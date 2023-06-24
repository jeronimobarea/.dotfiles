#!/bin/bash

calendar=(
  label.font="$FONT:Bold:14.0"
  label.align=right
  update_freq=30
  script="$PLUGIN_DIR/calendar.sh"
)

sketchybar --add item calendar right       \
           --set calendar "${calendar[@]}" \
           --subscribe calendar system_woke
