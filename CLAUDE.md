# Claude Code Context for Dotfiles Repository

## Repository Overview

This is a personal dotfiles repository containing configuration files for a Linux system (Arch Linux, rolling release). The repository uses Git for version control and tracks window manager configurations, system settings, and shell configurations.

## Window Managers in Use

David actually runs two of these day to day:

- **Niri** - Primary, daily-driver tiling compositor with scrollable workspaces
- **Mango** - dwm-like wlroots compositor (mangowm/mango) currently being trialed, selected at the login screen (lemurs) instead of Niri

Hyprland and Sway configs also exist in this repo but are **not actively run** as window managers — don't assume either is the active compositor. Several Hyprland-ecosystem tools (`hypridle`, `hyprlock`, `hyprctl`, `hyprpaper`) are used as standalone utilities regardless of which compositor is actually running, which is why Hyprland config/tooling shows up even though the Hyprland compositor itself isn't in use.

### Key Configuration Locations

- Niri: [.config/niri/config.kdl](.config/niri/config.kdl)
- Mango: [.config/mango/config.conf](.config/mango/config.conf), autostart in [.config/mango/autostart.sh](.config/mango/autostart.sh)
- Hyprland (not actively run): [.config/hypr/hyprland.conf](.config/hypr/hyprland.conf)
- Sway (not actively run): [.config/sway/config](.config/sway/config)

### Init System Note

This system does not run systemd as PID 1 (login is via **lemurs**, a non-PAM/non-systemd greeter). Services that would normally be socket-activated or systemd-managed (PipeWire, WirePlumber, ssh-agent, hypridle) are instead started directly from each compositor's autostart (`exec-once` in Hyprland/Niri, `autostart.sh` for Mango). `systemctl --user` is not available — to restart a user-level daemon like hypridle, kill the process and relaunch it directly (e.g. `pkill -x hypridle && hypridle &`).

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

- **hypridle** detects and supports Hyprland, Niri, Sway, or Mango at runtime, even though only Niri and Mango are actually used day to day (see Window Managers in Use above)
- Config location: [.config/hypr/hypridle.conf](.config/hypr/hypridle.conf)
- Uses compositor-agnostic commands that detect the *running* compositor via `pgrep -x <name>` (not `command -v <binary>` — with all WMs installed side by side, checking for an installed binary picks the wrong branch whenever that binary belongs to a WM that isn't actually running)
- DPMS (monitor on/off) command per compositor: Hyprland → `hyprctl dispatch dpms`, Niri → `niri msg action power-on/off-monitors`, Sway → `swaymsg "output * dpms on/off"`, Mango → `wlopm --on/--off "*"` (Mango has no built-in IPC for this; `wlopm` is a small standalone tool using the `zwlr_output_power_manager_v1` protocol, which Mango implements)
- Started directly from each compositor's autostart, not systemd (see Init System Note above) — restart with `pkill -x hypridle && hypridle &`
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
- Niri uses KDL format, Hyprland/Sway/Mango use different config syntaxes
- Focus-follows-mouse is enabled in Niri
- Four WM configs exist in this repo, but only Niri (daily driver) and Mango (being trialed) are actually run — check which one is active (e.g. `pgrep -x niri` / `pgrep -x mango`) rather than assuming from installed configs or binaries
- Todo items should be removed when complete, not accumulated
