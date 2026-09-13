#!/usr/bin/env bash

if resolvectl flush-caches
then
    "$HOME/.paps/openbox/publish-notification.sh" "%{c}DNS cache flushed"
else
    "$HOME/.paps/openbox/publish-notification.sh" "%{c}Failed to flush DNS cache"
    exit 1
fi
