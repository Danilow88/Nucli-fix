# Diagnu — Botões e Funções

Este documento resume os botões do app e o que cada um faz.

## Diagnóstico NuCLI/AWS
- Verificação completa - setup NuCLI AWS: roda checks completos e gera relatório.
- Testar comandos NuCLI: executa testes rápidos (doctor/versões/comandos).
- Roles, escopos e países: verifica roles e escopos por conta.
- Relatório consolidado: consolida logs e gera relatório final.
- Erro br prod / Missing Groups: guia para erros de grupos ausentes.
- Cadastrar digital: orienta IAM user, Okta e Touch ID.
- Error: "GNU version of chcon was not found" fix: entra em `~/dev/nu/nucli` e faz `git pull --rebase`.
- Unable to locate a Java Runtime Fix: instala Temurin via Homebrew.
- ERRO: Your Bash version is ancient...unbound variable fix: restaura PATH e variáveis do NuCLI no `.zshrc`.
- Nucli update and credentials fix: atualiza NuCLI e refaz credenciais AWS/CodeArtifact.

## Setup e acessos
- Instalar NuCLI: passo a passo de acesso, SSH, Homebrew e AWS.
- Conferir senha Okta: abre o Password Manager do Chrome filtrado por Okta.
- Touch ID no Mac: abre Touch ID & Password.
- Abrir Keychain: abre login e Meus Certificados.
- Como configurar o Mac: abre o guia oficial de configuração.

## Manutenção do Mac
- Limpar cache do macOS: remove caches do usuário e sistema.
- Limpar cache do Chrome: fecha o Chrome e limpa cache/cookies.
- Limpeza automática do Chrome: ativa/desativa limpeza automática de cache.
- Testar velocidade da internet: abre o Speedtest dentro do app.
- Clean clutter: abre Armazenamento com recomendações de limpeza.
- Selecionar apps para iniciar: abre Itens de Início no macOS.
- Limpeza de Memória: tenta liberar RAM (purge) e abre Monitor de Atividades.
- Corrigir hora: abre Date & Time e ativa ajustes automáticos.
- ZTD fix: executa `jamf` (manage/policy/recon/enrollmentComplete) e orienta reboot + ZTD no Self Service.
- Desinstalar apps: lista apps e remove selecionados (inclui limpeza de resíduos e lixeira).
- Esvaziar Lixeira: esvazia a lixeira do Finder.
- Atualizar o app: fecha apps abertos e roda o instalador via `curl`.
- Atualizar macOS: instala atualizações do sistema.
- Gerenciar espaço de HD: abre Armazenamento via Spotlight.
- Melhorar performance do Mac: executa script de performance/limpeza.
- Abrir Monitor de Atividades: abre o monitor de processos.

## Suporte e chamados
- Abrir chamado (Suporte): abre o portal de chamados.
- Pedir gadgets: abre o formulário de solicitação de itens de trabalho.
- Falar com People: abre o portal de RH/NuWayOfWorking.
- Shuffle Fix: abre o ticket de toolio, pede scopes no @AskNu, abre Okta e limpa cache do Chrome.
- Gerar certificados: abre o portal de certificados no Chrome.
- Pedir troca de laptop: abre o formulário de troca.
- Acionar on-call 24h (home office): abre WhatsApp do on-call.
- Problemas com Setup Nucli / Falar com @AskNu / Problemas com VPN: abre canais do Slack e atalho para @AskNu.

## Controles do app
- Minimizar/Maximizar: controla a janela e o modo de monitor.
- Limpar logs: limpa o painel de logs.
- Modo minimizado (barra superior): ativa o modo compacto com monitor de recursos.
