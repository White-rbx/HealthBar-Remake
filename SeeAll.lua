local CG = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

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
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Function to close Menu Background with Tween
local function closeMenuBackground()
    local goal = {Position = UDim2.new(1, 0, MenuBackground.Position.Y.Scale, 0)}
    local tween = TweenService:Create(MenuBackground, tweenInfo, goal)
    tween:Play()
end

-- Click SeeAll
SeeAll.MouseButton1Click:Connect(function()
    -- Move Menu Background to X = 1
    MenuBackground.Position = UDim2.new(1, 0, MenuBackground.Position.Y.Scale, MenuBackground.Position.Y.Offset)
    
    -- Simulate click at fixed Offset (X=30, Y=30)
    local x = 30
    local y = 60
    VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
    
    -- Tween Menu background back every time
    closeMenuBackground()
end)
-- I hate you
