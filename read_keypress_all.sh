read_keypress() {
    local key keytap
    key=""

    IFS= read -rsN1 keytap
    while [[ -n $keytap ]]; do
        key+="$keytap"
        IFS= read -rsN1 -t 0.0001 keytap
    done

    case $key in
        # Escape
        $'\x1B')            echo "Escape" ;;

        # Enter (Shift/Ctrl don't work in bash)
        $'\x0A')            echo "Enter" ;;
        $'\e\x0A'|$'\e\x0D') echo "Alt + Enter" ;;

        # Tab (Most Tab chars don't work with terminals)
        $'\x09')            echo "Tab" ;;
        $'\e[Z')            echo "Shift + Tab" ;;
        $'\e\x09')          echo "Alt + Tab" ;;
        $'\e\e[Z')          echo "Alt + Shift + Tab" ;;
        $'\x1B\x09')        echo "Ctrl + Tab" ;;
        $'\e\x1B\x09')      echo "Alt + Ctrl + Tab" ;;

        # Backspace (Shift doesn't work in bash)
        $'\x7F')            echo "Backspace" ;;
        $'\x08')            echo "Ctrl + Backspace" ;;
        $'\e\x7F')          echo "Alt + Backspace" ;;
        $'\e\x08')          echo "Alt + Ctrl + Backspace" ;;

        # Insert
        $'\e[2~')           echo "Insert" ;;
        $'\e[2;2~')         echo "Shift + Insert" ;;
        $'\e[2;3~')         echo "Alt + Insert" ;;
        $'\e[2;4~')         echo "Alt + Shift + Insert" ;;
        $'\e[2;5~')         echo "Ctrl + Insert" ;;
        $'\e[2;6~')         echo "Ctrl + Shift + Insert" ;;
        $'\e[2;7~')         echo "Alt + Ctrl + Insert" ;;
        $'\e[2;8~')         echo "Alt + Ctrl + Shift + Insert" ;;

        # Home
        $'\e[H'|$'\e[1~'|$'\eOH') echo "Home" ;;
        $'\e[1;2H')         echo "Shift + Home" ;;
        $'\e[1;3H')         echo "Alt + Home" ;;
        $'\e[1;4H')         echo "Alt + Shift + Home" ;;
        $'\e[1;5H')         echo "Ctrl + Home" ;;
        $'\e[1;6H')         echo "Ctrl + Shift + Home" ;;
        $'\e[1;7H')         echo "Alt + Ctrl + Home" ;;
        $'\e[1;8H')         echo "Alt + Ctrl + Shift + Home" ;;

        # End
        $'\e[F'|$'\e[4~'|$'\eOF') echo "End" ;;
        $'\e[1;2F')         echo "Shift + End" ;;
        $'\e[1;3F')         echo "Alt + End" ;;
        $'\e[1;4F')         echo "Alt + Shift + End" ;;
        $'\e[1;5F')         echo "Ctrl + End" ;;
        $'\e[1;6F')         echo "Ctrl + Shift + End" ;;
        $'\e[1;7F')         echo "Alt + Ctrl + End" ;;
        $'\e[1;8F')         echo "Alt + Ctrl + Shift + End" ;;

        # Delete
        $'\e[3~')           echo "Delete" ;;
        $'\e[3;2~')         echo "Shift + Delete" ;;
        $'\e[3;3~')         echo "Alt + Delete" ;;
        $'\e[3;4~')         echo "Alt + Shift + Delete" ;;
        $'\e[3;5~')         echo "Ctrl + Delete" ;;
        $'\e[3;6~')         echo "Ctrl + Shift + Delete" ;;
        $'\e[3;7~')         echo "Alt + Ctrl + Delete" ;;
        $'\e[3;8~')         echo "Alt + Ctrl + Shift + Delete" ;;

        # Page Up/Down
        $'\e[5~')           echo "Page Up" ;;
        $'\e[6~')           echo "Page Down" ;;
        $'\e[5;2~')         echo "Shift + Page Up" ;;
        $'\e[6;2~')         echo "Shift + Page Down" ;;

        # Arrow keys
        $'\e[A'|$'\eOA')    echo "Up Arrow" ;;
        $'\e[B'|$'\eOB')    echo "Down Arrow" ;;
        $'\e[C'|$'\eOC')    echo "Right Arrow" ;;
        $'\e[D'|$'\eOD')    echo "Left Arrow" ;;

        # CTRL + Arrows
        $'\e[1;5A')         echo "CTRL + Up Arrow" ;;
        $'\e[1;5B')         echo "CTRL + Down Arrow" ;;
        $'\e[1;5C')         echo "CTRL + Right Arrow" ;;
        $'\e[1;5D')         echo "CTRL + Left Arrow" ;;

        # Shift + Arrows
        $'\e[1;2A')         echo "Shift + Up Arrow" ;;
        $'\e[1;2B')         echo "Shift + Down Arrow" ;;
        $'\e[1;2C')         echo "Shift + Right Arrow" ;;
        $'\e[1;2D')         echo "Shift + Left Arrow" ;;

        # Alt + Arrow
        $'\e[1;3A')         echo "Alt + Up Arrow" ;;
        $'\e[1;3B')         echo "Alt + Down Arrow" ;;
        $'\e[1;3C')         echo "Alt + Right Arrow" ;;
        $'\e[1;3D')         echo "Alt + Left Arrow" ;;

        # CTRL + Shift + Arrows
        $'\e[1;6A')         echo "CTRL + Shift + Up Arrow" ;;
        $'\e[1;6B')         echo "CTRL + Shift + Down Arrow" ;;
        $'\e[1;6C')         echo "CTRL + Shift + Right Arrow" ;;
        $'\e[1;6D')         echo "CTRL + Shift + Left Arrow" ;;

        # Alt + Shift + Arrow
        $'\e[1;4A')         echo "Alt + Shift + Up Arrow" ;;
        $'\e[1;4B')         echo "Alt + Shift + Down Arrow" ;;
        $'\e[1;4C')         echo "Alt + Shift + Right Arrow" ;;
        $'\e[1;4D')         echo "Alt + Shift + Left Arrow" ;;

        # Ctrl + Alt + Arrow
        $'\e[1;7A')         echo "Ctrl + Alt + Up Arrow" ;;
        $'\e[1;7B')         echo "Ctrl + Alt + Down Arrow" ;;
        $'\e[1;7C')         echo "Ctrl + Alt + Right Arrow" ;;
        $'\e[1;7D')         echo "Ctrl + Alt + Left Arrow" ;;

        # Ctrl + Alt + Shift + Arrow
        $'\e[1;8A')         echo "Ctrl + Alt + Shift + Up Arrow" ;;
        $'\e[1;8B')         echo "Ctrl + Alt + Shift + Down Arrow" ;;
        $'\e[1;8C')         echo "Ctrl + Alt + Shift + Right Arrow" ;;
        $'\e[1;8D')         echo "Ctrl + Alt + Shift + Left Arrow" ;;

        # Function keys
        $'\eOP'|$'\e[11~')  echo "F1" ;;
        $'\eOQ'|$'\e[12~')  echo "F2" ;;
        $'\eOR'|$'\e[13~')  echo "F3" ;;
        $'\eOS'|$'\e[14~')  echo "F4" ;;
        $'\e[15~')          echo "F5" ;;
        $'\e[17~')          echo "F6" ;;
        $'\e[18~')          echo "F7" ;;
        $'\e[19~')          echo "F8" ;;
        $'\e[20~')          echo "F9" ;;
        $'\e[21~')          echo "F10" ;;
        $'\e[23~')          echo "F11" ;;
        $'\e[24~')          echo "F12" ;;

        $'\e[1;2P')         echo "Shift + F1" ;;
        $'\e[1;3P')         echo "Alt + F1" ;;
        $'\e[1;5P')         echo "CTRL + F1" ;;
        $'\e[1;6P')         echo "Shift + CTRL + F1" ;;
        $'\e[1;7P')         echo "Alt + CTRL + F1" ;;
        $'\e[1;8P')         echo "Shift + Alt + CTRL + F1" ;;

        $'\e[1;2Q')         echo "Shift + F2" ;;
        $'\e[1;3Q')         echo "Alt + F2" ;;
        $'\e[1;5Q')         echo "CTRL + F2" ;;
        $'\e[1;6Q')         echo "Shift + CTRL + F2" ;;
        $'\e[1;7Q')         echo "Alt + CTRL + F2" ;;
        $'\e[1;8Q')         echo "Shift + Alt + CTRL + F2" ;;

        $'\e[1;2R')         echo "Shift + F3" ;;
        $'\e[1;3R')         echo "Alt + F3" ;;
        $'\e[1;5R')         echo "CTRL + F3" ;;
        $'\e[1;6R')         echo "Shift + CTRL + F3" ;;
        $'\e[1;7R')         echo "Alt + CTRL + F3" ;;
        $'\e[1;8R')         echo "Shift + Alt + CTRL + F3" ;;

        $'\e[1;2S')         echo "Shift + F4" ;;
        $'\e[1;3S')         echo "Alt + F4" ;;
        $'\e[1;5S')         echo "CTRL + F4" ;;
        $'\e[1;6S')         echo "Shift + CTRL + F4" ;;
        $'\e[1;7S')         echo "Alt + CTRL + F4" ;;
        $'\e[1;8S')         echo "Shift + Alt + CTRL + F4" ;;

        $'\e[15;2~')        echo "Shift + F5" ;;
        $'\e[15;3~')        echo "Alt + F5" ;;
        $'\e[15;5~')        echo "CTRL + F5" ;;
        $'\e[15;6~')        echo "Shift + CTRL + F5" ;;
        $'\e[15;7~')        echo "Alt + CTRL + F5" ;;
        $'\e[15;8~')        echo "Shift + Alt + CTRL + F5" ;;

        $'\e[17;2~')        echo "Shift + F6" ;;
        $'\e[17;3~')        echo "Alt + F6" ;;
        $'\e[17;5~')        echo "CTRL + F6" ;;
        $'\e[17;6~')        echo "Shift + CTRL + F6" ;;
        $'\e[17;7~')        echo "Alt + CTRL + F6" ;;
        $'\e[17;8~')        echo "Shift + Alt + CTRL + F6" ;;

        $'\e[18;2~')        echo "Shift + F7" ;;
        $'\e[18;3~')        echo "Alt + F7" ;;
        $'\e[18;5~')        echo "CTRL + F7" ;;
        $'\e[18;6~')        echo "Shift + CTRL + F7" ;;
        $'\e[18;7~')        echo "Alt + CTRL + F7" ;;
        $'\e[18;8~')        echo "Shift + Alt + CTRL + F7" ;;

        $'\e[19;2~')        echo "Shift + F8" ;;
        $'\e[19;3~')        echo "Alt + F8" ;;
        $'\e[19;5~')        echo "CTRL + F8" ;;
        $'\e[19;6~')        echo "Shift + CTRL + F8" ;;
        $'\e[19;7~')        echo "Alt + CTRL + F8" ;;
        $'\e[19;8~')        echo "Shift + Alt + CTRL + F8" ;;

        $'\e[20;2~')        echo "Shift + F9" ;;
        $'\e[20;3~')        echo "Alt + F9" ;;
        $'\e[20;5~')        echo "CTRL + F9" ;;
        $'\e[20;6~')        echo "Shift + CTRL + F9" ;;
        $'\e[20;7~')        echo "Alt + CTRL + F9" ;;
        $'\e[20;8~')        echo "Shift + Alt + CTRL + F9" ;;

        $'\e[21;2~')        echo "Shift + F10" ;;
        $'\e[21;3~')        echo "Alt + F10" ;;
        $'\e[21;5~')        echo "CTRL + F10" ;;
        $'\e[21;6~')        echo "Shift + CTRL + F10" ;;
        $'\e[21;7~')        echo "Alt + CTRL + F10" ;;
        $'\e[21;8~')        echo "Shift + Alt + CTRL + F10" ;;

        $'\e[23;2~')        echo "Shift + F11" ;;
        $'\e[23;3~')        echo "Alt + F11" ;;
        $'\e[23;5~')        echo "CTRL + F11" ;;
        $'\e[23;6~')        echo "Shift + CTRL + F11" ;;
        $'\e[23;7~')        echo "Alt + CTRL + F11" ;;
        $'\e[23;8~')        echo "Shift + Alt + CTRL + F11" ;;

        $'\e[24;2~')        echo "Shift + F12" ;;
        $'\e[24;3~')        echo "Alt + F12" ;;
        $'\e[24;5~')        echo "CTRL + F12" ;;
        $'\e[24;6~')        echo "Shift + CTRL + F12" ;;
        $'\e[24;7~')        echo "Alt + CTRL + F12" ;;
        $'\e[24;8~')        echo "Shift + Alt + CTRL + F12" ;;

        $'\e0') echo "Alt + 0" ;;
        $'\e1') echo "Alt + 1" ;;
        $'\e2') echo "Alt + 2" ;;
        $'\e3') echo "Alt + 3" ;;
        $'\e4') echo "Alt + 4" ;;
        $'\e5') echo "Alt + 5" ;;
        $'\e6') echo "Alt + 6" ;;
        $'\e7') echo "Alt + 7" ;;
        $'\e8') echo "Alt + 8" ;;
        $'\e9') echo "Alt + 9" ;;

        # Ctrl is pretty hit or miss for letters and numbers. Alt works much better
        $'\x00') echo "Ctrl + 2 (NULL)" ;;     # Ctrl + @ = NULL (0x00)
        $'\x01') echo "Ctrl + A" ;;             # Included for completeness
        $'\x02') echo "Ctrl + B" ;;
        $'\x03') echo "Ctrl + C" ;;
        $'\x04') echo "Ctrl + D" ;;
        $'\x05') echo "Ctrl + E" ;;
        $'\x06') echo "Ctrl + F" ;;
        $'\x07') echo "Ctrl + G" ;;
        $'\x08') echo "Ctrl + H" ;;             # Also Backspace in many terms
        $'\x09') echo "Tab / Ctrl + I" ;;
        $'\x0A') echo "Enter / Ctrl + J" ;;
        $'\x0B') echo "Ctrl + K" ;;
        $'\x0C') echo "Ctrl + L" ;;
        $'\x0D') echo "Enter / Ctrl + M" ;;
        $'\x1E') echo "Ctrl + ^" ;;
        $'\x1F') echo "Ctrl + _" ;;

        # Ctrl + numbers (sometimes aliases, often not distinguishable)
        $'\x1D') echo "Ctrl + 5 (ESC)" ;;
        $'\x1F') echo "Ctrl + 6 / _" ;;
        $'\x1C') echo "Ctrl + 4" ;;
        $'\x1B') echo "Ctrl + [" ;;
        $'\x1A') echo "Ctrl + Z" ;; # Ctrl+1–3, 7–9 are typically Ctrl+A–I
        $'\x1F') echo "Ctrl + ?" ;; # Also Ctrl + /

        # Alt + common punctuation
        $'\e/') echo "Alt + /" ;;
        $'\e,') echo "Alt + ," ;;
        $'\e.') echo "Alt + ." ;;
        $'\e[') echo "Alt + [" ;;
        $'\e]') echo "Alt + ]" ;;
        $'\e;') echo "Alt + ;" ;;
        $'\e\'') echo "Alt + '" ;;
        $'\e\\') echo "Alt + \\" ;;
        $'\e-') echo "Alt + -" ;;
        $'\e=') echo "Alt + =" ;;
        $'\e`') echo "Alt + \` (backtick)" ;;
        $'\e ') echo "Alt + Space" ;;

        # Ctrl + punctuation (as allowed)
        $'\x1F') echo "Ctrl + / (Unit Separator)" ;;
        $'\x1C') echo "Ctrl + \\" ;;
        $'\x1B') echo "Ctrl + [" ;;
        $'\x1D') echo "Ctrl + ]" ;;
        $'\x1E') echo "Ctrl + ^" ;;
        $'\x07') echo "Ctrl + G (Bell)" ;;


        # Catch any printable characters
        ?)  echo "character: '$key'" ;;

        *)
            printf "Unknown: "
            for ((i=0; i<${#key}; i++)); do
                printf '\\x%02X' "'${key:$i:1}"
            done
            echo
            ;;
    esac
}

echo "Press a Key:"
while :; do
  read_keypress
done
