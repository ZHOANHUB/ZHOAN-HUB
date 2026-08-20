local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")

local CORRECT_KEY = "RONALDO"

_G.Translations = {
    en = {
        TabUniversal = "Universal",
        TabGames = "Games",
        TabFavorites = "Favorites",
        TabServer = "Server",
        TabLanguage = "Language",
        SectionUniversal = "Universal Scripts",
        SectionGames = "Games",
        SectionServerMgmt = "Server Management",
        SectionJoinJob = "Join by JobId",
        BtnFly = "Fly, jump, noclip",
        BtnFling = "Fling",
        BtnRivals = "Rivals",
        BtnApoc = "Apocalypse rising 2",
        BtnBloxstrike = "Bloxstrike",
        BtnJailbird = "Jailbird",
        BtnMM2 = "MM2",
        BtnMurder = "Murder VS Sheriff",
        BtnRejoin = "RE-JOIN SERVER",
        BtnCopyJob = "COPY SERVER JOBID",
        BtnAutoRejoin = "AUTO-REJOIN ON CRASH",
        BtnJoinJob = "TELEPORT TO JOBID",
        BtnMask = "MASK DATA",
        BtnUnmask = "UNMASK",
        PlaceholderJob = "PASTE JOBID HERE...",
        PlaceholderSearch = " SEARCH SCRIPTS...",
        KeyTitle = "KEY REQUIRED",
        KeySub = "Enter the key from our Discord server:",
        KeyPlaceholder = "Enter key here...",
        KeyCheck = "VERIFY KEY",
        KeyDiscord = "GET DISCORD",
        KeyStatusCorrect = "KEY CORRECT! LOADING...",
        KeyStatusInvalid = "INVALID KEY! TRY AGAIN.",
        KeyStatusCopied = "DISCORD LINK COPIED!",
        KeyStatusJoin = "JOIN: discord.gg/VrQtWF9tj",
        CopyJobSuccess = " COPIED JOBID!",
        CopyJobDefault = " COPY SERVER JOBID",
        AnonIdentity = "IDENTITY: HIDDEN",
        AnonSoftware = "SOFTWARE: HIDDEN",
        Identity = "IDENTITY: ",
        Software = "SOFTWARE: ",
        RejoinOn = " AUTO-REJOIN ON CRASH: [ ON ]",
        RejoinOff = " AUTO-REJOIN ON CRASH: [ OFF ]",
        ExecuteText = " EXECUTE: ",
        NameLabel = "ZHOAN HUB",
        FPSLabel = "FPS: 00 | MS: 00.0",
        DiscordLabel = " GET DISCORD",
        LanguageLabel = "Language",
        Lang_en = "English",
        Lang_fr = "Français",
        Lang_es = "Español",
        Lang_pt = "Português",
        Lang_it = "Italiano",
    },
    fr = {
        TabUniversal = "Universel",
        TabGames = "Jeux",
        TabFavorites = "Favoris",
        TabServer = "Serveur",
        TabLanguage = "Langue",
        SectionUniversal = "Scripts Universels",
        SectionGames = "Jeux",
        SectionServerMgmt = "Gestion du serveur",
        SectionJoinJob = "Rejoindre par JobId",
        BtnFly = "Voler, sauter, noclip",
        BtnFling = "Fling",
        BtnRivals = "Rivals",
        BtnApoc = "Apocalypse rising 2",
        BtnBloxstrike = "Bloxstrike",
        BtnJailbird = "Jailbird",
        BtnMM2 = "MM2",
        BtnMurder = "Murder VS Sheriff",
        BtnRejoin = "REJOINDRE LE SERVEUR",
        BtnCopyJob = "COPIER LE JOBID",
        BtnAutoRejoin = "REJOINDRE AUTO EN CAS DE CRASH",
        BtnJoinJob = "TÉLÉPORTER VERS JOBID",
        BtnMask = "MASQUER LES DONNÉES",
        BtnUnmask = "DÉMASQUER",
        PlaceholderJob = "COLLEZ LE JOBID ICI...",
        PlaceholderSearch = " RECHERCHER DES SCRIPTS...",
        KeyTitle = "CLÉ REQUISE",
        KeySub = "Entrez la clé depuis notre serveur Discord :",
        KeyPlaceholder = "Entrez la clé ici...",
        KeyCheck = "VÉRIFIER LA CLÉ",
        KeyDiscord = "OBTENIR DISCORD",
        KeyStatusCorrect = "CLÉ CORRECTE ! CHARGEMENT...",
        KeyStatusInvalid = "CLÉ INVALIDE ! RÉESSAYEZ.",
        KeyStatusCopied = "LIEN DISCORD COPIÉ !",
        KeyStatusJoin = "REJOIGNEZ : discord.gg/VrQtWF9tj",
        CopyJobSuccess = " JOBID COPIÉ !",
        CopyJobDefault = " COPIER LE JOBID",
        AnonIdentity = "IDENTITÉ : CACHÉE",
        AnonSoftware = "LOGICIEL : CACHÉ",
        Identity = "IDENTITÉ : ",
        Software = "LOGICIEL : ",
        RejoinOn = " REJOINDRE AUTO EN CAS DE CRASH : [ ON ]",
        RejoinOff = " REJOINDRE AUTO EN CAS DE CRASH : [ OFF ]",
        ExecuteText = " EXÉCUTER : ",
        NameLabel = "ZHOAN HUB",
        FPSLabel = "FPS : 00 | MS : 00.0",
        DiscordLabel = " OBTENIR DISCORD",
        LanguageLabel = "Langue",
        Lang_en = "Anglais",
        Lang_fr = "Français",
        Lang_es = "Espagnol",
        Lang_pt = "Portugais",
        Lang_it = "Italien",
    },
    es = {
        TabUniversal = "Universal",
        TabGames = "Juegos",
        TabFavorites = "Favoritos",
        TabServer = "Servidor",
        TabLanguage = "Idioma",
        SectionUniversal = "Scripts Universales",
        SectionGames = "Juegos",
        SectionServerMgmt = "Gestión del servidor",
        SectionJoinJob = "Unirse por JobId",
        BtnFly = "Volar, saltar, noclip",
        BtnFling = "Fling",
        BtnRivals = "Rivals",
        BtnApoc = "Apocalypse rising 2",
        BtnBloxstrike = "Bloxstrike",
        BtnJailbird = "Jailbird",
        BtnMM2 = "MM2",
        BtnMurder = "Murder VS Sheriff",
        BtnRejoin = "REUNIRSE AL SERVIDOR",
        BtnCopyJob = "COPIAR JOBID",
        BtnAutoRejoin = "REUNIRSE AUTO EN CRASH",
        BtnJoinJob = "TELEPORTAR A JOBID",
        BtnMask = "OCULTAR DATOS",
        BtnUnmask = "MOSTRAR",
        PlaceholderJob = "PEGUE EL JOBID AQUÍ...",
        PlaceholderSearch = " BUSCAR SCRIPTS...",
        KeyTitle = "CLAVE REQUERIDA",
        KeySub = "Ingrese la clave de nuestro servidor Discord:",
        KeyPlaceholder = "Ingrese la clave aquí...",
        KeyCheck = "VERIFICAR CLAVE",
        KeyDiscord = "OBTENER DISCORD",
        KeyStatusCorrect = "¡CLAVE CORRECTA! CARGANDO...",
        KeyStatusInvalid = "¡CLAVE INVÁLIDA! INTENTE DE NUEVO.",
        KeyStatusCopied = "¡ENLACE DE DISCORD COPIADO!",
        KeyStatusJoin = "ÚNASE: discord.gg/VrQtWF9tj",
        CopyJobSuccess = " ¡JOBID COPIADO!",
        CopyJobDefault = " COPIAR JOBID",
        AnonIdentity = "IDENTIDAD: OCULTA",
        AnonSoftware = "SOFTWARE: OCULTO",
        Identity = "IDENTIDAD: ",
        Software = "SOFTWARE: ",
        RejoinOn = " REUNIRSE AUTO EN CRASH: [ ON ]",
        RejoinOff = " REUNIRSE AUTO EN CRASH: [ OFF ]",
        ExecuteText = " EJECUTAR: ",
        NameLabel = "ZHOAN HUB",
        FPSLabel = "FPS: 00 | MS: 00.0",
        DiscordLabel = " OBTENER DISCORD",
        LanguageLabel = "Idioma",
        Lang_en = "Inglés",
        Lang_fr = "Francés",
        Lang_es = "Español",
        Lang_pt = "Portugués",
        Lang_it = "Italiano",
    },
    pt = {
        TabUniversal = "Universal",
        TabGames = "Jogos",
        TabFavorites = "Favoritos",
        TabServer = "Servidor",
        TabLanguage = "Idioma",
        SectionUniversal = "Scripts Universais",
        SectionGames = "Jogos",
        SectionServerMgmt = "Gestão do servidor",
        SectionJoinJob = "Entrar por JobId",
        BtnFly = "Voar, saltar, noclip",
        BtnFling = "Fling",
        BtnRivals = "Rivals",
        BtnApoc = "Apocalypse rising 2",
        BtnBloxstrike = "Bloxstrike",
        BtnJailbird = "Jailbird",
        BtnMM2 = "MM2",
        BtnMurder = "Murder VS Sheriff",
        BtnRejoin = "REENTRAR NO SERVIDOR",
        BtnCopyJob = "COPIAR JOBID",
        BtnAutoRejoin = "REENTRAR AUTO EM CRASH",
        BtnJoinJob = "TELEPORTAR PARA JOBID",
        BtnMask = "OCULTAR DADOS",
        BtnUnmask = "MOSTRAR",
        PlaceholderJob = "COLE O JOBID AQUI...",
        PlaceholderSearch = " PESQUISAR SCRIPTS...",
        KeyTitle = "CHAVE NECESSÁRIA",
        KeySub = "Digite a chave do nosso servidor Discord:",
        KeyPlaceholder = "Digite a chave aqui...",
        KeyCheck = "VERIFICAR CHAVE",
        KeyDiscord = "OBTER DISCORD",
        KeyStatusCorrect = "CHAVE CORRETA! CARREGANDO...",
        KeyStatusInvalid = "CHAVE INVÁLIDA! TENTE NOVAMENTE.",
        KeyStatusCopied = "LINK DO DISCORD COPIADO!",
        KeyStatusJoin = "ENTRE: discord.gg/VrQtWF9tj",
        CopyJobSuccess = " JOBID COPIADO!",
        CopyJobDefault = " COPIAR JOBID",
        AnonIdentity = "IDENTIDADE: OCULTA",
        AnonSoftware = "SOFTWARE: OCULTO",
        Identity = "IDENTIDADE: ",
        Software = "SOFTWARE: ",
        RejoinOn = " REENTRAR AUTO EM CRASH: [ ON ]",
        RejoinOff = " REENTRAR AUTO EM CRASH: [ OFF ]",
        ExecuteText = " EXECUTAR: ",
        NameLabel = "ZHOAN HUB",
        FPSLabel = "FPS: 00 | MS: 00.0",
        DiscordLabel = " OBTER DISCORD",
        LanguageLabel = "Idioma",
        Lang_en = "Inglês",
        Lang_fr = "Francês",
        Lang_es = "Espanhol",
        Lang_pt = "Português",
        Lang_it = "Italiano",
    },
    it = {
        TabUniversal = "Universale",
        TabGames = "Giochi",
        TabFavorites = "Preferiti",
        TabServer = "Server",
        TabLanguage = "Lingua",
        SectionUniversal = "Script Universali",
        SectionGames = "Giochi",
        SectionServerMgmt = "Gestione Server",
        SectionJoinJob = "Unisciti tramite JobId",
        BtnFly = "Volare, saltare, noclip",
        BtnFling = "Fling",
        BtnRivals = "Rivals",
        BtnApoc = "Apocalypse rising 2",
        BtnBloxstrike = "Bloxstrike",
        BtnJailbird = "Jailbird",
        BtnMM2 = "MM2",
        BtnMurder = "Murder VS Sheriff",
        BtnRejoin = "RIENTRA NEL SERVER",
        BtnCopyJob = "COPIA JOBID",
        BtnAutoRejoin = "RIENTRA AUTO IN CASO DI CRASH",
        BtnJoinJob = "TELEPORTA A JOBID",
        BtnMask = "NASCONDI DATI",
        BtnUnmask = "MOSTRA",
        PlaceholderJob = "INCOLLA JOBID QUI...",
        PlaceholderSearch = " CERCA SCRIPT...",
        KeyTitle = "CHIAVE RICHIESTA",
        KeySub = "Inserisci la chiave dal nostro server Discord:",
        KeyPlaceholder = "Inserisci la chiave qui...",
        KeyCheck = "VERIFICA CHIAVE",
        KeyDiscord = "OTTIENI DISCORD",
        KeyStatusCorrect = "CHIAVE CORRETTA! CARICAMENTO...",
        KeyStatusInvalid = "CHIAVE NON VALIDA! RIPROVA.",
        KeyStatusCopied = "LINK DISCORD COPIATO!",
        KeyStatusJoin = "UNISCITI: discord.gg/VrQtWF9tj",
        CopyJobSuccess = " JOBID COPIATO!",
        CopyJobDefault = " COPIA JOBID",
        AnonIdentity = "IDENTITÀ: NASCOSTA",
        AnonSoftware = "SOFTWARE: NASCOSTO",
        Identity = "IDENTITÀ: ",
        Software = "SOFTWARE: ",
        RejoinOn = " RIENTRA AUTO IN CASO DI CRASH: [ ON ]",
        RejoinOff = " RIENTRA AUTO IN CASO DI CRASH: [ OFF ]",
        ExecuteText = " ESEGUI: ",
        NameLabel = "ZHOAN HUB",
        FPSLabel = "FPS: 00 | MS: 00.0",
        DiscordLabel = " OTTIENI DISCORD",
        LanguageLabel = "Lingua",
        Lang_en = "Inglese",
        Lang_fr = "Francese",
        Lang_es = "Spagnolo",
        Lang_pt = "Portoghese",
        Lang_it = "Italiano",
    }
}

