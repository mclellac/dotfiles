#!/bin/bash

entries="   Shutdown
   Reboot
   Logout
   Lock"

selected=$(printf '%s' "$entries" | fuzzel --dmenu --prompt 'Power Menu:')

if [ -z "$selected" ]; then
    exit 0
fi

confirm() {
    local prompt="$1"
    answer=$(printf "No\nYes" | fuzzel --dmenu --prompt "$prompt")
    [ "$answer" = "Yes" ]
}

case "$selected" in
*Shutdown)
    if confirm "Are you sure you want to shut down?"; then
        systemctl poweroff
    fi
    ;;
*Reboot)
    if confirm "Are you sure you want to reboot?"; then
        systemctl reboot
    fi
    ;;
*Logout)
    if confirm "Are you sure you want to log out?"; then
        hyprctl dispatch exit
    fi
    ;;
*Lock)
    # No confirmation needed for locking
    hyprlock
    ;;
esac

exit 0
