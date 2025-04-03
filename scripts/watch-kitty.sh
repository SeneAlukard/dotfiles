#!/bin/bash
CONFIG_FILE="$HOME/.config/kitty/kitty.conf"

while inotifywait -e modify "$CONFIG_FILE"; do
    kitty @ set-colors --reload
done

