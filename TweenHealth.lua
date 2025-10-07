-- LocalScript: HealthBar + DamageOverlay control
-- วางใน StarterPlayerScripts (LocalScript)

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Settings
local FORCE_FULL_ON_SPAWN = true
local UICORNER_RADIUS = UDim.new(1, 0)
local HEALTHBAR_IMAGE_TRANSPARENCY = 1 -- เฉพาะ HealthBar.HealthBar
local OVERLAY_IMAGE_ASSET = "rbxassetid://89248890386154"
local OVERLAY_DEFAULT_TRANSPARENCY = 1 -- ถ้ต้องการ default เมื่อสร้าง
local FLASH_HIGHHEALTH_TARGET = 0.5 -- target transparency เมื่อเลือด >= 50% (flash to 0.5)
local FLASH_TO_FULL_TIME = 0.12
local FLASH_BACK_TIME = 0.28
local LOWHEALTH_TWEEN_TIME = 0.18 -- tween time when health < 50% (no flashing)

-- Internal
local Fill = nil
local innerHealthBar = nil
local humanoid = nil
local currentTween = nil
local overlayTween = nil
local overlayGui = nil
local overlayImage = nil

-- Helper: safe find inner HealthBar and Fill
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

-- Ensure HealthBar (inner) ImageTransparency only
local function ensureHealthBarTransparency(gui)
	if not gui or not gui:IsA("GuiObject") then return end
	if gui:IsA("ImageLabel") or gui:IsA("ImageButton") then
		pcall(function() gui.ImageTransparency = HEALTHBAR_IMAGE_TRANSPARENCY end)
	end
end

-- Force Fill full size on spawn/detect
local function forceFillFull(fill)
	if not fill or not fill:IsA("GuiObject") then return end
	pcall(function() fill.Size = UDim2.new(1, 0, 1, 0) end)
end

-- Tween Fill to percent (0..1)
local function tweenFill(percent)
	if not Fill or not Fill:IsA("GuiObject") then return end
	if currentTween then
		pcall(function() currentTween:Cancel() end)
	end
	pcall(function()
		local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		currentTween = TweenService:Create(Fill, tweenInfo, { Size = UDim2.new(math.clamp(percent, 0, 1), 0, 1, 0) })
		currentTween:Play()
	end)
end

-- Create or get DamageOverlay under CoreGui
local function setupOverlay()
	-- try find existing ScreenGui named DamageOverlay
	local existing = CoreGui:FindFirstChild("DamageOverlay")
	if existing and existing:IsA("ScreenGui") then
		overlayGui = existing
		overlayImage = overlayGui:FindFirstChildOfClass("ImageLabel") or overlayGui:FindFirstChildOfClass("ImageButton")
		-- if no image, create one
	else
		overlayGui = Instance.new("ScreenGui")
		overlayGui.Name = "DamageOverlay"
		overlayGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
		overlayGui.Parent = CoreGui
		overlayImage = nil
	end

	if not overlayImage then
		local ima = Instance.new("ImageLabel")
		ima.Size = UDim2.new(1, 0, 1, 0)
		ima.BackgroundTransparency = 1
		ima.Image = OVERLAY_IMAGE_ASSET
		ima.Active = false
		ima.ImageTransparency = OVERLAY_DEFAULT_TRANSPARENCY
		ima.Name = "OverlayImage"
		ima.Parent = overlayGui
		overlayImage = ima
	end
end

