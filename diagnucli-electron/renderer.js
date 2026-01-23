const logOutput = document.getElementById("logOutput");
const statusText = document.getElementById("statusText");
const startButton = document.getElementById("startButton");
const langButtons = document.querySelectorAll(".lang-btn");
const menuCards = document.querySelectorAll(".menu-card[data-option]");
const actionCards = document.querySelectorAll("[data-action]");
const setupHelpButton = document.getElementById("openSetupHelp");
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
    installNucliDesc: "Guia completo de acesso, SSH, brew e setup AWS.",
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
    manageDiskTitle: "Gerenciar espaço de HD",
    manageDiskDesc: "Abre o gerenciamento de armazenamento do macOS.",
    activityMonitorTitle: "Abrir Monitor de Atividades",
    activityMonitorDesc: "Abre o monitor de processos do macOS.",
    emptyTrashTitle: "Esvaziar Lixeira",
    emptyTrashDesc: "Esvazia a lixeira do Finder.",
    openKeychainTitle: "Abrir Keychain",
    openKeychainDesc: "Abre em login e Meus Certificados. Clique em Acesso às Chaves.",
    resetGeneralTitle: "Resetar configurações gerais",
    resetGeneralDesc: "Abre a área de redefinições do macOS.",
    rovoTitle: "Abrir Rovo (Suporte)",
    rovoDesc: "Abre o chat no Google Chrome (usa login do navegador).",
    supportTitle: "Abrir chamado (Suporte)",
    supportDesc: "Abre o portal de chamados da Nubank no Chrome.",
    setupHelpTitle:
      "Enviar dúvida para o canal Setup Help, canal para duvidas de aws e nucli setup.",
    setupHelpButton: "Abrir canal no Slack",
    setupHelpHint: "Clique para abrir o canal e pedir ajuda.",
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
    ],
    installFinishHint:
      "Ao finalizar a instalação do NuCLI, clique no botão Cadastrar digital."
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
    installNucliDesc: "Full guide for access, SSH, brew, and AWS setup.",
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
    manageDiskTitle: "Manage disk space",
    manageDiskDesc: "Opens macOS storage management.",
    activityMonitorTitle: "Open Activity Monitor",
    activityMonitorDesc: "Opens the macOS process monitor.",
    emptyTrashTitle: "Empty Trash",
    emptyTrashDesc: "Empties the Finder trash.",
    openKeychainTitle: "Open Keychain",
    openKeychainDesc: "Opens Login and My Certificates. Click Keychain Access.",
    resetGeneralTitle: "Reset general settings",
    resetGeneralDesc: "Opens the macOS reset area.",
    rovoTitle: "Open Rovo (Support)",
    rovoDesc: "Opens chat in Google Chrome (uses browser login).",
    supportTitle: "Open ticket (Support)",
    supportDesc: "Opens Nubank support portal in Chrome.",
    setupHelpTitle: "Send a question to the Setup Help channel",
    setupHelpButton: "Open Slack channel",
    setupHelpHint: "Click to open the channel and ask for help.",
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
    ],
    installFinishHint:
      "After finishing the NuCLI setup, click the Cadastrar digital button."
  },
  es: {
    subtitle: "Diagnóstico interactivo NuCLI + AWS + Soporte general",
    startButton: "Iniciar diagnóstico",
    liveTitle: "Ejecución en tiempo real",
    statusIdle: "Esperando inicio. El Terminal de macOS se abrirá en segundo plano.",
    hint:
      "Escriba y responda en el Terminal de macOS. Aquí seguirá los comandos en ejecución.",
    opt1Title: "Verificación completa",
    opt1Desc: "Ejecuta todas las verificaciones y genera el informe final.",
    opt7Title: "Probar comandos NuCLI",
    opt7Desc: "Ejecuta nu doctor, versiones y comandos clave.",
    installNucliTitle: "Instalar NuCLI",
    installNucliDesc: "Guía completa de acceso, SSH, brew y configuración AWS.",
    opt10Title: "Roles, alcances y países",
    opt10Desc: "Valida permisos por cuenta.",
    opt12Title: "Informe consolidado",
    opt12Desc: "Genera el informe final con detalles completos.",
    opt19Title: "Error br prod / Missing Groups",
    opt19Desc: "Diagnóstico guiado para grupos y roles BR.",
    opt22Title: "Registrar biometría",
    opt22Desc: "Configura IAM user, Okta y FIDO/Touch ID.",
    cacheMacTitle: "Limpiar caché de macOS",
    cacheMacDesc: "Elimina cachés de usuario y sistema (puede pedir contraseña).",
    cacheChromeTitle: "Limpiar caché de Chrome",
    cacheChromeDesc: "Cierra Chrome y elimina cachés locales.",
    updateTitle: "Actualizar app",
    updateDesc: "Descarga la última versión de Git y reinstala.",
    macosUpdateTitle: "Actualizar macOS",
    macosUpdateDesc: "Verifica e instala actualizaciones del sistema.",
    manageDiskTitle: "Administrar espacio en disco",
    manageDiskDesc: "Abre la gestión de almacenamiento de macOS.",
    activityMonitorTitle: "Abrir Monitor de Actividad",
    activityMonitorDesc: "Abre el monitor de procesos de macOS.",
    emptyTrashTitle: "Vaciar Papelera",
    emptyTrashDesc: "Vacía la papelera del Finder.",
    openKeychainTitle: "Abrir Keychain",
    openKeychainDesc: "Abre en login y Mis Certificados. Haz clic en Acceso a Llaveros.",
    resetGeneralTitle: "Restablecer ajustes generales",
    resetGeneralDesc: "Abre el área de restablecimiento de macOS.",
    rovoTitle: "Abrir Rovo (Soporte)",
    rovoDesc: "Abre el chat en Google Chrome (usa login del navegador).",
    supportTitle: "Abrir ticket (Soporte)",
    supportDesc: "Abre el portal de soporte de Nubank en Chrome.",
    setupHelpTitle: "Enviar duda al canal Setup Help",
    setupHelpButton: "Abrir canal en Slack",
    setupHelpHint: "Haga clic para abrir el canal y pedir ayuda.",
    howTitle: "Cómo funciona",
    howList: [
      "La app abre el Terminal de macOS y ejecuta diagnucli.",
      "Los logs en vivo se muestran aquí mientras corren los comandos.",
      "Para cambiar el script: DIAGNUCLI_PATH=/ruta/al/diagnucli."
    ],
    guideTitle: "Orientaciones rápidas",
    guideList: [
      "Mantenga el Terminal abierto para responder a los prompts.",
      "Si pide MFA, confirme en Okta o Touch ID.",
      "Permita acceso de Accesibilidad si se solicita.",
      "Cierre Google Chrome antes de limpiar la caché."
    ],
    noteTitle: "Importante",
    noteList: [
      "Todos los comandos se ejecutan en el Terminal de macOS.",
      "La app principal es solo visual y refleja los logs."
    ],
    installFinishHint:
      "Al finalizar la instalación de NuCLI, haga clic en el botón Cadastrar digital."
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

const actionLabels = {
  "install-nucli": "NuCLI installer",
  "cache-mac": "macOS cache cleanup",
  "cache-chrome": "Chrome cache cleanup",
  "update-app": "DiagnuCLI app update",
  "update-macos": "macOS update",
  "manage-disk": "Manage disk space",
  "activity-monitor": "Open Activity Monitor",
  "empty-trash": "Empty Trash",
  "open-keychain": "Open Keychain",
  "reset-general": "Reset general settings"
};

const sendAction = async (actionId) => {
  const label = actionLabels[actionId];
  if (!label) {
    return;
  }
  if (actionId === "install-nucli") {
    await window.diagnucli.installNucli(currentLang);
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

if (setupHelpButton) {
  setupHelpButton.addEventListener("click", async () => {
    await window.diagnucli.openSetupHelp();
    appendLog("\n[DiagnuCLI] Setup Help channel opened.\n");
  });
}

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
