

-- Notificaciones cristalinas
local NotifyHolder = Instance.new("Frame")
NotifyHolder.Name = "Notifications"
NotifyHolder.AnchorPoint = Vector2.new(1, 1)
NotifyHolder.Position = UDim2.new(1, -18, 1, -18)
NotifyHolder.Size = UDim2.new(0, IsMobile and 245 or 305, 0, 230)
NotifyHolder.BackgroundTransparency = 1
NotifyHolder.ZIndex = 130
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
    card.Size = UDim2.new(1, 0, 0, 60)
    card.BackgroundColor3 = Color3.fromRGB(10, 15, 26)
    card.BackgroundTransparency = 0.18
    card.BorderSizePixel = 0
    card.ZIndex = 131
    card.Parent = NotifyHolder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 13)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.3
    stroke.Transparency = 0.25
    stroke.Color = Color3.fromRGB(115, 215, 255)
    stroke.Parent = card

    local tLbl = Instance.new("TextLabel")
    tLbl.Position = UDim2.new(0, 13, 0, 8)
    tLbl.Size = UDim2.new(1, -26, 0, 18)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = title
    tLbl.TextColor3 = Color3.fromRGB(245, 250, 255)
    tLbl.Font = Enum.Font.GothamBlack
    tLbl.TextSize = 13
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.ZIndex = 132
    tLbl.Parent = card

    local bLbl = Instance.new("TextLabel")
    bLbl.Position = UDim2.new(0, 13, 0, 27)
    bLbl.Size = UDim2.new(1, -26, 0, 26)
    bLbl.BackgroundTransparency = 1
    bLbl.Text = text
    bLbl.TextColor3 = Color3.fromRGB(190, 215, 240)
    bLbl.Font = Enum.Font.GothamMedium
    bLbl.TextSize = 11
    bLbl.TextXAlignment = Enum.TextXAlignment.Left
    bLbl.TextWrapped = true
    bLbl.ZIndex = 132
    bLbl.Parent = card

    task.delay(duration, function()
        if card and card.Parent then
            local tw = TweenService:Create(card, TweenInfo.new(0.25), {BackgroundTransparency = 1})
            tw:Play()
            tw.Completed:Wait()
            card:Destroy()
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
            error("No clipboard API")
        end
    end)
    return ok
end

-- Ventana principal estilo cristal
local winW = IsMobile and math.clamp(Camera.ViewportSize.X * 0.89, 330, 490) or 585
local winH = IsMobile and math.clamp(Camera.ViewportSize.Y * 0.8, 270, 370) or 400

local MainWindow = Instance.new("Frame")
MainWindow.Name = "King_Gael_MainWindow"
MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
MainWindow.Size = UDim2.new(0, winW, 0, winH)
MainWindow.BackgroundColor3 = Color3.fromRGB(10, 14, 24)
MainWindow.BackgroundTransparency = 0.2
MainWindow.BorderSizePixel = 0
MainWindow.ClipsDescendants = true
MainWindow.Active = true
MainWindow.Parent = ScreenGui

local WinCorner = Instance.new("UICorner")
WinCorner.CornerRadius = UDim.new(0, 18)
WinCorner.Parent = MainWindow

local WinStroke = Instance.new("UIStroke")
WinStroke.Thickness = 1.7
WinStroke.Transparency = 0.18
WinStroke.Parent = MainWindow

local GlassGradient = Instance.new("UIGradient")
GlassGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(175, 215, 250)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(95, 135, 185))
})
GlassGradient.Rotation = 125
GlassGradient.Parent = MainWindow

-- Partículas cayendo estrictamente dentro de MainWindow
local particlesEnabled = true
local MenuParticlesBox = Instance.new("Frame")
MenuParticlesBox.Name = "InsideMenuParticles"
MenuParticlesBox.Size = UDim2.new(1, 0, 1, 0)
MenuParticlesBox.Position = UDim2.new(0, 0, 0, 0)
MenuParticlesBox.BackgroundTransparency = 1
MenuParticlesBox.BorderSizePixel = 0
MenuParticlesBox.ClipsDescendants = true
MenuParticlesBox.ZIndex = 2
MenuParticlesBox.Active = false
MenuParticlesBox.Parent = MainWindow

