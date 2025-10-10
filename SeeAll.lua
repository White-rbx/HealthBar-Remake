task.spawn(function()
	local CoreGui = game:GetService("CoreGui")

	-- Path ของ SeeAll
	local success, SeeAll = pcall(function()
		return CoreGui:WaitForChild("TopBarApp", 10)
			:WaitForChild("TopBarApp", 10)
			:WaitForChild("UnibarLeftFrame", 10)
			:WaitForChild("HealthBar", 10)
			:WaitForChild("ExperienceSettings", 10)
			:WaitForChild("Menu", 10)
			:WaitForChild("Background", 10)
			:WaitForChild("Settings", 10)
			:WaitForChild("Pmax", 10)
			:WaitForChild("SeeAll", 10)
	end)

	if not success or not SeeAll then
		warn("⚠️ ไม่พบ SeeAll ใน CoreGui path")
		return
	end

	-- Path ของ Roblox Menu button
	local success2, MenuButton = pcall(function()
		return CoreGui:WaitForChild("TopBarApp", 10)
			:WaitForChild("TopBarApp", 10)
			:WaitForChild("MenuIconHolder", 10)
			:WaitForChild("TriggerPoint", 10)
			:WaitForChild("Background", 10)
	end)

	if not success2 or not MenuButton then
		warn("⚠️ ไม่พบ Roblox Menu button")
		return
	end

	-- เมื่อคลิก SeeAll ให้กดปุ่มเมนู
	SeeAll.MouseButton1Click:Connect(function()
		pcall(function()
			MenuButton:Activate()
		end)
	end)
end)
