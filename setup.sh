#!/bin/bash

clone_git_repo() {
    # Check the number of parameters
    if [ "$#" -ne 2 ]; then
        echo "Incorrect number of parameters provided"
        return
    fi

    local repo_url="$1"
    local destination="$2"

    # Check if destination contains environment variables and expand them
    destination=$(eval echo "$destination")

    # Extract the repository name from the URL
    local repo_name
    repo_name=$(basename "$repo_url" .git)

    # Echo the repository name
    echo "Repository name: $repo_name"

    # Check if the destination directory exists
    if [ -d "$destination" ]; then
        # Check if it's a Git repository
        if [ -d "$destination/.git" ]; then
            # Update the existing repository using git pull
            cd "$destination" || return
            git pull
            echo "The existing repo was updated using a pull"
        else
            echo "The destination had a folder with the same name as the repo, clone aborted."
        fi
    else
        # Clone the Git repository to the destination
        git clone "$repo_url" "$destination"
        echo "The repo cloned successfully."
    fi
}

create_custom_venv() {
    local environment_name="$1"
    local venv_dir="$HOME/venvs"
    local venv_path="$venv_dir/$environment_name"
    local env_file="$venv_path/.env"

    # Check if the virtual environment already exists
    if [ -d "$venv_path" ]; then
        echo "Virtual environment '$environment_name' already exists."
    else
        echo "Creating a new virtual environment '$environment_name'..."
        python -m venv "$venv_path"  # Create a new virtual environment
        echo "Virtual environment '$environment_name' created in '$venv_dir'."

        # Create .env file with the virtual environment path
        echo "export VIRTUAL_ENV=\"$venv_path\"" > "$env_file"
        echo "export PATH=\"\$VIRTUAL_ENV/bin:\$PATH\"" >> "$env_file"
        echo "Virtual environment path added to '$env_file'."
    fi
}




dotfiles_dir="$HOME/.dotfiles"



# Set up python environments and create template .env files.
create_custom_venv dev
create_custom_venv test
create_custom_venv prod
# The template .env files can be copied to the relevant directories. This allows the ZSH plugin autoenv to change environments when CD'ing into the directory.


install_package() {
  local package_name="$1"
  local package_manager="$2"

  echo "Processing $package_name."

  # Check if the package is already installed
  if "$package_manager" -Qq "$package_name" &>/dev/null; then
    echo "$package_name ................is already installed."
    echo ""
  else
    # Install the package without sudo for yay and paru
    if [ "$package_manager" = "yay" ] || [ "$package_manager" = "paru" ]; then
      echo "Installing ................ $package_name"
      "$package_manager" -S --noconfirm "$package_name"
      echo ""
    elif [ "$package_manager" = "pacman" ]; then
      # For pacman, use sudo
      echo "Installing ................ $package_name"
      sudo "$package_manager" -S --noconfirm "$package_name"
      echo ""
    else
      echo "Unsupported package manager: $package_manager"
      echo ""
      return 1
    fi
  fi
}



#install required packages for ricing both from arch repos and AUR
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


#add aur helper - reliant on bat for color output
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

cd $HOME

#install_package "betterlockscreen" "paru"
install_package "cava" "paru"
install_package "ruby-colorls" "paru"
install_package "librewolf-bin" "paru"



#Create symbolic links for directories
ln -sf "$HOME/.dotfiles/cava" ~/.config/cava
ln -sf "$HOME/.dotfiles/scripts" ~/scripts
ln -sf "$HOME/.dotfiles/file_templates" ~/file_templates
ln -sf "$HOME/.dotfiles/themes" ~/themes
ln -sf "$HOME/.dotfiles/mc" ~/.config/mc


#Prep config folders for sym links if software not yet installed:
mkdir -p ~/.config/rofi/
mkdir -p ~/.config/hypr/
mkdir -p ~/.config/nvim/
mkdir -p ~/.config/kitty/
mkdir -p ~/.local/share/mc/skins/


#Create symbolic links for files
ln -sf "$HOME/.dotfiles/rofi/config.rasi" ~/.config/rofi/config.rasi
ln -sf "$HOME/.dotfiles/hypr/hyprland.conf" ~/.config/hypr/hyprland.conf
ln -sf "$HOME/.dotfiles/nvim/init.vim" ~/.config/nvim/init.vim
ln -sf "$HOME/.dotfiles/.zshrc" ~/.zshrc
ln -sf "$HOME/.dotfiles/.bashrc" ~/.bashrc
ln -sf "$HOME/.dotfiles/.bash_aliases" ~/.bash_aliases
ln -sf "$HOME/.dotfiles/.nanorc" ~/.nanorc
ln -sf "$HOME/.dotfiles/.tmux" ~/.tmux
ln -sf "$HOME/.dotfiles/kitty/kitty.conf" ~/.config/kitty/kitty.conf
ln -sf "$HOME/.dotfiles/themes/onedark/mc/one_dark.ini" ~/.local/share/mc/skins/one_dark.ini
ln -sf "$HOME/.dotfiles/.p10k.zsh" ~/.p10k.zsh

#sudo cp -r "$HOME/.dotfiles/themes/onedark/onboard" /usr/share/onboard/themes
sudo cp "$HOME/.dotfiles/pacman.conf" /etc/pacman.conf



# Make workflow folders if they dont already exist. These dont point to config files in the git repo.
mkdir -p $HOME/documentation/best_practice
mkdir -p $HOME/documentation/business_processes
mkdir -p $HOME/documentation/meeting_notes
mkdir -p $HOME/documentation/migration_plans
mkdir -p $HOME/documentation/technical_guides
mkdir -p $HOME/documentation/technical_training
mkdir -p $HOME/documentation/user_guides
mkdir -p $HOME/documentation/workflow
mkdir -p $HOME/learning/IT/
mkdir -p $HOME/learning/science
mkdir -p $HOME/_tickets/archive
mkdir -p $HOME/_tickets/sample_ticket
mkdir -p $HOME/_tickets/change_requests
mkdir -p $HOME/_todo/sample_ticket
mkdir -p $HOME/ad_hoc_backups
mkdir -p $HOME/ad_hoc_restores
mkdir -p $HOME/personal_development/career_plans/biology
mkdir -p $HOME/personal_development/career_plans/software_dev
mkdir -p $HOME/personal_development/career_plans/data_engineer
mkdir -p $HOME/resources
mkdir -p $HOME/keys
mkdir -p $HOME/wallpapers/onedark
mkdir -p $HOME/software_dev/prod
mkdir -p $HOME/software_dev/test
mkdir -p $HOME/software_dev/dev


# grab repo's and scripts from third parties
git clone "https://github.com/tmux-plugins/tpm" "~/.tmux/plugins/tpm"

# ZSH plugins

git clone "https://github.com/Narmis-E/onedark-wallpapers" ~/wallpapers/onedark

#Move across workspace, random and seasonal wallpapers, one dark wallpapers are a seperate directory cloned from a repo below
cp -r "$HOME/.dotfiles/themes/onedark/wallpapers/*" ~/wallpapers


# nvim plugin manager
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'



#Make scripts executable
find $HOME/scripts -type f -name "*.sh" -exec chmod +x {} \;


# install fonts
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

echo "Installation complete."


chsh -s $(which zsh)


sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Powerlevel 10k ZSH theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone "https://github.com/zsh-users/zsh-syntax-highlighting" ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone "https://github.com/zsh-users/zsh-autosuggestions" ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone "https://github.com/zsh-users/zsh-completions" ~/.oh-my-zsh/custom/plugins/zsh-completions



