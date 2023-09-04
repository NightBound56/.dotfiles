convert_mp3_to_m4a_and_delete() {
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
