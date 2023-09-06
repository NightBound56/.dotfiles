#!/bin/bash
create_custom_venv() {
    environment_name="$1"
    venv_dir="$HOME/venvs"

    if [ -z "$environment_name" ]; then
        echo "Please provide an environment name as a parameter."
        return 1
    fi

    # Check if Python is installed and venv module is available
    if command -v python &> /dev/null && python -c "import venv" &> /dev/null; then
        # Check if the named virtual environment directory exists within the custom directory
        if [ ! -d "$venv_dir/$environment_name" ]; then
            # Create the named virtual environment within the custom directory
            python -m venv "$venv_dir/$environment_name"
            echo "Virtual environment '$environment_name' created in $venv_dir."
            
            # Create .env file with environment path
            env_file="$venv_dir/$environment_name.env"
            echo "VIRTUAL_ENV=$venv_dir/$environment_name" > "$env_file"
            echo "Activated by autoenv" >> "$env_file"
            
            echo "Environment path saved in $env_file."
        else
            echo "Virtual environment '$environment_name' already exists in $venv_dir."
        fi
    else
        echo "Python is not installed or venv module is unavailable. Please check your setup."
        return 1
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




sudo pacman -S onboard git zsh jq wget tmux mdcat neovim picom i3-wm rofi curl rxvt-unicode urxvt-perls xsel lsd --noconfirm
yay -S betterlockscreen cava --noconfirm


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
ln -s "$dotfiles_dir/themes" ~/themes

ln -s "$dotfiles_dir/.zshrc" ~/.zshrc
ln -s "$dotfiles_dir/.bashrc" ~/.bashrc
ln -s "$dotfiles_dir/.bash_aliases" ~/.bash_aliases
ln -s "$dotfiles_dir/.tmux.conf" ~/.tmux.conf
ln -s "$dotfiles_dir/.Xresources" ~/.Xresources
ln -s "$dotfiles_dir/file_templates" ~/file_templates

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
mkdir -p $HOME/learning/IT
mkdir -p $HOME/learning/science
mkdir -p $HOME/_tickets/archive
mkdir -p $HOME/_tickets/personal_projects
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

# grab repo's and scripts from third parties
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# ZSH plugins
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zpm-zsh/autoenv ~/.oh-my-zsh/custom/plugins/autoenv
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
# Clone in wallpapers for onedark theme
git clone https://github.com/Narmis-E/onedark-wallpapers ~/wallpapers

# nvim plugin manager
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

#Make scripts executable
find $HOME/scripts -type f -name "*.sh" -exec chmod +x {} \;

# Update terminal after symlinking config.
xrdb -merge ~/.Xresources

# install fonts
directory="$HOME/fonts"; if [ ! -d "$directory" ]; then echo "Error: Directory not found."; exit 1; fi; echo "Installing fonts from $directory..."; mkdir -p "$HOME/.fonts"; find "$directory" -type f \( -name "*.otf" -o -name "*.ttf" \) -print0 | while IFS= read -r -d '' fontfile; do fontname=$(basename "$fontfile"); if fc-list | grep -q "$fontname"; then echo "Font $fontname is already installed."; else cp "$fontfile" "$HOME/.fonts/"; echo "Installed font: $fontname"; fi; done; echo "Updating font cache..."; fc-cache -f -v; echo "Font installation complete."
