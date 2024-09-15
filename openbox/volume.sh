#!/usr/bin/env bash

lockfile="$HOME/.paps/openbox/.global-event-lock"
notification="$HOME/.paps/openbox/.notification-string"

if [ -f "$lockfile" ]
then
    echo "Lock file $lockfile exists"
    exit 1
fi

touch "$lockfile"

if [ $# -eq 1 ]
then
    if [ $1 = "+" ]
    then
        pactl set-sink-volume @DEFAULT_SINK@ +5%
    elif [ $1 = "-" ]
    then
        pactl set-sink-volume @DEFAULT_SINK@ -5%
    elif [ $1 = "m" ]
    then
        pactl set-sink-mute @DEFAULT_SINK@ toggle
    else
        echo "Usage: $0 +|-|m"
    fi
    echo "%{c}Vol $(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1)" > $notification
else
    echo "Usage: $0 +|-|m"
fi

rm "$lockfile"
