#!/bin/bash

# Define the Wofi theme
WOFI_THEME="$HOME/.config/wofi/themes/gruvbox.css"

# Get the list of hosts from known_hosts
hosts=$(awk '{print $1}' ~/.ssh/known_hosts | cut -d ',' -f1 | uniq)

# Use wofi to select a host
selected_host=$(echo "$hosts" | wofi --dmenu --prompt "Select a host to SSH into" --style "$WOFI_THEME")

# If a host is selected, open a new terminal and ssh into it
if [ -n "$selected_host" ]; then
    kitty --title "SSH: ${selected_host}" ssh "$selected_host" &
fi
