#!/bin/sh
# dmenu became rofi at some point
exec $(rofi -modi run -show run -font "Hack Nerd Font Mono Regular 22")
