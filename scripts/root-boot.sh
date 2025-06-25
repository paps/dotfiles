#!/usr/bin/env bash

# This script is meant to be run a few seconds after boot using cron.
# To set it up, run `sudo crontab -e` then add the following line:
# @reboot sleep 5 && /home/paps/.paps/scripts/root-boot.sh
#
# (A sleep is added as a cheap workaround to wait for most things to be
# ready, daemons to be loaded, etc.)



# In case an Apple keyboard is already present, let's configure it with sane options
# (if not present, these 3 commands will fail, but the script will continue anyway)
# Respect standard layout:
echo 0 > /sys/module/hid_apple/parameters/iso_layout
# Have ctrl & alt were it's expected:
echo 1 > /sys/module/hid_apple/parameters/swap_opt_cmd
# F keys are F keys:
echo 2 > /sys/module/hid_apple/parameters/fnmode