local function getText(key)
    local langTable = _G.Translations[_G.CurrentLanguage] or _G.Translations.en
    return langTable[key] or _G.Translations.en[key] or key
end

local ZhoanHub = Instance.new("ScreenGui")
ZhoanHub.Name = "ZHOAN_VANTA"
ZhoanHub.ResetOnSpawn = false
ZhoanHub.ZIndexBehavior = Enum.ZIndexBehavior.Global

pcall(function() ZhoanHub.Parent = CoreGui end)
if not ZhoanHub.Parent then ZhoanHub.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

local savedKey = nil
local isUnlocked = false
local fileName = "ZhoanHub_Config_" .. Players.LocalPlayer.Name .. ".json"
_G.CurrentLanguage = "en"

local function loadSavedData()
    if readfile and isfile and isfile(fileName) then
        pcall(function()
            local content = readfile(fileName)
            local data = HttpService:JSONDecode(content)
            if type(data) == "table" then
                if data.SavedKey then savedKey = data.SavedKey end
                if data.Language then _G.CurrentLanguage = data.Language end
            end
        end)
    end
end

local function saveDataToFile(key, lang)
    if writefile then
        pcall(function()
            local content = ""
            if isfile and isfile(fileName) then
                content = readfile(fileName)
            end
            local data = {}
            if content and content ~= "" then
                data = HttpService:JSONDecode(content)
            end
            if key then data.SavedKey = key end
            if lang then data.Language = lang end
            writefile(fileName, HttpService:JSONEncode(data))
        end)
    end
end

loadSavedData()

