-- ==========================================
-- 👑 GAEL SCRIPT | MM2 (FINAL TOUCH FIX)
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
    Sidebar = Color3.fromRGB(18, 18, 24),
    Panel = Color3.fromRGB(25, 25, 32), 
    Accent = Color3.fromRGB(0, 170, 255), 
    Text = Color3.fromRGB(255, 255, 255), 
    Muted = Color3.fromRGB(140, 140, 160), 
    ToggleOff = Color3.fromRGB(35, 35, 45),
    Red = Color3.fromRGB(255, 60, 60)
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GaelScript_Final"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- BOTÓN FLOTANTE
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 150, 0, 40)
ToggleBtn.Position = UDim2.new(0.5, -75, 0, 20)
ToggleBtn.BackgroundColor3 = Theme.BG
ToggleBtn.Text = "Gael Script"
ToggleBtn.TextColor3 = Theme.Accent
ToggleBtn.Font = Enum.Font.BuilderSansBold
ToggleBtn.TextSize = 15
ToggleBtn.ZIndex = 100
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local TStroke = Instance.new("UIStroke", ToggleBtn)
TStroke.Color = Theme.Accent
TStroke.Thickness = 2

-- Mover botón
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

-- VENTANA PRINCIPAL
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 300) 
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -150)
MainFrame.BackgroundColor3 = Theme.BG
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
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
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 12

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
CloseBtn.BackgroundColor3 = Theme.Red
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.ZIndex = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

-- Mover ventana
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

local isOpen = false
local function ToggleMenu()
    isOpen = not isOpen
    MainFrame.Visible = isOpen
    ToggleBtn.Text = isOpen and "Cerrar" or "Gael Script"
end

ToggleBtn.MouseButton1Click:Connect(ToggleMenu)
CloseBtn.MouseButton1Click:Connect(ToggleMenu)

-- VARIABLES
local maxDistance = 500
local ChamsEnabled, BoxesEnabled, TracersEnabled = false, false, false
local AimbotEnabled = false
local AutoGrabEnabled = false
local SkinFXEnabled = false
local SkinFXColor = Color3.fromRGB(0, 170, 255)
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

-- DRAWINGS
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

