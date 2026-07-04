#!/usr/bin/env python3
"""
Anime API server for Quickshell
- AniList GraphQL  → search, popular (trending), latest (recent)
- allanime scraper → episode list + stream links (unchanged from original)
Run: pip install flask requests && python anime_server.py
"""

import re
import threading
import time
import urllib.parse
from concurrent.futures import ThreadPoolExecutor, as_completed

import requests
from flask import Flask, jsonify, request

app = Flask(__name__)

# ── AniList ───────────────────────────────────────────────────────────────────
ANILIST_API = "https://graphql.anilist.co"

def _anilist(query: str, variables: dict) -> dict:
    resp = requests.post(
        ANILIST_API,
        json={"query": query, "variables": variables},
        headers={"Content-Type": "application/json", "Accept": "application/json"},
        timeout=15,
    )
    resp.raise_for_status()
    return resp.json()

def _norm_media(m: dict) -> dict:
    """Normalise an AniList media node to our shared show shape."""
    title  = m.get("title") or {}
    cover  = m.get("coverImage") or {}
    avail  = m.get("streamingEpisodes") or []
    return {
        "id":           "al_" + str(m.get("id", "")),   # prefix so we know source
        "anilist_id":   m.get("id"),
        "name":         title.get("romaji") or title.get("english") or "",
        "english_name": title.get("english") or title.get("romaji") or "",
        "native_name":  title.get("native") or "",
        "thumbnail":    cover.get("large") or cover.get("medium") or "",
        "score":        (m.get("averageScore") or 0) / 10.0 or None,
        "type":         m.get("format") or "",
        "episode_count": m.get("episodes") or "",
        "available_episodes": {
            "sub": m.get("episodes") or 0,
            "dub": 0,
            "raw": 0,
        },
        "season": {
            "quarter": m.get("season"),
            "year":    m.get("seasonYear"),
        },
    }

# ── allanime (stream links only) ─────────────────────────────────────────────
AGENT         = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0"
ALLANIME_REFR = "https://allmanga.to"
ALLANIME_BASE = "allanime.day"
ALLANIME_API  = f"https://api.{ALLANIME_BASE}"

HEADERS = {
    "User-Agent": AGENT,
    "Referer":    ALLANIME_REFR,
}

HEX_MAP = {
    "79":"A","7a":"B","7b":"C","7c":"D","7d":"E","7e":"F","7f":"G",
    "70":"H","71":"I","72":"J","73":"K","74":"L","75":"M","76":"N",
    "77":"O","68":"P","69":"Q","6a":"R","6b":"S","6c":"T","6d":"U",
    "6e":"V","6f":"W","60":"X","61":"Y","62":"Z",
    "59":"a","5a":"b","5b":"c","5c":"d","5d":"e","5e":"f","5f":"g",
    "50":"h","51":"i","52":"j","53":"k","54":"l","55":"m","56":"n",
    "57":"o","48":"p","49":"q","4a":"r","4b":"s","4c":"t","4d":"u",
    "4e":"v","4f":"w","40":"x","41":"y","42":"z",
    "08":"0","09":"1","0a":"2","0b":"3","0c":"4","0d":"5",
    "0e":"6","0f":"7","00":"8","01":"9",
    "15":"-","16":".","67":"_","46":"~","02":":","17":"/",
    "07":"?","1b":"#","63":"[","65":"]","78":"@","19":"!",
    "1c":"$","1e":"&","10":"(","11":")","12":"*","13":"+",
    "14":",","03":";","05":"=","1d":"%",
}

def decode_provider_url(encoded: str) -> str:
    pairs  = [encoded[i:i+2] for i in range(0, len(encoded), 2)]
    result = "".join(HEX_MAP.get(p, p) for p in pairs)
    result = result.replace("/clock", "/clock.json")
    return result

SEARCH_GQL = (
    "query( $search: SearchInput $limit: Int $page: Int "
    "$translationType: VaildTranslationTypeEnumType "
    "$countryOrigin: VaildCountryOriginEnumType ) { "
    "shows( search: $search limit: $limit page: $page "
    "translationType: $translationType countryOrigin: $countryOrigin ) "
    "{ edges { _id name englishName nativeName thumbnail score "
    "availableEpisodes episodeCount __typename } }}"
)

EPISODES_LIST_GQL = (
    "query ($showId: String!) { show( _id: $showId ) { _id availableEpisodesDetail }}"
)

EPISODE_EMBED_GQL = (
    "query ($showId: String!, $translationType: VaildTranslationTypeEnumType!, "
    "$episodeString: String!) { episode( showId: $showId translationType: $translationType "
    "episodeString: $episodeString ) { episodeString sourceUrls }}"
)

