-- Bah bah 2.37
-- LocalScript: HealthBar + PainOverlay + UIScale + Static Noise

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- ========== CONFIG ==========
local FORCE_FULL_ON_SPAWN = true
local UICORNER_RADIUS = UDim.new(1, 0)
local HEALTHBAR_IMAGE_TRANSPARENCY = 1

local FULL_FILL_TWEEN_TIME = 5

local PAIN_SOUND_ASSET = "rbxassetid://126351915401997" -- default, original: rbxassetid://126351915401997

local PAIN_FRAMES = {
    "rbxassetid://96879254983434",
    "rbxassetid://78560495271932",
    "rbxassetid://93946025207462",
    "rbxassetid://105257528758532",
    "rbxassetid://73483179055064",
    "rbxassetid://129859585758269",
    "rbxassetid://136911054416816",
    "rbxassetid://76279489893641",
    "rbxassetid://73479414373169",
    "rbxassetid://119223450722196",
    "rbxassetid://133591090239187",
    "rbxassetid://100019676388141",
    "rbxassetid://140378202061940",
    "rbxassetid://90055648136400",
    "rbxassetid://122553589002743",
    "rbxassetid://101480675389306",
    "rbxassetid://81455574803019",
}

local ContentProvider = game:GetService("ContentProvider")

local PAIN_FPS = #PAIN_FRAMES
local PAIN_LOOP_STEP = 1 / PAIN_FPS

local preload = {}

for _, imageId in ipairs(PAIN_FRAMES) do
	table.insert(preload, imageId)
end

ContentProvider:PreloadAsync(preload)

local DAMAGE_PULSE_DURATION = 0.35
local DAMAGE_SOUND_DURATION = 0.18

-- ========== STATE ==========
local innerHealthBar = nil
local Fill = nil
local humanoid = nil

local currentFillTween = nil
local overlayGui = nil
local overlayHolder = nil
local overlayImage = nil
local overlayScale = nil
local overlaySound = nil

local healthConn = nil
local painLoopStarted = false
local frameIndex = 1
local frameAccumulator = 0

local damageHoldUntil = 0
local damageSoundUntil = 0

local currentTargetScale = 1
local currentPulseAmp = 0
local currentPulseFreq = 0
local currentSoundVolume = 0
local currentSoundPitch = 1
local currentSoundEnabled = false

-- ========== HELPERS ==========
local function lerp(a, b, t)
	return a + (b - a) * math.clamp(t, 0, 1)
end

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

local function getHealthBarParent()
	local topBarApp = CoreGui:FindFirstChild("TopBarApp")
	if not topBarApp then return nil end

	local nested = topBarApp:FindFirstChild("TopBarApp")
	if not nested then return nil end

	local unibar = nested:FindFirstChild("UnibarLeftFrame")
	if not unibar then return nil end

	local healthBar = unibar:FindFirstChild("HealthBar")
	if not healthBar then return nil end

	return healthBar:FindFirstChild("HealthBar")
end

local function ensureUICorner(target)
	if not target or not target:IsA("GuiObject") then return end

	local existing = target:FindFirstChildOfClass("UICorner")
	if existing then
		pcall(function()
			existing.CornerRadius = UICORNER_RADIUS
		end)
	else
		pcall(function()
			local uc = Instance.new("UICorner")
			uc.CornerRadius = UICORNER_RADIUS
			uc.Parent = target
		end)
	end
end

local function ensureHealthBarTransparency(gui)
	if not gui or not gui:IsA("GuiObject") then return end
	if gui:IsA("ImageLabel") or gui:IsA("ImageButton") then
		pcall(function()
			gui.ImageTransparency = HEALTHBAR_IMAGE_TRANSPARENCY
		end)
	end
end

local function forceFillFull(fill)
	if not fill or not fill:IsA("GuiObject") then return end
	pcall(function()
		fill.Size = UDim2.new(1, 0, 1, 0)
	end)
end

