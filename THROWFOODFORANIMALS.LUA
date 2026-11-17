--[[ ZHOAN HUB - THROW FOOD FOR ANIMALS - Rayfield Gen2 v10 ]]
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer
local remotes = RS:WaitForChild("Remotes")
local Controllers = lp.PlayerScripts.Client.Controllers
local AreaUtil = require(RS.Shared.AreaUtil)
local ClientState = require(Controllers.ClientState)
local DataController = require(Controllers.DataController)
local ThrowController = require(Controllers.ThrowController)
local ThrowMeter = require(Controllers.ThrowMeter)
local FoodsConfig = require(RS.Config.FoodsConfig)
local GameConfig = require(RS.Config.GameConfig)

local G = getgenv()
if G.__BA_cleanup then pcall(G.__BA_cleanup) end

local state = {
    alive=true, autoThrow=false, autoTrain=false, autoX2=false,
    autoEquip=false, autoFarm=false, cutscene=false, farmCutscene=false,
    autoFood=false, autoFence=false, autoBar=false,
    throwCooldown=0.5, equipInterval=10, meterValue=0.95,
    levelStep=20, tierStep=10,
}
local uiRefs = {}
local RayfieldRef = nil
-- generation token: invalidates old loops
local farmGen = 0
local function alive() return state.alive end
local function level() return DataController:Get("Level") or 0 end
local function xp() return DataController:Get("Xp") or 0 end
local function notify(title, content, dur)
    if RayfieldRef then pcall(function() RayfieldRef:Notify({Title=title, Content=content, Duration=dur or 4}) end) end
end
local function getLvlStep()
    local v = state.levelStep
    if RayfieldRef and RayfieldRef.Flags and type(RayfieldRef.Flags["BA_Lvl"]) == "number" then v = RayfieldRef.Flags["BA_Lvl"] end
    return math.max(1, math.floor(v or 1))
end
local function getTierStep()
    local v = state.tierStep
    if RayfieldRef and RayfieldRef.Flags and type(RayfieldRef.Flags["BA_Tier"]) == "number" then v = RayfieldRef.Flags["BA_Tier"] end
    return math.max(1, math.floor(v or 1))
end

local function getChar()
    local c = lp.Character
    return c, c and c:FindFirstChild("HumanoidRootPart")
end
local function getPlot()
    local idx = lp:GetAttribute("PlotIndex") or DataController:Get("PlotIndex")
    local plots = workspace:FindFirstChild("Plots")
    return plots and idx and plots:FindFirstChild(tostring(idx))
end
local function tpLaunch()
    local _, hrp = getChar()
    if hrp then hrp.CFrame = CFrame.new(AreaUtil.GetLaunchPosition() + Vector3.new(0, 3, 8)) end
    task.wait(0.2)
end
local function gotoTraining()
    local plot = getPlot(); local _, hrp = getChar()
    if plot and hrp then
        hrp.Anchored = false
        hrp.CFrame = CFrame.new(plot.Position + GameConfig.Plot.TrainingSpotOffset + Vector3.new(0, 3, 0))
        task.wait(0.35)
    end
end
local function freeBusy()
    if ClientState.Busy ~= "Training" then
        pcall(function() remotes.Throw_Cancel:InvokeServer() end)
        task.wait(0.25)
    end
end
local function startTraining()
    gotoTraining(); freeBusy()
    local ok, res = pcall(function() return remotes.Training_Start:InvokeServer() end)
    if ok and res and res.Ok then ClientState.Busy = "Training"; return true end
    return false, res and res.Reason
end
local function stopTraining()
    pcall(function() return remotes.Training_Stop:InvokeServer() end)
    if ClientState.Busy == "Training" then ClientState.Busy = nil end
    task.wait(0.35)
end
local function throwDirect()
    if ClientState.Busy == "Training" then stopTraining() end
    if ClientState.Busy ~= nil then freeBusy() end
    tpLaunch()
    local ok, start = pcall(function() return remotes.Throw_Start:InvokeServer() end)
    if ok and start and start.Ok then
        task.wait(0.12)
        local okR, resolved = pcall(function() return remotes.Throw_Resolve:InvokeServer(state.meterValue) end)
        if okR and resolved and resolved.Ok then
            task.wait(resolved.FlightTime or 2)
            return pcall(function() return remotes.Throw_Complete:InvokeServer() end)
        end
    end
    return false
end
local function throwCutscene()
    if ClientState.Busy == "Training" then stopTraining() end
    tpLaunch()
    ThrowMeter.TestAutoTap = 1.08
    local done = false
    task.spawn(function() pcall(ThrowController.Start); done = true end)
    local t0 = os.clock()
    while not done and os.clock() - t0 < 20 do task.wait(0.3) end
    ThrowMeter.TestAutoTap = false
    return done
end
local function doThrow(forceCutscene)
    local useCutscene = forceCutscene
    if useCutscene == nil then useCutscene = state.cutscene end
    if useCutscene then return throwCutscene() else return throwDirect() end
end

local function throwLoop()
    while alive() and state.autoThrow do doThrow(); task.wait(state.throwCooldown) end
