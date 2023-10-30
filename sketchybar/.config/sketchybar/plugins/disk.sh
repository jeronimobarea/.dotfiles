#!/usr/bin/env bash

source "$CONFIG_DIR/icons.sh"

sketchybar -m --set "$NAME" icon=$DISK label="$(df -H | grep -E '^(/dev/disk3s1s1 ).' | awk '{ printf ("%s\n", $5) }')"
