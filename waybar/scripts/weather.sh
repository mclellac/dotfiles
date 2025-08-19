#!/bin/sh

if ! command -v jq >/dev/null; then
    echo '{"text": "ERR: jq not found", "tooltip": "Please install jq to use the weather widget."}'
    exit 1
fi

if ! command -v curl >/dev/null; then
    echo '{"text": "ERR: curl not found", "tooltip": "Please install curl to use the weather widget."}'
    exit 1
fi

WEATHER_DATA=$(curl -sf "wttr.in/Toronto?format=j1")

if [ -z "$WEATHER_DATA" ]; then
    echo '{"text": "Weather N/A", "tooltip": "Could not fetch weather data from wttr.in"}'
    exit 0
fi

# The jq parsing can fail if the structure of the JSON from wttr.in changes.
# It's better to parse it once and check for errors.
PARSED_DATA=$(echo "$WEATHER_DATA" | jq -c ".current_condition[0]")

if [ -z "$PARSED_DATA" ] || [ "$PARSED_DATA" = "null" ]; then
    echo '{"text": "Weather N/A", "tooltip": "Could not parse weather data."}'
    exit 0
fi

WEATHER_TEMP=$(echo "$PARSED_DATA" | jq -r ".temp_C")
WEATHER_DESC=$(echo "$PARSED_DATA" | jq -r ".weatherDesc[0].value")

ICON=""
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

jq -n --arg text "$TEXT_CONTENT" --arg tooltip "$WEATHER_DESC" '{"text": $text, "tooltip": $tooltip}'
