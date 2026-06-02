#!/bin/bash

### --- Start swaybg 
### this variable is for the swaybg script to work and set the wallpaper on startup, you can change this into your '~/.bashrc' and only chnage the suffix number of the file name for next wallpaer or a custom wallpaper path
swaybg -i "$CURRENT_WALLPAPER" -m fill &
sleep 1 # extra stability buffer

### --- Start waybar
waybar >/dev/null 2>&1 &
sleep 1 # extra stability buffer

### --- Start hypridle
hypridle >/dev/null 2>&1 &
sleep 1 # extra stability buffer

### --- Start custom btop moniter
custom-launch-btop

### --- Start brightness to default
/usr/local/bin/brightnessCheck resetToDefault

### --- Put your startup tools here --- ###
