#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js nao encontrado. Instale o Node 18+ e tente novamente."
  exit 1
fi

cd "$PROJECT_DIR"

if [[ ! -d "node_modules" ]]; then
  echo "Dependencias nao encontradas. Instalando..."
  npm install
fi

echo "Iniciando DiagnuCLI via CLI (sem app bundle)..."
LOG_PATH="${DIAGNUCLI_CLI_LOG:-/tmp/diagnucli-electron.log}"
nohup npx electron . >"$LOG_PATH" 2>&1 &
disown
echo "DiagnuCLI iniciado em background. Logs: $LOG_PATH"
