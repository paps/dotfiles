#!/bin/sh
# dmenu became rofi at some point
exec $(rofi -modi run -show run -font "JetBrains Mono 22")
