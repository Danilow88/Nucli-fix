const { app, BrowserWindow, ipcMain } = require("electron");
const path = require("path");
const os = require("os");
const fs = require("fs");
const { spawn } = require("child_process");

let mainWindow = null;
let tailProcess = null;
let runStarted = false;

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
const ROVO_URL =
  "https://home.atlassian.com/o/2c2ebb29-8407-4659-a7d0-69bbf5b745ce/chat?rovoChatPathway=chat&rovoChatCloudId=c43390d3-e5f8-43ca-9eec-c382a5220bd9&rovoChatAgentId=01c47565-9fcc-4e41-8db8-2706b4631f9f&cloudId=c43390d3-e5f8-43ca-9eec-c382a5220bd9";
const SUPPORT_URL = "https://nubank.atlassian.net/servicedesk/customer/portal/131";
const GUIDE_URL_BASE =
  "https://nubank.atlassian.net/wiki/spaces/ITKB/pages/262490555235/How+to+Configure+NuCli+on+MacBook";
const SETUP_HELP_URL = "https://nubank.enterprise.slack.com/archives/CBJGG73AM";
const SETUP_HELP_CHANNEL_ID = "CBJGG73AM";
const APP_NAME = "DiagnuCLI";
const DEV_ICON_PATH = path.join(__dirname, "assets", "icon.png");

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

function openKeychainMyCertificates() {
  const osa = `
    tell application "Keychain Access" to activate
    delay 0.4
    tell application "System Events"
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
  fs.mkdirSync(path.dirname(LOG_PATH), { recursive: true });
  if (!fs.existsSync(LOG_PATH)) {
    fs.writeFileSync(LOG_PATH, "");
  }

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
  "cache-mac": {
    label: "macOS cache cleanup",
    buildCommand: () => {
      const home = os.homedir();
      return [
        `echo "[DiagnuCLI] macOS cache cleanup started"`,
        `rm -rf "${home}/Library/Caches"`,
        `sudo rm -rf /Library/Caches/*`,
        `echo "[DiagnuCLI] macOS cache cleanup finished"`
      ].join("; ");
    }
  },
  "cache-chrome": {
    label: "Chrome cache cleanup",
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
  "update-app": {
    label: "DiagnuCLI app update",
    buildCommand: () => {
      const repo = REPO_PATH;
      const electronDir = path.join(repo, "diagnucli-electron");
      const relaunch = [
        `osascript -e 'tell application "DiagnuCLI" to quit' || true`,
        `sleep 1`,
        `open -a "/Applications/DiagnuCLI.app"`
      ].join("; ");
      return [
        `echo "[DiagnuCLI] Update started"`,
        `if [ ! -d "${repo}/.git" ]; then echo "[DiagnuCLI] Repo not found: ${repo}"; exit 1; fi`,
        `cd "${repo}"`,
        `git pull`,
        `cd "${electronDir}"`,
        `./install.sh`,
        `echo "[DiagnuCLI] Update finished"`,
        relaunch
      ].join("; ");
    }
  },
  "update-macos": {
    label: "macOS update",
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
    runDirect: () => {
      spawn("open", ["x-apple.systempreferences:com.apple.SystemSettings?pane=General"]);
      setTimeout(() => {
        spawn("open", [
          "x-apple.systempreferences:com.apple.SystemSettings?pane=General&section=Storage"
        ]);
      }, 600);
    }
  },
  "activity-monitor": {
    label: "Open Activity Monitor",
    runDirect: () => {
      spawn("open", ["-a", "Activity Monitor"]);
    }
  },
  "empty-trash": {
    label: "Empty Trash",
    runDirect: () => {
      spawn("osascript", ["-e", 'tell application "Finder" to empty the trash']);
    }
  },
  "open-keychain": {
    label: "Open Keychain",
    runDirect: () => {
      openKeychainMyCertificates();
    }
  }
};

function runMaintenanceAction(actionId) {
  const action = MAINTENANCE_ACTIONS[actionId];
  if (!action) {
    return { ok: false, reason: "unknown action" };
  }

  if (action.runDirect) {
    action.runDirect();
    sendStatus({ actionStarted: action.label });
    return { ok: true };
  }

  fs.mkdirSync(path.dirname(LOG_PATH), { recursive: true });
  if (!fs.existsSync(LOG_PATH)) {
    fs.writeFileSync(LOG_PATH, "");
  }

  startLogTail();

  const closeTerminal = `osascript -e 'tell application "Terminal" to close front window'`;
  const command = `(${action.buildCommand()}; ${closeTerminal}) | tee -a "${LOG_PATH}"`;
  const escaped = escapeAppleScript(command);
  const osa = [
    'tell application "Terminal" to activate',
    `tell application "Terminal" to do script "${escaped}"`
  ];
  spawn("osascript", ["-e", osa[0], "-e", osa[1]]);
  sendStatus({ actionStarted: action.label });
  return { ok: true };
}

ipcMain.handle("run-action", (_event, actionId) => {
  return runMaintenanceAction(actionId);
});

ipcMain.handle("open-rovo", () => {
  openRovoInChrome();
  return { ok: true, url: ROVO_URL };
});

ipcMain.handle("open-support", () => {
  openSupportInChrome();
  return { ok: true, url: SUPPORT_URL };
});

ipcMain.handle("open-setup-help", () => {
  openSetupHelpInChrome();
  return { ok: true, url: SETUP_HELP_URL };
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
  createWindow();
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
