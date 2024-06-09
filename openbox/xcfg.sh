setxkbmap us

# disable beeping
xset b off
# keyboard repeat rates
xset r rate 165 28
# mouse acceleration and threshold
xset m 7/6 6 # from what I understand, this is a no-op on any modern system with libinput

# screensaver and dpms
xset s on
xset s noblank # don't make screensaver shutdown screens, xsecurelock will do it, or dpms will do it one minute later
xset s 1200 # screensaver at 20min
xset dpms 1260 1320 1380 # screen standby at 21min, suspend at 22min, off at 23min

# reset xkbmap options (empty -option)
# and swap Caps_Lock and Control_L
# and use the full bottom right row of keys for composition
setxkbmap -option -option ctrl:swapcaps -option compose:ralt -option compose:rctrl -option compose:menu -option compose:rwin

# load a few more keyboard customizations
xmodmap ~/.Xmodmap

numlockx on
