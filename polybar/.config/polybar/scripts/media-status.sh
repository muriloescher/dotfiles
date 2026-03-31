#!/usr/bin/env bash

WIDTH=20
STEP_DELAY=0.3
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
    printf '%s\t%s - %s\n' "$icon" "$artist" "$title" > "$STATE_FILE"
  else
    printf '%s\t%s\n' "$icon" "$title" > "$STATE_FILE"
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
  local icon="$1"
  local text="$2"
  local pos="$3"

  if [ -z "$text" ]; then
    printf '\n'
    return
  fi

  local prefix="${icon} "
  local text_width=$((WIDTH - ${#prefix}))
  [ "$text_width" -lt 1 ] && text_width=1

  if [ "${#text}" -le "$text_width" ]; then
    printf '%s%-*s\n' "$prefix" "$text_width" "$text"
    return
  fi

  local scroll_text="${text}${GAP}"
  local doubled="${scroll_text}${scroll_text}"
  printf '%s%s\n' "$prefix" "${doubled:$pos:$text_width}"
}

init_state
watch_player &
WATCH_PID=$!

trap 'kill "$WATCH_PID" 2>/dev/null' EXIT

last_line=""
pos=0

while true; do
  line="$(cat "$STATE_FILE" 2>/dev/null)"

  if [ "$line" != "$last_line" ]; then
    pos=0
    last_line="$line"
  fi

  if [ -z "$line" ]; then
    printf '\n'
    sleep "$STEP_DELAY"
    continue
  fi

  IFS=$'\t' read -r icon text <<< "$line"
  render_window "$icon" "$text" "$pos"

  prefix="${icon} "
  text_width=$((WIDTH - ${#prefix}))
  [ "$text_width" -lt 1 ] && text_width=1

  if [ -n "$text" ] && [ "${#text}" -gt "$text_width" ]; then
    cycle_len=$((${#text} + ${#GAP}))
    pos=$(((pos + 1) % cycle_len))
  else
    pos=0
  fi

  sleep "$STEP_DELAY"
done
