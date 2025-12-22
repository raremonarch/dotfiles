#!/bin/bash
# Power menu for Niri using rofi

options="Logout\nReboot\nShutdown\nCancel"

chosen=$(echo -e "$options" | rofi -dmenu -p "Power Menu" -theme-str 'window {width: 200px;} listview {lines: 4;}')

case "$chosen" in
    Logout)
        loginctl terminate-session ""
        ;;
    Reboot)
        systemctl reboot
        ;;
    Shutdown)
        systemctl poweroff
        ;;
    *)
        # Cancel or Esc pressed
        exit 0
        ;;
esac
