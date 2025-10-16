#!/bin/bash
# Preference validation functions for setupv2.sh

# Function to validate required preferences
validate_required_prefs() {
    local missing_prefs=()
    
    for pref in "${_required_prefs[@]}"; do
        if [ -z "${!pref}" ]; then
            missing_prefs+=("$pref")
        fi
    done
    
    if [ ${#missing_prefs[@]} -gt 0 ]; then
        echo "ERROR: Required preferences not set:"
        for pref in "${missing_prefs[@]}"; do
            echo "  - $pref"
        done
        echo ""
        echo "Please set these variables in setup.conf and try again."
        exit 1
    fi
}

# Function to check for orphaned preference variables
check_orphaned_preferences() {
    echo "> checking for orphaned preference variables..."
    local orphaned_prefs=()
    
    # Check all non-boolean preference variables that start with underscore
    while IFS= read -r var_line; do
        if [[ "$var_line" =~ ^_[a-zA-Z_][a-zA-Z0-9_]*= ]]; then
            var_name=$(echo "$var_line" | cut -d'=' -f1)
            var_value="${!var_name}"
            
            # Skip boolean variables (true/false) and empty variables
            if [[ "$var_value" != "true" && "$var_value" != "false" && -n "$var_value" ]]; then
                # Extract module name from variable (remove leading underscore)
                module_name="${var_name#_}"
                script_file="$_scripts${module_name}.sh"
                
                # Check if corresponding script exists
                if [ ! -f "$script_file" ]; then
                    orphaned_prefs+=("$var_name (value: $var_value)")
                fi
            fi
        fi
    done < <(declare -p | grep "^declare -.*_.*=")
    
    if [ ${#orphaned_prefs[@]} -gt 0 ]; then
        echo "ERROR: Found preference variables without corresponding scripts:"
        for pref in "${orphaned_prefs[@]}"; do
            echo "  - $pref"
        done
        echo ""
        echo "This indicates an invalid configuration. Please either:"
        echo "  1. Remove unused preference variables from setup.conf, or"
        echo "  2. Create corresponding scripts in $_scripts"
        echo ""
        echo "Configuration must be fixed before running setup."
        exit 1
    fi
}

# Function to validate all preferences before execution
validate_preferences() {
    # Skip validation for help command
    if [[ "$1" == "help" || "$1" == "-h" || "$1" == "--help" ]]; then
        return 0
    fi
    
    check_orphaned_preferences
}