-- LOOP PRINCIPAL
RunService.RenderStepped:Connect(function()
    local screenCenter = Camera.ViewportSize / 2
    local bestHead = nil
    local shortestDist = 9e9

    -- Skin FX
    if LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
        if tool then
            local handle = tool:FindFirstChild("Handle")
            if handle then
                local highlight = handle:FindFirstChild("SkinFX_Highlight")
                local particle = handle:FindFirstChild("SkinFX_Particle")
                
                if SkinFXEnabled then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "SkinFX_Highlight"
                        highlight.Adornee = handle
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                        highlight.Parent = handle
                    end
                    highlight.FillColor = SkinFXColor
                    highlight.OutlineColor = SkinFXColor
                    highlight.Enabled = true
                    
                    if not particle then
                        particle = Instance.new("ParticleEmitter")
                        particle.Name = "SkinFX_Particle"
                        particle.Texture = "rbxassetid://243660364"
                        particle.Rate = 20
                        particle.Lifetime = NumberRange.new(0.5, 1)
                        particle.Speed = NumberRange.new(1, 2)
                        particle.Size = NumberSequence.new(0.2)
                        particle.Color = ColorSequence.new(SkinFXColor)
                        particle.Parent = handle
                    end
                    particle.Color = ColorSequence.new(SkinFXColor)
                    particle.Enabled = true
                else
                    if highlight then highlight.Enabled = false end
                    if particle then particle.Enabled = false end
                end
            end
        end
    end

    -- Auto Grab
    if AutoGrabEnabled and LocalPlayer.Character then
        local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Tool") and (obj.Name:lower():find("knife") or obj.Name:lower():find("gun") or obj.Name:lower():find("revolver")) then
                    local handle = obj:FindFirstChild("Handle")
                    if handle and (handle.Position - myRoot.Position).Magnitude <= 15 then
                        pcall(function()
                            if firetouchinterest then
                                firetouchinterest(handle, myRoot, 0)
                                firetouchinterest(handle, myRoot, 1)
                            end
                        end)
                    end
                end
            end
        end
    end

    -- ESP y Aimbot
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
-- SISTEMA DE BOTONES (CON FRAME NORMAL)
-- ==========================================
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 85, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.ZIndex = 11
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local ContentHost = Instance.new("Frame", MainFrame)
ContentHost.Size = UDim2.new(1, -95, 1, -50)
ContentHost.Position = UDim2.new(0, 90, 0, 45)
ContentHost.BackgroundTransparency = 1
ContentHost.ZIndex = 11

-- Función para crear Toggle en un Frame normal (sin scroll)
local function CreateToggle(parent, text, yPos, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 34)
    btn.Position = UDim2.new(0, 5, 0, yPos)
    btn.BackgroundColor3 = Theme.Panel
    btn.Text = ""
    btn.ZIndex = 100
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -100, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.BuilderSansMedium
    label.TextSize = 12
    label.ZIndex = 101

    local statusLabel = Instance.new("TextLabel", btn)
    statusLabel.Size = UDim2.new(0, 60, 1, 0)
    statusLabel.Position = UDim2.new(1, -95, 0, 0)
    statusLabel.Text = "OFF"
    statusLabel.TextColor3 = Theme.Muted
    statusLabel.TextXAlignment = Enum.TextXAlignment.Right
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.BuilderSansBold
    statusLabel.TextSize = 10
    statusLabel.ZIndex = 101

    local switchBg = Instance.new("Frame", btn)
    switchBg.Size = UDim2.new(0, 30, 0, 16)
    switchBg.Position = UDim2.new(1, -35, 0.5, -8)
    switchBg.BackgroundColor3 = Theme.ToggleOff
    switchBg.ZIndex = 101
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

    local switchThumb = Instance.new("Frame", switchBg)
    switchThumb.Size = UDim2.new(0, 12, 0, 12)
    switchThumb.Position = UDim.new(0, 2, 0.5, -6)
    switchThumb.BackgroundColor3 = Theme.Muted
    switchThumb.ZIndex = 102
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

-- Función para la Paleta
local function CreateColorPicker(parent, text, defaultColor, yPos, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, yPos)
    btn.BackgroundColor3 = Theme.Panel
    btn.Text = ""
    btn.ZIndex = 100
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.BuilderSansMedium
    label.TextSize = 11
    label.ZIndex = 101
    
    local colorBox = Instance.new("Frame", btn)
    colorBox.Size = UDim2.new(0, 14, 0, 14)
    colorBox.Position = UDim2.new(1, -22, 0.5, -7)
    colorBox.BackgroundColor3 = defaultColor
    colorBox.ZIndex = 101
    Instance.new("UICorner", colorBox).CornerRadius = UDim.new(1, 0)
    
    local paletteFrame = Instance.new("Frame", MainFrame)
    paletteFrame.Size = UDim2.new(0, 180, 0, 100)
    paletteFrame.BackgroundColor3 = Theme.BG
    paletteFrame.BorderSizePixel = 0
    paletteFrame.Visible = false
    paletteFrame.ZIndex = 200
    Instance.new("UICorner", paletteFrame).CornerRadius = UDim.new(0, 6)
    local pStroke = Instance.new("UIStroke", paletteFrame)
    pStroke.Color = Theme.Accent
    
    local grid = Instance.new("UIGridLayout", paletteFrame)
    grid.CellSize = UDim2.new(0, 25, 0, 25)
    grid.CellPadding = UDim2.new(0, 5, 0, 5)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    
    local colors = {
        Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 0, 255), Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 150, 0), Color3.fromRGB(150, 0, 255), Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(0, 0, 0), Color3.fromRGB(150, 150, 150), Color3.fromRGB(100, 50, 0)
    }
    
    for i, color in ipairs(colors) do
        local cBtn = Instance.new("TextButton", paletteFrame)
        cBtn.BackgroundColor3 = color
        cBtn.Text = ""
        cBtn.ZIndex = 201
        Instance.new("UICorner", cBtn).CornerRadius = UDim.new(0, 4)
        cBtn.MouseButton1Click:Connect(function()
            colorBox.BackgroundColor3 = color
            if callback then callback(color) end
            paletteFrame.Visible = false
        end)
    end

    btn.MouseButton1Click:Connect(function()
        if paletteFrame.Visible then
            paletteFrame.Visible = false
        else
            local pos = btn.AbsolutePosition
            paletteFrame.Position = UDim2.new(0, pos.X - 100, 0, pos.Y + 35)
            paletteFrame.Visible = true
        end
    end)
end

-- ==========================================
-- CONSTRUCCIÓN DE LAS PESTAÑAS
-- ==========================================
local Pages = {}
local function SwitchPage(pageName)
    for name, page in pairs(Pages) do
        page.Visible = (name == pageName)
    end
end

local function CreateTab(tabName, buildFunction)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.Position = UDim2.new(0, 5, 0, 5 + (#Sidebar:GetChildren() * 37))
    btn.BackgroundColor3 = Theme.Panel
    btn.Text = tabName
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.BuilderSansBold
    btn.TextSize = 12
    btn.ZIndex = 100
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local page = Instance.new("Frame", ContentHost)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ZIndex = 99
    Pages[tabName] = page
    
    btn.MouseButton1Click:Connect(function()
        SwitchPage(tabName)
    end)
    
    buildFunction(page)
    return btn
end

-- Crear Pestañas
local ESPTab = CreateTab("ESP", function(page)
    CreateToggle(page, "ESP (Todo)", 0, function(s) ChamsEnabled = s; BoxesEnabled = s; TracersEnabled = s end)
    CreateToggle(page, "Boxes (Cajas)", 40, function(s) BoxesEnabled = s end)
    CreateToggle(page, "Chams (Pintar)", 80, function(s) ChamsEnabled = s end)
    CreateToggle(page, "Tracers (Lazos)", 120, function(s) TracersEnabled = s end)
end)

local CombatTab = CreateTab("Combat", function(page)
    CreateToggle(page, "Aimbot Lock (Sheriff)", 0, function(s) AimbotEnabled = s end)
end)

local ItemTab = CreateTab("Items", function(page)
    CreateToggle(page, "Auto Grab (Armas)", 0, function(s) AutoGrabEnabled = s end)
end)

local SkinTab = CreateTab("Skins", function(page)
    CreateToggle(page, "Activar Efecto en Arma", 0, function(s) SkinFXEnabled = s end)
    CreateColorPicker(page, "Color del Efecto", SkinFXColor, 40, function(c) SkinFXColor = c end)
end)

SwitchPage("ESP")
