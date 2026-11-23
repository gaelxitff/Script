--// SERVICIOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

local function getGuiRoot()
    local ok, res = pcall(function()
        if gethui then return gethui() end
        return game:GetService("CoreGui")
    end)
    if ok and res then return res end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local GuiParent = getGuiRoot()

--// CONFIGURACIÓN COMUNIDAD
local WHATSAPP_CHANNEL_URL = "https://whatsapp.com/channel/0029VbCHjR7LNSaCqoxB7P10"
local SHOW_WHATSAPP_ON_OPEN = true

--// ESTADO GLOBAL COMPARTIDO
local State = {
    MenuOpen = true,
    Particles = true,
    QuickBtn = true,
    Fly = false,
    InfiniteJump = false,
    Noclip = false,
    WalkSpeed = 16,
    SilentAim = false,
    SoftLock = false,
    MaxDistance = 500,
    FovEnabled = false,
    FovLevel = 3,
    Chams = false,
    Tracers = false,
    BoxEsp = false,
    TopLine = false,
    Marker = false,
    Fullbright = false
}

--------------------------------------------------
-- 🩸 UI CRISTAL ROJO PROFESIONAL - KING GAEL
--------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KING_GAEL_PRO_RED"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 200
ScreenGui.Parent = GuiParent

local EspOverlay = Instance.new("Frame")
EspOverlay.Name = "EspOverlay"
EspOverlay.Size = UDim2.new(1, 0, 1, 0)
EspOverlay.BackgroundTransparency = 1
EspOverlay.Active = false
EspOverlay.ZIndex = 10
EspOverlay.Parent = ScreenGui

-- Contenedor de notificaciones
local NotifyHolder = Instance.new("Frame")
NotifyHolder.Name = "Notifications"
NotifyHolder.AnchorPoint = Vector2.new(1, 1)
NotifyHolder.Position = UDim2.new(1, -18, 1, -18)
NotifyHolder.Size = UDim2.new(0, IsMobile and 250 or 310, 0, 240)
NotifyHolder.BackgroundTransparency = 1
NotifyHolder.Active = false
NotifyHolder.ZIndex = 170
NotifyHolder.Parent = ScreenGui

local NotifyLayout = Instance.new("UIListLayout")
NotifyLayout.Padding = UDim.new(0, 8)
NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifyLayout.Parent = NotifyHolder

local function Notify(title, text, duration)
    duration = duration or 3.2
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 62)
    card.BackgroundColor3 = Color3.fromRGB(20, 7, 11)
    card.BackgroundTransparency = 0.14
    card.BorderSizePixel = 0
    card.ZIndex = 171
    card.Parent = NotifyHolder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.3
    stroke.Transparency = 0.2
    stroke.Color = Color3.fromRGB(255, 65, 85)
    stroke.Parent = card

    local accentBar = Instance.new("Frame")
    accentBar.Position = UDim2.new(0, 0, 0, 8)
    accentBar.Size = UDim2.new(0, 3, 1, -16)
    accentBar.BackgroundColor3 = Color3.fromRGB(255, 50, 75)
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 172
    accentBar.Parent = card

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = accentBar

    local tLbl = Instance.new("TextLabel")
    tLbl.Position = UDim2.new(0, 14, 0, 7)
    tLbl.Size = UDim2.new(1, -24, 0, 18)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = title
    tLbl.TextColor3 = Color3.fromRGB(255, 240, 243)
    tLbl.Font = Enum.Font.GothamBlack
    tLbl.TextSize = 13
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.ZIndex = 172
    tLbl.Parent = card

    local bLbl = Instance.new("TextLabel")
    bLbl.Position = UDim2.new(0, 14, 0, 26)
    bLbl.Size = UDim2.new(1, -24, 0, 28)
    bLbl.BackgroundTransparency = 1
    bLbl.Text = text
    bLbl.TextColor3 = Color3.fromRGB(245, 195, 202)
    bLbl.Font = Enum.Font.GothamMedium
    bLbl.TextSize = 11
    bLbl.TextXAlignment = Enum.TextXAlignment.Left
    bLbl.TextWrapped = true
    bLbl.ZIndex = 172
    bLbl.Parent = card

    task.delay(duration, function()
        if card and card.Parent then
            local tw = TweenService:Create(card, TweenInfo.new(0.24), {BackgroundTransparency = 1})
            tw:Play()
            tw.Completed:Wait()
            if card and card.Parent then card:Destroy() end
        end
    end)
end

local function CopyToClipboard(txt)
    local ok = pcall(function()
        if setclipboard then
            setclipboard(txt)
        elseif toclipboard then
            toclipboard(txt)
        else
            error("Clipboard unavailable")
        end
    end)
    return ok
end

-- Ventana principal cristal rojo
local vpNow = Camera.ViewportSize
local winW = IsMobile and math.clamp(vpNow.X * 0.9, 335, 500) or 600
local winH = IsMobile and math.clamp(vpNow.Y * 0.82, 275, 380) or 410