end
local function trainLoop()
    while alive() and state.autoTrain do
        if ClientState.Busy ~= "Training" then startTraining() end
        task.wait(3)
    end
end
local function equipLoop()
    while alive() and state.autoEquip do
        pcall(function() return remotes.Plot_EquipBest:InvokeServer() end)
        task.wait(state.equipInterval)
    end
end
local function buyBestFood()
    pcall(function()
        local owned = DataController:Get("OwnedFoods") or {}
        local money = DataController:Get("Money") or 0
        local bestIdx = nil
        for _, f in ipairs(FoodsConfig.All) do
            if type(f) == "table" and f.Index and f.Price and not owned[f.Index] then
                if f.Price <= money and f.Index > (bestIdx or 0) then bestIdx = f.Index end
            end
        end
        if bestIdx then pcall(function() remotes.Shop_Buy:InvokeServer(bestIdx) end) end
    end)
end
local function foodLoop()
    while alive() and state.autoFood do buyBestFood(); task.wait(6) end
end
local function fenceLoop()
    while alive() and state.autoFence do
        pcall(function() return remotes.Plot_UpgradeFence:InvokeServer() end)
        task.wait(6)
    end
end
local function barLoop()
    while alive() and state.autoBar do
        pcall(function() return remotes.Stand_Upgrade:InvokeServer() end)
        task.wait(6)
    end
end

-- LEVEL PHASE: target = current level + N (read fresh). Exits only at target or if loop is superseded.
local function trainingPhase(myGen)
    local step = getLvlStep()
    local startLvl = level()
    local targetLvl = startLvl + step
    notify("Level Phase", string.format("From %d to %d (+%d)", startLvl, targetLvl, step), 5)
    if not startTraining() then
        for i = 1, 8 do
            if not (alive() and state.autoFarm and farmGen == myGen) then return end
            task.wait(1.5)
            if startTraining() then break end
        end
    end
    local lastXp = xp()
    local lastXpChange = os.clock()
    while alive() and state.autoFarm and farmGen == myGen do
        if level() >= targetLvl then break end
        local curXp = xp()
        if curXp ~= lastXp then
            lastXp = curXp; lastXpChange = os.clock()
        elseif os.clock() - lastXpChange > 12 then
            stopTraining(); startTraining(); lastXpChange = os.clock()
        elseif ClientState.Busy ~= "Training" then
            startTraining()
        end
        task.wait(0.75)
    end
    if farmGen == myGen then
        stopTraining()
        notify("Level Phase complete", string.format("Level %d reached", level()), 4)
    end
end

local function throwPhase(myGen)
    local tier = getTierStep()
    notify("Throw Phase", string.format("Performing %d throws", tier), 4)
    local done, attempts = 0, 0
    local maxAttempts = tier * 5 + 10
    while alive() and state.autoFarm and farmGen == myGen and done < tier and attempts < maxAttempts do
        attempts = attempts + 1
        if doThrow(state.farmCutscene) then done = done + 1 end
        task.wait(state.throwCooldown)
    end
end

local function generalFarmLoop()
    farmGen = farmGen + 1
    local myGen = farmGen
    while alive() and state.autoFarm and farmGen == myGen do
        pcall(function() trainingPhase(myGen) end)
        if not (alive() and state.autoFarm and farmGen == myGen) then break end
        pcall(function() throwPhase(myGen) end)
        task.wait(0.5)
    end
end

local function startLoop(fn)
    task.spawn(function()
        local ok, err = pcall(fn)
        if not ok then warn("[ZHOAN HUB] loop error: "..tostring(err)) end
    end)
end

local bonusConn = remotes.Training_Bonus.OnClientEvent:Connect(function(id)
    if state.autoX2 then pcall(function() return remotes.Training_TapBonus:InvokeServer(id) end) end
end)

