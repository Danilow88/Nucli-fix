const logOutput = document.getElementById("logOutput");
const statusText = document.getElementById("statusText");
const startButton = document.getElementById("startButton");
const langButtons = document.querySelectorAll(".lang-btn");
const menuCards = document.querySelectorAll(".menu-card[data-option]");
const actionCards = document.querySelectorAll("[data-action]");
const terminalInput = document.getElementById("terminalInput");
const sendTerminal = document.getElementById("sendTerminal");
const rovoButton = document.getElementById("openRovo");
const supportButton = document.getElementById("openSupport");
let runStarted = false;
let currentLang = "pt";

const translations = {
  pt: {
    subtitle: "Diagnóstico interativo NuCLI + AWS + Suporte em geral",
    startButton: "Iniciar diagnóstico",
    liveTitle: "Execução em tempo real",
    statusIdle: "Aguardando início. O Terminal do macOS abrirá em segundo plano.",
    hint:
      "Digite e responda no Terminal do macOS. Aqui você acompanha os comandos sendo executados.",
    opt1Title: "Verificação completa",
    opt1Desc: "Roda todas as verificações e gera relatório final.",
    opt7Title: "Testar comandos NuCLI",
    opt7Desc: "Checa nu doctor, versões e comandos essenciais.",
    installNucliTitle: "Instalar NuCLI",
    installNucliDesc: "Guia automático para SSH, brew e setup inicial.",
    opt10Title: "Roles, escopos e países",
    opt10Desc: "Valida permissões e acessos por conta.",
    opt12Title: "Relatório consolidado",
    opt12Desc: "Gera relatório final com detalhes completos.",
    opt19Title: "Erro br prod / Missing Groups",
    opt19Desc: "Diagnóstico guiado para grupos e roles BR.",
    opt22Title: "Cadastrar digital",
    opt22Desc: "Configura IAM user, Okta e FIDO/Touch ID.",
    cacheMacTitle: "Limpar cache do macOS",
    cacheMacDesc: "Remove caches do usuario e do sistema (pode pedir senha).",
    cacheChromeTitle: "Limpar cache do Chrome",
    cacheChromeDesc: "Fecha o Chrome e remove caches locais.",
    updateTitle: "Atualizar o app",
    updateDesc: "Baixa a ultima versao do Git e reinstala.",
    macosUpdateTitle: "Atualizar macOS",
    macosUpdateDesc: "Verifica e instala atualizacoes do sistema.",
    rovoTitle: "Abrir Rovo (Suporte)",
    rovoDesc: "Abre o chat no Google Chrome (usa login do navegador).",
    supportTitle: "Abrir chamado (Suporte)",
    supportDesc: "Abre o portal de chamados da Nubank no Chrome.",
    terminalInputLabel: "Enviar comando para o Terminal do macOS",
    terminalInputPlaceholder: "Ex: 1 ou nu doctor",
    terminalInputHint:
      "Pressione Enter para enviar. O texto aparece no Terminal do macOS.",
    sendButton: "Enviar",
    howTitle: "Como funciona",
    howList: [
      "O app abre o Terminal do macOS e executa o diagnucli.",
      "Os logs ao vivo aparecem aqui conforme os comandos rodam.",
      "Para alterar o script: DIAGNUCLI_PATH=/caminho/diagnucli."
    ],
    guideTitle: "Orientações rápidas",
    guideList: [
      "Mantenha o Terminal aberto para responder aos prompts.",
      "Se pedir MFA, confirme no Okta ou Touch ID.",
      "Permita acesso de Acessibilidade caso solicitado.",
      "Feche o Google Chrome antes de limpar o cache."
    ],
    noteTitle: "Importante",
    noteList: [
      "Todos os comandos rodam no Terminal do macOS.",
      "O app principal é apenas visual e acompanha os logs."
    ]
  },
  en: {
    subtitle: "Interactive NuCLI + AWS + General support",
    startButton: "Start diagnostics",
    liveTitle: "Live execution",
    statusIdle: "Waiting to start. macOS Terminal will open in background.",
    hint:
      "Type and answer in macOS Terminal. Here you follow commands as they run.",
    opt1Title: "Full verification",
    opt1Desc: "Runs all checks and generates the final report.",
    opt7Title: "Test NuCLI commands",
    opt7Desc: "Runs nu doctor, versions and key commands.",
    installNucliTitle: "Install NuCLI",
    installNucliDesc: "Guided setup for SSH, brew, and initial config.",
    opt10Title: "Roles, scopes and countries",
    opt10Desc: "Validates permissions per account.",
    opt12Title: "Consolidated report",
    opt12Desc: "Generates the final report with full details.",
    opt19Title: "br prod / Missing Groups error",
    opt19Desc: "Guided diagnostics for BR groups and roles.",
    opt22Title: "Register biometrics",
    opt22Desc: "Configure IAM user, Okta and FIDO/Touch ID.",
    cacheMacTitle: "Clear macOS cache",
    cacheMacDesc: "Removes user and system caches (may ask for password).",
    cacheChromeTitle: "Clear Chrome cache",
    cacheChromeDesc: "Quits Chrome and removes local caches.",
    updateTitle: "Update app",
    updateDesc: "Pulls latest Git version and reinstalls.",
    macosUpdateTitle: "Update macOS",
    macosUpdateDesc: "Checks and installs system updates.",
    rovoTitle: "Open Rovo (Support)",
    rovoDesc: "Opens chat in Google Chrome (uses browser login).",
    supportTitle: "Open ticket (Support)",
    supportDesc: "Opens Nubank support portal in Chrome.",
    terminalInputLabel: "Send command to macOS Terminal",
    terminalInputPlaceholder: "Ex: 1 or nu doctor",
    terminalInputHint:
      "Press Enter to send. The text appears in macOS Terminal.",
    sendButton: "Send",
    howTitle: "How it works",
    howList: [
      "The app opens macOS Terminal and runs diagnucli.",
      "Live logs are shown here as commands run.",
      "To change script path: DIAGNUCLI_PATH=/path/to/diagnucli."
    ],
    guideTitle: "Quick guidance",
    guideList: [
      "Keep Terminal open to answer prompts.",
      "If MFA is requested, approve in Okta or Touch ID.",
      "Allow Accessibility access if prompted.",
      "Close Google Chrome before clearing cache."
    ],
    noteTitle: "Important",
    noteList: [
      "All commands run in macOS Terminal.",
      "The main app is visual-only and mirrors logs."
    ]
  }
};