local MainWindow = Instance.new("Frame")
MainWindow.Name = "KING_GAEL_WINDOW"
MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
MainWindow.Size = UDim2.new(0, winW, 0, winH)
MainWindow.BackgroundColor3 = Color3.fromRGB(16, 5, 9)
MainWindow.BackgroundTransparency = 0.18
MainWindow.BorderSizePixel = 0
MainWindow.ClipsDescendants = true
MainWindow.Active = true
MainWindow.ZIndex = 30
MainWindow.Parent = ScreenGui

local WinCorner = Instance.new("UICorner")
WinCorner.CornerRadius = UDim.new(0, 18)
WinCorner.Parent = MainWindow

local WinStroke = Instance.new("UIStroke")
WinStroke.Thickness = 1.8
WinStroke.Transparency = 0.15
WinStroke.Color = Color3.fromRGB(255, 45, 70)
WinStroke.Parent = MainWindow

local GlassGrad = Instance.new("UIGradient")
GlassGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 210)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 60, 82)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(105, 12, 24))
})
GlassGrad.Rotation = 130
GlassGrad.Parent = MainWindow

-- Partículas cayendo estrictamente dentro de MainWindow
local MenuParticlesBox = Instance.new("Frame")
MenuParticlesBox.Name = "InsideMenuParticles"
MenuParticlesBox.Size = UDim2.new(1, 0, 1, 0)
MenuParticlesBox.Position = UDim2.new(0, 0, 0, 0)
MenuParticlesBox.BackgroundTransparency = 1
MenuParticlesBox.BorderSizePixel = 0
MenuParticlesBox.ClipsDescendants = true
MenuParticlesBox.ZIndex = 31
MenuParticlesBox.Active = false
MenuParticlesBox.Parent = MainWindow

local menuParticles = {}
local particleTotal = IsMobile and 28 or 46

for i = 1, particleTotal do
    local pFrame = Instance.new("Frame")
    local sz = math.random(3, 7)
    pFrame.Size = UDim2.new(0, sz, 0, sz)
    pFrame.Position = UDim2.new(0, math.random(6, math.max(10, winW - 10)), 0, -math.random(6, winH))
    pFrame.BackgroundColor3 = Color3.fromRGB(255, math.random(50, 125), math.random(70, 135))
    pFrame.BackgroundTransparency = math.random(22, 62) / 100
    pFrame.BorderSizePixel = 0
    pFrame.ZIndex = 31
    pFrame.Active = false
    pFrame.Parent = MenuParticlesBox

    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(1, 0)
    pCorner.Parent = pFrame

    table.insert(menuParticles, {
        obj = pFrame,
        speedY = math.random(34, 88),
        sway = math.random(10, 24),
        phase = math.random() * math.pi * 2
    })
end

-- Header superior KING GAEL
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = Color3.fromRGB(255, 45, 70)
Header.BackgroundTransparency = 0.84
Header.BorderSizePixel = 0
Header.ZIndex = 35
Header.Parent = MainWindow

local HeaderLine = Instance.new("Frame")
HeaderLine.AnchorPoint = Vector2.new(0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, 0)
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.BackgroundColor3 = Color3.fromRGB(255, 85, 105)
HeaderLine.BackgroundTransparency = 0.5
HeaderLine.BorderSizePixel = 0
HeaderLine.ZIndex = 35
HeaderLine.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.Size = UDim2.new(0, 130, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "KING GAEL"
TitleLabel.TextColor3 = Color3.fromRGB(255, 246, 248)
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = IsMobile and 16 or 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 36
TitleLabel.Parent = Header

local SubTag = Instance.new("TextLabel")
SubTag.Position = UDim2.new(0, 134, 0, 1)
SubTag.Size = UDim2.new(0, 195, 1, 0)
SubTag.BackgroundTransparency = 1
SubTag.Text = IsMobile and "RED CRYSTAL • MOBILE PRO" or "RED CRYSTAL • PRO EDITION"
SubTag.TextColor3 = Color3.fromRGB(255, 120, 140)
SubTag.Font = Enum.Font.GothamBold
SubTag.TextSize = 10
SubTag.TextXAlignment = Enum.TextXAlignment.Left
SubTag.ZIndex = 36
SubTag.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.AnchorPoint = Vector2.new(1, 0.5)
CloseBtn.Position = UDim2.new(1, -12, 0.5, 0)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 55, 80)
CloseBtn.BackgroundTransparency = 0.5
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.ZIndex = 36
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

-- Control centralizado de arrastre (evita listeners duplicados)
local activeDrag = nil

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        activeDrag = {
            kind = "window",
            startPos = input.Position,
            origin = MainWindow.Position
        }
    end
end)

UIS.InputChanged:Connect(function(input)
    if not activeDrag then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if activeDrag.kind == "window" then
            local delta = input.Position - activeDrag.startPos
            MainWindow.Position = UDim2.new(
                activeDrag.origin.X.Scale,
                activeDrag.origin.X.Offset + delta.X,
                activeDrag.origin.Y.Scale,
                activeDrag.origin.Y.Offset + delta.Y
            )
        elseif activeDrag.kind == "slider" and activeDrag.onMove then
            activeDrag.onMove(input.Position.X)
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        activeDrag = nil
    end
end)

