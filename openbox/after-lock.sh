#!/usr/bin/env bash

# Script meant to be executed after successfull screen lock.
# It is triggered by xsecurelock (configured in autostart.sh).

if [ -x "$(command -v brightnessctl)" ]
then
    # If we have brightnessctl installed, we're
    # assuming we're on a laptop so we try to
    # disable keyboard light on lock.
    brightnessctl --device kbd_backlight set 0
fi

pactl set-sink-mute @DEFAULT_SINK@ 1
