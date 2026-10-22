-- ==========================================
-- 🎯 SANCHO HUB | RIVALS ULTIMATE EDITION
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- UI LIBRARY (RAYFIELD)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
task.wait(0.5)

-- ==========================================
-- 🌎 SISTEMA DE IDIOMAS (ES/EN)
-- ==========================================
local Language = "ES"
local Texts = {
    ES = {
        Title = "🎯 Sancho Hub | RIVALS",
        PlayerTab = "👤 Jugador",
        CombatTab = "⚔️ Combate",
        ESPTab = "👁️ ESP",
        WorldTab = "🌍 Mundo",
        VisualTab = "🎨 Visuales",
        SettingsTab = "⚙️ Ajustes",
        
        -- Player
        Movement = "Movimiento",
        Fly = "✈️ Volar",
        InfJump = "🦘 Salto Infinito",
        Noclip = "👻 Atravesar Paredes",
        Speed = "🏃 Velocidad",
        
        -- Combat
        AimbotS = "Aimbot",
        SilentAim = "🎯 Silent Aim",
        SoftLock = "🔒 Soft Lock",
        MaxDist = "📏 Distancia Máxima",
        Hitbox = "📦 Expandir Hitbox",
        AutoShoot = "🔫 Disparo Automático",
        
        -- ESP
        ESPVisuals = "Visuales ESP",
        Chams = "🌈 Chams",
        Tracers = "📏 Tracers",
        Boxes = "🟥 Cajas (Box)",
        Names = "📝 Nombres",
        Health = "❤️ Barra de Vida",
        
        -- World
        WorldSettings = "Ajustes del Mundo",
        Time = "🕒 Cambiar Hora",
        Fullbright = "☀️ Fullbright",
        
        -- Visuals
        FOVSettings = "Ajustes FOV",
        ShowFOV = "⭕ Mostrar Círculo FOV",
        FOVLevel = "🌀 Tamaño FOV",
        Performance = "Rendimiento",
        FPSBoost = "🚀 AUMENTAR FPS EXTREMO",
        RemoveTextures = "🧹 Quitar Texturas"
    },
    EN = {
        Title = "🎯 Sancho Hub | RIVALS",
        PlayerTab = "👤 Player",
        CombatTab = "⚔️ Combat",
        ESPTab = "👁️ ESP",
        WorldTab = "🌍 World",
        VisualTab = "🎨 Visuals",
        SettingsTab = "⚙️ Settings",
        
        -- Player
        Movement = "Movement",
        Fly = "✈️ Fly",
        InfJump = "🦘 Infinite Jump",
        Noclip = "👻 Noclip",
        Speed = "🏃 WalkSpeed",
        
        -- Combat
        AimbotS = "Aimbot",
        SilentAim = "🎯 Silent Aim",
        SoftLock = "🔒 Soft Lock",
        MaxDist = "📏 Max Distance",
        Hitbox = "📦 Hitbox Expander",
        AutoShoot = "🔫 Auto Shoot",
        
        -- ESP
        ESPVisuals = "ESP Visuals",
        Chams = "🌈 Chams",
        Tracers = "📏 Tracers",
        Boxes = "🟥 Boxes",
        Names = "📝 Names",
        Health = "❤️ Health Bar",
        
        -- World
        WorldSettings = "World Settings",
        Time = "🕒 Time of Day",
        Fullbright = "☀️ Fullbright",
        
        -- Visuals
        FOVSettings = "FOV Settings",
        ShowFOV = "⭕ Show FOV",
        FOVLevel = "🌀 FOV Size",
        Performance = "Performance",
        FPSBoost = "🚀 EXTREME FPS BOOST",
        RemoveTextures = "🧹 Remove Textures"
    }
}

