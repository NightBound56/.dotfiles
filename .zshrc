# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source ~/powerlevel10k/powerlevel10k.zsh-theme

# Set your ZSH_THEME after sourcing the Powerlevel10k theme.
ZSH_THEME="powerlevel10k/powerlevel10k"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi

if [[ -z "$VIRTUAL_ENV" ]]; then
    source "$HOME/venvs/prod/bin/activate"
fi

# Move any commands that perform console I/O after the instant prompt preamble
# to a later part of the file to avoid conflicts with instant prompt.

# The following lines perform console I/O and should be moved down
# to a later part of the file:

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

if [ -e $HOME/.bash_aliases ]; then
    source $HOME/.bash_aliases
fi

eval $(dircolors $HOME/themes/onedark/onedark_ls_colors)
export TERMINAL=urxvt
