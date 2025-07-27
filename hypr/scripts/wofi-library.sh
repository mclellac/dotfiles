#!/bin/bash

library="$HOME/Documents" # There are only pdfs, epubs, and djvus in here
cd "$library" || exit 1
wofi_theme="-theme ~/.config/wofi/themes/library.css"

file=$(
    fd . -tf -e 'pdf' -e 'epub' -e 'djvu' | \
    wofi -dmenu -i -matching normal -p "" "$wofi_theme" \
)

if [[ $file ]]; then
    if [[ $file == *.epub ]]; then
        # Terminal ebook reader
        # https://github.com/wustho/epy
        $TERM epy "$library"/"$file"
        exit 0
    else
        zathura "$library"/"$file"
        exit 0
    fi
fi
exit 1
