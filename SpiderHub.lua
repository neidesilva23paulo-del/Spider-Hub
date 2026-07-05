--[[
    ================================================================
                           SPIDER HUB (V1.3)
    ================================================================
    Aplicação unificada com interface moderna, modular e responsiva.
]]

-- Serviços do Roblox
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ProximityPromptService = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Destruir versão antiga se já existir para evitar duplicidade
if PlayerGui:FindFirstChild("SpiderHubGui") then
	PlayerGui.SpiderHubGui:Destroy()
end

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
local insScroll, insLayout, modScroll, modLayout

-- Referências para o Fly e Conexões
local linVel, alignOri, flyConnection, jumpConnection
local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- ==========================================
-- CRIAÇÃO DA INTERFACE VISUAL (GUI)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpiderHubGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui


-- Janela Principal (Estilo Dark Minimalista, Ultra Limpo)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 560, 0, 360)
mainFrame.Position = UDim2.new(0.5, -280, 0.5, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18) -- Fundo escuro puro e sólido
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

do
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 8) -- Cantos nítidos de 8px
	mainCorner.Parent = mainFrame

	-- Borda roxa fina de pixel único (sem gradientes que embaçam)
	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Color3.fromRGB(130, 50, 200) -- Roxo brilhante
	mainStroke.Thickness = 1
	mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	mainStroke.Parent = mainFrame
end

-- Barra de Topo (Header)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

do
	local topCorner = Instance.new("UICorner")
	topCorner.CornerRadius = UDim.new(0, 10)
	topCorner.Parent = topBar

	-- Remover cantos inferiores do TopBar para estética
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
	title.Text = "🕷️ SPIDER HUB"
	title.TextColor3 = Color3.fromRGB(240, 240, 250)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = topBar
end

-- Sidebar de Navegação (Esquerda)
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

-- Container de Conteúdo (Direita)
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -150, 1, -50)
contentContainer.Position = UDim2.new(0, 145, 0, 45)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

-- Console / Feedback de Logs (Barra de Status inferior)
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

-- ==========================================
-- SISTEMA DE MINIMIZAR / RESTAURAR JANELA
-- ==========================================
local minBtn = Instance.new("TextButton")
minBtn.Name = "MinimizeButton"
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.AnchorPoint = Vector2.new(1, 0.5) -- Define a âncora no centro-direito do botão
minBtn.Position = UDim2.new(1, -12, 0.5, 0) -- Centraliza verticalmente e afasta 12px da direita
minBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(240, 240, 250)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.BorderSizePixel = 0
minBtn.ZIndex = 10 -- Força o botão a renderizar acima de qualquer máscara ou título
minBtn.Active = true
minBtn.Parent = topBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minBtn

local isMinimized = false
local originalSize = UDim2.new(0, 560, 0, 360)
local minimizedSize = UDim2.new(0, 560, 0, 40)

-- Efeitos visuais ao passar o mouse
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
		-- Oculta os elementos internos antes de redimensionar
		sidebar.Visible = false
		contentContainer.Visible = false
		statusBar.Visible = false

		-- Transição para encolher a janela
		TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = minimizedSize
		}):Play()
	else
		minBtn.Text = "-"
		-- Transição para expandir a janela
		local expandTween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = originalSize
		})
		expandTween:Play()

		-- Restaura os elementos internos após a expansão
		expandTween.Completed:Connect(function()
			if not isMinimized then
				sidebar.Visible = true
				contentContainer.Visible = true
				statusBar.Visible = true
			end
		end)
	end
end)

local function setStatus(msg)
	statusBar.Text = "LOG: " .. tostring(msg)
	task.spawn(function()
		statusBar.TextColor3 = Color3.fromRGB(130, 50, 200)
		task.wait(1.5)
		statusBar.TextColor3 = Color3.fromRGB(150, 150, 160)
	end)
end

-- ==========================================
-- GESTÃO DE ABAS
-- ==========================================
local tabs = {}
local tabButtons = {}

local function createTab(tabName)
	-- Voltamos para Frame padrão (evita que o texto fique embaçado ou bugado no Roblox)
	local page = Instance.new("Frame")
	page.Size = UDim2.new(1, 0, 1, -20)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = contentContainer

	tabs[tabName] = page

	-- Botão da Sidebar com design plano e limpo
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
	btn.BackgroundTransparency = 1 -- Invisível por padrão (flat)
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

	-- Indicador minimalista lateral esquerdo para a aba selecionada
	local activeIndicator = Instance.new("Frame")
	activeIndicator.Size = UDim2.new(0, 3, 0.5, 0)
	activeIndicator.Position = UDim2.new(0, 4, 0.25, 0)
	activeIndicator.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
	activeIndicator.BorderSizePixel = 0
	activeIndicator.BackgroundTransparency = 1 -- Invisível por padrão
	activeIndicator.Parent = btn

	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(0, 2)
	indicatorCorner.Parent = activeIndicator

	tabButtons[tabName] = btn

	-- Transições nítidas ao passar o mouse
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

-- Função Auxiliar para Criar Containers de Configurações
local function criarFrameConfig(titulo, textoBotao, paginaAlvo, callback)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, -10, 0, 42) -- Altura mais equilibrada e compacta
	f.BackgroundColor3 = Color3.fromRGB(22, 22, 28) -- Cinza de contraste nítido
	f.BorderSizePixel = 0
	f.Parent = paginaAlvo

	local fCorner = Instance.new("UICorner")
	fCorner.CornerRadius = UDim.new(0, 6)
	fCorner.Parent = f

	local fStroke = Instance.new("UIStroke")
	fStroke.Color = Color3.fromRGB(32, 32, 40) -- Borda interna muito sutil para relevo
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
			local isEnabled = (btn.Text == "Ativado")
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

-- Instanciação das Abas
local homePage = createTab("Início")
local movePage = createTab("Movimentação")
local playersPage = createTab("Jogadores")
local itemsPage = createTab("Itens")
local visualPage = createTab("Visual")
local ftfPage = createTab("Flee The Facility")

local ftfScroll = Instance.new("ScrollingFrame")
ftfScroll.Size = UDim2.new(1, 0, 1, 0)
ftfScroll.BackgroundTransparency = 1
ftfScroll.BorderSizePixel = 0
ftfScroll.ScrollBarThickness = 4
ftfScroll.ScrollBarImageColor3 = Color3.fromRGB(130, 50, 200)
ftfScroll.Parent = ftfPage

local ftfLayout = Instance.new("UIListLayout")
ftfLayout.Padding = UDim.new(0, 10)
ftfLayout.Parent = ftfScroll

ftfLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	ftfScroll.CanvasSize = UDim2.new(0, 0, 0, ftfLayout.AbsoluteContentSize.Y + 20)
end)

local utilsPage = createTab("Utilitários")
local combatPage = createTab("Guerra de Torres")

-- Ativar primeira aba por padrão
tabs["Início"].Visible = true
tabButtons["Início"].BackgroundColor3 = Color3.fromRGB(130, 50, 200)
tabButtons["Início"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- ==========================================
-- VARIÁVEIS DO INSPETOR E EXTRAS
-- ==========================================
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

-- ==========================================
-- CRIAÇÃO DAS ABAS (INSPETOR)
-- ==========================================
local inspectorPage = createTab("Inspetor")

-- ==========================================
-- UI DA ABA INSPETOR
-- ==========================================
do
	insScroll = Instance.new("ScrollingFrame")
	insScroll.Size = UDim2.new(1, 0, 1, 0)
	insScroll.BackgroundTransparency = 1
	insScroll.BorderSizePixel = 0
	insScroll.ScrollBarThickness = 4
	insScroll.ScrollBarImageColor3 = Color3.fromRGB(130, 50, 200)
	insScroll.Parent = inspectorPage

	insLayout = Instance.new("UIListLayout")
	insLayout.Padding = UDim.new(0, 8)
	insLayout.Parent = insScroll

	-- Função auxiliar para criar linhas de dados no Inspetor
	local function criarLinhaInfo(label, valorInicial)
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, -10, 0, 28)
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

	-- Campos da Interface
	local iStatus = criarLinhaInfo("Status do Inspetor [F4]", "DESATIVADO")
	local iNome = criarLinhaInfo("Nome", "---")
	local iClasse = criarLinhaInfo("Classe", "---")
	local iDist = criarLinhaInfo("Distância", "0m")
	local iPos = criarLinhaInfo("Posição", "---")
	local iTamanho = criarLinhaInfo("Tamanho", "---")
	local iFilhos = criarLinhaInfo("Filhos/Desc.", "0/0")
	local iFPS = criarLinhaInfo("Performance (FPS)", "60")
	local iPing = criarLinhaInfo("Latência (Ping)", "0ms")

	-- Botão de Copiar Caminho
	local copyBtn = Instance.new("TextButton")
	copyBtn.Size = UDim2.new(1, -10, 0, 30)
	copyBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
	copyBtn.Text = "Copiar Caminho Completo"
	copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	copyBtn.Font = Enum.Font.GothamBold
	copyBtn.TextSize = 11
	copyBtn.Parent = insScroll
	Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)

	copyBtn.MouseButton1Click:Connect(function()
		if SelectedInstance then
			local path = SelectedInstance:GetFullName()
			if setclipboard then
				setclipboard(path)
				setStatus("Caminho copiado para a área de transferência!")
			else
				iNome.Text = "ERRO: Sem suporte a clipboard"
			end
		end
	end)

	-- Botão de Deletar Instância Selecionada (Movido para cá)
	local delBtn = Instance.new("TextButton")
	delBtn.Size = UDim2.new(1, -10, 0, 30)
	delBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	delBtn.Text = "Deletar Objeto Selecionado"
	delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	delBtn.Font = Enum.Font.GothamBold
	delBtn.TextSize = 11
	delBtn.Parent = insScroll
	Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 6)

	delBtn.MouseButton1Click:Connect(function()
		if SelectedInstance then
			local n = SelectedInstance.Name
			SelectedInstance:Destroy()
			SelectedInstance = nil
			setStatus("Objeto " .. n .. " removido localmente.")
		else
			setStatus("Erro: Selecione um item usando o Inspetor [F4].")
		end
	end)

	-- ==========================================
	-- LÓGICA DO INSPETOR (REAL-TIME)
	-- ==========================================
	local function ResetHighlight()
		if SelectedInstance then
			if SelectedInstance:IsA("BasePart") and OriginalColor then
				SelectedInstance.Color = OriginalColor
			end
			HighlightEffect.Parent = nil
		end
	end

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

		if not InspectorActive then 
			iStatus.Text = "DESATIVADO"
			iStatus.TextColor3 = Color3.fromRGB(255, 50, 50)
			return 
		end

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
			iPos.Text = string.format("%.1f, %.1f, %.1f", target.Position.X, target.Position.Y, target.Position.Z)

			if target:IsA("BasePart") then
				iTamanho.Text = string.format("%.1f x %.1f x %.1f", target.Size.X, target.Size.Y, target.Size.Z)
				local dist = (target.Position - root.Position).Magnitude
				iDist.Text = math.floor(dist) .. "m"
			else
				iTamanho.Text = "N/A"
			end

			iFilhos.Text = #target:GetChildren() .. " / " .. #target:GetDescendants()
		else
			ResetHighlight()
			SelectedInstance = nil
		end
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == inspectorKey then
			InspectorActive = not InspectorActive
			if not InspectorActive then ResetHighlight() end
			setStatus("Inspetor: " .. (InspectorActive and "ATIVADO" or "DESATIVADO"))
		end
	end)

	insLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		insScroll.CanvasSize = UDim2.new(0, 0, 0, insLayout.AbsoluteContentSize.Y + 20)
	end)
