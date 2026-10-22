-- ==========================================
-- 👑 URIEL DEV | MURDER MYSTERY 2 (ULTIMATE)
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- SISTEMA DE IDIOMAS
local Language = "ES"
local Texts = {
    ES = {
        Title = "URIEL DEV | MM2",
        ESP = {RoleESP = "Role ESP (Colores)", GunESP = "Cham de Armas", OnlyMurder = "Solo ver Murder", OnlySheriff = "Solo ver Sheriff", Boxes = "Cajas (Box)", Tracers = "Líneas", Names = "Nombres", Health = "Barra de Vida", Rainbow = "Modo Arcoíris"},
        Combat = {Aimbot = "Aimbot al Murder", KillAll = "Kill All", AutoGrab = "Auto Recoger Arma", MaxDist = "Distancia"},
        Player = {Speed = "Speed Hack", Noclip = "Noclip", Fly = "Volar", Jump = "Salto Infinito"},
        World = {Fullbright = "Fullbright", RemoveTex = "Quitar Texturas"},
        Settings = {ParticleColor = "Color de Estrellas", ParticleTrans = "Transparencia Estrellas", RoleColors = "Colores por Rol", Fill = "Relleno", Outline = "Contorno"},
        Credits = {Title = "Creado por Uriel Dev", Desc = "Gracias por usar este Hub.", Btn = "Copiar Discord"}
    },
    EN = {
        Title = "URIEL DEV | MM2",
        ESP = {RoleESP = "Role ESP (Colors)", GunESP = "Gun ESP", OnlyMurder = "Only Murder", OnlySheriff = "Only Sheriff", Boxes = "Boxes", Tracers = "Tracers", Names = "Names", Health = "Health Bar", Rainbow = "Rainbow Mode"},
        Combat = {Aimbot = "Aimbot Murder", KillAll = "Kill All", AutoGrab = "Auto Grab Weapon", MaxDist = "Distance"},
        Player = {Speed = "Speed Hack", Noclip = "Noclip", Fly = "Fly", Jump = "Infinite Jump"},
        World = {Fullbright = "Fullbright", RemoveTex = "Remove Textures"},
        Settings = {ParticleColor = "Star Color", ParticleTrans = "Star Transparency", RoleColors = "Role Colors", Fill = "Fill", Outline = "Outline"},
        Credits = {Title = "Created by Uriel Dev", Desc = "Thanks for using this Hub.", Btn = "Copy Discord"}
    }
}

local Theme = { BG = Color3.fromRGB(15, 15, 20), Card = Color3.fromRGB(25, 25, 32), Border = Color3.fromRGB(50, 50, 65), Accent = Color3.fromRGB(0, 150, 255), Text = Color3.fromRGB(255, 255, 255), Red = Color3.fromRGB(255, 60, 60) }

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UrielDev_MM2_Ultimate"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ==========================================
-- 🔘 BOTÓN FLOTANTE CON BORDES
-- ==========================================
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 210, 0, 50)
ToggleBtn.Position = UDim2.new(0.5, -105, 0, 20)
ToggleBtn.BackgroundColor3 = Theme.BG
ToggleBtn.BackgroundTransparency = 0.1
ToggleBtn.Text = "URIEL DEV"
ToggleBtn.TextColor3 = Theme.Text
ToggleBtn.Font = Enum.Font.FredokaOne
ToggleBtn.TextSize = 18
ToggleBtn.AutoButtonColor = false
ToggleBtn.ZIndex = 100
ToggleBtn.Visible = false
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

local TStroke = Instance.new("UIStroke", ToggleBtn)
TStroke.Color = Theme.Accent
TStroke.Thickness = 3

-- Animación del botón
ToggleBtn.MouseButton1Down:Connect(function()
    TweenService:Create(ToggleBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 200, 0, 45)}):Play()
    TweenService:Create(TStroke, TweenInfo.new(0.1), {Thickness = 5}):Play()
end)
ToggleBtn.MouseButton1Up:Connect(function()
    TweenService:Create(ToggleBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 210, 0, 50)}):Play()
    TweenService:Create(TStroke, TweenInfo.new(0.1), {Thickness = 3}):Play()
