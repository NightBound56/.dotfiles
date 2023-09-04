#!/bin/bash

shred_dir() {
    # Directory to purge
    local directory="$1"
    echo "Purging... '$directory'"
    if [ -d "$directory" ]; then
        # Loop through each file and directory recursively purging with 40 passes.
        find "$directory" -type f | while read -r file; do
            echo "Purging: '$file'"
            shred -u -n 40 "$file"
            echo "Purged"
        done

        # Remove the parent directory that had all files purged
        rm -r "$directory"

        # Purge shell
        if [ -n "$ZSH_VERSION" ]; then
            cat /dev/null > "$XDG_HOME/.zsh_history"
            fc -R
        elif [ -n "$BASH_VERSION" ]; then
            cat /dev/null > "$XDG_HOME/.bash_history"
            history -c
            history -r
        fi
    else
        echo "Directory '$1' does not exist."
    fi
}

# Check which function is passed to the script and execute it with args.
case "$1" in
    "shred_dir")
        shift  # Remove the first argument
        shred_dir "$@"
        ;;
    "another_function")
        shift  # Remove the first argument
        another_function "$@"
        ;;
    *)
        echo "Usage: $0 {shred_dir|another_function} [args...]"
        exit 1
        ;;
esac
