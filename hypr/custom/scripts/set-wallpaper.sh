#!/bin/bash

# Check if zenity is installed
if ! command -v zenity &> /dev/null; then
    echo "zenity not found, please install it to use this script."
    exit 1
fi

# Open file picker to select a wallpaper
wallpaper=$(zenity --file-selection --title="Select a wallpaper" --filename="$HOME/Pictures/wallpapers/")

# Exit if no wallpaper is selected
if [ -z "$wallpaper" ]; then
    exit 0
fi

# Update hyprpaper.conf
hyprpaper_conf="$HOME/.config/hypr/hyprpaper.conf"
sed -i "s|^\s*wallpaper\s*=\s*.*|wallpaper = ,$wallpaper|" "$hyprpaper_conf"
sed -i "s|^\s*preload\s*=\s*.*|preload = $wallpaper|" "$hyprpaper_conf"

# Reload hyprpaper
pkill hyprpaper
hyprpaper &

# Generate and apply color scheme with pywal
wal -i "$wallpaper"
