# Scripts de Troubleshooting NuCLI e AWS

Este repositório contém dois scripts para auxiliar analistas na resolução de problemas relacionados ao NuCLI e AWS, baseado no documento de troubleshooting.

## Scripts Disponíveis

### 1. `nucli-troubleshoot.sh` - Script Principal
Script de produção que realiza verificações de forma silenciosa e eficiente.

### 2. `nucli-troubleshoot-test.sh` - Script de Teste
Script detalhado que mostra **qual comando será executado** e **sua finalidade** antes de executá-lo. Ideal para:
- Aprender como cada verificação funciona
- Depuração de problemas
- Entender o que cada comando faz
- Treinamento de novos analistas

## DiagnuCLI App (Electron)

Se quiser instalar o app via Git (sem DMG/ZIP), use:

```bash
git clone https://github.com/Danilow88/Nucli-fix
cd Nucli-fix/diagnucli-electron
./install.sh
```

Alias para iniciar o app pelo Terminal:

```bash
cd Nucli-fix/diagnucli-electron
./alias.sh
```

Depois use:

```bash
diagnucli-app
```

Atualizar o app via Git:

```bash
cd Nucli-fix
git pull
cd diagnucli-electron
./install.sh
```

O instalador:
- Faz o build local se nao existir app pronto
- Instala em `/Applications/DiagnuCLI.app`
- Remove a quarentena do macOS (quando necessario)

Para remover:

```bash
cd diagnucli-electron
./uninstall.sh
```

## Funcionalidades

O script realiza as seguintes verificações e diagnósticos:

1. **Verificação de Instalação do NuCLI**
   - Verifica se o NuCLI está instalado
   - Exibe a versão instalada
   - Fornece instruções de instalação se necessário

2. **Verificação de Configuração do AWS**
   - Verifica se o AWS CLI está instalado
   - Valida credenciais AWS
   - Verifica região configurada
   - Exibe informações da conta AWS

3. **Verificação de Conectividade de Rede**
   - Testa conectividade geral
   - Verifica resolução DNS
   - Testa conectividade com serviços AWS

4. **Verificação de Variáveis de Ambiente**
   - Lista variáveis AWS configuradas
   - Lista variáveis NuCLI configuradas

5. **Verificação de Permissões de Arquivos**
   - Verifica permissões de arquivos de credenciais AWS
   - Sugere correções de segurança quando necessário

6. **Testes de Comandos**
   - Testa comandos básicos do NuCLI
   - Testa comandos básicos do AWS CLI

7. **Diagnóstico de Problemas Comuns**
   - Identifica problemas conhecidos
   - Fornece soluções sugeridas

8. **Geração de Relatório**
   - Cria um relatório detalhado em arquivo de texto
   - Inclui informações do sistema e configurações

## Como Usar

### Script Principal (`nucli-troubleshoot.sh`)

#### Modo Interativo (Recomendado)

Execute o script sem argumentos para entrar no modo interativo:

```bash
./nucli-troubleshoot.sh
```

O menu interativo permite escolher verificações específicas ou executar uma verificação completa.

### Script de Teste (`nucli-troubleshoot-test.sh`)

#### Modo Interativo com Detalhes

Execute o script de teste para ver cada comando e sua finalidade:

```bash
./nucli-troubleshoot-test.sh
```

**Diferenças do script de teste:**
- 📋 Mostra o comando que será executado
- 🎯 Explica a finalidade de cada comando
- 📤 Mostra a saída dos comandos quando relevante
- ✓ Indica o código de saída de cada comando
- Mais verboso e educativo

**Exemplo de saída do script de teste:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 COMANDO: command -v nu
🎯 FINALIDADE: Verifica se o comando 'nu' está instalado e disponível no PATH do sistema
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Comando executado com sucesso (código: 0)
```

### Modo Não-Interativo

Execute verificações automáticas (útil para scripts e automação):

```bash
./nucli-troubleshoot.sh < /dev/null
```

Ou simplesmente execute e pressione Ctrl+C após a verificação completa.

## Exemplos de Uso

### Script Principal

#### Verificação Completa

```bash
./nucli-troubleshoot.sh
# Escolha a opção 1 no menu
```

#### Verificar apenas AWS

```bash
./nucli-troubleshoot.sh
# Escolha a opção 3 no menu
```

#### Gerar Relatório

```bash
./nucli-troubleshoot.sh
# Escolha a opção 10 no menu
```

O relatório será salvo como `nucli-troubleshoot-report-YYYYMMDD-HHMMSS.txt`

### Script de Teste

#### Verificação Completa com Detalhes

```bash
./nucli-troubleshoot-test.sh
# Escolha a opção 1 no menu
```

#### Verificar apenas NuCLI com Detalhes

```bash
./nucli-troubleshoot-test.sh
# Escolha a opção 2 no menu
```

#### Verificar Logs

```bash
./nucli-troubleshoot-test.sh
# Escolha a opção 11 no menu
```

O relatório de teste será salvo como `nucli-troubleshoot-test-report-YYYYMMDD-HHMMSS.txt`

## Requisitos

- Bash 4.0 ou superior
- AWS CLI (opcional, mas recomendado)
- NuCLI (opcional, mas recomendado)
- Comandos padrão do sistema: `ping`, `curl`, `nslookup`

## Solução de Problemas Comuns

### NuCLI não encontrado

```bash
npm install -g @nubank/nucli
```

### AWS CLI não encontrado

Instale seguindo as instruções em: https://aws.amazon.com/cli/

### Credenciais AWS inválidas

```bash
aws configure
```

### Problemas de conectividade

- Verifique sua conexão de internet
- Verifique configurações de proxy/firewall
- Verifique configurações DNS

## Estrutura do Script

O script está organizado em funções modulares:

- `check_nucli_installation()` - Verifica instalação do NuCLI
- `check_aws_config()` - Verifica configuração AWS
- `check_network_connectivity()` - Verifica rede
- `check_environment_variables()` - Verifica variáveis de ambiente
- `check_file_permissions()` - Verifica permissões
- `test_nucli_commands()` - Testa comandos NuCLI
- `test_aws_commands()` - Testa comandos AWS
- `diagnose_common_issues()` - Diagnóstico geral
- `generate_report()` - Gera relatório

## Cores e Símbolos

Os scripts usam cores e símbolos para facilitar a leitura:

- ✓ Verde: Sucesso/OK
- ✗ Vermelho: Erro/Problema
- ⚠ Amarelo: Aviso
- ℹ Azul: Informação
- 📋 Magenta: Comando (apenas no script de teste)
- 🎯 Magenta: Finalidade (apenas no script de teste)
- 📤 Azul: Executando (apenas no script de teste)

## Contribuindo

Para adicionar novas verificações ou melhorar o script:

1. Adicione novas funções de verificação
2. Integre-as no menu principal
3. Atualize este README

## Licença

Este script foi criado para uso interno e auxiliar na resolução de problemas relacionados ao NuCLI e AWS.