def _allanime_search(query: str, mode: str = "sub") -> list[dict]:
    """Search allanime by title — used to resolve AniList IDs to allanime IDs."""
    import json
    params = {
        "variables": json.dumps({
            "search": {"allowAdult": False, "allowUnknown": False, "query": query},
            "limit": 5, "page": 1,
            "translationType": mode, "countryOrigin": "ALL",
        }),
        "query": SEARCH_GQL,
    }
    resp = requests.get(f"{ALLANIME_API}/api", params=params, headers=HEADERS, timeout=15)
    resp.raise_for_status()
    edges = resp.json().get("data", {}).get("shows", {}).get("edges", [])
    return edges

def _resolve_allanime_id(title: str, mode: str = "sub") -> str | None:
    """Given a show title, return the allanime _id (or None on failure)."""
    try:
        edges = _allanime_search(title, mode)
        if edges:
            return edges[0].get("_id")
    except Exception:
        pass
    return None

def episodes_list(show_id: str, mode: str = "sub") -> list[str]:
    import json
    params = {
        "variables": json.dumps({"showId": show_id}),
        "query": EPISODES_LIST_GQL,
    }
    resp = requests.get(f"{ALLANIME_API}/api", params=params, headers=HEADERS, timeout=15)
    resp.raise_for_status()
    raw = resp.text
    m = re.search(r'"' + mode + r'\":\[([0-9.\",]*)\]', raw)
    if not m:
        return []
    eps_raw = m.group(1)
    eps = [e.strip('"') for e in eps_raw.split(",") if e.strip('"')]
    try:
        eps.sort(key=lambda x: float(x))
    except ValueError:
        eps.sort()
    return eps

def _get_links_from_url(path: str) -> list[dict]:
    url = f"https://{ALLANIME_BASE}{path}"
    try:
        resp = requests.get(url, headers=HEADERS, timeout=15)
        resp.raise_for_status()
        raw = resp.text
    except Exception as e:
        return [{"error": str(e), "url": url}]

    links = []

    if "repackager.wixmp.com" in raw:
        for m in re.finditer(r'"link":"([^"]*repackager\.wixmp\.com[^"]*)".*?"resolutionStr":"([^"]*)"', raw):
            links.append({"quality": m.group(2), "url": m.group(1), "type": "mp4"})
        return links

    if "master.m3u8" in raw:
        m_url  = re.search(r'"url":"([^"]*master\.m3u8[^"]*)"', raw)
        m_refr = re.search(r'"Referer":"([^"]*)"', raw)
        subtitle_m = re.search(r'"subtitles":\[.*?"lang":"en".*?"src":"([^"]*)"', raw)
        referer  = m_refr.group(1) if m_refr else ALLANIME_REFR
        subtitle = subtitle_m.group(1) if subtitle_m else None
        if m_url:
            m3u8_url = m_url.group(1)
            try:
                m3u8_resp = requests.get(m3u8_url, headers={**HEADERS, "Referer": referer}, timeout=15)
                m3u8_text = m3u8_resp.text
                base = m3u8_url.rsplit("/", 1)[0] + "/"
                stream_re = re.compile(r'#EXT-X-STREAM-INF[^\n]*RESOLUTION=\d+x(\d+)[^\n]*\n([^\n]+)')
                for sm in stream_re.finditer(m3u8_text):
                    height      = sm.group(1)
                    stream_path = sm.group(2).strip()
                    stream_url  = stream_path if stream_path.startswith("http") else base + stream_path
                    links.append({"quality": f"{height}p", "url": stream_url, "type": "m3u8",
                                  "referer": referer, **({"subtitle": subtitle} if subtitle else {})})
                if not links:
                    links.append({"quality": "best", "url": m3u8_url, "type": "m3u8", "referer": referer})
            except Exception as e:
                links.append({"quality": "best", "url": m3u8_url, "type": "m3u8",
                               "referer": referer, "parse_error": str(e)})
        return links

    for m in re.finditer(r'"link":"([^"]*)".*?"resolutionStr":"([^"]*)"', raw):
        links.append({"quality": m.group(2), "url": m.group(1), "type": "mp4"})

    if "tools.fast4speed.rsvp" in raw:
        m = re.search(r'"url"\s*:\s*"(https://tools\.fast4speed\.rsvp[^"]+)"', raw)
        if m:
            links.append({"quality": "best", "url": m.group(1), "type": "yt", "referer": ALLANIME_REFR})
        elif path.startswith("https://tools.fast4speed.rsvp"):
            links.append({"quality": "best", "url": path, "type": "yt", "referer": ALLANIME_REFR})

    return links

