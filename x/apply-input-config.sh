#!/usr/bin/env bash

# This script is meant to be called either:
# - from a udev notification when a new keyboard appears
# - or manually by the user from the openbox menu
#
# The usual lockfile is used, along with a sleep 1 debounce
# to protect against multiple calls, e.g. multiple udev events

lockfile="$HOME/.paps/openbox/.global-event-lock"
notification="$HOME/.paps/openbox/.notification-string"

if [ -f "$lockfile" ]
then
    echo "Lock file $lockfile exists"
    exit 1
fi

touch "$lockfile"
echo "%{c}Applying input config" > $notification

# Immediately detach because udev doesn't like anything long running
(
    # Debounce in case udev sends multiple events or keyboard needs time to initialize etc
    sleep 1

    # Set these env vars if they're not already set
    # This is meant to make the script work when called from a udev notification
    : "${DISPLAY:=:0}"
    : "${XAUTHORITY:=/home/paps/.Xauthority}"

    DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY bash ~/.paps/x/input-config.sh

    echo "%{c}Applied input config" > $notification

    rm "$lockfile"
) >/dev/null 2>&1 &

exit 0
