# Define a function to clear command history based on the shell
#Needs to be moved to utils lib
clear_history() {
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

# Define a function to compress a directory and securely delete its contents
compress_folder() {
    # Check if the directory path argument is provided and exists
    if [ $# -eq 1 ] && [ -d "$1" ]; then
        local dir_path="$1"
        
        # Print a message to indicate the compression process is starting
        echo "Compressing directory to archive..."
        echo "Directory path: $dir_path"
        
        # Get the directory name (without trailing slashes)
        local dir_name=$(basename "$dir_path")
        
        # Create the archive path one level up from the original directory
        local archive_path="../${dir_name}.tar.gz"
        
        # Use the 'tar' command to compress the directory into a tar.gz archive
        tar -czf "$archive_path" -C "$(dirname "$dir_path")" "$dir_name"
        
        # Check the exit status of 'tar' to verify if the archive creation was successful
        if [ $? -eq 0 ]; then
            # Use 'find' to list files within the directory
            # Pipe the list of files to 'xargs' for parallel processing
            # '-P' specifies the number of parallel processes to use
            # Adjust '-P' as needed based on the number of CPU cores
            find "$dir_path" -type f | xargs -P "$(nproc)" -I {} bash -c '
                file="$1"
                echo "Purging: $file"
                shred -u -n 40 "$file"
                echo "Purged: $file"
            ' _ {}
            
            # Delete the original directory
            rm -rf "$dir_path"
            
            # Check the exit status of 'rm' to verify if the directory was deleted
            if [ $? -ne 0 ]; then
                echo "Error: Failed to delete the original directory."
                return 1
            fi
        else
            # If 'tar' encountered an error, print an error message
            echo "Error: Archive creation failed."
            return 1
        fi

        # Call the clear_history function to clear command history
        clear_history
    fi
}

decompress_folder() {
  # Check if there is at least 1 argument, it's a file, and it's a compressed archive
  if [ $# -ge 1 ] && [ -f "$1" ] && [[ "$1" =~ \.(zip|tar\.gz|tar\.bz2|tar\.xz)$ ]]; then
    # Determine the parent directory
    parent_dir="$(dirname "$1")"
    
    # Create a folder with the archive's name
    archive_name="$(basename "$1")"
    folder_name="${archive_name%.*}"  # Remove the file extension
    mkdir -p "$parent_dir/$folder_name"
    
    # Extract the archive into the folder
    case "$1" in
      *.zip) unzip -q "$1" -d "$parent_dir/$folder_name" ;;
      *.tar.gz) tar -xzf "$1" -C "$parent_dir/$folder_name" ;;
      *.tar.bz2) tar -xjf "$1" -C "$parent_dir/$folder_name" ;;
      *.tar.xz) tar -xf "$1" -C "$parent_dir/$folder_name" ;;
    esac

    # Check the exit status of the tar command
    if [ $? -eq 0 ]; then
      echo "Extraction completed: $1 -> $parent_dir/$folder_name"
    else
      echo "Error: Failed to extract $1. Check the archive format or permissions."

      # Securely delete all files in the folder
      find "$parent_dir/$folder_name" -type f | xargs -P "$(nproc)" -I {} bash -c '
        file="$1"
        echo "Purging: $file"
        shred -u -n 40 "$file"
        echo "Purged: $file"
      ' _ {}
      
      # Delete the folder
      rm -rf "$parent_dir/$folder_name"
    fi
  else
    echo "Error: One or more conditions are not met."
  fi
  
  # Call the clear_history function to clear command history
  clear_history
}

encrypt_file() {
  local input_file="$1"
  local input_directory=$(dirname "$input_file")
  local input_filename=$(basename "$input_file")
  local output_file="$input_directory/${input_filename}.enc"
  local passphrase_file="$HOME/keys/symmetric_key.txt"

  # Check if the passphrase file exists
  if [ ! -e "$passphrase_file" ]; then
    echo "The passphrase file does not exist."
    return 1  # Exit the function with an error code
  fi

  # Read the first line of the passphrase file into the passphrase variable
  local passphrase
  passphrase=$(head -n 1 "$passphrase_file")

  # Check if the passphrase is empty
  if [ -z "$passphrase" ]; then
    echo "The passphrase file is empty."
    return 1  # Exit the function with an error code
  fi

  # Encrypt the file using OpenSSL with error checking
  if openssl enc -aes-256-cbc -salt -in "$input_file" -out "$output_file" -pass "pass:$passphrase"; then
    echo "Encryption of $input_file complete. Encrypted file saved as $output_file"
    
    # Securely delete the input file with 40 passes using shred
    shred -u -n 40 "$input_file"
    echo "Securely deleted $input_file."
  else
    echo "Encryption failed."
    return 1  # Exit the function with an error code
  fi
}

decrypt_file() {
  local encrypted_file="$1"
  local decrypted_directory=$(dirname "$encrypted_file")
  local decrypted_filename=$(basename "$encrypted_file" .enc)
  local output_file="$decrypted_directory/${decrypted_filename}"
  local passphrase_file="$HOME/keys/symmetric_key.txt"

  # Check if the passphrase file exists
  if [ ! -e "$passphrase_file" ]; then
    echo "The passphrase file does not exist."
    return 1  # Exit the function with an error code
  fi

  # Read the first line of the passphrase file into the passphrase variable
  local passphrase
  passphrase=$(head -n 1 "$passphrase_file")

  # Check if the passphrase is empty
  if [ -z "$passphrase" ]; then
    echo "The passphrase file is empty."
    return 1  # Exit the function with an error code
  fi

  # Decrypt the file using OpenSSL with error checking
  if openssl enc -aes-256-cbc -d -salt -in "$encrypted_file" -out "$output_file" -pass "pass:$passphrase"; then
    echo "Decryption of $encrypted_file complete. Decrypted file saved as $output_file"
    
    # Securely delete the encrypted file with 40 passes using shred
    shred -u -n 40 "$encrypted_file"
    echo "Securely deleted $encrypted_file."
  else
    echo "Decryption failed."
    return 1  # Exit the function with an error code
  fi
}
#Catch anything that isnt cleared.
#clear_history