#!/bin/bash

# Check if wallpaper path is provided as first parameter
if [ -z "$1" ]; then
    echo "Error: No wallpaper path provided. Usage: $0 <wallpaper_path>"
    exit 1
fi

_wallpaper="$1"

# Check if wallpaper file exists
if [ ! -f "$_wallpaper" ]; then
    echo "ERROR: wallpaper file '$_wallpaper' not found"
    exit 1
fi

_wallpaper_name=$(basename "$_wallpaper")
_wallpaper_base="${_wallpaper_name%.*}"
_wallpaper_ext="${_wallpaper_name##*.}"

# System wallpaper directory
_system_wallpaper_dir="/usr/share/backgrounds"
_system_wallpaper="$_system_wallpaper_dir/$_wallpaper_name"

# Determine if this is a dual monitor wallpaper
_is_dual_monitor=false

if command -v magick >/dev/null 2>&1; then
    echo -n "detecting image dimensions ... "
    _dimensions=$(magick identify -format "%wx%h" "$_wallpaper" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$_dimensions" ]; then
        _width=$(echo "$_dimensions" | cut -d'x' -f1)
        _height=$(echo "$_dimensions" | cut -d'x' -f2)
        echo "done (${_width}x${_height})"
        
        # Simple aspect ratio check: if width > 2.5 * height, it's likely dual monitor
        if [ $((_width * 10 / _height)) -gt 25 ]; then
            echo "detected ultra-wide aspect ratio - likely dual monitor wallpaper"
            _is_dual_monitor=true
        else
            echo "detected standard aspect ratio - single monitor wallpaper"
            _is_dual_monitor=false
        fi
    else
        echo "failed to detect dimensions, using filename heuristics"
        # Fallback: check filename for dual monitor keywords
        if [[ "$_wallpaper_name" == *"dual"* ]] || [[ "$_wallpaper_name" == *"monitor"* ]] || [[ "$_wallpaper_name" == *"wide"* ]]; then
            echo "detected dual monitor keywords in filename"
            _is_dual_monitor=true
        fi
    fi
else
    echo "WARNING: ImageMagick not available, using filename heuristics only"
    if [[ "$_wallpaper_name" == *"dual"* ]] || [[ "$_wallpaper_name" == *"monitor"* ]] || [[ "$_wallpaper_name" == *"wide"* ]]; then
        echo "detected dual monitor keywords in filename"
        _is_dual_monitor=true
    fi
fi

# Copy wallpaper to system directory
echo -n "copying wallpaper to system directory ... "
if sudo cp "$_wallpaper" "$_system_wallpaper" 2>/dev/null; then
    echo "done"
else
    echo "ERROR: failed to copy wallpaper to system directory"
    exit 1
fi

# Handle dual monitor wallpaper splitting
if [ "$_is_dual_monitor" = true ]; then
    echo "Processing dual monitor wallpaper"
    
    _system_split_0="$_system_wallpaper_dir/${_wallpaper_base}-0.${_wallpaper_ext}"
    _system_split_1="$_system_wallpaper_dir/${_wallpaper_base}-1.${_wallpaper_ext}"
    
    # Check if split wallpapers already exist
    if [ ! -f "$_system_split_0" ] || [ ! -f "$_system_split_1" ]; then
        echo "Split wallpapers not found, creating them..."
        echo -n "splitting wallpaper into dual monitor versions ... "
        if command -v magick >/dev/null 2>&1; then
            if sudo magick "$_system_wallpaper" -crop 50%x100% +repage +adjoin "${_system_wallpaper_dir}/${_wallpaper_base}-%d.${_wallpaper_ext}" 2>/dev/null; then
                echo "done"
            else
                echo "ERROR: failed to split wallpaper"
                exit 1
            fi
        else
            echo "ERROR: ImageMagick required for wallpaper splitting"
            exit 1
        fi
    else
        echo "Split wallpapers already exist, skipping creation"
    fi
    
    # Update Sway config for dual monitor setup
    _update_sway_dual_monitor
else
    echo "Processing single monitor wallpaper"
    # Update Sway config for single monitor setup
    _update_sway_single_monitor
fi

# Function to update Sway config for dual monitor wallpaper
_update_sway_dual_monitor() {
    local SWAY_CONFIG="$HOME/.config/sway/config"
    if [ ! -f "$SWAY_CONFIG" ]; then
        echo "Sway config not found, skipping Sway configuration"
        return
    fi
    
    echo -n "updating Sway output wallpaper configurations ... "
    
    # Update or add output configurations for dual monitor setup
    # This assumes common monitor names, but could be made more flexible
    sed -i '/^output.*bg.*$/d' "$SWAY_CONFIG"  # Remove existing wallpaper configs
    
    # Add new dual monitor wallpaper configurations
    cat >> "$SWAY_CONFIG" << EOF

# Dual monitor wallpaper configuration
output HDMI-A-1 pos 0 0 bg $_system_split_0 fill
output HDMI-A-2 pos 1920 0 bg $_system_split_1 fill
EOF
    
    echo "done"
}

# Function to update Sway config for single monitor wallpaper
_update_sway_single_monitor() {
    local SWAY_CONFIG="$HOME/.config/sway/config"
    if [ ! -f "$SWAY_CONFIG" ]; then
        echo "Sway config not found, skipping Sway configuration"
        return
    fi
    
    echo -n "updating Sway output configurations for single wallpaper ... "
    
    # Update existing output lines to use the same wallpaper on all monitors
    sed -i '/^output.*bg.*$/d' "$SWAY_CONFIG"  # Remove existing wallpaper configs
    
    # Add new single wallpaper configuration for common monitor setups
    cat >> "$SWAY_CONFIG" << EOF

# Single wallpaper configuration
output HDMI-A-1 pos 0 0 bg $_system_wallpaper fill
output HDMI-A-2 pos 1920 0 bg $_system_wallpaper fill
EOF
    
    echo "done"
}

# Reload Sway configuration
if [ "$XDG_CURRENT_DESKTOP" = "sway" ]; then
    echo -n "reloading Sway configuration ... "
    if swaymsg reload 2>/dev/null; then
        echo "done"
    else
        echo "failed (not in Sway session or swaymsg not available)"
    fi
fi

echo "wallpaper setup completed successfully"