local function buildUI()
    local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    G.__BA_rayfield = Rayfield
    RayfieldRef = Rayfield
    uiRefs = {}
    local Win = Rayfield:CreateWindow({
        Name = "ZHOAN HUB",
        LoadingTitle = "ZHOAN HUB",
        LoadingSubtitle = "THROW FOOD FOR ANIMALS"
    })
    local Farm = Win:CreateTab("Farm")

    -- QUI HO CAMBIATO IL NOME DELLA SEZIONE E DEL TOGGLE IN "Smart Autofarm"
    Farm:CreateSection("Smart Autofarm")
    uiRefs.farm = Farm:CreateToggle({Name="Smart Autofarm", CurrentValue=state.autoFarm, Flag="BA_Farm", Callback=function(v)
        state.autoFarm=v
        if v then
            state.autoTrain=false
            if uiRefs.train then pcall(function() uiRefs.train:Set(false) end) end
            state.autoX2=true
            if uiRefs.x2 then pcall(function() uiRefs.x2:Set(true) end) end
            startLoop(generalFarmLoop)
        else
            farmGen = farmGen + 1 -- invalidate the running loop
            stopTraining()
        end
    end})
    Farm:CreateSlider({Name="Levels per cycle", Range={1,100}, Increment=1, CurrentValue=state.levelStep, Flag="BA_Lvl", Callback=function(v) state.levelStep=math.floor(v) end})
    Farm:CreateSlider({Name="Throws (tiers) per cycle", Range={1,50}, Increment=1, CurrentValue=state.tierStep, Flag="BA_Tier", Callback=function(v) state.tierStep=math.floor(v) end})
    Farm:CreateToggle({Name="Show cutscene (farm)", CurrentValue=state.farmCutscene, Flag="BA_FarmCut", Callback=function(v)
        state.farmCutscene=v
    end})

    Farm:CreateSection("Auto Throw")
    Farm:CreateToggle({Name="Auto Throw", CurrentValue=state.autoThrow, Flag="BA_Throw", Callback=function(v)
        state.autoThrow=v; if v then startLoop(throwLoop) end
    end})
    Farm:CreateToggle({Name="Show cutscene (throw animation)", CurrentValue=state.cutscene, Flag="BA_Cut", Callback=function(v) state.cutscene=v end})
    Farm:CreateSlider({Name="Delay between throws", Range={0,5}, Increment=0.5, Suffix="s", CurrentValue=state.throwCooldown, Flag="BA_ThrowCd", Callback=function(v) state.throwCooldown=v end})
    Farm:CreateSlider({Name="Meter value (0.92+ PERFECT)", Range={0,1}, Increment=0.01, CurrentValue=state.meterValue, Flag="BA_Meter", Callback=function(v) state.meterValue=v end})

    Farm:CreateSection("Auto Training")
    uiRefs.train = Farm:CreateToggle({Name="Auto Train", CurrentValue=state.autoTrain, Flag="BA_Train", Callback=function(v)
        state.autoTrain=v
        if v then state.autoThrow=false; startLoop(trainLoop) else stopTraining() end
    end})
    uiRefs.x2 = Farm:CreateToggle({Name="Auto X2 (requires Auto Train)", CurrentValue=state.autoX2, Flag="BA_X2", Callback=function(v) state.autoX2=v end})

    Farm:CreateSection("Auto Equip")
    Farm:CreateToggle({Name="Auto Equip Best Pet", CurrentValue=state.autoEquip, Flag="BA_Equip", Callback=function(v)
        state.autoEquip=v; if v then startLoop(equipLoop) end
    end})
    Farm:CreateSlider({Name="Equip interval", Range={2,60}, Increment=1, Suffix="s", CurrentValue=state.equipInterval, Flag="BA_EquipInt", Callback=function(v) state.equipInterval=v end})
    Farm:CreateButton({Name="Equip Best now", Callback=function()
        pcall(function() return remotes.Plot_EquipBest:InvokeServer() end)
        Rayfield:Notify({Title="ZHOAN HUB", Content="Best pet equipped", Duration=3})
    end})

    Farm:CreateSection("Auto Buy (choose)")
    Farm:CreateToggle({Name="Auto Buy Food", CurrentValue=state.autoFood, Flag="BA_Food", Callback=function(v)
        state.autoFood=v; if v then startLoop(foodLoop) end
    end})
    Farm:CreateToggle({Name="Auto Upgrade Fence", CurrentValue=state.autoFence, Flag="BA_Fence", Callback=function(v)
        state.autoFence=v; if v then startLoop(fenceLoop) end
    end})
    Farm:CreateToggle({Name="Auto Upgrade Bar", CurrentValue=state.autoBar, Flag="BA_Bar", Callback=function(v)
        state.autoBar=v; if v then startLoop(barLoop) end
    end})

    local Unbug = Win:CreateTab("Unbug")
    Unbug:CreateSection("GUI Repair")
    Unbug:CreateParagraph({Title="If the GUI bugs out", Content="Press the button: the window is recreated from scratch and all toggles come back, keeping the current settings."})
    Unbug:CreateButton({Name="Regenerate GUI (fix bug)", Callback=function()
        task.spawn(function()
            local old = G.__BA_rayfield; G.__BA_rayfield = nil; RayfieldRef = nil
            if old then pcall(function() old:Destroy() end) end
            task.wait(0.4); buildUI()
        end)
    end})
    Unbug:CreateButton({Name="Restart all scripts", Callback=function()
        task.spawn(function()
            state.autoThrow, state.autoTrain, state.autoFarm, state.autoEquip = false, false, false, false
            state.autoFood, state.autoFence, state.autoBar = false, false, false
            farmGen = farmGen + 1
            pcall(function() remotes.Training_Stop:InvokeServer() end)
            if ClientState.Busy == "Training" then ClientState.Busy = nil end
            local old = G.__BA_rayfield; G.__BA_rayfield = nil; RayfieldRef = nil
            if old then pcall(function() old:Destroy() end) end
            task.wait(0.4); buildUI()
        end)
    end})

    Rayfield:Notify({Title="ZHOAN HUB", Content="THROW FOOD FOR ANIMALS", Duration=4})
end

G.__BA_cleanup = function()
    state.alive = false
    farmGen = farmGen + 1
    pcall(function() bonusConn:Disconnect() end)
    if G.__BA_rayfield then pcall(function() G.__BA_rayfield:Destroy() end) end
    G.__BA_rayfield = nil; RayfieldRef = nil
end

buildUI()
