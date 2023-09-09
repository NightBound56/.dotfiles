export ZSH="$HOME/.oh-my-zsh"


ZSH_THEME="agnoster"

# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode auto      # update automatically without asking

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 31

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh-completions
  autoenv
  command-not-found
  emoji
  tmux
  ufw
)

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi

if [[ -z "$VIRTUAL_ENV" ]]; then
    source "$HOME/venvs/prod/bin/activate"
fi


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


