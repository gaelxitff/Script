-- ==========================================================
-- 👑 GAEL SCRIPT v1.0 | MM2 | OFFICIAL RELEASE
-- ==========================================================
local RunService   = game:GetService("RunService")
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local CoreGui      = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Workspace    = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

-- ==========================================================
-- CONFIGURACIÓN
-- ==========================================================
local Config = {
    ESPEnabled   = true,
    ShowNames    = false,
    ESPThickness = 2,
    GunESP       = true,
    AimbotEnabled = true,
    Smooth        = 0.22,
    FOV           = 500,
    AutoGrabEnabled = false,
    AutoGrabRange   = 100,
    GhostMode       = false,
    SafeAimbot      = true,
}

local Theme = {
    BG        = Color3.fromRGB(10, 10, 15),
    Glass     = Color3.fromRGB(25, 25, 35),
    Glass2    = Color3.fromRGB(35, 35, 48),
    Border    = Color3.fromRGB(255, 255, 255),
    Accent    = Color3.fromRGB(0, 170, 255),
    Accent2   = Color3.fromRGB(0, 100, 255),
    Text      = Color3.fromRGB(255, 255, 255),
    Muted     = Color3.fromRGB(160, 160, 180),
    ToggleOff = Color3.fromRGB(45, 45, 60),
    Red       = Color3.fromRGB(255, 60, 60),
    Green     = Color3.fromRGB(60, 220, 120),
    Blue      = Color3.fromRGB(60, 120, 255),
}

-- ==========================================================
-- POOL DE LÍNEAS
-- ==========================================================
local LinePool, LineIndex = {}, 0
local NameLabels = {}
local ESPPulse = 0

local function GetLine()
    LineIndex += 1
    if not LinePool[LineIndex] then
        local l = Drawing.new("Line")
        l.Transparency = 1
        l.Visible = false
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
        lbl.Size = 14
        lbl.Center = true
        lbl.Outline = true
        lbl.OutlineColor = Color3.new(0,0,0)
        lbl.Visible = false
        NameLabels[idx] = lbl
    end
    return NameLabels[idx]
end

local function ResetLabels()
    for _, l in ipairs(NameLabels) do l.Visible = false end
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

local function IsMurder(p) return HasTool(p, "Knife") end
local function IsSheriff(p) return HasTool(p, "Gun") end
local function IsLocalSheriff() return IsSheriff(LocalPlayer) end

local function GetPlayerRole(p)
    if IsMurder(p) then return "Murder", Theme.Red end
    if IsSheriff(p) then return "Sheriff", Theme.Blue end
    return "Innocent", Theme.Green
end

-- ==========================================================
-- ESP LÓGICA
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

