#!/bin/sh
# dmenu became rofi at some point
exec $(rofi -modi drun -show drun -font "Hack Nerd Font Mono Regular 22")
