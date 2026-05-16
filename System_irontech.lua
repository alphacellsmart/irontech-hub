_G.ANTIENVLOGBYNEVERWON1 = 1
getgenv().ANTIENVLOGBYNEVERWON2 = 1
getgenv().ANTIENVLOGBYNEVERWON3 = 69
_G.ifucantseeanyprintthenufailedtobypassthisenvlogger = true
_G.ANTIENVLOGGERmadebyclickdetectoronneverwon = true

local a = getgenv().ANTIENVLOGBYNEVERWON2 + _G.ANTIENVLOGBYNEVERWON1

if _G.ANTIENVLOGBYNEVERWON1 and getgenv().ANTIENVLOGBYNEVERWON2 and _G.ANTIENVLOGBYNEVERWON1 == 1 and getgenv().ANTIENVLOGBYNEVERWON2 == 1 then
    if a and a ~= 1 or a ~= 3 then
        a = a + a
        if a and a ~= a and a == 4 then
        elseif a == a and a ~= 3 then        

            task.spawn(function()
                while true do
                    local b = math.random(1, 1000000)
                    getgenv().ANTIENVLOGBYNEVERWON3 = b + 1
                    getgenv().ANTIENVLOGBYNEVERWON2 = getgenv().ANTIENVLOGBYNEVERWON2 + 1
                    _G.ANTIENVLOGBYNEVERWON1 = _G.ANTIENVLOGBYNEVERWON1 + 1
                    task.wait(math.random() / 10)
                end
            end)

        end
    end
end
--// =========================================
--//   IronTech System v2.1
--//   github.com/alphacellsmart/irontech-hub
--// =========================================
return function(config)
    if not config or not config.HubName or not config.Script then
        error("[IronTech] Config inválida: HubName ou Script não definido")
    end

    local HUB_NAME        = config.HubName
    local MAIN_SCRIPT_URL = config.Script

    local CONFIG_URL     = "https://raw.githubusercontent.com/alphacellsmart/irontech-hub/main/Config.json"
    local LIB_CONFIG_URL = "https://raw.githubusercontent.com/alphacellsmart/irontech-hub/main/Lib/Config.json"
    local LIB_SRC_URL    = "https://irontech-system.vercel.app/api/load"
    local ANALYTICS_URL  = "https://irontech-system.vercel.app/api/analytics"
    local SECRET_TOKEN   = "IRNTCH_SEC_7x9kQmZ2pL4nR8wY"

--// =========================================
--//   CONFIG INTERNA
--// =========================================
    local INTERNAL_CONFIG = {
        Links = {
            ["https://suaads.com/wxtj1e"]    = "KEY-CYRS-K45P-YU98-78AB",
            ["https://suaads.com/gcefwl"]    = "KEY-CYRS-RTV4-4D4R-GGK3",
            ["https://suaads.com/ifw7t0"]    = "KEY-CYRS-VYHT-VSWV-Y7L0",
            ["https://suaurl.com/j0th05"]    = "KEY-CYRS-ENK5-HOAS-GRYC",
            ["https://shortmine.com/5bp0w2"] = "KEY-CYRS-AODV-YWI1-CKSM",
            ["https://mineurl.com/g9fw43"]   = "KEY-CYRS-HOX7-WO6Z-GHQS",
        },
        LinkExpiryTime = 43200,
        DiscordLink    = "https://discord.gg/RCkCmkTFaf",
        DiscordComprar = "https://discord.com/channels/1481726997452296326/1482141134938702069",
    }

--// =========================================
    local HttpService = game:GetService("HttpService")
    local Players     = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

--// =========================================
--//   HELPERS
--// =========================================
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

    local function getGameName()
        local ok, name = pcall(function()
            return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        end)
        return (ok and name) or "Unknown"
    end

    local function getCountry()
        local ok, locale = pcall(function() return LocalPlayer.LocaleId or "" end)
        if ok and locale and locale ~= "" then
            local localeMap = {
                ["pt-br"]="Brasil",["pt"]="Portugal",
                ["en-us"]="Estados Unidos",["en-gb"]="Reino Unido",
                ["es-es"]="Espanha",["es-mx"]="Mexico",
                ["fr-fr"]="Franca",["de-de"]="Alemanha",
                ["it-it"]="Italia",["ru-ru"]="Russia",
                ["ja-jp"]="Japao",["ko-kr"]="Coreia do Sul",
                ["zh-cn"]="China",["ar-sa"]="Arabia Saudita",
                ["tr-tr"]="Turquia",["pl-pl"]="Polonia",
                ["id-id"]="Indonesia",["th-th"]="Tailandia",
                ["vi-vn"]="Vietna",["uk-ua"]="Ucrania",
            }
            return localeMap[locale:lower()] or locale
        end
        return "Desconhecido"
    end

    local function buildTeleportScript()
        local ok, result = pcall(function()
            return string.format(
                'local Players = game:GetService("Players")\n'..
                'local TeleportService = game:GetService("TeleportService")\n\n'..
                'local player = Players.LocalPlayer\n\n'..
                'local placeId = %s\n'..
                'local jobId = "%s"\n\n'..
                'pcall(function()\n'..
                '    TeleportService:TeleportToPlaceInstance(placeId, jobId, player)\n'..
                'end)',
                tostring(game.PlaceId), tostring(game.JobId)
            )
        end)
        return ok and result or ""
    end

