-- ==========================================================
-- 🏴‍☠️ ONE PIECE GAEL SCRIPT v6.0 | MM2 MOBILE
-- ==========================================================
local RunService   = game:GetService("RunService")
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local CoreGui      = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Workspace    = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")
local Debris       = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

-- ==========================================================
-- CONFIG
-- ==========================================================
local Config = {
    ESPEnabled    = true,
    ShowNames     = true,
    ShowDistance  = true,
    ESPThickness  = 2,
    AimbotEnabled = true,
    Smooth        = 0.22,
    FOV           = 500,        -- studs range
    ScreenFOV     = 400,        -- pixels (FOV circle radius)
    ShowFOVCircle = true,
    ESPColorMode  = "Role",
    SoundsEnabled = true,
    Weather       = "CalmSea",
}

-- ==========================================================
-- ONE PIECE PALETTE
-- ==========================================================
local OP = {
    -- Sea
    DeepSea   = Color3.fromRGB(12, 42, 88),
    OceanBlue = Color3.fromRGB(30, 100, 170),
    SeaFoam   = Color3.fromRGB(170, 225, 245),
    SkyLight  = Color3.fromRGB(210, 235, 255),
    -- Straw hat
    StrawGold = Color3.fromRGB(255, 210, 90),
    StrawDark = Color3.fromRGB(205, 155, 45),
    HatRed    = Color3.fromRGB(210, 55, 55),
    -- Parchment
    Parchment = Color3.fromRGB(246, 231, 197),
    ParchDark = Color3.fromRGB(215, 195, 155),
    Ink       = Color3.fromRGB(35, 25, 15),
    -- Accents
    Gold      = Color3.fromRGB(235, 195, 70),
    FireRed   = Color3.fromRGB(235, 75, 75),
    Marine    = Color3.fromRGB(70, 135, 225),
    Jolly     = Color3.fromRGB(22, 28, 44),
    White     = Color3.fromRGB(255, 255, 255),
    Muted     = Color3.fromRGB(115, 140, 170),
    Green     = Color3.fromRGB(90, 210, 130),
    Red       = Color3.fromRGB(235, 75, 75),
    Blue      = Color3.fromRGB(90, 160, 255),
}

local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ==========================================================
-- WEATHER THEMES
-- ==========================================================
local Weathers = {
    CalmSea = {
        Name = "Calm Sea",
        Accent = Color3.fromRGB(120, 190, 255),
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 200, 255)),
            ColorSequenceKeypoint.new(0.55, Color3.fromRGB(80, 150, 220)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 100, 175)),
        }),
        Clouds = true, Sun = true, Rain = false, Stars = false,
    },
    Storm = {
        Name = "Storm",
        Accent = Color3.fromRGB(140, 160, 200),
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 80, 100)),
            ColorSequenceKeypoint.new(0.55, Color3.fromRGB(45, 55, 80)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 30, 50)),
        }),
        Clouds = true, Sun = false, Rain = true, Stars = false,
    },
    Sunset = {
        Name = "Sunset",
        Accent = Color3.fromRGB(255, 170, 90),
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 120)),
            ColorSequenceKeypoint.new(0.45, Color3.fromRGB(250, 130, 100)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 65, 140)),
        }),
        Clouds = true, Sun = true, Rain = false, Stars = false,
    },
    NightSea = {
        Name = "Night Sea",
        Accent = Color3.fromRGB(130, 175, 240),
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 45, 95)),
            ColorSequenceKeypoint.new(0.55, Color3.fromRGB(20, 30, 70)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 15, 40)),
        }),
        Clouds = false, Sun = false, Rain = false, Stars = true,
    },
}

-- ==========================================================
-- COMPAT
-- ==========================================================
local HasDrawing = pcall(function() return Drawing.new("Line") end)

-- ==========================================================
-- POOLS
-- ==========================================================
local LinePool, LineIndex = {}, 0
local NameLabels = {}
local FOVCircle = nil
if HasDrawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 60
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.6
    FOVCircle.Color = OP.Gold
    FOVCircle.Visible = false
end

local function GetLine()
    LineIndex += 1
    if not LinePool[LineIndex] then
        local l = Drawing.new("Line")
        l.Transparency = 1; l.Visible = false
        LinePool[LineIndex] = l
    end
    local line = LinePool[LineIndex]
    line.Thickness = Config.ESPThickness
    return line
end

local function ResetLines()
    for _, l in ipairs(LinePool) do l.Visible = false end
    LineIndex = 0
end

local function GetLabel(idx)
    if not NameLabels[idx] then
        local lbl = Drawing.new("Text")
        lbl.Size = 16; lbl.Center = true; lbl.Outline = true
        lbl.OutlineColor = Color3.new(0,0,0); lbl.Visible = false
        NameLabels[idx] = lbl
    end
    return NameLabels[idx]
end

local function ResetLabels()
    for _, l in ipairs(NameLabels) do l.Visible = false end
end

