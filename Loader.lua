-- Well 1.52
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
local CoreGui = game:GetService("CoreGui")
local expsting = CoreGui:WaitForChild("TopBarApp")
    :WaitForChild("TopBarApp")
    :WaitForChild("UnibarLeftFrame")
    :WaitForChild("HealthBar")
    :WaitForChild("ExperienceSettings")

-- รอ Loader พร้อม
local loader
repeat
    loader = expsting:FindFirstChild("Menu")
            and expsting.Menu:FindFirstChild("Load_Background")
            and expsting.Menu.Load_Background:FindFirstChild("Skip")
            and expsting.Menu.Load_Background.Skip:FindFirstChild("Loader")
    task.wait(0.05)
until loader and loader.Size == UDim2.new(1,0,1,0)

-- ตอนนี้ย้าย parent
expsting.Parent = CoreGui


-- Auto-destroy Load_Background
task.wait(3)

task.spawn(function()
    local CoreGui = game:GetService("CoreGui")

    while task.wait(0.05) do
        local path = CoreGui:FindFirstChild("TopBarApp")
        if path then
            path = path:FindFirstChild("TopBarApp")
        end
        if path then
            path = path:FindFirstChild("UnibarLeftFrame")
        end
        if path then
            path = path:FindFirstChild("HealthBar")
        end
        if path then
            path = path:FindFirstChild("ExperienceSettings")
        end
        if path then
            path = path:FindFirstChild("Menu")
        end

        -- ถ้าถึงตรงนี้ได้แล้วจึงเช็ค Load_Background
        if path then
            local lb = path:FindFirstChild("Load_Background")
            if lb then
                lb:Destroy()
            end
        end
    end
end)
