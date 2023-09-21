delayed_shutdown() {
    if [ $# -ne 1 ]; then
        echo "Usage: delayed_shutdown <minutes>"
        return 1
    fi

    minutes="$1"

    echo "Shutdown has been delayed for $minutes minutes. Please enter your password:"
    sudo -v && sleep "${minutes}m" && sudo shutdown now
}

shred_dir() {
    # Directory to purge
    local directory="$1"
	
	
    echo "Purging $directory"
    echo "Progress %"
    if [ -d "$directory" ]; then
	
		total_files=$(find $directory -type f | wc -l)
		files_deleted=0
        # Loop through each file and directory recursively purging with 40 passes.
        find "$directory" -type f | while read -r file; do
			
            shred -u -n 40 "$file"
            ((files_deleted++))
			
			progress=$((files_deleted * 100 / total_files))
			echo "$progress"
        done

        # Remove the parent directory that had all files purged
        rm -r "$directory"

        # Purge shell
        if [ -n "$ZSH_VERSION" ]; then
            cat /dev/null > "$HOME/.zsh_history"
            fc -R
        elif [ -n "$BASH_VERSION" ]; then
            cat /dev/null > "$HOME/.bash_history"
            history -c
            history -r
        fi
    else
        echo "Directory '$1' does not exist."
    fi
}
