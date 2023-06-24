#!/bin/bash

wifi=(
  background.corner_radius=12
  background.padding_left=5
  background.padding_right=10
  script="$PLUGIN_DIR/wifi.sh"
)

sketchybar --add item wifi right        \
           --set wifi "${wifi[@]}"      \
           --subscribe wifi wifi_change
