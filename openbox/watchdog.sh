#!/usr/bin/env bash

# This script is continuously restarted (after a 60s wait) from autostart.sh
# Its goal is to check and report important system info

# Only run checks every 15 minutes instead of continuously
current_minute=$(date +%M)
minute_mod=$(( current_minute % 15 ))
if [ $minute_mod -ne 0 ]; then
    exit 0
fi

# Check that we're still protected by NextDNS
# Using a more neutral domain instead of an ad network
advertiser_ip=$(dig +short example.com | xargs) # xargs is used for trimming
if [ -z "$advertiser_ip" ]; then
    # Only notify if we seem to be online but DNS is failing
    if ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
        notify-send "DNS resolution failed — check NextDNS configuration"
    fi
else
    # We could check for expected NextDNS behavior here if needed
    # But avoid unnecessary notifications
    :
fi

sleep 30

# Check that we're still protected by mullvad
# Only if the Mullvad service actually exists on this system
if command -v mullvad >/dev/null 2>&1; then
    mullvad=$(curl --silent --max-time 3 'https://am.i.mullvad.net/connected')
    if [ -n "$mullvad" ] && [[ $mullvad != *"You are connected to Mullvad"* ]]; then
        # Only notify if Mullvad is installed but not connected
        notify-send "Mullvad VPN not connected"
    fi
fi

# Todo some day: notify about low battery
# Check battery only if battery exists
if [ -d /sys/class/power_supply/BAT* ] 2>/dev/null; then
    for battery in /sys/class/power_supply/BAT*; do
        if [ -f "$battery/capacity" ]; then
            capacity=$(cat "$battery/capacity")
            status=$(cat "$battery/status")
            if [ "$status" = "Discharging" ] && [ "$capacity" -le 15 ]; then
                ~/.paps/openbox/publish-notification.sh "%{c}Battery at ${capacity}%"
            fi
        fi
    done
fi
