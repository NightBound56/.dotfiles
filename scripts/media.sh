join_m4a() {
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

join_mp3() {
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

convert_m4b_to_m4a_() {
    input_file="$1"
    output_file="$(dirname "$input_file")/$(basename "$input_file" .m4b).m4a"
    
    # Convert to M4A using ffmpeg
    if ffmpeg -i "$input_file" -c:v copy -c:a aac -strict experimental -b:a 256k -map_metadata 0 "$output_file"; then
        # Conversion successful, securely delete the input M4B file
        shred -u -n 40 "$input_file"
    else
        # Conversion failed, display an error message
        echo "Error: FFmpeg conversion failed."
    fi
}

convert_mp3_to_m4a() {
    input_file="$1"
    output_file="$(dirname "$input_file")/$(basename "$input_file" .mp3).m4a"
    
    # Convert to M4A using ffmpeg with error checking
    if ffmpeg -i "$input_file" -c:v copy -c:a aac -strict experimental -b:a 256k -map_metadata 0 "$output_file"; then
        echo "Conversion successful."
        
        # Securely delete the input MP3 file
        shred -u -n 40 "$input_file"
        echo "Input MP3 file securely deleted."
    else
        echo "Error during conversion. Input MP3 file not deleted."
    fi
}

download_youtube() {
    # Check if the function is called with exactly one argument
    if [ "$#" -ne 1 ]; then
        echo "Usage: download_youtube <URL>"
        return 1
    fi

    # Check if the URL is for a playlist or a single video
    if youtube-dl --skip-download --quiet --get-id "$1"; then
        # It's a single video URL
        video_url="$1"
        video_title=$(youtube-dl --get-title "$video_url")
        
        # Download the video with the best quality
        # Save it in $HOME/Downloads/youtube/ using its title as the filename
        youtube-dl --format best -o "$HOME/Downloads/youtube/%(title)s.%(ext)s" "$video_url"
        echo "Video '$video_title' downloaded to $HOME/Downloads/youtube/"
    else
        # It's a playlist URL
        playlist_url="$1"
        playlist_title=$(youtube-dl --get-title "$playlist_url")
        
        # Create a directory for the playlist if it doesn't exist
        playlist_dir="$HOME/Downloads/youtube/$playlist_title"
        mkdir -p "$playlist_dir"

        # Download all videos in the playlist with the best quality
        # Save them in $HOME/Downloads/youtube/playlist_title/ using their titles as filenames
        youtube-dl --format best -o "$playlist_dir/%(title)s.%(ext)s" "$playlist_url"
        echo "Playlist '$playlist_title' downloaded to $playlist_dir/"

        # Create a text file listing each video URL
        video_list_file="$playlist_dir/playlist_urls.txt"
        youtube-dl -j --flat-playlist "$playlist_url" | jq -r '.url' > "$video_list_file"
        echo "Video URLs listed in '$video_list_file'"
    fi
}

yt_video_to_audio() {
    directory="$1"
    
    if [ ! -d "$directory" ]; then
        echo "Directory does not exist."
        return 1
    fi
    
    cd "$directory"
    
    for ext in mp4 webm flv mkv avi mov; do
        find . -type f -iname "*.$ext" -print0 | while IFS= read -r -d '' file; do
            base_name=$(basename -- "$file")
            base_name="${base_name%.*}"
            output_file="${base_name}.mp3"
            ffmpeg -i "$file" -vn -acodec libmp3lame -q:a 2 "$output_file"
            echo "$file converted to $output_file"
            
            # Securely delete the original video file
            shred -u -n 42 "$file"
            echo "$file securely deleted"
        done
    done
}

clean_dup_audio_files() {
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