--// =========================================
--//   ANALYTICS v2.1 — token secreto + request() compativel
--// =========================================
    local function sendAnalytics(accessType)
        pcall(function()
            local payload = HttpService:JSONEncode({
                hubName        = HUB_NAME,
                gameName       = getGameName(),
                gameId         = tostring(game.PlaceId),
                executor       = getExecutorName(),
                player         = LocalPlayer.Name,
                userId         = tostring(LocalPlayer.UserId),
                country        = getCountry(),
                accessType     = accessType,
                teleportScript = buildTeleportScript(),
            })
            local reqData = {
                Url     = ANALYTICS_URL,
                Method  = "POST",
                Headers = {
                    ["Content-Type"]      = "application/json",
                    ["X-IronTech-Token"]  = SECRET_TOKEN,
                },
                Body = payload,
            }
            -- Tenta request() dos executors (syn, http, request) — fallback HttpPost
            if syn and syn.request then
                syn.request(reqData)
            elseif http and http.request then
                http.request(reqData)
            elseif request then
                request(reqData)
            else
                game:HttpPost(ANALYTICS_URL, payload, false, "application/json")
            end
        end)
    end

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

    if not externalConfig.KernelEnabled then
        task.spawn(function() sendAnalytics("free") end)
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
        pcall(function() writefile(FOLDER_NAME.."/"..fileName, HttpService:JSONEncode(data)) end)
    end
    function DataManager:load(fileName)
        local fp = FOLDER_NAME.."/"..fileName
        if not isfile(fp) then return nil end
        local ok, r = pcall(function() return HttpService:JSONDecode(readfile(fp)) end)
        return ok and r or nil
    end

    local dataManager = DataManager.new()

--// =========================================
--//   VALIDAÇÃO
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
        if externalConfig.PremiumUsers then
            for _, user in ipairs(externalConfig.PremiumUsers) do
                if tostring(user):lower() == tostring(LocalPlayer.Name):lower() then return true end
            end
        end
        local sp = dataManager:load("Premium.json")
        if sp and sp.key and externalConfig.PremiumKeys then
            for _, k in ipairs(externalConfig.PremiumKeys) do
                if sp.key == k then return true end
            end
        end
        return false
    end

    if isPremium() then
        task.spawn(function() sendAnalytics("premium") end)
        loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
        return
    end

    local savedLink = dataManager:load("Link.json")
    local savedKey  = dataManager:load("Key.json")
    if savedLink and savedKey and isLinkValid() then
        if validateKey(savedKey.key, savedLink.link) then
            task.spawn(function() sendAnalytics("key") end)
            loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
            return
        end
    end

--// =========================================
--//   CARREGA LIB CONFIG
--// =========================================
    local libCfg    = fetchJSON(LIB_CONFIG_URL) or {}
    local CFG_THEME = libCfg["ThemeSelect"] or "darker"
    local CFG_SND   = libCfg["SoundId"]     or ""
    local CFG_VOL   = libCfg["SoundVolume"] or 1

--// =========================================
--//   CARREGA UI
--// =========================================
    local BastardXHub = loadstring(game:HttpGet(LIB_SRC_URL))()

    local function Notify(content, delay, color)
        return BastardXHub:MakeNotify({
            Title = "IronTech", Content = content or "",
            Color = color or Color3.fromRGB(120,0,240), Delay = delay or 4,
        })
    end

    local gameName = getGameName()
    local Window = BastardXHub:Window({
        Title       = HUB_NAME..(gameName ~= "" and (" | "..gameName) or "").." | "..getExecutorName(),
        Color       = Color3.fromRGB(120, 0, 240),
        Version     = 1,
        ThemePreset = CFG_THEME,
    })

    if CFG_SND ~= "" then
        task.spawn(function()
            local s = Instance.new("Sound")
            s.SoundId = CFG_SND; s.Volume = CFG_VOL
            s.RollOffMaxDistance = 1000
            s.Parent = game:GetService("SoundService")
            if not s.IsLoaded then s.Loaded:Wait() end
            s:Play()
            game:GetService("Debris"):AddItem(s, 15)
        end)
    end

    task.delay(0.5, function()
        Notify("Sistema IronTech ativo! Verifique sua chave.", 5, Color3.fromRGB(120,0,240))
    end)

