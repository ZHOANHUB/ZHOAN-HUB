local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

local env = getgenv()
if env.__ZHOAN_DEAGLE_CLEANUP then
    pcall(env.__ZHOAN_DEAGLE_CLEANUP)
end
local okRayfield, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not okRayfield or not Rayfield then
    warn("[ZHOAN] Rayfield non caricato: " .. tostring(Rayfield))
    return
end

local Window = Rayfield:CreateWindow({
    Name = "ZHOAN DEAGLE HUB",
    LoadingTitle = "ZHOAN DEAGLE HUB",
    LoadingSubtitle = "Aimbot - Silent - ESP",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false,
})

local AimTab = Window:CreateTab("Aimbot", 4483362458)
local SilentTab = Window:CreateTab("Silent Aim", 4483362458)
local EspTab = Window:CreateTab("ESP", 4483362458)
local ConfigTab = Window:CreateTab("Config", 4483362458)
local AIM_MODES = {"Hold", "Toggle"}
local PARTS = {"Head", "UpperTorso", "Torso"}
local ORIGINS = {"Top", "Middle", "Bottom"}

local DEFAULTS = {
    aim = {
        enabled = false, mode = "Hold", fov = 150, part = "Head",
        team = true, visible = true,
        color = Color3.fromRGB(90, 170, 255),
    },
    silent = {
        enabled = false, fov = 150, part = "Head",
        team = true, visible = true,
        color = Color3.fromRGB(255, 210, 60),
    },
    esp = {
        box = false, skeleton = false, tracer = false, origin = "Bottom",
        team = true,
        boxColor = Color3.fromRGB(255, 90, 90),
        skelColor = Color3.fromRGB(255, 255, 255),
        tracerColor = Color3.fromRGB(255, 190, 60),
    },
    rainbow = false,
}

local function deepcopy(value)
    if type(value) ~= "table" then return value end
    local out = {}
    for k, v in pairs(value) do out[k] = deepcopy(v) end
    return out
end

local S = deepcopy(DEFAULTS)

local function packColor(c)
    return {math.round(c.R * 255), math.round(c.G * 255), math.round(c.B * 255)}
end

local function readColor(t, fallback)
    if type(t) ~= "table" then return fallback end
    local r = tonumber(t[1] or t.r)
    local g = tonumber(t[2] or t.g)
    local b = tonumber(t[3] or t.b)
    if not (r and g and b) then return fallback end
    return Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
end

local function clampNumber(value, fallback, min, max)
    local n = tonumber(value)
    if not n then return fallback end
    return math.clamp(n, min, max)
end

local function pickString(value, allowed, fallback)
    if type(value) == "string" and table.find(allowed, value) then return value end
    return fallback
end
local function getHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function isAlive(character)
    local humanoid = getHumanoid(character)
    if humanoid then return humanoid.Health > 0 end
    return character ~= nil and (character:FindFirstChild("Head") ~= nil or character:FindFirstChild("HeadHitbox") ~= nil)
end

local function resolveParts(character, partName)
    local head = character:FindFirstChild("Head") or character:FindFirstChild("HeadHitbox")
    local headHitbox = character:FindFirstChild("HeadHitbox")
    local bodyHitbox = character:FindFirstChild("BodyHitbox")
    local upper = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    local lower = character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso")

    local aim
    local hit
    if partName == "Head" then
        aim = head
        hit = headHitbox or head
    elseif partName == "UpperTorso" then
        aim = upper or bodyHitbox
        hit = bodyHitbox or upper
    else
        aim = lower or bodyHitbox
        hit = bodyHitbox or lower
    end

    if aim and not aim:IsA("BasePart") then aim = nil end
    if hit and not hit:IsA("BasePart") then hit = nil end
    return aim, hit
end
local GamemodeShared
do
    local ok, mod = pcall(function()
        local node: Instance? = game:GetService("ReplicatedStorage")
        for _, name in ipairs({ "Modules", "Shared", "GamemodeShared" }) do
            if not node then return nil end
            node = node:FindFirstChild(name)
        end
        if not node then return nil end
        return require(node :: ModuleScript)
    end)
    if ok and type(mod) == "table" and type(mod.AreTeammates) == "function" then
        GamemodeShared = mod
    end
end

local function getTeam(obj)
    if not obj then return nil end
    local attr = obj:GetAttribute("GamemodeTeam")
    if attr == nil and obj:IsA("Model") then
        local player = Players:GetPlayerFromCharacter(obj)
        attr = player and player:GetAttribute("GamemodeTeam")
    end
    if type(attr) == "string" then return attr end
    return nil
