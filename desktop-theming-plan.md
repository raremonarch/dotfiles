# Desktop Theming Plan - Catppuccin Macchiato

Goal: Create a consistent Catppuccin Macchiato theme across all desktop components.

## Current Status

### ✅ Already Themed

- **Alacritty (Terminal)**: Using Catppuccin Macchiato theme
- **Hyprlock (Screen Locker)**: Using Catppuccin Frappé colors (could update to Macchiato for consistency)
- **GTK Apps (Thunar, etc.)**: Now using Adwaita-dark (functional dark mode)

### ❌ Not Themed (Default/Basic Styling)

- **Waybar (Status Bar)**: Basic black/white theme, highly visible, HIGH IMPACT
- **Mako (Notifications)**: No config file, using defaults, HIGH IMPACT
- **Rofi (App Launcher)**: No config file, using defaults, HIGH IMPACT
- **Niri Focus Ring**: Custom green-to-blue gradient, not Catppuccin, MEDIUM IMPACT
- **Niri Window Borders**: Currently disabled, could enable with Catppuccin colors, MEDIUM IMPACT
- **GTK Theme**: Using Adwaita-dark (works but not Catppuccin), MEDIUM IMPACT
- **Cursor Theme**: Using breeze_cursors (works but not Catppuccin), LOW IMPACT

## Components Breakdown

### 1. Waybar (Status Bar) - HIGH IMPACT

**Why**: Visible 100% of the time at top of screen
**Current**: Basic black background, white text
**Files**:

- `~/.config/waybar/style.css` (styling)
- `~/.config/waybar/config.jsonc` (configuration)
**What to theme**: Background, text colors, module backgrounds, accent colors
**Reload**: `pkill -SIGUSR2 waybar`

### 2. Mako (Notification Daemon) - HIGH IMPACT

**Why**: Appears frequently, currently completely unstyled
**Current**: Default theme (no config)
**Files**:

- `~/.config/mako/config` (doesn't exist yet, needs to be created)
**What to theme**: Background, text, border colors, urgency levels
**Reload**: `makoctl reload`

### 3. Rofi (Application Launcher) - HIGH IMPACT

**Why**: Used every time you launch apps (Mod+R)
**Current**: No configuration, using defaults
**Files**:

- `~/.config/rofi/config.rasi` (doesn't exist yet)
**What to theme**: Window background, text, selection colors, borders
**Note**: Pre-made Catppuccin rofi themes are available
**Reload**: Automatic on next launch

### 4. Niri Focus Ring & Borders - MEDIUM IMPACT

**Why**: Visual indicator for active window
**Current**: Green-to-blue gradient (lines 198-204 in config)
**Files**:

- `~/.config/niri/config.kdl` (lines 170-226 for focus-ring and border)
**What to theme**: Focus ring colors/gradient, optional window borders
**Reload**: `niri msg action reload-config` (doesn't restart apps, safe to use)

### 5. GTK Theme - MEDIUM IMPACT

**Why**: Affects file manager, settings apps, and login screen (gtkgreet)
**Current**: Adwaita-dark (functional but not Catppuccin)
**Option 1**: Install Catppuccin GTK theme
**Option 2**: Keep Adwaita-dark (it works and looks fine)
**Files**:

- `~/.config/gtk-3.0/settings.ini`
- gsettings via `gsettings set org.gnome.desktop.interface gtk-theme`
**Reload**: Restart GTK apps

### 6. Hyprlock - ALREADY THEMED (but inconsistent)

**Current**: Using Catppuccin Frappé colors
**Consideration**: Update to Macchiato to match terminal
**Files**: `~/.config/hypr/hyprlock.conf`

### 7. Cursor Theme - LOW IMPACT

**Current**: breeze_cursors
**Option**: Install Catppuccin cursor theme
**Files**:

- `~/.config/niri/config.kdl` (line 80)
- `~/.config/gtk-3.0/settings.ini`

## Catppuccin Macchiato Color Palette

```plaintext
Base (background):  #24273a
Mantle (darker):    #1e2030
Crust (darkest):    #181926
Text:               #cad3f5
Subtext1:           #b8c0e0
Subtext0:           #a5adcb
Overlay2:           #939ab7
Overlay1:           #8087a2
Overlay0:           #6e738d
Surface2:           #5b6078
Surface1:           #494d64
Surface0:           #363a4f

# Catppuccin - Macchiato
Lavender:           #b7bdf8
Blue:               #8aadf4
Sapphire:           #7dc4e4
Sky:                #91d7e3
Teal:               #8bd5ca
Green:              #a6da95
Yellow:             #eed49f
Peach:              #f5a97f
Maroon:             #ee99a0
Red:                #ed8796
Mauve:              #c6a0f6
Pink:               #f5bde6
Flamingo:           #f0c6c6
Rosewater:          #f4dbd6
```

## Recommended Order of Attack

1. **Waybar** - Most visible, biggest impact
2. **Mako** - Notifications appear frequently
3. **Rofi** - Used constantly for launching apps
4. **Niri focus ring** - Quick config change, nice visual improvement
5. **GTK theme** - Optional, Adwaita-dark is fine for now
6. **Hyprlock** - Update to Macchiato for consistency
7. **Cursor** - Lowest priority, current one works fine

## Notes

- All theming is config-file based, no system changes needed
- Changes are easily reversible via git
- Most components reload without restarting the session
- Focus on consistency: pick ONE Catppuccin variant (Macchiato) and use it everywhere