end


-- ==========================================
-- CONTEÚDO DA ABA: INÍCIO
-- ==========================================
do
	local welcomeLabel = Instance.new("TextLabel")
	welcomeLabel.Size = UDim2.new(1, 0, 0, 40)
	welcomeLabel.BackgroundTransparency = 1
	welcomeLabel.Text = "Bem-vindo ao Spider Hub, " .. LocalPlayer.DisplayName .. "!"
	welcomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	welcomeLabel.Font = Enum.Font.GothamBold
	welcomeLabel.TextSize = 14
	welcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
	welcomeLabel.Parent = homePage

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, 0, 0, 120)
	descLabel.Position = UDim2.new(0, 0, 0, 40)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = "Este hub unifica suas ferramentas de movimentação, trapaça visual e teletransporte em um painel responsivo.\n\nAtalhos Rápidos:\n[P] Ativar/Desativar Voo (Fly)\n[N] Ativar/Desativar Noclip"
	descLabel.TextColor3 = Color3.fromRGB(170, 170, 180)
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 12
	descLabel.TextWrapped = true
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.Parent = homePage
end

-- ==========================================
-- CONTEÚDO DA ABA: MOVIMENTAÇÃO (ROLÁVEL)
-- ==========================================
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

moveLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	moveScroll.CanvasSize = UDim2.new(0, 0, 0, moveLayout.AbsoluteContentSize.Y + 15)
end)

-- Componente Fly Toggle
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

-- Controle de Velocidade do Fly
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, -10, 0, 45)
speedFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
speedFrame.BorderSizePixel = 0
speedFrame.Parent = moveScroll

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 6)
speedCorner.Parent = speedFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.5, 0, 1, 0)
speedLabel.Position = UDim2.new(0, 12, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Velocidade do Vôo:"
speedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 12
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedFrame

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.3, 0, 0.7, 0)
speedInput.Position = UDim2.new(0.65, 0, 0.15, 0)
speedInput.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Text = tostring(FlySpeed)
speedInput.Font = Enum.Font.GothamBold
speedInput.TextSize = 12
speedInput.BorderSizePixel = 0
speedInput.Parent = speedFrame

local speedInputCorner = Instance.new("UICorner")
speedInputCorner.CornerRadius = UDim.new(0, 5)
speedInputCorner.Parent = speedInput

-- Componente Noclip Toggle
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
noclipLabel.Text = "Ativar Noclip (Atravessar Paredes) [N]"
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



moveScroll.CanvasSize = UDim2.new(0, 0, 0, moveLayout.AbsoluteContentSize.Y + 15)

-- ==========================================
-- LÓGICA DE MOVIMENTAÇÃO (FLY & NOCLIP)
-- ==========================================
local function updateFlyPhysics()
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local att = root:FindFirstChild("RootAttachment") or Instance.new("Attachment", root)

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

	linVel.Parent = root
	alignOri.Parent = root
end

local function toggleFly()
	char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	root = char:WaitForChild("HumanoidRootPart")
	hum = char:WaitForChild("Humanoid")

	updateFlyPhysics()

	FlyActive = not FlyActive
	hum.PlatformStand = FlyActive
	linVel.Enabled = FlyActive
	alignOri.Enabled = FlyActive

	if FlyActive then
		flyBtn.Text = "Ativado"
		flyBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		setStatus("Modo Vôo Ativado.")

		flyConnection = RunService.Heartbeat:Connect(function()
			local cam = workspace.CurrentCamera
			local dir = Vector3.zero

			if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.E) then dir += Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.Q) then dir -= Vector3.new(0, 1, 0) end

			if dir.Magnitude > 0 then dir = dir.Unit end
			linVel.VectorVelocity = dir * FlySpeed
			alignOri.CFrame = workspace.CurrentCamera.CFrame
		end)
	else
		flyBtn.Text = "Desativado"
		flyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		flyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		setStatus("Modo Vôo Desativado.")

		if flyConnection then 
			flyConnection:Disconnect() 
			flyConnection = nil 
		end
		if linVel then linVel.VectorVelocity = Vector3.zero end
	end
end

local function toggleNoclip()
	NoclipActive = not NoclipActive
	if NoclipActive then
		noclipBtn.Text = "Ativado"
		noclipBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		noclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		setStatus("Noclip Ativado.")
	else
		noclipBtn.Text = "Desativado"
		noclipBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		noclipBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		setStatus("Noclip Desativado.")
	end
end

RunService.Stepped:Connect(function()
	if NoclipActive and char and hum and hum.Health > 0 then
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

flyBtn.MouseButton1Click:Connect(toggleFly)
noclipBtn.MouseButton1Click:Connect(toggleNoclip)

speedInput:GetPropertyChangedSignal("Text"):Connect(function()
	local val = tonumber(speedInput.Text)
	if val then FlySpeed = val end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.P then
		toggleFly()
	elseif input.KeyCode == Enum.KeyCode.N then
		toggleNoclip()
	elseif input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt then
		toggleMouseUnlock()
	end
end)

-- ==========================================
-- CONTEÚDO DA ABA: JOGADORES (TELEPORTE & SPECTATE)
-- ==========================================

-- Elementos de UI de Jogadores definidos antes de suas funções
do
	local pSearch = Instance.new("TextBox")
	pSearch.Size = UDim2.new(1, 0, 0, 32)
	pSearch.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	pSearch.PlaceholderText = "Pesquisar jogador..."
	pSearch.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
	pSearch.Text = ""
	pSearch.TextColor3 = Color3.fromRGB(240, 240, 240)
	pSearch.Font = Enum.Font.Gotham
	pSearch.TextSize = 12
	pSearch.BorderSizePixel = 0
	pSearch.Parent = playersPage

	local pSearchCorner = Instance.new("UICorner")
	pSearchCorner.CornerRadius = UDim.new(0, 6)
	pSearchCorner.Parent = pSearch

	local pSearchPadding = Instance.new("UIPadding")
	pSearchPadding.PaddingLeft = UDim.new(0, 8)
	pSearchPadding.Parent = pSearch

	local pScroll = Instance.new("ScrollingFrame")
	pScroll.Size = UDim2.new(1, 0, 1, -45)
	pScroll.Position = UDim2.new(0, 0, 0, 40)
	pScroll.BackgroundTransparency = 1
	pScroll.BorderSizePixel = 0
	pScroll.ScrollBarThickness = 4
	pScroll.ScrollBarImageColor3 = Color3.fromRGB(130, 50, 200)
	pScroll.Parent = playersPage

	local pListLayout = Instance.new("UIListLayout")
	pListLayout.Padding = UDim.new(0, 6)
	pListLayout.Parent = pScroll

	local spectatingPlayer = nil
	local spectateConnection = nil

	-- Função para restaurar o estilo visual de todos os botões de espectar
	local function resetarBotoesEspectar()
		for _, row in ipairs(pScroll:GetChildren()) do
			if row:IsA("Frame") then
				local sBtn = row:FindFirstChild("SpectateButton")
				if sBtn then
					sBtn.Text = "Espectar"
					sBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
					sBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
				end
			end
		end
	end

	-- Função para alternar o foco da câmera de forma segura
	local function alternarEspectador(targetPlayer, specBtn)
		local camera = workspace.CurrentCamera

		-- Desconecta monitoramento anterior se houver
		if spectateConnection then
			spectateConnection:Disconnect()
			spectateConnection = nil
		end

		if spectatingPlayer == targetPlayer then
			-- Desativa o espectador e retorna ao jogador local
			spectatingPlayer = nil
			camera.CameraType = Enum.CameraType.Custom

			local localHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if localHum then
				camera.CameraSubject = localHum
			end
			resetarBotoesEspectar()
			setStatus("Câmera restaurada ao seu personagem.")
		else
			-- Ativa o espectador para o alvo escolhido
			local targetChar = targetPlayer.Character
			local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")

			if targetHum then
				resetarBotoesEspectar()
				spectatingPlayer = targetPlayer

				-- Força o tipo de câmera e foca no alvo
				camera.CameraType = Enum.CameraType.Custom
				camera.CameraSubject = targetHum

				-- Destaca visualmente o botão ativo
				specBtn.Text = "Olhando"
				specBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
				specBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				setStatus("Espectando: " .. targetPlayer.DisplayName)

				-- Se o alvo morrer e renascer, a câmera foca no novo corpo automaticamente
				spectateConnection = targetPlayer.CharacterAdded:Connect(function(newChar)
					task.wait(0.2) -- Aguarda carregamento físico do novo humanoid
					if spectatingPlayer == targetPlayer then
						local newHum = newChar:WaitForChild("Humanoid", 5)
						if newHum then
							camera.CameraType = Enum.CameraType.Custom
							camera.CameraSubject = newHum
						end
					end
				end)
			else
				setStatus("Jogador indisponível ou morto.")
			end
		end
	end

	local function teleportToPlayer(targetPlayer)
		local localChar = LocalPlayer.Character
		local targetChar = targetPlayer.Character
		if localChar and targetChar then
			local localRoot = localChar:FindFirstChild("HumanoidRootPart")
			local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
			if localRoot and targetRoot then
				localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)
				setStatus("Teleportado para: " .. targetPlayer.DisplayName)
			else
				setStatus("Erro: Componentes físicos ausentes.")
			end
		else
			setStatus("Erro: Personagem não carregado.")
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
				rowFrame.Size = UDim2.new(1, -10, 0, 34)
				rowFrame.BackgroundTransparency = 1
				rowFrame.BorderSizePixel = 0
				rowFrame.Parent = pScroll

				local tpBtn = Instance.new("TextButton")
				tpBtn.Name = "TeleportButton"
				tpBtn.Size = UDim2.new(0.7, -4, 1, 0)
				tpBtn.Position = UDim2.new(0, 0, 0, 0)
				tpBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
				tpBtn.BorderSizePixel = 0
				tpBtn.Text = string.format("  %s (@%s)", otherPlayer.DisplayName, otherPlayer.Name)
				tpBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
				tpBtn.Font = Enum.Font.GothamMedium
				tpBtn.TextSize = 10
				tpBtn.TextXAlignment = Enum.TextXAlignment.Left
				tpBtn.Parent = rowFrame

				local tpCorner = Instance.new("UICorner")
				tpCorner.CornerRadius = UDim.new(0, 5)
				tpCorner.Parent = tpBtn

				local specBtn = Instance.new("TextButton")
				specBtn.Name = "SpectateButton"
				specBtn.Size = UDim2.new(0.3, 0, 1, 0)
				specBtn.Position = UDim2.new(0.7, 4, 0, 0)
				specBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
				specBtn.BorderSizePixel = 0
				specBtn.Text = "Espectar"
				specBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
				specBtn.Font = Enum.Font.GothamBold
				specBtn.TextSize = 10
				specBtn.Parent = rowFrame

				local specCorner = Instance.new("UICorner")
				specCorner.CornerRadius = UDim.new(0, 5)
				specCorner.Parent = specBtn

				if spectatingPlayer == otherPlayer then
					specBtn.Text = "Olhando"
					specBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
					specBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				end

				tpBtn.MouseEnter:Connect(function()
					TweenService:Create(tpBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(130, 50, 200), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				end)
				tpBtn.MouseLeave:Connect(function()
					if tpBtn then
						TweenService:Create(tpBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(22, 22, 28), TextColor3 = Color3.fromRGB(200, 200, 210)}):Play()
					end
				end)
				tpBtn.MouseButton1Click:Connect(function()
					teleportToPlayer(otherPlayer)
				end)

				specBtn.MouseEnter:Connect(function()
					if spectatingPlayer ~= otherPlayer then
						TweenService:Create(specBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(80, 80, 95), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
					end
				end)
				specBtn.MouseLeave:Connect(function()
					if specBtn and spectatingPlayer ~= otherPlayer then
						TweenService:Create(specBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(28, 28, 35), TextColor3 = Color3.fromRGB(180, 180, 190)}):Play()
					end
				end)
				specBtn.MouseButton1Click:Connect(function()
					alternarEspectador(otherPlayer, specBtn)
				end)
			end
		end
		pScroll.CanvasSize = UDim2.new(0, 0, 0, pListLayout.AbsoluteContentSize.Y + 10)
	end

	pSearch:GetPropertyChangedSignal("Text"):Connect(function()
		local query = string.lower(pSearch.Text)
		for _, row in ipairs(pScroll:GetChildren()) do
			if row:IsA("Frame") then
				row.Visible = string.find(string.lower(row.Name), query) or false
			end
		end
	end)

	Players.PlayerAdded:Connect(function() task.wait(0.5) updatePlayersList() end)
	Players.PlayerRemoving:Connect(updatePlayersList)
	updatePlayersList()