local menuParticles = {}
local particleTotal = IsMobile and 26 or 44

for i = 1, particleTotal do
    local pFrame = Instance.new("Frame")
    local sz = math.random(3, 7)
    pFrame.Size = UDim2.new(0, sz, 0, sz)
    pFrame.Position = UDim2.new(0, math.random(4, math.max(8, winW - 8)), 0, -math.random(6, winH))
    pFrame.BackgroundTransparency = math.random(22, 62) / 100
    pFrame.BorderSizePixel = 0
    pFrame.ZIndex = 2
    pFrame.Active = false
    pFrame.Parent = MenuParticlesBox

    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(1, 0)
    pCorner.Parent = pFrame

    table.insert(menuParticles, {
        obj = pFrame,
        speedY = math.random(32, 84),
        sway = math.random(10, 24),
        phase = math.random() * math.pi * 2
    })
end

-- Header cristalino
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 46)
Header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Header.BackgroundTransparency = 0.91
Header.BorderSizePixel = 0
Header.ZIndex = 5
Header.Parent = MainWindow

local HeaderLine = Instance.new("Frame")
HeaderLine.AnchorPoint = Vector2.new(0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, 0)
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HeaderLine.BackgroundTransparency = 0.76
HeaderLine.BorderSizePixel = 0
HeaderLine.ZIndex = 5
HeaderLine.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.Size = UDim2.new(0, 130, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "𝐊𝐢𝐧𝐠 𝐆𝐚𝐞𝐥"
TitleLabel.TextColor3 = Color3.fromRGB(248, 252, 255)
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = IsMobile and 16 or 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 6
TitleLabel.Parent = Header

local SubTag = Instance.new("TextLabel")
SubTag.Position = UDim2.new(0, 128, 0, 1)
SubTag.Size = UDim2.new(0, 180, 1, 0)
SubTag.BackgroundTransparency = 1
SubTag.Text = IsMobile and "GLASS • MOBILE EDITION" or "GLASS • PRO EDITION"
SubTag.TextColor3 = Color3.fromRGB(135, 215, 255)
SubTag.Font = Enum.Font.GothamBold
SubTag.TextSize = 10
SubTag.TextXAlignment = Enum.TextXAlignment.Left
SubTag.ZIndex = 6
SubTag.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.AnchorPoint = Vector2.new(1, 0.5)
CloseBtn.Position = UDim2.new(1, -12, 0.5, 0)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundTransparency = 0.86
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.ZIndex = 6
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

-- Arrastrar ventana (Mouse + Touch)
do
    local dragging = false
    local dragInput, dragStart, startPos

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainWindow.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainWindow.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Barra lateral y contenedor
local sideW = IsMobile and 106 or 136
local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.new(0, 0, 0, 46)
Sidebar.Size = UDim2.new(0, sideW, 1, -46)
Sidebar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Sidebar.BackgroundTransparency = 0.95
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 4
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
ContentHolder.Position = UDim2.new(0, sideW + 8, 0, 54)
ContentHolder.Size = UDim2.new(1, -(sideW + 16), 1, -62)
ContentHolder.BackgroundTransparency = 1
ContentHolder.ZIndex = 4
ContentHolder.Parent = MainWindow

local tabs = {}

local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, IsMobile and 34 or 36)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.92
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(190, 212, 238)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = IsMobile and 12 or 13
    btn.ZIndex = 5
    btn.Parent = Sidebar

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 10)
    bCorner.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(145, 215, 255)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 5
    page.Parent = ContentHolder

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingBottom = UDim.new(0, 8)
    pad.Parent = page

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.page.Visible = false
            t.btn.BackgroundTransparency = 0.92
            t.btn.TextColor3 = Color3.fromRGB(190, 212, 238)
        end
        page.Visible = true
        btn.BackgroundTransparency = 0.7
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    table.insert(tabs, {btn = btn, page = page})
    if #tabs == 1 then
        page.Visible = true
        btn.BackgroundTransparency = 0.7
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    return page
end

