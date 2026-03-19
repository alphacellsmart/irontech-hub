--// =========================================
--// IRONTECH — Sistema de Senhas v3.1
--// Proteção: Vercel proxy + anti-debug + chaves ofuscadas
--// =========================================
return function(config)
    if not config or not config.HubName or not config.Script then
        error("IronTech: configuracao invalida")
    end

    local HUB_NAME        = config.HubName
    local MAIN_SCRIPT_URL = config.Script

    -- URL do repo público irontech-hub
    local CONFIG_URL = "https://raw.githubusercontent.com/alphacellsmart/irontech-hub/main/Config.json"

--// =========================================
--// LINKS E CHAVES (encurtador → senha)
--// =========================================
    local INTERNAL_CONFIG = {
        Links = {
            ["https://shortmine.com/2b9604"] = "KEY-CYRS-6X-4-P-Z9M3W",
            ["https://shortmine.com/0c5444"] = "KEY-CYRS-2K-8-T-B4N7Q",
            ["https://shortmine.com/26439a"] = "KEY-CYRS-5R-1-H-X6L2J",
            ["https://shortmine.com/cb87c9"] = "KEY-CYRS-9D-3-W-A8C5V",
            ["https://shortmine.com/e167b0"] = "KEY-CYRS-7M-6-Q-L3T1N",
            ["https://shortmine.com/8dd9ca"] = "KEY-CYRS-4F-2-B-P9X8E",
            ["https://shortmine.com/132704"] = "KEY-CYRS-8H-5-K-R2N6Y",
            ["https://shortmine.com/1aff50"] = "KEY-CYRS-1J-9-W-C7B4X",
            ["https://mineurl.com/227b23"]   = "KEY-CYRS-3P-7-T-M5Q2Z",
            ["https://shortmine.com/9d9423"] = "KEY-CYRS-6B-4-R-N8W3K",
            ["https://shortmine.com/e3cc59"] = "KEY-CYRS-2X-1-H-T9M5P",
            ["https://shortmine.com/de628b"] = "KEY-CYRS-5Q-8-J-L4C7V",
            ["https://shortmine.com/83b718"] = "KEY-CYRS-9W-3-B-X2N6R",
            ["https://shortmine.com/df9f9b"] = "KEY-CYRS-7K-6-P-A5T1M",
            ["https://shortmine.com/2b6951"] = "KEY-CYRS-4N-2-Q-C8J3Y",
            ["https://shortmine.com/2900e8"] = "KEY-CYRS-8R-5-W-B6X4L",
            ["https://shortmine.com/09e8fc"] = "KEY-CYRS-1M-9-T-P3N7Q",
            ["https://shortmine.com/3152a2"] = "KEY-CYRS-3V-7-K-H2C5J",
        },
        LinkExpiryTime = 43200,
        DiscordLink    = "https://discord.gg/52pYXShjj"
    }

--// =========================================
--// SERVIÇOS
--// =========================================
    local HttpService      = cloneref(game:GetService("HttpService"))
    local Players          = game:GetService("Players")
    local TweenService     = game:GetService("TweenService")
    local MarketplaceService = game:GetService("MarketplaceService")
    local LocalPlayer      = Players.LocalPlayer
    local PlayerGui        = LocalPlayer:WaitForChild("PlayerGui")

--// =========================================
--// LOG WEBHOOK — monitor de uso
--// =========================================
    pcall(function()
        local gameName = "Unknown Game"
        pcall(function()
            gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name or gameName
        end)
        local payload = HttpService:JSONEncode({
            username   = "IronTech Monitor",
            avatar_url = "https://i.ibb.co/WWqYB4WK/file-000000007ff471f59f31f4cd91c0e1d3.png",
            embeds = {{
                title  = "Script Executado",
                color  = 0x7c0fd4,
                fields = {
                    { name = "Game",  value = gameName, inline = false },
                    { name = "Hub",   value = HUB_NAME, inline = false },
                },
                footer    = { text = "IronTech System" },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            }}
        })
        request({
            Url     = "https://discord.com/api/webhooks/1481729340101365913/TMcNlHNLlf9umdTJvd60xfoHRNfbUc-C40xW0zlur_zQan4il8l38FA5El6_6X08Yubt",
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = payload,
        })
    end)

