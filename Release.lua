--// SERVICIOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

local TARGET_PLACE_ID = 17625359962
local WHATSAPP_CHANNEL_URL = "https://whatsapp.com/channel/0029VbCHjR7LNSaCqoxB7P10"

local BG_ASSET_ID = 138351747140128
local LOGO_ASSET_ID = 124340778722653

local State = {
    MenuOpen = true,
    QuickBtn = true,
    Sounds = true,
    SoundVolume = 0.85,
    SafeMode = true,
    LeapGlide = false,
    LeapLocked = false,
    TpBtnEnabled = false,
    TpLocked = false,
    Fly = false,
    SpeedRun = false,
    SpeedRunValue = 38,
    InfiniteJump = false,
    Noclip = false,
    WalkSpeed = 16,
    InfiniteAmmo = false,
    FastReload = true,
    SilentAim = false,
    SoftLock = false,
    SoftLockSmooth = 0.26,
    MaxDistance = 600,
    FovEnabled = false,
    FovLevel = 3,
    Chams = false,
    Tracers = false,
    BoxEsp = false,
    TopLine = false,
    Marker = false,
    Fullbright = false
}

local ScreenGui, MainWindow, BgImageLabel, LogoImageLabel, EspOverlay, WaBanner, QuickBtn, StatusLbl
local LeapDock, LeapBtn, LeapLockBtn, LeapTimerLbl
local TpDock, TpBtn, TpLockBtn
local FovCircle, FovStroke
local Notify, PlayUiSound, CreateTab, AddSection, AddToggle, AddSlider, AddButton, teleportToEnemy, triggerLeapGlide, emergencyResetAll, syncAmmoWatchdog

local function getRainbowColor(offset)
    local hue = ((os.clock() * 0.24) + (offset or 0)) % 1
    return Color3.fromHSV(hue, 0.88, 1)
end

local function extractNumericAssetId(val)
    if type(val) == "number" then
        return val > 0 and val or nil
    elseif type(val) == "string" then
        local num = string.match(val, "%d%d%d%d%d%d+")
        return num and tonumber(num) or nil
    end
    return nil
end

local function resolveImageAssetId(rawId)
    local numId = extractNumericAssetId(rawId)
    if not numId then return nil end

    local okInfo, info = pcall(function()
        return MarketplaceService:GetProductInfo(numId, Enum.InfoType.Asset)
    end)

    if okInfo and info then
        if info.AssetTypeId == 1 then
            return numId
        end
        if type(info.Description) == "string" then
            local descId = string.match(info.Description, "rbxassetid://(%d+)") or string.match(info.Description, "(%d%d%d%d%d%d+)")
            if descId and tonumber(descId) then
                return tonumber(descId)
            end
        end
    end

    return numId
end

local function loadInitialImages()
    if BgImageLabel then
        BgImageLabel.Image = "rbxassetid://" .. tostring(BG_ASSET_ID)
    end
    if LogoImageLabel then
        LogoImageLabel.Image = "rbxassetid://" .. tostring(LOGO_ASSET_ID)
    end

    task.spawn(function()
        local resolvedBg = resolveImageAssetId(BG_ASSET_ID)
        if resolvedBg and BgImageLabel and BgImageLabel.Parent then
            BgImageLabel.Image = "rbxassetid://" .. tostring(resolvedBg)
        end

        local resolvedLogo = resolveImageAssetId(LOGO_ASSET_ID)
        if resolvedLogo and LogoImageLabel and LogoImageLabel.Parent then
            LogoImageLabel.Image = "rbxassetid://" .. tostring(resolvedLogo)
        end
    end)
end

--------------------------------------------------
-- 🔊 SISTEMA DE SONIDO PRO - KING GAEL
--------------------------------------------------
local sfxList = {}
do
    local sfxFolder = Instance.new("Folder")
    sfxFolder.Name = "KING_GAEL_SFX_RAINBOW"
    sfxFolder.Parent = SoundService

    local function createSfx(name, assetId, mult, pitch)
        local s = Instance.new("Sound")
        s.Name = name
        s.SoundId = "rbxassetid://" .. tostring(assetId)
        s.Volume = math.clamp(State.SoundVolume * (mult or 1), 0, 1)
        s.PlaybackSpeed = pitch or 1
        s.Parent = sfxFolder
        table.insert(sfxList, {sound = s, mult = mult or 1})
        return s
    end

    local sndOn = createSfx("ToggleOn", 6042053626, 1.0, 1.12)
    local sndOff = createSfx("ToggleOff", 6042053363, 0.9, 0.88)
    local sndClick = createSfx("Click", 6895079853, 0.95, 1.05)
    local sndBoost = createSfx("Boost", 4612375233, 1.0, 1.18)

    PlayUiSound = function(kind)
        if not State.Sounds then return end
        local target = sndClick
        if kind == "on" then
            target = sndOn
        elseif kind == "off" then
            target = sndOff
        elseif kind == "boost" then
            target = sndBoost
        end
        pcall(function()
            target.Volume = math.clamp(State.SoundVolume, 0, 1)
            target.TimePosition = 0
            target:Play()
        end)
    end
end

local function syncSfxVolumes()
    for _, entry in ipairs(sfxList) do
        if entry.sound then
            entry.sound.Volume = math.clamp(State.SoundVolume * entry.mult, 0, 1)
        end
    end
end

--------------------------------------------------
-- 🌈 UI PRO - KING GAEL
--------------------------------------------------
local uiRainbowStrokes = {}
local uiRainbowAccents = {}