local function AddSection(page, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(text)
    lbl.TextColor3 = Color3.fromRGB(130, 208, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 6
    lbl.Parent = page
end

local function AddToggle(page, text, defaultVal, callback)
    local state = defaultVal or false
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    row.BackgroundTransparency = 0.9
    row.BorderSizePixel = 0
    row.ZIndex = 6
    row.Parent = page

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 11)
    rCorner.Parent = row

    local rStroke = Instance.new("UIStroke")
    rStroke.Thickness = 1
    rStroke.Transparency = 0.74
    rStroke.Color = Color3.fromRGB(220, 242, 255)
    rStroke.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.Size = UDim2.new(1, -68, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(242, 249, 255)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = IsMobile and 12 or 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 7
    lbl.Parent = row

    local pill = Instance.new("TextButton")
    pill.AnchorPoint = Vector2.new(1, 0.5)
    pill.Position = UDim2.new(1, -10, 0.5, 0)
    pill.Size = UDim2.new(0, 44, 0, 22)
    pill.BackgroundColor3 = state and Color3.fromRGB(65, 190, 255) or Color3.fromRGB(45, 55, 75)
    pill.BackgroundTransparency = state and 0.14 or 0.45
    pill.Text = state and "ON" or "OFF"
    pill.TextColor3 = Color3.fromRGB(255, 255, 255)
    pill.Font = Enum.Font.GothamBold
    pill.TextSize = 10
    pill.ZIndex = 7
    pill.Parent = row

    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(1, 0)
    pCorner.Parent = pill

    local function setVal(v)
        state = v
        pill.Text = state and "ON" or "OFF"
        pill.BackgroundColor3 = state and Color3.fromRGB(65, 190, 255) or Color3.fromRGB(45, 55, 75)
        pill.BackgroundTransparency = state and 0.14 or 0.45
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
    row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    row.BackgroundTransparency = 0.9
    row.BorderSizePixel = 0
    row.ZIndex = 6
    row.Parent = page

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 11)
    rCorner.Parent = row

    local rStroke = Instance.new("UIStroke")
    rStroke.Thickness = 1
    rStroke.Transparency = 0.74
    rStroke.Color = Color3.fromRGB(220, 242, 255)
    rStroke.Parent = row

    local topLbl = Instance.new("TextLabel")
    topLbl.Position = UDim2.new(0, 12, 0, 5)
    topLbl.Size = UDim2.new(1, -24, 0, 18)
    topLbl.BackgroundTransparency = 1
    topLbl.Text = string.format("%s: %s%s", text, tostring(val), suffix or "")
    topLbl.TextColor3 = Color3.fromRGB(242, 249, 255)
    topLbl.Font = Enum.Font.GothamMedium
    topLbl.TextSize = IsMobile and 12 or 12.5
    topLbl.TextXAlignment = Enum.TextXAlignment.Left
    topLbl.ZIndex = 7
    topLbl.Parent = row

    local barBg = Instance.new("Frame")
    barBg.Position = UDim2.new(0, 12, 0, 29)
    barBg.Size = UDim2.new(1, -24, 0, 8)
    barBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    barBg.BackgroundTransparency = 0.82
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 7
    barBg.Parent = row

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = barBg

    local initRatio = math.clamp((val - minV) / (maxV - minV), 0, 1)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(initRatio, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(110, 208, 255)
    fill.BorderSizePixel = 0
    fill.ZIndex = 8
    fill.Parent = barBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local sliding = false
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
            sliding = true
            updateFromX(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
end

local function AddButton(page, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(85, 190, 255)
    btn.BackgroundTransparency = 0.22
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = IsMobile and 12.5 or 13
    btn.ZIndex = 7
    btn.Parent = page

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 11)
    bCorner.Parent = btn

    local bStroke = Instance.new("UIStroke")
    bStroke.Thickness = 1.2
    bStroke.Transparency = 0.3
    bStroke.Color = Color3.fromRGB(225, 245, 255)
    bStroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

-- Tarjeta de invitación al canal de 𝐊𝐢𝐧𝐠 𝐆𝐚𝐞𝐥 en WhatsApp
local WaBanner = Instance.new("Frame")
WaBanner.Name = "WhatsAppInviteCard"
WaBanner.AnchorPoint = Vector2.new(0.5, 0.5)
WaBanner.Position = UDim2.new(0.5, 0, 0.5, 0)
WaBanner.Size = UDim2.new(0, IsMobile and 300 or 365, 0, 184)
WaBanner.BackgroundColor3 = Color3.fromRGB(11, 20, 30)
WaBanner.BackgroundTransparency = 0.1
WaBanner.BorderSizePixel = 0
WaBanner.Visible = SHOW_WHATSAPP_ON_OPEN
WaBanner.ZIndex = 70
WaBanner.Parent = MainWindow

local WaCorner = Instance.new("UICorner")
WaCorner.CornerRadius = UDim.new(0, 16)
WaCorner.Parent = WaBanner

local WaStroke = Instance.new("UIStroke")
WaStroke.Thickness = 1.6
WaStroke.Color = Color3.fromRGB(55, 225, 125)
WaStroke.Parent = WaBanner

local WaTitle = Instance.new("TextLabel")
WaTitle.Position = UDim2.new(0, 16, 0, 14)
WaTitle.Size = UDim2.new(1, -32, 0, 22)
WaTitle.BackgroundTransparency = 1
WaTitle.Text = "Sigue el canal de 𝐊𝐢𝐧𝐠 𝐆𝐚𝐞𝐥"
WaTitle.TextColor3 = Color3.fromRGB(115, 250, 168)
WaTitle.Font = Enum.Font.GothamBlack
WaTitle.TextSize = IsMobile and 13.5 or 15
WaTitle.TextXAlignment = Enum.TextXAlignment.Left
WaTitle.ZIndex = 71
WaTitle.Parent = WaBanner

local WaDesc = Instance.new("TextLabel")
WaDesc.Position = UDim2.new(0, 16, 0, 38)
WaDesc.Size = UDim2.new(1, -32, 0, 38)
WaDesc.BackgroundTransparency = 1
WaDesc.Text = "Únete al canal oficial de WhatsApp para novedades, scripts y actualizaciones de 𝐊𝐢𝐧𝐠 𝐆𝐚𝐞𝐥."
WaDesc.TextColor3 = Color3.fromRGB(228, 240, 250)
WaDesc.Font = Enum.Font.Gotham
WaDesc.TextSize = IsMobile and 11 or 12
WaDesc.TextXAlignment = Enum.TextXAlignment.Left
WaDesc.TextWrapped = true
WaDesc.ZIndex = 71
WaTitle.ZIndex = 71
WaBanner.ZIndex = 70
WaDesc.Parent = WaBanner

local WaLinkBox = Instance.new("TextBox")
WaLinkBox.Position = UDim2.new(0, 16, 0, 82)
WaLinkBox.Size = UDim2.new(1, -32, 0, 30)
WaLinkBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
WaLinkBox.BackgroundTransparency = 0.9
WaLinkBox.Text = WHATSAPP_CHANNEL_URL
WaLinkBox.TextColor3 = Color3.fromRGB(165, 245, 198)
WaLinkBox.Font = Enum.Font.GothamMedium
WaLinkBox.TextSize = IsMobile and 10 or 11
WaLinkBox.ClearTextOnFocus = false
WaLinkBox.TextEditable = false
WaLinkBox.ZIndex = 71
WaLinkBox.Parent = WaBanner

local WaBoxCorner = Instance.new("UICorner")
WaBoxCorner.CornerRadius = UDim.new(0, 8)
WaBoxCorner.Parent = WaLinkBox

local CopyWaBtn = Instance.new("TextButton")
CopyWaBtn.Position = UDim2.new(0, 16, 1, -46)
CopyWaBtn.Size = UDim2.new(0.56, -20, 0, 34)
CopyWaBtn.BackgroundColor3 = Color3.fromRGB(37, 211, 102)
CopyWaBtn.BackgroundTransparency = 0.12
CopyWaBtn.Text = "Copiar Canal"
CopyWaBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyWaBtn.Font = Enum.Font.GothamBold
CopyWaBtn.TextSize = 12
CopyWaBtn.ZIndex = 71
CopyWaBtn.Parent = WaBanner

local CopyWaCorner = Instance.new("UICorner")
CopyWaCorner.CornerRadius = UDim.new(0, 10)
CopyWaCorner.Parent = CopyWaBtn

local CloseWaBtn = Instance.new("TextButton")
CloseWaBtn.Position = UDim2.new(0.56, 4, 1, -46)
CloseWaBtn.Size = UDim2.new(0.44, -20, 0, 34)
CloseWaBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseWaBtn.BackgroundTransparency = 0.86
CloseWaBtn.Text = "Entrar al Menú"
CloseWaBtn.TextColor3 = Color3.fromRGB(238, 246, 255)
CloseWaBtn.Font = Enum.Font.GothamBold
CloseWaBtn.TextSize = 11.5
CloseWaBtn.ZIndex = 71
CloseWaBtn.Parent = WaBanner

local CloseWaCorner = Instance.new("UICorner")
CloseWaCorner.CornerRadius = UDim.new(0, 10)
CloseWaCorner.Parent = CloseWaBtn

CopyWaBtn.MouseButton1Click:Connect(function()
    if CopyToClipboard(WHATSAPP_CHANNEL_URL) then
        Notify("𝐊𝐢𝐧𝐠 𝐆𝐚𝐞𝐥 • WhatsApp", "Enlace del canal copiado al portapapeles.", 3.2)
    else
        Notify("𝐊𝐢𝐧𝐠 𝐆𝐚𝐞𝐥 • WhatsApp", WHATSAPP_CHANNEL_URL, 5)
    end
end)

CloseWaBtn.MouseButton1Click:Connect(function()
    WaBanner.Visible = false
end)

-- Botón flotante para reabrir / alternar menú (móvil y PC)
local QuickBtn = Instance.new("TextButton")
QuickBtn.Name = "King_Gael_Toggle"
QuickBtn.Size = IsMobile and UDim2.new(0, 88, 0, 34) or UDim2.new(0, 84, 0, 30)
QuickBtn.Position = IsMobile and UDim2.new(0, 14, 0.5, -17) or UDim2.new(0, 14, 0, 14)
QuickBtn.BackgroundColor3 = Color3.fromRGB(12, 16, 28)
QuickBtn.BackgroundTransparency = 0.22
QuickBtn.Text = "𝐊𝐢𝐧𝐠 𝐆𝐚𝐞𝐥"
QuickBtn.TextColor3 = Color3.fromRGB(245, 250, 255)
QuickBtn.Font = Enum.Font.GothamBold
QuickBtn.TextSize = IsMobile and 12 or 11.5
QuickBtn.Visible = true
QuickBtn.ZIndex = 115
QuickBtn.Parent = ScreenGui

local qCorner = Instance.new("UICorner")
qCorner.CornerRadius = UDim.new(0, 10)
qCorner.Parent = QuickBtn

local qStroke = Instance.new("UIStroke")
qStroke.Thickness = 1.4
qStroke.Transparency = 0.22
qStroke.Parent = QuickBtn

local function ToggleWindow(forceState)
    local nextState = (forceState ~= nil) and forceState or (not MainWindow.Visible)
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

local flying, infiniteJump, noclip = false, false, false

local function Fly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Parent = hrp

    while flying do
        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end
        bv.Velocity = move * 60
        task.wait()
    end

    if bv and bv.Parent then
        bv:Destroy()
    end
end

UIS.JumpRequest:Connect(function()
    if infiniteJump then
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then
            h:ChangeState("Jumping")
        end
    end
end)

RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

AddToggle(PlayerTab, "Fly", false, function(v)
    flying = v
    if v then task.spawn(Fly) end
end)

AddToggle(PlayerTab, "Infinite Jump", false, function(v)
    infiniteJump = v
end)

AddToggle(PlayerTab, "Noclip", false, function(v)
    noclip = v
end)

AddSlider(PlayerTab, "WalkSpeed", 16, 200, 1, 16, " WS", function(v)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)

--------------------------------------------------
-- ⚔️ PESTAÑA: COMBATE
--------------------------------------------------
local CombatTab = CreateTab("Combate")
AddSection(CombatTab, "Apuntado y Objetivos")

local maxDistance = 500
getgenv().SilentAimEnabled = false
getgenv().SoftLockEnabled = false
local fovEnabled = false
local fovScale = IsMobile and 48 or 60
local calculatedRadius = 3 * fovScale

AddToggle(CombatTab, "Silent Aim (Full Range)", false, function(v)
    getgenv().SilentAimEnabled = v
end)

AddToggle(CombatTab, "Soft Lock (FOV Only)", false, function(v)
    getgenv().SoftLockEnabled = v
end)

AddSlider(CombatTab, "Max Distance", 100, 2000, 50, 500, " studs", function(v)
    maxDistance = v
end)

AddSection(CombatTab, "Configuración FOV")

AddToggle(CombatTab, "Show FOV Circle", false, function(v)
    fovEnabled = v
end)

AddSlider(CombatTab, "FOV Level (1-10)", 1, 10, 1, 3, "x", function(v)
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
fovStroke.Parent = fovCircle

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

--------------------------------------------------
-- 👁️ PESTAÑA: ESP
--------------------------------------------------
local ESPTab = CreateTab("ESP")
AddSection(ESPTab, "Visuales Enemigos")

local chamsEnabled = false
local tracersEnabled = false
local boxEnabled = false
local topLineEnabled = false
local markerEnabled = false

local espObjects = {}

AddToggle(ESPTab, "Enemy Chams", false, function(v)
    chamsEnabled = v
end)

AddToggle(ESPTab, "Crosshair Tracers (Torso)", false, function(v)
    tracersEnabled = v
end)

AddToggle(ESPTab, "Box ESP", false, function(v)
    boxEnabled = v
end)

AddToggle(ESPTab, "Top Line (Desde Arriba)", false, function(v)
    topLineEnabled = v
end)

AddToggle(ESPTab, "Player Marker", false, function(v)
    markerEnabled = v
end)

local function createEspForPlayer(plr)
    if plr == LocalPlayer or espObjects[plr] then return end

    local tracer = Drawing.new("Line")
    tracer.Thickness = IsMobile and 2 or 1.5
    tracer.Transparency = 1
    tracer.Visible = false

    local topLine = Drawing.new("Line")
    topLine.Thickness = IsMobile and 2 or 1.5
    topLine.Transparency = 1
    topLine.Visible = false

    local box = Drawing.new("Square")
    box.Thickness = IsMobile and 2 or 1.5
    box.Filled = false
    box.Transparency = 1
    box.Visible = false

    local marker = Drawing.new("Circle")
    marker.Thickness = 2
    marker.NumSides = 16
    marker.Radius = IsMobile and 6 or 5
    marker.Filled = true
    marker.Transparency = 1
    marker.Visible = false

    espObjects[plr] = {
        tracer = tracer,
        topLine = topLine,
        box = box,
        marker = marker
    }
end

local function removeEspForPlayer(plr)
    local data = espObjects[plr]
    if data then
        for _, obj in pairs(data) do
            pcall(function()
                obj.Visible = false
                obj:Remove()
            end)
        end
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
    local rgb = Color3.fromHSV((tick() % 5) / 5, 1, 1)
    local vp = Camera.ViewportSize
    local screenCenter = vp / 2
    local topCenter = Vector2.new(vp.X / 2, 0)

    WinStroke.Color = rgb
    qStroke.Color = rgb

    -- Partículas cayendo estrictamente dentro de MainWindow
    MenuParticlesBox.Visible = particlesEnabled and MainWindow.Visible
    if particlesEnabled and MainWindow.Visible then
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
            p.obj.BackgroundColor3 = rgb
        end
    end

    -- Círculo FOV
    fovCircle.Visible = fovEnabled
    if fovEnabled then
        fovCircle.Size = UDim2.new(0, calculatedRadius * 2, 0, calculatedRadius * 2)
        fovStroke.Color = rgb
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
            local highlight = char:FindFirstChild("Highlight") or Instance.new("Highlight", char)

            if head and torso and hrp then
                local distFromMe = (head.Position - Camera.CFrame.Position).Magnitude
                local inRange = distFromMe <= maxDistance
                local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.55, 0))
                local footPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.8, 0))
                local torsoPos, torsoOnScreen = Camera:WorldToViewportPoint(torso.Position)
                local fovDist = (Vector2.new(headPos.X, headPos.Y) - screenCenter).Magnitude

                highlight.Enabled = chamsEnabled
                highlight.FillColor = rgb
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)

                data.tracer.Visible = (tracersEnabled and torsoOnScreen and inRange)
                if data.tracer.Visible then
                    data.tracer.From = screenCenter
                    data.tracer.To = Vector2.new(torsoPos.X, torsoPos.Y)
                    data.tracer.Color = rgb
                end

                data.topLine.Visible = (topLineEnabled and headOnScreen and inRange)
                if data.topLine.Visible then
                    data.topLine.From = topCenter
                    data.topLine.To = Vector2.new(headPos.X, headPos.Y)
                    data.topLine.Color = rgb
                end

                data.box.Visible = (boxEnabled and headOnScreen and inRange)
                if data.box.Visible then
                    local boxHeight = math.clamp(math.abs(footPos.Y - headPos.Y), 14, 320)
                    local boxWidth = math.clamp(boxHeight * 0.58, 10, 220)
                    data.box.Size = Vector2.new(boxWidth, boxHeight)
                    data.box.Position = Vector2.new(headPos.X - boxWidth / 2, headPos.Y)
                    data.box.Color = rgb
                end

                data.marker.Visible = (markerEnabled and headOnScreen and inRange)
                if data.marker.Visible then
                    data.marker.Position = Vector2.new(headPos.X, math.max(8, headPos.Y - 10))
                    data.marker.Color = rgb
                end

                if headOnScreen and inRange then
                    if getgenv().SoftLockEnabled then
                        if fovDist <= calculatedRadius and fovDist < shortestDist then
                            local valid = getValidHead(char)
                            if valid then
                                shortestDist = fovDist
                                bestHead = valid
                            end
                        end
                    elseif getgenv().SilentAimEnabled then
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
                data.tracer.Visible = false
                data.topLine.Visible = false
                data.box.Visible = false
                data.marker.Visible = false
            end
        elseif data then
            data.tracer.Visible = false
            data.topLine.Visible = false
            data.box.Visible = false
            data.marker.Visible = false
        end
    end

    activeTargetPos = bestHead and bestHead.Position or nil
