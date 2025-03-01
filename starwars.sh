#!/bin/sh

SMALL_FONT="/usr/share/consolefonts/Lat15-Terminus16.psf.gz"
DEFAULT_FONT="/usr/share/consolefonts/Lat15-Terminus20x10.psf.gz"

restore_font() {
    setfont "$DEFAULT_FONT"
    stty echo cooked  # Restore terminal settings
    clear  # Clear the terminal after exit
}

trap restore_font EXIT

setfont "$SMALL_FONT"
stty -echo raw  # Hide input and enable raw mode

while true; do
    # Run telnet inside `script` to prevent it from capturing input
    script -q -c "telnet towel.blinkenlights.nl" /dev/null &

    TELNET_PID=$!

    # Detect key press while telnet runs
    while kill -0 $TELNET_PID 2>/dev/null; do
        if od -An -N1 -t u1 </dev/tty | grep -q .; then
            kill $TELNET_PID 2>/dev/null
            wait $TELNET_PID 2>/dev/null  # Ensure telnet fully exits
            restore_font
            exit 0  # Exit the entire script
        fi
        sleep 0.1
    done

    wait $TELNET_PID 2>/dev/null  # Wait for telnet to finish before looping
done
