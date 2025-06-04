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
- Paket: `nginx`, `mariadb-server`, `php`, `php-fpm`, `wget`, `unzip`, `curl`, `dialog`

---

## 🚀 Cara Menggunakan

1. Clone repositori:

    ```bash
    git clone https://github.com/awanservers/WordPress-Installer-Armbian-STB.git
    cd WordPress-Installer-Armbian-STB
    ```

2. Jalankan script utama:

    ```bash
    sudo bash installer.sh
    ```

---

## 🧩 Struktur Script

```bash
WordPress-Installer-Armbian-STB/
├── installer.sh          # Menu utama
├── install_site.sh       # Instalasi situs WordPress baru
├── uninstall_site.sh     # Hapus situs WordPress
├── list_sites.sh         # Tampilkan daftar situs
├── config/               # Folder konfigurasi pool PHP dan nginx
├── sites/                # Lokasi direktori situs WordPress
└── helpers/              # Fungsi tambahan
```


---

## 📝 Catatan

- Script ini **tidak menggunakan Let's Encrypt** karena ditujukan untuk lokal/STB tanpa domain publik
- Port untuk tiap situs **dapat disesuaikan** selama belum digunakan
- Disarankan untuk menjalankan script sebagai **root** atau dengan `sudo`
- Mendukung lebih dari 1 situs WordPress secara paralel (multi-site, multi-port)

---

## 📬 Kontribusi

Jika kamu ingin menambahkan fitur atau memperbaiki bug, silakan **fork** repo ini dan buat **pull request**. Semua kontribusi sangat diapresiasi!

---

## 🛡️ Lisensi

Proyek ini dilisensikan di bawah **MIT License**

---

## 🙌 Terima Kasih

Script ini dibuat untuk komunitas STB Armbian dan pengguna WordPress lokal oleh [awanservers.com](https://awanservers.com)
