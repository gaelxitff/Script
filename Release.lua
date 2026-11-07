-- ==========================================================
-- 🏴‍☠️ ONE PIECE HUB v8.0 | MM2 ULTIMATE (MOBILE FIX)
-- ==========================================================
local RunService   = game:GetService("RunService")
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local CoreGui      = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Workspace    = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")
local Debris       = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

-- ==========================================================
-- CONFIG
-- ==========================================================
local Config = {
    -- ESP & Aimbot
    ESPEnabled    = true,
    ESPHighlight  = true,
    ShowNames     = true,
    ShowDistance  = true,
    AimbotEnabled = false,
    AimbotSmooth  = 0.15,
    Instakill     = false,
    ShowFOVCircle = true,
    ScreenFOV     = 250,
    LastInstakill = 0,
    
    -- Movement
    WalkSpeed     = 16,
    JumpPower     = 50,
    FlyEnabled    = false,
    FlySpeed      = 50,
    Noclip        = false,
    AntiVoid      = true,
    
    -- Farm
    AutoFarm      = false,
    FarmSpeed     = 100, -- Teletransporte rápido
    
    -- Misc
    KnifeDodge    = true,
    SoundsEnabled = true,
    Weather       = "CalmSea",
}

-- ==========================================================
-- ONE PIECE PALETTE
-- ==========================================================
local OP = {
    Parchment = Color3.fromRGB(250, 240, 220),
    ParchDark = Color3.fromRGB(220, 200, 160),
    Ink       = Color3.fromRGB(25, 20, 15),
    Gold      = Color3.fromRGB(255, 205, 60),
    FireRed   = Color3.fromRGB(230, 70, 70),
    Marine    = Color3.fromRGB(70, 140, 230),
    Green     = Color3.fromRGB(80, 220, 120),
    White     = Color3.fromRGB(255, 255, 255),
    Muted     = Color3.fromRGB(140, 130, 110),
    Jolly     = Color3.fromRGB(15, 20, 30),
    StrawGold = Color3.fromRGB(255, 220, 100),
    StrawDark = Color3.fromRGB(200, 150, 40),
}

local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ==========================================================
-- WEATHER THEMES
-- ==========================================================
local Weathers = {
    CalmSea = { Accent = Color3.fromRGB(120, 190, 255), Gradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 200, 255)), ColorSequenceKeypoint.new(0.55, Color3.fromRGB(80, 150, 220)), ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 100, 175))}), Clouds = true, Sun = true },
    Storm   = { Accent = Color3.fromRGB(140, 160, 200), Gradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 80, 100)), ColorSequenceKeypoint.new(0.55, Color3.fromRGB(45, 55, 80)), ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 30, 50))}), Clouds = true, Rain = true },
    Sunset  = { Accent = Color3.fromRGB(255, 170, 90), Gradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 120)), ColorSequenceKeypoint.new(0.45, Color3.fromRGB(250, 130, 100)), ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 65, 140))}), Clouds = true, Sun = true },
    NightSea= { Accent = Color3.fromRGB(130, 175, 240), Gradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 45, 95)), ColorSequenceKeypoint.new(0.55, Color3.fromRGB(20, 30, 70)), ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 15, 40))}), Stars = true },
}

-- ==========================================================
-- DRAWING & POOLS
-- ==========================================================
local HasDrawing = pcall(function() return Drawing.new("Line") end)
local LinePool, LineIndex = {}, 0
local NameLabels = {}
local FOVCircle = nil

if HasDrawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 2; FOVCircle.NumSides = 60; FOVCircle.Filled = false
    FOVCircle.Transparency = 0.6; FOVCircle.Color = OP.Gold; FOVCircle.Visible = false
end

local function GetLine()
    LineIndex += 1
    if not LinePool[LineIndex] then
        local l = Drawing.new("Line"); l.Transparency = 1; l.Visible = false; LinePool[LineIndex] = l
    end
    local line = LinePool[LineIndex]; line.Thickness = 2; return line
end

local function ResetLines() for _, l in ipairs(LinePool) do l.Visible = false end; LineIndex = 0 end

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
-- MM2 HELPERS & NOCLIP
-- ==========================================================
local function getHRP() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") end
local function getHumanoid() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") end

