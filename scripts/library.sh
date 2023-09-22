#!/bin/bash

#How ro run this script: ./library.sh -f functionOne -a arg1 -a arg2 -a arg3
# This script will run functions defined here or in other script files.
# It will sanitise the arguments and execute the function.
# Scroll down to function definition to check how to validate number of args.
# Issues are added to a log file that is automatically cleaned.
# The aim of this function is to bring in a library of various other scripts and functions in a modular way.

# Logging function
log() {
    local log_dir="$HOME/script_logs"
    local log_file="script.log"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local log_path="$log_dir/$log_file"
    
    # Check if log directory exists, create it if not
    if [ ! -d "$log_dir" ]; then
        mkdir -p "$log_dir"
    fi

    # Check if log file exists and is older than 1 month
    if [ -f "$log_path" ] && [ "$(find "$log_path" -type f -mtime +30)" ]; then
        # Delete the old log file securely with 42 passes
        shred -u -n 42 "$log_path"
    fi

    # Create a new log file
    touch "$log_path"

    # Log the message to the new log file
    echo "[$timestamp] $1" >> "$log_path"
}

sanitize_argument() {
    local input="$1"

    # Define disallowed strings
    local disallowed=("rm -rf /" ":(){:|:&};:")

    # Check if the input contains disallowed strings
    for dis in "${disallowed[@]}"; do
        if [[ "$input" == *"$dis"* ]]; then
            echo "Invalid input: Disallowed string detected."
            return 1
        fi
    done

    # Allow only specified characters (alphanumeric, $, #, ~, +, -, /)
    local sanitized_string="${input//[^A-Za-z0-9\$#~+-/]/}"

    if [ -n "$sanitized_string" ]; then
        echo "$sanitized_string"
        return 0
    else
        echo "Invalid input: Contains no valid characters."
        return 1
    fi
}




# Function to check the number of arguments for a given function and call it if valid
CheckArgs() {
    local func_name="$1"
    shift
    local args=("$@")

	echo "Entering Check args..."
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
		echo "Entering Check For loop of args..."
        all_args_valid=true
        for arg in "${args[@]}"; do
			echo "Attempting to trigger sanitize check against $arg"
            sanitized_arg=$(sanitize_argument "$arg")
            if [ "$sanitized_arg" != "$arg" ]; then
                log "Error: Argument '$arg' contains invalid characters."
                all_args_valid=false
                break
            fi
        done

        # Call the function with the provided arguments if all arguments are valid
        if [ "$all_args_valid" = true ]; then
            eval "$func_name" "${args[@]}"
        else
			echo "Error: Not calling the function due to invalid arguments."
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

# General functions needed across all scripts
clear_shell_history() {
    # Check if the current shell is zsh
    if [ -n "$ZSH_VERSION" ]; then
        echo "Clearing zsh history..."
        cat /dev/null > "$XDG_HOME/.zsh_history"
        fc -R
    # Check if the current shell is bash
    elif [ -n "$BASH_VERSION" ]; then
        echo "Clearing bash history..."
        cat /dev/null > "$XDG_HOME/.bash_history"
        history -c
        history -r
    else
        echo "Unknown shell. Command history not cleared."
    fi
}

check_directory_exists() {
  dir_path="$1"
  expanded_path=$(eval echo "$dir_path")
  if [ -d "$expanded_path" ]; then
    return 0  # Directory exists
  else
    return 1  # Directory does not exist
  fi
}
# Example usage:if check_directory_exists "$HOME/Documents";

check_file_exists() {
  file_path="$1"
  expanded_path=$(eval echo "$file_path")
  if [ -f "$expanded_path" ]; then
    return 0  # File exists
  else
    return 1  # File does not exist
  fi
}
# Example usage:if check_file_exists "$HOME/Documents/example.txt";

is_installed() {
    package_name="$1"
    
    # Check if the package manager is apt (Ubuntu)
    if command -v apt &>/dev/null; then
        if dpkg -l | grep -q "ii  $package_name "; then
            return 0
        else
            return 1
        fi
    # Check if the package manager is pacman (Arch Linux)
    elif command -v pacman &>/dev/null; then
        if pacman -Qs "$package_name" &>/dev/null; then
            return 0
        elif command -v yay &>/dev/null && yay -Qs "$package_name" &>/dev/null; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}
# Example usage: if is_installed "package_name";


trim() {
  # Remove leading whitespace
  local trimmed="${1##* }"
  # Remove trailing whitespace
  trimmed="${trimmed%%* }"
  echo -n "$trimmed"
}
# Example usage: result=$(trim "$my_string")


extract_alphanumerics() {
  local input="$1"
  local pattern="[a-zA-Z0-9. ]+"
  
  if [[ "$input" =~ $pattern ]]; then
    local result="${BASH_REMATCH[0]}"
    echo "$result"
  else
    echo "No alphanumeric or period characters found."
  fi
}

replace_space_with_underscore() {
  local input="$1"
  # Replace periods with spaces
  local replaced="${input//./ }"
  # Replace spaces with underscores
  replaced="${replaced// /_}"
  # Use sed to replace consecutive underscores with a single underscore
  replaced=$(echo "$replaced" | sed 's/__*/_/g')
  echo "$replaced"
}

lower() {
  local input="$1"
  local lowercase
  lowercase=$(echo "$input" | tr '[:upper:]' '[:lower:]')
  echo "$lowercase"
}

upper() {
  local input="$1"
  local uppercase
  uppercase=$(echo "$input" | tr '[:lower:]' '[:upper:]')
  echo "$uppercase"
}



# Media functions
source ~/scripts/media.sh

# Utility functions
source ~/scripts/utils.sh

# Archiving functions - needs more modularising and made compatible with library.
#source ~/scripts/archiving.sh


# Naming convention SeasonEpisode_title_year_quality
# lower $1
# extract_alphanumerics $1
# replace_space_with_underscore $1
# extract_season_episode $1
# extract_info $1 "year"
# extract_info $1 "quality"


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