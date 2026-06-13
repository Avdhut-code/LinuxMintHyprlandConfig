#!/bin/bash
set -e

gnome-terminal \
  --class=exit-hyprland-pass \
  --title="Exit-hyprland-pass" \
  -- bash -c '
    clear
    cols=$(tput cols)
    lines=$(tput lines)

    print_center() {
      local text="$1"
      local padding=$(( (cols - ${#text}) / 2 ))
      if [ "$padding" -gt 0 ]; then
        printf "%*s" "$padding" ""
      fi
      printf "%s\n" "$text"
    }

    content=(
      "┌───────────────────────────────────────────────┐"
      "│          Switch-Off / Exit Hyprland ?         │"
      "└───────────────────────────────────────────────┘"
    )

    content_height=${#content[@]}
    top=$(( (lines - content_height - 2) / 2 ))
    if [ "$top" -gt 0 ]; then
      for _ in $(seq 1 "$top"); do
        printf "\n"
      done
    fi

    for line in "${content[@]}"; do
      print_center "$line"
    done
    printf "\n"

    prompt="Are you sure you want to exit Hyprland? [y/N]: "
    left=$(( (cols - ${#prompt}) / 2 ))
    if [ "$left" -gt 0 ]; then
      read -rp "$(printf '%*s' "$left" '')$prompt" ans
    else
      read -rp "$prompt" ans
    fi

    case "$ans" in
        [Yy]*)
            echo "Exiting..."
            sleep 0.5
            hyprctl dispatch exit
            systemctl poweroff
            ;;
        *)
            echo "Cancelled."
            sleep 0.5
            ;;
    esac
  '