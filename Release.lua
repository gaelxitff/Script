--// SERVICIOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

local WHATSAPP_CHANNEL_URL = "https://whatsapp.com/channel/0029VbCHjR7LNSaCqoxB7P10"

local State = {
    MenuOpen = true,
    Particles = true,
    QuickBtn = true,
    Sounds = true,
    Fly = false,
    SpeedRun = false,
    SpeedRunValue = 48,
    InfiniteJump = false,
    Noclip = false,
    WalkSpeed = 16,
    RapidFire = false,
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

local ScreenGui, MainWindow, MenuParticlesBox, EspOverlay, WaBanner, QuickBtn, FovCircle, FovStroke
local Notify, PlayUiSound, CreateTab, AddSection, AddToggle, AddSlider, AddButton

--------------------------------------------------
-- 🔊 EFECTOS DE SONIDO AL ACTIVAR OPCIONES
--------------------------------------------------
do
    local sfxFolder = Instance.new("Folder")
    sfxFolder.Name = "KING_GAEL_SFX"
    sfxFolder.Parent = SoundService

    local toggleOnSound = Instance.new("Sound")
    toggleOnSound.Name = "ToggleOn"
    toggleOnSound.SoundId = "rbxassetid://6042053626"
    toggleOnSound.Volume = 0.55
    toggleOnSound.Parent = sfxFolder

    local toggleOffSound = Instance.new("Sound")
    toggleOffSound.Name = "ToggleOff"
    toggleOffSound.SoundId = "rbxassetid://6042053363"
    toggleOffSound.Volume = 0.45
    toggleOffSound.Parent = sfxFolder

    local clickSound = Instance.new("Sound")
    clickSound.Name = "ClickAction"
    clickSound.SoundId = "rbxassetid://6895079853"
    clickSound.Volume = 0.55
    clickSound.Parent = sfxFolder

    PlayUiSound = function(kind)
        if not State.Sounds then return end
        local target = (kind == "on" and toggleOnSound) or (kind == "off" and toggleOffSound) or clickSound
        pcall(function()
            target.TimePosition = 0
            target:Play()
        end)
    end
end

--------------------------------------------------
-- 🩸 UI CRISTAL ROJO PRO - KING GAEL
--------------------------------------------------
do
    local okRoot, root = pcall(function()
        return (gethui and gethui()) or game:GetService("CoreGui")
    end)
    local parent = (okRoot and root) or LocalPlayer:WaitForChild("PlayerGui")

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KING_GAEL_PRO_V5"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 200
    ScreenGui.Parent = parent

    EspOverlay = Instance.new("Frame")
    EspOverlay.Size = UDim2.new(1, 0, 1, 0)
    EspOverlay.BackgroundTransparency = 1
    EspOverlay.Active = false
    EspOverlay.ZIndex = 10
    EspOverlay.Parent = ScreenGui

    local notifyHolder = Instance.new("Frame")
    notifyHolder.AnchorPoint = Vector2.new(1, 1)
    notifyHolder.Position = UDim2.new(1, -16, 1, -16)
    notifyHolder.Size = UDim2.new(0, IsMobile and 245 or 300, 0, 215)
    notifyHolder.BackgroundTransparency = 1
    notifyHolder.Active = false
    notifyHolder.ZIndex = 170
    notifyHolder.Parent = ScreenGui

    local nLayout = Instance.new("UIListLayout")
    nLayout.Padding = UDim.new(0, 7)
    nLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    nLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    nLayout.SortOrder = Enum.SortOrder.LayoutOrder
    nLayout.Parent = notifyHolder

    Notify = function(title, text, dur)
        dur = dur or 3.2
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 58)
        card.BackgroundColor3 = Color3.fromRGB(20, 7, 11)
        card.BackgroundTransparency = 0.14
        card.BorderSizePixel = 0
        card.ZIndex = 171
        card.Parent = notifyHolder

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 11)
        cCorner.Parent = card

        local cStroke = Instance.new("UIStroke")
        cStroke.Thickness = 1.25
        cStroke.Color = Color3.fromRGB(255, 60, 82)
        cStroke.Parent = card

        local tLbl = Instance.new("TextLabel")
        tLbl.Position = UDim2.new(0, 12, 0, 6)
        tLbl.Size = UDim2.new(1, -24, 0, 18)
        tLbl.BackgroundTransparency = 1
        tLbl.Text = title
        tLbl.TextColor3 = Color3.fromRGB(255, 242, 245)
        tLbl.Font = Enum.Font.GothamBlack
        tLbl.TextSize = 12.5
        tLbl.TextXAlignment = Enum.TextXAlignment.Left
        tLbl.ZIndex = 172
        tLbl.Parent = card

        local bLbl = Instance.new("TextLabel")
        bLbl.Position = UDim2.new(0, 12, 0, 25)
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

        task.delay(dur, function()
            if card and card.Parent then
                local tw = TweenService:Create(card, TweenInfo.new(0.22), {BackgroundTransparency = 1})
                tw:Play()
                tw.Completed:Wait()
                if card and card.Parent then card:Destroy() end
            end
        end)
    end

    local vp = Camera.ViewportSize
    local w = IsMobile and math.clamp(vp.X * 0.9, 330, 490) or 580
    local h = IsMobile and math.clamp(vp.Y * 0.82, 275, 370) or 400

    MainWindow = Instance.new("Frame")
    MainWindow.Name = "KING_GAEL_WINDOW"
    MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainWindow.Size = UDim2.new(0, w, 0, h)
    MainWindow.BackgroundColor3 = Color3.fromRGB(16, 5, 9)
    MainWindow.BackgroundTransparency = 0.18
    MainWindow.BorderSizePixel = 0
    MainWindow.ClipsDescendants = true
    MainWindow.Active = true
    MainWindow.ZIndex = 30
    MainWindow.Parent = ScreenGui

    local mCorner = Instance.new("UICorner")
    mCorner.CornerRadius = UDim.new(0, 16)
    mCorner.Parent = MainWindow

    local mStroke = Instance.new("UIStroke")
    mStroke.Thickness = 1.7
    mStroke.Color = Color3.fromRGB(255, 48, 72)
    mStroke.Parent = MainWindow

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 210)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(215, 55, 78)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 10, 22))
    })
    grad.Rotation = 125
    grad.Parent = MainWindow

    MenuParticlesBox = Instance.new("Frame")
    MenuParticlesBox.Size = UDim2.new(1, 0, 1, 0)
    MenuParticlesBox.BackgroundTransparency = 1
    MenuParticlesBox.BorderSizePixel = 0
    MenuParticlesBox.ClipsDescendants = true
    MenuParticlesBox.ZIndex = 31
    MenuParticlesBox.Active = false
    MenuParticlesBox.Parent = MainWindow

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 44)
    header.BackgroundColor3 = Color3.fromRGB(255, 45, 70)
    header.BackgroundTransparency = 0.84
    header.BorderSizePixel = 0
    header.ZIndex = 35
    header.Parent = MainWindow

    local title = Instance.new("TextLabel")
    title.Position = UDim2.new(0, 14, 0, 0)
    title.Size = UDim2.new(0.75, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "KING GAEL"
    title.TextColor3 = Color3.fromRGB(255, 245, 248)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = IsMobile and 16 or 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 36
    title.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.Position = UDim2.new(1, -12, 0.5, 0)
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 55, 80)
    closeBtn.BackgroundTransparency = 0.5
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 17
    closeBtn.ZIndex = 36
    closeBtn.Parent = header

    local clCorner = Instance.new("UICorner")
    clCorner.CornerRadius = UDim.new(1, 0)
    clCorner.Parent = closeBtn

    local drag = nil
    header.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            drag = {kind = "win", start = inp.Position, origin = MainWindow.Position}
        end
    end)

    UIS.InputChanged:Connect(function(inp)
        if not drag then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            if drag.kind == "win" then
                local d = inp.Position - drag.start
                MainWindow.Position = UDim2.new(drag.origin.X.Scale, drag.origin.X.Offset + d.X, drag.origin.Y.Scale, drag.origin.Y.Offset + d.Y)
            elseif drag.kind == "slider" and drag.fn then
                drag.fn(inp.Position.X)
            end
        end
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            drag = nil
        end
    end)

    local sideW = IsMobile and 106 or 136
    local sidebar = Instance.new("Frame")
    sidebar.Position = UDim2.new(0, 0, 0, 44)
    sidebar.Size = UDim2.new(0, sideW, 1, -44)
    sidebar.BackgroundColor3 = Color3.fromRGB(255, 50, 75)
    sidebar.BackgroundTransparency = 0.92
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 34
    sidebar.Parent = MainWindow

    local sList = Instance.new("UIListLayout")
    sList.Padding = UDim.new(0, 6)
    sList.SortOrder = Enum.SortOrder.LayoutOrder
    sList.Parent = sidebar

    local sPad = Instance.new("UIPadding")
    sPad.PaddingTop = UDim.new(0, 10)
    sPad.PaddingLeft = UDim.new(0, 8)
    sPad.PaddingRight = UDim.new(0, 8)
    sPad.Parent = sidebar

    local content = Instance.new("Frame")
    content.Position = UDim2.new(0, sideW + 8, 0, 52)
    content.Size = UDim2.new(1, -(sideW + 16), 1, -60)
    content.BackgroundTransparency = 1
    content.ZIndex = 34
    content.Parent = MainWindow

    local tabs = {}

    CreateTab = function(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, IsMobile and 33 or 35)
        btn.BackgroundColor3 = Color3.fromRGB(255, 50, 75)
        btn.BackgroundTransparency = 0.86
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(245, 195, 202)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = IsMobile and 12 or 13
        btn.ZIndex = 35
        btn.Parent = sidebar

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 9)
        bCorner.Parent = btn

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = Color3.fromRGB(255, 75, 95)
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        page.ZIndex = 35
        page.Parent = content

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 7)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = page

        local pad = Instance.new("UIPadding")
        pad.PaddingBottom = UDim.new(0, 8)
        pad.Parent = page

        local function openThis(playSfx)
            for _, t in pairs(tabs) do
                t.page.Visible = false
                t.btn.BackgroundColor3 = Color3.fromRGB(255, 50, 75)
                t.btn.BackgroundTransparency = 0.86
                t.btn.TextColor3 = Color3.fromRGB(245, 195, 202)
            end
            page.Visible = true
            btn.BackgroundColor3 = Color3.fromRGB(230, 32, 58)
            btn.BackgroundTransparency = 0.3
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            if playSfx and PlayUiSound then PlayUiSound("click") end
        end

        btn.MouseButton1Click:Connect(function() openThis(true) end)
        table.insert(tabs, {btn = btn, page = page})
        if #tabs == 1 then openThis(false) end
        return page
    end

    AddSection = function(page, text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text = string.upper(text)
        lbl.TextColor3 = Color3.fromRGB(255, 110, 130)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 36
        lbl.Parent = page
    end

    AddToggle = function(page, text, def, cb)
        local on = def or false
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 36)
        row.BackgroundColor3 = Color3.fromRGB(255, 65, 85)
        row.BackgroundTransparency = 0.88
        row.BorderSizePixel = 0
        row.ZIndex = 36
        row.Parent = page

        local rCorner = Instance.new("UICorner")
        rCorner.CornerRadius = UDim.new(0, 10)
        rCorner.Parent = row

        local lbl = Instance.new("TextLabel")
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.Size = UDim2.new(1, -66, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(255, 242, 245)
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = IsMobile and 12 or 12.5
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 37
        lbl.Parent = row

        local pill = Instance.new("TextButton")
        pill.AnchorPoint = Vector2.new(1, 0.5)
        pill.Position = UDim2.new(1, -10, 0.5, 0)
        pill.Size = UDim2.new(0, 42, 0, 21)
        pill.BackgroundColor3 = on and Color3.fromRGB(240, 35, 60) or Color3.fromRGB(48, 20, 28)
        pill.BackgroundTransparency = on and 0.15 or 0.35
        pill.Text = on and "ON" or "OFF"
        pill.TextColor3 = Color3.fromRGB(255, 255, 255)
        pill.Font = Enum.Font.GothamBold
        pill.TextSize = 10
        pill.ZIndex = 37
        pill.Parent = row

        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(1, 0)
        pCorner.Parent = pill

        pill.MouseButton1Click:Connect(function()
            on = not on
            pill.Text = on and "ON" or "OFF"
            pill.BackgroundColor3 = on and Color3.fromRGB(240, 35, 60) or Color3.fromRGB(48, 20, 28)
            pill.BackgroundTransparency = on and 0.15 or 0.35
            if PlayUiSound then PlayUiSound(on and "on" or "off") end
            if cb then cb(on) end
        end)
    end

    AddSlider = function(page, text, minV, maxV, step, def, suffix, cb)
        local val = def or minV
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 46)
        row.BackgroundColor3 = Color3.fromRGB(255, 65, 85)
        row.BackgroundTransparency = 0.88
        row.BorderSizePixel = 0
        row.ZIndex = 36
        row.Parent = page

        local rCorner = Instance.new("UICorner")
        rCorner.CornerRadius = UDim.new(0, 10)
        rCorner.Parent = row

        local topLbl = Instance.new("TextLabel")
        topLbl.Position = UDim2.new(0, 12, 0, 5)
        topLbl.Size = UDim2.new(1, -24, 0, 17)
        topLbl.BackgroundTransparency = 1
        topLbl.Text = string.format("%s: %s%s", text, tostring(val), suffix or "")
        topLbl.TextColor3 = Color3.fromRGB(255, 242, 245)
        topLbl.Font = Enum.Font.GothamMedium
        topLbl.TextSize = 12
        topLbl.TextXAlignment = Enum.TextXAlignment.Left
        topLbl.ZIndex = 37
        topLbl.Parent = row

        local barBg = Instance.new("Frame")
        barBg.Position = UDim2.new(0, 12, 0, 28)
        barBg.Size = UDim2.new(1, -24, 0, 7)
        barBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        barBg.BackgroundTransparency = 0.82
        barBg.BorderSizePixel = 0
        barBg.ZIndex = 37
        barBg.Parent = row

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(1, 0)
        bCorner.Parent = barBg

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(math.clamp((val - minV) / (maxV - minV), 0, 1), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(255, 55, 80)
        fill.BorderSizePixel = 0
        fill.ZIndex = 38
        fill.Parent = barBg

        local fCorner = Instance.new("UICorner")
        fCorner.CornerRadius = UDim.new(1, 0)
        fCorner.Parent = fill

        local function setFromX(xPos)
            local ratio = math.clamp((xPos - barBg.AbsolutePosition.X) / math.max(barBg.AbsoluteSize.X, 1), 0, 1)
            local snapped = math.clamp(math.floor(((minV + (maxV - minV) * ratio) / step) + 0.5) * step, minV, maxV)
            val = snapped
            fill.Size = UDim2.new((val - minV) / (maxV - minV), 0, 1, 0)
            topLbl.Text = string.format("%s: %s%s", text, tostring(val), suffix or "")
            if cb then cb(val) end
        end

        barBg.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                if PlayUiSound then PlayUiSound("click") end
                setFromX(inp.Position.X)
                drag = {kind = "slider", fn = setFromX}
            end
        end)
    end

    AddButton = function(page, text, cb)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 36)
        btn.BackgroundColor3 = Color3.fromRGB(220, 30, 55)
        btn.BackgroundTransparency = 0.22
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12.5
        btn.ZIndex = 37
        btn.Parent = page

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 10)
        bCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            if PlayUiSound then PlayUiSound("on") end
            if cb then cb() end
        end)
    end

    WaBanner = Instance.new("Frame")
    WaBanner.AnchorPoint = Vector2.new(0.5, 0.5)
    WaBanner.Position = UDim2.new(0.5, 0, 0.5, 0)
    WaBanner.Size = UDim2.new(0, IsMobile and 295 or 355, 0, 176)
    WaBanner.BackgroundColor3 = Color3.fromRGB(20, 7, 11)
    WaBanner.BackgroundTransparency = 0.08
    WaBanner.BorderSizePixel = 0
    WaBanner.Visible = true
    WaBanner.ZIndex = 80
    WaBanner.Parent = MainWindow

    local waCorner = Instance.new("UICorner")
    waCorner.CornerRadius = UDim.new(0, 15)
    waCorner.Parent = WaBanner

    local waStroke = Instance.new("UIStroke")
    waStroke.Thickness = 1.6
    waStroke.Color = Color3.fromRGB(255, 55, 80)
    waStroke.Parent = WaBanner

    local waTitle = Instance.new("TextLabel")
    waTitle.Position = UDim2.new(0, 14, 0, 12)
    waTitle.Size = UDim2.new(1, -28, 0, 20)
    waTitle.BackgroundTransparency = 1
    waTitle.Text = "Canal WhatsApp • KING GAEL"
    waTitle.TextColor3 = Color3.fromRGB(255, 115, 135)
    waTitle.Font = Enum.Font.GothamBlack
    waTitle.TextSize = 14
    waTitle.TextXAlignment = Enum.TextXAlignment.Left
    waTitle.ZIndex = 81
    waTitle.Parent = WaBanner

    local waDesc = Instance.new("TextLabel")
    waDesc.Position = UDim2.new(0, 14, 0, 34)
    waDesc.Size = UDim2.new(1, -28, 0, 34)
    waDesc.BackgroundTransparency = 1
    waDesc.Text = "Sigue el canal de KING GAEL en WhatsApp para actualizaciones y scripts."
    waDesc.TextColor3 = Color3.fromRGB(255, 235, 238)
    waDesc.Font = Enum.Font.Gotham
    waDesc.TextSize = 11.5
    waDesc.TextXAlignment = Enum.TextXAlignment.Left
    waDesc.TextWrapped = true
    waDesc.ZIndex = 81
    waDesc.Parent = WaBanner

    local waBox = Instance.new("TextBox")
    waBox.Position = UDim2.new(0, 14, 0, 74)
    waBox.Size = UDim2.new(1, -28, 0, 28)
    waBox.BackgroundColor3 = Color3.fromRGB(255, 55, 80)
    waBox.BackgroundTransparency = 0.85
    waBox.Text = WHATSAPP_CHANNEL_URL
    waBox.TextColor3 = Color3.fromRGB(255, 195, 205)
    waBox.Font = Enum.Font.GothamMedium
    waBox.TextSize = 10.5
    waBox.ClearTextOnFocus = false
    waBox.TextEditable = false
    waBox.ZIndex = 81
    waBox.Parent = WaBanner

    local copyBtn = Instance.new("TextButton")
    copyBtn.Position = UDim2.new(0, 14, 1, -44)
    copyBtn.Size = UDim2.new(0.55, -18, 0, 32)
    copyBtn.BackgroundColor3 = Color3.fromRGB(230, 30, 55)
    copyBtn.Text = "Copiar Enlace"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 12
    copyBtn.ZIndex = 81
    copyBtn.Parent = WaBanner

    local cBtnCorner = Instance.new("UICorner")
    cBtnCorner.CornerRadius = UDim.new(0, 9)
    cBtnCorner.Parent = copyBtn

    local enterBtn = Instance.new("TextButton")
    enterBtn.Position = UDim2.new(0.55, 4, 1, -44)
    enterBtn.Size = UDim2.new(0.45, -18, 0, 32)
    enterBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    enterBtn.BackgroundTransparency = 0.86
    enterBtn.Text = "Entrar"
    enterBtn.TextColor3 = Color3.fromRGB(255, 240, 244)
    enterBtn.Font = Enum.Font.GothamBold
    enterBtn.TextSize = 12
    enterBtn.ZIndex = 81
    enterBtn.Parent = WaBanner

    local eBtnCorner = Instance.new("UICorner")
    eBtnCorner.CornerRadius = UDim.new(0, 9)
    eBtnCorner.Parent = enterBtn

    copyBtn.MouseButton1Click:Connect(function()
        if PlayUiSound then PlayUiSound("on") end
        local ok = pcall(function()
            if setclipboard then setclipboard(WHATSAPP_CHANNEL_URL)
            elseif toclipboard then toclipboard(WHATSAPP_CHANNEL_URL)
            else error() end
        end)
        Notify("KING GAEL", ok and "Enlace copiado al portapapeles." or WHATSAPP_CHANNEL_URL, 3.5)
    end)

    enterBtn.MouseButton1Click:Connect(function()
        if PlayUiSound then PlayUiSound("click") end
        WaBanner.Visible = false
    end)

    QuickBtn = Instance.new("TextButton")
    QuickBtn.Size = IsMobile and UDim2.new(0, 90, 0, 32) or UDim2.new(0, 86, 0, 28)
    QuickBtn.Position = IsMobile and UDim2.new(0, 12, 0.5, -16) or UDim2.new(0, 12, 0, 12)
    QuickBtn.BackgroundColor3 = Color3.fromRGB(20, 6, 10)
    QuickBtn.BackgroundTransparency = 0.2
    QuickBtn.Text = "KING GAEL"
    QuickBtn.TextColor3 = Color3.fromRGB(255, 245, 248)
    QuickBtn.Font = Enum.Font.GothamBlack
    QuickBtn.TextSize = 11
    QuickBtn.ZIndex = 150
    QuickBtn.Parent = ScreenGui

    local qCorner = Instance.new("UICorner")
    qCorner.CornerRadius = UDim.new(0, 9)
    qCorner.Parent = QuickBtn

    local qStroke = Instance.new("UIStroke")
    qStroke.Thickness = 1.4
    qStroke.Color = Color3.fromRGB(255, 50, 75)
    qStroke.Parent = QuickBtn

    local function toggleMenu(force)
        State.MenuOpen = (force ~= nil) and force or (not MainWindow.Visible)
        MainWindow.Visible = State.MenuOpen
        if PlayUiSound then PlayUiSound(State.MenuOpen and "on" or "off") end
    end

    closeBtn.MouseButton1Click:Connect(function() toggleMenu(false) end)
    QuickBtn.MouseButton1Click:Connect(function() toggleMenu() end)
    UIS.InputBegan:Connect(function(inp, gp)
        if not gp and inp.KeyCode == Enum.KeyCode.RightShift then toggleMenu() end
    end)
