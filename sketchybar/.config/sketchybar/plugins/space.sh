#!/bin/bash

update() {
  source "$CONFIG_DIR/colors.sh"
  COLOR=$YABAI_SPACE_BACKGROUND_BORDER_COLOR
  BG_COLOR=$YABAI_SPACE_BACKGROUND_COLOR
  if [ "$SELECTED" = "true" ]; then
    COLOR=$YABAI_SPACE_BACKGROUND_BORDER_COLOR_ACTIVE
    BG_COLOR=$YABAI_SPACE_BACKGROUND_SELECTED_COLOR
  fi
  sketchybar --set $NAME icon.highlight=$SELECTED \
                         label.highlight=$SELECTED \
                         background.border_color=$COLOR \
                         background.color=$BG_COLOR
}

mouse_clicked() {
  if [ "$BUTTON" = "right" ]; then
    yabai -m space --destroy $SID
    sketchybar --trigger windows_on_spaces --trigger space_change
  else
    yabai -m space --focus $SID 2>/dev/null
  fi
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  *) update
  ;;
esac
