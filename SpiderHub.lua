--[[
    ================================================================
                     SPIDER HUB & KOALA SCRIPTS (UNIFICADO)
    ================================================================
    Aplicação integrada com interface escura moderna, responsiva,
    contendo todas as automações de Flee The Facility (Auto-Farm, 
    ESPs, Trolls, Evasão e Utilitários).
]]

-- Serviços do Roblox
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Evitar duplicidade de interface
if PlayerGui:FindFirstChild("SpiderHubGui") then
	PlayerGui.SpiderHubGui:Destroy()
end

-- Tenta obter o RemoteEvent do jogo com segurança
local RemoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvent")
if not RemoteEvent then
	task.spawn(function()
		RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent", 10)
	end)
end

-- Tenta carregar bibliotecas auxiliares do Koala Scripts
local PU
pcall(function()
	PU = loadstring(game:HttpGet("https://pastebin.com/raw/xAZ4WQRS"))()
end)

-- ==========================================
-- ESTADOS DO SISTEMA (VARIÁVEIS DE CONTROLE)
-- ==========================================
local FlyActive = false
local FlySpeed = 50
local NoclipActive = false
local ChamsActive = false
local ComputerTableESPActive = false
local FreezePodESPActive = false
local ChamsNeon = true
local ChamsTransparency = 0.4

-- Estados dos Utilitários
local FullbrightActive = false
local InfiniteJumpActive = false
local originalAmbient = Lighting.Ambient
local originalOutdoor = Lighting.OutdoorAmbient
local originalShadows = Lighting.GlobalShadows
local antiAfkActive = false
local antiAfkConnection
local noFogActive = false
local originalFogStart = Lighting.FogStart
local originalFogEnd = Lighting.FogEnd
local originalAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

-- Referências para o Fly e Conexões
local linVel, alignOri, flyConnection, jumpConnection
local mouseUnlockActive = false
local mouseUnlockConnection
local mouseUnlockBtn = nil

-- Tabela de progresso persistente dos computadores
local pcProgressTracker = {}

-- Lógicas e Configurações Portadas do Koala Scripts (Auto Farm & Variáveis)
local onsurvivorfarm = false
local OnBeastFarm = false
local bnhide = false
local clpos = false
local bnhideelapse = 0
local noelepse = 0
local lpos = nil
local Comp = 0
local Beast = nil
local farmtasks = {}
local TempPlayerStatsModule = nil

-- Configurações padrão do Auto Farm
local KeepComputer = false
local AutoHideHack = false
local UseMinimalTeleport = true
local TeleportInsteadTweenPCFarm = false
local TeleportToFreezePod = false
local TeleportToExitDoor = false
local FreezePodOnce = true
local ExitCancel = false
local WaitForSave = false
local WaitSaveDelay = 0
local ForcedTogglesDisabled = false
local FarmTweenSpeed = 16
local WaitTweenFast = 8
local MinimumDuration = 5
local StudsPerDelay = 16
local TriggerPrioritization = 1
local TriggerUnCampOut = 5
local CampTweenAnimOut = 30
local CampHackOut = 30
local HackBanUnbanTime = 5
local CampFreezePodOut = 30
local CampEscapeOut = 30

-- Configurações Beast Farm
local WaitForExitBeastFarm = false
local CaptureForSave = false
local BeastInstantTP = false
local BeastFarmTweenSpeed = 25
local BeastThreshold = 4

-- Configurações Adicionais & Troll
local SlowBeast = false
local UnTieAll = false
local UnTieMe = false
local Beast3rdPerson = false
local AntiPCError = false
local RagdollMovement = false
local AutoHideFromSeer = false
local ReturnFromHideSeer = false
local SpeedHackCrawlActive = false
local HackCrawlWPeople = false
local HackCrawlType = 0 -- 0: Crawl, 1: Jump, 2: Air
local HackCrawlTime = 0.33
local HackCrawlDelay = 0.2
local AlertModerator = false
local KickOnModerator = false
local HideBeastNear = false
local HideBeastNearDist = 35
local BeastTieRange = 0
local HitboxScale = 1

-- Soundboard Troll Configs
local STSpamPercentage = 50
local STSpamCorrect = false
local STSpamWarning = false
local STSpamSafe = false
local STSpamDetected = false
local STSpamSeen = false
local STSpamErrorAll = false
local STSpamErrorOne = false
local STSpamExitsUnlock = false

-- Variáveis do Inspetor de Instâncias
local InspectorActive = false
local SelectedInstance = nil
local OriginalColor = nil
local HighlightEffect = Instance.new("Highlight")
HighlightEffect.FillColor = Color3.fromRGB(0, 150, 255)
HighlightEffect.FillTransparency = 0.5
HighlightEffect.OutlineColor = Color3.fromRGB(255, 255, 255)
HighlightEffect.Name = "SpiderInspectorHighlight"

local Mouse = LocalPlayer:GetMouse()
local inspectorKey = Enum.KeyCode.F4

-- Tabelas para gerenciamento de FPS/Ping
local lastIteration = tick()
local frameHistory = {}
local fps = 0

-- Containers de UI
local tabs = {}
local tabButtons = {}

-- ==========================================
-- FUNÇÕES AUXILIARES E DE INFRAESTRUTURA
-- ==========================================

local function GetCharacter()
	local character = LocalPlayer.Character
	if not character then return nil, nil, nil end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	return character, rootPart, humanoid
end

local function IsThereChar(APlr)
	local plr = APlr or LocalPlayer
	if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") then
		return true
	end
	return false
end

local function TPPlayerSpawn()
	if IsThereChar() and Workspace:FindFirstChild("LobbySpawnPad") then
		LocalPlayer.Character:PivotTo(Workspace.LobbySpawnPad.CFrame * CFrame.new(0, 3, 0))
	end
end

local function obterCorPeloNome(username)
	local hash = 0
	for i = 1, #username do 
		hash = hash + string.byte(username, i) 
	end
	return Color3.fromHSV((hash % 100) / 100, 0.9, 1)
end

-- ==========================================
-- SISTEMA DE ESPS E DESTAQUES VISUAIS
-- ==========================================

local function aplicarComputerESP(model)
	if not model:IsA("Model") or model.Name ~= "ComputerTable" then return end
	
	local highlight = model:FindFirstChild("ComputerHighlight")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "ComputerHighlight"
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.OutlineTransparency = 0.2
		highlight.FillTransparency = 0.4
		highlight.Parent = model
	end

	local billboard = model:FindFirstChild("KSBillboard")
	if not billboard then
		billboard = Instance.new("BillboardGui")
		billboard.Name = "KSBillboard"
		billboard.AlwaysOnTop = true
		billboard.Size = UDim2.new(0, 250, 0, 25)
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 1.5, 0)

		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBold
		label.Size = UDim2.new(1, 0, 1, 0)
		label.TextScaled = true
		label.RichText = true
		label.Parent = billboard

		billboard.Parent = model
	end

	local screen = model:FindFirstChild("Screen")
	if screen then
		if screen.BrickColor == BrickColor.new("Bright blue") then
			highlight.FillColor = Color3.fromRGB(0, 180, 255)
			billboard.TextLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
		elseif screen.BrickColor == BrickColor.new("Dark green") then
			highlight.FillColor = Color3.fromRGB(0, 230, 100)
			billboard.TextLabel.TextColor3 = Color3.fromRGB(0, 230, 100)
		else
			highlight.FillColor = Color3.fromRGB(255, 50, 50)
			billboard.TextLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
		end
	end
end

local function atualizarComputerTableESP()
	for _, descendant in ipairs(Workspace:GetDescendants()) do
		local nomeFormatado = string.lower(descendant.Name)
		if (nomeFormatado == "computertable" or nomeFormatado == "computer table") and descendant:IsA("Model") then
			if ComputerTableESPActive then
				aplicarComputerESP(descendant)
			else
				local highlight = descendant:FindFirstChild("ComputerHighlight")
				if highlight then highlight:Destroy() end
				local billboard = descendant:FindFirstChild("KSBillboard")
				if billboard then billboard:Destroy() end
			end
		end
	end
end

local function aplicarFreezePodESP(descendant)
	local nomeFormatado = string.gsub(string.lower(descendant.Name), " ", "")
	if nomeFormatado == "freezepod" and descendant:IsA("Model") then
		local highlight = descendant:FindFirstChild("FreezePodHighlight")
		if not highlight then
			highlight = Instance.new("Highlight")
			highlight.Name = "FreezePodHighlight"
			highlight.FillColor = Color3.fromRGB(0, 23, 55)
			highlight.FillTransparency = 0.4
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.OutlineTransparency = 0.1
			highlight.Parent = descendant
		end
	end
end

local function atualizarFreezePodESP()
	for _, descendant in ipairs(Workspace:GetDescendants()) do
		local nomeFormatado = string.gsub(string.lower(descendant.Name), " ", "")
		if nomeFormatado == "freezepod" and descendant:IsA("Model") then
			if FreezePodESPActive then
				aplicarFreezePodESP(descendant)
			else
				local highlight = descendant:FindFirstChild("FreezePodHighlight")
				if highlight then highlight:Destroy() end
			end
		end
	end
end

-- ESP de Saídas e Ventilações do Koala
local ftfVisualsActive = false
local function applyFTFHighlight(name, color)
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Name == name and obj:IsA("Model") then
			local hl = obj:FindFirstChild("FTF_Highlight")
			if ftfVisualsActive then
				if not hl then
					hl = Instance.new("Highlight")
					hl.Name = "FTF_Highlight"
					hl.FillTransparency = 0.5
					hl.OutlineColor = Color3.new(1,1,1)
					hl.Parent = obj
				end
				hl.FillColor = color
			elseif hl then
				hl:Destroy()
			end
		end
	end