end

--------------------------------------------------
-- 🌧️ PARTÍCULAS LIGERAS DENTRO DEL MENÚ
--------------------------------------------------
local updateParticles
do
    local list = {}
    local count = IsMobile and 16 or 24
    local w = MainWindow.AbsoluteSize.X > 0 and MainWindow.AbsoluteSize.X or 500
    local h = MainWindow.AbsoluteSize.Y > 0 and MainWindow.AbsoluteSize.Y or 360

    for i = 1, count do
        local p = Instance.new("Frame")
        local sz = math.random(3, 6)
        p.Size = UDim2.new(0, sz, 0, sz)
        p.Position = UDim2.new(0, math.random(6, math.max(12, w - 10)), 0, -math.random(6, h))
        p.BackgroundColor3 = Color3.fromRGB(255, 65, 85)
        p.BackgroundTransparency = math.random(25, 65) / 100
        p.BorderSizePixel = 0
        p.ZIndex = 31
        p.Active = false
        p.Parent = MenuParticlesBox

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = p

        table.insert(list, {
            f = p,
            vy = math.random(35, 78),
            phase = math.random() * 6.28
        })
    end

    updateParticles = function(dt, color)
        MenuParticlesBox.Visible = State.Particles and State.MenuOpen
        if not (State.Particles and State.MenuOpen) then return end
        local bw = math.max(MenuParticlesBox.AbsoluteSize.X, 10)
        local bh = math.max(MenuParticlesBox.AbsoluteSize.Y, 10)
        local t = tick()

        for i = 1, #list do
            local item = list[i]
            local pos = item.f.Position
            local x = pos.X.Offset + math.sin(t * 2 + item.phase) * 10 * dt
            local y = pos.Y.Offset + item.vy * dt

            if y > bh + 4 then
                y = -math.random(6, 20)
                x = math.random(6, math.max(10, bw - 10))
            else
                x = math.clamp(x, 4, bw - 8)
            end

            item.f.Position = UDim2.new(0, x, 0, y)
            item.f.BackgroundColor3 = color
        end
    end
