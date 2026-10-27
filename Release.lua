-- ==========================================
-- 👑 GAEL SCRIPT | MURDER MYSTERY 2 (PREMIUM)
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Theme = { 
    BG = Color3.fromRGB(12, 12, 16), 
    Panel = Color3.fromRGB(22, 22, 28), 
    Accent = Color3.fromRGB(0, 170, 255), -- Azul brillante
    Text = Color3.fromRGB(255, 255, 255), 
    Muted = Color3.fromRGB(140, 140, 160), 
    ToggleOff = Color3.fromRGB(35, 35, 45)
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GaelScript_Premium"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ==========================================
-- BOTÓN FLOTANTE
-- ==========================================
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 160, 0, 45)
ToggleBtn.Position = UDim2.new(0.5, -80, 0, 20)
ToggleBtn.BackgroundColor3 = Theme.BG
ToggleBtn.BackgroundTransparency = 0.1
ToggleBtn.Text = "Gael Script"
ToggleBtn.TextColor3 = Theme.Text
ToggleBtn.Font = Enum.Font.BuilderSansBold
ToggleBtn.TextSize = 16
ToggleBtn.ZIndex = 100
ToggleBtn.Visible = true
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local TStroke = Instance.new("UIStroke", ToggleBtn)
TStroke.Color = Theme.Accent
TStroke.Thickness = 2

-- Arrastrar botón
local dragToggle, startToggle, posToggle
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true; startToggle = input.Position; posToggle = ToggleBtn.Position
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = false end
end)
UIS.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - startToggle
        ToggleBtn.Position = UDim2.new(posToggle.X.Scale, posToggle.X.Offset + delta.X, posToggle.Y.Scale, posToggle.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- VENTANA PRINCIPAL
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 460, 0, 340)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -170)
MainFrame.BackgroundColor3 = Theme.BG
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 1.5

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.ZIndex = 11

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Gael Script"
Title.TextColor3 = Theme.Accent
Title.Font = Enum.Font.BuilderSansBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 12

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.ZIndex = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

-- Arrastrar ventana
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Lógica del botón para abrir/cerrar
local isOpen = false
local function ToggleMenu()
    isOpen = not isOpen
    if isOpen then
        MainFrame.Visible = true
        ToggleBtn.Text = "Cerrar"
    else
        MainFrame.Visible = false
        ToggleBtn.Text = "Gael Script"
    end
end

ToggleBtn.MouseButton1Click:Connect(ToggleMenu)
CloseBtn.MouseButton1Click:Connect(ToggleMenu)

-- ==========================================
-- VARIABLES DEL JUEGO
-- ==========================================
local maxDistance = 500
local ChamsEnabled, BoxesEnabled, TracersEnabled = false, false, false
local AimbotEnabled = false
local activeTarget = nil

local RoleColors = {
    Murder = {Fill = Color3.fromRGB(255, 0, 0), Outline = Color3.fromRGB(0, 0, 0)},
    Sheriff = {Fill = Color3.fromRGB(0, 150, 255), Outline = Color3.fromRGB(255, 255, 255)},
    Innocent = {Fill = Color3.fromRGB(0, 0, 0), Outline = Color3.fromRGB(255, 255, 255)}
}

local function getRole(plr)
    if not plr.Character then return "Innocent" end
    for _, t in pairs(plr.Character:GetChildren()) do
        if t:IsA("Tool") then
            local n = t.Name:lower()
            if n:find("knife") then return "Murder" end
            if n:find("gun") then return "Sheriff" end
        end
    end
    local bp = plr:FindFirstChild("Backpack")
    if bp then
        for _, t in pairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                local n = t.Name:lower()
                if n:find("knife") then return "Murder" end
                if n:find("gun") then return "Sheriff" end
            end
        end
    end
    return "Innocent"
end

-- ==========================================
-- DRAWINGS (CAJAS Y LÍNEAS)
-- ==========================================
local Drawings = {}
local function CreateDrawing(class, props)
    if not Drawing then return nil end
    local obj = Drawing.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function createDrawings(plr)
    Drawings[plr] = {
        Box = CreateDrawing("Square", {Thickness = 2, Color = Color3.new(1,1,1), Filled = false, Visible = false}),
        Tracer = CreateDrawing("Line", {Thickness = 2, Color = Color3.new(1,1,1), Visible = false})
    }
