-- Well 1.792
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

-- Auto-destroy Folder 
task.spawn(function()
    local CoreGui = game:GetService("CoreGui")

    while task.wait(0.05) do
        -- หา ExperienceSettings ให้แน่นอนก่อน
        local path = CoreGui:FindFirstChild("TopBarApp")
        if path then path = path:FindFirstChild("TopBarApp") end
        if path then path = path:FindFirstChild("UnibarLeftFrame") end
        if path then path = path:FindFirstChild("HealthBar") end
        if path then path = path:FindFirstChild("ExperienceSettings") end

        if not path then
            continue
        end

        -- เก็บจำนวน child แต่ละชื่อ
        local nameCount = {}

        for _, obj in ipairs(path:GetChildren()) do
            local n = obj.Name
            nameCount[n] = nameCount[n] or {}
            table.insert(nameCount[n], obj)
        end

        -- ถ้าชื่อไหนมีมากกว่า 1 → ลบตัวที่เกินออก
        for name, list in pairs(nameCount) do
            if #list > 1 then
                -- เริ่มลบตั้งแต่ตัวที่ 2 ขึ้นไป
                for i = 2, #list do
                    list[i]:Destroy()
                end
            end
        end
    end
end)


task.wait(5)
--======BANNED======
local Menu = CoreGui:WaitForChild("ExperienceSettings", 10):WaitForChild("Menu", 10)
local valueGui = CoreGui:WaitForChild("TopBarApp, 10)
	:WaitForChild("TopBarApp, 10)
	:WaitForChild("UnibarLeftFrame", 10)
	:WaitForChild("HealthBar", 10)
	:WaitForChild("ValueFolder", 10):WaitForChild("ValueGui", 10)

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local plr = Players.LocalPlayer

-- ======== รายชื่อผู้ถูกแบน ========
local BannedList = {
    Usernames = {
        ["5teve3019D"] = true,   -- Test
        ["666ooppko"] = true,
    },

    UserIds = {
        -- ถ้ามี UserId สามารถเติมที่นี่เพิ่มได้
        -- [123456789] = true,
    }
}

-- ======== ฟังก์ชันตรวจสอบ ========
local function IsBanned(player)
    return BannedList.Usernames[player.Name] == true
        or BannedList.UserIds[player.UserId] == true
end

-- ======== ถ้าถูกแบน ========
if IsBanned(plr) then
    
    -- ปิดเมนูตลอดเวลา
    task.spawn(function()
        while task.wait(0.1) do
            Menu.Enabled = false
			valueGui.Enabled = false
        end
    end)

    -- Notification Roblox + Image
    StarterGui:SetCore("SendNotification", {
        Title = "BANNED USER";
        Text = "You cannot use ExperienceSettings.";
        Duration = 8;
        Icon = "rbxassetid://83001021035700";
    })
end
