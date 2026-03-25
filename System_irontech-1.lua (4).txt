--// IronTech System v4.0
local _=string local __=table local ___=math
local function _x(s,k) local r="" for i=1,#s do r=r..string.char(string.byte(s,i)~k) end return r end

local _cfg={_u="https://raw.githubusercontent.com/alphacellsmart/irontech-hub/main/Config.json"}
local _lib={_u="https://raw.githubusercontent.com/alphacellsmart/irontech-hub/main/Lib/Src.lua"}
local _lcfg={_u="https://raw.githubusercontent.com/alphacellsmart/irontech-hub/main/Lib/Config.json"}

return function(_config)
    if not _config or not _config.HubName or not _config.Script then error("err:cfg") end

    local _hn = _config.HubName
    local _ms = _config.Script

    local _hs  = cloneref(game:GetService("HttpService"))
    local _pl  = game:GetService("Players")
    local _cg  = game:GetService("CoreGui")
    local _ts  = game:GetService("TweenService")
    local _mps = game:GetService("MarketplaceService")
    local _lp  = _pl.LocalPlayer
    local _pg  = _lp:WaitForChild("PlayerGui")

    -- Strings internas particionadas
    local _s = {
        lj = "Li"  .."nk"  ..".js"  .."on",
        kj = "Ke"  .."y."  .."js"   .."on",
        pj = "Pre" .."miu" .."mKe"  .."y.json",
        dc = "htt" .."ps:" .."//di" .."scord.gg/52pYXShjj",
    }

    -- Links montados em runtime via concat de partes
    local _p = "KEY" .. "-" .. "CYRS" .. "-"
    local _ld = {
        {"https://sho" .."rtmine.com/" .."2b9604", _p.."6X-4-P-Z9M3W"},
        {"https://sho" .."rtmine.com/" .."0c5444", _p.."2K-8-T-B4N7Q"},
        {"https://sho" .."rtmine.com/" .."26439a", _p.."5R-1-H-X6L2J"},
        {"https://sho" .."rtmine.com/" .."cb87c9", _p.."9D-3-W-A8C5V"},
        {"https://sho" .."rtmine.com/" .."e167b0", _p.."7M-6-Q-L3T1N"},
        {"https://sho" .."rtmine.com/" .."8dd9ca", _p.."4F-2-B-P9X8E"},
        {"https://sho" .."rtmine.com/" .."132704", _p.."8H-5-K-R2N6Y"},
        {"https://sho" .."rtmine.com/" .."1aff50", _p.."1J-9-W-C7B4X"},
        {"https://min" .."eurl.com/"   .."227b23", _p.."3P-7-T-M5Q2Z"},
        {"https://sho" .."rtmine.com/" .."9d9423", _p.."6B-4-R-N8W3K"},
        {"https://sho" .."rtmine.com/" .."e3cc59", _p.."2X-1-H-T9M5P"},
        {"https://sho" .."rtmine.com/" .."de628b", _p.."5Q-8-J-L4C7V"},
        {"https://sho" .."rtmine.com/" .."83b718", _p.."9W-3-B-X2N6R"},
        {"https://sho" .."rtmine.com/" .."df9f9b", _p.."7K-6-P-A5T1M"},
        {"https://sho" .."rtmine.com/" .."2b6951", _p.."4N-2-Q-C8J3Y"},
        {"https://sho" .."rtmine.com/" .."2900e8", _p.."8R-5-W-B6X4L"},
        {"https://sho" .."rtmine.com/" .."09e8fc", _p.."1M-9-T-P3N7Q"},
        {"https://sho" .."rtmine.com/" .."3152a2", _p.."3V-7-K-H2C5J"},
    }
    local _lk = {}
    for _,v in ipairs(_ld) do _lk[v[1]]=v[2] end

    local _ic = { Links=_lk, LinkExpiryTime=43200, DiscordLink=_s.dc }

