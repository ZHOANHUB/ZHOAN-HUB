-- ============================================================
--  MM2 Hub - Rayfield Edition
-- ============================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local TeleportService    = game:GetService("TeleportService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Lighting           = game:GetService("Lighting")
local MaterialService    = game:GetService("MaterialService")
local LocalPlayer        = Players.LocalPlayer

if game.PlaceId ~= 142823291 then
    Rayfield:Notify({Title="MM2 Hub", Content="Only works in Murder Mystery 2.", Duration=5, Image=4483362458})
    return
end

local SCRIPT_VERSION = "1.0.4"

-- ============================================================
--  STATE
-- ============================================================
local Aim = { LockOn=false, Smooth=8, Range=500, Bone="Head", Trigger=false, TriggerRange=300, AutoFire=false, WallCheck=true, FOVCircle=false, FOVRadius=120, AutoKill=false, AutoThrow=false }
local Visual = {
    ForceField=false, ForceFieldColor=Color3.fromRGB(0,170,255),
    AuraOn=false, AuraSel={},
    KillEffect=false, KillEffectColor=Color3.fromRGB(255,0,0),
    ChinaHat=false, ChinaHatColor=Color3.fromRGB(255,123,123),
    Headless=false, Korblox=false,
    RTX=false, SkyOn=false, SkyType="Sunset",
    WeatherOn=false, WeatherType="LightRain", WeatherIntensity=1, WeatherColor=Color3.fromRGB(200,200,255),
    Crosshair=false, CrosshairColor=Color3.fromRGB(255,255,255),
    ToolSpin=false, ToolSpinMode=1, ToolSpinSpeed=1,
    FFTools=false, FFToolsColor=Color3.fromRGB(255,0,255),
    Textures=false, TextureTheme="minecraft",
    LightOn=false, AmbientOn=false, AmbientColor=Color3.fromRGB(255,123,123),
    TimeOn=false, TimeValue=12,
    CCOn=false, CCSat=0, CCCon=0, CCBri=0,
}
local ESPS = {
    PlayerESP=false, PlayerESPRoles={ Murderer=true, Sheriff=true, Innocent=true, Hero=true },
    NameESP=false, NameRoles={ Murderer=true, Sheriff=true, Innocent=true, Hero=true },
    Box2D=false, DisplayName=false, Username=true, Avatar=false,
    Gun=false, Trap=false, Beam=false,
    Coin=false, CoinColor=Color3.fromRGB(255,215,0),
    Candy=false, CandyColor=Color3.fromRGB(255,105,180),
}
local ROLE_COLORS = {
    Murderer=Color3.fromRGB(255,0,0),
    Sheriff =Color3.fromRGB(0,132,255),
    Hero    =Color3.fromRGB(255,200,0),
    Innocent=Color3.fromRGB(56,255,112),
}
local Misc     = { InfJump=false, AntiAFK=false, AutoGun=false, SilentAim=false, AntiVoid=false, Evade=false, PanicKey=true, AutoRejoin=false }
local Movement = { Noclip=false, Fly=false, WalkSpeed=16, JumpPower=50, FlySpeed=40, AntiFling=false }
local Farm     = { On=false, Type=nil, ResetBag=false, ShootBag=false, KillAllBag=false }

local FARM_SPEED = 23
local PANIC_KEY  = Enum.KeyCode.P

local PanicToggles = {}
local function PT(t) table.insert(PanicToggles, t) return t end

local S = {
    roleCache={}, murdererCache={plr=nil, time=0}, roundActive=false,
    fadeConn=nil, noclipConn=nil, afkConn=nil,
    flyConn=nil, flyBV=nil, flyBG=nil,
    lockConn=nil, triggerConn=nil, fireConn=nil, killConn=nil, throwConn=nil,
    voidConn=nil, safeCF=nil, evadeBV=nil,
    beamSegs={}, beamConn=nil, beamTick=0,
    fovGui=nil,
    highlights={}, tags={}, gunHL=nil, gunBB=nil, itemHLs={Coin={}, Candy={}},
    antiFlingConns={}, antiFlingOn=false,
    emoteTrack=nil, oldNamecall=nil,
    ffOrig={}, auraAssets={}, auraParts={},
    hatParts={}, killConns={},
    rtxOrig=nil, skyOrig=nil,
    weatherPart=nil, weatherEmitter=nil, weatherConn=nil,
    crossLines={}, crossOutlines={}, crossConn=nil, crossRot=0,
    spinConn=nil, spinGrip=nil,
    ffToolOrig={},
    texObjects={},
    ccEffect=nil, lightConn=nil,
    legOrig={}, headOrig=nil,
    farm={active=false, laid=false, tween=nil, holdConn=nil, noclipConn=nil, orig={}, collected=0, total=0, allDone=false, bagBusy=false, startTime=0, container=nil, containerCheck=0},
}

-- ============================================================
--  HELPERS
-- ============================================================
local function HRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function Hum()
    local c = LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function roleFromCache(p)
    local i = S.roleCache[p.Name]
    return i and i.Role or nil
end
local function hasTool(parent, name)
    if not parent then return false end
    for _, t in ipairs(parent:GetChildren()) do
        if t:IsA("Tool") and t.Name:lower():find(name, 1, true) then return true end
    end
    return false
end
local function scanRole(p)
    local c  = p.Character
    local bp = p:FindFirstChildOfClass("Backpack")
    if hasTool(c, "knife") or hasTool(bp, "knife") then return "Murderer" end
    if hasTool(c, "gun")   or hasTool(bp, "gun")   then return "Sheriff"  end
    return nil
end
local function getRole(p)
    if not S.roundActive then return "Innocent" end
    local cached = roleFromCache(p)
    if cached then return cached end
    local scanned = scanRole(p)
    if scanned then
        S.roleCache[p.Name] = { Role = scanned, Dead = false }
        return scanned
    end
    return "Innocent"
end
local function isMurderer(p)
    if not S.roundActive then return false end
    if not p or p == LocalPlayer or not p.Parent then return false end
    local cached = S.roleCache[p.Name]
    if cached and cached.Dead then return false end
    if cached and cached.Role == "Murderer" then return true end
    local c  = p.Character
    local bp = p:FindFirstChildOfClass("Backpack")
    return hasTool(c,"knife") or hasTool(bp,"knife")
end
local function getMurderer()
    if not S.roundActive then return nil end
    local now = tick()
    local c = S.murdererCache.plr
    if c and c.Parent and c.Character and (now - S.murdererCache.time) < 0.15 then return c end
    local found = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isMurderer(p) then found = p break end
    end
    S.murdererCache.plr  = found
    S.murdererCache.time = now
    return found
end
local function getSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and getRole(p) == "Sheriff" then return p end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local c, bp = p.Character, p:FindFirstChildOfClass("Backpack")
            if hasTool(c,"gun") or hasTool(bp,"gun") then return p end
        end
    end
    return nil
end
local function isLocalSheriff()
    if not S.roundActive then return false end
    if roleFromCache(LocalPlayer) == "Sheriff" then return true end
    local c, bp = LocalPlayer.Character, LocalPlayer:FindFirstChildOfClass("Backpack")
    return hasTool(c,"gun") or hasTool(bp,"gun")
end
local function isLocalMurderer()
    if not S.roundActive then return false end
    if roleFromCache(LocalPlayer) == "Murderer" then return true end
    local c, bp = LocalPlayer.Character, LocalPlayer:FindFirstChildOfClass("Backpack")
    return hasTool(c,"knife") or hasTool(bp,"knife")
end
local function localKnife()
    local c = LocalPlayer.Character
    if not c then return nil end
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") and t.Name:lower():find("knife", 1, true) then return t end
    end
    return nil
end
local function targetPart(char)
    if not char then return nil end
    if Aim.Bone == "Head" then return char:FindFirstChild("Head") end
    return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
end
local function gunOrigin()
    local c = LocalPlayer.Character
    if not c then return nil end
    local h = c:FindFirstChild("HumanoidRootPart")
    if not h then return nil end
    local att = h:FindFirstChild("GunRaycastAttachment")
    return att and att.WorldCFrame or h.CFrame
end
local function equippedGun()
    local c = LocalPlayer.Character
    if not c then return nil end
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") and t.Name:lower():find("gun", 1, true) then return t end
    end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find("gun", 1, true) then
                local h = Hum()
                if h then pcall(function() h:EquipTool(t) end) task.wait(0.1) end
                return c:FindFirstChild(t.Name)
            end
        end
    end
    return nil
end
local function shootRemote(gun)
    if not gun then return nil end
    local e = gun:FindFirstChild("Shoot")
    if e and e:IsA("RemoteEvent") then return e end
    local ev = gun:FindFirstChild("Events")
    if ev then
        local e2 = ev:FindFirstChild("Shoot")
        if e2 and e2:IsA("RemoteEvent") then return e2 end
    end
    for _, d in ipairs(gun:GetDescendants()) do
        if d.Name == "Shoot" and d:IsA("RemoteEvent") then return d end
    end
    return nil
end
local function predict(part, shooterPart)
    if not part then return nil end
    local ok, ping = pcall(function() return LocalPlayer:GetNetworkPing() end)
    if not ok or not ping then ping = 0.05 end
    local relativeVel = part.AssemblyLinearVelocity
    if shooterPart then relativeVel = relativeVel - shooterPart.AssemblyLinearVelocity end
    return CFrame.new(part.Position + relativeVel * (ping * 1.15))
end
local function charFromPart(part)
    local cur = part
    while cur and cur ~= workspace do
        if cur:IsA("Model") then
            local p = Players:GetPlayerFromCharacter(cur)
            if p then return p end
        end
        cur = cur.Parent
    end
    return nil
end
local function pathHit(from, to, tChar)
    local dir = to - from
    local dist = dir.Magnitude
    if dist < 0.5 then return "clear" end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = { workspace.CurrentCamera }
    if LocalPlayer.Character then table.insert(ignore, LocalPlayer.Character) end
    if tChar then
        for _, part in ipairs(tChar:GetDescendants()) do
            if part:IsA("Accessory") or part:IsA("Accoutrement") then table.insert(ignore, part) end
        end
    end
    params.FilterDescendantsInstances = ignore
    params.IgnoreWater = true
    local res = workspace:Raycast(from, dir.Unit * (dist + 1), params)
    if not res then return "clear" end
    if tChar and (res.Instance:IsDescendantOf(tChar) or res.Instance == tChar) then return "target" end
    local hp = charFromPart(res.Instance)
    if hp and hp ~= LocalPlayer and getRole(hp) ~= "Murderer" then return "innocent" end
    return "wall"
end
local function canShoot(from, to, tChar)
    local hit = pathHit(from, to, tChar)
    if hit == "innocent" then return false end
    if not Aim.WallCheck then return true end
    return hit ~= "wall"
end
local function fireAt(part, plr, throughWalls)
    if plr and not isMurderer(plr) then return false end
    local gun = equippedGun()
    if not gun then return false end
    local rem = shootRemote(gun)
    if not rem then return false end
    local my = HRP()
    if not my then return false end
    local origin
    if throughWalls then
        origin = CFrame.new(part.Position + Vector3.new(0,3,0), part.Position)
    else
        origin = gunOrigin() or my.CFrame
        if not canShoot(my.Position, part.Position, plr and plr.Character) then return false end
    end
    local cf = predict(part, my) or CFrame.new(part.Position)
    return pcall(function() rem:FireServer(origin, cf) end)
end
local function throwKnifeAt(target)
    local knife = localKnife()
    if not knife then return false end
    local my = HRP()
    local tp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not my or not tp then return false end
    if not canShoot(my.Position, tp.Position, target.Character) then return false end
    local ev = knife:FindFirstChild("Events")
    local throw = ev and (ev:FindFirstChild("KnifeThrown") or ev:FindFirstChild("Throw")) or knife:FindFirstChild("Throw")
    local pred = tp.Position + tp.AssemblyLinearVelocity * 0.3
    local from = CFrame.new(my.Position + Vector3.new(0,2,0))
    if throw and throw:IsA("RemoteEvent") then
        return pcall(function() throw:FireServer(from, CFrame.new(pred)) end)
    elseif throw and throw:IsA("RemoteFunction") then
        return pcall(function() throw:InvokeServer(from, CFrame.new(pred)) end)
    end
    return false
end
local function nearestVictim()
    local my = HRP()
    if not my then return nil end
    local best, bd = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = p.Character:FindFirstChild("HumanoidRootPart")
            if h then
                local d = (my.Position - h.Position).Magnitude
                if d < bd then bd = d best = p end
            end
        end
    end
    return best, bd
end
local function killAllAura()
    local knife = localKnife()
    if not knife then
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") and t.Name:lower():find("knife", 1, true) then
                    local h = Hum()
                    if h then pcall(function() h:EquipTool(t) end) end
                    task.wait(0.3)
                    knife = localKnife()
                    break
                end
            end
        end
    end
    if not knife then return false end
    local ev = knife:FindFirstChild("Events")
    if not ev then return false end
    local stab  = ev:FindFirstChild("KnifeStabbed")
    local touch = ev:FindFirstChild("HandleTouched")
    if not stab or not touch then return false end
    local saved = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = p.Character:FindFirstChild("HumanoidRootPart")
            if h then
                saved[p] = { size = h.Size, trans = h.Transparency, coll = h.CanCollide }
                h.Size = Vector3.new(60,60,60) h.Transparency = 1 h.CanCollide = false
            end
        end
    end
    local start = tick()
    task.spawn(function()
        while tick() - start < 5 do
            pcall(function() stab:FireServer() end)
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local ph = p.Character:FindFirstChildOfClass("Humanoid")
                    if ph and ph.Health > 0 then
                        for _, part in ipairs(p.Character:GetChildren()) do
                            if part:IsA("BasePart") then pcall(function() touch:FireServer(part) end) end
                        end
                    end
                end
            end
            task.wait(0.03)
        end
        for p, data in pairs(saved) do
            if p.Character then
                local h = p.Character:FindFirstChild("HumanoidRootPart")
                if h then h.Size = data.size h.Transparency = data.trans h.CanCollide = data.coll end
            end
        end
    end)
    return true
end

local function panicOff()
    for _, t in ipairs(PanicToggles) do
        pcall(function() t:Set(false) end)
    end
    Aim.LockOn=false Aim.Trigger=false Aim.AutoFire=false Aim.AutoKill=false Aim.AutoThrow=false
    Misc.SilentAim=false
    if S.lockConn    then S.lockConn:Disconnect()    S.lockConn = nil    end
    if S.triggerConn then S.triggerConn:Disconnect() S.triggerConn = nil end
    if S.fireConn    then S.fireConn:Disconnect()    S.fireConn = nil    end
    if S.killConn    then S.killConn:Disconnect()    S.killConn = nil    end
    if S.throwConn   then S.throwConn:Disconnect()   S.throwConn = nil   end
    Rayfield:Notify({Title="Panic", Content="All features disabled.", Duration=3, Image=4483362458})
end

pcall(function()
    S.oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if getnamecallmethod() == "FireServer" and Misc.SilentAim and not checkcaller() then
            if self:IsA("RemoteEvent") and self.Name == "Shoot" then
                local m = getMurderer()
                if m and m.Character then
                    local tp = targetPart(m.Character)
                    if tp then
                        local my = HRP()
                        local from = my and my.Position or workspace.CurrentCamera.CFrame.Position
                        if canShoot(from, tp.Position, m.Character) then
                            local args = table.pack(...)
                            local cf = predict(tp, my)
                            if cf then
                                args[2] = cf
                                return S.oldNamecall(self, table.unpack(args, 1, args.n))
                            end
                        end
                    end
                end
            end
        end
        return S.oldNamecall(self, ...)
    end))
