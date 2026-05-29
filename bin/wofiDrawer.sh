# #!/usr/bin/env bash

# # Display wofi with a custom prompt, type your input and hit enter
# USER_INPUT=$(
#   wofi \
#     --dmenu \
#     --style "/home/its_avdhut/.config/wofi/SearchBarStyle.css"
# )
# QUERY_STRING="https://google.com/search?q=$USER_INPUT"
# # Check if the user entered something and didn't close Wofi
# if [ -n "$USER_INPUT" ]; then

#   hyprctl dispatch workspace 2

#   zen --new-tab "$QUERY_STRING"
# else
#   hyprctl notify 3 3000 "fontsize:35 No input provided."
# fi

#### AI After this ###

#!/usr/bin/env bash

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