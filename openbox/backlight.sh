#!/usr/bin/env bash

if [ ! -x "$(command -v light)" ]
then
    echo "light command not found"
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
        light -A 10%
    elif [ $1 = "-" ]
    then
        light -U 10%
    else
        echo "Usage: $0 +|-"
    fi
    echo "%{c}Backlight $(light -G | cut -d. -f1)%" > $notification
else
    echo "Usage: $0 +|-"
fi

rm "$lockfile"