end)

local function getFade()
    local rem = ReplicatedStorage:FindFirstChild("Remotes")
    if not rem then return nil end
    local gp = rem:FindFirstChild("Gameplay")
    if not gp then return nil end
    return gp:FindFirstChild("Fade")
end
local function clearHL(p)
    if S.highlights[p] then S.highlights[p]:Destroy() S.highlights[p] = nil end
    if S.tags[p] then
        if S.tags[p].bb  and S.tags[p].bb.Parent  then S.tags[p].bb:Destroy()  end
        if S.tags[p].box and S.tags[p].box.Parent then S.tags[p].box:Destroy() end
        S.tags[p] = nil
    end
end
local function clearAllHL()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then clearHL(p) end
    end
end

local function findGunDrop()
    for _, o in ipairs(workspace:GetChildren()) do
        if o:IsA("BasePart") and o.Name:lower():find("gundrop") then return o end
        if o:IsA("Model") then
            local f = o:FindFirstChild("GunDrop", true)
            if f and f:IsA("BasePart") then return f end
        end
    end
    return workspace:FindFirstChild("GunDrop", true)
end
local function applyGunESP()
    if not ESPS.Gun then
        if S.gunHL and S.gunHL.Parent then S.gunHL:Destroy() end S.gunHL = nil
        if S.gunBB and S.gunBB.Parent then S.gunBB:Destroy() end S.gunBB = nil
        return
    end
    local g = findGunDrop()
    if not g then
        if S.gunHL and S.gunHL.Parent then S.gunHL:Destroy() end S.gunHL = nil
        if S.gunBB and S.gunBB.Parent then S.gunBB:Destroy() end S.gunBB = nil
        return
    end
    if not S.gunHL or not S.gunHL.Parent or S.gunHL.Parent ~= g then
        if S.gunHL then S.gunHL:Destroy() end
        local h = Instance.new("Highlight")
        h.FillColor = Color3.fromRGB(255,200,0)
        h.FillTransparency = 0.3
        h.OutlineTransparency = 1
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = g
        S.gunHL = h
    end
    if not S.gunBB or not S.gunBB.Parent or S.gunBB.Parent ~= g then
        if S.gunBB then S.gunBB:Destroy() end
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0,160,0,24)
        bb.StudsOffset = Vector3.new(0,3,0)
        bb.AlwaysOnTop = true
        bb.Adornee = g
        bb.Parent = g
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,0,1,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "Gun dropped here!"
        lbl.TextColor3 = Color3.fromRGB(255,200,0)
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 13
        lbl.TextStrokeTransparency = 1
        lbl.Parent = bb
        S.gunBB = bb
    end
end

local function isTargetItem(obj, itemType)
    if not obj or not itemType then return false end
    if not obj:IsA("BasePart") then return false end
    local id = obj:GetAttribute(itemType .. "ID") or obj:GetAttribute("ItemID") or obj:GetAttribute("CoinID")
    if id == itemType or id == "Coin" or id == "Candy" then return true end
    local n = obj.Name:lower()
    if itemType == "Candy" and n:find("candy", 1, true) then return true end
    if itemType == "Coin"  and n:find("coin",  1, true) then return true end
    return false
end

local function findTargetContainer(itemType)
    if S.farm.container and S.farm.container.Parent then return S.farm.container end
    S.farm.container = nil
    local now = tick()
    if now - S.farm.containerCheck < 1 then return nil end
    S.farm.containerCheck = now
    local namesToCheck = {"CoinContainer","CandyContainer","ItemContainer","CandyBagContainer"}
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") or obj:IsA("Folder") then
            for _, name in ipairs(namesToCheck) do
                local c = obj:FindFirstChild(name)
                if c then S.farm.container = c return c end
            end
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "CoinContainer" or obj.Name == "CandyContainer" or obj.Name == "ItemContainer" then
            S.farm.container = obj return obj
        end
    end
    if itemType == "Candy" then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find("candy") then
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("BasePart") then S.farm.container = obj return obj end
                end
            end
        end
    end
    if itemType == "Coin" then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find("coin") then
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("BasePart") then S.farm.container = obj return obj end
                end
            end
        end
    end
    return nil
end

local function isItemCollectible(item, itemType)
    if not item or not itemType then return false end
    if not isTargetItem(item, itemType) then return false end
    if not item.CanTouch then return false end
    if not (item:FindFirstChildWhichIsA("TouchTransmitter") or item:FindFirstChild("TouchInterest")) then return false end
    if item.Transparency ~= 1 then return false end
    return true
end

local function findNearestItem(container, itemType)
    if not container or not itemType then return nil, math.huge end
    local hrp = HRP()
    if not hrp then return nil, math.huge end
    local best, bd = nil, math.huge
    for _, item in ipairs(container:GetDescendants()) do
        if isItemCollectible(item, itemType) then
            local d = (hrp.Position - item.Position).Magnitude
            if d < bd then bd = d best = item end
        end
    end
    return best, bd
end

local function countItems(container, itemType)
    if not container or not itemType then return 0, 0 end
    local total, collectible = 0, 0
    for _, item in ipairs(container:GetDescendants()) do
        if isTargetItem(item, itemType) then
            total = total + 1
            if isItemCollectible(item, itemType) then collectible = collectible + 1 end
        end
    end
    return total, collectible
end

local function clearItemHL(itemType)
    if not S.itemHLs[itemType] then return end
    for _, hl in ipairs(S.itemHLs[itemType]) do
        if hl.Parent then hl:Destroy() end
    end
    S.itemHLs[itemType] = {}
end

local function applyItemESP(itemType)
    local isEnabled = (itemType == "Coin" and ESPS.Coin) or (itemType == "Candy" and ESPS.Candy)
    local color     = (itemType == "Coin" and ESPS.CoinColor) or (itemType == "Candy" and ESPS.CandyColor)
    if not isEnabled then clearItemHL(itemType) return end
    local container = findTargetContainer(itemType)
    if not container then clearItemHL(itemType) return end
    for _, item in ipairs(container:GetDescendants()) do
        if isTargetItem(item, itemType) then
            local hl = item:FindFirstChild("ESP_HL")
            if not hl then
                hl = Instance.new("Highlight")
                hl.Name = "ESP_HL"
                hl.Adornee = item
                hl.FillTransparency = 0.3
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = item
                table.insert(S.itemHLs[itemType], hl)
            end
            hl.FillColor    = color
            hl.OutlineColor = color
        end
    end
end

local function applyRoles(data)
    if type(data) ~= "table" then return end
    for name, info in pairs(data) do
        if type(info) == "table" and info.Role then
            S.roleCache[name] = { Role = info.Role, Dead = info.Dead or false }
        end
    end
    refreshESP()
end
local function hookFade()
    if S.fadeConn then S.fadeConn:Disconnect() S.fadeConn = nil end
    local ev = getFade()
    if not ev then return end
    S.fadeConn = ev.OnClientEvent:Connect(function(...)
        S.roleCache = {}
        S.murdererCache.plr = nil S.murdererCache.time = 0
        S.roundActive = true
        for _, arg in ipairs({...}) do
            if type(arg) == "table" then applyRoles(arg) end
        end
        refreshESP()
    end)
end
hookFade()
task.spawn(function()
    while true do
        task.wait(3)
        if not S.fadeConn or not getFade() then hookFade() end
    end
end)

local function applyESP(plr)
    if plr == LocalPlayer then return end
    local char = plr.Character
    if not char then clearHL(plr) return end
    if not S.roundActive then clearHL(plr) return end
    local cached = S.roleCache[plr.Name]
    if cached and cached.Dead then clearHL(plr) return end
    local role = getRole(plr)
    local col  = ROLE_COLORS[role] or ROLE_COLORS.Innocent
    if ESPS.PlayerESP and ESPS.PlayerESPRoles[role] then
        local hl = S.highlights[plr]
        if not hl or not hl.Parent or hl.Parent ~= char then
            if hl then hl:Destroy() end
            hl = Instance.new("Highlight")
            hl.Name = "PlayerHighlight"
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = char
            S.highlights[plr] = hl
        end
        hl.FillColor    = col
        hl.OutlineColor = col
    elseif S.highlights[plr] then
        S.highlights[plr]:Destroy() S.highlights[plr] = nil
    end
    if ESPS.NameESP and ESPS.NameRoles[role] then
        local tag  = S.tags[plr]
        local head = char:FindFirstChild("Head")
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        if head and hrp then
            if not tag or not tag.bb or not tag.bb.Parent then
                if tag then
                    if tag.bb  then tag.bb:Destroy()  end
                    if tag.box then tag.box:Destroy() end
                end
                tag = {}
                local bb = Instance.new("BillboardGui")
                bb.Name = "NameESP"
                bb.AlwaysOnTop = true
                bb.Size = UDim2.new(0,200,0,80)
                bb.StudsOffset = Vector3.new(0,2,0)
                bb.Parent = head
                local frame = Instance.new("Frame")
                frame.Name = "AvatarFrame"
                frame.BackgroundColor3 = Color3.new(1,1,1)
                frame.Size = UDim2.new(0,40,0,40)
                frame.Position = UDim2.new(0.5,-20,0,0)
                frame.BorderSizePixel = 2
                frame.Parent = bb
                local fc = Instance.new("UICorner")
                fc.CornerRadius = UDim.new(1,0)
                fc.Parent = frame
                local img = Instance.new("ImageLabel")
                img.Name = "Avatar"
                img.BackgroundTransparency = 1
                img.Size = UDim2.new(1,0,1,0)
                img.Parent = frame
                local ic = Instance.new("UICorner")
                ic.CornerRadius = UDim.new(1,0)
                ic.Parent = img
                local lbl = Instance.new("TextLabel")
                lbl.Name = "NameLabel"
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.new(0,200,0,20)
                lbl.Position = UDim2.new(0,0,0,45)
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 14
                lbl.TextStrokeTransparency = 0
                lbl.TextStrokeColor3 = Color3.new(0,0,0)
                lbl.Parent = bb
                tag.bb = bb tag.lbl = lbl tag.frame = frame tag.img = img tag.box = nil tag.thumb = false
                S.tags[plr] = tag
                task.spawn(function()
                    local ok, url = pcall(function()
                        return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
                    end)
                    if ok and url and tag.img then tag.img.Image = url tag.thumb = true end
                end)
            end
            if tag.lbl then
                if ESPS.DisplayName then      tag.lbl.Text = plr.DisplayName
                elseif ESPS.Username  then    tag.lbl.Text = plr.Name
                else                          tag.lbl.Text = "" end
                tag.lbl.TextColor3 = col
            end
            if tag.frame then
                tag.frame.Visible = ESPS.Avatar
                tag.frame.BorderColor3 = col
            end
            if ESPS.Box2D then
                if not tag.box or not tag.box.Parent then
                    local box = Instance.new("BillboardGui")
                    box.Name = "Box2D"
                    box.AlwaysOnTop = true
                    box.Size = UDim2.new(4,0,5,0)
                    box.Parent = hrp
                    local bf = Instance.new("Frame")
                    bf.Name = "BoxFrame"
                    bf.BackgroundTransparency = 1
                    bf.Size = UDim2.new(1,0,1,0)
                    bf.BorderSizePixel = 2
                    bf.Parent = box
                    local bs = Instance.new("UIStroke")
                    bs.Name = "Stroke"
                    bs.Thickness = 2
                    bs.Parent = bf
                    tag.box = box
                end
                local bf = tag.box:FindFirstChild("BoxFrame")
                if bf then
                    local bs = bf:FindFirstChild("Stroke")
                    if bs then bs.Color = col end
                end
            elseif tag.box then
                tag.box:Destroy() tag.box = nil
            end
        end
    elseif S.tags[plr] then
        if S.tags[plr].bb  then S.tags[plr].bb:Destroy()  end
        if S.tags[plr].box then S.tags[plr].box:Destroy() end
        S.tags[plr] = nil
    end
end
function refreshESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then applyESP(p) end
    end
    applyGunESP()
    applyItemESP("Coin")
    applyItemESP("Candy")
end

local function resetRound()
    S.roundActive = false
    S.roleCache = {}
    S.murdererCache.plr = nil S.murdererCache.time = 0
    S.farm.collected = 0 S.farm.total = 0 S.farm.allDone = false S.farm.bagBusy = false
    S.farm.container = nil S.farm.containerCheck = 0
    stopFarming()
    clearAllHL()
    refreshESP()
end

local function setupRoundListeners()
    local rem = ReplicatedStorage:FindFirstChild("Remotes")
    if not rem then return end
    local gp = rem:FindFirstChild("Gameplay")
    if not gp then return end
    local roundEnd = gp:FindFirstChild("RoundEndFade")
    if roundEnd then
        roundEnd.OnClientEvent:Connect(function()
            S.roundActive = false
            S.roleCache = {}
            S.murdererCache.plr = nil S.murdererCache.time = 0
            S.farm.collected = 0 S.farm.total = 0 S.farm.allDone = false S.farm.bagBusy = false
            S.farm.container = nil S.farm.containerCheck = 0
            stopFarming()
            clearAllHL()
            refreshESP()
        end)
    end
    local roundStart = gp:FindFirstChild("RoundStart")
    if roundStart then
        roundStart.OnClientEvent:Connect(function()
            S.roundActive = true
            S.farm.collected = 0 S.farm.total = 0 S.farm.allDone = false S.farm.bagBusy = false
            S.farm.container = nil S.farm.containerCheck = 0
            task.wait(0.5)
            refreshESP()
        end)
    end
    local coinEvent = gp:FindFirstChild("CoinCollected")
    if coinEvent then
        coinEvent.OnClientEvent:Connect(function(typ, collected, total)
            if typ == Farm.Type or typ == nil then
                S.farm.collected = tonumber(collected) or S.farm.collected
                S.farm.total     = tonumber(total)    or S.farm.total
                if S.farm.total > 0 and S.farm.collected >= S.farm.total then
                    S.farm.allDone = true
                    stopFarming()
                end
            end
        end)
    end
