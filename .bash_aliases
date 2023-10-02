
# color ls
alias ls='ls --color=auto '
# color grep
alias grep='grep --color=auto '


#Find file recursively
alias f='find . |grep --color=auto '

# Show hidden files
alias l.='ls -d .* --color=auto '
# Diff color
alias diff='diff --color=auto '
#Todays date
alias nowdate='date +"%d-%m-%Y"'

# System management
alias reboot='sudo /sbin/reboot'
alias poweroff='sudo /sbin/poweroff'
alias halt='sudo /sbin/halt'
alias shutdown='sudo /sbin/shutdown'
alias shutdownt="$HOME/scripts/./library.sh -f delayed_shutdown -a "
#File conversion ffmpeg

#Media server

#Sort by file size
alias lt='ls --human-readable --size -1 -S --classify'

#Sort by file modification date
alias left='ls -t -1'

# Count of files
alias count='find . -type f | wc -l'

# use rsync to copy files as it shows progress
alias cpv='rsync -ah --info=progress2 '

# CD to folders
alias desk="cd ~/Desktop"
alias down="cd ~/Downloads"

# open programs
alias o='xdg-open'

alias upg="sudo pacman -Syyuu && yay -Syyuu"
alias mediaserv="minidlnad -f /$HOME/.config/minidlna.conf - P /$HOME/.config/minidlna.pid -d"
alias ls='lsd'
alias shreddir="$HOME/scripts/./library.sh -f shred_dir -a "
alias pvprod="source \"$HOME/venvs/prod/bin/activate\""
alias pvdev="source \"$HOME/venvs/dev/bin/activate\""
alias pvtest="source \"$HOME/venvs/test/bin/activate\""
