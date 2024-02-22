if [ -e $HOME/.bash_aliases ]; then
    source $HOME/.bash_aliases
fi
export TERMINAL=urxvt

export MANPAGER="less -R --use-color -Dd+r -Du+b"
export MANROFFOPT="-P -c"
export EDITOR=nvim