-- ==========================================
-- CREACIÓN DE LA UI
-- ==========================================
local function CreateMenu()
    local Window = Rayfield:CreateWindow({
        Name = Texts[Language].Title,
        LoadingTitle = "Cargando...",
        LoadingSubtitle = "by Sancho",
        ConfigurationSaving = { Enabled = false }
    })

    -- Pestañas
    local PlayerTab = Window:CreateTab(Texts[Language].PlayerTab, 4483362458)
    local CombatTab = Window:CreateTab(Texts[Language].CombatTab, 4483362458)
    local ESPTab = Window:CreateTab(Texts[Language].ESPTab, 4483362458)
    local WorldTab = Window:CreateTab(Texts[Language].WorldTab, 4483362458)
    local VisualTab = Window:CreateTab(Texts[Language].VisualTab, 4483362458)
    local SettingsTab = Window:CreateTab(Texts[Language].SettingsTab, 4483362458)

    -- ==========================================
    -- 🛡️ UTILIDADES
    -- ==========================================
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

    -- ==========================================
    -- 👤 PESTAÑA JUGADOR
    -- ==========================================
    PlayerTab:CreateSection(Texts[Language].Movement)
    local flying, infiniteJump, noclip = false, false, false

    local function Fly()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
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
        bv:Destroy()
    end

    UIS.JumpRequest:Connect(function() if infiniteJump then local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if h then h:ChangeState("Jumping") end end end)
    RunService.Stepped:Connect(function() if noclip and LocalPlayer.Character then for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end end)

    PlayerTab:CreateToggle({Name=Texts[Language].Fly, Callback=function(v) flying=v if v then task.spawn(Fly) end end})
    PlayerTab:CreateToggle({Name=Texts[Language].InfJump, Callback=function(v) infiniteJump=v end})
    PlayerTab:CreateToggle({Name=Texts[Language].Noclip, Callback=function(v) noclip=v end})
    PlayerTab:CreateSlider({Name=Texts[Language].Speed, Range={16, 200}, Increment=1, CurrentValue=16, Callback=function(v) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end end})

    -- ==========================================
    -- ⚔️ PESTAÑA COMBATE
    -- ==========================================
    CombatTab:CreateSection(Texts[Language].AimbotS)
    local maxDistance = 500
    getgenv().SilentAimEnabled = false
    getgenv().SoftLockEnabled = false
    local fovEnabled = false
    local calculatedRadius = 180 

    CombatTab:CreateToggle({Name=Texts[Language].SilentAim, Callback=function(v) getgenv().SilentAimEnabled = v end})
    CombatTab:CreateToggle({Name=Texts[Language].SoftLock, Callback=function(v) getgenv().SoftLockEnabled = v end})
    CombatTab:CreateSlider({Name=Texts[Language].MaxDist, Range={100, 2000}, Increment=50, CurrentValue=500, Callback=function(v) maxDistance = v end})
    
    CombatTab:CreateToggle({Name=Texts[Language].Hitbox, Callback=function(v) 
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                p.Character.Head.Size = v and Vector3.new(10,10,10) or Vector3.new(2,1,1)
                p.Character.Head.Transparency = v and 0.5 or 0
                p.Character.Head.CanCollide = false
            end
        end
    end})

    CombatTab:CreateSection(Texts[Language].FOVSettings)
    CombatTab:CreateToggle({Name=Texts[Language].ShowFOV, Callback=function(v) fovEnabled = v end})
    CombatTab:CreateSlider({Name=Texts[Language].FOVLevel, Range={1, 10}, Increment=1, CurrentValue=3, Callback=function(v) calculatedRadius = v * 60 end})

    local mainGui = Instance.new("ScreenGui", (gethui and gethui()) or game:GetService("CoreGui"))
    mainGui.IgnoreGuiInset = true 
    local fovCircle = Instance.new("Frame", mainGui)
    local stroke = Instance.new("UIStroke", fovCircle); local corner = Instance.new("UICorner", fovCircle)
    fovCircle.AnchorPoint = Vector2.new(0.5, 0.5); fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    fovCircle.BackgroundTransparency = 1; stroke.Thickness = 2; corner.CornerRadius = UDim.new(1, 0)

    -- ==========================================
    -- 👁️ PESTAÑA ESP
    -- ==========================================
    local chamsEnabled, tracersEnabled, boxesEnabled, namesEnabled, healthEnabled = false, false, false, false, false
    local tracers = {}
    local drawings = {}

    ESPTab:CreateSection(Texts[Language].ESPVisuals)
    ESPTab:CreateToggle({Name=Texts[Language].Chams, Callback=function(v) chamsEnabled = v end})
    ESPTab:CreateToggle({Name=Texts[Language].Tracers, Callback=function(v) tracersEnabled = v end})
    ESPTab:CreateToggle({Name=Texts[Language].Boxes, Callback=function(v) boxesEnabled = v end})
    ESPTab:CreateToggle({Name=Texts[Language].Names, Callback=function(v) namesEnabled = v end})
    ESPTab:CreateToggle({Name=Texts[Language].Health, Callback=function(v) healthEnabled = v end})

    local function createDrawings(plr)
        tracers[plr] = Drawing.new("Line")
        tracers[plr].Thickness = 1.5; tracers[plr].Transparency = 1; tracers[plr].Visible = false
        
        drawings[plr] = {
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Health = Drawing.new("Square"),
            HealthBg = Drawing.new("Square")
        }
        drawings[plr].Box.Thickness = 1.5; drawings[plr].Box.Filled = false; drawings[plr].Box.Visible = false
        drawings[plr].Name.Center = true; drawings[plr].Name.Outline = true; drawings[plr].Name.Size = 14; drawings[plr].Name.Visible = false
        drawings[plr].Health.Filled = true; drawings[plr].Health.Visible = false
        drawings[plr].HealthBg.Filled = true; drawings[plr].HealthBg.Color = Color3.new(0,0,0); drawings[plr].HealthBg.Visible = false
    end
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then createDrawings(p) end end
    Players.PlayerAdded:Connect(createDrawings)

    -- ==========================================
    -- 🔥 MOTOR PRINCIPAL (AIMBOT / ESP)
    -- ==========================================
    local activeTargetPos = nil 

    RunService.RenderStepped:Connect(function()
        local rgb = Color3.fromHSV((tick() % 5) / 5, 1, 1)
        local screenCenter = Camera.ViewportSize / 2
        
        fovCircle.Visible = fovEnabled
        if fovEnabled then
            fovCircle.Size = UDim2.new(0, calculatedRadius * 2, 0, calculatedRadius * 2)
            stroke.Color = rgb
        end

        local bestHead = nil
        local shortestDist = 9e9

        for _, plr in pairs(Players:GetPlayers()) do
            local char = plr.Character
            if char and isEnemy(plr) then
                local head = char:FindFirstChild("Head")
                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local highlight = char:FindFirstChild("Highlight") or Instance.new("Highlight", char)
                
                if head and torso and humanoid then
                    local distFromMe = (head.Position - Camera.CFrame.Position).Magnitude
                    local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
                    local torsoPos, torsoOnScreen = Camera:WorldToViewportPoint(torso.Position)
                    local fovDist = (Vector2.new(headPos.X, headPos.Y) - screenCenter).Magnitude
                    
                    -- Chams
                    highlight.Enabled = chamsEnabled and distFromMe <= maxDistance; 
                    highlight.FillColor = rgb
                    
                    -- Tracers
                    if tracers[plr] then
                        tracers[plr].Visible = (tracersEnabled and torsoOnScreen and distFromMe <= maxDistance)
                        if tracers[plr].Visible then
                            tracers[plr].From = screenCenter 
                            tracers[plr].To = Vector2.new(torsoPos.X, torsoPos.Y)
                            tracers[plr].Color = rgb
                        end
                    end

                    -- Boxes, Names, Health
                    if drawings[plr] then
                        local draw = drawings[plr]
                        if headOnScreen and torsoOnScreen and distFromMe <= maxDistance then
                            local height = math.abs(torsoPos.Y - headPos.Y) * 1.5
                            local width = height / 2
                            
                            -- Boxes
                            draw.Box.Visible = boxesEnabled
                            draw.Box.Size = Vector2.new(width, height)
                            draw.Box.Position = Vector2.new(headPos.X - width/2, headPos.Y - height/4)
                            draw.Box.Color = rgb
                            
                            -- Names
                            draw.Name.Visible = namesEnabled
                            draw.Name.Text = plr.Name
                            draw.Name.Position = Vector2.new(headPos.X, headPos.Y - height/2 - 16)
                            draw.Name.Color = rgb
                            
                            -- Health
                            draw.Health.Visible = healthEnabled
                            draw.HealthBg.Visible = healthEnabled
                            if healthEnabled then
                                local hpPct = humanoid.Health / humanoid.MaxHealth
                                draw.Health.Size = Vector2.new(3, height * hpPct)
                                draw.Health.Position = Vector2.new(headPos.X - width/2 - 6, headPos.Y + height/2 - (height * hpPct))
                                draw.Health.Color = Color3.fromRGB(0, 255, 0)
                                
                                draw.HealthBg.Size = Vector2.new(3, height)
                                draw.HealthBg.Position = Vector2.new(headPos.X - width/2 - 6, headPos.Y - height/4)
                            end
                        else
                            draw.Box.Visible = false
                            draw.Name.Visible = false
                            draw.Health.Visible = false
                            draw.HealthBg.Visible = false
                        end
                    end

                    -- Aimbot Logic
                    if headOnScreen and distFromMe <= maxDistance then
                        if getgenv().SoftLockEnabled then
                            if fovDist <= calculatedRadius and fovDist < shortestDist then
                                local valid = getValidHead(char)
                                if valid then shortestDist = fovDist; bestHead = valid end
                            end
                        elseif getgenv().SilentAimEnabled then
                            if fovDist < shortestDist then
                                local valid = getValidHead(char)
                                if valid then shortestDist = fovDist; bestHead = valid end
                            end
                        end
                    end
                end
            end
        end
        activeTargetPos = bestHead and bestHead.Position or nil
    end)

    local old; old = hookmetamethod(game, "__index", newcclosure(function(self, idx)
        if (getgenv().SilentAimEnabled or getgenv().SoftLockEnabled) and activeTargetPos and not checkcaller() and idx == "ViewportSize" and self == Camera then
            local pos, on = Camera:WorldToViewportPoint(activeTargetPos)
            if on then return Vector2.new(pos.X * 2, pos.Y * 2) end
        end
        return old(self, idx)
    end))

    -- ==========================================
    -- 🌍 PESTAÑA MUNDO
    -- ==========================================
    WorldTab:CreateSection(Texts[Language].WorldSettings)
    WorldTab:CreateToggle({Name=Texts[Language].Fullbright, Callback=function(v) Lighting.Brightness = v and 2 or 1 Lighting.ClockTime = v and 14 or 12 Lighting.GlobalShadows = not v end})
    WorldTab:CreateSlider({Name=Texts[Language].Time, Range={0, 24}, Increment=1, CurrentValue=14, Callback=function(v) Lighting.ClockTime = v end})

    -- ==========================================
    -- 🎨 PESTAÑA VISUALES
    -- ==========================================
    VisualTab:CreateSection(Texts[Language].Performance)
    VisualTab:CreateButton({Name=Texts[Language].FPSBoost, Callback=function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsAncestorOf(LocalPlayer.Character) then
                v.Material = Enum.Material.SmoothPlastic
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Explosion") then
                v.Enabled = false
            end
        end
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostProcessEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") then
                v.Enabled = false
            end
        end
        Rayfield:Notify({Title="🚀 Optimized", Content="FPS Boost aplicado.", Duration=3})
    end})
    
    VisualTab:CreateButton({Name=Texts[Language].RemoveTextures, Callback=function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Texture") or v:IsA("Decal") then
                v:Destroy()
            end
        end
        Rayfield:Notify({Title="🧹 Cleaned", Content="Texturas eliminadas.", Duration=3})
    end})

    Rayfield:Notify({Title="✅ Loaded", Content="Sancho Hub cargado correctamente.", Duration=3})
