#!/bin/bash
# A robust application launcher for Fuzzel with JSON caching,
# custom overrides, usage frequency sorting, and icon support.

set -euo pipefail

# --- Error Handling & Dependencies ---
die() {
    echo "ERROR: $1" >&2
    exit 1
}

check_dependencies() {
    local dependencies=(jq find stat awk printf fuzzel zsh)
    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            die "Required command '$cmd' is not installed. Please install it to continue."
        fi
    done
}

# --- Configuration & Paths ---
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fuzzel"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/fuzzel-apps"
HISTORY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fuzzel-apps"
CACHE_FILE="$CACHE_DIR/apps.json"
HISTORY_FILE="$HISTORY_DIR/history.json"
OVERRIDES_FILE="$CONFIG_DIR/overrides.json"
TERMCMD="${TERMCMD:-kitty}"

# --- Setup ---
# Ensures that all necessary directories and files exist.
# Provides explicit error messages if creation fails.
setup_directories() {
    mkdir -p "$CONFIG_DIR" "$CACHE_DIR" "$HISTORY_DIR" || die "Failed to create required directories."
    if [ ! -s "$HISTORY_FILE" ]; then
        echo "{}" >"$HISTORY_FILE" || die "Failed to create history file. Check permissions for $HISTORY_DIR."
    fi
}

# --- Cache Management ---
is_cache_stale() {
    if [ ! -f "$CACHE_FILE" ]; then return 0; fi

    local app_dirs_array=("$@")
    local cache_mtime
    cache_mtime=$(stat -c %Y "$CACHE_FILE")

    [ -f "$OVERRIDES_FILE" ] && [ "$(stat -c %Y "$OVERRIDES_FILE")" -gt "$cache_mtime" ] && return 0
    [ "$0" -nt "$CACHE_FILE" ] && return 0

    for dir in "${app_dirs_array[@]}"; do
        [ -d "$dir" ] && [ "$(stat -c %Y "$dir")" -gt "$cache_mtime" ] && return 0
    done

    return 1
}

# Function to parse .desktop files and convert them to a JSON array.
# It extracts Name, Exec, Icon, Terminal, and NoDisplay fields.
# It prefers en_US and en names, and handles missing icons.
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
                exec_cmd=""; icon=""; terminal="false"; nodisplay="false";
            }
            /\[Desktop Entry\]/ { in_entry=1 }
            in_entry {
                val = substr($0, index($0, "=") + 1);
                if ($1 == "Name")        { generic_name = val }
                if ($1 == "Name[en]")    { en_name = val }
                if ($1 == "Name[en_US]") { en_us_name = val }
                if ($1 == "Exec" && !exec_cmd)      { exec_cmd = val }
                if ($1 == "Icon" && !icon)          { icon = val }
                if ($1 == "Terminal")               { terminal = (val == "true" ? "true" : "false") }
                if ($1 == "NoDisplay")              { nodisplay = (val == "true" ? "true" : "false") }
            }
            END {
                name = en_us_name ? en_us_name : (en_name ? en_name : generic_name);
                if (name && exec_cmd && nodisplay != "true") {
                    gsub(/%[a-zA-Z]/, "", exec_cmd);
                    gsub(/\\/, "\\\\", name); gsub(/"/, "\\\"", name); gsub(/\n/, "\\n", name);
                    gsub(/\\/, "\\\\", exec_cmd); gsub(/"/, "\\\"", exec_cmd);
                    gsub(/\\/, "\\\\", icon); gsub(/"/, "\\\"", icon);
                    if (!icon) icon="application-x-executable";
                    printf "{\"name\":\"%s\",\"exec\":\"%s\",\"terminal\":%s,\"icon\":\"%s\"}\n", name, exec_cmd, terminal, icon
                }
            }
        ' "$desktop_file"
        done | jq -s '.'
}

# Generates the application cache by parsing .desktop files and merging with overrides.
generate_cache() {
    local app_dirs_array=("$@")
    local scanned_apps
    scanned_apps=$(parse_desktop_files "${app_dirs_array[@]}")
    scanned_apps=${scanned_apps:-'[]'}

    local overrides_apps='[]'
    if [ -f "$OVERRIDES_FILE" ]; then
        overrides_apps=$(jq 'to_entries | map({name: .key, exec: .value, terminal: false, icon: "application-x-executable"})' "$OVERRIDES_FILE" 2>/dev/null || echo '[]')
    fi

    jq -n --argjson overrides "$overrides_apps" --argjson scanned "$scanned_apps" \
        '($overrides + $scanned) | unique_by(.name)' >"$CACHE_FILE"
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

    if is_cache_stale "${app_dirs_array[@]}"; then
        generate_cache "${app_dirs_array[@]}"
    fi

    if [ ! -s "$CACHE_FILE" ]; then
        die "Application cache is empty. No applications found."
    fi

    local history
    history=$(jq . "$HISTORY_FILE" 2>/dev/null || echo "{}")

    local apps_with_history
    apps_with_history=$(jq -s '
        .[0] as $history | .[1] as $apps |
        $apps | map(. + {count: ($history[.name] // 0)})
    ' <(echo "$history") "$CACHE_FILE")

    local sorted_apps
    sorted_apps=$(echo "$apps_with_history" | jq 'sort_by(-.count, .name)')

    local fuzzel_input
    fuzzel_input=$(echo "$sorted_apps" | jq -r '.[] | .name + "\u0000icon\u001f" + (.icon // "application-x-executable")')

    local chosen_app_name
    chosen_app_name=$(printf "%s" "$fuzzel_input" | fuzzel --dmenu --log-level=none | cut -z -f1 || true)

    if [ -z "$chosen_app_name" ]; then
        exit 0 # User cancelled fuzzel
    fi

    local chosen_app_details
    chosen_app_details=$(echo "$sorted_apps" | jq --arg name "$chosen_app_name" '.[] | select(.name == $name)')

    if [ -z "$chosen_app_details" ]; then
        die "Could not find details for '$chosen_app_name'"
    fi

    # Update history before launching
    local tmp_history_file
    tmp_history_file=$(mktemp)
    jq --arg name "$chosen_app_name" '.[$name] = (.[$name] // 0) + 1' <(echo "$history") >"$tmp_history_file" && mv "$tmp_history_file" "$HISTORY_FILE"

    local exec_cmd is_terminal
    exec_cmd=$(echo "$chosen_app_details" | jq -r '.exec')
    is_terminal=$(echo "$chosen_app_details" | jq -r '.terminal')

    # Launch the application
    if [ "$is_terminal" = "true" ]; then
        nohup "$TERMCMD" zsh -c "$exec_cmd" >/dev/null 2>&1 &
    else
        # Use a login shell to ensure the user's environment is loaded
        nohup zsh -l -c "$exec_cmd" >/dev/null 2>&1 &
    fi
}

main "$@"
