-- HealthBar + DamageOverlay + Outline 
-- LocalScript: place in StarterPlayerScripts

local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players      = game:GetService("Players")
local CoreGui      = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- CONFIG
local NORMAL_TWEEN_TIME    = 0.25
local SPAWN_TWEEN_TIME     = 5
local FLASH_TO_FULL_TIME   = 0.12
local FLASH_BACK_TIME      = 0.28
local LOWHEALTH_TWEEN_TIME = 0.18
local OVERLAY_IMAGE_ASSET  = "rbxassetid://114133350704123"
local FORCE_FULL_ON_SPAWN  = true

-- STATE
local Fill = nil
local humanoid = nil
local currentFillTween = nil
local overlayGui = nil
local overlayImage = nil
local overlayTween = nil
local currentTweenTime = NORMAL_TWEEN_TIME

-- safe cancel
local function safeCancel(tw)
	if not tw then return end
	pcall(function()
		if type(tw.Cancel) == "function" then
			tw:Cancel()
		elseif type(tw.Stop) == "function" then
			tw:Stop()
		end
	end)
end

-- robust finder for Fill
local function findFill()
	local ok, res = pcall(function()
		local top = CoreGui:FindFirstChild("TopBarApp")
		if not top then return nil end
		local nested = top:FindFirstChild("TopBarApp")
		if not nested then return nil end
		local uni = nested:FindFirstChild("UnibarLeftFrame")
		if not uni then return nil end
		local hb = uni:FindFirstChild("HealthBar")
		if not hb then return nil end
		local inner = hb:FindFirstChild("HealthBar")
		if not inner then return nil end
		return inner:FindFirstChild("Fill")
	end)
	if ok and res and res:IsA("GuiObject") then
		return res
	end
	return nil
end

-- ensure Outline
local function ensureOutline()
	local ok, inner = pcall(function()
		return CoreGui:WaitForChild("TopBarApp"):WaitForChild("TopBarApp")
			:WaitForChild("UnibarLeftFrame"):WaitForChild("HealthBar"):WaitForChild("HealthBar")
	end)
	if not ok or not inner then return end
	if not inner:FindFirstChild("Outline") then
		local outline = Instance.new("Frame")
		outline.Name = "Outline"
		outline.Size = UDim2.new(0.98, 0, 0.7, 0)
		outline.Position = UDim2.new(0.01, 0, 0.15, 0)
		outline.BackgroundTransparency = 1
		outline.Parent = inner

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = outline

		local stroke = Instance.new("UIStroke")
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Color = Color3.fromRGB(0, 0, 0)
		stroke.Thickness = 1.8
		stroke.Parent = outline
	end
end

-- overlay ensure/create
local function ensureOverlay()
	if overlayGui and overlayImage then return end
	local existing = CoreGui:FindFirstChild("DamageOverlay")
	if existing and existing:IsA("ScreenGui") then
		overlayGui = existing
		overlayImage = overlayGui:FindFirstChild("OverlayImage")
	end
	if not overlayGui then
		overlayGui = Instance.new("ScreenGui")
		overlayGui.Name = "DamageOverlay"
		overlayGui.ResetOnSpawn = false
		overlayGui.Parent = CoreGui
	end
	if not overlayImage then
		local ima = Instance.new("ImageLabel")
		ima.Name = "OverlayImage"
		ima.Size = UDim2.new(1,0,1,0)
		ima.BackgroundTransparency = 1
		ima.Image = OVERLAY_IMAGE_ASSET
		ima.ImageTransparency = 1
		ima.ZIndex = 100
		ima.Parent = overlayGui
		overlayImage = ima
	else
		pcall(function() overlayImage.ImageTransparency = overlayImage.ImageTransparency or 1 end)
	end
	pcall(function() overlayGui.Enabled = true end)
end

