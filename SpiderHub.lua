-- ==========================================
-- MONTAGEM DOS CONTEÚDOS DAS ABAS DA UI
-- ==========================================

-- ABA: INÍCIO
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
	descLabel.Text = "Este painel unifica as melhores ferramentas do Koala Scripts para Flee The Facility de forma otimizada e limpa.\n\nAtalhos do Teclado:\n[P] Ativar/Desativar Voo (Fly)\n[N] Ativar/Desativar Noclip\n[Alt] Destravar Cursor"
	descLabel.TextColor3 = Color3.fromRGB(170, 170, 180)
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 12
	descLabel.TextWrapped = true
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.Parent = homePage
end

-- ABA: MOVIMENTAÇÃO
do
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

	-- WalkSpeed Configs
	criarFrameConfig("Habilitar WalkSpeed Hack", "Desativado", moveScroll, function(btn)
		speedHackEnabled = not speedHackEnabled
		btn.Text = speedHackEnabled and "Ativado" or "Desativado"
		btn.BackgroundColor3 = speedHackEnabled and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
		if not speedHackEnabled then
			local _, _, humanoid = GetCharacter()
			if humanoid then humanoid.WalkSpeed = 16 end
		end
	end)

	criarSliderConfig("Ajustar WalkSpeed", "Velocidade de corrida.", 16, 120, 16, moveScroll, function(val)
		speedHackValue = val
	end)

	-- JumpPower Configs
	criarFrameConfig("Habilitar JumpPower Hack", "Desativado", moveScroll, function(btn)
		jumpHackEnabled = not jumpHackEnabled
		btn.Text = jumpHackEnabled and "Ativado" or "Desativado"
		btn.BackgroundColor3 = jumpHackEnabled and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
		if not jumpHackEnabled then
			local _, _, humanoid = GetCharacter()
			if humanoid then humanoid.JumpPower = 36 end
		end
	end)

	criarSliderConfig("Ajustar JumpPower", "Altura de salto.", 36, 250, 36, moveScroll, function(val)
		jumpHackValue = val
	end)

	-- Jump Infinito Toggle
	criarFrameConfig("Habilitar Pulo Infinito", "Desativado", moveScroll, function(btn)
		infiniteJumpActive = not infiniteJumpActive
		btn.Text = infiniteJumpActive and "Ativado" or "Desativado"
		btn.BackgroundColor3 = infiniteJumpActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	end)

	-- Fly Toggle
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

	flyBtn = Instance.new("TextButton")
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

	-- Noclip Toggle
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

	noclipBtn = Instance.new("TextButton")
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
end

