# 🚀 COMO RODAR O SCRIPT DO ZERO - GUIA RÁPIDO

## 📦 Passo 1: Extrair o arquivo ZIP

Se você recebeu o arquivo `nucli-troubleshoot-scripts-detailed.zip`, extraia-o primeiro:

```bash
unzip nucli-troubleshoot-scripts-detailed.zip
cd setup  # ou o nome da pasta onde extraiu
```

## 🔧 Passo 2: Tornar o script executável

```bash
chmod +x nucli-troubleshoot-detailed.sh
```

## ▶️ Passo 3: Executar o script

### Opção A: Modo Interativo (RECOMENDADO)

Execute o script sem argumentos:

```bash
./nucli-troubleshoot-detailed.sh
```

Você verá um menu interativo com as seguintes opções:

```
========================================
Menu de Troubleshooting (Versão Detalhada)
========================================

1. Verificação completa (recomendado)
2. Verificar instalação do NuCLI
3. Verificar configuração do AWS
4. Verificar conectividade de rede
5. Verificar variáveis de ambiente
6. Verificar permissões de arquivos
7. Testar comandos NuCLI
8. Testar comandos AWS
9. Diagnóstico de problemas comuns
10. Verificar roles, escopos e países
11. Gerar relatório detalhado
12. Gerar relatório final consolidado
13. Verificar logs de erro recentes
14. Habilitar/Desabilitar modo interativo automatizado
0. Sair

Escolha uma opção: 
```

### Opção B: Verificação Completa Automática

Para executar todas as verificações de uma vez:

```bash
./nucli-troubleshoot-detailed.sh
# Escolha a opção 1 no menu
```

Ou execute diretamente em modo não-interativo:

```bash
echo "1" | ./nucli-troubleshoot-detailed.sh
```

## 🎯 Opção 1: Verificação Completa (RECOMENDADO)

Quando você escolher a opção 1, o script irá:

1. ✅ Verificar se NuCLI está instalado
2. ✅ Verificar se AWS CLI está instalado
3. ✅ Verificar credenciais AWS
4. ✅ Testar conectividade de rede
5. ✅ Verificar variáveis de ambiente
6. ✅ Verificar permissões de arquivos
7. ✅ Testar comandos NuCLI
8. ✅ Testar comandos AWS
9. ✅ Verificar roles, escopos e países
10. ✅ Diagnosticar problemas comuns
11. ✅ Gerar relatório final consolidado

## 📊 Relatórios Gerados

Após a execução, o script gera dois relatórios:

1. **Relatório Final de Diagnóstico**: `nucli-diagnostico-final-YYYYMMDD-HHMMSS.txt`
   - Contém todas as informações coletadas
   - Status de cada verificação
   - Comandos executados e resultados

2. **Relatório Consolidado de Comandos**: `nucli-comandos-executados-YYYYMMDD-HHMMSS.txt`
   - Lista todos os comandos executados
   - Verde: comandos que funcionaram
   - Vermelho: comandos que falharam
   - Amarelo: comandos que precisam de ação

## 🔄 Modo Interativo Automatizado

Para habilitar a execução automática de comandos interativos:

```bash
export TRY_INTERACTIVE=true
./nucli-troubleshoot-detailed.sh
```

**⚠️ ATENÇÃO**: Com `TRY_INTERACTIVE=true`, o script tentará executar comandos que normalmente requerem interação manual (como `nu aws shared-role-credentials refresh -i`). Use com cuidado.

## 📝 Exemplos de Uso

### Verificar apenas NuCLI:
```bash
./nucli-troubleshoot-detailed.sh
# Escolha opção 2
```

### Verificar apenas AWS:
```bash
./nucli-troubleshoot-detailed.sh
# Escolha opção 3
```

### Verificar roles e escopos:
```bash
./nucli-troubleshoot-detailed.sh
# Escolha opção 10
```

### Gerar apenas o relatório:
```bash
./nucli-troubleshoot-detailed.sh
# Escolha opção 12
```

## 🎨 Recursos Visuais

O script usa cores para facilitar a leitura:

- 🟢 **Verde**: Sucesso/OK
- 🔴 **Vermelho**: Erro/Problema
- 🟡 **Amarelo**: Aviso/Ação necessária
- 🔵 **Azul**: Informação
- 🟣 **Magenta**: Comando sendo executado

## ⚡ Comandos Rápidos

### Executar tudo de uma vez (não-interativo):
```bash
./nucli-troubleshoot-detailed.sh < /dev/null
```

### Executar e salvar saída em arquivo:
```bash
./nucli-troubleshoot-detailed.sh 2>&1 | tee output.log
```

### Executar com modo interativo habilitado:
```bash
TRY_INTERACTIVE=true ./nucli-troubleshoot-detailed.sh
```

## 🆘 Solução de Problemas

### Erro: "Permission denied"
```bash
chmod +x nucli-troubleshoot-detailed.sh
```

### Erro: "Command not found"
Certifique-se de estar no diretório correto:
```bash
pwd
ls -la nucli-troubleshoot-detailed.sh
```

### Script não executa
Verifique se você tem Bash instalado:
```bash
bash --version
```

Se não tiver Bash, instale:
- **macOS**: Já vem instalado
- **Linux**: `sudo apt-get install bash` (Ubuntu/Debian) ou `sudo yum install bash` (CentOS/RHEL)

## 📚 Mais Informações

Para mais detalhes, consulte o arquivo `README.md` incluído no ZIP.

## ✅ Checklist Rápido

- [ ] Arquivo ZIP extraído
- [ ] Script com permissão de execução (`chmod +x`)
- [ ] NuCLI instalado (opcional, mas recomendado)
- [ ] AWS CLI instalado (opcional, mas recomendado)
- [ ] Script executado com sucesso
- [ ] Relatórios gerados e revisados

---

**Pronto! Agora você pode usar o script para diagnosticar problemas com NuCLI e AWS.**




