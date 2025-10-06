-- LocalScript: HealthBar Fix (Transparency only on HealthBar, not Fill)
-- วางใน StarterPlayerScripts หรือที่แน่นอนว่าเป็น LocalScript

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Fill = nil
local innerHealthBar = nil -- HealthBar.HealthBar
local humanoid = nil
local currentTween = nil

-- ปรับค่าได้
local FORCE_FULL_ON_SPAWN = true -- ตั้ง Fill เป็นเต็มทุกครั้งที่เจอใหม่
local UICORNER_RADIUS = UDim.new(1, 0)
local IMAGE_TRANSPARENCY = 1 -- เฉพาะ HealthBar.HealthBar เท่านั้น

-- หา HealthBar.HealthBar และ Fill
local function findInnerAndFill()
	local core = game:GetService("CoreGui")
	local topBarApp = core:FindFirstChild("TopBarApp")
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

-- เพิ่มหรือปรับ UICorner
local function ensureUICorner(target)
	if not target or not target:IsA("GuiObject") then return end
	local existing = target:FindFirstChildOfClass("UICorner")
	if existing then
		pcall(function() existing.CornerRadius = UICORNER_RADIUS end)
	else
		local uc = Instance.new("UICorner")
		uc.CornerRadius = UICORNER_RADIUS
		uc.Parent = target
	end
end

-- ตั้ง Transparency เฉพาะ HealthBar (ถ้าเป็น ImageLabel)
local function ensureHealthBarTransparency(gui)
	if not gui or not gui:IsA("GuiObject") then return end
	if gui:IsA("ImageLabel") or gui:IsA("ImageButton") then
		pcall(function() gui.ImageTransparency = IMAGE_TRANSPARENCY end)
	end
end

-- บังคับ Fill เต็ม (X=1,Y=1)
local function forceFillFull(fill)
	if not fill or not fill:IsA("GuiObject") then return end
	pcall(function() fill.Size = UDim2.new(1, 0, 1, 0) end)
end

-- Tween Fill ตามเลือด
local function tweenFill(percent)
	if not Fill or not Fill:IsA("GuiObject") then return end
	if currentTween then pcall(function() currentTween:Cancel() end) end

	pcall(function()
		local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		currentTween = TweenService:Create(Fill, tweenInfo, { Size = UDim2.new(percent, 0, 1, 0) })
		currentTween:Play()
	end)
end

-- ตั้ง Humanoid สำหรับอัปเดต Health
local function setupHumanoid(h)
	if not h then return end
	humanoid = h
	humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if not Fill then return end
		local percent = humanoid.MaxHealth > 0 and humanoid.Health / humanoid.MaxHealth or 1
		tweenFill(math.clamp(percent, 0, 1))
	end)
end

-- ฟังก์ชันหลัก: apply ทุกอย่าง
local function applyAllFixes()
	local inner, fill = findInnerAndFill()
	innerHealthBar = inner
	Fill = fill

	if innerHealthBar then
		ensureUICorner(innerHealthBar)
		ensureHealthBarTransparency(innerHealthBar)
	end

	if Fill then
		if FORCE_FULL_ON_SPAWN then
			forceFillFull(Fill)
		end
	end
end

-- Character spawn
player.CharacterAdded:Connect(function(char)
	task.wait(0.1)
	local h = char:WaitForChild("Humanoid", 5)
	if h then
		setupHumanoid(h)
	end
	applyAllFixes()
end)

-- ถ้ามี character อยู่แล้ว
if player.Character then
	local h = player.Character:FindFirstChild("Humanoid")
	if h then
		setupHumanoid(h)
	end
	applyAllFixes()
end

-- ตรวจจับ TopBar / Fill ใหม่
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
