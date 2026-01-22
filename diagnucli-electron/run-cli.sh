#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js nao encontrado. Instale o Node 18+ e tente novamente."
  exit 1
fi

cd "$PROJECT_DIR"

if [[ ! -d "node_modules" ]]; then
  echo "Dependencias nao encontradas. Instalando (sem devDependencies)..."
  npm install --omit=dev
fi

echo "Iniciando DiagnuCLI via CLI (sem app bundle)..."
npm start
