-- ==========================================
-- 👑 URIEL DEV | RIVALS (CUSTOM UI)
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================
-- 🎨 DISEÑO Y COLORES
-- ==========================================
local Theme = {
    BG = Color3.fromRGB(15, 15, 20),
    Card = Color3.fromRGB(25, 25, 32),
    Border = Color3.fromRGB(50, 50, 65),
    Accent = Color3.fromRGB(0, 150, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Muted = Color3.fromRGB(150, 150, 160),
    Red = Color3.fromRGB(255, 60, 60)
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UrielDev_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ==========================================
-- ✨ BOTÓN FLOTANTE (ESTILO PÍLDORA)
-- ==========================================
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 200, 0, 45)
ToggleBtn.Position = UDim2.new(0.5, -100, 0, 20)
ToggleBtn.BackgroundColor3 = Theme.BG
ToggleBtn.Text = "URIEL DEV"
ToggleBtn.TextColor3 = Theme.Text
ToggleBtn.Font = Enum.Font.FredokaOne
ToggleBtn.TextSize = 16
ToggleBtn.ZIndex = 100
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local TStroke = Instance.new("UIStroke", ToggleBtn)
TStroke.Color = Theme.Accent
TStroke.Thickness = 2

-- SISTEMA PARA MOVER EL BOTÓN
local dragToggle, startToggle, posToggle
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        startToggle = input.Position
        posToggle = ToggleBtn.Position
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
local MainFrame = Instance.new("CanvasGroup")
MainFrame.Size = UDim2.new(0, 380, 0, 300)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -150)
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

-- CABECERA
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.ZIndex = 10

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "URIEL DEV"
Title.TextColor3 = Theme.Accent
Title.Font = Enum.Font.FredokaOne
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 10

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
CloseBtn.BackgroundColor3 = Theme.Red
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 10
CloseBtn.ZIndex = 10
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false ToggleBtn.Visible = true end)

-- MOVER LA VENTANA
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
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

-- ABRIR MENÚ AL TOCAR EL BOTÓN
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ToggleBtn.Visible = false
    MainFrame.GroupTransparency = 1
    MainFrame.Size = UDim2.new(0, 360, 0, 280)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        GroupTransparency = 0, Size = UDim2.new(0, 380, 0, 300)
    }):Play()
end)

-- BARRA LATERAL (TABS)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 50, 1, -55)
Sidebar.Position = UDim2.new(0, 10, 0, 50)
Sidebar.BackgroundColor3 = Theme.Card
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

local function CreateTabBtn(iconId, pageName)
    local btn = Instance.new("ImageButton", Sidebar)
    btn.Size = UDim2.new(0, 32, 0, 32)
    btn.Position = UDim2.new(0, 9, 0, 9 + (#Sidebar:GetChildren() * 40))
    btn.BackgroundColor3 = Theme.BG
    btn.BackgroundTransparency = 0.5
    btn.Image = iconId
    btn.ImageColor3 = Theme.Accent
    btn.ZIndex = 2
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function() SwitchPage(pageName) end)
    return CreatePage(pageName)
end

-- ==========================================
-- ⚙️ LÓGICA DEL JUEGO (RIVALS)
-- ==========================================
local ESP_Color = Color3.fromRGB(0, 150, 255)
local ESP_Rainbow = false
local maxDistance = 500

local function isEnemy(plr)
    if not plr or plr == LocalPlayer then return false end
    local myT = LocalPlayer:GetAttribute("TeamID")
    local thrT = plr:GetAttribute("TeamID")
    if myT ~= nil and thrT ~= nil then return tostring(myT) ~= tostring(thrT) end
    if LocalPlayer.Team and plr.Team then return LocalPlayer.Team ~= plr.Team end
    return true
end

local function getValidHead(char)
    local head = char:FindFirstChild("Head")
    if not head then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 1000, params)
    return (result == nil or result.Instance:IsDescendantOf(char)) and head or nil
end

-- ESP Y TRACERS
local tracers = {}
local function createTracer(plr)
    local l = Drawing.new("Line")
    l.Thickness = 1.5; l.Transparency = 1; l.Visible = false; tracers[plr] = l
end
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then createTracer(p) end end
Players.PlayerAdded:Connect(createTracer)

local activeTargetPos = nil 
local ESP_Enabled = false
local Tracers_Enabled = false
local SilentAim_Enabled = false

