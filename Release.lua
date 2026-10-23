-- ==========================================
-- 👑 URIEL DEV | MURDER MYSTERY 2 (PALETTE EDITION)
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Language = "ES"
local Texts = {
    ES = {
        Title = "URIEL DEV | MM2",
        ESP = {RoleESP = "Role ESP", GunESP = "Cham de Armas", OnlyMurder = "Solo Murder", Boxes = "Cajas (Box)", Tracers = "Líneas", Names = "Nombres", Health = "Barra de Vida", Rainbow = "Arcoíris"},
        Combat = {Aimbot = "Aimbot al Murder", KillAll = "Kill All", AutoGrab = "Auto Recoger", MaxDist = "Distancia Máx"},
        Player = {Speed = "Speed Hack", Noclip = "Noclip", Fly = "Volar", Jump = "Salto Infinito"},
        Settings = {RoleColors = "Colores de Rol", Fill = "Relleno", Outline = "Contorno"},
        Credits = {Title = "Creado por Uriel Dev", Btn = "Copiar Discord"}
    },
    EN = {
        Title = "URIEL DEV | MM2",
        ESP = {RoleESP = "Role ESP", GunESP = "Gun ESP", OnlyMurder = "Only Murder", Boxes = "Boxes", Tracers = "Tracers", Names = "Names", Health = "Health Bar", Rainbow = "Rainbow"},
        Combat = {Aimbot = "Aimbot Murder", KillAll = "Kill All", AutoGrab = "Auto Grab", MaxDist = "Max Dist"},
        Player = {Speed = "Speed Hack", Noclip = "Noclip", Fly = "Fly", Jump = "Infinite Jump"},
        Settings = {RoleColors = "Role Colors", Fill = "Fill", Outline = "Outline"},
        Credits = {Title = "Created by Uriel Dev", Btn = "Copy Discord"}
    }
}

local Theme = { 
    BG = Color3.fromRGB(15, 15, 20), 
    Panel = Color3.fromRGB(22, 22, 30), 
    Border = Color3.fromRGB(45, 45, 60), 
    Accent = Color3.fromRGB(0, 170, 255), 
    Text = Color3.fromRGB(255, 255, 255), 
    Muted = Color3.fromRGB(140, 140, 160), 
    Red = Color3.fromRGB(255, 60, 60),
    ToggleOff = Color3.fromRGB(35, 35, 45)
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "URIEL_DEV_PALETTE"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- BOTÓN FLOTANTE
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 160, 0, 42)
ToggleBtn.Position = UDim2.new(0.5, -80, 0, 20)
ToggleBtn.BackgroundColor3 = Theme.BG
ToggleBtn.Text = "URIEL DEV"
ToggleBtn.TextColor3 = Theme.Accent
ToggleBtn.Font = Enum.Font.BuilderSansBold
ToggleBtn.TextSize = 14
ToggleBtn.ZIndex = 100
ToggleBtn.Visible = false
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local TStroke = Instance.new("UIStroke", ToggleBtn)
TStroke.Color = Theme.Accent
TStroke.Thickness = 2

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
MainFrame.Size = UDim2.new(0, 460, 0, 340)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -170)
MainFrame.BackgroundColor3 = Theme.BG
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Theme.Border
MainStroke.Thickness = 1.5

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Theme.Panel
Header.BorderSizePixel = 0
Header.ZIndex = 11
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = Texts[Language].Title
Title.TextColor3 = Theme.Accent
Title.Font = Enum.Font.BuilderSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 12

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
CloseBtn.BackgroundColor3 = Theme.Panel
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.ZIndex = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false ToggleBtn.Visible = true end)

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

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true ToggleBtn.Visible = false end)

-- VARIABLES DEL JUEGO
local maxDistance = 500
local BoxesEnabled, NamesEnabled, HealthEnabled, TracersEnabled, RoleESPEnabled, GunESPEnabled, OnlyMurder, ESP_Rainbow = false, false, false, false, false, false, false, false
local AimbotEnabled, KillAllEnabled, AutoGrabEnabled = false, false, false
local SpeedHack, FlyHack, Noclip, InfJump = false, false, false, false

