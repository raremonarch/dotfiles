#!/bin/bash
# Single rofi power menu for waybar. No confirmation — the menu choice is the action.

_is_systemd() { [ "$(ps -o comm= -p 1 2>/dev/null)" = "systemd" ]; }

# On systemd, reboot/poweroff goes through systemd --user which stops the graphical
# session cleanly before rebooting. On OpenRC that session management layer doesn't
# exist, so we quit the compositor explicitly — it sends Wayland close events to all
# clients, letting them save state before the system goes down.
_quit_compositor() {
    if pgrep -x niri > /dev/null; then
        niri msg action quit 2>/dev/null
    elif pgrep -x Hyprland > /dev/null; then
        hyprctl dispatch exit 2>/dev/null
    elif pgrep -x sway > /dev/null; then
        swaymsg exit 2>/dev/null
    else
        return
    fi

    local waited=0
    while pgrep -x niri > /dev/null || pgrep -x Hyprland > /dev/null || pgrep -x sway > /dev/null; do
        sleep 0.5
        waited=$(( waited + 1 ))
        [ "$waited" -ge 10 ] && break  # 5 second timeout
    done
}

chosen=$(printf 'Shutdown\nReboot\nHibernate\n' | rofi -dmenu -p "Power")

case "$chosen" in
    Shutdown)
        _is_systemd || _quit_compositor
        if _is_systemd; then systemctl poweroff; else loginctl poweroff; fi
        ;;
    Reboot)
        _is_systemd || _quit_compositor
        if _is_systemd; then systemctl reboot; else loginctl reboot; fi
        ;;
    Hibernate)
        ~/.config/waybar/scripts/hibernate.sh
        ;;
esac
