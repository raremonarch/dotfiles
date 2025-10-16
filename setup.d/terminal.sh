#!/bin/bash

# Exit on any error
set -e

# Get terminal preference from config or use first parameter
TERMINAL_APP="${1:-$_terminal}"

if [ -z "$TERMINAL_APP" ]; then
    echo "Error: No terminal application specified"
    exit 1
fi

echo -n "configuring $TERMINAL_APP as default terminal ... "

# Check if the terminal application is installed
if ! command -v "$TERMINAL_APP" >/dev/null 2>&1; then
    echo "$TERMINAL_APP not found, please install it first"
    exit 1
fi

# Set terminal as default system-wide
echo -n "setting system-wide terminal alternative ... "
if sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "/usr/bin/$TERMINAL_APP" 50 2>/dev/null; then
    sudo update-alternatives --set x-terminal-emulator "/usr/bin/$TERMINAL_APP"
    echo "done"
else
    echo "failed (update-alternatives not available or failed)"
fi

# Configure XFCE4 helpers if the config exists
XFCE_HELPERS="$HOME/.config/xfce4/helpers.rc"
if [ -f "$XFCE_HELPERS" ]; then
    echo -n "configuring XFCE4 terminal helper ... "
    if grep -q "^TerminalEmulator=" "$XFCE_HELPERS"; then
        sed -i "s|^TerminalEmulator=.*|TerminalEmulator=/usr/bin/$TERMINAL_APP|" "$XFCE_HELPERS"
    else
        echo "TerminalEmulator=/usr/bin/$TERMINAL_APP" >> "$XFCE_HELPERS"
    fi
    echo "done"
fi

echo "$TERMINAL_APP configured as default terminal"