#!/bin/sh


mmsg -g -t | awk '
BEGIN { printf "["; first=1 }

$2=="tag" && ($5>0 || $4>0) {
    if (!first) printf ","
    first=0
    printf "{\"name\":%s,\"focused\":%s}", $3, ($4==1?"true":"false")
}

END { print "]" }
'
