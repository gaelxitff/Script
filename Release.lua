--// SERVICIOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

--------------------------------------------------
-- ✨ INICIALIZACIÓN DE INTERFAZ (F$VL)
--------------------------------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
task.wait(0.4)

local Window = Rayfield:CreateWindow({
    Name = "F$VL",
    Icon = 0,
    LoadingTitle = "F$VL",
    LoadingSubtitle = IsMobile and "Modo Móvil Activo • Cargando..." or "Cargando módulos y optimización...",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "F$VL_Config",
        FileName = "F$VL_Settings"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false
})

local PlayerTab = Window:CreateTab("Jugador", 4483362458)
local CombatTab = Window:CreateTab("Combate", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local VisualTab = Window:CreateTab("Visuales", 4483362458)

--------------------------------------------------
-- 🛡️ UTILIDADES
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
-- 🌧️ PARTÍCULAS CAYENDO + BOTÓN MÓVIL (F$VL)
--------------------------------------------------
local overlayGui = Instance.new("ScreenGui")
overlayGui.Name = "FSVL_Overlay"
overlayGui.IgnoreGuiInset = true
overlayGui.ResetOnSpawn = false
overlayGui.DisplayOrder = 50
overlayGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local particlesContainer = Instance.new("Frame")
particlesContainer.Name = "FallingParticles"
particlesContainer.Size = UDim2.new(1, 0, 1, 0)
particlesContainer.BackgroundTransparency = 1
particlesContainer.Active = false
particlesContainer.Parent = overlayGui

local particlesEnabled = true
local particleCount = IsMobile and 24 or 42
local particles = {}

local function createParticle()
    local dot = Instance.new("Frame")
    local size = math.random(4, 9)
    dot.Size = UDim2.new(0, size, 0, size)
    dot.Position = UDim2.new(math.random(), 0, -math.random() * 0.5, 0)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BackgroundTransparency = math.random(25, 65) / 100
    dot.BorderSizePixel = 0
    dot.Active = false
    dot.Parent = particlesContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = dot

    return {
        frame = dot,
        speedY = math.random(45, 130),
        driftX = math.random(-25, 25),
        phase = math.random() * math.pi * 2
    }
end

for i = 1, particleCount do
    table.insert(particles, createParticle())
end

-- Botón flotante para móvil / toque rápido
local mobileToggleBtn = Instance.new("TextButton")
mobileToggleBtn.Name = "FSVL_MobileToggle"
mobileToggleBtn.Size = IsMobile and UDim2.new(0, 62, 0, 34) or UDim2.new(0, 56, 0, 30)
mobileToggleBtn.Position = IsMobile and UDim2.new(0, 14, 0.5, -17) or UDim2.new(0, 14, 0, 14)
mobileToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
mobileToggleBtn.BackgroundTransparency = 0.15
mobileToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
mobileToggleBtn.Text = "F$VL"
mobileToggleBtn.Font = Enum.Font.GothamBold
mobileToggleBtn.TextSize = IsMobile and 14 or 12
mobileToggleBtn.Visible = IsMobile
mobileToggleBtn.Parent = overlayGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = mobileToggleBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Thickness = 1.5
btnStroke.Parent = mobileToggleBtn

local menuVisible = true
mobileToggleBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    pcall(function()
        if Rayfield.SetVisibility then
            Rayfield:SetVisibility(menuVisible)
        elseif Rayfield.Toggle then
            Rayfield:Toggle()
        end
    end)
end)

--------------------------------------------------
-- 👤 PESTAÑA: JUGADOR
--------------------------------------------------
PlayerTab:CreateSection("Movimiento")

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

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "FSVL_Fly",
    Callback = function(v)
        flying = v
        if v then
            task.spawn(Fly)
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "FSVL_InfJump",
    Callback = function(v)
        infiniteJump = v
    end
})

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "FSVL_Noclip",
    Callback = function(v)
        noclip = v
    end
})

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    Suffix = " WS",
    CurrentValue = 16,
    Flag = "FSVL_WalkSpeed",
    Callback = function(v)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end
})

--------------------------------------------------
-- ⚔️ PESTAÑA: COMBATE
--------------------------------------------------
CombatTab:CreateSection("Apuntado y Objetivos")

local maxDistance = 500
getgenv().SilentAimEnabled = false
getgenv().SoftLockEnabled = false
local fovEnabled = false
local fovScale = IsMobile and 48 or 60
local calculatedRadius = 3 * fovScale

CombatTab:CreateToggle({
    Name = "Silent Aim (Full Range)",
    CurrentValue = false,
    Flag = "FSVL_SilentAim",
    Callback = function(v)
        getgenv().SilentAimEnabled = v
    end
})

CombatTab:CreateToggle({
    Name = "Soft Lock (FOV Only)",
    CurrentValue = false,
    Flag = "FSVL_SoftLock",
    Callback = function(v)
        getgenv().SoftLockEnabled = v
    end
})

CombatTab:CreateSlider({
    Name = "Max Distance",
    Range = {100, 2000},
    Increment = 50,
    Suffix = " studs",
    CurrentValue = 500,
    Flag = "FSVL_MaxDist",
    Callback = function(v)
        maxDistance = v
    end
})

CombatTab:CreateSection("Configuración FOV")

CombatTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = false,
    Flag = "FSVL_ShowFOV",
    Callback = function(v)
        fovEnabled = v
    end
})

