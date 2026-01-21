# 🔐 SOLUÇÃO: Permission Denied

## ❌ Erro que você está vendo:

```
zsh: permission denied: ./nucli-troubleshoot-detailed.sh
```

## ✅ SOLUÇÃO RÁPIDA (Copie e Cole):

### Opção 1: Se você está no diretório do script

```bash
chmod +x nucli-troubleshoot-detailed.sh && ./nucli-troubleshoot-detailed.sh
```

### Opção 2: Comando completo em uma linha

```bash
cd ~/Desktop/setup && chmod +x nucli-troubleshoot-detailed.sh && ./nucli-troubleshoot-detailed.sh
```

## 📋 Passo a Passo Detalhado:

### 1️⃣ Navegar para o diretório:
```bash
cd ~/Desktop/setup
```

### 2️⃣ Dar permissão de execução:
```bash
chmod +x nucli-troubleshoot-detailed.sh
```

### 3️⃣ Executar o script:
```bash
./nucli-troubleshoot-detailed.sh
```

## 🔍 Verificar se funcionou:

Execute este comando para ver as permissões:

```bash
ls -lh nucli-troubleshoot-detailed.sh
```

**✅ Deve mostrar algo como:**
```
-rwxr-xr-x  1 danilo.fukuyama.digisystem  staff  86K Dec 19 11:53 nucli-troubleshoot-detailed.sh
```

**O `x` nas permissões (`-rwxr-xr-x`) significa que o arquivo tem permissão de execução!**

## 💡 O que significa `chmod +x`?

- `chmod` = "change mode" (mudar modo/permissões)
- `+x` = adicionar permissão de execução (execute)
- Isso permite que o arquivo seja executado como um programa

## ⚠️ Se ainda não funcionar:

1. Verifique se você está no diretório correto:
   ```bash
   pwd
   ls -la | grep nucli
   ```

2. Tente com o caminho completo:
   ```bash
   chmod +x ~/Desktop/setup/nucli-troubleshoot-detailed.sh
   ~/Desktop/setup/nucli-troubleshoot-detailed.sh
   ```

---

**✅ Pronto! Agora o script deve executar sem problemas.**

