#!/bin/bash

# Main setup function - can be sourced or executed directly
main_setup() {
    _scripts="$HOME/setup.d/"
    _packages="$HOME/packages.txt"
    _desktop=$(echo $XDG_CURRENT_DESKTOP)

    # Load configuration from setup.conf
    if [ -f "$HOME/setup.conf" ]; then
        source "$HOME/setup.conf"
    else
        echo "ERROR: Configuration file '$HOME/setup.conf' not found"
        echo "Please create setup.conf with your preferences"
        return 1
    fi

    # Required non-boolean preferences (script will fail if not set)
    # Only include preferences that have corresponding scripts in setup.d/
    _required_prefs=("_hostname" "_wallpaper" "_cursor" "_editor")

    # Load library functions
    source "${_scripts}_lib/validation.sh"
    source "${_scripts}_lib/module-runner.sh"
    source "${_scripts}_lib/setup-functions.sh"

    # Validate preferences before any execution
    validate_preferences "$1"

    # Check if first argument matches a module name
    requested_module="$1"

    if [ -n "$requested_module" ] && [ "$requested_module" != "help" ] && [ "$requested_module" != "-h" ] && [ "$requested_module" != "--help" ]; then
        # Check if it's a valid module (script exists)
        script_file="$_scripts${requested_module}.sh"
        if [ -f "$script_file" ]; then
            echo 'Initializing...'
            sudo -n true 2>/dev/null || sudo -v || return 1
            
            # Use the same logic as module discovery - pass any additional arguments
            process_module "$script_file" "${@:2}"
            return 0
        fi
    fi

    # Handle special cases and fallbacks
    case "$requested_module" in
        "help"|"-h"|"--help")
            show_usage
            return 0
            ;;
        "repos")
            echo 'Initializing...'
            sudo -n true 2>/dev/null || sudo -v || return 1
            setup_repos
            ;;
        "packages")
            echo 'Initializing...'
            sudo -n true 2>/dev/null || sudo -v || return 1
            setup_packages
            ;;
        "")
            # Run full setup with module discovery
            echo 'Initializing...'
            sudo -n true 2>/dev/null || sudo -v || return 1

            # First run core system setup
            setup_repos
            setup_packages
            
            # Then run discovered modules
            run_discovered_modules
            ;;
        *)
            if [ -n "$requested_module" ]; then
                echo "Error: Unknown module '$requested_module'"
                echo ""
                echo "Available modules:"
                for script_file in "$_scripts"*.sh; do
                    if [ -f "$script_file" ]; then
                        module_name=$(basename "$script_file" .sh)
                        echo "  - $module_name"
                    fi
                done
                echo ""
                echo "Use '$0 help' for more information."
                return 1
            fi
            ;;
    esac
}

# If this script is executed directly (not sourced), run main_setup
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main_setup "$@"
fi