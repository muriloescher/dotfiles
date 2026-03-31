#!/usr/bin/env bash

if command -v nvidia-smi >/dev/null 2>&1; then
  util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1)
  if [ -n "$util" ]; then
    echo "NVIDIA ${util}%"
    exit 0
  fi
fi

echo "GPU N/A"