def get_episode_links(show_id: str, ep_no: str, mode: str = "sub") -> dict:
    import json
    params = {
        "variables": json.dumps({
            "showId": show_id,
            "translationType": mode,
            "episodeString": ep_no,
        }),
        "query": EPISODE_EMBED_GQL,
    }
    resp = requests.get(f"{ALLANIME_API}/api", params=params, headers=HEADERS, timeout=15)
    resp.raise_for_status()

    data      = resp.json()
    ep_data   = data.get("data", {}).get("episode")
    if not ep_data:
        return {"error": "Episode not found"}

    source_urls = ep_data.get("sourceUrls", [])
    if not source_urls:
        return {"error": "No source URLs found"}

    PROVIDER_PATTERNS = {
        "wixmp":      r"Default\s*:([^\n]+)",
        "youtube":    r"Yt-mp4\s*:([^\n]+)",
        "sharepoint": r"S-mp4\s*:([^\n]+)",
        "hianime":    r"Luf-Mp4\s*:([^\n]+)",
    }

    resp_normalized = "\n".join(
        f"{su.get('sourceName','')} :{su.get('sourceUrl','')}"
        for su in source_urls
    )

    all_links = []
    providers = {}

    with ThreadPoolExecutor(max_workers=4) as ex:
        futures = {}
        for name, pattern in PROVIDER_PATTERNS.items():
            m = re.search(pattern, resp_normalized)
            if m:
                encoded = m.group(1).strip()
                path    = decode_provider_url(encoded)
                futures[ex.submit(_get_links_from_url, path)] = name

        for future in as_completed(futures):
            name  = futures[future]
            links = future.result()
            providers[name] = links
            all_links.extend(links)

    valid = [l for l in all_links if not l.get("error") and l.get("url")]
    return {
        "show_id": show_id,
        "episode": ep_no,
        "mode":    mode,
        "providers":  providers,
        "all_links":  valid or all_links,
    }

# ── Flask routes ──────────────────────────────────────────────────────────────

@app.route("/health")
def health():
    return jsonify({"status": "ok"})

@app.route("/")
def index():
    return jsonify({
        "name": "Anime API (AniList + allanime)",
        "endpoints": {
            "GET /search?q=":     "Search anime by title",
            "GET /popular":       "Trending anime (AniList)",
            "GET /latest":        "Recently updated anime (AniList)",
            "GET /episodes?id=":  "Episode list for a show (allanime ID or title lookup)",
            "GET /links?id=&ep=": "Stream links for an episode",
            "GET /health":        "Health check",
        },
    })

@app.route("/search")
def search_route():
    q    = request.args.get("q", "").strip()
    mode = request.args.get("mode", "sub").strip()
    if not q:
        return jsonify({"error": "Missing required param: q"}), 400

    SEARCH_QUERY = """
    query ($search: String, $page: Int, $perPage: Int) {
      Page(page: $page, perPage: $perPage) {
        pageInfo { total hasNextPage }
        media(search: $search, type: ANIME, sort: SEARCH_MATCH) {
          id
          title { romaji english native }
          coverImage { large medium }
          averageScore
          format
          episodes
          season
          seasonYear
          status
        }
      }
    }
    """
    try:
        data  = _anilist(SEARCH_QUERY, {"search": q, "page": 1, "perPage": 30})
        items = data.get("data", {}).get("Page", {}).get("media", [])
        return jsonify({"query": q, "count": len(items), "results": [_norm_media(m) for m in items]})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/popular")