-- Noclip Global (Se activa solo si el usuario lo pide o el farm lo necesita)
local noclipConn = RunService.Stepped:Connect(function()
    if Config.Noclip or Config.AutoFarm then
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
    end
end)

local function HasTool(p, name)
    if not p then return false end
    local c, bp = p.Character, p:FindFirstChild("Backpack")
    return (c and c:FindFirstChild(name)) or (bp and bp:FindFirstChild(name))
end

local function IsMurder(p) return HasTool(p, "Knife") end
local function IsSheriff(p) return HasTool(p, "Gun") end

local function GetPlayerColor(p)
    if IsMurder(p) then return OP.FireRed end
    if IsSheriff(p) then return OP.Marine end
    return OP.Green
end

-- ==========================================================
-- HAPPYHUB LOGIC (Aimbot / Instakill)
-- ==========================================================
local function getGun()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("Gun") or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Gun"))
end

local function getMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsMurder(p) then return p end
    end
    return nil
end

local function InstaKill(targetPlr)
    if not targetPlr or not targetPlr.Character then return end
    local gun = getGun()
    if not gun or gun.Parent ~= LocalPlayer.Character then return end
    local shootEvent = gun:FindFirstChild("Shoot")
    if not shootEvent then return end
    local targetHRP = targetPlr.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    pcall(function() shootEvent:FireServer(CFrame.new(targetHRP.Position - targetHRP.CFrame.LookVector * 3.5), CFrame.new(targetHRP.Position)) end)
end

-- ==========================================================
-- ESP LÓGICA
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
            h.FillColor = color; h.FillTransparency = 0.5; h.OutlineColor = color
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; h.Parent = char
            HighlightCache[player] = h
        else
            HighlightCache[player].FillColor = color; HighlightCache[player].OutlineColor = color
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
        for p, h in pairs(HighlightCache) do pcall(function() h:Destroy() end); HighlightCache[p] = nil end
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
-- AIMBOT & FOV
-- ==========================================================
local function GetCrosshair()
    if IsMobile then return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else local m = UIS:GetMouseLocation(); return Vector2.new(m.X, m.Y) end
end

local function UpdateAimbot()
    local target = getMurderer()
    local hasTarget = false
    
    if Config.AimbotEnabled and target and target.Character then
        local hrp = getHRP()
        local tHead = target.Character:FindFirstChild("Head")
        if hrp and tHead then
            local screenPos, onScreen = Camera:WorldToViewportPoint(tHead.Position)
            if onScreen then
                local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - GetCrosshair()).Magnitude
                if screenDist <= Config.ScreenFOV then
                    hasTarget = true
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, tHead.Position), Config.AimbotSmooth)
                    
                    if Config.Instakill and tick() - Config.LastInstakill > 0.15 then
                        Config.LastInstakill = tick()
                        InstaKill(target)
                    end
                end
            end
        end
    end

    if FOVCircle then
        if Config.ShowFOVCircle and Config.AimbotEnabled then
            FOVCircle.Position = GetCrosshair()
            FOVCircle.Radius = Config.ScreenFOV
            FOVCircle.Color = hasTarget and OP.FireRed or OP.Gold
            FOVCircle.Visible = true
        else
            FOVCircle.Visible = false
        end
    end
end

-- ==========================================================
-- MOVEMENT LOGIC
-- ==========================================================
local flyBV, flyBG, flyConn = nil, nil, nil
local function ToggleFly(state)
    local hrp = getHRP(); local hum = getHumanoid()
    if not hrp or not hum then return end
    
    if state then
        hum.PlatformStand = true
        flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce = Vector3.new(1e5,1e5,1e5); flyBV.Parent = hrp
        flyBG = Instance.new("BodyGyro"); flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5); flyBG.P = 1e4; flyBG.Parent = hrp
        
        if flyConn then flyConn:Disconnect() end
        flyConn = RunService.Heartbeat:Connect(function()
            if not Config.FlyEnabled or not flyBV or not flyBG then return end
            local cam = Workspace.CurrentCamera
            local moveDir = getHumanoid().MoveDirection
            if moveDir.Magnitude < 0.1 then moveDir = cam.CFrame.LookVector end
            flyBV.Velocity = moveDir * Config.FlySpeed
            flyBG.CFrame = cam.CFrame
        end)
    else
        if flyConn then flyConn:Disconnect(); flyConn = nil end
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
        if hum then hum.PlatformStand = false end
    end
