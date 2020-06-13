setxkbmap us

xset b off
xset r rate 165 28
xset m 7/6 6

setxkbmap -option compose:ralt
setxkbmap -option compose:rctrl
setxkbmap -option compose:menu
# Not using rwin as a possible compose key because it's a good Discord PTT key
#setxkbmap -option compose:rwin

xmodmap ~/.Xmodmap
numlockx on
