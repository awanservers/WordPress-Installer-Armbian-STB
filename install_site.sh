#!/bin/bash

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$BASE_DIR/helpers/functions.sh"
source "$BASE_DIR/helpers/validate.sh"

LOG_FILE="$BASE_DIR/logs/install.log"
exec > >(tee -a "$LOG_FILE") 2>&1

dialog --title "Instalasi WordPress" --infobox "Menyiapkan instalasi..." 5 40
sleep 1

# 1. Ambil input
DOMAIN=$(input_text "Nama domain (tanpa http://)" "")
PORT=$(input_text "Port yang akan digunakan" "")
DB_NAME=$(input_text "Nama database" "")
DB_USER=$(input_text "User database" "")
DB_PASS=$(input_text "Password database" "")

# 2. Validasi
if ! validate_port "$PORT"; then
  error_msg "Port $PORT sudah digunakan!"
  exit 1
fi

if [ -d "$BASE_DIR/sites/$DOMAIN" ]; then
  error_msg "Domain $DOMAIN sudah terdaftar!"
  exit 1
fi

# 3. Buat direktori
mkdir -p "$BASE_DIR/sites/$DOMAIN/public"

# 4. Setup database
log_step "Membuat database..."
mysql -e "CREATE DATABASE $DB_NAME;"
mysql -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# 5. Unduh WordPress
log_step "Mengunduh WordPress..."
cd "$BASE_DIR/sites/$DOMAIN"
wget -q https://wordpress.org/latest.zip
unzip -qq latest.zip
mv wordpress/* public/
rm -rf wordpress latest.zip

# 6. Konfigurasi wp-config
cp public/wp-config-sample.php public/wp-config.php
sed -i "s/database_name_here/$DB_NAME/" public/wp-config.php
sed -i "s/username_here/$DB_USER/" public/wp-config.php
sed -i "s/password_here/$DB_PASS/" public/wp-config.php

# 7. Setup Nginx dan PHP-FPM
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN.conf"
PHP_POOL_CONF="/etc/php/$(get_php_version)/fpm/pool.d/$DOMAIN.conf"

cp "$BASE_DIR/config/nginx_template.conf" "$NGINX_CONF"
cp "$BASE_DIR/config/php_pool_template.conf" "$PHP_POOL_CONF"

sed -i "s/__DOMAIN__/$DOMAIN/g" "$NGINX_CONF"
sed -i "s/__PORT__/$PORT/g" "$NGINX_CONF"
sed -i "s#__ROOT__#$BASE_DIR/sites/$DOMAIN/public#g" "$NGINX_CONF"

sed -i "s/__POOL_NAME__/$DOMAIN/g" "$PHP_POOL_CONF"
sed -i "s#__SITE_PATH__#$BASE_DIR/sites/$DOMAIN#g" "$PHP_POOL_CONF"

ln -s "$NGINX_CONF" /etc/nginx/sites-enabled/

# 8. Restart layanan
log_step "Restart layanan Nginx & PHP-FPM..."
systemctl reload php$(get_php_version)-fpm
systemctl reload nginx

# 9. Selesai
dialog --title "Selesai" --msgbox "WordPress untuk $DOMAIN berhasil diinstal di port $PORT!" 7 50
