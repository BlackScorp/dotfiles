#!/bin/sh

tags="$(mmsg get all-tags)"
clients="$(mmsg get all-clients)"

jq -n \
  --argjson tags "$tags" \
  --argjson clients "$clients" '
[
  $tags.all_tags[].tags[]
  | select(.client_count > 0)
  | . as $tag

  | (
      $clients.clients[]
      | select(.tags[] == $tag.index)
    ) as $client

  | {
      name: ($tag.index | tostring),
      focused: $tag.is_active,
      appid: ($client.appid | ascii_downcase),
      title: $client.title
    }
]
'