do
    local okRoot, root = pcall(function()
        return (gethui and gethui()) or game:GetService("CoreGui")
    end)
    local parent = (okRoot and root) or LocalPlayer:WaitForChild("PlayerGui")

    local oldGui = parent:FindFirstChild("KING_GAEL_RIVALS_RAINBOW")
    if oldGui then
        pcall(function() oldGui:Destroy() end)
    end

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KING_GAEL_RIVALS_RAINBOW"
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
        card.BackgroundColor3 = Color3.fromRGB(15, 16, 24)
        card.BackgroundTransparency = 0.12
        card.BorderSizePixel = 0
        card.ZIndex = 171
        card.Parent = notifyHolder

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 11)
        cCorner.Parent = card

        local cStroke = Instance.new("UIStroke")
        cStroke.Thickness = 1.4
        cStroke.Color = getRainbowColor(0.1)
        cStroke.Parent = card
        local strokeEntry = {stroke = cStroke, phase = 0.1}
        table.insert(uiRainbowStrokes, strokeEntry)

        local tLbl = Instance.new("TextLabel")
        tLbl.Position = UDim2.new(0, 12, 0, 6)
        tLbl.Size = UDim2.new(1, -24, 0, 18)
        tLbl.BackgroundTransparency = 1
        tLbl.Text = title
        tLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
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
        bLbl.TextColor3 = Color3.fromRGB(225, 228, 245)
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
            strokeEntry.stroke = nil
        end)
    end

    local vp = Camera.ViewportSize
    local w = IsMobile and math.clamp(vp.X * 0.9, 330, 500) or 590
    local h = IsMobile and math.clamp(vp.Y * 0.82, 275, 380) or 410

    MainWindow = Instance.new("Frame")
    MainWindow.Name = "KING_GAEL_WINDOW"
    MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainWindow.Size = UDim2.new(0, w, 0, h)
    MainWindow.BackgroundColor3 = Color3.fromRGB(13, 14, 22)
    MainWindow.BackgroundTransparency = 0.25
    MainWindow.BorderSizePixel = 0
    MainWindow.ClipsDescendants = true
    MainWindow.Active = true
    MainWindow.ZIndex = 30
    MainWindow.Parent = ScreenGui

    local mCorner = Instance.new("UICorner")
    mCorner.CornerRadius = UDim.new(0, 16)
    mCorner.Parent = MainWindow

    local mStroke = Instance.new("UIStroke")
    mStroke.Thickness = 2
    mStroke.Color = getRainbowColor(0)
    mStroke.Parent = MainWindow
    table.insert(uiRainbowStrokes, {stroke = mStroke, phase = 0})

    local bgContainer = Instance.new("Frame")
    bgContainer.Name = "KING_GAEL_BG_HOLDER"
    bgContainer.Size = UDim2.new(1, 0, 1, 0)
    bgContainer.Position = UDim2.new(0, 0, 0, 0)
    bgContainer.BackgroundTransparency = 1
    bgContainer.BorderSizePixel = 0
    bgContainer.Active = false
    bgContainer.ZIndex = 31
    bgContainer.Parent = MainWindow

    BgImageLabel = Instance.new("ImageLabel")
    BgImageLabel.Name = "KING_GAEL_BG_IMAGE"
    BgImageLabel.Size = UDim2.new(1, 0, 1, 0)
    BgImageLabel.Position = UDim2.new(0, 0, 0, 0)
    BgImageLabel.BackgroundTransparency = 1
    BgImageLabel.BorderSizePixel = 0
    BgImageLabel.Image = "rbxassetid://" .. tostring(BG_ASSET_ID)
    BgImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
    BgImageLabel.ImageTransparency = 0.18
    BgImageLabel.ScaleType = Enum.ScaleType.Crop
    BgImageLabel.ZIndex = 31
    BgImageLabel.Active = false
    BgImageLabel.Parent = bgContainer

    local bgTint = Instance.new("Frame")
    bgTint.Size = UDim2.new(1, 0, 1, 0)
    bgTint.Position = UDim2.new(0, 0, 0, 0)
    bgTint.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
    bgTint.BackgroundTransparency = 0.58
    bgTint.BorderSizePixel = 0
    bgTint.Active = false
    bgTint.ZIndex = 32
    bgTint.Parent = bgContainer

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 44)
    header.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
    header.BackgroundTransparency = 0.45
    header.BorderSizePixel = 0
    header.ZIndex = 35
    header.Parent = MainWindow

    LogoImageLabel = Instance.new("ImageLabel")
    LogoImageLabel.Name = "KING_GAEL_LOGO_IMAGE"
    LogoImageLabel.AnchorPoint = Vector2.new(0, 0.5)
    LogoImageLabel.Position = UDim2.new(0, 10, 0.5, 0)
    LogoImageLabel.Size = UDim2.new(0, 32, 0, 32)
    LogoImageLabel.BackgroundColor3 = Color3.fromRGB(24, 26, 40)
    LogoImageLabel.BackgroundTransparency = 0.2
    LogoImageLabel.BorderSizePixel = 0
    LogoImageLabel.Image = "rbxassetid://" .. tostring(LOGO_ASSET_ID)
    LogoImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
    LogoImageLabel.ScaleType = Enum.ScaleType.Fit
    LogoImageLabel.ZIndex = 36
    LogoImageLabel.Active = false
    LogoImageLabel.Parent = header

    local lgCorner = Instance.new("UICorner")
    lgCorner.CornerRadius = UDim.new(0, 8)
    lgCorner.Parent = LogoImageLabel

    local lgStroke = Instance.new("UIStroke")
    lgStroke.Thickness = 1.4
    lgStroke.Color = getRainbowColor(0.2)
    lgStroke.Parent = LogoImageLabel
    table.insert(uiRainbowStrokes, {stroke = lgStroke, phase = 0.2})

    local title = Instance.new("TextLabel")
    title.Position = UDim2.new(0, 48, 0, 0)
    title.Size = UDim2.new(0.38, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "KING GAEL"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = IsMobile and 15 or 17
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 36
    title.Parent = header

    StatusLbl = Instance.new("TextLabel")
    StatusLbl.Position = UDim2.new(0, IsMobile and 142 or 156, 0, 1)
    StatusLbl.Size = UDim2.new(0.45, 0, 1, 0)
    StatusLbl.BackgroundTransparency = 1
    StatusLbl.Text = "RIVALS • SAFE ON"
    StatusLbl.TextColor3 = getRainbowColor(0.3)
    StatusLbl.Font = Enum.Font.GothamBold
    StatusLbl.TextSize = 10
    StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
    StatusLbl.ZIndex = 36
    StatusLbl.Parent = header
    table.insert(uiRainbowAccents, {obj = StatusLbl, prop = "TextColor3", phase = 0.3})

    local closeBtn = Instance.new("TextButton")
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.Position = UDim2.new(1, -12, 0.5, 0)
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.BackgroundColor3 = Color3.fromRGB(34, 37, 54)
    closeBtn.BackgroundTransparency = 0.15
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 17
    closeBtn.ZIndex = 36
    closeBtn.Parent = header

    local clCorner = Instance.new("UICorner")
    clCorner.CornerRadius = UDim.new(1, 0)
    clCorner.Parent = closeBtn

    local clStroke = Instance.new("UIStroke")
    clStroke.Thickness = 1.1
    clStroke.Color = Color3.fromRGB(255, 255, 255)
    clStroke.Transparency = 0.78
    clStroke.Parent = closeBtn

    closeBtn.MouseButton1Down:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(210, 65, 90)}):Play()
    end)
    closeBtn.MouseButton1Up:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(34, 37, 54)}):Play()
    end)

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
            elseif drag.kind == "dock" and drag.target and not drag.isLocked() then
                local d = inp.Position - drag.start
                if d.Magnitude > 8 then
                    drag.moved = true
                end
                if drag.moved then
                    local nx = math.clamp(drag.origin.X.Offset + d.X, 8, math.max(8, Camera.ViewportSize.X - drag.target.AbsoluteSize.X - 8))
                    local ny = math.clamp(drag.origin.Y.Offset + d.Y, 8, math.max(8, Camera.ViewportSize.Y - drag.target.AbsoluteSize.Y - 8))
                    drag.target.Position = UDim2.new(0, nx, 0, ny)
                end
            elseif drag.kind == "slider" and drag.fn then
                drag.fn(inp.Position.X)
            end
        end
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            if drag and drag.kind == "dock" and not drag.moved and drag.onTap then
                drag.onTap()
            end
            drag = nil
        end
    end)

    local sideW = IsMobile and 106 or 136
    local sidebar = Instance.new("Frame")
    sidebar.Position = UDim2.new(0, 0, 0, 44)
    sidebar.Size = UDim2.new(0, sideW, 1, -44)
    sidebar.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
    sidebar.BackgroundTransparency = 0.55
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 34
    sidebar.Parent = MainWindow

    local sList = Instance.new("UIListLayout")
    sList.Padding = UDim.new(0, 7)
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
        btn.Size = UDim2.new(1, 0, 0, IsMobile and 34 or 36)
        btn.BackgroundColor3 = Color3.fromRGB(28, 30, 46)
        btn.BackgroundTransparency = 0.25
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(215, 220, 240)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = IsMobile and 12 or 13
        btn.ZIndex = 35
        btn.Parent = sidebar

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 10)
        bCorner.Parent = btn

        local bStroke = Instance.new("UIStroke")
        bStroke.Thickness = 1.15
        bStroke.Color = getRainbowColor(0.35)
        bStroke.Transparency = 0.72
        bStroke.Parent = btn

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = getRainbowColor(0.5)
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
                TweenService:Create(t.btn, TweenInfo.new(0.14), {
                    BackgroundColor3 = Color3.fromRGB(28, 30, 46),
                    BackgroundTransparency = 0.28,
                    TextColor3 = Color3.fromRGB(210, 215, 235)
                }):Play()
                if t.stroke then
                    t.stroke.Transparency = 0.75
                end
            end
            page.Visible = true
            TweenService:Create(btn, TweenInfo.new(0.14), {
                BackgroundColor3 = Color3.fromRGB(58, 66, 112),
                BackgroundTransparency = 0.1,
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            bStroke.Transparency = 0.15
            if playSfx and PlayUiSound then PlayUiSound("click") end
        end

        btn.MouseButton1Click:Connect(function() openThis(true) end)
        table.insert(tabs, {btn = btn, page = page, stroke = bStroke})
        if #tabs == 1 then openThis(false) end
        return page
    end

    AddSection = function(page, text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text = string.upper(text)
        lbl.TextColor3 = getRainbowColor(0.2)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 36
        lbl.Parent = page
        table.insert(uiRainbowAccents, {obj = lbl, prop = "TextColor3", phase = 0.2})
    end

    AddToggle = function(page, text, def, cb)
        local on = def or false
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1, 0, 0, 38)
        row.BackgroundColor3 = on and Color3.fromRGB(32, 38, 56) or Color3.fromRGB(24, 26, 40)
        row.BackgroundTransparency = 0.24
        row.BorderSizePixel = 0
        row.Text = ""
        row.AutoButtonColor = false
        row.ZIndex = 36
        row.Parent = page

        local rCorner = Instance.new("UICorner")
        rCorner.CornerRadius = UDim.new(0, 11)
        rCorner.Parent = row

        local rStroke = Instance.new("UIStroke")
        rStroke.Thickness = 1.1
        rStroke.Color = getRainbowColor(0.35)
        rStroke.Transparency = on and 0.35 or 0.78
        rStroke.Parent = row

        local lbl = Instance.new("TextLabel")
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.Size = UDim2.new(1, -72, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(248, 250, 255)
        lbl.Font = Enum.Font.GothamSemiBold
        lbl.TextSize = IsMobile and 12 or 12.5
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 37
        lbl.Parent = row

        local pill = Instance.new("Frame")
        pill.AnchorPoint = Vector2.new(1, 0.5)
        pill.Position = UDim2.new(1, -10, 0.5, 0)
        pill.Size = UDim2.new(0, 46, 0, 23)
        pill.BackgroundColor3 = on and Color3.fromRGB(48, 205, 130) or Color3.fromRGB(48, 52, 72)
        pill.BackgroundTransparency = 0.1
        pill.BorderSizePixel = 0
        pill.ZIndex = 37
        pill.Parent = row

        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(1, 0)
        pCorner.Parent = pill

        local pStroke = Instance.new("UIStroke")
        pStroke.Thickness = 1
        pStroke.Color = Color3.fromRGB(255, 255, 255)
        pStroke.Transparency = 0.75
        pStroke.Parent = pill

        local pTxt = Instance.new("TextLabel")
        pTxt.Size = UDim2.new(1, 0, 1, 0)
        pTxt.BackgroundTransparency = 1
        pTxt.Text = on and "ON" or "OFF"
        pTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
        pTxt.Font = Enum.Font.GothamBlack
        pTxt.TextSize = 10
        pTxt.ZIndex = 38
        pTxt.Parent = pill

        local function syncVisual()
            pTxt.Text = on and "ON" or "OFF"
            TweenService:Create(pill, TweenInfo.new(0.14), {
                BackgroundColor3 = on and Color3.fromRGB(48, 205, 130) or Color3.fromRGB(48, 52, 72)
            }):Play()
            TweenService:Create(row, TweenInfo.new(0.14), {
                BackgroundColor3 = on and Color3.fromRGB(32, 38, 56) or Color3.fromRGB(24, 26, 40)
            }):Play()
            rStroke.Transparency = on and 0.35 or 0.78
        end

        row.MouseButton1Click:Connect(function()
            on = not on
            syncVisual()
            if PlayUiSound then PlayUiSound(on and "on" or "off") end
            if cb then cb(on) end
        end)
    end

    AddSlider = function(page, text, minV, maxV, step, def, suffix, cb)
        local val = def or minV
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 46)
        row.BackgroundColor3 = Color3.fromRGB(26, 28, 42)
        row.BackgroundTransparency = 0.32
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
        topLbl.TextColor3 = Color3.fromRGB(245, 247, 255)
        topLbl.Font = Enum.Font.GothamMedium
        topLbl.TextSize = 12
        topLbl.TextXAlignment = Enum.TextXAlignment.Left
        topLbl.ZIndex = 37
        topLbl.Parent = row

        local barBg = Instance.new("Frame")
        barBg.Position = UDim2.new(0, 12, 0, 28)
        barBg.Size = UDim2.new(1, -24, 0, 7)
        barBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        barBg.BackgroundTransparency = 0.84
        barBg.BorderSizePixel = 0
        barBg.ZIndex = 37
        barBg.Parent = row

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(1, 0)
        bCorner.Parent = barBg

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(math.clamp((val - minV) / (maxV - minV), 0, 1), 0, 1, 0)
        fill.BackgroundColor3 = getRainbowColor(0.4)
        fill.BorderSizePixel = 0
        fill.ZIndex = 38
        fill.Parent = barBg
        table.insert(uiRainbowAccents, {obj = fill, prop = "BackgroundColor3", phase = 0.4})

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
        btn.Size = UDim2.new(1, 0, 0, 38)
        btn.BackgroundColor3 = Color3.fromRGB(36, 42, 68)
        btn.BackgroundTransparency = 0.14
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12.5
        btn.AutoButtonColor = false
        btn.ZIndex = 37
        btn.Parent = page

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 11)
        bCorner.Parent = btn

        local bStroke = Instance.new("UIStroke")
        bStroke.Thickness = 1.35
        bStroke.Color = getRainbowColor(0.6)
        bStroke.Parent = btn
        table.insert(uiRainbowStrokes, {stroke = bStroke, phase = 0.6})

        btn.MouseButton1Down:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.09), {
                BackgroundColor3 = Color3.fromRGB(58, 72, 118),
                Size = UDim2.new(1, -2, 0, 36)
            }):Play()
        end)

        btn.MouseButton1Up:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {
                BackgroundColor3 = Color3.fromRGB(36, 42, 68),
                Size = UDim2.new(1, 0, 0, 38)
            }):Play()
        end)

        btn.MouseButton1Click:Connect(function()
            if cb then cb() end
        end)
    end

    WaBanner = Instance.new("Frame")
    WaBanner.AnchorPoint = Vector2.new(0.5, 0.5)
    WaBanner.Position = UDim2.new(0.5, 0, 0.5, 0)
    WaBanner.Size = UDim2.new(0, IsMobile and 295 or 355, 0, 176)
    WaBanner.BackgroundColor3 = Color3.fromRGB(16, 17, 26)
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
    waStroke.Color = getRainbowColor(0.25)
    waStroke.Parent = WaBanner
    table.insert(uiRainbowStrokes, {stroke = waStroke, phase = 0.25})

    local waTitle = Instance.new("TextLabel")
    waTitle.Position = UDim2.new(0, 14, 0, 12)
    waTitle.Size = UDim2.new(1, -28, 0, 20)
    waTitle.BackgroundTransparency = 1
    waTitle.Text = "Canal WhatsApp • KING GAEL"
    waTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    waTitle.Font = Enum.Font.GothamBlack
    waTitle.TextSize = 14
    waTitle.TextXAlignment = Enum.TextXAlignment.Left
    waTitle.ZIndex = 81
    waTitle.Parent = WaBanner

    local waDesc = Instance.new("TextLabel")
    waDesc.Position = UDim2.new(0, 14, 0, 34)
    waDesc.Size = UDim2.new(1, -28, 0, 34)
    waDesc.BackgroundTransparency = 1
    waDesc.Text = "Sigue el canal de KING GAEL en WhatsApp para actualizaciones y scripts de Rivals."
    waDesc.TextColor3 = Color3.fromRGB(225, 228, 245)
    waDesc.Font = Enum.Font.Gotham
    waDesc.TextSize = 11.5
    waDesc.TextXAlignment = Enum.TextXAlignment.Left
    waDesc.TextWrapped = true
    waDesc.ZIndex = 81
    waDesc.Parent = WaBanner

    local waBox = Instance.new("TextBox")
    waBox.Position = UDim2.new(0, 14, 0, 74)
    waBox.Size = UDim2.new(1, -28, 0, 28)
    waBox.BackgroundColor3 = Color3.fromRGB(35, 38, 56)
    waBox.BackgroundTransparency = 0.25
    waBox.Text = WHATSAPP_CHANNEL_URL
    waBox.TextColor3 = Color3.fromRGB(240, 245, 255)
    waBox.Font = Enum.Font.GothamMedium
    waBox.TextSize = 10.5
    waBox.ClearTextOnFocus = false
    waBox.TextEditable = false
    waBox.ZIndex = 81
    waBox.Parent = WaBanner

    local copyBtn = Instance.new("TextButton")
    copyBtn.Position = UDim2.new(0, 14, 1, -44)
    copyBtn.Size = UDim2.new(0.55, -18, 0, 33)
    copyBtn.BackgroundColor3 = Color3.fromRGB(58, 74, 132)
    copyBtn.Text = "Copiar Enlace"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 12
    copyBtn.ZIndex = 81
    copyBtn.Parent = WaBanner

    local cBtnCorner = Instance.new("UICorner")
    cBtnCorner.CornerRadius = UDim.new(0, 10)
    cBtnCorner.Parent = copyBtn

    local cBtnStroke = Instance.new("UIStroke")
    cBtnStroke.Thickness = 1.2
    cBtnStroke.Color = getRainbowColor(0.45)
    cBtnStroke.Parent = copyBtn
    table.insert(uiRainbowStrokes, {stroke = cBtnStroke, phase = 0.45})

    local enterBtn = Instance.new("TextButton")
    enterBtn.Position = UDim2.new(0.55, 4, 1, -44)
    enterBtn.Size = UDim2.new(0.45, -18, 0, 33)
    enterBtn.BackgroundColor3 = Color3.fromRGB(36, 40, 62)
    enterBtn.BackgroundTransparency = 0.14
    enterBtn.Text = "Entrar"
    enterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    enterBtn.Font = Enum.Font.GothamBold
    enterBtn.TextSize = 12
    enterBtn.ZIndex = 81
    enterBtn.Parent = WaBanner

    local eBtnCorner = Instance.new("UICorner")
    eBtnCorner.CornerRadius = UDim.new(0, 10)
    eBtnCorner.Parent = enterBtn

    local eBtnStroke = Instance.new("UIStroke")
    eBtnStroke.Thickness = 1.2
    eBtnStroke.Color = getRainbowColor(0.75)
    eBtnStroke.Parent = enterBtn
    table.insert(uiRainbowStrokes, {stroke = eBtnStroke, phase = 0.75})

    copyBtn.MouseButton1Click:Connect(function()
        if PlayUiSound then PlayUiSound("boost") end
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
    QuickBtn.Size = IsMobile and UDim2.new(0, 96, 0, 34) or UDim2.new(0, 92, 0, 30)
    QuickBtn.Position = IsMobile and UDim2.new(0, 12, 0.5, -17) or UDim2.new(0, 12, 0, 12)
    QuickBtn.BackgroundColor3 = Color3.fromRGB(18, 20, 32)
    QuickBtn.BackgroundTransparency = 0.14
    QuickBtn.Text = "KING GAEL"
    QuickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    QuickBtn.Font = Enum.Font.GothamBlack
    QuickBtn.TextSize = 11
    QuickBtn.ZIndex = 150
    QuickBtn.Parent = ScreenGui

    local qCorner = Instance.new("UICorner")
    qCorner.CornerRadius = UDim.new(0, 10)
    qCorner.Parent = QuickBtn

    local qStroke = Instance.new("UIStroke")
    qStroke.Thickness = 1.6
    qStroke.Color = getRainbowColor(0.15)
    qStroke.Parent = QuickBtn
    table.insert(uiRainbowStrokes, {stroke = qStroke, phase = 0.15})

    local function createFloatingDock(name, emoji, initX, initY, strokePhase, lockPhase, onTapFn, onLockToggle, isLockedFn)
        local dock = Instance.new("Frame")
        dock.Name = name .. "_DOCK"
        dock.Size = UDim2.new(0, 92, 0, 52)
        dock.Position = UDim2.new(0, initX, 0, initY)
        dock.BackgroundTransparency = 1
        dock.Active = false
        dock.Visible = false
        dock.ZIndex = 155
        dock.Parent = ScreenGui

        local mainBtn = Instance.new("TextButton")
        mainBtn.Name = name .. "_BTN"
        mainBtn.Size = UDim2.new(0, 52, 0, 52)
        mainBtn.Position = UDim2.new(0, 0, 0, 0)
        mainBtn.BackgroundColor3 = Color3.fromRGB(22, 25, 40)
        mainBtn.BackgroundTransparency = 0.1
        mainBtn.Text = emoji
        mainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        mainBtn.Font = Enum.Font.GothamBold
        mainBtn.TextSize = 25
        mainBtn.AutoButtonColor = false
        mainBtn.Active = true
        mainBtn.ZIndex = 156
        mainBtn.Parent = dock

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 14)
        bCorner.Parent = mainBtn

        local bStroke = Instance.new("UIStroke")
        bStroke.Thickness = 2
        bStroke.Color = getRainbowColor(strokePhase)
        bStroke.Parent = mainBtn
        table.insert(uiRainbowStrokes, {stroke = bStroke, phase = strokePhase})

        mainBtn.MouseButton1Down:Connect(function()
            TweenService:Create(mainBtn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(44, 52, 86)}):Play()
        end)
        mainBtn.MouseButton1Up:Connect(function()
            TweenService:Create(mainBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(22, 25, 40)}):Play()
        end)

        local timerLbl = Instance.new("TextLabel")
        timerLbl.AnchorPoint = Vector2.new(0.5, 1)
        timerLbl.Position = UDim2.new(0.5, 0, 1, -3)
        timerLbl.Size = UDim2.new(1, -4, 0, 13)
        timerLbl.BackgroundTransparency = 1
        timerLbl.Text = ""
        timerLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        timerLbl.Font = Enum.Font.GothamBlack
        timerLbl.TextSize = 9.5
        timerLbl.ZIndex = 157
        timerLbl.Parent = mainBtn

        local lockBtn = Instance.new("TextButton")
        lockBtn.Name = name .. "_LOCK"
        lockBtn.Size = UDim2.new(0, 32, 0, 32)
        lockBtn.Position = UDim2.new(0, 58, 0, 10)
        lockBtn.BackgroundColor3 = Color3.fromRGB(26, 29, 46)
        lockBtn.BackgroundTransparency = 0.12
        lockBtn.Text = "🔓"
        lockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        lockBtn.Font = Enum.Font.GothamBold
        lockBtn.TextSize = 15
        lockBtn.AutoButtonColor = false
        lockBtn.Active = true
        lockBtn.ZIndex = 156
        lockBtn.Parent = dock

        local lkCorner = Instance.new("UICorner")
        lkCorner.CornerRadius = UDim.new(0, 10)
        lkCorner.Parent = lockBtn

        local lkStroke = Instance.new("UIStroke")
        lkStroke.Thickness = 1.5
        lkStroke.Color = getRainbowColor(lockPhase)
        lkStroke.Parent = lockBtn
        table.insert(uiRainbowStrokes, {stroke = lkStroke, phase = lockPhase})

        mainBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                drag = {
                    kind = "dock",
                    target = dock,
                    start = inp.Position,
                    origin = dock.Position,
                    moved = false,
                    isLocked = isLockedFn,
                    onTap = onTapFn
                }
            end
        end)

        lockBtn.MouseButton1Click:Connect(function()
            onLockToggle()
        end)

        return dock, mainBtn, lockBtn, timerLbl
    end

    local startX = math.max(16, Camera.ViewportSize.X - 116)
    local startY = math.max(16, math.floor(Camera.ViewportSize.Y * 0.62))

    LeapDock, LeapBtn, LeapLockBtn, LeapTimerLbl = createFloatingDock(
        "KING_GAEL_LEAP",
        "🦘",
        startX,
        startY,
        0.5,
        0.75,
        function()
            if triggerLeapGlide then triggerLeapGlide() end
        end,
        function()
            State.LeapLocked = not State.LeapLocked
            LeapLockBtn.Text = State.LeapLocked and "🔒" or "🔓"
            TweenService:Create(LeapLockBtn, TweenInfo.new(0.14), {
                BackgroundColor3 = State.LeapLocked and Color3.fromRGB(48, 205, 130) or Color3.fromRGB(26, 29, 46)
            }):Play()
            PlayUiSound(State.LeapLocked and "on" or "off")
            Notify("KING GAEL • 🦘", State.LeapLocked and "Posición de 🦘 bloqueada." or "Posición de 🦘 desbloqueada.", 2.2)
        end,
        function() return State.LeapLocked end
    )

    TpDock, TpBtn, TpLockBtn = createFloatingDock(
        "KING_GAEL_TP",
        "⚡",
        startX,
        math.max(16, startY - 64),
        0.65,
        0.85,
        function()
            if teleportToEnemy then teleportToEnemy() end
        end,
        function()
            State.TpLocked = not State.TpLocked
            TpLockBtn.Text = State.TpLocked and "🔒" or "🔓"
            TweenService:Create(TpLockBtn, TweenInfo.new(0.14), {
                BackgroundColor3 = State.TpLocked and Color3.fromRGB(48, 205, 130) or Color3.fromRGB(26, 29, 46)
            }):Play()
            PlayUiSound(State.TpLocked and "on" or "off")
            Notify("KING GAEL • ⚡", State.TpLocked and "Posición de ⚡ bloqueada." or "Posición de ⚡ desbloqueada.", 2.2)
        end,
        function() return State.TpLocked end
    )

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
-- 🎯 LÓGICA RIVALS (17625359962)
--------------------------------------------------
local function isEnemy(plr)
    if not plr or plr == LocalPlayer then return false end

    local myAttr = LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("TeamId") or LocalPlayer:GetAttribute("TeamID")
    local thrAttr = plr:GetAttribute("Team") or plr:GetAttribute("TeamId") or plr:GetAttribute("TeamID")
    if myAttr ~= nil and thrAttr ~= nil then
        return tostring(myAttr) ~= tostring(thrAttr)
    end

    if LocalPlayer.Team and plr.Team then
        return LocalPlayer.Team ~= plr.Team
    end

    return true