end

--------------------------------------------------
-- 🛡️ JUGADOR, COMBATE Y ESP
--------------------------------------------------
local function isEnemy(plr)
    if not plr or plr == LocalPlayer then return false end
    local myT, thrT = LocalPlayer:GetAttribute("TeamID"), plr:GetAttribute("TeamID")
    if myT ~= nil and thrT ~= nil then return tostring(myT) ~= tostring(thrT) end
    if LocalPlayer.Team and plr.Team then return LocalPlayer.Team ~= plr.Team end
    return true
end

local function hasLineOfSight(char)
    local head = char and char:FindFirstChild("Head")
    if not head then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local hit = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 1000, params)
    return (not hit or hit.Instance:IsDescendantOf(char)) and head or nil
end

local function getEnemyBasePosition()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") and obj.Enabled then
            local nameLow = string.lower(obj.Name)
            local teamAttr = obj:GetAttribute("Team") or obj:GetAttribute("TeamID")
            local myTeam = LocalPlayer.Team and tostring(LocalPlayer.Team) or ""
            if teamAttr ~= nil and tostring(teamAttr) ~= tostring(LocalPlayer:GetAttribute("TeamID") or "") then
                return obj.Position + Vector3.new(0, 4, 0)
            elseif myTeam ~= "" and not string.find(string.lower(myTeam), nameLow, 1, true) then
                if string.find(nameLow, "red") or string.find(nameLow, "blue") or string.find(nameLow, "enemy") or string.find(nameLow, "base") then
                    return obj.Position + Vector3.new(0, 4, 0)
                end
            end
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                return hrp.Position + Vector3.new(0, 3, 0)
            end
        end
    end

    return nil
