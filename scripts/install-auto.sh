#!/usr/bin/env bash
set -euo pipefail

say() { printf "%s\n" "$*"; }
section() {
  printf "\n== %s ==\n" "$1"
}

section "DiagnuCLI app installer"
say "This script updates and installs the DiagnuCLI app."

section "Step 1/1: DiagnuCLI app"
APP_REPO_PATH="${DIAGNUCLI_REPO_PATH:-$HOME/diagnucli}"
APP_REPO_URL="${DIAGNUCLI_REPO_URL:-https://github.com/Danilow88/Nucli-fix.git}"
if [[ ! -d "$APP_REPO_PATH/.git" ]]; then
  say "Cloning DiagnuCLI app repository..."
  git clone "$APP_REPO_URL" "$APP_REPO_PATH"
else
  say "Updating DiagnuCLI app repository..."
  git -C "$APP_REPO_PATH" pull
fi

if [[ ! -d "$APP_REPO_PATH/diagnucli-electron" ]]; then
  say "DiagnuCLI Electron folder not found at $APP_REPO_PATH/diagnucli-electron"
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  say "Node.js not found. Install Node 18+ and rerun this script."
  exit 1
fi

say "Installing dependencies..."
if [[ -f "$APP_REPO_PATH/diagnucli-electron/package-lock.json" ]]; then
  (cd "$APP_REPO_PATH/diagnucli-electron" && npm ci)
else
  (cd "$APP_REPO_PATH/diagnucli-electron" && npm install)
fi

say "Starting DiagnuCLI via npm start (background)..."
LOG_PATH="${DIAGNUCLI_NPM_LOG:-/tmp/diagnucli-npm-start.log}"
(cd "$APP_REPO_PATH/diagnucli-electron" && nohup npm start >"$LOG_PATH" 2>&1 & disown)
say "DiagnuCLI started. Logs: $LOG_PATH"

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
