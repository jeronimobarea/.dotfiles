#!/usr/bin/env sh

sketchybar --add item     battery right                     \
           --set battery icon=battery                       \
                          icon.font="$FONT:Black:12.0"      \
                          icon.padding_right=0              \
                          label.align=right                 \
                          background.padding_left=15        \
                          update_freq=30                    \
                          script="$PLUGIN_DIR/battery.sh"
