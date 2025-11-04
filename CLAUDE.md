# Claude Code Context for Dotfiles Repository

## Repository Overview

This is a personal dotfiles repository containing configuration files for a Linux system (Fedora 42). The repository uses Git for version control and tracks window manager configurations, system settings, and shell configurations.

## Window Managers in Use

This system uses multiple Wayland compositors:

- **Niri** - Primary tiling compositor with scrollable workspaces
- **Hyprland** - Dynamic tiling compositor with animations
- **Sway** - i3-compatible tiling compositor

### Key Configuration Locations

- Niri: [.config/niri/config.kdl](.config/niri/config.kdl)
- Hyprland: [.config/hypr/hyprland.conf](.config/hypr/hyprland.conf)
- Sway: [.config/sway/config](.config/sway/config)

## Important Context and Patterns

### Niri-Specific Details

1. **App ID Case Sensitivity**: Window rules in Niri use regex patterns that are case-sensitive. Always verify the actual App ID using:
   ```bash
   niri msg windows
   ```
   Example: VS Code reports as "Code" (capital C), not "code".

2. **Reloading Configuration**: After editing Niri config, reload with:
   ```bash
   niri msg action load-config-file
   ```

3. **Window Rules**: Located at the bottom of config.kdl, use KDL syntax:
   ```kdl
   window-rule {
       match app-id=r#"^AppID$"#
       default-column-width { proportion 1.0; }
   }
   ```

### Display Setup

- Dual monitor configuration
- Using CapsLock as an additional Super/Mod key (configured via xkb options: `caps:super`)

### Common Components

- **Terminal**: Alacritty
- **Launcher**: rofi
- **Bar**: waybar
- **Screen Lock**: hyprlock (works across all WMs)
- **Idle Management**: hypridle (compositor-agnostic, enabled as systemd user service)
- **Clipboard**: copyq
- **File Manager**: thunar
- **Wallpaper**: swaybg
- **Color Temperature**: wlsunset
- **Greeter**: greetd with gtkgreet

### Idle and Lock Management

- **hypridle** is configured to work across all three window managers (Hyprland, Niri, Sway)
- Config location: [.config/hypr/hypridle.conf](.config/hypr/hypridle.conf)
- Uses compositor-agnostic commands that auto-detect the running WM
- Enabled as a systemd user service: `systemctl --user status hypridle`
- Timeouts: Lock after 5 minutes idle, monitor off after 10 minutes
- **Known behavior**: When running in Niri (not Hyprland), hypridle logs warnings about missing `hyprland-lock-notify-v1` protocol and `org.freedesktop.ScreenSaver` interface conflicts. These are non-fatal - the core idle detection and timeouts still work correctly.
- Uses `loginctl lock-session` which triggers hyprlock regardless of compositor

## Task Management Approach

The repository includes [dotfiles.todo.md](dotfiles.todo.md) to track pending configuration issues and improvements. This file serves as a working checklist:

- Items are added when issues are identified
- Items are **removed entirely** when fixed (not marked as complete)
- The file exists to prevent forgetting tasks, not as a permanent record

## Git Workflow

- Main branch: `main`
- Commit style: Descriptive messages focusing on the "why" rather than the "what"
- Include context about the specific window manager or component being modified
- Example: "Niri: Fix VS Code window rule to use correct App ID case"

## Common Tasks

### Debugging Window Rules

1. Check actual App ID: `niri msg windows`
2. Verify regex pattern matches (case-sensitive!)
3. Reload config after changes
4. Test with new window instances

### Configuration Changes

Most tasks involve config-only changes captured by git. Changes typically require:
- Reloading the compositor config
- Sometimes a re-login for display manager changes
- Restarting services for idle/lock managers

## Notes for Future Sessions

- Always check App IDs before creating window rules
- Niri uses KDL format, Hyprland/Sway use different config syntaxes
- Focus-follows-mouse is enabled in Niri
- The system has three window managers configured, so check which one is being used
- Todo items should be removed when complete, not accumulated
