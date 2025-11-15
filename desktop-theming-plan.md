# Desktop Theming Plan - Neon Flow

Goal: Create a consistent "Neon Flow" custom theme across all desktop components.

## Theme Philosophy

**Neon Flow** is a custom theme built around vibrant lime-cyan gradient (#c7ff7f → #80c8ff) with:

- High contrast, vibrant accent colors
- Dark blue-gray backgrounds for comfort
- Energetic, modern aesthetic
- More saturated than Catppuccin, less extreme than pure cyberpunk

Full palette documented in [custom-theme-palette.md](custom-theme-palette.md)

## Current Status

### ✅ Already Themed (Neon Flow)

- **Mako (Notifications)**: Custom Neon Flow theme with electric blue borders
- **Rofi (App Launcher)**: Custom theme with lime selection and cyan accents
- **Niri Focus Ring**: Lime-to-cyan gradient (the theme's signature!)
- **GTK Apps (Thunar, etc.)**: Using Adwaita-dark (functional dark mode)

### ❌ Not Themed (Default/Basic Styling)

- **Waybar (Status Bar)**: Basic black/white theme, highly visible, HIGH IMPACT
- **Alacritty (Terminal)**: Still using Catppuccin Macchiato (inconsistent), MEDIUM IMPACT
- **Hyprlock (Screen Locker)**: Using Catppuccin Frappé colors (inconsistent), MEDIUM IMPACT
- **Niri Window Borders**: Currently disabled, could enable with Neon Flow colors, MEDIUM IMPACT
- **GTK Theme**: Using Adwaita-dark (works but not Neon Flow), LOW IMPACT
- **Cursor Theme**: Using breeze_cursors (works but not themed), LOW IMPACT

## Components Breakdown

### 1. Waybar (Status Bar) - HIGH IMPACT

**Why**: Visible 100% of the time at top of screen
**Current**: Basic black background, white text
**Files**:

- `~/.config/waybar/style.css` (styling)
- `~/.config/waybar/config.jsonc` (configuration)
**What to theme**: Background, text colors, module backgrounds, accent colors
**Reload**: `pkill -SIGUSR2 waybar`

### 2. Mako (Notification Daemon) - ✅ THEMED

**Why**: Appears frequently for system notifications
**Current**: Neon Flow theme with electric blue borders
**Files**:

- `~/.config/mako/config` (themed with Neon Flow colors)
**What to theme**: Already themed - dark background (#161b22), bright text, electric blue borders (#58a6ff), red critical alerts
**Reload**: `makoctl reload`

### 3. Rofi (Application Launcher) - ✅ THEMED

**Why**: Used every time you launch apps (Mod+R)
**Current**: Neon Flow theme with lime selection highlights
**Files**:

- `~/.config/rofi/config.rasi` (themed with Neon Flow)
- `~/.config/rofi/neon-flow.rasi` (color palette)
**What to theme**: Already themed - dark background, bright text, vibrant lime (#c7ff7f) selection, cyan borders
**Reload**: Automatic on next launch

### 4. Niri Focus Ring & Borders - ✅ THEMED

**Why**: Visual indicator for active window - THE SIGNATURE ELEMENT!
**Current**: Lime-to-cyan gradient (#c7ff7f → #80c8ff) - this is the theme's foundation!
**Files**:

- `~/.config/niri/config.kdl` (lines 170-226 for focus-ring and border)
**What to theme**: Already themed - the iconic gradient that defines Neon Flow
**Reload**: `niri msg action reload-config` (doesn't restart apps, safe to use)

### 5. GTK Theme - LOW IMPACT

**Why**: Affects file manager, settings apps, and login screen (gtkgreet)
**Current**: Adwaita-dark (functional, good enough)
**Consideration**: Could create custom GTK theme with Neon Flow colors, but low priority
**Files**:

- `~/.config/gtk-3.0/settings.ini`
- gsettings via `gsettings set org.gnome.desktop.interface gtk-theme`
**Reload**: Restart GTK apps

### 6. Alacritty (Terminal) - MEDIUM IMPACT

**Why**: Used frequently for development and system tasks
**Current**: Using Catppuccin Macchiato (inconsistent with Neon Flow)
**Consideration**: Update to Neon Flow for consistency
**Files**: `~/.config/alacritty/alacritty.toml` and color scheme file
**Reload**: Automatic on config save

### 7. Hyprlock (Screen Locker) - MEDIUM IMPACT

**Why**: Seen every time screen locks
**Current**: Using Catppuccin Frappé colors (inconsistent with Neon Flow)
**Consideration**: Update to Neon Flow for consistency
**Files**: `~/.config/hypr/hyprlock.conf`
**Reload**: Automatic on next lock

### 8. Cursor Theme - LOW IMPACT

**Current**: breeze_cursors (works fine)
**Consideration**: Could look for vibrant cursor theme, but low priority
**Files**:

- `~/.config/niri/config.kdl` (line 80)
- `~/.config/gtk-3.0/settings.ini`

## Neon Flow Color Palette

For complete color palette documentation, see [custom-theme-palette.md](custom-theme-palette.md)

**Quick Reference:**

```plaintext
# Base Colors (Backgrounds & Neutrals)
Darkest:            #0d1117  (very dark blue-gray)
Dark:               #161b22  (dark blue-gray)
Medium Dark:        #21262d  (medium dark blue-gray)
Surface:            #30363d  (lighter surface)
Border:             #484f58  (subtle borders)
Muted:              #6e7681  (muted text/icons)

# Text Colors
Text Primary:       #e6edf3  (bright white-blue)
Text Secondary:     #7d8590  (dimmed text)
Text Muted:         #484f58  (very subtle text)

# Core Accent Gradient (Theme Signature!)
Lime Green:         #c7ff7f  (vibrant lime)
Cyan:               #80c8ff  (bright cyan)

# Extended Accent Colors
Electric Blue:      #58a6ff  (vibrant blue - links, info)
Bright Green:       #7ee787  (success, positive)
Neon Yellow:        #f0e68c  (warnings, highlights)
Vibrant Orange:     #ff9f68  (moderate warnings)
Hot Pink:           #ff6ec7  (magenta, special)
Bright Red:         #ff7b72  (errors, critical)
Purple:             #bc8cff  (special states)
Teal:               #56d4dd  (alternative accent)
```

## Recommended Order of Attack

**Already completed:**

1. ✅ **Niri focus ring** - The signature gradient that started it all!
2. ✅ **Mako** - Notifications themed with electric blue borders
3. ✅ **Rofi** - App launcher themed with lime selection highlights

**Next steps for full Neon Flow theme:**
4. **Waybar** - Most visible, biggest impact (user previously tried but reverted)
5. **Alacritty** - Update from Catppuccin Macchiato for consistency
6. **Hyprlock** - Update from Catppuccin Frappé for consistency
7. **GTK theme** - Optional, Adwaita-dark is fine for now
8. **Cursor** - Lowest priority, current one works fine

## Notes

- All theming is config-file based, no system changes needed
- Changes are easily reversible via git
- Most components reload without restarting the session
- **Theme philosophy**: Vibrant, energetic, high-contrast - more saturated than Catppuccin, less extreme than pure cyberpunk
- The lime-cyan gradient (#c7ff7f → #80c8ff) is the theme's signature element
