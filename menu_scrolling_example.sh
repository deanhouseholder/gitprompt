#!/bin/bash

source "${0%/*}/menu_scrolling.sh"

# To change the marker, set this variable:
#menu_marker=$(echo -e "\u27A5")

# To change the highlighted entry style, set the following variables:
#menu_fg="\e[38;5;13m"
#menu_bg="\e[48;5;6m"

# To add a blank line between menu items set:
#menu_padding=1

# Define Menu variables
header="Select an option and press Enter to select, or ESC/Q to quit."
menu=(
  "Menu Entry 1"  "Menu Entry 2"  "Menu Entry 3"  "Menu Entry 4"  "Menu Entry 5"
  "Menu Entry 6"  "Menu Entry 7"  "Menu Entry 8"  "Menu Entry 9"  "Menu Entry 10"
  "Menu Entry 11" "Menu Entry 12" "Menu Entry 13" "Menu Entry 14" "Menu Entry 15"
  "Menu Entry 16" "Menu Entry 17" "Menu Entry 18" "Menu Entry 19" "Menu Entry 20"
  "Menu Entry 21" "Menu Entry 22" "Menu Entry 23" "Menu Entry 24" "Menu Entry 25"
  "Menu Entry 26" "Menu Entry 27" "Menu Entry 28" "Menu Entry 29" "Menu Entry 30"
  "Menu Entry 31" "Menu Entry 32" "Menu Entry 33" "Menu Entry 34" "Menu Entry 35"
  "Menu Entry 36" "Menu Entry 37" "Menu Entry 38" "Menu Entry 39" "Menu Entry 40"
  "Menu Entry 41" "Menu Entry 42" "Menu Entry 43" "Menu Entry 44" "Menu Entry 45"
  "Menu Entry 46" "Menu Entry 47" "Menu Entry 48" "Menu Entry 49" "Menu Entry 50"
  "Menu Entry 51" "Menu Entry 52" "Menu Entry 53" "Menu Entry 54" "Menu Entry 55"
  "Menu Entry 56" "Menu Entry 57" "Menu Entry 58" "Menu Entry 59" "Menu Entry 60"
  "Menu Entry 61" "Menu Entry 62" "Menu Entry 63" "Menu Entry 64" "Menu Entry 65"
  "Menu Entry 66" "Menu Entry 67" "Menu Entry 68" "Menu Entry 69" "Menu Entry 70"
  "Menu Entry 71" "Menu Entry 72" "Menu Entry 73" "Menu Entry 74" "Menu Entry 75"
  "Menu Entry 76" "Menu Entry 77" "Menu Entry 78" "Menu Entry 79" "Menu Entry 80"
  "Menu Entry 81" "Menu Entry 82" "Menu Entry 83" "Menu Entry 84" "Menu Entry 85"
  "Menu Entry 86" "Menu Entry 87" "Menu Entry 88" "Menu Entry 89" "Menu Entry 90"
  "Menu Entry 91" "Menu Entry 92" "Menu Entry 93" "Menu Entry 94" "Menu Entry 95"
  "Menu Entry 96" "Menu Entry 97" "Menu Entry 98" "Menu Entry 99" "Menu Entry 100"
)

# Run
menu "$header" "menu"

# Returns:
# $menu_status (0=success, 1=error)
# $menu_selected (0-based key of $menu array)
# $menu_msg (output message if error)

# Handle results
if [[ "$menu_status" -eq 0 ]]; then
  printf "\nYou selected: %s\n\n" "${menu[$menu_selected]}"
else
  printf "\n%s\n\n" "$menu_msg"
fi
