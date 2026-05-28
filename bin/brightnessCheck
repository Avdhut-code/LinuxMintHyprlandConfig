#!/bin/bash

DefaultBrightnessLevel=15 
BUS=2

# Define paths to your custom icons here
ICON_UP="/home/its_avdhut/.icons/notify-send/brightnessCheck/brightnessIncrease.png"
ICON_DOWN="/home/its_avdhut/.icons/notify-send/brightnessCheck/brightnessDecrease.png"
ICON_RESET="/home/its_avdhut/.icons/notify-send/brightnessCheck/brightnessReset.png"

# Get current value
CURRENT_VAL=$(sudo ddcutil --bus $BUS getvcp 10 | grep -oP 'current value =\s+\K\d+')

if [ "$1" != "resetToDefault" ]; then
    # Calculate and clamp
    NEW_VAL=$(( CURRENT_VAL $1 $2 ))
    [ "$NEW_VAL" -gt 100 ] && NEW_VAL=100
    [ "$NEW_VAL" -lt 0 ] && NEW_VAL=0

    # Apply change
    if [ "$NEW_VAL" -ne "$CURRENT_VAL" ]; then
        sudo /usr/bin/ddcutil --bus $BUS setvcp 10 "$NEW_VAL"
    fi

    # Check for + or - to set the icon
    if [ "$1" == "+" ]; then
        ICON=$ICON_UP
    else
        ICON=$ICON_DOWN
    fi

    MSG="Current Level: ${NEW_VAL}%"

else 
    # Reset Logic
    NEW_VAL=$DefaultBrightnessLevel
    sudo /usr/bin/ddcutil --bus $BUS setvcp 10 $NEW_VAL
    ICON=$ICON_RESET
    MSG="Reset to Level: ${NEW_VAL}%"
fi

# Global updates (Shared by both branches)
echo "$NEW_VAL" > /tmp/current_brightness
pkill -RTMIN+10 waybar # to Reset  the value at the waybar 
notify-send -t 1500 -i "$ICON" "Brightness" "$MSG" 
