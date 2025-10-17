#!/bin/bash

# Check if wallpaper path is provided as first parameter
if [ -z "$1" ]; then
    echo "Error: No wallpaper path provided. Usage: $0 <wallpaper_path_or_name>"
    exit 1
fi

_wallpaper_input="$1"

# Function to resolve wallpaper name to URL from definitions
resolve_wallpaper_name() {
    local name="$1"
    for definition in "${_wallpaper_definitions[@]}"; do
        if [[ "$definition" == "$name:"* ]]; then
            echo "${definition#*:}"
            return 0
        fi
    done
    return 1
}

# Function to download wallpaper from URL
download_wallpaper() {
    local url="$1"
    local name="$2"
    
    # Extract file extension from URL (remove query parameters first)
    local url_without_params="${url%%\?*}"
    local extension="${url_without_params##*.}"
    # If no extension found, extension contains path separators, or extension is too long, default to jpg
    if [ -z "$extension" ] || [[ "$extension" == */* ]] || [ "${#extension}" -gt 4 ]; then
        extension="jpg"
    fi
    
    local output_file="$HOME/wallpaper.$extension"
    
    echo -n "downloading wallpaper '$name' from URL ... "
    if command -v curl >/dev/null 2>&1; then
        if curl -fsSL "$url" -o "$output_file" 2>/dev/null; then
            echo "done"
            # Return the output file path via stdout (last line)
            echo "$output_file"
            return 0
        else
            echo "failed (curl error)"
            return 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget -q "$url" -O "$output_file" 2>/dev/null; then
            echo "done"
            # Return the output file path via stdout (last line)
            echo "$output_file"
            return 0
        else
            echo "failed (wget error)"
            return 1
        fi
    else
        echo "failed (no curl or wget available)"
        return 1
    fi
}

# Resolve wallpaper input to actual file path
if [[ "$_wallpaper_input" == *"/"* ]] && [ -f "$_wallpaper_input" ]; then
    # It's a file path that exists
    _wallpaper_path="$_wallpaper_input"
elif [ -f "$_wallpaper_input" ]; then
    # It's a file in current directory
    _wallpaper_path="$_wallpaper_input"
else
    # Try to resolve as predefined wallpaper name
    wallpaper_url=$(resolve_wallpaper_name "$_wallpaper_input")
    if [ $? -eq 0 ] && [ -n "$wallpaper_url" ]; then
        echo "resolved '$_wallpaper_input' as predefined wallpaper"
        # Download wallpaper - the function will print progress and return the file path
        download_output=$(download_wallpaper "$wallpaper_url" "$_wallpaper_input")
        download_exit_code=$?
        if [ $download_exit_code -eq 0 ]; then
            # Extract the file path from the last line of output
            _wallpaper_path=$(echo "$download_output" | tail -1)
            if [ -f "$_wallpaper_path" ]; then
                echo "downloaded to: $_wallpaper_path"
            else
                echo "ERROR: Download succeeded but file not found: $_wallpaper_path"
                exit 1
            fi
        else
            echo "ERROR: Failed to download wallpaper"
            exit 1
        fi
    else
        echo "ERROR: '$_wallpaper_input' is not a valid file path or predefined wallpaper name"
        echo ""
        echo "Available predefined wallpapers:"
        for definition in "${_wallpaper_definitions[@]}"; do
            local name="${definition%%:*}"
            echo "  - $name"
        done
        exit 1
    fi
fi

# Final check if wallpaper file exists
if [ ! -f "$_wallpaper_path" ]; then
    echo "ERROR: wallpaper file '$_wallpaper_path' not found"
    exit 1
fi

_wallpaper_name=$(basename "$_wallpaper_path")
_wallpaper_dir=$(dirname "$_wallpaper_path")
_wallpaper_base="${_wallpaper_name%.*}"
_wallpaper_ext="${_wallpaper_name##*.}"

# Source the configuration to get wallpaper targets and definitions
# Try multiple paths to find setup.conf
if [ -f "$HOME/setup.conf" ]; then
    source "$HOME/setup.conf"
elif [ -f "$(dirname "$(dirname "$0")")/setup.conf" ]; then
    source "$(dirname "$(dirname "$0")")/setup.conf"
else
    echo "ERROR: Could not find setup.conf - required for wallpaper definitions"
    echo "Please ensure setup.conf exists in your home directory"
    exit 1
fi

# Verify required variables are loaded
if [ -z "${_wallpaper_targets[*]}" ]; then
    echo "WARNING: _wallpaper_targets not found in setup.conf, using defaults"
    _wallpaper_targets=("desktop" "lock" "login")
fi

if [ -z "${_wallpaper_definitions[*]}" ]; then
    echo "WARNING: _wallpaper_definitions not found in setup.conf"
    echo "Predefined wallpaper names will not work"
    _wallpaper_definitions=()
fi

echo "Wallpaper targets: ${_wallpaper_targets[*]}"

# Check if ImageMagick is available for dimension detection
if ! command -v magick >/dev/null 2>&1; then
    echo "WARNING: ImageMagick (magick command) not found. Cannot detect image dimensions."
    echo "Install with: sudo dnf install ImageMagick"
    _is_dual_monitor=false
else
    # Get image dimensions using ImageMagick
    echo -n "detecting image dimensions ... "
    _dimensions=$(magick identify -format "%wx%h" "$_wallpaper_path")
    _exit_code=$?
    
    if [ $_exit_code -eq 0 ] && [ -n "$_dimensions" ]; then
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
if sudo cp "$_wallpaper_path" "$_system_wallpaper"; then
    echo "done"
else
    echo "failed to copy wallpaper to system directory"
    exit 1
fi

# Handle dual monitor wallpaper splitting if needed for desktop target
if [ "$_is_dual_monitor" = true ] && [[ " ${_wallpaper_targets[*]} " == *" desktop "* ]]; then
    echo "Detected potential dual monitor wallpaper for Sway desktop"
    
    # Check if split versions need to be created/updated
    # Create if they don't exist OR if the main wallpaper is newer than the split versions
    if [ ! -f "$_system_split_0" ] || [ ! -f "$_system_split_1" ] || [ "$_system_wallpaper" -nt "$_system_split_0" ]; then
        echo "Creating/updating split wallpapers in system directory..."
        
        # Check if ImageMagick is available
        if ! command -v magick >/dev/null 2>&1; then
            echo "ERROR: ImageMagick (magick command) not found. Please install it: sudo dnf install ImageMagick"
            exit 1
        fi
        
        echo -n "splitting wallpaper into dual monitor versions ... "
        if sudo magick "$_system_wallpaper" -crop 50%x100% +repage +adjoin "${_system_wallpaper_dir}/${_wallpaper_base}-%d.${_wallpaper_ext}"; then
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
    SWAYLOCK_CONFIG="$HOME/.config/swaylock/config"
    SWAY_CONFIG="$HOME/.config/sway/config"
    
    if [ ! -f "$SWAYLOCK_CONFIG" ]; then
        echo "note: Swaylock config not found at $SWAYLOCK_CONFIG"
        return 1
    fi
    
    # Choose appropriate wallpaper for lock screen
    local lock_wallpaper
    if [ "$_is_dual_monitor" = true ]; then
        # Use first half of split image for lock screen (looks better than full-width stretched)
        lock_wallpaper="$_system_split_0"
    else
        lock_wallpaper="$_system_wallpaper"
    fi
    
    echo -n "updating swaylock wallpaper configuration ... "
    
    # Update only the image path in existing swaylock config
    sed -i "s|^image=.*|image=$lock_wallpaper|" "$SWAYLOCK_CONFIG"

    # Update Sway config to use simple swaylock commands (swaylock will read its own config)
    if [ -f "$SWAY_CONFIG" ]; then
        # Update swayidle configuration to use simple swaylock command
        sed -i "s|swaylock -f -i [^']*|swaylock -f|g" "$SWAY_CONFIG"
        sed -i "s|swaylock -f -c [^']*|swaylock -f|g" "$SWAY_CONFIG"
        
        # Update manual lock keybinding to use simple swaylock command
        sed -i "s|\$mod+l exec swaylock[^\"]*|\$mod+l exec swaylock -f|" "$SWAY_CONFIG"
    fi
    
    echo "done"
}

# Function to configure SDDM wallpaper
configure_sddm() {
    SDDM_THEME_CONFIG="/usr/share/sddm/themes/custom/theme.conf"
    if [ ! -f "$SDDM_THEME_CONFIG" ]; then
        echo "note: SDDM custom theme config not found at $SDDM_THEME_CONFIG"
        return 1
    fi
    
    # Choose appropriate wallpaper for login screen
    local login_wallpaper
    if [ "$_is_dual_monitor" = true ]; then
        # Use first half of split image for login screen (looks better than full-width stretched)
        login_wallpaper="$_system_split_0"
    else
        login_wallpaper="$_system_wallpaper"
    fi
    
    echo -n "updating SDDM theme wallpaper configuration ... "
    if sudo sed -i "s|^background=.*|background=$login_wallpaper|" "$SDDM_THEME_CONFIG"; then
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