end

-- ==========================================
-- CONTEÚDO DA ABA: ITENS (TELEPORTE)
-- ==========================================
local itemScroll = Instance.new("ScrollingFrame")
itemScroll.Size = UDim2.new(1, 0, 1, 0)
itemScroll.BackgroundTransparency = 1
itemScroll.BorderSizePixel = 0
itemScroll.ScrollBarThickness = 4
itemScroll.ScrollBarImageColor3 = Color3.fromRGB(130, 50, 200)
itemScroll.Parent = itemsPage

local itemListLayout = Instance.new("UIListLayout")
itemListLayout.Padding = UDim.new(0, 8)
itemListLayout.Parent = itemScroll

local function teleportToItem(itemName)
	local character = LocalPlayer.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	local itemsFolder = Workspace:FindFirstChild("Items")
	local item = (itemsFolder and itemsFolder:FindFirstChild(itemName)) or Workspace:FindFirstChild(itemName)

	if item then
		if item:IsA("Model") then
			rootPart.CFrame = item:GetPivot() + Vector3.new(0, 3, 0)
		elseif item:IsA("BasePart") then
			rootPart.CFrame = item.CFrame + Vector3.new(0, 3, 0)
		end
		setStatus("Teleportado para: " .. itemName)
	else
		setStatus("Não encontrado: " .. itemName)
	end
end

local targetItems = {"Purple Key", "Crowbar", "Battery"}

for _, itemName in ipairs(targetItems) do
	local iBtn = Instance.new("TextButton")
	iBtn.Size = UDim2.new(1, -10, 0, 35)
	iBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	iBtn.Text = "Teleportar para: " .. itemName
	iBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
	iBtn.Font = Enum.Font.GothamBold
	iBtn.TextSize = 12
	iBtn.BorderSizePixel = 0
	iBtn.Parent = itemScroll

	local iBtnCorner = Instance.new("UICorner")
	iBtnCorner.CornerRadius = UDim.new(0, 6)
	iBtnCorner.Parent = iBtn

	iBtn.MouseEnter:Connect(function()
		TweenService:Create(iBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(130, 50, 200)}):Play()
	end)
	iBtn.MouseLeave:Connect(function()
		if iBtn then TweenService:Create(iBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(22, 22, 28)}):Play() end
	end)
	iBtn.MouseButton1Click:Connect(function()
		teleportToItem(itemName)
	end)
end
itemScroll.CanvasSize = UDim2.new(0, 0, 0, itemListLayout.AbsoluteContentSize.Y + 10)


-- ==========================================
-- SISTEMA DE COMBATE (KILL ALL / MODO DEUS)
-- ==========================================
local combatScroll = Instance.new("ScrollingFrame")
combatScroll.Size = UDim2.new(1, 0, 1, 0)
combatScroll.BackgroundTransparency = 1
combatScroll.BorderSizePixel = 0
combatScroll.ScrollBarThickness = 4
combatScroll.ScrollBarImageColor3 = Color3.fromRGB(130, 50, 200)
combatScroll.Parent = combatPage

local combatLayout = Instance.new("UIListLayout")
combatLayout.Padding = UDim.new(0, 10)
combatLayout.Parent = combatScroll

combatLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	combatScroll.CanvasSize = UDim2.new(0, 0, 0, combatLayout.AbsoluteContentSize.Y + 15)
end)

-- Configurações de Combate
local ARMA_PRINCIPAL = "Katana"
local ARMA_SECUNDARIA = "Sword"
local ROCKET = "RocketLauncher"
local BOLA = "Superball"
local ESTILINGUE = "ClassicSlingshot"
local BOMBA_PRETA = "Timebomb"
local BARREIRA = "Trowel"
local LISTA_IGNORAR = {
	"Katana", "Sword", "Timebomb", "RocketLauncher",
	"Superball", "ClassicSlingshot", "MedicKit",
	"Trowel", "GravityCoil", "SpeedCoil"
}
local TEMPO_GRUDADO = 0.5
local DISTANCIA = 0
local VIDA_MINIMA = 40
_G.KillAllAtivo = false

-- Sistema de Noclip automático para combate
RunService.Stepped:Connect(function()
	if _G.KillAllAtivo and LocalPlayer.Character then
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				part.CanCollide = false
			end
		end
	end
end)

local function FindTool(toolName)
	local Character = LocalPlayer.Character
	local Backpack = LocalPlayer.Backpack
	if not Character then return nil end
	return Character:FindFirstChild(toolName) or Backpack:FindFirstChild(toolName)
end

local function FindMysteryTool()
	local Character = LocalPlayer.Character
	local Backpack = LocalPlayer.Backpack
	local function CheckList(parent)
		for _, item in pairs(parent:GetChildren()) do
			if item:IsA("Tool") then
				local ehConhecido = false
				for _, nomeIgnorado in pairs(LISTA_IGNORAR) do
					if item.Name == nomeIgnorado then
						ehConhecido = true
						break
					end
				end
				if not ehConhecido then return item end
			end
		end
		return nil
	end
	return CheckList(Character) or CheckList(Backpack)
end

local function SnapCamera(TargetRoot, chao)
	if not TargetRoot then return end
	if chao then
		local PeDoInimigo = TargetRoot.Position - Vector3.new(0, 6, 0)
		workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, PeDoInimigo)
	else
		workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, TargetRoot.Position)
	end
end

local function EquipAndUse(tool, TargetRoot)
	local Character = LocalPlayer.Character
	if tool and Character then
		tool.Parent = Character
		if TargetRoot and Character:FindFirstChild("HumanoidRootPart") then
			Character.HumanoidRootPart.CFrame = TargetRoot.CFrame
		end

		RunService.Heartbeat:Wait() 

		if TargetRoot and Character:FindFirstChild("HumanoidRootPart") then
			Character.HumanoidRootPart.CFrame = TargetRoot.CFrame
		end

		if tool.Parent == Character then
			tool:Activate()
			return true
		end
	end
	return false
end

