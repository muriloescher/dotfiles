#!/usr/bin/env bash

pkill picom 2>/dev/null
sleep 1
picom --config "$HOME/.config/picom/picom.conf" --log-level=warn -b
