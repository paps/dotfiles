#!/usr/bin/env bash

# Recover the Asahi Bluetooth controller, including Blueman's software radio block.
# Run from a terminal in the desktop session, without sudo (used below as needed).
set -euo pipefail

if [[ ${1:-} == --help || ${1:-} == -h ]]; then
    echo "Usage: ${0##*/}"
    echo "Restart the hci_bcm4377 Bluetooth driver and enable Bluetooth through Blueman."
    echo "Disconnects Bluetooth devices temporarily; preserves saved pairings."
    echo "Run as your desktop user, not with sudo."
    exit 0
fi
if (( $# != 0 )); then
    echo "Unexpected argument. Use --help for usage." >&2
    exit 1
fi
if (( EUID == 0 )); then
    echo "Run without sudo so Blueman can use your desktop session." >&2
    exit 1
fi

echo "Checking required commands..."
for command in sudo systemctl busctl bluetoothctl timeout readlink; do
    if ! command -v "$command" >/dev/null; then
        echo "Missing required command: $command" >&2
        exit 1
    fi
done
if [[ ! -x /usr/sbin/modprobe ]]; then
    echo "Missing /usr/sbin/modprobe (install kmod)." >&2
    exit 1
fi
echo "Checking that hci0 uses the Asahi hci_bcm4377 driver..."
if [[ $(readlink -f /sys/class/bluetooth/hci0/device/driver) != /sys/bus/pci/drivers/hci_bcm4377 ]]; then
    echo "This script expects hci0 to use the Asahi hci_bcm4377 driver." >&2
    exit 1
fi

# Check the desktop connection before interrupting the adapter.
echo "Checking the Blueman applet in your desktop session..."
busctl --user --timeout=5s introspect org.blueman.Applet \
    /org/blueman/Applet org.blueman.Applet >/dev/null
echo "Checking sudo access (you may be prompted for your password)..."
sudo -v

service_stopped=false
module_removed=false
cleanup() {
    local result=$?
    trap - EXIT
    if $module_removed; then
        echo "Cleanup: attempting to reload the Bluetooth driver..." >&2
        sudo -n /usr/sbin/modprobe hci_bcm4377 || true
    fi
    if $service_stopped; then
        echo "Cleanup: attempting to start the Bluetooth service..." >&2
        sudo -n systemctl start bluetooth || true
    fi
    if (( result != 0 )); then
        echo "Bluetooth recovery failed. Check the latest kernel errors:" >&2
        echo "sudo journalctl -b -k --since '5 minutes ago' --no-pager -g 'Bluetooth|hci0|bcm4377'" >&2
    fi
    exit "$result"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

echo "Stopping the Bluetooth service (saved pairings are preserved)..."
sudo systemctl stop bluetooth
service_stopped=true
echo "Unloading the hci_bcm4377 driver..."
sudo /usr/sbin/modprobe -r hci_bcm4377
module_removed=true
echo "Reloading the hci_bcm4377 driver..."
sudo /usr/sbin/modprobe hci_bcm4377
module_removed=false
echo "Starting the Bluetooth service..."
sudo systemctl start bluetooth
service_stopped=false

adapter_property() {
    busctl --system --timeout=3s get-property org.bluez /org/bluez/hci0 \
        org.bluez.Adapter1 "$1"
}
wait_for() {
    local attempt
    for ((attempt = 0; attempt < 15; attempt++)); do
        if "$@"; then
            return 0
        fi
        sleep 1
    done
    return 1
}
adapter_ready() {
    adapter_property Address >/dev/null 2>&1
}
adapter_unblocked() {
    local radio
    for radio in /sys/class/rfkill/*; do
        [[ -r $radio/name ]] || continue
        if [[ $(< "$radio/name") == hci0 ]]; then
            [[ $(< "$radio/soft") == 0 && $(< "$radio/hard") == 0 ]]
            return
        fi
    done
    return 1
}
adapter_powered() {
    [[ $(adapter_property Powered 2>/dev/null) == 'b true' ]]
}

echo "Waiting for the hci0 adapter to appear in BlueZ..."
wait_for adapter_ready
echo "Clearing the software radio block through Blueman..."
# This is the extra step needed after reloading the driver: power on alone
# cannot clear rfkill. Blueman's request completes asynchronously.
busctl --user --timeout=10s call org.blueman.Applet /org/blueman/Applet \
    org.blueman.Applet SetBluetoothStatus b true
echo "Waiting for the radio block to clear..."
wait_for adapter_unblocked

echo "Powering on the adapter..."
# Blueman may still be powering it on; verify the resulting state even if
# bluetoothctl reports InProgress or reaches its deadline.
timeout 15s bluetoothctl power on || true
echo "Waiting for the adapter to report that it is powered on..."
wait_for adapter_powered

echo "Bluetooth is powered on."
