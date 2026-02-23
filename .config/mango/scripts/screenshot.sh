#!/usr/bin/env bash



DEFAULT_DIR="$HOME/Screenshots"
SCREENSHOT_DIR="${SCREENSHOT_DIR:-$DEFAULT_DIR}"


mkdir -p "$SCREENSHOT_DIR"


FILENAME="screenshot_$(date +%H-%M-%S).png"
FILEPATH="$SCREENSHOT_DIR/$FILENAME"


if [[ "$1" == "selection" ]]; then
  
    grim -g "$(slurp)" "$FILEPATH"
else
    grim "$FILEPATH"
fi


notify-send "Screenshot" "Gespeichert in $FILEPATH"