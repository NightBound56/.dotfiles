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



archive() {
    if [ $# -ne 1 ]; then
        echo "Usage: archive <path>"
        return 1
    fi

    local path="$1"
    local zip_name

    if [ -e "$path" ]; then
        if [ -d "$path" ]; then
            # It's a directory
            zip_name=$(basename "$path").zip
            zip -r "$zip_name" "$path"
            if [ $? -eq 0 ]; then
                echo "Directory '$path' has been compressed into '$zip_name'."
                # Verify the zip file
                zipinfo "$zip_name" >/dev/null
                if [ $? -eq 0 ]; then
                    echo "Verification: '$zip_name' is a valid zip archive."
                else
                    echo "Verification: '$zip_name' is NOT a valid zip archive or an error occurred."
                fi
            else
                echo "Error compressing directory '$path'."
            fi
        elif [ -f "$path" ]; then
            # It's a file
            zip_name=$(basename "$path" .${path##*.}).zip
            zip "$zip_name" "$path"
            if [ $? -eq 0 ]; then
                echo "File '$path' has been compressed into '$zip_name'."
                # Verify the zip file
                zipinfo "$zip_name" >/dev/null
                if [ $? -eq 0 ]; then
                    echo "Verification: '$zip_name' is a valid zip archive."
                else
                    echo "Verification: '$zip_name' is NOT a valid zip archive or an error occurred."
                fi
            else
                echo "Error compressing file '$path'."
            fi
        else
            echo "Error: '$path' is neither a file nor a directory."
            return 1
        fi
    else
        echo "Error: '$path' does not exist."
        return 1
    fi
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