if savedKey and savedKey == CORRECT_KEY then
    isUnlocked = true
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 560, 0, 380)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
MainFrame.BorderColor3 = Color3.fromRGB(255, 100, 0)
MainFrame.BorderSizePixel = 1
MainFrame.Active = true
MainFrame.ZIndex = 1
MainFrame.Visible = isUnlocked
MainFrame.Parent = ZhoanHub

local LockFrame = Instance.new("Frame")
LockFrame.Name = "LockFrame"
LockFrame.Size = UDim2.new(0, 350, 0, 250)
LockFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
LockFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
LockFrame.BorderColor3 = Color3.fromRGB(255, 100, 0)
LockFrame.BorderSizePixel = 1
LockFrame.Active = true
LockFrame.ZIndex = 10
LockFrame.Visible = not isUnlocked
LockFrame.Parent = ZhoanHub

local LockTitle = Instance.new("TextLabel")
LockTitle.Size = UDim2.new(1, 0, 0, 50)
LockTitle.Position = UDim2.new(0, 0, 0, 10)
LockTitle.BackgroundTransparency = 1
LockTitle.Text = getText("KeyTitle")
LockTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LockTitle.TextSize = 16
LockTitle.Font = Enum.Font.Code
LockTitle.TextXAlignment = Enum.TextXAlignment.Center
LockTitle.ZIndex = 11
LockTitle.Parent = LockFrame

local LockSub = Instance.new("TextLabel")
LockSub.Size = UDim2.new(1, -40, 0, 40)
LockSub.Position = UDim2.new(0, 20, 0, 45)
LockSub.BackgroundTransparency = 1
LockSub.Text = getText("KeySub")
LockSub.TextColor3 = Color3.fromRGB(120, 125, 140)
LockSub.TextSize = 12
LockSub.Font = Enum.Font.Code
LockSub.TextWrapped = true
LockSub.TextXAlignment = Enum.TextXAlignment.Center
LockSub.ZIndex = 11
LockSub.Parent = LockFrame

local LockInput = Instance.new("TextBox")
LockInput.Size = UDim2.new(1, -40, 0, 35)
LockInput.Position = UDim2.new(0, 20, 0, 95)
LockInput.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
LockInput.BorderColor3 = Color3.fromRGB(255, 100, 0)
LockInput.BorderSizePixel = 1
LockInput.Text = ""
LockInput.PlaceholderText = getText("KeyPlaceholder")
LockInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
LockInput.TextColor3 = Color3.fromRGB(255, 255, 255)
LockInput.TextSize = 13
LockInput.Font = Enum.Font.Code
LockInput.TextXAlignment = Enum.TextXAlignment.Center
LockInput.ZIndex = 11
LockInput.Parent = LockFrame

local LockCheckBtn = Instance.new("TextButton")
LockCheckBtn.Size = UDim2.new(0, 145, 0, 35)
LockCheckBtn.Position = UDim2.new(0, 20, 0, 145)
LockCheckBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
LockCheckBtn.BorderSizePixel = 0
LockCheckBtn.Text = getText("KeyCheck")
LockCheckBtn.TextColor3 = Color3.fromRGB(10, 10, 12)
LockCheckBtn.TextSize = 13
LockCheckBtn.Font = Enum.Font.Code
LockCheckBtn.ZIndex = 11
LockCheckBtn.Parent = LockFrame

local LockDiscordBtn = Instance.new("TextButton")
LockDiscordBtn.Size = UDim2.new(0, 145, 0, 35)
LockDiscordBtn.Position = UDim2.new(1, -165, 0, 145)
LockDiscordBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
LockDiscordBtn.BorderColor3 = Color3.fromRGB(255, 100, 0)
LockDiscordBtn.BorderSizePixel = 1
LockDiscordBtn.Text = getText("KeyDiscord")
LockDiscordBtn.TextColor3 = Color3.fromRGB(255, 100, 0)
LockDiscordBtn.TextSize = 13
LockDiscordBtn.Font = Enum.Font.Code
LockDiscordBtn.ZIndex = 11
LockDiscordBtn.Parent = LockFrame

local LockStatus = Instance.new("TextLabel")
LockStatus.Size = UDim2.new(1, 0, 0, 30)
LockStatus.Position = UDim2.new(0, 0, 0, 195)
LockStatus.BackgroundTransparency = 1
LockStatus.Text = ""
LockStatus.TextColor3 = Color3.fromRGB(255, 100, 0)
LockStatus.TextSize = 12
LockStatus.Font = Enum.Font.Code
LockStatus.TextXAlignment = Enum.TextXAlignment.Center
LockStatus.ZIndex = 11
LockStatus.Parent = LockFrame

local lockDragging, lockDragInput, lockDragStart, lockStartPos
LockFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        lockDragging = true
        lockDragStart = input.Position
        lockStartPos = LockFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then lockDragging = false end
        end)
    end
end)

LockFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        lockDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == lockDragInput and lockDragging then
        local delta = input.Position - lockDragStart
        LockFrame.Position = UDim2.new(lockStartPos.X.Scale, lockStartPos.X.Offset + delta.X, lockStartPos.Y.Scale, lockStartPos.Y.Offset + delta.Y)
    end
end)

LockCheckBtn.MouseButton1Click:Connect(function()
    local inputKey = LockInput.Text:upper():gsub("%s+", "")
    if inputKey == CORRECT_KEY then
        LockStatus.Text = getText("KeyStatusCorrect")
        LockStatus.TextColor3 = Color3.fromRGB(0, 255, 120)
        saveDataToFile(CORRECT_KEY, _G.CurrentLanguage)
        isUnlocked = true
        LockFrame.Visible = false
        MainFrame.Visible = true
        task.delay(1, function()
            LockStatus.Text = ""
        end)
    else
        LockStatus.Text = getText("KeyStatusInvalid")
        LockStatus.TextColor3 = Color3.fromRGB(255, 53, 53)
        LockInput.Text = ""
        task.delay(3, function()
            LockStatus.Text = ""
        end)
    end
end)

LockDiscordBtn.MouseButton1Click:Connect(function()
    local setclip = setclipboard or toclipboard or (Clipboard and Clipboard.set) or (syn and syn.write_to_clipboard)
    if setclip then
        setclip("https://discord.gg/VrQtWF9tj")
        LockStatus.Text = getText("KeyStatusCopied")
        LockStatus.TextColor3 = Color3.fromRGB(0, 220, 255)
        task.delay(2, function()
            LockStatus.Text = ""
        end)
    else
        LockStatus.Text = getText("KeyStatusJoin")
        LockStatus.TextColor3 = Color3.fromRGB(255, 165, 0)
        task.delay(3, function()
            LockStatus.Text = ""
        end)
    end
end)

local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    TweenService:Create(MainFrame, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {Position = targetPos}):Play()
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

local TopLine = Instance.new("Frame")
TopLine.Name = "TopLine"
TopLine.Size = UDim2.new(1, 0, 0, 2)
TopLine.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
TopLine.BorderSizePixel = 0
TopLine.ZIndex = 2
TopLine.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0, 120, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 2)
Title.BackgroundTransparency = 1
Title.Text = getText("NameLabel")
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 2
Title.Parent = MainFrame

local PerformanceLabel = Instance.new("TextLabel")
PerformanceLabel.Name = "PerformanceLabel"
PerformanceLabel.Size = UDim2.new(0, 180, 0, 40)
PerformanceLabel.Position = UDim2.new(0.5, -90, 0, 2)
PerformanceLabel.BackgroundTransparency = 1
PerformanceLabel.Text = getText("FPSLabel")
PerformanceLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
PerformanceLabel.TextSize = 12
PerformanceLabel.Font = Enum.Font.Code
PerformanceLabel.TextXAlignment = Enum.TextXAlignment.Center
PerformanceLabel.ZIndex = 2
PerformanceLabel.Parent = MainFrame

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 130, 1, -150)
Sidebar.Position = UDim2.new(0, 15, 0, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
Sidebar.BorderColor3 = Color3.fromRGB(30, 30, 35)
Sidebar.BorderSizePixel = 1
Sidebar.ZIndex = 2
Sidebar.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.Parent = Sidebar

local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -180, 1, -150)
ContentContainer.Position = UDim2.new(0, 160, 0, 50)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ZIndex = 2
ContentContainer.Parent = MainFrame

