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

-- Menu background for tweening
local MenuBackground = InnerTopBar.UnibarLeftFrame.HealthBar.ExperienceSettings.Menu.Background

-- Tween info for closing the menu
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Function to close Menu Background with Tween (back to X=0)
local function closeMenuBackground()
    local goal = {Position = UDim2.new(0, 0, MenuBackground.Position.Y.Scale, MenuBackground.Position.Y.Offset)}
    local tween = TweenService:Create(MenuBackground, tweenInfo, goal)
    tween:Play()
end

-- Click SeeAll
SeeAll.MouseButton1Click:Connect(function()
    -- Move Menu Background instantly to X = 1
    MenuBackground.Position = UDim2.new(1, 0, MenuBackground.Position.Y.Scale, MenuBackground.Position.Y.Offset)
    
    -- Simulate click at fixed Offset (X=30, Y=30)
    local x, y = 30, 60
    VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
    
    -- Tween Menu background back to X=0 every time
    closeMenuBackground()
end)
