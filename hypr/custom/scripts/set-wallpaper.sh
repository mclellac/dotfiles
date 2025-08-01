#!/bin/bash

# Check if zenity is installed
if ! command -v zenity &> /dev/null; then
    echo "zenity not found, please install it to use this script."
    exit 1
fi

# Get the first monitor name
monitor=$(hyprctl monitors | awk '/Monitor/ {print $2}')

# Open file picker to select a wallpaper
wallpaper=$(zenity --file-selection --title="Select a wallpaper" --filename="$HOME/Pictures/wallpapers/")

# Exit if no wallpaper is selected
if [ -z "$wallpaper" ]; then
    exit 0
fi

# Set the wallpaper with hyprpaper
hyprctl hyprpaper unload all
hyprctl hyprpaper wallpaper "$monitor,$wallpaper"

# Generate and apply color scheme with pywal
wal -i "$wallpaper"