CombatTab:CreateSlider({
    Name = "FOV Level (1-10)",
    Range = {1, 10},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 3,
    Flag = "FSVL_FOVLevel",
    Callback = function(v)
        calculatedRadius = v * fovScale
    end
})

local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.Active = false
fovCircle.Parent = overlayGui

local stroke = Instance.new("UIStroke")
stroke.Thickness = IsMobile and 2.5 or 2
stroke.Parent = fovCircle

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = fovCircle

--------------------------------------------------
-- 👁️ PESTAÑA: ESP
--------------------------------------------------
ESPTab:CreateSection("Visuales de Enemigos")

local chamsEnabled, tracersEnabled = false, false
local tracers = {}

ESPTab:CreateToggle({
    Name = "Enemy Chams",
    CurrentValue = false,
    Flag = "FSVL_Chams",
    Callback = function(v)
        chamsEnabled = v
    end
})

ESPTab:CreateToggle({
    Name = "Crosshair Tracers (Torso)",
    CurrentValue = false,
    Flag = "FSVL_Tracers",
    Callback = function(v)
        tracersEnabled = v
    end
})

local function createTracer(plr)
    local l = Drawing.new("Line")
    l.Thickness = IsMobile and 2 or 1.5
    l.Transparency = 1
    l.Visible = false
    tracers[plr] = l
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        createTracer(p)
    end
end
Players.PlayerAdded:Connect(createTracer)

Players.PlayerRemoving:Connect(function(plr)
    if tracers[plr] then
        tracers[plr].Visible = false
        tracers[plr]:Remove()
        tracers[plr] = nil
    end
end)

--------------------------------------------------
-- 🔥 MOTOR PRINCIPAL
--------------------------------------------------
local activeTargetPos = nil

RunService.RenderStepped:Connect(function(dt)
    local rgb = Color3.fromHSV((tick() % 5) / 5, 1, 1)
    local screenCenter = Camera.ViewportSize / 2
    local viewW = Camera.ViewportSize.X
    local viewH = Camera.ViewportSize.Y

    -- Actualizar partículas cayendo
    particlesContainer.Visible = particlesEnabled
    if particlesEnabled and viewW > 0 and viewH > 0 then
        for _, p in ipairs(particles) do
            local pos = p.frame.Position
            local absX = pos.X.Scale * viewW + pos.X.Offset
            local absY = pos.Y.Scale * viewH + pos.Y.Offset

            absY += p.speedY * dt
            absX += (p.driftX + math.sin(tick() * 2 + p.phase) * 14) * dt

            if absY > viewH + 20 then
                absY = -math.random(10, 80)
                absX = math.random(0, viewW)
            end

            p.frame.Position = UDim2.new(0, absX, 0, absY)
            p.frame.BackgroundColor3 = rgb
        end
    end

    if mobileToggleBtn.Visible then
        btnStroke.Color = rgb
    end

    fovCircle.Visible = fovEnabled
    if fovEnabled then
        fovCircle.Size = UDim2.new(0, calculatedRadius * 2, 0, calculatedRadius * 2)
        stroke.Color = rgb
    end

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
                    tracer.Visible = (tracersEnabled and torsoOnScreen and distFromMe <= maxDistance)
                    if tracer.Visible then
                        tracer.From = screenCenter
                        tracer.To = Vector2.new(torsoPos.X, torsoPos.Y)
                        tracer.Color = rgb
                    end
                end

                highlight.Enabled = chamsEnabled
                highlight.FillColor = rgb

                if headOnScreen and distFromMe <= maxDistance then
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
            end
        elseif tracer then
            tracer.Visible = false
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
VisualTab:CreateSection("Estilo y Pantalla")

VisualTab:CreateToggle({
    Name = "Falling Particles",
    CurrentValue = true,
    Flag = "FSVL_Particles",
    Callback = function(v)
        particlesEnabled = v
    end
})

VisualTab:CreateToggle({
    Name = "Mobile Quick Button",
    CurrentValue = IsMobile,
    Flag = "FSVL_MobileBtn",
    Callback = function(v)
        mobileToggleBtn.Visible = v
    end
})

VisualTab:CreateSection("Iluminación y Rendimiento")

VisualTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "FSVL_Fullbright",
    Callback = function(v)
        Lighting.Brightness = v and 2 or 1
        Lighting.ClockTime = v and 14 or 12
        Lighting.GlobalShadows = not v
    end
})

VisualTab:CreateButton({
    Name = "EXTREME FPS BOOST",
    Callback = function()
        -- 1. Quitar texturas y cambiar material del mapa
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsAncestorOf(LocalPlayer.Character) then
                v.Material = Enum.Material.SmoothPlastic
            elseif v:IsA("Texture") or v:IsA("Decal") then
                v:Destroy()
            -- 2. Desactivar efectos visuales y partículas
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Explosion") then
                v.Enabled = false
            end
        end

        -- 3. Desactivar post-procesado
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostProcessEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") then
                v.Enabled = false
            end
        end

        Rayfield:Notify({
            Title = "F$VL • Optimizado",
            Content = "Texturas, VFX y post-procesado eliminados para subir FPS.",
            Duration = 3.5,
            Image = 4483362458
        })
    end
})

Rayfield:Notify({
    Title = "F$VL",
    Content = IsMobile and "Cargado en modo móvil con partículas activas." or "Cargado correctamente con partículas activas.",
    Duration = 3.5,
    Image = 4483362458
})
