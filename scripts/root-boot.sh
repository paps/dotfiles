#!/usr/bin/env bash

# This script is meant to be run a few seconds after boot using cron.
# To set it up, run `sudo crontab -e` then add the following line:
# @reboot sleep 5 && /home/paps/.paps/scripts/root-boot.sh
#
# (A sleep is added as a cheap workaround to wait for most things to be
# ready, daemons to be loaded, etc.)
# (Note: the sysctl command is not used as it's not in PATH when the
# script runs)
#
# Important note for non-Full-Disk-Encryption setups (like my Asahi):
# this file obviously needs to be copied to where it's not encrypted
# (like /home/ instead of /home/user/...) for it to be executed before
# decryption of the home folder!



# In case an Apple keyboard is already present, let's configure it with sane options
# (if not present, these 3 commands will fail, but the script will continue anyway)
# Respect standard layout:
echo 0 > /sys/module/hid_apple/parameters/iso_layout
# Have ctrl & alt were it's expected:
echo 1 > /sys/module/hid_apple/parameters/swap_opt_cmd
# F keys are F keys:
echo 2 > /sys/module/hid_apple/parameters/fnmode



# Assumption below: running Asahi Linux on M2 Macbook Pro 16" with 16gb RAM with lots of swap
# (Note to self: refer to second-brain/2024/Asahi.md for *encrypted* swapfile config)

# zswap: compressed swap cache in RAM, avoids premature OOM on 16GB Asahi
echo Y > /sys/module/zswap/parameters/enabled
# Cap the pool at 30% of RAM (~4.8GB); with ~2.5:1 compression that's ~12GB of logical swap
echo 30 > /sys/module/zswap/parameters/max_pool_percent
# Proactively evict cold compressed pages to disk instead of waiting for the pool to fill
echo Y > /sys/module/zswap/parameters/shrinker_enabled
# Above 100 tells the kernel to prefer compressing anon pages over dropping file cache,
# which makes sense when "swapping" means compress-to-RAM rather than write-to-disk
echo 150 > /proc/sys/vm/swappiness
# Disable transparent huge pages: 2MB granularity wastes RAM under pressure,
# khugepaged causes latency spikes, and swapping 2MB chunks is expensive
echo never > /sys/kernel/mm/transparent_hugepage/enabled
# By default the kernel reads 8 swap pages at once as readahead (2^3 = 8 pages = 32KB).
# With zswap this is wasteful: each compressed page must be decompressed individually,
# and adjacent pages in swap are unlikely to be needed together. Read one page at a time.
echo 0 > /proc/sys/vm/page-cluster
# Controls how aggressively the kernel reclaims inode/dentry caches vs page cache.
# Default is 100 (equal preference). Lower values keep filesystem metadata in memory longer,
# which helps on desktops with many open files (browsers, editors, git repos) by avoiding
# redundant disk lookups to rebuild those caches.
echo 50 > /proc/sys/vm/vfs_cache_pressure
# Controls how much dirty (written but not yet flushed to disk) data can pile up in RAM.
# dirty_ratio: max % of RAM that can be dirty before a writing process is forced to wait
# for flushes (default 20% = 3.2GB on 16GB). dirty_background_ratio: threshold at which
# the kernel starts flushing in the background (default 10% = 1.6GB).
# Lower values free up RAM sooner, which matters under memory pressure.
echo 10 > /proc/sys/vm/dirty_ratio
echo 5 > /proc/sys/vm/dirty_background_ratio