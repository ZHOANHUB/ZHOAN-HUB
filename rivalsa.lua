

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
	task.wait(0.1)
	LocalPlayer = Players.LocalPlayer
end

-- Executor API references captured once
local _require: any = require
local _setthreadidentity: (number) -> () = setthreadidentity or function() end
local _gethui: () -> Instance? = gethui or function()
	return game:GetService("CoreGui")
end
local _mousemoverel: ((number, number) -> ())? = mousemoverel
local _queue_on_teleport: ((string) -> ())? = queue_on_teleport or queueonteleport
local _clear_teleport_queue: (() -> ())? = clear_teleport_queue or clearteleportqueue
local _isfile: ((string) -> boolean)? = isfile
local _readfile: ((string) -> string)? = readfile
local _writefile: ((string, string) -> ())? = writefile

_setthreadidentity(8)

-- Clean teardown of any previous run in this DataModel
local SHARED_KEY = "__LATTIC_RIVALS_HUB_INSTANCE"
local sharedTbl: any = shared
if type(sharedTbl[SHARED_KEY]) == "table" and type(sharedTbl[SHARED_KEY].teardown) == "function" then
	pcall(sharedTbl[SHARED_KEY].teardown)
end

local alive = true
local connections: { RBXScriptConnection } = {}
local overrides: { { tbl: any, key: string, orig: any } } = {}
local espPool: { [any]: { boxOutline: any, box: any, hpBg: any, hpBar: any, nameText: any, infoText: any, tracer: any, headDot: any } } = {}
local chamsMap: { [Model]: Highlight } = {}
local origHitboxes: { [BasePart]: { size: Vector3, trans: number, collide: boolean, massless: boolean } } = {}
local origWeaponInfo: { [any]: { [string]: any } } = {}
local noclipTouched: { [BasePart]: boolean } = {}
local extraObjects: { any } = {}
local fluentRef: any = nil
local toggleGui: ScreenGui? = nil

local function trackConn(conn: RBXScriptConnection): RBXScriptConnection
	table.insert(connections, conn)
	return conn
end

local function overrideField(tbl: any, key: string, value: any)
	if not tbl then
		return
	end
	for _, entry in ipairs(overrides) do
		if entry.tbl == tbl and entry.key == key then
			tbl[key] = value
			return
		end
	end
	table.insert(overrides, { tbl = tbl, key = key, orig = tbl[key] })
	tbl[key] = value
end

local function restoreAllHitboxes()
	for part, snap in pairs(origHitboxes) do
		pcall(function()
			if part and part.Parent then
				part.Size = snap.size
				part.Transparency = snap.trans
				part.CanCollide = snap.collide
				part.Massless = snap.massless
			end
		end)
	end
	table.clear(origHitboxes)
end

local function restoreAllWeapons()
	for infoTbl, snap in pairs(origWeaponInfo) do
		pcall(function()
			for k, v in pairs(snap) do
				if k == "__InputSpamStart" then
					if infoTbl.InputSpammingEnabled then
						infoTbl.InputSpammingEnabled.StartShooting = v
					end
				else
					infoTbl[k] = v
				end
			end
		end)
	end
	table.clear(origWeaponInfo)
end

local function removeEspEntry(key: any)
	local entry = espPool[key]
	if not entry then
		return
	end
	for _, drawObj in pairs(entry) do
		pcall(function()
			drawObj:Remove()
		end)
	end
	espPool[key] = nil
end

local function clearAllEsp()
	for k in pairs(espPool) do
		removeEspEntry(k)
	end
end

local function clearAllChams()
	for model, hl in pairs(chamsMap) do
		pcall(function()
			if hl then
				hl:Destroy()
			end
		end)
		chamsMap[model] = nil
	end
end

local function restoreNoclip()
	for part in pairs(noclipTouched) do
		pcall(function()
			if part and part.Parent then
				part.CanCollide = true
			end
		end)
	end
	table.clear(noclipTouched)
end

local function teardown()
	if not alive then
		return
	end
	alive = false

	for _, c in ipairs(connections) do
		pcall(function()
			c:Disconnect()
		end)
	end
	table.clear(connections)

	for i = #overrides, 1, -1 do
		local entry = overrides[i]
		pcall(function()
			entry.tbl[entry.key] = entry.orig
		end)
	end
	table.clear(overrides)

	restoreAllHitboxes()
	restoreAllWeapons()
	clearAllEsp()
	clearAllChams()
	restoreNoclip()

	for _, obj in ipairs(extraObjects) do
		pcall(function()
			if typeof(obj) == "Instance" then
				obj:Destroy()
			elseif type(obj) == "table" and obj.Remove then
				obj:Remove()
			end
		end)
	end
	table.clear(extraObjects)

	pcall(function()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.PlatformStand = false
		end
	end)

	pcall(function()
		_setthreadidentity(8)
		if toggleGui then
			toggleGui:Destroy()
			toggleGui = nil
		end
		if fluentRef and fluentRef.Unload then
			fluentRef:Unload()
		end
		fluentRef = nil
	end)
	if sharedTbl[SHARED_KEY] and sharedTbl[SHARED_KEY].teardown == teardown then
		sharedTbl[SHARED_KEY] = nil
	end
end

sharedTbl[SHARED_KEY] = { teardown = teardown }

-- Wait for RIVALS's own client bootstrap to finish (avoid requiring controllers while LoadingScreen is active)
do
	local waited = false
	local deadline = tick() + 45
	while alive and tick() < deadline do
		local pg = LocalPlayer:FindFirstChild("PlayerGui")
		local ls = pg and pg:FindFirstChild("LoadingScreen")
		local mg = pg and pg:FindFirstChild("MainGui")
		local loadingDone = (ls == nil) or (ls:IsA("ScreenGui") and not ls.Enabled)
		local gameReady = (mg ~= nil and mg:IsA("ScreenGui") and mg.Enabled) or (Workspace:FindFirstChild("ViewModels") ~= nil)
		if game:IsLoaded() and loadingDone and gameReady then
			break
		end
		waited = true
		task.wait(0.25)
	end
	if waited and alive then
		task.wait(0.6)
	end
	if not alive then
		return
	end
end

-- Wait for RIVALS controllers & modules
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
local ControllersFolder: any = PlayerScripts:WaitForChild("Controllers")
local ModulesFolder: any = PlayerScripts:WaitForChild("Modules")
local RSModules: any = ReplicatedStorage:WaitForChild("Modules")
local RSRemotes: any = ReplicatedStorage:WaitForChild("Remotes")

local Utility: any = _require(RSModules:WaitForChild("Utility"))
local GameplayUtility: any = _require(RSModules:WaitForChild("GameplayUtility"))
local CONSTANTS: any = _require(RSModules:WaitForChild("CONSTANTS"))

local FighterController: any = _require(ControllersFolder:WaitForChild("FighterController"))
local EnemyController: any = _require(ControllersFolder:WaitForChild("EnemyController"))
local DuelController: any = _require(ControllersFolder:WaitForChild("DuelController"))
local MechanicsController: any = _require(ControllersFolder:WaitForChild("MechanicsController"))
local CameraController: any = _require(ControllersFolder:WaitForChild("CameraController"))
local ArcadeController: any = _require(ControllersFolder:WaitForChild("ArcadeController"))
local MatchmakingController: any = _require(ControllersFolder:WaitForChild("MatchmakingController"))
local DebugController: any = _require(ControllersFolder:WaitForChild("DebugController"))
local Pages: any = _require((ModulesFolder:WaitForChild("UserInterface")):WaitForChild("Pages"))

local ClientFighterDir: any = (ModulesFolder:WaitForChild("ClientReplicatedClasses")):WaitForChild("ClientFighter")
local FighterInterfaceDir: any = ClientFighterDir:WaitForChild("FighterInterface")
local FlashedMod: any = _require(FighterInterfaceDir:WaitForChild("Flashed"))
local SmokeScreenMod: any = _require(FighterInterfaceDir:WaitForChild("SmokeScreen"))

local LocalFighter = FighterController:WaitForLocalFighter()
if not alive then
	return
end
_setthreadidentity(8)

-- Persistent Config
local CONFIG_FILE = "lattic_rivals_hub_config.json"
local PERSIST_FILE = "lattic_rivals_hub_persist.luau"

