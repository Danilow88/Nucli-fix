const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("diagnucli", {
  start: () => ipcRenderer.invoke("start-run"),
  onLog: (handler) => ipcRenderer.on("run-log", (_event, data) => handler(data)),
  onStatus: (handler) =>
    ipcRenderer.on("run-status", (_event, payload) => handler(payload)),
  sendChoice: (choice) => ipcRenderer.invoke("send-choice", choice),
  sendText: (text, pressEnter = false) =>
    ipcRenderer.invoke("send-text", text, pressEnter),
  runAction: (actionId) => ipcRenderer.invoke("run-action", actionId),
  openRovo: () => ipcRenderer.invoke("open-rovo"),
  sendToRovo: (text) => ipcRenderer.invoke("rovo-send-text", text),
  sendVoiceTextToChrome: (text) => ipcRenderer.invoke("send-voice-to-chrome", text),
  startChromeDictation: () => ipcRenderer.invoke("start-chrome-dictation"),
  openMicPermissions: () => ipcRenderer.invoke("open-mic-permissions"),
  openMicrophonePermissions: () =>
    ipcRenderer.invoke("open-microphone-permissions"),
  requestMicrophone: () => ipcRenderer.invoke("request-microphone")
});
