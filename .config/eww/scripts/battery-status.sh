#!/usr/bin/env bash

POWER_SUPPLY_PATH="/sys/class/power_supply"

# EWW Variablen holen
BATTERY_ANIMATION=$(eww get battery_animation 2>/dev/null)
CRITICAL_THRESHOLD=$(eww get battery_critical_threshold 2>/dev/null)

# Fallbacks
BATTERY_ANIMATION=${BATTERY_ANIMATION:-true}
CRITICAL_THRESHOLD=${CRITICAL_THRESHOLD:-15}

# Animation vorbereiten (nur wenn nötig)
if [ "$BATTERY_ANIMATION" = "true" ]; then
  frame=$(( $(date +%s) % 10 ))
fi

# Icons
charging_icons=(
"󰢜" "󰂆" "󰂇" "󰂈" "󰢝"
"󰂉" "󰢞" "󰂊" "󰂋" "󰂅"
)

discharging_icons=(
"󰁺" "󰁻" "󰁼" "󰁽" "󰁾"
"󰁿" "󰂀" "󰂁" "󰂂" "󰁹"
)

echo "{"

first=1

for bat in "$POWER_SUPPLY_PATH"/BAT*; do
  [ -d "$bat" ] || continue

  name=$(basename "$bat")
  capacity=$(cat "$bat/capacity")
  status=$(cat "$bat/status")

  index=$(( capacity / 10 ))
  [ "$index" -gt 9 ] && index=9

  final_status="$status"
  icon=""

  # Critical prüfen (nur bei Discharging sinnvoll)
  if [ "$capacity" -le "$CRITICAL_THRESHOLD" ] && [ "$status" = "Discharging" ]; then
    final_status="Critical"
  fi

  # Icon bestimmen
  case "$final_status" in
    Charging)
      if [ "$BATTERY_ANIMATION" = "true" ]; then
        icon="${charging_icons[$frame]}"
      else
        icon="${charging_icons[$index]}"
      fi
      ;;
    Discharging)
      icon="${discharging_icons[$index]}"
      ;;
    Full)
      icon="󰂅"
      ;;
    'Not charging')
      icon="󰂅"
      ;;
    Critical)
      icon="󰂃"   # Low Battery Icon
      ;;
    *)
      icon="󰂑"
      ;;
  esac

  # Komma Handling
  if [ $first -eq 0 ]; then
    echo ","
  fi
  first=0

  cat <<EOF
  "$name": {
    "icon": "$icon",
    "status": "$final_status",
    "capacity": $capacity
  }
EOF

done

echo "}"