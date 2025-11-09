-- LocalScript: HealthBar + DamageOverlay (แก้ไขเพื่อให้ Fill tween ทำงาน)
-- วางใน StarterPlayerScripts (LocalScript)
-- Fixed

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- ========== CONFIG ==========
local FORCE_FULL_ON_SPAWN = true          -- ถาต้องการ tween จาก 0->1 ตอนเกิดใหม่ ให้ true
local SPAWN_FILL_TIME = 3.5               -- เวลา tween ตอนเกิดใหม่ (0 -> 1)
local FILL_TWEEN_TIME = 0.35              -- เวลา tween เมื่อเปลี่ยนเลือดปกติ
local UICORNER_RADIUS = UDim.new(1, 0)
local HEALTHBAR_IMAGE_TRANSPARENCY = 1
local OVERLAY_IMAGE_ASSET = "rbxassetid://114133350704123"
local OVERLAY_DEFAULT_TRANSPARENCY = 1
local FLASH_HIGHHEALTH_TARGET = 0         -- target transparency when flashing (>=50%)
local FLASH_TO_FULL_TIME = 0.12
local FLASH_BACK_TIME = 0.28
local LOWHEALTH_TWEEN_TIME = 0.18

-- ========== STATE ==========
local innerHealthBar = nil   -- inner GUI
local Fill = nil             -- Fill inside inner
local humanoid = nil
local currentFillTween = nil
local overlayGui = nil
local overlayImage = nil
local overlayTween = nil

-- Helper: safe find inner healthbar and fill
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

-- Ensure UICorner on inner healthbar
local function ensureUICorner(target)
	if not target or not target:IsA("GuiObject") then return end
	local existing = target:FindFirstChildOfClass("UICorner")
	if existing then
		pcall(function() existing.CornerRadius = UICORNER_RADIUS end)
	else
		pcall(function()
			local uc = Instance.new("UICorner")
			uc.CornerRadius = UICORNER_RADIUS
			uc.Parent = target
		end)
	end
end

-- Ensure ImageTransparency only on inner healthbar
local function ensureHealthBarTransparency(gui)
	if not gui or not gui:IsA("GuiObject") then return end
	if gui:IsA("ImageLabel") or gui:IsA("ImageButton") then
		pcall(function() gui.ImageTransparency = HEALTHBAR_IMAGE_TRANSPARENCY end)
	end
end

-- safe cancel helper
local function safeCancelTween(tw)
	if not tw then return end
	pcall(function()
		if tw.PlaybackState then
			-- Use Cancel if available (robust)
			if type(tw.Cancel) == "function" then
				tw:Cancel()
			end
		else
			-- nothing
		end
	end)
end

-- Tween Fill to percent (with safe cancel + completed handler)
local function tweenFill(percent)
	if not Fill or not Fill:IsA("GuiObject") then return end
	percent = math.clamp(percent or 0, 0, 1)

	-- get current scale (safe)
	local curScale = 0
	pcall(function() curScale = Fill.Size.X.Scale or 0 end)
	-- if already extremely close -> do nothing
	if math.abs(curScale - percent) < 0.001 then
		return
	end

	-- cancel existing tween safely
	if currentFillTween then
		safeCancelTween(currentFillTween)
		currentFillTween = nil
	end

	-- create tween
	local ok, tw = pcall(function()
		local ti = TweenInfo.new(FILL_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		return TweenService:Create(Fill, ti, { Size = UDim2.new(percent, 0, 1, 0) })
	end)
	if not ok or not tw then return end

	currentFillTween = tw
	-- ensure we clear reference when finished
	tw.Completed:Connect(function(status)
		-- status is Enum.PlaybackState.Completed or Cancelled - clear ref either way
		currentFillTween = nil
	end)
	tw:Play()
end

-- Create or reuse DamageOverlay in CoreGui
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

-- Cancel and create overlay tween safely
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

-- Called when damage occurs; newPercent in [0,1]
local function onDamageTriggered(newPercent)
	if not overlayImage then return end
	if newPercent < 0.5 then
		local mapped = math.clamp(newPercent / 0.5, 0, 1)
		tweenOverlayTo(mapped, LOWHEALTH_TWEEN_TIME)
	else
		-- flash from 1 -> RT (where RT = real transparency)
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

-- Apply fixes to inner + fill + overlay (do NOT force-set fill to full here)
local function applyAllFixes()
	local inner, fill = findInnerAndFill()
	innerHealthBar = inner
	Fill = fill

	if innerHealthBar and innerHealthBar:IsA("GuiObject") then
		ensureUICorner(innerHealthBar)
		ensureHealthBarTransparency(innerHealthBar)
	end

	-- if Fill exists, ensure it's a GuiObject. Do NOT immediately set to full
	-- we'll handle spawn animation separately to avoid race conditions
	-- but ensure Fill.Size is valid (if nil, set to percent=1 safe)
	if Fill and Fill:IsA("GuiObject") then
		-- nothing that overrides tween here
	end

	-- ensure overlay exists
	if not overlayGui or not overlayImage then
		setupOverlay()
	end
end

-- Setup humanoid: health tracking + damage detection
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
		-- ensure Fill exists
		if not Fill then
			applyAllFixes()
		end

		local percent = 1
		if humanoid.MaxHealth and humanoid.MaxHealth > 0 then
			percent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
		end

		-- damage detection
		if lastHealth and humanoid.Health < lastHealth then
			onDamageTriggered(percent)
		else
			-- healed or unchanged: keep overlay in correct state if below 50%
			if percent < 0.5 then
				local mapped = math.clamp(percent / 0.5, 0, 1)
				tweenOverlayTo(mapped, LOWHEALTH_TWEEN_TIME)
			else
				tweenOverlayTo(1, LOWHEALTH_TWEEN_TIME)
			end
		end

		-- update fill tween
		tweenFill(percent)

		lastHealth = humanoid.Health
	end)
