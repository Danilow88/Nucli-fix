#!/usr/bin/env bash
set -euo pipefail

APP_NAME="DiagnuCLI.app"
INSTALL_DIR="/Applications"

run_cmd() {
  if [[ -w "$INSTALL_DIR" ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

if [[ -d "$INSTALL_DIR/$APP_NAME" ]]; then
  run_cmd rm -rf "$INSTALL_DIR/$APP_NAME"
  echo "Removido: $INSTALL_DIR/$APP_NAME"
else
  echo "Nao encontrado: $INSTALL_DIR/$APP_NAME"
fi
