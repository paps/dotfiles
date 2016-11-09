#!/usr/bin/env bash

if [ $# -eq 1 ]
then
    if [ $1 = "+" ]
    then
        amixer -q set Master -M 3%+
    elif [ $1 = "-" ]
    then
        amixer -q set Master -M 3%-
    elif [ $1 = "m" ]
    then
        amixer -q set Master toggle
        amixer -q set Headphone toggle
        amixer -q set Front toggle
        amixer -q set Surround toggle
        amixer -q set Center toggle
        amixer -q set LFE toggle
        amixer -q set Line toggle
    else
        echo "Usage: $0 [+/-/m]"
        exit 1
    fi
fi
