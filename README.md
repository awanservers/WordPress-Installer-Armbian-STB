# 🧰 WordPress Installer untuk Armbian STB

Installer otomatis untuk men-setup WordPress di perangkat **Armbian STB (Set-Top Box)** dengan Nginx, MariaDB, dan PHP-FPM.  
Setiap site dikonfigurasi menggunakan socket dan pool PHP-FPM tersendiri (isolasi per site).

---

## ✨ Fitur

- Instalasi WordPress full otomatis
- Setup Nginx + MariaDB + PHP-FPM
- Pool PHP-FPM per site (dengan socket unik)
- Validasi port, direktori, dan nama database
- Auto-generate database name, user, dan password
- Log instalasi tersimpan di `~/.wp_installs.log`
- Menu interaktif berbasis teks
- Tersedia uninstaller per site

---

## 📦 Requirements

- **OS**: Armbian (atau Debian-based lainnya)
- **Paket yang dibutuhkan**:
  - `nginx`, `mariadb-server`
  - `php`, `php-fpm`, `php-mysql`
  - `wget`, `unzip`, dll

---

## 🚀 Cara Instalasi

```bash
wget https://raw.githubusercontent.com/awanservers/WordPress-Installer-Armbian-STB/main/install.sh
chmod +x install.sh
./install.sh
```

---

## 🖥️ Menu Utama

```text
=== Auto Installer WordPress untuk Armbian STB ===
1. Install WordPress
2. Uninstall WordPress
3. Keluar
```

---

## 🧹 Uninstall

Script ini menyimpan log instalasi di `~/.wp_installs.log`.

Untuk menghapus salah satu instalasi:
- Pilih menu **Uninstall WordPress**
- Pilih nama direktori dari list yang muncul

Uninstall akan:
- Menghapus direktori dari `/var/www/`
- Menghapus konfigurasi Nginx
- Menghapus database dan user dari MariaDB
- Menghapus pool PHP-FPM dan socket-nya

---

## 📝 Log Instalasi

Setiap instalasi akan disimpan di:

```
~/.wp_installs.log
```

Format:
```
nama_direktori|nama_database|user_db|port
```

---

## 📷 Screenshot (Opsional)

_Tambahkan gambar tampilan terminal/menu jika tersedia._

---

## ⚠️ Catatan

- Jalankan dengan hak akses `sudo`
- Pastikan port yang dipilih tidak sedang digunakan oleh service lain
- Untuk penggunaan publik, lakukan hardening/keamanan tambahan pada WordPress

---

## 🧑‍💻 Kontribusi

Pull request dan issue terbuka untuk:
- Perbaikan bug
- Fitur tambahan
- Optimalisasi script dan struktur

---

## 📄 Lisensi

MIT License © 2025 [awanservers](https://github.com/awanservers)