local RoleColors = {
    Murder = {Fill = Color3.fromRGB(255, 0, 0), Outline = Color3.fromRGB(0, 0, 0)},
    Sheriff = {Fill = Color3.fromRGB(0, 150, 255), Outline = Color3.fromRGB(255, 255, 255)},
    Innocent = {Fill = Color3.fromRGB(255, 255, 255), Outline = Color3.fromRGB(0, 0, 0)}
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
        Box = CreateDrawing("Square", {Thickness = 1.5, Color = Theme.Accent, Filled = false, Visible = false}),
        Tracer = CreateDrawing("Line", {Thickness = 1.5, Color = Theme.Accent, Visible = false}),
        Name = CreateDrawing("Text", {Size = 13, Center = true, Outline = true, Visible = false}),
        HealthBg = CreateDrawing("Square", {Filled = true, Color = Color3.new(0,0,0), Visible = false}),
        Health = CreateDrawing("Square", {Filled = true, Color = Color3.fromRGB(0, 255, 0), Visible = false})
    }
end
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then createDrawings(p) end end
Players.PlayerAdded:Connect(createDrawings)

local activeTarget = nil

-- LOOP ESP Y AIMBOT
RunService.RenderStepped:Connect(function()
    local rainbowColor = Color3.fromHSV((tick() % 5) / 5, 1, 1)
    local screenCenter = Camera.ViewportSize / 2
    local bestHead = nil
    local shortestDist = 9e9

    if GunESPEnabled then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") and (obj.Name:lower():find("gun") or obj.Name:lower():find("knife")) then
                if not obj:FindFirstChild("GunHighlight") then
                    local h = Instance.new("Highlight")
                    h.Name = "GunHighlight"
                    h.Adornee = obj
                    h.FillColor = Color3.fromRGB(0, 255, 0)
                    h.FillTransparency = 0.2
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Parent = obj
                end
            end
        end
    else
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") then
                local h = obj:FindFirstChild("GunHighlight")
                if h then h:Destroy() end
            end
        end
    end

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
                local shouldDraw = true
                if OnlyMurder and role ~= "Murder" then shouldDraw = false end

                local fillColor = ESP_Rainbow and rainbowColor or Color3.fromRGB(255,255,255)
                local outlineColor = Theme.BG

                if RoleESPEnabled then
                    if role == "Murder" then fillColor = RoleColors.Murder.Fill; outlineColor = RoleColors.Murder.Outline
                    elseif role == "Sheriff" then fillColor = RoleColors.Sheriff.Fill; outlineColor = RoleColors.Sheriff.Outline
                    else fillColor = RoleColors.Innocent.Fill; outlineColor = RoleColors.Innocent.Outline end
                end

                local distFromMe = (head.Position - Camera.CFrame.Position).Magnitude
                local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                local torsoPos, torsoOnScreen = Camera:WorldToViewportPoint(torso.Position)
                local fovDist = (Vector2.new(headPos.X, headPos.Y) - screenCenter).Magnitude

                if shouldDraw and onScreen and torsoOnScreen and distFromMe <= maxDistance then
                    local height = math.abs(torsoPos.Y - headPos.Y) * 1.5
                    local width = height / 2

                    draw.Box.Visible = BoxesEnabled
                    draw.Box.Size = Vector2.new(width, height)
                    draw.Box.Position = Vector2.new(headPos.X - width/2, headPos.Y - height/4)
                    draw.Box.Color = fillColor

                    draw.Name.Visible = NamesEnabled
                    draw.Name.Text = plr.Name .. " [" .. role .. "]"
                    draw.Name.Position = Vector2.new(headPos.X, headPos.Y - height/2 - 12)
                    draw.Name.Color = fillColor

                    draw.Tracer.Visible = TracersEnabled
                    draw.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
                    draw.Tracer.To = Vector2.new(torsoPos.X, torsoPos.Y)
                    draw.Tracer.Color = fillColor

                    draw.Health.Visible = HealthEnabled
                    draw.HealthBg.Visible = HealthEnabled
                    if HealthEnabled then
                        local hpPct = humanoid.Health / humanoid.MaxHealth
                        draw.Health.Size = Vector2.new(2, height * hpPct)
                        draw.Health.Position = Vector2.new(headPos.X - width/2 - 4, headPos.Y + height/2 - (height * hpPct))
                        draw.HealthBg.Size = Vector2.new(2, height)
                        draw.HealthBg.Position = Vector2.new(headPos.X - width/2 - 4, headPos.Y - height/4)
                    end
                else
                    draw.Box.Visible = false; draw.Name.Visible = false
                    draw.Tracer.Visible = false; draw.Health.Visible = false; draw.HealthBg.Visible = false
                end

                highlight.Enabled = (RoleESPEnabled or ESP_Rainbow) and shouldDraw
                highlight.FillColor = fillColor
                highlight.OutlineColor = outlineColor
                highlight.FillTransparency = 0.5

                if AimbotEnabled and role == "Murder" and onScreen and distFromMe <= maxDistance then
                    if fovDist < shortestDist then
                        shortestDist = fovDist
                        bestHead = head
                    end
                end
            end
        elseif draw then
            draw.Box.Visible = false; draw.Name.Visible = false
            draw.Tracer.Visible = false; draw.Health.Visible = false; draw.HealthBg.Visible = false
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

task.spawn(function()
    while task.wait(0.1) do
        if LocalPlayer.Character then
            if AutoGrabEnabled then
                local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("Tool") and (obj.Name:lower():find("knife") or obj.Name:lower():find("gun")) then
                            local handle = obj:FindFirstChild("Handle")
                            if handle and (handle.Position - myRoot.Position).Magnitude <= 15 then
                                pcall(function() if firetouchinterest then firetouchinterest(handle, myRoot, 0) firetouchinterest(handle, myRoot, 1) end end)
                            end
                        end
                    end
                end
            end
            if KillAllEnabled then
                local knife = LocalPlayer.Character:FindFirstChild("Knife")
                if knife then
                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character and getRole(plr) ~= "Murder" then
                            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                            local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp and myRoot and (hrp.Position - myRoot.Position).Magnitude <= 20 then
                                pcall(function() knife:Activate() end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if InfJump then
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and SpeedHack then hum.WalkSpeed = 50 end
        if Noclip then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end
end)

-- ==========================================
-- FUNCIONES DE LA UI
-- ==========================================
local function CreateToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Theme.Panel
    btn.Text = ""
    btn.ZIndex = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -110, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.BuilderSansMedium
    label.TextSize = 11
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
    switchBg.Size = UDim2.new(0, 28, 0, 14)
    switchBg.Position = UDim2.new(1, -30, 0.5, -7)
    switchBg.BackgroundColor3 = Theme.ToggleOff
    switchBg.ZIndex = 13
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

    local switchThumb = Instance.new("Frame", switchBg)
    switchThumb.Size = UDim2.new(0, 10, 0, 10)
    switchThumb.Position = UDim.new(0, 2, 0.5, -5)
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
            TweenService:Create(switchThumb, TweenInfo.new(0.2), {Position = UDim2.new(1, -12, 0.5, -5), BackgroundColor3 = Color3.new(1,1,1)}):Play()
        else
            statusLabel.Text = "OFF"
            statusLabel.TextColor3 = Theme.Muted
            TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ToggleOff}):Play()
            TweenService:Create(switchThumb, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -5), BackgroundColor3 = Theme.Muted}):Play()
        end
        if callback then callback(state) end
    end)
    return btn
