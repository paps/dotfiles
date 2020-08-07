xscreensaver &
~/.paps/openbox/xcfg.sh
(while true; do conky -c ~/.paps/openbox/stats_conkyrc; sleep 5; notify-send 'Restarting conky stats'; done &) # auto-restart of conky stats (crashes when too many net interfaces are created)
conky -c ~/.paps/openbox/time_conkyrc &
xsetroot -solid black
stalonetray --dockapp-mode simple --icon-size=32 --kludges=force_icons_size -v -bg black -d none --icon-gravity S --geometry 1x10 &
~/.paps/openbox/volume_late.sh &
(while true; do rescuetime; sleep 5; notify-send 'Restarting rescuetime'; done &) # auto-restart of rescuetime

redshift-gtk -l 48.85:2.35 & # Paris
# redshift-gtk -l 37.77:-122.41 & # San Francisco

# Volume feedback
volstate="$HOME/.paps/openbox/.volume-state"
[ ! -f $volstate ] && touch $volstate
while true; do
    inotifywait -e close_write -qq $volstate
    if [ $? -ne 0 ]
    then
        notify-send "inotifywait for volume feedback failed"
        sleep 30
    fi
    while
        cat $volstate
        inotifywait -e close_write -qq -t 2 $volstate
    do true; done | lemonbar -g 210x34+34+1 -d -B '#859900' -F '#fdf6e3' -f '-xos4-terminus-bold-r-normal--32-320-72-72-c-160-*-*'
done &

# Backlight feedback
lightstate="$HOME/.paps/openbox/.backlight-state"
if [ -x "$(command -v light)" ]
then
    [ ! -f $lightstate ] && touch $lightstate
    while true; do
        inotifywait -e close_write -qq $lightstate
        if [ $? -ne 0 ]
        then
            notify-send "inotifywait for backlight feedback failed"
            sleep 30
        fi
        while
            cat $lightstate
            inotifywait -e close_write -qq -t 3 $lightstate
        do true; done | lemonbar -g 250x34+34+1 -d -B '#859900' -F '#fdf6e3' -f '-xos4-terminus-bold-r-normal--32-320-72-72-c-160-*-*'
    done &
fi

# Check that we're still protected by NextDNS every 5 minutes
while true; do
    sleep 300
    advertiser_ip=$(dig +short doubleclick.net | xargs) # xargs is used for trimming
    if [ -z "$advertiser_ip" ]
    then
        notify-send "dig failed on doubleclick.net — are we online?"
    else
        if [ "$advertiser_ip" != "0.0.0.0" ]
        then
            notify-send "dig doubleclick.net: $advertiser_ip"
        fi
    fi
done &

if [ -f ~/.paps/scripts/local.sh ]
then
    ~/.paps/scripts/local.sh &
fi
