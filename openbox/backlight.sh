#!/usr/bin/env bash

if [ ! -x "$(command -v brightnessctl)" ]
then
    echo "brightnessctl command not found"
    exit 1
fi

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
		brightnessctl set '+5%'
    elif [ $1 = "-" ]
    then
		brightnessctl set '5%-'
    else
        echo "Usage: $0 +|-"
    fi
    echo "%{c}Backlight $(brightnessctl -m | cut -d, -f4)%" > $notification
else
    echo "Usage: $0 +|-"
fi

rm "$lockfile"