RunService.RenderStepped:Connect(function()
    local rainbowColor = Color3.fromHSV((tick() % 5) / 5, 1, 1)
    local currentColor = ESP_Rainbow and rainbowColor or ESP_Color
    local screenCenter = Camera.ViewportSize / 2
    local bestHead = nil
    local shortestDist = 9e9

    for _, plr in pairs(Players:GetPlayers()) do
        local tracer = tracers[plr]
        local char = plr.Character
        if char and isEnemy(plr) then
            local head = char:FindFirstChild("Head")
            local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
            local highlight = char:FindFirstChild("Highlight") or Instance.new("Highlight", char)
            
            if head and torso then
                local distFromMe = (head.Position - Camera.CFrame.Position).Magnitude
                local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
                local torsoPos, torsoOnScreen = Camera:WorldToViewportPoint(torso.Position)
                local fovDist = (Vector2.new(headPos.X, headPos.Y) - screenCenter).Magnitude

                if tracer then
                    tracer.Visible = (Tracers_Enabled and torsoOnScreen and distFromMe <= maxDistance)
                    if tracer.Visible then
                        tracer.From = screenCenter 
                        tracer.To = Vector2.new(torsoPos.X, torsoPos.Y)
                        tracer.Color = currentColor
                    end
                end

                highlight.Enabled = ESP_Enabled; 
                highlight.FillColor = currentColor

                if headOnScreen and distFromMe <= maxDistance then
                    if SilentAim_Enabled then
                        if fovDist < shortestDist then
                            local valid = getValidHead(char)
                            if valid then shortestDist = fovDist; bestHead = valid end
                        end
                    end
                end
            end
        elseif tracer then tracer.Visible = false end
    end
    activeTargetPos = bestHead and bestHead.Position or nil
end)

local old; old = hookmetamethod(game, "__index", newcclosure(function(self, idx)
    if SilentAim_Enabled and activeTargetPos and not checkcaller() and idx == "ViewportSize" and self == Camera then
        local pos, on = Camera:WorldToViewportPoint(activeTargetPos)
        if on then return Vector2.new(pos.X * 2, pos.Y * 2) end
    end
    return old(self, idx)
end))

-- ==========================================
-- 🧱 CREACIÓN DE OPCIONES (CHECKBOXES Y SLIDERS)
-- ==========================================
local function CreateCheckbox(parent, text, default, callback)
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
    boxBg.BackgroundColor3 = Theme.BG
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
    wrap.Size = UDim2.new(1, 0, 0, 45)
    wrap.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", wrap)
    label.Size = UDim2.new(1, -40, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.BuilderSansMedium
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local bar = Instance.new("TextButton", wrap)
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0, 25)
    bar.BackgroundColor3 = Theme.Border
    bar.Text = ""
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local sliding = false
    local function updateValue(x)
        local pct = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        local val = math.floor(min + (max - min) * pct)
        if callback then callback(val) end
    end
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateValue(input.Position.X)
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

-- ==========================================
-- 📑 CONSTRUCCIÓN DE LAS PESTAÑAS
-- ==========================================
-- Tab ESP
local ESPPage = CreateTabBtn("rbxassetid://13571270194", "ESP")
CreateCheckbox(ESPPage, "Chams (Resaltar)", false, function(s) ESP_Enabled = s end)
CreateCheckbox(ESPPage, "Tracers (Líneas)", false, function(s) Tracers_Enabled = s end)
CreateCheckbox(ESPPage, "Modo Arcoíris", false, function(s) ESP_Rainbow = s end)

-- Tab Combat
local CombatPage = CreateTabBtn("rbxassetid://80964454894155", "Combat")
CreateCheckbox(CombatPage, "Silent Aim", false, function(s) SilentAim_Enabled = s end)
CreateSlider(CombatPage, "Max Distance", 100, 2000, 500, function(v) maxDistance = v end)

-- Tab Player
local PlayerPage = CreateTabBtn("rbxassetid://13492318225", "Player")
local flyEnabled, noclipEnabled = false, false
CreateCheckbox(PlayerPage, "Volar (Fly)", false, function(s) 
    flyEnabled = s
    if s then
        task.spawn(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = Instance.new("BodyVelocity", hrp)
                bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                while flyEnabled do
                    local move = Vector3.zero
                    if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
                    bv.Velocity = move * 60
                    task.wait()
                end
                bv:Destroy()
            end
        end)
    end
end)
CreateCheckbox(PlayerPage, "Atravesar Paredes", false, function(s) noclipEnabled = s end)
RunService.Stepped:Connect(function() if noclipEnabled and LocalPlayer.Character then for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end end)

-- INICIAR EN ESP
SwitchPage("ESP")
