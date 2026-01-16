#!/bin/bash
# Simple notification script for neomutt
# Usage: notify_mail.sh

# Use notify-send if available
if command -v notify-send >/dev/null 2>&1; then
    notify-send "New Mail" "You have new messages in neomutt."
fi
