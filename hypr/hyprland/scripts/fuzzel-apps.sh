#!/bin/bash
# A robust application launcher for Fuzzel with JSON caching,
# custom overrides, usage frequency sorting, and icon support.

# Set a standard UTF-8 locale to ensure consistent behavior of text-processing tools.
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# --- Wayland & Path Environment ---
# Ensure essential Wayland variables are set
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
# Set a robust PATH
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

set -euo pipefail

# --- Debugging ---
debug() {
    echo "DEBUG: $1" >&2
}

debug "Script started."
debug "WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
debug "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
debug "PATH=$PATH"

# --- Error Handling & Dependencies ---
die() {
    echo "ERROR: $1" >&2
    exit 1
}

check_dependencies() {
    debug "Checking dependencies..."
    local dependencies=(jq find stat awk printf fuzzel zsh)
    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            die "Required command '$cmd' is not installed. Please install it to continue."
        fi
    done
    debug "All dependencies are satisfied."
}

# --- Configuration & Paths ---
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fuzzel"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/fuzzel-apps"
HISTORY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fuzzel-apps"
CACHE_FILE="$CACHE_DIR/apps.json"
HISTORY_FILE="$HISTORY_DIR/history.json"
OVERRIDES_FILE="$CONFIG_DIR/overrides.json"
TERMCMD="${TERMCMD:-kitty}"

debug "Configuration paths:"
debug "  CONFIG_DIR=$CONFIG_DIR"
debug "  CACHE_DIR=$CACHE_DIR"
debug "  HISTORY_DIR=$HISTORY_DIR"
debug "  CACHE_FILE=$CACHE_FILE"
debug "  HISTORY_FILE=$HISTORY_FILE"
debug "  OVERRIDES_FILE=$OVERRIDES_FILE"
debug "  TERMCMD=$TERMCMD"

# --- Setup ---
# Ensures that all necessary directories and files exist.
# Provides explicit error messages if creation fails.
setup_directories() {
    debug "Setting up directories..."
    mkdir -p "$CONFIG_DIR" "$CACHE_DIR" "$HISTORY_DIR" || die "Failed to create required directories."
    if [ ! -s "$HISTORY_FILE" ]; then
        debug "History file is missing or empty, creating..."
        echo "{}" >"$HISTORY_FILE" || die "Failed to create history file. Check permissions for $HISTORY_DIR."
    fi
    debug "Directories are set up."
}

# --- Cache Management ---
is_cache_stale() {
    if [ ! -f "$CACHE_FILE" ]; then
        debug "Cache file not found. Stale."
        return 0
    fi

    local app_dirs_array=("$@")
    local cache_mtime
    cache_mtime=$(stat -c %Y "$CACHE_FILE")
    debug "Cache mtime: $(date -d @"$cache_mtime" 2>/dev/null || echo "$cache_mtime")"

    if [ -f "$OVERRIDES_FILE" ] && [ "$(stat -c %Y "$OVERRIDES_FILE")" -gt "$cache_mtime" ]; then
        debug "Overrides file is newer. Stale."
        return 0
    fi
    if [ "$0" -nt "$CACHE_FILE" ]; then
        debug "Script is newer. Stale."
        return 0
    fi

    for dir in "${app_dirs_array[@]}"; do
        if [ -d "$dir" ] && [ "$(stat -c %Y "$dir")" -gt "$cache_mtime" ]; then
            debug "Directory '$dir' is newer. Stale."
            return 0
        fi
    done

    debug "Cache is fresh."
    return 1
}