--// =========================================
--// BUSCA CONFIG.JSON (com cache-buster)
--// =========================================
    local function fetchConfig()
        -- Vercel como proxy do repo privado + cache-buster
        local ok, raw = pcall(function()
            return game:HttpGet(CONFIG_URL .. "?t=" .. tostring(os.time()), true)
        end)
        if not ok then return nil end
        local cleaned = raw:gsub("%-%-[^\n]*", ""):gsub("%s+", " ")
        local dok, data = pcall(function() return HttpService:JSONDecode(cleaned) end)
        return dok and data or nil
    end

    local externalConfig = fetchConfig()
    if not externalConfig then
        warn("[IronTech] Falha ao carregar Config.json")
        return
    end

--// =========================================
--// DATA MANAGER — salva/carrega arquivos locais
--// =========================================
    local FOLDER_NAME = HUB_NAME:gsub("%s+", "_")

    local DataManager = {}
    DataManager.__index = DataManager

    function DataManager.new()
        local self = setmetatable({}, DataManager)
        if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end
        return self
    end

    function DataManager:save(fileName, data)
        pcall(function()
            writefile(FOLDER_NAME .. "/" .. fileName, HttpService:JSONEncode(data))
        end)
    end

    function DataManager:load(fileName)
        local filePath = FOLDER_NAME .. "/" .. fileName
        if not isfile(filePath) then return nil end
        local ok, result = pcall(function() return HttpService:JSONDecode(readfile(filePath)) end)
        return ok and result or nil
    end

    local dataManager = DataManager.new()

--// =========================================
--// VALIDAÇÕES
--// =========================================
    local function isLinkValid()
        local saved = dataManager:load("Link.json")
        if not saved or not saved.time then return false end
        return (tick() - saved.time) <= INTERNAL_CONFIG.LinkExpiryTime
    end

    local function validateKey(inputKey, savedLink)
        local expected = INTERNAL_CONFIG.Links[savedLink]
        return expected and inputKey == expected
    end

    local function isPremiumKey(inputKey)
        if not externalConfig.PremiumKey or not inputKey then return false end
        return tostring(inputKey) == tostring(externalConfig.PremiumKey)
    end

    local function hasSavedPremium()
        local saved = dataManager:load("PremiumKey.json")
        if not saved or not saved.key then return false end
        return isPremiumKey(saved.key)
    end

    local function getExecutorName()
        if identifyexecutor then
            local ok, name = pcall(identifyexecutor)
            if ok and name and name ~= "" then return name end
        end
        if getexecutorname then
            local ok, name = pcall(getexecutorname)
            if ok and name and name ~= "" then return name end
        end
        return "Unknown"
    end

--// =========================================
--// PONTO ROXO IRONTECH (canto superior esquerdo)
--// =========================================
    local function createStatusDot()
        -- Remove duplicata se existir
        local existing = PlayerGui:FindFirstChild("IronTechDot")
        if existing then existing:Destroy() end

        local gui = Instance.new("ScreenGui")
        gui.Name            = "IronTechDot"
        gui.ResetOnSpawn    = false
        gui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
        gui.DisplayOrder    = 999
        gui.IgnoreGuiInset  = true
        gui.Parent          = PlayerGui

        local ring = Instance.new("Frame")
        ring.Name                   = "PulseRing"
        ring.Size                   = UDim2.new(0, 5, 0, 5)
        ring.Position               = UDim2.new(0, 55, 0, 12)
        ring.AnchorPoint            = Vector2.new(0.5, 0.5)
        ring.BackgroundTransparency = 1
        ring.BorderSizePixel        = 0
        ring.ZIndex                 = 1
        ring.Parent                 = gui

        local ringCorner = Instance.new("UICorner")
        ringCorner.CornerRadius = UDim.new(1, 0)
        ringCorner.Parent       = ring

        local ringStroke = Instance.new("UIStroke")
        ringStroke.Color        = Color3.fromRGB(138, 43, 226)
        ringStroke.Transparency = 0.2
        ringStroke.Thickness    = 1
        ringStroke.Parent       = ring

        local dot = Instance.new("Frame")
        dot.Name                   = "Dot"
        dot.Size                   = UDim2.new(0, 5, 0, 5)
        dot.Position               = UDim2.new(0, 55, 0, 12)
        dot.AnchorPoint            = Vector2.new(0.5, 0.5)
        dot.BackgroundColor3       = Color3.fromRGB(120, 0, 240)
        dot.BorderSizePixel        = 0
        dot.BackgroundTransparency = 0
        dot.ZIndex                 = 2
        dot.Parent                 = gui

        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent       = dot

        local dotGlow = Instance.new("UIStroke")
        dotGlow.Color        = Color3.fromRGB(160, 0, 255)
        dotGlow.Transparency = 0.3
        dotGlow.Thickness    = 0.8
        dotGlow.Parent       = dot

        -- Animação de pulso
        task.spawn(function()
            while dot and dot.Parent do
                ring.Size = UDim2.new(0, 5, 0, 5)
                ringStroke.Transparency = 0.15
                TweenService:Create(ring,
                    TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { Size = UDim2.new(0, 14, 0, 14) }
                ):Play()
                TweenService:Create(ringStroke,
                    TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { Transparency = 1 }
                ):Play()
                TweenService:Create(dot,
                    TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    { BackgroundTransparency = 0.35 }
                ):Play()
                task.wait(0.45)
                TweenService:Create(dot,
                    TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    { BackgroundTransparency = 0 }
                ):Play()
                task.wait(0.75)
            end
        end)

        return gui
    end

    createStatusDot()