-- Barra lateral y contenedor de pestañas
local sideW = IsMobile and 110 or 140
local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.new(0, 0, 0, 48)
Sidebar.Size = UDim2.new(0, sideW, 1, -48)
Sidebar.BackgroundColor3 = Color3.fromRGB(255, 50, 75)
Sidebar.BackgroundTransparency = 0.92
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 34
Sidebar.Parent = MainWindow

local SideList = Instance.new("UIListLayout")
SideList.Padding = UDim.new(0, 6)
SideList.SortOrder = Enum.SortOrder.LayoutOrder
SideList.Parent = Sidebar

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0, 10)
SidePad.PaddingLeft = UDim.new(0, 8)
SidePad.PaddingRight = UDim.new(0, 8)
SidePad.Parent = Sidebar

local ContentHolder = Instance.new("Frame")
ContentHolder.Position = UDim2.new(0, sideW + 8, 0, 56)
ContentHolder.Size = UDim2.new(1, -(sideW + 16), 1, -64)
ContentHolder.BackgroundTransparency = 1
ContentHolder.ZIndex = 34
ContentHolder.Parent = MainWindow

local tabs = {}

local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, IsMobile and 34 or 36)
    btn.BackgroundColor3 = Color3.fromRGB(255, 50, 75)
    btn.BackgroundTransparency = 0.85
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(245, 195, 202)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = IsMobile and 12 or 13
    btn.ZIndex = 35
    btn.Parent = Sidebar

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 10)
    bCorner.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(255, 75, 95)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 35
    page.Parent = ContentHolder

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingBottom = UDim.new(0, 8)
    pad.Parent = page

    local function selectTab()
        for _, t in pairs(tabs) do
            t.page.Visible = false
            t.btn.BackgroundTransparency = 0.85
            t.btn.BackgroundColor3 = Color3.fromRGB(255, 50, 75)
            t.btn.TextColor3 = Color3.fromRGB(245, 195, 202)
        end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(235, 35, 60)
        btn.BackgroundTransparency = 0.32
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    btn.MouseButton1Click:Connect(selectTab)

    table.insert(tabs, {btn = btn, page = page})
    if #tabs == 1 then
        selectTab()
    end

    return page
end

local function AddSection(page, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(text)
    lbl.TextColor3 = Color3.fromRGB(255, 110, 130)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 36
    lbl.Parent = page
end

local function AddToggle(page, text, defaultVal, callback)
    local state = defaultVal or false
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3 = Color3.fromRGB(255, 65, 85)
    row.BackgroundTransparency = 0.88
    row.BorderSizePixel = 0
    row.ZIndex = 36
    row.Parent = page

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 11)
    rCorner.Parent = row

    local rStroke = Instance.new("UIStroke")
    rStroke.Thickness = 1
    rStroke.Transparency = 0.65
    rStroke.Color = Color3.fromRGB(255, 95, 115)
    rStroke.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.Size = UDim2.new(1, -68, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 242, 245)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = IsMobile and 12 or 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 37
    lbl.Parent = row

    local pill = Instance.new("TextButton")
    pill.AnchorPoint = Vector2.new(1, 0.5)
    pill.Position = UDim2.new(1, -10, 0.5, 0)
    pill.Size = UDim2.new(0, 44, 0, 22)
    pill.BackgroundColor3 = state and Color3.fromRGB(240, 35, 60) or Color3.fromRGB(48, 20, 28)
    pill.BackgroundTransparency = state and 0.15 or 0.35
    pill.Text = state and "ON" or "OFF"
    pill.TextColor3 = Color3.fromRGB(255, 255, 255)
    pill.Font = Enum.Font.GothamBold
    pill.TextSize = 10
    pill.ZIndex = 37
    pill.Parent = row

    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(1, 0)
    pCorner.Parent = pill

    local function setVal(v)
        state = v
        pill.Text = state and "ON" or "OFF"
        pill.BackgroundColor3 = state and Color3.fromRGB(240, 35, 60) or Color3.fromRGB(48, 20, 28)
        pill.BackgroundTransparency = state and 0.15 or 0.35
        if callback then callback(state) end
    end

    pill.MouseButton1Click:Connect(function()
        setVal(not state)
    end)

    return {Set = setVal}
end

