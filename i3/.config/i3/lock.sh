#!/usr/bin/env bash
set -euo pipefail

PNG="$HOME/.cache/lockscreen.png"

if [[ ! -f "$PNG" ]]; then
  echo "Missing lockscreen image: $PNG" >&2
  exit 1
fi

GEOM="$(
  xrandr | awk '
    /^eDP[[:space:]]connected/ {
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^[0-9]+x[0-9]+\+[0-9]+\+[0-9]+$/) {
          print $i
          exit
        }
      }
    }
  '
)"

if [[ -z "${GEOM:-}" ]]; then
  echo "Could not detect eDP geometry from xrandr" >&2
  exit 1
fi

IFS='x+' read -r W H X Y <<< "$GEOM"

CENTER_X=$((X + W / 2))
CENTER_Y=$((Y + H / 2))

exec i3lock \
  --image "$PNG" \
  --indicator \
  --ind-pos "$CENTER_X:$CENTER_Y" \
  --ring-color=ffffffff \
  --inside-color=00000088 \
  --line-color=00000000 \
  --separator-color=00000000 \
  --ignore-empty-password