local cfg: { [string]: any } = {
	-- Combat
	SilentAim = true,
	HitboxMode = "Head (Auto Headshot)",
	TargetPriority = "Closest to Crosshair",
	UnlimitedFov = false,
	SilentFov = 220,
	VisCheckSilent = true,
	ProjectilePrediction = true,
	AutoShoot = false,
	AutoShootDelayMs = 25,
	CameraAimbot = false,
	AimbotMode = "Hold MB2",
	AimbotMethod = "Camera",
	AimbotSmooth = 1,
	ShowFov = true,
	FovColor = { 0, 220, 255 },

	-- Rage / Exploits
	RageOrbit = false,
	OrbitDistance = 10,
	OrbitHeight = 4,
	OrbitSpeed = 4,
	HitboxExpander = false,
	HitboxSize = 7,
	HitboxTransparency = 0.65,
	MeleeAura = false,
	IncludeEntities = true,
	IncludeProps = false,

	-- Weapons
	RapidFire = true,
	FireDelayMs = 25,
	NoSpread = true,
	NoRecoil = true,
	FullAutoAll = true,

	-- Movement
	SpeedEnabled = true,
	WalkSpeed = 42,
	InfiniteJump = true,
	JumpPower = 42,
	FlyEnabled = false,
	FlySpeed = 75,
	NoclipEnabled = false,
	NoSlideCooldown = true,

	-- Visuals & Protections
	EspBox = true,
	EspHealth = true,
	EspInfo = true,
	EspTracer = false,
	EspHeadDot = true,
	EspColor = { 255, 70, 70 },
	ChamsEnabled = true,
	ChamsColor = { 255, 50, 100 },
	AntiFlash = true,
	AntiSmoke = true,
	NoCamShake = true,
	ThirdPerson = false,
	CustomFovEnabled = false,
	CustomFov = 100,
	ShowDebugHitboxes = false,
	ShowDebugBarriers = false,

	-- Match & Misc
	AutoRespawn = true,
	AutoPickLoadout = false,
	AutoPickPreset = "Assault Rifle + Handgun",
	AutoPersistTeleport = true,
}

local function loadConfig()
	if _isfile and _readfile and _isfile(CONFIG_FILE) then
		local ok, decoded = pcall(function()
			return HttpService:JSONDecode(_readfile(CONFIG_FILE))
		end)
		if ok and type(decoded) == "table" then
			for k, v in pairs(decoded) do
				if cfg[k] ~= nil then
					if typeof(cfg[k]) == typeof(v) then
						cfg[k] = v
					elseif type(cfg[k]) == "number" and tonumber(v) then
						cfg[k] = tonumber(v)
					end
				end
			end
		end
	end
end

local saveScheduled = false
local function saveConfig()
	if not _writefile or saveScheduled then
		return
	end
	saveScheduled = true
	task.delay(0.25, function()
		saveScheduled = false
		if not alive or not _writefile then
			return
		end
		pcall(function()
			_writefile(CONFIG_FILE, HttpService:JSONEncode(cfg))
		end)
	end)
end

loadConfig()

-- Teleport persistence helper (proactive queue + OnTeleport safety net)
local function syncTeleportQueue()
	if _clear_teleport_queue then
		pcall(_clear_teleport_queue)
	end
	if not cfg.AutoPersistTeleport or not _queue_on_teleport then
		return
	end
	if _isfile and _isfile(PERSIST_FILE) then
		pcall(_queue_on_teleport, [[
			if setthreadidentity then pcall(setthreadidentity, 8) end
			if not game:IsLoaded() then game.Loaded:Wait() end
			task.wait(1.5)
			if setthreadidentity then pcall(setthreadidentity, 8) end
			if isfile and isfile("lattic_rivals_hub_persist.luau") then
				local fn = loadstring(readfile("lattic_rivals_hub_persist.luau"))
				if fn then fn() end
			end
		]])
	end
end

syncTeleportQueue()
trackConn(LocalPlayer.OnTeleport:Connect(function(state: Enum.TeleportState)
	if state == Enum.TeleportState.Started and cfg.AutoPersistTeleport then
		syncTeleportQueue()
	end
end))

-- Helpers
local function toColor3(rgb: { number }): Color3
	return Color3.fromRGB(rgb[1] or 255, rgb[2] or 255, rgb[3] or 255)
end

local function fromColor3(c: Color3): { number }
	return { math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5) }
end

local function getAimScreenCenter(): Vector2
	local cam = Workspace.CurrentCamera
	if cam then
		return cam.ViewportSize / 2
	end
	return UserInputService:GetMouseLocation()
end

local function isMenuBlockingInput(): boolean
	if Pages and Pages.PageSystem and Pages.PageSystem.CurrentPage then
		return true
	end
	if UserInputService:GetFocusedTextBox() then
		return true
	end
	return false
end

