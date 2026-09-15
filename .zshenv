# uv
export PATH="/home/david/.local/bin:$PATH"

if [ -e /home/david/.nix-profile/etc/profile.d/nix.sh ]; then . /home/david/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# Fixed ssh-agent socket started by the compositor (niri/hyprland/sway/mango autostart)
# .zshenv (not .zprofile) so it's set in every shell, not just login shells
# (Alacritty execs zsh non-login, so .zprofile never ran here)
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.sock"
