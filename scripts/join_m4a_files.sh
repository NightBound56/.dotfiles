#!/bin/bash
join_m4a_files() {
    # Specify the folder containing the M4A files
    folder="$1"

    # Check if the folder exists
    if [ $# -eq 1 ] && [ -d "$1" ]; then
    
        # Create a temporary text file to list the M4A files in sequence
        tmpfile=$(mktemp)
    
        # Use 'ls' with natural sorting to list the M4A files
        if ! ls -v "$folder"/*.m4a > "$tmpfile"; then
            echo "No M4A files found in $folder"
            rm "$tmpfile"
            return 1
        fi
    
        # Use ffmpeg to concatenate the M4A files
        if ! ffmpeg -f concat -safe 0 -i "$tmpfile" -c:v copy -c:a aac -strict experimental -b:a 256k -map_metadata 0 "${folder}/output.m4a"; then
            echo "Error during M4A file concatenation"
            shred -u -n 40 "$tmpfile"
            return 1
        fi
    
        # Clean up the temporary text file
        shred -u -n 40 "$tmpfile"
    
        echo "M4A files in $folder have been successfully joined into 'output.m4a'"
    
    fi
}