end

local function isTeammate(character, _player)
    if not character then return false end
    if GamemodeShared then
        local ok, same = pcall(GamemodeShared.AreTeammates, LP, character)
        if ok then return same == true end
    end
    local mine = getTeam(LP)
    return mine ~= nil and mine == getTeam(character)
end
local botCache = {}
local botCacheTime = 0

local function getBots()
    local now = tick()
    if now - botCacheTime < 1 then return botCache end
    botCacheTime = now

    local list = {}
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") and child:GetAttribute("IsBot") == true then
            table.insert(list, child)
        elseif child:IsA("Folder") then
            for _, sub in ipairs(child:GetChildren()) do
                if sub:IsA("Model") and sub:GetAttribute("IsBot") == true then
                    table.insert(list, sub)
                end
            end
        end
    end
    botCache = list
    return list
end

local function getTargets()
    local list = {}
    local lpCharacter = LP.Character
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            local character = player.Character
            if character and character ~= lpCharacter and isAlive(character) then
                table.insert(list, {character = character, player = player})
            end
        end
    end
    for _, model in ipairs(getBots()) do
        if model ~= lpCharacter and isAlive(model) then
            table.insert(list, {character = model, player = nil})
        end
    end
    return list
end
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true
rayParams.RespectCanCollide = false

local visibilityCache = {}

local function isVisible(character, part)
    local camera = workspace.CurrentCamera
    if not camera or not part then return false end

    local now = tick()
    local cached = visibilityCache[character]
    if cached and cached.part == part and now - cached.time < 0.08 then
        return cached.visible
    end

    local filter = {camera}
    if LP.Character then table.insert(filter, LP.Character) end
    rayParams.FilterDescendantsInstances = filter

    local origin = camera.CFrame.Position
    local result = workspace:Raycast(origin, part.Position - origin, rayParams)
    local visible = result == nil or result.Instance:IsDescendantOf(character)

    visibilityCache[character] = {time = now, part = part, visible = visible}
    return visible
end
local function findTarget(settings)
    local camera = workspace.CurrentCamera
    if not camera then return nil end

    local viewport = camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    local best = nil
    local bestDistance = settings.fov

    for _, target in ipairs(getTargets()) do
        if not (settings.team and isTeammate(target.character, target.player)) then
            local aimPart, hitPart = resolveParts(target.character, settings.part)
            if aimPart then
                local screenPoint, onScreen = camera:WorldToViewportPoint(aimPart.Position)
                if onScreen and screenPoint.Z > 0 then
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - center).Magnitude
                    if distance <= bestDistance then
                        if not settings.visible or isVisible(target.character, aimPart) then
                            bestDistance = distance
                            best = {
                                character = target.character,
                                player = target.player,
                                aimPart = aimPart,
                                hitPart = hitPart or aimPart,
                                distance = distance,
                            }
                        end
                    end
                end
            end
        end
    end

    return best
end
local allDrawings = {}
local function newDrawing(kind)
    local drawing = Drawing.new(kind)
    table.insert(allDrawings, drawing)
    return drawing
end

local aimCircle = newDrawing("Circle")
aimCircle.Thickness = 1
aimCircle.Filled = false
aimCircle.Transparency = 0.85

local silentCircle = newDrawing("Circle")
silentCircle.Thickness = 1
silentCircle.Filled = false
silentCircle.Transparency = 0.85

local function rainbowColor(phase)
    return Color3.fromHSV((tick() * 0.35 + (phase or 0)) % 1, 1, 1)
end

local function elementColor(base, phase)
    if S.rainbow then return rainbowColor(phase) end
    return base
end
local espObjects = {}

local R15_LINKS = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "HumanoidRootPart"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

local R6_LINKS = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
}

local function getEsp(character)
    local entry = espObjects[character]
    if entry then return entry end

    entry = {
        box = newDrawing("Square"),
        tracer = newDrawing("Line"),
        lines = {},
    }
    entry.box.Thickness = 1
    entry.box.Filled = false
    entry.tracer.Thickness = 1
    for i = 1, #R15_LINKS do
        entry.lines[i] = newDrawing("Line")
        entry.lines[i].Thickness = 1
    end
    espObjects[character] = entry
    return entry
end

local function destroyEsp(character)
    local entry = espObjects[character]
    if not entry then return end
    for _, drawing in ipairs(entry.lines) do pcall(function() drawing:Remove() end) end
    pcall(function() entry.box:Remove() end)
    pcall(function() entry.tracer:Remove() end)
    espObjects[character] = nil