local function CheckHeal()
	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChild("Humanoid")
	if Humanoid and Humanoid.Health < VIDA_MINIMA then
		local Kit = FindTool("MedicKit")
		if Kit then
			Kit.Parent = Character
			RunService.Heartbeat:Wait()
			Kit:Activate()
		end
	end
end

local function AttackTarget(TargetPlayer)
	local Character = LocalPlayer.Character
	local MyRoot = Character and Character:FindFirstChild("HumanoidRootPart")
	local TargetChar = TargetPlayer.Character

	if not MyRoot or not TargetChar then return end
	local TargetRoot = TargetChar:FindFirstChild("HumanoidRootPart")
	local TargetHumanoid = TargetChar:FindFirstChild("Humanoid")

	if not TargetRoot or not TargetHumanoid or TargetHumanoid.Health <= 0 then return end

	local Connection
	Connection = RunService.RenderStepped:Connect(function()
		if TargetRoot and MyRoot and TargetChar.Parent and TargetHumanoid.Health > 0 then
			MyRoot.CFrame = TargetRoot.CFrame
			MyRoot.Velocity = Vector3.new(0,0,0)
		else
			if Connection then Connection:Disconnect() end
		end
	end)

	local StartTime = tick()

	SnapCamera(TargetRoot, true) 

	local Pa = FindTool(BARREIRA)
	if Pa then EquipAndUse(Pa, TargetRoot) end 

	local BombaP = FindTool(BOMBA_PRETA)
	if BombaP then EquipAndUse(BombaP, TargetRoot) end 

	local Misterio = FindMysteryTool()
	if Misterio then EquipAndUse(Misterio, TargetRoot) end 

	while (tick() - StartTime) < TEMPO_GRUDADO do
		if not TargetChar.Parent or TargetHumanoid.Health <= 0 then break end
		CheckHeal()

		MyRoot.CFrame = TargetRoot.CFrame
		SnapCamera(TargetRoot, false)

		local Bola = FindTool(BOLA)
		if Bola then EquipAndUse(Bola, TargetRoot) end

		local Estilingue = FindTool(ESTILINGUE)
		if Estilingue then EquipAndUse(Estilingue, TargetRoot) end

		local LancaRocket = FindTool(ROCKET)
		if LancaRocket then EquipAndUse(LancaRocket, TargetRoot) end

		local Espada = FindTool(ARMA_PRINCIPAL) or FindTool(ARMA_SECUNDARIA)
		if Espada then
			EquipAndUse(Espada, TargetRoot)
		end

		RunService.Heartbeat:Wait()
	end

	if Connection then Connection:Disconnect() end
end

local function IsTeammate(player)
	if LocalPlayer.TeamColor == player.TeamColor then return true end
	return false
end

-- Botão para ativar/desativar na interface
criarFrameConfig("Ativar Kill All", "Desativado", combatScroll, function(btn)
	_G.KillAllAtivo = not _G.KillAllAtivo
	if _G.KillAllAtivo then
		btn.Text = "Ativado"
		btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		setStatus("Kill All Ativado.")
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "MODO DEUS",
			Text = "Distância 0 + Noclip + Sticky Frame",
			Duration = 5
		})
	else
		btn.Text = "Desativado"
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		setStatus("Kill All Desativado.")
	end
end)

-- Loop de execução contínua
task.spawn(function()
	while true do
		task.wait()
		if _G.KillAllAtivo then
			pcall(function()
				local Character = LocalPlayer.Character
				if Character and Character:FindFirstChild("HumanoidRootPart") then
					CheckHeal()
					for _, Target in pairs(Players:GetPlayers()) do
						if _G.KillAllAtivo and Target ~= LocalPlayer and not IsTeammate(Target) and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") and Target.Character.Humanoid.Health > 0 then
							AttackTarget(Target)
						end
					end
				end
			end)
		end
	end
end)

-- ==========================================
-- CONTEÚDO DA ABA: VISUAL (ESP / CHAMS)
-- ==========================================
local visualLayout = Instance.new("UIListLayout")
visualLayout.Padding = UDim.new(0, 12)
visualLayout.Parent = visualPage

-- ==========================================
-- CONTEÚDO DA ABA: VISUAL (ROLÁVEL)
-- ==========================================

-- 1. Criação do ScrollingFrame para a aba Visual
local visualScroll = Instance.new("ScrollingFrame")
visualScroll.Size = UDim2.new(1, 0, 1, 0)
visualScroll.BackgroundTransparency = 1
visualScroll.BorderSizePixel = 0
visualScroll.ScrollBarThickness = 4
visualScroll.ScrollBarImageColor3 = Color3.fromRGB(130, 50, 200)
visualScroll.Parent = visualPage

local visualLayout = Instance.new("UIListLayout")
visualLayout.Padding = UDim.new(0, 10)
visualLayout.Parent = visualScroll

-- Ajuste automático do tamanho da área interna com base no conteúdo
visualLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	visualScroll.CanvasSize = UDim2.new(0, 0, 0, visualLayout.AbsoluteContentSize.Y + 15)
end)

-- 2. Componente ESP (Chams de Cores)
local chamsFrame = Instance.new("Frame")
chamsFrame.Size = UDim2.new(1, -10, 0, 45) -- Reduzido levemente em X para não sobrepor a barra de rolagem
chamsFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
chamsFrame.BorderSizePixel = 0
chamsFrame.Parent = visualScroll -- Redirecionado para visualScroll

local chamsCorner = Instance.new("UICorner")
chamsCorner.CornerRadius = UDim.new(0, 6)
chamsCorner.Parent = chamsFrame

local chamsLabel = Instance.new("TextLabel")
chamsLabel.Size = UDim2.new(0.6, 0, 1, 0)
chamsLabel.Position = UDim2.new(0, 12, 0, 0)
chamsLabel.BackgroundTransparency = 1
chamsLabel.Text = "Habilitar ESP (Chams de Cores)"
chamsLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
chamsLabel.Font = Enum.Font.GothamBold
chamsLabel.TextSize = 12
chamsLabel.TextXAlignment = Enum.TextXAlignment.Left
chamsLabel.Parent = chamsFrame

local chamsBtn = Instance.new("TextButton")
chamsBtn.Size = UDim2.new(0.3, 0, 0.7, 0)
chamsBtn.Position = UDim2.new(0.65, 0, 0.15, 0)
chamsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
chamsBtn.Text = "Desativado"
chamsBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
chamsBtn.Font = Enum.Font.GothamMedium
chamsBtn.TextSize = 11
chamsBtn.BorderSizePixel = 0
chamsBtn.Parent = chamsFrame

local chamsBtnCorner = Instance.new("UICorner")
chamsBtnCorner.CornerRadius = UDim.new(0, 5)
chamsBtnCorner.Parent = chamsBtn

-- 3. Componente ESP ComputerTable
local compEspFrame = Instance.new("Frame")
compEspFrame.Size = UDim2.new(1, -10, 0, 45)
compEspFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
compEspFrame.BorderSizePixel = 0
compEspFrame.Parent = ftfScroll -- Redirecionado para ftfPage

local compEspCorner = Instance.new("UICorner")
compEspCorner.CornerRadius = UDim.new(0, 6)
compEspCorner.Parent = compEspFrame

local compEspLabel = Instance.new("TextLabel")
compEspLabel.Size = UDim2.new(0.6, 0, 1, 0)
compEspLabel.Position = UDim2.new(0, 12, 0, 0)
compEspLabel.BackgroundTransparency = 1
compEspLabel.Text = "Habilitar ESP (ComputerTable)"
compEspLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
compEspLabel.Font = Enum.Font.GothamBold
compEspLabel.TextSize = 12
compEspLabel.TextXAlignment = Enum.TextXAlignment.Left
compEspLabel.Parent = compEspFrame

local compEspBtn = Instance.new("TextButton")
compEspBtn.Size = UDim2.new(0.3, 0, 0.7, 0)
compEspBtn.Position = UDim2.new(0.65, 0, 0.15, 0)
compEspBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
compEspBtn.Text = "Desativado"
compEspBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
compEspBtn.Font = Enum.Font.GothamMedium
compEspBtn.TextSize = 11
compEspBtn.BorderSizePixel = 0
compEspBtn.Parent = compEspFrame

local compEspBtnCorner = Instance.new("UICorner")
compEspBtnCorner.CornerRadius = UDim.new(0, 5)
compEspBtnCorner.Parent = compEspBtn

-- 4. Componente ESP FreezePod
local freezeEspFrame = Instance.new("Frame")
freezeEspFrame.Size = UDim2.new(1, -10, 0, 45)
freezeEspFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
freezeEspFrame.BorderSizePixel = 0
freezeEspFrame.Parent = ftfScroll -- Redirecionado para ftfPage

local freezeEspCorner = Instance.new("UICorner")
freezeEspCorner.CornerRadius = UDim.new(0, 6)
freezeEspCorner.Parent = freezeEspFrame

local freezeEspLabel = Instance.new("TextLabel")
freezeEspLabel.Size = UDim2.new(0.6, 0, 1, 0)
freezeEspLabel.Position = UDim2.new(0, 12, 0, 0)
freezeEspLabel.BackgroundTransparency = 1
freezeEspLabel.Text = "Habilitar ESP (FreezePod)"
freezeEspLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
freezeEspLabel.Font = Enum.Font.GothamBold
freezeEspLabel.TextSize = 12
freezeEspLabel.TextXAlignment = Enum.TextXAlignment.Left
freezeEspLabel.Parent = freezeEspFrame

local freezeEspBtn = Instance.new("TextButton")
freezeEspBtn.Size = UDim2.new(0.3, 0, 0.7, 0)
freezeEspBtn.Position = UDim2.new(0.65, 0, 0.15, 0)
freezeEspBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
freezeEspBtn.Text = "Desativado"
freezeEspBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
freezeEspBtn.Font = Enum.Font.GothamMedium
freezeEspBtn.TextSize = 11
freezeEspBtn.BorderSizePixel = 0
freezeEspBtn.Parent = freezeEspFrame

local freezeEspBtnCorner = Instance.new("UICorner")
freezeEspBtnCorner.CornerRadius = UDim.new(0, 5)
freezeEspBtnCorner.Parent = freezeEspBtn

