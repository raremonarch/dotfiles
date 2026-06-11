#!/bin/bash
# Single rofi power menu for waybar. No confirmation — the menu choice is the action.

chosen=$(printf 'Shutdown\nReboot\nHibernate\n' | rofi -dmenu -p "Power")

case "$chosen" in
    Shutdown)  systemctl poweroff ;;
    Reboot)    systemctl reboot ;;
    Hibernate) ~/.config/waybar/scripts/hibernate.sh ;;
esac