end

local function isCharacterAlive(char)
    if not char or not char.Parent then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum ~= nil and hrp ~= nil and hum.Health > 0
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

local function findClosestEnemyTarget()
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local originPos = myHrp and myHrp.Position or Camera.CFrame.Position

    local closestEnemy = nil
    local closestDist = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) and isCharacterAlive(plr.Character) then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - originPos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestEnemy = plr
                end
            end
        end
    end

    return closestEnemy, closestDist
end

local lastTpTime = 0
teleportToEnemy = function()
    local now = os.clock()
    if State.SafeMode and (now - lastTpTime) < 0.85 then
        Notify("KING GAEL • ⚡ TP", "Modo Seguro: espera un instante entre TPs.", 2)
        return
    end
    lastTpTime = now

    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

    if not myHrp or not myHum or myHum.Health <= 0 then
        Notify("KING GAEL • ⚡ TP", "Espera a tener tu personaje vivo en la ronda.", 2.8)
        return
    end

    local targetPlr, dist = findClosestEnemyTarget()
    if not targetPlr or not targetPlr.Character then
        Notify("KING GAEL • ⚡ TP", "No hay enemigos vivos cerca para teletransportarte.", 3)
        return
    end

    local enemyHrp = targetPlr.Character:FindFirstChild("HumanoidRootPart")
    if not enemyHrp then
        Notify("KING GAEL • ⚡ TP", "Objetivo sin posición válida.", 2.5)
        return
    end

    local behindOffset = -enemyHrp.CFrame.LookVector * 3.8 + Vector3.new(0, 1.5, 0)
    local destPos = enemyHrp.Position + behindOffset

    local ok = pcall(function()
        myHrp.AssemblyLinearVelocity = Vector3.zero
        myHrp.CFrame = CFrame.lookAt(destPos, enemyHrp.Position)
    end)

    if ok then
        PlayUiSound("boost")
        Notify("KING GAEL • ⚡ TP", string.format("Movido donde está %s (%.0fm).", targetPlr.DisplayName, dist), 3)
    else
        Notify("KING GAEL • ⚡ TP", "El juego bloqueó el teletransporte.", 3)
    end
