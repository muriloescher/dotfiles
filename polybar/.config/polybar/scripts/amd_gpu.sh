#!/usr/bin/env bash

for f in /sys/class/drm/card*/device/gpu_busy_percent; do
  [ -r "$f" ] || continue
  val=$(cat "$f" 2>/dev/null)
  case "$val" in
    ''|*[!0-9]*)
      continue
      ;;
    *)
      echo "AMD ${val}%"
      exit 0
      ;;
  esac
done

echo "AMD N/A"
