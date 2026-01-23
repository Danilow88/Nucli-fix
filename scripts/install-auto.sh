#!/usr/bin/env bash
set -euo pipefail

say() { printf "%s\n" "$*"; }
section() {
  printf "\n== %s ==\n" "$1"
}

section "NuCLI guided installer"
say "This script follows the internal tutorial steps."
say "It will open GitHub settings and install required tools."

section "Step 1/6: GitHub SSH key"
if [[ ! -f "$HOME/.ssh/id_ed25519.pub" ]]; then
  read -r -p "GitHub email: " github_email
  if [[ -n "${github_email:-}" ]]; then
    ssh-keygen -t ed25519 -C "$github_email"
  else
    say "No email provided. Skipping SSH key generation."
  fi
else
  say "SSH key already exists at ~/.ssh/id_ed25519.pub"
fi

eval "$(ssh-agent -s)" >/dev/null
ssh-add -k "$HOME/.ssh/id_ed25519" >/dev/null 2>&1 || true

if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
  pbcopy < "$HOME/.ssh/id_ed25519.pub" || true
  say "SSH public key copied to clipboard."
  say "Open GitHub to add the key and authorize SSO for Nubank."
  open "https://github.com/settings/keys" || true
  read -r -p "Press Enter after adding/authorizing the key..."
fi

section "Step 2/6: Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
  say "Xcode Command Line Tools already installed."
else
  say "Installing Xcode Command Line Tools..."
  xcode-select --install || true
  say "If a dialog opened, finish the installation and rerun this step if needed."
fi

section "Step 3/6: Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  say "Homebrew not found."
  say "Install with:"
  say '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  say "After installation, re-run this installer."
  exit 1
fi

section "Step 4/6: Packages"
brew install \
  coreutils \
  binutils \
  diffutils \
  ed \
  findutils \
  gawk \
  gnu-indent \
  gnu-sed \
  gnu-tar \
  gnu-which \
  gnutls \
  grep \
  gzip \
  screen \
  watch \
  wget \
  wdiff

brew install awscli jq node fzf clojure

section "Step 5/6: Configure NU_HOME and PATH"
shell_name="$(basename "${SHELL:-}")"
if [[ "$shell_name" == "bash" ]]; then
  profile="$HOME/.bash_profile"
else
  profile="$HOME/.zshrc"
fi

touch "$profile"

if ! grep -q "NU_HOME" "$profile"; then
  {
    echo ""
    echo "# NuCLI"
    echo "export NU_HOME=\"\$HOME/dev/nu\""
    echo "export PATH=\"\$NU_HOME/nucli/bin:\$PATH\""
  } >> "$profile"
  say "Added NU_HOME and PATH to $profile."
else
  say "NU_HOME already configured in $profile."
fi

section "Step 6/7: Clone repositories"
NU_HOME="${NU_HOME:-$HOME/dev/nu}"
mkdir -p "$NU_HOME"

if [[ ! -d "$NU_HOME/nucli/.git" ]]; then
  git clone git@github.com:nubank/nucli.git "$NU_HOME/nucli"
else
  say "NuCLI repo already exists. Pulling latest..."
  git -C "$NU_HOME/nucli" pull
fi

say ""
say "Next steps (run after reopening Terminal):"
say "  nu proj clone it-engineering"
say "  cd dev/nu/it-engineering/setup"
say "  ./setupnu.sh"
say ""
say "AWS setup (examples):"
say "  nu update"
say "  nu-ist auth get-refresh-token --env prod"
say "  nu aws credentials refresh"
say "  nu aws credentials setup"
say ""
say "Installer finished."

section "Step 7/7: DiagnuCLI app"
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
