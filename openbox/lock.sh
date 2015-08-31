#!/bin/sh
if [ -f ~/.paps/x/do_not_lock ] ; then
	xscreensaver-command -activate
else
	xscreensaver-command -lock
fi