end

-- ESP de Armários (Locker ESP)
local lockerESPActive = false
local function updateLockerESP()
	for _, locker in ipairs(CollectionService:GetTagged("LOCKER")) do
		if locker:IsA("Model") then
			local hl = locker:FindFirstChild("LockerHighlight")
			if lockerESPActive then
				if not hl then
					hl = Instance.new("Highlight")
					hl.Name = "LockerHighlight"
					hl.FillColor = Color3.fromRGB(210, 210, 0)
					hl.FillTransparency = 0.6
					hl.OutlineColor = Color3.fromRGB(255, 255, 100)
					hl.OutlineTransparency = 0.2
					hl.Parent = locker
				end
			elseif hl then
				hl:Destroy()
			end
		end
	end
end

-- ESP de Dutos (VentBlock) com SurfaceGui
local ventESPActive = false
local ventHighlights = {}
local function updateVentESP()
	for i = #ventHighlights, 1, -1 do
		local v = ventHighlights[i]
		if not ventESPActive and v then
			for _, child in ipairs(v:GetChildren()) do
				if child:IsA("SurfaceGui") and child.Name == "KHHighlight" then
					child:Destroy()
				end
			end
			table.remove(ventHighlights, i)
		end
	end
	if ventESPActive and ReplicatedStorage:FindFirstChild("CurrentMap") and ReplicatedStorage.CurrentMap.Value then
		local debounce = 0
		for _, v in ipairs(ReplicatedStorage.CurrentMap.Value:GetDescendants()) do
			debounce = debounce + 1
			if debounce >= 100 then
				task.wait()
				debounce = 0
			end
			if v:IsA("BasePart") and string.find(string.lower(v.Name), "ventblock") and not v:FindFirstChild("KHHighlight") then
				local function NewSUI(Face)
					local NewHighlight = Instance.new("SurfaceGui")
					NewHighlight.Name = "KHHighlight"
					NewHighlight.Adornee = v
					NewHighlight.AlwaysOnTop = true
					NewHighlight.Face = Face
					NewHighlight.Parent = v

					local NewFrame = Instance.new("Frame")
					NewFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 200)
					NewFrame.Transparency = 0.6
					NewFrame.Size = UDim2.new(1, 0, 1, 0)
					NewFrame.Parent = NewHighlight
				end

				NewSUI(Enum.NormalId.Front)
				NewSUI(Enum.NormalId.Back)
				NewSUI(Enum.NormalId.Left)
				NewSUI(Enum.NormalId.Right)
				NewSUI(Enum.NormalId.Top)
				NewSUI(Enum.NormalId.Bottom)

				table.insert(ventHighlights, v)
			end
		end
	end
end

-- ESP de Itens Comuns
local itemEspActive = false
local function aplicarItemESP(item)
	if not item:IsA("Tool") or not item:FindFirstChild("Handle") then return end
	local handle = item.Handle
	if handle:FindFirstChild("ItemESP_Tag") then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ItemESP_Tag"
	billboard.Size = UDim2.new(0, 120, 0, 30)
	billboard.AlwaysOnTop = true
	billboard.ExtentsOffset = Vector3.new(0, 1.5, 0)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "📦 " .. item.Name
	label.TextColor3 = Color3.fromRGB(0, 220, 150)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 9
	label.TextStrokeTransparency = 0.5
	label.Parent = billboard

	billboard.Parent = handle
end

-- ==========================================
-- CONTROLE DE MOVIMENTAÇÃO E DESTRAVAMENTO DE MOUSE
-- ==========================================

local function toggleMouseUnlock()
	mouseUnlockActive = not mouseUnlockActive
	if mouseUnlockActive then
		if mouseUnlockBtn then
			mouseUnlockBtn.Text = "Ativado"
			mouseUnlockBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
			mouseUnlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
		mouseUnlockConnection = RunService.RenderStepped:Connect(function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end)
	else
		if mouseUnlockBtn then
			mouseUnlockBtn.Text = "Desativado"
			mouseUnlockBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
			mouseUnlockBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
		end
		if mouseUnlockConnection then
			mouseUnlockConnection:Disconnect()
			mouseUnlockConnection = nil
		end
	end
end

local function updateFlyPhysics()
	local _, rootPart, _ = GetCharacter()
	if not rootPart then return end

	local att = rootPart:FindFirstChild("RootAttachment") or Instance.new("Attachment", rootPart)

	if not linVel then
		linVel = Instance.new("LinearVelocity")
		linVel.Attachment0 = att
		linVel.RelativeTo = Enum.ActuatorRelativeTo.World
		linVel.MaxForce = math.huge
		linVel.VectorVelocity = Vector3.zero
	end

	if not alignOri then
		alignOri = Instance.new("AlignOrientation")
		alignOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
		alignOri.Attachment0 = att
		alignOri.RigidityEnabled = true
	end

	linVel.Parent = rootPart
	alignOri.Parent = rootPart
end

local function toggleFly(btn)
	local _, rootPart, humanoid = GetCharacter()
	if not rootPart or not humanoid then return end

	updateFlyPhysics()
	FlyActive = not FlyActive
	humanoid.PlatformStand = FlyActive
	linVel.Enabled = FlyActive
	alignOri.Enabled = FlyActive

	if FlyActive then
		if btn then
			btn.Text = "Ativado"
			btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		flyConnection = RunService.Heartbeat:Connect(function()
			local character, currentRoot, _ = GetCharacter()
			if not character or not currentRoot then return end
			
			local cam = workspace.CurrentCamera
			local dir = Vector3.zero

			if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.E) then dir += Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.Q) then dir -= Vector3.new(0, 1, 0) end

			if dir.Magnitude > 0 then dir = dir.Unit end
			if linVel then linVel.VectorVelocity = dir * FlySpeed end
			if alignOri then alignOri.CFrame = cam.CFrame end
		end)
	else
		if btn then
			btn.Text = "Desativado"
			btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		end

		if flyConnection then 
			flyConnection:Disconnect() 
			flyConnection = nil 
		end
		if linVel then linVel.VectorVelocity = Vector3.zero end
	end
end

local function toggleNoclip(btn)
	NoclipActive = not NoclipActive
	if PU then
		PU.NoClip = NoclipActive
	end
	if NoclipActive then
		if btn then
			btn.Text = "Ativado"
			btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	else
		if btn then
			btn.Text = "Desativado"
			btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
	end
end

RunService.Stepped:Connect(function()
	if NoclipActive then
		local character, _, humanoid = GetCharacter()
		if character and humanoid and humanoid.Health > 0 then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end
end)

-- ==========================================
-- GESTÃO DO CORPO DE CHAMS E ESP DE JOGADORES
-- ==========================================

local function colorirPersonagem(character, targetPlayer)
	if not character or not targetPlayer or targetPlayer == LocalPlayer or not ChamsActive then return end
	local corDoJogador = obterCorPeloNome(targetPlayer.Name)

	local highlight = character:FindFirstChild("ColorChamsHighlight")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "ColorChamsHighlight"
		highlight.FillColor = corDoJogador
		highlight.FillTransparency = ChamsTransparency
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.OutlineTransparency = 0.2
		highlight.Parent = character
	end

	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Color = corDoJogador
			if ChamsNeon then part.Material = Enum.Material.Neon end
		elseif part:IsA("Shirt") or part:IsA("Pants") or part:IsA("ShirtGraphic") then
			part:Destroy()
		end
	end
end

local BeastHighlights = {}
local function UpdateBeastESP(state)
	for i = #BeastHighlights, 1, -1 do
		local v = BeastHighlights[i]
		if not state or (v and v.Adornee == nil) then
			if v then v:Destroy() end
			table.remove(BeastHighlights, i)
		end
	end
	if state then
		for _, v in ipairs(Players:GetPlayers()) do
			if v.Character and v.Character:FindFirstChild("BeastPowers") and v ~= LocalPlayer and not v.Character:FindFirstChild("KHBeastHighlight") then
				local NewHighlight = Instance.new("Highlight")
				NewHighlight.Name = "KHBeastHighlight"
				NewHighlight.Adornee = v.Character
				NewHighlight.Parent = v.Character
				NewHighlight.FillColor = Color3.fromRGB(200, 50, 50)
				NewHighlight.OutlineColor = Color3.fromRGB(255, 50, 50)
				table.insert(BeastHighlights, NewHighlight)
			end
		end
	end
end

local PlrHighlights = {}
local function UpdatePlrESP(state)
	for i = #PlrHighlights, 1, -1 do
		local v = PlrHighlights[i]
		if not state or (v and v.Adornee == nil) or (v and v.Adornee and v.Adornee.Parent and v.Adornee.Parent:FindFirstChild("BeastPowers")) then
			if v then v:Destroy() end
			table.remove(PlrHighlights, i)
		end
	end
	if state then
		for _, v in ipairs(Players:GetPlayers()) do
			if v.Character and not v.Character:FindFirstChild("BeastPowers") and v ~= LocalPlayer and not v.Character:FindFirstChild("KHPlayerHighlight") then
				local NewHighlight = Instance.new("Highlight")
				NewHighlight.Name = "KHPlayerHighlight"
				NewHighlight.Adornee = v.Character
				NewHighlight.FillColor = Color3.fromRGB(0, 230, 0)
				NewHighlight.OutlineColor = Color3.fromRGB(0, 255, 0)
				NewHighlight.Parent = v.Character
				table.insert(PlrHighlights, NewHighlight)
			end
		end
	end
