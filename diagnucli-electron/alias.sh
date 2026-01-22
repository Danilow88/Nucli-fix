#!/usr/bin/env bash
set -euo pipefail

ALIAS_LINE='alias diagnucli-app="open -a DiagnuCLI"'

add_alias() {
  local target="$1"
  if [[ ! -f "$target" ]]; then
    touch "$target"
  fi
  if ! grep -Fq "$ALIAS_LINE" "$target"; then
    printf "\n# DiagnuCLI\n%s\n" "$ALIAS_LINE" >> "$target"
    echo "Alias adicionado em $target"
  else
    echo "Alias ja existe em $target"
  fi
}

add_alias "$HOME/.zshrc"
add_alias "$HOME/.bashrc"
add_alias "$HOME/.bash_profile"

echo "Recarregue o shell: source ~/.zshrc ou abra um novo Terminal."
