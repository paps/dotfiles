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
    # black overlay at 4h
    xset s 14400
    # screen standby at 4h1min, suspend at 4h2min, off at 4h3min
    xset dpms 14460 14520 14580
else
    # black overlay at 10min
    xset s 600
    # screen standby at 11min, suspend at 12min, off at 13min
    xset dpms 660 720 780
fi

setxkbmap -option compose:ralt
setxkbmap -option compose:rctrl
setxkbmap -option compose:menu
# Not using rwin as a possible compose key because it's a good Discord PTT key
#setxkbmap -option compose:rwin

xmodmap ~/.Xmodmap
numlockx on
