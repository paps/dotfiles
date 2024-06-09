~/.paps/openbox/xcfg.sh
conky -c ~/.paps/openbox/stats_conkyrc &
conky -c ~/.paps/openbox/time_conkyrc &
xsetroot -solid black

# Start xsecurelock every time the X screensaver (xss) activates
# The --transfer-sleep-lock option is used to make sure this happens correctly when the laptop goes to sleep too (i.e. when the lid is closed)
XSECURELOCK_SHOW_HOSTNAME=0 XSECURELOCK_SHOW_USERNAME=0 XSECURELOCK_SHOW_DATETIME=1 XSECURELOCK_AUTH_BACKGROUND_COLOR='Slate Gray' XSECURELOCK_AUTH_TIMEOUT=5 XSECURELOCK_BLANK_TIMEOUT=10 xss-lock --transfer-sleep-lock -- xsecurelock &

# Start a standard system tray
# Depending on top or left side placement, geometry and gravity should be changed
stalonetray --dockapp-mode simple --icon-size=32 --kludges=force_icons_size -v -bg black -d none --icon-gravity W --geometry 12x1 &

(killall parcellite; sleep 5; while true; do parcellite; sleep 5; notify-send 'Restarting parcellite'; done &) # auto-restart of parcellite
ibus-daemon -d &
nm-applet &
if [ -x "$(command -v blueman-applet)" ]
then
    blueman-applet &
fi

# Start solaar (Logitech Unifying/bluetooth monitor/controller) if it's installed
if [ -x "$(command -v solaar)" ]
then
    solaar --window hide &
fi

# Generic notification system
notification="$HOME/.paps/openbox/.notification-string"
[ ! -f $notification ] && touch $notification
while true; do
    inotifywait -e close_write -qq $notification
    if [ $? -ne 0 ]
    then
        notify-send "inotifywait for ./notification-string display failed"
        sleep 30
    fi
    while
        cat $notification
        inotifywait -e close_write -qq -t 3 $notification
    do true; done | lemonbar -g 300x34+34+1 -d -B '#859900' -F '#fdf6e3' -f '-xos4-terminus-bold-r-normal--32-320-72-72-c-160-*-*'
done &

# Screen brightness control:
#  redshift is manually run every 90s to adjust screen temperature
#
#  '-b' sets the brightness (first value for day, second value for night)
#  '-l' sets our location in the world. When changing location, update the two commands with:
#     Paris: 48.85:2.35
#     San Francisco: 37.77:122.41
#     Taipei: 25.03:121.56
#     (sidenote: to change timezone, run `sudo dpkg-reconfigure tzdata`)
#  '-m randr' skips a useless check for Wayland
#  '-r' makes changes instantaneous (disables fading)
#  '-o' means 'one shot mode', i.e. redshift immediately exits
#  '-P' resets everything before applying new temp/brightness values
#
# /!\ redshift is also called by brightness.sh, changes should be made over there too
brightness="$HOME/.paps/openbox/.brightness-state"
echo -n 1.0 > $brightness
while true; do
    val=`cat $brightness`
    redshift -m randr -l 48.85:2.35 -r -o -P -b "$val:$val"
    sleep 90
done &

# Small monitoring script that notifies when xsecurelock is about to trigger because the user is inactive
while true; do
    timeleft_ms=`xssstate -t`
    timeleft=$(echo "$timeleft_ms / 1000" | bc)
    if [ $timeleft -le 3 ]
    then
        # either we're about to lock, we're already locked, or activity just happened in the last few seconds before lock
        # so we can safely wait and re-assess the situation in one minute
        sleep 60
    elif [ $timeleft -le 300 ]
    then
        # xsecurelock will activate soon, so we notify
        $HOME/.paps/openbox/publish-notification.sh "%{c}Locking in ${timeleft}s"
        sleep 5
    else
        # xsecurelock will activate in a long time, so we wait until the last moment to re-check again
        sleeptime=$(echo "$timeleft - 300" | bc)
        sleep ${sleeptime}
    fi
done &

# Restart watchdog.sh every 60s so that it can check and report important system info
while true; do
    sleep 60
    ~/.paps/openbox/watchdog.sh
done &
