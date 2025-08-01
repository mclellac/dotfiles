#!/bin/bash

# Get the first monitor name
monitor=$(hyprctl monitors | awk '/Monitor/ {print $2}')

# Find a random wallpaper
wallpaper_dir="$HOME/.config/wallpapers"
wallpaper=$(find "$wallpaper_dir" -type f | shuf -n 1)

# Set the wallpaper with hyprpaper
hyprctl hyprpaper unload all
hyprctl hyprpaper wallpaper "$monitor,$wallpaper"

# Generate and apply color scheme with pywal
wal -i "$wallpaper"
