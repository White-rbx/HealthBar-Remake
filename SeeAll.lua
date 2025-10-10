local CG = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")

-- Chained WaitForChild for SeeAll
local SeeAll = CG:WaitForChild("TopBarApp")
                :WaitForChild("TopBarApp") -- there you go, your stupid TopBarApp
                :WaitForChild("UnibarLeftFrame")
                :WaitForChild("HealthBar")
                :WaitForChild("ExperienceSettings")
                :WaitForChild("Menu")
                :WaitForChild("Background")
                :WaitForChild("Settings")
                :WaitForChild("Pmax")
                :WaitForChild("SeeAll")

-- Chained WaitForChild for Trigger Background
local TriggerBackground = CG:WaitForChild("TopBarApp")
                        :WaitForChild("TopBarApp") -- you too, STUPID-
                        :WaitForChild("MenuIconHolder")
                        :WaitForChild("TriggerPoint")
                        :WaitForChild("Background")

SeeAll.MouseButton1Click:Connect(function()
    if TriggerBackground and SeeAll then
        local bg = CG.TopBarApp.UnibarLeftFrame.HealthBar.ExperienceSettings.Menu.Background
        -- เลื่อน background ไป X = 1
        bg.Position = UDim2.new(1, 0, bg.Position.Y.Scale, bg.Position.Y.Offset)
        
        -- จำลองคลิกเมนู Roblox
        local p, s = TriggerBackground.AbsolutePosition, TriggerBackground.AbsoluteSize
        local x, y = p.X + s.X/2, p.Y + s.Y/2
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end
end)