end

local function findMap()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:GetAttribute("MapID") then return obj end
    end
    return nil
end

task.spawn(function()
    local noMapTime = 0
    while true do
        task.wait(0.5)
        local hasMap = findMap() ~= nil
        if hasMap then
            noMapTime = 0
            if not S.roundActive then
                for _, p in ipairs(Players:GetPlayers()) do
                    if scanRole(p) then S.roundActive = true break end
                end
            end
        else
            noMapTime = noMapTime + 0.5
            if noMapTime >= 1 and S.roundActive then resetRound() end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1.5)
        if S.roundActive then
            local changed = false
            for _, p in ipairs(Players:GetPlayers()) do
                local cached = S.roleCache[p.Name]
                if not cached or not cached.Role then
                    local scanned = scanRole(p)
                    if scanned then
                        S.roleCache[p.Name] = { Role = scanned, Dead = false }
                        changed = true
                    end
                end
            end
            if changed then refreshESP() end
        end
    end
end)

local function bindPlayerRoles(p)
    local function onToolChange()
        task.wait(0.05)
        if not S.roundActive then return end
        local scanned = scanRole(p)
        if scanned then
            S.roleCache[p.Name] = { Role = scanned, Dead = false }
            refreshESP()
        end
    end
    local function bindChar(char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Died:Connect(function()
                S.roleCache[p.Name] = nil
                if S.murdererCache.plr == p then S.murdererCache.plr = nil S.murdererCache.time = 0 end
                clearHL(p)
            end)
        end
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then onToolChange() end
        end)
    end
    p.CharacterAdded:Connect(bindChar)
    if p.Character then bindChar(p.Character) end
    local function bindBp(bp)
        bp.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then onToolChange() end
        end)
    end
    local bp = p:FindFirstChildOfClass("Backpack")
    if bp then bindBp(bp) end
    p.ChildAdded:Connect(function(child)
        if child:IsA("Backpack") then bindBp(child) end
    end)
end

-- ============================================================
--  BEAM
-- ============================================================
local function clearBeam()
    for _, seg in ipairs(S.beamSegs) do
        if seg.beam then seg.beam:Destroy() end
        if seg.a then seg.a:Destroy() end
        if seg.b then seg.b:Destroy() end
        if seg.p0 then seg.p0:Destroy() end
        if seg.p1 then seg.p1:Destroy() end
    end
    S.beamSegs = {}
end
local function beamSeg()
    local p0 = Instance.new("Part") p0.Size = Vector3.new(0.1,0.1,0.1) p0.Transparency = 1
    p0.CanCollide = false p0.Anchored = true p0.Massless = true p0.Parent = workspace
    local p1 = Instance.new("Part") p1.Size = Vector3.new(0.1,0.1,0.1) p1.Transparency = 1
    p1.CanCollide = false p1.Anchored = true p1.Massless = true p1.Parent = workspace
    local a = Instance.new("Attachment") a.Parent = p0
    local b = Instance.new("Attachment") b.Parent = p1
    local beam = Instance.new("Beam")
    beam.Attachment0 = a beam.Attachment1 = b
    beam.FaceCamera = true beam.Width0 = 0.15 beam.Width1 = 0.15
    beam.Transparency = NumberSequence.new(0.2)
    beam.LightEmission = 1 beam.Parent = p0
    return {beam=beam, a=a, b=b, p0=p0, p1=p1}
end
local function beamPath(from, to, tChar)
    local pts = { from }
    local cur = from
    for _ = 1, 14 do
        local diff = to - cur
        if diff.Magnitude < 1 then break end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local ignore = { workspace.CurrentCamera }
        if LocalPlayer.Character then table.insert(ignore, LocalPlayer.Character) end
        params.FilterDescendantsInstances = ignore
        params.IgnoreWater = true
        local res = workspace:Raycast(cur, diff, params)
        if not res then table.insert(pts, to) break end
        if tChar and (res.Instance:IsDescendantOf(tChar) or res.Instance == tChar) then table.insert(pts, to) break end
        local hp = charFromPart(res.Instance)
        if hp and hp ~= LocalPlayer and getRole(hp) == "Murderer" then table.insert(pts, to) break end
        local hit  = res.Position
        local nrm  = res.Normal
        local trav = hit - cur
        if trav.Magnitude < 0.1 then table.insert(pts, to) break end
        local perp = nrm:Cross(Vector3.yAxis)
        if perp.Magnitude < 0.01 then perp = nrm:Cross(Vector3.xAxis) end
        perp = perp.Unit
        local sa = hit + perp * 3
        local sb = hit - perp * 3
        local pick = ((sa - to).Magnitude < (sb - to).Magnitude) and sa or sb
        pick = pick + trav.Unit * 0.5
        if (pick - cur).Magnitude < 0.5 then pick = cur + trav.Unit end
        table.insert(pts, pick)
        cur = pick
    end
    if (pts[#pts] - to).Magnitude > 1 then table.insert(pts, to) end
    return pts
end
local function updateBeam()
    if not ESPS.Beam then if #S.beamSegs > 0 then clearBeam() end return end
    local my = HRP()
    local m  = getMurderer()
    if not my or not m or not m.Character then clearBeam() return end
    local tp = targetPart(m.Character)
    if not tp then clearBeam() return end
    local pts = beamPath(my.Position, tp.Position, m.Character)
    local need = #pts - 1
    if need < 1 then clearBeam() return end
    while #S.beamSegs < need do table.insert(S.beamSegs, beamSeg()) end
    while #S.beamSegs > need do
        local seg = table.remove(S.beamSegs)
        seg.beam:Destroy() seg.a:Destroy() seg.b:Destroy() seg.p0:Destroy() seg.p1:Destroy()
    end
    local hit = pathHit(my.Position, tp.Position, m.Character)
    local col
    if hit == "clear" or hit == "target" then col = Color3.fromRGB(0,255,100)
    elseif hit == "innocent" then col = Color3.fromRGB(255,130,0)
    else col = Color3.fromRGB(255,50,50) end
    for i = 1, need do
        local seg = S.beamSegs[i]
        seg.p0.CFrame = CFrame.new(pts[i])
        seg.p1.CFrame = CFrame.new(pts[i + 1])
        seg.beam.Color = ColorSequence.new(col)
    end
end
local function beamLoop()
    if S.beamConn then return end
    S.beamConn = RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - S.beamTick < 0.033 then return end
        S.beamTick = now
        updateBeam()
    end)
end
local function beamStop()
    if S.beamConn then S.beamConn:Disconnect() S.beamConn = nil end
    clearBeam()
end

-- ============================================================
--  AURAS
-- ============================================================
local AURA_ASSETS = {
    starlight="rbxassetid://134645216613107", heavenly="rbxassetid://139300897520961",
    ribbon="rbxassetid://132069507632161",     sakura="rbxassetid://81755778619404",
    angel="rbxassetid://97658130917593",       wind="rbxassetid://80694081850877",
    flow="rbxassetid://119913533725648",      star="rbxassetid://73754563740680",
}
task.spawn(function()
    for name, id in pairs(AURA_ASSETS) do
        local ok, obj = pcall(function() return game:GetObjects(id)[1] end)
        if ok and obj then S.auraAssets[name] = obj end
    end
end)
local function clearAuras()
    for _, part in ipairs(S.auraParts) do pcall(function() part:Destroy() end) end
    S.auraParts = {}
end
local function applyAuras()
    clearAuras()
    if not Visual.AuraOn then return end
    local char = LocalPlayer.Character
    if not char then return end
    local count = 0
    for _ in pairs(Visual.AuraSel) do count = count + 1 end
    if count == 0 then return end
    for name in pairs(Visual.AuraSel) do
        local asset = S.auraAssets[name]
        if asset then
            local clone = asset:Clone()
            for _, part in ipairs(clone:GetChildren()) do
                local target = char:FindFirstChild(part.Name)
                if target then
                    for _, child in ipairs(part:GetChildren()) do
                        local c = child:Clone()
                        c.Parent = target
                        table.insert(S.auraParts, c)
                    end
                end
            end
            clone:Destroy()
        end
    end
end

-- ============================================================
--  VISUALS - character
-- ============================================================
local function applyForceField()
    local char = LocalPlayer.Character
    if not char then return end
    if not Visual.ForceField then
        for part, data in pairs(S.ffOrig) do
            if part and part.Parent then
                part.Material = data.mat
                part.Color    = data.col
            end
        end
        S.ffOrig = {}
        return
    end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            local insideTool = false
            local par = part.Parent
            while par and par ~= char do
                if par:IsA("Tool") then insideTool = true break end
                par = par.Parent
            end
            if not insideTool then
                if not S.ffOrig[part] then
                    S.ffOrig[part] = { mat = part.Material, col = part.Color }
                end
                part.Material = Enum.Material.ForceField
                part.Color    = Visual.ForceFieldColor
            end
        end
    end
end

local function applyChinaHat()
    for _, part in ipairs(S.hatParts) do pcall(function() part:Destroy() end) end
    S.hatParts = {}
    if not Visual.ChinaHat then return end
    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    local hat = Instance.new("Part")
    hat.Name = "ChinaHat"
    hat.Size = Vector3.new(1,1,1)
    hat.Color = Visual.ChinaHatColor
    hat.Material = Enum.Material.Neon
    hat.Transparency = 0.2
    hat.CanCollide = false hat.Anchored = false hat.Parent = char
    table.insert(S.hatParts, hat)
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1033714"
    mesh.Scale = Vector3.new(1.7,1.1,1.7)
    mesh.Parent = hat
    table.insert(S.hatParts, mesh)
    local weld = Instance.new("Weld")
    weld.Part0 = head weld.Part1 = hat
    weld.C0 = CFrame.new(0,0.9,0)
    weld.Parent = hat
    table.insert(S.hatParts, weld)
    local light = Instance.new("PointLight")
    light.Color = Visual.ChinaHatColor
    light.Brightness = 1 light.Range = 12 light.Shadows = true
    light.Parent = hat
    table.insert(S.hatParts, light)
end

local function applyHeadless()
    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    if Visual.Headless then
        if S.headOrig == nil then S.headOrig = head.Transparency end
        head.Transparency = 1
    else
        head.Transparency = S.headOrig or 0
        S.headOrig = nil
    end
end

local function saveLegProps()
    S.legOrig = {}
    local char = LocalPlayer.Character
    if not char then return end
    local rll = char:FindFirstChild("RightLowerLeg")
    local rul = char:FindFirstChild("RightUpperLeg")
    local rf  = char:FindFirstChild("RightFoot")
    if rll then S.legOrig.RLL = { MeshId = rll.MeshId, Trans = rll.Transparency } end
    if rul then S.legOrig.RUL = { MeshId = rul.MeshId, TexId = rul.TextureID } end
    if rf  then S.legOrig.RF  = { MeshId = rf.MeshId,  Trans = rf.Transparency } end
end
local function applyKorblox()
    local char = LocalPlayer.Character
    if not char then return end
    local rll = char:FindFirstChild("RightLowerLeg")
    local rul = char:FindFirstChild("RightUpperLeg")
    local rf  = char:FindFirstChild("RightFoot")
    if Visual.Korblox then
        if rll then rll.MeshId = "http://www.roblox.com/asset/?id=902942093" rll.Transparency = 1 end
        if rul then rul.MeshId = "http://www.roblox.com/asset/?id=902942096" rul.TextureID = "http://www.roblox.com/asset/?id=902843398" end
        if rf  then rf.MeshId  = "http://www.roblox.com/asset/?id=902942089" rf.Transparency  = 1 end
    else
        if rll and S.legOrig.RLL then rll.MeshId = S.legOrig.RLL.MeshId rll.Transparency = S.legOrig.RLL.Trans end
        if rul and S.legOrig.RUL then rul.MeshId = S.legOrig.RUL.MeshId rul.TextureID = S.legOrig.RUL.TexId end
        if rf  and S.legOrig.RF  then rf.MeshId  = S.legOrig.RF.MeshId   rf.Transparency  = S.legOrig.RF.Trans end
    end
end

local function setupKillEffect()
    for _, c in ipairs(S.killConns) do if c then c:Disconnect() end end
    S.killConns = {}
    if not Visual.KillEffect then return end
    local function onDeath(victim, victimChar)
        if victim == LocalPlayer then return end
        if not isLocalMurderer() and not isLocalSheriff() then return end
        local hrp = victimChar and victimChar:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local clone = victimChar:Clone()
        local cloneHrp = clone:FindFirstChild("HumanoidRootPart")
        if cloneHrp then cloneHrp.Transparency = 1 end
        for _, part in ipairs(clone:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                if part.Name ~= "HumanoidRootPart" then
                    part.Anchored = true part.CanCollide = false
                    part.Material = Enum.Material.Neon
                    part.Color = Visual.KillEffectColor
                    part.Transparency = 0
                    if part:IsA("MeshPart") then part.TextureID = "" end
                end
            elseif part:IsA("Decal") or part:IsA("Texture") then part:Destroy()
            elseif part:IsA("Script") or part:IsA("LocalScript") or part:IsA("ModuleScript") then part:Destroy()
            elseif part:IsA("Humanoid") or part:IsA("Tool") then part:Destroy() end
        end
        for _, w in ipairs(clone:GetDescendants()) do
            if w:IsA("Weld") or w:IsA("Motor6D") then w:Destroy() end
        end
        for _, part in ipairs(clone:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then part.Anchored = true end
        end
        pcall(function() clone:SetPrimaryPartCFrame(hrp.CFrame) end)
        clone.Parent = workspace
        task.spawn(function()
            for i = 1, 60 do
                task.wait(2/60)
                for _, part in ipairs(clone:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("MeshPart") then
                        part.Transparency = math.min(1, part.Transparency + 1/60)
                    end
                end
            end
            clone:Destroy()
        end)
    end
    local function bindChar(plr, char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            table.insert(S.killConns, hum.Died:Connect(function() onDeath(plr, char) end))
        end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if plr.Character then bindChar(plr, plr.Character) end
            table.insert(S.killConns, plr.CharacterAdded:Connect(function(char)
                task.wait(0.3)
                if Visual.KillEffect then bindChar(plr, char) end
            end))
        end
    end
    table.insert(S.killConns, Players.PlayerAdded:Connect(function(plr)
        table.insert(S.killConns, plr.CharacterAdded:Connect(function(char)
            task.wait(0.3)
            if Visual.KillEffect then bindChar(plr, char) end
        end))
    end))
end

-- ============================================================
--  RTX / SKY / WEATHER
-- ============================================================
local function applyRTX()
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj.Name:find("RTX Shaders") then obj:Destroy() end
    end
    if not Visual.RTX then
        if S.rtxOrig then
            Lighting.Brightness            = S.rtxOrig.Brightness
            Lighting.ColorShift_Bottom     = S.rtxOrig.ColorShift_Bottom
            Lighting.ColorShift_Top        = S.rtxOrig.ColorShift_Top
            Lighting.OutdoorAmbient        = S.rtxOrig.OutdoorAmbient
            Lighting.ClockTime             = S.rtxOrig.ClockTime
            Lighting.FogColor              = S.rtxOrig.FogColor
            Lighting.FogEnd                = S.rtxOrig.FogEnd
            Lighting.FogStart              = S.rtxOrig.FogStart
            Lighting.ExposureCompensation  = S.rtxOrig.ExposureCompensation
            Lighting.ShadowSoftness        = S.rtxOrig.ShadowSoftness
            Lighting.Ambient               = S.rtxOrig.Ambient
            S.rtxOrig = nil
        end
        return
    end
    if not S.rtxOrig then
        S.rtxOrig = {
            Brightness=S.Lighting and nil or Lighting.Brightness,
            ColorShift_Bottom=Lighting.ColorShift_Bottom,
            ColorShift_Top=Lighting.ColorShift_Top,
            OutdoorAmbient=Lighting.OutdoorAmbient,
            ClockTime=Lighting.ClockTime,
            FogColor=Lighting.FogColor,
            FogEnd=Lighting.FogEnd,
            FogStart=Lighting.FogStart,
            ExposureCompensation=Lighting.ExposureCompensation,
            ShadowSoftness=Lighting.ShadowSoftness,
            Ambient=Lighting.Ambient,
        }
    end
    local bloom = Instance.new("BloomEffect")
    bloom.Name = "Bloom (RTX Shaders)"
    bloom.Intensity = 0.1 bloom.Threshold = 0 bloom.Size = 100
    bloom.Parent = Lighting
    local tropic = Instance.new("Sky")
    tropic.Name = "Tropic (RTX Shaders)"
    tropic.SkyboxUp = "http://www.roblox.com/asset/?id=169210149"
    tropic.SkyboxLf = "http://www.roblox.com/asset/?id=169210133"
    tropic.SkyboxBk = "http://www.roblox.com/asset/?id=169210090"
    tropic.SkyboxFt = "http://www.roblox.com/asset/?id=169210121"
    tropic.StarCount = 100
    tropic.SkyboxDn = "http://www.roblox.com/asset/?id=169210108"
    tropic.SkyboxRt = "http://www.roblox.com/asset/?id=169210143"
    tropic.Parent = bloom
    local sunset = Instance.new("Sky")
    sunset.Name = "Sunset (RTX Shaders)"
    sunset.SkyboxUp = "rbxassetid://323493360"
    sunset.SkyboxLf = "rbxassetid://323494252"
    sunset.SkyboxBk = "rbxassetid://323494035"
    sunset.SkyboxFt = "rbxassetid://323494130"
    sunset.SkyboxDn = "rbxassetid://323494368"
    sunset.SunAngularSize = 14
    sunset.SkyboxRt = "rbxassetid://323494067"
    sunset.Parent = Lighting
    Lighting.Brightness           = 2.14
    Lighting.ColorShift_Bottom    = Color3.fromRGB(11,0,20)
    Lighting.ColorShift_Top       = Color3.fromRGB(240,127,14)
    Lighting.OutdoorAmbient       = Color3.fromRGB(34,0,49)
    Lighting.ClockTime            = 6.7
    Lighting.FogColor             = Color3.fromRGB(94,76,106)
    Lighting.FogEnd               = 1000
    Lighting.FogStart             = 0
    Lighting.ExposureCompensation = 0.24
    Lighting.ShadowSoftness       = 0
    Lighting.Ambient              = Color3.fromRGB(59,33,27)
end

local SKYBOXES = {
    Sunset    = { Bk="http://www.roblox.com/asset/?id=458016711", Dn="http://www.roblox.com/asset/?id=458016826", Ft="http://www.roblox.com/asset/?id=458016532", Lf="http://www.roblox.com/asset/?id=458016655", Rt="http://www.roblox.com/asset/?id=458016782", Up="http://www.roblox.com/asset/?id=458016792" },
    Night     = { Bk="rbxassetid://48020371", Dn="rbxassetid://48020144", Ft="rbxassetid://48020234", Lf="rbxassetid://48020211", Rt="rbxassetid://48020254", Up="rbxassetid://48020383" },
    Minecraft = { Bk="rbxassetid://1876545003", Dn="rbxassetid://1876544331", Ft="rbxassetid://1876542941", Lf="rbxassetid://1876543392", Rt="rbxassetid://1876543764", Up="rbxassetid://1876544642" },
    Evening   = { Bk="http://www.roblox.com/asset/?id=7950569153", Dn="http://www.roblox.com/asset/?id=7950570785", Ft="http://www.roblox.com/asset/?id=7950572449", Lf="http://www.roblox.com/asset/?id=7950573918", Rt="http://www.roblox.com/asset/?id=7950575055", Up="http://www.roblox.com/asset/?id=7950627627" },
    Purple    = { Bk="rbxassetid://159454299", Dn="rbxassetid://159454296", Ft="rbxassetid://159454293", Lf="rbxassetid://159454286", Rt="rbxassetid://159454300", Up="rbxassetid://159454288" },
    Pink      = { Bk="rbxassetid://271042516", Dn="rbxassetid://271077243", Ft="rbxassetid://271042556", Lf="rbxassetid://271042310", Rt="rbxassetid://271042467", Up="rbxassetid://271077958" },
    Chill     = { Bk="rbxassetid://5084575798", Dn="rbxassetid://5084575916", Ft="rbxassetid://5103949679", Lf="rbxassetid://5103948542", Rt="rbxassetid://5103948784", Up="rbxassetid://5084576400" },
}
local function applySky()
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if Visual.SkyOn then
        if not S.skyOrig then
            if sky then S.skyOrig = { Bk=sky.SkyboxBk, Dn=sky.SkyboxDn, Ft=sky.SkyboxFt, Lf=sky.SkyboxLf, Rt=sky.SkyboxRt, Up=sky.SkyboxUp } end
        end
        if not sky then sky = Instance.new("Sky") sky.Parent = Lighting end
        local data = SKYBOXES[Visual.SkyType]
        if data then
            sky.SkyboxBk=data.Bk sky.SkyboxDn=data.Dn sky.SkyboxFt=data.Ft
            sky.SkyboxLf=data.Lf sky.SkyboxRt=data.Rt sky.SkyboxUp=data.Up
        end
    else
        if S.skyOrig and sky then
            sky.SkyboxBk=S.skyOrig.Bk sky.SkyboxDn=S.skyOrig.Dn sky.SkyboxFt=S.skyOrig.Ft
            sky.SkyboxLf=S.skyOrig.Lf sky.SkyboxRt=S.skyOrig.Rt sky.SkyboxUp=S.skyOrig.Up
        end
        S.skyOrig = nil
    end
end

local WEATHER_CONFIGS = {
    Rain = { BaseRate=1500, Texture="rbxassetid://1822883048", Speed=NumberRange.new(120,180), Lifetime=NumberRange.new(2.5,3.5), Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.8),NumberSequenceKeypoint.new(0.5,0.9),NumberSequenceKeypoint.new(1,0.7)}), SpreadAngle=Vector2.new(12,12), Acceleration=Vector3.new(0,-30,0), Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.1),NumberSequenceKeypoint.new(0.7,0.3),NumberSequenceKeypoint.new(1,1)}), EmissionDirection=Enum.NormalId.Bottom, LightEmission=0.3, LightInfluence=0.4 },
    Snow = { BaseRate=150, Texture="rbxassetid://605668174", SpreadAngle=Vector2.new(40,40), Speed=NumberRange.new(8,20), Lifetime=NumberRange.new(12,18), Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.6),NumberSequenceKeypoint.new(0.5,0.9),NumberSequenceKeypoint.new(1,0.7)}), Rotation=NumberRange.new(-180,180), RotSpeed=NumberRange.new(-60,60), Acceleration=Vector3.new(0,-6,0), Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.15),NumberSequenceKeypoint.new(0.8,0.4),NumberSequenceKeypoint.new(1,1)}), EmissionDirection=Enum.NormalId.Bottom, LightEmission=0.4, LightInfluence=0.3 },
    LightRain = { BaseRate=600, Texture="rbxasset://textures/particles/sparkles_main.dds", Speed=NumberRange.new(70,110), Lifetime=NumberRange.new(3,4), Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.35),NumberSequenceKeypoint.new(0.5,0.4),NumberSequenceKeypoint.new(1,0.3)}), SpreadAngle=Vector2.new(8,8), Acceleration=Vector3.new(0,-18,0), Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(0.7,0.5),NumberSequenceKeypoint.new(1,1)}), EmissionDirection=Enum.NormalId.Bottom, LightEmission=0.5, LightInfluence=0.3 },
}
local function applyWeather()
    if S.weatherPart    then S.weatherPart:Destroy()    S.weatherPart = nil    end
    if S.weatherEmitter then S.weatherEmitter:Destroy() S.weatherEmitter = nil end
    if S.weatherConn    then S.weatherConn:Disconnect() S.weatherConn = nil    end
    if not Visual.WeatherOn then return end
    local part = Instance.new("Part")
    part.Size = Vector3.new(200,1,200)
    part.CanCollide = false part.Massless = true part.CastShadow = false
    part.Transparency = 1 part.Anchored = true part.Name = "WeatherPart"
    part.Parent = workspace
    S.weatherPart = part
    local cfg = WEATHER_CONFIGS[Visual.WeatherType]
    if not cfg then return end
    local emitter = Instance.new("ParticleEmitter")
    emitter.Parent = part
    emitter.Color = ColorSequence.new(Visual.WeatherColor)
    emitter.Rate = cfg.BaseRate * Visual.WeatherIntensity
    emitter.LightEmission = 0 emitter.ZOffset = -1
    for k, v in pairs(cfg) do
        if k ~= "BaseRate" then pcall(function() emitter[k] = v end) end
    end
    S.weatherEmitter = emitter
    S.weatherConn = RunService.Heartbeat:Connect(function()
        if not S.weatherPart or not S.weatherPart.Parent then return end
        local hrp = HRP()
        local cam = workspace.CurrentCamera
        if hrp then S.weatherPart.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y + 50, hrp.Position.Z)
        elseif cam then S.weatherPart.CFrame = cam.CFrame * CFrame.new(0,50,0) end
    end)
