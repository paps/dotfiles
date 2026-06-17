#!/bin/bash

# tailvad - set a Tailscale VPN exit node by country, or turn it off
# Usage: tailvad <country|off>
# Called via the 'tailvad' alias in zshrc

set -euo pipefail

# Simple ANSI colors
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
DIM=$'\033[2m'
RESET=$'\033[0m'

if [ $# -ne 1 ]; then
    echo "${RED}Usage: tailvad <country|off>${RESET}" >&2
    exit 1
fi

COUNTRY="$1"

is_up() {
    tailscale status > /dev/null 2>&1
}

# Hostname of the currently active exit node, if any
current_exit_node() {
    tailscale status 2>/dev/null | awk '/active/ && /exit node/ {print $2; exit}'
}

show_previous_node() {
    local previous
    previous=$(current_exit_node)
    if [ -n "$previous" ]; then
        echo "${DIM}Previous exit node: $previous${RESET}"
    fi
}

if [ "$COUNTRY" = "off" ]; then
    if ! is_up; then
        echo "${YELLOW}Tailscale is not running, nothing to do${RESET}"
        exit 0
    fi
    tailscale set --exit-node=
    tailscale down
    tailscale up
    echo "${GREEN}Exit node turned off${RESET}"
else
    if ! is_up; then
        echo "${YELLOW}Tailscale is not running, starting it${RESET}"
        tailscale up
    fi
    NODES=$(tailscale exit-node list --filter="$COUNTRY" | awk '/^[[:space:]]+[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/ {print $2}')

    NODE_COUNT=$(echo "$NODES" | wc -l)
    RANDOM_INDEX=$((RANDOM % NODE_COUNT + 1))
    CHOSEN=$(echo "$NODES" | sed -n "${RANDOM_INDEX}p")

    show_previous_node
    echo "${GREEN}Setting exit node:  $CHOSEN${RESET}"
    tailscale set --exit-node="$CHOSEN"
fi
