const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("diagnucli", {
  start: () => ipcRenderer.invoke("start-run"),
  startPty: () => ipcRenderer.invoke("start-pty"),
  onLog: (handler) => ipcRenderer.on("run-log", (_event, data) => handler(data)),
  onStatus: (handler) =>
    ipcRenderer.on("run-status", (_event, payload) => handler(payload)),
  onPtyData: (handler) =>
    ipcRenderer.on("pty-data", (_event, data) => handler(data)),
  sendPtyInput: (data) => ipcRenderer.send("pty-input", data),
  resizePty: (cols, rows) => ipcRenderer.send("pty-resize", cols, rows),
  sendChoice: (choice) => ipcRenderer.invoke("send-choice", choice),
  sendText: (text, pressEnter = false) =>
    ipcRenderer.invoke("send-text", text, pressEnter),
  runAction: (actionId) => ipcRenderer.invoke("run-action", actionId),
  openRovo: () => ipcRenderer.invoke("open-rovo"),
  openSupport: () => ipcRenderer.invoke("open-support"),
  sendToRovo: (text) => ipcRenderer.invoke("rovo-send-text", text),
  openMicPermissions: () => ipcRenderer.invoke("open-mic-permissions")
});

contextBridge.exposeInMainWorld("xterm", {
  Terminal: require("xterm").Terminal,
  FitAddon: require("xterm-addon-fit").FitAddon
});
