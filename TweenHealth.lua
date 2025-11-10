-- TweenHealth.lua (complete) 
-- LocalScript to place in StarterPlayerScripts
-- Features:
--  - Smart tween Fill.Size when health changes or core UI sets size
--  - Spawn tween 0 -> 1 for SPAWN_FILL_TIME seconds (default 5s)
--  - Normal health tweens use FILL_TWEEN_TIME (default 0.25s)
--  - Damage overlay behavior (flash for >=50%, mapped fade for <50%)
--  - Watches CoreGui TopBar re-creation and re-attaches watcher
--  - Adds simple Outline frame once
--  - Robust against fast/overlapping size changes

local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")
local Players       = game:GetService("Players")
local CoreGui       = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- ========== CONFIG ==========
local FORCE_FULL_ON_SPAWN = true
local SPAWN_FILL_TIME = 5.0        -- spawn tween duration (seconds)
local FILL_TWEEN_TIME  = 0.25      -- normal tween duration (seconds)
local UICORNER_RADIUS  = UDim.new(1, 0)
local HEALTHBAR_IMAGE_TRANSPARENCY = 1
local OVERLAY_IMAGE_ASSET = "rbxassetid://114133350704123"
local OVERLAY_DEFAULT_TRANSPARENCY = 1
local FLASH_HIGHHEALTH_TARGET = 0  -- flash to this transparency before backing off
local FLASH_TO_FULL_TIME = 0.12
local FLASH_BACK_TIME = 0.28
local LOWHEALTH_TWEEN_TIME = 0.18

-- ========== STATE ==========
local innerHealthBar = nil
local Fill = nil
local humanoid = nil

-- overlay
local overlayGui = nil
local overlayImage = nil
local overlayTween = nil

-- smart tween state
local currentFillTween = nil
local ignoreSizeChange = false
local SaveValue = nil
local pendingTarget = nil
local tweening = false
local spawnPhase = false

-- helper: safe find inner healthbar and fill
local function findInnerAndFill()
	local topBarApp = CoreGui:FindFirstChild("TopBarApp")
	if not topBarApp then return nil, nil end
	local nested = topBarApp:FindFirstChild("TopBarApp")
	if not nested then return nil, nil end
	local unibar = nested:FindFirstChild("UnibarLeftFrame")
	if not unibar then return nil, nil end
	local healthBar = unibar:FindFirstChild("HealthBar")
	if not healthBar then return nil, nil end
	local inner = healthBar:FindFirstChild("HealthBar")
	if not inner then return nil, nil end
	local fill = inner:FindFirstChild("Fill")
	return inner, fill
end

-- small helpers
local function ensureNumberSave()
	if SaveValue and SaveValue.Parent then return end
	SaveValue = Instance.new("NumberValue")
	SaveValue.Name = "SaveValue"
	SaveValue.Value = 1
	SaveValue.Parent = script
end

local function readFillScale()
	if Fill and Fill:IsA("GuiObject") then
		local ok, s = pcall(function() return Fill.Size.X.Scale end)
		if ok and type(s) == "number" then
			return s
		end
	end
	if SaveValue then return SaveValue.Value end
	return 1
end

local function safeCancel(tw)
	if not tw then return end
	pcall(function() if type(tw.Cancel) == "function" then tw:Cancel() end end)
end

-- smart tween to targetPercent (optional forcedDuration)
local function smartTweenTo(targetPercent, forcedDuration)
	if not targetPercent then return end
	targetPercent = math.clamp(targetPercent, 0, 1)
	ensureNumberSave()

	-- if Fill not ready, just save and return (apply later)
	if not Fill or not Fill:IsA("GuiObject") then
		SaveValue.Value = targetPercent
		pendingTarget = nil
		return
	end

	-- if tweening already, queue pending target
	if tweening then
		pendingTarget = targetPercent
		return
	end

	local cur = readFillScale()
	SaveValue.Value = cur

	if math.abs(cur - targetPercent) < 0.001 then
		SaveValue.Value = targetPercent
		return
	end

	tweening = true
	if currentFillTween then
		safeCancel(currentFillTween)
		currentFillTween = nil
	end

	ignoreSizeChange = true

	local dur
	if forcedDuration and type(forcedDuration) == "number" then
		dur = forcedDuration
	else
		if spawnPhase then
			dur = SPAWN_FILL_TIME
		else
			dur = FILL_TWEEN_TIME
		end
	end

	local ok, tw = pcall(function()
		return TweenService:Create(Fill, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(targetPercent, 0, 1, 0)
		})
	end)
	if not ok or not tw then
		pcall(function() Fill.Size = UDim2.new(targetPercent, 0, 1, 0) end)
		SaveValue.Value = targetPercent
		ignoreSizeChange = false
		tweening = false
		if pendingTarget and math.abs(pendingTarget - targetPercent) > 0.001 then
			local next = pendingTarget; pendingTarget = nil
			spawnPhase = false
			smartTweenTo(next)
		end
		return
	end

	currentFillTween = tw
	tw:Play()

	-- completion
	spawn(function()
		tw.Completed:Wait()
		SaveValue.Value = targetPercent
		currentFillTween = nil
		ignoreSizeChange = false
		tweening = false
		-- handle pending
		if pendingTarget and math.abs(pendingTarget - targetPercent) > 0.001 then
			local next = pendingTarget; pendingTarget = nil
			spawnPhase = false
			smartTweenTo(next)
		end
	end)
