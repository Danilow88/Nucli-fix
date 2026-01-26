const {
  app,
  BrowserWindow,
  ipcMain,
  systemPreferences,
  Tray,
  nativeImage,
  Menu
} = require("electron");
const path = require("path");
const os = require("os");
const fs = require("fs");
const { spawn, spawnSync } = require("child_process");

let mainWindow = null;
let tailProcess = null;
let runStarted = false;
let tray = null;
let trayModeEnabled = false;
let trayInterval = null;
let autoCacheEnabled = false;
let autoCacheInterval = null;
let monitorModeEnabled = false;
let monitorModeSnapshot = null;
let speedtestWindow = null;

const DEFAULT_SCRIPT_PATH = app.isPackaged
  ? path.join(process.resourcesPath, "diagnucli")
  : path.resolve(__dirname, "..", "diagnucli");
const SCRIPT_PATH = process.env.DIAGNUCLI_PATH || DEFAULT_SCRIPT_PATH;
const DEFAULT_REPO_PATH = path.join(os.homedir(), "Nucli-fix");
const REPO_PATH = process.env.DIAGNUCLI_REPO_PATH || DEFAULT_REPO_PATH;
const LOG_PATH = path.join(app.getPath("userData"), "diagnucli.log");
const INSTALLER_PATH = app.isPackaged
  ? path.join(process.resourcesPath, "install-nucli.sh")
  : path.join(__dirname, "..", "scripts", "nucli-setup.sh");
const PERFORMANCE_SCRIPT_PATH = app.isPackaged
  ? path.join(process.resourcesPath, "optimize-performance.sh")
  : path.join(__dirname, "..", "scripts", "optimize-performance.sh");
const ROVO_URL =
  "https://home.atlassian.com/o/2c2ebb29-8407-4659-a7d0-69bbf5b745ce/chat?rovoChatPathway=chat&rovoChatCloudId=c43390d3-e5f8-43ca-9eec-c382a5220bd9&rovoChatAgentId=01c47565-9fcc-4e41-8db8-2706b4631f9f&cloudId=c43390d3-e5f8-43ca-9eec-c382a5220bd9";
const SUPPORT_URL = "https://nubank.atlassian.net/servicedesk/customer/portal/131";
const LAPTOP_REQUEST_URL =
  "https://nubank.atlassian.net/servicedesk/customer/portal/131/group/552/create/2364";
const GADGETS_REQUEST_URL =
  "https://nubank.atlassian.net/servicedesk/customer/portal/359/group/3385/create/4698";
const PEOPLE_REQUEST_URL =
  "https://nubank.atlassian.net/servicedesk/customer/portal/273";
const SHUFFLE_FIX_URL =
  "https://nubank.atlassian.net/servicedesk/customer/portal/131/group/834/create/2941";
const ONCALL_WHATSAPP_URL = "https://wa.me/5511951857554";
const GUIDE_URL_BASE =
  "https://nubank.atlassian.net/wiki/spaces/ITKB/pages/262490555235/How+to+Configure+NuCli+on+MacBook";
const MAC_SETUP_URL = "https://itops-mdm.s3.amazonaws.com/ZTD/guide/home.html";
const SETUP_HELP_URL = "https://nubank.enterprise.slack.com/archives/CBJGG73AM";
const SETUP_HELP_CHANNEL_ID = "CBJGG73AM";
const SPEEDTEST_URL = "https://www.speedtest.net/";
const OKTA_PASSWORDS_URL = "chrome://password-manager/passwords?q=okta";
const ZSCALER_OKTA_URL =
  "https://nubank.okta.com/app/zscaler_private_access/exk20v3f4xjOjaR3e0h8/sso/saml?SAMLRequest=jZJRb5swFIX%2FCvI74BhKwAqpslXVKnVqltA%2B7KW6mJuFBmzma1C0X1%2BaEK2TpqqPlu895%2Fh8Xlwf28Yb0FJtdM5mAWceamWqWv%2FK2WNx66fserkgaBvRyVXv9nqDv3sk542LmuT5Jme91dIA1SQ1tEjSKbldfb%2BXIuCys8YZZRrmrYjQutHqq9HUt2i3aIda4ePmPmd75zqSYfgmSV3Q2XoAh8EfUtCgDZRpQxgDhCJNRZJeJdF8niWpiONZSGSYdzOmqjW400suYrovQR8Cc3BwVui6cFJ8nhyeQSkkCvF4EHyIdvHx5eEFNhHyffqmfArEvFtjFZ4ayNkOGkLm3d3kbLX5kSHssirzo4ynfrzL0C%2FnlfBVlaRRXAIvZ%2FE4S2sgqgf8u03U450mB9rlTHCR%2BHzmi7iYxTJOZMSDK578ZN56qu9Lrc9YPuq6PA%2BR%2FFYUa3%2F9sC2Y93TBOw6wCaY8udv3FD8Whgs6tvwsqBYdVODgP8QW4fsUy%2Bn47w9bvgI%3D&SigAlg=http%3A%2F%2Fwww.w3.org%2F2001%2F04%2Fxmldsig-more%23rsa-sha256&Signature=Ml6yh55p7o6x7SraKmzYSxfV0ckYSuRRKYABUNHo7Ae4wx5yzHK7VpU%2BFxCjAjlinOMzu7vDDpAGVNxgsRc9fbEJPH5Zb0u8UrLydo2etq8fyvkJlRA3K145d5lHf2OZB0w8VDVjNVYchwyve4pkRfTphc7%2BIuKjecnAOdRAqSDKrlJyxm5n4JztjjgZ8z4OW%2FK2t4c3dVWnY5dQC%2BrlpcYY45f8%2FsqNtDIbF1KKeXC8kK52Q1O7qvMVnFWxVo9razhFDE0E1v4O%2BCXX7RLF0WjoiI3HJABGoEVQTF%2Bf7w3n82S%2BFW92PYjpxBRk%2FxliC0ySQUmfjThbyfU1f8%2FcXA%3D%3D";
const WORKSTATION_IDENTITY_URL =
  "https://nubank.okta.com/app/nubank_infosecworkstationidentity_1/exk1s1je4siFhxkDv0h8/sso/saml?fromHome=true";
const APP_NAME = "DiagnuCLI";
const DEV_ICON_PATH = path.join(__dirname, "assets", "icon.png");

const SHUFFLE_FIX_I18N = {
  pt: {
    step1: "Shuffle Fix: passo 1 - abrir chamado do toolio.",
    step2: "Shuffle Fix: passo 2 - abrindo @AskNu e enviando pedido de escopo.",
    step3: "Shuffle Fix: passo 3 - abrir workstation-identity no Okta.",
    step4: "Shuffle Fix: passo 4 - fechar Chrome e limpar cache/cookies.",
    askNuPrompt:
      "eu quero o escopo lift e cs para a conta {country} para acessar o shuffle.",
    waitApproval:
      "Shuffle Fix: aguarde aprovacao do escopo e do actor toolio antes de acessar o Shuffle.",
    oktaHint:
      "Shuffle Fix: esteja logado no Okta. Se pedir senha 3x, use a senha de desbloqueio da maquina.",
    done: "Shuffle Fix: finalizado.",
    stop: "Shuffle Fix: encerrado pelo usuario.",
    qStep1: "Pressione Enter para continuar...",
    qCountry: "Qual pais precisa do escopo? (br/mex/co): ",
    qStep2: "Pressione Enter para continuar...",
    qStep3: "Pressione Enter para continuar..."
  },
  en: {
    step1: "Shuffle Fix: step 1 - open the toolio request ticket.",
    step2: "Shuffle Fix: step 2 - open @AskNu and request scopes.",
    step3: "Shuffle Fix: step 3 - open workstation-identity in Okta.",
    step4: "Shuffle Fix: step 4 - quit Chrome and clear cache/cookies.",
    askNuPrompt:
      "I want lift and cs scope for the {country} account to access Shuffle.",
    waitApproval:
      "Shuffle Fix: wait for scope and toolio approval before accessing Shuffle.",
    oktaHint:
      "Shuffle Fix: make sure you are logged into Okta. If it asks for password 3x, use your machine unlock password.",
    done: "Shuffle Fix: finished.",
    stop: "Shuffle Fix: canceled by user.",
    qStep1: "Press Enter to continue...",
    qCountry: "Which country needs the scope? (br/mex/co): ",
    qStep2: "Press Enter to continue...",
    qStep3: "Press Enter to continue..."
  },
  es: {
    step1: "Shuffle Fix: paso 1 - abrir el ticket de toolio.",
    step2: "Shuffle Fix: paso 2 - abrir @AskNu y solicitar scopes.",
    step3: "Shuffle Fix: paso 3 - abrir workstation-identity en Okta.",
    step4: "Shuffle Fix: paso 4 - cerrar Chrome y limpiar caché/cookies.",
    askNuPrompt:
      "Quiero los scopes lift y cs para la cuenta {country} para acceder a Shuffle.",
    waitApproval:
      "Shuffle Fix: espere la aprobación del scope y del toolio antes de acceder a Shuffle.",
    oktaHint:
      "Shuffle Fix: asegúrese de iniciar sesión en Okta. Si pide la contraseña 3 veces, use la contraseña de desbloqueo de la máquina.",
    done: "Shuffle Fix: finalizado.",
    stop: "Shuffle Fix: cancelado por el usuario.",
    qStep1: "Presione Enter para continuar...",
    qCountry: "¿Qué país necesita el scope? (br/mex/co): ",
    qStep2: "Presione Enter para continuar...",
    qStep3: "Presione Enter para continuar..."
  }
};

