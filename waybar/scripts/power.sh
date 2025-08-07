#!/bin/sh

entries=" Shutdown\n Reboot\n Logout\n Lock"

selected=$(echo -e $entries|fuzzel --dmenu --prompt "Power Menu")

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
