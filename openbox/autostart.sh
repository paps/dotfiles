xscreensaver &
~/.paps/openbox/xcfg.sh
conky -c ~/.paps/openbox/stats_conkyrc &
conky -c ~/.paps/openbox/time_conkyrc &
xsetroot -solid black
stalonetray --dockapp-mode simple --icon-size=32 --kludges=force_icons_size -v -bg black -d none --icon-gravity S --geometry 1x8 &
~/.paps/openbox/volume_late.sh &
rescuetime &
volumeicon &
redshift-gtk &

if [ -f ~/.paps/scripts/local.sh ]
then
    ~/.paps/scripts/local.sh &
fi
