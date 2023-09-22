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

generate_ssh_keys() {
    local key_name="$1"
    local key_path="$HOME/keys/$key_name"

    # Generate a secure Ed25519 SSH key
    ssh-keygen -t ed25519 -f "$key_path" -N ""

    # Ensure correct permissions for all files in the keys folder
    chmod 600 "$HOME/keys"/*
}

import_ssh_keys() {
    local keys_dir="$HOME/keys"
    
    # Check if the keys directory exists
    if [ -d "$keys_dir" ]; then
        for key_file in "$keys_dir"/*; do
            # Check if it's a regular file and not a directory
            if [ -f "$key_file" ]; then
                # Check if the file is an SSH key (public or private)
                if ssh-keygen -l -f "$key_file" &>/dev/null; then
                    # Check if the key is already in the SSH agent
                    if ! ssh-add -l | grep -q "$(ssh-keygen -E md5 -lf "$key_file" | awk '{print $2}')"; then
                        ssh-add "$key_file"
                        echo "Imported SSH key: $key_file"
                    else
                        echo "SSH key already imported: $key_file"
                    fi
                else
                    echo "Not an SSH key: $key_file"
                fi
            fi
        done
    else
        echo "Keys directory not found: $keys_dir"
    fi
}
