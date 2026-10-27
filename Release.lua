-- ==========================================================
-- 👑 GAEL SCRIPT v5.5 | MM2 | GUN ESP + AUTO-GRAB
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
-- CONFIG
-- ==========================================================
local Config = {
    -- ESP
    ESPEnabled   = true,
    ShowNames    = false,
    ShowDistance = false,
    ESPThickness = 2,
    GunESP       = true, -- Cham para las armas
    -- Aimbot
    AimbotEnabled = true,
    Smooth        = 0.22,
    FOV           = 500,
    -- Auto Grab
    AutoGrabEnabled = false,
    AutoGrabRange   = 100, -- Distancia de recogida
    -- General
    ESPColorMode  = "Role",
}

local Theme = {
    BG        = Color3.fromRGB(15, 15, 20),
    Panel     = Color3.fromRGB(28, 28, 36),
    Panel2    = Color3.fromRGB(38, 38, 48),
    Accent    = Color3.fromRGB(0, 170, 255),
    Text      = Color3.fromRGB(255, 255, 255),
    Muted     = Color3.fromRGB(140, 140, 160),
    ToggleOff = Color3.fromRGB(45, 45, 55),
    Red       = Color3.fromRGB(255, 60, 60),
    Green     = Color3.fromRGB(60, 220, 120),
    Blue      = Color3.fromRGB(60, 120, 255),
}

local HasDrawing = pcall(function() return Drawing.new("Line") end)

-- ==========================================================
-- POOL DE LÍNEAS Y LABELS
-- ==========================================================
local LinePool, LineIndex = {}, 0
local NameLabels = {}

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
        lbl.Size = 16
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

local function IsMurder(p)      return HasTool(p, "Knife") end
local function IsSheriff(p)     return HasTool(p, "Gun")   end
local function IsLocalSheriff() return IsSheriff(LocalPlayer) end

local function GetPlayerColor(p)
    if Config.ESPColorMode == "Static" then return Theme.Accent end
    if IsMurder(p)  then return Theme.Red end
    if IsSheriff(p) then return Theme.Blue end
    return Theme.Green
end

local function GetPlayerRole(p)
    if IsMurder(p)  then return "Murder",   Theme.Red end
    if IsSheriff(p) then return "Sheriff",  Theme.Blue end
    return "Innocent", Theme.Green
end

local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Exclude

local function CanSee(targetPart)
    local char = LocalPlayer.Character
    if not char then return false end
    local head = char:FindFirstChild("Head")
    if not head then return false end
    RayParams.FilterDescendantsInstances = { char, Camera }
    local origin = head.Position
    local dir    = targetPart.Position - origin
    local result = Workspace:Raycast(origin, dir, RayParams)
    return result == nil or result.Instance:IsDescendantOf(targetPart.Parent)
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
            l.Color = color
            l.Visible = true
        end
    end

    if Config.ShowNames then
        local head = char:FindFirstChild("Head") or hrp
        local pos, on = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
        if on then
            local role = GetPlayerRole(player)
            local txt  = player.Name
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
            lbl.Text     = txt
            lbl.Position = Vector2.new(pos.X, pos.Y)
            lbl.Color    = color
            lbl.Visible  = true
        end
    end
end

local function UpdateESP()
    if not HasDrawing then return end
    ResetLines()
    ResetLabels()
    if not Config.ESPEnabled then return end
    if not LocalPlayer.Character then return end

    local idx = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and HasCharacter(p) then
            idx += 1
            pcall(DrawFor, p, idx)
        end
    end
end

-- ==========================================================
-- GUN ESP (CHAM DE ARMAS)
-- ==========================================================
local function UpdateGunESP()
    if not Config.GunESP then
        -- Limpiar los highlights de las armas si se desactiva
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Tool") then
                local h = obj:FindFirstChild("GunESP_Highlight")
                if h then h:Destroy() end
            end
        end
        return
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and (obj.Name:lower():find("gun") or obj.Name:lower():find("knife") or obj.Name:lower():find("revolver")) then
            if not obj:FindFirstChild("GunESP_Highlight") then
                local h = Instance.new("Highlight")
                h.Name = "GunESP_Highlight"
                h.Adornee = obj
                h.FillColor = Color3.fromRGB(0, 255, 0) -- Verde Neón
                h.FillTransparency = 0.3
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = obj
            end
        end
    end
end

