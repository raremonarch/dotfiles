#!/bin/bash

# Sudo Configuration Management Script
# Configures sudo timeout and other sudo preferences
# Can be called with timeout value as parameter or uses _sudo_timeout from setup.conf

# Determine timeout value - use parameter if provided, otherwise use config
timeout_value="${1:-$_sudo_timeout}"

# Skip if no timeout value provided
if [ -z "$timeout_value" ]; then
    echo "No sudo timeout configuration provided"
    return 0
fi

echo "Configuring sudo timeout: $timeout_value minutes"

# Define paths
TEMPLATE_FILE="$HOME/system-configs/sudoers.d/user-timeout.template"
DOTFILES_CONFIG="$HOME/system-configs/sudoers.d/${USER}-timeout"
SYSTEM_CONFIG="/etc/sudoers.d/${USER}-timeout"

# Create sudoers config from template
echo -n "  generating configuration from template ... "
if [ -f "$TEMPLATE_FILE" ]; then
    # Use template and substitute variables
    sed -e "s/%USER%/${USER}/g" -e "s/%TIMEOUT%/${timeout_value}/g" "$TEMPLATE_FILE" > "$DOTFILES_CONFIG"
    echo "done"
else
    # Fallback: create directly
    echo "Defaults:${USER} timestamp_timeout=${timeout_value}" > "$DOTFILES_CONFIG"
    echo "done (no template, created directly)"
fi

# Install to system location
echo -n "  installing to system ... "
if sudo cp "$DOTFILES_CONFIG" "$SYSTEM_CONFIG" 2>/dev/null; then
    echo "done"
else
    echo "failed"
    return 1
fi

# Set correct permissions (sudoers files must be mode 440)
echo -n "  setting permissions ... "
if sudo chmod 440 "$SYSTEM_CONFIG" 2>/dev/null; then
    echo "done"
else
    echo "failed"
    return 1
fi

# Validate sudoers configuration
echo -n "  validating configuration ... "
if sudo visudo -c > /dev/null 2>&1; then
    echo "done"
else
    echo "failed - configuration is invalid!"
    echo "  removing invalid configuration..."
    sudo rm -f "$SYSTEM_CONFIG"
    rm -f "$DOTFILES_CONFIG"
    return 1
fi

# Clear current sudo timestamp to apply new settings
echo -n "  applying new timeout settings ... "
sudo -k 2>/dev/null
echo "done"

echo "  sudo timeout configured: $timeout_value minutes"
echo "  dotfiles config: $DOTFILES_CONFIG"
echo "  system config: $SYSTEM_CONFIG"