-- ==========================================================
-- 🏴‍☠️ ONE PIECE HUB v18.0 | DARK RED | PARTICLES & MOBILE PRO
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
    ESPHighlight  = true,
    ShowNames     = true,
    ShowDistance  = true,
    
    AimbotEnabled = false,
    AimbotSmooth  = 0.15,
    ShowFOVCircle = true,
    ScreenFOV     = 250,
    LockDistance  = 150,
    
    SoundsEnabled = true,
}

-- ==========================================================
-- 🎵 LISTA DE CANCIONES (ACTUALIZADA)
-- ==========================================================
local Songs = {
    {name = "Sunflower - Post Malone", id = "97898853555749"},
    {name = "Mask Off", id = "118893494775965"},
    {name = "Billie Jean", id = "116197983114890"},
    {name = "Misery", id = "121397051787416"},
    {name = "Terraway", id = "82746224492420"},
    {name = "Ra Ta Ta Phonk", id = "90851490275942"},
    {name = "Next to Me", id = "81732137163686"},
    {name = "Bazooka", id = "121252909004354"},
    {name = "Birdbrain", id = "73585961437875"},
    {name = "Fashion Center", id = "87570666848900"},
    {name = "Pixy - Legacy", id = "98250122413808"},
    {name = "Poison Jersey Remix", id = "135299486466028"},
    {name = "No One Knows", id = "82132732216469"},
    {name = "Swang", id = "131599540018104"},
    -- Extras
    {name = "Mood - 24kGoldn", id = "5519565135"},
    {name = "Raining Tacos", id = "142376088"},
    {name = "Crab Rave", id = "5410086218"},
}

local OP = {
    BG        = Color3.fromRGB(12, 12, 16),
    Panel     = Color3.fromRGB(24, 24, 30),
    Panel2    = Color3.fromRGB(35, 35, 45),
    Red       = Color3.fromRGB(230, 30, 50),
    RedDark   = Color3.fromRGB(150, 10, 20),
    White     = Color3.fromRGB(255, 255, 255),
    Text      = Color3.fromRGB(240, 240, 240),
    Muted     = Color3.fromRGB(140, 140, 150),
    Green     = Color3.fromRGB(60, 220, 120),
    Blue      = Color3.fromRGB(70, 140, 230),
}

local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ==========================================================
-- DRAWING & POOLS (ESP)
-- ==========================================================
local HasDrawing = pcall(function() return Drawing.new("Line") end)
local LinePool, LineIndex = {}, 0
local NameLabels = {}
local FOVCircle = nil

if HasDrawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 2; FOVCircle.NumSides = 60; FOVCircle.Filled = false
    FOVCircle.Transparency = 0.6; FOVCircle.Color = OP.Red; FOVCircle.Visible = false
end

local function GetLine()
    LineIndex += 1
    if not LinePool[LineIndex] then
        local l = Drawing.new("Line"); l.Transparency = 1; l.Visible = false; LinePool[LineIndex] = l
    end
    local line = LinePool[LineIndex]; line.Thickness = 2; return line
end

local function ResetLines() 
    for _, l in ipairs(LinePool) do l.Visible = false end; LineIndex = 0 
end

local function GetLabel(idx)
    if not NameLabels[idx] then
        local lbl = Drawing.new("Text"); lbl.Size = 16; lbl.Center = true; lbl.Outline = true; lbl.OutlineColor = Color3.new(0,0,0); lbl.Visible = false; NameLabels[idx] = lbl
    end
    return NameLabels[idx]
end
local function ResetLabels() for _, l in ipairs(NameLabels) do l.Visible = false end end

local function PlaySound(kind)
    if not Config.SoundsEnabled then return end
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxasset://sounds/electronicpingshort.wav"; s.Volume = 0.3
        s.PlaybackSpeed = (kind == "open" and 1.3) or (kind == "close" and 0.7) or 1
        s.Parent = SoundService; s:Play(); Debris:AddItem(s, 2)
    end)
end

-- ==========================================================
-- MM2 HELPERS
-- ==========================================================
local function getHRP() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") end
local function HasTool(p, name)
    if not p then return false end
    local c, bp = p.Character, p:FindFirstChild("Backpack")
    return (c and c:FindFirstChild(name)) or (bp and bp:FindFirstChild(name))
end

local function IsMurder(p) return HasTool(p, "Knife") end
local function IsSheriff(p) return HasTool(p, "Gun") end