end

local function hideEsp(entry)
    entry.box.Visible = false
    entry.tracer.Visible = false
    for _, line in ipairs(entry.lines) do line.Visible = false end
end

local function projectBox(camera, character)
    local model = character
    local ok, boxCFrame, boxSize = pcall(function()
        local cf, size = model:GetBoundingBox()
        return cf, size
    end)
    if not ok or not boxCFrame then return nil end

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local valid = 0

    for x = -0.5, 0.5, 1 do
        for y = -0.5, 0.5, 1 do
            for z = -0.5, 0.5, 1 do
                local world = (boxCFrame * CFrame.new(boxSize.X * x, boxSize.Y * y, boxSize.Z * z)).Position
                local point, onScreen = camera:WorldToViewportPoint(world)
                if onScreen and point.Z > 0 then
                    valid += 1
                    minX = math.min(minX, point.X)
                    minY = math.min(minY, point.Y)
                    maxX = math.max(maxX, point.X)
                    maxY = math.max(maxY, point.Y)
                end
            end
        end
    end

    if valid < 4 then return nil end
    return Vector2.new(minX, minY), Vector2.new(maxX - minX, maxY - minY)
end

local function projectPoint(camera, part)
    if not part then return nil end
    local point, onScreen = camera:WorldToViewportPoint(part.Position)
    if onScreen and point.Z > 0 then return Vector2.new(point.X, point.Y) end
    return nil
end

local function drawSkeleton(entry, camera, character)
    local links = R15_LINKS
    if not character:FindFirstChild("UpperTorso") and not character:FindFirstChild("LowerTorso") then
        links = R6_LINKS
    end

    for i, line in ipairs(entry.lines) do
        local link = links[i]
        if link then
            local partA = character:FindFirstChild(link[1])
            local partB = character:FindFirstChild(link[2])
            local pointA = projectPoint(camera, partA)
            local pointB = projectPoint(camera, partB)
            if pointA and pointB then
                line.From = pointA
                line.To = pointB
                line.Thickness = 1
                line.Color = elementColor(S.esp.skelColor, 0.08)
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end

local function updateEsp(camera)
    local viewport = camera.ViewportSize
    local active = {}

    for _, target in ipairs(getTargets()) do
        local character = target.character
        if not (S.esp.team and isTeammate(character, target.player)) then
            active[character] = true
            local entry = getEsp(character)

            if S.esp.box then
                local position, size = projectBox(camera, character)
                if position and size and size.X > 0 and size.Y > 0 then
                    entry.box.Position = position
                    entry.box.Size = size
                    entry.box.Thickness = 1
                    entry.box.Color = elementColor(S.esp.boxColor, 0)
                    entry.box.Visible = true
                else
                    entry.box.Visible = false
                end
            else
                entry.box.Visible = false
            end

            if S.esp.skeleton then
                drawSkeleton(entry, camera, character)
            else
                for _, line in ipairs(entry.lines) do line.Visible = false end
            end

            if S.esp.tracer then
                local originY
                if S.esp.origin == "Top" then
                    originY = 0
                elseif S.esp.origin == "Middle" then
                    originY = viewport.Y / 2
                else
                    originY = viewport.Y
                end
                local head = character:FindFirstChild("Head") or character:FindFirstChild("HeadHitbox") or character:FindFirstChild("HumanoidRootPart")
                local point = projectPoint(camera, head)
                if point then
                    entry.tracer.From = Vector2.new(viewport.X / 2, originY)
                    entry.tracer.To = point
                    entry.tracer.Thickness = 1
                    entry.tracer.Color = elementColor(S.esp.tracerColor, 0.16)
                    entry.tracer.Visible = true
                else
                    entry.tracer.Visible = false
                end
            else
                entry.tracer.Visible = false
            end
        end
    end

    for character, entry in pairs(espObjects) do
        if not active[character] then
            if not isAlive(character) or character.Parent == nil then
                destroyEsp(character)
            else
                hideEsp(entry)
            end
        end
    end
end

local aimHeld = false

local function onRender()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local viewport = camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

    aimCircle.Position = center
    aimCircle.Radius = S.aim.fov
    aimCircle.Color = elementColor(S.aim.color, 0.33)
    aimCircle.Visible = S.aim.enabled

    silentCircle.Position = center
    silentCircle.Radius = S.silent.fov
    silentCircle.Color = elementColor(S.silent.color, 0.66)
    silentCircle.Visible = S.silent.enabled

    if S.aim.enabled and aimHeld then
        local target = findTarget(S.aim)
        if target then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.aimPart.Position)
        end
    end

    updateEsp(camera)
