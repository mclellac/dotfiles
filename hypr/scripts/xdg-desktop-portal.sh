#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error when substituting.
# Prevent errors in pipelines from being masked.
set -euo pipefail

# --- Configuration ---
readonly portal_hyprland_name="xdg-desktop-portal-hyprland"
readonly portal_name="xdg-desktop-portal"
readonly portal_hyprland_service="${portal_hyprland_name}.service"
readonly portal_service="${portal_name}.service"

# --- Helper Functions ---
# Consistent logging format
log() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*" >&2; }   # Send warnings to stderr
error() { echo "[ERROR] $*" >&2; } # Send errors to stderr
die() {
    error "$*"
    exit 1
} # Print error and exit

# Function to check if a systemd user service unit exists (active or inactive)
# Returns 0 if the service exists, 1 otherwise.
check_systemd_service_exists() {
    local service_name="$1"
    # systemctl --user can fail if the user session bus isn't available.
    # Check if systemd knows about the unit (either active or inactive state).
    # Redirect stderr to /dev/null to suppress "Unit file does not exist" etc.
    if systemctl --user --quiet is-enabled "$service_name" >/dev/null 2>&1 ||
        systemctl --user --quiet is-active "$service_name" >/dev/null 2>&1 ||
        systemctl --user --quiet is-inactive "$service_name" >/dev/null 2>&1; then
        return 0 # Service unit exists
    else
        # This can also mean the systemd user instance itself isn't running properly
        return 1 # Service unit does not exist or systemd user session issue
    fi
}

# --- Systemd Restart Attempt ---
# Tries to restart using systemd user services.
# Returns 0 on success, 1 on failure or if systemd isn't applicable.
try_systemd_restart() {
    log "Checking for systemd user services..."
    local services_to_restart=()

    # Check if systemctl command is available
    if ! command -v systemctl >/dev/null; then
        log "systemctl command not found. Skipping systemd check."
        return 1
    fi

    # Check essential portal service
    if check_systemd_service_exists "$portal_service"; then
        log "Found systemd user service: $portal_service"
        services_to_restart+=("$portal_service")
    else
        log "Systemd user service '$portal_service' not found or user session inactive."
        # If the main portal isn't managed by systemd, don't attempt systemd restart
        return 1
    fi

    # Check optional Hyprland portal service
    if check_systemd_service_exists "$portal_hyprland_service"; then
        log "Found systemd user service: $portal_hyprland_service"
        # Add Hyprland service; systemd handles dependencies/ordering
        services_to_restart+=("$portal_hyprland_service")
    else
        log "Systemd user service '$portal_hyprland_service' not found or user session inactive. Will restart only '$portal_service'."
    fi

    log "Attempting restart via systemctl --user for: ${services_to_restart[*]}"
    # Execute the restart command
    if systemctl --user restart "${services_to_restart[@]}"; then
        log "Successfully restarted services via systemctl."
        return 0 # Success
    else
        warn "systemctl restart command failed. Check 'systemctl --user status ${services_to_restart[*]}' for details."
        return 1 # Failure
    fi
}

# --- Manual Restart Method (Fallback) ---
# Finds, kills, and restarts processes manually.
manual_restart() {
    log "Executing manual restart process..."
    local portal_hyprland_exec="" # Initialize empty
    local portal_exec=""
    local found_essential=false

    # Find executables using command -v
    log "Locating required portal executables..."
    portal_hyprland_exec=$(command -v "$portal_hyprland_name")
    portal_exec=$(command -v "$portal_name")

    # Validate paths
    if [ -z "$portal_hyprland_exec" ]; then
        # This might be acceptable if the Hyprland portal isn't needed/installed
        warn "Executable '$portal_hyprland_name' not found in PATH. Will skip managing it."
    else
        log "Found Hyprland portal backend: $portal_hyprland_exec"
    fi

    if [ -z "$portal_exec" ]; then
        # The main portal is generally essential
        error "Executable '$portal_name' not found in PATH."
    else
        log "Found main portal service: $portal_exec"
        found_essential=true
    fi

    # Exit if the essential main portal executable wasn't found
    if [ "$found_essential" != "true" ]; then
        die "Exiting because essential executable '$portal_name' was not found."
    fi

    # Stop existing processes using pkill
    log "Attempting to stop existing portal processes via pkill..."
    # Only try to kill hyprland portal if its executable was found
    if [ -n "$portal_hyprland_exec" ]; then
        # Use -f to match command line, redirect errors, ignore non-zero exit code
        pkill -f "$portal_hyprland_name" >/dev/null 2>&1 || true
    fi
    # Kill main portal process
    pkill -f "$portal_name" >/dev/null 2>&1 || true

    log "Waiting briefly for processes to terminate..."
    sleep 1 # Adjust if necessary

    # Start new processes
    log "Starting portal services manually..."

    # Start Hyprland backend first if found (in background, suppress output)
    if [ -n "$portal_hyprland_exec" ]; then
        log "Starting $portal_hyprland_name..."
        if ! "$portal_hyprland_exec" &>/dev/null & then
            warn "Command to start '$portal_hyprland_name' failed immediately."
            # Continue anyway, maybe main portal works alone
        fi
        # Give backend a moment to initialize
        sleep 2 # Adjust if necessary
    fi

    # Start main portal service (in background, suppress output)
    log "Starting $portal_name..."
    if ! "$portal_exec" &>/dev/null & then
        die "Command to start essential service '$portal_name' failed immediately."
    fi

    log "Manual portal restart sequence initiated."
    log "Verify processes are running (e.g., using 'ps aux | grep xdg-desktop-portal')."
    return 0 # Manual sequence completed attempt
}

# --- Main Execution ---
log "Starting XDG Desktop Portal restart script..."

# First, attempt restart using systemd
if try_systemd_restart; then
    log "Systemd restart successful. Exiting."
    exit 0 # Success!
else
    # If systemd failed or wasn't applicable, fall back to manual method
    log "Systemd restart failed or not applicable. Falling back to manual method."
    if manual_restart; then
        log "Manual restart method completed."
        exit 0 # Manual method finished (doesn't guarantee success, but sequence ran)
    else
        # manual_restart calls die() on critical failure, so script should exit there.
        # This is a fallback exit in case manual_restart returns non-zero unexpectedly.
        die "Manual restart method failed."
    fi
fi
