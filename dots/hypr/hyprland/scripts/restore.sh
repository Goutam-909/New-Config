#!/usr/bin/env bash
# ~/.config/uchiha/scripts/my-script-wall.sh
#
# Login wallpaper restore — reads background state from config.json and
# re-applies the last wallpaper (image via swww, video via mpvpaper).
#
# Usage:
#   my-script-wall.sh          Restore wallpaper from config.json
#   my-script-wall.sh --check  Same as above (explicit flag for hyprland exec-once)
#   my-script-wall.sh --help   Show this message

set -euo pipefail
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$HOME/.local/bin:$PATH"

# ── Config ────────────────────────────────────────────────────────────────────
CONFIG_JSON="$HOME/.config/uchiha/music/config.json"
SCREENSHOT_DIR="$HOME/.config/hypr/screenshot"

# swww transition params (match wallpaper.sh)
SWWW_PARAMS="--transition-fps 60 --transition-type any --transition-duration 3 --transition-bezier 0.4,0.2,0.4,1.0"

# ── Helpers ───────────────────────────────────────────────────────────────────
info() { echo "==> $*"; }
die()  { echo "ERROR: $*" >&2; exit 1; }

# Read a value from config.json using jq
json_get() {
    local filter="$1" default="${2:-}"
    if command -v jq &>/dev/null && [[ -f "$CONFIG_JSON" ]]; then
        local val
        val=$(jq -r "${filter} // empty" "$CONFIG_JSON" 2>/dev/null)
        echo "${val:-$default}"
    else
        echo "$default"
    fi
}

# ── Kill helpers ──────────────────────────────────────────────────────────────
kill_mpvpaper() {
    /usr/bin/pgrep -x mpvpaper &>/dev/null || return 0
    info "Stopping mpvpaper..."
    /usr/bin/pkill -TERM mpvpaper 2>/dev/null || true
    local a=0
    while /usr/bin/pgrep -x mpvpaper &>/dev/null && (( a < 3 )); do
        /usr/bin/pkill -9 mpvpaper 2>/dev/null || true
        sleep 0.2; (( a++ ))
    done
}

kill_swww() {
    /usr/bin/pgrep -x swww-daemon &>/dev/null || /usr/bin/pgrep -x swww &>/dev/null || return 0
    info "Stopping swww..."
    /usr/bin/pkill -9 swww-daemon 2>/dev/null || true
    /usr/bin/pkill -9 swww         2>/dev/null || true
    local a=0
    while /usr/bin/pgrep -x swww-daemon &>/dev/null && (( a < 5 )); do
        sleep 0.2; (( a++ ))
    done
}

ensure_swww() {
    if ! /usr/bin/pgrep -x swww-daemon &>/dev/null; then
        info "Starting swww-daemon..."
        /usr/bin/swww-daemon &
        sleep 1
    fi
    local a=0
    while ! /usr/bin/swww query &>/dev/null && (( a < 10 )); do
        sleep 0.3; (( a++ ))
    done
}

# ── Restore ───────────────────────────────────────────────────────────────────
restore_wallpaper() {
    [[ -f "$CONFIG_JSON" ]] || die "config.json not found: $CONFIG_JSON"

    local wall thumb
    wall=$(json_get  '.background.wallpaperPath'  "")
    thumb=$(json_get '.background.thumbnailPath'  "")

    [[ -n "$wall" ]] || die "No wallpaperPath in config.json — set a wallpaper first"
    [[ -f "$wall" ]] || die "Wallpaper file not found: $wall"

    # Determine type from extension
    local ext="${wall##*.}"
    case "${ext,,}" in
        mp4|mkv|webm|avi|mov|flv|m4v|wmv)
            restore_video "$wall" "$thumb"
            ;;
        *)
            restore_image "$wall"
            ;;
    esac
}

restore_image() {
    local img="$1"
    info "Restoring image wallpaper: $(basename "$img")"

    kill_mpvpaper
    ensure_swww

    if /usr/bin/swww query &>/dev/null; then
        /usr/bin/swww img "$img" $SWWW_PARAMS
        info "Image wallpaper restored via swww"
    elif command -v swaybg &>/dev/null; then
        setsid swaybg -i "$img" &
        disown
        info "Image wallpaper restored via swaybg (fallback)"
    else
        die "Neither swww nor swaybg is available"
    fi
}

restore_video() {
    local video="$1" thumb="$2"
    info "Restoring video wallpaper: $(basename "$video")"

    command -v mpvpaper &>/dev/null || die "mpvpaper is not installed"

    kill_swww
    kill_mpvpaper

    setsid /usr/bin/mpvpaper \
        -o 'no-audio --loop-file=inf --hwdec=auto' \
        '*' "$video" </dev/null &>/dev/null &
    disown

    # Verify it started
    sleep 0.5
    if /usr/bin/pgrep -x mpvpaper &>/dev/null; then
        info "Video wallpaper restored via mpvpaper"
    else
        sleep 1
        /usr/bin/pgrep -x mpvpaper &>/dev/null \
            && info "Video wallpaper restored via mpvpaper" \
            || echo "WARNING: mpvpaper may not have started properly" >&2
    fi
}

# ── Entry point ───────────────────────────────────────────────────────────────
case "${1:-}" in
    --check|"")
        restore_wallpaper
        ;;
    --help|-h)
        grep '^#' "$0" | grep -v '#!/' | sed 's/^# \?//'
        exit 0
        ;;
    *)
        die "Unknown option: $1 (try --help)"
        ;;
esac
