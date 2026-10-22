-- SANCHO STAR HUB - V16 (PREMIUM EDITION & TRANSLATION)
-- Optimizado para Delta Executor / Celular

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================
-- 🟢 TUS IMÁGENES (RECUERDA RENOMBRARLAS EN GITHUB A fondo.jpg y logo.jpg)
-- ==========================================
local ImgFondo = "https://raw.githubusercontent.com/gaelxitff/Script/main/e82ccb62d42683c1758df82a1b43c6ca.jpg"
local ImgLogo = "https://raw.githubusercontent.com/gaelxitff/Script/main/15ea3b2984d4d74634226262852641b8.jpg"

-- ==========================================
-- 🌎 SISTEMA DE IDIOMAS
-- ==========================================
local Language = "ES" -- Por defecto Español
local Texts = {
    ES = {
        Title = "SANCHO STAR",
        LanguageSelect = "Selecciona tu Idioma",
        VisualTab = "Visual (ESP)",
        CombatTab = "Combate",
        PlayerTab = "Jugador",
        SettingsTab = "Ajustes",
        Boxes = "Cajas (Box)",
        Chams = "Pintar Cuerpo (Chams)",
        Tracers = "Líneas (Tracers)",
        Names = "Nombres",
        Health = "Barra de Vida",
        EnemyRed = "Enemigos de Color Rojo",
        Aimbot = "Aimbot Suave",
        SilentAim = "Silent Aim",
        AutoShoot = "Disparo Automático",
        Fly = "Volar (Fly)",
        Speed = "Velocidad (Speed)",
        InfJump = "Salto Infinito",
        Unload = "Desactivar Script"
    },
    EN = {
        Title = "SANCHO STAR",
        LanguageSelect = "Select your Language",
        VisualTab = "Visual (ESP)",
        CombatTab = "Combat",
        PlayerTab = "Player",
        SettingsTab = "Settings",
        Boxes = "Boxes",
        Chams = "Chams (Highlight)",
        Tracers = "Tracers",
        Names = "Names",
        Health = "Health Bar",
        EnemyRed = "Red Enemy ESP",
        Aimbot = "Smooth Aimbot",
        SilentAim = "Silent Aim",
        AutoShoot = "Auto Shoot",
        Fly = "Fly",
        Speed = "Speed Hack",
        InfJump = "Infinite Jump",
        Unload = "Unload Script"
    }
}

local Theme = {
    BG = Color3.fromRGB(15, 15, 20),
    Sidebar = Color3.fromRGB(10, 10, 15),
    Card = Color3.fromRGB(25, 25, 30),
    Border = Color3.fromRGB(45, 45, 55),
    Accent = Color3.fromRGB(0, 170, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Muted = Color3.fromRGB(140, 140, 150)
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SanchoHub_Pro"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ==========================================
-- 1. MENÚ DE SELECCIÓN DE IDIOMA
-- ==========================================
local LangFrame = Instance.new("Frame")
LangFrame.Size = UDim2.new(0, 250, 0, 150)
LangFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
LangFrame.BackgroundColor3 = Theme.BG
LangFrame.Parent = ScreenGui
Instance.new("UICorner", LangFrame).CornerRadius = UDim.new(0, 10)
local LangStroke = Instance.new("UIStroke", LangFrame)
LangStroke.Color = Theme.Accent

local LangTitle = Instance.new("TextLabel", LangFrame)
LangTitle.Size = UDim2.new(1, 0, 0, 40)
LangTitle.BackgroundTransparency = 1
LangTitle.Text = "Select Language / Selecciona Idioma"
LangTitle.TextColor3 = Theme.Text
LangTitle.Font = Enum.Font.BuilderSansBold
LangTitle.TextSize = 12
LangTitle.Parent = LangFrame

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

-- ==========================================
-- 2. BOTÓN FLOTANTE (LOGO)
-- ==========================================
local FloatLogo = Instance.new("ImageButton")
FloatLogo.Size = UDim2.new(0, 55, 0, 55)
FloatLogo.Position = UDim2.new(0, 20, 0.5, -27)
FloatLogo.BackgroundColor3 = Theme.BG
FloatLogo.Image = ImgLogo
FloatLogo.ZIndex = 100
FloatLogo.Visible = false
FloatLogo.Parent = ScreenGui
Instance.new("UICorner", FloatLogo).CornerRadius = UDim.new(1, 0)
local fStroke = Instance.new("UIStroke", FloatLogo)
fStroke.Color = Theme.Accent
fStroke.Thickness = 2

local dragLogo, startLogo, posLogo
FloatLogo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragLogo = true
        startLogo = input.Position
        posLogo = FloatLogo.Position
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragLogo = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragLogo and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - startLogo
        FloatLogo.Position = UDim2.new(posLogo.X.Scale, posLogo.X.Offset + delta.X, posLogo.Y.Scale, posLogo.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- 3. VENTANA PRINCIPAL
-- ==========================================
local MainFrame = Instance.new("CanvasGroup")
MainFrame.Size = UDim2.new(0, 360, 0, 300)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -150)
MainFrame.BackgroundColor3 = Theme.BG
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.GroupTransparency = 1
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 1.5

local BgImage = Instance.new("ImageLabel", MainFrame)
BgImage.Size = UDim2.new(1, 0, 1, 0)
BgImage.BackgroundTransparency = 1
BgImage.Image = ImgFondo
BgImage.ImageTransparency = 0.6
BgImage.ScaleType = Enum.ScaleType.Crop
BgImage.ZIndex = 0
Instance.new("UICorner", BgImage).CornerRadius = UDim.new(0, 10)

-- HEADER
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.ZIndex = 10

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SANCHO STAR"
Title.TextColor3 = Theme.Accent
Title.Font = Enum.Font.FredokaOne
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 10

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -60, 0.5, -12)
MinBtn.BackgroundColor3 = Theme.Card
MinBtn.Text = "—"
MinBtn.TextColor3 = Theme.Text
MinBtn.Font = Enum.Font.GothamBold
MinBtn.ZIndex = 10
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 5)
MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false FloatLogo.Visible = true end)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 10
CloseBtn.ZIndex = 10
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false FloatLogo.Visible = true end)

