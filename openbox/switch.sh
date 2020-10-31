#!/usr/bin/env bash

if [ -r ~/.pointer ]
then
	eval $(cat ~/.pointer)
fi

echo "$(xdotool getmouselocation --shell)" > .pointer

xdotool mousemove $X $Y

# the binary is built for amd64 from https://github.com/arp242/find-cursor
~/.paps/openbox/find-cursor -w 700 -d 300 -o -s 400

