#!/bin/bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

# The wifi_change event supplies a $INFO variable in which the current SSID
# is passed to the script.

update() {
  INFO="$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I | awk -F ' SSID: '  '/ SSID: / {print $2}')"
  LABEL="Not connected"

  ICON=$WIFI_NOTCONNECTED
  COLOR=$GV_RED

  if [ "$INFO" != "" ]; then
    LABEL=$INFO
    ICON=$WIFI_CONNECTED
    COLOR=$GV_BLUE
  fi

  sketchybar --set $NAME icon=$ICON icon.color=$COLOR \
      label="$LABEL"
}

case "$SENDER" in
  "wifi_change") update
  ;;
esac
