#!/bin/bash

swaymsg -t get_workspaces -p | awk '
BEGIN {
  print "["
  first = 1
}

# Workspace-Zeile erkennen: "Workspace 1 (focused)"
/^Workspace [0-9]+/ {
  # Falls wir schon einen Workspace gesammelt haben -> ausgeben
  if (ws != "") {
    if (!first) print ","
    first = 0

    printf "{\n"
    printf "\"key\":%d,\n", key
    printf "\"name\":\"%s\",\n", ws
    printf "\"focused\":%s,\n", focused
    printf "\"output\":\"%s\",\n", output
    printf "\"apps\":[%s]\n", apps
    printf "}"
  }

  # Reset für neuen Workspace
  apps=""
  output=""
  
  key = $2
  ws = "Workspace " key

  if ($0 ~ /\(focused\)/) focused="true"
  else focused="false"
}

# Output-Zeile
/^  Output:/ {
  output = $2
}

# Representation-Zeile
/^  Representation:/ {
  line = $0

  # alles vor "[" weg
  sub(/^.*\[/, "", line)
  # alles nach "]" weg
  sub(/\].*$/, "", line)

  n = split(line, arr, " ")
  apps = ""

  for (i=1; i<=n; i++) {
    if (apps != "") apps = apps ","
    apps = apps "\"" arr[i] "\""
  }
}

END {
  # letzten Workspace ausgeben
  if (ws != "") {
    if (!first) print ","

    printf "{\n"
    printf "\"key\":%d,\n", key
    printf "\"name\":\"%s\",\n", ws
    printf "\"focused\":%s,\n", focused
    printf "\"output\":\"%s\",\n", output
    printf "\"apps\":[%s]\n", apps
    printf "}"
  }

  print "\n]"
}
'