FloatLogo.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    FloatLogo.Visible = false
    MainFrame.GroupTransparency = 1
    MainFrame.Size = UDim2.new(0, 340, 0, 280)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        GroupTransparency = 0, Size = UDim2.new(0, 360, 0, 300)
    }):Play()
end)

local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- BARRA LATERAL
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 50, 1, -55)
Sidebar.Position = UDim2.new(0, 10, 0, 50)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BackgroundTransparency = 0.2
Sidebar.ZIndex = 2
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local ContentHost = Instance.new("Frame", MainFrame)
ContentHost.Size = UDim2.new(1, -85, 1, -55)
ContentHost.Position = UDim2.new(0, 75, 0, 50)
ContentHost.BackgroundTransparency = 1
ContentHost.ZIndex = 2

local Pages = {}
local function CreatePage(name)
    local page = Instance.new("ScrollingFrame", ContentHost)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 2
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 6)
    Pages[name] = page
    return page
end

local function SwitchPage(pageName)
    for name, page in pairs(Pages) do page.Visible = (name == pageName) end
end

local function CreateTabButton(iconId, pageName)
    local btn = Instance.new("ImageButton", Sidebar)
    btn.Size = UDim2.new(0, 32, 0, 32)
    btn.Position = UDim2.new(0, 9, 0, 9 + (#Sidebar:GetChildren() * 40))
    btn.BackgroundColor3 = Theme.Card
    btn.BackgroundTransparency = 0.5
    btn.Image = iconId
    btn.ImageColor3 = Theme.Accent
    btn.ZIndex = 2
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function() SwitchPage(pageName) end)
    return CreatePage(pageName)
end

-- ==========================================
-- 4. LÓGICA DEL JUEGO (CON ENEMIGOS ROJOS)
-- ==========================================
local ESP_Boxes = false
local ESP_Chams = false
local ESP_Tracers = false
local ESP_RedEnemies = false
local Aimbot_Enabled = false
local AimSmoothness = 0.15

local Drawings = {}
local function CreateDrawing(class, props)
    if not Drawing then return nil end
    local obj = Drawing.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

-- CHAMS
task.spawn(function()
    while task.wait(0.2) do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local h = p.Character:FindFirstChild("SanchoESP")
                if ESP_Chams then
                    if not h then
                        h = Instance.new("Highlight")
                        h.Name = "SanchoESP"
                        h.Adornee = p.Character
                        h.Parent = p.Character
                    end
                    -- Color Rojo si está activado, si no Azul
                    h.FillColor = ESP_RedEnemies and Color3.fromRGB(255, 0, 0) or Theme.Accent
                    h.FillTransparency = 0.5
                else
                    if h then h:Destroy() end
                end
            end
        end
    end
end)

-- BOXES Y TRACERS
RunService.RenderStepped:Connect(function()
    if not Drawing then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Head") then
            local hrp = p.Character.HumanoidRootPart
            local head = p.Character.Head
            
            if not Drawings[p] then
                Drawings[p] = {
                    Box = CreateDrawing("Square", {Thickness = 1.5, Color = Theme.Accent, Filled = false, Visible = false}),
                    Tracer = CreateDrawing("Line", {Thickness = 1.5, Color = Theme.Accent, Visible = false})
                }
            end
            
            local draw = Drawings[p]
            local headPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local hrpPos, onScreen2 = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
            
            if onScreen and onScreen2 then
                local currentColor = ESP_RedEnemies and Color3.fromRGB(255, 0, 0) or Theme.Accent
                
                if ESP_Boxes then
                    local height = math.abs(hrpPos.Y - headPos.Y)
                    local width = height / 2
                    draw.Box.Size = Vector2.new(width, height)
                    draw.Box.Position = Vector2.new(headPos.X - width/2, headPos.Y)
                    draw.Box.Color = currentColor
                    draw.Box.Visible = true
                else
                    draw.Box.Visible = false
                end
                
                if ESP_Tracers then
                    draw.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
                    draw.Tracer.To = Vector2.new(hrpPos.X, hrpPos.Y)
                    draw.Tracer.Color = currentColor
                    draw.Tracer.Visible = true
                else
                    draw.Tracer.Visible = false
                end
            else
                draw.Box.Visible = false
                draw.Tracer.Visible = false
            end
        end
    end
end)

-- AIMBOT
local aimbotConn
local function UpdateAimbot()
    if aimbotConn then aimbotConn:Disconnect() end
    if Aimbot_Enabled then
        aimbotConn = RunService.RenderStepped:Connect(function()
            local closest, dist = nil, 250
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if onScreen then
                        local d = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if d < dist then dist = d; closest = p.Character.Head end
                    end
                end
            end
            if closest then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closest.Position), AimSmoothness)
            end
        end)
    end
