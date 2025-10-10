local CG = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")

-- Outer TopBarApp
local OuterTopBar = CG:WaitForChild("TopBarApp")
-- Inner TopBarApp
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

SeeAll.MouseButton1Click:Connect(function()
    if TriggerBackground and SeeAll then
        -- Move background to X = 1
        local bg = InnerTopBar.UnibarLeftFrame.HealthBar.ExperienceSettings.Menu.Background
        bg.Position = UDim2.new(1, 0, bg.Position.Y.Scale, bg.Position.Y.Offset)
        
        -- Simulate Roblox menu click
        local p, s = TriggerBackground.AbsolutePosition, TriggerBackground.AbsoluteSize
        local x, y = p.X + s.X/2, p.Y + s.Y/2
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end
end)
