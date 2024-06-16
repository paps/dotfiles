#!/usr/bin/env bash

pactl set-sink-volume @DEFAULT_SINK@ 80%
pactl set-sink-mute @DEFAULT_SINK@ 0
ffplay -nodisp -t 0.3 -autoexit ~/.paps/systemd/minimal-pop-click-ui-8-198308.mp3
pactl set-sink-volume @DEFAULT_SINK@ 30%
pactl set-sink-mute @DEFAULT_SINK@ 1
