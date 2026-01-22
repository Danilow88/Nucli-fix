#!/usr/bin/env bash
set -euo pipefail

APP_NAME="DiagnuCLI.app"
INSTALL_DIR="/Applications"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$PROJECT_DIR/dist"
UNPACK_DIR="$DIST_DIR/unpacked"
SOURCE_FILES=(
  "$PROJECT_DIR/main.js"
  "$PROJECT_DIR/preload.js"
  "$PROJECT_DIR/renderer.js"
  "$PROJECT_DIR/index.html"
  "$PROJECT_DIR/styles.css"
  "$PROJECT_DIR/package.json"
)

say() { printf "%s\n" "$*"; }

run_cmd() {
  if [[ -w "$INSTALL_DIR" ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

find_app_bundle() {
  if [[ -d "$DIST_DIR/mac-universal/$APP_NAME" ]]; then
    echo "$DIST_DIR/mac-universal/$APP_NAME"
    return
  fi

local arch
arch="$(uname -m)"
if [[ -d "$DIST_DIR/mac-$arch/$APP_NAME" ]]; then
  echo "$DIST_DIR/mac-$arch/$APP_NAME"
  return
fi

if [[ -d "$DIST_DIR/$APP_NAME" ]]; then
  echo "$DIST_DIR/$APP_NAME"
  return
fi

echo ""
}

needs_rebuild() {
  local app_path="$1"
  local asar_path="$app_path/Contents/Resources/app.asar"
  if [[ ! -f "$asar_path" ]]; then
    return 0
  fi

  local asar_mtime
  asar_mtime="$(/usr/bin/stat -f %m "$asar_path")"
  for src in "${SOURCE_FILES[@]}"; do
    if [[ -f "$src" ]]; then
      local src_mtime
      src_mtime="$(/usr/bin/stat -f %m "$src")"
      if [[ "$src_mtime" -gt "$asar_mtime" ]]; then
        return 0
      fi
    fi
  done
  return 1
}

ensure_built() {
  local app_path
  app_path="$(find_app_bundle)"
  if [[ -n "$app_path" ]]; then
    if needs_rebuild "$app_path"; then
      say "Build desatualizado. Recriando app..."
      app_path=""
    else
      echo "$app_path"
      return
    fi
  fi

if [[ -f "$DIST_DIR/DiagnuCLI-1.0.0-universal-mac-finder.zip" ]]; then
  rm -rf "$UNPACK_DIR"
  mkdir -p "$UNPACK_DIR"
  /usr/bin/ditto -x -k "$DIST_DIR/DiagnuCLI-1.0.0-universal-mac-finder.zip" "$UNPACK_DIR"
  echo "$UNPACK_DIR/$APP_NAME"
  return
fi

say "Build nao encontrado. Gerando app..."
if ! command -v node >/dev/null 2>&1; then
  say "Node.js nao encontrado. Instale o Node 18+ e tente novamente."
  exit 1
fi

if [[ -f "$PROJECT_DIR/package-lock.json" ]]; then
  (cd "$PROJECT_DIR" && npm ci)
else
  (cd "$PROJECT_DIR" && npm install)
fi

(cd "$PROJECT_DIR" && npx electron-builder --mac)
app_path="$(find_app_bundle)"
if [[ -z "$app_path" ]]; then
  say "Nao foi possivel localizar o app apos o build."
  exit 1
fi

echo "$app_path"
}

main() {
  local app_path
  app_path="$(ensure_built)"
  if [[ ! -d "$app_path" ]]; then
    say "App nao encontrado: $app_path"
    exit 1
  fi

say "Instalando $APP_NAME em $INSTALL_DIR..."
run_cmd rm -rf "$INSTALL_DIR/$APP_NAME"
run_cmd /usr/bin/ditto "$app_path" "$INSTALL_DIR/$APP_NAME"

say "Removendo quarentena (se existir)..."
run_cmd /usr/bin/xattr -dr com.apple.quarantine "$INSTALL_DIR/$APP_NAME" || true

say "Concluido. Abra o app em $INSTALL_DIR/$APP_NAME"
}

main "$@"
