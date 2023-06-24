#!/bin/sh

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

# The wifi_change event supplies a $INFO variable in which the current SSID
# is passed to the script.

WIFI=${INFO:-"Not Connected"}

ICON=$WIFI_NOTCONNECTED
COLOR=$GV_RED

if [ "$INFO" != "" ]; then
  ICON=$WIFI_CONNECTED
  COLOR=$GV_BLUE
fi

sketchybar --set $NAME icon=$ICON icon.color=$COLOR \
    label="${WIFI}"
