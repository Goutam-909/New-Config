#!/usr/bin/env bash
# clock_position.sh
# Analyses the wallpaper (or its cached thumbnail for videos/GIFs), finds the
# least-busy region, and writes clockX / clockY / clockColor into
# ~/.config/ambxst/config/desktop.json so DesktopClockWidget picks them up.
#
# clockColor is written as a NAMED KEY (e.g. "primary", "secondary", "cyan")
# not a raw hex, so the clock continues to track live theme-color changes.
# The key is chosen by computing WCAG contrast ratios of every palette color
# against the region's dominant background color, then picking the winner.
#
# Usage (called from Wallpaper.qml / wallpaper-change hook):
#   clock_position.sh /path/to/wallpaper

set -uo pipefail

# ── Args ──────────────────────────────────────────────────────────────────────
WALLPAPER="${1:-}"
if [[ -z "$WALLPAPER" ]]; then
    echo "Usage: $0 /path/to/wallpaper" >&2
    exit 1
fi

# ── Paths ─────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="/home/goutam/.config/quickshell/Ambxst/venv"
PYTHON_SCRIPT="$SCRIPT_DIR/least_busy_region.py"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
DESKTOP_JSON="$CONFIG_HOME/ambxst/config/desktop.json"

# Quickshell's cache dir is $XDG_CACHE_HOME/quickshell/<ShellName>/ where
# ShellName matches the config directory name (e.g. "Ambxst").
# We derive it from the venv path so it stays correct if the shell is renamed.
# venv: ~/.config/quickshell/Ambxst/venv  →  ShellName = Ambxst
_SHELL_NAME="$(basename "$(dirname "$VENV_DIR")")"
QUICKSHELL_CACHE="$CACHE_HOME/quickshell/$_SHELL_NAME"
COLORS_JSON="$QUICKSHELL_CACHE/colors.json"
TMP_FRAME=""

# ── Sanity checks ─────────────────────────────────────────────────────────────
for f in "$VENV_DIR/bin/activate" "$PYTHON_SCRIPT" "$DESKTOP_JSON"; do
    if [[ ! -f "$f" ]]; then
        echo "Error: required file not found: $f" >&2
        exit 1
    fi
done

# ── Venv activate — deactivate guaranteed via EXIT trap ───────────────────────
# shellcheck source=/dev/null
source "$VENV_DIR/bin/activate"

cleanup() {
    deactivate 2>/dev/null || true
    [[ -n "$TMP_FRAME" && -f "$TMP_FRAME" ]] && rm -f "$TMP_FRAME"
}
trap cleanup EXIT

# ── Determine the image to analyse ───────────────────────────────────────────
image_path="$WALLPAPER"
ext_lower="${WALLPAPER##*.}"
ext_lower="${ext_lower,,}"

if [[ "$ext_lower" =~ ^(mp4|webm|mov|avi|mkv|gif)$ ]]; then
    wallpaper_dir=""
    wallpaper_json="$QUICKSHELL_CACHE/wallpapers.json"
    if [[ -f "$wallpaper_json" ]] && command -v jq &>/dev/null; then
        wallpaper_dir="$(jq -r '.wallPath // empty' "$wallpaper_json" 2>/dev/null || true)"
    fi

    if [[ -n "$wallpaper_dir" ]]; then
        base_path="${wallpaper_dir%/}/"
        rel_path="${WALLPAPER#"$base_path"}"
    else
        rel_path="$(basename "$WALLPAPER")"
    fi

    rel_dir="$(dirname "$rel_path")"
    file_name="$(basename "$rel_path")"
    thumbnail="${QUICKSHELL_CACHE}/thumbnails/$([[ "$rel_dir" == "." ]] && echo "" || echo "${rel_dir}/")${file_name}.jpg"

    if [[ -f "$thumbnail" ]]; then
        image_path="$thumbnail"
        echo "Using cached thumbnail: $thumbnail"
    elif command -v ffmpeg &>/dev/null; then
        TMP_FRAME="/tmp/ambxst_clock_frame_$$.jpg"
        if ffmpeg -y -i "$WALLPAPER" -vframes 1 -q:v 2 "$TMP_FRAME" &>/dev/null; then
            image_path="$TMP_FRAME"
            echo "Extracted frame to $TMP_FRAME"
        else
            echo "ffmpeg failed — using wallpaper path as-is" >&2
        fi
    else
        echo "No thumbnail or ffmpeg, using path as-is" >&2
    fi
fi

# ── Screen resolution ─────────────────────────────────────────────────────────
screen_width=1920
screen_height=1080
if command -v hyprctl &>/dev/null; then
    monitor_json="$(hyprctl monitors -j 2>/dev/null | jq '.[0]' 2>/dev/null || true)"
    if [[ -n "$monitor_json" ]]; then
        w="$(echo "$monitor_json" | jq -r '.width  // empty' 2>/dev/null || true)"
        h="$(echo "$monitor_json" | jq -r '.height // empty' 2>/dev/null || true)"
        [[ -n "$w" ]] && screen_width="$w"
        [[ -n "$h" ]] && screen_height="$h"
    fi
fi
echo "Screen: ${screen_width}x${screen_height}"

# ── Clock widget approximate size ─────────────────────────────────────────────
CLOCK_W=560
CLOCK_H=210

# ── Run least_busy_region.py ──────────────────────────────────────────────────
echo "Analysing $image_path for least-busy ${CLOCK_W}x${CLOCK_H} region..."
result="$(python3 "$PYTHON_SCRIPT" \
    "$image_path" \
    --width  "$CLOCK_W" \
    --height "$CLOCK_H" \
    --screen-width  "$screen_width" \
    --screen-height "$screen_height" \
    --stride 8)"

if [[ -z "$result" ]]; then
    echo "Error: least_busy_region.py returned no output" >&2
    exit 1
fi

center_x="$(echo "$result" | jq -r '.center_x')"
center_y="$(echo "$result" | jq -r '.center_y')"
dominant_hex="$(echo "$result" | jq -r '.dominant_color')"

if [[ "$center_x" == "null" || "$center_y" == "null" ]]; then
    echo "Error: could not parse output from: $result" >&2
    exit 1
fi

# ── Convert center → top-left, clamp to screen ───────────────────────────────
clock_x=$(( center_x - CLOCK_W / 2 ))
clock_y=$(( center_y - CLOCK_H / 2 ))
(( clock_x < 0 )) && clock_x=0
(( clock_y < 0 )) && clock_y=0
(( clock_x + CLOCK_W > screen_width  )) && clock_x=$(( screen_width  - CLOCK_W ))
(( clock_y + CLOCK_H > screen_height )) && clock_y=$(( screen_height - CLOCK_H ))

clock_color="auto"

# ── Patch desktop.json atomically ─────────────────────────────────────────────
# clockAutoColor  → the script's best-contrast palette key, read by QML when
#                   the user has clockColor set to "auto".
# clockColor      → intentionally NOT touched here so the user's manual color
#                   pick is never overwritten by the script.
tmp_json="$(mktemp)"
if jq \
    --argjson x         "$clock_x" \
    --argjson y         "$clock_y" \
    --arg     autocolor "$clock_color" \
    '.clockX = $x | .clockY = $y | .clockAutoColor = $autocolor' \
    "$DESKTOP_JSON" > "$tmp_json"; then
    mv "$tmp_json" "$DESKTOP_JSON"
    echo "Clock updated → x=$clock_x  y=$clock_y  autoColor=$clock_color  (center $center_x,$center_y)"
else
    rm -f "$tmp_json"
    echo "Error: jq failed to patch $DESKTOP_JSON" >&2
    exit 1
fi
