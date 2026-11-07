-- ==========================================================
-- 🏴‍☠️ ONE PIECE GAEL SCRIPT v7.1 | ULTIMATE MM2 (FIXED)
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
    ESPEnabled    = true,
    ESPHighlight  = true,
    ShowNames     = true,
    ShowDistance  = true,
    ESPThickness  = 2,
    
    AimbotEnabled = false,
    AimbotSmooth  = 0.15,
    Instakill     = false,
    ShowFOVCircle = true,
    ScreenFOV     = 250,
    LastInstakill = 0, -- Cooldown
    
    WalkSpeed     = 16,
    JumpPower     = 50,
    FlyEnabled    = false,
    FlySpeed      = 50,
    Noclip        = false,
    AntiVoid      = true,
    
    AutoFarm      = false,
    FarmSpeed     = 50,
    
    KnifeDodge    = true,
    SoundsEnabled = true,
    Weather       = "CalmSea",
}

-- ==========================================================
-- ONE PIECE PALETTE (Error corregido: se agregaron StrawGold y StrawDark)
-- ==========================================================
local OP = {
    Parchment = Color3.fromRGB(246, 231, 197),
    ParchDark = Color3.fromRGB(215, 195, 155),
    Ink       = Color3.fromRGB(35, 25, 15),
    Gold      = Color3.fromRGB(235, 195, 70),
    FireRed   = Color3.fromRGB(235, 75, 75),
    Marine    = Color3.fromRGB(70, 135, 225),
    Green     = Color3.fromRGB(90, 210, 130),
    White     = Color3.fromRGB(255, 255, 255),
    Muted     = Color3.fromRGB(115, 140, 170),
    Jolly     = Color3.fromRGB(22, 28, 44),
    StrawGold = Color3.fromRGB(255, 210, 90), -- FIX
    StrawDark = Color3.fromRGB(205, 155, 45), -- FIX
}

local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ==========================================================
-- WEATHER THEMES
-- ==========================================================
local Weathers = {
    CalmSea = {
        Name = "Calm Sea", Accent = Color3.fromRGB(120, 190, 255),
        Gradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 200, 255)), ColorSequenceKeypoint.new(0.55, Color3.fromRGB(80, 150, 220)), ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 100, 175))}),
        Clouds = true, Sun = true, Rain = false, Stars = false,
    },
    Storm = {
        Name = "Storm", Accent = Color3.fromRGB(140, 160, 200),
        Gradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 80, 100)), ColorSequenceKeypoint.new(0.55, Color3.fromRGB(45, 55, 80)), ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 30, 50))}),
        Clouds = true, Sun = false, Rain = true, Stars = false,
    },
    Sunset = {
        Name = "Sunset", Accent = Color3.fromRGB(255, 170, 90),
        Gradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 120)), ColorSequenceKeypoint.new(0.45, Color3.fromRGB(250, 130, 100)), ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 65, 140))}),
        Clouds = true, Sun = true, Rain = false, Stars = false,
    },
    NightSea = {
        Name = "Night Sea", Accent = Color3.fromRGB(130, 175, 240),
        Gradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 45, 95)), ColorSequenceKeypoint.new(0.55, Color3.fromRGB(20, 30, 70)), ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 15, 40))}),
        Clouds = false, Sun = false, Rain = false, Stars = true,
    },
}

-- ==========================================================
-- COMPAT & POOLS
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
    local line = LinePool[LineIndex]; line.Thickness = Config.ESPThickness; return line
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
        s.SoundId = "rbxasset://sounds/electronicpingshort.wav"; s.Volume = 0.35
        s.PlaybackSpeed = (kind == "open" and 1.3) or (kind == "close" and 0.7) or 1
        s.Parent = SoundService; s:Play(); Debris:AddItem(s, 2)
    end)
end

-- ==========================================================
-- MM2 HELPERS
-- ==========================================================
local function getHRP() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") end
local function getHumanoid() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") end

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

local function GetPlayerRole(p)
    if IsMurder(p) then return "Murderer", OP.FireRed end
    if IsSheriff(p) then return "Sheriff", OP.Marine end
    return "Innocent", OP.Green
end