end

-- ==========================================
-- CRIAÇÃO DA INTERFACE VISUAL (GUI PRINCIPAL)
-- ==========================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpiderHubGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 580, 0, 390)
mainFrame.Position = UDim2.new(0.5, -290, 0.5, -195)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

do
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 8)
	mainCorner.Parent = mainFrame

	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Color3.fromRGB(130, 50, 200)
	mainStroke.Thickness = 1
	mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	mainStroke.Parent = mainFrame
end

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

do
	local topCorner = Instance.new("UICorner")
	topCorner.CornerRadius = UDim.new(0, 10)
	topCorner.Parent = topBar

	local topMask = Instance.new("Frame")
	topMask.Size = UDim2.new(1, 0, 0, 10)
	topMask.Position = UDim2.new(0, 0, 1, -10)
	topMask.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	topMask.BorderSizePixel = 0
	topMask.Parent = topBar

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -100, 1, 0)
	title.Position = UDim2.new(0, 15, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "🕷️ SPIDER & KOALA HUB"
	title.TextColor3 = Color3.fromRGB(240, 240, 250)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = topBar
end

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 150, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

do
	local sidebarCorner = Instance.new("UICorner")
	sidebarCorner.CornerRadius = UDim.new(0, 10)
	sidebarCorner.Parent = sidebar

	local sidebarLayout = Instance.new("UIListLayout")
	sidebarLayout.Padding = UDim.new(0, 4)
	sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	sidebarLayout.Parent = sidebar

	local sidebarPadding = Instance.new("UIPadding")
	sidebarPadding.PaddingTop = UDim.new(0, 8)
	sidebarPadding.Parent = sidebar
end

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -165, 1, -55)
contentContainer.Position = UDim2.new(0, 155, 0, 45)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

local statusBar = Instance.new("TextLabel")
statusBar.Size = UDim2.new(1, -10, 0, 20)
statusBar.Position = UDim2.new(0, 5, 1, -25)
statusBar.BackgroundTransparency = 1
statusBar.Text = "Pronto."
statusBar.TextColor3 = Color3.fromRGB(150, 150, 160)
statusBar.Font = Enum.Font.SourceSans
statusBar.TextSize = 13
statusBar.TextXAlignment = Enum.TextXAlignment.Left
statusBar.ZIndex = 3
statusBar.Parent = mainFrame

local function setStatus(msg)
	statusBar.Text = "LOG: " .. tostring(msg)
	task.spawn(function()
		statusBar.TextColor3 = Color3.fromRGB(130, 50, 200)
		task.wait(1.5)
		statusBar.TextColor3 = Color3.fromRGB(150, 150, 160)
	end)
end

-- Botão Minimizar
local minBtn = Instance.new("TextButton")
minBtn.Name = "MinimizeButton"
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.AnchorPoint = Vector2.new(1, 0.5)
minBtn.Position = UDim2.new(1, -12, 0.5, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(240, 240, 250)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.BorderSizePixel = 0
minBtn.ZIndex = 10
minBtn.Active = true
minBtn.Parent = topBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minBtn

local isMinimized = false
local originalSize = UDim2.new(0, 580, 0, 390)
local minimizedSize = UDim2.new(0, 580, 0, 40)

minBtn.MouseEnter:Connect(function()
	TweenService:Create(minBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(130, 50, 200)}):Play()
end)

minBtn.MouseLeave:Connect(function()
	TweenService:Create(minBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
end)

minBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		minBtn.Text = "+"
		sidebar.Visible = false
		contentContainer.Visible = false
		statusBar.Visible = false
		TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = minimizedSize}):Play()
	else
		minBtn.Text = "-"
		local expandTween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = originalSize})
		expandTween:Play()
		expandTween.Completed:Connect(function()
			if not isMinimized then
				sidebar.Visible = true
				contentContainer.Visible = true
				statusBar.Visible = true
			end
		end)
	end
end)

-- ==========================================
-- GESTÃO DE ABAS E CONFIGURAÇÕES DE INTERFACE
-- ==========================================

local function createTab(tabName)
	local page = Instance.new("Frame")
	page.Size = UDim2.new(1, 0, 1, -10)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = contentContainer

	tabs[tabName] = page

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.92, 0, 0, 28)
	btn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
	btn.BackgroundTransparency = 1
	btn.Text = "  " .. tabName
	btn.TextColor3 = Color3.fromRGB(160, 160, 170)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 10.5
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.BorderSizePixel = 0
	btn.Parent = sidebar

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 5)
	btnCorner.Parent = btn

	local activeIndicator = Instance.new("Frame")
	activeIndicator.Size = UDim2.new(0, 3, 0.5, 0)
	activeIndicator.Position = UDim2.new(0, 3, 0.25, 0)
	activeIndicator.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
	activeIndicator.BorderSizePixel = 0
	activeIndicator.BackgroundTransparency = 1
	activeIndicator.Parent = btn

	tabButtons[tabName] = btn

	btn.MouseEnter:Connect(function()
		if not page.Visible then
			TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.93, TextColor3 = Color3.fromRGB(220, 220, 230)}):Play()
		end
	end)

	btn.MouseLeave:Connect(function()
		if not page.Visible then
			TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(160, 160, 170)}):Play()
		end
	end)

	btn.MouseButton1Click:Connect(function()
		for name, p in pairs(tabs) do
			local isTarget = (name == tabName)
			local currentBtn = tabButtons[name]
			local indicator = currentBtn:FindFirstChildOfClass("Frame")

			p.Visible = isTarget
			if isTarget then
				TweenService:Create(currentBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0.88, BackgroundColor3 = Color3.fromRGB(130, 50, 200), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				if indicator then TweenService:Create(indicator, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play() end
			else
				TweenService:Create(currentBtn, TweenInfo.new(0.1), {BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(24, 24, 30), TextColor3 = Color3.fromRGB(160, 160, 170)}):Play()
				if indicator then TweenService:Create(indicator, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play() end
			end
		end
	end)

	return page
end

-- Helper para gerar opções liga/desliga estruturadas
local function criarFrameConfig(titulo, textoBotao, paginaAlvo, callback)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, -10, 0, 36)
	f.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	f.BorderSizePixel = 0
	f.Parent = paginaAlvo

	local fCorner = Instance.new("UICorner")
	fCorner.CornerRadius = UDim.new(0, 5)
	fCorner.Parent = f

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.65, 0, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = titulo
	label.TextColor3 = Color3.fromRGB(235, 235, 240)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 10
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = f

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.24, 0, 0.65, 0)
	btn.Position = UDim2.new(0.73, 0, 0.175, 0)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	btn.Text = textoBotao
	btn.TextColor3 = Color3.fromRGB(180, 180, 190)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 9
	btn.BorderSizePixel = 0
	btn.Parent = f

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 4)
	btnCorner.Parent = btn

	local btnStroke = Instance.new("UIStroke")
	btnStroke.Color = Color3.fromRGB(45, 45, 55)
	btnStroke.Thickness = 1
	btnStroke.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(110, 40, 185), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		TweenService:Create(btnStroke, TweenInfo.new(0.1), {Color = Color3.fromRGB(140, 60, 220)}):Play()
	end)

	btn.MouseLeave:Connect(function()
		local isEnabled = (btn.Text == "Ativado")
		local targetBg = isEnabled and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
		local targetTx = isEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)
		local targetStroke = isEnabled and Color3.fromRGB(150, 70, 230) or Color3.fromRGB(45, 45, 55)

		TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = targetBg, TextColor3 = targetTx}):Play()
		TweenService:Create(btnStroke, TweenInfo.new(0.1), {Color = targetStroke}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		callback(btn)
	end)

	return f
end

-- Helper para Inputs Numéricos
local function criarFrameInput(titulo, valorInicial, paginaAlvo, callback)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, -10, 0, 36)
	f.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	f.BorderSizePixel = 0
	f.Parent = paginaAlvo

	local fCorner = Instance.new("UICorner")
	fCorner.CornerRadius = UDim.new(0, 5)
	fCorner.Parent = f

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.65, 0, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = titulo
	label.TextColor3 = Color3.fromRGB(235, 235, 240)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 10
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = f

	local input = Instance.new("TextBox")
	input.Size = UDim2.new(0.24, 0, 0.65, 0)
	input.Position = UDim2.new(0.73, 0, 0.175, 0)
	input.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
	input.TextColor3 = Color3.fromRGB(255, 255, 255)
	input.Text = tostring(valorInicial)
	input.Font = Enum.Font.GothamBold
	input.TextSize = 10
	input.BorderSizePixel = 0
	input.Parent = f

	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = UDim.new(0, 4)
	inputCorner.Parent = input

	input.FocusLost:Connect(function(enterPressed)
		local val = tonumber(input.Text)
		if val then
			callback(val)
		else
			input.Text = tostring(valorInicial)
		end
	end)

	return f
end

-- Instanciação de Abas
local homePage = createTab("Início")
local movePage = createTab("Movimentação")
local playersPage = createTab("Jogadores")
local ftfPage = createTab("Auto Farm")
local visualPage = createTab("Visual")
local trollPage = createTab("Troll & Sounds")
local utilsPage = createTab("Utilitários")
local inspectorPage = createTab("Inspetor")

