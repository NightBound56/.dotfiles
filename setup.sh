#!/bin/bash

# Function to clone a Git repository
clone_git_repo() {
    if [ "$#" -ne 2 ]; then
        echo "Incorrect number of parameters provided"
        return
    fi

    local repo_url="$1"
    local destination="$2"
    destination=$(eval echo "$destination")
    local repo_name
    repo_name=$(basename "$repo_url" .git)

    echo "Repository name: $repo_name"

    if [ -d "$destination" ]; then
        if [ -d "$destination/.git" ]; then
            cd "$destination" || return
            git pull
            echo "The existing repo was updated using a pull"
        else
            echo "The destination had a folder with the same name as the repo, clone aborted."
        fi
    else
        git clone "$repo_url" "$destination"
        echo "The repo cloned successfully."
    fi
}

# Function to create a custom Python virtual environment
create_custom_venv() {
    local environment_name="$1"
    local venv_dir="$HOME/venvs"
    local venv_path="$venv_dir/$environment_name"
    local env_file="$venv_path/.env"

    if [ -d "$venv_path" ]; then
        echo "Virtual environment '$environment_name' already exists."
    else
        echo "Creating a new virtual environment '$environment_name'..."
        python -m venv "$venv_path"
        echo "Virtual environment '$environment_name' created in '$venv_dir'."

        echo "export VIRTUAL_ENV=\"$venv_path\"" > "$env_file"
        echo "export PATH=\"\$VIRTUAL_ENV/bin:\$PATH\"" >> "$env_file"
        echo "Virtual environment path added to '$env_file'."
    fi
}

# Function to install a package using the appropriate package manager
install_package() {
    local package_name="$1"
    local package_manager="$2"

    echo "Processing $package_name."

    if "$package_manager" -Qq "$package_name" &>/dev/null; then
        echo "$package_name is already installed."
    else
        if [ "$package_manager" = "yay" ] || [ "$package_manager" = "paru" ]; then
            "$package_manager" -S --noconfirm "$package_name"
        elif [ "$package_manager" = "pacman" ]; then
            sudo "$package_manager" -S --noconfirm "$package_name"
        else
            echo "Unsupported package manager: $package_manager"
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
            echo "Symbolic link $link_name already exists and points to the correct target."
        else
            echo "Symbolic link $link_name exists but points to a different target. Updating..."
            ln -sf "$target" "$link_name"
        fi
    elif [ -e "$link_name" ]; then
        echo "Warning: $link_name already exists as a regular file or directory. Skipping..."
    else
        ln -sf "$target" "$link_name"
        echo "Created symbolic link $link_name -> $target"
    fi
}

# Function to install fonts
install_fonts() {
    local directory="$1"

    if [ ! -d "$directory" ]; then
        echo "Error: Directory not found."
        exit 1
    fi

    echo "Installing fonts from $directory..."
    mkdir -p "$HOME/.fonts"

    find "$directory" -type f \( -name "*.otf" -o -name "*.ttf" \) -print0 | while IFS= read -r -d '' fontfile; do
        fontname=$(basename "$fontfile")

        if fc-list | grep -q "$fontname"; then
            echo "Font $fontname is already installed."
        else
            cp "$fontfile" "$HOME/.fonts/"
            echo "Installed font: $fontname"
        fi
    done

    echo "Updating font cache..."
    fc-cache -f -v > /dev/null 2>&1
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
#sudo pacman -S --needed base-devel
#git clone https://aur.archlinux.org/paru.git
#cd paru
#makepkg -si
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
yay -Y --gendb
yay -Syu --devel
yay -Y --devel --save

cd $HOME

# Install additional packages from AUR
install_package "cava" "yay"
install_package "ruby-colorls" "yay"
install_package "librewolf-bin" "yay"

# Create symbolic links
create_symlink "$HOME/.dotfiles/cava" "$HOME/.config/cava"
create_symlink "$HOME/.dotfiles/scripts" "$HOME/scripts"
create_symlink "$HOME/.dotfiles/file_templates" "$HOME/file_templates"
create_symlink "$HOME/.dotfiles/themes" "$HOME/themes"
create_symlink "$HOME/.dotfiles/mc" "$HOME/.config/mc"
create_symlink "$HOME/.dotfiles/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
create_symlink "$HOME/.dotfiles/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
create_symlink "$HOME/.dotfiles/nvim/init.vim" "$HOME/.config/nvim/init.vim"
create_symlink "$HOME/.dotfiles/.bashrc" "$HOME/.bashrc"
create_symlink "$HOME/.dotfiles/.bash_aliases" "$HOME/.bash_aliases"
create_symlink "$HOME/.dotfiles/.nanorc" "$HOME/.nanorc"
create_symlink "$HOME/.dotfiles/.tmux" "$HOME/.tmux"
create_symlink "$HOME/.dotfiles/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
create_symlink "$HOME/.dotfiles/themes/onedark/mc/one_dark.ini" "$HOME/.local/share/mc/skins/one_dark.ini"
create_symlink "$HOME/.dotfiles/.p10k.zsh" "$HOME/.p10k.zsh"

# Copy configuration files that require sudo
sudo cp "$HOME/.dotfiles/pacman.conf" /etc/pacman.conf

# Create directories
mkdir -p $HOME/documentation/{best_practice,business_processes,meeting_notes,migration_plans,technical_guides,technical_training,user_guides,workflow}
mkdir -p $HOME/learning/{IT,science}
mkdir -p $HOME/_tickets/{archive,sample_ticket,change_requests}
mkdir -p $HOME/_todo/sample_ticket
mkdir -p $HOME/ad_hoc_backups
mkdir -p $HOME/ad_hoc_restores
mkdir -p $HOME/personal_development/career_plans/{biology,software_dev,data_engineer}
mkdir -p $HOME/resources
mkdir -p $HOME/keys
mkdir -p $HOME/wallpapers/onedark
mkdir -p $HOME/software_dev/{prod,test,dev}

# Clone third-party repositories
git clone "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"
git clone "https://github.com/Narmis-E/onedark-wallpapers" "$HOME/wallpapers/onedark"

# Copy wallpapers
cp -r "$HOME/.dotfiles/themes/onedark/wallpapers/*" "$HOME/wallpapers"

# Install Neovim plugin manager
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# Make scripts executable
find $HOME/scripts -type f -name "*.sh" -exec chmod +x {} \;

# Install fonts
install_fonts "$HOME/.dotfiles/fonts"

# Change shell to Zsh
chsh -s $(which zsh)

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions


git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

create_symlink "$HOME/.dotfiles/.zshrc" "$HOME/.zshrc"