-- Função para atualizar e aplicar o Highlight nos FreezePods carregados no mapa
local function atualizarFreezePodESP()
	if FreezePodESPActive then
		for _, descendant in ipairs(Workspace:GetDescendants()) do
			-- Normaliza o nome removendo espaços e convertendo para minúsculas
			local nomeFormatado = string.gsub(string.lower(descendant.Name), " ", "")
			if nomeFormatado == "freezepod" and descendant:IsA("Model") then
				local highlight = descendant:FindFirstChild("FreezePodHighlight")
				if not highlight then
					highlight = Instance.new("Highlight")
					highlight.Name = "FreezePodHighlight"
					highlight.FillColor = Color3.fromRGB(0, 23, 55) -- Tom ciano/gelo
					highlight.FillTransparency = 0.4
					highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
					highlight.OutlineTransparency = 0.1
					highlight.Parent = descendant
				end
			end
		end
	else
		-- Remove o Highlight se desativado
		for _, descendant in ipairs(Workspace:GetDescendants()) do
			local nomeFormatado = string.gsub(string.lower(descendant.Name), " ", "")
			if nomeFormatado == "freezepod" then
				local highlight = descendant:FindFirstChild("FreezePodHighlight")
				if highlight then
					highlight:Destroy()
				end
			end
		end
	end
end

-- Listener para escutar novos objetos FreezePod adicionados dinamicamente no jogo
Workspace.DescendantAdded:Connect(function(descendant)
	if FreezePodESPActive then
		local nomeFormatado = string.gsub(string.lower(descendant.Name), " ", "")
		if nomeFormatado == "freezepod" and descendant:IsA("Model") then
			task.wait(0.2) -- Aguarda as peças internas carregarem totalmente
			atualizarFreezePodESP()
		end
	end
end)

freezeEspBtn.MouseButton1Click:Connect(function()
	FreezePodESPActive = not FreezePodESPActive
	if FreezePodESPActive then
		freezeEspBtn.Text = "Ativado"
		freezeEspBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		freezeEspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		setStatus("ESP FreezePod Ativado.")
	else
		freezeEspBtn.Text = "Desativado"
		freezeEspBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		freezeEspBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		setStatus("ESP FreezePod Desativado.")
	end
	atualizarFreezePodESP()
end)

compEspBtn.MouseButton1Click:Connect(function()
	ComputerTableESPActive = not ComputerTableESPActive
	if ComputerTableESPActive then
		compEspBtn.Text = "Ativado"
		compEspBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		compEspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		setStatus("ESP ComputerTable Ativado.")
	else
		compEspBtn.Text = "Desativado"
		compEspBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		compEspBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		setStatus("ESP ComputerTable Desativado.")
	end
	atualizarComputerTableESP()
end)

local function obterCorPeloNome(username)
	local hash = 0
	for i = 1, #username do hash = hash + string.byte(username, i) end
	return Color3.fromHSV((hash % 100) / 100, 0.9, 1)
end

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

local function monitorarJogador(targetPlayer)
	if targetPlayer == LocalPlayer then return end
	local function noCharacterAdded(character)
		task.wait(0.1)
		if ChamsActive then colorirPersonagem(character, targetPlayer) end
		character.DescendantAdded:Connect(function(desc)
			if ChamsActive and desc:IsA("BasePart") then
				task.wait()
				desc.Color = obterCorPeloNome(targetPlayer.Name)
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

-- Lógica para buscar e aplicar ESP em todos os modelos de ComputerTable
local function atualizarComputerTableESP()
	if ComputerTableESPActive then
		for _, descendant in ipairs(Workspace:GetDescendants()) do
			-- Normaliza o nome para evitar problemas com maiúsculas/minúsculas ou espaços
			local nomeFormatado = string.lower(descendant.Name)
			if (nomeFormatado == "computertable" or nomeFormatado == "computer table") and descendant:IsA("Model") then
				local highlight = descendant:FindFirstChild("ComputerHighlight")
				if not highlight then
					highlight = Instance.new("Highlight")
					highlight.Name = "ComputerHighlight"
					highlight.FillColor = Color3.fromRGB(0, 180, 255) -- Cor Ciano/Azul claro para destaque
					highlight.FillTransparency = 0.4
					highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
					highlight.OutlineTransparency = 0.1
					highlight.Parent = descendant
				end
			end
		end
	else
		-- Remove o ESP das mesas caso a função seja desativada
		for _, descendant in ipairs(Workspace:GetDescendants()) do
			local nomeFormatado = string.lower(descendant.Name)
			if nomeFormatado == "computertable" or nomeFormatado == "computer table" then
				local highlight = descendant:FindFirstChild("ComputerHighlight")
				if highlight then
					highlight:Destroy()
				end
			end
		end
	end
end

-- Monitora caso novos modelos de ComputerTable sejam carregados dinamicamente no mapa
Workspace.DescendantAdded:Connect(function(descendant)
	if ComputerTableESPActive then
		local nomeFormatado = string.lower(descendant.Name)
		if (nomeFormatado == "computertable" or nomeFormatado == "computer table") and descendant:IsA("Model") then
			task.wait(0.2) -- Aguarda o carregamento completo das partes internas do modelo
			atualizarComputerTableESP()
		end
	end
end)

-- Escuta caso novas ComputerTables sejam criadas dinamicamente no mapa
Workspace.DescendantAdded:Connect(function(descendant)
	if ComputerTableESPActive and descendant.Name == "ComputerTable" then
		task.wait(0.1)
		atualizarComputerTableESP()
	end
end)

chamsBtn.MouseButton1Click:Connect(toggleChams)
for _, otherPlayer in ipairs(Players:GetPlayers()) do monitorarJogador(otherPlayer) end
Players.PlayerAdded:Connect(monitorarJogador)

-- ==========================================
-- FOV SLIDER (Campo de Visão)
-- ==========================================

do
	local fovFrame = Instance.new("Frame")
	fovFrame.Size = UDim2.new(1, -10, 0, 45)
	fovFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	fovFrame.BorderSizePixel = 0
	fovFrame.Parent = visualScroll -- Certifique-se de que visualScroll existe

	local fovCorner = Instance.new("UICorner")
	fovCorner.CornerRadius = UDim.new(0, 6)
	fovCorner.Parent = fovFrame

	local fovLabel = Instance.new("TextLabel")
	fovLabel.Size = UDim2.new(0.5, 0, 1, 0)
	fovLabel.Position = UDim2.new(0, 12, 0, 0)
	fovLabel.BackgroundTransparency = 1
	fovLabel.Text = "Campo de Visão (FOV):"
	fovLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
	fovLabel.Font = Enum.Font.GothamBold
	fovLabel.TextSize = 12
	fovLabel.TextXAlignment = Enum.TextXAlignment.Left
	fovLabel.Parent = fovFrame

	local fovInput = Instance.new("TextBox")
	fovInput.Size = UDim2.new(0.3, 0, 0.7, 0)
	fovInput.Position = UDim2.new(0.65, 0, 0.15, 0)
	fovInput.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
	fovInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	fovInput.Text = tostring(workspace.CurrentCamera.FieldOfView)
	fovInput.Font = Enum.Font.GothamBold
	fovInput.TextSize = 12
	fovInput.BorderSizePixel = 0
	fovInput.Parent = fovFrame

	local fovInputCorner = Instance.new("UICorner")
	fovInputCorner.CornerRadius = UDim.new(0, 5)
	fovInputCorner.Parent = fovInput

	-- Lógica do FOV
	fovInput.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			local newFov = tonumber(fovInput.Text)
			if newFov then
				-- Limita entre 10 e 120 para evitar bugs visuais extremos
				local clampedFov = math.clamp(newFov, 10, 120)
				workspace.CurrentCamera.FieldOfView = clampedFov
				fovInput.Text = tostring(clampedFov)
				setStatus("FOV definido para " .. clampedFov)
			else
				fovInput.Text = tostring(workspace.CurrentCamera.FieldOfView)
			end
		end
	end)
end
-- Atualizar CanvasSize da visualScroll após adicionar novos itens
visualScroll.CanvasSize = UDim2.new(0, 0, 0, visualLayout.AbsoluteContentSize.Y + 15)