-- Tween overlay transparency safely (cancel previous tween)
local function tweenOverlayTo(targetTransparency, timeSec)
	if not overlayImage then return end
	if overlayTween then
		pcall(function() overlayTween:Cancel() end)
	end
	pcall(function()
		local ti = TweenInfo.new(timeSec or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		overlayTween = TweenService:Create(overlayImage, ti, { ImageTransparency = math.clamp(targetTransparency, 0, 1) })
		overlayTween:Play()
	end)
end

-- On damage event: decide behavior by newPercent
local function onDamageTriggered(newPercent)
	-- newPercent is in [0,1]
	if not overlayImage then return end

	if newPercent < 0.5 then
		-- Low health: set transparency proportional to percent (no flashing)
		-- mapping: at percent=0.5 -> transparency = 1 ; at percent=0 -> transparency = 0
		local t = newPercent / 0.5 -- 0..1
		-- tween smoothly to target (not flashing)
		tweenOverlayTo(t, LOWHEALTH_TWEEN_TIME)
	else
		-- High health: flash between 0.5 and 1 smoothly
		-- First tween to FLASH_HIGHHEALTH_TARGET quickly, then back to 1
		tweenOverlayTo(FLASH_HIGHHEALTH_TARGET, FLASH_TO_FULL_TIME)
		-- chain back
		spawn(function()
			-- wait until first tween roughly completes, then tween back
			wait(FLASH_TO_FULL_TIME)
			-- ensure player still has health >=50% (optional: only return if still >=50)
			local stillPercent = 1
			if humanoid and humanoid.MaxHealth > 0 then
				stillPercent = humanoid.Health / humanoid.MaxHealth
			end
			if stillPercent >= 0.5 then
				tweenOverlayTo(1, FLASH_BACK_TIME)
			else
				-- if dropped below 50% during flash, immediately set according to low-health rule
				local t = stillPercent / 0.5
				tweenOverlayTo(t, LOWHEALTH_TWEEN_TIME)
			end
		end)
	end
end

-- Apply fixes (inner healthbar, fill, overlay)
local function applyAllFixes()
	local inner, fill = findInnerAndFill()
	innerHealthBar = inner
	Fill = fill

	if innerHealthBar and innerHealthBar:IsA("GuiObject") then
		ensureUICorner(innerHealthBar)
		ensureHealthBarTransparency(innerHealthBar) -- only inner gets ImageTransparency
	end

	if Fill and Fill:IsA("GuiObject") then
		if FORCE_FULL_ON_SPAWN then
			forceFillFull(Fill)
		end
	end

	-- ensure overlay exists
	if not overlayGui or not overlayImage then
		setupOverlay()
	end
end

-- Setup humanoid connections for health tracking & damage detection
local function setupHumanoid(h)
	if not h then return end
	humanoid = h
	local lastHealth = humanoid.Health
	-- initial overlay state in case starting low
	if overlayImage then
		local initialPercent = 1
		if humanoid.MaxHealth and humanoid.MaxHealth > 0 then
			initialPercent = humanoid.Health / humanoid.MaxHealth
		end
		if initialPercent < 0.5 then
			-- set according to low-health mapping directly (no flash)
			local t = initialPercent / 0.5
			pcall(function() overlayImage.ImageTransparency = math.clamp(t, 0, 1) end)
		else
			-- keep overlay invisible (transparency = 1)
			pcall(function() overlayImage.ImageTransparency = 1 end)
		end
	end

	humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		-- ensure Fill found
		if not Fill then
			applyAllFixes()
		end
		-- compute percent
		local percent = 1
		if humanoid.MaxHealth and humanoid.MaxHealth > 0 then
			percent = humanoid.Health / humanoid.MaxHealth
		end
		percent = math.clamp(percent, 0, 1)

		-- if health decreased -> damage
		if lastHealth and humanoid.Health < lastHealth then
			-- trigger overlay reaction for this damage event
			onDamageTriggered(percent)
		else
			-- if healed, maybe update overlay if below 50% (keep consistent)
			if percent < 0.5 then
				local t = percent / 0.5
				tweenOverlayTo(t, LOWHEALTH_TWEEN_TIME)
			else
				-- if healed above 50, ensure overlay transparency returns to 1
				tweenOverlayTo(1, LOWHEALTH_TWEEN_TIME)
			end
		end

		-- update fill bar tween
		tweenFill(percent)

		lastHealth = humanoid.Health
	end)
end

-- Initialize: character/humanoid and UI
Players.LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.08)
	local ok, h = pcall(function() return char:WaitForChild("Humanoid", 5) end)
	if ok and h then
		setupHumanoid(h)
	end
	applyAllFixes()
end)

if Players.LocalPlayer.Character then
	local h = Players.LocalPlayer.Character:FindFirstChild("Humanoid")
	if h then setupHumanoid(h) end
	applyAllFixes()
end

-- Watch for TopBar / Fill changes (respawn or TopBar re-creation)
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
