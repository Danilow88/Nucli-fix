#!/bin/bash

# Script de Troubleshooting para NuCLI e AWS
# Versão detalhada que mostra comandos e suas finalidades
# Executa correções automáticas quando problemas são detectados
# Baseado no documento de troubleshooting NuCLI and AWS Errors

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Arrays para armazenar resultados dos comandos executados
declare -a COMMAND_SUCCESS=()
declare -a COMMAND_FAILED=()
declare -a COMMAND_NEEDS_ACTION=()
declare -a COMMAND_TO_RETRY=()  # Comandos que falharam e devem ser reexecutados

# Arrays associativos para armazenar roles e policies por país
# Usando variáveis com prefixos para compatibilidade com bash 3.2
# Formato: USER_ROLES_<country> e USER_POLICIES_<country>

# Funções auxiliares para gerenciar roles e policies (compatibilidade bash 3.2)
set_user_role() {
    local country="$1"
    local value="$2"
    eval "USER_ROLES_${country}=\"$value\""
}

get_user_role() {
    local country="$1"
    eval "echo \${USER_ROLES_${country}:-}"
}

set_user_policy() {
    local country="$1"
    local value="$2"
    eval "USER_POLICIES_${country}=\"$value\""
}

get_user_policy() {
    local country="$1"
    eval "echo \${USER_POLICIES_${country}:-}"
}

set_user_role_full() {
    local country="$1"
    local value="$2"
    eval "USER_ROLES_${country}_full=\"$value\""
}

get_user_role_full() {
    local country="$1"
    eval "echo \${USER_ROLES_${country}_full:-}"
}

# Configuração de modo interativo (padrão: habilitado)
export TRY_INTERACTIVE="${TRY_INTERACTIVE:-true}"

# Função para imprimir cabeçalho
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Função para imprimir sucesso
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Função para imprimir erro
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Função para imprimir aviso
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Função para imprimir informação
print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Função para mostrar comando antes de executar
print_command() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}📋 COMANDO:${NC} ${YELLOW}$1${NC}"
    echo -e "${MAGENTA}🎯 FINALIDADE:${NC} $2"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Funções para registrar resultados dos comandos
register_command_success() {
    local cmd="$1"
    local output="${2:-}"
    COMMAND_SUCCESS+=("$cmd|$output")
}

register_command_failed() {
    local cmd="$1"
    local reason="${2:-}"
    COMMAND_FAILED+=("$cmd|$reason")
}

register_command_needs_action() {
    local cmd="$1"
    local reason="${2:-}"
    COMMAND_NEEDS_ACTION+=("$cmd|$reason")
}

# Função para executar comando e mostrar resultado
execute_command() {
    local cmd="$1"
    local purpose="$2"
    local show_output="${3:-true}"
    local auto_retry="${4:-true}"  # Por padrão, tenta reexecutar se falhar
    
    print_command "$cmd" "$purpose"
    
    if [ "$show_output" = "true" ]; then
        echo -e "${BLUE}📤 Executando...${NC}"
        eval "$cmd"
        local exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            echo -e "${GREEN}✓ Comando executado com sucesso (código: $exit_code)${NC}"
            register_command_success "$cmd" "Executado com sucesso"
        else
            echo -e "${RED}✗ Comando falhou (código: $exit_code)${NC}"
            register_command_failed "$cmd" "Código de saída: $exit_code"
            
            # Se auto_retry estiver habilitado, adicionar à lista de comandos para reexecutar
            if [ "$auto_retry" = "true" ]; then
                COMMAND_TO_RETRY+=("$cmd|$purpose")
            fi
        fi
        return $exit_code
    else
        eval "$cmd" &> /dev/null
        local exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            echo -e "${GREEN}✓ Comando executado com sucesso (código: $exit_code)${NC}"
            register_command_success "$cmd" "Executado com sucesso"
        else
            echo -e "${RED}✗ Comando falhou (código: $exit_code)${NC}"
            register_command_failed "$cmd" "Código de saída: $exit_code"
            
            # Se auto_retry estiver habilitado, adicionar à lista de comandos para reexecutar
            if [ "$auto_retry" = "true" ]; then
                COMMAND_TO_RETRY+=("$cmd|$purpose")
            fi
        fi
        return $exit_code
    fi
}

