#!/bin/bash
wofi --show drun --style ~/.config/wofi/themes/gruvbox.css | xargs hyprctl dispatch exec
