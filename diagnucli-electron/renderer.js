const logOutput = document.getElementById("logOutput");
const statusText = document.getElementById("statusText");
const startButton = document.getElementById("startButton");
const langButtons = document.querySelectorAll(".lang-btn");
const menuCards = document.querySelectorAll(".menu-card[data-option]");
const actionCards = document.querySelectorAll("[data-action]");
const setupHelpButton = document.getElementById("openSetupHelp");
const askNuButton = document.getElementById("openAskNu");
const zscalerFeedbackButton = document.getElementById("openZscalerFeedback");
const gadgetsButton = document.getElementById("openGadgets");
const peopleButton = document.getElementById("openPeople");
const certificatesButton = document.getElementById("openCertificates");
const rovoButton = document.getElementById("openRovo");
const supportButton = document.getElementById("openSupport");
const searchInput = document.getElementById("buttonSearch");
const infoOverlay = document.getElementById("infoOverlay");
const infoOverlayTitle = document.getElementById("infoOverlayTitle");
const infoOverlayBody = document.getElementById("infoOverlayBody");
const infoOverlayClose = document.getElementById("infoOverlayClose");
const monitorCpuValue = document.getElementById("monitorCpuValue");
const monitorMemValue = document.getElementById("monitorMemValue");
const monitorDiskValue = document.getElementById("monitorDiskValue");
const monitorCpuBar = document.getElementById("monitorCpuBar");
const monitorMemBar = document.getElementById("monitorMemBar");
const monitorDiskBar = document.getElementById("monitorDiskBar");
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
    statusIdle: "Aguardando início. O Terminal do macOS abrirá em segundo plano.",
    hint:
      "Digite e responda no Terminal do macOS. Aqui você acompanha os comandos sendo executados.",
    opt1Title: "Verificação completa - setup NuCLI AWS",
    opt1Desc: "Executa todos os checks do NuCLI/AWS e gera relatório.",
    opt7Title: "Testar comandos NuCLI",
    opt7Desc: "Roda nu doctor, versões e comandos-chave.",
    installNucliTitle: "Instalar NuCLI",
    installNucliDesc: "Passo a passo de acesso, SSH, Homebrew e AWS.",
    gnuChconTitle: 'Error: "GNU version of chcon was not found" fix',
    gnuChconDesc:
      "Este erro ocorre por divergência de versões/caminhos. Vai para ~/dev/nu/nucli e roda git pull --rebase.",
    javaRuntimeTitle: "Unable to locate a Java Runtime Fix",
    javaRuntimeDesc: "Instala o Java (Temurin) via Homebrew.",
    bashUnboundTitle:
      "ERRO: Your Bash version is ancient...unbound variable fix",
    bashUnboundDesc: "Restaura o PATH e variáveis do NuCLI no .zshrc.",
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
    cleanClutterTitle: "Clean clutter",
    cleanClutterDesc: "Abre Armazenamento com recomendações de limpeza.",
    cleanClutterTip: "Mostra recomendações para liberar espaço.",
    startupItemsTitle: "Selecionar dispositivos para iniciar",
    startupItemsDesc: "Abre Itens de Início nos Ajustes do Sistema.",
    startupItemsTip: "Gerencie apps que iniciam com o macOS.",
    memoryCleanupTitle: "Limpeza de Memoria",
    memoryCleanupDesc: "Alivia memória RAM limpando buffers.",
    memoryCleanupTip: "Executa purge de memória (pode pedir senha).",
    updateTitle: "Atualizar o app",
    updateDesc: "Atualiza via Git e reinstala o app.",
    updateHeader: "Atualizar app",
    updateHeaderTip: "Atualiza o DiagnuCLI a partir do Git.",
    minimizeHeader: "Minimizar",
    minimizeHeaderTip: "Minimiza o DiagnuCLI para o Dock.",
    maximizeHeaderTip: "Alterna entre maximizar e restaurar a janela.",
    searchPlaceholder: "Buscar botões...",
    logTitle: "Logs do Terminal",
    clearLogButton: "Limpar logs",
    clearLogTip: "Limpa o histórico exibido no painel de logs.",
    macosUpdateTitle: "Atualizar macOS",
    macosUpdateDesc: "Verifica e instala atualizações do macOS.",
    manageDiskTitle: "Gerenciar espaço de HD",
    manageDiskDesc: "Abre Armazenamento via Spotlight.",
    optimizePerfTitle: "Melhorar performance do Mac",
    optimizePerfDesc: "Executa script de desempenho e limpeza.",
    cleanClutterTitle: "Clean clutter",
    cleanClutterDesc:
      "Abre o gerenciamento de armazenamento para liberar espaço.",
    cleanClutterTip: "Abre o painel de Armazenamento do macOS.",
    startupItemsTitle: "Selecionar dispositivos para iniciar",
    startupItemsDesc: "Abre itens de inicialização no macOS.",
    startupItemsTip: "Mostra apps e itens de login no sistema.",
    memoryCleanupTitle: "Limpeza de Memória",
    memoryCleanupDesc: "Alivia memória RAM e abre o Monitor de Atividades.",
    memoryCleanupTip: "Tenta liberar RAM e abre o Monitor de Atividades.",
    monitorTitle: "Monitor de recursos",
    monitorCpu: "CPU",
    monitorMem: "Memória",
    monitorDisk: "Disco",
    monitorHint: "Atualiza automaticamente enquanto o app estiver aberto.",
    autoCacheTitle: "Limpeza automática do Chrome",
    autoCacheDesc: "Ativa ou desativa a limpeza automática de cache.",
    autoCacheTip: "Limpa cache do Chrome de tempos em tempos.",
    trayModeTitle: "Modo minimizado (monitor)",
    trayModeDesc: "Entra no modo compacto estilo Jira Monitor.",
    trayModeTip: "Mostra apenas o painel de monitoramento.",
    activityMonitorTitle: "Abrir Monitor de Atividades",
    activityMonitorDesc: "Abre o monitor de processos.",
    emptyTrashTitle: "Esvaziar Lixeira",
    emptyTrashDesc: "Esvazia a Lixeira do Finder.",
    fixTimeTitle: "Corrigir hora",
    fixTimeDesc:
      "Abre Date & Time via Spotlight e ativa ajustes automáticos.",
    uninstallAppsTitle: "Desinstalar apps",
    uninstallAppsDesc:
      "Mapeia apps instalados e move os selecionados para a Lixeira.",
    openKeychainTitle: "Abrir Keychain",
    openKeychainDesc: "Abre login e Meus Certificados. Clique em Acesso às Chaves.",
    touchIdTitle: "Touch ID no Mac",
    touchIdDesc: "Abre Touch ID & Password via Spotlight.",
    macSetupTitle: "Como configurar o Mac",
    macSetupDesc: "Abre o guia oficial de configuração do Mac.",
    oktaPasswordsTitle: "Conferir senha Okta",
    oktaPasswordsDesc:
      "Abre o Gerenciador de Senhas do Chrome filtrado por Okta.",
    restartVpnTitle: "Reiniciar VPN (Zscaler)",
    restartVpnDesc: "Fecha e reabre o Zscaler.",
    exitAppTitle: "Sair do app",
    exitAppDesc: "Fecha o DiagnuCLI.",
    rovoTitle: "Abrir Rovo (Suporte)",
    rovoDesc: "Abre o chat do Rovo no Google Chrome.",
    gadgetsTitle: "Pedir gadgets",
    gadgetsDesc: "Solicita itens utilizados para trabalhar.",
    peopleTitle: "Falar com People",
    peopleDesc: "Dúvidas de RH e NuWayOfWorking (Kadence).",
    shuffleFixTitle: "Shuffle Fix",
    shuffleFixDesc:
      "Cria chamado do toolio, pede scopes no AskNu e limpa cache do Chrome.",
    certificatesTitle: "Gerar certificados",
    certificatesDesc: "Abre o portal de certificados no Chrome.",
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
    gnuChconTip:
      'Corrige o erro "GNU version of chcon was not found" com git pull --rebase.',
    javaRuntimeTip: "Instala o Temurin para corrigir o Java Runtime.",
    bashUnboundTip: "Restaura o PATH e variáveis do NuCLI no .zshrc.",
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
    fixTimeTip: "Abre Date & Time e configura automaticamente.",
    uninstallAppsTip: "Lista apps e move os selecionados para a Lixeira.",
    openKeychainTip: "Abre o Keychain na área correta.",
    touchIdTip: "Abre Touch ID & Password nas Configurações.",
    macSetupTip: "Abre o guia de configuração do Mac.",
    oktaPasswordsTip: "Abre o Chrome Password Manager filtrado por Okta.",
    restartVpnTip: "Reinicia o Zscaler.",
    exitAppTip: "Sai do DiagnuCLI.",
    rovoTip: "Abre o Rovo no Chrome.",
    gadgetsTip: "Abre o formulário para pedir itens de trabalho.",
    peopleTip: "Abre o portal de People para RH e Kadence.",
    shuffleFixTip:
      "Siga os passos e aguarde aprovacao de escopo/toolio antes de acessar o Shuffle.",
    certificatesTip: "Abre o link de certificados no Chrome.",
    supportTip: "Abre o portal de suporte.",
    requestLaptopTip: "Abre o formulário de troca de laptop.",
    oncallTip: "Abre o WhatsApp de on-call.",
    setupHelpTip: "Abre o canal Setup Help no Slack.",
    askNuTip: "Abre o Slack e busca @AskNu.",
    zscalerFeedbackTip: "Abre o canal zscaler-feedback-tmp no Slack.",
    setupHelpTitle: "Fale com os canais oficiais do Slack para suporte.",
    setupHelpButton: "Problemas com Setup Nucli",
    askNuButton: "Falar com @AskNu",
    zscalerFeedbackButton: "Problemas com VPN",
    setupHelpHint: "Clique para abrir o canal e pedir ajuda.",
    overlayHintTitle: "Detalhes do comando",
    overlayHint:
      "Siga os prompts do Terminal e use os tooltips para entender cada etapa.",
    howTitle: "Como funciona",
    howList: [
      "Use a busca para encontrar botões e ações rapidamente.",
      "Os botões executam passos automáticos e abrem links úteis.",
      "Passe o mouse nos botões para ver tooltips explicativos.",
      "Os logs do Terminal aparecem em tempo real na esquerda."
    ],
    guideTitle: "Orientações rápidas",
    guideList: [
      "Leia o pop-up à direita após iniciar um comando.",
      "Responda aos prompts do Terminal quando solicitado.",
      "Se pedir MFA, confirme no Okta ou Touch ID.",
      "Feche o Google Chrome antes de limpar o cache."
    ],
    noteTitle: "Importante",
    noteList: [
      "Algumas ações exigem aprovações (ex.: scopes e acessos).",
      "O app apenas orquestra e acompanha os logs do Terminal."
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
    statusIdle: "Waiting to start. macOS Terminal will open in background.",
    hint:
      "Type and answer in macOS Terminal. Here you follow commands as they run.",
    opt1Title: "Full verification - NuCLI AWS setup",
    opt1Desc: "Runs all NuCLI/AWS checks and generates the report.",
    opt7Title: "Test NuCLI commands",
    opt7Desc: "Runs nu doctor, versions, and key commands.",
    installNucliTitle: "Install NuCLI",
    installNucliDesc: "Step-by-step access, SSH, Homebrew, and AWS setup.",
    gnuChconTitle: 'Error: "GNU version of chcon was not found" fix',
    gnuChconDesc:
      "This error happens due to version/path mismatches. Goes to ~/dev/nu/nucli and runs git pull --rebase.",
    javaRuntimeTitle: "Unable to locate a Java Runtime Fix",
    javaRuntimeDesc: "Installs Java (Temurin) via Homebrew.",
    bashUnboundTitle: "Bash version ancient / unbound variable fix",
    bashUnboundDesc: "Restores PATH and NuCLI variables in .zshrc.",
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
    cleanClutterTitle: "Clean clutter",
    cleanClutterDesc: "Opens Storage with cleanup recommendations.",
    cleanClutterTip: "Shows recommendations to free space.",
    startupItemsTitle: "Select startup devices",
    startupItemsDesc: "Opens Login Items in System Settings.",
    startupItemsTip: "Manage apps that start with macOS.",
    memoryCleanupTitle: "Memory cleanup",
    memoryCleanupDesc: "Relieves RAM by clearing buffers.",
    memoryCleanupTip: "Runs memory purge (may ask for password).",
    updateTitle: "Update app",
    updateDesc: "Pulls the latest Git version and reinstalls.",
    updateHeader: "Update app",
    updateHeaderTip: "Update DiagnuCLI from Git.",
    minimizeHeader: "Minimize",
    minimizeHeaderTip: "Minimize DiagnuCLI to the Dock.",
    maximizeHeaderTip: "Toggle between maximize and restore.",
    searchPlaceholder: "Search buttons...",
    logTitle: "Terminal logs",
    clearLogButton: "Clear logs",
    clearLogTip: "Clears the log panel history.",
    macosUpdateTitle: "Update macOS",
    macosUpdateDesc: "Checks and installs macOS updates.",
    manageDiskTitle: "Manage disk space",
    manageDiskDesc: "Opens Storage via Spotlight.",
    optimizePerfTitle: "Improve Mac performance",
    optimizePerfDesc: "Runs the performance and cleanup script.",
    cleanClutterTitle: "Clean clutter",
    cleanClutterDesc: "Opens Storage management to free space.",
    cleanClutterTip: "Opens the macOS Storage panel.",
    startupItemsTitle: "Select startup items",
    startupItemsDesc: "Opens macOS login items.",
    startupItemsTip: "Shows apps and login items in settings.",
    memoryCleanupTitle: "Memory cleanup",
    memoryCleanupDesc: "Frees RAM and opens Activity Monitor.",
    memoryCleanupTip: "Attempts to free RAM and opens Activity Monitor.",
    monitorTitle: "Resource monitor",
    monitorCpu: "CPU",
    monitorMem: "Memory",
    monitorDisk: "Disk",
    monitorHint: "Updates automatically while the app is open.",
    autoCacheTitle: "Automatic Chrome cleanup",
    autoCacheDesc: "Enable or disable automatic cache cleanup.",
    autoCacheTip: "Cleans Chrome cache periodically.",
    trayModeTitle: "Minimized mode (monitor)",
    trayModeDesc: "Enter compact Jira Monitor style mode.",
    trayModeTip: "Shows only the monitoring panel.",
    activityMonitorTitle: "Open Activity Monitor",
    activityMonitorDesc: "Opens the process monitor.",
    emptyTrashTitle: "Empty Trash",
    emptyTrashDesc: "Empties the Finder Trash.",
    fixTimeTitle: "Fix time",
    fixTimeDesc: "Opens Date & Time via Spotlight and enables auto settings.",
    uninstallAppsTitle: "Uninstall apps",
    uninstallAppsDesc: "Lists installed apps and moves selected ones to Trash.",
    openKeychainTitle: "Open Keychain",
    openKeychainDesc: "Opens Login and My Certificates. Click Keychain Access.",
    touchIdTitle: "Touch ID on Mac",
    touchIdDesc: "Opens Touch ID & Password via Spotlight.",
    macSetupTitle: "How to set up the Mac",
    macSetupDesc: "Opens the official Mac setup guide.",
    oktaPasswordsTitle: "Check Okta password",
    oktaPasswordsDesc:
      "Opens Chrome Password Manager filtered by Okta.",
    restartVpnTitle: "Restart VPN (Zscaler)",
    restartVpnDesc: "Quits and reopens Zscaler.",
    exitAppTitle: "Exit app",
    exitAppDesc: "Closes DiagnuCLI.",
    rovoTitle: "Open Rovo (Support)",
    rovoDesc: "Opens the Rovo chat in Google Chrome.",
    gadgetsTitle: "Request gadgets",
    gadgetsDesc: "Requests items used for work.",
    peopleTitle: "Talk to People",
    peopleDesc: "HR and NuWayOfWorking questions (Kadence).",
    shuffleFixTitle: "Shuffle Fix",
    shuffleFixDesc:
      "Creates the toolio ticket, requests scopes in AskNu, and clears Chrome cache.",
    certificatesTitle: "Generate certificates",
    certificatesDesc: "Opens the certificates portal in Chrome.",
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
    gnuChconTip:
      'Fixes the "GNU version of chcon was not found" error with git pull --rebase.',
    javaRuntimeTip: "Installs Temurin to fix the Java Runtime error.",
    bashUnboundTip: "Restores PATH and NuCLI variables in .zshrc.",
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
    fixTimeTip: "Opens Date & Time and configures automatically.",
    uninstallAppsTip: "Lists apps and moves selected ones to Trash.",
    openKeychainTip: "Opens Keychain in the right section.",
    touchIdTip: "Opens Touch ID & Password in Settings.",
    macSetupTip: "Opens the Mac setup guide.",
    oktaPasswordsTip: "Opens Chrome Password Manager filtered by Okta.",
    restartVpnTip: "Restarts Zscaler.",
    exitAppTip: "Exit DiagnuCLI.",
    rovoTip: "Open Rovo in Chrome.",
    gadgetsTip: "Opens the form to request work items.",
    peopleTip: "Opens the People portal for HR and Kadence.",
    shuffleFixTip:
      "Follow the steps and wait for scope/toolio approval before using Shuffle.",
    certificatesTip: "Opens the certificates link in Chrome.",
    supportTip: "Open the support portal.",
    requestLaptopTip: "Open the laptop replacement form.",
    oncallTip: "Open the on-call WhatsApp.",
    setupHelpTip: "Open the Setup Help Slack channel.",
    askNuTip: "Open Slack and search for @AskNu.",
    zscalerFeedbackTip: "Open the zscaler-feedback-tmp Slack channel.",
    setupHelpTitle: "Reach official Slack channels for support.",
    setupHelpButton: "NuCLI setup issues",
    askNuButton: "Talk to @AskNu",
    zscalerFeedbackButton: "VPN issues",
    setupHelpHint: "Click to open the channel and ask for help.",
    overlayHintTitle: "Command details",
    overlayHint: "Follow Terminal prompts and use tooltips for each step.",
    howTitle: "How it works",
    howList: [
      "Use search to quickly find buttons and actions.",
      "Buttons run automated steps and open helpful links.",
      "Hover buttons to see interactive tooltips.",
      "Terminal logs stream live on the left."
    ],
    guideTitle: "Quick guidance",
    guideList: [
      "Read the right-side pop-up after starting a command.",
      "Answer Terminal prompts when requested.",
      "If MFA is requested, approve in Okta or Touch ID.",
      "Close Google Chrome before clearing cache."
    ],
    noteTitle: "Important",
    noteList: [
      "Some actions require approvals (scopes/access).",
      "The app only orchestrates and mirrors Terminal logs."
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
    statusIdle: "Esperando inicio. El Terminal de macOS se abrirá en segundo plano.",
    hint:
      "Escriba y responda en el Terminal de macOS. Aquí seguirá los comandos en ejecución.",
    opt1Title: "Verificación completa - setup NuCLI AWS",
    opt1Desc: "Ejecuta todos los checks de NuCLI/AWS y genera el informe.",
    opt7Title: "Probar comandos NuCLI",
    opt7Desc: "Ejecuta nu doctor, versiones y comandos clave.",
    installNucliTitle: "Instalar NuCLI",
    installNucliDesc: "Paso a paso de acceso, SSH, Homebrew y AWS.",
    gnuChconTitle: 'Error: "GNU version of chcon was not found" fix',
    gnuChconDesc:
      "Este error ocurre por divergencia de versiones/rutas. Va a ~/dev/nu/nucli y ejecuta git pull --rebase.",
    javaRuntimeTitle: "Unable to locate a Java Runtime Fix",
    javaRuntimeDesc: "Instala Java (Temurin) con Homebrew.",
    bashUnboundTitle: "Error de Bash antiguo / unbound variable fix",
    bashUnboundDesc: "Restaura PATH y variables de NuCLI en .zshrc.",
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
    cleanClutterTitle: "Clean clutter",
    cleanClutterDesc: "Abre Almacenamiento con recomendaciones.",
    cleanClutterTip: "Muestra recomendaciones para liberar espacio.",
    startupItemsTitle: "Seleccionar dispositivos para iniciar",
    startupItemsDesc: "Abre Elementos de inicio en Ajustes del Sistema.",
    startupItemsTip: "Administra apps que inician con macOS.",
    memoryCleanupTitle: "Limpieza de Memoria",
    memoryCleanupDesc: "Alivia la RAM limpiando buffers.",
    memoryCleanupTip: "Ejecuta purge de memoria (puede pedir contraseña).",
    updateTitle: "Actualizar app",
    updateDesc: "Actualiza desde Git y reinstala.",
    updateHeader: "Actualizar app",
    updateHeaderTip: "Actualiza DiagnuCLI desde Git.",
    minimizeHeader: "Minimizar",
    minimizeHeaderTip: "Minimiza DiagnuCLI al Dock.",
    maximizeHeaderTip: "Alterna entre maximizar y restaurar.",
    searchPlaceholder: "Buscar botones...",
    logTitle: "Registros del Terminal",
    clearLogButton: "Limpiar logs",
    clearLogTip: "Limpia el historial de registros.",
    macosUpdateTitle: "Actualizar macOS",
    macosUpdateDesc: "Verifica e instala actualizaciones de macOS.",
    manageDiskTitle: "Administrar espacio en disco",
    manageDiskDesc: "Abre Almacenamiento via Spotlight.",
    optimizePerfTitle: "Mejorar rendimiento del Mac",
    optimizePerfDesc: "Ejecuta el script de rendimiento y limpieza.",
    cleanClutterTitle: "Clean clutter",
    cleanClutterDesc: "Abre Administración de almacenamiento para liberar espacio.",
    cleanClutterTip: "Abre el panel de Almacenamiento de macOS.",
    startupItemsTitle: "Seleccionar elementos de inicio",
    startupItemsDesc: "Abre elementos de inicio de sesión en macOS.",
    startupItemsTip: "Muestra apps y elementos de inicio.",
    memoryCleanupTitle: "Limpieza de memoria",
    memoryCleanupDesc: "Libera RAM y abre el Monitor de Actividad.",
    memoryCleanupTip: "Intenta liberar RAM y abre Monitor de Actividad.",
    monitorTitle: "Monitor de recursos",
    monitorCpu: "CPU",
    monitorMem: "Memoria",
    monitorDisk: "Disco",
    monitorHint: "Se actualiza automáticamente mientras la app está abierta.",
    autoCacheTitle: "Limpieza automática de Chrome",
    autoCacheDesc: "Activa o desactiva la limpieza automática de caché.",
    autoCacheTip: "Limpia el caché de Chrome periódicamente.",
    trayModeTitle: "Modo minimizado (monitor)",
    trayModeDesc: "Entra en modo compacto estilo Jira Monitor.",
    trayModeTip: "Muestra solo el panel de monitorización.",
    activityMonitorTitle: "Abrir Monitor de Actividad",
    activityMonitorDesc: "Abre el monitor de procesos.",
    emptyTrashTitle: "Vaciar Papelera",
    emptyTrashDesc: "Vacía la Papelera del Finder.",
    fixTimeTitle: "Corregir hora",
    fixTimeDesc:
      "Abre Date & Time via Spotlight y activa ajustes automáticos.",
    uninstallAppsTitle: "Desinstalar apps",
    uninstallAppsDesc:
      "Enumera apps instaladas y mueve las seleccionadas a la Papelera.",
    openKeychainTitle: "Abrir Keychain",
    openKeychainDesc: "Abre login y Mis Certificados. Haz clic en Acceso a Llaveros.",
    touchIdTitle: "Touch ID en Mac",
    touchIdDesc: "Abre Touch ID & Password via Spotlight.",
    macSetupTitle: "Cómo configurar el Mac",
    macSetupDesc: "Abre la guía oficial de configuración del Mac.",
    oktaPasswordsTitle: "Ver contraseña de Okta",
    oktaPasswordsDesc:
      "Abre el Administrador de contraseñas de Chrome filtrado por Okta.",
    restartVpnTitle: "Reiniciar VPN (Zscaler)",
    restartVpnDesc: "Cierra y vuelve a abrir Zscaler.",
    exitAppTitle: "Salir de la app",
    exitAppDesc: "Cierra DiagnuCLI.",
    rovoTitle: "Abrir Rovo (Soporte)",
    rovoDesc: "Abre el chat de Rovo en Google Chrome.",
    gadgetsTitle: "Pedir gadgets",
    gadgetsDesc: "Solicita artículos utilizados para trabajar.",
    peopleTitle: "Hablar con People",
    peopleDesc: "Dudas de RRHH y NuWayOfWorking (Kadence).",
    shuffleFixTitle: "Shuffle Fix",
    shuffleFixDesc:
      "Crea el ticket de toolio, pide scopes en AskNu y limpia la caché de Chrome.",
    certificatesTitle: "Generar certificados",
    certificatesDesc: "Abre el portal de certificados en Chrome.",
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
    gnuChconTip:
      'Corrige el error "GNU version of chcon was not found" con git pull --rebase.',
    javaRuntimeTip: "Instala Temurin para corregir el error de Java Runtime.",
    bashUnboundTip: "Restaura PATH y variables de NuCLI en .zshrc.",
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
    fixTimeTip: "Abre Date & Time y configura automáticamente.",
    uninstallAppsTip: "Lista apps y mueve las seleccionadas a la Papelera.",
    openKeychainTip: "Abre Keychain en la sección correcta.",
    touchIdTip: "Abre Touch ID & Password en Configuración.",
    macSetupTip: "Abre la guía de configuración del Mac.",
    oktaPasswordsTip: "Abre el Password Manager de Chrome filtrado por Okta.",
    restartVpnTip: "Reinicia Zscaler.",
    exitAppTip: "Salir de DiagnuCLI.",
    rovoTip: "Abre Rovo en Chrome.",
    gadgetsTip: "Abre el formulario para solicitar artículos de trabajo.",
    peopleTip: "Abre el portal de People para RRHH y Kadence.",
    shuffleFixTip:
      "Siga los pasos y espere la aprobación de scopes/toolio antes de usar Shuffle.",
    certificatesTip: "Abre el enlace de certificados en Chrome.",
    supportTip: "Abre el portal de soporte.",
    requestLaptopTip: "Abre el formulario de cambio de laptop.",
    oncallTip: "Abre el WhatsApp de on-call.",
    setupHelpTip: "Abre el canal Setup Help en Slack.",
    askNuTip: "Abre Slack y busca @AskNu.",
    zscalerFeedbackTip: "Abre el canal zscaler-feedback-tmp en Slack.",
    setupHelpTitle: "Hable con los canales oficiales de Slack para soporte.",
    setupHelpButton: "Problemas con Setup Nucli",
    askNuButton: "Hablar con @AskNu",
    zscalerFeedbackButton: "Problemas con VPN",
    setupHelpHint: "Haga clic para abrir el canal y pedir ayuda.",
    overlayHintTitle: "Detalles del comando",
    overlayHint:
      "Siga los prompts del Terminal y use los tooltips para cada etapa.",
    howTitle: "Cómo funciona",
    howList: [
      "Use la búsqueda para encontrar botones rápidamente.",
      "Los botones ejecutan pasos automáticos y abren enlaces.",
      "Pase el mouse para ver tooltips interactivos.",
      "Los logs del Terminal se muestran en vivo a la izquierda."
    ],
    guideTitle: "Orientaciones rápidas",
    guideList: [
      "Lea el pop-up a la derecha al iniciar un comando.",
      "Responda a los prompts del Terminal cuando se solicite.",
      "Si pide MFA, confirme en Okta o Touch ID.",
      "Cierre Google Chrome antes de limpiar la caché."
    ],
    noteTitle: "Importante",
    noteList: [
      "Algunas acciones requieren aprobación (scopes/accesos).",
      "La app solo orquesta y refleja los logs del Terminal."
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
      el.setAttribute("data-tooltip-text", dict[key]);
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

const showInfoOverlay = (title, desc) => {
  if (!infoOverlay || !infoOverlayTitle || !infoOverlayBody) {
    return;
  }
  const dict = translations[currentLang];
  infoOverlayTitle.textContent = dict.overlayHintTitle;
  infoOverlayBody.textContent = `${title}\n${desc}\n\n${dict.overlayHint}`;
  infoOverlay.classList.add("show");
  infoOverlay.setAttribute("aria-hidden", "false");
};

const hideInfoOverlay = () => {
  if (!infoOverlay) {
    return;
  }
  infoOverlay.classList.remove("show");
  infoOverlay.setAttribute("aria-hidden", "true");
};

const getCardInfo = (element) => {
  if (!element) {
    return null;
  }
  const titleEl = element.querySelector(".menu-title");
  const descEl = element.querySelector(".menu-desc");
  const title = titleEl ? titleEl.textContent.trim() : "";
  const desc = descEl ? descEl.textContent.trim() : "";
  if (!title && !desc) {
    return null;
  }
  return { title, desc };
};

const filterButtons = (term) => {
  const needle = term.trim().toLowerCase();
  const buttons = document.querySelectorAll(
    ".menu-card, .terminal-row button"
  );
  buttons.forEach((btn) => {
    const text = `${btn.textContent || ""} ${btn.getAttribute("title") || ""}`
      .toLowerCase()
      .trim();
    const shouldShow = !needle || text.includes(needle);
    btn.style.display = shouldShow ? "" : "none";
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
  "fix-gnu-chcon": "Fix GNU chcon error",
  "fix-java-runtime": "Fix Java Runtime missing",
  "fix-bash-unbound": "Fix Bash unbound variables",
  "cache-mac": "macOS cache cleanup",
  "cache-chrome": "Chrome cache cleanup",
  "clean-clutter": "Clean clutter",
  "startup-items": "Startup items",
  "memory-cleanup": "Memory cleanup",
  "update-app": "DiagnuCLI app update",
  "update-macos": "macOS update",
  "manage-disk": "Manage disk space",
  "clean-clutter": "Clean clutter",
  "startup-items": "Startup items",
  "memory-cleanup": "Memory cleanup",
  "optimize-performance": "Optimize macOS performance",
  "activity-monitor": "Open Activity Monitor",
  "empty-trash": "Empty Trash",
  "fix-time": "Fix time",
  "uninstall-apps": "Uninstall apps",
  "open-keychain": "Open Keychain",
  "open-touch-id": "Open Touch ID & Password",
  "open-mac-setup": "Open Mac setup guide",
  "open-okta-passwords": "Open Okta passwords",
  "restart-vpn": "Restart VPN",
  "toggle-auto-cache": "Auto cache cleanup",
  "toggle-tray-mode": "Tray mode",
  "maximize-app": "Maximize app",
  "minimize-app": "Minimize app",
  "shuffle-fix": "Shuffle Fix",
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
  } else if (actionId === "minimize-app") {
    await window.diagnucli.minimizeApp();
    return;
  } else if (actionId === "maximize-app") {
    await window.diagnucli.maximizeApp();
    return;
  } else if (actionId === "toggle-tray-mode") {
    await window.diagnucli.toggleTrayMode();
    return;
  } else if (actionId === "toggle-auto-cache") {
    await window.diagnucli.toggleAutoCache();
    return;
  } else if (actionId === "exit-app") {
    await window.diagnucli.exitApp();
    return;
  } else if (actionId === "clear-log") {
    logOutput.textContent = "";
    await window.diagnucli.clearLog();
    return;
  } else {
    await window.diagnucli.runAction(actionId, currentLang);
  }
  appendLog(`\n[DiagnuCLI] Action started: ${label}\n`);
  const card = document.querySelector(`[data-action="${actionId}"]`);
  const info = getCardInfo(card);
  if (info) {
    showInfoOverlay(info.title, info.desc);
  }
};

startButton.addEventListener("click", startRun);

menuCards.forEach((card) => {
  card.addEventListener("click", () => {
    const titleEl = card.querySelector(".menu-title");
    const title = titleEl ? titleEl.textContent.trim() : "";
    sendMenuChoice(card.dataset.option, title);
    const info = getCardInfo(card);
    if (info) {
      showInfoOverlay(info.title, info.desc);
    }
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
    const info = getCardInfo(setupHelpButton);
    if (info) {
      showInfoOverlay(info.title, info.desc);
    }
  });
}

if (askNuButton) {
  askNuButton.addEventListener("click", async () => {
    await window.diagnucli.openAskNu();
    appendLog("\n[DiagnuCLI] AskNu opened in Slack.\n");
    const info = getCardInfo(askNuButton);
    if (info) {
      showInfoOverlay(info.title, info.desc);
    }
  });
}

if (zscalerFeedbackButton) {
  zscalerFeedbackButton.addEventListener("click", async () => {
    await window.diagnucli.openZscalerFeedback();
    appendLog("\n[DiagnuCLI] zscaler-feedback-tmp opened in Slack.\n");
    const info = getCardInfo(zscalerFeedbackButton);
    if (info) {
      showInfoOverlay(info.title, info.desc);
    }
  });
}

if (rovoButton) {
  rovoButton.addEventListener("click", async () => {
    await window.diagnucli.openRovo();
    appendLog("\n[DiagnuCLI] Rovo support opened.\n");
    const info = getCardInfo(rovoButton);
    if (info) {
      showInfoOverlay(info.title, info.desc);
    }
  });
}

if (supportButton) {
  supportButton.addEventListener("click", async () => {
    await window.diagnucli.openSupport();
    appendLog("\n[DiagnuCLI] Support portal opened.\n");
    const info = getCardInfo(supportButton);
    if (info) {
      showInfoOverlay(info.title, info.desc);
    }
  });
}

if (gadgetsButton) {
  gadgetsButton.addEventListener("click", async () => {
    await window.diagnucli.openGadgetsRequest();
    appendLog("\n[DiagnuCLI] Gadgets request opened.\n");
    const info = getCardInfo(gadgetsButton);
    if (info) {
      showInfoOverlay(info.title, info.desc);
    }
  });
}

if (peopleButton) {
  peopleButton.addEventListener("click", async () => {
    await window.diagnucli.openPeopleRequest();
    appendLog("\n[DiagnuCLI] People request opened.\n");
    const info = getCardInfo(peopleButton);
    if (info) {
      showInfoOverlay(info.title, info.desc);
    }
  });
}

if (certificatesButton) {
  certificatesButton.addEventListener("click", async () => {
    await window.diagnucli.openCertificates();
    appendLog("\n[DiagnuCLI] Certificates portal opened.\n");
    const info = getCardInfo(certificatesButton);
    if (info) {
      showInfoOverlay(info.title, info.desc);
    }
  });
}

if (searchInput) {
  searchInput.addEventListener("input", (event) => {
    filterButtons(event.target.value);
  });
}

if (infoOverlayClose) {
  infoOverlayClose.addEventListener("click", hideInfoOverlay);
}

langButtons.forEach((btn) => {
  btn.addEventListener("click", () => updateLang(btn.dataset.lang));
});

window.addEventListener("DOMContentLoaded", () => {
  updateLang(currentLang);
  if (window.diagnucli && window.diagnucli.onMonitorMode) {
    window.diagnucli.onMonitorMode((enabled) => {
      document.body.classList.toggle("monitor-only", Boolean(enabled));
    });
  }
  const updateMonitor = async () => {
    if (!window.diagnucli || !window.diagnucli.getSystemStats) {
      return;
    }
    try {
      const stats = await window.diagnucli.getSystemStats();
      if (!stats) {
        return;
      }
      const cpu = Math.min(100, Math.max(0, stats.cpuPercent ?? 0));
      const mem = Math.min(100, Math.max(0, stats.memPercent ?? 0));
      const disk = Math.min(100, Math.max(0, stats.diskPercent ?? 0));

      if (monitorCpuValue && monitorCpuBar) {
        monitorCpuValue.textContent = `${cpu}%`;
        monitorCpuBar.style.width = `${cpu}%`;
      }
      if (monitorMemValue && monitorMemBar) {
        monitorMemValue.textContent = `${mem}%`;
        monitorMemBar.style.width = `${mem}%`;
      }
      if (monitorDiskValue && monitorDiskBar) {
        monitorDiskValue.textContent = `${disk}%`;
        monitorDiskBar.style.width = `${disk}%`;
      }
    } catch (error) {
      // Ignore stats failures to keep UI responsive.
    }
  };
  updateMonitor();
  setInterval(updateMonitor, 4000);
});
