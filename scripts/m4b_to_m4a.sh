convert_m4b_to_m4a_and_delete() {
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
