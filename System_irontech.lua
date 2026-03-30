--// =========================================
--//   IronTech System v1.0
--//   github.com/alphacellsmart/irontech-hub
--// =========================================
return function(config)
    if not config or not config.HubName or not config.Script then
        error("[IronTech] Config inválida: HubName ou Script não definido")
    end

    local HUB_NAME        = config.HubName
    local MAIN_SCRIPT_URL = config.Script

    -- URLs do SEU repositório público
    local CONFIG_URL      = "https://raw.githubusercontent.com/alphacellsmart/irontech-hub/main/Config.json"
    local LIB_CONFIG_URL  = "https://raw.githubusercontent.com/alphacellsmart/irontech-hub/main/Lib/Config.json"
    local LIB_SRC_URL     = "https://raw.githubusercontent.com/alphacellsmart/irontech-hub/main/Lib/Src.lua"

--// =========================================
--//   CONFIG INTERNA — Links encurtados + Keys
--// =========================================
    local INTERNAL_CONFIG = {
        Links = {
            ["https://mineurl.com/1aff50"] = "KEY-CYRS-1J-9-W-C7B4X",
            ["https://mineurl.com/132704"] = "KEY-CYRS-8H-5-K-R2N6Y",
            ["https://mineurl.com/8dd9ca"] = "KEY-CYRS-4F-2-B-P9X8E",
            ["https://mineurl.com/e3cc59"] = "KEY-CYRS-2X-1-H-T9M5P",
            ["https://mineurl.com/9d9423"] = "KEY-CYRS-6B-4-R-N8W3K",
            ["https://mineurl.com/227b23"] = "KEY-CYRS-3P-7-T-M5Q2Z",
            ["https://mineurl.com/e167b0"] = "KEY-CYRS-7M-6-Q-L3T1N",
            ["https://mineurl.com/2b9604"] = "KEY-CYRS-6X-4-P-Z9M3W",
        },
        LinkExpiryTime = 43200, -- 12 horas em segundos
        DiscordLink    = "https://discord.gg/52pYXShjj",
    }

--// =========================================
    local HttpService = game:GetService("HttpService")
    local Players     = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Ponto roxo IronTech (watermark)
    local function spawnIronTechDot()
        pcall(function()
            local sg = Instance.new("ScreenGui")
            sg.Name             = "IronTechDot"
            sg.ResetOnSpawn     = false
            sg.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
            sg.IgnoreGuiInset   = true
            sg.Parent           = game:GetService("CoreGui")

            local dot = Instance.new("Frame")
            dot.Size            = UDim2.new(0, 8, 0, 8)
            dot.Position        = UDim2.new(0, 10, 0, 10)
            dot.BackgroundColor3 = Color3.fromRGB(120, 0, 240)
            dot.BorderSizePixel = 0
            dot.Parent          = sg

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent       = dot

            -- Pulso sutil
            task.spawn(function()
                while dot and dot.Parent do
                    local t = tick()
                    local alpha = (math.sin(t * 2) + 1) / 2
                    dot.BackgroundTransparency = 0.2 + alpha * 0.4
                    task.wait(0.05)
                end
            end)
        end)
    end

    spawnIronTechDot()

--// =========================================
    local function fetchJSON(url)
        local ok, raw = pcall(function() return game:HttpGet(url, true) end)
        if not ok or not raw then return nil end
        local dok, data = pcall(function() return HttpService:JSONDecode(raw) end)
        return dok and data or nil
    end

    local externalConfig = fetchJSON(CONFIG_URL)
    if not externalConfig then
        warn("[IronTech] Falha ao carregar Config.json")
        return
    end

    -- KernelEnabled = false → executa direto sem senha
    if not externalConfig.KernelEnabled then
        loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
        return
    end

