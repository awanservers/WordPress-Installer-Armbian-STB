# WordPress Installer Armbian STB

Sebuah script bash interaktif untuk menginstal dan mengelola banyak situs WordPress di perangkat lokal berbasis Armbian (seperti STB HG680P). Tidak membutuhkan Let's Encrypt, dan mendukung port kustom untuk tiap website.

---

## 🎯 Fitur Utama

- Instalasi otomatis WordPress (Nginx, MariaDB, PHP-FPM)
- Support multi-situs dengan pilihan port kustom
- Konfigurasi domain, database, user, dan password dinamis
- PHP-FPM pool terpisah untuk tiap situs (keamanan dan performa)
- Validasi port sudah digunakan atau belum
- Tampilan daftar situs yang sudah dibuat
- Fitur uninstall lengkap dan aman
- Struktur script modular (terpisah per fitur)
- Dirancang khusus untuk perangkat lokal tanpa internet publik

---

## 📦 Persyaratan

- Sistem: Armbian / Debian / Ubuntu 24.04
- Paket: `nginx`, `mariadb-server`, `php`, `php-fpm`, `wget`, `unzip`, `curl`, `dialog` (untuk antarmuka menu interaktif)

---

## 🚀 Cara Menggunakan

1. Clone repositori:

```bash
git clone https://github.com/awanservers/WordPress-Installer-Armbian-STB.git
cd WordPress-Installer-Armbian-STB