end
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then createDrawings(p) end end
Players.PlayerAdded:Connect(createDrawings)

-- ==========================================
-- LOOP ESP Y AIMBOT
-- ==========================================
RunService.RenderStepped:Connect(function()
    local screenCenter = Camera.ViewportSize / 2
    local bestHead = nil
    local shortestDist = 9e9

    for _, plr in pairs(Players:GetPlayers()) do
        local draw = Drawings[plr]
        local char = plr.Character
        if char and plr ~= LocalPlayer and draw then
            local head = char:FindFirstChild("Head")
            local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local highlight = char:FindFirstChild("Highlight") or Instance.new("Highlight", char)
            
            if head and torso and humanoid and humanoid.Health > 0 then
                local role = getRole(plr)
                local colors = RoleColors[role] or RoleColors["Innocent"]

                -- CHAMS CON BORDES
                highlight.Enabled = ChamsEnabled
                highlight.FillColor = colors.Fill
                highlight.OutlineColor = colors.Outline
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0

                local distFromMe = (head.Position - Camera.CFrame.Position).Magnitude
                local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                local torsoPos, torsoOnScreen = Camera:WorldToViewportPoint(torso.Position)
                local fovDist = (Vector2.new(headPos.X, headPos.Y) - screenCenter).Magnitude

                if onScreen and torsoOnScreen and distFromMe <= maxDistance then
                    -- CAJA PROFESIONAL (Más grande)
                    local height = math.abs(torsoPos.Y - headPos.Y) * 2.5
                    local width = height / 2
                    
                    draw.Box.Visible = BoxesEnabled
                    draw.Box.Size = Vector2.new(width, height)
                    draw.Box.Position = Vector2.new(headPos.X - width/2, headPos.Y - height/4)
                    draw.Box.Color = colors.Fill
                    
                    draw.Tracer.Visible = TracersEnabled
                    draw.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
                    draw.Tracer.To = Vector2.new(torsoPos.X, torsoPos.Y)
                    draw.Tracer.Color = colors.Fill
                else
                    draw.Box.Visible = false
                    draw.Tracer.Visible = false
                end

                -- AIMBOT SOLO SHERIFF
                local myRole = getRole(LocalPlayer)
                if AimbotEnabled and myRole == "Sheriff" and onScreen and distFromMe <= maxDistance then
                    if role == "Murder" and fovDist < shortestDist then
                        shortestDist = fovDist
                        bestHead = head
                    end
                end
            end
        elseif draw then
            local highlight = char and (char:FindFirstChild("Highlight") or Instance.new("Highlight", char))
            if highlight then highlight.Enabled = false end
            draw.Box.Visible = false
            draw.Tracer.Visible = false
        end
    end
    activeTarget = bestHead
end)

RunService.RenderStepped:Connect(function()
    if AimbotEnabled and activeTarget and activeTarget.Parent then
        local currentCFrame = Camera.CFrame
        local targetCFrame = CFrame.new(currentCFrame.Position, activeTarget.Position)
        Camera.CFrame = currentCFrame:Lerp(targetCFrame, 0.3) 
    end
end)

-- ==========================================
-- UI: COMPONENTES
-- ==========================================
local function CreateToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Theme.Panel
    btn.Text = ""
    btn.ZIndex = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -110, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.BuilderSansMedium
    label.TextSize = 12
    label.ZIndex = 13

    local statusLabel = Instance.new("TextLabel", btn)
    statusLabel.Size = UDim2.new(0, 65, 1, 0)
    statusLabel.Position = UDim2.new(1, -100, 0, 0)
    statusLabel.Text = "OFF"
    statusLabel.TextColor3 = Theme.Muted
    statusLabel.TextXAlignment = Enum.TextXAlignment.Right
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.BuilderSansBold
    statusLabel.TextSize = 10
    statusLabel.ZIndex = 13

    local switchBg = Instance.new("Frame", btn)
    switchBg.Size = UDim2.new(0, 32, 0, 16)
    switchBg.Position = UDim2.new(1, -35, 0.5, -8)
    switchBg.BackgroundColor3 = Theme.ToggleOff
    switchBg.ZIndex = 13
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

    local switchThumb = Instance.new("Frame", switchBg)
    switchThumb.Size = UDim2.new(0, 12, 0, 12)
    switchThumb.Position = UDim.new(0, 2, 0.5, -6)
    switchThumb.BackgroundColor3 = Theme.Muted
    switchThumb.ZIndex = 14
    Instance.new("UICorner", switchThumb).CornerRadius = UDim.new(1, 0)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            statusLabel.Text = "ACTIVADO"
            statusLabel.TextColor3 = Theme.Accent
            TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
            TweenService:Create(switchThumb, TweenInfo.new(0.2), {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.new(1,1,1)}):Play()
        else
            statusLabel.Text = "OFF"
            statusLabel.TextColor3 = Theme.Muted
            TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ToggleOff}):Play()
            TweenService:Create(switchThumb, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Theme.Muted}):Play()
        end
        if callback then callback(state) end
    end)
    return btn
