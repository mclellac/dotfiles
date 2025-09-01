#!/bin/bash

# Path for the state file
STATE_FILE="/tmp/hypr_gaps.state"

# Default gap size if state file doesn't exist
# This should ideally match your hyprland.conf initial value
DEFAULT_GAPS=5

# Step size for increasing/decreasing gaps
STEP=5

# Read current gap size from state file, or use default
if [ -f "$STATE_FILE" ]; then
    current_gaps=$(cat "$STATE_FILE")
else
    # If state file doesn't exist, try to get it from hyprctl, fallback to default
    current_gaps=$(hyprctl getoption general:gaps_in | jq .int 2>/dev/null)
    if [ -z "$current_gaps" ]; then
        current_gaps=$DEFAULT_GAPS
    fi
fi

# Adjust gaps based on argument
if [ "$1" == "inc" ]; then
    new_gaps=$((current_gaps + STEP))
elif [ "$1" == "dec" ]; then
    new_gaps=$((current_gaps - STEP))
    # Prevent gaps from being negative
    if [ "$new_gaps" -lt 0 ]; then
        new_gaps=0
    fi
else
    echo "Usage: $0 [inc|dec]"
    exit 1
fi

# Apply the new gap size
hyprctl keyword general:gaps_in "$new_gaps"

# Save the new gap size to the state file
echo "$new_gaps" > "$STATE_FILE"
