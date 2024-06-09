#!/usr/bin/env bash

if [ -x "$(command -v brightnessctl)" ]
then
    # If we have brightnessctl installed, we're
    # assuming we're on a laptop so we try to
    # disable keyboard light on suspend.
    brightnessctl --device kbd_backlight set 0
fi

pactl set-sink-volume @DEFAULT_SINK@ 80%
pactl set-sink-mute @DEFAULT_SINK@ 0
ffplay -nodisp -t 0.3 -autoexit ~/.paps/systemd/minimal-pop-click-ui-8-198308.mp3
pactl set-sink-volume @DEFAULT_SINK@ 30%
pactl set-sink-mute @DEFAULT_SINK@ 1
