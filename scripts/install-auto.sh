#!/usr/bin/env bash
set -euo pipefail
# Avoid commands consuming the script stdin when running via curl | bash.
exec </dev/null

say() { printf "%s\n" "$*"; }
section() {
  printf "\n== %s ==\n" "$1"
}

section "DiagnuCLI app installer"
say "This script updates and installs the DiagnuCLI app."

section "Step 0/2: simdjson"
ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi
  say "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

ensure_brew
say "Reinstalling simdjson..."
brew reinstall simdjson || brew install simdjson

section "Step 1/2: Node.js 18+"
needs_node_update() {
  if ! command -v node >/dev/null 2>&1; then
    return 0
  fi
  local major
  major="$(node -v | sed 's/^v//' | cut -d. -f1)"
  [[ "${major:-0}" -lt 18 ]]
}

if needs_node_update; then
  ensure_brew
  say "Installing/Updating Node.js 18+..."
  brew install node@18 || brew upgrade node@18
  brew link --force --overwrite node@18 >/dev/null 2>&1 || true
fi

if ! command -v node >/dev/null 2>&1; then
  say "Node.js not found after installation attempt. Install Node 18+ and rerun this script."
  exit 1
fi

section "Step 2/2: DiagnuCLI app"
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