end

local function CreateSlider(parent, text, min, max, default, callback)
    local wrap = Instance.new("Frame", parent)
    wrap.Size = UDim2.new(1, 0, 0, 35)
    wrap.BackgroundTransparency = 1
    wrap.ZIndex = 12
    local label = Instance.new("TextLabel", wrap)
    label.Size = UDim2.new(1, 0, 0, 15)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.BuilderSansMedium
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    local bar = Instance.new("TextButton", wrap)
    bar.Size = UDim2.new(1, 0, 0, 6)
    bar.Position = UDim2.new(0, 0, 0, 22)
    bar.BackgroundColor3 = Theme.ToggleOff
    bar.Text = ""
    bar.ZIndex = 13
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.ZIndex = 14
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local sliding = false
    local function updateValue(x)
        local pct = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        local val = math.floor(min + (max - min) * pct)
        label.Text = text .. ": " .. tostring(val)
        if callback then callback(val) end
    end
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true; updateValue(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input.Position.X)
        end
    end)
end

-- NUEVO SISTEMA DE COLORES CON PALETA
local function CreateColorPicker(parent, text, defaultColor, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Theme.Panel
    btn.Text = ""
    btn.ZIndex = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.BuilderSansMedium
    label.TextSize = 11
    label.ZIndex = 13
    
    local colorBox = Instance.new("Frame", btn)
    colorBox.Size = UDim2.new(0, 14, 0, 14)
    colorBox.Position = UDim2.new(1, -22, 0.5, -7)
    colorBox.BackgroundColor3 = defaultColor
    colorBox.ZIndex = 13
    Instance.new("UICorner", colorBox).CornerRadius = UDim.new(1, 0)
    
    -- El panel de la paleta (oculto por defecto)
    local paletteFrame = Instance.new("Frame", MainFrame)
    paletteFrame.Size = UDim2.new(0, 180, 0, 100)
    paletteFrame.BackgroundColor3 = Theme.BG
    paletteFrame.BorderSizePixel = 0
    paletteFrame.Visible = false
    paletteFrame.ZIndex = 50
    Instance.new("UICorner", paletteFrame).CornerRadius = UDim.new(0, 6)
    local pStroke = Instance.new("UIStroke", paletteFrame)
    pStroke.Color = Theme.Border
    
    local grid = Instance.new("UIGridLayout", paletteFrame)
    grid.CellSize = UDim2.new(0, 25, 0, 25)
    grid.CellPadding = UDim2.new(0, 5, 0, 5)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- 12 Colores de la paleta
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
        cBtn.ZIndex = 51
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
            -- Posicionar la paleta justo al lado del botón
            local pos = btn.AbsolutePosition
            paletteFrame.Position = UDim2.new(0, pos.X - 100, 0, pos.Y + 35)
            paletteFrame.Visible = true
        end
    end)