end

-- Init: CharacterAdded + existing character
Players.LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.08)
	local ok, h = pcall(function() return char:WaitForChild("Humanoid", 5) end)
	if ok and h then setupHumanoid(h) end
	applyAllFixes()
end)

if Players.LocalPlayer.Character then
	local h = Players.LocalPlayer.Character:FindFirstChild("Humanoid")
	if h then setupHumanoid(h) end
	applyAllFixes()
end

-- Monitor TopBar / Fill recreation (respawn or core gui change)
local checkTimer = 0
RunService.RenderStepped:Connect(function(dt)
	checkTimer = checkTimer + dt
	if checkTimer < 0.2 then return end
	checkTimer = 0
	local inner, fill = findInnerAndFill()
	if inner ~= innerHealthBar or fill ~= Fill then
		applyAllFixes()
	end
end)

-- Outline สำหรับ HealthBar (unchanged)
local healthBarParentOK, healthBarParent = pcall(function()
	return CoreGui:WaitForChild("TopBarApp"):WaitForChild("TopBarApp")
		:WaitForChild("UnibarLeftFrame"):WaitForChild("HealthBar"):WaitForChild("HealthBar")
end)
if healthBarParentOK and healthBarParent and not healthBarParent:FindFirstChild("Outline") then
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

-- --- Respawn spawn-tween: ถ้าต้องการให้เกิด tween จาก 0->1 ตอนเกิดใหม่ ให้ใช้โค้ดนี้ (รวมในสคริปต์เดียว)
-- ถูกเรียกเมื่อ CharacterAdded (หลัง applyAllFixes)
local function spawnFillTweenOnce()
	-- small delay to allow TopBar to create widgets
	task.wait(0.9) -- รอให้ UI สร้างก่อน
	local inner, fill = findInnerAndFill()
	if not fill or not fill:IsA("GuiObject") then return end
	-- Start from zero width (do a direct set once) then tween to full
	pcall(function() fill.Size = UDim2.new(0, 0, 1, 0) end)
	-- cancel any existing tween
	if currentFillTween then safeCancelTween(currentFillTween); currentFillTween = nil end
	pcall(function()
		local ti = TweenInfo.new(SPAWN_FILL_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		currentFillTween = TweenService:Create(fill, ti, { Size = UDim2.new(1, 0, 1, 0) })
		currentFillTween.Completed:Connect(function() currentFillTween = nil end)
		currentFillTween:Play()
	end)
end

-- Hook respawn spawn tween if desired
if FORCE_FULL_ON_SPAWN then
	Players.LocalPlayer.CharacterAdded:Connect(function(char)
		-- wait until humanoid is alive
		task.defer(function()
			local ok, h = pcall(function() return char:WaitForChild("Humanoid", 5) end)
			if ok and h then
				while h.Health <= 0 do task.wait(0.05) end
				spawnFillTweenOnce()
			end
		end)
	end)
	-- if already alive at script start, run once
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		spawnFillTweenOnce()
	end
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/loadstring/TweenHealth-Small.lua"))()
