#!/bin/sh
# Wallpaper background daemon
swaybg -i /home/david/SynologyDrive/system/wallpapers/anime/the-urban-anime-girl-xk.jpg -m fill &

# Status bar
waybar -c ~/.config/waybar/mango.jsonc &

# Night light / color temperature adjustment
wlsunset -T 6500 -t 4000 -l 35.7796 -L -78.6382 &

# Clipboard manager daemon
copyq &

# Audio stack (started here because lemurs bypasses the systemd user session that would socket-activate PipeWire)
pipewire &
pipewire-pulse &
wireplumber &

# SSH agent, bound to a fixed socket so rofi/waypipe launchers can find it
# (lemurs bypasses the systemd/PAM integration that would normally auto-launch and unlock one;
# run `ssh-add ~/.ssh/ed25519` once per login to unlock it)
ssh-agent -a "$XDG_RUNTIME_DIR/ssh-agent.sock" -D &

# XWayland support for X11-only applications (e.g. Synology Drive)
xwayland-satellite &

# Idle management and lock screen (started here because lemurs bypasses the systemd graphical-session target)
hypridle &

# Desktop notifications
mako &

# System tray / autostart apps (started here because lemurs bypasses xdg-desktop-autostart.target)
remmina -i &
synology-drive autostart &
discord --start-minimized &
teams-for-linux --minimized --ozone-platform=wayland &
