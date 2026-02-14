#!/usr/bin/env bash

eval $(xdotool getmouselocation --shell)

if [ -r ~/.dotfiles-last-pointer-location ]
then
	eval $(cat ~/.dotfiles-last-pointer-location)
fi

echo "$(xdotool getmouselocation --shell)" > ~/.dotfiles-last-pointer-location

xdotool mousemove $X $Y

