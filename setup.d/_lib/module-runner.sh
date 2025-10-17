#!/bin/bash
# Module discovery and execution functions for setupv2.sh

# Helper function to determine if a preference value should run a module
should_run_module() {
    local pref_value="$1"
    [ "$pref_value" = "true" ] || [ "$pref_value" != "false" -a -n "$pref_value" ]
}

# Helper function to get module execution type and args
get_module_execution_info() {
    local module_name="$1"
    local pref_value="$2"
    
    # Determine execution type and arguments
    if [ "$pref_value" = "true" ]; then
        echo "boolean_true"
    elif [ "$pref_value" = "false" ]; then
        echo "skip"
    else
        echo "configured" "$pref_value"
    fi
}

# Helper function to execute a single module
execute_module() {
    local module_name="$1"
    local script_file="$2"
    local execution_type="$3"
    local pref_value="$4"
    
    case "$execution_type" in
        "boolean_true")
            echo "enabled, running"
            run_module_with_defaults "$module_name" "$script_file"
            ;;
        "configured")
            echo "configured, running"
            run_module_with_value "$module_name" "$script_file" "$pref_value"
            ;;
        "skip")
            echo "disabled, skipping"
            ;;
    esac
}

# Helper function to run module with default values
run_module_with_defaults() {
    local module_name="$1"
    local script_file="$2"
    
    case "$module_name" in
        "hostname") setup_hostname ;;
        "wallpaper") setup_wallpaper ;;
        "cursor") setup_cursor ;;
        *)
            echo -n "    > running $module_name module ... "
            source "$script_file"
            ;;
    esac
}

# Helper function to run module with provided value
run_module_with_value() {
    local module_name="$1"
    local script_file="$2"
    local pref_value="$3"
    
    case "$module_name" in
        "hostname") setup_hostname "$pref_value" ;;
        "wallpaper") setup_wallpaper "$pref_value" ;;
        "cursor") setup_cursor "$pref_value" "$_cursor_size" ;;
        *)
            echo -n "    > running $module_name module with value '$pref_value' ... "
            source "$script_file" "$pref_value"
            ;;
    esac
}

# Function to process a single discovered module
process_module() {
    local script_file="$1"
    local override_args=("${@:2}")  # All arguments after the first
    local module_name
    local pref_var
    local pref_value
    local execution_info
    
    module_name=$(basename "$script_file" .sh)
    pref_var="_${module_name}"
    
    echo -n "  > checking module '$module_name' ... "
    
    # If override arguments provided, use them instead of preferences
    if [ ${#override_args[@]} -gt 0 ]; then
        echo "with provided arguments, running"
        case "$module_name" in
            "hostname") setup_hostname "${override_args[0]}" ;;
            "wallpaper") setup_wallpaper "${override_args[0]}" ;;
            "cursor") setup_cursor "${override_args[0]}" "${override_args[1]:-$_cursor_size}" ;;
            *)
                echo -n "    > running $module_name module with arguments ... "
                source "$script_file" "${override_args[@]}"
                ;;
        esac
        return 0
    fi
    
    # Check if preference variable exists
    if ! declare -p "$pref_var" >/dev/null 2>&1; then
        echo "no preference variable found, skipping"
        return 0
    fi
    
    # Get preference value and execution info
    pref_value="${!pref_var}"
    execution_info=($(get_module_execution_info "$module_name" "$pref_value"))
    
    # Execute the module
    execute_module "$module_name" "$script_file" "${execution_info[@]}" "$pref_value"
}

# Function to discover and run available modules
run_discovered_modules() {
    validate_required_prefs
    
    echo "> discovering available modules in $_scripts"
    
    # Find all .sh files in the scripts directory (excluding _lib)
    for script_file in "$_scripts"*.sh; do
        [ -f "$script_file" ] && process_module "$script_file"
    done
}