-- ==========================================================
-- HAPPYHUB EXTRACTED LOGIC (AIMBOT / INSTAKILL / DODGE)
-- ==========================================================
local function getGun()
    local char = LocalPlayer.Character
    if not char then return nil end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local gun = char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun"))
    return gun
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
    
    local origin = CFrame.new(targetHRP.Position - targetHRP.CFrame.LookVector * 3.5)
    local target = CFrame.new(targetHRP.Position)
    
    pcall(function() shootEvent:FireServer(origin, target) end)
end

-- Knife Dodge Logic
task.spawn(function()
    local cs = ReplicatedStorage:WaitForChild("ClientServices", 10)
    local ws = cs and cs:FindFirstChild("WeaponService")
    local gf = ws and ws:FindFirstChild("GunFired")
    if gf then
        gf.OnClientEvent:Connect(function(handle, p1, p2, part)
            if not Config.KnifeDodge then return end
            if typeof(p1) ~= "Vector3" or typeof(p2) ~= "Vector3" then return end
            local hrp = getHRP()
            if not hrp then return end
            local myPos = hrp.Position
            
            local dir = p2 - p1
            local len = dir.Magnitude
            if len < 5 then return end
            local unit = dir.Unit
            local toMe = myPos - p1
            local proj = toMe:Dot(unit)
            
            if proj > -10 and proj < len + 30 then
                local closest = p1 + unit * math.clamp(proj, 0, len)
                if (myPos - closest).Magnitude < 12 then
                    local perp = unit:Cross(Vector3.yAxis).Unit
                    local side = (myPos - closest):Dot(perp) > 0 and 1 or -1
                    hrp.CFrame = CFrame.new(myPos + perp * side * 20 + Vector3.new(0, 3, 0))
                end
            end
        end)
    end
end)

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

    -- 3D BOX
    if Config.ESPEnabled then
        local cf = hrp.CFrame * CFrame.new(0, -0.5, 0)
        local corners = GetCorners(cf, Vector3.new(3, 5, 3))
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

    -- HIGHLIGHT
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

    -- NAMETAGS
    if Config.ShowNames then
        local head = char:FindFirstChild("Head") or hrp
        local pos, on = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
        if on then
            local role, _ = GetPlayerRole(player)
            local txt = player.Name
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
            lbl.Text = txt; lbl.Position = Vector2.new(pos.X, pos.Y); lbl.Color = color; lbl.Visible = true
        end
    end
end

local function UpdateESP()
    if not HasDrawing then return end
    ResetLines(); ResetLabels()
    if not (Config.ESPEnabled or Config.ESPHighlight or Config.ShowNames) or not LocalPlayer.Character then 
        for p, h in pairs(HighlightCache) do 
            pcall(function() h:Destroy() end) 
            HighlightCache[p] = nil 
        end
        return 
    end
    local idx = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            idx += 1
            pcall(DrawFor, p, idx)
        end
    end
end

