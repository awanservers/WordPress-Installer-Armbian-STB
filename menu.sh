#!/bin/bash

while true; do
  echo "======================================"
  echo " Script WordPress Multi-site Nginx"
  echo "======================================"
  echo "1) Install paket yang dibutuhkan"
  echo "2) Tambah situs WordPress baru"
  echo "3) Tampilkan daftar situs"
  echo "4) Hapus situs WordPress"
  echo "5) Keluar"
  echo "======================================"
  read -p "Pilih opsi [1-5]: " CHOICE

  case $CHOICE in
    1) ./install.sh ;;
    2) ./create.sh ;;
    3) ./list.sh ;;
    4) ./uninstall.sh ;;
    5) echo "Bye!"; exit 0 ;;
    *) echo "Pilihan salah, coba lagi." ;;
  esac
done
