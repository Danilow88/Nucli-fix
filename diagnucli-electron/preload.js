const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("diagnucli", {
  start: () => ipcRenderer.invoke("start-run"),
  onLog: (handler) => ipcRenderer.on("run-log", (_event, data) => handler(data)),
  onStatus: (handler) =>
    ipcRenderer.on("run-status", (_event, payload) => handler(payload)),
  sendChoice: (choice) => ipcRenderer.invoke("send-choice", choice),
  sendText: (text, pressEnter = false) =>
    ipcRenderer.invoke("send-text", text, pressEnter),
  installNucli: (lang) => ipcRenderer.invoke("install-nucli", lang),
  runAction: (actionId, lang) => ipcRenderer.invoke("run-action", actionId, lang),
  openRovo: () => ipcRenderer.invoke("open-rovo"),
  openSupport: () => ipcRenderer.invoke("open-support"),
  openGadgetsRequest: () => ipcRenderer.invoke("open-gadgets-request"),
  openPeopleRequest: () => ipcRenderer.invoke("open-people-request"),
  openShuffleFix: () => ipcRenderer.invoke("open-shuffle-fix"),
  openCertificates: () => ipcRenderer.invoke("open-certificates"),
  openSetupHelp: () => ipcRenderer.invoke("open-setup-help"),
  openAskNu: () => ipcRenderer.invoke("open-ask-nu"),
  openZscalerFeedback: () => ipcRenderer.invoke("open-zscaler-feedback"),
  sendToRovo: (text) => ipcRenderer.invoke("rovo-send-text", text),
  openMicPermissions: () => ipcRenderer.invoke("open-mic-permissions"),
  minimizeApp: () => ipcRenderer.invoke("minimize-app"),
  maximizeApp: () => ipcRenderer.invoke("maximize-app"),
  toggleTrayMode: () => ipcRenderer.invoke("toggle-tray-mode"),
  toggleAutoCache: () => ipcRenderer.invoke("toggle-auto-cache"),
  exitApp: () => ipcRenderer.invoke("exit-app"),
  clearLog: () => ipcRenderer.invoke("clear-log")
});
