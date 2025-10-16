#!/bin/bash

# Exit on any error
set -e

echo -n "configuring SDDM login manager ... "

# Configure SDDM to use the custom theme (if available)
SDDM_CONFIG="/etc/sddm.conf"
if [ -f "$SDDM_CONFIG" ]; then
    # Ensure SDDM uses the custom theme
    if [ -d "/usr/share/sddm/themes/custom" ] && ! sudo grep -q "^Current=custom" "$SDDM_CONFIG"; then
        sudo sed -i 's|#Current=.*|Current=custom|; s|^Current=.*|Current=custom|' "$SDDM_CONFIG"
    fi
    
    # Ensure SDDM uses default Wayland mode (comment out any X11 override)
    if sudo grep -q "^DisplayServer=x11" "$SDDM_CONFIG"; then
        sudo sed -i 's|^DisplayServer=x11|# DisplayServer=wayland|' "$SDDM_CONFIG"
    fi
fi

echo "done"