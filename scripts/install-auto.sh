#!/bin/bash

# 🚀 Instalacao automatica do DiagnuCLI
# Este script clona o projeto, valida Node.js e inicia o app via npm start.

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     🟣 DiagnuCLI - Auto Installer        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

INSTALL_DIR="$HOME/dev/nu"
PROJECT_DIR="$INSTALL_DIR/Nucli-fix"
APP_DIR="$PROJECT_DIR/diagnucli-electron"

echo -e "${BLUE}[1/6]${NC} Verificando Git..."
if ! command -v git &> /dev/null; then
  echo -e "${RED}❌ Git nao encontrado!${NC}"
  echo -e "${YELLOW}Instale o Git primeiro:${NC}"
  echo "  brew install git"
  echo "  ou"
  echo "  xcode-select --install"
  exit 1
fi
echo -e "${GREEN}✅ Git instalado${NC}"

echo ""
echo -e "${BLUE}[2/6]${NC} Criando estrutura de diretorios..."
if [ ! -d "$INSTALL_DIR" ]; then
  mkdir -p "$INSTALL_DIR"
  echo -e "${GREEN}✅ Criado: $INSTALL_DIR${NC}"
else
  echo -e "${GREEN}✅ Diretorio ja existe: $INSTALL_DIR${NC}"
fi

echo ""
echo -e "${BLUE}[3/6]${NC} Verificando projeto existente..."
if [ -d "$PROJECT_DIR" ]; then
  echo -e "${YELLOW}⚠️  Projeto ja existe em: $PROJECT_DIR${NC}"
  echo -e "${YELLOW}Deseja atualizar (git pull)? [s/N]${NC}"
  read -r response
  if [[ "$response" =~ ^([sS][iI][mM]|[sS])$ ]]; then
    cd "$PROJECT_DIR"
    git pull
    echo -e "${GREEN}✅ Projeto atualizado${NC}"
  else
    echo -e "${YELLOW}⏭️  Pulando atualizacao${NC}"
  fi
else
  echo -e "${BLUE}[4/6]${NC} Clonando repositorio..."
  cd "$INSTALL_DIR"
  echo -e "${YELLOW}Escolha o metodo de clonagem:${NC}"
  echo "  1) HTTPS - https://github.com/Danilow88/Nucli-fix"
  echo "  2) SSH   - git@github.com:Danilow88/Nucli-fix.git"
  read -p "Opcao [1/2]: " clone_method

  if [ "$clone_method" = "2" ]; then
    git clone git@github.com:Danilow88/Nucli-fix.git
  else
    git clone https://github.com/Danilow88/Nucli-fix
  fi
  echo -e "${GREEN}✅ Repositorio clonado${NC}"
fi

echo ""
echo -e "${BLUE}[5/6]${NC} Verificando Node.js..."
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if ! command -v node &> /dev/null; then
  echo -e "${RED}❌ Node.js nao encontrado!${NC}"
  echo -e "${YELLOW}Instale Node.js 20+ e tente novamente.${NC}"
  exit 1
fi

NODE_VERSION=$(node --version)
NODE_MAJOR_VERSION=$(echo "$NODE_VERSION" | cut -d'.' -f1 | sed 's/v//')
echo -e "${GREEN}✅ Node.js instalado: $NODE_VERSION${NC}"
if [ "$NODE_MAJOR_VERSION" -lt 20 ]; then
  echo -e "${RED}❌ Node.js v20+ e necessario!${NC}"
  exit 1
fi

echo ""
echo -e "${BLUE}[6/6]${NC} Instalando dependencias..."
cd "$APP_DIR"
if [ -d "node_modules" ]; then
  echo -e "${YELLOW}⚠️  node_modules ja existe${NC}"
  echo -e "${YELLOW}Deseja reinstalar? [s/N]${NC}"
  read -r response
  if [[ "$response" =~ ^([sS][iI][mM]|[sS])$ ]]; then
    rm -rf node_modules package-lock.json
    npm install --omit=dev
    echo -e "${GREEN}✅ Dependencias reinstaladas${NC}"
  else
    echo -e "${YELLOW}⏭️  Pulando instalacao de dependencias${NC}"
  fi
else
  npm install --omit=dev
  echo -e "${GREEN}✅ Dependencias instaladas${NC}"
fi

echo ""
echo -e "${BLUE}Criando atalho dev (nome + icone DiagnuCLI)...${NC}"
if [ -x "$PROJECT_DIR/scripts/create-dev-app.sh" ]; then
  "$PROJECT_DIR/scripts/create-dev-app.sh" || true
else
  echo -e "${YELLOW}⚠️  create-dev-app.sh nao encontrado${NC}"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅ Instalacao concluida com sucesso!  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}🚀 Para iniciar:${NC}"
echo -e "   ${YELLOW}$PROJECT_DIR/scripts/start.sh${NC}"
echo ""
echo -e "${YELLOW}Deseja iniciar agora? [s/N]${NC}"
read -r response
if [[ "$response" =~ ^([sS][iI][mM]|[sS])$ ]]; then
  "$PROJECT_DIR/scripts/start.sh"
fi
