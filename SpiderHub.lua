--[[
    ================================================================
                       SPIDER HUB - FTF EDITION (V2.0)
    ================================================================
    Aplicação unificada com foco exclusivo em Flee The Facility.
    Integração total do motor do Koala Scripts (v4) e ferramentas de automação.
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

-- Destruir versão antiga se já existir para evitar duplicidade
if PlayerGui:FindFirstChild("SpiderHubGui") then
	PlayerGui.SpiderHubGui:Destroy()
end

-- Instanciação segura do RemoteEvent do jogo
local RemoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvent")
if not RemoteEvent then
	task.spawn(function()
		RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent", 10)
	end)
end

-- ==========================================
-- ESTADOS DO SISTEMA E CONFIGURAÇÃO
-- ==========================================
local FlyActive = false
local FlySpeed = 50
local NoclipActive = false
local ChamsActive = false
local ComputerTableESPActive = false
local FreezePodESPActive = false
local LockerESPActive = false
local VentESPActive = false
local ChamsNeon = true
local ChamsTransparency = 0.4

-- Velocidade e Pulo (Koala WalkSpeed/JumpPower)
local speedHackEnabled = false
local speedHackValue = 16
local jumpHackEnabled = false
local jumpHackValue = 36
local infiniteJumpActive = false

-- Estados do Flee The Facility (Survivor & Beast Mods)
local autoHackActive = false
local speedHackCrawlActive = false
local autoHideFromSeerActive = false
local lastSeerHidePos = nil
local hadSeerHide = false
local antiPcErrorActive = false
local beast3rdPersonActive = false
local slowBeastActive = false
local unTieEveryoneActive = false
local unTieMeActive = false
local beastTieRangeValue = 0

-- ESPs Avançados (Koala Scripts)
local showPlrRagTimeActive = false
local exitDoorESPActive = false

-- Configurações de Auto-Farm (Survivor & Beast)
local survivorAutoFarmActive = false
local beastAutoFarmActive = false
local keepComputerActive = false
local autoHideHackActive = false
local useMinimalTeleportActive = true
local teleportInsteadTweenPCFarmActive = false
local teleportToFreezePodActive = false
local teleportToExitDoorActive = false
local freezePodOnceActive = true
local exitCancelActive = false
local waitForSaveActive = false
local waitSaveDelayValue = 0
local farmTweenSpeedValue = 16
local waitTweenFastValue = 12
local minimumDurationValue = 5
local studsPerDelayValue = 16
local triggerPrioritizationValue = 1
local campHackOutValue = 40
local campFreezePodOutValue = 40
local campEscapeOutValue = 40
local hackBanUnbanTimeValue = 5
local triggerUnCampOutValue = 5
local hideBeastNearDistValue = 25

-- Variáveis de controle de farms
local onsurvivorfarm = false
local OnBeastFarm = false
local farmtasks = {}
local pcProgressTracker = {}
local lpos = nil
local bnhide = false
local bnhideelapse = 0
local noelepse = 0

-- Variáveis do Inspetor
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

-- Controle de FPS/Ping
local lastIteration = tick()
local frameHistory = {}
local fps = 0

-- Tabelas de Armazenamento de UI
local tabs = {}
local tabButtons = {}

-- Tabelas para rastreamento físico de ESPs (Koala Highlight garbage collector)
local BeastHighlights = {}
local PlrHighlights = {}
local PlrRagTimeBillboards = {}
local ExitDoorHighlights = {}
local PodHighlights = {}
local LockerHighlights = {}
local VentHighlights = {}

-- Estatísticas de Gravação
local StatsConfig = {
	Recording = false,
	StartMoney = 0,
	StartXP = 0,
	Elapsed = 0
}

-- ==========================================
-- SISTEMA REPLETO DE FUNÇÕES AUXILIARES / GETTERS
-- ==========================================

-- Retorna referências do Personagem atualizado de forma dinâmica
local function GetCharacter()
	local character = LocalPlayer.Character
	if not character then return nil, nil, nil end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	return character, rootPart, humanoid
end

-- Gera uma cor exclusiva com base no nome de usuário do jogador
local function obterCorPeloNome(username)
	local hash = 0
	for i = 1, #username do 
		hash = hash + string.byte(username, i) 
	end
	return Color3.fromHSV((hash % 100) / 100, 0.9, 1)
end

-- Retorna se o personagem está carregado e vivo
local function IsThereChar(APlr)
	local plr = APlr or LocalPlayer
	if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
		return true
	end
	return false
end

-- Teleporta para a zona neutra do Spawn do Lobby
local function TPPlayerSpawn()
	local character, _, _ = GetCharacter()
	if character then
		local spawnPad = Workspace:FindFirstChild("LobbySpawnPad")
		if spawnPad then
			character:PivotTo(spawnPad.CFrame * CFrame.new(0, 3, 0))
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
mainFrame.Size = UDim2.new(0, 560, 0, 360)
mainFrame.Position = UDim2.new(0.5, -280, 0.5, -180)
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
	title.Text = "🕷️ SPIDER HUB - FTF EDITION"
	title.TextColor3 = Color3.fromRGB(240, 240, 250)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = topBar
end

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 140, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

do
	local sidebarCorner = Instance.new("UICorner")
	sidebarCorner.CornerRadius = UDim.new(0, 10)
	sidebarCorner.Parent = sidebar

	local sidebarLayout = Instance.new("UIListLayout")
	sidebarLayout.Padding = UDim.new(0, 5)
	sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	sidebarLayout.Parent = sidebar

	local sidebarPadding = Instance.new("UIPadding")
	sidebarPadding.PaddingTop = UDim.new(0, 10)
	sidebarPadding.Parent = sidebar
end

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -150, 1, -50)
contentContainer.Position = UDim2.new(0, 145, 0, 45)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

local statusBar = Instance.new("TextLabel")
statusBar.Size = UDim2.new(1, -10, 0, 20)
statusBar.Position = UDim2.new(0, 5, 1, -25)
statusBar.BackgroundTransparency = 1
statusBar.Text = "Sistema inicializado com sucesso."
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

-- Minimizar Painel
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
local originalSize = UDim2.new(0, 560, 0, 360)
local minimizedSize = UDim2.new(0, 560, 0, 40)

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

-- Gerenciador de Abas Dinâmico
local function createTab(tabName)
	local page = Instance.new("Frame")
	page.Size = UDim2.new(1, 0, 1, -20)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = contentContainer

	tabs[tabName] = page

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
	btn.BackgroundTransparency = 1
	btn.Text = "   " .. tabName
	btn.TextColor3 = Color3.fromRGB(160, 160, 170)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 11
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.BorderSizePixel = 0
	btn.Parent = sidebar

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn

	local activeIndicator = Instance.new("Frame")
	activeIndicator.Size = UDim2.new(0, 3, 0.5, 0)
	activeIndicator.Position = UDim2.new(0, 4, 0.25, 0)
	activeIndicator.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
	activeIndicator.BorderSizePixel = 0
	activeIndicator.BackgroundTransparency = 1
	activeIndicator.Parent = btn

	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(0, 2)
	indicatorCorner.Parent = activeIndicator

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
				if indicator then
					TweenService:Create(indicator, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
				end
			else
				TweenService:Create(currentBtn, TweenInfo.new(0.1), {BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(24, 24, 30), TextColor3 = Color3.fromRGB(160, 160, 170)}):Play()
				if indicator then
					TweenService:Create(indicator, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
				end
			end
		end
	end)

	return page
end

-- Função Auxiliar para Criar Cards de Configurações
local function criarFrameConfig(titulo, textoBotao, paginaAlvo, callback)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, -10, 0, 42)
	f.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	f.BorderSizePixel = 0
	f.Parent = paginaAlvo

	local fCorner = Instance.new("UICorner")
	fCorner.CornerRadius = UDim.new(0, 6)
	fCorner.Parent = f

	local fStroke = Instance.new("UIStroke")
	fStroke.Color = Color3.fromRGB(32, 32, 40)
	fStroke.Thickness = 1
	fStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	fStroke.Parent = f

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = titulo
	label.TextColor3 = Color3.fromRGB(235, 235, 240)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = f

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.26, 0, 0.65, 0)
	btn.Position = UDim2.new(0.7, 0, 0.175, 0)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	btn.Text = textoBotao
	btn.TextColor3 = Color3.fromRGB(180, 180, 190)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 10
	btn.BorderSizePixel = 0
	btn.Parent = f

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 5)
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
		if btn then
			local isEnabled = (btn.Text == "Ativado") or (btn.Text == "Ativa") or (btn.Text == "Ativada")
			local targetBg = isEnabled and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
			local targetTx = isEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)
			local targetStroke = isEnabled and Color3.fromRGB(150, 70, 230) or Color3.fromRGB(45, 45, 55)

			TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = targetBg, TextColor3 = targetTx}):Play()
			TweenService:Create(btnStroke, TweenInfo.new(0.1), {Color = targetStroke}):Play()
		end
	end)

	btn.MouseButton1Click:Connect(function()
		callback(btn)
	end)

	return f