end)

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
-- 🖥️ VENTANA PRINCIPAL
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 430, 0, 360)
MainFrame.Position = UDim2.new(0.5, -215, 0.5, -180)
MainFrame.BackgroundColor3 = Theme.BG
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 1.5

-- PARTÍCULAS (ESTRELLAS)
local StarContainer = Instance.new("Frame", MainFrame)
StarContainer.Size = UDim2.new(1, 0, 1, 0)
StarContainer.BackgroundTransparency = 1
StarContainer.ClipsDescendants = true
StarContainer.ZIndex = 10
Instance.new("UICorner", StarContainer).CornerRadius = UDim.new(0, 10)

local StarColor = Color3.fromRGB(0, 150, 255)
local StarTransparency = 0.5

local function CreateStar()
    local star = Instance.new("ImageLabel", StarContainer)
    star.Size = UDim2.new(0, math.random(3, 8), 0, math.random(3, 8))
    star.Position = UDim2.new(math.random(0, 100)/100, 0, 1, 0)
    star.BackgroundTransparency = 1
    star.Image = "rbxassetid://11395780588"
    star.ImageColor3 = StarColor
    star.ImageTransparency = StarTransparency
    star.ZIndex = 10
    local tween = TweenService:Create(star, TweenInfo.new(math.random(2, 5), Enum.EasingStyle.Linear), {Position = UDim2.new(star.Position.X.Scale, 0, -0.1, 0)})
    tween:Play()
    tween.Completed:Connect(function() star:Destroy() end)
end

task.spawn(function()
    while task.wait(0.1) do
        if MainFrame.Visible then CreateStar() end
    end
end)

-- HEADER
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.ZIndex = 11

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = Texts[Language].Title
Title.TextColor3 = Theme.Accent
Title.Font = Enum.Font.FredokaOne
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
CloseBtn.TextSize = 10
CloseBtn.ZIndex = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)
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
-- ⚙️ VARIABLES Y LÓGICA (MM2)
-- ==========================================
local ESP_Color = Color3.fromRGB(255, 255, 255)
local ESP_Rainbow = false
local maxDistance = 500
local BoxesEnabled, NamesEnabled, HealthEnabled, TracersEnabled, RoleESPEnabled, GunESPEnabled = false, false, false, false, false, false
local OnlyMurder, OnlySheriff = false, false
local AimbotEnabled, KillAllEnabled, AutoGrabEnabled = false, false, false
local SpeedHack, FlyHack, Noclip, InfJump = false, false, false, false

-- 🎨 COLORES POR ROL (Dos colores: Relleno y Contorno)
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
            if n:find("knife") or n:find("katana") then return "Murder" end
            if n:find("gun") or n:find("revolver") then return "Sheriff" end
        end
    end
    local bp = plr:FindFirstChild("Backpack")
    if bp then
        for _, t in pairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                local n = t.Name:lower()
                if n:find("knife") or n:find("katana") then return "Murder" end
                if n:find("gun") or n:find("revolver") then return "Sheriff" end
            end
        end
    end
    return "Innocent"
end

local function getValidHead(char)
    local head = char:FindFirstChild("Head")
    if not head then return nil end
    return head
end

local Drawings = {}
local function CreateDrawing(class, props)
    if not Drawing then return nil end
    local obj = Drawing.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function createDrawings(plr)
    Drawings[plr] = {
        Box = CreateDrawing("Square", {Thickness = 2, Color = Theme.Accent, Filled = false, Visible = false}),
        Tracer = CreateDrawing("Line", {Thickness = 2, Color = Theme.Accent, Visible = false}),
        Name = CreateDrawing("Text", {Size = 14, Center = true, Outline = true, Visible = false}),
        HealthBg = CreateDrawing("Square", {Filled = true, Color = Color3.new(0,0,0), Visible = false}),
        Health = CreateDrawing("Square", {Filled = true, Color = Color3.fromRGB(0, 255, 0), Visible = false})
    }
end
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then createDrawings(p) end end
Players.PlayerAdded:Connect(createDrawings)

local activeTargetPos = nil 

