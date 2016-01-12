#!/usr/bin/env bash

if [ -r ~/.pointer ]
then
	eval $(cat ~/.pointer)
fi

echo "$(xdotool getmouselocation --shell)" > .pointer

xdotool mousemove $X $Y