local function GetPlayerColor(p)
    if IsMurder(p) then return OP.Red end
    if IsSheriff(p) then return OP.Blue end
    return OP.Green
end

local function getMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsMurder(p) then return p end
    end
    return nil
end

-- ==========================================================
-- ESP LÓGICA (SIN CONGELAMIENTO)
-- ==========================================================
local HighlightCache = {}

local function GetCorners(cf, size)
    local corners, half = {}, size / 2
    for X=-1,1,2 do for Y=-1,1,2 do for Z=-1,1,2 do
        corners[#corners+1] = (cf * CFrame.new(half.X*X, half.Y*Y, half.Z*Z)).Position
    end end end
    return corners
end
local BoxEdges = {{1,2},{2,4},{4,3},{3,1},{5,6},{6,8},{8,7},{7,5},{1,5},{2,6},{3,7},{4,8}}

local function DrawFor(player, labelIdx)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local color = GetPlayerColor(player)

    if Config.ESPEnabled then
        local corners = GetCorners(hrp.CFrame * CFrame.new(0, -0.5, 0), Vector3.new(3, 5, 3))
        local screen, visible = {}, {}
        for i, v in ipairs(corners) do
            local pos, on = Camera:WorldToViewportPoint(v)
            screen[i] = Vector2.new(pos.X, pos.Y); visible[i] = on
        end
        for _, e in ipairs(BoxEdges) do
            if visible[e[1]] or visible[e[2]] then
                local l = GetLine(); l.From, l.To = screen[e[1]], screen[e[2]]; l.Color = color; l.Visible = true
            end
        end
    end

    if Config.ESPHighlight then
        if not HighlightCache[player] or not HighlightCache[player].Parent then
            local h = Instance.new("Highlight")
            h.FillColor = color; h.FillTransparency = 0.5
            h.OutlineColor = OP.White; h.OutlineTransparency = 0 
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; h.Parent = char
            HighlightCache[player] = h
        else
            HighlightCache[player].FillColor = color
            HighlightCache[player].OutlineColor = OP.White
        end
    elseif HighlightCache[player] then
        HighlightCache[player]:Destroy(); HighlightCache[player] = nil
    end

    if Config.ShowNames then
        local head = char:FindFirstChild("Head") or hrp
        local pos, on = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
        if on then
            local role = IsMurder(player) and "Murderer" or (IsSheriff(player) and "Sheriff" or "Innocent")
            local dist = 0
            local myHRP = getHRP()
            if myHRP then dist = math.floor((hrp.Position - myHRP.Position).Magnitude) end
            local txt = Config.ShowDistance and string.format("%s [%s] %dm", player.Name, role, dist) or string.format("%s [%s]", player.Name, role)
            
            local lbl = GetLabel(labelIdx)
            lbl.Text = txt; lbl.Position = Vector2.new(pos.X, pos.Y); lbl.Color = color; lbl.Visible = true
        end
    end
end

local function UpdateESP()
    if not HasDrawing then return end
    ResetLines(); ResetLabels()
    
    if not (Config.ESPEnabled or Config.ESPHighlight or Config.ShowNames) then 
        for p, h in pairs(HighlightCache) do 
            pcall(function() h:Destroy() end) 
            HighlightCache[p] = nil 
        end
        return 
    end
    
    local idx = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            idx += 1; pcall(DrawFor, p, idx)
        end
    end
end

-- ==========================================================
-- AIMBOT LOCK
-- ==========================================================
local function GetCrosshair()
    if IsMobile then return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else local m = UIS:GetMouseLocation(); return Vector2.new(m.X, m.Y) end
end

local function UpdateAimbot()
    local target = getMurderer()
    local hasTarget = false
    if Config.AimbotEnabled and target and target.Character and IsSheriff(LocalPlayer) then
        local hrp = getHRP()
        local tHead = target.Character:FindFirstChild("Head")
        if hrp and tHead then
            local worldDist = (hrp.Position - tHead.Position).Magnitude
            if worldDist <= Config.LockDistance then
                local screenPos, onScreen = Camera:WorldToViewportPoint(tHead.Position)
                if onScreen then
                    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - GetCrosshair()).Magnitude
                    if screenDist <= Config.ScreenFOV then
                        hasTarget = true
                        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, tHead.Position), Config.AimbotSmooth)
                    end
                end
            end
        end
    end

    if FOVCircle then
        if Config.ShowFOVCircle and Config.AimbotEnabled then
            FOVCircle.Position = GetCrosshair(); FOVCircle.Radius = Config.ScreenFOV
            FOVCircle.Color = hasTarget and OP.White or OP.Red; FOVCircle.Visible = true
        else FOVCircle.Visible = false end
    end
