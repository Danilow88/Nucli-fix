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

if [[ -x "$APP_REPO_PATH/diagnucli-electron/install.sh" ]]; then
  say "Installing DiagnuCLI app..."
  (cd "$APP_REPO_PATH/diagnucli-electron" && ./install.sh)
  open -a "/Applications/DiagnuCLI.app" || true
else
  say "DiagnuCLI installer not found at $APP_REPO_PATH/diagnucli-electron/install.sh"
fi
