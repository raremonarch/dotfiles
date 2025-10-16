#!/bin/bash

# Editor Environment Configuration
# Sets the default EDITOR and VISUAL environment variables

EDITOR_CHOICE="${1:-$_editor}"

if [ -z "$EDITOR_CHOICE" ]; then
    echo "Error: No editor specified. Usage: $0 <editor>"
    exit 1
fi

# Verify the editor is available
if ! command -v "$EDITOR_CHOICE" >/dev/null 2>&1; then
    echo "Warning: Editor '$EDITOR_CHOICE' not found in PATH"
    echo "Proceeding anyway (it may be installed later)"
fi

echo "Setting default editor to '$EDITOR_CHOICE'..."

# Update systemd user environment file
EDITOR_ENV_FILE="$HOME/.config/environment.d/editor.conf"
echo -n "updating editor environment configuration ... "
if [ -f "$EDITOR_ENV_FILE" ]; then
    sed -i "s|^EDITOR=.*|EDITOR=$EDITOR_CHOICE|" "$EDITOR_ENV_FILE"
    sed -i "s|^VISUAL=.*|VISUAL=$EDITOR_CHOICE|" "$EDITOR_ENV_FILE"
    echo "done"
else
    echo "failed (editor environment file not found)"
fi

# Set for current session
export EDITOR="$EDITOR_CHOICE"
export VISUAL="$EDITOR_CHOICE"

# Set git default editor (useful even if rarely used)
echo -n "configuring git default editor ... "
if command -v git >/dev/null 2>&1; then
    git config --global core.editor "$EDITOR_CHOICE"
    echo "done"
else
    echo "skipped (git not available)"
fi

# Set systemd user environment for consistency
echo -n "setting systemd user environment ... "
if command -v systemctl >/dev/null 2>&1; then
    systemctl --user set-environment EDITOR="$EDITOR_CHOICE" 2>/dev/null || true
    systemctl --user set-environment VISUAL="$EDITOR_CHOICE" 2>/dev/null || true
    echo "done"
else
    echo "skipped (systemctl not available)"
fi

echo ""
echo "✅ Editor configuration completed!"
echo "   Default editor: $EDITOR_CHOICE"
echo "   Current \$EDITOR: $EDITOR"
echo ""
echo "Note: You may need to start a new shell session for changes to take full effect."