end

-- ==========================================================
-- UI CREATION (MÓVIL Y PREMIUM)
-- ==========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OnePieceMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- TOGGLE BUTTON
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 130, 0, 42); ToggleBtn.Position = UDim2.new(0, 15, 0, 60)
ToggleBtn.BackgroundColor3 = OP.Panel; ToggleBtn.Text = "🏴‍☠️ ONE PIECE"
ToggleBtn.TextColor3 = OP.Red; ToggleBtn.Font = Enum.Font.BuilderSansBold; ToggleBtn.TextSize = 14
ToggleBtn.ZIndex = 100; ToggleBtn.AutoButtonColor = false; ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local tStroke = Instance.new("UIStroke", ToggleBtn); tStroke.Color = OP.Red; tStroke.Thickness = 2

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 290, 0, 420); MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = OP.BG; MainFrame.Visible = false; MainFrame.ClipsDescendants = true; MainFrame.ZIndex = 50; MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local menuScale = Instance.new("UIScale", MainFrame)
local function UpdateScale()
    local vp = Camera.ViewportSize
    menuScale.Scale = math.clamp(math.min(vp.X, vp.Y) / 460, 0.6, 1) -- Ajuste fino para pantallas pequeñas
end
UpdateScale()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)

local mainStroke = Instance.new("UIStroke", MainFrame); mainStroke.Color = OP.Red; mainStroke.Thickness = 2; mainStroke.Transparency = 0.3

-- PARTICLE SYSTEM (EFECTO "MÁS PERRO")
local ParticleLayer = Instance.new("Frame", MainFrame)
ParticleLayer.Size = UDim2.new(1, 0, 1, 0); ParticleLayer.BackgroundTransparency = 1; ParticleLayer.ZIndex = 3; ParticleLayer.ClipsDescendants = true

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.15)
        if MainFrame.Visible then
            local p = Instance.new("Frame", ParticleLayer)
            p.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
            p.Position = UDim2.new(math.random(), 0, 1, 0)
            p.BackgroundColor3 = OP.Red
            p.ZIndex = 3
            Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
            
            local tween = TweenService:Create(p, TweenInfo.new(math.random(2, 5), Enum.EasingStyle.Linear), {
                Position = UDim2.new(p.Position.X.Scale, 0, -0.1, 0),
                BackgroundTransparency = 1
            })
            tween:Play()
            tween.Completed:Connect(function() p:Destroy() end)
        end
    end
end)

-- HEADER
local StrawHat = Instance.new("Frame", MainFrame); StrawHat.Size = UDim2.new(0, 30, 0, 30); StrawHat.Position = UDim2.new(0, 14, 0, 14); StrawHat.BackgroundTransparency = 1; StrawHat.ZIndex = 52
local hatCap = Instance.new("Frame", StrawHat); hatCap.Size = UDim2.new(0, 18, 0, 12); hatCap.Position = UDim2.new(0, 6, 0, 2); hatCap.BackgroundColor3 = OP.Red; hatCap.ZIndex = 53
Instance.new("UICorner", hatCap).CornerRadius = UDim.new(0, 10)
local hatBand = Instance.new("Frame", StrawHat); hatBand.Size = UDim2.new(0, 18, 0, 4); hatBand.Position = UDim2.new(0, 6, 0, 9); hatBand.BackgroundColor3 = OP.White; hatBand.ZIndex = 54
Instance.new("UICorner", hatBand).CornerRadius = UDim.new(0, 2)
local hatBrim = Instance.new("Frame", StrawHat); hatBrim.Size = UDim2.new(0, 28, 0, 5); hatBrim.Position = UDim2.new(0, 1, 0, 16); hatBrim.BackgroundColor3 = OP.RedDark; hatBrim.ZIndex = 53
Instance.new("UICorner", hatBrim).CornerRadius = UDim.new(1, 0)

local Title = Instance.new("TextLabel", MainFrame); Title.Size = UDim2.new(1, -100, 0, 26); Title.Position = UDim2.new(0, 48, 0, 9); Title.BackgroundTransparency = 1; Title.Text = "ONE PIECE"; Title.TextColor3 = OP.Red; Title.Font = Enum.Font.BuilderSansBold; Title.TextSize = 20; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.TextStrokeColor3 = OP.BG; Title.TextStrokeTransparency = 0; Title.ZIndex = 52

