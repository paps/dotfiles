# This script is called from openbox/autostart.sh,
# almost as a first step for the desktop session.
#
# It is also called by x/apply-input-config.sh, useful
# when a new keyboard appears (udev notification) or
# when the user wants to trigger it manually (openbox
# menu)

setxkbmap us

# disable beeping
xset b off
# keyboard repeat rates
xset r rate 165 28
# mouse acceleration and threshold
xset m 7/6 6 # from what I understand, this is a no-op on any modern system with libinput

# reset xkbmap options (empty -option)
# and swap Caps_Lock and Control_L
# and use the full bottom right row of keys for composition
setxkbmap -option -option ctrl:swapcaps -option compose:ralt -option compose:rctrl -option compose:menu -option compose:rwin

# load a few more keyboard customizations
xmodmap ~/.Xmodmap

numlockx on