local UniversalPage = Instance.new("ScrollingFrame")
UniversalPage.Name = "UniversalPage"
UniversalPage.Size = UDim2.new(1, 0, 1, 0)
UniversalPage.BackgroundTransparency = 1
UniversalPage.ScrollBarThickness = 2
UniversalPage.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 0)
UniversalPage.Visible = true
UniversalPage.ZIndex = 3
UniversalPage.Parent = ContentContainer

local GamesPage = Instance.new("ScrollingFrame")
GamesPage.Name = "GamesPage"
GamesPage.Size = UDim2.new(1, 0, 1, 0)
GamesPage.BackgroundTransparency = 1
GamesPage.ScrollBarThickness = 2
GamesPage.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 0)
GamesPage.Visible = false
GamesPage.ZIndex = 3
GamesPage.Parent = ContentContainer

local FavoritesPage = Instance.new("ScrollingFrame")
FavoritesPage.Name = "FavoritesPage"
FavoritesPage.Size = UDim2.new(1, 0, 1, 0)
FavoritesPage.BackgroundTransparency = 1
FavoritesPage.ScrollBarThickness = 2
FavoritesPage.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 0)
FavoritesPage.Visible = false
FavoritesPage.ZIndex = 3
FavoritesPage.Parent = ContentContainer

local ServerPage = Instance.new("ScrollingFrame")
ServerPage.Name = "ServerPage"
ServerPage.Size = UDim2.new(1, 0, 1, 0)
ServerPage.BackgroundTransparency = 1
ServerPage.ScrollBarThickness = 2
ServerPage.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 0)
ServerPage.Visible = false
ServerPage.ZIndex = 3
ServerPage.Parent = ContentContainer

local LanguagePage = Instance.new("ScrollingFrame")
LanguagePage.Name = "LanguagePage"
LanguagePage.Size = UDim2.new(1, 0, 1, 0)
LanguagePage.BackgroundTransparency = 1
LanguagePage.ScrollBarThickness = 2
LanguagePage.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 0)
LanguagePage.Visible = false
LanguagePage.ZIndex = 3
LanguagePage.Parent = ContentContainer

local UniversalList = Instance.new("UIListLayout")
UniversalList.SortOrder = Enum.SortOrder.LayoutOrder
UniversalList.Padding = UDim.new(0, 10)
UniversalList.Parent = UniversalPage

local GamesList = Instance.new("UIListLayout")
GamesList.SortOrder = Enum.SortOrder.LayoutOrder
GamesList.Padding = UDim.new(0, 10)
GamesList.Parent = GamesPage

local FavoritesList = Instance.new("UIListLayout")
FavoritesList.SortOrder = Enum.SortOrder.LayoutOrder
FavoritesList.Padding = UDim.new(0, 10)
FavoritesList.Parent = FavoritesPage

local ServerList = Instance.new("UIListLayout")
ServerList.SortOrder = Enum.SortOrder.LayoutOrder
ServerList.Padding = UDim.new(0, 10)
ServerList.Parent = ServerPage

local LanguageList = Instance.new("UIListLayout")
LanguageList.SortOrder = Enum.SortOrder.LayoutOrder
LanguageList.Padding = UDim.new(0, 10)
LanguageList.Parent = LanguagePage

local registeredTabs = {}
local savedConfig = {Favorites = {}, AutoRejoin = false}

local function loadConfigFromFile()
    if readfile and isfile and isfile(fileName) then
        pcall(function()
            local content = readfile(fileName)
            local data = HttpService:JSONDecode(content)
            if type(data) == "table" then
                if data.Favorites then savedConfig.Favorites = data.Favorites end
                if data.AutoRejoin ~= nil then savedConfig.AutoRejoin = data.AutoRejoin end
                if data.Language then _G.CurrentLanguage = data.Language end
            end
        end)
    end
end

local function saveConfigToFile()
    if writefile then
        pcall(function()
            local content = ""
            if isfile and isfile(fileName) then
                content = readfile(fileName)
            end
            local data = {}
            if content and content ~= "" then
                data = HttpService:JSONDecode(content)
            end
            data.Favorites = savedConfig.Favorites
            data.AutoRejoin = savedConfig.AutoRejoin
            data.Language = _G.CurrentLanguage
            writefile(fileName, HttpService:JSONEncode(data))
        end)
    end
end

loadConfigFromFile()

local function CreateSearchBar(parentPage)
    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "SearchBar"
    SearchBox.Size = UDim2.new(1, -5, 0, 28)
    SearchBox.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
    SearchBox.BorderColor3 = Color3.fromRGB(255, 100, 0)
    SearchBox.BorderSizePixel = 1
    SearchBox.Text = ""
    SearchBox.PlaceholderText = getText("PlaceholderSearch")
    SearchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.TextSize = 11
    SearchBox.Font = Enum.Font.Code
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.LayoutOrder = -1
    SearchBox.ZIndex = 4
    SearchBox.Parent = parentPage

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        for _, section in pairs(parentPage:GetChildren()) do
            if section:IsA("Frame") and section.Name:find("Section") then
                local content = section:FindFirstChild("Content")
                if content then
                    for _, row in pairs(content:GetChildren()) do
                        if row:IsA("Frame") and row.Name == "ButtonRow" then
                            local button = row:FindFirstChildOfClass("TextButton")
                            if button then
                                local btnText = button.Text:lower()
                                if query == "" or btnText:find(query) then
                                    row.Visible = true
                                else
                                    row.Visible = false
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

CreateSearchBar(UniversalPage)
CreateSearchBar(GamesPage)

local function CreateTab(nameKey, pageTarget, order)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = nameKey .. "Tab"
    TabButton.Size = UDim2.new(1, 0, 0, 34)
    TabButton.BackgroundColor3 = order == 1 and Color3.fromRGB(20, 20, 25) or Color3.fromRGB(14, 14, 16)
    TabButton.BorderSizePixel = 0
    TabButton.Text = " " .. getText(nameKey):upper()
    TabButton.TextColor3 = order == 1 and Color3.fromRGB(255, 100, 0) or Color3.fromRGB(140, 140, 150)
    TabButton.TextSize = 12
    TabButton.Font = Enum.Font.Code
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.LayoutOrder = order
    TabButton.ZIndex = 4
    TabButton.Parent = Sidebar

    local BorderIndicator = Instance.new("Frame")
    BorderIndicator.Size = UDim2.new(0, 2, 1, 0)
    BorderIndicator.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    BorderIndicator.BorderSizePixel = 0
    BorderIndicator.Visible = order == 1
    BorderIndicator.ZIndex = 5
    BorderIndicator.Parent = TabButton

    table.insert(registeredTabs, {Btn = TabButton, Indicator = BorderIndicator, Page = pageTarget, NameKey = nameKey})

    TabButton.MouseEnter:Connect(function()
        if pageTarget.Visible == false then
            TweenService:Create(TabButton, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end
    end)

    TabButton.MouseLeave:Connect(function()
        if pageTarget.Visible == false then
            TweenService:Create(TabButton, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(140, 140, 150)}):Play()
        end
    end)

    TabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(registeredTabs) do
            tab.Btn.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
            tab.Btn.TextColor3 = Color3.fromRGB(140, 140, 150)
            tab.Indicator.Visible = false
            tab.Page.Visible = false
        end
        TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        TabButton.TextColor3 = Color3.fromRGB(255, 100, 0)
        BorderIndicator.Visible = true
        pageTarget.Visible = true
    end)

    return TabButton
end

