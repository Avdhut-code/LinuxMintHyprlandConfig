#!/bin/bash

set -e

if ! command -v gnome-terminal &>/dev/null; then
  echo "Error: gnome-terminal is not installed or not in PATH." >&2
  exit 1
fi

if ! command -v btop &>/dev/null; then
  echo "Error: btop is not installed or not in PATH." >&2
  exit 1
fi

gnome-terminal --class=custom-launch-btop --title="btop Moniter" -- sh -c 'btop --utf-force'