end

-- watcher attach: detect external Size changes and tween instead
local sizeWatcherConn = nil
local function attachFillWatcher()
	if not Fill or not Fill:IsA("GuiObject") then return end
	if sizeWatcherConn then return end

	ensureNumberSave()
	SaveValue.Value = readFillScale()

	sizeWatcherConn = Fill:GetPropertyChangedSignal("Size"):Connect(function()
		if ignoreSizeChange then return end
		local ok, newScale = pcall(function() return Fill.Size.X.Scale end)
		if not ok or type(newScale) ~= "number" then return end

		local prev = SaveValue and SaveValue.Value or newScale
		if math.abs(prev - newScale) < 0.001 then
			SaveValue.Value = newScale
			return
		end

		-- revert instantly to previous then tween
		ignoreSizeChange = true
		pcall(function() Fill.Size = UDim2.new(prev, 0, 1, 0) end)
		-- schedule tween
		task.defer(function()
			ignoreSizeChange = false
			spawnPhase = false
			smartTweenTo(newScale, FILL_TWEEN_TIME)
		end)
	end)
end

local function detachFillWatcher()
	if sizeWatcherConn then
		pcall(function() sizeWatcherConn:Disconnect() end)
		sizeWatcherConn = nil
	end
end

-- Overlay setup and tween
local function setupOverlay()
	local existing = CoreGui:FindFirstChild("DamageOverlay")
	if existing and existing:IsA("ScreenGui") then
		overlayGui = existing
		overlayImage = overlayGui:FindFirstChild("OverlayImage") or overlayGui:FindFirstChildOfClass("ImageLabel") or overlayGui:FindFirstChildOfClass("ImageButton")
	else
		overlayGui = Instance.new("ScreenGui")
		overlayGui.Name = "DamageOverlay"
		overlayGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
		overlayGui.Enabled = true
		overlayGui.Parent = CoreGui
		overlayImage = nil
	end

	if not overlayImage then
		local ima = Instance.new("ImageLabel")
		ima.Name = "OverlayImage"
		ima.Size = UDim2.new(1, 0, 1, 0)
		ima.BackgroundTransparency = 1
		ima.Image = OVERLAY_IMAGE_ASSET
		ima.Active = false
		ima.ImageTransparency = OVERLAY_DEFAULT_TRANSPARENCY
		ima.ZIndex = 100
		ima.Parent = overlayGui
		overlayImage = ima
	else
		pcall(function()
			overlayImage.ImageTransparency = OVERLAY_DEFAULT_TRANSPARENCY
			overlayImage.ZIndex = overlayImage.ZIndex or 100
			overlayImage.Visible = true
		end)
		pcall(function() overlayGui.Enabled = true end)
	end
end