-- ==========================================================
-- SOUND
-- ==========================================================
local function PlaySound(kind)
    if not Config.SoundsEnabled then return end
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxasset://sounds/electronicpingshort.wav"
        s.Volume = 0.35
        s.PlaybackSpeed = (kind == "open" and 1.3)
                       or (kind == "close" and 0.7)
                       or (kind == "success" and 1.5)
                       or 1
        s.Parent = SoundService
        s:Play()
        Debris:AddItem(s, 2)
    end)
end

-- ==========================================================
-- HELPERS
-- ==========================================================
local function HasCharacter(p)
    local c = p and p.Character
    if not c then return false end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    return hrp and hum and hum.Health > 0
end

local function HasTool(p, name)
    if not p then return false end
    local c, bp = p.Character, p:FindFirstChild("Backpack")
    return (c and c:FindFirstChild(name)) or (bp and bp:FindFirstChild(name))
end

local function IsMurder(p)      return HasTool(p, "Knife") end
local function IsSheriff(p)     return HasTool(p, "Gun")   end
local function IsLocalSheriff() return IsSheriff(LocalPlayer) end

local function GetPlayerColor(p)
    if Config.ESPColorMode == "Static" then return OP.Gold end
    if IsMurder(p)  then return OP.FireRed end
    if IsSheriff(p) then return OP.Marine end
    return OP.Green
end

local function GetPlayerRole(p)
    if IsMurder(p)  then return "BLACKBEARD", OP.FireRed end
    if IsSheriff(p) then return "MARINE",     OP.Marine end
    return "NAKAMA", OP.Green
end

-- ==========================================================
-- RAYCAST
-- ==========================================================
local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Exclude

local function CanSee(targetPart)
    local char = LocalPlayer.Character
    if not char then return false end
    local head = char:FindFirstChild("Head")
    if not head then return false end
    RayParams.FilterDescendantsInstances = { char, Camera }
    local result = Workspace:Raycast(head.Position, targetPart.Position - head.Position, RayParams)
    return result == nil or result.Instance:IsDescendantOf(targetPart.Parent)
end

-- ==========================================================
-- ESP
-- ==========================================================
local function GetCorners(cf, size)
    local corners, half = {}, size / 2
    for X=-1,1,2 do for Y=-1,1,2 do for Z=-1,1,2 do
        corners[#corners+1] = (cf * CFrame.new(half.X*X, half.Y*Y, half.Z*Z)).Position
    end end end
    return corners
end

local BoxEdges = {
    {1,2},{2,4},{4,3},{3,1},
    {5,6},{6,8},{8,7},{7,5},
    {1,5},{2,6},{3,7},{4,8},
}

local function DrawFor(player, labelIdx)
    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local cf      = hrp.CFrame * CFrame.new(0, -0.5, 0)
    local corners = GetCorners(cf, Vector3.new(3, 5, 3))
    local color   = GetPlayerColor(player)

    local screen, visible = {}, {}
    for i, v in ipairs(corners) do
        local pos, on = Camera:WorldToViewportPoint(v)
        screen[i]  = Vector2.new(pos.X, pos.Y)
        visible[i] = on
    end
    for _, e in ipairs(BoxEdges) do
        if visible[e[1]] or visible[e[2]] then
            local l = GetLine()
            l.From, l.To = screen[e[1]], screen[e[2]]
            l.Color = color; l.Visible = true
        end
    end
    if Config.ShowNames then
        local head = char:FindFirstChild("Head") or hrp
        local pos, on = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
        if on then
            local role = GetPlayerRole(player)
            local txt
            if Config.ShowDistance then
                local myC = LocalPlayer.Character
                local dist = 0
                if myC and myC:FindFirstChild("HumanoidRootPart") then
                    dist = math.floor((hrp.Position - myC.HumanoidRootPart.Position).Magnitude)
                end
                txt = string.format("%s [%s] %dm", player.Name, role, dist)
            else
                txt = string.format("%s [%s]", player.Name, role)
            end
            local lbl = GetLabel(labelIdx)
            lbl.Text = txt; lbl.Position = Vector2.new(pos.X, pos.Y)
            lbl.Color = color; lbl.Visible = true
        end
    end
end

local function UpdateESP()
    if not HasDrawing then return end
    ResetLines(); ResetLabels()
    if not Config.ESPEnabled or not LocalPlayer.Character then return end
    local idx = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and HasCharacter(p) then
            idx += 1
            pcall(DrawFor, p, idx)
        end
    end
end

-- ==========================================================
-- AIMBOT (with screen FOV)
-- ==========================================================
local function GetCrosshair()
    if IsMobile then
        return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        local m = UIS:GetMouseLocation()
        return Vector2.new(m.X, m.Y)
    end
end

local function GetClosestMurder()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position
    local crosshair = GetCrosshair()

    local best, bestScore = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and HasCharacter(p) and IsMurder(p) then
            local hrp = p.Character.HumanoidRootPart
            local dist = (hrp.Position - myPos).Magnitude
            if dist <= Config.FOV then
                local head = p.Character:FindFirstChild("Head") or hrp
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - crosshair).Magnitude
                    if screenDist <= Config.ScreenFOV and CanSee(head) then
                        if screenDist < bestScore then
                            best, bestScore = head, screenDist
                        end
                    end
                end
            end
        end
    end
    return best
