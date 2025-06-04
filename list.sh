#!/bin/bash

echo "📋 Daftar situs WordPress yang sudah dibuat:"
echo "-------------------------------------------"

for conf in /etc/nginx/sites-available/*; do
    [[ -f "$conf" ]] || continue
    WP_NAME=$(basename "$conf")
    PORT=$(grep -Po '(?<=listen )\d+' "$conf" | head -1)
    WP_USER="${WP_NAME}user"

    echo "- Site: $WP_NAME"
    echo "  Port: $PORT"
    echo "  PHP-FPM User: $WP_USER"
    echo
done
