# === HYPRLAND CONFIG START ===

# Point to the permanent dotfiles suite location
export TARGET_DIR="$HOME/.local/share/LinuxMintHyprlandConfig/"

# Uncomment if you want to show neofetch on terminal intitalization/opening
#if command -v neofetch >/dev/null 2>&1; then
#    neofetch
#    printf "\e[1A"
#fi

# env's for walk configuration/customization
export EDITOR=vim
export WALK_MAIN_COLOR="#5a5b5e"
export WALK_STATUS_BAR='[Mode(), Owner(), Size() | PadLeft(7), ModTime() | PadLeft(12)] | join(" ")'

# short hand function
function lk {
  cd "$(walk "$@")"
}

# System tools environment variables
export CURRENT_WALLPAPER="${TARGET_DIR}/wallpaper/wall1.png"

export DEFAULT_FILE=""

# function get_bright() {
#   sudo ddcutil getvcp 10 | grep -oP 'current value =\s+\K\d+'
# }
# export BRIGHTNESS=$(get_bright)

# Make prompt bright bold neon green,purple keep output white.
# PS1=' \[\033[1;32m\]\w >\[\033[0m\] ' ## neon-green
PS1=' \[\033[38;5;141m\]\w >\[\033[0m\] ' ## neon-purple

function q {
  exit
}

alias F2="sudo systemctl reboot"

alias F1="sudo systemctl poweroff"

alias ~="cd ~"

alias ..="cd .."

# === HYPRLAND CONFIG END ===