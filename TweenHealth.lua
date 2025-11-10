-- HealthBar + DamageOverlay + Smooth Tween (Final Fixed)
-- Place in StarterPlayerScripts (LocalScript)

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- ========= CONFIG =========
local UICORNER_RADIUS = UDim.new(1, 0)
local HEALTHBAR_IMAGE_TRANSPARENCY = 1
local OVERLAY_IMAGE_ASSET = "rbxassetid://114133350704123"
local OVERLAY_DEFAULT_TRANSPARENCY = 1
local FLASH_HIGHHEALTH_TARGET = 0
local FLASH_TO_FULL_TIME = 0.12
local FLASH_BACK_TIME = 0.28
local LOWHEALTH_TWEEN_TIME = 0.18

local NORMAL_TWEEN_TIME = 0.25 -- ปกติ (ทุกครั้งที่เลือดเปลี่ยน)
local SPAWN_TWEEN_TIME = 5 -- ตอนเกิด
local currentTweenTime = NORMAL_TWEEN_TIME

-- ========= STATE =========
local innerHealthBar, Fill = nil, nil
local humanoid = nil
local currentFillTween = nil
local overlayGui, overlayImage, overlayTween = nil, nil, nil

-- ========= FIND =========
local function findInnerAndFill()
	local top = CoreGui:FindFirstChild("TopBarApp")
	if not top then return nil, nil end
	local nested = top:FindFirstChild("TopBarApp")
	if not nested then return nil, nil end
	local uni = nested:FindFirstChild("UnibarLeftFrame")
	if not uni then return nil, nil end
	local hb = uni:FindFirstChild("HealthBar")
	if not hb then return nil, nil end
	local inner = hb:FindFirstChild("HealthBar")
	if not inner then return nil, nil end
	local fill = inner:FindFirstChild("Fill")
	return inner, fill
end

-- ========= UI FIX =========
local function ensureUICorner(target)
	if not target or not target:IsA("GuiObject") then return end
	local ex = target:FindFirstChildOfClass("UICorner")
	if not ex then
		local u = Instance.new("UICorner")
		u.CornerRadius = UICORNER_RADIUS
		u.Parent = target
	end
end

local function ensureTransparency(gui)
	if gui and (gui:IsA("ImageLabel") or gui:IsA("ImageButton")) then
		gui.ImageTransparency = HEALTHBAR_IMAGE_TRANSPARENCY
	end
end

-- ========= OVERLAY =========
local function setupOverlay()
	local ex = CoreGui:FindFirstChild("DamageOverlay")
	if ex and ex:IsA("ScreenGui") then
		overlayGui = ex
		overlayImage = ex:FindFirstChild("OverlayImage")
	else
		overlayGui = Instance.new("ScreenGui")
		overlayGui.Name = "DamageOverlay"
		overlayGui.Parent = CoreGui

		overlayImage = Instance.new("ImageLabel")
		overlayImage.Name = "OverlayImage"
		overlayImage.Size = UDim2.new(1, 0, 1, 0)
		overlayImage.BackgroundTransparency = 1
		overlayImage.Image = OVERLAY_IMAGE_ASSET
		overlayImage.ImageTransparency = OVERLAY_DEFAULT_TRANSPARENCY
		overlayImage.ZIndex = 100
		overlayImage.Parent = overlayGui
	end
end

local function tweenOverlayTo(targetTransparency, time)
	if not overlayImage then return end
	if overlayTween then pcall(function() overlayTween:Cancel() end) end
	local ti = TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	overlayTween = TweenService:Create(overlayImage, ti, { ImageTransparency = math.clamp(targetTransparency, 0, 1) })
	overlayTween:Play()
end

local function onDamageTriggered(percent)
	if not overlayImage then return end
	if percent < 0.5 then
		local mapped = math.clamp(percent / 0.5, 0, 1)
		tweenOverlayTo(mapped, LOWHEALTH_TWEEN_TIME)
	else
		tweenOverlayTo(FLASH_HIGHHEALTH_TARGET, FLASH_TO_FULL_TIME)
		task.delay(FLASH_TO_FULL_TIME, function()
			local now = humanoid and humanoid.Health / humanoid.MaxHealth or 1
			if now < 0.5 then
				local mapped = math.clamp(now / 0.5, 0, 1)
				tweenOverlayTo(mapped, LOWHEALTH_TWEEN_TIME)
			else
				tweenOverlayTo(1, FLASH_BACK_TIME)
			end
		end)
	end
