#!/usr/bin/env bash
set -euo pipefail

PNG="$("$HOME/.local/bin/generate-lockscreen")"
exec i3lock -i "$PNG" -e
