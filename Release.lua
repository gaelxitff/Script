-- ==========================================
-- 👑 URIEL DEV | MM2 (DRAKE MODZ STYLE)
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- IDIOMAS
local Language = "ES"
local Texts = {
    ES = {
        Title = "URIEL DEV | MM2",
        Tabs = {ESP = "Visual / ESP", Combat = "Combat", Player = "Player", Settings = "Ajustes", Credits = "Créditos"},
        ESP = {RoleESP = "Role ESP (Resaltar)", GunESP = "Cham de Armas", Boxes = "Cajas", Tracers = "Líneas", Names = "Nombres", Health = "Barra de Vida", OnlyMurder = "Solo ver Murder"},
        Combat = {Aimbot = "Aimbot al Murder", KillAll = "Kill All", AutoGrab = "Auto Recoger", MaxDist = "Distancia Máx"},
        Player = {Speed = "Velocidad", Noclip = "Noclip", Fly = "Volar", Jump = "Salto Infinito"},
        Settings = {Colors = "Colores de Rol", Fill = "Relleno", Outline = "Contorno"},
        Credits = {Title = "Creado por URIEL DEV", Btn = "Copiar Discord de URIEL DEV"}
    },
    EN = {
        Title = "URIEL DEV | MM2",
        Tabs = {ESP = "Visual / ESP", Combat = "Combat", Player = "Player", Settings = "Settings", Credits = "Credits"},
        ESP = {RoleESP = "Role ESP", GunESP = "Gun ESP", Boxes = "Boxes", Tracers = "Tracers", Names = "Names", Health = "Health Bar", OnlyMurder = "Only Murder"},
        Combat = {Aimbot = "Aimbot Murder", KillAll = "Kill All", AutoGrab = "Auto Grab", MaxDist = "Max Dist"},
        Player = {Speed = "Speed", Noclip = "Noclip", Fly = "Fly", Jump = "Infinite Jump"},
        Settings = {Colors = "Role Colors", Fill = "Fill", Outline = "Outline"},
        Credits = {Title = "Created by URIEL DEV", Btn = "Copy URIEL DEV Discord"}
    }
}

local Theme = { 
    BG = Color3.fromRGB(20, 20, 25), 
    Sidebar = Color3.fromRGB(15, 15, 18), 
    Panel = Color3.fromRGB(30, 30, 38), 
    Border = Color3.fromRGB(55, 55, 70), 
    Accent = Color3.fromRGB(0, 170, 255), 
    Text = Color3.fromRGB(255, 255, 255), 
    Muted = Color3.fromRGB(140, 140, 160), 
    Red = Color3.fromRGB(255, 60, 60),
    ToggleOff = Color3.fromRGB(45, 45, 55)
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "URIEL_DEV_MM2" -- Nombre del script en el CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- BOTÓN FLOTANTE
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 150, 0, 40)
ToggleBtn.Position = UDim2.new(0.5, -75, 0, 20)
ToggleBtn.BackgroundColor3 = Theme.BG
ToggleBtn.Text = "URIEL DEV" -- Texto del botón flotante
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

-- VENTANA PRINCIPAL (ESTILO DRAKE)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 280)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -140)
MainFrame.BackgroundColor3 = Theme.BG
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Theme.Border
MainStroke.Thickness = 1.5

-- HEADER
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Theme.Sidebar
Header.BorderSizePixel = 0
Header.ZIndex = 11
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = Texts[Language].Title -- Título del menú
Title.TextColor3 = Theme.Accent
Title.Font = Enum.Font.BuilderSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 12

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
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

-- ==========================================
-- VARIABLES DEL JUEGO (MM2)
-- ==========================================
local ESP_Color = Color3.fromRGB(255, 255, 255)
local maxDistance = 500
local BoxesEnabled, NamesEnabled, HealthEnabled, TracersEnabled, RoleESPEnabled, GunESPEnabled, OnlyMurder = false, false, false, false, false, false, false
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

-- ==========================================
-- DRAWINGS (CAJAS, LÍNEAS, NOMBRES)
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
        Box = CreateDrawing("Square", {Thickness = 1.5, Color = Theme.Accent, Filled = false, Visible = false}),
        Tracer = CreateDrawing("Line", {Thickness = 1.5, Color = Theme.Accent, Visible = false}),
        Name = CreateDrawing("Text", {Size = 13, Center = true, Outline = true, Visible = false}),
        HealthBg = CreateDrawing("Square", {Filled = true, Color = Color3.new(0,0,0), Visible = false}),
        Health = CreateDrawing("Square", {Filled = true, Color = Color3.fromRGB(0, 255, 0), Visible = false})
    }
end
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then createDrawings(p) end end
Players.PlayerAdded:Connect(createDrawings)

local activeTargetPos = nil 

-- ==========================================
-- LOOP PRINCIPAL (ESP Y AIMBOT)
-- ==========================================
RunService.RenderStepped:Connect(function()
    local screenCenter = Camera.ViewportSize / 2
    local bestHead = nil
    local shortestDist = 9e9

    -- GUN ESP
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

                local fillColor = ESP_Color
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

                highlight.Enabled = (RoleESPEnabled) and shouldDraw
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
    activeTargetPos = bestHead and bestHead.Position or nil
end)