end

-- ==========================================================
-- AUTOFARM PRO (WALLCHECK / NOCLIP)
-- ==========================================================
local function getClosestCoin()
    local hrp = getHRP()
    if not hrp then return nil end
    local bestCoin, minDist = nil, math.huge
    
    -- Buscamos en todo el Workspace monedas no recolectadas
    for _, v in pairs(Workspace:GetDescendants()) do
        if (v:IsA("BasePart") or v:IsA("MeshPart")) and not v:GetAttribute("Collected") then
            local name = v.Name:lower()
            if name:find("coin") or (v.Parent and v.Parent.Name:lower():find("coin")) then
                local d = (v.Position - hrp.Position).Magnitude
                if d < minDist then
                    minDist = d
                    bestCoin = v
                end
            end
        end
    end
    return bestCoin
end

local farmThread = nil
local function ToggleFarm(state)
    if state then
        if farmThread then task.cancel(farmThread) end
        farmThread = task.spawn(function()
            while Config.AutoFarm do
                task.wait(0.05)
                local hrp = getHRP()
                local coin = getClosestCoin()
                
                if hrp and coin then
                    -- Teletransporte directo a la moneda (Atraviesa paredes gracias al Noclip forzado)
                    hrp.CFrame = CFrame.new(coin.Position + Vector3.new(0, 1, 0))
                    hrp.Velocity = Vector3.zero
                    
                    -- Simular toque para recolectar
                    pcall(firetouchinterest, hrp, coin, 0)
                    task.wait(0.01)
                    pcall(firetouchinterest, hrp, coin, 1)
                end
            end
        end)
    else
        if farmThread then task.cancel(farmThread); farmThread = nil end
    end
end

-- ==========================================================
-- UI CREATION (Responsive & Fix for Mobile)
-- ==========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OnePieceMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- TOASTS
local function ShowToast(text, accent)
    accent = accent or OP.Gold
    local toast = Instance.new("Frame", ScreenGui)
    toast.Size = UDim2.new(0, 220, 0, 42); toast.Position = UDim2.new(1, 20, 0, 20)
    toast.BackgroundColor3 = OP.Parchment; toast.ZIndex = 200
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", toast); stroke.Color = accent; stroke.Thickness = 2
    local label = Instance.new("TextLabel", toast); label.Size = UDim2.new(1, -20, 1, 0); label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1; label.Text = text; label.TextColor3 = OP.Ink; label.Font = Enum.Font.BuilderSansBold; label.TextSize = 12; label.TextXAlignment = Enum.TextXAlignment.Left
    
    TweenService:Create(toast, TweenInfo.new(0.35, Enum.EasingStyle.Back), {Position = UDim2.new(1, -240, 0, 20)}):Play()
    task.delay(2, function()
        local tOut = TweenService:Create(toast, TweenInfo.new(0.3), {Position = UDim2.new(1, 20, 0, 20)})
        tOut:Play(); tOut.Completed:Wait(); toast:Destroy()
    end)
end

-- TOGGLE BUTTON
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 140, 0, 42); ToggleBtn.Position = UDim2.new(0, 15, 0, 60)
ToggleBtn.BackgroundColor3 = OP.Parchment; ToggleBtn.Text = "🏴‍☠️ ONE PIECE"
ToggleBtn.TextColor3 = OP.Ink; ToggleBtn.Font = Enum.Font.BuilderSansBold; ToggleBtn.TextSize = 14
ToggleBtn.ZIndex = 100; ToggleBtn.AutoButtonColor = false; ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local tStroke = Instance.new("UIStroke", ToggleBtn); tStroke.Color = OP.Gold; tStroke.Thickness = 2

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 460); MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = OP.White; MainFrame.Visible = false; MainFrame.ClipsDescendants = true; MainFrame.ZIndex = 50; MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

