#!/usr/bin/env bash
set -euo pipefail

bluetooth_info() {
    local raw
    raw="$(bluetoothctl show)"

    controller=$(echo "$raw" | awk '/^Controller/ {print $2}')
    name=$(echo "$raw" | awk -F': ' '/Name:/ {print $2; exit}')
    alias=$(echo "$raw" | awk -F': ' '/Alias:/ {print $2; exit}')
    powered=$(echo "$raw" | awk '/Powered:/ {print $2; exit}')
    discovering=$(echo "$raw" | awk '/Discovering:/ {print $2; exit}')
    discoverable=$(echo "$raw" | awk '/Discoverable:/ {print $2; exit}')
    pairable=$(echo "$raw" | awk '/Pairable:/ {print $2; exit}')

    [[ "$powered" == "yes" ]] && powered=true || powered=false
    [[ "$discovering" == "yes" ]] && discovering=true || discovering=false
    [[ "$discoverable" == "yes" ]] && discoverable=true || discoverable=false
    [[ "$pairable" == "yes" ]] && pairable=true || pairable=false

   
    devices_json="["
    first=true

    while read -r line; do
        id=$(echo "$line" | awk '{print $2}')
        dev_name=$(echo "$line" | cut -d' ' -f3-)

        info="$(bluetoothctl info "$id")"

        connected=$(echo "$info" | awk '/Connected:/ {print $2; exit}')
        paired=$(echo "$info" | awk '/Paired:/ {print $2; exit}')
        icon=$(echo "$info" | awk -F': ' '/Icon:/ {print $2; exit}')

        [[ "$connected" == "yes" ]] && status="connected" || status="disconnected"
        [[ -z "${icon:-}" ]] && icon="unknown"

        if [ "$first" = true ]; then
            first=false
        else
            devices_json+=","
        fi

        devices_json+="
        {
            \"id\": \"$id\",
            \"name\": \"$dev_name\",
            \"status\": \"$status\",
            \"paired\": \"$paired\",
            \"icon\": \"$icon\"
        }"
    done < <(bluetoothctl devices)

    devices_json+="]"

   
    cat <<EOF
{
  "controller": "$controller",
  "name": "$name",
  "alias": "$alias",
  "powered": $powered,
  "discovering": $discovering,
  "discoverable": $discoverable,
  "pairable": $pairable,
  "devices": $devices_json
}
EOF
}

bluetooth_connect() {
    local id="$1"
   
    if [ -z "$id" ]; then
        echo "Usage: $0 connect <device-id>"
        exit 1
    fi
    
    info=$(bluetoothctl info "$id")
 
    paired=$(echo "$info" | awk '/Paired:/ {print $2}')
    trusted=$(echo "$info" | awk '/Trusted:/ {print $2}')

    # Pair if not paired
    if [[ "$paired" != "yes" ]]; then
        echo "Pairing $id..."
        bluetoothctl pair "$id"
    fi

    # Trust if not trusted
    if [[ "$trusted" != "yes" ]]; then
        echo "Trusting $id..."
        bluetoothctl trust "$id"
    fi

    # Connect
    echo "Connecting $id..."
    bluetoothctl connect "$id"
}

bluetooth_disconnect() {
    local id="$1"
    if [ -z "$id" ]; then
        echo "Usage: $0 disconnect <device-id>"
        exit 1
    fi

    echo "Disconnecting $id..."
    bluetoothctl disconnect "$id"

}

bluetooth_remove() {
    local id="$1"
    if [ -z "$id" ]; then
        echo "Usage: $0 remove <device-id>"
        exit 1
    fi

    echo "Disconnecting $id..."
    bluetoothctl remove "$id"
}

case "${1:-}" in
    info)
        bluetooth_info
        ;;
    connect)
        bluetooth_connect "$2"
        ;;
    disconnect)
        bluetooth_disconnect "$2"
        ;;
          remove)
        bluetooth_remove "$2"
        ;;
    *)
        echo "Usage: $0 {info|connect <id>|disconnect <id>}"
        exit 1
        ;;
esac