local CloseBtn = Instance.new("TextButton", MainFrame); CloseBtn.Size = UDim2.new(0, 28, 0, 28); CloseBtn.Position = UDim2.new(1, -38, 0, 13); CloseBtn.BackgroundColor3 = OP.Panel; CloseBtn.Text = "✕"; CloseBtn.TextColor3 = OP.Red; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 14; CloseBtn.ZIndex = 52; CloseBtn.AutoButtonColor = false
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- TABS
local TabBar = Instance.new("ScrollingFrame", MainFrame)
TabBar.Size = UDim2.new(1, -20, 0, 32); TabBar.Position = UDim2.new(0, 10, 0, 52)
TabBar.BackgroundColor3 = OP.Panel; TabBar.BackgroundTransparency = 0.3; TabBar.ZIndex = 51
TabBar.ScrollBarThickness = 0; TabBar.CanvasSize = UDim2.new(0, 0, 0, 0); TabBar.AutomaticCanvasSize = Enum.AutomaticSize.X; TabBar.ScrollingDirection = Enum.ScrollingDirection.X
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(1, 0)
local TabLayout = Instance.new("UIListLayout", TabBar); TabLayout.FillDirection = Enum.FillDirection.Horizontal; TabLayout.Padding = UDim.new(0, 4); TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
local TabPad = Instance.new("UIPadding", TabBar); TabPad.PaddingLeft = UDim.new(0, 4); TabPad.PaddingRight = UDim.new(0, 4)

local ContentArea = Instance.new("ScrollingFrame", MainFrame)
ContentArea.Size = UDim2.new(1, -20, 1, -100); ContentArea.Position = UDim2.new(0, 10, 0, 92)
ContentArea.BackgroundTransparency = 1; ContentArea.ScrollBarThickness = 3; ContentArea.ScrollBarImageColor3 = OP.Red
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0); ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y; ContentArea.ZIndex = 51
local ContentPad = Instance.new("UIPadding", ContentArea); ContentPad.PaddingRight = UDim.new(0, 6)

local Sections = {}
local function CreateSection(name)
    local f = Instance.new("Frame", ContentArea); f.Size = UDim2.new(1, 0, 0, 0); f.BackgroundTransparency = 1; f.Visible = false; f.ZIndex = 52
    f.AutomaticSize = Enum.AutomaticSize.Y
    Sections[name] = f; return f
end

local ESPPage    = CreateSection("ESP")
local AimbotPage = CreateSection("Aimbot")
local MusicPage  = CreateSection("Music")

local TabButtons = {}
local currentTab = nil
local function SwitchTab(name)
    for n, p in pairs(Sections) do p.Visible = (n == name) end
    for n, b in pairs(TabButtons) do
        local active = (n == name)
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = active and OP.Red or OP.Panel2, TextColor3 = active and OP.White or OP.Muted}):Play()
    end
    currentTab = name
end

local function CreateTabButton(name)
    local btn = Instance.new("TextButton", TabBar); btn.Size = UDim2.new(0, 60, 0, 24); btn.BackgroundColor3 = OP.Panel2; btn.Text = name; btn.TextColor3 = OP.Muted; btn.Font = Enum.Font.BuilderSansBold; btn.TextSize = 11; btn.AutoButtonColor = false; btn.ZIndex = 52
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    btn.Activated:Connect(function() PlaySound(); SwitchTab(name) end)
    TabButtons[name] = btn
end
CreateTabButton("ESP"); CreateTabButton("Aimbot"); CreateTabButton("Music")

-- BUILDERS
local function CreateLabel(parent, text, yPos, color)
    local lbl = Instance.new("TextLabel", parent); lbl.Size = UDim2.new(1, 0, 0, 18); lbl.Position = UDim2.new(0, 4, 0, yPos); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = color or OP.Muted; lbl.Font = Enum.Font.BuilderSansBold; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 100
    return lbl
end