end

RunService:BindToRenderStep("ZHOAN_DEAGLE_RENDER", Enum.RenderPriority.Camera.Value + 1, onRender)
local function findNetworkRemote()
    local node = game:GetService("ReplicatedStorage")
    for _, name in ipairs({"Modules", "Packages", "Network"}) do
        node = node and node:FindFirstChild(name)
    end
    return node and node:FindFirstChild("NetworkRemote") or nil
end

local shootRemote = findNetworkRemote()
local oldNamecall
local hookInstalled = false
local lastShot = nil

local function installHook()
    if hookInstalled or not shootRemote then return hookInstalled end

    local ok, original = pcall(function()
        return hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and self == shootRemote and (not checkcaller() or env.__ZHOAN_FORCE_HOOK == true) then
                local args = {...}
                if args[1] == "Shoot" and S.silent.enabled then
                    local target = findTarget(S.silent)
                    if target and (not S.silent.visible or isVisible(target.character, target.aimPart)) then
                        local hitPosition = target.hitPart.Position
                        local timestamp = tonumber(args[6]) or workspace:GetServerTimeNow()
                        lastShot = {
                            target = target.character.Name,
                            part = target.hitPart.Name,
                            position = hitPosition,
                            timestamp = timestamp,
                            originalHadHit = args[4] ~= nil,
                        }
                        pcall(setnamecallmethod, method)
                        return oldNamecall(self, args[1], args[2], hitPosition, target.hitPart, hitPosition, timestamp)
                    end
                end
            end
            pcall(setnamecallmethod, method)
            return oldNamecall(self, ...)
        end)
    end)

    if ok then
        oldNamecall = original
        hookInstalled = true
    else
        warn("[ZHOAN] Hook silent aim fallito: " .. tostring(original))
    end
    return hookInstalled
end

installHook()
local CONFIG_DIR = "ZHOAN_DEAGLE_HUB"
local CONFIG_SUB = CONFIG_DIR .. "/configs"
local AUTOLOAD_FILE = CONFIG_DIR .. "/autoload.txt"

local function ensureFolders()
    local ok = pcall(function()
        if not isfolder(CONFIG_DIR) then makefolder(CONFIG_DIR) end
        if not isfolder(CONFIG_SUB) then makefolder(CONFIG_SUB) end
    end)
    return ok
end
ensureFolders()