end

local function UpdateFOVCircle(hasTarget)
    if not FOVCircle then return end
    if not Config.ShowFOVCircle or not IsLocalSheriff() then
        FOVCircle.Visible = false
        return
    end
    FOVCircle.Position = GetCrosshair()
    FOVCircle.Radius   = Config.ScreenFOV
    FOVCircle.Color    = hasTarget and OP.FireRed or OP.Gold
    FOVCircle.Transparency = hasTarget and 0.85 or 0.55
    FOVCircle.Visible  = true
end

local function UpdateAimbot()
    local target = nil
    if Config.AimbotEnabled and IsLocalSheriff() then
        target = GetClosestMurder()
        if target then
            local desired = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(desired, Config.Smooth)
        end
    end
    UpdateFOVCircle(target ~= nil)
end

-- ==========================================================
-- SCREEN GUI + RESPONSIVE
-- ==========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OnePieceGael"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
local okGui = pcall(function() ScreenGui.Parent = CoreGui end)
if not okGui then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local uiScale = Instance.new("UIScale", ScreenGui)
local function UpdateUIScale()
    local vp = Camera.ViewportSize
    local minDim = math.min(vp.X, vp.Y)
    uiScale.Scale = math.clamp(minDim / 480, 0.6, 1)
end
UpdateUIScale()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateUIScale)

-- ==========================================================
-- TOASTS
-- ==========================================================
local toastStack = 0
local function ShowToast(text, accent)
    accent = accent or OP.Gold
    toastStack += 1
    local slot = toastStack
    local toast = Instance.new("Frame", ScreenGui)
    toast.Size = UDim2.new(0, 240, 0, 46)
    toast.Position = UDim2.new(1, 20, 0, 20 + (slot-1)*56)
    toast.BackgroundColor3 = OP.Parchment
    toast.BackgroundTransparency = 0.05
    toast.ZIndex = 200
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", toast)
    stroke.Color = accent; stroke.Thickness = 2; stroke.Transparency = 0.15

    local bar = Instance.new("Frame", toast)
    bar.Size = UDim2.new(0, 5, 1, -14)
    bar.Position = UDim2.new(0, 6, 0, 7)
    bar.BackgroundColor3 = accent
    bar.ZIndex = 201
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local label = Instance.new("TextLabel", toast)
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 20, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = OP.Ink
    label.Font = Enum.Font.BuilderSansBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 201

    local tIn = TweenService:Create(toast,
        TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -260, 0, 20 + (slot-1)*56)})
    tIn:Play()

    task.delay(2.3, function()
        local tOut = TweenService:Create(toast,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(1, 20, 0, 20 + (slot-1)*56)})
        tOut:Play()
        tOut.Completed:Wait()
        toast:Destroy()
        toastStack -= 1
    end)
end

-- ==========================================================
-- TOGGLE BUTTON (straw hat pill)
-- ==========================================================
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 158, 0, 46)
ToggleBtn.Position = UDim2.new(0, 15, 0, 60)
ToggleBtn.BackgroundColor3 = OP.Parchment
ToggleBtn.Text = "🏴‍☠️ ONE PIECE"
ToggleBtn.TextColor3 = OP.Ink
ToggleBtn.Font = Enum.Font.BuilderSansBold
ToggleBtn.TextSize = 15
ToggleBtn.ZIndex = 100
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

local tGrad = Instance.new("UIGradient", ToggleBtn)
tGrad.Rotation = 90
tGrad.Color = ColorSequence.new(OP.Parchment, OP.ParchDark)

local tStroke = Instance.new("UIStroke", ToggleBtn)
tStroke.Color = OP.Gold
tStroke.Thickness = 2

-- ==========================================================
-- MAIN WINDOW
-- ==========================================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 330, 0, 510)
MainFrame.Position = UDim2.new(0.5, -165, 0.5, -255)
MainFrame.BackgroundColor3 = OP.White
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 50
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 18)

local mainGradient = Instance.new("UIGradient", MainFrame)
mainGradient.Rotation = 90
mainGradient.Color = Weathers.CalmSea.Gradient

local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = OP.Gold
mainStroke.Thickness = 2.5
mainStroke.Transparency = 0.1

local menuScale = Instance.new("UIScale", MainFrame)
menuScale.Scale = 1

-- ==========================================================
-- WEATHER BACKGROUND LAYERS
-- ==========================================================
local CloudLayer = Instance.new("Frame", MainFrame)
CloudLayer.Size = UDim2.new(1, 0, 1, 0)
CloudLayer.BackgroundTransparency = 1
CloudLayer.ClipsDescendants = true
CloudLayer.ZIndex = 2

local RainLayer = Instance.new("Frame", MainFrame)
RainLayer.Size = UDim2.new(1, 0, 1, 0)
RainLayer.BackgroundTransparency = 1
RainLayer.ClipsDescendants = true
RainLayer.ZIndex = 3
RainLayer.Visible = false