local function DrawESP()
    ResetLines()
    ResetLabels()
    if not Config.ESPEnabled or not LocalPlayer.Character then return end

    ESPPulse += 0.05
    local pulse = (math.sin(ESPPulse) + 1) / 2

    local idx = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and HasCharacter(p) then
            idx += 1
            local hrp = p.Character.HumanoidRootPart
            local cf = hrp.CFrame * CFrame.new(0, -0.5, 0)
            local corners = GetCorners(cf, Vector3.new(3, 5, 3))
            local role, color = GetPlayerRole(p)
            
            local screen, visible = {}, {}
            for i, v in ipairs(corners) do
                local pos, on = Camera:WorldToViewportPoint(v)
                screen[i] = Vector2.new(pos.X, pos.Y)
                visible[i] = on
            end

            local thickness = Config.GhostMode and 1 or Config.ESPThickness
            local transparency = Config.GhostMode and 0.8 or (0.6 + (pulse * 0.4))

            for _, e in ipairs(BoxEdges) do
                if visible[e[1]] or visible[e[2]] then
                    local l = GetLine()
                    l.From, l.To = screen[e[1]], screen[e[2]]
                    l.Color = color
                    l.Thickness = thickness
                    l.Transparency = transparency
                    l.Visible = true
                end
            end

            if Config.ShowNames then
                local head = p.Character:FindFirstChild("Head") or hrp
                local pos, on = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
                if on then
                    local dist = math.floor((hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                    local txt = string.format("%s [%s] %dm", p.Name, role, dist)
                    local lbl = GetLabel(idx)
                    lbl.Text = txt
                    lbl.Position = Vector2.new(pos.X, pos.Y)
                    lbl.Color = color
                    lbl.Visible = true
                end
            end
        end
    end
end

-- ==========================================================
-- GUN ESP
-- ==========================================================
task.spawn(function()
    while task.wait(0.5) do
        if Config.GunESP then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Tool") and (obj.Name:lower():find("gun") or obj.Name:lower():find("knife") or obj.Name:lower():find("revolver")) then
                    if not obj:FindFirstChild("GunESP_Highlight") then
                        local h = Instance.new("Highlight")
                        h.Name = "GunESP_Highlight"
                        h.Adornee = obj
                        h.FillColor = Theme.Green
                        h.FillTransparency = 0.2
                        h.OutlineColor = Color3.new(1,1,1)
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Parent = obj
                    end
                end
            end
        else
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Tool") then
                    local h = obj:FindFirstChild("GunESP_Highlight")
                    if h then h:Destroy() end
                end
            end
        end
    end
end)

-- ==========================================================
-- AIMBOT
-- ==========================================================
local function UpdateAimbot()
    if not Config.AimbotEnabled or not IsLocalSheriff() then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myPos = myChar.HumanoidRootPart.Position
    
    local best, bestDist = nil, Config.FOV

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and HasCharacter(p) and IsMurder(p) then
            local hrp = p.Character.HumanoidRootPart
            local dist = (hrp.Position - myPos).Magnitude
            if dist < bestDist then
                best, bestDist = p.Character:FindFirstChild("Head") or hrp, dist
            end
        end
    end

    if best then
        local camPos = Camera.CFrame.Position
        local desired = CFrame.new(camPos, best.Position)
        local smoothness = Config.SafeAimbot and 0.1 or Config.Smooth
        Camera.CFrame = Camera.CFrame:Lerp(desired, smoothness)
    end
end

-- ==========================================================
-- AUTO-GRAB
-- ==========================================================
local function UpdateAutoGrab()
    if not Config.AutoGrabEnabled then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myRoot = myChar.HumanoidRootPart

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and (obj.Name:lower():find("gun") or obj.Name:lower():find("knife")) then
            local handle = obj:FindFirstChild("Handle")
            if handle and (handle.Position - myRoot.Position).Magnitude <= Config.AutoGrabRange then
                pcall(function() handle.CFrame = myRoot.CFrame end)
            end
        end
    end
end

-- ==========================================================
-- UI - V1.0 OFFICIAL
-- ==========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GaelScriptV1"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Botón Flotante
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 140, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0, 80)
ToggleBtn.BackgroundColor3 = Theme.Glass
ToggleBtn.BackgroundTransparency = 0.2
ToggleBtn.Text = "👑 Gael"
ToggleBtn.TextColor3 = Theme.Accent
ToggleBtn.Font = Enum.Font.BuilderSansBold
ToggleBtn.TextSize = 16
ToggleBtn.ZIndex = 200
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local TStroke = Instance.new("UIStroke", ToggleBtn)
TStroke.Color = Theme.Accent
TStroke.Thickness = 2
TStroke.Transparency = 0.5

-- Ventana Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 520)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -260)
MainFrame.BackgroundColor3 = Theme.BG
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ZIndex = 50
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Theme.Border
MainStroke.Thickness = 1
MainStroke.Transparency = 0.8

-- Fondo de Partículas (Estrellas Animadas)
local ParticleBg = Instance.new("ImageLabel", MainFrame)
ParticleBg.Size = UDim2.new(1, 0, 1, 0)
ParticleBg.BackgroundTransparency = 1
ParticleBg.Image = "rbxassetid://243660364"
ParticleBg.ImageTransparency = 0.8
ParticleBg.ImageColor3 = Theme.Accent
ParticleBg.ScaleType = Enum.ScaleType.Tile
ParticleBg.TileSize = UDim2.new(0, 150, 0, 150)
ParticleBg.ZIndex = 0
Instance.new("UICorner", ParticleBg).CornerRadius = UDim.new(0, 16)

task.spawn(function()
    while MainFrame.Parent do
        ParticleBg.Position = UDim2.new(0, 0, 0, 0)
        TweenService:Create(ParticleBg, TweenInfo.new(15, Enum.EasingStyle.Linear), {Position = UDim2.new(0, 0, -1, 0)}):Play()
        task.wait(15)
    end
end)

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Theme.Glass2
Header.BackgroundTransparency = 0.5
Header.BorderSizePixel = 0
Header.ZIndex = 51
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)
local HeaderGrad = Instance.new("UIGradient", Header)
HeaderGrad.Color = ColorSequence.new(Theme.Accent, Theme.Accent2)
HeaderGrad.Rotation = 90

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "👑 Gael Script v1.0"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.BuilderSansBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 52

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 36, 0, 36)
CloseBtn.Position = UDim2.new(1, -46, 0.5, -18)
CloseBtn.BackgroundColor3 = Theme.Red
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.ZIndex = 52
CloseBtn.AutoButtonColor = false
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- Barra de Pestañas
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, -40, 0, 40)
TabBar.Position = UDim2.new(0, 20, 0, 75)
TabBar.BackgroundColor3 = Theme.Glass
TabBar.BackgroundTransparency = 0.5
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 51
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(1, 0)

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 4)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