--// =========================================
--//   GERENCIADOR DE DADOS LOCAL
--// =========================================
    local FOLDER_NAME = "IronTech_" .. HUB_NAME:gsub("%s+", "_")

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
--//   VALIDAÇÃO DE CHAVES
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

    local function isPremium()
        -- Checa lista de premium do Config.json externo
        if externalConfig.PremiumUsers then
            for _, user in ipairs(externalConfig.PremiumUsers) do
                if tostring(user):lower() == tostring(LocalPlayer.Name):lower() then
                    return true
                end
            end
        end
        -- Checa PremiumKey digitada salva localmente
        local savedPremium = dataManager:load("Premium.json")
        if savedPremium and savedPremium.key and externalConfig.PremiumKeys then
            for _, k in ipairs(externalConfig.PremiumKeys) do
                if savedPremium.key == k then return true end
            end
        end
        return false
    end

    -- Premium: executa direto
    if isPremium() then
        loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
        return
    end

    -- Chave normal salva e ainda válida: executa direto
    local savedLink = dataManager:load("Link.json")
    local savedKey  = dataManager:load("Key.json")
    if savedLink and savedKey and isLinkValid() then
        if validateKey(savedKey.key, savedLink.link) then
            loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
            return
        end
    end

--// =========================================
--//   CARREGA LIB CONFIG
--// =========================================
    local libCfg = fetchJSON(LIB_CONFIG_URL) or {}

    local CFG_ICON  = libCfg["OpenIcon"]    or "rbxassetid://112738695202091"
    local CFG_THEME = libCfg["ThemeSelect"] or "darker"
    local CFG_SND   = libCfg["SoundId"]     or ""
    local CFG_VOL   = libCfg["SoundVolume"] or 1

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
--//   CARREGA UI (Src.lua do irontech-hub)
--// =========================================
    local BastardXHub = loadstring(game:HttpGet(LIB_SRC_URL))()

    local function Notify(content, delay, color)
        return BastardXHub:MakeNotify({
            Title   = "IronTech",
            Content = content or "",
            Color   = color   or Color3.fromRGB(120, 0, 240),
            Delay   = delay   or 4,
        })
    end

    local gameName = ""
    pcall(function()
        gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or ""
    end)

    local Window = BastardXHub:Window({
        Title       = HUB_NAME .. (gameName ~= "" and (" | " .. gameName) or "") .. " | " .. getExecutorName(),
        Color       = Color3.fromRGB(120, 0, 240),
        Version     = 1,
        ThemePreset = CFG_THEME,
    })

    local Float = BastardXHub:FloatBtn({
        Icon       = CFG_ICON,
        Color      = Color3.fromRGB(120, 0, 240),
        ColorDark  = Color3.fromRGB(20, 0, 40),
        Size       = 46,
        MainHolder = Window._holder,
    })
    Window:RegisterFloat(Float)

    if CFG_SND ~= "" then
        task.spawn(function()
            local s = Instance.new("Sound")
            s.SoundId            = CFG_SND
            s.Volume             = CFG_VOL
            s.RollOffMaxDistance = 1000
            s.Parent             = game:GetService("SoundService")
            if not s.IsLoaded then s.Loaded:Wait() end
            s:Play()
            game:GetService("Debris"):AddItem(s, 15)
        end)
    end

    task.delay(0.5, function()
        Notify("Sistema IronTech ativo! Verifique sua chave.", 5, Color3.fromRGB(120, 0, 240))
    end)

