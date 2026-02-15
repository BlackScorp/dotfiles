#!/bin/sh
DEVICE="$1"

if [ -z "$DEVICE" ]; then
    echo "Usage: $0 <BT-ADDRESS>"
    exit 1
fi

echo "[*] Pairing $DEVICE ..."

bluetoothctl <<EOF
remove $DEVICE
connect $DEVICE
trust $DEVICE
EOF

echo "[*] Done."