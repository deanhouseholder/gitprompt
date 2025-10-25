#!/bin/bash

read_keypress() {
    local key keytap
    key=""

    # Read the first byte
    IFS= read -rsN1 keytap

    # Loop to read additional bytes (for multi-byte escape sequences)
    while [[ -n $keytap ]]; do
        key+="$keytap"
        IFS= read -rsN1 -t 0.0001 keytap
    done

    case $key in
        $'\x1B')            echo "escape" ;;
        $'\x7F')            echo "backspace" ;;
        $'\x09')            echo "tab" ;;
        $'\x0A'|$'\x0D')    echo "enter" ;;

        # Arrow keys
        $'\e[A'|$'\eOA')    echo "up arrow" ;;
        $'\e[B'|$'\eOB')    echo "down arrow" ;;
        $'\e[C'|$'\eOC')    echo "right arrow" ;;
        $'\e[D'|$'\eOD')    echo "left arrow" ;;

        # Home/End
        $'\e[H'|$'\eOH')    echo "home" ;;
        $'\e[F'|$'\eOF')    echo "end" ;;

        # Insert/Delete
        $'\e[2~')           echo "insert" ;;
        $'\e[3~')           echo "delete" ;;

        # Page Up/Down
        $'\e[5~')           echo "page up" ;;
        $'\e[6~')           echo "page down" ;;
        $'\e[5;2~')         echo "shift + page up" ;;
        $'\e[6;2~')         echo "shift + page down" ;;

        # Ctrl + Arrows
        $'\e[1;5A')         echo "ctrl + up arrow" ;;
        $'\e[1;5B')         echo "ctrl + down arrow" ;;
        $'\e[1;5C')         echo "ctrl + right arrow" ;;
        $'\e[1;5D')         echo "ctrl + left arrow" ;;

        # Catch any printable characters
        ?)  echo "character: '$key'" ;;

        *)
            printf 'unknown sequence:'
            for ((i=0; i<${#key}; i++)); do
                printf ' \\x%02X' "'${key:$i:1}"
            done
            echo
            ;;
    esac
}

echo "Press a Key:"
while :; do
  read_keypress
done