# Função para reexecutar comandos que falharam automaticamente
retry_failed_commands() {
    if [ ${#COMMAND_TO_RETRY[@]} -eq 0 ]; then
        return 0
    fi
    
    print_header "Reexecutando Comandos que Falharam Automaticamente"
    
    local retry_count=0
    local success_count=0
    
    for item in "${COMMAND_TO_RETRY[@]}"; do
        local cmd=$(echo "$item" | cut -d'|' -f1)
        local purpose=$(echo "$item" | cut -d'|' -f2-)
        
        ((retry_count++))
        echo ""
        print_info "Tentativa $retry_count de ${#COMMAND_TO_RETRY[@]}: $cmd"
        
        # Tentar executar novamente
        print_command "$cmd" "$purpose (tentativa automática de reexecução)"
        echo -e "${BLUE}📤 Reexecutando...${NC}"
        
        eval "$cmd" 2>&1
        local exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            echo -e "${GREEN}✓ Comando reexecutado com sucesso${NC}"
            register_command_success "$cmd" "Reexecutado com sucesso após falha inicial"
            ((success_count++))
            
            # Remover da lista de falhas
            COMMAND_FAILED=("${COMMAND_FAILED[@]/$cmd|*/}")
        else
            echo -e "${YELLOW}⚠ Comando ainda falhou após reexecução (código: $exit_code)${NC}"
            print_info "Este comando pode precisar de intervenção manual ou configuração adicional"
        fi
        
        echo ""
        sleep 1  # Pequena pausa entre tentativas
    done
    
    echo ""
    if [ $success_count -gt 0 ]; then
        print_success "$success_count de $retry_count comando(s) reexecutado(s) com sucesso"
    else
        print_warning "Nenhum comando foi reexecutado com sucesso automaticamente"
        print_info "Verifique os erros acima e execute manualmente se necessário"
    fi
    
    # Limpar array de comandos para reexecutar
    COMMAND_TO_RETRY=()
}

# Função para executar comandos interativos permitindo interação do usuário
execute_interactive_user_command() {
    local cmd="$1"
    local purpose="$2"
    
    print_command "$cmd" "$purpose (modo interativo - aguardando interação do usuário)"
    echo ""
    print_info "Este comando requer interação manual. Você poderá interagir diretamente."
    echo ""
    print_warning "Pressione Ctrl+C para cancelar se necessário."
    echo ""
    
    # Executar o comando permitindo interação completa do usuário (sem pedir confirmação)
    eval "$cmd"
    local exit_code=$?
    
    echo ""
    if [ $exit_code -eq 0 ]; then
        print_success "Comando interativo executado com sucesso"
        register_command_success "$cmd" "Executado com interação do usuário"
    else
        print_error "Comando interativo retornou código: $exit_code"
        register_command_failed "$cmd" "Código de saída: $exit_code (após interação do usuário)"
    fi
    
    return $exit_code
}

# Verificar e instalar Java se necessário
check_and_install_java() {
    print_header "Verificando instalação do Java"
    
    print_info "Verificando se o Java está instalado no sistema..."
    
    execute_command "command -v java" \
        "Verifica se o comando 'java' está instalado e disponível no PATH do sistema" \
        "false"
    
    if [ $? -eq 0 ]; then
        print_success "Java está instalado"
        register_command_success "command -v java" "Java encontrado no PATH"
        
        execute_command "java -version" \
            "Obtém a versão do Java instalado" \
            "true"
        
        local java_version=$(java -version 2>&1 | head -1)
        register_command_success "java -version" "$java_version"
        print_info "Versão: $java_version"
        return 0
    else
        print_warning "Java não está instalado"
        register_command_needs_action "java" "Java não encontrado - será instalado automaticamente"
        print_info "Instalando Java (Temurin) via Homebrew..."
        echo ""
        
        # Verificar se Homebrew está instalado
        execute_command "command -v brew" \
            "Verifica se o Homebrew está instalado (necessário para instalar Java)" \
            "false"
        
        if [ $? -ne 0 ]; then
            print_error "Homebrew não está instalado. Não é possível instalar Java automaticamente."
            register_command_failed "brew" "Homebrew não encontrado"
            print_info "Instale o Homebrew primeiro: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            return 1
        fi
        
        register_command_success "command -v brew" "Homebrew encontrado"
        
        # Instalar Java via Homebrew
        execute_command "brew install --cask temurin" \
            "Instala o Java (Temurin) via Homebrew Cask" \
            "true"
        
        local install_exit=$?
        if [ $install_exit -eq 0 ]; then
            print_success "Java instalado com sucesso!"
            register_command_success "brew install --cask temurin" "Java instalado com sucesso"
            print_info "Reinicie o terminal ou execute: source ~/.zshrc (ou ~/.bashrc)"
            return 0
        else
            print_error "Falha ao instalar Java"
            register_command_failed "brew install --cask temurin" "Código de saída: $install_exit"
            print_info "Tente instalar manualmente: brew install --cask temurin"
            return 1
        fi
    fi
}

# Função de verificação completa (inclui todas as verificações)
check_complete_verification() {
    print_header "Verificação Completa do Sistema"
    
    # Limpar arrays de resultados antes de começar
    COMMAND_SUCCESS=()
    COMMAND_FAILED=()
    COMMAND_NEEDS_ACTION=()
    COMMAND_TO_RETRY=()
    
    # 1. Verificar e instalar Java se necessário (primeiro passo)
    echo ""
    check_and_install_java
    
    # 2. Verificar instalação do NuCLI
    echo ""
    check_nucli_installation
    
    # 3. Verificar configuração do AWS
    echo ""
    check_aws_config
    
    # 4. Verificar conectividade de rede
    echo ""
    check_network_connectivity
    
    # 5. Verificar variáveis de ambiente
    echo ""
    check_environment_variables
    
    # 6. Verificar permissões de arquivos
    echo ""
    check_file_permissions
    
    # 7. Testar comandos NuCLI
    echo ""
    test_nucli_commands
    
    # 8. Testar comandos AWS
    echo ""
    test_aws_commands
    
    # 9. Verificar roles, escopos e países
    echo ""
    check_roles_scopes_countries
    
    # 10. Diagnóstico de problemas comuns
    echo ""
    diagnose_common_issues
    
    # 11. Reexecutar comandos que falharam automaticamente
    echo ""
    retry_failed_commands
    
    # 12. Coletar roles e policies do usuário antes de gerar relatório
    echo ""
    collect_user_roles_and_policies
    
    echo ""
    print_success "Verificação completa finalizada!"
    echo ""
}

# Função para executar comandos interativos de forma automatizada
execute_interactive_command() {
    local cmd="$1"
    local purpose="$2"
    local timeout_seconds="${3:-30}"
    
    print_command "$cmd" "$purpose (modo interativo automatizado com timeout de ${timeout_seconds}s)"
    
    # Verificar se timeout está disponível (macOS pode ter gtimeout)
    local timeout_cmd=""
    if command -v timeout &> /dev/null; then
        timeout_cmd="timeout"
    elif command -v gtimeout &> /dev/null; then
        timeout_cmd="gtimeout"
    else
        print_warning "Comando 'timeout' não disponível. Tentando sem timeout..."
    fi
    
    echo -e "${BLUE}📤 Executando com timeout de ${timeout_seconds}s...${NC}"
    print_warning "Se o comando pedir confirmação interativa, pode não funcionar automaticamente."
    
    # Tentar executar com expect se disponível (melhor opção para automação)
    if command -v expect &> /dev/null; then
        print_info "Usando 'expect' para automação interativa..."
        expect << EXPECT_EOF 2>&1 | head -100
set timeout $timeout_seconds
spawn bash -c "$cmd"
expect {
    -re ".*[Yy]es/[Nn]o.*" { 
        send "yes\r"
        exp_continue 
    }
    -re ".*[Yy]/[Nn].*" { 
        send "y\r"
        exp_continue 
    }
    -re ".*password.*" { 
        send "\r"
        exp_continue 
    }
    -re ".*Password.*" { 
        send "\r"
        exp_continue 
    }
    -re ".*continue.*" { 
        send "\r"
        exp_continue 
    }
    -re ".*proceed.*" { 
        send "\r"
        exp_continue 
    }
    -re ".*Press.*" { 
        send "\r"
        exp_continue 
    }
    timeout { 
        puts "Timeout após ${timeout_seconds}s"
        exit 124
    }
    eof
}
catch wait result
exit [lindex \$result 3]
EXPECT_EOF
        local exit_code=$?
    elif [ -n "$timeout_cmd" ]; then
        # Fallback: usar timeout com entrada automática (múltiplos Enters)
        print_info "Usando 'timeout' com entrada automática..."
        (
            # Enviar múltiplos Enters para responder prompts
            for i in {1..10}; do
                echo ""
                sleep 0.2
            done
        ) | $timeout_cmd "$timeout_seconds" bash -c "$cmd" 2>&1 | head -100
        local exit_code=$?
    else
        # Sem timeout disponível - executar diretamente mas limitar saída
        print_warning "Executando sem timeout (pode travar se for muito interativo)..."
        bash -c "$cmd" 2>&1 | head -100 &
        local cmd_pid=$!
        sleep "$timeout_seconds"
        if kill -0 "$cmd_pid" 2>/dev/null; then
            kill "$cmd_pid" 2>/dev/null
            exit_code=124
        else
            wait "$cmd_pid"
            exit_code=$?
        fi
    fi
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ Comando interativo executado com sucesso${NC}"
    elif [ $exit_code -eq 124 ]; then
        echo -e "${YELLOW}⚠ Comando interativo atingiu timeout de ${timeout_seconds}s${NC}"
        print_info "O comando pode precisar de interação manual. Execute: $cmd"
    else
        echo -e "${YELLOW}⚠ Comando interativo retornou código: $exit_code${NC}"
        print_info "Pode ter funcionado parcialmente ou requerido interação manual."
        print_info "Para executar manualmente: $cmd"
    fi
    
    return $exit_code
}

# Verificar se o NuCLI está instalado
check_nucli_installation() {
    print_header "Verificando instalação do NuCLI"
    
    print_info "Verificando se o comando 'nu' está disponível no sistema..."
    
    execute_command "command -v nu" \
        "Verifica se o comando 'nu' está instalado e disponível no PATH do sistema" \
        "false"
    
    if [ $? -eq 0 ]; then
        print_success "NuCLI está instalado"
        register_command_success "command -v nu" "NuCLI encontrado no PATH"
        
        execute_command "nu --version" \
            "Obtém a versão do NuCLI instalado, incluindo informações de commit e data" \
            "true"
        
        nucli_version=$(nu --version 2>/dev/null || echo "versão não disponível")
        register_command_success "nu --version" "$nucli_version"
        print_info "Versão: $nucli_version"
        return 0
    else
        print_error "NuCLI não está instalado"
        register_command_failed "command -v nu" "NuCLI não encontrado no PATH"
        print_info "Para instalar, execute: npm install -g @nubank/nucli"
        return 1
    fi
}

# Verificar configuração do AWS CLI
check_aws_config() {
    print_header "Verificando configuração do AWS"
    
    print_info "Verificando se o AWS CLI está instalado..."
    
    execute_command "command -v aws" \
        "Verifica se o comando 'aws' está instalado e disponível no PATH do sistema" \
        "false"
    
    if [ $? -eq 0 ]; then
        print_success "AWS CLI está instalado"
        register_command_success "command -v aws" "AWS CLI encontrado no PATH"
        
        execute_command "aws --version" \
            "Exibe a versão do AWS CLI instalado, incluindo versão do Python e sistema operacional" \
            "true"
        
        aws_version=$(aws --version 2>/dev/null)
        register_command_success "aws --version" "$aws_version"
        print_info "$aws_version"
        
        print_info "Verificando se as credenciais AWS estão configuradas corretamente..."
        
        execute_command "aws sts get-caller-identity" \
            "Verifica se as credenciais AWS são válidas obtendo informações da identidade do chamador (conta, usuário, ARN)" \
            "false"
        
        if [ $? -eq 0 ]; then
            print_success "Credenciais AWS configuradas corretamente"
            register_command_success "aws sts get-caller-identity" "Credenciais AWS válidas"
            
            execute_command "aws sts get-caller-identity --query Account --output text" \
                "Obtém o número da conta AWS associada às credenciais configuradas" \
                "true"
            
            aws_account=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
            
            execute_command "aws sts get-caller-identity --query Arn --output text" \
                "Obtém o ARN (Amazon Resource Name) completo do usuário/role autenticado" \
                "true"
            
            aws_user=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null)
            print_info "Conta AWS: $aws_account"
            print_info "Usuário: $aws_user"
        else
            print_error "Credenciais AWS não configuradas ou inválidas"
            register_command_failed "aws sts get-caller-identity" "Credenciais não configuradas ou inválidas"
            print_info "Execute: aws configure"
            return 1
        fi
        
        print_info "Verificando região AWS configurada..."
        
        execute_command "aws configure get region" \
            "Obtém a região AWS padrão configurada nas credenciais" \
            "true"
        
        aws_region=$(aws configure get region 2>/dev/null)
        if [ -n "$aws_region" ]; then
            print_success "Região AWS configurada: $aws_region"
        else
            print_warning "Região AWS não configurada"
            print_info "Execute: aws configure set region <sua-regiao>"
        fi
        
        return 0
    else
        print_error "AWS CLI não está instalado"
        print_info "Para instalar, visite: https://aws.amazon.com/cli/"
        return 1
    fi
}

# Verificar conectividade de rede
check_network_connectivity() {
    print_header "Verificando conectividade de rede"
    
    print_info "Testando conectividade básica de rede..."
    
    execute_command "ping -c 1 8.8.8.8" \
        "Testa conectividade de rede básica fazendo ping para o servidor DNS público do Google (8.8.8.8)" \
        "false"
    
    if [ $? -eq 0 ]; then
        print_success "Conectividade de rede OK"
    else
        print_error "Sem conectividade de rede"
        return 1
    fi
    
    print_info "Verificando resolução DNS..."
    
    execute_command "nslookup aws.amazon.com" \
        "Testa se o DNS está funcionando corretamente resolvendo o domínio aws.amazon.com" \
        "false"
    
    if [ $? -eq 0 ]; then
        print_success "DNS funcionando corretamente"
    else
        print_error "Problemas com DNS"
        return 1
    fi
    
    print_info "Verificando conectividade com serviços AWS..."
    
    execute_command "curl -s --max-time 5 https://aws.amazon.com" \
        "Testa conectividade HTTPS com os serviços AWS usando curl com timeout de 5 segundos" \
        "false"
    
    if [ $? -eq 0 ]; then
        print_success "Conectividade com AWS OK"
    else
        print_warning "Possível problema de conectividade com AWS"
    fi
}

# Verificar variáveis de ambiente
check_environment_variables() {
    print_header "Verificando variáveis de ambiente"
    
    print_info "Verificando variáveis de ambiente AWS..."
    
    # Verificar variáveis AWS comuns
    aws_vars=("AWS_PROFILE" "AWS_REGION" "AWS_DEFAULT_REGION" "AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY")
    
    for var in "${aws_vars[@]}"; do
        if [ -n "${!var}" ]; then
            if [[ "$var" == *"SECRET"* ]] || [[ "$var" == *"KEY"* ]]; then
                print_info "$var está definida (valor oculto)"
                execute_command "echo \"\$$var\" | wc -c" \
                    "Verifica o tamanho da variável $var (sem mostrar o valor por segurança)" \
                    "true"
            else
                execute_command "echo \"\$$var\"" \
                    "Exibe o valor da variável de ambiente $var" \
                    "true"
                print_info "$var=${!var}"
            fi
        fi
    done
    
    print_info "Verificando variáveis de ambiente NuCLI..."
    
    # Verificar variáveis NuCLI
    nucli_vars=("NUCLI_ENV" "NUCLI_PROFILE" "NUCLI_CONFIG_PATH")
    
    for var in "${nucli_vars[@]}"; do
        if [ -n "${!var}" ]; then
            execute_command "echo \"\$$var\"" \
                "Exibe o valor da variável de ambiente $var" \
                "true"
            print_info "$var=${!var}"
        fi
    done
}

# Verificar permissões de arquivos
check_file_permissions() {
    print_header "Verificando permissões de arquivos"
    
    aws_creds_file="$HOME/.aws/credentials"
    
    if [ -f "$aws_creds_file" ]; then
        print_info "Verificando permissões do arquivo de credenciais AWS..."
        
        execute_command "stat -f \"%OLp\" \"$aws_creds_file\" 2>/dev/null || stat -c \"%a\" \"$aws_creds_file\" 2>/dev/null" \
            "Obtém as permissões do arquivo de credenciais AWS em formato octal (ex: 600, 644)" \
            "true"
        
        perms=$(stat -f "%OLp" "$aws_creds_file" 2>/dev/null || stat -c "%a" "$aws_creds_file" 2>/dev/null)
        if [ "$perms" != "600" ] && [ "$perms" != "400" ]; then
            print_warning "Permissões do arquivo de credenciais AWS podem ser inseguras: $perms"
            print_info "Aplicando correção automática..."
            execute_command "chmod 600 \"$aws_creds_file\"" \
                "Corrige as permissões do arquivo para 600 (leitura/escrita apenas para o proprietário, mais seguro)" \
                "false"
            
            if [ $? -eq 0 ]; then
                print_success "Permissões corrigidas automaticamente"
            else
                print_error "Falha ao corrigir permissões"
            fi
        else
            print_success "Permissões do arquivo de credenciais AWS OK"
        fi
    fi
    
    aws_config_file="$HOME/.aws/config"
    
    if [ -f "$aws_config_file" ]; then
        execute_command "test -f \"$aws_config_file\"" \
            "Verifica se o arquivo de configuração AWS existe" \
            "false"
        
        if [ $? -eq 0 ]; then
            print_success "Arquivo de configuração AWS encontrado"
        fi
    fi
}

# Coletar roles e policies do usuário
collect_user_roles_and_policies() {
    print_header "Coletando Roles e Policies do Usuário"
    
    if ! command -v nu &> /dev/null; then
        print_warning "NuCLI não está instalado. Não é possível coletar roles e policies."
        return 1
    fi
    
    local current_user=$(whoami)
    local all_countries=("br" "br-staging" "co" "mx" "ist" "us" "us-staging" "ar")
    local selected_countries=()
    local timeout_cmd=""
    
    if command -v timeout &> /dev/null; then
        timeout_cmd="timeout"
    elif command -v gtimeout &> /dev/null; then
        timeout_cmd="gtimeout"
    fi
    
    print_info "Coletando informações de IAM para o usuário: $current_user"
    echo ""
    
    # Permitir que o usuário escolha quais contas verificar
    if [ -t 0 ]; then  # Modo interativo
        echo ""
        print_info "Selecione quais contas AWS você deseja verificar:"
        echo ""
        echo "0. Todas as contas"
        local idx=1
        for country in "${all_countries[@]}"; do
            echo "$idx. $country"
            ((idx++))
        done
        echo ""
        read -p "Digite os números separados por vírgula (ex: 1,2,3) ou 0 para todas: " selection
        
        if [ "$selection" = "0" ] || [ -z "$selection" ]; then
            # Selecionar todas as contas
            selected_countries=("${all_countries[@]}")
            print_info "Verificando todas as contas: ${all_countries[*]}"
        else
            # Processar seleção múltipla
            IFS=',' read -ra selections <<< "$selection"
            for sel in "${selections[@]}"; do
                sel=$(echo "$sel" | tr -d ' ')  # Remover espaços
                if [[ "$sel" =~ ^[0-9]+$ ]] && [ "$sel" -ge 1 ] && [ "$sel" -le "${#all_countries[@]}" ]; then
                    local country_idx=$((sel - 1))
                    selected_countries+=("${all_countries[$country_idx]}")
                fi
            done
            
            if [ ${#selected_countries[@]} -eq 0 ]; then
                print_warning "Nenhuma seleção válida. Verificando todas as contas por padrão."
                selected_countries=("${all_countries[@]}")
            else
                print_info "Contas selecionadas: ${selected_countries[*]}"
            fi
        fi
        echo ""
    else
        # Modo não-interativo: verificar todas
        selected_countries=("${all_countries[@]}")
        print_info "Modo não-interativo: Verificando todas as contas"
    fi
    
    for country in "${selected_countries[@]}"; do
        print_info "Verificando $country..."
        
        local iam_cmd="nu sec shared-role-iam show $current_user --target-aws-account=$country 2>&1"
        local iam_output=""
        local iam_exit=1
        
        if [ -n "$timeout_cmd" ]; then
            iam_output=$($timeout_cmd 15 bash -c "$iam_cmd" 2>&1)
            iam_exit=$?
        else
            iam_output=$(bash -c "$iam_cmd" 2>&1)
            iam_exit=$?
        fi
        
        if [ $iam_exit -eq 0 ] && [ -n "$iam_output" ]; then
            # Verificar se a saída contém informações válidas
            if ! echo "$iam_output" | grep -qiE "error|Error|ERROR|failed|Failed|not found|não encontrado|timeout|permission denied|authentication"; then
                local content_lines=$(echo "$iam_output" | grep -v '^[[:space:]]*$' | wc -l | tr -d ' ')
                
                if [ "$content_lines" -gt 0 ]; then
                    print_success "Informações coletadas para $country"
                    
                    # Extrair roles (geralmente aparecem como "role:" ou "arn:aws:iam::")
                    local roles=$(echo "$iam_output" | grep -iE "role:|arn:aws:iam::" | head -20 | tr '\n' '; ' || echo "N/A")
                    
                    # Extrair policies (geralmente aparecem como "policy:" ou nomes de políticas)
                    local policies=$(echo "$iam_output" | grep -iE "policy:|Policy Name|ManagedPolicy" | head -20 | tr '\n' '; ' || echo "N/A")
                    
                    # Armazenar usando funções auxiliares (compatibilidade bash 3.2)
                    set_user_role "$country" "$roles"
                    set_user_policy "$country" "$policies"
                    
                    # Armazenar output completo também
                    set_user_role_full "$country" "$iam_output"
                else
                    print_warning "Nenhuma informação encontrada para $country"
                    set_user_role "$country" "Nenhuma role encontrada"
                    set_user_policy "$country" "Nenhuma policy encontrada"
                fi
            else
                print_warning "Erro ao coletar informações para $country (pode requerer autenticação)"
                
                # Verificar se está em modo interativo e oferecer autenticação manual
                if [ -t 0 ]; then
                    echo ""
                    print_info "Deseja fazer autenticação manual para $country agora?"
                    read -p "Digite 's' para autenticar manualmente ou Enter para pular: " auth_choice
                    
                    if [[ "$auth_choice" =~ ^[SsYy]$ ]]; then
                        echo ""
                        print_info "Executando autenticação interativa para $country..."
                        print_info "Comando: nu sec shared-role-iam show $current_user --target-aws-account=$country"
                        echo ""
                        print_warning "Você poderá interagir diretamente com o comando de autenticação."
                        echo ""
                        
                        # Executar comando interativo permitindo autenticação manual
                        execute_interactive_user_command "nu sec shared-role-iam show $current_user --target-aws-account=$country" \
                            "Autenticação manual para coletar informações de $country"
                        
                        # Tentar coletar novamente após autenticação
                        echo ""
                        print_info "Tentando coletar informações novamente para $country..."
                        if [ -n "$timeout_cmd" ]; then
                            iam_output=$($timeout_cmd 15 bash -c "$iam_cmd" 2>&1)
                            iam_exit=$?
                        else
                            iam_output=$(bash -c "$iam_cmd" 2>&1)
                            iam_exit=$?
                        fi
                        
                        # Verificar se agora funcionou
                        if [ $iam_exit -eq 0 ] && [ -n "$iam_output" ]; then
                            if ! echo "$iam_output" | grep -qiE "error|Error|ERROR|failed|Failed|not found|não encontrado|timeout|permission denied|authentication"; then
                                local content_lines=$(echo "$iam_output" | grep -v '^[[:space:]]*$' | wc -l | tr -d ' ')
                                
                                if [ "$content_lines" -gt 0 ]; then
                                    print_success "Informações coletadas para $country após autenticação!"
                                    
                                    local roles=$(echo "$iam_output" | grep -iE "role:|arn:aws:iam::" | head -20 | tr '\n' '; ' || echo "N/A")
                                    local policies=$(echo "$iam_output" | grep -iE "policy:|Policy Name|ManagedPolicy" | head -20 | tr '\n' '; ' || echo "N/A")
                                    
                                    set_user_role "$country" "$roles"
                                    set_user_policy "$country" "$policies"
                                    set_user_role_full "$country" "$iam_output"
                                    
                                    echo ""
                                    continue  # Pular para próximo país
                                fi
                            fi
                        fi
                        
                        print_warning "Ainda não foi possível coletar informações para $country após autenticação"
                    fi
                fi
                
                set_user_role "$country" "Erro ao coletar (requer autenticação)"
                set_user_policy "$country" "Erro ao coletar (requer autenticação)"
            fi
        else
            print_warning "Não foi possível coletar informações para $country"
            
            # Verificar se é erro de autenticação e oferecer autenticação manual
            if echo "$iam_output" | grep -qiE "authentication|auth|login|credential"; then
                if [ -t 0 ]; then
                    echo ""
                    print_info "Parece ser um erro de autenticação. Deseja fazer autenticação manual para $country?"
                    read -p "Digite 's' para autenticar manualmente ou Enter para pular: " auth_choice
                    
                    if [[ "$auth_choice" =~ ^[SsYy]$ ]]; then
                        echo ""
                        print_info "Executando autenticação interativa para $country..."
                        execute_interactive_user_command "nu sec shared-role-iam show $current_user --target-aws-account=$country" \
                            "Autenticação manual para coletar informações de $country"
                        
                        # Tentar coletar novamente
                        echo ""
                        print_info "Tentando coletar informações novamente para $country..."
                        if [ -n "$timeout_cmd" ]; then
                            iam_output=$($timeout_cmd 15 bash -c "$iam_cmd" 2>&1)
                            iam_exit=$?
                        else
                            iam_output=$(bash -c "$iam_cmd" 2>&1)
                            iam_exit=$?
                        fi
                        
                        if [ $iam_exit -eq 0 ] && [ -n "$iam_output" ]; then
                            if ! echo "$iam_output" | grep -qiE "error|Error|ERROR|failed|Failed|not found|não encontrado|timeout|permission denied|authentication"; then
                                local content_lines=$(echo "$iam_output" | grep -v '^[[:space:]]*$' | wc -l | tr -d ' ')
                                
                                if [ "$content_lines" -gt 0 ]; then
                                    print_success "Informações coletadas para $country após autenticação!"
                                    
                                    local roles=$(echo "$iam_output" | grep -iE "role:|arn:aws:iam::" | head -20 | tr '\n' '; ' || echo "N/A")
                                    local policies=$(echo "$iam_output" | grep -iE "policy:|Policy Name|ManagedPolicy" | head -20 | tr '\n' '; ' || echo "N/A")
                                    
                                    set_user_role "$country" "$roles"
                                    set_user_policy "$country" "$policies"
                                    set_user_role_full "$country" "$iam_output"
                                    
                                    echo ""
                                    continue  # Pular para próximo país
                                fi
                            fi
                        fi
                    fi
                fi
            fi
            
            set_user_role "$country" "Não disponível"
            set_user_policy "$country" "Não disponível"
        fi
        
        sleep 0.5  # Pequena pausa entre requisições
    done
    
    echo ""
    print_success "Coleta de roles e policies concluída"
    
    return 0
}

# Cadastrar digital (configurar IAM user e autenticação)
cadastrar_digital() {
    print_header "Cadastro Digital - Configuração IAM User e Autenticação"
    
    # Obter usuário atual
    local current_user=$(whoami)
    print_info "Usuário atual detectado: $current_user"
    echo ""
    
    # Criar diretório se não existir
    local iam_user_dir="$HOME/dev/nu/.nu/about/me"
    local iam_user_file="$iam_user_dir/iam_user"
    
    print_info "Criando diretório se necessário: $iam_user_dir"
    execute_command "mkdir -p '$iam_user_dir'" \
        "Cria o diretório para armazenar informações do IAM user" \
        "false"
    
    if [ $? -ne 0 ]; then
        print_error "Falha ao criar diretório"
        return 1
    fi
    
    # Criar arquivo iam_user com o nome do usuário
    print_info "Criando arquivo iam_user com o nome do usuário..."
    execute_command "echo '$current_user' > '$iam_user_file'" \
        "Cria arquivo iam_user com o nome do usuário atual ($current_user)" \
        "false"
    
    if [ $? -eq 0 ]; then
        print_success "Arquivo iam_user criado com sucesso!"
        register_command_success "echo '$current_user' > '$iam_user_file'" "IAM user configurado: $current_user"
        print_info "Conteúdo do arquivo: $(cat "$iam_user_file")"
    else
        print_error "Falha ao criar arquivo iam_user"
        register_command_failed "echo '$current_user' > '$iam_user_file'" "Falha ao criar arquivo"
        return 1
    fi
    
    echo ""
    print_info "Para continuar com a configuração, você precisa de YubiKey ou Touch ID configurado para AWS CLI."
    echo ""
    
    # Verificar se gimme-aws-creds está instalado
    print_info "Verificando se gimme-aws-creds está instalado..."
    execute_command "command -v gimme-aws-creds" \
        "Verifica se gimme-aws-creds está instalado" \
        "false"
    
    local has_gimme=$?
    
    if [ $has_gimme -ne 0 ]; then
        print_warning "gimme-aws-creds não está instalado"
        print_info "Instalando gimme-aws-creds via Homebrew..."
        echo ""
        
        execute_command "brew install gimme-aws-creds" \
            "Instala gimme-aws-creds via Homebrew" \
            "true"
        
        if [ $? -ne 0 ]; then
            print_error "Falha ao instalar gimme-aws-creds"
            register_command_failed "brew install gimme-aws-creds" "Falha na instalação"
            print_info "Tente instalar manualmente: brew install gimme-aws-creds"
            return 1
        else
            register_command_success "brew install gimme-aws-creds" "gimme-aws-creds instalado"
        fi
    else
        print_success "gimme-aws-creds já está instalado"
        register_command_success "command -v gimme-aws-creds" "gimme-aws-creds encontrado"
    fi
    
    echo ""
    print_info "Atualizando NuCLI..."
    execute_command "nu update" \
        "Atualiza o NuCLI para garantir versão mais recente" \
        "true"
    
    echo ""
    print_info "Configurando autenticação FIDO..."
    print_warning "Se você não tem YubiKey, o Touch ID será configurado."
    print_info "O Touch ID deve estar registrado na sua máquina."
    echo ""
    
    # Verificar se gsed está disponível (GNU sed)
    execute_command "command -v gsed" \
        "Verifica se gsed (GNU sed) está disponível" \
        "false"
    
    local has_gsed=$?
    
    if [ $has_gsed -ne 0 ]; then
        print_warning "gsed não encontrado. Tentando instalar via Homebrew..."
        execute_command "brew install gnu-sed" \
            "Instala gnu-sed (gsed) via Homebrew" \
            "true"
        
        if [ $? -ne 0 ]; then
            print_error "Falha ao instalar gsed. Continuando sem ele..."
            register_command_needs_action "gsed" "gsed não disponível - pode precisar instalar manualmente"
        fi
    fi
    
    # Configurar okta_aws_login_config se gsed estiver disponível
    local okta_config="$HOME/.okta_aws_login_config"
    if [ -f "$okta_config" ] && [ $has_gsed -eq 0 ]; then
        print_info "Configurando okta_aws_login_config..."
        execute_command "gsed -i 's/^[^#]*preferred_mfa_type/#&/' '$okta_config'" \
            "Comenta a linha preferred_mfa_type no arquivo de configuração Okta" \
            "false"
        
        if [ $? -eq 0 ]; then
            register_command_success "gsed -i 's/^[^#]*preferred_mfa_type/#&/' '$okta_config'" "Configuração Okta atualizada"
        fi
    elif [ ! -f "$okta_config" ]; then
        print_info "Arquivo okta_aws_login_config não existe ainda. Será criado durante a configuração."
    fi
    
    echo ""
    print_info "Configurando autenticador FIDO..."
    print_warning "Você precisará autenticar usando Okta Verify ou Google Authenticator."
    print_info "Após autenticação, selecione a opção 'webauth:webauth' sempre que atualizar credenciais AWS."
    echo ""
    
    read -p "Deseja executar a configuração do autenticador FIDO agora? (s/N): " setup_fido
    if [[ "$setup_fido" =~ ^[SsYy]$ ]]; then
        execute_interactive_user_command "nu aws okta-aws-creds --setup-fido-authenticator" \
            "Configura o autenticador FIDO para AWS (requer interação do usuário)"
    else
        print_info "Pulando configuração do autenticador FIDO."
        print_info "Execute manualmente quando necessário: nu aws okta-aws-creds --setup-fido-authenticator"
    fi
    
    echo ""
    print_header "Configuração BR AWS - Shared Role Account"
    print_info "Para BR AWS - Shared Role account, execute os seguintes comandos:"
    echo ""
    
    read -p "Deseja executar os comandos para BR AWS - Shared Role account agora? (s/N): " setup_br
    if [[ "$setup_br" =~ ^[SsYy]$ ]]; then
        echo ""
        print_info "1. Obtendo refresh token para IST (prod)..."
        execute_interactive_user_command "nu-ist auth get-refresh-token --env prod" \
            "Obtém refresh token para ambiente prod do IST (requer interação)"
        
        echo ""
        print_info "2. Atualizando credenciais AWS compartilhadas para BR e fazendo login no CodeArtifact..."
        execute_interactive_user_command "nu aws shared-role-credentials refresh --account-alias=br && nu codeartifact login maven" \
            "Atualiza credenciais AWS para BR e faz login no CodeArtifact Maven"
    else
        print_info "Comandos para executar manualmente:"
        print_info "  nu-ist auth get-refresh-token --env prod"
        print_info "  nu aws shared-role-credentials refresh --account-alias=br && nu codeartifact login maven"
    fi
    
    echo ""
    print_success "Cadastro digital concluído!"
    print_info "Resumo:"
    print_info "  - Arquivo iam_user criado: $iam_user_file"
    print_info "  - Usuário configurado: $current_user"
    if [ $has_gimme -ne 0 ]; then
        print_info "  - gimme-aws-creds instalado"
    else
        print_info "  - gimme-aws-creds já estava instalado"
    fi
    echo ""
}

# Mostrar comandos úteis do NuCLI
show_useful_commands() {
    print_header "Comandos Úteis do NuCLI e AWS"
    
    echo ""
    print_info "COMANDOS DE CREDENCIAIS AWS:"
    echo ""
    print_info "1. Refresh Credenciais AWS (modo interativo):"
    print_info "   nu aws shared-role-credentials refresh -i"
    echo ""
    print_info "2. Refresh Credenciais para conta BR:"
    print_info "   nu aws shared-role-credentials refresh --account-alias=br"
    echo ""
    print_info "3. Refresh com políticas específicas:"
    print_info "   nu aws shared-role-credentials refresh --account-alias=br --keep-policies=casual-dev,eng,eng-prod-engineering,prod-eng"
    echo ""
    print_info "4. Reset Credenciais AWS:"
    print_info "   nu aws credentials reset"
    echo ""
    print_info "5. Setup Credenciais AWS:"
    print_info "   nu aws credentials setup"
    echo ""
    print_info "6. Setup Profiles Config:"
    print_info "   nu aws profiles-config setup"
    echo ""
    print_info "COMANDOS DE CODEARTIFACT:"
    echo ""
    print_info "1. Login Maven/CodeArtifact:"
    print_info "   nu codeartifact login maven"
    echo ""
    print_info "2. Combinar refresh e login (atalho):"
    print_info "   nu aws shared-role-credentials refresh --account-alias=br && nu codeartifact login maven"
    echo ""
    print_info "COMANDOS DE ATUALIZAÇÃO:"
    echo ""
    print_info "1. Atualizar NuCLI:"
    print_info "   nu update"
    echo ""
    print_info "2. Update branch (resetar e atualizar branch - versão do Nucli):"
    print_info "   cd ~/dev/nu/nucli"
    print_info "   git pull --rebase"
    echo ""
    print_info "3. Apagar pasta do nucli e reclonar:"
    print_info "   rm -rf \"\${NU_HOME:-~/dev/nu}/nucli/\""
    print_info "   git clone git@github.com:nubank/nucli.git \"\${NU_HOME:-~/dev/nu}/nucli/\""
    echo ""
    print_info "COMANDOS DE VERIFICAÇÃO:"
    echo ""
    print_info "1. Ver Políticas IAM:"
    print_info "   nu sec shared-role-iam show <username> --target-aws-account=<account-alias>"
    print_info "   Exemplo: nu sec shared-role-iam show $(whoami) --target-aws-account=br"
    echo ""
    print_info "2. Ver Escopos por País:"
    print_info "   nu-br sec scope show <username>"
    print_info "   nu-co sec scope show <username>"
    print_info "   nu-mx sec scope show <username>"
    echo ""
    print_info "3. Acessar Console Web AWS via terminal (útil para ver roles e acessar arquivos no S3):"
    print_info "   nu aws shared-role-credentials refresh -i"
    echo ""
    print_info "4. Acessar Console Web AWS:"
    print_info "   nu aws shared-role-credentials web-console -i"
    echo ""
    print_info "COMANDOS DE TROUBLESHOOTING:"
    echo ""
    print_info "1. Deletar configuração AWS (para problemas de credenciais):"
    print_info "   Deletar pasta .aws inteira:"
    print_info "   rm -rf ~/.aws"
    print_info "   OU apenas o arquivo config:"
    print_info "   rm ~/.aws/config"
    echo ""
    print_info "2. Instalar Java (necessário para shared roles):"
    print_info "   brew install --cask temurin"
    echo ""
    print_info "3. Configurar Autenticadores Okta:"
    print_info "   /opt/homebrew/bin/gimme-aws-creds --action-setup-fido-authenticator"
    echo ""
    print_info "4. Editar Configuração Okta (remover preferred_mfa_type):"
    print_info "   gsed -i 's/^[^#]*preferred_mfa_type/#&/' ~/.okta_aws_login_config"
    echo ""
    print_info "LINKS ÚTEIS:"
    echo ""
    print_info "1. Request BR Role:"
    print_info "   https://nubank.atlassian.net/servicedesk/customer/portal/131/group/679/create/9937"
    echo ""
    print_info "2. Request Groups (casual-dev, eng):"
    print_info "   https://nubank.atlassian.net/servicedesk/customer/portal/131/group/680/create/2117"
    echo ""
    print_info "3. Acesso S3:"
    print_info "   https://nubank.atlassian.net/servicedesk/customer/portal/4/group/3525"
    echo ""
    print_info "4. Lista de chamados iniciativa:"
    print_info "   IT-1073490: Office Tickets - Daniel Fonseca"
    echo ""
}

# Verificar logs de erro recentes
check_recent_errors() {
    print_header "Verificando logs de erro recentes"
    
    if [ -d "/var/log" ]; then
        print_info "Verificando logs do sistema..."
        execute_command "ls -ld /var/log" \
            "Lista informações do diretório de logs do sistema" \
            "true"
        print_info "Logs do sistema em: /var/log"
    fi
    
    if [ -d "$HOME/.nucli" ]; then
        print_info "Verificando diretório NuCLI..."
        
        execute_command "test -d \"$HOME/.nucli\"" \
            "Verifica se o diretório de configuração/logs do NuCLI existe" \
            "false"
        
        if [ $? -eq 0 ]; then
            print_info "Diretório NuCLI encontrado: $HOME/.nucli"
            
            execute_command "find \"$HOME/.nucli\" -name \"*.log\" -type f 2>/dev/null | wc -l" \
                "Conta quantos arquivos de log existem no diretório NuCLI" \
                "true"
            
            log_count=$(find "$HOME/.nucli" -name "*.log" -type f 2>/dev/null | wc -l)
            if [ "$log_count" -gt 0 ]; then
                print_info "Encontrados $log_count arquivo(s) de log"
                
                execute_command "ls -lah \"$HOME/.nucli\"/*.log 2>/dev/null | head -5" \
                    "Lista os arquivos de log do NuCLI com detalhes de tamanho e data" \
                    "true"
                
                print_info "Para visualizar: ls -lah $HOME/.nucli/*.log"
            fi
        fi
    fi
}

# Testar comandos básicos do NuCLI
test_nucli_commands() {
    print_header "Testando comandos básicos do NuCLI"
    
    if ! command -v nu &> /dev/null; then
        print_error "NuCLI não está instalado. Pulando testes."
        return 1
    fi
    
    print_info "Testando comando de ajuda do NuCLI..."
    
    execute_command "nu --help" \
        "Testa o comando de ajuda do NuCLI para verificar se está funcionando corretamente" \
        "false"
    
    if [ $? -eq 0 ]; then
        print_success "Comando 'nu --help' funciona"
    else
        print_error "Comando 'nu --help' falhou"
    fi
    
    print_info "Testando comando de versão do NuCLI..."
    
    execute_command "nu --version" \
        "Testa o comando de versão do NuCLI para verificar se está funcionando corretamente" \
        "true"
    
    if [ $? -eq 0 ]; then
        print_success "Comando 'nu --version' funciona"
    else
        print_warning "Comando 'nu --version' pode não estar disponível"
    fi
}

# Testar comandos básicos do AWS CLI
test_aws_commands() {
    print_header "Testando comandos básicos do AWS CLI"
    
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI não está instalado. Pulando testes."
        return 1
    fi
    
    print_info "Testando comando de ajuda do AWS CLI..."
    
    execute_command "aws --help" \
        "Testa o comando de ajuda do AWS CLI para verificar se está funcionando corretamente" \
        "false"
    
    if [ $? -eq 0 ]; then
        print_success "Comando 'aws --help' funciona"
    else
        print_error "Comando 'aws --help' falhou"
    fi
    
    print_info "Testando comando de versão do AWS CLI..."
    
    execute_command "aws --version" \
        "Testa o comando de versão do AWS CLI para verificar se está funcionando corretamente" \
        "true"
    
    if [ $? -eq 0 ]; then
        print_success "Comando 'aws --version' funciona"
    else
        print_error "Comando 'aws --version' falhou"
    fi
    
    print_info "Testando autenticação AWS..."
    
    execute_command "aws sts get-caller-identity" \
        "Testa se as credenciais AWS são válidas tentando obter informações da identidade do chamador" \
        "true"
    
    if [ $? -eq 0 ]; then
        print_success "Comando 'aws sts get-caller-identity' funciona"
    else
        print_error "Comando 'aws sts get-caller-identity' falhou"
        print_info "Verifique suas credenciais AWS"
    fi
}

# Verificar roles, escopos e países disponíveis
check_roles_scopes_countries() {
    print_header "Verificando Roles, Escopos e Países Disponíveis"
    
    if ! command -v nu &> /dev/null; then
        print_error "NuCLI não está instalado. Pulando verificação de roles e escopos."
        return 1
    fi
    
    # Verificar se deve tentar executar comandos interativos
    local try_interactive="${TRY_INTERACTIVE:-false}"
    
    print_info "Informações sobre credenciais AWS compartilhadas..."
    
    if [ "$try_interactive" = "true" ]; then
        print_info "Modo interativo automatizado habilitado. Tentando executar comandos..."
        
        # Tentar executar refresh de credenciais com timeout
        execute_interactive_command "nu aws shared-role-credentials refresh -i" \
            "Atualiza as credenciais AWS compartilhadas (tentativa automatizada)" \
            30
        
        if [ $? -eq 0 ]; then
            print_success "Credenciais AWS compartilhadas atualizadas"
        else
            print_warning "Não foi possível atualizar credenciais automaticamente"
            print_info "Execute manualmente: nu aws shared-role-credentials refresh -i"
        fi
    else
        print_warning "AVISO: Comandos de credenciais são interativos e podem travar o script."
        print_info "Por padrão, o script não executa esses comandos automaticamente."
        print_info "Para habilitar execução automatizada, defina: export TRY_INTERACTIVE=true"
        print_success "Comando disponível: nu aws shared-role-credentials"
        print_info ""
        print_info "Para atualizar credenciais manualmente quando necessário, execute:"
        print_info "  nu aws shared-role-credentials refresh -i"
        print_info ""
        print_info "Para acessar o console web AWS:"
        print_info "  nu aws shared-role-credentials web-console -i"
    fi
    
    print_info "Listando países/aliases disponíveis..."
    
    # Lista de países/aliases conhecidos baseado na documentação
    countries=("br" "br-staging" "mx" "ist" "us" "us-staging" "co" "ar")
    
    print_info "Países/Aliases conhecidos disponíveis:"
    for country in "${countries[@]}"; do
        print_info "  - $country"
    done
    
    print_info ""
    print_info "Informações sobre comandos de IAM..."
    
    if [ "$try_interactive" = "true" ]; then
        print_info "Tentando verificar políticas IAM (modo automatizado)..."
        
        # Permitir que o usuário escolha quais contas verificar
        local all_countries=("br" "br-staging" "co" "mx" "ist" "us" "us-staging" "ar")
        local selected_countries=()
        
        if [ -t 0 ]; then  # Modo interativo
            echo ""
            print_info "Selecione quais contas AWS você deseja verificar IAM:"
            echo ""
            echo "0. Todas as contas"
            local idx=1
            for country in "${all_countries[@]}"; do
                echo "$idx. $country"
                ((idx++))
            done
            echo ""
            read -p "Digite os números separados por vírgula (ex: 1,2,3) ou 0 para todas: " iam_selection
            
            if [ "$iam_selection" = "0" ] || [ -z "$iam_selection" ]; then
                selected_countries=("${all_countries[@]}")
                print_info "Verificando IAM para todas as contas: ${all_countries[*]}"
            else
                IFS=',' read -ra selections <<< "$iam_selection"
                for sel in "${selections[@]}"; do
                    sel=$(echo "$sel" | tr -d ' ')
                    if [[ "$sel" =~ ^[0-9]+$ ]] && [ "$sel" -ge 1 ] && [ "$sel" -le "${#all_countries[@]}" ]; then
                        local country_idx=$((sel - 1))
                        selected_countries+=("${all_countries[$country_idx]}")
                    fi
                done
                
                if [ ${#selected_countries[@]} -eq 0 ]; then
                    print_warning "Nenhuma seleção válida. Usando países principais por padrão."
                    selected_countries=("br" "co" "mx")
                else
                    print_info "Contas selecionadas para IAM: ${selected_countries[*]}"
                fi
            fi
            echo ""
        else
            # Modo não-interativo: usar países principais
            selected_countries=("br" "co" "mx")
        fi
        
        for country in "${selected_countries[@]}"; do
            print_info "Verificando IAM para $country..."
            execute_interactive_command "nu sec shared-role-iam show $(whoami) --target-aws-account=$country" \
                "Obtém informações de IAM para o usuário no país $country" \
                20
        done
    else
        print_warning "AVISO: Comandos de IAM são interativos e podem travar o script."
        print_info "Por padrão, o script não executa esses comandos automaticamente."
        print_info "Para habilitar execução automatizada, defina: export TRY_INTERACTIVE=true"
        print_success "Comando de IAM disponível (nu sec shared-role-iam)"
        print_info ""
        print_info "Para verificar suas políticas IAM em cada país, execute manualmente:"
        for country in "${countries[@]}"; do
            print_info "  nu sec shared-role-iam show $(whoami) --target-aws-account=$country"
        done
        print_info ""
        print_info "Exemplo para Brasil:"
        print_info "  nu sec shared-role-iam show $(whoami) --target-aws-account=br"
    fi
    
    print_info ""
    print_info "Informações sobre comandos de Escopos..."
    
    if [ "$try_interactive" = "true" ]; then
        print_info "Tentando verificar escopos (modo automatizado)..."
        
        # Permitir que o usuário escolha quais contas verificar escopos
        local scope_countries_available=("br" "co" "mx")
        local selected_scope_countries=()
        
        if [ -t 0 ]; then  # Modo interativo
            echo ""
            print_info "Selecione quais contas AWS você deseja verificar escopos:"
            echo ""
            echo "0. Todas as contas disponíveis (br, co, mx)"
            local idx=1
            for country in "${scope_countries_available[@]}"; do
                echo "$idx. $country"
                ((idx++))
            done
            echo ""
            read -p "Digite os números separados por vírgula (ex: 1,2) ou 0 para todas: " scope_selection
            
            if [ "$scope_selection" = "0" ] || [ -z "$scope_selection" ]; then
                selected_scope_countries=("${scope_countries_available[@]}")
                print_info "Verificando escopos para todas as contas: ${scope_countries_available[*]}"
            else
                IFS=',' read -ra selections <<< "$scope_selection"
                for sel in "${selections[@]}"; do
                    sel=$(echo "$sel" | tr -d ' ')
                    if [[ "$sel" =~ ^[0-9]+$ ]] && [ "$sel" -ge 1 ] && [ "$sel" -le "${#scope_countries_available[@]}" ]; then
                        local country_idx=$((sel - 1))
                        selected_scope_countries+=("${scope_countries_available[$country_idx]}")
                    fi
                done
                
                if [ ${#selected_scope_countries[@]} -eq 0 ]; then
                    print_warning "Nenhuma seleção válida. Usando todas as contas por padrão."
                    selected_scope_countries=("${scope_countries_available[@]}")
                else
                    print_info "Contas selecionadas para escopos: ${selected_scope_countries[*]}"
                fi
            fi
            echo ""
        else
            # Modo não-interativo: usar todas as contas disponíveis
            selected_scope_countries=("${scope_countries_available[@]}")
        fi
        
        for country in "${selected_scope_countries[@]}"; do
            # Tentar comando nu-<pais> primeiro
            local cmd_base="nu-$country"
            local cmd="$cmd_base sec scope show $(whoami)"
            
            if command -v "$cmd_base" &> /dev/null; then
                execute_interactive_command "$cmd" \
                    "Verifica escopos usando $cmd_base" \
                    20
            else
                print_info "Comando $cmd_base não encontrado, tentando formato alternativo..."
                # Tentar formato alternativo: nu sec scope show --target-aws-account
                execute_interactive_command "nu sec scope show $(whoami) --target-aws-account=$country" \
                    "Verifica escopos para $country usando formato alternativo" \
                    20
            fi
        done
    else
        print_warning "AVISO: Comandos de escopos podem ser interativos e travar o script."
        print_info "Por padrão, o script não executa esses comandos automaticamente."
        print_info "Para habilitar execução automatizada, defina: export TRY_INTERACTIVE=true"
        print_success "Comandos de escopo disponíveis (nu-<pais> sec scope show)"
        print_info ""
        print_info "Para verificar seus escopos em cada país, execute manualmente:"
        
        # Comandos específicos de escopo por país
        scope_commands=(
            "nu-br sec scope show $(whoami)"
            "nu-co sec scope show $(whoami)"
            "nu-mx sec scope show $(whoami)"
        )
        
        for cmd in "${scope_commands[@]}"; do
            print_info "  $cmd"
        done
        
        print_info ""
        print_info "Nota: Se os comandos nu-br, nu-co, nu-mx não estiverem disponíveis,"
        print_info "você pode precisar usar o formato: nu sec scope show <usuario> --target-aws-account=<pais>"
    fi
    
    print_info ""
    print_info "Verificando variável ENG_POLICIES..."
    
    if [ -n "$ENG_POLICIES" ]; then
        print_success "Variável ENG_POLICIES configurada: $ENG_POLICIES"
        execute_command "echo \"\$ENG_POLICIES\"" \
            "Exibe as políticas definidas na variável ENG_POLICIES" \
            "true"
    else
        print_warning "Variável ENG_POLICIES não configurada"
        print_info "Aplicando correção automática..."
        
        # Detectar shell config file
        local shell_config=""
        if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
            shell_config="$HOME/.zshrc"
        elif [ -n "$BASH_VERSION" ]; then
            if [ -f "$HOME/.bash_profile" ]; then
                shell_config="$HOME/.bash_profile"
            elif [ -f "$HOME/.bashrc" ]; then
                shell_config="$HOME/.bashrc"
            fi
        fi
        
        if [ -n "$shell_config" ]; then
            # Verificar se já existe ENG_POLICIES no arquivo
            if ! grep -q "ENG_POLICIES" "$shell_config" 2>/dev/null; then
                # Adicionar com valor padrão (pode ser customizado depois)
                local default_policies="casual-dev,prod-eng"
                execute_command "echo '' >> \"$shell_config\" && echo '# ENG_POLICIES - Configure suas políticas AWS aqui' >> \"$shell_config\" && echo \"export ENG_POLICIES=$default_policies\" >> \"$shell_config\"" \
                    "Adiciona configuração de ENG_POLICIES ao arquivo $shell_config com valor padrão" \
                    "false"
                
                if [ $? -eq 0 ]; then
                    print_success "Variável ENG_POLICIES configurada automaticamente em $shell_config"
                    print_info "Valor padrão: $default_policies"
                    print_info "Para personalizar, edite: $shell_config"
                    print_info "Para aplicar agora: source $shell_config"
                    
                    # Tentar carregar no shell atual
                    export ENG_POLICIES="$default_policies"
                    print_success "ENG_POLICIES carregada na sessão atual: $ENG_POLICIES"
                else
                    print_error "Falha ao configurar ENG_POLICIES automaticamente"
                    print_info "Configure manualmente: echo 'export ENG_POLICIES=<policy-names>' >> $shell_config"
                fi
            else
                print_info "ENG_POLICIES já existe em $shell_config mas não está carregada"
                print_info "Para carregar: source $shell_config"
            fi
        else
            print_warning "Não foi possível detectar arquivo de configuração do shell"
            print_info "Configure manualmente:"
            print_info "  echo 'export ENG_POLICIES=casual-dev,prod-eng' >> ~/.zshrc"
            print_info "  source ~/.zshrc"
        fi
    fi
    
    print_info "Verificando aliases configurados..."
    
    # Verificar aliases comuns
    if alias | grep -q "aws-br"; then
        print_success "Aliases AWS encontrados"
        execute_command "alias | grep aws-br" \
            "Lista aliases AWS configurados" \
            "true"
    else
        print_info "Nenhum alias AWS encontrado"
        print_info "Para criar alias: alias aws-br-refresh=\"nu aws shared-role-credentials refresh --account-alias br --keep-policies=\$ENG_POLICIES\""
    fi
}

# Diagnóstico específico: Erro de Perfil br-prod no NuCLI
diagnose_br_prod_profile_error() {
    print_header "Diagnóstico: Erro de Perfil br-prod no NuCLI"
    
    print_info "Verificando se o perfil br-prod está configurado..."
    
    # Verificar se o arquivo .aws/config existe e contém br-prod
    local aws_config_file="$HOME/.aws/config"
    local br_prod_found=false
    
    if [ -f "$aws_config_file" ]; then
        if grep -q "\[profile br-prod\]" "$aws_config_file" 2>/dev/null || grep -q "\[br-prod\]" "$aws_config_file" 2>/dev/null; then
            print_success "Perfil br-prod encontrado no arquivo de configuração"
            br_prod_found=true
        else
            print_warning "Perfil br-prod NÃO encontrado no arquivo de configuração"
        fi
    else
        print_warning "Arquivo de configuração AWS não encontrado: $aws_config_file"
    fi
    
    if [ "$br_prod_found" = "false" ]; then
        print_error "Problema detectado: Perfil br-prod não encontrado"
        echo ""
        print_info "Soluções recomendadas:"
        echo ""
        print_info "1. Request Access:"
        print_info "   - Shared br role: https://nubank.atlassian.net/servicedesk/customer/portal/131/group/679/create/9937"
        print_info "   - Admin scope in ist: Request via Ask Nu"
        echo ""
        print_info "2. Refresh Credentials (modo interativo):"
        print_info "   nu aws shared-role-credentials refresh -i"
        echo ""
        print_info "3. Authenticate with CodeArtifact:"
        print_info "   nu codeartifact login maven"
        echo ""
        print_info "🔧 Authentication Troubleshooting:"
        print_info "   Se os erros de autenticação persistirem:"
        echo ""
        print_info "4. Reset as credenciais AWS:"
        print_info "   nu aws credentials reset"
        echo ""
        print_info "5. Atualize as credenciais para a conta BR:"
        print_info "   nu aws shared-role-credentials refresh --account-alias=br"
        echo ""
        print_info "6. Continuous Use and Policy Management (atalho):"
        print_info "   nu aws shared-role-credentials refresh --account-alias=br && nu codeartifact login maven"
        echo ""
        print_info "7. Para manter políticas específicas durante a atualização:"
        print_info "   nu aws shared-role-credentials refresh --account-alias=br --keep-policies=casual-dev,eng,eng-prod-engineering,prod-eng"
        echo ""
        print_info "8. Se necessário, deletar e recriar configuração:"
        print_info "   Deletar pasta .aws inteira:"
        print_info "   rm -rf ~/.aws"
        print_info "   OU apenas o arquivo config:"
        print_info "   rm ~/.aws/config"
        print_info "   Depois executar:"
        print_info "   nu aws profiles-config setup"
        print_info "   nu aws credentials setup"
        print_info "   nu aws credentials refresh"
        echo ""
        print_info "9. Verificar se tem todos os grupos eng e casual-dev e roles br necessários antes de realizar o processo."
        
        register_command_needs_action "nu aws shared-role-credentials refresh -i" "Perfil br-prod não encontrado - requer refresh de credenciais"
        return 1
    fi
    
    return 0
}

# Diagnóstico específico: Erro "Unable to retrieve nucli version"
diagnose_nucli_update_error() {
    print_header "Diagnóstico: Erro 'Unable to retrieve nucli version'"
    
    print_info "Verificando conectividade para atualização do NuCLI..."
    
    # Verificar VPN/Network
    print_info "Verificando conectividade de rede..."
    
    execute_command "ping -c 1 8.8.8.8" \
        "Testa conectividade básica de rede" \
        "false"
    
    if [ $? -ne 0 ]; then
        print_error "Problema: Sem conectividade de rede básica"
        print_warning "Soluções recomendadas:"
        echo ""
        print_info "1. VPN Check: Ligue serviços de VPN (GlobalProtect ou Zscaler)"
        print_info "2. Office Network: Se estiver no escritório, certifique-se de estar conectado à rede nubank-office"
        echo ""
        register_command_needs_action "Verificar VPN/Network" "Sem conectividade - verifique VPN ou rede do escritório"
        return 1
    fi
    
    # Tentar executar nu update para verificar erro específico
    if command -v nu &> /dev/null; then
        print_info "Testando comando 'nu update'..."
        
        execute_command "nu update 2>&1 | head -20" \
            "Testa se o comando nu update funciona corretamente" \
            "true"
        
        local update_output=$(nu update 2>&1)
        if echo "$update_output" | grep -qi "Unable to retrieve nucli version\|unable to retrieve\|version.*not found"; then
            print_error "Erro detectado: 'Unable to retrieve nucli version'"
            echo ""
            print_warning "Soluções recomendadas:"
            echo ""
            print_info "1. VPN Check: Ligue serviços de VPN (GlobalProtect ou Zscaler)"
            print_info "2. Office Network: Se estiver no escritório, certifique-se de estar conectado à rede nubank-office"
            echo ""
            register_command_needs_action "nu update" "Erro ao recuperar versão - verifique VPN/rede"
            return 1
        fi
    fi
    
    return 0
}

# Diagnóstico específico: Erro "GNU version of chcon was not found"
diagnose_chcon_error() {
    print_header "Diagnóstico: Erro 'GNU version of chcon was not found'"
    
    print_info "Verificando repositório NuCLI..."
    
    # Verificar se o diretório nucli existe
    local nucli_dir="${NU_HOME:-$HOME/dev/nu}/nucli"
    
    if [ ! -d "$nucli_dir" ]; then
        print_warning "Diretório NuCLI não encontrado: $nucli_dir"
        print_info "Soluções recomendadas:"
        echo ""
        print_info "1. Vá para o diretório do NuCLI:"
        print_info "   cd ~/dev/nu/nucli"
        echo ""
        print_info "2. Atualize o repositório:"
        print_info "   git pull --rebase"
        echo ""
        return 1
    fi
    
    print_info "Diretório NuCLI encontrado: $nucli_dir"
    
    # Verificar se é um repositório git
    if [ -d "$nucli_dir/.git" ]; then
        print_info "Verificando status do repositório git..."
        
        execute_command "cd \"$nucli_dir\" && git status --short 2>&1 | head -10" \
            "Verifica o status do repositório git do NuCLI" \
            "true"
        
        print_info "Soluções recomendadas se o erro persistir:"
        echo ""
        print_info "1. Vá para o diretório do NuCLI:"
        print_info "   cd ~/dev/nu/nucli"
        echo ""
        print_info "2. Atualize o repositório:"
        print_info "   git pull --rebase"
        echo ""
        print_info "3. Se o problema persistir, apagar pasta do nucli e reclonar:"
        print_info "   rm -rf \"\${NU_HOME:-~/dev/nu}/nucli/\""
        print_info "   git clone git@github.com:nubank/nucli.git \"\${NU_HOME:-~/dev/nu}/nucli/\""
        echo ""
    else
        print_warning "Diretório não é um repositório git válido"
    fi
    
    return 0
}

# Diagnóstico específico: Erro "Step-up authentication is not supported when using the --force_classic parameter"
diagnose_stepup_auth_error() {
    print_header "Diagnóstico: Erro 'Step-up authentication is not supported when using --force_classic'"
    
    print_info "Verificando configuração de autenticação..."
    
    # Verificar se gimme-aws-creds está instalado
    local gimme_paths=("/opt/homebrew/bin/gimme-aws-creds" "/usr/local/bin/gimme-aws-creds" "$(command -v gimme-aws-creds)")
    local gimme_found=false
    
    for path in "${gimme_paths[@]}"; do
        if [ -f "$path" ] || command -v "$path" &> /dev/null; then
            print_success "gimme-aws-creds encontrado: $path"
            gimme_found=true
            break
        fi
    done
    
    if [ "$gimme_found" = "false" ]; then
        print_warning "gimme-aws-creds não encontrado"
        print_info "Solução: brew install gimme-aws-creds"
    fi
    
    # Verificar arquivo de configuração Okta
    local okta_config="$HOME/.okta_aws_login_config"
    if [ -f "$okta_config" ]; then
        print_info "Arquivo de configuração Okta encontrado"
        
        if grep -q "^[^#]*preferred_mfa_type" "$okta_config" 2>/dev/null; then
            print_warning "Configuração preferred_mfa_type encontrada (pode causar problemas)"
            print_info "Solução recomendada:"
            echo ""
            print_info "Editar configuração do Okta:"
            print_info "   gsed -i 's/^[^#]*preferred_mfa_type/#&/' ~/.okta_aws_login_config"
            echo ""
        fi
    else
        print_info "Arquivo de configuração Okta não encontrado (será criado na primeira execução)"
    fi
    
    echo ""
    print_info "Soluções completas para este erro:"
    echo ""
    print_info "1. Pré-requisitos:"
    print_info "   - Solicite AWS roles necessárias e scope admin para conta ist"
    print_info "   - Via Identity Hub ou Slack AskNu"
    echo ""
    print_info "2. Atualize o NuCLI:"
    print_info "   nu update"
    echo ""
    print_info "3. Reset e Configure Credentials:"
    print_info "   nu aws credentials reset"
    print_info "   nu aws credentials setup"
    echo ""
    print_info "4. Autentique no CodeArtifact:"
    print_info "   nu codeartifact login maven"
    echo ""
    print_info "5. Autentique no CodeArtifact:"
    print_info "   nu codeartifact login maven"
    echo ""
    print_info "6. Verifique Autenticadores Okta:"
    print_info "   /opt/homebrew/bin/gimme-aws-creds --action-setup-fido-authenticator"
    echo ""
    print_info "7. Se necessário, reinstale o gimme-aws-creds:"
    print_info "   brew install gimme-aws-creds"
    echo ""
    print_info "8. Edite a Configuração do Okta:"
    print_info "   gsed -i 's/^[^#]*preferred_mfa_type/#&/' ~/.okta_aws_login_config"
    echo ""
    print_info "9. Refresh Final:"
    print_info "   nu aws shared-role-credentials refresh --account-alias=br && nu codeartifact login maven"
    echo ""
    print_info "10. Configure Profiles:"
    print_info "    nu aws profiles-config setup"
    echo ""
    print_warning "⚠️ Importante:"
    print_info "   - Certifique-se de ter sua biometria (fingerprint) registrada no Okta antes de prosseguir"
    print_info "   - Em caso de erro de autenticação, resete os autenticadores e registre-se novamente no Okta antes de seguir os passos"
    echo ""
    
    register_command_needs_action "nu aws credentials reset && nu aws credentials setup" "Erro de step-up authentication - requer reset de credenciais"
    
    return 0
}

# Diagnóstico específico: Erro "br prod not found" e "Missing Groups"
diagnose_br_prod_groups_error() {
    print_header "Diagnóstico: Erro 'br group not found'"
    
    echo ""
    print_info "═══════════════════════════════════════════════════════════════"
    print_info "CHECKLIST DE SOLUÇÃO PARA ERRO BR GROUP NOT FOUND"
    print_info "═══════════════════════════════════════════════════════════════"
    echo ""
    
    # Passo 1: Verificar se possui o papel correto
    print_info "PASSO 1: Verificar acesso à conta AWS 'br'"
    echo ""
    print_warning "Confirme se você possui o papel (role) correto na conta AWS 'br'."
    echo ""
    print_info "Se você NÃO possui acesso, solicite através de:"
    print_info "  → AWS Request access / Add role"
    print_info "  → Portal: https://nubank.atlassian.net/servicedesk/customer/portal/131"
    echo ""
    print_info "Instruções para solicitar:"
    print_info "  1. Abra o Slack e procure por 'asknu'"
    print_info "  2. Escreva: 'quero a shared role na conta br para acesso ao nucli'"
    print_info "  3. Aguarde aprovação antes de continuar"
    echo ""
    
    read -p "Você JÁ possui o role na conta 'br'? (s/n): " tem_role
    if [[ ! "$tem_role" =~ ^[sS]$ ]]; then
        print_warning "Por favor, solicite o acesso conforme as instruções acima antes de prosseguir."
        print_info "Após obter o acesso, execute este diagnóstico novamente."
        return 1
    fi
    
    echo ""
    print_success "Ótimo! Vamos configurar suas credenciais."
    echo ""
    
    # Passo 2: Obter informações do usuário
    print_info "═══════════════════════════════════════════════════════════════"
    print_info "PASSO 2: Configuração do usuário IAM"
    print_info "═══════════════════════════════════════════════════════════════"
    echo ""
    
    local iam_user=""
    local is_partner=""
    
    print_info "Você é parceiro da Nubank (terceiro/empresa externa)?"
    read -p "Resposta (s/n): " is_partner
    echo ""
    
    if [[ "$is_partner" =~ ^[sS]$ ]]; then
        print_info "Como parceiro, seu usuário deve seguir o formato: nome.sobrenome.empresa"
        print_info "Exemplo: joao.silva.accenture"
    else
        print_info "Como colaborador Nubank, seu usuário deve seguir o formato: nome.sobrenome"
        print_info "Exemplo: joao.silva"
    fi
    echo ""
    
    read -p "Digite seu usuário IAM (firstname.lastname ou firstname.lastname.empresa): " iam_user
    
    # Validar formato do usuário
    if [[ ! "$iam_user" =~ ^[a-z]+\.[a-z]+(\.[a-z]+)?$ ]]; then
        print_error "Formato de usuário inválido!"
        print_info "Use apenas letras minúsculas e pontos, no formato:"
        print_info "  - nome.sobrenome (colaborador)"
        print_info "  - nome.sobrenome.empresa (parceiro)"
        return 1
    fi
    
    echo ""
    print_success "Usuário IAM configurado: $iam_user"
    echo ""
    
    # Passo 3: Executar comandos de configuração
    print_info "═══════════════════════════════════════════════════════════════"
    print_info "PASSO 3: Executando comandos de configuração"
    print_info "═══════════════════════════════════════════════════════════════"
    echo ""
    
    print_warning "Os comandos serão executados um por vez."
    print_warning "Aguarde a conclusão de cada comando antes de prosseguir."
    echo ""
    
    # Comando 1: Reset das credenciais
    print_info "Comando 1/7: Resetar credenciais AWS"
    print_info "  → nu aws credentials reset --force"
    echo ""
    read -p "Pressione ENTER para executar... "
    
    if nu aws credentials reset --force; then
        print_success "✓ Credenciais resetadas com sucesso"
    else
        print_error "✗ Erro ao resetar credenciais"
        print_warning "Continuando mesmo assim..."
    fi
    echo ""
    
    # Comando 2: Configurar arquivo iam_user
    print_info "Comando 2/7: Configurar arquivo iam_user"
    print_info "  → echo \"$iam_user\" > ~/dev/nu/.nu/about/me/iam_user"
    echo ""
    read -p "Pressione ENTER para executar... "
    
    # Criar diretório se não existir
    mkdir -p ~/dev/nu/.nu/about/me
    
    if echo "$iam_user" > ~/dev/nu/.nu/about/me/iam_user; then
        print_success "✓ Arquivo iam_user configurado"
        print_info "  Localização: ~/dev/nu/.nu/about/me/iam_user"
        print_info "  Conteúdo: $iam_user"
    else
        print_error "✗ Erro ao configurar iam_user"
        return 1
    fi
    echo ""
    
    # Comando 3: Setup das credenciais
    print_info "Comando 3/7: Configurar credenciais AWS"
    print_info "  → nu aws credentials setup"
    echo ""
    read -p "Pressione ENTER para executar... "
    
    if nu aws credentials setup; then
        print_success "✓ Credenciais configuradas"
    else
        print_error "✗ Erro ao configurar credenciais"
        print_warning "Continuando mesmo assim..."
    fi
    echo ""
    
    # Comando 4: Okta login config
    print_info "Comando 4/7: Configurar Okta login"
    print_info "  → nu aws okta-login-config setup"
    echo ""
    read -p "Pressione ENTER para executar... "
    
    if nu aws okta-login-config setup; then
        print_success "✓ Okta login configurado"
    else
        print_error "✗ Erro ao configurar Okta login"
        print_warning "Continuando mesmo assim..."
    fi
    echo ""
    
    # Comando 5: Profiles config
    print_info "Comando 5/7: Configurar perfis AWS"
    print_info "  → nu aws profiles-config setup"
    echo ""
    read -p "Pressione ENTER para executar... "
    
    if nu aws profiles-config setup; then
        print_success "✓ Perfis AWS configurados"
    else
        print_error "✗ Erro ao configurar perfis"
        print_warning "Continuando mesmo assim..."
    fi
    echo ""
    
    # Comando 6: Shared role credentials refresh
    print_info "Comando 6/7: Atualizar shared role credentials para conta 'br'"
    print_info "  → nu aws shared-role-credentials refresh --account-alias=br"
    echo ""
    read -p "Pressione ENTER para executar... "
    
    if nu aws shared-role-credentials refresh --account-alias=br; then
        print_success "✓ Shared role credentials atualizadas para conta 'br'"
    else
        print_error "✗ Erro ao atualizar shared role credentials"
        print_warning "Verifique se você tem as permissões necessárias"
    fi
    echo ""
    
    # Comando 7: CodeArtifact login
    print_info "Comando 7/7: Configurar CodeArtifact Maven"
    print_info "  → nu codeartifact login maven"
    echo ""
    read -p "Pressione ENTER para executar... "
    
    if nu codeartifact login maven; then
        print_success "✓ CodeArtifact configurado"
    else
        print_error "✗ Erro ao configurar CodeArtifact"
        print_warning "Isso pode indicar problemas com Java/JDK"
    fi
    echo ""
    
    # Verificar se há erro relacionado ao Java
    print_info "═══════════════════════════════════════════════════════════════"
    print_info "VERIFICAÇÃO: Java/JDK"
    print_info "═══════════════════════════════════════════════════════════════"
    echo ""
    
    if ! command -v java &> /dev/null; then
        print_error "Java não está instalado!"
        echo ""
        print_info "Se você viu erros relacionados ao Java/JDK, instale o Temurin:"
        print_info "  → brew install --cask temurin"
        echo ""
        print_info "Após instalar, execute novamente os comandos acima."
        echo ""
        read -p "Deseja instalar o Temurin agora? (s/n): " install_java
        
        if [[ "$install_java" =~ ^[sS]$ ]]; then
            print_info "Instalando Temurin..."
            if brew install --cask temurin; then
                print_success "✓ Temurin instalado com sucesso"
                print_info "Execute este diagnóstico novamente para reconfigurar."
            else
                print_error "✗ Erro ao instalar Temurin"
                print_info "Tente instalar manualmente: brew install --cask temurin"
            fi
        fi
    else
        local java_version=$(java -version 2>&1 | head -1)
        print_success "✓ Java instalado: $java_version"
    fi
    echo ""
    
    # Verificação final
    print_info "═══════════════════════════════════════════════════════════════"
    print_info "VERIFICAÇÃO FINAL"
    print_info "═══════════════════════════════════════════════════════════════"
    echo ""
    
    print_info "Verificando arquivo iam_user..."
    if [ -f ~/dev/nu/.nu/about/me/iam_user ]; then
        local arquivo_content=$(cat ~/dev/nu/.nu/about/me/iam_user)
        print_success "✓ Arquivo iam_user existe"
        print_info "  Conteúdo: $arquivo_content"
        
        if [ "$arquivo_content" = "$iam_user" ]; then
            print_success "✓ Conteúdo correto!"
        else
            print_warning "⚠ Conteúdo diferente do esperado"
            print_info "  Esperado: $iam_user"
            print_info "  Encontrado: $arquivo_content"
        fi
    else
        print_error "✗ Arquivo iam_user não encontrado"
        print_info "  Crie manualmente: echo \"$iam_user\" > ~/dev/nu/.nu/about/me/iam_user"
    fi
    echo ""
    
    # Respostas prontas e links úteis
    print_info "═══════════════════════════════════════════════════════════════"
    print_info "RESPOSTAS PRONTAS E LINKS ÚTEIS"
    print_info "═══════════════════════════════════════════════════════════════"
    echo ""
    
    print_info "1. Sempre execute o reset e setup das credenciais antes de tentar novamente."
    echo ""
    
    print_info "2. Se não possuir o role, solicite pelo portal:"
    print_info "   → https://nubank.atlassian.net/servicedesk/customer/portal/131"
    echo ""
    
    print_info "3. Para roles compartilhadas, consulte o guia oficial:"
    print_info "   → https://nubank.atlassian.net/wiki/spaces/SECENG/pages/263220954522/User+Guide+-+Accessing+AWS+via+User+Shared+Roles"
    echo ""
    
    print_info "4. Documentação AWS Request access:"
    print_info "   → https://nubank.atlassian.net/wiki/spaces/SECENG/pages/263220954522/"
    echo ""
    
    print_success "Configuração concluída!"
    echo ""
    print_info "Se ainda houver problemas:"
    print_info "  • Execute: nu doctor"
    print_info "  • Verifique os logs de erro específicos"
    print_info "  • Contate o suporte através do @AskNu no Slack"
    echo ""
    
    return 0
        print_info "   rm -rf ~/.aws"
        print_info "   OU apenas o arquivo config:"
        print_info "   rm ~/.aws/config"
        print_info "   Executar eng setup 2 novamente no eng self service"
        echo ""
        print_info "6. Instalar Java (necessário para ler shared roles):"
        print_info "   brew install --cask temurin"
        echo ""
        print_info "7. Refresh roles:"
        print_info "   nu aws shared-role-credentials refresh -i && nu codeartifact login maven"
        echo ""
        print_info "8. Verificar grupos:"
        print_info "   nu sec shared-role-iam show <username> --target-aws-account=<account-alias>"
        echo ""
        print_info "9. Para problemas de acesso S3 e assuntos de dev:"
        print_info "    https://nubank.atlassian.net/servicedesk/customer/portal/4/group/3525"
        echo ""
        
        register_command_needs_action "nu aws credentials reset && nu aws credentials setup" "Grupos ou perfil br-prod faltando - requer reset de credenciais"
        
        # Verificar PATH do Homebrew para zsh
        if [ -n "$ZSH_VERSION" ]; then
            print_info ""
            print_info "Adendo para quem usa Zsh (macOS com Homebrew):"
            print_info "Se o problema persistir, exporte o PATH do Homebrew:"
            print_info "   echo 'export PATH=\"/opt/homebrew/bin:\$PATH\"' >> ~/.zprofile"
            print_info "   Reinicie o terminal ou recarregue: source ~/.zprofile"
        fi
        
        return 1
    fi
    
    return 0
}

# Diagnóstico específico: Erro de versão antiga do Bash
diagnose_bash_version_error() {
    print_header "Diagnóstico: Erro 'Your Bash version is ancient'"
    
    print_info "Verificando versão do Bash..."
    
    local bash_version=$(bash --version 2>&1 | head -1)
    print_info "Versão do Bash: $bash_version"
    
    # Extrair número da versão
    local version_num=$(bash --version 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    
    if [ -n "$version_num" ]; then
        local major=$(echo "$version_num" | cut -d. -f1)
        local minor=$(echo "$version_num" | cut -d. -f2)
        
        if [ "$major" -lt 4 ] || ([ "$major" -eq 3 ] && [ "$minor" -lt 2 ]); then
            print_error "Versão antiga do Bash detectada: $version_num"
            print_warning "Versão mínima recomendada: 3.2.57 ou superior"
            echo ""
            print_info "Solução:"
            print_info "Este problema foi discutido e resolvido no Slack."
            print_info "Procure por informações atualizadas no link fornecido na documentação."
            echo ""
            print_info "Link para Thread no Slack: (consulte a documentação para o link atualizado)"
            echo ""
            print_info "Soluções comuns:"
            print_info "1. Atualizar Bash via Homebrew:"
            print_info "   brew install bash"
            print_info "   echo '/opt/homebrew/bin/bash' | sudo tee -a /etc/shells"
            print_info "   chsh -s /opt/homebrew/bin/bash"
            echo ""
            print_info "2. Usar zsh como shell padrão (macOS):"
            print_info "   chsh -s /bin/zsh"
            echo ""
            
            register_command_needs_action "Atualizar Bash" "Versão antiga do Bash detectada"
            return 1
        else
            print_success "Versão do Bash OK: $version_num"
        fi
    fi
    
    return 0
}

# Diagnóstico de problemas comuns e correção automática
diagnose_common_issues() {
    print_header "Diagnóstico de Problemas Comuns e Correção Automática"
    
    issues_found=0
    issues_fixed=0
    
    print_info "Verificando problemas conhecidos..."
    
    # Verificar NuCLI
    execute_command "command -v nu" \
        "Verifica se o NuCLI está instalado (problema comum: comando não encontrado)" \
        "false"
    
    if [ $? -ne 0 ]; then
        print_error "Problema: NuCLI não instalado"
        print_warning "Correção automática não disponível para instalação do NuCLI"
        print_info "Solução manual: npm install -g @nubank/nucli"
        ((issues_found++))
    fi
    
    # Verificar AWS CLI
    execute_command "command -v aws" \
        "Verifica se o AWS CLI está instalado (problema comum: comando não encontrado)" \
        "false"
    
    if [ $? -ne 0 ]; then
        print_error "Problema: AWS CLI não instalado"
        print_warning "Correção automática não disponível para instalação do AWS CLI"
        print_info "Solução manual: Instale o AWS CLI conforme documentação oficial"
        ((issues_found++))
    fi
    
    # Verificar credenciais AWS
    execute_command "aws sts get-caller-identity" \
        "Verifica se as credenciais AWS são válidas (problema comum: credenciais inválidas)" \
        "false"
    
    if [ $? -ne 0 ]; then
        print_error "Problema: Credenciais AWS inválidas ou não configuradas"
        print_warning "Correção automática não disponível para configuração de credenciais"
        print_info "Solução manual: Execute 'aws configure' para configurar credenciais"
        ((issues_found++))
    fi
    
    # Verificar permissões de arquivos AWS
    aws_creds_file="$HOME/.aws/credentials"
    if [ -f "$aws_creds_file" ]; then
        perms=$(stat -f "%OLp" "$aws_creds_file" 2>/dev/null || stat -c "%a" "$aws_creds_file" 2>/dev/null)
        if [ "$perms" != "600" ] && [ "$perms" != "400" ]; then
            print_warning "Problema: Permissões inseguras no arquivo de credenciais AWS: $perms"
            print_info "Aplicando correção automática..."
            
            execute_command "chmod 600 \"$aws_creds_file\"" \
                "Corrige as permissões do arquivo de credenciais AWS para 600 (mais seguro)" \
                "false"
            
            if [ $? -eq 0 ]; then
                print_success "Permissões corrigidas automaticamente"
                ((issues_fixed++))
            else
                print_error "Falha ao corrigir permissões"
                ((issues_found++))
            fi
        fi
    fi
    
    # Verificar região AWS
    if command -v aws &> /dev/null; then
        aws_region=$(aws configure get region 2>/dev/null)
        if [ -z "$aws_region" ]; then
            print_warning "Problema: Região AWS não configurada"
            print_info "Sugestão: Configure uma região padrão com 'aws configure set region <sua-regiao>'"
            print_info "Regiões comuns: us-east-1, us-west-2, sa-east-1"
            ((issues_found++))
        fi
    fi
    
    # Executar diagnósticos específicos
    echo ""
    print_info "Executando diagnósticos específicos de erros conhecidos..."
    echo ""
    
    # Diagnóstico: Perfil br-prod
    if ! diagnose_br_prod_profile_error; then
        ((issues_found++))
    fi
    
    # Diagnóstico: Nu update error
    if ! diagnose_nucli_update_error; then
        ((issues_found++))
    fi
    
    # Diagnóstico: chcon error
    if ! diagnose_chcon_error; then
        ((issues_found++))
    fi
    
    # Diagnóstico: Step-up authentication
    if ! diagnose_stepup_auth_error; then
        ((issues_found++))
    fi
    
    # Diagnóstico: br-prod e grupos
    if ! diagnose_br_prod_groups_error; then
        ((issues_found++))
    fi
    
    # Diagnóstico: Bash version
    if ! diagnose_bash_version_error; then
        ((issues_found++))
    fi
    
    # Resumo
    echo ""
    if [ $issues_found -eq 0 ]; then
        print_success "Nenhum problema comum detectado"
    else
        print_warning "Foram encontrados $issues_found problema(s)"
        if [ $issues_fixed -gt 0 ]; then
            print_success "$issues_fixed problema(s) corrigido(s) automaticamente"
        fi
    fi
}

# Função auxiliar para escrever linha colorida (para terminal) e sem cor (para arquivo)
write_report_line() {
    local color="$1"
    local text="$2"
    local file="$3"
    
    # Escrever versão sem cor no arquivo (texto limpo)
    echo "$text" >> "$file"
    # Escrever versão colorida no terminal
    echo -e "${color}${text}${NC}"
}

# Gerar relatório final consolidado após diagnóstico completo
generate_final_report() {
    print_header "Gerando Relatório Final de Diagnóstico"
    
    local report_file="nucli-diagnostico-final-$(date +%Y%m%d-%H%M%S).txt"
    
    print_info "Coletando informações do sistema..."
    
    # Criar arquivo vazio primeiro
    > "$report_file"
    
    # Função para escrever seção colorida
    write_section() {
        local title="$1"
        write_report_line "$CYAN" "======================================================================" "$report_file"
        write_report_line "$CYAN" "$title" "$report_file"
        write_report_line "$CYAN" "======================================================================" "$report_file"
        write_report_line "$NC" "" "$report_file"
    }
    
    # Cabeçalho
    write_report_line "$BLUE" "======================================================================" "$report_file"
    write_report_line "$BLUE" "RELATÓRIO FINAL DE DIAGNÓSTICO - NuCLI e AWS" "$report_file"
    write_report_line "$BLUE" "======================================================================" "$report_file"
    write_report_line "$NC" "Gerado em: $(date '+%Y-%m-%d %H:%M:%S')" "$report_file"
    write_report_line "$NC" "Sistema: $(uname -s) $(uname -r)" "$report_file"
    write_report_line "$NC" "Hostname: $(hostname)" "$report_file"
    write_report_line "$NC" "Usuário: $(whoami)" "$report_file"
    write_report_line "$NC" "" "$report_file"
    
    # 1. STATUS DE INSTALAÇÃO
    write_section "1. STATUS DE INSTALAÇÃO"
    
    # NuCLI
    write_report_line "$NC" "NuCLI:" "$report_file"
    if command -v nu &> /dev/null; then
        local nu_version=$(nu --version 2>/dev/null | head -1 || echo "N/A")
        write_report_line "$GREEN" "  [✓] Instalado" "$report_file"
        write_report_line "$NC" "  Versão: $nu_version" "$report_file"
    else
        write_report_line "$RED" "  [✗] NÃO INSTALADO" "$report_file"
        write_report_line "$YELLOW" "  Ação necessária: npm install -g @nubank/nucli" "$report_file"
    fi
    write_report_line "$NC" "" "$report_file"
    
    # AWS CLI
    write_report_line "$NC" "AWS CLI:" "$report_file"
    if command -v aws &> /dev/null; then
        local aws_version=$(aws --version 2>/dev/null || echo "N/A")
        write_report_line "$GREEN" "  [✓] Instalado" "$report_file"
        write_report_line "$NC" "  Versão: $aws_version" "$report_file"
    else
        write_report_line "$RED" "  [✗] NÃO INSTALADO" "$report_file"
        write_report_line "$YELLOW" "  Ação necessária: Instalar AWS CLI" "$report_file"
    fi
    write_report_line "$NC" "" "$report_file"
    
    # 2. CONFIGURAÇÕES AWS
    write_section "2. CONFIGURAÇÕES AWS"
    
    if command -v aws &> /dev/null; then
        if aws sts get-caller-identity &> /dev/null; then
            local aws_account=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "N/A")
            local aws_arn=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null || echo "N/A")
            write_report_line "$GREEN" "Credenciais AWS: [✓] Configuradas e válidas" "$report_file"
            write_report_line "$NC" "  Conta: $aws_account" "$report_file"
            write_report_line "$NC" "  ARN: $aws_arn" "$report_file"
        else
            write_report_line "$RED" "Credenciais AWS: [✗] Não configuradas ou inválidas" "$report_file"
            write_report_line "$YELLOW" "  Ação necessária:" "$report_file"
            write_report_line "$NC" "    1. Configurar credenciais AWS: aws configure" "$report_file"
            write_report_line "$NC" "    2. OU atualizar credenciais NuCLI: nu aws shared-role-credentials refresh -i" "$report_file"
            write_report_line "$NC" "    3. Verificar se está conectado à VPN" "$report_file"
        fi
        
        local aws_region=$(aws configure get region 2>/dev/null)
        if [ -n "$aws_region" ]; then
            write_report_line "$GREEN" "Região AWS: [✓] $aws_region" "$report_file"
        else
            write_report_line "$RED" "Região AWS: [✗] Não configurada" "$report_file"
            write_report_line "$YELLOW" "  Ação necessária:" "$report_file"
            write_report_line "$NC" "    aws configure set region <sua-regiao>" "$report_file"
            write_report_line "$NC" "    Exemplos: us-east-1, sa-east-1, us-west-2" "$report_file"
        fi
    fi
    write_report_line "$NC" "" "$report_file"
    
    # 3. VARIÁVEIS DE AMBIENTE
    write_section "3. VARIÁVEIS DE AMBIENTE"
    
    if [ -n "$ENG_POLICIES" ]; then
        write_report_line "$GREEN" "ENG_POLICIES: [✓] Configurada" "$report_file"
        write_report_line "$NC" "  Valor: $ENG_POLICIES" "$report_file"
    else
        write_report_line "$RED" "ENG_POLICIES: [✗] NÃO CONFIGURADA" "$report_file"
        write_report_line "$YELLOW" "  Ação necessária: export ENG_POLICIES=<policy-names>" "$report_file"
        write_report_line "$YELLOW" "  Exemplo: export ENG_POLICIES=casual-dev,prod-eng" "$report_file"
    fi
    write_report_line "$NC" "" "$report_file"
    
    # 4. PAÍSES/ALIASES DISPONÍVEIS
    write_section "4. PAÍSES/ALIASES DISPONÍVEIS"
    
    local countries=("br" "br-staging" "mx" "ist" "us" "us-staging" "co" "ar")
    for country in "${countries[@]}"; do
        write_report_line "$BLUE" "  - $country" "$report_file"
    done
    write_report_line "$NC" "" "$report_file"
    
    # 5. PERMISSÕES DE ARQUIVOS
    write_section "5. PERMISSÕES DE ARQUIVOS"
    
    local aws_creds_file="$HOME/.aws/credentials"
    if [ -f "$aws_creds_file" ]; then
        local perms=$(stat -f "%OLp" "$aws_creds_file" 2>/dev/null || stat -c "%a" "$aws_creds_file" 2>/dev/null)
        if [ "$perms" = "600" ] || [ "$perms" = "400" ]; then
            write_report_line "$GREEN" "Arquivo de credenciais AWS: [✓] Permissões seguras ($perms)" "$report_file"
        else
            write_report_line "$YELLOW" "Arquivo de credenciais AWS: [⚠] Permissões inseguras ($perms)" "$report_file"
            write_report_line "$YELLOW" "  Ação necessária: chmod 600 $aws_creds_file" "$report_file"
        fi
    else
        write_report_line "$RED" "Arquivo de credenciais AWS: [✗] Não encontrado" "$report_file"
    fi
    write_report_line "$NC" "" "$report_file"
    
    # 6. CONECTIVIDADE
    write_section "6. CONECTIVIDADE"
    
    if ping -c 1 8.8.8.8 &> /dev/null; then
        write_report_line "$GREEN" "Rede: [✓] Conectividade OK" "$report_file"
    else
        write_report_line "$RED" "Rede: [✗] Problemas de conectividade detectados" "$report_file"
    fi
    write_report_line "$NC" "" "$report_file"
    
    # 7. EXECUÇÃO DE COMANDOS E RESULTADOS
    write_section "7. EXECUÇÃO DE COMANDOS E RESULTADOS"
    
    if ! command -v nu &> /dev/null; then
        write_report_line "$YELLOW" "NuCLI não está instalado. Pulando execução de comandos." "$report_file"
    else
        local try_interactive="${TRY_INTERACTIVE:-false}"
        
        # Configurar comando timeout
        local timeout_cmd=""
        if command -v timeout &> /dev/null; then
            timeout_cmd="timeout"
        elif command -v gtimeout &> /dev/null; then
            timeout_cmd="gtimeout"
        fi
        
        # 1. Ver Escopos
        write_report_line "$NC" "Verificando Escopos:" "$report_file"
        local all_scope_countries=("br" "co" "mx")
        local scope_countries=()
        local scope_found=false
        
        # Permitir que o usuário escolha quais contas verificar escopos
        if [ -t 0 ]; then  # Modo interativo
            echo ""
            print_info "Selecione quais contas AWS você deseja verificar escopos no relatório:"
            echo ""
            echo "0. Todas as contas (br, co, mx)"
            local idx=1
            for country in "${all_scope_countries[@]}"; do
                echo "$idx. $country"
                ((idx++))
            done
            echo ""
            read -p "Digite os números separados por vírgula (ex: 1,2) ou 0 para todas: " scope_selection
            
            if [ "$scope_selection" = "0" ] || [ -z "$scope_selection" ]; then
                scope_countries=("${all_scope_countries[@]}")
                print_info "Verificando escopos para todas as contas: ${all_scope_countries[*]}"
            else
                IFS=',' read -ra selections <<< "$scope_selection"
                for sel in "${selections[@]}"; do
                    sel=$(echo "$sel" | tr -d ' ')
                    if [[ "$sel" =~ ^[0-9]+$ ]] && [ "$sel" -ge 1 ] && [ "$sel" -le "${#all_scope_countries[@]}" ]; then
                        local country_idx=$((sel - 1))
                        scope_countries+=("${all_scope_countries[$country_idx]}")
                    fi
                done
                
                if [ ${#scope_countries[@]} -eq 0 ]; then
                    print_warning "Nenhuma seleção válida. Usando todas as contas por padrão."
                    scope_countries=("${all_scope_countries[@]}")
                else
                    print_info "Contas selecionadas para escopos: ${scope_countries[*]}"
                fi
            fi
            echo ""
        else
            # Modo não-interativo: usar todas
            scope_countries=("${all_scope_countries[@]}")
        fi
        
        for country in "${scope_countries[@]}"; do
            write_report_line "$BLUE" "  Escopos para $country:" "$report_file"
            
            # Tentar comando nu-<pais> primeiro
            local scope_cmd="nu-$country sec scope show $(whoami)"
            local scope_output=""
            local scope_exit=1
            
            if command -v "nu-$country" &> /dev/null; then
                if [ -n "$timeout_cmd" ]; then
                    scope_output=$($timeout_cmd 20 bash -c "$scope_cmd" 2>&1)
                    scope_exit=$?
                else
                    scope_output=$(bash -c "$scope_cmd" 2>&1)
                    scope_exit=$?
                fi
            else
                # Tentar formato alternativo
                local alt_cmd="nu sec scope show $(whoami) --target-aws-account=$country"
                if [ -n "$timeout_cmd" ]; then
                    scope_output=$($timeout_cmd 20 bash -c "$alt_cmd" 2>&1)
                    scope_exit=$?
                else
                    scope_output=$(bash -c "$alt_cmd" 2>&1)
                    scope_exit=$?
                fi
            fi
            
            if [ $scope_exit -eq 0 ] && [ -n "$scope_output" ] && ! echo "$scope_output" | grep -qi "error\|failed\|timeout"; then
                write_report_line "$GREEN" "  [✓] Escopos encontrados para $country" "$report_file"
                register_command_success "nu-$country sec scope show $(whoami)" "$(echo "$scope_output" | head -2 | tr '\n' '; ')"
                write_report_line "$NC" "  Resultado:" "$report_file"
                echo "$scope_output" | head -30 | while IFS= read -r line; do
                    write_report_line "$NC" "    $line" "$report_file"
                done
                scope_found=true
            elif [ $scope_exit -eq 124 ]; then
                write_report_line "$YELLOW" "  [⚠] Comando atingiu timeout para $country" "$report_file"
                register_command_needs_action "nu-$country sec scope show $(whoami)" "Timeout - pode precisar de autenticação interativa"
            else
                write_report_line "$YELLOW" "  [⚠] Não foi possível obter escopos para $country (código: $scope_exit)" "$report_file"
                register_command_failed "nu-$country sec scope show $(whoami)" "Código: $scope_exit - pode requerer autenticação"
            fi
            write_report_line "$NC" "" "$report_file"
        done
        
        if [ "$scope_found" = "false" ]; then
            write_report_line "$YELLOW" "  Nenhum escopo foi encontrado ou comandos requerem autenticação interativa" "$report_file"
            write_report_line "$NC" "  Execute manualmente:" "$report_file"
            for country in "${scope_countries[@]}"; do
                write_report_line "$BLUE" "    nu-$country sec scope show $(whoami)" "$report_file"
            done
        fi
        write_report_line "$NC" "" "$report_file"
        
        # 2. Ver Políticas IAM do usuário atual
        write_report_line "$NC" "Verificando Políticas IAM do usuário atual:" "$report_file"
        local current_user=$(whoami)
        write_report_line "$BLUE" "  Usuário: $current_user" "$report_file"
        
        # Permitir que o usuário escolha quais contas verificar IAM
        local all_iam_countries=("br" "br-staging" "co" "mx" "ist" "us" "us-staging" "ar")
        local iam_countries_to_check=()
        local iam_found=false
        
        if [ "$try_interactive" = "true" ] && [ -t 0 ]; then
            echo ""
            print_info "Selecione quais contas AWS você deseja verificar IAM no relatório:"
            echo ""
            echo "0. Todas as contas"
            local idx=1
            for country in "${all_iam_countries[@]}"; do
                echo "$idx. $country"
                ((idx++))
            done
            echo ""
            read -p "Digite os números separados por vírgula (ex: 1,2,3) ou 0 para todas: " iam_selection
            
            if [ "$iam_selection" = "0" ] || [ -z "$iam_selection" ]; then
                iam_countries_to_check=("${all_iam_countries[@]}")
                print_info "Verificando IAM para todas as contas: ${all_iam_countries[*]}"
            else
                IFS=',' read -ra selections <<< "$iam_selection"
                for sel in "${selections[@]}"; do
                    sel=$(echo "$sel" | tr -d ' ')
                    if [[ "$sel" =~ ^[0-9]+$ ]] && [ "$sel" -ge 1 ] && [ "$sel" -le "${#all_iam_countries[@]}" ]; then
                        local country_idx=$((sel - 1))
                        iam_countries_to_check+=("${all_iam_countries[$country_idx]}")
                    fi
                done
                
                if [ ${#iam_countries_to_check[@]} -eq 0 ]; then
                    print_warning "Nenhuma seleção válida. Verificando apenas 'br' por padrão."
                    iam_countries_to_check=("br")
                else
                    print_info "Contas selecionadas para IAM: ${iam_countries_to_check[*]}"
                fi
            fi
            echo ""
        else
            # Modo não-interativo ou try_interactive=false: verificar apenas br
            iam_countries_to_check=("br")
        fi
        
        # Verificar IAM para cada país selecionado
        for country in "${iam_countries_to_check[@]}"; do
            local iam_cmd="nu sec shared-role-iam show $current_user --target-aws-account=$country"
            local iam_output=""
            local iam_exit=1
            
            write_report_line "$BLUE" "  Políticas IAM para $country:" "$report_file"
            write_report_line "$BLUE" "  Comando: $iam_cmd" "$report_file"
            
            if [ "$try_interactive" = "true" ]; then
                if [ -n "$timeout_cmd" ]; then
                    iam_output=$($timeout_cmd 20 bash -c "$iam_cmd" 2>&1)
                    iam_exit=$?
                else
                    iam_output=$(bash -c "$iam_cmd" 2>&1)
                    iam_exit=$?
                fi
                
                # Verificar se o comando foi bem-sucedido e tem conteúdo válido
                if [ $iam_exit -eq 0 ]; then
                    # Verificar se a saída contém informações válidas (não apenas mensagens de erro)
                    if [ -n "$iam_output" ] && ! echo "$iam_output" | grep -qiE "error|Error|ERROR|failed|Failed|not found|não encontrado|timeout|permission denied"; then
                        # Verificar se há conteúdo real (mais que apenas espaços/linhas vazias)
                        local content_lines=$(echo "$iam_output" | grep -v '^[[:space:]]*$' | wc -l | tr -d ' ')
                        if [ "$content_lines" -gt 0 ]; then
                            write_report_line "$GREEN" "  [✓] Políticas IAM encontradas para $country" "$report_file"
                            register_command_success "$iam_cmd" "$(echo "$iam_output" | head -3 | tr '\n' '; ')"
                            write_report_line "$NC" "  Resultado:" "$report_file"
                            echo "$iam_output" | head -50 | while IFS= read -r line; do
                                write_report_line "$NC" "    $line" "$report_file"
                            done
                            iam_found=true
                        else
                            write_report_line "$YELLOW" "  [⚠] Nenhuma política encontrada para $country" "$report_file"
                            register_command_needs_action "$iam_cmd" "Nenhuma política encontrada"
                        fi
                    else
                        write_report_line "$YELLOW" "  [⚠] Não foi possível obter políticas IAM para $country (código: $iam_exit)" "$report_file"
                        register_command_needs_action "$iam_cmd" "Pode requerer autenticação interativa"
                    fi
                elif [ $iam_exit -eq 124 ]; then
                    write_report_line "$YELLOW" "  [⚠] Comando atingiu timeout para $country" "$report_file"
                    register_command_needs_action "$iam_cmd" "Timeout - pode precisar de autenticação interativa"
                else
                    write_report_line "$YELLOW" "  [⚠] Não foi possível obter políticas IAM para $country (código: $iam_exit)" "$report_file"
                    register_command_needs_action "$iam_cmd" "Código de saída: $iam_exit - pode requerer autenticação"
                fi
            else
                # Modo não-interativo: apenas mostrar instruções
                write_report_line "$YELLOW" "  [⚠] Modo interativo desabilitado" "$report_file"
                write_report_line "$NC" "  Execute manualmente:" "$report_file"
                write_report_line "$BLUE" "    $iam_cmd" "$report_file"
                write_report_line "$NC" "  Ou habilite: export TRY_INTERACTIVE=true" "$report_file"
            fi
            write_report_line "$NC" "" "$report_file"
        done
        
        # Se não encontrou nenhuma política e está em modo interativo, oferecer executar para mais países
        if [ "$iam_found" = "false" ] && [ "$try_interactive" = "true" ] && [ -t 0 ]; then
            echo ""
            write_report_line "$NC" "" "$report_file"
            write_report_line "$YELLOW" "  [ℹ] Nenhuma política encontrada. Deseja tentar para outros países?" "$report_file"
            echo ""
            print_info "Países disponíveis: br, co, mx, br-staging, ist, us, us-staging, ar"
            echo ""
            echo "1. Sim, executar para todos os países principais (co, mx)"
            echo "2. Sim, executar para todos os países disponíveis"
            echo "3. Não, apenas mostrar os comandos"
            echo "4. Executar países individualmente"
            echo ""
            read -p "Escolha uma opção (1-4): " countries_option
                            
                            case $countries_option in
                                1)
                                    echo ""
                                    print_info "Executando para países principais: co, mx"
                                    echo ""
                                    local main_countries=("co" "mx")
                                    for country in "${main_countries[@]}"; do
                                        local country_cmd="nu sec shared-role-iam show $current_user --target-aws-account=$country"
                                        echo ""
                                        write_report_line "$BLUE" "  Executando para $country:" "$report_file"
                                        print_info "Comando: $country_cmd"
                                        
                                        local country_output=""
                                        local country_exit=1
                                        if [ -n "$timeout_cmd" ]; then
                                            country_output=$($timeout_cmd 20 bash -c "$country_cmd" 2>&1)
                                            country_exit=$?
                                        else
                                            country_output=$(bash -c "$country_cmd" 2>&1)
                                            country_exit=$?
                                        fi
                                        
                                        if [ $country_exit -eq 0 ] && [ -n "$country_output" ] && ! echo "$country_output" | grep -qiE "error|Error|ERROR|failed|Failed|not found|não encontrado|timeout|permission denied"; then
                                            local country_content_lines=$(echo "$country_output" | grep -v '^[[:space:]]*$' | wc -l | tr -d ' ')
                                            if [ "$country_content_lines" -gt 0 ]; then
                                                write_report_line "$GREEN" "  [✓] Políticas IAM encontradas para $country" "$report_file"
                                                register_command_success "$country_cmd" "$(echo "$country_output" | head -3 | tr '\n' '; ')"
                                                write_report_line "$NC" "  Resultado:" "$report_file"
                                                echo "$country_output" | head -30 | while IFS= read -r line; do
                                                    write_report_line "$NC" "    $line" "$report_file"
                                                done
                                            else
                                                write_report_line "$YELLOW" "  [⚠] Nenhuma política encontrada para $country" "$report_file"
                                                register_command_needs_action "$country_cmd" "Nenhuma política encontrada"
                                            fi
                                        else
                                            write_report_line "$YELLOW" "  [⚠] Não foi possível obter políticas para $country" "$report_file"
                                            register_command_needs_action "$country_cmd" "Pode requerer autenticação interativa"
                                        fi
                                    done
                                    ;;
                                2)
                                    echo ""
                                    print_info "Executando para todos os países disponíveis..."
                                    echo ""
                                    local all_countries=("co" "mx" "br-staging" "ist")
                                    for country in "${all_countries[@]}"; do
                                        local country_cmd="nu sec shared-role-iam show $current_user --target-aws-account=$country"
                                        echo ""
                                        write_report_line "$BLUE" "  Executando para $country:" "$report_file"
                                        print_info "Comando: $country_cmd"
                                        
                                        local country_output=""
                                        local country_exit=1
                                        if [ -n "$timeout_cmd" ]; then
                                            country_output=$($timeout_cmd 20 bash -c "$country_cmd" 2>&1)
                                            country_exit=$?
                                        else
                                            country_output=$(bash -c "$country_cmd" 2>&1)
                                            country_exit=$?
                                        fi
                                        
                                        if [ $country_exit -eq 0 ] && [ -n "$country_output" ] && ! echo "$country_output" | grep -qiE "error|Error|ERROR|failed|Failed|not found|não encontrado|timeout|permission denied"; then
                                            local country_content_lines=$(echo "$country_output" | grep -v '^[[:space:]]*$' | wc -l | tr -d ' ')
                                            if [ "$country_content_lines" -gt 0 ]; then
                                                write_report_line "$GREEN" "  [✓] Políticas IAM encontradas para $country" "$report_file"
                                                register_command_success "$country_cmd" "$(echo "$country_output" | head -3 | tr '\n' '; ')"
                                                write_report_line "$NC" "  Resultado:" "$report_file"
                                                echo "$country_output" | head -30 | while IFS= read -r line; do
                                                    write_report_line "$NC" "    $line" "$report_file"
                                                done
                                            else
                                                write_report_line "$YELLOW" "  [⚠] Nenhuma política encontrada para $country" "$report_file"
                                                register_command_needs_action "$country_cmd" "Nenhuma política encontrada"
                                            fi
                                        else
                                            write_report_line "$YELLOW" "  [⚠] Não foi possível obter políticas para $country" "$report_file"
                                            register_command_needs_action "$country_cmd" "Pode requerer autenticação interativa"
                                        fi
                                    done
                                    ;;
                                4)
                                    echo ""
                                    print_info "Executando países individualmente..."
                                    echo ""
                                    local available_countries=("co" "mx" "br-staging" "ist")
                                    for country in "${available_countries[@]}"; do
                                        local country_cmd="nu sec shared-role-iam show $current_user --target-aws-account=$country"
                                        echo ""
                                        print_info "Deseja executar para $country?"
                                        read -p "Executar para $country? (s/N): " exec_country
                                        if [[ "$exec_country" =~ ^[SsYy]$ ]]; then
                                            write_report_line "$BLUE" "  Executando para $country:" "$report_file"
                                            print_info "Comando: $country_cmd"
                                            
                                            local country_output=""
                                            local country_exit=1
                                            if [ -n "$timeout_cmd" ]; then
                                                country_output=$($timeout_cmd 20 bash -c "$country_cmd" 2>&1)
                                                country_exit=$?
                                            else
                                                country_output=$(bash -c "$country_cmd" 2>&1)
                                                country_exit=$?
                                            fi
                                            
                                            if [ $country_exit -eq 0 ] && [ -n "$country_output" ] && ! echo "$country_output" | grep -qiE "error|Error|ERROR|failed|Failed|not found|não encontrado|timeout|permission denied"; then
                                                local country_content_lines=$(echo "$country_output" | grep -v '^[[:space:]]*$' | wc -l | tr -d ' ')
                                                if [ "$country_content_lines" -gt 0 ]; then
                                                    write_report_line "$GREEN" "  [✓] Políticas IAM encontradas para $country" "$report_file"
                                                    register_command_success "$country_cmd" "$(echo "$country_output" | head -3 | tr '\n' '; ')"
                                                    write_report_line "$NC" "  Resultado:" "$report_file"
                                                    echo "$country_output" | head -30 | while IFS= read -r line; do
                                                        write_report_line "$NC" "    $line" "$report_file"
                                                    done
                                                else
                                                    write_report_line "$YELLOW" "  [⚠] Nenhuma política encontrada para $country" "$report_file"
                                                    register_command_needs_action "$country_cmd" "Nenhuma política encontrada"
                                                fi
                                            else
                                                write_report_line "$YELLOW" "  [⚠] Não foi possível obter políticas para $country" "$report_file"
                                                register_command_needs_action "$country_cmd" "Pode requerer autenticação interativa"
                                            fi
                                        else
                                            print_info "Pulando país: $country"
                                        fi
                                    done
                                    ;;
                                *)
                                    write_report_line "$NC" "  Comandos para outros países:" "$report_file"
                                    write_report_line "$BLUE" "    nu sec shared-role-iam show $current_user --target-aws-account=co" "$report_file"
                                    write_report_line "$BLUE" "    nu sec shared-role-iam show $current_user --target-aws-account=mx" "$report_file"
                                    write_report_line "$BLUE" "    nu sec shared-role-iam show $current_user --target-aws-account=br-staging" "$report_file"
                                    write_report_line "$BLUE" "    nu sec shared-role-iam show $current_user --target-aws-account=ist" "$report_file"
                                    ;;
                            esac
                        else
                            write_report_line "$NC" "" "$report_file"
                            write_report_line "$NC" "  Para verificar políticas em outros países, execute:" "$report_file"
                            write_report_line "$BLUE" "    nu sec shared-role-iam show $current_user --target-aws-account=co" "$report_file"
                            write_report_line "$BLUE" "    nu sec shared-role-iam show $current_user --target-aws-account=mx" "$report_file"
                        fi
        
        if [ "$iam_found" = "false" ] && [ "$try_interactive" = "true" ]; then
            write_report_line "$NC" "" "$report_file"
            write_report_line "$NC" "  Para verificar políticas em outros países, execute:" "$report_file"
            write_report_line "$BLUE" "    nu sec shared-role-iam show $current_user --target-aws-account=co" "$report_file"
            write_report_line "$BLUE" "    nu sec shared-role-iam show $current_user --target-aws-account=mx" "$report_file"
        fi
        write_report_line "$NC" "" "$report_file"
        
        # 3. Refresh Credenciais AWS (interativo)
        write_report_line "$NC" "Refresh Credenciais AWS:" "$report_file"
        write_report_line "$BLUE" "  Comando: nu aws shared-role-credentials refresh -i" "$report_file"
        
        if [ -t 0 ]; then  # Verificar se está em modo interativo
            write_report_line "$YELLOW" "  [ℹ] Este comando requer interação do usuário" "$report_file"
            write_report_line "$NC" "  Deseja executar agora? (s/N): " "$report_file"
            # Não podemos usar read aqui porque estamos escrevendo no arquivo
            # Vamos registrar como precisa de ação e oferecer execução no relatório consolidado
            register_command_needs_action "nu aws shared-role-credentials refresh -i" "Requer interação manual do usuário"
        else
            write_report_line "$YELLOW" "  [ℹ] Modo não-interativo: Execute manualmente quando necessário" "$report_file"
            register_command_needs_action "nu aws shared-role-credentials refresh -i" "Requer interação manual do usuário"
        fi
        write_report_line "$NC" "" "$report_file"
    fi
    
    # 8. ROLES E POLICIES DO USUÁRIO
    write_section "8. ROLES E POLICIES DO USUÁRIO"
    
    print_info "Coletando roles e policies do usuário..."
    
    # Coletar informações de roles e policies
    collect_user_roles_and_policies
    
    local current_user=$(whoami)
    write_report_line "$NC" "Usuário: $current_user" "$report_file"
    write_report_line "$NC" "" "$report_file"
    
    local countries=("br" "br-staging" "co" "mx" "ist" "us" "us-staging" "ar")
    local has_any_info=false
    
    for country in "${countries[@]}"; do
        local roles=$(get_user_role "$country")
        local policies=$(get_user_policy "$country")
        
        if [ -n "$roles" ] && [ "$roles" != "Não disponível" ] && [ "$roles" != "Erro ao coletar (requer autenticação)" ] && [ "$roles" != "Nenhuma role encontrada" ]; then
            has_any_info=true
            write_report_line "$BLUE" "País/Conta: $country" "$report_file"
            
            # Mostrar roles
            if [ -n "$roles" ] && [ "$roles" != "N/A" ]; then
                write_report_line "$GREEN" "  Roles:" "$report_file"
                # Converter ; em quebras de linha e mostrar
                echo "$roles" | tr ';' '\n' | sed 's/^/    /' | while IFS= read -r line; do
                    if [ -n "$line" ] && [ "$line" != " " ]; then
                        write_report_line "$NC" "$line" "$report_file"
                    fi
                done
            fi
            
            # Mostrar policies
            if [ -n "$policies" ] && [ "$policies" != "N/A" ]; then
                write_report_line "$GREEN" "  Policies:" "$report_file"
                # Converter ; em quebras de linha e mostrar
                echo "$policies" | tr ';' '\n' | sed 's/^/    /' | while IFS= read -r line; do
                    if [ -n "$line" ] && [ "$line" != " " ]; then
                        write_report_line "$NC" "$line" "$report_file"
                    fi
                done
            fi
            
            # Se houver output completo, mostrar resumo
            local full_output=$(get_user_role_full "$country")
            if [ -n "$full_output" ] && [ ${#full_output} -gt 100 ]; then
                write_report_line "$NC" "  Detalhes completos (primeiras 20 linhas):" "$report_file"
                echo "$full_output" | head -20 | while IFS= read -r line; do
                    write_report_line "$NC" "    $line" "$report_file"
                done
            fi
            
            write_report_line "$NC" "" "$report_file"
        elif [ "$roles" = "Erro ao coletar (requer autenticação)" ] || [ "$roles" = "Não disponível" ]; then
            write_report_line "$YELLOW" "País/Conta: $country - [⚠] Requer autenticação ou não disponível" "$report_file"
            write_report_line "$NC" "  Execute manualmente: nu sec shared-role-iam show $current_user --target-aws-account=$country" "$report_file"
            write_report_line "$NC" "" "$report_file"
        fi
    done
    
    if [ "$has_any_info" = "false" ]; then
        write_report_line "$YELLOW" "Nenhuma informação de roles/policies foi coletada automaticamente" "$report_file"
        write_report_line "$NC" "Isso pode ocorrer se:" "$report_file"
        write_report_line "$NC" "  - Requer autenticação interativa" "$report_file"
        write_report_line "$NC" "  - NuCLI não está configurado corretamente" "$report_file"
        write_report_line "$NC" "  - Usuário não possui roles/policies configuradas" "$report_file"
        write_report_line "$NC" "" "$report_file"
        write_report_line "$NC" "Para coletar manualmente, execute:" "$report_file"
        for country in "${countries[@]}"; do
            write_report_line "$BLUE" "  nu sec shared-role-iam show $current_user --target-aws-account=$country" "$report_file"
        done
        write_report_line "$NC" "" "$report_file"
    fi
    
    # 9. RESUMO E AÇÕES RECOMENDADAS
    write_section "9. RESUMO E AÇÕES RECOMENDADAS"
    
    local issues_count=0
    local fixes_applied=0
    
    if ! command -v nu &> /dev/null; then
        write_report_line "$RED" "[✗] Instalar NuCLI" "$report_file"
        ((issues_count++))
    fi
    
    if ! command -v aws &> /dev/null; then
        write_report_line "$RED" "[✗] Instalar AWS CLI" "$report_file"
        ((issues_count++))
    fi
    
    if command -v aws &> /dev/null && ! aws sts get-caller-identity &> /dev/null; then
        write_report_line "$RED" "[✗] Configurar credenciais AWS" "$report_file"
        ((issues_count++))
    fi
    
    if [ -z "$ENG_POLICIES" ]; then
        write_report_line "$RED" "[✗] Configurar ENG_POLICIES" "$report_file"
        ((issues_count++))
    else
        write_report_line "$GREEN" "[✓] ENG_POLICIES configurada" "$report_file"
        ((fixes_applied++))
    fi
    
    if [ -f "$aws_creds_file" ]; then
        local perms=$(stat -f "%OLp" "$aws_creds_file" 2>/dev/null || stat -c "%a" "$aws_creds_file" 2>/dev/null)
        if [ "$perms" != "600" ] && [ "$perms" != "400" ]; then
            write_report_line "$YELLOW" "[⚠] Corrigir permissões do arquivo de credenciais" "$report_file"
            ((issues_count++))
        else
            write_report_line "$GREEN" "[✓] Permissões de arquivo OK" "$report_file"
            ((fixes_applied++))
        fi
    fi
    
    write_report_line "$NC" "" "$report_file"
    write_report_line "$NC" "Total de problemas encontrados: $issues_count" "$report_file"
    write_report_line "$NC" "Total de correções aplicadas: $fixes_applied" "$report_file"
    write_report_line "$NC" "" "$report_file"
    
    if [ $issues_count -eq 0 ]; then
        write_report_line "$GREEN" "STATUS GERAL: [✓] Tudo configurado corretamente!" "$report_file"
    else
        write_report_line "$YELLOW" "STATUS GERAL: [⚠] $issues_count problema(s) encontrado(s)" "$report_file"
    fi
    
    write_report_line "$NC" "" "$report_file"
    write_report_line "$BLUE" "======================================================================" "$report_file"
    write_report_line "$BLUE" "FIM DO RELATÓRIO" "$report_file"
    write_report_line "$BLUE" "======================================================================" "$report_file"
    
    execute_command "test -f \"$report_file\"" \
        "Verifica se o arquivo de relatório final foi criado com sucesso" \
        "false"
    
    print_success "Relatório final salvo em: $report_file"
    print_info "Para visualizar: cat $report_file"
    echo ""
    print_info "Relatório já foi exibido acima com cores para facilitar a leitura."
    
    # Gerar relatório consolidado de comandos executados
    generate_consolidated_command_report
}

# Gerar relatório consolidado de todos os comandos executados
generate_consolidated_command_report() {
    print_header "Relatório Consolidado de Comandos Executados"
    
    local consolidated_file="nucli-comandos-executados-$(date +%Y%m%d-%H%M%S).txt"
    > "$consolidated_file"
    
    write_report_line "$BLUE" "======================================================================" "$consolidated_file"
    write_report_line "$BLUE" "RELATÓRIO CONSOLIDADO DE COMANDOS EXECUTADOS" "$consolidated_file"
    write_report_line "$BLUE" "======================================================================" "$consolidated_file"
    write_report_line "$NC" "Gerado em: $(date '+%Y-%m-%d %H:%M:%S')" "$consolidated_file"
    write_report_line "$NC" "" "$consolidated_file"
    
    # Comandos que funcionaram (VERDE)
    if [ ${#COMMAND_SUCCESS[@]} -gt 0 ]; then
        write_report_line "$GREEN" "======================================================================" "$consolidated_file"
        write_report_line "$GREEN" "✓ COMANDOS EXECUTADOS COM SUCESSO (${#COMMAND_SUCCESS[@]})" "$consolidated_file"
        write_report_line "$GREEN" "======================================================================" "$consolidated_file"
        write_report_line "$NC" "" "$consolidated_file"
        
        for item in "${COMMAND_SUCCESS[@]}"; do
            local cmd=$(echo "$item" | cut -d'|' -f1)
            local output=$(echo "$item" | cut -d'|' -f2-)
            write_report_line "$GREEN" "[✓] $cmd" "$consolidated_file"
            if [ -n "$output" ] && [ "$output" != "null" ]; then
                write_report_line "$NC" "   Saída: $(echo "$output" | head -3 | tr '\n' ' ')" "$consolidated_file"
            fi
            write_report_line "$NC" "" "$consolidated_file"
        done
    else
        write_report_line "$YELLOW" "Nenhum comando executado com sucesso registrado" "$consolidated_file"
        write_report_line "$NC" "" "$consolidated_file"
    fi
    
    # Comandos que falharam (VERMELHO)
    if [ ${#COMMAND_FAILED[@]} -gt 0 ]; then
        write_report_line "$RED" "======================================================================" "$consolidated_file"
        write_report_line "$RED" "✗ COMANDOS QUE FALHARAM (${#COMMAND_FAILED[@]})" "$consolidated_file"
        write_report_line "$RED" "======================================================================" "$consolidated_file"
        write_report_line "$NC" "" "$consolidated_file"
        
        for item in "${COMMAND_FAILED[@]}"; do
            local cmd=$(echo "$item" | cut -d'|' -f1)
            local reason=$(echo "$item" | cut -d'|' -f2-)
            write_report_line "$RED" "[✗] $cmd" "$consolidated_file"
            if [ -n "$reason" ] && [ "$reason" != "null" ]; then
                write_report_line "$YELLOW" "   Motivo: $reason" "$consolidated_file"
            fi
            write_report_line "$NC" "" "$consolidated_file"
        done
        
        # Perguntar se o usuário quer tentar executar novamente de forma interativa
        echo ""
        if [ -t 0 ]; then  # Verificar se está em modo interativo
            print_info "Alguns comandos falharam. Deseja tentar executá-los novamente de forma interativa?"
            echo ""
            echo "1. Sim, tentar executar todos os comandos que falharam"
            echo "2. Não, apenas mostrar os comandos"
            echo "3. Tentar executar comandos individualmente"
            echo ""
            read -p "Escolha uma opção (1-3): " retry_option
            
            case $retry_option in
                1)
                    echo ""
                    print_info "Tentando executar comandos que falharam de forma interativa..."
                    echo ""
                    for item in "${COMMAND_FAILED[@]}"; do
                        local cmd=$(echo "$item" | cut -d'|' -f1)
                        local reason=$(echo "$item" | cut -d'|' -f2-)
                        echo ""
                        print_info "Tentando executar: $cmd"
                        print_info "Motivo da falha anterior: $reason"
                        execute_interactive_user_command "$cmd" "Tentativa interativa após falha: $reason"
                    done
                    ;;
                3)
                    echo ""
                    print_info "Tentando executar comandos individualmente..."
                    echo ""
                    local idx=1
                    for item in "${COMMAND_FAILED[@]}"; do
                        local cmd=$(echo "$item" | cut -d'|' -f1)
                        local reason=$(echo "$item" | cut -d'|' -f2-)
                        echo ""
                        print_info "Comando $idx de ${#COMMAND_FAILED[@]}: $cmd"
                        print_info "Motivo da falha: $reason"
                        read -p "Deseja tentar executar este comando novamente? (s/N): " retry_cmd
                        if [[ "$retry_cmd" =~ ^[SsYy]$ ]]; then
                            execute_interactive_user_command "$cmd" "Tentativa interativa após falha: $reason"
                        else
                            print_info "Pulando comando: $cmd"
                        fi
                        ((idx++))
                    done
                    ;;
                *)
                    print_info "Comandos não serão executados novamente."
                    ;;
            esac
        else
            write_report_line "$NC" "Modo não-interativo: Tente executar os comandos manualmente" "$consolidated_file"
        fi
    else
        write_report_line "$GREEN" "Nenhum comando falhou" "$consolidated_file"
        write_report_line "$NC" "" "$consolidated_file"
    fi
    
    # Comandos que precisam de ação do usuário (AMARELO)
    if [ ${#COMMAND_NEEDS_ACTION[@]} -gt 0 ]; then
        write_report_line "$YELLOW" "======================================================================" "$consolidated_file"
        write_report_line "$YELLOW" "⚠ COMANDOS QUE PRECISAM DE AÇÃO DO USUÁRIO (${#COMMAND_NEEDS_ACTION[@]})" "$consolidated_file"
        write_report_line "$YELLOW" "======================================================================" "$consolidated_file"
        write_report_line "$NC" "" "$consolidated_file"
        
        for item in "${COMMAND_NEEDS_ACTION[@]}"; do
            local cmd=$(echo "$item" | cut -d'|' -f1)
            local reason=$(echo "$item" | cut -d'|' -f2-)
            write_report_line "$YELLOW" "[⚠] $cmd" "$consolidated_file"
            if [ -n "$reason" ] && [ "$reason" != "null" ]; then
                write_report_line "$NC" "   Motivo: $reason" "$consolidated_file"
            fi
            write_report_line "$NC" "" "$consolidated_file"
        done
        
        # Perguntar se o usuário quer executar os comandos interativamente
        echo ""
        if [ -t 0 ]; then  # Verificar se está em modo interativo
            print_info "Deseja executar os comandos que precisam de interação agora?"
            echo ""
            echo "1. Sim, executar todos os comandos interativos"
            echo "2. Não, apenas mostrar os comandos"
            echo "3. Executar comandos individualmente"
            echo ""
            read -p "Escolha uma opção (1-3): " exec_option
            
            case $exec_option in
                1)
                    echo ""
                    print_info "Executando todos os comandos interativos..."
                    echo ""
                    # Sempre executar nu update primeiro
                    echo ""
                    print_info "Executando: nu update"
                    execute_interactive_user_command "nu update" "Atualização do NuCLI"
                    echo ""
                    # Depois executar os outros comandos que precisam de ação
                    for item in "${COMMAND_NEEDS_ACTION[@]}"; do
                        local cmd=$(echo "$item" | cut -d'|' -f1)
                        local reason=$(echo "$item" | cut -d'|' -f2-)
                        # Pular nu update se já foi executado acima
                        if [[ "$cmd" != "nu update" ]]; then
                            echo ""
                            execute_interactive_user_command "$cmd" "Execução interativa: $reason"
                        fi
                    done
                    ;;
                3)
                    echo ""
                    print_info "Executando comandos individualmente..."
                    echo ""
                    # Sempre oferecer nu update primeiro
                    echo ""
                    print_info "Comando 1: nu update"
                    read -p "Deseja executar 'nu update' agora? (s/N): " exec_nu_update
                    if [[ "$exec_nu_update" =~ ^[SsYy]$ ]]; then
                        execute_interactive_user_command "nu update" "Atualização do NuCLI"
                    else
                        print_info "Pulando comando: nu update"
                    fi
                    echo ""
                    # Depois executar os outros comandos que precisam de ação
                    local idx=2
                    for item in "${COMMAND_NEEDS_ACTION[@]}"; do
                        local cmd=$(echo "$item" | cut -d'|' -f1)
                        local reason=$(echo "$item" | cut -d'|' -f2-)
                        # Pular nu update se já foi oferecido acima
                        if [[ "$cmd" != "nu update" ]]; then
                            echo ""
                            print_info "Comando $idx de $((${#COMMAND_NEEDS_ACTION[@]} + 1)): $cmd"
                            read -p "Deseja executar este comando agora? (s/N): " exec_cmd
                            if [[ "$exec_cmd" =~ ^[SsYy]$ ]]; then
                                execute_interactive_user_command "$cmd" "Execução interativa: $reason"
                            else
                                print_info "Pulando comando: $cmd"
                            fi
                            ((idx++))
                        fi
                    done
                    ;;
                *)
                    print_info "Comandos não serão executados. Execute manualmente quando necessário."
                    ;;
            esac
        else
            write_report_line "$NC" "Modo não-interativo: Execute os comandos manualmente quando necessário" "$consolidated_file"
        fi
    else
        write_report_line "$GREEN" "Nenhum comando requer ação do usuário" "$consolidated_file"
        write_report_line "$NC" "" "$consolidated_file"
    fi
    
    # Resumo final
    write_report_line "$BLUE" "======================================================================" "$consolidated_file"
    write_report_line "$BLUE" "RESUMO" "$consolidated_file"
    write_report_line "$BLUE" "======================================================================" "$consolidated_file"
    write_report_line "$NC" "" "$consolidated_file"
    write_report_line "$GREEN" "Total de comandos executados com sucesso: ${#COMMAND_SUCCESS[@]}" "$consolidated_file"
    write_report_line "$RED" "Total de comandos que falharam: ${#COMMAND_FAILED[@]}" "$consolidated_file"
    write_report_line "$YELLOW" "Total de comandos que precisam de ação: ${#COMMAND_NEEDS_ACTION[@]}" "$consolidated_file"
    write_report_line "$NC" "" "$consolidated_file"
    
    local total_commands=$((${#COMMAND_SUCCESS[@]} + ${#COMMAND_FAILED[@]} + ${#COMMAND_NEEDS_ACTION[@]}))
    write_report_line "$NC" "Total geral de comandos registrados: $total_commands" "$consolidated_file"
    write_report_line "$NC" "" "$consolidated_file"
    
    write_report_line "$BLUE" "======================================================================" "$consolidated_file"
    write_report_line "$BLUE" "FIM DO RELATÓRIO CONSOLIDADO" "$consolidated_file"
    write_report_line "$BLUE" "======================================================================" "$consolidated_file"
    
    echo ""
    print_success "Relatório consolidado salvo em: $consolidated_file"
    print_info "Para visualizar novamente: cat $consolidated_file"
    echo ""
    print_info "Relatório consolidado já foi exibido acima com cores para facilitar a leitura."
    echo ""
}

# Gerar relatório
generate_report() {
    print_header "Gerando Relatório de Diagnóstico"
    
    report_file="nucli-troubleshoot-detailed-report-$(date +%Y%m%d-%H%M%S).txt"
    
    print_info "Criando arquivo de relatório..."
    
    execute_command "date" \
        "Obtém a data e hora atual para incluir no relatório" \
        "false"
    
    {
        echo "Relatório de Troubleshooting NuCLI e AWS (Versão Detalhada)"
        echo "Gerado em: $(date)"
        echo "=========================================="
        echo ""
        echo "Sistema:"
        echo "  OS: $(uname -s)"
        echo "  Versão: $(uname -r)"
        echo "  Hostname: $(hostname)"
        echo ""
        echo "NuCLI:"
        if command -v nu &> /dev/null; then
            echo "  Instalado: Sim"
            echo "  Versão: $(nu --version 2>/dev/null || echo 'N/A')"
        else
            echo "  Instalado: Não"
        fi
        echo ""
        echo "AWS CLI:"
        if command -v aws &> /dev/null; then
            echo "  Instalado: Sim"
            echo "  Versão: $(aws --version 2>/dev/null || echo 'N/A')"
            if aws sts get-caller-identity &> /dev/null; then
                echo "  Credenciais: OK"
                echo "  Conta: $(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo 'N/A')"
            else
                echo "  Credenciais: Não configuradas ou inválidas"
            fi
        else
            echo "  Instalado: Não"
        fi
        echo ""
        echo "Rede:"
        if ping -c 1 8.8.8.8 &> /dev/null; then
            echo "  Conectividade: OK"
        else
            echo "  Conectividade: Problemas detectados"
        fi
        echo ""
        echo "Países/Aliases Disponíveis:"
        countries=("br" "br-staging" "mx" "ist" "us" "us-staging" "co" "ar")
        for country in "${countries[@]}"; do
            echo "  - $country"
        done
        echo ""
        echo "Variáveis de Ambiente:"
        if [ -n "$ENG_POLICIES" ]; then
            echo "  ENG_POLICIES: $ENG_POLICIES"
        else
            echo "  ENG_POLICIES: Não configurada"
        fi
        echo ""
        echo "=========================================="
        echo "ERROS COMUNS E SOLUÇÕES:"
        echo "=========================================="
        echo ""
        echo "1. Erro de Perfil br-prod no NuCLI:"
        echo "   - Request Access: Shared br role via JIRA Service Desk"
        echo "   - Refresh Credentials: nu aws shared-role-credentials refresh -i"
        echo "   - Authenticate CodeArtifact: nu codeartifact login maven"
        echo "   - Reset: nu aws credentials reset && nu aws credentials setup"
        echo ""
        echo "2. Erro 'Unable to retrieve nucli version':"
        echo "   - VPN Check: Ligue serviços de VPN (GlobalProtect ou Zscaler)"
        echo "   - Office Network: Conecte-se à rede nubank-office"
        echo ""
        echo "3. Erro 'GNU version of chcon was not found':"
        echo "   - cd ~/dev/nu/nucli"
        echo "   - git pull --rebase"
        echo ""
        echo "4. Erro 'Step-up authentication is not supported when using --force_classic':"
        echo "   - nu update"
        echo "   - nu aws credentials reset && nu aws credentials setup"
        echo "   - nu codeartifact login maven"
        echo "   - /opt/homebrew/bin/gimme-aws-creds --action-setup-fido-authenticator"
        echo "   - brew install gimme-aws-creds (se necessário)"
        echo "   - gsed -i 's/^[^#]*preferred_mfa_type/#&/' ~/.okta_aws_login_config"
        echo ""
        echo "5. Erro 'br prod not found' e 'Missing Groups':"
        echo "   - Request BR roles: https://nubank.atlassian.net/servicedesk/customer/portal/131/group/679/create/9937"
        echo "   - Request Groups: https://nubank.atlassian.net/servicedesk/customer/portal/131/group/680/create/2117"
        echo "   - Request admin at ist: Via Ask Nu ou Identity Hub"
        echo "   - nu aws credentials reset && nu aws credentials setup"
        echo "   - nu aws shared-role-credentials refresh --account-alias=br"
        echo "   - rm ~/.aws/config (se necessário)"
        echo "   - brew install --cask temurin (instalar Java)"
        echo ""
        echo "6. Erro 'Your Bash version is ancient':"
        echo "   - Consultar thread no Slack para solução atualizada"
        echo "   - brew install bash (atualizar Bash)"
        echo "   - chsh -s /opt/homebrew/bin/bash (mudar shell)"
        echo ""
        echo "=========================================="
        echo "COMANDOS ÚTEIS DO NUCLI:"
        echo "=========================================="
        echo ""
        echo "CREDENCIAIS AWS:"
        echo "   nu aws shared-role-credentials refresh -i"
        echo "   nu aws shared-role-credentials refresh --account-alias=br"
        echo "   nu aws shared-role-credentials refresh --account-alias=br --keep-policies=casual-dev,eng,eng-prod-engineering,prod-eng"
        echo "   nu aws credentials reset"
        echo "   nu aws credentials setup"
        echo "   nu aws profiles-config setup"
        echo ""
        echo "CODEARTIFACT:"
        echo "   nu codeartifact login maven"
        echo "   nu aws shared-role-credentials refresh --account-alias=br && nu codeartifact login maven"
        echo ""
        echo "ATUALIZAÇÃO:"
        echo "   nu update"
        echo "   cd ~/dev/nu/nucli && git pull --rebase"
        echo "   rm -rf \"\${NU_HOME:-~/dev/nu}/nucli/\""
        echo "   git clone git@github.com:nubank/nucli.git \"\${NU_HOME:-~/dev/nu}/nucli/\""
        echo ""
        echo "VERIFICAÇÃO:"
        echo "   nu sec shared-role-iam show <username> --target-aws-account=<account-alias>"
        echo "   nu-br sec scope show <username>"
        echo "   nu aws shared-role-credentials web-console -i"
        echo ""
        echo "TROUBLESHOOTING:"
        echo "   rm ~/.aws/config"
        echo "   brew install --cask temurin"
        echo "   /opt/homebrew/bin/gimme-aws-creds --action-setup-fido-authenticator"
        echo "   gsed -i 's/^[^#]*preferred_mfa_type/#&/' ~/.okta_aws_login_config"
        echo ""
        echo "=========================================="
        echo "LINKS ÚTEIS:"
        echo "=========================================="
        echo "Request BR Role:"
        echo "   https://nubank.atlassian.net/servicedesk/customer/portal/131/group/679/create/9937"
        echo ""
        echo "Request Groups (casual-dev, eng):"
        echo "   https://nubank.atlassian.net/servicedesk/customer/portal/131/group/680/create/2117"
        echo ""
        echo "Acesso S3:"
        echo "   https://nubank.atlassian.net/servicedesk/customer/portal/4/group/3525"
        echo ""
        echo "Lista de chamados iniciativa:"
        echo "   IT-1073490: Office Tickets - Daniel Fonseca"
        echo ""
        echo "=========================================="
        echo "OBSERVAÇÕES:"
        echo "=========================================="
        echo "- <account-alias> pode ser: br, br-staging, mx, ist, us, us-staging, co, ar"
        echo "- <username> é seu nome de usuário (surname)"
        echo "- <policy-names> é uma lista separada por vírgulas, ex: casual-dev,prod-eng"
        echo "- Para zsh (macOS): export PATH=\"/opt/homebrew/bin:\$PATH\" >> ~/.zprofile"
    } > "$report_file"
    
    execute_command "test -f \"$report_file\"" \
        "Verifica se o arquivo de relatório foi criado com sucesso" \
        "false"
    
    print_success "Relatório salvo em: $report_file"
    print_info "Para visualizar: cat $report_file"
}

# Menu principal
show_menu() {
    echo ""
    print_header "Menu de Troubleshooting (Versão Detalhada)"
    
    # Mostrar status do modo interativo
    if [ "${TRY_INTERACTIVE:-false}" = "true" ]; then
        echo -e "${GREEN}✓ Modo Interativo Automatizado: HABILITADO${NC}"
    else
        echo -e "${YELLOW}⚠ Modo Interativo Automatizado: DESABILITADO${NC}"
        echo -e "${BLUE}   (Para habilitar: export TRY_INTERACTIVE=true)${NC}"
    fi
    echo ""
    
    echo "1. Verificação completa (recomendado)"
    echo "2. Verificar instalação do NuCLI"
    echo "3. Verificar configuração do AWS"
    echo "4. Verificar conectividade de rede"
    echo "5. Verificar variáveis de ambiente"
    echo "6. Verificar permissões de arquivos"
    echo "7. Testar comandos NuCLI"
    echo "8. Testar comandos AWS"
    echo "9. Diagnóstico de problemas comuns"
    echo "10. Verificar roles, escopos e países"
    echo "11. Gerar relatório detalhado"
    echo "12. Gerar relatório final consolidado"
    echo "13. Verificar logs de erro recentes"
    echo "14. Habilitar/Desabilitar modo interativo automatizado"
    echo "15. Diagnóstico: Erro de Perfil br-prod"
    echo "16. Diagnóstico: Erro 'Unable to retrieve nucli version'"
    echo "17. Diagnóstico: Erro 'GNU version of chcon was not found'"
    echo "18. Diagnóstico: Erro 'Step-up authentication not supported'"
    echo "19. Diagnóstico: Erro 'br prod not found' e 'Missing Groups'"
    echo "20. Diagnóstico: Erro 'Bash version is ancient'"
    echo "21. Mostrar comandos úteis"
    echo "22. Cadastrar digital (configurar IAM user e autenticação)"
    echo "0. Sair"
    echo ""
    read -p "Escolha uma opção: " option
    
    case $option in
        1)
            # Executar verificação completa (inclui Java e todas as outras verificações)
            check_complete_verification
            
            echo ""
            generate_final_report
            ;;
        2)
            check_nucli_installation
            ;;
        3)
            check_aws_config
            ;;
        4)
            check_network_connectivity
            ;;
        5)
            check_environment_variables
            ;;
        6)
            check_file_permissions
            ;;
        7)
            test_nucli_commands
            ;;
        8)
            test_aws_commands
            ;;
        9)
            diagnose_common_issues
            ;;
        10)
            check_roles_scopes_countries
            ;;
        11)
            generate_report
            ;;
        12)
            # Limpar arrays de resultados antes de gerar relatório
            COMMAND_SUCCESS=()
            COMMAND_FAILED=()
            COMMAND_NEEDS_ACTION=()
            COMMAND_TO_RETRY=()
            
            # Coletar roles e policies do usuário antes de gerar relatório
            collect_user_roles_and_policies
            
            generate_final_report
            ;;
        13)
            check_recent_errors
            ;;
        14)
            if [ "${TRY_INTERACTIVE:-false}" = "true" ]; then
                export TRY_INTERACTIVE=false
                print_success "Modo interativo automatizado DESABILITADO"
                print_info "Comandos interativos não serão executados automaticamente"
            else
                export TRY_INTERACTIVE=true
                print_success "Modo interativo automatizado HABILITADO"
                print_info "O script tentará executar comandos interativos com timeout"
                print_warning "Alguns comandos podem ainda precisar de interação manual"
            fi
            ;;
        15)
            diagnose_br_prod_profile_error
            ;;
        16)
            diagnose_nucli_update_error
            ;;
        17)
            diagnose_chcon_error
            ;;
        18)
            diagnose_stepup_auth_error
            ;;
        19)
            diagnose_br_prod_groups_error
            ;;
        20)
            diagnose_bash_version_error
            ;;
        21)
            show_useful_commands
            ;;
        22)
            cadastrar_digital
            ;;
        0)
            echo "Saindo..."
            exit 0
            ;;
        *)
            print_error "Opção inválida"
            ;;
    esac
}

# Função principal
main() {
    # Verificar se está sendo executado interativamente
    if [ -t 0 ]; then
        # Modo interativo
        while true; do
            show_menu
            echo ""
            read -p "Pressione Enter para continuar..."
        done
    else
        # Modo não-interativo - executar verificação completa (inclui Java e todas as outras verificações)
        check_complete_verification
        
        echo ""
        generate_final_report
    fi
}

# Executar função principal
main