local function sanitizeName(name)
    name = tostring(name or ""):gsub("[^%w%-_ ]", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if #name > 32 then name = name:sub(1, 32):gsub("%s+$", "") end
    return name
end

local function configPath(name)
    return CONFIG_SUB .. "/" .. name .. ".json"
end

local function listConfigs()
    local names = {}
    local ok, files = pcall(listfiles, CONFIG_SUB)
    if ok and type(files) == "table" then
        for _, file in ipairs(files) do
            local name = tostring(file):match("([^/\\]+)%.json$")
            if name and name ~= "" then table.insert(names, name) end
        end
    end
    table.sort(names)
    return names
end

local function serialize()
    return {
        version = 1,
        aim = {
            enabled = S.aim.enabled, mode = S.aim.mode, fov = S.aim.fov,
            part = S.aim.part, team = S.aim.team, visible = S.aim.visible,
            color = packColor(S.aim.color),
        },
        silent = {
            enabled = S.silent.enabled, fov = S.silent.fov, part = S.silent.part,
            team = S.silent.team, visible = S.silent.visible,
            color = packColor(S.silent.color),
        },
        esp = {
            box = S.esp.box, skeleton = S.esp.skeleton, tracer = S.esp.tracer,
            origin = S.esp.origin, team = S.esp.team,
            boxColor = packColor(S.esp.boxColor),
            skelColor = packColor(S.esp.skelColor),
            tracerColor = packColor(S.esp.tracerColor),
        },
        rainbow = S.rainbow,
    }
end

local function normalizeConfig(data)
    local out = deepcopy(DEFAULTS)
    if type(data) ~= "table" then return out end

    local aim = type(data.aim) == "table" and data.aim or {}
    out.aim.enabled = aim.enabled == true
    out.aim.mode = pickString(aim.mode, AIM_MODES, out.aim.mode)
    out.aim.fov = clampNumber(aim.fov, out.aim.fov, 30, 1500)
    out.aim.part = pickString(aim.part, PARTS, out.aim.part)
    out.aim.team = aim.team ~= false
    out.aim.visible = aim.visible ~= false
    out.aim.color = readColor(aim.color, out.aim.color)

    local silent = type(data.silent) == "table" and data.silent or {}
    out.silent.enabled = silent.enabled == true
    out.silent.fov = clampNumber(silent.fov, out.silent.fov, 30, 1500)
    out.silent.part = pickString(silent.part, PARTS, out.silent.part)
    out.silent.team = silent.team ~= false
    out.silent.visible = silent.visible ~= false
    out.silent.color = readColor(silent.color, out.silent.color)

    local esp = type(data.esp) == "table" and data.esp or {}
    out.esp.box = esp.box == true
    out.esp.skeleton = esp.skeleton == true
    out.esp.tracer = esp.tracer == true
    out.esp.origin = pickString(esp.origin, ORIGINS, out.esp.origin)
    out.esp.team = esp.team ~= false
    out.esp.boxColor = readColor(esp.boxColor, out.esp.boxColor)
    out.esp.skelColor = readColor(esp.skelColor, out.esp.skelColor)
    out.esp.tracerColor = readColor(esp.tracerColor, out.esp.tracerColor)

    out.rainbow = data.rainbow == true

    return out
end
local ui = {}

local function setControl(control, value)
    if not control then return end
    pcall(function() control:Set(value) end)
end

local function syncUI()
    setControl(ui.aimToggle, S.aim.enabled)
    setControl(ui.aimMode, {S.aim.mode})
    setControl(ui.aimFov, S.aim.fov)
    setControl(ui.aimPart, {S.aim.part})
    setControl(ui.aimTeam, S.aim.team)
    setControl(ui.aimVisible, S.aim.visible)
    setControl(ui.aimColor, S.aim.color)

    setControl(ui.silentToggle, S.silent.enabled)
    setControl(ui.silentFov, S.silent.fov)
    setControl(ui.silentPart, {S.silent.part})
    setControl(ui.silentTeam, S.silent.team)
    setControl(ui.silentVisible, S.silent.visible)
    setControl(ui.silentColor, S.silent.color)

    setControl(ui.espBox, S.esp.box)
    setControl(ui.espSkeleton, S.esp.skeleton)
    setControl(ui.espTracer, S.esp.tracer)
    setControl(ui.espOrigin, {S.esp.origin})
    setControl(ui.espTeam, S.esp.team)
    setControl(ui.espBoxColor, S.esp.boxColor)
    setControl(ui.espSkelColor, S.esp.skelColor)
    setControl(ui.espTracerColor, S.esp.tracerColor)
    setControl(ui.rainbow, S.rainbow)

end
AimTab:CreateSection("Target")
ui.aimToggle = AimTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = S.aim.enabled,
    Flag = "ZHOAN_AIM_ENABLED",
    Callback = function(value) S.aim.enabled = value end,
})
ui.aimMode = AimTab:CreateDropdown({
    Name = "Modalita' (tasto destro)",
    Options = AIM_MODES,
    CurrentOption = {S.aim.mode},
    MultipleOptions = false,
    Flag = "ZHOAN_AIM_MODE",
    Callback = function(value)
        S.aim.mode = type(value) == "table" and value[1] or value
        aimHeld = false
    end,
})
ui.aimFov = AimTab:CreateSlider({
    Name = "FOV aimbot",
    Range = {30, 1500},
    Increment = 5,
    Suffix = "px",
    CurrentValue = S.aim.fov,
    Flag = "ZHOAN_AIM_FOV",
    Callback = function(value) S.aim.fov = value end,
})
ui.aimPart = AimTab:CreateDropdown({
    Name = "Parte da mirare",
    Options = PARTS,
    CurrentOption = {S.aim.part},
    MultipleOptions = false,
    Flag = "ZHOAN_AIM_PART",
    Callback = function(value)
        S.aim.part = type(value) == "table" and value[1] or value
    end,
})

AimTab:CreateSection("Filtri")
ui.aimTeam = AimTab:CreateToggle({
    Name = "Team check",
    CurrentValue = S.aim.team,
    Flag = "ZHOAN_AIM_TEAM",
    Callback = function(value) S.aim.team = value end,
})
ui.aimVisible = AimTab:CreateToggle({
    Name = "Visibility check",
    CurrentValue = S.aim.visible,
    Flag = "ZHOAN_AIM_VISIBLE",
    Callback = function(value) S.aim.visible = value end,
})