-- Área de Contenido
local ContentArea = Instance.new("ScrollingFrame", MainFrame)
ContentArea.Size = UDim2.new(1, -40, 1, -180)
ContentArea.Position = UDim2.new(0, 20, 0, 125)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 3
ContentArea.ScrollBarImageColor3 = Theme.Accent
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 600)
ContentArea.ZIndex = 51

local UIList = Instance.new("UIListLayout", ContentArea)
UIList.Padding = UDim.new(0, 10)

-- ==========================================================
-- COMPONENTES UI
-- ==========================================================
local function CreateToggle(text, callback, default)
    local state = default
    local btn = Instance.new("TextButton", ContentArea)
    btn.Size = UDim2.new(1, 0, 0, 50)
    btn.BackgroundColor3 = Theme.Glass
    btn.BackgroundTransparency = 0.2
    btn.Text = ""
    btn.ZIndex = 100
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 15, 0, 0)
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.BuilderSansBold
    lbl.TextSize = 15
    lbl.ZIndex = 101

    local swBg = Instance.new("Frame", btn)
    swBg.Size = UDim2.new(0, 46, 0, 24)
    swBg.Position = UDim2.new(1, -60, 0.5, -12)
    swBg.BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff
    swBg.ZIndex = 101
    Instance.new("UICorner", swBg).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame", swBg)
    thumb.Size = UDim2.new(0, 20, 0, 20)
    thumb.Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    thumb.BackgroundColor3 = state and Color3.new(1,1,1) or Theme.Muted
    thumb.ZIndex = 102
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            state = not state
            TweenService:Create(swBg, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff}):Play()
            TweenService:Create(thumb, TweenInfo.new(0.2), {
                Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
                BackgroundColor3 = state and Color3.new(1,1,1) or Theme.Muted
            }):Play()
            if callback then callback(state) end
        end
    end)
end