-- tween overlay
local function tweenOverlayTo(target, timeSec)
	if not overlayImage then return end
	if overlayTween then safeCancel(overlayTween); overlayTween = nil end
	pcall(function()
		local ti = TweenInfo.new(timeSec or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		overlayTween = TweenService:Create(overlayImage, ti, { ImageTransparency = math.clamp(target, 0, 1) })
		overlayTween:Play()
	end)
end

-- overlay flashing/lowhealth
local function onDamageTriggered(newPercent)
	ensureOverlay()
	local rt = math.clamp(newPercent / 0.5, 0, 1)
	if overlayTween then safeCancel(overlayTween); overlayTween = nil end
	tweenOverlayTo(rt, FLASH_TO_FULL_TIME)
	if newPercent >= 0.5 then
		task.delay(FLASH_TO_FULL_TIME, function()
			local nowP = 1
			pcall(function()
				if humanoid and humanoid.MaxHealth > 0 then
					nowP = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
				end
			end)
			if nowP < 0.5 then
				tweenOverlayTo(math.clamp(nowP / 0.5, 0, 1), LOWHEALTH_TWEEN_TIME)
			else
				tweenOverlayTo(1, FLASH_BACK_TIME)
			end
		end)
	end
end

-- tween Fill smoothly
local function tweenFillTo(percent)
	if not Fill or not Fill:IsA("GuiObject") then return end
	percent = math.clamp(percent or 0, 0, 1)
	local cur = 0
	pcall(function() cur = (Fill.Size and Fill.Size.X.Scale) or 0 end)
	if math.abs(cur - percent) < 0.001 then return end
	if currentFillTween then safeCancel(currentFillTween) end
	pcall(function()
		local ti = TweenInfo.new(currentTweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		currentFillTween = TweenService:Create(Fill, ti, { Size = UDim2.new(percent, 0, 1, 0) })
		currentFillTween.Completed:Connect(function() currentFillTween = nil end)
		currentFillTween:Play()
	end)
end

-- spawn tween
local function spawnFillTweenOnce()
	if not Fill then return end
	pcall(function() Fill.Size = UDim2.new(0,0,1,0) end)
	currentTweenTime = SPAWN_TWEEN_TIME
	local ok, tw = pcall(function()
		return TweenService:Create(Fill, TweenInfo.new(SPAWN_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Size = UDim2.new(1, 0, 1, 0) })
	end)
	if ok and tw then
		tw.Completed:Connect(function() currentTweenTime = NORMAL_TWEEN_TIME end)
		tw:Play()
	end
end

-- setup humanoid signals
local function connectHumanoid(h)
	if not h then return end
	humanoid = h
	local lastHealth = humanoid.Health
	ensureOverlay()
	local initP = math.clamp(h.Health / h.MaxHealth, 0, 1)
	if initP < 0.5 then
		tweenOverlayTo(math.clamp(initP / 0.5, 0, 1), LOWHEALTH_TWEEN_TIME)
	else
		tweenOverlayTo(1, LOWHEALTH_TWEEN_TIME)
	end
	h:GetPropertyChangedSignal("Health"):Connect(function()
		if not Fill then return end
		local percent = math.clamp(h.Health / h.MaxHealth, 0, 1)
		if lastHealth > h.Health then
			onDamageTriggered(percent)
		else
			if percent < 0.5 then
				tweenOverlayTo(math.clamp(percent / 0.5, 0, 1), LOWHEALTH_TWEEN_TIME)
			else
				tweenOverlayTo(1, LOWHEALTH_TWEEN_TIME)
			end
		end
		tweenFillTo(percent)
		lastHealth = h.Health
	end)
end

-- monitor fill + outline
RunService.Heartbeat:Connect(function()
	if not Fill then
		local f = findFill()
		if f then Fill = f; ensureOutline(); if FORCE_FULL_ON_SPAWN then spawnFillTweenOnce() end end
	else
		if not Fill.Parent then Fill = nil end
	end
end)

-- on character
local function onCharacterAdded(char)
	task.defer(function()
		local h = char:WaitForChild("Humanoid", 5)
		if not h then return end
		connectHumanoid(h)
	end)
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character and player.Character:FindFirstChild("Humanoid") then
	onCharacterAdded(player.Character)
end