local function CreateToggle(parent, text, yPos, callback, default)
    local state = default ~= false
    local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(1, 0, 0, 36); btn.Position = UDim2.new(0, 0, 0, yPos); btn.BackgroundColor3 = OP.Panel; btn.Text = ""; btn.AutoButtonColor = false; btn.ZIndex = 100
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", btn); stroke.Color = OP.Panel2; stroke.Thickness = 1
    local label = Instance.new("TextLabel", btn); label.Size = UDim2.new(1, -60, 1, 0); label.Position = UDim2.new(0, 12, 0, 0); label.Text = text; label.TextColor3 = OP.Text; label.TextXAlignment = Enum.TextXAlignment.Left; label.BackgroundTransparency = 1; label.Font = Enum.Font.BuilderSansBold; label.TextSize = 12; label.ZIndex = 101
    local switchBg = Instance.new("Frame", btn); switchBg.Size = UDim2.new(0, 36, 0, 18); switchBg.Position = UDim2.new(1, -48, 0.5, -9); switchBg.BackgroundColor3 = state and OP.Red or OP.Panel2; switchBg.ZIndex = 101
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
    local thumb = Instance.new("Frame", switchBg); thumb.Size = UDim2.new(0, 14, 0, 14); thumb.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7); thumb.BackgroundColor3 = OP.White; thumb.ZIndex = 102
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
    
    btn.Activated:Connect(function()
        state = not state; PlaySound()
        TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = state and OP.Red or OP.Panel2}):Play()
        TweenService:Create(thumb, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
        if callback then callback(state) end
    end)
end

local function CreateSlider(parent, text, yPos, minVal, maxVal, defaultVal, callback, decimals)
    decimals = decimals or 2
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1, 0, 0, 42); frame.Position = UDim2.new(0, 0, 0, yPos); frame.BackgroundColor3 = OP.Panel; frame.ZIndex = 100
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", frame); stroke.Color = OP.Panel2; stroke.Thickness = 1
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1, -20, 0, 16); label.Position = UDim2.new(0, 12, 0, 4); label.BackgroundTransparency = 1; label.Text = string.format("%s: %." .. decimals .. "f", text, defaultVal); label.TextColor3 = OP.Text; label.TextXAlignment = Enum.TextXAlignment.Left; label.Font = Enum.Font.BuilderSansBold; label.TextSize = 12; label.ZIndex = 101
    local bar = Instance.new("Frame", frame); bar.Size = UDim2.new(1, -24, 0, 6); bar.Position = UDim2.new(0, 12, 0, 26); bar.BackgroundColor3 = OP.Panel2; bar.ZIndex = 101; bar.Active = true
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local percent = (defaultVal - minVal) / (maxVal - minVal)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new(percent, 0, 1, 0); fill.BackgroundColor3 = OP.Red; fill.ZIndex = 102
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame", bar); knob.Size = UDim2.new(0, 14, 0, 14); knob.Position = UDim2.new(percent, -7, 0.5, -7); knob.BackgroundColor3 = OP.White; knob.ZIndex = 103
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local function setVal(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = minVal + (maxVal - minVal) * rel
        fill.Size = UDim2.new(rel, 0, 1, 0); knob.Position = UDim2.new(rel, -7, 0.5, -7); label.Text = string.format("%s: %." .. decimals .. "f", text, val)
        if callback then callback(val) end
    end
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; setVal(input.Position.X) end end)
    UIS.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then setVal(input.Position.X) end end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end

-- ==========================================================
-- POBLAR PÁGINAS
-- ==========================================================
local espY = 0
CreateLabel(ESPPage, "─── VISUAL ───", espY, OP.Red); espY += 22
CreateToggle(ESPPage, "ESP Cajas (Lines)", espY, function(s) Config.ESPEnabled = s end, Config.ESPEnabled); espY += 42
CreateToggle(ESPPage, "ESP Chams (Borde)", espY, function(s) Config.ESPHighlight = s end, Config.ESPHighlight); espY += 42
CreateToggle(ESPPage, "Nombres y Distancia", espY, function(s) Config.ShowNames = s end, Config.ShowNames); espY += 42