RunService.RenderStepped:Connect(function()
    if AimbotEnabled and activeTargetPos then
        local currentCFrame = Camera.CFrame
        local targetCFrame = CFrame.new(currentCFrame.Position, activeTargetPos)
        Camera.CFrame = currentCFrame:Lerp(targetCFrame, 0.2)
    end
end)

-- KILL ALL / AUTO GRAB / MOVIMIENTO
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
-- DISEÑO DE LA UI (DRAKE STYLE)
-- ==========================================
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 40, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 11

local ContentHost = Instance.new("Frame", MainFrame)
ContentHost.Size = UDim2.new(1, -40, 1, -35)
ContentHost.Position = UDim2.new(0, 40, 0, 35)
ContentHost.BackgroundTransparency = 1
ContentHost.ZIndex = 11

-- CONTENEDOR DE DOS COLUMNAS
local LeftCol = Instance.new("ScrollingFrame", ContentHost)
LeftCol.Size = UDim2.new(0.5, -5, 1, 0)
LeftCol.Position = UDim2.new(0, 5, 0, 5)
LeftCol.BackgroundTransparency = 1
LeftCol.ScrollBarThickness = 2
LeftCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
LeftCol.ZIndex = 12
Instance.new("UIListLayout", LeftCol).Padding = UDim.new(0, 5)

local RightCol = Instance.new("Frame", ContentHost)
RightCol.Size = UDim2.new(0.5, -5, 1, -10)
RightCol.Position = UDim2.new(0.5, 0, 0, 5)
RightCol.BackgroundColor3 = Theme.Panel
RightCol.ZIndex = 12
Instance.new("UICorner", RightCol).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", RightCol).Color = Theme.Border

local PreviewTitle = Instance.new("TextLabel", RightCol)
PreviewTitle.Size = UDim2.new(1, 0, 0, 25)
PreviewTitle.Position = UDim2.new(0, 0, 0, 5)
PreviewTitle.BackgroundTransparency = 1
PreviewTitle.Text = "VISTA PREVIA"
PreviewTitle.TextColor3 = Theme.Accent
PreviewTitle.Font = Enum.Font.BuilderSansBold
PreviewTitle.TextSize = 11
PreviewTitle.ZIndex = 13

local PreviewInfo = Instance.new("TextLabel", RightCol)
PreviewInfo.Size = UDim2.new(1, -10, 1, -35)
PreviewInfo.Position = UDim2.new(0, 5, 0, 30)
PreviewInfo.BackgroundTransparency = 1
PreviewInfo.Text = "Esperando objetivo..."
PreviewInfo.TextColor3 = Theme.Text
PreviewInfo.Font = Enum.Font.BuilderSansMedium
PreviewInfo.TextSize = 12
PreviewInfo.TextWrapped = true
PreviewInfo.TextYAlignment = Enum.TextYAlignment.Top
PreviewInfo.ZIndex = 13

-- COMPONENTES DE LA UI
local function CreateToggle(parent, text, default, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Theme.Panel
    btn.Text = ""
    btn.ZIndex = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -45, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.BuilderSansMedium
    label.TextSize = 11
    label.ZIndex = 13
    
    local switchBg = Instance.new("Frame", btn)
    switchBg.Size = UDim2.new(0, 28, 0, 14)
    switchBg.Position = UDim2.new(1, -36, 0.5, -7)
    switchBg.BackgroundColor3 = Theme.ToggleOff
    switchBg.ZIndex = 13
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
    
    local switchThumb = Instance.new("Frame", switchBg)
    switchThumb.Size = UDim2.new(0, 10, 0, 10)
    switchThumb.Position = UDim.new(0, 2, 0.5, -5)
    switchThumb.BackgroundColor3 = Theme.Muted
    switchThumb.ZIndex = 14
    Instance.new("UICorner", switchThumb).CornerRadius = UDim.new(1, 0)
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff}):Play()
        TweenService:Create(switchThumb, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5),
            BackgroundColor3 = state and Theme.Text or Theme.Muted
        }):Play()
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
    
    btn.MouseButton1Click:Connect(function()
        local newColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        colorBox.BackgroundColor3 = newColor
        if callback then callback(newColor) end
    end)
end

-- CREACIÓN DE LAS PESTAÑAS
local Pages = {}
local Tabs = {}

