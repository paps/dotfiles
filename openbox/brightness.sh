#!/usr/bin/env bash

lockfile="$HOME/.paps/openbox/.global-event-lock"
notification="$HOME/.paps/openbox/.notification-string"
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

    # Save value for next run of this script.
    # This value is also used to maintain the chosen brightness when redshift is rerun
    # to adjust blue light (see autostart.sh)
    echo -n $value > $brightness

    # Screen brightness control:
    #  '-b' sets the brightness (first value for day, second value for night)
    #  '-l' sets our location in the world. When changing location, update the two commands with:
    #     Paris: 48.85:2.35
    #     San Francisco: 37.77:122.41
    #     Taipei: 25.03:121.56
    #     (sidenote: to change timezone, run `sudo dpkg-reconfigure tzdata`)
    #  '-m randr' skips a useless check for Wayland
    #  '-r' makes changes instantaneous (disables fading)
    #  '-o' means 'one shot mode', i.e. redshift immediately exits
    #  '-P' resets everything before applying new temp/brightness values
    #
    # /!\ redshift is also called by autostart.sh, changes should be made over there too
    redshift -m randr -l 48.85:2.35 -r -o -P -b "$value:$value" > /dev/null

    # Show a notification about what just happened
    echo "%{c}Brightness $value" > $notification

else
    echo "Usage: $0 +|-"
fi

rm "$lockfile"