local function tweenFill(percent)
	if not Fill or not Fill:IsA("GuiObject") then return end

	if currentFillTween then
		pcall(function()
			currentFillTween:Cancel()
		end)
		currentFillTween = nil
	end

	pcall(function()
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		currentFillTween = TweenService:Create(Fill, tweenInfo, {
			Size = UDim2.new(math.clamp(percent, 0, 1), 0, 1, 0)
		})
		currentFillTween:Play()
	end)
end

local function setupOverlay()
	local existing = CoreGui:FindFirstChild("DamageOverlay")
	if existing and existing:IsA("ScreenGui") then
		overlayGui = existing
	else
		overlayGui = Instance.new("ScreenGui")
		overlayGui.Name = "DamageOverlay"
		overlayGui.ResetOnSpawn = false
		overlayGui.IgnoreGuiInset = true
		overlayGui.DisplayOrder = 1
		overlayGui.Enabled = true
		overlayGui.Parent = CoreGui
	end

	overlayHolder = overlayGui:FindFirstChild("OverlayHolder")
	if not overlayHolder then
		overlayHolder = Instance.new("Frame")
		overlayHolder.Name = "OverlayHolder"
		overlayHolder.Size = UDim2.fromScale(1, 1)
		overlayHolder.BackgroundTransparency = 1
		overlayHolder.Parent = overlayGui

		local layout = Instance.new("UIListLayout")
		layout.Name = "CenterLayout"
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = overlayHolder
	end

	overlayImage = overlayHolder:FindFirstChild("OverlayImage")
	if not overlayImage then
		overlayImage = Instance.new("ImageLabel")
		overlayImage.Name = "OverlayImage"
		overlayImage.Size = UDim2.fromScale(1, 1)
		overlayImage.BackgroundTransparency = 1
		overlayImage.ImageTransparency = 0.25
		overlayImage.Image = PAIN_FRAMES[1]
		overlayImage.Active = false
		overlayImage.Visible = false
		overlayImage.LayoutOrder = 1
		overlayImage.Parent = overlayHolder
	end

	overlayScale = overlayImage:FindFirstChildOfClass("UIScale")
	if not overlayScale then
		overlayScale = Instance.new("UIScale")
		overlayScale.Parent = overlayImage
	end
	overlayScale.Scale = 1
end

local function bindPainSoundToCharacter(character)
	if overlaySound then
		pcall(function()
			overlaySound:Destroy()
		end)
		overlaySound = nil
	end

	if not character then return end
	local hrp = character:WaitForChild("HumanoidRootPart", 5)
	if not hrp then return end

	overlaySound = Instance.new("Sound")
	overlaySound.Name = "PainNoise"
	overlaySound.SoundId = PAIN_SOUND_ASSET
	overlaySound.Looped = true
	overlaySound.Volume = 0
	overlaySound.Parent = hrp
end

local function getPainProfile(percent)
	percent = math.clamp(percent, 0, 1)

	if percent >= 0.999 then
		return 1, 0, 0, 0, false, 0
	end

	if percent >= 0.9 then
		local t = (1 - percent) / 0.1
		return lerp(1, 1.8, t), 0, 0, 0, false, 0
	elseif percent >= 0.8 then
		local t = (0.9 - percent) / 0.1
		return lerp(1.8, 2.4, t), 0, 0, 0, false, 0
	elseif percent >= 0.65 then
		local t = (0.8 - percent) / 0.15
		return lerp(2.4, 3.0, t), 0, 0, 0, false, 0
	elseif percent >= 0.5 then
		local t = (0.65 - percent) / 0.15
		return lerp(3.0, 3.4, t), 0, 0, 0, false, 0
	end

	if percent >= 0.4 then
	local t = (0.5 - percent) / 0.1
	return lerp(3.6, 3.0, t), 0.20,
		lerp(3, 5, t),   -- Volume
		lerp(1.0, 1.1, t), -- PlaybackSpeed
		true,
		lerp(8, 10, t)

elseif percent >= 0.3 then
	local t = (0.4 - percent) / 0.1
	return lerp(3.0, 2.3, t), 0.10,
		lerp(5, 7, t),
		lerp(1.1, 1.5, t),
		true,
		lerp(10, 12, t)

