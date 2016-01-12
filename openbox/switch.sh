#!/usr/bin/env bash

eval $(xdotool getmouselocation --shell)

if [ -r ~/.pointer ]
then
	eval $(cat ~/.pointer)
fi

echo "$(xdotool getmouselocation --shell)" > .pointer

xdotool mousemove $X $Y

