local CG = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")

local SeeAll = CG.TopBarApp.TopBarApp.UnibarLeftFrame.HealthBar
	.ExperienceSettings.Menu.Background.Settings.Pmax.SeeAll

SeeAll.MouseButton1Click:Connect(function()
	local menu = CG.TopBarApp.TopBarApp.MenuIconHolder.TriggerPoint.Background
	local bg = CG.TopBarApp.TopBarApp.UnibarLeftFrame.HealthBar
		.ExperienceSettings.Menu.Background
	if menu and bg then
		-- เลื่อน background ไป X = 1
		bg.Position = UDim2.new(1, 0, bg.Position.Y.Scale, bg.Position.Y.Offset)
		
		-- จำลองคลิกเมนู Roblox
		local p, s = menu.AbsolutePosition, menu.AbsoluteSize
		local x, y = p.X + s.X/2, p.Y + s.Y/2
		VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
		VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
	end
end)
