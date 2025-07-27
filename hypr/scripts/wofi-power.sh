#!/bin/bash

# Define the Wofi theme
WOFI_THEME="$HOME/.config/wofi/themes/gruvbox.css"

# Options for the power menu
options="Logout\nReboot\nShutdown\nLock Screen"

# Use wofi to select an option
selected_option=$(echo -e "$options" | wofi --dmenu --prompt "Power Menu" --style "$WOFI_THEME")

# Confirmation dialog
if [ -n "$selected_option" ]; then
    confirm=$(echo -e "Yes\nNo" | wofi --dmenu --prompt "Are you sure?" --style "$WOFI_THEME")
    if [ "$confirm" == "Yes" ]; then
        # Execute the selected option
        case "$selected_option" in
            "Logout")
                hyprctl dispatch exit
                ;;
            "Reboot")
                systemctl reboot
                ;;
            "Shutdown")
                systemctl poweroff
                ;;
            "Lock Screen")
                ~/.config/hypr/scripts/lock.sh
                ;;
        esac
    fi
fi
