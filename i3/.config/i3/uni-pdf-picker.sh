#!/usr/bin/env bash

set -u

uniroot="${HOME}/Documents/uni/master"
theme="${HOME}/.config/rofi/theme.rasi"

if [[ ! -d "$uniroot" ]]; then
    exit 1
fi

query=""
format=$'i\x1ff'

while true; do
    mapfile -t pdfs < <(fdfind -I -e pdf . "$uniroot" 2>/dev/null | sed "s|^$uniroot/||")
    [[ ${#pdfs[@]} -eq 0 ]] && break

    result="$(printf '%s\n' "${pdfs[@]}" | rofi -dmenu -i -p "Uni PDFs" -theme "$theme" -no-custom -filter "$query" -format "$format")"
    rofi_status=$?

    if [[ $rofi_status -ne 0 ]]; then
        break
    fi

    [[ "$result" == *$'\x1f'* ]] || continue

    picked_index="${result%%$'\x1f'*}"
    query="${result#*$'\x1f'}"

    [[ "$picked_index" =~ ^[0-9]+$ ]] || continue
    (( picked_index < ${#pdfs[@]} )) || continue

    picked="${pdfs[picked_index]}"

    full_path="$uniroot/$picked"
    [[ -f "$full_path" ]] || continue

    zathura "$full_path" >/dev/null 2>&1 &
done