end

-- ============================================================
--  CROSSHAIR / TOOLSPIN / FF TOOLS / TEXTURES / LIGHTING
-- ============================================================
local function applyCrosshair()
    for _, l in ipairs(S.crossLines)    do pcall(function() l:Remove() end) end
    for _, o in ipairs(S.crossOutlines) do pcall(function() o:Remove() end) end
    S.crossLines = {} S.crossOutlines = {}
    if S.crossConn then S.crossConn:Disconnect() S.crossConn = nil end
    if not Visual.Crosshair then UserInputService.MouseIconEnabled = true return end
    local hasDrawing = pcall(function() return Drawing.new("Line") end)
    for _, l in ipairs(S.crossLines) do pcall(function() l:Remove() end) end
    S.crossLines = {}
    if not hasDrawing then
        Rayfield:Notify({Title="Visuals", Content="Crosshair needs Drawing API support.", Duration=3, Image=4483362458})
        Visual.Crosshair = false UserInputService.MouseIconEnabled = true return
    end
    UserInputService.MouseIconEnabled = false
    for i = 1, 4 do
        local outline = Drawing.new("Line")
        outline.Thickness = 3 outline.Color = Color3.fromRGB(0,0,0)
        outline.Transparency = 1 outline.Visible = true
        table.insert(S.crossOutlines, outline)
        local line = Drawing.new("Line")
        line.Thickness = 1.5 line.Color = Visual.CrosshairColor
        line.Transparency = 1 line.Visible = true
        table.insert(S.crossLines, line)
    end
    S.crossConn = RunService.RenderStepped:Connect(function()
        if not Visual.Crosshair or #S.crossLines < 4 then return end
        local mouse = UserInputService:GetMouseLocation()
        S.crossRot = S.crossRot + math.rad(2)
        if S.crossRot >= math.pi * 2 then S.crossRot = 0 end
        local gap, size = 6, 12
        local dirs = {
            { from=Vector2.new(0,-gap-size), to=Vector2.new(0,-gap) },
            { from=Vector2.new(0, gap),      to=Vector2.new(0, gap+size) },
            { from=Vector2.new(-gap-size,0), to=Vector2.new(-gap,0) },
            { from=Vector2.new(gap,0),       to=Vector2.new(gap+size,0) },
        }
        local cosR, sinR = math.cos(S.crossRot), math.sin(S.crossRot)
        for i = 1, 4 do
            local ff = dirs[i].from + mouse
            local tt = dirs[i].to + mouse
            local rf = Vector2.new(mouse.X + (ff.X-mouse.X)*cosR - (ff.Y-mouse.Y)*sinR, mouse.Y + (ff.X-mouse.X)*sinR + (ff.Y-mouse.Y)*cosR)
            local rt = Vector2.new(mouse.X + (tt.X-mouse.X)*cosR - (tt.Y-mouse.Y)*sinR, mouse.Y + (tt.X-mouse.X)*sinR + (tt.Y-mouse.Y)*cosR)
            if S.crossOutlines[i] then S.crossOutlines[i].From = rf S.crossOutlines[i].To = rt end
            if S.crossLines[i]    then S.crossLines[i].From    = rf S.crossLines[i].To    = rt end
        end
    end)
end

local function stopToolSpin()
    if S.spinConn then S.spinConn:Disconnect() S.spinConn = nil end
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and S.spinGrip then tool.Grip = S.spinGrip S.spinGrip = nil end
    end
