#!/bin/bash

#
# MENU
#
# Description
#   Display an interactive shell menu and select with arrow keys and Enter.
#
# Input variables
#   $1 The header/prompt you wish to display
#   $2 The variable name indicating the menu array you have defined
#
# Notes
#   Enter, Tab or Space will select the entry
#   ESC or Q will cancel
#   Ctrl+C will quit the script as usual
#
# Return values
#   $menu_status   = The success/error status with 0=success and 1=error
#   $menu_selected = The selected entry is set to the key of the menu array
#   $menu_msg      = If there was an error, this will hold the message
#
# Styling
#   If you wish to override the default styles, define any of these variables before calling the menu function.
#   $menu_marker   = You can override the default marker character
#   $menu_fg       = You can override the default highlighted entries' text color
#   $menu_bg       = You can override the default highlighted entries' background color
#
menu() {
  # Main Menu function
  main_menu() {
    local default_marker default_highlight_fg default_highlight_bg i input key selected menu_array menu_fg menu_bg menu_marker header

    default_marker=$(echo -e "\u27A4") # marker char: ➤
    default_highlight_fg="\e[38;5;15m" # White text
    default_highlight_bg="\e[48;5;4m"  # Blue background

    # Check to make sure a menu array was passed in
    if [[ -z "$1" ]]; then
      echo "Error: No menu header submitted!" >&2
      return 1
    fi

    # Define header message
    header="$1"
    shift

    if [[ -z "$1" ]]; then
      echo "Error: No menu submitted!" >&2
      return 1
    fi

    # Define submitted menu
    if [[ -v $2 ]]; then
      # There are multiple strings passed, so set the array to all of them
      local menu_array=("$@")
    else
      # If only one remaining string was passed, check to see if it points to an existing array variable
      local tmp=$1
      if declare -p $tmp &>/dev/null; then
        local -n menu_array=$tmp
      else
        local menu_array=("$1")
      fi
    fi

    # Initial selected item
    selected=0

    # Set hightlight colors
    if [[ ! -v menu_fg ]]; then
      menu_fg="$default_highlight_fg"
    fi
    if [[ ! -v menu_bg ]]; then
      menu_fg="$default_highlight_bg"
    fi

    # Display the menu with the selected item highlighted
    display_menu() {
      printf "\033[H\n%b\n\n" "$header" # \033[H is needed to redraw menu
      if [[ -z "$menu_marker" ]]; then
        menu_marker="$default_marker"
      fi
      for i in "${!menu_array[@]}"; do
        if [ "$i" -eq "$selected" ]; then
          printf "%b%b %s %s\e[0m\n" "$menu_fg" "$menu_bg" "$menu_marker" "${menu_array[$i]}"
        else
          echo "   ${menu_array[$i]}"
        fi
        test "$menu_padding" == 1 && echo
      done
    }


    # Main loop
    while true; do
      display_menu >&2
      # Read a single character (Up, Down and ESC share a comon prefix, and have different suffixes)
      IFS= read -rsn1 input
      #printf "\n==%x==\n\n" "'$input"

      # Check arrow keys
      if [[ $input == $'\x1b' ]]; then
        # Read next part of input string
        read -rsn2 -t 0.1 key
        #printf "\n==%x==\n\n" "'$key"

        if [[ -z "$key" ]]; then
          # Escape was pressed and no additional input was detected
          echo "Canceled"
          return 1
        elif [[ $key == '[A' ]]; then
          # Up arrow
          if [ "$selected" -eq 0 ]; then               # Wrap around from top to bottom
            selected=$((${#menu_array[@]} -1))
          else
            ((selected--))
          fi
        elif [[ $key == '[B' ]]; then
          # Down arrow
          ((selected++))
          if [ "$selected" -eq ${#menu_array[@]} ]; then     # Wrap around from bottom to top
            selected=0
          fi
        fi
      elif [[ $input == $'\x09' || $input == ' ' || $input == $'\x0' ]]; then
        # Tab, space, or enter
        return $selected
      elif [[ $input == 'q' ]]; then
        # 'q'
        echo "Canceled"
        return 1
      fi
    done
  }

  # This wrapper function handles clearing screen and output handling
  tput clear 2>/dev/null || clear
  export menu_msg menu_selected menu_status

  menu_msg="$(main_menu "$@")"
  menu_selected=$?

  if [[ -z "$menu_msg" ]]; then
    # Success
    menu_status=0
    return 0
  else
    # Error
    menu_status=1
    return 1
  fi
}
