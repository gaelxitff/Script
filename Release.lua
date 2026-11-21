do
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")
	local CoreGui = game:GetService("CoreGui")
	local TweenService = game:GetService("TweenService")
	local Workspace = game:GetService("Workspace")
	local SoundService = game:GetService("SoundService")
	local Debris = game:GetService("Debris")

	local LocalPlayer = Players.LocalPlayer
	local Camera = Workspace.CurrentCamera

	local GUN_NAMES = { "Gun", "Revolver", "Pistol" }

	local ColorPalette = {
		{ Name = "Red", Color = Color3.fromRGB(255, 50, 50) },
		{ Name = "Blue", Color = Color3.fromRGB(50, 140, 255) },
		{ Name = "Green", Color = Color3.fromRGB(50, 255, 100) },
		{ Name = "Yellow", Color = Color3.fromRGB(255, 220, 50) },
		{ Name = "Purple", Color = Color3.fromRGB(180, 50, 255) },
		{ Name = "Cyan", Color = Color3.fromRGB(0, 255, 255) },
		{ Name = "Pink", Color = Color3.fromRGB(255, 50, 150) },
		{ Name = "White", Color = Color3.fromRGB(255, 255, 255) }
	}

	local Config = {
		LogoId = "rbxassetid://123799479988356",
		ESPEnabled = false,
		ESPHighlight = true,
		TracersEnabled = false,
		ChamGunEnabled = true,
		GunTracerEnabled = false,
		ColorMurder = ColorPalette[1].Color,
		ColorSheriff = ColorPalette[2].Color,
		ColorInnocent = ColorPalette[3].Color,
		ColorGun = Color3.fromRGB(255, 215, 0),
		AimbotEnabled = false,
		AimbotSmooth = 0.15,
		ShowFOVCircle = true,
		ScreenFOV = 250,
		LockDistance = 150,
		SoundsEnabled = true
	}

	local Songs = {
		{ name = "Sunflower - Post Malone", id = "97898853555749" },
		{ name = "Mask Off", id = "118893494775965" },
		{ name = "Billie Jean", id = "116197983114890" },
		{ name = "Misery", id = "121397051787416" },
		{ name = "Terraway", id = "82746224492420" },
		{ name = "Ra Ta Ta Phonk", id = "90851490275942" },
		{ name = "Next to Me", id = "81732137163686" },
		{ name = "Bazooka", id = "121252909004354" },
		{ name = "Birdbrain", id = "73585961437875" },
		{ name = "Fashion Center", id = "87570666848900" },
		{ name = "Pixy - Legacy", id = "98250122413808" }
	}

	local XOLO = {
		BG = Color3.fromRGB(8, 8, 12),
		BG2 = Color3.fromRGB(15, 12, 20),
		Panel = Color3.fromRGB(22, 22, 28),
		Panel2 = Color3.fromRGB(35, 35, 45),
		Accent = Color3.fromRGB(0, 230, 255),
		Accent2 = Color3.fromRGB(180, 50, 255),
		White = Color3.fromRGB(255, 255, 255),
		Text = Color3.fromRGB(235, 235, 240),
		Muted = Color3.fromRGB(120, 120, 130),
		Red = Color3.fromRGB(255, 60, 60)
	}

	local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

	local function PlaySound(kind)
		if not Config.SoundsEnabled then return end
		pcall(function()
			local s = Instance.new("Sound")
			s.SoundId = "rbxasset://sounds/electronicpingshort.wav"
			s.Volume = 0.2
			s.PlaybackSpeed = (kind == "open" and 1.4) or (kind == "close" and 0.8) or (kind == "click" and 1.2) or 1
			s.Parent = SoundService
			s:Play()
			Debris:AddItem(s, 2)
		end)
	end

	local function MakeDraggable(frame, handle)
		local dragging, dragStart, startPos
		handle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = frame.Position
			end
		end)
		UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				frame.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end)
	end

	-- Drawing API Pool
	local HasDrawing = pcall(function()
		local test = Drawing.new("Line")
		test:Remove()
	end)

	local BoxLinePool = {}
	local BoxLineIndex = 0

	local TracerLinePool = {}
	local TracerLineIndex = 0

	local GunTracerLine = nil
	local FOVCircle = nil

	if HasDrawing then
		FOVCircle = Drawing.new("Circle")
		FOVCircle.Thickness = 1.5
		FOVCircle.NumSides = 80
		FOVCircle.Filled = false
		FOVCircle.Transparency = 0.8
		FOVCircle.Color = XOLO.Accent
		FOVCircle.Visible = false

		GunTracerLine = Drawing.new("Line")
		GunTracerLine.Thickness = 1.8
		GunTracerLine.Transparency = 0.9
		GunTracerLine.Color = Config.ColorGun
		GunTracerLine.Visible = false
	end

	local function AcquireFromPool(pool, index, thickness, transparency)
		local line = pool[index]
		if not line then
			line = Drawing.new("Line")
			pool[index] = line
		end
		line.Thickness = thickness or 1.5
		line.Transparency = transparency or 1
		line.Visible = false
		return line
	end

	local function GetBoxLine()
		BoxLineIndex += 1
		return AcquireFromPool(BoxLinePool, BoxLineIndex, 1.5, 1)
	end

	local function ClearBoxLines()
		for _, l in ipairs(BoxLinePool) do
			l.Visible = false
		end
		BoxLineIndex = 0
	end

	local function GetTracerLine()
		TracerLineIndex += 1
		return AcquireFromPool(TracerLinePool, TracerLineIndex, 1.3, 0.85)
	end

	local function ClearTracerLines()
		for _, l in ipairs(TracerLinePool) do
			l.Visible = false
		end
		TracerLineIndex = 0
	end

	local function HideGunTracer()
		if GunTracerLine then
			GunTracerLine.Visible = false
		end
	end

	-- Helpers de Jugadores y Armas
	local function getHRP()
		return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	end

	local function IsGunName(name)
		if type(name) ~= "string" then return false end
		for _, gName in ipairs(GUN_NAMES) do
			if name == gName then
				return true
			end
		end
		return false
	end

	local function HasTool(p, name)
		if not p then return false end
		local c = p.Character
		local bp = p:FindFirstChild("Backpack")
		return (c and c:FindFirstChild(name)) ~= nil or (bp and bp:FindFirstChild(name)) ~= nil
	end

	local function IsMurder(p)
		return HasTool(p, "Knife")
	end

	local function IsSheriff(p)
		for _, gName in ipairs(GUN_NAMES) do
			if HasTool(p, gName) then
				return true
			end
		end
		return false
	end

	local function GetPlayerColor(p)
		if IsMurder(p) then return Config.ColorMurder end
		if IsSheriff(p) then return Config.ColorSheriff end
		return Config.ColorInnocent
	end

	local function getMurderer()
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and IsMurder(p) then
				return p
			end
		end
		return nil
	end

	-- Chams de Jugadores
	local HighlightCache = {}

	local function ClearAllHighlights()
		for p, h in pairs(HighlightCache) do
			pcall(function() h:Destroy() end)
			HighlightCache[p] = nil
		end
	end

	-- Cham Gun (Pistola en suelo o sin dueño)
	local GunHighlightCache = {}
	local GunTagCache = {}

	local function ClearGunVisuals()
		for obj, h in pairs(GunHighlightCache) do
			pcall(function() h:Destroy() end)
			GunHighlightCache[obj] = nil
		end
		for obj, gui in pairs(GunTagCache) do
			pcall(function() gui:Destroy() end)
			GunTagCache[obj] = nil
		end
		HideGunTracer()
	end

	local function GetTargetAdornee(obj)
		if obj:IsA("Model") then
			return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true), obj
		elseif obj:IsA("Tool") then
			local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart", true)
			return handle, obj
		elseif obj:IsA("BasePart") then
			return obj, obj
		end
		return nil, nil
	end

	local function IsDroppedOrUnownedGun(obj)
		if not obj or not obj.Parent then return false end
		if not IsGunName(obj.Name) then return false end

		-- Ignorar si pertenece a un jugador (en Backpack o Character)
		local ancestor = obj.Parent
		while ancestor and ancestor ~= Workspace do
			if Players:GetPlayerFromCharacter(ancestor) then
				return false
			end
			if ancestor:IsA("Backpack") then
				return false
			end
			ancestor = ancestor.Parent
		end

		return obj:IsA("Tool") or obj:IsA("Model") or obj:IsA("BasePart")
	end

	local function ApplyGunCham(obj)
		local part, adornee = GetTargetAdornee(obj)
		if not part or not adornee then return end

		if not GunHighlightCache[obj] or not GunHighlightCache[obj].Parent then
			local h = Instance.new("Highlight")
			h.Name = "XoloGunCham"
			h.Adornee = adornee
			h.FillColor = Config.ColorGun
			h.FillTransparency = 0.35
			h.OutlineColor = XOLO.White
			h.OutlineTransparency = 0
			h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			h.Parent = CoreGui
			GunHighlightCache[obj] = h
		else
			local h = GunHighlightCache[obj]
			h.Adornee = adornee
			h.FillColor = Config.ColorGun
		end

		if not GunTagCache[obj] or not GunTagCache[obj].Parent then
			local bb = Instance.new("BillboardGui")
			bb.Name = "XoloGunTag"
			bb.Adornee = part
			bb.Size = UDim2.new(0, 110, 0, 24)
			bb.StudsOffset = Vector3.new(0, 1.8, 0)
			bb.AlwaysOnTop = true
			bb.Parent = CoreGui

			local lbl = Instance.new("TextLabel", bb)
			lbl.Size = UDim2.new(1, 0, 1, 0)
			lbl.BackgroundColor3 = XOLO.BG
			lbl.BackgroundTransparency = 0.25
			lbl.Text = "🔫 GUN"
			lbl.TextColor3 = Config.ColorGun
			lbl.Font = Enum.Font.BuilderSansBold
			lbl.TextSize = 12
			Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 6)

			local stroke = Instance.new("UIStroke", lbl)
			stroke.Color = Config.ColorGun
			stroke.Thickness = 1

			GunTagCache[obj] = bb
		else
			local lbl = GunTagCache[obj]:FindFirstChildWhichIsA("TextLabel")
			if lbl then
				lbl.TextColor3 = Config.ColorGun
			end
		end

		if HasDrawing and Config.GunTracerEnabled and GunTracerLine then
			local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
			if onScreen then
				GunTracerLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
				GunTracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
				GunTracerLine.Color = Config.ColorGun
				GunTracerLine.Visible = true
			else
				GunTracerLine.Visible = false
			end
		elseif GunTracerLine then
			GunTracerLine.Visible = false
		end
	end

	local function UpdateGunCham()
		if not Config.ChamGunEnabled then
			ClearGunVisuals()
			return
		end

		local activeGuns = {}
		for _, desc in ipairs(Workspace:GetDescendants()) do
			if IsDroppedOrUnownedGun(desc) then
				table.insert(activeGuns, desc)
			end
		end

		-- Limpiar visuales de armas que ya no existen o fueron recogidas
		for obj, h in pairs(GunHighlightCache) do
			if not IsDroppedOrUnownedGun(obj) then
				pcall(function() h:Destroy() end)
				GunHighlightCache[obj] = nil
			end
		end
		for obj, gui in pairs(GunTagCache) do
			if not IsDroppedOrUnownedGun(obj) then
				pcall(function() gui:Destroy() end)
				GunTagCache[obj] = nil
			end
		end

		if #activeGuns == 0 then
			HideGunTracer()
			return
		end

		for i, gunObj in ipairs(activeGuns) do
			ApplyGunCham(gunObj)
			-- Solo dibujar tracer hacia la primera arma encontrada para evitar saturar la pantalla
			if i > 1 and GunTracerLine then
				GunTracerLine.Visible = false
			end
		end
	end

	-- Bounding Box 2D limpio para ESP Cajas
	local function GetCharacterScreenBox(char)
		local cf, size = char:GetBoundingBox()
		local half = size * 0.5

		local offsets = {
			Vector3.new(-half.X, -half.Y, -half.Z),
			Vector3.new(-half.X, -half.Y,  half.Z),
			Vector3.new(-half.X,  half.Y, -half.Z),
			Vector3.new(-half.X,  half.Y,  half.Z),
			Vector3.new( half.X, -half.Y, -half.Z),
			Vector3.new( half.X, -half.Y,  half.Z),
			Vector3.new( half.X,  half.Y, -half.Z),
			Vector3.new( half.X,  half.Y,  half.Z)
		}

		local minX, minY = math.huge, math.huge
		local maxX, maxY = -math.huge, -math.huge
		local anyOnScreen = false

		for _, offset in ipairs(offsets) do
			local worldPt = cf:PointToWorldSpace(offset)
			local screenPt, onScreen = Camera:WorldToViewportPoint(worldPt)
			if screenPt.Z > 0 then
				if onScreen then
					anyOnScreen = true
				end
				if screenPt.X < minX then minX = screenPt.X end
				if screenPt.X > maxX then maxX = screenPt.X end
				if screenPt.Y < minY then minY = screenPt.Y end
				if screenPt.Y > maxY then maxY = screenPt.Y end
			end
		end

		if not anyOnScreen or minX == math.huge or maxX == -math.huge then
			return nil
		end

		local vp = Camera.ViewportSize
		minX = math.clamp(minX, 0, vp.X)
		maxX = math.clamp(maxX, 0, vp.X)
		minY = math.clamp(minY, 0, vp.Y)
		maxY = math.clamp(maxY, 0, vp.Y)

		if (maxX - minX) < 4 or (maxY - minY) < 6 then
			return nil
		end

		return Vector2.new(minX, minY), Vector2.new(maxX, maxY)
	end

	local function DrawFor(player)
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local head = (char and char:FindFirstChild("Head")) or hrp

		if not hrp or not hum or hum.Health <= 0 then
			if HighlightCache[player] then
				pcall(function() HighlightCache[player]:Destroy() end)
				HighlightCache[player] = nil
			end
			return
		end

		local color = GetPlayerColor(player)

		-- ESP Cajas 2D
		if Config.ESPEnabled then
			local topLeft, bottomRight = GetCharacterScreenBox(char)
			if topLeft and bottomRight then
				local topRight = Vector2.new(bottomRight.X, topLeft.Y)
				local bottomLeft = Vector2.new(topLeft.X, bottomRight.Y)

				local l1 = GetBoxLine()
				l1.From, l1.To, l1.Color, l1.Visible = topLeft, topRight, color, true

				local l2 = GetBoxLine()
				l2.From, l2.To, l2.Color, l2.Visible = topRight, bottomRight, color, true

				local l3 = GetBoxLine()
				l3.From, l3.To, l3.Color, l3.Visible = bottomRight, bottomLeft, color, true

				local l4 = GetBoxLine()
				l4.From, l4.To, l4.Color, l4.Visible = bottomLeft, topLeft, color, true
			end
		end

		-- ESP Tracers
		if Config.TracersEnabled and head then
			local screenHead, onScreen = Camera:WorldToViewportPoint(head.Position)
			if onScreen then
				local origin = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y)
				local tracer = GetTracerLine()
				tracer.From = origin
				tracer.To = Vector2.new(screenHead.X, screenHead.Y)
				tracer.Color = color
				tracer.Visible = true
			end
		end

		-- ESP Chams
		if Config.ESPHighlight then
			if not HighlightCache[player] or not HighlightCache[player].Parent then
				local h = Instance.new("Highlight")
				h.Name = "XoloPlayerCham"
				h.FillColor = color
				h.FillTransparency = 0.6
				h.OutlineColor = color
				h.OutlineTransparency = 0
				h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				h.Parent = char
				HighlightCache[player] = h
			else
				HighlightCache[player].FillColor = color
				HighlightCache[player].OutlineColor = color
			end
		elseif HighlightCache[player] then
			pcall(function() HighlightCache[player]:Destroy() end)
			HighlightCache[player] = nil
		end
	end

	local function UpdateESP()
		ClearBoxLines()
		ClearTracerLines()

		if not Config.ESPEnabled and not Config.ESPHighlight and not Config.TracersEnabled then
			ClearAllHighlights()
			return
		end

		if HasDrawing then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer then
					pcall(DrawFor, p)
				end
			end
		elseif Config.ESPHighlight then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer then
					pcall(DrawFor, p)
				end
			end
		end
	end

	Players.PlayerRemoving:Connect(function(plr)
		if HighlightCache[plr] then
			pcall(function() HighlightCache[plr]:Destroy() end)
			HighlightCache[plr] = nil
		end
	end)

	-- Aimbot
	local function GetCrosshair()
		if IsMobile then
			return Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
		end
		local m = UIS:GetMouseLocation()
		return Vector2.new(m.X, m.Y)
	end

	local function UpdateAimbot()
		local target = getMurderer()
		local hasTarget = false

		if Config.AimbotEnabled and target and target.Character and IsSheriff(LocalPlayer) then
			local hrp = getHRP()
			local tHead = target.Character:FindFirstChild("Head")
			if hrp and tHead then
				local worldDist = (hrp.Position - tHead.Position).Magnitude
				if worldDist <= Config.LockDistance then
					local screenPos, onScreen = Camera:WorldToViewportPoint(tHead.Position)
					if onScreen then
						local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - GetCrosshair()).Magnitude
						if screenDist <= Config.ScreenFOV then
							hasTarget = true
							Camera.CFrame = Camera.CFrame:Lerp(
								CFrame.new(Camera.CFrame.Position, tHead.Position),
								Config.AimbotSmooth
							)
						end
					end
				end
			end
		end

		if FOVCircle then
			if Config.ShowFOVCircle and Config.AimbotEnabled then
				FOVCircle.Position = GetCrosshair()
				FOVCircle.Radius = Config.ScreenFOV
				FOVCircle.Color = hasTarget and XOLO.White or XOLO.Accent
				FOVCircle.Visible = true
			else
				FOVCircle.Visible = false
			end
		end
	end

	-- UI Principal
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "XoloMenu"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.IgnoreGuiInset = true
	pcall(function() ScreenGui.Parent = CoreGui end)
	if not ScreenGui.Parent then
		ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end

	local function ShowToast(text)
		local toast = Instance.new("Frame", ScreenGui)
		toast.Size = UDim2.new(0, 250, 0, 40)
		toast.Position = UDim2.new(0.5, -125, -0.1, 0)
		toast.BackgroundColor3 = XOLO.Panel
		toast.ZIndex = 200
		Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 8)

		local stroke = Instance.new("UIStroke", toast)
		stroke.Color = XOLO.Accent
		stroke.Thickness = 1.5

		local lbl = Instance.new("TextLabel", toast)
		lbl.Size = UDim2.new(1, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = XOLO.White
		lbl.Font = Enum.Font.BuilderSansBold
		lbl.TextSize = 12
		lbl.ZIndex = 201

		TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Position = UDim2.new(0.5, -125, 0.1, 0) }):Play()
		task.delay(2.5, function()
			local tOut = TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Position = UDim2.new(0.5, -125, -0.1, 0) })
			tOut:Play()
			tOut.Completed:Wait()
			toast:Destroy()
		end)
	end

	local ShadowFrame = Instance.new("Frame", ScreenGui)
	ShadowFrame.Size = UDim2.new(0, 320, 0, 480)
	ShadowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	ShadowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	ShadowFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	ShadowFrame.BackgroundTransparency = 0.3
	ShadowFrame.Visible = false
	ShadowFrame.ZIndex = 49
	Instance.new("UICorner", ShadowFrame).CornerRadius = UDim.new(0, 16)

	local ToggleBtn = Instance.new("TextButton")
	ToggleBtn.Size = UDim2.new(0, 130, 0, 40)
	ToggleBtn.Position = UDim2.new(0, 15, 0, 60)
	ToggleBtn.BackgroundColor3 = XOLO.Panel
	ToggleBtn.Text = "🚀 XOLO HUB"
	ToggleBtn.TextColor3 = XOLO.Accent
	ToggleBtn.Font = Enum.Font.BuilderSansBold
	ToggleBtn.TextSize = 14
	ToggleBtn.ZIndex = 100
	ToggleBtn.AutoButtonColor = false
	ToggleBtn.Parent = ScreenGui
	Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

	local tStroke = Instance.new("UIStroke", ToggleBtn)
	tStroke.Color = XOLO.Accent
	tStroke.Thickness = 2

	local MainFrame = Instance.new("Frame")
	MainFrame.Size = UDim2.new(0, 320, 0, 480)
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainFrame.BackgroundColor3 = XOLO.BG
	MainFrame.Visible = false
	MainFrame.ClipsDescendants = true
	MainFrame.ZIndex = 50
	MainFrame.Parent = ScreenGui
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

	local bgGradient = Instance.new("UIGradient", MainFrame)
	bgGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, XOLO.BG2),
		ColorSequenceKeypoint.new(1, XOLO.BG)
	})
	bgGradient.Rotation = 90

	local menuScale = Instance.new("UIScale", MainFrame)
	local function UpdateScale()
		local vp = Camera.ViewportSize
		menuScale.Scale = math.clamp(math.min(vp.X, vp.Y) / 520, 0.6, 1)
	end
	UpdateScale()
	Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)

	local mainStroke = Instance.new("UIStroke", MainFrame)
	mainStroke.Color = XOLO.Accent
	mainStroke.Thickness = 1.5
	mainStroke.Transparency = 0.2

	local Header = Instance.new("Frame", MainFrame)
	Header.Size = UDim2.new(1, 0, 0, 50)
	Header.BackgroundTransparency = 1
	Header.ZIndex = 52

	local LogoImage = Instance.new("ImageLabel", Header)
	LogoImage.Size = UDim2.new(0, 30, 0, 30)
	LogoImage.Position = UDim2.new(0, 15, 0, 10)
	LogoImage.BackgroundTransparency = 1
	LogoImage.Image = Config.LogoId
	LogoImage.ScaleType = Enum.ScaleType.Fit
	LogoImage.ZIndex = 52

	local Title = Instance.new("TextLabel", Header)
	Title.Size = UDim2.new(1, -120, 0, 26)
	Title.Position = UDim2.new(0, 50, 0, 12)
	Title.BackgroundTransparency = 1
	Title.Text = "XOLO HUB v2.0"
	Title.TextColor3 = XOLO.White
	Title.Font = Enum.Font.BuilderSansBold
	Title.TextSize = 20
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.ZIndex = 52

	local MinBtn = Instance.new("TextButton", Header)
	MinBtn.Size = UDim2.new(0, 26, 0, 26)
	MinBtn.Position = UDim2.new(1, -66, 0, 12)
	MinBtn.BackgroundColor3 = XOLO.Panel
	MinBtn.Text = "—"
	MinBtn.TextColor3 = XOLO.Accent
	MinBtn.Font = Enum.Font.GothamBold
	MinBtn.TextSize = 16
	MinBtn.ZIndex = 52
	MinBtn.AutoButtonColor = false
	Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

	local CloseBtn = Instance.new("TextButton", Header)
	CloseBtn.Size = UDim2.new(0, 26, 0, 26)
	CloseBtn.Position = UDim2.new(1, -36, 0, 12)
	CloseBtn.BackgroundColor3 = XOLO.Panel
	CloseBtn.Text = "✕"
	CloseBtn.TextColor3 = XOLO.Red
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextSize = 14
	CloseBtn.ZIndex = 52
	CloseBtn.AutoButtonColor = false
	Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

	local Sidebar = Instance.new("Frame", MainFrame)
	Sidebar.Size = UDim2.new(0, 80, 1, -60)
	Sidebar.Position = UDim2.new(0, 0, 0, 50)
	Sidebar.BackgroundColor3 = XOLO.Panel
	Sidebar.BackgroundTransparency = 0.5
	Sidebar.ZIndex = 51

	local SidebarLayout = Instance.new("UIListLayout", Sidebar)
	SidebarLayout.FillDirection = Enum.FillDirection.Vertical
	SidebarLayout.Padding = UDim.new(0, 8)
	SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	SidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top

	local SidebarPad = Instance.new("UIPadding", Sidebar)
	SidebarPad.PaddingTop = UDim.new(0, 10)

	local ContentArea = Instance.new("ScrollingFrame", MainFrame)
	ContentArea.Size = UDim2.new(1, -90, 1, -70)
	ContentArea.Position = UDim2.new(0, 85, 0, 55)
	ContentArea.BackgroundTransparency = 1
	ContentArea.ScrollBarThickness = 2
	ContentArea.ScrollBarImageColor3 = XOLO.Accent
	ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
	ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ContentArea.ZIndex = 51

	local ContentPad = Instance.new("UIPadding", ContentArea)
	ContentPad.PaddingRight = UDim.new(0, 6)

	local Sections = {}
	local function CreateSection(name)
		local f = Instance.new("Frame", ContentArea)
		f.Size = UDim2.new(1, 0, 0, 0)
		f.BackgroundTransparency = 1
		f.Visible = false
		f.ZIndex = 52
		f.AutomaticSize = Enum.AutomaticSize.Y
		Sections[name] = f
		return f
	end

	local ESPPage = CreateSection("ESP")
	local AimbotPage = CreateSection("Aimbot")
	local MusicPage = CreateSection("Music")
	local SettingsPage = CreateSection("Settings")

	local TabButtons = {}
	local currentTab = nil

	local function SwitchTab(name)
		for n, p in pairs(Sections) do
			p.Visible = (n == name)
		end
		for n, b in pairs(TabButtons) do
			local active = (n == name)
			TweenService:Create(b, TweenInfo.new(0.2), {
				BackgroundColor3 = active and XOLO.Accent or XOLO.Panel2,
				TextColor3 = active and XOLO.BG or XOLO.Muted
			}):Play()
		end
		currentTab = name
	end

	local function CreateTabButton(name, iconText)
		local btn = Instance.new("TextButton", Sidebar)
		btn.Size = UDim2.new(0, 60, 0, 50)
		btn.BackgroundColor3 = XOLO.Panel2
		btn.Text = iconText .. "\n" .. name
		btn.TextColor3 = XOLO.Muted
		btn.Font = Enum.Font.BuilderSansBold
		btn.TextSize = 11
		btn.AutoButtonColor = false
		btn.ZIndex = 52
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
		btn.Activated:Connect(function()
			PlaySound("click")
			SwitchTab(name)
		end)
		TabButtons[name] = btn
	end

	CreateTabButton("ESP", "👁️")
	CreateTabButton("Aimbot", "🎯")
	CreateTabButton("Music", "🎵")
	CreateTabButton("Settings", "⚙️")

	local function CreateLabel(parent, text, yPos, color)
		local lbl = Instance.new("TextLabel", parent)
		lbl.Size = UDim2.new(1, 0, 0, 20)
		lbl.Position = UDim2.new(0, 4, 0, yPos)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = color or XOLO.Muted
		lbl.Font = Enum.Font.BuilderSansBold
		lbl.TextSize = 11
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.ZIndex = 100
		return lbl
	end

	local function CreateToggle(parent, text, yPos, callback, default)
		local state = (default == true)
		local btn = Instance.new("TextButton", parent)
		btn.Size = UDim2.new(1, 0, 0, 40)
		btn.Position = UDim2.new(0, 0, 0, yPos)
		btn.BackgroundColor3 = XOLO.Panel
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.ZIndex = 100
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

		local stroke = Instance.new("UIStroke", btn)
		stroke.Color = XOLO.Panel2
		stroke.Thickness = 1

		local label = Instance.new("TextLabel", btn)
		label.Size = UDim2.new(1, -50, 1, 0)
		label.Position = UDim2.new(0, 12, 0, 0)
		label.Text = text
		label.TextColor3 = XOLO.Text
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.BuilderSansBold
		label.TextSize = 12
		label.ZIndex = 101

		local switchBg = Instance.new("Frame", btn)
		switchBg.Size = UDim2.new(0, 34, 0, 18)
		switchBg.Position = UDim2.new(1, -42, 0.5, -9)
		switchBg.BackgroundColor3 = state and XOLO.Accent or XOLO.Panel2
		switchBg.ZIndex = 101
		Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

		local thumb = Instance.new("Frame", switchBg)
		thumb.Size = UDim2.new(0, 14, 0, 14)
		thumb.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
		thumb.BackgroundColor3 = XOLO.White
		thumb.ZIndex = 102
		Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

		btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				TweenService:Create(btn, TweenInfo.new(0.1), { Size = UDim2.new(0.95, 0, 0, 40) }):Play()
			end
		end)
		btn.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				TweenService:Create(btn, TweenInfo.new(0.1), { Size = UDim2.new(1, 0, 0, 40) }):Play()
			end
		end)

		btn.Activated:Connect(function()
			state = not state
			PlaySound("click")
			TweenService:Create(switchBg, TweenInfo.new(0.2), { BackgroundColor3 = state and XOLO.Accent or XOLO.Panel2 }):Play()
			TweenService:Create(thumb, TweenInfo.new(0.2), { Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) }):Play()

			if not state then
				if text:find("Cajas") then ClearBoxLines() end
				if text:find("Tracers") and not text:find("Gun") then ClearTracerLines() end
				if text:find("Chams") and not text:find("Gun") then ClearAllHighlights() end
				if text:find("Cham Gun") then ClearGunVisuals() end
				if text:find("Tracer Gun") then HideGunTracer() end
				if text:find("FOV") and FOVCircle then FOVCircle.Visible = false end
			end

			if callback then
				callback(state)
			end
		end)

		return btn
	end

	local function CreateSlider(parent, text, yPos, minVal, maxVal, defaultVal, callback, decimals)
		decimals = decimals or 2
		local frame = Instance.new("Frame", parent)
		frame.Size = UDim2.new(1, 0, 0, 46)
		frame.Position = UDim2.new(0, 0, 0, yPos)
		frame.BackgroundColor3 = XOLO.Panel
		frame.ZIndex = 100
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

		local stroke = Instance.new("UIStroke", frame)
		stroke.Color = XOLO.Panel2
		stroke.Thickness = 1

		local label = Instance.new("TextLabel", frame)
		label.Size = UDim2.new(1, -20, 0, 18)
		label.Position = UDim2.new(0, 12, 0, 6)
		label.BackgroundTransparency = 1
		label.Text = string.format("%s: %." .. decimals .. "f", text, defaultVal)
		label.TextColor3 = XOLO.Text
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Font = Enum.Font.BuilderSansBold
		label.TextSize = 11
		label.ZIndex = 101

		local bar = Instance.new("Frame", frame)
		bar.Size = UDim2.new(1, -24, 0, 5)
		bar.Position = UDim2.new(0, 12, 0, 28)
		bar.BackgroundColor3 = XOLO.Panel2
		bar.ZIndex = 101
		bar.Active = true
		Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

		local percent = (defaultVal - minVal) / (maxVal - minVal)
		local fill = Instance.new("Frame", bar)
		fill.Size = UDim2.new(percent, 0, 1, 0)
		fill.BackgroundColor3 = XOLO.Accent
		fill.ZIndex = 102
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

		local knob = Instance.new("Frame", bar)
		knob.Size = UDim2.new(0, 14, 0, 14)
		knob.Position = UDim2.new(percent, -7, 0.5, -7)
		knob.BackgroundColor3 = XOLO.White
		knob.ZIndex = 103
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

		local dragging = false
		local function setVal(x)
			local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			local val = minVal + ((maxVal - minVal) * rel)
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, -7, 0.5, -7)
			label.Text = string.format("%s: %." .. decimals .. "f", text, val)
			if callback then callback(val) end
		end

		bar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				setVal(input.Position.X)
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				setVal(input.Position.X)
			end
		end)
		UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
	end

	local function CreateButton(parent, text, yPos, callback, color)
		local btn = Instance.new("TextButton", parent)
		btn.Size = UDim2.new(1, 0, 0, 40)
		btn.Position = UDim2.new(0, 0, 0, yPos)
		btn.BackgroundColor3 = color or XOLO.Panel
		btn.Text = text
		btn.TextColor3 = XOLO.White
		btn.Font = Enum.Font.BuilderSansBold
		btn.TextSize = 12
		btn.AutoButtonColor = false
		btn.ZIndex = 100
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

		local stroke = Instance.new("UIStroke", btn)
		stroke.Color = XOLO.Panel2
		stroke.Thickness = 1

		btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				TweenService:Create(btn, TweenInfo.new(0.1), { Size = UDim2.new(0.95, 0, 0, 40) }):Play()
			end
		end)
		btn.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				TweenService:Create(btn, TweenInfo.new(0.1), { Size = UDim2.new(1, 0, 0, 40) }):Play()
			end
		end)
		btn.Activated:Connect(function()
			PlaySound("click")
			if callback then callback() end
		end)
		return btn
	end

	-- Página ESP
	local espY = 0
	CreateLabel(ESPPage, "─── VISUAL ───", espY, XOLO.Accent)
	espY += 24
	CreateToggle(ESPPage, "ESP Cajas", espY, function(s) Config.ESPEnabled = s end, Config.ESPEnabled)
	espY += 48
	CreateToggle(ESPPage, "ESP Chams", espY, function(s) Config.ESPHighlight = s end, Config.ESPHighlight)
	espY += 48
	CreateToggle(ESPPage, "ESP Tracers", espY, function(s) Config.TracersEnabled = s end, Config.TracersEnabled)
	espY += 48
	CreateToggle(ESPPage, "Cham Gun (Suelo)", espY, function(s) Config.ChamGunEnabled = s end, Config.ChamGunEnabled)
	espY += 48
	CreateToggle(ESPPage, "Tracer Gun", espY, function(s) Config.GunTracerEnabled = s end, Config.GunTracerEnabled)
	espY += 48

	local PreviewUI = Instance.new("Frame", ESPPage)
	PreviewUI.Size = UDim2.new(1, 0, 0, 60)
	PreviewUI.Position = UDim2.new(0, 0, 0, espY)
	PreviewUI.BackgroundColor3 = XOLO.Panel
	PreviewUI.ZIndex = 100
	Instance.new("UICorner", PreviewUI).CornerRadius = UDim.new(0, 10)

	local previewStroke = Instance.new("UIStroke", PreviewUI)
	previewStroke.Color = XOLO.Panel2
	previewStroke.Thickness = 1

	local prevTitle = Instance.new("TextLabel", PreviewUI)
	prevTitle.Size = UDim2.new(1, 0, 0, 20)
	prevTitle.Position = UDim2.new(0, 0, 0, 5)
	prevTitle.BackgroundTransparency = 1
	prevTitle.Text = "Vista Previa ESP"
	prevTitle.TextColor3 = XOLO.Muted
	prevTitle.Font = Enum.Font.BuilderSansBold
	prevTitle.TextSize = 10
	prevTitle.ZIndex = 101

	local prevSkeleton = Instance.new("Frame", PreviewUI)
	prevSkeleton.Size = UDim2.new(0, 60, 0, 30)
	prevSkeleton.Position = UDim2.new(0.5, -30, 0, 25)
	prevSkeleton.BackgroundTransparency = 1
	prevSkeleton.ZIndex = 101

	local prevHead = Instance.new("Frame", prevSkeleton)
	prevHead.Size = UDim2.new(0, 8, 0, 8)
	prevHead.Position = UDim2.new(0.5, -4, 0, 0)
	prevHead.BackgroundTransparency = 1
	prevHead.ZIndex = 102
	local headStroke = Instance.new("UIStroke", prevHead)
	headStroke.Color = Config.ColorInnocent
	headStroke.Thickness = 1.5

	local prevBody = Instance.new("Frame", prevSkeleton)
	prevBody.Size = UDim2.new(0, 12, 0, 16)
	prevBody.Position = UDim2.new(0.5, -6, 0, 8)
	prevBody.BackgroundTransparency = 1
	prevBody.ZIndex = 102
	local bodyStroke = Instance.new("UIStroke", prevBody)
	bodyStroke.Color = Config.ColorInnocent
	bodyStroke.Thickness = 1.5

	local prevTracer = Instance.new("Frame", prevSkeleton)
	prevTracer.Size = UDim2.new(0, 30, 0, 1)
	prevTracer.Position = UDim2.new(0, -10, 0, 24)
	prevTracer.BackgroundColor3 = Config.ColorInnocent
	prevTracer.Rotation = 30
	prevTracer.ZIndex = 101

	espY += 68
	CreateLabel(ESPPage, "─── COLORES ───", espY, XOLO.Accent)
	espY += 24

	local function CreateColorBtn(parent, text, yPos, colorKey)
		local btn = Instance.new("TextButton", parent)
		btn.Size = UDim2.new(1, 0, 0, 36)
		btn.Position = UDim2.new(0, 0, 0, yPos)
		btn.BackgroundColor3 = XOLO.Panel
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.ZIndex = 100
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

		local label = Instance.new("TextLabel", btn)
		label.Size = UDim2.new(1, -60, 1, 0)
		label.Position = UDim2.new(0, 12, 0, 0)
		label.Text = text
		label.TextColor3 = XOLO.Text
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.BuilderSansBold
		label.TextSize = 12
		label.ZIndex = 101

		local colorBox = Instance.new("Frame", btn)
		colorBox.Size = UDim2.new(0, 20, 0, 20)
		colorBox.Position = UDim2.new(1, -32, 0.5, -10)
		colorBox.BackgroundColor3 = Config[colorKey]
		colorBox.ZIndex = 101
		Instance.new("UICorner", colorBox).CornerRadius = UDim.new(0, 4)

		btn.Activated:Connect(function()
			PlaySound("click")
			local currentColor = Config[colorKey]
			local nextIndex = 1
			for i, c in ipairs(ColorPalette) do
				if c.Color == currentColor then
					nextIndex = i + 1
					break
				end
			end
			if nextIndex > #ColorPalette then
				nextIndex = 1
			end
			Config[colorKey] = ColorPalette[nextIndex].Color
			TweenService:Create(colorBox, TweenInfo.new(0.2), { BackgroundColor3 = Config[colorKey] }):Play()
			headStroke.Color = Config[colorKey]
			bodyStroke.Color = Config[colorKey]
			prevTracer.BackgroundColor3 = Config[colorKey]
		end)
	end

	CreateColorBtn(ESPPage, "Color Murder", espY, "ColorMurder")
	espY += 42
	CreateColorBtn(ESPPage, "Color Sheriff", espY, "ColorSheriff")
	espY += 42
	CreateColorBtn(ESPPage, "Color Innocent", espY, "ColorInnocent")
	espY += 42
	CreateColorBtn(ESPPage, "Color Gun", espY, "ColorGun")
	espY += 48

	-- Página Aimbot
	local aimY = 0
	CreateLabel(AimbotPage, "─── COMBATE ───", aimY, XOLO.Accent)
	aimY += 24
	CreateToggle(AimbotPage, "Aimbot Lock", aimY, function(s) Config.AimbotEnabled = s end, Config.AimbotEnabled)
	aimY += 48
	CreateToggle(AimbotPage, "Mostrar FOV", aimY, function(s) Config.ShowFOVCircle = s end, Config.ShowFOVCircle)
	aimY += 48
	CreateSlider(AimbotPage, "Suavidad", aimY, 0.05, 0.5, Config.AimbotSmooth, function(v) Config.AimbotSmooth = v end)
	aimY += 52
	CreateSlider(AimbotPage, "Tamaño FOV", aimY, 50, 600, Config.ScreenFOV, function(v) Config.ScreenFOV = v end, 0)
	aimY += 52
	CreateSlider(AimbotPage, "Distancia Max", aimY, 10, 500, Config.LockDistance, function(v) Config.LockDistance = v end, 0)
	aimY += 52
	CreateLabel(AimbotPage, "* Solo funciona si eres Sheriff.", aimY, XOLO.Muted)

	-- Página Settings
	local cfgY = 0
	CreateLabel(SettingsPage, "─── COMUNIDAD ───", cfgY, XOLO.Accent)
	cfgY += 24
	CreateButton(SettingsPage, "💬 Unirse al Discord", cfgY, function()
		if setclipboard then
			setclipboard("https://discord.gg/2VC9mSq43")
			ShowToast("¡Link de Discord copiado!")
		end
	end, XOLO.Panel2)
	cfgY += 48
	CreateButton(SettingsPage, "📺 Suscríbete en YouTube", cfgY, function()
		if setclipboard then
			setclipboard("https://youtube.com/@xolok4?si=RZEvkPlIJ89J7IqJ")
			ShowToast("¡Link de YouTube copiado!")
		end
	end, XOLO.Panel2)
	cfgY += 48
	CreateLabel(SettingsPage, "─── INFO ───", cfgY, XOLO.Accent)
	cfgY += 24
	CreateLabel(SettingsPage, "XOLO HUB v2.0\nDesarrollado por @xolok4\nGracias por usar el script.", cfgY, XOLO.Text)

	-- Reproductor de Música
	local PlayerGui = Instance.new("Frame", ScreenGui)
	PlayerGui.Name = "MusicPlayer"
	PlayerGui.Size = UDim2.new(0, 230, 0, 95)
	PlayerGui.Position = UDim2.new(0.5, -115, 0.8, -47)
	PlayerGui.BackgroundColor3 = XOLO.BG
	PlayerGui.BackgroundTransparency = 0.05
	PlayerGui.Visible = false
	PlayerGui.ZIndex = 150
	PlayerGui.Active = true
	Instance.new("UICorner", PlayerGui).CornerRadius = UDim.new(0, 12)

	local playerStroke = Instance.new("UIStroke", PlayerGui)
	playerStroke.Color = XOLO.Accent
	playerStroke.Thickness = 1.5

	local SongNameLbl = Instance.new("TextLabel", PlayerGui)
	SongNameLbl.Size = UDim2.new(1, -70, 0, 20)
	SongNameLbl.Position = UDim2.new(0, 12, 0, 8)
	SongNameLbl.BackgroundTransparency = 1
	SongNameLbl.Text = "Selecciona una canción"
	SongNameLbl.TextColor3 = XOLO.White
	SongNameLbl.Font = Enum.Font.BuilderSansBold
	SongNameLbl.TextSize = 12
	SongNameLbl.TextXAlignment = Enum.TextXAlignment.Left
	SongNameLbl.TextTruncate = Enum.TextTruncate.AtEnd
	SongNameLbl.ZIndex = 151

	local MinMusicBtn = Instance.new("TextButton", PlayerGui)
	MinMusicBtn.Size = UDim2.new(0, 20, 0, 20)
	MinMusicBtn.Position = UDim2.new(1, -50, 0, 8)
	MinMusicBtn.BackgroundColor3 = XOLO.Panel
	MinMusicBtn.Text = "—"
	MinMusicBtn.TextColor3 = XOLO.Accent
	MinMusicBtn.Font = Enum.Font.GothamBold
	MinMusicBtn.TextSize = 14
	MinMusicBtn.ZIndex = 151
	MinMusicBtn.AutoButtonColor = false
	Instance.new("UICorner", MinMusicBtn).CornerRadius = UDim.new(0, 4)

	local ClosePlayerBtn = Instance.new("TextButton", PlayerGui)
	ClosePlayerBtn.Size = UDim2.new(0, 20, 0, 20)
	ClosePlayerBtn.Position = UDim2.new(1, -26, 0, 8)
	ClosePlayerBtn.BackgroundColor3 = XOLO.Panel
	ClosePlayerBtn.Text = "✕"
	ClosePlayerBtn.TextColor3 = XOLO.Red
	ClosePlayerBtn.Font = Enum.Font.GothamBold
	ClosePlayerBtn.TextSize = 10
	ClosePlayerBtn.ZIndex = 151
	ClosePlayerBtn.AutoButtonColor = false
	Instance.new("UICorner", ClosePlayerBtn).CornerRadius = UDim.new(0, 4)

	local PlayBtnPlayer = Instance.new("TextButton", PlayerGui)
	PlayBtnPlayer.Size = UDim2.new(0, 28, 0, 26)
	PlayBtnPlayer.Position = UDim2.new(0, 12, 0, 58)
	PlayBtnPlayer.BackgroundColor3 = XOLO.Accent
	PlayBtnPlayer.Text = "⏸"
	PlayBtnPlayer.TextColor3 = XOLO.BG
	PlayBtnPlayer.Font = Enum.Font.GothamBold
	PlayBtnPlayer.TextSize = 14
	PlayBtnPlayer.ZIndex = 151
	PlayBtnPlayer.AutoButtonColor = false
	Instance.new("UICorner", PlayBtnPlayer).CornerRadius = UDim.new(0, 6)

	local PrevBtn = Instance.new("TextButton", PlayerGui)
	PrevBtn.Size = UDim2.new(0, 28, 0, 26)
	PrevBtn.Position = UDim2.new(0, 44, 0, 58)
	PrevBtn.BackgroundColor3 = XOLO.Panel2
	PrevBtn.Text = "⏮"
	PrevBtn.TextColor3 = XOLO.White
	PrevBtn.Font = Enum.Font.GothamBold
	PrevBtn.TextSize = 14
	PrevBtn.ZIndex = 151
	PrevBtn.AutoButtonColor = false
	Instance.new("UICorner", PrevBtn).CornerRadius = UDim.new(0, 6)

	local NextBtn = Instance.new("TextButton", PlayerGui)
	NextBtn.Size = UDim2.new(0, 28, 0, 26)
	NextBtn.Position = UDim2.new(0, 76, 0, 58)
	NextBtn.BackgroundColor3 = XOLO.Panel2
	NextBtn.Text = "⏭"
	NextBtn.TextColor3 = XOLO.White
	NextBtn.Font = Enum.Font.GothamBold
	NextBtn.TextSize = 14
	NextBtn.ZIndex = 151
	NextBtn.AutoButtonColor = false
	Instance.new("UICorner", NextBtn).CornerRadius = UDim.new(0, 6)

	local ProgressBg = Instance.new("TextButton", PlayerGui)
	ProgressBg.Size = UDim2.new(1, -116, 0, 6)
	ProgressBg.Position = UDim2.new(0, 114, 0, 68)
	ProgressBg.BackgroundColor3 = XOLO.Panel2
	ProgressBg.Text = ""
	ProgressBg.AutoButtonColor = false
	ProgressBg.ZIndex = 151
	Instance.new("UICorner", ProgressBg).CornerRadius = UDim.new(1, 0)

	local ProgressFill = Instance.new("Frame", ProgressBg)
	ProgressFill.Size = UDim2.new(0, 0, 1, 0)
	ProgressFill.BackgroundColor3 = XOLO.Accent
	ProgressFill.ZIndex = 152
	Instance.new("UICorner", ProgressFill).CornerRadius = UDim.new(1, 0)

	local TimeLbl = Instance.new("TextLabel", PlayerGui)
	TimeLbl.Size = UDim2.new(0, 50, 0, 20)
	TimeLbl.Position = UDim2.new(1, -62, 0, 33)
	TimeLbl.BackgroundTransparency = 1
	TimeLbl.Text = "0:00"
	TimeLbl.TextColor3 = XOLO.Muted
	TimeLbl.Font = Enum.Font.BuilderSans
	TimeLbl.TextSize = 10
	TimeLbl.ZIndex = 151

	local MusicSound = Instance.new("Sound", SoundService)
	MusicSound.Volume = 5
	MusicSound.Looped = true

	local isMusicMinimized = false
	MinMusicBtn.Activated:Connect(function()
		isMusicMinimized = not isMusicMinimized
		if isMusicMinimized then
			TweenService:Create(PlayerGui, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Size = UDim2.new(0, 45, 0, 45) }):Play()
			SongNameLbl.Visible = false
			ClosePlayerBtn.Visible = false
			PrevBtn.Visible = false
			NextBtn.Visible = false
			ProgressBg.Visible = false
			TimeLbl.Visible = false
			MinMusicBtn.Visible = false
			PlayBtnPlayer.Size = UDim2.new(1, 0, 1, 0)
			PlayBtnPlayer.Position = UDim2.new(0, 0, 0, 0)
			PlayBtnPlayer.Text = "🎵"
		else
			TweenService:Create(PlayerGui, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Size = UDim2.new(0, 230, 0, 95) }):Play()
			SongNameLbl.Visible = true
			ClosePlayerBtn.Visible = true
			PrevBtn.Visible = true
			NextBtn.Visible = true
			ProgressBg.Visible = true
			TimeLbl.Visible = true
			MinMusicBtn.Visible = true
			PlayBtnPlayer.Size = UDim2.new(0, 28, 0, 26)
			PlayBtnPlayer.Position = UDim2.new(0, 12, 0, 58)
			PlayBtnPlayer.Text = MusicSound.IsPlaying and "⏸" or "▶"
		end
	end)

	MakeDraggable(PlayerGui, SongNameLbl)

	local currentSongIndex = 1
	local function PlaySong(index)
		if not Songs[index] then return end
		currentSongIndex = index
		local song = Songs[index]
		ProgressFill.Size = UDim2.new(0, 0, 1, 0)
		TimeLbl.Text = "0:00"
		pcall(function()
			MusicSound:Stop()
			MusicSound.SoundId = "rbxassetid://" .. song.id
			MusicSound:Play()
			SongNameLbl.Text = song.name
			PlayerGui.Visible = true
			PlayBtnPlayer.Text = "⏸"
		end)
	end

	PlayBtnPlayer.Activated:Connect(function()
		if isMusicMinimized then
			if MusicSound.IsPlaying then
				MusicSound:Pause()
			else
				MusicSound:Resume()
			end
			PlayBtnPlayer.Text = "🎵"
		elseif MusicSound.IsPlaying then
			MusicSound:Pause()
			PlayBtnPlayer.Text = "▶"
		else
			MusicSound:Resume()
			PlayBtnPlayer.Text = "⏸"
		end
	end)

	PrevBtn.Activated:Connect(function()
		local newIndex = currentSongIndex - 1
		if newIndex < 1 then newIndex = #Songs end
		PlaySong(newIndex)
	end)

	NextBtn.Activated:Connect(function()
		local newIndex = currentSongIndex + 1
		if newIndex > #Songs then newIndex = 1 end
		PlaySong(newIndex)
	end)

	ClosePlayerBtn.Activated:Connect(function()
		MusicSound:Stop()
		PlayerGui.Visible = false
		ProgressFill.Size = UDim2.new(0, 0, 1, 0)
		TimeLbl.Text = "0:00"
	end)

	ProgressBg.Activated:Connect(function()
		if MusicSound.TimeLength > 0 then
			local percent = math.clamp((UIS:GetMouseLocation().X - ProgressBg.AbsolutePosition.X) / ProgressBg.AbsoluteSize.X, 0, 1)
			MusicSound.TimePosition = percent * MusicSound.TimeLength
		end
	end)

	local musicY = 0
	CreateLabel(MusicPage, "─── CANCIONES ───", musicY, XOLO.Accent)
	musicY += 24
	for i, song in ipairs(Songs) do
		local btn = Instance.new("TextButton", MusicPage)
		btn.Size = UDim2.new(1, 0, 0, 36)
		btn.Position = UDim2.new(0, 0, 0, musicY)
		btn.BackgroundColor3 = XOLO.Panel
		btn.Text = "🎵 " .. song.name
		btn.TextColor3 = XOLO.Text
		btn.Font = Enum.Font.BuilderSansBold
		btn.TextSize = 11
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.AutoButtonColor = false
		btn.ZIndex = 100

		local padding = Instance.new("UIPadding", btn)
		padding.PaddingLeft = UDim.new(0, 10)
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

		btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				TweenService:Create(btn, TweenInfo.new(0.1), { Size = UDim2.new(0.96, 0, 0, 36) }):Play()
			end
		end)
		btn.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				TweenService:Create(btn, TweenInfo.new(0.1), { Size = UDim2.new(1, 0, 0, 36) }):Play()
			end
		end)
		btn.Activated:Connect(function()
			PlaySound("click")
			PlaySong(i)
		end)
		musicY += 40
	end

	-- Minimizar y Toggle del Menú
	local isMinimized = false
	MinBtn.Activated:Connect(function()
		isMinimized = not isMinimized
		if isMinimized then
			TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Size = UDim2.new(0, 80, 0, 250) }):Play()
			TweenService:Create(ShadowFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 80, 0, 250) }):Play()
			Sidebar.Visible = false
			ContentArea.Visible = false
			Title.Text = "XOLO"
			Title.Size = UDim2.new(0, 50, 0, 20)
			Title.Position = UDim2.new(0, 15, 0, 60)
		else
			TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Size = UDim2.new(0, 320, 0, 480) }):Play()
			TweenService:Create(ShadowFrame, TweenInfo.new(0.3), { Size = UDim2.new(0, 320, 0, 480) }):Play()
			Sidebar.Visible = true
			ContentArea.Visible = true
			Title.Text = "XOLO HUB v2.0"
			Title.Size = UDim2.new(1, -120, 0, 26)
			Title.Position = UDim2.new(0, 50, 0, 12)
		end
	end)

	MakeDraggable(ToggleBtn, ToggleBtn)
	MakeDraggable(MainFrame, ToggleBtn)
	MakeDraggable(MainFrame, Header)

	_G.XoloMenuOpen = false
	function ToggleMenu()
		_G.XoloMenuOpen = not _G.XoloMenuOpen
		if _G.XoloMenuOpen then
			MainFrame.Visible = true
			ShadowFrame.Visible = true
			menuScale.Scale = 0.85
			TweenService:Create(menuScale, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
				Scale = math.clamp(math.min(Camera.ViewportSize.X, Camera.ViewportSize.Y) / 520, 0.6, 1)
			}):Play()
			ToggleBtn.Text = "✕ CERRAR"
			PlaySound("open")
			if not currentTab then
				SwitchTab("ESP")
			end
		else
			local t = TweenService:Create(menuScale, TweenInfo.new(0.2), { Scale = 0.85 })
			t:Play()
			t.Completed:Connect(function()
				MainFrame.Visible = false
				ShadowFrame.Visible = false
				UpdateScale()
			end)
			ToggleBtn.Text = "🚀 XOLO HUB"
			PlaySound("close")
		end
	end

	ToggleBtn.Activated:Connect(ToggleMenu)
	CloseBtn.Activated:Connect(ToggleMenu)
	SwitchTab("ESP")

	local lastGunScan = 0
	RunService.RenderStepped:Connect(function()
		pcall(UpdateESP)
		pcall(UpdateAimbot)

		local now = os.clock()
		if now - lastGunScan >= 0.12 then
			lastGunScan = now
			pcall(UpdateGunCham)
		end

		if PlayerGui.Visible and not isMusicMinimized and MusicSound.IsPlaying and MusicSound.TimeLength > 0 then
			local percent = MusicSound.TimePosition / MusicSound.TimeLength
			ProgressFill.Size = UDim2.new(percent, 0, 1, 0)
			local curM = math.floor(MusicSound.TimePosition / 60)
			local curS = math.floor(MusicSound.TimePosition % 60)
			TimeLbl.Text = string.format("%d:%02d", curM, curS)
		end
	end)

	print("[XOLO HUB v2.0] Cargado correctamente con ESP Box 2D, Tracers y Cham Gun 🚀")
end
