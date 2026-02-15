#!/bin/bash
awww-daemon --no-cache &

WALLPAPER_DIR="$HOME/Bilder/Wallpapers"
WAIT_TIME=1800


 while true; do
   
    RANDOM_WALLPAPER=$(find $WALLPAPER_DIR -type f -name '*.png' -o -name '*.jpg' | shuf -n 1)

    awww img --transition-duration=0.5 -t random -a $RANDOM_WALLPAPER
    awww clear-cache
    sleep "$WAIT_TIME"
done