AimTab:CreateSection("Colore")
ui.aimColor = AimTab:CreateColorPicker({
    Name = "Colore FOV aimbot",
    Color = S.aim.color,
    Flag = "ZHOAN_AIM_COLOR",
    Callback = function(value) S.aim.color = value end,
})
SilentTab:CreateSection("Target")
ui.silentToggle = SilentTab:CreateToggle({
    Name = "Silent aim",
    CurrentValue = S.silent.enabled,
    Flag = "ZHOAN_SILENT_ENABLED",
    Callback = function(value) S.silent.enabled = value end,
})
ui.silentFov = SilentTab:CreateSlider({
    Name = "FOV silent",
    Range = {30, 1500},
    Increment = 5,
    Suffix = "px",
    CurrentValue = S.silent.fov,
    Flag = "ZHOAN_SILENT_FOV",
    Callback = function(value) S.silent.fov = value end,
})
ui.silentPart = SilentTab:CreateDropdown({
    Name = "Parte da mirare",
    Options = PARTS,
    CurrentOption = {S.silent.part},
    MultipleOptions = false,
    Flag = "ZHOAN_SILENT_PART",
    Callback = function(value)
        S.silent.part = type(value) == "table" and value[1] or value
    end,
})

SilentTab:CreateSection("Filtri")
ui.silentTeam = SilentTab:CreateToggle({
    Name = "Team check",
    CurrentValue = S.silent.team,
    Flag = "ZHOAN_SILENT_TEAM",
    Callback = function(value) S.silent.team = value end,
})
ui.silentVisible = SilentTab:CreateToggle({
    Name = "Visibility check",
    CurrentValue = S.silent.visible,
    Flag = "ZHOAN_SILENT_VISIBLE",
    Callback = function(value) S.silent.visible = value end,
})

SilentTab:CreateSection("Colore")
ui.silentColor = SilentTab:CreateColorPicker({
    Name = "Colore FOV silent",
    Color = S.silent.color,
    Flag = "ZHOAN_SILENT_COLOR",
    Callback = function(value) S.silent.color = value end,
})
EspTab:CreateSection("Elementi")
ui.espBox = EspTab:CreateToggle({
    Name = "ESP 2D box",
    CurrentValue = S.esp.box,
    Flag = "ZHOAN_ESP_BOX",
    Callback = function(value) S.esp.box = value end,
})
ui.espSkeleton = EspTab:CreateToggle({
    Name = "ESP skeleton",
    CurrentValue = S.esp.skeleton,
    Flag = "ZHOAN_ESP_SKELETON",
    Callback = function(value) S.esp.skeleton = value end,
})
ui.espTracer = EspTab:CreateToggle({
    Name = "ESP tracer",
    CurrentValue = S.esp.tracer,
    Flag = "ZHOAN_ESP_TRACER",
    Callback = function(value) S.esp.tracer = value end,
})
ui.espOrigin = EspTab:CreateDropdown({
    Name = "Origine tracer",
    Options = ORIGINS,
    CurrentOption = {S.esp.origin},
    MultipleOptions = false,
    Flag = "ZHOAN_ESP_ORIGIN",
    Callback = function(value)
        S.esp.origin = type(value) == "table" and value[1] or value
    end,
})

EspTab:CreateSection("Filtri")
ui.espTeam = EspTab:CreateToggle({
    Name = "Team check ESP",
    CurrentValue = S.esp.team,
    Flag = "ZHOAN_ESP_TEAM",
    Callback = function(value) S.esp.team = value end,
})

EspTab:CreateSection("Colori")
ui.espBoxColor = EspTab:CreateColorPicker({
    Name = "Colore box",
    Color = S.esp.boxColor,
    Flag = "ZHOAN_ESP_BOX_COLOR",
    Callback = function(value) S.esp.boxColor = value end,
})
ui.espSkelColor = EspTab:CreateColorPicker({
    Name = "Colore skeleton",
    Color = S.esp.skelColor,
    Flag = "ZHOAN_ESP_SKEL_COLOR",
    Callback = function(value) S.esp.skelColor = value end,
})
ui.espTracerColor = EspTab:CreateColorPicker({
    Name = "Colore tracer",
    Color = S.esp.tracerColor,
    Flag = "ZHOAN_ESP_TRACER_COLOR",
    Callback = function(value) S.esp.tracerColor = value end,
})

EspTab:CreateSection("Effetti")
ui.rainbow = EspTab:CreateToggle({
    Name = "Rainbow (FOV + ESP)",
    CurrentValue = S.rainbow,
    Flag = "ZHOAN_RAINBOW",
    Callback = function(value) S.rainbow = value end,
})
local selectedConfig = nil