local StarLayer = Instance.new("Frame", MainFrame)
StarLayer.Size = UDim2.new(1, 0, 1, 0)
StarLayer.BackgroundTransparency = 1
StarLayer.ClipsDescendants = true
StarLayer.ZIndex = 2
StarLayer.Visible = false

local SunLayer = Instance.new("Frame", MainFrame)
SunLayer.Size = UDim2.new(0, 60, 0, 60)
SunLayer.Position = UDim2.new(1, -85, 0, 20)
SunLayer.BackgroundColor3 = Color3.fromRGB(255, 230, 130)
SunLayer.BackgroundTransparency = 0.15
SunLayer.BorderSizePixel = 0
SunLayer.ZIndex = 2
SunLayer.Visible = false
Instance.new("UICorner", SunLayer).CornerRadius = UDim.new(1, 0)
local sunStroke = Instance.new("UIStroke", SunLayer)
sunStroke.Color = Color3.fromRGB(255, 240, 170)
sunStroke.Thickness = 4
sunStroke.Transparency = 0.4

-- animated sun pulse
task.spawn(function()
    while ScreenGui.Parent do
        if SunLayer.Visible then
            TweenService:Create(SunLayer, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {BackgroundTransparency = 0.35}):Play()
            task.wait(2)
            TweenService:Create(SunLayer, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {BackgroundTransparency = 0.05}):Play()
            task.wait(2)
        else
            task.wait(0.5)
        end
    end
end)

-- Clouds
local function SpawnCloud(w, h, yScale, dur, transp)
    local cloud = Instance.new("Frame", CloudLayer)
    cloud.Size = UDim2.new(0, w, 0, h)
    cloud.Position = UDim2.new(-0.4, 0, yScale, 0)
    cloud.BackgroundColor3 = OP.White
    cloud.BackgroundTransparency = transp
    cloud.BorderSizePixel = 0
    cloud.ZIndex = 2
    Instance.new("UICorner", cloud).CornerRadius = UDim.new(1, 0)
    for i = 1, 2 do
        local b = Instance.new("Frame", cloud)
        b.Size = UDim2.new(0.6, 0, 0.85, 0)
        b.Position = UDim2.new(0.15 + (i-1)*0.28, 0, -0.25 + i*0.08, 0)
        b.BackgroundColor3 = OP.White
        b.BackgroundTransparency = transp
        b.BorderSizePixel = 0
        b.ZIndex = 2
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    end
    task.spawn(function()
        while cloud.Parent do
            local t = TweenService:Create(cloud,
                TweenInfo.new(dur, Enum.EasingStyle.Linear),
                {Position = UDim2.new(1, 20, yScale, 0)})
            t:Play(); t.Completed:Wait()
            if not cloud.Parent then break end
            cloud.Position = UDim2.new(-0.4, 0, yScale, 0)
            task.wait(math.random(3, 8))
        end
    end)
end
SpawnCloud(110, 34, 0.08, 42, 0.55)
SpawnCloud(150, 44, 0.30, 55, 0.62)
SpawnCloud(90,  28, 0.55, 32, 0.5)
SpawnCloud(130, 40, 0.80, 48, 0.58)

-- Rain
for i = 1, 22 do
    local drop = Instance.new("Frame", RainLayer)
    drop.Size = UDim2.new(0, 2, 0, 14)
    drop.Position = UDim2.new(math.random(), 0, -0.1, 0)
    drop.BackgroundColor3 = Color3.fromRGB(180, 210, 255)
    drop.BackgroundTransparency = 0.4
    drop.ZIndex = 3
    Instance.new("UICorner", drop).CornerRadius = UDim.new(1, 0)
    task.spawn(function()
        while drop.Parent do
            drop.Position = UDim2.new(math.random(), 0, -0.1, 0)
            local t = TweenService:Create(drop,
                TweenInfo.new(0.9 + math.random()*0.4, Enum.EasingStyle.Linear),
                {Position = UDim2.new(drop.Position.X.Scale, 0, 1.1, 0)})
            t:Play(); t.Completed:Wait()
            task.wait(math.random()*0.2)
        end
    end)
end

-- Stars
for i = 1, 26 do
    local star = Instance.new("Frame", StarLayer)
    local size = math.random(2, 4)
    star.Size = UDim2.new(0, size, 0, size)
    star.Position = UDim2.new(math.random(), 0, math.random()*0.85, 0)
    star.BackgroundColor3 = OP.White
    star.BackgroundTransparency = 0.2
    star.BorderSizePixel = 0
    star.ZIndex = 2
    Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
    task.spawn(function()
        while star.Parent do
            local goal = math.random()
            TweenService:Create(star, TweenInfo.new(0.6 + math.random(), Enum.EasingStyle.Sine),
                {BackgroundTransparency = goal}):Play()
            task.wait(0.8 + math.random())
        end
    end)
end

-- Weather applier
local function ApplyWeather(name)
    local w = Weathers[name]
    if not w then return end
    Config.Weather = name
    TweenService:Create(mainGradient, TweenInfo.new(0.9, Enum.EasingStyle.Quad), {
        Color = w.Gradient
    }):Play()
    CloudLayer.Visible = w.Clouds
    RainLayer.Visible  = w.Rain
    StarLayer.Visible  = w.Stars
    SunLayer.Visible   = w.Sun
    mainStroke.Color = w.Accent
    tStroke.Color    = w.Accent
