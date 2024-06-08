setxkbmap us

# disable beeping
xset b off
# keyboard repeat rates
xset r rate 165 28
# mouse acceleration and threshold
xset m 7/6 6

# screensaver and dpms
xset s on
xset s noblank # don't make screensaver shutdown screens, dpms will do it one minute later
if [ -f ~/.paps/x/screensaver_4h ] ; then
    # screensaver at 4h
    xset s 14400
    # screen standby at 4h1min, suspend at 4h2min, off at 4h3min
    xset dpms 14460 14520 14580
else
    # screensaver at 10min
    xset s 600
    # screen standby at 11min, suspend at 12min, off at 13min
    xset dpms 660 720 780
fi

# reset xkbmap options (empty -option)
# and swap Caps_Lock and Control_L
# and use the full bottom right row of keys for composition
setxkbmap -option -option ctrl:swapcaps -option compose:ralt -option compose:rctrl -option compose:menu -option compose:rwin

# load a few more keyboard customizations
xmodmap ~/.Xmodmap

numlockx on
