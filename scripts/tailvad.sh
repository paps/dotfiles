#!/bin/bash

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: tailvad <country|off>" >&2
    exit 1
fi

COUNTRY="$1"

if [ "$COUNTRY" = "off" ]; then
    tailscale set --exit-node=
    tailscale down
    tailscale up
else
    NODES=$(tailscale exit-node list --filter="$COUNTRY" | awk '/^[[:space:]]+[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/ {print $2}')

    NODE_COUNT=$(echo "$NODES" | wc -l)
    RANDOM_INDEX=$((RANDOM % NODE_COUNT + 1))
    CHOSEN=$(echo "$NODES" | sed -n "${RANDOM_INDEX}p")

    echo "Setting exit node: $CHOSEN"
    tailscale set --exit-node="$CHOSEN"
fi