-- ==========================================================
-- AIMBOT & FOV LÓGICA
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
                    local desired = CFrame.new(Camera.CFrame.Position, tHead.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(desired, Config.AimbotSmooth)
                    
                    -- Instakill con cooldown para evitar Kick por spam
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
-- MOVEMENT & FARM LÓGICA
-- ==========================================================
local noclipConn = nil
local function ToggleNoclip(state)
    if state then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    end
end

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

local farmThread = nil
local function ToggleFarm(state)
    if state then
        if farmThread then task.cancel(farmThread) end
        farmThread = task.spawn(function()
            while Config.AutoFarm do
                task.wait(0.1)
                local hrp = getHRP()
                if hrp then
                    local container = Workspace:FindFirstChild("CoinContainer", true)
                    if container then
                        local bestCoin, minDist = nil, math.huge
                        for _, coin in ipairs(container:GetChildren()) do
                            if coin:IsA("BasePart") and not coin:GetAttribute("Collected") then
                                local d = (coin.Position - hrp.Position).Magnitude
                                if d < minDist then minDist = d; bestCoin = coin end
                            end
                        end
                        if bestCoin then
                            pcall(firetouchinterest, hrp, bestCoin, 0)
                            task.wait(0.01)
                            pcall(firetouchinterest, hrp, bestCoin, 1)
                            
                            if minDist > 10 then
                                hrp.Velocity = (bestCoin.Position - hrp.Position).Unit * Config.FarmSpeed
                            end
                        end
                    end
                end
            end
        end)
    else
        if farmThread then task.cancel(farmThread); farmThread = nil end
    end
end

-- ==========================================================
-- UI CREATION (A prueba de fallos)
-- ==========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OnePieceUltimate"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- TOASTS
local toastStack = 0
local function ShowToast(text, accent)
    accent = accent or OP.Gold; toastStack += 1; local slot = toastStack
    local toast = Instance.new("Frame", ScreenGui)
    toast.Size = UDim2.new(0, 240, 0, 46); toast.Position = UDim2.new(1, 20, 0, 20 + (slot-1)*56)
    toast.BackgroundColor3 = OP.Parchment; toast.BackgroundTransparency = 0.05; toast.ZIndex = 200
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", toast); stroke.Color = accent; stroke.Thickness = 2
    local bar = Instance.new("Frame", toast); bar.Size = UDim2.new(0, 5, 1, -14); bar.Position = UDim2.new(0, 6, 0, 7); bar.BackgroundColor3 = accent
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local label = Instance.new("TextLabel", toast); label.Size = UDim2.new(1, -30, 1, 0); label.Position = UDim2.new(0, 20, 0, 0)
    label.BackgroundTransparency = 1; label.Text = text; label.TextColor3 = OP.Ink; label.Font = Enum.Font.BuilderSansBold; label.TextSize = 13; label.TextXAlignment = Enum.TextXAlignment.Left
    
    TweenService:Create(toast, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -260, 0, 20 + (slot-1)*56)}):Play()
    task.delay(2.3, function()
        local tOut = TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 0, 20 + (slot-1)*56)})
        tOut:Play(); tOut.Completed:Wait(); toast:Destroy(); toastStack -= 1
    end)
end

-- TOGGLE BUTTON
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 158, 0, 46); ToggleBtn.Position = UDim2.new(0, 15, 0, 60)
ToggleBtn.BackgroundColor3 = OP.Parchment; ToggleBtn.Text = "🏴‍☠️ ONE PIECE V7"
ToggleBtn.TextColor3 = OP.Ink; ToggleBtn.Font = Enum.Font.BuilderSansBold; ToggleBtn.TextSize = 15
ToggleBtn.ZIndex = 100; ToggleBtn.AutoButtonColor = false; ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local tGrad = Instance.new("UIGradient", ToggleBtn); tGrad.Rotation = 90; tGrad.Color = ColorSequence.new(OP.Parchment, OP.ParchDark)
local tStroke = Instance.new("UIStroke", ToggleBtn); tStroke.Color = OP.Gold; tStroke.Thickness = 2

-- MAIN WINDOW
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 540); MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = OP.White; MainFrame.Visible = false; MainFrame.ClipsDescendants = true; MainFrame.ZIndex = 50; MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 18)
local mainGradient = Instance.new("UIGradient", MainFrame); mainGradient.Rotation = 90; mainGradient.Color = Weathers.CalmSea.Gradient
local mainStroke = Instance.new("UIStroke", MainFrame); mainStroke.Color = OP.Gold; mainStroke.Thickness = 2.5; mainStroke.Transparency = 0.1
local menuScale = Instance.new("UIScale", MainFrame); menuScale.Scale = 1

-- WEATHER LAYERS
local CloudLayer = Instance.new("Frame", MainFrame); CloudLayer.Size = UDim2.new(1, 0, 1, 0); CloudLayer.BackgroundTransparency = 1; CloudLayer.ClipsDescendants = true; CloudLayer.ZIndex = 2
local RainLayer = Instance.new("Frame", MainFrame); RainLayer.Size = UDim2.new(1, 0, 1, 0); RainLayer.BackgroundTransparency = 1; RainLayer.ClipsDescendants = true; RainLayer.ZIndex = 3; RainLayer.Visible = false
local StarLayer = Instance.new("Frame", MainFrame); StarLayer.Size = UDim2.new(1, 0, 1, 0); StarLayer.BackgroundTransparency = 1; StarLayer.ClipsDescendants = true; StarLayer.ZIndex = 2; StarLayer.Visible = false
local SunLayer = Instance.new("Frame", MainFrame); SunLayer.Size = UDim2.new(0, 60, 0, 60); SunLayer.Position = UDim2.new(1, -85, 0, 20); SunLayer.BackgroundColor3 = Color3.fromRGB(255, 230, 130); SunLayer.BackgroundTransparency = 0.15; SunLayer.ZIndex = 2; SunLayer.Visible = false
Instance.new("UICorner", SunLayer).CornerRadius = UDim.new(1, 0)

