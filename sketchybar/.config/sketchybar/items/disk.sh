#!/usr/bin/env bash

disk=(
	background.padding_left=0
	label.font="$FONT:Heavy:12"
	icon.color="$MAGENTA"
	update_freq=60
	script="$PLUGIN_DIR/disk.sh"
)

sketchybar --add item disk right \
	--set disk "${disk[@]}"
