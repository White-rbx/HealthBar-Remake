-- LocalScript: HealthBar + DamageOverlay (ปรับให้แก้เฉพาะ Fill)
-- วางใน StarterPlayerScripts (LocalScript)

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- ========== CONFIG ==========
local FORCE_FULL_ON_SPAWN = true
local UICORNER_RADIUS = UDim.new(1, 0)            -- ใส่ให้ Fill แทน inner
local FILL_IMAGE_TRANSPARENCY = 1                -- ถ้า Fill เป็น Image จะตั้งเป็นค่านี้
local OVERLAY_IMAGE_ASSET = "rbxassetid://89248890386154"
local OVERLAY_DEFAULT_TRANSPARENCY = 1           -- default = 1 (invisible)
local FLASH_HIGHHEALTH_TARGET = 0.5              -- target transparency when flashing (>=50%)
local FLASH_TO_FULL_TIME = 0.12
local FLASH_BACK_TIME = 0.28
local LOWHEALTH_TWEEN_TIME = 0.18

-- ========== STATE ==========
local innerHealthBar = nil   -- HealthBar.HealthBar (inner)
local Fill = nil             -- Fill inside inner (we will modify ONLY this)
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

-- Ensure UICorner on target (we will call for Fill)
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

-- Ensure ImageTransparency only on Fill (if it's an Image)
local function ensureFillTransparency(fill)
	if not fill or not fill:IsA("GuiObject") then return end
	if fill:IsA("ImageLabel") or fill:IsA("ImageButton") then
		pcall(function() fill.ImageTransparency = FILL_IMAGE_TRANSPARENCY end)
	end
end

-- Force Fill full (1,1)
local function forceFillFull(fill)
	if not fill or not fill:IsA("GuiObject") then return end
	pcall(function() fill.Size = UDim2.new(1, 0, 1, 0) end)
end

-- Tween Fill to percent
local function tweenFill(percent)
	if not Fill or not Fill:IsA("GuiObject") then return end
	if currentFillTween then
		pcall(function() currentFillTween:Cancel() end)
		currentFillTween = nil
	end
	pcall(function()
		local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		currentFillTween = TweenService:Create(Fill, tweenInfo, { Size = UDim2.new(math.clamp(percent, 0, 1), 0, 1, 0) })
		currentFillTween:Play()
	end)
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
		ima.Parent = overlayGui
		overlayImage = ima
	else
		-- ensure default transparency set (default=1)
		pcall(function() overlayImage.ImageTransparency = OVERLAY_DEFAULT_TRANSPARENCY end)
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
	-- Low health (<50%): map [0..0.5] -> [0..1] where 0.5 => 1, 0 => 0
	if newPercent < 0.5 then
		local mapped = math.clamp(newPercent / 0.5, 0, 1)
		-- Tween to mapped transparency (no flashing)
		tweenOverlayTo(mapped, LOWHEALTH_TWEEN_TIME)
	else
		-- High health: flash (0.5 -> 1)
		-- Cancel previous tween and do sequence
		tweenOverlayTo(FLASH_HIGHHEALTH_TARGET, FLASH_TO_FULL_TIME)
		-- chain back in coroutine so we can re-evaluate health mid-flash
		coroutine.wrap(function()
			wait(FLASH_TO_FULL_TIME)
			local nowPercent = 1
			if humanoid and humanoid.MaxHealth and humanoid.MaxHealth > 0 then
				nowPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
			end
			if nowPercent < 0.5 then
				-- switched to low health during flash -> go to mapped state
				local mapped = math.clamp(nowPercent / 0.5, 0, 1)
				tweenOverlayTo(mapped, LOWHEALTH_TWEEN_TIME)
			else
				-- still >=50 -> tween back to invisible (1)
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

	-- apply only to Fill (NOT inner healthbar)
	if Fill and Fill:IsA("GuiObject") then
		-- put corner on Fill and set its image transparency if it's an image
		ensureUICorner(Fill)
		ensureFillTransparency(Fill)

		if FORCE_FULL_ON_SPAWN then
			forceFillFull(Fill)
		end
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
				-- if healed above 50 ensure invisible
				tweenOverlayTo(1, LOWHEALTH_TWEEN_TIME)
			end
		end

		-- update fill tween
		tweenFill(percent)

		lastHealth = humanoid.Health
	end)
end

-- New: onCharacterSpawn - handle spawn timing and ensure Fill shows full until real values arrive
local function onCharacterSpawn(char)
	-- find Fill early
	Fill, innerHealthBar = findInnerAndFill()
	-- if Fill exists, force full to hide wrong empty bar
	if Fill and Fill:IsA("GuiObject") and FORCE_FULL_ON_SPAWN then
		pcall(function() Fill.Size = UDim2.new(1,0,1,0) end)
	end

	-- wait for humanoid (if not present)
	local h = char:FindFirstChildOfClass("Humanoid")
	if not h then
		h = char:WaitForChild("Humanoid", 5)
		if not h then return end
	end

	-- wait a short time for server/custom scripts to set MaxHealth/Health
	local timeout = 2.0
	local elapsed = 0
	local step = 0.05
	while elapsed < timeout do
		-- if MaxHealth positive and Health is not nil, break
		if h.MaxHealth and h.MaxHealth > 0 and h.Health ~= nil then
			break
		end
		task.wait(step)
		elapsed = elapsed + step
	end

	-- update references (in case UI created after)
	Fill, innerHealthBar = findInnerAndFill()

	-- now tween Fill to real percent (if valid)
	if Fill and h.MaxHealth and h.MaxHealth > 0 then
		local percent = math.clamp(h.Health / h.MaxHealth, 0, 1)
		-- Tween from full to actual so it doesn't appear empty at spawn
		tweenFill(percent)
	end

	-- finally setup humanoid connections (only once each spawn)
	setupHumanoid(h)
end

-- Init: CharacterAdded + existing character
Players.LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.08)
	applyAllFixes()
	onCharacterSpawn(char)
end)

if Players.LocalPlayer.Character then
	applyAllFixes()
	onCharacterSpawn(Players.LocalPlayer.Character)
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
