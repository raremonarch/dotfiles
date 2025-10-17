#!/bin/bash

# YubiKey U2F Login Authentication Setup
# This module configures optional U2F/FIDO2 security key authentication for SDDM login

# Only run if this script is being sourced by the setup system
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    echo "This script should be sourced by the setup system, not run directly."
    echo "Use: ./setup.sh yubikey_login"
    exit 1
fi

# Check if yubikey login is enabled in preferences or override argument
override_arg="$1"

# Handle help requests or invalid arguments
if [ "$override_arg" = "help" ] || [ "$override_arg" = "--help" ] || [ "$override_arg" = "-h" ]; then
    echo "YubiKey U2F Login Authentication Setup"
    echo ""
    echo "USAGE:"
    echo "  ./setup.sh yubikey_login                    # Use preference setting from setup.conf"
    echo "  ./setup.sh yubikey_login true               # Force enable U2F authentication"
    echo "  ./setup.sh yubikey_login false              # Force disable U2F authentication"
    echo "  ./setup.sh yubikey_login help               # Show this help"
    echo ""
    echo "DESCRIPTION:"
    echo "  Configures optional U2F/FIDO2 security key authentication for SDDM login."
    echo "  U2F authentication is SUFFICIENT (optional) - password login still works."
    echo ""
    echo "CONFIGURATION:"
    echo "  Set _yubikey_login=true/false in setup.conf to enable/disable by default"
    echo ""
    echo "EXAMPLES:"
    echo "  ./setup.sh yubikey_login true               # Enable and register security key"
    echo "  ./setup.sh yubikey_login false              # Disable U2F authentication"
    echo ""
    return 0
fi

if [ "$override_arg" = "false" ]; then
    echo "> disabling PAM U2F authentication..."
    
    # Backup and restore original SDDM PAM config
    SDDM_PAM="/etc/pam.d/sddm"
    SDDM_PAM_BACKUP="/etc/pam.d/sddm.backup-$(date +%Y%m%d)"
    
    if sudo grep -q "pam_u2f.so" "$SDDM_PAM"; then
        echo "  > removing U2F configuration from SDDM..."
        
        # Remove the U2F line from PAM config
        sudo sed -i '/pam_u2f.so/d' "$SDDM_PAM"
        
        echo "  > U2F authentication disabled for SDDM"
        echo ""
        echo "✅ PAM U2F disabled!"
        echo ""
        echo "📋 What was changed:"
        echo "   • U2F authentication removed from SDDM"
        echo "   • Password-only login restored"
        echo ""
        echo "🔑 To re-enable U2F authentication:"
        echo "   • Set _yubikey_login=true in setup.conf"
        echo "   • Run: ./setup.sh yubikey_login"
        return 0
    else
        echo "  > U2F authentication is not currently configured"
        echo ""
        echo "ℹ️  PAM U2F is already disabled"
        return 0
    fi
elif [ "$_yubikey_login" != true ] && [ "$override_arg" != "true" ]; then
    echo "> yubikey login disabled in preferences, skipping"
    return 0
fi

echo -n "> setting up PAM U2F authentication ... "

# Check if pam-u2f and pamu2fcfg are installed
echo ""
echo "  > checking for required packages..."

packages_to_install=()

if ! rpm -q pam-u2f >/dev/null 2>&1; then
    packages_to_install+=("pam-u2f")
fi

if ! rpm -q pamu2fcfg >/dev/null 2>&1; then
    packages_to_install+=("pamu2fcfg")
fi

