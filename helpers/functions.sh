#!/bin/bash

log_step() {
  echo -e "\n🔧 $1"
}

error_msg() {
  dialog --title "Error" --msgbox "$1" 7 50
}

input_text() {
  TITLE="$1"
  DEFAULT="$2"
  dialog --inputbox "$TITLE" 8 50 "$DEFAULT" 2>&1 >/dev/tty
}

get_php_version() {
  php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;"
}