-- ABA: VISUAL (ESPs E MODIFICADORES)
do
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

	-- ESP Computadores Dinâmico
	criarFrameConfig("ESP Computadores Dinâmico", "Desativado", visualScroll, function(btn)
		ComputerTableESPActive = not ComputerTableESPActive
		btn.Text = ComputerTableESPActive and "Ativado" or "Desativado"
		btn.BackgroundColor3 = ComputerTableESPActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
		atualizarComputerTableESP()
	end)

	-- ESP Portas de Saída
	criarFrameConfig("ESP Portas de Saída", "Desativado", visualScroll, function(btn)
		exitDoorESPActive = not exitDoorESPActive
		btn.Text = exitDoorESPActive and "Ativado" or "Desativado"
		btn.BackgroundColor3 = exitDoorESPActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
		atualizarExitESP()
	end)

	-- ESP Armários (Lockers)
	criarFrameConfig("ESP Armários (Lockers)", "Desativado", visualScroll, function(btn)
		LockerESPActive = not LockerESPActive
		btn.Text = LockerESPActive and "Ativado" or "Desativado"
		btn.BackgroundColor3 = LockerESPActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
		atualizarLockerESP()
	end)

	-- ESP Tubulações (Vents)
	criarFrameConfig("ESP Tubulações (Vents)", "Desativado", visualScroll, function(btn)
		VentESPActive = not VentESPActive
		btn.Text = VentESPActive and "Ativado" or "Desativado"
		btn.BackgroundColor3 = VentESPActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
		atualizarVentESP()
	end)

	-- ESP Células (FreezePods)
	criarFrameConfig("Habilitar ESP (FreezePod)", "Desativado", visualScroll, function(btn)
		FreezePodESPActive = not FreezePodESPActive
		btn.Text = FreezePodESPActive and "Ativado" or "Desativado"
		btn.BackgroundColor3 = FreezePodESPActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
		atualizarFreezePodESP()
	end)

	-- Mostrar Progresso Ragdoll de Caídos
	criarFrameConfig("Mostrar Progresso Ragdoll", "Desativado", visualScroll, function(btn)
		showPlrRagTimeActive = not showPlrRagTimeActive
		btn.Text = showPlrRagTimeActive and "Ativado" or "Desativado"
		btn.BackgroundColor3 = showPlrRagTimeActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
	end)

	-- ESP Chams de Cores (Beast / Survivors)
	local chamsFrame = Instance.new("Frame")
	chamsFrame.Size = UDim2.new(1, -10, 0, 45)
	chamsFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	chamsFrame.BorderSizePixel = 0
	chamsFrame.Parent = visualScroll

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

	chamsBtn = Instance.new("TextButton")
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

	chamsBtn.MouseButton1Click:Connect(toggleChams)

	-- FOV Slider
	criarSliderConfig("Ajustar Campo de Visão (FOV)", "Zoom da câmera do jogo.", 10, 120, 70, visualScroll, function(val)
		Workspace.CurrentCamera.FieldOfView = val
	end)

	-- Fullbright Config
	criarFrameConfig("Brilho Máximo (Fullbright)", "Desativado", visualScroll, function(btn)
		FullbrightActive = not FullbrightActive
		if FullbrightActive then
			btn.Text = "Ativado"
			btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			Lighting.Ambient = Color3.fromRGB(255, 255, 255)
			Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
			Lighting.GlobalShadows = false
		else
			btn.Text = "Desativado"
			btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			Lighting.Ambient = originalAmbient
			Lighting.OutdoorAmbient = originalOutdoor
			Lighting.GlobalShadows = originalShadows
		end
	end)

	-- No Fog Config
	criarFrameConfig("Remover Névoa (No Fog)", "Desativado", visualScroll, function(btn)
		noFogActive = not noFogActive
		if noFogActive then
			btn.Text = "Ativado"
			btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			Lighting.FogStart = 999999
			Lighting.FogEnd = 999999
			if originalAtmosphere then
				originalAtmosphere.Parent = nil
			end
		else
			btn.Text = "Desativado"
			btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			Lighting.FogStart = originalFogStart
			Lighting.FogEnd = originalFogEnd
			if originalAtmosphere then
				originalAtmosphere.Parent = Lighting
			end
		end
	end)

	-- X-Ray Config
	criarFrameConfig("Modo Raio-X (X-Ray)", "Desativado", visualScroll, function(btn)
		xrayActive = not xrayActive
		if xrayActive then
			btn.Text = "Ativado"
			btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			local character, _, _ = GetCharacter()
			for _, part in ipairs(Workspace:GetDescendants()) do
				if part:IsA("BasePart") and not part:IsDescendantOf(character) and not part.Parent:FindFirstChildOfClass("Humanoid") then
					originalTransparencies[part] = part.Transparency
					part.Transparency = 0.5
				end
			end
		else
			btn.Text = "Desativado"
			btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			for part, trans in pairs(originalTransparencies) do
				if part and part.Parent then
					part.Transparency = trans
				end
			end
			originalTransparencies = {}
		end
	end)

	-- Name Tags (ESP) Config
	criarFrameConfig("Mostrar Tags de Nome (ESP)", "Desativado", visualScroll, function(btn)
		nameTagsActive = not nameTagsActive
		if nameTagsActive then
			btn.Text = "Ativado"
			btn.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			for _, player in ipairs(Players:GetPlayers()) do
				criarTag(player)
			end
		else
			btn.Text = "Desativado"
			btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			for _, player in ipairs(Players:GetPlayers()) do
				if player.Character then
					local head = player.Character:FindFirstChild("Head")
					local tag = head and head:FindFirstChild("SpiderNameTag")
					if tag then tag:Destroy() end
				end
			end
		end
	end)

	visualLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		visualScroll.CanvasSize = UDim2.new(0, 0, 0, visualLayout.AbsoluteContentSize.Y + 15)
	end)