for i = 1, 4 do
    local cloud = Instance.new("Frame", CloudLayer); cloud.Size = UDim2.new(0, 100 + math.random(20,60), 0, 34); cloud.Position = UDim2.new(-0.4, 0, math.random(10,80)/100, 0); cloud.BackgroundColor3 = OP.White; cloud.BackgroundTransparency = 0.6
    Instance.new("UICorner", cloud).CornerRadius = UDim.new(1, 0)
    task.spawn(function()
        while cloud.Parent do
            local t = TweenService:Create(cloud, TweenInfo.new(40 + math.random(10), Enum.EasingStyle.Linear), {Position = UDim2.new(1, 20, cloud.Position.Y.Scale, 0)})
            t:Play(); t.Completed:Wait(); cloud.Position = UDim2.new(-0.4, 0, cloud.Position.Y.Scale, 0)
        end
    end)
end

local function ApplyWeather(name)
    local w = Weathers[name]; if not w then return end
    Config.Weather = name; mainGradient.Color = w.Gradient 
    CloudLayer.Visible = w.Clouds; RainLayer.Visible = w.Rain; StarLayer.Visible = w.Stars; SunLayer.Visible = w.Sun
    mainStroke.Color = w.Accent; tStroke.Color = w.Accent
end

-- HEADER
local StrawHat = Instance.new("Frame", MainFrame); StrawHat.Size = UDim2.new(0, 36, 0, 36); StrawHat.Position = UDim2.new(0, 14, 0, 12); StrawHat.BackgroundTransparency = 1; StrawHat.ZIndex = 52
local hatCap = Instance.new("Frame", StrawHat); hatCap.Size = UDim2.new(0, 22, 0, 15); hatCap.Position = UDim2.new(0, 7, 0, 3); hatCap.BackgroundColor3 = OP.StrawGold; hatCap.ZIndex = 53
Instance.new("UICorner", hatCap).CornerRadius = UDim.new(0, 10)
local hatBand = Instance.new("Frame", StrawHat); hatBand.Size = UDim2.new(0, 22, 0, 4); hatBand.Position = UDim2.new(0, 7, 0, 12); hatBand.BackgroundColor3 = OP.FireRed; hatBand.ZIndex = 54
Instance.new("UICorner", hatBand).CornerRadius = UDim.new(0, 2)
local hatBrim = Instance.new("Frame", StrawHat); hatBrim.Size = UDim2.new(0, 34, 0, 7); hatBrim.Position = UDim2.new(0, 1, 0, 20); hatBrim.BackgroundColor3 = OP.StrawDark; hatBrim.ZIndex = 53
Instance.new("UICorner", hatBrim).CornerRadius = UDim.new(1, 0)

local Header = Instance.new("Frame", MainFrame); Header.Size = UDim2.new(1, 0, 0, 56); Header.BackgroundTransparency = 1; Header.ZIndex = 51
local Title = Instance.new("TextLabel", Header); Title.Size = UDim2.new(1, -140, 0, 26); Title.Position = UDim2.new(0, 56, 0, 5); Title.BackgroundTransparency = 1; Title.Text = "ONE PIECE"; Title.TextColor3 = OP.Gold; Title.Font = Enum.Font.BuilderSansBold; Title.TextSize = 21; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.TextStrokeColor3 = OP.Jolly; Title.TextStrokeTransparency = 0; Title.ZIndex = 52
local Subtitle = Instance.new("TextLabel", Header); Subtitle.Size = UDim2.new(1, -140, 0, 16); Subtitle.Position = UDim2.new(0, 57, 0, 32); Subtitle.BackgroundTransparency = 1; Subtitle.Text = "⚓ ULTIMATE MM2"; Subtitle.TextColor3 = OP.FireRed; Subtitle.Font = Enum.Font.BuilderSansBold; Subtitle.TextSize = 10; Subtitle.TextXAlignment = Enum.TextXAlignment.Left; Subtitle.TextStrokeColor3 = OP.Jolly; Subtitle.TextStrokeTransparency = 0.5; Subtitle.ZIndex = 52

