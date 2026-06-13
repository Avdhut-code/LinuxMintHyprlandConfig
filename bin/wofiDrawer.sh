#!/bin/bash

USER_INPUT=$(
  wofi \
    --dmenu \
    --style "$HOME/.local/share/LinuxMintHyprlandConfig/config/wofi/SearchBarStyle.css"
)

if [ -z "$USER_INPUT" ]; then
  hyprctl notify 3 3000 "fontsize:35 No input provided."
  exit 1
fi

ENCODED_QUERY=$(printf '%s' "$USER_INPUT" | sed 's/ /+/g')

QUERY_STRING="https://google.com/search?q=$ENCODED_QUERY"

zen --new-tab "$QUERY_STRING"

sleep 1

hyprctl dispatch workspace 2