end

-- ==========================================
-- CONSTRUCCIÓN DEL MENÚ
-- ==========================================
local function BuildMenu()
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 50, 1, -45)
    Sidebar.Position = UDim2.new(0, 10, 0, 45)
    Sidebar.BackgroundTransparency = 1
    Sidebar.ZIndex = 11

    local ContentHost = Instance.new("Frame", MainFrame)
    ContentHost.Size = UDim2.new(1, -70, 1, -45)
    ContentHost.Position = UDim2.new(0, 60, 0, 45)
    ContentHost.BackgroundTransparency = 1
    ContentHost.ZIndex = 11

    local Pages = {}
    local function CreatePage(name)
        local page = Instance.new("ScrollingFrame", ContentHost)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 3
        page.CanvasSize = UDim2.new(0, 0, 0, 500)
        page.Visible = false
        page.ZIndex = 12
        Pages[name] = page
        return page
    end

    local function SwitchPage(pageName)
        for name, page in pairs(Pages) do page.Visible = (name == pageName) end
    end

    local function CreateTabBtn(iconId, pageName)
        local btn = Instance.new("ImageButton", Sidebar)
        btn.Size = UDim2.new(0, 32, 0, 32)
        btn.Position = UDim2.new(0, 9, 0, 9 + (#Sidebar:GetChildren() * 40))
        btn.BackgroundColor3 = Theme.Panel
        btn.BackgroundTransparency = 0.5
        btn.Image = iconId
        btn.ImageColor3 = Theme.Accent
        btn.ZIndex = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(function() SwitchPage(pageName) end)
        return CreatePage(pageName)
    end

    -- SECCIÓN ESP
    local ESPPage = CreateTabBtn("rbxassetid://13571270194", "ESP")
    local yPos = 0
    local function AddToggle(text, cb)
        local t = CreateToggle(ESPPage, text, cb)
        t.Position = UDim2.new(0, 0, 0, yPos)
        yPos = yPos + 40
    end

    AddToggle("ESP (Activar Todo)", function(s) 
        ChamsEnabled = s; BoxesEnabled = s; TracersEnabled = s 
    end)
    AddToggle("Boxes (Cajas Pro)", function(s) BoxesEnabled = s end)
    AddToggle("Chams (Pintar con Bordes)", function(s) ChamsEnabled = s end)
    AddToggle("Tracers (Lazos)", function(s) TracersEnabled = s end)

    -- SECCIÓN COMBAT
    local CombatPage = CreateTabBtn("rbxassetid://80964454894155", "Combat")
    yPos = 0
    local function AddCombatToggle(text, cb)
        local t = CreateToggle(CombatPage, text, cb)
        t.Position = UDim2.new(0, 0, 0, yPos)
        yPos = yPos + 40
    end

    AddCombatToggle("Aimbot Lock (Solo Sheriff)", function(s) AimbotEnabled = s end)

    -- Texto Informativo
    local infoLabel = Instance.new("TextLabel", CombatPage)
    infoLabel.Size = UDim2.new(1, 0, 0, 50)
    infoLabel.Position = UDim2.new(0, 0, 0, yPos)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "El Aimbot solo se activará si eres el Sheriff y apuntará automáticamente al Murder."
    infoLabel.TextColor3 = Theme.Muted
    infoLabel.Font = Enum.Font.BuilderSansMedium
    infoLabel.TextSize = 10
    infoLabel.TextWrapped = true
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.ZIndex = 13

    SwitchPage("ESP")
end

-- ==========================================
-- INICIO
-- ==========================================
ToggleBtn.Visible = true
MainFrame.Visible = false
BuildMenu()