def popular_route():
    try:
        page = int(request.args.get("page", 1))
        size = int(request.args.get("size", 20))
    except ValueError:
        return jsonify({"error": "page and size must be integers"}), 400

    TRENDING_QUERY = """
    query ($page: Int, $perPage: Int) {
      Page(page: $page, perPage: $perPage) {
        pageInfo { total hasNextPage }
        media(sort: TRENDING_DESC, type: ANIME, isAdult: false) {
          id
          title { romaji english native }
          coverImage { large medium }
          averageScore
          format
          episodes
          season
          seasonYear
        }
      }
    }
    """
    try:
        data  = _anilist(TRENDING_QUERY, {"page": page, "perPage": size})
        page_info = data.get("data", {}).get("Page", {}).get("pageInfo", {})
        items = data.get("data", {}).get("Page", {}).get("media", [])
        return jsonify({
            "page":  page,
            "size":  size,
            "total": page_info.get("total", len(items)),
            "count": len(items),
            "shows": [_norm_media(m) for m in items],
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/latest")
def latest_route():
    try:
        page  = int(request.args.get("page",  1))
        limit = int(request.args.get("limit", 26))
    except ValueError:
        return jsonify({"error": "page and limit must be integers"}), 400

    q = request.args.get("q", "").strip()

    RECENT_QUERY = """
    query ($page: Int, $perPage: Int, $search: String) {
      Page(page: $page, perPage: $perPage) {
        pageInfo { total hasNextPage }
        media(sort: UPDATED_AT_DESC, type: ANIME, isAdult: false, search: $search) {
          id
          title { romaji english native }
          coverImage { large medium }
          averageScore
          format
          episodes
          season
          seasonYear
        }
      }
    }
    """
    variables = {"page": page, "perPage": limit}
    if q:
        variables["search"] = q

    try:
        data      = _anilist(RECENT_QUERY, variables)
        page_info = data.get("data", {}).get("Page", {}).get("pageInfo", {})
        items     = data.get("data", {}).get("Page", {}).get("media", [])
        return jsonify({
            "page":  page,
            "limit": limit,
            "total": page_info.get("total", len(items)),
            "count": len(items),
            "shows": [_norm_media(m) for m in items],
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/episodes")
def episodes_route():
    show_id = request.args.get("id", "").strip()
    mode    = request.args.get("mode", "sub").strip()
    if not show_id:
        return jsonify({"error": "Missing required param: id"}), 400

    # AniList IDs are prefixed "al_" — resolve to allanime ID via title search
    allanime_id = show_id
    if show_id.startswith("al_"):
        anilist_id = show_id[3:]
        # Fetch title from AniList first
        TITLE_QUERY = """
        query ($id: Int) {
          Media(id: $id, type: ANIME) {
            title { romaji english }
          }
        }
        """
        try:
            data  = _anilist(TITLE_QUERY, {"id": int(anilist_id)})
            title_obj = data.get("data", {}).get("Media", {}).get("title", {})
            title = title_obj.get("english") or title_obj.get("romaji") or ""
            if not title:
                return jsonify({"error": "Could not resolve title for id " + show_id}), 404
            resolved = _resolve_allanime_id(title, mode)
            if not resolved:
                return jsonify({"error": f"Show '{title}' not found on allanime"}), 404
            allanime_id = resolved
        except Exception as e:
            return jsonify({"error": "AniList lookup failed: " + str(e)}), 500

    try:
        eps = episodes_list(allanime_id, mode)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    return jsonify({"id": allanime_id, "original_id": show_id, "mode": mode,
                    "count": len(eps), "episodes": eps})

@app.route("/links")
def links_route():
    show_id = request.args.get("id", "").strip()
    ep_no   = request.args.get("ep", "").strip()
    mode    = request.args.get("mode", "sub").strip()
    quality = request.args.get("quality", "best").strip()

    if not show_id:
        return jsonify({"error": "Missing required param: id"}), 400
    if not ep_no:
        return jsonify({"error": "Missing required param: ep"}), 400

    # Resolve AniList ID → allanime ID
    allanime_id = show_id
    if show_id.startswith("al_"):
        anilist_id = show_id[3:]
        TITLE_QUERY = """
        query ($id: Int) {
          Media(id: $id, type: ANIME) { title { romaji english } }
        }
        """
        try:
            data      = _anilist(TITLE_QUERY, {"id": int(anilist_id)})
            title_obj = data.get("data", {}).get("Media", {}).get("title", {})
            title     = title_obj.get("english") or title_obj.get("romaji") or ""
            resolved  = _resolve_allanime_id(title, mode)
            if not resolved:
                return jsonify({"error": f"Show '{title}' not found on allanime"}), 404
            allanime_id = resolved
        except Exception as e:
            return jsonify({"error": "ID resolution failed: " + str(e)}), 500

    try:
        data = get_episode_links(allanime_id, ep_no, mode)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    if "error" in data:
        return jsonify(data), 404

    all_links = data.get("all_links", [])
    if quality == "best":
        selected = all_links[0] if all_links else None
    elif quality == "worst":
        numeric  = [l for l in all_links if re.match(r"\d+", l.get("quality", ""))]
        selected = numeric[-1] if numeric else (all_links[-1] if all_links else None)
    else:
        matched  = [l for l in all_links if quality in l.get("quality", "")]
        selected = matched[0] if matched else (all_links[0] if all_links else None)

    if selected and "error" in selected:
        selected = None

    data["selected"] = selected
    data["requested_quality"] = quality
    return jsonify(data)


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Anime API server")
    parser.add_argument("--host",  default="0.0.0.0")
    parser.add_argument("--port",  type=int, default=5050)
    parser.add_argument("--debug", action="store_true")
    args = parser.parse_args()

    print("""
  ┌─────────────────────────────────────────┐
  │         Anime API (AniList)             │
  │  http://0.0.0.0:5050                    │
  ├─────────────────────────────────────────┤
  │  GET /search?q=blue+lock               │
  │  GET /popular                          │
  │  GET /latest                           │
  │  GET /episodes?id=<id>                 │
  │  GET /links?id=<id>&ep=1              │
  └─────────────────────────────────────────┘
""")
    app.run(host=args.host, port=args.port, debug=args.debug)
