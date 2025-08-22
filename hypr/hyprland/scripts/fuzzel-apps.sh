#!/bin/bash
#
# A robust application launcher for Fuzzel with JSON caching,
# custom overrides, and icon support.
#
# DEPENDENCIES: jq
#

# --- Configuration & Paths ---
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fuzzel"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/fuzzel-apps"
CACHE_FILE="$CACHE_DIR/apps.json"
OVERRIDES_FILE="$CONFIG_DIR/overrides.json"

# Ensure directories exist
mkdir -p "$CONFIG_DIR" "$CACHE_DIR"

# --- Application Directories ---
APP_DIRS=""
[ -d "$HOME/.local/share/applications" ] && APP_DIRS="$APP_DIRS $HOME/.local/share/applications"
[ -d "$HOME/.local/share/flatpak/exports/share/applications" ] && APP_DIRS="$APP_DIRS $HOME/.local/share/flatpak/exports/share/applications"

XDG_DATA_DIRS=${XDG_DATA_DIRS:-/usr/local/share:/usr/share}
OLD_IFS=$IFS
IFS=':'
for dir in $XDG_DATA_DIRS; do
    [ -d "$dir/applications" ] && APP_DIRS="$APP_DIRS $dir/applications"
    [ -d "$dir/flatpak/exports/share/applications" ] && APP_DIRS="$APP_DIRS $dir/flatpak/exports/share/applications"
done
IFS=$OLD_IFS
[ -d "/var/lib/flatpak/exports/share/applications" ] && APP_DIRS="$APP_DIRS /var/lib/flatpak/exports/share/applications"

# --- Cache Generation ---
# Check if the cache is stale
STALE=0
if [ ! -f "$CACHE_FILE" ]; then
    STALE=1
else
    CACHE_MTIME=$(stat -c %Y "$CACHE_FILE")
    # Check if overrides file is newer than cache
    [ -f "$OVERRIDES_FILE" ] && [ "$(stat -c %Y "$OVERRIDES_FILE")" -gt "$CACHE_MTIME" ] && STALE=1
    # Check if any app dir is newer than cache
    if [ "$STALE" -eq 0 ]; then
        for dir in $APP_DIRS; do
            if [ -d "$dir" ] && [ "$(stat -c %Y "$dir")" -gt "$CACHE_MTIME" ]; then
                STALE=1
                break
            fi
        done
    fi
fi

if [ "$STALE" -eq 1 ]; then
    # 1. Scan all .desktop files and convert them to a stream of JSON objects
    SCANNED_APPS=$(find $(echo "$APP_DIRS" | xargs) -type f -name "*.desktop" -print0 2>/dev/null |
        while IFS= read -r -d '' desktop_file; do
            awk '
            BEGIN { FS="=" }
            /^\[Desktop Entry\]/ { in_entry=1 }
            in_entry && /^Name=/ { name=substr($0, index($0, "=") + 1) }
            in_entry && /^Exec=/ { exec_cmd=substr($0, index($0, "=") + 1) }
            in_entry && /^Icon=/ { icon=substr($0, index($0, "=") + 1) }
            in_entry && /^Terminal=/ { terminal=($2=="true") ? "true" : "false" }
            in_entry && /^NoDisplay=/ { nodisplay=($2=="true") ? "true" : "false" }
            END {
                if (name && exec_cmd && nodisplay != "true") {
                    # Clean Exec command
                    gsub(/%%/, "\a", exec_cmd); gsub(/%[a-zA-Z]/, "", exec_cmd); gsub(/\a/, "%", exec_cmd);
                    # Set defaults
                    if (!terminal) terminal="false";
                    if (!icon) icon="application-x-executable";
                    # Output JSON using jq for safe string escaping
                    printf "%s\n" name exec_cmd terminal icon | jq -R "split(\"\n\") | {name:.[0], exec:.[1], terminal:(.[2]|test(\"true\")), icon:.[3]}"
                }
            }
        ' "$desktop_file"
        done | jq -s '.')

    # 2. Convert the overrides file into a compatible JSON array
    if [ -f "$OVERRIDES_FILE" ]; then
        OVERRIDES_APPS=$(jq 'to_entries | map({name: .key, exec: .value, terminal: false, icon: "application-x-executable"})' "$OVERRIDES_FILE")
    else
        OVERRIDES_APPS="[]"
    fi

    # 3. Merge scanned apps and overrides, with overrides taking precedence.
    #    'unique_by(.name)' keeps the first occurrence, so we put overrides first.
    echo "[]" | jq --argjson overrides "$OVERRIDES_APPS" --argjson scanned "$SCANNED_APPS" \
        '($overrides + $scanned) | unique_by(.name) | sort_by(.name)' >"$CACHE_FILE"
fi

# --- Fuzzel Execution ---
# Format the JSON cache into the string Fuzzel needs for icons: text\0icon\x1f<icon_name>
FUZZEL_INPUT=$(jq -r '.[] | .name + "\u0000icon\u001f" + (.icon // "application-x-executable")' "$CACHE_FILE")

# Run Fuzzel
CHOSEN=$(printf "%s" "$FUZZEL_INPUT" | fuzzel --dmenu --log-level=none)

# Exit if Fuzzel was closed
if [ -z "$CHOSEN" ]; then
    exit 0
fi

# --- Application Launch ---
# Look up the chosen app in the JSON cache
LAUNCH_OBJ=$(jq -r --arg chosen_name "$CHOSEN" '.[] | select(.name == $chosen_name)' "$CACHE_FILE")

EXEC_CMD=$(echo "$LAUNCH_OBJ" | jq -r '.exec')
IS_TERMINAL=$(echo "$LAUNCH_OBJ" | jq -r '.terminal')

if [ "$IS_TERMINAL" = "true" ]; then
    FINAL_CMD="${TERMCMD:-kitty} $EXEC_CMD"
else
    FINAL_CMD="$EXEC_CMD"
fi

# Launch the application directly as a detached background process
nohup sh -c "$FINAL_CMD" >/dev/null 2>&1 &