end
local function startToolSpin()
    stopToolSpin()
    if not Visual.ToolSpin then return end
    local angle, elapsed = 0, 0
    S.spinConn = RunService.Heartbeat:Connect(function(dt)
        local char = LocalPlayer.Character if not char then return end
        local tool = char:FindFirstChildOfClass("Tool") if not tool then return end
        if not S.spinGrip then S.spinGrip = tool.Grip end
        elapsed = elapsed + dt
        if Visual.ToolSpinMode == 1 then
            angle = angle + (360 * Visual.ToolSpinSpeed) * dt
            if angle >= 360 then angle = angle - 360 end
            tool.Grip = S.spinGrip * CFrame.Angles(math.rad(angle), 0, 0)
        elseif Visual.ToolSpinMode == 2 then
            angle = angle - (360 * Visual.ToolSpinSpeed) * dt
            if angle <= -360 then angle = angle + 360 end
            tool.Grip = S.spinGrip * CFrame.Angles(math.rad(angle), 0, 0)
        else
            local period = 2 / Visual.ToolSpinSpeed
            local t = (elapsed % period) / period
            local x = 1.70158 * 1.525
            local h = t * 2
            local eased
            if h < 1 then eased = 0.5 * (h*h*((x+1)*h - x))
            else h = h - 2 eased = 0.5 * (h*h*((x+1)*h + x) + 2) end
            local swing = math.sin(eased * math.pi * 2) * 180
            tool.Grip = S.spinGrip * CFrame.Angles(math.rad(swing), 0, 0)
        end
    end)
end
local function bindToolSpin(char)
    if not char then return end
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and Visual.ToolSpin then
            S.spinGrip = nil
            task.wait(0.1)
            startToolSpin()
        end
    end)
    char.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then S.spinGrip = nil end
    end)
end

local function applyFFTools()
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not Visual.FFTools then
        for part, data in pairs(S.ffToolOrig) do
            if part and part.Parent then
                part.Material = data.Material
                part.Color    = data.Color
            end
        end
        S.ffToolOrig = {}
        return
    end
    if not tool then return end
    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            if not S.ffToolOrig[part] then
                S.ffToolOrig[part] = { Material = part.Material, Color = part.Color }
            end
            part.Material = Enum.Material.ForceField
            part.Color    = Visual.FFToolsColor
        end
    end
end

local TEXTURE_THEMES = {
    minecraft = {
        {"Wood","128754006217410"},{"WoodPlanks","8676581022"},{"Brick","8139086777"},{"Cobblestone","17874801808"},
        {"Concrete","9405731606"},{"DiamondPlate","14197861013"},{"Fabric","9744916443"},{"Granite","4714662147"},
        {"Grass","9267183930"},{"Ice","11413423466"},{"Marble","14974016515"},{"Metal","14524282848"},
        {"Sand","11119324718"},{"Slate","7801228489"},
    },
    playboi = {
        {"Wood","14784281899"},{"WoodPlanks","14784281899"},{"Brick","12647798329"},{"Cobblestone","12647798329"},
        {"Concrete","12647798329"},{"DiamondPlate","128808789797567"},{"Fabric","128808789797567"},{"Granite","4722586771"},
        {"Grass","17303981964"},{"Ice","17303981964"},{"Marble","17303981964"},{"Metal","114917525242362"},
        {"Sand","114917525242362"},{"Slate","114917525242362"},
    },
    icey = {
        {"Wood","5933003775"},{"WoodPlanks","5933003775"},{"Brick","17295828838"},{"Cobblestone","11760888310"},
        {"Concrete","109017797659108"},{"DiamondPlate","11760888310"},{"Fabric","140018484507153"},{"Granite","16833201065"},
        {"Grass","140018484507153"},{"Ice","1090177976591089"},{"Marble","62967586"},{"Metal","11760888310"},
        {"Sand","16833201065"},{"Slate","7397414089"},
    },
}
local function clearTextures()
    for _, obj in ipairs(S.texObjects) do pcall(function() obj:Destroy() end) end
    S.texObjects = {}
    for _, mat in ipairs(Enum.Material:GetEnumItems()) do
        pcall(function() MaterialService:SetBaseMaterialOverride(mat, "") end)
    end
end
local function applyTextures()
    clearTextures()
    if not Visual.Textures then return end
    local theme = TEXTURE_THEMES[Visual.TextureTheme]
    if not theme then return end
    for _, entry in ipairs(theme) do
        local matName, id = entry[1], entry[2]
        if not id:find("rbxassetid://") and not id:find("http") then id = "rbxassetid://" .. id end
        pcall(function()
            local variant = Instance.new("MaterialVariant")
            variant.Name = "Texture_" .. matName
            variant.BaseMaterial = Enum.Material[matName]
            variant.ColorMap = id variant.NormalMap = id
            variant.RoughnessMap = id variant.MetalnessMap = id
            variant.StudsPerTile = 5 variant.Parent = MaterialService
            table.insert(S.texObjects, variant)
            MaterialService:SetBaseMaterialOverride(Enum.Material[matName], variant.Name)
        end)
    end
end

local LIGHT_DEFAULTS = { Ambient=nil, FogColor=nil, ClockTime=nil }
local function startLightLoop()
    if S.lightConn then return end
    if LIGHT_DEFAULTS.Ambient == nil then
        LIGHT_DEFAULTS.Ambient   = Lighting.Ambient
        LIGHT_DEFAULTS.FogColor  = Lighting.FogColor
        LIGHT_DEFAULTS.ClockTime = Lighting.ClockTime
    end
    S.lightConn = RunService.Heartbeat:Connect(function()
        if not Visual.LightOn then return end
        if Visual.AmbientOn then Lighting.Ambient   = Visual.AmbientColor end
        if Visual.TimeOn    then Lighting.ClockTime = Visual.TimeValue    end
    end)
end
local function stopLightLoop()
    if S.lightConn then S.lightConn:Disconnect() S.lightConn = nil end
    if LIGHT_DEFAULTS.Ambient then
        Lighting.Ambient   = LIGHT_DEFAULTS.Ambient
        Lighting.ClockTime = LIGHT_DEFAULTS.ClockTime
    end
    if S.ccEffect then S.ccEffect:Destroy() S.ccEffect = nil end
end
local function applyCC()
    if S.ccEffect then S.ccEffect:Destroy() S.ccEffect = nil end
    if not Visual.CCOn then return end
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "CustomColorCorrection"
    cc.Parent = Lighting
    cc.Saturation = Visual.CCSat
    cc.Contrast   = Visual.CCCon
    cc.Brightness = Visual.CCBri
    cc.Enabled = true
    S.ccEffect = cc
end

-- ============================================================
--  FARMING
-- ============================================================
local function restoreNormalGravity()
    local hrp = HRP() if not hrp then return end
    local g = hrp:FindFirstChild("FarmGravity")
    if g then g:Destroy() end
end
local function addFarmGravity()
    local hrp = HRP() if not hrp then return end
    local existing = hrp:FindFirstChild("FarmGravity")
    if existing then existing:Destroy() end
    local bp = Instance.new("BodyPosition")
    bp.Name = "FarmGravity"
    bp.MaxForce = Vector3.new(0, math.huge, 0)
    bp.D = 1000 bp.P = 10000
    bp.Position = hrp.Position
    bp.Parent = hrp
end
local function farmRestoreParts()
    if next(S.farm.orig) == nil then return end
    local char = LocalPlayer.Character
    if not char then S.farm.orig = {} return end
    for part, data in pairs(S.farm.orig) do
        if part and part.Parent then
            part.CanCollide = data.CanCollide
            part.Massless   = data.Massless
        end
    end
    S.farm.orig = {}
end
local function farmStopNoclip()
    if S.farm.noclipConn then S.farm.noclipConn:Disconnect() S.farm.noclipConn = nil end
end
local function farmStartNoclip()
    if S.farm.noclipConn then return end
    S.farm.noclipConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end

function stopFarming()
    if S.farm.holdConn then S.farm.holdConn:Disconnect() S.farm.holdConn = nil end
    if S.farm.tween then pcall(function() S.farm.tween:Cancel() end) S.farm.tween = nil end
    farmStopNoclip()
    if not (S.farm.active or S.farm.laid) then return end
    S.farm.active = false
    farmRestoreParts()
    local hrp = HRP()
    if hrp and S.farm.laid then
        hrp.Velocity    = Vector3.zero
        hrp.RotVelocity = Vector3.zero
        hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 2.5, 0)
    end
    S.farm.laid = false
    local hum = Hum()
    if hum then
        hum.PlatformStand = false
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
    end
    restoreNormalGravity()
end

local function startFarming()
    if S.farm.active then return end
    local hrp, hum = HRP(), Hum()
    if not hrp or not hum then return end
    if LocalPlayer:GetAttribute("Alive") == false then return end
    addFarmGravity()
    S.farm.orig = {}
    local char = LocalPlayer.Character
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            S.farm.orig[part] = { CanCollide = part.CanCollide, Massless = part.Massless }
        end
    end
    hrp.CFrame = hrp.CFrame - Vector3.new(0, 2.5, 0)
    hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(90), 0, 0)
    hum.PlatformStand = true
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    S.farm.laid = true
    S.farm.active = true
end

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        pcall(function()
            local farmType = Farm.Type
            if Farm.On and farmType and not S.farm.allDone and LocalPlayer:GetAttribute("Alive") ~= false then
                local container = findTargetContainer(farmType)
                local item, dist = findNearestItem(container, farmType)
                if item and Farm.On and Farm.Type == farmType then
                    if not S.farm.active then startFarming() end
                    local hrp, hum = HRP(), Hum()
                    if hrp and hum then
                        hrp.Velocity    = Vector3.zero
                        hrp.RotVelocity = Vector3.zero
                        local target = CFrame.new(item.Position - Vector3.new(0,2.5,0)) * CFrame.Angles(math.rad(90), 0, 0)
                        farmStartNoclip()
                        if S.farm.tween then S.farm.tween:Cancel() end
                        local tweenTime = math.max(dist / FARM_SPEED, 0.15)
                        S.farm.tween = TweenService:Create(hrp, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { CFrame = target })
                        S.farm.tween:Play()
                        if S.farm.holdConn then S.farm.holdConn:Disconnect() end
                        S.farm.holdConn = RunService.Heartbeat:Connect(function()
                            if not Farm.On or not hrp.Parent then return end
                            hrp.Velocity    = Vector3.zero
                            hrp.RotVelocity = Vector3.zero
                            local g = hrp:FindFirstChild("FarmGravity")
                            if g and g:IsA("BodyPosition") then g.Position = hrp.Position end
                            local h = Hum() if h then h.PlatformStand = true end
                        end)
                        task.wait(tweenTime + 0.08)
                        if Farm.On and Farm.Type == farmType and item and item.Parent and isItemCollectible(item, farmType) then
                            local d = (hrp.Position - item.Position).Magnitude
                            if d <= 4 then
                                pcall(function() firetouchinterest(hrp, item, 0) end)
                                task.wait(0.03)
                                pcall(function() firetouchinterest(hrp, item, 1) end)
                            end
                        end
                        local checkStart = tick()
                        while Farm.On and Farm.Type == farmType and item and item.Parent and isItemCollectible(item, farmType) and (tick() - checkStart) < 1.5 and LocalPlayer:GetAttribute("Alive") ~= false do
                            RunService.Heartbeat:Wait()
                        end
                        if S.farm.holdConn then S.farm.holdConn:Disconnect() S.farm.holdConn = nil end
                        if S.farm.tween then S.farm.tween:Cancel() S.farm.tween = nil end
                        if hrp.Parent then hrp.Velocity = Vector3.zero hrp.RotVelocity = Vector3.zero end
                    end
                else
                    stopFarming()
                end
            else
                stopFarming()
            end
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if Farm.On and not S.farm.bagBusy and S.farm.allDone and LocalPlayer:GetAttribute("Alive") ~= false then
            S.farm.bagBusy = true
            stopFarming()
            local role = getRole(LocalPlayer)
            if role == "Innocent" and Farm.ResetBag then
                Rayfield:Notify({Title="Bag Full", Content="Resetting character...", Duration=2, Image=4483362458})
                task.wait(0.5)
                local hum = Hum() if hum then hum.Health = 0 end
                task.wait(6)
            elseif role == "Sheriff" and Farm.ShootBag then
                local m = getMurderer()
                if m and m.Character then
                    local tp = targetPart(m.Character)
                    if tp then fireAt(tp, m, true) end
                end
            elseif role == "Murderer" and Farm.KillAllBag then
                Rayfield:Notify({Title="Bag Full", Content="Killing all players...", Duration=2, Image=4483362458})
                killAllAura()
            end
            S.farm.bagBusy = false
        end
    end
end)

setupRoundListeners()

-- ============================================================
--  GUN GRAB / NOCLIP / FLY / VOID / EVADE / ANTIFLING
-- ============================================================
local function grabGun(obj)
    task.spawn(function()
        local start = tick()
        while obj and obj.Parent and (tick() - start) < 5 do
            local c = LocalPlayer.Character if not c then break end
            if equippedGun() then break end
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart") or obj:FindFirstChildWhichIsA("BasePart", true)
            if not part then break end
            for _, n in ipairs({"HumanoidRootPart","RightHand","LeftHand"}) do
                local b = c:FindFirstChild(n)
                if b then
                    pcall(function() firetouchinterest(part, b, 0) end)
                    task.wait(0.02)
                    pcall(function() firetouchinterest(part, b, 1) end)
                end
            end
            task.wait(0.1)
        end
    end)
end

local function setNoClip(state)
    local c = LocalPlayer.Character if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = not state end
    end
end
local function startFly()
    if S.flyConn then return end
    local hrp, hum = HRP(), Hum()
    if not hrp or not hum then return end
    hum.PlatformStand = true
    S.flyBV = Instance.new("BodyVelocity")
    S.flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
    S.flyBV.Parent = hrp
    S.flyBG = Instance.new("BodyGyro")
    S.flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5)
    S.flyBG.P = 1e4
    S.flyBG.Parent = hrp
    S.flyConn = RunService.Heartbeat:Connect(function()
        if not Movement.Fly then return end
        local cur = HRP() if not cur then return end
        if not S.flyBV or not S.flyBV.Parent then return end
        local cam = workspace.CurrentCamera
        local mv = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W)           then mv = mv + cam.CFrame.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)           then mv = mv - cam.CFrame.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)           then mv = mv - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)           then mv = mv + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then mv = mv + Vector3.yAxis         end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then mv = mv - Vector3.yAxis         end
        S.flyBV.Velocity = mv.Magnitude > 0 and mv.Unit * Movement.FlySpeed or Vector3.zero
        S.flyBG.CFrame = cam.CFrame
    end)
end
local function stopFly()
    if S.flyConn then S.flyConn:Disconnect() S.flyConn = nil end
    if S.flyBV then S.flyBV:Destroy() S.flyBV = nil end
    if S.flyBG then S.flyBG:Destroy() S.flyBG = nil end
    local hum = Hum() if hum then hum.PlatformStand = false end