end

-- ==========================================================
-- STRAW HAT ICON (procedural)
-- ==========================================================
local StrawHat = Instance.new("Frame", MainFrame)
StrawHat.Size = UDim2.new(0, 36, 0, 36)
StrawHat.Position = UDim2.new(0, 14, 0, 12)
StrawHat.BackgroundTransparency = 1
StrawHat.ZIndex = 52

local hatCap = Instance.new("Frame", StrawHat)
hatCap.Size = UDim2.new(0, 22, 0, 15)
hatCap.Position = UDim2.new(0, 7, 0, 3)
hatCap.BackgroundColor3 = OP.StrawGold
hatCap.ZIndex = 53
Instance.new("UICorner", hatCap).CornerRadius = UDim.new(0, 10)

local hatBand = Instance.new("Frame", StrawHat)
hatBand.Size = UDim2.new(0, 22, 0, 4)
hatBand.Position = UDim2.new(0, 7, 0, 12)
hatBand.BackgroundColor3 = OP.HatRed
hatBand.ZIndex = 54
Instance.new("UICorner", hatBand).CornerRadius = UDim.new(0, 2)

local hatBrim = Instance.new("Frame", StrawHat)
hatBrim.Size = UDim2.new(0, 34, 0, 7)
hatBrim.Position = UDim2.new(0, 1, 0, 20)
hatBrim.BackgroundColor3 = OP.StrawDark
hatBrim.ZIndex = 53
Instance.new("UICorner", hatBrim).CornerRadius = UDim.new(1, 0)

local hatStroke = Instance.new("UIStroke", hatBrim)
hatStroke.Color = OP.Gold
hatStroke.Thickness = 1
hatStroke.Transparency = 0.3

-- ==========================================================
-- HEADER
-- ==========================================================
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 56)
Header.BackgroundTransparency = 1
Header.ZIndex = 51

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -140, 0, 26)
Title.Position = UDim2.new(0, 56, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "ONE PIECE"
Title.TextColor3 = OP.Gold
Title.Font = Enum.Font.BuilderSansBold
Title.TextSize = 21
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextStrokeColor3 = OP.Jolly
Title.TextStrokeTransparency = 0
Title.ZIndex = 52

local titleGrad = Instance.new("UIGradient", Title)
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 235, 130)),
    ColorSequenceKeypoint.new(0.5, OP.Gold),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 145, 40)),
})

local Subtitle = Instance.new("TextLabel", Header)
Subtitle.Size = UDim2.new(1, -140, 0, 16)
Subtitle.Position = UDim2.new(0, 57, 0, 32)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "⚓ STRAW HAT PIRATES"
Subtitle.TextColor3 = OP.FireRed
Subtitle.Font = Enum.Font.BuilderSansBold
Subtitle.TextSize = 10
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.TextStrokeColor3 = OP.Jolly
Subtitle.TextStrokeTransparency = 0.5
Subtitle.ZIndex = 52

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Position = UDim2.new(1, -46, 0.5, -17)
CloseBtn.BackgroundColor3 = OP.Parchment
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = OP.FireRed
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.ZIndex = 52
CloseBtn.AutoButtonColor = false
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)
local cbStroke = Instance.new("UIStroke", CloseBtn)
cbStroke.Color = OP.Gold; cbStroke.Thickness = 1.5

-- ==========================================================
-- TABS
-- ==========================================================
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, -24, 0, 42)
TabBar.Position = UDim2.new(0, 12, 0, 62)
TabBar.BackgroundColor3 = OP.Parchment
TabBar.BackgroundTransparency = 0.25
TabBar.ZIndex = 51
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(1, 0)
local tbStroke = Instance.new("UIStroke", TabBar)
tbStroke.Color = OP.Gold; tbStroke.Thickness = 1.5; tbStroke.Transparency = 0.3

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 3)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -24, 1, -170)
ContentArea.Position = UDim2.new(0, 12, 0, 112)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 51
ContentArea.ClipsDescendants = true

local Sections = {}
local function CreateSection(name)
    local f = Instance.new("Frame", ContentArea)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.Visible = false
    f.ZIndex = 52
    Sections[name] = f
    return f
end
local ESPPage    = CreateSection("ESP")
local AimbotPage = CreateSection("Aimbot")
local WeatherPage = CreateSection("Weather")
local ConfigPage = CreateSection("Config")

local TabButtons = {}
local currentTab = nil
local function SwitchTab(name)
    for n, p in pairs(Sections) do p.Visible = (n == name) end
    for n, b in pairs(TabButtons) do
        local active = (n == name)
        TweenService:Create(b, TweenInfo.new(0.2), {
            BackgroundColor3 = active and OP.Gold or OP.Parchment,
            BackgroundTransparency = active and 0 or 0.3,
            TextColor3 = active and OP.Ink or OP.Muted,
        }):Play()
    end
    currentTab = name
