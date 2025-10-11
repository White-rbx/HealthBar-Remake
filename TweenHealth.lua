-- LocalScript: HealthBar + DamageOverlay
-- วางใน StarterPlayerScripts (LocalScript)

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- ========== CONFIG ==========
local FORCE_FULL_ON_SPAWN = true
local UICORNER_RADIUS = UDim.new(1, 0)            -- มุมตามที่ขอ
local HEALTHBAR_IMAGE_TRANSPARENCY = 1           -- เฉพาะ inner HealthBar
local OVERLAY_IMAGE_ASSET = "rbxassetid://114133350704123"
local OVERLAY_DEFAULT_TRANSPARENCY = 1           -- default = 1 (invisible)
local FLASH_HIGHHEALTH_TARGET = 0 -- target transparency when flashing (>=50%)
local FLASH_TO_FULL_TIME = 0.12
local FLASH_BACK_TIME = 0.28
local LOWHEALTH_TWEEN_TIME = 0.18

-- ========== STATE ==========
local innerHealthBar = nil   -- HealthBar.HealthBar (inner)
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
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
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
        overlayGui.Enabled = false
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

	if innerHealthBar and innerHealthBar:IsA("GuiObject") then
		ensureUICorner(innerHealthBar)
		ensureHealthBarTransparency(innerHealthBar)
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

-- Outline สำหรับ HealthBar
local CoreGui = game:GetService("CoreGui")
local healthBarParent = CoreGui:WaitForChild("TopBarApp"):WaitForChild("TopBarApp")
	:WaitForChild("UnibarLeftFrame"):WaitForChild("HealthBar"):WaitForChild("HealthBar")

-- ตรวจว่ามี Outline อยู่แล้วไหม
if not healthBarParent:FindFirstChild("Outline") then
	local outline = Instance.new("Frame")
	outline.Name = "Outline"
	-- กำหนดขนาดและตำแหน่งสัมพันธ์กับ HealthBar
	outline.Size = UDim2.new(0.98, 0, 0.7, 0)
	outline.Position = UDim2.new(0.01, 0, 0.15, 0)
	outline.BackgroundTransparency = 1
	outline.Parent = healthBarParent

	-- UICorner ทำให้มุมโค้ง
	local uicorner = Instance.new("UICorner")
	uicorner.CornerRadius = UDim.new(1, 0)
	uicorner.Parent = outline

	-- UIStroke สำหรับเส้นขอบ
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Thickness = 1.8
	stroke.Parent = outline
end

-- LocalScript: Tween Fill full ONCE after respawn
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- 🔍 หา Fill
local function findFill()
	local topBar = CoreGui:FindFirstChild("TopBarApp")
	if not topBar then return nil end
	local nested = topBar:FindFirstChild("TopBarApp")
	if not nested then return nil end
	local unibar = nested:FindFirstChild("UnibarLeftFrame")
	if not unibar then return nil end
	local hb = unibar:FindFirstChild("HealthBar")
	if not hb then return nil end
	local inner = hb:FindFirstChild("HealthBar")
	if not inner then return nil end
	return inner:FindFirstChild("Fill")
end

-- 💫 Tween Fill จาก 0 → 1
local function tweenFillFull()
	local fill = findFill()
	if not fill or not fill:IsA("GuiObject") then return end

	pcall(function()
		-- เริ่มต้นที่ 0
		fill.Size = UDim2.new(0, 0, 1, 0)

		-- Tween ไป 1
		local tweenInfo = TweenInfo.new(
			5, -- ระยะเวลา
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)
		local goal = { Size = UDim2.new(1, 0, 1, 0) }
		local tween = TweenService:Create(fill, tweenInfo, goal)
		tween:Play()
	end)
end

-- ⚙️ ตอนเกิดใหม่
local function onCharacterAdded(char)
	task.defer(function()
		local humanoid = char:WaitForChild("Humanoid", 5)
		if not humanoid then return end

		-- รอจนเกิดจริง
		while humanoid.Health <= 0 do
			task.wait(0.05)
		end

		-- ⏱ รอ 1 วิให้ Fill ถูกสร้าง
		task.wait(0.1)
		tweenFillFull()
	end)
end

-- 🔄 เชื่อมต่อกับการเกิดใหม่
player.CharacterAdded:Connect(onCharacterAdded)

-- เรียกครั้งแรกถ้ามีตัวอยู่แล้ว
if player.Character then
	onCharacterAdded(player.Character)
end
