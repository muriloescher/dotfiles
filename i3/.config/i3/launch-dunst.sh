#!/usr/bin/env bash
set -euo pipefail

pkill -x dunst || true
nohup dunst >/dev/null 2>&1 &
