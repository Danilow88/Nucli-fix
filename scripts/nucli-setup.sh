#!/usr/bin/env bash
set -euo pipefail

say() { printf "%s\n" "$*"; }
section() { printf "\n== %s ==\n" "$1"; }
pause() { read -r -p "Press Enter to continue..."; }

LANG_UI="${LANG_UI:-pt}"

tr() {
  local key="$1"
  case "$LANG_UI" in
    es)
      case "$key" in
        title) echo "Guia de incorporación NuCLI" ;;
        intro) echo "Este script sigue los pasos oficiales de incorporación." ;;
        intro2) echo "Abrirá enlaces y ejecutará comandos cuando sea posible." ;;
        press_enter) echo "Presione Enter para continuar..." ;;
        step1) echo "1) Activar 2FA en GitHub" ;;
        step1_desc) echo "Abra la configuración de GitHub para activar 2FA (app autenticadora recomendada)." ;;
        step2) echo "2) Solicitar acceso a la org Nubank + grupos NuCLI" ;;
        step2_desc) echo "Solicite acceso a la org de Nubank y a los grupos del repo NuCLI." ;;
        step2_desc2) echo "Si no tiene acceso, abra un ticket con IT Eng." ;;
        step3) echo "3) Crear y registrar clave SSH" ;;
        step3_email) echo "Email de GitHub: " ;;
        step3_skip) echo "Sin email. Se omite la generación de SSH." ;;
        step3_exists) echo "La clave SSH ya existe en ~/.ssh/id_ed25519.pub" ;;
        step3_copied) echo "Clave pública copiada al portapapeles." ;;
        step3_add) echo "Agregue la clave en GitHub y autorice SSO para Nubank." ;;
        step4) echo "4) Solicitar acceso AWS y grupos" ;;
        step4_desc) echo "Solicite acceso AWS y los grupos requeridos en el portal IT Eng." ;;
        step5) echo "5) Xcode Command Line Tools" ;;
        step5_installed) echo "Xcode Command Line Tools ya instalado." ;;
        step5_install) echo "Instalando Xcode Command Line Tools..." ;;
        step5_hint) echo "Si se abre un diálogo, finalice la instalación y repita este paso si es necesario." ;;
        step6) echo "6) Homebrew" ;;
        step6_missing) echo "Homebrew no encontrado." ;;
        step6_install) echo "Instale con:" ;;
        step6_retry) echo "Después de instalar, ejecute este instalador nuevamente." ;;
        step7) echo "7) Paquetes" ;;
        step8) echo "8) Configurar NU_HOME y PATH" ;;
        step8_added) echo "Agregado NU_HOME y PATH en" ;;
        step8_exists) echo "NU_HOME ya está configurado en" ;;
        step9) echo "9) Clonar NuCLI + setup IT Engineering" ;;
        step9_next) echo "Ejecute lo siguiente (después de reabrir el Terminal):" ;;
        step10) echo "10) Configurar credenciales AWS" ;;
        step10_no_key) echo "Si no tiene YubiKey, configure Touch ID:" ;;
        step10_then) echo "Luego ejecute:" ;;
        step10_mx) echo "MX: nu-mx aws credentials setup" ;;
        step10_co) echo "CO: nu-co aws credentials setup" ;;
        done) echo "Configuración finalizada. De vuelta en la app, haga clic en el botón 'Cadastrar digital'." ;;
        guide_link_label) echo "Guía:" ;;
        asknu) echo "Para escopos/permisos, solicite via Ask Nu en Slack." ;;
        ist_admin) echo "Para configurar NuCLI en la cuenta IST, solicite el scope Admin." ;;
        *) echo "$key" ;;
      esac
      ;;
    en)
      case "$key" in
        title) echo "NuCLI onboarding guide" ;;
        intro) echo "This script follows the official onboarding steps." ;;
        intro2) echo "It will open links and run the required commands when possible." ;;
        press_enter) echo "Press Enter to continue..." ;;
        step1) echo "1) Activate GitHub 2FA" ;;
        step1_desc) echo "Open GitHub settings to enable 2FA (Authenticator app recommended)." ;;
        step2) echo "2) Request access to Nubank org + NuCLI groups" ;;
        step2_desc) echo "Request access to the Nubank org and NuCLI repo groups." ;;
        step2_desc2) echo "If you don't have access, open a ticket with IT Eng." ;;
        step3) echo "3) Create and register SSH key" ;;
        step3_email) echo "GitHub email: " ;;
        step3_skip) echo "No email provided. Skipping SSH key generation." ;;
        step3_exists) echo "SSH key already exists at ~/.ssh/id_ed25519.pub" ;;
        step3_copied) echo "SSH public key copied to clipboard." ;;
        step3_add) echo "Add the key in GitHub and authorize SSO for Nubank." ;;
        step4) echo "4) Request AWS access and groups" ;;
        step4_desc) echo "Request AWS access and required groups in the IT Eng portal." ;;
        step5) echo "5) Xcode Command Line Tools" ;;
        step5_installed) echo "Xcode Command Line Tools already installed." ;;
        step5_install) echo "Installing Xcode Command Line Tools..." ;;
        step5_hint) echo "If a dialog opened, finish the installation and rerun this step if needed." ;;
        step6) echo "6) Homebrew" ;;
        step6_missing) echo "Homebrew not found." ;;
        step6_install) echo "Install with:" ;;
        step6_retry) echo "After installation, re-run this installer." ;;
        step7) echo "7) Packages" ;;
        step8) echo "8) Configure NU_HOME and PATH" ;;
        step8_added) echo "Added NU_HOME and PATH to" ;;
        step8_exists) echo "NU_HOME already configured in" ;;
        step9) echo "9) Clone NuCLI + IT Engineering setup" ;;
        step9_next) echo "Run next (after reopening Terminal):" ;;
        step10) echo "10) Configure AWS credentials" ;;
        step10_no_key) echo "If you don't have a YubiKey, set up Touch ID:" ;;
        step10_then) echo "Then run:" ;;
        step10_mx) echo "MX: nu-mx aws credentials setup" ;;
        step10_co) echo "CO: nu-co aws credentials setup" ;;
        done) echo "Setup finished. Back in the app, click the 'Cadastrar digital' button." ;;
        guide_link_label) echo "Guide:" ;;
        asknu) echo "For scopes/permissions, request via Ask Nu on Slack." ;;
        ist_admin) echo "For NuCLI setup in IST account, request Admin scope." ;;
        *) echo "$key" ;;
      esac
      ;;
    *)
      case "$key" in
        title) echo "Guia de onboarding NuCLI" ;;
        intro) echo "Este script segue os passos oficiais de onboarding." ;;
        intro2) echo "Ele vai abrir links e executar comandos quando possível." ;;
        press_enter) echo "Pressione Enter para continuar..." ;;
        step1) echo "1) Ativar 2FA no GitHub" ;;
        step1_desc) echo "Abra as configurações do GitHub para habilitar 2FA (app autenticador recomendado)." ;;
        step2) echo "2) Solicitar acesso à org Nubank + grupos NuCLI" ;;
        step2_desc) echo "Solicite acesso à org da Nubank e aos grupos do repo NuCLI." ;;
        step2_desc2) echo "Se não tiver acesso, abra um ticket com IT Eng." ;;
        step3) echo "3) Criar e registrar chave SSH" ;;
        step3_email) echo "Email do GitHub: " ;;
        step3_skip) echo "Sem email. Pulando geração de SSH." ;;
        step3_exists) echo "Chave SSH já existe em ~/.ssh/id_ed25519.pub" ;;
        step3_copied) echo "Chave pública copiada para a área de transferência." ;;
        step3_add) echo "Adicione a chave no GitHub e autorize o SSO para Nubank." ;;
        step4) echo "4) Solicitar acesso AWS e grupos" ;;
        step4_desc) echo "Solicite acesso AWS e grupos necessários no portal do IT Eng." ;;
        step5) echo "5) Xcode Command Line Tools" ;;
        step5_installed) echo "Xcode Command Line Tools já instalado." ;;
        step5_install) echo "Instalando Xcode Command Line Tools..." ;;
        step5_hint) echo "Se abrir um diálogo, finalize a instalação e refaça este passo se necessário." ;;
        step6) echo "6) Homebrew" ;;
        step6_missing) echo "Homebrew não encontrado." ;;
        step6_install) echo "Instale com:" ;;
        step6_retry) echo "Depois de instalar, rode este instalador novamente." ;;
        step7) echo "7) Pacotes" ;;
        step8) echo "8) Configurar NU_HOME e PATH" ;;
        step8_added) echo "Adicionado NU_HOME e PATH em" ;;
        step8_exists) echo "NU_HOME já configurado em" ;;
        step9) echo "9) Clonar NuCLI + setup IT Engineering" ;;
        step9_next) echo "Execute a seguir (depois de reabrir o Terminal):" ;;
        step10) echo "10) Configurar credenciais AWS" ;;
        step10_no_key) echo "Se não tiver YubiKey, configure Touch ID:" ;;
        step10_then) echo "Depois execute:" ;;
        step10_mx) echo "MX: nu-mx aws credentials setup" ;;
        step10_co) echo "CO: nu-co aws credentials setup" ;;
        done) echo "Setup finalizado. De volta ao app, clique no botão 'Cadastrar digital'." ;;
        guide_link_label) echo "Guia:" ;;
        asknu) echo "Para escopos/permissões, solicite via Ask Nu no Slack." ;;
        ist_admin) echo "Para configurar NuCLI na conta IST, solicite o escopo Admin." ;;
        *) echo "$key" ;;
      esac
      ;;
  esac
}