elseif percent >= 0.2 then
	local t = (0.3 - percent) / 0.1
	return lerp(2.3, 1.75, t), 0.25,
		lerp(7, 8, t),
		lerp(1.5, 2.0, t),
		true,
		lerp(12, 14, t)

elseif percent >= 0.1 then
	local t = (0.2 - percent) / 0.1
	return lerp(1.75, 1.45, t), 0.15,
		lerp(8, 9, t),
		lerp(2.0, 2.3, t),
		true,
		lerp(14, 16, t)

else
	local t = math.clamp((0.1 - percent) / 0.1, 0, 1)
	return lerp(1.45, 1.10, t), 0.10,
		lerp(9, 10, t),
		lerp(2.3, 3.0, t),
		true,
		lerp(16, 18, t)
end
end

local function applyPainProfile(percent)
	if percent >= 0.999 and os.clock() > damageHoldUntil then
		overlayImage.Visible = false
		overlayScale.Scale = 1
		currentTargetScale = 1
		currentPulseAmp = 0
		currentPulseFreq = 0
		currentSoundVolume = 0
		currentSoundPitch = 1
		currentSoundEnabled = false
		frameIndex = 1
		overlayImage.Image = PAIN_FRAMES[1]
		if overlaySound and overlaySound.IsPlaying then
			overlaySound:Stop()
		end
		return
	end

	local scale, pulseAmp, vol, pitch, soundEnabled, pulseFreq = getPainProfile(percent)
	currentTargetScale = scale
	currentPulseAmp = pulseAmp
	currentPulseFreq = pulseFreq
	currentSoundVolume = vol
	currentSoundPitch = pitch
	currentSoundEnabled = soundEnabled

	overlayImage.Visible = true
end

local function startPainLoop()
	if painLoopStarted then return end
	painLoopStarted = true

	task.spawn(function()
		while true do
			task.wait(PAIN_LOOP_STEP)

			if not overlayImage or not overlayScale then
				if overlaySound and overlaySound.IsPlaying then
					overlaySound:Stop()
				end
				continue
			end

			if not humanoid or not humanoid.Parent or not humanoid.MaxHealth or humanoid.MaxHealth <= 0 then
				overlayImage.Visible = false
				overlayScale.Scale = 1
				if overlaySound and overlaySound.IsPlaying then
					overlaySound:Stop()
				end
				continue
			end

			local percent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
			local recentlyDamaged = os.clock() < damageHoldUntil

			-- เห็นเฉพาะตอนเลือดต่ำกว่า 50% หรือยังอยู่ในช่วงดาเมจ
			if percent < 0.5 or recentlyDamaged then

    -- เพิ่งเข้าช่วง Damage Overlay
    if not overlayImage.Visible then
        overlayScale.Scale = 10
        overlayImage.Visible = true
    end

    applyPainProfile(percent)

    frameAccumulator += PAIN_LOOP_STEP
    if frameAccumulator >= PAIN_LOOP_STEP then
        frameAccumulator = 0
        frameIndex += 1
        if frameIndex > #PAIN_FRAMES then
            frameIndex = 1
        end
        overlayImage.Image = PAIN_FRAMES[frameIndex]
    end

    local pulse = 0
    if percent < 0.5 and currentPulseAmp > 0 then
        pulse = math.sin(os.clock() * currentPulseFreq) * currentPulseAmp
    end

    local target = math.clamp(currentTargetScale + pulse, 1, 10)

    overlayScale.Scale = lerp(
        overlayScale.Scale,
        target,
        0.20 -- ปรับความเร็ว Tween ได้
    )

else

    -- ออกจากโหมด Damage
    overlayScale.Scale = lerp(
        overlayScale.Scale,
        10,
        0.20
    )

    if math.abs(overlayScale.Scale - 10) < 0.05 then
        overlayScale.Scale = 10
        overlayImage.Visible = false
    end

    frameIndex = 1
    overlayImage.Image = PAIN_FRAMES[1]

    if overlaySound and overlaySound.IsPlaying then
        overlaySound:Stop()
    end

end
		end
	end)