end

-- CONSTRUCCIÓN DEL MENÚ (UNA COLUMNA)
local function BuildMenu()
    local Scroll = Instance.new("ScrollingFrame", MainFrame)
    Scroll.Size = UDim2.new(1, -20, 1, -50)
    Scroll.Position = UDim2.new(0, 10, 0, 45)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 3
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 800)
    Scroll.ZIndex = 11

    local currentY = 0
    local function AddToggle(text, cb)
        local t = CreateToggle(Scroll, text, cb)
        t.Position = UDim2.new(0, 0, 0, currentY)
        currentY = currentY + 38
    end
    
    local function AddSlider(text, min, max, def, cb)
        local s = CreateSlider(Scroll, text, min, max, def, cb)
        s.Position = UDim2.new(0, 0, 0, currentY)
        currentY = currentY + 45
    end

    local function AddColor(text, col, cb)
        local c = CreateColorPicker(Scroll, text, col, cb)
        c.Position = UDim2.new(0, 0, 0, currentY)
        currentY = currentY + 35
    end

    -- ESP
    AddToggle(Texts[Language].ESP.RoleESP, function(s) RoleESPEnabled = s end)
    AddToggle(Texts[Language].ESP.GunESP, function(s) GunESPEnabled = s end)
    AddToggle(Texts[Language].ESP.OnlyMurder, function(s) OnlyMurder = s end)
    AddToggle(Texts[Language].ESP.Boxes, function(s) BoxesEnabled = s end)
    AddToggle(Texts[Language].ESP.Tracers, function(s) TracersEnabled = s end)
    AddToggle(Texts[Language].ESP.Names, function(s) NamesEnabled = s end)
    AddToggle(Texts[Language].ESP.Health, function(s) HealthEnabled = s end)
    AddToggle(Texts[Language].ESP.Rainbow, function(s) ESP_Rainbow = s end)

    -- COMBAT
    AddToggle(Texts[Language].Combat.Aimbot, function(s) AimbotEnabled = s end)
    AddToggle(Texts[Language].Combat.KillAll, function(s) KillAllEnabled = s end)
    AddToggle(Texts[Language].Combat.AutoGrab, function(s) AutoGrabEnabled = s end)
    AddSlider(Texts[Language].Combat.MaxDist, 100, 2000, 500, function(v) maxDistance = v end)

    -- PLAYER
    AddToggle(Texts[Language].Player.Speed, function(s) SpeedHack = s end)
    AddToggle(Texts[Language].Player.Noclip, function(s) Noclip = s end)
    AddToggle(Texts[Language].Player.Fly, function(s) 
        FlyHack = s
        if s then
            task.spawn(function()
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bv = Instance.new("BodyVelocity", hrp)
                    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                    while FlyHack do
                        local move = Vector3.zero
                        if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
                        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
                        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
                        bv.Velocity = move * 60
                        task.wait()
                    end
                    bv:Destroy()
                end
            end)
        end
    end)
    AddToggle(Texts[Language].Player.Jump, function(s) InfJump = s end)

    -- SETTINGS (COLORES)
    AddColor("Murder Fill", RoleColors.Murder.Fill, function(c) RoleColors.Murder.Fill = c end)
    AddColor("Murder Outline", RoleColors.Murder.Outline, function(c) RoleColors.Murder.Outline = c end)
    AddColor("Sheriff Fill", RoleColors.Sheriff.Fill, function(c) RoleColors.Sheriff.Fill = c end)
    AddColor("Sheriff Outline", RoleColors.Sheriff.Outline, function(c) RoleColors.Sheriff.Outline = c end)
    AddColor("Innocent Fill", RoleColors.Innocent.Fill, function(c) RoleColors.Innocent.Fill = c end)
    AddColor("Innocent Outline", RoleColors.Innocent.Outline, function(c) RoleColors.Innocent.Outline = c end)
    
    Scroll.CanvasSize = UDim2.new(0, 0, 0, currentY + 10)
