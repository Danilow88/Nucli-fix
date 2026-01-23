const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("diagnucli", {
  start: () => ipcRenderer.invoke("start-run"),
  onLog: (handler) => ipcRenderer.on("run-log", (_event, data) => handler(data)),
  onStatus: (handler) =>
    ipcRenderer.on("run-status", (_event, payload) => handler(payload)),
  sendChoice: (choice) => ipcRenderer.invoke("send-choice", choice),
  sendText: (text, pressEnter = false) =>
    ipcRenderer.invoke("send-text", text, pressEnter),
  installNucli: () => ipcRenderer.invoke("install-nucli"),
  runAction: (actionId) => ipcRenderer.invoke("run-action", actionId),
  openRovo: () => ipcRenderer.invoke("open-rovo"),
  openSupport: () => ipcRenderer.invoke("open-support"),
  sendToRovo: (text) => ipcRenderer.invoke("rovo-send-text", text),
  openMicPermissions: () => ipcRenderer.invoke("open-mic-permissions")
});
