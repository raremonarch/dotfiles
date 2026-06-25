#!/bin/bash
# Emit the focused window app/command as waybar JSON, updating live from niri's event stream.
# For terminals (Alacritty), walks the process tree to find the running command rather than
# using the window title (which programs like Claude Code override with their own strings).
set -u

last=""

# Walk the process tree from a terminal emulator PID, skipping shell wrappers,
# to find the first interesting command.
find_terminal_cmd() {
    local pid=$1 cmd next child
    child=$(ps --ppid "$pid" -o pid= 2>/dev/null | tail -1 | tr -d ' ')
    [ -z "$child" ] && return
    while true; do
        cmd=$(ps -p "$child" -o comm= 2>/dev/null | tr -d ' ')
        case "$cmd" in
            zsh|bash|sh|fish|dash)
                next=$(ps --ppid "$child" -o pid= 2>/dev/null | tail -1 | tr -d ' ')
                [ -z "$next" ] && return  # shell at prompt, nothing running
                child="$next"
                ;;
            *) printf '%s' "$cmd"; return ;;
        esac
    done
}

emit() {
    local json app pid title cmd label out
    json=$(niri msg --json focused-window 2>/dev/null)
    if [ -z "$json" ] || [ "$json" = "null" ]; then
        out='{"text":"","tooltip":""}'
    else
        app=$(printf '%s' "$json" | jq -r '(.app_id // "") | ascii_downcase')
        pid=$(printf '%s' "$json" | jq -r '.pid // 0')
        title=$(printf '%s' "$json" | jq -r '.title // ""')

        if [ "$app" = "alacritty" ] && [ "$pid" -gt 0 ]; then
            cmd=$(find_terminal_cmd "$pid")
            label="${app}${cmd:+:$cmd}"
        else
            label="$app"
        fi

        out=$(jq -cn --arg text "$label" --arg tooltip "${app}  ·  ${title}" \
            '{text: $text, tooltip: $tooltip}')
    fi

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
