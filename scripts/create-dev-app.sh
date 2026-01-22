#!/bin/bash

# Cria um app wrapper que executa "npm start" e exibe nome/icone DiagnuCLI.

set -e

APP_NAME="DiagnuCLI Dev"
APP_DIR="$HOME/Applications"
PROJECT_DIR="${1:-$HOME/dev/nu/Nucli-fix/diagnucli-electron}"
ICON_SRC="$PROJECT_DIR/assets/icon.icns"
APP_BUNDLE="$APP_DIR/$APP_NAME.app"

if [ ! -d "$PROJECT_DIR" ]; then
  echo "Diretorio nao encontrado: $PROJECT_DIR"
  exit 1
fi

mkdir -p "$APP_DIR"

osascript -e "tell application \"System Events\" to set frontmost of process \"Finder\" to true" || true

osacompile -o "$APP_BUNDLE" <<APPLESCRIPT
do shell script "cd '$PROJECT_DIR' && npm start"
APPLESCRIPT

if [ -f "$ICON_SRC" ]; then
  cp "$ICON_SRC" "$APP_BUNDLE/Contents/Resources/applet.icns"
fi

if [ -x "/usr/libexec/PlistBuddy" ]; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleName $APP_NAME" "$APP_BUNDLE/Contents/Info.plist" || true
  /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $APP_NAME" "$APP_BUNDLE/Contents/Info.plist" || true
  /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.diagnucli.dev" "$APP_BUNDLE/Contents/Info.plist" || true
fi

echo "App criado em: $APP_BUNDLE"
