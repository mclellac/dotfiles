#!/bin/bash

# --- Constants ---
readonly XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
readonly XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share/:/usr/share/}"
APP_DIRS=()
readonly LOCK_FILE="/tmp/launch_wofi.lock"
readonly DEBUG=false

# --- Functions ---

# Log a debug message
debug() {
  if [ "$DEBUG" = true ]; then
    echo "DEBUG: $1" >&2
  fi
}

# Clean up the lock file on exit
cleanup() {
  debug "Cleaning up lock file."
  rm -f "$LOCK_FILE"
}

# Create a lock file to prevent multiple instances
create_lock() {
  if [ -e "$LOCK_FILE" ]; then
    debug "Lock file already exists. Exiting."
    exit 1
  fi
  touch "$LOCK_FILE"
  debug "Lock file created."
}

# Get a list of all available applications
get_app_list() {
  declare -A app_list

  IFS=':' read -ra DIRS <<< "$XDG_DATA_DIRS"
  for dir in "${DIRS[@]}"; do
    APP_DIRS+=("$dir/applications")
  done
  APP_DIRS+=("$XDG_DATA_HOME/applications")

  for APP_DIR in "${APP_DIRS[@]}"; do
    if [ ! -d "$APP_DIR" ]; then
      debug "Directory not found: $APP_DIR"
      continue
    fi

    for desktop_file in "$APP_DIR"/*.desktop; do
      if [ -f "$desktop_file" ]; then
        if grep -q "NoDisplay=true" "$desktop_file"; then
          continue
        fi

        local app_name
        app_name=$(grep -E "^Name=" "$desktop_file" | cut -d'=' -f2- | head -n 1)
        local exec_cmd
        exec_cmd=$(grep -E "^Exec=" "$desktop_file" | cut -d'=' -f2- | head -n 1)

        if [ -n "$app_name" ] && [ -n "$exec_cmd" ]; then
          app_list["$app_name"]="$exec_cmd"
        fi
      fi
    done
  done
  echo "${!app_list[@]}"
}

# Show the wofi menu and get the chosen application
show_wofi_menu() {
  local wofi_menu_input
  wofi_menu_input=$(get_app_list | tr ' ' '\n')
  echo -e "$wofi_menu_input" | wofi --show dmenu --style ~/.config/wofi/themes/gruvbox.css
}

# Launch the chosen application
launch_application() {
  local chosen_app="$1"
  declare -A app_list

  IFS=':' read -ra DIRS <<< "$XDG_DATA_DIRS"
  for dir in "${DIRS[@]}"; do
    APP_DIRS+=("$dir/applications")
  done
  APP_DIRS+=("$XDG_DATA_HOME/applications")

  for APP_DIR in "${APP_DIRS[@]}"; do
    if [ ! -d "$APP_DIR" ]; then
      debug "Directory not found: $APP_DIR"
      continue
    fi

    for desktop_file in "$APP_DIR"/*.desktop; do
      if [ -f "$desktop_file" ]; then
        if grep -q "NoDisplay=true" "$desktop_file"; then
          continue
        fi

        local app_name
        app_name=$(grep -E "^Name=" "$desktop_file" | cut -d'=' -f2- | head -n 1)
        local exec_cmd
        exec_cmd=$(grep -E "^Exec=" "$desktop_file" | cut -d'=' -f2- | head -n 1)

        if [ -n "$app_name" ] && [ -n "$exec_cmd" ]; then
          app_list["$app_name"]="$exec_cmd"
        fi
      fi
    done
  done

  local exec_cmd_to_run="${app_list[$chosen_app]}"

  if [ -n "$exec_cmd_to_run" ]; then
    local cleaned_cmd
    cleaned_cmd=$(echo "$exec_cmd_to_run" | sed -e 's/ %[UuFfcCk]//g')
    debug "Executing command: $cleaned_cmd"
    $cleaned_cmd &
  else
    debug "No command found for '$chosen_app'."
  fi
}

# --- Main ---

main() {
  trap cleanup EXIT
  create_lock

  local chosen_app
  chosen_app=$(show_wofi_menu)

  if [ -n "$chosen_app" ]; then
    launch_application "$chosen_app"
  fi
}

main "$@"
