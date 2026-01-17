#!/bin/sh
# Wrapper for mpv to handle Wayland vs X11 vs macOS correctly
# Mutt passes the filename as the first argument

FILE="$1"

if [ "$(uname)" = "Darwin" ]; then
    # macOS
    mpv --autofit-larger=90%x90% "$FILE"
elif [ "$(uname)" = "Linux" ]; then
    if [ -n "$WAYLAND_DISPLAY" ]; then
        # Wayland detected. Force GPU context to wayland to avoid X11 fallback assertions.
        mpv --autofit-larger=90%x90% --vo=gpu --gpu-context=wayland "$FILE"
    else
        # Fallback (X11 or other)
        mpv --autofit-larger=90%x90% "$FILE"
    fi
else
    # Fallback for other OS
    mpv --autofit-larger=90%x90% "$FILE"
fi