tabs["Início"].Visible = true
tabButtons["Início"].BackgroundColor3 = Color3.fromRGB(130, 50, 200)
tabButtons["Início"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- ==========================================
-- CONTEÚDO DA ABA: INÍCIO
-- ==========================================
do
	local welcomeLabel = Instance.new("TextLabel")
	welcomeLabel.Size = UDim2.new(1, 0, 0, 30)
	welcomeLabel.BackgroundTransparency = 1
	welcomeLabel.Text = "Painel Integrado Spider Hub & Koala Scripts"
	welcomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	welcomeLabel.Font = Enum.Font.GothamBold
	welcomeLabel.TextSize = 13
	welcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
	welcomeLabel.Parent = homePage

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, 0, 1, -40)
	descLabel.Position = UDim2.new(0, 0, 0, 35)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = "Atalhos Rápidos Gerais:\n[P] Ativar/Desativar Voo (Fly)\n[N] Ativar/Desativar Noclip\n[Alt] Soltar Cursor / Fechar Painel\n[F4] Modo Inspetor de Blocos\n[Ctrl + 2] Ativar Aceleração de Hack"
	descLabel.TextColor3 = Color3.fromRGB(170, 170, 180)
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 11
	descLabel.TextWrapped = true
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.Parent = homePage
end

-- ==========================================
-- CONTEÚDO DA ABA: MOVIMENTAÇÃO
-- ==========================================
local moveScroll = Instance.new("ScrollingFrame")
moveScroll.Size = UDim2.new(1, 0, 1, 0)
moveScroll.BackgroundTransparency = 1
moveScroll.BorderSizePixel = 0
moveScroll.ScrollBarThickness = 4
moveScroll.ScrollBarImageColor3 = Color3.fromRGB(130, 50, 200)
moveScroll.Parent = movePage

local moveLayout = Instance.new("UIListLayout")
moveLayout.Padding = UDim.new(0, 6)
moveLayout.Parent = moveScroll

criarFrameConfig("Habilitar Vôo (Fly) [P]", "Desativado", moveScroll, function(btn)
	toggleFly(btn)
end)

criarFrameInput("Velocidade do Vôo:", FlySpeed, moveScroll, function(val)
	FlySpeed = val
end)

criarFrameConfig("Ativar Noclip [N]", "Desativado", moveScroll, function(btn)
	toggleNoclip(btn)
end)

criarFrameConfig("Pulo Infinito", "Desativado", moveScroll, function(btn)
	InfiniteJumpActive = not InfiniteJumpActive
	if InfiniteJumpActive then
		btn.Text = "Ativado"
		btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		jumpConnection = UserInputService.JumpRequest:Connect(function()
			local _, _, humanoid = GetCharacter()
			if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
		end)
	else
		btn.Text = "Desativado"
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		if jumpConnection then
			jumpConnection:Disconnect()
			jumpConnection = nil
		end
	end
end)

local originalGravity = Workspace.Gravity
criarFrameConfig("Gravidade Baixa (Lua)", "Desativado", moveScroll, function(btn)
	if Workspace.Gravity == originalGravity then
		Workspace.Gravity = 30
		btn.Text = "Ativado"
		btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
	else
		Workspace.Gravity = originalGravity
		btn.Text = "Desativado"
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	end
end)

criarFrameConfig("Salva-Vidas (Anti-Void)", "Desativado", moveScroll, function(btn)
	antiVoidActive = not antiVoidActive
	btn.Text = antiVoidActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = antiVoidActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(45, 45, 55)
end)

moveLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	moveScroll.CanvasSize = UDim2.new(0, 0, 0, moveLayout.AbsoluteContentSize.Y + 10)
end)