-- ==========================================
-- MODS ESPECÍFICOS: FLEE THE FACILITY
-- ==========================================
do
	-- 1. NEVER FAIL HACKING (Auto-Hack)
	local autoHackActive = false
	criarFrameConfig("Nunca Errar Hack (Auto-Hack)", "Desativado", ftfScroll, function(btn)
		autoHackActive = not autoHackActive
		btn.Text = autoHackActive and "Ativado" or "Desativado"
		btn.BackgroundColor3 = autoHackActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)

		task.spawn(function()
			while autoHackActive do
				RemoteEvent:FireServer("SetPlayerMinigameResult", true)
				task.wait(0.1)
			end
		end)
	end)

	-- 2. ESP DE COMPUTADORES DINÂMICO (Melhorado com cores por estado)
	local compEspConnection
	criarFrameConfig("ESP Computadores Dinâmico", "Desativado", ftfScroll, function(btn)
		ComputerTableESPActive = not ComputerTableESPActive
		btn.Text = ComputerTableESPActive and "Ativado" or "Desativado"
		btn.BackgroundColor3 = ComputerTableESPActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)

		if ComputerTableESPActive then
			compEspConnection = RunService.Heartbeat:Connect(function()
				for _, v in ipairs(Workspace:GetDescendants()) do
					if v.Name == "ComputerTable" and v:IsA("Model") then
						local highlight = v:FindFirstChild("ComputerHighlight")
						if not highlight then
							highlight = Instance.new("Highlight", v)
							highlight.Name = "ComputerHighlight"
							highlight.OutlineColor = Color3.new(1, 1, 1)
						end
						local screen = v:FindFirstChild("Screen")
						if screen then
							if screen.BrickColor == BrickColor.new("Bright blue") then
								highlight.FillColor = Color3.new(0, 0, 1) -- Azul: Em progresso
							elseif screen.BrickColor == BrickColor.new("Dark green") then
								highlight.FillColor = Color3.new(0, 1, 0) -- Verde: Concluído
							end
						end
					end
				end
			end)
			setStatus("ESP Computadores Dinâmico Ativado.")
		else
			if compEspConnection then
				compEspConnection:Disconnect()
				compEspConnection = nil
			end
			for _, v in ipairs(Workspace:GetDescendants()) do
				if v.Name == "ComputerTable" then
					local hl = v:FindFirstChild("ComputerHighlight")
					if hl then hl:Destroy() end
				end
			end
			setStatus("ESP Computadores Dinâmico Desativado.")
		end
	end)

	-- 3. ESP DE PORTAS DINÂMICO (Aberto = Verde / Fechado = Vermelho)
	local doorEspConnection
	criarFrameConfig("ESP Portas (Status)", "Desativado", ftfScroll, function(btn)
		local doorActive = (btn.Text == "Desativado")
		btn.Text = doorActive and "Ativado" or "Desativado"
		btn.BackgroundColor3 = doorActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)

		if doorActive then
			doorEspConnection = RunService.Heartbeat:Connect(function()
				for _, v in ipairs(Workspace:GetDescendants()) do
					if v.Name == "SingleDoor" and v:FindFirstChild("Door") then
						local hl = v.Door:FindFirstChild("DoorHighlight")
						if not hl then
							hl = Instance.new("Highlight", v.Door)
							hl.Name = "DoorHighlight"
							hl.OutlineColor = Color3.new(1, 1, 1)
						end
						local trigger = v:FindFirstChild("DoorTrigger")
						if trigger and trigger:FindFirstChild("ActionSign") then
							hl.FillColor = (trigger.ActionSign.Value == 11) and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
						end
					elseif v.Name == "DoubleDoor" then
						local hl = v:FindFirstChild("DoorHighlight")
						if not hl then
							hl = Instance.new("Highlight", v)
							hl.Name = "DoorHighlight"
							hl.OutlineColor = Color3.new(1, 1, 1)
						end
						local trigger = v:FindFirstChild("DoorTrigger")
						if trigger and trigger:FindFirstChild("ActionSign") then
							hl.FillColor = (trigger.ActionSign.Value == 11) and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
						end
					end
				end
			end)
		else
			if doorEspConnection then
				doorEspConnection:Disconnect()
				doorEspConnection = nil
			end
			for _, v in ipairs(Workspace:GetDescendants()) do
				if v.Name == "SingleDoor" and v:FindFirstChild("Door") then
					local hl = v.Door:FindFirstChild("DoorHighlight")
					if hl then hl:Destroy() end
				elseif v.Name == "DoubleDoor" then
					local hl = v:FindFirstChild("DoorHighlight")
					if hl then hl:Destroy() end
				end
			end
		end
	end)

	-- 4. ESP DE SAÍDAS E DUTOS
	local ftfVisualsActive = false
	local function applyFTFHighlight(name, color)
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj.Name == name and obj:IsA("Model") then
				local hl = obj:FindFirstChild("FTF_Highlight")
				if ftfVisualsActive then
					if not hl then
						hl = Instance.new("Highlight", obj)
						hl.Name = "FTF_Highlight"
						hl.FillTransparency = 0.5
						hl.OutlineColor = Color3.new(1,1,1)
					end
					hl.FillColor = color
				elseif hl then
					hl:Destroy()
				end
			end
		end
	end

	criarFrameConfig("ESP Saídas e Dutos", "Desativado", ftfScroll, function(btn)
		ftfVisualsActive = not ftfVisualsActive
		btn.Text = ftfVisualsActive and "Ativado" or "Desativado"
		btn.BackgroundColor3 = ftfVisualsActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)

		applyFTFHighlight("ExitDoor", Color3.fromRGB(255, 255, 0))
		applyFTFHighlight("AirVent", Color3.fromRGB(100, 100, 100))
	end)

	-- 5. BEAST STEALTH (Silenciar Fera)
	criarFrameConfig("Fera Silenciosa (Stealth)", "Executar", ftfScroll, function()
		local character = LocalPlayer.Character
		if character then
			for _, v in pairs(character:GetDescendants()) do
				if v:IsA("Sound") and (v.Parent.Name == "Handle" or v.Parent.Name == "Hammer") then
					v:Destroy()
				end
			end
			local gemstone = character:FindFirstChild("Gemstone")
			if gemstone then
				local light = gemstone:FindFirstChildOfClass("PointLight", true)
				if light then light:Destroy() end
			end
			setStatus("Som e Brilho da Fera removidos.")
		end
	end)

	-- 6. SPRINT MANUAL (Tecla Q para correr)
	local sprintConnection
	criarFrameConfig("Sprint de Sobrevivência [Q]", "Desativado", ftfScroll, function(btn)
		local sprintActive = (btn.Text == "Desativado")
		btn.Text = sprintActive and "Ativado" or "Desativado"
		btn.BackgroundColor3 = sprintActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)

		if sprintActive then
			sprintConnection = UserInputService.InputBegan:Connect(function(input, processed)
				if not processed and input.KeyCode == Enum.KeyCode.Q then
					local character = LocalPlayer.Character
					if character and character:FindFirstChild("Humanoid") then
						character.Humanoid.WalkSpeed = 30
					end
				end
			end)
			local releaseConnection
			releaseConnection = UserInputService.InputEnded:Connect(function(input)
				if input.KeyCode == Enum.KeyCode.Q then
					local character = LocalPlayer.Character
					if character and character:FindFirstChild("Humanoid") then
						character.Humanoid.WalkSpeed = 16
					end
				end
			end)
			pcall(function()
				if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("PowersLocalScript") then
					LocalPlayer.Character.PowersLocalScript:Destroy()
				end
			end)
		else
			if sprintConnection then
				sprintConnection:Disconnect()
				sprintConnection = nil
			end
		end
	end)

	-- 7. AUTO-FLOP
	local autoFlopActive = false
	criarFrameConfig("Auto-Flop (Bugar Captura)", "Desativado", ftfScroll, function(btn)
		autoFlopActive = not autoFlopActive
		btn.Text = autoFlopActive and "Ativado" or "Desativado"
		btn.BackgroundColor3 = autoFlopActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	end)

	task.spawn(function()
		while true do
			task.wait(0.2)
			if autoFlopActive then
				local stats = LocalPlayer:FindFirstChild("TempPlayerStatsModule")
				if stats and stats:FindFirstChild("Ragdoll") and stats.Ragdoll.Value == true then
					RemoteEvent:FireServer("Flop", Vector3.new(math.random(-100,100), 100, math.random(-100,100)))
				end
			end
		end
	end)

	-- 8. DESTRAVAR CRAWL (Fera)
	criarFrameConfig("Destravar Engatinhar Fera", "Executar", ftfScroll, function()
		pcall(function()
			LocalPlayer.TempPlayerStatsModule.DisableCrawl.Value = false
			setStatus("Engatinhar liberado.")
		end)
	end)

	-- 9. BYPASS ANTICHEAT (Survivor)
	criarFrameConfig("Burlar Anticheat (Survivor)", "Executar", ftfScroll, function()
		local character = LocalPlayer.Character
		if character then
			local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if torso and rootPart then
				character.Parent = nil
				rootPart.Parent = nil
				task.wait(0.5)
				local fake = torso:Clone()
				fake.Parent = character
				torso.Name = "HumanoidRootPart"
				torso.Transparency = 1
				character.Parent = workspace
				setStatus("Bypass aplicado localmente.")
			end
		end
	end)

	-- 10. DETECTAR QUEM É A FERA
	criarFrameConfig("Quem é a Fera?", "Verificar", ftfScroll, function()
		local beastName = "Não detectada"
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character and p.Character:FindFirstChild("BeastPowers") then
				beastName = p.DisplayName .. " (@" .. p.Name .. ")"
				break
			end
		end
		setStatus("Fera Atual: " .. beastName)
	end)

	-- ==========================================
	-- ESPs AVANÇADOS (CATEGORIA 2 - KOALA SCRIPTS)
	-- ==========================================

	-- 1. Mostrar Progresso de Hack em Tempo Real (PCProgESP)
	local pcProgConnection
	criarFrameConfig("Mostrar Progresso de Hack (PC)", "Desativado", ftfScroll, function(btn)
		local active = (btn.Text == "Desativado")
		btn.Text = active and "Ativado" or "Desativado"
		btn.BackgroundColor3 = active and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)

		if active then
			pcProgConnection = RunService.Heartbeat:Connect(function()
				local currentMap = game.ReplicatedStorage:FindFirstChild("CurrentMap")
				local mapValue = currentMap and currentMap.Value
				if not mapValue then return end

				-- Coleta jogadores digitando
				local typingPlayers = {}
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= LocalPlayer and p.Character and p:FindFirstChild("TempPlayerStatsModule") then
						local anim = p.TempPlayerStatsModule:FindFirstChild("CurrentAnimation")
						if anim and anim.Value == "Typing" then
							table.insert(typingPlayers, p)
						end
					end
				end

				-- Atualiza os outdoors de progresso
				local pcCount = 0
				for _, v in ipairs(mapValue:GetChildren()) do
					if v.Name == "ComputerTable" and v:FindFirstChild("Screen") then
						pcCount = pcCount + 1
						local billboard = v:FindFirstChild("KSBillboard")
						if not billboard then
							billboard = Instance.new("BillboardGui")
							billboard.Name = "KSBillboard"
							billboard.AlwaysOnTop = true
							billboard.Size = UDim2.new(0, 200, 0, 25)
							billboard.StudsOffsetWorldSpace = Vector3.new(0, 1.5, 0)
							billboard.Parent = v

							local label = Instance.new("TextLabel")
							label.BackgroundTransparency = 1
							label.TextColor3 = Color3.fromRGB(0, 200, 255)
							label.Font = Enum.Font.GothamBold
							label.Size = UDim2.new(1, 0, 1, 0)
							label.TextScaled = true
							label.RichText = true
							label.Parent = billboard
						end

						-- Calcula o progresso do jogador mais próximo
						local progress = nil
						for _, tpPlr in ipairs(typingPlayers) do
							if tpPlr.Character and tpPlr.Character:FindFirstChild("HumanoidRootPart") then
								local dist = (tpPlr.Character.HumanoidRootPart.Position - v.Screen.Position).Magnitude
								if dist < 15 then
									local stats = tpPlr:FindFirstChild("TempPlayerStatsModule")
									local progressVal = stats and stats:FindFirstChild("ActionProgress")
									if progressVal then
										progress = math.round(progressVal.Value * 100)
									end
								end
							end
						end

						if progress then
							billboard.TextLabel.Text = string.format("PC %d | <font color='#00FF00'>%d%%</font>", pcCount, progress)
						else
							billboard.TextLabel.Text = string.format("PC %d | Aguardando", pcCount)
						end
					end
				end
			end)
		else
			if pcProgConnection then
				pcProgConnection:Disconnect()
				pcProgConnection = nil
			end
			local currentMap = game.ReplicatedStorage:FindFirstChild("CurrentMap")
			local mapValue = currentMap and currentMap.Value
			if mapValue then
				for _, v in ipairs(mapValue:GetChildren()) do
					local billboard = v:FindFirstChild("KSBillboard")
					if billboard then billboard:Destroy() end
				end
			end
		end
	end)

	-- 2. Mostrar Tempo de Queda / Recuperação de Sobreviventes (ShowPlrRagTime)
	local ragdollConnection
	criarFrameConfig("ESP Tempo de Queda (Nocaute)", "Desativado", ftfScroll, function(btn)
		local active = (btn.Text == "Desativado")
		btn.Text = active and "Ativado" or "Desativado"
		btn.BackgroundColor3 = active and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)

		if active then
			ragdollConnection = RunService.Heartbeat:Connect(function()
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
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
								billboard.Parent = p.Character

								local label = Instance.new("TextLabel")
								label.BackgroundTransparency = 1
								label.TextColor3 = Color3.fromRGB(255, 50, 50)
								label.Font = Enum.Font.GothamBold
								label.Size = UDim2.new(1, 0, 1, 0)
								label.TextScaled = true
								label.Parent = billboard
							end
							billboard.TextLabel.Text = string.format("%s | Caído: %d%%", p.DisplayName, math.floor(progress.Value * 100))
						elseif billboard then
							billboard:Destroy()
						end
					end
				end
			end)
		else
			if ragdollConnection then
				ragdollConnection:Disconnect()
				ragdollConnection = nil
			end
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Character then
					local billboard = p.Character:FindFirstChild("PlrRagTimeBillboard")
					if billboard then billboard:Destroy() end
				end
			end
		end
	end)

	-- 3. ESP de Armários / Closets (LockerESP)
	local lockerESPActive = false
	criarFrameConfig("ESP Armários (Locker ESP)", "Desativado", ftfScroll, function(btn)
		lockerESPActive = not lockerESPActive
		btn.Text = lockerESPActive and "Ativado" or "Desativado"
		btn.BackgroundColor3 = lockerESPActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)

		local collectionService = game:GetService("CollectionService")

		if lockerESPActive then
			for _, locker in ipairs(collectionService:GetTagged("LOCKER")) do
				if not locker:FindFirstChild("LockerHighlight") then
					local highlight = Instance.new("Highlight")
					highlight.Name = "LockerHighlight"
					highlight.FillColor = Color3.fromRGB(210, 210, 0) -- Amarelo translúcido
					highlight.FillTransparency = 0.6
					highlight.OutlineColor = Color3.fromRGB(255, 255, 100)
					highlight.OutlineTransparency = 0.2
					highlight.Parent = locker
				end
			end
		else
			for _, locker in ipairs(collectionService:GetTagged("LOCKER")) do
				local hl = locker:FindFirstChild("LockerHighlight")
				if hl then hl:Destroy() end
			end
		end
	end)

	-- 4. ESP de Dutos de Ventilação (VentESP)
	local ventESPActive = false
	criarFrameConfig("ESP Dutos de Ventilação", "Desativado", ftfScroll, function(btn)
		ventESPActive = not ventESPActive
		btn.Text = ventESPActive and "Ativado" or "Desativado"
		btn.BackgroundColor3 = ventESPActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)

		local function criarSlicesVent(part)
			if part:FindFirstChild("VentSGU_Front") then return end
			local faces = {
				Enum.NormalId.Front, Enum.NormalId.Back, 
				Enum.NormalId.Left, Enum.NormalId.Right, 
				Enum.NormalId.Top, Enum.NormalId.Bottom
			}
			for _, face in ipairs(faces) do
				local sgu = Instance.new("SurfaceGui")
				sgu.Name = "VentSGU_" .. face.Name
				sgu.AlwaysOnTop = true
				sgu.Face = face
				sgu.Parent = part

				local frame = Instance.new("Frame")
				frame.BackgroundColor3 = Color3.fromRGB(255, 255, 150) -- Amarelo claro suave
				frame.BackgroundTransparency = 0.65
				frame.Size = UDim2.new(1, 0, 1, 0)
				frame.BorderSizePixel = 0
				frame.Parent = sgu
			end
		end

		local function removerSlicesVent(part)
			for _, v in ipairs(part:GetChildren()) do
				if v:IsA("SurfaceGui") and string.find(v.Name, "VentSGU_") then
					v:Destroy()
				end
			end
		end

		if ventESPActive then
			local currentMap = game.ReplicatedStorage:FindFirstChild("CurrentMap")
			local mapValue = currentMap and currentMap.Value
			if mapValue then
				for _, v in ipairs(mapValue:GetDescendants()) do
					if v:IsA("BasePart") and string.find(string.lower(v.Name), "ventblock") then
						criarSlicesVent(v)
					end
				end
			end
		else
			local currentMap = game.ReplicatedStorage:FindFirstChild("CurrentMap")
			local mapValue = currentMap and currentMap.Value
			if mapValue then
				for _, v in ipairs(mapValue:GetDescendants()) do
					if v:IsA("BasePart") then
						removerSlicesVent(v)
					end
				end
			end
		end
	end)