-- ==========================================================
-- AIMBOT LÓGICA
-- ==========================================================
local function GetClosestMurder()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position
    local best, bestDist = nil, Config.FOV

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and HasCharacter(p) and IsMurder(p) then
            local hrp = p.Character.HumanoidRootPart
            local dist = (hrp.Position - myPos).Magnitude
            if dist < bestDist then
                local head = p.Character:FindFirstChild("Head") or hrp
                if CanSee(head) then
                    best, bestDist = head, dist
                end
            end
        end
    end
    return best
end

local function UpdateAimbot()
    if not Config.AimbotEnabled then return end
    if not IsLocalSheriff() then return end
    local target = GetClosestMurder()
    if not target then return end

    local camPos  = Camera.CFrame.Position
    local desired = CFrame.new(camPos, target.Position)
    Camera.CFrame = Camera.CFrame:Lerp(desired, Config.Smooth)
end

-- ==========================================================
-- AUTO-GRAB A DISTANCIA
-- ==========================================================
local function UpdateAutoGrab()
    if not Config.AutoGrabEnabled then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and (obj.Name:lower():find("gun") or obj.Name:lower():find("knife") or obj.Name:lower():find("revolver")) then
            local handle = obj:FindFirstChild("Handle")
            if handle then
                local dist = (handle.Position - myRoot.Position).Magnitude
                if dist <= Config.AutoGrabRange then
                    -- Teletransportar el arma al jugador (Magnetismo)
                    pcall(function()
                        handle.CFrame = myRoot.CFrame
                    end)
                end
            end
        end
    end
end

-- ==========================================================
-- UI — SCREEN GUI
-- ==========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GaelScript"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
local okGui = pcall(function() ScreenGui.Parent = CoreGui end)
if not okGui then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- BOTÓN FLOTANTE
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 130, 0, 48)
ToggleBtn.Position = UDim2.new(0, 15, 0, 60)
ToggleBtn.BackgroundColor3 = Theme.BG
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
TStroke.Thickness = 2.5

-- VENTANA PRINCIPAL
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 420)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -210)
MainFrame.BackgroundColor3 = Theme.BG
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ZIndex = 50
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 2

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 46)
Header.BackgroundTransparency = 1
Header.ZIndex = 51

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "👑 Gael Script v5.5"
Title.TextColor3 = Theme.Accent
Title.Font = Enum.Font.BuilderSansBold
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 52

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 36, 0, 36)
CloseBtn.Position = UDim2.new(1, -44, 0.5, -18)
CloseBtn.BackgroundColor3 = Theme.Red
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.ZIndex = 52
CloseBtn.AutoButtonColor = false
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- ==========================================================
-- SISTEMA DE PESTAÑAS
-- ==========================================================
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, -20, 0, 36)
TabBar.Position = UDim2.new(0, 10, 0, 52)
TabBar.BackgroundColor3 = Theme.Panel
TabBar.ZIndex = 51
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 4)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -20, 1, -140)
ContentArea.Position = UDim2.new(0, 10, 0, 96)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 51
ContentArea.ClipsDescendants = true

local Sections = {}

local function CreateSection(name)
    local frame = Instance.new("Frame", ContentArea)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.ZIndex = 52
    Sections[name] = frame
    return frame
end

local ESPPage    = CreateSection("ESP")
local AimbotPage = CreateSection("Aimbot")
local ConfigPage = CreateSection("Config")

local TabButtons = {}
local currentTab = nil

local function SwitchTab(name)
    for tabName, page in pairs(Sections) do
        page.Visible = (tabName == name)
    end
    for tabName, btn in pairs(TabButtons) do
        local isActive = (tabName == name)
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = isActive and Theme.Accent or Theme.Panel2,
        }):Play()
        btn.TextColor3 = isActive and Theme.Text or Theme.Muted
    end
    currentTab = name
end

local function CreateTabButton(name)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0, 88, 0, 28)
    btn.BackgroundColor3 = Theme.Panel2
    btn.Text = name
    btn.TextColor3 = Theme.Muted
    btn.Font = Enum.Font.BuilderSansBold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.ZIndex = 52
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    TabButtons[name] = btn
    return btn
end

CreateTabButton("ESP")
CreateTabButton("Aimbot")
CreateTabButton("Config")

