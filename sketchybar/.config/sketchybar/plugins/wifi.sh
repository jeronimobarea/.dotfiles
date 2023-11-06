#!/bin/bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

# The wifi_change event supplies a $INFO variable in which the current SSID
# is passed to the script.

update() {
  INFO="$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I | awk -F ' SSID: '  '/ SSID: / {print $2}')"
  IS_VPN=$(scutil --nwi | grep -m1 'utun' | awk '{ print $1 }')
  LABEL="Not connected"

  ICON=$WIFI_NOTCONNECTED
  COLOR=$GV_RED

  if [[ $IS_VPN != "" ]]; then
  	COLOR=$CYAN
  	ICON=$WIFI_VPN
  	LABEL="VPN"
  elif [ "$INFO" != "" ]; then
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