local aimY = 0
CreateLabel(AimbotPage, "─── COMBATE ───", aimY, OP.Red); aimY += 22
CreateToggle(AimbotPage, "Aimbot Lock (Cámara)", aimY, function(s) Config.AimbotEnabled = s end, Config.AimbotEnabled); aimY += 42
CreateToggle(AimbotPage, "Mostrar Círculo FOV", aimY, function(s) Config.ShowFOVCircle = s end, Config.ShowFOVCircle); aimY += 42
CreateSlider(AimbotPage, "Suavidad (Smooth)", aimY, 0.05, 0.5, Config.AimbotSmooth, function(v) Config.AimbotSmooth = v end); aimY += 48
CreateSlider(AimbotPage, "Tamaño FOV", aimY, 50, 600, Config.ScreenFOV, function(v) Config.ScreenFOV = v end, 0); aimY += 48
CreateSlider(AimbotPage, "Distancia Max (Studs)", aimY, 10, 500, Config.LockDistance, function(v) Config.LockDistance = v end, 0); aimY += 48
CreateLabel(AimbotPage, "* Solo funciona si eres Sheriff.", aimY, OP.Muted)

-- ==========================================================
-- FLOATING MINI PLAYER (REPRODUCTOR FLOTANTE PREMIUM)
-- ==========================================================
local PlayerGui = Instance.new("Frame", ScreenGui)
PlayerGui.Name = "MusicPlayer"
PlayerGui.Size = UDim2.new(0, 200, 0, 80)
PlayerGui.Position = UDim2.new(0.5, -100, 0.8, -40)
PlayerGui.BackgroundColor3 = OP.BG
PlayerGui.BackgroundTransparency = 0.2
PlayerGui.Visible = false
PlayerGui.ZIndex = 150
PlayerGui.Active = true
Instance.new("UICorner", PlayerGui).CornerRadius = UDim.new(0, 10)
local playerStroke = Instance.new("UIStroke", PlayerGui); playerStroke.Color = OP.Red; playerStroke.Thickness = 2

local SongNameLbl = Instance.new("TextLabel", PlayerGui)
SongNameLbl.Size = UDim2.new(1, -40, 0, 24); SongNameLbl.Position = UDim2.new(0, 10, 0, 5)
SongNameLbl.BackgroundTransparency = 1; SongNameLbl.Text = "Ninguna canción"
SongNameLbl.TextColor3 = OP.Text; SongNameLbl.Font = Enum.Font.BuilderSansBold; SongNameLbl.TextSize = 12
SongNameLbl.TextXAlignment = Enum.TextXAlignment.Left; SongNameLbl.ZIndex = 151

local ClosePlayerBtn = Instance.new("TextButton", PlayerGui)
ClosePlayerBtn.Size = UDim2.new(0, 24, 0, 24); ClosePlayerBtn.Position = UDim2.new(1, -30, 0, 5)
ClosePlayerBtn.BackgroundColor3 = OP.RedDark; ClosePlayerBtn.Text = "✕"; ClosePlayerBtn.TextColor3 = OP.White
ClosePlayerBtn.Font = Enum.Font.GothamBold; ClosePlayerBtn.TextSize = 12; ClosePlayerBtn.ZIndex = 151; ClosePlayerBtn.AutoButtonColor = false
Instance.new("UICorner", ClosePlayerBtn).CornerRadius = UDim.new(0, 6)

local PlayBtnPlayer = Instance.new("TextButton", PlayerGui)
PlayBtnPlayer.Size = UDim2.new(0, 40, 0, 30); PlayBtnPlayer.Position = UDim2.new(0, 10, 0, 45)
PlayBtnPlayer.BackgroundColor3 = OP.Red; PlayBtnPlayer.Text = "⏸"; PlayBtnPlayer.TextColor3 = OP.White
PlayBtnPlayer.Font = Enum.Font.GothamBold; PlayBtnPlayer.TextSize = 16; PlayBtnPlayer.ZIndex = 151; PlayBtnPlayer.AutoButtonColor = false
Instance.new("UICorner", PlayBtnPlayer).CornerRadius = UDim.new(0, 6)

local MiniVisualizer = Instance.new("Frame", PlayerGui)
MiniVisualizer.Size = UDim2.new(1, -60, 0, 30); MiniVisualizer.Position = UDim2.new(0, 60, 0, 45)
MiniVisualizer.BackgroundTransparency = 1; MiniVisualizer.ZIndex = 151
local MiniLayout = Instance.new("UIListLayout", MiniVisualizer)
MiniLayout.FillDirection = Enum.FillDirection.Horizontal
MiniLayout.Padding = UDim.new(0, 2)
MiniLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
MiniLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

local MiniBars = {}
for i = 1, 8 do
    local bar = Instance.new("Frame", MiniVisualizer)
    bar.Size = UDim2.new(0, 5, 0, 5)
    bar.BackgroundColor3 = OP.Red
    bar.ZIndex = 152
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 1)
    MiniBars[i] = bar