local function CreateSlider(text, minVal, maxVal, defaultVal, callback, decimals)
    decimals = decimals or 2
    local frame = Instance.new("Frame", ContentArea)
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = Theme.Glass
    frame.BackgroundTransparency = 0.2
    frame.ZIndex = 100
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -20, 0, 22)
    lbl.Position = UDim2.new(0, 15, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.format("%s: %." .. decimals .. "f", text, defaultVal)
    lbl.TextColor3 = Theme.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.BuilderSansBold
    lbl.TextSize = 14
    lbl.ZIndex = 101

    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1, -30, 0, 10)
    bar.Position = UDim2.new(0, 15, 0, 35)
    bar.BackgroundColor3 = Theme.ToggleOff
    bar.ZIndex = 101
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", bar)
    local percent = (defaultVal - minVal) / (maxVal - minVal)
    fill.Size = UDim2.new(percent, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.ZIndex = 102
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local drag = false
    local function setVal(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = minVal + (maxVal - minVal) * rel
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = string.format("%s: %." .. decimals .. "f", text, val)
        if callback then callback(val) end
    end

    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; setVal(i.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            setVal(i.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

local function CreateButton(text, callback, color)
    local btn = Instance.new("TextButton", ContentArea)
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = color or Theme.Glass
    btn.BackgroundTransparency = 0.2
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.BuilderSansBold
    btn.TextSize = 14
    btn.ZIndex = 100
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if callback then callback() end
        end
    end)
end

local function CreateLabel(text, color)
    local lbl = Instance.new("TextLabel", ContentArea)
    lbl.Size = UDim2.new(1, 0, 0, 30)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Theme.Muted
    lbl.Font = Enum.Font.BuilderSansBold
    lbl.TextSize = 14
    lbl.ZIndex = 100
    return lbl
end

-- ==========================================================
-- PESTAÑAS
-- ==========================================================
local Tabs = {}
local currentTab = nil

local function SwitchTab(name)
    for _, child in ipairs(ContentArea:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end
    
    for tabName, data in pairs(Tabs) do
        local isActive = (tabName == name)
        TweenService:Create(data.Button, TweenInfo.new(0.2), {
            BackgroundColor3 = isActive and Theme.Accent or Theme.Glass,
            BackgroundTransparency = isActive and 0 or 0.5
        }):Play()
    end

    if name == "ESP" then
        CreateToggle("ESP (Cajas 3D)", function(s) Config.ESPEnabled = s end, Config.ESPEnabled)
        CreateToggle("Gun ESP (Brillo Armas)", function(s) Config.GunESP = s end, Config.GunESP)
        CreateSlider("Grosor Líneas", 1, 5, Config.ESPThickness, function(v) Config.ESPThickness = math.floor(v) end, 0)
    
    elseif name == "Aimbot" then
        CreateToggle("Aimbot Lock", function(s) Config.AimbotEnabled = s end, Config.AimbotEnabled)
        CreateSlider("Smooth (Suavidad)", 0.05, 0.5, Config.Smooth, function(v) Config.Smooth = v end)
        CreateSlider("FOV (Distancia)", 100, 1000, Config.FOV, function(v) Config.FOV = v end, 0)

    elseif name == "Config" then
        local roleLbl = CreateLabel("Tu rol: ...", Theme.Muted)
        task.spawn(function()
            while ScreenGui.Parent do
                local role, color = GetPlayerRole(LocalPlayer)
                roleLbl.Text = "Tu rol: " .. role
                roleLbl.TextColor3 = color
                task.wait(0.5)
            end
        end)

        CreateToggle("Auto-Grab (Recoger Armas)", function(s) Config.AutoGrabEnabled = s end, Config.AutoGrabEnabled)
        CreateSlider("Rango Auto-Grab", 10, 200, Config.AutoGrabRange, function(v) Config.AutoGrabRange = v end, 0)
        CreateButton("🧹 Limpiar ESP", function()
            ResetLines()
            ResetLabels()
        end, Theme.Glass2)
        CreateButton("❌ Cerrar Menú", function()
            MainFrame.Visible = false
            ToggleBtn.Visible = true
        end, Theme.Red)

    elseif name == "Seguridad" then
        CreateLabel("─── ANTI-BAN ───", Theme.Accent)
        CreateLabel("El Modo Fantasma hace el ESP más sutil.", Theme.Muted)
        CreateToggle("Modo Fantasma (ESP Sutil)", function(s) Config.GhostMode = s end, Config.GhostMode)
        CreateToggle("Aimbot Seguro (Más Lento)", function(s) Config.SafeAimbot = s end, Config.SafeAimbot)
        CreateLabel("Ningún script es 100% indetectable.", Theme.Red)
    end
end

local function CreateTab(name, icon)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0, 75, 0, 32)
    btn.BackgroundColor3 = Theme.Glass
    btn.BackgroundTransparency = 0.5
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.BuilderSansBold
    btn.TextSize = 12
    btn.ZIndex = 52
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            SwitchTab(name)
            currentTab = name
        end
    end)
    Tabs[name] = {Button = btn}
end

CreateTab("ESP", "👁️")
CreateTab("Aimbot", "🎯")
CreateTab("Config", "⚙️")
CreateTab("Seguridad", "🛡️")

-- ==========================================================
-- DRAG & TOGGLE
-- ==========================================================
local function MakeDraggable(frame, handle)
    local drag, start, pos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; start = i.Position; pos = frame.Position
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - start
            frame.Position = UDim2.new(pos.X.Scale, pos.X.Offset + delta.X, pos.Y.Scale, pos.Y.Offset + delta.Y)
        end
    end)
end
MakeDraggable(ToggleBtn, ToggleBtn)
MakeDraggable(MainFrame, Header)

local function ToggleMenu()
    MainFrame.Visible = not MainFrame.Visible
    ToggleBtn.Visible = not MainFrame.Visible
    if MainFrame.Visible and not currentTab then
        SwitchTab("ESP")
        currentTab = "ESP"
    end
end

ToggleBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        ToggleMenu()
    end
end)

CloseBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        MainFrame.Visible = false
        ToggleBtn.Visible = true
    end
end)

-- ==========================================================
-- LOOP PRINCIPAL
-- ==========================================================
RunService.RenderStepped:Connect(function()
    pcall(DrawESP)
    pcall(UpdateAimbot)
    pcall(UpdateAutoGrab)
end)

-- Limpieza
ScreenGui.Destroying:Connect(function()
    for _, l in ipairs(LinePool) do pcall(function() l:Remove() end) end
    for _, l in ipairs(NameLabels) do pcall(function() l:Remove() end) end
end)