pause() { read -r -p "$(tr press_enter)"; }

section "$(tr title)"
say "$(tr intro)"
say "$(tr intro2)"
say "$(tr guide_link_label) https://nubank.atlassian.net/wiki/spaces/ITKB/pages/262490555235/How+to+Configure+NuCli+on+MacBook"

section "$(tr step1)"
say "$(tr step1_desc)"
open "https://github.com/settings/security" || true
pause

section "$(tr step2)"
say "$(tr step2_desc)"
say "$(tr step2_desc2)"
say "$(tr asknu)"
say "$(tr ist_admin)"
open "https://nubank.atlassian.net/servicedesk/customer/portal/131" || true
pause

section "$(tr step3)"
if [[ ! -f "$HOME/.ssh/id_ed25519.pub" ]]; then
  read -r -p "$(tr step3_email)" github_email
  if [[ -n "${github_email:-}" ]]; then
    ssh-keygen -t ed25519 -C "$github_email"
  else
    say "$(tr step3_skip)"
  fi
else
  say "$(tr step3_exists)"
fi

eval "$(ssh-agent -s)" >/dev/null
ssh-add -k "$HOME/.ssh/id_ed25519" >/dev/null 2>&1 || true

if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
  pbcopy < "$HOME/.ssh/id_ed25519.pub" || true
  say "$(tr step3_copied)"
  say "$(tr step3_add)"
  open "https://github.com/settings/keys" || true
  pause
