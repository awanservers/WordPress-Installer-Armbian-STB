#!/bin/bash

read -p "Masukkan nama direktori (contoh: wp01): " WP_NAME

WP_USER="${WP_NAME}user"

while true; do
    read -p "Masukkan PORT yang ingin digunakan (misal: 8081) atau tekan [Enter] untuk otomatis: " PORT
    if [[ -z "$PORT" ]]; then
        for p in {8080..9000}; do
            if ! ss -tuln | grep -q ":$p "; then
                PORT=$p
                echo "✅ Port otomatis yang tersedia: $PORT"
                break
            fi
        done
        if [[ -z "$PORT" ]]; then
            echo "❌ Tidak ditemukan port kosong antara 8080–9000"
            exit 1
        fi
        break
    elif ss -tuln | grep -q ":$PORT "; then
        echo "❌ Port $PORT sudah digunakan. Silakan pilih port lain."
    else
        echo "✅ Port $PORT tersedia."
        break
    fi
done

read -p "Masukkan nama database: " DB_NAME
read -p "Masukkan username database: " DB_USER
read -s -p "Masukkan password database: " DB_PASS
echo

WP_DIR="/var/www/$WP_NAME"

echo "👤 Membuat user Linux khusus untuk pool PHP: $WP_USER"
id -u $WP_USER &>/dev/null || adduser --system --no-create-home --group $WP_USER

echo "🛠️ Membuat database dan user..."
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "⬇️ Mengunduh WordPress..."
mkdir -p $WP_DIR
cd /tmp
wget -q https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* $WP_DIR

echo "🔐 Mengatur izin file..."
chown -R $WP_USER:$WP_USER $WP_DIR
chmod -R 755 $WP_DIR

echo "⚙️ Membuat wp-config.php..."
cp $WP_DIR/wp-config-sample.php $WP_DIR/wp-config.php
sed -i "s/database_name_here/$DB_NAME/" $WP_DIR/wp-config.php
sed -i "s/username_here/$DB_USER/" $WP_DIR/wp-config.php
sed -i "s/password_here/$DB_PASS/" $WP_DIR/wp-config.php

curl -s https://api.wordpress.org/secret-key/1.1/salt/ > /tmp/wp-keys
sed -i '/AUTH_KEY/d' $WP_DIR/wp-config.php
sed -i '/put your unique phrase here/d' $WP_DIR/wp-config.php
sed -i "/define('DB_COLLATE', '');/r /tmp/wp-keys" $WP_DIR/wp-config.php

echo "⚙️ Membuat konfigurasi PHP-FPM pool untuk $WP_NAME..."

POOL_FILE="/etc/php/8.3/fpm/pool.d/${WP_NAME}.conf"
cat <<EOF > $POOL_FILE
[$WP_NAME]
user = $WP_USER
group = $WP_USER
listen = /run/php/php8.3-fpm-${WP_NAME}.sock
listen.owner = www-data
listen.group = www-data

pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3

php_admin_value[upload_max_filesize] = 64M
php_admin_value[post_max_size] = 64M
php_admin_value[memory_limit] = 128M

chdir = /
EOF

echo "🔄 Reload PHP-FPM..."
systemctl reload php8.3-fpm

echo "⚙️ Membuat konfigurasi Nginx port $PORT..."
cat <<EOF > /etc/nginx/sites-available/$WP_NAME
server {
    listen $PORT;
    server_name _;
    root $WP_DIR;

    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm-${WP_NAME}.sock;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)\$ {
        expires max;
        log_not_found off;
    }

    location = /favicon.ico { log_not_found off; access_log off; }
    location = /robots.txt  { log_not_found off; access_log off; allow all; }

    access_log /var/log/nginx/$WP_NAME.access.log;
    error_log /var/log/nginx/$WP_NAME.error.log;
}
EOF

ln -sf /etc/nginx/sites-available/$WP_NAME /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

SERVER_IP=$(hostname -I | awk '{print $1}')

echo
echo "🎉 Situs WordPress berhasil dibuat!"
echo "------------------------------"
echo "Nama situs   : $WP_NAME"
echo "Direktori    : $WP_DIR"
echo "Port         : $PORT"
echo "PHP-FPM user : $WP_USER"
echo "Akses URL    : http://$SERVER_IP:$PORT"
echo "------------------------------"
echo