const ZTD_FIX_I18N = {
  pt: {
    start: "ZTD fix: iniciando comandos Jamf.",
    passwordHint: "Se pedir senha, use a mesma que desbloqueia a máquina.",
    restartHint: "Reinicie o dispositivo após finalizar.",
    selfServiceHint: "Depois do reboot, rode o ZTD no IT Eng Self Service.",
    done: "ZTD fix: finalizado."
  },
  en: {
    start: "ZTD fix: starting Jamf commands.",
    passwordHint:
      "If it asks for a password, use the same one you use to unlock the machine.",
    restartHint: "Restart the device after finishing.",
    selfServiceHint: "After reboot, run ZTD in IT Eng Self Service.",
    done: "ZTD fix: finished."
  },
  es: {
    start: "ZTD fix: iniciando comandos de Jamf.",
    passwordHint:
      "Si pide contraseña, usa la misma que desbloquea la máquina.",
    restartHint: "Reinicia el dispositivo al finalizar.",
    selfServiceHint: "Después del reinicio, ejecuta ZTD en IT Eng Self Service.",
    done: "ZTD fix: finalizado."
  }
};

function getGuideUrl(lang) {
  const localeMap = {
    pt: "pt_BR",
    en: "en_US",
    es: "es_ES"
  };
  const locale = localeMap[lang] || "pt_BR";
  return `${GUIDE_URL_BASE}?locale=${locale}`;
}

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 760,
    backgroundColor: "#1B0B2E",
    title: APP_NAME,
    icon: DEV_ICON_PATH,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      contextIsolation: true,
      nodeIntegration: false
    }
  });

  mainWindow.loadFile(path.join(__dirname, "index.html"));
}

function ensureAccessibilityAccess() {
  if (process.platform !== "darwin") {
    return;
  }
  try {
    const trusted = systemPreferences.isTrustedAccessibilityClient(true);
    if (!trusted) {
      spawn("open", [
        "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
      ]);
    }
  } catch (error) {
    logLine(`[DiagnuCLI] Accessibility permission check failed: ${error}`);
  }
}

function openRovoInChrome() {
  const osa = `
    set rovoUrl to "${ROVO_URL}"
    tell application "Google Chrome" to activate
    tell application "Google Chrome"
      if (count of windows) = 0 then
        make new window
      end if
      set targetWindow to front window
      set targetTab to make new tab at end of tabs of targetWindow with properties {URL: rovoUrl}
      set active tab index of targetWindow to (index of targetTab)
    end tell
  `;
  spawn("osascript", ["-e", osa]);
}

function openSupportInChrome() {
  const osa = `
    set supportUrl to "${SUPPORT_URL}"
    tell application "Google Chrome" to activate
    tell application "Google Chrome"
      if (count of windows) = 0 then
        make new window
      end if
      set targetWindow to front window
      set targetTab to make new tab at end of tabs of targetWindow with properties {URL: supportUrl}
      set active tab index of targetWindow to (index of targetTab)
    end tell
  `;
  spawn("osascript", ["-e", osa]);
}

function openGadgetsRequestInChrome() {
  const osa = `
    set gadgetsUrl to "${GADGETS_REQUEST_URL}"
    tell application "Google Chrome" to activate
    tell application "Google Chrome"
      if (count of windows) = 0 then
        make new window
      end if
      set targetWindow to front window
      set targetTab to make new tab at end of tabs of targetWindow with properties {URL: gadgetsUrl}
      set active tab index of targetWindow to (index of targetTab)
    end tell
  `;
  spawn("osascript", ["-e", osa]);
}

function openPeopleRequestInChrome() {
  const osa = `
    set peopleUrl to "${PEOPLE_REQUEST_URL}"
    tell application "Google Chrome" to activate
    tell application "Google Chrome"
      if (count of windows) = 0 then
        make new window
      end if
      set targetWindow to front window
      set targetTab to make new tab at end of tabs of targetWindow with properties {URL: peopleUrl}
      set active tab index of targetWindow to (index of targetTab)
    end tell
  `;
  spawn("osascript", ["-e", osa]);
}

function openCertificatesInChrome() {
  const osa = `
    set certUrl to "${WORKSTATION_IDENTITY_URL}"
    tell application "Google Chrome" to activate
    tell application "Google Chrome"
      if (count of windows) = 0 then
        make new window
      end if
      set targetWindow to front window
      set targetTab to make new tab at end of tabs of targetWindow with properties {URL: certUrl}
      set active tab index of targetWindow to (index of targetTab)
    end tell
  `;
  spawn("osascript", ["-e", osa]);
}

function openShuffleFixInChrome() {
  const osa = `
    set shuffleUrl to "${SHUFFLE_FIX_URL}"
    tell application "Google Chrome" to activate
    tell application "Google Chrome"
      if (count of windows) = 0 then
        make new window
      end if
      set targetWindow to front window
      set targetTab to make new tab at end of tabs of targetWindow with properties {URL: shuffleUrl}
      set active tab index of targetWindow to (index of targetTab)
    end tell
  `;
  spawn("osascript", ["-e", osa]);
}

function openMacSetupInChrome() {
  const osa = `
    set macSetupUrl to "${MAC_SETUP_URL}"
    tell application "Google Chrome" to activate
    tell application "Google Chrome"
      if (count of windows) = 0 then
        make new window
      end if
      set targetWindow to front window
      set targetTab to make new tab at end of tabs of targetWindow with properties {URL: macSetupUrl}
      set active tab index of targetWindow to (index of targetTab)
    end tell
  `;
  spawn("osascript", ["-e", osa]);
}

function openOktaPasswordsInChrome() {
  const osa = `
    set oktaUrl to "${OKTA_PASSWORDS_URL}"
    tell application "Google Chrome" to activate
    tell application "Google Chrome"
      if (count of windows) = 0 then
        make new window
      end if
      set targetWindow to front window
      set targetTab to make new tab at end of tabs of targetWindow with properties {URL: oktaUrl}
      set active tab index of targetWindow to (index of targetTab)
    end tell
  `;
  spawn("osascript", ["-e", osa]);
}

function openZscalerOktaInChrome() {
  const osa = `
    set zscalerUrl to "${ZSCALER_OKTA_URL}"
    tell application "Google Chrome" to activate
    tell application "Google Chrome"
      if (count of windows) = 0 then
        make new window
      end if
      set targetWindow to front window
      set targetTab to make new tab at end of tabs of targetWindow with properties {URL: zscalerUrl}
      set active tab index of targetWindow to (index of targetTab)
    end tell
  `;
  spawn("osascript", ["-e", osa]);
}