end)

local old
old = hookmetamethod(game, "__index", newcclosure(function(self, idx)
    if (getgenv().SilentAimEnabled or getgenv().SoftLockEnabled) and activeTargetPos and not checkcaller() and idx == "ViewportSize" and self == Camera then
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

AddButton(VisualTab, "Canal WhatsApp 𝐊𝐢𝐧𝐠 𝐆𝐚𝐞𝐥 (Copiar)", function()
    if CopyToClipboard(WHATSAPP_CHANNEL_URL) then
        Notify("𝐊𝐢𝐧𝐠 𝐆𝐚𝐞𝐥 • WhatsApp", "Enlace copiado al portapapeles.", 3.2)
    else
        Notify("𝐊𝐢𝐧𝐠 𝐆𝐚𝐞𝐥 • WhatsApp", WHATSAPP_CHANNEL_URL, 5)
    end
end)

AddButton(VisualTab, "Mostrar Tarjeta de WhatsApp", function()
    WaBanner.Visible = true
end)

AddToggle(VisualTab, "Menu Particles", true, function(v)
    particlesEnabled = v
end)

AddToggle(VisualTab, "Quick Button", true, function(v)
    QuickBtn.Visible = v
end)

AddSection(VisualTab, "Iluminación y Rendimiento")

AddToggle(VisualTab, "Fullbright", false, function(v)
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

    Notify("𝐊𝐢𝐧𝐠 𝐆𝐚𝐞𝐥 • FPS Boost", "Texturas, VFX y post-procesado optimizados.", 3.5)
end)

Notify("𝐊𝐢𝐧𝐠 𝐆𝐚𝐞𝐥", IsMobile and "Menú cristal cargado en modo móvil." or "Menú cristal cargado correctamente.", 3.5)