-- RESPONSIVE SCALE
local menuScale = Instance.new("UIScale", MainFrame)
local function UpdateScale()
    local vp = Camera.ViewportSize
    menuScale.Scale = math.clamp(math.min(vp.X, vp.Y) / 460, 0.65, 1)
end
UpdateScale()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)

local mainStroke = Instance.new("UIStroke", MainFrame); mainStroke.Color = OP.Gold; mainStroke.Thickness = 2
local mainGradient = Instance.new("UIGradient", MainFrame); mainGradient.Rotation = 90; mainGradient.Color = Weathers.CalmSea.Gradient

-- HEADER (TITLE + STRAW HAT)
local StrawHat = Instance.new("Frame", MainFrame); StrawHat.Size = UDim2.new(0, 32, 0, 32); StrawHat.Position = UDim2.new(0, 14, 0, 14); StrawHat.BackgroundTransparency = 1; StrawHat.ZIndex = 52
local hatCap = Instance.new("Frame", StrawHat); hatCap.Size = UDim2.new(0, 20, 0, 14); hatCap.Position = UDim2.new(0, 6, 0, 2); hatCap.BackgroundColor3 = OP.StrawGold; hatCap.ZIndex = 53
Instance.new("UICorner", hatCap).CornerRadius = UDim.new(0, 10)
local hatBand = Instance.new("Frame", StrawHat); hatBand.Size = UDim2.new(0, 20, 0, 4); hatBand.Position = UDim2.new(0, 6, 0, 10); hatBand.BackgroundColor3 = OP.FireRed; hatBand.ZIndex = 54
Instance.new("UICorner", hatBand).CornerRadius = UDim.new(0, 2)
local hatBrim = Instance.new("Frame", StrawHat); hatBrim.Size = UDim2.new(0, 30, 0, 6); hatBrim.Position = UDim2.new(0, 1, 0, 18); hatBrim.BackgroundColor3 = OP.StrawDark; hatBrim.ZIndex = 53
Instance.new("UICorner", hatBrim).CornerRadius = UDim.new(1, 0)

local Title = Instance.new("TextLabel", MainFrame); Title.Size = UDim2.new(1, -100, 0, 26); Title.Position = UDim2.new(0, 52, 0, 10); Title.BackgroundTransparency = 1; Title.Text = "ONE PIECE"; Title.TextColor3 = OP.Gold; Title.Font = Enum.Font.BuilderSansBold; Title.TextSize = 22; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.TextStrokeColor3 = OP.Jolly; Title.TextStrokeTransparency = 0; Title.ZIndex = 52

local CloseBtn = Instance.new("TextButton", MainFrame); CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -40, 0, 14); CloseBtn.BackgroundColor3 = OP.Parchment; CloseBtn.Text = "✕"; CloseBtn.TextColor3 = OP.FireRed; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 14; CloseBtn.ZIndex = 52; CloseBtn.AutoButtonColor = false
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- TABS SCROLL (Para que quepan todas en celular)
local TabBar = Instance.new("ScrollingFrame", MainFrame)
TabBar.Size = UDim2.new(1, -20, 0, 34); TabBar.Position = UDim2.new(0, 10, 0, 56)
TabBar.BackgroundColor3 = OP.Parchment; TabBar.BackgroundTransparency = 0.2; TabBar.ZIndex = 51
TabBar.ScrollBarThickness = 0; TabBar.CanvasSize = UDim2.new(0, 0, 0, 0); TabBar.AutomaticCanvasSize = Enum.AutomaticSize.X; TabBar.ScrollingDirection = Enum.ScrollingDirection.X
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(1, 0)
local TabLayout = Instance.new("UIListLayout", TabBar); TabLayout.FillDirection = Enum.FillDirection.Horizontal; TabLayout.Padding = UDim.new(0, 5); TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
local TabPad = Instance.new("UIPadding", TabBar); TabPad.PaddingLeft = UDim.new(0, 5); TabPad.PaddingRight = UDim.new(0, 5)