end

local function processWeaponContainer(container)
    if not container then return end
    for _, desc in ipairs(container:GetDescendants()) do
        if State.InfiniteAmmo and (desc:IsA("NumberValue") or desc:IsA("IntValue")) then
            local n = string.lower(desc.Name)
            if string.find(n, "ammo") or string.find(n, "mag") or string.find(n, "clip") or string.find(n, "bullet") or string.find(n, "reserve") or string.find(n, "shell") then
                local maxVal = desc:GetAttribute("MaxAmmo") or desc:GetAttribute("MaxMag") or desc:GetAttribute("Max") or 999
                local targetNum = tonumber(maxVal) or 999
                if desc.Value < targetNum then
                    desc.Value = targetNum
                end
            end
        end

        if desc:IsA("Tool") or desc:IsA("Model") or desc:IsA("Configuration") or desc:IsA("Folder") then
            for attrName, attrVal in pairs(desc:GetAttributes()) do
                local low = string.lower(attrName)
                if State.InfiniteAmmo and type(attrVal) == "number" and (string.find(low, "ammo") or string.find(low, "mag") or string.find(low, "clip") or string.find(low, "bullet") or string.find(low, "reserve") or string.find(low, "shell")) then
                    local maxAttr = desc:GetAttribute("Max" .. attrName) or desc:GetAttribute("MaxAmmo") or desc:GetAttribute("MaxMag") or 999
                    local targetAttr = tonumber(maxAttr) or 999
                    if attrVal < targetAttr then
                        desc:SetAttribute(attrName, targetAttr)
                    end
                elseif State.FastReload then
                    if type(attrVal) == "boolean" and (string.find(low, "reload") or string.find(low, "reloading")) and attrVal == true then
                        desc:SetAttribute(attrName, false)
                    elseif type(attrVal) == "number" and (string.find(low, "reloadtime") or string.find(low, "cooldown") or string.find(low, "reloadspeed")) then
                        local floorTime = State.SafeMode and 0.15 or 0.05
                        if string.find(low, "speed") then
                            desc:SetAttribute(attrName, math.max(attrVal, 2.5))
                        elseif attrVal > floorTime then
                            desc:SetAttribute(attrName, floorTime)
                        end
                    end
                end
            end
        end

        if State.FastReload and (desc:IsA("BoolValue") or desc:IsA("NumberValue") or desc:IsA("IntValue")) then
            local n = string.lower(desc.Name)
            local floorTime = State.SafeMode and 0.15 or 0.05
            if desc:IsA("BoolValue") and (string.find(n, "reload") or string.find(n, "reloading")) and desc.Value == true then
                desc.Value = false
            elseif (desc:IsA("NumberValue") or desc:IsA("IntValue")) and (string.find(n, "reloadtime") or string.find(n, "cooldown")) and desc.Value > floorTime then
                desc.Value = floorTime
            end
        end
    end
