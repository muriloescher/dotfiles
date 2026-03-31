#!/usr/bin/env bash

on_ac_power() {
    for f in /sys/class/power_supply/AC*/online /sys/class/power_supply/ADP*/online /sys/class/power_supply/ACAD*/online; do
        [ -f "$f" ] || continue
        [ "$(cat "$f")" = "1" ] && return 0
    done
    return 1
}

if on_ac_power; then
    exit 0
else
    exec "$HOME/.config/i3/lock.sh"
fi
