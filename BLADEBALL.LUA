
local _dwzyaTable = {["A"] = 0, ["B"] = 1, ["C"] = 2, ["D"] = 3, ["E"] = 4, ["F"] = 5, ["G"] = 6, ["H"] = 7, ["I"] = 8, ["J"] = 9, ["K"] = 10, ["L"] = 11, ["M"] = 12, ["N"] = 13, ["O"] = 14, ["P"] = 15, ["Q"] = 16, ["R"] = 17, ["S"] = 18, ["T"] = 19, ["U"] = 20, ["V"] = 21, ["W"] = 22, ["X"] = 23, ["Y"] = 24, ["Z"] = 25, ["a"] = 26, ["b"] = 27, ["c"] = 28, ["d"] = 29, ["e"] = 30, ["f"] = 31, ["g"] = 32, ["h"] = 33, ["i"] = 34, ["j"] = 35, ["k"] = 36, ["l"] = 37, ["m"] = 38, ["n"] = 39, ["o"] = 40, ["p"] = 41, ["q"] = 42, ["r"] = 43, ["s"] = 44, ["t"] = 45, ["u"] = 46, ["v"] = 47, ["w"] = 48, ["x"] = 49, ["y"] = 50, ["z"] = 51, ["0"] = 52, ["1"] = 53, ["2"] = 54, ["3"] = 55, ["4"] = 56, ["5"] = 57, ["6"] = 58, ["7"] = 59, ["8"] = 60, ["9"] = 61, ["+"] = 62, ["/"] = 63}
local function _dwzya(s)
    local bytes = {}
    local buffer, bits = 0, 0
    for i = 1, #s do
        local ch = s:sub(i, i)
        if ch == "=" then break end
        local val = _dwzyaTable[ch]
        if val ~= nil then
            buffer = bit32.bor(bit32.lshift(buffer, 6), val)
            bits = bits + 6
            if bits >= 8 then
                bits = bits - 8
                bytes[#bytes + 1] = bit32.band(bit32.rshift(buffer, bits), 0xFF)
            end
        end
    end
    local key = "dqmhbjhqqigh"
    local out = {}
    for i = 1, #bytes do
        local k = key:byte(((i - 1) % #key) + 1)
        out[i] = string.char(bit32.bxor(bytes[i], k))
    end
    return table.concat(out)
end
local Players = game:GetService(_dwzya("NB0MEQcYGw=="))
local UserInputService = game:GetService(_dwzya("MQIIGisEGAQFOgIaEhgODQ=="))
local TweenService = game:GetService(_dwzya("MAYIDQw5DQMHAAQN"))
local RunService = game:GetService(_dwzya("NgQDOwcYHhgSDA=="))
local Stats = game:GetService(_dwzya("NwUMHBE="))
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end
local PlayerGui = LocalPlayer:WaitForChild(_dwzya("NB0MEQcYLwQY"))
for _, guiObject in ipairs(PlayerGui:GetChildren()) do
if guiObject.Name == _dwzya("PjkiKSw1JB4QDQIa") or guiObject.Name == _dwzya("PjkiKSw1IAQT") then
guiObject:Destroy()
end
end
-- ============================================================
--  THEME + HELPERS
-- ============================================================
local Theme = {
BG = Color3.fromRGB((14 - 6), (11 - 3), (15 - 5)),
Sidebar = Color3.fromRGB((14 - 2), (17 - 5), (20 - 6)),
Panel = Color3.fromRGB((28 - 10), (23 - 5), (32 - 10)),
PanelHover = Color3.fromRGB((45 - 20), (32 - 7), (57 - 27)),
Track = Color3.fromRGB((39 - 9), (41 - 11), (52 - 17)),
Accent = Color3.fromRGB((408 - 196), (279 - 104), (99 - 9)),
AccentBright = Color3.fromRGB((359 - 114), (335 - 120), (255 - 115)),
Text = Color3.fromRGB((331 - 91), (456 - 216), (389 - 144)),
TextDim = Color3.fromRGB((247 - 107), (206 - 66), (217 - 67)),
Stroke = Color3.fromRGB((79 - 34), (68 - 23), (106 - 51)),
Red = Color3.fromRGB((383 - 163), (114 - 44), (109 - 39)),
Green = Color3.fromRGB((149 - 54), (367 - 162), (234 - 89)),
}
local function new(_v1, _v2)
local _v3 = Instance.new(_v1)
for _v4, _v5 in pairs(_v2 or {}) do
if _v4 ~= _dwzya("NBAfDQwe") then
pcall(function() _v3[_v4] = _v5 end)
end
end
if _v2 and _v2.Parent then _v3.Parent = _v2.Parent end
return _v3
end
local function corner(_v6, _v7)
return new(_dwzya("MTguBxAEDQM="), { CornerRadius = UDim.new(0, _v7 or (15 - 7)), Parent = _v6 })
end
local function stroke(_v8, color, _v9, _va)
return new(_dwzya("MTg+HBAFAxQ="), {
Color = color or Theme.Stroke,
Thickness = _v9 or 1,
Transparency = _va == nil and 0.5 or _va,
ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
Parent = _v8,
})
end
local function tween(_vb, _vc, _vd)
if not _vb or not _vb.Parent then return end
local _ve = TweenService:Create(
_vb,
TweenInfo.new(_vc or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
_vd
)
_ve:Play()
return _ve
end
local function getThumbnail()
local _vf = ""
pcall(function()
_vf = Players:GetUserThumbnailAsync(
LocalPlayer.UserId,
Enum.ThumbnailType.HeadShot,
Enum.ThumbnailSize.Size150x150
)
end)
return _vf
end
-- ============================================================
--  REAL UI LIBRARY (custom GUI)
-- ============================================================
local RealUI = {}
function RealUI:Window(_vg, _vh)
local _vi = new(_dwzya("NxIfDQcELwQY"), {
Name = _dwzya("PjkiKSw1IAQT"),
IgnoreGuiInset = true,
DisplayOrder = (1387 - 388),
ZIndexBehavior = Enum.ZIndexBehavior.Global,
ResetOnSpawn = false,
Parent = PlayerGui,
})
local _vj = new(_dwzya("IgMMBQc="), {
Name = _dwzya("MxgDDA0d"),
Size = UDim2.fromOffset((1088 - 388), (469 - 49)), -- Altezza diminuita da 500 a 420
Position = UDim2.new(0.5, 0, 0.5, 0),
AnchorPoint = Vector2.new(0.5, 0.5),
BackgroundColor3 = Theme.BG,
BorderSizePixel = 0,
ClipsDescendants = true,
Parent = _vi,
})
corner(_vj, (26 - 12))
stroke(_vj, Theme.Accent, 1, 0.7)
local _vk = new(_dwzya("IgMMBQc="), {
Size = UDim2.new(1, 0, 0, (54 - 4)),
BackgroundTransparency = 1,
Parent = _vj,
})
new(_dwzya("MBQVHC4LChQd"), {
Text = string.format(_dwzya("WBcCBhZKCx4dBhVVRlIpXCMsXTBTV0IbWF4LBwweVlFNDwgGEFEOBw4FGkxTSiFaIkMrXUBUTQJNRgEHCgVT"), _vg, _vh),
RichText = true,
Font = Enum.Font.GothamBold,
TextSize = (32 - 16),
TextColor3 = Theme.Text,
TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1,
Size = UDim2.new(0, (240 - 20), 1, 0),
Position = UDim2.new(0, (22 - 2), 0, 0),
Parent = _vk,
})
local _vl = new(_dwzya("MBQVHC4LChQd"), {
Text = _dwzya("IiE+UkJaWFFRFUdIKSJXSFJaRkE="),
Font = Enum.Font.GothamMedium, TextSize = (18 - 7), TextColor3 = Theme.Accent,
TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 1,
Size = UDim2.new(0, (368 - 178), 1, 0),
Position = UDim2.new(0.5, -(139 - 44), 0, 0),
Parent = _vk,
})
local _vm = new(_dwzya("MBQVHC4LChQd"), {
Text = _dwzya("VEFXWFJQWEE="), Font = Enum.Font.GothamMedium, TextSize = (13 - 2),
TextColor3 = Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Right,
BackgroundTransparency = 1, Size = UDim2.new(0, (148 - 48), 1, 0),
Position = UDim2.new(1, -(202 - 47), 0, 0), Parent = _vk,
})
local _vn = new(_dwzya("MBQVHCAfHAUeBw=="), {
Text = _dwzya("sw=="), Font = Enum.Font.GothamBold, TextSize = (39 - 19),
TextColor3 = Theme.TextDim, BackgroundTransparency = 1, BorderSizePixel = 0,
Size = UDim2.fromOffset((48 - 20), (41 - 13)),
Position = UDim2.new(1, -(23 - 8), 0, (17 - 6)),
AnchorPoint = Vector2.new(1, 0),
AutoButtonColor = false, Parent = _vk,
})
_vn.MouseEnter:Connect(function() tween(_vn, 0.15, {TextColor3 = Theme.Red}) end)
_vn.MouseLeave:Connect(function() tween(_vn, 0.15, {TextColor3 = Theme.TextDim}) end)
_vn.MouseButton1Click:Connect(function()
tween(_vj, 0.18, {Size = UDim2.fromOffset(0, 0)})
task.delay(0.2, function() if _vi.Parent then _vi:Destroy() end end)
end)
local _vo = new(_dwzya("IgMMBQc="), {
Size = UDim2.new(0, (244 - 64), 1, -(147 - 72)), -- Modificato per riempire lo spazio (era -160)
Position = UDim2.new(0, (23 - 8), 0, (94 - 34)),
BackgroundTransparency = 1, Parent = _vj,
})
local _vp = new(_dwzya("IgMMBQc="), {
Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = _vo,
})
new(_dwzya("MTghAREeJBAIBhIc"), { Padding = UDim.new(0, (12 - 6)), SortOrder = Enum.SortOrder.LayoutOrder, Parent = _vp })
local _vq = new(_dwzya("IgMMBQc="), {
Size = UDim2.new(1, -(425 - 210), 1, -(111 - 36)), -- Modificato per riempire lo spazio (era -160)
Position = UDim2.new(0, (341 - 141), 0, (75 - 15)),
BackgroundTransparency = 1, Parent = _vj,
})
-- (Footer rimosso)
local function _vr(_v2t, color)
print(_dwzya("PyslJyMkSDkkKzpI") .. tostring(_v2t)) -- Le notifiche ora vanno nella console (F9)
end
-- Dragging
local _vs, _vt, _vu, _vv = false, nil, nil, nil
_vk.InputBegan:Connect(function(_v2u)
if _v2u.UserInputType == Enum.UserInputType.MouseButton1
or _v2u.UserInputType == Enum.UserInputType.Touch then
_vs = true
_vu = _v2u.Position
_vv = _vj.Position
_v2u.Changed:Connect(function()
if _v2u.UserInputState == Enum.UserInputState.End then _vs = false end
end)
end
end)
_vk.InputChanged:Connect(function(_v2v)
if _v2v.UserInputType == Enum.UserInputType.MouseMovement
or _v2v.UserInputType == Enum.UserInputType.Touch then
_vt = _v2v
end
end)
local _vw = UserInputService.InputChanged:Connect(function(_v2w)
if _vs and _v2w == _vt then
local _v2x = _v2w.Position - _vu
_vj.Position = UDim2.new(
_vv.X.Scale, _vv.X.Offset + _v2x.X,
_vv.Y.Scale, _vv.Y.Offset + _v2x.Y
)
end
end)
local _vy = {}
local _vz
local function _v10(_v2y)
local _v2z = new(_dwzya("MBQVHCAfHAUeBw=="), {
Text = "", BackgroundColor3 = Theme.Panel, BackgroundTransparency = 1,
BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, (63 - 25)),
AutoButtonColor = false, Parent = _vp,
})
corner(_v2z, (11 - 3))
local _v30 = new(_dwzya("IgMMBQc="), {
Size = UDim2.new(0, (6 - 3), 0, (28 - 12)),
Position = UDim2.new(0, 0, 0.5, 0),
AnchorPoint = Vector2.new(0, 0.5),
BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
Visible = false, Parent = _v2z,
})
corner(_v30, (4 - 2))
local _v31 = new(_dwzya("MBQVHC4LChQd"), {
Text = _v2y:upper(), Font = Enum.Font.GothamMedium, TextSize = (21 - 9),
TextColor3 = Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1, Size = UDim2.new(1, -(36 - 16), 1, 0),
Position = UDim2.new(0, (25 - 10), 0, 0), Parent = _v2z,
})
local _v32 = new(_dwzya("NxIfBw4GAR8WLxUJCRQ="), {
Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
Visible = false, ScrollBarThickness = (3 - 1), ScrollBarImageColor3 = Theme.Stroke,
CanvasSize = UDim2.new(0, 0, 0, 0),
AutomaticCanvasSize = Enum.AutomaticSize.Y,
BorderSizePixel = 0, Parent = _vq,
})
new(_dwzya("MTghAREeJBAIBhIc"), { Padding = UDim.new(0, (14 - 6)), SortOrder = Enum.SortOrder.LayoutOrder, Parent = _v32 })
new(_dwzya("MTg9CQYOAR8W"), {
PaddingRight = UDim.new(0, (11 - 1)),
PaddingBottom = UDim.new(0, (10 - 2)), Parent = _v32,
})
local _v33 = {button = _v2z, label = _v31, indicator = _v30, page = _v32}
local function _v34()
if _vz then
tween(_vz.button, 0.18, {BackgroundTransparency = 1})
tween(_vz.label, 0.18, {TextColor3 = Theme.TextDim})
_vz.indicator.Visible = false
_vz.page.Visible = false
end
_vz = _v33
tween(_v2z, 0.18, {BackgroundTransparency = 0.35, BackgroundColor3 = Theme.Panel})
tween(_v31, 0.18, {TextColor3 = Theme.Text})
_v30.Visible = true
_v32.Visible = true
end
_v2z.MouseEnter:Connect(function()
if _vz ~= _v33 then
tween(_v2z, 0.15, {BackgroundTransparency = 0.65, BackgroundColor3 = Theme.Panel})
end
end)
_v2z.MouseLeave:Connect(function()
if _vz ~= _v33 then tween(_v2z, 0.15, {BackgroundTransparency = 1}) end
end)
_v2z.MouseButton1Click:Connect(_v34)
_vy[_v2y] = _v33
if not _vz then _v34() end
return _v33
end
local _v17 = {ScreenGui = _vi, Window = _vj, Tabs = _vy, Notify = _vr}
local function _v18(_v35, _v36)
local _v37 = new(_dwzya("IgMMBQc="), {
Size = UDim2.new(1, 0, 0, _v36),
BackgroundColor3 = Theme.Panel, BackgroundTransparency = 0.35,
BorderSizePixel = 0, Parent = _v35,
})
corner(_v37, (14 - 6))
stroke(_v37, Theme.Stroke, 1, 0.78)
return _v37
end
function _v17:AddTab(_v38) return _v10(_v38) end
function _v17:AddSection(_v39, _v3a, _v3b)
local _v3c = new(_dwzya("IgMMBQc="), {
Size = UDim2.new(1, 0, 0, (73 - 31)), BackgroundTransparency = 1,
BorderSizePixel = 0, Parent = _v39,
})
new(_dwzya("MBQVHC4LChQd"), {
Text = _v3a, Font = Enum.Font.GothamBold, TextSize = (16 - 2),
TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, (22 - 2)), Parent = _v3c,
})
new(_dwzya("MBQVHC4LChQd"), {
Text = _v3b or "", Font = Enum.Font.GothamMedium, TextSize = (16 - 6),
TextColor3 = Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, (24 - 9)),
Position = UDim2.new(0, 0, 0, (36 - 15)), Parent = _v3c,
})
return _v3c
end
function _v17:AddToggle(_v3d, _v3e, _v3f, _v3g)
local _v3h = _v18(_v3d, (55 - 15))
new(_dwzya("MBQVHC4LChQd"), {
Text = _v3e, Font = Enum.Font.GothamMedium, TextSize = (19 - 7),
TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1, Size = UDim2.new(1, -(117 - 47), 1, 0),
Position = UDim2.new(0, (28 - 13), 0, 0), Parent = _v3h,
})
local _v3i = new(_dwzya("IgMMBQc="), {
Size = UDim2.fromOffset((47 - 11), (36 - 16)),
Position = UDim2.new(1, -(26 - 11), 0.5, 0),
AnchorPoint = Vector2.new(1, 0.5),
BackgroundColor3 = Theme.Track, BorderSizePixel = 0, Parent = _v3h,
})
corner(_v3i, (19 - 9))
local _v3j = stroke(_v3i, Theme.Stroke, 1, 0.6)
local _v3k = new(_dwzya("IgMMBQc="), {
Size = UDim2.fromOffset((23 - 9), (25 - 11)),
Position = UDim2.new(0, (5 - 2), 0.5, 0),
AnchorPoint = Vector2.new(0, 0.5),
BackgroundColor3 = Theme.TextDim, BorderSizePixel = 0, Parent = _v3i,
})
corner(_v3k, (14 - 7))
local _v3l = _v3f and true or false
local function _v3m()
if _v3l then
tween(_v3i, 0.18, {BackgroundColor3 = Theme.Accent})
tween(_v3k, 0.18, {Position = UDim2.new(1, -(29 - 12), 0.5, 0), BackgroundColor3 = Theme.Text})
_v3j.Color = Theme.AccentBright
else
tween(_v3i, 0.18, {BackgroundColor3 = Theme.Track})
tween(_v3k, 0.18, {Position = UDim2.new(0, (4 - 1), 0.5, 0), BackgroundColor3 = Theme.TextDim})
_v3j.Color = Theme.Stroke
end
end
_v3m()
new(_dwzya("MBQVHCAfHAUeBw=="), { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = _v3h })
.MouseButton1Click:Connect(function()
_v3l = not _v3l
_v3m()
if _v3g then _v3g(_v3l) end
end)
return {
Set = function(_, _v3n)
_v3l = _v3n and true or false
_v3m()
if _v3g then _v3g(_v3l) end
end,
Get = function() return _v3l end,
}
end
function _v17:AddSlider(_v3o, _v3p, _v3q, _v3r, _v3s, _v3t, _v3u)
local _v3v = _v18(_v3o, (63 - 7))
new(_dwzya("MBQVHC4LChQd"), {
Text = _v3p, Font = Enum.Font.GothamMedium, TextSize = (13 - 1),
TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1, Size = UDim2.new(1, -(159 - 79), 0, (24 - 4)),
Position = UDim2.new(0, (21 - 6), 0, (8 - 2)), Parent = _v3v,
})
local _v3w = new(_dwzya("MBQVHC4LChQd"), {
Text = tostring(_v3s), Font = Enum.Font.GothamMedium, TextSize = (12 - 1),
TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Right,
BackgroundTransparency = 1, Size = UDim2.new(0, (76 - 26), 0, (21 - 1)),
Position = UDim2.new(1, -(30 - 15), 0, (8 - 2)), AnchorPoint = Vector2.new(1, 0), Parent = _v3v,
})
local _v3x = new(_dwzya("IgMMBQc="), {
Size = UDim2.new(1, -(53 - 23), 0, (8 - 4)), Position = UDim2.new(0, (29 - 14), 0, (40 - 2)),
BackgroundColor3 = Theme.Track, BorderSizePixel = 0, Parent = _v3v,
})
corner(_v3x, (3 - 1))
local _v3y = new(_dwzya("IgMMBQc="), {
Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Accent,
BorderSizePixel = 0, Parent = _v3x,
})
corner(_v3y, (4 - 2))
new(_dwzya("MTgqGgMOARQfHQ=="), { Color = ColorSequence.new(Theme.Accent, Theme.AccentBright), Parent = _v3y })
local _v3z = new(_dwzya("IgMMBQc="), {
Size = UDim2.fromOffset((13 - 1), (19 - 7)), AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Theme.Text,
BorderSizePixel = 0, Parent = _v3x,
})
corner(_v3z, (10 - 4))
stroke(_v3z, Theme.Accent, 1.5, 0.2)
local _v40 = _v3s
local function _v41(_v48, _v49)
_v48 = math.clamp(_v48, _v3q, _v3r)
if _v3u and _v3u > 0 then
_v48 = math.floor((_v48 - _v3q) / _v3u + 0.5) * _v3u + _v3q
_v48 = math.clamp(_v48, _v3q, _v3r)
end
_v40 = _v48
local _v4a = (_v48 - _v3q) / (_v3r - _v3q)
tween(_v3y, 0.08, {Size = UDim2.new(_v4a, 0, 1, 0)})
tween(_v3z, 0.08, {Position = UDim2.new(_v4a, 0, 0.5, 0)})
if _v3u and _v3u >= 1 then
_v3w.Text = tostring(math.floor(_v48 + 0.5))
else
_v3w.Text = tostring(math.floor(_v48 * (14 - 4)) / (18 - 8))
end
if _v49 ~= false and _v3t then _v3t(_v40) end
end
_v41(_v3s, false)
local _v43 = false
local function _v44(_v4b)
if _v3x.AbsoluteSize.X <= 0 then return end
local _v4c = (_v4b - _v3x.AbsolutePosition.X) / _v3x.AbsoluteSize.X
_v41(_v3q + (_v3r - _v3q) * math.clamp(_v4c, 0, 1), true)
end
_v3x.InputBegan:Connect(function(_v4d)
if _v4d.UserInputType == Enum.UserInputType.MouseButton1
or _v4d.UserInputType == Enum.UserInputType.Touch then
_v43 = true
_v44(_v4d.Position.X)
end
end)
local _v46 = UserInputService.InputChanged:Connect(function(_v4e)
if _v43 and (_v4e.UserInputType == Enum.UserInputType.MouseMovement
or _v4e.UserInputType == Enum.UserInputType.Touch) then
_v44(_v4e.Position.X)
end
end)
local _v47 = UserInputService.InputEnded:Connect(function(_v4f)
if _v4f.UserInputType == Enum.UserInputType.MouseButton1
or _v4f.UserInputType == Enum.UserInputType.Touch then
_v43 = false
end
end)
_vi.Destroying:Connect(function()
_v46:Disconnect()
_v47:Disconnect()
end)
return {
Set = function(_, _v4g) _v41(_v4g, true) end,
Get = function() return _v40 end,
}
end
function _v17:AddButton(_v4h, _v4i, _v4j)
local _v4k = _v18(_v4h, (55 - 15))
_v4k.BackgroundTransparency = 0.45
local _v4l = new(_dwzya("MBQVHC4LChQd"), {
Text = _v4i, Font = Enum.Font.GothamBold, TextSize = (18 - 6),
TextColor3 = Theme.Accent, BackgroundTransparency = 1,
Size = UDim2.fromScale(1, 1), Parent = _v4k,
})
local _v4m = new(_dwzya("MBQVHCAfHAUeBw=="), {
Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = _v4k,
})
_v4m.MouseEnter:Connect(function()
tween(_v4k, 0.15, {BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.1})
tween(_v4l, 0.15, {TextColor3 = Theme.BG})
end)
_v4m.MouseLeave:Connect(function()
tween(_v4k, 0.15, {BackgroundColor3 = Theme.Panel, BackgroundTransparency = 0.45})
tween(_v4l, 0.15, {TextColor3 = Theme.Accent})
end)
_v4m.MouseButton1Click:Connect(function() if _v4j then _v4j() end end)
return _v4k
end
function _v17:AddTextbox(_v4n, _v4o, _v4p, _v4q)
local _v4r = _v18(_v4n, (73 - 33))
new(_dwzya("MBQVHC4LChQd"), {
Text = _v4o, Font = Enum.Font.GothamMedium, TextSize = (23 - 11),
TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1, Size = UDim2.new(0.35, 0, 1, 0),
Position = UDim2.new(0, (23 - 8), 0, 0), Parent = _v4r,
})
local _v4s = new(_dwzya("MBQVHCAFEA=="), {
Text = "", PlaceholderText = _v4p or "",
PlaceholderColor3 = Theme.TextDim, Font = Enum.Font.GothamMedium,
TextSize = (21 - 10), TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
BackgroundColor3 = Theme.Track, BorderSizePixel = 0, ClearTextOnFocus = false,
Size = UDim2.new(0.6, -(21 - 6), 0, (49 - 23)), Position = UDim2.new(1, -(17 - 2), 0.5, 0),
AnchorPoint = Vector2.new(1, 0.5), Parent = _v4r,
})
corner(_v4s, (10 - 4))
local _v4t = stroke(_v4s, Theme.Stroke, 1, 0.6)
new(_dwzya("MTg9CQYOAR8W"), { PaddingLeft = UDim.new(0, (14 - 6)), PaddingRight = UDim.new(0, (15 - 7)), Parent = _v4s })
_v4s.Focused:Connect(function()
tween(_v4s, 0.15, {BackgroundColor3 = Theme.Panel})
_v4t.Color = Theme.Accent
end)
_v4s.FocusLost:Connect(function(_v4u)
tween(_v4s, 0.15, {BackgroundColor3 = Theme.Track})
_v4t.Color = Theme.Stroke
if _v4q then _v4q(_v4s.Text, _v4u) end
end)
return {
Get = function() return _v4s.Text end,
Set = function(_, _v4v) _v4s.Text = tostring(_v4v) end, Box = _v4s,
}
end
function _v17:AddDropdown(_v4w, _v4x, _v4y, _v4z, _v50)
local _v51 = _v18(_v4w, (71 - 31))
new(_dwzya("MBQVHC4LChQd"), {
Text = _v4x, Font = Enum.Font.GothamMedium, TextSize = (17 - 5),
TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1, Size = UDim2.new(1, -(257 - 107), 1, 0),
Position = UDim2.new(0, (20 - 5), 0, 0), Parent = _v51,
})
local _v52 = new(_dwzya("MBQVHCAfHAUeBw=="), {
Text = tostring(_v4z or ""), Font = Enum.Font.GothamMedium, TextSize = (20 - 9),
TextColor3 = Theme.Text, BackgroundColor3 = Theme.Track, BorderSizePixel = 0,
Size = UDim2.new(0, (180 - 60), 0, (42 - 16)), Position = UDim2.new(1, -(30 - 15), 0.5, 0),
AnchorPoint = Vector2.new(1, 0.5), AutoButtonColor = false, Parent = _v51,
})
corner(_v52, (9 - 3))
stroke(_v52, Theme.Stroke, 1, 0.6)
new(_dwzya("MBQVHC4LChQd"), {
Text = _dwzya("hv3p"), Font = Enum.Font.GothamBold, TextSize = (16 - 2),
TextColor3 = Theme.TextDim, BackgroundTransparency = 1,
Size = UDim2.new(0, (36 - 16), 1, 0), Position = UDim2.new(1, -(21 - 1), 0, 0), Parent = _v52,
})
local _v53 = new(_dwzya("IgMMBQc="), {
Size = UDim2.new(0, (179 - 59), 0, 0), Position = UDim2.new(1, -(20 - 5), 0, (73 - 31)),
AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = Theme.Panel,
BorderSizePixel = 0, Visible = false, ZIndex = (29 - 9), Parent = _v51,
})
corner(_v53, (9 - 3))
stroke(_v53, Theme.Stroke, 1, 0.3)
new(_dwzya("MTghAREeJBAIBhIc"), { Padding = UDim.new(0, (4 - 2)), SortOrder = Enum.SortOrder.LayoutOrder, Parent = _v53 })
new(_dwzya("MTg9CQYOAR8W"), {
PaddingTop = UDim.new(0, (6 - 2)), PaddingBottom = UDim.new(0, (6 - 2)),
PaddingLeft = UDim.new(0, (8 - 4)), PaddingRight = UDim.new(0, (6 - 2)), Parent = _v53,
})
local _v54 = _v4z
local _v55 = false
local function _v56()
_v55 = false
tween(_v53, 0.13, {Size = UDim2.new(0, (193 - 73), 0, 0)})
task.delay(0.14, function() if _v53.Parent and not _v55 then _v53.Visible = false end end)
end
local function _v57()
_v55 = true
_v53.Visible = true
_v53.Size = UDim2.new(0, (197 - 77), 0, 0)
tween(_v53, 0.13, {Size = UDim2.new(0, (194 - 74), 0, #_v4y * (33 - 7) + (14 - 6))})
end
_v52.MouseButton1Click:Connect(function()
if _v55 then _v56() else _v57() end
end)
for _, _v58 in ipairs(_v4y) do
local _v59 = new(_dwzya("MBQVHCAfHAUeBw=="), {
Text = tostring(_v58), Font = Enum.Font.GothamMedium, TextSize = (18 - 7),
TextColor3 = Theme.TextDim, BackgroundColor3 = Theme.Panel,
BackgroundTransparency = 0.5, BorderSizePixel = 0,
Size = UDim2.new(1, 0, 0, (38 - 14)), AutoButtonColor = false,
ZIndex = (41 - 20), Parent = _v53,
})
corner(_v59, (5 - 1))
_v59.MouseEnter:Connect(function()
tween(_v59, 0.1, {BackgroundTransparency = 0.15, TextColor3 = Theme.Text})
end)
_v59.MouseLeave:Connect(function()
tween(_v59, 0.1, {BackgroundTransparency = 0.5, TextColor3 = Theme.TextDim})
end)
_v59.MouseButton1Click:Connect(function()
_v54 = _v58
_v52.Text = tostring(_v58)
if _v50 then _v50(_v58) end
_v56()
end)
end
return {
Get = function() return _v54 end,
Set = function(_, _v5a)
_v54 = _v5a
_v52.Text = tostring(_v5a)
if _v50 then _v50(_v5a) end
end,
}
end
function _v17:AddColorPicker(_v5b, _v5c, _v5d, _v5e)
local _v5f = _v18(_v5b, (66 - 26))
new(_dwzya("MBQVHC4LChQd"), {
Text = _v5c, Font = Enum.Font.GothamMedium, TextSize = (14 - 2),
TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
BackgroundTransparency = 1, Size = UDim2.new(1, -(111 - 41), 1, 0),
Position = UDim2.new(0, (16 - 1), 0, 0), Parent = _v5f,
})
local _v5g = _v5d or Color3.fromRGB((424 - 169), (306 - 51), (345 - 90))
local _v5h = new(_dwzya("MBQVHCAfHAUeBw=="), {
Text = "", BackgroundColor3 = _v5g, BorderSizePixel = 0,
Size = UDim2.fromOffset((96 - 48), (34 - 14)), Position = UDim2.new(1, -(28 - 13), 0.5, 0),
AnchorPoint = Vector2.new(1, 0.5), AutoButtonColor = false, Parent = _v5f,
})
corner(_v5h, (8 - 2))
stroke(_v5h, Theme.Accent, 1, 0.4)
local _v5i = new(_dwzya("IgMMBQc="), {
Size = UDim2.fromOffset((413 - 173), (286 - 86)), BackgroundColor3 = Theme.Panel,
BorderSizePixel = 0, Visible = false, ZIndex = (158 - 58), Parent = _vi,
})
corner(_v5i, (16 - 8))
stroke(_v5i, Theme.Stroke, 1, 0.2)
local _v5j = new(_dwzya("IgMMBQc="), {
Size = UDim2.new(1, -(22 - 2), 0, (47 - 19)),
Position = UDim2.new(0, (13 - 3), 0, (19 - 9)),
BackgroundColor3 = _v5g, BorderSizePixel = 0, ZIndex = (165 - 64), Parent = _v5i,
})
corner(_v5j, (8 - 2))
stroke(_v5j, Theme.Stroke, 1, 0.5)
local _v5k = {_v5g.R * (471 - 216), _v5g.G * (509 - 254), _v5g.B * (278 - 23)}
local _v5l = {}
local _v5m = {
{label = _dwzya("Ng=="), color = Color3.fromRGB((343 - 123), (134 - 64), (116 - 46))},
{label = _dwzya("Iw=="), color = Color3.fromRGB((142 - 47), (345 - 140), (249 - 104))},
{label = _dwzya("Jg=="), color = Color3.fromRGB((117 - 37), (242 - 112), (228 - 8))},
}
local function _v5n()
_v5g = Color3.fromRGB(
math.floor(_v5k[1] + 0.5),
math.floor(_v5k[(3 - 1)] + 0.5),
math.floor(_v5k[(4 - 1)] + 0.5)
)
_v5j.BackgroundColor3 = _v5g
_v5h.BackgroundColor3 = _v5g
if _v5e then _v5e(_v5g) end
end
for _v5o, info in ipairs(_v5m) do
local _v5p = _v5o
local _v5q = info
local _v5r = (73 - 25) + (_v5p - 1) * (81 - 33)
new(_dwzya("MBQVHC4LChQd"), {
Text = _v5q.label, Font = Enum.Font.GothamBold, TextSize = (14 - 2),
TextColor3 = _v5q.color, BackgroundTransparency = 1,
Size = UDim2.fromOffset((23 - 3), (36 - 16)), TextXAlignment = Enum.TextXAlignment.Left,
Position = UDim2.fromOffset((23 - 11), _v5r), ZIndex = (185 - 84), Parent = _v5i,
})
local _v5s = new(_dwzya("MBQVHC4LChQd"), {
Text = tostring(math.floor(_v5k[_v5p] + 0.5)),
Font = Enum.Font.GothamMedium, TextSize = (20 - 9), TextColor3 = Theme.Text,
TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1,
Size = UDim2.fromOffset((45 - 10), (27 - 7)), Position = UDim2.fromOffset((265 - 72), _v5r),
ZIndex = (154 - 53), Parent = _v5i,
})
local _v5t = new(_dwzya("IgMMBQc="), {
Size = UDim2.new(1, -(77 - 27), 0, (6 - 2)), Position = UDim2.fromOffset((36 - 1), _v5r + (13 - 5)),
BackgroundColor3 = Theme.Track, BorderSizePixel = 0,
ZIndex = (165 - 64), Parent = _v5i,
})
corner(_v5t, (4 - 2))
local _v5u = new(_dwzya("IgMMBQc="), {
Size = UDim2.new(_v5k[_v5p] / (507 - 252), 0, 1, 0),
BackgroundColor3 = _v5q.color, BorderSizePixel = 0,
ZIndex = (195 - 93), Parent = _v5t,
})
corner(_v5u, (4 - 2))
local _v5v = new(_dwzya("IgMMBQc="), {
Size = UDim2.fromOffset((13 - 1), (18 - 6)),
Position = UDim2.new(_v5k[_v5p] / (267 - 12), 0, 0.5, 0),
AnchorPoint = Vector2.new(0.5, 0.5),
BackgroundColor3 = Theme.Text, BorderSizePixel = 0,
ZIndex = (187 - 84), Parent = _v5t,
})
corner(_v5v, (8 - 2))
stroke(_v5v, Theme.Accent, 1, 0.2)
local _v5w = false
local function _v5x(_v6h)
if _v5t.AbsoluteSize.X <= 0 then return end
local _v6i = math.clamp((_v6h - _v5t.AbsolutePosition.X) / _v5t.AbsoluteSize.X, 0, 1)
_v5k[_v5p] = _v6i * (288 - 33)
_v5u.Size = UDim2.new(_v6i, 0, 1, 0)
_v5v.Position = UDim2.new(_v6i, 0, 0.5, 0)
_v5s.Text = tostring(math.floor(_v6i * (482 - 227) + 0.5))
_v5n()
end
_v5l[_v5p] = function(_v6j)
_v5k[_v5p] = _v6j
local _v6k = _v6j / (321 - 66)
_v5u.Size = UDim2.new(_v6k, 0, 1, 0)
_v5v.Position = UDim2.new(_v6k, 0, 0.5, 0)
_v5s.Text = tostring(math.floor(_v6j + 0.5))
end
_v5t.InputBegan:Connect(function(_v6l)
if _v6l.UserInputType == Enum.UserInputType.MouseButton1
or _v6l.UserInputType == Enum.UserInputType.Touch then
_v5w = true
_v5x(_v6l.Position.X)
end
end)
local _v5z = UserInputService.InputChanged:Connect(function(_v6m)
if _v5w and (_v6m.UserInputType == Enum.UserInputType.MouseMovement
or _v6m.UserInputType == Enum.UserInputType.Touch) then
_v5x(_v6m.Position.X)
end
end)
local _v60 = UserInputService.InputEnded:Connect(function(_v6n)
if _v6n.UserInputType == Enum.UserInputType.MouseButton1
or _v6n.UserInputType == Enum.UserInputType.Touch then
_v5w = false
end
end)
_vi.Destroying:Connect(function()
_v5z:Disconnect()
_v60:Disconnect()
end)
end
local _v61 = false
local _v62
local function _v63()
_v61 = false
_v5i.Visible = false
if _v62 then _v62:Disconnect() _v62 = nil end
end
_v5h.MouseButton1Click:Connect(function()
if _v61 then _v63() return end
_v61 = true
_v5i.Visible = true
local _v6o = _vi.AbsoluteSize
local _v6p = _v5h.AbsolutePosition
local _v6q = _v5h.AbsoluteSize
local _v6r = _v5i.AbsoluteSize
local _v6s = math.clamp(_v6p.X - (277 - 77), (9 - 4), _v6o.X - _v6r.X - (8 - 3))
local _v6t = _v6p.Y + _v6q.Y + (7 - 3)
if _v6t + _v6r.Y > _v6o.Y - (8 - 3) then _v6t = _v6p.Y - _v6r.Y - (6 - 2) end
_v5i.Position = UDim2.fromOffset(_v6s, _v6t)
_v62 = UserInputService.InputBegan:Connect(function(_v6z)
if not _v61 then return end
if _v6z.UserInputType == Enum.UserInputType.MouseButton1
or _v6z.UserInputType == Enum.UserInputType.Touch then
local _v70 = _v6z.Position
local _v71, _v72 = _v5i.AbsolutePosition, _v5i.AbsoluteSize
if _v70.X < _v71.X or _v70.X > _v71.X + _v72.X
or _v70.Y < _v71.Y or _v70.Y > _v71.Y + _v72.Y then
local _v73, _v74 = _v5h.AbsolutePosition, _v5h.AbsoluteSize
if _v70.X < _v73.X or _v70.X > _v73.X + _v74.X
or _v70.Y < _v73.Y or _v70.Y > _v73.Y + _v74.Y then
_v63()
end
end
end
end)
end)
_vi.Destroying:Connect(function()
if _v62 then _v62:Disconnect() end
end)
return {
Get = function() return _v5g end,
Set = function(_, _v75)
_v5g = _v75
local _v76 = math.floor(_v75.R * (304 - 49) + 0.5)
local _v77 = math.floor(_v75.G * (472 - 217) + 0.5)
local _v78 = math.floor(_v75.B * (371 - 116) + 0.5)
_v5l[1](_v76) _v5l[(3 - 1)](_v77) _v5l[(5 - 2)](_v78)
_v5j.BackgroundColor3 = _v75
_v5h.BackgroundColor3 = _v75
if _v5e then _v5e(_v75) end
end,
}
end
return _v17, {
Performance = _vl, Clock = _vm, Screen = _vi,
Window = _vj, DragConnection = _vw,
}
end
-- ============================================================
--  BLADE BALL BACKEND (adattato dal Rayfield)
-- ============================================================
local BB_Players = cloneref(game:GetService(_dwzya("NB0MEQcYGw==")))
local BB_LocalPlayer = BB_Players.LocalPlayer
local BB_RunService = cloneref(game:GetService(_dwzya("NgQDOwcYHhgSDA==")))
local BB_UserInputService = cloneref(game:GetService(_dwzya("MQIIGisEGAQFOgIaEhgODQ==")))
local BB_Workspace = cloneref(game:GetService(_dwzya("Mx4fAxEaCRIU")))
local BB_TeleportService = cloneref(game:GetService(_dwzya("MBQBDRIFGgUiDBUeDRII")))
local BB_HttpService = cloneref(game:GetService(_dwzya("LAUZGDEPGgcYCgI=")))
local BB_ReplicatedStorage = cloneref(game:GetService(_dwzya("NhQdBAsJCQUUDTQcCwMMDwc=")))
local BB_Stats = cloneref(game:GetService(_dwzya("NwUMHBE=")))
-- Notify middle-layer (buffer prima che la GUI esista)
local BB_NotifyHandlers = {}
local function BB_Notify(_v79, color)
if BB_NotifyHandlers.fn then
BB_NotifyHandlers.fn(tostring(_v79), color or Theme.Accent)
end
end
local BB_Alive = BB_Workspace:FindFirstChild(_dwzya("JR0EHgc=")) or BB_Workspace:WaitForChild(_dwzya("JR0EHgc="), (22 - 7))
local BB_Runtime = BB_Workspace:FindFirstChild(_dwzya("NgQDHAsHDQ=="))
local BB_Config = {
MovementMods = false, WalkSpeed = (55 - 19), JumpPower = (81 - 31),
Fly = false, FlySpeed = (71 - 11),
PlayerESP = false, PlayerESPNames = true, PlayerESPDistance = true,
PlayerESPColor = Color3.fromRGB((221 - 5), (250 - 90), (416 - 161)),
AbilityESP = false, AbilityESPColor = Color3.fromRGB(0, (400 - 145), (382 - 182)),
Headless = false, Korblox = false,
}
local BB_SwordsModule, BB_AnimationController, BB_SwordApi
pcall(function()
BB_SwordsModule = require(BB_ReplicatedStorage.Shared.ReplicatedInstances.Swords)
BB_AnimationController = require(BB_ReplicatedStorage.Controllers.AnimationController)
BB_SwordApi = require(BB_ReplicatedStorage.Shared.SwordAPI)
end)
local BB_DataAbilities = BB_ReplicatedStorage:FindFirstChild(_dwzya("KRgeCw==")) and BB_ReplicatedStorage.Misc:FindFirstChild(_dwzya("IBAZCSMIAR0YHQ4NFw=="))
if not BB_DataAbilities then
task.spawn(function()
local _v7a, _v7b = pcall(function() return BB_ReplicatedStorage:WaitForChild(_dwzya("KRgeCw=="), (21 - 6)) end)
if _v7a and _v7b then
local _v7c, da = pcall(function() return _v7b:WaitForChild(_dwzya("IBAZCSMIAR0YHQ4NFw=="), (30 - 15)) end)
if _v7c then BB_DataAbilities = da end
end
end)
end
local BB_AbilityTranslations = {
[_dwzya("Nx4fHAc=")]=_dwzya("KAQOAw=="),[_dwzya("Jh4BCUIODVE+HBUH")]=_dwzya("Ix4BDAcESDMQBQs="),[_dwzya("KZAfHAsY")]=_dwzya("KRAfHBsYDB4c"),[_dwzya("KRABDAuNix4=")]=_dwzya("KRgeDg0YHAQfDA=="),
[_dwzya("JxQEDgMOBwM=")]=_dwzya("NhQMGAcY"),[_dwzya("MBAZBw==")]=_dwzya("MBAOHA=="),[_dwzya("IQIOBxIFDh4TAAY=")]=_dwzya("NxICGA0aAB4TAAY="),[_dwzya("NhQOBw8aDR8CCA==")]=_dwzya("Jh4YBhYT"),
[_dwzya("JxAfDwNKORg=")]=_dwzya("NRhAKwoLGhYU"),[_dwzya("JR8HB0IOCVE2HAYaABA=")]=_dwzya("IwQMGgYDCR9RKAkPAR0="),[_dwzya("MpwfHRE=")]=_dwzya("MhgfHRE="),[_dwzya("NxABHA1KOQSQDRUdFB0C")]=_dwzya("NQQMDEIgHRwB"),
[_dwzya("IBQLBAcSix5RKgYECRA=")]=_dwzya("JxABBQsED1E1DAEEARIZAQ0E"),[_dwzya("IBQLBAcSix5RLxIaDR4eCQ==")]=_dwzya("NhAKAQwNSDUUDwsNBwUEBww="),[_dwzya("JQMfDQALHBAcDAkcCw==")]=_dwzya("NhAdHBcYDQ=="),
[_dwzya("Jx4fHAdKKRQDBgMBCpMAAQEF")]=_dwzya("JRQfBwYTBhAcAARINx0MGwo="),[_dwzya("JxAAGA1KDBRRLwgagxA=")]=_dwzya("Ih4fCwcMARQdDQ=="),[_dwzya("LR8LAQwDHB4=")]=_dwzya("LR8LAQwDHAg="),
[_dwzya("IgMMHBcYCQ==")]=_dwzya("IgMMCxYfGhQ="),[_dwzya("Jx4fHAdKDBBRJAgaEBQ=")]=_dwzya("IBQMHApKOx0QGg8="),[_dwzya("Jx4fHAcZSBUQSSGSFhgM")]=_dwzya("Nx0MGwoPG1EeD0cuEQMU"),[_dwzya("IhADHAMZBRA=")]=_dwzya("NBkMBhYFBQ=="),
[_dwzya("KhQOGg0HCR8FDA==")]=_dwzya("KhQOGg0HCR8SDBU="),[_dwzya("JQMIBgNKOQSTBxMBBxA=")]=_dwzya("NQQMBhYfBVEwGwIGBQ=="),[_dwzya("IQIdhRADHB5RDQhIIAMMD4EF")]=_dwzya("IAMMDw0ESCIBABUBEA=="),
[_dwzya("IAMECg4P")]=_dwzya("IAMECgAGDQ=="),[_dwzya("Jx4ACg0=")]=_dwzya("Jx4ACg0="),[_dwzya("IxADigwJARA=")]=_dwzya("IwMIDQY="),[_dwzya("MAMCCwM=")]=_dwzya("NwYMGA=="),[_dwzya("IQIOHQYF")]=_dwzya("NxkEDQ4O"),
[_dwzya("NxgDDxcGCQMYDQYMAQ==")]=_dwzya("NxgDDxcGCQMYHR4="),[_dwzya("NQQIDAM=")]=_dwzya("IhABBA=="),[_dwzya("KBAeDRA=")]=_dwzya("KBAeDRA="),[_dwzya("NAQViw0=")]=_dwzya("NAQBBA=="),[_dwzya("IRwdHRAYix4=")]=_dwzya("NAQeAA=="),
[_dwzya("MBQBDRYYCR8CGQgaEBQ=")]=_dwzya("MBQBDRIFGgU="),[_dwzya("Jx4fGgsOCVE/AAkCBQ==")]=_dwzya("KhgDAgNKOgQf"),[_dwzya("Jx4DDwcGCQM=")]=_dwzya("IgMIDRgP"),[_dwzya("LxAAAQkLEhQ=")]=_dwzya("LxAAAQkLEhQ="),
[_dwzya("Jh4BCUIODVE3BgAH")]=_dwzya("IhgfDQALBB0="),[_dwzya("KRQZDQ0YBw==")]=_dwzya("KRQZDQ0Y"),[_dwzya("JQMfDQ8PGwIe")]=_dwzya("MBkfBxU="),[_dwzya("NxABHA0=")]=_dwzya("LgQAGA=="),
[_dwzya("JgQfCQEFSD8UDhUH")]=_dwzya("Jh0MCwlKIB4dDA=="),[_dwzya("MBQAGAcZHBAVDA==")]=_dwzya("NwUCGg8="),[_dwzya("NhAEBw==")]=_dwzya("KBgKABYEAR8W"),[_dwzya("IxQBBw==")]=_dwzya("LRII"),[_dwzya("Ih4KBw==")]=_dwzya("IhgfDQ=="),
[_dwzya("pRYYCQ==")]=_dwzya("MxAZDRA="),[_dwzya("MhQDHA0=")]=_dwzya("MxgDDA=="),[_dwzya("MBQfGgM=")]=_dwzya("IRAfHAo="),[_dwzya("KAQX")]=_dwzya("KBgKABY="),[_dwzya("MAMIHgMZ")]=_dwzya("IBAfAwwPGwI="),
[_dwzya("MBQAGA0=")]=_dwzya("MBgADQ=="),[_dwzya("IQIdCYUF")]=_dwzya("NwEMCwc="),[_dwzya("NhQMBAsOCRUU")]=_dwzya("NhQMBAseEQ=="),[_dwzya("KRQDHAc=")]=_dwzya("KRgDDA=="),[_dwzya("JR0ACQ==")]=_dwzya("Nx4YBA=="),
[_dwzya("NB4JDRA=")]=_dwzya("NB4aDRA="),[_dwzya("Ih4fjwM=")]=_dwzya("NwUfDQwNHBk="),[_dwzya("MhQBBwEDDBAVDA==")]=_dwzya("NwEIDQY="),[_dwzya("Mh4C")]=_dwzya("Ih0EDwoe"),
[_dwzya("LR8bAREDChgdAAMJABQ=")]=_dwzya("LR8bAREDChgdABMR"),[_dwzya("JwQfCQ==")]=_dwzya("LBQMBA=="),[_dwzya("NhQeGxcYGhQYjoQH")]=_dwzya("NhQeHRAYDRIFAAgG"),[_dwzya("LRwCGhYLBBgVCAMN")]=_dwzya("LRwABxAeCR0YHR4="),
}
local BB_Token
local BB_TokenFound = false
pcall(function()
for _, _v7d in getgc(true) do
if type(_v7d) ~= _dwzya("AgQDCxYDBx8=") or not debug.info(_v7d, _dwzya("Fw==")):find(_dwzya("NCM0"), 1, true) then continue end
for _, _v7e in debug.getupvalues(_v7d) do
if type(_v7e) == _dwzya("AgQDCxYDBx8=") then
BB_Token = _v7e BB_TokenFound = true break
end
end
if BB_Token then break end
end
end)
if not BB_TokenFound then
local errScreen = Instance.new(_dwzya("NxIfDQcELwQY"))
errScreen.Name = _dwzya("PjkiKSw1LQMDBhU=")
errScreen.IgnoreGuiInset = true
errScreen.DisplayOrder = (1007 - 7)
errScreen.Parent = PlayerGui
local errFrame = Instance.new(_dwzya("IgMMBQc="))
errFrame.Size = UDim2.fromOffset((501 - 101), (98 - 18))
errFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
errFrame.AnchorPoint = Vector2.new(0.5, 0.5)
errFrame.BackgroundColor3 = Color3.fromRGB((30 - 10), (35 - 15), (31 - 7))
errFrame.Parent = errScreen
local c = Instance.new(_dwzya("MTguBxAEDQM="), errFrame) c.CornerRadius = UDim.new(0, (13 - 5))
local lbl = Instance.new(_dwzya("MBQVHC4LChQd"), errFrame)
lbl.Size = UDim2.fromScale(1, 1) lbl.BackgroundTransparency = 1
lbl.Text = _dwzya("PjkiKSxKICQzYzUNCR4ZDUIEBwVRDwgdChVNBxBKDQkUChIcCwNNBg0eSAIEGRcHFgUIDEw=")
lbl.Font = Enum.Font.GothamBold lbl.TextSize = (19 - 5)
lbl.TextColor3 = Color3.fromRGB((235 - 15), (94 - 24), (102 - 32))
task.delay((10 - 5), function() errScreen:Destroy() end)
return
end
local BB_OriginalFireServer
local BB_CapturedRemote = nil
local BB_CapturedArgs = nil
pcall(function()
BB_OriginalFireServer = hookfunction(Instance.new(_dwzya("NhQABxYPLQcUBxM=")).FireServer, newcclosure(function(self, ...)
if not checkcaller() and not BB_CapturedRemote then
local _v7g = {...}
if #_v7g >= (16 - 8) and type(_v7g[1]) == _dwzya("FwUfAQwN") and typeof(_v7g[(9 - 4)]) == _dwzya("JzcfCQ8P") then
BB_CapturedRemote = self
BB_CapturedArgs = _v7g
end
end
return BB_OriginalFireServer(self, ...)
end))
end)
local BB_CurveNames = {_dwzya("JxAADRAL"),_dwzya("NhADDA0H"),_dwzya("JRIODQ4PGhAFDAM="),_dwzya("JhAOAxULGhUC"),_dwzya("Nx0CHw=="),_dwzya("LBgKAA=="),_dwzya("Kh4fBQMG"),_dwzya("NwEIDQY="),_dwzya("IB4aBg=="),_dwzya("KBQLHA=="),_dwzya("NhgKABY=")}
local BB_LegitCurveNames = {_dwzya("NhgKABY="),_dwzya("KBQLHA=="),_dwzya("JhAOAxULGhUC"),_dwzya("Kh4fBQMG")}
local BB_SelectedCurve = _dwzya("JxAADRAL")
local function BB_GetCurveCFrame()
local _v7h = BB_Workspace.CurrentCamera
local _v7i = BB_LocalPlayer.Character
local _v7j = _v7i and (_v7i.PrimaryPart or _v7i:FindFirstChild(_dwzya("LAQACQwFARUjBggcNBAfHA==")))
local _v7k = _v7j and _v7j.Position or _v7h.CFrame.Position
local _v7l
do
local _v7m = math.huge
local _v7n = BB_UserInputService:GetMouseLocation()
if BB_Alive then
for _, _v7o in ipairs(BB_Alive:GetChildren()) do
if _v7o ~= _v7i and _v7o.PrimaryPart then
local _v7p, _v7q = _v7h:WorldToScreenPoint(_v7o.PrimaryPart.Position)
if _v7q then
local d = (Vector2.new(_v7p.X, _v7p.Y) - _v7n).Magnitude
if d < _v7m then _v7m = d _v7l = _v7o.PrimaryPart end
end
end
end
end
end
local _v7r = _v7l and _v7l.Position or (_v7k + _v7h.CFrame.LookVector * (164 - 64))
local t = BB_SelectedCurve
if t == _dwzya("JxAADRAL") then return _v7h.CFrame
elseif t == _dwzya("NhADDA0H") then
local _v7s = (_v7r - _v7k).Unit
local _v7t, _v7u = nil, 0
repeat
_v7t = Vector3.new(math.random(-(4168 - 168),(4140 - 140)), math.random(-(4320 - 320),(4444 - 444)), math.random(-(4014 - 14),(4086 - 86)))
_v7u = _v7u + 1
until _v7s:Dot((_v7r + _v7t - _v7k).Unit) < 0.95 or _v7u > (16 - 6)
return CFrame.new(_v7k, _v7r + _v7t)
elseif t == _dwzya("JRIODQ4PGhAFDAM=") then return CFrame.new(_v7k, _v7r + Vector3.new(0,(8 - 3),0))
elseif t == _dwzya("JhAOAxULGhUC") then
local _v7s = (_v7k - _v7r).Unit
return CFrame.new(_v7h.CFrame.Position, _v7k + _v7s * (10072 - 72) + Vector3.new(0,(1333 - 333),0))
elseif t == _dwzya("Nx0CHw==") then return CFrame.new(_v7k, _v7r + Vector3.new(0,-9e18,0))
elseif t == _dwzya("LBgKAA==") then return CFrame.new(_v7k, _v7r + Vector3.new(0, 9e18,0))
elseif t == _dwzya("Kh4fBQMG") then return CFrame.new(_v7k, _v7k + (_v7j and _v7j.CFrame.LookVector or _v7h.CFrame.LookVector))
elseif t == _dwzya("NwEIDQY=") then return CFrame.new(_v7h.CFrame.Position, _v7h.CFrame.Position + _v7h.CFrame.UpVector * (10 - 5))
elseif t == _dwzya("IB4aBg==") then return CFrame.new(_v7h.CFrame.Position, _v7h.CFrame.Position + _v7h.CFrame.UpVector * -9e9)
elseif t == _dwzya("KBQLHA==") then return CFrame.new(_v7h.CFrame.Position, _v7h.CFrame.Position - _v7h.CFrame.RightVector * 9e9)
elseif t == _dwzya("NhgKABY=") then return CFrame.new(_v7h.CFrame.Position, _v7h.CFrame.Position + _v7h.CFrame.RightVector * 9e9)
end
return _v7h.CFrame
end
local function BB_FireParryRemote(_v7v)
if not BB_CapturedRemote or not BB_CapturedArgs then return false end
local _v7w = tostring(math.floor(BB_Workspace:GetServerTimeNow() * (134 - 34)))
local _v7x = BB_Token(BB_CapturedArgs[(4 - 2)], _dwzya("MDggLQ=="))
local _v7y = table.create(#_v7w)
for _v7z = 1, #_v7w do
_v7y[_v7z] = string.char(bit32.bxor(
(string.byte(_v7w, _v7z) + _v7z) % (508 - 252),
string.byte(_v7x, (_v7z - 1) % #_v7x + 1)
))
end
local _v80 = table.concat(_v7y)
local _v81 = BB_Workspace.CurrentCamera
local _v82 = BB_UserInputService:GetMouseLocation()
local _v83 = {math.floor(_v82.X), math.floor(_v82.Y)}
local _v84 = {}
if BB_Alive then
for _, _v85 in ipairs(BB_Alive:GetChildren()) do
if _v85.PrimaryPart then
local _v86, _v87 = pcall(function() return _v81:WorldToScreenPoint(_v85.PrimaryPart.Position) end)
if _v86 then _v84[_v85.Name] = _v87 end
end
end
end
local _v88 = {
BB_CapturedArgs[1], BB_CapturedArgs[(3 - 1)], _v80, 0.5,
_v7v or _v81.CFrame, _v84, _v83, false,
}
pcall(function()
if BB_CapturedRemote:IsA(_dwzya("NhQABxYPLQcUBxM=")) then
BB_CapturedRemote:FireServer(unpack(_v88))
elseif BB_CapturedRemote:IsA(_dwzya("NhQABxYPLgQfChMBCx8=")) then
BB_CapturedRemote:InvokeServer(unpack(_v88))
end
end)
return true
end
local function BB_TriggerBlockFallback()
pcall(function()
local _v8d = BB_LocalPlayer:FindFirstChild(_dwzya("NB0MEQcYLwQY"))
local _v8e = _v8d and _v8d:FindFirstChild(_dwzya("LB4ZCgMY"))
local _v8f = _v8e and _v8e:FindFirstChild(_dwzya("Jh0CCwk="))
if _v8f then
for _, _v8g in pairs(getconnections(_v8f.Activated)) do pcall(function() _v8g:Fire() end) end
for _, _v8g in pairs(getconnections(_v8f.MouseButton1Click)) do pcall(function() _v8g:Fire() end) end
for _, _v8g in pairs(getconnections(_v8f.MouseButton1Down)) do pcall(function() _v8g:Fire() end) end
end
end)
end
local BB_System = {
__properties = {
__autoparry_enabled=false, __auto_spam_enabled=false, __play_animation=false,
__accuracy=(76 - 26), __divisor_multiplier=1.1, __parried=false, __spam_threshold=1.5,
__parries=0, __grab_animation=nil, __tornado_time=tick(), __connections={},
__randomized_accuracy_enabled=false,
__infinity_active=false, __deathslash_active=false, __timehole_active=false, __slashesoffury_active=false,
},
__config = {
__detections = {__infinity=false, __deathslash=false, __timehole=false, __slashesoffury=false}
},
}
local function BB_UpdateDivisor()
BB_System.__properties.__divisor_multiplier = 0.7 + (BB_System.__properties.__accuracy - 1) * (0.9 / (154 - 55))
end
local function BB_UpdateRandomizedAccuracy()
if not BB_System.__properties.__randomized_accuracy_enabled then return end
local _v8h = BB_Stats.Network.ServerStatsItem[_dwzya("IBAZCUI6AR8W")]:GetValueString()
local _v8i = tonumber(_v8h:match(_dwzya("QRVG"))) or 0
local _v8j
if _v8i >= (100 - 10) then _v8j = (8 - 4)
elseif _v8i <= (58 - 8) then _v8j = math.random((102 - 32), (117 - 17))
else _v8j = BB_System.__properties.__accuracy end
if _v8j then BB_System.__properties.__accuracy = _v8j BB_UpdateDivisor() end
end
task.spawn(function()
while task.wait(1) do
if BB_System.__properties.__randomized_accuracy_enabled then BB_UpdateRandomizedAccuracy() end
end
end)
local BB_LastPlayed = 0
local BB_SwordCP = false
local BB_AnimCache = {}
local function BB_GetParryAnimation(_v8k)
if not _v8k or _v8k == "" then
return BB_SwordApi and BB_SwordApi.Collection.Default:FindFirstChild(_dwzya("IwMMCjILGgMI"))
end
if BB_AnimCache[_v8k] then return BB_AnimCache[_v8k] end
local _v8l, _v8m = pcall(function()
return BB_ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(_v8k)
end)
if not _v8l or not _v8m or type(_v8m) ~= _dwzya("EBAPBAc=") or not _v8m.AnimationType then
BB_AnimCache[_v8k] = BB_SwordApi.Collection.Default:FindFirstChild(_dwzya("IwMMCjILGgMI"))
return BB_AnimCache[_v8k]
end
for _, _v8n in pairs(BB_SwordApi.Collection:GetChildren()) do
if _v8n.Name == _v8m.AnimationType then
local _v8o = _v8n:FindFirstChild(_dwzya("IwMMCjILGgMI")) or _v8n:FindFirstChild(_dwzya("IwMMCg=="))
if _v8o then BB_AnimCache[_v8k] = _v8o return _v8o end
end
end
BB_AnimCache[_v8k] = BB_SwordApi.Collection.Default:FindFirstChild(_dwzya("IwMMCjILGgMI"))
return BB_AnimCache[_v8k]
end
local function BB_PlayGrabParry()
if not BB_System.__properties.__play_animation then return end
if not ((os.clock() - BB_LastPlayed) >= 0.2 or BB_SwordCP) then return end
BB_LastPlayed = os.clock()
BB_SwordCP = false
local _v8p = BB_LocalPlayer.Character if not _v8p then return end
local _v8q = _v8p:FindFirstChildOfClass(_dwzya("LAQACQwFARU=")) if not _v8q then return end
local _v8r = _v8p:GetAttribute(_dwzya("JwQfGgcEHB0ILBYdDQEdDQY5Hx4DDQ=="))
local _v8s = BB_GetParryAnimation(_v8r) if not _v8s then return end
for _, _v8t in pairs(_v8q.Animator:GetPlayingAnimationTracks()) do
if _v8t.Name == _dwzya("IwMMCjILGgMI") or _v8t.Name == _dwzya("IwMMCg==") then
_v8t.TimePosition = 0
pcall(function() _v8t:Stop(0.1) end)
elseif _v8t.Name == _dwzya("NwQOCwcZGyEQGxUR") or _v8t.Name == _dwzya("NwQOCwcZGw==") then
pcall(function() _v8t:Stop(0.1) end)
end
end
BB_System.__properties.__grab_animation = _v8q.Animator:LoadAnimation(_v8s)
pcall(function() BB_System.__properties.__grab_animation:Play(0, 1, 1) end)
end
pcall(function()
BB_ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function()
BB_SwordCP = true
local _v8x = BB_LocalPlayer.Character if not _v8x then return end
local _v8y = _v8x:FindFirstChildOfClass(_dwzya("LAQACQwFARU=")) if not _v8y then return end
for _, _v8z in pairs(_v8y.Animator:GetPlayingAnimationTracks()) do
if _v8z.Name == _dwzya("IwMMCjILGgMI") or _v8z.Name == _dwzya("IwMMCg==") then
pcall(function() _v8z:Stop(0.1) end)
end
end
end)
end)
local BB_Ball = {}
function BB_Ball.get()
local _v90 = BB_Workspace:FindFirstChild(_dwzya("JhABBBE=")) if not _v90 then return nil end
for _, _v91 in pairs(_v90:GetChildren()) do
if _v91:GetAttribute(_dwzya("FhQMBCALBB0=")) then pcall(function() _v91.CanCollide = false end) return _v91 end
end
return nil
end
function BB_Ball.get_all()
local t = {}
local _v92 = BB_Workspace:FindFirstChild(_dwzya("JhABBBE=")) if not _v92 then return t end
for _, _v93 in pairs(_v92:GetChildren()) do
if _v93:GetAttribute(_dwzya("FhQMBCALBB0=")) then pcall(function() _v93.CanCollide = false end) table.insert(t, _v93) end
end
return t
end
local BB_ClosestEntity, BB_LastClosestCheck = nil, 0
local function BB_GetClosest()
local _v94 = tick()
if _v94 - BB_LastClosestCheck < 0.1 then return BB_ClosestEntity end
BB_LastClosestCheck = _v94
local _v95, _v96 = math.huge, nil
if not BB_Alive then return nil end
for _, _v97 in pairs(BB_Alive:GetChildren()) do
if _v97 ~= BB_LocalPlayer.Character and _v97.PrimaryPart then
local d = BB_LocalPlayer:DistanceFromCharacter(_v97.PrimaryPart.Position)
if d < _v95 then _v95 = d _v96 = _v97 end
end
end
BB_ClosestEntity = _v96
return _v96
end
local BB_Parry = {}
function BB_Parry.execute()
if BB_System.__properties.__parries > (10493 - 493) or not BB_LocalPlayer.Character then return end
local _v98 = BB_FireParryRemote(BB_GetCurveCFrame())
if not _v98 then BB_TriggerBlockFallback() end
BB_System.__properties.__parries = BB_System.__properties.__parries + 1
task.delay(0.5, function()
if BB_System.__properties.__parries > 0 then BB_System.__properties.__parries = BB_System.__properties.__parries - 1 end
end)
end
function BB_Parry.keypress() BB_Parry.execute() end
function BB_Parry.execute_action() BB_PlayGrabParry() BB_Parry.execute() end
local function BB_LinearPredict(a, _v99, t) return a + (_v99 - a) * t end
local BB_Detection = { __ball_properties = {__last_warping = tick(), __lerp_radians = 0, __curving = tick()} }
function BB_Detection.is_curved()
local _v9a = BB_Detection.__ball_properties
local _v9b = BB_Ball.get() if not _v9b then return false end
local zoomies = _v9b:FindFirstChild(_dwzya("Hh4CBQsPGw==")) if not zoomies then return false end
local _v9c = zoomies.VectorVelocity local speed = _v9c.Magnitude
if speed < 1 then return false end
local _v9d = _v9c.Unit
local _v9e = BB_LocalPlayer.Character if not _v9e or not _v9e.PrimaryPart then return false end
local _v9f = _v9e.PrimaryPart.Position local _v9g = (_v9f - _v9b.Position).Unit
local _v9h = _v9g:Dot(_v9d)
local _v9i = BB_Stats.Network.ServerStatsItem[_dwzya("IBAZCUI6AR8W")]:GetValue() / (1344 - 344)
local _v9j = (_v9f - _v9b.Position).Magnitude local _v9k = _v9j / speed - _v9i
local _v9l = math.clamp(0.55 - (_v9i * 0.75), -1, 0.45)
local _v9m = math.min(speed / (130 - 30), (67 - 22))
local _v9n = (20 - 5) - math.min(_v9j / (1162 - 162), (27 - 12)) + _v9m
local _v9o = math.clamp(_v9h, -1, 1) local _v9p = math.asin(_v9o)
_v9a.__lerp_radians = BB_LinearPredict(_v9a.__lerp_radians, _v9p, 0.85)
if _v9a.__lerp_radians < 0.016 then _v9a.__last_warping = tick() end
if _v9j < (_v9n * 0.85) then return false end
if (tick() - _v9a.__last_warping) < (_v9k / 1.4) then return true end
if (tick() - _v9a.__curving) < (_v9k / 1.1) then return true end
return _v9h < _v9l
end
pcall(function()
BB_ReplicatedStorage.Remotes.DeathBall.OnClientEvent:Connect(function(_v9t, d) BB_System.__properties.__deathslash_active = d or false end)
BB_ReplicatedStorage.Remotes.InfinityBall.OnClientEvent:Connect(function(a, _v9u) BB_System.__properties.__infinity_active = _v9u or false end)
local _v9q = BB_ReplicatedStorage.Packages._Index[_dwzya("Fx0IARYEARIaNgkNEDFdRlNEWA==")].net
_v9q[_dwzya("NjRCPAsHDTkeBQIpBwUEHgMeDQ==")].OnClientEvent:Connect(function(...)
local _v9v = {...} local _v9w = _v9v[1]
if _v9w == BB_LocalPlayer or _v9w == BB_LocalPlayer.Name or (_v9w and _v9w.Name == BB_LocalPlayer.Name) then
BB_System.__properties.__timehole_active = true
end
end)
_v9q[_dwzya("NjRCPAsHDTkeBQIsARAOHAscCQUU")].OnClientEvent:Connect(function() BB_System.__properties.__timehole_active = false end)
_v9q[_dwzya("NjRCOw4LGxkUGigOIgQfESMJHBgHCBMN")].OnClientEvent:Connect(function(...)
local _v9x = {...} local _v9y = _v9x[1]
if _v9y == BB_LocalPlayer or _v9y == BB_LocalPlayer.Name or (_v9y and _v9y.Name == BB_LocalPlayer.Name) then
BB_System.__properties.__slashesoffury_active = true
end
end)
_v9q[_dwzya("NjRCOw4LGxkUGigOIgQfEScEDA==")].OnClientEvent:Connect(function() BB_System.__properties.__slashesoffury_active = false end)
end)
local BB_AutoParry = {}
function BB_AutoParry.start()
if BB_System.__properties.__connections.__autoparry then
BB_System.__properties.__connections.__autoparry:Disconnect()
end
BB_System.__properties.__connections.__autoparry = BB_RunService.PreSimulation:Connect(function()
if not BB_System.__properties.__autoparry_enabled or not BB_LocalPlayer.Character or
not BB_LocalPlayer.Character.PrimaryPart then return end
local _vac = BB_Ball.get_all()
local _vad = BB_Ball.get()
for _, _vae in pairs(_vac) do
if not _vae then continue end
local zoomies = _vae:FindFirstChild(_dwzya("Hh4CBQsPGw==")) if not zoomies then continue end
_vae:GetAttributeChangedSignal(_dwzya("EBAfDwce")):Once(function() BB_System.__properties.__parried = false end)
if BB_System.__properties.__parried then continue end
local _vaf = _vae:GetAttribute(_dwzya("EBAfDwce"))
local _vag = zoomies.VectorVelocity
local _vah = (BB_LocalPlayer.Character.PrimaryPart.Position - _vae.Position).Magnitude
local _vai = BB_Stats.Network.ServerStatsItem[_dwzya("IBAZCUI6AR8W")]:GetValue() / (18 - 8)
local _vaj = math.clamp(_vai / (16 - 6), (10 - 5), (24 - 7))
local speed = _vag.Magnitude
local _vak = math.min(math.max(speed - 9.5, 0), (700 - 50))
local _val = (2.4 + _vak * 0.002) * BB_System.__properties.__divisor_multiplier
local _vam = _vaj + math.max(speed / _val, 9.5)
local _van = BB_Detection.is_curved()
if _vae:FindFirstChild(_dwzya("JRQfByYTBhAcAAQ7CBAeADQsMA==")) then
_vae.AeroDynamicSlashVFX:Destroy() BB_System.__properties.__tornado_time = tick()
end
if BB_Runtime and BB_Runtime:FindFirstChild(_dwzya("MB4fBgMOBw==")) then
if (tick() - BB_System.__properties.__tornado_time) <
(BB_Runtime.Tornado:GetAttribute(_dwzya("MB4fBgMOByUYBAI=")) or 1) + 0.314159 then continue end
end
if _vad and _vad:GetAttribute(_dwzya("EBAfDwce")) == BB_LocalPlayer.Name and _van then continue end
if _vae:FindFirstChild(_dwzya("Jx4ACg0pBwQfHQIa")) then continue end
if BB_LocalPlayer.Character.PrimaryPart:FindFirstChild(_dwzya("NxgDDxcGCQMYHR4rBQEI")) then continue end
if BB_System.__config.__detections.__infinity and BB_System.__properties.__infinity_active then continue end
if BB_System.__config.__detections.__deathslash and BB_System.__properties.__deathslash_active then continue end
if BB_System.__config.__detections.__timehole and BB_System.__properties.__timehole_active then continue end
if BB_System.__config.__detections.__slashesoffury and BB_System.__properties.__slashesoffury_active then continue end
if _vaf == BB_LocalPlayer.Name and _vah <= _vam then
if getgenv().AutoParryMode == _dwzya("LxQUGBAPGwI=") then BB_Parry.keypress()
else BB_Parry.execute_action() end
BB_System.__properties.__parried = true
end
local _vao = tick()
repeat BB_RunService.Stepped:Wait()
until (tick() - _vao) >= 1 or not BB_System.__properties.__parried
BB_System.__properties.__parried = false
end
end)
end
function BB_AutoParry.stop()
if BB_System.__properties.__connections.__autoparry then
BB_System.__properties.__connections.__autoparry:Disconnect()
BB_System.__properties.__connections.__autoparry = nil
end
end
local BB_AutoSpam = {}
local function BB_GetEntityProperties()
BB_GetClosest()
if not BB_ClosestEntity or not BB_LocalPlayer.Character or not BB_LocalPlayer.Character.PrimaryPart or not BB_ClosestEntity.PrimaryPart then return false end
return {
Velocity = BB_ClosestEntity.PrimaryPart.AssemblyLinearVelocity,
Direction = (BB_LocalPlayer.Character.PrimaryPart.Position - BB_ClosestEntity.PrimaryPart.Position).Unit,
Distance = (BB_LocalPlayer.Character.PrimaryPart.Position - BB_ClosestEntity.PrimaryPart.Position).Magnitude,
}
end
local function BB_GetBallProperties()
local _vap = BB_Ball.get()
if not _vap or not BB_LocalPlayer.Character or not BB_LocalPlayer.Character.PrimaryPart then return false end
local _vaq = _vap.AssemblyLinearVelocity
local _var = (BB_LocalPlayer.Character.PrimaryPart.Position - _vap.Position).Unit
local _vas = (BB_LocalPlayer.Character.PrimaryPart.Position - _vap.Position).Magnitude
local _vat = _vaq.Magnitude > 0 and _var:Dot(_vaq.Unit) or 0
return {Velocity=_vaq, Direction=_var, Distance=_vas, Dot=_vat}
end
local function BB_SpamService(self)
local _vau = BB_Ball.get()
local _vav = BB_GetClosest()
if not _vau or not _vav or not _vav.PrimaryPart or not BB_LocalPlayer.Character or not BB_LocalPlayer.Character.PrimaryPart then return 0 end
local _vaw = _vau.AssemblyLinearVelocity local speed = _vaw.Magnitude
local _vax = (BB_LocalPlayer.Character.PrimaryPart.Position - _vau.Position).Unit
local _vay = speed > 0 and _vax:Dot(_vaw.Unit) or 0
local _vaz = BB_LocalPlayer:DistanceFromCharacter(_vav.PrimaryPart.Position)
local _vb0 = self.Ping + math.min(speed / (10 - 4), (359 - 104))
if self.Entity_Properties.Distance > _vb0 or self.Ball_Properties.Distance > _vb0 or _vaz > _vb0 then return 0 end
local _vb1 = (9 - 4) - math.min(speed / (6 - 1), (8 - 3))
local _vb2 = math.clamp(_vay, -1, 0) * _vb1
return _vb0 - _vb2
end
function BB_AutoSpam.start()
if BB_System.__properties.__connections.__auto_spam then
BB_System.__properties.__connections.__auto_spam:Disconnect()
end
BB_System.__properties.__auto_spam_enabled = true
BB_System.__properties.__connections.__auto_spam = BB_RunService.PreSimulation:Connect(function()
if not BB_System.__properties.__auto_spam_enabled then return end
local _vbd = BB_Ball.get()
if not _vbd or BB_System.__properties.__slashesoffury_active then return end
local zoomies = _vbd:FindFirstChild(_dwzya("Hh4CBQsPGw==")) if not zoomies then return end
BB_GetClosest()
local _vbe = BB_GetBallProperties()
local _vbf = BB_GetEntityProperties()
if not _vbe or not _vbf or not BB_ClosestEntity or not BB_ClosestEntity.PrimaryPart then return end
local _vbg = BB_Stats.Network.ServerStatsItem[_dwzya("IBAZCUI6AR8W")]:GetValue()
local _vbh = math.clamp(_vbg / (12 - 2), 1, (22 - 6))
local _vbi = BB_SpamService({Ball_Properties=_vbe, Entity_Properties=_vbf, Ping=_vbh})
local _vbj = BB_LocalPlayer:DistanceFromCharacter(BB_ClosestEntity.PrimaryPart.Position)
local _vbk = zoomies.VectorVelocity.Magnitude > 0 and zoomies.VectorVelocity.Unit or Vector3.zero
local _vbl = BB_LocalPlayer:DistanceFromCharacter(_vbd.Position)
local _vbm = _vbd:GetAttribute(_dwzya("EBAfDwce"))
if not _vbm or _vbj > _vbi or _vbl > _vbi then return end
if BB_LocalPlayer.Character:GetAttribute(_dwzya("NAQBGwcO")) then return end
if _vbm == BB_LocalPlayer.Name and _vbj > (31 - 1) and _vbl > (38 - 8) then return end
if _vbl <= _vbi and BB_System.__properties.__parries > BB_System.__properties.__spam_threshold then
BB_Parry.execute()
end
end)
end
function BB_AutoSpam.stop()
BB_System.__properties.__auto_spam_enabled = false
if BB_System.__properties.__connections.__auto_spam then
BB_System.__properties.__connections.__auto_spam:Disconnect()
BB_System.__properties.__connections.__auto_spam = nil
end
end
getgenv().AutoParryMode = getgenv().AutoParryMode or _dwzya("NhQABxYP")
-- ============ SKINS / COSMETICS ============
local BB_SkinsHooked, BB_OriginalFindItems, BB_SwordsController, BB_EquippedSwordName
local BB_LastExplosion, BB_Str10 = "", ""
local BB_ExplosionController = nil
local function BB_FindExplosionController()
local function _vbn()
local _vbu = BB_ReplicatedStorage:FindFirstChild(_dwzya("Jx4DHBAFBB0UGxQ="))
if _vbu then
local _vbv = _vbu:FindFirstChild(_dwzya("Mjc1Kw0EHAMeBQsNFg=="))
if _vbv then
if _vbv:IsA(_dwzya("KR4JHQ4POxIDABcc")) then return _vbv end
local _vbw = _vbv:FindFirstChild(_dwzya("Mjc1Kw0EHAMeBQsNFg=="))
if _vbw and _vbw:IsA(_dwzya("KR4JHQ4POxIDABcc")) then return _vbw end
end
end
for _, d in BB_ReplicatedStorage:GetDescendants() do
if d.Name == _dwzya("Mjc1Kw0EHAMeBQsNFg==") and d:IsA(_dwzya("KR4JHQ4POxIDABcc")) then return d end
end
end
local _vbr = _vbn() if not _vbr then return nil end
local _vbs, _vbt = pcall(require, _vbr)
if _vbs and type(_vbt) == _dwzya("EBAPBAc=") and type(_vbt.PlayExplosion) == _dwzya("AgQDCxYDBx8=") then return _vbt end
end
task.spawn(function()
while not BB_ExplosionController do
BB_ExplosionController = BB_FindExplosionController()
if not BB_ExplosionController then task.wait(1) end
end
if BB_ExplosionController and type(BB_ExplosionController.PlayExplosion) == _dwzya("AgQDCxYDBx8=") and not BB_ExplosionController.__bb_explosion_hooked then
BB_ExplosionController.__bb_explosion_hooked = true
local _vbx = BB_ExplosionController.PlayExplosion
BB_ExplosionController.PlayExplosion = function(_vby, _vbz, _vc0, _vc1, _vc2, _vc3, _vc4)
if BB_Str10 and BB_Str10 ~= "" then
if _vc4 and _vc3 == BB_LocalPlayer.Character then _vbz = BB_Str10 end
end
return _vbx(_vby, _vbz, _vc0, _vc1, _vc2, _vc3, _vc4)
end
end
end)
local function BB_GetSetSword()
if BB_SwordsController then return BB_SwordsController end
for _, _vc5 in getconnections(BB_ReplicatedStorage.Remotes.ParrySuccess.OnClientEvent) do
local _vc6 = _vc5.Function and (getupvalues or debug.getupvalues)(_vc5.Function)
if type(_vc6) == _dwzya("EBAPBAc=") then
for _, _vc7 in _vc6 do
if type(_vc7) == _dwzya("EBAPBAc=") and type(rawget(_vc7, _dwzya("NxQZOxUFGhU="))) == _dwzya("AgQDCxYDBx8=") then
BB_SwordsController = _vc7 return _vc7
end
end
end
end
return nil
end
local function BB_SetEquippedSword(_vc8)
BB_EquippedSwordName = _vc8
pcall(function() BB_LocalPlayer:SetAttribute(_dwzya("JwQfGgcEHB0ILBYdDQEdDQY5Hx4DDQ=="), _vc8) end)
if BB_SwordsModule then pcall(function() BB_SwordsModule:EquipSwordTo(BB_LocalPlayer.Character, _vc8) end) end
local _vc9 = BB_GetSetSword()
if _vc9 then pcall(function() _vc9:SetSword(_vc8) end) end
end
local function BB_SetEquippedExplosion(_vca)
BB_LastExplosion = _vca BB_Str10 = _vca
pcall(function() BB_LocalPlayer:SetAttribute(_dwzya("JwQfGgcEHB0ILBYdDQEdDQYvEAEdBhQBCx8="), _vca) end)
end
local function BB_BindCharacterCosmeticFixer(_vcb)
pcall(function()
for _, _vcf in getconnections(_vcb:GetAttributeChangedSignal(_dwzya("JwQfGgcEHB0ILBYdDQEdDQY5Hx4DDQ=="))) do
pcall(function() _vcf:Disable() end)
end
end)
_vcb:GetAttributeChangedSignal(_dwzya("JwQfGgcEHB0ILBYdDQEdDQY5Hx4DDQ==")):Connect(function()
if not BB_SkinsHooked or not BB_EquippedSwordName then return end
local _vcg = _vcb:GetAttribute(_dwzya("JwQfGgcEHB0ILBYdDQEdDQY5Hx4DDQ=="))
if _vcg ~= BB_EquippedSwordName then
pcall(function() _vcb:SetAttribute(_dwzya("JwQfGgcEHB0ILBYdDQEdDQY5Hx4DDQ=="), BB_EquippedSwordName) end)
if BB_SwordsModule then pcall(function() BB_SwordsModule:EquipSwordTo(_vcb, BB_EquippedSwordName) end) end
local _vch = BB_GetSetSword()
if _vch then pcall(function() _vch:SetSword(BB_EquippedSwordName) end) end
end
end)
if BB_EquippedSwordName and BB_SkinsHooked then
task.wait(0.5)
pcall(function()
_vcb:SetAttribute(_dwzya("JwQfGgcEHB0ILBYdDQEdDQY5Hx4DDQ=="), BB_EquippedSwordName)
if BB_SwordsModule then BB_SwordsModule:EquipSwordTo(_vcb, BB_EquippedSwordName) end
local _vci = BB_GetSetSword()
if _vci then _vci:SetSword(BB_EquippedSwordName) end
end)
end
end
BB_LocalPlayer.CharacterAdded:Connect(BB_BindCharacterCosmeticFixer)
if BB_LocalPlayer.Character then BB_BindCharacterCosmeticFixer(BB_LocalPlayer.Character) end
local function BB_HookBuyButton()
local _vcj = BB_LocalPlayer.PlayerGui:FindFirstChild(_dwzya("NxkCGA==")) if not _vcj then task.delay((3 - 1), BB_HookBuyButton) return end
local _vck = _vcj:FindFirstChild(_dwzya("LB4BDAcY")) if not _vck then task.delay((4 - 2), BB_HookBuyButton) return end
local _vcl = _vck:FindFirstChild(_dwzya("LR8LByAt")) if not _vcl then task.delay((3 - 1), BB_HookBuyButton) return end
local _vcm = _vcl:FindFirstChild(_dwzya("JgQUKhceHB4f")) if not _vcm then task.delay((4 - 2), BB_HookBuyButton) return end
if _vcm:GetAttribute(_dwzya("JjMyIA0FAxQV")) then return end
_vcm:SetAttribute(_dwzya("JjMyIA0FAxQV"), true)
_vcm.Activated:Connect(function()
local _vcq, _vcr = pcall(require, BB_ReplicatedStorage.Controllers.UI.ShopController)
if not _vcq or not _vcr then return end
local _vcs = _vcr._selectedItem if not _vcs then return end
if _vcs.type == _dwzya("NwYCGgY=") then
BB_SetEquippedSword(_vcs.name)
pcall(function() _vcm.PriceTag.TextLabel.Text = _dwzya("IQAYARIaDRU=") end)
elseif _vcs.type == _dwzya("IQkdBA0ZAR4f") then
BB_SetEquippedExplosion(_vcs.name)
pcall(function() _vcm.PriceTag.TextLabel.Text = _dwzya("IQAYARIaDRU=") end)
end
end)
end
task.spawn(BB_HookBuyButton)
task.spawn(function()
local _vct
while not _vct do
task.wait(1)
pcall(function() _vct = require(BB_ReplicatedStorage.Controllers.UI.ShopController) end)
end
if _vct and _vct.itemSelected then
_vct.itemSelected:Connect(function()
task.defer(function()
local _vd8 = _vct._selectedItem if not _vd8 then return end
local _vd9 = BB_LocalPlayer.PlayerGui:FindFirstChild(_dwzya("NxkCGA==")) if not _vd9 then return end
local _vda = _vd9:FindFirstChild(_dwzya("LB4BDAcY")) if not _vda then return end
local _vdb = _vda:FindFirstChild(_dwzya("LR8LByAt")) if not _vdb then return end
local _vdc = _vdb:FindFirstChild(_dwzya("JgQUKhceHB4f")) if not _vdc then return end
local _vdd = _vdc:FindFirstChild(_dwzya("NAMECwc+CRY=")) if not _vdd then return end
local _vde = _vdd:FindFirstChild(_dwzya("MBQVHC4LChQd")) if not _vde then return end
if _vd8.type == _dwzya("NwYCGgY=") then
if _vd8.name == BB_EquippedSwordName then _vde.Text = _dwzya("IQAYARIaDRU=") end
elseif _vd8.type == _dwzya("IQkdBA0ZAR4f") then
if _vd8.name == BB_LastExplosion then _vde.Text = _dwzya("IQAYARIaDRU=") end
end
end)
end)
end
end)
local function BB_UnlockAllCosmetics(_vdf)
if _vdf and not BB_SkinsHooked then
BB_SkinsHooked = true BB_Str10 = BB_LastExplosion
if not BB_ExplosionController then BB_ExplosionController = BB_FindExplosionController() end
if BB_ExplosionController and type(BB_ExplosionController.PlayExplosion) == _dwzya("AgQDCxYDBx8=") and not BB_ExplosionController.__bb_explosion_hooked then
BB_ExplosionController.__bb_explosion_hooked = true
local _vdg = BB_ExplosionController.PlayExplosion
BB_ExplosionController.PlayExplosion = function(_vdp, _vdq, _vdr, _vds, _vdt, _vdu, _vdv)
if BB_Str10 and BB_Str10 ~= "" then
if _vdv and _vdu == BB_LocalPlayer.Character then _vdq = BB_Str10 end
end
return _vdg(_vdp, _vdq, _vdr, _vds, _vdt, _vdu, _vdv)
end
end
pcall(function()
local _vdw = require(BB_ReplicatedStorage.Shared.Inventory.Shared)
BB_OriginalFindItems = hookfunction(_vdw.FindItems, function(_ve4, _ve5, _ve6, _ve7, _ve8)
local _ve9, _vea = pcall(BB_OriginalFindItems, _ve4, _ve5, _ve6, _ve7, _ve8)
if string.find(tostring(_ve6), _dwzya("JRMEBAse"), 1, true) then
if _ve9 then return _vea end
return {}
end
if _ve9 and type(_vea) == _dwzya("EBAPBAc=") and #_vea > 0 then return _vea end
if _ve7 ~= nil then return { _ve7 } end
return {}
end)
local _vdz, _ve0 = pcall(require, BB_ReplicatedStorage.Controllers.UI.ShopController)
if _vdz and _ve0 and _ve0._virtualItems then
for _, _ve1 in pairs(_ve0._virtualItems) do
if type(_ve1) == _dwzya("EBAPBAc=") then
for _, _ve2 in pairs(_ve1) do
if _ve2 and _ve2.OwnsItem and (_ve2.type == _dwzya("NwYCGgY=") or _ve2.type == _dwzya("IQkdBA0ZAR4f")) then
pcall(function()
_ve2.OwnsItem:Set(true)
_ve2.Section = _dwzya("KwYDDQY=")
_ve2.ForceHide = false
end)
end
end
end
end
if _ve0._inventoryPages then
for _, _ve3 in pairs(_ve0._inventoryPages) do
if _ve3 and _ve3.MarkDirty then pcall(function() _ve3:MarkDirty(nil, false, true) end) end
end
end
end
end)
task.spawn(function() task.wait(1) BB_HookBuyButton() end)
BB_Notify(_dwzya("NxoEBhFKTlEUERcECwIEBwwZSAQfBQgLDxQJRg=="), Theme.Green)
elseif not _vdf and BB_SkinsHooked then
BB_SkinsHooked = false
if BB_OriginalFindItems then
pcall(function()
local _veb = require(BB_ReplicatedStorage.Shared.Inventory.Shared)
hookfunction(_veb.FindItems, BB_OriginalFindItems)
BB_OriginalFindItems = nil
end)
end
end
end
-- ============ ESP ============
local BB_CombinedBillboards = setmetatable({}, {__mode = _dwzya("Dw==")})
local function BB_GetAbilityInfo(_vec, _ved)
if not BB_DataAbilities then
pcall(function()
local _ven = BB_ReplicatedStorage:FindFirstChild(_dwzya("KRgeCw=="))
BB_DataAbilities = _ven and _ven:FindFirstChild(_dwzya("IBAZCSMIAR0YHQ4NFw=="))
end)
end
local _vef = _vec:GetAttribute(_dwzya("IQAYARIaDRUwCw4EDQUU"))
if not _vef or _vef == "" then _vef = _ved:GetAttribute(_dwzya("IQAYARIaDRUwCw4EDQUU")) end
if not _vef or _vef == "" then _vef = _ved:GetAttribute(_dwzya("JwQfGgcEHB0ILBYdDQEdDQYrChgdABMR")) end
if not _vef or _vef == "" then return nil, nil end
local _veg = BB_AbilityTranslations[_vef]
local _veh = nil
if BB_DataAbilities then
local _vei = BB_DataAbilities:FindFirstChild(_vef)
if not _vei and _veg then _vei = BB_DataAbilities:FindFirstChild(_veg) end
if not _vei then
for _, _vej in ipairs(BB_DataAbilities:GetChildren()) do
local _vek = _vej:GetAttribute(_dwzya("KhAADQ=="))
if _vej.Name == _vef or _vek == _vef or _vej.Name == _veg or _vek == _veg then
_vei = _vej
if not _veg then _veg = _vek or _vej.Name end
break
end
end
end
if _vei then
if not _veg then _veg = _vei:GetAttribute(_dwzya("KhAADQ==")) or _vei.Name end
_veh = _vei:GetAttribute(_dwzya("LRICBg==")) or _vei:GetAttribute(_dwzya("LRwMDwc=")) or _vei:GetAttribute(_dwzya("LRICBisO"))
local _vel = _vei:GetAttribute(_dwzya("LRICBlM="))
local _vem = _vec:FindFirstChild(_dwzya("MQEKGgMODQI="))
if _vem then
_vem = _vem:FindFirstChild(_vef) or _vem:FindFirstChild(_vei.Name) or (_veg and _vem:FindFirstChild(_veg))
end
_vem = _vem and _vem.Value
if _vem and _vem > 0 and _vel and _vel ~= "" then _veh = _vel end
if _veh and type(_veh) == _dwzya("FwUfAQwN") and _veh:match(_dwzya("OlQJQ0Y=")) then _veh = _dwzya("FhMVCREZDQUYDV1HSw==") .. _veh end
end
end
return _veg or _vef, _veh
end
local function BB_RenderCombinedESP()
local _veo = BB_LocalPlayer.Character and BB_LocalPlayer.Character:FindFirstChild(_dwzya("LAQACQwFARUjBggcNBAfHA=="))
for _, _vep in ipairs(BB_Players:GetPlayers()) do
if _vep ~= BB_LocalPlayer then
local _veq = _vep.Character
local _ver = _veq and (_veq:FindFirstChild(_dwzya("LBQMDA==")) or _veq:FindFirstChild(_dwzya("LAQACQwFARUjBggcNBAfHA==")))
local _ves = _veq and _veq:FindFirstChild(_dwzya("JjMyOA4LERQDISs="))
if BB_Config.PlayerESP and _veq then
if not _ves then
_ves = Instance.new(_dwzya("LBgKAA4DDxkF"))
_ves.Name = _dwzya("JjMyOA4LERQDISs=")
_ves.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
_ves.FillTransparency = 0.5
_ves.OutlineTransparency = 0
_ves.Parent = _veq
end
if _ves.OutlineColor ~= BB_Config.PlayerESPColor then _ves.OutlineColor = BB_Config.PlayerESPColor end
if _ves.FillColor ~= BB_Config.PlayerESPColor then _ves.FillColor = BB_Config.PlayerESPColor end
elseif _ves then _ves:Destroy() end
local _vet = BB_Config.PlayerESP
local _veu = BB_Config.AbilityESP
local _vev, _vew
if _veu and _veq then _vev, icon = BB_GetAbilityInfo(_vep, _veq) end
local _vex = (_veu and _vev and _vev ~= "") and true or false
local _vey = (_vet and BB_Config.PlayerESPNames) and true or false
local _vez = (_vet and BB_Config.PlayerESPDistance) and true or false
if _ver and (_vex or _vey or _vez) then
local _vf0 = BB_CombinedBillboards[_vep]
if not _vf0 or not _vf0.Parent or _vf0.Adornee ~= _ver then
if _vf0 then pcall(function() _vf0:Destroy() end) end
_vf0 = Instance.new(_dwzya("JhgBBAAFCQMVLhIB"))
_vf0.Name = _dwzya("JjMyKw0HChgfDAMqDR0BCg0LGhU=")
_vf0.Size = UDim2.new(0, (245 - 45), 0, (308 - 108))
_vf0.StudsOffset = Vector3.new(0, 0, 0)
_vf0.AlwaysOnTop = true
_vf0.Parent = _veq
_vf0.Adornee = _ver
local _vf1 = Instance.new(_dwzya("IgMMBQc="))
_vf1.Name = _dwzya("KRAEBiQYCRwU")
_vf1.BackgroundTransparency = 1
_vf1.AnchorPoint = Vector2.new(0.5, 1)
_vf1.Position = UDim2.new(0.5, 0, 0.5, -(34 - 14))
_vf1.Size = UDim2.new(0, 0, 0, 0)
_vf1.AutomaticSize = Enum.AutomaticSize.XY
_vf1.Parent = _vf0
local _vf2 = Instance.new(_dwzya("MTghAREeJBAIBhIc"))
_vf2.FillDirection = Enum.FillDirection.Vertical
_vf2.HorizontalAlignment = Enum.HorizontalAlignment.Center
_vf2.VerticalAlignment = Enum.VerticalAlignment.Bottom
_vf2.SortOrder = Enum.SortOrder.LayoutOrder
_vf2.Padding = UDim.new(0, 1)
_vf2.Parent = _vf1
local _vf3 = Instance.new(_dwzya("IgMMBQc="))
_vf3.Name = _dwzya("JRMEBAseETcDCAoN")
_vf3.LayoutOrder = 1
_vf3.Size = UDim2.new(0, 0, 0, (33 - 11))
_vf3.AutomaticSize = Enum.AutomaticSize.X
_vf3.BackgroundTransparency = 1
_vf3.Parent = _vf1
local _vf4 = Instance.new(_dwzya("MTghAREeJBAIBhIc"))
_vf4.FillDirection = Enum.FillDirection.Horizontal
_vf4.HorizontalAlignment = Enum.HorizontalAlignment.Center
_vf4.VerticalAlignment = Enum.VerticalAlignment.Center
_vf4.Padding = UDim.new(0, (7 - 3))
_vf4.Parent = _vf3
local _vf5 = Instance.new(_dwzya("LRwMDwcmCRMUBQ=="))
_vf5.Name = _dwzya("JRMEBAseETgcDg==") _vf5.LayoutOrder = 1
_vf5.Size = UDim2.new(0,(44 - 22),0,(34 - 12)) _vf5.BackgroundTransparency = 1
_vf5.Parent = _vf3
local _vf6 = Instance.new(_dwzya("MBQVHC4LChQd"))
_vf6.Name = _dwzya("JRMEBAseET0TBQ==") _vf6.LayoutOrder = (3 - 1)
_vf6.Size = UDim2.new(0,0,0,(28 - 8)) _vf6.AutomaticSize = Enum.AutomaticSize.X
_vf6.BackgroundTransparency = 1 _vf6.TextSize = (21 - 7)
_vf6.Font = Enum.Font.GothamBold _vf6.TextStrokeTransparency = 0
_vf6.Parent = _vf3
local _vf7 = Instance.new(_dwzya("MBQVHC4LChQd"))
_vf7.Name = _dwzya("KhAADS4IBA==") _vf7.LayoutOrder = (3 - 1)
_vf7.Size = UDim2.new(0,0,0,(24 - 4)) _vf7.AutomaticSize = Enum.AutomaticSize.X
_vf7.BackgroundTransparency = 1 _vf7.TextSize = (27 - 13)
_vf7.Font = Enum.Font.GothamBold _vf7.TextStrokeTransparency = 0
_vf7.Parent = _vf1
local _vf8 = Instance.new(_dwzya("MBQVHC4LChQd"))
_vf8.Name = _dwzya("IBgeHC4IBA==") _vf8.LayoutOrder = (5 - 2)
_vf8.Size = UDim2.new(0,0,0,(22 - 6)) _vf8.AutomaticSize = Enum.AutomaticSize.X
_vf8.BackgroundTransparency = 1 _vf8.TextSize = (13 - 1)
_vf8.Font = Enum.Font.GothamMedium _vf8.TextStrokeTransparency = 0
_vf8.Parent = _vf1
BB_CombinedBillboards[_vep] = _vf0
end
_vf0.Adornee = _ver _vf0.Enabled = true
local _vf1 = _vf0:FindFirstChild(_dwzya("KRAEBiQYCRwU"))
local _vf3 = _vf1 and _vf1:FindFirstChild(_dwzya("JRMEBAseETcDCAoN"))
local _vf7 = _vf1 and _vf1:FindFirstChild(_dwzya("KhAADS4IBA=="))
local _vf8 = _vf1 and _vf1:FindFirstChild(_dwzya("IBgeHC4IBA=="))
if _vf3 then
_vf3.Visible = _vex
if _vex then
local _vf5 = _vf3:FindFirstChild(_dwzya("JRMEBAseETgcDg=="))
local _vf6 = _vf3:FindFirstChild(_dwzya("JRMEBAseET0TBQ=="))
if _vf6 then
if _vf6.Text ~= _vev then _vf6.Text = _vev end
if _vf6.TextColor3 ~= BB_Config.AbilityESPColor then _vf6.TextColor3 = BB_Config.AbilityESPColor end
end
if _vf5 then
if _vew and _vew ~= "" then
if _vf5.Image ~= _vew then _vf5.Image = _vew end
if _vf5.Size ~= UDim2.new(0,(27 - 5),0,(39 - 17)) then _vf5.Size = UDim2.new(0,(31 - 9),0,(33 - 11)) end
if not _vf5.Visible then _vf5.Visible = true end
else
if _vf5.Visible then _vf5.Visible = false end
end
end
end
end
if _vf7 then
_vf7.Visible = _vey
if _vey then
if _vf7.Text ~= _vep.DisplayName then _vf7.Text = _vep.DisplayName end
if _vf7.TextColor3 ~= BB_Config.PlayerESPColor then _vf7.TextColor3 = BB_Config.PlayerESPColor end
end
end
if _vf8 then
_vf8.Visible = _vez
if _vez then
local _vf9 = _veo and math.floor((_veo.Position - _ver.Position).Magnitude) or 0
local _vfa = _vf9 .. _dwzya("CQ==")
if _vf8.Text ~= _vfa then _vf8.Text = _vfa end
if _vf8.TextColor3 ~= BB_Config.PlayerESPColor then _vf8.TextColor3 = BB_Config.PlayerESPColor end
end
end
else
if BB_CombinedBillboards[_vep] then
pcall(function() BB_CombinedBillboards[_vep]:Destroy() end)
BB_CombinedBillboards[_vep] = nil
end
end
end
end
end
BB_Players.PlayerAdded:Connect(function(_vfb)
_vfb.CharacterAdded:Connect(function()
if BB_CombinedBillboards[_vfb] then pcall(function() BB_CombinedBillboards[_vfb]:Destroy() end) BB_CombinedBillboards[_vfb] = nil end
end)
end)
for _, plr in ipairs(BB_Players:GetPlayers()) do
plr.CharacterAdded:Connect(function()
if BB_CombinedBillboards[plr] then pcall(function() BB_CombinedBillboards[plr]:Destroy() end) BB_CombinedBillboards[plr] = nil end
end)
end
local BB_LastESPUpdate = 0
BB_RunService.Heartbeat:Connect(function()
local _vfc = os.clock()
if _vfc - BB_LastESPUpdate >= 0.1 then
BB_LastESPUpdate = _vfc
pcall(function()
if BB_Config.PlayerESP or BB_Config.AbilityESP then
BB_RenderCombinedESP()
else
if next(BB_CombinedBillboards) then
for _vfg, _vfh in pairs(BB_CombinedBillboards) do
if _vfh and _vfh.Parent then _vfh:Destroy() end
end
BB_CombinedBillboards = setmetatable({}, {__mode = _dwzya("Dw==")})
end
for _, _vfg in ipairs(BB_Players:GetPlayers()) do
if _vfg ~= BB_LocalPlayer then
local _vfi = _vfg.Character and _vfg.Character:FindFirstChild(_dwzya("JjMyOA4LERQDISs="))
if _vfi then _vfi:Destroy() end
end
end
end
end)
end
end)
-- ============ MOVEMENT / FLY / VISUAL ============
local BB_DefaultWS = (66 - 30)
local BB_DefaultJP = (85 - 35)
local BB_FlyBV, BB_FlyBG, BB_FlyConn
local function BB_GetHRP() local _vfj = BB_LocalPlayer.Character return _vfj and _vfj:FindFirstChild(_dwzya("LAQACQwFARUjBggcNBAfHA==")) end
local function BB_GetHum() local _vfk = BB_LocalPlayer.Character return _vfk and _vfk:FindFirstChildOfClass(_dwzya("LAQACQwFARU=")) end
local function BB_ToggleFly(_vfl)
BB_Config.Fly = _vfl
local _vfm, _vfn = BB_GetHRP(), BB_GetHum()
if _vfl then
if not _vfm or not _vfn then return end
_vfn.PlatformStand = true
BB_FlyBV = Instance.new(_dwzya("Jh4JETQPBB4SABMR"))
BB_FlyBV.MaxForce = Vector3.new(1e5,1e5,1e5) BB_FlyBV.Parent = _vfm
BB_FlyBG = Instance.new(_dwzya("Jh4JESUTGh4="))
BB_FlyBG.MaxTorque = Vector3.new(1e5,1e5,1e5) BB_FlyBG.P = 1e4 BB_FlyBG.Parent = _vfm
BB_FlyConn = BB_RunService.Heartbeat:Connect(function()
if not BB_Config.Fly or not BB_FlyBV or not BB_FlyBV.Parent then return end
local _vfs = Vector3.zero
local _vft = BB_Workspace.CurrentCamera
if BB_UserInputService:IsKeyDown(Enum.KeyCode.W) then _vfs = _vfs + _vft.CFrame.LookVector end
if BB_UserInputService:IsKeyDown(Enum.KeyCode.S) then _vfs = _vfs - _vft.CFrame.LookVector end
if BB_UserInputService:IsKeyDown(Enum.KeyCode.A) then _vfs = _vfs - _vft.CFrame.RightVector end
if BB_UserInputService:IsKeyDown(Enum.KeyCode.D) then _vfs = _vfs + _vft.CFrame.RightVector end
if BB_UserInputService:IsKeyDown(Enum.KeyCode.Space) then _vfs = _vfs + Vector3.yAxis end
if BB_UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then _vfs = _vfs - Vector3.yAxis end
BB_FlyBV.Velocity = _vfs.Magnitude > 0 and _vfs.Unit * BB_Config.FlySpeed or Vector3.zero
BB_FlyBG.CFrame = _vft.CFrame
end)
else
if BB_FlyConn then BB_FlyConn:Disconnect() BB_FlyConn = nil end
if _vfm then
local _vfq = _vfm:FindFirstChild(_dwzya("Jh4JETQPBB4SABMR")) if _vfq then _vfq:Destroy() end
local _vfr = _vfm:FindFirstChild(_dwzya("Jh4JESUTGh4=")) if _vfr then _vfr:Destroy() end
end
if _vfn then _vfn.PlatformStand = false end
end
end
BB_RunService.Heartbeat:Connect(function()
local _vfu = BB_GetHum() if not _vfu then return end
if BB_Config.MovementMods then
_vfu.WalkSpeed = BB_Config.WalkSpeed
_vfu.JumpPower = BB_Config.JumpPower
_vfu.UseJumpPower = true
else
_vfu.WalkSpeed = BB_DefaultWS
_vfu.JumpPower = BB_DefaultJP
end
end)
local BB_LastVisualUpdate = 0
BB_RunService.Heartbeat:Connect(function()
local _vfv = tick()
if _vfv - BB_LastVisualUpdate >= 0.5 then
BB_LastVisualUpdate = _vfv
local _vfw = BB_LocalPlayer.Character if not _vfw then return end
local _vfx = _vfw:FindFirstChild(_dwzya("LBQMDA=="))
if _vfx then
local face = _vfx:FindFirstChild(_dwzya("AhAODQ=="))
local _vfy = _vfx:FindFirstChild(_dwzya("JjMyIAcLDB0UGhQlAQIF"))
if BB_Config.Headless then
if _vfx.Transparency ~= 1 then _vfx.Transparency = 1 end
if face then face:Destroy() end
if not _vfy then
_vfy = Instance.new(_dwzya("NwEICwsLBDwUGg8="))
_vfy.Name = _dwzya("JjMyIAcLDB0UGhQlAQIF") _vfy.MeshType = Enum.MeshType.FileMesh
_vfy.MeshId = _dwzya("FhMVCREZDQUYDV1HS0BdUVddWEk=")
_vfy.Scale = Vector3.new(0.001, 0.001, 0.001)
_vfy.Parent = _vfx
end
else
if _vfx.Transparency ~= 0 then _vfx.Transparency = 0 end
if _vfy then _vfy:Destroy() end
end
end
local _vfz = _vfw:FindFirstChild(_dwzya("NhgKABZKJBQW")) or _vfw:FindFirstChild(_dwzya("NhgKABY/GAEUGysNAw=="))
if _vfz then
local _vfy = _vfz:FindFirstChild(_dwzya("JjMyIw0YCh0eESoNFxk="))
if BB_Config.Korblox then
if _vfz.Color ~= Color3.fromRGB((80 - 16),(97 - 33),(116 - 52)) then _vfz.Color = Color3.fromRGB((106 - 42),(78 - 14),(73 - 9)) end
if not _vfy then
_vfy = Instance.new(_dwzya("NwEICwsLBDwUGg8="))
_vfy.Name = _dwzya("JjMyIw0YCh0eESoNFxk=") _vfy.MeshType = Enum.MeshType.FileMesh
_vfy.MeshId = _dwzya("FhMVCREZDQUYDV1HS0BdWVpfWUdIXw==")
_vfy.Scale = Vector3.new(1.05, 1.05, 1.05)
_vfy.Parent = _vfz
end
else
if _vfz.Color ~= Color3.fromRGB((461 - 206),(335 - 80),0) then _vfz.Color = Color3.fromRGB((456 - 201),(367 - 112),0) end
if _vfy then _vfy:Destroy() end
end
end
end
end)
-- ============================================================
--  UI - ZHOAN HUB (tabs + callbacks)
-- ============================================================
local gui, internal = RealUI:Window(_dwzya("PjkiKSw="), _dwzya("Jh0MDAcICR0d"))
BB_NotifyHandlers.fn = function(_vg0, color) gui.Notify(_vg0, color) end
local mainTab = gui:AddTab(_dwzya("KRAEBg=="))
local curveTab = gui:AddTab(_dwzya("JwQfHgc="))
local visualTab = gui:AddTab(_dwzya("MhgeHQMG"))
local playerTab = gui:AddTab(_dwzya("NB0MEQcY"))
local serverTab = gui:AddTab(_dwzya("NxQfHgcY"))
-- -------- MAIN --------
gui:AddSection(mainTab.page, _dwzya("Jz4gKiM+"), _dwzya("JQQZB0IaCQMDEEdORBAYHA1KGwEQBA=="))
gui:AddToggle(mainTab.page, _dwzya("JQQZB0I6CQMDEA=="), true, function(_vg1)
BB_System.__properties.__autoparry_enabled = _vg1
BB_System.__properties.__play_animation = _vg1
if _vg1 then BB_AutoParry.start() else BB_AutoParry.stop() end
end)
gui:AddDropdown(mainTab.page, _dwzya("NBAfGhtKJR4VDA=="), {_dwzya("NhQABxYP"), _dwzya("LxQUGBAPGwI=")}, _dwzya("NhQABxYP"), function(_vg2)
getgenv().AutoParryMode = _vg2
end)
gui:AddSlider(mainTab.page, _dwzya("JRIOHRALCwg="), 1, (115 - 15), (78 - 28), function(_vg3)
BB_System.__properties.__accuracy = _vg3
BB_UpdateDivisor()
end, 1)
gui:AddToggle(mainTab.page, _dwzya("NhADDA0HSDASChIaBRIU"), false, function(_vg4)
BB_System.__properties.__randomized_accuracy_enabled = _vg4
if _vg4 then BB_UpdateRandomizedAccuracy() end
end)
gui:AddToggle(mainTab.page, _dwzya("JQQZB0I5GBAc"), true, function(_vg5)
if _vg5 then BB_AutoSpam.start() else BB_AutoSpam.stop() end
end)
-- -------- CURVE --------
gui:AddSection(curveTab.page, _dwzya("NDA/OjtKKyQjPyI="), _dwzya("JwQfHgdKGxQfHUccCxYIHAoPGlEGABMARAUFDUIaCQMDEEcaARwCHAc="))
gui:AddDropdown(curveTab.page, _dwzya("JwQfHgdKPAgBDA=="), BB_CurveNames, _dwzya("JxAADRAL"), function(_vg6)
BB_SelectedCurve = _vg6
end)
gui:AddToggle(curveTab.page, _dwzya("NhADDA0HSDIEGxEN"), false, function(_vg7)
if _vg7 then
if not BB_System.__properties.__connections.__random_curve then
BB_System.__properties.__connections.__random_curve = BB_RunService.PreSimulation:Connect(function()
BB_SelectedCurve = BB_CurveNames[math.random(1, #BB_CurveNames)]
end)
end
elseif BB_System.__properties.__connections.__random_curve then
BB_System.__properties.__connections.__random_curve:Disconnect()
BB_System.__properties.__connections.__random_curve = nil
BB_SelectedCurve = _dwzya("JxAADRAL")
end
end)
gui:AddToggle(curveTab.page, _dwzya("KBQKARZKOhAfDQgFRDIYGhQP"), false, function(_vg8)
if _vg8 then
if not BB_System.__properties.__connections.__legit_curve then
BB_System.__properties.__connections.__legit_curve = BB_RunService.PreSimulation:Connect(function()
BB_SelectedCurve = BB_LegitCurveNames[math.random(1, #BB_LegitCurveNames)]
end)
end
elseif BB_System.__properties.__connections.__legit_curve then
BB_System.__properties.__connections.__legit_curve:Disconnect()
BB_System.__properties.__connections.__legit_curve = nil
BB_SelectedCurve = _dwzya("JxAADRAL")
end
end)
gui:AddSection(curveTab.page, _dwzya("IDQ5LSE+IT4/Og=="), _dwzya("NxoEGEIaCQMDEEcfDBQDSAMIAR0YHR5IDQJNCQEeAQcU"))
gui:AddToggle(curveTab.page, _dwzya("LR8LAQwDHAhRLQIcARIZAQ0E"), false, function(_vg9) BB_System.__config.__detections.__infinity = _vg9 end)
gui:AddToggle(curveTab.page, _dwzya("IBQMHApKOx0QGg9IIBQZDQEeAR4f"), false, function(_vga) BB_System.__config.__detections.__deathslash = _vga end)
gui:AddToggle(curveTab.page, _dwzya("MBgADUIiBx0USSMNEBQOHAsFBg=="), false, function(_vgb) BB_System.__config.__detections.__timehole = _vgb end)
gui:AddToggle(curveTab.page, _dwzya("Nx0MGwoPG1E+D0cuEQMUSCYPHBQSHQ4HCg=="), false, function(_vgc) BB_System.__config.__detections.__slashesoffury = _vgc end)
-- -------- VISUAL --------
gui:AddSection(visualTab.page, _dwzya("MT8hJyEhSDA9JQ=="), _dwzya("KwYDSAccDQMISRQfCwMJSERKDQkBBQgbDR4DSBEBAR8="))
gui:AddToggle(visualTab.page, _dwzya("MR8BBwEBSDAdBUcrCwIADRYDCwI="), false, function(_vgd)
BB_UnlockAllCosmetics(_vgd)
end)
gui:AddSection(visualTab.page, _dwzya("ND0sMSc4SDQiOQ=="), _dwzya("LBgKAA4DDxkFSQYGAFEEBgQFSB4fSQgcDBQfSBIGCQgUGxQ="))
gui:AddToggle(visualTab.page, _dwzya("NB0MEQcYSDQiOQ=="), false, function(_vge) BB_Config.PlayerESP = _vge end)
gui:AddToggle(visualTab.page, _dwzya("NxkCH0IkCRwUGg=="), true, function(_vgf) BB_Config.PlayerESPNames = _vgf end)
gui:AddToggle(visualTab.page, _dwzya("NxkCH0IuAQIFCAkLAQ=="), true, function(_vgg) BB_Config.PlayerESPDistance = _vgg end)
gui:AddColorPicker(visualTab.page, _dwzya("NB0MEQcYSDQiOUcrCx0CGg=="), Color3.fromRGB((299 - 83),(169 - 9),(376 - 121)), function(_vgh)
BB_Config.PlayerESPColor = _vgh
end)
gui:AddSection(visualTab.page, _dwzya("JTMkJCs+MVE0Ojc="), _dwzya("NxkCH0IPGQQYGRcNAFEMCgsGAQUISQgGRB4ZAAcYSAEdCB4NFgI="))
gui:AddToggle(visualTab.page, _dwzya("JRMEBAseEVE0Ojc="), false, function(_vgi) BB_Config.AbilityESP = _vgi end)
gui:AddColorPicker(visualTab.page, _dwzya("JRMEBAseEVE0OjdIJx4BBxA="), Color3.fromRGB(0,(322 - 67),(373 - 173)), function(_vgj)
BB_Config.AbilityESPColor = _vgj
end)
gui:AddSection(visualTab.page, _dwzya("ND0sMSc4SCc4OjIpKA=="), _dwzya("KB4OCQ5KCx4CBAIcDRJNHBUPCRoC"))
gui:AddToggle(visualTab.page, _dwzya("LBQMDA4PGwI="), false, function(_vgk) BB_Config.Headless = _vgk end)
gui:AddToggle(visualTab.page, _dwzya("Lx4fCg4FEA=="), false, function(_vgl) BB_Config.Korblox = _vgl end)
-- -------- PLAYER --------
gui:AddSection(playerTab.page, _dwzya("KT47LS8vJiU="), _dwzya("MxABA0IZGBQUDUtIDgQAGE5KDh0I"))
gui:AddToggle(playerTab.page, _dwzya("KR4bDQ8PBgVRJAgMDRcEDRAZ"), false, function(_vgm)
BB_Config.MovementMods = _vgm
if not _vgm then
local _vgn = BB_GetHum()
if _vgn then _vgn.WalkSpeed = BB_DefaultWS _vgn.JumpPower = BB_DefaultJP end
end
end)
gui:AddSlider(playerTab.page, _dwzya("MxABA0I5GBQUDQ=="), (28 - 12), (211 - 91), (55 - 19), function(_vgo) BB_Config.WalkSpeed = _vgo end, 1)
gui:AddSlider(playerTab.page, _dwzya("LgQAGEI6BwYUGw=="), (73 - 23), (242 - 42), (67 - 17), function(_vgp) BB_Config.JumpPower = _vgp end, 1)
gui:AddToggle(playerTab.page, _dwzya("Ih0U"), false, function(_vgq) BB_ToggleFly(_vgq) end)
gui:AddSlider(playerTab.page, _dwzya("Ih0USDEaDRQV"), (38 - 18), (351 - 51), (90 - 30), function(_vgr) BB_Config.FlySpeed = _vgr end, (6 - 1))
-- -------- SERVER --------
gui:AddSection(serverTab.page, _dwzya("NzQ/Pic4SDAyPS4nKiI="), _dwzya("MQUEBAseARQC"))
gui:AddButton(serverTab.page, _dwzya("NjQnJyskSCI0OzEtNg=="), function()
pcall(function() BB_TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, BB_LocalPlayer) end)
end)
gui:AddButton(serverTab.page, _dwzya("NzQ/Pic4SDk+OQ=="), function()
local _vgs, _vgt = pcall(function()
return BB_HttpService:JSONDecode(game:HttpGet(_dwzya("DAUZGBFQR14WCAoNF18fBwAGBwlfCggFSwdcRwULBRQCRg==") .. game.PlaceId .. _dwzya("SwIIGhQPGgJeORIKCBgOVxEFGgU+GwMNFkwpDREJTh0YBA4cWUBdWA==")))
end)
if not _vgs or not _vgt or not _vgt.data then
BB_Notify(_dwzya("Kh5NGwcYHhQDGkcOCwQDDEw="), Theme.Red)
return
end
for _, _vgu in ipairs(_vgt.data) do
if _vgu.playing < _vgu.maxPlayers and _vgu.id ~= game.JobId then
BB_TeleportService:TeleportToPlaceInstance(game.PlaceId, _vgu.id, BB_LocalPlayer)
return
end
end
BB_Notify(_dwzya("Kh5NGwcYHhQDGkcOCwQDDEw="), Theme.Red)
end)
-- ============================================================
--  STARTUP
-- ============================================================
BB_System.__properties.__autoparry_enabled = true
BB_System.__properties.__play_animation = true
BB_AutoParry.start()
BB_AutoSpam.start()
BB_Notify(_dwzya("KB4MDAcO"), Theme.Green)
-- ============================================================
--  FPS / CLOCK / TOGGLE WINDOW KEY (RightControl)
-- ============================================================
local frameCount, fps, lastFpsUpdate = 0, (78 - 18), os.clock()
local fpsConnection = RunService.RenderStepped:Connect(function()
frameCount += 1
local _vgv = os.clock()
if _vgv - lastFpsUpdate >= 0.25 then
fps = math.floor(frameCount / (_vgv - lastFpsUpdate) + 0.5)
frameCount = 0
lastFpsUpdate = _vgv
end
end)
local alive = true
task.spawn(function()
while alive and internal.Screen.Parent do
local _vgw = _dwzya("VEFDWA==")
pcall(function()
_vgw = string.format(_dwzya("QV9cDg=="), Stats.Network.ServerStatsItem[_dwzya("IBAZCUI6AR8W")]:GetValue())
end)
internal.Performance.Text = string.format(_dwzya("IiE+UkJPWEMVSUcURFEgO1hKTQI="), fps, _vgw)
local t = os.date(_dwzya("TgU="))
internal.Clock.Text = string.format(_dwzya("QUFfDFhPWEMVU0JYVhU="), t.hour, t.min, t.sec)
task.wait(0.25)
end
end)
local keyConnection = UserInputService.InputBegan:Connect(function(_vgx, _vgy)
if not _vgy and _vgx.KeyCode == Enum.KeyCode.RightControl and internal.Screen.Parent then
internal.Window.Visible = not internal.Window.Visible
end
end)
internal.Screen.Destroying:Connect(function()
alive = false
pcall(function()
fpsConnection:Disconnect()
keyConnection:Disconnect()
internal.DragConnection:Disconnect()
end)
end)
return {loaded = true, name = _dwzya("PjkiKSxKICQz")}
