#!/bin/sh
# rebuild font.dir file
mkfontdir ~/.paps/fonts
# add .fonts to font path
xset fp+ ~/.paps/fonts
# tell X to reread fonts
xset fp rehash
# register ttf fonts with fontconfig
fc-cache ~/.fonts