function openITEngSelfServiceAndClick(targetLabel) {
  const osa = `
    tell application "ITEng Self Service" to activate
    repeat with i from 1 to 30
      delay 0.2
      tell application "System Events"
        if exists process "ITEng Self Service" then
          if exists window 1 of process "ITEng Self Service" then exit repeat
        end if
      end tell
    end repeat
    tell application "System Events"
      tell process "ITEng Self Service"
        set frontmost to true
        set targetField to missing value
        try
          set targetField to first UI element of window 1 whose role description is "search field"
        end try
        if targetField is missing value then
          try
            set targetField to first text field of window 1 whose description is "Search"
          end try
        end if
        if targetField is missing value then
          try
            set targetField to first text field of window 1
          end try
        end if
        if targetField is not missing value then
          click targetField
          delay 0.2
          keystroke "a" using {command down}
          delay 0.1
          keystroke "${targetLabel}"
          delay 0.2
          key code 36
          delay 0.3
        else
          keystroke "f" using {command down}
          delay 0.2
          keystroke "${targetLabel}"
          delay 0.2
          key code 36
          delay 0.3
        end if
        try
          click button "${targetLabel}" of window 1
        end try
      end tell
    end tell
  `;
  spawn("osascript", ["-e", osa]);
}

function openLaptopRequestInChrome() {
  const osa = `
    set laptopUrl to "${LAPTOP_REQUEST_URL}"
    tell application "Google Chrome" to activate
    tell application "Google Chrome"
      if (count of windows) = 0 then
        make new window
      end if
      set targetWindow to front window
      set targetTab to make new tab at end of tabs of targetWindow with properties {URL: laptopUrl}
      set active tab index of targetWindow to (index of targetTab)
    end tell
  `;
  spawn("osascript", ["-e", osa]);
}

function openSetupHelpInChrome() {
  const osa = `
    tell application "Slack" to activate
    delay 0.3
    tell application "System Events"
      tell process "Slack"
        set frontmost to true
        keystroke "k" using {command down}
        delay 0.2
        keystroke "#setup-help"
        delay 0.2
        key code 36
      end tell
    end tell
  `;
  spawn("osascript", ["-e", osa]);
}

function openAskNuInSlack() {
  const osa = `
    tell application "Slack" to activate
    delay 0.3
    tell application "System Events"
      tell process "Slack"
        set frontmost to true
        keystroke "k" using {command down}
        delay 0.2
        keystroke "@AskNu"
        delay 0.2
        key code 36
      end tell
    end tell
  `;
  spawn("osascript", ["-e", osa]);
}

function openZscalerFeedbackInSlack() {
  const osa = `
    tell application "Slack" to activate
    delay 0.3
    tell application "System Events"
      tell process "Slack"
        set frontmost to true
        keystroke "k" using {command down}
        delay 0.2
        keystroke "#zscaler-feedback-tmp"
        delay 0.2
        key code 36
      end tell
    end tell
  `;
  spawn("osascript", ["-e", osa]);
}

function closeAllTerminalWindows() {
  if (process.platform !== "darwin") {
    return;
  }
  const osa = `
    tell application "Terminal"
      if (count of windows) > 0 then
        repeat with w from (count of windows) to 1 by -1
          try
            close window w
          end try
        end repeat
      end if
    end tell
    delay 0.2
    tell application "System Events"
      if exists process "Terminal" then
        tell process "Terminal"
          repeat with w from (count of windows) to 1 by -1
            if exists sheet 1 of window w then
              try
                click button "Close" of sheet 1 of window w
              end try
              try
                click button "Fechar" of sheet 1 of window w
              end try
              try
                click button "Finalizar" of sheet 1 of window w
              end try
              try
                click button "Terminate" of sheet 1 of window w
              end try
            end if
          end repeat
        end tell
      end if
    end tell
  `;
  spawn("osascript", ["-e", osa]);
}

function openKeychainMyCertificates() {
  const osa = `
    tell application "Keychain Access" to activate
    delay 0.4
    tell application "System Events"
      -- Auto-confirm "Abrir Acesso às Chaves" if a prompt appears
      try
        tell process "Keychain Access"
          if exists window 1 then
            if exists button "Abrir Acesso às Chaves" of window 1 then
              click button "Abrir Acesso às Chaves" of window 1
              delay 0.2
            end if
          end if
        end tell
      end try
      try
        tell process "SecurityAgent"
          if exists window 1 then
            if exists button "Abrir Acesso às Chaves" of window 1 then
              click button "Abrir Acesso às Chaves" of window 1
              delay 0.2
            end if
          end if
        end tell
      end try
      tell process "Keychain Access"
        set frontmost to true
        try
          click row "Acesso às Chaves" of outline 1 of scroll area 1 of splitter group 1 of window 1
        end try
        try
          click row "Keychains" of outline 1 of scroll area 1 of splitter group 1 of window 1
        end try
        try
          click row "login" of outline 1 of scroll area 1 of splitter group 1 of window 1
        end try
        delay 0.2
        try
          click row "Meus Certificados" of outline 1 of scroll area 1 of splitter group 1 of window 1
        end try
        try
          click row "My Certificates" of outline 1 of scroll area 1 of splitter group 1 of window 1
        end try
        try
          click row "Mis certificados" of outline 1 of scroll area 1 of splitter group 1 of window 1
        end try
      end tell
    end tell
  `;
  spawn("osascript", ["-e", osa]);
}

function openGuideInChrome(lang) {
  const guideUrl = getGuideUrl(lang);
  const osa = `
    set guideUrl to "${guideUrl}"
    tell application "Google Chrome" to activate
    tell application "Google Chrome"
      if (count of windows) = 0 then
        make new window
      end if
      set targetWindow to front window
      set targetTab to make new tab at end of tabs of targetWindow with properties {URL: guideUrl}
      set active tab index of targetWindow to (index of targetTab)
    end tell
  `;
  spawn("osascript", ["-e", osa]);
}

function sendStatus(payload) {
  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.webContents.send("run-status", payload);
  }
}

function ensureLogFile() {
  fs.mkdirSync(path.dirname(LOG_PATH), { recursive: true });
  if (!fs.existsSync(LOG_PATH)) {
    fs.writeFileSync(LOG_PATH, "");
  }
}

function logLine(message) {
  ensureLogFile();
  const line = `${message}\n`;
  fs.appendFileSync(LOG_PATH, line);
  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.webContents.send("run-log", line);
  }
}

function getTrayIconPath() {
  return app.isPackaged
    ? path.join(process.resourcesPath, "assets", "icon.png")
    : path.join(__dirname, "assets", "icon.png");
}

function getResourceStats() {
  const cpuCount = os.cpus().length || 1;
  const load = os.loadavg()[0] || 0;
  const cpuPercent = Math.min(100, Math.round((load / cpuCount) * 100));
  const memPercent = Math.round(
    ((os.totalmem() - os.freemem()) / os.totalmem()) * 100
  );
  return { cpuPercent, memPercent };
}

function getDiskUsagePercent() {
  try {
    const result = spawnSync("df", ["-k", "/"], { encoding: "utf8" });
    if (result.status !== 0) {
      return null;
    }
    const lines = result.stdout.trim().split("\n");
    if (lines.length < 2) {
      return null;
    }
    const parts = lines[1].trim().split(/\s+/);
    if (parts.length < 5) {
      return null;
    }
    const total = parseInt(parts[1], 10);
    const used = parseInt(parts[2], 10);
    if (!Number.isFinite(total) || total <= 0 || !Number.isFinite(used)) {
      return null;
    }
    return Math.min(100, Math.round((used / total) * 100));
  } catch (error) {
    return null;
  }
}

function updateTrayTitle() {
  if (!tray) {
    return;
  }
  const { cpuPercent, memPercent } = getResourceStats();
  const title = `CPU ${cpuPercent}% | MEM ${memPercent}%`;
  tray.setTitle(title);
  tray.setToolTip(`DiagnuCLI • ${title}`);
}

