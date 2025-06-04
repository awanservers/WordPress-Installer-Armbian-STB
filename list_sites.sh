#!/bin/bash

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
SITES_DIR="$BASE_DIR/sites"

if [ ! -d "$SITES_DIR" ]; then
  echo "Belum ada situs yang dibuat."
  exit 0
fi

SITES=$(ls -1 "$SITES_DIR")

dialog --title "Daftar Situs WordPress" --msgbox "$SITES" 20 60