end

-- ==========================================
-- CONTEÚDO DA ABA: UTILITÁRIOS (ROlÁVEL)
-- ==========================================
local utilsScroll = Instance.new("ScrollingFrame")
utilsScroll.Size = UDim2.new(1, 0, 1, 0)
utilsScroll.BackgroundTransparency = 1
utilsScroll.BorderSizePixel = 0
utilsScroll.ScrollBarThickness = 4
utilsScroll.ScrollBarImageColor3 = Color3.fromRGB(130, 50, 200)
utilsScroll.Parent = utilsPage

local utilsScrollLayout = Instance.new("UIListLayout")
utilsScrollLayout.Padding = UDim.new(0, 10)
utilsScrollLayout.Parent = utilsScroll

-- 1. Resetar Câmera
criarFrameConfig("Forçar Câmera Custom", "Resetar",utilsScroll, function()
	local camera = workspace.CurrentCamera
	local character = LocalPlayer.Character
	if camera and character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		camera.CameraType = Enum.CameraType.Custom
		if humanoid then
			camera.CameraSubject = humanoid
			setStatus("Câmera resetada com sucesso.")
		else
			setStatus("Aviso: Tipo definido para Custom, sem foco no Humanoid.")
		end
	else
		setStatus("Erro: Componentes inacessíveis.")
	end
end)

-- 2. Brilho Máximo (Fullbright)
criarFrameConfig("Brilho Máximo (Fullbright)", "Desativado",visualScroll, function(btn)
	FullbrightActive = not FullbrightActive
	if FullbrightActive then
		btn.Text = "Ativado"
		btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
		Lighting.GlobalShadows = false
		setStatus("Fullbright Ativado.")
	else
		btn.Text = "Desativado"
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		Lighting.Ambient = originalAmbient
		Lighting.OutdoorAmbient = originalOutdoor
		Lighting.GlobalShadows = originalShadows
		setStatus("Fullbright Desativado.")
	end
end)

-- 3. Pulo Infinito (Infinite Jump)
criarFrameConfig("Habilitar Pulo Infinito", "Desativado",moveScroll, function(btn)
	InfiniteJumpActive = not InfiniteJumpActive
	if InfiniteJumpActive then
		btn.Text = "Ativado"
		btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		setStatus("Pulo Infinito Ativado.")

		jumpConnection = UserInputService.JumpRequest:Connect(function()
			local character = LocalPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	else
		btn.Text = "Desativado"
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		setStatus("Pulo Infinito Desativado.")
		if jumpConnection then
			jumpConnection:Disconnect()
			jumpConnection = nil
		end
	end
end)

-- 4. Otimizador de FPS (Lag Remover)
criarFrameConfig("Otimizar Gráficos (Anti-Lag)", "Executar",visualScroll, function()
	local alterados = 0
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Material = Enum.Material.SmoothPlastic
			alterados = alterados + 1
		elseif obj:IsA("Decal") or obj:IsA("Texture") then
			obj:Destroy()
			alterados = alterados + 1
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
			obj.Enabled = false
			alterados = alterados + 1
		end
	end
	Lighting.GlobalShadows = false
	setStatus("Limpeza concluída. " .. alterados .. " elementos otimizados.")
end)

-- 5. Reentrar no Servidor (Rejoin)
criarFrameConfig("Reentrar no Servidor (Rejoin)", "Reconectar",utilsScroll, function()
	setStatus("Tentando reconectar...")
	task.wait(0.5)
	if #Players:GetPlayers() <= 1 then
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	else
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end
end)

-- 6. Evitar Desconexão (Anti-AFK)
criarFrameConfig("Evitar Desconexão (Anti-AFK)", "Desativado",utilsScroll, function(btn)
	antiAfkActive = not antiAfkActive
	if antiAfkActive then
		btn.Text = "Ativado"
		btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		setStatus("Anti-AFK Ativado.")

		antiAfkConnection = LocalPlayer.Idled:Connect(function()
			local VirtualUser = game:GetService("VirtualUser")
			VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			task.wait(1)
			VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		end)
	else
		btn.Text = "Desativado"
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		setStatus("Anti-AFK Desativado.")

		if antiAfkConnection then
			antiAfkConnection:Disconnect()
			antiAfkConnection = nil
		end
	end
end)

-- 7. Remover Névoa (No Fog)
criarFrameConfig("Remover Névoa (No Fog)", "Desativado",visualScroll, function(btn)
	noFogActive = not noFogActive
	if noFogActive then
		btn.Text = "Ativado"
		btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)

		originalFogStart = Lighting.FogStart
		originalFogEnd = Lighting.FogEnd
		originalAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

		Lighting.FogStart = 999999
		Lighting.FogEnd = 999999
		if originalAtmosphere then
			originalAtmosphere.Parent = nil
		end
		setStatus("Névoa Removida.")
	else
		btn.Text = "Desativado"
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)

		Lighting.FogStart = originalFogStart
		Lighting.FogEnd = originalFogEnd
		if originalAtmosphere then
			originalAtmosphere.Parent = Lighting
		end
		setStatus("Névoa Restaurada.")
	end