local CloseBtn = Instance.new("TextButton", Header); CloseBtn.Size = UDim2.new(0, 34, 0, 34); CloseBtn.Position = UDim2.new(1, -46, 0.5, -17); CloseBtn.BackgroundColor3 = OP.Parchment; CloseBtn.Text = "✕"; CloseBtn.TextColor3 = OP.FireRed; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 16; CloseBtn.ZIndex = 52; CloseBtn.AutoButtonColor = false
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)
local cbStroke = Instance.new("UIStroke", CloseBtn); cbStroke.Color = OP.Gold; cbStroke.Thickness = 1.5

-- TABS
local TabBar = Instance.new("ScrollingFrame", MainFrame)
TabBar.Size = UDim2.new(1, -24, 0, 42); TabBar.Position = UDim2.new(0, 12, 0, 62)
TabBar.BackgroundColor3 = OP.Parchment; TabBar.BackgroundTransparency = 0.25; TabBar.ZIndex = 51
TabBar.ScrollBarThickness = 0; TabBar.CanvasSize = UDim2.new(0, 0, 0, 0); TabBar.ScrollingDirection = Enum.ScrollingDirection.X
TabBar.AutomaticCanvasSize = Enum.AutomaticSize.X -- FIX: Tabs no se apilan
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(1, 0)
local tbStroke = Instance.new("UIStroke", TabBar); tbStroke.Color = OP.Gold; tbStroke.Thickness = 1.5; tbStroke.Transparency = 0.3

local TabLayout = Instance.new("UIListLayout", TabBar); TabLayout.FillDirection = Enum.FillDirection.Horizontal; TabLayout.Padding = UDim.new(0, 6); TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local ContentArea = Instance.new("ScrollingFrame", MainFrame)
ContentArea.Size = UDim2.new(1, -24, 1, -170); ContentArea.Position = UDim2.new(0, 12, 0, 112)
ContentArea.BackgroundTransparency = 1; ContentArea.BorderSizePixel = 0; ContentArea.ScrollBarThickness = 4; ContentArea.ScrollBarImageColor3 = OP.Gold
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 600); ContentArea.ZIndex = 51; ContentArea.ClipsDescendants = true

local Sections = {}
local function CreateSection(name)
    local f = Instance.new("Frame", ContentArea); f.Size = UDim2.new(1, -6, 0, 600); f.BackgroundTransparency = 1; f.Visible = false; f.ZIndex = 52; f.BorderSizePixel = 0
    Sections[name] = f; return f
end

local ESPPage    = CreateSection("ESP")
local AimbotPage = CreateSection("Aimbot")
local MovePage   = CreateSection("Move")
local FarmPage   = CreateSection("Farm")
local MiscPage   = CreateSection("Misc")
local WeatherPage= CreateSection("Weather")
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
    local btn = Instance.new("TextButton", TabBar); btn.Size = UDim2.new(0, 70, 0, 30); btn.BackgroundColor3 = OP.Parchment; btn.BackgroundTransparency = 0.3; btn.Text = name; btn.TextColor3 = OP.Muted; btn.Font = Enum.Font.BuilderSansBold; btn.TextSize = 12; btn.AutoButtonColor = false; btn.ZIndex = 52
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    btn.Activated:Connect(function() PlaySound(); SwitchTab(name) end)
    TabButtons[name] = btn
end
CreateTabButton("ESP"); CreateTabButton("Aimbot"); CreateTabButton("Move"); CreateTabButton("Farm"); CreateTabButton("Misc"); CreateTabButton("Weather"); CreateTabButton("Config")

