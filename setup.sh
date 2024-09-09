#!/bin/bash

# Define log files
LOG_FILE="$HOME/script.log"
ERROR_LOG_FILE="$HOME/script_error.log"

# Function to log messages
log_message() {
    local message="$1"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Function to log errors
log_error() {
    local error_message="$1"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - ERROR: $error_message" >> "$ERROR_LOG_FILE"
}

# Function to clone a Git repository
clone_git_repo() {
    if [ "$#" -ne 2 ]; then
        log_error "Incorrect number of parameters provided"
        return
    fi

    local repo_url="$1"
    local destination="$2"
    destination=$(eval echo "$destination")
    local repo_name
    repo_name=$(basename "$repo_url" .git)

    log_message "Repository name: $repo_name"

    if [ -d "$destination" ]; then
        if [ -d "$destination/.git" ]; then
            cd "$destination" || { log_error "Failed to change directory to $destination"; return; }
            git pull >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
            log_message "The existing repo was updated using a pull"
        else
            log_error "The destination had a folder with the same name as the repo, clone aborted."
        fi
    else
        git clone "$repo_url" "$destination" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
        log_message "The repo cloned successfully."
    fi
}

# Function to create a custom Python virtual environment
create_custom_venv() {
    local environment_name="$1"
    local venv_dir="$HOME/venvs"
    local venv_path="$venv_dir/$environment_name"
    local env_file="$venv_path/.env"

    if [ -d "$venv_path" ]; then
        log_message "Virtual environment '$environment_name' already exists."
    else
        log_message "Creating a new virtual environment '$environment_name'..."
        python -m venv "$venv_path" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
        log_message "Virtual environment '$environment_name' created in '$venv_dir'."

        echo "export VIRTUAL_ENV=\"$venv_path\"" > "$env_file"
        echo "export PATH=\"\$VIRTUAL_ENV/bin:\$PATH\"" >> "$env_file"
        log_message "Virtual environment path added to '$env_file'."
    fi
}

# Function to install a package using the appropriate package manager
install_package() {
    local package_name="$1"
    local package_manager="$2"

    log_message "Processing $package_name."

    if "$package_manager" -Qq "$package_name" &>/dev/null; then
        log_message "$package_name is already installed."
    else
        if [ "$package_manager" = "yay" ] || [ "$package_manager" = "paru" ]; then
            "$package_manager" -S --noconfirm "$package_name" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
        elif [ "$package_manager" = "pacman" ]; then
            sudo "$package_manager" -S --noconfirm "$package_name" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
        else
            log_error "Unsupported package manager: $package_manager"
            return 1
        fi
    fi
}

# Function to create a symbolic link safely
create_symlink() {
    local target="$1"
    local link_name="$2"

    if [ -L "$link_name" ]; then
        if [ "$(readlink "$link_name")" == "$target" ]; then
            log_message "Symbolic link $link_name already exists and points to the correct target."
        else
            log_message "Symbolic link $link_name exists but points to a different target. Updating..."
            ln -sf "$target" "$link_name" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
        fi
    elif [ -e "$link_name" ]; then
        log_error "Warning: $link_name already exists as a regular file or directory. Skipping..."
    else
        ln -sf "$target" "$link_name" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
        log_message "Created symbolic link $link_name -> $target"
    fi
}

# Function to install fonts
install_fonts() {
    local directory="$1"

    if [ ! -d "$directory" ]; then
        log_error "Directory not found."
        exit 1
    fi

    log_message "Installing fonts from $directory..."
    mkdir -p "$HOME/.fonts"

    find "$directory" -type f \( -name "*.otf" -o -name "*.ttf" \) -print0 | while IFS= read -r -d '' fontfile; do
        fontname=$(basename "$fontfile")

        if fc-list | grep -q "$fontname"; then
            log_message "Font $fontname is already installed."
        else
            cp "$fontfile" "$HOME/.fonts/" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
            log_message "Installed font: $fontname"
        fi
    done

    log_message "Updating font cache..."
    fc-cache -f -v > /dev/null 2>> "$ERROR_LOG_FILE"
}

# Set up Python environments and create .env files
create_custom_venv dev
create_custom_venv test
create_custom_venv prod

# Install required packages from Arch repos and AUR
install_package "grep" "pacman"
install_package "sed" "pacman"
install_package "wget" "pacman"
install_package "squeekboard" "pacman"
install_package "git" "pacman"
install_package "zsh" "pacman"
install_package "jq" "pacman"
install_package "swaybg" "pacman"
install_package "tmux" "pacman"
install_package "mdcat" "pacman"
install_package "neovim" "pacman"
install_package "waybar" "pacman"
install_package "rofi" "pacman"
install_package "curl" "pacman"
install_package "kitty" "pacman"
install_package "xsel" "pacman"
install_package "zathura" "pacman"
install_package "zathura-cb" "pacman"
install_package "zathura-pdf-mupdf" "pacman"
install_package "feh" "pacman"
install_package "neofetch" "pacman"
install_package "wl-clipboard" "pacman"
install_package "grim" "pacman"
install_package "flameshot" "pacman"
install_package "bat" "pacman"

# Install AUR helper
sudo pacman -S --needed base-devel >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
git clone https://aur.archlinux.org/paru.git >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
cd paru || { log_error "Failed to change directory to paru"; exit 1; }
makepkg -si >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
cd "$HOME" || { log_error "Failed to change directory to $HOME"; exit 1; }

# Install additional packages from AUR
install_package "cava" "paru"
install_package "ruby-colorls" "paru"
install_package "librewolf-bin" "paru"

# Create symbolic links
create_symlink "$HOME/.dotfiles/cava" "$HOME/.config/cava"
create_symlink "$HOME/.dotfiles/scripts" "$HOME/scripts"
create_symlink "$HOME/.dotfiles/file_templates" "$HOME/file_templates"
create_symlink "$HOME/.dotfiles/themes" "$HOME/themes"
create_symlink "$HOME/.dotfiles/mc" "$HOME/.config/mc"
create_symlink "$HOME/.dotfiles/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
create_symlink "$HOME/.dotfiles/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
create_symlink "$HOME/.dotfiles/nvim/init.vim" "$HOME/.config/nvim/init.vim"
create_symlink "$HOME/.dotfiles/.zshrc" "$HOME/.zshrc"
create_symlink "$HOME/.dotfiles/.bashrc" "$HOME/.bashrc"
create_symlink "$HOME/.dotfiles/.bash_aliases" "$HOME/.bash_aliases"
create_symlink "$HOME/.dotfiles/.nanorc" "$HOME/.nanorc"
create_symlink "$HOME/.dotfiles/.tmux" "$HOME/.tmux"
create_symlink "$HOME/.dotfiles/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
create_symlink "$HOME/.dotfiles/themes/onedark/mc/one_dark.ini" "$HOME/.local/share/mc/skins/one_dark.ini"
create_symlink "$HOME/.dotfiles/.p10k.zsh" "$HOME/.p10k.zsh"

# Copy configuration files that require sudo
sudo cp "$HOME/.dotfiles/pacman.conf" /etc/pacman.conf >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"

# Create directories
mkdir -p $HOME/documentation/{best_practice,business_processes,meeting_notes,migration_plans,technical_guides,technical_training,user_guides,workflow} >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
mkdir -p $HOME/learning/{IT,science} >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
mkdir -p $HOME/_tickets/{archive,sample_ticket,change_requests} >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
mkdir -p $HOME/_todo/sample_ticket >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
mkdir -p $HOME/ad_hoc_backups >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
mkdir -p $HOME/ad_hoc_restores >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
mkdir -p $HOME/personal_development/career_plans/{biology,software_dev,data_engineer} >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
mkdir -p $HOME/resources >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
mkdir -p $HOME/keys >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
mkdir -p $HOME/wallpapers/onedark >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
mkdir -p $HOME/software_dev/{prod,test,dev} >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"

# Clone third-party repositories
git clone "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
git clone "https://github.com/Narmis-E/onedark-wallpapers" "$HOME/wallpapers/onedark" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"

# Copy wallpapers
cp -r "$HOME/.dotfiles/themes/onedark/wallpapers/*" "$HOME/wallpapers" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"

# Install Neovim plugin manager
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"

# Make scripts executable
find $HOME/scripts -type f -name "*.sh" -exec chmod +x {} \; >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"

# Install fonts
install_fonts "$HOME/.dotfiles/fonts"

# Change shell to Zsh
chsh -s $(which zsh) >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
