# Custom Vibrant Theme - "Neon Flow"

Built around your existing Niri focus ring gradient: lime-green (#c7ff7f) to cyan-blue (#80c8ff)

## Core Philosophy
- High contrast, vibrant accent colors
- Dark backgrounds for comfort
- Energetic, modern aesthetic
- More saturated than Catppuccin, less extreme than pure cyberpunk

## Base Colors (Backgrounds & Neutrals)

```
Darkest (backgrounds):  #0d1117  (very dark blue-gray)
Dark:                   #161b22  (dark blue-gray)
Medium Dark:            #21262d  (medium dark blue-gray)
Surface:                #30363d  (lighter surface)
Border:                 #484f58  (subtle borders)
Muted:                  #6e7681  (muted text/icons)
```

## Text Colors

```
Text Primary:           #e6edf3  (bright white-blue)
Text Secondary:         #7d8590  (dimmed text)
Text Muted:             #484f58  (very subtle text)
```

## Accent Colors (Vibrant & Energetic)

### Your Core Gradient
```
Lime Green:             #c7ff7f  (your existing bright lime)
Cyan:                   #80c8ff  (your existing bright cyan)
```

### Extended Palette (matching the energy)
```
Electric Blue:          #58a6ff  (vibrant blue - links, info)
Bright Green:           #7ee787  (success, positive)
Neon Yellow:            #f0e68c  (warnings, highlights)
Vibrant Orange:         #ff9f68  (moderate warnings)
Hot Pink:               #ff6ec7  (magenta, special)
Bright Red:             #ff7b72  (errors, critical)
Purple:                 #bc8cff  (special states)
Teal:                   #56d4dd  (alternative accent)
```

## Semantic Color Assignments

### Status Colors
```
Success:                #7ee787  (bright green)
Warning:                #f0e68c  (neon yellow)
Error:                  #ff7b72  (bright red)
Info:                   #58a6ff  (electric blue)
```

### UI Element Colors
```
Focus/Active:           #80c8ff  (your cyan)
Hover:                  #c7ff7f  (your lime)
Selection Background:   #58a6ff  (electric blue)
Selection Text:         #0d1117  (dark background on selection)
Link:                   #58a6ff  (electric blue)
```

## Color Usage Guide

### Terminal Colors (ANSI)
```
Black:                  #0d1117
Red:                    #ff7b72
Green:                  #7ee787
Yellow:                 #f0e68c
Blue:                   #58a6ff
Magenta:                #ff6ec7
Cyan:                   #80c8ff
White:                  #e6edf3

Bright Black:           #484f58
Bright Red:             #ff9999
Bright Green:           #7ee787
Bright Yellow:          #f0e68c
Bright Blue:            #80c8ff
Bright Magenta:         #bc8cff
Bright Cyan:            #56d4dd
Bright White:           #ffffff
```

## Application-Specific Mappings

### Waybar
- Background: #161b22 (dark)
- Text: #e6edf3 (bright white-blue)
- Modules: Individual bright accent colors
- Border accent: #80c8ff (cyan)

### Mako Notifications
- Background: #161b22 (dark)
- Border normal: #58a6ff (electric blue)
- Border critical: #ff7b72 (bright red)
- Text: #e6edf3 (bright white-blue)

### Rofi
- Background: #0d1117 (darkest)
- Text: #e6edf3 (bright white-blue)
- Selection: #58a6ff (electric blue background)
- Active: #80c8ff (cyan)

### Niri Focus Ring
- Active gradient: #c7ff7f to #80c8ff (keep your existing!)
- Inactive: #484f58 to #6e7681 (subtle gray)

## Inspiration Sources
This palette draws from:
- GitHub Dark Dimmed theme (base colors)
- Your existing lime-cyan gradient (core accent)
- Cyberpunk aesthetics (vibrancy)
- Modern developer tools (Discord, VS Code Dark+)

## Comparison to Other Themes

**vs Catppuccin:**
- Much higher saturation
- More contrast
- Cooler color temperature
- More "tech" feel, less "cozy"

**vs Dracula:**
- Similar vibrancy
- Cooler tones (blue-cyan vs purple-pink)
- Darker base backgrounds

**vs Nord:**
- Much more vibrant accents
- Nord is very muted by comparison
- Similar cool color temperature
