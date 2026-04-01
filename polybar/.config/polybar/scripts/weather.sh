#!/usr/bin/env bash

set -u

WIDTH=20
STEP_DELAY=0.3
REFRESH_SECONDS=900
LOCATION_ICON=""

format_location() {
  perl -CS -Mutf8 -pe 's/^\s+|\s+$//g; s/^(.)/uc($1)/e'
}

fetch_weather() {
  local response location temperature

  if ! command -v curl >/dev/null 2>&1; then
    return 1
  fi

  response="$(curl -fsS --max-time 8 'https://wttr.in/?format=%l:+%t' 2>/dev/null)" || return 1
  [ -n "$response" ] || return 1

  location="${response%%:*}"
  temperature="${response#*:}"

  location="${location//+/ }"
  temperature="${temperature//+/}"

  location="$(printf '%s' "$location" | format_location)"
  [ -n "$location" ] || return 1
  [ -n "$temperature" ] || return 1

  printf '%s %s %s' "$LOCATION_ICON" "$location" "$temperature"
}

render_window() {
  local text="$1"
  local pos="$2"

  if [ -z "$text" ]; then
    printf '%-*s\n' "$WIDTH" ''
    return
  fi

  if [ "${#text}" -le "$WIDTH" ]; then
    printf '%-*s\n' "$WIDTH" "$text"
    return
  fi

  local doubled="${text}${text}"
  printf '%s\n' "${doubled:$pos:$WIDTH}"
}

current_text=""
last_refresh=0
pos=0
last_text=""

while true; do
  now="$(date +%s)"

  if [ -z "$current_text" ] || [ $((now - last_refresh)) -ge "$REFRESH_SECONDS" ]; then
    new_text="$(fetch_weather)" || new_text=""

    if [ -n "$new_text" ]; then
      current_text="$new_text"
      last_refresh="$now"
    elif [ -z "$current_text" ]; then
      current_text="${LOCATION_ICON} weather N/A"
      last_refresh="$now"
    fi
  fi

  if [ "$current_text" != "$last_text" ]; then
    pos=0
    last_text="$current_text"
  fi

  render_window "$current_text" "$pos"

  if [ "${#current_text}" -gt "$WIDTH" ]; then
    cycle_len=${#current_text}
    pos=$(((pos + 1) % cycle_len))
  else
    pos=0
  fi

  sleep "$STEP_DELAY"
done
