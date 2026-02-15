#!/bin/sh

swaymsg -t get_workspaces -r | jq -c '.[]' | while read -r ws; do
  # Workspace representation, z.B. "H[firefox]" oder "H[Alacritty]"
  rep=$(echo "$ws" | jq -r '.representation')

  # Appname extrahieren
  app=$(echo "$rep" | sed -E 's/.*\[(.*)\].*/\1/')

  # Desktop-Datei suchen (case-insensitive)
  desktop=""
  if [ -f "/usr/share/applications/$app.desktop" ]; then
    desktop="/usr/share/applications/$app.desktop"
  elif [ -f "/usr/share/applications/$(echo "$app" | sed 's/.*/\u&/').desktop" ]; then
    desktop="/usr/share/applications/$(echo "$app" | sed 's/.*/\u&/').desktop"
  else
    desktop=$(find /usr/share/applications ~/.local/share/applications -type f -iname "*$app*.desktop" | head -n1)
  fi

  # Icon-Name aus der Desktop-Datei lesen
  icon=""
  if [ -n "$desktop" ]; then
    icon=$(grep -i '^Icon=' "$desktop" | head -n1 | cut -d= -f2)
  fi

  # Icon-Datei suchen (SVG bevorzugt)
  path=""
  # SVG bevorzugt


  if [ -n "$icon" ]; then
  
    for dir in /usr/share/icons /usr/share/applications ~/.local/share/icons /usr/share/pixmaps; do
      path=$(find "$dir" -type f -iname "$icon.svg" 2>/dev/null | head -n1)
      [ -n "$path" ] && break
    done

    # PNG fallback
    if [ -z "$path" ]; then
      pngs=$(find /usr/share/icons ~/.local/share/icons /usr/share/pixmaps -type f -iname "$icon.png" 2>/dev/null)
      if [ -n "$pngs" ]; then
        path=$(echo "$pngs" | sort -t/ -k5,5nr | head -n1)
      fi
    fi
  fi

  # JSON erweitern
  echo "$ws" | jq --arg icon "$path" --arg app "$app" --arg iconName "$icon" --arg desktop "$desktop" '. + {desktopFile:$desktop, iconName: $iconName,icon: $icon, app: $app}'
done | jq -s '.'
