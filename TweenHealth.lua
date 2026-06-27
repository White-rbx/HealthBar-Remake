-- Bah bah 2.1
-- LocalScript: HealthBar + PainOverlay + UIScale + Static Noise
-- One ImageLabel only, frame-cycled animation

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer

-- ========== CONFIG ==========
local FORCE_FULL_ON_SPAWN = true
local UICORNER_RADIUS = UDim.new(1, 0)
local HEALTHBAR_IMAGE_TRANSPARENCY = 1

local FULL_FILL_TWEEN_TIME = 5
local PAIN_LOOP_STEP = 0.02

local PAIN_SOUND_ASSET = "rbxassetid://126351915401997"

local PAIN_FRAMES = {
	"rbxassetid://96879254983434",
	"rbxassetid://78560495271932",
	"rbxassetid://93946025207462",
	"rbxassetid://105257528758532",
	"rbxassetid://73483179055064",
	"rbxassetid://136010240858607",
	"rbxassetid://80073454439641",
	"rbxassetid://129411412379170",
	"rbxassetid://113905008572350",
	"rbxassetid://76768283876168",
	"rbxassetid://133442935057291",
	"rbxassetid://99707786821960",
	"rbxassetid://128020817481662",
	"rbxassetid://85745216910474",
	"rbxassetid://77614183505418",
	"rbxassetid://80292339864919",
	"rbxassetid://103911595205799",
}

-- ========== STATE ==========
local innerHealthBar = nil
local Fill = nil
local humanoid = nil

local currentFillTween = nil
local overlayGui = nil
local overlayImage = nil
local overlayScale = nil
local overlaySound = nil

local healthConn = nil
local painLoopStarted = false
local frameIndex = 1

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
		overlayImage =
			overlayGui:FindFirstChild("OverlayImage")
			or overlayGui:FindFirstChildOfClass("ImageLabel")
			or overlayGui:FindFirstChildOfClass("ImageButton")
	else
		overlayGui = Instance.new("ScreenGui")
		overlayGui.Name = "DamageOverlay"
		overlayGui.ResetOnSpawn = false
		overlayGui.IgnoreGuiInset = true
		overlayGui.DisplayOrder = 1
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
		ima.Image = PAIN_FRAMES[1]
		ima.Active = false
		ima.Visible = false
		ima.Parent = overlayGui
		overlayImage = ima
	end

	overlayScale = overlayImage:FindFirstChildOfClass("UIScale")
	if not overlayScale then
		overlayScale = Instance.new("UIScale")
		overlayScale.Parent = overlayImage
	end
	overlayScale.Scale = 1

	overlaySound = SoundService:FindFirstChild("PainNoise")
	if not overlaySound then
		overlaySound = Instance.new("Sound")
		overlaySound.Name = "PainNoise"
		overlaySound.SoundId = PAIN_SOUND_ASSET
		overlaySound.Looped = true
		overlaySound.Volume = 0
		overlaySound.Parent = SoundService
	end
end

local function getPainProfile(percent)
	percent = math.clamp(percent, 0, 1)

	-- 100%+ = 1
	if percent >= 0.999 then
		return 1, 0, 0, 0, false, 0
	end

	-- 100% -> 90% -> 80% -> 65% -> 50%
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

	-- ต่ำกว่า 50% -> scale แบบเต้น + เสียง
	if percent >= 0.4 then
		local t = (0.5 - percent) / 0.1
		return lerp(3.6, 3.0, t), 0.20, lerp(0.5, 1.0, t), lerp(8, 10, t), true, lerp(8, 10, t)
	elseif percent >= 0.3 then
		local t = (0.4 - percent) / 0.1
		return lerp(3.0, 2.3, t), 0.10, lerp(1.0, 3.0, t), lerp(10, 12, t), true, lerp(10, 12, t)
	elseif percent >= 0.2 then
		local t = (0.3 - percent) / 0.1
		return lerp(2.3, 1.75, t), 0.25, lerp(3.0, 6.0, t), lerp(12, 14, t), true, lerp(12, 14, t)
	elseif percent >= 0.1 then
		local t = (0.2 - percent) / 0.1
		return lerp(1.75, 1.45, t), 0.15, lerp(6.0, 8.0, t), lerp(14, 16, t), true, lerp(14, 16, t)
	else
		local t = math.clamp((0.1 - percent) / 0.1, 0, 1)
		return lerp(1.45, 1.10, t), 0.10, lerp(8.0, 10.0, t), lerp(16, 18, t), true, lerp(16, 18, t)
	end