local function notify(title, content, duration)
    pcall(function()
        Rayfield:Notify({
            Title = title,
            Content = content,
            Duration = duration or 5,
            Image = 4483362458,
        })
    end)
end

local function readAutoload()
    local ok, data = pcall(function()
        if isfile(AUTOLOAD_FILE) then return readfile(AUTOLOAD_FILE) end
        return nil
    end)
    if ok and type(data) == "string" then
        return sanitizeName(data)
    end
    return nil
end

local function loadConfig(name, silentMode)
    name = sanitizeName(name)
    if name == "" then
        notify("ZHOAN", "Nome config non valido.", 4)
        return false
    end

    local path = configPath(name)
    local ok, data = pcall(function()
        if not isfile(path) then return nil end
        return HttpService:JSONDecode(readfile(path))
    end)

    if not ok then
        notify("ZHOAN", "Config corrotta o illeggibile.", 5)
        return false
    end
    if type(data) ~= "table" then
        notify("ZHOAN", "Config non trovata: " .. name, 4)
        return false
    end

    S = normalizeConfig(data)
    aimHeld = false
    syncUI()

    if not silentMode then
        notify("ZHOAN", "Config caricata: " .. name, 4)
    end
    return true
end

local function saveConfig(name, overwrite)
    name = sanitizeName(name)
    if name == "" then
        notify("ZHOAN", "Scrivi un nome per la config.", 4)
        return false
    end

    local path = configPath(name)
    if isfile(path) and not overwrite then
        notify("ZHOAN", "Esiste gia': " .. name .. ". Usa Overwrite.", 5)
        return false
    end

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(serialize())
    end)
    if not ok then
        notify("ZHOAN", "Errore di encoding config.", 5)
        return false
    end

    local written = pcall(writefile, path, encoded)
    if not written then
        notify("ZHOAN", "Scrittura config fallita.", 5)
        return false
    end

    notify("ZHOAN", (overwrite and "Config sovrascritta: " or "Config creata: ") .. name, 4)
    return true
end

local configDropdown
local configInput

local function refreshConfigList(preferred)
    local names = listConfigs()
    local options = names
    if #options == 0 then options = {"(nessuna)"} end

    if configDropdown then
        pcall(function() configDropdown:Refresh(options) end)
    end

    local wanted = preferred or selectedConfig
    if not wanted or not table.find(options, wanted) then
        wanted = options[1]
    end
    selectedConfig = wanted
    if configDropdown then setControl(configDropdown, {wanted}) end
    return names
end

ConfigTab:CreateSection("Config")
ConfigTab:CreateParagraph({
    Title = "ZHOAN DEAGLE HUB",
    Content = "Le config sono salvate in " .. CONFIG_SUB .. ". Ogni file contiene aimbot, silent ed ESP.",
})

configInput = ConfigTab:CreateInput({
    Name = "Nome config",
    CurrentValue = "",
    PlaceholderText = "es. rage",
    RemoveTextAfterFocusLost = false,
    Flag = "ZHOAN_CONFIG_NAME",
    Callback = function(text) end,
})

configDropdown = ConfigTab:CreateDropdown({
    Name = "Config salvate",
    Options = {"(nessuna)"},
    CurrentOption = {"(nessuna)"},
    MultipleOptions = false,
    Flag = "ZHOAN_CONFIG_SELECTED",
    Callback = function(value)
        selectedConfig = type(value) == "table" and value[1] or value
    end,
})

local function getNameFromUI()
    local typed = configInput and configInput.CurrentValue or ""
    typed = sanitizeName(typed)
    if typed ~= "" then return typed end
    if selectedConfig and selectedConfig ~= "(nessuna)" then return sanitizeName(selectedConfig) end
    return ""
end

ConfigTab:CreateButton({
    Name = "Crea / salva config",
    Callback = function()
        local name = getNameFromUI()
        if saveConfig(name, false) then
            refreshConfigList(name)
        end
    end,
})

ConfigTab:CreateButton({
    Name = "Overwrite config selezionata",
    Callback = function()
        local name = getNameFromUI()
        if saveConfig(name, true) then
            refreshConfigList(name)
        end
    end,
})

ConfigTab:CreateButton({
    Name = "Carica config selezionata",
    Callback = function()
        local name = getNameFromUI()
        if loadConfig(name) then
            refreshConfigList(sanitizeName(name))
        end
    end,
})

