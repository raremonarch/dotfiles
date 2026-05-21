#!/bin/bash
# Select audio input source via rofi and set as default,
# also moving any active streams to the new source.

declare -A source_map
current_name=""
while IFS= read -r line; do
    if [[ "$line" =~ Name:\ (.+) ]]; then
        current_name="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ Description:\ (.+) ]] && [[ -n "$current_name" ]]; then
        source_map["${BASH_REMATCH[1]}"]="$current_name"
        current_name=""
    fi
done < <(pactl list sources | grep -v "Monitor of")

selected=$(printf '%s\n' "${!source_map[@]}" | rofi -dmenu -p "Audio Input")
[[ -z "$selected" ]] && exit 0

source_name="${source_map[$selected]}"
pactl set-default-source "$source_name"

pactl list short source-outputs | awk '{print $1}' | while read -r output; do
    pactl move-source-output "$output" "$source_name"
done
