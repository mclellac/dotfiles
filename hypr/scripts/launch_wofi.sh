#!/bin/bash

# --- Constants ---
readonly XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
readonly XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share/:/usr/share/}"
readonly LOCK_FILE="/tmp/launch_wofi.lock"
readonly DEBUG=false
APP_DIRS=()

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

# Remove field codes from an Exec line
clean_exec() {
  local exec_line="$1"
  # Remove all field codes and their arguments
  exec_line=$(echo "$exec_line" | sed -e 's/ %[a-zA-Z]//g')
  echo "$exec_line"
}

# Get a list of all available applications
get_app_list() {
  declare -A app_list

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
  local desktop_file_path

  for APP_DIR in "${APP_DIRS[@]}"; do
      if [ -f "$APP_DIR/$chosen_app.desktop" ]; then
          desktop_file_path="$APP_DIR/$chosen_app.desktop"
          break
      fi
  done

  if [ -z "$desktop_file_path" ]; then
      # Fallback for applications where the name doesn't match the file
      for APP_DIR in "${APP_DIRS[@]}"; do
          if [ -d "$APP_DIR" ]; then
            desktop_file_path=$(grep -l "Name=$chosen_app" "$APP_DIR"/*.desktop | head -n 1)
            if [ -n "$desktop_file_path" ]; then
                break
            fi
          fi
      done
  fi

  if [ -n "$desktop_file_path" ]; then
    local try_exec
    try_exec=$(grep -E "^TryExec=" "$desktop_file_path" | cut -d'=' -f2- | head -n 1)
    if [ -n "$try_exec" ] && ! command -v "$try_exec" &> /dev/null; then
      debug "TryExec command not found: $try_exec"
      exit 1
    fi

    if grep -q "DBusActivatable=true" "$desktop_file_path"; then
      debug "Launching with gtk-launch: $chosen_app"
      gtk-launch "$chosen_app" &
    elif [ -n "$exec_cmd_to_run" ]; then
      local path
      path=$(grep -E "^Path=" "$desktop_file_path" | cut -d'=' -f2- | head -n 1)
      local cleaned_cmd
      cleaned_cmd=$(clean_exec "$exec_cmd_to_run")
      debug "Executing command: $cleaned_cmd"
      if [ -n "$path" ]; then
        debug "Setting path to: $path"
        (cd "$path" && sh -c "$cleaned_cmd" &)
      else
        sh -c "$cleaned_cmd" &
      fi
    else
      debug "No command found for '$chosen_app'."
    fi
  else
      debug "No desktop file found for '$chosen_app'."
  fi
}

# --- Main ---

main() {
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
  fi

  local chosen_app
  chosen_app=$(show_wofi_menu)

  if [ -n "$chosen_app" ]; then
    launch_application "$chosen_app"
  fi
}

main "$@"