end

local function teleportToEnemyBase()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        Notify("KING GAEL", "Personaje no disponible.", 2.5)
        return
    end

    local targetPos = getEnemyBasePosition()
    if not targetPos then
        Notify("KING GAEL • Teleport", "No se detectó base o enemigo objetivo.", 3)
        return
    end

    local ok = pcall(function()
        hrp.CFrame = CFrame.new(targetPos)
    end)

    if ok then
        Notify("KING GAEL • Teleport", "Teletransportado a zona enemiga.", 2.8)
    else
        Notify("KING GAEL • Teleport", "El juego bloqueó el teletransporte.", 3)
    end
end

do
    local pTab = CreateTab("Jugador")
    AddSection(pTab, "Movimiento")

    local flyActive = false
    local function stopFly()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local bv = hrp and hrp:FindFirstChild("KingGaelFly")
        if bv then bv:Destroy() end
    end

    local function runFly()
        if flyActive then return end
        flyActive = true
        task.spawn(function()
            while State.Fly do
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bv = hrp:FindFirstChild("KingGaelFly") or Instance.new("BodyVelocity")
                    bv.Name = "KingGaelFly"
                    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                    bv.Parent = hrp

                    local mv = Vector3.zero
                    if UIS:IsKeyDown(Enum.KeyCode.W) then mv += Camera.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then mv -= Camera.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then mv -= Camera.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then mv += Camera.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then mv += Vector3.new(0, 1, 0) end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv -= Vector3.new(0, 1, 0) end
                    bv.Velocity = mv * 65
                end
                task.wait()
            end
            stopFly()
            flyActive = false
        end)
    end

    local function applySpeed()
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then
            h.WalkSpeed = State.SpeedRun and State.SpeedRunValue or State.WalkSpeed
        end
    end

    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.15)
        applySpeed()
        if State.Fly then runFly() end
    end)

    UIS.JumpRequest:Connect(function()
        if State.InfiniteJump then
            local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)

    RunService.Stepped:Connect(function()
        if State.Noclip and LocalPlayer.Character then
            for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)

    AddToggle(pTab, "Speed Run", false, function(v)
        State.SpeedRun = v
        applySpeed()
    end)

    AddSlider(pTab, "Speed Run Power", 24, 150, 2, 48, " spd", function(v)
        State.SpeedRunValue = v
        applySpeed()
    end)

    AddToggle(pTab, "Traspasar Paredes", false, function(v)
        State.Noclip = v
    end)

    AddButton(pTab, "Teleport a Base Enemiga", function()
        teleportToEnemyBase()
    end)

    AddToggle(pTab, "Fly", false, function(v)
        State.Fly = v
        if v then runFly() else stopFly() end
    end)

    AddToggle(pTab, "Infinite Jump", false, function(v) State.InfiniteJump = v end)

    AddSlider(pTab, "WalkSpeed", 16, 200, 1, 16, " WS", function(v)
        State.WalkSpeed = v
        applySpeed()
    end)