local function tweenOverlayTo(targetTransparency, timeSec)
	if not overlayImage then return end
	if overlayTween then
		pcall(function() overlayTween:Cancel() end)
		overlayTween = nil
	end
	pcall(function()
		local ti = TweenInfo.new(timeSec or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		overlayTween = TweenService:Create(overlayImage, ti, { ImageTransparency = math.clamp(targetTransparency, 0, 1) })
		overlayTween:Play()
	end)
end

local function onDamageTriggered(newPercent)
	if not overlayImage then return end
	if newPercent < 0.5 then
		local mapped = math.clamp(newPercent / 0.5, 0, 1)
		tweenOverlayTo(mapped, LOWHEALTH_TWEEN_TIME)
	else
		-- flash to FLASH_HIGHHEALTH_TARGET then go toward real transparency
		tweenOverlayTo(FLASH_HIGHHEALTH_TARGET, FLASH_TO_FULL_TIME)
		coroutine.wrap(function()
			wait(FLASH_TO_FULL_TIME)
			local nowPercent = 1
			if humanoid and humanoid.MaxHealth and humanoid.MaxHealth > 0 then
				nowPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
			end
			if nowPercent < 0.5 then
				local mapped = math.clamp(nowPercent / 0.5, 0, 1)
				tweenOverlayTo(mapped, LOWHEALTH_TWEEN_TIME)
			else
				tweenOverlayTo(1, FLASH_BACK_TIME)
			end
		end)()
	end
end

-- Apply fixes to inner + fill + overlay
local function applyAllFixes()
	local inner, fill = findInnerAndFill()
	innerHealthBar = inner
	Fill = fill

	if innerHealthBar and innerHealthBar:IsA("GuiObject") then
		-- ensure UICorner
		local existing = innerHealthBar:FindFirstChildOfClass("UICorner")
		if existing then
			pcall(function() existing.CornerRadius = UICORNER_RADIUS end)
		else
			pcall(function()
				local uc = Instance.new("UICorner")
				uc.CornerRadius = UICORNER_RADIUS
				uc.Parent = innerHealthBar
			end)
		end
		-- ensure image transparency on inner
		pcall(function() if innerHealthBar:IsA("ImageLabel") or innerHealthBar:IsA("ImageButton") then innerHealthBar.ImageTransparency = HEALTHBAR_IMAGE_TRANSPARENCY end end)
	end

	if Fill and Fill:IsA("GuiObject") then
		attachFillWatcher()
	end

	if not overlayGui or not overlayImage then
		setupOverlay()
	end
end

-- Setup humanoid: track health, call smartTweenTo on changes
local function setupHumanoid(h)
	if not h then return end
	humanoid = h
	local lastHealth = humanoid.Health

	-- initial overlay state
	if overlayImage then
		local initPercent = 1
		if humanoid.MaxHealth and humanoid.MaxHealth > 0 then
			initPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
		end
		if initPercent < 0.5 then
			local mapped = math.clamp(initPercent / 0.5, 0, 1)
			pcall(function() overlayImage.ImageTransparency = mapped end)
		else
			pcall(function() overlayImage.ImageTransparency = 1 end)
		end
	end

	humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if not Fill then
			applyAllFixes()
		end

		local percent = 1
		if humanoid.MaxHealth and humanoid.MaxHealth > 0 then
			percent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
		end

		-- damage/regen overlay logic
		if lastHealth and humanoid.Health < lastHealth then
			onDamageTriggered(percent)
		else
			if percent < 0.5 then
				local mapped = math.clamp(percent / 0.5, 0, 1)
				tweenOverlayTo(mapped, LOWHEALTH_TWEEN_TIME)
			else
				tweenOverlayTo(1, LOWHEALTH_TWEEN_TIME)
			end
		end

		-- smart tween fill
		-- If currently in spawnPhase, use SPAWN_FILL_TIME, else normal FILL_TWEEN_TIME
		if spawnPhase then
			smartTweenTo(percent, SPAWN_FILL_TIME)
		else
			smartTweenTo(percent, FILL_TWEEN_TIME)
		end

		lastHealth = humanoid.Health
	end)
end

-- spawn tween: set fill to 0 then tween to 1 using SPAWN_FILL_TIME
local function spawnFillTweenOnce()
	-- small wait to let UI create
	task.wait(0.9)
	local inner, fill = findInnerAndFill()
	if not fill or not fill:IsA("GuiObject") then return end

	-- set 0 instantly (suppress watcher)
	ignoreSizeChange = true
	pcall(function() fill.Size = UDim2.new(0, 0, 1, 0) end)
	ignoreSizeChange = false

	-- set spawnPhase and tween to 1
	spawnPhase = true
	smartTweenTo(1, SPAWN_FILL_TIME)
end

-- Init & hooks
Players.LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.08)
	local ok, h = pcall(function() return char:WaitForChild("Humanoid", 5) end)
	if ok and h then setupHumanoid(h) end
	applyAllFixes()
end)

if player.Character then
	local h = player.Character:FindFirstChild("Humanoid")
	if h then setupHumanoid(h) end
	applyAllFixes()
end

-- spawn tween on respawn if enabled
if FORCE_FULL_ON_SPAWN then
	Players.LocalPlayer.CharacterAdded:Connect(function(char)
		task.defer(function()
			local ok, h = pcall(function() return char:WaitForChild("Humanoid", 5) end)
			if ok and h then
				while h.Health <= 0 do task.wait(0.05) end
				spawnFillTweenOnce()
			end
		end)
	end)
	-- if alive at start
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		spawnFillTweenOnce()
	end
end

-- Monitor TopBar / Fill recreation and re-attach watcher
local checkTimer = 0
RunService.RenderStepped:Connect(function(dt)
	checkTimer = checkTimer + dt
	if checkTimer < 0.2 then return end
	checkTimer = 0
	local inner, fill = findInnerAndFill()
	if inner ~= innerHealthBar or fill ~= Fill then
		-- detach old watcher and reapply
		detachFillWatcher()
		applyAllFixes()
	end
end)

-- Outline for HealthBar (create once safely)
local okHB, healthBarParent = pcall(function()
	return CoreGui:WaitForChild("TopBarApp"):WaitForChild("TopBarApp")
		:WaitForChild("UnibarLeftFrame"):WaitForChild("HealthBar"):WaitForChild("HealthBar")
end)
if okHB and healthBarParent and not healthBarParent:FindFirstChild("Outline") then
	local outline = Instance.new("Frame")
	outline.Name = "Outline"
	outline.Size = UDim2.new(0.98, 0, 0.7, 0)
	outline.Position = UDim2.new(0.01, 0, 0.15, 0)
	outline.BackgroundTransparency = 1
	outline.Parent = healthBarParent

	local uicorner = Instance.new("UICorner")
	uicorner.CornerRadius = UDim.new(1, 0)
	uicorner.Parent = outline

	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Thickness = 1.8
	stroke.Parent = outline
end

-- Done
