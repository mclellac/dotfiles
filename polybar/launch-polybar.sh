#!/usr/bin/env bash

if type "xrandr"; then
    m="$(xrandr | grep "connected primary" | awk '{print $1}')"

    for w in $( xrandr --query | grep "*" | awk -Fx '{print $1}' | tr -d ' '); do
        MONITOR=${m} WIDTH=${w} polybar --reload main &
    done
else
  polybar --reload main &
fi

