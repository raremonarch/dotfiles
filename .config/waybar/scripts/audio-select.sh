#!/bin/bash
# Select audio output sink via rofi and set as default,
# also moving any active streams to the new sink.

# Build "Description → Name" pairs for display
declare -A sink_map
current_name=""
while IFS= read -r line; do
    if [[ "$line" =~ Name:\ (.+) ]]; then
        current_name="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ Description:\ (.+) ]] && [[ -n "$current_name" ]]; then
        sink_map["${BASH_REMATCH[1]}"]="$current_name"
        current_name=""
    fi
done < <(pactl list sinks)

# Show descriptions in rofi
selected=$(printf '%s\n' "${!sink_map[@]}" | rofi -dmenu -p "Audio Output")
[[ -z "$selected" ]] && exit 0

sink_name="${sink_map[$selected]}"
pactl set-default-sink "$sink_name"

# Move all active sink inputs to the new default
pactl list short sink-inputs | awk '{print $1}' | while read -r input; do
    pactl move-sink-input "$input" "$sink_name"
done