end
local function startVoid()
    if S.voidConn then return end
    S.voidConn = RunService.Heartbeat:Connect(function()
        if not Misc.AntiVoid then return end
        local hrp = HRP() if not hrp then S.safeCF = nil return end
        if hrp.Position.Y >= 10 then S.safeCF = hrp.CFrame
        elseif hrp.Position.Y <= -30 and S.safeCF then
            hrp.CFrame = S.safeCF
            hrp.Velocity = Vector3.zero
        end
    end)
end
local function stopVoid()
    if S.voidConn then S.voidConn:Disconnect() S.voidConn = nil end
    S.safeCF = nil
end

local function getBestEvadePoint(myPos, mPos, mChar)
    local bestPoint, bestScore = nil, -math.huge
    local myChar = LocalPlayer.Character
    for i = 1, 24 do
        local angle = (i / 24) * math.pi * 2
        local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * 40
        local candidate = myPos + offset
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { myChar, mChar }
        local res = workspace:Raycast(myPos, candidate - myPos, params)
        if not res then
            local distToMurderer = (candidate - mPos).Magnitude
            local distToMe       = (candidate - myPos).Magnitude
            local score = distToMurderer - (distToMe * 0.1)
            if score > bestScore then bestScore = score bestPoint = candidate end
        end
    end
    return bestPoint
end

local function evadeTick()
    if not Misc.Evade or isLocalMurderer() then
        if S.evadeBV then S.evadeBV:Destroy() S.evadeBV = nil end
        return
    end
    local my = HRP() if not my then return end
    local m = getMurderer()
    if m and m.Character then
        local mh = m.Character:FindFirstChild("HumanoidRootPart")
        if mh then
            local d = (my.Position - mh.Position).Magnitude
            if d < 35 then
                local evadePoint = getBestEvadePoint(my.Position, mh.Position, m.Character)
                if not evadePoint then
                    local away = (my.Position - mh.Position).Unit
                    evadePoint = my.Position + away * 40
                end
                if not S.evadeBV or not S.evadeBV.Parent then
                    S.evadeBV = Instance.new("BodyVelocity")
                    S.evadeBV.MaxForce = Vector3.new(1e5,1e5,1e5)
                    S.evadeBV.Parent = my
                end
                local dir = (evadePoint - my.Position).Unit
                S.evadeBV.Velocity = dir * 50
                return
            end
        end
    end
    if S.evadeBV then S.evadeBV:Destroy() S.evadeBV = nil end
end

local function startAntiFling()
    if S.antiFlingOn then return end
    S.antiFlingOn = true
    local function off(p)
        if p == LocalPlayer then return end
        local c = p.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if h then h.CanCollide = false end
    end
    for _, p in ipairs(Players:GetPlayers()) do off(p) end
    table.insert(S.antiFlingConns, Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function(c)
            task.wait(0.1)
            if S.antiFlingOn then
                local h = c:FindFirstChild("HumanoidRootPart")
                if h then h.CanCollide = false end
            end
        end)
    end))
end
local function stopAntiFling()
    S.antiFlingOn = false
    local function on(p)
        if p == LocalPlayer then return end
        local c = p.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if h then h.CanCollide = true end
    end
    for _, p in ipairs(Players:GetPlayers()) do on(p) end
    for _, c in ipairs(S.antiFlingConns) do c:Disconnect() end
    S.antiFlingConns = {}
end

-- ============================================================
--  EMOTES / TELEPORT HELPERS
-- ============================================================
local EMOTES = {
    {name="Take the L", id="74430100028293"},
    {name="Gamgam Style", id="129764254213842"},
    {name="Fly", id="77529400769588"},
    {name="Zombie Walk", id="81931167118728"},
    {name="Jamal Brasil", id="83796130837213"},
    {name="Headless Korblox", id="84323682148776"},
    {name="Insane Bug", id="86036950557685"},
    {name="Kick", id="92249489340640"},
    {name="Mini Box", id="113994067684875"},
}
local function playEmote(id)
    local c = LocalPlayer.Character if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid") if not h then return end
    local an = h:FindFirstChildOfClass("Animator") if not an then return end
    if S.emoteTrack then pcall(function() S.emoteTrack:Stop(0.1) end) S.emoteTrack = nil end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. id
    local ok, track = pcall(function() return an:LoadAnimation(anim) end)
    if ok and track then
        track.Priority = Enum.AnimationPriority.Action
        track.Looped = true
        track:Play(0.1)
        S.emoteTrack = track
    end
end

local function teleportLobby()
    local my = HRP() if not my then return false end
    local lobby = workspace:FindFirstChild("RegularLobby")
    if lobby then
        local spawns = lobby:FindFirstChild("Spawns")
        if spawns and #spawns:GetChildren() > 0 then my.CFrame = spawns:GetChildren()[1].CFrame return true end
    end
    for _, obj in ipairs(workspace:GetChildren()) do
        local spawns = obj:FindFirstChild("Spawns")
        if spawns and #spawns:GetChildren() > 0 then my.CFrame = spawns:GetChildren()[1].CFrame return true end
    end
    return false
end
local function teleportMap()
    local my = HRP() if not my then return false end
    local map = findMap() if not map then return false end
    local spawns = map:FindFirstChild("Spawns")
    if not spawns or #spawns:GetChildren() == 0 then return false end
    my.CFrame = spawns:GetChildren()[1].CFrame
    return true
end

-- ============================================================
--  UI - RAYFIELD
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name = "ZHOAN HUB",
    LoadingTitle = "ZHOAN HUB",
    LoadingSubtitle = "MM2",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MM2Hub",
        FileName   = "MM2_Config",
    },
    Discord = {
        Enabled = true,
        Invite  = "2ksQSAnnW6",
        RememberJoins = true,
    },
    KeySystem = false,
})

local Main        = Window:CreateTab("Main",       4483362458)
local Combat      = Window:CreateTab("Combat",     4483362458)
local Visuals     = Window:CreateTab("Visuals",    4483362458)
local ESPTab      = Window:CreateTab("ESP",        4483362458)
local FarmTab     = Window:CreateTab("Farm",       4483362458)
local MovementTab = Window:CreateTab("Movement",   4483362458)
local TeleportTab = Window:CreateTab("Teleport",   4483362458)
local PlayersTab  = Window:CreateTab("Players",    4483362458)
local Emotes      = Window:CreateTab("Emotes",     4483362458)
local Config      = Window:CreateTab("Config",     4483362458)


-- ---------- MAIN ----------
Main:CreateSection("player")
Main:CreateSlider({ Name="Walk Speed", Range={4,150}, Increment=1, Suffix="studs", CurrentValue=16, Flag="WalkSpeed",
    Callback=function(v) Movement.WalkSpeed = v local h = Hum() if h then h.WalkSpeed = v end end })
Main:CreateSlider({ Name="Jump Power", Range={10,200}, Increment=5, Suffix="power", CurrentValue=50, Flag="JumpPower",
    Callback=function(v) Movement.JumpPower = v local h = Hum() if h then h.JumpPower = v h.UseJumpPower = true end end })
PT(Main:CreateToggle({ Name="Infinite Jump", CurrentValue=false, Flag="InfJump", Callback=function(v) Misc.InfJump = v end }))
PT(Main:CreateToggle({ Name="Anti-AFK", CurrentValue=true, Flag="AntiAFK",
    Callback=function(v)
        Misc.AntiAFK = v
        if S.afkConn then S.afkConn:Disconnect() S.afkConn = nil end
        if v then
            local vu = game:GetService("VirtualUser")
            S.afkConn = LocalPlayer.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end }))
Main:CreateSection("safety")
PT(Main:CreateToggle({ Name="Panic Key", CurrentValue=true, Flag="PanicKey", Callback=function(v) Misc.PanicKey = v end }))

-- ---------- COMBAT ----------
Combat:CreateSection("aimbot")
local lockToggle = PT(Combat:CreateToggle({ Name="Aim Lock", CurrentValue=false, Flag="AimLock",
    Callback=function(v)
        Aim.LockOn = v
        if S.lockConn then S.lockConn:Disconnect() S.lockConn = nil end
        if v then
            S.lockConn = RunService.RenderStepped:Connect(function()
                if not Aim.LockOn then return end
                local m = getMurderer()
                if not m or not m.Character then return end
                local tp = targetPart(m.Character) local my = HRP()
                if not tp or not my then return end
                if (my.Position - tp.Position).Magnitude > Aim.Range then return end
                if not canShoot(my.Position, tp.Position, m.Character) then return end
                local cam = workspace.CurrentCamera
                local cf = CFrame.new(cam.CFrame.Position, tp.Position)
                cam.CFrame = cam.CFrame:Lerp(cf, math.clamp(1 / Aim.Smooth, 0.02, 1))
            end)
        end
    end }))
Combat:CreateKeybind({ Name="Aim Lock Key", CurrentKeybind="Q", HoldToInteract=false, Flag="AimLockKey",
    Callback=function() lockToggle:Set(not Aim.LockOn) end })
Combat:CreateSlider({ Name="Smoothness", Range={1,30},   Increment=1,  CurrentValue=8,   Flag="Smooth", Callback=function(v) Aim.Smooth = v end })
Combat:CreateSlider({ Name="Range",      Range={50,1000}, Increment=25, Suffix="studs", CurrentValue=500, Flag="Range",  Callback=function(v) Aim.Range = v end })
Combat:CreateDropdown({ Name="Target Bone", Options={"Head","Torso"}, CurrentOption="Head", Flag="Bone", Callback=function(v) Aim.Bone = v end })
PT(Combat:CreateToggle({ Name="FOV Circle", CurrentValue=false, Flag="FOVCircle",
    Callback=function(v)
        Aim.FOVCircle = v
        if v then
            if not S.fovGui then
                S.fovGui = Instance.new("ScreenGui")
                S.fovGui.Name = "MM2FOV" S.fovGui.ResetOnSpawn = false S.fovGui.IgnoreGuiInset = true
                pcall(function() S.fovGui.Parent = game:GetService("CoreGui") end)
                if not S.fovGui.Parent then S.fovGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
                local f = Instance.new("Frame")
                f.Name = "Circle" f.BackgroundTransparency = 1 f.AnchorPoint = Vector2.new(0.5,0.5)
                f.Size = UDim2.new(0, Aim.FOVRadius*2, 0, Aim.FOVRadius*2)
                f.Position = UDim2.new(0.5,0,0.5,0) f.Parent = S.fovGui
                local st = Instance.new("UIStroke")
                st.Thickness = 2 st.Color = Color3.fromRGB(255,255,255) st.Transparency = 0.3 st.Parent = f
                local co = Instance.new("UICorner")
                co.CornerRadius = UDim.new(1,0) co.Parent = f
            end
            S.fovGui.Enabled = true
        else
            if S.fovGui then S.fovGui.Enabled = false end
        end
    end }))
Combat:CreateSlider({ Name="FOV Radius", Range={40,500}, Increment=10, Suffix="px", CurrentValue=120, Flag="FOVRadius",
    Callback=function(v)
        Aim.FOVRadius = v
        if S.fovGui then
            local f = S.fovGui:FindFirstChild("Circle")
            if f then f.Size = UDim2.new(0, v*2, 0, v*2) end
        end
    end })

Combat:CreateSection("trigger")
PT(Combat:CreateToggle({ Name="Trigger Bot", CurrentValue=false, Flag="Trigger",
    Callback=function(v)
        Aim.Trigger = v
        if S.triggerConn then S.triggerConn:Disconnect() S.triggerConn = nil end
        if v then
            local last = 0
            S.triggerConn = RunService.RenderStepped:Connect(function()
                if not Aim.Trigger then return end
                if not isLocalSheriff() then return end
                local m = getMurderer()
                if not m or not m.Character then return end
                local tp = targetPart(m.Character) local my = HRP()
                if not tp or not my then return end
                if (my.Position - tp.Position).Magnitude > Aim.TriggerRange then return end
                local cam = workspace.CurrentCamera
                local sp, on = cam:WorldToViewportPoint(tp.Position)
                if not on or sp.Z < 0 then return end
                local mouse = UserInputService:GetMouseLocation()
                if (Vector2.new(sp.X, sp.Y) - mouse).Magnitude > 28 then return end
                if not canShoot(my.Position, tp.Position, m.Character) then return end
                local now = tick() if now - last < 0.15 then return end
                last = now
                fireAt(tp, m, false)
            end)
        end
    end }))
Combat:CreateSlider({ Name="Trigger Range", Range={20,500}, Increment=10, Suffix="studs", CurrentValue=300, Flag="TriggerRange", Callback=function(v) Aim.TriggerRange = v end })
PT(Combat:CreateToggle({ Name="Auto Fire", CurrentValue=false, Flag="AutoFire",
    Callback=function(v)
        Aim.AutoFire = v
        if S.fireConn then S.fireConn:Disconnect() S.fireConn = nil end
        if v then
            local last = 0
            S.fireConn = RunService.RenderStepped:Connect(function()
                if not Aim.AutoFire then return end
                local m = getMurderer()
                if not m or not m.Character then return end
                local tp = targetPart(m.Character) local my = HRP()
                if not tp or not my then return end
                if not canShoot(my.Position, tp.Position, m.Character) then return end
                local now = tick() if now - last < 0.15 then return end
                last = now
                fireAt(tp, m, false)
            end)
        end
    end }))
PT(Combat:CreateToggle({ Name="Silent Aim", CurrentValue=false, Flag="SilentAim", Callback=function(v) Misc.SilentAim = v end }))

Combat:CreateSection("sheriff")
PT(Combat:CreateToggle({ Name="Auto Kill Murderer", CurrentValue=false, Flag="AutoKill",
    Callback=function(v)
        Aim.AutoKill = v
        if S.killConn then S.killConn:Disconnect() S.killConn = nil end
        if v then
            local last = 0
            S.killConn = RunService.RenderStepped:Connect(function()
                if not Aim.AutoKill then return end
                if not isLocalSheriff() then return end
                local m = getMurderer()
                if not m or not m.Character then return end
                local tp = targetPart(m.Character)
                local mh = m.Character:FindFirstChild("HumanoidRootPart")
                if not tp or not mh then return end
                local gun = equippedGun() if not gun then return end
                local rem = shootRemote(gun) if not rem then return end
                local now = tick() if now - last < 0.15 then return end
                last = now
                local origin = CFrame.new(tp.Position + Vector3.new(0,3,0), tp.Position)
                local cf = predict(tp, HRP()) or CFrame.new(tp.Position)
                pcall(function() rem:FireServer(origin, cf) end)
            end)
        end
    end }))
