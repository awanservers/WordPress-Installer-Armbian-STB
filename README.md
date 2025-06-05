# 🧰 WordPress Installer untuk Armbian STB

Installer otomatis untuk men-setup WordPress di perangkat Armbian STB (Set-Top Box) dengan Nginx, MariaDB, dan PHP-FPM.  
Masing-masing site menggunakan socket dan pool PHP-FPM sendiri (isolasi per site).

---

## ✨ Fitur

- Instalasi WordPress full otomatis
- Setup Nginx + MariaDB + PHP-FPM
- Pool PHP-FPM per site (isolasi socket)
- Validasi port dan direktori
- Auto generate database name, user, dan password
- Log instalasi tersimpan di `~/.wp_installs.log`
- Menu berbasis teks, mudah digunakan
- Uninstaller per site

---

## 📦 Requirements

- OS: Armbian (atau Debian-based lainnya)
- Paket:
  - `nginx`, `mariadb-server`
  - `php`, `php-fpm`, `php-mysql`, `wget`, `unzip`, dll

---

## 🚀 Cara Instalasi

```bash
wget https://raw.githubusercontent.com/awanservers/WordPress-Installer-Armbian-STB/main/install.sh
chmod +x install.sh
./install.sh


🖥️ Menu Utama
text
Copy
Edit
=== Auto Installer WordPress untuk Armbian STB ===
1. Install WordPress
2. Uninstall WordPress
3. Keluar
🧹 Uninstall
Installer ini menyimpan log instalasi di ~/.wp_installs.log.
Untuk uninstall per site, cukup pilih menu "Uninstall WordPress" dan pilih direktori yang ingin dihapus.
Uninstall akan:

Menghapus direktori di /var/www/

Menghapus konfigurasi Nginx

Menghapus database dan user

Menghapus pool PHP-FPM dan socket

📝 Log Instalasi
Setiap instalasi disimpan dalam:

bash
Copy
Edit
~/.wp_installs.log
Format:

Copy
Edit
nama_direktori|nama_database|user_db|port
📷 Screenshot (Opsional)
Tambahkan gambar contoh tampilan terminal/menu di sini jika ada.

⚠️ Catatan
Gunakan dengan hak akses sudo

Pastikan port yang dipilih tidak bentrok dengan service lain

Untuk penggunaan publik, amankan instalasi WordPress setelah setup

🧑‍💻 Kontribusi
Pull request dan issue terbuka untuk perbaikan, fitur tambahan, atau optimalisasi.

