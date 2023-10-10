# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


export ZSH="$HOME/.oh-my-zsh"

# Set your ZSH_THEME after sourcing the Powerlevel10k theme.
# ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"

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


#If a bash alias file is present then use it.
if [ -e $HOME/.bash_aliases ]; then
    source $HOME/.bash_aliases
fi


# Default terminal
export TERMINAL=kitty

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh-completions
  command-not-found
  emoji
  tmux
  ufw
  web-search
)

# Set lang
export LANG=en_GB.UTF-8

# Add color theme
export MANPAGER="less -R --use-color -Dd+r -Du+b"
export MANROFFOPT="-P -c"
eval $(dircolors $HOME/themes/onedark/onedark_ls_colors)

# Add ZSH source again, if so why?
source $ZSH/oh-my-zsh.sh



# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh