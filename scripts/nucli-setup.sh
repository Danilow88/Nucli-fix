#!/usr/bin/env bash
set -euo pipefail

say() { printf "%s\n" "$*"; }
section() { printf "\n== %s ==\n" "$1"; }
pause() { read -r -p "Press Enter to continue..."; }

section "NuCLI onboarding guide"
say "This script follows the official onboarding steps."
say "It will open links and run the required commands when possible."

section "1) Activate GitHub 2FA"
say "Open GitHub settings to enable 2FA (Authenticator app recommended)."
open "https://github.com/settings/security" || true
pause

section "2) Request access to Nubank org + NuCLI groups"
say "Request access to Nubank org and NuCLI repo groups using the internal forms."
say "If you don't have access, open a ticket with IT Eng."
open "https://nubank.atlassian.net/servicedesk/customer/portal/131" || true
pause

section "3) Create and register SSH key"
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
  say "Add the key in GitHub and authorize SSO for Nubank."
  open "https://github.com/settings/keys" || true
  pause
fi

section "4) Request AWS access and groups"
say "Request AWS access and required groups in the IT Eng portal."
open "https://nubank.atlassian.net/servicedesk/customer/portal/131" || true
pause

section "5) Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
  say "Xcode Command Line Tools already installed."
else
  say "Installing Xcode Command Line Tools..."
  xcode-select --install || true
  say "If a dialog opened, finish the installation and rerun this step if needed."
fi

section "6) Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  say "Homebrew not found."
  say "Install with:"
  say '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  say "After installation, re-run this installer."
  exit 1
fi

section "7) Packages"
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

section "8) Configure NU_HOME and PATH"
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

section "9) Clone NuCLI + IT Engineering setup"
NU_HOME="${NU_HOME:-$HOME/dev/nu}"
mkdir -p "$NU_HOME"

if [[ ! -d "$NU_HOME/nucli/.git" ]]; then
  git clone git@github.com:nubank/nucli.git "$NU_HOME/nucli"
else
  say "NuCLI repo already exists. Pulling latest..."
  git -C "$NU_HOME/nucli" pull
fi

say ""
say "Run next (after reopening Terminal):"
say "  nu proj clone it-engineering"
say "  cd dev/nu/it-engineering/setup"
say "  ./setupnu.sh"
pause

section "10) Configure AWS credentials"
say "If you don't have a YubiKey, set up Touch ID:"
say "  brew install gimme-aws-creds"
say "  nu update"
say "  gsed -i 's/^[^#]*preferred_mfa_type/#&/' ~/.okta_aws_login_config"
say "  nu aws okta-aws-creds --setup-fido-authenticator"
say ""
say "Then run:"
say "  nu update"
say "  echo \"firstname.lastname\" > ~/dev/nu/.nu/about/me/iam_user"
say "  nu-ist auth get-refresh-token --env prod"
say "  nu aws credentials refresh"
say "  nu aws credentials setup"
say ""
say "MX: nu-mx aws credentials setup"
say "CO: nu-co aws credentials setup"

say ""
say "Setup finished."
