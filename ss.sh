install_fonts() {
  local directory="$1"

  # Check if the directory exists
  if [ ! -d "$directory" ]; then
    echo "Error: Directory not found."
    exit 1
  fi

  echo "Installing fonts from $directory..."
  mkdir -p "$HOME/.fonts"

  find "$directory" -type f \( -name "*.otf" -o -name "*.ttf" \) -print0 | while IFS= read -r -d '' fontfile; do
    fontname=$(basename "$fontfile")

    # Check if the font is already installed
    if fc-list | grep -q "$fontname"; then
      echo "Font $fontname is already installed."
    else
      cp "$fontfile" "$HOME/.fonts/"
      echo "Installed font: $fontname"
    fi
  done

  echo "Updating font cache..."
  fc-cache -f -v > /dev/null 2>&1
  echo "Font installation complete."
}

# Example usage:
install_fonts "$dotfiles_dir/fonts"
