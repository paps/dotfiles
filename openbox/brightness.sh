#!/usr/bin/env bash

lockfile="$HOME/.paps/openbox/.brightness-lock"
brightness="$HOME/.paps/openbox/.brightness-state"
value=`cat $brightness`

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
        value=`echo $value + 0.05 | bc -l | tr '\n' ' '`
    elif [ $1 = "-" ]
    then
        value=`echo $value - 0.05 | bc -l | tr '\n' ' '`
    else
        echo "Usage: $0 +|-"
    fi
    if (( $(echo "$value > 1.0" | bc -l) )); then
        value="1.0"
    elif (( $(echo "$value < 0.2" | bc -l) )); then
        value="0.2"
    fi
    echo $value
    echo -n $value > $brightness
else
    echo "Usage: $0 +|-"
fi

rm "$lockfile"
