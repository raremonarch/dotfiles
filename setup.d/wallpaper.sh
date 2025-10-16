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
_wallpaper_dir=$(dirname "$_wallpaper")
_wallpaper_base="${_wallpaper_name%.*}"
_wallpaper_ext="${_wallpaper_name##*.}"

# Source the configuration to get wallpaper targets
source "$(dirname "$(dirname "$0")")/setup.conf" 2>/dev/null || {
    echo "Warning: Could not load setup.conf, using default targets"
    _wallpaper_targets=("desktop" "lock" "login")
}

echo "Wallpaper targets: ${_wallpaper_targets[*]}"

# Check if ImageMagick is available for dimension detection
if ! command -v magick >/dev/null 2>&1; then
    echo "WARNING: ImageMagick (magick command) not found. Cannot detect image dimensions."
    echo "Install with: sudo dnf install ImageMagick"
    _is_dual_monitor=false
else
    # Get image dimensions using ImageMagick
    echo -n "detecting image dimensions ... "
    _dimensions=$(magick identify -format "%wx%h" "$_wallpaper" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$_dimensions" ]; then
        _width=$(echo "$_dimensions" | cut -d'x' -f1)
        _height=$(echo "$_dimensions" | cut -d'x' -f2)
        echo "done (${_width}x${_height})"
        
        # Calculate aspect ratio to determine if it's likely a dual monitor setup
        # Typical dual monitor setups: 3840x1080 (2x1920x1080), 2560x1024 (2x1280x1024), etc.
        # Look for aspect ratios wider than 2.5:1 (normal widescreen is ~1.78:1)
        if command -v bc >/dev/null 2>&1; then
            _aspect_ratio=$(echo "scale=2; $_width / $_height" | bc -l 2>/dev/null || echo "0")
            _aspect_check=$(echo "$_aspect_ratio > 2.5" | bc -l 2>/dev/null || echo "0")
        else
            # Fallback calculation without bc (less precise)
            _aspect_times_10=$((($_width * 10) / $_height))
            if [ $_aspect_times_10 -gt 25 ]; then
                _aspect_check="1"
                _aspect_ratio="$_aspect_times_10.0/10"
            else
                _aspect_check="0"
                _aspect_ratio="$_aspect_times_10.0/10"
            fi
        fi
        
        if [ "$_aspect_check" = "1" ]; then
            echo "detected ultra-wide aspect ratio ($_aspect_ratio:1) - likely dual monitor wallpaper"
            _is_dual_monitor=true
        else
            echo "detected standard aspect ratio ($_aspect_ratio:1) - single monitor wallpaper"
            _is_dual_monitor=false
        fi
    else
        echo "failed to detect dimensions"
        # Fallback to filename detection
        if [[ "$_wallpaper_name" == *"dual"* ]] || [[ "$_wallpaper_name" == *"monitor"* ]] || [[ "$_wallpaper_name" == *"wide"* ]]; then
            echo "fallback: detected dual monitor keywords in filename"
            _is_dual_monitor=true
        else
            _is_dual_monitor=false
        fi
    fi
fi

# Define system paths for the wallpapers
_system_wallpaper_dir="/usr/share/backgrounds"
_system_wallpaper="$_system_wallpaper_dir/$_wallpaper_name"
_system_split_0="$_system_wallpaper_dir/${_wallpaper_base}-0.${_wallpaper_ext}"
_system_split_1="$_system_wallpaper_dir/${_wallpaper_base}-1.${_wallpaper_ext}"

# Copy original wallpaper to system directory (needed for all targets)
echo -n "copying wallpaper to system directory ... "
if sudo cp "$_wallpaper" "$_system_wallpaper" 2>/dev/null; then
    echo "done"
else
    echo "failed to copy wallpaper to system directory"
    exit 1
fi

# Handle dual monitor wallpaper splitting if needed for desktop target
if [ "$_is_dual_monitor" = true ] && [[ " ${_wallpaper_targets[*]} " == *" desktop "* ]]; then
    echo "Detected potential dual monitor wallpaper for Sway desktop"
    
    # Check if split versions already exist in system directory
    if [ ! -f "$_system_split_0" ] || [ ! -f "$_system_split_1" ]; then
        echo "Split wallpapers not found in system directory, creating them..."
        
        # Check if ImageMagick is available
        if ! command -v magick >/dev/null 2>&1; then
            echo "ERROR: ImageMagick (magick command) not found. Please install it: sudo dnf install ImageMagick"
            exit 1
        fi
        
        echo -n "splitting wallpaper into dual monitor versions ... "
        if sudo magick "$_system_wallpaper" -crop 50%x100% +repage +adjoin "${_system_wallpaper_dir}/${_wallpaper_base}-%d.${_wallpaper_ext}" 2>/dev/null; then
            echo "done"
        else
            echo "failed to split wallpaper"
            exit 1
        fi
        
        # Verify split files were created
        if [ ! -f "$_system_split_0" ] || [ ! -f "$_system_split_1" ]; then
            echo "ERROR: Split wallpaper files not created properly"
            exit 1
        fi
    else
        echo "Split wallpapers already exist in system directory"
    fi
fi

# Function to configure Sway desktop wallpaper
configure_sway_desktop() {
    SWAY_CONFIG="$HOME/.config/sway/config"
    if [ ! -f "$SWAY_CONFIG" ]; then
        echo "note: Sway config not found at $SWAY_CONFIG"
        return 1
    fi
    
    if [ "$_is_dual_monitor" = true ]; then
        # Check for existing output lines with bg settings
        if grep -q "^output.*bg.*" "$SWAY_CONFIG"; then
            echo -n "updating Sway output wallpaper configurations (dual monitor) ... "
            
            # Update existing output lines to use the system split wallpapers
            sed -i "s|^output HDMI-A-1.*bg.*|output HDMI-A-1 pos    0 0 bg $_system_split_0 fill|" "$SWAY_CONFIG"
            sed -i "s|^output HDMI-A-2.*bg.*|output HDMI-A-2 pos 1920 0 bg $_system_split_1 fill|" "$SWAY_CONFIG"
            
            echo "done"
        else
            echo "No Sway output configurations found with wallpaper settings"
            echo "Dual monitor wallpapers created but not applied to Sway config"
        fi
    else
        # Single monitor wallpaper handling
        if grep -q "^output.*bg.*" "$SWAY_CONFIG"; then
            echo -n "updating Sway output configurations for single wallpaper ... "
            
            # Update existing output lines to use the same single wallpaper on both monitors
            sed -i "s|^output HDMI-A-1.*bg.*|output HDMI-A-1 pos    0 0 bg $_system_wallpaper fill|" "$SWAY_CONFIG"
            sed -i "s|^output HDMI-A-2.*bg.*|output HDMI-A-2 pos 1920 0 bg $_system_wallpaper fill|" "$SWAY_CONFIG"
            
            echo "done"
        fi
    fi
}

# Function to configure swaylock wallpaper
configure_swaylock() {
    SWAY_CONFIG="$HOME/.config/sway/config"
    if [ ! -f "$SWAY_CONFIG" ]; then
        echo "note: Sway config not found at $SWAY_CONFIG"
        return 1
    fi
    
    echo -n "updating swaylock wallpaper configuration ... "
    
    # Update swayidle configuration
    sed -i "s|swaylock -f -i [^']*|swaylock -f -i $_system_wallpaper|g" "$SWAY_CONFIG"
    sed -i "s|swaylock -f -c [^']*|swaylock -f -i $_system_wallpaper -s fill|g" "$SWAY_CONFIG"
    
    # Update manual lock keybinding
    sed -i "s|\$mod+l exec swaylock[^\"]*|\$mod+l exec swaylock -f -i $_system_wallpaper -s fill|" "$SWAY_CONFIG"
    
    echo "done"
}

# Function to configure SDDM wallpaper
configure_sddm() {
    SDDM_THEME_CONFIG="/usr/share/sddm/themes/custom/theme.conf"
    if [ ! -f "$SDDM_THEME_CONFIG" ]; then
        echo "note: SDDM custom theme config not found at $SDDM_THEME_CONFIG"
        return 1
    fi
    
    echo -n "updating SDDM theme wallpaper configuration ... "
    if sudo sed -i "s|^background=.*|background=$_system_wallpaper|" "$SDDM_THEME_CONFIG"; then
        echo "done"
    else
        echo "failed (insufficient permissions)"
        return 1
    fi
    
    # Ensure SDDM is configured to use the custom theme
    SDDM_CONFIG="/etc/sddm.conf"
    if [ -f "$SDDM_CONFIG" ] && ! sudo grep -q "^Current=custom" "$SDDM_CONFIG"; then
        echo -n "configuring SDDM to use custom theme ... "
        if sudo sed -i 's|#Current=.*|Current=custom|' "$SDDM_CONFIG"; then
            echo "done"
        else
            echo "failed (insufficient permissions)"
            return 1
        fi
    fi
}

# Apply wallpaper to specified targets
for target in "${_wallpaper_targets[@]}"; do
    case "$target" in
        "desktop")
            configure_sway_desktop
            ;;
        "lock")
            configure_swaylock
            ;;
        "login")
            configure_sddm
            ;;
        *)
            echo "Warning: Unknown wallpaper target '$target'"
            ;;
    esac