end

local fovScale = IsMobile and 48 or 60
local getFovRadius = function() return State.FovLevel * fovScale end

do
    local cTab = CreateTab("Combate")
    AddSection(cTab, "Armas y Apuntado")

    AddToggle(cTab, "Rapid Fire", false, function(v)
        State.RapidFire = v
        if v then
            task.spawn(function()
                while State.RapidFire do
                    local char = LocalPlayer.Character
                    if char then
                        for _, item in ipairs(char:GetChildren()) do
                            if item:IsA("Tool") then
                                pcall(function()
                                    if item:GetAttribute("FireRate") ~= nil then item:SetAttribute("FireRate", 0.02) end
                                    if item:GetAttribute("Cooldown") ~= nil then item:SetAttribute("Cooldown", 0.02) end
                                    for _, valObj in ipairs(item:GetDescendants()) do
                                        if valObj:IsA("NumberValue") or valObj:IsA("IntValue") then
                                            local n = string.lower(valObj.Name)
                                            if string.find(n, "firerate") or string.find(n, "cooldown") or string.find(n, "reload") then
                                                valObj.Value = 0.02
                                            end
                                        end
                                    end
                                end)
                            end
                        end
                    end
                    task.wait(0.25)
                end
            end)
        end
    end)

    AddToggle(cTab, "Silent Aim (Full Range)", false, function(v)
        State.SilentAim = v
        getgenv().SilentAimEnabled = v
    end)

    AddToggle(cTab, "Soft Lock (FOV Only)", false, function(v)
        State.SoftLock = v
        getgenv().SoftLockEnabled = v
    end)

    AddSlider(cTab, "Max Distance", 100, 2000, 50, 500, " st", function(v) State.MaxDistance = v end)

    AddSection(cTab, "FOV")
    AddToggle(cTab, "Show FOV Circle", false, function(v) State.FovEnabled = v end)
    AddSlider(cTab, "FOV Level", 1, 10, 1, 3, "x", function(v) State.FovLevel = v end)

    FovCircle = Instance.new("Frame")
    FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    FovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    FovCircle.BackgroundTransparency = 1
    FovCircle.Active = false
    FovCircle.ZIndex = 20
    FovCircle.Parent = ScreenGui

    FovStroke = Instance.new("UIStroke")
    FovStroke.Thickness = IsMobile and 2.2 or 1.8
    FovStroke.Color = Color3.fromRGB(255, 50, 75)
    FovStroke.Parent = FovCircle

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = FovCircle
end

