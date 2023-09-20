
# color ls
alias ls='ls --color=auto'
# color grep
alias grep='grep --color=auto'


#Find file recursively
alias f='find . |grep --color=auto '

# Show hidden files
alias l.='ls -d .* --color=auto'
# Diff color
alias diff='diff --color=auto'
#Todays date
alias nowdate='date +"%d-%m-%Y"'

# System management
alias reboot='sudo /sbin/reboot'
alias poweroff='sudo /sbin/poweroff'
alias halt='sudo /sbin/halt'
alias shutdown='sudo /sbin/shutdown'

#File conversion ffmpeg

#Media server

#Sort by file size
alias lt='ls --human-readable --size -1 -S --classify'

#Sort by file modification date
alias left='ls -t -1'

# Count of files
alias count='find . -type f | wc -l'

# use rsync to copy files as it shows progress
alias cpv='rsync -ah --info=progress2'

# Pac-Man cleanup and yay cleanup

# CD to folders
alias desk="cd ~/Desktop"
alias down="cd ~/Downloads"

#Clipboard management:
alias xc='xclip -selection clipboard -i ' #To write to Clipboard
alias clipboard='xclip -selection "clipboard" -o' #To read from Clipboard

# open programs
alias o='xdg-open'

alias med="sh ~/scripts/listMedia.sh"
alias upg="sudo pacman -Syyuu && yay -Syyuu"
alias mediaserv="minidlnad -f /home/$USER/.config/minidlna.conf - P /home/$USER/.config/minidlna.pid -d"
alias ls='lsd'
alias shreddir="./$HOME/scripts/shred.sh shred_dir"