end

local function clearBodyMoverByName(name)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local mover = hrp and hrp:FindFirstChild(name)
    if mover then
        pcall(function() mover:Destroy() end)
    end
end

local leapRunning = false
triggerLeapGlide = function()
    if leapRunning then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then
        Notify("KING GAEL • 🦘", "Personaje no disponible.", 2.5)
        return
    end

    leapRunning = true
    PlayUiSound("boost")

    local bv = hrp:FindFirstChild("KingGaelLeapGlide")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "KingGaelLeapGlide"
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Parent = hrp
    end

    local startT = os.clock()
    local duration = 4.0

    task.spawn(function()
        while (os.clock() - startT) < duration do
            local curChar = LocalPlayer.Character
            local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
            local curHum = curChar and curChar:FindFirstChildOfClass("Humanoid")
            if not curHrp or not curHum or curHum.Health <= 0 then break end

            local elapsed = os.clock() - startT
            local left = math.max(0, duration - elapsed)
            if LeapTimerLbl then
                LeapTimerLbl.Text = string.format("%.1fs", left)
            end

            local fwd = Camera.CFrame.LookVector
            local flatFwd = Vector3.new(fwd.X, 0, fwd.Z)
            if flatFwd.Magnitude > 0.01 then
                flatFwd = flatFwd.Unit
            else
                flatFwd = curHrp.CFrame.LookVector
            end

            local horizSpeed = State.SafeMode and 44 or 58
            local upBurst = State.SafeMode and 48 or 64
            local glideY = State.SafeMode and 4 or 8
            local yVel = (elapsed < 0.45) and upBurst or glideY
            bv.Velocity = flatFwd * horizSpeed + Vector3.new(0, yVel, 0)
            task.wait()
        end

        clearBodyMoverByName("KingGaelLeapGlide")
        if LeapTimerLbl then
            LeapTimerLbl.Text = ""
        end
        leapRunning = false
    end)
