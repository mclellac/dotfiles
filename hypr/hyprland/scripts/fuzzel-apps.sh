#!/bin/bash
#
# A robust application launcher for Fuzzel with JSON caching,
# custom overrides, usage frequency sorting, and icon support.
#
# DEPENDENCIES: jq, find, stat, awk, printf
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
APP_DIRS=()
[ -d "$HOME/.local/share/applications" ] && APP_DIRS+=("$HOME/.local/share/applications")
[ -d "$HOME/.local/share/flatpak/exports/share/applications" ] && APP_DIRS+=("$HOME/.local/share/flatpak/exports/share/applications")
IFS=':' read -r -a xdg_data_dirs <<< "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
for dir in "${xdg_data_dirs[@]}"; do
    [ -d "$dir/applications" ] && APP_DIRS+=("$dir/applications")
    [ -d "$dir/flatpak/exports/share/applications" ] && APP_DIRS+=("$dir/flatpak/exports/share/applications")
done
[ -d "/var/lib/flatpak/exports/share/applications" ] && APP_DIRS+=("/var/lib/flatpak/exports/share/applications")

# --- Cache Management ---
is_cache_stale() {
    if [ ! -f "$CACHE_FILE" ]; then return 0; fi
    local cache_mtime
    cache_mtime=$(stat -c %Y "$CACHE_FILE")
    [ -f "$OVERRIDES_FILE" ] && [ "$(stat -c %Y "$OVERRIDES_FILE")" -gt "$cache_mtime" ] && return 0
    [ "$0" -nt "$CACHE_FILE" ] && return 0
    for dir in "${APP_DIRS[@]}"; do
        [ -d "$dir" ] && [ "$(stat -c %Y "$dir")" -gt "$cache_mtime" ] && return 0
    done
    return 1
}

generate_cache() {
    local scanned_apps
    scanned_apps=$(
        find "${APP_DIRS[@]}" -mindepth 1 -type f -name "*.desktop" -print0 2>/dev/null |
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
    )
    scanned_apps=${scanned_apps:-'[]'}

    local overrides_apps
    if [ -f "$OVERRIDES_FILE" ]; then
        overrides_apps=$(jq 'to_entries | map({name: .key, exec: .value, terminal: false, icon: "application-x-executable"})' "$OVERRIDES_FILE" 2>/dev/null)
    fi
    overrides_apps=${overrides_apps:-'[]'}

    jq -n --argjson overrides "$overrides_apps" --argjson scanned "$scanned_apps" \
        '($overrides + $scanned) | unique_by(.name)' > "$CACHE_FILE"
}

# --- Main Logic ---
if is_cache_stale; then
    generate_cache
fi

if [ ! -s "$CACHE_FILE" ]; then
    echo "Application cache is empty. No applications found." >&2
    exit 1
fi

apps_with_history=$(
    jq -s '.[0] as $history | .[1] as $apps | $apps | map(. + {count: ($history[.name] // 0)})' \
    <(jq . "$HISTORY_FILE" 2>/dev/null || echo "{}") "$CACHE_FILE"
)

sorted_apps=$(echo "$apps_with_history" | jq 'sort_by(-.count, .name)')

# --- Fuzzel Execution ---
fuzzel_input_template=$(echo "$sorted_apps" | jq -r '.[] | .name + "\\0icon\\x1f" + (.icon // "application-x-executable")')

chosen_app_name=""
if ! chosen_app_name=$(printf "%b\n" "$fuzzel_input_template" | fuzzel --dmenu --log-level=none); then
    exit 0
fi

if [ -z "$chosen_app_name" ]; then
    exit 0
fi

# --- Application Launching ---
chosen_app_details=$(echo "$sorted_apps" | jq --arg name "$chosen_app_name" '.[] | select(.name == $name)')

if [ -z "$chosen_app_details" ]; then
    echo "Error: Could not find details for '$chosen_app_name'" >&2
    exit 1
fi

exec_cmd=$(echo "$chosen_app_details" | jq -r '.exec')
is_terminal=$(echo "$chosen_app_details" | jq -r '.terminal')

tmp_history_file=$(mktemp)
jq --arg name "$chosen_app_name" '.[$name] = (.[$name] // 0) + 1' <(jq . "$HISTORY_FILE" 2>/dev/null || echo "{}") > "$tmp_history_file" && mv "$tmp_history_file" "$HISTORY_FILE"

if [ "$is_terminal" = "true" ]; then
    nohup "$TERMCMD" bash -c "$exec_cmd" >/dev/null 2>&1 &
else
    nohup bash -l -c "$exec_cmd" >/dev/null 2>&1 &
fi

exit 0
