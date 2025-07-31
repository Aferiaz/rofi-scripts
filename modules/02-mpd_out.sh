#!/bin/bash
# name: 🎵 Switch MPD Output

choice=$(printf '%s\n' \
  "⬅️ Back to Main Menu" \
  "🎚 ALSA" \
  "🧩 PipeWire" \
  | rofi -dmenu -i -p "Select MPD Output:")

if [[ "$choice" == "-" ]]; then
  exit 100
fi

case "$choice" in
  "🎚 ALSA")
    mpc enable 1 && mpc disable 2
    notify-send -u normal -t 2000 "MPD Output" "🎚 Switched to ALSA"
    ;;
  "🧩 PipeWire")
    mpc enable 2 && mpc disable 1
    notify-send -u normal -t 2000 "MPD Output" "🧩 Switched to PipeWire"
    ;;
  "⬅️ Back to Main Menu")
    exit 100
    ;;
esac