-- 🔄 LOOP PRINCIPAL (ESP, GUN ESP, AIMBOT)
RunService.RenderStepped:Connect(function()
    local rainbowColor = Color3.fromHSV((tick() % 5) / 5, 1, 1)
    local screenCenter = Camera.ViewportSize / 2
    
    local bestHead = nil
    local shortestDist = 9e9

    -- CHAM DE ARMAS (Gun ESP)
    if GunESPEnabled then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") and (obj.Name:lower():find("gun") or obj.Name:lower():find("knife") or obj.Name:lower():find("revolver")) then
                if not obj:FindFirstChild("GunHighlight") then
                    local h = Instance.new("Highlight")
                    h.Name = "GunHighlight"
                    h.Adornee = obj
                    h.FillColor = Color3.fromRGB(0, 255, 0) -- Verde neón para que resalte
                    h.FillTransparency = 0.3
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
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
                
                -- FILTROS DE ROL
                if OnlyMurder and role ~= "Murder" then shouldDraw = false end
                if OnlySheriff and role ~= "Sheriff" then shouldDraw = false end

                -- COLORES DUALES
                local fillColor = ESP_Color
                local outlineColor = Theme.BG
                
                if RoleESPEnabled then
                    if role == "Murder" then fillColor = RoleColors.Murder.Fill; outlineColor = RoleColors.Murder.Outline
                    elseif role == "Sheriff" then fillColor = RoleColors.Sheriff.Fill; outlineColor = RoleColors.Sheriff.Outline
                    else fillColor = RoleColors.Innocent.Fill; outlineColor = RoleColors.Innocent.Outline end
                elseif ESP_Rainbow then
                    fillColor = rainbowColor
                    outlineColor = rainbowColor
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
                    draw.Name.Position = Vector2.new(headPos.X, headPos.Y - height/2 - 16)
                    draw.Name.Color = fillColor
                    
                    draw.Tracer.Visible = TracersEnabled
                    draw.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
                    draw.Tracer.To = Vector2.new(torsoPos.X, torsoPos.Y)
                    draw.Tracer.Color = fillColor

                    draw.Health.Visible = HealthEnabled
                    draw.HealthBg.Visible = HealthEnabled
                    if HealthEnabled then
                        local hpPct = humanoid.Health / humanoid.MaxHealth
                        draw.Health.Size = Vector2.new(3, height * hpPct)
                        draw.Health.Position = Vector2.new(headPos.X - width/2 - 6, headPos.Y + height/2 - (height * hpPct))
                        draw.HealthBg.Size = Vector2.new(3, height)
                        draw.HealthBg.Position = Vector2.new(headPos.X - width/2 - 6, headPos.Y - height/4)
                    end
                else
                    draw.Box.Visible = false; draw.Name.Visible = false
                    draw.Tracer.Visible = false; draw.Health.Visible = false; draw.HealthBg.Visible = false
                end

                -- CHAMS
                highlight.Enabled = (RoleESPEnabled or ESP_Rainbow) and shouldDraw
                highlight.FillColor = fillColor
                highlight.OutlineColor = outlineColor
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0

                -- AIMBOT
                if AimbotEnabled and role == "Murder" and onScreen and distFromMe <= maxDistance then
                    if fovDist < shortestDist then
                        local valid = getValidHead(char)
                        if valid then shortestDist = fovDist; bestHead = valid end
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

-- AIMBOT HOOK
local old; old = hookmetamethod(game, "__index", newcclosure(function(self, idx)
    if AimbotEnabled and activeTargetPos and not checkcaller() and idx == "ViewportSize" and self == Camera then
        local pos, on = Camera:WorldToViewportPoint(activeTargetPos)
        if on then return Vector2.new(pos.X * 2, pos.Y * 2) end
    end
    return old(self, idx)
end))

-- KILL ALL Y AUTO GRAB
task.spawn(function()
    while task.wait(0.1) do
        if LocalPlayer.Character then
            if AutoGrabEnabled then
                local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("Tool") and (obj.Name:lower():find("knife") or obj.Name:lower():find("gun") or obj.Name:lower():find("revolver")) then
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
                                for _, part in pairs(plr.Character:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        pcall(function() if firetouchinterest then firetouchinterest(part, part, 0) firetouchinterest(part, part, 1) end end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- MOVIMIENTO
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
-- 🧱 COMPONENTES DE LA UI
-- ==========================================
local function CreateCheckbox(parent, text, default, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Theme.Card
    btn.BackgroundTransparency = 0.5
    btn.Text = ""
    btn.ZIndex = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local boxBg = Instance.new("Frame", btn)
    boxBg.Size = UDim2.new(0, 16, 0, 16)
    boxBg.Position = UDim2.new(0, 8, 0.5, -8)
    boxBg.BackgroundColor3 = Theme.BG
    boxBg.ZIndex = 13
    Instance.new("UICorner", boxBg).CornerRadius = UDim.new(0, 3)
    local boxStroke = Instance.new("UIStroke", boxBg)
    boxStroke.Color = Theme.Border
    
    local check = Instance.new("ImageLabel", boxBg)
    check.Size = UDim2.new(1, -4, 1, -4)
    check.Position = UDim2.new(0, 2, 0, 2)
    check.BackgroundTransparency = 1
    check.Image = "rbxassetid://6031091004"
    check.ImageColor3 = Theme.Accent
    check.Visible = false
    check.ZIndex = 14
    
    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 32, 0, 0)
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.BuilderSansMedium
    label.TextSize = 11
    label.ZIndex = 13
    
    local state = default
    if state then check.Visible = true boxStroke.Color = Theme.Accent end
    btn.MouseButton1Click:Connect(function()
        state = not state
        check.Visible = state
        TweenService:Create(boxStroke, TweenInfo.new(0.2), {Color = state and Theme.Accent or Theme.Border}):Play()
        if callback then callback(state) end
    end)
    return btn
end

local function CreateSlider(parent, text, min, max, default, callback)
    local wrap = Instance.new("Frame", parent)
    wrap.Size = UDim2.new(1, 0, 0, 40)
    wrap.BackgroundTransparency = 1
    wrap.ZIndex = 12
    
    local label = Instance.new("TextLabel", wrap)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.BuilderSansMedium
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    
    local bar = Instance.new("TextButton", wrap)
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0, 25)
    bar.BackgroundColor3 = Theme.Border
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
    btn.BackgroundColor3 = Theme.Card
    btn.BackgroundTransparency = 0.5
    btn.Text = ""
    btn.ZIndex = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.BuilderSansMedium
    label.TextSize = 11
    label.ZIndex = 13
    
    local colorBox = Instance.new("Frame", btn)
    colorBox.Size = UDim2.new(0, 16, 0, 16)
    colorBox.Position = UDim2.new(1, -24, 0.5, -8)
    colorBox.BackgroundColor3 = defaultColor
    colorBox.ZIndex = 13
    Instance.new("UICorner", colorBox).CornerRadius = UDim.new(1, 0)
    
    btn.MouseButton1Click:Connect(function()
        local newColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        colorBox.BackgroundColor3 = newColor
        if callback then callback(newColor) end
    end)
end

-- ==========================================
-- 📑 CONSTRUCCIÓN DEL MENÚ
-- ==========================================
local function BuildMenu()
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 50, 1, -55)
    Sidebar.Position = UDim2.new(0, 10, 0, 50)
    Sidebar.BackgroundColor3 = Theme.Card
    Sidebar.BackgroundTransparency = 0.4
    Sidebar.ZIndex = 11
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

    local ContentHost = Instance.new("Frame", MainFrame)
    ContentHost.Size = UDim2.new(1, -85, 1, -55)
    ContentHost.Position = UDim2.new(0, 75, 0, 50)
    ContentHost.BackgroundTransparency = 1
    ContentHost.ZIndex = 11

    local Pages = {}
    local function CreatePage(name)
        local page = Instance.new("ScrollingFrame", ContentHost)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 2
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        page.ZIndex = 12
        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 5)
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
        btn.BackgroundColor3 = Theme.BG
        btn.BackgroundTransparency = 0.5
        btn.Image = iconId
        btn.ImageColor3 = Theme.Accent
        btn.ZIndex = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(function() SwitchPage(pageName) end)
        return CreatePage(pageName)
    end

    -- ESP
    local ESPPage = CreateTabBtn("rbxassetid://13571270194", "ESP")
    CreateCheckbox(ESPPage, Texts[Language].ESP.RoleESP, false, function(s) RoleESPEnabled = s end)
    CreateCheckbox(ESPPage, Texts[Language].ESP.GunESP, false, function(s) GunESPEnabled = s end)
    CreateCheckbox(ESPPage, Texts[Language].ESP.OnlyMurder, false, function(s) OnlyMurder = s if s then OnlySheriff = false end end)
    CreateCheckbox(ESPPage, Texts[Language].ESP.OnlySheriff, false, function(s) OnlySheriff = s if s then OnlyMurder = false end end)
    CreateCheckbox(ESPPage, Texts[Language].ESP.Boxes, false, function(s) BoxesEnabled = s end)
    CreateCheckbox(ESPPage, Texts[Language].ESP.Tracers, false, function(s) TracersEnabled = s end)
    CreateCheckbox(ESPPage, Texts[Language].ESP.Names, false, function(s) NamesEnabled = s end)
    CreateCheckbox(ESPPage, Texts[Language].ESP.Health, false, function(s) HealthEnabled = s end)
    CreateCheckbox(ESPPage, Texts[Language].ESP.Rainbow, false, function(s) ESP_Rainbow = s end)

    -- COMBAT
    local CombatPage = CreateTabBtn("rbxassetid://80964454894155", "Combat")
    CreateCheckbox(CombatPage, Texts[Language].Combat.Aimbot, false, function(s) AimbotEnabled = s end)
    CreateCheckbox(CombatPage, Texts[Language].Combat.KillAll, false, function(s) KillAllEnabled = s end)
    CreateCheckbox(CombatPage, Texts[Language].Combat.AutoGrab, false, function(s) AutoGrabEnabled = s end)
    CreateSlider(CombatPage, Texts[Language].Combat.MaxDist, 100, 2000, 500, function(v) maxDistance = v end)

    -- PLAYER
    local PlayerPage = CreateTabBtn("rbxassetid://13492318225", "Player")
    CreateCheckbox(PlayerPage, Texts[Language].Player.Speed, false, function(s) SpeedHack = s end)
    CreateCheckbox(PlayerPage, Texts[Language].Player.Noclip, false, function(s) Noclip = s end)
    CreateCheckbox(PlayerPage, Texts[Language].Player.Fly, false, function(s) 
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
    CreateCheckbox(PlayerPage, Texts[Language].Player.Jump, false, function(s) InfJump = s end)

    -- WORLD
    local WorldPage = CreateTabBtn("rbxassetid://13492318225", "World")
    CreateCheckbox(WorldPage, Texts[Language].World.Fullbright, false, function(s) 
        Lighting.Brightness = s and 2 or 1; Lighting.ClockTime = s and 14 or 12; Lighting.GlobalShadows = not s 
    end)
    CreateCheckbox(WorldPage, Texts[Language].World.RemoveTex, false, function(s)
        if s then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end
            end
        end
    end)

    -- SETTINGS
    local SettingsPage = CreateTabBtn("rbxassetid://13492318225", "Settings")
    CreateColorPicker(SettingsPage, Texts[Language].Settings.ParticleColor, StarColor, function(c) StarColor = c end)
    CreateSlider(SettingsPage, Texts[Language].Settings.ParticleTrans, 0, 0.9, 0.5, function(v) StarTransparency = v end)

    CreateColorPicker(SettingsPage, "Murder " .. Texts[Language].Settings.Fill, RoleColors.Murder.Fill, function(c) RoleColors.Murder.Fill = c end)
    CreateColorPicker(SettingsPage, "Murder " .. Texts[Language].Settings.Outline, RoleColors.Murder.Outline, function(c) RoleColors.Murder.Outline = c end)
    CreateColorPicker(SettingsPage, "Sheriff " .. Texts[Language].Settings.Fill, RoleColors.Sheriff.Fill, function(c) RoleColors.Sheriff.Fill = c end)
    CreateColorPicker(SettingsPage, "Sheriff " .. Texts[Language].Settings.Outline, RoleColors.Sheriff.Outline, function(c) RoleColors.Sheriff.Outline = c end)
    CreateColorPicker(SettingsPage, "Innocent " .. Texts[Language].Settings.Fill, RoleColors.Innocent.Fill, function(c) RoleColors.Innocent.Fill = c end)
    CreateColorPicker(SettingsPage, "Innocent " .. Texts[Language].Settings.Outline, RoleColors.Innocent.Outline, function(c) RoleColors.Innocent.Outline = c end)

    -- CREDITS
    local CreditsPage = CreateTabBtn("rbxassetid://13492318225", "Credits")
    local creditLabel = Instance.new("TextLabel", CreditsPage)
    creditLabel.Size = UDim2.new(1, 0, 0, 60)
    creditLabel.BackgroundTransparency = 1
    creditLabel.Text = Texts[Language].Credits.Title .. "\n" .. Texts[Language].Credits.Desc
    creditLabel.TextColor3 = Theme.Text
    creditLabel.Font = Enum.Font.BuilderSansBold
    creditLabel.TextSize = 12
    creditLabel.TextWrapped = true
    creditLabel.ZIndex = 13

    local copyBtn = Instance.new("TextButton", CreditsPage)
    copyBtn.Size = UDim2.new(1, 0, 0, 30)
    copyBtn.BackgroundColor3 = Theme.Accent
    copyBtn.Text = Texts[Language].Credits.Btn
    copyBtn.TextColor3 = Theme.Text
    copyBtn.Font = Enum.Font.BuilderSansBold
    copyBtn.ZIndex = 13
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)
    copyBtn.MouseButton1Click:Connect(function() setclipboard("urieldev") end)

    SwitchPage("ESP")
end

-- SELECTOR DE IDIOMA
local LangGui = Instance.new("ScreenGui", CoreGui)
local LangFrame = Instance.new("Frame", LangGui)
LangFrame.Size = UDim2.new(0, 250, 0, 150)
LangFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
LangFrame.BackgroundColor3 = Theme.BG
Instance.new("UICorner", LangFrame).CornerRadius = UDim.new(0, 10)
local LStroke = Instance.new("UIStroke", LangFrame)
LStroke.Color = Theme.Accent

local LTitle = Instance.new("TextLabel", LangFrame)
LTitle.Size = UDim2.new(1, 0, 0, 40)
LTitle.BackgroundTransparency = 1
LTitle.Text = "Select Language / Selecciona Idioma"
LTitle.TextColor3 = Theme.Text
LTitle.Font = Enum.Font.BuilderSansBold
LTitle.Parent = LangFrame

local BtnES = Instance.new("TextButton", LangFrame)
BtnES.Size = UDim2.new(0.4, 0, 0, 35)
BtnES.Position = UDim2.new(0.05, 0, 0, 60)
BtnES.BackgroundColor3 = Theme.Card
BtnES.Text = "Español"
BtnES.TextColor3 = Theme.Text
BtnES.Font = Enum.Font.BuilderSansBold
Instance.new("UICorner", BtnES).CornerRadius = UDim.new(0, 6)

local BtnEN = Instance.new("TextButton", LangFrame)
BtnEN.Size = UDim2.new(0.4, 0, 0, 35)
BtnEN.Position = UDim2.new(0.55, 0, 0, 60)
BtnEN.BackgroundColor3 = Theme.Card
BtnEN.Text = "English"
BtnEN.TextColor3 = Theme.Text
BtnEN.Font = Enum.Font.BuilderSansBold
Instance.new("UICorner", BtnEN).CornerRadius = UDim.new(0, 6)

BtnES.MouseButton1Click:Connect(function()
    Language = "ES"; LangGui:Destroy(); ToggleBtn.Visible = true; BuildMenu()
end)

BtnEN.MouseButton1Click:Connect(function()
    Language = "EN"; LangGui:Destroy(); ToggleBtn.Visible = true; BuildMenu()
end)
