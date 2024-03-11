#!/bin/bash

source "$CONFIG_DIR/colors.sh" # Loads all defined colors

divider=(
  background.color="$GV_BLACK_BG1"
	background.border_color="$GV_BLACK_BG2"
  background.corner_radius=4
	background.border_width=2
	background.padding_left=5
	background.padding_right=10
)

sketchybar --add bracket status wifi battery \
	--set status "${divider[@]}"
