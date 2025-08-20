#!/bin/sh

if ! command -v jq >/dev/null; then
    echo '{"text": "ERR: jq not found", "tooltip": "Please install jq to use the update checker."}'
    exit 1
fi

# Get the OS ID from /etc/os-release
OS_ID=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')

get_updates() {
    UPDATES="$1"
    if [ -n "$UPDATES" ]; then
        COUNT=$(echo "$UPDATES" | wc -l)
        jq -c -n --arg text "$COUNT" --arg tooltip "$UPDATES" '{"text": $text, "tooltip": $tooltip, "class": "updates"}'
    else
        echo '{"text": "", "class": "hidden"}'
    fi
}

case "$OS_ID" in
    "arch")
        UPDATES=$(checkupdates)
        get_updates "$UPDATES"
        ;;
    "fedora")
        UPDATES=$(dnf check-update -q | grep -v '^Obsoleting ' | awk '{print $1}')
        get_updates "$UPDATES"
        ;;
    "debian" | "kali")
        # It's important to run apt update in the background periodically
        # This script will not run apt update to avoid sudo prompts
        UPDATES=$(apt list --upgradable 2>/dev/null | tail -n +2 | awk -F/ '{print $1}')
        get_updates "$UPDATES"
        ;;
    *)
        echo "{}" # Don't show anything if the OS is not supported
        ;;
esac