end

do
    local pTab = CreateTab("Jugador")
    AddSection(pTab, "Movimiento y Impulso")

    local flyActive = false
    local function stopFly()
        clearBodyMoverByName("KingGaelFly")
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
                    local flySpd = State.SafeMode and 44 or 62
                    bv.Velocity = mv * flySpd
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
            local targetSpd = State.SpeedRun and State.SpeedRunValue or State.WalkSpeed
            if State.SafeMode then
                targetSpd = math.min(targetSpd, 52)
            end
            h.WalkSpeed = targetSpd
        end
    end

    LocalPlayer.CharacterAdded:Connect(function()
        clearBodyMoverByName("KingGaelFly")
        clearBodyMoverByName("KingGaelLeapGlide")
        task.wait(0.15)
        applySpeed()
        if State.Fly then runFly() end
        if syncAmmoWatchdog then syncAmmoWatchdog() end
    end)

    UIS.JumpRequest:Connect(function()
        if State.InfiniteJump then
            local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)

    RunService.Stepped:Connect(function()
        if State.SpeedRun then
            applySpeed()
        end
        if State.Noclip and LocalPlayer.Character then
            for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)

    AddToggle(pTab, "Botón ⚡ TP Enemigo", false, function(v)
        State.TpBtnEnabled = v
        TpDock.Visible = v
    end)

    AddToggle(pTab, "Bloquear Posición ⚡", false, function(v)
        State.TpLocked = v
        TpLockBtn.Text = v and "🔒" or "🔓"
        TweenService:Create(TpLockBtn, TweenInfo.new(0.14), {
            BackgroundColor3 = v and Color3.fromRGB(48, 205, 130) or Color3.fromRGB(26, 29, 46)
        }):Play()
    end)

    AddToggle(pTab, "Botón 🦘 Leap (4s)", false, function(v)
        State.LeapGlide = v
        LeapDock.Visible = v
    end)

    AddToggle(pTab, "Bloquear Posición 🦘", false, function(v)
        State.LeapLocked = v
        LeapLockBtn.Text = v and "🔒" or "🔓"
        TweenService:Create(LeapLockBtn, TweenInfo.new(0.14), {
            BackgroundColor3 = v and Color3.fromRGB(48, 205, 130) or Color3.fromRGB(26, 29, 46)
        }):Play()
    end)

    AddButton(pTab, "TP Donde Está el Enemigo", function()
        teleportToEnemy()
    end)

    AddToggle(pTab, "Speed Run", false, function(v)
        State.SpeedRun = v
        applySpeed()
    end)

    AddSlider(pTab, "Speed Run Power", 20, 120, 2, 38, " spd", function(v)
        State.SpeedRunValue = v
        applySpeed()
    end)

    AddToggle(pTab, "Traspasar Paredes", false, function(v)
        State.Noclip = v
    end)

    AddToggle(pTab, "Fly", false, function(v)
        State.Fly = v
        if v then runFly() else stopFly() end
    end)

    AddToggle(pTab, "Infinite Jump", false, function(v) State.InfiniteJump = v end)

    AddSlider(pTab, "WalkSpeed", 16, 150, 1, 16, " WS", function(v)
        State.WalkSpeed = v
        applySpeed()
    end)
