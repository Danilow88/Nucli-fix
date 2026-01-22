const { app, BrowserWindow, ipcMain } = require("electron");
const path = require("path");
const os = require("os");
const fs = require("fs");
const { spawn } = require("child_process");
const pty = require("node-pty");

let mainWindow = null;
let tailProcess = null;
let runStarted = false;
let ptyProcess = null;

const DEFAULT_SCRIPT_PATH = app.isPackaged
  ? path.join(process.resourcesPath, "diagnucli")
  : path.resolve(__dirname, "..", "diagnucli");
const SCRIPT_PATH = process.env.DIAGNUCLI_PATH || DEFAULT_SCRIPT_PATH;
const DEFAULT_REPO_PATH = path.join(os.homedir(), "Nucli-fix");
const REPO_PATH = process.env.DIAGNUCLI_REPO_PATH || DEFAULT_REPO_PATH;
const LOG_PATH = path.join(app.getPath("userData"), "diagnucli.log");
const ROVO_URL =
  "https://home.atlassian.com/o/2c2ebb29-8407-4659-a7d0-69bbf5b745ce/chat?rovoChatPathway=chat&rovoChatCloudId=c43390d3-e5f8-43ca-9eec-c382a5220bd9&rovoChatAgentId=01c47565-9fcc-4e41-8db8-2706b4631f9f&cloudId=c43390d3-e5f8-43ca-9eec-c382a5220bd9";
const SUPPORT_URL = "https://nubank.atlassian.net/servicedesk/customer/portal/131";

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 760,
    backgroundColor: "#1B0B2E",
    title: "DiagnuCLI",
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

function startPtyRun() {
  if (ptyProcess) {
    return;
  }

  const exists = fs.existsSync(SCRIPT_PATH);
  fs.mkdirSync(path.dirname(LOG_PATH), { recursive: true });
  fs.writeFileSync(LOG_PATH, "");

  sendStatus({
    scriptPath: SCRIPT_PATH,
    logPath: LOG_PATH,
    exists
  });

  const command = exists
    ? `export TERM=xterm-256color; export JAVA_TOOL_OPTIONS="--enable-native-access=ALL-UNNAMED"; ` +
      `export DIAGNUCLI_LOG_PATH="${LOG_PATH}"; bash "${SCRIPT_PATH}"`
    : `echo "Script not found: ${SCRIPT_PATH}"`;

  const shell = process.env.SHELL || "/bin/bash";
  ptyProcess = pty.spawn(shell, ["-lc", command], {
    name: "xterm-256color",
    cwd: os.homedir(),
    cols: 100,
    rows: 30,
    env: {
      ...process.env,
      TERM: "xterm-256color",
      JAVA_TOOL_OPTIONS: "--enable-native-access=ALL-UNNAMED"
    }
  });

  ptyProcess.onData((data) => {
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.webContents.send("pty-data", data);
    }
  });

  ptyProcess.onExit(() => {
    ptyProcess = null;
  });
}

function startRun() {
  if (runStarted) {
    return;
  }
  runStarted = true;

  startPtyRun();
}

ipcMain.handle("start-run", () => {
  startRun();
  return { scriptPath: SCRIPT_PATH, logPath: LOG_PATH, started: true };
});

function sendTextToTerminal(text, pressEnter = false) {
  if (!ptyProcess) {
    startPtyRun();
  }
  if (!ptyProcess) {
    return;
  }
  const textValue = String(text);
  ptyProcess.write(textValue);
  if (pressEnter) {
    ptyProcess.write("\r");
  }
}

ipcMain.handle("send-choice", (_event, choice) => {
  sendTextToTerminal(`${choice}`, true);
  return { ok: true };
});

ipcMain.handle("send-text", (_event, text, pressEnter = false) => {
  sendTextToTerminal(text, pressEnter);
  return { ok: true };
});

ipcMain.handle("start-pty", () => {
  startPtyRun();
  return { ok: true };
});

ipcMain.on("pty-input", (_event, data) => {
  if (!ptyProcess) {
    startPtyRun();
  }
  if (ptyProcess) {
    ptyProcess.write(String(data));
  }
});

ipcMain.on("pty-resize", (_event, cols, rows) => {
  if (ptyProcess) {
    ptyProcess.resize(cols, rows);
  }
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
  }
};

function runMaintenanceAction(actionId) {
  const action = MAINTENANCE_ACTIONS[actionId];
  if (!action) {
    return { ok: false, reason: "unknown action" };
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

app.whenReady().then(createWindow);

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
