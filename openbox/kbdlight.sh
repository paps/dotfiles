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

value=`brightnessctl --device kbd_backlight get`

if [ $value = "0" ]
then
    brightnessctl --device kbd_backlight set 128
    echo "%{c}Kbdlight 50%" > $notification
else
    if [ $value = "128" ]
    then
        brightnessctl --device kbd_backlight set 255
        echo "%{c}Kbdlight max" > $notification
    else
        brightnessctl --device kbd_backlight set 0
        echo "%{c}Kbdlight off" > $notification
    fi
fi

rm "$lockfile"

