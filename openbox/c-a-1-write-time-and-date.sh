#!/usr/bin/env bash


# Doing this xclip trick instead of directly writing the date with `xdotool type`
# because xdotool cannot type any key that is being held down while it runs, such
# as '1' in the Ctrl-Alt-1 binding used to run this script, which is super annoying.

echo "$(date +'%a, %b %d, %Y, %H:%M')" | xclip -selection clipboard
xdotool key --clearmodifiers "ctrl+v"