end)

-- 8. Ferramenta de Teleporte por Clique (Click TP Tool)
criarFrameConfig("Ferramenta Click TP", "Obter Tool",moveScroll, function()
	local mochila = LocalPlayer:WaitForChild("Backpack")

	-- Impede a criação de ferramentas duplicadas
	if mochila:FindFirstChild("Teleporte Tool") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Teleporte Tool")) then
		setStatus("Você já possui esta ferramenta.")
		return
	end

	local mouse = LocalPlayer:GetMouse()
	local tool = Instance.new("Tool")
	tool.Name = "Teleporte Tool"
	tool.RequiresHandle = false

	tool.Activated:Connect(function()
		local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			rootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
			setStatus("Teleportado via clique.")
		end
	end)

	tool.Parent = mochila
	setStatus("Ferramenta de teleporte adicionada à mochila.")
end)

criarFrameConfig("Buscar Servidor Vazio", "Executar", utilsScroll, function()
	setStatus("Buscando servidores vazios...")
	local HttpService = game:GetService("HttpService")
	local TeleportService = game:GetService("TeleportService")

	task.spawn(function()
		pcall(function()
			local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
			local servers = HttpService:JSONDecode(game:HttpGet(url))
			-- Varre a lista de trás para frente buscando menor densidade de jogadores
			for i = #servers.data, 1, -1 do
				local server = servers.data[i]
				if server.playing > 0 and server.playing <= 3 and server.id ~= game.JobId then
					TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
					return
				end
			end
			setStatus("Nenhum servidor vazio encontrado.")
		end)
	end)
end)

local xrayActive = false
local originalTransparencies = {}

criarFrameConfig("Modo Raio-X (X-Ray)", "Desativado", visualScroll, function(btn)
	xrayActive = not xrayActive
	if xrayActive then
		btn.Text = "Ativado"
		btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		setStatus("Modo Raio-X ativo.")

		for _, part in ipairs(Workspace:GetDescendants()) do
			-- Filtra para não alterar a transparência do próprio personagem nem de outros jogadores
			if part:IsA("BasePart") and not part:IsDescendantOf(LocalPlayer.Character) and not part.Parent:FindFirstChildOfClass("Humanoid") then
				originalTransparencies[part] = part.Transparency
				part.Transparency = 0.5
			end
		end
	else
		btn.Text = "Desativado"
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		setStatus("Modo Raio-X desativado.")

		-- Restaura o estado de transparência original do cenário
		for part, trans in pairs(originalTransparencies) do
			if part and part.Parent then
				part.Transparency = trans
			end
		end
		originalTransparencies = {}
	end
end)

local originalGravity = Workspace.Gravity

criarFrameConfig("Gravidade de Lua (Baixa)", "Desativado", moveScroll, function(btn)
	if Workspace.Gravity == originalGravity then
		Workspace.Gravity = 30 -- Ajusta a gravidade local para o nível da lua (padrão é 196.2)
		btn.Text = "Ativado"
		btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		setStatus("Gravidade local reduzida.")
	else
		Workspace.Gravity = originalGravity
		btn.Text = "Desativado"
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		setStatus("Gravidade padrão restaurada.")
	end
end)

local infiniteZoomActive = false
local originalMaxZoom = LocalPlayer.CameraMaxZoomDistance

criarFrameConfig("Distanciamento de Zoom Livre", "Desativado", utilsScroll, function(btn)
	infiniteZoomActive = not infiniteZoomActive
	if infiniteZoomActive then
		btn.Text = "Ativado"
		btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		setStatus("Zoom máximo destravado.")

		LocalPlayer.CameraMaxZoomDistance = 999999 -- Define distância quase infinita de zoom
	else
		btn.Text = "Desativado"
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		setStatus("Zoom original restaurado.")

		LocalPlayer.CameraMaxZoomDistance = originalMaxZoom
	end
end)

local nameTagsActive = false

local function criarTag(player)
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

	-- Loop para atualizar distância e vida em tempo real
	task.spawn(function()
		while nameTagsActive and billboard and billboard.Parent do
			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local myChar = LocalPlayer.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
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

criarFrameConfig("Mostrar Tags de Nome (ESP)", "Desativado", visualScroll, function(btn)
	nameTagsActive = not nameTagsActive
	if nameTagsActive then
		btn.Text = "Ativado"
		btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		setStatus("Tags de Nome ativadas.")

		for _, player in ipairs(Players:GetPlayers()) do
			criarTag(player)
		end
	else
		btn.Text = "Desativado"
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		setStatus("Tags de Nome desativadas.")
		nameTagsActive = false

		-- Limpa as tags existentes
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character then
				local head = player.Character:FindFirstChild("Head")
				local tag = head and head:FindFirstChild("SpiderNameTag")
				if tag then tag:Destroy() end
			end
		end
	end
end)

local antiVoidActive = false
local lastSafeCFrame = CFrame.new(0, 50, 0)
local antiVoidConnection

criarFrameConfig("Salva-Vidas (Anti-Void)", "Desativado", moveScroll, function(btn)
	antiVoidActive = not antiVoidActive
	if antiVoidActive then
		btn.Text = "Ativado"
		btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		setStatus("Anti-Void ativado.")

		antiVoidConnection = RunService.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root then
				-- Se estiver em uma posição segura de altura, salva o CFrame
				if root.Position.Y > -50 then
					lastSafeCFrame = root.CFrame
				else
					-- Se cair abaixo de -100Y, restaura a última posição segura
					if root.Position.Y < -100 then
						root.Velocity = Vector3.zero
						root.CFrame = lastSafeCFrame + Vector3.new(0, 5, 0)
						setStatus("Resgatado do vácuo.")
					end
				end
			end
		end)
	else
		btn.Text = "Desativado"
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		setStatus("Anti-Void desativado.")
		if antiVoidConnection then
			antiVoidConnection:Disconnect()
			antiVoidConnection = nil
		end
	end
end)

local mouseUnlockActive = false
local mouseUnlockConnection
local mouseUnlockBtn = nil -- Armazena a referência para atualizar a interface caso use o atalho

local function toggleMouseUnlock()
	mouseUnlockActive = not mouseUnlockActive
	if mouseUnlockActive then
		if mouseUnlockBtn then
			mouseUnlockBtn.Text = "Ativado"
			mouseUnlockBtn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
			mouseUnlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			local btnStroke = mouseUnlockBtn:FindFirstChildOfClass("UIStroke")
			if btnStroke then btnStroke.Color = Color3.fromRGB(150, 70, 230) end
		end
		setStatus("Cursor destravado.")

		-- Garante comportamento do cursor livre
		mouseUnlockConnection = RunService.RenderStepped:Connect(function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end)
	else
		if mouseUnlockBtn then
			mouseUnlockBtn.Text = "Desativado"
			mouseUnlockBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
			mouseUnlockBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
			local btnStroke = mouseUnlockBtn:FindFirstChildOfClass("UIStroke")
			if btnStroke then btnStroke.Color = Color3.fromRGB(45, 45, 55) end
		end
		setStatus("Cursor restaurado.")

		if mouseUnlockConnection then
			mouseUnlockConnection:Disconnect()
			mouseUnlockConnection = nil
		end
	end
end

-- Criação da opção no menu de configurações
criarFrameConfig("Destravar Cursor (Mouse Unlock) [Alt]", "Desativado", utilsScroll, function(btn)
	mouseUnlockBtn = btn -- Salva a referência do botão criado
	toggleMouseUnlock()
end)

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

criarFrameConfig("Mostrar Nomes de Itens (ESP)", "Desativado", itemScroll, function(btn)
	itemEspActive = not itemEspActive
	if itemEspActive then
		btn.Text = "Ativado"
		btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		setStatus("ESP de itens ativo.")

		-- Aplica nos itens que já existem no mapa
		for _, descendant in ipairs(Workspace:GetDescendants()) do
			aplicarItemESP(descendant)
		end
	else
		btn.Text = "Desativado"
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		setStatus("ESP de itens inativo.")

		-- Remove os marcadores de itens
		for _, descendant in ipairs(Workspace:GetDescendants()) do
			if descendant:IsA("BillboardGui") and descendant.Name == "ItemESP_Tag" then
				descendant:Destroy()
			end
		end
	end
end)

local glideActive = false
local glideConnection

criarFrameConfig("Deslizar no Ar (Glide)", "Desativado", moveScroll, function(btn)
	glideActive = not glideActive
	if glideActive then
		btn.Text = "Ativado"
		btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		setStatus("Modo Planador Ativado.")

		glideConnection = RunService.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")

			-- Se estiver caindo e segurando Espaço, suaviza a velocidade vertical
			if root and hum and hum:GetState() == Enum.HumanoidStateType.Freefall then
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
					-- Limita a queda para uma velocidade constante e suave para baixo (-5)
					if root.Velocity.Y < -5 then
						root.Velocity = Vector3.new(root.Velocity.X, -5, root.Velocity.Z)
					end
				end
			end
		end)
	else
		btn.Text = "Desativado"
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		setStatus("Modo Planador Desativado.")
		if glideConnection then
			glideConnection:Disconnect()
			glideConnection = nil
		end
	end
end)

utilsScroll.CanvasSize = UDim2.new(0, 0, 0, utilsScrollLayout.AbsoluteContentSize.Y + 15)
