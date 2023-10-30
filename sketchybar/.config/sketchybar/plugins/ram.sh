#!/usr/bin/env bash

source "$CONFIG_DIR/icons.sh"

sketchybar -m --set "$NAME" icon=$MEMORY label="$(memory_pressure | grep "System-wide memory free percentage:" | awk '{ printf("%02.0f\n", 100-$5"%") }')%"
