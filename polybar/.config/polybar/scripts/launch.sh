# #!/usr/bin/env bash
# 
# killall -q polybar
# 
# while pgrep -u "$UID" -x polybar >/dev/null; do
#   sleep 0.2
# done
# 
# # IMPORTANT: adjust this if needed
# primary="eDP"
# 
# # allow autorandr/xrandr to settle
# sleep 1
# 
# # wait until monitor list is stable
# prev=""
# for _ in $(seq 1 20); do
#   current="$(polybar --list-monitors 2>/dev/null | cut -d: -f1 | sort | tr '\n' ' ')"
# 
#   if [ -n "$current" ] && [ "$current" = "$prev" ]; then
#     break
#   fi
# 
#   prev="$current"
#   sleep 0.3
# done
# 
# # launch bars
# for m in $current; do
#   if [ "$m" = "$primary" ]; then
#     echo "Launching MAIN on $m"
#     MONITOR="$m" polybar --reload main &
#   else
#     echo "Launching SECONDARY on $m"
#     MONITOR="$m" polybar --reload main-secondary &
#   fi
# done

#!/usr/bin/env bash

killall -q polybar
while pgrep -u "$UID" -x polybar >/dev/null; do
  sleep 0.2
done

primary="eDP"

sleep 1

MONITOR="$primary" polybar --reload main &
