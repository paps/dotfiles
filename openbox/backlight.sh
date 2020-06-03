#!/usr/bin/env bash

if [ ! -x "$(command -v xbacklight)" ]
then
    echo "xbacklight command not found"
    exit 1
fi

lockfile="$HOME/.paps/openbox/.backlight-lock"
lightstate="$HOME/.paps/openbox/.backlight-state"

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
        xbacklight -inc 10
    elif [ $1 = "-" ]
    then
        xbacklight -dec 10
    else
        echo "Usage: $0 +|-"
    fi
    echo " Backlight $(xbacklight -get | cut -d. -f1)%" > $lightstate
else
    echo "Usage: $0 +|-"
fi

rm "$lockfile"