local espMap = {}
local setLine

do
    local eTab = CreateTab("ESP")
    AddSection(eTab, "Visuales Enemigos")
    AddToggle(eTab, "Enemy Chams", false, function(v) State.Chams = v end)
    AddToggle(eTab, "Crosshair Tracers", false, function(v) State.Tracers = v end)
    AddToggle(eTab, "Box ESP", false, function(v) State.BoxEsp = v end)
    AddToggle(eTab, "Top Line", false, function(v) State.TopLine = v end)
    AddToggle(eTab, "Player Marker", false, function(v) State.Marker = v end)

    setLine = function(frame, a, b, col, thick)
        local dx, dy = b.X - a.X, b.Y - a.Y
        local len = math.sqrt(dx * dx + dy * dy)
        if len < 1 then frame.Visible = false return end
        frame.Position = UDim2.new(0, (a.X + b.X) * 0.5, 0, (a.Y + b.Y) * 0.5)
        frame.Size = UDim2.new(0, len, 0, thick)
        frame.Rotation = math.deg(math.atan2(dy, dx))
        frame.BackgroundColor3 = col
        frame.Visible = true
    end

    local function newLine(th)
        local f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.BorderSizePixel = 0
        f.Visible = false
        f.Active = false
        f.ZIndex = 12
        f.Parent = EspOverlay
        return f
    end

    local function addPlr(p)
        if p == LocalPlayer or espMap[p] then return end
        local th = IsMobile and 2 or 1.5

        local box = Instance.new("Frame")
        box.BackgroundTransparency = 1
        box.BorderSizePixel = 0
        box.Visible = false
        box.Active = false
        box.ZIndex = 12
        box.Parent = EspOverlay

        local bs = Instance.new("UIStroke")
        bs.Thickness = th
        bs.Color = Color3.fromRGB(255, 50, 75)
        bs.Parent = box

        local mk = Instance.new("Frame")
        mk.AnchorPoint = Vector2.new(0.5, 0.5)
        mk.Size = UDim2.new(0, IsMobile and 11 or 9, 0, IsMobile and 11 or 9)
        mk.BorderSizePixel = 0
        mk.Visible = false
        mk.Active = false
        mk.ZIndex = 13
        mk.Parent = EspOverlay

        local mc = Instance.new("UICorner")
        mc.CornerRadius = UDim.new(1, 0)
        mc.Parent = mk

        espMap[p] = {
            tracer = newLine(th),
            top = newLine(th),
            box = box,
            bs = bs,
            mk = mk,
            th = th
        }
    end

    local function delPlr(p)
        local d = espMap[p]
        if d then
            pcall(function()
                d.tracer:Destroy()
                d.top:Destroy()
                d.box:Destroy()
                d.mk:Destroy()
            end)
            espMap[p] = nil
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do addPlr(p) end
    Players.PlayerAdded:Connect(addPlr)
    Players.PlayerRemoving:Connect(delPlr)
