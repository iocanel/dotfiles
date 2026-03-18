#!/bin/bash

# Test what swayr shows for window selection
echo "Testing swayr window display..."

# Use swaymsg to check current marks
echo "Current marks on windows:"
swaymsg -t get_tree | jq -r '
  def walk(f): 
    . as $in
    | if type == "object" then
        reduce keys_unsorted[] as $key
          ({}; . + { ($key):  ($in[$key] | walk(f)) }) | f
      elif type == "array" then map( walk(f) ) | f
      else f
      end;
  
  walk(if type == "object" and has("type") and .type == "con" and has("app_id") and .app_id != null then . else empty end) |
  select(. != null) |
  "\(.marks // []): \(.app_id) - \(.name)"
'