local function AddSlider(page, text, minV, maxV, step, defaultV, suffix, callback)
    local val = defaultV or minV
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 48)
    row.BackgroundColor3 = Color3.fromRGB(255, 65, 85)
    row.BackgroundTransparency = 0.88
    row.BorderSizePixel = 0
    row.ZIndex = 36
    row.Parent = page

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 11)
    rCorner.Parent = row

    local rStroke = Instance.new("UIStroke")
    rStroke.Thickness = 1
    rStroke.Transparency = 0.65
    rStroke.Color = Color3.fromRGB(255, 95, 115)
    rStroke.Parent = row

    local topLbl = Instance.new("TextLabel")
    topLbl.Position = UDim2.new(0, 12, 0, 5)
    topLbl.Size = UDim2.new(1, -24, 0, 18)
    topLbl.BackgroundTransparency = 1
    topLbl.Text = string.format("%s: %s%s", text, tostring(val), suffix or "")
    topLbl.TextColor3 = Color3.fromRGB(255, 242, 245)
    topLbl.Font = Enum.Font.GothamMedium
    topLbl.TextSize = IsMobile and 12 or 12.5
    topLbl.TextXAlignment = Enum.TextXAlignment.Left
    topLbl.ZIndex = 37
    topLbl.Parent = row

    local barBg = Instance.new("Frame")
    barBg.Position = UDim2.new(0, 12, 0, 29)
    barBg.Size = UDim2.new(1, -24, 0, 8)
    barBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    barBg.BackgroundTransparency = 0.82
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 37
    barBg.Parent = row

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = barBg

    local initRatio = math.clamp((val - minV) / (maxV - minV), 0, 1)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(initRatio, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 55, 80)
    fill.BorderSizePixel = 0
    fill.ZIndex = 38
    fill.Parent = barBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local function updateFromX(xPos)
        local absX = barBg.AbsolutePosition.X
        local absW = math.max(barBg.AbsoluteSize.X, 1)
        local ratio = math.clamp((xPos - absX) / absW, 0, 1)
        local raw = minV + (maxV - minV) * ratio
        local snapped = math.floor((raw / step) + 0.5) * step
        snapped = math.clamp(snapped, minV, maxV)
        val = snapped
        local finalRatio = (val - minV) / (maxV - minV)
        fill.Size = UDim2.new(finalRatio, 0, 1, 0)
        topLbl.Text = string.format("%s: %s%s", text, tostring(val), suffix or "")
        if callback then callback(val) end
    end

    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            updateFromX(input.Position.X)
            activeDrag = {
                kind = "slider",
                onMove = updateFromX
            }
        end
    end)
end

local function AddButton(page, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(220, 30, 55)
    btn.BackgroundTransparency = 0.22
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = IsMobile and 12.5 or 13
    btn.ZIndex = 37
    btn.Parent = page

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 11)
    bCorner.Parent = btn

    local bStroke = Instance.new("UIStroke")
    bStroke.Thickness = 1.2
    bStroke.Transparency = 0.25
    bStroke.Color = Color3.fromRGB(255, 130, 145)
    bStroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

-- Tarjeta de invitación al canal de KING GAEL en WhatsApp
local WaBanner = Instance.new("Frame")
WaBanner.Name = "WhatsAppInviteCard"
WaBanner.AnchorPoint = Vector2.new(0.5, 0.5)
WaBanner.Position = UDim2.new(0.5, 0, 0.5, 0)
WaBanner.Size = UDim2.new(0, IsMobile and 305 or 370, 0, 188)
WaBanner.BackgroundColor3 = Color3.fromRGB(20, 7, 11)
WaBanner.BackgroundTransparency = 0.08
WaBanner.BorderSizePixel = 0
WaBanner.Visible = SHOW_WHATSAPP_ON_OPEN
WaBanner.ZIndex = 80
WaBanner.Parent = MainWindow

local WaCorner = Instance.new("UICorner")
WaCorner.CornerRadius = UDim.new(0, 16)
WaCorner.Parent = WaBanner

local WaStroke = Instance.new("UIStroke")
WaStroke.Thickness = 1.7
WaStroke.Color = Color3.fromRGB(255, 55, 80)
WaStroke.Parent = WaBanner

local WaTitle = Instance.new("TextLabel")
WaTitle.Position = UDim2.new(0, 16, 0, 14)
WaTitle.Size = UDim2.new(1, -32, 0, 22)
WaTitle.BackgroundTransparency = 1
WaTitle.Text = "Canal WhatsApp • KING GAEL"
WaTitle.TextColor3 = Color3.fromRGB(255, 115, 135)
WaTitle.Font = Enum.Font.GothamBlack
WaTitle.TextSize = IsMobile and 13.5 or 15
WaTitle.TextXAlignment = Enum.TextXAlignment.Left
WaTitle.ZIndex = 81
WaTitle.Parent = WaBanner

local WaDesc = Instance.new("TextLabel")
WaDesc.Position = UDim2.new(0, 16, 0, 38)
WaDesc.Size = UDim2.new(1, -32, 0, 38)
WaDesc.BackgroundTransparency = 1
WaDesc.Text = "Sigue el canal de KING GAEL en WhatsApp para actualizaciones, scripts y avisos."
WaDesc.TextColor3 = Color3.fromRGB(255, 235, 238)
WaDesc.Font = Enum.Font.Gotham
WaDesc.TextSize = IsMobile and 11 or 12
WaDesc.TextXAlignment = Enum.TextXAlignment.Left
WaDesc.TextWrapped = true
WaDesc.ZIndex = 81
WaDesc.Parent = WaBanner

local WaLinkBox = Instance.new("TextBox")
WaLinkBox.Position = UDim2.new(0, 16, 0, 82)
WaLinkBox.Size = UDim2.new(1, -32, 0, 30)
WaLinkBox.BackgroundColor3 = Color3.fromRGB(255, 55, 80)
WaLinkBox.BackgroundTransparency = 0.84
WaLinkBox.Text = WHATSAPP_CHANNEL_URL
WaLinkBox.TextColor3 = Color3.fromRGB(255, 195, 205)
WaLinkBox.Font = Enum.Font.GothamMedium
WaLinkBox.TextSize = IsMobile and 10 or 11
WaLinkBox.ClearTextOnFocus = false
WaLinkBox.TextEditable = false
WaLinkBox.ZIndex = 81
WaLinkBox.Parent = WaBanner

