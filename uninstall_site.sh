#!/bin/bash

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$BASE_DIR/helpers/functions.sh"

LOG_FILE="$BASE_DIR/logs/uninstall.log"
exec > >(tee -a "$LOG_FILE") 2>&1

SITES_DIR="$BASE_DIR/sites"
AVAILABLE_SITES=($(ls -1 "$SITES_DIR"))

if [ ${#AVAILABLE_SITES[@]} -eq 0 ]; then
  error_msg "Belum ada situs yang tersedia untuk dihapus."
  exit 1
fi

# Tampilkan pilihan situs
SITE=$(dialog --clear \
  --backtitle "Hapus Situs WordPress" \
  --title "Pilih Situs" \
  --menu "Pilih situs yang ingin dihapus:" 15 60 5 \
  $(for s in "${AVAILABLE_SITES[@]}"; do echo "$s" "-"; done) \
  2>&1 >/dev/tty)

[ -z "$SITE" ] && exit 0

# Konfirmasi
dialog --title "Konfirmasi" --yesno "Yakin ingin menghapus situs: $SITE?" 7 50
[ $? -ne 0 ] && exit 0

log_step "Menghapus konfigurasi dan data situs $SITE..."

rm -rf "$SITES_DIR/$SITE"

rm -f "/etc/nginx/sites-available/$SITE.conf"
rm -f "/etc/nginx/sites-enabled/$SITE.conf"
rm -f "/etc/php/$(get_php_version)/fpm/pool.d/$SITE.conf"

log_step "Reload layanan..."
systemctl reload php$(get_php_version)-fpm
systemctl reload nginx

dialog --msgbox "Situs $SITE berhasil dihapus." 6 40
