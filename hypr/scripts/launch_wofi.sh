#!/bin/bash

# Set the paths to the applications directories
APP_DIRS=("/usr/share/applications" "$HOME/.local/share/applications")

# Find all .desktop files and process them
declare -A app_list
for APP_DIR in "${APP_DIRS[@]}"; do
  # Check if the directory exists
  if [ ! -d "$APP_DIR" ]; then
    continue
  fi

  for desktop_file in "$APP_DIR"/*.desktop; do
    if [ -f "$desktop_file" ]; then
      # Skip files that are not regular files
      if grep -q "NoDisplay=true" "$desktop_file"; then
        continue
      fi

      # Extract the name and exec command
      app_name=$(grep -E "^Name=" "$desktop_file" | cut -d'=' -f2- | head -n 1)
      exec_cmd=$(grep -E "^Exec=" "$desktop_file" | cut -d'=' -f2- | head -n 1)

      # Check if both name and exec command are present
      if [ -n "$app_name" ] && [ -n "$exec_cmd" ]; then
        app_list["$app_name"]="$exec_cmd"
      fi
    fi
  done
done

# Create a string for wofi menu
wofi_menu_input=""
for app_name in "${!app_list[@]}"; do
  wofi_menu_input+="$app_name\n"
done

# Show wofi menu and get the chosen application name
chosen_app=$(echo -e "$wofi_menu_input" | wofi --show dmenu --style ~/.config/wofi/themes/gruvbox.css)

# If an application was chosen, execute its command
if [ -n "$chosen_app" ]; then
  exec_cmd_to_run="${app_list[$chosen_app]}"
  if [ -n "$exec_cmd_to_run" ]; then
    # Remove desktop file arguments like %U, %f, etc.
    cleaned_cmd=$(echo "$exec_cmd_to_run" | sed -e 's/ %[UuFfcCk]//g')
    # Execute the command in the background
    $cleaned_cmd &
    exit 0
  else
    echo "Error: No command found for '$chosen_app'." >&2
    exit 1
  fi
fi
exit 0
