#!/bin/bash
# name: 🗂️ Obsidian

choice=$(printf '%s\n' \
  "⬅️ Back to Main Menu" \
  "📅 Today" \
  "🔍 Search" \
  "🏷️ Tags" \
  "🆕 New Note" \
  "📁 Open Vault" \
  | rofi -dmenu -i -p "Obsidian")

if [[ "$choice" == "-" ]]; then
  exit 100
fi

case "$choice" in
  "📅 Today")
    ghostty -e 'nvim -c "Obsidian today"; exec bash'
    ;;
  "🔍 Search")
    ghostty -e 'nvim -c "Obsidian search"; exec bash'
    ;;
  "🏷️ Tags")
    ghostty -e 'nvim -c "Obsidian tags"; exec bash'
    ;;
  "🆕 New Note")
    ghostty -e 'nvim -c "Obsidian new"; exec bash'
    ;;
  "📁 Open Vault")
    ghostty -e 'nvim ~/Notes -c "Alpha"'; exec bash
    ;;
  "⬅️ Back to Main Menu")
    exit 100
    ;;
  *)
    exit 1
    ;;
esac
  
