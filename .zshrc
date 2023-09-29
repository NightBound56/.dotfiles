
export ZSH="$HOME/.oh-my-zsh"

# Set your ZSH_THEME after sourcing the Powerlevel10k theme.
ZSH_THEME="robbyrussell"


zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' frequency 31

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi


# Always set python environment to be production by default, that way python wont conflict with package managers.
if [[ -z "$VIRTUAL_ENV" ]]; then
    source "$HOME/venvs/prod/bin/activate"
fi

# Change to different python environments depending on folder.
function cd() {
    # Store the current theme.
    local current_theme="$ZSH_THEME"

    builtin cd "$@"  # This ensures the normal 'cd' behavior.

    # Define your virtual environment activation based on directory path.
    case "$(pwd)" in
        "$HOME" | "$HOME/Downloads" | "$HOME/.config")
            source "$HOME/venvs/prod/bin/activate" # Change to your desired virtual environment path.
            ;;
        "$HOME/software_dev/prod")
            source "$HOME/venvs/prod/bin/activate"
            ;;
        "$HOME/software_dev/dev")
            source "$HOME/venvs/dev/bin/activate"
            ;;
        "$HOME/software_dev/test")
            source "$HOME/venvs/test/bin/activate"
            ;;
        *)
            source "$HOME/venvs/prod/bin/activate" # Default virtual environment.
            ;;
    esac

    # Restore the original theme.
    ZSH_THEME="$current_theme"
}

#If a bash alias file is present then use it.
if [ -e $HOME/.bash_aliases ]; then
    source $HOME/.bash_aliases
fi


# Default terminal
export TERMINAL=urxvt

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh-completions
  command-not-found
  emoji
  tmux
  ufw
)

# Set lang
export LANG=en_GB.UTF-8

# Add color theme
export MANPAGER="less -R --use-color -Dd+r -Du+b"
export MANROFFOPT="-P -c"
eval $(dircolors $HOME/themes/onedark/onedark_ls_colors)

# Add ZSH source again, if so why?
source $ZSH/oh-my-zsh.sh