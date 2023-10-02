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






create_symbolic_link() {
  source_path=$(readlink -f "$1")
  dest_path=$(readlink -f "$2")

  # Check if source exists
  if [ ! -e "$source_path" ]; then
    echo "Error: Source '$1' does not exist."
    return 1
  fi

  # Check if source is a symbolic link and remove it
  if [ -L "$source_path" ]; then
    rm "$source_path"
    echo "Removed existing symbolic link: $source_path"
  fi

  # Extract directory path from destination and create if not exists
  dest_dir=$(dirname "$dest_path")
  mkdir -p "$dest_dir"

  # Check if source and destination are the same
  if [ "$source_path" == "$dest_path" ]; then
    echo "$source_path"
    echo "Error: Source and destination are the same. Symbolic link not created."
    return 1
  fi

  # Check for indirect self-referencing through symbolic links
  if [[ -n $(find "$dest_path" -type l -samefile "$source_path") ]]; then
    echo "$source_path"
    echo "Error: Symbolic link creates an indirect self-reference. Not created."
    return 1
  fi

  # Create symbolic link
  ln -s "$source_path" "$dest_path"
  echo "Symbolic link created: $source_path -> $dest_path"
}



dotfiles_dir="$HOME/.dotfiles"

cd $HOME

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
    # Install the package without sudo for yay
    if [ "$package_manager" = "yay" ]; then
	  "Installing ................ $package_name"
      "$package_manager" -S --noconfirm "$package_name"
	  echo ""
    elif [ "$package_manager" = "pacman" ]; then
      # For pacman, use sudo
      "Installing ................ $package_name"
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
install_package "onboard" "pacman"
install_package "git" "pacman"
install_package "zsh" "pacman"
install_package "jq" "pacman"
install_package "wget" "pacman"
install_package "tmux" "pacman"
install_package "mdcat" "pacman"
install_package "neovim" "pacman"
install_package "picom" "pacman"
install_package "i3-wm" "pacman"
install_package "rofi" "pacman"
install_package "curl" "pacman"
install_package "kitty" "pacman"
install_package "xsel" "pacman"
install_package "zathura" "pacman"
install_package "zathura-cb" "pacman"
install_package "zathura-pdf-mupdf" "pacman"
install_package "feh" "pacman"
install_package "neofetch" "pacman"

install_package "betterlockscreen" "yay"
install_package "cava" "yay"
install_package "ruby-colorls" "yay" 


#Create symbolic links for directories
create_symbolic_link "$dotfiles_dir/i3" ~/.config/i3 #tiling window manager multiple virtual desktops with apps opening on them by default.
create_symbolic_link "$dotfiles_dir/cava" ~/.config/cava #terminal audio visualisation, needs more work.
create_symbolic_link "$dotfiles_dir/dmenu" ~/.config/dmenu #terminal based launcher for apps
create_symbolic_link "$dotfiles_dir/scripts" ~/scripts #script library
create_symbolic_link "$dotfiles_dir/file_templates" ~/file_templates #using neovim as an editor the are default template files used each time I scaffold a file.
create_symbolic_link "$dotfiles_dir/themes" ~/themes


#Create symbolic links for files
create_symbolic_link "$dotfiles_dir/rofi/config" ~/.config/rofi/config #alternative to dmenu
#create_symbolic_link "$dotfiles_dir/polybar/config" ~/.config/polybar/config #tiny menubar showing system stats and results of scripts.
create_symbolic_link "$dotfiles_dir/nvim/init.vim" ~/.config/nvim/init.vim #neonim config
create_symbolic_link "$dotfiles_dir/picom/picom.conf" ~/.config/picom/picom.conf #display manager for i3
#create_symbolic_link "$dotfiles_dir/mpv/mpv.conf" ~/.config/mpv/mpv.conf #movie player
create_symbolic_link "$dotfiles_dir/.zshrc" ~/.zshrc # zsh/oh-my-zsh/powerline10k config file
create_symbolic_link "$dotfiles_dir/.bashrc" ~/.bashrc # basic bash shell if i need to revert from zsh
create_symbolic_link "$dotfiles_dir/.bash_aliases" ~/.bash_aliases #used for both bash and zsh for short hand commands
create_symbolic_link "$dotfiles_dir/.tmux.conf" ~/.tmux.conf #terminal multiplexer - mostly specifies keybindings for terminal management, split screens etc.
create_symbolic_link "$dotfiles_dir/kitty/kitty.conf" ~/.config/kitty/kitty.conf

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
mkdir -p $HOME/wallapers
mkdir -p $HOME/software_dev/prod
mkdir -p $HOME/software_dev/test
mkdir -p $HOME/software_dev/dev

# grab repo's and scripts from third parties
clone_git_repo "https://github.com/tmux-plugins/tpm" "~/.tmux/plugins/tpm"

# ZSH plugins
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
clone_git_repo "https://github.com/zsh-users/zsh-syntax-highlighting" "~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
clone_git_repo "https://github.com/zsh-users/zsh-autosuggestions" "~/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
clone_git_repo "https://github.com/zsh-users/zsh-completions" "~/.oh-my-zsh/custom/plugins/zsh-completions"
clone_git_repo "https://github.com/Narmis-E/onedark-wallpapers" "~/wallpapers"

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