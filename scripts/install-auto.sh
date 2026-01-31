#!/usr/bin/env bash
set -euo pipefail

say() { printf "%s\n" "$*"; }
section() {
  printf "\n== %s ==\n" "$1"
}

section "DiagnuCLI app installer"
say "This script updates the repo and installs the DiagnuCLI app."

section "Step 1/1: DiagnuCLI app"
DEFAULT_REPO_PATH="$HOME/Nucli-fix"
LEGACY_REPO_PATH="$HOME/diagnucli"
if [[ -n "${DIAGNUCLI_REPO_PATH:-}" ]]; then
  APP_REPO_PATH="$DIAGNUCLI_REPO_PATH"
elif [[ -d "$DEFAULT_REPO_PATH/.git" ]]; then
  APP_REPO_PATH="$DEFAULT_REPO_PATH"
elif [[ -d "$LEGACY_REPO_PATH/.git" ]]; then
  APP_REPO_PATH="$LEGACY_REPO_PATH"
else
  APP_REPO_PATH="$DEFAULT_REPO_PATH"
fi
APP_REPO_URL="${DIAGNUCLI_REPO_URL:-https://github.com/Danilow88/Nucli-fix.git}"
if [[ ! -d "$APP_REPO_PATH/.git" ]]; then
  say "Cloning DiagnuCLI app repository..."
  git clone "$APP_REPO_URL" "$APP_REPO_PATH"
else
  say "Updating DiagnuCLI app repository..."
  if git -C "$APP_REPO_PATH" remote get-url origin >/dev/null 2>&1; then
    git -C "$APP_REPO_PATH" remote set-url origin "$APP_REPO_URL"
  else
    git -C "$APP_REPO_PATH" remote add origin "$APP_REPO_URL"
  fi
  git -C "$APP_REPO_PATH" pull
fi

if [[ ! -d "$APP_REPO_PATH/diagnucli-electron" ]]; then
  say "DiagnuCLI Electron folder not found at $APP_REPO_PATH/diagnucli-electron"
  exit 1
fi

say "Running installer..."
INSTALL_SCRIPT="$APP_REPO_PATH/diagnucli-electron/install.sh"
if [[ ! -f "$INSTALL_SCRIPT" ]]; then
  say "Installer not found at $INSTALL_SCRIPT"
  exit 1
fi

/bin/bash "$INSTALL_SCRIPT"
say "Opening DiagnuCLI..."
open -a "DiagnuCLI" || open "/Applications/DiagnuCLI.app" || true

# Close the Terminal window that ran the curl|bash command (no prompt)
osascript -e 'tell application "Terminal" to close front window' >/dev/null 2>&1 || true
sleep 0.2
osascript -e 'tell application "System Events" to tell process "Terminal"' \
  -e 'if exists sheet 1 of window 1 then' \
  -e 'try' \
  -e 'click button "Close" of sheet 1 of window 1' \
  -e 'end try' \
  -e 'try' \
  -e 'click button "Fechar" of sheet 1 of window 1' \
  -e 'end try' \
  -e 'try' \
  -e 'click button "Finalizar" of sheet 1 of window 1' \
  -e 'end try' \
  -e 'try' \
  -e 'click button "Terminate" of sheet 1 of window 1' \
  -e 'end try' \
  -e 'end if' >/dev/null 2>&1 || true
