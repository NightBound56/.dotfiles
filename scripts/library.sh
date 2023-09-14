#!/bin/bash

# Logging function
log() {
    local log_dir="logs"
    local log_file="script.log"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local log_path="$log_dir/$log_file"
    
    # Check if log directory exists, create it if not
    if [ ! -d "$log_dir" ]; then
        mkdir -p "$log_dir"
    fi

    # Check if log file exists and is older than 1 month
    if [ -f "$log_path" ] && [ "$(find "$log_path" -mtime +30)" ]; then
        # Delete the old log file securely with 42 passes
        shred -u -n 42 "$log_path"
    fi

    # Create a new log file
    touch "$log_path"

    # Log the message to the new log file
    echo "[$timestamp] $1" >> "$log_path"
}

# Function to sanitize and validate arguments
sanitize_argument() {
    local arg="$1"
    
    # Define a regular expression to allow alphanumeric characters, underscores,
    # at symbols, periods, hyphens, slashes, parentheses, square brackets, spaces,
    # tilde, question mark, ampersand, and dollar sign
    local allowed_chars="A-Za-z0-9_@./-()[] ~?&$"

    # Use grep with the -q (quiet) option to check if the argument contains only allowed characters
    if echo "$arg" | grep -Eq "^[${allowed_chars}]+$"; then
        # Argument is safe; return it
        echo "$arg"
    else
        # Argument contains disallowed characters; handle the error
        echo "Error: Argument '$arg' contains invalid characters."
        exit 1
    fi
}


# Function to check the number of arguments for a given function and call it if valid
CheckArgs() {
    local func_name="$1"
    shift
    local args=("$@")

    # Log function start
    log "Function '$func_name' started with arguments: ${args[*]}"

    # Check if the -f flag is provided
    if [ -z "$func_name" ]; then
        log "Error: Function name (-f) is not provided."
        exit 1
    fi

    # Check if at least one -a flag is provided
    if [ ${#args[@]} -eq 0 ]; then
        log "Error: No arguments (-a) are provided."
        exit 1
    fi

    # Check if the function exists
    if declare -f "$func_name" >/dev/null; then
        # Validate the number of arguments
        if ! validate_arg_num "${#args[@]}" "$func_name"; then
            log "Error: Invalid number of arguments."
            exit 1
        fi

        # Iterate through arguments and validate each one
        all_args_valid=true
        for arg in "${args[@]}"; do
            sanitized_arg=$(sanitize_argument "$arg")
            if [ "$sanitized_arg" != "$arg" ]; then
                log "Error: Argument '$arg' contains invalid characters."
                all_args_valid=false
                break
            fi
        done

        # Call the function with the provided arguments if all arguments are valid
        if [ "$all_args_valid" = true ]; then
            "$func_name" "${args[@]}"
        else
            log "Error: Not calling the function due to invalid arguments."
        fi
    else
        log "Error: Function '$func_name' does not exist."
    fi

    # Log function end
    log "Function '$func_name' completed."
}

validate_arg_num() {
    local expected_args="$1"
    shift
    local actual_args="$#"

    if [ "$actual_args" -ne "$expected_args" ]; then
        log "Error: Expected $expected_args arguments, but received $actual_args arguments"
        return 1
    fi
}



#BEGIN FUNCTION DEFINITION HERE

# Function to validate the number of arguments provided to a function
# EXAMPLE FUNCTION TEMPLATE:
#function function001() {
#    validate_arg_num 1 "$@"
#    if [ $? -ne 0 ]; then
#        return 1
#    fi
#    # Rest of function001's code
#}





#END FUNCTION DEFINITION HERE


# Parse command line arguments
while getopts "f:a:" opt; do
    case $opt in
        f)
            func_name="$OPTARG"
            ;;
        a)
            args+=("$OPTARG")
            ;;
        *)
            echo "Usage: $0 -f function_name -a argument1 -a argument2 ..."
            exit 1
            ;;
    esac
done


CheckArgs "$func_name" "${args[@]}"