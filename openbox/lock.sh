#!/usr/bin/env bash

if [ -x "$(command -v brightnessctl)" ]
then
    # If we have brightnessctl installed, we're
    # assuming we're on a laptop so we try to
    # disable keyboard light on lock.
    brightnessctl --device kbd_backlight set 0
fi

xset s activate

