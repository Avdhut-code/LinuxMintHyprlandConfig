# this is from my .bashrc idk its use but its here
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#start this incase you want you have fastfetch show up at each time opening of an terminla window
# if command -v fastfetch >/dev/null 2>&1; then
#    fastfetch
#    printf "\e[1A"
# fi

# # env's for walk configuration/customization
# export EDITOR=nvim
# export WALK_MAIN_COLOR="#5a5b5e"
# export WALK_STATUS_BAR='[Mode(), Owner(), Size() | PadLeft(7), ModTime() | PadLeft(12)] | join(" ")'

# function lk {
#   cd "$(walk "$@")"
# }

function get_bright() {
    sudo ddcutil --bus 2 getvcp 10 | grep -oP 'current value =\s+\K\d+'
}
export BRIGHTNESS=$(get_bright)

# system tools needed env's
export CURRENT_WALLPAPER="wallpaper/wall1.png"

# default file for codecho tool
export DEFAULT_FILE=""

# minimal teminal bar in purpule color
PS1=' \[\033[38;5;141m\]\w >\[\033[0m\] ' 

alias ~="cd ~"

alias ..="cd .."

