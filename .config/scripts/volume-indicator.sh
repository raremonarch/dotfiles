#!/bin/bash
# volume indicator for polybar

# Get current volume and mute status using pactl
volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1 | tr -d '%')
muted=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -o "yes\|no")

if [ "$muted" = "yes" ]; then
    icon="[X]"
    text="MUTED"
elif [ "$volume" -gt 70 ]; then
    icon="VOL"
    text="$volume%"
elif [ "$volume" -gt 30 ]; then
    icon="VOL"
    text="$volume%"
else
    icon="VOL"
    text="$volume%"
fi

# Play test sound (only if not muted)
if [ "$muted" != "yes" ]; then
    paplay /usr/share/sounds/freedesktop/stereo/bell.oga &
fi

# Show notification
notify-send -r 12345 -t 1500 "$icon $text" -h int:value:$volume