local function CreateSection(parent, titleKey)
    local Section = Instance.new("Frame")
    Section.Name = titleKey:upper():gsub(" ", "") .. "Section"
    Section.Size = UDim2.new(1, -5, 0, 0)
    Section.AutomaticSize = Enum.AutomaticSize.Y
    Section.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
    Section.BorderColor3 = Color3.fromRGB(30, 30, 35)
    Section.BorderSizePixel = 1
    Section.ZIndex = 4
    Section.Parent = parent

    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Size = UDim2.new(1, -10, 0, 24)
    SectionTitle.Position = UDim2.new(0, 10, 0, 2)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = string.upper(getText(titleKey))
    SectionTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
    SectionTitle.TextSize = 11
    SectionTitle.Font = Enum.Font.Code
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.ZIndex = 5
    SectionTitle.Parent = Section

    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -20, 0, 0)
    Content.Position = UDim2.new(0, 10, 0, 30)
    Content.AutomaticSize = Enum.AutomaticSize.Y
    Content.BackgroundTransparency = 1
    Content.ZIndex = 5
    Content.Parent = Section

    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 6)
    Layout.Parent = Content

    local function updateSectionSize()
        local visibleHeight = 0
        local itemsCount = 0
        for _, child in pairs(Content:GetChildren()) do
            if (child:IsA("Frame") or child:IsA("TextBox") or child:IsA("TextButton")) and child.Visible then
                visibleHeight = visibleHeight + child.AbsoluteSize.Y + Layout.Padding.Offset
                itemsCount = itemsCount + 1
            end
        end
        if itemsCount == 0 and (parent == FavoritesPage or parent == LanguagePage) then
            Section.Visible = false
        else
            Section.Visible = true
            Section.Size = UDim2.new(1, -5, 0, visibleHeight + 40)
        end
    end

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSectionSize)
    Content.ChildRemoved:Connect(updateSectionSize)
    return Content
end

local FavUniversalSection = CreateSection(FavoritesPage, "SectionUniversal")
local FavGamesSection = CreateSection(FavoritesPage, "SectionGames")
local LanguageSection = CreateSection(LanguagePage, "LanguageLabel")

local function AddButton(parent, textKey, urlString)
    local Row = Instance.new("Frame")
    Row.Name = "ButtonRow"
    Row.Size = UDim2.new(1, 0, 0, 26)
    Row.BackgroundTransparency = 1
    Row.ZIndex = 5
    Row.Parent = parent

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -30, 1, 0)
    Button.BackgroundTransparency = 1
    Button.BorderColor3 = Color3.fromRGB(35, 35, 40)
    Button.BorderSizePixel = 1
    Button.Text = getText("ExecuteText") .. string.upper(getText(textKey))
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.TextSize = 11
    Button.Font = Enum.Font.Code
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.ZIndex = 6
    Button.Parent = Row

    local FavBtn = Instance.new("TextButton")
    FavBtn.Size = UDim2.new(0, 26, 1, 0)
    FavBtn.Position = UDim2.new(1, -26, 0, 0)
    FavBtn.BackgroundTransparency = 1
    FavBtn.BorderColor3 = Color3.fromRGB(35, 35, 40)
    FavBtn.BorderSizePixel = 1
    FavBtn.Text = "☆"
    FavBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    FavBtn.TextSize = 13
    FavBtn.Font = Enum.Font.Code
    FavBtn.ZIndex = 6
    FavBtn.Parent = Row

    local isFavorite = false
    local MirrorRow = nil

    local function updateParentSection(p)
        local layout = p:FindFirstChildOfClass("UIListLayout")
        if layout then
            local section = p.Parent
            local visibleHeight = 0
            local itemsCount = 0
            for _, child in pairs(p:GetChildren()) do
                if child:IsA("Frame") and child.Visible then
                    visibleHeight = visibleHeight + child.AbsoluteSize.Y + layout.Padding.Offset
                    itemsCount = itemsCount + 1
                end
            end
            if itemsCount == 0 and p.Parent.Parent == FavoritesPage then
                section.Visible = false
            else
                section.Visible = true
                section.Size = UDim2.new(1, -5, 0, visibleHeight + 40)
            end
        end
    end

    Row:GetPropertyChangedSignal("Visible"):Connect(function()
        updateParentSection(parent)
    end)

    Button.MouseEnter:Connect(function()
        Button.BackgroundTransparency = 0
        TweenService:Create(Button, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(255, 100, 0), BorderColor3 = Color3.fromRGB(255, 255, 255), TextColor3 = Color3.fromRGB(10, 10, 12)}):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.08), {BorderColor3 = Color3.fromRGB(35, 35, 40), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        task.wait(0.08)
        if Row.Parent then Button.BackgroundTransparency = 1 end
    end)

    Button.MouseButton1Click:Connect(function()
        pcall(function() loadstring(game:HttpGet(urlString))() end)
    end)

    local toggleFavorite
    toggleFavorite = function(forceState, skipSave)
        if forceState ~= nil then
            isFavorite = forceState
        else
            isFavorite = not isFavorite
        end

        if isFavorite then
            FavBtn.Text = "⭐"
            savedConfig.Favorites[textKey] = urlString
            if not skipSave then saveConfigToFile() end

            local parentNameNormalized = parent.Parent.Name:upper():gsub(" ", "")
            local targetSection = (parentNameNormalized:find("UNIVERSAL")) and FavUniversalSection or FavGamesSection

            if not MirrorRow then
                MirrorRow = Instance.new("Frame")
                MirrorRow.Name = "ButtonRow"
                MirrorRow.Size = UDim2.new(1, 0, 0, 26)
                MirrorRow.BackgroundTransparency = 1
                MirrorRow.ZIndex = 5
                MirrorRow.Parent = targetSection

                local MButton = Button:Clone()
                MButton.Parent = MirrorRow
                MButton.Text = getText("ExecuteText") .. string.upper(getText(textKey))
                MButton.MouseButton1Click:Connect(function()
                    pcall(function() loadstring(game:HttpGet(urlString))() end)
                end)
                MButton.MouseEnter:Connect(function()
                    MButton.BackgroundTransparency = 0
                    TweenService:Create(MButton, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(255, 100, 0), BorderColor3 = Color3.fromRGB(255, 255, 255), TextColor3 = Color3.fromRGB(10, 10, 12)}):Play()
                end)
                MButton.MouseLeave:Connect(function()
                    TweenService:Create(MButton, TweenInfo.new(0.08), {BorderColor3 = Color3.fromRGB(35, 35, 40), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                    task.wait(0.08)
                    if MirrorRow.Parent then MButton.BackgroundTransparency = 1 end
                end)

                local MFavBtn = FavBtn:Clone()
                MFavBtn.Parent = MirrorRow
                MFavBtn.MouseButton1Click:Connect(function()
                    toggleFavorite(false)
                end)

                MirrorRow:GetPropertyChangedSignal("Visible"):Connect(function()
                    updateParentSection(targetSection)
                end)
                updateParentSection(targetSection)
            end
        else
            FavBtn.Text = "☆"
            savedConfig.Favorites[textKey] = nil
            if not skipSave then saveConfigToFile() end
            if MirrorRow then
                local targetSection = MirrorRow.Parent
                MirrorRow:Destroy()
                MirrorRow = nil
                if targetSection then updateParentSection(targetSection) end
            end
        end
    end

    FavBtn.MouseButton1Click:Connect(function()
        toggleFavorite(nil)
    end)

    task.defer(function()
        if savedConfig.Favorites[textKey] then
            toggleFavorite(true, true)
        end
    end)
end

local function AddLanguageOption(parent, langCode)
    local Row = Instance.new("Frame")
    Row.Name = "LangRow_" .. langCode
    Row.Size = UDim2.new(1, 0, 0, 26)
    Row.BackgroundTransparency = 1
    Row.ZIndex = 5
    Row.Parent = parent

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.BorderColor3 = Color3.fromRGB(35, 35, 40)
    Button.BorderSizePixel = 1
    Button.Text = " " .. getText("Lang_" .. langCode)
    Button.TextColor3 = (_G.CurrentLanguage == langCode) and Color3.fromRGB(255, 100, 0) or Color3.fromRGB(200, 200, 200)
    Button.TextSize = 11
    Button.Font = Enum.Font.Code
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.ZIndex = 6
    Button.Parent = Row

    local CheckMark = Instance.new("TextLabel")
    CheckMark.Size = UDim2.new(0, 30, 1, 0)
    CheckMark.Position = UDim2.new(1, -30, 0, 0)
    CheckMark.BackgroundTransparency = 1
    CheckMark.Text = (_G.CurrentLanguage == langCode) and "✓" or ""
    CheckMark.TextColor3 = Color3.fromRGB(255, 100, 0)
    CheckMark.TextSize = 13
    CheckMark.Font = Enum.Font.Code
    CheckMark.TextXAlignment = Enum.TextXAlignment.Center
    CheckMark.ZIndex = 6
    CheckMark.Parent = Row

    Button.MouseEnter:Connect(function()
        Button.BackgroundTransparency = 0
        TweenService:Create(Button, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(255, 100, 0), BorderColor3 = Color3.fromRGB(255, 255, 255), TextColor3 = Color3.fromRGB(10, 10, 12)}):Play()
    end)

    Button.MouseLeave:Connect(function()
        if _G.CurrentLanguage ~= langCode then
            TweenService:Create(Button, TweenInfo.new(0.08), {BorderColor3 = Color3.fromRGB(35, 35, 40), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
            task.wait(0.08)
            if Button.Parent then Button.BackgroundTransparency = 1 end
        else
            TweenService:Create(Button, TweenInfo.new(0.08), {BorderColor3 = Color3.fromRGB(35, 35, 40), TextColor3 = Color3.fromRGB(255, 100, 0)}):Play()
            task.wait(0.08)
            if Button.Parent then Button.BackgroundTransparency = 1 end
        end
    end)

    Button.MouseButton1Click:Connect(function()
        _G.CurrentLanguage = langCode
        saveConfigToFile()
        for _, row in pairs(LanguageSection:GetChildren()) do
            if row:IsA("Frame") then
                local btn = row:FindFirstChildOfClass("TextButton")
                local chk = row:FindFirstChildOfClass("TextLabel")
                if btn and chk then
                    local code = row.Name:gsub("LangRow_", "")
                    btn.Text = " " .. getText("Lang_" .. code)
                    if code == langCode then
                        btn.TextColor3 = Color3.fromRGB(255, 100, 0)
                        chk.Text = "✓"
                    else
                        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                        chk.Text = ""
                    end
                end
            end
        end
        for _, tab in pairs(registeredTabs) do
            tab.Btn.Text = " " .. getText(tab.NameKey):upper()
        end
        for _, section in pairs({UniversalPage, GamesPage, FavoritesPage, ServerPage, LanguagePage}) do
            for _, child in pairs(section:GetChildren()) do
                if child:IsA("Frame") and child.Name:find("Section") then
                    local title = child:FindFirstChildOfClass("TextLabel")
                    if title then
                        local key = child.Name:gsub("Section", "")
                        for k, v in pairs(_G.Translations.en) do
                            if k:upper():gsub(" ", "") == key then
                                title.Text = string.upper(getText(k))
                                break
                            end
                        end
                    end
                    local content = child:FindFirstChild("Content")
                    if content then
                        for _, row in pairs(content:GetChildren()) do
                            if row:IsA("Frame") and row.Name == "ButtonRow" then
                                local btn = row:FindFirstChildOfClass("TextButton")
                                if btn then
                                    local textKey = nil
                                    for k, v in pairs(_G.Translations.en) do
                                        if k:find("Btn") and _G.Translations.en[k] and btn.Text:find(_G.Translations.en[k]) then
                                            textKey = k
                                            break
                                        end
                                    end
                                    if textKey then
                                        btn.Text = getText("ExecuteText") .. string.upper(getText(textKey))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        Title.Text = getText("NameLabel")
        PerformanceLabel.Text = getText("FPSLabel")
        SearchBox = UniversalPage:FindFirstChild("SearchBar")
        if SearchBox then SearchBox.PlaceholderText = getText("PlaceholderSearch") end
        SearchBox = GamesPage:FindFirstChild("SearchBar")
        if SearchBox then SearchBox.PlaceholderText = getText("PlaceholderSearch") end
        local rejoinBtn = ServerPage:FindFirstChild("RejoinBtn")
        if rejoinBtn then rejoinBtn.Text = getText("BtnRejoin") end
        local copyBtn = ServerPage:FindFirstChild("CopyBtn")
        if copyBtn then copyBtn.Text = getText("BtnCopyJob") end
        local autoBtn = ServerPage:FindFirstChild("AutoBtn")
        if autoBtn then
            if savedConfig.AutoRejoin then
                autoBtn.Text = getText("RejoinOn")
                autoBtn.TextColor3 = Color3.fromRGB(0, 220, 255)
            else
                autoBtn.Text = getText("RejoinOff")
                autoBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
        local jobInput = ServerPage:FindFirstChild("JobInput")
        if jobInput then jobInput.PlaceholderText = getText("PlaceholderJob") end
        local joinBtn = ServerPage:FindFirstChild("JoinBtn")
        if joinBtn then joinBtn.Text = getText("BtnJoinJob") end
        local anonBtn = MainFrame:FindFirstChild("AnonBtn")
        if anonBtn then
            if isAnon then
                anonBtn.Text = "[ " .. getText("BtnUnmask") .. " ]"
            else
                anonBtn.Text = "[ " .. getText("BtnMask") .. " ]"
            end
        end
    end)
end

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 6)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.Code
CloseBtn.ZIndex = 3
CloseBtn.Parent = MainFrame

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.08), {TextColor3 = Color3.fromRGB(255, 0, 0)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.08), {TextColor3 = Color3.fromRGB(150, 150, 160)}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function()
    ZhoanHub:Destroy()
end)

