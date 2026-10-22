-- SANCHO STAR HUB - V15 (PROFESSIONAL EDITION)
-- Optimizado para Delta Executor / Celular

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================
-- 🟢 TUS IMÁGENES CONFIGURADAS
-- ==========================================
local ImgFondo = "https://raw.githubusercontent.com/gaelxitff/Script/main/e82ccb62d42683c1758df82a1b43c6ca.jpg"
local ImgLogo = "https://raw.githubusercontent.com/gaelxitff/Script/main/15ea3b2984d4d74634226262852641b8.jpg"

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
-- 1. BOTÓN FLOTANTE (LOGO PARA ABRIR)
-- ==========================================
local FloatLogo = Instance.new("ImageButton")
FloatLogo.Size = UDim2.new(0, 55, 0, 55)
FloatLogo.Position = UDim2.new(0, 20, 0.5, -27)
FloatLogo.BackgroundColor3 = Theme.BG
FloatLogo.Image = ImgLogo
FloatLogo.ZIndex = 100
FloatLogo.Visible = true
FloatLogo.Parent = ScreenGui
Instance.new("UICorner", FloatLogo).CornerRadius = UDim.new(1, 0)
local fStroke = Instance.new("UIStroke", FloatLogo)
fStroke.Color = Theme.Accent
fStroke.Thickness = 2

-- Arrastrar el logo flotante
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
-- 2. VENTANA PRINCIPAL (TAMAÑO CELULAR)
-- ==========================================
local MainFrame = Instance.new("CanvasGroup")
MainFrame.Size = UDim2.new(0, 340, 0, 280)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -140)
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

-- FONDO PERSONALIZADO (URIEL)
local BgImage = Instance.new("ImageLabel", MainFrame)
BgImage.Size = UDim2.new(1, 0, 1, 0)
BgImage.BackgroundTransparency = 1
BgImage.Image = ImgFondo
BgImage.ImageTransparency = 0.6 -- Transparencia para que se lea el menú
BgImage.ScaleType = Enum.ScaleType.Crop
BgImage.ZIndex = 0
Instance.new("UICorner", BgImage).CornerRadius = UDim.new(0, 10)

-- HEADER
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundTransparency = 1
Header.ZIndex = 10

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SANCHO STAR"
Title.TextColor3 = Theme.Accent
Title.Font = Enum.Font.FredokaOne
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 10

-- MINIMIZAR
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -60, 0.5, -12)
MinBtn.BackgroundColor3 = Theme.Card
MinBtn.Text = "—"
MinBtn.TextColor3 = Theme.Text
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 12
MinBtn.ZIndex = 10
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 5)
MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false FloatLogo.Visible = true end)

-- CERRAR
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

-- ABRIR MENÚ CON EL LOGO
FloatLogo.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    FloatLogo.Visible = false
    -- Animación de apertura
    MainFrame.GroupTransparency = 1
    MainFrame.Size = UDim2.new(0, 320, 0, 260)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        GroupTransparency = 0, Size = UDim2.new(0, 340, 0, 280)
    }):Play()
end)

-- ARRASTRAR VENTANA
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

-- ==========================================
-- 3. BARRA LATERAL (TABS) Y CONTENIDO
-- ==========================================
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 45, 1, -50)
Sidebar.Position = UDim2.new(0, 10, 0, 45)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BackgroundTransparency = 0.2
Sidebar.ZIndex = 2
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local ContentHost = Instance.new("Frame", MainFrame)
ContentHost.Size = UDim2.new(1, -75, 1, -50)
ContentHost.Position = UDim2.new(0, 65, 0, 45)
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
    btn.Size = UDim2.new(0, 30, 0, 30)
    btn.Position = UDim2.new(0, 7.5, 0, 7.5 + (#Sidebar:GetChildren() * 38))
    btn.BackgroundColor3 = Theme.Card
    btn.BackgroundTransparency = 0.5
    btn.Image = iconId
    btn.ImageColor3 = Theme.Accent
    btn.ZIndex = 2
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() SwitchPage(pageName) end)
    return CreatePage(pageName)
end

-- ==========================================
-- 4. LÓGICA DEL JUEGO (ARSENAL)
-- ==========================================
local ESP_Boxes = false
local ESP_Chams = false
local ESP_Tracers = false
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
                    h.FillColor = Theme.Accent
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
                if ESP_Boxes then
                    local height = math.abs(hrpPos.Y - headPos.Y)
                    local width = height / 2
                    draw.Box.Size = Vector2.new(width, height)
                    draw.Box.Position = Vector2.new(headPos.X - width/2, headPos.Y)
                    draw.Box.Visible = true
                else
                    draw.Box.Visible = false
                end
                
                if ESP_Tracers then
                    draw.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, 0) -- Desde arriba hacia el jugador
                    draw.Tracer.To = Vector2.new(hrpPos.X, hrpPos.Y)
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
-- 5. COMPONENTES VISUALES (CHECKBOXES)
-- ==========================================
local function CreateCheckbox(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 30)
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
    label.Text = text
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
-- 6. CONSTRUIR PESTAÑAS Y OPCIONES
-- ==========================================
-- Pestaña Visual (ESP)
local VisualPage = CreateTabButton("rbxassetid://13571270194", "Visual")
CreateCheckbox(VisualPage, "Boxes (Cajas)", function(s) ESP_Boxes = s end)
CreateCheckbox(VisualPage, "Chams (Pintar Cuerpo)", function(s) ESP_Chams = s end)
CreateCheckbox(VisualPage, "Tracers (Líneas arriba)", function(s) ESP_Tracers = s end)
CreateCheckbox(VisualPage, "Names (Nombres)", function(s) print("Names:", s) end)
CreateCheckbox(VisualPage, "Health (Vida)", function(s) print("Health:", s) end)

-- Pestaña Combat (Aimbot)
local CombatPage = CreateTabButton("rbxassetid://80964454894155", "Combat")
CreateCheckbox(CombatPage, "Aimbot Suave", function(s) Aimbot_Enabled = s; UpdateAimbot() end)
CreateCheckbox(CombatPage, "Silent Aim", function(s) print("Silent Aim:", s) end)
CreateCheckbox(CombatPage, "Auto Shoot", function(s) print("Auto Shoot:", s) end)

-- Pestaña Player (Movimiento)
local PlayerPage = CreateTabButton("rbxassetid://13492318225", "Player")
CreateCheckbox(PlayerPage, "Volar (Fly)", function(s) ToggleFly(s) end)
CreateCheckbox(PlayerPage, "Speed Hack", function(s) 
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = s and 50 or 16 end
end)
CreateCheckbox(PlayerPage, "Infinite Jump", function(s) print("Jump:", s) end)

-- INICIAR EN LA PÁGINA VISUAL
SwitchPage("Visual")
