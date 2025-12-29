-- Demo Test 3.6

--====================================================
-- SERVICES
--====================================================
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

--====================================================
-- PATHS
--====================================================
local Menu =
	CoreGui
	:WaitForChild("ExperienceSettings", 10)
	:WaitForChild("Menu", 10)

local TopBarHolder =
	Menu:WaitForChild("TopBar", 10)
	:WaitForChild("Holder", 10)

local ShiftLockHolder =
	Menu
	:WaitForChild("HolderScreen", 10)
	:WaitForChild("Shift_Lock", 10)

--====================================================
-- TWEEN INFO
--====================================================
local PRESS_TWEEN = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local RELEASE_TWEEN = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local RELEASE_UISTROKE = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

--====================================================
-- SIZE
--====================================================
local NORMAL_SIZE = UDim2.new(0, 34, 0.8, 0)
local PRESS_SIZE  = UDim2.new(0, 64, 0.8, 30)

--====================================================
-- STATE
--====================================================
local pressedButton : ImageButton? = nil

--====================================================
-- HELPERS
--====================================================
local function isDragger(btn)
	return btn.Name == "a3_Dragger"
end

local function getButtonFromInput(input)
	local guiObjects = UserInputService:GetGuiObjectsAtPosition(
		input.Position.X,
		input.Position.Y
	)

	for _, gui in ipairs(guiObjects) do
		if gui:IsA("ImageButton") and gui.Parent then
			if gui.Parent == TopBarHolder or gui.Parent == ShiftLockHolder then
				if not isDragger(gui) then
					return gui
				end
			end
		end
	end
end

local function press(btn)
	if pressedButton == btn then return end
	if pressedButton then
		release(pressedButton)
	end

	pressedButton = btn

	TweenService:Create(btn, PRESS_TWEEN, {
		BackgroundTransparency = 0.36,
		Size = PRESS_SIZE
	}):Play()

	local stroke = btn:FindFirstChild("UIStroke")
	if stroke then
		stroke.Thickness = 4
	end
end

function release(btn)
	if not btn then return end

	TweenService:Create(btn, RELEASE_TWEEN, {
		BackgroundTransparency = 1,
		Size = NORMAL_SIZE
	}):Play()

	local stroke = btn:FindFirstChild("UIStroke")
	if stroke then
		TweenService:Create(stroke, RELEASE_UISTROKE, {
			Thickness = 0
		}):Play()
	end

	if pressedButton == btn then
		pressedButton = nil
	end
end

--====================================================
-- APPLY BUTTON STYLE
--====================================================
local function setupButton(btn)
	if not btn:IsA("ImageButton") then return end
	if isDragger(btn) then return end

	btn.AutoButtonColor = false
	btn.BackgroundTransparency = 1
	btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
	btn.Size = NORMAL_SIZE

	-- UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255,255,255)
	stroke.Thickness = 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = btn

	-- mouse / touch
	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			press(btn)
		end
	end)

	btn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			release(btn)
		end
	end)
end

--====================================================
-- INIT
--====================================================
for _, v in ipairs(TopBarHolder:GetChildren()) do
	setupButton(v)
end

for _, v in ipairs(ShiftLockHolder:GetChildren()) do
	setupButton(v)
end

--====================================================
-- DRAG DETECTION (FIX STUCK BUG)
--====================================================
UserInputService.InputChanged:Connect(function(input)
	if not pressedButton then return end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement
	and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local hoverBtn = getButtonFromInput(input)
	if hoverBtn and hoverBtn ~= pressedButton then
		press(hoverBtn)
	elseif not hoverBtn then
		release(pressedButton)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		if pressedButton then
			release(pressedButton)
		end
	end
end)
