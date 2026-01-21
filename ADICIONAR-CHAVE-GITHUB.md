# Como Adicionar sua Chave SSH ao GitHub

## Passo 1: Copiar sua Chave Pública

Sua chave pública SSH já está pronta. Aqui está ela:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7lSk2S0FKXF4PkmHUBw2yV2Jh5Ku+KTfZMM76t+yVt danilo.fukuyama.digisystem@nubank.com.br
```

**Para copiar no terminal, execute:**
```bash
pbcopy < ~/.ssh/id_ed25519.pub
```

Isso copiará a chave para a área de transferência.

## Passo 2: Adicionar a Chave no GitHub

1. Acesse o GitHub: https://github.com
2. Faça login na sua conta
3. Clique na sua foto de perfil (canto superior direito)
4. Clique em **Settings**
5. No menu lateral esquerdo, clique em **SSH and GPG keys**
6. Clique no botão **New SSH key** (ou **Add SSH key**)
7. Preencha:
   - **Title**: Dê um nome descritivo (ex: "MacBook Pro - Nubank")
   - **Key**: Cole a chave pública que você copiou (ou use `Cmd+V`)
8. Clique em **Add SSH key**
9. Confirme sua senha do GitHub se solicitado

## Passo 3: Testar a Conexão

Depois de adicionar a chave, teste a conexão SSH com o GitHub:

```bash
ssh -T git@github.com
```

**Resposta esperada:**
```
Hi [seu-usuario]! You've successfully authenticated, but GitHub does not provide shell access.
```

Se você ver essa mensagem, está tudo funcionando! ✅

## Solução de Problemas

### Se aparecer "Permission denied (publickey)":
- Verifique se você copiou a chave completa (deve começar com `ssh-ed25519` e terminar com seu email)
- Certifique-se de que adicionou a chave no GitHub corretamente
- Aguarde alguns minutos após adicionar a chave (pode levar um pouco para propagar)

### Se aparecer "Host key verification failed":
- Execute: `ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts`

### Se não tiver chave SSH:
- Gere uma nova chave: `ssh-keygen -t ed25519 -C "seu-email@exemplo.com"`
- Siga os passos acima com a nova chave

## Comandos Úteis

```bash
# Ver sua chave pública
cat ~/.ssh/id_ed25519.pub

# Copiar chave para área de transferência
pbcopy < ~/.ssh/id_ed25519.pub

# Testar conexão GitHub
ssh -T git@github.com

# Verificar chaves SSH carregadas
ssh-add -l
```