Combat:CreateToggle({ Name="Wall Check", CurrentValue=true, Flag="WallCheck", Callback=function(v) Aim.WallCheck = v end })
Combat:CreateButton({ Name="Shoot Murderer",
    Callback=function()
        local m = getMurderer()
        if not m or not m.Character then
            Rayfield:Notify({Title="Combat", Content="No murderer found.", Duration=2, Image=4483362458}) return
        end
        local tp = targetPart(m.Character)
        if tp and fireAt(tp, m, false) then
            Rayfield:Notify({Title="Combat", Content="Shot fired.", Duration=2, Image=4483362458})
        else
            Rayfield:Notify({Title="Combat", Content="Could not fire.", Duration=2, Image=4483362458})
        end
    end })
PT(Combat:CreateToggle({ Name="Auto Get Dropped Gun", CurrentValue=false, Flag="AutoGun",
    Callback=function(v)
        Misc.AutoGun = v
        if v then
            task.spawn(function()
                task.wait(0.2)
                local g = findGunDrop()
                if g and not equippedGun() then grabGun(g) end
            end)
        end
    end }))
Combat:CreateButton({ Name="Grab Dropped Gun",
    Callback=function()
        local g = findGunDrop()
        if g then
            grabGun(g)
            Rayfield:Notify({Title="Combat", Content="Grabbing gun.", Duration=2, Image=4483362458})
        else
            Rayfield:Notify({Title="Combat", Content="No dropped gun found.", Duration=2, Image=4483362458})
        end
    end })

Combat:CreateSection("murderer")
PT(Combat:CreateToggle({ Name="Auto Knife Throw", CurrentValue=false, Flag="AutoThrow",
    Callback=function(v)
        Aim.AutoThrow = v
        if S.throwConn then S.throwConn:Disconnect() S.throwConn = nil end
        if v then
            local last = 0
            S.throwConn = RunService.Heartbeat:Connect(function()
                if not Aim.AutoThrow then return end
                if not isLocalMurderer() then return end
                local now = tick() if now - last < 1.5 then return end
                local t, d = nearestVictim()
                if t and d < 200 then if throwKnifeAt(t) then last = now end end
            end)
        end
    end }))
Combat:CreateButton({ Name="Knife Throw",
    Callback=function()
        if not isLocalMurderer() then
            Rayfield:Notify({Title="Combat", Content="You are not the murderer.", Duration=2, Image=4483362458}) return
        end
        local t = nearestVictim()
        if not t then
            Rayfield:Notify({Title="Combat", Content="No players nearby.", Duration=2, Image=4483362458}) return
        end
        local ok = throwKnifeAt(t)
        Rayfield:Notify({Title="Combat", Content=ok and ("Knife thrown at " .. t.Name) or "Knife remote not found.", Duration=2, Image=4483362458})
    end })
Combat:CreateButton({ Name="Kill Everyone",
    Callback=function()
        if not isLocalMurderer() then
            Rayfield:Notify({Title="Combat", Content="You are not the murderer.", Duration=2, Image=4483362458}) return
        end
        if killAllAura() then
            Rayfield:Notify({Title="Combat", Content="Kill aura active for 5 seconds.", Duration=2, Image=4483362458})
        else
            Rayfield:Notify({Title="Combat", Content="No knife equipped.", Duration=2, Image=4483362458})
        end
    end })

-- ---------- VISUALS ----------
Visuals:CreateSection("character visuals")
PT(Visuals:CreateToggle({ Name="Force Field Body", CurrentValue=false, Flag="ForceField", Callback=function(v) Visual.ForceField = v applyForceField() end }))
Visuals:CreateColorPicker({ Name="Force Field Color", Color=Color3.fromRGB(0,170,255), Flag="FFColor",
    Callback=function(c) Visual.ForceFieldColor = c if Visual.ForceField then applyForceField() end end })
PT(Visuals:CreateToggle({ Name="Character Aura", CurrentValue=false, Flag="AuraOn", Callback=function(v) Visual.AuraOn = v applyAuras() end }))
Visuals:CreateDropdown({ Name="Aura Types",
    Options={"angel","starlight","heavenly","ribbon","sakura","wind","flow","star"},
    CurrentOption={}, MultipleOptions=true, Flag="AuraSel",
    Callback=function(list)
        Visual.AuraSel = {}
        for _, name in ipairs(list) do Visual.AuraSel[name] = true end
        if Visual.AuraOn then applyAuras() end
    end })
PT(Visuals:CreateToggle({ Name="Kill Effect", CurrentValue=false, Flag="KillEffect", Callback=function(v) Visual.KillEffect = v setupKillEffect() end }))
Visuals:CreateColorPicker({ Name="Kill Effect Color", Color=Color3.fromRGB(255,0,0), Flag="KillColor", Callback=function(c) Visual.KillEffectColor = c end })
PT(Visuals:CreateToggle({ Name="China Hat", CurrentValue=false, Flag="ChinaHat", Callback=function(v) Visual.ChinaHat = v applyChinaHat() end }))
Visuals:CreateColorPicker({ Name="China Hat Color", Color=Color3.fromRGB(255,123,123), Flag="HatColor",
    Callback=function(c) Visual.ChinaHatColor = c if Visual.ChinaHat then applyChinaHat() end end })

Visuals:CreateSection("character modifications")
PT(Visuals:CreateToggle({ Name="Headless", CurrentValue=false, Flag="Headless", Callback=function(v) Visual.Headless = v applyHeadless() end }))
PT(Visuals:CreateToggle({ Name="Korblox Leg", CurrentValue=false, Flag="Korblox", Callback=function(v) Visual.Korblox = v applyKorblox() end }))

Visuals:CreateSection("sky & weather")
PT(Visuals:CreateToggle({ Name="RTX Shaders", CurrentValue=false, Flag="RTX", Callback=function(v) Visual.RTX = v applyRTX() end }))
PT(Visuals:CreateToggle({ Name="Custom Sky", CurrentValue=false, Flag="SkyOn", Callback=function(v) Visual.SkyOn = v applySky() end }))
Visuals:CreateDropdown({ Name="Sky Theme", Options={"Sunset","Night","Minecraft","Evening","Purple","Pink","Chill"}, CurrentOption="Sunset", Flag="SkyType",
    Callback=function(v) Visual.SkyType = v if Visual.SkyOn then applySky() end end })
PT(Visuals:CreateToggle({ Name="Weather Effect", CurrentValue=false, Flag="WeatherOn", Callback=function(v) Visual.WeatherOn = v applyWeather() end }))
Visuals:CreateDropdown({ Name="Weather Type", Options={"LightRain","Rain","Snow"}, CurrentOption="LightRain", Flag="WeatherType",
    Callback=function(v) Visual.WeatherType = v if Visual.WeatherOn then applyWeather() end end })
Visuals:CreateColorPicker({ Name="Weather Color", Color=Color3.fromRGB(200,200,255), Flag="WeatherColor",
    Callback=function(c) Visual.WeatherColor = c if Visual.WeatherOn then applyWeather() end end })
Visuals:CreateSlider({ Name="Weather Intensity", Range={0.1,10}, Increment=0.1, Suffix="x", CurrentValue=1, Flag="WeatherInt",
    Callback=function(v)
        Visual.WeatherIntensity = v
        if S.weatherEmitter and S.weatherEmitter.Parent then
            local cfg = WEATHER_CONFIGS[Visual.WeatherType]
            if cfg then S.weatherEmitter.Rate = cfg.BaseRate * v end
        end
    end })

Visuals:CreateSection("tool manipulations")
PT(Visuals:CreateToggle({ Name="Tool Spin", CurrentValue=false, Flag="ToolSpin", Callback=function(v) Visual.ToolSpin = v if v then startToolSpin() else stopToolSpin() end end }))
Visuals:CreateDropdown({ Name="Spin Mode", Options={"360 Forward","360 Back","Forward then Back"}, CurrentOption="360 Forward", Flag="SpinMode",
    Callback=function(v)
        Visual.ToolSpinMode = v == "360 Forward" and 1 or v == "360 Back" and 2 or 3
        if Visual.ToolSpin then startToolSpin() end
    end })
Visuals:CreateSlider({ Name="Spin Speed", Range={0.1,5}, Increment=0.1, Suffix="rps", CurrentValue=1, Flag="SpinSpeed",
    Callback=function(v) Visual.ToolSpinSpeed = v if Visual.ToolSpin then startToolSpin() end end })
PT(Visuals:CreateToggle({ Name="Force Field Tools", CurrentValue=false, Flag="FFTools", Callback=function(v) Visual.FFTools = v applyFFTools() end }))
Visuals:CreateColorPicker({ Name="Force Field Tools Color", Color=Color3.fromRGB(255,0,255), Flag="FFToolColor",
    Callback=function(c) Visual.FFToolsColor = c if Visual.FFTools then applyFFTools() end end })

Visuals:CreateSection("material textures")
PT(Visuals:CreateToggle({ Name="Material Textures", CurrentValue=false, Flag="Textures", Callback=function(v) Visual.Textures = v applyTextures() end }))
Visuals:CreateDropdown({ Name="Texture Pack", Options={"minecraft","playboi","icey"}, CurrentOption="minecraft", Flag="TexTheme",
    Callback=function(v) Visual.TextureTheme = v if Visual.Textures then applyTextures() end end })

Visuals:CreateSection("lighting & effects")
PT(Visuals:CreateToggle({ Name="Custom Lighting", CurrentValue=false, Flag="LightOn", Callback=function(v) Visual.LightOn = v if v then startLightLoop() else stopLightLoop() end end }))
PT(Visuals:CreateToggle({ Name="Custom Ambient", CurrentValue=false, Flag="AmbientOn", Callback=function(v) Visual.AmbientOn = v end }))
Visuals:CreateColorPicker({ Name="Ambient Color", Color=Color3.fromRGB(255,123,123), Flag="AmbientColor", Callback=function(c) Visual.AmbientColor = c end })
PT(Visuals:CreateToggle({ Name="Custom Time", CurrentValue=false, Flag="TimeOn", Callback=function(v) Visual.TimeOn = v end }))
Visuals:CreateSlider({ Name="Time Value", Range={0,24}, Increment=0.5, Suffix="h", CurrentValue=12, Flag="TimeValue", Callback=function(v) Visual.TimeValue = v end })
PT(Visuals:CreateToggle({ Name="Color Correction", CurrentValue=false, Flag="CCOn", Callback=function(v) Visual.CCOn = v applyCC() end }))
Visuals:CreateSlider({ Name="Saturation", Range={-1,1}, Increment=0.05, CurrentValue=0, Flag="CCSat", Callback=function(v) Visual.CCSat = v if S.ccEffect then S.ccEffect.Saturation = v end end })
Visuals:CreateSlider({ Name="Contrast",   Range={-1,1}, Increment=0.05, CurrentValue=0, Flag="CCCon", Callback=function(v) Visual.CCCon = v if S.ccEffect then S.ccEffect.Contrast   = v end end })
Visuals:CreateSlider({ Name="Brightness", Range={-1,1}, Increment=0.05, CurrentValue=0, Flag="CCBri", Callback=function(v) Visual.CCBri = v if S.ccEffect then S.ccEffect.Brightness = v end end })

Visuals:CreateSection("crosshair")
PT(Visuals:CreateToggle({ Name="Custom Crosshair", CurrentValue=false, Flag="Crosshair", Callback=function(v) Visual.Crosshair = v applyCrosshair() end }))
Visuals:CreateColorPicker({ Name="Crosshair Color", Color=Color3.fromRGB(255,255,255), Flag="CrossColor",
    Callback=function(c)
        Visual.CrosshairColor = c
        for _, line in ipairs(S.crossLines) do if line then line.Color = c end end
    end })

-- ---------- ESP ----------
ESPTab:CreateSection("player esp")
PT(ESPTab:CreateToggle({ Name="Player ESP", CurrentValue=false, Flag="PlayerESP", Callback=function(v) ESPS.PlayerESP = v refreshESP() end }))
ESPTab:CreateDropdown({ Name="Player ESP Roles", Options={"Murderer","Sheriff","Innocent","Hero"},
    CurrentOption={"Murderer","Sheriff","Innocent","Hero"}, MultipleOptions=true, Flag="PlayerESPRoles",
    Callback=function(list)
        ESPS.PlayerESPRoles = { Murderer=false, Sheriff=false, Innocent=false, Hero=false }
        for _, r in ipairs(list) do ESPS.PlayerESPRoles[r] = true end
        refreshESP()
    end })
ESPTab:CreateSection("name tags")
PT(ESPTab:CreateToggle({ Name="Name ESP", CurrentValue=false, Flag="NameESP", Callback=function(v) ESPS.NameESP = v refreshESP() end }))
ESPTab:CreateDropdown({ Name="Name ESP Roles", Options={"Murderer","Sheriff","Innocent","Hero"},
    CurrentOption={"Murderer","Sheriff","Innocent","Hero"}, MultipleOptions=true, Flag="NameRoles",
    Callback=function(list)
        ESPS.NameRoles = { Murderer=false, Sheriff=false, Innocent=false, Hero=false }
        for _, r in ipairs(list) do ESPS.NameRoles[r] = true end
        refreshESP()
    end })
ESPTab:CreateDropdown({ Name="Tag Options", Options={"2D Box","Display Name","Username","Avatar"},
    CurrentOption={"Username"}, MultipleOptions=true, Flag="TagOpts",
    Callback=function(list)
        ESPS.Box2D = false ESPS.DisplayName = false ESPS.Username = false ESPS.Avatar = false
        for _, opt in ipairs(list) do
            if     opt == "2D Box"       then ESPS.Box2D       = true
            elseif opt == "Display Name" then ESPS.DisplayName = true
            elseif opt == "Username"     then ESPS.Username    = true
            elseif opt == "Avatar"       then ESPS.Avatar      = true end
        end
        refreshESP()
    end })
