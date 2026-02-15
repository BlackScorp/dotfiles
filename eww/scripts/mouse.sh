#!/bin/bash



read x y <<< $(swaymsg -t get_inputs -r  | grep -A5 '"type":"pointer"'  | grep -Eo '"position_[xy]":[0-9]+' \
  | sed 's/.*://g' \
  | xargs)


echo "${x}x${y}"