local ContentArea = Instance.new("ScrollingFrame", MainFrame)
ContentArea.Size = UDim2.new(1, -20, 1, -150); ContentArea.Position = UDim2.new(0, 10, 0, 100)
ContentArea.BackgroundTransparency = 1; ContentArea.ScrollBarThickness = 3; ContentArea.ScrollBarImageColor3 = OP.Gold
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 800); ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y; ContentArea.ZIndex = 51
local ContentPad = Instance.new("UIPadding", ContentArea); ContentPad.PaddingRight = UDim.new(0, 6)

local Sections = {}
local function CreateSection(name)
    local f = Instance.new("Frame", ContentArea); f.Size = UDim2.new(1, 0, 0, 0); f.BackgroundTransparency = 1; f.Visible = false; f.ZIndex = 52
    f.AutomaticSize = Enum.AutomaticSize.Y
    Sections[name] = f; return f
end

local ESPPage    = CreateSection("ESP")
local AimbotPage = CreateSection("Aimbot")
local MovePage   = CreateSection("Move")
local FarmPage   = CreateSection("Farm")
local MiscPage   = CreateSection("Misc")
local ConfigPage = CreateSection("Config")

local TabButtons = {}
local currentTab = nil
local function SwitchTab(name)
    for n, p in pairs(Sections) do p.Visible = (n == name) end
    for n, b in pairs(TabButtons) do
        local active = (n == name)
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = active and OP.Gold or OP.Parchment, BackgroundTransparency = active and 0 or 0.3, TextColor3 = active and OP.Ink or OP.Muted}):Play()
    end
    currentTab = name
end

local function CreateTabButton(name)
    local btn = Instance.new("TextButton", TabBar); btn.Size = UDim2.new(0, 62, 0, 24); btn.BackgroundColor3 = OP.Parchment; btn.BackgroundTransparency = 0.3; btn.Text = name; btn.TextColor3 = OP.Muted; btn.Font = Enum.Font.BuilderSansBold; btn.TextSize = 11; btn.AutoButtonColor = false; btn.ZIndex = 52
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    btn.Activated:Connect(function() PlaySound(); SwitchTab(name) end) -- FIX: Activated para movil
    TabButtons[name] = btn
end
CreateTabButton("ESP"); CreateTabButton("Aimbot"); CreateTabButton("Move"); CreateTabButton("Farm"); CreateTabButton("Misc"); CreateTabButton("Config")

-- BUILDERS
local function CreateLabel(parent, text, yPos, color)
    local lbl = Instance.new("TextLabel", parent); lbl.Size = UDim2.new(1, 0, 0, 18); lbl.Position = UDim2.new(0, 4, 0, yPos); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = color or OP.Muted; lbl.Font = Enum.Font.BuilderSansBold; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 100
    return lbl
end

local function CreateToggle(parent, text, yPos, callback, default)
    local state = default ~= false
    local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(1, 0, 0, 36); btn.Position = UDim2.new(0, 0, 0, yPos); btn.BackgroundColor3 = OP.Parchment; btn.BackgroundTransparency = 0.15; btn.Text = ""; btn.AutoButtonColor = false; btn.ZIndex = 100
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", btn); stroke.Color = OP.Gold; stroke.Thickness = 1; stroke.Transparency = 0.55
    local label = Instance.new("TextLabel", btn); label.Size = UDim2.new(1, -60, 1, 0); label.Position = UDim2.new(0, 12, 0, 0); label.Text = text; label.TextColor3 = OP.Ink; label.TextXAlignment = Enum.TextXAlignment.Left; label.BackgroundTransparency = 1; label.Font = Enum.Font.BuilderSansBold; label.TextSize = 12; label.ZIndex = 101
    local switchBg = Instance.new("Frame", btn); switchBg.Size = UDim2.new(0, 36, 0, 18); switchBg.Position = UDim2.new(1, -48, 0.5, -9); switchBg.BackgroundColor3 = state and OP.Gold or OP.ParchDark; switchBg.ZIndex = 101
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
    local thumb = Instance.new("Frame", switchBg); thumb.Size = UDim2.new(0, 14, 0, 14); thumb.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7); thumb.BackgroundColor3 = OP.White; thumb.ZIndex = 102
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
    
    btn.Activated:Connect(function()
        state = not state; PlaySound()
        TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = state and OP.Gold or OP.ParchDark}):Play()
        TweenService:Create(thumb, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
        if callback then callback(state) end
    end)
    return btn
