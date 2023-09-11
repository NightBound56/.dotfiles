#!/bin/bash

clone_git_repo() {
    # Check the number of parameters
    if [ "$#" -ne 2 ]; then
        echo "Incorrect number of parameters provided"
        return
    fi

    local repo_url="$1"
    local destination="$2"

    # Check if both parameters are provided
    if [ -z "$repo_url" ] || [ -z "$destination" ]; then
        echo "Incorrect number of parameters provided"
        return
    fi

    # Check if destination contains environment variables and expand them
    destination=$(eval echo "$destination")

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




copy_env_file() {
    # Check if both parameters are provided
    if [ $# -ne 2 ]; then
        echo "Usage: copy_env_file <environment> <destination_directory>"
        return 1
    fi

    local environment="$1"
    local destination_directory="$2"
    
    # Construct the source path based on the environment
    local source_file="$HOME/venvs/${environment}.env"

    # Check if the source file exists
    if [ -f "$source_file" ]; then
        # Copy the source file to the destination directory and rename it to ".env"
        cp "$source_file" "$destination_directory/.env"
        echo "Copied ${environment}.env to $destination_directory as .env"
    else
        echo "Error: ${environment}.env not found in $HOME/venvs."
    fi
}




prep_directories() {
    local dir_path="$1"
    
    if [ -L "$dir_path" ]; then
        # If it's a symbolic link, remove it.
        echo "Removing symbolic link: $dir_path"
        rm "$dir_path"
    elif [ ! -d "$dir_path" ]; then
        # If it doesn't exist, create the directory.
        echo "Creating directory: $dir_path"
        mkdir -p "$dir_path"
    fi
}

# Function to create a symbolic link with the -s argument.
create_symbolic_link() {
    local target="$1"
    local destination="$2"
    
    ln -s "$target" "$destination"
}


dotfiles_dir="$HOME/.dotfiles"



cd $HOME

# Set up python environments and create template .env files.
create_custom_venv dev
create_custom_venv test
create_custom_venv prod
# The template .env files can be copied to the relevant directories. This allows the ZSH plugin autoenv to change environments when CD'ing into the directory.

copy_env_file prod $HOME




sudo pacman -qS grep sed onboard git zsh jq wget tmux mdcat neovim picom i3-wm rofi curl rxvt-unicode urxvt-perls xsel lsd --noconfirm
yay -S betterlockscreen cava --noconfirm --quiet


# create directories for symbolic links (if they dont already exist), if there is already a symbolic link then remove it.
prep_directories "$HOME/.config/i3"
prep_directories "$HOME/.config/cava"
prep_directories "$HOME/.config/dmenu"
prep_directories "$HOME/.config/rofi"
prep_directories "$HOME/.config/polybar"
prep_directories "$HOME/.config/nvim"
prep_directories "$HOME/.config/picom"
prep_directories "$HOME/.config/mpv"
prep_directories "$HOME/scripts"
prep_directories "$HOME/fonts"
prep_directories "$HOME/themes"

#Create symbolic links
ln -s "$dotfiles_dir/themes/onedark/.Xresources" ~/.Xresources
ln -s "$dotfiles_dir/i3/config" ~/.config/i3/config
ln -s "$dotfiles_dir/cava" ~/.config/cava
ln -s "$dotfiles_dir/dmenu" ~/.config/dmenu
ln -s "$dotfiles_dir/rofi/config" ~/.config/rofi/config
ln -s "$dotfiles_dir/polybar/config" ~/.config/polybar/config
ln -s "$dotfiles_dir/nvim/init.vim" ~/.config/nvim/init.vim
ln -s "$dotfiles_dir/picom/picom.conf" ~/.config/picom/picom.conf
ln -s "$dotfiles_dir/mpv/mpv.conf" ~/.config/mpv/mpv.conf
ln -s "$dotfiles_dir/scripts" ~/scripts
ln -s "$dotfiles_dir/fonts" ~/fonts


ln -s "$dotfiles_dir/.zshrc" ~/.zshrc
ln -s "$dotfiles_dir/.bashrc" ~/.bashrc
ln -s "$dotfiles_dir/.bash_aliases" ~/.bash_aliases
ln -s "$dotfiles_dir/.tmux.conf" ~/.tmux.conf
ln -s "$dotfiles_dir/file_templates" ~/file_templates
ln -s "$dotfiles_dir/themes/onedark" ~/themes/onedark

echo "Symbolic links created!"

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
clone_git_repo "https://github.com/zpm-zsh/autoenv" "~/.oh-my-zsh/custom/plugins/autoenv"
clone_git_repo "https://github.com/zsh-users/zsh-syntax-highlighting" "~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
clone_git_repo "https://github.com/zsh-users/zsh-autosuggestions" "~/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
clone_git_repo "https://github.com/zsh-users/zsh-completions" "~/.oh-my-zsh/custom/plugins/zsh-completions"
# Clone in wallpapers for onedark theme
clone_git_repo "https://github.com/Narmis-E/onedark-wallpapers" "~/wallpapers"

# nvim plugin manager
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

#Make scripts executable
find $HOME/scripts -type f -name "*.sh" -exec chmod +x {} \;


# install fonts
directory="$HOME/fonts"; if [ ! -d "$directory" ]; then echo "Error: Directory not found."; exit 1; fi; echo "Installing fonts from $directory..."; mkdir -p "$HOME/.fonts"; find "$directory" -type f \( -name "*.otf" -o -name "*.ttf" \) -print0 | while IFS= read -r -d '' fontfile; do fontname=$(basename "$fontfile"); if fc-list | grep -q "$fontname"; then echo "Font $fontname is already installed."; else cp "$fontfile" "$HOME/.fonts/"; echo "Installed font: $fontname"; fi; done; echo "Updating font cache..."; fc-cache -f -v; echo "Font installation complete."

# this avoids tracking username details in the Xresources file during commit. Aim was to create a symbolic link to a theme based file, but urxvt had issues with env vars.

# Update terminal
xrdb -merge ~/.Xresources

#Clone Powerlevel 10k and add it the to symlinked .zshrc.
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