end

local fovScale = IsMobile and 48 or 60
local getFovRadius = function() return State.FovLevel * fovScale end

do
    local cTab = CreateTab("Combate")
    AddSection(cTab, "Munición y Apuntado")

    local ammoLoopRunning = false
    syncAmmoWatchdog = function()
        if ammoLoopRunning or not State.InfiniteAmmo then return end
        ammoLoopRunning = true
        task.spawn(function()
            while State.InfiniteAmmo do
                pcall(function()
                    processWeaponContainer(LocalPlayer.Character)
                    processWeaponContainer(LocalPlayer:FindFirstChild("Backpack"))
                end)
                task.wait(State.SafeMode and 0.18 or 0.08)
            end
            ammoLoopRunning = false
        end)
    end

    AddToggle(cTab, "Infinite Ammo Pro", false, function(v)
        State.InfiniteAmmo = v
        if v then
            pcall(function()
                processWeaponContainer(LocalPlayer.Character)
                processWeaponContainer(LocalPlayer:FindFirstChild("Backpack"))
            end)
            syncAmmoWatchdog()
        end
    end)

    AddToggle(cTab, "Fast Reload Boost", true, function(v)
        State.FastReload = v
        if v then
            pcall(function()
                processWeaponContainer(LocalPlayer.Character)
                processWeaponContainer(LocalPlayer:FindFirstChild("Backpack"))
            end)
        end
    end)

    AddToggle(cTab, "Silent Aim (Full Range)", false, function(v)
        State.SilentAim = v
        if getgenv then getgenv().SilentAimEnabled = v end
    end)

    AddToggle(cTab, "Soft Lock (FOV Only)", false, function(v)
        State.SoftLock = v
        if getgenv then getgenv().SoftLockEnabled = v end
    end)

    AddSlider(cTab, "Soft Lock Suavidad", 5, 60, 5, 26, "%", function(v)
        State.SoftLockSmooth = v / 100
    end)

    AddSlider(cTab, "Max Distance", 100, 2000, 50, 600, " st", function(v) State.MaxDistance = v end)

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
    FovStroke.Color = getRainbowColor(0)
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
        bs.Color = getRainbowColor(0)
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

emergencyResetAll = function()
    State.Fly = false
    State.SpeedRun = false
    State.Noclip = false
    State.InfiniteJump = false
    State.SilentAim = false
    State.SoftLock = false
    State.FovEnabled = false
    State.Chams = false
    State.Tracers = false
    State.BoxEsp = false
    State.TopLine = false
    State.Marker = false
    clearBodyMoverByName("KingGaelFly")
    clearBodyMoverByName("KingGaelLeapGlide")
    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = 16 end
    for _, plr in ipairs(Players:GetPlayers()) do
        local hl = plr.Character and plr.Character:FindFirstChild("Highlight")
        if hl then hl.Enabled = false end
    end
    PlayUiSound("off")
    Notify("KING GAEL", "Funciones activas limpiadas y velocidad restaurada.", 3)
