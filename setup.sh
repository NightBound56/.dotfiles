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
            env_file="$venv_dir/$environment_name/.env"
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

cd $HOME

# Set up python environments and create template .env files
create_custom_venv dev
create_custom_venv test
create_custom_venv prod

sudo pacman -S onboard git zsh jq wget tmux mdcat neovim picom i3-wm rofi curl rxvt-unicode urxvt-perls xsel lsd -y
yay -S betterlockscreen cava
# Dot files path
dotfiles_dir="$HOME/.dotfiles"

# i3-gaps
ln -s "$dotfiles_dir/i3/config" ~/.config/i3/config

# Shells
ln -s "$dotfiles_dir/.zshrc" ~/.zshrc
ln -s "$dotfiles_dir/.bashrc" ~/.bashrc


# Aliasing
ln -s "$dotfiles_dir/.bash_aliases" ~/.bash_aliases

# Cava
ln -s "$dotfiles_dir/cava" ~/.config/cava

# Dmenu
ln -s "$dotfiles_dir/dmenu" ~/.config/dmenu

# Dmenu
ln -s "$dotfiles_dir/fonts" ~/fonts

# Scripts
ln -s "$dotfiles_dir/scripts" ~/scripts

# Scripts
ln -s "$dotfiles_dir/themes" ~/themes

# Tmux
ln -s "$dotfiles_dir/.tmux.conf" ~/.tmux.conf

# Rofi
ln -s "$dotfiles_dir/rofi/config" ~/.config/rofi/config

# Polybar
ln -s "$dotfiles_dir/polybar/config" ~/.config/polybar/config

# Neovim
ln -s "$dotfiles_dir/nvim/init.vim" ~/.config/nvim/init.vim

# urxvt
ln -s "$dotfiles_dir/.Xresources" ~/.Xresources

# Picom
ln -s "$dotfiles_dir/picom/picom.conf" ~/.config/picom/picom.conf

# mpv
ln -s "$dotfiles_dir/mpv/mpv.conf" ~/.config/mpv/mpv.conf

# File templates for neovim
ln -s "$dotfiles_dir/file_templates" ~/file_templates

echo "Symbolic links created!"

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

git clone https://github.com/tmux-plugins/tpm "$HOME/.config"/tmux/.tmux/plugins/tpm
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zpm-zsh/autoenv ~/.oh-my-zsh/custom/plugins/autoenv
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions

# nvim plugin manager
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

#Make scripts executable
find $HOME/scripts -type f -name "*.sh" -exec chmod +x {} \;

# Update terminal after symlinking config.
xrdb -merge ~/.Xresources

# install fonts
directory="$HOME/fonts"; if [ ! -d "$directory" ]; then echo "Error: Directory not found."; exit 1; fi; echo "Installing fonts from $directory..."; mkdir -p "$HOME/.fonts"; find "$directory" -type f \( -name "*.otf" -o -name "*.ttf" \) -print0 | while IFS= read -r -d '' fontfile; do fontname=$(basename "$fontfile"); if fc-list | grep -q "$fontname"; then echo "Font $fontname is already installed."; else cp "$fontfile" "$HOME/.fonts/"; echo "Installed font: $fontname"; fi; done; echo "Updating font cache..."; fc-cache -f -v; echo "Font installation complete."
