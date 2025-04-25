#!/bin/bash

# --- Configuration ---
# List of essential portal executables to ensure are running *after* cleanup
# The script will try to find these in /usr/libexec/ or /usr/lib/
# Order matters: start generic portal first, then specific backends.
required_portals=(
    "xdg-desktop-portal"
    "xdg-desktop-portal-gtk"      # Often needed for file pickers etc. in GTK apps
    "xdg-desktop-portal-hyprland" # The one we want running for Hyprland
)

# --- Script Logic ---

echo "INFO: Attempting to stop all running xdg-desktop-portal processes..."

# Use pkill to find processes matching the pattern 'xdg-desktop-portal'
# Send SIGTERM first, wait a moment, then send SIGKILL if any are left.
pkill -f "xdg-desktop-portal"
sleep 0.5                           # Give processes a moment to terminate gracefully
pkill -KILL -f "xdg-desktop-portal" # Force kill any remaining ones
sleep 0.5                           # Wait briefly after killing

echo "INFO: Restarting required XDG Desktop Portal services..."

# Loop through the required portals and start them if found
for portal_name in "${required_portals[@]}"; do
    portal_path=""
    # Check common locations
    if [ -f "/usr/libexec/${portal_name}" ]; then
        portal_path="/usr/libexec/${portal_name}"
    elif [ -f "/usr/lib/${portal_name}" ]; then
        portal_path="/usr/lib/${portal_name}"
    fi

    # If the portal executable was found, start it in the background
    if [ -n "$portal_path" ]; then
        echo "INFO: Starting ${portal_name} from ${portal_path}..."
        # Start in background, redirect stdout/stderr to /dev/null to avoid clutter
        "$portal_path" &>/dev/null &
        sleep 0.5 # Short delay between starting portals
    else
        echo "WARNING: Required portal '${portal_name}' not found in /usr/libexec or /usr/lib. Skipping."
    fi
done

echo "INFO: Portal restart script finished."

exit 0
