#!/usr/bin/env bash

# this is a small helper script so that's it's easy
# to publish a notification from anywhere while having
# .global-event-lock being taken into account (prevents
# weird stuff from happening with parallel file edits)

# this script is called by /etc/acpi/events/notify-jack
# (see ../README.md)

lockfile="$HOME/.paps/openbox/.global-event-lock"
notification="$HOME/.paps/openbox/.notification-string"

if [ -f "$lockfile" ]
then
    echo "Lock file $lockfile exists"
    exit 1
fi

touch "$lockfile"

if [ $# -eq 1 ]
then
    echo "$1" > $notification
else
    echo "Usage: $0 notification_string"
fi

rm "$lockfile"

