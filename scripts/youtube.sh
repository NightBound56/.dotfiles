#!/bin/bash

# Function to download a video or playlist from YouTube
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