local UserPanel = Instance.new("Frame")
UserPanel.Size = UDim2.new(1, -30, 0, 75)
UserPanel.Position = UDim2.new(0, 15, 1, -90)
UserPanel.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
UserPanel.BorderColor3 = Color3.fromRGB(30, 30, 35)
UserPanel.BorderSizePixel = 1
UserPanel.ZIndex = 2
UserPanel.Parent = MainFrame

local SkinImage = Instance.new("ImageLabel")
SkinImage.Size = UDim2.new(0, 55, 0, 55)
SkinImage.Position = UDim2.new(0, 10, 0.5, -27)
SkinImage.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
SkinImage.BorderColor3 = Color3.fromRGB(255, 100, 0)
SkinImage.BorderSizePixel = 1
SkinImage.ZIndex = 3
SkinImage.Parent = UserPanel

pcall(function()
    local content, isReady = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    if isReady then SkinImage.Image = content end
end)

local NameLabel = Instance.new("TextLabel")
NameLabel.Size = UDim2.new(0, 220, 0, 16)
NameLabel.Position = UDim2.new(0, 75, 0, 6)
NameLabel.BackgroundTransparency = 1
NameLabel.Text = getText("Identity") .. Players.LocalPlayer.Name:upper()
NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NameLabel.TextSize = 11
NameLabel.Font = Enum.Font.Code
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.ZIndex = 3
NameLabel.Parent = UserPanel