function startTrayMonitor() {
  updateTrayTitle();
  if (!trayInterval) {
    trayInterval = setInterval(updateTrayTitle, 10000);
  }
}

function stopTrayMonitor() {
  if (trayInterval) {
    clearInterval(trayInterval);
    trayInterval = null;
  }
}

function enableTrayMode() {
  if (!tray) {
    const icon = nativeImage.createFromPath(getTrayIconPath());
    tray = new Tray(icon);
    const menu = Menu.buildFromTemplate([
      {
        label: "Ver recursos",
        click: () => enableTrayMode()
      },
      {
        label: "Limpar cache",
        click: () => runChromeCacheCleanupSilent()
      },
      {
        label: "Maximizar",
        click: () => {
          disableTrayMode();
          if (mainWindow && !mainWindow.isDestroyed()) {
            mainWindow.maximize();
          }
        }
      },
      {
        label: "Desinstalar apps",
        click: () => {
          disableTrayMode();
          runMaintenanceAction("uninstall-apps", "pt");
        }
      },
      {
        label: "Limpar Memoria",
        click: () => {
          disableTrayMode();
          runMaintenanceAction("memory-cleanup", "pt");
        }
      }
    ]);
    tray.setContextMenu(menu);
    tray.on("click", () => {
      if (mainWindow && !mainWindow.isDestroyed()) {
        mainWindow.show();
        mainWindow.focus();
      }
    });
  }
  trayModeEnabled = true;
  if (mainWindow && !mainWindow.isDestroyed()) {
    monitorModeSnapshot = {
      bounds: mainWindow.getBounds(),
      resizable: mainWindow.isResizable(),
      alwaysOnTop: mainWindow.isAlwaysOnTop()
    };
    mainWindow.setResizable(false);
    mainWindow.setAlwaysOnTop(true, "floating");
    mainWindow.setBounds({
      x: monitorModeSnapshot.bounds.x,
      y: monitorModeSnapshot.bounds.y,
      width: 380,
      height: 520
    });
    mainWindow.show();
    mainWindow.focus();
    mainWindow.webContents.send("monitor-mode", true);
  }
  startTrayMonitor();
  logLine("[DiagnuCLI] Tray mode enabled.");
}

function disableTrayMode() {
  trayModeEnabled = false;
  if (mainWindow && !mainWindow.isDestroyed()) {
    if (monitorModeSnapshot) {
      mainWindow.setAlwaysOnTop(monitorModeSnapshot.alwaysOnTop);
      mainWindow.setResizable(monitorModeSnapshot.resizable);
      mainWindow.setBounds(monitorModeSnapshot.bounds);
    } else {
      mainWindow.setAlwaysOnTop(false);
      mainWindow.setResizable(true);
    }
    mainWindow.show();
    mainWindow.focus();
    mainWindow.webContents.send("monitor-mode", false);
  }
  stopTrayMonitor();
  if (tray) {
    tray.destroy();
    tray = null;
  }
  logLine("[DiagnuCLI] Tray mode disabled.");
}

function runChromeCacheCleanupSilent() {
  const action = ACTIONS["cache-chrome"];
  if (!action) {
    return;
  }
  const command = action.buildCommand();
  logLine("[DiagnuCLI] Auto Chrome cache cleanup started.");
  spawn("/bin/bash", ["-lc", command], {
    cwd: os.homedir(),
    env: {
      ...process.env,
      PATH: "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    }
  }).on("close", () => {
    logLine("[DiagnuCLI] Auto Chrome cache cleanup finished.");
  });
}

function enableAutoCache() {
  autoCacheEnabled = true;
  runChromeCacheCleanupSilent();
  if (!autoCacheInterval) {
    autoCacheInterval = setInterval(runChromeCacheCleanupSilent, 4 * 60 * 60 * 1000);
  }
  logLine("[DiagnuCLI] Auto Chrome cache cleanup enabled.");
}

function disableAutoCache() {
  autoCacheEnabled = false;
  if (autoCacheInterval) {
    clearInterval(autoCacheInterval);
    autoCacheInterval = null;
  }
  logLine("[DiagnuCLI] Auto Chrome cache cleanup disabled.");
}

function openSpeedtestWindow() {
  if (speedtestWindow && !speedtestWindow.isDestroyed()) {
    speedtestWindow.show();
    speedtestWindow.focus();
    return;
  }
  speedtestWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    backgroundColor: "#0b0715",
    title: "Speedtest",
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true
    }
  });
  speedtestWindow.loadURL(SPEEDTEST_URL);
  speedtestWindow.on("closed", () => {
    speedtestWindow = null;
  });
}

function escapeAppleScript(value) {
  return value.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
}

function startLogTail() {
  if (tailProcess) {
    return;
  }

  tailProcess = spawn("tail", ["-n", "200", "-f", LOG_PATH], {
    cwd: os.homedir()
  });

  tailProcess.stdout.on("data", (data) => {
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.webContents.send("run-log", data.toString());
    }
  });

  tailProcess.on("exit", () => {
    tailProcess = null;
  });
}

function startRun() {
  if (runStarted) {
    return;
  }
  runStarted = true;

  const exists = fs.existsSync(SCRIPT_PATH);
  fs.mkdirSync(path.dirname(LOG_PATH), { recursive: true });
  fs.writeFileSync(LOG_PATH, "");

  sendStatus({
    scriptPath: SCRIPT_PATH,
    logPath: LOG_PATH,
    exists
  });

  startLogTail();

  const closeTerminal = `osascript -e 'tell application "Terminal" to close front window'`;
  const runCommand = exists
    ? `TERM=xterm-256color JAVA_TOOL_OPTIONS="--enable-native-access=ALL-UNNAMED" ` +
      `DIAGNUCLI_LOG_PATH="${LOG_PATH}" /usr/bin/script -q -a "${LOG_PATH}" bash "${SCRIPT_PATH}"; ${closeTerminal}`
    : `echo "Script not found: ${SCRIPT_PATH}" | tee -a "${LOG_PATH}"; ${closeTerminal}`;

  const escaped = escapeAppleScript(runCommand);
  const osa = [
    'tell application "Terminal" to activate',
    `tell application "Terminal" to do script "${escaped}"`
  ];

  const osaProc = spawn("osascript", ["-e", osa[0], "-e", osa[1]]);
  osaProc.on("exit", () => {
    sendStatus({ terminalStarted: true });
  });
}

ipcMain.handle("start-run", () => {
  startRun();
  return { scriptPath: SCRIPT_PATH, logPath: LOG_PATH, started: true };
});

function sendTextToTerminal(text, pressEnter = false) {
  const escapedText = escapeAppleScript(String(text));
  const osa = [
    'tell application "Terminal" to activate',
    'tell application "System Events" to tell process "Terminal" to set frontmost to true',
    "delay 0.2",
    `tell application "System Events" to tell process "Terminal" to keystroke "${escapedText}"`
  ];
  if (pressEnter) {
    osa.push(
      'tell application "System Events" to tell process "Terminal" to key code 36'
    );
  }
  spawn("osascript", osa.flatMap((line) => ["-e", line]));
}

ipcMain.handle("send-choice", (_event, choice) => {
  sendTextToTerminal(`${choice}`, true);
  return { ok: true };
});

ipcMain.handle("send-text", (_event, text, pressEnter = false) => {
  sendTextToTerminal(text, pressEnter);
  return { ok: true };
});

function runNucliInstaller(lang = "pt") {
  const exists = fs.existsSync(INSTALLER_PATH);
  ensureLogFile();

  openGuideInChrome(lang);
  startLogTail();

  const closeTerminal = `osascript -e 'tell application "Terminal" to close front window'`;
  const runCommand = exists
    ? `LANG_UI="${lang}" bash "${INSTALLER_PATH}" | tee -a "${LOG_PATH}"; ${closeTerminal}`
    : `echo "Installer not found: ${INSTALLER_PATH}" | tee -a "${LOG_PATH}"; ${closeTerminal}`;

  const escaped = escapeAppleScript(runCommand);
  const osa = [
    'tell application "Terminal" to activate',
    `tell application "Terminal" to do script "${escaped}"`
  ];

  spawn("osascript", ["-e", osa[0], "-e", osa[1]]);
  sendStatus({ installerStarted: true, installerPath: INSTALLER_PATH, exists });
}