ConfigTab:CreateButton({
    Name = "Elimina config selezionata",
    Callback = function()
        local name = getNameFromUI()
        if name == "" then
            notify("ZHOAN", "Seleziona una config.", 4)
            return
        end
        local path = configPath(name)
        if not isfile(path) then
            notify("ZHOAN", "Config non trovata.", 4)
            return
        end
        local ok = pcall(delfile, path)
        if not ok then
            notify("ZHOAN", "Eliminazione fallita.", 5)
            return
        end
        if readAutoload() == name then
            pcall(delfile, AUTOLOAD_FILE)
        end
        notify("ZHOAN", "Config eliminata: " .. name, 4)
        refreshConfigList()
    end,
})

ConfigTab:CreateButton({
    Name = "Imposta come autoload",
    Callback = function()
        local name = getNameFromUI()
        if name == "" then
            notify("ZHOAN", "Seleziona una config.", 4)
            return
        end
        if not isfile(configPath(name)) then
            notify("ZHOAN", "Salva prima la config.", 4)
            return
        end
        local ok = pcall(writefile, AUTOLOAD_FILE, name)
        if ok then
            notify("ZHOAN", "Autoload impostato: " .. name, 4)
        else
            notify("ZHOAN", "Autoload non salvato.", 5)
        end
    end,
})

ConfigTab:CreateButton({
    Name = "Rimuovi autoload",
    Callback = function()
        pcall(delfile, AUTOLOAD_FILE)
        notify("ZHOAN", "Autoload rimosso.", 4)
    end,
})

ConfigTab:CreateButton({
    Name = "Aggiorna lista",
    Callback = function()
        local names = refreshConfigList()
        notify("ZHOAN", #names .. " config trovate.", 3)
    end,
})

ConfigTab:CreateSection("Sessione")
ConfigTab:CreateButton({
    Name = "Unload hub",
    Callback = function()
        notify("ZHOAN", "Hub scaricato.", 3)
        task.delay(0.3, function()
            if env.__ZHOAN_DEAGLE_CLEANUP then
                env.__ZHOAN_DEAGLE_CLEANUP()
            end
        end)
    end,
})
local inputBegan = UIS.InputBegan:Connect(function(input, processed)
    if processed or input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
    if S.aim.mode == "Toggle" then
        aimHeld = not aimHeld
    else
        aimHeld = true
    end
end)

local inputEnded = UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and S.aim.mode == "Hold" then
        aimHeld = false
    end
end)
local cleaned = false
env.__ZHOAN_DEAGLE_CLEANUP = function()
    if cleaned then return end
    cleaned = true

    pcall(function() RunService:UnbindFromRenderStep("ZHOAN_DEAGLE_RENDER") end)
    pcall(function() inputBegan:Disconnect() end)
    pcall(function() inputEnded:Disconnect() end)

    if hookInstalled and oldNamecall then
        pcall(function() hookmetamethod(game, "__namecall", oldNamecall) end)
    end

    for character in pairs(espObjects) do
        destroyEsp(character)
    end
    for _, drawing in ipairs(allDrawings) do
        pcall(function() drawing:Remove() end)
    end

    pcall(function() Rayfield:Destroy() end)
    env.__ZHOAN_DEAGLE_CLEANUP = nil
    env.__ZHOAN_DEAGLE_DEBUG = nil
end
refreshConfigList()
syncUI()

task.defer(function()
    local autoload = readAutoload()
    if autoload and autoload ~= "" and isfile(configPath(autoload)) then
        loadConfig(autoload, true)
        notify("ZHOAN", "Autoload: " .. autoload, 4)
    end
end)

if not hookInstalled then
    task.spawn(function()
        for _ = 1, 20 do
            if hookInstalled then return end
            shootRemote = shootRemote or findNetworkRemote()
            if shootRemote then installHook() end
            task.wait(1)
        end
        if not hookInstalled then
            notify("ZHOAN", "Silent aim non agganciato: hook non disponibile.", 6)
        end
    end)
end

notify("ZHOAN DEAGLE HUB", "Caricato. Silent aim " .. (hookInstalled and "attivo." or "in attesa di hook."), 5)

env.__ZHOAN_DEAGLE_DEBUG = {
    state = S,
    getState = function() return S end,
    ui = ui,
    remote = shootRemote,
    hooked = function() return hookInstalled end,
    findTarget = function() return findTarget(S.silent) end,
    isTeammate = isTeammate,
    lastShot = function() return lastShot end,
    saveConfig = saveConfig,
    loadConfig = loadConfig,
    listConfigs = listConfigs,
    cleanup = env.__ZHOAN_DEAGLE_CLEANUP,
}