local function CreateTab(iconId, tabName)
    local btn = Instance.new("ImageButton", Sidebar)
    btn.Size = UDim2.new(0, 30, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, 5 + (#Sidebar:GetChildren() * 35))
    btn.BackgroundColor3 = Theme.BG
    btn.BackgroundTransparency = 0.5
    btn.Image = iconId
    btn.ImageColor3 = Theme.Muted
    btn.ZIndex = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local page = Instance.new("ScrollingFrame", LeftCol)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 13
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 5)
    
    Pages[tabName] = page
    Tabs[tabName] = btn
    
    btn.MouseButton1Click:Connect(function()
        for name, p in pairs(Pages) do p.Visible = (name == tabName) end
        for name, b in pairs(Tabs) do
            TweenService:Create(b, TweenInfo.new(0.2), {ImageColor3 = name == tabName and Theme.Accent or Theme.Muted}):Play()
        end
    end)
    return page
end

-- LLENAR LAS PESTAÑAS CON TUS OPCIONES
local ESPPage = CreateTab("rbxassetid://13571270194", "ESP")
CreateToggle(ESPPage, Texts[Language].ESP.RoleESP, false, function(s) RoleESPEnabled = s end)
CreateToggle(ESPPage, Texts[Language].ESP.GunESP, false, function(s) GunESPEnabled = s end)
CreateToggle(ESPPage, Texts[Language].ESP.OnlyMurder, false, function(s) OnlyMurder = s end)
CreateToggle(ESPPage, Texts[Language].ESP.Boxes, false, function(s) BoxesEnabled = s end)
CreateToggle(ESPPage, Texts[Language].ESP.Tracers, false, function(s) TracersEnabled = s end)
CreateToggle(ESPPage, Texts[Language].ESP.Names, false, function(s) NamesEnabled = s end)
CreateToggle(ESPPage, Texts[Language].ESP.Health, false, function(s) HealthEnabled = s end)

local CombatPage = CreateTab("rbxassetid://80964454894155", "Combat")
CreateToggle(CombatPage, Texts[Language].Combat.Aimbot, false, function(s) AimbotEnabled = s end)
CreateToggle(CombatPage, Texts[Language].Combat.KillAll, false, function(s) KillAllEnabled = s end)
CreateToggle(CombatPage, Texts[Language].Combat.AutoGrab, false, function(s) AutoGrabEnabled = s end)
CreateSlider(CombatPage, Texts[Language].Combat.MaxDist, 100, 2000, 500, function(v) maxDistance = v end)

local PlayerPage = CreateTab("rbxassetid://13492318225", "Player")
CreateToggle(PlayerPage, Texts[Language].Player.Speed, false, function(s) SpeedHack = s end)
CreateToggle(PlayerPage, Texts[Language].Player.Noclip, false, function(s) Noclip = s end)
CreateToggle(PlayerPage, Texts[Language].Player.Fly, false, function(s) 
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
CreateToggle(PlayerPage, Texts[Language].Player.Jump, false, function(s) InfJump = s end)

local SettingsPage = CreateTab("rbxassetid://13492318225", "Settings")
CreateColorPicker(SettingsPage, "Murder " .. Texts[Language].Settings.Fill, RoleColors.Murder.Fill, function(c) RoleColors.Murder.Fill = c end)
CreateColorPicker(SettingsPage, "Murder " .. Texts[Language].Settings.Outline, RoleColors.Murder.Outline, function(c) RoleColors.Murder.Outline = c end)
CreateColorPicker(SettingsPage, "Sheriff " .. Texts[Language].Settings.Fill, RoleColors.Sheriff.Fill, function(c) RoleColors.Sheriff.Fill = c end)
CreateColorPicker(SettingsPage, "Sheriff " .. Texts[Language].Settings.Outline, RoleColors.Sheriff.Outline, function(c) RoleColors.Sheriff.Outline = c end)
CreateColorPicker(SettingsPage, "Innocent " .. Texts[Language].Settings.Fill, RoleColors.Innocent.Fill, function(c) RoleColors.Innocent.Fill = c end)
CreateColorPicker(SettingsPage, "Innocent " .. Texts[Language].Settings.Outline, RoleColors.Innocent.Outline, function(c) RoleColors.Innocent.Outline = c end)

-- INICIAR EN ESP
Pages["ESP"].Visible = true
Tabs["ESP"].ImageColor3 = Theme.Accent

-- SELECTOR DE IDIOMA
local LangGui = Instance.new("ScreenGui", CoreGui)
local LangFrame = Instance.new("Frame", LangGui)
LangFrame.Size = UDim2.new(0, 220, 0, 130)
LangFrame.Position = UDim2.new(0.5, -110, 0.5, -65)
LangFrame.BackgroundColor3 = Theme.BG
Instance.new("UICorner", LangFrame).CornerRadius = UDim.new(0, 8)
local LStroke = Instance.new("UIStroke", LangFrame)
LStroke.Color = Theme.Border

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
Instance.new("UICorner", BtnES).CornerRadius = UDim.new(0, 4)

local BtnEN = Instance.new("TextButton", LangFrame)
BtnEN.Size = UDim2.new(0.4, 0, 0, 30)
BtnEN.Position = UDim2.new(0.55, 0, 0, 50)
BtnEN.BackgroundColor3 = Theme.Panel
BtnEN.Text = "English"
BtnEN.TextColor3 = Theme.Text
BtnEN.Font = Enum.Font.BuilderSansBold
BtnEN.TextSize = 11
Instance.new("UICorner", BtnEN).CornerRadius = UDim.new(0, 4)

BtnES.MouseButton1Click:Connect(function()
    Language = "ES"; LangGui:Destroy(); ToggleBtn.Visible = true
end)
BtnEN.MouseButton1Click:Connect(function()
    Language = "EN"; LangGui:Destroy(); ToggleBtn.Visible = true
end)