end

-- FLY
local flyBV
local function ToggleFly(state)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if state and hrp then
        flyBV = Instance.new("BodyVelocity", hrp)
        flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyBV.Velocity = Vector3.zero
    else
        if flyBV then flyBV:Destroy() end
    end
end

-- ==========================================
-- 5. COMPONENTES (CHECKBOXES)
-- ==========================================
local function CreateCheckbox(parent, textKey, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Theme.Card
    btn.BackgroundTransparency = 0.2
    btn.Text = ""
    btn.ZIndex = 2
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local boxBg = Instance.new("Frame", btn)
    boxBg.Size = UDim2.new(0, 16, 0, 16)
    boxBg.Position = UDim2.new(0, 8, 0.5, -8)
    boxBg.BackgroundColor3 = Theme.Sidebar
    boxBg.ZIndex = 3
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
    check.ZIndex = 4
    
    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 32, 0, 0)
    label.Text = Texts[Language][textKey] -- Traducción dinámica
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.BuilderSansMedium
    label.TextSize = 11
    label.ZIndex = 3
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        check.Visible = state
        TweenService:Create(boxStroke, TweenInfo.new(0.2), {Color = state and Theme.Accent or Theme.Border}):Play()
        if callback then callback(state) end
    end)
    return btn
end

-- ==========================================
-- 6. CONSTRUCCIÓN DEL MENÚ
-- ==========================================
local function BuildMenu()
    -- Visual Page
    local VisualPage = CreateTabButton("rbxassetid://13571270194", "Visual")
    CreateCheckbox(VisualPage, "Boxes", function(s) ESP_Boxes = s end)
    CreateCheckbox(VisualPage, "Chams", function(s) ESP_Chams = s end)
    CreateCheckbox(VisualPage, "Tracers", function(s) ESP_Tracers = s end)
    CreateCheckbox(VisualPage, "EnemyRed", function(s) ESP_RedEnemies = s end)

    -- Combat Page
    local CombatPage = CreateTabButton("rbxassetid://80964454894155", "Combat")
    CreateCheckbox(CombatPage, "Aimbot", function(s) Aimbot_Enabled = s; UpdateAimbot() end)
    CreateCheckbox(CombatPage, "SilentAim", function(s) print("Silent Aim:", s) end)
    CreateCheckbox(CombatPage, "AutoShoot", function(s) print("Auto Shoot:", s) end)

    -- Player Page
    local PlayerPage = CreateTabButton("rbxassetid://13492318225", "Player")
    CreateCheckbox(PlayerPage, "Fly", function(s) ToggleFly(s) end)
    CreateCheckbox(PlayerPage, "Speed", function(s) 
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = s and 50 or 16 end
    end)
    CreateCheckbox(PlayerPage, "InfJump", function(s) 
        if s then
            UserInputService.JumpRequest:Connect(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end)

    SwitchPage("Visual")
end

-- ==========================================
-- 7. SELECCIÓN DE IDIOMA
-- ==========================================
BtnES.MouseButton1Click:Connect(function()
    Language = "ES"
    LangFrame:Destroy()
    FloatLogo.Visible = true
    BuildMenu()
end)

BtnEN.MouseButton1Click:Connect(function()
    Language = "EN"
    LangFrame:Destroy()
    FloatLogo.Visible = true
    BuildMenu()
end)