end

-- Função Auxiliar para criar Sliders personalizados
local function criarSliderConfig(titulo, desc, min, max, padrao, paginaAlvo, callback)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, -10, 0, 52)
	f.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	f.BorderSizePixel = 0
	f.Parent = paginaAlvo

	local fCorner = Instance.new("UICorner")
	fCorner.CornerRadius = UDim.new(0, 6)
	fCorner.Parent = f

	local fStroke = Instance.new("UIStroke")
	fStroke.Color = Color3.fromRGB(32, 32, 40)
	fStroke.Thickness = 1
	fStroke.Parent = f

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.5, 0, 0, 20)
	label.Position = UDim2.new(0, 12, 0, 4)
	label.BackgroundTransparency = 1
	label.Text = titulo
	label.TextColor3 = Color3.fromRGB(235, 235, 240)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = f

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(0.5, 0, 0, 20)
	descLabel.Position = UDim2.new(0, 12, 0, 24)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = desc
	descLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
	descLabel.Font = Enum.Font.SourceSans
	descLabel.TextSize = 11
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Parent = f

	local input = Instance.new("TextBox")
	input.Size = UDim2.new(0.2, 0, 0, 26)
	input.Position = UDim2.new(0.75, 0, 0.5, -13)
	input.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
	input.TextColor3 = Color3.fromRGB(255, 255, 255)
	input.Text = tostring(padrao)
	input.Font = Enum.Font.GothamBold
	input.TextSize = 11
	input.BorderSizePixel = 0
	input.Parent = f

	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = UDim.new(0, 4)
	inputCorner.Parent = input

	input.FocusLost:Connect(function(enterPressed)
		local val = tonumber(input.Text)
		if val then
			local clamped = math.clamp(val, min, max)
			input.Text = tostring(clamped)
			callback(clamped)
		else
			input.Text = tostring(padrao)
		end
	end)

	return f
end

-- ==========================================
-- GESTÃO DE SISTEMAS DE MOVIMENTO E FÍSICA
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
			
			local cam = Workspace.CurrentCamera
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
-- GESTÃO DO CORPO DE CHAMS E RASTREAMENTOS OTIMIZADOS
-- ==========================================