end

-- ABA: FLEE THE FACILITY MODS
do
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

	-- 7. Survivor Auto-Farm
	criarFrameConfig("Sobrevivente Auto-Farm", "Desativado", ftfScroll, function(btn)
		survivorAutoFarmActive = not survivorAutoFarmActive
		btn.Text = survivorAutoFarmActive and "Ativado" or "Desativado"
		btn.BackgroundColor3 = survivorAutoFarmActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
		if survivorAutoFarmActive then
			DoSurvivorFarm()
		end
	end)

	-- 8. Beast Auto-Farm
	criarFrameConfig("Fera Auto-Farm", "Desativado", ftfScroll, function(btn)
		beastAutoFarmActive = not beastAutoFarmActive
		btn.Text = beastAutoFarmActive and "Ativado" or "Desativado"
		btn.BackgroundColor3 = beastAutoFarmActive and Color3.fromRGB(130, 50, 200) or Color3.fromRGB(30, 30, 38)
		if beastAutoFarmActive then
			DoBeastFarm()
		end
	end)

	-- Sliders do Auto Farm
	criarSliderConfig("Beast Camp Timeout (PC)", "Segundos limites de camp.", 20, 60, 40, ftfScroll, function(val) campHackOutValue = val end)
	criarSliderConfig("Beast Camp Timeout (Pods)", "Segundos limites de camp.", 20, 60, 40, ftfScroll, function(val) campFreezePodOutValue = val end)
	criarSliderConfig("Tween Speed (Survivor)", "Velocidade em blocos/s.", 10, 30, 16, ftfScroll, function(val) farmTweenSpeedValue = val end)
	criarSliderConfig("Delay de Teleporte (Anti-Cheat)", "Segurança contra detecção.", 5, 20, 12, ftfScroll, function(val) waitTweenFastValue = val end)
end

-- ABA: TROLLING ( Sound board, Slow Beast, Untie All, Fling Beast )
do
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

	-- Lentidão na Fera (Jumped exploit)
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
			
			local originalPos = rootPart.CFrame
			local t = tick()
			while tick() - t < 1.5 do
				RunService.Heartbeat:Wait()
				rootPart.CFrame = bRoot.CFrame * CFrame.new(0, 0, 0.5)
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

	-- Painel Sound board
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
end

-- ==========================================
-- SUB-SISTEMA UTILITÁRIO: GRAVAÇÃO E SESSÃO
-- ==========================================
do
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
end

-- ==========================================
-- GESTÃO DE LOOP DE EXECUÇÃO EM TEMPO REAL E TECLADO
-- ==========================================

RunService.Heartbeat:Connect(function(dt)
	-- 1. Loops de Velocidade e Pulo (WalkSpeed/JumpPower)
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

	-- 3. Terceira Pessoa Fera (Beast 3rd Person camera lock bypass)
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
			if MoneyStats then MoneyStats.Text = "Total Credits: " .. tostring(totalCredits) .. "C" end
			if XPStats then XPStats.Text = "Total XP: " .. tostring(totalXP) .. "XP" end
			if MoneyStatsHour then MoneyStatsHour.Text = "Credits por Hora: " .. tostring(math.ceil(totalCredits / (StatsConfig.Elapsed / 3600))) .. "C/h" end
			if XPStatsHour then XPStatsHour.Text = "XP por Hora: " .. tostring(math.ceil(totalXP / (StatsConfig.Elapsed / 3600))) .. "XP/h" end
			
			local hours = math.floor(StatsConfig.Elapsed / 3600)
			local minutes = math.floor((StatsConfig.Elapsed % 3600) / 60)
			local seconds = math.floor(StatsConfig.Elapsed % 60)
			if RecordElapsed then
				RecordElapsed.Text = string.format("Tempo Decorrido: %d:%02d:%02d", hours, minutes, seconds)
			end
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