end

local function CreateTabButton(name)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0, 68, 0, 32)
    btn.BackgroundColor3 = OP.Parchment
    btn.BackgroundTransparency = 0.3
    btn.Text = name
    btn.TextColor3 = OP.Muted
    btn.Font = Enum.Font.BuilderSansBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.ZIndex = 52
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    btn.MouseButton1Click:Connect(function() PlaySound(); SwitchTab(name) end)
    TabButtons[name] = btn
end
CreateTabButton("ESP")
CreateTabButton("Aimbot")
CreateTabButton("Weather")
CreateTabButton("Config")

-- ==========================================================
-- BUILDERS
-- ==========================================================
local function CreateLabel(parent, text, yPos, color)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.Position = UDim2.new(0, 6, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or OP.Muted
    lbl.Font = Enum.Font.BuilderSansBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 100
    return lbl
end

local function CreateToggle(parent, text, yPos, callback, default)
    local state = default ~= false
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 44)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = OP.Parchment
    btn.BackgroundTransparency = 0.15
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 100
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = OP.Gold; stroke.Thickness = 1; stroke.Transparency = 0.55

    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.Text = text
    label.TextColor3 = OP.Ink
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.BuilderSansBold
    label.TextSize = 14
    label.ZIndex = 101

    local switchBg = Instance.new("Frame", btn)
    switchBg.Size = UDim2.new(0, 44, 0, 22)
    switchBg.Position = UDim2.new(1, -56, 0.5, -11)
    switchBg.BackgroundColor3 = state and OP.Gold or OP.ParchDark
    switchBg.ZIndex = 101
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame", switchBg)
    thumb.Size = UDim2.new(0, 18, 0, 18)
    thumb.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    thumb.BackgroundColor3 = OP.White
    thumb.ZIndex = 102
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
    local thStroke = Instance.new("UIStroke", thumb)
    thStroke.Color = OP.StrawDark; thStroke.Thickness = 1

    btn.MouseButton1Click:Connect(function()
        state = not state
        PlaySound()
        TweenService:Create(switchBg, TweenInfo.new(0.25),
            {BackgroundColor3 = state and OP.Gold or OP.ParchDark}):Play()
        TweenService:Create(thumb, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
        }):Play()
        if callback then callback(state) end
    end)
end

local function CreateSlider(parent, text, yPos, minVal, maxVal, defaultVal, callback, decimals)
    decimals = decimals or 2
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundColor3 = OP.Parchment
    frame.BackgroundTransparency = 0.15
    frame.ZIndex = 100
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = OP.Gold; stroke.Thickness = 1; stroke.Transparency = 0.55

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -24, 0, 18)
    label.Position = UDim2.new(0, 14, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = string.format("%s: %." .. decimals .. "f", text, defaultVal)
    label.TextColor3 = OP.Ink
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.BuilderSansBold
    label.TextSize = 13
    label.ZIndex = 101

    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1, -28, 0, 8)
    bar.Position = UDim2.new(0, 14, 0, 32)
    bar.BackgroundColor3 = OP.ParchDark
    bar.ZIndex = 101
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local percent = (defaultVal - minVal) / (maxVal - minVal)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(percent, 0, 1, 0)
    fill.BackgroundColor3 = OP.Gold
    fill.ZIndex = 102
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", bar)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(percent, -9, 0.5, -9)
    knob.BackgroundColor3 = OP.White
    knob.ZIndex = 103
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local ks = Instance.new("UIStroke", knob)
    ks.Color = OP.Gold; ks.Thickness = 1.5

    local dragging = false
    local function setVal(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = minVal + (maxVal - minVal) * rel
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -9, 0.5, -9)
        label.Text = string.format("%s: %." .. decimals .. "f", text, val)
        if callback then callback(val) end
    end
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; setVal(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                     or input.UserInputType == Enum.UserInputType.Touch) then
            setVal(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function CreateButton(parent, text, yPos, callback, color)
    local base = color or OP.Parchment
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = base
    btn.BackgroundTransparency = 0.1
    btn.Text = text
    btn.TextColor3 = OP.Ink
    btn.Font = Enum.Font.BuilderSansBold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.ZIndex = 100
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = OP.Gold; stroke.Thickness = 1.2; stroke.Transparency = 0.4

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15),
            {BackgroundColor3 = base:Lerp(OP.Gold, 0.35)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15),
            {BackgroundColor3 = base}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        PlaySound()
        if callback then callback() end
    end)
    return btn
end

-- ==========================================================
-- ESP PAGE
-- ==========================================================
local espY = 0
CreateLabel(ESPPage, "─── VISUAL ───", espY, OP.FireRed); espY += 24
CreateToggle(ESPPage, "ESP (3D Boxes)", espY, function(s) Config.ESPEnabled = s end, Config.ESPEnabled); espY += 50
CreateToggle(ESPPage, "Nombres", espY, function(s) Config.ShowNames = s end, Config.ShowNames); espY += 50
CreateToggle(ESPPage, "Mostrar distancia", espY, function(s) Config.ShowDistance = s end, Config.ShowDistance); espY += 50
CreateSlider(ESPPage, "Grosor líneas", espY, 1, 5, Config.ESPThickness, function(v) Config.ESPThickness = math.floor(v) end, 0); espY += 56