--// WEBHOOK LOG
    pcall(function()
        local _gn="Unknown"
        pcall(function() _gn=_mps:GetProductInfo(game.PlaceId).Name or _gn end)
        local _py=_hs:JSONEncode({
            username="IronTech Monitor",
            avatar_url="https://i.ibb.co/WWqYB4WK/file-000000007ff471f59f31f4cd91c0e1d3.png",
            embeds={{
                title="Script Executado",color=0x7c0fd4,
                fields={{name="Game",value=_gn,inline=false},{name="Hub",value=_hn,inline=false}},
                footer={text="IronTech v4.0"},
                timestamp=os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        })
        request({
            Url="https://discord.com/api/webhooks/1481729340101365913/TMcNlHNLlf9umdTJvd60xfoHRNfbUc-C40xW0zlur_zQan4il8l38FA5El6_6X08Yubt",
            Method="POST",Headers={["Content-Type"]="application/json"},Body=_py
        })
    end)

--// FETCH CONFIG
    local function _fc()
        local ok,raw=pcall(function() return game:HttpGet(_cfg._u.."?t="..tostring(os.time()),true) end)
        if not ok then return nil end
        local cl=raw:gsub("%-%-[^\n]*",""):gsub("%s+"," ")
        local dok,data=pcall(function() return _hs:JSONDecode(cl) end)
        return dok and data or nil
    end

    local _ec=_fc()
    if not _ec then return end

--// DATA MANAGER
    local _fn=_hn:gsub("%s+","_")
    local _dm={}
    _dm.__index=_dm
    function _dm.new()
        local self=setmetatable({},_dm)
        if not isfolder(_fn) then makefolder(_fn) end
        return self
    end
    function _dm:save(f,d) pcall(function() writefile(_fn.."/"..f,_hs:JSONEncode(d)) end) end
    function _dm:load(f)
        local fp=_fn.."/"..f
        if not isfile(fp) then return nil end
        local ok,r=pcall(function() return _hs:JSONDecode(readfile(fp)) end)
        return ok and r or nil
    end
    local _mgr=_dm.new()

--// VALIDAÇÕES
    local function _ilv()
        local s=_mgr:load(_s.lj)
        if not s or not s.time then return false end
        return (tick()-s.time)<=_ic.LinkExpiryTime
    end
    local function _vk(k,l) local e=_ic.Links[l] return e and k==e end
    local function _ipk(k)
        if not _ec.PremiumKey or not k then return false end
        return tostring(k)==tostring(_ec.PremiumKey)
    end
    local function _hsp()
        local s=_mgr:load(_s.pj)
        if not s or not s.key then return false end
        return _ipk(s.key)
    end
    local function _ge()
        if identifyexecutor then local ok,n=pcall(identifyexecutor) if ok and n~="" then return n end end
        if getexecutorname then local ok,n=pcall(getexecutorname) if ok and n~="" then return n end end
        return "Unknown"
    end

--// PONTO ROXO
    local function _dot()
        local ex=_pg:FindFirstChild("IronTechDot")
        if ex then ex:Destroy() end
        local gui=Instance.new("ScreenGui")
        gui.Name="IronTechDot" gui.ResetOnSpawn=false
        gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
        gui.DisplayOrder=999 gui.IgnoreGuiInset=true gui.Parent=_pg

        local ring=Instance.new("Frame")
        ring.Size=UDim2.new(0,5,0,5) ring.Position=UDim2.new(0,55,0,12)
        ring.AnchorPoint=Vector2.new(0.5,0.5) ring.BackgroundTransparency=1
        ring.BorderSizePixel=0 ring.ZIndex=1 ring.Parent=gui
        local rc=Instance.new("UICorner") rc.CornerRadius=UDim.new(1,0) rc.Parent=ring
        local rs=Instance.new("UIStroke")
        rs.Color=Color3.fromRGB(138,43,226) rs.Transparency=0.2 rs.Thickness=1 rs.Parent=ring

        local dot=Instance.new("Frame")
        dot.Size=UDim2.new(0,5,0,5) dot.Position=UDim2.new(0,55,0,12)
        dot.AnchorPoint=Vector2.new(0.5,0.5) dot.BackgroundColor3=Color3.fromRGB(120,0,240)
        dot.BorderSizePixel=0 dot.BackgroundTransparency=0 dot.ZIndex=2 dot.Parent=gui
        local dc=Instance.new("UICorner") dc.CornerRadius=UDim.new(1,0) dc.Parent=dot
        local dg=Instance.new("UIStroke")
        dg.Color=Color3.fromRGB(160,0,255) dg.Transparency=0.3 dg.Thickness=0.8 dg.Parent=dot

        task.spawn(function()
            while dot and dot.Parent do
                ring.Size=UDim2.new(0,5,0,5) rs.Transparency=0.15
                _ts:Create(ring,TweenInfo.new(0.9,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,14,0,14)}):Play()
                _ts:Create(rs,TweenInfo.new(0.9,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Transparency=1}):Play()
                _ts:Create(dot,TweenInfo.new(0.45,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundTransparency=0.35}):Play()
                task.wait(0.45)
                _ts:Create(dot,TweenInfo.new(0.45,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundTransparency=0}):Play()
                task.wait(0.75)
            end
        end)
    end
    _dot()

--// KERNEL DESLIGADO
    if not _ec.KernelEnabled then
        loadstring(game:HttpGet(_ms))()
        return
    end

--// PREMIUM SALVO
    if _hsp() then
        loadstring(game:HttpGet(_ms))()
        return
    end

--// CHAVE SALVA VÁLIDA
    local _sl=_mgr:load(_s.lj)
    local _sk=_mgr:load(_s.kj)
    if _sl and _sk and _ilv() then
        if _vk(_sk.key,_sl.link) then
            loadstring(game:HttpGet(_ms))()
            return
        end
    end

--// CARREGA CONFIG VISUAL
    local _vc={}
    pcall(function()
        local ok,raw=pcall(function() return game:HttpGet(_lcfg._u) end)
        if ok and raw then
            local cl=raw:gsub("%-%-[^\n]*",""):gsub("%s+"," ")
            local ok2,p=pcall(function() return _hs:JSONDecode(cl) end)
            if ok2 and type(p)=="table" then _vc=p end
        end
    end)

    local _icon  = _vc["OpenIcon"]           or "rbxassetid://98419825001487"
    local _theme = _vc["ThemeSelect"]         or "grape"
    local _snd   = _vc["SoundId"]             or ""
    local _vol   = _vc["SoundVolume"]         or 1
    local _thl   = _vc["_themes_available"]   or {
        "darker","dark","carbon","obsidian","midnight","navy","ocean","teal","slate",
        "grape","rose","crimson","bronze","forest","ash","void","aurora","ember",
        "lilac","storm","rust","pine"
    }

--// DESTROI UI
    local function _dkg()
        pcall(function() local g=_cg:FindFirstChild("BastardXHub") if g then g:Destroy() end end)
        pcall(function() local f=_cg:FindFirstChild("BastardFloatBtn") if f then f:Destroy() end end)
        pcall(function() local d=_pg:FindFirstChild("IronTechDot") if d then d:Destroy() end end)
    end

--// CARREGA LIB UI
    local _bxh=loadstring(game:HttpGet(_lib._u))()

    local function _ntf(msg,delay,color)
        return _bxh:MakeNotify({
            Title=_hn,Content=msg or "",
            Color=color or Color3.fromRGB(255,255,255),
            Delay=delay or 4
        })
    end

    local _gname=""
    pcall(function() _gname=_mps:GetProductInfo(game.PlaceId).Name or "" end)

    local _win=_bxh:Window({
        Title=_hn..(_gname~="" and (" | ".._gname) or "").." | ".._ge(),
        Color=Color3.fromRGB(255,255,255),
        Version=1,
        ThemePreset=_theme,
    })

    local _fl=_bxh:FloatBtn({
        Icon=_icon,Color=Color3.fromRGB(255,255,255),
        ColorDark=Color3.fromRGB(35,35,35),Size=46,
        MainHolder=_win._holder,
    })
    _win:RegisterFloat(_fl)

    if _snd~="" then
        task.spawn(function()
            local s=Instance.new("Sound")
            s.SoundId=_snd s.Volume=_vol s.RollOffMaxDistance=1000
            s.Parent=game:GetService("SoundService")
            if not s.IsLoaded then s.Loaded:Wait() end
            s:Play()
            game:GetService("Debris"):AddItem(s,15)
        end)
    end

    task.delay(0.5,function() _ntf("Sistema de senha ativo!",4,Color3.fromRGB(100,220,180)) end)

--// ABA: VERIFICAR
    local _tv=_win:AddTab({Name="Verificar",Icon="rbxassetid://7733965118"})
    local _sv=_tv:AddSection("Pegue uma senha para continuar",true)

    _sv:AddButton({
        Title="Gerar Link (Clique Aqui)",
        Callback=function()
            local links={}
            for l in pairs(_ic.Links) do table.insert(links,l) end
            if #links==0 then _ntf("Nenhum link disponível",3,Color3.fromRGB(255,100,100)) return end
            local rl=links[math.random(#links)]
            _mgr:save(_s.lj,{link=rl,time=tick()})
            setclipboard(rl)
            _ntf("Link copiado! Cole no navegador.",5,Color3.fromRGB(255,220,100))
        end,
    })

    local _ik=""
    _sv:AddInput({
        Title="Digite a senha:",Content="Senha de Acesso",Default="",
        Callback=function(v) _ik=v end,
    })

    _sv:AddButton({
        Title="Confirmar Senha",
        Callback=function()
            if _ik=="" then _ntf("Digite uma senha",3,Color3.fromRGB(255,150,80)) return end
            if _ipk(_ik) then
                _mgr:save(_s.pj,{key=_ik})
                _ntf("Acesso Premium ativado!",4,Color3.fromRGB(255,215,0))
                task.wait(1) _dkg() _win=nil _bxh=nil
                loadstring(game:HttpGet(_ms))()
                return
            end
            local _sld=_mgr:load(_s.lj)
            if not _sld or not _ilv() then
                _ntf("Gere um novo link para continuar",4,Color3.fromRGB(255,100,100))
                return
            end
            if _vk(_ik,_sld.link) then
                _mgr:save(_s.kj,{key=_ik,time=tick()})
                _ntf("Acesso liberado com sucesso!",3,Color3.fromRGB(100,255,150))
                task.wait(1) _dkg() _win=nil _bxh=nil
                loadstring(game:HttpGet(_ms))()
            else
                _ntf("Senha incorreta. Tente novamente.",4,Color3.fromRGB(255,80,80))
            end
        end,
    })

--// ABA: PREMIUM
    local _tp=_win:AddTab({Name="Premium",Icon="rbxassetid://127843403295538"})
    local _sp=_tp:AddSection("Adquira seu Acesso Premium",true)
    _sp:AddParagraph({
        Title="Benefícios",
        Content="- Acesso Premium de 30 dias\n- Sem precisar de links ou encurtadores\n- Suporte VIP no Discord\n- Acesso antecipado aos novos recursos",
    })
    _sp:AddButton({
        Title="Copiar link do Discord",
        Callback=function()
            setclipboard(_ic.DiscordLink)
            _ntf("Link do Discord copiado!",5,Color3.fromRGB(114,137,218))
        end,
    })

--// ABA: CONFIG
    local _tc=_win:AddTab({Name="Config",Icon="settings"})
    local _sc=_tc:AddSection("Salvar / Carregar",true)
    _sc:AddButton({
        Title="Salvar Config",SubTitle="Carregar Config",
        Callback=function() _win:SaveConfig() _ntf("Config salva!",3,Color3.fromRGB(180,255,180)) end,
        SubCallback=function() _win:LoadConfig() _ntf("Config carregada!",3,Color3.fromRGB(180,200,255)) end,
    })
    local _st=_tc:AddSection("Visual da Interface",true)
    _st:AddDropdown({Title="Tema",Options=_thl,Default=_theme,Multi=false,Callback=function(v) _win:SetTheme(v) end})
    _st:AddColorPicker({Title="Cor de Destaque",Default=Color3.fromRGB(255,255,255),Callback=function(c) _win:SetAccentColor(c) end})
    _st:AddSlider({Title="Nitidez",Min=0,Max=95,Default=0,Increment=1,Callback=function(v) _win:SetTransparency(v/100) end})
    local _sk2=_tc:AddSection("Atalhos",true)
    _sk2:AddKeybind({Title="Toggle UI",Default=Enum.KeyCode.X,Callback=function(kc) _win:LibSettings({ToggleKey=kc}) end})

end
--// IronTech v4.0