local function colorirPersonagem(character, targetPlayer)
	if not character or not targetPlayer or targetPlayer == LocalPlayer or not ChamsActive then return end
	
	-- Koala-style team color detection
	local stats = targetPlayer:FindFirstChild("TempPlayerStatsModule")
	local isBeast = stats and stats:FindFirstChild("IsBeast") and stats.IsBeast.Value == true
	local corDoJogador = isBeast and Color3.fromRGB(230, 50, 50) or Color3.fromRGB(50, 230, 50)

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

local function monitorarJogador(targetPlayer)
	if targetPlayer == LocalPlayer then return end
	local function noCharacterAdded(character)
		task.wait(0.1)
		if ChamsActive then colorirPersonagem(character, targetPlayer) end
		character.DescendantAdded:Connect(function(desc)
			if ChamsActive and desc:IsA("BasePart") then
				task.wait()
				local stats = targetPlayer:FindFirstChild("TempPlayerStatsModule")
				local isBeast = stats and stats:FindFirstChild("IsBeast") and stats.IsBeast.Value == true
				desc.Color = isBeast and Color3.fromRGB(230, 50, 50) or Color3.fromRGB(50, 230, 50)
				if ChamsNeon then desc.Material = Enum.Material.Neon end
			end
		end)
	end
	if targetPlayer.Character then task.spawn(noCharacterAdded, targetPlayer.Character) end
	targetPlayer.CharacterAdded:Connect(noCharacterAdded)
end

local function toggleChams()
	ChamsActive = not ChamsActive
	if ChamsActive then
		chamsBtn.Text = "Ativado"
		chamsBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		chamsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		setStatus("Chams Ativados.")
		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			if otherPlayer.Character then colorirPersonagem(otherPlayer.Character, otherPlayer) end
		end
	else
		chamsBtn.Text = "Desativado"
		chamsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		chamsBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		setStatus("Chams Desativados.")
		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			if otherPlayer.Character then
				local hl = otherPlayer.Character:FindFirstChild("ColorChamsHighlight")
				if hl then hl:Destroy() end
			end
		end
	end
end

-- ==========================================
-- GESTÃO DE RECURSOS KOALA SCRIPTS (ESPs COMPLETO)
-- ==========================================

local function atualizarBeastESP()
	for _, v in ipairs(BeastHighlights) do pcall(function() v:Destroy() end) end
	table.clear(BeastHighlights)
	
	if ChamsActive then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				local stats = p:FindFirstChild("TempPlayerStatsModule")
				if stats and stats:FindFirstChild("IsBeast") and stats.IsBeast.Value == true then
					local highlight = Instance.new("Highlight")
					highlight.Name = "KHHighlight"
					highlight.FillColor = Color3.fromRGB(200, 50, 50)
					highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
					highlight.Adornee = p.Character
					highlight.Parent = p.Character
					table.insert(BeastHighlights, highlight)
				end
			end
		end
	end
end

local function atualizarPlrESP()
	for _, v in ipairs(PlrHighlights) do pcall(function() v:Destroy() end) end
	table.clear(PlrHighlights)

	if ChamsActive then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				local stats = p:FindFirstChild("TempPlayerStatsModule")
				local isBeast = stats and stats:FindFirstChild("IsBeast") and stats.IsBeast.Value == true
				if not isBeast then
					local highlight = Instance.new("Highlight")
					highlight.Name = "KHHighlight"
					highlight.FillColor = Color3.fromRGB(0, 230, 0)
					highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
					highlight.Adornee = p.Character
					highlight.Parent = p.Character
					table.insert(PlrHighlights, highlight)
				end
			end
		end
	end
end

local function atualizarExitESP()
	for _, v in ipairs(ExitDoorHighlights) do pcall(function() v:Destroy() end) end
	table.clear(ExitDoorHighlights)

	local currentMap = ReplicatedStorage:FindFirstChild("CurrentMap")
	local mapValue = currentMap and currentMap.Value
	if exitDoorESPActive and mapValue then
		for _, v in ipairs(mapValue:GetChildren()) do
			if v.Name == "ExitDoor" then
				local highlight = Instance.new("Highlight")
				highlight.Name = "KHHighlight"
				highlight.FillColor = Color3.fromRGB(220, 220, 50)
				highlight.OutlineColor = Color3.fromRGB(255, 255, 100)
				highlight.Adornee = v
				highlight.Parent = v
				table.insert(ExitDoorHighlights, highlight)
			end
		end
	end
end

local function atualizarLockerESP()
	for _, v in ipairs(LockerHighlights) do pcall(function() v:Destroy() end) end
	table.clear(LockerHighlights)

	if lockerESPActive then
		for _, v in ipairs(CollectionService:GetTagged("LOCKER")) do
			local highlight = Instance.new("Highlight")
			highlight.Name = "KHHighlight"
			highlight.FillColor = Color3.fromRGB(210, 210, 0)
			highlight.FillTransparency = 0.75
			highlight.OutlineColor = Color3.fromRGB(230, 230, 0)
			highlight.OutlineTransparency = 0.25
			highlight.Adornee = v
			highlight.Parent = v
			table.insert(LockerHighlights, highlight)
		end
	end
end