local WaBoxCorner = Instance.new("UICorner")
WaBoxCorner.CornerRadius = UDim.new(0, 8)
WaBoxCorner.Parent = WaLinkBox

local CopyWaBtn = Instance.new("TextButton")
CopyWaBtn.Position = UDim2.new(0, 16, 1, -46)
CopyWaBtn.Size = UDim2.new(0.56, -20, 0, 34)
CopyWaBtn.BackgroundColor3 = Color3.fromRGB(230, 30, 55)
CopyWaBtn.BackgroundTransparency = 0.12
CopyWaBtn.Text = "Copiar Enlace"
CopyWaBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyWaBtn.Font = Enum.Font.GothamBold
CopyWaBtn.TextSize = 12
CopyWaBtn.ZIndex = 81
CopyWaBtn.Parent = WaBanner

local CopyWaCorner = Instance.new("UICorner")
CopyWaCorner.CornerRadius = UDim.new(0, 10)
CopyWaCorner.Parent = CopyWaBtn

local CloseWaBtn = Instance.new("TextButton")
CloseWaBtn.Position = UDim2.new(0.56, 4, 1, -46)
CloseWaBtn.Size = UDim2.new(0.44, -20, 0, 34)
CloseWaBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseWaBtn.BackgroundTransparency = 0.86
CloseWaBtn.Text = "Entrar"
CloseWaBtn.TextColor3 = Color3.fromRGB(255, 240, 244)
CloseWaBtn.Font = Enum.Font.GothamBold
CloseWaBtn.TextSize = 12
CloseWaBtn.ZIndex = 81
CloseWaBtn.Parent = WaBanner

local CloseWaCorner = Instance.new("UICorner")
CloseWaCorner.CornerRadius = UDim.new(0, 10)
CloseWaCorner.Parent = CloseWaBtn

CopyWaBtn.MouseButton1Click:Connect(function()
    if CopyToClipboard(WHATSAPP_CHANNEL_URL) then
        Notify("KING GAEL • WhatsApp", "Enlace copiado al portapapeles.", 3.2)
    else
        Notify("KING GAEL • WhatsApp", WHATSAPP_CHANNEL_URL, 5)
    end
end)

CloseWaBtn.MouseButton1Click:Connect(function()
    WaBanner.Visible = false
end)

-- Botón flotante para abrir/cerrar KING GAEL
local QuickBtn = Instance.new("TextButton")
QuickBtn.Name = "KING_GAEL_TOGGLE"
QuickBtn.Size = IsMobile and UDim2.new(0, 92, 0, 34) or UDim2.new(0, 88, 0, 30)
QuickBtn.Position = IsMobile and UDim2.new(0, 14, 0.5, -17) or UDim2.new(0, 14, 0, 14)
QuickBtn.BackgroundColor3 = Color3.fromRGB(22, 7, 11)
QuickBtn.BackgroundTransparency = 0.2
QuickBtn.Text = "KING GAEL"
QuickBtn.TextColor3 = Color3.fromRGB(255, 245, 248)
QuickBtn.Font = Enum.Font.GothamBlack
QuickBtn.TextSize = IsMobile and 11.5 or 11
QuickBtn.Visible = State.QuickBtn
QuickBtn.ZIndex = 150
QuickBtn.Parent = ScreenGui

local qCorner = Instance.new("UICorner")
qCorner.CornerRadius = UDim.new(0, 10)
qCorner.Parent = QuickBtn

local qStroke = Instance.new("UIStroke")
qStroke.Thickness = 1.5
qStroke.Transparency = 0.2
qStroke.Color = Color3.fromRGB(255, 50, 75)
qStroke.Parent = QuickBtn

local function ToggleWindow(forceState)
    local nextState = (forceState ~= nil) and forceState or (not MainWindow.Visible)
    State.MenuOpen = nextState
    MainWindow.Visible = nextState
end

CloseBtn.MouseButton1Click:Connect(function()
    ToggleWindow(false)
end)

QuickBtn.MouseButton1Click:Connect(function()
    ToggleWindow()
end)

UIS.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift then
        ToggleWindow()
    end
end)

--------------------------------------------------
-- 🛡️ UTILIDADES DE JUEGO
--------------------------------------------------
local function isEnemy(plr)
    if not plr or plr == LocalPlayer then return false end
    local myT = LocalPlayer:GetAttribute("TeamID")
    local thrT = plr:GetAttribute("TeamID")
    if myT ~= nil and thrT ~= nil then
        return tostring(myT) ~= tostring(thrT)
    end
    if LocalPlayer.Team and plr.Team then
        return LocalPlayer.Team ~= plr.Team
    end
    return true
end

local function getValidHead(char)
    local head = char:FindFirstChild("Head")
    if not head then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = workspace:Raycast(
        Camera.CFrame.Position,
        (head.Position - Camera.CFrame.Position).Unit * 1000,
        params
    )
    return (result == nil or result.Instance:IsDescendantOf(char)) and head or nil
end