done

# Create default symlink for compatibility (only if not dual monitor or desktop not in targets)
if [ "$_is_dual_monitor" = false ] || [[ ! " ${_wallpaper_targets[*]} " == *" desktop "* ]]; then
    # Remove existing default wallpaper if it exists and is not our target
    if [ -f "/usr/share/backgrounds/default" ] && [ "$(readlink /usr/share/backgrounds/default)" != "$_system_wallpaper" ]; then
        sudo rm -f /usr/share/backgrounds/default
    fi
    
    # Create symlink to new wallpaper
    echo -n "setting as system default wallpaper ... "
    if sudo ln -sf "$_system_wallpaper" /usr/share/backgrounds/default; then
        echo "done"
    else
        echo "ERROR: failed to create wallpaper symlink"
    fi
fi

# Reload Sway configuration if any Sway-related targets were configured
if [[ " ${_wallpaper_targets[*]} " == *" desktop "* ]] || [[ " ${_wallpaper_targets[*]} " == *" lock "* ]]; then
    if [ "$XDG_CURRENT_DESKTOP" = "sway" ]; then
        echo -n "reloading Sway configuration ... "
        if swaymsg reload 2>/dev/null; then
            echo "done"
        else
            echo "failed (not in Sway session or swaymsg not available)"
        fi
    fi
fi