#!/usr/bin/env bash

lockfile="$HOME/.paps/openbox/.volume-lock"
volstate="$HOME/.paps/openbox/.volume-state"

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
        amixer -q set Master -M 5%+
    elif [ $1 = "-" ]
    then
        amixer -q set Master -M 5%-
    elif [ $1 = "m" ]
    then
        amixer -q set Master toggle
        amixer -q set Headphone toggle
        amixer -q set Front toggle
        amixer -q set Surround toggle
        amixer -q set Center toggle
        amixer -q set LFE toggle
        amixer -q set Line toggle
    else
        echo "Usage: $0 +|-|m"
    fi
    amixer sget Master | grep -m 1 -Eo ' \[[0-9]{1,3}%\] \[(on|off)\]' > $volstate
else
    echo "Usage: $0 +|-|m"
fi

rm "$lockfile"