local colorBtn = Instance.new("TextButton", ESPPage)
colorBtn.Size = UDim2.new(1, 0, 0, 40)
colorBtn.Position = UDim2.new(0, 0, 0, espY)
colorBtn.BackgroundColor3 = OP.Parchment
colorBtn.BackgroundTransparency = 0.1
colorBtn.Text = "🎨 Color: " .. Config.ESPColorMode
colorBtn.TextColor3 = OP.Ink
colorBtn.Font = Enum.Font.BuilderSansBold
colorBtn.TextSize = 13
colorBtn.AutoButtonColor = false
colorBtn.ZIndex = 100
Instance.new("UICorner", colorBtn).CornerRadius = UDim.new(0, 12)
local cbStroke2 = Instance.new("UIStroke", colorBtn)
cbStroke2.Color = OP.Gold; cbStroke2.Thickness = 1.2; cbStroke2.Transparency = 0.4
colorBtn.MouseButton1Click:Connect(function()
    Config.ESPColorMode = Config.ESPColorMode == "Role" and "Static" or "Role"
    colorBtn.Text = "🎨 Color: " .. Config.ESPColorMode
    ShowToast("Color: " .. Config.ESPColorMode, OP.Gold)
    PlaySound()
end)

-- ==========================================================
-- AIMBOT PAGE
-- ==========================================================
local aimY = 0
CreateLabel(AimbotPage, "─── AIM ───", aimY, OP.FireRed); aimY += 24
CreateToggle(AimbotPage, "Aimbot Lock", aimY, function(s) Config.AimbotEnabled = s end, Config.AimbotEnabled); aimY += 50
CreateToggle(AimbotPage, "FOV Circle", aimY, function(s) Config.ShowFOVCircle = s end, Config.ShowFOVCircle); aimY += 50
CreateSlider(AimbotPage, "Smooth", aimY, 0.05, 0.5, Config.Smooth, function(v) Config.Smooth = v end); aimY += 56
CreateSlider(AimbotPage, "Rango (studs)", aimY, 100, 1000, Config.FOV, function(v) Config.FOV = v end, 0); aimY += 56
CreateSlider(AimbotPage, "FOV pantalla (px)", aimY, 100, 900, Config.ScreenFOV, function(v) Config.ScreenFOV = v end, 0); aimY += 56

local aimInfo = CreateLabel(AimbotPage,
    "Solo funciona si eres MARINE.\nApunta al BLACKBEARD más cercano\ndentro del FOV y con línea de visión.",
    aimY, OP.Muted)
aimInfo.Size = UDim2.new(1, 0, 0, 56)
aimInfo.TextSize = 11

-- ==========================================================
-- WEATHER PAGE
-- ==========================================================
local wY = 0
CreateLabel(WeatherPage, "─── CLIMA DEL GRAND LINE ───", wY, OP.FireRed); wY += 24
CreateButton(WeatherPage, "☀️  Calm Sea", wY, function()
    ApplyWeather("CalmSea"); ShowToast("Weather: Calm Sea", Weathers.CalmSea.Accent)
end, OP.Parchment); wY += 46
CreateButton(WeatherPage, "⚡  Storm", wY, function()
    ApplyWeather("Storm"); ShowToast("Weather: Storm", Weathers.Storm.Accent)
end, OP.Parchment); wY += 46
CreateButton(WeatherPage, "🌅  Sunset", wY, function()
    ApplyWeather("Sunset"); ShowToast("Weather: Sunset", Weathers.Sunset.Accent)
end, OP.Parchment); wY += 46
CreateButton(WeatherPage, "🌙  Night Sea", wY, function()
    ApplyWeather("NightSea"); ShowToast("Weather: Night Sea", Weathers.NightSea.Accent)
end, OP.Parchment); wY += 52

local wInfo = CreateLabel(WeatherPage,
    "Cada clima cambia el fondo de la\nventana, los acentos y las\ndecoraciones animadas.",
    wY, OP.Muted)
wInfo.Size = UDim2.new(1, 0, 0, 56)
wInfo.TextSize = 11

-- ==========================================================
-- CONFIG PAGE
-- ==========================================================
local cfgY = 0
CreateLabel(ConfigPage, "─── INFO ───", cfgY, OP.FireRed); cfgY += 24

local roleLbl = Instance.new("TextLabel", ConfigPage)
roleLbl.Size = UDim2.new(1, 0, 0, 26)
roleLbl.Position = UDim2.new(0, 6, 0, cfgY)
roleLbl.BackgroundTransparency = 1
roleLbl.Text = "Tu rol: ..."
roleLbl.TextColor3 = OP.Muted
roleLbl.Font = Enum.Font.BuilderSansBold
roleLbl.TextSize = 14
roleLbl.TextXAlignment = Enum.TextXAlignment.Left
roleLbl.ZIndex = 100
cfgY += 30

