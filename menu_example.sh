#!/bin/bash

source "${0%/*}/menu.sh"

# To change the marker, set this variable:
#menu_marker=$(echo -e "\u27A5")

# To change the highlighted entry style, set the following variables:
#menu_fg="\e[38;5;13m"
#menu_bg="\e[48;5;6m"

# To add a blank line between menu items set:
#menu_padding=1

# Define Menu variables
header="Select an option and press Enter to select, or ESC/Q to quit."
menu=("Menu Entry 1" "Menu Entry 2" "Menu Entry 3" "Menu Entry 4" "Menu Entry 5")

# Run
menu "$header" "menu"

# Handle results
if [[ "$menu_status" -eq 0 ]]; then
  printf "\nYou selected: %s\n\n" "${menu[$menu_selected]}"
else
  printf "\n%s\n\n" "$menu_msg"
fi