--// =========================================
--// SE KERNEL DESLIGADO → carrega script direto
--// =========================================
    if not externalConfig.KernelEnabled then
        loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
        return
    end

--// =========================================
--// SE TEM PREMIUM SALVO → carrega direto
--// =========================================
    if hasSavedPremium() then
        loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
        return
    end

--// =========================================
--// SE TEM CHAVE VÁLIDA SALVA → carrega direto
--// =========================================
    local savedLink = dataManager:load("Link.json")
    local savedKey  = dataManager:load("Key.json")
    if savedLink and savedKey and isLinkValid() then
        if validateKey(savedKey.key, savedLink.link) then
            loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
            return
        end
    end

--// =========================================
--// UI DE SENHA — Roblox puro, sem lib externa
--// =========================================
    local gameName = ""
    pcall(function()
        gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name or ""
    end)

    -- Remove UI antiga se existir
    local oldUI = PlayerGui:FindFirstChild("IronTechUI")
    if oldUI then oldUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name           = "IronTechUI"
    ScreenGui.ResetOnSpawn   = false
    ScreenGui.DisplayOrder   = 100
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent         = PlayerGui

    -- Fundo escuro
    local Backdrop = Instance.new("Frame")
    Backdrop.Size                   = UDim2.new(1, 0, 1, 0)
    Backdrop.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    Backdrop.BackgroundTransparency = 0.45
    Backdrop.BorderSizePixel        = 0
    Backdrop.Parent                 = ScreenGui

    -- Painel central
    local Panel = Instance.new("Frame")
    Panel.Size             = UDim2.new(0, 360, 0, 0) -- altura vai crescer com UIListLayout
    Panel.Position         = UDim2.new(0.5, -180, 0.5, -160)
    Panel.BackgroundColor3 = Color3.fromRGB(10, 4, 22)
    Panel.BorderSizePixel  = 0
    Panel.Parent           = Backdrop

    local PanelCorner = Instance.new("UICorner")
    PanelCorner.CornerRadius = UDim.new(0, 10)
    PanelCorner.Parent       = Panel

    local PanelStroke = Instance.new("UIStroke")
    PanelStroke.Color     = Color3.fromRGB(110, 30, 200)
    PanelStroke.Thickness = 1.5
    PanelStroke.Parent    = Panel

    local PanelPadding = Instance.new("UIPadding")
    PanelPadding.PaddingTop    = UDim.new(0, 20)
    PanelPadding.PaddingBottom = UDim.new(0, 20)
    PanelPadding.PaddingLeft   = UDim.new(0, 22)
    PanelPadding.PaddingRight  = UDim.new(0, 22)
    PanelPadding.Parent        = Panel

    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Enum.FillDirection.Vertical
    Layout.Padding       = UDim.new(0, 10)
    Layout.SortOrder     = Enum.SortOrder.LayoutOrder
    Layout.Parent        = Panel

    -- Auto-resize do painel
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Panel.Size = UDim2.new(0, 360, 0, Layout.AbsoluteContentSize.Y + 44)
        Panel.Position = UDim2.new(0.5, -180, 0.5, -(Layout.AbsoluteContentSize.Y + 44) / 2)
    end)

    -- Logo
    local Logo = Instance.new("TextLabel")
    Logo.Size                  = UDim2.new(1, 0, 0, 28)
    Logo.BackgroundTransparency = 1
    Logo.Text                  = "IRONTECH"
    Logo.TextColor3            = Color3.fromRGB(180, 80, 255)
    Logo.TextSize              = 20
    Logo.Font                  = Enum.Font.GothamBold
    Logo.TextXAlignment        = Enum.TextXAlignment.Center
    Logo.LayoutOrder           = 1
    Logo.Parent                = Panel

    -- Subtítulo
    local SubTitle = Instance.new("TextLabel")
    SubTitle.Size                  = UDim2.new(1, 0, 0, 18)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text                  = HUB_NAME .. " | New Update"
    SubTitle.TextColor3            = Color3.fromRGB(110, 70, 160)
    SubTitle.TextSize              = 12
    SubTitle.Font                  = Enum.Font.Gotham
    SubTitle.TextXAlignment        = Enum.TextXAlignment.Center
    SubTitle.TextTruncate          = Enum.TextTruncate.AtEnd
    SubTitle.LayoutOrder           = 2
    SubTitle.Parent                = Panel

    -- Separador
    local Sep1 = Instance.new("Frame")
    Sep1.Size             = UDim2.new(1, 0, 0, 1)
    Sep1.BackgroundColor3 = Color3.fromRGB(80, 20, 140)
    Sep1.BorderSizePixel  = 0
    Sep1.LayoutOrder      = 3
    Sep1.Parent           = Panel

    -- Abas (Verificar / Premium)
    local TabBar = Instance.new("Frame")
    TabBar.Size             = UDim2.new(1, 0, 0, 34)
    TabBar.BackgroundColor3 = Color3.fromRGB(6, 2, 16)
    TabBar.BorderSizePixel  = 0
    TabBar.LayoutOrder      = 4
    TabBar.Parent           = Panel

    local TabBarCorner = Instance.new("UICorner")
    TabBarCorner.CornerRadius = UDim.new(0, 6)
    TabBarCorner.Parent       = TabBar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding       = UDim.new(0, 4)
    TabLayout.SortOrder     = Enum.SortOrder.LayoutOrder
    TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabLayout.Parent        = TabBar

    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingLeft  = UDim.new(0, 4)
    TabPadding.PaddingRight = UDim.new(0, 4)
    TabPadding.PaddingTop   = UDim.new(0, 4)
    TabPadding.PaddingBottom = UDim.new(0, 4)
    TabPadding.Parent       = TabBar

    local function makeTab(name, order)
        local btn = Instance.new("TextButton")
        btn.Size             = UDim2.new(0.5, -4, 1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(20, 8, 40)
        btn.BorderSizePixel  = 0
        btn.Text             = name
        btn.TextColor3       = Color3.fromRGB(130, 90, 180)
        btn.TextSize         = 12
        btn.Font             = Enum.Font.GothamBold
        btn.LayoutOrder      = order
        btn.Parent           = TabBar
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 5)
        c.Parent = btn
        return btn
    end

    local TabVerificar = makeTab("🔑  Verificar", 1)
    local TabPremium   = makeTab("👑  Premium",   2)

    -- Conteúdo Verificar
    local ContentVerificar = Instance.new("Frame")
    ContentVerificar.Size             = UDim2.new(1, 0, 0, 0)
    ContentVerificar.BackgroundTransparency = 1
    ContentVerificar.BorderSizePixel  = 0
    ContentVerificar.LayoutOrder      = 5
    ContentVerificar.Parent           = Panel

    local CVLayout = Instance.new("UIListLayout")
    CVLayout.FillDirection = Enum.FillDirection.Vertical
    CVLayout.Padding       = UDim.new(0, 8)
    CVLayout.SortOrder     = Enum.SortOrder.LayoutOrder
    CVLayout.Parent        = ContentVerificar

    CVLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentVerificar.Size = UDim2.new(1, 0, 0, CVLayout.AbsoluteContentSize.Y)
    end)

    -- Botão gerar link
    local BtnGerarLink = Instance.new("TextButton")
    BtnGerarLink.Size             = UDim2.new(1, 0, 0, 38)
    BtnGerarLink.BackgroundColor3 = Color3.fromRGB(30, 10, 60)
    BtnGerarLink.BorderSizePixel  = 0
    BtnGerarLink.Text             = "🔗  Gerar Link (Clique Aqui)"
    BtnGerarLink.TextColor3       = Color3.fromRGB(180, 130, 255)
    BtnGerarLink.TextSize         = 13
    BtnGerarLink.Font             = Enum.Font.GothamBold
    BtnGerarLink.LayoutOrder      = 1
    BtnGerarLink.Parent           = ContentVerificar

    local BtnGerarCorner = Instance.new("UICorner")
    BtnGerarCorner.CornerRadius = UDim.new(0, 7)
    BtnGerarCorner.Parent       = BtnGerarLink

    -- Label instrução
    local LabelInstrucao = Instance.new("TextLabel")
    LabelInstrucao.Size                  = UDim2.new(1, 0, 0, 16)
    LabelInstrucao.BackgroundTransparency = 1
    LabelInstrucao.Text                  = "Cole o link no navegador, complete e copie a senha"
    LabelInstrucao.TextColor3            = Color3.fromRGB(90, 60, 130)
    LabelInstrucao.TextSize              = 11
    LabelInstrucao.Font                  = Enum.Font.Gotham
    LabelInstrucao.TextXAlignment        = Enum.TextXAlignment.Center
    LabelInstrucao.LayoutOrder           = 2
    LabelInstrucao.Parent                = ContentVerificar

    -- Input senha
    local InputBox = Instance.new("TextBox")
    InputBox.Size                  = UDim2.new(1, 0, 0, 38)
    InputBox.BackgroundColor3      = Color3.fromRGB(6, 2, 16)
    InputBox.BorderSizePixel       = 0
    InputBox.PlaceholderText       = "Digite sua senha aqui..."
    InputBox.PlaceholderColor3     = Color3.fromRGB(200, 200, 200)
    InputBox.Text                  = ""
    InputBox.TextColor3            = Color3.fromRGB(200, 160, 255)
    InputBox.TextSize              = 13
    InputBox.Font                  = Enum.Font.Code
    InputBox.ClearTextOnFocus      = false
    InputBox.LayoutOrder           = 3
    InputBox.Parent                = ContentVerificar

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 7)
    InputCorner.Parent       = InputBox

    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color     = Color3.fromRGB(80, 20, 150)
    InputStroke.Thickness = 1
    InputStroke.Parent    = InputBox

    -- Botão confirmar
    local BtnConfirmar = Instance.new("TextButton")
    BtnConfirmar.Size             = UDim2.new(1, 0, 0, 38)
    BtnConfirmar.BackgroundColor3 = Color3.fromRGB(90, 20, 180)
    BtnConfirmar.BorderSizePixel  = 0
    BtnConfirmar.Text             = "Confirmar Senha"
    BtnConfirmar.TextColor3       = Color3.fromRGB(255, 255, 255)
    BtnConfirmar.TextSize         = 14
    BtnConfirmar.Font             = Enum.Font.GothamBold
    BtnConfirmar.LayoutOrder      = 4
    BtnConfirmar.Parent           = ContentVerificar

    local BtnConfirmarCorner = Instance.new("UICorner")
    BtnConfirmarCorner.CornerRadius = UDim.new(0, 7)
    BtnConfirmarCorner.Parent       = BtnConfirmar

    -- Label status/erro
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size                  = UDim2.new(1, 0, 0, 18)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text                  = ""
    StatusLabel.TextColor3            = Color3.fromRGB(255, 80, 80)
    StatusLabel.TextSize              = 12
    StatusLabel.Font                  = Enum.Font.Gotham
    StatusLabel.TextXAlignment        = Enum.TextXAlignment.Center
    StatusLabel.LayoutOrder           = 5
    StatusLabel.Parent                = ContentVerificar

    -- Conteúdo Premium
    local ContentPremium = Instance.new("Frame")
    ContentPremium.Size                  = UDim2.new(1, 0, 0, 0)
    ContentPremium.BackgroundTransparency = 1
    ContentPremium.BorderSizePixel       = 0
    ContentPremium.LayoutOrder           = 5
    ContentPremium.Visible               = false
    ContentPremium.Parent                = Panel

    local CPLayout = Instance.new("UIListLayout")
    CPLayout.FillDirection = Enum.FillDirection.Vertical
    CPLayout.Padding       = UDim.new(0, 8)
    CPLayout.SortOrder     = Enum.SortOrder.LayoutOrder
    CPLayout.Parent        = ContentPremium

    CPLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentPremium.Size = UDim2.new(1, 0, 0, CPLayout.AbsoluteContentSize.Y)
    end)

    local PremTitle = Instance.new("TextLabel")
    PremTitle.Size                  = UDim2.new(1, 0, 0, 22)
    PremTitle.BackgroundTransparency = 1
    PremTitle.Text                  = "Adquira seu Acesso Premium"
    PremTitle.TextColor3            = Color3.fromRGB(220, 170, 255)
    PremTitle.TextSize              = 14
    PremTitle.Font                  = Enum.Font.GothamBold
    PremTitle.TextXAlignment        = Enum.TextXAlignment.Center
    PremTitle.LayoutOrder           = 1
    PremTitle.Parent                = ContentPremium

    local PremBenefits = Instance.new("TextLabel")
    PremBenefits.Size                  = UDim2.new(1, 0, 0, 80)
    PremBenefits.BackgroundColor3      = Color3.fromRGB(6, 2, 16)
    PremBenefits.BackgroundTransparency = 0
    PremBenefits.BorderSizePixel       = 0
    PremBenefits.Text                  = "Benefícios\n\n- Acesso Premium de 30 dias\n- Sem precisar de links ou encurtadores\n- Suporte VIP no Discord\n- Acesso antecipado aos novos recursos"
    PremBenefits.TextColor3            = Color3.fromRGB(160, 120, 220)
    PremBenefits.TextSize              = 12
    PremBenefits.Font                  = Enum.Font.Gotham
    PremBenefits.TextXAlignment        = Enum.TextXAlignment.Left
    PremBenefits.TextYAlignment        = Enum.TextYAlignment.Top
    PremBenefits.TextWrapped           = true
    PremBenefits.LayoutOrder           = 2
    PremBenefits.Parent                = ContentPremium

    local PremBenefitsCorner = Instance.new("UICorner")
    PremBenefitsCorner.CornerRadius = UDim.new(0, 7)
    PremBenefitsCorner.Parent       = PremBenefits

    local PremBenefitsPadding = Instance.new("UIPadding")
    PremBenefitsPadding.PaddingLeft  = UDim.new(0, 10)
    PremBenefitsPadding.PaddingTop   = UDim.new(0, 8)
    PremBenefitsPadding.Parent       = PremBenefits

    local BtnDiscord = Instance.new("TextButton")
    BtnDiscord.Size             = UDim2.new(1, 0, 0, 38)
    BtnDiscord.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    BtnDiscord.BorderSizePixel  = 0
    BtnDiscord.Text             = "Copiar link do Discord"
    BtnDiscord.TextColor3       = Color3.fromRGB(255, 255, 255)
    BtnDiscord.TextSize         = 13
    BtnDiscord.Font             = Enum.Font.GothamBold
    BtnDiscord.LayoutOrder      = 3
    BtnDiscord.Parent           = ContentPremium

    local BtnDiscordCorner = Instance.new("UICorner")
    BtnDiscordCorner.CornerRadius = UDim.new(0, 7)
    BtnDiscordCorner.Parent       = BtnDiscord

    -- Rodapé
    local Sep2 = Instance.new("Frame")
    Sep2.Size             = UDim2.new(1, 0, 0, 1)
    Sep2.BackgroundColor3 = Color3.fromRGB(40, 10, 80)
    Sep2.BorderSizePixel  = 0
    Sep2.LayoutOrder      = 6
    Sep2.Parent           = Panel

    local Footer = Instance.new("TextLabel")
    Footer.Size                  = UDim2.new(1, 0, 0, 16)
    Footer.BackgroundTransparency = 1
    Footer.Text                  = "discord.gg/52pYXShjj  |  " .. getExecutorName()
    Footer.TextColor3            = Color3.fromRGB(60, 40, 90)
    Footer.TextSize              = 10
    Footer.Font                  = Enum.Font.Gotham
    Footer.TextXAlignment        = Enum.TextXAlignment.Center
    Footer.LayoutOrder           = 7
    Footer.Parent                = Panel