end

local function applyPainProfile(percent)
	if percent >= 0.999 then
		overlayImage.Visible = false
		overlayScale.Scale = 1
		currentTargetScale = 1
		currentPulseAmp = 0
		currentPulseFreq = 0
		currentSoundVolume = 0
		currentSoundPitch = 1
		currentSoundEnabled = false
		if overlaySound and overlaySound.IsPlaying then
			overlaySound:Stop()
		end
		frameIndex = 1
		if overlayImage then
			overlayImage.Image = PAIN_FRAMES[1]
		end
		return
	end

	local scale, pulseAmp, vol, pitch, soundEnabled, pulseFreq = getPainProfile(percent)

	overlayImage.Visible = true
	currentTargetScale = scale
	currentPulseAmp = pulseAmp
	currentPulseFreq = pulseFreq
	currentSoundVolume = vol
	currentSoundPitch = pitch
	currentSoundEnabled = soundEnabled
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
			applyPainProfile(percent)

			if overlayImage.Visible then
				if #PAIN_FRAMES > 0 then
					frameIndex += 1
					if frameIndex > #PAIN_FRAMES then
						frameIndex = 1
					end
					overlayImage.Image = PAIN_FRAMES[frameIndex]
				end

				local pulse = 0
				if currentPulseAmp > 0 and currentPulseFreq > 0 then
					pulse = math.sin(os.clock() * currentPulseFreq) * currentPulseAmp
				end

				local target = math.clamp(currentTargetScale + pulse, 1, 10)
				overlayScale.Scale = lerp(overlayScale.Scale, target, 0.35)

				if currentSoundEnabled then
					if overlaySound then
						overlaySound.Volume = math.clamp(currentSoundVolume, 0, 10)
						overlaySound.PlaybackSpeed = math.clamp(currentSoundPitch, 0.1, 10)

						if not overlaySound.IsPlaying then
							overlaySound:Play()
						end
					end
				else
					if overlaySound and overlaySound.IsPlaying then
						overlaySound:Stop()
					end
				end
			else
				overlayScale.Scale = 1
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

local function setupHumanoid(h)
	if not h then return end

	if healthConn then
		pcall(function()
			healthConn:Disconnect()
		end)
		healthConn = nil
	end

	humanoid = h
	local lastHealth = humanoid.Health

	healthConn = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if not Fill then
			applyAllFixes()
		end

		local percent = 1
		if humanoid.MaxHealth and humanoid.MaxHealth > 0 then
			percent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
		end

		-- damage detected / health changed
		applyPainProfile(percent)
		tweenFill(percent)

		-- ถ้าฟื้นจนเต็มอีกครั้ง ให้ซ่อน overlay
		if percent >= 0.999 then
			overlayImage.Visible = false
			overlayScale.Scale = 1
			if overlaySound and overlaySound.IsPlaying then
				overlaySound:Stop()
			end
			frameIndex = 1
			if overlayImage then
				overlayImage.Image = PAIN_FRAMES[1]
			end
		end

		lastHealth = humanoid.Health
	end)
end

local function onCharacterAdded(char)
	task.spawn(function()
		local h = char:WaitForChild("Humanoid", 5)
		if h then
			setupHumanoid(h)
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
		setupHumanoid(h)
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
