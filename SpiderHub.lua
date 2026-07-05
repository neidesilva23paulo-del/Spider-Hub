--[[
    ================================================================
                       SPIDER HUB - FTF EDITION (V2.2)
    ================================================================
    Painel de controle com tratamento estrito de escopo e conexões.
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
-- PRÉ-DECLARAÇÃO DE UPVALUES (CONTROLE DE ESCOPO)
-- ==========================================
local setStatus
local GetCharacter
local obterCorPeloNome
local IsThereChar
local TPPlayerSpawn
local aplicarComputerESP
local atualizarComputerTableESP
local aplicarFreezePodESP
local atualizarFreezePodESP
local aplicarItemESP
local atualizarExitESP
local atualizarLockerESP
local atualizarVentESP
local atualizarPlrESP
local atualizarBeastESP
local colorirPersonagem
local monitorarJogador
local toggleChams
local toggleFly
local toggleNoclip
local toggleMouseUnlock
local criarTag
local applyFTFHighlight
local DoSurvivorFarm
local DoBeastFarm
local createTab
local criarFrameConfig
local criarSliderConfig

-- Referências aos botões de alternância da UI (Atribuídos na criação)
local flyBtn, noclipBtn, chamsBtn, compEspBtn, freezeEspBtn, exitEspBtn, lockerEspBtn, ventEspBtn

-- ==========================================
-- DECLARAÇÃO EXPLÍCITA DE ESTADOS LOCAIS
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

-- Velocidade e Pulo (WalkSpeed/JumpPower)
local speedHackEnabled = false
local speedHackValue = 16
local jumpHackEnabled = false
local jumpHackValue = 36
local infiniteJumpActive = false -- Consistência de caixa aplicada

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
local nameTagsActive = false
local ftfVisualsActive = false

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

-- Tabelas para rastreamento físico de ESPs
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

-- Estados dos Utilitários e Preservação de Valores Originais (Bypass de nil)
local FullbrightActive = false
local originalAmbient = Lighting.Ambient
local originalOutdoor = Lighting.OutdoorAmbient
local originalShadows = Lighting.GlobalShadows

local noFogActive = false
local originalFogStart = Lighting.FogStart
local originalFogEnd = Lighting.FogEnd
local originalAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

local xrayActive = false
local originalTransparencies = {} -- Tabela explicitamente definida

local antiVoidActive = false
local lastSafeCFrame = CFrame.new(0, 50, 0)

-- Controle de Conexões de Eventos (Prevenção de vazamento de memória)
local flyConnection = nil
local jumpConnection = nil
local pcProgConnection = nil
local doorEspConnection = nil
local ragdollConnection = nil
local sprintConnection = nil
local releaseConnection = nil
local glideConnection = nil
local antiVoidConnection = nil
local mouseUnlockConnection = nil

-- ==========================================
-- RESOLUÇÃO DO ESCUPO DE FUNÇÕES COMPLEMENTARES
-- ==========================================

GetCharacter = function()
	local character = LocalPlayer.Character
	if not character then return nil, nil, nil end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	return character, rootPart, humanoid
end

obterCorPeloNome = function(username)
	local hash = 0
	for i = 1, #username do 
		hash = hash + string.byte(username, i) 
	end
	return Color3.fromHSV((hash % 100) / 100, 0.9, 1)
end

IsThereChar = function(APlr)
	local plr = APlr or LocalPlayer
	if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
		return true
	end
	return false
end

TPPlayerSpawn = function()
	local character, _, _ = GetCharacter()
	if character then
		local spawnPad = Workspace:FindFirstChild("LobbySpawnPad")
		if spawnPad then
			character:PivotTo(spawnPad.CFrame * CFrame.new(0, 3, 0))
		end
	end
end

-- ==========================================
-- COMPONENTES VISUAIS E CONFIGURAÇÕES DE ESP
-- ==========================================

aplicarComputerESP = function(model)
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

atualizarComputerTableESP = function()
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

aplicarFreezePodESP = function(descendant)
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

atualizarFreezePodESP = function()
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

aplicarItemESP = function(item)
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

atualizarExitESP = function()
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

atualizarLockerESP = function()
	for _, v in ipairs(LockerHighlights) do pcall(function() v:Destroy() end) end
	table.clear(LockerHighlights)

	if LockerESPActive then
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

atualizarVentESP = function()
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

atualizarBeastESP = function()
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

atualizarPlrESP = function()
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

colorirPersonagem = function(character, targetPlayer)
	if not character or not targetPlayer or targetPlayer == LocalPlayer or not ChamsActive then return end
	
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

monitorarJogador = function(targetPlayer)
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

toggleChams = function()
	ChamsActive = not ChamsActive
	if ChamsActive then
		if chamsBtn then
			chamsBtn.Text = "Ativado"
			chamsBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
			chamsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
		setStatus("Chams Ativados.")
		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			if otherPlayer.Character then colorirPersonagem(otherPlayer.Character, otherPlayer) end
		end
	else
		if chamsBtn then
			chamsBtn.Text = "Desativado"
			chamsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			chamsBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
		setStatus("Chams Desativados.")
		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			if otherPlayer.Character then
				local hl = otherPlayer.Character:FindFirstChild("ColorChamsHighlight")
				if hl then hl:Destroy() end
			end
		end
	end
end

criarTag = function(player)
	if player == LocalPlayer or not player.Character then return end
	local head = player.Character:WaitForChild("Head", 5)
	if not head or head:FindFirstChild("SpiderNameTag") then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "SpiderNameTag"
	billboard.Size = UDim2.new(0, 100, 0, 40)
	billboard.AlwaysOnTop = true
	billboard.ExtentsOffset = Vector3.new(0, 2.5, 0)

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(150, 80, 255)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 10
	textLabel.TextStrokeTransparency = 0.5
	textLabel.Parent = billboard

	billboard.Parent = head

	task.spawn(function()
		while nameTagsActive and billboard and billboard.Parent do
			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local _, myRoot, _ = GetCharacter()
			local targetRoot = char and char:FindFirstChild("HumanoidRootPart")

			if hum and myRoot and targetRoot then
				local dist = math.round((myRoot.Position - targetRoot.Position).Magnitude)
				textLabel.Text = string.format("%s\nHP: %d | Dist: %dm", player.DisplayName, hum.Health, dist)
			end
			task.wait(0.2)
		end
		billboard:Destroy()
	end)
end

applyFTFHighlight = function(name, color)
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

-- ==========================================
-- SINAL E LOGICA DE CONTROLE DE MOVIMENTACAO (DEFINIÇÃO)
-- ==========================================

toggleMouseUnlock = function()
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

updateFlyPhysics = function()
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

toggleFly = function(btn)
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

		if flyConnection then
			flyConnection:Disconnect()
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

toggleNoclip = function(btn)
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

-- ==========================================
-- GESTÃO DE INTELIGÊNCIA ARTIFICIAL: ENGINE DE AUTO-FARM (DEFINIÇÃO)
-- ==========================================

DoSurvivorFarm = function()
	local function PlayerReady()
		local stats = LocalPlayer:FindFirstChild("TempPlayerStatsModule")
		if not stats or stats.IsBeast.Value or stats.Health.Value <= 0 or not IsThereChar() then
			return false
		end
		return true
	end

	local function TaskGood()
		local isGameActiveVal = false
		pcall(function()
			isGameActiveVal = ReplicatedStorage.IsGameActive.Value
		end)
		if string.find(string.lower(ReplicatedStorage.GameStatus.Value), "game over") or string.find(string.lower(ReplicatedStorage.GameStatus.Value), "intermission") or not PlayerReady() or not isGameActiveVal then
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
				local hackedAll = true
				for _, comp in ipairs(objects.Computers) do
					if comp:FindFirstChild("Screen") and comp.Screen.BrickColor ~= BrickColor.new("Dark green") then
						hackedAll = false
						local trigger = comp:FindFirstChild("ComputerTrigger1") or comp:FindFirstChild("ComputerTrigger2") or comp:FindFirstChild("ComputerTrigger3")
						if trigger then
							rootPart.CFrame = trigger.CFrame
							task.wait(1)
							
							repeat
								task.wait(0.2)
								if RemoteEvent then
									pcall(function()
										RemoteEvent:FireServer("Input", "Trigger", true, trigger.Event)
										RemoteEvent:FireServer("Input", "Action", true)
									end)
								end
							until comp.Screen.BrickColor == BrickColor.new("Dark green") or not survivorAutoFarmActive or not TaskGood()
						end
					end
				end

				if hackedAll and not exitCancelActive then
					for _, exit in ipairs(objects.ExitDoors) do
						local trigger = exit:FindFirstChild("ExitDoorTrigger")
						if trigger then
							rootPart.CFrame = trigger.CFrame
							task.wait(1)
							repeat
								task.wait(0.2)
								if RemoteEvent then
									pcall(function()
										RemoteEvent:FireServer("Input", "Trigger", true, trigger.Event)
										RemoteEvent:FireServer("Input", "Action", true)
									end)
								end
							until not exit:FindFirstChild("ExitDoorTrigger") or not survivorAutoFarmActive or not TaskGood()
						else
							local area = exit:FindFirstChild("ExitArea")
							if area then
								rootPart.CFrame = area.CFrame
								task.wait(2)
							end
						end
					end
				end
			end
			task.wait(1)
		end
		onsurvivorfarm = false
	end)
end

DoBeastFarm = function()
	local function IsTaskGood()
		local isGameActiveVal = false
		pcall(function()
			isGameActiveVal = ReplicatedStorage.IsGameActive.Value
		end)
		if string.find(string.lower(ReplicatedStorage.GameStatus.Value), "game over") or string.find(string.lower(ReplicatedStorage.GameStatus.Value), "intermission") or not beastAutoFarmActive or not isGameActiveVal then
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
						local isBeast = stats and stats:FindFirstChild("IsBeast") and stats.IsBeast.Value == true
						if stats and stats.Health.Value > 0 and stats.Captured.Value == false and not isBeast and stats.Ragdoll.Value == false then
							rootPart.CFrame = p.Character.Torso.CFrame
							task.wait(0.2)

							local hammer = character:FindFirstChild("Hammer")
							if hammer and hammer:FindFirstChild("HammerEvent") then
								pcall(function()
									hammer.HammerEvent:FireServer("HammerHit", p.Character.Torso)
								end)
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

-- ==========================================
-- SISTEMA DE INTERFACE GRÁFICA (CONSTRUTOR)
-- ==========================================

createTab = function(tabName)
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

criarFrameConfig = function(titulo, textoBotao, paginaAlvo, callback)
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

criarSliderConfig = function(titulo, desc, min, max, padrao, paginaAlvo, callback)
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