end

local function applyAllFixes()
	local inner, fill = findInnerAndFill()
	innerHealthBar = inner
	Fill = fill

	if innerHealthBar and innerHealthBar:IsA("GuiObject") then
		ensureUICorner(innerHealthBar)
		ensureHealthBarTransparency(innerHealthBar)
	end

	if Fill and Fill:IsA("GuiObject") and FORCE_FULL_ON_SPAWN then
		forceFillFull(Fill)
	end

	if not overlayGui or not overlayImage then
		setupOverlay()
	end

	local healthBarParent = getHealthBarParent()
	if healthBarParent and not healthBarParent:FindFirstChild("Outline") then
		local outline = Instance.new("Frame")
		outline.Name = "Outline"
		outline.Size = UDim2.new(0.98, 0, 0.7, 0)
		outline.Position = UDim2.new(0.01, 0, 0.15, 0)
		outline.BackgroundTransparency = 1
		outline.Parent = healthBarParent

		local uicorner = Instance.new("UICorner")
		uicorner.CornerRadius = UICORNER_RADIUS
		uicorner.Parent = outline

		local stroke = Instance.new("UIStroke")
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Color = Color3.fromRGB(0, 0, 0)
		stroke.Thickness = 1.8
		stroke.Parent = outline
	end

	startPainLoop()
end

local function tweenFillFullOnce()
	local fill = nil
	local topBar = CoreGui:FindFirstChild("TopBarApp")
	if topBar then
		local nested = topBar:FindFirstChild("TopBarApp")
		if nested then
			local unibar = nested:FindFirstChild("UnibarLeftFrame")
			if unibar then
				local hb = unibar:FindFirstChild("HealthBar")
				if hb then
					local inner = hb:FindFirstChild("HealthBar")
					if inner then
						fill = inner:FindFirstChild("Fill")
					end
				end
			end
		end
	end

	if not fill or not fill:IsA("GuiObject") then return end

	pcall(function()
		fill.Size = UDim2.new(0, 0, 1, 0)
		local tweenInfo = TweenInfo.new(FULL_FILL_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(fill, tweenInfo, {
			Size = UDim2.new(1, 0, 1, 0)
		})
		tween:Play()
	end)
end

local function setupHumanoid(h, character)
	if not h then return end

	if healthConn then
		pcall(function()
			healthConn:Disconnect()
		end)
		healthConn = nil
	end

	humanoid = h
	local lastHealth = humanoid.Health

	if character then
		bindPainSoundToCharacter(character)
	end

	healthConn = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if not Fill then
			applyAllFixes()
		end

		local percent = 1
		if humanoid.MaxHealth and humanoid.MaxHealth > 0 then
			percent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
		end

		if lastHealth and humanoid.Health < lastHealth then
			damageHoldUntil = os.clock() + DAMAGE_PULSE_DURATION
			damageSoundUntil = os.clock() + DAMAGE_SOUND_DURATION
		end

		tweenFill(percent)
		lastHealth = humanoid.Health
	end)
end

local function onCharacterAdded(char)
	task.spawn(function()
		local h = char:WaitForChild("Humanoid", 5)
		if h then
			setupHumanoid(h, char)
		end

		task.wait(0.1)
		applyAllFixes()

		if FORCE_FULL_ON_SPAWN then
			tweenFillFullOnce()
		end
	end)
end

-- ========== INIT ==========
player.CharacterAdded:Connect(onCharacterAdded)

if player.Character then
	local h = player.Character:FindFirstChild("Humanoid")
	if h then
		setupHumanoid(h, player.Character)
	end
	applyAllFixes()

	if FORCE_FULL_ON_SPAWN then
		task.defer(function()
			task.wait(0.1)
			tweenFillFullOnce()
		end)
	end
end

local checkTimer = 0
RunService.RenderStepped:Connect(function(dt)
	checkTimer += dt
	if checkTimer < 0.2 then return end
	checkTimer = 0

	local inner, fill = findInnerAndFill()
	if inner ~= innerHealthBar or fill ~= Fill then
		applyAllFixes()
	end
end)