--// =========================================
--//   ABA VERIFICAR
--// =========================================
    local TabVerificar = Window:AddTab({ Name = "Verificar", Icon = "rbxassetid://7733965118" })
    local SecEntrada   = TabVerificar:AddSection("Pegue uma senha para continuar", true)

    SecEntrada:AddButton({
        Title    = "Gerar Link (Clique Aqui)",
        Callback = function()
            local links = {}
            for link in pairs(INTERNAL_CONFIG.Links) do table.insert(links, link) end
            if #links == 0 then Notify("Nenhum link disponivel", 3, Color3.fromRGB(255,80,80)); return end
            local randomLink = links[math.random(#links)]
            dataManager:save("Link.json", { link = randomLink, time = tick() })
            setclipboard(randomLink)
            Notify("Link copiado! Cole no navegador e complete para obter a senha.", 6, Color3.fromRGB(255,200,0))
        end,
    })

    local inputKey = ""
    SecEntrada:AddInput({
        Title = "Digite a senha:", Content = "Senha de Acesso", Default = "",
        Callback = function(value) inputKey = value end,
    })

    SecEntrada:AddButton({
        Title    = "Confirmar Senha",
        Callback = function()
            if inputKey == "" then Notify("Digite uma senha primeiro", 3, Color3.fromRGB(255,150,80)); return end
            local savedLinkData = dataManager:load("Link.json")
            if not savedLinkData or not isLinkValid() then
                Notify("Gere um novo link para continuar", 4, Color3.fromRGB(255,80,80)); return
            end
            if validateKey(inputKey, savedLinkData.link) then
                dataManager:save("Key.json", { key = inputKey, time = tick() })
                Notify("Acesso liberado!", 3, Color3.fromRGB(80,255,150))
                task.spawn(function() sendAnalytics("key") end)
                task.wait(1.5)
                pcall(function() BastardXHub:Destroy() end)
                loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
            else
                Notify("Senha incorreta. Tente novamente.", 4, Color3.fromRGB(255,80,80))
            end
        end,
    })

--// =========================================
--//   ABA PREMIUM
--// =========================================
    local TabPremium = Window:AddTab({ Name = "Premium", Icon = "rbxassetid://127843403295538" })
    local SecPremium = TabPremium:AddSection("Acesso Permanente IronTech", true)

    SecPremium:AddParagraph({
        Title   = "Beneficios do Premium",
        Content = "Acesso PERMANENTE e ILIMITADO\nSem encurtadores ou links\nSenha que nunca expira\nSuporte VIP no Discord\nAcesso antecipado a novos scripts",
    })

    local premiumInput = ""
    SecPremium:AddInput({
        Title = "Chave Premium:", Content = "Cole sua chave aqui", Default = "",
        Callback = function(value) premiumInput = value end,
    })

    SecPremium:AddButton({
        Title    = "Ativar Premium",
        Callback = function()
            if premiumInput == "" then Notify("Digite sua chave Premium", 3, Color3.fromRGB(255,150,80)); return end
            local valid = false
            if externalConfig.PremiumKeys then
                for _, k in ipairs(externalConfig.PremiumKeys) do
                    if premiumInput == k then valid = true; break end
                end
            end
            if valid then
                dataManager:save("Premium.json", { key = premiumInput })
                Notify("Premium ativado com sucesso!", 4, Color3.fromRGB(120,0,240))
                task.spawn(function() sendAnalytics("premium") end)
                task.wait(1.5)
                pcall(function() BastardXHub:Destroy() end)
                loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
            else
                Notify("Chave Premium invalida.", 4, Color3.fromRGB(255,80,80))
            end
        end,
    })

    SecPremium:AddButton({
        Title    = "Comprar no Discord",
        Callback = function()
            setclipboard(INTERNAL_CONFIG.DiscordComprar)
            Notify("Link copiado! Entre no Discord e va ao canal de compras.", 5, Color3.fromRGB(114,137,218))
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
        Title = "Tema", Options = _themeList, Default = CFG_THEME, Multi = false,
        Callback = function(v) Window:SetTheme(v) end,
    })
    SecTheme:AddColorPicker({
        Title = "Cor de Destaque", Default = Color3.fromRGB(120,0,240),
        Callback = function(col) Window:SetAccentColor(col) end,
    })
    SecTheme:AddSlider({
        Title = "Transparencia", Min = 0, Max = 95, Default = 0, Increment = 1,
        Callback = function(v) Window:SetTransparency(v/100) end,
    })

    local SecKeys = TabConfig:AddSection("Atalhos", true)
    SecKeys:AddKeybind({
        Title = "Toggle UI", Default = Enum.KeyCode.X,
        Callback = function(kc) Window:LibSettings({ ToggleKey = kc }) end,
    })
end
--// =========================================
