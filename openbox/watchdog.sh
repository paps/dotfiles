#!/usr/bin/env bash

# This script is continuously restarted (after a 60s wait) from autostart.sh
# Its goal is to check and report important system info

# Check that we're still protected by NextDNS
advertiser_ip=$(dig +short doubleclick.net | xargs) # xargs is used for trimming
if [ -z "$advertiser_ip" ]
then
    notify-send "dig failed on doubleclick.net — are we online?"
else
    if [ "$advertiser_ip" != "0.0.0.0" ]
    then
        notify-send "dig doubleclick.net: $advertiser_ip"
    fi
fi

# Check that we're still protected by mullvad
mullvad=$(curl 'https://am.i.mullvad.net/connected')
if [ -z "$mullvad" ]
then
    notify-send "curl failed on mullvad.net — are we online?"
else
    if [[ $mullvad != *"You are connected to Mullvad"* ]]
    then
        # Disabled while in Taiwan
        #notify-send "$mullvad"
        echo 'disabled'
    fi
fi

sleep 120

# Todo some day: notify about low battery
# ~/.paps/openbox/publish-notification.sh "Battery 50%"

sleep 120
