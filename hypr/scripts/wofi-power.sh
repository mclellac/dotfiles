#!/bin/bash

options="Shutdown\nReboot\nLogout"

selected_option=$(echo -e "$options" | wofi --dmenu --prompt "Power Menu")

case $selected_option in
    "Shutdown")
        systemctl poweroff
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Logout")
        hyprctl dispatch exit 0
        ;;
esac