local detectedExecutor = (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "Unknown"
local ExecLabel = Instance.new("TextLabel")
ExecLabel.Size = UDim2.new(0, 220, 0, 16)
ExecLabel.Position = UDim2.new(0, 75, 0, 24)
ExecLabel.BackgroundTransparency = 1
ExecLabel.Text = getText("Software") .. detectedExecutor:upper()
ExecLabel.TextColor3 = Color3.fromRGB(130, 130, 140)
ExecLabel.TextSize = 11
ExecLabel.Font = Enum.Font.Code
ExecLabel.TextXAlignment = Enum.TextXAlignment.Left
ExecLabel.ZIndex = 3
ExecLabel.Parent = UserPanel

local DiscordBtn = Instance.new("TextButton")
DiscordBtn.Size = UDim2.new(0, 150, 0, 16)
DiscordBtn.Position = UDim2.new(0, 75, 0, 42)
DiscordBtn.BackgroundTransparency = 1
DiscordBtn.Text = getText("DiscordLabel")
DiscordBtn.TextColor3 = Color3.fromRGB(255, 100, 0)
DiscordBtn.TextSize = 11
DiscordBtn.Font = Enum.Font.Code
DiscordBtn.TextXAlignment = Enum.TextXAlignment.Left
DiscordBtn.ZIndex = 3
DiscordBtn.Parent = UserPanel

DiscordBtn.MouseButton1Click:Connect(function()
    local setclip = setclipboard or toclipboard or (Clipboard and Clipboard.set) or (syn and syn.write_to_clipboard)
    if setclip then
        setclip("https://discord.gg/AR5NU2hQu")
        local oldText = DiscordBtn.Text
        DiscordBtn.Text = " COPIED!"
        DiscordBtn.TextColor3 = Color3.fromRGB(0, 220, 255)
        task.delay(1.5, function()
            DiscordBtn.Text = oldText
            DiscordBtn.TextColor3 = Color3.fromRGB(255, 100, 0)
        end)
    else
        DiscordBtn.Text = " NOT SUPPORTED"
    end
end)

local TimeLabel = Instance.new("TextLabel")
TimeLabel.Size = UDim2.new(0, 120, 0, 20)
TimeLabel.Position = UDim2.new(1, -175, 0, 12)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = "00:00:00"
TimeLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
TimeLabel.TextSize = 13
TimeLabel.Font = Enum.Font.Code
TimeLabel.TextXAlignment = Enum.TextXAlignment.Right
TimeLabel.ZIndex = 2
TimeLabel.Parent = MainFrame

local isAnon = false
local AnonBtn = Instance.new("TextButton")
AnonBtn.Name = "AnonBtn"
AnonBtn.Size = UDim2.new(0, 100, 0, 22)
AnonBtn.Position = UDim2.new(1, -112, 0, 38)
AnonBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
AnonBtn.BorderColor3 = Color3.fromRGB(255, 100, 0)
AnonBtn.BorderSizePixel = 1
AnonBtn.Text = "[ " .. getText("BtnMask") .. " ]"
AnonBtn.TextColor3 = Color3.fromRGB(255, 100, 0)
AnonBtn.TextSize = 10
AnonBtn.Font = Enum.Font.Code
AnonBtn.ZIndex = 3
AnonBtn.Parent = UserPanel

AnonBtn.MouseButton1Click:Connect(function()
    isAnon = not isAnon
    if isAnon then
        AnonBtn.Text = "[ " .. getText("BtnUnmask") .. " ]"
        AnonBtn.TextColor3 = Color3.fromRGB(0, 220, 255)
        AnonBtn.BorderColor3 = Color3.fromRGB(0, 220, 255)
        NameLabel.Text = getText("AnonIdentity")
        ExecLabel.Text = getText("AnonSoftware")
        SkinImage.Image = "rbxassetid://0"
    else
        AnonBtn.Text = "[ " .. getText("BtnMask") .. " ]"
        AnonBtn.TextColor3 = Color3.fromRGB(255, 100, 0)
        AnonBtn.BorderColor3 = Color3.fromRGB(255, 100, 0)
        NameLabel.Text = getText("Identity") .. Players.LocalPlayer.Name:upper()
        ExecLabel.Text = getText("Software") .. detectedExecutor:upper()
        pcall(function()
            local content = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            SkinImage.Image = content
        end)
    end
end)

RunService.RenderStepped:Connect(function()
    local timeTable = os.date("*t")
    TimeLabel.Text = string.format("%02d:%02d:%02d", timeTable.hour, timeTable.min, timeTable.sec)
end)

task.spawn(function()
    local lastUpdate = 0
    local frameCount = 0
    local lastFpsTime = os.clock()
    local fpsResult = 60

    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = os.clock()
        if now - lastFpsTime >= 0.25 then
            fpsResult = math.round(frameCount / (now - lastFpsTime))
            frameCount = 0
            lastFpsTime = now
        end
    end)

    while ZhoanHub.Parent do
        local now = os.clock()
        if now - lastUpdate >= 0.25 then
            lastUpdate = now
            local pingResult = "00.0"
            pcall(function()
                local rawPing = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
                pingResult = string.format("%.1f", rawPing)
            end)
            PerformanceLabel.Text = "FPS: " .. fpsResult .. " | MS: " .. pingResult
        end
        task.wait(0.05)
    end
end)

CreateTab("TabUniversal", UniversalPage, 1)
CreateTab("TabGames", GamesPage, 2)
CreateTab("TabFavorites", FavoritesPage, 3)
CreateTab("TabServer", ServerPage, 4)
CreateTab("TabLanguage", LanguagePage, 5)

local MainSection = CreateSection(UniversalPage, "SectionUniversal")
AddButton(MainSection, "BtnFly", "https://raw.githubusercontent.com/GABLELE11/ZHOAN-HUB/refs/heads/main/fly%2Cnoclip%2Cinf%20jump.lua")
AddButton(MainSection, "BtnFling", "https://raw.githubusercontent.com/GABLELE11/ZHOAN-HUB/refs/heads/main/fling.lua")

local GamesSection = CreateSection(GamesPage, "SectionGames")
AddButton(GamesSection, "BtnRivals", "https://raw.githubusercontent.com/GABLELE11/ZHOAN-HUB/refs/heads/main/rivalsa.lua")
AddButton(GamesSection, "BtnApoc", "https://raw.githubusercontent.com/GABLELE11/ZHOAN-HUB/refs/heads/main/AR2.lua")
AddButton(GamesSection, "BtnBloxstrike", "https://raw.githubusercontent.com/GABLELE11/ZHOAN-HUB/refs/heads/main/bloxstrike.lua")
AddButton(GamesSection, "BtnJailbird", "https://raw.githubusercontent.com/GABLELE11/ZHOAN-HUB/refs/heads/main/jailbird.lua")
AddButton(GamesSection, "BtnMM2", "https://raw.githubusercontent.com/GABLELE11/ZHOAN-HUB/refs/heads/main/mm2.lua")
AddButton(GamesSection, "BtnMurder", "https://raw.githubusercontent.com/GABLELE11/ZHOAN-HUB/refs/heads/main/murder%20vs%20sheriff.lua")

local ManagementSection = CreateSection(ServerPage, "SectionServerMgmt")

local RJBtn = Instance.new("TextButton")
RJBtn.Name = "RejoinBtn"
RJBtn.Size = UDim2.new(1, 0, 0, 26)
RJBtn.BackgroundTransparency = 1
RJBtn.BorderColor3 = Color3.fromRGB(35, 35, 40)
RJBtn.BorderSizePixel = 1
RJBtn.Text = getText("BtnRejoin")
RJBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
RJBtn.TextSize = 11
RJBtn.Font = Enum.Font.Code
RJBtn.TextXAlignment = Enum.TextXAlignment.Left
RJBtn.ZIndex = 6
RJBtn.Parent = ManagementSection

RJBtn.MouseEnter:Connect(function()
    RJBtn.BackgroundTransparency = 0
    TweenService:Create(RJBtn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(255, 100, 0), BorderColor3 = Color3.fromRGB(255, 255, 255), TextColor3 = Color3.fromRGB(10, 10, 12)}):Play()
