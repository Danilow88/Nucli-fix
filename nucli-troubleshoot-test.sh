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

# Função para executar comando e mostrar resultado
execute_command() {
    local cmd="$1"
    local purpose="$2"
    local show_output="${3:-true}"
    
    print_command "$cmd" "$purpose"
    
    if [ "$show_output" = "true" ]; then
        echo -e "${BLUE}📤 Executando...${NC}"
        eval "$cmd"
        local exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            echo -e "${GREEN}✓ Comando executado com sucesso (código: $exit_code)${NC}"
        else
            echo -e "${RED}✗ Comando falhou (código: $exit_code)${NC}"
        fi
        return $exit_code
    else
        eval "$cmd" &> /dev/null
        local exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            echo -e "${GREEN}✓ Comando executado com sucesso (código: $exit_code)${NC}"
        else
            echo -e "${RED}✗ Comando falhou (código: $exit_code)${NC}"
        fi
        return $exit_code
    fi
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
        
        execute_command "nu --version" \
            "Obtém a versão do NuCLI instalado, incluindo informações de commit e data" \
            "true"
        
        nucli_version=$(nu --version 2>/dev/null || echo "versão não disponível")
        print_info "Versão: $nucli_version"
        return 0
    else
        print_error "NuCLI não está instalado"
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
        
        execute_command "aws --version" \
            "Exibe a versão do AWS CLI instalado, incluindo versão do Python e sistema operacional" \
            "true"
        
        aws_version=$(aws --version 2>/dev/null)
        print_info "$aws_version"
        
        print_info "Verificando se as credenciais AWS estão configuradas corretamente..."
        
        execute_command "aws sts get-caller-identity" \
            "Verifica se as credenciais AWS são válidas obtendo informações da identidade do chamador (conta, usuário, ARN)" \
            "false"
        
        if [ $? -eq 0 ]; then
            print_success "Credenciais AWS configuradas corretamente"
            
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
    echo "1. Verificação completa (recomendado)"
    echo "2. Verificar instalação do NuCLI"
    echo "3. Verificar configuração do AWS"
    echo "4. Verificar conectividade de rede"
    echo "5. Verificar variáveis de ambiente"
    echo "6. Verificar permissões de arquivos"
    echo "7. Testar comandos NuCLI"
    echo "8. Testar comandos AWS"
    echo "9. Diagnóstico de problemas comuns"
    echo "10. Gerar relatório"
    echo "11. Verificar logs de erro recentes"
    echo "0. Sair"
    echo ""
    read -p "Escolha uma opção: " option
    
    case $option in
        1)
            check_nucli_installation
            check_aws_config
            check_network_connectivity
            check_environment_variables
            check_file_permissions
            test_nucli_commands
            test_aws_commands
            diagnose_common_issues
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
            generate_report
            ;;
        11)
            check_recent_errors
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
        # Modo não-interativo - executar verificação completa
        check_nucli_installation
        check_aws_config
        check_network_connectivity
        check_environment_variables
        check_file_permissions
        test_nucli_commands
        test_aws_commands
        diagnose_common_issues
        generate_report
    fi
}

# Executar função principal
main

