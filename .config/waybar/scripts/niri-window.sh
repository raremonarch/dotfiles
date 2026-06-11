#!/bin/bash
# Emit the focused window title as waybar JSON, updating live from niri's event stream.
# Output: {"text": <title>, "tooltip": "<app_id>  ·  <title>"}
set -u

last=""

emit() {
    local json out
    json=$(niri msg --json focused-window 2>/dev/null)
    if [ -z "$json" ] || [ "$json" = "null" ]; then
        out='{"text":"","tooltip":""}'
    else
        out=$(printf '%s' "$json" | jq -c '{
            text: (.app_id // "" | ascii_downcase),
            tooltip: ((.app_id // "?") + "  ·  " + (.title // ""))
        }')
    fi
    # Only emit on change to avoid needless waybar churn.
    if [ "$out" != "$last" ]; then
        printf '%s\n' "$out"
        last="$out"
    fi
}

emit
niri msg event-stream 2>/dev/null | while read -r line; do
    case "$line" in
        *[Ww]indow*|*[Ff]ocus*) emit ;;
    esac
done