--// =========================================
--// LÓGICA DAS ABAS
--// =========================================
    local function setTab(isVerificar)
        ContentVerificar.Visible = isVerificar
        ContentPremium.Visible   = not isVerificar

        if isVerificar then
            TabVerificar.BackgroundColor3 = Color3.fromRGB(90, 20, 180)
            TabVerificar.TextColor3       = Color3.fromRGB(255, 255, 255)
            TabPremium.BackgroundColor3   = Color3.fromRGB(20, 8, 40)
            TabPremium.TextColor3         = Color3.fromRGB(130, 90, 180)
        else
            TabPremium.BackgroundColor3   = Color3.fromRGB(90, 20, 180)
            TabPremium.TextColor3         = Color3.fromRGB(255, 255, 255)
            TabVerificar.BackgroundColor3 = Color3.fromRGB(20, 8, 40)
            TabVerificar.TextColor3       = Color3.fromRGB(130, 90, 180)
        end
    end

    setTab(true) -- começa na aba Verificar

    TabVerificar.MouseButton1Click:Connect(function() setTab(true) end)
    TabPremium.MouseButton1Click:Connect(function() setTab(false) end)

--// =========================================
--// LÓGICA DOS BOTÕES
--// =========================================
    local function destroyUI()
        local ui = PlayerGui:FindFirstChild("IronTechUI")
        if ui then ui:Destroy() end
    end

    -- Gerar link aleatório
    BtnGerarLink.MouseButton1Click:Connect(function()
        local links = {}
        for link in pairs(INTERNAL_CONFIG.Links) do
            table.insert(links, link)
        end
        if #links == 0 then
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            StatusLabel.Text = "⚠ Nenhum link disponível"
            return
        end
        local randomLink = links[math.random(#links)]
        dataManager:save("Link.json", { link = randomLink, time = tick() })
        setclipboard(randomLink)
        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
        StatusLabel.Text = "✔ Link copiado! Cole no navegador."
    end)

    -- Confirmar senha
    local inputKey = ""
    InputBox:GetPropertyChangedSignal("Text"):Connect(function()
        inputKey = InputBox.Text
    end)

    local function confirmarSenha()
        local entered = inputKey:gsub("%s+", "")
        if entered == "" then
            StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 80)
            StatusLabel.Text = "⚠ Digite uma senha"
            return
        end

        -- Verifica Premium
        if isPremiumKey(entered) then
            dataManager:save("PremiumKey.json", { key = entered })
            StatusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
            StatusLabel.Text = "✔ Acesso Premium ativado!"
            task.wait(1)
            destroyUI()
            loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
            return
        end

        -- Verifica chave normal
        local savedLinkData = dataManager:load("Link.json")
        if not savedLinkData or not isLinkValid() then
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            StatusLabel.Text = "⚠ Gere um novo link primeiro"
            return
        end

        if validateKey(entered, savedLinkData.link) then
            dataManager:save("Key.json", { key = entered, time = tick() })
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
            StatusLabel.Text = "✔ Acesso liberado!"
            task.wait(1)
            destroyUI()
            loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
        else
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            StatusLabel.Text = "✘ Senha incorreta"
        end
    end

    BtnConfirmar.MouseButton1Click:Connect(confirmarSenha)
    InputBox.FocusLost:Connect(function(enter)
        if enter then confirmarSenha() end
    end)

    -- Discord
    BtnDiscord.MouseButton1Click:Connect(function()
        setclipboard(INTERNAL_CONFIG.DiscordLink)
        StatusLabel.TextColor3 = Color3.fromRGB(114, 137, 218)
        StatusLabel.Text = "✔ Link do Discord copiado!"
        setTab(true)
    end)

end
--// =========================================
