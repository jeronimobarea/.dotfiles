#!/bin/bash

SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15")

# Destroy space on right click, focus space on left click.
# New space by left clicking separator (>)

sid=0
spaces=()
for i in "${!SPACE_ICONS[@]}"
do
  sid=$(($i+1))

  space=(
    associated_space=$sid
    icon="${SPACE_ICONS[i]}"
    icon.padding_left=10
    icon.padding_right=10
    padding_left=2
    padding_right=2
    label.padding_right=20
    icon.color=$YABAI_SPACE_ICON_COLOR
    icon.highlight_color=$ICON_HIGHLIGHT_COLOR
    label.color=$YABAI_SPACE_LABEL_COLOR
    label.highlight_color=$LABEL_HIGHLIGHT_COLOR
    label.font="sketchybar-app-font:Regular:16.0"
    label.y_offset=-1
    background.color=$YABAI_SPACE_BACKGROUND_COLOR
    background.border_color=$YABAI_SPACE_BACKGROUND_BORDER_COLOR
    background.drawing=off
    label.drawing=off
    script="$PLUGIN_DIR/space.sh"
  )

  sketchybar --add space space.$sid left    \
             --set space.$sid "${space[@]}" \
             --subscribe space.$sid mouse.clicked
done

spaces_bracket=(
  background.color=$YABAI_SPACE_BACKGROUND_COLOR
  background.border_color=$YABAI_SPACE_BACKGROUND_BORDER_COLOR
)

separator=(
  icon=􀆊
  icon.font="$FONT:Heavy:16.0"
  padding_left=10
  padding_right=8
  label.drawing=off
  associated_display=active
  click_script='yabai -m space --create && sketchybar --trigger space_change'
  icon.color=$ICON_COLOR
)

sketchybar --add bracket spaces_bracket '/space\..*/'  \
           --set spaces_bracket "${spaces_bracket[@]}" \
                                                       \
           --add item separator left                   \
           --set separator "${separator[@]}"