local function atualizarVentESP()
	for _, v in ipairs(VentHighlights) do pcall(function() v:Destroy() end) end
	table.clear(VentHighlights)

	local currentMap = ReplicatedStorage:FindFirstChild("CurrentMap")
	local mapValue = currentMap and currentMap.Value
	if VentESPActive and mapValue then
		for _, v in ipairs(mapValue:GetDescendants()) do
			if v:IsA("BasePart") and string.find(string.lower(v.Name), "ventblock") then
				local function NewSUI(Face)
					local sui = Instance.new("SurfaceGui")
					sui.Name = "KHHighlight"
					sui.AlwaysOnTop = true
					sui.Face = Face
					sui.Adornee = v
					sui.Parent = v

					local f = Instance.new("Frame")
					f.BackgroundColor3 = Color3.fromRGB(255, 255, 200)
					f.BackgroundTransparency = 0.6
					f.Size = UDim2.new(1, 0, 1, 0)
					f.Parent = sui
				end
				NewSUI(Enum.NormalId.Front)
				NewSUI(Enum.NormalId.Back)
				NewSUI(Enum.NormalId.Left)
				NewSUI(Enum.NormalId.Right)
				NewSUI(Enum.NormalId.Top)
				NewSUI(Enum.NormalId.Bottom)
				table.insert(VentHighlights, v)
			end
		end
	end
end

-- ==========================================
-- CONSTRUTOR DE INTERFACE: ABAS PRINCIPAIS
-- ==========================================

-- ABA: INÍCIO (welcome & info)
-- [Já definida na seção principal]

-- ABA: MOVIMENTAÇÃO
local moveScroll = Instance.new("ScrollingFrame")
moveScroll.Size = UDim2.new(1, 0, 1, 0)
moveScroll.BackgroundTransparency = 1
moveScroll.BorderSizePixel = 0
moveScroll.ScrollBarThickness = 4
moveScroll.ScrollBarImageColor3 = Color3.fromRGB(130, 50, 200)
moveScroll.Parent = movePage

local moveLayout = Instance.new("UIListLayout")
moveLayout.Padding = UDim.new(0, 10)
moveLayout.Parent = moveScroll

-- WalkSpeed Slider & Toggle (Koala Style)
criarFrameConfig("Habilitar WalkSpeed Hack", "Desativado", moveScroll, function(btn)
	speedHackEnabled = not speedHackEnabled
	btn.Text = speedHackEnabled and "Ativado" or "Desativado"
	btn.BackgroundColor3 = speedHackEnabled and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	if not speedHackEnabled then
		local _, _, humanoid = GetCharacter()
		if humanoid then humanoid.WalkSpeed = 16 end
	end
end)
criarSliderConfig("Ajustar WalkSpeed", "Velocidade de movimento do jogador.", 16, 120, 16, moveScroll, function(val)
	speedHackValue = val
end)

-- JumpPower Slider & Toggle (Koala Style)
criarFrameConfig("Habilitar JumpPower Hack", "Desativado", moveScroll, function(btn)
	jumpHackEnabled = not jumpHackEnabled
	btn.Text = jumpHackEnabled and "Ativado" or "Desativado"
	btn.BackgroundColor3 = jumpHackEnabled and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	if not jumpHackEnabled then
		local _, _, humanoid = GetCharacter()
		if humanoid then humanoid.JumpPower = 36 end
	end
end)
criarSliderConfig("Ajustar JumpPower", "Força do pulo do jogador.", 36, 250, 36, moveScroll, function(val)
	jumpHackValue = val
end)

-- Jump Infinito (Infinite Jump)
criarFrameConfig("Pulo Infinito", "Desativado", moveScroll, function(btn)
	infiniteJumpActive = not infiniteJumpActive
	btn.Text = infiniteJumpActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = infiniteJumpActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

UserInputService.JumpRequest:Connect(function()
	if infiniteJumpActive then
		local _, _, humanoid = GetCharacter()
		if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

-- Elementos de voo e noclip legados
local flyFrame = Instance.new("Frame")
flyFrame.Size = UDim2.new(1, -10, 0, 45)
flyFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
flyFrame.BorderSizePixel = 0
flyFrame.Parent = moveScroll

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 6)
flyCorner.Parent = flyFrame

local flyLabel = Instance.new("TextLabel")
flyLabel.Size = UDim2.new(0.6, 0, 1, 0)
flyLabel.Position = UDim2.new(0, 12, 0, 0)
flyLabel.BackgroundTransparency = 1
flyLabel.Text = "Habilitar Vôo (Fly) [P]"
flyLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
flyLabel.Font = Enum.Font.GothamBold
flyLabel.TextSize = 12
flyLabel.TextXAlignment = Enum.TextXAlignment.Left
flyLabel.Parent = flyFrame

local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0.3, 0, 0.7, 0)
flyBtn.Position = UDim2.new(0.65, 0, 0.15, 0)
flyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
flyBtn.Text = "Desativado"
flyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
flyBtn.Font = Enum.Font.GothamMedium
flyBtn.TextSize = 11
flyBtn.BorderSizePixel = 0
flyBtn.Parent = flyFrame

local flyBtnCorner = Instance.new("UICorner")
flyBtnCorner.CornerRadius = UDim.new(0, 5)
flyBtnCorner.Parent = flyBtn

flyBtn.MouseButton1Click:Connect(function() toggleFly(flyBtn) end)

local noclipFrame = Instance.new("Frame")
noclipFrame.Size = UDim2.new(1, -10, 0, 45)
noclipFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
noclipFrame.BorderSizePixel = 0
noclipFrame.Parent = moveScroll

local noclipCorner = Instance.new("UICorner")
noclipCorner.CornerRadius = UDim.new(0, 6)
noclipCorner.Parent = noclipFrame

local noclipLabel = Instance.new("TextLabel")
noclipLabel.Size = UDim2.new(0.6, 0, 1, 0)
noclipLabel.Position = UDim2.new(0, 12, 0, 0)
noclipLabel.BackgroundTransparency = 1
noclipLabel.Text = "Ativar Noclip [N]"
noclipLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
noclipLabel.Font = Enum.Font.GothamBold
noclipLabel.TextSize = 12
noclipLabel.TextXAlignment = Enum.TextXAlignment.Left
noclipLabel.Parent = noclipFrame

