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
const LOG_PATH = path.join(app.getPath("userData"), "diagnucli.log");

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

  const runCommand = exists
    ? `TERM=xterm-256color JAVA_TOOL_OPTIONS="--enable-native-access=ALL-UNNAMED" ` +
      `DIAGNUCLI_LOG_PATH="${LOG_PATH}" /usr/bin/script -q -a "${LOG_PATH}" bash "${SCRIPT_PATH}"`
    : `echo "Script not found: ${SCRIPT_PATH}" | tee -a "${LOG_PATH}"`;

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
