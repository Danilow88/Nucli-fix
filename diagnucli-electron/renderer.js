const logOutput = document.getElementById("logOutput");
const statusText = document.getElementById("statusText");
const startButton = document.getElementById("startButton");
const langButtons = document.querySelectorAll(".lang-btn");
const menuCards = document.querySelectorAll(".menu-card[data-option]");
const actionCards = document.querySelectorAll("[data-action]");
const setupHelpButton = document.getElementById("openSetupHelp");
const askNuButton = document.getElementById("openAskNu");
const rovoButton = document.getElementById("openRovo");
const supportButton = document.getElementById("openSupport");
let runStarted = false;
let currentLang = "pt";

const translations = {
  pt: {
    subtitle: "Diagnóstico interativo NuCLI + AWS + Suporte em geral",
    startButton: "Iniciar diagnóstico",
    groupDiagTitle: "Diagnóstico NuCLI/AWS",
    groupSetupTitle: "Setup e acessos",
    groupMacTitle: "Manutenção do Mac",
    groupSupportTitle: "Suporte e chamados",
    liveTitle: "Execução em tempo real",
    statusIdle: "Aguardando início. O Terminal do macOS abrirá minimizado.",
    hint: "O Terminal ficará minimizado; acompanhe os comandos aqui.",
    opt1Title: "Verificação completa - setup NuCLI AWS",
    opt1Desc: "Executa todos os checks do NuCLI/AWS e gera relatório.",
    opt7Title: "Testar comandos NuCLI",
    opt7Desc: "Roda nu doctor, versões e comandos-chave.",
    installNucliTitle: "Instalar NuCLI",
    installNucliDesc: "Passo a passo de acesso, SSH, Homebrew e AWS.",
    opt10Title: "Roles, escopos e países",
    opt10Desc: "Confere roles, escopos e contas permitidas.",
    opt12Title: "Relatório consolidado",
    opt12Desc: "Consolida logs e gera relatório final.",
    opt19Title: "Erro br prod / Missing Groups",
    opt19Desc: "Guia para erro br prod e grupos ausentes.",
    opt22Title: "Cadastrar digital",
    opt22Desc: "Configura IAM user, Okta e Touch ID.",
    cacheMacTitle: "Limpar cache do macOS",
    cacheMacDesc: "Limpa caches de usuário e sistema (pode pedir senha).",
    cacheChromeTitle: "Limpar cache do Chrome",
    cacheChromeDesc: "Fecha o Chrome, limpa cache e cookies locais.",
    updateTitle: "Atualizar o app",
    updateDesc: "Atualiza via Git e reinstala o app.",
    updateHeader: "Atualizar app",
    updateHeaderTip: "Atualiza o DiagnuCLI a partir do Git.",
    logTitle: "Logs do Terminal",
    clearLogButton: "Limpar logs",
    clearLogTip: "Limpa o histórico exibido no painel de logs.",
    macosUpdateTitle: "Atualizar macOS",
    macosUpdateDesc: "Verifica e instala atualizações do macOS.",
    manageDiskTitle: "Gerenciar espaço de HD",
    manageDiskDesc: "Abre Armazenamento via Spotlight.",
    optimizePerfTitle: "Melhorar performance do Mac",
    optimizePerfDesc: "Executa script de desempenho e limpeza.",
    activityMonitorTitle: "Abrir Monitor de Atividades",
    activityMonitorDesc: "Abre o monitor de processos.",
    emptyTrashTitle: "Esvaziar Lixeira",
    emptyTrashDesc: "Esvazia a Lixeira do Finder.",
    openKeychainTitle: "Abrir Keychain",
    openKeychainDesc: "Abre login e Meus Certificados. Clique em Acesso às Chaves.",
    touchIdTitle: "Configurar Digital no Mac",
    touchIdDesc: "Abre Touch ID e Senha nas Configurações.",
    macSetupTitle: "Como configurar o Mac",
    macSetupDesc: "Abre o guia oficial de configuração do Mac.",
    mfaResetTitle: "Resetar MFA (Okta)",
    mfaResetDesc: "Abre o ITEng Self Service em Reset my MFA.",
    passwordChangeTitle: "Trocar senha (Okta)",
    passwordChangeDesc: "Abre o ITEng Self Service em Change my password.",
    restartVpnTitle: "Reiniciar VPN (Zscaler)",
    restartVpnDesc: "Fecha e reabre o Zscaler.",
    exitAppTitle: "Sair do app",
    exitAppDesc: "Fecha o DiagnuCLI.",
    rovoTitle: "Abrir Rovo (Suporte)",
    rovoDesc: "Abre o chat do Rovo no Google Chrome.",
    supportTitle: "Abrir chamado (Suporte)",
    supportDesc: "Abre o portal de chamados da Nubank.",
    requestLaptopTitle: "Pedir troca de laptop",
    requestLaptopDesc: "Abre o formulário de troca de laptop.",
    oncallTitle: "Acionar on-call 24h (home office)",
    oncallDesc: "Abre WhatsApp para o número (11) 95185-7554.",
    startButtonTip: "Inicia o diagnóstico completo no Terminal.",
    opt1Tip: "Roda a verificação completa do NuCLI/AWS.",
    opt7Tip: "Executa testes rápidos do NuCLI.",
    installNucliTip: "Guia passo a passo para instalar e configurar.",
    opt10Tip: "Verifica roles e escopos por conta.",
    opt12Tip: "Gera um relatório consolidado final.",
    opt19Tip: "Diagnóstico para erro BR e grupos ausentes.",
    opt22Tip: "Configura IAM user e autenticação.",
    cacheMacTip: "Remove caches do macOS com sudo.",
    cacheChromeTip: "Fecha o Chrome e limpa cache/cookies.",
    macosUpdateTip: "Executa atualizações do macOS.",
    manageDiskTip: "Abre Armazenamento via Spotlight.",
    optimizePerfTip: "Executa o script de performance.",
    activityMonitorTip: "Abre o Activity Monitor.",
    emptyTrashTip: "Esvazia a Lixeira.",
    openKeychainTip: "Abre o Keychain na área correta.",
    touchIdTip: "Abre Touch ID e Senha nas Configurações do macOS.",
    macSetupTip: "Abre o guia de configuração do Mac.",
    mfaResetTip: "Abre o fluxo de Reset my MFA.",
    passwordChangeTip: "Abre o fluxo de Change my password.",
    restartVpnTip: "Reinicia o Zscaler.",
    exitAppTip: "Sai do DiagnuCLI.",
    rovoTip: "Abre o Rovo no Chrome.",
    supportTip: "Abre o portal de suporte.",
    requestLaptopTip: "Abre o formulário de troca de laptop.",
    oncallTip: "Abre o WhatsApp de on-call.",
    setupHelpTip: "Abre o canal Setup Help no Slack.",
    askNuTip: "Abre o Slack e busca @AskNu.",
    setupHelpTitle:
      "Enviar dúvida para o canal Setup Help, canal para duvidas de aws e nucli setup.",
    setupHelpButton: "Abrir canal no Slack",
    askNuButton: "Falar com @AskNu",
    setupHelpHint: "Clique para abrir o canal e pedir ajuda.",
    howTitle: "Como funciona",
    howList: [
      "O app abre o Terminal do macOS e executa o diagnucli.",
      "Os logs ao vivo aparecem aqui conforme os comandos rodam.",
      "Para alterar o script: DIAGNUCLI_PATH=/caminho/diagnucli."
    ],
    guideTitle: "Orientações rápidas",
    guideList: [
      "O Terminal fica minimizado enquanto os comandos rodam.",
      "Se pedir MFA, confirme no Okta ou Touch ID.",
      "Permita acesso de Acessibilidade caso solicitado.",
      "Feche o Google Chrome antes de limpar o cache."
    ],
    noteTitle: "Importante",
    noteList: [
      "Todos os comandos rodam no Terminal do macOS.",
      "O app principal acompanha os logs."
    ],
    installFinishHint:
      "Ao finalizar a instalação do NuCLI, clique no botão Cadastrar digital."
  },
  en: {
    subtitle: "Interactive NuCLI + AWS + General support",
    startButton: "Start diagnostics",
    groupDiagTitle: "NuCLI/AWS diagnostics",
    groupSetupTitle: "Setup and access",
    groupMacTitle: "Mac maintenance",
    groupSupportTitle: "Support and tickets",
    liveTitle: "Live execution",
    statusIdle: "Waiting to start. macOS Terminal will open minimized.",
    hint: "Terminal stays minimized; follow the commands here.",
    opt1Title: "Full verification - NuCLI AWS setup",
    opt1Desc: "Runs all NuCLI/AWS checks and generates the report.",
    opt7Title: "Test NuCLI commands",
    opt7Desc: "Runs nu doctor, versions, and key commands.",
    installNucliTitle: "Install NuCLI",
    installNucliDesc: "Step-by-step access, SSH, Homebrew, and AWS setup.",
    opt10Title: "Roles, scopes and countries",
    opt10Desc: "Checks roles, scopes, and account access.",
    opt12Title: "Consolidated report",
    opt12Desc: "Consolidates logs and generates the final report.",
    opt19Title: "br prod / Missing Groups error",
    opt19Desc: "Guided diagnostics for BR error and missing groups.",
    opt22Title: "Register biometrics",
    opt22Desc: "Configure IAM user, Okta, and Touch ID.",
    cacheMacTitle: "Clear macOS cache",
    cacheMacDesc: "Removes user and system caches (may ask for password).",
    cacheChromeTitle: "Clear Chrome cache",
    cacheChromeDesc: "Quits Chrome and clears cache and cookies.",
    updateTitle: "Update app",
    updateDesc: "Pulls the latest Git version and reinstalls.",
    updateHeader: "Update app",
    updateHeaderTip: "Update DiagnuCLI from Git.",
    logTitle: "Terminal logs",
    clearLogButton: "Clear logs",
    clearLogTip: "Clears the log panel history.",
    macosUpdateTitle: "Update macOS",
    macosUpdateDesc: "Checks and installs macOS updates.",
    manageDiskTitle: "Manage disk space",
    manageDiskDesc: "Opens Storage via Spotlight.",
    optimizePerfTitle: "Improve Mac performance",
    optimizePerfDesc: "Runs the performance and cleanup script.",
    activityMonitorTitle: "Open Activity Monitor",
    activityMonitorDesc: "Opens the process monitor.",
    emptyTrashTitle: "Empty Trash",
    emptyTrashDesc: "Empties the Finder Trash.",
    openKeychainTitle: "Open Keychain",
    openKeychainDesc: "Opens Login and My Certificates. Click Keychain Access.",
    touchIdTitle: "Set up Touch ID on Mac",
    touchIdDesc: "Opens Touch ID & Password in Settings.",
    macSetupTitle: "How to set up the Mac",
    macSetupDesc: "Opens the official Mac setup guide.",
    mfaResetTitle: "Reset MFA (Okta)",
    mfaResetDesc: "Opens ITEng Self Service on Reset my MFA.",
    passwordChangeTitle: "Change password (Okta)",
    passwordChangeDesc: "Opens ITEng Self Service on Change my password.",
    restartVpnTitle: "Restart VPN (Zscaler)",
    restartVpnDesc: "Quits and reopens Zscaler.",
    exitAppTitle: "Exit app",
    exitAppDesc: "Closes DiagnuCLI.",
    rovoTitle: "Open Rovo (Support)",
    rovoDesc: "Opens the Rovo chat in Google Chrome.",
    supportTitle: "Open ticket (Support)",
    supportDesc: "Opens the Nubank support portal.",
    requestLaptopTitle: "Request laptop replacement",
    requestLaptopDesc: "Opens the laptop replacement form.",
    oncallTitle: "Call on-call 24h (remote work)",
    oncallDesc: "Opens WhatsApp for +55 11 95185-7554.",
    startButtonTip: "Starts the full diagnostics in Terminal.",
    opt1Tip: "Runs the full NuCLI/AWS verification.",
    opt7Tip: "Runs quick NuCLI checks.",
    installNucliTip: "Step-by-step installation and setup.",
    opt10Tip: "Validates roles and scopes.",
    opt12Tip: "Creates the final consolidated report.",
    opt19Tip: "Diagnoses BR prod error and missing groups.",
    opt22Tip: "Configures IAM user and authentication.",
    cacheMacTip: "Clears macOS caches with sudo.",
    cacheChromeTip: "Closes Chrome and clears cache/cookies.",
    macosUpdateTip: "Runs macOS updates.",
    manageDiskTip: "Opens Storage via Spotlight.",
    optimizePerfTip: "Runs the performance script.",
    activityMonitorTip: "Opens Activity Monitor.",
    emptyTrashTip: "Empties Trash.",
    openKeychainTip: "Opens Keychain in the right section.",
    touchIdTip: "Opens Touch ID & Password in macOS Settings.",
    macSetupTip: "Opens the Mac setup guide.",
    mfaResetTip: "Opens the Reset my MFA flow.",
    passwordChangeTip: "Opens the Change my password flow.",
    restartVpnTip: "Restarts Zscaler.",
    exitAppTip: "Exit DiagnuCLI.",
    rovoTip: "Open Rovo in Chrome.",
    supportTip: "Open the support portal.",
    requestLaptopTip: "Open the laptop replacement form.",
    oncallTip: "Open the on-call WhatsApp.",
    setupHelpTip: "Open the Setup Help Slack channel.",
    askNuTip: "Open Slack and search for @AskNu.",
    setupHelpTitle: "Send a question to the Setup Help channel",
    setupHelpButton: "Open Slack channel",
    askNuButton: "Talk to @AskNu",
    setupHelpHint: "Click to open the channel and ask for help.",
    howTitle: "How it works",
    howList: [
      "The app opens macOS Terminal and runs diagnucli.",
      "Live logs are shown here as commands run.",
      "To change script path: DIAGNUCLI_PATH=/path/to/diagnucli."
    ],
    guideTitle: "Quick guidance",
    guideList: [
      "Terminal stays minimized while commands run.",
      "If MFA is requested, approve in Okta or Touch ID.",
      "Allow Accessibility access if prompted.",
      "Close Google Chrome before clearing cache."
    ],
    noteTitle: "Important",
    noteList: [
      "All commands run in macOS Terminal.",
      "The main app mirrors the logs."
    ],
    installFinishHint:
      "After finishing the NuCLI setup, click the Cadastrar digital button."
  },
  es: {
    subtitle: "Diagnóstico interactivo NuCLI + AWS + Soporte general",
    startButton: "Iniciar diagnóstico",
    groupDiagTitle: "Diagnóstico NuCLI/AWS",
    groupSetupTitle: "Configuración y accesos",
    groupMacTitle: "Mantenimiento del Mac",
    groupSupportTitle: "Soporte y tickets",
    liveTitle: "Ejecución en tiempo real",
    statusIdle: "Esperando inicio. El Terminal de macOS se abrirá minimizado.",
    hint: "El Terminal quedará minimizado; siga los comandos aquí.",
    opt1Title: "Verificación completa - setup NuCLI AWS",
    opt1Desc: "Ejecuta todos los checks de NuCLI/AWS y genera el informe.",
    opt7Title: "Probar comandos NuCLI",
    opt7Desc: "Ejecuta nu doctor, versiones y comandos clave.",
    installNucliTitle: "Instalar NuCLI",
    installNucliDesc: "Paso a paso de acceso, SSH, Homebrew y AWS.",
    opt10Title: "Roles, alcances y países",
    opt10Desc: "Verifica roles, alcances y cuentas.",
    opt12Title: "Informe consolidado",
    opt12Desc: "Consolida logs y genera el informe final.",
    opt19Title: "Error br prod / Missing Groups",
    opt19Desc: "Guía para error BR y grupos faltantes.",
    opt22Title: "Registrar biometría",
    opt22Desc: "Configura IAM user, Okta y Touch ID.",
    cacheMacTitle: "Limpiar caché de macOS",
    cacheMacDesc: "Limpia cachés de usuario y sistema (puede pedir contraseña).",
    cacheChromeTitle: "Limpiar caché de Chrome",
    cacheChromeDesc: "Cierra Chrome y limpia caché y cookies.",
    updateTitle: "Actualizar app",
    updateDesc: "Actualiza desde Git y reinstala.",
    updateHeader: "Actualizar app",
    updateHeaderTip: "Actualiza DiagnuCLI desde Git.",
    logTitle: "Registros del Terminal",
    clearLogButton: "Limpiar logs",
    clearLogTip: "Limpia el historial de registros.",
    macosUpdateTitle: "Actualizar macOS",
    macosUpdateDesc: "Verifica e instala actualizaciones de macOS.",
    manageDiskTitle: "Administrar espacio en disco",
    manageDiskDesc: "Abre Almacenamiento via Spotlight.",
    optimizePerfTitle: "Mejorar rendimiento del Mac",
    optimizePerfDesc: "Ejecuta el script de rendimiento y limpieza.",
    activityMonitorTitle: "Abrir Monitor de Actividad",
    activityMonitorDesc: "Abre el monitor de procesos.",
    emptyTrashTitle: "Vaciar Papelera",
    emptyTrashDesc: "Vacía la Papelera del Finder.",
    openKeychainTitle: "Abrir Keychain",
    openKeychainDesc: "Abre login y Mis Certificados. Haz clic en Acceso a Llaveros.",
    touchIdTitle: "Configurar Touch ID en Mac",
    touchIdDesc: "Abre Touch ID y Contraseña en Configuración.",
    macSetupTitle: "Cómo configurar el Mac",
    macSetupDesc: "Abre la guía oficial de configuración del Mac.",
    mfaResetTitle: "Restablecer MFA (Okta)",
    mfaResetDesc: "Abre ITEng Self Service en Reset my MFA.",
    passwordChangeTitle: "Cambiar contraseña (Okta)",
    passwordChangeDesc: "Abre ITEng Self Service en Change my password.",
    restartVpnTitle: "Reiniciar VPN (Zscaler)",
    restartVpnDesc: "Cierra y vuelve a abrir Zscaler.",
    exitAppTitle: "Salir de la app",
    exitAppDesc: "Cierra DiagnuCLI.",
    rovoTitle: "Abrir Rovo (Soporte)",
    rovoDesc: "Abre el chat de Rovo en Google Chrome.",
    supportTitle: "Abrir ticket (Soporte)",
    supportDesc: "Abre el portal de soporte de Nubank.",
    requestLaptopTitle: "Solicitar cambio de laptop",
    requestLaptopDesc: "Abre el formulario de cambio de laptop.",
    oncallTitle: "Activar on-call 24h (home office)",
    oncallDesc: "Abre WhatsApp para +55 11 95185-7554.",
    startButtonTip: "Inicia el diagnóstico completo en Terminal.",
    opt1Tip: "Ejecuta la verificación completa NuCLI/AWS.",
    opt7Tip: "Ejecuta checks rápidos de NuCLI.",
    installNucliTip: "Instalación y configuración paso a paso.",
    opt10Tip: "Valida roles y alcances.",
    opt12Tip: "Crea el informe consolidado final.",
    opt19Tip: "Diagnostica el error BR y grupos faltantes.",
    opt22Tip: "Configura IAM user y autenticación.",
    cacheMacTip: "Limpia cachés de macOS con sudo.",
    cacheChromeTip: "Cierra Chrome y limpia caché/cookies.",
    macosUpdateTip: "Ejecuta actualizaciones de macOS.",
    manageDiskTip: "Abre Almacenamiento via Spotlight.",
    optimizePerfTip: "Ejecuta el script de rendimiento.",
    activityMonitorTip: "Abre el Monitor de Actividad.",
    emptyTrashTip: "Vacía la Papelera.",
    openKeychainTip: "Abre Keychain en la sección correcta.",
    touchIdTip: "Abre Touch ID y Contraseña en Configuración de macOS.",
    macSetupTip: "Abre la guía de configuración del Mac.",
    mfaResetTip: "Abre el flujo Reset my MFA.",
    passwordChangeTip: "Abre el flujo Change my password.",
    restartVpnTip: "Reinicia Zscaler.",
    exitAppTip: "Salir de DiagnuCLI.",
    rovoTip: "Abre Rovo en Chrome.",
    supportTip: "Abre el portal de soporte.",
    requestLaptopTip: "Abre el formulario de cambio de laptop.",
    oncallTip: "Abre el WhatsApp de on-call.",
    setupHelpTip: "Abre el canal Setup Help en Slack.",
    askNuTip: "Abre Slack y busca @AskNu.",
    setupHelpTitle: "Enviar duda al canal Setup Help",
    setupHelpButton: "Abrir canal en Slack",
    askNuButton: "Hablar con @AskNu",
    setupHelpHint: "Haga clic para abrir el canal y pedir ayuda.",
    howTitle: "Cómo funciona",
    howList: [
      "La app abre el Terminal de macOS y ejecuta diagnucli.",
      "Los logs en vivo se muestran aquí mientras corren los comandos.",
      "Para cambiar el script: DIAGNUCLI_PATH=/ruta/al/diagnucli."
    ],
    guideTitle: "Orientaciones rápidas",
    guideList: [
      "El Terminal queda minimizado mientras se ejecutan los comandos.",
      "Si pide MFA, confirme en Okta o Touch ID.",
      "Permita acceso de Accesibilidad si se solicita.",
      "Cierre Google Chrome antes de limpiar la caché."
    ],
    noteTitle: "Importante",
    noteList: [
      "Todos los comandos se ejecutan en el Terminal de macOS.",
      "La app principal refleja los logs."
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

  document.querySelectorAll("[data-tooltip]").forEach((el) => {
    const key = el.getAttribute("data-tooltip");
    if (dict[key]) {
      el.setAttribute("title", dict[key]);
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
        : currentLang === "es"
        ? "Ejecutando en Terminal de macOS"
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

const sendMenuChoice = async (choice, title) => {
  if (!choice) {
    return;
  }
  await startRun();
  setTimeout(async () => {
    await window.diagnucli.sendChoice(choice);
    const detail = title ? ` (${title})` : "";
    appendLog(`\n[DiagnuCLI] Menu option sent: ${choice}${detail}\n`);
  }, 1200);
};

const actionLabels = {
  "install-nucli": "NuCLI installer",
  "cache-mac": "macOS cache cleanup",
  "cache-chrome": "Chrome cache cleanup",
  "update-app": "DiagnuCLI app update",
  "update-macos": "macOS update",
  "manage-disk": "Manage disk space",
  "optimize-performance": "Optimize macOS performance",
  "activity-monitor": "Open Activity Monitor",
  "empty-trash": "Empty Trash",
  "open-keychain": "Open Keychain",
  "open-touch-id": "Open Touch ID & Password",
  "open-mac-setup": "Open Mac setup guide",
  "open-itenge-mfa-reset": "Open ITEng MFA reset",
  "open-itenge-password-change": "Open ITEng password change",
  "restart-vpn": "Restart VPN",
  "exit-app": "Exit app",
  "request-laptop": "Request laptop replacement",
  "open-oncall": "Open WhatsApp on-call",
  "clear-log": "Clear logs"
};

const sendAction = async (actionId) => {
  const label = actionLabels[actionId];
  if (!label) {
    return;
  }
  if (actionId === "install-nucli") {
    await window.diagnucli.installNucli(currentLang);
  } else if (actionId === "exit-app") {
    await window.diagnucli.exitApp();
    return;
  } else if (actionId === "clear-log") {
    logOutput.textContent = "";
    await window.diagnucli.clearLog();
    return;
  } else {
    await window.diagnucli.runAction(actionId);
  }
  appendLog(`\n[DiagnuCLI] Action started: ${label}\n`);
};

startButton.addEventListener("click", startRun);

menuCards.forEach((card) => {
  card.addEventListener("click", () => {
    const titleEl = card.querySelector(".menu-title");
    const title = titleEl ? titleEl.textContent.trim() : "";
    sendMenuChoice(card.dataset.option, title);
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

if (askNuButton) {
  askNuButton.addEventListener("click", async () => {
    await window.diagnucli.openAskNu();
    appendLog("\n[DiagnuCLI] AskNu opened in Slack.\n");
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