local statusLbl = Instance.new("TextLabel", ConfigPage)
statusLbl.Size = UDim2.new(1, 0, 0, 22)
statusLbl.Position = UDim2.new(0, 6, 0, cfgY)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "ESP: ✅ | Aimbot: ✅"
statusLbl.TextColor3 = OP.Green
statusLbl.Font = Enum.Font.BuilderSansBold
statusLbl.TextSize = 12
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.ZIndex = 100
cfgY += 28

CreateLabel(ConfigPage, "─── ACCIONES ───", cfgY, OP.FireRed); cfgY += 24

CreateToggle(ConfigPage, "🔊 Sound FX", cfgY, function(s) Config.SoundsEnabled = s end, Config.SoundsEnabled); cfgY += 50

CreateButton(ConfigPage, "🔄 Reiniciar config", cfgY, function()
    Config.ESPEnabled    = true
    Config.ShowNames     = true
    Config.ShowDistance  = true
    Config.ESPThickness  = 2
    Config.AimbotEnabled = true
    Config.ShowFOVCircle = true
    Config.Smooth        = 0.22
    Config.FOV           = 500
    Config.ScreenFOV     = 400
    Config.ESPColorMode  = "Role"
    Config.SoundsEnabled = true
    ShowToast("Config reiniciada", OP.Green)
end, OP.Parchment); cfgY += 46

CreateButton(ConfigPage, "🧹 Limpiar ESP", cfgY, function()
    ResetLines(); ResetLabels()
    ShowToast("ESP limpiado", OP.Gold)
end, OP.Parchment); cfgY += 46

local isOpen = false
local closeMenuBtn -- forward declaration
closeMenuBtn = CreateButton(ConfigPage, "❌ Cerrar menú", cfgY, function()
    if not isOpen then return end
    isOpen = false
    PlaySound("close")
    local t = TweenService:Create(menuScale,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.7})
    t:Play()
    t.Completed:Connect(function()
        if not isOpen then
            MainFrame.Visible = false
            menuScale.Scale = 1
        end
    end)
    ToggleBtn.Text = "🏴‍☠️ ONE PIECE"
end, OP.Parchment)

-- ==========================================================
-- DRAG
-- ==========================================================
local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                     or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
MakeDraggable(ToggleBtn, ToggleBtn)
MakeDraggable(MainFrame, Header)

-- ==========================================================
-- OPEN / CLOSE
-- ==========================================================
local function OpenMenu()
    if isOpen then return end
    isOpen = true
    MainFrame.Visible = true
    menuScale.Scale = 0.7
    TweenService:Create(menuScale,
        TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Scale = 1}):Play()
    ToggleBtn.Text = "✕ Cerrar"
    PlaySound("open")
    if not currentTab then SwitchTab("ESP") end
end

local function CloseMenu()
    if not isOpen then return end
    isOpen = false
    PlaySound("close")
    local t = TweenService:Create(menuScale,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.7})
    t:Play()
    t.Completed:Connect(function()
        if not isOpen then
            MainFrame.Visible = false
            menuScale.Scale = 1
        end
    end)
    ToggleBtn.Text = "🏴‍☠️ ONE PIECE"
end

local function ToggleMenu()
    if isOpen then CloseMenu() else OpenMenu() end
end

ToggleBtn.MouseButton1Click:Connect(ToggleMenu)
CloseBtn.MouseButton1Click:Connect(function() if isOpen then CloseMenu() end end)

-- Optional: PC keyboard shortcut
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not IsMobile and input.KeyCode == Enum.KeyCode.RightShift then
        ToggleMenu()
    end
end)

-- Default tab + weather
SwitchTab("ESP")
ApplyWeather("CalmSea")

-- ==========================================================
-- INFO LOOP
-- ==========================================================
task.spawn(function()
    while ScreenGui.Parent do
        local role, color = GetPlayerRole(LocalPlayer)
        roleLbl.Text = "Tu rol: " .. role
        roleLbl.TextColor3 = color
        statusLbl.Text = string.format("ESP: %s | Aimbot: %s | Sound: %s",
            Config.ESPEnabled    and "✅" or "❌",
            Config.AimbotEnabled and "✅" or "❌",
            Config.SoundsEnabled and "✅" or "❌")
        statusLbl.TextColor3 = (Config.ESPEnabled or Config.AimbotEnabled) and OP.Green or OP.Muted
        task.wait(0.5)
    end
end)

-- ==========================================================
-- MAIN LOOP
-- ==========================================================
RunService.RenderStepped:Connect(function()
    pcall(UpdateESP)
    pcall(UpdateAimbot)
end)

-- ==========================================================
-- CLEANUP
-- ==========================================================
ScreenGui.Destroying:Connect(function()
    for _, l in ipairs(LinePool)   do pcall(function() l:Remove() end) end
    for _, l in ipairs(NameLabels) do pcall(function() l:Remove() end) end
    if FOVCircle then pcall(function() FOVCircle:Remove() end) end
end)

print("[One Piece Gael v6.0] Ahoy! Loaded 🏴‍☠️")
print("Drawing supported: " .. tostring(HasDrawing))
