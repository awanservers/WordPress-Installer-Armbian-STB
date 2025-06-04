#!/bin/bash

DIALOG=${DIALOG=dialog}
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

LOG_DIR="$BASE_DIR/logs"
mkdir -p "$LOG_DIR"

while true; do
  CHOICE=$(dialog --clear \
    --backtitle "WordPress Installer Armbian STB" \
    --title "Menu Utama" \
    --menu "Pilih opsi:" 15 50 6 \
    1 "Install WordPress Baru" \
    2 "Hapus Situs WordPress" \
    3 "Daftar Situs Aktif" \
    4 "Keluar" \
    2>&1 >/dev/tty)

  clear
  case $CHOICE in
    1) bash "$BASE_DIR/install_site.sh" ;;
    2) bash "$BASE_DIR/uninstall_site.sh" ;;
    3) bash "$BASE_DIR/list_sites.sh" ;;
    4) echo "Keluar..." && exit 0 ;;
    *) echo "Pilihan tidak valid!" ;;
  esac
done
