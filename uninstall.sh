#!/bin/bash

mapfile -t sites < <(ls /etc/nginx/sites-available)

if [ ${#sites[@]} -eq 0 ]; then
    echo "❌ Tidak ada situs yang terdaftar."
    exit 1
fi

echo "Pilih situs yang ingin dihapus:"
for i in "${!sites[@]}"; do
    echo "$((i+1)). ${sites[i]}"
done

read -p "Masukkan nomor pilihan: " choice
if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#sites[@]} )); then
    echo "❌ Pilihan tidak valid."
    exit 1
fi

WP_NAME="${sites[choice-1]}"
WP_DIR="/var/www/$WP_NAME"
WP_USER="${WP_NAME}user"
POOL_CONF="/etc/php/8.3/fpm/pool.d/${WP_NAME}.conf"
NGINX_CONF="/etc/nginx/sites-available/$WP_NAME"
NGINX_LINK="/etc/nginx/sites-enabled/$WP_NAME"

if [[ ! -d "$WP_DIR" ]]; then
    echo "❌ Direktori situs tidak ditemukan: $WP_DIR"
    exit 1
fi

if [[ -f "$WP_DIR/wp-config.php" ]]; then
    DB_NAME=$(grep "DB_NAME" "$WP_DIR/wp-config.php" | cut -d\' -f4)
    DB_USER=$(grep "DB_USER" "$WP_DIR/wp-config.php" | cut -d\'