ESPTab:CreateSection("role colors")
ESPTab:CreateColorPicker({ Name="Murderer Color", Color=Color3.fromRGB(255,0,0),   Flag="ColMurderer", Callback=function(c) ROLE_COLORS.Murderer = c refreshESP() end })
ESPTab:CreateColorPicker({ Name="Sheriff Color",  Color=Color3.fromRGB(0,132,255), Flag="ColSheriff",  Callback=function(c) ROLE_COLORS.Sheriff  = c refreshESP() end })
ESPTab:CreateColorPicker({ Name="Innocent Color", Color=Color3.fromRGB(56,255,112),Flag="ColInnocent", Callback=function(c) ROLE_COLORS.Innocent = c refreshESP() end })
ESPTab:CreateColorPicker({ Name="Hero Color",     Color=Color3.fromRGB(255,200,0), Flag="ColHero",     Callback=function(c) ROLE_COLORS.Hero     = c refreshESP() end })
ESPTab:CreateSection("items & beam")
PT(ESPTab:CreateToggle({ Name="Gun ESP", CurrentValue=false, Flag="GunESP", Callback=function(v) ESPS.Gun = v applyGunESP() end }))
PT(ESPTab:CreateToggle({ Name="Coin ESP", CurrentValue=false, Flag="CoinESP", Callback=function(v) ESPS.Coin = v applyItemESP("Coin") end }))
ESPTab:CreateColorPicker({ Name="Coin Color", Color=Color3.fromRGB(255,215,0), Flag="CoinColor", Callback=function(c) ESPS.CoinColor = c if ESPS.Coin then applyItemESP("Coin") end end })
PT(ESPTab:CreateToggle({ Name="Candy ESP", CurrentValue=false, Flag="CandyESP", Callback=function(v) ESPS.Candy = v applyItemESP("Candy") end }))
ESPTab:CreateColorPicker({ Name="Candy Color", Color=Color3.fromRGB(255,105,180), Flag="CandyColor", Callback=function(c) ESPS.CandyColor = c if ESPS.Candy then applyItemESP("Candy") end end })
PT(ESPTab:CreateToggle({ Name="Trap ESP", CurrentValue=false, Flag="TrapESP", Callback=function(v) ESPS.Trap = v end }))
PT(ESPTab:CreateToggle({ Name="Beam to Murderer", CurrentValue=false, Flag="Beam", Callback=function(v) ESPS.Beam = v if v then beamLoop() else beamStop() end end }))

-- ---------- FARM ----------
FarmTab:CreateSection("coin & candy farm")
local coinFarmToggle, candyFarmToggle
local function setFarm(farmType, state)
    if state then
        stopFarming()
        Farm.On = true
        Farm.Type = farmType
        S.farm.container = nil S.farm.containerCheck = 0
        S.farm.allDone = false S.farm.collected = 0 S.farm.total = 0
        S.farm.startTime = os.time() S.farm.bagBusy = false
        if farmType == "Coin"  and candyFarmToggle then candyFarmToggle:Set(false) end
        if farmType == "Candy" and coinFarmToggle  then coinFarmToggle:Set(false)  end
        task.spawn(function()
            task.wait(0.3)
            local c = findTargetContainer(farmType)
            if c then
                local total, collectible = countItems(c, farmType)
                Rayfield:Notify({Title="Farm", Content="Found "..total.." "..farmType:lower().."s ("..collectible.." collectible).", Duration=3, Image=4483362458})
            else
                Rayfield:Notify({Title="Farm", Content="No "..farmType.."Container found. Wait for the round to start.", Duration=3, Image=4483362458})
            end
        end)
    else
        if Farm.Type == farmType then
            Farm.On = false Farm.Type = nil stopFarming()
        end
    end
end
coinFarmToggle  = PT(FarmTab:CreateToggle({ Name="Farm Coins",  CurrentValue=false, Flag="FarmCoins",  Callback=function(v) setFarm("Coin",  v) end }))
candyFarmToggle = PT(FarmTab:CreateToggle({ Name="Farm Candy",  CurrentValue=false, Flag="FarmCandy",  Callback=function(v) setFarm("Candy", v) end }))

FarmTab:CreateSection("bag full actions")
PT(FarmTab:CreateToggle({ Name="Reset When Bag Full",           CurrentValue=false, Flag="BagReset",   Callback=function(v) Farm.ResetBag    = v end }))
PT(FarmTab:CreateToggle({ Name="Shoot Murderer When Bag Full",  CurrentValue=false, Flag="BagShoot",   Callback=function(v) Farm.ShootBag    = v end }))
PT(FarmTab:CreateToggle({ Name="Kill All When Bag Full",        CurrentValue=false, Flag="BagKillAll", Callback=function(v) Farm.KillAllBag  = v end }))

FarmTab:CreateSection("live stats")
local statsPara = FarmTab:CreateParagraph({ Title="Live Stats", Content="Status: Idle\nItems: 0/0\nSession: 00:00:00\nRate: 0/h" })
task.spawn(function()
    while true do
        task.wait(1)
        if Farm.On then
            local elapsed = os.time() - S.farm.startTime
            local hh = math.floor(elapsed / 3600)
            local mm = math.floor((elapsed % 3600) / 60)
            local ss = math.floor(elapsed % 60)
            local statusText = "Waiting"
            if S.farm.allDone then statusText = "All items collected"
            elseif S.farm.active then statusText = "Farming" end
            local rate = 0
            if elapsed > 0 and S.farm.collected > 0 then
                rate = math.floor((S.farm.collected / elapsed) * 3600)
            end
            statsPara:Set({Content=string.format("Status: %s\nItems: %d/%d\nSession: %02d:%02d:%02d\nRate: %d/h", statusText, S.farm.collected, S.farm.total, hh, mm, ss, rate)})
        else
            statsPara:Set({Content="Status: Idle\nItems: 0/0\nSession: 00:00:00\nRate: 0/h"})
        end
    end
end)

-- ---------- MOVEMENT ----------
MovementTab:CreateSection("flight")
PT(MovementTab:CreateToggle({ Name="Fly", CurrentValue=false, Flag="Fly", Callback=function(v) Movement.Fly = v if v then startFly() else stopFly() end end }))
MovementTab:CreateSlider({ Name="Fly Speed", Range={5,200}, Increment=5, CurrentValue=40, Flag="FlySpeed", Callback=function(v) Movement.FlySpeed = v end })
MovementTab:CreateSection("modifiers")
PT(MovementTab:CreateToggle({ Name="Noclip", CurrentValue=false, Flag="Noclip",
    Callback=function(v)
        Movement.Noclip = v
        if S.noclipConn then S.noclipConn:Disconnect() S.noclipConn = nil end
        if v then
            S.noclipConn = RunService.Stepped:Connect(function() setNoClip(true) end)
        else
            if not S.farm.active then setNoClip(false) end
        end
    end }))
PT(MovementTab:CreateToggle({ Name="Auto Evade Murderer", CurrentValue=false, Flag="Evade",
    Callback=function(v) Misc.Evade = v if not v and S.evadeBV then S.evadeBV:Destroy() S.evadeBV = nil end end }))
PT(MovementTab:CreateToggle({ Name="Anti-Void", CurrentValue=false, Flag="AntiVoid", Callback=function(v) Misc.AntiVoid = v if v then startVoid() else stopVoid() end end }))
PT(MovementTab:CreateToggle({ Name="Anti-Fling", CurrentValue=false, Flag="AntiFling", Callback=function(v) Movement.AntiFling = v if v then startAntiFling() else stopAntiFling() end end }))

-- ---------- TELEPORT ----------
TeleportTab:CreateSection("roles")
TeleportTab:CreateButton({ Name="To Murderer",
    Callback=function()
        local m = getMurderer() local my = HRP()
        if m and m.Character and my then
            local h = m.Character:FindFirstChild("HumanoidRootPart")
            if h then my.CFrame = h.CFrame + Vector3.new(0,4,4) end
        else
            Rayfield:Notify({Title="Teleport", Content="No murderer found.", Duration=2, Image=4483362458})
        end
    end })
TeleportTab:CreateButton({ Name="To Sheriff",
    Callback=function()
        local s = getSheriff() local my = HRP()
        if s and s.Character and my then
            local h = s.Character:FindFirstChild("HumanoidRootPart")
            if h then my.CFrame = h.CFrame + Vector3.new(0,4,4) end
        else
            Rayfield:Notify({Title="Teleport", Content="No sheriff found.", Duration=2, Image=4483362458})
        end
    end })
TeleportTab:CreateSection("map")
TeleportTab:CreateButton({ Name="To Dropped Gun",
    Callback=function()
        local g = findGunDrop() local my = HRP()
        if g and my then my.CFrame = g.CFrame + Vector3.new(0,2,0)
        else Rayfield:Notify({Title="Teleport", Content="No dropped gun found.", Duration=2, Image=4483362458}) end
    end })
TeleportTab:CreateButton({ Name="To Lobby",
    Callback=function()
        if not teleportLobby() then
            Rayfield:Notify({Title="Teleport", Content="Lobby spawn not found.", Duration=2, Image=4483362458})
        end
    end })
TeleportTab:CreateButton({ Name="Map TP",
    Callback=function()
        if not teleportMap() then
            Rayfield:Notify({Title="Teleport", Content="Map spawn not found.", Duration=2, Image=4483362458})
        end
    end })

-- ---------- PLAYERS ----------
PlayersTab:CreateSection("spectate")
PlayersTab:CreateButton({ Name="Spectate Murderer",
    Callback=function()
        local m = getMurderer()
        if not m or not m.Character then
            Rayfield:Notify({Title="Spectate", Content="No murderer found.", Duration=2, Image=4483362458}) return
        end
        local h = m.Character:FindFirstChildOfClass("Humanoid")
        if h then
            workspace.CurrentCamera.CameraSubject = h
            Rayfield:Notify({Title="Spectate", Content="Watching "..m.DisplayName, Duration=2, Image=4483362458})
        end
    end })
PlayersTab:CreateButton({ Name="Spectate Sheriff",
    Callback=function()
        local s = getSheriff()
        if not s or not s.Character then
            Rayfield:Notify({Title="Spectate", Content="No sheriff found.", Duration=2, Image=4483362458}) return
        end
        local h = s.Character:FindFirstChildOfClass("Humanoid")
        if h then
            workspace.CurrentCamera.CameraSubject = h
            Rayfield:Notify({Title="Spectate", Content="Watching "..s.DisplayName, Duration=2, Image=4483362458})
        end
    end })
PlayersTab:CreateButton({ Name="Stop Spectating",
    Callback=function()
        local h = Hum() if h then workspace.CurrentCamera.CameraSubject = h end
    end })
PlayersTab:CreateSection("server")
PlayersTab:CreateButton({ Name="Rejoin", Callback=function() pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end) end })
PlayersTab:CreateButton({ Name="Server Hop", Callback=function() pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end) end })
PT(PlayersTab:CreateToggle({ Name="Auto Rejoin", CurrentValue=false, Flag="AutoRejoin",
    Callback=function(v)
        Misc.AutoRejoin = v
        if v then
            Rayfield:Notify({Title="Auto Rejoin", Content="Will reconnect on kick.", Duration=2, Image=4483362458})
        end
    end }))

-- ---------- EMOTES ----------
Emotes:CreateSection("animations")
Emotes:CreateButton({ Name="Stop Emote",
    Callback=function() if S.emoteTrack then pcall(function() S.emoteTrack:Stop(0.1) end) S.emoteTrack = nil end end })
for _, e in ipairs(EMOTES) do
    Emotes:CreateButton({ Name=e.name, Callback=function() playEmote(e.id) end })
end

-- ---------- CONFIG ----------
Config:CreateSection("configuration")
Config:CreateParagraph({
    Title = "Configuration",
    Content = "Use the built-in config menu at the bottom of the window to Save / Load / Delete your MM2 config. Auto-load is enabled."
})

-- ============================================================
--  EVENT HOOKS / LOOPS
-- ============================================================
workspace.DescendantAdded:Connect(function(obj)
    if Misc.AutoGun then
        local n = obj.Name
        if n == "GunDrop" or n == "DroppedGun" or n:lower():find("gundrop") then
            if not equippedGun() then
                task.wait(0.1)
                if not equippedGun() then grabGun(obj) end
            end
        end
    end
    if ESPS.Trap and obj.Name == "Trap" then
        local hl = Instance.new("Highlight")
        hl.Adornee = obj
        hl.FillColor = Color3.fromRGB(255,60,60)
        hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.fromRGB(255,60,60)
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = obj
        Rayfield:Notify({Title="Trap", Content="Murderer placed a trap.", Duration=3, Image=4483362458})
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Misc.InfJump then
        local h = Hum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode == PANIC_KEY and Misc.PanicKey then panicOff() return end
    if input.KeyCode == Enum.KeyCode.T then
        lockToggle:Set(not Aim.LockOn)
    elseif input.KeyCode == Enum.KeyCode.O then
        ESPS.PlayerESP = not ESPS.PlayerESP
        refreshESP()
    elseif input.KeyCode == Enum.KeyCode.B then
        Aim.AutoFire = not Aim.AutoFire
    end
end)

RunService.Heartbeat:Connect(function()
    evadeTick()
    if Visual.ForceField then applyForceField() end
    if Visual.FFTools    then applyFFTools()    end
end)

local function bindPlayer(p)
    p.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        if ESPS.PlayerESP or ESPS.NameESP then applyESP(p) end
    end)
    p.CharacterRemoving:Connect(function() clearHL(p) end)
    if p.Character and (ESPS.PlayerESP or ESPS.NameESP) then applyESP(p) end
end
for _, p in ipairs(Players:GetPlayers()) do
    bindPlayer(p)
    bindPlayerRoles(p)
end
Players.PlayerAdded:Connect(function(p) bindPlayer(p) bindPlayerRoles(p) end)
Players.PlayerRemoving:Connect(function(p)
    clearHL(p)
    S.roleCache[p.Name] = nil
    if S.murdererCache.plr == p then S.murdererCache.plr = nil end
    if p == LocalPlayer and Misc.AutoRejoin then
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, p) end)
    end
end)

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if Misc.AutoRejoin then
            local lp = Players.LocalPlayer
            if not lp or not lp.Parent then
                pcall(function() TeleportService:Teleport(game.PlaceId) end)
                break
            end
        end
    end
end)

saveLegProps()
if LocalPlayer.Character then bindToolSpin(LocalPlayer.Character) end

LocalPlayer.CharacterAdded:Connect(function(char)
    S.murdererCache.plr = nil S.murdererCache.time = 0
    S.safeCF = nil S.emoteTrack = nil S.spinGrip = nil
    if S.evadeBV then S.evadeBV:Destroy() S.evadeBV = nil end
    clearBeam()
    restoreNormalGravity()
    char:WaitForChild("Humanoid")
    task.wait(0.5)
    saveLegProps()
    bindToolSpin(char)
    if Movement.Fly then startFly() end
    local h = Hum()
    if h then
        h.WalkSpeed = Movement.WalkSpeed
        h.JumpPower = Movement.JumpPower
        h.UseJumpPower = true
    end
    if Visual.ForceField then applyForceField() end
    if Visual.AuraOn     then applyAuras()      end
    if Visual.ChinaHat   then applyChinaHat()   end
    if Visual.Headless   then applyHeadless()   end
    if Visual.Korblox    then applyKorblox()    end
    if Visual.ToolSpin   then startToolSpin()   end
    refreshESP()
end)

task.spawn(function()
    while true do
        task.wait(1)
        if ESPS.PlayerESP or ESPS.NameESP or ESPS.Gun or ESPS.Coin or ESPS.Candy then refreshESP() end
    end
end)

Rayfield:Notify({Title="MM2 Hub", Content="Loaded v" .. SCRIPT_VERSION, Duration=3, Image=4483362458})
