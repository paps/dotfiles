xscreensaver &
DISPLAY=:0.0 ~/.paps/openbox/xcfg.sh
conky -c ~/.paps/openbox/stats_conkyrc &
conky -c ~/.paps/openbox/time_conkyrc &
DISPLAY=:0.0 xsetroot -solid black
DISPLAY=:0.1 xsetroot -solid black
stalonetray --dockapp-mode simple &
~/.paps/openbox/volume_late.sh &

if [ -f ~/.paps/scripts/local.sh ]
then
    ~/.paps/scripts/local.sh &
fi
