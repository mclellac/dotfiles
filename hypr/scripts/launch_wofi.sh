#!/bin/bash
chosen=$(ls /usr/share/applications/*.desktop | sed 's/\.desktop//g' | sed 's/.*\///g' | wofi --show dmenu --style ~/.config/wofi/themes/gruvbox.css)
if [ -n "$chosen" ]; then
  gtk-launch "$chosen"
fi