end

-- ========= TWEEN FILL =========
local function tweenFill(percent)
	if not Fill or not Fill:IsA("GuiObject") then return end
	if currentFillTween then pcall(function() currentFillTween:Cancel() end) end

	local ti = TweenInfo.new(currentTweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = { Size = UDim2.new(math.clamp(percent, 0, 1), 0, 1, 0) }
	currentFillTween = TweenService:Create(Fill, ti, goal)
	currentFillTween:Play()
end

-- ========= APPLY FIX =========
local function applyAllFixes()
	local inner, fill = findInnerAndFill()
	innerHealthBar, Fill = inner, fill
	if inner then
		ensureUICorner(inner)
		ensureTransparency(inner)
	end
	if not overlayGui then
		setupOverlay()
	end
end

-- ========= HEALTH SETUP =========
local function setupHumanoid(h)
	humanoid = h
	local lastHealth = h.Health
	applyAllFixes()

	h:GetPropertyChangedSignal("Health"):Connect(function()
		if not Fill then applyAllFixes() end
		local percent = (h.Health / h.MaxHealth)
		if h.Health < lastHealth then
			onDamageTriggered(percent)
		else
			if percent < 0.5 then
				local mapped = percent / 0.5
				tweenOverlayTo(mapped, LOWHEALTH_TWEEN_TIME)
			else
				tweenOverlayTo(1, LOWHEALTH_TWEEN_TIME)
			end
		end
		tweenFill(percent)
		lastHealth = h.Health
	end)
end

-- ========= SPAWN TWEEN =========
local function tweenFillFull()
	local fill = findInnerAndFill()
	if not fill then return end
	pcall(function()
		fill.Size = UDim2.new(0, 0, 1, 0)
		currentTweenTime = SPAWN_TWEEN_TIME
		local tw = TweenService:Create(fill, TweenInfo.new(SPAWN_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Size = UDim2.new(1, 0, 1, 0) })
		tw:Play()
		tw.Completed:Connect(function()
			currentTweenTime = NORMAL_TWEEN_TIME
		end)
	end)
end

-- ========= CHARACTER HOOK =========
player.CharacterAdded:Connect(function(char)
	task.defer(function()
		local h = char:WaitForChild("Humanoid", 5)
		if not h then return end
		setupHumanoid(h)
		while h.Health <= 0 do task.wait(0.05) end
		task.wait(0.3)
		tweenFillFull()
	end)
end)

if player.Character and player.Character:FindFirstChild("Humanoid") then
	setupHumanoid(player.Character:FindFirstChild("Humanoid"))
	tweenFillFull()
end

-- ========= MONITOR =========
RunService.RenderStepped:Connect(function(dt)
	local inner, fill = findInnerAndFill()
	if inner ~= innerHealthBar or fill ~= Fill then
		applyAllFixes()
	end
end)

-- ========= OUTLINE =========
task.defer(function()
	local ok, parent = pcall(function()
		return CoreGui:WaitForChild("TopBarApp"):WaitForChild("TopBarApp")
			:WaitForChild("UnibarLeftFrame"):WaitForChild("HealthBar"):WaitForChild("HealthBar")
	end)
	if ok and parent and not parent:FindFirstChild("Outline") then
		local outline = Instance.new("Frame")
		outline.Name = "Outline"
		outline.Size = UDim2.new(0.98, 0, 0.7, 0)
		outline.Position = UDim2.new(0.01, 0, 0.15, 0)
		outline.BackgroundTransparency = 1
		outline.Parent = parent

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = outline

		local stroke = Instance.new("UIStroke")
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Color = Color3.fromRGB(0, 0, 0)
		stroke.Thickness = 1.8
		stroke.Parent = outline
	end
end)
