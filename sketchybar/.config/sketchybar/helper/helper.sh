#!/bin/bash

HELPER=git.felix.helper
killall helper
cd "$HOME"/sketchybar/.config/sketchybar/helper && make
"$HOME"/sketchybar/.config/sketchybar/helper/helper "$HELPER" >/dev/null 2>&1 &