end

local function CreateSlider(parent, text, yPos, minVal, maxVal, defaultVal, callback, decimals)
    decimals = decimals or 2
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1, 0, 0, 42); frame.Position = UDim2.new(0, 0, 0, yPos); frame.BackgroundColor3 = OP.Parchment; frame.BackgroundTransparency = 0.15; frame.ZIndex = 100
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", frame); stroke.Color = OP.Gold; stroke.Thickness = 1; stroke.Transparency = 0.55
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1, -20, 0, 16); label.Position = UDim2.new(0, 12, 0, 4); label.BackgroundTransparency = 1; label.Text = string.format("%s: %." .. decimals .. "f", text, defaultVal); label.TextColor3 = OP.Ink; label.TextXAlignment = Enum.TextXAlignment.Left; label.Font = Enum.Font.BuilderSansBold; label.TextSize = 12; label.ZIndex = 101
    local bar = Instance.new("Frame", frame); bar.Size = UDim2.new(1, -24, 0, 6); bar.Position = UDim2.new(0, 12, 0, 26); bar.BackgroundColor3 = OP.ParchDark; bar.ZIndex = 101; bar.Active = true
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local percent = (defaultVal - minVal) / (maxVal - minVal)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new(percent, 0, 1, 0); fill.BackgroundColor3 = OP.Gold; fill.ZIndex = 102
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

local function CreateButton(parent, text, yPos, callback, color)
    local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(1, 0, 0, 34); btn.Position = UDim2.new(0, 0, 0, yPos); btn.BackgroundColor3 = color or OP.Parchment; btn.BackgroundTransparency = 0.1; btn.Text = text; btn.TextColor3 = OP.Ink; btn.Font = Enum.Font.BuilderSansBold; btn.TextSize = 12; btn.AutoButtonColor = false; btn.ZIndex = 100
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", btn); stroke.Color = OP.Gold; stroke.Thickness = 1.2; stroke.Transparency = 0.4
    btn.Activated:Connect(function() PlaySound(); if callback then callback() end end)
end

-- ==========================================================
-- POBLAR PÁGINAS
-- ==========================================================
local espY = 0
CreateLabel(ESPPage, "─── VISUAL ───", espY, OP.FireRed); espY += 22
CreateToggle(ESPPage, "Cajas 3D", espY, function(s) Config.ESPEnabled = s end, Config.ESPEnabled); espY += 42
CreateToggle(ESPPage, "Resaltado (Highlight)", espY, function(s) Config.ESPHighlight = s end, Config.ESPHighlight); espY += 42
CreateToggle(ESPPage, "Nombres y Distancia", espY, function(s) Config.ShowNames = s end, Config.ShowNames); espY += 46

local aimY = 0
CreateLabel(AimbotPage, "─── COMBATE ───", aimY, OP.FireRed); aimY += 22
CreateToggle(AimbotPage, "Aimbot (Cámara)", aimY, function(s) Config.AimbotEnabled = s end, Config.AimbotEnabled); aimY += 42
CreateToggle(AimbotPage, "Instakill (Auto Disparo)", aimY, function(s) Config.Instakill = s end, Config.Instakill); aimY += 42
CreateToggle(AimbotPage, "Mostrar FOV", aimY, function(s) Config.ShowFOVCircle = s end, Config.ShowFOVCircle); aimY += 42
CreateSlider(AimbotPage, "Smooth", aimY, 0.05, 0.5, Config.AimbotSmooth, function(v) Config.AimbotSmooth = v end); aimY += 48
CreateSlider(AimbotPage, "Tamaño FOV", aimY, 50, 600, Config.ScreenFOV, function(v) Config.ScreenFOV = v end, 0); aimY += 48