if [ ${#packages_to_install[@]} -gt 0 ]; then
    echo "  > installing packages: ${packages_to_install[*]}"
    if sudo dnf install -y "${packages_to_install[@]}"; then
        echo "  > packages installed successfully"
        # Update PATH to ensure commands are available
        export PATH="/usr/bin:/usr/sbin:$PATH"
    else
        echo "❌ Failed to install required packages: ${packages_to_install[*]}"
        return 1
    fi
else
    echo "  > all required packages already installed"
fi

# Backup original SDDM PAM config
SDDM_PAM="/etc/pam.d/sddm"
SDDM_PAM_BACKUP="/etc/pam.d/sddm.backup-$(date +%Y%m%d)"

if [ ! -f "$SDDM_PAM_BACKUP" ]; then
    sudo cp "$SDDM_PAM" "$SDDM_PAM_BACKUP"
fi

# Check if U2F is already configured
if sudo grep -q "pam_u2f.so" "$SDDM_PAM"; then
    echo "already configured"
else
    echo ""
    echo "  > configuring PAM U2F for SDDM..."
    
    # Create a temporary file with the new configuration
    TEMP_PAM="/tmp/sddm_pam_new"
    
    # Add U2F auth line after the first auth line but before substack password-auth
    awk '
    /^auth\s+\[success=done ignore=ignore default=bad\]\s+pam_selinux_permit\.so/ {
        print $0
        print "auth        sufficient    pam_u2f.so cue"
        next
    }
    { print }
    ' "$SDDM_PAM" | sudo tee "$TEMP_PAM" > /dev/null
    
    # Replace the original file
    sudo mv "$TEMP_PAM" "$SDDM_PAM"
    
    echo "  > PAM U2F configuration added to SDDM"
fi

# Check if user has U2F keys configured
U2F_KEYS_FILE="$HOME/.config/Yubico/u2f_keys"
U2F_KEYS_DIR="$(dirname "$U2F_KEYS_FILE")"

if [ ! -f "$U2F_KEYS_FILE" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔑 U2F Key Setup Required"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "You need to register your U2F/FIDO2 security key."
    echo "Please insert your security key and follow the prompts."
    echo ""
    echo "Note: This is OPTIONAL authentication - you can still log in with password only."
    echo ""
    
    # Create the directory if it doesn't exist
    mkdir -p "$U2F_KEYS_DIR"
    
    # Check if pamu2fcfg is available (should be after package install)
    if ! command -v pamu2fcfg >/dev/null 2>&1; then
        # Try to find it in common locations
        for path in /usr/bin/pamu2fcfg /usr/sbin/pamu2fcfg; do
            if [ -x "$path" ]; then
                export PATH="$(dirname "$path"):$PATH"
                break
            fi
        done
    fi
    
    if command -v pamu2fcfg >/dev/null 2>&1; then
        echo "Touch your security key when it lights up..."
        echo "(Waiting 30 seconds - setup will continue automatically if no key is detected)"
        echo "(Press Ctrl+C to skip U2F setup and continue)"
        echo ""
        
        # Run pamu2fcfg with timeout and capture both stdout and stderr
        local temp_output=$(mktemp)
        local temp_error=$(mktemp)
        local skip_u2f=false
        local pamu2fcfg_pid=""
        
        # Set up signal handler for Ctrl+C
        handle_interrupt() {
            skip_u2f=true
            if [ -n "$pamu2fcfg_pid" ]; then
                kill "$pamu2fcfg_pid" 2>/dev/null
            fi
            echo ""
            echo "⏭️  Skipping U2F setup..."
            echo ""
        }
        trap 'handle_interrupt' INT
        
        # Start pamu2fcfg in background with timeout
        (
            exec timeout 30 pamu2fcfg -u "$USER" > "$temp_output" 2> "$temp_error"
        ) &
        pamu2fcfg_pid=$!
        
        # Wait for the background process
        if wait $pamu2fcfg_pid 2>/dev/null; then
            local exit_code=$?
            if [ "$skip_u2f" = false ] && [ $exit_code -eq 0 ]; then
                # Success - copy the output to the keys file
                cp "$temp_output" "$U2F_KEYS_FILE"
                echo ""
                echo "✅ U2F key registered successfully!"
                echo "   Keys file: $U2F_KEYS_FILE"
            else
                # Handle various failure cases
                echo ""
                if [ "$skip_u2f" = true ]; then
                    # User pressed Ctrl+C - message already shown by handler
                    echo "📝 To set up U2F authentication later, run:"
                    echo "   ./setup.sh yubikey_login"
                elif [ $exit_code -eq 124 ]; then
                    # Timeout occurred
                    echo "⏱️  No U2F key detected within 30 seconds - skipping for now"
                    echo ""
                    echo "📝 To set up U2F authentication later, run:"
                    echo "   ./setup.sh yubikey_login"
                    echo ""
                    echo "   Or manually register your key:"
                    echo "   mkdir -p ~/.config/Yubico"
                    echo "   pamu2fcfg -u $USER > ~/.config/Yubico/u2f_keys"
                else
                    # Other error
                    local error_msg=$(cat "$temp_error" 2>/dev/null || echo "Unknown error")
                    if [[ "$error_msg" == *"No U2F"* ]] || [[ "$error_msg" == *"no device"* ]]; then
                        echo "⏱️  No U2F key detected - skipping for now"
                    else
                        echo "❌ U2F key registration failed: $error_msg"
                    fi
                    echo ""
                    echo "📝 To set up U2F authentication later, run:"
                    echo "   ./setup.sh yubikey_login"
                    echo ""
                    echo "   Or manually register your key:"
                    echo "   pamu2fcfg -u $USER > $U2F_KEYS_FILE"
                fi
            fi
        else
            # wait failed (probably due to interrupt)
            if [ "$skip_u2f" = false ]; then
                echo ""
                echo "❌ U2F setup interrupted"
                echo ""
                echo "📝 To set up U2F authentication later, run:"
                echo "   ./setup.sh yubikey_login"
            fi
        fi
        
        # Reset signal handler
        trap - INT
        
        # Clean up temp files
        rm -f "$temp_output" "$temp_error"
    else
        echo "❌ pamu2fcfg command not found after package installation."
        echo "   Please verify pam-u2f package is properly installed:"
        echo "   sudo dnf list installed pam-u2f"
        echo ""
        echo "   Then manually register your key:"
        echo "   pamu2fcfg -u $USER > $U2F_KEYS_FILE"
        echo ""
        echo "📝 To set up U2F authentication later, run:"
        echo "   ./setup.sh yubikey_login"
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    echo "done (keys already configured)"
fi

echo ""

# Check if U2F keys are actually configured and show appropriate status
if [ -f "$U2F_KEYS_FILE" ] && [ -s "$U2F_KEYS_FILE" ]; then
    echo "✅ PAM U2F setup complete!"
    echo ""
    echo "📋 What was configured:"
    echo "   • PAM U2F package installed"
    echo "   • SDDM configured for optional U2F authentication"
    echo "   • U2F authentication is SUFFICIENT (optional) - password login still works"
    echo "   • Configuration: auth sufficient pam_u2f.so cue"
    echo "   • U2F security key registered and ready to use"
    echo ""
    echo "🔒 Security Notes:"
    echo "   • U2F authentication is optional - you won't get locked out"
    echo "   • You can still log in with just your password"
    echo "   • When U2F key is present, touch it when prompted at login"
    echo "   • To disable: set _yubikey_login=false in setup.conf"
else
    echo "⚠️  PAM U2F setup partially complete"
    echo ""
    echo "📋 What was configured:"
    echo "   • PAM U2F package installed"
    echo "   • SDDM configured for optional U2F authentication"
    echo "   • U2F authentication is SUFFICIENT (optional) - password login still works"
    echo "   • Configuration: auth sufficient pam_u2f.so cue"
    echo "   ❌ U2F security key NOT registered"
    echo ""
    echo "🔑 To complete U2F setup:"
    echo "   • Run: ./setup.sh yubikey_login"
    echo "   • Or manually: pamu2fcfg -u $USER > ~/.config/Yubico/u2f_keys"
    echo ""
    echo "🔒 Security Notes:"
    echo "   • You can still log in normally with your password"
    echo "   • U2F will be available once you register a key"
    echo "   • To disable: set _yubikey_login=false in setup.conf"
fi
echo ""