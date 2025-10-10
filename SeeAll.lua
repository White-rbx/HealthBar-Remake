local CG = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

-- Outer and inner TopBarApp
local OuterTopBar = CG:WaitForChild("TopBarApp")
local InnerTopBar = OuterTopBar:WaitForChild("TopBarApp")

-- SeeAll button
local SeeAll = InnerTopBar:WaitForChild("UnibarLeftFrame")
                :WaitForChild("HealthBar")
                :WaitForChild("ExperienceSettings")
                :WaitForChild("Menu")
                :WaitForChild("Background")
                :WaitForChild("Settings")
                :WaitForChild("Pmax")
                :WaitForChild("SeeAll")

-- Trigger background for simulating click
local TriggerBackground = InnerTopBar:WaitForChild("MenuIconHolder")
                        :WaitForChild("TriggerPoint")
                        :WaitForChild("Background")

-- Menu background for tweening
local MenuBackground = InnerTopBar.UnibarLeftFrame.HealthBar.ExperienceSettings.Menu.Background

-- Tween info for closing the menu
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

SeeAll.MouseButton1Click:Connect(function()
    if TriggerBackground and SeeAll then
        -- Move Menu Background to X = 1
        MenuBackground.Position = UDim2.new(1, 0, MenuBackground.Position.Y.Scale, MenuBackground.Position.Y.Offset)
        
        -- Simulate click properly by sending both mouse down/up with a small delay
        local p, s = TriggerBackground.AbsolutePosition, TriggerBackground.AbsoluteSize
        local x, y = p.X + s.X/2, p.Y + s.Y/2
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end
end)

-- Function to close Menu Background with Tween
local function closeMenuBackground()
    local goal = {Position = UDim2.new(0, 0, MenuBackground.Position.Y.Scale, MenuBackground.Position.Y.Offset)}
    local tween = TweenService:Create(MenuBackground, tweenInfo, goal)
    tween:Play()
end

-- Example: close menu when pressing Escape
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Escape then
        closeMenuBackground()
    end
end)

-- GitHub always doesn't let my script to latest version.
