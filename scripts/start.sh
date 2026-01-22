#!/bin/bash

set -e

APP_NAME="DiagnuCLI"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$PROJECT_DIR/diagnucli-electron"
DEV_APP="$HOME/Applications/${APP_NAME}-Dev.app"

if [ ! -d "$DEV_APP" ]; then
  echo "Atalho dev nao encontrado. Criando..."
  "$PROJECT_DIR/scripts/create-dev-app.sh"
fi

open -a "$DEV_APP" || {
  echo "Falha ao abrir o app dev. Iniciando via npm start..."
  cd "$APP_DIR"
  npm start
}
