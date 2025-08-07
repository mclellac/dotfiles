#!/bin/sh

# Use wttr.in for weather data, which is more reliable than scraping
WEATHER_DATA=$(curl -sf "wttr.in/Toronto?format=j1")

if [ -n "$WEATHER_DATA" ]; then
    WEATHER_TEMP=$(echo "$WEATHER_DATA" | jq -r ".current_condition[0].temp_C")
    WEATHER_DESC=$(echo "$WEATHER_DATA" | jq -r ".current_condition[0].weatherDesc[0].value")

    # Simple icon mapping
    ICON="?"
    case "$WEATHER_DESC" in
        *Sunny*) ICON="☀️";;
        *Clear*) ICON="☀️";;
        *Cloudy*) ICON="☁️";;
        *Partly*cloudy*) ICON="⛅️";;
        *Rain*) ICON="🌧️";;
        *Snow*) ICON="❄️";;
        *Mist*) ICON="🌫️";;
        *) ICON="";; # A generic cloud icon
    esac

    # Waybar JSON output
    echo "{\"text\": \"$ICON $WEATHER_TEMP°C\", \"tooltip\": \"$WEATHER_DESC\"}"
else
    echo "{\"text\": \"Weather N/A\", \"tooltip\": \"Could not fetch weather\"}"
fi
