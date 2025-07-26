#!/bin/bash

# --- Constants ---
readonly LOG_FILE="/tmp/launch_wofi.log"
readonly XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
readonly XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share/:/usr/share/}"
readonly LOCK_FILE="/tmp/launch_wofi.lock"
APP_DIRS=()

# --- Functions ---

# Log a message
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Clean up the lock file on exit
cleanup() {
  log "Cleaning up lock file."
  rm -f "$LOCK_FILE"
}

# Create a lock file to prevent multiple instances
create_lock() {
  if [ -e "$LOCK_FILE" ]; then
    log "Lock file already exists. Exiting."
    exit 1
  fi
  touch "$LOCK_FILE"
  log "Lock file created."
}

# Remove field codes from an Exec line
clean_exec() {
  local exec_line="$1"
  log "Cleaning Exec line: $exec_line"
  # Remove all field codes and their arguments
  exec_line=$(echo "$exec_line" | sed -e 's/ %[a-zA-Z]//g')
  log "Cleaned Exec line: $exec_line"
  echo "$exec_line"
}

# Get a list of all available applications
get_app_list() {
  declare -A app_list

  local config_file
  config_file="$(dirname "$0")/default/wofi_apps"
  log "Reading config file: $config_file"

  if [ -f "$config_file" ]; then
    while IFS=':' read -r app_name exec_cmd; do
      if [[ ! "$app_name" =~ ^#.* ]]; then
        log "Adding custom app: $app_name -> $exec_cmd"
        app_list["$app_name"]="$exec_cmd"
      fi
    done < "$config_file"
  else
    log "Config file not found."
  fi

  for APP_DIR in "${APP_DIRS[@]}"; do
    if [ ! -d "$APP_DIR" ]; then
      log "Directory not found: $APP_DIR"
      continue
    fi

    log "Searching for desktop files in: $APP_DIR"
    for desktop_file in "$APP_DIR"/*.desktop; do
      if [ -f "$desktop_file" ]; then
        if grep -q "NoDisplay=true" "$desktop_file"; then
          log "Skipping NoDisplay=true file: $desktop_file"
          continue
        fi

        local app_name
        app_name=$(grep -E "^Name=" "$desktop_file" | cut -d'=' -f2- | head -n 1)
        local exec_cmd
        exec_cmd=$(grep -E "^Exec=" "$desktop_file" | cut -d'=' -f2- | head -n 1)

        if [ -n "$app_name" ] && [ -n "$exec_cmd" ]; then
          log "Found app: $app_name -> $exec_cmd"
          app_list["$app_name"]="$exec_cmd"
        fi
      fi
    done
  done
  log "Returning application list: ${!app_list[@]}"
  echo "${!app_list[@]}"
}

# Show the wofi menu and get the chosen application
show_wofi_menu() {
  log "Showing wofi menu."
  local wofi_menu_input
  wofi_menu_input=$(get_app_list | tr ' ' '\n')
  echo -e "$wofi_menu_input" | wofi --show dmenu --style ~/.config/wofi/themes/gruvbox.css
}

# Launch the chosen application
launch_application() {
  local chosen_app="$1"
  log "Chosen app: $chosen_app"
  declare -A app_list

  local config_file
  config_file="$(dirname "$0")/default/wofi_apps"
  log "Reading config file: $config_file"

  if [ -f "$config_file" ]; then
    while IFS=':' read -r app_name exec_cmd; do
      if [[ ! "$app_name" =~ ^#.* ]]; then
        app_list["$app_name"]="$exec_cmd"
      fi
    done < "$config_file"
  else
    log "Config file not found."
  fi

  for APP_DIR in "${APP_DIRS[@]}"; do
    if [ ! -d "$APP_DIR" ]; then
      log "Directory not found: $APP_DIR"
      continue
    fi

    for desktop_file in "$APP_DIR"/*.desktop; do
      if [ -f "$desktop_file" ];
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
  log "Command to run: $exec_cmd_to_run"
  local desktop_file_path

  # Find the desktop file by searching for the Name field
  for APP_DIR in "${APP_DIRS[@]}"; do
      if [ -d "$APP_DIR" ]; then
        desktop_file_path=$(grep -l "Name=$chosen_app" "$APP_DIR"/*.desktop | head -n 1)
        if [ -n "$desktop_file_path" ]; then
            log "Found desktop file: $desktop_file_path"
            break
        fi
      fi
  done

  if [ -n "$exec_cmd_to_run" ]; then
      if [ -n "$desktop_file_path" ]; then
        log "Found desktop file. Checking for TryExec, DBusActivatable, and Path."
        local try_exec
        try_exec=$(grep -E "^TryExec=" "$desktop_file_path" | cut -d'=' -f2- | head -n 1)
        if [ -n "$try_exec" ] && ! command -v "$try_exec" &> /dev/null; then
          log "TryExec command not found: $try_exec. Exiting."
          exit 1
        fi

        if grep -q "DBusActivatable=true" "$desktop_file_path"; then
          log "Launching with gtk-launch: $chosen_app"
          gtk-launch "$chosen_app" &
        else
          local path
          path=$(grep -E "^Path=" "$desktop_file_path" | cut -d'=' -f2- | head -n 1)
          local cleaned_cmd
          cleaned_cmd=$(clean_exec "$exec_cmd_to_run")
          log "Executing command: $cleaned_cmd"
          if [ -n "$path" ]; then
            log "Setting path to: $path"
            (cd "$path" && sh -c "$cleaned_cmd" &)
          else
            sh -c "$cleaned_cmd" &
          fi
        fi
      else
        log "No desktop file found. Executing command directly."
        local cleaned_cmd
        cleaned_cmd=$(clean_exec "$exec_cmd_to_run")
        log "Executing command: $cleaned_cmd"
        sh -c "$cleaned_cmd" &
      fi
  else
      log "No command found for '$chosen_app'."
  fi
}

# --- Main ---

main() {
  log "--- Starting launch_wofi.sh ---"
  log "User: $(whoami)"
  log "HOME: $HOME"
  log "PATH: $PATH"
  log "XDG_DATA_HOME: $XDG_DATA_HOME"
  log "XDG_DATA_DIRS: $XDG_DATA_DIRS"

  trap cleanup EXIT
  create_lock

  IFS=':' read -ra DIRS <<< "$XDG_DATA_DIRS"
  for dir in "${DIRS[@]}"; do
    if [ -n "$dir" ]; then
      APP_DIRS+=("$dir/applications")
    fi
  done
  if [ -n "$XDG_DATA_HOME" ]; then
    APP_DIRS+=("$XDG_DATA_HOME/applications")
    APP_DIRS+=("$XDG_DATA_HOME/flatpak/exports/share/applications")
  fi
  APP_DIRS+=("/var/lib/flatpak/exports/share/applications")
  log "APP_DIRS: ${APP_DIRS[@]}"

  local chosen_app
  chosen_app=$(show_wofi_menu)

  if [ -n "$chosen_app" ]; then
    launch_application "$chosen_app"
  fi
  log "--- Exiting launch_wofi.sh ---"
}

main "$@"