ipcMain.handle("install-nucli", (_event, lang) => {
  runNucliInstaller(lang);
  return { ok: true };
});

const MAINTENANCE_ACTIONS = {
  "fix-gnu-chcon": {
    label: "Fix GNU chcon error",
    detail: "Entra em ~/dev/nu/nucli e executa git pull --rebase.",
    buildCommand: () => {
      const nucliDir = path.join(os.homedir(), "dev", "nu", "nucli");
      return [
        `echo "[DiagnuCLI] GNU chcon fix started"`,
        `cd "${nucliDir}"`,
        `echo "[DiagnuCLI] cd ${nucliDir}"`,
        `git pull --rebase`,
        `echo "[DiagnuCLI] GNU chcon fix finished"`
      ].join("; ");
    }
  },
  "fix-java-runtime": {
    label: "Fix Java Runtime missing",
    detail: "Instala Temurin via Homebrew.",
    buildCommand: () => {
      return [
        `echo "[DiagnuCLI] Java Runtime fix started"`,
        `brew install --cask temurin`,
        `echo "[DiagnuCLI] Java Runtime fix finished"`
      ].join("; ");
    }
  },
  "fix-bash-unbound": {
    label: "Fix Bash unbound variables",
    detail: "Restaura PATH e variáveis do NuCLI no .zshrc.",
    buildCommand: () => {
      return [
        `echo "[DiagnuCLI] Bash/NUCLI fix started"`,
        `/bin/cat > ~/.zshrc <<'EOF'`,
        `export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"`,
        `eval "$(/opt/homebrew/bin/brew shellenv)"`,
        `# NuCLI`,
        `export NU_HOME="$HOME/dev/nu"`,
        `export NUCLI_HOME="$NU_HOME/nucli"`,
        `export PATH="$NUCLI_HOME:$PATH"`,
        `EOF`,
        `echo "[DiagnuCLI] Bash/NUCLI fix finished"`
      ].join("\n");
    }
  },
  "ztd-fix": {
    label: "ZTD fix",
    detail: "Executa comandos Jamf e orienta reboot/ZTD no Self Service.",
    buildCommand: (lang = "pt") => {
      const texts = ZTD_FIX_I18N[lang] || ZTD_FIX_I18N.pt;
      return [
        `echo "[DiagnuCLI] ${texts.start}"`,
        `echo "[DiagnuCLI] ${texts.passwordHint}"`,
        `sudo jamf manage`,
        `sudo jamf policy`,
        `sudo jamf recon`,
        `sudo jamf policy -event enrollmentComplete`,
        `echo "[DiagnuCLI] ${texts.restartHint}"`,
        `echo "[DiagnuCLI] ${texts.selfServiceHint}"`,
        `echo "[DiagnuCLI] ${texts.done}"`
      ].join("; ");
    }
  },
  "shuffle-fix": {
    label: "Shuffle fix",
    detail:
      "Cria chamado do toolio, pede scopes no AskNu, abre Okta e limpa cache do Chrome.",
    buildCommand: (lang = "pt") => {
      const texts = SHUFFLE_FIX_I18N[lang] || SHUFFLE_FIX_I18N.pt;
      const chromeCacheBase = path.join(
        os.homedir(),
        "Library",
        "Application Support",
        "Google",
        "Chrome",
        "Default"
      );
      const chromeTargets = [
        path.join(os.homedir(), "Library", "Caches", "Google", "Chrome"),
        path.join(chromeCacheBase, "Cache"),
        path.join(chromeCacheBase, "Code Cache"),
        path.join(chromeCacheBase, "GPUCache"),
        path.join(chromeCacheBase, "Service Worker", "CacheStorage")
      ];
      const cookieFiles = [
        path.join(chromeCacheBase, "Cookies"),
        path.join(chromeCacheBase, "Cookies-journal")
      ];
      const rmTargets = chromeTargets.map((target) => `"${target}"`).join(" ");
      const rmCookies = cookieFiles.map((file) => `"${file}"`).join(" ");
      const openToolio = `open -a "Google Chrome" "${SHUFFLE_FIX_URL}"`;
      const openAskNu = escapeAppleScript(
        `tell application "Slack" to activate
delay 0.3
tell application "System Events"
  tell process "Slack"
    set frontmost to true
    keystroke "k" using {command down}
    delay 0.2
    keystroke "@AskNu"
    delay 0.2
    key code 36
    delay 0.4
  end tell
end tell`
      );
      const openWorkstation = `open -a "Google Chrome" "${WORKSTATION_IDENTITY_URL}"`;
      const yesRegex = "^(sim|si|yes|y)?$";
      return [
        `echo "[DiagnuCLI] ${texts.step1}"`,
        `${openToolio}`,
        `printf "${texts.qStep1}"`,
        `read -r shuffle_step1`,
        `shuffle_step1=$(echo "$shuffle_step1" | tr '[:upper:]' '[:lower:]')`,
        `if [[ ! "$shuffle_step1" =~ ${yesRegex} ]]; then echo "[DiagnuCLI] ${texts.stop}"; exit 0; fi`,
        `printf "${texts.qCountry}"`,
        `read -r scope_country`,
        `scope_country=$(echo "$scope_country" | tr '[:upper:]' '[:lower:]')`,
        `echo "[DiagnuCLI] ${texts.step2}"`,
        `osascript -e "${openAskNu}"`,
        `sleep 1`,
        `message="${texts.askNuPrompt.replace(
          "{country}",
          "${scope_country}"
        )}"`,
        `osascript -e 'on run argv' -e 'set theMessage to item 1 of argv' -e 'tell application "System Events" to tell process "Slack" to keystroke theMessage' -e 'tell application "System Events" to tell process "Slack" to key code 36' -e 'end run' -- "$message"`,
        `echo "[DiagnuCLI] ${texts.waitApproval}"`,
        `printf "${texts.qStep2}"`,
        `read -r shuffle_step2`,
        `shuffle_step2=$(echo "$shuffle_step2" | tr '[:upper:]' '[:lower:]')`,
        `if [[ ! "$shuffle_step2" =~ ${yesRegex} ]]; then echo "[DiagnuCLI] ${texts.stop}"; exit 0; fi`,
        `echo "[DiagnuCLI] ${texts.step3}"`,
        `${openWorkstation}`,
        `echo "[DiagnuCLI] ${texts.oktaHint}"`,
        `printf "${texts.qStep3}"`,
        `read -r shuffle_step3`,
        `shuffle_step3=$(echo "$shuffle_step3" | tr '[:upper:]' '[:lower:]')`,
        `if [[ ! "$shuffle_step3" =~ ${yesRegex} ]]; then echo "[DiagnuCLI] ${texts.stop}"; exit 0; fi`,
        `echo "[DiagnuCLI] ${texts.step4}"`,
        `osascript -e 'tell application "Google Chrome" to quit' || true`,
        `rm -rf ${rmTargets}`,
        `rm -f ${rmCookies}`,
        `echo "[DiagnuCLI] Opening Chrome sync settings"`,
        `open -a "Google Chrome" "chrome://settings/syncSetup"`,
        `echo "[DiagnuCLI] ${texts.done}"`
      ].join("; ");
    }
  },
  "cache-mac": {
    label: "macOS cache cleanup",
    detail: "Remove caches em ~/Library/Caches e /Library/Caches.",
    buildCommand: () => {
      const home = os.homedir();
      return [
        `echo "[DiagnuCLI] macOS cache cleanup started"`,
        `sudo rm -rf "${home}/Library/Caches"`,
        `sudo find /Library/Caches -mindepth 1 -maxdepth 1 -exec rm -rf {} + >/dev/null 2>&1`,
        `echo "[DiagnuCLI] macOS cache cleanup finished"`
      ].join("; ");
    }
  },
  "cache-chrome": {
    label: "Chrome cache cleanup",
    detail: "Fecha o Chrome e remove cache e cookies locais.",
    buildCommand: () => {
      const home = os.homedir();
      const chromeBase = path.join(
        home,
        "Library",
        "Application Support",
        "Google",
        "Chrome",
        "Default"
      );
      const targets = [
        path.join(home, "Library", "Caches", "Google", "Chrome"),
        path.join(chromeBase, "Cache"),
        path.join(chromeBase, "Code Cache"),
        path.join(chromeBase, "GPUCache"),
        path.join(chromeBase, "Service Worker", "CacheStorage")
      ];
      const cookieFiles = [
        path.join(chromeBase, "Cookies"),
        path.join(chromeBase, "Cookies-journal")
      ];
      const rmTargets = targets.map((target) => `"${target}"`).join(" ");
      const rmCookies = cookieFiles.map((file) => `"${file}"`).join(" ");
      return [
        `echo "[DiagnuCLI] Chrome cache cleanup started"`,
        `osascript -e 'tell application "Google Chrome" to quit' || true`,
        `rm -rf ${rmTargets}`,
        `rm -f ${rmCookies}`,
        `echo "[DiagnuCLI] Chrome cache cleanup finished"`
      ].join("; ");
    }
  },
  "clean-clutter": {
    label: "Clean clutter",
    detail: "Abre Armazenamento com recomendações.",
    runDirect: () => {
      const command = `open -b com.apple.systempreferences "x-apple.systempreferences:com.apple.StorageManagement"`;
      spawn("/bin/bash", ["-lc", command], {
        cwd: os.homedir(),
        env: {
          ...process.env,
          PATH: "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        }
      });
    }
  },
  "startup-items": {
    label: "Startup items",
    detail: "Abre Itens de Início nos Ajustes do Sistema.",
    runDirect: () => {
      const command = `open -b com.apple.systempreferences "x-apple.systempreferences:com.apple.LoginItems-Settings.extension"`;
      spawn("/bin/bash", ["-lc", command], {
        cwd: os.homedir(),
        env: {
          ...process.env,
          PATH: "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        }
      });
    }
  },
  "memory-cleanup": {
    label: "Memory cleanup",
    detail: "Executa purge de memória.",
    buildCommand: () => {
      return [
        `echo "[DiagnuCLI] Memory cleanup started"`,
        `if command -v /usr/bin/purge >/dev/null 2>&1; then sudo /usr/bin/purge; else echo "[DiagnuCLI] purge not available"; fi`,
        `echo "[DiagnuCLI] Memory cleanup finished"`
      ].join("; ");
    }
  },
  "update-app": {
    label: "DiagnuCLI app update",
    detail: "Fecha apps e roda o instalador via curl.",
    buildCommand: () => {
      const quitAppsScript = `
        tell application "System Events"
          set keepApps to {"Finder", "Terminal", "System Events"}
          repeat with proc in (application processes whose background only is false)
            set appName to name of proc as text
            if keepApps does not contain appName then
              try
                tell application appName to quit
              end try
            end if
          end repeat
        end tell
      `;
      const repoPath = REPO_PATH;
      return [
        `echo "[DiagnuCLI] Update started"`,
        `osascript -e '${quitAppsScript.replace(/'/g, "'\"'\"'")}'`,
        `sleep 1`,
        `if [ -d "${repoPath}/.git" ]; then git -C "${repoPath}" pull --rebase || git -C "${repoPath}" pull; fi`,
        `curl -fsSL https://raw.githubusercontent.com/Danilow88/Nucli-fix/main/scripts/install-auto.sh | bash`,
        `sleep 1`,
        `open -a "DiagnuCLI" || open -a "Diagnu" || open "/Applications/DiagnuCLI.app" || true`,
        `echo "[DiagnuCLI] Update finished"`
      ].join("; ");
    }
  },
  "update-macos": {
    label: "macOS update",
    detail: "Executa softwareupdate com todas as atualizações.",
    buildCommand: () => {
      return [
        `echo "[DiagnuCLI] macOS update started"`,
        `sudo /usr/sbin/softwareupdate --install --all --force`,
        `echo "[DiagnuCLI] macOS update finished"`
      ].join("; ");
    }
  },
  "manage-disk": {
    label: "Manage disk space",
    detail: "Abre o Spotlight e pesquisa por Armazenamento.",
    runDirect: () => {
      const osa = `
        tell application "System Events"
          key code 49 using {command down}
          delay 0.3
          keystroke "Armazenamento"
          delay 0.2
          key code 36
        end tell
      `;
      spawn("osascript", ["-e", osa]);
    }
  },
  "clean-clutter": {
    label: "Clean clutter",
    detail: "Remove caches/logs do usuário e esvazia a Lixeira.",
    buildCommand: () => {
      const home = os.homedir();
      const cachePath = path.join(home, "Library", "Caches");
      const logsPath = path.join(home, "Library", "Logs");
      return [
        `echo "[DiagnuCLI] Clean clutter started"`,
        `rm -rf "${cachePath}"/* >/dev/null 2>&1 || true`,
        `rm -rf "${logsPath}"/* >/dev/null 2>&1 || true`,
        `osascript -e 'tell application "Finder" to empty the trash' >/dev/null 2>&1 || true`,
        `echo "[DiagnuCLI] Clean clutter finished"`
      ].join("; ");
    }
  },
  "startup-items": {
    label: "Startup items",
    detail: "Abre os itens de login para selecionar apps na inicialização.",
    runDirect: () => {
      logLine("[DiagnuCLI] Opening Login Items in System Settings.");
      spawn("open", [
        "x-apple.systempreferences:com.apple.LoginItems-Settings.extension"
      ]);
    }
  },
  "memory-cleanup": {
    label: "Memory cleanup",
    detail: "Tenta liberar RAM e abre o Monitor de Atividades.",
    buildCommand: () => {
      return [
        `echo "[DiagnuCLI] Memory cleanup started"`,
        `if [ -x /usr/bin/purge ]; then sudo /usr/bin/purge; elif command -v purge >/dev/null 2>&1; then sudo purge; else echo "[DiagnuCLI] purge not available; opening Activity Monitor"; fi`,
        `open -a "Activity Monitor"`,
        `echo "[DiagnuCLI] Memory cleanup finished"`
      ].join("; ");
    }
  },
  "speedtest": {
    label: "Speedtest",
    detail: "Abre o Speedtest dentro do app.",
    runDirect: () => {
      logLine("[DiagnuCLI] Opening Speedtest window.");
      openSpeedtestWindow();
    }
  },
  "nucli-update-credentials": {
    label: "NuCLI update + credentials fix",
    detail: "Atualiza NuCLI e refaz credenciais AWS/CodeArtifact.",
    buildCommand: () => {
      return [
        `echo "[DiagnuCLI] NuCLI update and credentials fix started"`,
        `nu update`,
        `nu aws credentials reset`,
        `nu aws credentials setup`,
        `nu aws profiles-config setup`,
        `nu aws credentials refresh`,
        `nu-br auth get-refresh-token`,
        `nu-mx auth get-refresh-token`,
        `nu-co auth get-refresh-token`,
        `nu-ist auth get-refresh-token`,
        `nu-us-staging auth get-refresh-token --env staging`,
        `nu-mx auth get-refresh-token --env staging`,
        `nu-co auth get-refresh-token --env staging`,
        `nu-br-staging auth get-refresh-token --env staging`,
        `nu aws credentials refresh`,
        `nu aws shared-role-credentials refresh --interactive`,
        `nu codeartifact login maven`,
        `echo "[DiagnuCLI] NuCLI update and credentials fix finished"`
      ].join(" && ");
    }
  },
  "activity-monitor": {
    label: "Open Activity Monitor",
    detail: "Abre o Activity Monitor.",
    runDirect: () => {
      spawn("open", ["-a", "Activity Monitor"]);
    }
  },
  "empty-trash": {
    label: "Empty Trash",
    detail: "Esvazia a Lixeira do Finder.",
    runDirect: () => {
      spawn("osascript", ["-e", 'tell application "Finder" to empty the trash']);
    }
  },
  "fix-time": {
    label: "Fix time",
    detail: "Abre Ajustes do Sistema em Data e Hora.",
    runDirect: () => {
      const osa = `
        tell application "System Events"
          key code 49 using {command down}
          delay 0.3
          keystroke "Date & Time"
          delay 0.2
          key code 36
        end tell
        delay 1.2
        tell application "System Settings" to activate
        delay 0.5
        tell application "System Events"
          tell process "System Settings"
            set frontmost to true
            delay 0.6
            -- Toggle "Set time and date automatically"
            try
              click checkbox "Set time and date automatically" of window 1
            end try
            try
              click checkbox "Definir data e hora automaticamente" of window 1
            end try
            try
              click checkbox "Definir fecha y hora automáticamente" of window 1
            end try
            try
              click (first UI element of window 1 whose role description is "switch" and description contains "Set time and date automatically")
            end try
            try
              click (first UI element of window 1 whose role description is "switch" and description contains "Definir data e hora automaticamente")
            end try
            try
              click (first UI element of window 1 whose role description is "switch" and description contains "Definir fecha y hora automáticamente")
            end try
            delay 0.3
            try
              click button "Set" of window 1
            end try
            try
              click button "Definir" of window 1
            end try
            try
              click button "Establecer" of window 1
            end try
            delay 0.4
            try
              if exists sheet 1 of window 1 then
                tell sheet 1 of window 1
                  try
                    set value of text field 1 to "time.apple.com"
                  end try
                  try
                    click button "OK"
                  end try
                  try
                    click button "Ok"
                  end try
                  try
                    click button "Aceptar"
                  end try
                end tell
              end if
            end try
            delay 0.3
            -- Toggle "Set time zone automatically"
            try
              click checkbox "Set time zone automatically using your current location" of window 1
            end try
            try
              click checkbox "Definir fuso horário automaticamente utilizando a localização atual" of window 1
            end try
            try
              click checkbox "Definir zona horaria automáticamente usando tu ubicación actual" of window 1
            end try
            try
              click (first UI element of window 1 whose role description is "switch" and description contains "Set time zone automatically")
            end try
            try
              click (first UI element of window 1 whose role description is "switch" and description contains "Definir fuso horário automaticamente")
            end try
            try
              click (first UI element of window 1 whose role description is "switch" and description contains "Definir zona horaria automáticamente")
            end try
          end tell
        end tell
      `;
      spawn("osascript", ["-e", osa]);
    }
  },
  "uninstall-apps": {
    label: "Uninstall apps",
    detail: "Lista apps e move os selecionados para a Lixeira.",
    runDirect: () => {
      const osa = `
        set appEntries to {}
        set appPaths to {}
        try
          set sysPaths to paragraphs of (do shell script "find /Applications -maxdepth 1 -type d -name '*.app' 2>/dev/null")
          repeat with p in sysPaths
            if (p as text) is not "" then set end of appPaths to (p as text)
          end repeat
        end try
        try
          set homePaths to paragraphs of (do shell script "find ~/Applications -maxdepth 1 -type d -name '*.app' 2>/dev/null")
          repeat with p in homePaths
            if (p as text) is not "" then set end of appPaths to (p as text)
          end repeat
        end try
        repeat with appPath in appPaths
          try
            set appName to do shell script "basename " & quoted form of (appPath as text)
            set end of appEntries to appName & " — " & (appPath as text)
          end try
        end repeat
        if (count of appEntries) is 0 then
          display dialog "Nenhum app encontrado para desinstalar." buttons {"OK"} default button "OK"
          return
        end if
        set chosen to choose from list appEntries with prompt "Selecione os apps para desinstalar" with multiple selections allowed
        if chosen is false then return
        set AppleScript's text item delimiters to " — "
        set authPrompt to "Use Touch ID ou senha para remover o app selecionado."
        repeat with entry in chosen
          try
            set appPath to text item 2 of (entry as text)
            set appName to do shell script "basename " & quoted form of appPath
            set trashPath to (POSIX path of (path to home folder)) & ".Trash"
            set destPath to trashPath & "/" & appName
            try
              if (do shell script "test -e " & quoted form of destPath & " && echo 1 || echo 0") is "1" then
                set suffix to do shell script "date +%s"
                set destPath to trashPath & "/" & suffix & "-" & appName
              end if
            end try
            do shell script "mv " & quoted form of appPath & " " & quoted form of destPath with administrator privileges with prompt authPrompt
            -- remove residuals for this app name
            set appBase to do shell script "basename " & quoted form of appName & " .app"
            set homePath to POSIX path of (path to home folder)
            set cleanupTargets to {¬
              homePath & "Library/Application Support/" & appBase, ¬
              homePath & "Library/Caches/" & appBase, ¬
              homePath & "Library/Preferences/" & appBase & ".plist", ¬
              homePath & "Library/Logs/" & appBase, ¬
              homePath & "Library/Saved Application State/" & appBase & ".savedState", ¬
              homePath & "Library/Containers/" & appBase, ¬
              homePath & "Library/Group Containers/" & appBase, ¬
              "/Library/Application Support/" & appBase, ¬
              "/Library/Caches/" & appBase, ¬
              "/Library/Preferences/" & "com." & appBase & ".*"}
            repeat with t in cleanupTargets
              try
                do shell script "rm -rf " & quoted form of (t as text) with administrator privileges with prompt authPrompt
              end try
            end repeat
          end try
        end repeat
        set AppleScript's text item delimiters to ""
        try
          tell application "Finder" to empty the trash
        end try
      `;
      spawn("osascript", ["-e", osa]);
    }
  },
  "open-keychain": {
    label: "Open Keychain",
    detail: "Abre Keychain e seleciona login/Meus Certificados.",
    runDirect: () => {
      openKeychainMyCertificates();
    }
  },
  "open-touch-id": {
    label: "Open Touch ID & Password",
    detail: "Abre Touch ID & Password via Spotlight.",
    runDirect: () => {
      const osa = `
        tell application "System Events"
          key code 49 using {command down}
          delay 0.3
          keystroke "Touch ID & Password"
          delay 0.2
          key code 36
        end tell
        delay 1.2
        tell application "System Settings" to activate
        delay 0.4
        tell application "System Events"
          tell process "System Settings"
            set frontmost to true
            delay 0.3
            try
              click button "Add Fingerprint" of window 1
            end try
            try
              click button "Adicionar impressão digital" of window 1
            end try
            try
              click button "Agregar huella digital" of window 1
            end try
          end tell
        end tell
      `;
      spawn("osascript", ["-e", osa]);
    }
  },
  "open-mac-setup": {
    label: "Open Mac setup guide",
    detail: "Abre o guia de configuração do Mac no Chrome.",
    runDirect: () => {
      openMacSetupInChrome();
    }
  },
  "open-okta-passwords": {
    label: "Open Okta passwords",
    detail: "Abre o gerenciador de senhas do Chrome filtrado por Okta.",
    runDirect: () => {
      openOktaPasswordsInChrome();
    }
  },
  "restart-vpn": {
    label: "Restart VPN (Zscaler)",
    detail: "Fecha e reabre o Zscaler.app e abre o link do Okta no Chrome.",
    runDirect: () => {
      const osa = `
        tell application "Zscaler" to quit
        repeat with i from 1 to 20
          delay 0.2
          tell application "System Events"
            if not (exists process "Zscaler") then exit repeat
          end tell
        end repeat
      `;
      spawn("osascript", ["-e", osa]);
      setTimeout(() => {
        spawn("pkill", ["-x", "Zscaler"]);
        setTimeout(() => {
          spawn("open", ["-a", "Zscaler"]);
          setTimeout(() => {
            openZscalerOktaInChrome();
          }, 800);
        }, 600);
      }, 900);
    }
  },
  "open-oncall": {
    label: "Open WhatsApp on-call",
    detail: "Abre o WhatsApp para +55 11 95185-7554.",
    runDirect: () => {
      spawn("open", ["-a", "WhatsApp", ONCALL_WHATSAPP_URL]);
      setTimeout(() => {
        spawn("open", [ONCALL_WHATSAPP_URL]);
      }, 500);
    }
  },
  "request-laptop": {
    label: "Request laptop replacement",
    detail: "Abre o formulário de troca de laptop no Chrome.",
    runDirect: () => {
      openLaptopRequestInChrome();
    }
  },
  "optimize-performance": {
    label: "Optimize macOS performance",
    detail: "Executa o script optimize-performance.sh.",
    buildCommand: () => {
      return [
        `echo "[DiagnuCLI] Performance tune started"`,
        `if [ ! -f "${PERFORMANCE_SCRIPT_PATH}" ]; then echo "[DiagnuCLI] Script not found: ${PERFORMANCE_SCRIPT_PATH}"; exit 1; fi`,
        `bash "${PERFORMANCE_SCRIPT_PATH}"`,
        `echo "[DiagnuCLI] Performance tune finished"`
      ].join("; ");
    }
  }
};

function runMaintenanceAction(actionId, lang) {
  const action = MAINTENANCE_ACTIONS[actionId];
  if (!action) {
    return { ok: false, reason: "unknown action" };
  }

  if (action.runDirect) {
    logLine(`[DiagnuCLI] ${action.label}: ${action.detail}`);
    action.runDirect();
    sendStatus({ actionStarted: action.label });
    return { ok: true };
  }

  ensureLogFile();

  startLogTail();

  const closeTerminal = `osascript -e 'tell application "Terminal" to close front window'`;
  const command = `(${action.buildCommand(lang)}; ${closeTerminal}) | tee -a "${LOG_PATH}"`;
  logLine(`[DiagnuCLI] ${action.label}: ${action.detail}`);
  const escaped = escapeAppleScript(command);
  const osa = [
    'tell application "Terminal" to activate',
    `tell application "Terminal" to do script "${escaped}"`
  ];
  spawn("osascript", ["-e", osa[0], "-e", osa[1]]);
  sendStatus({ actionStarted: action.label });
  return { ok: true };
}

ipcMain.handle("run-action", (_event, actionId, lang) => {
  return runMaintenanceAction(actionId, lang);
});

ipcMain.handle("open-rovo", () => {
  logLine(`[DiagnuCLI] Open Rovo support: ${ROVO_URL}`);
  openRovoInChrome();
  return { ok: true, url: ROVO_URL };
});

ipcMain.handle("open-support", () => {
  logLine(`[DiagnuCLI] Open support portal: ${SUPPORT_URL}`);
  openSupportInChrome();
  return { ok: true, url: SUPPORT_URL };
});

ipcMain.handle("open-gadgets-request", () => {
  logLine(`[DiagnuCLI] Open gadgets request: ${GADGETS_REQUEST_URL}`);
  openGadgetsRequestInChrome();
  return { ok: true, url: GADGETS_REQUEST_URL };
});

ipcMain.handle("open-people-request", () => {
  logLine(`[DiagnuCLI] Open People request: ${PEOPLE_REQUEST_URL}`);
  openPeopleRequestInChrome();
  return { ok: true, url: PEOPLE_REQUEST_URL };
});

ipcMain.handle("open-certificates", () => {
  logLine(`[DiagnuCLI] Open certificates: ${WORKSTATION_IDENTITY_URL}`);
  openCertificatesInChrome();
  return { ok: true, url: WORKSTATION_IDENTITY_URL };
});

ipcMain.handle("open-shuffle-fix", () => {
  logLine(`[DiagnuCLI] Open Shuffle Fix request: ${SHUFFLE_FIX_URL}`);
  openShuffleFixInChrome();
  return { ok: true, url: SHUFFLE_FIX_URL };
});

ipcMain.handle("open-laptop-request", () => {
  logLine(`[DiagnuCLI] Open laptop request: ${LAPTOP_REQUEST_URL}`);
  openLaptopRequestInChrome();
  return { ok: true, url: LAPTOP_REQUEST_URL };
});

ipcMain.handle("open-setup-help", () => {
  logLine(`[DiagnuCLI] Open Slack Setup Help channel`);
  openSetupHelpInChrome();
  return { ok: true, url: SETUP_HELP_URL };
});

ipcMain.handle("open-ask-nu", () => {
  logLine(`[DiagnuCLI] Open Slack AskNu`);
  openAskNuInSlack();
  return { ok: true };
});

ipcMain.handle("open-zscaler-feedback", () => {
  logLine(`[DiagnuCLI] Open Slack zscaler-feedback-tmp`);
  openZscalerFeedbackInSlack();
  return { ok: true };
});

ipcMain.handle("exit-app", () => {
  app.quit();
  return { ok: true };
});

ipcMain.handle("minimize-app", () => {
  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.minimize();
  }
  return { ok: true };
});

ipcMain.handle("maximize-app", () => {
  if (mainWindow && !mainWindow.isDestroyed()) {
    if (mainWindow.isMaximized()) {
      mainWindow.unmaximize();
    } else {
      mainWindow.maximize();
    }
  }
  return { ok: true };
});

ipcMain.handle("toggle-tray-mode", () => {
  if (trayModeEnabled) {
    disableTrayMode();
  } else {
    enableTrayMode();
  }
  return { ok: true, enabled: trayModeEnabled };
});

ipcMain.handle("toggle-auto-cache", () => {
  if (autoCacheEnabled) {
    disableAutoCache();
  } else {
    enableAutoCache();
  }
  return { ok: true, enabled: autoCacheEnabled };
});

ipcMain.handle("get-system-stats", () => {
  const { cpuPercent, memPercent } = getResourceStats();
  const diskPercent = getDiskUsagePercent();
  return {
    cpuPercent,
    memPercent,
    diskPercent: diskPercent ?? 0
  };
});

ipcMain.handle("clear-log", () => {
  ensureLogFile();
  fs.writeFileSync(LOG_PATH, "");
  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.webContents.send("run-log", "");
  }
  return { ok: true };
});

