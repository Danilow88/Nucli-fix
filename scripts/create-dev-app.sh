#!/bin/bash

set -e

APP_NAME="DiagnuCLI"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$PROJECT_DIR/diagnucli-electron"
ICON_SRC="$APP_DIR/assets/icon.icns"
APP_TARGET="$HOME/Applications/${APP_NAME}-Dev.app"

if ! command -v osacompile >/dev/null 2>&1; then
  echo "osacompile nao encontrado. Instale o Xcode Command Line Tools."
  echo "Execute: xcode-select --install"
  exit 1
fi

mkdir -p "$HOME/Applications"

osascript_tmp="$(mktemp)"
/usr/bin/python3 - <<PY
import pathlib

app_dir = r"""$APP_DIR"""
script = f"""set appDir to "{app_dir}"
set cmd to "cd " & quoted form of appDir & " && npm start"
do shell script "/bin/zsh -lc " & quoted form of cmd
"""

path = pathlib.Path(r"""$osascript_tmp""")
path.write_text(script, encoding="utf-8")
PY

osacompile -o "$APP_TARGET" "$osascript_tmp"
rm -f "$osascript_tmp"

INFO_PLIST="$APP_TARGET/Contents/Info.plist"
RESOURCES_DIR="$APP_TARGET/Contents/Resources"

/usr/libexec/PlistBuddy -c "Set :CFBundleName $APP_NAME" "$INFO_PLIST" || true
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $APP_NAME" "$INFO_PLIST" || true
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.diagnucli.dev" "$INFO_PLIST" || true

if [[ -f "$ICON_SRC" ]]; then
  cp "$ICON_SRC" "$RESOURCES_DIR/DiagnuCLI.icns"
  /usr/libexec/PlistBuddy -c "Set :CFBundleIconFile DiagnuCLI.icns" "$INFO_PLIST" || true
fi

echo "Atalho dev criado em: $APP_TARGET"