fi

section "$(tr step4)"
say "$(tr step4_desc)"
open "https://nubank.atlassian.net/servicedesk/customer/portal/131" || true
pause

section "$(tr step5)"
if xcode-select -p >/dev/null 2>&1; then
  say "$(tr step5_installed)"
else
  say "$(tr step5_install)"
  xcode-select --install || true
  say "$(tr step5_hint)"
fi

section "$(tr step6)"
if ! command -v brew >/dev/null 2>&1; then
  say "$(tr step6_missing)"
  say "$(tr step6_install)"
  say '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  say "$(tr step6_retry)"
  exit 1
fi

section "$(tr step7)"
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

section "$(tr step8)"
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
  say "$(tr step8_added) $profile."
else
  say "$(tr step8_exists) $profile."
fi

section "8.1) Exportar variaveis antes do clone"
echo "$SHELL"
echo "export NU_HOME='\${HOME}/dev/nu'" >> "$HOME/.zshrc"
echo "export NUCLI_HOME='\${NU_HOME}/nucli'" >> "$HOME/.zshrc"
echo "export PATH='\${NUCLI_HOME}:\${PATH}'" >> "$HOME/.zshrc"

section "$(tr step9)"
NU_HOME="${NU_HOME:-$HOME/dev/nu}"
mkdir -p "$NU_HOME"

if [[ ! -d "$NU_HOME/nucli/.git" ]]; then
  git clone git@github.com:nubank/nucli.git "$NU_HOME/nucli"
else
  say "NuCLI repo already exists. Pulling latest..."
  git -C "$NU_HOME/nucli" pull
fi

say ""
say "Instalando Temurin (Java)..."
brew install --cask temurin

say ""
say "$(tr step9_next)"
say "  nu proj clone it-engineering"
say "  cd dev/nu/it-engineering/setup"
say "  ./setupnu.sh"
pause

section "$(tr step10)"
say "$(tr step10_no_key)"
say "  brew install gimme-aws-creds"
say "  nu update"
say "  gsed -i 's/^[^#]*preferred_mfa_type/#&/' ~/.okta_aws_login_config"
say "  # Autentique com Google Authenticator ou Okta Verify somente neste passo"
say "  # Depois, para qualquer autenticacao, escolha o metodo webauth/webauth"
say "  nu aws okta-aws-creds --setup-fido-authenticator"
say ""
say "$(tr step10_then)"
say "  nu update"
say "  echo \"firstname.lastname\" > ~/dev/nu/.nu/about/me/iam_user"
say "  nu-ist auth get-refresh-token --env prod"
say "  nu aws credentials refresh"
say "  nu aws credentials setup"
say ""
say "$(tr step10_mx)"
say "$(tr step10_co)"

say ""
say "$(tr done)"