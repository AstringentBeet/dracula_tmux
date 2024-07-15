#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $current_dir/utils.sh

function slice_loop() {
  local str="$1"
  local start="$2"
  local how_many="$3"
  local len=${#str}

  local result=""

  for ((i = 0; i < how_many; i++)); do
    local index=$(((start + i) % len))
    local char="${str:index:1}"
    result="$result$char"
  done

  echo "$result"
}

main() {
  # storing the refresh rate in the variable RATE, default is 5
  RATE=$(get_tmux_option "@dracula-refresh-rate" 5)

  if ! command -v playerctl &>/dev/null; then
    exit 1
  fi

  FORMAT=$(get_tmux_option "@dracula-playerctl-format" "Now playing: {{ artist }} - {{ album }} - {{ title }}")
  playerctl_playback=$(playerctl metadata --format "${FORMAT}")
  playerctl_playback="${playerctl_playback} "

  # Determine the length of the terminal window (not implemented here)
  # Adjust 'terminal_width' based on your actual terminal width
  terminal_width=25

  # Initial start point for scrolling
  start=0
  len=${#playerctl_playback}

  scrolling_text=""

  for ((i = 0; i <= len; i++)); do
    # Slice the string starting from 'start' index and display 'terminal_width' characters
    scrolling_text=$(slice_loop "$playerctl_playback" "$start" "$terminal_width")
    echo -ne "\r"
    echo "$scrolling_text"
    echo -ne "\r"

    # Check if the beginning of the original string reappears at the start of the visible area

    # Update the start index for the next iteration
    ((start++))

    # Sleep for RATE seconds before updating the display (adjust RATE as needed)
    sleep 0.08
  done
}

# run the main driver
main