end

do
    local vTab = CreateTab("Visuales")
    AddSection(vTab, "Comunidad y Estilo")
    AddButton(vTab, "Copiar Canal WhatsApp", function()
        local ok = pcall(function()
            if setclipboard then setclipboard(WHATSAPP_CHANNEL_URL)
            elseif toclipboard then toclipboard(WHATSAPP_CHANNEL_URL)
            else error() end
        end)
        Notify("KING GAEL", ok and "Enlace copiado." or WHATSAPP_CHANNEL_URL, 3)
    end)
    AddButton(vTab, "Mostrar Tarjeta WhatsApp", function() WaBanner.Visible = true end)
    AddToggle(vTab, "Menu Particles", true, function(v) State.Particles = v end)
    AddToggle(vTab, "Menu Sounds", true, function(v) State.Sounds = v end)
    AddToggle(vTab, "Quick Button", true, function(v) State.QuickBtn = v QuickBtn.Visible = v end)

    AddSection(vTab, "Rendimiento")
    AddToggle(vTab, "Fullbright", false, function(v)
        State.Fullbright = v
        Lighting.Brightness = v and 2 or 1
        Lighting.ClockTime = v and 14 or 12
        Lighting.GlobalShadows = not v
    end)
    AddButton(vTab, "EXTREME FPS BOOST", function()
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsAncestorOf(LocalPlayer.Character) then
                v.Material = Enum.Material.SmoothPlastic
            elseif v:IsA("Texture") or v:IsA("Decal") then
                v:Destroy()
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") then
                v.Enabled = false
            end
        end
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("PostProcessEffect") then v.Enabled = false end
        end
        Notify("KING GAEL", "Optimización aplicada.", 3)
    end)
