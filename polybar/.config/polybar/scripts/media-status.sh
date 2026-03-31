#!/usr/bin/env bash

WIDTH=20
STEP_DELAY=0.4
GAP=" • "

STATE_FILE="/tmp/polybar-media-state"

write_state() {
  local artist="$1"
  local title="$2"
  local status="$3"

  if [ -z "$title" ]; then
    : > "$STATE_FILE"
    return
  fi

  local icon=""
  case "$status" in
    Playing) icon=" " ;;
    Paused)  icon=" " ;;
    *)       : > "$STATE_FILE"; return ;;
  esac

  if [ -n "$artist" ]; then
    printf '%s%s - %s\n' "$icon" "$artist" "$title" > "$STATE_FILE"
  else
    printf '%s%s\n' "$icon" "$title" > "$STATE_FILE"
  fi
}

init_state() {
  local line
  line="$(playerctl metadata --format '{{default(artist, "")}}	{{default(title, "")}}	{{status}}' 2>/dev/null | head -n1)" || true
  [ -z "$line" ] && { : > "$STATE_FILE"; return; }

  IFS=$'\t' read -r artist title status <<< "$line"
  write_state "$artist" "$title" "$status"
}

watch_player() {
  playerctl --follow metadata --format '{{default(artist, "")}}	{{default(title, "")}}	{{status}}' 2>/dev/null |
  while IFS=$'\t' read -r artist title status; do
    write_state "$artist" "$title" "$status"
  done
}

render_window() {
  local text="$1"
  local pos="$2"

  if [ -z "$text" ]; then
    printf '\n'
    return
  fi

  if [ "${#text}" -le "$WIDTH" ]; then
    printf '%-*s\n' "$WIDTH" "$text"
    return
  fi

  local scroll_text="${text}${GAP}"
  local doubled="${scroll_text}${scroll_text}"
  printf '%s\n' "${doubled:$pos:$WIDTH}"
}

init_state
watch_player &
WATCH_PID=$!

trap 'kill "$WATCH_PID" 2>/dev/null' EXIT

last_text=""
pos=0

while true; do
  text="$(cat "$STATE_FILE" 2>/dev/null)"

  if [ "$text" != "$last_text" ]; then
    pos=0
    last_text="$text"
  fi

  render_window "$text" "$pos"

  if [ -n "$text" ] && [ "${#text}" -gt "$WIDTH" ]; then
    cycle_len=$((${#text} + ${#GAP}))
    pos=$(((pos + 1) % cycle_len))
  else
    pos=0
  fi

  sleep "$STEP_DELAY"
done
