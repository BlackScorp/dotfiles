#!/usr/bin/env bash
KEYBOARD="AT Translated Set 2 keyboard"

#swaymsg input "$KEYBOARD" xkb_switch_layout next

ACTIVE_LAYOUT="$(swaymsg -t get_inputs | jq -r ".[] | select(.product==\"1\") | .xkb_active_layout_name" | cut -d ' ' -f1)"

#notify-send --category=quick "⌨️ $ACTIVE_LAYOUT"