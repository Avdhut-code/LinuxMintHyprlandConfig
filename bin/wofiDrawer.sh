# #!/usr/bin/env bash

USER_INPUT=$(
  wofi \
    --dmenu \
    --style "/home/its_avdhut/.config/wofi/SearchBarStyle.css"
)

# Exit if empty
if [ -z "$USER_INPUT" ]; then
  hyprctl notify 3 3000 "fontsize:35 No input provided."
  exit 1
fi

# Replace spaces with +
ENCODED_QUERY=$(printf '%s' "$USER_INPUT" | sed 's/ /+/g')

QUERY_STRING="https://google.com/search?q=$ENCODED_QUERY"

sleep 1

hyprctl dispatch workspace 2

zen --new-tab "$QUERY_STRING"