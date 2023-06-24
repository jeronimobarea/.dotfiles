#!/bin/bash

battery=(
  background.corner_radius=12
  background.padding_left=5
  background.padding_right=10
  icon.font="$FONT:Regular:19.0"
  update_freq=120
  updates=on
  script="$PLUGIN_DIR/battery.sh"
)

sketchybar --add item battery right      \
           --set battery "${battery[@]}" \
           --subscribe battery power_source_change system_woke
