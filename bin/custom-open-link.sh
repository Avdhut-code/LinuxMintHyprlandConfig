#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: No argument provided."
    exit 1
fi

/usr/bin/env -S bash -c 'exec -a zenlaunch zen --new-tab "$1"' -- "$1" &

until pgrep -f "zenlaunch" >/dev/null; do
    sleep 0.2
done

notify-send -u low "Web-App-Launcher" "$1 Opened" --icon="$2"

hyprctl dispatch workspace 2