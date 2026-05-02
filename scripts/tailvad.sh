#!/bin/bash

# tailvad - set a Tailscale VPN exit node by country, or turn it off
# Usage: tailvad <country|off>
# Called via the 'tailvad' alias in zshrc

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: tailvad <country|off>" >&2
    exit 1
fi

COUNTRY="$1"

is_up() {
    tailscale status > /dev/null 2>&1
}

if [ "$COUNTRY" = "off" ]; then
    if ! is_up; then
        echo "Tailscale is not running, nothing to do."
        exit 0
    fi
    tailscale set --exit-node=
    tailscale down
    tailscale up
else
    if ! is_up; then
        tailscale up
    fi
    NODES=$(tailscale exit-node list --filter="$COUNTRY" | awk '/^[[:space:]]+[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/ {print $2}')

    NODE_COUNT=$(echo "$NODES" | wc -l)
    RANDOM_INDEX=$((RANDOM % NODE_COUNT + 1))
    CHOSEN=$(echo "$NODES" | sed -n "${RANDOM_INDEX}p")

    echo "Setting exit node: $CHOSEN"
    tailscale set --exit-node="$CHOSEN"
fi
