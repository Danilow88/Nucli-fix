#!/usr/bin/env bash
set -euo pipefail

say() { printf "%s\n" "$*"; }
section() {
  printf "\n== %s ==\n" "$1"
}

section "DiagnuCLI app installer"
say "This script updates and installs the DiagnuCLI app."

section "Step 1/1: DiagnuCLI app"
APP_REPO_PATH="${DIAGNUCLI_REPO_PATH:-$HOME/Nucli-fix}"
if [[ ! -d "$APP_REPO_PATH/.git" ]]; then
  say "Cloning DiagnuCLI app repository..."
  git clone https://github.com/Danilow88/Nucli-fix.git "$APP_REPO_PATH"
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
