#!/bin/bash

# List app_id for all open windows in Sway
swaymsg -t get_tree | jq -r '.. | select(.type? == "con" and .app_id? != null) | "\(.app_id): \(.name)"'