const appendLog = (text) => {
  logOutput.textContent += text;
  logOutput.scrollTop = logOutput.scrollHeight;
};

const updateLang = (lang) => {
  currentLang = lang;
  const dict = translations[lang];

  document.querySelectorAll("[data-i18n]").forEach((el) => {
    const key = el.getAttribute("data-i18n");
    if (dict[key]) {
      el.textContent = dict[key];
    }
  });

  document.querySelectorAll("[data-i18n-list]").forEach((el) => {
    const key = el.getAttribute("data-i18n-list");
    const items = dict[key] || [];
    el.innerHTML = "";
    items.forEach((item) => {
      const li = document.createElement("li");
      li.textContent = item;
      el.appendChild(li);
    });
  });

  document.querySelectorAll("[data-i18n-placeholder]").forEach((el) => {
    const key = el.getAttribute("data-i18n-placeholder");
    if (dict[key]) {
      el.setAttribute("placeholder", dict[key]);
    }
  });

  langButtons.forEach((btn) => {
    btn.classList.toggle("active", btn.dataset.lang === lang);
  });

};

window.diagnucli.onLog((data) => {
  appendLog(data);
});

window.diagnucli.onStatus((payload) => {
  if (payload?.scriptPath) {
    const existsLabel = payload.exists ? "ok" : "não encontrado";
    const prefix =
      currentLang === "en"
        ? "Running in macOS Terminal"
        : "Executando no Terminal macOS";
    statusText.textContent =
      `${prefix}: ${payload.scriptPath} (${existsLabel}). ` +
      `Logs: ${payload.logPath}`;
  }
});

const startRun = async () => {
  if (runStarted) {
    return;
  }
  runStarted = true;
  startButton.disabled = true;
  const { scriptPath } = await window.diagnucli.start();
  appendLog(`\n[DiagnuCLI] Start requested for: ${scriptPath}\n`);
};

const sendMenuChoice = async (choice) => {
  if (!choice) {
    return;
  }
  await startRun();
  setTimeout(async () => {
    await window.diagnucli.sendChoice(choice);
    appendLog(`\n[DiagnuCLI] Menu option sent: ${choice}\n`);
  }, 1200);
};

const sendTerminalText = async () => {
  const value = terminalInput.value.trim();
  if (!value) {
    return;
  }
  await startRun();
  await window.diagnucli.sendText(value, true);
  appendLog(`\n[DiagnuCLI] Sent to Terminal: ${value}\n`);
  terminalInput.value = "";
};

const actionLabels = {
  "install-nucli": "NuCLI installer",
  "cache-mac": "macOS cache cleanup",
  "cache-chrome": "Chrome cache cleanup",
  "update-app": "DiagnuCLI app update",
  "update-macos": "macOS update"
};

const sendAction = async (actionId) => {
  const label = actionLabels[actionId];
  if (!label) {
    return;
  }
  if (actionId === "install-nucli") {
    await window.diagnucli.installNucli();
  } else {
    await window.diagnucli.runAction(actionId);
  }
  appendLog(`\n[DiagnuCLI] Action started: ${label}\n`);
};

startButton.addEventListener("click", startRun);

menuCards.forEach((card) => {
  card.addEventListener("click", () => {
    sendMenuChoice(card.dataset.option);
  });
});

actionCards.forEach((card) => {
  card.addEventListener("click", () => {
    sendAction(card.dataset.action);
  });
});

sendTerminal.addEventListener("click", sendTerminalText);
terminalInput.addEventListener("keydown", (event) => {
  if (event.key === "Enter") {
    sendTerminalText();
  }
});

if (rovoButton) {
  rovoButton.addEventListener("click", async () => {
    await window.diagnucli.openRovo();
    appendLog("\n[DiagnuCLI] Rovo support opened.\n");
  });
}

if (supportButton) {
  supportButton.addEventListener("click", async () => {
    await window.diagnucli.openSupport();
    appendLog("\n[DiagnuCLI] Support portal opened.\n");
  });
}

langButtons.forEach((btn) => {
  btn.addEventListener("click", () => updateLang(btn.dataset.lang));
});

window.addEventListener("DOMContentLoaded", () => {
  updateLang(currentLang);
});