local noclipBtn = Instance.new("TextButton")
noclipBtn.Size = UDim2.new(0.3, 0, 0.7, 0)
noclipBtn.Position = UDim2.new(0.65, 0, 0.15, 0)
noclipBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
noclipBtn.Text = "Desativado"
noclipBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
noclipBtn.Font = Enum.Font.GothamMedium
noclipBtn.TextSize = 11
noclipBtn.BorderSizePixel = 0
noclipBtn.Parent = noclipFrame

local noclipBtnCorner = Instance.new("UICorner")
noclipBtnCorner.CornerRadius = UDim.new(0, 5)
noclipBtnCorner.Parent = noclipBtn

noclipBtn.MouseButton1Click:Connect(function() toggleNoclip(noclipBtn) end)

moveLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	moveScroll.CanvasSize = UDim2.new(0, 0, 0, moveLayout.AbsoluteContentSize.Y + 15)
end)

-- ABA: JOGADORES (Teleporte & Spectate)
-- [Configurada dinamicamente na seção original de jogadores]

-- ABA: VISUAL (Chams, ESPs e Modificadores Gráficos)
-- Integramos aqui todas as opções avançadas de ESP do Koala Scripts
criarFrameConfig("ESP Computadores Dinâmico", "Desativado", visualScroll, function(btn)
	ComputerTableESPActive = not ComputerTableESPActive
	btn.Text = ComputerTableESPActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = ComputerTableESPActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	atualizarComputerTableESP()
end)

criarFrameConfig("ESP Portas de Saída", "Desativado", visualScroll, function(btn)
	exitDoorESPActive = not exitDoorESPActive
	btn.Text = exitDoorESPActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = exitDoorESPActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	atualizarExitESP()
end)

criarFrameConfig("ESP Armários (Lockers)", "Desativado", visualScroll, function(btn)
	lockerESPActive = not lockerESPActive
	btn.Text = lockerESPActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = lockerESPActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	atualizarLockerESP()
end)

criarFrameConfig("ESP Tubulações (Vents)", "Desativado", visualScroll, function(btn)
	VentESPActive = not VentESPActive
	btn.Text = VentESPActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = VentESPActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	atualizarVentESP()
end)

