#!/bin/sh

# Get the OS ID from /etc/os-release
OS_ID=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')

# Function to get updates for Arch Linux
get_arch_updates() {
    UPDATES=$(checkupdates)
    if [ -n "$UPDATES" ]; then
        COUNT=$(echo "$UPDATES" | wc -l)
        TOOLTIP=$(echo "$UPDATES")
        echo "{\"text\": \"$COUNT\", \"tooltip\": \"$TOOLTIP\"}"
    else
        echo "{}"
    fi
}

# Function to get updates for Fedora
get_fedora_updates() {
    UPDATES=$(dnf check-update -q | grep -v '^Obsoleting ')
    if [ -n "$UPDATES" ]; then
        COUNT=$(echo "$UPDATES" | wc -l)
        TOOLTIP=$(echo "$UPDATES" | awk '{print $1}')
        echo "{\"text\": \"$COUNT\", \"tooltip\": \"$TOOLTIP\"}"
    else
        echo "{}"
    fi
}

# Function to get updates for Debian/Kali
get_debian_updates() {
    # It's important to run apt update in the background periodically
    # This script will not run apt update to avoid sudo prompts
    UPDATES=$(apt list --upgradable 2>/dev/null | tail -n +2)
    if [ -n "$UPDATES" ]; then
        COUNT=$(echo "$UPDATES" | wc -l)
        TOOLTIP=$(echo "$UPDATES" | awk -F/ '{print $1}')
        echo "{\"text\": \"$COUNT\", \"tooltip\": \"$TOOLTIP\"}"
    else
        echo "{}"
    fi
}

case "$OS_ID" in
    "arch")
        get_arch_updates
        ;;
    "fedora")
        get_fedora_updates
        ;;
    "debian" | "kali")
        get_debian_updates
        ;;
    *)
        echo "{}" # Don't show anything if the OS is not supported
        ;;
esac
