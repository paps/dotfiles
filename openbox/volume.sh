#!/usr/bin/env bash

if [ $# -eq 1 ]
then
    if [ $1 = "+" ]
    then
        amixer -q set Master -M 3%+
        vol=`amixer get Master -M | grep -Po ' \[\K[0-9]+(?=%\] )'`
        notify-send -t 200 -h "int:value:$vol" -i 'audio-volume-medium' '__volume__' 'Alsa Master'
    elif [ $1 = "-" ]
    then
        amixer -q set Master -M 3%-
        vol=`amixer get Master -M | grep -Po ' \[\K[0-9]+(?=%\] )'`
        notify-send -t 200 -h "int:value:$vol" -i 'audio-volume-medium' '__volume__' 'Alsa Master'
    elif [ $1 = "m" ]
    then
        amixer -q set Master toggle
        amixer -q set Headphone toggle
        amixer -q set Front toggle
        amixer -q set Surround toggle
        amixer -q set Center toggle
        amixer -q set LFE toggle
        amixer -q set Line toggle
        vol=`amixer get Master -M | grep -Po ' \[\K[0-9]+(?=%\] )'`
        mute=`amixer get Master -M | grep '\[on\]'`
        if [ $? -eq 0 ]
        then
            notify-send -t 200 -h "int:value:$vol" -i 'audio-volume-high' '__volume__' 'All channels unmuted'
        else
            notify-send -t 200 -h "int:value:$vol" -i 'audio-volume-muted' '__volume__' 'All channels muted'
        fi
    else
        echo "Usage: $0 [+/-/m]"
        exit 1
    fi
fi
