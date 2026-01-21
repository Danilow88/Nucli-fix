#!/bin/bash

# Script de Troubleshooting para NuCLI e AWS
# Baseado no documento de troubleshooting NuCLI and AWS Errors

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Verificar se o NuCLI está instalado
check_nucli_installation() {
    print_header "Verificando instalação do NuCLI"
    
    if command -v nu &> /dev/null; then
        print_success "NuCLI está instalado"
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
    
    if command -v aws &> /dev/null; then
        print_success "AWS CLI está instalado"
        aws_version=$(aws --version 2>/dev/null)
        print_info "$aws_version"
        
        # Verificar credenciais
        if aws sts get-caller-identity &> /dev/null; then
            print_success "Credenciais AWS configuradas corretamente"
            aws_account=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
            aws_user=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null)
            print_info "Conta AWS: $aws_account"
            print_info "Usuário: $aws_user"
        else
            print_error "Credenciais AWS não configuradas ou inválidas"
            print_info "Execute: aws configure"
            return 1
        fi
        
        # Verificar região padrão
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
    
    # Verificar conectividade geral
    if ping -c 1 8.8.8.8 &> /dev/null; then
        print_success "Conectividade de rede OK"
    else
        print_error "Sem conectividade de rede"
        return 1
    fi
    
    # Verificar DNS
    if nslookup aws.amazon.com &> /dev/null; then
        print_success "DNS funcionando corretamente"
    else
        print_error "Problemas com DNS"
        return 1
    fi
    
    # Verificar conectividade com AWS
    if curl -s --max-time 5 https://aws.amazon.com &> /dev/null; then
        print_success "Conectividade com AWS OK"
    else
        print_warning "Possível problema de conectividade com AWS"
    fi
}

# Verificar variáveis de ambiente
check_environment_variables() {
    print_header "Verificando variáveis de ambiente"
    
    # Verificar variáveis AWS comuns
    aws_vars=("AWS_PROFILE" "AWS_REGION" "AWS_DEFAULT_REGION" "AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY")
    
    for var in "${aws_vars[@]}"; do
        if [ -n "${!var}" ]; then
            if [[ "$var" == *"SECRET"* ]] || [[ "$var" == *"KEY"* ]]; then
                print_info "$var está definida (valor oculto)"
            else
                print_info "$var=${!var}"
            fi
        fi
    done
    
    # Verificar variáveis NuCLI
    nucli_vars=("NUCLI_ENV" "NUCLI_PROFILE" "NUCLI_CONFIG_PATH")
    
    for var in "${nucli_vars[@]}"; do
        if [ -n "${!var}" ]; then
            print_info "$var=${!var}"
        fi
    done
}

# Verificar permissões de arquivos
check_file_permissions() {
    print_header "Verificando permissões de arquivos"
    
    # Verificar arquivo de credenciais AWS
    aws_creds_file="$HOME/.aws/credentials"
    if [ -f "$aws_creds_file" ]; then
        perms=$(stat -f "%OLp" "$aws_creds_file" 2>/dev/null || stat -c "%a" "$aws_creds_file" 2>/dev/null)
        if [ "$perms" != "600" ] && [ "$perms" != "400" ]; then
            print_warning "Permissões do arquivo de credenciais AWS podem ser inseguras: $perms"
            print_info "Recomendado: chmod 600 $aws_creds_file"
        else
            print_success "Permissões do arquivo de credenciais AWS OK"
        fi
    fi
    
    # Verificar arquivo de configuração AWS
    aws_config_file="$HOME/.aws/config"
    if [ -f "$aws_config_file" ]; then
        print_success "Arquivo de configuração AWS encontrado"
    fi
}

# Verificar logs de erro recentes
check_recent_errors() {
    print_header "Verificando logs de erro recentes"
    
    # Verificar logs do sistema (macOS)
    if [ -d "/var/log" ]; then
        print_info "Verificando logs do sistema..."
        # Não vamos ler logs completos, apenas informar onde estão
        print_info "Logs do sistema em: /var/log"
    fi
    
    # Verificar se há arquivos de log do NuCLI
    if [ -d "$HOME/.nucli" ]; then
        print_info "Diretório NuCLI encontrado: $HOME/.nucli"
        log_count=$(find "$HOME/.nucli" -name "*.log" -type f 2>/dev/null | wc -l)
        if [ "$log_count" -gt 0 ]; then
            print_info "Encontrados $log_count arquivo(s) de log"
            print_info "Para visualizar: ls -lah $HOME/.nucli/*.log"
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
    
    # Testar comando de ajuda
    if nu --help &> /dev/null; then
        print_success "Comando 'nu --help' funciona"
    else
        print_error "Comando 'nu --help' falhou"
    fi
    
    # Testar comando de versão
    if nu --version &> /dev/null; then
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
    
    # Testar comando de ajuda
    if aws --help &> /dev/null; then
        print_success "Comando 'aws --help' funciona"
    else
        print_error "Comando 'aws --help' falhou"
    fi
    
    # Testar comando de versão
    if aws --version &> /dev/null; then
        print_success "Comando 'aws --version' funciona"
    else
        print_error "Comando 'aws --version' falhou"
    fi
    
    # Testar comando de identidade
    if aws sts get-caller-identity &> /dev/null; then
        print_success "Comando 'aws sts get-caller-identity' funciona"
    else
        print_error "Comando 'aws sts get-caller-identity' falhou"
        print_info "Verifique suas credenciais AWS"
    fi
}

# Diagnóstico de problemas comuns
diagnose_common_issues() {
    print_header "Diagnóstico de Problemas Comuns"
    
    issues_found=0
    
    # Verificar se há problemas conhecidos
    if ! command -v nu &> /dev/null; then
        print_error "Problema: NuCLI não instalado"
        print_info "Solução: npm install -g @nubank/nucli"
        ((issues_found++))
    fi
    
    if ! command -v aws &> /dev/null; then
        print_error "Problema: AWS CLI não instalado"
        print_info "Solução: Instale o AWS CLI conforme documentação oficial"
        ((issues_found++))
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "Problema: Credenciais AWS inválidas ou não configuradas"
        print_info "Solução: Execute 'aws configure' para configurar credenciais"
        ((issues_found++))
    fi
    
    if [ $issues_found -eq 0 ]; then
        print_success "Nenhum problema comum detectado"
    else
        print_warning "Foram encontrados $issues_found problema(s)"
    fi
}

# Gerar relatório
generate_report() {
    print_header "Gerando Relatório de Diagnóstico"
    
    report_file="nucli-troubleshoot-report-$(date +%Y%m%d-%H%M%S).txt"
    
    {
        echo "Relatório de Troubleshooting NuCLI e AWS"
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
    
    print_success "Relatório salvo em: $report_file"
    print_info "Para visualizar: cat $report_file"
}

# Menu principal
show_menu() {
    echo ""
    print_header "Menu de Troubleshooting"
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