local function getTargetPart(entity: any, model: Model, mode: string): BasePart?
	if mode == "Body" then
		return (model:FindFirstChild("HitboxBody") :: BasePart?)
			or (model:FindFirstChild("UpperTorso") :: BasePart?)
			or entity.RootPart
	elseif mode == "Smart (80% Head)" then
		if math.random() < 0.8 then
			return (model:FindFirstChild("HitboxHead") :: BasePart?)
				or (model:FindFirstChild("Head") :: BasePart?)
				or entity.RootPart
		end
		return (model:FindFirstChild("HitboxBody") :: BasePart?)
			or (model:FindFirstChild("UpperTorso") :: BasePart?)
			or entity.RootPart
	elseif mode == "Random" then
		local pool: { BasePart } = {}
		for _, name in ipairs({ "HitboxHead", "HitboxBody", "Head", "UpperTorso" }) do
			local p = model:FindFirstChild(name)
			if p and p:IsA("BasePart") then
				table.insert(pool, p)
			end
		end
		if #pool > 0 then
			return pool[math.random(1, #pool)]
		end
		return entity.RootPart
	end
	return (model:FindFirstChild("HitboxHead") :: BasePart?)
		or (model:FindFirstChild("Head") :: BasePart?)
		or (model:FindFirstChild("HitboxHeadSmall") :: BasePart?)
		or entity.RootPart
end

local cachedEnvId: any = nil
local cachedWhitelist: { Instance } = {}
local nextWhitelistFetch = 0

local function getMapWhitelist(envId: any): { Instance }
	local now = tick()
	if now > nextWhitelistFetch or envId ~= cachedEnvId then
		nextWhitelistFetch = now + 2
		cachedEnvId = envId
		local ok, wl = pcall(function()
			return GameplayUtility:GetRaycastWhitelist(envId)
		end)
		if ok and type(wl) == "table" then
			cachedWhitelist = wl
		else
			cachedWhitelist = {}
		end
	end
	return cachedWhitelist
end

local function hasLineOfSight(originPos: Vector3, targetPos: Vector3, lf: any, targetModel: Model): boolean
	local myEnv = lf and lf:Get("EnvironmentID")
	local mapWl = getMapWhitelist(myEnv)
	local dir = targetPos - originPos
	if dir.Magnitude < 0.01 then
		return true
	end
	if #mapWl > 0 then
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances = mapWl
		params.IgnoreWater = true
		local hit = Workspace:Raycast(originPos, dir, params)
		return hit == nil
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local excl: { Instance } = { targetModel }
	if lf and lf.Entity and lf.Entity.Model then
		table.insert(excl, lf.Entity.Model)
	end
	local vm = Workspace:FindFirstChild("ViewModels")
	if vm then
		table.insert(excl, vm)
	end
	params.FilterDescendantsInstances = excl
	params.IgnoreWater = true
	local hit = Workspace:Raycast(originPos, dir, params)
	return hit == nil
end

type TargetEntry = {
	key: any,
	name: string,
	isPlayer: boolean,
	fighter: any?,
	entity: any,
	model: Model,
	root: BasePart,
	hp: number,
	maxHp: number,
	weaponName: string,
}

local function collectValidTargets(): { TargetEntry }
	local targets: { TargetEntry } = {}
	local lf = FighterController.LocalFighter
	if not lf then
		return targets
	end

	local myEnv = lf:Get("EnvironmentID")
	local myTeam = lf:Get("TeamID") or LocalPlayer:GetAttribute("TeamID")
	local teamkill = lf:Get("TeamkillEnabled")
	local inShootingRange = lf:Get("IsInShootingRange")
	local inDuel = lf:Get("IsInDuel")

	-- Player fighters
	local inArcadeMatch = ArcadeController and ArcadeController.CurrentDuel ~= nil
	if inDuel or inShootingRange or myEnv ~= nil or inArcadeMatch then
		for _, f in pairs(FighterController.Objects) do
			if f ~= lf and not f.IsLocalPlayer and f:IsAlive() then
				local ent = f.Entity
				if ent and ent.Model and ent.RootPart and not ent:Get("IsInvincible") then
					local fEnv = f:Get("EnvironmentID")
					local fighterActive = (myEnv ~= nil and fEnv == myEnv) or (myEnv == nil and f:Get("IsInDuel"))
					if fighterActive then
						local fTeam = f:Get("TeamID") or (f.Player and f.Player:GetAttribute("TeamID"))
						local isAlly = (not teamkill) and myTeam ~= nil and fTeam ~= nil and fTeam == myTeam
						if not isAlly then
							local hp = 100
							local maxHp = 100
							pcall(function()
								hp = f:GetHealth()
								maxHp = f:GetMaxHealth()
							end)
							local wName = ""
							if f.EquippedItem and f.EquippedItem.Name then
								wName = tostring(f.EquippedItem.Name)
							end
							table.insert(targets, {
								key = f,
								name = (f.Player and f.Player.Name) or "Player",
								isPlayer = true,
								fighter = f,
								entity = ent,
								model = ent.Model,
								root = ent.RootPart,
								hp = hp,
								maxHp = math.max(1, maxHp),
								weaponName = wName,
							})
						end
					end
				end
			end
		end
	end

	-- PvE / Shooting Range entities
	if cfg.IncludeEntities then
		for _, ent in pairs(EnemyController.Objects) do
			if ent and ent:IsAlive() and ent.Model and ent.RootPart and not ent:Get("IsInvincible") then
				local hasHum = ent.Model:FindFirstChildOfClass("Humanoid") ~= nil
				if hasHum or cfg.IncludeProps then
					local eEnv = ent:Get("EnvironmentID")
					if myEnv == nil or eEnv == myEnv then
						local hp = 100
						local maxHp = 100
						pcall(function()
							hp = ent:GetHealth()
							maxHp = ent:GetMaxHealth()
						end)
						local cleanName = ent.Model.Name:gsub("%s*%[%-?%d+%]", "")
						table.insert(targets, {
							key = ent,
							name = cleanName,
							isPlayer = false,
							fighter = nil,
							entity = ent,
							model = ent.Model,
							root = ent.RootPart,
							hp = hp,
							maxHp = math.max(1, maxHp),
							weaponName = if hasHum then "NPC" else "Prop",
						})
					end
				end
			end
		end
	end

	return targets
end

local function selectBestTarget(
	fovLimit: number,
	unlimitedFov: boolean,
	priorityMode: string,
	requireLos: boolean,
	originOverride: Vector3?,
	maxDistOverride: number?
): (TargetEntry?, BasePart?)
	local lf = FighterController.LocalFighter
	local cam = Workspace.CurrentCamera
	if not lf or not lf.Entity or not lf.Entity.RootPart or not cam then
		return nil, nil
	end

	local camPos = originOverride or cam.CFrame.Position
	local maxDist = maxDistOverride or (CONSTANTS.MAX_RAYCAST_DISTANCE or 400)
	local aimCenter = getAimScreenCenter()
	local bestEntry: TargetEntry? = nil
	local bestPart: BasePart? = nil
	local bestScore = math.huge

	for _, entry in ipairs(collectValidTargets()) do
		local part = getTargetPart(entry.entity, entry.model, cfg.HitboxMode)
		if part then
			local worldDist = (part.Position - camPos).Magnitude
			if worldDist <= maxDist then
				local vp, onScreen = cam:WorldToViewportPoint(part.Position)
				local screenDist = (Vector2.new(vp.X, vp.Y) - aimCenter).Magnitude
				local inFov = unlimitedFov or (onScreen and vp.Z > 0 and screenDist <= fovLimit)

				if inFov then
					local losOk = true
					if requireLos then
						losOk = hasLineOfSight(camPos, part.Position, lf, entry.model)
					end
					if losOk then
						local score: number
						if priorityMode == "Closest Distance" then
							score = worldDist
						elseif priorityMode == "Lowest Health" then
							score = entry.hp
						else
							if not onScreen or vp.Z <= 0 then
								score = 10000 + worldDist
							else
								score = screenDist
							end
						end
						if score < bestScore then
							bestScore = score
							bestEntry = entry
							bestPart = part
						end
					end
				end
			end
		end
	end

	return bestEntry, bestPart
end

local function computeAimPos(entry: TargetEntry, part: BasePart, originPos: Vector3, equipped: any): Vector3
	local aimPos = part.Position
	if cfg.ProjectilePrediction and equipped and equipped.Info and equipped.Info.IsProjectile and not equipped.Info.IsRaycast then
		local speed = equipped.Info.ProjectileSpeed or 300
		if speed > 1 then
			local dist = (aimPos - originPos).Magnitude
			local travelTime = dist / speed
			local vel = entry.root.AssemblyLinearVelocity
			aimPos = aimPos + vel * travelTime
		end
	end
	return aimPos
end

-- Hook ClientFighter.GetCameraData (Silent Aim + Auto Headshot + Grenades + Melee)
local fighterMeta = getmetatable(LocalFighter)
if fighterMeta and type(fighterMeta.GetCameraData) == "function" then
	local origGetCameraData = fighterMeta.GetCameraData
	overrideField(fighterMeta, "GetCameraData", function(self: any, whitelist: any, spread: any, raw: any)
		if not alive or not cfg.SilentAim or self ~= FighterController.LocalFighter then
			return origGetCameraData(self, whitelist, spread, raw)
		end

		local cam = Workspace.CurrentCamera
		if not cam then
			return origGetCameraData(self, whitelist, spread, raw)
		end

		local originPos = cam.CFrame.Position
		if cfg.RageOrbit and self.Entity and self.Entity.RootPart then
			originPos = self.Entity.RootPart.Position + Vector3.new(0, 1.5, 0)
		end

		local useUnlimited = cfg.UnlimitedFov or cfg.RageOrbit
		local target, targetPart = selectBestTarget(cfg.SilentFov, useUnlimited, cfg.TargetPriority, cfg.VisCheckSilent, originPos)
		if not target or not targetPart then
			return origGetCameraData(self, whitelist, spread, raw)
		end

		local aimPos = computeAimPos(target, targetPart, originPos, self.EquippedItem)
		if (aimPos - originPos).Magnitude < 0.01 then
			return origGetCameraData(self, whitelist, spread, raw)
		end

		local lookCF = CFrame.lookAt(originPos, aimPos)
		if raw then
			local resRaw: { [string]: any } = {
				[utf8.char(0)] = lookCF,
				[utf8.char(1)] = lookCF,
				[utf8.char(2)] = targetPart,
				[utf8.char(3)] = CFrame.identity,
			}
			return resRaw
		end

		local resEnc: { [string]: any } = {
			[utf8.char(0)] = Utility:EncodeCFrame(lookCF),
			[utf8.char(1)] = Utility:EncodeCFrame(lookCF),
			[utf8.char(2)] = targetPart,
			[utf8.char(3)] = Utility:EncodeCFrame(CFrame.identity),
		}
		return resEnc
	end)
end

-- Hook MechanicsController._GetWalkSpeed
if type(MechanicsController._GetWalkSpeed) == "function" then
	local origGetWalkSpeed = MechanicsController._GetWalkSpeed
	overrideField(MechanicsController, "_GetWalkSpeed", function(self: any, a2: any)
		if alive and cfg.SpeedEnabled and not self:IsFrozen() then
			return cfg.WalkSpeed
		end
		return origGetWalkSpeed(self, a2)
	end)
end

-- Hook CameraController.Shake / ShakeOnce
if type(CameraController.Shake) == "function" then
	local origShake = CameraController.Shake
	overrideField(CameraController, "Shake", function(self: any, ...)
		if alive and cfg.NoCamShake then
			return
		end
		return origShake(self, ...)
	end)
end
if type(CameraController.ShakeOnce) == "function" then
	local origShakeOnce = CameraController.ShakeOnce
	overrideField(CameraController, "ShakeOnce", function(self: any, ...)
		if alive and cfg.NoCamShake then
			return
		end
		return origShakeOnce(self, ...)
	end)
end

-- Hook Anti-Flashbang
if type(FlashedMod.AttemptToFlash) == "function" then
	local origAttempt = FlashedMod.AttemptToFlash
	overrideField(FlashedMod, "AttemptToFlash", function(self: any, ...)
		if alive and cfg.AntiFlash then
			return
		end
		return origAttempt(self, ...)
	end)
end
if type(FlashedMod.Flash) == "function" then
	local origFlash = FlashedMod.Flash
	overrideField(FlashedMod, "Flash", function(self: any, ...)
		if alive and cfg.AntiFlash then
			return
		end
		return origFlash(self, ...)
	end)
end

-- Hook Anti-Smoke
if type(SmokeScreenMod.Update) == "function" then
	local origSmokeUpdate = SmokeScreenMod.Update
	overrideField(SmokeScreenMod, "Update", function(self: any, a2: any, a3: any)
		if alive and cfg.AntiSmoke then
			self:Hide()
			return
		end
		return origSmokeUpdate(self, a2, a3)
	end)
end
if type(GameplayUtility.GetSmokeCloudBetweenPoints) == "function" then
	local origBetween = GameplayUtility.GetSmokeCloudBetweenPoints
	overrideField(GameplayUtility, "GetSmokeCloudBetweenPoints", function(self: any, p1: Vector3, p2: Vector3)
		if alive and cfg.AntiSmoke then
			return nil
		end
		return origBetween(self, p1, p2)
	end)
end
if type(GameplayUtility.GetSmokeCloudsInSphere) == "function" then
	local origInSphere = GameplayUtility.GetSmokeCloudsInSphere
	overrideField(GameplayUtility, "GetSmokeCloudsInSphere", function(self: any, ...)
		if alive and cfg.AntiSmoke then
			return {}
		end
		return origInSphere(self, ...)
	end)
end

-- Weapon Info Modifier
local function applyWeaponMods()
	local lf = FighterController.LocalFighter
	if not lf or not lf.Items then
		return
	end
	for _, item in pairs(lf.Items) do
		local info = item and item.Info
		if type(info) == "table" and info.Type == "Gun" then
			if not origWeaponInfo[info] then
				origWeaponInfo[info] = {
					ShootCooldown = info.ShootCooldown,
					BurstCooldown = info.BurstCooldown,
					QuickShotCooldown = info.QuickShotCooldown,
					ShootSpread = info.ShootSpread,
					QuickShotSpread = info.QuickShotSpread,
					AimSpreadMultiplier = info.AimSpreadMultiplier,
					ShootSpreadPerVelocityLimit = info.ShootSpreadPerVelocityLimit,
					ShootSpreadPerVelocityUnit = info.ShootSpreadPerVelocityUnit,
					ShootRecoil = info.ShootRecoil,
					ShootCameraDisplacementRecoil = info.ShootCameraDisplacementRecoil,
					ShootCameraDisplacementRecoilWhileAiming = info.ShootCameraDisplacementRecoilWhileAiming,
					__InputSpamStart = info.InputSpammingEnabled and info.InputSpammingEnabled.StartShooting,
				}
			end
			local orig = origWeaponInfo[info]

			if cfg.RapidFire then
				local delaySec = math.clamp(cfg.FireDelayMs, 15, 200) / 1000
				info.ShootCooldown = math.min(orig.ShootCooldown or delaySec, delaySec)
				if orig.BurstCooldown then
					info.BurstCooldown = math.min(orig.BurstCooldown, delaySec)
				end
				if orig.QuickShotCooldown then
					info.QuickShotCooldown = math.min(orig.QuickShotCooldown, delaySec)
				end
			else
				info.ShootCooldown = orig.ShootCooldown
				info.BurstCooldown = orig.BurstCooldown
				info.QuickShotCooldown = orig.QuickShotCooldown
			end

			if cfg.NoSpread then
				info.ShootSpread = 0
				info.QuickShotSpread = 0
				info.AimSpreadMultiplier = 0
				info.ShootSpreadPerVelocityLimit = 0
				info.ShootSpreadPerVelocityUnit = 0
			else
				info.ShootSpread = orig.ShootSpread
				info.QuickShotSpread = orig.QuickShotSpread
				info.AimSpreadMultiplier = orig.AimSpreadMultiplier
				info.ShootSpreadPerVelocityLimit = orig.ShootSpreadPerVelocityLimit
				info.ShootSpreadPerVelocityUnit = orig.ShootSpreadPerVelocityUnit
			end

			if cfg.NoRecoil then
				info.ShootRecoil = 0
				info.ShootCameraDisplacementRecoil = Vector2.zero
				info.ShootCameraDisplacementRecoilWhileAiming = Vector2.zero
			else
				info.ShootRecoil = orig.ShootRecoil
				info.ShootCameraDisplacementRecoil = orig.ShootCameraDisplacementRecoil
				info.ShootCameraDisplacementRecoilWhileAiming = orig.ShootCameraDisplacementRecoilWhileAiming
			end

			if info.InputSpammingEnabled then
				if cfg.FullAutoAll or cfg.RapidFire then
					info.InputSpammingEnabled.StartShooting = 0
				else
					info.InputSpammingEnabled.StartShooting = orig.__InputSpamStart
				end
			end
		end
	end
end

-- Camera & Visual Helpers
local function applyCameraPrefs()
	pcall(function()
		CameraController:SetThirdPersonOverride(if cfg.ThirdPerson then true else nil)
		CameraController:SetExternalFOVOffset("LatticHubFOV", if cfg.CustomFovEnabled then (cfg.CustomFov - 80) else 0)
	end)
	_setthreadidentity(8)
end

-- Build Rayfield Gen2 UI
_setthreadidentity(8)
local Rayfield: any = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
_setthreadidentity(8)

local Window: any = Rayfield:CreateWindow({
	name = "LATTIC RIVALS HUB",
	subtitle = "Combat • Rage • Weapons • Movement • Visuals",
	sidebarLayout = true,
	theme = "Default",
})

fluentRef = Window

local Tabs = {
	Combat = Window:CreateTab({ name = "Combat" }),
	Rage = Window:CreateTab({ name = "Rage / TP" }),
	Weapons = Window:CreateTab({ name = "Weapons" }),
	Movement = Window:CreateTab({ name = "Movement" }),
	Visuals = Window:CreateTab({ name = "Visuals" }),
	Match = Window:CreateTab({ name = "Match & Misc" }),
}

local Options: any = {}
sharedTbl[SHARED_KEY].options = Options
sharedTbl[SHARED_KEY].cfg = cfg
sharedTbl[SHARED_KEY].window = Window

local function addToggle(tab: any, id: string, title: string, desc: string, cfgKey: string, onChange: ((boolean) -> ())?)
	local handle = tab:CreateToggle({
		name = title,
		description = desc,
		flag = id,
		value = cfg[cfgKey],
		callback = function(value: boolean)
			_setthreadidentity(8)
			Options[id] = Options[id] or {}
			Options[id].Value = value
			cfg[cfgKey] = value
			saveConfig()
			if onChange then
				onChange(value)
				_setthreadidentity(8)
			end
		end,
	})
	Options[id] = { Value = cfg[cfgKey] }
	return {
		SetValue = function(_, value: boolean)
			handle:Set(value)
		end,
		Handle = handle,
	}
end

local function addSlider(tab: any, id: string, title: string, desc: string, cfgKey: string, minV: number, maxV: number, rounding: number, onChange: ((number) -> ())?)
	return tab:CreateSlider({
		name = title,
		description = desc,
		flag = id,
		value = cfg[cfgKey],
		range = { minV, maxV },
		increment = 10 ^ (-rounding),
		callback = function(value: number)
			_setthreadidentity(8)
			local num = tonumber(value) or tonumber(cfg[cfgKey]) or 0
			cfg[cfgKey] = num
			saveConfig()
			if onChange then
				onChange(num)
				_setthreadidentity(8)
			end
		end,
	})
end

local function addDropdown(tab: any, id: string, title: string, desc: string, values: { string }, cfgKey: string, callback: ((string) -> ())?)
	return tab:CreateDropdown({
		name = title,
		description = desc,
		flag = id,
		options = values,
		value = cfg[cfgKey],
		multiSelect = false,
		callback = function(value: any)
			local selected = if type(value) == "table" then value[1] else value
			if selected == nil then
				return
			end
			cfg[cfgKey] = selected
			saveConfig()
			if callback then
				callback(selected)
			end
		end,
	})
end

local function addKeybind(tab: any, title: string, defaultKey: string, callback: () -> ())
	return tab:CreateKeybind({
		name = title,
		value = defaultKey,
		callback = function()
			_setthreadidentity(8)
			callback()
		end,
	})
end

local function addColorPicker(tab: any, title: string, initialColor: Color3, callback: (Color3) -> ())
	return tab:CreateColorPicker({
		name = title,
		color = initialColor,
		callback = function(color: Color3)
			callback(color)
		end,
	})
end

local function notify(title: string, content: string, duration: number?)
	Window:Notify({
		title = title,
		content = content,
		duration = duration or 3,
	})
end

-- === TAB 1: COMBAT ===
do
	Tabs.Combat:CreateSection({ name = "Silent Aim (Server-Accepted)" })
	addToggle(Tabs.Combat, "SilentAim", "Silent Aim (Auto Headshot)", "Redirects bullets/throwables directly to target hitbox without moving camera", "SilentAim")

	addDropdown(Tabs.Combat, "HitboxMode", "Target Hitbox", "Select the target hitbox", { "Head (Auto Headshot)", "Body", "Smart (80% Head)", "Random" }, "HitboxMode")
	addDropdown(Tabs.Combat, "TargetPriority", "Target Selection", "Choose target priority", { "Closest to Crosshair", "Closest Distance", "Lowest Health" }, "TargetPriority")

	addToggle(Tabs.Combat, "UnlimitedFov", "360° Unlimited FOV", "Lock enemies anywhere around you ignoring FOV radius", "UnlimitedFov")
	addSlider(Tabs.Combat, "SilentFov", "FOV Radius (px)", "Screen radius when 360° FOV is off", "SilentFov", 30, 800, 0)
	addToggle(Tabs.Combat, "VisCheckSilent", "Wall / LOS Check", "Only target enemies with clear line of sight", "VisCheckSilent")
	addToggle(Tabs.Combat, "ProjectilePrediction", "Projectile Velocity Prediction", "Predict moving targets for Bow / RPG / Crossbow / Paintball", "ProjectilePrediction")

	Tabs.Combat:CreateSection({ name = "Triggerbot & Camera Aimbot" })
	local autoShootToggle = addToggle(Tabs.Combat, "AutoShoot", "Auto Shoot (Rage Triggerbot)", "Automatically fires at visible targets within FOV", "AutoShoot")
	addKeybind(Tabs.Combat, "Auto Shoot Keybind", "X", function()
		autoShootToggle:SetValue(not Options.AutoShoot.Value)
	end)
	addSlider(Tabs.Combat, "AutoShootDelayMs", "Auto Shoot Delay (ms)", "Interval between auto shots", "AutoShootDelayMs", 15, 150, 0)

	local camAimToggle = addToggle(Tabs.Combat, "CameraAimbot", "Camera Aimbot", "Locks view onto enemy head", "CameraAimbot")
	addDropdown(Tabs.Combat, "AimbotMode", "Aimbot Activation", "Choose when the aimbot activates", { "Hold MB2", "Always" }, "AimbotMode")
	addDropdown(Tabs.Combat, "AimbotMethod", "Aimbot Method", "Choose camera or mouse movement", { "Camera", "Mouse" }, "AimbotMethod")
	addSlider(Tabs.Combat, "AimbotSmooth", "Aimbot Smoothness", "1 = instant snap lock, higher = smoother", "AimbotSmooth", 1, 20, 0)
	addKeybind(Tabs.Combat, "Toggle Camera Aimbot", "Q", function()
		camAimToggle:SetValue(not Options.CameraAimbot.Value)
	end)

	Tabs.Combat:CreateSection({ name = "FOV Circle" })
	addToggle(Tabs.Combat, "ShowFov", "Draw FOV Circle", "Show aiming circle on viewport", "ShowFov")
	addColorPicker(Tabs.Combat, "FOV Circle Color", toColor3(cfg.FovColor), function(color)
		cfg.FovColor = fromColor3(color)
		saveConfig()
	end)
end

-- === TAB 2: RAGE / TP ===
do
	Tabs.Rage:CreateSection({ name = "Teleport & Orbit Exploits" })
	local orbitToggle = addToggle(Tabs.Rage, "RageOrbit", "Rage Orbit / Behind Enemy", "Continuously teleports behind/above closest alive enemy", "RageOrbit")
	addKeybind(Tabs.Rage, "Rage Orbit Keybind", "Z", function()
		orbitToggle:SetValue(not Options.RageOrbit.Value)
	end)
	addSlider(Tabs.Rage, "OrbitDistance", "Orbit Distance", "Studs behind/around target", "OrbitDistance", 3, 25, 1)
	addSlider(Tabs.Rage, "OrbitHeight", "Orbit Height Offset", "Studs above target", "OrbitHeight", 0, 15, 1)
	addSlider(Tabs.Rage, "OrbitSpeed", "Orbit Speed", "0 = stay directly behind back, >0 = circle around", "OrbitSpeed", 0, 12, 1)

	local function tpBehindClosest()
		local lf = FighterController.LocalFighter
		if not lf or not lf:IsAlive() or not lf.Entity or not lf.Entity.RootPart then
			return
		end
		local target = selectBestTarget(9999, true, "Closest Distance", false)
		if target and target.root then
			lf.Entity.RootPart.AssemblyLinearVelocity = Vector3.zero
			lf.Entity.RootPart.CFrame = target.root.CFrame * CFrame.new(0, 2, 7)
		end
	end

	Tabs.Rage:CreateButton({
		name = "TP Behind Closest Enemy",
		description = "Instant one-shot teleport behind closest enemy",
		callback = tpBehindClosest,
	})
	addKeybind(Tabs.Rage, "TP Behind Keybind", "T", tpBehindClosest)

	Tabs.Rage:CreateSection({ name = "Hitbox & Melee Aura" })
	addToggle(Tabs.Rage, "HitboxExpander", "Big Head Hitbox Expander", "Enlarges enemy HitboxHead & Head for easier hits", "HitboxExpander", function(val: boolean)
		if not val then
			restoreAllHitboxes()
		end
	end)
	addSlider(Tabs.Rage, "HitboxSize", "Hitbox Size (studs)", "Expanded head size", "HitboxSize", 2, 16, 1)
	addSlider(Tabs.Rage, "HitboxTransparency", "Hitbox Transparency", "0 = solid, 1 = invisible", "HitboxTransparency", 0, 1, 2)
	addToggle(Tabs.Rage, "MeleeAura", "Melee Kill Aura", "Auto-swings melee weapon when an enemy is within reach", "MeleeAura")
	addToggle(Tabs.Rage, "IncludeEntities", "Target Dummies / PvE Enemies", "Include Shooting Range Dummies, DPS Dummies, and combat NPCs", "IncludeEntities")
	addToggle(Tabs.Rage, "IncludeProps", "Include Range Targets & Glass", "Include Shooting Range bullseye targets and breakable windows", "IncludeProps")
end

-- === TAB 3: WEAPONS ===
do
	Tabs.Weapons:CreateSection({ name = "Weapon Modifiers (Live & Restorable)" })
	addToggle(Tabs.Weapons, "RapidFire", "Rapid Fire", "Overrides ShootCooldown / BurstCooldown / QuickShotCooldown", "RapidFire", function()
		applyWeaponMods()
	end)
	addSlider(Tabs.Weapons, "FireDelayMs", "Fire Delay (ms)", "Lower = faster fire rate (25ms = 40/sec)", "FireDelayMs", 15, 150, 0, function()
		applyWeaponMods()
	end)
	addToggle(Tabs.Weapons, "NoSpread", "No Spread", "Pinpoint accuracy while moving or jumping", "NoSpread", function()
		applyWeaponMods()
	end)
	addToggle(Tabs.Weapons, "NoRecoil", "No Recoil", "Removes gun kick and camera displacement recoil", "NoRecoil", function()
		applyWeaponMods()
	end)
	addToggle(Tabs.Weapons, "FullAutoAll", "Full Auto All Guns", "Hold left click to continuous-fire Handgun / Revolver / Sniper", "FullAutoAll", function()
		applyWeaponMods()
	end)

	Tabs.Weapons:CreateSection({ name = "Quick Pick Weapons (Shooting Range / Pick Prompt)" })
	local function pickLoadout(list: { string })
		pcall(function()
			RSRemotes.Replication.Fighter.PickWeapons:FireServer(list)
			if Pages and Pages.PageSystem then
				Pages.PageSystem:CloseCurrentPage()
			end
		end)
		_setthreadidentity(8)
		notify("Loadout Sent", table.concat(list, ", "), 3)
	end

	Tabs.Weapons:CreateButton({
		name = "Pick Meta Loadout",
		description = "Sniper, Revolver, Knife, Grenade",
		callback = function()
			pickLoadout({ "Sniper", "Revolver", "Knife", "Grenade" })
		end,
	})
	Tabs.Weapons:CreateButton({
		name = "Pick Shredder Loadout",
		description = "Assault Rifle, Exogun, Katana, Molotov",
		callback = function()
			pickLoadout({ "Assault Rifle", "Exogun", "Katana", "Molotov" })
		end,
	})
	Tabs.Weapons:CreateButton({
		name = "Pick Heavy / Energy Loadout",
		description = "Minigun, Energy Pistols, Scythe, Flashbang",
		callback = function()
			pickLoadout({ "Minigun", "Energy Pistols", "Scythe", "Flashbang" })
		end,
	})
	Tabs.Weapons:CreateButton({
		name = "Pick Starter Loadout",
		description = "Assault Rifle, Handgun, Fists, Grenade",
		callback = function()
			pickLoadout({ "Assault Rifle", "Handgun", "Fists", "Grenade" })
		end,
	})
end

-- === TAB 4: MOVEMENT ===
do
	Tabs.Movement:CreateSection({ name = "Speed & Mobility" })
	addToggle(Tabs.Movement, "SpeedEnabled", "WalkSpeed Hack", "Hooks MechanicsController._GetWalkSpeed natively", "SpeedEnabled")
	addSlider(Tabs.Movement, "WalkSpeed", "WalkSpeed", "Default is 16", "WalkSpeed", 16, 140, 0)

	addToggle(Tabs.Movement, "InfiniteJump", "Infinite Air Jump", "Jump infinitely in midair", "InfiniteJump")
	addSlider(Tabs.Movement, "JumpPower", "Jump Power", "Default is 20", "JumpPower", 20, 120, 0)
	addToggle(Tabs.Movement, "NoSlideCooldown", "No Slide Cooldown", "Removes slide cooldown delay", "NoSlideCooldown")

	Tabs.Movement:CreateSection({ name = "Fly & Noclip" })
	local flyToggle = addToggle(Tabs.Movement, "FlyEnabled", "Fly (WASD + Space/LCtrl)", "Smooth camera-relative flight", "FlyEnabled", function(val: boolean)
		if not val then
			local lf = FighterController.LocalFighter
			if lf and lf.Entity and lf.Entity.Humanoid then
				lf.Entity.Humanoid.PlatformStand = false
			end
		end
	end)
	addKeybind(Tabs.Movement, "Fly Keybind", "F", function()
		flyToggle:SetValue(not Options.FlyEnabled.Value)
	end)
	addSlider(Tabs.Movement, "FlySpeed", "Fly Speed", "Studs per second", "FlySpeed", 20, 180, 0)

	local noclipToggle = addToggle(Tabs.Movement, "NoclipEnabled", "Noclip", "Walk/fly through walls", "NoclipEnabled", function(val: boolean)
		if not val then
			restoreNoclip()
		end
	end)
	addKeybind(Tabs.Movement, "Noclip Keybind", "V", function()
		noclipToggle:SetValue(not Options.NoclipEnabled.Value)
	end)
end

-- === TAB 5: VISUALS ===
do
	Tabs.Visuals:CreateSection({ name = "ESP (Drawing API)" })
	addToggle(Tabs.Visuals, "EspBox", "2D Box ESP", "Draws bounding box around enemies", "EspBox")
	addToggle(Tabs.Visuals, "EspHealth", "Health Bar ESP", "Draws dynamic HP bar beside box", "EspHealth")
	addToggle(Tabs.Visuals, "EspInfo", "Name / HP / Weapon / Dist", "Displays target info above/below box", "EspInfo")
	addToggle(Tabs.Visuals, "EspTracer", "Snapline Tracers", "Lines from screen bottom to enemies", "EspTracer")
	addToggle(Tabs.Visuals, "EspHeadDot", "Head Dot", "Marks target Head / HitboxHead", "EspHeadDot")

	addColorPicker(Tabs.Visuals, "ESP Color", toColor3(cfg.EspColor), function(color)
		cfg.EspColor = fromColor3(color)
		saveConfig()
	end)

	Tabs.Visuals:CreateSection({ name = "Chams & Camera" })
	addToggle(Tabs.Visuals, "ChamsEnabled", "Through-Wall Chams", "Highlights enemy models through walls", "ChamsEnabled", function(val: boolean)
		if not val then
			clearAllChams()
		end
	end)
	addColorPicker(Tabs.Visuals, "Chams Color", toColor3(cfg.ChamsColor), function(color)
		cfg.ChamsColor = fromColor3(color)
		saveConfig()
	end)

	addToggle(Tabs.Visuals, "ThirdPerson", "Unlock Third Person", "Forces Third Person toggle access", "ThirdPerson", function()
		applyCameraPrefs()
	end)
	addToggle(Tabs.Visuals, "CustomFovEnabled", "Custom FOV", "Overrides camera base FOV", "CustomFovEnabled", function()
		applyCameraPrefs()
	end)
	addSlider(Tabs.Visuals, "CustomFov", "FOV Value", "70 - 120", "CustomFov", 70, 120, 0, function()
		applyCameraPrefs()
	end)

	Tabs.Visuals:CreateSection({ name = "Protections & Debug" })
	local debugHbApplied = false
	addToggle(Tabs.Visuals, "AntiFlash", "Anti-Flashbang", "Blocks flashbang screen blinding and ringing", "AntiFlash")
	addToggle(Tabs.Visuals, "AntiSmoke", "Anti-Smoke", "Removes smoke blur and lets Aimbot/Triggerbot see through smoke", "AntiSmoke")
	addToggle(Tabs.Visuals, "NoCamShake", "No Camera Shake", "Disables weapon and explosion camera shake", "NoCamShake")
	addToggle(Tabs.Visuals, "ShowDebugHitboxes", "Show Built-in Hitboxes", "Uses DebugController:SetHitboxesVisible", "ShowDebugHitboxes", function(val: boolean)
		if val or debugHbApplied then
			debugHbApplied = true
			pcall(function()
				DebugController:SetHitboxesVisible(val)
			end)
		end
	end)
	local debugBarApplied = false
	addToggle(Tabs.Visuals, "ShowDebugBarriers", "Show Map Barriers", "Uses DebugController:SetMapBarriersVisible", "ShowDebugBarriers", function(val: boolean)
		if val or debugBarApplied then
			debugBarApplied = true
			pcall(function()
				DebugController:SetMapBarriersVisible(val)
			end)
		end
	end)
end

-- === TAB 6: MATCH & MISC ===
do
	_setthreadidentity(8)
	Tabs.Match:CreateSection({ name = "Automation" })
	addToggle(Tabs.Match, "AutoRespawn", "Auto Respawn", "Automatically respawns in TDM / FFA / Duels", "AutoRespawn")
	addToggle(Tabs.Match, "AutoPickLoadout", "Auto Pick Weapons", "Automatically picks weapons when prompt opens", "AutoPickLoadout")

	addDropdown(Tabs.Match, "AutoPickPreset", "Auto Pick Loadout Preset", "Choose the automatic loadout", { "Assault Rifle + Handgun", "Sniper + Revolver", "Minigun + Energy" }, "AutoPickPreset")

	addToggle(Tabs.Match, "AutoPersistTeleport", "Auto-Load Across Teleports", "Re-opens Hub automatically when joining/leaving matches", "AutoPersistTeleport", function()
		syncTeleportQueue()
	end)

	Tabs.Match:CreateSection({ name = "Quick Mode / Server Actions" })
	Tabs.Match:CreateButton({
		name = "Queue 1v1 Duel",
		callback = function()
			pcall(function()
				MatchmakingController:QueueInto("1v1")
			end)
		end,
	})
	Tabs.Match:CreateButton({
		name = "Join Team Deathmatch (Arcade)",
		callback = function()
			pcall(function()
				ArcadeController:ToArcadeServer("arc_teamdeathmatch")
			end)
		end,
	})
	Tabs.Match:CreateButton({
		name = "Join Free For All (Arcade)",
		callback = function()
			pcall(function()
				ArcadeController:ToArcadeServer("arc_freeforall")
			end)
		end,
	})
	Tabs.Match:CreateButton({
		name = "Join Gun Game (Arcade)",
		callback = function()
			pcall(function()
				ArcadeController:ToArcadeServer("arc_gungame")
			end)
		end,
	})
	Tabs.Match:CreateButton({
		name = "Enter Shooting Range",
		callback = function()
			pcall(function()
				RSRemotes.Misc.ShootingRangeEnter:FireServer()
			end)
		end,
	})
	Tabs.Match:CreateButton({
		name = "Leave Shooting Range",
		callback = function()
			pcall(function()
				MatchmakingController.BackToHub:FireServer()
			end)
		end,
	})

	Tabs.Match:CreateSection({ name = "Hub Control" })
	addKeybind(Tabs.Match, "Toggle Rayfield UI", "RightShift", function()
		Window:ToggleMinimise()
	end)
	Tabs.Match:CreateButton({
		name = "Unload LATTIC RIVALS HUB",
		description = "Cleanly restores all hooks, hitboxes, weapons, and closes UI",
		callback = function()
			if _clear_teleport_queue then
				pcall(_clear_teleport_queue)
			end
			teardown()
		end,
	})
end

Tabs.Combat:Select()
applyCameraPrefs()
applyWeaponMods()
_setthreadidentity(8)

-- FOV Circle Drawing (never set NumSides on Real!)
local fovCircle: any = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.Filled = false
fovCircle.Transparency = 0.85
fovCircle.Visible = false
table.insert(extraObjects, fovCircle)

-- Infinite Air Jump Listener
trackConn(UserInputService.JumpRequest:Connect(function()
	if not alive or not cfg.InfiniteJump then
		return
	end
	local lf = FighterController.LocalFighter
	if not lf or not lf:IsAlive() or not lf.Entity or not lf.Entity.RootPart or not lf.Entity.Humanoid then
		return
	end
	if MechanicsController:IsFrozen() or MechanicsController:AreInputsDisabled() then
		return
	end
	local jp = cfg.JumpPower
	lf.Entity.Humanoid.JumpPower = jp
	local state = lf.Entity.Humanoid:GetState()
	if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.FallingDown then
		local vel = lf.Entity.RootPart.AssemblyLinearVelocity
		lf.Entity.RootPart.AssemblyLinearVelocity = Vector3.new(vel.X, jp * 1.45, vel.Z)
		pcall(function()
			lf.Entity:AirborneRedirect()
		end)
	end
end))

-- Noclip Physics Loop
trackConn(RunService.Stepped:Connect(function()
	if not alive or not cfg.NoclipEnabled then
		return
	end
	local lf = FighterController.LocalFighter
	local model = lf and lf.Entity and lf.Entity.Model
	if not model then
		return
	end
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("BasePart") and desc.CanCollide then
			desc.CanCollide = false
			noclipTouched[desc] = true
		end
	end
end))

-- Main Frame Loop (ESP, Chams, Hitbox Expander, Fly, Aimbot, AutoShoot, Orbit, Melee, Protections)
local lastAutoShoot = 0
local lastMeleeSwing = 0
local lastAutoPick = 0
local lastAutoRespawn = 0
local orbitAngle = 0

trackConn(RunService.RenderStepped:Connect(function(dt: number)
	if not alive then
		return
	end

	local lf = FighterController.LocalFighter
	local cam = Workspace.CurrentCamera
	local now = tick()

	-- Keep weapon mods synced on item switch
	applyWeaponMods()

	-- Slide cooldown reset
	if cfg.NoSlideCooldown and MechanicsController._sliding_cooldown then
		MechanicsController._sliding_cooldown = 0
	end

	-- JumpPower keep synced
	if lf and lf.Entity and lf.Entity.Humanoid then
		if cfg.InfiniteJump or cfg.JumpPower ~= 20 then
			lf.Entity.Humanoid.JumpPower = cfg.JumpPower
		end
	end

	-- Anti-Flash guard
	if cfg.AntiFlash then
		local pg = LocalPlayer:FindFirstChild("PlayerGui")
		if pg then
			local fb = pg:FindFirstChild("FlashbangGui")
			if fb then
				fb:Destroy()
			end
		end
		local lfb = Lighting:FindFirstChild("Flashbang")
		if lfb then
			lfb:Destroy()
		end
	end

	-- FOV Circle Update
	if cfg.ShowFov and not cfg.UnlimitedFov and (cfg.SilentAim or cfg.CameraAimbot) and cam then
		fovCircle.Position = getAimScreenCenter()
		fovCircle.Radius = cfg.SilentFov
		fovCircle.Color = toColor3(cfg.FovColor)
		fovCircle.Visible = true
	else
		fovCircle.Visible = false
	end

	-- Collect targets once per frame
	local targets = collectValidTargets()
	local activeKeys: { [any]: boolean } = {}
	local activeModels: { [Model]: boolean } = {}

	-- Update ESP, Chams & Hitbox Expander
	local wantEsp = cfg.EspBox or cfg.EspHealth or cfg.EspInfo or cfg.EspTracer or cfg.EspHeadDot
	local espColor = toColor3(cfg.EspColor)
	local chamsColor = toColor3(cfg.ChamsColor)

	for _, t in ipairs(targets) do
		activeKeys[t.key] = true
		activeModels[t.model] = true

		-- Hitbox Expander
		if cfg.HitboxExpander then
			for _, partName in ipairs({ "HitboxHead", "Head" }) do
				local hpPart = t.model:FindFirstChild(partName)
				if hpPart and hpPart:IsA("BasePart") then
					if not origHitboxes[hpPart] then
						origHitboxes[hpPart] = {
							size = hpPart.Size,
							trans = hpPart.Transparency,
							collide = hpPart.CanCollide,
							massless = hpPart.Massless,
						}
					end
					local s = tonumber(cfg.HitboxSize) or 7
					local trans = tonumber(cfg.HitboxTransparency) or 0.65
					hpPart.Size = Vector3.new(s, s, s)
					hpPart.Transparency = if partName == "HitboxHead" then trans else origHitboxes[hpPart].trans
					hpPart.CanCollide = false
					hpPart.Massless = true
				end
			end
		end

		-- Chams
		if cfg.ChamsEnabled then
			local hl: Highlight? = chamsMap[t.model]
			if not hl or not hl.Parent then
				local newHl = Instance.new("Highlight")
				newHl.Name = "LatticHubChams"
				newHl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				newHl.FillTransparency = 0.55
				newHl.OutlineTransparency = 0.1
				newHl.Adornee = t.model
				newHl.Parent = t.model
				chamsMap[t.model] = newHl
				hl = newHl
			end
			if hl then
				hl.FillColor = chamsColor
				hl.OutlineColor = Color3.new(1, 1, 1)
			end
		end

		-- ESP
		if wantEsp and cam then
			local rootPos = t.root.Position
			local headPart = getTargetPart(t.entity, t.model, "Head (Auto Headshot)")
			local headPos = if headPart then headPart.Position else (rootPos + Vector3.new(0, 2, 0))
			local topWorld = rootPos + Vector3.new(0, 2.7, 0)
			local botWorld = rootPos - Vector3.new(0, 3.1, 0)

			local topVp, topVis = cam:WorldToViewportPoint(topWorld)
			local botVp, botVis = cam:WorldToViewportPoint(botWorld)
			local rootVp, rootVis = cam:WorldToViewportPoint(rootPos)

			local entry = espPool[t.key]
			if not entry then
				local bo: any = Drawing.new("Square")
				bo.Thickness = 3
				bo.Color = Color3.new(0, 0, 0)
				bo.Filled = false
				bo.Transparency = 0.65

				local bx: any = Drawing.new("Square")
				bx.Thickness = 1.4
				bx.Filled = false
				bx.Transparency = 1

				local hbg: any = Drawing.new("Line")
				hbg.Thickness = 4
				hbg.Color = Color3.new(0, 0, 0)
				hbg.Transparency = 0.7

				local hb: any = Drawing.new("Line")
				hb.Thickness = 2
				hb.Transparency = 1

				local nt: any = Drawing.new("Text")
				nt.Size = 14
				nt.Center = true
				nt.Outline = true
				nt.Color = Color3.new(1, 1, 1)

				local it: any = Drawing.new("Text")
				it.Size = 13
				it.Center = true
				it.Outline = true
				it.Color = Color3.fromRGB(200, 230, 255)

				local tr: any = Drawing.new("Line")
				tr.Thickness = 1.2
				tr.Transparency = 0.85

				local hd: any = Drawing.new("Circle")
				hd.Radius = 3.5
				hd.Filled = true
				hd.Thickness = 1
				hd.Transparency = 1

				entry = {
					boxOutline = bo,
					box = bx,
					hpBg = hbg,
					hpBar = hb,
					nameText = nt,
					infoText = it,
					tracer = tr,
					headDot = hd,
				}
				espPool[t.key] = entry
			end

			local onScreen = (topVis or botVis or rootVis) and rootVp.Z > 0 and rootVp.Z < (CONSTANTS.RENDER_DISTANCE or 500)
			if onScreen then
				local height = math.max(12, math.abs(botVp.Y - topVp.Y))
				local width = height * 0.58
				local x = rootVp.X - width / 2
				local y = topVp.Y

				entry.boxOutline.Visible = cfg.EspBox
				entry.box.Visible = cfg.EspBox
				if cfg.EspBox then
					entry.boxOutline.Position = Vector2.new(x, y)
					entry.boxOutline.Size = Vector2.new(width, height)
					entry.box.Position = Vector2.new(x, y)
					entry.box.Size = Vector2.new(width, height)
					entry.box.Color = espColor
				end

				entry.hpBg.Visible = cfg.EspHealth
				entry.hpBar.Visible = cfg.EspHealth
				if cfg.EspHealth then
					local isInfHp = t.hp >= 1e9 or t.maxHp >= 1e9 or t.hp ~= t.hp
					local ratio = if isInfHp then 1 else math.clamp(t.hp / math.max(1, t.maxHp), 0, 1)
					local barX = x - 6
					entry.hpBg.From = Vector2.new(barX, y + height)
					entry.hpBg.To = Vector2.new(barX, y)
					entry.hpBar.From = Vector2.new(barX, y + height)
					entry.hpBar.To = Vector2.new(barX, y + height - height * ratio)
					entry.hpBar.Color = Color3.fromRGB(math.floor(255 * (1 - ratio)), math.floor(255 * ratio), 40)
				end

				entry.nameText.Visible = cfg.EspInfo
				entry.infoText.Visible = cfg.EspInfo
				if cfg.EspInfo then
					local dist = math.floor((rootPos - cam.CFrame.Position).Magnitude)
					local hpText = if t.hp >= 1e9 or t.hp ~= t.hp then "INF" else tostring(math.floor(t.hp))
					entry.nameText.Text = string.format("%s [%s]", t.name, hpText)
					entry.nameText.Position = Vector2.new(rootVp.X, y - 16)
					entry.infoText.Text = if t.weaponName ~= "" then string.format("%s | %dm", t.weaponName, dist) else string.format("%dm", dist)
					entry.infoText.Position = Vector2.new(rootVp.X, y + height + 2)
				end

				entry.tracer.Visible = cfg.EspTracer
				if cfg.EspTracer then
					local vpSize = cam.ViewportSize
					entry.tracer.From = Vector2.new(vpSize.X / 2, vpSize.Y)
					entry.tracer.To = Vector2.new(rootVp.X, y + height)
					entry.tracer.Color = espColor
				end

				local headVp, headVis = cam:WorldToViewportPoint(headPos)
				entry.headDot.Visible = cfg.EspHeadDot and headVis and headVp.Z > 0
				if entry.headDot.Visible then
					entry.headDot.Position = Vector2.new(headVp.X, headVp.Y)
					entry.headDot.Color = Color3.fromRGB(255, 220, 40)
				end
			else
				for _, drawObj in pairs(entry) do
					drawObj.Visible = false
				end
			end
		end
	end

	-- Cleanup stale ESP / Chams
	for k in pairs(espPool) do
		if not activeKeys[k] or not wantEsp then
			removeEspEntry(k)
		end
	end
	for m, hl in pairs(chamsMap) do
		if not activeModels[m] or not cfg.ChamsEnabled then
			pcall(function()
				hl:Destroy()
			end)
			chamsMap[m] = nil
		end
	end

	-- LocalFighter active checks
	if not lf then
		return
	end

	-- Auto Respawn / Auto-Join (TDM / FFA / Duels)
	if cfg.AutoRespawn and now - lastAutoRespawn > 0.75 then
		if not lf:Get("IsInDuel") and ArcadeController.CurrentDuel and ArcadeController:CanJoin() then
			lastAutoRespawn = now
			pcall(function()
				ArcadeController:Join()
			end)
		elseif not lf:IsAlive() then
			lastAutoRespawn = now
			pcall(function()
				local duel = DuelController:GetDuel(LocalPlayer)
				if duel and duel.DuelInterface and duel.DuelInterface.Buttons and duel.DuelInterface.Buttons:IsRespawnNowVisible() then
					RSRemotes.Duels.RespawnNow:FireServer()
				elseif ArcadeController.CurrentDuel and ArcadeController:CanJoin() then
					ArcadeController:Join()
				end
			end)
		end
	end

	-- Auto Pick Weapons
	if cfg.AutoPickLoadout and lf:Get("CanPickWeapons") and #lf.Items == 0 and now - lastAutoPick > 1.2 then
		lastAutoPick = now
		local chosen = { "Assault Rifle", "Handgun", "Fists", "Grenade" }
		if cfg.AutoPickPreset == "Sniper + Revolver" then
			chosen = { "Sniper", "Revolver", "Knife", "Grenade" }
		elseif cfg.AutoPickPreset == "Minigun + Energy" then
			chosen = { "Minigun", "Energy Pistols", "Scythe", "Flashbang" }
		end
		pcall(function()
			RSRemotes.Replication.Fighter.PickWeapons:FireServer(chosen)
			if Pages and Pages.PageSystem then
				Pages.PageSystem:CloseCurrentPage()
			end
		end)
	end

	if not lf:IsAlive() or not lf.Entity or not lf.Entity.RootPart then
		return
	end

	local hrp = lf.Entity.RootPart
	local hum = lf.Entity.Humanoid

	-- Fly
	if cfg.FlyEnabled and hum and not MechanicsController:IsFrozen() and not UserInputService:GetFocusedTextBox() then
		hum.PlatformStand = true
		local moveVec = Vector3.zero
		if cam then
			local cf = cam.CFrame
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				moveVec += cf.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				moveVec -= cf.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				moveVec += cf.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				moveVec -= cf.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				moveVec += Vector3.new(0, 1, 0)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				moveVec -= Vector3.new(0, 1, 0)
			end
		end
		if moveVec.Magnitude > 0.01 then
			moveVec = moveVec.Unit * cfg.FlySpeed
		end
		hrp.AssemblyLinearVelocity = moveVec
		hrp.CFrame = hrp.CFrame + moveVec * dt
	end

	-- Rage Orbit Behind Target
	if cfg.RageOrbit and not MechanicsController:IsFrozen() then
		local target = selectBestTarget(9999, true, "Closest Distance", false, nil, 2000)
		if target and target.root then
			local orbSpeed = tonumber(cfg.OrbitSpeed) or 4
			local orbDist = tonumber(cfg.OrbitDistance) or 10
			local orbHeight = tonumber(cfg.OrbitHeight) or 4
			orbitAngle = (orbitAngle + dt * orbSpeed) % (math.pi * 2)
			local offset: Vector3
			if orbSpeed <= 0.01 then
				offset = Vector3.new(0, orbHeight, orbDist)
			else
				offset = Vector3.new(
					math.cos(orbitAngle) * orbDist,
					orbHeight,
					math.sin(orbitAngle) * orbDist
				)
			end
			local dest = (target.root.CFrame * CFrame.new(offset)).Position
			local mapWl = getMapWhitelist(lf:Get("EnvironmentID"))
			if #mapWl > 0 then
				local p = RaycastParams.new()
				p.FilterType = Enum.RaycastFilterType.Include
				p.FilterDescendantsInstances = mapWl
				p.IgnoreWater = true
				local toDest = dest - target.root.Position
				if toDest.Magnitude > 0.1 then
					local hit = Workspace:Raycast(target.root.Position, toDest, p)
					if hit then
						dest = hit.Position - toDest.Unit * 2
					end
				end
			end
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
			if (dest - target.root.Position).Magnitude > 0.2 then
				hrp.CFrame = CFrame.lookAt(dest, target.root.Position)
			else
				hrp.CFrame = CFrame.new(dest)
			end
		end
	end

	-- Camera Aimbot
	if cfg.CameraAimbot and cam and not isMenuBlockingInput() and not MechanicsController:IsFrozen() then
		local active = (cfg.AimbotMode == "Always")
			or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
		if active then
			local target, part = selectBestTarget(cfg.SilentFov, cfg.UnlimitedFov, cfg.TargetPriority, cfg.VisCheckSilent)
			if target and part then
				local camPos = cam.CFrame.Position
				local aimPos = computeAimPos(target, part, camPos, lf.EquippedItem)
				if (aimPos - camPos).Magnitude > 0.05 then
					if cfg.AimbotMethod == "Mouse" and _mousemoverel then
						local vp, onScreen = cam:WorldToViewportPoint(aimPos)
						if onScreen and vp.Z > 0 then
							local center = getAimScreenCenter()
							local dx = vp.X - center.X
							local dy = vp.Y - center.Y
							local smooth = math.max(1, cfg.AimbotSmooth)
							_mousemoverel(dx / smooth, dy / smooth)
						end
					else
						local targetCF = CFrame.lookAt(camPos, aimPos)
						if cfg.AimbotSmooth <= 1 then
							CameraController:MimicRotation(targetCF)
						else
							local curCF = CameraController:GetRotationCFrame()
							local alpha = math.clamp(1 / cfg.AimbotSmooth, 0.05, 1)
							CameraController:MimicRotation(curCF:Lerp(targetCF.Rotation, alpha))
						end
					end
				end
			end
		end
	end

	-- Auto Shoot (Triggerbot) & Melee Kill Aura
	local equipped = lf.EquippedItem
	if equipped and equipped.Info and not equipped:IsEquipping() and not MechanicsController:IsFrozen() and not MechanicsController:AreInputsDisabled() and not isMenuBlockingInput() then
		if cfg.AutoShoot and equipped.Info.Type == "Gun" then
			local ammo = equipped:Get("Ammo")
			local delaySec = math.clamp(cfg.AutoShootDelayMs, 15, 250) / 1000
			if ammo and ammo > 0 and (now - lastAutoShoot) >= delaySec then
				local shootOrigin = if cfg.RageOrbit then (hrp.Position + Vector3.new(0, 1.5, 0)) else nil
				local useUnlimited = cfg.UnlimitedFov or cfg.RageOrbit
				local target = selectBestTarget(cfg.SilentFov, useUnlimited, cfg.TargetPriority, true, shootOrigin)
				if target then
					lastAutoShoot = now
					task.spawn(function()
						pcall(function()
							equipped:Input("StartShooting")
							task.wait(0.015)
							if alive and equipped then
								equipped:Input("FinishShooting")
							end
						end)
					end)
				end
			end
		elseif cfg.MeleeAura and equipped.Info.Type == "Melee" then
			local reach = (equipped.Info.AttackReach or 6) + 2
			if (now - lastMeleeSwing) >= (equipped.Info.AttackCooldown or 0.25) then
				local target = selectBestTarget(9999, true, "Closest Distance", false)
				if target and (target.root.Position - hrp.Position).Magnitude <= reach then
					lastMeleeSwing = now
					task.spawn(function()
						pcall(function()
							equipped:Input("StartShooting")
						end)
					end)
				end
			end
		end
	end
end))

_setthreadidentity(8)
Window:Notify({
	title = "LATTIC RIVALS HUB Loaded",
	content = "Hub loaded. Use the top toggle or the Rayfield controls to manage the interface.",
	duration = 5,
})
