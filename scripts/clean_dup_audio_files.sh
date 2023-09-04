clean_audio_files() {
    local dir="$1"
    local ext="$2"
    
    # Check if the argument is a directory and if it exists
    if [ -d "$dir" ]; then
        # Create an associative array to track file names
        declare -A filenames
        
        # Check for files only if the directory exists
        for file in "$dir"/*."$ext"; do
            if [ -f "$file" ]; then
                filename="${file%.*}"  # Get the file name without extension
                # Check if this file name has been seen before
                if [ -n "${filenames[$filename]}" ]; then
                    # Use shred with 40 passes to securely delete the duplicate file
                    shred -u -n 40 "$file"
                    echo "Securely deleted: $file (Duplicate)"
                else
                    # Store the file name in the associative array
                    filenames["$filename"]=1
                fi
            fi
        done
    else
        echo "Error: '$dir' is not a valid directory or does not exist."
        return 1
    fi
}