end

local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = frame.Position end end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UIS.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
end
MakeDraggable(PlayerGui, SongNameLbl)

-- ==========================================================
-- LÓGICA DE MÚSICA (AUDIO)
-- ==========================================================
local MusicSound = Instance.new("Sound", SoundService)
MusicSound.Volume = 5
MusicSound.Looped = true

local function PlaySong(id, name)
    pcall(function()
        MusicSound:Stop()
        MusicSound.SoundId = "rbxassetid://" .. id
        MusicSound:Play()
        
        SongNameLbl.Text = name
        PlayerGui.Visible = true
        PlayBtnPlayer.Text = "⏸"
    end)
end

PlayBtnPlayer.Activated:Connect(function()
    if MusicSound.IsPlaying then
        MusicSound:Pause()
        PlayBtnPlayer.Text = "▶"
    else
        MusicSound:Resume()
        PlayBtnPlayer.Text = "⏸"
    end
end)

ClosePlayerBtn.Activated:Connect(function()
    MusicSound:Stop()
    PlayerGui.Visible = false
end)

RunService.RenderStepped:Connect(function()
    if PlayerGui.Visible and MusicSound.IsPlaying then
        for i, bar in ipairs(MiniBars) do
            local height = 5 + math.random(0, 15) + (math.sin(tick() * 15 + i) * 5)
            bar.Size = UDim2.new(0, 5, 0, height)
            bar.BackgroundColor3 = OP.Red:Lerp(OP.White, math.random(0, 5)/10)
        end
    elseif PlayerGui.Visible then
        for _, bar in ipairs(MiniBars) do
            bar.Size = UDim2.new(0, 5, 0, 5)
            bar.BackgroundColor3 = OP.Panel2
        end
    end
end)

-- ==========================================================
-- SECCIÓN MUSIC (LISTA DE CANCIONES NUEVAS)
-- ==========================================================
local musicY = 0
CreateLabel(MusicPage, "─── LISTA DE REPRODUCCIÓN ───", musicY, OP.Red); musicY += 22

for i, song in ipairs(Songs) do
    local btn = Instance.new("TextButton", MusicPage)
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.Position = UDim2.new(0, 0, 0, musicY)
    btn.BackgroundColor3 = OP.Panel
    btn.Text = "🎵 " .. song.name
    btn.TextColor3 = OP.Text
    btn.Font = Enum.Font.BuilderSansBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.ZIndex = 100
    
    local padding = Instance.new("UIPadding", btn)
    padding.PaddingLeft = UDim.new(0, 10)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", btn); stroke.Color = OP.Panel2; stroke.Thickness = 1
    
    btn.Activated:Connect(function()
        PlaySound()
        PlaySong(song.id, song.name)
    end)
    
    musicY += 40
end

-- ==========================================================
-- DRAG & OPEN/CLOSE (MAIN MENU)
-- ==========================================================
MakeDraggable(ToggleBtn, ToggleBtn); MakeDraggable(MainFrame, ToggleBtn) 

_G.OnePieceMenuOpen = false
function ToggleMenu()
    _G.OnePieceMenuOpen = not _G.OnePieceMenuOpen
    if _G.OnePieceMenuOpen then
        MainFrame.Visible = true; menuScale.Scale = 0.85
        TweenService:Create(menuScale, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Scale = math.clamp(math.min(Camera.ViewportSize.X, Camera.ViewportSize.Y) / 460, 0.6, 1)}):Play()
        ToggleBtn.Text = "✕ CERRAR"; PlaySound("open")
        if not currentTab then SwitchTab("ESP") end
    else
        local t = TweenService:Create(menuScale, TweenInfo.new(0.2), {Scale = 0.85})
        t:Play(); t.Completed:Connect(function() MainFrame.Visible = false; UpdateScale() end)
        ToggleBtn.Text = "🏴‍☠️ ONE PIECE"; PlaySound("close")
    end
end

ToggleBtn.Activated:Connect(ToggleMenu)
CloseBtn.Activated:Connect(ToggleMenu)

-- ==========================================================
-- MAIN LOOP
-- ==========================================================
SwitchTab("ESP")

RunService.RenderStepped:Connect(function()
    pcall(UpdateESP)
    pcall(UpdateAimbot)
end)

print("[ONE PIECE HUB v18.0] ¡Diseño móvil PRO con partículas cargado! 🏴‍☠️")