ipcMain.handle("rovo-send-text", (_event, text) => {
  if (!text) {
    return { ok: false, reason: "empty" };
  }
  const escapedText = String(text).replace(/\\/g, "\\\\").replace(/"/g, '\\"');
  const osa = `
    set rovoUrl to "${ROVO_URL}"
    tell application "Google Chrome"
      if (count of windows) = 0 then return
      set targetWindow to front window
      set targetTab to missing value
      repeat with t in tabs of targetWindow
        if (URL of t as text) is rovoUrl then
          set targetTab to t
          exit repeat
        end if
      end repeat
      if targetTab is missing value then
        set targetTab to make new tab at end of tabs of targetWindow with properties {URL: rovoUrl}
      end if
      set active tab index of targetWindow to (index of targetTab)
    end tell
    delay 0.5
    tell application "Google Chrome" to execute front window's active tab javascript "
      (function () {
        const el =
          document.querySelector('[contenteditable=\\\"true\\\"]') ||
          document.querySelector('textarea, input[type=\\\"text\\\"]');
        if (!el) return;
        el.focus();
        el.value = (el.value || '') + \\"${escapedText}\\";
        el.dispatchEvent(new Event('input', { bubbles: true }));
      })();
    "
  `;
  spawn("osascript", ["-e", osa]);
  return { ok: true };
});

ipcMain.handle("open-mic-permissions", () => {
  spawn("open", [
    "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone"
  ]);
  return { ok: true };
});

app.whenReady().then(() => {
  app.setName(APP_NAME);
  if (process.platform === "darwin" && !app.isPackaged) {
    app.dock.setIcon(DEV_ICON_PATH);
  }
  closeAllTerminalWindows();
  createWindow();
  ensureAccessibilityAccess();
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") {
    app.quit();
  }
});

app.on("activate", () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});
