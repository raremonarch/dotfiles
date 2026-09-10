#!/bin/bash
# Outputs the given monitor's layout name as waybar JSON.
# Usage: mango-layout.sh <monitor-name>
# Fires on layout changes and monitor focus switches.

MONITOR="$1"

fmt() {
    jq -rc --arg mon "$MONITOR" '
        .monitors
        | map(select(.name == $mon))
        | first
        | .layout_symbol
        | {
            "T":  "tile",
            "S":  "scroller",
            "G":  "grid",
            "M":  "monocle",
            "K":  "deck",
            "CT": "center tile",
            "RT": "right tile",
            "VS": "vertical scroller",
            "VT": "vertical tile",
            "VG": "vertical grid",
            "VK": "vertical deck",
            "DW": "dwindle",
            "F":  "fair",
            "VF": "vertical fair"
        }[.] // .
        | "layout [ \(.) ]"
        | {text: .}
    ' 2>/dev/null
}

mmsg get all-monitors | fmt

mmsg watch all-monitors | while IFS= read -r line; do
    echo "$line" | fmt
done
