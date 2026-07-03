#!/bin/bash
# Single rofi power menu for waybar. No confirmation — the menu choice is the action.

_is_systemd() { [ "$(ps -o comm= -p 1 2>/dev/null)" = "systemd" ]; }

# On systemd, systemctl reboot/poweroff properly tears down the session in order.
# On OpenRC there is no equivalent session layer, so we do it ourselves.
#
# Send xdg_toplevel.close to every window via niri's IPC — the same Wayland
# protocol event Chrome receives when you click the X button, which triggers a
# full clean shutdown with session save. Then wait only for those specific
# window-owning processes to exit before issuing the reboot/poweroff.
_graceful_session_end() {
    trap '' TERM HUP

    local window_json
    window_json=$(niri msg -j windows 2>/dev/null)

    local window_ids window_pids
    window_ids=$(echo "$window_json" | jq -r '.[].id' 2>/dev/null)
    window_pids=$(echo "$window_json" | jq -r '.[].pid' 2>/dev/null)

    for wid in $window_ids; do
        niri msg action close-window --id "$wid" 2>/dev/null
    done

    if [ -n "$window_pids" ]; then
        local deadline=$(( $(date +%s) + 15 ))
        while IFS= read -r pid; do
            while kill -0 "$pid" 2>/dev/null; do
                if (( $(date +%s) >= deadline )); then
                    kill -TERM "$pid" 2>/dev/null
                    break
                fi
                sleep 0.2
            done
        done <<< "$window_pids"
    fi

    trap - TERM HUP
}

chosen=$(printf 'Shutdown\nReboot\nHibernate\n' | rofi -dmenu -p "Power")

case "$chosen" in
    Shutdown)
        if _is_systemd; then systemctl poweroff; else _graceful_session_end && loginctl poweroff; fi
        ;;
    Reboot)
        if _is_systemd; then systemctl reboot; else _graceful_session_end && loginctl reboot; fi
        ;;
    Hibernate)
        ~/.config/waybar/scripts/hibernate.sh
        ;;
esac