criarFrameConfig("Mostrar Progresso Ragdoll de Caídos", "Desativado", visualScroll, function(btn)
	showPlrRagTimeActive = not showPlrRagTimeActive
	btn.Text = showPlrRagTimeActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = showPlrRagTimeActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

-- ESP de Fera/Player Unificados com Chams
criarFrameConfig("ESP Sobreviventes (Verde)", "Desativado", visualScroll, function(btn)
	ChamsActive = not ChamsActive
	btn.Text = ChamsActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = ChamsActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	atualizarPlrESP()
	atualizarBeastESP()
end)

-- ABA: FLEE THE FACILITY
-- Onde residem o Survivor/Beast Auto-Farm e as opções de aceleração

-- 1. Auto-Hack (Sem falhar minigame)
criarFrameConfig("Nunca Errar Hack (Auto-Hack)", "Desativado", ftfScroll, function(btn)
	autoHackActive = not autoHackActive
	btn.Text = autoHackActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = autoHackActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

-- 2. Crawl Exploit
criarFrameConfig("Acelerar Codificação [Q]", "Desativado", ftfScroll, function(btn)
	speedHackCrawlActive = not speedHackCrawlActive
	btn.Text = speedHackCrawlActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = speedHackCrawlActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

-- 3. Auto-Flop
local autoFlopActive = false
criarFrameConfig("Auto-Flop (Bugar Captura)", "Desativado", ftfScroll, function(btn)
	autoFlopActive = not autoFlopActive
	btn.Text = autoFlopActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = autoFlopActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

-- 4. Locker Auto-Hide (Seer)
criarFrameConfig("Auto-Esconder do Seer", "Desativado", ftfScroll, function(btn)
	autoHideFromSeerActive = not autoHideFromSeerActive
	btn.Text = autoHideFromSeerActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = autoHideFromSeerActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

-- 5. Soltar Amarras Automático
criarFrameConfig("Auto-Soltar Amarras Fera", "Desativado", ftfScroll, function(btn)
	unTieMeActive = not unTieMeActive
	btn.Text = unTieMeActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = unTieMeActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

-- 6. Terceira Pessoa Fera (Beast 3rd Person)
criarFrameConfig("Fera em 3ª Pessoa", "Desativado", ftfScroll, function(btn)
	beast3rdPersonActive = not beast3rdPersonActive
	btn.Text = beast3rdPersonActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = beast3rdPersonActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	if not beast3rdPersonActive then
		local stats = LocalPlayer:FindFirstChild("TempPlayerStatsModule")
		if stats and stats:FindFirstChild("IsBeast") and stats.IsBeast.Value == true then
			LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
		end
	end
end)

-- 7. Survivor Auto-Farm (Estilo Koala)
criarFrameConfig("Sobrevivente Auto-Farm", "Desativado", ftfScroll, function(btn)
	survivorAutoFarmActive = not survivorAutoFarmActive
	btn.Text = survivorAutoFarmActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = survivorAutoFarmActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	if survivorAutoFarmActive then
		DoSurvivorFarm()
	end
end)

-- 8. Beast Auto-Farm (Estilo Koala)
criarFrameConfig("Fera Auto-Farm", "Desativado", ftfScroll, function(btn)
	beastAutoFarmActive = not beastAutoFarmActive
	btn.Text = beastAutoFarmActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = beastAutoFarmActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	if beastAutoFarmActive then
		DoBeastFarm()
	end
end)

-- Sliders do Engine de Auto Farm
criarSliderConfig("Beast Camp Timeout (PC)", "Tempo limite em segundos.", 20, 60, 40, ftfScroll, function(val) campHackOutValue = val end)
criarSliderConfig("Beast Camp Timeout (Pods)", "Tempo limite em segundos.", 20, 60, 40, ftfScroll, function(val) campFreezePodOutValue = val end)
criarSliderConfig("Tween Speed (Survivor)", "Velocidade em blocos/s.", 10, 30, 16, ftfScroll, function(val) farmTweenSpeedValue = val end)
criarSliderConfig("Delay de Teleporte (Anti-Cheat)", "Segurança contra detecção.", 5, 20, 12, ftfScroll, function(val) waitTweenFastValue = val end)

-- ==========================================
-- ABA: TROLL ( Sound Board, Piggyback, Slow, Fling )
-- ==========================================
local trollPage = createTab("Trolling")
local trollScroll = Instance.new("ScrollingFrame")
trollScroll.Size = UDim2.new(1, 0, 1, 0)
trollScroll.BackgroundTransparency = 1
trollScroll.BorderSizePixel = 0
trollScroll.ScrollBarThickness = 4
trollScroll.ScrollBarImageColor3 = Color3.fromRGB(130, 50, 200)
trollScroll.Parent = trollPage

local trollLayout = Instance.new("UIListLayout")
trollLayout.Padding = UDim.new(0, 10)
trollLayout.Parent = trollScroll

-- Lentidão na Fera (Jumped loop exploit)
criarFrameConfig("Lentidão Extrema na Fera", "Desativado", trollScroll, function(btn)
	slowBeastActive = not slowBeastActive
	btn.Text = slowBeastActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = slowBeastActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

-- Libertar Todos (Hammer click exploit)
criarFrameConfig("Auto-Soltar Todos (Hammer Exploit)", "Desativado", trollScroll, function(btn)
	unTieEveryoneActive = not unTieEveryoneActive
	btn.Text = unTieEveryoneActive and "Ativado" or "Desativado"
	btn.BackgroundColor3 = unTieEveryoneActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
end)

-- Arremessar Fera (Fling Beast)
criarFrameConfig("Arremessar Fera (Fling Beast)", "Executar", trollScroll, function()
	local character, rootPart, _ = GetCharacter()
	if not character or not rootPart then 
		setStatus("Personagem indisponível.")
		return 
	end
	
	local targetBeast = nil
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local stats = p:FindFirstChild("TempPlayerStatsModule")
			if stats and stats:FindFirstChild("IsBeast") and stats.IsBeast.Value == true then
				targetBeast = p
				break
			end
		end
	end

	if targetBeast and targetBeast.Character and targetBeast.Character:FindFirstChild("HumanoidRootPart") then
		local bRoot = targetBeast.Character.HumanoidRootPart
		setStatus("Flinging " .. targetBeast.DisplayName)
		
		-- Loop rápido de empuxo físico usando AssemblyLinearVelocity
		local originalPos = rootPart.CFrame
		local t = tick()
		while tick() - t < 1.5 do
			RunService.Heartbeat:Wait()
			rootPart.CFrame = bRoot.CFrame * CFrame.new(0,0,0.5)
			rootPart.AssemblyLinearVelocity = Vector3.new(0, 50000, 0)
			rootPart.AssemblyAngularVelocity = Vector3.new(0, 50000, 0)
		end
		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.AssemblyAngularVelocity = Vector3.zero
		rootPart.CFrame = originalPos
		setStatus("Fling executado.")
	else
		setStatus("Fera não encontrada ou inválida.")
	end
end)

-- Painel Sound board troll (Sons locais com replay instantâneo)
local soundHeader = Instance.new("TextLabel")
soundHeader.Size = UDim2.new(1, 0, 0, 25)
soundHeader.BackgroundTransparency = 1
soundHeader.Text = "🎵 SOUND BOARD TROLL (Spam e Play)"
soundHeader.TextColor3 = Color3.fromRGB(130, 50, 200)
soundHeader.Font = Enum.Font.GothamBold
soundHeader.TextSize = 12
soundHeader.TextXAlignment = Enum.TextXAlignment.Left
soundHeader.Parent = trollScroll

local function tocarSom(nomeSom)
	pcall(function()
		local som = SoundService:FindFirstChild(nomeSom, true) or ReplicatedStorage:FindFirstChild(nomeSom, true)
		if som and som:IsA("Sound") then
			som:Play()
			setStatus("Tocado: " .. nomeSom)
		else
			-- Tenta carregar os caminhos reais da estrutura interna do FTF
			local monitor = Workspace:FindFirstChild("ComputerTable", true)
			local screen = monitor and monitor:FindFirstChild("Screen")
			local errorSound = screen and screen:FindFirstChild("ErrorSound")
			if errorSound and nomeSom == "ErrorSound" then
				errorSound:Play()
				setStatus("Tocado: ErrorSound")
			end
		end
	end)
end

criarFrameConfig("Tocar Erro de Hack (ErrorSound)", "Executar", trollScroll, function() tocarSom("ErrorSound") end)
criarFrameConfig("Tocar Alarme de Saída (Siren)", "Executar", trollScroll, function() tocarSom("SoundExitsUnlock") end)
criarFrameConfig("Tocar Sinal Correto (CorrectSound)", "Executar", trollScroll, function() tocarSom("CorrectSound") end)
criarFrameConfig("Tocar Sinal de Alerta (WarningSound)", "Executar", trollScroll, function() tocarSom("WarningSound") end)

trollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	trollScroll.CanvasSize = UDim2.new(0, 0, 0, trollLayout.AbsoluteContentSize.Y + 20)
end)

-- ==========================================
-- GESTÃO DE LOOP DE EXECUÇÃO EM TEMPO REAL
-- ==========================================

RunService.Heartbeat:Connect(function(dt)
	-- 1. Loops de Velocidade e Pulo (Koala WalkSpeed/JumpPower)
	local character, _, humanoid = GetCharacter()
	if character and humanoid then
		if speedHackEnabled then
			humanoid.WalkSpeed = speedHackValue
		end
		if jumpHackEnabled then
			humanoid.JumpPower = jumpHackValue
		end
	end

	-- 2. Anti PC Error
	if antiPcErrorActive then
		if RemoteEvent then
			pcall(function()
				RemoteEvent:FireServer("SetPlayerMinigameResult", true)
			end)
		end
	end

	-- 3. Terceira Pessoa Fera (Beast 3rd Person camera mode lock bypass)
	if beast3rdPersonActive then
		local stats = LocalPlayer:FindFirstChild("TempPlayerStatsModule")
		if stats and stats:FindFirstChild("IsBeast") and stats.IsBeast.Value == true then
			LocalPlayer.CameraMinZoomDistance = 0.5
			LocalPlayer.CameraMode = Enum.CameraMode.Classic
		end
	end

	-- 4. Troll Lógica: Lerdeza na Fera (Jumped exploit)
	if slowBeastActive then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				local stats = p:FindFirstChild("TempPlayerStatsModule")
				if stats and stats:FindFirstChild("IsBeast") and stats.IsBeast.Value == true then
					local bPowers = p.Character:FindFirstChild("BeastPowers")
					local pEvt = bPowers and bPowers:FindFirstChild("PowersEvent")
					if pEvt then
						pEvt:FireServer("Jumped")
					end
				end
			end
		end
	end

	-- 5. Troll Lógica: Soltar Todos do Martelo (Hammer Exploit)
	if unTieEveryoneActive or unTieMeActive then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				local stats = p:FindFirstChild("TempPlayerStatsModule")
				if stats and stats:FindFirstChild("IsBeast") and stats.IsBeast.Value == true then
					local hammer = p.Character:FindFirstChild("Hammer")
					local hEvt = hammer and hammer:FindFirstChild("HammerEvent")
					if hEvt then
						if unTieEveryoneActive then
							hEvt:FireServer("HammerClick", true)
						end
						if unTieMeActive and character then
							for _, rope in ipairs(p.Character:GetDescendants()) do
								if rope:IsA("RopeConstraint") then
									if (rope.Attachment0 and rope.Attachment0:IsDescendantOf(character)) or (rope.Attachment1 and rope.Attachment1:IsDescendantOf(character)) then
										hEvt:FireServer("HammerClick", true)
									end
								end
							end
						end
					end
				end
			end
		end
	end

	-- 6. Atualização do Monitoramento de Estatísticas de Partida (Credits e XP)
	if StatsConfig.Recording then
		StatsConfig.Elapsed = StatsConfig.Elapsed + dt
		local statsFolder = LocalPlayer:FindFirstChild("SavedPlayerStatsModule")
		local currentXP = statsFolder and statsFolder:FindFirstChild("Xp") and statsFolder.Xp.Value
		local currentCredits = statsFolder and statsFolder:FindFirstChild("Credits") and statsFolder.Credits.Value

		if currentXP and currentCredits then
			local totalCredits = currentCredits - StatsConfig.StartMoney
			local totalXP = currentXP - StatsConfig.StartXP
			MoneyStats.Text = "Total Credits: " .. tostring(totalCredits) .. "C"
			XPStats.Text = "Total XP: " .. tostring(totalXP) .. "XP"
			MoneyStatsHour.Text = "Credits por Hora: " .. tostring(math.ceil(totalCredits / (StatsConfig.Elapsed / 3600))) .. "C/h"
			XPStatsHour.Text = "XP por Hora: " .. tostring(math.ceil(totalXP / (StatsConfig.Elapsed / 3600))) .. "XP/h"
			
			local hours = math.floor(StatsConfig.Elapsed / 3600)
			local minutes = math.floor((StatsConfig.Elapsed % 3600) / 60)
			local seconds = math.floor(StatsConfig.Elapsed % 60)
			RecordElapsed.Text = string.format("Tempo Decorrido: %d:%02d:%02d", hours, minutes, seconds)
		end
	end

	-- 7. ESP de Caídos (Downed RagTime)
	if showPlrRagTimeActive then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				local stats = p:FindFirstChild("TempPlayerStatsModule")
				local isDowned = stats and stats:FindFirstChild("Ragdoll") and stats.Ragdoll.Value == true
				local progress = stats and stats:FindFirstChild("ActionProgress")

				local billboard = p.Character:FindFirstChild("PlrRagTimeBillboard")

				if isDowned and progress then
					if not billboard then
						billboard = Instance.new("BillboardGui")
						billboard.Name = "PlrRagTimeBillboard"
						billboard.AlwaysOnTop = true
						billboard.Size = UDim2.new(0, 180, 0, 30)
						billboard.ExtentsOffsetWorldSpace = Vector3.new(0, 1.5, 0)

						local label = Instance.new("TextLabel")
						label.BackgroundTransparency = 1
						label.TextColor3 = Color3.fromRGB(255, 50, 50)
						label.Font = Enum.Font.GothamBold
						label.Size = UDim2.new(1, 0, 1, 0)
						label.TextScaled = true
						label.Parent = billboard

						billboard.Parent = p.Character
					end
					billboard.TextLabel.Text = string.format("%s | Caído: %d%%", p.DisplayName, math.floor(progress.Value * 100))
				elseif billboard then
					billboard:Destroy()
				end
			end
		end
	end
end)

-- ==========================================
-- SUB-SISTEMA UTILITÁRIO: GRAVAÇÃO DE SESSÃO
-- ==========================================
local statsScroll = Instance.new("ScrollingFrame")
statsScroll.Size = UDim2.new(1, 0, 1, 0)
statsScroll.BackgroundTransparency = 1
statsScroll.BorderSizePixel = 0
statsScroll.ScrollBarThickness = 4
statsScroll.ScrollBarImageColor3 = Color3.fromRGB(130, 50, 200)
statsScroll.Parent = utilsPage

local statsLayout = Instance.new("UIListLayout")
statsLayout.Padding = UDim.new(0, 10)
statsLayout.Parent = statsScroll

local function criarLabelStats(texto)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 0, 25)
	label.BackgroundTransparency = 1
	label.Text = texto
	label.TextColor3 = Color3.fromRGB(200, 200, 210)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = statsScroll
	return label
end

criarFrameConfig("Gravação de Estatísticas", "Iniciar", statsScroll, function(btn)
	if not StatsConfig.Recording then
		btn.Text = "Parar"
		btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
		
		local statsFolder = LocalPlayer:FindFirstChild("SavedPlayerStatsModule")
		StatsConfig.StartXP = statsFolder and statsFolder:FindFirstChild("Xp") and statsFolder.Xp.Value or 0
		StatsConfig.StartMoney = statsFolder and statsFolder:FindFirstChild("Credits") and statsFolder.Credits.Value or 0
		StatsConfig.Elapsed = 0
		StatsConfig.Recording = true
	else
		btn.Text = "Iniciar"
		btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		StatsConfig.Recording = false
	end
end)

RecordElapsed = criarLabelStats("Tempo Decorrido: 0:00:00")
MoneyStats = criarLabelStats("Total Credits: 0C")
XPStats = criarLabelStats("Total XP: 0XP")
MoneyStatsHour = criarLabelStats("Credits por Hora: 0C/h")
XPStatsHour = criarLabelStats("XP por Hora: 0XP/h")

statsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	statsScroll.CanvasSize = UDim2.new(0, 0, 0, statsLayout.AbsoluteContentSize.Y + 20)
end)

-- ==========================================
-- ARQUITETURA DE INTELIGÊNCIA ARTIFICIAL: AUTO-FARMS (SURVIVOR & BEAST)
-- ==========================================

-- 1. MOTOR DO SURVIVOR AUTO-FARM
function DoSurvivorFarm()
	local function PlayerReady()
		local stats = LocalPlayer:FindFirstChild("TempPlayerStatsModule")
		if not stats or stats.IsBeast.Value or stats.Health.Value <= 0 or not IsThereChar() then
			return false
		end
		return true
	end

	local function TaskGood()
		if string.find(string.lower(ReplicatedStorage.GameStatus.Value), "game over") or string.find(string.lower(ReplicatedStorage.GameStatus.Value), "intermission") or not PlayerReady() then
			return false
		end
		return true
	end

	local function GetMapObjects()
		local Result = {Computers = {}, FreezePods = {}, ExitDoors = {}}
		local currentMap = ReplicatedStorage:FindFirstChild("CurrentMap")
		local mapValue = currentMap and currentMap.Value

		if mapValue then
			for _, v in ipairs(mapValue:GetChildren()) do
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

	task.spawn(function()
		while survivorAutoFarmActive and TaskGood() do
			local objects = GetMapObjects()
			local character, rootPart, _ = GetCharacter()

			if character and rootPart then
				for _, comp in ipairs(objects.Computers) do
					if comp:FindFirstChild("Screen") and comp.Screen.BrickColor ~= BrickColor.new("Dark green") then
						-- Simula teletransporte gradual/instantâneo até o PC
						local trigger = comp:FindFirstChild("ComputerTrigger1") or comp:FindFirstChild("ComputerTrigger2")
						if trigger then
							rootPart.CFrame = trigger.CFrame
							task.wait(1)
							
							repeat
								task.wait(0.2)
								if RemoteEvent then
									RemoteEvent:FireServer("Input", "Trigger", true, trigger.Event)
									RemoteEvent:FireServer("Input", "Action", true)
								end
							until comp.Screen.BrickColor == BrickColor.new("Dark green") or not survivorAutoFarmActive or not TaskGood()
						end
					end
				end
			end
			task.wait(1)
		end
		onsurvivorfarm = false
	end)
end

-- 2. MOTOR DO BEAST AUTO-FARM
function DoBeastFarm()
	local function IsTaskGood()
		if string.find(string.lower(ReplicatedStorage.GameStatus.Value), "game over") or string.find(string.lower(ReplicatedStorage.GameStatus.Value), "intermission") or not beastAutoFarmActive then
			return false
		end
		return true
	end

	task.spawn(function()
		while beastAutoFarmActive and IsTaskGood() do
			local character, rootPart, _ = GetCharacter()
			if character and rootPart then
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Torso") then
						local stats = p:FindFirstChild("TempPlayerStatsModule")
						if stats and stats.Health.Value > 0 and stats.Captured.Value == false then
							-- Teleporta até a vítima
							rootPart.CFrame = p.Character.Torso.CFrame
							task.wait(0.2)

							-- Simula golpe com o Martelo
							local hammer = character:FindFirstChild("Hammer")
							if hammer and hammer:FindFirstChild("HammerEvent") then
								hammer.HammerEvent:FireServer("HammerHit", p.Character.Torso)
							end
							task.wait(1)
						end
					end
				end
			end
			task.wait(1)
		end
		OnBeastFarm = false
	end)
end