end

-- SELECTOR DE IDIOMA INICIAL
local LangGui = Instance.new("ScreenGui", CoreGui)
local LangFrame = Instance.new("Frame", LangGui)
LangFrame.Size = UDim2.new(0, 220, 0, 130)
LangFrame.Position = UDim2.new(0.5, -110, 0.5, -65)
LangFrame.BackgroundColor3 = Theme.BG
Instance.new("UICorner", LangFrame).CornerRadius = UDim.new(0, 10)
local LStroke = Instance.new("UIStroke", LangFrame)
LStroke.Color = Theme.Accent

local LTitle = Instance.new("TextLabel", LangFrame)
LTitle.Size = UDim2.new(1, 0, 0, 30)
LTitle.BackgroundTransparency = 1
LTitle.Text = "Select / Selecciona Idioma"
LTitle.TextColor3 = Theme.Text
LTitle.Font = Enum.Font.BuilderSansBold
LTitle.TextSize = 11
LTitle.Parent = LangFrame

local BtnES = Instance.new("TextButton", LangFrame)
BtnES.Size = UDim2.new(0.4, 0, 0, 30)
BtnES.Position = UDim2.new(0.05, 0, 0, 50)
BtnES.BackgroundColor3 = Theme.Panel
BtnES.Text = "Español"
BtnES.TextColor3 = Theme.Text
BtnES.Font = Enum.Font.BuilderSansBold
BtnES.TextSize = 11
Instance.new("UICorner", BtnES).CornerRadius = UDim.new(0, 6)

local BtnEN = Instance.new("TextButton", LangFrame)
BtnEN.Size = UDim2.new(0.4, 0, 0, 30)
BtnEN.Position = UDim2.new(0.55, 0, 0, 50)
BtnEN.BackgroundColor3 = Theme.Panel
BtnEN.Text = "English"
BtnEN.TextColor3 = Theme.Text
BtnEN.Font = Enum.Font.BuilderSansBold
BtnEN.TextSize = 11
Instance.new("UICorner", BtnEN).CornerRadius = UDim.new(0, 6)

BtnES.MouseButton1Click:Connect(function()
    Language = "ES"
    LangGui:Destroy()
    ToggleBtn.Visible = true
    MainFrame.Visible = true
    BuildMenu()
end)

BtnEN.MouseButton1Click:Connect(function()
    Language = "EN"
    LangGui:Destroy()
    ToggleBtn.Visible = true
    MainFrame.Visible = true
    BuildMenu()
end)
