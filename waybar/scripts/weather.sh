#!/bin/sh

# Use wttr.in for weather data, which is more reliable than scraping
WEATHER_DATA=$(curl -sf "wttr.in/Toronto?format=j1")

if [ -n "$WEATHER_DATA" ]; then
    # Safely extract data
    WEATHER_TEMP=$(echo "$WEATHER_DATA" | jq -r ".current_condition[0].temp_C")
    WEATHER_DESC=$(echo "$WEATHER_DATA" | jq -r ".current_condition[0].weatherDesc[0].value")

    # Icon mapping
    ICON="" # Default icon
    case "$WEATHER_DESC" in
        *Sunny*) ICON="☀️";;
        *Clear*) ICON="☀️";;
        *Cloudy*) ICON="☁️";;
        *Partly*cloudy*) ICON="⛅️";;
        *Rain*) ICON="🌧️";;
        *Snow*) ICON="❄️";;
        *Mist*) ICON="🌫️";;
    esac

    TEXT_CONTENT="$ICON $WEATHER_TEMP°C"

    # Use jq to safely construct the JSON output
    jq -n --arg text "$TEXT_CONTENT" --arg tooltip "$WEATHER_DESC" '{"text": $text, "tooltip": $tooltip}'
else
    # Fallback JSON
    jq -n '{"text": "Weather N/A", "tooltip": "Could not fetch weather"}'
fi
