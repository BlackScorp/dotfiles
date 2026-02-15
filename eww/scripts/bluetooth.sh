#!/bin/sh
bluetoothctl devices | while read -r _ mac name_rest; do
        info="$(bluetoothctl info "$mac" 2>/dev/null)"

        name=$(echo "$info" | awk -F': ' '/^\s*Name:/ {print $2}')
        icon=$(echo "$info" | awk -F': ' '/^\s*Icon:/ {print $2}')
        paired=$(echo "$info" | awk -F': ' '/^\s*Paired:/ {print $2}')
        trusted=$(echo "$info" | awk -F': ' '/^\s*Trusted:/ {print $2}')
        connected=$(echo "$info" | awk -F': ' '/^\s*Connected:/ {print $2}')

        battery=$(echo "$info" | awk -F': ' '/^\s*Battery Percentage:/ {print $2}' | awk '{print $2}' | tr -d '()')
        [[ -z "$battery" ]] && battery=null

        # JSON object printen
        printf '{'
        printf '"mac":"%s",' "$mac"
        printf '"name":"%s",' "${name//\"/\\\"}"
        printf '"icon":"%s",' "$icon"
        printf '"paired":%s,' "$paired"
        printf '"trusted":%s,' "$trusted"
        printf '"connected":%s,' "$connected"

        if [[ "$battery" == "null" ]]; then
            printf '"battery":null'
        else
            printf '"battery":%s' "$battery"
        fi

        printf '}\n'
    done | awk '
        BEGIN { print "[" }
        { 
          if (NR>1) printf ",\n"
          printf "  %s", $0
        }
        END { print "\n]" }
    '