#!/bin/sh

echo "$(cat $HOME/.config/eww/config.json)" | jq -s '.'