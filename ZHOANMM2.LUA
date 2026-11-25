local version = "1.3.17"
local function finitenumber(value)
  return type(value) == "number" and value == value and math.abs(value) < math.huge
end
local function finitevector(value)
  return typeof(value) == "Vector3" and finitenumber(value.X) and finitenumber(value.Y) and finitenumber(value.Z)
end
local function finiteframe(value)
  if typeof(value) ~= "CFrame" then return false end
  for _, component in ipairs({value:GetComponents()}) do
    if not finitenumber(component) then return false end
  end
  return true
end
local function disconnect(connection)
  if connection then pcall(function() connection:Disconnect() end) end
end
local function destroy(object)
  if object then pcall(function() object:Destroy() end) end
end
local function protectedcall(callback, ...)
  if type(callback) ~= "function" then return false, "Unavailable" end
  return pcall(callback, ...)
end
local mm2universe = 66654135
local mm2place = 142823291
local ismm2 = game.GameId == mm2universe or game.GameId == 0 and game.PlaceId == mm2place
local uitheme = {
  shadow = Color3.fromRGB(6, 4, 12),
  border = Color3.fromRGB(12, 10, 19),
  backdrop = Color3.fromRGB(23, 17, 35),
  surface = Color3.fromRGB(19, 17, 26),
  surfacealt = Color3.fromRGB(24, 21, 34),
  hover = Color3.fromRGB(34, 28, 46),
  selected = Color3.fromRGB(59, 45, 83),
  selectedhover = Color3.fromRGB(77, 59, 106),
  accent = Color3.fromRGB(198, 177, 236),
  accentbright = Color3.fromRGB(224, 207, 252),
  stroke = Color3.fromRGB(77, 67, 94),
  strokehover = Color3.fromRGB(117, 98, 144),
  strokeselected = Color3.fromRGB(178, 152, 221),
  text = Color3.fromRGB(241, 235, 250),
  textmuted = Color3.fromRGB(187, 178, 204),
  textdim = Color3.fromRGB(151, 140, 171),
  scroll = Color3.fromRGB(128, 111, 161)
}
local function uibuttoncolor(selected, hovered)
  if selected then return hovered and uitheme.selectedhover or uitheme.selected end
  return hovered and uitheme.hover or uitheme.surface
end
local function uibuttonstroke(selected, hovered)
  if selected then return uitheme.strokeselected end
  return hovered and uitheme.strokehover or uitheme.stroke
end
local dependency = {}
if ismm2 then
  local storage = game:GetService("ReplicatedStorage")
  local deadline = os.clock() + 10
  local function resolve(parent, name)
    if not parent then return nil end
    return parent:FindFirstChild(name) or parent:WaitForChild(name, math.max(0, deadline - os.clock()))
  end
  dependency.gameplay = resolve(resolve(storage, "Remotes"), "Gameplay")
  dependency.fade = resolve(dependency.gameplay, "Fade")
  dependency.roundend = resolve(dependency.gameplay, "RoundEndFade")
  dependency.servicemodule = resolve(resolve(storage, "ClientServices"), "WeaponService")
  dependency.gunfired = resolve(dependency.servicemodule, "GunFired")
  ismm2 = dependency.fade ~= nil and dependency.fade:IsA("RemoteEvent")
    and dependency.roundend ~= nil and dependency.roundend:IsA("RemoteEvent")
    and dependency.gunfired ~= nil and dependency.gunfired:IsA("RemoteEvent")
end

if not ismm2 then
  local players = game:GetService("Players")
  local runservice = game:GetService("RunService")
  local userinputservice = game:GetService("UserInputService")
  local teleportservice = game:GetService("TeleportService")
  local lighting = game:GetService("Lighting")
  local localplayer = players.LocalPlayer
  local env = type(getgenv) == "function" and getgenv() or _G
  if type(env.vanta) == "table" then
    local old = env.vanta
    if type(old.runtime) == "table" then protectedcall(old.runtime.stop) else protectedcall(old.stop) end
  end
  local universal = {alive = true, connections = {}, settings = {antifling = true, antivoid = true, fullbright = false, fpscap = false}, safe = nil, character = nil, lastvelocity = nil, lastposition = nil}
  local original = {brightness = lighting.Brightness, clocktime = lighting.ClockTime, exposure = lighting.ExposureCompensation}
  env.vanta = universal
  local httpservice = game:GetService("HttpService")
  local configfile = "vanta_universal_settings_" .. tostring(localplayer.UserId) .. ".json"
  if type(readfile) == "function" then
    local ok, contents = pcall(readfile, configfile)
    if ok and type(contents) == "string" then
      local decoded, data = pcall(httpservice.JSONDecode, httpservice, contents)
      if decoded and type(data) == "table" then
        for key, value in pairs(universal.settings) do
          if type(data[key]) == type(value) then universal.settings[key] = data[key] end
        end
      end
    end
  end
  local function saveconfig()
    if type(writefile) == "function" then
      local ok, data = pcall(httpservice.JSONEncode, httpservice, universal.settings)
      if ok then pcall(writefile, configfile, data) end
    end
  end
  local function create(class, properties, parent)
    local object = Instance.new(class)
    for key, value in pairs(properties or {}) do object[key] = value end
    object.Parent = parent
    return object
  end
  local gui = create("ScreenGui", {
    Name = "VantaGui", ResetOnSpawn = false, IgnoreGuiInset = true,
    DisplayOrder = 1000, ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  }, type(gethui) == "function" and gethui() or game:GetService("CoreGui"))
  local backdrop = create("Frame", {
    Name = "Backdrop", Size = UDim2.fromScale(1, 1), BackgroundColor3 = uitheme.backdrop,
    BackgroundTransparency = 0.43, BorderSizePixel = 0, Visible = false
  }, gui)
  local frame = create("Frame", {
    Name = "Menu", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(602, 582), BackgroundTransparency = 1
  }, backdrop)
  local scale = create("UIScale", {Scale = 1}, frame)
  local title = create("TextLabel", {
    Position = UDim2.fromOffset(0, 4), Size = UDim2.new(1, 0, 0, 28),
    BackgroundTransparency = 1, Text = "VANTA", Font = Enum.Font.GothamBold,
    TextSize = 19, TextColor3 = uitheme.text,
    TextXAlignment = Enum.TextXAlignment.Center
  }, frame)
  local function box(parent, x, y, w, h, color, shade)
    create("Frame", {Position = UDim2.fromOffset(x, y + 5), Size = UDim2.fromOffset(w, h),
      BackgroundColor3 = uitheme.shadow, BorderSizePixel = 0}, parent)
    local outer = create("Frame", {Position = UDim2.fromOffset(x, y),
      Size = UDim2.fromOffset(w, h), BackgroundColor3 = uitheme.border, BorderSizePixel = 0}, parent)
    local inner = create("Frame", {Position = UDim2.fromOffset(4, 4),
      Size = UDim2.new(1, -8, 1, -8), BackgroundColor3 = color or uitheme.surface,
      BorderSizePixel = 0}, outer)
    create("UIStroke", {Color = uitheme.stroke, Thickness = 1}, inner)
    return inner, outer
  end
  local function button(parent, text, x, y, w, h, callback)
    local inner, outer = box(parent, x, y, w, h)
    local stroke = inner:FindFirstChildOfClass("UIStroke")
    local face = create("TextButton", {Size = UDim2.fromScale(1, 1),
      BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, inner)
    local label = create("TextLabel", {AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, -18, 1, -4),
      BackgroundTransparency = 1, Font = Enum.Font.Arcade, TextSize = 17,
      TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
      TextColor3 = uitheme.text, TextTruncate = Enum.TextTruncate.AtEnd,
      Text = text}, inner)
    local selected, hovered = false, false
    local function paint()
      inner.BackgroundColor3 = uibuttoncolor(selected, hovered)
      if stroke then stroke.Color = uibuttonstroke(selected, hovered) end
      label.TextColor3 = selected and uitheme.text or uitheme.textmuted
    end
    face.MouseEnter:Connect(function() hovered = true paint() end)
    face.MouseLeave:Connect(function() hovered = false paint() end)
    face.Activated:Connect(function() if universal.alive and callback then callback() end end)
    paint()
    return function(value, active)
      label.Text = value
      if active ~= nil then selected = active == true end
      paint()
    end
  end
  local searchsurface = box(frame, 9, 39, 584, 45, uitheme.surface)
  create("TextLabel", {Position = UDim2.fromOffset(10, 0), Size = UDim2.fromOffset(24, 37),
    BackgroundTransparency = 1, Text = "⌕", TextSize = 22, TextColor3 = uitheme.textmuted}, searchsurface)
  local search = create("TextBox", {
    Position = UDim2.fromOffset(36, 0), Size = UDim2.new(1, -80, 1, 0),
    BackgroundTransparency = 1, Text = "", ClearTextOnFocus = false,
    PlaceholderText = "Search settings, actions, menus...", Font = Enum.Font.GothamMedium,
    TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = uitheme.text,
    PlaceholderColor3 = uitheme.textdim
  }, searchsurface)
  create("TextLabel", {Position = UDim2.new(1, -35, 0, 8), Size = UDim2.fromOffset(25, 20),
    BackgroundColor3 = uitheme.surfacealt, Text = "/", Font = Enum.Font.Code,
    TextSize = 15, TextColor3 = uitheme.accent}, searchsurface)
  local content = create("Frame", {Position = UDim2.fromOffset(0, 152),
    Size = UDim2.new(1, 0, 1, -162), BackgroundTransparency = 1}, frame)
  local pages = {}
  local current = "main"
  local searching = false
  local pageinfo = {
    general = {"GENERAL", "main"}, combat = {"COMBAT", "main"},
    visuals = {"VISUALS", "main"}, automation = {"AUTOMATION", "main"},
    players = {"PLAYERS", "main"}, settings = {"SETTINGS", "main"},
    safety = {"SAFETY & RECOVERY", "general"},
    world = {"WORLD LIGHTING", "visuals"}, performance = {"PERFORMANCE", "visuals"}
  }
  for name in pairs(pageinfo) do
    pages[name] = create("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
      Visible = false}, content)
  end
  pages.main = create("Frame", {Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1}, content)
  local selectpage
  local back = button(frame, "Back to Game", 9, 96, 584, 50, function() backdrop.Visible = false end)
  local returnpage = button(frame, "Return to Home", 9, 515, 584, 50, function()
    if searching then search.Text = "" return end
    local info = pageinfo[current]
    selectpage(info and info[2] or "main")
  end)
  local mainpages = {{"General", "general"}, {"Combat", "combat"}, {"Visuals", "visuals"},
    {"Automation", "automation"}, {"Players", "players"}, {"Settings", "settings"}}
  for i, data in ipairs(mainpages) do
    local x = i % 2 == 1 and 9 or 309
    local y = 12 + math.floor((i - 1) / 2) * 61
    button(pages.main, data[1], x, y, 284, 56, function() selectpage(data[2]) end)
  end
  local function desc(page, value, y)
    return create("TextLabel", {Position = UDim2.fromOffset(16, y),
      Size = UDim2.fromOffset(568, 48), TextWrapped = true,
      BackgroundTransparency = 1, Text = value, Font = Enum.Font.GothamMedium,
      TextSize = 14, TextColor3 = Color3.fromRGB(196, 189, 209),
      TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center
    }, pages[page])
  end
  local settingsbuttons = {}
  local settingnames = {}
  local function toggle(page, text, key, x, y, callback)
    local function update()
      return text .. " [" .. (universal.settings[key] and "ON" or "OFF") .. "]"
    end
    local setlabel
    setlabel = button(pages[page], update(), x, y, 584, 50, function()
      universal.settings[key] = not universal.settings[key]
      if callback then callback() end
      setlabel(update(), universal.settings[key])
      saveconfig()
    end)
    setlabel(update(), universal.settings[key])
    settingsbuttons[key] = setlabel
    settingnames[key] = text
  end
  button(pages.general, "Safety & Recovery", 9, 12, 584, 50, function() selectpage("safety") end)
  button(pages.visuals, "World Lighting", 9, 12, 584, 50, function() selectpage("world") end)
  button(pages.visuals, "Performance", 9, 76, 584, 50, function() selectpage("performance") end)
  toggle("safety", "Anti Fling", "antifling", 9, 12)
  toggle("safety", "Anti Void", "antivoid", 9, 76)
  local function applylighting()
    lighting.Brightness = universal.settings.fullbright and 3 or original.brightness
    lighting.ClockTime = universal.settings.fullbright and 14 or original.clocktime
    lighting.ExposureCompensation = universal.settings.fullbright and 0.3 or original.exposure
  end
  toggle("world", "Fullbright", "fullbright", 9, 12, applylighting)
  local function applyfps()
    if type(setfpscap) == "function" then pcall(setfpscap, universal.settings.fpscap and 60 or 0) end
  end
  toggle("performance", "FPS Cap 60", "fpscap", 9, 12, applyfps)
  desc("combat", "Combat features require Murder Mystery 2. Universal settings remain accessible in the other tabs.", 25)
  desc("automation", "Auto Vote, coin collection and other MM2 automation are disabled outside Murder Mystery 2.", 25)
  desc("players", "MM2 role detection and role-specific controls are not available in this experience.", 25)
  desc("settings", "Vanta v" .. version .. " • Universal mode", 12)
  button(pages.settings, "Rejoin Server", 9, 75, 584, 50, function()
    pcall(function() teleportservice:TeleportToPlaceInstance(game.PlaceId, game.JobId, localplayer) end)
  end)
  button(pages.settings, "Reset Universal Settings", 9, 139, 584, 50, function()
    universal.settings.antifling = true
    universal.settings.antivoid = true
    universal.settings.fullbright = false
    universal.settings.fpscap = false
    for key, setlabel in pairs(settingsbuttons) do
      setlabel(settingnames[key] .. " [" .. (universal.settings[key] and "ON" or "OFF") .. "]", universal.settings[key])
    end
    applylighting()
    applyfps()
    saveconfig()
  end)
  button(pages.main, "Server Reconnect", 9, 198, 584, 50, function()
    pcall(function() teleportservice:TeleportToPlaceInstance(game.PlaceId, game.JobId, localplayer) end)
  end)
  button(pages.main, "Leave Game", 9, 325, 584, 50, function() localplayer:Kick("Left game using Vanta") end)
  local function fitmenu()
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    scale.Scale = math.clamp(math.min((viewport.X - 24) / 602, (viewport.Y - 36) / 582), 0.15, 1)
  end
  selectpage = function(name)
    current = pages[name] and name or "main"
    for key, page in pairs(pages) do page.Visible = key == current end
    local info = pageinfo[current]
    title.Text = info and "VANTA / " .. info[1] or "VANTA"
    if info then
      returnpage("Return to " .. (info[2] == "main" and "Home" or pageinfo[info[2]][1]))
    end
  end
  local launcher = create("TextButton", {
    Name = "VantaLauncher", AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 16, 0.5, 0), Size = UDim2.fromOffset(94, 37),
    BackgroundColor3 = uitheme.selected, Text = "VANTA",
    TextColor3 = uitheme.accentbright, Font = Enum.Font.GothamBold,
    TextSize = 13, AutoButtonColor = false
  }, gui)
  create("UICorner", {CornerRadius = UDim.new(0, 9)}, launcher)
  create("UIStroke", {Color = uitheme.strokeselected, Thickness = 1}, launcher)
  launcher.MouseEnter:Connect(function() launcher.BackgroundColor3 = uitheme.selectedhover end)
  launcher.MouseLeave:Connect(function() launcher.BackgroundColor3 = uitheme.selected end)
  local dragging, draginput, dragstart, buttonstart, moved, suppressuntil = false, nil, nil, nil, false, 0
  local function clampbutton(position)
    local size = gui.AbsoluteSize
    if size.X <= 0 or size.Y <= 0 then return position end
    local x = math.clamp(position.X.Scale * size.X + position.X.Offset, 0, math.max(0, size.X - launcher.AbsoluteSize.X))
    local y = math.clamp(position.Y.Scale * size.Y + position.Y.Offset, launcher.AbsoluteSize.Y / 2, math.max(launcher.AbsoluteSize.Y / 2, size.Y - launcher.AbsoluteSize.Y / 2))
    return UDim2.fromOffset(x, y)
  end
  launcher.Activated:Connect(function()
    if os.clock() >= suppressuntil and not moved then backdrop.Visible = not backdrop.Visible end
  end)
  launcher.InputBegan:Connect(function(input)
    if dragging then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
      dragging, moved, draginput = true, false, input
      dragstart, buttonstart = input.Position, launcher.Position
    end
  end)
  table.insert(universal.connections, userinputservice.InputEnded:Connect(function(input)
    if not dragging or input ~= draginput then return end
    if moved then suppressuntil = os.clock() + 0.2 end
    dragging, draginput = false, nil
    moved = false
  end))
  table.insert(universal.connections, userinputservice.InputChanged:Connect(function(input)
    if not dragging then return end
    local mouse = draginput.UserInputType == Enum.UserInputType.MouseButton1
    if not (mouse and input.UserInputType == Enum.UserInputType.MouseMovement or not mouse and input == draginput) then return end
    local delta = input.Position - dragstart
    if delta.Magnitude >= 6 then moved = true end
    if moved then
      launcher.Position = clampbutton(UDim2.new(buttonstart.X.Scale, buttonstart.X.Offset + delta.X,
        buttonstart.Y.Scale, buttonstart.Y.Offset + delta.Y))
    end
  end))
  local results = create("ScrollingFrame", {
    Position = UDim2.fromOffset(9, 8), Size = UDim2.fromOffset(584, 345),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
    ScrollBarImageColor3 = uitheme.scroll, CanvasSize = UDim2.fromOffset(0, 0), Visible = false
  }, content)
  local resultentries = {
    {"General", "general", "safety recovery"}, {"Combat", "combat", "weapon gun knife"},
    {"Visuals", "visuals", "world lighting graphics"}, {"Automation", "automation", "farm vote"},
    {"Players", "players", "roles"}, {"Settings", "settings", "reset reconnect"},
    {"Safety & Recovery", "safety", "protection"}, {"Anti Fling", "safety", "velocity collision"},
    {"Anti Void", "safety", "fall recovery"}, {"World Lighting", "world", "brightness"},
    {"Fullbright", "world", "brightness lighting"}, {"Performance", "performance", "fps graphics"},
    {"FPS Cap 60", "performance", "frame limit"}, {"Rejoin Server", "settings", "reconnect"},
    {"Reset Universal Settings", "settings", "defaults"}
  }
  local originalselect = selectpage
  selectpage = function(name)
    searching = false
    results.Visible = false
    if search.Text ~= "" then search.Text = "" end
    originalselect(name)
    if name == "main" then returnpage("Return to Home") end
  end
  local function searchpage()
    local query = search.Text:lower():match("^%s*(.-)%s*$") or ""
    for _, child in ipairs(results:GetChildren()) do destroy(child) end
    if query == "" then
      searching = false
      results.Visible = false
      originalselect(current)
      if current == "main" then returnpage("Return to Home") end
      return
    end
    searching = true
    for _, page in pairs(pages) do page.Visible = false end
    results.Visible = true
    results.CanvasPosition = Vector2.zero
    title.Text = "VANTA / SEARCH"
    returnpage("Clear Search")
    local row = 0
    for _, entry in ipairs(resultentries) do
      local haystack = (entry[1] .. " " .. entry[3]):lower()
      local matched = true
      for word in query:gmatch("%S+") do
        if not haystack:find(word, 1, true) then matched = false break end
      end
      if matched then
        button(results, entry[1], 0, row * 57, 576, 50, function() selectpage(entry[2]) end)
        row += 1
      end
    end
    if row == 0 then
      create("TextLabel", {Size = UDim2.new(1, -12, 0, 60), BackgroundTransparency = 1,
        Text = "No matching settings", Font = Enum.Font.GothamMedium, TextSize = 14,
        TextColor3 = uitheme.textmuted}, results)
    end
    results.CanvasSize = UDim2.fromOffset(0, math.max(60, row * 57))
  end
  search:GetPropertyChangedSignal("Text"):Connect(searchpage)
  local camerawatch
  local function bindcamera()
    disconnect(camerawatch)
    camerawatch = nil
    local camera = workspace.CurrentCamera
    if camera then camerawatch = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
      fitmenu()
      launcher.Position = clampbutton(launcher.Position)
    end) end
    fitmenu()
    launcher.Position = clampbutton(launcher.Position)
  end
  table.insert(universal.connections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindcamera))
  bindcamera()

  selectpage("main")
  fitmenu()
  applylighting()
  applyfps()
  local function finite(vector)
    return vector.X == vector.X and vector.Y == vector.Y and vector.Z == vector.Z
      and math.abs(vector.X) < 1e9 and math.abs(vector.Y) < 1e9 and math.abs(vector.Z) < 1e9
  end
  table.insert(universal.connections, runservice.PreSimulation:Connect(function(dt)
    if not universal.alive then return end
    local character = localplayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local human = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not human or human.Health <= 0 then return end
    if character ~= universal.character or root ~= universal.root then
      universal.character, universal.root = character, root
      universal.safe = nil
      universal.lastvelocity = nil
      universal.lastposition = nil
    end
    local velocity = root.AssemblyLinearVelocity
    local rotation = root.AssemblyAngularVelocity
    local position = root.Position
    local valid = finite(velocity) and finite(rotation) and finite(position)
    local speed = valid and velocity.Magnitude or math.huge
    local spin = valid and rotation.Magnitude or math.huge
    local danger = not valid or speed > 155 or spin > 45
    if valid and human.FloorMaterial ~= Enum.Material.Air and speed < 36 and spin < 12
      and position.Y > workspace.FallenPartsDestroyHeight + 55 then
      universal.safe = character:GetPivot()
    end
    local below = valid and position.Y < workspace.FallenPartsDestroyHeight + 32
    if universal.settings.antifling and danger then
      root.AssemblyLinearVelocity = Vector3.zero
      root.AssemblyAngularVelocity = Vector3.zero
    end
    if universal.settings.antivoid and universal.safe
      and (below or valid and universal.lastposition
        and position.Y < universal.lastposition.Y - 40 and velocity.Y < -70) then
      root.AssemblyLinearVelocity = Vector3.zero
      root.AssemblyAngularVelocity = Vector3.zero
      character:PivotTo(universal.safe)
    end
    if valid then universal.lastposition = position; universal.lastvelocity = velocity end
  end))
  table.insert(universal.connections, userinputservice.InputBegan:Connect(function(input, processed)
    if processed or userinputservice:GetFocusedTextBox() then return end
    if input.KeyCode == Enum.KeyCode.RightControl then backdrop.Visible = not backdrop.Visible
    elseif input.KeyCode == Enum.KeyCode.Slash and backdrop.Visible then search:CaptureFocus() end
  end))
  function universal.stop()
    if not universal.alive then return end
    universal.alive = false
    for _, connection in ipairs(universal.connections) do disconnect(connection) end
    table.clear(universal.connections)
    disconnect(camerawatch)
    if universal.settings.fullbright then
      pcall(function() lighting.Brightness = original.brightness end)
      pcall(function() lighting.ClockTime = original.clocktime end)
      pcall(function() lighting.ExposureCompensation = original.exposure end)
    end
    destroy(gui)
    if env.vanta == universal then env.vanta = nil end
  end
  universal.version = version
  universal.config = universal.settings
  universal.flags = universal.settings
  universal.functions = {togglemenu = function() backdrop.Visible = not backdrop.Visible end}
  return
end

local players, replicatedstorage = game:GetService("Players"), game:GetService("ReplicatedStorage")
local userinputservice, tweenservice = game:GetService("UserInputService"), game:GetService("TweenService")
local debris, coregui = game:GetService("Debris"), game:GetService("CoreGui")
local textservice = game:GetService("TextService")
local collectionservice, world = game:GetService("CollectionService"), game:GetService("Workspace")
local runservice = game:GetService("RunService")
local teleportservice = game:GetService("TeleportService")
local contextactionservice = game:GetService("ContextActionService")

local localplayer = players.LocalPlayer
local gameplay = dependency.gameplay
local fade = dependency.fade
local roundend = dependency.roundend
local playerchanged = gameplay:FindFirstChild("PlayerDataChanged")
local roundstart = gameplay:FindFirstChild("RoundStart")
local loadingmap = gameplay:FindFirstChild("LoadingMap")
local teleporttopart = gameplay:FindFirstChild("TeleportToPart")
local victory = gameplay:FindFirstChild("VictoryScreen")
local specialxp = gameplay:FindFirstChild("SpecialXPEvent")
local servicemodule = dependency.servicemodule
local gunfired = dependency.gunfired
local env = type(getgenv) == "function" and getgenv() or _G
local api = type(env.vanta) == "table" and env.vanta or type(env.rolefx) == "table" and env.rolefx or {}
local previous = type(api.runtime) == "table" and api.runtime or nil
local snapshot = previous or (type(env.__rolechams_cinematic) == "table" and env.__rolechams_cinematic or nil)
local remembered = snapshot and {
  records = snapshot.records, authoritative = snapshot.authoritative, observed = snapshot.observed,
  round = snapshot.round, synced = snapshot.synced, endlock = snapshot.endlock, seenunarmed = snapshot.seenunarmed,
  lastgun = snapshot.lastgun, victoryactive = snapshot.victoryactive,
  lastsheriff = snapshot.lastsheriff, gunroleowner = snapshot.gunroleowner,
  participants = snapshot.participants, localround = snapshot.localround, originalsheriff = snapshot.originalsheriff,
  roundstartobserved = snapshot.roundstartobserved, roundstartparticipant = snapshot.roundstartparticipant,
  roundstartedat = snapshot.roundstartedat, roundstartsource = snapshot.roundstartsource,
  farmkilledround = snapshot.farmkilledround,
  fullresetround = snapshot.autofarm and snapshot.autofarm.fullresetround,
  maproot = snapshot.maproot, mapcf = snapshot.mapcf, mapsize = snapshot.mapsize,
  mapmode = snapshot.mapmode, mapspawn = snapshot.mapspawn, gunhistory = snapshot.gunhistory,
  coinhidden = snapshot.coinhidden, coinorigins = snapshot.coinorigins, coinroundhidden = snapshot.coinroundhidden
} or nil

if previous and type(previous.stop) == "function" then
  pcall(previous.stop)
elseif type(api.stop) == "function" then
  pcall(api.stop)
end

local stopped = {}
for _, key in ipairs({"__rolechams_silentaim", "__rolechams_silentaim_safe", "__rolechams_weaponservice", "__rolechams_cinematic"}) do
  local runtime = env[key]
  if type(runtime) == "table" and runtime ~= previous and not stopped[runtime] and type(runtime.stop) == "function" then
    stopped[runtime] = true
    pcall(runtime.stop)
  end
  env[key] = nil
end

if type(env.coinchams) == "table" and type(env.coinchams.stop) == "function" then
  pcall(env.coinchams.stop)
end

local defaults = {
  refresh = 0.2, rolecheck = 0.2, closeaimdistance = 18, closeaimfov = 0.12, strictequipment = true,
  checkbackpack = true, preservemanual = true, skeleton = true, skeletonwidth = 1.85, skeletonoutline = true,
  skeletondistance = 420, skeletontransparency = 0.98, skeletonbeamsize = 0.055, showmenu = false,
  skeletonrefresh = 1 / 45, outlineglow = true, maxdistance = 300, screenradius = math.huge, filltransparency = 0.47,
  innocentfill = 0.76, outlinetransparency = 0, innocentoutline = 0.03, throughwalls = true, outlineonly = false,
  showinnocents = true, showtags = true, showinnocentlabels = true, showhud = true, tagdistance = 280,
  effectsdistance = 1100, effectsquality = 1, gunmarker = true, gunmarkericon = "crosshair", gunmarkermaxage = 180,
  gunmarkerdropscan = 1.25, gunmarkersearchradius = 95, knifedistance = 300,
  knifescreenradius = 320,
  knifetargetlock = 0.16, knifeaim = true, knifeaimalways = true, requiregunforsheriff = false, nocollision = true,
  mousecframespoof = true, mouseunitrayspoof = true, mousecacherate = 0.014,
  guncloserange = 20, gunmaxoffset = 1.5, gunmotioninterval = 0.045,
  autopickup = true, pickupsearchinterval = 0.07, pickuphold = 0.75, pickupretrydelay = 0.3, pickupestimatedmarkers = true,
  pickupverticaloffset = 0.3, pickupdropdelay = 0.25, pickupraycast = true, pickupallowgenericraycast = true,
  pickupwithoutlastknown = true, pickupattachmentowner = "", pickupheadcontact = true,
  killnotices = true, killnoticetime = 3.8, notifications = true, notificationheadshots = true,
  notificationduration = 5, notificationlimit = 4, aimonfire = true,
  autoshoot = false, autoshootbehind = false, autoshootfar = false, autoshootcover = true, autoshoothitpart = "Torso", autounequipgun = false, rolehitboxes = true, autoshootinterval = 0.16, autoshootcheckinterval = 0.016,
  gunaimmaxoffset = 2.5, firefallback = true, autoshootactivate = true,
  gunmovementbias = 15, gunedgebias = 0.24, gunminmovementspeed = 3.5,
  notificationminwidth = 350, notificationmaxwidth = 520, notificationheight = 78,
  roundrequestcooldown = 8, autoequipgun = true, r6tracking = true, r6trackinginterval = 1 / 45,
  r6trackingsmallthreshold = 0.85, gunmapmargin = 42, guntrackinterval = 0.08,
  gunmemoryradius = 125, mapdetectioninterval = 2,
  coinfilltransparency = 0.38, coinoutlinecolor = Color3.fromRGB(255, 248, 198),
  coinboxtransparency = 0.74, coinboxpadding = 0.16, coinboxfallback = false, coinproxytransparency = 0.985,
  coinproxyfps = 30, coincontactinterval = 0.09, coinriseheight = 5,
  autofarmtweenspeed = 20, autofarmnoclip = true, autoshootwhenfull = false,
  farmreturnfinished = true, farmreturnfull = true, farmhidefull = false, farmresetfull = false,
  farmfinishdestination = "Start", farmfulldestination = "Start",
  gunownershiptracking = true, adaptiveesp = true, espmode = "Highlight", adaptivefpslow = 46,
  adaptivefpscritical = 29, adaptiverecovermargin = 8, adaptiveswitchdelay = 1.4,
  antifling = true, antiflingvelocity = 160, antiflingrotation = 45, antiflingreturn = true, flinglogs = false,
  antivoid = true,
  knifeallinterval = 0.18, walkspeedpreset = "Default", persistnoclip = true, manualnoclip = false,
  autokillmode = "Teleport", autokillfullbag = false, autokillautoequip = true,
  autokillreturn = true, autokillactivate = true, autovote = false,
  guikeybind = "RightControl", mobilebuttonx = 0.89, mobilebuttony = 0.57,
  gunbeamstyle = "Prism", gunbeamwidth = "Standard", gunbeamglow = true, gunbeamtracer = true,
  gunbeamimpact = true, gunbeammuzzle = true,
  removetextures = false, simplematerials = false, disablemapfx = false,
  distanceculling = false, frustumculling = false, disablepostfx = false, lowqualitywater = false,
  fullbright = false, clearfog = false, noshadows = false, disablefade = true,
  fpscapmode = "Unlimited", fovmode = "Default"
}
local config = type(api.config) == "table" and api.config or {}
local function validsetting(value, default)
  if type(value) ~= type(default) then return false end
  if type(default) == "number" then
    return finitenumber(value) or default == math.huge and value == math.huge
  end
  if typeof(default) == "Color3" then return typeof(value) == "Color3" end
  return true
end
for key, value in pairs(defaults) do
  if not validsetting(config[key], value) then config[key] = value end
end
config.pickupsearchinterval = 0.07
config.pickuphold = math.max(0.65, tonumber(config.pickuphold) or 0.75)
config.pickupretrydelay = math.max(0.25, tonumber(config.pickupretrydelay) or 0.3)
local function validkeycode(value)
  if type(value) ~= "string" or value == "Unbound" then return nil end
  local ok, code = pcall(function() return Enum.KeyCode[value] end)
  return ok and code and code ~= Enum.KeyCode.Unknown and code or nil
end
if tonumber(config.autoshootinterval) == 0.48 then config.autoshootinterval = 0.16 end
config.autoshootcheckinterval = 0.016
config.gunmaxoffset = 1.5
config.notificationduration = 5
config.killnoticetime = 5
config.pickupretrydelay = math.max(0.25, tonumber(config.pickupretrydelay) or 0.3)
local guikeyfile = "vanta_gui_keybind.txt"
if type(readfile) == "function" then
  local ok, saved = pcall(readfile, guikeyfile)
  if ok and type(saved) == "string" then
    local key = saved:match("^%s*(.-)%s*$")
    if validkeycode(key) then
      config.guikeybind = key
    end
  end
end
if not validkeycode(config.guikeybind) then
  config.guikeybind = "RightControl"
end
local httpservice = game:GetService("HttpService")
local preferencesfile = "vanta_settings_" .. tostring(localplayer.UserId) .. "_" .. tostring(game.PlaceId) .. ".json"
local persistedsettings
local readpreferences = type(readfile) == "function" and readfile or type(env.readfile) == "function" and env.readfile or nil
local writepreferences = type(writefile) == "function" and writefile or type(env.writefile) == "function" and env.writefile or nil
if readpreferences then
  local ok, contents = pcall(readpreferences, preferencesfile)
  if ok and type(contents) == "string" then
    local parsed, data = pcall(httpservice.JSONDecode, httpservice, contents)
    if parsed and type(data) == "table" and data.version == 2
      and data.userid == localplayer.UserId and data.placeid == game.PlaceId then
      persistedsettings = data
    end
  end
end
if not persistedsettings and type(env.__vanta_saved_settings) == "table" then
  local data = env.__vanta_saved_settings
  if data.userid == localplayer.UserId and data.placeid == game.PlaceId then persistedsettings = data end
end
if persistedsettings then
  for key, value in pairs(type(persistedsettings.config) == "table" and persistedsettings.config or {}) do
    if key ~= "showmenu" and (type(value) == "boolean" or type(value) == "number" or type(value) == "string")
      and defaults[key] ~= nil and validsetting(value, defaults[key]) then config[key] = value end
  end
  if localplayer.Name:lower() == "4tgw" and (persistedsettings.mobilelayout == "Mobile" or persistedsettings.mobilelayout == "Desktop") then
    config.mobilelayout = persistedsettings.mobilelayout
  end
  if type(persistedsettings.config) == "table" then
    for _, key in ipairs({"mobilebuttonx", "mobilebuttony"}) do
      local value = tonumber(persistedsettings.config[key])
      if value and value == value then config[key] = math.clamp(value, 0.08, 0.92) end
    end
  end
  if type(persistedsettings.walkspeedpreset) == "string" then config.walkspeedpreset = persistedsettings.walkspeedpreset end
  if type(persistedsettings.autokillmode) == "string" then config.autokillmode = persistedsettings.autokillmode end
  if type(persistedsettings.farmfinishdestination) == "string" then
    config.farmfinishdestination = persistedsettings.farmfinishdestination
  end
  if type(persistedsettings.farmfulldestination) == "string" then
    config.farmfulldestination = persistedsettings.farmfulldestination
  end
  if type(persistedsettings.fpscapmode) == "string" then config.fpscapmode = persistedsettings.fpscapmode end
  if type(persistedsettings.fovmode) == "string" then config.fovmode = persistedsettings.fovmode end
  if type(persistedsettings.gunbeamstyle) == "string" then config.gunbeamstyle = persistedsettings.gunbeamstyle end
  if persistedsettings.espmode == "Drawing" or persistedsettings.espmode == "Highlight" then
    config.espmode = persistedsettings.espmode
  end
  if type(persistedsettings.gunbeamwidth) == "string" then config.gunbeamwidth = persistedsettings.gunbeamwidth end
  if validkeycode(persistedsettings.guikeybind) then
    config.guikeybind = persistedsettings.guikeybind
  end
end
do
  local ranges = {refresh = {0.08, 5}, rolecheck = {0.12, 5}, skeletonwidth = {0.5, 8}, skeletondistance = {10, 2000},
    maxdistance = {10, 2000}, tagdistance = {10, 2000}, effectsdistance = {10, 4000}, coinproxyfps = {5, 60},
    coincontactinterval = {0.04, 2}, guntrackinterval = {0.05, 5}, pickupsearchinterval = {0.05, 0.35},
    pickuphold = {0.65, 5}, pickupretrydelay = {0.25, 10}, notificationduration = {1, 20}, notificationlimit = {1, 10},
    notificationminwidth = {200, 1000}, notificationmaxwidth = {200, 1000}, notificationheight = {76, 104},
    r6trackinginterval = {1 / 90, 1}, skeletonrefresh = {1 / 90, 1}, adaptivefpslow = {25, 190},
    adaptivefpscritical = {12, 150}, adaptiveswitchdelay = {0.3, 10}, adaptiverecovermargin = {3, 30},
    antiflingvelocity = {25, 1000}, antiflingrotation = {5, 250}, autoshootinterval = {0.08, 5},
    autoshootcheckinterval = {0.016, 1}, mobilebuttonx = {0.08, 0.92}, mobilebuttony = {0.08, 0.92}}
  for key, range in pairs(ranges) do config[key] = math.clamp(config[key], range[1], range[2]) end
  for key, value in pairs(defaults) do
    if type(value) == "number" and key:find("transparency", 1, true) then config[key] = math.clamp(config[key], 0, 1) end
  end
  config.notificationmaxwidth = math.max(config.notificationminwidth, config.notificationmaxwidth)
end
local votemapnames = {
  "Bank 2", "Bio Lab", "Factory", "Hospital 3", "Hotel 2", "House 2",
  "Mansion 2", "Mil Base", "Office 3", "Police Station", "Research Facility", "Workplace"
}
local votemapkeys = {}
local function votekey(value)
  return tostring(value or ""):lower():gsub("[^%w]", "")
end
for _, name in ipairs(votemapnames) do votemapkeys[votekey(name)] = name end
local previousvotemaps = config.autovotemaps
config.autovotemaps = {}
local savedvotemaps = persistedsettings and persistedsettings.autovotemaps
if type(savedvotemaps) ~= "table" then savedvotemaps = previousvotemaps end
if type(savedvotemaps) == "table" then
  for _, name in ipairs(savedvotemaps) do
    local mapped = votemapkeys[votekey(name)]
    if mapped and not table.find(config.autovotemaps, mapped) then
      config.autovotemaps[#config.autovotemaps + 1] = mapped
    end
  end
end
local farmspeeds = {16, 20, 24}
local keybindactions = {
  {"shootmurderer", "Shoot Murderer", "Zero"},
  {"toggleautofarm", "Toggle Auto Collect", "Nine"},
  {"toggleautoshoot", "Toggle Auto Shoot", "Unbound"},
  {"togglepickup", "Toggle Gun Pickup", "Unbound"},
  {"togglecoinchams", "Toggle Coin Chams", "Unbound"},
  {"togglerolechams", "Toggle Role Chams", "Unbound"},
  {"toggleantifling", "Toggle Anti Fling", "Unbound"},
  {"togglenoclip", "Toggle Noclip", "Unbound"},
  {"toggleautokill", "Toggle Auto Kill All", "Unbound"}
}
local keybinddefaults = {}
for _, entry in ipairs(keybindactions) do keybinddefaults[entry[1]] = entry[3] end
config.keybinds = {}
for action, default in pairs(keybinddefaults) do
  local stored = persistedsettings and type(persistedsettings.keybinds) == "table"
    and persistedsettings.keybinds or nil
  local saved = stored and stored[action]
  local selected = type(saved) == "string" and saved or default
  config.keybinds[action] = (selected == "Unbound" or validkeycode(selected)) and selected or default
end
local occupiedkeys = {}
for _, entry in ipairs(keybindactions) do
  local name = config.keybinds[entry[1]]
  if name ~= "Unbound" then
    if occupiedkeys[name] then
      config.keybinds[entry[1]] = "Unbound"
    else
      occupiedkeys[name] = true
    end
  end
end
if occupiedkeys[config.guikeybind] then
  for _, name in ipairs({"RightControl", "RightShift", "F8", "F7"}) do
    if not occupiedkeys[name] then config.guikeybind = name break end
  end
end
local storedfarmspeed = persistedsettings and tonumber(persistedsettings.autofarmtweenspeed)
config.autofarmtweenspeed = table.find(farmspeeds, storedfarmspeed) and storedfarmspeed or 20
local farmdestinations = {"Start", "Lobby", "Stay"}
if not table.find(farmdestinations, config.farmfinishdestination) then config.farmfinishdestination = "Start" end
if not table.find(farmdestinations, config.farmfulldestination) then config.farmfulldestination = "Start" end
local fpscapmodes = {"Unlimited", "60", "120", "144", "240"}
local fovmodes = {"Default", "80", "90", "100"}
local gunbeamstyles = {"Lightning", "Lava", "Prism", "Ion", "Ember", "Arc", "Void", "Minimal"}
local gunbeamwidths = {"Thin", "Standard", "Bold"}
local espmodes = {"Highlight", "Drawing"}
local hitparts = {"Auto", "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
if not table.find(hitparts, config.autoshoothitpart) then config.autoshoothitpart = "Torso" end
if not table.find(espmodes, config.espmode) then config.espmode = "Highlight" end
if not table.find(gunbeamstyles, config.gunbeamstyle) then config.gunbeamstyle = "Prism" end
if not table.find(gunbeamwidths, config.gunbeamwidth) then config.gunbeamwidth = "Standard" end
if not table.find(fpscapmodes, config.fpscapmode) then config.fpscapmode = "Unlimited" end
if not table.find(fovmodes, config.fovmode) then config.fovmode = "Default" end
local autokillmodes = {"Teleport", "CFrame", "Touch Interest"}
local validautokillmodes = {Teleport = true, CFrame = true, ["Touch Interest"] = true}
if not validautokillmodes[config.autokillmode] then config.autokillmode = "Teleport" end
local lastpreferencestext
local savepreferences
if not persistedsettings then config.autounequipgun = false end
local initialhumanoid = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
local initialwalkspeed = initialhumanoid and initialhumanoid.WalkSpeed or nil
local walkspeeds = {Default = 16, Quick = 32, Fast = 48, Rapid = 64}
if not walkspeeds[config.walkspeedpreset] then config.walkspeedpreset = "Default" end
local speedorder = {"Default", "Quick", "Fast", "Rapid"}
if not walkspeeds[config.walkspeedpreset] then config.walkspeedpreset = "Default" end
if config.walkspeedversion ~= 2 then
  config.defaultwalkspeed = initialwalkspeed and initialwalkspeed > 0 and initialwalkspeed or 16
  config.walkspeedversion = 2
end
walkspeeds.Default = tonumber(config.defaultwalkspeed) or initialwalkspeed or 16
if not finitenumber(config.visualversion) or config.visualversion < 2 then
  if config.filltransparency == 0.93 then config.filltransparency = 0.47 end
  if config.innocentfill == 0.985 then config.innocentfill = 0.76 end
  if config.outlinetransparency == 0.07 then config.outlinetransparency = 0 end
  if config.innocentoutline == 0.4 then config.innocentoutline = 0.03 end
  if config.skeletontransparency == 0.92 then config.skeletontransparency = 0.98 end
  config.checkbackpack = true
  config.visualversion = 2
end
if config.aimversion ~= 3 then
  if config.knifescreenradius == math.huge then config.knifescreenradius = 320 end
  config.requiregunforsheriff = false
  config.aimversion = 3
end

local defaultcolors = {
  Murderer = Color3.fromRGB(255, 53, 94), Sheriff = Color3.fromRGB(36, 172, 255), Hero = Color3.fromRGB(32, 245, 205),
  Innocent = Color3.fromRGB(51, 240, 133), Neutral = Color3.fromRGB(155, 161, 172),
  GunCarrier = Color3.fromRGB(36, 172, 255), Coin = Color3.fromRGB(255, 195, 52)
}
local colors = type(api.colors) == "table" and api.colors or {}
for key, value in pairs(defaultcolors) do
  if typeof(colors[key]) ~= "Color3" then colors[key] = value end
end
if not finitenumber(api.colorversion) or api.colorversion < 2 then
  local old = {
    Murderer = Color3.fromRGB(248, 92, 112), Sheriff = Color3.fromRGB(89, 158, 245), Hero = Color3.fromRGB(98, 212, 213),
    Innocent = Color3.fromRGB(179, 193, 214),
    GunCarrier = Color3.fromRGB(103, 169, 245)
  }
  for key, original in pairs(old) do
    if colors[key] == original then colors[key] = defaultcolors[key] end
  end
  api.colorversion = 2
end
if api.colorversion < 3 then
  if colors.Innocent == Color3.fromRGB(204, 191, 255) then colors.Innocent = defaultcolors.Innocent end
  colors.Neutral = colors.Neutral or defaultcolors.Neutral
  api.colorversion = 3
end

if type(config.gunprediction) ~= "boolean" then config.gunprediction = false end
if type(config.combatpredictionstrength) ~= "string" then config.combatpredictionstrength = "Exact" end
local flags = type(api.flags) == "table" and api.flags or {}
config.gunflash, config.gunflashoffset, config.gunflashmaxdistance = nil, nil, nil
config.pickupmaxdistance, config.pickupmaxattempts, config.pickupcooldown = nil, nil, nil
config.pickupverticaloffset = 0
if type(flags.aim) ~= "boolean" then flags.aim = true end
if type(flags.chams) ~= "boolean" then flags.chams = true end
if type(flags.fx) ~= "boolean" then flags.fx = true end
if type(flags.skeleton) ~= "boolean" then flags.skeleton = true end
if type(flags.nocollision) ~= "boolean" then flags.nocollision = true end
if type(flags.autopickup) ~= "boolean" then flags.autopickup = false end
if type(flags.coinchams) ~= "boolean" then flags.coinchams = true end
if type(flags.autofarm) ~= "boolean" then flags.autofarm = false end
if type(flags.knifeall) ~= "boolean" then flags.knifeall = false end
if type(flags.autokillall) ~= "boolean" then flags.autokillall = false end
flags.gunflash = nil
if api.defaultsversion ~= 3 then
  flags.aim, flags.chams, flags.fx, flags.skeleton, flags.nocollision = true, true, true, true, true
  config.showinnocents, config.showtags, config.throughwalls = true, true, true
  config.skeleton = true
  api.defaultsversion = 3
end

if not persistedsettings then flags.autofarm = false; flags.autokillall = false end
if persistedsettings and type(persistedsettings.flags) == "table" then
  for key, value in pairs(persistedsettings.flags) do
    if type(value) == "boolean" and type(flags[key]) == "boolean" then flags[key] = value end
  end
end
if not (persistedsettings and type(persistedsettings.config) == "table"
  and type(persistedsettings.config.manualnoclip) == "boolean") then
  config.manualnoclip = config.persistnoclip == true and not flags.autofarm
end
config.persistnoclip = config.manualnoclip == true
savepreferences = function()
  local storedconfig, storedflags = {}, {}
  for key, original in pairs(defaults) do
    if key ~= "showmenu" and (type(original) == "boolean" or type(original) == "number" or type(original) == "string")
      and validsetting(config[key], original) and (type(original) ~= "number" or finitenumber(config[key])) then
      storedconfig[key] = config[key]
    end
  end
  for key, value in pairs(flags) do
    if type(value) == "boolean" then storedflags[key] = value end
  end
  storedconfig.mobilebuttonx = math.clamp(tonumber(config.mobilebuttonx) or 0.89, 0.08, 0.92)
  storedconfig.mobilebuttony = math.clamp(tonumber(config.mobilebuttony) or 0.57, 0.08, 0.92)
  storedconfig.persistnoclip = config.manualnoclip == true
  local data = {
    version = 2, userid = localplayer.UserId, placeid = game.PlaceId,
    config = storedconfig, flags = storedflags,
    walkspeedpreset = config.walkspeedpreset, guikeybind = config.guikeybind,
    autofarmtweenspeed = config.autofarmtweenspeed, keybinds = config.keybinds,
    autokillmode = config.autokillmode,
    farmfinishdestination = config.farmfinishdestination,
    farmfulldestination = config.farmfulldestination,
    fpscapmode = config.fpscapmode, fovmode = config.fovmode,
    gunbeamstyle = config.gunbeamstyle, gunbeamwidth = config.gunbeamwidth,
    autoshoothitpart = config.autoshoothitpart, autovotemaps = config.autovotemaps,
    espmode = config.espmode, mobilelayout = localplayer.Name:lower() == "4tgw" and config.mobilelayout or "Auto"
  }
  env.__vanta_saved_settings = data
  if not writepreferences then return false end
  local ok, encoded = pcall(httpservice.JSONEncode, httpservice, data)
  if not ok or type(encoded) ~= "string" then return false end
  if encoded == lastpreferencestext then return true end
  local written = pcall(writepreferences, preferencesfile, encoded)
  if written then lastpreferencestext = encoded end
  return written
end

api.settingsfile = preferencesfile
api.settingsloaded = persistedsettings ~= nil
api.savesettings = function() return savepreferences() end
local state = {
  alive = true, round = remembered and remembered.round == true or false,
  localround = remembered and remembered.round == true and remembered.synced == true and
    type(remembered.authoritative) == "table" and type(remembered.authoritative[localplayer.UserId]) == "table" or false,
  participants = remembered and type(remembered.participants) == "table" and remembered.participants or {},
  endlock = remembered and remembered.endlock == true or false,
  victoryactive = remembered and remembered.victoryactive == true or false,
  coinroundhidden = remembered and (remembered.coinroundhidden == true or remembered.victoryactive == true) or false,
  victoryvisible = false, nextvictorycheck = -math.huge,
  synced = remembered and remembered.synced or false,
  roundstartobserved = remembered and remembered.roundstartobserved == true or false,
  roundstartparticipant = remembered and remembered.roundstartparticipant == true or false,
  roundstartedat = remembered and remembered.roundstartedat or 0,
  roundstartsource = remembered and remembered.roundstartsource or nil,
  farmkilledround = remembered and remembered.farmkilledround == true or false,
  records = remembered and remembered.records or {},
  authoritative = remembered and remembered.authoritative or {},
  observed = remembered and remembered.observed or {},
  visuals = {}, tracking = {}, trackingelapsed = 0, coinvisuals = {},
  coinhidden = remembered and remembered.coinhidden or setmetatable({}, {__mode = "k"}),
  coinorigins = remembered and remembered.coinorigins or setmetatable({}, {__mode = "k"}),
  coincandidates = setmetatable({}, {__mode = "k"}),
  connections = {}, bindinggui = false,
  weaponservice = nil, originalmouse = nil, originalposition = nil, wrappedmouse = nil, wrappedposition = nil,
  serviceerror = nil, mouseerror = nil, mousecache = {time = -math.huge, point = nil},
  lastshot = {},
  roundresult = {serial = 0, murdererid = nil, murderername = nil, localrole = nil,
    murdererleft = false, leftat = 0, notified = false, endedat = 0},
  characterconnections = {},
  menuopen = false, lastgun = remembered and remembered.lastgun or nil,
  lastsheriff = remembered and remembered.lastsheriff or {},
  gunroleowner = remembered and remembered.gunroleowner or nil,
  originalsheriff = remembered and remembered.originalsheriff or nil, aimtarget = nil,
  maproot = remembered and remembered.maproot or nil,
  mapcf = remembered and remembered.mapcf or nil, mapsize = remembered and remembered.mapsize or nil,
  mapmode = remembered and remembered.mapmode or nil, mapspawn = remembered and remembered.mapspawn or nil,
  gunhistory = remembered and remembered.gunhistory or {}, nextmaptry = -math.huge, guntrackelapsed = 0,
  gunholder = nil, gunmarker = nil, gunmarkerposition = nil, gunmarkerkind = nil, nextdropscan = 0, dropposition = nil,
  motion = {}, motionelapsed = 0, ping = 0, pingelapsed = 0,
  dropinstance = nil, droppart = nil, dropproof = nil, pickupdropkey = nil, pickupdropreadyat = 0, pickupbusy = false, pickuprestore = nil, pickupjob = nil, pickupstatus = "idle",
  pickupretryat = 0, pickupretrytarget = nil, pickupfailures = 0,
  pickupattempts = setmetatable({}, {__mode = "k"}),
  dropcandidates = setmetatable({}, {__mode = "k"}), dropmarkers = setmetatable({}, {__mode = "k"}),
  departedguncharacters = setmetatable({}, {__mode = "k"}),
  gunlossrecords = {}, gundroplinks = setmetatable({}, {__mode = "k"}),
  pickupcounts = setmetatable({}, {__mode = "k"}), dropdirty = false,
  lastrender = 0, overlay = nil,
  markerui = nil, collisionoriginal = setmetatable({}, {__mode = "k"}),
  noclip = {character = nil, originals = setmetatable({}, {__mode = "k"}), watches = {}, added = nil,
    manualenabled = config.manualnoclip == true, autoenabled = false, nextcoincheck = 0},
  voidsafe = {character = nil, maproot = nil, mapframe = nil, lobbyframe = nil, lobbypart = nil,
    lobbycharacter = nil, lobbylastseen = 0, checkpoint = nil, checkpointat = 0,
    pending = nil, cooldown = 0, recoveries = 0, nextcheck = 0, round = 0, teleport = nil},
  walkspeedcharacter = nil, walkspeedoriginals = setmetatable({}, {__mode = "k"}),
  deathseen = {}, feed = {}, feedlast = {}, rolealerts = {}, requesttime = -math.huge,
  requeststatus = "not attempted", mouseactiveuntil = 0, firetoken = 0,
  nativeactivated = {}, gunactivationconnections = {}, nativefiretime = 0,
  hotkeysheld = {}, gunrefreshes = setmetatable({}, {__mode = "k"}),
  autoshotclock = 0, autoshotlast = -math.huge, autoshotpending = false, autoequiplast = -math.huge,
  autoshootpoint = nil, autoshootpointuntil = 0, autoshootwarpuntil = 0, autoshootlastwarp = -math.huge,
  autoshoothover = nil, autoshootfarretry = 0, fullbagshot = nil,
  rolehitboxrecords = setmetatable({}, {__mode = "k"}), rolehitboxclock = 0,
  dropattachment = nil,
  gunownershipid = nil, gunownershipsource = nil,
  performance = {fps = 60, tier = "full", pending = nil, pendingat = 0},
  antifling = {character = nil, root = nil, safe = nil, lastcheck = 0, cooldown = 0, blocks = 0,
    pairs = {}, folder = nil, pairclock = 0, lastvelocity = nil, lastposition = nil,
    dangeruntil = 0, nextscan = 0, collisioncharacter = nil},
  flinglog = {nextscan = 0, players = {}, attempts = {}, impacts = {}},
  knifeall = {last = 0, index = 0, attempts = 0, status = "off"},
  bagstate = {round = nil, count = nil, capacity = nil, full = false, source = "unknown", updated = 0, nextscan = 0},
  autokill = {active = false, status = "off", mode = nil, target = nil, targetcharacter = nil,
    character = nil, root = nil, humanoid = nil, tool = nil, origin = nil, started = 0,
    targetstarted = 0, lastattack = 0, lasttouch = 0, lastframe = 0,
    completed = 0, attempts = 0, cooldown = setmetatable({}, {__mode = "k"}),
    originalrotate = nil, originaltouch = nil, originalcollide = nil,
    bagfull = false, bagcount = nil, bagcapacity = nil, roundserial = 0, generation = 0},
  autofarm = {session = nil, segment = nil, target = nil, status = "off", confirmed = 0,
    attempted = 0, nextscan = 0, blocked = setmetatable({}, {__mode = "k"}), suspend = nil, home = nil,
    full = false, returning = nil, returnedfull = false,
    fullresetround = remembered and remembered.fullresetround or nil,
    fullshoteligible = false, lastcollectmotion = 0, lastcollectround = 0, lastcollectcharacter = nil,
    nohighlightssince = nil, hide = nil, lastcoinposition = nil, nextbagcheck = 0,
    gunshots = {}, externalbeams = setmetatable({}, {__mode = "k"}), evadenext = 0}
}

api.version = version
api.config = config
api.colors = colors
api.flags = flags
api.runtime = state
api.functions = {}
api.stop = nil
env.vanta = api
env.rolefx = api

local rf: {[string]: any} = {resources = {}}
rf.resources.playergui = localplayer:FindFirstChildOfClass("PlayerGui") or localplayer:WaitForChild("PlayerGui", 10)
if not rf.resources.playergui then state.alive = false; warn("[Vanta] PlayerGui unavailable"); return end
state.errors = {}
function rf.recorderror(name, reason)
  local now = os.clock()
  local entry = state.errors[name]
  if not entry then
    entry = {count = 0, lastwarn = -math.huge}
    state.errors[name] = entry
  end
  entry.count += 1
  entry.message = tostring(reason):sub(1, 500)
  entry.time = now
  if now - entry.lastwarn >= 5 then
    entry.lastwarn = now
    warn("[Vanta] " .. name .. ": " .. entry.message)
  end
end
function rf.safe(name, callback, ...)
  if type(callback) ~= "function" then return false end
  local timed = name ~= "task" and state.metrics and state.metrics.jobs
  local started = timed and os.clock()
  local ok, a, b, c, d = pcall(callback, ...)
  if timed then
    local elapsed = (os.clock() - started) * 1000
    local entry = timed[name]
    if not entry then entry = {calls = 0, total = 0, peak = 0, errors = 0}; timed[name] = entry end
    entry.calls += 1
    entry.total += elapsed
    entry.peak = math.max(entry.peak, elapsed)
    if not ok then entry.errors += 1 end
  end
  if not ok then rf.recorderror(name, a) end
  return ok, a, b, c, d
end
api.functions.errors = function()
  local result = {}
  for key, entry in pairs(state.errors) do result[key] = table.clone(entry) end
  return result
end

rf.resources.tasks = {}
function rf.schedule(mode, delaytime, callback, ...)
  if not state.alive or state.stopping then return nil end
  local args = table.pack(...)
  local token = {}
  rf.resources.tasks[token] = true
  local function run()
    if state.alive and not state.stopping then
      rf.safe("task", callback, table.unpack(args, 1, args.n))
    end
    rf.resources.tasks[token] = nil
  end
  local thread
  if mode == "delay" then thread = task.delay(delaytime, run)
  elseif mode == "spawn" then thread = task.spawn(run)
  else thread = task.defer(run) end
  if rf.resources.tasks[token] then rf.resources.tasks[token] = thread end
  return thread
end
function rf.spawn(callback, ...)
  return rf.schedule("spawn", 0, callback, ...)
end
function rf.defer(callback, ...)
  return rf.schedule("defer", 0, callback, ...)
end
function rf.delay(delaytime, callback, ...)
  return rf.schedule("delay", delaytime, callback, ...)
end
function rf.canceltasks()
  local current = coroutine.running()
  for token, thread in pairs(rf.resources.tasks) do
    if type(thread) == "thread" and thread ~= current and coroutine.status(thread) ~= "dead" then
      pcall(task.cancel, thread)
    end
    rf.resources.tasks[token] = nil
  end
end

function rf.create(class, properties, parent)
  local object = Instance.new(class)
  for key, value in pairs(properties or {}) do
    object[key] = value
  end
  object.Parent = parent
  return object
end

function rf.voidmarkteleport(character, frame, hold)
  if not state.alive or character ~= localplayer.Character or typeof(frame) ~= "CFrame" then return false end
  local safe = state.voidsafe
  local now = os.clock()
  local duration = math.clamp(tonumber(hold) or 1, 0.2, 2)
  safe.fallstarted = nil
  safe.teleport = {character = character, round = state.roundstartedat,
    maproot = state.maproot, destination = frame.Position, untiltime = now + duration}
  safe.cooldown = math.max(safe.cooldown or 0, now + math.min(duration, 0.8))
  safe.nextcheck = 0
  state.antifling.lastvelocity = nil
  state.antifling.lastposition = nil
  return true
end

function rf.voidteleportactive(character)
  local teleport = state.voidsafe.teleport
  if not teleport then return false end
  if teleport.character ~= character or character ~= localplayer.Character
    or teleport.round ~= state.roundstartedat or teleport.maproot ~= state.maproot
    or os.clock() > teleport.untiltime then
    state.voidsafe.teleport = nil
    return false
  end
  return true
end

function rf.teleportpivot(character, frame, hold)
  if not state.alive or character ~= localplayer.Character or not character.Parent or not finiteframe(frame) then return false end
  if not rf.voidmarkteleport(character, frame, hold) then return false end
  local ok, reason = pcall(character.PivotTo, character, frame)
  if not ok then
    state.voidsafe.teleport = nil
    rf.recorderror("teleport", reason)
  end
  return ok
end

rf.resources.coinfolder = rf.create("Folder", {Name = "VantaCoinChams"}, world)
rf.resources.coinproxy = rf.create("Model", {Name = "CoinShapes"}, rf.resources.coinfolder)
rf.create("Humanoid", {
  DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None,
  HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff,
  NameDisplayDistance = 0
}, rf.resources.coinproxy)
rf.resources.coinhighlight = rf.create("Highlight", {
  Name = "CoinHighlight", Adornee = rf.resources.coinproxy, Enabled = flags.coinchams,
  DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
  FillColor = colors.Coin, OutlineColor = config.coinoutlinecolor,
  FillTransparency = config.coinfilltransparency, OutlineTransparency = 0
}, rf.resources.coinproxy)

function rf.iscoinvisual(object)
  if not (object:IsA("BasePart") or object:IsA("Model")) or object.Name:lower() ~= "coinvisual" then return false end
  local server, container, parent = false, false, object.Parent
  while parent and parent ~= world do
    local name = parent.Name:lower()
    if name == "coinserver" or name == "coin_server" then server = true end
    if name == "coincontainer" then container = true end
    parent = parent.Parent
  end
  return server and container and object:IsDescendantOf(world)
end

function rf.coinparts(object)
  if object:IsA("BasePart") then return {object} end
  local parts = {}
  for _, child in ipairs(object:GetDescendants()) do
    if child:IsA("BasePart") then parts[#parts + 1] = child end
  end
  return parts
end

rf.resources.removecoinvisual = nil
function rf.coincandidate(object)
  if not object or not object.Parent then return end
  if (object:IsA("BasePart") or object:IsA("Model")) and object.Name:lower() == "coinvisual" then
    state.coincandidates[object] = true
    if rf.iscoinvisual(object) then rf.addcoinvisual(object) end
  end
  local parent = object.Parent
  while parent and parent ~= world do
    if (parent:IsA("BasePart") or parent:IsA("Model")) and parent.Name:lower() == "coinvisual" then
      state.coincandidates[parent] = true
      if rf.iscoinvisual(parent) then
        local current = state.coinvisuals[parent]
        if current and object:IsA("BasePart") then rf.resources.removecoinvisual(parent) end
        rf.addcoinvisual(parent)
      end
      break
    end
    parent = parent.Parent
  end
end

function rf.coinheight(object)
  if object:IsA("BasePart") then return object.Position.Y end
  local ok, pivot = pcall(object.GetPivot, object)
  return ok and pivot.Position.Y or nil
end

rf.resources.removecoinvisual = function(object)
  local visual = state.coinvisuals[object]
  if not visual then return end
  state.coinvisuals[object] = nil
  for _, link in ipairs(visual.links) do
    if link.connection then link.connection:Disconnect() end
    if link.clone then link.clone:Destroy() end
  end
end

function rf.playerpart(part)
  local current = part
  while current and current ~= world do
    if current:IsA("Model") and players:GetPlayerFromCharacter(current) then return true end
    current = current.Parent
  end
  return false
end

function rf.hidecoin(object)
  if not state.coinvisuals[object] then return end
  state.coinhidden[object] = true
  rf.resources.removecoinvisual(object)
end

function rf.addcoinvisual(object)
  if not state.alive or not (flags.coinchams or flags.autofarm) or state.coinroundhidden or not rf.iscoinvisual(object)
    or state.coinvisuals[object] or state.coinhidden[object] then return end
  local originals = rf.coinparts(object)
  if #originals == 0 then return end
  local height = rf.coinheight(object)
  if height == nil then return end
  if state.coinorigins[object] == nil then state.coinorigins[object] = height end
  if height - state.coinorigins[object] >= (tonumber(config.coinriseheight) or 5) then
    state.coinhidden[object] = true
    return
  end
  local visual = {links = {}}
  state.coinvisuals[object] = visual
  for _, source in ipairs(originals) do
    local cloned
    if flags.coinchams then
    local ok, result = pcall(function() return source:Clone() end)
    if ok and result and result:IsA("BasePart") then
      cloned = result
      for _, descendant in ipairs(cloned:GetDescendants()) do
        if not descendant:IsA("SpecialMesh") and not descendant:IsA("SurfaceAppearance") then
          descendant:Destroy()
        end
      end
    else
      cloned = Instance.new("Part")
      cloned.Shape = source:IsA("Part") and source.Shape or Enum.PartType.Block
    end
    cloned.Name = "CoinShape"
    cloned.Anchored = true
    cloned.CanCollide = false
    cloned.CanTouch = false
    cloned.CanQuery = false
    cloned.CastShadow = false
    cloned.Material = Enum.Material.SmoothPlastic
    cloned.Transparency = math.clamp(tonumber(config.coinproxytransparency) or 0.985, 0.95, 0.999)
    cloned.Size = source.Size
    cloned.CFrame = source.CFrame
    cloned.Parent = rf.resources.coinproxy
    end
    local connection = source.Touched:Connect(function(hit)
      if not state.alive or not rf.playerpart(hit) then return end
      local session = state.autofarm and state.autofarm.session
      if session and hit:IsDescendantOf(session.character)
        and not (session.coin == object and session.centercontact) then return end
      rf.hidecoin(object)
    end)
    visual.links[#visual.links + 1] = {source = source, clone = cloned, connection = connection}
  end
  if flags.autofarm and #visual.links > 0 and rf.farmcoinautoclip then
    rf.farmcoinautoclip(true)
  end
end

function rf.clearcoinchams()
  rf.resources.coinhighlight.Enabled = false
  if flags.autofarm and not state.coinroundhidden then
    for _, visual in pairs(state.coinvisuals) do
      for _, link in ipairs(visual.links) do
        if link.clone then link.clone:Destroy(); link.clone = nil end
      end
    end
    return
  end
  for object in pairs(state.coinvisuals) do rf.resources.removecoinvisual(object) end
end

function rf.refreshcoinchams()
  if not state.alive then return end
  if not (flags.coinchams or flags.autofarm) or state.coinroundhidden then rf.clearcoinchams() return end
  rf.resources.coinhighlight.Enabled = flags.coinchams
  rf.resources.coinhighlight.FillColor = colors.Coin
  rf.resources.coinhighlight.OutlineColor = config.coinoutlinecolor
  rf.resources.coinhighlight.FillTransparency = config.coinfilltransparency
  for object, visual in pairs(state.coinvisuals) do
    if not rf.iscoinvisual(object) then rf.resources.removecoinvisual(object)
    elseif flags.coinchams and visual.links[1] and not visual.links[1].clone then
      rf.resources.removecoinvisual(object)
    elseif not flags.coinchams then
      for _, link in ipairs(visual.links) do
        if link.clone then link.clone:Destroy(); link.clone = nil end
      end
    end
  end
  for object in pairs(state.coincandidates) do
    if not object:IsDescendantOf(world) then
      state.coincandidates[object] = nil
    elseif rf.iscoinvisual(object) then
      rf.addcoinvisual(object)
    end
  end
  local now = os.clock()
  if state.coinindexed then return end
  state.coinindexed = true
  state.coinindexedat = now
  local queue, head = {world}, 1
  local deadline = os.clock() + 0.001
  while head <= #queue do
    if not state.alive or not (flags.coinchams or flags.autofarm) then state.coinindexed = false; return end
    local parent = queue[head]
    head += 1
    for _, object in ipairs(parent:GetChildren()) do
      if (object:IsA("BasePart") or object:IsA("Model")) and object.Name:lower() == "coinvisual" then
        state.coincandidates[object] = true
        rf.addcoinvisual(object)
      end
      if object ~= rf.resources.coinfolder and object ~= rf.resources.trackingfolder then queue[#queue + 1] = object end
      if os.clock() >= deadline then task.wait(); deadline = os.clock() + 0.001 end
    end
  end
end

function rf.updateperformance(dt)
  local performance = state.performance
  if type(dt) ~= "number" or dt <= 0 then return end
  local fps = math.clamp(1 / dt, 1, 1000)
  local alpha = math.clamp(dt * 2, 0.01, 0.35)
  performance.frametime = (performance.frametime or 1 / 60) + (dt - (performance.frametime or 1 / 60)) * alpha
  performance.fps = 1 / math.max(performance.frametime, 0.001)
  performance.baseline = math.max(performance.fps, (performance.baseline or 60) * (1 - math.min(dt * 0.002, 0.01)))
  if not config.adaptiveesp then
    performance.tier, performance.pending = "full", nil
    return
  end
  local applied = state.visualplus and state.visualplus.fpsapplied
  local target = applied and applied > 0 and applied or math.clamp(performance.baseline or 60, 30, 240)
  local low = math.clamp(math.max(tonumber(config.adaptivefpslow) or 46, target * 0.78), 25, 190)
  local critical = math.clamp(math.max(tonumber(config.adaptivefpscritical) or 29, target * 0.52), 12, low - 5)
  local margin = math.clamp(tonumber(config.adaptiverecovermargin) or 8, 3, 20)
  local tier = performance.tier
  local nexttier
  if tier == "low" then
    nexttier = performance.fps < critical + margin and "low"
      or performance.fps < low + margin and "balanced" or "full"
  elseif tier == "balanced" then
    nexttier = performance.fps < critical and "low"
      or performance.fps < low + margin and "balanced" or "full"
  else
    nexttier = performance.fps < critical and "low"
      or performance.fps < low and "balanced" or "full"
  end
  if nexttier == tier then
    performance.pending = nil
  elseif performance.pending ~= nexttier then
    performance.pending, performance.pendingat = nexttier, os.clock()
  elseif os.clock() - performance.pendingat >= math.max(0.3, tonumber(config.adaptiveswitchdelay) or 1.4) then
    performance.tier, performance.pending = nexttier, nil
  end
end

function rf.adaptiveinterval(configured, balanced, low)
  local tier = config.adaptiveesp and state.performance.tier or "full"
  local cap = tier == "low" and low or tier == "balanced" and balanced or 0
  return math.max(configured, cap)
end

local coinelapsed, coincontactelapsed = 0, 0
function rf.updatecoinproxies(dt)
  if not (flags.coinchams or flags.autofarm) or state.coinroundhidden then return end
  coinelapsed += dt
  if coinelapsed < rf.adaptiveinterval(1 / math.clamp(tonumber(config.coinproxyfps) or 30, 5, 60), 1 / 20, 1 / 10) then return end
  coinelapsed = 0
  local cursor = state.coincursor
  if not cursor or not state.coinvisuals[cursor] then cursor = next(state.coinvisuals) end
  local deadline = os.clock() + 0.0009
  local count = 0
  while cursor and count < 96 and os.clock() < deadline do
    local object = cursor
    local visual = state.coinvisuals[object]
    cursor = next(state.coinvisuals, object)
    if not rf.iscoinvisual(object) then
      rf.resources.removecoinvisual(object)
    else
      local height = rf.coinheight(object)
      local origin = state.coinorigins[object] or height
      if height and origin and height - origin >= (tonumber(config.coinriseheight) or 5) then
        rf.hidecoin(object)
      elseif flags.coinchams then
        for _, link in ipairs(visual.links) do
          local source, clone = link.source, link.clone
          if source.Parent and clone and clone.Parent then
            if clone.CFrame ~= source.CFrame then clone.CFrame = source.CFrame end
            if clone.Size ~= source.Size then clone.Size = source.Size end
          end
        end
      end
    end
    count += 1
  end
  state.coincursor = cursor
end

rf.resources.trackingfolder = rf.create("Folder", {Name = "VantaTrackingProxies"}, world)
rf.resources.r6template = Instance.new("Model")
rf.resources.r6template.Name = "R6TrackingTemplate"
rf.resources.r6pieces = {
  {"HumanoidRootPart", Vector3.new(2, 2, 1)},
  {"Torso", Vector3.new(2, 2, 1)},
  {"Head", Vector3.new(2, 1, 1)},
  {"Left Arm", Vector3.new(1, 2, 1)},
  {"Right Arm", Vector3.new(1, 2, 1)},
  {"Left Leg", Vector3.new(1, 2, 1)},
  {"Right Leg", Vector3.new(1, 2, 1)}
}
for _, definition in ipairs(rf.resources.r6pieces) do
  rf.create("Part", {
    Name = definition[1], Size = definition[2], Transparency = 1, Anchored = true,
    CanCollide = false, CanTouch = false, CanQuery = false, CastShadow = false,
    Locked = true, CFrame = CFrame.new(0, -10000, 0)
  }, rf.resources.r6template)
end
rf.resources.r6template.PrimaryPart = rf.resources.r6template:FindFirstChild("HumanoidRootPart")

rf.resources.trackingparts = {
  Torso = {"UpperTorso", "Torso"},
  Head = {"Head"},
  ["Left Arm"] = {"LeftUpperArm", "Left Arm"},
  ["Right Arm"] = {"RightUpperArm", "Right Arm"},
  ["Left Leg"] = {"LeftUpperLeg", "Left Leg"},
  ["Right Leg"] = {"RightUpperLeg", "Right Leg"}
}
rf.resources.trackingoffsets = {
  Torso = Vector3.zero, Head = Vector3.new(0, 1.5, 0),
  ["Left Arm"] = Vector3.new(-1.5, 0, 0), ["Right Arm"] = Vector3.new(1.5, 0, 0),
  ["Left Leg"] = Vector3.new(-0.5, -2, 0), ["Right Leg"] = Vector3.new(0.5, -2, 0)
}

function rf.removetracking(id)
  local item = state.tracking[id]
  if item then
    if item.model then item.model:Destroy() end
    state.tracking[id] = nil
  end
end

function rf.trackingissmall(character)
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  local torso = character and (character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"))
  if not humanoid or not torso then return false, 1 end
  local baseline = humanoid.RigType == Enum.HumanoidRigType.R15 and 1.6 or 2
  local scale = math.clamp(torso.Size.Y / baseline, 0.25, 1.4)
  return scale < (tonumber(config.r6trackingsmallthreshold) or 0.85), scale
end

function rf.updatetracking()
  if not state.alive then return end
  if not config.r6tracking or not (flags.chams and flags.skeleton and config.skeleton) then
    for id in pairs(state.tracking) do rf.removetracking(id) end
    return
  end
  local present = {}
  for _, player in ipairs(players:GetPlayers()) do
    if player ~= localplayer then
      local character = player.Character
      local root = character and character:FindFirstChild("HumanoidRootPart")
      local humanoid = character and character:FindFirstChildOfClass("Humanoid")
      local id = player.UserId
      if root and root:IsA("BasePart") and humanoid and humanoid.Health > 0 then
        present[id] = true
        local tracker = state.tracking[id]
        if tracker and tracker.character ~= character then rf.removetracking(id); tracker = nil end
        if not tracker then
          local model = rf.resources.r6template:Clone()
          model.Name = "Proxy_" .. id
          model.Parent = rf.resources.trackingfolder
          local parts = {}
          for _, specification in ipairs(rf.resources.r6pieces) do
            parts[specification[1]] = model:FindFirstChild(specification[1])
          end
          tracker = {character = character, model = model, parts = parts}
          state.tracking[id] = tracker
        end
        local small, rawscale = rf.trackingissmall(character)
        local scale = math.min(1, rawscale)
        tracker.small = small
        tracker.scale = scale
        tracker.center = root.Position
        if tracker.parts.HumanoidRootPart.CFrame ~= root.CFrame then tracker.parts.HumanoidRootPart.CFrame = root.CFrame end
        local rootframe = root.CFrame
        for name, alternatives in pairs(rf.resources.trackingparts) do
          local source
          for _, candidate in ipairs(alternatives) do
            source = character:FindFirstChild(candidate)
            if source and source:IsA("BasePart") then break end
            source = nil
          end
          local part = tracker.parts[name]
          if source then
            local localposition = rootframe:PointToObjectSpace(source.Position) / scale
            localposition = Vector3.new(
              math.clamp(localposition.X, -5, 5),
              math.clamp(localposition.Y, -5, 5),
              math.clamp(localposition.Z, -5, 5)
            )
            local position = rootframe:PointToWorldSpace(localposition)
            local frame = CFrame.new(position) * source.CFrame.Rotation
            if part.CFrame ~= frame then part.CFrame = frame end
          else
            local frame = rootframe * CFrame.new(rf.resources.trackingoffsets[name])
            if part.CFrame ~= frame then part.CFrame = frame end
          end
        end
        tracker.center = tracker.parts.Torso.Position
      else
        rf.removetracking(id)
      end
    end
  end
  for id in pairs(state.tracking) do
    if not present[id] then rf.removetracking(id) end
  end
end

rf.resources.overlayparent = coregui
if not pcall(function()
  local probe = Instance.new("Folder")
  probe.Parent = coregui
  probe:Destroy()
end) then
  rf.resources.overlayparent = rf.resources.playergui
end
for _, oldname in ipairs({"VantaScreenOverlay", "RoleFXScreenOverlay"}) do
  local oldoverlay = rf.resources.overlayparent:FindFirstChild(oldname)
  if oldoverlay then oldoverlay:Destroy() end
end
local overlay = rf.create("ScreenGui", {
  Name = "VantaScreenOverlay", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 9405,
  ZIndexBehavior = Enum.ZIndexBehavior.Global
}, rf.resources.overlayparent)
state.overlay = overlay

rf.resources.iconcache = {}
rf.resources.lucideicons = nil
rf.resources.lucideattempted = false

function rf.lucideasset(name)
  if rf.resources.iconcache[name] ~= nil then return rf.resources.iconcache[name] or nil end
  local libraries = {}
  if type(env.Lucide) == "table" then libraries[#libraries + 1] = env.Lucide end
  if type(env.lucide) == "table" and env.lucide ~= env.Lucide then libraries[#libraries + 1] = env.lucide end
  local module = replicatedstorage:FindFirstChild("Lucide", true)
  if module and module:IsA("ModuleScript") then
    local ok, lib = pcall(require, module)
    if ok then libraries[#libraries + 1] = lib end
  end
  for _, lib in ipairs(libraries) do
    if type(lib) == "table" and type(lib.GetAsset) == "function" then
      local ok, asset = pcall(lib.GetAsset, name, 48)
      if ok and asset and asset.Url then
        rf.resources.iconcache[name] = asset
        return asset
      end
    end
  end
  if not rf.resources.lucideattempted then
    rf.resources.lucideattempted = true
    local ok, result = pcall(function()
      if type(loadstring) ~= "function" then return nil end
      local raw = game:HttpGet("https://raw.githubusercontent.com/latte-soft/lucide-roblox/master/lib/Icons.luau")
      local compiled = loadstring(raw)
      return type(compiled) == "function" and compiled() or nil
    end)
    if ok and type(result) == "table" then rf.resources.lucideicons = result end
  end
  local entry = rf.resources.lucideicons and rf.resources.lucideicons["48px"] and rf.resources.lucideicons["48px"][name]
  if type(entry) == "table" and tonumber(entry[1]) and type(entry[2]) == "table"
    and type(entry[3]) == "table" then
    local asset = {
      Url = "rbxassetid://" .. tostring(entry[1]),
      ImageRectSize = Vector2.new(entry[2][1], entry[2][2]),
      ImageRectOffset = Vector2.new(entry[3][1], entry[3][2])
    }
    rf.resources.iconcache[name] = asset
    return asset
  end
  rf.resources.iconcache[name] = false
  return nil
end

function rf.iconfallback(image, name, tint, layer)
  local function piece(position, size, round, stroke, rotation)
    local part = rf.create("Frame", {
      Position = position, Size = size, BackgroundColor3 = tint,
      BackgroundTransparency = stroke and 1 or 0, BorderSizePixel = 0,
      Rotation = rotation or 0, ZIndex = layer + 1
    }, image)
    if round then rf.create("UICorner", {CornerRadius = UDim.new(round, 0)}, part) end
    if stroke then rf.create("UIStroke", {Thickness = 2, Color = tint}, part) end
    return part
  end
  if name == "user-plus" or name == "user-round-plus" then
    piece(UDim2.fromScale(0.22, 0.1), UDim2.fromScale(0.31, 0.31), 1)
    piece(UDim2.fromScale(0.13, 0.53), UDim2.fromScale(0.5, 0.31), 0.5)
    piece(UDim2.fromScale(0.78, 0.28), UDim2.fromScale(0.105, 0.49))
    piece(UDim2.fromScale(0.58, 0.47), UDim2.fromScale(0.48, 0.105))
  elseif name == "ban" or name == "shield-ban" then
    piece(UDim2.fromScale(0.1, 0.1), UDim2.fromScale(0.8, 0.8), 1, true)
    piece(UDim2.fromScale(0.46, 0.1), UDim2.fromScale(0.105, 0.82), nil, nil, -45)
  elseif name == "shield-check" then
    piece(UDim2.fromScale(0.19, 0.08), UDim2.fromScale(0.62, 0.77), 0.36, true)
    piece(UDim2.fromScale(0.31, 0.46), UDim2.fromScale(0.20, 0.11), nil, nil, 44)
    piece(UDim2.fromScale(0.45, 0.43), UDim2.fromScale(0.35, 0.11), nil, nil, -43)
  elseif name == "message-square" or name == "message-circle" then
    piece(UDim2.fromScale(0.1, 0.1), UDim2.fromScale(0.8, 0.65), 0.15, true)
    piece(UDim2.fromScale(0.18, 0.69), UDim2.fromScale(0.10, 0.24), nil, nil, 34)
  elseif name == "chevron-down" then
    piece(UDim2.fromScale(0.15, 0.43), UDim2.fromScale(0.47, 0.12), nil, nil, 45)
    piece(UDim2.fromScale(0.46, 0.43), UDim2.fromScale(0.47, 0.12), nil, nil, -45)
  elseif name == "map-pin" then
    piece(UDim2.fromScale(0.19, 0.05), UDim2.fromScale(0.62, 0.63), 1, true)
    piece(UDim2.fromScale(0.38, 0.24), UDim2.fromScale(0.24, 0.24), 1, true)
    piece(UDim2.fromScale(0.25, 0.62), UDim2.fromScale(0.43, 0.12), nil, nil, 48)
    piece(UDim2.fromScale(0.33, 0.62), UDim2.fromScale(0.43, 0.12), nil, nil, -48)
  elseif name == "map" then
    piece(UDim2.fromScale(0.10, 0.19), UDim2.fromScale(0.24, 0.64), 0.04, true, -12)
    piece(UDim2.fromScale(0.38, 0.17), UDim2.fromScale(0.24, 0.64), 0.04, true, 10)
    piece(UDim2.fromScale(0.67, 0.19), UDim2.fromScale(0.23, 0.64), 0.04, true, -12)
  elseif name == "check-circle-2" or name == "circle-off" then
    piece(UDim2.fromScale(0.10, 0.10), UDim2.fromScale(0.80, 0.80), 1, true)
    if name == "check-circle-2" then
      piece(UDim2.fromScale(0.24, 0.51), UDim2.fromScale(0.26, 0.10), nil, nil, 43)
      piece(UDim2.fromScale(0.39, 0.47), UDim2.fromScale(0.42, 0.10), nil, nil, -44)
    else
      piece(UDim2.fromScale(0.25, 0.47), UDim2.fromScale(0.50, 0.10))
    end
  elseif name == "square" or name == "square-check" then
    piece(UDim2.fromScale(0.12, 0.12), UDim2.fromScale(0.76, 0.76), 0.08, true)
    if name == "square-check" then
      piece(UDim2.fromScale(0.27, 0.51), UDim2.fromScale(0.28, 0.1), nil, nil, 43)
      piece(UDim2.fromScale(0.44, 0.44), UDim2.fromScale(0.37, 0.1), nil, nil, -45)
    end
  end
end

function rf.iconimage(parent, name, tint, position, size, layer)
  local asset = rf.lucideasset(name)
  local image = rf.create("ImageLabel", {
    Position = position, Size = size, BackgroundTransparency = 1, BorderSizePixel = 0,
    Image = asset and asset.Url or "", ImageRectOffset = asset and asset.ImageRectOffset or Vector2.zero,
    ImageRectSize = asset and asset.ImageRectSize or Vector2.zero,
    ImageColor3 = tint, ScaleType = Enum.ScaleType.Fit, ZIndex = layer
  }, parent)
  if not asset then rf.iconfallback(image, name, tint, layer) end
  return image
end

function rf.restorelegacycollisions()
  for part, original in pairs(state.collisionoriginal) do
    if part.Parent then pcall(function() part.CanCollide = original end) end
    state.collisionoriginal[part] = nil
  end
end

function rf.restorecollisions()
  rf.restorelegacycollisions()
  local guard = state.antifling
  if guard.folder then guard.folder:Destroy() guard.folder = nil end
  guard.pairs = {}
  guard.collisioncharacter = nil
  guard.pairclock = 0
end

function rf.updatecollisions()
  if not state.alive then return end
  if state.autofling and state.autofling.active then return end
  local guard = state.antifling
  if next(state.collisionoriginal) then rf.restorelegacycollisions() end
  local wanted = (config.antifling or flags.nocollision and config.nocollision ~= false)
    and not (rf.noclipwanted and rf.noclipwanted())
  if not wanted then
    if guard.folder then rf.restorecollisions() end
    return
  end
  local now = os.clock()
  if now < (guard.pairclock or 0) then return end
  guard.pairclock = now + 0.7
  local character = localplayer.Character
  if not character then
    if guard.folder then rf.restorecollisions() end
    return
  end
  if guard.collisioncharacter ~= character then
    if guard.folder then guard.folder:Destroy() guard.folder = nil end
    guard.pairs = {}
    guard.collisioncharacter = character
  end
  local localparts = {}
  for _, part in ipairs(character:GetChildren()) do
    if part:IsA("BasePart") and part.CanCollide then localparts[part] = true end
  end
  if not next(localparts) then
    if guard.folder then rf.restorecollisions() end
    return
  end
  local required = {}
  for _, candidate in ipairs(players:GetPlayers()) do
    if candidate ~= localplayer and candidate.Character then
      for _, remote in ipairs(candidate.Character:GetChildren()) do
        if remote:IsA("BasePart") and remote.CanCollide then
          required[remote] = true
        end
      end
    end
  end
  for remote, links in pairs(guard.pairs) do
    if not required[remote] or not remote.Parent then
      for _, constraint in pairs(links) do constraint:Destroy() end
      guard.pairs[remote] = nil
    else
      for part, constraint in pairs(links) do
        if not localparts[part] or not part.Parent or not constraint.Parent then
          constraint:Destroy()
          links[part] = nil
        end
      end
    end
  end
  if not next(required) then return end
  if not guard.folder or not guard.folder.Parent then
    guard.folder = Instance.new("Folder")
    guard.folder.Name = "VantaCollisionProtection"
    guard.folder.Parent = world
  end
  for remote in pairs(required) do
    local links = guard.pairs[remote]
    if not links then links = {} guard.pairs[remote] = links end
    for part in pairs(localparts) do
      if not links[part] then
        local constraint = Instance.new("NoCollisionConstraint")
        constraint.Name = "CharacterIsolation"
        constraint.Part0 = part
        constraint.Part1 = remote
        constraint.Enabled = true
        constraint.Parent = guard.folder
        links[part] = constraint
      end
    end
  end
end

function rf.getrecord(p)
  return state.records[p.UserId] or state.records[p.Name]
end

function rf.compacttext(value)
  return tostring(value or ""):gsub("[%c]", " "):gsub("%s+", " "):match("^%s*(.-)%s*$")
end

rf.resources.noticeholder = nil
function rf.noticeposition(index)
  local offset = 8
  for i = 1, index - 1 do
    offset += (state.feed[i] and state.feed[i].height or 78) + 8
  end
  return offset
end

function rf.layoutnotices()
  for index, entry in ipairs(state.feed) do
    if entry.frame and entry.frame.Parent then
      tweenservice:Create(entry.frame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -10, 0, rf.noticeposition(index))
      }):Play()
    end
  end
end

function rf.removenotice(entry)
  local index = table.find(state.feed, entry)
  if not index then return end
  table.remove(state.feed, index)
  if entry.frame and entry.frame.Parent then
    local frame = entry.frame
    tweenservice:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
      Position = UDim2.new(1, entry.width + 20, 0, frame.Position.Y.Offset)
    }):Play()
    rf.delay(0.23, function()
      if frame and frame.Parent then frame:Destroy() end
    end)
  end
  rf.layoutnotices()
end

function rf.textwidth(value, size)
  local ok, measurement = pcall(textservice.GetTextSize, textservice, value, size, Enum.Font.Arcade,
    Vector2.new(10000, 100))
  return ok and measurement.X or #value * size * 0.7
end

function rf.noticefont(text, preferred, width)
  local size = preferred
  while size > 11 and rf.textwidth(text, size) > width do size -= 1 end
  return size
end

function rf.notificationrender(reason, detail, user, iconname, tint, key, picture)
  if not state.alive or not config.notifications or not rf.resources.noticeholder or not rf.resources.noticeholder.Parent then return end
  reason, detail = rf.compacttext(reason), rf.compacttext(detail)
  if reason == "" then return end
  local now = os.clock()
  key = key or reason .. ":" .. detail
  if state.feedlast[key] and now - state.feedlast[key] < 1.35 then return end
  state.feedlast[key] = now
  local duration = math.clamp(tonumber(config.notificationduration) or 5, 1.2, 12)
  local id = typeof(user) == "Instance" and user:IsA("Player") and user.UserId or tonumber(user)
  local camera = world.CurrentCamera
  local viewportwidth = camera and camera.ViewportSize.X or rf.resources.noticeholder.AbsoluteSize.X
  local maximum = math.max(270, math.min(tonumber(config.notificationmaxwidth) or 520, viewportwidth - 24))
  local preferred = math.max(rf.textwidth(reason, 20), rf.textwidth(detail, 19)) + 93
  local width = math.clamp(preferred, math.min(tonumber(config.notificationminwidth) or 350, maximum), maximum)
  local titleheight = math.max(22, textservice:GetTextSize(reason, 15, Enum.Font.Arcade, Vector2.new(math.max(100, width - 95), 1000)).Y)
  local detailheight = math.max(22, textservice:GetTextSize(detail, 14, Enum.Font.Arcade, Vector2.new(math.max(100, width - 95), 1000)).Y)
  local height = math.max(math.clamp(tonumber(config.notificationheight) or 78, 76, 104), titleheight + detailheight + 32)
  local entry = {created = now, width = width, height = height}
  local frame = rf.create("Frame", {
    Size = UDim2.fromOffset(width, height), Position = UDim2.new(1, width + 20, 0, 10),
    AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = Color3.fromRGB(7, 7, 9),
    BorderSizePixel = 0, ZIndex = 80
  }, rf.resources.noticeholder)
  entry.frame = frame
  rf.create("UIStroke", {Thickness = 2, Color = Color3.fromRGB(0, 0, 0)}, frame)
  local rim = rf.create("Frame", {
    Position = UDim2.fromOffset(4, 4), Size = UDim2.new(1, -8, 1, -8),
    BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(103, 104, 105), ZIndex = 81
  }, frame)
  local face = rf.create("Frame", {
    Position = UDim2.fromOffset(3, 3), Size = UDim2.new(1, -6, 1, -6),
    BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(31, 31, 33), ZIndex = 82
  }, rim)
  rf.create("Frame", {Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = Color3.fromRGB(74, 74, 77),
    BorderSizePixel = 0, ZIndex = 83}, face)
  rf.create("Frame", {Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(1, 0, 0, 2),
    BackgroundColor3 = Color3.fromRGB(13, 13, 15), BorderSizePixel = 0, ZIndex = 83}, face)
  local portraitsize = math.min(50, height - 22)
  local portrait = rf.create("Frame", {
    Position = UDim2.fromOffset(9, math.floor((height - 14 - portraitsize) / 2)),
    Size = UDim2.fromOffset(portraitsize, portraitsize),
    BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 84
  }, face)
  local iconpadding = math.floor(portraitsize * 0.18)
  local icon = rf.iconimage(portrait, iconname or "swords", tint or Color3.fromRGB(255, 223, 80),
    UDim2.fromOffset(iconpadding, iconpadding),
    UDim2.fromOffset(portraitsize - iconpadding * 2, portraitsize - iconpadding * 2), 85)
  if type(picture) == "string" and picture ~= "" then
    rf.create("ImageLabel", {
      Position = UDim2.fromScale(0, 0), Size = UDim2.fromScale(1, 1),
      BackgroundTransparency = 1, BorderSizePixel = 0, ImageTransparency = 0,
      ImageColor3 = Color3.new(1, 1, 1), Image = picture,
      ScaleType = Enum.ScaleType.Fit, ZIndex = 86
    }, portrait)
  end
  local left = portraitsize + 23
  local available = math.max(130, width - left - 23)
  local titlefont = 15
  local detailfont = 14
  rf.create("TextLabel", {
    Position = UDim2.fromOffset(left, 9), Size = UDim2.new(1, -left - 17, 0, titleheight),
    BorderSizePixel = 0, BackgroundTransparency = 1, Text = reason, Font = Enum.Font.Arcade,
    TextSize = titlefont, TextColor3 = Color3.fromRGB(255, 232, 53), TextWrapped = true,
    TextTruncate = Enum.TextTruncate.None, TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 85
  }, face)
  rf.create("TextLabel", {
    Position = UDim2.fromOffset(left, 13 + titleheight), Size = UDim2.new(1, -left - 17, 0, detailheight),
    BorderSizePixel = 0, BackgroundTransparency = 1, Text = detail, Font = Enum.Font.Arcade,
    TextSize = detailfont, TextColor3 = Color3.fromRGB(244, 245, 248), TextWrapped = true,
    TextTruncate = Enum.TextTruncate.None, TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 85
  }, face)
  if id and config.notificationheadshots then
    rf.spawn(function()
      local ok, content, ready
      for attempt = 1, 4 do
        ok, content, ready = pcall(function()
          return players:GetUserThumbnailAsync(id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        end)
        if ok and ready and type(content) == "string" and content ~= "" then break end
        if not state.alive or not entry.frame or not entry.frame.Parent then return end
        task.wait(attempt * 0.2)
      end
      if ok and ready and type(content) == "string" and content ~= "" and state.alive
        and entry.frame and entry.frame.Parent and config.notificationheadshots then
        rf.create("ImageLabel", {
          Position = UDim2.fromScale(0, 0), Size = UDim2.fromScale(1, 1),
          BackgroundTransparency = 1, BorderSizePixel = 0, ImageTransparency = 0,
          ImageColor3 = Color3.new(1, 1, 1), Image = content,
          ScaleType = Enum.ScaleType.Fit, ZIndex = 86
        }, portrait)
        icon.Visible = false
      end
    end)
  end
  state.feed[#state.feed + 1] = entry
  local limit = math.clamp(math.floor(tonumber(config.notificationlimit) or 4), 1, 6)
  while #state.feed > limit do rf.removenotice(state.feed[1]) end
  rf.layoutnotices()
  rf.delay(duration, function()
    if state.alive then rf.removenotice(entry) end
  end)
end

rf.resources.noticerate = {times = {}, pending = {}, scheduled = false, sequence = 0}
state.noticerate = rf.resources.noticerate

function rf.noticedrain()
  if not state.alive or not config.notifications then
    table.clear(rf.resources.noticerate.pending)
    rf.resources.noticerate.scheduled = false
    return
  end
  local now = os.clock()
  while #rf.resources.noticerate.times > 0 and now - rf.resources.noticerate.times[1] >= 3 do
    table.remove(rf.resources.noticerate.times, 1)
  end
  while #rf.resources.noticerate.times < 4 and #rf.resources.noticerate.pending > 0 do
    local item = table.remove(rf.resources.noticerate.pending, 1)
    if os.clock() - item.queuedat > 9 and item.priority < 3 then continue end
    now = os.clock()
    if not state.feedlast[item.key] or now - state.feedlast[item.key] >= 1.35 then
      rf.resources.noticerate.times[#rf.resources.noticerate.times + 1] = now
      rf.notificationrender(table.unpack(item.args, 1, 7))
    end
  end
  if #rf.resources.noticerate.pending == 0 then
    rf.resources.noticerate.scheduled = false
    return
  end
  local oldest = rf.resources.noticerate.times[1] or os.clock()
  rf.delay(math.max(0.03, oldest + 3.02 - os.clock()), rf.noticedrain)
end

function rf.notification(reason, detail, user, iconname, tint, key, picture)
  if not state.alive or not config.notifications or not rf.resources.noticeholder or not rf.resources.noticeholder.Parent then return end
  local identity = tostring(key or rf.compacttext(reason) .. ":" .. rf.compacttext(detail))
  local now = os.clock()
  if state.feedlast[identity] and now - state.feedlast[identity] < 1.35 then return end
  for _, item in ipairs(rf.resources.noticerate.pending) do
    if item.key == identity then return end
  end
  local priority = identity:sub(1, 13) == "vanta:toggle:"
  local critical = reason == "Anti Void" or reason == "Next map"
    or tostring(reason):lower():find("unavailable", 1, true) ~= nil
    or tostring(reason):lower():find("error", 1, true) ~= nil
  local rank = critical and 3 or priority and 2 or 1
  if #rf.resources.noticerate.pending >= 24 then
    local lowest, index = rank, nil
    for position, pending in ipairs(rf.resources.noticerate.pending) do
      if pending.priority < lowest then
        lowest, index = pending.priority, position
      end
    end
    if not index then return end
    table.remove(rf.resources.noticerate.pending, index)
  end
  local entry = {key = identity, priority = rank, queuedat = now,
    args = {reason, detail, user, iconname, tint, identity, picture}}
  local index = #rf.resources.noticerate.pending + 1
  for position, waiting in ipairs(rf.resources.noticerate.pending) do
    if waiting.priority < rank then index = position break end
  end
  table.insert(rf.resources.noticerate.pending, index, entry)
  if not rf.resources.noticerate.scheduled then
    rf.resources.noticerate.scheduled = true
    rf.noticedrain()
  end
end

function rf.killnotice(message, tint, key)
  if not config.killnotices then return end
  rf.notification("Combat update", message, nil, "swords", tint, key)
end

function rf.drawnotices()
  if not config.notifications then
    while #state.feed > 0 do rf.removenotice(state.feed[1]) end
  end
end

rf.resources.destroyskeleton = function() end

function rf.destroyvisual(id)
  local visual = state.visuals[id]
  if not visual then return end
  if visual.highlight then visual.highlight:Destroy() end
  if visual.drawing and rf.removedrawingesp then rf.removedrawingesp(visual) end
  if visual.tag then visual.tag:Destroy() end
  if visual.skeleton then rf.resources.destroyskeleton(visual.skeleton) end
  state.visuals[id] = nil
end

function rf.clearvisuals()
  for id in pairs(state.visuals) do
    rf.destroyvisual(id)
  end
end

function rf.isgunname(name)
  name = string.lower(name)
  return name:find("gun", 1, true) or name:find("revolver", 1, true) or name:find("pistol", 1, true) or name:find("laser", 1, true)
end

function rf.isknifename(name)
  name = string.lower(name)
  return name:find("knife", 1, true) or name:find("dagger", 1, true) or name:find("blade", 1, true)
end

function rf.getweapon()
  local character = localplayer.Character
  if not character then return nil, nil end
  local gun, knife
  for _, item in ipairs(character:GetChildren()) do
    if item:IsA("Tool") then
      if rf.isknifename(item.Name) then
        knife = item
      elseif rf.isgunname(item.Name) or item:FindFirstChild("Muzzle", true) then
        gun = item
      end
    end
  end
  if gun then return gun, "gun" end
  if knife then return knife, "knife" end
  return nil, nil
end

local function visible(character, point, origin, targetpart)
  local direction = point - origin
  if direction.Magnitude < 0.001 then return true end
  local ignored = {}
  if localplayer.Character then
    ignored[#ignored + 1] = localplayer.Character
  end
  for _, object in ipairs(collectionservice:GetTagged("WeaponPassthrough")) do
    ignored[#ignored + 1] = object
  end
  local params = RaycastParams.new()
  params.FilterType = Enum.RaycastFilterType.Exclude
  params.IgnoreWater = true
  for _ = 1, 24 do
    params.FilterDescendantsInstances = ignored
    local hit = world:Raycast(origin, direction, params)
    if not hit then return true end
    if hit.Instance:IsDescendantOf(character) then
      if not targetpart or hit.Instance == targetpart then return true end
      local accessory = hit.Instance:FindFirstAncestorOfClass("Accessory")
      if accessory and accessory:IsDescendantOf(character) then
        ignored[#ignored + 1] = hit.Instance
      else
        return false
      end
    elseif hit.Instance:IsA("BasePart") and hit.Instance.Transparency >= 1 then
      ignored[#ignored + 1] = hit.Instance
    else
      return false
    end
  end
  return false
end

function rf.horizontal(vector)
  return Vector3.new(vector.X, 0, vector.Z)
end

function rf.capped(vector, maximum)
  local length = vector.Magnitude
  return length > maximum and vector * (maximum / length) or vector
end

function rf.updatemotion()
  local now = os.clock()
  local active = {}
  for _, p in ipairs(players:GetPlayers()) do
    if p ~= localplayer then
      local character = p.Character
      local root = character and character:FindFirstChild("HumanoidRootPart")
      local humanoid = character and character:FindFirstChildOfClass("Humanoid")
      if root and root:IsA("BasePart") and humanoid and humanoid.Health > 0 then
        active[p.UserId] = true
        local previous = state.motion[p.UserId]
        local raw = rf.capped(root.AssemblyLinearVelocity, 100)
        local velocity = raw
        local acceleration = Vector3.zero
        local observed = raw
        local stable = false
        if previous and previous.root == root then
          local dt = now - previous.time
          if dt >= 0.008 and dt <= 0.25 then
            local change = root.Position - previous.position
            if change.Magnitude <= math.max(6, dt * 110) then
              observed = rf.capped(change / dt, 100)
              local mix = math.clamp(dt * 38, 0.58, 0.88)
              local combined = observed:Lerp(raw, 0.18)
              local reversal = previous.velocity.Magnitude > 3 and combined.Magnitude > 3
                and combined:Dot(previous.velocity) < -previous.velocity.Magnitude * combined.Magnitude * 0.25
              velocity = reversal and combined or previous.velocity:Lerp(combined, mix)
              local wanted = rf.capped((velocity - previous.velocity) / dt, 110)
              acceleration = previous.acceleration:Lerp(wanted, 0.42)
              if observed.Magnitude < 1 and raw.Magnitude < 1.5 then
                velocity, acceleration = Vector3.zero, Vector3.zero
              end
              stable = true
            end
          end
        end
        state.motion[p.UserId] = {
          root = root, position = root.Position, time = now, velocity = velocity,
          acceleration = acceleration, observed = observed, stable = stable,
          direction = rf.horizontal(humanoid.MoveDirection)
        }
      end
    end
  end
  for id in pairs(state.motion) do
    if not active[id] then state.motion[id] = nil end
  end
end

function rf.combatmovementlead(p, humanoid, root, distance)
  return Vector3.zero
end

function rf.closegunrange(character)
  local own = localplayer.Character
  local ownroot = own and own:FindFirstChild("HumanoidRootPart")
  local targetroot = character and character:FindFirstChild("HumanoidRootPart")
  return ownroot ~= nil and targetroot ~= nil
    and (ownroot.Position - targetroot.Position).Magnitude <= 10
end

function rf.closegunvertical(humanoid, root)
  if not humanoid or not root or humanoid.FloorMaterial ~= Enum.Material.Air then return Vector3.zero end
  local velocity = root.AssemblyLinearVelocity.Y
  if math.abs(velocity) < 1 then return Vector3.zero end
  return Vector3.new(0, math.clamp(velocity * 0.018, -0.22, 0.28), 0)
end

function rf.predictgun(p, humanoid, root, position, distance)
  return position
end

rf.resources.gunparts = {
  "Head", "UpperTorso", "Torso", "LowerTorso", "HumanoidRootPart",
  "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",
  "LeftHand", "RightHand", "LeftUpperLeg", "RightUpperLeg",
  "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot",
  "Left Arm", "Right Arm", "Left Leg", "Right Leg"
}
rf.resources.knifeparts = {"UpperTorso", "Torso", "LowerTorso", "HumanoidRootPart", "Head", "LeftUpperArm", "RightUpperArm"}
rf.resources.autoshootdefaultparts = {"UpperTorso", "Torso", "LowerTorso", "LeftUpperLeg", "RightUpperLeg", "Left Leg", "Right Leg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot"}
rf.resources.selectedhitpartnames = {
  Head = {"Head"},
  Torso = {"UpperTorso", "Torso", "LowerTorso"},
  ["Left Arm"] = {"Left Arm", "LeftUpperArm", "LeftLowerArm", "LeftHand"},
  ["Right Arm"] = {"Right Arm", "RightUpperArm", "RightLowerArm", "RightHand"},
  ["Left Leg"] = {"Left Leg", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot"},
  ["Right Leg"] = {"Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot"}
}

rf.resources.closegunparts = {"UpperTorso", "Torso", "LowerTorso"}

function rf.closegunpart(character)
  if not character then return nil end
  for _, name in ipairs(rf.resources.closegunparts) do
    local part = character:FindFirstChild(name)
    if part and part:IsA("BasePart") and part.Transparency < 1 then return part end
  end
  return nil
end

function rf.selectedhitparts(defaultparts, character)
  local selected = config.autoshoothitpart
  if selected ~= "Auto" then
    return rf.resources.selectedhitpartnames[selected] or defaultparts or rf.resources.autoshootdefaultparts
  end
  if character and rf.closegunrange(character) then return rf.resources.closegunparts end
  return defaultparts or rf.resources.autoshootdefaultparts
end

function rf.matcheshitpart(part, character)
  if not part then return false end
  local names = rf.selectedhitparts(nil, character)
  return not names or table.find(names, part.Name) ~= nil
end

function rf.selectedhitvisible(character, part, origin)
  if not part or not rf.matcheshitpart(part, character) then return false end
  local strict = rf.closegunrange(character) or config.autoshoothitpart ~= "Auto"
  return visible(character, part.Position, origin, strict and part or nil)
end

function rf.movementvector(p, humanoid, root)
  local history = state.motion[p.UserId]
  local velocity = history and history.root == root and history.velocity or rf.horizontal(root.AssemblyLinearVelocity)
  local intent = rf.horizontal(humanoid.MoveDirection)
  if intent.Magnitude > 0.1 then
    local expected = intent.Unit * math.max(humanoid.WalkSpeed * 0.7, velocity.Magnitude)
    velocity = velocity:Lerp(expected, 0.27)
  end
  return velocity
end

function rf.leadingedge(part, direction)
  if direction.Magnitude < 0.01 then return part.Position end
  local localdirection = part.CFrame:VectorToObjectSpace(direction.Unit)
  local factor = math.clamp(tonumber(config.gunedgebias) or 0.24, 0, 0.4)
  local size = part.Size * factor
  local offset = Vector3.new(localdirection.X * size.X, localdirection.Y * size.Y, localdirection.Z * size.Z)
  return part.CFrame:PointToWorldSpace(offset)
end

function rf.targetpoint()
  if not state.alive or not flags.aim then return nil end
  local weapon, kind = rf.getweapon()
  local camera = world.CurrentCamera
  if not weapon or not camera then return nil end
  local origin = camera.CFrame.Position
  local mouse = userinputservice:GetMouseLocation()
  local scripts = localplayer:FindFirstChild("PlayerScripts")
  local lock = scripts and scripts:FindFirstChild("MouseLock")
  local center = lock and lock:GetAttribute("Enabled") == true and userinputservice.PreferredInput ~= Enum.PreferredInput.Gamepad
    and camera.ViewportSize * 0.5 or mouse
  local cursor = Vector2.new(center.X, center.Y)
  local radius = tonumber(kind == "knife" and config.knifescreenradius or config.screenradius) or math.huge
  local maximum = tonumber(kind == "knife" and config.knifedistance or config.maxdistance) or 300
  local close = tonumber(config.closeaimdistance) or 18
  local handle = weapon:FindFirstChild("Handle", true)
  local muzzle = handle and handle:IsA("BasePart") and handle.Position or origin
  local bestpoint, bestscore, bestid, bestpart
  local now = os.clock()
  local previous = state.aimtarget

  for _, p in ipairs(players:GetPlayers()) do
    if p ~= localplayer then
      local record = rf.getrecord(p)
      local role = record and record.Role or "Innocent"
      local eligible = kind == "gun" and role == "Murderer" or kind == "knife" and role ~= "Murderer"
      local character = p.Character
      local humanoid = character and character:FindFirstChildOfClass("Humanoid")
      local root = character and character:FindFirstChild("HumanoidRootPart")
      if eligible and root and humanoid and humanoid.Health > 0 and not (record and record.Dead == true) then
        local distance = (root.Position - muzzle).Magnitude
        if distance <= maximum then
          local closegun = kind == "gun" and rf.closegunrange(character)
          local parts = rf.resources.closegunparts
          local nearby = distance <= close
          local motion = rf.movementvector(p, humanoid, root)
          local speed = motion.Magnitude
          local moving = false
          local direction = moving and motion.Unit or Vector3.zero
          local weights = moving and math.clamp(speed / 16, 0.35, 1.8) or 0
          for _, name in ipairs(parts) do
            local part = character:FindFirstChild(name)
            if part and part:IsA("BasePart") then
              local base = part.Position
              if visible(character, base, origin, part) and visible(character, base, muzzle, part) then
                local point = base
                if not visible(character, point, muzzle) then point = base end
                local projected, onscreen = camera:WorldToViewportPoint(point)
                local delta = point - origin
                local forward = delta.Magnitude > 0.001 and camera.CFrame.LookVector:Dot(delta.Unit) or 1
                local permitted = projected.Z > 0 and (onscreen or nearby and forward >= (tonumber(config.closeaimfov) or 0.12))
                if permitted then
                  local screen = Vector2.new(projected.X, projected.Y)
                  local distance2d = (screen - cursor).Magnitude
                  if distance2d <= radius or nearby then
                    local distance3d = (base - muzzle).Magnitude
                    local tracker = state.tracking[p.UserId]
                    local trackedcenter = config.r6tracking and tracker and tracker.center or root.Position
                    local leading = 0
                    local score = distance3d * 0.7 + distance2d * (moving and 0.3 or 0.55)
                    
                    if nearby then score = score - 12 end
                    if previous and previous.id == p.UserId and previous.kind == kind
                      and previous.weapon == weapon and now - previous.time < 0.4 then
                      score -= previous.part == part.Name and 26 or 12
                    end
                    if not bestscore or score < bestscore then
                      bestpoint, bestscore, bestid, bestpart = point, score, p.UserId, part.Name
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  if not bestpoint then
    state.aimtarget = nil
    return nil
  end
  local point = bestpoint
  state.aimtarget = {
    id = bestid, kind = kind, weapon = weapon, part = bestpart,
    point = point, time = now
  }
  return point
end

rf.resources.skeletonpoints = {
  head = {"Head"},
  neck = {"UpperTorso", "NeckRigAttachment"},
  waist = {"UpperTorso", "WaistRigAttachment"},
  pelvis = {"LowerTorso"},
  leftshoulder = {"UpperTorso", "LeftShoulderRigAttachment"},
  rightshoulder = {"UpperTorso", "RightShoulderRigAttachment"},
  leftelbow = {"LeftUpperArm", "LeftElbowRigAttachment"},
  rightelbow = {"RightUpperArm", "RightElbowRigAttachment"},
  leftwrist = {"LeftLowerArm", "LeftWristRigAttachment"},
  rightwrist = {"RightLowerArm", "RightWristRigAttachment"},
  lefthand = {"LeftHand"},
  righthand = {"RightHand"},
  lefthip = {"LowerTorso", "LeftHipRigAttachment"},
  righthip = {"LowerTorso", "RightHipRigAttachment"},
  leftknee = {"LeftUpperLeg", "LeftKneeRigAttachment"},
  rightknee = {"RightUpperLeg", "RightKneeRigAttachment"},
  leftankle = {"LeftLowerLeg", "LeftAnkleRigAttachment"},
  rightankle = {"RightLowerLeg", "RightAnkleRigAttachment"},
  leftfoot = {"LeftFoot"},
  rightfoot = {"RightFoot"}
}

rf.resources.skeletonsegments = {
  {"head", "neck"}, {"neck", "waist"}, {"leftshoulder", "rightshoulder"},
  {"leftshoulder", "leftelbow"}, {"leftelbow", "leftwrist"}, {"leftwrist", "lefthand"},
  {"rightshoulder", "rightelbow"}, {"rightelbow", "rightwrist"}, {"rightwrist", "righthand"},
  {"waist", "pelvis"}, {"lefthip", "righthip"}, {"pelvis", "lefthip"}, {"pelvis", "righthip"},
  {"lefthip", "leftknee"}, {"leftknee", "leftankle"}, {"leftankle", "leftfoot"},
  {"righthip", "rightknee"}, {"rightknee", "rightankle"}, {"rightankle", "rightfoot"}
}

function rf.skeletonpoint(character, definition)
  local part = character:FindFirstChild(definition[1])
  if not part or not part:IsA("BasePart") then return nil end
  local joint = definition[2] and part:FindFirstChild(definition[2])
  if joint and joint:IsA("Attachment") then return joint.WorldPosition end
  return part.Position
end

rf.resources.r6skeletonpoints = {
  head = {"Head", Vector3.zero}, neck = {"Torso", Vector3.new(0, 1, 0)},
  waist = {"Torso", Vector3.new(0, -0.85, 0)},
  leftshoulder = {"Torso", Vector3.new(-0.95, 0.85, 0)},
  rightshoulder = {"Torso", Vector3.new(0.95, 0.85, 0)},
  leftelbow = {"Left Arm", Vector3.zero}, rightelbow = {"Right Arm", Vector3.zero},
  leftwrist = {"Left Arm", Vector3.new(0, -0.9, 0)},
  rightwrist = {"Right Arm", Vector3.new(0, -0.9, 0)},
  lefthip = {"Torso", Vector3.new(-0.5, -0.9, 0)},
  righthip = {"Torso", Vector3.new(0.5, -0.9, 0)},
  leftknee = {"Left Leg", Vector3.zero}, rightknee = {"Right Leg", Vector3.zero},
  leftankle = {"Left Leg", Vector3.new(0, -0.95, 0)},
  rightankle = {"Right Leg", Vector3.new(0, -0.95, 0)}
}
rf.resources.r6skeletonsegments = {
  {"head", "neck"}, {"neck", "waist"}, {"leftshoulder", "rightshoulder"},
  {"leftshoulder", "leftelbow"}, {"leftelbow", "leftwrist"},
  {"rightshoulder", "rightelbow"}, {"rightelbow", "rightwrist"},
  {"waist", "lefthip"}, {"waist", "righthip"},
  {"lefthip", "leftknee"}, {"leftknee", "leftankle"},
  {"righthip", "rightknee"}, {"rightknee", "rightankle"}
}
function rf.r6skeletonpoint(model, definition)
  local part = model and model:FindFirstChild(definition[1])
  if not part or not part:IsA("BasePart") then return nil end
  return part.CFrame:PointToWorldSpace(definition[2])
end
function rf.skeletonstyle(character, id)
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  if not humanoid then return "r6" end
  if humanoid.RigType == Enum.HumanoidRigType.R6 then return "r6" end
  local tracker = state.tracking[id]
  if config.r6tracking and tracker and tracker.small then return "r6" end
  return "r15"
end
function rf.makeskeleton(character, id)
  local humanoid = character:FindFirstChildOfClass("Humanoid")
  if not humanoid then return nil end
  local style = rf.skeletonstyle(character, id)
  local holder = rf.create("Frame", {
    Name = "VantaSkeleton_" .. character.Name, BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1), ZIndex = 5, Active = false
  }, overlay)
  local skeleton = {mode = "screen", style = style, character = character, holder = holder, lines = {}}
  for _, pair in ipairs(style == "r6" and rf.resources.r6skeletonsegments or rf.resources.skeletonsegments) do
    local shadow = rf.create("Frame", {
      Name = "Shadow", BackgroundColor3 = Color3.fromRGB(4, 7, 13),
      BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Visible = false, ZIndex = 5
    }, holder)
    local foreground = rf.create("Frame", {
      Name = "Bone", BackgroundColor3 = Color3.fromRGB(255, 255, 255),
      BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Visible = false, ZIndex = 6
    }, holder)
    skeleton.lines[#skeleton.lines + 1] = {a = pair[1], b = pair[2], foreground = foreground, shadow = shadow}
  end
  return skeleton
end

rf.resources.destroyskeleton = function(skeleton)
  if skeleton.holder then skeleton.holder:Destroy() end
end

function rf.screenline(part, a, b, thickness)
  local delta = b - a
  local distance = delta.Magnitude
  if distance < 1 then
    part.Visible = false
    return
  end
  local midpoint = (a + b) * 0.5
  part.Position = UDim2.fromOffset(midpoint.X, midpoint.Y)
  part.Size = UDim2.fromOffset(distance, thickness)
  part.Rotation = math.deg(math.atan2(delta.Y, delta.X))
  part.Visible = true
end

function rf.renderskeletons()
  if not state.alive then return end
  local now = os.clock()
  if now - state.lastrender < rf.adaptiveinterval(math.max(1 / 90, tonumber(config.skeletonrefresh) or 1 / 45), 1 / 24, 1 / 12) then return end
  state.lastrender = now
  local camera = world.CurrentCamera
  if not camera then return end
  local origin = camera.CFrame.Position
  local viewport = camera.ViewportSize
  for _, visual in pairs(state.visuals) do
    local skeleton = visual.skeleton
    if skeleton then
      local root = visual.character:FindFirstChild("HumanoidRootPart")
      local allowed = flags.chams and flags.skeleton and config.skeleton and root
        and (root.Position - origin).Magnitude <= config.skeletondistance
      local projected = allowed and {} or nil
      if allowed then
        local tracker = state.tracking[visual.id]
        local source = config.r6tracking and tracker and tracker.model or visual.character
        local definitions = skeleton.style == "r6" and rf.resources.r6skeletonpoints or rf.resources.skeletonpoints
        for name, definition in pairs(definitions) do
          local position = skeleton.style == "r6" and rf.r6skeletonpoint(source, definition)
            or rf.skeletonpoint(visual.character, definition)
          if position then
            local screen = camera:WorldToViewportPoint(position)
            if screen.Z > 0 and screen.X > -25 and screen.Y > -25
              and screen.X < viewport.X + 25 and screen.Y < viewport.Y + 25 then
              projected[name] = Vector2.new(screen.X, screen.Y)
            end
          end
        end
      end
      local tint = colors[visual.role] or colors.Innocent
      local weight = math.clamp(tonumber(config.skeletonwidth) or 1.7, 1, 5)
      for _, segment in ipairs(skeleton.lines) do
        local a, b = projected and projected[segment.a], projected and projected[segment.b]
        local shown = a ~= nil and b ~= nil
        if shown then
          segment.foreground.BackgroundColor3 = tint
          segment.foreground.BackgroundTransparency = 1 - math.clamp(tonumber(config.skeletontransparency) or 0.98, 0, 1)
          rf.screenline(segment.foreground, a, b, weight)
          if config.skeletonoutline then
            segment.shadow.BackgroundTransparency = 0.17
            rf.screenline(segment.shadow, a, b, weight + 2)
          else
            segment.shadow.Visible = false
          end
        else
          segment.foreground.Visible = false
          segment.shadow.Visible = false
        end
      end
    end
  end
  if state.markerui then
    local marker = state.markerui
    local position = state.gunmarkerposition
    if state.gunmarkerkind == "dropped" and state.droppart
      and state.droppart:IsDescendantOf(world) and state.dropproof
      and state.dropproof:IsDescendantOf(world) then
      position = state.droppart.Position
      state.gunmarkerposition = position
    end
    local enabled = config.gunmarker and flags.chams and typeof(position) == "Vector3"
    if enabled then
      local projected = camera:WorldToViewportPoint(position + Vector3.new(0, 1.4, 0))
      enabled = projected.Z > 0 and projected.X > 0 and projected.X < viewport.X
        and projected.Y > 0 and projected.Y < viewport.Y
      if enabled then
        marker.holder.Position = UDim2.fromOffset(projected.X, projected.Y)
      end
    end
    marker.holder.Visible = not not enabled
  end
end

rf.resources.drawingapi = (type(Drawing) == "table" or type(Drawing) == "userdata") and Drawing
  or (type(env.Drawing) == "table" or type(env.Drawing) == "userdata") and env.Drawing or nil
rf.resources.drawingverified = nil
rf.resources.drawingoverlay = nil
rf.resources.drawingfailure = nil

function rf.drawingnativeavailable()
  if rf.resources.drawingverified ~= nil then return rf.resources.drawingverified end
  rf.resources.drawingverified = false
  if not rf.resources.drawingapi or type(rf.resources.drawingapi.new) ~= "function" then return false end
  local objects = {}
  local ok, reason = pcall(function()
    for _, kind in ipairs({"Square", "Line"}) do
      local object = rf.resources.drawingapi.new(kind)
      assert(object, "Missing " .. kind .. " renderer")
      objects[#objects + 1] = object
      object.Visible = false
      object.Color = Color3.new(1, 1, 1)
      object.Transparency = 1
      object.Thickness = 2
      if kind == "Square" then
        object.Position = Vector2.zero
        object.Size = Vector2.new(10, 10)
        object.Filled = false
      else
        object.From = Vector2.zero
        object.To = Vector2.new(10, 10)
      end
      assert(type(object.Remove) == "function" or type(object.Destroy) == "function", "Missing cleanup")
    end
  end)
  for _, object in ipairs(objects) do
    pcall(function()
      object.Visible = false
      if type(object.Remove) == "function" then object:Remove() else object:Destroy() end
    end)
  end
  rf.resources.drawingverified = ok
  if not ok then rf.resources.drawingfailure = tostring(reason) end
  return ok
end

function rf.drawingoverlay()
  if rf.resources.drawingoverlay and rf.resources.drawingoverlay.Parent then return rf.resources.drawingoverlay end
  local ok, screen = pcall(function()
    local parent = coregui
    local root = rf.create("ScreenGui", {
      Name = "VantaDrawingTopLayer", ResetOnSpawn = false, IgnoreGuiInset = true,
      ZIndexBehavior = Enum.ZIndexBehavior.Global, DisplayOrder = 1000000,
      Enabled = true
    }, parent)
    return root
  end)
  if not ok or not screen then
    ok, screen = pcall(function()
      return rf.create("ScreenGui", {
        Name = "VantaDrawingTopLayer", ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Global, DisplayOrder = 1000000,
        Enabled = true
      }, rf.resources.playergui)
    end)
  end
  if ok then rf.resources.drawingoverlay = screen end
  return rf.resources.drawingoverlay
end

function rf.drawingavailable()
  return rf.drawingnativeavailable() or rf.drawingoverlay() ~= nil
end

function rf.removedrawingesp(visual)
  if not visual or not visual.drawing then return end
  local drawing = visual.drawing
  if drawing.kind == "native" then
    for _, object in ipairs(drawing.objects or {}) do
      pcall(function()
        object.Visible = false
        if type(object.Remove) == "function" then object:Remove()
        elseif type(object.Destroy) == "function" then object:Destroy() end
      end)
    end
  elseif drawing.kind == "gui" and drawing.holder then
    pcall(function() drawing.holder:Destroy() end)
  end
  visual.drawing = nil
end

function rf.createdrawingesp(visual, forcegui)
  if not visual or visual.drawing then return end
  if not forcegui and rf.drawingnativeavailable() then
    local created = {kind = "native", objects = {}, corners = {}}
    local ok = pcall(function()
      for _, kind in ipairs({"fill", "shadow", "outline", "inner"}) do
        local object = rf.resources.drawingapi.new("Square")
        assert(object)
        created[kind] = object
        created.objects[#created.objects + 1] = object
        object.Visible = false
        object.Filled = kind == "fill"
        object.Thickness = kind == "shadow" and 5 or kind == "outline" and 2 or 1
        object.Transparency = 1
        object.Color = kind == "shadow" and Color3.fromRGB(5, 8, 14)
          or kind == "inner" and Color3.fromRGB(252, 253, 255) or Color3.new(1, 1, 1)
        object.Position = Vector2.new(0, 0)
        object.Size = Vector2.new(12, 24)
        pcall(function() object.ZIndex = kind == "fill" and 9990
          or kind == "shadow" and 9991 or kind == "outline" and 9992 or 9993 end)
      end
      for i = 1, 8 do
        local line = rf.resources.drawingapi.new("Line")
        assert(line, "Missing corner line")
        if line then
          created.corners[i] = line
          created.objects[#created.objects + 1] = line
          line.Visible = false
          line.Thickness = 2
          line.Transparency = 1
          line.Color = Color3.new(1, 1, 1)
          line.From = Vector2.zero
          line.To = Vector2.zero
          pcall(function() line.ZIndex = 9994 end)
        end
      end
    end)
    if ok then
      visual.drawing = created
      return
    end
    rf.removedrawingesp({drawing = created})
    rf.resources.drawingverified = false
    rf.resources.drawingfailure = "Native Drawing creation failed; using GUI fallback"
  end
  local screen = rf.drawingoverlay()
  if not screen then return end
  local created
  local ok = pcall(function()
    local holder = rf.create("Frame", {
      Name = "PlayerOutline", BackgroundTransparency = 1,
      BorderSizePixel = 0, Active = false, Visible = false,
      Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(12, 24), ZIndex = 1500
    }, screen)
    created = {kind = "gui", holder = holder, corners = {}}
    local shadow = rf.create("Frame", {
      BackgroundTransparency = 1, BorderSizePixel = 0, Active = false,
      Position = UDim2.fromOffset(-2, -2), Size = UDim2.new(1, 4, 1, 4), ZIndex = 1500
    }, holder)
    rf.create("UIStroke", {Color = Color3.fromRGB(4, 7, 13), Thickness = 4, Transparency = 0}, shadow)
    local fill = rf.create("Frame", {
      BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.93,
      BorderSizePixel = 0, Active = false, Size = UDim2.fromScale(1, 1), ZIndex = 1501
    }, holder)
    local outline = rf.create("Frame", {
      BackgroundTransparency = 1, BorderSizePixel = 0, Active = false,
      Size = UDim2.fromScale(1, 1), ZIndex = 1502
    }, holder)
    local stroke = rf.create("UIStroke", {Color = Color3.new(1, 1, 1), Thickness = 2, Transparency = 0}, outline)
    local inner = rf.create("Frame", {
      BackgroundTransparency = 1, BorderSizePixel = 0, Active = false,
      Position = UDim2.fromOffset(2, 2), Size = UDim2.new(1, -4, 1, -4), ZIndex = 1503
    }, holder)
    rf.create("UIStroke", {Color = Color3.fromRGB(245, 247, 255), Thickness = 1, Transparency = 0.58}, inner)
    for i = 1, 8 do
      created.corners[i] = rf.create("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
        BackgroundTransparency = 0, Active = false, ZIndex = 1504,
        Size = UDim2.fromOffset(3, 3)
      }, holder)
    end
    created.fill = fill
    created.stroke = stroke
    created.shadowstroke = shadow:FindFirstChildOfClass("UIStroke")
    created.innerstroke = inner:FindFirstChildOfClass("UIStroke")
  end)
  if ok then
    visual.drawing = created
  elseif created and created.holder then
    pcall(function() created.holder:Destroy() end)
  end
end

function rf.hidedrawingesp(visual)
  if not visual or not visual.drawing then return end
  local drawing = visual.drawing
  if drawing.kind == "native" then
    for _, object in ipairs(drawing.objects) do
      pcall(function() object.Visible = false end)
    end
  elseif drawing.holder then
    drawing.holder.Visible = false
  end
end

function rf.drawingbounds(camera, character, root, humanoid)
  local viewport = camera.ViewportSize
  local minx, miny, maxx, maxy = math.huge, math.huge, -math.huge, -math.huge
  local validpoints = 0
  local okay, boxframe, boxsize = pcall(character.GetBoundingBox, character)
  if okay and boxframe and boxsize and boxsize.X <= 8 and boxsize.Y <= 13 and boxsize.Z <= 8 then
    local behind = false
    for x = -1, 1, 2 do
      for y = -1, 1, 2 do
        for z = -1, 1, 2 do
          local point = boxframe:PointToWorldSpace(Vector3.new(x * boxsize.X * 0.5, y * boxsize.Y * 0.5, z * boxsize.Z * 0.5))
          local projected = camera:WorldToViewportPoint(point)
          if projected.Z <= 0.05 then behind = true end
          if projected.Z > 0.05 then
            validpoints += 1
            minx = math.min(minx, projected.X)
            miny = math.min(miny, projected.Y)
            maxx = math.max(maxx, projected.X)
            maxy = math.max(maxy, projected.Y)
          end
        end
      end
    end
    if behind then validpoints = 0 end
  end
  if validpoints < 4 or maxy - miny < 8 or maxx - minx < 4 then
    local head = character:FindFirstChild("Head")
    local top = head and head:IsA("BasePart") and head.Position + Vector3.new(0, head.Size.Y * 0.62 + 0.15, 0)
      or root.Position + Vector3.new(0, 2.5, 0)
    local bottom = root.Position - Vector3.new(0, math.max(2.5, humanoid.HipHeight + 0.8), 0)
    local projectedtop = camera:WorldToViewportPoint(top)
    local projectedbottom = camera:WorldToViewportPoint(bottom)
    if projectedtop.Z <= 0.05 or projectedbottom.Z <= 0.05 then return nil end
    local height = math.max(12, math.abs(projectedbottom.Y - projectedtop.Y))
    local width = math.max(9, height * 0.54)
    local center = (projectedtop.X + projectedbottom.X) * 0.5
    minx, maxx = center - width * 0.5, center + width * 0.5
    miny, maxy = math.min(projectedtop.Y, projectedbottom.Y), math.max(projectedtop.Y, projectedbottom.Y)
  end
  if maxx < -12 or minx > viewport.X + 12 or maxy < -12 or miny > viewport.Y + 12 then return nil end
  local width, height = maxx - minx, maxy - miny
  if width < 4 or height < 8 or width > viewport.X * 4 or height > viewport.Y * 4 then return nil end
  if width > height * 0.95 then
    local center = (minx + maxx) * 0.5
    width = height * 0.95
    minx = center - width * 0.5
  end
  return math.floor(minx + 0.5), math.floor(miny + 0.5),
    math.floor(width + 0.5), math.floor(height + 0.5)
end

function rf.drawingstyle(visual, width, height)
  local tint = colors[visual.role] or colors.Innocent
  local opacity = 1 - math.clamp(visual.role == "Innocent" and config.innocentfill
    or config.filltransparency, 0, 1)
  return tint, math.clamp(opacity * 0.24, 0.03, 0.13),
    math.clamp(math.min(width, height) * 0.24, 6, 16)
end

function rf.updatedrawingesp(visual, x, y, width, height)
  local drawn = visual.drawing
  local tint, fillopacity, length = rf.drawingstyle(visual, width, height)
  local white = Color3.fromRGB(251, 251, 255)
  if drawn.kind == "native" then
    local position = Vector2.new(x, y)
    local size = Vector2.new(width, height)
    drawn.fill.Position = position
    drawn.fill.Size = size
    drawn.fill.Color = tint
    drawn.fill.Transparency = fillopacity
    drawn.fill.Visible = not config.outlineonly
    drawn.shadow.Position = position
    drawn.shadow.Size = size
    drawn.shadow.Color = Color3.fromRGB(5, 8, 13)
    drawn.shadow.Thickness = config.outlineglow and 6 or 4
    drawn.shadow.Visible = true
    drawn.outline.Position = position
    drawn.outline.Size = size
    drawn.outline.Color = tint
    drawn.outline.Thickness = 2
    drawn.outline.Visible = true
    drawn.inner.Position = position + Vector2.new(2, 2)
    drawn.inner.Size = size - Vector2.new(4, 4)
    drawn.inner.Color = white
    drawn.inner.Transparency = 0.42
    drawn.inner.Visible = width > 14 and height > 24
    local points = drawn.corners
    for i = 1, 8 do
      local ax, ay, bx, by
      if i == 1 then ax, ay, bx, by = x, y, x + length, y
      elseif i == 2 then ax, ay, bx, by = x, y, x, y + length
      elseif i == 3 then ax, ay, bx, by = x + width, y, x + width - length, y
      elseif i == 4 then ax, ay, bx, by = x + width, y, x + width, y + length
      elseif i == 5 then ax, ay, bx, by = x, y + height, x + length, y + height
      elseif i == 6 then ax, ay, bx, by = x, y + height, x, y + height - length
      elseif i == 7 then ax, ay, bx, by = x + width, y + height, x + width - length, y + height
      else ax, ay, bx, by = x + width, y + height, x + width, y + height - length end
      local line = points[i]
      line.From = Vector2.new(ax, ay)
      line.To = Vector2.new(bx, by)
      line.Color = white
      line.Thickness = 2
      line.Visible = true
    end
  else
    drawn.holder.Position = UDim2.fromOffset(x, y)
    drawn.holder.Size = UDim2.fromOffset(width, height)
    drawn.fill.BackgroundColor3 = tint
    drawn.fill.BackgroundTransparency = config.outlineonly and 1 or 1 - fillopacity
    drawn.stroke.Color = tint
    if drawn.shadowstroke then drawn.shadowstroke.Thickness = config.outlineglow and 6 or 4 end
    if drawn.innerstroke then drawn.innerstroke.Transparency = 0.58 end
    for i = 1, 8 do
      local px, py, sx, sy
      if i == 1 then px, py, sx, sy = 0, 0, length, 2
      elseif i == 2 then px, py, sx, sy = 0, 0, 2, length
      elseif i == 3 then px, py, sx, sy = width - length, 0, length, 2
      elseif i == 4 then px, py, sx, sy = width - 2, 0, 2, length
      elseif i == 5 then px, py, sx, sy = 0, height - 2, length, 2
      elseif i == 6 then px, py, sx, sy = 0, height - length, 2, length
      elseif i == 7 then px, py, sx, sy = width - length, height - 2, length, 2
      else px, py, sx, sy = width - 2, height - length, 2, length end
      local corner = drawn.corners[i]
      corner.Position = UDim2.fromOffset(px, py)
      corner.Size = UDim2.fromOffset(sx, sy)
      corner.BackgroundColor3 = white
    end
    drawn.holder.Visible = true
  end
end

function rf.renderdrawingesp()
  if not state.alive then return end
  if config.espmode ~= "Drawing" or not flags.chams or not state.round then
    for _, visual in pairs(state.visuals) do rf.hidedrawingesp(visual) end
    return
  end
  local now = os.clock()
  if now - (state.lastdrawingrender or 0) < rf.adaptiveinterval(1 / 60, 1 / 45, 1 / 30) then return end
  state.lastdrawingrender = now
  local camera = world.CurrentCamera
  if not camera then
    for _, visual in pairs(state.visuals) do rf.hidedrawingesp(visual) end
    return
  end
  local origin = camera.CFrame.Position
  local params
  if not config.throughwalls then
    params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = localplayer.Character and {localplayer.Character} or {}
  end
  for _, visual in pairs(state.visuals) do
    if not visual.drawing then rf.createdrawingesp(visual) end
    local character = visual.character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local visible = visual.drawing ~= nil and root ~= nil and humanoid ~= nil
      and humanoid.Health > 0 and character.Parent ~= nil
    if visible and (root.Position - origin).Magnitude > (tonumber(config.maxdistance) or 300) then
      visible = false
    end
    if visible and params then
      local head = character:FindFirstChild("Head")
      local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
      local unobstructed = false
      for index = 1, 3 do
        local part = index == 1 and head or index == 2 and torso or root
        if part and part:IsA("BasePart") then
          local hit = world:Raycast(origin, part.Position - origin, params)
          if not hit or hit.Instance:IsDescendantOf(character) then
            unobstructed = true
            break
          end
        end
      end
      visible = unobstructed
    end
    local x, y, width, height
    if visible then
      x, y, width, height = rf.drawingbounds(camera, character, root, humanoid)
      if not x then visible = false end
    end
    if visible then
      local ok = pcall(rf.updatedrawingesp, visual, x, y, width, height)
      if not ok then
        rf.hidedrawingesp(visual)
        if visual.drawing and visual.drawing.kind == "native" then
          rf.resources.drawingverified = false
          rf.resources.drawingfailure = "Native renderer failed during drawing update"
          rf.removedrawingesp(visual)
          rf.createdrawingesp(visual, true)
          if visual.drawing then pcall(rf.updatedrawingesp, visual, x, y, width, height) end
        end
      end
    else
      rf.hidedrawingesp(visual)
    end
  end
end

function rf.newvisual(p, character, role, inferred)
  local tint = colors[role] or colors.Innocent
  local innocent = role == "Innocent"
  local highlight = rf.create("Highlight", {
    Name = "VantaHighlight", Adornee = character, FillColor = tint, OutlineColor = tint,
    FillTransparency = config.outlineonly and 1 or innocent and config.innocentfill or config.filltransparency,
    OutlineTransparency = innocent and config.innocentoutline or config.outlinetransparency,
    DepthMode = config.throughwalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded,
    Enabled = config.espmode == "Highlight"
  }, character)
  local head = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
  local tag, name, detail
  if head then
    tag = rf.create("BillboardGui", {
      Name = "VantaTag", Adornee = head, Size = UDim2.fromOffset(240, 40),
      StudsOffsetWorldSpace = Vector3.new(0, 2.15, 0), AlwaysOnTop = true,
      MaxDistance = config.tagdistance, ResetOnSpawn = false,
      Enabled = config.showtags and (not innocent or config.showinnocentlabels)
    }, character)
    name = rf.create("TextLabel", {
      Size = UDim2.fromOffset(240, 19), Position = UDim2.fromOffset(0, 0), BackgroundTransparency = 1, Text = rf.compacttext(p.Name),
      TextColor3 = Color3.fromRGB(248, 250, 254), TextStrokeColor3 = Color3.fromRGB(4, 6, 9),
      TextStrokeTransparency = 0.1, Font = Enum.Font.GothamMedium,
      TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center,
      TextTruncate = Enum.TextTruncate.None, TextWrapped = false, TextScaled = true
    }, tag)
    detail = rf.create("TextLabel", {
      Position = UDim2.fromOffset(0, 18), Size = UDim2.fromOffset(240, 17), BackgroundTransparency = 1, Text = role,
      TextColor3 = tint, TextStrokeColor3 = Color3.fromRGB(4, 6, 9),
      TextStrokeTransparency = 0.07, Font = Enum.Font.GothamMedium,
      TextSize = 10, TextXAlignment = Enum.TextXAlignment.Center,
      TextTruncate = Enum.TextTruncate.None, TextWrapped = false, TextScaled = true
    }, tag)
  end
  state.visuals[p.UserId] = {
    id = p.UserId, character = character, role = role, inferred = inferred,
    highlight = highlight, tag = tag, name = name, detail = detail,
    skeleton = flags.skeleton and config.skeleton and rf.makeskeleton(character, p.UserId) or nil
  }
  if config.espmode == "Drawing" then rf.createdrawingesp(state.visuals[p.UserId]) end
end

function rf.refreshvisuals()
  if not state.alive then return end
  if config.espmode == "Drawing" and not rf.drawingavailable() then
    config.espmode = "Highlight"
    rf.notification("ESP renderer", "Drawing.new is unavailable; using Highlight", nil,
      "alert-triangle", Color3.fromRGB(255, 184, 100), "esp:drawing:unavailable")
    savepreferences()
  end
  local present = {}
  for _, p in ipairs(players:GetPlayers()) do
    if p ~= localplayer then
      present[p.UserId] = true
      local record = rf.getrecord(p)
      local role = record and record.Role or "Innocent"
      local character = p.Character
      local humanoid = character and character:FindFirstChildOfClass("Humanoid")
      local valid = state.round and flags.chams and (role ~= "Innocent" or config.showinnocents)
        and role ~= "Neutral" and not (record and record.Dead == true)
        and character and humanoid and humanoid.Health > 0
      local inferred = not record or record.source ~= "fade"
      local existing = state.visuals[p.UserId]
      if not valid or (existing and (existing.character ~= character or existing.role ~= role or existing.inferred ~= inferred or not existing.highlight.Parent)) then
        rf.destroyvisual(p.UserId)
        existing = nil
      end
      if valid then
        if not existing then
          rf.newvisual(p, character, role, inferred)
          existing = state.visuals[p.UserId]
        end
        if existing then
          local tint = colors[role] or colors.Innocent
          local innocent = role == "Innocent"
          existing.highlight.Enabled = config.espmode == "Highlight"
          if config.espmode == "Drawing" then
            if not existing.drawing then rf.createdrawingesp(existing) end
          elseif existing.drawing then
            rf.removedrawingesp(existing)
          end
          existing.highlight.FillColor = tint
          existing.highlight.OutlineColor = tint
          existing.highlight.FillTransparency = config.outlineonly and 1 or innocent and config.innocentfill or config.filltransparency
          existing.highlight.OutlineTransparency = innocent and config.innocentoutline or config.outlinetransparency
          existing.highlight.DepthMode = config.throughwalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
          if existing.tag then
            existing.tag.Enabled = config.showtags and (not innocent or config.showinnocentlabels)
            existing.tag.MaxDistance = config.tagdistance
          end
          if not flags.skeleton or not config.skeleton then
            if existing.skeleton then rf.resources.destroyskeleton(existing.skeleton) existing.skeleton = nil end
          else
            local wantedstyle = rf.skeletonstyle(character, p.UserId)
            if existing.skeleton and existing.skeleton.style ~= wantedstyle then
              rf.resources.destroyskeleton(existing.skeleton)
              existing.skeleton = nil
            end
            if not existing.skeleton then existing.skeleton = rf.makeskeleton(character, p.UserId) end
          end
          if existing.name then existing.name.Text = rf.compacttext(p.Name) end
          if existing.detail then
            local root = character:FindFirstChild("HumanoidRootPart")
            local localroot = localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
            local distance = root and localroot and math.floor((root.Position - localroot.Position).Magnitude + 0.5)
            local roletext = role == "GunCarrier" and "GUN HOLDER" or string.upper(role)
            local source = record and record.source
            local estimated = not record or source == "assumed" or source == "weapon" or source == "unarmed"
            local suffix = estimated and role ~= "Innocent" and " / EST" or ""
            existing.detail.Text = rf.compacttext(roletext .. suffix .. (distance and "  /  " .. distance .. " studs" or ""))
            existing.detail.TextColor3 = tint
          end
        end
      end
    end
  end
  for id in pairs(state.visuals) do
    if not present[id] then rf.destroyvisual(id) end
  end
  if config.espmode ~= "Drawing" and rf.resources.drawingoverlay and rf.resources.drawingoverlay.Parent then
    rf.resources.drawingoverlay:Destroy()
    rf.resources.drawingoverlay = nil
  end
end

function rf.normalize_role(value)
  if type(value) ~= "string" then return nil end
  local role = value:lower():gsub("%s+", "")
  if role == "murderer" or role == "murder" then return "Murderer" end
  if role == "sheriff" then return "Sheriff" end
  if role == "hero" then return "Hero" end
  if role == "innocent" then return "Innocent" end
  if role == "neutral" then return "Neutral" end
  return nil
end

function rf.readrole(container)
  if not container then return nil end
  for _, key in ipairs({"Role", "CurrentRole", "RoundRole", "GameRole"}) do
    local role = rf.normalize_role(container:GetAttribute(key))
    if role then return role end
    local child = container:FindFirstChild(key)
    if child and child:IsA("StringValue") then
      role = rf.normalize_role(child.Value)
      if role then return role end
    end
  end
  return nil
end

function rf.replicatedrole(p)
  local candidates = {p}
  for _, item in ipairs({"Data", "PlayerData", "Stats"}) do
    local node = p:FindFirstChild(item)
    if node then candidates[#candidates + 1] = node end
  end
  if p.Character then candidates[#candidates + 1] = p.Character end
  for _, item in ipairs(candidates) do
    local role = rf.readrole(item)
    if role then return role end
  end
  for _, name in ipairs({"PlayerData", "PlayerRoles", "RoleData", "RoundData", "GameState"}) do
    local root = replicatedstorage:FindFirstChild(name) or gameplay:FindFirstChild(name)
    if root then
      local node = root:FindFirstChild(p.Name) or root:FindFirstChild(tostring(p.UserId))
      local role = rf.readrole(node)
      if not role and node and node:IsA("StringValue") then
        role = rf.normalize_role(node.Value)
      end
      if role then return role end
    end
  end
  return nil
end

function rf.equippedrole(p)
  local roots = {}
  if p.Character then roots[#roots + 1] = p.Character end
  if config.checkbackpack then
    local backpack = p:FindFirstChildOfClass("Backpack")
    if backpack then roots[#roots + 1] = backpack end
  end
  local gun, knife = false, false
  for _, root in ipairs(roots) do
    for _, object in ipairs(root:GetChildren()) do
      if object:IsA("Tool") then
        if rf.isknifename(object.Name) then knife = true end
        if rf.isgunname(object.Name) then gun = true end
      end
    end
  end
  if knife then return "Murderer" end
  if gun then return "Sheriff" end
  return nil
end

function rf.getrootposition(p)
  local character = p.Character
  local root = character and character:FindFirstChild("HumanoidRootPart")
  if root and root:IsA("BasePart") then return root.Position end
  return nil
end

function rf.holderalive(p)
  if not p or (state.synced and not state.participants[p.UserId]) then return false end
  local data = state.authoritative[p.UserId]
  if data and data.Dead == true then return false end
  local character = p.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  return not humanoid or humanoid.Health > 0
end

function rf.guncarrier()
  local roster = players:GetPlayers()
  for _, p in ipairs(roster) do
    local character = p.Character
    if character and rf.holderalive(p) then
      for _, object in ipairs(character:GetChildren()) do
        if object:IsA("Tool") and rf.isgunname(object.Name) then return p end
      end
    end
  end
  if config.checkbackpack then
    for _, p in ipairs(roster) do
      if rf.holderalive(p) then
        local backpack = p:FindFirstChildOfClass("Backpack")
        if backpack then
          for _, object in ipairs(backpack:GetChildren()) do
            if object:IsA("Tool") and rf.isgunname(object.Name) then return p end
          end
        end
      end
    end
  end
  return nil
end

function rf.mapbounds(root)
  if not root or not root:IsA("Model") or not root:IsDescendantOf(world) then return nil end
  local ok, cf, size = pcall(root.GetBoundingBox, root)
  if not ok or typeof(cf) ~= "CFrame" or typeof(size) ~= "Vector3" then return nil end
  if size.X < 10 or size.Z < 10 then return nil end
  return cf, size
end

function rf.withinbounds(position, cf, size, margin)
  if typeof(position) ~= "Vector3" or typeof(cf) ~= "CFrame" or typeof(size) ~= "Vector3" then return false end
  local delta = cf:PointToObjectSpace(position)
  return math.abs(delta.X) <= size.X * 0.5 + margin
    and math.abs(delta.Y) <= size.Y * 0.5 + math.max(65, margin)
    and math.abs(delta.Z) <= size.Z * 0.5 + margin
end

function rf.setmap(root, spawn)
  local cf, size = rf.mapbounds(root)
  if not cf then return false end
  if state.maproot ~= root then
    state.lastgun, state.lastsheriff, state.gunhistory = nil, {}, {}
    state.dropposition, state.dropinstance, state.droppart, state.dropattachment, state.dropproof = nil, nil, nil, nil, nil
    state.pickupdropkey, state.pickupdropreadyat = nil, 0
    state.nextdropscan = 0
    state.gunlossrecords = {}
    state.gundroplinks = setmetatable({}, {__mode = "k"})
  end
  state.maproot, state.mapcf, state.mapsize = root, cf, size
  if typeof(spawn) == "Vector3" then state.mapspawn = spawn end
  if rf.nextmapconfirmed then rf.nextmapconfirmed(root) end
  local safe = state.voidsafe
  if safe then
    if safe.maproot ~= root then
      safe.maproot = root
      safe.mapframe = nil
      safe.pending = nil
      safe.round = state.roundstartedat
      safe.checkpoint = nil
      safe.checkpointmap = nil
      safe.checkpointround = nil
    end
    if typeof(spawn) == "Vector3" and not root.Name:lower():find("lobby", 1, true)
      and not safe.mapframe then
      safe.mapframe = CFrame.new(spawn + Vector3.new(0, 4, 0))
    end
  end
  return true
end

function rf.mapfromspawn(instance)
  if typeof(instance) ~= "Instance" or not instance:IsA("BasePart") then return false end
  if not instance:IsDescendantOf(world) then return false end
  local parent = instance.Parent
  while parent and parent ~= world do
    if parent.Name:lower() == "spawns" then
      local candidate = parent.Parent
      if candidate and candidate ~= world and rf.setmap(candidate, instance.Position) then return true end
    end
    parent = parent.Parent
  end
  local candidate = instance
  while candidate.Parent and candidate.Parent ~= world do candidate = candidate.Parent end
  return rf.setmap(candidate, instance.Position)
end

function rf.findactivemap()
  if state.maproot and state.maproot:IsDescendantOf(world) and state.mapcf then return true end
  if not state.round or os.clock() < state.nextmaptry then return false end
  state.nextmaptry = os.clock() + math.max(0.5, tonumber(config.mapdetectioninterval) or 2)
  local positions = {}
  for id, data in pairs(state.authoritative) do
    if data.Dead ~= true and data.Killed ~= true
      and (data.Role == "Sheriff" or data.Role == "Hero" or data.Role == "Murderer") then
      local p = players:GetPlayerByUserId(id)
      if p and rf.holderalive(p) then
        local position = rf.getrootposition(p)
        if position then positions[#positions + 1] = position end
      end
    end
  end
  if #positions == 0 then return false end
  local best, score, spawnposition
  for _, candidate in ipairs(world:GetChildren()) do
    if candidate:IsA("Model") and candidate:FindFirstChild("Spawns") then
      local cf, size = rf.mapbounds(candidate)
      if cf then
        local spawns = candidate:FindFirstChild("Spawns")
        local spawn = spawns and spawns:FindFirstChildWhichIsA("BasePart", true)
        for _, position in ipairs(positions) do
          if rf.withinbounds(position, cf, size, tonumber(config.gunmapmargin) or 42) then
            local distance = spawn and (position - spawn.Position).Magnitude or (position - cf.Position).Magnitude
            if not score or distance < score then
              best, score, spawnposition = candidate, distance, spawn and spawn.Position or nil
            end
          end
        end
      end
    end
  end
  return best and rf.setmap(best, spawnposition) or false
end

function rf.inactivemap(position)
  if not state.maproot or not state.mapcf then return false end
  if not state.maproot:IsDescendantOf(world) then return false end
  return rf.withinbounds(position, state.mapcf, state.mapsize, tonumber(config.gunmapmargin) or 42)
end

function rf.capturegunposition(p)
  if not p or not rf.holderalive(p) then return false end
  local position = rf.getrootposition(p)
  if not position or not rf.inactivemap(position) then return false end
  local id, now = p.UserId, os.clock()
  state.lastsheriff[id] = position
  state.gunhistory[id] = {position = position, userId = id, timestamp = now}
  if id == state.gunroleowner or id == state.gunholder
    or not state.gunroleowner and id == state.originalsheriff then
    state.lastgun = {position = position, userId = id, timestamp = now}
  end
  return true
end

function rf.trackassignedgun()
  if not state.round or state.endlock or not rf.findactivemap() then return end
  local current, original = state.gunroleowner, state.originalsheriff
  for id, data in pairs(state.authoritative) do
    if data.Dead ~= true and data.Killed ~= true
      and (data.Role == "Sheriff" or data.Role == "Hero") then
      local p = players:GetPlayerByUserId(id)
      if p then rf.capturegunposition(p) end
    end
  end
  if current then
    local p = players:GetPlayerByUserId(current)
    if p then rf.capturegunposition(p) end
  end
  if original and original ~= current then
    local p = players:GetPlayerByUserId(original)
    if p and rf.holderalive(p) then rf.capturegunposition(p) end
  end
end

function rf.knownherocarrier()
  if not config.gunownershiptracking then return nil end
  for id, data in pairs(state.authoritative) do
    if data.Role == "Hero" and data.Dead ~= true and data.Killed ~= true then
      local p = players:GetPlayerByUserId(id)
      if p and rf.holderalive(p) then return p end
    end
  end
  return nil
end

function rf.remembergun()
  if not state.alive or not state.round or state.endlock then return end
  local toolholder = rf.guncarrier()
  local heroholder = rf.knownherocarrier()
  local dropped = not toolholder and rf.droppedgunposition()
  local holder = toolholder or (not dropped and heroholder or nil)
  if holder and (not state.synced or state.participants[holder.UserId]) then
    if state.gunownershipid ~= holder.UserId then
      local wasdropped = state.gunmarkerkind == "dropped" or state.dropinstance ~= nil
      state.gunownershipid = holder.UserId
      if wasdropped then
        rf.notification("Gun collected", holder.Name, holder.UserId, "shield", colors.Hero, "gun-owner:" .. holder.UserId)
      end
    end
    state.gunownershipsource = toolholder and "equipped tool" or "confirmed hero"
    state.gunholder, state.gunroleowner = holder.UserId, holder.UserId
    state.dropposition, state.dropinstance, state.droppart, state.dropattachment, state.dropproof = nil, nil, nil, nil, nil
    state.pickupdropkey, state.pickupdropreadyat = nil, 0
    state.gunmarkerposition, state.gunmarkerkind = nil, nil
    state.gunlossrecords = {}
    state.gundroplinks = setmetatable({}, {__mode = "k"})
    if state.gunmarker then
      state.gunmarker.holder:Destroy()
      state.gunmarker = nil
      state.markerui = nil
    end
    if state.pickuprestore then state.pickuprestore(true) end
    state.pickupretryat, state.pickupretrytarget, state.pickupfailures = 0, nil, 0
  else
    state.gunholder = nil
    state.gunownershipid, state.gunownershipsource = nil, nil
  end
  rf.trackassignedgun()
  if holder then rf.capturegunposition(holder) end
  if state.gunholder then return end
  local lastid = state.gunroleowner or state.originalsheriff
  local saved = lastid and state.gunhistory[lastid] or nil
  if not saved and state.originalsheriff then saved = state.gunhistory[state.originalsheriff] end
  if saved and rf.inactivemap(saved.position) then
    if not state.lastgun or state.lastgun.userId ~= saved.userId
      or state.lastgun.timestamp < saved.timestamp then
      state.lastgun = table.clone(saved)
    end
  end
end

function rf.dropbasepart(object)
  if object:IsA("BasePart") then return object end
  if object:IsA("Attachment") then
    local parent = object.Parent
    if parent and parent:IsA("BasePart") then return parent end
    local ancestor = object:FindFirstAncestorWhichIsA("BasePart")
    if ancestor then return ancestor end
    object = parent
    if not object then return nil end
  end
  if object:IsA("Tool") or object:IsA("Model") then
    local handle = object:FindFirstChild("Handle", true)
    if handle and handle:IsA("BasePart") then return handle end
    if object:IsA("Model") and object.PrimaryPart then return object.PrimaryPart end
    return object:FindFirstChildWhichIsA("BasePart", true)
  end
  return nil
end

function rf.fuzzyname(name, expected, tolerance)
  local a = name:lower():gsub("[^%w]", "")
  local b = expected:lower():gsub("[^%w]", "")
  if a == b then return true end
  if math.abs(#a - #b) > tolerance then return false end
  local previous = {}
  for j = 0, #b do previous[j] = j end
  for i = 1, #a do
    local current = {[0] = i}
    for j = 1, #b do
      current[j] = math.min(current[j - 1] + 1, previous[j] + 1,
        previous[j - 1] + (a:sub(i, i) == b:sub(j, j) and 0 or 1))
    end
    previous = current
  end
  return previous[#b] <= tolerance
end

function rf.fuzzygunroot(object)
  if not object:IsA("Attachment") then return nil end
  local root = object.Parent
  if not root or not root:IsA("BasePart") or not rf.fuzzyname(root.Name, "HumanoidRootPart", 2) then return nil end
  local name = object.Name
  if not (rf.fuzzyname(name, "GunRaycastAttachment", 2) or rf.fuzzyname(name, "GunRaycastAttachment1", 2)) then return nil end
  return root
end

function rf.recordgunloss(p, character)
  if not state.alive or not state.round or state.endlock or not p then return false end
  local id = p.UserId
  local known = state.authoritative[id] or rf.getrecord(p)
  local role = known and rf.normalize_role(known.Role)
  local associated = id == state.gunholder or id == state.gunroleowner
    or id == state.gunownershipid or id == state.originalsheriff
    or role == "Sheriff" or role == "Hero"
  if not associated then
    for _, container in ipairs({character, p:FindFirstChildOfClass("Backpack")}) do
      if container then
        for _, item in ipairs(container:GetChildren()) do
          if item:IsA("Tool") and (rf.isgunname(item.Name) or item:FindFirstChild("Muzzle", true)) then
            associated = true
            break
          end
        end
      end
    end
  end
  if not associated then return false end
  local root = character and character:FindFirstChild("HumanoidRootPart")
  local saved = state.gunhistory[id]
  local position = root and root:IsA("BasePart") and root.Position
    or saved and saved.position
  if typeof(position) ~= "Vector3" or state.mapcf and not rf.inactivemap(position) then return false end
  local now = os.clock()
  local record = {userId = id, position = position, timestamp = now,
    round = state.roundstartedat, maproot = state.maproot}
  state.gunlossrecords[id] = record
  state.gunhistory[id] = {position = position, userId = id, timestamp = now}
  state.lastgun = table.clone(state.gunhistory[id])
  if character then state.departedguncharacters[character] = true end
  state.dropdirty = true
  state.nextdropscan = 0
  state.raggyrescanat = 0
  return true
end

function rf.gundropanchor(position)
  if typeof(position) ~= "Vector3" or state.mapcf and not rf.inactivemap(position) then return nil end
  if rf.guncarrier() then return nil end
  local now = os.clock()
  local bestgap, bestrecord
  for id, record in pairs(state.gunlossrecords) do
    local age = now - record.timestamp
    if record.round == state.roundstartedat and record.maproot == state.maproot
      and age >= -0.5 and age <= 24 then
      local holder = players:GetPlayerByUserId(id)
      local living = holder and rf.holderalive(holder)
      if not living then
        local gap = (position - record.position).Magnitude
        if gap <= 18 and (not bestgap or gap < bestgap) then
          bestgap, bestrecord = gap, record
        end
      end
    else
      state.gunlossrecords[id] = nil
    end
  end
  return bestgap, bestrecord
end

function rf.raggyroot(object)
  if typeof(object) ~= "Instance" then return nil end
  local current = object
  while current and current ~= world do
    if current:IsA("Model") and current.Name:lower() == "raggy" then
      local container = current.Parent
      if not container or not container:IsA("Model")
        or state.maproot and container ~= state.maproot
        or not state.maproot and container.Parent ~= world then return nil end
      local root = current:FindFirstChild("HumanoidRootPart")
      if root and root:IsA("BasePart") and root:IsDescendantOf(world) then return root end
      return nil
    end
    current = current.Parent
  end
  return nil
end

function rf.gunattachment(object)
  if not (object:IsA("Attachment") or object:IsA("BasePart")) then return nil end
  local root = rf.fuzzygunroot(object)
  local name = object.Name:lower()
  if not root and name ~= "gunraycastattachment1" and name ~= "gunraycastattachment" then return nil end
  local part = root or rf.dropbasepart(object)
  if not part or not part:IsDescendantOf(world) then return nil end
  local parent, associated = part, root ~= nil or object:IsA("BasePart")
  while parent and parent ~= world do
    local pname = parent.Name:lower()
    if rf.isgunname(pname) or pname:find("drop", 1, true) then associated = true end
    parent = parent.Parent
  end
  if not associated then return nil end
  local position = object:IsA("Attachment") and object.WorldPosition or part.Position
  return part, position
end

function rf.isheldobject(object)
  local current = object
  while current and current ~= world do
    if current:IsA("Model") then
      if players:GetPlayerFromCharacter(current) then return true end
      if state.departedguncharacters[current] and current:FindFirstChildOfClass("Humanoid")
        and current:FindFirstChildWhichIsA("Tool") then return true end
    end
    current = current.Parent
  end
  return current ~= world
end

function rf.realgunmodel(object)
  if not (object:IsA("Model") or object:IsA("Tool")) then return nil end
  local name = object.Name:lower():gsub("[^%w]", "")
  if name:find("raycast", 1, true) or name:find("beam", 1, true)
    or name:find("marker", 1, true) or name:find("effect", 1, true)
    or name:find("projectile", 1, true) then return nil end
  if not (name:find("gun", 1, true) or name:find("revolver", 1, true)
    or name:find("pistol", 1, true) or name:find("laser", 1, true)) then return nil end
  local part = object:FindFirstChildWhichIsA("BasePart", true)
  if not part or not part:IsDescendantOf(world) then return nil end
  return part
end

function rf.isgunraycastmarker(object)
  if typeof(object) ~= "Instance" or not object:IsDescendantOf(world) then return false end
  local name = object.Name:lower():gsub("[^%w]", "")
  return name:find("gunraycast", 1, true) ~= nil
end

function rf.referencegundrop(object)
  if typeof(object) ~= "Instance" or not object:IsDescendantOf(world) then return nil end
  local marker
  if rf.isgunraycastmarker(object) then
    marker = object
  else
    local root = rf.raggyroot(object)
    if root and root.Parent then
      for _, candidate in ipairs(root.Parent:GetDescendants()) do
        if rf.isgunraycastmarker(candidate) then
          marker = candidate
          break
        end
      end
    end
  end
  if not marker then return nil end
  local current = marker.Parent
  while current and current ~= world do
    if current:IsA("Tool") then return nil end
    if current:IsA("Model") then
      local root = current:FindFirstChild("HumanoidRootPart")
      if root and root:IsA("BasePart") and root:IsDescendantOf(world)
        and not current:FindFirstAncestorOfClass("Tool") then
        local raggy = rf.raggyroot(root)
        if (raggy == root or state.departedguncharacters[current]) and not rf.isheldobject(root) then
          local part = marker:IsA("Attachment") and marker.Parent or marker
          if not part or not part:IsA("BasePart") or not part:IsDescendantOf(current) then part = root end
          if state.mapcf and not rf.inactivemap(part.Position) then return nil end
          return part, part.Position, marker
        end
      end
    end
    current = current.Parent
  end
  return nil
end

function rf.verifiedgundrop(object)
  if typeof(object) ~= "Instance" or not object:IsDescendantOf(world)
    or rf.isheldobject(object) or rf.guncarrier() then return nil end
  local raggy = rf.raggyroot(object)
  if raggy then
    if rf.isheldobject(raggy) or state.mapcf and not rf.inactivemap(raggy.Position) then return nil end
    for _, model in ipairs(raggy.Parent:GetDescendants()) do
      local gunpart = rf.realgunmodel(model)
      if gunpart and not rf.isheldobject(model) then
        return gunpart, gunpart.Position, model
      end
    end
    local referencepart, referenceposition, referencemarker = rf.referencegundrop(object)
    if referencepart then return referencepart, referenceposition, referencemarker end
    local link = state.gundroplinks[raggy]
    if not link or link.round ~= state.roundstartedat or link.maproot ~= state.maproot then
      local _, record = rf.gundropanchor(raggy.Position)
      if not record then return nil end
      link = {userId = record.userId, round = state.roundstartedat, maproot = state.maproot}
      state.gundroplinks[raggy] = link
    end
    return raggy, raggy.Position, raggy
  end
  local referencepart, referenceposition, referencemarker = rf.referencegundrop(object)
  if referencepart then return referencepart, referenceposition, referencemarker end
  local current = object
  while current and current ~= world do
    if current:IsA("BasePart") and not rf.isheldobject(current) then
      local name = current.Name:lower():gsub("[^%w]", "")
      if (name == "gundrop" or name == "droppedgun" or name == "gundropped")
        and finitevector(current.Position) and (not state.mapcf or rf.inactivemap(current.Position)) then
        return current, current.Position, current
      end
    end
    local gunpart = rf.realgunmodel(current)
    if gunpart and not rf.isheldobject(current) then
      local name = current.Name:lower():gsub("[^%w]", "")
      local dropped = current:IsA("Tool") and current.Parent == world
        or name:find("drop", 1, true) ~= nil
      if dropped then return gunpart, gunpart.Position, current end
    end
    current = current.Parent
  end
  return nil
end

function rf.validgundrop(source, part, proof)
  if not source or not part or not proof or not source.Parent or not proof.Parent
    or not part:IsDescendantOf(world) or not proof:IsDescendantOf(world) then return false end
  local resolved, _, verified = rf.verifiedgundrop(source)
  return resolved == part and verified == proof
end

function rf.dropstrength(object)
  local part, _, proof = rf.verifiedgundrop(object)
  if not part or not proof then return 0 end
  return rf.raggyroot(object) and 18 or 10
end

function rf.adddropcandidate(instance)
  if typeof(instance) ~= "Instance" then return end
  if rf.isgunraycastmarker(instance) then state.dropmarkers[instance] = true end
  local current = instance
  while current and current ~= world do
    if (current:IsA("Attachment") or current:IsA("BasePart")
      or current:IsA("Model") or current:IsA("Tool"))
      and rf.dropstrength(current) > 0 then
      if not state.dropcandidates[current] then state.dropcandidates[current] = true end
      state.dropdirty = true
      state.nextdropscan = 0
      return true
    end
    current = current.Parent
  end
  return false
end

function rf.rescanraggygundrops()
  local found = false
  local function visit(container)
    if not container:IsA("Model") then return end
    local raggy = container:FindFirstChild("Raggy")
    local root = raggy and raggy:IsA("Model") and raggy:FindFirstChild("HumanoidRootPart")
    if root and root:IsA("BasePart") and rf.gundropanchor(root.Position)
      and rf.adddropcandidate(root) then found = true end
  end
  if state.maproot and state.maproot:IsDescendantOf(world) then
    visit(state.maproot)
  else
    for _, container in ipairs(world:GetChildren()) do visit(container) end
  end
  return found
end

function rf.rescanexistinggundrops(refreshworld)
  if not state.alive or not state.round or state.endlock then return false end
  if refreshworld then
    local objects = world:GetDescendants()
    for _, object in ipairs(objects) do
      if rf.isgunraycastmarker(object) then
        state.dropmarkers[object] = true
      elseif (object:IsA("Model") or object:IsA("Tool") or object:IsA("BasePart"))
        and (rf.isgunname(object.Name) or object.Name == "Raggy" or object.Name:lower():find("gundrop", 1, true)) then
        rf.adddropcandidate(object)
      end
    end
  end
  local found = rf.rescanraggygundrops()
  for marker in pairs(state.dropmarkers) do
    if marker:IsDescendantOf(world) then
      if rf.dropstrength(marker) > 0 then
        rf.adddropcandidate(marker)
        found = true
      end
    else
      state.dropmarkers[marker] = nil
    end
  end
  if found then
    state.dropdirty = true
    state.nextdropscan = 0
  end
  return found
end

function rf.droppedgunposition(skipscan)
  local character = localplayer.Character
  local localroot = character and character:FindFirstChild("HumanoidRootPart")
  local preferred = localroot and localroot.Position
  local selectedposition, selected, selectedpart, selectedproof, nearest, beststrength
  for instance in pairs(state.dropcandidates) do
    local part, position, proof = rf.verifiedgundrop(instance)
    if not part or not proof then
      state.dropcandidates[instance] = nil
    elseif not state.mapcf or rf.inactivemap(position) or rf.isgunraycastmarker(proof) then
      local distance = preferred and (position - preferred).Magnitude or 0
      local anchor = rf.raggyroot(instance) and rf.gundropanchor(position)
      local strength = rf.isgunraycastmarker(proof) and 40 or proof ~= part and 30 or 20
      if anchor then
        strength = strength + math.max(0, 10 - anchor * 0.5)
        distance = anchor
      end
      if not beststrength or strength > beststrength or strength == beststrength and distance < nearest then
        beststrength, nearest = strength, distance
        selectedposition, selected, selectedpart, selectedproof = position, instance, part, proof
      end
    end
  end
  if not selectedpart and not skipscan and os.clock() >= (state.raggyrescanat or 0) then
    state.raggyrescanat = os.clock() + 0.15
    if rf.rescanraggygundrops() then return rf.droppedgunposition(true) end
  end
  return selectedposition, selected, selectedpart, nil, selectedproof
end

function rf.haslocalgun()
  local character = localplayer.Character
  local backpack = localplayer:FindFirstChildOfClass("Backpack")
  for _, container in ipairs({character, backpack}) do
    if container then
      for _, object in ipairs(container:GetChildren()) do
        if object:IsA("Tool") and (rf.isgunname(object.Name) or object:FindFirstChild("Muzzle", true)) then
          return true
        end
      end
    end
  end
  return false
end

function rf.localismurderer()
  if rf.equippedrole(localplayer) == "Murderer" then return true end
  if not state.round then return false end
  local assigned = state.authoritative[localplayer.UserId]
  if assigned and rf.normalize_role(assigned.Role) == "Murderer" then return true end
  local record = rf.getrecord(localplayer)
  if record and rf.normalize_role(record.Role) == "Murderer" then return true end
  return rf.replicatedrole(localplayer) == "Murderer"
end

function rf.localisdead()
  local character = localplayer.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  if not character or not humanoid or humanoid.Health <= 0 then return true end
  local authoritative = state.authoritative[localplayer.UserId]
  local recorded = rf.getrecord(localplayer)
  for _, data in ipairs({authoritative or {}, recorded or {}}) do
    if data.Dead == true or data.Killed == true then return true end
  end
  for _, object in ipairs({localplayer, character}) do
    for _, name in ipairs({"Dead", "Killed"}) do
      if object:GetAttribute(name) == true then return true end
      local value = object:FindFirstChild(name)
      if value and value:IsA("BoolValue") and value.Value then return true end
    end
  end
  return false
end

function rf.localisinround()
  if not (state.round and state.synced and state.localround and not state.endlock) then return false end
  if state.participants[localplayer.UserId] ~= true then return false end
  local entry = state.authoritative[localplayer.UserId]
  return type(entry) == "table" and rf.normalize_role(entry.Role) ~= nil
    and entry.Killed ~= true and entry.Dead ~= true
end

function rf.farmconfirmedkilled()
  local authoritative = state.authoritative[localplayer.UserId]
  local recorded = rf.getrecord(localplayer)
  for _, data in ipairs({authoritative or {}, recorded or {}}) do
    if data.Killed == true or data.Dead == true then return true end
  end
  local character = localplayer.Character
  for _, object in ipairs({localplayer, character}) do
    if object then
      for _, key in ipairs({"Killed", "Dead"}) do
        if object:GetAttribute(key) == true then return true end
        local value = object:FindFirstChild(key)
        if value and value:IsA("BoolValue") and value.Value then return true end
      end
    end
  end
  return false
end

function rf.victoryisshown()
  if state.victoryactive then return true end
  local now = os.clock()
  if now < state.nextvictorycheck then return state.victoryvisible end
  state.nextvictorycheck = now + 0.3
  state.victoryvisible = false
  local playergui = localplayer:FindFirstChildOfClass("PlayerGui")
  if not playergui then return false end
  for _, object in ipairs(playergui:GetDescendants()) do
    if object:IsA("TextLabel") or object:IsA("TextButton") then
      local text = rf.compacttext(object.Text):upper():gsub("[^A-Z]", "")
      if text == "VICTORY" or text == "DEFEAT" then
        local current = object
        local visible = true
        while current and current ~= playergui do
          if current:IsA("GuiObject") and not current.Visible then visible = false break end
          if current:IsA("LayerCollector") and not current.Enabled then visible = false break end
          current = current.Parent
        end
        if visible and current == playergui then
          state.victoryvisible = true
          break
        end
      end
    end
  end
  if state.victoryvisible and not state.coinroundhidden then
    rf.farmshowafterfull(true)
    state.coinroundhidden = true
    if rf.autokillstop then rf.autokillstop("round finished", false) end
    if rf.autoshootstophover then rf.autoshootstophover(true) end
    rf.clearcoinchams()
    rf.farmstop(true)
    farm.home = nil
    state.autofarm.status = flags.autofarm and "Waiting for next round" or "Off"
  end
  return state.victoryvisible
end

function rf.getpickupattachment(marker)
  local _, instance, part, _, proof = rf.droppedgunposition()
  if instance and rf.validgundrop(instance, part, proof) then
    return nil, part
  end
  return nil, nil
end

function rf.applypickuppart(job, object)
  if not object:IsA("BasePart") then return end
  if job.touches[object] == nil then job.touches[object] = object.CanTouch end
  if job.collisions[object] == nil then
    local original = state.noclip.originals[object]
    if original == nil then original = object.CanCollide end
    job.collisions[object] = original
  end
  object.CanCollide = false
  object.CanTouch = object == job.head
end

function rf.enforcepickupcollision(job)
  for _, object in ipairs(job.character:GetDescendants()) do
    if object:IsA("BasePart") then rf.applypickuppart(job, object) end
  end
end

function rf.pickupcontactpart(job)
  local selected, score = job.part, -math.huge
  local visited = {}
  local function scan(model)
    if visited[model] or not rf.realgunmodel(model) then return end
    visited[model] = true
    for _, object in ipairs(model:GetDescendants()) do
      if object:IsA("BasePart") and object:IsDescendantOf(world) then
        local distance = (object.Position - job.part.Position).Magnitude
        if distance <= 28 then
          local name = object.Name:lower()
          local value = 200 - distance * 2
          if name == "handle" then value += 55 end
          if name == "hitbox" or name == "touchpart" then value += 40 end
          if object:FindFirstChild("TouchInterest") then value += 100 end
          if object.CanTouch then value += 12 end
          if value > score then selected, score = object, value end
        end
      end
    end
  end
  for _, reference in ipairs({job.source, job.proof, job.part}) do
    local current, depth = reference, 0
    while current and current ~= world and depth < 6 do
      if current:IsA("Model") or current:IsA("Tool") then
        scan(current)
        if current:IsA("Model") and rf.fuzzyname(current.Name, "Raggy", 1) then
          for _, object in ipairs(current:GetDescendants()) do
            if object:IsA("Model") or object:IsA("Tool") then scan(object) end
          end
        end
      end
      current = current.Parent
      depth += 1
    end
  end
  return selected
end

function rf.pickupfloorheight(job)
  local contact = job.contact or job.part
  local excluded = {job.character, contact, job.part}
  for _, player in ipairs(players:GetPlayers()) do
    if player.Character and player.Character ~= job.character then
      excluded[#excluded + 1] = player.Character
    end
  end
  for _, reference in ipairs({job.source, job.proof, contact}) do
    local current, depth = reference, 0
    while current and current ~= world and depth < 6 do
      if (current:IsA("Tool") or current:IsA("Model"))
        and (rf.realgunmodel(current) or rf.fuzzyname(current.Name, "Raggy", 1)) then
        excluded[#excluded + 1] = current
      end
      current = current.Parent
      depth += 1
    end
  end
  local params = RaycastParams.new()
  params.FilterType = Enum.RaycastFilterType.Exclude
  params.FilterDescendantsInstances = excluded
  params.IgnoreWater = true
  local origin = contact.Position + Vector3.new(0, 5, 0)
  local success, result = pcall(world.Raycast, world, origin, Vector3.new(0, -45, 0), params)
  if success and result and result.Normal.Y > 0.55
    and result.Position.Y <= contact.Position.Y + 1.5 then
    return result.Position.Y
  end
  return nil
end

function rf.pickupverticalradius(part)
  local frame, size = part.CFrame, part.Size
  return math.abs(frame.RightVector.Y) * size.X * 0.5
    + math.abs(frame.UpVector.Y) * size.Y * 0.5
    + math.abs(frame.LookVector.Y) * size.Z * 0.5
end

function rf.pickupheadposition(job)
  local neck = job.neck
  if neck and neck.Parent and neck.Part0 and neck.Part0.Parent then
    local success, result = pcall(function()
      return (neck.Part0.CFrame * neck.C0 * neck.Transform * neck.C1:Inverse()).Position
    end)
    if success and typeof(result) == "Vector3" then return result end
  end
  return job.head.Position
end

function rf.pickupheadtarget(job)
  local contact = job.contact or job.part
  local radius = rf.pickupverticalradius(contact)
  local headradius = math.max(0.2, rf.pickupverticalradius(job.head))
  return Vector3.new(contact.Position.X,
    contact.Position.Y - radius - headradius + 0.22, contact.Position.Z)
end

function rf.pickupstartcontact(job)
  if job.stage == "contact" then return true end
  if not rf.validgundrop(job.source, job.part, job.proof) then return false end
  job.contact = rf.pickupcontactpart(job)
  if not job.contact or not job.contact.Parent then return false end
  job.floor = rf.pickupfloorheight(job)
  for _, joint in ipairs(job.character:GetDescendants()) do
    if joint:IsA("Motor6D") and joint.Part1 == job.head then
      job.neck = joint
      job.neckframe = joint.C0
      local destination = rf.pickupheadtarget(job)
      local relative = job.head.Position.Y - job.root.Position.Y
      local needed = job.floor and destination.Y - relative - job.floor + 2.5 or 3.5
      job.necklift = math.clamp(math.max(3.5, needed), 3.5, 10)
      joint.C0 = CFrame.new(0, job.necklift, 0) * joint.C0
      break
    end
  end
  job.stage = "contact"
  job.elapsed, job.touchcycle = 0, 0
  state.pickupstatus = "Making contact with dropped gun"
  if not rf.movepickup(job) then return false end
  if type(firetouchinterest) == "function" and job.contact and job.contact.Parent then
    pcall(firetouchinterest, job.head, job.contact, 0)
    job.touchcontact = job.contact
  end
  return true
end

function rf.movepickup(job)
  if not job.character.Parent or not job.root.Parent or not job.head.Parent
    or not rf.validgundrop(job.source, job.part, job.proof) then return false end
  if not job.contact or not job.contact:IsDescendantOf(world) then
    job.contact = rf.pickupcontactpart(job)
  end
  if not job.contact or not job.contact.Parent then return false end
  local destination = rf.pickupheadtarget(job)
  job.destination = destination
  local difference = destination - rf.pickupheadposition(job)
  if job.stage == "approach" then
    local maximum = math.clamp((job.steptime or 1 / 60) * 320, 4, 24)
    if difference.Magnitude > maximum then
      difference = difference.Unit * maximum
    end
  end
  if difference.Magnitude > 0.015 then
    rf.teleportpivot(job.character, job.character:GetPivot() + difference)
  end
  job.root.AssemblyLinearVelocity = Vector3.zero
  job.root.AssemblyAngularVelocity = Vector3.zero
  return true
end

function rf.beginpickup(job)
  if job.started then return true end
  if not rf.validgundrop(job.source, job.part, job.proof) then return false end
  local success = pcall(function()
    job.original = job.character:GetPivot()
    job.velocity = job.root.AssemblyLinearVelocity
    job.angular = job.root.AssemblyAngularVelocity
    job.contact = rf.pickupcontactpart(job)
    if not job.contact or not job.contact.Parent then error("gun contact missing") end
    job.stage = "approach"
    job.totalelapsed = 0
    job.startdistance = (job.head.Position - job.contact.Position).Magnitude
    job.timeout = math.clamp(job.startdistance / 125 + 5, 5, 55)
    rf.enforcepickupcollision(job)
    job.connection = job.character.DescendantAdded:Connect(function(object)
      if job.started and state.pickupjob == job and object:IsA("BasePart") then
        pcall(rf.applypickuppart, job, object)
      end
    end)
    job.started = true
    if job.startdistance > 100 then
      job.streaming = true
      job.streamready = false
      job.streamwaitat = os.clock()
      local target = job.contact.Position
      rf.spawn(function()
        local success = pcall(function() localplayer:RequestStreamAroundAsync(target, 2.5) end)
        if state.alive and state.pickupjob == job then
          job.streaming = false
          job.streamready = success and job.contact and job.contact.Parent ~= nil
          if not job.streamready then state.pickupstatus = "Streaming unavailable; approaching visible drop" end
        end
      end)
    end
    state.pickupstatus = "Approaching dropped gun"
  end)
  return success
end

function rf.pickupgun()
  if state.autofling and state.autofling.active then
    state.pickupstatus = "paused for auto fling"
    return false
  end
  if not state.alive or state.pickupbusy or state.manualshotbusy then return false end
  if not flags.autopickup or not config.autopickup then
    state.pickupstatus = "pickup disabled"
    return false
  end
  if not rf.localisinround() then
    state.pickupstatus = "not participating in round"
    return false
  end
  if rf.haslocalgun() then
    state.pickupstatus = "gun acquired"
    state.pickupfailures, state.pickupretryat, state.pickupretrytarget = 0, 0, nil
    return false
  end
  if rf.localismurderer() or rf.localisdead() or rf.victoryisshown() then
    state.pickupstatus = "round safety restriction"
    return false
  end
  local character = localplayer.Character
  local head = character and character:FindFirstChild("Head")
  local root = character and character:FindFirstChild("HumanoidRootPart")
  local part = state.droppart
  if not head or not head:IsA("BasePart") or not root or not root:IsA("BasePart")
    or not part or not part:IsA("BasePart")
    or part:IsDescendantOf(character)
    or not rf.validgundrop(state.dropinstance, part, state.dropproof) then
    state.pickupstatus = "pickup part unavailable"
    return false
  end
  if state.pickupretrytarget ~= part then
    state.pickupretrytarget, state.pickupretryat, state.pickupfailures = part, 0, 0
  end
  if os.clock() < state.pickupretryat then
    state.pickupstatus = "retry pending"
    return false
  end
  local identity = state.dropproof and state.dropproof.Parent and state.dropproof
    or state.dropinstance and state.dropinstance.Parent and state.dropinstance or part
  if identity ~= state.pickupdropkey then
    state.pickupdropkey = identity
    state.pickupdropreadyat = os.clock() + 0.25
    state.pickupstatus = "waiting for drop to settle"
    return false
  end
  if os.clock() < (state.pickupdropreadyat or 0) then
    state.pickupstatus = "waiting 0.25 seconds after drop"
    return false
  end
  local attachment = part == state.droppart and state.dropattachment or nil
  if not (attachment and attachment:IsA("Attachment") and attachment:IsDescendantOf(world)) then
    attachment = nil
  end
  local reference = rf.isgunraycastmarker(state.dropproof)
  local job = {
    character = character, head = head, root = root, part = part, source = state.dropinstance,
    proof = state.dropproof, attachment = attachment, reference = reference,
    touchpart = head, rootsize = root.Size, rootcantouch = root.CanTouch, touchcycle = 0,
    original = nil, velocity = nil, angular = nil, touches = {}, collisions = {}, connection = nil,
    neck = nil, neckframe = nil, necklift = 0, contact = nil, touchcontact = nil, floor = nil,
    elapsed = 0, started = false, stage = "pending", steptime = 0, totalelapsed = 0,
    originalround = state.roundstartedat, originalmap = state.maproot,
    attempt = state.pickupfailures + 1, inventory = {}
  }
  local restored = false
  local function restore(cancel)
    if restored then return end
    restored = true
    if job.connection then
      job.connection:Disconnect()
      job.connection = nil
    end
    for _, watcher in ipairs(job.inventory) do watcher:Disconnect() end
    table.clear(job.inventory)
    if job.touchcontact and job.touchcontact.Parent and job.head.Parent
      and type(firetouchinterest) == "function" then
      pcall(firetouchinterest, job.head, job.touchcontact, 1)
    end
    job.touchcontact = nil
    if job.neck and job.neck.Parent and job.neckframe then
      pcall(function() job.neck.C0 = job.neckframe end)
    end
    if root.Parent then
      pcall(function()
        root.Size = job.rootsize
        root.CanTouch = job.rootcantouch
      end)
    end
    if job.original and character.Parent and root.Parent and localplayer.Character == character
      and job.originalround == state.roundstartedat and job.originalmap == state.maproot
      and rf.localisinround() and not rf.localisdead() and not rf.voidlobbyspawn(root.Position) then
      pcall(function()
        rf.teleportpivot(character, job.original)
        root.AssemblyLinearVelocity = job.velocity or Vector3.zero
        root.AssemblyAngularVelocity = job.angular or Vector3.zero
      end)
    end
    for touchedpart, previous in pairs(job.touches) do
      if touchedpart.Parent then pcall(function() touchedpart.CanTouch = previous end) end
    end
    if state.pickuprestore == restore then state.pickuprestore = nil end
    if state.pickupjob == job then state.pickupjob = nil end
    state.pickupbusy = false
    rf.motionrelease("pickup", true)
    if not rf.noclipwanted() then
      for collisionpart, previous in pairs(job.collisions) do
        if collisionpart.Parent and state.noclip.originals[collisionpart] == nil then
          pcall(function() collisionpart.CanCollide = previous end)
        end
      end
    end
    if state.pendingmanualshot then
      local queued = state.pendingmanualshot >= os.clock() and rf.haslocalgun()
      state.pendingmanualshot = nil
      if queued then
        rf.defer(function()
          if state.alive and not state.pickupbusy and not state.manualshotbusy
            and rf.localisinround() and not rf.localisdead() and rf.shootmurdererkey then
            rf.shootmurdererkey()
          end
        end)
      end
    end
    if rf.haslocalgun() then
      state.pickupstatus = "Gun collected"
      state.pickupfailures, state.pickupretryat, state.pickupretrytarget = 0, 0, nil
    elseif not cancel and state.alive and flags.autopickup and config.autopickup
      and rf.localisinround() and not rf.localismurderer() and not rf.localisdead()
      and not rf.victoryisshown() and rf.validgundrop(job.source, part, job.proof) then
      state.pickupfailures += 1
      local retry = math.clamp((tonumber(config.pickupretrydelay) or 0.3) + math.min(1.2, job.attempt * 0.12), 0.25, 1.8)
      state.pickupretryat = os.clock() + retry
      state.pickupstatus = "No gun after attempt " .. job.attempt .. "; retrying"
      rf.delay(retry, function()
        if not state.alive or state.pickupbusy or rf.haslocalgun()
          or not flags.autopickup or not config.autopickup or not rf.localisinround()
          or rf.localismurderer() or rf.localisdead() or rf.victoryisshown()
          or not rf.validgundrop(job.source, part, job.proof)
          or state.pickupretrytarget ~= part then return end
        state.pickupretryat = 0
        rf.scangunpickup()
      end)
    else
      state.pickupstatus = "Pickup stopped"
    end
  end
  if not rf.motionacquire("pickup") then
    state.pickupstatus = "queued behind " .. tostring(rf.motionowner())
    return false
  end
  job.restore = restore
  state.pickupjob, state.pickuprestore = job, restore
  state.pickupbusy, state.pickupstatus = true, "Picking up gun (attempt " .. job.attempt .. ")"
  local function inventorychanged(item)
    if item:IsA("Tool") and (rf.isgunname(item.Name) or item:FindFirstChild("Muzzle", true)) then
      rf.defer(function()
        if state.pickupjob == job and not restored and rf.haslocalgun() then restore(true) end
      end)
    end
  end
  for _, container in ipairs({character, localplayer:FindFirstChildOfClass("Backpack")}) do
    if container then
      job.inventory[#job.inventory + 1] = container.ChildAdded:Connect(inventorychanged)
    end
  end
  if state.autofarm and state.autofarm.suspend then
    state.autofarm.suspend(false)
  end
  if not rf.beginpickup(job) then
    state.pickupstatus = "teleport failed"
    restore(false)
    return false
  end
  return true
end

function rf.scangunpickup()
  if not state.alive or state.pickupbusy or state.manualshotbusy
    or not flags.autopickup or not config.autopickup
    or not rf.localisinround() or rf.localismurderer()
    or rf.localisdead() or rf.haslocalgun() or state.endlock then return false end
  local position, instance, part, attachment, proof = rf.droppedgunposition()
  if (typeof(position) ~= "Vector3" or not rf.validgundrop(instance, part, proof))
    and os.clock() >= (state.pickuprescanat or 0) then
    state.pickuprescanat = os.clock() + 2
    rf.rescanexistinggundrops(true)
    position, instance, part, attachment, proof = rf.droppedgunposition()
  end
  if typeof(position) ~= "Vector3" or not rf.validgundrop(instance, part, proof) then
    state.dropposition, state.dropinstance, state.droppart, state.dropattachment, state.dropproof = nil, nil, nil, nil, nil
    state.pickupdropkey, state.pickupdropreadyat = nil, 0
    state.pickupretrytarget, state.pickupretryat, state.pickupfailures = nil, 0, 0
    state.pickupstatus = "Waiting for confirmed dropped gun"
    return false
  end
  if state.dropinstance ~= instance or state.droppart ~= part then
    state.pickupretrytarget, state.pickupretryat, state.pickupfailures = nil, 0, 0
  end
  state.dropposition = position
  state.dropinstance = instance
  state.droppart = part
  state.dropattachment = attachment
  state.dropproof = proof
  local identity = proof and proof.Parent and proof or instance and instance.Parent and instance or part
  if state.pickupdropkey ~= identity then
    state.pickupdropkey = identity
    state.pickupdropreadyat = os.clock() + 0.25
  end
  if os.clock() < (state.pickupdropreadyat or 0) then
    state.pickupstatus = "waiting 0.25 seconds after drop"
    return false
  end
  return rf.pickupgun()
end

function rf.steppickup(dt)
  local job = state.pickupjob
  if not job then return end
  if rf.motionowner() ~= "pickup" then
    job.restore(true)
    return
  end
  if rf.haslocalgun() then
    job.restore(true)
    return
  end
  if not state.alive or not flags.autopickup or not config.autopickup
    or not rf.localisinround()
    or rf.localismurderer() or rf.localisdead() or rf.victoryisshown()
    or job.character ~= localplayer.Character or not job.head.Parent
    or not rf.validgundrop(job.source, job.part, job.proof) then
    job.restore(true)
    return
  end
  if not job.started then
    if not rf.beginpickup(job) then job.restore(false) end
    return
  end
  if job.streaming and os.clock() - (job.streamwaitat or 0) < 2.75 then
    state.pickupstatus = "Streaming distant gun"
    return
  end
  job.steptime = math.max(1 / 240, dt or 1 / 60)
  job.totalelapsed = (job.totalelapsed or 0) + job.steptime
  if job.totalelapsed >= (job.timeout or 6) then
    state.pickupstatus = "Pickup timed out; retrying"
    job.restore(false)
    return
  end
  local success, moved = pcall(function()
    rf.enforcepickupcollision(job)
    return rf.movepickup(job)
  end)
  if not success or not moved then
    state.pickupstatus = "teleport interrupted"
    job.restore(false)
    return
  end
  if job.stage == "approach" then
    local distance = (rf.pickupheadtarget(job) - rf.pickupheadposition(job)).Magnitude
    if distance > 17 then
      state.pickupstatus = "Approaching gun (" .. tostring(math.floor(distance)) .. " studs)"
      return
    end
    local ready, completed = pcall(rf.pickupstartcontact, job)
    if not ready or not completed then
      job.restore(false)
    end
    return
  end
  local delta = math.max(0, dt or 0)
  job.elapsed += delta
  job.touchcycle += delta
  if job.touchcycle >= 0.055 and type(firetouchinterest) == "function"
    and job.head.Parent and job.contact and job.contact.Parent then
    job.touchcycle = 0
    if job.touchcontact and job.touchcontact.Parent then
      pcall(firetouchinterest, job.head, job.touchcontact, 1)
    end
    pcall(firetouchinterest, job.head, job.contact, 0)
    job.touchcontact = job.contact
  end
  local hold = job.reference and 1 or math.clamp(tonumber(config.pickuphold) or 0.75, 0.65, 1.25)
  if job.elapsed >= hold then
    state.pickupstatus = "Checking inventory after attempt " .. job.attempt
    job.restore(false)
  end
end

local farm = state.autofarm
local motionpriorities = {manualshot = 700, autofling = 850, autokill = 400, pickup = 350, autoshoot = 300, autofarm = 100}
local motionqueue = {owner = nil, shotuntil = 0, manualuntil = 0, queuedcollect = false,
  returnhome = false, returndestination = nil, priorities = motionpriorities,
  character = nil, round = nil, generation = 0, acquiredat = 0,
  returncharacter = nil, returnround = nil, returnmap = nil, returnkind = nil}
state.movementqueue = motionqueue
state.noclip.owners = {pickup = false, autovote = false, autokill = false,
  manualshot = false, autoshoot = false}
state.noclip.suppressed = not (state.noclip.manualenabled or state.noclip.autoenabled)

function rf.noclipwanted()
  if state.noclip.manualenabled or state.noclip.autoenabled then return true end
  for _, enabled in pairs(state.noclip.owners) do
    if enabled then return true end
  end
  return false
end

function rf.noclipowner(owner, enabled)
  local noclip = state.noclip
  if noclip.owners[owner] == nil then return false end
  enabled = enabled == true
  if noclip.owners[owner] == enabled then return enabled end
  noclip.owners[owner] = enabled
  noclip.suppressed = not rf.noclipwanted()
  if rf.enforcenoclip then rf.enforcenoclip() end
  state.antifling.pairclock = 0
  if rf.updatecollisions then rf.updatecollisions() end
  return enabled
end

farm.voidcooldown = 0
farm.voidrecoveries = 0

function rf.motionowner()
  local owner = motionqueue.owner
  if not owner then return nil end
  if motionqueue.character and (motionqueue.character ~= localplayer.Character or not motionqueue.character.Parent)
    or motionqueue.round ~= state.roundstartedat then
    rf.motionrelease(owner, true)
    return nil
  end
  if owner == "manualshot" and not state.manualshotbusy and os.clock() >= motionqueue.manualuntil then
    motionqueue.owner = nil
    rf.noclipowner("manualshot", false)
  elseif owner == "autoshoot" and not state.autoshoothover
    and os.clock() >= motionqueue.shotuntil then
    motionqueue.owner = nil
    rf.noclipowner("autoshoot", false)
  elseif owner == "pickup" and not state.pickupbusy
    and os.clock() - (motionqueue.acquiredat or 0) >= 0.35 then
    motionqueue.owner = nil
    rf.noclipowner("pickup", false)
  end
  return motionqueue.owner
end

function rf.motionacquire(owner, hold)
  if not motionpriorities[owner] or not state.alive or state.stopping then return false end
  local character = localplayer.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  if not character or not character.Parent or not humanoid or humanoid.Health <= 0 then return false end
  if owner == "autoshoot" and (not config.autoshoot or not config.autoshootbehind and not config.autoshootfar) then return false end
  if owner == "autokill" and not flags.autokillall then return false end
  if owner == "autofling" and not (state.autofling and (state.autofling.murderer or state.autofling.sheriff)) then return false end
  if owner == "pickup" and (not flags.autopickup or not config.autopickup) then return false end
  if owner == "autovote" and not config.autovote then return false end
  if owner == "autofarm" and not flags.autofarm then return false end
  local current = rf.motionowner()
  if current and current ~= owner and motionpriorities[current] >= motionpriorities[owner] then
    if owner == "autofarm" then motionqueue.queuedcollect = flags.autofarm end
    return false
  end
  if current and current ~= owner then
    if current == "manualshot" and state.manualshotcancel then
      pcall(state.manualshotcancel)
    elseif current == "autofarm" and farm.session then
      motionqueue.queuedcollect = flags.autofarm
      rf.farmstop(false)
    elseif current == "autoshoot" and state.autoshoothover then
      rf.autoshootstophover(true)
    elseif current == "pickup" and state.pickuprestore then
      state.pickuprestore(true)
    elseif current == "autokill" and rf.autokillstop then
      rf.autokillstop("movement interrupted", false)
    elseif current == "autofling" and rf.flingstop then
      rf.flingstop("movement interrupted", true)
    end
    rf.noclipowner(current, false)
  end
  if owner ~= "autofarm" and farm.session then
    motionqueue.queuedcollect = flags.autofarm
    rf.farmstop(false)
  end
  if owner ~= "autofarm" and farm.hide then
    rf.farmshowafterfull(true)
  end
  if motionqueue.owner ~= owner then
    motionqueue.generation += 1
    motionqueue.acquiredat = os.clock()
  end
  motionqueue.owner = owner
  motionqueue.character = localplayer.Character
  motionqueue.round = state.roundstartedat
  if owner ~= "autofarm" and owner ~= "autofling" then rf.noclipowner(owner, true) end
  if owner == "autoshoot" then
    motionqueue.shotuntil = math.max(motionqueue.shotuntil, os.clock() + (hold or 0.65))
  elseif owner == "manualshot" then
    motionqueue.manualuntil = math.max(motionqueue.manualuntil, os.clock() + (hold or 0.45))
  elseif owner == "autofarm" then
    motionqueue.queuedcollect = false
  end
  return true
end

function rf.motionrelease(owner, immediate)
  if owner == "autoshoot" and not immediate and motionqueue.owner == owner then
    motionqueue.shotuntil = math.max(motionqueue.shotuntil, os.clock() + 0.35)
    return
  end
  if owner == "manualshot" then motionqueue.manualuntil = 0 end
  if owner == "autoshoot" then motionqueue.shotuntil = 0 end
  if motionqueue.owner == owner then
    motionqueue.owner = nil
    motionqueue.character = nil
    motionqueue.round = nil
    motionqueue.generation += 1
    if (owner == "autokill" or owner == "pickup") and flags.autofarm then
      motionqueue.queuedcollect = true
      farm.nextscan = 0
    end
  end
  rf.noclipowner(owner, false)
end

local voting = {status = "Disabled", pad = nil, name = nil, attempts = 0, stage = "idle",
  oldcharacter = nil, deadline = 0, nextattempt = 0, finished = false,
  missingat = 0, startedat = 0, lastscan = 0, choices = {}, active = false,
  attemptserial = 0, touchat = 0, collisions = nil, voteconnections = {},
  stepping = false, lastreset = 0, lastcharacter = nil, noresponse = 0,
  resetsmax = math.huge, rescanat = 0, cameracheckat = 0, baselines = {},
  pendingcharacter = nil, holdconnection = nil, holdroot = nil, holdserial = nil, resetretry = false, attemptstarted = 0, timeoutseconds = 0.85}
state.voting = voting
motionpriorities.autovote = 600

rf.resources.mapimagecache = {}
state.mapimagecache = rf.resources.mapimagecache

function rf.mapasset(value)
  if typeof(value) == "Content" then
    local ok, uri = pcall(function() return value.Uri end)
    if ok and type(uri) == "string" then
      value = uri
    else
      value = tostring(value):match("Uri=([^,}%s]+)") or ""
    end
  end
  if type(value) == "number" then
    value = tostring(value)
  end
  if type(value) ~= "string" then return "" end
  value = value:match("^%s*(.-)%s*$")
  if value == "" or value == "0" or value:lower():find("placeholder", 1, true) then return "" end
  if value:match("^%d+$") then return "rbxassetid://" .. value end
  if value:match("^rbxassetid://%d+$") or value:match("^rbxasset://[%w%p]+$")
    or value:match("^rbxthumb://[%w%p]+$") then return value end
  local id = value:match("^https?://www%.roblox%.com/asset/%?id=(%d+)")
    or value:match("^https?://assetdelivery%.roblox%.com/v1/asset/%?id=(%d+)")
  if id then return "rbxassetid://" .. id end
  return ""
end

function rf.mapimageproperty(object, name)
  if not object then return "" end
  local ok, value = pcall(function() return object[name] end)
  return ok and rf.mapasset(value) or ""
end

function rf.mapimagesource(object)
  if not object then return "" end
  if object:IsA("ImageLabel") or object:IsA("ImageButton") then
    for _, property in ipairs({"Image", "ImageContent", "LocalizedImageContent"}) do
      local image = rf.mapimageproperty(object, property)
      if image ~= "" then return image end
    end
  elseif object:IsA("Decal") or object:IsA("Texture") then
    for _, property in ipairs({"Texture", "TextureContent"}) do
      local image = rf.mapimageproperty(object, property)
      if image ~= "" then return image end
    end
  elseif object:IsA("StringValue") then
    local image = rf.mapasset(object.Value)
    if image ~= "" then return image end
  end
  local ok, attributes = pcall(object.GetAttributes, object)
  if ok and type(attributes) == "table" then
    for key, value in pairs(attributes) do
      local field = key:lower()
      if field:find("mapicon", 1, true) or field:find("mapimage", 1, true)
        or field:find("mapthumbnail", 1, true) then
        local image = rf.mapasset(value)
        if image ~= "" then return image end
      end
    end
  end
  return ""
end

function rf.votemapimage(pad, info, icon, surface, mapinfo)
  for _, source in ipairs({mapinfo or false, info or false, surface or false, icon or false, pad or false}) do
    if source then
      local image = rf.mapimagesource(source:FindFirstChild("MapIcon", true))
      if image ~= "" then return image end
    end
  end
  for _, source in ipairs({mapinfo or false, info or false, surface or false, pad or false}) do
    if source then
      for _, name in ipairs({"MapImage", "MapThumbnail", "MapPicture", "Thumbnail", "MapTexture"}) do
        local image = rf.mapimagesource(source:FindFirstChild(name, true))
        if image ~= "" then return image end
      end
    end
  end
  local mapvalue = icon and icon:FindFirstChild("Map")
  if mapvalue and mapvalue:IsA("ObjectValue") and mapvalue.Value then
    local model = mapvalue.Value
    for _, name in ipairs({"MapIcon", "MapImage", "MapThumbnail", "Thumbnail"}) do
      local image = rf.mapimagesource(model:FindFirstChild(name, true))
      if image ~= "" then return image end
    end
  end
  return ""
end

rf.resources.voteimagechecked = {}
rf.resources.votewindowcache = {signature = "", recentuntil = 0, seen = {}, changedat = 0}
function rf.votepads(includeimages)
  local lobby = world:FindFirstChild("RegularLobby")
  if not lobby then return {}, false end
  local icons = lobby:FindFirstChild("VoteIcons")
  local detectors = lobby:FindFirstChild("VotePads")
  local results = {}
  local official = false
  local assigned, evidence, signature, names = 0, 0, {}, {}
  for index = 1, 3 do
    local pad = lobby:FindFirstChild("VotePad" .. index)
    local info = pad and pad:FindFirstChild("VoteInfoGui")
    local container = info and info:FindFirstChild("Container")
    local label = container and container:FindFirstChild("MapName")
    local icon = icons and icons:FindFirstChild("VotePad" .. index)
    local surface = icon and icon:FindFirstChild("Surface")
    local enabled = icon and icon:FindFirstChild("Voting")
    local mapinfo = pad and pad:FindFirstChild("MapInfoGui")
    local display = icon and icon:FindFirstChild("MapInfo")
    local displaysurface = display and display:FindFirstChild("Surface")
    local frame = displaysurface and displaysurface:FindFirstChild("Frame")
    local displayname = frame and frame:FindFirstChild("MapName")
    local displayvotes = frame and frame:FindFirstChild("Votes")
    local mapvalue = icon and icon:FindFirstChild("Map")
    local assignedmap = mapvalue and mapvalue:IsA("ObjectValue") and mapvalue.Value
    local name = assignedmap and assignedmap.Name or ""
    if not votemapkeys[votekey(name)] then
      name = displayname and displayname:IsA("TextLabel") and displayname.Text or ""
    end
    if not votemapkeys[votekey(name)] then
      name = label and label:IsA("TextLabel") and label.Text or ""
    end
    local key = votekey(name)
    local detector = detectors and detectors:FindFirstChild("Detector" .. index)
    local valid = votemapkeys[key] ~= nil and detector and detector:IsA("BasePart")
    local image = includeimages == false and "" or rf.resources.mapimagecache[key] or ""
    local stamp = rf.resources.voteimagechecked[index]
    if includeimages ~= false and valid and image == ""
      and (not stamp or stamp.key ~= key or os.clock() - stamp.at > 2.5) then
      rf.resources.voteimagechecked[index] = {key = key, at = os.clock()}
      image = rf.votemapimage(pad, info, icon, surface, mapinfo)
    end
    names[index] = valid and key or ""
    if valid then
      name = votemapkeys[key]
      assigned += 1
      signature[#signature + 1] = key
      if image ~= "" then rf.resources.mapimagecache[key] = image else image = rf.resources.mapimagecache[key] or "" end
    end
    local replicated = valid and enabled and enabled:IsA("BoolValue") and enabled.Value == true
    local visible = valid and (
      info and info:IsA("SurfaceGui") and info.Enabled
      or mapinfo and mapinfo:IsA("SurfaceGui") and mapinfo.Enabled
      or surface and surface:IsA("SurfaceGui") and surface.Enabled
      or displaysurface and displaysurface:IsA("SurfaceGui") and displaysurface.Enabled)
    local votesource = icon and icon:FindFirstChild("Votes")
    local votelabel = container and container:FindFirstChild("Votes") or displayvotes
    local count = votesource and (votesource:IsA("IntValue") or votesource:IsA("NumberValue"))
      and votesource.Value or votelabel and votelabel:IsA("TextLabel")
      and tonumber(tostring(votelabel.Text):match("(%d+)")) or nil
    if replicated then official = true end
    if valid and (visible or assignedmap or type(count) == "number" and count > 0) then
      evidence += 1
    end
    results[index] = {index = index, name = name, active = false, official = replicated == true,
      valid = valid == true, detector = valid and detector or nil,
      icon = icon, info = info, surface = surface,
      votecount = votesource, votelabel = votelabel, image = image}
  end
  local now = os.clock()
  local lobbyeligible = not (state.roundstartparticipant and rf.localisinround())
  local current = table.concat(signature, ":")
  local changed = false
  for index = 1, 3 do
    local name = names[index] or ""
    local previous = rf.resources.votewindowcache.seen[index]
    if previous ~= nil and name ~= "" and name ~= previous then changed = true end
    rf.resources.votewindowcache.seen[index] = name
  end
  if changed and assigned >= 2 and lobbyeligible then rf.resources.votewindowcache.changedat = now end
  local recentlyassigned = rf.resources.votewindowcache.changedat > 0 and now - rf.resources.votewindowcache.changedat <= 12
  local inferred = not official and lobbyeligible and assigned >= 2 and (evidence >= 2 or recentlyassigned)
  if not lobbyeligible then
    rf.resources.votewindowcache.changedat = 0
    rf.resources.votewindowcache.recentuntil = 0
  end
  if official or inferred then
    rf.resources.votewindowcache.signature = current
    rf.resources.votewindowcache.recentuntil = now + 0.65
  elseif lobbyeligible and assigned >= 2 and current == rf.resources.votewindowcache.signature
    and now <= rf.resources.votewindowcache.recentuntil then
    inferred = true
  end
  local active = official or inferred
  for _, entry in ipairs(results) do
    entry.active = entry.valid and (inferred or not official or entry.official) and active or false
  end
  return results, active
end

rf.resources.votefadetracking = {}
rf.resources.votefadelastscan = -math.huge
rf.resources.votefadearmed = false
rf.resources.votefadenames = {fade = true, fader = true, fadegui = true, fadingscreen = true,
  screenfade = true, screenfadegui = true, blackout = true, blackscreen = true,
  transition = true, transitiongui = true, screenwipe = true, whitescreen = true,
  whitefade = true, spawnfade = true, respawnfade = true, deathfade = true}

function rf.votefadeactive()
  return state.alive and config.disablefade == true
end

function rf.votefadeisvisual(object)
  return object and (object:IsA("Frame") or object:IsA("ImageLabel") or object:IsA("ImageButton")) or false
end

function rf.votefadecandidate(object)
  if not rf.votefadeisvisual(object) or not object.Parent then return false end
  local playergui = localplayer:FindFirstChildOfClass("PlayerGui")
  if not playergui or not object:IsDescendantOf(playergui) or not object.Visible then return false end
  local gui = object:FindFirstAncestorOfClass("ScreenGui")
  if not gui or not gui.Enabled or gui.Name:lower():find("vanta", 1, true) then return false end
  local screen = world.CurrentCamera and world.CurrentCamera.ViewportSize
  if not screen or screen.X <= 0 or screen.Y <= 0 then return false end
  local size = object.AbsoluteSize
  local ratio = (size.X / screen.X) * (size.Y / screen.Y)
  local name = object.Name:lower()
  local guiname = gui.Name:lower()
  local named = rf.resources.votefadenames[name] == true or rf.resources.votefadenames[guiname] == true
    or name:find("fade", 1, true) ~= nil or guiname:find("fade", 1, true) ~= nil
    or name:find("blackout", 1, true) ~= nil or guiname:find("blackout", 1, true) ~= nil
  if named and size.X >= screen.X * 0.55 and size.Y >= screen.Y * 0.55 then return true end
  if size.X < screen.X * 0.89 or size.Y < screen.Y * 0.86 or ratio < 0.8 then return false end
  if object:IsA("Frame") then
    local color = object.BackgroundColor3
    local bright = (color.R + color.G + color.B) / 3
    return bright <= 0.12 or bright >= 0.88
  end
  local color = object.ImageColor3
  local bright = (color.R + color.G + color.B) / 3
  return object.Image ~= "" and (bright <= 0.12 or bright >= 0.88)
end

function rf.votefadeattach(object)
  if not rf.votefadeactive() or not rf.votefadecandidate(object) or rf.resources.votefadetracking[object] then return end
  local property = object:IsA("Frame") and "BackgroundTransparency" or "ImageTransparency"
  local tracking = {property = property, connections = {}, changing = false, original = object[property]}
  rf.resources.votefadetracking[object] = tracking
  local function suppress()
    if tracking.changing or not rf.votefadeactive() or not object.Parent then return end
    tracking.changing = true
    pcall(function() if object[property] ~= 1 then object[property] = 1 end end)
    tracking.changing = false
  end
  tracking.connections[#tracking.connections + 1] = object:GetPropertyChangedSignal(property):Connect(suppress)
  tracking.connections[#tracking.connections + 1] = object:GetPropertyChangedSignal("Visible"):Connect(suppress)
  tracking.connections[#tracking.connections + 1] = object.AncestryChanged:Connect(function(_, parent)
    if parent then return end
    for _, connection in ipairs(tracking.connections) do connection:Disconnect() end
    rf.resources.votefadetracking[object] = nil
  end)
  suppress()
end

function rf.votefadeapply(force)
  if not rf.votefadeactive() then
    if next(rf.resources.votefadetracking) then rf.votefadestop(true) end
    return
  end
  local now = os.clock()
  if not force and now - rf.resources.votefadelastscan < 0.5 then return end
  rf.resources.votefadelastscan = now
  local playergui = localplayer:FindFirstChildOfClass("PlayerGui")
  if not playergui then return end
  if not rf.resources.fadeindex then
    rf.resources.fadeindex = setmetatable({}, {__mode = "k"})
    for _, object in ipairs(playergui:GetDescendants()) do
      if rf.votefadeisvisual(object) then rf.resources.fadeindex[object] = true end
    end
  end
  local cursor = rf.resources.fadecursor
  if not cursor or not rf.resources.fadeindex[cursor] then cursor = next(rf.resources.fadeindex) end
  local deadline = os.clock() + 0.0007
  local count = 0
  while cursor and count < 100 and os.clock() < deadline do
    local object = cursor
    cursor = next(rf.resources.fadeindex, object)
    if not object:IsDescendantOf(playergui) then rf.resources.fadeindex[object] = nil
    elseif rf.votefadecandidate(object) then rf.votefadeattach(object) end
    count += 1
  end
  rf.resources.fadecursor = cursor
end

function rf.votefadestop(restore)
  for object, tracking in pairs(rf.resources.votefadetracking) do
    for _, connection in ipairs(tracking.connections) do connection:Disconnect() end
    if restore and object.Parent then pcall(function()
      if object[tracking.property] == 1 then object[tracking.property] = tracking.original end
    end) end
    rf.resources.votefadetracking[object] = nil
  end
  rf.resources.votefadelastscan = -math.huge
end

rf.resources.votefadegui = rf.resources.playergui
rf.resources.votefadepending = false
table.insert(state.connections, rf.resources.votefadegui.DescendantAdded:Connect(function(object)
  if not rf.votefadeisvisual(object) then return end
  if rf.resources.fadeindex then rf.resources.fadeindex[object] = true end
  if rf.votefadeactive() and rf.votefadecandidate(object) then rf.votefadeattach(object) end
end))
rf.votefadeapply(true)

function rf.votecamerastop()
  local session = voting.camera
  if not session then return end
  voting.camera = nil
  local camera = world.CurrentCamera
  if not camera then return end
  pcall(function()
    local character = localplayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
      camera.CameraSubject = humanoid
    elseif session.subject and session.subject.Parent then
      camera.CameraSubject = session.subject
    end
    camera.CameraType = session.type ~= Enum.CameraType.Scriptable
      and session.type or Enum.CameraType.Custom
    if camera == session.camera then camera.FieldOfView = session.fov end
  end)
end

function rf.votecamerastart(selected)
  if voting.camera then return end
  if not selected or voting.stage == "respawn" or voting.camerapeeked then return end
  local camera = world.CurrentCamera
  local detector = selected.detector
  local icon = selected.icon
  local display = selected.info and selected.info.Adornee
  if not (display and display:IsA("BasePart")) then
    display = icon and icon:FindFirstChild("MapInfo")
  end
  if not (display and display:IsA("BasePart")) then
    display = icon and icon:IsA("BasePart") and icon or nil
  end
  if not camera or not display or not display.Parent or not detector or not detector.Parent then return end
  local center = display.Position:Lerp(detector.Position, 0.3) + Vector3.new(0, 1.5, 0)
  local position = display.Position + display.CFrame.LookVector * 16
    + display.CFrame.RightVector * 4 + Vector3.new(0, 6, 0)
  local session = {camera = camera, type = camera.CameraType, subject = camera.CameraSubject,
    fov = camera.FieldOfView}
  local ok = pcall(function()
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = CFrame.lookAt(position, center)
    camera.Focus = CFrame.new(center)
  end)
  if ok then
    voting.camera = session
    voting.camerapeeked = true
    rf.delay(0.11, function()
      if state.alive and voting.camera == session then rf.votecamerastop() end
    end)
  end
end

function rf.voteholdstop()
  if voting.holdconnection then
    voting.holdconnection:Disconnect()
    voting.holdconnection = nil
  end
  voting.holdroot = nil
  voting.holdserial = nil
end

function rf.voteholdstart(serial, character, root, detector)
  rf.voteholdstop()
  voting.holdroot = root
  voting.holdserial = serial
  local target = detector.Position + Vector3.new(0, 1.65, 0)
  local orientation = root.CFrame.Rotation
  local elapsed = 0
  voting.holdconnection = runservice.Heartbeat:Connect(function(dt)
    if not state.alive or not config.autovote or voting.stage ~= "voting"
      or serial ~= voting.attemptserial or localplayer.Character ~= character
      or not root.Parent or not detector.Parent or rf.motionowner() ~= "autovote" then
      rf.voteholdstop()
      return
    end
    elapsed += dt
    if elapsed < 0.025 then return end
    elapsed = 0
    target = detector.Position + Vector3.new(0, 1.65, 0)
    if (root.Position - target).Magnitude > 0.18 then
      local frame = CFrame.new(target) * orientation
      rf.voidmarkteleport(character, frame, 0.35)
      root.CFrame = frame
    end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
  end)
end

function rf.votereleasecontact()
  rf.voteholdstop()
  for _, connection in ipairs(voting.voteconnections) do
    pcall(function() connection:Disconnect() end)
  end
  table.clear(voting.voteconnections)
  local collisions = voting.collisions
  voting.collisions = nil
  if collisions then
    for part, original in pairs(collisions) do
      if part.Parent and not rf.noclipwanted() then
        pcall(function() part.CanCollide = original end)
      end
    end
  end
  voting.touchat = 0
  voting.baselines = {}
end

function rf.votehalt(reason, finished)
  voting.attemptserial += 1
  rf.votereleasecontact()
  rf.votecamerastop()
  if rf.motionowner() == "autovote" then rf.motionrelease("autovote", true) end
  voting.status = reason or "Waiting for voting"
  voting.stage = "idle"
  voting.oldcharacter = nil
  voting.pad = nil
  voting.name = nil
  voting.deadline = 0
  voting.nextattempt = 0
  voting.lastcharacter = nil
  voting.camerapeeked = false
  voting.noresponse = 0
  voting.finished = finished == true
end

function rf.voteenabled()
  if not config.autovote then
    rf.votehalt("Auto Vote disabled", false)
    return
  end
  if #config.autovotemaps == 0 then
    config.autovote = false
    rf.votehalt("Select at least one map", false)
    rf.notification("Auto Vote", "Choose preferred maps first", nil, "map", Color3.fromRGB(242, 197, 130), "vanta:vote:empty")
    return
  end
  voting.status = "Waiting for matching maps"
  rf.votefadeapply()
  voting.nextattempt = 0
  voting.finished = false
  voting.missingat = 0
  voting.startedat = 0
  voting.lastreset = 0
  voting.camerapeeked = false
  voting.noresponse = 0
end

function rf.voteselect(name)
  name = votemapkeys[votekey(name)]
  if not name then return false end
  local index = table.find(config.autovotemaps, name)
  if index then
    table.remove(config.autovotemaps, index)
  else
    config.autovotemaps[#config.autovotemaps + 1] = name
  end
  if voting.name and not table.find(config.autovotemaps, votemapkeys[votekey(voting.name)]) then
    rf.votehalt("Map selection changed", false)
  end
  if config.autovote and #config.autovotemaps == 0 then
    config.autovote = false
    rf.votehalt("Select at least one map", false)
  end
  savepreferences()
  if rf.updatevoteui then rf.updatevoteui() end
  return not index
end

function rf.votereadcount(object)
  if not object or not object.Parent then return nil end
  if object:IsA("IntValue") or object:IsA("NumberValue") then
    return tonumber(object.Value)
  end
  if object:IsA("TextLabel") then
    return tonumber(tostring(object.Text):match("(%d+)"))
  end
  return nil
end

rf.resources.nextmapwatch = {active = false, last = {}, endedat = 0, announced = false,
  observedat = 0, wasactive = false, pending = nil}
state.nextmapwatch = rf.resources.nextmapwatch

function rf.tracknextmap(force)
  if not state.alive then return end
  local pads, active = rf.votepads()
  local now = os.clock()
  local newvotes = false
  for _, entry in ipairs(pads) do
    local labelvotes = rf.votereadcount(entry.votelabel)
    local iconvotes = rf.votereadcount(entry.votecount)
    local votes = math.max(labelvotes or -1, iconvotes or -1)
    local previous = rf.resources.nextmapwatch.last[entry.index]
    if votes > 0 and (not previous or previous.name ~= entry.name or votes > previous.votes) then
      newvotes = true
    end
  end
  if active and not rf.resources.nextmapwatch.wasactive then
    rf.resources.nextmapwatch.last = {}
    rf.resources.nextmapwatch.announced = false
    rf.resources.nextmapwatch.active = true
    rf.resources.nextmapwatch.endedat = 0
  elseif newvotes and not rf.resources.nextmapwatch.active and not rf.resources.nextmapwatch.announced then
    rf.resources.nextmapwatch.active = true
  end
  rf.resources.nextmapwatch.wasactive = active
  if active then rf.resources.nextmapwatch.pending = nil end
  if (active or rf.resources.nextmapwatch.active) and not rf.resources.nextmapwatch.announced then
    for _, entry in ipairs(pads) do
      local labelvotes = rf.votereadcount(entry.votelabel)
      local iconvotes = rf.votereadcount(entry.votecount)
      local votes = math.max(labelvotes or -1, iconvotes or -1)
      local name = tostring(entry.name or ""):match("^%s*(.-)%s*$")
      if votes >= 0 and name ~= "" and name:lower() ~= "map name" then
        local previous = rf.resources.nextmapwatch.last[entry.index]
        local image = rf.mapasset(entry.image)
        if image == "" then
          image = (previous and previous.name == name and previous.image) or rf.resources.mapimagecache[votekey(name)] or ""
        end
        if not previous or previous.name ~= name or votes >= previous.votes then
          rf.resources.nextmapwatch.last[entry.index] = {name = name, votes = votes, image = image}
        elseif previous.image == "" and image ~= "" then
          previous.image = image
        end
        if votes > 0 then rf.resources.nextmapwatch.observedat = now end
      end
    end
  end
  if active and not force then
    rf.resources.nextmapwatch.endedat = 0
    return
  end
  if not rf.resources.nextmapwatch.active or rf.resources.nextmapwatch.announced then return end
  if not force then
    if rf.resources.nextmapwatch.endedat == 0 then
      rf.resources.nextmapwatch.endedat = now
      return
    end
    if now - rf.resources.nextmapwatch.endedat < 0.22 then return end
  end
  local winner
  local tied = false
  for _, entry in pairs(rf.resources.nextmapwatch.last) do
    if entry.votes > 0 then
      if not winner or entry.votes > winner.votes then
        winner = entry
        tied = false
      elseif entry.votes == winner.votes then
        tied = true
      end
    end
  end
  rf.resources.nextmapwatch.active = false
  rf.resources.nextmapwatch.endedat = 0
  if not winner then return end
  if tied then
    rf.resources.nextmapwatch.pending = table.clone(rf.resources.nextmapwatch.last)
    rf.resources.nextmapwatch.announced = false
    return
  end
  rf.resources.nextmapwatch.announced = true
  local image = rf.mapasset(winner.image)
  if image == "" then image = rf.resources.mapimagecache[votekey(winner.name)] or "" end
  rf.notification("Next map", winner.name .. " is next with " .. tostring(winner.votes) .. " votes.",
    nil, "map", Color3.fromRGB(177, 225, 249),
    "vanta:nextmap:" .. tostring(rf.resources.nextmapwatch.observedat), image)
end

function rf.nextmapconfirmed(root)
  local pending = rf.resources.nextmapwatch.pending
  if not pending or not root or not root.Parent then return false end
  local key = votekey(root.Name)
  for _, entry in pairs(pending) do
    if votekey(entry.name) == key then
      local image = rf.mapasset(entry.image)
      if image == "" then image = rf.resources.mapimagecache[key] or "" end
      rf.resources.nextmapwatch.pending = nil
      rf.resources.nextmapwatch.announced = true
      rf.notification("Next map", entry.name .. " is next with " .. tostring(entry.votes) .. " votes.",
        nil, "map", Color3.fromRGB(177, 225, 249), "vanta:nextmap:confirmed:" .. key, image)
      return true
    end
  end
  return false
end

function rf.voteobserved(serial)
  if serial ~= voting.attemptserial or voting.stage ~= "voting" then return false end
  for object, baseline in pairs(voting.baselines) do
    if object.Parent then
      local count = rf.votereadcount(object)
      if type(count) == "number" and count > baseline then return true end
    end
  end
  return false
end

function rf.votefinish(serial, increased)
  if not increased or not state.alive or not config.autovote or voting.stage ~= "voting"
    or serial ~= voting.attemptserial then return end
  local selected = select(1, rf.votepads(false))[voting.pad]
  if not selected or not selected.active or not selected.detector
    or votekey(selected.name) ~= votekey(voting.name) then
    rf.votehalt("Voting pad unavailable", false)
    return
  end
  local character = localplayer.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  if not character or not humanoid or humanoid.Health <= 0 then
    rf.votehalt("Character lost before reset", false)
    return
  end
  voting.attemptserial += 1
  rf.votereleasecontact()
  rf.votecamerastop()
  rf.motionrelease("autovote", true)
  voting.attempts += 1
  voting.noresponse = 0
  voting.stage = "respawn"
  voting.oldcharacter = character
  voting.lastreset = os.clock()
  voting.deadline = voting.lastreset + 12
  voting.nextattempt = voting.lastreset
  voting.resetretry = false
  voting.status = "Vote confirmed; awaiting server respawn"
  local reset = pcall(function()
    humanoid.Health = 0
    humanoid:ChangeState(Enum.HumanoidStateType.Dead)
  end)
  if not reset then rf.votehalt("Unable to reset character", false) end
end

function rf.votetimeout(serial)
  if not state.alive or not config.autovote or voting.stage ~= "voting"
    or serial ~= voting.attemptserial then return end
  if rf.voteobserved(serial) then
    rf.votefinish(serial, true)
    return
  end
  local now = os.clock()
  if now - voting.attemptstarted < voting.timeoutseconds then return end
  voting.attemptserial += 1
  rf.votereleasecontact()
  rf.votecamerastop()
  if rf.motionowner() == "autovote" then rf.motionrelease("autovote", true) end
  voting.noresponse += 1
  voting.stage = "ready"
  voting.nextattempt = now + math.min(0.3 + voting.noresponse * 0.25, 2.5)
  voting.status = "Vote not confirmed; retrying without a reset"
end

function rf.votecontact(serial)
  if serial ~= voting.attemptserial or voting.stage ~= "voting" or voting.touchat ~= 0 then return end
  voting.touchat = os.clock()
  if rf.voteobserved(serial) then rf.votefinish(serial, true) end
end

function rf.votestep()
  if state.autofling and state.autofling.active then return end
  if not state.alive then return end
  if not config.autovote then
    if voting.stage ~= "idle" or rf.motionowner() == "autovote" then
      rf.votehalt("Auto Vote disabled", false)
    end
    return
  end
  if #config.autovotemaps == 0 then
    rf.voteenabled()
    return
  end
  local now = os.clock()
  local pads, anyactive = rf.votepads(false)
  voting.active = anyactive
  if not anyactive then
    if voting.missingat == 0 then voting.missingat = now end
    if now - voting.missingat > 0.65 then
      if voting.stage ~= "idle" then rf.votehalt("Voting ended; waiting for next vote", false) end
      voting.finished = false
      if voting.stage == "idle" and voting.status ~= "Voting ended; waiting for next vote" then
        voting.status = "Waiting for map voting to open"
      end
    end
    return
  end
  voting.missingat = 0
  if voting.finished then
    voting.status = "Vote complete; waiting for next round"
    return
  end
  local selected = voting.pad and pads[voting.pad]
  if voting.pad and (not selected or not selected.active or not selected.detector
    or votekey(selected.name) ~= votekey(voting.name)) then
    rf.votehalt("Voting icon disappeared", true)
    return
  end
  if not voting.pad then
    for _, preferred in ipairs(config.autovotemaps) do
      for _, entry in ipairs(pads) do
        if entry.active and entry.detector and votekey(entry.name) == votekey(preferred) then
          selected = entry
          break
        end
      end
      if selected then break end
    end
    if not selected then
      voting.status = "No preferred maps on the voting pads"
      return
    end
    voting.pad = selected.index
    voting.name = selected.name
    voting.stage = "ready"
    voting.startedat = now
    voting.attempts = 0
    voting.noresponse = 0
    voting.lastreset = 0
    voting.camerapeeked = false
    voting.nextattempt = now + 0.15
    rf.notification("Auto Vote", "Selected " .. selected.name .. " on pad " .. selected.index,
      nil, "map-pin", Color3.fromRGB(177, 225, 249), "vanta:vote:select:" .. tostring(voting.startedat))
    if state.menuopen and rf.showmenu then rf.showmenu(false) end
    rf.votecamerastart(selected)
  end
  if selected and not voting.camera and not voting.camerapeeked and voting.stage ~= "respawn" then rf.votecamerastart(selected) end
  local character = localplayer.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  local root = character and character:FindFirstChild("HumanoidRootPart")
  if voting.stage == "respawn" then
    if character == voting.oldcharacter or not humanoid or humanoid.Health <= 0 or not root then
      if character == voting.oldcharacter and humanoid and humanoid.Health > 0
        and now - voting.lastreset >= 0.65 and not voting.resetretry then
        voting.resetretry = true
        pcall(function()
          humanoid.Health = 0
          humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        end)
      end
      if character == voting.oldcharacter and humanoid and humanoid.Health > 0
        and now - voting.lastreset > 2.5 then
        voting.stage = "ready"
        voting.oldcharacter = nil
        voting.nextattempt = now + 0.10
        voting.status = "Reset not acknowledged; retrying pad"
        return
      end
      if now > voting.deadline then
        rf.votehalt("Respawn unavailable; waiting for next vote", true)
      else
        voting.status = "Waiting for server character respawn"
      end
      return
    end
    voting.stage = "ready"
    voting.oldcharacter = nil
    voting.camerapeeked = false
    voting.nextattempt = now
  end
  if voting.stage == "voting" then
    if rf.voteobserved(voting.attemptserial) then
      rf.votefinish(voting.attemptserial, true)
    elseif now - voting.attemptstarted >= voting.timeoutseconds then
      rf.votetimeout(voting.attemptserial)
    elseif rf.motionowner() ~= "autovote" then
      voting.attemptserial += 1
      rf.votereleasecontact()
      voting.stage = "ready"
      voting.nextattempt = now + 0.08
      voting.status = "Movement interrupted; returning to vote pad"
    end
    return
  end
  if now < voting.nextattempt then return end
  if not character or not root or not humanoid or humanoid.Health <= 0 then
    voting.status = "Waiting for living character"
    return
  end
  if rf.localisinround() then
    voting.status = "Waiting for the lobby"
    return
  end
  if state.autokill.active and rf.autokillstop then
    rf.autokillstop("paused for voting", true)
  end
  if not rf.motionacquire("autovote") then
    voting.status = "Waiting for movement control"
    return
  end
  local detector = selected and selected.detector
  if not detector or not detector.Parent then
    rf.votehalt("Voting pad unavailable", true)
    return
  end
  voting.stage = "voting"
  voting.status = "Voting " .. tostring(voting.attempts + 1) .. " time(s) for " .. selected.name
  voting.attemptserial += 1
  local serial = voting.attemptserial
  voting.attemptstarted = os.clock()
  rf.votereleasecontact()
  voting.collisions = nil
  voting.baselines = {}
  local sources = {}
  if selected.votecount then sources[#sources + 1] = selected.votecount end
  if selected.votelabel then sources[#sources + 1] = selected.votelabel end
  for _, object in ipairs(sources) do
    if object and object.Parent then
      local baseline = rf.votereadcount(object)
      if baseline ~= nil then
        voting.baselines[object] = baseline
        local property = object:IsA("TextLabel") and "Text" or "Value"
        local connection = object:GetPropertyChangedSignal(property):Connect(function()
          if serial ~= voting.attemptserial or voting.stage ~= "voting" then return end
          local count = rf.votereadcount(object)
          if count and count > baseline then
            rf.votefinish(serial, true)
          end
        end)
        voting.voteconnections[#voting.voteconnections + 1] = connection
      end
    end
  end
  voting.voteconnections[#voting.voteconnections + 1] = detector.Touched:Connect(function(hit)
    if hit and hit:IsDescendantOf(character) then rf.votecontact(serial) end
  end)
  local position = detector.Position + Vector3.new(0, 1.65, 0)
  local moved = pcall(function()
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    local frame = CFrame.new(position) * root.CFrame.Rotation
    rf.voidmarkteleport(character, frame, 1)
    root.CFrame = frame
  end)
  if not moved then
    rf.votehalt("Could not reach voting pad", true)
    return
  end
  rf.voteholdstart(serial, character, root, detector)
  local touch = type(firetouchinterest) == "function" and firetouchinterest
    or type(env.firetouchinterest) == "function" and env.firetouchinterest or nil
  if type(touch) == "function" then
    local touchparts = {root}
    for _, name in ipairs({"LeftFoot", "RightFoot", "Left Leg", "Right Leg", "Torso", "UpperTorso"}) do
      local part = character:FindFirstChild(name)
      if part and part:IsA("BasePart") then touchparts[#touchparts + 1] = part end
    end
    for _, part in ipairs(touchparts) do
      if serial ~= voting.attemptserial or voting.stage ~= "voting" then break end
      pcall(touch, part, detector, 0)
      pcall(touch, part, detector, 1)
    end
  end
  rf.votecontact(serial)
  rf.delay(voting.timeoutseconds, function()
    rf.votetimeout(serial)
  end)
end

function rf.motionqueuereturn(kind, reason)
  motionqueue.returnkind = kind
  motionqueue.returncharacter = localplayer.Character
  motionqueue.returnround = state.roundstartedat
  motionqueue.returnmap = state.maproot
  motionqueue.returnhome = kind == "home"
  motionqueue.returndestination = kind == "destination" and reason or nil
end

function rf.motionclearreturn()
  motionqueue.returnkind = nil
  motionqueue.returncharacter = nil
  motionqueue.returnround = nil
  motionqueue.returnmap = nil
  motionqueue.returnhome = false
  motionqueue.returndestination = nil
end

function rf.motiondrain()
  if rf.motionowner() ~= nil then return false end
  local kind = motionqueue.returnkind
  local reason = motionqueue.returndestination
  local eligible = kind and motionqueue.returncharacter == localplayer.Character
    and motionqueue.returnround == state.roundstartedat
    and motionqueue.returnmap == state.maproot and rf.farmcanrestorehome()
  rf.motionclearreturn()
  if eligible and kind == "home" then
    rf.farmrestorehome()
    if not flags.autofarm then farm.home = nil end
  elseif eligible and kind == "destination" and flags.autofarm then
    rf.farmreturndestination(reason)
  end
  if motionqueue.queuedcollect then
    motionqueue.queuedcollect = false
    farm.nextscan = 0
  end
  return true
end

function rf.enforcewalkspeed()
  local character = localplayer.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  if not humanoid then return end
  if state.walkspeedcharacter ~= humanoid then
    state.walkspeedcharacter = humanoid
    local native = humanoid.WalkSpeed
    if native and native > 0 then
      state.walkspeedoriginals[humanoid] = native
      walkspeeds.Default = native
      config.defaultwalkspeed = native
    end
  end
  if humanoid.Health <= 0 then return end
  local session = farm.session
  local locked = session and session.humanoid == humanoid and session.locked
  local wanted = locked and 0 or (walkspeeds[config.walkspeedpreset] or walkspeeds.Default)
  if humanoid.WalkSpeed ~= wanted then humanoid.WalkSpeed = wanted end
end

function rf.setwalkspeed(mode)
  if not walkspeeds[mode] then return false end
  config.walkspeedpreset = mode
  rf.enforcewalkspeed()
  savepreferences()
  return true
end

function rf.cyclewalkspeed()
  local index = table.find(speedorder, config.walkspeedpreset) or 1
  return rf.setwalkspeed(speedorder[index % #speedorder + 1])
end

rf.enforcewalkspeed()
table.insert(state.connections, localplayer.CharacterAdded:Connect(function(character)
  rf.spawn(function()
    local humanoid = character:WaitForChild("Humanoid", 10)
    if state.alive and humanoid and localplayer.Character == character then
      rf.enforcewalkspeed()
    end
  end)
end))

function rf.collisionbusy(part)
  local pickup = state.pickupjob
  if pickup and pickup.character and part:IsDescendantOf(pickup.character) then return true end
  if state.autokill.active and part == state.autokill.root then return true end
  if voting and voting.collisions and voting.collisions[part] ~= nil then return true end
  return false
end

function rf.stopnoclip()
  local noclip = state.noclip
  if noclip.added then noclip.added:Disconnect() noclip.added = nil end
  for part, watcher in pairs(noclip.watches) do
    watcher:Disconnect()
    noclip.watches[part] = nil
  end
  local session = farm.session
  for part, original in pairs(noclip.originals) do
    if part.Parent and not rf.collisionbusy(part)
      and not (session and session.locked and part:IsDescendantOf(session.character)) then
      pcall(function() part.CanCollide = original end)
    elseif session and session.collisions[part] == nil then
      session.collisions[part] = original
    end
    noclip.originals[part] = nil
  end
  noclip.character = nil
end

function rf.tracknoclip(part)
  local noclip = state.noclip
  if not part:IsA("BasePart") or noclip.watches[part] then return end
  local session = farm.session
  local original = session and session.collisions[part]
  if original == nil then original = part.CanCollide end
  noclip.originals[part] = original
  noclip.watches[part] = part:GetPropertyChangedSignal("CanCollide"):Connect(function()
    if state.alive and not noclip.suppressed and noclip.character and part:IsDescendantOf(noclip.character) and part.CanCollide then
      part.CanCollide = false
    end
  end)
  if part.CanCollide then part.CanCollide = false end
end

function rf.farmnoclipallowed()
  if not state.alive or not flags.autofarm or not config.autofarmnoclip
    or state.endlock or state.victoryactive or state.farmkilledround
    or not rf.localisinround() or rf.localisdead() then return false end
  local character = localplayer.Character
  local root = character and character:FindFirstChild("HumanoidRootPart")
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  if not root or not humanoid or humanoid.Health <= 0 then return false end
  local cache = state.noclip
  local now = os.clock()
  if cache.coincharacter ~= character or cache.coinround ~= state.roundstartedat
    or now >= (cache.nextcoincheck or 0) then
    cache.coincharacter = character
    cache.coinround = state.roundstartedat
    cache.nextcoincheck = now + 0.17
    cache.coininlobby = rf.voidlobbyspawn(root.Position)
  end
  return cache.coininlobby ~= true
end

function rf.enforcenoclip()
  if state.autofling and state.autofling.active then return end
  local noclip = state.noclip
  noclip.autoenabled = rf.farmnoclipallowed()
  noclip.suppressed = not rf.noclipwanted()
  if noclip.suppressed then
    if noclip.character then rf.stopnoclip() end
    return
  end
  local character = localplayer.Character
  if noclip.character ~= character then
    rf.stopnoclip()
    noclip.character = character
    if character then
      noclip.added = character.DescendantAdded:Connect(function(part)
        if state.alive and rf.noclipwanted() and noclip.character == character then
          rf.tracknoclip(part)
        end
      end)
      for _, part in ipairs(character:GetDescendants()) do rf.tracknoclip(part) end
    end
  end
  if character then
    for part in pairs(noclip.originals) do
      if part:IsDescendantOf(character) and part.CanCollide then part.CanCollide = false end
    end
  end
end


function rf.applynoclip()
  local noclip = state.noclip
  noclip.autoenabled = rf.farmnoclipallowed()
  local enabled = rf.noclipwanted()
  local changed = noclip.suppressed == enabled
  config.manualnoclip = noclip.manualenabled
  config.persistnoclip = noclip.manualenabled
  noclip.suppressed = not enabled
  if changed then
    rf.enforcenoclip()
    rf.updatecollisions()
    if flags.autofarm and rf.localisinround() then
      farm.nextscan = 0
      farm.status = enabled and (farm.full and "coin bag full" or "searching for coins")
        or "paused while noclip is disabled"
    end
    rf.updatehud()
  end
  return enabled
end

function rf.setglobalnoclip(enabled)
  enabled = enabled == true
  state.noclip.manualenabled = enabled
  rf.applynoclip()
  rf.updatehud()
  savepreferences()
  return enabled
end

function rf.setautofarmnoclip(enabled)
  enabled = enabled == true
  config.autofarmnoclip = enabled
  state.noclip.autoenabled = rf.farmnoclipallowed()
  rf.applynoclip()
  rf.updatehud()
  savepreferences()
  return enabled
end

function rf.farmreleasenoclip()
  local noclip = state.noclip
  noclip.autoenabled = false
  noclip.nextcoincheck = 0
  rf.applynoclip()
end

function rf.farmcoinautoclip(observed)
  local allowed = rf.farmnoclipallowed()
  if state.noclip.autoenabled ~= allowed then
    state.noclip.autoenabled = allowed
    rf.applynoclip()
  end
  return allowed
end

function rf.farmcancel()
  local segment = farm.segment
  farm.segment = nil
  if not segment then return end
  if segment.completed then segment.completed:Disconnect() end
  if segment.tween then pcall(function() segment.tween:Cancel() end) end
end

function rf.farmcanrestorehome()
  if not state.alive or not state.round or state.endlock or state.victoryactive
    or state.farmkilledround or not rf.localisinround() or rf.localisdead() then return false end
  local character = localplayer.Character
  local root = character and character:FindFirstChild("HumanoidRootPart")
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  if not root or not humanoid or humanoid.Health <= 0 then return false end
  if rf.voidlobbyspawn(root.Position) then return false end
  return true
end

function rf.farmcapturehome(character)
  character = character or localplayer.Character
  if character ~= localplayer.Character or not rf.farmcanrestorehome() then return end
  local root = character and character:FindFirstChild("HumanoidRootPart")
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  if not root or not humanoid or humanoid.Health <= 0 then return end
  if root.Position.Y <= world.FallenPartsDestroyHeight + 35 then return end
  local safe = state.voidsafe
  local frame = safe and safe.maproot == state.maproot
    and safe.round == state.roundstartedat and safe.mapframe
  if typeof(frame) ~= "CFrame" then frame = character:GetPivot() end
  if not farm.home or farm.home.character ~= character then
    farm.home = {character = character, pivot = frame}
  elseif typeof(safe and safe.mapframe) == "CFrame" and safe.maproot == state.maproot
    and safe.round == state.roundstartedat then
    farm.home.pivot = safe.mapframe
  end
end

function rf.farmrestorehome()
  if not rf.farmcanrestorehome() then return false end
  local home = farm.home
  if not home or home.character ~= localplayer.Character or not home.character.Parent then return false end
  local root = home.character:FindFirstChild("HumanoidRootPart")
  local humanoid = home.character:FindFirstChildOfClass("Humanoid")
  if not root or not humanoid or humanoid.Health <= 0 then return false end
  local safe = state.voidsafe
  local destination = safe and safe.maproot == state.maproot
    and safe.round == state.roundstartedat and safe.mapframe or home.pivot
  if typeof(destination) ~= "CFrame" or rf.voidlobbyspawn(destination.Position) then return false end
  local success = pcall(function()
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    rf.teleportpivot(home.character, destination)
  end)
  return success
end

function rf.farmlobbyframe()
  local lobby = world:FindFirstChild("RegularLobby") or world:FindFirstChild("Lobby")
  if not lobby then return nil end
  local spawns = lobby:FindFirstChild("Spawns") or lobby:FindFirstChild("Spawns", true)
  if not spawns then return nil end
  local respawn = localplayer.RespawnLocation
  if rf.voidislobbyspawn(respawn) then
    return CFrame.new(respawn.Position + Vector3.new(0, 4, 0))
  end
  local root = localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
  local nearest, distance
  for _, part in ipairs(rf.voidcachedspawns and rf.voidcachedspawns() or spawns:GetDescendants()) do
    if part:IsA("BasePart") then
      local delta = root and (root.Position - part.Position).Magnitude or 0
      if not distance or delta < distance then nearest, distance = part, delta end
    end
  end
  return nearest and CFrame.new(nearest.Position + Vector3.new(0, 4, 0)) or nil
end

function rf.farmreturndestination(reason)
  if not rf.farmcanrestorehome() then
    rf.motionclearreturn()
    return false
  end
  local enabled, destination
  if reason == "full" then
    enabled, destination = config.farmreturnfull, config.farmfulldestination
  else
    enabled, destination = config.farmreturnfinished, config.farmfinishdestination
  end
  if not enabled or destination == "Stay" or not farm.home then return false end
  if rf.motionowner() and rf.motionowner() ~= "autofarm" then
    rf.motionqueuereturn("destination", reason)
    return true
  end
  if destination == "Start" then
    return rf.farmrestorehome()
  end
  if destination ~= "Lobby" then return false end
  local character = localplayer.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  local root = character and character:FindFirstChild("HumanoidRootPart")
  if not root or not humanoid or humanoid.Health <= 0 then return false end
  local target = rf.farmlobbyframe()
  if not target then
    rf.farmrestorehome()
    return false
  end
  local offset = root.CFrame:ToObjectSpace(character:GetPivot())
  pcall(function()
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    rf.teleportpivot(character, target * offset)
  end)
  return true
end

function rf.farmcollision(session, part)
  if state.noclip.suppressed or not part:IsA("BasePart") then return end
  if session.collisions[part] == nil then
    local original = state.noclip.originals[part]
    if original == nil then original = part.CanCollide end
    session.collisions[part] = original
  end
  if session.touches[part] == nil then session.touches[part] = part.CanTouch end
  part.CanCollide = false
  if part == session.root then part.CanTouch = true end
end

function rf.farmnoclip(session)
  if state.noclip.suppressed or farm.session ~= session or not session.character.Parent then return end
  for part in pairs(session.collisions) do
    if part.Parent and part.CanCollide then part.CanCollide = false end
  end
end

function rf.farmsetlocked(session, enabled)
  if session.locked == enabled then return end
  session.locked = enabled
  if session.gravity and session.gravity.Parent then session.gravity.Enabled = enabled end
  if enabled then
    if session.humanoid.Parent then
      session.humanoid.PlatformStand = true
      session.humanoid.AutoRotate = false
      session.humanoid:Move(Vector3.zero, false)
    end
    rf.farmnoclip(session)
  else
    if session.humanoid.Parent then
      session.humanoid.PlatformStand = session.platformstand
      session.humanoid.AutoRotate = session.autorotate
    end
  end
  rf.enforcewalkspeed()
end

function rf.farmstop(returnposition)
  local shouldrestore = returnposition == true and rf.farmcanrestorehome()
  local session = farm.session
  farm.nohighlightssince = nil
  farm.session, farm.target = nil, nil
  rf.farmcancel()
  if session then
    session.locked = false
    if session.added then session.added:Disconnect() end
    if session.post then session.post:Disconnect() end
    if session.gravity then session.gravity:Destroy() end
    if session.attachment then session.attachment:Destroy() end
    for part, original in pairs(session.touches) do
      if part.Parent then pcall(function() part.CanTouch = original end) end
    end
    for part, original in pairs(session.collisions) do
      if part.Parent and (state.noclip.suppressed or not rf.noclipwanted()) then
        pcall(function() part.CanCollide = original end)
      end
    end
    if session.root.Parent then
      pcall(function()
        session.root.Anchored = session.wasanchored
        session.root.AssemblyLinearVelocity = Vector3.zero
        session.root.AssemblyAngularVelocity = Vector3.zero
      end)
    end
    if session.humanoid.Parent then
      pcall(function()
        session.humanoid.PlatformStand = session.platformstand
        session.humanoid.AutoRotate = session.autorotate
        if session.humanoid.Health > 0 and not session.platformstand then
          session.humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
      end)
    end
  end
  rf.enforcewalkspeed()
  rf.motionrelease("autofarm")
  if rf.enforcenoclip then rf.enforcenoclip() end
  if shouldrestore then
    if rf.motionowner() and rf.motionowner() ~= "autofarm" then
      if farm.home then rf.motionqueuereturn("home") end
    else
      rf.farmrestorehome()
    end
  elseif returnposition then
    rf.motionclearreturn()
  end
  if not flags.autofarm and not motionqueue.returnkind then farm.home = nil end
  farm.status = flags.autofarm and "searching for coins" or "off"
end

farm.suspend = function(returnposition)
  if farm.session then rf.farmstop(returnposition ~= false) end
  farm.nextscan = os.clock() + 0.08
  if flags.autofarm then farm.status = "waiting for gun pickup" end
end

function rf.farmcancelreturn()
  farm.returning = nil
end

function rf.farmshowafterfull(restore)
  local hidden = farm.hide
  if not hidden then return end
  farm.hide = nil
  local character, root, humanoid = hidden.character, hidden.root, hidden.humanoid
  if not root or not root.Parent or character ~= localplayer.Character then return end
  if restore ~= false and rf.farmcanrestorehome()
    and character.Parent and humanoid.Parent and humanoid.Health > 0 then
    pcall(function() rf.teleportpivot(character, hidden.origin) end)
  end
  root.Anchored = hidden.anchored
  root.AssemblyLinearVelocity = Vector3.zero
  root.AssemblyAngularVelocity = Vector3.zero
  if humanoid.Parent then humanoid.AutoRotate = hidden.autorotate end
end

function rf.farmhidewhenfull()
  if config.farmresetfull or not config.farmhidefull or not flags.autofarm or not state.alive or not state.round
    or state.endlock or rf.localisdead() then return false end
  local owner = rf.motionowner()
  if owner and owner ~= "autofarm" then
    if farm.hide then rf.farmshowafterfull(true) end
    farm.status = "queued behind " .. tostring(owner)
    return false
  end
  if farm.hide then return true end
  local character = localplayer.Character
  local root = character and character:FindFirstChild("HumanoidRootPart")
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  if not root or not humanoid or humanoid.Health <= 0 then return false end
  rf.farmcapturehome(character)
  local session = farm.session
  local final = session and session.coinpart and session.coinpart.Parent and session.coinpart.Position
    or farm.lastcoinposition
  if typeof(final) ~= "Vector3" then final = root.Position end
  farm.lastcoinposition = final
  if state.autoshoothover and rf.autoshootstophover then rf.autoshootstophover(true) end
  if farm.session then rf.farmstop(false) end
  local original = character:GetPivot()
  local offset = root.CFrame:ToObjectSpace(original)
  local hidden = {character = character, root = root, humanoid = humanoid,
    origin = original, anchored = root.Anchored, autorotate = humanoid.AutoRotate,
    final = final, pivot = offset}
  farm.hide = hidden
  humanoid.AutoRotate = false
  root.Anchored = true
  local location = final + Vector3.new(0, 2500, 0)
  local direction = root.CFrame.LookVector
  local horizontal = Vector3.new(direction.X, 0, direction.Z)
  local frame = horizontal.Magnitude > 0.001 and CFrame.lookAt(location, location + horizontal.Unit)
    or CFrame.new(location)
  pcall(function()
    rf.teleportpivot(character, frame * offset)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
  end)
  farm.status = "hidden 2500 studs above final coin"
  return true
end

function rf.farmkeephidden()
  local hidden = farm.hide
  if not hidden then return false end
  local owner = rf.motionowner()
  if owner and owner ~= "autofarm" then
    rf.farmshowafterfull(true)
    return false
  end
  if not state.alive or not flags.autofarm or not config.farmhidefull or config.farmresetfull or not farm.full
    or not state.round or state.endlock or rf.localisdead()
    or hidden.character ~= localplayer.Character or not hidden.root.Parent then
    rf.farmshowafterfull(true)
    return false
  end
  if not hidden.root.Anchored then hidden.root.Anchored = true end
  hidden.root.AssemblyLinearVelocity = Vector3.zero
  hidden.root.AssemblyAngularVelocity = Vector3.zero
  farm.status = "hidden 2500 studs above final coin"
  return true
end

function rf.farmresetwhenfull()
  if not state.alive or not flags.autofarm or not config.farmresetfull or not farm.full
    or not state.round or state.endlock or not state.roundstartparticipant
    or not state.roundstartobserved then return false end
  local round = state.roundstartedat
  if type(round) ~= "number" or round <= 0 then return false end
  if farm.fullresetround == round then
    farm.status = "bag full; waiting for next round"
    return true
  end
  local owner = rf.motionowner()
  if owner and owner ~= "autofarm" then
    farm.status = "full bag; waiting for " .. tostring(owner) .. " before reset"
    return true
  end
  local character = localplayer.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  if not humanoid or humanoid.Health <= 0 then
    farm.status = "waiting for live character"
    return true
  end
  farm.fullresetround = round
  farm.returnedfull = true
  if farm.hide then rf.farmshowafterfull(true) end
  if farm.session then rf.farmstop(false) end
  if rf.motionowner() == "autofarm" then rf.motionrelease("autofarm", true) end
  farm.status = "resetting after full bag"
  rf.notification("Auto Collect", "Bag full; resetting character", nil,
    "rotate-ccw", Color3.fromRGB(255, 217, 117), "autofarm:resetfull:" .. tostring(round))
  local ok = pcall(function()
    humanoid.Health = 0
    humanoid:ChangeState(Enum.HumanoidStateType.Dead)
  end)
  if not ok or humanoid.Health > 0 then
    pcall(function() character:BreakJoints() end)
  end
  return true
end

function rf.farmfinishfullbag()
  if not state.alive or not flags.autofarm then return end
  farm.full = true
  if config.farmresetfull then
    rf.farmresetwhenfull()
    return
  end
  local owner = rf.motionowner()
  if owner and owner ~= "autofarm" then
    if farm.hide then rf.farmshowafterfull(true) end
    if farm.session then rf.farmstop(false) end
    farm.status = "full bag; waiting for " .. tostring(owner)
    return
  end
  if config.farmhidefull and rf.farmhidewhenfull() then
    farm.returnedfull = true
    return
  end
  if farm.session then rf.farmstop(false) end
  if not farm.returnedfull then
    farm.returnedfull = true
    rf.farmreturndestination("full")
  end
  farm.status = "coin bag full"
end

rf.resources.fullhudcache = {labels = {}, lastindex = 0, playergui = nil, lastresult = false, lastcheck = 0}

function rf.farmhudfull()
  local gui = localplayer:FindFirstChildOfClass("PlayerGui")
  if not gui then return false end
  local now = os.clock()
  if rf.resources.fullhudcache.playergui ~= gui or now - rf.resources.fullhudcache.lastindex >= 4 then
    rf.resources.fullhudcache.labels = {}
    rf.resources.fullhudcache.lastindex = now
    rf.resources.fullhudcache.playergui = gui
    for _, object in ipairs(gui:GetDescendants()) do
      if object:IsA("TextLabel") or object:IsA("TextButton") then
        local path = object:GetFullName():lower()
        if path:find("bag", 1, true) or path:find("coin", 1, true)
          or path:find("inventory", 1, true) or path:find("capacity", 1, true) then
          rf.resources.fullhudcache.labels[#rf.resources.fullhudcache.labels + 1] = object
        end
      end
    end
  end
  if now - rf.resources.fullhudcache.lastcheck < 0.18 then return rf.resources.fullhudcache.lastresult end
  rf.resources.fullhudcache.lastcheck = now
  local camera = world.CurrentCamera
  local viewport = camera and camera.ViewportSize or Vector2.new(1600, 900)
  for _, object in ipairs(rf.resources.fullhudcache.labels) do
    if object.Parent then
      local value = tostring(object.Text or ""):lower():gsub("<[^>]+>", "")
        :gsub("%s+", " "):match("^%s*(.-)%s*$")
      if value == "full!" or value == "full" or value == "bag full" or value == "coin bag full" then
        local visible = true
        local parent = object
        while parent and parent ~= gui do
          if parent:IsA("GuiObject") and not parent.Visible then visible = false break end
          if parent:IsA("LayerCollector") and not parent.Enabled then visible = false break end
          parent = parent.Parent
        end
        if visible and object.AbsoluteSize.X > 0 and object.AbsoluteSize.Y > 0 then
          local center = object.AbsolutePosition + object.AbsoluteSize * 0.5
          if value == "coin bag full" or value == "bag full"
            or (center.X >= viewport.X * 0.55 and center.Y >= viewport.Y * 0.4) then
            rf.resources.fullhudcache.lastresult = true
            return true
          end
        end
      end
    end
  end
  rf.resources.fullhudcache.lastresult = false
  return false
end

function rf.farmcheckfull(force)
  if farm.full and farm.fullround == state.roundstartedat and state.roundstartedat > 0 then return true end
  if not state.alive or not state.round or state.endlock or not state.roundstartparticipant then return false end
  local now = os.clock()
  if not force and now < (farm.nextfullcheck or 0) then return false end
  farm.nextfullcheck = now + 0.24
  if rf.autokillbagfull() then return true end
  local bag = state.bagstate
  if type(bag.count) == "number" and type(bag.capacity) == "number"
    and bag.count < bag.capacity and now - bag.updated < 1.5 then return false end
  if rf.farmhudfull() then return rf.bagobserve(nil, nil, "hud", true) end
  return false
end

function rf.farmvalid()
  if farm.full then return false end
  if not state.alive or not flags.autofarm or state.pickupbusy or farm.full
    or not state.roundstartobserved or not state.roundstartparticipant
    or state.farmkilledround or not rf.localisinround() or rf.localisdead()
    or rf.victoryisshown() then return false end
  local character = localplayer.Character
  local root = character and character:FindFirstChild("HumanoidRootPart")
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  if not root or not humanoid or humanoid.Health <= 0 then return false end
  return true, character, root, humanoid
end

function rf.farmplayerpositions()
  local cache = farm.playerpositions
  local now = os.clock()
  if cache and now - cache.updated < 0.045 then return cache.positions end
  local positions = {}
  local names = {"HumanoidRootPart", "UpperTorso", "Torso", "LowerTorso", "LeftFoot", "RightFoot", "Left Leg", "Right Leg"}
  for _, candidate in ipairs(players:GetPlayers()) do
    if candidate ~= localplayer then
      local character = candidate.Character
      local humanoid = character and character:FindFirstChildOfClass("Humanoid")
      if humanoid and humanoid.Health > 0 then
        for _, name in ipairs(names) do
          local part = character:FindFirstChild(name)
          if part and part:IsA("BasePart") then
            positions[#positions + 1] = part.Position
          end
        end
      end
    end
  end
  farm.playerpositions = {updated = now, positions = positions}
  return positions
end

function rf.farmcoinoccupied(position)
  for _, point in ipairs(rf.farmplayerpositions()) do
    local difference = position - point
    if difference:Dot(difference) <= 9 then return true end
  end
  return false
end

function rf.farmcoineligible(object, part)
  if farm.full then return false end
  if state.coinroundhidden or state.coinhidden[object] or not object or not part then return false end
  if not rf.iscoinvisual(object) or not part:IsDescendantOf(object) and part ~= object then return false end
  if rf.farmcoinoccupied(part.Position) then return false end
  local visual = state.coinvisuals[object]
  if not visual then return false end
  for _, link in ipairs(visual.links) do
    if link.source == part and part.Parent then return true end
  end
  return false
end

function rf.farmcoinpoint(object, part)
  if not rf.farmcoineligible(object, part) then return nil end
  return part.Position
end

function rf.farmrootpoint(session)
  return session and session.coinpart and rf.farmcoinpoint(session.coin, session.coinpart) or nil
end

function rf.farmselectcoin(root)
  local best, selected, closest
  local origin = root.Position
  local now = os.clock()
  for object, visual in pairs(state.coinvisuals) do
    if (farm.blocked[object] or 0) <= now and not state.coinhidden[object]
      and rf.iscoinvisual(object) then
      for _, link in ipairs(visual.links) do
        local part = link.source
        if part and rf.farmcoineligible(object, part) then
          local distance = (part.Position - origin).Magnitude
          if not closest or distance < closest then
            best, selected, closest = object, part, distance
          end
        end
      end
    end
  end
  return best, selected, closest
end

function rf.farmissheriff(candidate)
  if not candidate or candidate == localplayer or candidate.Parent ~= players then return false end
  local entry = state.authoritative[candidate.UserId] or rf.getrecord(candidate)
  if not entry or entry.Dead == true or entry.Killed == true then return false end
  if state.synced and state.participants[candidate.UserId] ~= true then return false end
  local role = rf.normalize_role(entry.Role)
  if role ~= "Sheriff" and role ~= "Hero" then return false end
  local character = candidate.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  local root = character and character:FindFirstChild("HumanoidRootPart")
  return humanoid ~= nil and humanoid.Health > 0 and root ~= nil
end

rf.resources.fxroot = nil

function rf.farmtrackbeam(beam)
  if not beam or not beam:IsA("Beam") then return end
  local attachment = beam.Attachment0
  local secondary = beam.Attachment1
  if not attachment or not secondary then return end
  for _, candidate in ipairs(players:GetPlayers()) do
    if rf.farmissheriff(candidate) then
      local character = candidate.Character
      local root = character and character:FindFirstChild("HumanoidRootPart")
      local start = attachment.WorldPosition
      local finish = secondary.WorldPosition
      local endpointnear = root and math.min((start - root.Position).Magnitude,
        (finish - root.Position).Magnitude) <= 12
      local name = beam.Name:lower()
      local projectile = name:find("bullet", 1, true) or name:find("shot", 1, true)
        or name:find("gun", 1, true) or name:find("ray", 1, true)
      if beam:IsDescendantOf(character) or attachment:IsDescendantOf(character)
        or secondary:IsDescendantOf(character)
        or (projectile and endpointnear and (finish - start).Magnitude > 2
          and not beam:IsDescendantOf(rf.resources.fxroot)) then
        farm.externalbeams[beam] = candidate
        return
      end
    end
  end
end

function rf.farmbeamclosest(point, origin, destination)
  local segment = destination - origin
  local length = segment:Dot(segment)
  if length < 0.0001 then return origin end
  local alpha = math.clamp((point - origin):Dot(segment) / length, 0, 1)
  return origin + segment * alpha
end

function rf.farmbeamdistance(point, origin, destination)
  return (point - rf.farmbeamclosest(point, origin, destination)).Magnitude
end

function rf.farmrecordgunshot(handle, start, finish)
  if not state.alive or not flags.autofarm or not state.round then return end
  local origin = rf.resolveorigin(start) or rf.resolveorigin(handle)
  local destination = rf.resolveorigin(finish)
  if not origin or not destination or (destination - origin).Magnitude < 1 then return end
  local shooter
  if typeof(handle) == "Instance" then
    for _, candidate in ipairs(players:GetPlayers()) do
      if candidate ~= localplayer and candidate.Character and handle:IsDescendantOf(candidate.Character)
        and rf.farmissheriff(candidate) then
        shooter = candidate
        break
      end
    end
  end
  if not shooter then
    local closest = 12
    for _, candidate in ipairs(players:GetPlayers()) do
      if rf.farmissheriff(candidate) then
        local character = candidate.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local muzzle = character and character:FindFirstChild("Gun", true)
        local position = muzzle and muzzle:IsA("BasePart") and muzzle.Position or root and root.Position
        if position then
          local distance = (position - origin).Magnitude
          if distance <= closest then
            shooter, closest = candidate, distance
          end
        end
      end
    end
  end
  if not shooter then return end
  local now = os.clock()
  local shots = farm.gunshots
  shots[#shots + 1] = {origin = origin, destination = destination,
    shooter = shooter, expiry = now + 0.7}
  while #shots > 24 do table.remove(shots, 1) end
end

function rf.farmthreatnear(root)
  if not root or not root.Parent then return nil end
  local origin = root.Position
  local best, urgency
  for _, candidate in ipairs(players:GetPlayers()) do
    local kind, radius
    if rf.autoshootfarvalid(candidate) then
      kind, radius = "murderer", 20
    end
    if radius then
      local character = candidate.Character
      local enemyroot = character and character:FindFirstChild("HumanoidRootPart")
      if enemyroot then
        local distance = (enemyroot.Position - origin).Magnitude
        local score = distance / radius
        if distance <= radius and (not urgency or score < urgency) then
          best, urgency = {kind = kind, root = enemyroot, position = enemyroot.Position,
            player = candidate}, score
        end
      end
    end
  end
  local now = os.clock()
  for beam, shooter in pairs(farm.externalbeams) do
    if not beam.Parent or not rf.farmissheriff(shooter) then
      farm.externalbeams[beam] = nil
    else
      local a, b = beam.Attachment0, beam.Attachment1
      if a and b and a.Parent and b.Parent and beam.Enabled then
        local start, finish = a.WorldPosition, b.WorldPosition
        local distance = rf.farmbeamdistance(origin, start, finish)
        local score = distance / 7
        if distance <= 7 and (not urgency or score < urgency) then
          best, urgency = {kind = "gun beam",
            position = rf.farmbeamclosest(origin, start, finish), beam = beam, player = shooter}, score
        end
      end
    end
  end
  for index = #farm.gunshots, 1, -1 do
    local shot = farm.gunshots[index]
    if now >= shot.expiry or not rf.farmissheriff(shot.shooter) then
      table.remove(farm.gunshots, index)
    else
      local distance = rf.farmbeamdistance(origin, shot.origin, shot.destination)
      local score = distance / 7
      if distance <= 7 and (not urgency or score < urgency) then
        best, urgency = {kind = "gun beam",
          position = rf.farmbeamclosest(origin, shot.origin, shot.destination), shot = shot,
          player = shot.shooter}, score
      end
    end
  end
  return best
end

function rf.farmfurthestcoin(threat)
  if not threat then return nil end
  local threats, lines = {}, {}
  local now = os.clock()
  for _, candidate in ipairs(players:GetPlayers()) do
    local radius
    if rf.autoshootfarvalid(candidate) then radius = 20 end
    if radius then
      local character = candidate.Character
      local enemyroot = character and character:FindFirstChild("HumanoidRootPart")
      if enemyroot then
        threats[#threats + 1] = {position = enemyroot.Position, radius = radius}
      end
    end
  end
  for _, shot in ipairs(farm.gunshots) do
    if now < shot.expiry then
      lines[#lines + 1] = {origin = shot.origin, destination = shot.destination}
    end
  end
  for beam, shooter in pairs(farm.externalbeams) do
    if beam.Parent and beam.Enabled and rf.farmissheriff(shooter) then
      local a, b = beam.Attachment0, beam.Attachment1
      if a and b and a.Parent and b.Parent then
        lines[#lines + 1] = {origin = a.WorldPosition, destination = b.WorldPosition}
      end
    end
  end
  local best, selected, furthest = nil, nil, -math.huge
  for object, visual in pairs(state.coinvisuals) do
    if (farm.blocked[object] or 0) <= now and not state.coinhidden[object]
      and rf.iscoinvisual(object) then
      for _, link in ipairs(visual.links) do
        local part = link.source
        if part and rf.farmcoineligible(object, part) then
          local position = part.Position
          local score = (position - threat.position).Magnitude
          for _, source in ipairs(threats) do
            score = math.min(score, (position - source.position).Magnitude * 20 / source.radius)
          end
          for _, line in ipairs(lines) do
            score = math.min(score, rf.farmbeamdistance(position, line.origin, line.destination) * 20 / 7)
          end
          if score > furthest then
            best, selected, furthest = object, part, score
          end
        end
      end
    end
  end
  return best, selected, furthest
end

function rf.farmevadehorizontal(a, b)
  local delta = a - b
  return Vector3.new(delta.X, 0, delta.Z).Magnitude
end

function rf.farmevadeposition(escape)
  if not escape then return nil end
  if escape.kind == "gun beam" then
    local beam = escape.beam
    local shot = escape.shot
    if beam and beam.Parent and beam.Enabled then
      local a, b = beam.Attachment0, beam.Attachment1
      if a and b and a.Parent and b.Parent then
        escape.position = rf.farmbeamclosest(escape.origin, a.WorldPosition, b.WorldPosition)
      end
    elseif shot then
      escape.position = rf.farmbeamclosest(escape.origin, shot.origin, shot.destination)
    end
    return escape.position
  end
  local candidate = escape.player
  local character = candidate and candidate.Character
  local root = character and character:FindFirstChild("HumanoidRootPart")
  if root and root.Parent then escape.position = root.Position end
  return escape.position
end

function rf.farmevadestartsegment(session, position, phase)
  local escape = session.evasion
  if farm.session ~= session or not escape or not session.root.Parent
    or rf.motionowner() ~= "autofarm" then return false end
  rf.farmcancel()
  local root = session.root
  local distance = (position - root.Position).Magnitude
  local direction = position - root.Position
  local horizontal = Vector3.new(direction.X, 0, direction.Z)
  local rotation = horizontal.Magnitude > 0.001
    and CFrame.lookAt(Vector3.zero, horizontal.Unit).Rotation or root.CFrame.Rotation
  session.stage = "evade_" .. phase
  escape.phase = phase
  escape.destination = position
  escape.startedsegment = os.clock()
  session.lastprogress = os.clock()
  session.lastposition = root.Position
  rf.farmsetlocked(session, true)
  rf.farmnoclip(session)
  root.Anchored = false
  if distance < 0.04 then
    session.stage = "evade_hold"
    escape.lastphase = phase
    return true
  end
  local speed = math.clamp(tonumber(config.autofarmtweenspeed) or 20, 10, 24.5)
  local duration = math.max(0.1, distance / speed)
  local tween = tweenservice:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
    CFrame = CFrame.new(position) * rotation
  })
  local segment = {tween = tween, evasion = escape}
  farm.segment = segment
  segment.completed = tween.Completed:Connect(function(status)
    if farm.session ~= session or farm.segment ~= segment
      or session.evasion ~= escape then return end
    farm.segment = nil
    if segment.completed then segment.completed:Disconnect() end
    if status ~= Enum.PlaybackState.Completed then return end
    session.stage = "evade_hold"
    escape.lastphase = phase
  end)
  tween:Play()
  return true
end

function rf.farmevadeupdate(session)
  local escape = session.evasion
  if not escape then return false end
  if farm.session ~= session or rf.motionowner() ~= "autofarm"
    or not session.root.Parent or not session.humanoid.Parent
    or session.humanoid.Health <= 0 then return true end
  local root = session.root
  local threatposition = rf.farmevadeposition(escape)
  if not threatposition then
    session.evasion = nil
    rf.farmcancel()
    session.stage = "idle"
    return false
  end
  local distance = rf.farmevadehorizontal(root.Position, threatposition)
  local clearance = rf.farmevadehorizontal(root.Position, escape.origin)
  if distance >= 50 and clearance >= 50 then
    rf.farmcancel()
    session.evasion = nil
    session.stage = "idle"
    session.coin, session.coinpart = nil, nil
    farm.target = nil
    farm.evadenext = os.clock() + 1.2
    farm.nextscan = 0
    rf.farmsetlocked(session, false)
    farm.status = "50 studs clear; resuming nearest coin"
    return false
  end
  if session.stage == "evade_drop" or session.stage == "evade_travel"
    or session.stage == "evade_extend" then
    farm.status = "evading " .. escape.kind .. "; " .. math.floor(distance) .. "/50 studs"
    return true
  end
  if session.stage ~= "evade_hold" then return true end
  local point = escape.coinpart
  if escape.lastphase == "drop" then
    if not rf.farmcoineligible(escape.coin, point) then
      local updated, updatedpart = rf.farmfurthestcoin({position = threatposition})
      escape.coin, escape.coinpart = updated, updatedpart
      point = updatedpart
    end
    if point and point.Parent then
      local target = point.Position - Vector3.new(0, 10, 0)
      farm.target = escape.coin
      rf.farmevadestartsegment(session, target, "travel")
      return true
    end
  end
  local horizontal = root.Position - threatposition
  horizontal = Vector3.new(horizontal.X, 0, horizontal.Z)
  if horizontal.Magnitude < 0.1 then
    local facing = root.CFrame.LookVector
    horizontal = Vector3.new(-facing.X, 0, -facing.Z)
  end
  if horizontal.Magnitude < 0.1 then horizontal = Vector3.new(1, 0, 0) end
  local remaining = math.max(12, 56 - math.min(distance, clearance))
  local destination = root.Position + horizontal.Unit * remaining
  escape.extensions = (escape.extensions or 0) + 1
  if escape.extensions > 8 or os.clock() - escape.started > 25 then
    session.evasion = nil
    rf.farmcancel()
    session.stage = "idle"
    farm.evadenext = os.clock() + 1.25
    farm.nextscan = 0
    rf.farmsetlocked(session, false)
    farm.status = "evasion interrupted; resuming coin search"
    return false
  end
  rf.farmevadestartsegment(session, destination, "extend")
  return true
end

function rf.farmevadethreat(session)
  if farm.session ~= session or not flags.autofarm
    or session.evasion or session.stage ~= "moving" and session.stage ~= "touching"
    or os.clock() < (farm.evadenext or 0)
    or rf.motionowner() ~= "autofarm" or not session.root.Parent
    or not session.humanoid.Parent or session.humanoid.Health <= 0 then return false end
  local threat = rf.farmthreatnear(session.root)
  if not threat then return false end
  local object, part = rf.farmfurthestcoin(threat)
  if not object or not part or not part.Parent then
    farm.status = threat.kind .. " nearby; no eligible distant coin"
    farm.evadenext = os.clock() + 0.35
    return false
  end
  local origin = session.root.Position
  rf.farmcancel()
  if farm.session ~= session or rf.motionowner() ~= "autofarm" then return false end
  session.coin, session.coinpart = nil, nil
  session.centercontact = false
  session.evasion = {
    kind = threat.kind, player = threat.player, position = threat.position,
    beam = threat.beam, shot = threat.shot,
    origin = origin, coin = object, coinpart = part, started = os.clock(), extensions = 0
  }
  farm.target = object
  farm.evadenext = os.clock() + 1.25
  farm.status = "descending 10 studs to escape " .. threat.kind
  return rf.farmevadestartsegment(session, origin - Vector3.new(0, 10, 0), "drop")
end

function rf.farmhashighlights()
  if state.coinroundhidden then return false end
  for object, visual in pairs(state.coinvisuals) do
    if not state.coinhidden[object] and rf.iscoinvisual(object) then
      for _, link in ipairs(visual.links) do
        if link.source and link.source.Parent then return true end
      end
    end
  end
  return false
end

function rf.farmstart(character, root, humanoid)
  if farm.full or state.noclip.suppressed then return nil end
  if farm.session then return farm.session end
  local session = {
    character = character, root = root, humanoid = humanoid,
    collisions = {}, touches = {}, wasanchored = root.Anchored,
    platformstand = humanoid.PlatformStand, autorotate = humanoid.AutoRotate,
    locked = false, coin = nil, coinpart = nil, centercontact = false,
    stage = "idle", arrived = 0, lastprogress = os.clock(),
    lastposition = root.Position, baselinestamp = farm.eventstamp or 0
  }
  farm.session = session
  for _, part in ipairs(character:GetDescendants()) do rf.farmcollision(session, part) end
  session.added = character.DescendantAdded:Connect(function(part)
    if farm.session == session then rf.farmcollision(session, part) end
  end)
  local attachment = Instance.new("Attachment")
  attachment.Name = "VantaCoinMovement"
  attachment.Parent = root
  local gravity = Instance.new("VectorForce")
  gravity.Name = "VantaCoinGravity"
  gravity.Attachment0 = attachment
  gravity.RelativeTo = Enum.ActuatorRelativeTo.World
  gravity.ApplyAtCenterOfMass = true
  gravity.Force = Vector3.new(0, root.AssemblyMass * world.Gravity, 0)
  gravity.Parent = root
  gravity.Enabled = false
  session.attachment, session.gravity = attachment, gravity
  session.poststep = function()
    if farm.session ~= session or not session.root.Parent then return end
    rf.farmnoclip(session)
    if session.locked and session.humanoid.Parent then
      session.humanoid.PlatformStand = true
      session.humanoid.AutoRotate = false
      session.humanoid:Move(Vector3.zero, false)
      session.gravity.Force = Vector3.new(0, session.root.AssemblyMass * world.Gravity, 0)
      session.root.CanTouch = true
    end
  end
  return session
end

function rf.farmfinishcoin(session)
  if farm.session ~= session then return end
  local object = session.coin
  local collected = session.centercontact and (session.baselinestamp or 0) < (farm.eventstamp or 0)
    or object and not object:IsDescendantOf(world)
  if collected then
    farm.confirmed += 1
    if object then farm.blocked[object] = math.huge end
    farm.status = "coin collected"
  else
    if object then farm.blocked[object] = os.clock() + 1.5 end
    farm.status = "trying next coin"
  end
  session.coin, session.coinpart = nil, nil
  session.centercontact = false
  session.stage = "idle"
  if session.root.Parent then
    session.root.AssemblyLinearVelocity = Vector3.zero
    session.root.AssemblyAngularVelocity = Vector3.zero
  end
  rf.farmsetlocked(session, false)
  farm.target = nil
  farm.nextscan = os.clock() + 0.05
end

function rf.farmarrive(session)
  if farm.session ~= session or session.stage ~= "moving" then return end
  session.stage = "touching"
  session.arrived = os.clock()
  local root, part = session.root, session.coinpart
  if not root.Parent or not part or not part.Parent or rf.farmcoinoccupied(part.Position) then
    rf.farmfinishcoin(session)
    return
  end
  root.Anchored = false
  root.CanTouch = true
  root.CanCollide = false
  local target = part.Position
  local offset = target - root.Position
  if offset.Magnitude > 0.01 then
    local frame = CFrame.new(target) * root.CFrame.Rotation
    rf.voidmarkteleport(session.character, frame, 0.55)
    root.CFrame = frame
  end
  root.AssemblyLinearVelocity = Vector3.zero
  root.AssemblyAngularVelocity = Vector3.zero
  session.centercontact = (root.Position - part.Position).Magnitude <= math.max(0.5, root.Size.Magnitude * 0.5)
  if session.centercontact then
    farm.lastcoinposition = target
    farm.lastcollectmotion = os.clock()
    farm.lastcollectround = state.roundstartedat
    farm.lastcollectcharacter = session.character
  end
  farm.status = "touching coin"
  if session.centercontact then
    local callback = type(firetouchinterest) == "function" and firetouchinterest or env.firetouchinterest
    if type(callback) == "function" then
      pcall(callback, root, part, 0)
      pcall(callback, root, part, 1)
    end
  end
end

function rf.farmstarttween(session, object, part, distance)
  if farm.session ~= session or not rf.farmcoineligible(object, part) then return false end
  if not rf.motionacquire("autofarm") then return false end
  rf.farmcapturehome(session.character)
  rf.farmcancel()
  local root = session.root
  local changed = session.coin ~= object or session.coinpart ~= part
  session.coin, session.coinpart = object, part
  if changed then
    session.baselinestamp = farm.eventstamp or 0
    session.centercontact = false
    farm.attempted += 1
  end
  session.stage = "moving"
  session.lastprogress = os.clock()
  session.lastposition = root.Position
  session.nextretarget = os.clock() + 0.05
  session.retargettime = os.clock()
  farm.target = object
  farm.status = "tweening to nearest coin"
  rf.farmsetlocked(session, true)
  local target = part.Position
  session.lastdestination = target
  local towards = Vector3.new(target.X - root.Position.X, 0, target.Z - root.Position.Z)
  local rotation = towards.Magnitude > 0.001 and CFrame.lookAt(Vector3.zero, towards.Unit).Rotation or root.CFrame.Rotation
  local seconds = math.max(0.025, distance / config.autofarmtweenspeed)
  root.Anchored = false
  rf.voidmarkteleport(session.character, CFrame.new(target) * rotation, 1.1)
  local tween = tweenservice:Create(root, TweenInfo.new(seconds, Enum.EasingStyle.Linear), {
    CFrame = CFrame.new(target) * rotation
  })
  local segment = {tween = tween}
  farm.segment = segment
  segment.completed = tween.Completed:Connect(function(status)
    if farm.segment ~= segment or farm.session ~= session then return end
    farm.segment = nil
    if segment.completed then segment.completed:Disconnect() end
    if status ~= Enum.PlaybackState.Completed then return end
    if rf.farmcoineligible(object, part) then
      rf.farmarrive(session)
    else
      rf.farmfinishcoin(session)
    end
  end)
  tween:Play()
  farm.lastcollectmotion = os.clock()
  farm.lastcollectround = state.roundstartedat
  farm.lastcollectcharacter = session.character
  return true
end

function rf.voidlobbyspawns()
  local lobby = world:FindFirstChild("RegularLobby")
  return lobby and lobby:FindFirstChild("Spawns") or nil
end

function rf.voidcachedspawns()
  local safe = state.voidsafe
  local folder = rf.voidlobbyspawns()
  if not folder then return {} end
  local now = os.clock()
  if safe.spawnfolder ~= folder or now >= (safe.spawnexpires or 0) then
    safe.spawnfolder = folder
    safe.spawnexpires = now + 3
    safe.spawnparts = {}
    for _, part in ipairs(folder:GetDescendants()) do
      if part:IsA("BasePart") then safe.spawnparts[#safe.spawnparts + 1] = part end
    end
  end
  return safe.spawnparts
end

function rf.voidislobbyspawn(part)
  local spawns = rf.voidlobbyspawns()
  return typeof(part) == "Instance" and part:IsA("BasePart") and spawns ~= nil
    and part:IsDescendantOf(spawns)
end

function rf.voidlobbyspawn(position)
  local safe = state.voidsafe
  local spawns = rf.voidlobbyspawns()
  if not spawns then return false end
  local nearest, score, first
  for _, part in ipairs(rf.voidcachedspawns()) do
    if part.Parent and part:IsDescendantOf(spawns) then
      first = first or part
      if typeof(position) == "Vector3" then
        local difference = position - part.Position
        local horizontal = Vector2.new(difference.X, difference.Z).Magnitude
        local vertical = math.abs(difference.Y)
        if horizontal <= 120 and vertical <= 45 then
          local distance = horizontal + vertical * 0.6
          if not score or distance < score then
            nearest, score = part, distance
          end
        end
      end
    end
  end
  if not nearest then
    local respawn = localplayer.RespawnLocation
    if rf.voidislobbyspawn(respawn) then
      first = respawn
    end
    if first and (not safe.lobbyframe or not safe.lobbypart
      or not safe.lobbypart:IsDescendantOf(spawns)) then
      safe.lobbyframe = CFrame.new(first.Position + Vector3.new(0, 4, 0))
      safe.lobbypart = first
    end
    return false
  end
  local character = localplayer.Character
  if safe.lobbycharacter ~= character or not safe.lobbyframe
    or not safe.lobbypart or not safe.lobbypart:IsDescendantOf(spawns) then
    safe.lobbyframe = CFrame.new(nearest.Position + Vector3.new(0, 4, 0))
    safe.lobbypart = nearest
    safe.lobbycharacter = character
  end
  safe.lobbylastseen = os.clock()
  return true
end

rf.enforcenoclip()

function rf.voidrecordspawn(part)
  if typeof(part) ~= "Instance" or not part:IsA("BasePart") then return false end
  local safe = state.voidsafe
  if rf.voidislobbyspawn(part) then
    safe.lobbyframe = CFrame.new(part.Position + Vector3.new(0, 4, 0))
    safe.lobbypart = part
    safe.lobbycharacter = localplayer.Character
    safe.lobbylastseen = os.clock()
    safe.checkpoint = nil
    safe.checkpointat = 0
    safe.cooldown = os.clock() + 0.4
    return true
  end
  local maproot = state.maproot
  if not maproot or not maproot:IsDescendantOf(world)
    or maproot.Name:lower():find("lobby", 1, true) then return false end
  safe.maproot = maproot
  safe.mapframe = CFrame.new(part.Position + Vector3.new(0, 4, 0))
  safe.pending = {position = part.Position, untiltime = os.clock() + 3.5,
    round = state.roundstartedat, maproot = maproot}
  safe.round = state.roundstartedat
  safe.cooldown = os.clock() + 0.6
  return true
end

function rf.voidresetmap()
  local safe = state.voidsafe
  safe.maproot = nil
  safe.mapframe = nil
  safe.pending = nil
  safe.checkpoint = nil
  safe.checkpointat = 0
  safe.checkpointmap = nil
  safe.checkpointround = nil
  safe.teleport = nil
  safe.fallstarted = nil
  safe.character = nil
  safe.round = 0
  safe.cooldown = os.clock() + 0.8
end

function rf.voidstep(dt)
  if not state.alive or not config.antivoid then return false end
  local safe = state.voidsafe
  local now = os.clock()
  if now < safe.nextcheck then return false end
  safe.nextcheck = now + 0.025
  local character = localplayer.Character
  local root = character and character:FindFirstChild("HumanoidRootPart")
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  if not root or not humanoid or humanoid.Health <= 0 then return false end
  if state.autofling and state.autofling.active then
    if not finitevector(root.Position) or not finitevector(root.AssemblyLinearVelocity)
      or root.Position.Y <= world.FallenPartsDestroyHeight + 45 then
      rf.flingfinish("Anti Void emergency stop")
      return true
    end
    return false
  end
  if not finitevector(root.Position) then return false end
  local inlobby = rf.voidlobbyspawn(root.Position)
  if safe.character ~= character then
    safe.character = character
    safe.checkpoint = nil
    safe.checkpointat = 0
    safe.checkpointmap = nil
    safe.checkpointround = nil
    safe.fallstarted = nil
    if not safe.teleport or safe.teleport.character ~= character
      or safe.teleport.round ~= state.roundstartedat
      or safe.teleport.maproot ~= state.maproot then
      safe.teleport = nil
    end
    safe.cooldown = math.max(safe.cooldown, now + 0.55)
  end
  local pending = safe.pending
  if pending then
    if pending.maproot ~= state.maproot or pending.round ~= state.roundstartedat
      or now > pending.untiltime then
      safe.pending = nil
    elseif (root.Position - pending.position).Magnitude <= 30
      and humanoid.FloorMaterial ~= Enum.Material.Air then
      safe.mapframe = character:GetPivot()
      safe.round = state.roundstartedat
      safe.pending = nil
      if farm.home and farm.home.character == character then farm.home.pivot = safe.mapframe end
    end
  end
  if safe.mapframe and (not safe.maproot or not safe.maproot:IsDescendantOf(world)) then
    safe.mapframe = nil
    safe.maproot = nil
  end
  local owner = rf.motionowner()
  local teleporting = rf.voidteleportactive(character)
  local busy = state.pickupbusy or state.autokill.active or farm.hide ~= nil
    or state.autoshoothover ~= nil or voting.stage ~= "idle"
    or farm.session ~= nil and owner == "autofarm"
    or owner == "manualshot" or owner == "autokill" or owner == "pickup"
    or owner == "autovote" or owner == "autoshoot" or owner == "autofling"
  local grounded = humanoid.FloorMaterial ~= Enum.Material.Air
    and math.abs(root.AssemblyLinearVelocity.Y) < 35
    and root.Position.Y > world.FallenPartsDestroyHeight + 30
  if not busy and not teleporting and grounded then
    if inlobby then
      safe.checkpoint = nil
      safe.checkpointmap = nil
      safe.checkpointround = nil
    elseif state.round and not state.endlock and not rf.localisdead()
      and state.maproot and rf.inactivemap(root.Position)
      then
      safe.checkpoint = character:GetPivot()
      safe.checkpointat = now
      safe.checkpointmap = state.maproot
      safe.checkpointround = state.roundstartedat
    end
  end
  local emergency = root.Position.Y <= world.FallenPartsDestroyHeight + 12
  if not emergency and (now < safe.cooldown or teleporting or busy or grounded) then
    safe.fallstarted = nil
    return false
  end
  local killed = rf.localisdead()
  local preferlobby = inlobby or killed or not state.round or state.endlock or state.victoryactive
  local lobbyframe = safe.lobbyframe
  local mapframe = safe.maproot == state.maproot and safe.round == state.roundstartedat
    and safe.mapframe or nil
  local checkpoint = safe.checkpointmap == state.maproot
    and safe.checkpointround == state.roundstartedat and safe.checkpoint or nil
  local frame
  if preferlobby then
    frame = lobbyframe
  else
    frame = checkpoint or mapframe or lobbyframe
  end
  if typeof(frame) ~= "CFrame" and state.antifling.safe
    and state.antifling.saferound == state.roundstartedat
    and state.antifling.safemap == state.maproot then
    frame = state.antifling.safe
  end
  if typeof(frame) ~= "CFrame" then return false end
  if not preferlobby and rf.voidlobbyspawn(frame.Position) then return false end
  local threshold = world.FallenPartsDestroyHeight + 26
  local projected = root.Position.Y + math.min(0, root.AssemblyLinearVelocity.Y) * 0.2
  if root.Position.Y > threshold and projected > threshold then
    safe.fallstarted = nil
    return false
  end
  if root.AssemblyLinearVelocity.Y > -8 and root.Position.Y > world.FallenPartsDestroyHeight + 9 then
    safe.fallstarted = nil
    return false
  end
  if not emergency then
    if not safe.fallstarted then safe.fallstarted = now; return false end
    if now - safe.fallstarted < 0.08 then return false end
  end
  safe.fallstarted = nil
  safe.cooldown = now + 1.4
  farm.voidcooldown = now + 0.75
  if state.manualshotcancel then pcall(state.manualshotcancel) end
  if state.pickuprestore then pcall(state.pickuprestore, true) end
  if state.autokill.active and rf.autokillstop then pcall(rf.autokillstop, "anti void recovery", false) end
  if state.autoshoothover and rf.autoshootstophover then pcall(rf.autoshootstophover, true) end
  if voting.stage ~= "idle" and rf.votehalt then pcall(rf.votehalt, "anti void recovery", false) end
  if farm.hide then rf.farmshowafterfull(false) end
  if farm.session then rf.farmstop(false) end
  if owner then rf.motionrelease(owner, true) end
  rf.motionclearreturn()
  local success = pcall(function()
    root.Anchored = false
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    if not rf.teleportpivot(character, frame) then error("Recovery teleport failed") end
  end)
  if success then
    safe.recoveries += 1
    farm.voidrecoveries = safe.recoveries
    if not preferlobby then
      safe.checkpoint = frame
      safe.checkpointat = now
      safe.checkpointmap = state.maproot
      safe.checkpointround = state.roundstartedat
    end
    if flags.autofarm then
      farm.nextscan = now + 0.75
      farm.status = preferlobby and "anti void returned to lobby spawn"
        or "anti void returned to map spawn"
      if not preferlobby then farm.home = {character = character, pivot = frame} end
    end
    rf.notification("Anti Void", preferlobby and "Returned to lobby spawn"
      or frame == mapframe and "Returned to map spawn" or "Returned to safe checkpoint",
      nil, "shield-check", Color3.fromRGB(112, 226, 178), "antivoid:" .. tostring(safe.recoveries))
  else
    rf.notification("Anti Void", "Unable to restore character", nil,
      "alert-triangle", Color3.fromRGB(242, 158, 132), "antivoid:failed")
  end
  return success
end

function rf.stepautofarm(dt)
  if not flags.autofarm and state.noclip.autoenabled then rf.farmreleasenoclip() end
  if flags.autofarm and not rf.localisinround() then
    if farm.hide then
      local character = localplayer.Character
      local root = character and character:FindFirstChild("HumanoidRootPart")
      rf.farmshowafterfull(not (root and rf.voidlobbyspawn(root.Position)))
    end
    if farm.session then rf.farmstop(false) end
    farm.status = "waiting for participating round"
    return
  end
  if flags.autofarm then
    rf.farmcheckfull(false)
    if farm.full then
      if farm.hide and rf.farmkeephidden() then return end
      rf.farmfinishfullbag()
      return
    end
  end
  if flags.autofarm and not farm.full then rf.farmcoinautoclip(false) end
  if state.noclip.suppressed then
    if farm.hide then rf.farmshowafterfull(true) end
    if farm.session then rf.farmstop(true) end
    if flags.autofarm then
      farm.status = rf.farmnoclipallowed() and "paused while noclip is disabled"
        or "waiting for map character"
    end
    return
  end
  if os.clock() < (farm.voidcooldown or 0) then return end
  local owner = rf.motionowner()
  if owner == "autokill" or state.autokill.active then
    if farm.hide then rf.farmshowafterfull(true) end
    if farm.session then rf.farmstop(false) end
    if flags.autofarm then motionqueue.queuedcollect = true end
    farm.status = "queued behind auto kill all"
    return
  end
  if flags.autofarm and config.farmresetfull and farm.full then
    rf.farmresetwhenfull()
    return
  end
  if farm.hide and rf.farmkeephidden() then return end
  if owner == "autofarm" and not farm.session then rf.motionrelease("autofarm", true) end
  owner = rf.motionowner()
  if owner and owner ~= "autofarm" then
    if farm.session then rf.farmstop(false) end
    if flags.autofarm then motionqueue.queuedcollect = true end
    farm.status = "queued behind " .. (owner == "autoshoot" and "auto shoot"
      or owner == "pickup" and "gun pickup" or owner)
    return
  end
  if not owner and not rf.motiondrain() then return end
  if not flags.autofarm then
    rf.farmshowafterfull(true)
    farm.fullshoteligible = false
    farm.lastcollectmotion = 0
    farm.lastcollectround = 0
    farm.lastcollectcharacter = nil
    farm.lastcoinposition = nil
    farm.returnedfull = false
    farm.nohighlightssince = nil
    if farm.session or farm.home then rf.farmstop(true) end
    farm.status = "off"
    return
  end
  if os.clock() < state.autoshootwarpuntil then return end
  if state.roundstartparticipant and rf.farmconfirmedkilled() then state.farmkilledround = true end
  if state.farmkilledround or not state.roundstartobserved or not state.roundstartparticipant
    or not rf.localisinround() or rf.localisdead() then
    if farm.session then rf.farmstop(false) end
    farm.status = state.farmkilledround and "waiting for next round" or "waiting for participating round"
    return
  end
  if state.pickupbusy then
    if farm.session then farm.suspend(true) end
    return
  end
  local valid, character, root, humanoid = rf.farmvalid()
  if not valid then
    if farm.session then rf.farmstop(false) end
    farm.status = "waiting for live character"
    return
  end
  local session = farm.session
  if session and (session.character ~= character or session.root ~= root or session.humanoid ~= humanoid) then
    rf.farmstop(false)
    session = nil
  end
  local now = os.clock()
  if not rf.farmhashighlights() and not (session and session.stage == "touching") then
    if session then
      farm.nohighlightssince = farm.nohighlightssince or now
      if now - farm.nohighlightssince >= 0.35 then
        rf.farmstop(false)
        rf.farmreturndestination("finished")
        farm.nohighlightssince = nil
      end
    end
    farm.status = "waiting for coin highlights"
    if now >= (farm.nextcoinrefresh or 0) then
      farm.nextcoinrefresh = now + 1
      rf.defer(function()
        if state.alive and flags.autofarm then rf.refreshcoinchams() end
      end)
    end
    return
  end
  farm.nohighlightssince = nil
  if session and session.evasion and rf.farmevadeupdate(session) then return end
  if session and (session.stage == "moving" or session.stage == "touching")
    and rf.farmevadethreat(session) then return end
  if session and session.stage == "moving" then
    if not rf.farmcoineligible(session.coin, session.coinpart) then
      rf.farmcancel()
      rf.farmfinishcoin(session)
      farm.nextscan = 0
      return
    end
    if now >= (session.nextretarget or 0) then
      session.nextretarget = now + 0.05
      local object, part, distance = rf.farmselectcoin(session.root)
      local targetpoint = session.coinpart.Position
      local currentdistance = (targetpoint - session.root.Position).Magnitude
      local changed = object and (object ~= session.coin or part ~= session.coinpart)
      local closer = changed and distance + math.max(0.3, currentdistance * 0.02) < currentdistance
      local moved = (targetpoint - (session.lastdestination or targetpoint)).Magnitude > 1
      if now - (session.retargettime or 0) >= 0.07 and (closer or moved) then
        if closer then
          rf.farmstarttween(session, object, part, distance)
        else
          rf.farmstarttween(session, session.coin, session.coinpart, currentdistance)
        end
        return
      end
    end
    if (session.root.Position - session.lastposition).Magnitude > 0.025 then
      session.lastposition = session.root.Position
      session.lastprogress = now
    end
    if now - session.lastprogress > 0.3 then
      farm.blocked[session.coin] = now + 1.5
      rf.farmcancel()
      rf.farmfinishcoin(session)
    end
    return
  end
  if session and session.stage == "touching" then
    if now - session.arrived < 0.19 then return end
    rf.farmfinishcoin(session)
    return
  end
  if now < farm.nextscan then return end
  local object, part, distance = rf.farmselectcoin(root)
  if not object then
    if session then rf.farmstop(false) end
    farm.status = "waiting for eligible coins"
    farm.nextscan = now + 0.1
    return
  end
  if not rf.motionacquire("autofarm") then
    farm.status = "queued behind auto shoot"
    return
  end
  if not session then session = rf.farmstart(character, root, humanoid) end
  if not session then
    rf.motionrelease("autofarm")
    return
  end
  rf.farmstarttween(session, object, part, distance)
end

function rf.creategunmarker()
  local holder = rf.create("Frame", {
    Name = "LastKnownGun", Size = UDim2.fromOffset(196, 57),
    AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Visible = false,
    Active = false, ZIndex = 40
  }, overlay)
  local shadow = rf.create("Frame", {Position = UDim2.fromOffset(4, 4), Size = UDim2.fromOffset(196, 57),
    BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(0, 0, 0), ZIndex = 39}, holder)
  local border = rf.create("Frame", {Size = UDim2.fromScale(1, 1), BorderSizePixel = 0,
    BackgroundColor3 = Color3.fromRGB(8, 8, 10), ZIndex = 40}, holder)
  local rim = rf.create("Frame", {Position = UDim2.fromOffset(3, 3), Size = UDim2.new(1, -6, 1, -6),
    BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(99, 98, 105), ZIndex = 41}, border)
  local face = rf.create("Frame", {Position = UDim2.fromOffset(3, 3), Size = UDim2.new(1, -6, 1, -6),
    BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(31, 31, 35), ZIndex = 42}, rim)
  rf.create("Frame", {Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = Color3.fromRGB(141, 139, 143),
    BorderSizePixel = 0, ZIndex = 43}, rim)
  rf.create("Frame", {Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(1, 0, 0, 2),
    BackgroundColor3 = Color3.fromRGB(14, 14, 17), BorderSizePixel = 0, ZIndex = 43}, rim)
  local plate = rf.create("Frame", {Position = UDim2.fromOffset(5, 5), Size = UDim2.fromOffset(39, 39),
    BackgroundColor3 = Color3.fromRGB(19, 21, 22), BorderSizePixel = 0, ZIndex = 44}, face)
  local icon = rf.iconimage(plate, config.gunmarkericon or "crosshair", Color3.fromRGB(255, 235, 64),
    UDim2.fromOffset(8, 8), UDim2.fromOffset(23, 23), 45)
  local heading = rf.create("TextLabel", {Position = UDim2.fromOffset(51, 3), Size = UDim2.new(1, -55, 0, 24),
    BorderSizePixel = 0, BackgroundTransparency = 1, Font = Enum.Font.Arcade, TextSize = 16,
    Text = "Gun last seen", TextColor3 = Color3.fromRGB(255, 235, 64),
    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 45}, face)
  local detail = rf.create("TextLabel", {Position = UDim2.fromOffset(51, 26), Size = UDim2.new(1, -55, 0, 18),
    BorderSizePixel = 0, BackgroundTransparency = 1, Font = Enum.Font.Arcade, TextSize = 12,
    Text = "Position unknown", TextColor3 = Color3.fromRGB(241, 241, 244),
    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 45}, face)
  return {holder = holder, heading = heading, detail = detail, icon = icon, plate = plate, rim = rim}
end

function rf.cleargunmarker()
  if state.gunmarker then
    state.gunmarker.holder:Destroy()
    state.markerui = nil
    state.gunmarker = nil
  end
  state.gunmarkerposition = nil
  state.gunmarkerkind = nil
  state.dropinstance = nil
  state.droppart = nil
  state.dropattachment = nil
  state.dropproof = nil
end

function rf.updategunmarker()
  if not state.alive then return end
  if not state.round or state.endlock then
    rf.cleargunmarker()
    return
  end
  rf.remembergun()
  local last = state.lastgun
  local age = last and (os.clock() - (last.timestamp or os.clock())) or math.huge
  local reliablelast = last and typeof(last.position) == "Vector3" and age <= (tonumber(config.gunmarkermaxage) or 180)
  if state.gunholder or not (flags.autopickup and config.autopickup or config.gunmarker and flags.chams) then
    rf.cleargunmarker()
    return
  end
  if not reliablelast or last and not rf.inactivemap(last.position) then
    state.lastgun = nil
    last, reliablelast = nil, false
  end
  if os.clock() >= state.nextdropscan then
    state.nextdropscan = os.clock() + math.max(0.05, tonumber(config.pickupsearchinterval) or 0.07)
    state.dropposition, state.dropinstance, state.droppart, state.dropattachment, state.dropproof = rf.droppedgunposition()
    if not state.droppart and os.clock() >= (state.markerrescanat or 0) then
      state.markerrescanat = os.clock() + 2
      rf.rescanexistinggundrops(true)
      state.dropposition, state.dropinstance, state.droppart, state.dropattachment, state.dropproof = rf.droppedgunposition(true)
    end
  end
  local exact = typeof(state.dropposition) == "Vector3"
    and rf.validgundrop(state.dropinstance, state.droppart, state.dropproof)
    and (not state.mapcf or rf.inactivemap(state.dropposition) or rf.isgunraycastmarker(state.dropproof))
  local position = exact and state.droppart.Position or reliablelast and last.position
  if exact then state.dropposition = position end
  if not exact then
    if state.pickuprestore then state.pickuprestore(true) end
    state.dropposition, state.dropinstance, state.droppart, state.dropattachment, state.dropproof = nil, nil, nil, nil, nil
    state.pickupdropkey, state.pickupdropreadyat = nil, 0
    state.pickupretrytarget, state.pickupretryat, state.pickupfailures = nil, 0, 0
    local assigned = state.gunroleowner and players:GetPlayerByUserId(state.gunroleowner)
    if assigned and rf.holderalive(assigned) then
      rf.cleargunmarker()
      return
    end
  end
  if typeof(position) ~= "Vector3" then
    rf.cleargunmarker()
    return
  end
  local previouskind = state.gunmarkerkind
  state.gunmarkerposition = position
  state.gunmarkerkind = exact and "dropped" or "estimated"
  if exact and previouskind ~= "dropped" then
    local localroot = localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
    local distance = localroot and math.floor((position - localroot.Position).Magnitude + 0.5)
    rf.notification("Gun dropped", distance and (distance .. " studs away") or "Weapon available",
      nil, "crosshair", Color3.fromRGB(255, 235, 64), "gun-drop:" .. tostring(state.dropinstance))
  end
  if exact and not state.pickupbusy then rf.pickupgun() end
  if not config.gunmarker or not flags.chams then
    if state.gunmarker then
      state.gunmarker.holder:Destroy()
      state.gunmarker = nil
      state.markerui = nil
    end
    return
  end
  local marker = state.gunmarker
  if not marker then
    marker = rf.creategunmarker()
    state.gunmarker = marker
  end
  state.markerui = marker
  marker.heading.Text = exact and "Gun dropped" or "Gun last seen"
  marker.icon.ImageColor3 = Color3.fromRGB(255, 235, 64)
  marker.plate.BackgroundColor3 = Color3.fromRGB(19, 21, 22)
  local localroot = localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
  local distance = localroot and math.floor((position - localroot.Position).Magnitude + 0.5)
  marker.detail.Text = (exact and "On ground" or "Last position") .. (distance and "  " .. distance .. " studs" or "")
end

function rf.inferroles()
  if not state.alive or not state.round or state.endlock then return end
  local changed = false
  local previousowner = state.gunroleowner
  rf.remembergun()
  local confirmedhero, confirmedsheriff
  for id, data in pairs(state.authoritative) do
    local p = players:GetPlayerByUserId(id)
    if p and rf.holderalive(p) then
      if data.Role == "Hero" then
        confirmedhero = id
      elseif data.Role == "Sheriff" then
        confirmedsheriff = id
      end
    end
  end
  local newowner = confirmedhero or state.gunholder or confirmedsheriff
  if newowner and newowner ~= state.gunroleowner then
    local saved = state.gunhistory[newowner]
    state.lastgun = saved and table.clone(saved) or nil
    state.gunroleowner = newowner
  end
  for _, p in ipairs(players:GetPlayers()) do
    if p ~= localplayer then
      local existing = rf.getrecord(p)
      local stored = state.authoritative[p.UserId]
      local observed = state.observed[p.UserId]
      local weapon = rf.equippedrole(p)
      local replicated = rf.replicatedrole(p)
      local humanoid = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
      local alive = rf.holderalive(p)
      if not alive then weapon = nil end
      if weapon then
        local inferred = weapon
        if weapon == "Sheriff" and ((stored and stored.Role == "Hero")
          or (state.originalsheriff and p.UserId ~= state.originalsheriff)
          or (not state.originalsheriff and previousowner and p.UserId ~= previousowner)) then
          inferred = "Hero"
        end
        if not observed or observed.Role ~= inferred then
          state.observed[p.UserId] = {Role = inferred, UserId = p.UserId}
          observed = state.observed[p.UserId]
        end
      end
      local role, source
      if state.synced and not state.participants[p.UserId] then
        role, source = "Neutral", "spectator"
      elseif config.preservemanual and existing and existing.source == "manual" then
        role, source = existing.Role, "manual"
      elseif stored and stored.Role ~= "Innocent" then
        role, source = stored.Role, "fade"
      elseif weapon then
        role, source = observed and observed.Role or weapon, "weapon"
      elseif observed and observed.Role ~= "Innocent" then
        role, source = observed.Role, "remembered"
      elseif replicated and replicated ~= "Innocent" then
        role, source = replicated, "replicated"
      elseif existing and existing.Role ~= "Innocent" and existing.source ~= "assumed" then
        role, source = existing.Role, "remembered"
      else
        role, source = "Innocent", "assumed"
      end
      if (role == "Sheriff" or role == "Hero" or role == "GunCarrier")
        and state.gunroleowner and p.UserId ~= state.gunroleowner and alive then
        role, source = "Innocent", "transferred"
      end
      if (role == "Sheriff" or role == "Hero") and alive then rf.capturegunposition(p) end
      local dead = stored and stored.Dead == true or existing and existing.Dead == true or false
      local killed = stored and stored.Killed == true or existing and existing.Killed == true or false
      if humanoid and humanoid.Health <= 0 then dead = true end
      if existing and existing.source == "manual" and config.preservemanual then
        dead, killed = existing.Dead == true, existing.Killed == true
      end
      if not existing or existing.Role ~= role or existing.source ~= source
        or existing.Dead ~= dead or existing.Killed ~= killed then
        local record = existing and table.clone(existing) or {}
        record.Role, record.Dead, record.Killed = role, dead, killed
        record.source, record.UserId = source, p.UserId
        if stored and stored.DeadTime ~= nil then record.DeadTime = stored.DeadTime end
        state.records[p.UserId], state.records[p.Name] = record, record
        changed = true
      end
    end
  end
  if changed then rf.refreshvisuals() end
end

function rf.loadroles(payload, reset, source)
  if not state.alive or type(payload) ~= "table" then return end
  local updated, count = {}, 0
  for key, data in pairs(payload) do
    if type(data) == "table" then
      local role = rf.normalize_role(data.Role)
      local id = tonumber(data.UserId) or tonumber(key)
      if not id and type(key) == "string" then
        local p = players:FindFirstChild(key)
        if p then id = p.UserId end
      end
      if role and id then
        local record = table.clone(data)
        record.Role, record.source = role, "fade"
        updated[id] = record
        count += 1
      end
    end
  end
  if count == 0 or state.endlock and not reset then return end
  local now = os.clock()
  local localentry = updated[localplayer.UserId]
  local haslocal = localentry and localentry.Dead ~= true and localentry.Killed ~= true
  if reset then
    local newround = not state.roundstartobserved or state.endlock or now - state.roundstartedat > 10
    if newround then
      if rf.autokillstop then rf.autokillstop("new round", false) end
      rf.motionclearreturn()
      if rf.autoshootstophover then rf.autoshootstophover(true) end
      rf.farmcancelreturn()
      rf.farmshowafterfull(true)
      farm.lastcoinposition = nil
      farm.returnedfull = false
      farm.fullresetround = nil
      farm.full = false
      farm.fullround = nil
      farm.fullshoteligible = false
      farm.lastcollectmotion = 0
      farm.lastcollectround = 0
      farm.lastcollectcharacter = nil
      state.fullbagshot = nil
      rf.bagreset()
      state.autokill.cooldown = setmetatable({}, {__mode = "k"})
      state.roundresult = {serial = (state.roundresult and state.roundresult.serial or 0) + 1,
        murdererid = nil, murderername = nil, localrole = nil,
        murdererleft = false, leftat = 0, notified = false, endedat = 0}
      state.roundstartobserved = true
      state.roundstartparticipant = haslocal == true
      state.farmkilledround = false
      state.roundstartedat = now
      state.roundstartsource = source or "fade"
    elseif source == "roundstart" and state.roundstartsource ~= "roundstart" and now - state.roundstartedat < 8 then
      state.roundstartparticipant = haslocal == true
      state.roundstartsource = "roundstart"
    end
    if not newround then reset = false end
  end
  state.endlock = false
  if state.roundstartobserved and state.roundstartparticipant and config.disablefade then
    rf.defer(function()
      if state.alive then rf.votefadeapply(true) end
    end)
  end
  if reset then
    state.coinroundhidden = false
    rf.defer(function()
      if state.alive and (flags.coinchams or flags.autofarm) and not state.coinroundhidden then rf.refreshcoinchams() end
    end)
  end
  if reset or not state.synced then
    if reset then state.victoryactive, state.victoryvisible = false, false end
    state.observed = {}
    state.authoritative = {}
    state.records = {}
    state.deathseen = {}
    if not state.synced then state.rolealerts = {} end
    state.lastsheriff, state.lastgun, state.gunhistory = {}, nil, {}
    state.gunlossrecords = {}
    state.gundroplinks = setmetatable({}, {__mode = "k"})
    state.gunroleowner, state.gunholder, state.originalsheriff = nil, nil, nil
    state.gunownershipid, state.gunownershipsource = nil, nil
    state.dropposition, state.dropinstance, state.droppart, state.dropattachment, state.dropproof = nil, nil, nil, nil, nil
    state.pickupdropkey, state.pickupdropreadyat = nil, 0
    state.nextdropscan = 0
    state.pickupretryat, state.pickupretrytarget, state.pickupfailures = 0, nil, 0
    state.pickupattempts = setmetatable({}, {__mode = "k"})
    state.pickupcounts = setmetatable({}, {__mode = "k"})
  end
  for id, incoming in pairs(updated) do
    if incoming.Role == "Sheriff" then state.originalsheriff = id end
    local result = state.roundresult
    if result then
      if incoming.Role == "Murderer" then
        result.murdererid = id
        local murderer = players:GetPlayerByUserId(id)
        result.murderername = murderer and murderer.Name or result.murderername
      end
      if id == localplayer.UserId and incoming.Role ~= "Neutral" then
        result.localrole = incoming.Role
      end
    end
  end
  local participants = reset and {} or table.clone(state.participants)
  for id in pairs(updated) do participants[id] = true end
  state.participants = participants
  state.localround = participants[localplayer.UserId] == true
    and (type(updated[localplayer.UserId]) == "table" or type(state.authoritative[localplayer.UserId]) == "table")
  local wassynced = state.synced
  if reset and not state.synced then state.rolealerts = {} end
  for id, incoming in pairs(updated) do
    local previous = state.authoritative[id]
    local wasdead = previous and previous.Dead == true
    local died = incoming.Dead == true
    if died and not wasdead and (incoming.Role == "Sheriff" or incoming.Role == "Hero"
      or id == state.gunroleowner or id == state.gunholder or id == state.gunownershipid) then
      local player = players:GetPlayerByUserId(id)
      if player then rf.recordgunloss(player, player.Character) end
    end
    if died and not wasdead and wassynced and not state.deathseen[id] then
      state.deathseen[id] = true
      local p = players:GetPlayerByUserId(id)
      if config.killnotices then
        rf.notification(incoming.Role == "Murderer" and "Murderer eliminated" or
          incoming.Role == "Sheriff" and "Sheriff eliminated" or "Player eliminated",
          p and p.Name or tostring(id), id, "skull", colors[incoming.Role], "death:" .. id)
      end
    elseif not died and reset then
      state.deathseen[id] = nil
    end
    if incoming.Dead ~= true and (incoming.Role == "Murderer" or incoming.Role == "Sheriff" or incoming.Role == "Hero") then
      local alertkey = incoming.Role .. ":" .. id
      if not state.rolealerts[alertkey] then
        state.rolealerts[alertkey] = true
        local player = players:GetPlayerByUserId(id)
        local heading = incoming.Role == "Murderer" and "Murderer revealed" or
          incoming.Role == "Sheriff" and "Sheriff revealed" or "Hero revealed"
        rf.notification(heading, player and player.Name or tostring(id), id,
          incoming.Role == "Murderer" and "swords" or "shield", colors[incoming.Role], "role:" .. alertkey)
      end
    end
    state.authoritative[id] = incoming
    local current = state.records[id] or {}
    local record = table.clone(current)
    for key, value in pairs(incoming) do record[key] = value end
    state.records[id] = record
    local p = players:GetPlayerByUserId(id)
    if p then state.records[p.Name] = record end
  end
  local holder, sheriff
  for id, incoming in pairs(updated) do
    if incoming.Dead ~= true then
      if incoming.Role == "Hero" then
        holder = id
        break
      elseif incoming.Role == "Sheriff" then
        sheriff = id
      end
    end
  end
  if holder or sheriff then
    local owner = holder or sheriff
    if state.gunroleowner and owner ~= state.gunroleowner then
      local saved = state.gunhistory[owner]
      state.lastgun = saved and table.clone(saved) or nil
    end
    state.gunroleowner = owner
  end
  state.round, state.synced = true, true
  if state.roundstartparticipant and rf.farmconfirmedkilled() then state.farmkilledround = true end
  if not state.roundstartparticipant or state.farmkilledround or not state.localround then
    if farm.session then rf.farmstop(false) end
    if flags.autofarm then
      farm.status = state.farmkilledround and "killed: waiting for next round" or "waiting for participating round"
    end
  end
  rf.trackassignedgun()
  rf.remembergun()
  if rf.localisdead() and state.pickuprestore then state.pickuprestore() end
  rf.inferroles()
  rf.refreshvisuals()
  rf.updategunmarker()
end

function rf.endround(value)
  if not state.alive or value ~= true then return end
  if state.roundresult then state.roundresult.endedat = os.clock() end
  state.round, state.localround, state.synced, state.endlock, state.victoryactive = false, false, false, true, true
  state.roundstartobserved, state.roundstartparticipant, state.farmkilledround = false, false, false
  state.roundstartedat, state.roundstartsource = 0, nil
  rf.resources.votefadearmed = false
  rf.votefadeapply(true)
  motionqueue.queuedcollect = false
  rf.motionclearreturn()
  state.coinroundhidden = true
  if rf.autokillstop then rf.autokillstop("round ended", false) end
  if rf.autoshootstophover then rf.autoshootstophover(true) end
  rf.farmcancelreturn()
  rf.farmshowafterfull(true)
  farm.full = false
  farm.fullround = nil
  farm.fullresetround = nil
  farm.fullshoteligible = false
  farm.lastcollectmotion = 0
  farm.lastcollectround = 0
  farm.lastcollectcharacter = nil
  state.fullbagshot = nil
  farm.lastcoinposition = nil
  farm.returnedfull = false
  farm.nohighlightssince = nil
  rf.bagreset()
  state.autokill.cooldown = setmetatable({}, {__mode = "k"})
  rf.clearcoinchams()
  rf.farmstop(true)
  farm.home = nil
  farm.status = flags.autofarm and "waiting for next round" or "off"
  state.participants = {}
  state.records, state.authoritative, state.observed = {}, {}, {}
  state.lastsheriff, state.lastgun, state.gunhistory = {}, nil, {}
  state.gunlossrecords = {}
  state.gundroplinks = setmetatable({}, {__mode = "k"})
  state.maproot, state.mapcf, state.mapsize, state.mapspawn, state.mapmode = nil, nil, nil, nil, nil
  rf.voidresetmap()
  state.gunholder, state.gunroleowner, state.originalsheriff, state.aimtarget = nil, nil, nil, nil
  state.gunownershipid, state.gunownershipsource = nil, nil
  state.deathseen, state.rolealerts, state.dropposition = {}, {}, nil
  if state.pickuprestore then state.pickuprestore() end
  state.pickupattempts = setmetatable({}, {__mode = "k"})
  state.pickupcounts = setmetatable({}, {__mode = "k"})
  state.nextdropscan = 0
  rf.cleargunmarker()
  rf.clearvisuals()
  for _, p in ipairs(players:GetPlayers()) do
    local record = {Role = "Neutral", Dead = false, Killed = false, source = "neutral", UserId = p.UserId}
    state.records[p.UserId], state.records[p.Name] = record, record
  end
end

function rf.smoothoverride(point, target, part, tool)
  if typeof(point) ~= "Vector3" then return nil end
  state.aimoverride = nil
  return point
end

function rf.resolvecframe()
  if not state.alive then return nil end
  local track = state.autoshoottrack
  if track and (flags.aim or config.autoshoot or state.manualshotbusy)
    and os.clock() <= track.untiltime and track.tool and track.tool.Parent == localplayer.Character
    and track.part and track.part.Parent and rf.autoshootfarvalid(track.target) then
    local handle = track.tool:FindFirstChild("Handle", true)
    local camera = world.CurrentCamera
    local origin = handle and handle:IsA("BasePart") and handle.Position
      or camera and camera.CFrame.Position
    if origin then
      local result = track.exact and track.part.Position or rf.autoshootforecast(track.target, track.part, origin)
      if result and visible(track.target.Character, result, origin, track.exact and track.part or nil) then
        state.autoshootpoint = result
        return CFrame.new(rf.smoothoverride(result, track.target, track.part, track.tool))
      end
    end
  end
  if state.autoshootpoint and os.clock() <= state.autoshootpointuntil
    and (flags.aim or config.autoshoot or state.manualshotbusy) then
    return CFrame.new(rf.smoothoverride(state.autoshootpoint, nil, nil, nil))
  end
  state.aimoverride = nil
  if not flags.aim then return nil end
  local weapon, kind = rf.getweapon()
  if not weapon or kind == "knife" and not config.knifeaim then return nil end
  if config.aimonfire then
    local active = userinputservice:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
      or os.clock() <= state.mouseactiveuntil
    if kind == "gun" and not active then return nil end
    if kind == "knife" and not config.knifeaimalways and not active then return nil end
  end
  local ok, point = pcall(rf.targetpoint)
  if ok and typeof(point) == "Vector3" then return CFrame.new(point) end
  return nil
end

function rf.install()
  local ok, service = pcall(require, servicemodule)
  if not ok or type(service) ~= "table" then
    state.serviceerror = tostring(service)
    return false
  end
  if type(service.GetMouseTargetCFrame) ~= "function" or type(service.GetTargetPosition) ~= "function" then
    state.serviceerror = "Aiming methods unavailable"
    return false
  end
  local oldmouse = service.GetMouseTargetCFrame
  local oldposition = service.GetTargetPosition
  local newmouse = function(...)
    local point = rf.resolvecframe()
    if point then return point end
    return oldmouse(...)
  end
  local newposition = function(...)
    local point = rf.resolvecframe()
    if point then return point end
    return oldposition(...)
  end
  local patched = pcall(function()
    service.GetMouseTargetCFrame = newmouse
    service.GetTargetPosition = newposition
  end)
  if not patched then
    pcall(function()
      if service.GetMouseTargetCFrame == newmouse then service.GetMouseTargetCFrame = oldmouse end
    end)
    state.serviceerror = "Could not attach aiming methods"
    return false
  end
  state.weaponservice = service
  state.originalmouse = oldmouse
  state.originalposition = oldposition
  state.wrappedmouse = newmouse
  state.wrappedposition = newposition
  return true
end

local mouse = localplayer:GetMouse()
local mousehook = env.__rolefx_mouse_spoofer
if type(mousehook) ~= "table" then
  mousehook = {installed = false, resolve = nil, original = nil}
  env.__rolefx_mouse_spoofer = mousehook
end

function rf.spoofmouse(property)
  if not state.alive or not (flags.aim or config.autoshoot) or not config.mousecframespoof then return nil end
  if property == "UnitRay" and not config.mouseunitrayspoof then return nil end
  if type(checkcaller) == "function" and checkcaller() then return nil end
  local weapon, kind = rf.getweapon()
  if not weapon or kind == "knife" and not config.knifeaim then return nil end
  local now = os.clock()
  local cache = state.mousecache
  if now - cache.time >= math.max(0.004, tonumber(config.mousecacherate) or 0.014) then
    cache.time, cache.point = now, rf.resolvecframe()
  end
  local point = cache.point
  local camera = world.CurrentCamera
  if not point or not camera then return nil end
  local origin = camera.CFrame.Position
  local delta = point.Position - origin
  if delta.Magnitude <= 0.001 then return nil end
  local direction = delta.Unit
  if property == "Hit" then return CFrame.lookAt(point.Position, point.Position + direction) end
  if property == "UnitRay" then return Ray.new(origin, direction) end
  return nil
end

function rf.installmouse()
  if mousehook.installed then
    mousehook.resolve = rf.spoofmouse
    return true
  end
  if type(hookmetamethod) ~= "function" then
    state.mouseerror = "hookmetamethod unavailable"
    return false
  end
  local handler = function(self, property)
    if self == mouse and (property == "Hit" or property == "UnitRay") then
      local resolve = mousehook.resolve
      if type(resolve) == "function" then
        local ok, value = pcall(resolve, property)
        if ok and value ~= nil then return value end
      end
    end
    return mousehook.original(self, property)
  end
  local wrapped = type(newcclosure) == "function" and newcclosure(handler) or handler
  local ok, original = pcall(hookmetamethod, game, "__index", wrapped)
  if not ok or type(original) ~= "function" then
    state.mouseerror = ok and "Invalid original mouse hook" or tostring(original)
    return false
  end
  mousehook.original = original
  mousehook.installed = true
  mousehook.resolve = rf.spoofmouse
  return true
end

rf.resources.fxroot = rf.create("Folder", {Name = "CinematicGunFX"}, world)

function rf.fxanchor(parent, position)
  local part = rf.create("Part", {
    Name = "FXAnchor", Anchored = true, CanCollide = false, CanTouch = false, CanQuery = false, CastShadow = false,
    Transparency = 1, Size = Vector3.new(0.1, 0.1, 0.1),
    CFrame = CFrame.new(position)
  }, parent)
  return part, rf.create("Attachment", {}, part)
end

function rf.fxball(parent, position, color, initial, final, lifetime, transparency)
  local ball = rf.create("Part", {
    Name = "EnergyBloom", Shape = Enum.PartType.Ball, Material = Enum.Material.Neon, Color = color,
    Size = Vector3.new(initial, initial, initial), CFrame = CFrame.new(position), Anchored = true, CanCollide = false,
    CanTouch = false, CanQuery = false,
    CastShadow = false, Transparency = transparency or 0.12
  }, parent)
  tweenservice:Create(ball, TweenInfo.new(lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Size = Vector3.new(final, final, final),
    Transparency = 1
  }):Play()
  return ball
end

function rf.fxlight(parent, color, brightness, range, lifetime)
  local light = rf.create("PointLight", {
    Color = color, Brightness = brightness,
    Range = range, Shadows = false
  }, parent)
  tweenservice:Create(light, TweenInfo.new(lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Brightness = 0,
    Range = 1
  }):Play()
  return light
end

function rf.fxbeam(parent, a0, a1, tint, width, duration, curved, transparency)
  local beam = rf.create("Beam", {
    Attachment0 = a0, Attachment1 = a1, Color = tint, Transparency = NumberSequence.new(transparency),
    Width0 = width, Width1 = width * 0.78, FaceCamera = true, Segments = curved and 18 or 2,
    CurveSize0 = curved and 0.48 or 0, CurveSize1 = curved and -0.48 or 0, LightEmission = 1, LightInfluence = 0,
    Brightness = 6, ZOffset = 0
  }, parent)
  tweenservice:Create(beam, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
    Width0 = 0,
    Width1 = 0
  }):Play()
  return beam
end

function rf.sparks(parent, position, tint, count)
  local anchor, attachment = rf.fxanchor(parent, position)
  local particles = rf.create("ParticleEmitter", {
    Name = "ImpactSparks", Texture = "rbxasset://textures/particles/sparkles_main.dds",
    Rate = 0, Lifetime = NumberRange.new(0.11, 0.35), Speed = NumberRange.new(9, 23), SpreadAngle = Vector2.new(180, 180),
    Drag = 7, LightEmission = 1, LightInfluence = 0, Color = ColorSequence.new(tint, Color3.fromRGB(245, 245, 255)),
    Size = NumberSequence.new({
      NumberSequenceKeypoint.new(0, 0.33),
      NumberSequenceKeypoint.new(0.45, 0.16),
      NumberSequenceKeypoint.new(1, 0)
    }),
    Transparency = NumberSequence.new({
      NumberSequenceKeypoint.new(0, 0.02),
      NumberSequenceKeypoint.new(0.65, 0.18),
      NumberSequenceKeypoint.new(1, 1)
    }),
    Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-160, 160)
  }, attachment)
  particles:Emit(count)
  return anchor
end

function rf.resolveorigin(value)
  if typeof(value) == "Vector3" then return value end
  if typeof(value) == "CFrame" then return value.Position end
  if typeof(value) == "Instance" then
    if value:IsA("Attachment") then return value.WorldPosition end
    if value:IsA("BasePart") then return value.Position end
  end
  return nil
end

rf.resources.gunpalette = {
  Prism = {Color3.fromRGB(58, 231, 255), Color3.fromRGB(183, 112, 255), Color3.fromRGB(234, 251, 255)},
  Ion = {Color3.fromRGB(71, 255, 180), Color3.fromRGB(67, 211, 255), Color3.fromRGB(235, 255, 250)},
  Ember = {Color3.fromRGB(255, 177, 65), Color3.fromRGB(255, 78, 94), Color3.fromRGB(255, 247, 206)},
  Arc = {Color3.fromRGB(170, 111, 255), Color3.fromRGB(75, 202, 255), Color3.fromRGB(246, 242, 255)},
  Minimal = {Color3.fromRGB(185, 205, 255), Color3.fromRGB(236, 247, 255), Color3.fromRGB(255, 255, 255)},
  Lightning = {Color3.fromRGB(92, 191, 255), Color3.fromRGB(176, 104, 255), Color3.fromRGB(245, 252, 255)},
  Lava = {Color3.fromRGB(255, 210, 55), Color3.fromRGB(255, 67, 35), Color3.fromRGB(255, 248, 188)},
  Void = {Color3.fromRGB(168, 68, 255), Color3.fromRGB(255, 73, 188), Color3.fromRGB(238, 222, 255)}
}

function rf.fxaxes(start, finish)
  local line = finish - start
  local direction = line.Magnitude > 0.001 and line.Unit or Vector3.new(0, 0, -1)
  local side = direction:Cross(Vector3.new(0, 1, 0))
  if side.Magnitude < 0.01 then side = direction:Cross(Vector3.new(1, 0, 0)) end
  side = side.Unit
  return direction, side, direction:Cross(side).Unit
end

function rf.fxdischarge(group, origin, finish, primary, secondary, white, width, duration, quality)
  local direction, side, up = rf.fxaxes(origin, finish)
  local length = (finish - origin).Magnitude
  local segments = quality == "low" and 6 or quality == "full" and 11 or 8
  local anchors, points = {}, {}
  for i = 0, segments do
    local point = origin:Lerp(finish, i / segments)
    local part, attachment = rf.fxanchor(group, point)
    anchors[i + 1], points[i + 1] = part, attachment
  end
  local glowcolor = ColorSequence.new(primary, secondary)
  for i = 1, segments do
    if config.gunbeamglow then
      rf.fxbeam(group, points[i], points[i + 1], glowcolor, 0.24 * width, duration, false, 0.75)
    end
    rf.fxbeam(group, points[i], points[i + 1], ColorSequence.new(white), 0.07 * width, duration * 0.86, false, 0.02)
  end
  if quality ~= "low" then
    for i = 1, 2 do
      local index = math.clamp(math.floor(segments * (i / 3)), 2, segments - 1)
      local from = points[index]
      local aim = origin:Lerp(finish, (index + 1.3) / segments)
        + side * ((i == 1 and 1 or -1) * math.min(3, length * 0.085))
        + up * (i == 1 and 1.5 or -1.2)
      local _, terminal = rf.fxanchor(group, aim)
      rf.fxbeam(group, from, terminal, ColorSequence.new(primary, secondary), 0.06 * width, duration * 0.72, false, 0.25)
    end
  end
  rf.spawn(function()
    local started, nextchange = os.clock(), 0
    while state.alive and group.Parent and os.clock() - started < duration do
      local elapsed = os.clock() - started
      if elapsed >= nextchange then
        nextchange = elapsed + 0.035
        local fade = math.clamp(1 - elapsed / duration, 0.1, 1)
        for i = 2, segments do
          local t = (i - 1) / segments
          local taper = math.sin(t * math.pi)
          local shake = math.min(1.75, length * 0.055) * taper * fade
          anchors[i].Position = origin:Lerp(finish, t)
            + side * ((math.random() * 2 - 1) * shake)
            + up * ((math.random() * 2 - 1) * shake)
        end
      end
      runservice.Heartbeat:Wait()
    end
  end)
end

function rf.fxmolten(group, origin, finish, primary, secondary, white, width, duration, quality)
  local direction, side, up = rf.fxaxes(origin, finish)
  local length = (finish - origin).Magnitude
  local count = quality == "low" and 5 or quality == "full" and 14 or 9
  local base = ColorSequence.new({
    ColorSequenceKeypoint.new(0, secondary),
    ColorSequenceKeypoint.new(0.3, primary),
    ColorSequenceKeypoint.new(0.67, white),
    ColorSequenceKeypoint.new(1, secondary)
  })
  local _, from = rf.fxanchor(group, origin)
  local _, to = rf.fxanchor(group, finish)
  if config.gunbeamglow then
    rf.fxbeam(group, from, to, ColorSequence.new(secondary), 0.76 * width, duration, true, 0.86)
  end
  local flow = rf.fxbeam(group, from, to, base, 0.34 * width, duration, true, 0.16)
  flow.Segments = 20
  flow.CurveSize0 = 0.8
  flow.CurveSize1 = -0.8
  local core = rf.fxbeam(group, from, to, ColorSequence.new(white), 0.08 * width, duration * 0.8, false, 0.1)
  core.Brightness = 9
  for i = 1, count do
    local t = (i - 1) / count
    local position = origin:Lerp(finish, t)
      + side * ((math.random() * 2 - 1) * 0.42)
      + up * ((math.random() * 2 - 1) * 0.35)
    local size = (0.17 + math.random() * 0.26) * width
    local drop = rf.create("Part", {
      Name = "MoltenDroplet", Shape = Enum.PartType.Ball, Material = Enum.Material.Neon,
      Color = i % 3 == 0 and primary or secondary, Anchored = true, CanCollide = false,
      CanQuery = false, CanTouch = false, CastShadow = false, Transparency = 0.12,
      Size = Vector3.new(size, size, size), Position = position
    }, group)
    local endpos = position + direction * math.min(length * 0.28, 4.5)
      + side * ((math.random() * 2 - 1) * 1.3)
      + up * (0.5 + math.random() * 1.5)
    rf.delay(t * 0.13, function()
      if not group.Parent then return end
      tweenservice:Create(drop, TweenInfo.new(duration * 0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = endpos, Size = Vector3.new(0.025, 0.025, 0.025), Transparency = 1
      }):Play()
    end)
  end
  if quality ~= "low" then
    rf.spawn(function()
      local started = os.clock()
      while state.alive and group.Parent and os.clock() - started < duration * 0.85 do
        local t = math.clamp((os.clock() - started) / duration, 0, 1)
        flow.CurveSize0 = 0.75 * math.sin(t * math.pi * 4)
        flow.CurveSize1 = -0.75 * math.sin(t * math.pi * 4 + 1)
        runservice.Heartbeat:Wait()
      end
    end)
  end
end

function rf.fxcoil(group, origin, finish, primary, secondary, white, width, duration, quality, style)
  local direction, side, up = rf.fxaxes(origin, finish)
  local length = (finish - origin).Magnitude
  local segments = quality == "low" and 6 or 11
  local anchors, points = {}, {}
  for i = 0, segments do
    local part, attachment = rf.fxanchor(group, origin:Lerp(finish, i / segments))
    anchors[i + 1], points[i + 1] = part, attachment
  end
  local tint = ColorSequence.new(primary, secondary)
  for i = 1, segments do
    if config.gunbeamglow then
      rf.fxbeam(group, points[i], points[i + 1], tint, 0.3 * width, duration, false, 0.79)
    end
    rf.fxbeam(group, points[i], points[i + 1],
      ColorSequence.new(i % 3 == 0 and white or primary), 0.09 * width, duration * 0.84, false, 0.04)
  end
  rf.spawn(function()
    local begun = os.clock()
    while state.alive and group.Parent and os.clock() - begun < duration do
      local t = os.clock() - begun
      local fading = math.clamp(1 - t / duration, 0, 1)
      for i = 2, segments do
        local fraction = (i - 1) / segments
        local wave = math.sin(fraction * math.pi * (style == "Void" and 6 or 4) - t * 26)
        local wave2 = math.cos(fraction * math.pi * 5 - t * 21)
        local amplitude = math.min(1.2, length * 0.035) * fading * math.sin(fraction * math.pi)
        anchors[i].Position = origin:Lerp(finish, fraction)
          + side * wave * amplitude + up * wave2 * amplitude
      end
      runservice.Heartbeat:Wait()
    end
  end)
end

function rf.createbeam(handle, start, finish, impact, options)
  options = options or {}
  if not state.alive or (not flags.fx and not options.preview) then return nil end
  if typeof(finish) ~= "Vector3" then return nil end
  local origin = rf.resolveorigin(start) or rf.resolveorigin(handle)
  if not origin then return nil end
  local delta = finish - origin
  local length = delta.Magnitude
  if length < 0.2 or length > (options.preview and 3000 or config.effectsdistance) then return nil end
  local now = os.clock()
  if not options.preview then
    local key = typeof(handle) == "Instance" and handle or gunfired
    if state.lastshot[key] and now - state.lastshot[key] < 0.025 then return nil end
    state.lastshot[key] = now
  end
  local style = options.style or config.gunbeamstyle
  local palette = rf.resources.gunpalette[style] or rf.resources.gunpalette.Prism
  local primary, secondary, white = palette[1], palette[2], palette[3]
  local width = config.gunbeamwidth == "Bold" and 1.48
    or config.gunbeamwidth == "Thin" and 0.64 or 1
  local quality = options.preview and "full" or state.performance.tier
  local minimal = style == "Minimal"
  local special = style == "Lightning" or style == "Lava" or style == "Void"
  local duration = minimal and 0.16 or special and 0.42 or 0.32
  local travel = math.clamp(length / 900, 0.055, 0.18)
  local group = rf.create("Folder", {Name = "VantaGunBeam"}, rf.resources.fxroot)
  debris:AddItem(group, 1.35)
  local startpart, a0 = rf.fxanchor(group, origin)
  local hitpart, a1 = rf.fxanchor(group, finish)
  if style == "Lightning" then
    rf.fxdischarge(group, origin, finish, primary, secondary, white, width, duration, quality)
  elseif style == "Lava" or style == "Ember" then
    rf.fxmolten(group, origin, finish, primary, secondary, white, width,
      style == "Lava" and duration or duration * 0.73, quality)
  elseif style == "Void" or style == "Ion" or style == "Prism" then
    rf.fxcoil(group, origin, finish, primary, secondary, white, width, duration, quality, style)
  else
    local tint = ColorSequence.new(primary, secondary)
    if config.gunbeamglow and not minimal then
      rf.fxbeam(group, a0, a1, tint, 0.85 * width, duration, true, 0.81)
    end
    local main = rf.fxbeam(group, a0, a1, tint, (minimal and 0.11 or 0.29) * width,
      duration * 0.88, style == "Arc", minimal and 0.16 or 0.14)
    main.Segments = style == "Arc" and 24 or 2
    rf.fxbeam(group, a0, a1, ColorSequence.new(white),
      (minimal and 0.034 or 0.08) * width, duration * 0.66, false, 0.02)
    if style == "Arc" then
      local arc = rf.fxbeam(group, a0, a1, ColorSequence.new(secondary, white),
        0.1 * width, duration, true, 0.28)
      arc.CurveSize0 = -1.6
      arc.CurveSize1 = 1.3
      tweenservice:Create(arc, TweenInfo.new(duration * 0.8), {
        CurveSize0 = 1.6, CurveSize1 = -1.3
      }):Play()
    end
  end
  if config.gunbeammuzzle then
    rf.fxball(group, origin, primary, 0.2, minimal and 0.65 or 1.35, 0.18, 0.16)
    rf.fxball(group, origin, white, 0.1, 0.43, 0.13, 0.04)
    if config.gunbeamglow and not minimal then rf.fxlight(startpart, primary, 2, 11, 0.18) end
  end
  if config.gunbeamtracer then
    local orb = rf.create("Part", {
      Name = "BeamPulse", Shape = Enum.PartType.Ball, Material = Enum.Material.Neon,
      Color = white, Size = Vector3.new(0.2, 0.2, 0.2),
      Position = origin, Anchored = true, CanCollide = false, CanTouch = false,
      CanQuery = false, CastShadow = false
    }, group)
    local top = rf.create("Attachment", {Position = Vector3.new(0, 0.13, 0)}, orb)
    local bottom = rf.create("Attachment", {Position = Vector3.new(0, -0.13, 0)}, orb)
    rf.create("Trail", {
      Attachment0 = top, Attachment1 = bottom, Lifetime = 0.13, FaceCamera = true,
      LightEmission = 1, LightInfluence = 0, Color = ColorSequence.new(primary, secondary),
      Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.04), NumberSequenceKeypoint.new(1, 1)
      }),
      WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)
      })
    }, orb)
    tweenservice:Create(orb, TweenInfo.new(travel, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
      Position = finish, Size = Vector3.new(0.035, 0.035, 0.035), Transparency = 1
    }):Play()
  end
  if config.gunbeamimpact then
    local impactcolor = secondary
    if typeof(impact) == "Instance" and impact:IsA("BasePart") then
      local model = impact:FindFirstAncestorOfClass("Model")
      if model and model:FindFirstChildOfClass("Humanoid") then
        impactcolor = Color3.fromRGB(255, 100, 153)
      end
    end
    rf.delay(travel * 0.8, function()
      if not state.alive or not group.Parent or (not flags.fx and not options.preview) then return end
      rf.fxball(group, finish, impactcolor, 0.15, minimal and 0.7 or 1.75, 0.19, 0.16)
      rf.fxball(group, finish, white, 0.1, 0.5, 0.12, 0.04)
      if config.gunbeamglow and not minimal and quality ~= "low" then
        rf.fxlight(hitpart, impactcolor, 2.5, 10, 0.2)
      end
      rf.sparks(group, finish, impactcolor,
        quality == "full" and not minimal and 12 or quality == "low" and 2 or 5)
      if minimal or quality == "low" then return end
      for i = 1, quality == "full" and 6 or 3 do
        local phi = math.random() * math.pi * 2
        local theta = (math.random() - 0.5) * math.pi
        local dir = Vector3.new(math.cos(phi) * math.cos(theta),
          math.sin(theta), math.sin(phi) * math.cos(theta))
        local shard = rf.create("Part", {
          Name = "BeamShard", Material = Enum.Material.Neon,
          Color = i % 2 == 0 and impactcolor or white,
          Size = Vector3.new(0.05, 0.05, 0.34),
          CFrame = CFrame.lookAt(finish + dir * 0.25, finish + dir * 1.25),
          Anchored = true, CanCollide = false, CanTouch = false,
          CanQuery = false, CastShadow = false
        }, group)
        tweenservice:Create(shard, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
          Position = finish + dir * (0.65 + math.random()), Transparency = 1,
          Size = Vector3.new(0.02, 0.02, 0.03)
        }):Play()
      end
    end)
  end
  return group
end

function rf.showgunfx(handle, start, finish, impact)
  return rf.createbeam(handle, start, finish, impact)
end

local parent = coregui
if not pcall(function()
  local probe = Instance.new("Folder")
  probe.Parent = coregui
  probe:Destroy()
end) then
  parent = rf.resources.playergui
end
for _, oldname in ipairs({"VantaStatus", "RoleChamsStatus"}) do
  local oldgui = parent:FindFirstChild(oldname)
  if oldgui then oldgui:Destroy() end
end
local gui = rf.create("ScreenGui", {
  Name = "VantaStatus", ResetOnSpawn = false,
  IgnoreGuiInset = true, ScreenInsets = Enum.ScreenInsets.None,
  ClipToDeviceSafeArea = false, DisplayOrder = 9400, ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, parent)
gui.ScreenInsets = Enum.ScreenInsets.None
local lighting = game:GetService("Lighting")
for _, oldname in ipairs({"VantaPauseBlur", "RoleFXPauseBlur"}) do
  local previousblur = lighting:FindFirstChild(oldname)
  if previousblur then previousblur:Destroy() end
end
local visualstate = {
  textures = {},
  maproots = setmetatable({}, {__mode = "k"}),
  materials = setmetatable({}, {__mode = "k"}),
  mapfx = setmetatable({}, {__mode = "k"}),
  cameras = setmetatable({}, {__mode = "k"}),
  lighting = {}, atmosphere = setmetatable({}, {__mode = "k"}),
  texturegeneration = 0, lightingelapsed = 0,
  worldelapsed = 0, worldscanrunning = nil, worldscaninterval = 15, scannedmap = state.maproot,
  fpssupported = nil, fpsapplied = nil,
  cullcandidates = setmetatable({}, {__mode = "k"}), cullrecords = setmetatable({}, {__mode = "k"}),
  cullcursor = nil, cullelapsed = 0, cullgeneration = 0, postfx = setmetatable({}, {__mode = "k"}),
  water = setmetatable({}, {__mode = "k"})
}
state.visualplus = visualstate

local function visualset(object, property, value)
  return pcall(function() if object[property] ~= value then object[property] = value end end)
end

local function visualremember(records, object, properties)
  local record = records[object]
  if record then return record end
  record = {}
  for property in pairs(properties) do
    local ok, value = pcall(function() return object[property] end)
    if ok then record[property] = value end
  end
  records[object] = record
  return record
end

local function visualrestore(records)
  for object, record in pairs(records) do
    if typeof(object) == "Instance" then
      for property, value in pairs(record) do visualset(object, property, value) end
    end
    records[object] = nil
  end
end

function rf.isvisualworldobject(object)
  if not object or not object.Parent or not object:IsDescendantOf(world) then return false end
  if object:IsDescendantOf(rf.resources.fxroot) or object:IsDescendantOf(rf.resources.coinfolder)
    or object:IsDescendantOf(rf.resources.trackingfolder) then return false end
  local camera = world.CurrentCamera
  if camera and object:IsDescendantOf(camera) then return false end
  local current = object
  local top
  while current and current ~= world do
    local name = current.Name:lower()
    if current:IsA("Tool") or current:IsA("Accessory") or current:IsA("Accoutrement") then return false end
    if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then return false end
    if name == "handle" or name == "blade" or name == "knife" or name == "gun"
      or name == "weapon" or name == "weapons" or name == "revolver" or name == "pistol"
      or name == "gundrop" or name == "droppedgun" or name == "gunpickup"
      or name == "droppedrevolver" or name == "droppedpistol" or name == "raggy"
      or name:find("knife", 1, true) or name:find("weapon", 1, true)
      or name:find("revolver", 1, true) or name:find("gunraycast", 1, true)
      or name:find("gundrop", 1, true) or name:find("gunpickup", 1, true)
      or name:find("chroma", 1, true) or name:find("sword", 1, true)
      or name:find("cosmetic", 1, true) or name:find("inventory", 1, true)
      or name == "coincontainer" or name == "coinvisual" then return false end
    top = current
    current = current.Parent
  end
  local root = state.maproot
  if root and root.Parent and object:IsDescendantOf(root) then return true end
  if not top or top == world or not (top:IsA("Model") or top:IsA("Folder")) then return false end
  local name = top.Name:lower()
  if name == "lobby" or name == "map" or name == "maps" or name == "currentmap"
    or name == "activemap" or name == "mapcontainer" or name == "workspace" then return true end
  local cached = visualstate.maproots[top]
  local now = os.clock()
  if cached and now - cached.checked < 2 then return cached.valid end
  local valid = top:FindFirstChild("Spawns", true) ~= nil
  visualstate.maproots[top] = {valid = valid, checked = now}
  return valid
end

function rf.culleligible(object)
  if not object or not object.Parent or not object:IsA("BasePart") then return false end
  if not object.Anchored or object.CanCollide or object.CanTouch then return false end
  local size = object.Size
  if size.X > 12 or size.Y > 12 or size.Z > 12 then return false end
  if object:FindFirstChildOfClass("ProximityPrompt") or object:FindFirstChildOfClass("ClickDetector") then return false end
  return rf.isvisualworldobject(object)
end

function rf.restoreculling()
  visualstate.cullgeneration += 1
  visualstate.cullcursor = nil
  for object, original in pairs(visualstate.cullrecords) do
    if object.Parent then visualset(object, "LocalTransparencyModifier", original) end
    visualstate.cullrecords[object] = nil
  end
  table.clear(visualstate.cullcandidates)
end

function rf.trackculling(object)
  if not (config.distanceculling or config.frustumculling) then return end
  if rf.culleligible(object) then visualstate.cullcandidates[object] = true end
end

function rf.stepculling(dt)
  if not (config.distanceculling or config.frustumculling) then return end
  visualstate.cullelapsed += dt
  if visualstate.cullelapsed < 0.35 then return end
  visualstate.cullelapsed = 0
  local camera = world.CurrentCamera
  if not camera then return end
  local origin = camera.CFrame.Position
  local viewport = camera.ViewportSize
  local processed = 0
  local object = visualstate.cullcursor
  if not object or not visualstate.cullcandidates[object] then
    object = next(visualstate.cullcandidates)
  end
  local deadline = os.clock() + 0.0008
  while object and processed < 120 and os.clock() < deadline do
    local nextobject = next(visualstate.cullcandidates, object)
    if not object.Parent or not object:IsA("BasePart") or not object.Anchored or object.CanCollide or object.CanTouch then
      local original = visualstate.cullrecords[object]
      if original ~= nil and object.Parent then visualset(object, "LocalTransparencyModifier", original) end
      visualstate.cullrecords[object] = nil
      visualstate.cullcandidates[object] = nil
    else
      local distance = (object.Position - origin).Magnitude
      local hidden = visualstate.cullrecords[object] ~= nil
      local hide = config.distanceculling and distance > (hidden and 205 or 250)
      if not hide and config.frustumculling and distance > 75 then
        local screen = camera:WorldToViewportPoint(object.Position)
        local margin = hidden and 220 or 140
        hide = screen.Z < 0 or screen.X < -margin or screen.Y < -margin
          or screen.X > viewport.X + margin or screen.Y > viewport.Y + margin
      end
      if hide then
        if visualstate.cullrecords[object] == nil then
          visualstate.cullrecords[object] = object.LocalTransparencyModifier
        end
        if object.LocalTransparencyModifier ~= 1 then visualset(object, "LocalTransparencyModifier", 1) end
      else
        local original = visualstate.cullrecords[object]
        if original ~= nil then
          visualset(object, "LocalTransparencyModifier", original)
          visualstate.cullrecords[object] = nil
        end
      end
    end
    processed += 1
    object = nextobject
  end
  visualstate.cullcursor = object
end

function rf.refreshperformancegraphics()
  if not (config.distanceculling or config.frustumculling) then
    rf.restoreculling()
  else
    visualstate.cullcursor = nil
    visualstate.cullelapsed = 1
    rf.scanworldgraphics()
  end
  if not config.disablepostfx then visualrestore(visualstate.postfx) end
  if not config.lowqualitywater then visualrestore(visualstate.water) end
  if config.disablepostfx then
    for _, object in ipairs(lighting:GetDescendants()) do
      if object:IsA("BloomEffect") or object:IsA("BlurEffect") or object:IsA("SunRaysEffect")
        or object:IsA("DepthOfFieldEffect") or object:IsA("ColorCorrectionEffect") then
        if object.Name ~= "VantaPauseBlur" then
          visualremember(visualstate.postfx, object, {Enabled = true})
          visualset(object, "Enabled", false)
        end
      end
    end
  end
  if config.lowqualitywater then
    local terrain = world:FindFirstChildOfClass("Terrain")
    if terrain then
      visualremember(visualstate.water, terrain,
        {WaterWaveSize = true, WaterWaveSpeed = true, WaterReflectance = true})
      visualset(terrain, "WaterWaveSize", 0)
      visualset(terrain, "WaterWaveSpeed", 0)
      visualset(terrain, "WaterReflectance", 0)
    end
  end
end

function rf.applyworldobject(object)
  if not state.alive or not object or not object.Parent then return end
  if not (object:IsA("BasePart") or object:IsA("Decal") or object:IsA("Texture") or object:IsA("SpecialMesh") or object:IsA("SurfaceAppearance") or object:IsA("ParticleEmitter") or object:IsA("Beam") or object:IsA("Trail") or object:IsA("Fire") or object:IsA("Smoke") or object:IsA("Sparkles") or object:IsA("Light")) then return end
  if not rf.isvisualworldobject(object) then return end
  if config.removetextures then
    if object:IsA("Decal") or object:IsA("Texture") then
      visualremember(visualstate.textures, object, {Transparency = true})
      visualset(object, "Transparency", 1)
    elseif object:IsA("MeshPart") then
      visualremember(visualstate.textures, object, {TextureID = true})
      visualset(object, "TextureID", "")
    elseif object:IsA("SpecialMesh") then
      visualremember(visualstate.textures, object, {TextureId = true})
      visualset(object, "TextureId", "")
    elseif object:IsA("SurfaceAppearance") then
      local original = visualstate.textures[object]
      if not original then
        visualstate.textures[object] = {Parent = object.Parent}
        visualset(object, "Parent", nil)
      end
    end
  end
  if (config.removetextures or config.simplematerials) and object:IsA("BasePart") then
    local original = visualremember(visualstate.materials, object,
      {Material = true, Reflectance = true, MaterialVariant = true, CastShadow = true})
    visualset(object, "MaterialVariant", "")
    visualset(object, "Material", Enum.Material.SmoothPlastic)
    if config.simplematerials then
      visualset(object, "Reflectance", 0)
      visualset(object, "CastShadow", false)
    else
      if original.Reflectance ~= nil then visualset(object, "Reflectance", original.Reflectance) end
      if original.CastShadow ~= nil then visualset(object, "CastShadow", original.CastShadow) end
    end
  end
  if config.disablemapfx and (object:IsA("ParticleEmitter") or object:IsA("Beam")
    or object:IsA("Trail") or object:IsA("Fire") or object:IsA("Smoke")
    or object:IsA("Sparkles") or object:IsA("PointLight")
    or object:IsA("SpotLight") or object:IsA("SurfaceLight")) then
    visualremember(visualstate.mapfx, object, {Enabled = true})
    visualset(object, "Enabled", false)
  end
end

function rf.scanworldgraphics()
  if not state.alive or not (config.removetextures or config.simplematerials or config.disablemapfx
    or config.distanceculling or config.frustumculling) then return end
  local generation = visualstate.texturegeneration
  if visualstate.worldscanrunning == generation then return end
  visualstate.worldscanrunning = generation
  rf.spawn(function()
    local ok = pcall(function()
      local queue, head = {world}, 1
      local deadline = os.clock() + 0.001
      while head <= #queue do
        if not state.alive or generation ~= visualstate.texturegeneration then break end
        local parent = queue[head]
        head += 1
        for _, object in ipairs(parent:GetChildren()) do
          if not state.alive or generation ~= visualstate.texturegeneration then return end
          queue[#queue + 1] = object
          if config.removetextures or config.simplematerials or config.disablemapfx then rf.applyworldobject(object) end
          if config.distanceculling or config.frustumculling then rf.trackculling(object) end
          if os.clock() >= deadline then
            runservice.Heartbeat:Wait()
            deadline = os.clock() + 0.001
          end
        end
      end
    end)
    if visualstate.worldscanrunning == generation then
      visualstate.worldscanrunning = nil
    end
  end)
end

function rf.refreshworldgraphics()
  visualstate.texturegeneration += 1
  visualstate.worldelapsed = 0
  if not config.removetextures then visualrestore(visualstate.textures) end
  if not (config.simplematerials or config.removetextures) then
    visualrestore(visualstate.materials)
  elseif not config.simplematerials then
    for object, original in pairs(visualstate.materials) do
      if typeof(object) == "Instance" and object.Parent then
        if original.Reflectance ~= nil then visualset(object, "Reflectance", original.Reflectance) end
        if original.CastShadow ~= nil then visualset(object, "CastShadow", original.CastShadow) end
      end
    end
  end
  if not config.disablemapfx then visualrestore(visualstate.mapfx) end
  rf.scanworldgraphics()
end

function rf.clearlegacyknifevfx()
  for _, member in ipairs(players:GetPlayers()) do
    local character = member.Character
    if character then
      for _, object in ipairs(character:GetDescendants()) do
        if object.Name == "VantaKnifeGlow" or object.Name == "VantaKnifeMarker" then
          object:Destroy()
        end
      end
    end
  end
end

function rf.applylightingvisuals()
  local current = visualstate.lighting
  local function enforce(key, value, enabled)
    if enabled then
      if current[key] == nil then
        local ok, old = pcall(function() return lighting[key] end)
        if ok then current[key] = old end
      end
      visualset(lighting, key, value)
    elseif current[key] ~= nil then
      visualset(lighting, key, current[key])
      current[key] = nil
    end
  end
  enforce("Brightness", 3, config.fullbright)
  enforce("Ambient", Color3.fromRGB(190, 190, 190), config.fullbright)
  enforce("OutdoorAmbient", Color3.fromRGB(190, 190, 190), config.fullbright)
  enforce("FogStart", 0, config.clearfog)
  enforce("FogEnd", 100000, config.clearfog)
  enforce("GlobalShadows", false, config.noshadows)
  for _, effect in ipairs(lighting:GetChildren()) do
    if effect:IsA("Atmosphere") then
      if config.clearfog then
        visualremember(visualstate.atmosphere, effect, {Density = true, Haze = true, Glare = true})
        visualset(effect, "Density", 0)
        visualset(effect, "Haze", 0)
        visualset(effect, "Glare", 0)
      elseif visualstate.atmosphere[effect] then
        for property, value in pairs(visualstate.atmosphere[effect]) do visualset(effect, property, value) end
        visualstate.atmosphere[effect] = nil
      end
    end
  end
end

function rf.applyfov()
  local camera = world.CurrentCamera
  if not camera then return end
  if visualstate.cameras[camera] == nil then visualstate.cameras[camera] = camera.FieldOfView end
  local selected = config.fovmode == "Default" and visualstate.cameras[camera] or tonumber(config.fovmode)
  if selected and math.abs(camera.FieldOfView - selected) > 0.01 then
    visualset(camera, "FieldOfView", selected)
  end
end

function rf.applyfpscap(quiet)
  local setter = type(setfpscap) == "function" and setfpscap
    or type(env.setfpscap) == "function" and env.setfpscap
    or type(_G.setfpscap) == "function" and _G.setfpscap or nil
  visualstate.fpssupported = setter ~= nil
  if not setter then
    visualstate.fpsapplied = nil
    if not quiet then
      rf.notification("FPS cap unavailable", "setfpscap is not available in this executor", nil,
        "alert-circle", Color3.fromRGB(255, 160, 116), "visual:fpsunsupported")
    end
    return false
  end
  if not visualstate.fpscaptured then
    visualstate.fpscaptured = true
    local getter = type(getfpscap) == "function" and getfpscap or type(env.getfpscap) == "function" and env.getfpscap
    if getter then
      local captured, value = pcall(getter)
      if captured and finitenumber(value) and value >= 0 then visualstate.originalfpscap = value end
    end
  end
  local target = config.fpscapmode == "Unlimited" and 0 or tonumber(config.fpscapmode)
  if not target then return false end
  local ok, result = pcall(setter, target)
  if ok and result ~= false then
    visualstate.fpsapplied = target
    if not quiet then
      rf.notification("FPS cap", config.fpscapmode == "Unlimited" and "Unlimited requested"
        or tostring(target) .. " FPS cap applied", nil,
        "check-circle", Color3.fromRGB(183, 239, 188), "visual:fpsapplied")
    end
    return true
  end
  visualstate.fpsapplied = nil
  if not quiet then
    rf.notification("FPS cap unavailable", tostring(result or "setfpscap rejected the selected frame limit"):sub(1, 115), nil,
      "alert-circle", Color3.fromRGB(255, 160, 116), "visual:fpsrejected")
  end
  return false
end

function rf.cyclefpscap()
  local index = table.find(fpscapmodes, config.fpscapmode) or 1
  local previousmode = config.fpscapmode
  config.fpscapmode = fpscapmodes[index % #fpscapmodes + 1]
  if not rf.applyfpscap(false) then
    config.fpscapmode = previousmode
    rf.updatehud()
    return false
  end
  savepreferences()
  rf.updatehud()
  return true
end

function rf.cyclefov()
  local index = table.find(fovmodes, config.fovmode) or 1
  config.fovmode = fovmodes[index % #fovmodes + 1]
  rf.applyfov()
  savepreferences()
  rf.updatehud()
  return config.fovmode
end

function rf.stopvisualplus()
  if visualstate.originalfpscap ~= nil then
    local setter = type(setfpscap) == "function" and setfpscap or type(env.setfpscap) == "function" and env.setfpscap
    if setter then pcall(setter, visualstate.originalfpscap) end
  end
  visualstate.texturegeneration += 1
  visualstate.worldscanrunning = nil
  if visualstate.pendingobjects then table.clear(visualstate.pendingobjects) end
  visualrestore(visualstate.textures)
  visualrestore(visualstate.materials)
  visualrestore(visualstate.mapfx)
  rf.restoreculling()
  visualrestore(visualstate.postfx)
  visualrestore(visualstate.water)
  for key, value in pairs(visualstate.lighting) do visualset(lighting, key, value) end
  table.clear(visualstate.lighting)
  visualrestore(visualstate.atmosphere)
  for camera, value in pairs(visualstate.cameras) do visualset(camera, "FieldOfView", value) end
end

local blur = rf.create("BlurEffect", {Name = "VantaPauseBlur", Size = 0, Enabled = false}, lighting)
rf.resources.noticeholder = rf.create("Frame", {
  Name = "AchievementNotifications", Position = UDim2.fromScale(0, 0), Size = UDim2.fromScale(1, 1),
  BackgroundTransparency = 1, BorderSizePixel = 0, Active = false, ZIndex = 75
}, gui)
local backdrop = rf.create("Frame", {
  Name = "Backdrop", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0,
  BackgroundColor3 = uitheme.backdrop, BackgroundTransparency = 0.43,
  Active = false, Visible = false, ZIndex = 10
}, gui)
local menu = rf.create("Frame", {
  AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, -8),
  Size = UDim2.fromOffset(602, 582), BackgroundTransparency = 1, ZIndex = 11
}, backdrop)
local menuscale = rf.create("UIScale", {Scale = 1}, menu)
local pagecontent = rf.create("Frame", {
  Position = UDim2.fromOffset(0, 152), Size = UDim2.new(1, 0, 1, -162),
  BackgroundTransparency = 1, ZIndex = 11
}, menu)
local pagetitle = rf.create("TextLabel", {
  Position = UDim2.fromOffset(0, 4), Size = UDim2.new(1, 0, 0, 28),
  BackgroundTransparency = 1, Text = "VANTA", Font = Enum.Font.GothamBold,
  TextSize = 19, TextColor3 = uitheme.text, TextXAlignment = Enum.TextXAlignment.Center,
  ZIndex = 13
}, menu)
local searchinput, searchview, searchclear, searchcatalog, searchslots, searchmatches = nil, nil, nil, {}, {}, {}
rf.resources.searchshadow = rf.create("Frame", {
  Name = "SearchBarShadow", Position = UDim2.fromOffset(9, 43),
  Size = UDim2.fromOffset(584, 45), BorderSizePixel = 0,
  BackgroundColor3 = uitheme.shadow, ZIndex = 16
}, menu)
rf.resources.searchborder = rf.create("Frame", {
  Name = "SearchBarBorder", Position = UDim2.fromOffset(9, 39),
  Size = UDim2.fromOffset(584, 45), BorderSizePixel = 0,
  BackgroundColor3 = uitheme.border, ZIndex = 17
}, menu)
rf.resources.searchsurface = rf.create("Frame", {
  Position = UDim2.fromOffset(4, 4), Size = UDim2.new(1, -8, 1, -8),
  BackgroundColor3 = uitheme.surface, BorderSizePixel = 0, ZIndex = 18
}, rf.resources.searchborder)
rf.resources.searchstroke = rf.create("UIStroke", {Color = uitheme.stroke, Thickness = 1}, rf.resources.searchsurface)
rf.resources.searchasset = rf.lucideasset("search")
if rf.resources.searchasset then
  rf.create("ImageLabel", {
    Position = UDim2.fromOffset(15, 12), Size = UDim2.fromOffset(13, 13),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Image = rf.resources.searchasset.Url, ImageRectOffset = rf.resources.searchasset.ImageRectOffset,
    ImageRectSize = rf.resources.searchasset.ImageRectSize, ImageColor3 = uitheme.textmuted,
    ScaleType = Enum.ScaleType.Fit, ZIndex = 19
  }, rf.resources.searchsurface)
else
  local lens = rf.create("Frame", {
    Position = UDim2.fromOffset(16, 12), Size = UDim2.fromOffset(9, 9),
    BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 19
  }, rf.resources.searchsurface)
  rf.create("UICorner", {CornerRadius = UDim.new(1, 0)}, lens)
  rf.create("UIStroke", {Color = uitheme.textmuted, Thickness = 2}, lens)
  rf.create("Frame", {
    Position = UDim2.fromOffset(23, 21), Size = UDim2.fromOffset(6, 2),
    Rotation = 45, BackgroundColor3 = uitheme.textmuted,
    BorderSizePixel = 0, ZIndex = 19
  }, rf.resources.searchsurface)
end
searchinput = rf.create("TextBox", {
  Name = "FuzzySearchInput", Position = UDim2.fromOffset(36, 0),
  Size = UDim2.new(1, -83, 1, 0), BackgroundTransparency = 1,
  Text = "", PlaceholderText = "Search settings, actions, menus...",
  TextColor3 = uitheme.text,
  PlaceholderColor3 = uitheme.textdim,
  Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
  TextYAlignment = Enum.TextYAlignment.Center, ClearTextOnFocus = false,
  TextTruncate = Enum.TextTruncate.AtEnd, MultiLine = false,
  ZIndex = 19
}, rf.resources.searchsurface)
searchclear = rf.create("TextButton", {
  Position = UDim2.new(1, -32, 0, 0), Size = UDim2.fromOffset(31, 37),
  BackgroundTransparency = 1, Text = "X", TextSize = 14,
  Font = Enum.Font.GothamMedium, TextColor3 = uitheme.textmuted,
  AutoButtonColor = false, Visible = false, ZIndex = 20
}, rf.resources.searchsurface)
rf.resources.searchhint = rf.create("TextLabel", {
  Name = "FocusShortcut", Position = UDim2.new(1, -36, 0, 8),
  Size = UDim2.fromOffset(26, 21), BackgroundColor3 = uitheme.surfacealt,
  BorderSizePixel = 0, Font = Enum.Font.Code, Text = "/", TextSize = 15,
  TextColor3 = uitheme.accent, ZIndex = 19
}, rf.resources.searchsurface)
rf.create("UICorner", {CornerRadius = UDim.new(0, 4)}, rf.resources.searchhint)
searchinput.Focused:Connect(function()
  tweenservice:Create(rf.resources.searchstroke, TweenInfo.new(0.13, Enum.EasingStyle.Quad), {
    Color = uitheme.strokeselected
  }):Play()
  rf.resources.searchhint.Visible = false
end)
searchinput.FocusLost:Connect(function()
  tweenservice:Create(rf.resources.searchstroke, TweenInfo.new(0.13, Enum.EasingStyle.Quad), {
    Color = uitheme.stroke
  }):Play()
  rf.resources.searchhint.Visible = searchinput.Text == ""
end)
local currentpage, pages, controls = "main", {}, {}
rf.resources.resetconfirmbutton = nil
local definitions
rf.resources.menuheighttarget = 582
rf.resources.menuresizetween = nil
rf.resources.farmstatuslabel = nil
local pageparents, pagetitles
rf.resources.keynames = {
  RightControl = "Right Ctrl", LeftControl = "Left Ctrl",
  RightShift = "Right Shift", LeftShift = "Left Shift",
  RightAlt = "Right Alt", LeftAlt = "Left Alt",
  Return = "Enter", Backquote = "`", Space = "Space",
  CapsLock = "Caps Lock", Tab = "Tab"
}

function rf.bindname(name)
  return rf.resources.keynames[name] or tostring(name):gsub("(%l)(%u)", "%1 %2")
end

function rf.setguibind(name)
  if not validkeycode(name) then return false end
  for action, selected in pairs(config.keybinds) do
    if selected == name then config.keybinds[action] = "Unbound" end
  end
  config.guikeybind = name
  state.bindinggui = false
  if rf.refreshhotkeys then rf.refreshhotkeys() end
  state.hotkeysheld[name] = os.clock()
  if type(writefile) == "function" then
    pcall(writefile, guikeyfile, name)
  end
  rf.updatehud()
  savepreferences()
  return true
end

function rf.menutextwidth(value, size)
  local ok, measurement = pcall(textservice.GetTextSize, textservice, tostring(value), size,
    Enum.Font.Arcade, Vector2.new(10000, 100))
  return ok and measurement.X or #tostring(value) * size * 0.6
end

function rf.menubutton(frame, title, position, size, action)
  local shadow = rf.create("Frame", {
    Position = position + UDim2.fromOffset(0, 5), Size = size,
    BackgroundColor3 = uitheme.shadow, BorderSizePixel = 0, ZIndex = 11
  }, frame)
  local outer = rf.create("Frame", {
    Position = position, Size = size, BackgroundColor3 = uitheme.border,
    BorderSizePixel = 0, ZIndex = 12
  }, frame)
  local face = rf.create("TextButton", {
    Position = UDim2.fromOffset(4, 4), Size = UDim2.new(1, -8, 1, -8),
    Text = "", TextTransparency = 1, Font = Enum.Font.Arcade, TextSize = 17,
    TextColor3 = uitheme.text, ClipsDescendants = true,
    BackgroundColor3 = uitheme.surface, BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 13
  }, outer)
  local stroke = rf.create("UIStroke", {Thickness = 1, Color = uitheme.stroke}, face)
  local clip = rf.create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, -16, 1, -4),
    BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true,
    Active = false, ZIndex = 14
  }, face)
  local name = rf.create("TextLabel", {
    Text = "", TextSize = 17, Font = Enum.Font.Arcade,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0.5, 0.5),
    TextColor3 = face.TextColor3, TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
    BackgroundTransparency = 1, TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd,
    Active = false, ZIndex = 14
  }, clip)
  local stateview = rf.create("TextLabel", {
    Text = "", Size = UDim2.fromOffset(41, 30),
    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
    TextColor3 = face.TextColor3, TextSize = 14, Font = Enum.Font.Arcade,
    BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
    Active = false, Visible = false, ZIndex = 15
  }, face)
  local currenttext = ""
  local textlast, widthlast
  rf.resources.marquees = rf.resources.marquees or setmetatable({}, {__mode = "k"})
  local function present()
    local content = currenttext
    local width = face.AbsoluteSize.X
    if width <= 0 then return end
    if textlast == content and widthlast == width then return end
    textlast, widthlast = content, width
    local prefix, status = content:match("^(.-)%s+%[([A-Z]+)%]$")
    local hasstatus = prefix and (status == "ON" or status == "OFF")
    local displayed = hasstatus and prefix or content
    local left, right = 8, hasstatus and 51 or 8
    clip.AnchorPoint = Vector2.new(0, 0.5)
    clip.Size = UDim2.new(1, -(left + right), 1, -4)
    clip.Position = UDim2.new(0, left, 0.5, 0)
    stateview.Visible = not not hasstatus
    stateview.Text = hasstatus and status or ""
    stateview.TextColor3 = status == "ON" and uitheme.accent or uitheme.textmuted
    name.Text = displayed
    name.TextSize = 17
    name.TextTruncate = Enum.TextTruncate.None
    name.TextScaled = false
    local scale = 1
    local ancestor = face
    while ancestor and ancestor:IsA("GuiObject") do
      local component = ancestor:FindFirstChildOfClass("UIScale")
      if component then scale *= component.Scale end
      ancestor = ancestor.Parent
    end
    local available = math.max(1, width / math.max(scale, 0.01) - left - right)
    local measured = rf.menutextwidth(displayed, 17) + 4
    if measured > available + 1 then
      name.AnchorPoint = Vector2.new(0, 0.5)
      name.TextXAlignment = Enum.TextXAlignment.Left
      name.Size = UDim2.new(0, measured, 1, 0)
      name.Position = UDim2.fromScale(0, 0.5)
      rf.resources.marquees[name] = {clip = clip, face = face, overflow = measured - available, started = os.clock(), offset = 0}
    else
      rf.resources.marquees[name] = nil
      name.AnchorPoint = Vector2.new(0.5, 0.5)
      name.TextXAlignment = Enum.TextXAlignment.Center
      name.Size = UDim2.fromScale(1, 1)
      name.Position = UDim2.fromScale(0.5, 0.5)
    end
  end
  local function setlabel(value)
    currenttext = tostring(value or "")
    present()
  end
  local selected, hovered = false, false
  local function paint()
    face.BackgroundColor3 = uibuttoncolor(selected, hovered)
    stroke.Color = uibuttonstroke(selected, hovered)
    face.TextColor3 = selected and uitheme.text or uitheme.textmuted
    stateview.TextColor3 = stateview.Text == "ON" and uitheme.accent or uitheme.textmuted
  end
  local function setselected(value)
    selected = value == true
    paint()
  end
  face:GetPropertyChangedSignal("AbsoluteSize"):Connect(present)
  face:GetPropertyChangedSignal("TextColor3"):Connect(function()
    name.TextColor3 = face.TextColor3
  end)
  face.MouseEnter:Connect(function() hovered = true paint() end)
  face.MouseLeave:Connect(function() hovered = false paint() end)
  face.Activated:Connect(function()
    if state.alive and not state.stopping then rf.safe("menu:" .. tostring(title), action) end
  end)
  setlabel(title)
  paint()
  rf.defer(present)
  return {face = face, outer = outer, shadow = shadow, name = name, status = stateview,
    setlabel = setlabel, setselected = setselected}
end

rf.resources.mobilescroll = rf.create("ScrollingFrame", {
  Name = "MobileMenuScroll", Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0, 0),
  BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, Active = true,
  ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 3,
  ScrollBarImageColor3 = uitheme.scroll, ZIndex = 11,
  CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.None
}, backdrop)
rf.resources.mobilelaunchershadow = rf.create("Frame", {
  Name = "VantaLauncherShadow", AnchorPoint = Vector2.new(0.5, 0.5),
  Position = UDim2.fromScale(config.mobilebuttonx, config.mobilebuttony),
  Size = UDim2.fromOffset(96, 43), BackgroundColor3 = uitheme.shadow,
  BackgroundTransparency = 0.32, BorderSizePixel = 0, Visible = false, ZIndex = 248
}, gui)
rf.create("UICorner", {CornerRadius = UDim.new(0, 14)}, rf.resources.mobilelaunchershadow)
rf.resources.mobilelauncher = rf.create("TextButton", {
  Name = "VantaMobileButton", AnchorPoint = Vector2.new(0.5, 0.5),
  Position = UDim2.fromScale(config.mobilebuttonx, config.mobilebuttony),
  Size = UDim2.fromOffset(94, 40), BackgroundColor3 = uitheme.surfacealt,
  Text = "", AutoButtonColor = false, BorderSizePixel = 0,
  Visible = false, Active = true, ZIndex = 250
}, gui)
rf.create("UICorner", {CornerRadius = UDim.new(0, 13)}, rf.resources.mobilelauncher)
rf.create("UIStroke", {Color = uitheme.strokeselected, Thickness = 1, Transparency = 0.12}, rf.resources.mobilelauncher)
rf.resources.mobilelauncher.MouseEnter:Connect(function() rf.resources.mobilelauncher.BackgroundColor3 = uitheme.hover end)
rf.resources.mobilelauncher.MouseLeave:Connect(function() rf.resources.mobilelauncher.BackgroundColor3 = uitheme.surfacealt end)
rf.resources.mobileglyph = rf.create("TextLabel", {
  Name = "VantaGlyph", Position = UDim2.fromOffset(6, 6),
  Size = UDim2.fromOffset(28, 28), BackgroundColor3 = uitheme.selected,
  Text = "V", Font = Enum.Font.Arcade, TextSize = 16,
  TextColor3 = uitheme.accentbright, BorderSizePixel = 0,
  ZIndex = 251, Active = false
}, rf.resources.mobilelauncher)
rf.create("UICorner", {CornerRadius = UDim.new(0, 8)}, rf.resources.mobileglyph)
rf.create("TextLabel", {
  Name = "VantaWordmark", Position = UDim2.fromOffset(37, 0),
  Size = UDim2.fromOffset(54, 40), BackgroundTransparency = 1,
  Text = "VANTA", Font = Enum.Font.Arcade, TextSize = 11,
  TextColor3 = uitheme.text, ZIndex = 251, Active = false
}, rf.resources.mobilelauncher)
rf.resources.mobileclose = rf.create("TextButton", {
  Name = "MobileClose", Position = UDim2.fromOffset(555, 5), Size = UDim2.fromOffset(37, 30),
  Text = "X", Font = Enum.Font.Arcade, TextSize = 15, TextColor3 = uitheme.accentbright,
  BackgroundColor3 = uitheme.hover, BorderSizePixel = 0,
  AutoButtonColor = false, Visible = false, ZIndex = 50
}, menu)
rf.create("UICorner", {CornerRadius = UDim.new(0, 8)}, rf.resources.mobileclose)
rf.resources.mobileclose.MouseEnter:Connect(function() rf.resources.mobileclose.BackgroundColor3 = uitheme.selected end)
rf.resources.mobileclose.MouseLeave:Connect(function() rf.resources.mobileclose.BackgroundColor3 = uitheme.hover end)
rf.resources.mobileclose.Activated:Connect(function() if rf.showmenu then rf.showmenu(false) end end)
local mobiletouch, mobileorigin, mobileposition, mobiledragged
rf.resources.mobilelauncher.InputBegan:Connect(function(input)
  if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
  mobiletouch, mobileorigin, mobileposition, mobiledragged = input, input.Position, rf.resources.mobilelauncher.Position, false
end)
table.insert(state.connections, userinputservice.InputChanged:Connect(function(input)
  if not mobiletouch or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input ~= mobiletouch) then return end
  if mobiletouch.UserInputType == Enum.UserInputType.Touch and input ~= mobiletouch then return end
  local difference = input.Position - mobileorigin
  if difference.Magnitude > 8 then mobiledragged = true end
  if not mobiledragged then return end
  local viewport = world.CurrentCamera and world.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
  local x = math.clamp(mobileposition.X.Scale + difference.X / viewport.X, 0.09, 0.91)
  local y = math.clamp(mobileposition.Y.Scale + difference.Y / viewport.Y, 0.12, 0.88)
  rf.resources.mobilelauncher.Position = UDim2.fromScale(x, y)
  rf.resources.mobilelaunchershadow.Position = UDim2.fromScale(x, y) + UDim2.fromOffset(2, 4)
end))
table.insert(state.connections, userinputservice.InputEnded:Connect(function(input)
  if not mobiletouch or input ~= mobiletouch then return end
  mobiletouch = nil
  if mobiledragged then
    config.mobilebuttonx = rf.resources.mobilelauncher.Position.X.Scale
    config.mobilebuttony = rf.resources.mobilelauncher.Position.Y.Scale
    savepreferences()
  end
end))
rf.resources.mobilelauncher.Activated:Connect(function()
  if mobiledragged then mobiledragged = false return end
  if rf.showmenu then rf.showmenu(not state.menuopen) end
end)
function rf.ismobilelayout()
  if localplayer.Name:lower() == "4tgw" and config.mobilelayout == "Mobile" then return true end
  if localplayer.Name:lower() == "4tgw" and config.mobilelayout == "Desktop" then return false end
  local viewport = world.CurrentCamera and world.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
  return userinputservice.TouchEnabled and (not userinputservice.KeyboardEnabled or viewport.X <= 850)
end
function rf.fitmenu()
  local viewport = world.CurrentCamera and world.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
  local mobile = rf.ismobilelayout()
  rf.resources.mobilelaunchershadow.Position = rf.resources.mobilelauncher.Position + UDim2.fromOffset(2, 4)
  if mobile then
    if menu.Parent ~= rf.resources.mobilescroll then menu.Parent = rf.resources.mobilescroll end
    rf.resources.mobilescroll.Visible = true
    menu.AnchorPoint = Vector2.new(0.5, 0)
    menu.Position = UDim2.new(0.5, 0, 0, 12)
    menuscale.Scale = math.clamp((viewport.X - 24) / 615, 0.15, 1.15)
    rf.resources.mobilescroll.CanvasSize = UDim2.fromOffset(0, math.ceil(rf.resources.menuheighttarget * menuscale.Scale + 34))
  else
    if menu.Parent ~= backdrop then menu.Parent = backdrop end
    rf.resources.mobilescroll.Visible = false
    menu.AnchorPoint = Vector2.new(0.5, 0.5)
    menu.Position = UDim2.new(0.5, 0, 0.5, -8)
    menuscale.Scale = math.clamp(math.min((viewport.X - 28) / 615,
      (viewport.Y - 24) / math.max(250, rf.resources.menuheighttarget + 24)), 0.15, 1)
  end
  rf.resources.mobilelauncher.Visible = mobile and state.alive and not state.menuopen
  rf.resources.mobilelaunchershadow.Visible = rf.resources.mobilelauncher.Visible
  rf.resources.mobileclose.Visible = mobile
end
function rf.togglemobilelayout()
  if localplayer.Name:lower() ~= "4tgw" then return false end
  config.mobilelayout = rf.ismobilelayout() and "Desktop" or "Mobile"
  rf.fitmenu()
  savepreferences()
  if rf.notification then
    rf.notification("Developer display", "Mobile layout " .. (rf.ismobilelayout() and "enabled" or "disabled"), nil,
      "smartphone", Color3.fromRGB(176, 150, 235), "vanta:mobilemode")
  end
  return true
end
local camerawatch
local function bindviewport()
  if camerawatch then camerawatch:Disconnect() camerawatch = nil end
  local camera = world.CurrentCamera
  if camera then camerawatch = camera:GetPropertyChangedSignal("ViewportSize"):Connect(rf.fitmenu) end
  rf.fitmenu()
end
bindviewport()
table.insert(state.connections, world:GetPropertyChangedSignal("CurrentCamera"):Connect(bindviewport))

local startergui = game:GetService("StarterGui")
local savedguis, guiwatches, savedcore, savedmouse = {}, {}, {}, nil
local roots = {coregui, rf.resources.playergui}
local mousebind = "VantaPauseMouse_" .. tostring(localplayer.UserId)
local selectpage, reconnect, leave, returnhome

function rf.hideothergui(object)
  if not config.showmenu or not object:IsA("ScreenGui") or object == gui or savedguis[object] ~= nil then return end
  local ok, enabled = pcall(function() return object.Enabled end)
  if not ok then return end
  savedguis[object] = enabled
  guiwatches[object] = object:GetPropertyChangedSignal("Enabled"):Connect(function()
    if config.showmenu and object.Parent and object.Enabled then
      pcall(function() object.Enabled = false end)
    end
  end)
  pcall(function() object.Enabled = false end)
end

function rf.hideotherguis()
  for _, root in ipairs(roots) do
    for _, object in ipairs(root:GetDescendants()) do rf.hideothergui(object) end
  end
  for _, kind in ipairs(Enum.CoreGuiType:GetEnumItems()) do
    if kind ~= Enum.CoreGuiType.All then
      local ok, enabled = pcall(startergui.GetCoreGuiEnabled, startergui, kind)
      if ok then
        savedcore[kind] = enabled
        pcall(startergui.SetCoreGuiEnabled, startergui, kind, false)
      end
    end
  end
end

function rf.restoreotherguis()
  for object, watcher in pairs(guiwatches) do
    watcher:Disconnect()
    guiwatches[object] = nil
  end
  for object, enabled in pairs(savedguis) do
    if object.Parent then pcall(function() object.Enabled = enabled end) end
    savedguis[object] = nil
  end
  for kind, enabled in pairs(savedcore) do
    pcall(startergui.SetCoreGuiEnabled, startergui, kind, enabled)
    savedcore[kind] = nil
  end
end

function rf.unlockmouse()
  if not config.showmenu then return end
  if not userinputservice:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
    userinputservice.MouseBehavior = Enum.MouseBehavior.Default
    userinputservice.MouseIconEnabled = true
  end
end

function rf.openmouse()
  local scripts = localplayer:FindFirstChild("PlayerScripts")
  local lock = scripts and scripts:FindFirstChild("MouseLock")
  savedmouse = {
    behavior = userinputservice.MouseBehavior,
    icon = userinputservice.MouseIconEnabled,
    lock = lock,
    enabled = lock and lock:GetAttribute("Enabled") or nil
  }
  if lock then
    savedmouse.lockwatch = lock:GetAttributeChangedSignal("Enabled"):Connect(function()
      if config.showmenu and lock:GetAttribute("Enabled") == true then
        pcall(lock.SetAttribute, lock, "Enabled", false)
      end
    end)
    if savedmouse.enabled == true then
      pcall(lock.SetAttribute, lock, "Enabled", false)
    end
  end
  runservice:BindToRenderStep(mousebind, Enum.RenderPriority.Camera.Value + 5, rf.unlockmouse)
  rf.unlockmouse()
end

function rf.restoremouse()
  runservice:UnbindFromRenderStep(mousebind)
  if savedmouse then
    if savedmouse.lockwatch then savedmouse.lockwatch:Disconnect() end
    if savedmouse.lock and savedmouse.lock.Parent then
      pcall(savedmouse.lock.SetAttribute, savedmouse.lock, "Enabled", false)
    end
    savedmouse = nil
  end
  pcall(function()
    userinputservice.MouseBehavior = Enum.MouseBehavior.Default
    userinputservice.MouseIconEnabled = true
  end)
end

function rf.showmenu(enabled)
  enabled = enabled == true
  if enabled and state.hopping then return end
  if not enabled and state.fxpreview and rf.closefxpreview then rf.closefxpreview() end
  if not enabled then
    state.bindinggui = false
    state.bindingaction = nil
    if searchinput then
      searchinput:ReleaseFocus()
      searchinput.Text = ""
    end
    if selectpage then selectpage("main") end
  end
  if enabled ~= state.menuopen then
    if enabled then
      config.showmenu = true
      rf.hideotherguis()
      rf.openmouse()
    else
      config.showmenu = false
      rf.restoremouse()
      rf.restoreotherguis()
    end
  end
  config.showmenu = enabled
  state.menuopen = enabled
  backdrop.Visible = enabled
  rf.fitmenu()
  if rf.resources.blurtween then rf.resources.blurtween:Cancel() end
  if config.disablepostfx then
    blur.Size = 0
    blur.Enabled = false
  else
    blur.Enabled = true
    rf.resources.blurtween = tweenservice:Create(blur, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Size = enabled and 16 or 0})
    rf.resources.blurtween:Play()
  end
  if not enabled then
    rf.delay(0.18, function()
      if state.alive and not config.showmenu and blur.Parent then blur.Enabled = false end
    end)
  end
end

rf.resources.previewoverlay = rf.create("Frame", {
  Name = "CinematicPreview", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
  BorderSizePixel = 0, Visible = false, ZIndex = 100
}, gui)
rf.resources.previewtop = rf.create("Frame", {
  Position = UDim2.new(0.5, -230, 0, 24), Size = UDim2.fromOffset(460, 80),
  BackgroundColor3 = uitheme.surface, BackgroundTransparency = 0.06,
  BorderSizePixel = 0, ZIndex = 101
}, rf.resources.previewoverlay)
rf.create("UICorner", {CornerRadius = UDim.new(0, 8)}, rf.resources.previewtop)
rf.create("UIStroke", {Thickness = 1, Color = uitheme.strokehover}, rf.resources.previewtop)
rf.resources.previewtitle = rf.create("TextLabel", {
  Position = UDim2.fromOffset(18, 10), Size = UDim2.new(1, -36, 0, 30),
  BackgroundTransparency = 1, Text = "VANTA / GUN EFFECT PREVIEW",
  Font = Enum.Font.Arcade, TextSize = 18, TextColor3 = uitheme.text,
  TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 102
}, rf.resources.previewtop)
rf.resources.previewstyle = rf.create("TextLabel", {
  Position = UDim2.fromOffset(18, 42), Size = UDim2.new(1, -36, 0, 26),
  BackgroundTransparency = 1, Text = "LIGHTNING",
  Font = Enum.Font.Code, TextSize = 17, TextColor3 = uitheme.accent,
  TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 102
}, rf.resources.previewtop)
rf.resources.previewbar = rf.create("Frame", {
  AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -29),
  Size = UDim2.fromOffset(490, 67), BackgroundColor3 = uitheme.surface,
  BackgroundTransparency = 0.04, BorderSizePixel = 0, ZIndex = 101
}, rf.resources.previewoverlay)
rf.create("UICorner", {CornerRadius = UDim.new(0, 8)}, rf.resources.previewbar)
rf.create("UIStroke", {Thickness = 1, Color = uitheme.strokehover}, rf.resources.previewbar)
local function previewbutton(title, x, width, action, primary)
  local button = rf.create("TextButton", {
    Position = UDim2.fromOffset(x, 10), Size = UDim2.fromOffset(width, 47),
    BackgroundColor3 = uibuttoncolor(primary, false),
    BorderSizePixel = 0, AutoButtonColor = false,
    Font = Enum.Font.Arcade, TextSize = 14,
    TextColor3 = uitheme.text, Text = title, ZIndex = 102
  }, rf.resources.previewbar)
  rf.create("UICorner", {CornerRadius = UDim.new(0, 5)}, button)
  local stroke = rf.create("UIStroke", {Thickness = 1, Color = uibuttonstroke(primary, false)}, button)
  button.MouseEnter:Connect(function()
    button.BackgroundColor3 = uibuttoncolor(primary, true)
    stroke.Color = uibuttonstroke(primary, true)
  end)
  button.MouseLeave:Connect(function()
    button.BackgroundColor3 = uibuttoncolor(primary, false)
    stroke.Color = uibuttonstroke(primary, false)
  end)
  button.Activated:Connect(action)
  return button
end

function rf.closefxpreview()
  local session = state.fxpreview
  if not session then return end
  state.fxpreview = nil
  runservice:UnbindFromRenderStep("VantaCinematicPreview_" .. tostring(localplayer.UserId))
  rf.resources.previewoverlay.Visible = false
  backdrop.Visible = state.menuopen
  rf.resources.noticeholder.Visible = session.noticesvisible
  overlay.Enabled = session.overlayenabled
  if session.stage and session.stage.Parent then session.stage:Destroy() end
  for _, group in ipairs(session.beams) do
    if group and group.Parent then group:Destroy() end
  end
  local camera = session.camera
  if camera and camera.Parent and camera == world.CurrentCamera then
    pcall(function()
      camera.CameraType = Enum.CameraType.Scriptable
      camera.CFrame = session.frame
      camera.Focus = session.focus
      camera.FieldOfView = session.fov
      local subject = session.subject
      if subject and subject.Parent then
        camera.CameraSubject = subject
      else
        local character = localplayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then camera.CameraSubject = humanoid end
      end
      camera.CameraType = session.type
    end)
  end
  if config.showmenu then
    blur.Enabled = true
    blur.Size = 16
  else
    blur.Size = session.blursize
    blur.Enabled = session.blurenabled
  end
end

function rf.playfxpreview()
  local session = state.fxpreview
  if not session or not state.alive then return end
  for _, group in ipairs(session.beams) do
    if group and group.Parent then group:Destroy() end
  end
  table.clear(session.beams)
  rf.resources.previewstyle.Text = string.upper(config.gunbeamstyle) .. "  /  " .. string.upper(config.gunbeamwidth)
  local group = rf.createbeam(nil, session.origin, session.finish, nil,
    {preview = true, style = config.gunbeamstyle})
  if group then table.insert(session.beams, group) end
end

function rf.openfxpreview()
  if not state.alive or state.fxpreview then return end
  if not config.showmenu then rf.showmenu(true) end
  local camera = world.CurrentCamera
  if not camera then return end
  local character = localplayer.Character
  local root = character and character:FindFirstChild("HumanoidRootPart")
  local base = root and root.Position or camera.CFrame.Position
  local axis = root and root.CFrame.LookVector or camera.CFrame.LookVector
  local forward = Vector3.new(axis.X, 0, axis.Z)
  if forward.Magnitude < 0.001 then forward = Vector3.new(0, 0, -1) end
  forward = forward.Unit
  local right = forward:Cross(Vector3.new(0, 1, 0)).Unit
  local origin = base + Vector3.new(0, 230, 0)
  local finish = origin + forward * 21
  local midpoint = origin:Lerp(finish, 0.5)
  local stage = rf.create("Folder", {Name = "VantaVFXPreviewStage"}, rf.resources.fxroot)
  local cameraoffset = right * 21 + Vector3.new(0, 8, 0) - forward * 2
  local session = {
    camera = camera, frame = camera.CFrame, focus = camera.Focus,
    subject = camera.CameraSubject, type = camera.CameraType, fov = camera.FieldOfView,
    stage = stage, beams = {}, origin = origin, finish = finish, midpoint = midpoint,
    cameraoffset = cameraoffset, started = os.clock(),
    blurenabled = blur.Enabled, blursize = blur.Size, noticesvisible = rf.resources.noticeholder.Visible,
    overlayenabled = overlay.Enabled
  }
  state.fxpreview = session
  local backplate = rf.create("Part", {
    Name = "PreviewBackdrop", Anchored = true, CanCollide = false,
    CanTouch = false, CanQuery = false, CastShadow = false,
    Color = uitheme.shadow, Material = Enum.Material.SmoothPlastic,
    Size = Vector3.new(31, 14, 0.4),
    CFrame = CFrame.lookAt(midpoint - right * 4.5, midpoint + right * 20)
  }, stage)
  local source = rf.create("Part", {
    Name = "Emitter", Anchored = true, CanCollide = false, CanTouch = false,
    CanQuery = false, CastShadow = false, Material = Enum.Material.Metal,
    Color = Color3.fromRGB(79, 72, 94), Size = Vector3.new(0.55, 0.55, 1.7),
    CFrame = CFrame.lookAt(origin - forward * 0.9, finish)
  }, stage)
  local target = rf.create("Part", {
    Name = "Target", Anchored = true, CanCollide = false,
    CanTouch = false, CanQuery = false, CastShadow = false,
    Color = Color3.fromRGB(147, 123, 200), Material = Enum.Material.Neon,
    Shape = Enum.PartType.Ball, Size = Vector3.new(0.6, 0.6, 0.6),
    Position = finish
  }, stage)
  rf.resources.previewoverlay.Visible = true
  backdrop.Visible = false
  rf.resources.noticeholder.Visible = false
  overlay.Enabled = false
  blur.Enabled = false
  camera.CameraType = Enum.CameraType.Scriptable
  camera.FieldOfView = 54
  runservice:BindToRenderStep("VantaCinematicPreview_" .. tostring(localplayer.UserId),
    Enum.RenderPriority.Camera.Value + 2, function()
      if state.fxpreview ~= session or world.CurrentCamera ~= camera then return end
      local t = os.clock() - session.started
      local position = midpoint + cameraoffset + Vector3.new(0, math.sin(t * 0.45) * 0.3, 0)
      camera.CameraType = Enum.CameraType.Scriptable
      camera.FieldOfView = 54
      camera.CFrame = CFrame.lookAt(position, midpoint)
      camera.Focus = CFrame.new(midpoint)
    end)
  rf.playfxpreview()
  rf.spawn(function()
    while state.alive and state.fxpreview == session do
      task.wait(1.2)
      if state.fxpreview == session then rf.playfxpreview() end
    end
  end)
end

previewbutton("Replay Effect", 10, 148, function() rf.playfxpreview() end)
previewbutton("Next Style", 167, 135, function()
  local index = table.find(gunbeamstyles, config.gunbeamstyle) or 1
  config.gunbeamstyle = gunbeamstyles[index % #gunbeamstyles + 1]
  savepreferences()
  rf.updatehud()
  rf.playfxpreview()
end)
previewbutton("Close Preview", 310, 169, function() rf.closefxpreview() end, true)

function rf.buttonvisible(button, value)
  if not button then return end
  button.outer.Visible = value
  button.shadow.Visible = value
end

selectpage = function(name)
  currentpage = pages[name] and name or "main"
  if currentpage ~= "settings" then
    state.resetconfirmuntil = nil
    if rf.resources.resetconfirmbutton then rf.resources.resetconfirmbutton.setlabel("Reset Configuration") end
  end
  local searching = searchinput and searchinput.Text:match("%S") ~= nil
  local rows = definitions and definitions[currentpage] and math.ceil(#definitions[currentpage] / 2) or 0
  local finalcontent = 152 + 12 + math.max(0, rows - 1) * 58 + (rows > 0 and 52 or 0)
  if currentpage == "autofarm" then
    local statustop = 12 + math.max(0, rows - 1) * 58 + (rows > 0 and 52 or 0) + 18
    finalcontent = math.max(finalcontent, 152 + statustop + 86)
  end
  local footerposition = (currentpage == "players" or currentpage == "voting") and 662 or math.max(302, finalcontent + 27)
  local targetheight = searching and 733 or currentpage == "main" and 582
    or (currentpage == "players" or currentpage == "voting") and 733 or footerposition + 63
  if targetheight ~= rf.resources.menuheighttarget then
    rf.resources.menuheighttarget = targetheight
    if rf.resources.menuresizetween then rf.resources.menuresizetween:Cancel() end
    rf.resources.menuresizetween = tweenservice:Create(menu, TweenInfo.new(0.17, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
      Size = UDim2.fromOffset(602, targetheight)
    })
    rf.resources.menuresizetween:Play()
    rf.fitmenu()
  end
  if rf.ismobilelayout() then rf.resources.mobilescroll.CanvasPosition = Vector2.new(0, 0) end
  if returnhome then
    returnhome.outer.Position = UDim2.fromOffset(9, footerposition)
    returnhome.shadow.Position = UDim2.fromOffset(9, footerposition + 5)
  end
  for page, frame in pairs(pages) do frame.Visible = page == currentpage and not searching end
  if searchview then searchview.Visible = searching end
  local home = currentpage == "main"
  rf.buttonvisible(reconnect, home and not searching)
  rf.buttonvisible(rf.serverhopbutton, home and not searching)
  rf.buttonvisible(leave, home and not searching)
  rf.buttonvisible(returnhome, not home and not searching)
  if rf.homefps then rf.homefps.Visible = home and not searching end
  local title = pagetitles[currentpage] or currentpage:upper()
  pagetitle.Text = searching and "VANTA / SEARCH" or home and "VANTA" or "VANTA / " .. title
  if not home then
    local parentpage = pageparents[currentpage] or "main"
    returnhome.setlabel(parentpage == "main" and "Return to Home" or "Back to " .. (pagetitles[parentpage] or parentpage))
  end
  if currentpage == "players" and rf.refreshplayerlist then rf.refreshplayerlist() end
  if currentpage == "voting" and rf.updatevoteui then rf.updatevoteui() end
end

for _, root in ipairs(roots) do
  table.insert(state.connections, root.DescendantAdded:Connect(function(object)
    if config.showmenu then rf.hideothergui(object) end
  end))
end

function rf.resetsettings()
  if not state.alive then return false end
  if config.autovote then rf.votehalt("Settings reset", false) end
  if state.autofling then
    state.autofling.murderer, state.autofling.sheriff = false, false
    if rf.flingstop then rf.flingstop("off", true) end
    if rf.flingsyncbuttons then rf.flingsyncbuttons() end
  end
  if state.manualshotbusy and state.manualshotcancel then pcall(state.manualshotcancel) end
  if flags.autofarm then rf.toggleflag("autofarm") end
  if flags.autopickup then rf.toggleflag("autopickup") end
  if flags.autokillall then rf.toggleflag("autokillall") end
  if flags.knifeall then rf.toggleflag("knifeall") end
  rf.setautoshoot(false)
  if rf.autoshootstophover and state.autoshoothover then rf.autoshootstophover(true) end
  rf.motionrelease("pickup", true)
  rf.motionrelease("autovote", true)
  rf.motionrelease("manualshot", true)
  if rf.closefxpreview and state.fxpreview then rf.closefxpreview() end
  rf.votefadestop(false)
  for key, original in pairs(defaults) do
    config[key] = original
  end
  config.autoshoot = false
  config.autovote = false
  config.showmenu = true
  config.manualnoclip = false
  config.persistnoclip = false
  config.guikeybind = "RightControl"
  config.walkspeedpreset = "Default"
  config.autofarmtweenspeed = 20
  config.autovotemaps = {}
  config.keybinds = {}
  for name, key in pairs(keybinddefaults) do config.keybinds[name] = key end
  flags.aim, flags.chams, flags.fx, flags.skeleton = true, true, true, true
  flags.nocollision, flags.coinchams = true, true
  flags.autofarm, flags.autopickup = false, false
  flags.autokillall, flags.knifeall = false, false
  state.bindinggui = false
  state.bindingaction = nil
  state.pendingmanualshot = nil
  state.fullbagshot = nil
  state.autoshootpoint, state.autoshootpointuntil = nil, 0
  state.autoshoottrack = nil
  state.mouseactiveuntil = 0
  voting.finished = false
  voting.pad, voting.name = nil, nil
  rf.setglobalnoclip(false)
  rf.farmreleasenoclip()
  rf.updatecollisions()
  if rf.refreshhotkeys then rf.refreshhotkeys() end
  if rf.applyfpscap then rf.applyfpscap(true) end
  if rf.applyfov then rf.applyfov() end
  if rf.refreshworldgraphics then rf.refreshworldgraphics() end
  if rf.refreshperformancegraphics then rf.refreshperformancegraphics() end
  if rf.applylightingvisuals then rf.applylightingvisuals() end
  if rf.refreshvisuals then rf.refreshvisuals() end
  if rf.updatevoteui then rf.updatevoteui() end
  if type(writefile) == "function" then pcall(writefile, guikeyfile, config.guikeybind) end
  savepreferences()
  rf.updatehud()
  return true
end

function rf.updatehud()
  if not state.alive then return end
  if state.menuopen ~= config.showmenu then rf.showmenu(config.showmenu) end
  if currentpage == "voting" and config.showmenu and rf.updatevoteui then rf.updatevoteui() end
  if rf.homefps and currentpage == "main" then
    rf.homefps.Text = string.format("%d FPS", math.floor(state.performance.fps + 0.5))
  end
  if rf.resources.farmstatuslabel then
    local active = flags.autofarm
    if rf.farmstatuspanel then rf.farmstatuspanel.Visible = true end
    if rf.farmstatusshadow then rf.farmstatusshadow.Visible = true end
    if not active then
      rf.resources.farmstatuslabel.Text = "Auto Collect is disabled\nEnable it above to begin collecting"
      rf.resources.farmstatuslabel.TextColor3 = uitheme.textdim
    else
      rf.resources.farmstatuslabel.TextColor3 = farm.full and Color3.fromRGB(243, 223, 153)
        or uitheme.text
      local message = farm.status
      message = message:gsub("^%l", string.upper)
      if message == "waiting for live character" then message = "Waiting for the round to begin" end
      if message == "searching for coins" then message = "Looking for highlighted coins" end
      if message == "redirecting to highlighted coin" then message = "Switching to another coin" end
      if message == "waiting for coins" then message = "No highlighted coins nearby" end
      if message == "moving to coin" then message = "Moving to highlighted coin" end
      if message == "collecting coin" then message = "Collecting coin" end
      message = message:gsub("^%l", string.upper)
      rf.resources.farmstatuslabel.Text = string.format("%s\n%d highlights cleared  /  %d attempts", message, farm.confirmed, farm.attempted)
    end
  end
  for _, entry in ipairs(controls) do
    local enabled
    if entry.source == "speedcycle" then
      enabled = config.walkspeedpreset ~= "Default"
      entry.button.setlabel("WalkSpeed: " .. config.walkspeedpreset .. " (" .. tostring(walkspeeds[config.walkspeedpreset]) .. ")")
    elseif entry.source == "farmspeedcycle" then
      enabled = true
      entry.button.setlabel("Speed: " .. tostring(config.autofarmtweenspeed) .. " studs/s")
    elseif entry.source == "actionkeybind" then
      local selected = config.keybinds[entry.key] or "Unbound"
      enabled = state.bindingaction == entry.key
      entry.button.setlabel(entry.title .. ": " .. (enabled and "Press a Key..." or (selected == "Unbound" and "Unbound" or rf.bindname(selected))))
    elseif entry.source == "fpscycle" then
      enabled = config.fpscapmode ~= "Unlimited"
      entry.button.setlabel("FPS Cap: " .. config.fpscapmode)
    elseif entry.source == "espmode" then
      enabled = config.espmode == "Drawing"
      entry.button.setlabel("ESP Highlight Type: " .. config.espmode)
    elseif entry.source == "fovcycle" then
      enabled = config.fovmode ~= "Default"
      entry.button.setlabel("Camera FOV: " .. config.fovmode)
    elseif entry.source == "beamstyle" then
      enabled = flags.fx
      entry.button.setlabel("Gun Beam Style: " .. config.gunbeamstyle)
    elseif entry.source == "beamwidth" then
      enabled = flags.fx
      entry.button.setlabel("Gun Beam Width: " .. config.gunbeamwidth)
    elseif entry.source == "killmode" then
      enabled = flags.autokillall
      entry.button.setlabel("Kill Method: " .. config.autokillmode)
    elseif entry.source == "farmdestination" then
      enabled = config[entry.key] ~= "Stay"
      entry.button.setlabel(entry.title .. ": " .. tostring(config[entry.key]))
    elseif entry.source == "keybind" then
      enabled = state.bindinggui
      entry.button.setlabel(state.bindinggui and "GUI Toggle: Press a Key..."
        or "GUI Toggle: " .. rf.bindname(config.guikeybind))
    else
      if entry.source == "flag" then enabled = flags[entry.key] else enabled = config[entry.key] end
      entry.button.setlabel(entry.title .. "  " .. (enabled and "[ON]" or "[OFF]"))
    end
    entry.button.setselected(enabled)
  end
end

function rf.toggleflag(key)
  if not state.alive or flags[key] == nil then return end
  flags[key] = not flags[key]
  if key == "knifeall" and flags.knifeall and flags.autokillall then
    flags.autokillall = false
    if rf.autokillstop then rf.autokillstop("legacy knife sweep selected", true) end
  end
  if key == "autokillall" then
    if not flags.autokillall and rf.autokillstop then rf.autokillstop("off", true) end
    if flags.autokillall and flags.knifeall then flags.knifeall = false end
  end
  if key == "autopickup" and not flags.autopickup then
    state.pickupretryat, state.pickupretrytarget, state.pickupfailures = 0, nil, 0
    if state.pickuprestore then state.pickuprestore(true) end
    rf.motionrelease("pickup", true)
    state.pickupstatus = "pickup disabled"
  end
  if key == "chams" then
    if not flags.chams then rf.clearvisuals() end
    rf.refreshvisuals()
  elseif key == "fx" and not flags.fx then
    rf.resources.fxroot:ClearAllChildren()
  elseif key == "nocollision" then
    rf.updatecollisions()
  elseif key == "coinchams" then
    rf.spawn(rf.refreshcoinchams)
  elseif key == "autofarm" then
    farm.fullshoteligible = false
    farm.lastcollectmotion = 0
    farm.lastcollectround = 0
    farm.lastcollectcharacter = nil
    if not flags.autofarm then
      motionqueue.queuedcollect = false
      rf.motionclearreturn()
      rf.farmshowafterfull(true)
      rf.farmcancelreturn()
      farm.lastcoinposition = nil
      farm.returnedfull = false
      farm.nohighlightssince = nil
      rf.farmstop(true)
      rf.farmreleasenoclip()
      farm.status = "off"
      if not flags.coinchams then rf.clearcoinchams() end
    else
      rf.farmcoinautoclip(true)
      rf.motionclearreturn()
      farm.home = nil
      if rf.localisinround() then rf.farmcapturehome() end
      rf.farmcheckfull(true)
      if farm.full then
        local character = localplayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not farm.lastcoinposition and root then farm.lastcoinposition = root.Position end
      end
      farm.returnedfull = false
      farm.nohighlightssince = nil
      farm.status = farm.full and "coin bag full" or "searching for coins"
      farm.nextscan = 0
      rf.spawn(rf.refreshcoinchams)
      if farm.full and config.farmresetfull then rf.farmresetwhenfull()
      elseif farm.full and config.farmhidefull then rf.farmhidewhenfull() end
    end
  end
  rf.updatehud()
  savepreferences()
end

definitions = {
  main = {
    {"page", "general", "General"}, {"page", "aim", "Combat"},
    {"page", "visuals", "Visuals"}, {"page", "automation", "Automation"},
    {"page", "players", "Players"}, {"page", "settings", "Settings"}
  },
  general = {
    {"page", "movement", "Movement"}, {"page", "safety", "Safety & Recovery"},
    {"page", "gundetection", "Gun Detection"}
  },
  players = {},
  automation = {
    {"page", "autofarm", "Auto Collect"}, {"page", "gunpickup", "Gun Pickup"},
    {"page", "voting", "Map Voting"}
  },
  voting = {
    {"config", "autovote", "Auto Vote"}, {"action", "votescan", "Check Voting Pads"}
  },
  aim = {
    {"flag", "aim", "Aim Assist"}, {"config", "mousecframespoof", "Mouse CFrame"},
    {"config", "mouseunitrayspoof", "Mouse Ray"}, {"config", "aimonfire", "Aim on Fire"},
    {"config", "firefallback", "Fire Fallback"}, {"config", "rolehitboxes", "Murderer Virtual Aim Bounds"},
    {"page", "aimknife", "Knife Aim"}, {"page", "aimshoot", "Auto Shooting"},
    {"page", "autokill", "Auto Kill All"}
  },
  aimknife = {
    {"config", "knifeaim", "Knife Aim"}, {"config", "knifeaimalways", "Auto Knife Targeting"}
  },
  aimshoot = {
    {"config", "autoshoot", "Auto Shoot Murderer"},
    {"config", "autoequipgun", "Equip Gun on Sight"}, {"config", "autoshootactivate", "Tool Activation"},
    {"config", "autounequipgun", "Unequip After Shot"},
    {"action", "autoshootstatus", "Auto Shoot Status"},
    {"config", "autoshootbehind", "Teleport Behind Murderer"},
    {"config", "autoshootfar", "Far Teleport and Hover"},
    {"config", "autoshootcover", "Adaptive Cover Peek"},
    {"config", "autoshootwhenfull", "Shoot When Full"}
  },
  autokill = {
    {"flag", "autokillall", "Auto Kill All"}, {"killmode", "autokillmode", "Kill Method"},
    {"config", "autokillfullbag", "Only When Bag Is Full"}, {"config", "autokillautoequip", "Auto Equip Knife"},
    {"config", "autokillreturn", "Restore Position on Stop"}, {"config", "autokillactivate", "Activate Knife"},
    {"action", "autokillstatus", "Show Kill Status"}, {"flag", "knifeall", "Knife Touch All"}
  },
  visuals = {
    {"page", "visualplayers", "Player ESP"}, {"page", "visualcoins", "Coin ESP"},
    {"page", "visualeffects", "Weapon Effects"}, {"page", "visualperformance", "Performance"},
    {"config", "disablefade", "Disable Fade Visuals"}
  },
  visualplayers = {
    {"flag", "chams", "Role Chams"}, {"espmode", "espmode", "ESP Highlight Type"},
    {"flag", "skeleton", "Skeleton ESP"}, {"config", "showtags", "Player Labels"},
    {"config", "showinnocents", "Innocent ESP"}, {"config", "showinnocentlabels", "Innocent Names"},
    {"config", "throughwalls", "Through Walls"}, {"config", "skeletonoutline", "Skeleton Outline"},
    {"config", "outlineglow", "Outline Glow"}, {"config", "outlineonly", "Outline Only"},
    {"config", "r6tracking", "R6 Tracking Rigs"}
  },
  visualcoins = {
    {"flag", "coinchams", "Coin Chams"}, {"action", "refreshcoins", "Refresh Coin Highlights"}
  },
  visualeffects = {
    {"flag", "fx", "Gunshot FX"}, {"page", "visualgunbeams", "Gun Beam Customisation"}
  },
  visualgunbeams = {
    {"beamstyle", "gunbeamstyle", "Gun Beam Style"}, {"beamwidth", "gunbeamwidth", "Gun Beam Width"},
    {"action", "previewgunfx", "Preview Gun Effects"}, {"config", "gunbeamglow", "Layered Beam Glow"},
    {"config", "gunbeamtracer", "Moving Beam Pulse"}, {"config", "gunbeammuzzle", "Muzzle Flash"},
    {"config", "gunbeamimpact", "Impact Effects"}
  },
  visualperformance = {
    {"config", "adaptiveesp", "Adaptive ESP"}, {"fpscycle", "fpscapmode", "FPS Cap"},
    {"config", "removetextures", "Remove Map Textures"}, {"config", "simplematerials", "Simplify Materials"},
    {"config", "disablemapfx", "Disable Map Effects"},
    {"config", "distanceculling", "Distance Cull Decorations"},
    {"config", "frustumculling", "Offscreen Cull Decorations"},
    {"config", "disablepostfx", "Disable Post Processing"},
    {"config", "lowqualitywater", "Simplify Terrain Water"},
    {"page", "visualworld", "World Lighting"}, {"action", "performancestatus", "Performance Diagnostics"}
  },
  visualworld = {
    {"config", "fullbright", "Fullbright"}, {"config", "clearfog", "Remove Fog"},
    {"config", "noshadows", "Disable Shadows"}, {"fovcycle", "fovmode", "Camera FOV"}
  },
  gunpickup = {
    {"flag", "autopickup", "Auto Collect Gun"}, {"config", "pickupheadcontact", "Head Touch Only"},
    {"config", "pickupraycast", "Raycast Detection"}, {"config", "pickupallowgenericraycast", "Generic Raycasts"},
    {"config", "pickupwithoutlastknown", "Untracked Drops"}
  },
  gundetection = {
    {"config", "gunownershiptracking", "Gun Ownership Tracking"},
    {"config", "gunmarker", "Dropped Gun Marker"},
    {"config", "checkbackpack", "Inventory Checks"},
    {"config", "preservemanual", "Manual Role Memory"}
  },
  autofarm = {
    {"flag", "autofarm", "Auto Collect Coins"}, {"farmspeedcycle", "autofarmtweenspeed", "Collect Speed"},
    {"config", "farmresetfull", "Reset When Full"}, {"config", "autofarmnoclip", "Collect Noclip"},
    {"page", "autofarmreturn", "Return Settings"}, {"action", "resetfarm", "Reset Collector"},
    {"action", "farmstatus", "Collection Status"}
  },
  autofarmreturn = {
    {"config", "farmreturnfinished", "Return When Coins Are Gone"},
    {"farmdestination", "farmfinishdestination", "When Finished"},
    {"config", "farmreturnfull", "Return When Bag Is Full"},
    {"farmdestination", "farmfulldestination", "When Bag Is Full"},
    {"config", "farmhidefull", "Hide When Full"}
  },
  movement = {
    {"speedcycle", "walkspeedpreset", "WalkSpeed"}
  },
  safety = {
    {"config", "antivoid", "Anti Void"}, {"config", "antifling", "Anti Fling"},
    {"config", "flinglogs", "Fling Log Notifications"},
    {"config", "persistnoclip", "Global Noclip"}, {"flag", "nocollision", "No Player Collision"}
  },
  keybinds = {
    {"keybind", "guikeybind", "GUI Toggle"}, {"actionkeybind", "shootmurderer", "Shoot Murderer"},
    {"actionkeybind", "toggleautofarm", "Toggle Auto Collect"},
    {"actionkeybind", "toggleautoshoot", "Toggle Auto Shoot"},
    {"actionkeybind", "togglepickup", "Toggle Gun Pickup"},
    {"actionkeybind", "togglecoinchams", "Toggle Coin Chams"},
    {"actionkeybind", "togglerolechams", "Toggle Role Chams"},
    {"actionkeybind", "toggleantifling", "Toggle Anti Fling"},
    {"actionkeybind", "togglenoclip", "Toggle Noclip"},
    {"actionkeybind", "toggleautokill", "Toggle Auto Kill All"}
  },
  settings = {
    {"page", "keybinds", "Keybinds"}, {"config", "notifications", "Notifications"},
    {"config", "notificationheadshots", "Player Headshots"},
    {"config", "killnotices", "Kill Notifications"},
    {"action", "testnotification", "Test Notification"},
    {"action", "resetsettings", "Reset Configuration"}
  }
}

pageparents = {
  general = "main", aim = "main", visuals = "main", automation = "main",
  players = "main", settings = "main", movement = "general", safety = "general",
  gundetection = "general", aimknife = "aim", aimshoot = "aim", autokill = "aim",
  visualplayers = "visuals", visualcoins = "visuals", visualeffects = "visuals",
  visualperformance = "visuals", visualgunbeams = "visualeffects",
  visualworld = "visualperformance", gunpickup = "automation", autofarm = "automation",
  autofarmreturn = "autofarm", voting = "automation", keybinds = "settings"
}
pagetitles = {
  main = "VANTA", general = "GENERAL", aim = "COMBAT", visuals = "VISUALS",
  automation = "AUTOMATION", players = "PLAYERS", settings = "SETTINGS",
  movement = "MOVEMENT", safety = "SAFETY & RECOVERY",
  gundetection = "GUN DETECTION", aimknife = "KNIFE AIM", aimshoot = "AUTO SHOOTING",
  autokill = "AUTO KILL ALL", visualplayers = "PLAYER ESP", visualcoins = "COIN ESP",
  visualeffects = "WEAPON EFFECTS", visualperformance = "PERFORMANCE",
  visualgunbeams = "GUN BEAM EFFECTS", visualworld = "WORLD LIGHTING",
  gunpickup = "GUN PICKUP", autofarm = "AUTO COLLECT",
  autofarmreturn = "RETURN SETTINGS", voting = "MAP VOTING", keybinds = "KEYBINDS"
}
local back = rf.menubutton(menu, "Back to Game", UDim2.fromOffset(9, 96), UDim2.fromOffset(584, 50), function()
  rf.showmenu(false)
end)
back.face.Modal = false
function rf.queueteleport()
  local queuefn
  if type(queue_on_teleport) == "function" then
    queuefn = queue_on_teleport
  elseif type(queueonteleport) == "function" then
    queuefn = queueonteleport
  elseif type(syn) == "table" and type(syn.queue_on_teleport) == "function" then
    queuefn = syn.queue_on_teleport
  elseif type(fluxus) == "table" and type(fluxus.queue_on_teleport) == "function" then
    queuefn = fluxus.queue_on_teleport
  elseif type(env.queue_on_teleport) == "function" then
    queuefn = env.queue_on_teleport
  elseif type(env.queueonteleport) == "function" then
    queuefn = env.queueonteleport
  end
  if not queuefn then
    return false, "Teleport queuing is not supported by this executor"
  end
  local loader = [[
if not game:IsLoaded() then game.Loaded:Wait() end
local players = game:GetService("Players")
local player = players.LocalPlayer
local playerstart = os.clock()
while not player and os.clock() - playerstart < 15 do
  task.wait(0.1)
  player = players.LocalPlayer
end
if player then
  player:WaitForChild("PlayerGui", 20)
  if not player.Character then
    local started = os.clock()
    while not player.Character and os.clock() - started < 12 do task.wait(0.15) end
  end
end
task.wait(2)
local source
if type(readfile) == "function" then
  for _, filename in ipairs({"vanta_v1_1_8_mobile_fade_gui_fixed.lua", "vanta_v1_1_7_mobile_support.lua", "vanta_audit_reliability_voting_fixed.lua", "vanta_silentaim_votegui_independent.lua", "vanta_autoshoot_bag_underfeet_voting_fixed.lua", "vanta_autoshoot_toggle_autovote_spam_fixed.lua", "vanta_autovote_menu_reset_fixed.lua", "vanta_autovote_respawn_performance_fixed.lua", "vanta_conflict_noclip_shoot_pickup_fixed.lua", "vanta_lobby_autocollect_restore_fixed.lua", "vanta_independent_noclip_lobby_fade.lua", "vanta_lobby_spawn_fade_toggle.lua", "vanta_lobby_spawn_antivoid_fixed.lua", "vanta_independent_autofarm_noclip.lua", "vanta_safety_spawn_noclip_teleport.lua", "vanta_coin_noclip_player_teleport.lua", "vanta_autofarm_fullbag_ui_fixed.lua", "vanta_reset_when_full_noclip.lua", "vanta_antivoid_global_noclip.lua", "vanta_mapicon_keybind_notifications.lua", "vanta_mapicon_sources.lua", "vanta_noclip_keybind.lua", "vanta_movement_autofarm_map_notifications.lua", "vanta_autocollect_gun_keybinds_fixed.lua", "vanta_autovote_fade_fps.lua", "vanta_autovote_fast_reset.lua", "vanta_autovote_camera_lucide.lua", "vanta_auto_vote.lua", "vanta_keybinds_fixed.lua", "vanta_close_range_torso.lua", "vanta_underground_gun_pickup.lua", "vanta_hit_part_selector.lua", "vanta_tab_leaderboard.lua", "vanta_round_social_fixed.lua", "vanta_social_fixed.lua", "vanta_chat_serverhop_fixed.lua", "vanta_latest.lua"}) do
    local ok, content = pcall(readfile, filename)
    if ok and type(content) == "string" and #content > 10000 then
      source = content
      break
    end
  end
end
if not source then
  local url = "https://neruvex.lol/mm2mc.lua?cb=" .. tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999999))
  source = game:HttpGet(url)
end
local chunk, err = loadstring(source)
assert(chunk, err)
chunk()
]]
  local ok, result = pcall(queuefn, loader)
  if not ok then
    return false, tostring(result)
  end
  if result == false then
    return false, "Teleport queue was rejected"
  end
  return true
end
reconnect = rf.menubutton(menu, "Server Reconnect", UDim2.fromOffset(9, 363), UDim2.fromOffset(584, 50), function()
  local queued, reason = rf.queueteleport()
  if not queued then
    rf.notification("Reconnect unavailable", tostring(reason):sub(1, 115), nil,
      "alert-triangle", Color3.fromRGB(255, 144, 115), "reconnect:queueerror")
    return
  end
  rf.showmenu(false)
  rf.spawn(function()
    local ok, result = pcall(teleportservice.TeleportToPlaceInstance, teleportservice, game.PlaceId, game.JobId, localplayer)
    if not ok then
      local fallback, message = pcall(teleportservice.Teleport, teleportservice, game.PlaceId, localplayer)
      if not fallback and state.alive then
        rf.notification("Reconnect unavailable", tostring(message or result):sub(1, 115), nil,
          "alert-triangle", Color3.fromRGB(255, 144, 115), "reconnect:error")
      end
    end
  end)
end)
function rf.serverhop()
  if not state.alive or state.hopping then return end
  rf.showmenu(false)
  rf.restoreotherguis()
  rf.restoremouse()
  backdrop.Visible = false
  blur.Enabled = false
  blur.Size = 0
  config.showmenu = false
  state.menuopen = false
  state.hopping = true
  local session = {
    active = true, current = nil, failed = false, failreason = nil,
    started = false, inprogress = false, attempt = 0, connections = {},
    failedids = {}, departure = false
  }
  state.hopsession = session
  local function release()
    if not session.active then return end
    session.active = false
    for _, connection in ipairs(session.connections) do
      if connection.Connected then connection:Disconnect() end
    end
    if state.hopsession == session then
      state.hopsession = nil
      state.hopping = false
    end
    if state.alive then
      rf.restoreotherguis()
      rf.restoremouse()
      config.showmenu = false
      state.menuopen = false
      backdrop.Visible = false
      blur.Enabled = false
      blur.Size = 0
    end
  end
  table.insert(session.connections, teleportservice.TeleportInitFailed:Connect(function(player, result, message, placeid, options)
    if not session.active or player ~= localplayer or placeid ~= game.PlaceId or not session.current then return end
    local target
    pcall(function() target = options and options.ServerInstanceId end)
    if target and target ~= "" and target ~= session.current then return end
    session.failed = true
    session.failreason = tostring(message or result or "Teleport failed")
    session.flooded = result == Enum.TeleportResult.Flooded
  end))
  table.insert(session.connections, localplayer.OnTeleport:Connect(function(teleportstate, placeid)
    if not session.active or not session.current or placeid ~= game.PlaceId then return end
    if teleportstate == Enum.TeleportState.Failed then
      session.failed = true
      session.failreason = session.failreason or "Roblox could not join the selected server"
    elseif teleportstate == Enum.TeleportState.Started
      or teleportstate == Enum.TeleportState.WaitingForServer then
      session.started = true
    elseif teleportstate == Enum.TeleportState.InProgress then
      session.started = true
      session.inprogress = true
    end
  end))
  rf.notification("Server hop", "Finding available servers", nil,
    "server", Color3.fromRGB(255, 220, 100), "serverhop:search")
  rf.spawn(function()
    local ok, err = pcall(function()
      local requestfn = type(request) == "function" and request
        or type(http_request) == "function" and http_request
        or type(syn) == "table" and type(syn.request) == "function" and syn.request
      local servers = {}
      local seen = {[game.JobId] = true}
      local cursor = nil
      local checked = {}
      for page = 1, 6 do
        if not state.alive or not session.active then return end
        local data
        for _, size in ipairs({100, 50, 25}) do
          local stamp = tostring(cursor) .. ":" .. tostring(size)
          if not checked[stamp] then
            checked[stamp] = true
            local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId)
              .. "/servers/Public?sortOrder=Desc&limit=" .. tostring(size)
              .. "&excludeFullGames=true"
            if cursor and cursor ~= "" then url ..= "&cursor=" .. httpservice:UrlEncode(cursor) end
            local body
            local fetched, response = pcall(game.HttpGet, game, url)
            if fetched and type(response) == "string" then body = response end
            if not body and type(requestfn) == "function" then
              local success, result = pcall(requestfn, {Url = url, Method = "GET"})
              if success and type(result) == "table" and type(result.Body) == "string"
                and (not result.StatusCode or tonumber(result.StatusCode) == 200) then
                body = result.Body
              end
            end
            if body then
              local decoded, value = pcall(httpservice.JSONDecode, httpservice, body)
              if decoded and type(value) == "table" and type(value.data) == "table" then
                data = value
                break
              end
            end
          end
        end
        if not data then break end
        for _, entry in ipairs(data.data) do
          local playing = tonumber(entry.playing)
          local maximum = tonumber(entry.maxPlayers)
          if type(entry.id) == "string" and not seen[entry.id]
            and playing and maximum and playing >= 0 and maximum > playing then
            seen[entry.id] = true
            table.insert(servers, {
              id = entry.id, playing = playing, maximum = maximum,
              ping = tonumber(entry.ping) or math.huge
            })
          end
        end
        local nextcursor = data.nextPageCursor
        if type(nextcursor) ~= "string" or nextcursor == "" or nextcursor == cursor then break end
        cursor = nextcursor
      end
      table.sort(servers, function(a, b)
        if a.playing ~= b.playing then return a.playing > b.playing end
        return a.ping < b.ping
      end)
      if #servers == 0 then error("No other joinable public servers were found") end
      local queued, reason = rf.queueteleport()
      if not queued then
        rf.notification("Server hop", "Auto-load unavailable: " .. tostring(reason):sub(1, 85), nil,
          "alert-triangle", Color3.fromRGB(255, 189, 117), "serverhop:queue")
      end
      local limit = math.min(10, #servers)
      for index = 1, limit do
        if not state.alive or not session.active then return end
        local entry = servers[index]
        session.current = entry.id
        session.attempt = index
        session.failed = false
        session.failreason = nil
        session.flooded = false
        session.started = false
        session.inprogress = false
        session.departure = false
        rf.notification("Server hop " .. tostring(index) .. "/" .. tostring(limit),
          "Joining " .. tostring(entry.playing) .. "/" .. tostring(entry.maximum) .. " players", nil,
          "server", Color3.fromRGB(255, 220, 100), "serverhop:attempt:" .. index)
        local started = os.clock()
        local success, problem = pcall(teleportservice.TeleportToPlaceInstance,
          teleportservice, game.PlaceId, entry.id, localplayer)
        if not success then
          session.failed = true
          session.failreason = tostring(problem)
        end
        while state.alive and session.active and not session.failed do
          local duration = os.clock() - started
          if not session.started and duration >= 13 then
            session.failed = true
            session.failreason = "Teleport initiation timed out"
          elseif session.started and duration >= 45 then
            session.failed = true
            session.failreason = "Server connection timed out"
          else
            task.wait(0.15)
          end
        end
        if not state.alive or not session.active then return end
        if session.failed then
          session.failedids[entry.id] = true
          if index < limit then
            rf.notification("Server hop retry", "Server " .. tostring(index) .. " failed; trying another", nil,
              "refresh-cw", Color3.fromRGB(255, 187, 124), "serverhop:retry:" .. index)
            task.wait(session.flooded and 12 or 1.6)
          end
        end
      end
      error("All " .. tostring(limit) .. " server attempts failed")
    end)
    if state.alive and session.active and not ok then
      rf.notification("Server hop unavailable", tostring(err):sub(1, 120), nil,
        "alert-triangle", Color3.fromRGB(255, 144, 115), "serverhop:error")
    end
    release()
  end)
end
rf.serverhopbutton = rf.menubutton(menu, "Server Hop", UDim2.fromOffset(9, 421), UDim2.fromOffset(584, 50), rf.serverhop)
leave = rf.menubutton(menu, "Leave Game", UDim2.fromOffset(9, 479), UDim2.fromOffset(584, 50), function()
  rf.showmenu(false)
  local ok = pcall(function()
    game:Shutdown()
  end)
  if not ok then
    rf.notification("Exit unavailable", "Use the Roblox menu to leave", nil, "log-out", Color3.fromRGB(255, 232, 53))
  end
end)
returnhome = rf.menubutton(menu, "Return to Home", UDim2.fromOffset(9, 662), UDim2.fromOffset(584, 50), function()
  selectpage(pageparents[currentpage] or "main")
end)
rf.homefps = rf.create("TextLabel", {
  Position = UDim2.fromOffset(9, 542), Size = UDim2.fromOffset(584, 22),
  BackgroundTransparency = 1, Font = Enum.Font.Arcade,
  Text = "60 FPS", TextSize = 14,
  TextColor3 = uitheme.textmuted,
  TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 13
}, menu)
local playerlist, playerlistlayout, playercountlabel, playerempty
rf.resources.playercards = {}
rf.resources.playerorder = {}
rf.resources.playerorderindex = 0
for page, items in pairs(definitions) do
  local frame = rf.create("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
    Visible = page == "main", ZIndex = 12}, pagecontent)
  pages[page] = frame
  for i, entry in ipairs(items) do
    local kind, key, title = entry[1], entry[2], entry[3]
    local column, index = (i - 1) % 2, math.floor((i - 1) / 2)
    local position, size
    if page == "main" then
      column, index = (i - 1) % 2, math.floor((i - 1) / 2)
      position = UDim2.fromOffset(9 + column * 302, 12 + index * 62)
      size = UDim2.fromOffset(282, 56)
    else
      position = UDim2.fromOffset(9 + column * 302, 12 + index * 58)
      size = UDim2.fromOffset(282, 52)
      if page == "autofarm" and i == #items and i % 2 == 1 then
        position = UDim2.fromOffset(9, 12 + index * 58)
        size = UDim2.fromOffset(584, 52)
      end
    end
    local item
    item = rf.menubutton(frame, title, position, size, function()
      if kind == "page" then
        selectpage(key)
      elseif kind == "killmode" then
        local index = table.find(autokillmodes, config.autokillmode) or 0
        config.autokillmode = autokillmodes[index % #autokillmodes + 1]
        if rf.autokillstop then rf.autokillstop("changing mode", true) end
        savepreferences()
        rf.updatehud()
      elseif kind == "farmdestination" then
        local index = table.find(farmdestinations, config[key]) or 0
        config[key] = farmdestinations[index % #farmdestinations + 1]
        savepreferences()
        rf.updatehud()
      elseif kind == "farmspeedcycle" then
        local index = table.find(farmspeeds, config.autofarmtweenspeed) or 2
        config.autofarmtweenspeed = farmspeeds[index % #farmspeeds + 1]
        if farm.session and farm.session.stage == "moving" then
          local session = farm.session
          if session.coin and session.coinpart and rf.farmcoineligible(session.coin, session.coinpart) then
            rf.farmstarttween(session, session.coin, session.coinpart,
              (session.coinpart.Position - session.root.Position).Magnitude)
          end
        end
        savepreferences()
        rf.updatehud()
      elseif kind == "actionkeybind" then
        state.bindingaction = key
        rf.updatehud()
        rf.notification("Action keybind", "Press a key to bind | Esc cancels | Backspace clears", nil,
          "keyboard", Color3.fromRGB(255, 228, 109), "vanta:bind:" .. key)
      elseif kind == "espmode" then
        local nextmode = config.espmode == "Highlight" and "Drawing" or "Highlight"
        if nextmode == "Drawing" and not rf.drawingavailable() then
          rf.notification("ESP renderer", "Drawing.new is unavailable in this executor", nil,
            "alert-triangle", Color3.fromRGB(255, 184, 100), "esp:drawing:unavailable")
        else
          config.espmode = nextmode
          rf.refreshvisuals()
          savepreferences()
        end
        rf.updatehud()
      elseif kind == "fpscycle" then
        rf.cyclefpscap()
      elseif kind == "fovcycle" then
        rf.cyclefov()
      elseif kind == "beamstyle" then
        local index = table.find(gunbeamstyles, config.gunbeamstyle) or 1
        config.gunbeamstyle = gunbeamstyles[index % #gunbeamstyles + 1]
        savepreferences()
        rf.updatehud()
      elseif kind == "beamwidth" then
        local index = table.find(gunbeamwidths, config.gunbeamwidth) or 1
        config.gunbeamwidth = gunbeamwidths[index % #gunbeamwidths + 1]
        savepreferences()
        rf.updatehud()
      elseif kind == "speedcycle" then
        rf.cyclewalkspeed()
        rf.updatehud()
      elseif kind == "keybind" then
        state.bindinggui = true
        rf.updatehud()
        rf.notification("GUI keybind", "Press a key to bind | Esc cancels | Backspace resets", nil,
          "keyboard", Color3.fromRGB(255, 228, 109), "vanta:keybind")
      elseif kind == "flag" then
        rf.toggleflag(key)
      elseif kind == "action" then
        if key == "resetsettings" then
          local now = os.clock()
          if state.resetconfirmuntil and now < state.resetconfirmuntil then
            state.resetconfirmuntil = nil
            item.setlabel("Reset Configuration")
            local success = rf.resetsettings()
            if success then
              rf.notification("Configuration reset", "Settings restored to safe defaults", nil,
                "rotate-ccw", Color3.fromRGB(169, 223, 187), "vanta:settings:reset:" .. tostring(now))
            end
            selectpage("settings")
          else
            state.resetconfirmuntil = now + 5
            item.setlabel("Click again to confirm")
            rf.delay(5, function()
              if state.alive and (state.resetconfirmuntil or 0) <= os.clock() then
                state.resetconfirmuntil = nil
                if item.outer.Parent then item.setlabel("Reset Configuration") end
              end
            end)
          end
          return
        elseif key == "votescan" then
          local pads = select(1, rf.votepads())
          local lines = {}
          for _, entry in ipairs(pads) do
            lines[#lines + 1] = tostring(entry.index) .. ": " ..
              (entry.name ~= "" and entry.name or "Unknown") .. (entry.active and " (open)" or " (closed)")
          end
          rf.notification("Map Voting", table.concat(lines, " | "), nil, "map",
            Color3.fromRGB(177, 225, 249), "vanta:vote:scan:" .. tostring(os.clock()))
          if rf.updatevoteui then rf.updatevoteui() end
        elseif key == "previewgunfx" then
          rf.openfxpreview()
        elseif key == "performancestatus" then
          local metrics = api.functions.diagnostics and api.functions.diagnostics()
          if metrics and metrics.averagefps then
            rf.notification("Performance Diagnostics", string.format("Avg %.1f FPS | P99 %.2f ms | Simulation %.2f ms | %s", metrics.averagefps, 1000 / metrics.lowfps, metrics.simulationms, metrics.tier), nil,
              "activity", uitheme.accent, "performance:status:" .. tostring(os.clock()))
          else
            rf.notification("Performance Diagnostics", "Waiting for frame samples", nil, "activity", uitheme.accent)
          end
        elseif key == "autoshootstatus" then
          local info = rf.autoshootdiagnostics()
          rf.notification("Auto Shoot", string.format("%s | %.2fs | Poll gap %.0fms", info.status, info.statusseconds, info.maxpollgap * 1000), nil,
            "crosshair", Color3.fromRGB(218, 187, 243), "autoshoot:status:" .. tostring(os.clock()))
        elseif key == "autokillstatus" then
          local job = state.autokill
          rf.notification("Auto Kill All", job.status .. " | " .. tostring(job.attempts)
            .. " attacks | priority: " .. tostring(rf.motionowner() or "idle"),
            nil, "swords", Color3.fromRGB(255, 218, 93), "autokill:status:" .. tostring(os.clock()))
        elseif key == "testnotification" then
          rf.notification("Achievement get!", "Notifications enabled", nil, "award",
            Color3.fromRGB(255, 235, 64), "test:" .. tostring(os.clock()))
        elseif key == "refreshcoins" then
          rf.spawn(rf.refreshcoinchams)
        elseif key == "resetfarm" then
          rf.farmstop(false)
          farm.nextscan = 0
          farm.status = flags.autofarm and "route reset" or "off"
        elseif key == "farmstatus" then
          rf.notification("Autofarm", farm.status .. " | " .. tostring(farm.confirmed) .. " coins",
            localplayer.UserId, "coins", Color3.fromRGB(255, 218, 93), "farm:" .. tostring(os.clock()))
        end
        rf.updatehud()
      elseif kind == "config" then
        if key == "persistnoclip" then
          rf.setglobalnoclip(not config.persistnoclip)
        elseif key == "autofarmnoclip" then
          rf.setautofarmnoclip(not config.autofarmnoclip)
        else
          config[key] = not config[key]
        end
        if key == "autovote" then rf.voteenabled() end
        if key == "disablefade" then
          if config.disablefade then rf.votefadeapply(true)
          else rf.votefadestop(false) end
        end
        if key == "farmresetfull" and config.farmresetfull and flags.autofarm then
          rf.farmcheckfull(true)
          if farm.hide then rf.farmshowafterfull(true) end
          if farm.full then rf.farmresetwhenfull() end
        end
        if key == "farmhidefull" then
          if not config.farmhidefull then rf.farmshowafterfull(true)
          elseif flags.autofarm and farm.full and not config.farmresetfull then rf.farmhidewhenfull() end
        end
        if key == "autoshootfar" and not config.autoshootfar and rf.autoshootstophover
          and state.autoshoothover and state.autoshoothover.mode == "far" then
          rf.autoshootstophover(true)
        end
        if key == "autoshootbehind" and not config.autoshootbehind and rf.autoshootstophover
          and state.autoshoothover and state.autoshoothover.mode == "behind" then
          rf.autoshootstophover(true)
        end
        if key == "autoshoot" then rf.setautoshoot(config.autoshoot) end
        if key == "autoshootwhenfull" then
          state.fullbagshot = nil
          if config.autoshootwhenfull and rf.autoshootstophover then
            rf.autoshootstophover(true)
            rf.motionrelease("autoshoot", true)
          end
        end
        if key == "removetextures" or key == "simplematerials" or key == "disablemapfx" then
          rf.refreshworldgraphics()
        elseif key == "distanceculling" or key == "frustumculling"
          or key == "disablepostfx" or key == "lowqualitywater" then
          rf.refreshperformancegraphics()
          if key == "disablepostfx" then rf.showmenu(state.menuopen) end
        elseif key == "fullbright" or key == "clearfog" or key == "noshadows" then
          rf.applylightingvisuals()
        end
        if key == "autokillfullbag" and config.autokillfullbag and not state.autokill.bagfull and rf.autokillstop then
          rf.autokillstop("waiting for full bag", true)
        end
        if key == "r6tracking" then rf.updatetracking() end
        if key == "pickupheadcontact" and not config.pickupheadcontact and state.pickuprestore then state.pickuprestore() end
        if key == "throughwalls" or key == "outlineonly" or key == "showtags" or key == "showinnocents"
          or key == "r6tracking" then
          rf.refreshvisuals()
        end
        rf.updatehud()
        savepreferences()
      end
    end)
    if kind == "action" and key == "resetsettings" then rf.resources.resetconfirmbutton = item end
    searchcatalog[#searchcatalog + 1] = {
      kind = kind, key = key, title = title, page = page, button = item
    }
    if kind == "flag" or kind == "config" or kind == "speedcycle" or kind == "keybind" or kind == "killmode"
      or kind == "farmspeedcycle" or kind == "actionkeybind"
      or kind == "fpscycle" or kind == "fovcycle" or kind == "farmdestination"
      or kind == "beamstyle" or kind == "beamwidth" or kind == "espmode"
      then
      controls[#controls + 1] = {button = item, source = kind, key = key, title = title}
    end
  end
  if page == "players" then
    local heading = rf.create("Frame", {
      Position = UDim2.fromOffset(9, 12), Size = UDim2.fromOffset(584, 38),
      BackgroundColor3 = uitheme.surface, BorderSizePixel = 0, ZIndex = 13
    }, frame)
    rf.create("UIStroke", {Thickness = 1, Color = uitheme.stroke}, heading)
    rf.create("TextLabel", {
      Position = UDim2.fromOffset(14, 1), Size = UDim2.fromOffset(310, 36),
      BackgroundTransparency = 1, Text = "SERVER ROSTER", Font = Enum.Font.Arcade,
      TextSize = 15, TextColor3 = uitheme.text,
      TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14
    }, heading)
    playercountlabel = rf.create("TextLabel", {
      Position = UDim2.new(1, -175, 0, 1), Size = UDim2.fromOffset(160, 36),
      BackgroundTransparency = 1, Text = "0 PLAYERS", Font = Enum.Font.Arcade,
      TextSize = 13, TextColor3 = uitheme.accent,
      TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 14
    }, heading)
    local flingbuttons = {}
    for index, role in ipairs({"murderer", "sheriff"}) do
      local label = role == "murderer" and "Auto Fling Murderer" or "Auto Fling Sheriff"
      local button = rf.menubutton(frame, label .. " [OFF]",
        UDim2.fromOffset(9 + (index - 1) * 302, 62),
        UDim2.fromOffset(282, 52), function()
          if rf.flingtoggle then rf.flingtoggle(role) end
        end)
      flingbuttons[role] = button
    end
    state.flingbuttons = flingbuttons
    playerlist = rf.create("ScrollingFrame", {
      Name = "PlayersRoster", Position = UDim2.fromOffset(9, 123),
      Size = UDim2.fromOffset(584, 370), BackgroundTransparency = 1, BorderSizePixel = 0,
      ScrollBarThickness = 0, ScrollBarImageColor3 = uitheme.scroll,
      ScrollingDirection = Enum.ScrollingDirection.Y, CanvasSize = UDim2.fromOffset(0, 0),
      Active = true, ZIndex = 14
    }, frame)
    playerlistlayout = rf.create("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Vertical,
      Padding = UDim.new(0, 9)
    }, playerlist)
    playerempty = rf.create("TextLabel", {
      Position = UDim2.fromOffset(26, 240), Size = UDim2.new(1, -52, 0, 44),
      BackgroundTransparency = 1, Text = "Waiting for players...", Font = Enum.Font.Arcade,
      TextSize = 15, TextColor3 = uitheme.textdim,
      TextXAlignment = Enum.TextXAlignment.Center, Visible = false, ZIndex = 15
    }, frame)
  end
  if page == "autofarm" then
    local rows = math.ceil(#items / 2)
    local statustop = 12 + math.max(0, rows - 1) * 58 + (rows > 0 and 52 or 0) + 18
    rf.farmstatusshadow = rf.create("Frame", {
      Position = UDim2.fromOffset(9, statustop + 5), Size = UDim2.fromOffset(584, 73),
      BackgroundColor3 = uitheme.shadow, BorderSizePixel = 0, ZIndex = 11
    }, frame)
    local panel = rf.create("Frame", {
      Position = UDim2.fromOffset(9, statustop), Size = UDim2.fromOffset(584, 73),
      BackgroundColor3 = uitheme.border, BorderSizePixel = 0, ZIndex = 12
    }, frame)
    local face = rf.create("Frame", {
      Position = UDim2.fromOffset(4, 4), Size = UDim2.new(1, -8, 1, -8),
      BackgroundColor3 = uitheme.surface, BorderSizePixel = 0, ZIndex = 13
    }, panel)
    rf.create("UIStroke", {Thickness = 1, Color = uitheme.stroke}, face)
    rf.resources.farmstatuslabel = rf.create("TextLabel", {
      Position = UDim2.fromOffset(17, 10), Size = UDim2.new(1, -34, 1, -20),
      BackgroundTransparency = 1, Text = "", Font = Enum.Font.Arcade,
      TextSize = 15, TextColor3 = uitheme.text,
      TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
      TextWrapped = true, ZIndex = 14
    }, face)
    rf.farmstatuspanel = panel
    panel.Visible = true
    rf.farmstatusshadow.Visible = true
  end
end

rf.resources.votebuttons = {}
rf.resources.votestatuslabel = nil
rf.resources.voteselectionlabel = nil
rf.resources.votepreviewlabel = nil
rf.resources.votepage = pages.voting
if rf.resources.votepage then
  local heading = rf.create("TextLabel", {
    Name = "VotingHeading", Position = UDim2.fromOffset(11, 78),
    Size = UDim2.fromOffset(580, 24), BackgroundTransparency = 1,
    Text = "PREFERRED MAPS  /  SELECT MULTIPLE", Font = Enum.Font.Arcade,
    TextSize = 13, TextColor3 = uitheme.textmuted,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14
  }, rf.resources.votepage)
  for index, name in ipairs(votemapnames) do
    local column = (index - 1) % 2
    local row = math.floor((index - 1) / 2)
    local x = 9 + column * 302
    local y = 111 + row * 49
    local shadow = rf.create("Frame", {
      Position = UDim2.fromOffset(x, y + 4), Size = UDim2.fromOffset(282, 42),
      BorderSizePixel = 0, BackgroundColor3 = uitheme.shadow, ZIndex = 11
    }, rf.resources.votepage)
    local face = rf.create("TextButton", {
      Name = "Vote" .. votekey(name), Position = UDim2.fromOffset(x, y),
      Size = UDim2.fromOffset(282, 42), BackgroundColor3 = uitheme.surface,
      AutoButtonColor = false, BorderSizePixel = 0, Text = "", ZIndex = 13
    }, rf.resources.votepage)
    local stroke = rf.create("UIStroke", {
      Color = uitheme.stroke, Thickness = 1
    }, face)
    local label = rf.create("TextLabel", {
      Position = UDim2.fromOffset(14, 0), Size = UDim2.fromOffset(211, 42),
      BackgroundTransparency = 1, Text = name, Font = Enum.Font.Arcade,
      TextSize = 14, TextColor3 = uitheme.textmuted,
      TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14
    }, face)
    local officon = rf.iconimage(face, "square", uitheme.textdim,
      UDim2.new(1, -38, 0.5, -10), UDim2.fromOffset(20, 20), 14)
    local onicon = rf.iconimage(face, "square-check", uitheme.accent,
      UDim2.new(1, -38, 0.5, -10), UDim2.fromOffset(20, 20), 15)
    onicon.Visible = false
    local item = {face = face, stroke = stroke, label = label, onicon = onicon,
      officon = officon, hovered = false}
    rf.resources.votebuttons[name] = item
    local function paint()
      local selected = table.find(config.autovotemaps, name) ~= nil
      face.BackgroundColor3 = uibuttoncolor(selected, item.hovered)
      stroke.Color = uibuttonstroke(selected, item.hovered)
    end
    face.Activated:Connect(function() rf.voteselect(name) end)
    face.MouseEnter:Connect(function() item.hovered = true paint() end)
    face.MouseLeave:Connect(function() item.hovered = false paint() end)
  end
  local statuspanel = rf.create("Frame", {
    Position = UDim2.fromOffset(9, 415), Size = UDim2.fromOffset(584, 91),
    BackgroundColor3 = uitheme.surface, BorderSizePixel = 0, ZIndex = 13
  }, rf.resources.votepage)
  rf.create("UIStroke", {Color = uitheme.stroke, Thickness = 1}, statuspanel)
  rf.resources.voteselectionlabel = rf.create("TextLabel", {
    Position = UDim2.fromOffset(13, 8), Size = UDim2.fromOffset(558, 20),
    BackgroundTransparency = 1, Text = "0 MAPS SELECTED", Font = Enum.Font.Arcade,
    TextSize = 13, TextColor3 = uitheme.accent,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14
  }, statuspanel)
  rf.resources.votestatuslabel = rf.create("TextLabel", {
    Position = UDim2.fromOffset(13, 31), Size = UDim2.fromOffset(558, 25),
    BackgroundTransparency = 1, Text = "Waiting for map voting", Font = Enum.Font.Arcade,
    TextSize = 13, TextColor3 = uitheme.text,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14
  }, statuspanel)
  rf.resources.votepreviewlabel = rf.create("TextLabel", {
    Position = UDim2.fromOffset(13, 61), Size = UDim2.fromOffset(558, 19),
    BackgroundTransparency = 1, Text = "AVAILABLE NOW: --", Font = Enum.Font.Arcade,
    TextSize = 12, TextColor3 = uitheme.textdim,
    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 14
  }, statuspanel)
end

function rf.updatevoteui()
  if not rf.resources.votepage then return end
  for name, item in pairs(rf.resources.votebuttons) do
    local selected = table.find(config.autovotemaps, name) ~= nil
    item.face.BackgroundColor3 = uibuttoncolor(selected, item.hovered)
    item.stroke.Color = uibuttonstroke(selected, item.hovered)
    item.label.TextColor3 = selected and uitheme.text or uitheme.textmuted
    item.onicon.Visible = selected
    item.officon.Visible = not selected
  end
  rf.resources.voteselectionlabel.Text = tostring(#config.autovotemaps) .. " / " .. tostring(#votemapnames) .. " MAPS SELECTED"
  rf.resources.votestatuslabel.Text = voting.status
  local pads, active = rf.votepads()
  local names = {}
  for _, entry in ipairs(pads) do
    if entry.active and entry.name ~= "" then names[#names + 1] = entry.name end
  end
  rf.resources.votepreviewlabel.Text = active and "AVAILABLE NOW: " .. table.concat(names, "  /  ") or "AVAILABLE NOW: WAITING FOR VOTING"
end

rf.resources.playerrolepriority = {Murderer = 1, Sheriff = 2, Hero = 3, GunCarrier = 4, Innocent = 5, Neutral = 6, Lobby = 7, Unknown = 8}
function rf.playerlistrole(p)
  local record = state.authoritative[p.UserId] or rf.getrecord(p)
  if not state.round or state.endlock then return "Lobby", "WAITING FOR ROUND", false, record end
  local role = record and rf.normalize_role(record.Role) or nil
  if not role then role = rf.equippedrole(p) or rf.replicatedrole(p) end
  if not role then return "Unknown", "ROLE NOT DETECTED", false, record end
  local estimated = not state.authoritative[p.UserId]
    and (not record or record.source == "assumed" or record.source == "remembered")
  local humanoid = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
  local dead = record and (record.Dead == true or record.Killed == true)
    or humanoid and humanoid.Health <= 0
  local status = dead and "ELIMINATED" or role == "Neutral" and "SPECTATING"
    or estimated and "ESTIMATED ROLE" or "IN ROUND"
  return role, status, dead == true, record
end

rf.resources.expandedplayerid = nil
rf.resources.textchatservice = game:GetService("TextChatService")
rf.resources.blockedcache = {}
rf.resources.blockedready = false
rf.resources.blockedrefreshat = 0
rf.resources.blockedrefreshbusy = false

function rf.tryfriendconfirm(player)
  rf.spawn(function()
    local deadline = os.clock() + 2.5
    local sent = false
    while state.alive and player.Parent and os.clock() < deadline and not sent do
      task.wait(0.09)
      local root = coregui:FindFirstChild("RobloxGui")
      if not root then continue end
      for _, node in ipairs(root:GetDescendants()) do
        if not (node:IsA("TextLabel") or node:IsA("TextButton")) then continue end
        local phrase = tostring(node.Text or ""):lower()
        if not (phrase:find("friend request", 1, true)
          or phrase:find("connection request", 1, true)
          or phrase:find("are you sure", 1, true)) then continue end
        local group = node.Parent
        for _ = 1, 5 do
          if not group or group == root then break end
          local hasplayer = false
          local hasfriend = false
          local confirm
          for _, item in ipairs(group:GetDescendants()) do
            if item:IsA("TextLabel") or item:IsA("TextButton") then
              local value = tostring(item.Text or ""):lower()
              if value:find(player.Name:lower(), 1, true)
                or value:find(player.DisplayName:lower(), 1, true) then hasplayer = true end
              if value:find("friend", 1, true) or value:find("connection", 1, true) then hasfriend = true end
            end
            if item:IsA("GuiButton") and item.Visible and item.AbsoluteSize.X > 20 and item.AbsoluteSize.Y > 15 then
              local value = item:IsA("TextButton") and tostring(item.Text or ""):lower() or ""
              for _, label in ipairs(item:GetDescendants()) do
                if label:IsA("TextLabel") then value ..= " " .. tostring(label.Text or ""):lower() end
              end
              value = value:match("^%s*(.-)%s*$")
              if value == "confirm" or value == "yes" or value == "send request"
                or value == "send friend request" or value == "add friend"
                or value == "send connection request" then
                confirm = item
              end
            end
          end
          if hasplayer and hasfriend and confirm then
            local center = confirm.AbsolutePosition + confirm.AbsoluteSize / 2
            local ok = pcall(function()
              local virtualinputmanager = game:GetService("VirtualInputManager")
              virtualinputmanager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
              virtualinputmanager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
            end)
            if ok then sent = true end
            break
          end
          group = group.Parent
        end
        if sent then break end
      end
    end
  end)
end

function rf.getblockedstatus(player)
  local ok, result = pcall(startergui.GetCore, startergui, "GetBlockedUserIds")
  if not ok or type(result) ~= "table" then return rf.resources.blockedready and rf.resources.blockedcache[player.UserId] == true or nil end
  for key, value in pairs(result) do
    if tonumber(value) == player.UserId or value == true and tonumber(key) == player.UserId then return true end
  end
  return false
end

function rf.updateplayerblockaction(card)
  if not card or not card.blockbutton or not card.blockbutton.Parent then return end
  local blocked = rf.resources.blockedcache[card.player.UserId] == true
  if card.blockstate == blocked then return end
  card.blockstate = blocked
  card.blocklabel.Text = blocked and "Unblock" or "Block"
  card.blockbutton:SetAttribute("blockstate", blocked and "blocked" or "unblocked")
  local tint = blocked and Color3.fromRGB(125, 212, 178) or Color3.fromRGB(220, 145, 158)
  card.blocklabel.TextColor3 = tint
  local name = blocked and "shield-check" or "ban"
  local asset = rf.lucideasset(name)
  local icon = card.blockicon
  for _, child in ipairs(icon:GetChildren()) do child:Destroy() end
  icon.Image = asset and asset.Url or ""
  icon.ImageRectOffset = asset and asset.ImageRectOffset or Vector2.zero
  icon.ImageRectSize = asset and asset.ImageRectSize or Vector2.zero
  icon.ImageColor3 = tint
  if not asset then rf.iconfallback(icon, name, tint, 24) end
end

function rf.refreshblockedplayers(force)
  if rf.resources.blockedrefreshbusy or not state.alive then return end
  local now = os.clock()
  if not force and now < rf.resources.blockedrefreshat then return end
  rf.resources.blockedrefreshat = now + 1.25
  rf.resources.blockedrefreshbusy = true
  rf.spawn(function()
    local ok, result = pcall(startergui.GetCore, startergui, "GetBlockedUserIds")
    if ok and type(result) == "table" and state.alive then
      local updated = {}
      for key, value in pairs(result) do
        if tonumber(value) then updated[tonumber(value)] = true
        elseif value == true and tonumber(key) then updated[tonumber(key)] = true end
      end
      rf.resources.blockedcache = updated
      rf.resources.blockedready = true
      for _, card in pairs(rf.resources.playercards) do rf.updateplayerblockaction(card) end
    end
    rf.resources.blockedrefreshbusy = false
  end)
end

function rf.directblockplayer(player, unblock)
  local root = coregui:FindFirstChild("RobloxGui")
  local modules = root and root:FindFirstChild("Modules")
  if not modules then return false end
  for _, name in ipairs({"BlockingUtility", "PlayerDropDown"}) do
    local module = modules:FindFirstChild(name, true)
    if module and module:IsA("ModuleScript") then
      local loaded, library = pcall(require, module)
      if loaded and type(library) == "table" then
        local utility = library
        if type(library.CreateBlockingUtility) == "function" then
          local made, result = pcall(library.CreateBlockingUtility, library)
          if made and type(result) == "table" then utility = result end
        end
        local method = unblock and "UnblockPlayerAsync" or "BlockPlayerAsync"
        if type(utility[method]) == "function" then
          local ok, result = pcall(utility[method], utility, player)
          if ok and result == true then return true end
        end
      end
    end
  end
  return false
end

function rf.pressnativebutton(button)
  if not button or not button.Parent or not rf.nativevisible(button) then return false end
  local center = button.AbsolutePosition + button.AbsoluteSize * 0.5
  local virtualinputmanager = game:GetService("VirtualInputManager")
  pcall(function()
    virtualinputmanager:SendMouseMoveEvent(center.X, center.Y, game)
  end)
  local pressed = pcall(function()
    virtualinputmanager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
    task.wait()
    virtualinputmanager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
  end)
  if pressed then return true end
  if type(firesignal) == "function" then
    for _, signal in ipairs({button.Activated, button.MouseButton1Click}) do
      local allowed = true
      if type(getconnections) == "function" then
        local ok, connections = pcall(getconnections, signal)
        allowed = not ok or type(connections) ~= "table" or #connections > 0
      end
      if allowed and pcall(firesignal, signal) then return true end
    end
  end
  return false
end

function rf.nativevisible(object)
  local current = object
  while current do
    if current:IsA("GuiObject") and not current.Visible then return false end
    if current:IsA("LayerCollector") and not current.Enabled then return false end
    current = current.Parent
  end
  return true
end

function rf.nativebuttontext(button)
  local parts = {}
  if button:IsA("TextButton") then parts[#parts + 1] = tostring(button.Text or "") end
  for _, item in ipairs(button:GetDescendants()) do
    if item:IsA("TextLabel") and rf.nativevisible(item) then
      parts[#parts + 1] = tostring(item.Text or "")
    end
  end
  return table.concat(parts, " "):lower():gsub("%s+", " "):match("^%s*(.-)%s*$")
end

function rf.findblockconfirm(player, unblock)
  local root = coregui:FindFirstChild("RobloxGui") or coregui
  local action = unblock and "unblock" or "block"
  local playername = player.Name:lower()
  local displayname = player.DisplayName:lower()
  local best, score = nil, -1
  for _, button in ipairs(root:GetDescendants()) do
    if button:IsA("GuiButton") and not button:IsDescendantOf(state.overlay)
      and button.Visible and button.AbsoluteSize.X > 35 and button.AbsoluteSize.Y > 16
      and rf.nativevisible(button) then
      local label = rf.nativebuttontext(button)
      local primary = label == action or label == action .. " user" or label == action .. " player"
        or label == "confirm " .. action or label == "yes, " .. action
        or label == action .. " account"
      local generic = label == "confirm" or label == "yes" or label == "continue"
      if primary or generic then
        local group = button.Parent
        for depth = 1, 6 do
          if not group or group == root then break end
          local heading, username, cancellation, details, conflict = false, false, false, false, false
          for _, item in ipairs(group:GetDescendants()) do
            if (item:IsA("TextLabel") or item:IsA("TextButton")) and rf.nativevisible(item) then
              local line = tostring(item.Text or ""):lower()
              if line:find(playername, 1, true) or line:find(displayname, 1, true) then username = true end
              if line:find(action, 1, true) then heading = true end
              if not unblock and line:find("unblock", 1, true) then conflict = true end
              if line:find("are you sure", 1, true) or line:find("would you like", 1, true)
                or line:find("do you want", 1, true) or line:find("confirm", 1, true)
                or line:find("block this", 1, true) or line:find("block user", 1, true)
                or line:find("block player", 1, true) then details = true end
            end
            if item:IsA("GuiButton") and item ~= button and rf.nativevisible(item) then
              local option = rf.nativebuttontext(item)
              if option == "cancel" or option == "back" or option == "not now" or option == "no" then
                cancellation = true
              end
            end
          end
          if heading and not conflict and (cancellation or details) then
            local rank = (primary and 20 or 0) + (username and 10 or 0)
              + (cancellation and 5 or 0) + (details and 3 or 0) - depth
            if rank > score then
              best, score = button, rank
            end
            break
          end
          group = group.Parent
        end
      end
    end
  end
  return best
end

function rf.blockplayer(player)
  if not state.alive or not player or not player.Parent or player == localplayer then return end
  if rf.getblockedstatus(player) == true then
    rf.notification("Already blocked", "@" .. player.Name .. " is already blocked", player.UserId,
      "shield-check", Color3.fromRGB(118, 206, 163), "social:blocked:" .. player.UserId)
    return
  end
  rf.showmenu(false)
  rf.spawn(function()
    local direct = rf.directblockplayer(player)
    if direct then
      for _ = 1, 12 do
        if rf.getblockedstatus(player) == true then
          rf.notification("Player blocked", "@" .. player.Name .. " has been blocked", player.UserId,
            "shield-check", Color3.fromRGB(118, 206, 163), "social:blockdone:" .. player.UserId)
          return
        end
        task.wait(0.15)
      end
    end
    if rf.getblockedstatus(player) == true then return end
    local opened, err
    for _ = 1, 5 do
      opened, err = pcall(startergui.SetCore, startergui, "PromptBlockPlayer", player)
      if opened then break end
      task.wait(0.2)
    end
    if not opened then
      rf.notification("Block unavailable", tostring(err):sub(1, 105), player.UserId,
        "alert-circle", Color3.fromRGB(245, 139, 155), "social:blockerror:" .. player.UserId)
      return
    end
    local pressed = false
    local nextpress = 0
    local deadline = os.clock() + 6
    while state.alive and player.Parent and os.clock() < deadline do
      if rf.getblockedstatus(player) == true then
        rf.notification("Player blocked", "@" .. player.Name .. " has been blocked", player.UserId,
          "shield-check", Color3.fromRGB(118, 206, 163), "social:blockdone:" .. player.UserId)
        return
      end
      if os.clock() >= nextpress then
        local button = rf.findblockconfirm(player)
        if button then
          pressed = rf.pressnativebutton(button) or pressed
          nextpress = os.clock() + 0.85
        end
      end
      task.wait(0.13)
    end
    if rf.getblockedstatus(player) == true then
      rf.notification("Player blocked", "@" .. player.Name .. " has been blocked", player.UserId,
        "shield-check", Color3.fromRGB(118, 206, 163), "social:blockdone:" .. player.UserId)
    else
      rf.notification("Confirm block", "Finish the Roblox block confirmation for @" .. player.Name,
        player.UserId, "shield-alert", Color3.fromRGB(242, 183, 128), "social:blockpending:" .. player.UserId)
    end
  end)
end

function rf.unblockplayer(player)
  if not state.alive or not player or not player.Parent or player == localplayer then return end
  if rf.getblockedstatus(player) == false then
    rf.resources.blockedcache[player.UserId] = nil
    rf.resources.blockedready = true
    local card = rf.resources.playercards[player.UserId]
    if card then rf.updateplayerblockaction(card) end
    rf.notification("Not blocked", "@" .. player.Name .. " is not currently blocked", player.UserId,
      "shield-check", Color3.fromRGB(125, 212, 178), "social:notblocked:" .. player.UserId)
    return
  end
  rf.showmenu(false)
  rf.spawn(function()
    local direct = rf.directblockplayer(player, true)
    if direct then
      for _ = 1, 12 do
        if rf.getblockedstatus(player) == false then
          rf.resources.blockedcache[player.UserId] = nil
          rf.resources.blockedready = true
          local card = rf.resources.playercards[player.UserId]
          if card then rf.updateplayerblockaction(card) end
          rf.notification("Player unblocked", "@" .. player.Name .. " has been unblocked", player.UserId,
            "shield-check", Color3.fromRGB(125, 212, 178), "social:unblockdone:" .. player.UserId)
          return
        end
        task.wait(0.15)
      end
    end
    local opened, err
    for _ = 1, 5 do
      opened, err = pcall(startergui.SetCore, startergui, "PromptUnblockPlayer", player)
      if opened then break end
      task.wait(0.2)
    end
    if not opened then
      rf.notification("Unblock unavailable", tostring(err):sub(1, 105), player.UserId,
        "alert-circle", Color3.fromRGB(245, 139, 155), "social:unblockerror:" .. player.UserId)
      return
    end
    local nextpress = 0
    local deadline = os.clock() + 6
    while state.alive and player.Parent and os.clock() < deadline do
      if rf.getblockedstatus(player) == false then
        rf.resources.blockedcache[player.UserId] = nil
        rf.resources.blockedready = true
        local card = rf.resources.playercards[player.UserId]
        if card then rf.updateplayerblockaction(card) end
        rf.notification("Player unblocked", "@" .. player.Name .. " has been unblocked", player.UserId,
          "shield-check", Color3.fromRGB(125, 212, 178), "social:unblockdone:" .. player.UserId)
        return
      end
      if os.clock() >= nextpress then
        local button = rf.findblockconfirm(player, true)
        if button then
          rf.pressnativebutton(button)
          nextpress = os.clock() + 0.85
        end
      end
      task.wait(0.13)
    end
    rf.refreshblockedplayers(true)
    if rf.getblockedstatus(player) ~= false then
      rf.notification("Confirm unblock", "Finish the Roblox unblock confirmation for @" .. player.Name,
        player.UserId, "shield-check", Color3.fromRGB(242, 183, 128), "social:unblockpending:" .. player.UserId)
    end
  end)
end

function rf.playersocialprompt(action, player)
  if not state.alive or not player or not player.Parent or player == localplayer then return end
  if action == "block" then
    if rf.getblockedstatus(player) == true then
      rf.unblockplayer(player)
    else
      rf.blockplayer(player)
    end
    return
  end
  if action == "unblock" then
    rf.unblockplayer(player)
    return
  end
  if action ~= "friend" then return end
  local statusok, status = pcall(localplayer.GetFriendStatus, localplayer, player)
  if statusok and status == Enum.FriendStatus.Friend then
    rf.notification("Already connected", "You are already friends with @" .. player.Name,
      player.UserId, "user-check", Color3.fromRGB(109, 211, 168), "social:existing:" .. player.UserId)
    return
  end
  if statusok and status == Enum.FriendStatus.FriendRequestSent then
    rf.notification("Request pending", "Friend request already sent to @" .. player.Name,
      player.UserId, "clock", Color3.fromRGB(178, 172, 210), "social:pending:" .. player.UserId)
    return
  end
  local direct = pcall(function() localplayer:RequestFriendship(player) end)
  if direct then return end
  local ok, err = pcall(startergui.SetCore, startergui, "PromptSendFriendRequest", player)
  if ok then rf.tryfriendconfirm(player) end
  if not ok then
    rf.notification("Player action unavailable", tostring(err):sub(1, 100), player.UserId,
      "alert-circle", Color3.fromRGB(245, 139, 155), "social:friend:" .. player.UserId)
  end
end

function rf.findwhisperchannel(player)
  local channels = rf.resources.textchatservice:FindFirstChild("TextChannels")
  if not channels then return nil end
  local own = tostring(localplayer.UserId)
  local target = tostring(player.UserId)
  for _, channel in ipairs(channels:GetChildren()) do
    if channel:IsA("TextChannel") then
      local first, second = channel.Name:match("^RBXWhisper:(%d+)_(%d+)$")
      if first and ((first == own and second == target) or (first == target and second == own)) then
        return channel
      end
    end
  end
  return nil
end

function rf.preparewhisperchannel(player)
  local channel = rf.findwhisperchannel(player)
  if channel then return channel end
  local channels = rf.resources.textchatservice:FindFirstChild("TextChannels")
  if not channels then return nil, "Roblox text channels are unavailable" end
  local created, result = pcall(function()
    return rf.resources.textchatservice:CreateUserWhisperAsync(player.UserId)
  end)
  if created and typeof(result) == "Instance" and result:IsA("TextChannel") then
    channel = rf.findwhisperchannel(player)
    if channel == result then return channel end
  end
  channel = rf.findwhisperchannel(player)
  if channel then return channel end
  return nil, "Roblox has no private chat channel for @" .. player.Name
end

function rf.sendplayerwhisper(player, content)
  if not state.alive or not player or not player.Parent or player == localplayer then return false end
  local message = tostring(content or ""):match("^%s*(.-)%s*$")
  if message == "" then return false end
  if #message > 200 then
    rf.notification("Message too long", "Please use 200 characters or fewer", player.UserId,
      "message-square", Color3.fromRGB(245, 180, 155), "whisper:length:" .. player.UserId)
    return false
  end
  local channel, reason = rf.preparewhisperchannel(player)
  if not channel then
    rf.notification("Private message unavailable", (reason or "Whisper unavailable"):sub(1, 110),
      player.UserId, "message-square", Color3.fromRGB(245, 139, 155),
      "whisper:channel:" .. player.UserId .. ":" .. tostring(os.clock()))
    return false
  end
  local ok, result = pcall(channel.SendAsync, channel, message)
  if not ok or not result or result.Status ~= Enum.TextChatMessageStatus.Sending
    and result.Status ~= Enum.TextChatMessageStatus.Success then
    local detail = not ok and tostring(result) or result and tostring(result.Status.Name)
      or "Roblox rejected the private message"
    rf.notification("Private message unavailable", detail:sub(1, 105), player.UserId,
      "message-square", Color3.fromRGB(245, 139, 155),
      "whisper:error:" .. player.UserId .. ":" .. tostring(os.clock()))
    return false
  end
  rf.notification("Private message", result.Status == Enum.TextChatMessageStatus.Success
    and "Sent to @" .. player.Name or "Submitted to Roblox for @" .. player.Name, player.UserId,
    "message-square", Color3.fromRGB(145, 208, 169),
    "whisper:sent:" .. player.UserId .. ":" .. tostring(os.clock()))
  return true
end

function rf.setplayercardexpanded(card, expanded)
  if not card or not card.frame or not card.frame.Parent then return end
  card.expanded = expanded
  card.details.Visible = expanded
  card.composer.Visible = expanded and card.composing == true
  local height = expanded and (card.composing and 192 or 148) or 88
  if card.sizetween then card.sizetween:Cancel() end
  card.sizetween = tweenservice:Create(card.frame,
    TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
      Size = UDim2.new(1, 0, 0, height)
    })
  card.sizetween:Play()
end

function rf.toggleplayercard(card)
  if not card or not card.player or not card.player.Parent then return end
  local selected = rf.resources.expandedplayerid ~= card.player.UserId
  rf.resources.expandedplayerid = selected and card.player.UserId or nil
  for _, other in pairs(rf.resources.playercards) do
    if other ~= card and other.expanded then
      other.composing = false
      rf.setplayercardexpanded(other, false)
    end
  end
  if not selected then card.composing = false end
  rf.setplayercardexpanded(card, selected)
end

function rf.playeractionbutton(parent, title, iconname, index, callback, disabled)
  local button = rf.create("TextButton", {
    Position = UDim2.new((index - 1) / 4, 0, 0, 0),
    Size = UDim2.new(1 / 4, 0, 1, 0),
    BackgroundColor3 = uitheme.surfacealt, BackgroundTransparency = 1,
    BorderSizePixel = 0, Text = "", AutoButtonColor = false,
    Active = not disabled, ZIndex = 23
  }, parent)
  local tint = disabled and uitheme.textdim or
    title == "Block" and Color3.fromRGB(220, 145, 158) or uitheme.accent
  local icon = rf.iconimage(button, iconname, tint,
    UDim2.new(0.5, -48, 0.5, -9), UDim2.fromOffset(18, 18), 24)
  local label = rf.create("TextLabel", {
    Position = UDim2.new(0.5, -23, 0, 0), Size = UDim2.new(0.5, 20, 1, 0),
    BackgroundTransparency = 1, Text = title, Font = Enum.Font.Code,
    TextSize = 14, TextColor3 = disabled and uitheme.textdim
      or uitheme.text,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 24
  }, button)
  if index > 1 then
    rf.create("Frame", {
      Position = UDim2.fromOffset(0, 9), Size = UDim2.new(0, 1, 1, -18),
      BackgroundColor3 = uitheme.stroke, BorderSizePixel = 0,
      ZIndex = 25
    }, button)
  end
  if not disabled then
    button.MouseEnter:Connect(function()
      if state.alive then
        tweenservice:Create(button, TweenInfo.new(0.14), {
          BackgroundTransparency = 0,
          BackgroundColor3 = title == "Block" and button:GetAttribute("blockstate") ~= "blocked"
            and Color3.fromRGB(65, 39, 59) or uitheme.hover
        }):Play()
      end
    end)
    button.MouseLeave:Connect(function()
      if state.alive then
        tweenservice:Create(button, TweenInfo.new(0.14), {
          BackgroundTransparency = 1
        }):Play()
      end
    end)
    button.MouseButton1Click:Connect(callback)
  end
  return button, label, icon
end

function rf.teleporttoplayer(target)
  if not state.alive or not target or target == localplayer or not target.Parent then return false end
  local character = localplayer.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  local root = character and character:FindFirstChild("HumanoidRootPart")
  local targetcharacter = target.Character
  local targethumanoid = targetcharacter and targetcharacter:FindFirstChildOfClass("Humanoid")
  local targetroot = targetcharacter and targetcharacter:FindFirstChild("HumanoidRootPart")
  if not character or not root or not humanoid or humanoid.Health <= 0
    or not targetroot or not targethumanoid or targethumanoid.Health <= 0 then
    rf.notification("Teleport unavailable", "Both players must be alive", target.UserId,
      "map-pin", Color3.fromRGB(240, 160, 154), "player:teleport:unavailable:" .. tostring(target.UserId))
    return false
  end
  if not rf.motionacquire("manualshot", 3) then
    rf.notification("Teleport unavailable", "Another movement action is in progress", target.UserId,
      "map-pin", Color3.fromRGB(240, 160, 154), "player:teleport:busy:" .. tostring(target.UserId))
    return false
  end
  local destination = targetroot.CFrame * CFrame.new(0, 2, 4)
  local ok = pcall(function()
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    rf.teleportpivot(character, destination)
  end)
  if not ok then
    rf.motionrelease("manualshot", true)
    rf.notification("Teleport unavailable", "Failed to move character", target.UserId,
      "map-pin", Color3.fromRGB(240, 160, 154), "player:teleport:error:" .. tostring(target.UserId))
    return false
  end
  rf.notification("Teleport to player", "Moved near @" .. target.Name, target.UserId,
    "map-pin", Color3.fromRGB(125, 209, 187), "player:teleport:success:" .. tostring(target.UserId))
  return true
end

function rf.createplayercard(p)
  local outer = rf.create("Frame", {
    Name = "Player_" .. tostring(p.UserId), Size = UDim2.new(1, 0, 0, 88),
    BackgroundColor3 = uitheme.border, BorderSizePixel = 0, ClipsDescendants = true,
    LayoutOrder = 0, ZIndex = 15
  }, playerlist)
  rf.create("UIStroke", {Thickness = 1, Color = uitheme.shadow}, outer)
  local rim = rf.create("Frame", {
    Position = UDim2.fromOffset(3, 3), Size = UDim2.new(1, -6, 1, -6),
    BackgroundColor3 = uitheme.stroke, BorderSizePixel = 0, ZIndex = 16
  }, outer)
  local face = rf.create("Frame", {
    Position = UDim2.fromOffset(2, 2), Size = UDim2.new(1, -4, 1, -4),
    BackgroundColor3 = uitheme.surfacealt, BorderSizePixel = 0, ZIndex = 17
  }, rim)
  local portrait = rf.create("Frame", {
    Position = UDim2.fromOffset(11, 11), Size = UDim2.fromOffset(56, 56),
    BackgroundColor3 = uitheme.surface, BorderSizePixel = 0, ZIndex = 18
  }, face)
  rf.create("UIStroke", {Thickness = 1, Color = uitheme.strokehover}, portrait)
  local image = rf.create("ImageLabel", {
    Position = UDim2.fromOffset(2, 2), Size = UDim2.new(1, -4, 1, -4),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(p.UserId) .. "&w=150&h=150",
    ScaleType = Enum.ScaleType.Crop, ZIndex = 19
  }, portrait)
  rf.spawn(function()
    for attempt = 1, 3 do
      if not state.alive or not image.Parent or not p.Parent then return end
      local ok, content, ready = pcall(players.GetUserThumbnailAsync, players,
        p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
      if ok and ready and type(content) == "string" and content ~= "" then
        if state.alive and image.Parent and p.Parent then image.Image = content end
        return
      end
      task.wait(attempt * 0.2)
    end
  end)
  local name = rf.create("TextLabel", {
    Position = UDim2.fromOffset(82, 7), Size = UDim2.new(1, -254, 0, 24),
    BackgroundTransparency = 1, Text = "", Font = Enum.Font.Arcade,
    TextSize = 17, TextTruncate = Enum.TextTruncate.AtEnd,
    TextColor3 = uitheme.text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 19
  }, face)
  local username = rf.create("TextLabel", {
    Position = UDim2.fromOffset(82, 30), Size = UDim2.new(1, -254, 0, 20),
    BackgroundTransparency = 1, Text = "", Font = Enum.Font.Code,
    TextSize = 15, TextTruncate = Enum.TextTruncate.AtEnd,
    TextColor3 = uitheme.textmuted, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 19
  }, face)
  local status = rf.create("TextLabel", {
    Position = UDim2.fromOffset(82, 53), Size = UDim2.new(1, -254, 0, 18),
    BackgroundTransparency = 1, Text = "", Font = Enum.Font.Code,
    TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd,
    TextColor3 = uitheme.textdim, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 19
  }, face)
  local badge = rf.create("Frame", {
    Position = UDim2.new(1, -160, 0, 13), Size = UDim2.fromOffset(145, 29),
    BackgroundColor3 = uitheme.hover, BorderSizePixel = 0, ZIndex = 18
  }, face)
  local badgestroke = rf.create("UIStroke", {Thickness = 1, Color = uitheme.stroke}, badge)
  local roletext = rf.create("TextLabel", {
    Position = UDim2.fromOffset(4, 0), Size = UDim2.new(1, -8, 1, 0),
    BackgroundTransparency = 1, Text = "UNKNOWN", Font = Enum.Font.Arcade,
    TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd,
    TextColor3 = uitheme.text, ZIndex = 19
  }, badge)
  local userid = rf.create("TextLabel", {
    Position = UDim2.new(1, -165, 0, 50), Size = UDim2.fromOffset(150, 20),
    BackgroundTransparency = 1, Text = "ID " .. tostring(p.UserId),
    Font = Enum.Font.Code, TextSize = 12,
    TextColor3 = uitheme.textdim, TextXAlignment = Enum.TextXAlignment.Right,
    TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 19
  }, face)
  local details = rf.create("Frame", {
    Position = UDim2.fromOffset(10, 85), Size = UDim2.new(1, -20, 0, 100),
    BackgroundTransparency = 1, Visible = false, ZIndex = 20
  }, face)
  rf.create("Frame", {
    Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = uitheme.stroke, BorderSizePixel = 0, ZIndex = 21
  }, details)
  local actions = rf.create("Frame", {
    Position = UDim2.fromOffset(0, 8), Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = uitheme.surfacealt, BorderSizePixel = 0, ZIndex = 21,
    ClipsDescendants = true
  }, details)
  rf.create("UIStroke", {Thickness = 1, Color = uitheme.stroke}, actions)
  local composer = rf.create("Frame", {
    Position = UDim2.fromOffset(0, 56), Size = UDim2.new(1, 0, 0, 37),
    BackgroundTransparency = 1, Visible = false, ZIndex = 21
  }, details)
  local textbox = rf.create("TextBox", {
    Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -91, 0, 34),
    BackgroundColor3 = uitheme.surface, BorderSizePixel = 0,
    Font = Enum.Font.Code, TextSize = 14, TextColor3 = uitheme.text,
    PlaceholderText = "Send a private message...", PlaceholderColor3 = uitheme.textdim,
    Text = "", ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 23
  }, composer)
  rf.create("UIStroke", {Thickness = 1, Color = uitheme.strokehover}, textbox)
  rf.create("UIPadding", {PaddingLeft = UDim.new(0, 11), PaddingRight = UDim.new(0, 8)}, textbox)
  local send = rf.create("TextButton", {
    Position = UDim2.new(1, -83, 0, 0), Size = UDim2.fromOffset(83, 34),
    BackgroundColor3 = uitheme.selected, BorderSizePixel = 0, AutoButtonColor = false,
    Text = "Send", Font = Enum.Font.Code, TextSize = 14,
    TextColor3 = uitheme.text, ZIndex = 23
  }, composer)
  rf.create("UIStroke", {Thickness = 1, Color = uitheme.strokeselected}, send)
  send.MouseEnter:Connect(function() send.BackgroundColor3 = uitheme.selectedhover end)
  send.MouseLeave:Connect(function() send.BackgroundColor3 = uitheme.selected end)
  local function attachmarquee(label)
    local clip = rf.create("Frame", {Position = label.Position, Size = label.Size, BackgroundTransparency = 1,
      BorderSizePixel = 0, ClipsDescendants = true, ZIndex = label.ZIndex}, face)
    label.Parent = clip
    label.AnchorPoint = Vector2.new(0, 0.5)
    label.Position = UDim2.fromScale(0, 0.5)
    label.Size = UDim2.fromScale(1, 1)
    label.TextTruncate = Enum.TextTruncate.None
    local function refresh()
      if not state.alive or not clip.Parent or clip.AbsoluteSize.X <= 0 then return end
      local scale, ancestor = 1, clip
      while ancestor and ancestor:IsA("GuiObject") do
        local component = ancestor:FindFirstChildOfClass("UIScale")
        if component then scale *= component.Scale end
        ancestor = ancestor.Parent
      end
      local available = clip.AbsoluteSize.X / math.max(scale, 0.01)
      local measured = textservice:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(10000, 100)).X + 4
      rf.resources.marquees = rf.resources.marquees or setmetatable({}, {__mode = "k"})
      label.Position = UDim2.fromScale(0, 0.5)
      if measured > available + 1 then
        label.Size = UDim2.new(0, measured, 1, 0)
        rf.resources.marquees[label] = {clip = clip, face = face, overflow = measured - available, started = os.clock(), offset = 0}
      else
        label.Size = UDim2.fromScale(1, 1)
        rf.resources.marquees[label] = nil
      end
    end
    label:GetPropertyChangedSignal("Text"):Connect(refresh)
    clip:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh)
    rf.defer(refresh)
  end
  attachmarquee(name)
  attachmarquee(username)
  local card = {frame = outer, image = image, name = name,
    username = username, status = status, badge = badge, stroke = badgestroke,
    roletext = roletext, userid = userid, player = p, details = details,
    composer = composer, textbox = textbox,
    expanded = false, composing = false}
  local click = rf.create("TextButton", {
    Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, 80),
    BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 20
  }, face)
  click.MouseButton1Click:Connect(function() rf.toggleplayercard(card) end)
  if p ~= localplayer then
    rf.playeractionbutton(actions, "Friend", "user-plus", 1, function()
      rf.playersocialprompt("friend", p)
    end)
    local blockbutton, blocklabel, blockicon = rf.playeractionbutton(actions, "Block", "ban", 2, function()
      local blocked = rf.getblockedstatus(p)
      if blocked == nil then blocked = rf.resources.blockedcache[p.UserId] == true end
      rf.playersocialprompt(blocked and "unblock" or "block", p)
    end)
    card.blockbutton, card.blocklabel, card.blockicon = blockbutton, blocklabel, blockicon
    rf.updateplayerblockaction(card)
    rf.playeractionbutton(actions, "Message", "message-square", 3, function()
      card.composing = not card.composing
      rf.setplayercardexpanded(card, true)
      if card.composing then textbox:CaptureFocus() end
    end)
    rf.playeractionbutton(actions, "Teleport", "map-pin", 4, function()
      rf.teleporttoplayer(p)
    end)
  else
    rf.create("TextLabel", {
      Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
      Text = "YOUR PROFILE  /  NO SOCIAL ACTIONS", Font = Enum.Font.Code,
      TextSize = 14, TextColor3 = uitheme.textdim,
      ZIndex = 23
    }, actions)
  end
  local function sendmessage()
    if card.messagesending then return end
    local message = textbox.Text:match("^%s*(.-)%s*$")
    if not message or message == "" then return end
    card.messagesending = true
    card.composing = false
    textbox:ReleaseFocus()
    rf.setplayercardexpanded(card, true)
    send.Text = "..."
    rf.spawn(function()
      local ok, sent = pcall(rf.sendplayerwhisper, p, message)
      if card.frame.Parent and state.alive then
        if ok and sent then
          if textbox.Text == message then textbox.Text = "" end
        elseif not ok then
          rf.notification("Private message unavailable", tostring(sent):sub(1, 105), p.UserId,
            "message-square", Color3.fromRGB(245, 139, 155), "whisper:exception:" .. p.UserId)
        end
        send.Text = "Send"
      end
      card.messagesending = false
    end)
  end
  send.MouseButton1Click:Connect(sendmessage)
  textbox.FocusLost:Connect(function(enter)
    if enter then sendmessage() end
  end)
  if rf.resources.expandedplayerid == p.UserId then
    card.expanded = true
    details.Visible = true
    outer.Size = UDim2.new(1, 0, 0, 148)
  end
  return card
end

function rf.refreshplayerlist()
  if not state.alive or not playerlist or not playerlist.Parent then return end
  local roster = players:GetPlayers()
  local present = {}
  for _, p in ipairs(roster) do present[p.UserId] = true end
  for id, card in pairs(rf.resources.playercards) do
    if not present[id] or not card.frame.Parent then
      if rf.resources.marquees then rf.resources.marquees[card.name] = nil; rf.resources.marquees[card.username] = nil end
      card.frame:Destroy()
      rf.resources.playercards[id] = nil
      if rf.resources.expandedplayerid == id then rf.resources.expandedplayerid = nil end
    end
  end
  local savedposition = playerlist.CanvasPosition
  if rf.resources.playerorderindex == 0 then
    table.sort(roster, function(a, b)
      if a == b then return false end
      if a == localplayer then return true end
      if b == localplayer then return false end
      local rolea = rf.playerlistrole(a)
      local roleb = rf.playerlistrole(b)
      local prioritya = rf.resources.playerrolepriority[rolea] or 9
      local priorityb = rf.resources.playerrolepriority[roleb] or 9
      if prioritya ~= priorityb then return prioritya < priorityb end
      return a.Name:lower() < b.Name:lower()
    end)
  end
  for _, p in ipairs(roster) do
    if not rf.resources.playerorder[p.UserId] then
      rf.resources.playerorderindex += 1
      rf.resources.playerorder[p.UserId] = rf.resources.playerorderindex
    end
  end
  table.sort(roster, function(a, b)
    return rf.resources.playerorder[a.UserId] < rf.resources.playerorder[b.UserId]
  end)
  for index, p in ipairs(roster) do
    local card = rf.resources.playercards[p.UserId]
    if not card then
      card = rf.createplayercard(p)
      rf.resources.playercards[p.UserId] = card
    end
    if card.frame.LayoutOrder ~= index then card.frame.LayoutOrder = index end
    local displayname, username = rf.compacttext(p.DisplayName), "@" .. p.Name
    if card.name.Text ~= displayname then card.name.Text = displayname end
    if card.username.Text ~= username then card.username.Text = username end
    local role, status, dead = rf.playerlistrole(p)
    local tint = colors[role] or Color3.fromRGB(156, 151, 171)
    if dead then tint = tint:Lerp(Color3.fromRGB(104, 100, 108), 0.55) end
    local rolelabel = string.upper(role)
    local statuslabel = (p == localplayer and "YOU / " or "") .. status
    local statuscolor = dead and Color3.fromRGB(240, 147, 147) or uitheme.textdim
    if card.stroke.Color ~= tint then card.stroke.Color = tint end
    if card.roletext.Text ~= rolelabel then card.roletext.Text = rolelabel end
    if card.roletext.TextColor3 ~= tint then card.roletext.TextColor3 = tint end
    if card.status.Text ~= statuslabel then card.status.Text = statuslabel end
    if card.status.TextColor3 ~= statuscolor then card.status.TextColor3 = statuscolor end
  end
  playercountlabel.Text = tostring(#roster) .. " PLAYER" .. (#roster == 1 and "" or "S")
  playerempty.Visible = #roster == 0
  playerlist.CanvasSize = UDim2.fromOffset(0, playerlistlayout.AbsoluteContentSize.Y + 10)
  local maximum = math.max(0, playerlist.CanvasSize.Y.Offset - playerlist.AbsoluteSize.Y)
  if math.abs(playerlist.CanvasPosition.Y - savedposition.Y) > 1 then
    playerlist.CanvasPosition = Vector2.new(0, math.clamp(savedposition.Y, 0, maximum))
  end
  rf.refreshblockedplayers(false)
end

for _, definition in ipairs({{"PlayerBlockedEvent", true}, {"PlayerUnblockedEvent", false}}) do
  rf.spawn(function()
    for _ = 1, 10 do
      if not state.alive then return end
      local ok, event = pcall(startergui.GetCore, startergui, definition[1])
      if ok and typeof(event) == "Instance" and event:IsA("BindableEvent") then
        table.insert(state.connections, event.Event:Connect(function(value)
          local id = typeof(value) == "Instance" and value:IsA("Player") and value.UserId
            or tonumber(value)
          if id then
            rf.resources.blockedcache[id] = definition[2] or nil
            rf.resources.blockedready = true
            local card = rf.resources.playercards[id]
            if card then rf.updateplayerblockaction(card) end
          else
            rf.resources.blockedrefreshat = 0
            rf.refreshblockedplayers(true)
          end
        end))
        return
      end
      task.wait(0.5)
    end
  end)
end

table.insert(state.connections, playerlistlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
  if state.alive and playerlist.Parent then
    playerlist.CanvasSize = UDim2.fromOffset(0, playerlistlayout.AbsoluteContentSize.Y + 10)
  end
end))
rf.resources.playerlistelapsed = 0
table.insert(state.connections, runservice.Heartbeat:Connect(function(dt)
  if not state.alive or currentpage ~= "players" or not config.showmenu then
    rf.resources.playerlistelapsed = 0
    return
  end
  rf.resources.playerlistelapsed += dt
  if rf.resources.playerlistelapsed >= 0.3 then
    rf.resources.playerlistelapsed = 0
    rf.refreshplayerlist()
  end
end))

rf.resources.searchaliases = {
  autofarm = "autofarm auto farm collect coins farming grind nearest coin",
  autoshoot = "shoot gun fire murderer aim auto shoot triggerbot",
  autovote = "auto vote map voting map selection maps prefer preferred voting pad detector reset lobby",
  votescan = "scan available voting maps active vote pads status",
  autoshoothitpart = "hit part silent aim body head torso arms legs auto shoot",
  autoshootbehind = "behind murderer teleport hover",
  autoshootfar = "far hover teleport shoot murderer",
  autoshootcover = "wall peek cover line sight visible shoot",
  autofarmtweenspeed = "farm speed tween coins movement velocity",
  autoshootwhenfull = "only shoot murderer when current round coin bag is full",
  farmhidefull = "hide full bag up anchor sky",
  farmresetfull = "reset respawn character when coin bag is full during auto collect",
  farmreturnfinished = "return home done coins finish",
  farmreturnfull = "return full bag",
  farmfulldestination = "full bag home lobby stay return",
  farmfinishdestination = "finish return lobby start home stay",
  autokillall = "kill all murderer knife attack",
  autokillmode = "knife attack teleport touch interest cframe method",
  guikeybind = "toggle menu shortcut hotkey keybind",
  shootmurderer = "shoot murderer shortcut keybind instant fire",
  fpscapmode = "fps limit frame cap unlock unlimited framerate performance",
  removetextures = "texture map remove low graphics performance",
  simplematerials = "simplify materials graphics smoothplastic low lag",
  disablemapfx = "particles lights effects disable lag fps",
  distanceculling = "cull distant decorative props performance fps distance",
  frustumculling = "cull offscreen decorations viewport frustum fps",
  disablepostfx = "disable bloom sun rays blur depth of field color effects fps",
  lowqualitywater = "simplify terrain water waves reflectance performance fps",
  disablefade = "disable all fade visuals transparency screen camera spawn transition blackout without interrupting fade events",
  persistnoclip = "global noclip wall collision no collide",
  autofarmnoclip = "auto collect noclip independent collision movement",
  togglenoclip = "toggle noclip keybind collision off movement through walls",
  walkspeedpreset = "walk speed movement sprint rapid quick fast",
  coinchams = "coin highlight esp see coins",
  espmode = "esp highlight type drawing new renderer player boxes outline",
  antifling = "no fling protect collision anti fling",
  gunbeamstyle = "beam visual effect lightning bolt electricity lava molten magma prism ion ember arc void minimal gunfire colours",
  previewgunfx = "preview gun beams vfx lightning lava cinematic camera effect demo",
  gunbeamwidth = "beam thickness gun shot line width thin standard bold",
  gunbeamglow = "gun glow layered beam plasma effects",
  gunbeamtracer = "gun bullet moving pulse tracer energy effect",
  gunbeammuzzle = "gun flash muzzle flare shooting",
  gunbeamimpact = "gun bullet impact sparks particles",
  throughwalls = "wallhack esp visible through walls",
  gunmarker = "gun drop marker dropped gun",
  autopickup = "automatic gun pickup dropped sheriff gun collect",
  fovmode = "field of view camera zoom fov",
  fullbright = "bright daylight lighting visibility",
  clearfog = "remove fog distance atmosphere",
  noshadows = "disable shadow fps",
  r6tracking = "r6 player rigs skeleton",
  skeleton = "skeleton esp bones",
  aim = "aim assist aimbot targeting",
  aimshoot = "auto shoot weapon shooter aiming",
  visualperformance = "performance fps optimize graphics textures material",
  visuals = "esp visuals chams highlight graphics",
  autofarmreturn = "return when full bag finish hide destination",
  keybinds = "keyboard shortcuts bindings hotkeys",
  players = "players roster user list usernames display names roles avatars headshots murder sheriff hero innocent spectators"
}
local function searchnormalize(value)
  return tostring(value or ""):lower():gsub("[%p_]+", " "):gsub("%s+", " "):match("^%s*(.-)%s*$")
end
local function searchdistance(a, b)
  if math.abs(#a - #b) > 2 then return 3 end
  local previous = {}
  for j = 0, #b do previous[j] = j end
  for i = 1, #a do
    local current = {[0] = i}
    for j = 1, #b do
      local cost = a:sub(i, i) == b:sub(j, j) and 0 or 1
      current[j] = math.min(previous[j] + 1, current[j - 1] + 1, previous[j - 1] + cost)
    end
    previous = current
  end
  return previous[#b]
end
local function searchscore(query, record)
  local title = searchnormalize(record.title)
  local path = searchnormalize(pagetitles[record.page] or record.page)
  local aliases = searchnormalize(rf.resources.searchaliases[record.key] or "")
  local key = searchnormalize(record.key)
  local labelscore = title == query and 1200 or title:find(query, 1, true) and 850 or 0
  if aliases:find(query, 1, true) then labelscore = math.max(labelscore, 540) end
  if key:find(query, 1, true) then labelscore = math.max(labelscore, 460) end
  if path:find(query, 1, true) then labelscore = math.max(labelscore, 260) end
  if labelscore > 0 then return labelscore + (record.page ~= "main" and 4 or 0) end
  local words = {}
  for word in (title .. " " .. aliases .. " " .. key .. " " .. path):gmatch("%S+") do
    words[#words + 1] = word
  end
  local score = 0
  for searched in query:gmatch("%S+") do
    local best = 0
    for _, word in ipairs(words) do
      if word == searched then
        best = 150
        break
      elseif #searched >= 2 and word:sub(1, #searched) == searched then
        best = math.max(best, 115)
      elseif #searched >= 3 and word:find(searched, 1, true) then
        best = math.max(best, 85)
      elseif #searched >= 3 and math.abs(#searched - #word) <= 2 then
        local distance = searchdistance(searched, word)
        if distance == 1 then best = math.max(best, 74)
        elseif distance == 2 and #searched >= 5 then best = math.max(best, 46) end
      end
    end
    if best == 0 then return 0 end
    score += best
  end
  return score
end
local function searchpath(record)
  local parents = {}
  local page = record.page
  while page and page ~= "main" do
    table.insert(parents, 1, pagetitles[page] or page:upper())
    page = pageparents[page]
  end
  if #parents == 0 then return "HOME / QUICK ACCESS" end
  return table.concat(parents, " / ")
end
searchview = rf.create("Frame", {
  Name = "SearchResults", Size = UDim2.fromScale(1, 1),
  BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 13
}, pagecontent)
rf.resources.searchheading = rf.create("TextLabel", {
  Position = UDim2.fromOffset(14, 4), Size = UDim2.new(1, -28, 0, 28),
  BackgroundTransparency = 1, Font = Enum.Font.Arcade, TextSize = 14,
  TextColor3 = uitheme.textmuted, Text = "SEARCH RESULTS",
  TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14
}, searchview)
rf.resources.searchscroll = rf.create("ScrollingFrame", {
  Name = "ResultsList", Position = UDim2.fromOffset(9, 38),
  Size = UDim2.new(1, -18, 1, -48),
  BackgroundTransparency = 1, BorderSizePixel = 0,
  ScrollBarThickness = 3, ScrollBarImageColor3 = uitheme.scroll,
  CanvasSize = UDim2.fromOffset(0, 0), ScrollingDirection = Enum.ScrollingDirection.Y,
  ZIndex = 14, Active = true
}, searchview)
rf.resources.searchlayout = rf.create("UIListLayout", {
  FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder,
  Padding = UDim.new(0, 8)
}, rf.resources.searchscroll)
rf.resources.searchnone = rf.create("TextLabel", {
  Position = UDim2.fromOffset(15, 110), Size = UDim2.new(1, -30, 0, 55),
  BackgroundTransparency = 1, Font = Enum.Font.Arcade, TextSize = 16,
  TextColor3 = uitheme.textdim, Text = "No matching settings found",
  TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 15, Visible = false
}, searchview)
local function searchgo(record)
  if not record then return end
  searchinput.Text = ""
  searchinput:ReleaseFocus()
  selectpage(record.kind == "page" and record.key or record.page)
  if record.kind ~= "page" and record.button and record.button.outer.Parent then
    local flash = rf.create("UIStroke", {
      Thickness = 2, Color = uitheme.accentbright, Transparency = 0
    }, record.button.outer)
    tweenservice:Create(flash, TweenInfo.new(0.95, Enum.EasingStyle.Quad), {Transparency = 1}):Play()
    rf.delay(1.05, function()
      if flash.Parent then flash:Destroy() end
    end)
  end
end
for index = 1, 14 do
  local result = rf.create("TextButton", {
    Name = "Result" .. tostring(index), Size = UDim2.new(1, -6, 0, 58),
    BackgroundColor3 = uitheme.surface, BorderSizePixel = 0,
    Text = "", AutoButtonColor = false, LayoutOrder = index,
    ZIndex = 15, Visible = false
  }, rf.resources.searchscroll)
  rf.create("UIStroke", {Thickness = 1, Color = uitheme.stroke}, result)
  local heading = rf.create("TextLabel", {
    Position = UDim2.fromOffset(13, 5), Size = UDim2.new(1, -44, 0, 26),
    BackgroundTransparency = 1, Font = Enum.Font.Arcade, TextSize = 15,
    TextColor3 = uitheme.text,
    TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 16
  }, result)
  local category = rf.create("TextLabel", {
    Position = UDim2.fromOffset(13, 30), Size = UDim2.new(1, -40, 0, 21),
    BackgroundTransparency = 1, Font = Enum.Font.Code, TextSize = 13,
    TextColor3 = uitheme.textdim,
    TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 16
  }, result)
  rf.create("TextLabel", {
    Position = UDim2.new(1, -31, 0, 10), Size = UDim2.fromOffset(24, 36),
    BackgroundTransparency = 1, Font = Enum.Font.Arcade, TextSize = 18,
    Text = ">", TextColor3 = uitheme.accent, ZIndex = 16
  }, result)
  local slot = {button = result, heading = heading, category = category, record = nil}
  searchslots[#searchslots + 1] = slot
  result.MouseEnter:Connect(function() result.BackgroundColor3 = uibuttoncolor(false, true) end)
  result.MouseLeave:Connect(function() result.BackgroundColor3 = uibuttoncolor(false, false) end)
  result.Activated:Connect(function() searchgo(slot.record) end)
end
table.insert(state.connections, rf.resources.searchlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
  rf.resources.searchscroll.CanvasSize = UDim2.fromOffset(0, rf.resources.searchlayout.AbsoluteContentSize.Y + 6)
end))
local function searchrefresh()
  local query = searchnormalize(searchinput.Text:sub(1, 80))
  searchclear.Visible = searchinput.Text ~= ""
  rf.resources.searchhint.Visible = searchinput.Text == "" and not searchinput:IsFocused()
  table.clear(searchmatches)
  if query ~= "" then
    local unique = {}
    for _, record in ipairs(searchcatalog) do
      local score = searchscore(query, record)
      if score > 0 then
        local key = record.kind .. ":" .. record.key
        local previous = unique[key]
        if not previous or score > previous.score then
          unique[key] = {record = record, score = score}
        end
      end
    end
    for _, result in pairs(unique) do searchmatches[#searchmatches + 1] = result end
    table.sort(searchmatches, function(a, b)
      if a.score ~= b.score then return a.score > b.score end
      return a.record.title < b.record.title
    end)
  end
  rf.resources.searchheading.Text = string.format("SEARCH RESULTS  /  %d MATCH%s", #searchmatches, #searchmatches == 1 and "" or "ES")
  rf.resources.searchnone.Visible = query ~= "" and #searchmatches == 0
  for i, slot in ipairs(searchslots) do
    local match = searchmatches[i]
    slot.record = match and match.record or nil
    slot.button.Visible = match ~= nil
    if match then
      slot.heading.Text = match.record.title
      slot.category.Text = searchpath(match.record)
    end
  end
  rf.resources.searchscroll.CanvasPosition = Vector2.zero
  selectpage(currentpage)
end
searchinput:GetPropertyChangedSignal("Text"):Connect(searchrefresh)
searchclear.Activated:Connect(function()
  searchinput.Text = ""
  searchinput:CaptureFocus()
end)
searchinput.FocusLost:Connect(function(enterpressed)
  if enterpressed and #searchmatches > 0 then searchgo(searchmatches[1].record) end
end)
searchrefresh()
selectpage("main")
rf.showmenu(config.showmenu)
function rf.setactionbind(action, name)
  if not keybinddefaults[action] or type(name) ~= "string" then return false end
  if name ~= "Unbound" and not validkeycode(name) then return false end
  if name ~= "Unbound" then
    if config.guikeybind == name then
      local replacement
      for _, candidate in ipairs({"RightControl", "RightShift", "F8", "F7"}) do
        local unused = candidate ~= name
        for other, selected in pairs(config.keybinds) do
          if other ~= action and selected == candidate then unused = false break end
        end
        if unused then replacement = candidate break end
      end
      config.guikeybind = replacement or "RightControl"
      if type(writefile) == "function" then pcall(writefile, guikeyfile, config.guikeybind) end
    end
    for other, selected in pairs(config.keybinds) do
      if other ~= action and selected == name then config.keybinds[other] = "Unbound" end
    end
  end
  config.keybinds[action] = name
  state.bindingaction = nil
  if rf.refreshhotkeys then rf.refreshhotkeys() end
  if name ~= "Unbound" then state.hotkeysheld[name] = os.clock() end
  savepreferences()
  rf.updatehud()
  return true
end

function rf.setautoshoot(enabled)
  config.autoshoot = enabled == true
  state.autoshotclock = 0
  state.autoshotnext = 0
  state.autoshotlastpoll = nil
  state.autoshotmaxgap = 0
  state.autoshotstatus = nil
  state.autoshotstatusat = nil
  if not config.autoshoot then
    state.fullbagshot = nil
    state.autoshotpending = false
    state.autoshootfarretry = os.clock() + 0.65
    state.autoshootwarpuntil = 0
    if state.autoshoothover then rf.autoshootstophover(true) end
    if not state.manualshotbusy or state.manualshotsource == "fullbag" then
      state.mouseactiveuntil = 0
      state.autoshootpoint, state.autoshootpointuntil = nil, 0
      state.autoshoottrack = nil
    end
    rf.motionrelease("autoshoot", true)
    if state.manualshotbusy and state.manualshotsource == "fullbag" and state.manualshotcancel then
      state.manualshotcancel()
    end
  end
  savepreferences()
  rf.updatehud()
  return config.autoshoot
end

rf.resources.keybindstatus = {
  toggleautofarm = {"Auto Collect Coins", "flag", "autofarm"},
  toggleautoshoot = {"Auto Shoot", "config", "autoshoot"},
  togglepickup = {"Auto Gun Pickup", "flag", "autopickup"},
  togglecoinchams = {"Coin Chams", "flag", "coinchams"},
  togglerolechams = {"Role Chams", "flag", "chams"},
  toggleantifling = {"Anti Fling", "config", "antifling"},
  togglenoclip = {"Noclip", "config", "persistnoclip"},
  toggleautokill = {"Auto Kill All", "flag", "autokillall"}
}

function rf.runactionbind(action)
  if action == "shootmurderer" then
    if rf.shootmurdererkey then rf.shootmurdererkey() end
  elseif action == "toggleautofarm" then
    rf.toggleflag("autofarm")
  elseif action == "toggleautoshoot" then
    rf.setautoshoot(not config.autoshoot)
  elseif action == "togglepickup" then
    rf.toggleflag("autopickup")
  elseif action == "togglecoinchams" then
    rf.toggleflag("coinchams")
  elseif action == "togglerolechams" then
    rf.toggleflag("chams")
  elseif action == "toggleantifling" then
    config.antifling = not config.antifling
    savepreferences()
    rf.updatehud()
  elseif action == "togglenoclip" then
    rf.setglobalnoclip(not config.persistnoclip)
  elseif action == "toggleautokill" then
    rf.toggleflag("autokillall")
  end
  local notice = rf.resources.keybindstatus[action]
  if notice then
    local enabled = (notice[2] == "flag" and flags or config)[notice[3]] == true
    state.keybindnoticecount = (state.keybindnoticecount or 0) + 1
    local detail = enabled and "Enabled" or "Disabled"
    if action == "togglenoclip" and not enabled and state.noclip.autoenabled then
      detail = "Global off; Auto Collect noclip active"
    end
    rf.notification(notice[1], detail, nil,
      enabled and "check-circle-2" or "circle-off",
      enabled and Color3.fromRGB(77, 219, 145) or Color3.fromRGB(225, 138, 145),
      "vanta:toggle:" .. action .. ":" .. tostring(state.keybindnoticecount))
  end
end

function rf.toggleleaderboard()
  local playergui = localplayer:FindFirstChild("PlayerGui")
  local maingui = playergui and playergui:FindFirstChild("MainGUI")
  local gameui = maingui and maingui:FindFirstChild("Game")
  local leaderboard = gameui and gameui:FindFirstChild("Leaderboard")
  local container = leaderboard and leaderboard:FindFirstChild("Container")
  local close = container and container:FindFirstChild("Close")
  local toggle = close and close:FindFirstChild("Toggle")
  if not toggle or not toggle:IsA("GuiButton") then return false end
  local fire = type(firesignal) == "function" and firesignal
    or type(env.firesignal) == "function" and env.firesignal or nil
  if fire then
    local ok = pcall(fire, toggle.MouseButton1Click)
    if ok then return true end
  end
  local ok = pcall(function() toggle:Activate() end)
  return ok
end

rf.resources.hotkeyaction = "VantaHotkeys_" .. tostring(localplayer.UserId)
rf.resources.hotkeypriority = 5500

function rf.handlehotkey(input)
  if not state.alive or input.UserInputType ~= Enum.UserInputType.Keyboard
    or input.KeyCode == Enum.KeyCode.Unknown then return false end
  local keycode = input.KeyCode
  if state.fxpreview then
    if keycode == Enum.KeyCode.Escape then rf.closefxpreview() end
    return true
  end
  if state.bindingaction then
    local action = state.bindingaction
    if keycode == Enum.KeyCode.Escape then
      state.bindingaction = nil
      rf.updatehud()
    elseif keycode == Enum.KeyCode.Backspace or keycode == Enum.KeyCode.Delete then
      rf.setactionbind(action, "Unbound")
    else
      rf.setactionbind(action, keycode.Name)
    end
    return true
  end
  if state.bindinggui then
    if keycode == Enum.KeyCode.Escape then
      state.bindinggui = false
      rf.updatehud()
    elseif keycode == Enum.KeyCode.Backspace or keycode == Enum.KeyCode.Delete then
      rf.setguibind("RightControl")
    else
      rf.setguibind(keycode.Name)
    end
    return true
  end
  if keycode == Enum.KeyCode.Escape then
    if state.menuopen and searchinput and (searchinput:IsFocused() or searchinput.Text ~= "") then
      searchinput.Text = ""
      searchinput:ReleaseFocus()
    elseif state.menuopen then
      rf.showmenu(false)
    end
    return state.menuopen
  end
  if userinputservice:GetFocusedTextBox() or state.hopping then return false end
  if localplayer.Name:lower() == "4tgw" and (keycode == Enum.KeyCode.Equals or keycode == Enum.KeyCode.KeypadPlus)
    and (userinputservice:IsKeyDown(Enum.KeyCode.LeftControl) or userinputservice:IsKeyDown(Enum.KeyCode.RightControl)) then
    if state.hotkeysheld["mobiledev"] then return true end
    state.hotkeysheld.mobiledev = true
    rf.togglemobilelayout()
    return true
  end
  local keyname = keycode.Name
  local menukey = validkeycode(config.guikeybind)
  local action
  if menukey and keycode == menukey then
    action = "menu"
  else
    for _, entry in ipairs(keybindactions) do
      if config.keybinds[entry[1]] == keyname then
        action = entry[1]
        break
      end
    end
  end
  if not action and keycode == Enum.KeyCode.Tab then action = "leaderboard" end
  if not action and state.menuopen and keycode == Enum.KeyCode.Slash then action = "search" end
  if not action then return false end
  if state.hotkeysheld[keyname] then return true end
  state.hotkeysheld[keyname] = os.clock()
  if action == "menu" then
    rf.showmenu(not state.menuopen)
  elseif action == "leaderboard" then
    if not state.menuopen then rf.toggleleaderboard() end
  elseif action == "search" then
    searchinput:CaptureFocus()
  else
    rf.runactionbind(action)
  end
  return true
end

function rf.refreshhotkeys()
  pcall(contextactionservice.UnbindAction, contextactionservice, rf.resources.hotkeyaction)
  table.clear(state.hotkeysheld)
  local keys = {}
  local found = {}
  local function addkey(name)
    local code = validkeycode(name)
    if not code or found[code] then return end
    found[code] = true
    keys[#keys + 1] = code
  end
  addkey(config.guikeybind)
  for _, entry in ipairs(keybindactions) do addkey(config.keybinds[entry[1]]) end
  addkey("Tab")
  if localplayer.Name:lower() == "4tgw" then
    addkey("Equals")
    addkey("KeypadPlus")
  end
  if #keys == 0 then return end
  pcall(function()
    contextactionservice:BindActionAtPriority(rf.resources.hotkeyaction, function(_, inputstate, input)
      if inputstate == Enum.UserInputState.End or inputstate == Enum.UserInputState.Cancel then
        if input then state.hotkeysheld[input.KeyCode.Name] = nil end
        return Enum.ContextActionResult.Pass
      end
      if inputstate ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end
      if not state.alive or state.bindingaction or state.bindinggui
        or userinputservice:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
      return rf.handlehotkey(input) and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
    end, false, rf.resources.hotkeypriority, table.unpack(keys))
  end)
end

rf.refreshhotkeys()
table.insert(state.connections, userinputservice.InputBegan:Connect(function(input)
  rf.handlehotkey(input)
end))
table.insert(state.connections, userinputservice.InputEnded:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.Keyboard then
    state.hotkeysheld[input.KeyCode.Name] = nil
    if input.KeyCode == Enum.KeyCode.Equals or input.KeyCode == Enum.KeyCode.KeypadPlus
      or input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
      state.hotkeysheld.mobiledev = nil
    end
  end
end))

state.stop = function()
  if not state.alive or state.stopping then return end
  state.stopping = true
  rf.canceltasks()
  local function cleanup(name, callback, ...)
    if type(callback) == "function" then rf.safe("stop:" .. name, callback, ...) end
  end
  cleanup("save", savepreferences)
  cleanup("pickup", state.pickuprestore, true)
  cleanup("manualshot", state.manualshotcancel)
  for owner in pairs(state.noclip.owners) do state.noclip.owners[owner] = false end
  state.noclip.manualenabled, state.noclip.autoenabled = false, false
  state.noclip.suppressed = true
  cleanup("hotkeys", contextactionservice.UnbindAction, contextactionservice, rf.resources.hotkeyaction)
  table.clear(state.hotkeysheld)
  if state.fxpreview then cleanup("preview", rf.closefxpreview) end
  cleanup("vote", rf.votehalt, "Stopped", false)
  cleanup("fade", rf.votefadestop, true)
  cleanup("fling", rf.flingstop, "off", true)
  cleanup("menu", rf.showmenu, false)
  cleanup("mouse", rf.restoremouse)
  cleanup("guis", rf.restoreotherguis)
  cleanup("farmreturn", rf.farmcancelreturn)
  cleanup("farmvisibility", rf.farmshowafterfull, true)
  farm.full = false
  cleanup("farm", rf.farmstop, true)
  cleanup("hover", rf.autoshootstophover, true)
  cleanup("shotlease", rf.motionrelease, "autoshoot", true)
  motionqueue.queuedcollect = false
  cleanup("movementreturn", rf.motionclearreturn)
  cleanup("kill", rf.autokillstop, "off", true)
  motionqueue.owner = nil
  cleanup("hitboxes", rf.restorerolehitboxes)
  cleanup("noclip", rf.stopnoclip)
  cleanup("collisions", rf.restorecollisions)
  cleanup("graphics", rf.stopvisualplus)
  for humanoid, original in pairs(state.walkspeedoriginals) do
    if humanoid.Parent then pcall(function() humanoid.WalkSpeed = original end) end
  end
  if initialhumanoid and initialhumanoid.Parent and initialwalkspeed then
    pcall(function() initialhumanoid.WalkSpeed = initialwalkspeed end)
  end
  state.alive = false
  if mousehook.resolve == rf.spoofmouse then mousehook.resolve = nil end
  if state.weaponservice then
    cleanup("weaponmouse", function()
      if state.weaponservice.GetMouseTargetCFrame == state.wrappedmouse then
        state.weaponservice.GetMouseTargetCFrame = state.originalmouse
      end
    end)
    cleanup("weaponposition", function()
      if state.weaponservice.GetTargetPosition == state.wrappedposition then
        state.weaponservice.GetTargetPosition = state.originalposition
      end
    end)
  end
  for _, connection in ipairs(state.connections) do disconnect(connection) end
  table.clear(state.connections)
  disconnect(camerawatch)
  camerawatch = nil
  for _, connection in pairs(state.gunactivationconnections) do disconnect(connection) end
  table.clear(state.gunactivationconnections)
  for _, entry in ipairs(state.feed) do destroy(entry.frame) end
  table.clear(state.feed)
  cleanup("pickupfinal", state.pickuprestore)
  cleanup("collisionsfinal", rf.restorecollisions)
  cleanup("visuals", rf.clearvisuals)
  destroy(rf.resources.drawingoverlay)
  rf.resources.drawingoverlay = nil
  cleanup("coins", rf.clearcoinchams)
  destroy(rf.resources.coinfolder)
  for id in pairs(state.tracking) do cleanup("tracking", rf.removetracking, id) end
  destroy(rf.resources.trackingfolder)
  destroy(rf.resources.r6template)
  cleanup("marker", rf.cleargunmarker)
  for _, group in pairs(state.characterconnections) do
    for _, connection in ipairs(group) do disconnect(connection) end
  end
  table.clear(state.characterconnections)
  for _, group in pairs(rf.resources.playerconnections or {}) do
    for _, connection in ipairs(group) do disconnect(connection) end
  end
  if rf.resources.playerconnections then table.clear(rf.resources.playerconnections) end
  if rf.resources.blurtween then rf.resources.blurtween:Cancel() end
  if rf.resources.marquees then table.clear(rf.resources.marquees) end
  destroy(rf.resources.fxroot)
  destroy(overlay)
  destroy(gui)
  destroy(blur)
  if api.runtime == state then api.runtime = nil end
end
api.stop = state.stop

rf.install()
rf.installmouse()
if state.weaponservice and state.weaponservice.KnifeThrown
  and state.weaponservice.KnifeThrown:IsA("BindableEvent") then
  table.insert(state.connections, state.weaponservice.KnifeThrown.Event:Connect(function()
    state.mouseactiveuntil = math.max(state.mouseactiveuntil, os.clock() + 0.45)
    state.mousecache.time = -math.huge
  end))
end
rf.resources.pickupscanqueued = false
function rf.queuepickupscan()
  if not state.alive then return end
  state.dropdirty = true
end
rf.resources.worldadded = function(instance)
  if not state.alive then return end
  rf.adddropcandidate(instance)
  if state.dropdirty then rf.queuepickupscan() end
  if instance:IsA("Model") and instance.Name == "Raggy" then
    rf.defer(function()
      if not state.alive or not instance:IsDescendantOf(world) then return end
      rf.adddropcandidate(instance)
      if state.dropdirty then rf.queuepickupscan() end
    end)
  end
  if rf.isgunraycastmarker(instance) then
    rf.defer(function()
      if not state.alive or not instance:IsDescendantOf(world) then return end
      rf.adddropcandidate(instance)
      if state.dropdirty then rf.queuepickupscan() end
    end)
    rf.delay(0.12, function()
      if not state.alive or not instance:IsDescendantOf(world) then return end
      rf.adddropcandidate(instance)
      if state.dropdirty then rf.queuepickupscan() end
    end)
  elseif instance:IsA("BasePart") and instance.Name == "HumanoidRootPart" then
    local model = instance.Parent
    if model and model:IsA("Model") then
      if model.Name == "Raggy" then rf.adddropcandidate(instance) end
      for _, object in ipairs(model:GetDescendants()) do
        if rf.isgunraycastmarker(object) then rf.adddropcandidate(object) end
      end
      if state.dropdirty then rf.queuepickupscan() end
    end
  end
end
rf.resources.coinadded = function(object)
  state.coinhidden[object] = nil
  rf.coincandidate(object)
  if (object:IsA("Model") or object:IsA("BasePart")) and object.Name:lower() == "coinvisual" then
    rf.defer(function()
      if state.alive and object:IsDescendantOf(world) then rf.coincandidate(object) end
    end)
  end
end
table.insert(state.connections, world.DescendantRemoving:Connect(function(part)
  state.coinhidden[part] = nil
  state.coinorigins[part] = nil
  state.coincandidates[part] = nil
  if state.coinvisuals[part] then rf.resources.removecoinvisual(part) end
end))
rf.spawn(rf.refreshcoinchams)
table.insert(state.connections, world.DescendantRemoving:Connect(function(instance)
  local function affected(target)
    return target and (target == instance or instance:IsAncestorOf(target))
  end
  local job = state.pickupjob
  if job and (affected(job.source) or affected(job.part) or affected(job.proof)) then
    job.restore(true)
    state.pickupstatus = "Gun model disappeared"
  end
  if state.dropcandidates[instance] or affected(state.dropinstance)
    or affected(state.droppart) or affected(state.dropproof) then
    state.dropdirty = true
    state.nextdropscan = 0
  end
  state.dropcandidates[instance] = nil
  state.dropmarkers[instance] = nil
  if affected(state.dropinstance) or affected(state.droppart) or affected(state.dropproof) then
    state.dropposition, state.dropinstance, state.droppart, state.dropattachment, state.dropproof = nil, nil, nil, nil, nil
    state.pickupdropkey, state.pickupdropreadyat = nil, 0
    state.pickupretrytarget, state.pickupretryat, state.pickupfailures = nil, 0, 0
  end
end))

rf.spawn(function()
  for i, object in ipairs(world:GetDescendants()) do
    if not state.alive then return end
    rf.adddropcandidate(object)
    if i % 1400 == 0 then task.wait() end
  end
  state.nextdropscan = 0
  state.dropdirty = true
  rf.queuepickupscan()
end)
function rf.autoshootstatus(reason)
  if state.autoshotstatus ~= reason then
    state.autoshotstatus = reason
    state.autoshotstatusat = os.clock()
  end
end

function rf.autoshootdiagnostics()
  local now = os.clock()
  local tool = rf.findautoshootgun()
  return {status = state.autoshotstatus or "Waiting for update", statusseconds = now - (state.autoshotstatusat or now),
    lastpollago = state.autoshotlastpoll and now - state.autoshotlastpoll or nil,
    maxpollgap = state.autoshotmaxgap or 0,
    lastrequest = state.autoshotrequestat, lastactivation = tool and state.nativeactivated[tool] or nil,
    toolenabled = tool ~= nil and tool.Enabled == true, equipped = tool ~= nil and tool.Parent == localplayer.Character,
    owner = motionqueue.owner, roundready = rf.localisinround(), fullbagrequired = config.autoshootwhenfull == true}
end
api.functions.autoshootdiagnostics = rf.autoshootdiagnostics

function rf.watchweaponactivation(tool)
  local previous = state.gunactivationconnections[tool]
  if previous and previous.Connected then return end
  if previous then previous:Disconnect() end
  state.gunactivationconnections[tool] = tool.Activated:Connect(function()
    state.nativeactivated[tool] = os.clock()
    state.mouseactiveuntil = os.clock() + 0.45
  end)
end

function rf.refreshgunready(tool, humanoid)
  if not tool or not humanoid or not humanoid.Parent then return false end
  local character = localplayer.Character
  if tool.Parent ~= character then return false end
  if tool.Enabled then return true end
  local now = os.clock()
  if now - (state.gunrefreshes[tool] or -math.huge) < 3 then return false end
  if now - (state.nativeactivated[tool] or -math.huge) < 2 then return false end
  state.gunrefreshes[tool] = now
  rf.defer(function()
    if not state.alive or localplayer.Character ~= character or tool.Parent ~= character
      or not humanoid.Parent or humanoid.Health <= 0 or tool.Enabled then return end
    pcall(function() humanoid:UnequipTools() end)
    rf.defer(function()
      local backpack = localplayer:FindFirstChildOfClass("Backpack")
      if state.alive and localplayer.Character == character and humanoid.Parent
        and humanoid.Health > 0 and tool.Parent == backpack then
        pcall(function() humanoid:EquipTool(tool) end)
        rf.watchweaponactivation(tool)
      end
    end)
  end)
  return false
end

function rf.restorerolehitbox(character)
  local record = state.rolehitboxrecords[character]
  if not record then return end
  local root = record.root
  if root and root.Parent then
    pcall(function()
      root.Size = record.size
      root.Massless = record.massless
      root.CanQuery = record.canquery
      root.CanCollide = record.cancollide
    end)
  end
  state.rolehitboxrecords[character] = nil
end

function rf.restorerolehitboxes()
  for character in pairs(state.rolehitboxrecords) do
    rf.restorerolehitbox(character)
  end
end

function rf.updaterolehitboxes(dt)
  if next(state.rolehitboxrecords) then
    rf.restorerolehitboxes()
  end
end

function rf.hitboxaimpoint(root, camera, cursor, padding)
  if not root or not root.Parent or not camera then return nil end
  local ray = camera:ViewportPointToRay(cursor.X, cursor.Y)
  local origin = root.CFrame:PointToObjectSpace(ray.Origin)
  local direction = root.CFrame:VectorToObjectSpace(ray.Direction)
  local size = root.Size + Vector3.new(1, 1, 1) * (2 * math.max(0, tonumber(padding) or 0))
  local half = size * 0.5
  local near, far = 0, 10000
  for _, axis in ipairs({"X", "Y", "Z"}) do
    local d = direction[axis]
    local o = origin[axis]
    local radius = half[axis]
    if math.abs(d) < 0.000001 then
      if o < -radius or o > radius then return nil end
    else
      local a = (-radius - o) / d
      local b = (radius - o) / d
      if a > b then a, b = b, a end
      near = math.max(near, a)
      far = math.min(far, b)
      if far < near then return nil end
    end
  end
  if far <= 0 then return nil end
  return root.CFrame:PointToWorldSpace(origin + direction * math.max(0, near))
end

function rf.findautoshootgun()
  local character = localplayer.Character
  if not character then return nil end
  local backpack = localplayer:FindFirstChildOfClass("Backpack")
  for _, container in ipairs({character, backpack}) do
    if container then
      for _, tool in ipairs(container:GetChildren()) do
        if tool:IsA("Tool") and (rf.isgunname(tool.Name) or tool:FindFirstChild("Muzzle", true)) then
          return tool
        end
      end
    end
  end
  return nil
end

function rf.autoshootcenter(character)
  if not character then return nil end
  for _, name in ipairs(rf.resources.closegunparts) do
    local part = character:FindFirstChild(name)
    if part and part:IsA("BasePart") then return part.Position, part end
  end
  return nil
end

function rf.autoshootcandidates(character)
  if not character then return {} end
  local available = {}
  for _, name in ipairs(rf.selectedhitparts(rf.resources.autoshootdefaultparts, character)) do
    local part = character:FindFirstChild(name)
    if part and part:IsA("BasePart") and part.Transparency < 1 then
      available[#available + 1] = part
    end
  end
  return available
end

function rf.autoshootbase(character, part, origin)
  if not part or not part:IsA("BasePart") then return nil end
  return part.Position
end

function rf.findvisiblemurderer(tool)
  local camera = world.CurrentCamera
  local character = localplayer.Character
  if not camera or not character then return nil end
  local humanoid = character:FindFirstChildOfClass("Humanoid")
  if not humanoid or humanoid.Health <= 0 then return nil end
  local origin = camera.CFrame.Position
  local muzzle = origin
  if tool and tool.Parent == character then
    local handle = tool:FindFirstChild("Handle", true)
    if handle and handle:IsA("BasePart") then muzzle = handle.Position end
  end
  local maximum = tonumber(config.maxdistance) or 300
  local radius = tonumber(config.screenradius) or math.huge
  local mouse = userinputservice:GetMouseLocation()
  local lock = localplayer:FindFirstChild("PlayerScripts")
  lock = lock and lock:FindFirstChild("MouseLock")
  local center = lock and lock:GetAttribute("Enabled") == true
    and userinputservice.PreferredInput ~= Enum.PreferredInput.Gamepad and camera.ViewportSize * 0.5 or mouse
  local best, bestpoint, bestpart, bestdistance
  for _, candidate in ipairs(players:GetPlayers()) do
    if candidate ~= localplayer and rf.autoshootfarvalid(candidate) then
      local model = candidate.Character
      local root = model:FindFirstChild("HumanoidRootPart")
      local distance = (root.Position - muzzle).Magnitude
      if distance <= maximum then
        for _, part in ipairs(rf.autoshootcandidates(model)) do
          local base = rf.autoshootbase(model, part, muzzle)
          local projected, on = camera:WorldToViewportPoint(base)
          if on and projected.Z > 0 and (Vector2.new(projected.X, projected.Y)
            - Vector2.new(center.X, center.Y)).Magnitude <= radius
            and visible(model, base, origin) and visible(model, base, muzzle) then
            local predicted = rf.autoshootforecast(candidate, part, muzzle)
            if predicted and visible(model, predicted, muzzle) then
              if not bestdistance or distance < bestdistance then
                best, bestpoint, bestpart, bestdistance = candidate, predicted, part, distance
              end
              break
            end
          end
        end
      end
    end
  end
  return best, bestpoint, bestpart
end

function rf.autoshootsight(tool)
  return rf.findvisiblemurderer(tool) ~= nil
end

function rf.autoshootequip(tool, character)
  if not state.alive or state.stopping or not config.autoshoot or not config.autoequipgun
    or not tool or not character or character ~= localplayer.Character then return false end
  local backpack = localplayer:FindFirstChildOfClass("Backpack")
  if not backpack or tool.Parent ~= backpack then return tool.Parent == character end
  local humanoid = character:FindFirstChildOfClass("Humanoid")
  if not humanoid or humanoid.Health <= 0 then return false end
  local now = os.clock()
  if now - state.autoequiplast < 0.12 then return false end
  if not rf.autoshootsight(tool) then return false end
  state.autoequiplast = now
  local ok = pcall(function() humanoid:EquipTool(tool) end)
  rf.autoshootstatus(ok and tool.Parent == character and "Gun equipped" or ok and "Waiting for gun equip" or "Gun equip rejected")
  if ok and tool.Parent == character then
    rf.watchweaponactivation(tool)
    return true
  end
  return false
end

function rf.autoshootfire(tool, character)
  if not config.autoshootactivate or not tool or tool.Parent ~= character or not tool.Enabled then
    rf.autoshootstatus("Tool activation disabled or unavailable")
    return false
  end
  rf.watchweaponactivation(tool)
  local previous = state.nativeactivated[tool] or -math.huge
  local firedround = state.roundstartedat
  state.autoshotrequestat = os.clock()
  local success = pcall(function() tool:Activate() end)
  if success and config.firefallback then
    rf.delay(0.08, function()
      if not state.alive or not config.autoshoot or not config.autoshootactivate
        or state.roundstartedat ~= firedround or character ~= localplayer.Character
        or (config.autoshootwhenfull and not rf.fullbagshootallowed())
        or not config.firefallback or tool.Parent ~= character or not tool.Enabled then return end
      if (state.nativeactivated[tool] or -math.huge) > previous then return end
      local fire = type(firesignal) == "function" and firesignal
        or type(env.firesignal) == "function" and env.firesignal or nil
      if fire then pcall(fire, tool.Activated) end
    end)
  end
  rf.autoshootstatus(success and "Tool activation requested; server outcome unverified"
    or "Tool activation failed")
  return success
end

function rf.autoshootfarvalid(candidate)
  if not candidate or candidate == localplayer or not candidate:IsA("Player") then return false end
  if state.synced and state.participants[candidate.UserId] ~= true then return false end
  local record = state.authoritative[candidate.UserId] or rf.getrecord(candidate)
  if not record or rf.normalize_role(record.Role) ~= "Murderer"
    or record.Dead == true or record.Killed == true then return false end
  local character = candidate.Character
  local root = character and character:FindFirstChild("HumanoidRootPart")
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  return root ~= nil and humanoid ~= nil and humanoid.Health > 0
end

function rf.autoshootfarpoint(candidate, origin)
  local character = candidate and candidate.Character
  if not character then return nil end
  for _, part in ipairs(rf.autoshootcandidates(character)) do
    local point = rf.autoshootbase(character, part, origin)
    if point and (not origin or visible(character, point, origin)) then
      return point, part
    end
  end
  return nil
end

function rf.findfarautoshoottarget(root)
  if not config.autoshoot or not config.autoshootfar or not root or not root.Parent then return nil end
  local best, closest = nil, math.huge
  for _, candidate in ipairs(players:GetPlayers()) do
    if rf.autoshootfarvalid(candidate) then
      local enemyroot = candidate.Character:FindFirstChild("HumanoidRootPart")
      local distance = (enemyroot.Position - root.Position).Magnitude
      if distance > 500 and distance < closest then
        best, closest = candidate, distance
      end
    end
  end
  return best
end

function rf.autoshootstophover(restore)
  local hover = state.autoshoothover
  state.autoshoothover = nil
  if hover then
    local character, root, humanoid = hover.character, hover.root, hover.humanoid
    if root and root.Parent and character == localplayer.Character then
      local ownsstate = hover.character == character and hover.round == state.roundstartedat
      if restore ~= false and ownsstate and character.Parent and humanoid and humanoid.Parent
        and humanoid.Health > 0 and not rf.localisdead() and rf.localisinround()
        and not rf.voidlobbyspawn(root.Position) then
        local frame = hover.origin
        if typeof(frame) == "CFrame" then pcall(function() rf.teleportpivot(character, frame) end) end
      end
      pcall(function()
        root.Anchored = hover.anchored
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
      end)
      if humanoid and humanoid.Parent then pcall(function() humanoid.AutoRotate = hover.autorotate end) end
    end
    state.autoshootfarretry = os.clock() + 1.4
  end
  state.autoshootpoint, state.autoshootpointuntil = nil, 0
  state.autoshoottrack = nil
  state.aimoverride = nil
  rf.motionrelease("autoshoot", true)
end

function rf.autoshootforecast(candidate, part, origin)
  local enemy = candidate and candidate.Character
  if not enemy or not part or not part:IsDescendantOf(enemy) then return nil end
  local _, torso = rf.autoshootcenter(enemy)
  return torso == part and part.Position or nil
end

function rf.autoshootclearspace(position, enemy)
  local params = OverlapParams.new()
  params.FilterType = Enum.RaycastFilterType.Exclude
  params.FilterDescendantsInstances = {localplayer.Character, enemy}
  params.MaxParts = 45
  local parts = world:GetPartBoundsInBox(CFrame.new(position), Vector3.new(3, 4, 3), params)
  for _, part in ipairs(parts) do
    if part:IsA("BasePart") and part.CanCollide and part.Transparency < 0.98 then
      return false
    end
  end
  return true
end

function rf.autoshootprobe(candidate, position)
  local enemy = candidate and candidate.Character
  if not enemy or not rf.autoshootclearspace(position, enemy) then return nil end
  local muzzle = position + Vector3.new(0, 0.7, 0)
  for _, part in ipairs(rf.autoshootcandidates(enemy)) do
    local point = rf.autoshootforecast(candidate, part, muzzle)
    if point and visible(enemy, point, muzzle) then return point, part end
  end
  return nil
end

function rf.autoshoothoverframe(hover)
  local candidate = hover.target
  if not rf.autoshootfarvalid(candidate) then return nil end
  local enemy = candidate.Character
  local root = enemy:FindFirstChild("HumanoidRootPart")
  if not root then return nil end
  local forward = rf.horizontal(root.CFrame.LookVector)
  local right = rf.horizontal(root.CFrame.RightVector)
  forward = forward.Magnitude > 0.001 and forward.Unit or Vector3.new(0, 0, -1)
  right = right.Magnitude > 0.001 and right.Unit or Vector3.new(1, 0, 0)
  local offsets = {
    {-forward * 3.7 + right * 1.6, -0.05},
    {-forward * 3.7 - right * 1.6, -0.05},
    {right * 3.6, -0.05},
    {-right * 3.6, -0.05},
    {-forward * 15 + right * 5, 8},
    {-forward * 15 - right * 5, 8},
    {-forward * 15, 8},
    {-forward * 13 + right * 7, 6},
    {-forward * 13 - right * 7, 6},
    {forward * 2, 0},
    {forward * 4, 0},
    {forward * 7, 0},
    {forward * 12, 0},
    {forward * 20, 0},
    {forward * 20 + right * 5, 0},
    {forward * 20 - right * 5, 0},
    {forward * 12 + right * 7, 2},
    {forward * 12 - right * 7, 2},
    {right * 12, 1},
    {-right * 12, 1},
    {-forward * 20, 0},
    {-forward * 20 + right * 8, 3},
    {-forward * 20 - right * 8, 3},
    {forward * 6, 5},
    {forward * 15, 6}
  }
  if config.autoshootcover == false then
    for i = #offsets, 6, -1 do offsets[i] = nil end
  end
  local now = os.clock()
  local index = hover.spot or 1
  local entry = offsets[index]
  local position = entry and root.Position + entry[1] + Vector3.new(0, entry[2], 0)
  local aimpoint, aimpart
  if position then aimpoint, aimpart = rf.autoshootprobe(candidate, position) end
  if not aimpoint or now >= (hover.nextsidecheck or 0) then
    hover.nextsidecheck = now + (aimpoint and 0.18 or 0.075)
    if not aimpoint then
      index, position = nil, nil
      for i, offset in ipairs(offsets) do
        local proposed = root.Position + offset[1] + Vector3.new(0, offset[2], 0)
        local result, part = rf.autoshootprobe(candidate, proposed)
        if result then
          index, position, aimpoint, aimpart = i, proposed, result, part
          break
        end
      end
    end
  end
  if not position or not aimpoint then
    hover.aimpoint = nil
    hover.aimpart = nil
    hover.ready = false
    return nil
  end
  hover.spot = index
  hover.peek = config.autoshootcover ~= false and index > 5
  hover.aimpoint = aimpoint
  hover.aimpart = aimpart
  local facing = Vector3.new(aimpoint.X, position.Y, aimpoint.Z)
  if (facing - position).Magnitude < 0.01 then return nil end
  return CFrame.lookAt(position, facing)
end

function rf.autoshootconceal(hover)
  if not hover or state.autoshoothover ~= hover or not hover.peek then return end
  hover.hideuntil = os.clock() + 0.38
  hover.aimpoint = nil
  hover.aimpart = nil
  hover.ready = false
  hover.spot = nil
  hover.frame = nil
  hover.frameclock = nil
  hover.hidden = true
  if hover.character == localplayer.Character and hover.root.Parent then
    local origin = hover.origin
    if not rf.autoshootclearspace(origin.Position, hover.target.Character) then
      local base = origin.Position
      local options = {
        Vector3.new(3, 0, 0), Vector3.new(-3, 0, 0),
        Vector3.new(0, 0, 3), Vector3.new(0, 0, -3),
        Vector3.new(6, 0, 0), Vector3.new(-6, 0, 0),
        Vector3.new(0, 0, 6), Vector3.new(0, 0, -6)
      }
      for _, offset in ipairs(options) do
        if rf.autoshootclearspace(base + offset, hover.target.Character) then
          origin = CFrame.new(base + offset) * origin.Rotation
          break
        end
      end
    end
    pcall(function() rf.teleportpivot(hover.character, origin) end)
    hover.root.AssemblyLinearVelocity = Vector3.zero
    hover.root.AssemblyAngularVelocity = Vector3.zero
  end
end

function rf.autoshootfootframe(hover)
  local candidate = hover.target
  if not rf.autoshootfarvalid(candidate) then return nil end
  local enemy = candidate.Character
  local enemyroot = enemy and enemy:FindFirstChild("HumanoidRootPart")
  local enemyhumanoid = enemy and enemy:FindFirstChildOfClass("Humanoid")
  if not enemyroot or not enemyhumanoid or enemyhumanoid.Health <= 0 then return nil end
  local aimpart
  for _, name in ipairs({"LeftFoot", "RightFoot", "Left Leg", "Right Leg", "LeftLowerLeg", "RightLowerLeg", "LeftUpperLeg", "RightUpperLeg"}) do
    local part = enemy:FindFirstChild(name)
    if part and part:IsA("BasePart") then aimpart = part break end
  end
  if not aimpart then return nil end
  local bottom = enemyroot.Position.Y - enemyhumanoid.HipHeight - enemyroot.Size.Y * 0.5
  local footbottom = aimpart.Position.Y - aimpart.Size.Y * 0.5
  local height = math.min(bottom, footbottom) - hover.root.Size.Y * 0.5 - 0.22
  local position = Vector3.new(enemyroot.Position.X, height, enemyroot.Position.Z)
  local rayparams = RaycastParams.new()
  rayparams.FilterType = Enum.RaycastFilterType.Exclude
  rayparams.FilterDescendantsInstances = {enemy, hover.character}
  local below = world:Raycast(enemyroot.Position + Vector3.new(0, 1, 0),
    Vector3.new(0, -math.max(18, enemyhumanoid.HipHeight + 16), 0), rayparams)
  if below and below.Instance and below.Instance.CanCollide then
    local minimum = below.Position.Y + hover.root.Size.Y * 0.5 + 0.05
    if position.Y < minimum then
      local forward = rf.horizontal(enemyroot.CFrame.LookVector)
      if forward.Magnitude < 0.01 then forward = Vector3.new(0, 0, -1) end
      position = Vector3.new(position.X, minimum, position.Z) - forward.Unit * 1.1
    end
  end
  if not rf.autoshootclearspace(position, enemy) then
    hover.ready = false
    hover.aimpart = nil
    hover.aimpoint = nil
    return nil
  end
  if position.Y <= world.FallenPartsDestroyHeight + 14 then
    hover.ready = false
    hover.aimpart = nil
    hover.aimpoint = nil
    return nil
  end
  local forward = rf.horizontal(enemyroot.CFrame.LookVector)
  if forward.Magnitude < 0.01 then forward = Vector3.new(0, 0, -1) end
  hover.aimpart = aimpart
  hover.aimpoint = rf.autoshootforecast(candidate, aimpart, position) or aimpart.Position
  return CFrame.lookAt(position, position + forward.Unit * 0.2 + Vector3.new(0, 1, 0))
end

function rf.autoshoothoverstep(dt)
  local hover = state.autoshoothover
  if not hover then return end
  local owner = rf.motionowner()
  if owner and owner ~= "autoshoot" and motionpriorities[owner] > motionpriorities.autoshoot then
    rf.autoshootstophover(true)
    return
  end
  if not state.alive or not config.autoshoot
    or (config.autoshootwhenfull and not rf.fullbagshootallowed())
    or (hover.mode == "behind" and not config.autoshootbehind)
    or (hover.mode ~= "behind" and not config.autoshootfar)
    or state.endlock or not rf.localisinround() or rf.localisdead() or rf.localismurderer()
    or farm.hide or not rf.findautoshootgun() or not hover.root.Parent or hover.character ~= localplayer.Character
    or not rf.autoshootfarvalid(hover.target) then
    rf.autoshootstophover(true)
    return
  end
  local now = os.clock()
  if now - hover.started > 1.05 then
    rf.autoshootstophover(true)
    return
  end
  if not rf.motionacquire("autoshoot", 0.65) then return end
  if hover.hideuntil and now < hover.hideuntil then
    hover.ready = false
    hover.aimpoint = nil
    return
  end
  if hover.hideuntil then
    hover.hideuntil = nil
    hover.hidden = nil
    hover.spot = nil
  end
  local frame = rf.autoshootfootframe(hover)
  if not frame then
    hover.ready = false
    hover.aimpoint = nil
    hover.blockedat = hover.blockedat or now
    if not hover.hidden then
      hover.hidden = true
      pcall(function() rf.teleportpivot(hover.character, hover.origin) end)
      hover.frame = nil
      hover.root.AssemblyLinearVelocity = Vector3.zero
      hover.root.AssemblyAngularVelocity = Vector3.zero
    end
    if now - hover.blockedat > 0.6 then rf.autoshootstophover(true) end
    return
  end
  hover.hidden = false
  hover.blockedat = nil
  local old = hover.frame
  if old then
    local elapsed = math.clamp(tonumber(dt) or now - (hover.frameclock or now), 0, 0.05)
    local distance = (frame.Position - old.Position).Magnitude
    if distance < 12 then frame = old:Lerp(frame, 1 - math.exp(-48 * elapsed)) end
  end
  hover.frame, hover.frameclock = frame, now
  hover.root.Anchored = true
  hover.humanoid.AutoRotate = false
  pcall(function()
    rf.teleportpivot(hover.character, frame * hover.offset)
    hover.root.AssemblyLinearVelocity = Vector3.zero
    hover.root.AssemblyAngularVelocity = Vector3.zero
  end)
  local tool = rf.findautoshootgun()
  local muzzle = hover.root.Position + Vector3.new(0, 0.7, 0)
  if tool and tool.Parent == hover.character then
    local handle = tool:FindFirstChild("Handle", true)
    if handle and handle:IsA("BasePart") then muzzle = handle.Position end
  end
  hover.ready = hover.aimpart ~= nil and hover.aimpart.Parent ~= nil
    and hover.aimpoint ~= nil and visible(hover.target.Character, hover.aimpoint, muzzle)
  if not hover.ready then
    hover.blockedat = hover.blockedat or now
    if now - hover.blockedat > 0.45 then rf.autoshootstophover(true) end
  else
    hover.blockedat = nil
  end
end

function rf.autoshootstarthover(candidate)
  if not config.autoshoot or not config.autoshootfar or state.autoshoothover
    or not rf.autoshootfarvalid(candidate)
    or not config.autoshootfar or farm.hide or rf.localisdead() then return false end
  local character = localplayer.Character
  local root = character and character:FindFirstChild("HumanoidRootPart")
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  local enemyroot = candidate.Character and candidate.Character:FindFirstChild("HumanoidRootPart")
  if not root or not humanoid or humanoid.Health <= 0 or not enemyroot
    or (enemyroot.Position - root.Position).Magnitude <= 500 then return false end
  if not rf.motionacquire("autoshoot", 0.75) then return false end
  local origin = character:GetPivot()
  local hover = {target = candidate, character = character, root = root, humanoid = humanoid,
    origin = origin, offset = root.CFrame:ToObjectSpace(origin), anchored = root.Anchored,
    autorotate = humanoid.AutoRotate, started = os.clock(), side = 1, nextsidecheck = 0,
    mode = "far", round = state.roundstartedat}
  state.autoshoothover = hover
  rf.autoshoothoverstep()
  if state.autoshoothover ~= hover then return false end
  state.autoshootlastwarp = os.clock()
  state.autoshootwarpuntil = state.autoshootlastwarp + 0.35
  return true
end

function rf.autoshootbehind(candidate)
  if not state.alive or not config.autoshoot or not config.autoshootbehind
    or state.manualshotbusy or state.endlock or rf.localisdead() then return nil end
  local character = localplayer.Character
  local root = character and character:FindFirstChild("HumanoidRootPart")
  local enemy = candidate and candidate.Character
  local enemyroot = enemy and enemy:FindFirstChild("HumanoidRootPart")
  local enemyhumanoid = enemy and enemy:FindFirstChildOfClass("Humanoid")
  if not root or not enemyroot or not enemyhumanoid or enemyhumanoid.Health <= 0 then return nil end

  local humanoid = character:FindFirstChildOfClass("Humanoid")
  if not humanoid or humanoid.Health <= 0 then return nil end
  if not rf.motionacquire("autoshoot", 0.75) then return nil end
  local hover = {target = candidate, character = character, root = root, humanoid = humanoid,
    origin = character:GetPivot(), offset = root.CFrame:ToObjectSpace(character:GetPivot()),
    anchored = root.Anchored, autorotate = humanoid.AutoRotate, started = os.clock(),
    side = 1, nextsidecheck = 0, mode = "behind", round = state.roundstartedat}
  state.autoshoothover = hover
  rf.autoshoothoverstep()
  if state.autoshoothover ~= hover then return nil end
  state.antifling.safe = nil
  state.autoshootlastwarp = os.clock()
  state.autoshootwarpuntil = state.autoshootlastwarp + 0.35
  return hover.ready and hover.aimpoint or nil
end

function rf.findcoverautoshoottarget(root)
  if not root or not config.autoshoot or not config.autoshootbehind then return nil end
  local best, closest = nil, math.huge
  for _, candidate in ipairs(players:GetPlayers()) do
    if rf.autoshootfarvalid(candidate) then
      local enemyroot = candidate.Character:FindFirstChild("HumanoidRootPart")
      local distance = (root.Position - enemyroot.Position).Magnitude
      if distance <= 500 and distance < closest then
        best, closest = candidate, distance
      end
    end
  end
  return best
end

function rf.fullbagmurdererdead(record)
  if not record or not record.targetid then return false end
  local data = state.authoritative[record.targetid]
  if type(data) == "table" and rf.normalize_role(data.Role) == "Murderer"
    and (data.Dead == true or data.Killed == true) then return true end
  local candidate = players:GetPlayerByUserId(record.targetid)
  local entry = candidate and rf.getrecord(candidate)
  if type(entry) == "table" and rf.normalize_role(entry.Role) == "Murderer"
    and (entry.Dead == true or entry.Killed == true) then return true end
  local humanoid = record.targethumanoid
  if humanoid and humanoid.Health <= 0 then return true end
  if candidate and candidate.Character == record.targetcharacter then
    humanoid = candidate.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then return true end
  end
  return false
end

function rf.fullbagshootallowed()
  if not state.alive or not config.autoshoot
    or not config.autoshootwhenfull or not state.round or state.endlock
    or not state.roundstartobserved or not state.roundstartparticipant
    or not rf.localisinround() or rf.localisdead() then return false end
  local round = state.roundstartedat
  if type(round) ~= "number" or round <= 0 then return false end
  local bag = state.bagstate
  if bag.round == round and bag.full then return true end
  if rf.autokillbagfull() then return true end
  if type(bag.count) == "number" and type(bag.capacity) == "number"
    and bag.count < bag.capacity and os.clock() - bag.updated < 1.5 then return false end
  if rf.farmhudfull() then return rf.bagobserve(nil, nil, "hud", true) end
  return false
end

function rf.autoshoot(dt)
  if not config.autoshoot or not state.alive then
    rf.autoshootstatus("Auto Shoot disabled")
    state.autoshotnext = 0
    state.autoshotlastpoll = nil
    state.fullbagshot = nil
    if not state.manualshotbusy or state.manualshotsource == "fullbag" then
      state.autoshootpoint, state.autoshootpointuntil = nil, 0
      state.autoshoottrack = nil
      state.mouseactiveuntil = 0
    end
    if state.autoshoothover then rf.autoshootstophover(true) end
    if motionqueue.owner == "autoshoot" then rf.motionrelease("autoshoot", true) end
    return
  end
  local pollnow = os.clock()
  if pollnow < (state.autoshotnext or 0) then return end
  state.autoshotnext = pollnow + math.clamp(tonumber(config.autoshootcheckinterval) or 0.016, 0.008, 1)
  if state.autoshotlastpoll then
    state.autoshotmaxgap = math.max(state.autoshotmaxgap or 0, pollnow - state.autoshotlastpoll)
  end
  state.autoshotlastpoll = pollnow
  if config.autoshootwhenfull then
    if not rf.fullbagshootallowed() or state.endlock or not rf.localisinround()
      or rf.localisdead() or rf.localismurderer() or rf.victoryisshown() then
      rf.autoshootstatus("Waiting for full bag or valid round")
      state.fullbagshot = nil
      if state.autoshoothover then rf.autoshootstophover(true) end
      return
    end
    local record = state.fullbagshot
    if not record or record.character ~= localplayer.Character
      or record.roundstartedat ~= state.roundstartedat then
      record = {character = localplayer.Character, roundstartedat = state.roundstartedat,
        shots = 0, completed = false, nexttry = 0}
      state.fullbagshot = record
    end
    if record.completed then rf.autoshootstatus("Full-bag action completed") return end
    if rf.fullbagmurdererdead(record) then
      record.completed = true
      return
    end
    if os.clock() < record.nexttry then rf.autoshootstatus("Full-bag retry cooldown") return end
  else
    state.fullbagshot = nil
  end
  if state.autofling and state.autofling.active then rf.autoshootstatus("Waiting for active movement") return end
  if state.pickupbusy then rf.autoshootstatus("Waiting for gun pickup") return end
  local owner = rf.motionowner()
  if owner and owner ~= "autoshoot" and motionpriorities[owner] > motionpriorities.autoshoot then rf.autoshootstatus("Waiting for movement: " .. owner) return end
  if not config.autoshoot or not state.alive then return end
  if farm.hide or state.pickupbusy then rf.autoshootstatus("Waiting for character recovery or pickup") return end
  if not rf.localisinround() or rf.localisdead() or rf.victoryisshown() or rf.localismurderer() then
    rf.autoshootstatus("Waiting for valid round and role") return
  end
  if not config.autoshootactivate then rf.autoshootstatus("Tool activation disabled") return end
  if userinputservice:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then rf.autoshootstatus("Manual input held") return end
  local tool = rf.findautoshootgun()
  if not tool then
    rf.autoshootstatus("No gun in character or backpack")
    return
  end
  local character = localplayer.Character
  if not character then rf.autoshootstatus("Waiting for character") return end
  if tool.Parent ~= character then
    rf.autoshootstatus(config.autoequipgun and "Waiting to equip gun on sight" or "Auto equip disabled")
    rf.autoshootequip(tool, character)
    return
  end
  if not tool.Enabled then
    rf.autoshootstatus("Waiting for native weapon cooldown")
    return
  end
  local target, initialpoint, aimpart
  local hover = state.autoshoothover
  if hover then
    if rf.autoshootfarvalid(hover.target) then
      if hover.hideuntil and os.clock() < hover.hideuntil then rf.autoshootstatus("Waiting for movement to settle") return end
      target, initialpoint, aimpart = hover.target, hover.ready and hover.aimpoint or nil, hover.aimpart
      if not initialpoint then rf.autoshootstatus("Waiting for movement readiness") return end
    else
      rf.autoshootstophover(true)
    end
  end
  if not target then
    target, initialpoint, aimpart = rf.findvisiblemurderer(tool)
  end
  if not target and config.autoshootbehind and not state.autoshoothover
    and os.clock() >= state.autoshootfarretry then
    local character = localplayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local close = rf.findcoverautoshoottarget(root)
    if close then
      target = close
      initialpoint = rf.autoshootbehind(close)
      if typeof(initialpoint) ~= "Vector3" then return end
    end
  end
  if not target and config.autoshootfar and os.clock() >= state.autoshootfarretry then
    local character = localplayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local distant = rf.findfarautoshoottarget(root)
    if distant and rf.autoshootstarthover(distant) then
      local activehover = state.autoshoothover
      target, initialpoint = distant, activehover and activehover.ready and activehover.aimpoint or nil
    end
  end
  if not target or typeof(initialpoint) ~= "Vector3" then
    rf.autoshootstatus("No murderer in firing line")
    return
  end
  local now = os.clock()
  local interval = math.max(0.12, tonumber(config.autoshootinterval) or 0.16)
  if now - state.autoshotlast < interval or now - (state.nativeactivated[tool] or -math.huge) < interval then rf.autoshootstatus("Configured shot interval") return end
  local character = localplayer.Character
  if tool.Parent ~= character then
    rf.autoshootequip(tool, character)
    return
  end
  if not tool.Enabled then rf.autoshootstatus("Waiting for native weapon cooldown") return end
  local point = initialpoint
  local activehover = state.autoshoothover
  if activehover then
    if not activehover.ready or not activehover.aimpoint then rf.autoshootstatus("Waiting for movement readiness") return end
    point, aimpart = activehover.aimpoint, activehover.aimpart
  end
  if not state.alive or state.manualshotbusy or not config.autoshoot
    or not config.autoshootactivate
    or (config.autoshootwhenfull and not rf.fullbagshootallowed()) or rf.localisdead()
    or not rf.localisinround() or not tool.Enabled or tool.Parent ~= localplayer.Character then return end
  if not target or not target.Character or not rf.autoshootfarvalid(target) then return end
  if not aimpart or not aimpart:IsDescendantOf(target.Character)
    or (not activehover and not rf.matcheshitpart(aimpart, target.Character)) then
    local handle = tool:FindFirstChild("Handle", true)
    local origin = handle and handle:IsA("BasePart") and handle.Position or character:GetPivot().Position
    point, aimpart = rf.autoshootfarpoint(target, origin)
    if not aimpart then return end
  end
  local handle = tool:FindFirstChild("Handle", true)
  local origin = handle and handle:IsA("BasePart") and handle.Position or character:GetPivot().Position
  local basepoint = rf.autoshootbase(target.Character, aimpart, origin)
  if not basepoint or not visible(target.Character, basepoint, origin, aimpart) then rf.autoshootstatus("Final line-of-sight check blocked") return end
  local predicted = rf.autoshootforecast(target, aimpart, origin)
  point = predicted and visible(target.Character, predicted, origin, aimpart) and predicted or basepoint
  if activehover and not rf.motionacquire("autoshoot", 0.45) then return end
  state.mouseactiveuntil = math.max(state.mouseactiveuntil, now + 0.3)
  state.autoshootpoint, state.autoshootpointuntil = point, now + 0.22
  state.autoshoottrack = {target = target, part = aimpart, tool = tool, exact = false, untiltime = now + 0.22}
  state.mousecache.time = -math.huge
  local fired = rf.autoshootfire(tool, character)
  if fired then
    state.autoshotlast = os.clock()
    local record = state.fullbagshot
    if config.autoshootwhenfull and record then
      record.targetid = target.UserId
      record.targetcharacter = target.Character
      record.targethumanoid = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
      record.shots = (record.shots or 0) + 1
      record.lastshot = now
      record.nexttry = now + 0.42
    end
    if activehover then
      rf.delay(0.06, function()
        if state.alive and state.autoshoothover == activehover then
          rf.autoshootstophover(true)
        end
      end)
    else
      rf.motionrelease("autoshoot", true)
    end
    if config.autounequipgun then
      local humanoid = character and character:FindFirstChildOfClass("Humanoid")
      rf.defer(function()
        if state.alive and humanoid and humanoid.Parent and tool.Parent == character then
          pcall(function() humanoid:UnequipTools() end)
        end
      end)
    end
  else
    state.autoshootpoint, state.autoshootpointuntil = nil, 0
    state.autoshoottrack = nil
    if activehover then rf.autoshootstophover(true)
    else rf.motionrelease("autoshoot", true) end
  end
end


function rf.shootmurdererkey(source, record)
  if source == "fullbag" then return end
  if not state.alive or (state.menuopen and source ~= "fullbag") or state.endlock
    or rf.localisdead() or not rf.localisinround() or rf.localismurderer()
    or state.manualshotbusy then return end
  if state.pickupbusy then
    if source ~= "fullbag" then state.pendingmanualshot = os.clock() + 4 end
    return
  end
  local character = localplayer.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  local root = character and character:FindFirstChild("HumanoidRootPart")
  local tool = rf.findautoshootgun()
  if not character or not humanoid or humanoid.Health <= 0 or not root or not tool then return end
  rf.watchweaponactivation(tool)
  local candidate, closest
  for _, player in ipairs(players:GetPlayers()) do
    if rf.autoshootfarvalid(player) then
      local enemyroot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
      if enemyroot then
        local distance = (enemyroot.Position - root.Position).Magnitude
        if not closest or distance < closest then
          candidate, closest = player, distance
        end
      end
    end
  end
  if not candidate then return end
  local snapshot = {
    pivot = character:GetPivot(), anchored = root.Anchored,
    autorotate = humanoid.AutoRotate, platformstand = humanoid.PlatformStand,
    hidden = farm.hide, roundstartedat = state.roundstartedat
  }
  if not rf.motionacquire("manualshot", 2.6) then return end
  if source == "fullbag" and record and state.fullbagshot == record then
    record.targetid = candidate.UserId
    record.targetcharacter = candidate.Character
    record.targethumanoid = candidate.Character and candidate.Character:FindFirstChildOfClass("Humanoid")
  end
  state.manualshotbusy = true
  state.manualshotsource = source or "keybind"
  local started = os.clock()
  local deadline = started + 2.45
  local phase = "equip"
  local finished = false
  local settleuntil = 0
  local firedat = 0
  local lastattempt = 0
  local lastposition = 0
  local repositioned = 0
  local confirmed = false
  local activated = false
  local signalattempt = false
  local inputattempt = false
  local activationretries = 0
  local connections = {}
  local function finish()
    if finished then return end
    finished = true
    for _, connection in ipairs(connections) do connection:Disconnect() end
    table.clear(connections)
    if state.alive and motionqueue.owner == "manualshot"
      and character == localplayer.Character and character.Parent and root.Parent
      and humanoid.Parent and humanoid.Health > 0
      and snapshot.roundstartedat == state.roundstartedat
      and not rf.localisdead() and not rf.voidlobbyspawn(root.Position) then
      local rehide = snapshot.hidden and flags.autofarm and config.farmhidefull
        and farm.full and not state.endlock
      local destination = snapshot.pivot
      if snapshot.hidden and not rehide then
        destination = snapshot.hidden.origin or destination
      end
      pcall(function()
        root.Anchored = false
        rf.teleportpivot(character, destination)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.Anchored = rehide and true or snapshot.anchored
        humanoid.AutoRotate = rehide and false or snapshot.autorotate
        humanoid.PlatformStand = snapshot.platformstand
      end)
      if rehide then
        farm.hide = snapshot.hidden
        farm.status = "hidden 2500 studs above final coin"
      elseif flags.autofarm then
        farm.nextscan = 0
        motionqueue.queuedcollect = true
        farm.status = "resuming coin collection"
      end
    end
    if state.autoshoottrack and state.autoshoottrack.tool == tool
      and state.autoshoottrack.target == candidate then
      state.autoshoottrack = nil
      state.autoshootpoint = nil
      state.autoshootpointuntil = 0
      state.mousecache.time = -math.huge
    end
    state.manualshotbusy = false
    state.manualshotsource = nil
    state.manualshotcancel = nil
    rf.motionrelease("manualshot", true)
  end
  connections[#connections + 1] = tool.Activated:Connect(function()
    if not finished and phase == "fired" then activated = true end
  end)
  if gunfired:IsA("RemoteEvent") then
    connections[#connections + 1] = gunfired.OnClientEvent:Connect(function(handle)
      if finished or phase ~= "fired" or typeof(handle) ~= "Instance" then return end
      if handle == tool or handle:IsDescendantOf(tool)
        or handle:IsDescendantOf(character) then confirmed = true end
    end)
  end
  state.manualshotcancel = finish
  local function findposition()
    local enemy = candidate.Character
    local enemyroot = enemy and enemy:FindFirstChild("HumanoidRootPart")
    local enemyhumanoid = enemy and enemy:FindFirstChildOfClass("Humanoid")
    if not enemyroot or not enemyhumanoid or enemyhumanoid.Health <= 0 then return nil end
    local handle = tool:FindFirstChild("Handle", true)
    local origin = handle and handle:IsA("BasePart") and handle.Position or root.Position + Vector3.new(0, 0.7, 0)
    for _, part in ipairs(rf.autoshootcandidates(enemy)) do
      local predicted = rf.autoshootforecast(candidate, part, origin)
      if predicted and visible(enemy, predicted, origin, part) then
        return root.Position, part, predicted, true
      end
    end
    local forward = rf.horizontal(enemyroot.CFrame.LookVector)
    local right = rf.horizontal(enemyroot.CFrame.RightVector)
    forward = forward.Magnitude > 0.001 and forward.Unit or Vector3.new(0, 0, -1)
    right = right.Magnitude > 0.001 and right.Unit or Vector3.new(1, 0, 0)
    local height = enemyroot.Position.Y
    local offsets = {
      -forward * 4, right * 4, -right * 4, forward * 4,
      -forward * 6 + right * 2, -forward * 6 - right * 2,
      forward * 6, right * 6, -right * 6
    }
    for _, offset in ipairs(offsets) do
      local position = Vector3.new(enemyroot.Position.X + offset.X, height, enemyroot.Position.Z + offset.Z)
      if rf.autoshootclearspace(position, enemy) then
        local point, part = rf.autoshootprobe(candidate, position + Vector3.new(0, 0.7, 0))
        if point and part then return position, part, point, false end
      end
    end
    return nil
  end
  local function step()
    if finished then return end
    local now = os.clock()
    if (source == "fullbag" and not rf.fullbagshootallowed())
      or not state.alive or state.endlock or now >= deadline or not character.Parent
      or character ~= localplayer.Character or not root.Parent or not humanoid.Parent
      or humanoid.Health <= 0 or not rf.autoshootfarvalid(candidate)
      or rf.motionowner() ~= "manualshot" then
      finish()
      return
    end
    motionqueue.manualuntil = math.max(motionqueue.manualuntil, now + 0.5)
    if phase == "fired" then
      root.AssemblyLinearVelocity = Vector3.zero
      root.AssemblyAngularVelocity = Vector3.zero
      if not activated and not confirmed and not signalattempt and now - firedat >= 0.08 then
        signalattempt = true
        local fire = type(firesignal) == "function" and firesignal
          or type(env.firesignal) == "function" and env.firesignal or nil
        if fire and tool.Parent == character and tool.Enabled then
          pcall(fire, tool.Activated)
        end
      end
      if not activated and not confirmed and activationretries < 1 and now - firedat >= 0.2
        and tool.Parent == character and tool.Enabled then
        activationretries += 1
        pcall(function() tool:Activate() end)
      end
      if not confirmed and not inputattempt and now - firedat >= 0.31 then
        inputattempt = true
        if tool.Parent == character and tool.Enabled and not state.menuopen then
          local click = type(mouse1click) == "function" and mouse1click
            or type(env.mouse1click) == "function" and env.mouse1click or nil
          if click then pcall(click) end
        end
      end
      if now - firedat >= (confirmed and 0.18 or activated and 0.3 or 0.62) then
        if not activated and not confirmed and source ~= "fullbag" then
          rf.notification("Gun activation", "The equipped gun did not acknowledge firing", nil,
            "alert-circle", Color3.fromRGB(255, 162, 124), "gun:activation:" .. tostring(math.floor(now)))
        end
        finish()
      end
      return
    end
    if tool.Parent ~= character then
      local backpack = localplayer:FindFirstChildOfClass("Backpack")
      if tool.Parent ~= backpack then finish() return end
      if now - lastattempt >= 0.12 then
        lastattempt = now
        pcall(function() humanoid:EquipTool(tool) end)
      end
      return
    end
    if not tool.Enabled then
      if now - lastattempt >= 0.2 then
        lastattempt = now
        rf.refreshgunready(tool, humanoid)
      end
      return
    end
    if phase == "settling" then
      root.AssemblyLinearVelocity = Vector3.zero
      root.AssemblyAngularVelocity = Vector3.zero
      if now < settleuntil then return end
      local enemy = candidate.Character
      local handle = tool:FindFirstChild("Handle", true)
      local origin = handle and handle:IsA("BasePart") and handle.Position
        or root.Position + Vector3.new(0, 0.7, 0)
      local aimpart, point
      if enemy then
        for _, part in ipairs(rf.autoshootcandidates(enemy)) do
          local predicted = rf.autoshootforecast(candidate, part, origin)
          if predicted and visible(enemy, predicted, origin, part) then
            aimpart, point = part, predicted
            break
          end
        end
      end
      if not point then
        repositioned += 1
        if repositioned >= 3 then finish() else phase = "position" end
        return
      end
      state.mouseactiveuntil = math.max(state.mouseactiveuntil, now + 0.45)
      state.autoshootpoint, state.autoshootpointuntil = point, now + 0.38
      state.autoshoottrack = {target = candidate, part = aimpart, tool = tool, exact = false, untiltime = now + 0.38}
      state.mousecache.time = -math.huge
      phase = "fired"
      firedat = now
      local ok = pcall(function() tool:Activate() end)
      if not ok then
        firedat = now - 0.12
      end
      state.autoshotlast = now
      if source == "fullbag" and record and state.fullbagshot == record then
        record.shots = (record.shots or 0) + 1
        record.lastshot = now
        record.nexttry = now + 1.2
      end
      return
    end
    if now - lastposition < 0.06 then return end
    lastposition = now
    local position, part, point, stationary = findposition()
    if not position or not part or not point then return end
    if not stationary then
      local facing = Vector3.new(point.X, position.Y, point.Z)
      if (facing - position).Magnitude <= 0.01 then return end
      local frame = CFrame.lookAt(position, facing)
      local offset = root.CFrame:ToObjectSpace(character:GetPivot())
      local moved = pcall(function()
        root.Anchored = false
        humanoid.PlatformStand = false
        rf.teleportpivot(character, frame * offset)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
      end)
      if not moved then return end
    end
    phase = "settling"
    settleuntil = now + 0.07
  end
  connections[#connections + 1] = runservice.Heartbeat:Connect(step)
  rf.delay(2.7, finish)
  step()
end

local function watchautoshootcharacter(char)
  for _, item in ipairs(char:GetChildren()) do
    if item:IsA("Tool") and (rf.isgunname(item.Name) or rf.isknifename(item.Name)
      or item:FindFirstChild("Muzzle", true)) then
      rf.watchweaponactivation(item)
    end
  end
  table.insert(state.connections, char.ChildAdded:Connect(function(item)
    if item:IsA("Tool") and (rf.isgunname(item.Name) or rf.isknifename(item.Name)
      or item:FindFirstChild("Muzzle", true)) then
      rf.watchweaponactivation(item)
      if (rf.isgunname(item.Name) or item:FindFirstChild("Muzzle", true))
        and state.alive and config.autoshoot then
        state.autoshotnext = 0
      end
    end
  end))
end

if localplayer.Character then watchautoshootcharacter(localplayer.Character) end
table.insert(state.connections, localplayer.CharacterAdded:Connect(function(character)
  rf.autoshootstophover(false)
  watchautoshootcharacter(character)
  rf.spawn(function()
    local root = character:WaitForChild("HumanoidRootPart", 10)
    if root and state.alive and localplayer.Character == character then
      rf.voidlobbyspawn(root.Position)
      local humanoid = character:FindFirstChildOfClass("Humanoid")
      if humanoid then
        local connection = humanoid.Died:Connect(function()
          if state.alive and root.Parent then rf.voidlobbyspawn(root.Position) end
        end)
        table.insert(state.connections, connection)
      end
    end
  end)
end))

if loadingmap and loadingmap:IsA("RemoteEvent") then
  table.insert(state.connections, loadingmap.OnClientEvent:Connect(function(mode)
    pcall(rf.tracknextmap, true)
    state.mapmode = type(mode) == "string" and mode or nil
    state.maproot, state.mapcf, state.mapsize, state.mapspawn = nil, nil, nil, nil
    rf.voidresetmap()
    state.lastgun, state.lastsheriff, state.gunhistory = nil, {}, {}
    state.nextmaptry, state.nextdropscan = -math.huge, 0
    state.dropposition, state.dropinstance, state.droppart, state.dropattachment, state.dropproof = nil, nil, nil, nil, nil
    state.pickupdropkey, state.pickupdropreadyat = nil, 0
    if state.pickuprestore then state.pickuprestore() end
    if rf.autokillstop then rf.autokillstop("loading next map", false) end
    rf.autoshootstophover(true)
    rf.farmshowafterfull(true)
    rf.bagreset()
    rf.cleargunmarker()
  end))
end
rf.voidlobbyspawn(localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
  and localplayer.Character.HumanoidRootPart.Position or nil)
if teleporttopart and teleporttopart:IsA("RemoteEvent") then
  table.insert(state.connections, teleporttopart.OnClientEvent:Connect(function(destination)
    if rf.voidislobbyspawn(destination) then
      rf.voidrecordspawn(destination)
    elseif rf.mapfromspawn(destination) then
      rf.voidrecordspawn(destination)
      state.nextdropscan = 0
      state.dropdirty = true
      state.guntrackelapsed = math.max(state.guntrackelapsed or 0, tonumber(config.guntrackinterval) or 0.08)
    end
  end))
end

table.insert(state.connections, fade.OnClientEvent:Connect(function(payload)
  state.victoryactive, state.victoryvisible = false, false
  local roles = rf.validroundpayload(payload)
  if roles then
    rf.resources.votefadearmed = true
    rf.loadroles(roles, true, "fade")
  end
end))
table.insert(state.connections, roundend.OnClientEvent:Connect(rf.endround))
if playerchanged and playerchanged:IsA("RemoteEvent") then
  table.insert(state.connections, playerchanged.OnClientEvent:Connect(function(payload)
    if type(payload) == "table" and next(payload) == nil then
      rf.endround(true)
    else
      rf.loadroles(payload, false)
    end
  end))
end
if roundstart and roundstart:IsA("RemoteEvent") then
  table.insert(state.connections, roundstart.OnClientEvent:Connect(function(...)
    state.victoryactive, state.victoryvisible = false, false
    local arguments = table.pack(...)
    for index = 1, arguments.n do
      local roles = rf.validroundpayload(arguments[index])
      if roles then
        rf.resources.votefadearmed = true
        rf.loadroles(roles, true, "roundstart")
        break
      end
    end
  end))
end
function rf.roundvictoryreason(reason, participant)
  local result = state.roundresult
  local key = type(reason) == "string" and reason:lower():gsub("[^%w]", "") or ""
  local playerid = typeof(participant) == "Instance" and participant:IsA("Player") and participant.UserId
    or type(participant) == "number" and participant or nil
  local localrole = result and result.localrole
  if not localrole then
    local record = state.authoritative[localplayer.UserId] or rf.getrecord(localplayer)
    localrole = record and rf.normalize_role(record.Role)
  end
  if result and result.murdererleft or key:find("murdererleft", 1, true)
    or key:find("murdererquit", 1, true) then
    return "Murderer has left."
  end
  if key:find("murdererdied", 1, true) or key:find("murdererkilled", 1, true)
    or key:find("murdererdefeated", 1, true) or key == "sheriffwin" or key == "herowin" then
    if playerid == localplayer.UserId and (localrole == "Sheriff" or localrole == "Hero" or localrole == "Innocent") then
      return "You killed the murderer."
    end
    if typeof(participant) == "Instance" and participant:IsA("Player") then
      return "@" .. participant.Name .. " killed the murderer."
    end
    return "The murderer was eliminated."
  end
  if key:find("innocentsdied", 1, true) or key:find("innocentskilled", 1, true)
    or key:find("murdererwon", 1, true) or key:find("murdererwin", 1, true)
    or key:find("murderervictory", 1, true) or key:find("murdererkilledeveryone", 1, true) then
    if localrole == "Murderer" then return "You killed all innocents." end
    return "The murderer killed all innocents."
  end
  if key:find("timeup", 1, true) or key:find("timeout", 1, true)
    or key:find("timerrunout", 1, true) or key:find("timesup", 1, true) then
    return "The innocents survived until time ran out."
  end
  if key:find("innocentwin", 1, true) or key:find("innocentswin", 1, true)
    or key:find("innocentvictory", 1, true) then
    return "The innocents won the round."
  end
  if key:find("draw", 1, true) then return "The round ended in a draw." end
  return "The round has ended."
end

function rf.showroundresult(reason, participant)
  local result = state.roundresult
  if result and result.notified then return end
  local message = rf.roundvictoryreason(reason, participant)
  if result then result.notified = true end
  local id = typeof(participant) == "Instance" and participant:IsA("Player") and participant.UserId
    or result and result.murdererleft and result.murdererid or nil
  rf.notification("Round complete", message, id, "award", Color3.fromRGB(255, 235, 64),
    "roundreason:" .. tostring(result and result.serial or 0))
end

if victory and victory:IsA("RemoteEvent") then
  table.insert(state.connections, victory.OnClientEvent:Connect(function(_, _, reason, participant)
    state.victoryactive = true
    state.coinroundhidden = true
    if rf.autokillstop then rf.autokillstop("round finished", false) end
    if rf.autoshootstophover then rf.autoshootstophover(true) end
    rf.clearcoinchams()
    rf.farmshowafterfull(true)
    rf.farmstop(true)
    farm.fullshoteligible = false
    farm.lastcollectmotion = 0
    farm.lastcollectround = 0
    farm.lastcollectcharacter = nil
    state.fullbagshot = nil
    farm.home = nil
    farm.status = flags.autofarm and "waiting for next round" or "off"
    if state.pickuprestore then state.pickuprestore() end
    rf.showroundresult(reason, participant)
  end))
end
if specialxp and specialxp:IsA("RemoteEvent") then
  table.insert(state.connections, specialxp.OnClientEvent:Connect(function(name)
    if not state.round or not state.synced then return end
    if name == "Throwing Kill!" or name == "Melee Kill!" then
      if config.killnotices then
        rf.notification(name == "Throwing Kill!" and "Throwing kill" or "Melee kill", "Special XP earned",
          nil, "swords", Color3.fromRGB(255, 235, 64), "xp:" .. name)
      end
    end
  end))
end
table.insert(state.connections, gunfired.OnClientEvent:Connect(function(handle, start, finish, impact)
  pcall(rf.farmrecordgunshot, handle, start, finish)
  pcall(rf.showgunfx, handle, start, finish, impact)
end))

function rf.validroundpayload(data)
  if type(data) ~= "table" then return nil end
  for _, key in ipairs({"PlayerData", "Players", "CurrentPlayerData", "CurrentRoundData", "RoundData"}) do
    if type(data[key]) == "table" then data = data[key] end
  end
  for _, record in pairs(data) do
    if type(record) == "table" and rf.normalize_role(record.Role) then return data end
  end
  return nil
end

function rf.fetchroles(force)
  if not state.alive then return false end
  if state.rolefetchpending then return false end
  local requestgeneration = state.roundstartedat
  local cooldown = force and 0.5 or math.max(1, tonumber(config.roundrequestcooldown) or 8)
  if os.clock() - state.requesttime < cooldown then return false end
  state.requesttime = os.clock()
  local modules = replicatedstorage:FindFirstChild("Modules")
  local source = modules and modules:FindFirstChild("CurrentRoundClient")
  if source and source:IsA("ModuleScript") then
    local signal = source:FindFirstChild("PlayerDataChanged")
    if signal and signal:IsA("BindableEvent") and not state.rounddatawatch then
      state.rounddatawatch = signal.Event:Connect(function()
        if state.alive then rf.defer(rf.fetchroles, true) end
      end)
      table.insert(state.connections, state.rounddatawatch)
    end
    local ok, value = pcall(require, source)
    if not state.alive or state.roundstartedat ~= requestgeneration or state.endlock then return false end
    if ok and type(value) == "table" then
      for _, key in ipairs({"PlayerData", "Players", "RoundData", "CurrentPlayerData", "CurrentRoundData", "Data", "Round", "State"}) do
        local okread, candidate = pcall(function() return value[key] end)
        local data = okread and rf.validroundpayload(candidate) or nil
        if data then
          rf.loadroles(data, false)
          state.requeststatus = "read CurrentRoundClient." .. key
          return true
        end
      end
      for _, key in ipairs({"GetPlayerData", "GetRoundData", "GetCurrentPlayerData", "GetCurrentRoundData"}) do
        local okread, fn = pcall(function() return value[key] end)
        if not okread then fn = nil end
        if type(fn) == "function" then
          local found, data = pcall(fn, value)
          data = found and rf.validroundpayload(data) or nil
          if data then
            rf.loadroles(data, false)
            state.requeststatus = "read CurrentRoundClient:" .. key
            return true
          end
        end
      end
    end
  end
  local remotes = replicatedstorage:FindFirstChild("Remotes")
  for _, name in ipairs({"GetCurrentRoundData", "GetRoundData", "GetPlayerData"}) do
    local endpoint = gameplay:FindFirstChild(name) or (remotes and remotes:FindFirstChild(name))
    if endpoint and endpoint:IsA("RemoteFunction") then
      state.requeststatus = "requesting " .. endpoint:GetFullName()
      local request = {}
      state.rolefetchpending = request
      rf.delay(12, function()
        if state.rolefetchpending == request then
          request.expired = true
          state.rolefetchpending = nil
          state.requesttime = os.clock() + 30
          if request.thread and coroutine.status(request.thread) ~= "dead" then pcall(task.cancel, request.thread) end
          state.requeststatus = "Round data request timed out; retry delayed"
        end
      end)
      request.thread = rf.spawn(function()
        local ok, response = pcall(function() return endpoint:InvokeServer() end)
        if state.rolefetchpending ~= request then return end
        state.rolefetchpending = nil
        if request.expired or not state.alive or state.roundstartedat ~= requestgeneration or state.endlock then return end
        local data = ok and rf.validroundpayload(response) or nil
        if data then
          rf.loadroles(data, false)
          state.requeststatus = "received " .. endpoint.Name
        else
          state.requeststatus = "endpoint returned no readable role table"
        end
      end)
      return true
    end
  end
  state.requeststatus = "no confirmed round-data request endpoint"
  return false
end

api.functions.fetchroles = rf.fetchroles
api.functions.killnotice = rf.killnotice
api.functions.notify = function(reason, detail, player, icon)
  rf.notification(reason, detail, player, icon or "award", Color3.fromRGB(255, 235, 64))
end
api.functions.notifications = function(enabled)
  config.notifications = enabled == nil and not config.notifications or enabled == true
  rf.updatehud()
  return config.notifications
end
api.functions.getfetchstatus = function() return state.requeststatus end
api.functions.isinround = rf.localisinround
api.functions.roundstatus = function()
  local names = {}
  for id in pairs(state.participants) do
    local player = players:GetPlayerByUserId(id)
    names[#names + 1] = player and player.Name or tostring(id)
  end
  table.sort(names)
  return {active = state.round and not state.endlock, participating = rf.localisinround(),
    synced = state.synced, participants = names, source = state.requeststatus}
end
api.functions.refresh = rf.refreshvisuals
api.functions.menu = function(value)
  rf.showmenu(value == nil and not config.showmenu or not not value)
end
api.functions.detectroles = rf.inferroles
api.functions.mapstatus = function()
  return {mode = state.mapmode, map = state.maproot and state.maproot:GetFullName() or nil,
    ready = state.mapcf ~= nil, spawn = state.mapspawn}
end
api.functions.gunhistory = function()
  local history = {}
  for id, entry in pairs(state.gunhistory) do
    local p = players:GetPlayerByUserId(id)
    history[p and p.Name or tostring(id)] = {position = entry.position, timestamp = entry.timestamp}
  end
  return history
end
api.functions.getgunlocation = function()
  return state.gunmarkerposition or state.lastgun and state.lastgun.position or nil, state.gunmarkerkind, state.dropinstance
end
api.functions.pickupgun = rf.pickupgun
api.functions.pickupstatus = function() return state.pickupstatus end
api.functions.headcontact = function(enabled)
  config.pickupheadcontact = enabled == nil and not config.pickupheadcontact or enabled == true
  if not config.pickupheadcontact and state.pickuprestore then state.pickuprestore() end
  rf.updatehud()
  return config.pickupheadcontact
end
api.functions.ismurderer = rf.localismurderer
api.functions.isdead = rf.localisdead
api.functions.autopickup = function(enabled)
  flags.autopickup = enabled == nil and not flags.autopickup or enabled == true
  rf.updatehud()
  return flags.autopickup
end
api.functions.getpickupattachment = function()
  local marker = state.gunmarkerposition or state.lastgun and state.lastgun.position
  if typeof(marker) ~= "Vector3" then
    local root = localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
    marker = root and root.Position or Vector3.zero
  end
  return rf.getpickupattachment(marker)
end
api.functions.getdrop = function()
  return state.dropinstance, state.droppart, state.dropposition, state.dropattachment
end
api.functions.finddrops = function()
  local findings = {}
  local center = state.lastgun and state.lastgun.position
  for instance in pairs(state.dropcandidates) do
    local part, position, proof = rf.verifiedgundrop(instance)
    if part and proof then
      findings[#findings + 1] = {
        object = instance, path = instance:GetFullName(), score = rf.dropstrength(instance),
        position = position, distance = center and (position - center).Magnitude or nil,
        proof = proof
      }
    end
  end
  table.sort(findings, function(a, b)
    return (a.distance or math.huge) < (b.distance or math.huge)
  end)
  return findings
end

api.functions.autovote = function(enabled)
  config.autovote = enabled == nil and not config.autovote or enabled == true
  rf.voteenabled()
  savepreferences()
  rf.updatehud()
  return config.autovote
end
api.functions.votemaps = function()
  return table.clone(config.autovotemaps)
end
api.functions.voteselect = rf.voteselect
api.functions.votestatus = function()
  return {enabled = config.autovote, selected = table.clone(config.autovotemaps),
    status = voting.status, map = voting.name, pad = voting.pad, attempts = voting.attempts}
end

api.functions.getaimpoint = rf.targetpoint
api.functions.autoshootfar = function(enabled)
  config.autoshootfar = enabled == nil and not config.autoshootfar or enabled == true
  if not config.autoshootfar and rf.autoshootstophover and state.autoshoothover
    and state.autoshoothover.mode == "far" then rf.autoshootstophover(true) end
  savepreferences()
  rf.updatehud()
  return config.autoshootfar
end
api.functions.farmhidefull = function(enabled)
  config.farmhidefull = enabled == nil and not config.farmhidefull or enabled == true
  if not config.farmhidefull then
    rf.farmshowafterfull(true)
    if farm.full then farm.returnedfull = false end
  elseif flags.autofarm and farm.full and not config.farmresetfull then rf.farmhidewhenfull() end
  savepreferences()
  rf.updatehud()
  return config.farmhidefull
end
api.functions.farmresetfull = function(enabled)
  config.farmresetfull = enabled == nil and not config.farmresetfull or enabled == true
  if config.farmresetfull and flags.autofarm then
    rf.farmcheckfull(true)
    if farm.hide then rf.farmshowafterfull(true) end
    if farm.full then rf.farmresetwhenfull() end
  end
  savepreferences()
  rf.updatehud()
  return config.farmresetfull
end
api.functions.autoshootbehind = function(enabled)
  config.autoshootbehind = enabled == nil and not config.autoshootbehind or enabled == true
  if not config.autoshootbehind and state.autoshoothover and state.autoshoothover.mode == "behind" then
    rf.autoshootstophover(true)
  end
  savepreferences()
  rf.updatehud()
  return config.autoshootbehind
end
api.functions.autoshoot = function(enabled)
  return rf.setautoshoot(enabled == nil and not config.autoshoot or enabled == true)
end
api.functions.knifeaim = function(enabled)
  config.knifeaim = enabled == nil and not config.knifeaim or enabled == true
  savepreferences()
  state.mousecache.time = -math.huge
  rf.updatehud()
  return config.knifeaim
end
api.functions.gettracking = function(user)
  local player = type(user) == "string" and players:FindFirstChild(user) or nil
  local id = (typeof(user) == "Instance" and user:IsA("Player") and user.UserId)
    or (player and player.UserId) or tonumber(user)
  local tracker = id and state.tracking[id]
  if not tracker then return nil end
  return tracker.model, tracker.center, tracker.small
end
api.functions.tracking = function(enabled)
  config.r6tracking = enabled == nil and not config.r6tracking or enabled == true
  rf.updatetracking()
  rf.refreshvisuals()
  rf.updatehud()
  return config.r6tracking
end
api.functions.mousecframe = function(enabled)
  config.mousecframespoof = enabled == nil and not config.mousecframespoof or enabled == true
  state.mousecache.time = -math.huge
  return config.mousecframespoof, state.mouseerror
end
api.functions.mousehookstatus = function()
  return mousehook.installed and mousehook.resolve == rf.spoofmouse, state.mouseerror
end
api.functions.getmotion = function(user)
  local id = typeof(user) == "Instance" and user:IsA("Player") and user.UserId or tonumber(user)
  return id and state.motion[id] or nil
end
api.functions.performance = function()
  local p = state.performance
  return {fps = math.floor(p.fps + 0.5), mode = config.adaptiveesp and p.tier or "full",
    adaptive = config.adaptiveesp, skeletonfps = math.floor(1 / rf.adaptiveinterval(
      math.max(1 / 90, tonumber(config.skeletonrefresh) or 1 / 45), 1 / 24, 1 / 12) + 0.5)}
end
api.functions.adaptiveesp = function(enabled)
  config.adaptiveesp = enabled == nil and not config.adaptiveesp or enabled == true
  if not config.adaptiveesp then state.performance.tier, state.performance.pending = "full", nil end
  rf.updatehud()
  return config.adaptiveesp
end
api.functions.gunowner = function()
  return state.gunownershipid and players:GetPlayerByUserId(state.gunownershipid) or nil,
    state.gunownershipsource
end
api.functions.movementqueue = function()
  return {owner = rf.motionowner(), queuedcollect = motionqueue.queuedcollect,
    queuedreturn = motionqueue.returnkind ~= nil,
    priorities = motionpriorities, activekill = state.autokill.active}
end
api.functions.autofarm = function(enabled)
  local previous = flags.autofarm
  flags.autofarm = enabled == nil and not flags.autofarm or enabled == true
  if previous ~= flags.autofarm then
    farm.fullshoteligible = false
    farm.lastcollectmotion = 0
    farm.lastcollectround = 0
    farm.lastcollectcharacter = nil
  end
  savepreferences()
  if not flags.autofarm then
    motionqueue.queuedcollect = false
    rf.motionclearreturn()
    rf.farmshowafterfull(true)
    rf.farmcancelreturn()
    farm.lastcoinposition = nil
    farm.returnedfull = false
    farm.nohighlightssince = nil
    rf.farmstop(true)
    rf.farmreleasenoclip()
    farm.status = "off"
    if not flags.coinchams then rf.clearcoinchams() end
  else
    rf.farmcoinautoclip(true)
    rf.motionclearreturn()
    rf.farmcheckfull(true)
    if farm.full then
      local character = localplayer.Character
      local root = character and character:FindFirstChild("HumanoidRootPart")
      if not farm.lastcoinposition and root then farm.lastcoinposition = root.Position end
    end
    farm.returnedfull = false
    farm.nohighlightssince = nil
    farm.home = nil
    if rf.localisinround() then rf.farmcapturehome() end
    farm.nextscan = 0
    farm.status = farm.full and "coin bag full" or "searching for coins"
    rf.spawn(rf.refreshcoinchams)
    if farm.full and config.farmresetfull then rf.farmresetwhenfull()
    elseif farm.full and config.farmhidefull then rf.farmhidewhenfull() end
  end
  rf.updatehud()
  return flags.autofarm
end
api.functions.antivoid = function(enabled)
  config.antivoid = enabled == nil and not config.antivoid or enabled == true
  savepreferences()
  rf.updatehud()
  return config.antivoid, state.voidsafe.recoveries
end
api.functions.spawnpoint = function()
  local safe = state.voidsafe
  local character = localplayer.Character
  local root = character and character:FindFirstChild("HumanoidRootPart")
  local inlobby = root and rf.voidlobbyspawn(root.Position) or false
  local mapframe = safe.maproot == state.maproot and safe.mapframe or nil
  if safe.lobbyframe and (inlobby or rf.localisdead() or not state.round) then
    return safe.lobbyframe, "lobby"
  end
  if mapframe then return mapframe, "map" end
  if safe.checkpoint then return safe.checkpoint, "grounded" end
  return safe.lobbyframe, safe.lobbyframe and "lobby" or "unavailable"
end
api.functions.persistnoclip = function(enabled)
  return rf.setglobalnoclip(enabled == nil and not config.persistnoclip or enabled == true)
end
api.functions.autofarmnoclip = function(enabled)
  return rf.setautofarmnoclip(enabled == nil and not config.autofarmnoclip or enabled == true)
end
api.functions.teleporttoplayer = function(player)
  if type(player) == "number" then player = players:GetPlayerByUserId(player) end
  if type(player) == "string" then player = players:FindFirstChild(player) end
  if typeof(player) ~= "Instance" or not player:IsA("Player") then return false end
  return rf.teleporttoplayer(player)
end
api.functions.walkspeed = function(mode)
  if mode == nil then
    return config.walkspeedpreset, walkspeeds[config.walkspeedpreset]
  end
  local success = mode == "next" and rf.cyclewalkspeed() or rf.setwalkspeed(mode)
  if success then rf.updatehud() end
  return success and config.walkspeedpreset or nil, success and walkspeeds[config.walkspeedpreset] or nil
end
api.functions.autokill = function(enabled)
  flags.autokillall = enabled == nil and not flags.autokillall or enabled == true
  if not flags.autokillall then rf.autokillstop("off", true) end
  if flags.autokillall then flags.knifeall = false end
  savepreferences()
  rf.updatehud()
  return flags.autokillall, state.autokill.status
end
api.functions.autokillmode = function(value)
  if value == nil then return config.autokillmode end
  if not validautokillmodes[value] then return nil end
  config.autokillmode = value
  rf.autokillstop("changing mode", true)
  savepreferences()
  rf.updatehud()
  return value
end
api.functions.autokillstatus = function()
  local job = state.autokill
  return {enabled = flags.autokillall, mode = config.autokillmode, status = job.status,
    fullonly = config.autokillfullbag, bagfull = rf.autokillbagfull(),
    bagcount = job.bagcount, bagcapacity = job.bagcapacity, active = job.active,
    target = job.target and job.target.Name or nil, attempts = job.attempts,
    completed = job.completed}
end
api.functions.knifeall = function(enabled)
  flags.knifeall = enabled == nil and not flags.knifeall or enabled == true
  rf.updatehud()
  return flags.knifeall, state.knifeall.status
end
api.functions.antifling = function(enabled)
  config.antifling = enabled == nil and not config.antifling or enabled == true
  if not config.antifling then state.antifling.safe = nil end
  rf.updatehud()
  return config.antifling, state.antifling.blocks
end
api.functions.farmstatus = function()
  local session = farm.session
  local aim = session and rf.farmrootpoint(session)
  local actual = session and session.root and session.root.Parent and session.root.Position
  return {enabled = flags.autofarm, status = farm.status,
    confirmed = farm.confirmed, approached = farm.attempted,
    target = farm.target, speed = 24.5,
    headtarget = aim, headposition = actual,
    alignmenterror = aim and actual and (aim - actual).Magnitude or nil}
end
api.functions.coinchams = function(enabled)
  flags.coinchams = enabled == nil and not flags.coinchams or enabled == true
  rf.spawn(rf.refreshcoinchams)
  rf.updatehud()
  return flags.coinchams
end
api.functions.refreshcoins = function()
  rf.spawn(rf.refreshcoinchams)
end
api.functions.clear = rf.clearvisuals
api.functions.nocollision = function(enabled)
  flags.nocollision = enabled == nil and not flags.nocollision or enabled == true
  rf.updatecollisions()
  rf.updatehud()
  return flags.nocollision
end
api.functions.visualsetting = function(name, enabled)
  if defaults[name] == nil or type(defaults[name]) ~= "boolean" then return nil end
  if name ~= "gunbeamglow" and name ~= "gunbeamtracer" and name ~= "gunbeammuzzle"
    and name ~= "gunbeamimpact" and name ~= "removetextures" and name ~= "simplematerials" and name ~= "disablemapfx"
    and name ~= "fullbright" and name ~= "clearfog" and name ~= "noshadows"
    and name ~= "distanceculling" and name ~= "frustumculling"
    and name ~= "disablepostfx" and name ~= "lowqualitywater" then return nil end
  config[name] = enabled == nil and not config[name] or enabled == true
  if name == "removetextures" or name == "simplematerials" or name == "disablemapfx" then
    rf.refreshworldgraphics()
  elseif name == "fullbright" or name == "clearfog" or name == "noshadows" then
    rf.applylightingvisuals()
  elseif name == "distanceculling" or name == "frustumculling"
    or name == "disablepostfx" or name == "lowqualitywater" then
    rf.refreshperformancegraphics()
  end
  savepreferences()
  rf.updatehud()
  return config[name]
end
api.functions.gunbeamstyle = function(style)
  if style == nil then return config.gunbeamstyle end
  if not table.find(gunbeamstyles, tostring(style)) then return nil end
  config.gunbeamstyle = tostring(style)
  savepreferences()
  rf.updatehud()
  return config.gunbeamstyle
end
api.functions.gunbeamwidth = function(width)
  if width == nil then return config.gunbeamwidth end
  if not table.find(gunbeamwidths, tostring(width)) then return nil end
  config.gunbeamwidth = tostring(width)
  savepreferences()
  rf.updatehud()
  return config.gunbeamwidth
end
api.functions.fpscap = function(mode)
  if mode == nil then return config.fpscapmode, visualstate.fpssupported end
  if not table.find(fpscapmodes, tostring(mode)) then return nil end
  local previousmode = config.fpscapmode
  config.fpscapmode = tostring(mode)
  if not rf.applyfpscap(false) then config.fpscapmode = previousmode return nil end
  savepreferences()
  rf.updatehud()
  return config.fpscapmode
end
api.functions.fov = function(mode)
  if mode == nil then return config.fovmode end
  if not table.find(fovmodes, tostring(mode)) then return nil end
  config.fovmode = tostring(mode)
  rf.applyfov()
  savepreferences()
  rf.updatehud()
  return config.fovmode
end
api.functions.stop = function()
  state.stop()
end
api.functions.toggle = rf.toggleflag
api.functions.enableall = function()
  flags.aim, flags.chams, flags.fx, flags.skeleton, flags.autopickup, flags.coinchams = true, true, true, true, true, true
  config.showinnocents, config.skeleton, config.throughwalls = true, true, true
  rf.refreshvisuals()
  rf.spawn(rf.refreshcoinchams)
  rf.updatecollisions()
  rf.updatehud()
end
api.functions.setrole = function(user, role)
  local p
  if typeof(user) == "Instance" and user:IsA("Player") then
    p = user
  elseif type(user) == "number" then
    p = players:GetPlayerByUserId(user)
  elseif type(user) == "string" then
    p = players:FindFirstChild(user)
  end
  local normalized = rf.normalize_role(role)
  if not p or not normalized then return false end
  local record = {Role = normalized, Dead = false, Killed = false, source = "manual", UserId = p.UserId}
  state.records[p.UserId] = record
  state.records[p.Name] = record
  if normalized == "Sheriff" or normalized == "Hero" then state.gunroleowner = p.UserId end
  rf.refreshvisuals()
  return true
end
api.functions.update = function()
  rf.inferroles()
  rf.refreshvisuals()
  rf.updategunmarker()
  rf.updatecollisions()
  rf.spawn(rf.refreshcoinchams)
  rf.updatehud()
end

function rf.stepmarquees()
  if not state.menuopen or not rf.resources.marquees then return end
  local now = os.clock()
  for name, item in pairs(rf.resources.marquees) do
    if not name.Parent or not item.face.Parent then
      rf.resources.marquees[name] = nil
    else
      local visible, ancestor = true, item.face
      while ancestor and ancestor:IsA("GuiObject") do
        if not ancestor.Visible then visible = false break end
        if ancestor:IsA("ScrollingFrame") then
          local a, b = ancestor.AbsolutePosition, ancestor.AbsoluteSize
          local p, q = item.face.AbsolutePosition, item.face.AbsoluteSize
          if p.X + q.X <= a.X or p.X >= a.X + b.X or p.Y + q.Y <= a.Y or p.Y >= a.Y + b.Y then
            visible = false; break
          end
        end
        ancestor = ancestor.Parent
      end
      if visible then
        local travel = math.max(0.5, item.overflow / 36)
        local phase = (now - item.started) % (travel * 2 + 2)
        local offset = phase < 1 and 0 or phase < 1 + travel and (phase - 1) / travel * item.overflow or phase < 2 + travel and item.overflow or (1 - (phase - 2 - travel) / travel) * item.overflow
        offset = math.floor(offset + 0.5)
        if offset ~= item.offset then
          item.offset = offset
          name.Position = UDim2.new(0, -offset, 0.5, 0)
        end
      else
        item.started = now
        if item.offset ~= 0 then item.offset = 0; name.Position = UDim2.fromScale(0, 0.5) end
      end
    end
  end
end
local marqueeclock = 0
table.insert(state.connections, runservice.PreRender:Connect(function(dt)
  if not state.alive or state.stopping then return end
  local framedt = finitenumber(dt) and math.max(dt, 0) or 1 / 60
  dt = math.min(framedt, 0.25)
  rf.safe("render:performance", rf.updateperformance, dt)
  if state.metrics and framedt > 0 then
    local metrics = state.metrics
    metrics.index = metrics.index % 1800 + 1
    metrics.frames[metrics.index] = framedt * 1000
  end
  if state.menuopen then marqueeclock += dt else marqueeclock = 0 end
  if marqueeclock >= 1 / 24 then marqueeclock = 0; rf.safe("render:marquee", rf.stepmarquees) end
  local drawingactive = flags.chams and config.espmode == "Drawing"
  if drawingactive or state.drawingwasactive then rf.safe("render:drawing", rf.renderdrawingesp) end
  state.drawingwasactive = drawingactive
  local skeletonactive = flags.chams and flags.skeleton and config.skeleton
  if state.skeletonwasactive and not skeletonactive then state.lastrender = -math.huge end
  if skeletonactive or state.skeletonwasactive then rf.safe("render:skeleton", rf.renderskeletons) end
  state.skeletonwasactive = skeletonactive
  if not config.notifications and #state.feed > 0 then rf.safe("render:notices", rf.drawnotices) end
end))

function rf.watchcharacter(p)
  local current = state.characterconnections[p]
  if current then
    for _, connection in ipairs(current) do connection:Disconnect() end
  end
  local group = {}
  state.characterconnections[p] = group
  local character = p.Character
  local backpack = p:FindFirstChildOfClass("Backpack")
  if backpack then
    group[#group + 1] = backpack.ChildAdded:Connect(function(object)
      if object:IsA("Tool") then
        rf.defer(function()
          if state.alive then rf.inferroles(); rf.refreshvisuals(); rf.updategunmarker() end
        end)
      end
    end)
    group[#group + 1] = backpack.ChildRemoved:Connect(function(object)
      if object:IsA("Tool") then
        rf.defer(function()
          if state.alive then rf.inferroles(); rf.refreshvisuals(); rf.updategunmarker() end
        end)
      end
    end)
  end
  if character then
    for _, item in ipairs(character:GetChildren()) do
      if item:IsA("Tool") and (rf.isgunname(item.Name) or rf.isknifename(item.Name)) then rf.watchweaponactivation(item) end
    end
    group[#group + 1] = character.ChildAdded:Connect(function(object)
      if object:IsA("Tool") then
        if rf.isgunname(object.Name) or rf.isknifename(object.Name) then rf.watchweaponactivation(object) end
        rf.defer(function()
          if state.alive then rf.inferroles(); rf.refreshvisuals(); rf.updategunmarker() end
        end)
      elseif object:IsA("Humanoid") then
        rf.defer(function()
          if state.alive then rf.refreshvisuals() end
        end)
      end
    end)
    group[#group + 1] = character.ChildRemoved:Connect(function(object)
      if object:IsA("Tool") then
        rf.defer(function()
          if state.alive then rf.inferroles(); rf.refreshvisuals(); rf.updategunmarker() end
        end)
      end
    end)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
      group[#group + 1] = humanoid.Died:Connect(function()
        if not state.alive or not rf.recordgunloss(p, character) then return end
        rf.defer(function()
          if state.alive then
            rf.rescanexistinggundrops(false)
            rf.updategunmarker()
          end
        end)
      end)
    end
  end
end

function rf.applyplayer(p)
  if not state.alive or not p.Parent or p == localplayer then return end
  if not rf.getrecord(p) then
    local role = state.round and not state.endlock and (not state.synced or state.participants[p.UserId]) and "Innocent" or "Neutral"
    local record = {Role = role, Dead = false, Killed = false, source = "assumed", UserId = p.UserId}
    state.records[p.UserId], state.records[p.Name] = record, record
  end
  if state.round and not state.endlock then rf.inferroles() end
  rf.refreshvisuals()
end

rf.resources.playerconnections = {}
function rf.watchplayer(p)
  if rf.resources.playerconnections[p] then return end
  local connections = {}
  rf.resources.playerconnections[p] = connections
  rf.watchcharacter(p)
  rf.applyplayer(p)
  table.insert(connections, p.CharacterRemoving:Connect(function(character)
    if not state.alive or not rf.recordgunloss(p, character) then return end
    rf.defer(function()
      if state.alive then
        rf.rescanexistinggundrops(false)
        rf.updategunmarker()
      end
    end)
  end))
  table.insert(connections, p.CharacterAdded:Connect(function(character)
    if not state.alive then return end
    rf.watchcharacter(p)
    rf.applyplayer(p)
    rf.spawn(function()
      local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
      if state.alive and p.Character == character and humanoid then rf.applyplayer(p) end
    end)
  end))
  if p.Character and not p.Character:FindFirstChildOfClass("Humanoid") then
    rf.spawn(function()
      local character = p.Character
      local humanoid = character and character:WaitForChild("Humanoid", 5)
      if state.alive and humanoid and p.Character == character then rf.applyplayer(p) end
    end)
  end
end
for _, p in ipairs(players:GetPlayers()) do rf.watchplayer(p) end
table.insert(state.connections, players.PlayerAdded:Connect(rf.watchplayer))
table.insert(state.connections, players.PlayerRemoving:Connect(function(p)
  local connections = rf.resources.playerconnections[p]
  if connections then for _, connection in ipairs(connections) do disconnect(connection) end end
  rf.resources.playerconnections[p] = nil
  if rf.resources.playerorder then rf.resources.playerorder[p.UserId] = nil end
  local id = p.UserId
  local character = p.Character
  local record = state.authoritative[id] or rf.getrecord(p)
  local role = record and rf.normalize_role(record.Role)
  local result = state.roundresult
  if result and state.round and state.synced and not state.endlock and not state.victoryactive
    and (result.murdererid == id or role == "Murderer" and
      (state.authoritative[id] ~= nil or record and record.source ~= "assumed")) then
    result.murdererid = id
    result.murderername = p.Name
    result.murdererleft = true
    result.leftat = os.clock()
    if not result.notified then
      rf.showroundresult("MurdererLeft", p)
    end
  end
  local washolder = state.gunholder == id or state.gunroleowner == id
    or state.gunownershipid == id or state.originalsheriff == id
    or role == "Sheriff" or role == "Hero" or rf.equippedrole(p) == "Sheriff"
  if not washolder then
    local backpack = p:FindFirstChildOfClass("Backpack")
    if backpack then
      for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and rf.isgunname(tool.Name) then
          washolder = true
          break
        end
      end
    end
  end
  if washolder then
    rf.recordgunloss(p, character)
    if character then
      for _, object in ipairs(character:GetDescendants()) do
        if rf.isgunraycastmarker(object) then state.dropmarkers[object] = true end
      end
    end
  end
  local current = state.characterconnections[p]
  if current then
    for _, connection in ipairs(current) do connection:Disconnect() end
    state.characterconnections[p] = nil
  end
  rf.destroyvisual(id)
  rf.removetracking(id)
  if state.gunroleowner == id then state.gunroleowner = nil end
  if state.gunholder == id then state.gunholder = nil end
  if state.gunownershipid == id then
    state.gunownershipid, state.gunownershipsource = nil, nil
  end
  state.nextdropscan = 0
  state.dropdirty = true
  rf.defer(function()
    if state.alive then
      rf.inferroles()
      rf.rescanexistinggundrops(false)
      rf.scangunpickup()
      rf.updategunmarker()
    end
  end)
  if state.round and not state.endlock then
    state.gunleaverescangeneration = (state.gunleaverescangeneration or 0) + 1
    local generation = state.gunleaverescangeneration
    local roundstartedat = state.roundstartedat
    rf.spawn(function()
      task.wait(0.08)
      for attempt = 1, 24 do
        if not state.alive or not state.round or state.endlock
          or state.gunleaverescangeneration ~= generation
          or state.roundstartedat ~= roundstartedat or rf.haslocalgun() then break end
        rf.rescanexistinggundrops(attempt == 1 or washolder and (attempt == 8 or attempt == 16))
        rf.scangunpickup()
        if state.pickupbusy or rf.validgundrop(state.dropinstance, state.droppart, state.dropproof) then
          break
        end
        task.wait(attempt <= 8 and 0.12 or 0.25)
      end
    end)
  end
end))

local function autokillfinite(vector)
  return typeof(vector) == "Vector3" and vector.X == vector.X and vector.Y == vector.Y and vector.Z == vector.Z
    and math.abs(vector.X) < 1000000 and math.abs(vector.Y) < 1000000 and math.abs(vector.Z) < 1000000
end

function rf.bagreset()
  local bag = state.bagstate
  bag.round = nil
  bag.count = nil
  bag.capacity = nil
  bag.full = false
  bag.source = "unknown"
  bag.updated = 0
  bag.nextscan = 0
  state.autokill.bagfull = false
  state.autokill.bagcount = nil
  state.autokill.bagcapacity = nil
  farm.full = false
  farm.fullround = nil
end

function rf.bagobserve(count, capacity, source, detected)
  local round = state.roundstartedat
  if not state.alive or not state.round or state.endlock
    or type(round) ~= "number" or round <= 0 then return false end
  local bag = state.bagstate
  if bag.round ~= round then rf.bagreset() bag.round = round end
  local now = os.clock()
  local numeric = type(count) == "number" and type(capacity) == "number"
    and count >= 0 and count < math.huge and capacity > 0 and capacity < math.huge
  if numeric then
    bag.count, bag.capacity, bag.updated = count, capacity, now
    if count >= capacity then
      detected = true
    elseif source == "event" then
      detected = false
    end
  end
  if detected and (not numeric or count >= capacity) then
    if type(bag.count) == "number" and type(bag.capacity) == "number"
      and bag.count < bag.capacity and now - bag.updated < 1.5 then
      detected = false
    else
      bag.full = true
      bag.source = source or "unknown"
    end
  end
  state.autokill.bagcount = bag.count
  state.autokill.bagcapacity = bag.capacity
  state.autokill.bagfull = bag.full
  if bag.full then
    local wasfull = farm.full and farm.fullround == round
    farm.full = true
    farm.fullround = round
    if flags.autofarm and not wasfull then
      farm.returnedfull = false
      rf.farmfinishfullbag()
    end
  end
  return bag.full
end

function rf.autokillbagfull()
  if not state.alive or not state.round or state.endlock then return false end
  local round = state.roundstartedat
  if type(round) ~= "number" or round <= 0 then return false end
  local bag = state.bagstate
  if bag.round ~= round then rf.bagreset() bag.round = round end
  if bag.full then return true end
  local now = os.clock()
  if now < bag.nextscan then return false end
  bag.nextscan = now + 0.22
  local seenfull = false
  local count, capacity
  for _, instance in ipairs({localplayer, localplayer.Character or false}) do
    if instance then
      for _, name in ipairs({"BagFull", "CoinBagFull", "CoinsFull"}) do
        if instance:GetAttribute(name) == true then seenfull = true end
        local value = instance:FindFirstChild(name)
        if value and value:IsA("BoolValue") and value.Value then seenfull = true end
      end
      for _, key in ipairs({"Coins", "CoinCount", "BagCount", "CollectedCoins"}) do
        local value = instance:GetAttribute(key)
        if typeof(value) == "number" then count = value break end
        local child = instance:FindFirstChild(key)
        if child and (child:IsA("IntValue") or child:IsA("NumberValue")) then count = child.Value break end
      end
      for _, key in ipairs({"MaxCoins", "MaxCoinCount", "BagCapacity", "CoinCapacity"}) do
        local value = instance:GetAttribute(key)
        if typeof(value) == "number" then capacity = value break end
        local child = instance:FindFirstChild(key)
        if child and (child:IsA("IntValue") or child:IsA("NumberValue")) then capacity = child.Value break end
      end
    end
  end
  return rf.bagobserve(count, capacity, "attributes", seenfull)
end

rf.resources.coincountremote = gameplay:FindFirstChild("CoinCollected")
if rf.resources.coincountremote and rf.resources.coincountremote:IsA("RemoteEvent") then
  table.insert(state.connections, rf.resources.coincountremote.OnClientEvent:Connect(function(_, count, capacity)
    if not state.alive or not state.round or state.endlock then return end
    if type(count) ~= "number" or type(capacity) ~= "number" or capacity <= 0 or capacity >= math.huge
      or count < 0 or count >= math.huge then return end
    local job = state.autokill
    rf.bagobserve(count, capacity, "event", count >= capacity)
    if farm.lastcount == nil or count > farm.lastcount then
      farm.eventstamp = (farm.eventstamp or 0) + 1
    end
    farm.lastcount = count
    if count >= capacity then
      if flags.autofarm and not farm.full then
        local session = farm.session
        local running = session and session.character == localplayer.Character
          and (session.stage == "moving" or session.stage == "touching")
        local recent = farm.lastcollectcharacter == localplayer.Character
          and farm.lastcollectround == state.roundstartedat
          and os.clock() - (farm.lastcollectmotion or 0) <= 2
        farm.fullshoteligible = running == true or recent == true
      end
      job.bagfull = state.bagstate.full
    end
  end))
end

function rf.autokillready()
  return flags.autokillall and state.alive and state.round and state.roundstartobserved
    and state.roundstartparticipant and not state.farmkilledround and rf.localisinround()
    and rf.localismurderer() and not rf.localisdead()
    and not state.endlock and not rf.victoryisshown()
    and (not config.autokillfullbag or rf.autokillbagfull())
end

function rf.autokillvalidtarget(candidate)
  if not candidate or candidate == localplayer or candidate.Parent ~= players then return nil end
  if state.synced and state.participants[candidate.UserId] ~= true then return nil end
  local character = candidate.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  local root = character and character:FindFirstChild("HumanoidRootPart")
  if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart")
    or not autokillfinite(root.Position) then return nil end
  local entry = state.authoritative[candidate.UserId]
  local record = rf.getrecord(candidate)
  if entry and (entry.Killed == true or entry.Dead == true or entry.Role == "Murderer") then return nil end
  if record and (record.Killed == true or record.Dead == true or record.Role == "Murderer"
    or record.Role == "Neutral") then return nil end
  return character, humanoid, root
end

function rf.autokillweapon()
  local character = localplayer.Character
  if not character then return nil end
  local backpack = localplayer:FindFirstChildOfClass("Backpack")
  for _, container in ipairs({character, backpack}) do
    if container then
      for _, tool in ipairs(container:GetChildren()) do
        if tool:IsA("Tool") and rf.isknifename(tool.Name) then return tool end
      end
    end
  end
  return nil
end

function rf.autokillstop(reason, restore)
  local job = state.autokill
  job.generation += 1
  local wasactive = job.active
  local character, root, humanoid = job.character, job.root, job.humanoid
  local canrestore = motionqueue.owner == "autokill" and job.roundserial == state.roundstartedat
    and rf.localisinround() and not rf.localisdead()
  job.active, job.target, job.targetcharacter = false, nil, nil
  rf.motionrelease("autokill", true)
  if humanoid and humanoid.Parent then
    if job.originalrotate ~= nil then pcall(function() humanoid.AutoRotate = job.originalrotate end) end
  end
  if root and root.Parent then
    if job.originaltouch ~= nil then pcall(function() root.CanTouch = job.originaltouch end) end
    if job.originalcollide ~= nil and not rf.noclipwanted() then
      pcall(function() root.CanCollide = job.originalcollide end)
    end
    if character == localplayer.Character then
      pcall(function()
        root.AssemblyAngularVelocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
      end)
      if restore and canrestore and config.autokillreturn and humanoid and humanoid.Health > 0
        and typeof(job.origin) == "CFrame" and autokillfinite(job.origin.Position) then
        pcall(function() rf.teleportpivot(character, job.origin) end)
      end
    end
  end
  job.character, job.root, job.humanoid, job.tool = nil, nil, nil, nil
  job.origin, job.originalrotate, job.originaltouch, job.originalcollide = nil, nil, nil, nil
  job.mode, job.started, job.targetstarted, job.lastattack, job.lasttouch = nil, 0, 0, 0, 0
  job.moved = false
  job.status = reason or "off"
  if wasactive and state.alive and rf.enforcenoclip then rf.enforcenoclip() end
end

function rf.autokilltarget()
  local job = state.autokill
  local localroot = localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
  local origin = (job.root or localroot) and (job.root or localroot).Position
  local selected, selectedcharacter, selectedroot, nearest
  local now = os.clock()
  local haseligible = false
  for _, candidate in ipairs(players:GetPlayers()) do
    local character, humanoid, root = rf.autokillvalidtarget(candidate)
    if character then
      haseligible = true
      if now >= (job.cooldown[character] or 0) then
        local distance = origin and (root.Position - origin).Magnitude or 0
        if not nearest or distance < nearest then
          selected, selectedcharacter, selectedroot, nearest = candidate, character, root, distance
        end
      end
    end
  end
  return selected, selectedcharacter, selectedroot, haseligible
end

function rf.autokillbegin(character, root, humanoid, tool)
  local job = state.autokill
  if not rf.autokillready() then return false end
  if tool.Parent ~= character and not config.autokillautoequip then
    job.status = "equip knife to start"
    return false
  end
  local originalcollide = state.noclip.originals[root]
  if originalcollide == nil then originalcollide = root.CanCollide end
  if not rf.motionacquire("autokill") then
    job.status = "waiting for movement priority"
    return false
  end
  if not root.Parent or not humanoid.Parent or humanoid.Health <= 0 then
    rf.motionrelease("autokill", true)
    return false
  end
  if tool.Parent ~= character then
    local ok = pcall(humanoid.EquipTool, humanoid, tool)
    if not ok or tool.Parent ~= character then
      job.status = "waiting for knife equip"
      rf.motionrelease("autokill", true)
      return false
    end
  end
  job.character, job.root, job.humanoid, job.tool = character, root, humanoid, tool
  job.origin, job.originalrotate = character:GetPivot(), humanoid.AutoRotate
  job.originaltouch, job.originalcollide = root.CanTouch, originalcollide
  job.roundserial, job.mode = state.roundstartedat, config.autokillmode
  job.active, job.started = true, os.clock()
  job.status = "finding targets"
  if job.mode ~= "Touch Interest" then
    humanoid.AutoRotate = false
    root.CanTouch = true
    root.CanCollide = false
  end
  return true
end

function rf.autokillmove(job, enemyroot, dt)
  local root, character = job.root, job.character
  if not root or not character or root.Parent ~= character or not enemyroot.Parent then return false end
  local delta = enemyroot.CFrame.LookVector
  local direction = Vector3.new(delta.X, 0, delta.Z)
  if direction.Magnitude < 0.01 then direction = Vector3.new(0, 0, 1) else direction = direction.Unit end
  local position = enemyroot.Position - direction * 0.8
  local facing = Vector3.new(enemyroot.Position.X, position.Y, enemyroot.Position.Z)
  if (facing - position).Magnitude < 0.01 then return false end
  local frame = CFrame.lookAt(position, facing)
  if not autokillfinite(position) or position.Y <= world.FallenPartsDestroyHeight + 6 then return false end
  if job.mode == "CFrame" then
    local distance = (position - root.Position).Magnitude
    local alpha = distance > 60 and 1 or math.min(1, math.max(0, dt) * 90 / math.max(distance, 0.01))
    frame = root.CFrame:Lerp(frame, alpha)
  elseif job.mode == "Teleport" and job.moved and (position - root.Position).Magnitude < 2 then
    return true
  end
  local offset = root.CFrame:ToObjectSpace(character:GetPivot())
  rf.teleportpivot(character, frame * offset)
  root.AssemblyLinearVelocity = Vector3.zero
  root.AssemblyAngularVelocity = Vector3.zero
  job.moved = true
  return true
end

function rf.autokillcontact(job, enemycharacter, enemyroot, now)
  local tool = job.tool
  if not tool or tool.Parent ~= job.character or not tool.Enabled then return false end
  if config.autokillactivate and now - job.lastattack >= 0.14 then
    job.lastattack = now
    pcall(function() tool:Activate() end)
    job.attempts += 1
  end
  if now - job.lasttouch < 0.07 then return true end
  if job.mode ~= "Touch Interest" and (enemyroot.Position - job.root.Position).Magnitude > 5 then
    return true
  end
  job.lasttouch = now
  local touch = type(firetouchinterest) == "function" and firetouchinterest
    or type(env.firetouchinterest) == "function" and env.firetouchinterest or nil
  if type(touch) ~= "function" then return job.mode ~= "Touch Interest" end
  local blade = tool:FindFirstChild("Handle", true)
  if not blade or not blade:IsA("BasePart") then blade = tool:FindFirstChildWhichIsA("BasePart", true) end
  if not blade then return false end
  local targets = {}
  for _, name in ipairs({"UpperTorso", "Torso", "HumanoidRootPart", "Head"}) do
    local part = enemycharacter:FindFirstChild(name)
    if part and part:IsA("BasePart") and part.Parent then
      targets[#targets + 1] = part
    end
  end
  if #targets == 0 then targets[1] = enemyroot end
  local contacted = false
  for _, part in ipairs(targets) do
    local ok = pcall(touch, blade, part, 0)
    if ok then
      pcall(touch, blade, part, 1)
      contacted = true
    end
  end
  return contacted or job.mode ~= "Touch Interest"
end

function rf.stepautokill(dt)
  local job = state.autokill
  if not flags.autokillall then
    if job.active then rf.autokillstop("off", true) else job.status = "off" end
    return
  end
  if not state.round or not state.roundstartobserved or not state.roundstartparticipant
    or not rf.localisinround() then
    if job.active then rf.autokillstop("waiting for participating round", false)
    else job.status = "waiting for participating round" end
    return
  end
  if not rf.localismurderer() then
    if job.active then rf.autokillstop("waiting for murderer role", false)
    else job.status = "waiting for murderer role" end
    return
  end
  if config.autokillfullbag and not rf.autokillbagfull() then
    if job.active then rf.autokillstop("waiting for full coin bag", true)
    else job.status = "waiting for full coin bag" end
    return
  end
  if not rf.autokillready() then
    if job.active then rf.autokillstop("round or character unavailable", false)
    else job.status = "round or character unavailable" end
    return
  end
  local character = localplayer.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  local root = character and character:FindFirstChild("HumanoidRootPart")
  if not humanoid or humanoid.Health <= 0 or not root
    or (root.Anchored and not farm.hide) or not autokillfinite(root.Position) then
    if job.active then rf.autokillstop("waiting for live character", false)
    else job.status = "waiting for live character" end
    return
  end
  if config.autokillmode == "Touch Interest"
    and type(firetouchinterest) ~= "function" and type(env.firetouchinterest) ~= "function" then
    if job.active then rf.autokillstop("touch function unavailable", true)
    else job.status = "touch function unavailable" end
    return
  end
  local tool = rf.autokillweapon()
  if not tool then
    if job.active then rf.autokillstop("knife unavailable", true) else job.status = "knife unavailable" end
    return
  end
  if job.active and (job.character ~= character or job.root ~= root or job.humanoid ~= humanoid
    or job.mode ~= config.autokillmode or job.roundserial ~= state.roundstartedat) then
    rf.autokillstop("character or mode changed", false)
  end
  if job.active and rf.motionowner() ~= "autokill" then
    if not rf.motionacquire("autokill") then
      job.status = "waiting for movement priority"
      return
    end
  end
  if not job.active then
    local candidate, _, _, haseligible = rf.autokilltarget()
    if not candidate then
      job.status = haseligible and "waiting for target retry" or "no living round targets"
      return
    end
    if not rf.autokillbegin(character, root, humanoid, tool) then return end
  end
  if not tool.Parent or tool.Parent ~= character then
    if config.autokillautoequip then
      pcall(humanoid.EquipTool, humanoid, tool)
    end
    if tool.Parent ~= character then
      if not config.autokillautoequip then rf.autokillstop("knife unequipped", true)
      else job.status = "waiting for knife equip" end
      return
    end
  end
  job.tool = tool
  local now = os.clock()
  local targetcharacter = job.targetcharacter
  local target = job.target
  if target then
    local validcharacter, _, enemyroot = rf.autokillvalidtarget(target)
    if validcharacter ~= targetcharacter or not enemyroot then
      job.completed += 1
      job.cooldown[targetcharacter] = now + 0.6
      job.target, job.targetcharacter = nil, nil
      target, targetcharacter = nil, nil
    elseif now - job.targetstarted > 0.6 then
      job.cooldown[targetcharacter] = now + 0.75
      job.target, job.targetcharacter = nil, nil
      target, targetcharacter = nil, nil
    end
  end
  if not target then
    local chosen, chosencharacter, _, haseligible = rf.autokilltarget()
    if not chosen then
      if not haseligible then
        rf.autokillstop("no living round targets", true)
      else
        job.status = "waiting for target retry"
      end
      return
    end
    job.target, job.targetcharacter, job.targetstarted = chosen, chosencharacter, now
    job.lastattack, job.lasttouch, job.moved = 0, 0, false
    target, targetcharacter = chosen, chosencharacter
  end
  local confirmedcharacter, _, enemyroot = rf.autokillvalidtarget(target)
  if not confirmedcharacter or confirmedcharacter ~= targetcharacter or not enemyroot then return end
  if not root.Parent or not tool.Parent or not rf.autokillready() then
    rf.autokillstop("interrupted", false)
    return
  end
  if job.mode ~= "Touch Interest" then
    humanoid.AutoRotate = false
    root.CanTouch = true
    root.CanCollide = false
    if not rf.autokillmove(job, enemyroot, dt) then
      job.cooldown[targetcharacter] = now + 1
      job.target, job.targetcharacter = nil, nil
      job.status = "unsafe target position"
      return
    end
  end
  local ok = rf.autokillcontact(job, targetcharacter, enemyroot, now)
  job.status = ok and ("attacking " .. target.Name .. " / " .. job.mode) or "waiting for knife contact"
end

function rf.stepknifeall(dt)
  local job = state.knifeall
  if state.autofling and state.autofling.active then
    job.status = "paused for auto fling"
    return
  elseif rf.motionowner() == "autokill" then
    job.status = "paused for auto kill all"
    return
  end
  if not flags.knifeall then
    job.status = "off"
    return
  end
  if type(firetouchinterest) ~= "function" then
    job.status = "touch function unavailable"
    return
  end
  if not state.round or not rf.localisinround() or not rf.localismurderer()
    or rf.localisdead() or rf.victoryisshown() or state.pickupbusy then
    job.status = "waiting for murderer round"
    return
  end
  if os.clock() - job.last < math.max(0.1, tonumber(config.knifeallinterval) or 0.18) then return end
  job.last = os.clock()
  local character = localplayer.Character
  if not character then return end
  local knife
  for _, item in ipairs(character:GetChildren()) do
    if item:IsA("Tool") and rf.isknifename(item.Name) then
      knife = item
      break
    end
  end
  if not knife then
    local backpack = localplayer:FindFirstChildOfClass("Backpack")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if backpack and humanoid then
      for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") and rf.isknifename(item.Name) then
          pcall(humanoid.EquipTool, humanoid, item)
          break
        end
      end
    end
    job.status = "equipping knife"
    return
  end
  local blade = knife:FindFirstChild("Handle")
  if not blade or not blade:IsA("BasePart") then
    blade = knife:FindFirstChildWhichIsA("BasePart", true)
  end
  if not blade then job.status = "knife handle missing" return end
  local targets = {}
  for _, player in ipairs(players:GetPlayers()) do
    if player ~= localplayer and player.Character then
      local human = player.Character:FindFirstChildOfClass("Humanoid")
      local part = player.Character:FindFirstChild("HumanoidRootPart")
        or player.Character:FindFirstChild("UpperTorso")
        or player.Character:FindFirstChild("Torso")
      local role = rf.getrecord(player)
      if human and human.Health > 0 and part and part:IsA("BasePart")
        and (not role or role.Dead ~= true and role.Killed ~= true) then
        targets[#targets + 1] = part
      end
    end
  end
  if #targets == 0 then job.status = "no live targets" return end
  job.index = job.index % #targets + 1
  local target = targets[job.index]
  local originalsize = blade.Size
  local originalcollide = blade.CanCollide
  local ok = pcall(function()
    blade.CanCollide = false
    blade.Size = Vector3.new(
      math.min(originalsize.X * 5, 32),
      math.min(originalsize.Y * 5, 32),
      math.min(originalsize.Z * 5, 32)
    )
    firetouchinterest(blade, target, 0)
    firetouchinterest(blade, target, 1)
  end)
  pcall(function()
    if blade and blade.Parent then
      blade.Size = originalsize
      blade.CanCollide = originalcollide
    end
  end)
  if ok then
    job.attempts += 1
    job.status = "contacting players"
  else
    job.status = "knife contact failed"
  end
end

function rf.stepflinglog()
  local log = state.flinglog
  if not config.flinglogs or not config.notifications then
    if next(log.players) then table.clear(log.players) end
    return
  end
  local now = os.clock()
  if now < log.nextscan then return end
  log.nextscan = now + 0.25
  local character = localplayer.Character
  local root = character and character:FindFirstChild("HumanoidRootPart")
  if not root or not root:IsA("BasePart") then table.clear(log.players); return end
  local velocity, angular = root.AssemblyLinearVelocity, root.AssemblyAngularVelocity
  if not finitevector(velocity) or not finitevector(angular) then return end
  local previous = log.players[localplayer.UserId]
  log.players[localplayer.UserId] = {character = character, velocity = velocity, time = now}
  if previous and previous.character == character and now - previous.time < 1
    and not rf.motionowner() and (velocity - previous.velocity).Magnitude > 80
    and (velocity.Magnitude > 100 or angular.Magnitude > 45)
    and now - (log.lastnotice or -math.huge) > 10 then
    log.lastnotice = now
    rf.notification("Physics warning", "Local velocity spike detected; source unknown", localplayer.UserId,
      "alert-triangle", Color3.fromRGB(255, 160, 90), "physics:local")
  end
end

function rf.stepantifling(dt)
  local guard = state.antifling
  if not config.antifling or not state.alive then return end
  local character = localplayer.Character
  local root = character and character:FindFirstChild("HumanoidRootPart")
  local human = character and character:FindFirstChildOfClass("Humanoid")
  if not root or not human or human.Health <= 0 or root.Anchored then
    guard.character, guard.root, guard.safe, guard.lastvelocity = nil, nil, nil, nil
    return
  end
  local now = os.clock()
  if guard.root ~= root then
    guard.character, guard.root, guard.lastvelocity = character, root, nil
    guard.safe, guard.lastposition, guard.dangeruntil = nil, nil, 0
    guard.nextscan, guard.lastcheck = 0, 0
  end
  local function finite(vector)
    return vector.X == vector.X and vector.Y == vector.Y and vector.Z == vector.Z
      and math.abs(vector.X) < 1e12 and math.abs(vector.Y) < 1e12
      and math.abs(vector.Z) < 1e12
  end
  local position = root.Position
  local velocity = root.AssemblyLinearVelocity
  local rotation = root.AssemblyAngularVelocity
  local activefling = state.autofling and state.autofling.active
  if activefling then
    if not finite(position) or not finite(velocity) or not finite(rotation)
      or position.Y <= world.FallenPartsDestroyHeight + 45 then
      rf.flingfinish("Unsafe local physics")
    end
    return
  end
  if rf.voidteleportactive(character) and finite(position) and finite(velocity) and finite(rotation)
    and position.Y > world.FallenPartsDestroyHeight + 22 then
    guard.safe = nil
    guard.lastvelocity = velocity
    guard.lastposition = position
    guard.dangeruntil = 0
    return
  end
  local valid = finite(position) and finite(velocity) and finite(rotation)
  local speed = valid and velocity.Magnitude or math.huge
  local spin = valid and rotation.Magnitude or math.huge
  local owner = rf.motionowner()
  local owned = owner ~= nil or state.pickupbusy or farm.session ~= nil
    or state.autokill.active or state.autofling and state.autofling.active
  local nearthreat = now < (guard.dangeruntil or 0)
  if now >= (guard.nextscan or 0) then
    guard.nextscan = now + 0.15
    for _, candidate in ipairs(players:GetPlayers()) do
      if candidate ~= localplayer and candidate.Character then
        local enemy = candidate.Character:FindFirstChild("HumanoidRootPart")
        if enemy and enemy:IsA("BasePart") then
          local offset = enemy.Position - position
          if offset.Magnitude < 24 then
            local enemyvelocity = enemy.AssemblyLinearVelocity
            local enemyrotation = enemy.AssemblyAngularVelocity
            if finite(enemyvelocity) and finite(enemyrotation)
              and (enemyvelocity.Magnitude > 65 or enemyrotation.Magnitude > 17
                or (enemyvelocity - velocity).Magnitude > 95) then
              nearthreat = true
              guard.dangeruntil = now + 0.45
              break
            end
          end
        end
      end
    end
    if not nearthreat and type(world.GetPartBoundsInRadius) == "function" then
      if not guard.overlap or guard.overlapcharacter ~= character then
        guard.overlap = OverlapParams.new()
        guard.overlap.FilterType = Enum.RaycastFilterType.Exclude
        guard.overlap.FilterDescendantsInstances = {character}
        guard.overlap.MaxParts = 32
        guard.overlapcharacter = character
      end
      local overlap = guard.overlap
      local ok, nearby = pcall(world.GetPartBoundsInRadius, world, position, 12, overlap)
      if ok then
        for _, part in ipairs(nearby) do
          if part:IsA("BasePart") and not part.Anchored and part.CanCollide then
            local push = part.AssemblyLinearVelocity
            local spinvelocity = part.AssemblyAngularVelocity
            if finite(push) and finite(spinvelocity)
              and (push.Magnitude > 95 or spinvelocity.Magnitude > 25) then
              nearthreat = true
              guard.dangeruntil = now + 0.35
              break
            end
          end
        end
      end
    end
  end
  local movingfast = guard.lastvelocity and valid
    and (velocity - guard.lastvelocity).Magnitude / math.max(dt, 1 / 240) > 1400
  local limit = math.max(70, tonumber(config.antiflingvelocity) or 160)
  local spinlimit = math.max(12, tonumber(config.antiflingrotation) or 45)
  local hard = not valid or speed > math.max(450, limit * 3)
    or spin > math.max(110, spinlimit * 3)
  local collision = not owned and (nearthreat or movingfast) and
    (speed > math.min(limit, 85) or spin > math.min(spinlimit, 20))
  local dangerous = hard or collision
  local voidheight = world.FallenPartsDestroyHeight
  local below = valid and position.Y < voidheight + 22
  if not owned and valid and human.FloorMaterial ~= Enum.Material.Air
    and speed < 42 and spin < 12 and position.Y > voidheight + 55 and not nearthreat then
    if now - guard.lastcheck >= 0.15 then
      guard.safe = character:GetPivot()
      guard.lastcheck = now
      guard.saferound = state.roundstartedat
      guard.safemap = state.maproot
    end
  end
  if not dangerous and not below then
    guard.lastvelocity, guard.lastposition = valid and velocity or nil, position
    return
  end
  local horizontal = valid and Vector3.new(velocity.X, 0, velocity.Z) or Vector3.zero
  local horizontalcap = nearthreat and 40 or math.min(limit, 75)
  if owned and not below then horizontalcap = math.max(limit, 190) end
  if horizontal.Magnitude > horizontalcap then horizontal = horizontal.Unit * horizontalcap end
  local upcap = nearthreat and 45 or 70
  local downcap = nearthreat and -65 or -95
  local vertical = valid and math.clamp(velocity.Y, downcap, upcap) or 0
  root.AssemblyLinearVelocity = horizontal + Vector3.new(0, vertical, 0)
  if spin > 12 or not valid then root.AssemblyAngularVelocity = Vector3.zero end
  guard.blocks = (guard.blocks or 0) + 1
  guard.lastvelocity = root.AssemblyLinearVelocity
  local reference = guard.safe
  if guard.saferound ~= state.roundstartedat or guard.safemap ~= state.maproot then
    reference = nil
  end
  if not reference then
    local safe = state.voidsafe
    reference = safe.checkpointmap == state.maproot
      and safe.checkpointround == state.roundstartedat and safe.checkpoint
      or safe.maproot == state.maproot and safe.round == state.roundstartedat and safe.mapframe
      or safe.lobbyframe
  end
  if (below or not valid or not owned and reference and (position - reference.Position).Magnitude > 75
    and (nearthreat or dangerous)) and typeof(reference) == "CFrame" and config.antiflingreturn then
    pcall(function()
      root.AssemblyLinearVelocity = Vector3.zero
      root.AssemblyAngularVelocity = Vector3.zero
      rf.teleportpivot(character, reference)
      if human:GetState() == Enum.HumanoidStateType.Ragdoll
        or human:GetState() == Enum.HumanoidStateType.FallingDown then
        human:ChangeState(Enum.HumanoidStateType.GettingUp)
      end
    end)
    guard.lastvelocity = Vector3.zero
    guard.lastposition = reference.Position
    guard.dangeruntil = now + 0.5
    return
  end
  guard.lastposition = position
end

local fling = {murderer = false, sheriff = false, active = false, status = "idle",
  target = nil, targetcharacter = nil, role = nil, origin = nil,
  character = nil, root = nil, humanoid = nil, home = nil, homeround = nil,
  homemap = nil, parts = {}, rootcantouch = nil, humanautorotate = nil,
  eligibleat = 0, eligibilitytarget = nil, eligibilitycharacter = nil,
  eligibilityrole = nil, eligibilityround = nil, nexttargetscan = 0,
  cachedtarget = nil, cachedrole = nil, cachedroot = nil, started = 0,
  phase = 0, nextguncheck = 0, originalcarrier = nil, carrierlost = false,
  sawdrop = false, lasttargetpoint = nil, follows = 0}
state.autofling = fling

function rf.flingsyncbuttons()
  if not state.flingbuttons then return end
  for role, button in pairs(state.flingbuttons) do
    button.setlabel("Auto Fling " .. (role == "murderer" and "Murderer" or "Sheriff")
      .. (fling[role] and " [ON]" or " [OFF]"))
    button.setselected(fling[role])
  end
end

function rf.flingrestoreparts()
  for part, collide in pairs(fling.parts) do
    if part.Parent then pcall(function() if part.CanCollide == true then part.CanCollide = collide end end) end
    fling.parts[part] = nil
  end
  local root = fling.root
  if root and root.Parent and fling.rootcantouch ~= nil then
    pcall(function() if root.CanTouch == true then root.CanTouch = fling.rootcantouch end end)
  end
  local humanoid = fling.humanoid
  if humanoid and humanoid.Parent and fling.humanautorotate ~= nil then
    pcall(function() if humanoid.AutoRotate == false then humanoid.AutoRotate = fling.humanautorotate end end)
  end
end

function rf.flingstop(reason, restore)
  local active = fling.active
  local character, root, home = fling.character, fling.root, fling.home
  local sameround = fling.homeround == state.roundstartedat and fling.homemap == state.maproot
  fling.active = false
  fling.status = reason or "idle"
  fling.eligibilitytarget, fling.eligibilitycharacter = nil, nil
  fling.eligibilityrole, fling.eligibilityround, fling.eligibleat = nil, nil, 0
  fling.nexttargetscan = 0
  fling.cachedtarget, fling.cachedrole, fling.cachedroot = nil, nil, nil
  fling.nextguncheck, fling.originalcarrier = 0, nil
  fling.carrierlost, fling.sawdrop = false, false
  rf.flingrestoreparts()
  if active and root and root.Parent and character and character.Parent then
    pcall(function()
      root.AssemblyLinearVelocity = Vector3.zero
      root.AssemblyAngularVelocity = Vector3.zero
    end)
    if restore and sameround and character == localplayer.Character and home
      and fling.humanoid and fling.humanoid.Health > 0 then
      local ok, restored = pcall(rf.teleportpivot, character, home, 0.8)
      if not ok or not restored then rf.recorderror("fling:restore", "Home restoration failed") end
    end
  end
  fling.target, fling.targetcharacter, fling.role, fling.origin = nil, nil, nil, nil
  fling.character, fling.root, fling.humanoid, fling.home = nil, nil, nil, nil
  fling.homeround, fling.homemap = nil, nil
  fling.rootcantouch, fling.humanautorotate = nil, nil
  fling.phase, fling.started, fling.lasttargetpoint, fling.follows = 0, 0, nil, 0
  if motionqueue.owner == "autofling" then rf.motionrelease("autofling", true) end
  if active then
    local guard = state.antifling
    guard.safe, guard.lastvelocity, guard.lastposition = nil, nil, nil
    guard.dangeruntil, guard.nextscan, guard.pairclock = 0, 0, 0
    local safe = state.voidsafe
    safe.cooldown = math.max(safe.cooldown or 0, os.clock() + 1)
    safe.fallstarted, safe.nextcheck = nil, 0
    rf.updatecollisions()
    if reason and reason ~= "off" and reason ~= "switching target" then
      rf.notification("Auto Fling", reason, nil, "shield-alert",
        Color3.fromRGB(218, 187, 243), "fling:stop:" .. tostring(os.clock()))
    end
  end
end

function rf.flingfinish(reason)
  local role = fling.role
  if role then fling[role] = false end
  rf.flingstop(reason, true)
  rf.flingsyncbuttons()
end

function rf.flingtoggle(role)
  if role ~= "murderer" and role ~= "sheriff" then return end
  fling[role] = not fling[role]
  if fling.active and fling.role == role and not fling[role] then
    rf.flingstop("off", true)
  else
    fling.eligibilitytarget, fling.eligibilitycharacter = nil, nil
    fling.eligibilityrole, fling.eligibilityround, fling.eligibleat = nil, nil, 0
    fling.nexttargetscan = 0
  end
  if not fling.murderer and not fling.sheriff and fling.active then rf.flingstop("off", true) end
  rf.flingsyncbuttons()
  rf.notification("Auto Fling " .. (role == "murderer" and "Murderer" or "Sheriff"),
    fling[role] and "Enabled" or "Disabled", nil,
    fling[role] and "check-circle" or "circle-off",
    Color3.fromRGB(218, 187, 243), "fling:toggle:" .. role .. ":" .. tostring(os.clock()))
end

function rf.flingcandidate(player, role)
  if not player or player == localplayer or not fling[role] then return nil end
  local character = player.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  local root = character and character:FindFirstChild("HumanoidRootPart")
  if not character or not character.Parent or not humanoid or humanoid.Health <= 0
    or not root or not root.Parent or not root:IsA("BasePart") then return nil end
  local actual, _, dead = rf.playerlistrole(player)
  if actual ~= (role == "murderer" and "Murderer" or "Sheriff") or dead then return nil end
  return character, root
end

function rf.flingtarget()
  local now = os.clock()
  if now < fling.nexttargetscan then
    local target, role, root = fling.cachedtarget, fling.cachedrole, fling.cachedroot
    if target and role then
      local character, currentroot = rf.flingcandidate(target, role)
      if character and currentroot == root then return target, role, root end
    end
    return nil
  end
  fling.nexttargetscan = now + 0.08
  fling.cachedtarget, fling.cachedrole, fling.cachedroot = nil, nil, nil
  for _, role in ipairs({"murderer", "sheriff"}) do
    if fling[role] then
      for _, player in ipairs(players:GetPlayers()) do
        local character, root = rf.flingcandidate(player, role)
        if character then
          fling.cachedtarget, fling.cachedrole, fling.cachedroot = player, role, root
          return player, role, root
        end
      end
    end
  end
  return nil
end

function rf.flingguncollected(now)
  if now < fling.nextguncheck then return false end
  fling.nextguncheck = now + 0.12
  local carrier = rf.guncarrier()
  local id = carrier and carrier.UserId or nil
  if id then
    if fling.sawdrop or fling.originalcarrier and fling.carrierlost
      and id ~= fling.originalcarrier then return true end
    if not fling.originalcarrier then fling.originalcarrier = id end
    return false
  end
  if fling.originalcarrier then fling.carrierlost = true end
  local source, part, proof = state.dropinstance, state.droppart, state.dropproof
  local verified = source and part and proof and rf.validgundrop(source, part, proof)
  if not verified then
    local _, candidate, candidatepart, _, evidence = rf.droppedgunposition()
    verified = candidate and candidatepart and evidence
      and rf.validgundrop(candidate, candidatepart, evidence)
  end
  if verified then fling.sawdrop = true end
  return false
end

function rf.flingbegin(target, role, targetroot, now)
  local character = localplayer.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  local root = character and character:FindFirstChild("HumanoidRootPart")
  if not character or not character.Parent or not humanoid or humanoid.Health <= 0
    or not root or not root.Parent or not root:IsA("BasePart") then return false end
  if not rf.motionacquire("autofling") then return false end
  rf.stopnoclip()
  rf.restorecollisions()
  if rf.motionclearreturn then rf.motionclearreturn() end
  fling.active, fling.status = true, "following target"
  fling.target, fling.targetcharacter, fling.role = target, target.Character, role
  fling.origin, fling.character, fling.root, fling.humanoid = targetroot.Position, character, root, humanoid
  fling.home, fling.homeround, fling.homemap = character:GetPivot(), state.roundstartedat, state.maproot
  fling.parts, fling.rootcantouch, fling.humanautorotate = {}, root.CanTouch, humanoid.AutoRotate
  fling.started, fling.phase, fling.follows = now, 0, 0
  fling.lasttargetpoint, fling.nextguncheck = targetroot.Position, 0
  local holder = rf.guncarrier()
  fling.originalcarrier = holder and holder.UserId or nil
  fling.carrierlost, fling.sawdrop = false, false
  humanoid.AutoRotate = false
  root.CanTouch = true
  for _, name in ipairs({"HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "Head"}) do
    local part = character:FindFirstChild(name)
    if part and part:IsA("BasePart") then
      fling.parts[part] = part.CanCollide
      part.CanCollide = true
    end
  end
  return true
end

function rf.flingdrive(dt, targetroot)
  local root, character = fling.root, fling.character
  if not root or not root.Parent or not character or character ~= localplayer.Character then return false end
  fling.phase = (fling.phase + 1) % 8
  local phase = fling.phase
  local velocity = targetroot.AssemblyLinearVelocity
  local speed = velocity.Magnitude
  if speed > 140 then velocity = velocity.Unit * 140 end
  local lead = math.clamp(dt * 0.8, 0.008, 0.04)
  local targetframe = targetroot.CFrame
  local radial = ({0.3, -0.3, 0.6, -0.6, 0.2, -0.2, 0.45, -0.45})[phase + 1]
  local height = phase % 2 == 0 and 0.2 or -0.2
  local position = targetroot.Position + velocity * lead
    + targetframe.RightVector * radial + Vector3.new(0, height, 0)
  if not rf.teleportpivot(character, CFrame.new(position) * targetframe.Rotation, 0.4) then return false end
  local sign = phase % 2 == 0 and 1 or -1
  local thrust = targetframe.LookVector * (sign * 1900)
    + targetframe.RightVector * (phase < 4 and 1500 or -1500)
    + Vector3.new(0, sign * 1800, 0)
  root.AssemblyLinearVelocity = thrust + velocity * 2
  root.AssemblyAngularVelocity = Vector3.new(sign * 900, 1600, -sign * 900)
  fling.lasttargetpoint = targetroot.Position
  fling.follows = fling.follows + 1
  return true
end

function rf.stepautofling(dt)
  if not state.alive or not (fling.murderer or fling.sheriff) then
    if fling.active then rf.flingstop("off", true) end
    return
  end
  if not state.round or state.endlock or not state.roundstartobserved
    or state.roundstartedat <= 0 then
    if fling.active then rf.flingstop("waiting for next round", true) end
    fling.eligibilitytarget, fling.eligibilitycharacter = nil, nil
    fling.eligibilityrole, fling.eligibilityround, fling.eligibleat = nil, nil, 0
    return
  end
  local now = os.clock()
  if fling.active then
    if now - fling.started >= 8 then rf.flingfinish("Movement timed out"); return end
    if not fling.root or not fling.root.Parent or not finitevector(fling.root.Position)
      or not finitevector(fling.root.AssemblyLinearVelocity) or not finitevector(fling.root.AssemblyAngularVelocity)
      or fling.root.Position.Y <= world.FallenPartsDestroyHeight + 45 then
      rf.flingfinish("Unsafe local position"); return
    end
    if fling.homeround ~= state.roundstartedat or fling.homemap ~= state.maproot then
      rf.flingstop("round or map changed", false)
      return
    end
    local target, character = fling.target, fling.targetcharacter
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = fling.humanoid
    if not target or not character or not character.Parent or not root or not root.Parent
      or target.Character ~= character or not humanoid or humanoid.Health <= 0
      or localplayer.Character ~= fling.character or not fling.root or not fling.root.Parent then
      rf.flingstop("target or local character unavailable", true)
      return
    end
    local eligible, currentroot = rf.flingcandidate(target, fling.role)
    if eligible ~= character or currentroot ~= root then rf.flingfinish("Target no longer eligible"); return end
    if not root:IsA("BasePart") or not finitevector(root.Position) or not finitevector(root.AssemblyLinearVelocity) then
      rf.flingfinish("Invalid target physics"); return
    end
    if fling.origin and (root.Position - fling.origin).Magnitude >= 1000 then
      rf.flingfinish("Target displacement observed; cause unverified")
      return
    end
    if rf.flingguncollected(now) then
      rf.flingfinish("Dropped gun picked up")
      return
    end
    if rf.motionowner() ~= "autofling" then
      rf.flingstop("movement interrupted", true)
      return
    end
    if not rf.flingdrive(dt, root) then rf.flingstop("follow unavailable", true) end
    return
  end
  local target, role, root = rf.flingtarget()
  if not target then
    fling.eligibilitytarget, fling.eligibilitycharacter = nil, nil
    fling.eligibilityrole, fling.eligibilityround, fling.eligibleat = nil, nil, 0
    fling.status = "waiting for target"
    return
  end
  local character = target.Character
  if fling.eligibilitytarget ~= target or fling.eligibilitycharacter ~= character
    or fling.eligibilityrole ~= role or fling.eligibilityround ~= state.roundstartedat then
    fling.eligibilitytarget, fling.eligibilitycharacter = target, character
    fling.eligibilityrole, fling.eligibilityround = role, state.roundstartedat
    fling.eligibleat = now + 2.5
  end
  if now < fling.eligibleat then
    fling.status = "waiting 2.5 seconds"
    return
  end
  if rf.flingbegin(target, role, root, now) then
    if not rf.flingdrive(dt, root) then rf.flingfinish("Initial movement failed") end
  else
    fling.status = "waiting for movement"
  end
end
rf.resources.timers = {}
local function due(name, dt, interval)
  local elapsed = (rf.resources.timers[name] or 0) + dt
  if elapsed < interval then rf.resources.timers[name] = elapsed return false end
  rf.resources.timers[name] = elapsed % interval
  return true
end
local function interval(value, default, minimum, maximum)
  return math.clamp(finitenumber(value) and value or default, minimum, maximum)
end
local function simstep(dt)
  if not state.alive or state.stopping then return end
  dt = interval(dt, 1 / 60, 0, 0.25)
  if farm.session and farm.session.poststep then rf.safe("farm:physics", farm.session.poststep) end
  if due("motion", dt, 0.016) then rf.safe("motion", rf.updatemotion) end
  if due("speed", dt, 0.1) then rf.safe("walkspeed", rf.enforcewalkspeed) end
  if state.autoshoothover then rf.safe("hover", rf.autoshoothoverstep, dt) end
  rf.safe("noclip", rf.enforcenoclip)
  rf.safe("antifling", rf.stepantifling, dt)
  if fling.active or fling.murderer or fling.sheriff then
    local ok, reason = rf.safe("fling", rf.stepautofling, dt)
    if not ok then rf.safe("flingcleanup", rf.flingfinish, "Movement error: " .. tostring(reason):sub(1, 80)) end
  end
  if next(state.rolehitboxrecords) then rf.safe("hitboxes", rf.updaterolehitboxes, dt) end
  if due("victory", dt, 0.1) then rf.safe("victory", rf.victoryisshown) end
  if config.autoshootwhenfull then rf.safe("autoshoot", rf.autoshoot, dt) end
  if not fling.active then
    local killok, killerror = rf.safe("autokill", rf.stepautokill, dt)
    if not killok then rf.safe("autokillcleanup", rf.autokillstop, "kill action error: " .. tostring(killerror):sub(1, 80), true) end
  end
  if fling.active then
    rf.safe("void", rf.voidstep, dt)
  elseif rf.motionowner() == "autokill" then
    rf.safe("void", rf.voidstep, dt)
    state.antifling.safe = nil
  else
    rf.safe("pickup", rf.steppickup, dt)
    local voidok, recovered = rf.safe("void", rf.voidstep, dt)
    if state.pickupbusy then
      state.antifling.safe = nil
    elseif voidok and not recovered then
      rf.safe("farm", rf.stepautofarm, dt)
    end
  end
  if not fling.active and not state.pickupbusy then rf.safe("knife", rf.stepknifeall, dt) end
  if not config.autoshootwhenfull then rf.safe("autoshoot", rf.autoshoot, dt) end
end
rf.resources.backgroundjobs = {
  {name = "drop", interval = 0.07, run = function()
    if state.dropdirty then state.dropdirty = false; state.nextdropscan = 0; rf.scangunpickup(); rf.updategunmarker() end
  end},
  {name = "role_retry", interval = 2, run = function()
    if not state.synced and not state.endlock and not state.rolefetchpending then rf.defer(rf.fetchroles) end
  end},
  {name = "ping", interval = 0.5, run = function()
    local ok, ping = pcall(localplayer.GetNetworkPing, localplayer)
    if ok and finitenumber(ping) then state.ping = math.clamp(ping, 0, 0.3) end
  end},
  {name = "pickup_scan", interval = function() return interval(config.pickupsearchinterval, 0.07, 0.05, 0.35) end, run = rf.scangunpickup},
  {name = "gun_track", interval = function() return interval(config.guntrackinterval, 0.08, 0.05, 5) end, run = rf.trackassignedgun},
  {name = "roles", interval = function() return interval(config.rolecheck, 0.2, 0.12, 5) end, run = rf.inferroles},
  {name = "visuals", interval = function() return interval(config.refresh, 0.2, 0.08, 5) end, run = function() rf.refreshvisuals(); rf.updategunmarker(); rf.updatehud() end},
  {name = "collisions", interval = 0.35, run = rf.updatecollisions},
  {name = "flinglog", interval = 0.25, run = rf.stepflinglog},
  {name = "prune_tools", interval = 2, run = function()
    for tool, connection in pairs(state.gunactivationconnections) do
      if not tool.Parent then disconnect(connection); state.gunactivationconnections[tool] = nil end
    end
    for token, thread in pairs(rf.resources.tasks) do
      if type(thread) == "thread" and coroutine.status(thread) == "dead" then rf.resources.tasks[token] = nil end
    end
  end}
}
rf.resources.jobcursor = 1
function rf.backgroundstep()
  local jobs = rf.resources.backgroundjobs
  local deadline = os.clock() + 0.0015
  local now = os.clock()
  for _ = 1, #jobs do
    local index = rf.resources.jobcursor
    local job = jobs[index]
    rf.resources.jobcursor = index % #jobs + 1
    if now >= (job.nexttime or 0) then
      local period = type(job.interval) == "function" and job.interval() or job.interval
      job.nexttime = now + period
      local ok = rf.safe("background:" .. job.name, job.run)
      if ok then job.failures = 0 else
        job.failures = (job.failures or 0) + 1
        job.nexttime = now + math.min(30, 2 ^ math.min(job.failures, 5))
      end
    end
    if os.clock() >= deadline then break end
  end
end
rf.resources.simbusy = false
state.metrics = {simms = 0, samples = 0, frames = {}, index = 0, jobs = {}}
api.functions.diagnostics = function()
  local metrics = state.metrics
  local values = table.clone(metrics.frames)
  table.sort(values)
  local total = 0
  for _, value in ipairs(values) do total += value end
  local count = #values
  local tail, tailcount = 0, math.max(1, math.ceil(count * 0.01))
  for i = math.max(1, count - tailcount + 1), count do tail += values[i] end
  local pending, connections, jobs = 0, 0, {}
  for _ in pairs(rf.resources.tasks) do pending += 1 end
  for _, connection in ipairs(state.connections) do if connection.Connected then connections += 1 end end
  for _, group in pairs(state.characterconnections) do for _, connection in ipairs(group) do if connection.Connected then connections += 1 end end end
  for _, group in pairs(rf.resources.playerconnections or {}) do for _, connection in ipairs(group) do if connection.Connected then connections += 1 end end end
  for _, connection in pairs(state.gunactivationconnections) do if connection.Connected then connections += 1 end end
  for _, tracking in pairs(rf.resources.votefadetracking) do
    for _, connection in ipairs(tracking.connections) do if connection.Connected then connections += 1 end end
  end
  for _, visual in pairs(state.coinvisuals) do
    for _, link in ipairs(visual.links) do if link.connection and link.connection.Connected then connections += 1 end end
  end
  for name, entry in pairs(metrics.jobs) do jobs[name] = {calls = entry.calls, meanms = entry.total / entry.calls, peakms = entry.peak, errors = entry.errors} end
  return {fps = state.performance.fps, tier = state.performance.tier,
    averagefps = count > 0 and total > 0 and 1000 * count / total or nil,
    lowfps = tail > 0 and 1000 * tailcount / tail or nil,
    p99ms = values[math.max(1, math.ceil(count * 0.99))], worstms = values[count],
    simulationms = metrics.simms, samples = metrics.samples, connections = connections,
    pendingtasks = pending, jobs = jobs, sampleframes = count, luauheapkb = gcinfo(), timing = "inclusive elapsed milliseconds"}
end
table.insert(state.connections, runservice.PreSimulation:Connect(function(dt)
  if rf.resources.simbusy or not state.alive or state.stopping then return end
  rf.resources.simbusy = true
  local started = os.clock()
  rf.safe("simulation", simstep, dt)
  local metrics = state.metrics
  metrics.simms += ((os.clock() - started) * 1000 - metrics.simms) * 0.1
  metrics.samples += 1
  rf.resources.simbusy = false
end))

visualstate.pendingobjects = {}
rf.resources.worldevents = setmetatable({}, {__mode = "k"})
table.insert(state.connections, world.DescendantAdded:Connect(function(object)
  if not state.alive then return end
  if object:IsDescendantOf(rf.resources.coinfolder) or object:IsDescendantOf(rf.resources.trackingfolder) then return end
  rf.resources.worldevents[object] = true
end))


rf.refreshworldgraphics()
rf.refreshperformancegraphics()
rf.applylightingvisuals()
rf.applyfov()
rf.applyfpscap(true)
rf.clearlegacyknifevfx()
table.insert(state.connections, world:GetPropertyChangedSignal("CurrentCamera"):Connect(rf.applyfov))
table.insert(state.connections, runservice.Heartbeat:Connect(function(dt)
  if not state.alive or state.stopping then return end
  if not rf.resources.backgroundbusy then
    rf.resources.backgroundbusy = true
    rf.safe("heartbeat:background", rf.backgroundstep)
    rf.resources.backgroundbusy = false
  end
  if flags.coinchams or flags.autofarm then rf.safe("heartbeat:coins", rf.updatecoinproxies, dt) end
  if not state.pickupbusy and (config.r6tracking and flags.chams and flags.skeleton and config.skeleton or next(state.tracking)) then
    state.trackingelapsed += dt
    if state.trackingelapsed >= rf.adaptiveinterval(math.max(1 / 30, tonumber(config.r6trackinginterval) or 1 / 45), 1 / 20, 1 / 10) then
      state.trackingelapsed = 0
      rf.safe("heartbeat:tracking", rf.updatetracking)
    end
  end
  local deadline = os.clock() + 0.001
  local processed = 0
  while processed < 64 and os.clock() < deadline do
    local object = next(rf.resources.worldevents)
    if not object then break end
    rf.resources.worldevents[object] = nil
    if object.Parent and object:IsDescendantOf(world) then
      if object:IsA("Beam") then rf.safe("world:beam", rf.farmtrackbeam, object) end
      rf.safe("world:drop", rf.resources.worldadded, object)
      rf.safe("world:coin", rf.resources.coinadded, object)
      if config.removetextures or config.simplematerials or config.disablemapfx
        or config.distanceculling or config.frustumculling then visualstate.pendingobjects[object] = true end
    end
    processed += 1
  end
  while processed < 80 and os.clock() < deadline do
    local object = next(visualstate.pendingobjects)
    if not object then break end
    visualstate.pendingobjects[object] = nil
    if object.Parent then
      if config.removetextures or config.simplematerials or config.disablemapfx then rf.safe("graphics:object", rf.applyworldobject, object) end
      if config.distanceculling or config.frustumculling then rf.safe("graphics:cull", rf.trackculling, object) end
    end
    processed += 1
  end
  visualstate.lightingelapsed += dt
  visualstate.worldelapsed += dt
  visualstate.postfxelapsed = (visualstate.postfxelapsed or 0) + dt
  if visualstate.postfxelapsed >= 5 then
    visualstate.postfxelapsed = 0
    if config.disablepostfx then
      for _, object in ipairs(lighting:GetDescendants()) do
        if (object:IsA("BloomEffect") or object:IsA("BlurEffect") or object:IsA("SunRaysEffect")
          or object:IsA("DepthOfFieldEffect") or object:IsA("ColorCorrectionEffect"))
          and object.Name ~= "VantaPauseBlur" then
          visualremember(visualstate.postfx, object, {Enabled = true})
          visualset(object, "Enabled", false)
        end
      end
    end
  end
  rf.stepculling(dt)
  if visualstate.scannedmap ~= state.maproot then
    visualstate.scannedmap = state.maproot
    visualstate.maproots = setmetatable({}, {__mode = "k"})
    if state.maproot then
      visualstate.texturegeneration += 1
      visualstate.worldscanrunning = nil
      visualstate.worldelapsed = 0
      rf.scanworldgraphics()
    end
  end
  if visualstate.worldelapsed >= 30 then
    visualstate.worldelapsed = 0
    for _, records in ipairs({visualstate.textures, visualstate.materials, visualstate.mapfx}) do
      for object, record in pairs(records) do
        if not object.Parent and (not record.Parent or not record.Parent:IsDescendantOf(world)) then records[object] = nil end
      end
    end
  end
  if visualstate.lightingelapsed >= 0.7 then
    visualstate.lightingelapsed = 0
    if config.fullbright or config.clearfog or config.noshadows then rf.applylightingvisuals() end
    if config.fovmode ~= "Default" then rf.applyfov() end
  end
end))

rf.updatetracking()
rf.inferroles()
rf.updatehud()

function rf.votetick()
  if not state.alive or voting.stepping then return end
  voting.stepping = true
  local ok, reason = pcall(rf.votestep)
  voting.stepping = false
  if not ok then
    rf.votehalt("Voting error: " .. tostring(reason):sub(1, 75), true)
  end
end

table.insert(state.connections, localplayer.CharacterAdded:Connect(function(character)
  if not state.alive or not config.autovote or voting.stage ~= "respawn"
    or voting.lastcharacter == character then return end
  voting.lastcharacter = character
  rf.defer(function()
    local root = character:WaitForChild("HumanoidRootPart", 8)
    local humanoid = character:WaitForChild("Humanoid", 8)
    if not state.alive or not config.autovote or voting.stage ~= "respawn"
      or not root or not humanoid or localplayer.Character ~= character
      or humanoid.Health <= 0 then return end
    voting.nextattempt = os.clock()
    rf.votetick()
  end)
end))
rf.spawn(function()
  while state.alive do
    task.wait(0.2)
    if state.alive then pcall(rf.votefadeapply) end
  end
end)
rf.spawn(function()
  local nextmapscan = 0
  while state.alive do
    task.wait(config.autovote and 0.08 or 0.5)
    if not state.alive then break end
    local now = os.clock()
    if config.autovote and now >= nextmapscan then
      nextmapscan = now + 0.6
      pcall(rf.tracknextmap)
    end
    if config.autovote or voting.stage ~= "idle" then rf.votetick() end
  end
end)
rf.defer(rf.fetchroles)
rf.defer(function()
  if state.alive then
    rf.notification("Vanta v" .. version .. " loaded", rf.ismobilelayout() and "Tap the Vanta button to open settings" or "Press " .. rf.bindname(config.guikeybind) .. " to open settings", nil,
      "check-circle", Color3.fromRGB(255, 228, 109), "vanta:loaded")
  end
end)
