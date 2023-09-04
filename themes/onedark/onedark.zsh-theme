# ~/.oh-my-zsh/themes/onedark.zsh-theme

PROMPT='
%{$fg_bold[cyan]%}➜ %{$fg_bold[blue]%}%n %{$fg_bold[cyan]%}on %{$reset_color%}%m %{$fg_bold[yellow]%}in %{$fg_bold[green]%}%~ %{$fg_bold[cyan]%}at %{$reset_color%}%D{%T}
%{$fg_bold[cyan]%}→%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg_bold[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg_bold[red]%}) %{$fg_bold[blue]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[red]%})"

ZSH_THEME_GIT_PROMPT_ADDED="%{$fg_bold[green]%}✚"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg_bold[yellow]%}⚑"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg_bold[red]%}✖"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg_bold[magenta]%}➜"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[cyan]%}§"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[blue]%}…"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg_bold[blue]%}⇡"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg_bold[blue]%}⇣"
ZSH_THEME_GIT_PROMPT_DIVERGED="%{$fg_bold[cyan]%}⇕"

ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}●"
ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg_bold[red]%}✖"
ZSH_THEME_GIT_PROMPT_STASHED="%{$fg_bold[magenta]%}⚑"
ZSH_THEME_GIT_PROMPT_REMOTE=""

# Colors from onedark color scheme
ZSH_THEME_COLOR_BLUE="%{$fg_bold[blue]%}"
ZSH_THEME_COLOR_RED="%{$fg_bold[red]%}"
ZSH_THEME_COLOR_YELLOW="%{$fg_bold[yellow]%}"
ZSH_THEME_COLOR_GREEN="%{$fg_bold[green]%}"
ZSH_THEME_COLOR_CYAN="%{$fg_bold[cyan]%}"
ZSH_THEME_COLOR_MAGENTA="%{$fg_bold[magenta]%}"
ZSH_THEME_COLOR_BLACK="%{$fg_bold[black]%}"
ZSH_THEME_COLOR_WHITE="%{$fg_bold[white]%}"

ZSH_THEME_COLOR_RESET="%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$ZSH_THEME_COLOR_RED%}✖"
ZSH_THEME_GIT_PROMPT_STASHED="%{$ZSH_THEME_COLOR_MAGENTA%}⚑"

ZSH_THEME_GIT_PROMPT_CLEAN="%{$ZSH_THEME_COLOR_GREEN%})"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$ZSH_THEME_COLOR_RED%})"