--// =========================================
--//   ABA VERIFICAR
--// =========================================
    local TabVerificar = Window:AddTab({ Name = "Verificar", Icon = "rbxassetid://7733965118" })
    local SecEntrada   = TabVerificar:AddSection("Pegue uma senha para continuar", true)

    SecEntrada:AddButton({
        Title    = "🔗 Gerar Link (Clique Aqui)",
        Callback = function()
            local links = {}
            for link in pairs(INTERNAL_CONFIG.Links) do
                table.insert(links, link)
            end
            if #links == 0 then
                Notify("Nenhum link disponível", 3, Color3.fromRGB(255, 80, 80))
                return
            end
            local randomLink = links[math.random(#links)]
            dataManager:save("Link.json", { link = randomLink, time = tick() })
            setclipboard(randomLink)
            Notify("Link copiado! Cole no navegador e complete para obter a senha.", 6, Color3.fromRGB(255, 200, 0))
        end,
    })

    local inputKey = ""
    SecEntrada:AddInput({
        Title    = "Digite a senha:",
        Content  = "Senha de Acesso",
        Default  = "",
        Callback = function(value)
            inputKey = value
        end,
    })

    SecEntrada:AddButton({
        Title    = "✅ Confirmar Senha",
        Callback = function()
            if inputKey == "" then
                Notify("Digite uma senha primeiro", 3, Color3.fromRGB(255, 150, 80))
                return
            end
            local savedLinkData = dataManager:load("Link.json")
            if not savedLinkData or not isLinkValid() then
                Notify("Gere um novo link para continuar", 4, Color3.fromRGB(255, 80, 80))
                return
            end
            if validateKey(inputKey, savedLinkData.link) then
                dataManager:save("Key.json", { key = inputKey, time = tick() })
                Notify("✅ Acesso liberado!", 3, Color3.fromRGB(80, 255, 150))
                task.wait(1.5)
                pcall(function() BastardXHub:Destroy() end)
                loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
            else
                Notify("❌ Senha incorreta. Tente novamente.", 4, Color3.fromRGB(255, 80, 80))
            end
        end,
    })

--// =========================================
--//   ABA PREMIUM
--// =========================================
    local TabPremium = Window:AddTab({ Name = "⭐ Premium", Icon = "rbxassetid://127843403295538" })
    local SecPremium = TabPremium:AddSection("Acesso Permanente IronTech", true)

    SecPremium:AddParagraph({
        Title   = "Benefícios do Premium",
        Content = "✅ Acesso PERMANENTE e ILIMITADO\n✅ Sem encurtadores ou links\n✅ Senha que nunca expira\n✅ Suporte VIP no Discord\n✅ Acesso antecipado a novos scripts",
    })

    local premiumInput = ""
    SecPremium:AddInput({
        Title    = "Chave Premium:",
        Content  = "Cole sua chave aqui",
        Default  = "",
        Callback = function(value)
            premiumInput = value
        end,
    })

    SecPremium:AddButton({
        Title    = "🔓 Ativar Premium",
        Callback = function()
            if premiumInput == "" then
                Notify("Digite sua chave Premium", 3, Color3.fromRGB(255, 150, 80))
                return
            end
            -- Verifica contra a lista de PremiumKeys do Config.json externo
            local valid = false
            if externalConfig.PremiumKeys then
                for _, k in ipairs(externalConfig.PremiumKeys) do
                    if premiumInput == k then valid = true; break end
                end
            end
            if valid then
                dataManager:save("Premium.json", { key = premiumInput })
                Notify("⭐ Premium ativado com sucesso!", 4, Color3.fromRGB(120, 0, 240))
                task.wait(1.5)
                pcall(function() BastardXHub:Destroy() end)
                loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
            else
                Notify("❌ Chave Premium inválida.", 4, Color3.fromRGB(255, 80, 80))
            end
        end,
    })

    SecPremium:AddButton({
        Title    = "💬 Comprar no Discord",
        Callback = function()
            setclipboard(INTERNAL_CONFIG.DiscordLink)
            Notify("Link do Discord copiado! Entre e compre seu acesso Premium.", 5, Color3.fromRGB(114, 137, 218))
        end,
    })

--// =========================================
--//   ABA CONFIG
--// =========================================
    local TabConfig  = Window:AddTab({ Name = "Config", Icon = "settings" })
    local SecTheme   = TabConfig:AddSection("Visual da Interface", true)

    local _themeList = libCfg["_themes_available"] or {
        "darker","dark","carbon","obsidian","midnight","navy","ocean","teal","slate",
        "grape","rose","crimson","bronze","forest","ash","void","aurora","ember",
        "lilac","storm","rust","pine"
    }

    SecTheme:AddDropdown({
        Title    = "Tema",
        Options  = _themeList,
        Default  = CFG_THEME,
        Multi    = false,
        Callback = function(v) Window:SetTheme(v) end,
    })

    SecTheme:AddColorPicker({
        Title    = "Cor de Destaque",
        Default  = Color3.fromRGB(120, 0, 240),
        Callback = function(col) Window:SetAccentColor(col) end,
    })

    SecTheme:AddSlider({
        Title     = "Transparência",
        Min       = 0,
        Max       = 95,
        Default   = 0,
        Increment = 1,
        Callback  = function(v) Window:SetTransparency(v / 100) end,
    })

    local SecKeys = TabConfig:AddSection("Atalhos", true)
    SecKeys:AddKeybind({
        Title    = "Toggle UI",
        Default  = Enum.KeyCode.X,
        Callback = function(kc) Window:LibSettings({ ToggleKey = kc }) end,
    })
end
--// =========================================
