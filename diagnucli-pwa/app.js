const installButton = document.getElementById("installPwa");
const copyButton = document.getElementById("copyCli");
const rovoButton = document.getElementById("openRovo");
const supportButton = document.getElementById("openSupport");
const langButtons = document.querySelectorAll(".lang-btn");

const ROVO_URL =
  "https://home.atlassian.com/o/2c2ebb29-8407-4659-a7d0-69bbf5b745ce/chat?rovoChatPathway=chat&rovoChatCloudId=c43390d3-e5f8-43ca-9eec-c382a5220bd9&rovoChatAgentId=01c47565-9fcc-4e41-8db8-2706b4631f9f&cloudId=c43390d3-e5f8-43ca-9eec-c382a5220bd9";
const SUPPORT_URL = "https://nubank.atlassian.net/servicedesk/customer/portal/131";

let deferredPrompt = null;
let currentLang = "pt";

const translations = {
  pt: {
    subtitle: "Diagnóstico interativo NuCLI + AWS + Suporte em geral",
    installPwa: "Instalar PWA",
    quickTitle: "Acesso rápido",
    rovoTitle: "Abrir Rovo (Suporte)",
    rovoDesc: "Abre o chat no Google Chrome.",
    supportTitle: "Abrir chamado (Suporte)",
    supportDesc: "Abre o portal de chamados da Nubank.",
    cliTitle: "Rodar diagnucli via Terminal",
    copyCommand: "Copiar",
    pwaNote: "PWA nao executa comandos locais. Use o Terminal para rodar o diagnucli.",
    howTitle: "Como funciona",
    howList: [
      "A PWA centraliza links de suporte e orientacoes.",
      "Use o Terminal para executar o diagnucli localmente.",
      "O modo CLI evita bloqueios de politica corporativa."
    ],
    noteTitle: "Importante",
    noteList: [
      "O navegador precisa estar logado para acessar Rovo/portal.",
      "A PWA funciona offline para o conteudo basico."
    ]
  },
  en: {
    subtitle: "Interactive NuCLI + AWS + General support",
    installPwa: "Install PWA",
    quickTitle: "Quick access",
    rovoTitle: "Open Rovo (Support)",
    rovoDesc: "Opens chat in Google Chrome.",
    supportTitle: "Open ticket (Support)",
    supportDesc: "Opens Nubank support portal.",
    cliTitle: "Run diagnucli via Terminal",
    copyCommand: "Copy",
    pwaNote: "PWA cannot run local commands. Use Terminal to run diagnucli.",
    howTitle: "How it works",
    howList: [
      "The PWA centralizes support links and guidance.",
      "Use Terminal to run diagnucli locally.",
      "CLI mode avoids corporate policy blocks."
    ],
    noteTitle: "Important",
    noteList: [
      "You must be logged in to access Rovo/portal.",
      "PWA works offline for basic content."
    ]
  }
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
  langButtons.forEach((btn) => {
    btn.classList.toggle("active", btn.dataset.lang === lang);
  });
};

window.addEventListener("beforeinstallprompt", (event) => {
  event.preventDefault();
  deferredPrompt = event;
  installButton.disabled = false;
});

installButton.addEventListener("click", async () => {
  if (!deferredPrompt) {
    return;
  }
  deferredPrompt.prompt();
  await deferredPrompt.userChoice;
  deferredPrompt = null;
});

copyButton.addEventListener("click", async () => {
  const command = document.getElementById("cliCommand").textContent.trim();
  try {
    await navigator.clipboard.writeText(command);
    copyButton.textContent = currentLang === "pt" ? "Copiado" : "Copied";
    setTimeout(() => {
      copyButton.textContent =
        translations[currentLang].copyCommand || "Copiar";
    }, 1200);
  } catch {
    copyButton.textContent = currentLang === "pt" ? "Erro" : "Error";
  }
});

rovoButton.addEventListener("click", () => {
  window.open(ROVO_URL, "_blank", "noopener");
});

supportButton.addEventListener("click", () => {
  window.open(SUPPORT_URL, "_blank", "noopener");
});

langButtons.forEach((btn) => {
  btn.addEventListener("click", () => updateLang(btn.dataset.lang));
});

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("./service-worker.js");
  });
}

updateLang(currentLang);
