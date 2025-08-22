#!/bin/bash
#
# A robust application launcher for Fuzzel with JSON caching,
# custom overrides, usage frequency sorting, and icon support.
#
# DEPENDENCIES: jq, find, stat, awk
#

# --- Configuration & Paths ---
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fuzzel"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/fuzzel-apps"
HISTORY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fuzzel-apps"
CACHE_FILE="$CACHE_DIR/apps.json"
HISTORY_FILE="$HISTORY_DIR/history.json"
OVERRIDES_FILE="$CONFIG_DIR/overrides.json"
TERMCMD="${TERMCMD:-kitty}"

# --- Setup ---
# Ensure all necessary directories and files exist
mkdir -p "$CONFIG_DIR" "$CACHE_DIR" "$HISTORY_DIR"
# Create history file as an empty JSON object if it doesn't exist or is empty
[ ! -s "$HISTORY_FILE" ] && echo "{}" > "$HISTORY_FILE"

# --- Application Directories ---
# Build a list of directories to search for .desktop files
APP_DIRS=()
# User-specific directories
[ -d "$HOME/.local/share/applications" ] && APP_DIRS+=("$HOME/.local/share/applications")
[ -d "$HOME/.local/share/flatpak/exports/share/applications" ] && APP_DIRS+=("$HOME/.local/share/flatpak/exports/share/applications")

# System-wide directories from XDG_DATA_DIRS
IFS=':' read -r -a xdg_data_dirs <<< "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
for dir in "${xdg_data_dirs[@]}"; do
    [ -d "$dir/applications" ] && APP_DIRS+=("$dir/applications")
    [ -d "$dir/flatpak/exports/share/applications" ] && APP_DIRS+=("$dir/flatpak/exports/share/applications")
done
# System-wide flatpak directory
[ -d "/var/lib/flatpak/exports/share/applications" ] && APP_DIRS+=("/var/lib/flatpak/exports/share/applications")

# --- Cache Management ---
# Check if the cache is stale and needs regeneration
is_cache_stale() {
    if [ ! -f "$CACHE_FILE" ]; then return 0; fi

    local cache_mtime
    cache_mtime=$(stat -c %Y "$CACHE_FILE")

    # Check if overrides file is newer
    if [ -f "$OVERRIDES_FILE" ] && [ "$(stat -c %Y "$OVERRIDES_FILE")" -gt "$cache_mtime" ]; then
        return 0
    fi

    # Check if this script is newer
    if [ "$0" -nt "$CACHE_FILE" ]; then
        return 0
    fi

    # Check if any application directory is newer
    for dir in "${APP_DIRS[@]}"; do
        # Some dirs in XDG_DATA_DIRS might not exist, so check
        if [ -d "$dir" ] && [ "$(stat -c %Y "$dir")" -gt "$cache_mtime" ]; then
            return 0
        fi
    done

    return 1 # Cache is fresh
}

# Generate the application cache
generate_cache() {
    # 1. Scan all .desktop files and convert to a stream of JSON objects
    local scanned_apps
    scanned_apps=$(
        find "${APP_DIRS[@]}" -mindepth 1 -type f -name "*.desktop" -print0 2>/dev/null |
        while IFS= read -r -d '' desktop_file; do
            # Use awk to parse the desktop file, extracting relevant fields.
            # It handles multiple Name entries (e.g., Name[en_US]) by taking the first one.
            awk -F'=' '
            BEGIN {
                name=""; exec_cmd=""; icon=""; terminal="false"; nodisplay="false";
            }
            /^\[Desktop Entry\]/ { in_entry=1 }
            in_entry && /^Name/ { if(!name) name=substr($0, index($0, "=") + 1) }
            in_entry && /^Exec/ { if(!exec_cmd) exec_cmd=substr($0, index($0, "=") + 1) }
            in_entry && /^Icon/ { if(!icon) icon=substr($0, index($0, "=") + 1) }
            in_entry && /^Terminal/ { terminal=($2=="true" ? "true" : "false") }
            in_entry && /^NoDisplay/ { nodisplay=($2=="true" ? "true" : "false") }
            END {
                if (name && exec_cmd && nodisplay != "true") {
                    # Clean Exec command: remove field codes like %f, %U, etc.
                    # A simple approach that works for most cases.
                    gsub(/%[a-zA-Z]/, "", exec_cmd);
                    # Escape backslashes and double quotes for JSON
                    gsub(/\\/, "\\\\", name); gsub(/"/, "\\\"", name);
                    gsub(/\\/, "\\\\", exec_cmd); gsub(/"/, "\\\"", exec_cmd);
                    gsub(/\\/, "\\\\", icon); gsub(/"/, "\\\"", icon);
                    # Set default icon if not present
                    if (!icon) icon="application-x-executable";
                    # Output as a JSON object
                    printf "{\"name\":\"%s\",\"exec\":\"%s\",\"terminal\":%s,\"icon\":\"%s\"}\n", name, exec_cmd, terminal, icon
                }
            }
            ' "$desktop_file"
        done | jq -s '.' # Aggregate all JSON objects into a single array
    )
    # Ensure scanned_apps is a valid JSON array, even if find returns nothing.
    scanned_apps=${scanned_apps:-'[]'}

    # 2. Load overrides from the specified file
    local overrides_apps
    if [ -f "$OVERRIDES_FILE" ]; then
        # This handles the simple "Name": "exec" format
        overrides_apps=$(jq 'to_entries | map({name: .key, exec: .value, terminal: false, icon: "application-x-executable"})' "$OVERRIDES_FILE" 2>/dev/null)
    fi
    # Ensure overrides_apps is a valid JSON array
    overrides_apps=${overrides_apps:-'[]'}

    # 3. Merge scanned apps and overrides, with overrides taking precedence.
    #    'unique_by(.name)' keeps the first occurrence, so we put overrides first.
    jq -n --argjson overrides "$overrides_apps" --argjson scanned "$scanned_apps" \
        '($overrides + $scanned) | unique_by(.name)' > "$CACHE_FILE"
}

