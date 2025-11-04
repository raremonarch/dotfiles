# Dotfiles TODO

## Window Manager & Display Issues

### 1. greetd login form split across dual monitors

- [ ] Locate gtkgreet configuration in [.config/gtkgreet/](.config/gtkgreet/)
- [ ] Configure gtkgreet to target specific monitor
- [ ] Test centering on primary display
- [ ] Alternative: Consider adjusting greeter position/geometry

### 2. Set CapsLock as Mod key (or switch from SUPER)

- [ ] For Hyprland: Update mod key binding in [.config/hypr/hyprland.conf](.config/hypr/hyprland.conf)
- [ ] For Niri: Update mod key in [.config/niri/config.kdl](.config/niri/config.kdl)
- [ ] For Sway: Update mod key in [.config/sway/config](.config/sway/config)
- [ ] Remap CapsLock to act as mod key at input level
- [ ] Consider using input configuration (xkb options or similar)
- [ ] Test all keybindings after change

## Notes

- Most changes should be config-only and captured by git
- Test each change thoroughly before moving to the next
- Some changes may require service restarts or re-login
