-- Demo Test 1

-- SERVICES
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- PATH
local Holder =
	CoreGui
	:WaitForChild("ExperienceSettings", 10)
	:WaitForChild("Menu", 10)
	:WaitForChild("TopBar", 10)
	:WaitForChild("Holder", 10)

-- TWEEN INFO
local pressTweenInfo  = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local releaseTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- SIZE STATES
local NORMAL_SIZE = UDim2.new(0, 34, 0.8, 0)
local PRESS_SIZE  = UDim2.new(0, 44, 0.8, 10)

-- APPLY TO ALL IMAGEBUTTONS
for _, btn in ipairs(Holder:GetChildren()) do
	if not btn:IsA("ImageButton") then continue end

	-- initial state
	btn.BackgroundTransparency = 1
	btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
	btn.Size = NORMAL_SIZE
	btn.AutoButtonColor = false

	-- PRESS
	btn.MouseButton1Down:Connect(function()
		TweenService:Create(
			btn,
			pressTweenInfo,
			{
				BackgroundTransparency = 0.2,
				Size = PRESS_SIZE
			}
		):Play()
	end)

	-- RELEASE
	btn.MouseButton1Up:Connect(function()
		TweenService:Create(
			btn,
			releaseTweenInfo,
			{
				BackgroundTransparency = 1,
				Size = NORMAL_SIZE
			}
		):Play()
	end)
end