# --- Main Logic ---
# Regenerate cache if it's stale
if is_cache_stale; then
    generate_cache
fi

# Exit if cache is still empty (e.g., no .desktop files found)
if [ ! -s "$CACHE_FILE" ]; then
    echo "Application cache is empty. No applications found." >&2
    exit 1
fi

# Merge app list with usage history for sorting
# The subshell <(jq . "$HISTORY_FILE") handles cases where history file is invalid JSON
apps_with_history=$(
    jq -s '
        .[0] as $history | .[1] as $apps |
        $apps | map(. + {count: ($history[.name] // 0)})
    ' <(jq . "$HISTORY_FILE" 2>/dev/null || echo "{}") "$CACHE_FILE"
)

# Sort applications by usage count (descending) and then by name (ascending)
sorted_apps=$(echo "$apps_with_history" | jq 'sort_by(-.count, .name)')

# Format for Fuzzel: text\0icon\x1f<icon_name>
# Use a default icon if the icon value is null or empty
fuzzel_input=$(echo "$sorted_apps" | jq -r '.[] | .name + "\u0000icon\u001f" + (.icon // "application-x-executable")')

# Run Fuzzel
# The `if ...; then ...; fi` construct avoids issues with `set -e`
chosen_app_name=""
if ! chosen_app_name=$(echo -e "$fuzzel_input" | fuzzel --dmenu --log-level=none); then
    # Exit if fuzzel was closed (e.g., by pressing Esc, which gives exit code 1)
    exit 0
fi

# Exit if Fuzzel returned an empty selection
if [ -z "$chosen_app_name" ]; then
    exit 0
fi

# --- Application Launching ---
# Find the chosen application's details from the sorted list
chosen_app_details=$(echo "$sorted_apps" | jq --arg name "$chosen_app_name" '.[] | select(.name == $name)')

# Exit if the chosen app is not found in our list (should not happen)
if [ -z "$chosen_app_details" ]; then
    echo "Error: Could not find details for '$chosen_app_name'" >&2
    exit 1
fi

exec_cmd=$(echo "$chosen_app_details" | jq -r '.exec')
is_terminal=$(echo "$chosen_app_details" | jq -r '.terminal')

# Update usage history
# Use a temporary file for atomic write to avoid corruption
tmp_history_file=$(mktemp)
jq --arg name "$chosen_app_name" '.[$name] = (.[$name] // 0) + 1' <(jq . "$HISTORY_FILE" 2>/dev/null || echo "{}") > "$tmp_history_file" && mv "$tmp_history_file" "$HISTORY_FILE"


# Launch the application
# Use `hyprctl dispatch exec` for better integration with Hyprland
if [ "$is_terminal" = "true" ]; then
    hyprctl dispatch exec -- "$TERMCMD" sh -c "$exec_cmd"
else
    hyprctl dispatch exec -- sh -c "$exec_cmd"
fi

exit 0
