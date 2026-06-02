#!/bin/bash

DefaultBrightnessLevel=15 
BUS=2
CACHE_FILE="/tmp/current_brightness"

ICON_UP="/home/its_avdhut/.icons/notify-send/brightnessCheck/brightnessIncrease.png"
ICON_DOWN="/home/its_avdhut/.icons/notify-send/brightnessCheck/brightnessDecrease.png"
ICON_RESET="/home/its_avdhut/.icons/notify-send/brightnessCheck/brightnessReset.png"

if [ -z "$1" ]; then
    if [ -f "$CACHE_FILE" ]; then
        cat "$CACHE_FILE"
    else
        CURRENT_VAL=$(sudo ddcutil --bus $BUS getvcp 10 | grep -oP 'current value =\s+\K\d+')
        echo "$CURRENT_VAL" > "$CACHE_FILE"
        echo "$CURRENT_VAL"
    fi
    exit 0
fi

if [ -f "$CACHE_FILE" ]; then
    CURRENT_VAL=$(cat "$CACHE_FILE")
else
    CURRENT_VAL=$(sudo ddcutil --bus $BUS getvcp 10 | grep -oP 'current value =\s+\K\d+')
fi

if ! [[ "$CURRENT_VAL" =~ ^[0-9]+$ ]]; then
    CURRENT_VAL=$DefaultBrightnessLevel
fi

if [ "$1" != "resetToDefault" ]; then
    NEW_VAL=$(( CURRENT_VAL $1 $2 ))
    [ "$NEW_VAL" -gt 100 ] && NEW_VAL=100
    [ "$NEW_VAL" -lt 0 ] && NEW_VAL=0

    if [ "$1" == "+" ]; then
        ICON=$ICON_UP
    else
        ICON=$ICON_DOWN
    fi
    MSG="Current Level: ${NEW_VAL}%"
else 
    NEW_VAL=$DefaultBrightnessLevel
    ICON=$ICON_RESET
    MSG="Reset to Level: ${NEW_VAL}%"
fi

echo "$NEW_VAL" > "$CACHE_FILE"

pkill -RTMIN+10 waybar 

notify-send -r 9999 -t 1500 -i "$ICON" "Brightness" "$MSG"

sudo /usr/bin/ddcutil --bus $BUS setvcp 10 "$NEW_VAL" &>/dev/null