end

--------------------------------------------------
-- 🔥 BUCLE PRINCIPAL LIGERO
--------------------------------------------------
local activeTargetPos = nil

RunService.RenderStepped:Connect(function(dt)
    local pulse = (math.sin(tick() * 3) + 1) * 0.5
    local col = Color3.fromRGB(255, math.floor(38 + pulse * 40), math.floor(58 + pulse * 40))

    updateParticles(dt, col)

    local vp = Camera.ViewportSize
    local center = vp * 0.5
    local top = Vector2.new(vp.X * 0.5, 0)
    local rad = getFovRadius()

    FovCircle.Visible = State.FovEnabled
    if State.FovEnabled then
        FovCircle.Size = UDim2.new(0, rad * 2, 0, rad * 2)
        FovStroke.Color = col
    end

    local bestHead = nil
    local bestDist = 9e9
    local camPos = Camera.CFrame.Position

    for plr, d in pairs(espMap) do
        local char = plr.Character
        local head = char and char:FindFirstChild("Head")
        local torso = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart"))
        local hrp = char and (char:FindFirstChild("HumanoidRootPart") or torso)

        if head and torso and hrp and isEnemy(plr) then
            local dist = (head.Position - camPos).Magnitude
            local inRange = dist <= State.MaxDistance
            local hPos, hOn = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local fPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.7, 0))
            local tPos, tOn = Camera:WorldToViewportPoint(torso.Position)

            local hl = char:FindFirstChild("Highlight")
            if State.Chams then
                if not hl then hl = Instance.new("Highlight", char) end
                hl.Enabled = true
                hl.FillColor = col
            elseif hl then
                hl.Enabled = false
            end

            if State.Tracers and tOn and inRange then
                setLine(d.tracer, center, Vector2.new(tPos.X, tPos.Y), col, d.th)
            else
                d.tracer.Visible = false
            end

            if State.TopLine and hOn and inRange then
                setLine(d.top, top, Vector2.new(hPos.X, hPos.Y), col, d.th)
            else
                d.top.Visible = false
            end

            if State.BoxEsp and hOn and inRange then
                local bh = math.clamp(math.abs(fPos.Y - hPos.Y), 14, 320)
                local bw = math.clamp(bh * 0.58, 10, 220)
                d.box.Size = UDim2.new(0, bw, 0, bh)
                d.box.Position = UDim2.new(0, hPos.X - bw * 0.5, 0, hPos.Y)
                d.bs.Color = col
                d.box.Visible = true
            else
                d.box.Visible = false
            end

            if State.Marker and hOn and inRange then
                d.mk.Position = UDim2.new(0, hPos.X, 0, math.max(10, hPos.Y - 10))
                d.mk.BackgroundColor3 = col
                d.mk.Visible = true
            else
                d.mk.Visible = false
            end

            if hOn and inRange and (State.SoftLock or State.SilentAim) then
                local fd = (Vector2.new(hPos.X, hPos.Y) - center).Magnitude
                if (not State.SoftLock or fd <= rad) and fd < bestDist then
                    bestDist = fd
                    bestHead = head
                end
            end
        else
            d.tracer.Visible = false
            d.top.Visible = false
            d.box.Visible = false
            d.mk.Visible = false
            local hl = char and char:FindFirstChild("Highlight")
            if hl then hl.Enabled = false end
        end
    end

    if bestHead and bestHead.Parent and (State.SoftLock or State.SilentAim) then
        activeTargetPos = (hasLineOfSight(bestHead.Parent) and bestHead.Position) or nil
    else
        activeTargetPos = nil
    end
end)

local oldIdx
oldIdx = hookmetamethod(game, "__index", newcclosure(function(self, idx)
    if (State.SilentAim or State.SoftLock) and activeTargetPos and not checkcaller() and idx == "ViewportSize" and self == Camera then
        local pos, on = Camera:WorldToViewportPoint(activeTargetPos)
        if on then return Vector2.new(pos.X * 2, pos.Y * 2) end
    end
    return oldIdx(self, idx)
end))

PlayUiSound("on")
Notify("KING GAEL", "Menú PRO V5 con sonidos cargado.", 3)
