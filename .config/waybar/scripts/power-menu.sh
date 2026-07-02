#!/bin/bash
# Single rofi power menu for waybar. No confirmation — the menu choice is the action.

_is_systemd() { [ "$(ps -o comm= -p 1 2>/dev/null)" = "systemd" ]; }

chosen=$(printf 'Shutdown\nReboot\nHibernate\n' | rofi -dmenu -p "Power")

case "$chosen" in
    Shutdown)
        if _is_systemd; then systemctl poweroff; else loginctl poweroff; fi
        ;;
    Reboot)
        if _is_systemd; then systemctl reboot; else loginctl reboot; fi
        ;;
    Hibernate)
        ~/.config/waybar/scripts/hibernate.sh
        ;;
esac
