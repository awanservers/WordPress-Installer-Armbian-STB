#!/bin/bash

echo "📦 Memastikan semua paket sudah terpasang..."
apt update && apt install -y nginx mariadb-server php-fpm php-mysql \
    php-curl php-gd php-mbstring php-xml php-xmlrpc php-zip php-soap php-intl \
    unzip curl wget

echo "✅ Paket sudah terpasang."
