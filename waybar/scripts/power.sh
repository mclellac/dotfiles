#!/bin/sh

entries=" Shutdown\n Reboot\n Logout\n Lock"

selected=$(echo -e $entries|wofi --dmenu --prompt "Power Menu" --style ~/.config/wofi/themes/power.css)

case "$selected" in
  *Shutdown)
    systemctl poweroff
    ;;
  *Reboot)
    systemctl reboot
    ;;
  *Logout)
    hyprctl dispatch exit
    ;;
  *Lock)
    hyprlock
    ;;
esac