local mvY = 0
CreateLabel(MovePage, "─── VELOCIDAD ───", mvY, OP.FireRed); mvY += 22
CreateSlider(MovePage, "WalkSpeed", mvY, 16, 150, Config.WalkSpeed, function(v) Config.WalkSpeed = v; local h = getHumanoid(); if h then h.WalkSpeed = v end end, 0); mvY += 48
CreateSlider(MovePage, "JumpPower", mvY, 50, 200, Config.JumpPower, function(v) Config.JumpPower = v; local h = getHumanoid(); if h then h.JumpPower = v; h.UseJumpPower = true end end, 0); mvY += 48
CreateLabel(MovePage, "─── HABILIDADES ───", mvY, OP.FireRed); mvY += 22
CreateToggle(MovePage, "Fly (Volar)", mvY, function(s) Config.FlyEnabled = s; ToggleFly(s) end, Config.FlyEnabled); mvY += 42
CreateSlider(MovePage, "Velocidad Vuelo", mvY, 20, 200, Config.FlySpeed, function(v) Config.FlySpeed = v end, 0); mvY += 48
CreateToggle(MovePage, "Noclip (Atravesar)", mvY, function(s) Config.Noclip = s end, Config.Noclip); mvY += 42

local farmY = 0
CreateLabel(FarmPage, "─── FARMEO ───", farmY, OP.FireRed); farmY += 22
CreateToggle(FarmPage, "AutoFarm (Teletransporte)", farmY, function(s) Config.AutoFarm = s; ToggleFarm(s) end, Config.AutoFarm); farmY += 42
CreateLabel(FarmPage, "Teletransporta al personaje a traves de\nlas paredes directo a las monedas.", farmY, OP.Muted); farmY += 30

local miscY = 0
CreateLabel(MiscPage, "─── MISC ───", miscY, OP.FireRed); miscY += 22
CreateToggle(MiscPage, "Esquivar Cuchillos", miscY, function(s) Config.KnifeDodge = s end, Config.KnifeDodge); miscY += 42
CreateToggle(MiscPage, "Anti-Void", miscY, function(s) Config.AntiVoid = s end, Config.AntiVoid); miscY += 42
CreateToggle(MiscPage, "Efectos de Sonido", miscY, function(s) Config.SoundsEnabled = s end, Config.SoundsEnabled); miscY += 42

local cfgY = 0
CreateLabel(ConfigPage, "─── INFO ───", cfgY, OP.FireRed); cfgY += 22
CreateButton(ConfigPage, "❌ Cerrar menú", cfgY, function() if _G.OnePieceMenuOpen then ToggleMenu() end end, OP.FireRed)

-- ==========================================================
-- DRAG & OPEN/CLOSE
-- ==========================================================
local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = frame.Position end end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UIS.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
end
MakeDraggable(ToggleBtn, ToggleBtn); MakeDraggable(MainFrame, ToggleBtn) -- Drag desde ToggleBtn o Header

_G.OnePieceMenuOpen = false
function ToggleMenu()
    _G.OnePieceMenuOpen = not _G.OnePieceMenuOpen
    if _G.OnePieceMenuOpen then
        MainFrame.Visible = true; menuScale.Scale = 0.85
        TweenService:Create(menuScale, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Scale = math.clamp(math.min(Camera.ViewportSize.X, Camera.ViewportSize.Y) / 460, 0.65, 1)}):Play()
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
-- MAIN LOOPS & CHARACTER RESPAWN LOGIC
-- ==========================================================
SwitchTab("ESP")

-- Aplicar movimiento al morir / respawnear
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Config.WalkSpeed
        hum.JumpPower = Config.JumpPower
        hum.UseJumpPower = true
    end
    if Config.FlyEnabled then ToggleFly(true) end
    if Config.AutoFarm then ToggleFarm(true) end
end)

RunService.RenderStepped:Connect(function()
    pcall(UpdateESP)
    pcall(UpdateAimbot)
    
    -- Anti-Void
    if Config.AntiVoid then
        local hrp = getHRP()
        if hrp and hrp.Position.Y < -30 then hrp.CFrame = CFrame.new(0, 50, 0) end
    end
end)

print("[ONE PIECE HUB] ¡Cargado! Farm con Teletransporte y Noclip activados. 🏴‍☠️")