-- ==========================================
-- CONTEÚDO DA ABA: JOGADORES (SPECTATE / TELEPORT)
-- ==========================================
do
	local pSearch = Instance.new("TextBox")
	pSearch.Size = UDim2.new(1, -10, 0, 28)
	pSearch.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	pSearch.PlaceholderText = "Pesquisar jogador..."
	pSearch.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
	pSearch.Text = ""
	pSearch.TextColor3 = Color3.fromRGB(240, 240, 240)
	pSearch.Font = Enum.Font.Gotham
	pSearch.TextSize = 11
	pSearch.BorderSizePixel = 0
	pSearch.Parent = playersPage

	local pSearchCorner = Instance.new("UICorner")
	pSearchCorner.CornerRadius = UDim.new(0, 5)
	pSearchCorner.Parent = pSearch

	local pScroll = Instance.new("ScrollingFrame")
	pScroll.Size = UDim2.new(1, 0, 1, -35)
	pScroll.Position = UDim2.new(0, 0, 0, 35)
	pScroll.BackgroundTransparency = 1
	pScroll.BorderSizePixel = 0
	pScroll.ScrollBarThickness = 4
	pScroll.ScrollBarImageColor3 = Color3.fromRGB(130, 50, 200)
	pScroll.Parent = playersPage

	local pListLayout = Instance.new("UIListLayout")
	pListLayout.Padding = UDim.new(0, 5)
	pListLayout.Parent = pScroll

	local spectatingPlayer = nil
	local spectateConnection = nil

	local function resetarBotoesEspectar()
		for _, row in ipairs(pScroll:GetChildren()) do
			if row:IsA("Frame") then
				local sBtn = row:FindFirstChild("SpectateButton")
				if sBtn then
					sBtn.Text = "Espectar"
					sBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
				end
			end
		end
	end

	local function alternarEspectador(targetPlayer, specBtn)
		local camera = workspace.CurrentCamera
		if not camera then return end

		if spectateConnection then
			pcall(function() spectateConnection:Disconnect() end)
			spectateConnection = nil
		end

		if spectatingPlayer == targetPlayer then
			spectatingPlayer = nil
			camera.CameraType = Enum.CameraType.Custom
			local _, _, localHum = GetCharacter()
			if localHum then camera.CameraSubject = localHum end
			resetarBotoesEspectar()
			setStatus("Câmera restaurada.")
		else
			local targetChar = targetPlayer.Character
			local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")

			if targetHum then
				resetarBotoesEspectar()
				spectatingPlayer = targetPlayer
				camera.CameraType = Enum.CameraType.Custom
				camera.CameraSubject = targetHum

				specBtn.Text = "Olhando"
				specBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
				setStatus("Espectando: " .. targetPlayer.DisplayName)
			end
		end
	end

	local function teleportToPlayer(targetPlayer)
		local _, localRoot, _ = GetCharacter()
		local targetChar = targetPlayer.Character
		local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

		if localRoot and targetRoot then
			localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)
			setStatus("Teleportado para: " .. targetPlayer.DisplayName)
		end
	end

	local function updatePlayersList()
		for _, child in ipairs(pScroll:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end

		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			if otherPlayer ~= LocalPlayer then
				local rowFrame = Instance.new("Frame")
				rowFrame.Name = otherPlayer.Name .. "_row"
				rowFrame.Size = UDim2.new(1, -10, 0, 30)
				rowFrame.BackgroundTransparency = 1
				rowFrame.Parent = pScroll

				local tpBtn = Instance.new("TextButton")
				tpBtn.Size = UDim2.new(0.7, -4, 1, 0)
				tpBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
				tpBtn.BorderSizePixel = 0
				tpBtn.Text = string.format("  %s (@%s)", otherPlayer.DisplayName, otherPlayer.Name)
				tpBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
				tpBtn.Font = Enum.Font.GothamMedium
				tpBtn.TextSize = 9.5
				tpBtn.TextXAlignment = Enum.TextXAlignment.Left
				tpBtn.Parent = rowFrame

				local specBtn = Instance.new("TextButton")
				specBtn.Name = "SpectateButton"
				specBtn.Size = UDim2.new(0.3, 0, 1, 0)
				specBtn.Position = UDim2.new(0.7, 4, 0, 0)
				specBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
				specBtn.BorderSizePixel = 0
				specBtn.Text = "Espectar"
				specBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
				specBtn.Font = Enum.Font.GothamBold
				specBtn.TextSize = 9
				specBtn.Parent = rowFrame

				local rowCorner = Instance.new("UICorner")
				rowCorner.CornerRadius = UDim.new(0, 4)
				rowCorner.Parent = tpBtn

				local specCorner = Instance.new("UICorner")
				specCorner.CornerRadius = UDim.new(0, 4)
				specCorner.Parent = specBtn

				tpBtn.MouseButton1Click:Connect(function() teleportToPlayer(otherPlayer) end)
				specBtn.MouseButton1Click:Connect(function() alternarEspectador(otherPlayer, specBtn) end)
			end
		end
		pScroll.CanvasSize = UDim2.new(0, 0, 0, pListLayout.AbsoluteContentSize.Y + 10)
	end

	pSearch:GetPropertyChangedSignal("Text"):Connect(function()
		local query = string.lower(pSearch.Text)
		for _, row in ipairs(pScroll:GetChildren()) do
			if row:IsA("Frame") then
				row.Visible = string.find(string.lower(row.Name), query) ~= nil
			end
		end
	end)

	Players.PlayerAdded:Connect(function() task.wait(0.5); updatePlayersList() end)
	Players.PlayerRemoving:Connect(updatePlayersList)
	updatePlayersList()
end

-- ==========================================
-- CONTEÚDO DA ABA: FLEE THE FACILITY / AUTO FARM
-- ==========================================
local ftfScroll = Instance.new("ScrollingFrame")
ftfScroll.Size = UDim2.new(1, 0, 1, 0)
ftfScroll.BackgroundTransparency = 1
ftfScroll.BorderSizePixel = 0
ftfScroll.ScrollBarThickness = 4
ftfScroll.ScrollBarImageColor3 = Color3.fromRGB(130, 50, 200)
ftfScroll.Parent = ftfPage

local ftfLayout = Instance.new("UIListLayout")
ftfLayout.Padding = UDim.new(0, 6)
ftfLayout.Parent = ftfScroll

-- Configurações Ativas do Auto Farm Sobrevivente
criarFrameConfig("Survivor Auto Farm", "Desativado", ftfScroll, function(btn)
	ComputerAutoFarm = not ComputerAutoFarm
	btn.Text = ComputerAutoFarm and "Ativado" or "Desativado"
	btn.BackgroundColor3 = ComputerAutoFarm and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	if ComputerAutoFarm then DoSurvivorFarm() end
end)

criarFrameConfig("Nunca Trocar de PC no Meio", "Desativado", ftfScroll, function(btn)
	KeepComputer = not KeepComputer
	btn.Text = KeepComputer and "Ativado" or "Desativado"
	btn.BackgroundColor3 = KeepComputer and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

criarFrameConfig("Auto Esconder no Hacking", "Desativado", ftfScroll, function(btn)
	AutoHideHack = not AutoHideHack
	btn.Text = AutoHideHack and "Ativado" or "Desativado"
	btn.BackgroundColor3 = AutoHideHack and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

criarFrameConfig("Teleport Direto (Sem Glide)", "Desativado", ftfScroll, function(btn)
	TeleportInsteadTweenPCFarm = not TeleportInsteadTweenPCFarm
	btn.Text = TeleportInsteadTweenPCFarm and "Ativado" or "Desativado"
	btn.BackgroundColor3 = TeleportInsteadTweenPCFarm and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

-- Configurações Beast Farm
criarFrameConfig("Beast Auto Farm", "Desativado", ftfScroll, function(btn)
	AutoBeastFarm = not AutoBeastFarm
	btn.Text = AutoBeastFarm and "Ativado" or "Desativado"
	btn.BackgroundColor3 = AutoBeastFarm and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	if AutoBeastFarm then DoBeastFarm() end
end)

criarFrameConfig("Espera Portas para Sair", "Desativado", ftfScroll, function(btn)
	WaitForExitBeastFarm = not WaitForExitBeastFarm
	btn.Text = WaitForExitBeastFarm and "Ativado" or "Desativado"
	btn.BackgroundColor3 = WaitForExitBeastFarm and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

criarFrameInput("Velocidade do Farm (Normal: 16):", FarmTweenSpeed, ftfScroll, function(val)
	FarmTweenSpeed = val
end)

-- Hacks Específicos & Evasão do Seer
criarFrameConfig("Auto-Esconder do Seer", "Desativado", ftfScroll, function(btn)
	AutoHideFromSeer = not AutoHideFromSeer
	btn.Text = AutoHideFromSeer and "Ativado" or "Desativado"
	btn.BackgroundColor3 = AutoHideFromSeer and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

criarFrameConfig("Retornar ao PC Após Seer", "Desativado", ftfScroll, function(btn)
	ReturnFromHideSeer = not ReturnFromHideSeer
	btn.Text = ReturnFromHideSeer and "Ativado" or "Desativado"
	btn.BackgroundColor3 = ReturnFromHideSeer and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

criarFrameConfig("Destravar Queda (Anti-Ragdoll)", "Desativado", ftfScroll, function(btn)
	RagdollMovement = not RagdollMovement
	btn.Text = RagdollMovement and "Ativado" or "Desativado"
	btn.BackgroundColor3 = RagdollMovement and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

criarFrameConfig("Esconder se a Fera Estiver Perto", "Desativado", ftfScroll, function(btn)
	HideBeastNear = not HideBeastNear
	btn.Text = HideBeastNear and "Ativado" or "Desativado"
	btn.BackgroundColor3 = HideBeastNear and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

criarFrameInput("Distância de Detecção Fera:", HideBeastNearDist, ftfScroll, function(val)
	HideBeastNearDist = val
end)

criarFrameConfig("Auto-Hack (Nunca Errar)", "Desativado", ftfScroll, function(btn)
	AntiPCError = not AntiPCError
	btn.Text = AntiPCError and "Ativado" or "Desativado"
	btn.BackgroundColor3 = AntiPCError and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

criarFrameConfig("Acelerar Codificação (Crawl Hack)", "Desativado", ftfScroll, function(btn)
	SpeedHackCrawlActive = not SpeedHackCrawlActive
	btn.Text = SpeedHackCrawlActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = SpeedHackCrawlActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

ftfLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	ftfScroll.CanvasSize = UDim2.new(0, 0, 0, ftfLayout.AbsoluteContentSize.Y + 15)
end)

-- ==========================================
-- CONTEÚDO DA ABA: VISUAL (ESPS & RAY-X)
-- ==========================================
local visualScroll = Instance.new("ScrollingFrame")
visualScroll.Size = UDim2.new(1, 0, 1, 0)
visualScroll.BackgroundTransparency = 1
visualScroll.BorderSizePixel = 0
visualScroll.ScrollBarThickness = 4
visualScroll.ScrollBarImageColor3 = Color3.fromRGB(130, 50, 200)
visualScroll.Parent = visualPage

local visualLayout = Instance.new("UIListLayout")
visualLayout.Padding = UDim.new(0, 6)
visualLayout.Parent = visualScroll

criarFrameConfig("Chams de Jogadores (Koala)", "Desativado", visualScroll, function(btn)
	local state = (btn.Text == "Desativado")
	btn.Text = state and "Ativado" or "Desativado"
	btn.BackgroundColor3 = state and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	UpdatePlrESP(state)
end)

criarFrameConfig("Chams de Fera (Koala)", "Desativado", visualScroll, function(btn)
	local state = (btn.Text == "Desativado")
	btn.Text = state and "Ativado" or "Desativado"
	btn.BackgroundColor3 = state and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	UpdateBeastESP(state)
end)

criarFrameConfig("ESP de Computadores Dinâmico", "Desativado", visualScroll, function(btn)
	ComputerTableESPActive = not ComputerTableESPActive
	btn.Text = ComputerTableESPActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = ComputerTableESPActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	atualizarComputerTableESP()
end)

criarFrameConfig("ESP de Células (FreezePods)", "Desativado", visualScroll, function(btn)
	FreezePodESPActive = not FreezePodESPActive
	btn.Text = FreezePodESPActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = FreezePodESPActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	atualizarFreezePodESP()
end)

criarFrameConfig("ESP de Armários (Lockers)", "Desativado", visualScroll, function(btn)
	lockerESPActive = not lockerESPActive
	btn.Text = lockerESPActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = lockerESPActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	updateLockerESP()
end)

criarFrameConfig("ESP de Ventilações (Dutos)", "Desativado", visualScroll, function(btn)
	ventESPActive = not ventESPActive
	btn.Text = ventESPActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = ventESPActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	updateVentESP()
end)

criarFrameConfig("ESP de Portas e Saídas", "Desativado", visualScroll, function(btn)
	ftfVisualsActive = not ftfVisualsActive
	btn.Text = ftfVisualsActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = ftfVisualsActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	applyFTFHighlight("ExitDoor", Color3.fromRGB(255, 255, 0))
	applyFTFHighlight("AirVent", Color3.fromRGB(100, 100, 100))
end)

criarFrameConfig("ESP de Itens Soltos", "Desativado", visualScroll, function(btn)
	itemEspActive = not itemEspActive
	btn.Text = itemEspActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = itemEspActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if itemEspActive then aplicarItemESP(descendant) else
			if descendant:IsA("BillboardGui") and descendant.Name == "ItemESP_Tag" then descendant:Destroy() end
		end
	end
end)

criarFrameConfig("Brilho Máximo (Fullbright)", "Desativado", visualScroll, function(btn)
	FullbrightActive = not FullbrightActive
	if FullbrightActive then
		btn.Text = "Ativado"
		btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
		Lighting.GlobalShadows = false
	else
		btn.Text = "Desativado"
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		Lighting.Ambient = originalAmbient
		Lighting.OutdoorAmbient = originalOutdoor
		Lighting.GlobalShadows = originalShadows
	end
end)

visualLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	visualScroll.CanvasSize = UDim2.new(0, 0, 0, visualLayout.AbsoluteContentSize.Y + 10)
end)

-- ==========================================
-- CONTEÚDO DA ABA: TROLL & SOUNDS
-- ==========================================
local trollScroll = Instance.new("ScrollingFrame")
trollScroll.Size = UDim2.new(1, 0, 1, 0)
trollScroll.BackgroundTransparency = 1
trollScroll.BorderSizePixel = 0
trollScroll.ScrollBarThickness = 4
trollScroll.ScrollBarImageColor3 = Color3.fromRGB(130, 50, 200)
trollScroll.Parent = trollPage

local trollLayout = Instance.new("UIListLayout")
trollLayout.Padding = UDim.new(0, 6)
trollLayout.Parent = trollScroll

criarFrameConfig("Desacelerar Fera (Glitch)", "Desativado", trollScroll, function(btn)
	SlowBeast = not SlowBeast
	btn.Text = SlowBeast and "Ativado" or "Desativado"
	btn.BackgroundColor3 = SlowBeast and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

criarFrameConfig("Soltar Todos da Corda", "Desativado", trollScroll, function(btn)
	UnTieAll = not UnTieAll
	btn.Text = UnTieAll and "Ativado" or "Desativado"
	btn.BackgroundColor3 = UnTieAll and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

criarFrameConfig("Auto-Soltar Minha Corda", "Desativado", trollScroll, function(btn)
	UnTieMe = not UnTieMe
	btn.Text = UnTieMe and "Ativado" or "Desativado"
	btn.BackgroundColor3 = UnTieMe and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

criarFrameConfig("Fling na Fera", "Executar", trollScroll, function()
	if not PU then setStatus("Erro: Biblioteca física não carregada.") return end
	for _, v in ipairs(Players:GetPlayers()) do
		if v:FindFirstChild("TempPlayerStatsModule") and v.TempPlayerStatsModule:FindFirstChild("IsBeast") and v.TempPlayerStatsModule.IsBeast.Value == true and v ~= LocalPlayer then
			local success, result = pcall(function() return PU:FlingPlayer(v) end)
			if success then setStatus("Tentando fling na fera...") else setStatus("Falha ao processar física.") end
			return
		end
	end
	setStatus("Nenhuma fera encontrada.")
end)

-- Sistema de SPAM do Soundboard
criarFrameConfig("Spam: Som de Acerto", "Desativado", trollScroll, function(btn)
	STSpamCorrect = not STSpamCorrect
	btn.Text = STSpamCorrect and "Ativado" or "Desativado"
	btn.BackgroundColor3 = STSpamCorrect and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

criarFrameConfig("Spam: Som de Alerta", "Desativado", trollScroll, function(btn)
	STSpamWarning = not STSpamWarning
	btn.Text = STSpamWarning and "Ativado" or "Desativado"
	btn.BackgroundColor3 = STSpamWarning and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

criarFrameConfig("Spam: Sirene de Saída", "Desativado", trollScroll, function(btn)
	STSpamExitsUnlock = not STSpamExitsUnlock
	btn.Text = STSpamExitsUnlock and "Ativado" or "Desativado"
	btn.BackgroundColor3 = STSpamExitsUnlock and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

trollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	trollScroll.CanvasSize = UDim2.new(0, 0, 0, trollLayout.AbsoluteContentSize.Y + 10)
end)

-- ==========================================
-- CONTEÚDO DA ABA: UTILITÁRIOS
-- ==========================================
local utilsScroll = Instance.new("ScrollingFrame")
utilsScroll.Size = UDim2.new(1, 0, 1, 0)
utilsScroll.BackgroundTransparency = 1
utilsScroll.BorderSizePixel = 0
utilsScroll.ScrollBarThickness = 4
utilsScroll.ScrollBarImageColor3 = Color3.fromRGB(130, 50, 200)
utilsScroll.Parent = utilsPage

local utilsLayout = Instance.new("UIListLayout")
utilsLayout.Padding = UDim.new(0, 6)
utilsLayout.Parent = utilsScroll

criarFrameConfig("Evitar Desconexão (Anti-AFK)", "Desativado", utilsScroll, function(btn)
	antiAfkActive = not antiAfkActive
	if antiAfkActive then
		btn.Text = "Ativado"
		btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		antiAfkConnection = LocalPlayer.Idled:Connect(function()
			local VirtualUser = game:GetService("VirtualUser")
			VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			task.wait(0.5)
			VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		end)
	else
		btn.Text = "Desativado"
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		if antiAfkConnection then
			antiAfkConnection:Disconnect()
			antiAfkConnection = nil
		end
	end
end)

criarFrameConfig("Sair se Moderador Entrar", "Desativado", utilsScroll, function(btn)
	KickOnModerator = not KickOnModerator
	btn.Text = KickOnModerator and "Ativado" or "Desativado"
	btn.BackgroundColor3 = KickOnModerator and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

criarFrameConfig("Alerta Se Moderador Entrar", "Desativado", utilsScroll, function(btn)
	AlertModerator = not AlertModerator
	btn.Text = AlertModerator and "Ativado" or "Desativado"
	btn.BackgroundColor3 = AlertModerator and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

criarFrameConfig("Reentrar no Servidor (Rejoin)", "Executar", utilsScroll, function()
	if #Players:GetPlayers() <= 1 then
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	else
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end
end)

criarFrameConfig("Aumentar Hitbox (Como Fera)", "Executar", utilsScroll, function()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Torso") then
			p.Character.Torso.Size = Vector3.new(6, 6, 6)
			p.Character.Torso.CanCollide = false
		end
	end
	setStatus("Tamanho das Hitboxes de alvos expandido.")
end)

utilsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	utilsScroll.CanvasSize = UDim2.new(0, 0, 0, utilsLayout.AbsoluteContentSize.Y + 10)
end)

-- ==========================================
-- CONTEÚDO DA ABA: INSPETOR DE BLOCOS (REAL-TIME DEBUG)
-- ==========================================
local insScroll = Instance.new("ScrollingFrame")
insScroll.Size = UDim2.new(1, 0, 1, 0)
insScroll.BackgroundTransparency = 1
insScroll.BorderSizePixel = 0
insScroll.ScrollBarThickness = 4
insScroll.ScrollBarImageColor3 = Color3.fromRGB(130, 50, 200)
insScroll.Parent = inspectorPage

local insLayout = Instance.new("UIListLayout")
insLayout.Padding = UDim.new(0, 6)
insLayout.Parent = insScroll

local function criarLinhaInfo(label, valorInicial)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, -10, 0, 26)
	f.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
	f.BorderSizePixel = 0
	f.Parent = insScroll

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 4)
	c.Parent = f

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0.4, 0, 1, 0)
	l.Position = UDim2.new(0, 8, 0, 0)
	l.BackgroundTransparency = 1
	l.Text = label .. ":"
	l.TextColor3 = Color3.fromRGB(130, 50, 200)
	l.Font = Enum.Font.GothamBold
	l.TextSize = 10
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = f

	local v = Instance.new("TextBox")
	v.Size = UDim2.new(0.55, 0, 1, 0)
	v.Position = UDim2.new(0.4, 0, 0, 0)
	v.BackgroundTransparency = 1
	v.Text = valorInicial
	v.TextColor3 = Color3.fromRGB(220, 220, 220)
	v.Font = Enum.Font.Gotham
	v.TextSize = 10
	v.TextXAlignment = Enum.TextXAlignment.Right
	v.ClearTextOnFocus = false
	v.TextEditable = false
	v.Parent = f

	return v
end

local iStatus = criarLinhaInfo("Status do Inspetor [F4]", "DESATIVADO")
local iNome = criarLinhaInfo("Nome", "---")
local iClasse = criarLinhaInfo("Classe", "---")
local iDist = criarLinhaInfo("Distância", "0m")
local iPos = criarLinhaInfo("Posição", "---")
local iFPS = criarLinhaInfo("Performance", "---")
local iPing = criarLinhaInfo("Latência", "0ms")

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(1, -10, 0, 30)
copyBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
copyBtn.Text = "Copiar Caminho do Objeto"
copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 11
copyBtn.Parent = insScroll

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 5)
copyCorner.Parent = copyBtn

copyBtn.MouseButton1Click:Connect(function()
	if SelectedInstance and setclipboard then
		setclipboard(SelectedInstance:GetFullName())
		setStatus("Caminho copiado para a área de transferência!")
	end
end)

local function ResetHighlight()
	if SelectedInstance then
		if SelectedInstance:IsA("BasePart") and OriginalColor then
			SelectedInstance.Color = OriginalColor
		end
		HighlightEffect.Parent = nil
	end
end

insLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	insScroll.CanvasSize = UDim2.new(0, 0, 0, insLayout.AbsoluteContentSize.Y + 15)
end)

-- ==========================================
-- SCRIPT DE AUTO FARM (LOGICA PORTADA DO KOALA)
-- ==========================================

function DoSurvivorFarm()
	if onsurvivorfarm then return end
	
	local function PlayerReady()
		if not TempPlayerStatsModule or TempPlayerStatsModule.IsBeast.Value or TempPlayerStatsModule.Health.Value <= 0 or not IsThereChar() then
			return false
		end
		return true
	end

	local function TaskGood()
		local status = game.ReplicatedStorage:FindFirstChild("GameStatus")
		if not status or string.find(string.lower(status.Value), "game over") or string.find(string.lower(status.Value), "intermission") or not PlayerReady() then
			return false
		end
		return true
	end

	local function GetMapObjects()
		local Result = { Computers = {}, FreezePods = {}, ExitDoors = {} }
		local currentMap = game.ReplicatedStorage:FindFirstChild("CurrentMap")
		if currentMap and currentMap.Value then
			for _, v in ipairs(currentMap.Value:GetChildren()) do
				if v.Name == "ComputerTable" then
					table.insert(Result.Computers, v)
				elseif v.Name == "FreezePod" then
					table.insert(Result.FreezePods, v)
				elseif v.Name == "ExitDoor" then
					table.insert(Result.ExitDoors, v)
				end
			end
		end
		return Result
	end

	local MapObjects = GetMapObjects()
	local IsFreeing = false
	local HadSaved = false
	local GoTween
	local CheckingPods = false

	local function FreeAllPods(ToGo)
		if CheckingPods then return end
		CheckingPods = true
		for _, v in ipairs(MapObjects.FreezePods) do
			if TaskGood() and v:FindFirstChild("PodTrigger") and v.PodTrigger.ActionSign.Value == 31 and (not FreezePodOnce or not HadSaved) then
				IsFreeing = true
				GoTween(v.PodTrigger, true, TeleportToFreezePod)
				repeat
					task.wait()
					if not bnhide and v:FindFirstChild("PodTrigger") and IsThereChar() then
						LocalPlayer.Character:PivotTo(v.PodTrigger.CFrame)
						game.ReplicatedStorage.RemoteEvent:FireServer("Input", "Trigger", true, v.PodTrigger.Event)
						game.ReplicatedStorage.RemoteEvent:FireServer("Input", "Action", true)
					end
				until not v:FindFirstChild("PodTrigger") or v.PodTrigger.ActionSign.Value ~= 31 or bnhideelapse >= CampFreezePodOut
				
				if bnhideelapse >= CampFreezePodOut and IsThereChar() then
					lpos = LocalPlayer.Character:GetPivot()
				end
				if v:FindFirstChild("PodTrigger") and v.PodTrigger.ActionSign.Value ~= 31 then
					HadSaved = true
				end
				if ToGo then
					GoTween(ToGo, true, TeleportToFreezePod)
				end
				IsFreeing = false
			end
		end
		CheckingPods = false
	end

	GoTween = function(Part, IsPod, TeleportInstead, TeleportDelay)
		if not TeleportInstead and IsThereChar() then
			local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Part.Position).Magnitude
			local NewTween = TweenService:Create(
				LocalPlayer.Character.HumanoidRootPart,
				TweenInfo.new(Distance / FarmTweenSpeed, Enum.EasingStyle.Linear),
				{ CFrame = Part.CFrame }
			)
			NewTween:Play()

			repeat
				task.wait()
				if bnhide and IsThereChar() then
					NewTween:Pause()
					lpos = LocalPlayer.Character.HumanoidRootPart.CFrame
				elseif NewTween.PlaybackState == Enum.PlaybackState.Paused then
					NewTween:Play()
				end

				if bnhideelapse >= CampTweenAnimOut then
					lpos = Part.CFrame
					bnhideelapse = 0
					NewTween:Cancel()
				elseif not TaskGood() then
					NewTween:Cancel()
				elseif not IsFreeing and not IsPod and not CheckingPods then
					task.spawn(function() FreeAllPods(Part) end)
				elseif IsFreeing and not IsPod then
					NewTween:Cancel()
				end
			until NewTween.PlaybackState == Enum.PlaybackState.Completed or NewTween.PlaybackState == Enum.PlaybackState.Cancelled
		end
		if TeleportDelay and TeleportInstead and IsThereChar() then
			task.wait(TeleportDelay)
		end
		if IsThereChar() then
			LocalPlayer.Character:PivotTo(Part.CFrame)
		end
	end

	local OnComputer = false
	local ChosenComputer = nil
	local ComputerBanList = {}
	local CurrentComputer = nil
	local FirstPC = true
	local LastPC = nil

	local function GetComputer(Computer)
		if TaskGood() and Computer.Screen.BrickColor ~= BrickColor.new("Dark green") and not OnComputer then
			OnComputer = true
			local Triggers = {
				Computer:FindFirstChild("ComputerTrigger1"),
				Computer:FindFirstChild("ComputerTrigger2"),
				Computer:FindFirstChild("ComputerTrigger3"),
			}

			local hadteleported = false
			for _, v in ipairs(Triggers) do
				if v and TaskGood() and v.ActionSign.Value == 20 and Computer.Screen.BrickColor ~= BrickColor.new("Dark green") and ChosenComputer == Computer then
					local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude

					if (Distance / FarmTweenSpeed < WaitTweenFast) and not FirstPC and not TeleportInsteadTweenPCFarm and LastPC ~= Computer then
						task.wait(WaitTweenFast - (Distance / FarmTweenSpeed))
					end

					repeat task.wait() until not TaskGood() or bnhide == false or bnhideelapse >= CampHackOut
					if bnhideelapse >= CampHackOut and IsThereChar() then
						lpos = LocalPlayer.Character:GetPivot()
					end

					if hadteleported or FirstPC or LastPC == Computer then
						GoTween(v, nil, TeleportInsteadTweenPCFarm)
					else
						local GotDelay = WaitTweenFast
						if UseMinimalTeleport then
							local NewDelay = Distance / StudsPerDelay
							GotDelay = math.clamp(NewDelay, math.min(MinimumDuration, WaitTweenFast), WaitTweenFast)
						end
						GoTween(v, nil, TeleportInsteadTweenPCFarm, GotDelay)
					end
					hadteleported = true
					FirstPC = false
					LastPC = Computer

					if Computer.Screen.BrickColor == BrickColor.new("Dark green") then CurrentComputer = nil; OnComputer = false; return end
					if not TaskGood() then CurrentComputer = nil; OnComputer = false; return end

					local Tries = 0
					repeat
						task.wait()
						FreeAllPods(v)
						if TaskGood() and not bnhide and not IsFreeing and TempPlayerStatsModule.CurrentAnimation.Value ~= "Typing" and IsThereChar() then
							Tries = Tries + 1
							LocalPlayer.Character:PivotTo(v.CFrame)
							game.ReplicatedStorage.RemoteEvent:FireServer("Input", "Trigger", true, v.Event)
							game.ReplicatedStorage.RemoteEvent:FireServer("Input", "Action", true)
							task.wait(0.5)
						elseif TaskGood() and not bnhide and not IsFreeing then
							CurrentComputer = Computer
							Tries = 0
							if AutoHideHack and IsThereChar() then
								LocalPlayer.Character:PivotTo(v.CFrame * CFrame.new(0, 50, 0))
								game.ReplicatedStorage.RemoteEvent:FireServer("Input", "Trigger", true, v.Event)
								game.ReplicatedStorage.RemoteEvent:FireServer("Input", "Action", true)
							end
						end
						if bnhideelapse >= CampHackOut and not IsFreeing then
							ComputerBanList[math.floor(DateTime.now().UnixTimestampMillis)] = Computer
							if IsThereChar() then lpos = LocalPlayer.Character:GetPivot() end
							OnComputer = false
							CurrentComputer = nil
							bnhideelapse = 0
							return
						end
					until not TaskGood() or Computer.Screen.BrickColor == BrickColor.new("Dark green") or (ChosenComputer ~= Computer and ChosenComputer ~= nil)
					
					if TaskGood() and TeleportInsteadTweenPCFarm and IsThereChar() then
						game.ReplicatedStorage.RemoteEvent:FireServer("Input", "Trigger", false, v.Event)
						game.ReplicatedStorage.RemoteEvent:FireServer("Input", "Action", false)
						LocalPlayer.Character:PivotTo(v.CFrame * CFrame.new(0, 50, 0))
					end
				end
			end
			CurrentComputer = nil
			OnComputer = false
		end
	end

	local function Run()
		local CancelComputers = false
		local LeastTriggers = 4
		local Closest = math.huge
		local ComputersLeft = 0

		task.spawn(function()
			while TaskGood() do
				task.wait()
				ComputersLeft = 0
				LeastTriggers = 4
				Closest = math.huge

				for _, v in ipairs(MapObjects.Computers) do
					if v.Screen.BrickColor ~= BrickColor.new("Dark green") then
						ComputersLeft = ComputersLeft + 1
					end

					local FoundV = false
					for i2, v2 in pairs(ComputerBanList) do
						if v2 == v then FoundV = true end
					end

					if v.Screen.BrickColor ~= BrickColor.new("Dark green") and not FoundV and IsThereChar() then
						local Triggers = { v:FindFirstChild("ComputerTrigger3"), v:FindFirstChild("ComputerTrigger2"), v:FindFirstChild("ComputerTrigger1") }
						local Distance = (Triggers[1].Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
						local AmtTriggers = 3

						for _, v2 in ipairs(Triggers) do
							if v2 and v2.ActionSign.Value ~= 20 then AmtTriggers = AmtTriggers - 1 end
						end

						if ((AmtTriggers >= 1 or AmtTriggers == -1) and AmtTriggers <= LeastTriggers) then
							if AmtTriggers == LeastTriggers and Distance > Closest then continue end
							ChosenComputer = v
							LeastTriggers = AmtTriggers
							Closest = Distance
						end
					end
				end
			end
		end)

		repeat
			task.wait(0.5)
			if ChosenComputer and not OnComputer then
				GetComputer(ChosenComputer)
			elseif ComputersLeft < 1 then
				CancelComputers = true
			end
		until not TaskGood() or CancelComputers

		if not TaskGood() or ExitCancel then return end

		-- Escape Automático
		repeat
			task.wait()
			for _, v in ipairs(MapObjects.ExitDoors) do
				if not TaskGood() then continue end
				if v:FindFirstChild("ExitDoorTrigger") then
					GoTween(v.ExitDoorTrigger, nil, TeleportToExitDoor)
					repeat
						task.wait()
						if v:FindFirstChild("ExitDoorTrigger") and v.ExitDoorTrigger.ActionSign.Value ~= 0 and not bnhide and IsThereChar() then
							LocalPlayer.Character:PivotTo(v.ExitDoorTrigger.CFrame * CFrame.new(0, v.ExitDoorTrigger.Size.Y / 2, 0))
							game.ReplicatedStorage.RemoteEvent:FireServer("Input", "Trigger", true, v.ExitDoorTrigger.Event)
							game.ReplicatedStorage.RemoteEvent:FireServer("Input", "Action", true)
							task.wait(0.5)
						end
					until not TaskGood() or not v:FindFirstChild("ExitDoorTrigger") or bnhideelapse >= CampEscapeOut
				end
				if TaskGood() and IsThereChar() then
					task.wait(0.5)
					GoTween(v.ExitArea, nil, TeleportToExitDoor)
				end
			end
		until not TaskGood()
	end

	local NewFarmTask = coroutine.create(function()
		if PlayerReady() and not onsurvivorfarm then
			onsurvivorfarm = true
			local Success, Result = pcall(Run)
			if not Success then setStatus("Erro Farm: " .. tostring(Result)) end
			task.wait(1)
			TPPlayerSpawn()
			onsurvivorfarm = false
		end
	end)
	coroutine.resume(NewFarmTask)
end

function DoBeastFarm()
	if OnBeastFarm then return end
	
	local function IsTaskGood()
		local status = game.ReplicatedStorage:FindFirstChild("GameStatus")
		if not status or string.find(string.lower(status.Value), "game over") or string.find(string.lower(status.Value), "intermission") then
			return false
		end
		return true
	end

	local function LerpToPart(Part, Threshold, WaitUntilCompletion)
		if BeastInstantTP and IsThereChar() then
			LocalPlayer.Character:PivotTo(Part.CFrame)
			return
		end
		if not IsThereChar() then return end

		local LerpCompleted = false
		local Connection
		Connection = RunService.RenderStepped:Connect(function(dt)
			if not Part or not Part:IsDescendantOf(Workspace) or not IsTaskGood() or not IsThereChar() then
				LerpCompleted = true
				Connection:Disconnect()
				return
			end

			local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Part.Position).Magnitude
			if not LerpCompleted then
				local Direction = Part.Position - LocalPlayer.Character.HumanoidRootPart.Position
				local Alpha = Direction.Unit * math.min(BeastFarmTweenSpeed * dt, Distance)
				LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + Alpha
			end

			if Distance <= Threshold then
				LerpCompleted = true
				Connection:Disconnect()
			end
		end)

		if WaitUntilCompletion then
			repeat task.wait() until LerpCompleted
		end
	end

	local function Run()
		local currentMap = game.ReplicatedStorage:FindFirstChild("CurrentMap")
		if not currentMap or not currentMap.Value then return end

		while IsTaskGood() do
			task.wait(0.5)
			for _, v in ipairs(Players:GetPlayers()) do
				if v ~= LocalPlayer and v:FindFirstChild("TempPlayerStatsModule") and v.TempPlayerStatsModule.Health.Value > 0 and IsThereChar(v) and IsThereChar() then
					LerpToPart(v.Character.HumanoidRootPart, BeastThreshold, true)
					repeat
						task.wait()
						if IsThereChar(v) and IsThereChar() then
							LocalPlayer.Character:PivotTo(v.Character.HumanoidRootPart.CFrame)
							if LocalPlayer.Character:FindFirstChild("Hammer") then
								LocalPlayer.Character.Hammer.HammerEvent:FireServer("HammerHit", v.Character.Torso)
							end
						end
					until not IsThereChar(v) or v.TempPlayerStatsModule.Ragdoll.Value == true
				end
			end
		end
	end

	if IsThereChar() and TempPlayerStatsModule and TempPlayerStatsModule.IsBeast.Value then
		local NewFarmTask = coroutine.create(function()
			OnBeastFarm = true
			pcall(Run)
			task.wait(2)
			TPPlayerSpawn()
			OnBeastFarm = false
		end)
		coroutine.resume(NewFarmTask)
	end
end

-- ==========================================
-- LOOP PRINCIPAL E SINK DE CONFIGURAÇÕES (UPDATE TICK)
-- ==========================================

RunService.RenderStepped:Connect(function()
	local now = tick()
	local timePassed = now - lastIteration
	lastIteration = now
	table.insert(frameHistory, 1, timePassed)
	if #frameHistory > 60 then table.remove(frameHistory) end
	local avgTime = 0
	for _, t in pairs(frameHistory) do avgTime = avgTime + t end
	fps = math.floor(1 / (avgTime / #frameHistory))
	iFPS.Text = tostring(fps) .. " FPS"

	local ping = tonumber(string.format("%.0f", LocalPlayer:GetNetworkPing() * 1000))
	iPing.Text = ping .. " ms"

	-- Sistema do Inspetor
	if InspectorActive then
		iStatus.Text = "ESCANEANDO..."
		iStatus.TextColor3 = Color3.fromRGB(50, 255, 100)
		local target = Mouse.Target
		if target then
			if target ~= SelectedInstance then
				ResetHighlight()
				SelectedInstance = target
				if target:IsA("BasePart") then
					OriginalColor = target.Color
					target.Color = Color3.fromRGB(0, 100, 255)
				end
				HighlightEffect.Parent = target
			end
			iNome.Text = target.Name
			iClasse.Text = target.ClassName
			if target:IsA("BasePart") then
				iPos.Text = string.format("%.1f, %.1f, %.1f", target.Position.X, target.Position.Y, target.Position.Z)
				local _, rootPart = GetCharacter()
				if rootPart then
					iDist.Text = math.floor((target.Position - rootPart.Position).Magnitude) .. "m"
				end
			end
		end
	else
		iStatus.Text = "DESATIVADO"
		iStatus.TextColor3 = Color3.fromRGB(255, 50, 50)
	end

	-- Lógica de Monitoramento das Tags de Personagem
	if IsThereChar() then
		TempPlayerStatsModule = LocalPlayer:FindFirstChild("TempPlayerStatsModule")
		if TempPlayerStatsModule then
			-- Anti-Fail Hack (Sempre acertar os minigames)
			if AntiPCError then
				ReplicatedStorage.RemoteEvent:FireServer("SetPlayerMinigameResult", true)
			end
			-- Anti-Ragdoll
			if RagdollMovement and TempPlayerStatsModule:FindFirstChild("Ragdoll") then
				TempPlayerStatsModule.Ragdoll.Value = false
			end
			-- Forçar Terceira Pessoa na Fera
			if Beast3rdPerson and TempPlayerStatsModule.IsBeast.Value then
				LocalPlayer.CameraMode = Enum.CameraMode.Classic
			end
		end
	end

	-- Evasão de Seer
	local screenGuiObj = PlayerGui:FindFirstChild("ScreenGui")
	local warningFrame = screenGuiObj and screenGuiObj:FindFirstChild("WarningFrame")
	if warningFrame and warningFrame.Visible and AutoHideFromSeer and IsThereChar() then
		if not HadSeerHide then
			HadSeerHide = true
			local _, root = GetCharacter()
			LastSeerHidePos = root.CFrame
			local ClosestLocker
			local ClosestDistance = math.huge
			for _, locker in ipairs(CollectionService:GetTagged("LOCKER")) do
				if locker:IsA("Model") then
					local dist = (locker:GetPivot().Position - root.Position).Magnitude
					if dist < ClosestDistance then
						ClosestLocker = locker
						ClosestDistance = dist
					end
				end
			end
			if ClosestLocker then
				LocalPlayer.Character:PivotTo(ClosestLocker:GetPivot())
			end
		end
	elseif LastSeerHidePos and HadSeerHide and IsThereChar() then
		HadSeerHide = false
		if ReturnFromHideSeer then
			LocalPlayer.Character:PivotTo(LastSeerHidePos)
		end
		LastSeerHidePos = nil
	end
end)

-- Loop de Spam do Soundboard
task.spawn(function()
	while true do
		task.wait(math.clamp(1 - (STSpamPercentage / 100), 0.05, 1))
		if STSpamCorrect then SoundService.CorrectSound:Play() end
		if STSpamWarning then SoundService.WarningSound:Play() end
		if STSpamExitsUnlock and ReplicatedStorage:FindFirstChild("CurrentMap") and ReplicatedStorage.CurrentMap.Value then
			local map = ReplicatedStorage.CurrentMap.Value
			if map:FindFirstChild("FacilitySiren") and map.FacilitySiren:FindFirstChild("SoundExitsUnlock") then
				map.FacilitySiren.SoundExitsUnlock:Play()
			end
		end
	end
end)

-- Loop Crawl Hack (Acelerar Hack de Computador)
task.spawn(function()
	while true do
		task.wait(HackCrawlDelay)
		if SpeedHackCrawlActive and IsThereChar() and TempPlayerStatsModule then
			local anim = TempPlayerStatsModule:FindFirstChild("CurrentAnimation")
			if anim and anim.Value == "Typing" then
				local crawlAsset = ReplicatedStorage:FindFirstChild("Animations") and ReplicatedStorage.Animations:FindFirstChild("AnimCrawl")
				local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if crawlAsset and humanoid then
					local animTrack = humanoid:LoadAnimation(crawlAsset)
					ReplicatedStorage.RemoteEvent:FireServer("Input", "Crawl", true)
					humanoid.HipHeight = -2
					animTrack:Play(0.1, 1, 0)
					task.wait(HackCrawlTime)
					ReplicatedStorage.RemoteEvent:FireServer("Input", "Crawl", false)
					humanoid.HipHeight = 0
					animTrack:Stop()
				end
			end
		end
	end
end)

-- ==========================================
-- GERENCIADOR DE TECLAS DE ATALHO (HOTKEYS)
-- ==========================================
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.P then
		toggleFly()
	elseif input.KeyCode == Enum.KeyCode.N then
		toggleNoclip()
	elseif input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt then
		toggleMouseUnlock()
	elseif input.KeyCode == inspectorKey then
		InspectorActive = not InspectorActive
		if not InspectorActive then ResetHighlight() end
		setStatus("Inspetor: " .. (InspectorActive and "ATIVADO" or "DESATIVADO"))
	end
end)
