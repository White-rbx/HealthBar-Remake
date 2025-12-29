-- Demo Test 3

--====================================================
-- SERVICES
--====================================================
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

--====================================================
-- PATHS
--====================================================
local ExperienceSettings =
	CoreGui:WaitForChild("ExperienceSettings", 10)

local Menu = ExperienceSettings:WaitForChild("Menu", 10)

local TopBarHolder =
	Menu:WaitForChild("TopBar", 10)
		:WaitForChild("Holder", 10)

local ShiftLockHolder =
	Menu:WaitForChild("HolderScreen", 10)
		:WaitForChild("Shift_Lock", 10)

--====================================================
-- TWEEN INFO
--====================================================
local PRESS_TWEEN   = TweenInfo.new(0.01, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local RELEASE_TWEEN = TweenInfo.new(0.5,  Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

--====================================================
-- STATES
--====================================================
local NORMAL_SIZE = UDim2.new(0, 34, 0.8, 0)
local PRESS_SIZE  = UDim2.new(0, 64, 0.8, 30)

local NORMAL_TRANSPARENCY = 1
local PRESS_TRANSPARENCY  = 0.2

--====================================================
-- INTERNAL STATE
--====================================================
local currentPressedButton = nil

--====================================================
-- RESET BUTTON
--====================================================
local function resetButton(btn)
	if not btn then return end

	TweenService:Create(btn, RELEASE_TWEEN, {
		BackgroundTransparency = NORMAL_TRANSPARENCY,
		Size = NORMAL_SIZE
	}):Play()

	local stroke = btn:FindFirstChild("UIStroke")
	if stroke then
		stroke.Thickness = 0
	end
end

--====================================================
-- PRESS BUTTON
--====================================================
local function pressButton(btn)
	if currentPressedButton and currentPressedButton ~= btn then
		resetButton(currentPressedButton)
	end

	currentPressedButton = btn

	TweenService:Create(btn, PRESS_TWEEN, {
		BackgroundTransparency = PRESS_TRANSPARENCY,
		Size = PRESS_SIZE
	}):Play()

	local stroke = btn:FindFirstChild("UIStroke")
	if stroke then
		stroke.Thickness = 4
	end
end

--====================================================
-- APPLY EFFECT TO IMAGEBUTTON
--====================================================
local function setupButton(btn)
	-- ❌ ignore non ImageButton
	if not btn:IsA("ImageButton") then return end

	-- ❌ ignore a3_Dragger ONLY
	if btn.Name == "a3_Dragger" then return end

	-- base style
	btn.AutoButtonColor = false
	btn.BackgroundTransparency = NORMAL_TRANSPARENCY
	btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
	btn.Size = NORMAL_SIZE

	-- UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255,255,255)
	stroke.Thickness = 0
	stroke.Parent = btn

	-- PRESS
	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			pressButton(btn)
		end
	end)

	-- RELEASE (on same button)
	btn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			if currentPressedButton == btn then
				resetButton(btn)
				currentPressedButton = nil
			end
		end
	end)
end

--====================================================
-- APPLY TO HOLDERS
--====================================================
for _, obj in ipairs(TopBarHolder:GetChildren()) do
	setupButton(obj)
end

for _, obj in ipairs(ShiftLockHolder:GetChildren()) do
	setupButton(obj)
end

--====================================================
-- GLOBAL RELEASE (ลากออก / ลากข้ามปุ่ม)
--====================================================
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		if currentPressedButton then
			resetButton(currentPressedButton)
			currentPressedButton = nil
		end
	end
end)
