#!/usr/bin/env bash
set -euo pipefail

PNG="$HOME/.cache/lockscreen.png"

if [[ ! -f "$PNG" ]]; then
  echo "Missing lockscreen image: $PNG" >&2
  exit 1
fi

EDP_SCREEN="$(
  xrandr --listactivemonitors 2>/dev/null | awk '
    $NF ~ /^eDP/ {
      sub(/:/, "", $1)
      print $1
      exit
    }
  '
)"

if [[ -z "${EDP_SCREEN:-}" ]]; then
  echo "Could not detect eDP monitor index from xrandr --listactivemonitors" >&2
  exit 1
fi

i3lock \
  --nofork \
  --image "$PNG" \
  --indicator \
  --screen "$EDP_SCREEN" \
  --ind-pos 'x+w/2:y+h/2' \
  --ring-color=ffffffff \
  --inside-color=00000088 \
  --line-color=00000000 \
  --separator-color=00000000 \
  --ignore-empty-password &

LOCK_PID=$!

# Turn the display off once i3lock has grabbed input.
sleep 0.2
xset dpms force off || true

wait "$LOCK_PID"
