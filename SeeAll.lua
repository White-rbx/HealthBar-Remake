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

-- Trigger Background for click
local TriggerBackground = InnerTopBar:WaitForChild("MenuIconHolder")
                        :WaitForChild("TriggerPoint")
                        :WaitForChild("Background")

-- Menu background for tweening
local MenuBackground = InnerTopBar.UnibarLeftFrame.HealthBar.ExperienceSettings.Menu.Background

-- Tween info
local tweenInfo = TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Function to close Menu background smoothly to X=1
local function closeMenuBackground()
    local goal = {Position = UDim2.new(1, 0, MenuBackground.Position.Y.Scale, MenuBackground.Position.Y.Offset)}
    local tween = TweenService:Create(MenuBackground, tweenInfo, goal)
    tween:Play()
end

-- Click SeeAll
SeeAll.MouseButton1Click:Connect(function()
    -- Get absolute center of TriggerBackground
    local pos, size = TriggerBackground.AbsolutePosition, TriggerBackground.AbsoluteSize
    local x = pos.X + size.X/2
    local y = pos.Y + size.Y/2
    
    -- Simulate click at the center of Background
    VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
    
    -- Tween Menu background to X=1
    closeMenuBackground()
end)
