#!/bin/bash
# Script protegido - código comprimido e codificado
# Este arquivo não pode ser facilmente lido em editores de texto

# Dados comprimidos e codificados (base64)
ENCODED_DATA="$(cat <<'ENDOFDATA'
ENDOFDATA
)"

# Adicionar os dados codificados aqui
ENCODED_DATA="${ENCODED_DATA}$(cat diagnucli.enc)"

# Função para decodificar e executar
decode_and_execute() {
    # Decodificar base64 e descomprimir
    eval "$(echo "$ENCODED_DATA" | base64 -d | gunzip)"
}

# Executar o script decodificado
decode_and_execute "$@"