--------------------------------------------------
-- 👤 PESTAÑA: JUGADOR
--------------------------------------------------
local PlayerTab = CreateTab("Jugador")
AddSection(PlayerTab, "Movimiento")

local function applyWalkSpeed(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = State.WalkSpeed
    end
end

local function clearFlyVelocity()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local existing = hrp:FindFirstChild("KingGaelFlyVel")
        if existing then existing:Destroy() end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.2)
    applyWalkSpeed(char)
    if State.Fly then
        task.spawn(function()
            -- Se relanza el bucle de vuelo limpio en el nuevo personaje
            while State.Fly do
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then break end
                local bv = hrp:FindFirstChild("KingGaelFlyVel")
                if not bv then
                    bv = Instance.new("BodyVelocity")
                    bv.Name = "KingGaelFlyVel"
                    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                    bv.Parent = hrp
                end
                local move = Vector3.zero
                if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end
                bv.Velocity = move * 65
                task.wait()
            end
            clearFlyVelocity()
        end)
    end
end)

UIS.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then
            h:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Stepped:Connect(function()
    if State.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

AddToggle(PlayerTab, "Fly", false, function(v)
    State.Fly = v
    if v then
        LocalPlayer:LoadCharacter() -- asegura bucle activo si ya está vivo
    else
        clearFlyVelocity()
    end
end)

-- Fix rápido para Fly sin forzar respawn si ya tiene personaje
local flyLoopRunning = false
local function startFlyLoop()
    if flyLoopRunning then return end
    flyLoopRunning = true
    task.spawn(function()
        while State.Fly do
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = hrp:FindFirstChild("KingGaelFlyVel")
                if not bv then
                    bv = Instance.new("BodyVelocity")
                    bv.Name = "KingGaelFlyVel"
                    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                    bv.Parent = hrp
                end
                local move = Vector3.zero
                if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end
                bv.Velocity = move * 65
            end
            task.wait()
        end
        clearFlyVelocity()
        flyLoopRunning = false
    end)
end

-- Reemplaza el callback del toggle Fly para no recargar personaje
AddToggle(PlayerTab, "Fly Mode", false, function(v)
    State.Fly = v
    if v then
        startFlyLoop()
    else
        clearFlyVelocity()
    end
end)

AddToggle(PlayerTab, "Infinite Jump", false, function(v)
    State.InfiniteJump = v
end)

AddToggle(PlayerTab, "Noclip", false, function(v)
    State.Noclip = v
end)

AddSlider(PlayerTab, "WalkSpeed", 16, 200, 1, 16, " WS", function(v)
    State.WalkSpeed = v
    applyWalkSpeed(LocalPlayer.Character)
end)

--------------------------------------------------
-- ⚔️ PESTAÑA: COMBATE
--------------------------------------------------
local CombatTab = CreateTab("Combate")
AddSection(CombatTab, "Apuntado y Objetivos")

local fovScale = IsMobile and 48 or 60
local calculatedRadius = State.FovLevel * fovScale
getgenv().SilentAimEnabled = false
getgenv().SoftLockEnabled = false

AddToggle(CombatTab, "Silent Aim (Full Range)", false, function(v)
    State.SilentAim = v
    getgenv().SilentAimEnabled = v
end)

AddToggle(CombatTab, "Soft Lock (FOV Only)", false, function(v)
    State.SoftLock = v
    getgenv().SoftLockEnabled = v
end)

AddSlider(CombatTab, "Max Distance", 100, 2000, 50, 500, " studs", function(v)
    State.MaxDistance = v
end)

AddSection(CombatTab, "Configuración FOV")

AddToggle(CombatTab, "Show FOV Circle", false, function(v)
    State.FovEnabled = v
end)

AddSlider(CombatTab, "FOV Level (1-10)", 1, 10, 1, 3, "x", function(v)
    State.FovLevel = v
    calculatedRadius = v * fovScale
end)

local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.Active = false
fovCircle.ZIndex = 20
fovCircle.Parent = ScreenGui

local fovStroke = Instance.new("UIStroke")
fovStroke.Thickness = IsMobile and 2.5 or 2
fovStroke.Color = Color3.fromRGB(255, 50, 75)
fovStroke.Parent = fovCircle

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

--------------------------------------------------
-- 👁️ PESTAÑA: ESP (CHAMS, TRACERS, BOX, TOP LINE, MARKER)
--------------------------------------------------
local ESPTab = CreateTab("ESP")
AddSection(ESPTab, "Visuales Enemigos")

local espObjects = {}

local function makeLineFrame(thickness)
    local f = Instance.new("Frame")
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.BorderSizePixel = 0
    f.Size = UDim2.new(0, 1, 0, thickness or 2)
    f.Visible = false
    f.Active = false
    f.ZIndex = 12
    f.Parent = EspOverlay
    return f
end

local function positionLineFrame(frame, p1, p2, color, thickness)
    local dx = p2.X - p1.X
    local dy = p2.Y - p1.Y
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist < 1 then
        frame.Visible = false
        return
    end
    local cx = (p1.X + p2.X) * 0.5
    local cy = (p1.Y + p2.Y) * 0.5
    local angle = math.deg(math.atan2(dy, dx))
    frame.Position = UDim2.new(0, cx, 0, cy)
    frame.Size = UDim2.new(0, dist, 0, thickness or 2)
    frame.Rotation = angle
    frame.BackgroundColor3 = color
    frame.Visible = true
end

AddToggle(ESPTab, "Enemy Chams", false, function(v)
    State.Chams = v
end)

AddToggle(ESPTab, "Crosshair Tracers (Torso)", false, function(v)
    State.Tracers = v
end)

AddToggle(ESPTab, "Box ESP", false, function(v)
    State.BoxEsp = v
end)

AddToggle(ESPTab, "Top Line (Desde Arriba)", false, function(v)
    State.TopLine = v
end)

AddToggle(ESPTab, "Player Marker", false, function(v)
    State.Marker = v
end)

local function createEspForPlayer(plr)
    if plr == LocalPlayer or espObjects[plr] then return end
    local thick = IsMobile and 2 or 1.6

    local tracerUi = makeLineFrame(thick)
    local topLineUi = makeLineFrame(thick)

    local boxUi = Instance.new("Frame")
    boxUi.BackgroundTransparency = 1
    boxUi.BorderSizePixel = 0
    boxUi.Visible = false
    boxUi.Active = false
    boxUi.ZIndex = 12
    boxUi.Parent = EspOverlay

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Thickness = thick
    boxStroke.Color = Color3.fromRGB(255, 50, 75)
    boxStroke.Parent = boxUi

    local markerUi = Instance.new("Frame")
    markerUi.AnchorPoint = Vector2.new(0.5, 0.5)
    markerUi.Size = UDim2.new(0, IsMobile and 12 or 10, 0, IsMobile and 12 or 10)
    markerUi.BackgroundColor3 = Color3.fromRGB(255, 50, 75)
    markerUi.BorderSizePixel = 0
    markerUi.Visible = false
    markerUi.Active = false
    markerUi.ZIndex = 13
    markerUi.Parent = EspOverlay

    local mCorner = Instance.new("UICorner")
    mCorner.CornerRadius = UDim.new(1, 0)
    mCorner.Parent = markerUi

    espObjects[plr] = {
        tracerUi = tracerUi,
        topLineUi = topLineUi,
        boxUi = boxUi,
        boxStroke = boxStroke,
        markerUi = markerUi,
        thick = thick
    }
end

local function hideEspData(data)
    if not data then return end
    data.tracerUi.Visible = false
    data.topLineUi.Visible = false
    data.boxUi.Visible = false
    data.markerUi.Visible = false
end

local function removeEspForPlayer(plr)
    local data = espObjects[plr]
    if data then
        pcall(function()
            data.tracerUi:Destroy()
            data.topLineUi:Destroy()
            data.boxUi:Destroy()
            data.markerUi:Destroy()
        end)
        espObjects[plr] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do
    createEspForPlayer(p)
end
Players.PlayerAdded:Connect(createEspForPlayer)
Players.PlayerRemoving:Connect(removeEspForPlayer)

--------------------------------------------------
-- 🔥 MOTOR PRINCIPAL
--------------------------------------------------
local activeTargetPos = nil

RunService.RenderStepped:Connect(function(dt)
    local pulse = (math.sin(tick() * 3) + 1) * 0.5
    local redAccent = Color3.fromRGB(255, math.floor(35 + pulse * 45), math.floor(55 + pulse * 45))

    local vp = Camera.ViewportSize
    local screenCenter = vp * 0.5
    local topCenter = Vector2.new(vp.X * 0.5, 0)

    WinStroke.Color = redAccent
    qStroke.Color = redAccent

    -- Partículas cayendo estrictamente dentro de MainWindow
    MenuParticlesBox.Visible = State.Particles and MainWindow.Visible
    if State.Particles and MainWindow.Visible then
        local boxW = math.max(MenuParticlesBox.AbsoluteSize.X, 10)
        local boxH = math.max(MenuParticlesBox.AbsoluteSize.Y, 10)

        for _, p in ipairs(menuParticles) do
            local pos = p.obj.Position
            local x = pos.X.Offset
            local y = pos.Y.Offset

            y += p.speedY * dt
            x += math.sin(tick() * 2.2 + p.phase) * p.sway * dt
            x = math.clamp(x, 4, boxW - 8)

            if y > boxH + 4 then
                y = -math.random(6, 24)
                x = math.random(4, math.max(8, boxW - 8))
            end

            p.obj.Position = UDim2.new(0, x, 0, y)
            p.obj.BackgroundColor3 = redAccent
        end
    end

    -- Círculo FOV
    fovCircle.Visible = State.FovEnabled
    if State.FovEnabled then
        fovCircle.Size = UDim2.new(0, calculatedRadius * 2, 0, calculatedRadius * 2)
        fovStroke.Color = redAccent
    end

    local bestHead = nil
    local shortestDist = 9e9

    for _, plr in pairs(Players:GetPlayers()) do
        local data = espObjects[plr]
        local char = plr.Character

        if data and char and isEnemy(plr) then
            local head = char:FindFirstChild("Head")
            local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
            local hrp = char:FindFirstChild("HumanoidRootPart") or torso
            local highlight = char:FindFirstChild("Highlight")

            if State.Chams and not highlight then
                highlight = Instance.new("Highlight")
                highlight.Parent = char
            end

            if head and torso and hrp then
                local distFromMe = (head.Position - Camera.CFrame.Position).Magnitude
                local inRange = distFromMe <= State.MaxDistance
                local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.55, 0))
                local footPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.8, 0))
                local torsoPos, torsoOnScreen = Camera:WorldToViewportPoint(torso.Position)
                local fovDist = (Vector2.new(headPos.X, headPos.Y) - screenCenter).Magnitude

                if highlight then
                    highlight.Enabled = State.Chams
                    highlight.FillColor = redAccent
                    highlight.OutlineColor = Color3.fromRGB(255, 225, 230)
                end

                if State.Tracers and torsoOnScreen and inRange then
                    positionLineFrame(data.tracerUi, screenCenter, Vector2.new(torsoPos.X, torsoPos.Y), redAccent, data.thick)
                else
                    data.tracerUi.Visible = false
                end

                if State.TopLine and headOnScreen and inRange then
                    positionLineFrame(data.topLineUi, topCenter, Vector2.new(headPos.X, headPos.Y), redAccent, data.thick)
                else
                    data.topLineUi.Visible = false
                end

                if State.BoxEsp and headOnScreen and inRange then
                    local boxHeight = math.clamp(math.abs(footPos.Y - headPos.Y), 16, 340)
                    local boxWidth = math.clamp(boxHeight * 0.58, 12, 230)
                    data.boxUi.Size = UDim2.new(0, boxWidth, 0, boxHeight)
                    data.boxUi.Position = UDim2.new(0, headPos.X - boxWidth * 0.5, 0, headPos.Y)
                    data.boxStroke.Color = redAccent
                    data.boxUi.Visible = true
                else
                    data.boxUi.Visible = false
                end

                if State.Marker and headOnScreen and inRange then
                    data.markerUi.Position = UDim2.new(0, headPos.X, 0, math.max(10, headPos.Y - 10))
                    data.markerUi.BackgroundColor3 = redAccent
                    data.markerUi.Visible = true
                else
                    data.markerUi.Visible = false
                end

                if headOnScreen and inRange then
                    if State.SoftLock then
                        if fovDist <= calculatedRadius and fovDist < shortestDist then
                            local valid = getValidHead(char)
                            if valid then
                                shortestDist = fovDist
                                bestHead = valid
                            end
                        end
                    elseif State.SilentAim then
                        if fovDist < shortestDist then
                            local valid = getValidHead(char)
                            if valid then
                                shortestDist = fovDist
                                bestHead = valid
                            end
                        end
                    end
                end
            else
                hideEspData(data)
            end
        else
            hideEspData(data)
        end
    end

    activeTargetPos = bestHead and bestHead.Position or nil
