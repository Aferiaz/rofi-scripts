#!/bin/bash
# name: 🛠 Arduino Projects

# --- MAPPED FQBNs ---
declare -A fqbn_map=(
  [esp32c3]="esp32:esp32:esp32c3"
  [esp32s3]="esp32:esp32:esp32s3"
  [uno]="arduino:avr:uno"
  [nano]="arduino:avr:nano"
  # Add more mappings as needed
)

# --- SELECT BOARD ---
select_board() {
  local arduino_dir="$HOME/Arduino"
  local boards

  boards=$(find "$arduino_dir" -mindepth 1 -maxdepth 1 -type d | xargs -n 1 basename | sort)
  [[ -z "$boards" ]] && notify-send "Arduino" "❌ No boards found in ~/Arduino" && return 1

  choice=$(printf "🔙 Back\n%s" "$boards" | rofi -dmenu -i -p "Select Board")
  [[ "$choice" == "🔙 Back" || -z "$choice" ]] && return 1

  echo "$choice"
}

# --- SELECT PROJECT ---
select_project() {
  local board="$1"
  local project_dir="$HOME/Arduino/$board"

  [ ! -d "$project_dir" ] && notify-send "Arduino" "❌ No projects for $board" && return 1

  projects=$(find "$project_dir" -mindepth 1 -maxdepth 1 -type d | xargs -n 1 basename | sort)
  choice=$(printf "🔙 Back\n%s" "$projects" | rofi -dmenu -i -p "Select Project")
  [[ "$choice" == "🔙 Back" || -z "$choice" ]] && return 1

  echo "$project_dir/$choice"
}

# --- SELECT PORT ---
select_port() {
  ports_raw=$(arduino-cli board list | tail -n +2)

  if [[ -z "$ports_raw" ]]; then
    notify-send "Arduino" "❌ No serial ports found"
    return 1
  fi

  port_entries=""
  while IFS= read -r line; do
    # Extract first field as port
    port=$(echo "$line" | awk '{print $1}')
    
    # Try to extract FQBN and board name using the full line
    fqbn=$(echo "$line" | grep -o '[a-z0-9_]\+:[a-z0-9_]\+:[a-z0-9_]\+' | head -n1)
    [[ -z "$fqbn" ]] && fqbn="unknown"

    board_name=$(echo "$line" | sed -n 's/.*Serial Port (USB) \(.*\) '"$fqbn"'.*/\1/p')
    [[ -z "$board_name" ]] && board_name=$(echo "$line" | awk '{for(i=4;i<=NF;i++) printf $i" "; print ""}' | sed 's/'"$fqbn"'.*//')

    board_name=$(echo "$board_name" | xargs)  # trim spaces

    port_entries+="${port} | ${board_name} | ${fqbn}"$'\n'
  done <<< "$ports_raw"

  choice=$(printf "🔙 Back\n%s" "$port_entries" | rofi -dmenu -i -p "Select Port")
  [[ "$choice" == "🔙 Back" || -z "$choice" ]] && return 1

  echo "$choice" | cut -d ' ' -f1  # Return only /dev/ttyXXX
}

# --- MAIN MENU ---
while true; do
  action=$(printf "🔙 Back to Main Menu\n📂 Open Project\n📤 Upload Project" | rofi -dmenu -i -p "Arduino")

  case "$action" in
    "🔙 Back to Main Menu" | "") exit 100 ;;
    "📂 Open Project")
      board=$(select_board) || continue
      project_path=$(select_project "$board") || continue
      ghostty -e "nvim \"$project_path\"" &
      exit 0
      ;;
    "📤 Upload Project")
      board=$(select_board) || continue
      project_path=$(select_project "$board") || continue
      port=$(select_port) || continue

      fqbn="${fqbn_map[$board]}"
      if [[ -z "$fqbn" ]]; then
        notify-send -u critical "Arduino" "❌ No FQBN mapped for board '$board'"
        continue
      fi

      if arduino-cli compile --fqbn "$fqbn" "$project_path" && \
         arduino-cli upload -p "$port" --fqbn "$fqbn" "$project_path"; then
        notify-send -u normal -t 2000 "Arduino" "✅ Uploaded $project_path to $port"
      else
        notify-send -u critical "Arduino" "❌ Upload failed"
      fi
      exit 0
      ;;
  esac
done
