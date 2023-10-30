#!/usr/bin/env bash

memory=(
	background.padding_left=0
	label.font="$FONT:Heavy:12"
	icon.color="$MAGENTA"
	update_freq=15
	script="$PLUGIN_DIR/ram.sh"
)

sketchybar --add item memory right \
	--set disk "${memory[@]}"
