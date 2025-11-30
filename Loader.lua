-- Well 1.0
-- Monitor & auto-run (executor)
local URL = "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/main/loadstring.lua"
local CoreGui = game:GetService("CoreGui")

-- ========== HELPER ==========
local function getHealthBar()
	local ok, top = pcall(function()
		return CoreGui:FindFirstChild("TopBarApp") and CoreGui.TopBarApp:FindFirstChild("TopBarApp")
	end)
	if not ok or not top then return nil end
	local unibar = top:FindFirstChild("UnibarLeftFrame")
	if not unibar then return nil end
	return unibar:FindFirstChild("HealthBar")
end

local function removeLoadBackground()
	local ok, menu = pcall(function()
		return game:GetService("CoreGui")
			.TopBarApp.TopBarApp
			.UnibarLeftFrame.HealthBar
			.ExperienceSettings.Menu
	end)
	if ok and menu then
		local bg = menu:FindFirstChild("Load_Background")
		if bg then
			pcall(function() bg:Destroy() end)
			warn("[Monitor] Removed Load_Background before re-executing.")
		end
	end
end

-- ========== MAIN ==========
local reloading = false
_G.HealthBarExecutedOnce = _G.HealthBarExecutedOnce or false

local function tryReload()
	if reloading then return end
	reloading = true

	if _G.HealthBarExecutedOnce then
		-- ครั้งที่ 2 ขึ้นไป: ลบ Load_Background ก่อน
		removeLoadBackground()
	else
		warn("[Monitor] First-time execute, skipping Load_Background removal.")
	end

	local ok, src = pcall(function()
		return game:HttpGet(URL)
	end)
	if not ok then
		warn("HttpGet failed:", src)
		reloading = false
		return
	end

	local f, err = loadstring(src)
	if not f then
		warn("Compile failed:", err)
		reloading = false
		return
	end

	local ok2, res = pcall(f)
	if not ok2 then
		warn("Runtime error after loading:", res)
	else
		print("[Monitor] loadstring executed successfully.")
	end

	_G.HealthBarExecutedOnce = true
	reloading = false
end

-- ========== MONITOR LOOP ==========
task.spawn(function()
	while true do
		task.wait(1)
		local hb = getHealthBar()
		if hb then
			local exp = hb:FindFirstChild("ExperienceSettings")
			if not exp then
				tryReload()
			end
		else
			-- HealthBar หาย ไม่ reload ตามที่ระบุ
		end
	end
end)
-- ==============

-- Location
local expsting = game:GetService("CoreGui")
                   :WaitForChild("TopBarApp")
                   :WaitForChild("TopBarApp")
                   :WaitForChild("UnibarLeftFrame")
                   :WaitForChild("HealthBar")
                   :WaitForChild("ExperienceSettings")

expsting.Parent = CoreGui