-- ==========================================================
-- BUILDERS
-- ==========================================================
local function CreateToggle(parent, text, yPos, callback, default)
    local state = default ~= false
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = Theme.Panel
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 100
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.BuilderSansBold
    label.TextSize = 14
    label.ZIndex = 101

    local switchBg = Instance.new("Frame", btn)
    switchBg.Size = UDim2.new(0, 44, 0, 22)
    switchBg.Position = UDim2.new(1, -54, 0.5, -11)
    switchBg.BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff
    switchBg.ZIndex = 101
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame", switchBg)
    thumb.Size = UDim2.new(0, 18, 0, 18)
    thumb.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    thumb.BackgroundColor3 = state and Color3.new(1,1,1) or Theme.Muted
    thumb.ZIndex = 102
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(switchBg, TweenInfo.new(0.2),
            {BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff}):Play()
        TweenService:Create(thumb, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
            BackgroundColor3 = state and Color3.new(1,1,1) or Theme.Muted
        }):Play()
        if callback then callback(state) end
    end)
end

local function CreateSlider(parent, text, yPos, minVal, maxVal, defaultVal, callback, decimals)
    decimals = decimals or 2
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 46)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundColor3 = Theme.Panel
    frame.ZIndex = 100
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -20, 0, 18)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = string.format("%s: %." .. decimals .. "f", text, defaultVal)
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.BuilderSansBold
    label.TextSize = 13
    label.ZIndex = 101

    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1, -20, 0, 10)
    bar.Position = UDim2.new(0, 10, 0, 28)
    bar.BackgroundColor3 = Theme.ToggleOff
    bar.ZIndex = 101
    bar.Active = true
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", bar)
    local percent = (defaultVal - minVal) / (maxVal - minVal)
    fill.Size = UDim2.new(percent, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.ZIndex = 102
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", bar)
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(percent, -10, 0.5, -10)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.ZIndex = 103
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function setVal(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = minVal + (maxVal - minVal) * rel
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -10, 0.5, -10)
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
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = color or Theme.Panel
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.BuilderSansBold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.ZIndex = 100
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

local function CreateLabel(parent, text, yPos, color)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.Position = UDim2.new(0, 4, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Theme.Muted
    lbl.Font = Enum.Font.BuilderSansBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 100
    return lbl
end

-- ==========================================================
-- SECCIÓN ESP
-- ==========================================================
local espY = 0
CreateLabel(ESPPage, "─── VISUAL ───", espY, Theme.Accent); espY += 24
CreateToggle(ESPPage, "ESP (Cajas 3D)", espY, function(s) Config.ESPEnabled = s end, Config.ESPEnabled); espY += 48
CreateToggle(ESPPage, "Nombres", espY, function(s) Config.ShowNames = s end, Config.ShowNames); espY += 48
CreateToggle(ESPPage, "Mostrar distancia", espY, function(s) Config.ShowDistance = s end, Config.ShowDistance); espY += 48
CreateToggle(ESPPage, "Gun ESP (Brillo Armas)", espY, function(s) Config.GunESP = s end, Config.GunESP); espY += 48
CreateSlider(ESPPage, "Grosor líneas", espY, 1, 5, Config.ESPThickness, function(v) Config.ESPThickness = math.floor(v) end, 0); espY += 52

local colorBtn = Instance.new("TextButton", ESPPage)
colorBtn.Size = UDim2.new(1, 0, 0, 38)
colorBtn.Position = UDim2.new(0, 0, 0, espY)
colorBtn.BackgroundColor3 = Theme.Panel
colorBtn.Text = "Modo color: " .. Config.ESPColorMode
colorBtn.TextColor3 = Theme.Accent
colorBtn.Font = Enum.Font.BuilderSansBold
colorBtn.TextSize = 13
colorBtn.AutoButtonColor = false
colorBtn.ZIndex = 100
Instance.new("UICorner", colorBtn).CornerRadius = UDim.new(0, 8)
colorBtn.MouseButton1Click:Connect(function()
    Config.ESPColorMode = Config.ESPColorMode == "Role" and "Static" or "Role"
    colorBtn.Text = "Modo color: " .. Config.ESPColorMode
end)

-- ==========================================================
-- SECCIÓN AIMBOT
-- ==========================================================
local aimY = 0
CreateLabel(AimbotPage, "─── APUNTADO ───", aimY, Theme.Accent); aimY += 24
CreateToggle(AimbotPage, "Aimbot Lock", aimY, function(s) Config.AimbotEnabled = s end, Config.AimbotEnabled); aimY += 48
CreateSlider(AimbotPage, "Smooth (suavidad)", aimY, 0.05, 0.5, Config.Smooth, function(v) Config.Smooth = v end); aimY += 52
CreateSlider(AimbotPage, "FOV (distancia)", aimY, 100, 1000, Config.FOV, function(v) Config.FOV = v end, 0); aimY += 52

local aimInfo = CreateLabel(AimbotPage,
    "Solo funciona si eres Sheriff.\nApuntas al Murder más cercano\ncon línea de visión.",
    aimY, Theme.Muted)
aimInfo.Size = UDim2.new(1, 0, 0, 50)
aimInfo.TextSize = 11

-- ==========================================================
-- SECCIÓN CONFIG (AUTO-GRAB)
-- ==========================================================
local cfgY = 0
CreateLabel(ConfigPage, "─── ITEMS ───", cfgY, Theme.Accent); cfgY += 24

CreateToggle(ConfigPage, "Auto-Grab (Recoger Armas)", cfgY, function(s) Config.AutoGrabEnabled = s end, Config.AutoGrabEnabled); cfgY += 48
CreateSlider(ConfigPage, "Rango de Recogida", cfgY, 10, 200, Config.AutoGrabRange, function(v) Config.AutoGrabRange = v end, 0); cfgY += 52

local roleLbl = Instance.new("TextLabel", ConfigPage)
roleLbl.Size = UDim2.new(1, 0, 0, 28)
roleLbl.Position = UDim2.new(0, 4, 0, cfgY)
roleLbl.BackgroundTransparency = 1
roleLbl.Text = "Tu rol: ..."
roleLbl.TextColor3 = Theme.Muted
roleLbl.Font = Enum.Font.BuilderSansBold
roleLbl.TextSize = 14
roleLbl.TextXAlignment = Enum.TextXAlignment.Left
roleLbl.ZIndex = 100
cfgY += 32

local statusLbl = Instance.new("TextLabel", ConfigPage)
statusLbl.Size = UDim2.new(1, 0, 0, 24)
statusLbl.Position = UDim2.new(0, 4, 0, cfgY)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "ESP: ✅ | Aimbot: ✅"
statusLbl.TextColor3 = Theme.Green
statusLbl.Font = Enum.Font.BuilderSansBold
statusLbl.TextSize = 12
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.ZIndex = 100
cfgY += 30

CreateLabel(ConfigPage, "─── ACCIONES ───", cfgY, Theme.Accent); cfgY += 24

CreateButton(ConfigPage, "🔄 Reiniciar configuración", cfgY, function()
    Config.ESPEnabled    = true
    Config.ShowNames     = false
    Config.ShowDistance  = false
    Config.ESPThickness  = 2
    Config.AimbotEnabled = true
    Config.Smooth        = 0.22
    Config.FOV           = 500
    Config.ESPColorMode  = "Role"
    Config.GunESP        = true
    Config.AutoGrabEnabled = false
    Config.AutoGrabRange = 100
end, Theme.Panel2); cfgY += 44

CreateButton(ConfigPage, "🧹 Limpiar ESP (reset líneas)", cfgY, function()
    ResetLines(); ResetLabels()
end, Theme.Panel2); cfgY += 44

CreateButton(ConfigPage, "❌ Cerrar menú", cfgY, function()
    MainFrame.Visible = false
    ToggleBtn.Visible = true
end, Theme.Red); cfgY += 44

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
-- ABRIR / CERRAR
-- ==========================================================
local isOpen = false

local function OpenMenu()
    isOpen = true
    MainFrame.Visible = true
    ToggleBtn.Visible = false
    if not currentTab then SwitchTab("ESP") end
end

local function CloseMenu()
    isOpen = false
    MainFrame.Visible = false
    ToggleBtn.Visible = true
end

ToggleBtn.MouseButton1Click:Connect(OpenMenu)
CloseBtn.MouseButton1Click:Connect(CloseMenu)
CloseMenu()

-- ==========================================================
-- LOOPS
-- ==========================================================
task.spawn(function()
    while ScreenGui.Parent do
        local role, color = GetPlayerRole(LocalPlayer)
        roleLbl.Text = "Tu rol: " .. role
        roleLbl.TextColor3 = color

        statusLbl.Text = string.format("ESP: %s | Aimbot: %s",
            Config.ESPEnabled    and "✅" or "❌",
            Config.AimbotEnabled and "✅" or "❌")
        statusLbl.TextColor3 = (Config.ESPEnabled or Config.AimbotEnabled) and Theme.Green or Theme.Muted
        task.wait(0.5)
    end
end)

RunService.RenderStepped:Connect(function()
    pcall(UpdateESP)
    pcall(UpdateAimbot)
    pcall(UpdateGunESP)
    pcall(UpdateAutoGrab)
end)

-- Limpieza
ScreenGui.Destroying:Connect(function()
    for _, l in ipairs(LinePool)   do pcall(function() l:Remove() end) end
    for _, l in ipairs(NameLabels) do pcall(function() l:Remove() end) end
end)

print("[Gael Script v5.5] Cargado ✅")
