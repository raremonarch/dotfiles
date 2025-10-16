#!/bin/bash

# Cursor theme setup script
# Sets up Breeze cursor theme for Sway/Wayland

CURSOR_THEME="${1:-breeze_cursors}"
CURSOR_SIZE="${2:-24}"

# Check if cursor theme exists, if not try to install it
if [ ! -d "/usr/share/icons/$CURSOR_THEME" ] && [ ! -d "$HOME/.local/share/icons/$CURSOR_THEME" ]; then
    echo "Cursor theme '$CURSOR_THEME' not found, attempting to install..."
    
    # Install breeze cursor theme package
    echo -n "installing breeze cursor theme ... "
    if sudo dnf install -y breeze-cursor-theme 2>/dev/null; then
        echo "installed successfully"
    else
        echo "failed to install via dnf"
        echo "Available cursor themes in /usr/share/icons/:"
        ls /usr/share/icons/ | grep -i cursor || echo "No cursor themes found"
        exit 1
    fi
    
    # Verify installation worked
    if [ ! -d "/usr/share/icons/$CURSOR_THEME" ] && [ ! -d "$HOME/.local/share/icons/$CURSOR_THEME" ]; then
        echo "ERROR: Cursor theme '$CURSOR_THEME' still not found after installation attempt"
        exit 1
    fi
fi

# Set cursor theme using gsettings
echo -n "setting cursor theme via gsettings ... "
if gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME" 2>/dev/null; then
    echo "done"
else
    echo "failed (gsettings not available)"
fi

echo -n "setting cursor size via gsettings ... "
if gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE" 2>/dev/null; then
    echo "done"
else
    echo "failed (gsettings not available)"
fi

# Set environment variables for Electron/Chrome-based apps like VS Code
echo -n "configuring cursor environment variables ... "

# Add to .profile for session-wide environment variables (better than .bashrc)
PROFILE_FILE="$HOME/.profile"

# Remove any existing cursor environment variables from both .profile and .bashrc
for file in "$HOME/.profile" "$HOME/.bashrc"; do
    if [ -f "$file" ]; then
        sed -i '/^export XCURSOR_THEME=/d' "$file"
        sed -i '/^export XCURSOR_SIZE=/d' "$file"
    fi
done

# Add to .profile (sourced by display managers and session managers)
echo "export XCURSOR_THEME=$CURSOR_THEME" >> "$PROFILE_FILE"
echo "export XCURSOR_SIZE=$CURSOR_SIZE" >> "$PROFILE_FILE"

# Create systemd user environment file for better integration
SYSTEMD_ENV_DIR="$HOME/.config/environment.d"
mkdir -p "$SYSTEMD_ENV_DIR"
cat > "$SYSTEMD_ENV_DIR/cursor.conf" << EOF
XCURSOR_THEME=$CURSOR_THEME
XCURSOR_SIZE=$CURSOR_SIZE
EOF

# Set for current session
export XCURSOR_THEME="$CURSOR_THEME"
export XCURSOR_SIZE="$CURSOR_SIZE"

echo "done"

# Update GTK settings file for additional compatibility
GTK3_SETTINGS="$HOME/.config/gtk-3.0/settings.ini"
if [ ! -d "$(dirname "$GTK3_SETTINGS")" ]; then
    mkdir -p "$(dirname "$GTK3_SETTINGS")"
fi

echo -n "updating GTK3 cursor settings ... "
if [ -f "$GTK3_SETTINGS" ]; then
    # Update existing file
    sed -i '/^gtk-cursor-theme-name=/d' "$GTK3_SETTINGS"
    sed -i '/^gtk-cursor-theme-size=/d' "$GTK3_SETTINGS"
    echo "gtk-cursor-theme-name=$CURSOR_THEME" >> "$GTK3_SETTINGS"
    echo "gtk-cursor-theme-size=$CURSOR_SIZE" >> "$GTK3_SETTINGS"
else
    # Create new file
    cat > "$GTK3_SETTINGS" << EOF
[Settings]
gtk-cursor-theme-name=$CURSOR_THEME
gtk-cursor-theme-size=$CURSOR_SIZE
EOF
fi
echo "done"

# Configure for Sway if config exists
SWAY_CONFIG="$HOME/.config/sway/config"
if [ -f "$SWAY_CONFIG" ]; then
    echo -n "configuring cursor for Sway ... "
    
    # Remove any existing cursor configuration
    sed -i '/^seat \* xcursor_theme/d' "$SWAY_CONFIG"
    
    # Find the line after the closing brace of the set block and add cursor config
    if grep -q "^}" "$SWAY_CONFIG"; then
        # Insert cursor configuration after the first closing brace
        sed -i '0,/^}$/s/^}$/&\n\n# Cursor configuration\nseat * xcursor_theme '"$CURSOR_THEME"' '"$CURSOR_SIZE"'/' "$SWAY_CONFIG"
        echo "added to Sway config"
        
        # Reload Sway configuration if we're in a Sway session
        if [ "$XDG_CURRENT_DESKTOP" = "sway" ]; then
            echo -n "reloading Sway configuration ... "
            if swaymsg reload 2>/dev/null; then
                echo "done"
            else
                echo "failed (not in Sway session)"
            fi
        fi
    else
        echo "failed (could not find insertion point in Sway config)"
    fi
else
    echo "Sway config not found, skipping Sway configuration"
fi

# Verify configuration
echo -n "verifying cursor configuration ... "
CURRENT_THEME=$(gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null | tr -d "'")
CURRENT_SIZE=$(gsettings get org.gnome.desktop.interface cursor-size 2>/dev/null)

if [ "$CURRENT_THEME" = "$CURSOR_THEME" ] && [ "$CURRENT_SIZE" = "$CURSOR_SIZE" ]; then
    echo "cursor theme '$CURSOR_THEME' (size $CURSOR_SIZE) configured successfully"
else
    echo "verification failed, but configuration may still work"
fi

echo ""
echo "Notes for cursor theme changes:"
echo "  - Most applications will use the new cursor theme immediately"
echo "  - VS Code and other Electron apps may need to be restarted"
echo "  - If VS Code still shows old cursor, try: code --no-sandbox"
echo "  - Environment variables are set in ~/.profile and ~/.config/environment.d/"