# Function to parse .desktop files and convert them to a JSON array.
# It extracts Name, Exec, and Terminal fields.
parse_desktop_files() {
    local app_dirs_array=("$@")
    if [ ${#app_dirs_array[@]} -eq 0 ]; then
        echo "[]"
        return
    fi

    find "${app_dirs_array[@]}" -mindepth 1 -type f -name "*.desktop" -print0 |
        while IFS= read -r -d '' desktop_file; do
            awk -F'=' '
            BEGIN {
                generic_name=""; en_name=""; en_us_name="";
                exec_cmd=""; terminal="false"; nodisplay="false";
            }
            /\[Desktop Entry\]/ { in_entry=1 }
            in_entry {
                val = substr($0, index($0, "=") + 1);
                if ($1 == "Name")        { generic_name = val }
                if ($1 == "Name[en]")    { en_name = val }
                if ($1 == "Name[en_US]") { en_us_name = val }
                if ($1 == "Exec" && !exec_cmd)      { exec_cmd = val }
                if ($1 == "Terminal")               { terminal = (val == "true" ? "true" : "false") }
                if ($1 == "NoDisplay")              { nodisplay = (val == "true" ? "true" : "false") }
            }
            END {
                name = en_us_name ? en_us_name : (en_name ? en_name : generic_name);
                if (name && exec_cmd && nodisplay != "true") {
                    gsub(/%[a-zA-Z]/, "", exec_cmd);
                    gsub(/\\/, "\\\\", name); gsub(/"/, "\\\"", name); gsub(/\n/, "\\n", name);
                    gsub(/\\/, "\\\\", exec_cmd); gsub(/"/, "\\\"", exec_cmd);
                    printf "{\"name\":\"%s\",\"exec\":\"%s\",\"terminal\":%s}\n", name, exec_cmd, terminal
                }
            }
        ' "$desktop_file"
        done | jq -s '.'
}

# Generates the application cache by parsing .desktop files and merging with overrides.
generate_cache() {
    local app_dirs_array=("$@")
    debug "Generating cache from directories: ${app_dirs_array[*]}"
    local scanned_apps
    scanned_apps=$(parse_desktop_files "${app_dirs_array[@]}")
    scanned_apps=${scanned_apps:-'[]'}
    debug "Found $(echo "$scanned_apps" | jq length) applications from .desktop files."

    local overrides_apps='[]'
    if [ -f "$OVERRIDES_FILE" ]; then
        debug "Loading overrides from $OVERRIDES_FILE"
        overrides_apps=$(jq 'to_entries | map({name: .key, exec: .value, terminal: false})' "$OVERRIDES_FILE" 2>/dev/null || echo '[]')
        debug "Found $(echo "$overrides_apps" | jq length) applications from overrides."
    fi

    jq -n --argjson overrides "$overrides_apps" --argjson scanned "$scanned_apps" \
        '($overrides + $scanned) | unique_by(.name)' >"$CACHE_FILE"
    debug "Cache generated and saved to $CACHE_FILE."
}

# --- Main Logic ---
main() {
    check_dependencies
    setup_directories

    # --- Application Directories ---
    local app_dirs_array=()
    [ -d "$HOME/.local/share/applications" ] && app_dirs_array+=("$HOME/.local/share/applications")
    [ -d "$HOME/.local/share/flatpak/exports/share/applications" ] && app_dirs_array+=("$HOME/.local/share/flatpak/exports/share/applications")
    IFS=':' read -r -a xdg_data_dirs <<<"${XDG_DATA_DIRS:-/usr/local/share:/usr/share}" || true
    for dir in "${xdg_data_dirs[@]}"; do
        [ -d "$dir/applications" ] && app_dirs_array+=("$dir/applications")
        [ -d "$dir/flatpak/exports/share/applications" ] && app_dirs_array+=("$dir/flatpak/exports/share/applications")
    done
    [ -d "/var/lib/flatpak/exports/share/applications" ] && app_dirs_array+=("/var/lib/flatpak/exports/share/applications")
    debug "Application directories: ${app_dirs_array[*]}"

    if is_cache_stale "${app_dirs_array[@]}"; then
        debug "Cache is stale, regenerating..."
        generate_cache "${app_dirs_array[@]}"
    else
        debug "Using fresh cache."
    fi

    if [ ! -s "$CACHE_FILE" ]; then
        die "Application cache is empty. No applications found."
    fi

    local history
    history=$(jq . "$HISTORY_FILE" 2>/dev/null || echo "{}")
    debug "Loaded history with $(echo "$history" | jq 'length') entries."

    local apps_with_history
    apps_with_history=$(jq -s '
        .[0] as $history | .[1] as $apps |
        $apps | map(. + {count: ($history[.name] // 0)})
    ' <(echo "$history") "$CACHE_FILE")

    local sorted_apps
    sorted_apps=$(echo "$apps_with_history" | jq 'sort_by(-.count, .name)')

    debug "Presenting $(echo "$sorted_apps" | jq 'length') apps to fuzzel."
    local chosen_app_name
    chosen_app_name=$(echo "$sorted_apps" |
        jq -r '.[] | .name' |
        fuzzel --dmenu --log-level=none || true)

    if [ -z "$chosen_app_name" ]; then
        debug "Fuzzel was cancelled by the user."
        exit 0 # User cancelled fuzzel
    fi
    debug "User chose: '$chosen_app_name'"

    local chosen_app_details
    chosen_app_details=$(echo "$sorted_apps" | jq --arg name "$chosen_app_name" '.[] | select(.name == $name)')

    if [ -z "$chosen_app_details" ]; then
        die "Could not find details for '$chosen_app_name'"
    fi

    # Update history before launching
    debug "Updating history for '$chosen_app_name'."
    local tmp_history_file
    tmp_history_file=$(mktemp)
    jq --arg name "$chosen_app_name" '.[$name] = (.[$name] // 0) + 1' <(echo "$history") >"$tmp_history_file" && mv "$tmp_history_file" "$HISTORY_FILE"

    local exec_cmd is_terminal
    exec_cmd=$(echo "$chosen_app_details" | jq -r '.exec')
    is_terminal=$(echo "$chosen_app_details" | jq -r '.terminal')
    debug "Launch details: exec='$exec_cmd', terminal='$is_terminal'"

    # Launch the application
    if [ "$is_terminal" = "true" ]; then
        # Use an interactive shell to ensure aliases/functions are available.
        debug "Launching in terminal: $TERMCMD zsh -i -c \"$exec_cmd\""
        nohup "$TERMCMD" zsh -i -c "$exec_cmd" >/dev/null 2>&1 &
    else
        # Use a login, interactive shell to ensure the user's full environment is loaded,
        # including aliases and functions from .zshrc.
        debug "Launching with: nohup zsh -l -i -c \"$exec_cmd\""
        nohup zsh -l -i -c "$exec_cmd" >/dev/null 2>&1 &
    fi
    debug "Script finished."
}

main "$@"
