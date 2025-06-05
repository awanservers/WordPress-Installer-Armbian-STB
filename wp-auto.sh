#!/bin/bash

green=$(tput setaf 2)
red=$(tput setaf 1)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

check_service() {
  service=$1
  echo -n "Memeriksa service $service... "
  if systemctl is-active --quiet "$service"; then
    echo "${green}[aktif]${reset}"
  else
    echo "${red}[gagal aktif]${reset}"
    echo "Silakan cek log: sudo journalctl -xeu $service"
    exit 1
  fi
}

menu() {
  clear
  echo "${green}=== Auto Installer WordPress untuk Armbian STB ===${reset}"
  echo "1. Install WordPress"
  echo "2. Hapus WordPress (Uninstall)"
  echo "3. Keluar"
  echo -n "Pilih opsi [1-2]: "
  read opsi
  case $opsi in
    1) install_wordpress ;;
    2) uninstall_wordpress ;;
    3) exit ;;
    *) echo "${red}Pilihan tidak valid!${reset}" && sleep 2 && menu ;;
  esac
}

install_wordpress() {
  echo "[1/7] Update & install paket..."
  sudo apt update && sudo apt install -y nginx mariadb-server php-fpm php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc wget unzip

  echo "[1b] Aktifkan dan periksa semua service..."
  sudo systemctl enable nginx --now
  check_service nginx

  sudo systemctl enable mariadb --now
  check_service mariadb

  for fpm in $(systemctl list-units --type=service | grep php.*fpm | awk '{print $1}'); do
    sudo systemctl enable "$fpm" --now
    check_service "$fpm"
  done

  echo "${green}[OK] Semua service aktif.${reset}"

  php_ver=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

  while true; do
    read -p "Masukkan nama direktori WordPress (default: wordpress): " wp_dir
    wp_dir=${wp_dir:-wordpress}
    if [[ ! "$wp_dir" =~ ^[a-zA-Z0-9_-]+$ ]]; then
      echo "${red}Hanya boleh huruf, angka, dash (-), underscore (_).${reset}"
      continue
    fi
    if [ -d "/var/www/$wp_dir" ]; then
      echo "${yellow}Direktori /var/www/$wp_dir sudah ada. Silakan pilih nama lain.${reset}"
      continue
    fi
    break
  done

  dbname="wp_${wp_dir}"
  dbuser="user_${wp_dir}"
  dbpass=$(openssl rand -base64 12)
  dbpass_escaped=$(printf '%s\n' "$dbpass" | sed 's/[&/\]/\\&/g')

  while true; do
    read -p "Masukkan port untuk webserver (default: 8080): " port
    port=${port:-8080}
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
      echo "${red}Port tidak valid. Harus angka 1–65535.${reset}"
      continue
    fi
    if sudo nginx -T 2>/dev/null | grep -P "listen\s+($port|[0-9.:]*:$port)\b" &>/dev/null; then
      echo "${red}Port $port sudah digunakan oleh konfigurasi Nginx lain. Pilih port lain.${reset}"
      continue
    fi
    break
  done

  echo "[2/7] Setup database..."
  sudo mysql -e "CREATE DATABASE $dbname;"
  sudo mysql -e "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';"
  sudo mysql -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';"
  sudo mysql -e "FLUSH PRIVILEGES;"

  echo "[3/7] Download WordPress..."
  wget https://wordpress.org/latest.zip -P /tmp/
  unzip /tmp/latest.zip -d /tmp/
  sudo mv /tmp/wordpress /var/www/$wp_dir

  echo "[4/7] Konfigurasi WordPress..."
  cp /var/www/$wp_dir/wp-config-sample.php /var/www/$wp_dir/wp-config.php
  sed -i "s/database_name_here/$dbname/" /var/www/$wp_dir/wp-config.php
  sed -i "s/username_here/$dbuser/" /var/www/$wp_dir/wp-config.php
  sed -i "s/password_here/$dbpass_escaped/" /var/www/$wp_dir/wp-config.php

  echo "[5/7] Set permission..."
  sudo chown -R www-data:www-data /var/www/$wp_dir
  sudo find /var/www/$wp_dir -type d -exec chmod 755 {} \;
  sudo find /var/www/$wp_dir -type f -exec chmod 644 {} \;

  echo "[6/7] Konfigurasi PHP-FPM Pool..."
  pool_file="/etc/php/${php_ver}/fpm/pool.d/${wp_dir}.conf"
  sock_file="/run/php/php${php_ver}-${wp_dir}.sock"

  sudo tee "$pool_file" > /dev/null <<EOF
[$wp_dir]
user = www-data
group = www-data
listen = $sock_file
listen.owner = www-data
listen.group = www-data
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
chdir = /
EOF

  sudo systemctl restart php${php_ver}-fpm
  sleep 2
  check_service php${php_ver}-fpm

  echo "[6b] Setup Nginx..."
  sudo tee /etc/nginx/sites-available/$wp_dir > /dev/null <<EOF
server {
    listen $port;
    server_name localhost;

    root /var/www/$wp_dir;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$sock_file;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

  [ ! -e /etc/nginx/sites-enabled/$wp_dir ] && sudo ln -s /etc/nginx/sites-available/$wp_dir /etc/nginx/sites-enabled/
  sudo nginx -t && sudo systemctl reload nginx

  # Bagian Akhir Cantik
  echo
  echo "${green}[7/7] Instalasi WordPress Selesai!${reset}"
  echo "--------------------------------------------"
  printf "${yellow}%-12s${reset} %s\n" "URL:" "http://$(hostname -I | awk '{print $1}'):$port/"
  printf "${yellow}%-12s${reset} %s\n" "Direktori:" "/var/www/$wp_dir"
  printf "${yellow}%-12s${reset} %s\n" "Database:" "$dbname"
  printf "${yellow}%-12s${reset} %s\n" "User DB:" "$dbuser"
  printf "${yellow}%-12s${reset} %s\n" "Password:" "$dbpass"
  echo "--------------------------------------------"
  echo "${green}✅ Informasi juga disimpan di: ~/.wp_installs.log${reset}"
  echo

  echo "$wp_dir|$dbname|$dbuser|$port" >> ~/.wp_installs.log
  read -p "Tekan Enter untuk kembali ke menu..." _
}

uninstall_wordpress() {
  clear
  echo "${yellow}=== Uninstaller WordPress ===${reset}"
  if [ ! -f ~/.wp_installs.log ]; then
    echo "${red}Belum ada instalasi yang tercatat.${reset}"
    read -p "Tekan Enter untuk kembali ke menu..." _
    return
  fi

  echo "Daftar situs terinstall:"
  awk -F'|' '{printf "%d. %s (port %s)\n", NR, $1, $4}' ~/.wp_installs.log
  echo -n "Pilih nomor situs yang ingin dihapus: "
  read nomor
  info=$(sed -n "${nomor}p" ~/.wp_installs.log)

  if [ -z "$info" ]; then
    echo "${red}Pilihan tidak valid.${reset}"
    read -p "Tekan Enter untuk kembali ke menu..." _
    return
  fi

  wp_dir=$(echo "$info" | cut -d'|' -f1)
  dbname=$(echo "$info" | cut -d'|' -f2)
  dbuser=$(echo "$info" | cut -d'|' -f3)
  port=$(echo "$info" | cut -d'|' -f4)
  php_ver=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

  echo
  echo "${yellow}Menghapus situs: /var/www/$wp_dir (port: $port)${reset}"
  read -p "Ketik 'hapus' untuk konfirmasi: " konfirmasi
  if [ "$konfirmasi" != "hapus" ]; then
    echo "${red}Dibatalkan.${reset}"
    return
  fi

  echo "[1/5] Hapus direktori WordPress..."
  sudo rm -rf /var/www/$wp_dir

  echo "[2/5] Hapus konfigurasi Nginx..."
  sudo rm -f /etc/nginx/sites-{available,enabled}/$wp_dir

  echo "[3/5] Hapus PHP-FPM Pool..."
  sudo rm -f /etc/php/${php_ver}/fpm/pool.d/${wp_dir}.conf

  echo "[4/5] Hapus database dan user MySQL..."
  sudo mysql -e "DROP DATABASE IF EXISTS $dbname;"
  sudo mysql -e "DROP USER IF EXISTS '$dbuser'@'localhost';"
  sudo mysql -e "FLUSH PRIVILEGES;"

  echo "[5/5] Restart layanan..."
  sudo systemctl reload nginx
  sudo systemctl restart php${php_ver}-fpm

  sed -i "${nomor}d" ~/.wp_installs.log

  echo
  echo "${green}✅ Situs '$wp_dir' berhasil dihapus.${reset}"
  read -p "Tekan Enter untuk kembali ke menu..." _
menu
}