-- BUILDERS
local function CreateLabel(parent, text, yPos, color)
    local lbl = Instance.new("TextLabel", parent); lbl.Size = UDim2.new(1, 0, 0, 20); lbl.Position = UDim2.new(0, 6, 0, yPos); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = color or OP.Muted; lbl.Font = Enum.Font.BuilderSansBold; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 100
    return lbl
end

local function CreateToggle(parent, text, yPos, callback, default)
    local state = default ~= false
    local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(1, 0, 0, 44); btn.Position = UDim2.new(0, 0, 0, yPos); btn.BackgroundColor3 = OP.Parchment; btn.BackgroundTransparency = 0.15; btn.Text = ""; btn.AutoButtonColor = false; btn.ZIndex = 100
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", btn); stroke.Color = OP.Gold; stroke.Thickness = 1; stroke.Transparency = 0.55
    local label = Instance.new("TextLabel", btn); label.Size = UDim2.new(1, -70, 1, 0); label.Position = UDim2.new(0, 14, 0, 0); label.Text = text; label.TextColor3 = OP.Ink; label.TextXAlignment = Enum.TextXAlignment.Left; label.BackgroundTransparency = 1; label.Font = Enum.Font.BuilderSansBold; label.TextSize = 14; label.ZIndex = 101
    local switchBg = Instance.new("Frame", btn); switchBg.Size = UDim2.new(0, 44, 0, 22); switchBg.Position = UDim2.new(1, -56, 0.5, -11); switchBg.BackgroundColor3 = state and OP.Gold or OP.ParchDark; switchBg.ZIndex = 101
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
    local thumb = Instance.new("Frame", switchBg); thumb.Size = UDim2.new(0, 18, 0, 18); thumb.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9); thumb.BackgroundColor3 = OP.White; thumb.ZIndex = 102
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
    
    btn.Activated:Connect(function()
        state = not state; PlaySound()
        TweenService:Create(switchBg, TweenInfo.new(0.25), {BackgroundColor3 = state and OP.Gold or OP.ParchDark}):Play()
        TweenService:Create(thumb, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
        if callback then callback(state) end
    end)
    return btn
end

local function CreateSlider(parent, text, yPos, minVal, maxVal, defaultVal, callback, decimals)
    decimals = decimals or 2
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(1, 0, 0, 50); frame.Position = UDim2.new(0, 0, 0, yPos); frame.BackgroundColor3 = OP.Parchment; frame.BackgroundTransparency = 0.15; frame.ZIndex = 100
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", frame); stroke.Color = OP.Gold; stroke.Thickness = 1; stroke.Transparency = 0.55
    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(1, -24, 0, 18); label.Position = UDim2.new(0, 14, 0, 6); label.BackgroundTransparency = 1; label.Text = string.format("%s: %." .. decimals .. "f", text, defaultVal); label.TextColor3 = OP.Ink; label.TextXAlignment = Enum.TextXAlignment.Left; label.Font = Enum.Font.BuilderSansBold; label.TextSize = 13; label.ZIndex = 101
    local bar = Instance.new("Frame", frame); bar.Size = UDim2.new(1, -28, 0, 8); bar.Position = UDim2.new(0, 14, 0, 32); bar.BackgroundColor3 = OP.ParchDark; bar.ZIndex = 101; bar.Active = true
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local percent = (defaultVal - minVal) / (maxVal - minVal)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new(percent, 0, 1, 0); fill.BackgroundColor3 = OP.Gold; fill.ZIndex = 102
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame", bar); knob.Size = UDim2.new(0, 18, 0, 18); knob.Position = UDim2.new(percent, -9, 0.5, -9); knob.BackgroundColor3 = OP.White; knob.ZIndex = 103
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local function setVal(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = minVal + (maxVal - minVal) * rel
        fill.Size = UDim2.new(rel, 0, 1, 0); knob.Position = UDim2.new(rel, -9, 0.5, -9); label.Text = string.format("%s: %." .. decimals .. "f", text, val)
        if callback then callback(val) end
    end
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; setVal(input.Position.X) end end)
    UIS.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then setVal(input.Position.X) end end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end

local function CreateButton(parent, text, yPos, callback, color)
    local base = color or OP.Parchment
    local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(1, 0, 0, 40); btn.Position = UDim2.new(0, 0, 0, yPos); btn.BackgroundColor3 = base; btn.BackgroundTransparency = 0.1; btn.Text = text; btn.TextColor3 = OP.Ink; btn.Font = Enum.Font.BuilderSansBold; btn.TextSize = 13; btn.AutoButtonColor = false; btn.ZIndex = 100
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", btn); stroke.Color = OP.Gold; stroke.Thickness = 1.2; stroke.Transparency = 0.4
    btn.Activated:Connect(function() PlaySound(); if callback then callback() end end)
    return btn
end

-- ==========================================================
-- POBLAR PÁGINAS
-- ==========================================================
local espY = 0
CreateLabel(ESPPage, "─── VISUAL ───", espY, OP.FireRed); espY += 24
CreateToggle(ESPPage, "Cajas 3D", espY, function(s) Config.ESPEnabled = s end, Config.ESPEnabled); espY += 50
CreateToggle(ESPPage, "Resaltado (Highlight)", espY, function(s) Config.ESPHighlight = s end, Config.ESPHighlight); espY += 50
CreateToggle(ESPPage, "Nombres y Distancia", espY, function(s) Config.ShowNames = s end, Config.ShowNames); espY += 50

local aimY = 0
CreateLabel(AimbotPage, "─── COMBATE ───", aimY, OP.FireRed); aimY += 24
CreateToggle(AimbotPage, "Aimbot (Cámara)", aimY, function(s) Config.AimbotEnabled = s end, Config.AimbotEnabled); aimY += 50
CreateToggle(AimbotPage, "Instakill (Auto Disparo)", aimY, function(s) Config.Instakill = s end, Config.Instakill); aimY += 50
CreateToggle(AimbotPage, "Mostrar FOV", aimY, function(s) Config.ShowFOVCircle = s end, Config.ShowFOVCircle); aimY += 50
CreateSlider(AimbotPage, "Smooth (Suavidad)", aimY, 0.05, 0.5, Config.AimbotSmooth, function(v) Config.AimbotSmooth = v end); aimY += 56
CreateSlider(AimbotPage, "Tamaño FOV", aimY, 50, 600, Config.ScreenFOV, function(v) Config.ScreenFOV = v end, 0); aimY += 56

local mvY = 0
CreateLabel(MovePage, "─── VELOCIDAD ───", mvY, OP.FireRed); mvY += 24
CreateSlider(MovePage, "WalkSpeed", mvY, 16, 150, Config.WalkSpeed, function(v) Config.WalkSpeed = v; local h = getHumanoid(); if h then h.WalkSpeed = v end end, 0); mvY += 56
CreateSlider(MovePage, "JumpPower", mvY, 50, 200, Config.JumpPower, function(v) Config.JumpPower = v; local h = getHumanoid(); if h then h.JumpPower = v; h.UseJumpPower = true end end, 0); mvY += 56
CreateLabel(MovePage, "─── HABILIDADES ───", mvY, OP.FireRed); mvY += 24
CreateToggle(MovePage, "Fly (Volar)", mvY, function(s) Config.FlyEnabled = s; ToggleFly(s) end, Config.FlyEnabled); mvY += 50
CreateSlider(MovePage, "Velocidad Vuelo", mvY, 20, 200, Config.FlySpeed, function(v) Config.FlySpeed = v end, 0); mvY += 56
CreateToggle(MovePage, "Noclip", mvY, function(s) Config.Noclip = s; ToggleNoclip(s) end, Config.Noclip); mvY += 50

local farmY = 0
CreateLabel(FarmPage, "─── FARMEO ───", farmY, OP.FireRed); farmY += 24
CreateToggle(FarmPage, "Auto Recolectar Monedas", farmY, function(s) Config.AutoFarm = s; ToggleFarm(s) end, Config.AutoFarm); farmY += 50
CreateSlider(FarmPage, "Velocidad Farm", farmY, 20, 100, Config.FarmSpeed, function(v) Config.FarmSpeed = v end, 0); farmY += 56

local miscY = 0
CreateLabel(MiscPage, "─── MISC ───", miscY, OP.FireRed); miscY += 24
CreateToggle(MiscPage, "Esquivar Cuchillos", miscY, function(s) Config.KnifeDodge = s end, Config.KnifeDodge); miscY += 50
CreateToggle(MiscPage, "Anti-Void", miscY, function(s) Config.AntiVoid = s end, Config.AntiVoid); miscY += 50
CreateToggle(MiscPage, "Efectos de Sonido", miscY, function(s) Config.SoundsEnabled = s end, Config.SoundsEnabled); miscY += 50

local wY = 0
CreateLabel(WeatherPage, "─── CLIMA ───", wY, OP.FireRed); wY += 24
CreateButton(WeatherPage, "☀️  Calm Sea", wY, function() ApplyWeather("CalmSea"); ShowToast("Clima: Calm Sea") end, OP.Parchment); wY += 46
CreateButton(WeatherPage, "⚡  Storm", wY, function() ApplyWeather("Storm"); ShowToast("Clima: Storm") end, OP.Parchment); wY += 46
CreateButton(WeatherPage, "🌅  Sunset", wY, function() ApplyWeather("Sunset"); ShowToast("Clima: Sunset") end, OP.Parchment); wY += 46
CreateButton(WeatherPage, "🌙  Night Sea", wY, function() ApplyWeather("NightSea"); ShowToast("Clima: Night Sea") end, OP.Parchment); wY += 46

local cfgY = 0
CreateLabel(ConfigPage, "─── INFO ───", cfgY, OP.FireRed); cfgY += 24
local roleLbl = Instance.new("TextLabel", ConfigPage); roleLbl.Size = UDim2.new(1, 0, 0, 26); roleLbl.Position = UDim2.new(0, 6, 0, cfgY); roleLbl.BackgroundTransparency = 1; roleLbl.Text = "Tu rol: ..."; roleLbl.TextColor3 = OP.Muted; roleLbl.Font = Enum.Font.BuilderSansBold; roleLbl.TextSize = 14; roleLbl.TextXAlignment = Enum.TextXAlignment.Left; cfgY += 30
CreateLabel(ConfigPage, "─── ACCIONES ───", cfgY, OP.FireRed); cfgY += 24
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
MakeDraggable(ToggleBtn, ToggleBtn); MakeDraggable(MainFrame, Header)

_G.OnePieceMenuOpen = false
function ToggleMenu()
    _G.OnePieceMenuOpen = not _G.OnePieceMenuOpen
    if _G.OnePieceMenuOpen then
        MainFrame.Visible = true; menuScale.Scale = 0.7
        TweenService:Create(menuScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
        ToggleBtn.Text = "✕ Cerrar"; PlaySound("open")
        if not currentTab then SwitchTab("ESP") end
    else
        local t = TweenService:Create(menuScale, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.7})
        t:Play(); t.Completed:Connect(function() MainFrame.Visible = false; menuScale.Scale = 1 end)
        ToggleBtn.Text = "🏴‍☠️ ONE PIECE V7"; PlaySound("close")
    end
end

ToggleBtn.Activated:Connect(ToggleMenu)
CloseBtn.Activated:Connect(ToggleMenu)

-- ==========================================================
-- MAIN LOOPS
-- ==========================================================
SwitchTab("ESP"); ApplyWeather("CalmSea")

-- Info loop
task.spawn(function()
    while ScreenGui.Parent do
        local role, color = GetPlayerRole(LocalPlayer)
        roleLbl.Text = "Tu rol: " .. role
        roleLbl.TextColor3 = color
        task.wait(0.5)
    end
end)

-- Update loop
RunService.RenderStepped:Connect(function()
    pcall(UpdateESP)
    pcall(UpdateAimbot)
    
    -- Anti-Void Logic
    if Config.AntiVoid then
        local hrp = getHRP()
        if hrp and hrp.Position.Y < -30 then
            hrp.CFrame = CFrame.new(0, 50, 0)
        end
    end
end)

print("[One Piece Ultimate v7.1] ¡Menú cargado correctamente! 🏴‍☠️")
