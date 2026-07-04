#!/usr/bin/env bash
# matugen_pick.sh - Drives matugen's interactive PTY color picker non-interactively
# Usage: matugen_pick.sh <index 0-3> <image_path> <scheme> <mode> <config_toml> <state_file>

set -euo pipefail
export PATH=/usr/local/bin:/usr/bin:/bin:$PATH

IDX="${1:-0}"
IMAGE="$2"
SCHEME="${3:-scheme-tonal-spot}"
MODE="${4:-dark}"
CONFIG_TOML="${5:-}"
STATE_FILE="${6:-/tmp/ambxst_matugen_state.json}"

[ -f "$IMAGE" ] || { echo "ERROR: image not found: $IMAGE" >&2; exit 1; }

# ── Fix misnamed files (e.g. PNG saved as .jpg) ───────────────────────────────
# Read the first 4 bytes to detect real file type
magic=$(xxd -p -l 4 "$IMAGE" 2>/dev/null || od -A n -t x1 -N 4 "$IMAGE" | tr -d ' \n')
ACTUAL_IMAGE="$IMAGE"

case "$magic" in
    89504e47*)  # PNG magic: \x89PNG
        FIXED="/tmp/ambxst_matugen_fixed_$$.png"
        cp "$IMAGE" "$FIXED"
        ACTUAL_IMAGE="$FIXED"
        ;;
    52494646*)  # RIFF/WEBP
        FIXED="/tmp/ambxst_matugen_fixed_$$.webp"
        cp "$IMAGE" "$FIXED"
        ACTUAL_IMAGE="$FIXED"
        ;;
    47494638*)  # GIF
        FIXED="/tmp/ambxst_matugen_fixed_$$.gif"
        cp "$IMAGE" "$FIXED"
        ACTUAL_IMAGE="$FIXED"
        ;;
esac

# Build arrow-down keystrokes × IDX then Enter
keys=""
i=0
while [ "$i" -lt "$IDX" ]; do
    keys="${keys}"$'\e[B'
    i=$((i + 1))
done
keys="${keys}"$'\n'

tmp=$(mktemp)

# Run matugen inside a PTY via script(1), feeding keystrokes after 0.5s
if [ -n "$CONFIG_TOML" ] && [ -f "$CONFIG_TOML" ]; then
    ( sleep 0.5; printf '%s' "$keys" ) | \
        script --quiet --return --command \
        "matugen image $(printf '%q' "$ACTUAL_IMAGE") -c $(printf '%q' "$CONFIG_TOML") -t $(printf '%q' "$SCHEME") -m $(printf '%q' "$MODE")" \
        "$tmp"
else
    ( sleep 0.5; printf '%s' "$keys" ) | \
        script --quiet --return --command \
        "matugen image $(printf '%q' "$ACTUAL_IMAGE") -t $(printf '%q' "$SCHEME") -m $(printf '%q' "$MODE")" \
        "$tmp"
fi
ret=$?

# Clean up temp copy if we made one
[ "$ACTUAL_IMAGE" != "$IMAGE" ] && rm -f "$ACTUAL_IMAGE"

# Strip ANSI codes, extract up to 4 distinct hex colors from picker output
colors=$(sed 's/\x1b\[[0-9;]*[mGKHFABCDJsu]//g; s/\r//g' "$tmp" \
    | grep -oP '#[0-9a-fA-F]{6}' \
    | awk '!seen[$0]++' \
    | head -4)
rm -f "$tmp"

# Write JSON state: { "sourceColors": [...], "sourceColorIndex": N }
if [ -n "$colors" ]; then
    json_arr=$(printf '%s\n' $colors | python3 -c "import sys,json; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))")
    python3 -c "
import json, sys
arr = json.loads(sys.argv[1])
idx = int(sys.argv[2])
out = {'sourceColors': arr, 'sourceColorIndex': idx}
print(json.dumps(out))
" "$json_arr" "$IDX" > "$STATE_FILE"
fi

exit $ret
