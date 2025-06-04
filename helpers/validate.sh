#!/bin/bash

validate_port() {
  local port=$1
  if lsof -i ":$port" >/dev/null 2>&1; then
    return 1
  else
    return 0
  fi
}
