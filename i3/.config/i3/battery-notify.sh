#!/usr/bin/env bash
set -euo pipefail

lockfile="/tmp/i3-battery-notify.lock"
exec 9>"$lockfile"
flock -n 9 || exit 0

on_ac_power() {
    for f in /sys/class/power_supply/AC*/online /sys/class/power_supply/ADP*/online /sys/class/power_supply/ACAD*/online; do
        [ -f "$f" ] || continue
        [ "$(<"$f")" = "1" ] && return 0
    done
    return 1
}

battery_percent() {
    for f in /sys/class/power_supply/BAT*/capacity; do
        [ -f "$f" ] || continue
        pct="$(<"$f")"
        [[ "$pct" =~ ^[0-9]+$ ]] || continue
        echo "$pct"
        return 0
    done
    return 1
}

warned_15=0
warned_5=0

while true; do
    if on_ac_power; then
        warned_15=0
        warned_5=0
        sleep 60
        continue
    fi

    if ! pct="$(battery_percent)"; then
        sleep 60
        continue
    fi

    if (( pct <= 5 )) && (( warned_5 == 0 )); then
        notify-send -u critical -t 0 "Battery critical (${pct}%)" "Plug in your charger now."
        warned_5=1
        warned_15=1
    elif (( pct <= 15 )) && (( warned_15 == 0 )); then
        notify-send -u normal -t 10000 "Battery low (${pct}%)" "Battery is running low."
        warned_15=1
    fi

    sleep 60
done
