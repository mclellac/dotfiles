#!/bin/sh

WEATHER_DATA=$(curl -sf "https://www.theweathernetwork.com/en/city/ca/ontario/toronto/current")

if [ -n "$WEATHER_DATA" ]; then
    WEATHER_TEMP=$(echo "$WEATHER_DATA" | grep -A 1 '\[[0-9]\+\.svg\]' | tail -n 1 | sed 's/ //g')
    WEATHER_CONDITION=$(echo "$WEATHER_DATA" | grep -A 2 '\[[0-9]\+\.svg\]' | tail -n 1 | sed 's/ //g')

    echo "{\"text\": \"$WEATHER_TEMP°C\", \"tooltip\": \"$WEATHER_CONDITION\"}"
fi