end

-- ==========================================
-- LANZADOR DE MENÚ (SELECTOR DE IDIOMA)
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local LangGui = Instance.new("ScreenGui")
LangGui.Name = "LangSelect"
LangGui.Parent = CoreGui

local LangFrame = Instance.new("Frame", LangGui)
LangFrame.Size = UDim2.new(0, 250, 0, 150)
LangFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
LangFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", LangFrame).CornerRadius = UDim.new(0, 10)
local LStroke = Instance.new("UIStroke", LangFrame)
LStroke.Color = Color3.fromRGB(0, 150, 255)

local LTitle = Instance.new("TextLabel", LangFrame)
LTitle.Size = UDim2.new(1, 0, 0, 40)
LTitle.BackgroundTransparency = 1
LTitle.Text = "Select Language / Selecciona Idioma"
LTitle.TextColor3 = Color3.new(1,1,1)
LTitle.Font = Enum.Font.BuilderSansBold
LTitle.Parent = LangFrame

local BtnES = Instance.new("TextButton", LangFrame)
BtnES.Size = UDim2.new(0.4, 0, 0, 35)
BtnES.Position = UDim2.new(0.05, 0, 0, 60)
BtnES.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
BtnES.Text = "Español"
BtnES.TextColor3 = Color3.new(1,1,1)
BtnES.Font = Enum.Font.BuilderSansBold
Instance.new("UICorner", BtnES).CornerRadius = UDim.new(0, 6)

local BtnEN = Instance.new("TextButton", LangFrame)
BtnEN.Size = UDim2.new(0.4, 0, 0, 35)
BtnEN.Position = UDim2.new(0.55, 0, 0, 60)
BtnEN.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
BtnEN.Text = "English"
BtnEN.TextColor3 = Color3.new(1,1,1)
BtnEN.Font = Enum.Font.BuilderSansBold
Instance.new("UICorner", BtnEN).CornerRadius = UDim.new(0, 6)

BtnES.MouseButton1Click:Connect(function()
    Language = "ES"
    LangGui:Destroy()
    CreateMenu()
end)

BtnEN.MouseButton1Click:Connect(function()
    Language = "EN"
    LangGui:Destroy()
    CreateMenu()
end)
