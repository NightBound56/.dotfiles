#!/bin/bash
join_mp3_files() {
    # Specify the folder containing the MP3 files
    folder="$1"

    # Check if the folder exists
    if [ $# -eq 1 ] && [ -d "$1" ]; then
    
        # Create a temporary text file to list the MP3 files in sequence
        tmpfile=$(mktemp)
    
        # Use 'ls' with natural sorting to list the MP3 files
        if ! ls -v "$folder"/*.mp3 > "$tmpfile"; then
            echo "No MP3 files found in $folder"
            rm "$tmpfile"
            return 1
        fi
    
        # Use ffmpeg to concatenate the MP3 files
        if ! ffmpeg -f concat -safe 0 -i "$tmpfile" -c copy "${folder}/output.mp3"; then
            echo "Error during MP3 file concatenation"
            shred -u -n 40 "$tmpfile"
            return 1
        fi
    
        # Clean up the temporary text file
        shred -u -n 40 "$tmpfile"
    
        echo "MP3 files in $folder have been successfully joined into 'output.mp3'"
    
    fi
}