end)
RJBtn.MouseLeave:Connect(function()
    TweenService:Create(RJBtn, TweenInfo.new(0.08), {BorderColor3 = Color3.fromRGB(35, 35, 40), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
    task.wait(0.08)
    if RJBtn.Parent then RJBtn.BackgroundTransparency = 1 end
end)
RJBtn.MouseButton1Click:Connect(function()
    if #Players:GetPlayers() <= 1 then
        TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
    end
end)

local CopyJobBtn = Instance.new("TextButton")
CopyJobBtn.Name = "CopyBtn"
CopyJobBtn.Size = UDim2.new(1, 0, 0, 26)
CopyJobBtn.BackgroundTransparency = 1
CopyJobBtn.BorderColor3 = Color3.fromRGB(35, 35, 40)
CopyJobBtn.BorderSizePixel = 1
CopyJobBtn.Text = getText("BtnCopyJob")
CopyJobBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CopyJobBtn.TextSize = 11
CopyJobBtn.Font = Enum.Font.Code
CopyJobBtn.TextXAlignment = Enum.TextXAlignment.Left
CopyJobBtn.ZIndex = 6
CopyJobBtn.Parent = ManagementSection

CopyJobBtn.MouseEnter:Connect(function()
    CopyJobBtn.BackgroundTransparency = 0
    TweenService:Create(CopyJobBtn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(255, 100, 0), BorderColor3 = Color3.fromRGB(255, 255, 255), TextColor3 = Color3.fromRGB(10, 10, 12)}):Play()
end)
CopyJobBtn.MouseLeave:Connect(function()
    TweenService:Create(CopyJobBtn, TweenInfo.new(0.08), {BorderColor3 = Color3.fromRGB(35, 35, 40), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
    task.wait(0.08)
    if CopyJobBtn.Parent then CopyJobBtn.BackgroundTransparency = 1 end
end)

CopyJobBtn.MouseButton1Click:Connect(function()
    local setclip = setclipboard or toclipboard or (Clipboard and Clipboard.set) or (syn and syn.write_to_clipboard)
    if setclip then
        setclip(tostring(game.JobId))
        local oldText = CopyJobBtn.Text
        CopyJobBtn.Text = getText("CopyJobSuccess")
        CopyJobBtn.TextColor3 = Color3.fromRGB(0, 220, 255)
        task.delay(1.5, function()
            CopyJobBtn.Text = getText("BtnCopyJob")
            CopyJobBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end)
    end
end)

local AutoRejoinBtn = Instance.new("TextButton")
AutoRejoinBtn.Name = "AutoBtn"
AutoRejoinBtn.Size = UDim2.new(1, 0, 0, 26)
AutoRejoinBtn.BackgroundTransparency = 1
AutoRejoinBtn.BorderColor3 = Color3.fromRGB(35, 35, 40)
AutoRejoinBtn.BorderSizePixel = 1
AutoRejoinBtn.Text = savedConfig.AutoRejoin and getText("RejoinOn") or getText("RejoinOff")
AutoRejoinBtn.TextColor3 = savedConfig.AutoRejoin and Color3.fromRGB(0, 220, 255) or Color3.fromRGB(200, 200, 200)
AutoRejoinBtn.TextSize = 11
AutoRejoinBtn.Font = Enum.Font.Code
AutoRejoinBtn.TextXAlignment = Enum.TextXAlignment.Left
AutoRejoinBtn.ZIndex = 6
AutoRejoinBtn.Parent = ManagementSection

local function toggleAutoRejoin()
    savedConfig.AutoRejoin = not savedConfig.AutoRejoin
    saveConfigToFile()
    if savedConfig.AutoRejoin then
        AutoRejoinBtn.Text = getText("RejoinOn")
        AutoRejoinBtn.TextColor3 = Color3.fromRGB(0, 220, 255)
    else
        AutoRejoinBtn.Text = getText("RejoinOff")
        AutoRejoinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end
AutoRejoinBtn.MouseButton1Click:Connect(toggleAutoRejoin)

local InputSection = CreateSection(ServerPage, "SectionJoinJob")

local JobIdInput = Instance.new("TextBox")
JobIdInput.Name = "JobInput"
JobIdInput.Size = UDim2.new(1, 0, 0, 28)
JobIdInput.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
JobIdInput.BorderColor3 = Color3.fromRGB(255, 100, 0)
JobIdInput.BorderSizePixel = 1
JobIdInput.Text = ""
JobIdInput.PlaceholderText = getText("PlaceholderJob")
JobIdInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
JobIdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
JobIdInput.TextSize = 11
JobIdInput.Font = Enum.Font.Code
JobIdInput.TextXAlignment = Enum.TextXAlignment.Center
JobIdInput.ZIndex = 6
JobIdInput.Parent = InputSection

local JoinJobBtn = Instance.new("TextButton")
JoinJobBtn.Name = "JoinBtn"
JoinJobBtn.Size = UDim2.new(1, 0, 0, 26)
JoinJobBtn.BackgroundTransparency = 1
JoinJobBtn.BorderColor3 = Color3.fromRGB(35, 35, 40)
JoinJobBtn.BorderSizePixel = 1
JoinJobBtn.Text = getText("BtnJoinJob")
JoinJobBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
JoinJobBtn.TextSize = 11
JoinJobBtn.Font = Enum.Font.Code
JoinJobBtn.TextXAlignment = Enum.TextXAlignment.Left
JoinJobBtn.ZIndex = 6
JoinJobBtn.Parent = InputSection

JoinJobBtn.MouseEnter:Connect(function()
    JoinJobBtn.BackgroundTransparency = 0
    TweenService:Create(JoinJobBtn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(255, 100, 0), BorderColor3 = Color3.fromRGB(255, 255, 255), TextColor3 = Color3.fromRGB(10, 10, 12)}):Play()
end)
JoinJobBtn.MouseLeave:Connect(function()
    TweenService:Create(JoinJobBtn, TweenInfo.new(0.08), {BorderColor3 = Color3.fromRGB(35, 35, 40), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
    task.wait(0.08)
    if JoinJobBtn.Parent then JoinJobBtn.BackgroundTransparency = 1 end
end)
JoinJobBtn.MouseButton1Click:Connect(function()
    local targetId = JobIdInput.Text:gsub("%s+", "")
    if #targetId > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, targetId, Players.LocalPlayer)
    end
end)

AddLanguageOption(LanguageSection, "en")
AddLanguageOption(LanguageSection, "fr")
AddLanguageOption(LanguageSection, "es")
AddLanguageOption(LanguageSection, "pt")
AddLanguageOption(LanguageSection, "it")

GuiService.ErrorMessageChanged:Connect(function()
    if savedConfig.AutoRejoin then
        task.wait(1)
        if #Players:GetPlayers() <= 1 then
            TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.RightControl then
            MainFrame.Visible = not MainFrame.Visible
        end
    end
end)

task.spawn(function()
    local function adjustCanvas(page, listLayout)
        local totalHeight = 0
        for _, child in pairs(page:GetChildren()) do
            if child:IsA("Frame") and child.Name:find("Section") then
                totalHeight = totalHeight + child.AbsoluteSize.Y + listLayout.Padding.Offset
            end
        end
        page.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 60)
    end

    local function setupCanvasAutoUpdate(page, listLayout)
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            adjustCanvas(page, listLayout)
        end)
        page.ChildAdded:Connect(function()
            adjustCanvas(page, listLayout)
        end)
        for _, sect in pairs(page:GetChildren()) do
            if sect:IsA("Frame") and sect.Name:find("Section") then
                sect:GetPropertyChangedSignal("Size"):Connect(function()
                    adjustCanvas(page, listLayout)
                end)
            end
        end
    end

    setupCanvasAutoUpdate(UniversalPage, UniversalList)
    setupCanvasAutoUpdate(GamesPage, GamesList)
    setupCanvasAutoUpdate(FavoritesPage, FavoritesList)
    setupCanvasAutoUpdate(ServerPage, ServerList)
    setupCanvasAutoUpdate(LanguagePage, LanguageList)

    adjustCanvas(UniversalPage, UniversalList)
    adjustCanvas(GamesPage, GamesList)
    adjustCanvas(FavoritesPage, FavoritesList)
    adjustCanvas(ServerPage, ServerList)
    adjustCanvas(LanguagePage, LanguageList)
end)
