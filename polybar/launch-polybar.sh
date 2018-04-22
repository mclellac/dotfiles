#!/usr/bin/env bash

if type "xrandr"; then

    for w in $( xrandr --query | grep "*" | awk -Fx '{print $1}' | tr -d ' '); do
        WIDTH=${w} polybar --reload main &
    done  
    
    #for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    #    MONITOR=$m polybar --reload main &
    #done
else
  polybar --reload main &
fi