end)

local old
old = hookmetamethod(game, "__index", newcclosure(function(self, idx)
    if (State.SilentAim or State.SoftLock) and activeTargetPos and not checkcaller() and idx == "ViewportSize" and self == Camera then
        local pos, on = Camera:WorldToViewportPoint(activeTargetPos)
        if on then
            return Vector2.new(pos.X * 2, pos.Y * 2)
        end
    end
    return old(self, idx)
end))

--------------------------------------------------
-- ⚙️ PESTAÑA: VISUALES Y RENDIMIENTO
--------------------------------------------------
local VisualTab = CreateTab("Visuales")
AddSection(VisualTab, "Comunidad y Estilo")

AddButton(VisualTab, "Canal WhatsApp KING GAEL (Copiar)", function()
    if CopyToClipboard(WHATSAPP_CHANNEL_URL) then
        Notify("KING GAEL • WhatsApp", "Enlace copiado al portapapeles.", 3.2)
    else
        Notify("KING GAEL • WhatsApp", WHATSAPP_CHANNEL_URL, 5)
    end
end)

AddButton(VisualTab, "Mostrar Tarjeta de WhatsApp", function()
    WaBanner.Visible = true
end)

AddToggle(VisualTab, "Menu Particles", true, function(v)
    State.Particles = v
end)

AddToggle(VisualTab, "Quick Button", true, function(v)
    State.QuickBtn = v
    QuickBtn.Visible = v
end)

AddSection(VisualTab, "Iluminación y Rendimiento")

AddToggle(VisualTab, "Fullbright", false, function(v)
    State.Fullbright = v
    Lighting.Brightness = v and 2 or 1
    Lighting.ClockTime = v and 14 or 12
    Lighting.GlobalShadows = not v
end)

AddButton(VisualTab, "EXTREME FPS BOOST", function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsAncestorOf(LocalPlayer.Character) then
            v.Material = Enum.Material.SmoothPlastic
        elseif v:IsA("Texture") or v:IsA("Decal") then
            v:Destroy()
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Explosion") then
            v.Enabled = false
        end
    end

    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostProcessEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") then
            v.Enabled = false
        end
    end

    Notify("KING GAEL • FPS Boost", "Texturas, VFX y post-procesado optimizados.", 3.5)
end)

Notify("KING GAEL", IsMobile and "Menú cristal rojo PRO cargado en móvil." or "Menú cristal rojo PRO cargado.", 3.5)