end

do
    local vTab = CreateTab("Visuales")
    AddSection(vTab, "Seguridad y Control")
    AddToggle(vTab, "Modo Precaución (Límites)", true, function(v)
        State.SafeMode = v
        if StatusLbl then
            StatusLbl.Text = v and "RIVALS • SAFE ON" or "RIVALS • MAX PWR"
        end
        Notify("KING GAEL", v and "Límites moderados activos en movimiento/TP." or "Límites altos activados.", 2.5)
    end)
    AddButton(vTab, "Limpieza Rápida (Reset Movimiento/ESP)", function()
        emergencyResetAll()
    end)

    AddSection(vTab, "Comunidad y Sonido")
    AddButton(vTab, "Copiar Canal WhatsApp", function()
        PlayUiSound("boost")
        local ok = pcall(function()
            if setclipboard then setclipboard(WHATSAPP_CHANNEL_URL)
            elseif toclipboard then toclipboard(WHATSAPP_CHANNEL_URL)
            else error() end
        end)
        Notify("KING GAEL", ok and "Enlace copiado." or WHATSAPP_CHANNEL_URL, 3)
    end)
    AddButton(vTab, "Mostrar Tarjeta WhatsApp", function()
        PlayUiSound("on")
        WaBanner.Visible = true
    end)
    AddToggle(vTab, "Menu Sounds", true, function(v) State.Sounds = v end)
    AddSlider(vTab, "Sound Volume", 10, 100, 5, 85, "%", function(v)
        State.SoundVolume = v / 100
        syncSfxVolumes()
    end)
    AddToggle(vTab, "Quick Button", true, function(v) State.QuickBtn = v QuickBtn.Visible = v end)

    AddSection(vTab, "Rendimiento")
    AddToggle(vTab, "Fullbright", false, function(v)
        State.Fullbright = v
        Lighting.Brightness = v and 2 or 1
        Lighting.ClockTime = v and 14 or 12
        Lighting.GlobalShadows = not v
    end)
    AddButton(vTab, "EXTREME FPS BOOST", function()
        PlayUiSound("on")
        local char = LocalPlayer.Character
        for _, v in ipairs(workspace:GetDescendants()) do
            local isSelf = char and (v == char or v:IsDescendantOf(char))
            if not isSelf then
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                elseif v:IsA("Texture") or v:IsA("Decal") then
                    v:Destroy()
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") then
                    v.Enabled = false
                end
            end
        end
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("PostProcessEffect") then v.Enabled = false end
        end
        Notify("KING GAEL", "Optimización aplicada para Rivals.", 3)
    end)
end

loadInitialImages()

--------------------------------------------------
-- 🌈 BUCLE PRINCIPAL LIGERO
--------------------------------------------------
local activeTargetPos = nil

RunService.RenderStepped:Connect(function()
    local curCam = workspace.CurrentCamera
    if curCam then
        Camera = curCam
    end

    local col = getRainbowColor(0)

    for i = #uiRainbowStrokes, 1, -1 do
        local item = uiRainbowStrokes[i]
        if item.stroke and item.stroke.Parent then
            item.stroke.Color = getRainbowColor(item.phase)
        elseif not item.stroke then
            table.remove(uiRainbowStrokes, i)
        end
    end

    for i = #uiRainbowAccents, 1, -1 do
        local item = uiRainbowAccents[i]
        if item.obj and item.obj.Parent then
            item.obj[item.prop] = getRainbowColor(item.phase)
        elseif not item.obj then
            table.remove(uiRainbowAccents, i)
        end
    end

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
    local idx = 0

    for plr, d in pairs(espMap) do
        idx += 1
        local pCol = getRainbowColor(idx * 0.14)
        local char = plr.Character
        local head = char and char:FindFirstChild("Head")
        local torso = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart"))
        local hrp = char and (char:FindFirstChild("HumanoidRootPart") or torso)

        if head and torso and hrp and isEnemy(plr) and isCharacterAlive(char) then
            local dist = (head.Position - camPos).Magnitude
            local inRange = dist <= State.MaxDistance
            local hPos, hOn = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local fPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.7, 0))
            local tPos, tOn = Camera:WorldToViewportPoint(torso.Position)

            local hl = char:FindFirstChild("Highlight")
            if State.Chams and inRange then
                if not hl then hl = Instance.new("Highlight", char) end
                hl.Enabled = true
                hl.FillColor = pCol
            elseif hl then
                hl.Enabled = false
            end

            if State.Tracers and tOn and inRange then
                setLine(d.tracer, center, Vector2.new(tPos.X, tPos.Y), pCol, d.th)
            else
                d.tracer.Visible = false
            end

            if State.TopLine and hOn and inRange then
                setLine(d.top, top, Vector2.new(hPos.X, hPos.Y), pCol, d.th)
            else
                d.top.Visible = false
            end

            if State.BoxEsp and hOn and inRange then
                local bh = math.clamp(math.abs(fPos.Y - hPos.Y), 14, 320)
                local bw = math.clamp(bh * 0.58, 10, 220)
                d.box.Size = UDim2.new(0, bw, 0, bh)
                d.box.Position = UDim2.new(0, hPos.X - bw * 0.5, 0, hPos.Y)
                d.bs.Color = pCol
                d.box.Visible = true
            else
                d.box.Visible = false
            end

            if State.Marker and hOn and inRange then
                d.mk.Position = UDim2.new(0, hPos.X, 0, math.max(10, hPos.Y - 10))
                d.mk.BackgroundColor3 = pCol
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

    if State.SoftLock and activeTargetPos then
        pcall(function()
            local goalCf = CFrame.lookAt(Camera.CFrame.Position, activeTargetPos)
            local alpha = State.SafeMode and math.min(State.SoftLockSmooth, 0.22) or State.SoftLockSmooth
            Camera.CFrame = Camera.CFrame:Lerp(goalCf, alpha)
        end)
    end
end)

if hookmetamethod and newcclosure then
    pcall(function()
        local oldIdx
        oldIdx = hookmetamethod(game, "__index", newcclosure(function(self, idx)
            if State.SilentAim and activeTargetPos and not checkcaller() and idx == "ViewportSize" and self == Camera then
                local pos, on = Camera:WorldToViewportPoint(activeTargetPos)
                if on then return Vector2.new(pos.X * 2, pos.Y * 2) end
            end
            return oldIdx(self, idx)
        end))
    end)
end

PlayUiSound("on")
if game.PlaceId == TARGET_PLACE_ID then
    Notify("KING GAEL", "GOD PRO cargado para RIVALS (17625359962).", 3.5)
else
    Notify("KING GAEL", "GOD PRO cargado (PlaceId: " .. tostring(game.PlaceId) .. ").", 3.5)
end
