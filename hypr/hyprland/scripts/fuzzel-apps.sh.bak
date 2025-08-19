#!/usr/bin/env bash

# Get a list of all .desktop files
files=$(find /usr/share/applications ~/.local/share/applications -name "*.desktop")

# Parse each .desktop file to extract the name and exec command
apps=""
for file in $files; do
    name=$(grep -E "^Name=" "$file" | cut -d'=' -f2)
    exec=$(grep -E "^Exec=" "$file" | cut -d'=' -f2 | sed 's/ %.//')
    nodisplay=$(grep -E "^NoDisplay=" "$file" | cut -d'=' -f2)

    # Skip if NoDisplay is true or if there's no exec command
    if [ "$nodisplay" = "true" ] || [ -z "$exec" ]; then
        continue
    fi

    apps+="$name\t$exec\n"
done

# Pipe the list to fuzzel and execute the selected command
selected=$(echo -e "$apps" | fuzzel --dmenu | awk -F'\t' '{print $2}')
if [ -n "$selected" ]; then
    eval "$selected" &
fi
