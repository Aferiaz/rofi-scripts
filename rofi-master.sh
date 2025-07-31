#!/bin/bash

MODULES="$HOME/bin/rofi/modules"

while true; do
  ENTRIES=$(grep -h "^# name:" "$MODULES"/*.sh | sed 's/# name: //')

  CHOICE=$(echo "$ENTRIES" | rofi -dmenu -i -p "Main Menu")

  [ -z "$CHOICE" ] && exit 0

  SCRIPT=$(grep -l "# name: $CHOICE" "$MODULES"/*.sh | head -n 1)

  if [ -x "$SCRIPT" ]; then
    bash "$SCRIPT"
    # If script returns 100, reopen menu
    if [ $? -eq 100 ]; then
      continue
    else
      exit 0
    fi
  fi 
done
