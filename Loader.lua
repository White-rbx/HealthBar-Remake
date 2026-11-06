-- Well 4.13

-- LoaderSettings is the explicit start gate for the main script.
-- Do not run it in task.spawn: the main bootstrap must await its permission.
local loaderGateOK, loaderGateResult = pcall(function()
    local source = game:HttpGet(
        "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/Loader.lua"
    )
    local chunk, compileError = loadstring(source)
    if not chunk then error("LoaderSettings compile: " .. tostring(compileError)) end
    return chunk() -- true = authorized; false/nil = cancelled or incomplete
end)
if not loaderGateOK then
    warn("[ES][Bootstrap] Loader Settings failed; stopping Main: " .. tostring(loaderGateResult))
    return
end
if loaderGateResult ~= true then
    warn("[ES][Bootstrap] Main was not authorized by Loader Settings.")
    return
end
print("[ES][Bootstrap] Loader Settings authorized Main.")



--[[
 HELLO SCRIPTBLOX AND HAXHELL USERSSSS WHAT THE ACTUALLY HELL YOU GUYS
 DOING IN THIS RAW SCRIPT? AND YES IT'S MIGHT LOOK TOO AI SLOP BUT -
 GUIS ARE NOT MADE BY AI, ANYWAY I'M STILL LEARNING SCRIPT!

 THANK YOU FOR READINGGGGG *COUGH* *COUGH* *COUGH* *Died adorably*


  anyway you can see there's banned users. I'm not telling you how to- nah :3
]]

-- =========================================
-- RESET
-- =========================================

getgenv().ES = nil
getgenv().__ES_READY = nil
getgenv()[string.char(95, 120, 55, 95, 113)] = nil

-- =========================================
-- SAFE LOAD SETUP
-- =========================================

local ok,err =
	pcall(function()

		loadstring(
			game:HttpGet(
				"https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/loadstring/ExperienceSettings-SetUp.lua"
			)
		)()

	end)

if not ok then

	warn(
		"[ ES ERROR ] Failed to load setup:",
		err
	)

	return

end

-- =========================================
-- WAIT READY
-- =========================================

local timeout = 15
local start = tick()

repeat
	task.wait()
until
	getgenv().__ES_READY
	or getgenv()[string.char(95, 120, 55, 95, 113)]
	or tick() - start >= timeout

-- =========================================
-- TIMEOUT
-- =========================================

if tick() - start >= timeout then

	warn(
		"[ ES ERROR ] Setup timeout."
	)

	return

end

-- =========================================
-- BAN CHECK
-- =========================================

if getgenv()[string.char(95, 120, 55, 95, 113)] then

	warn(
		"You're banned from ExperienceSettings."
	)

	return

end

-- =========================================
-- ES OBJECT
-- =========================================

local ES = getgenv().ES

if not ES then

	warn(
		"[ ES ERROR ] ES missing."
	)

	return

end

-- ===== ERROR SYSTEM =====
local function catch(err)
	ES.error = true
	ES.lastError = tostring(err)
	warn("[ ES ERROR ]:", err)
end

local function safe(f)
	local ok, err = pcall(f)
	if not ok then
		catch(err)
	end
end

-- ===== SCAN SYSTEM =====
local visited = {}
local queue = {}
local scannedCount = 0

local function extractURLs(src)

	local urls = {}

	-- ""
	for url in string.gmatch(
		src,
		'HttpGet%s*%(%s*"([^"]+)"'
	) do

		if url:match("^https?://") then
			table.insert(urls,url)
		end

	end

	-- ''
	for url in string.gmatch(
		src,
		"HttpGet%s*%(%s*'([^']+)'"
	) do

		if url:match("^https?://") then
			table.insert(urls,url)
		end

	end

	-- [[ ]]
	for url in string.gmatch(
		src,
		'HttpGet%s*%(%s*%[%[(.-)%]%]'
	) do

		if url:match("^https?://") then
			table.insert(urls,url)
		end

	end

	return urls

end

local function scan(url)
	if visited[url] then return end
	visited[url] = true

	local ok, src = pcall(function()
		return game:HttpGet(url)
	end)

	if not ok then
		return catch("HttpGet failed: "..tostring(src))
	end

	if not src or src == "" then
		return catch("Empty script: "..url)
	end

	-- ✅ compile check
	local f, err = loadstring(src)
	if not f then
		return catch("Compile error: "..err.." | "..url)
	end

	-- 🔍 หา loadstring ต่อ
	for _, u in ipairs(extractURLs(src)) do
		table.insert(queue, u)
	end

	-- 📊 progress จริง
	scannedCount += 1
ES.progress =
	math.clamp(
		scannedCount * 15,
		0,
		ES.max
	)
end

-- ===== MAIN =====
local function main()

	-- 🔥 ใช้ Loader ตัวใหม่
	table.insert(queue, "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/loadstring/Loader.lua")

	while #queue > 0 do
		if ES.error then break end

		local url = table.remove(queue, 1)

		safe(function()
			scan(url)
		end)
	end

end

-- RUN
safe(main)

-- DONE
task.delay(0.5,function()
	if not ES.error then
		ES.progress = ES.max
		ES.done = true
	end
end)

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local hrp = character:WaitForChild("HumanoidRootPart")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true)


-- Monitor & auto-run (executor)
local URL = "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/main/loadstring.lua"
local CoreGui = game:GetService("CoreGui")

-- ========== HELPER ==========
-- Return both layout candidates rather than only the first one.
-- If both HealthBars exist during a Roblox UI rollout, the temporary UI
-- might still have been parented to the other HealthBar.
local function getHealthBars()
    local outer = CoreGui:FindFirstChild("TopBarApp")
    local app = outer and outer:FindFirstChild("TopBarApp")
    if not app then return nil, nil end

    local topBarFrame = app:FindFirstChild("TopBarFrame")
    local topRightFrame = topBarFrame and topBarFrame:FindFirstChild("TopRightFrame")
    local unibarLeftFrame = app:FindFirstChild("UnibarLeftFrame")

    local newBar = topRightFrame and topRightFrame:FindFirstChild("HealthBar")
    local oldBar = unibarLeftFrame and unibarLeftFrame:FindFirstChild("HealthBar")
    return newBar, oldBar
end

local function getHealthBar()
    local newBar, oldBar = getHealthBars()
    return newBar or oldBar
end

local function findExperienceSettings()
    -- It may already have been reparented by another stage of the loader.
    local direct = CoreGui:FindFirstChild("ExperienceSettings")
    if direct then return direct end

    -- Search BOTH candidates, even if the other HealthBar has priority.
    local newBar, oldBar = getHealthBars()
    return (newBar and newBar:FindFirstChild("ExperienceSettings"))
        or (oldBar and oldBar:FindFirstChild("ExperienceSettings"))
end

local function removeLoadBackground()
    local bar = getHealthBar()
    local exp = CoreGui:FindFirstChild("ExperienceSettings")
        or (bar and bar:FindFirstChild("ExperienceSettings"))
    local menu = exp and exp:FindFirstChild("Menu")
    if menu then
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
		warn(debug.traceback())
	else
		print("[Monitor] loadstring executed successfully.")
	end

	_G.HealthBarExecutedOnce = true
	reloading = false
end

-- ========== MONITOR LOOP ==========
local monitorReady = false
task.spawn(function()
	while true do
		task.wait(1)
		local hb = monitorReady and getHealthBar()
		if hb then
			local exp = CoreGui:FindFirstChild("ExperienceSettings")
                or hb:FindFirstChild("ExperienceSettings")
            if not exp then
                tryReload()
            end
		else
			-- HealthBar หาย ไม่ reload ตามที่ระบุ
		end
	end
end)
-- ==============

-- A separate entrypoint normally launches main/ExperienceSettings.lua.
-- If that entrypoint was skipped, failed or returned before creating the UI,
-- start it here *once*. Note: upload the PATCHED ExperienceSettings.lua to
-- the main branch too; main/loadstring.lua uses that path.
local UI_SOURCE_URL = "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/main/ExperienceSettings.lua"
task.spawn(function()
    task.wait(3) -- Give the normal entrypoint a chance to create the UI.
    if findExperienceSettings() then
        print("[ES][Bootstrap] UI already exists; no duplicate startup.")
        return
    end
    local env = getgenv()
    if env.__ES_UI_BOOTSTRAP_RUNNING or env.__ES_UI_SCRIPT_RUNNING then
        print("[ES][Bootstrap] UI script already in progress; monitoring it.")
        return
    end

    env.__ES_UI_BOOTSTRAP_RUNNING = true
    local ok, err = pcall(function()
        print("[ES][Bootstrap] No UI after 3s; fetching ExperienceSettings.lua...")
        local source = game:HttpGet(UI_SOURCE_URL)
        print("[ES][Bootstrap] UI source downloaded; compiling...")
        local chunk, compileError = loadstring(source)
        if not chunk then
            error("ExperienceSettings.lua compile error: " .. tostring(compileError))
        end
        print("[ES][Bootstrap] Executing ExperienceSettings.lua...")
        chunk()
    end)
    env.__ES_UI_BOOTSTRAP_RUNNING = nil
    if not ok then
        warn("[ES][Bootstrap] UI script failed: " .. tostring(err))
    elseif findExperienceSettings() then
        print("[ES][Bootstrap] ExperienceSettings UI created.")
    else
        warn("[ES][Bootstrap] ExperienceSettings.lua returned without creating UI. Make sure main/ExperienceSettings.lua is the updated dual-path file.")
    end
end)

-- Locate ExperienceSettings under either HealthBar or CoreGui.
-- Unlike a path warning, this also reports whether the bootstrap began.
local expsting
local uiDeadline = os.clock() + 45
repeat
    expsting = findExperienceSettings()
    if expsting then break end
    task.wait(0.1)
until os.clock() >= uiDeadline

if not expsting then
    local newBar, oldBar = getHealthBars()
    if newBar or oldBar then
        warn("[ExperienceSettings] HealthBar found, but no UI after 45s. Check [ES][Bootstrap] logs and verify main/ExperienceSettings.lua is updated.")
    else
        warn("[ExperienceSettings] HealthBar not found at either TopBar path within 45s (new: TopBarFrame.TopRightFrame.HealthBar; old: UnibarLeftFrame.HealthBar).")
    end
    return
end

-- Keep waiting for the loading animation, but handle a UI that has
-- already moved to CoreGui and no longer has a loading background.
local ready = false
local readyDeadline = os.clock() + 45
repeat
    local menu = expsting:FindFirstChild("Menu")
    local background = menu and menu:FindFirstChild("Load_Background")
    local skip = background and background:FindFirstChild("Skip")
    local loader = skip and skip:FindFirstChild("Loader")

    if loader and loader.Size == UDim2.new(1, 0, 1, 0) then
        ready = true
        break
    end

    if expsting.Parent == CoreGui and menu and not background then
        ready = true -- Already completed by another stage.
        break
    end

    task.wait(0.05)
until os.clock() >= readyDeadline

if not ready then
    warn("[ExperienceSettings] UI folder found, but loading animation did not finish within 45s.")
    return
end

-- Parent is temporary in either TopBar layout; move it only after loading.
if expsting.Parent ~= CoreGui then
    expsting.Parent = CoreGui
end
monitorReady = true

-- Auto-destroy Load_Background
task.wait(3)

task.spawn(function()
    local CoreGui = game:GetService("CoreGui")

    while task.wait(0.05) do
        local bar = getHealthBar()
        local exp = CoreGui:FindFirstChild("ExperienceSettings")
            or (bar and bar:FindFirstChild("ExperienceSettings"))
        local path = exp and exp:FindFirstChild("Menu")

        -- ถ้าถึงตรงนี้ได้แล้วจึงเช็ค Load_Background
        if path then
            local lb = path:FindFirstChild("Load_Background", 10)
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
        local bar = getHealthBar()
        local path = CoreGui:FindFirstChild("ExperienceSettings")
            or (bar and bar:FindFirstChild("ExperienceSettings"))

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

-- Function_Two.lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/Function_Two.lua"))()

-- BouncyAndHiglightImagsButton
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/loadstring/BouncyAndHighlightImageButton.lua"))()
print("[ BouncyAndHiglightImagsButton ] Successful loaded.")

local asrt =
	game:GetService("CoreGui")
	.ExperienceSettings
	.Menu
	.TopBar
	.Holder

local MAX_ZINDEX = 2147483646

local function SetZIndexRecursive(obj)
	pcall(function()
		obj.ZIndex = MAX_ZINDEX
	end)

	for _, child in ipairs(obj:GetDescendants()) do
		pcall(function()
			child.ZIndex = MAX_ZINDEX
		end)
	end
end

SetZIndexRecursive(asrt)

-- The main ExperienceSettings instance was moved to CoreGui above.
-- Only remove an obsolete second Menu still attached to a HealthBar.
local staleBar = getHealthBar()
local staleExp = staleBar and staleBar:FindFirstChild("ExperienceSettings")
local sata = staleExp and staleExp:FindFirstChild("Menu")
if sata then sata:Destroy() end


-- Hamburger Menu Remake
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/RecommendedScript.lua"))()

-- Editor
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/Editor.lua"))()

-- Arcsen
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/loadstring/Arcsen.lua"))()
print("[ Arcsen ] Successful loaded.")

-- Seacrh
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/Search.lua"))()
print("[ Seacrh ] Successful loaded.")

-- Anniversary (The event has ended.)
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/Anniversary.lua"))()

------------------------------------------------------------
local CoreGui = game:GetService("CoreGui")

task.spawn(function()
    while task.wait(0.2) do
        local menu = CoreGui:FindFirstChild("ExperienceSettings")
        if not menu then continue end
        
        local Menu1 = menu:FindFirstChild("Menu")
        if not Menu1 then continue end
        
        local topBar = Menu1:FindFirstChild("TopBar")
        if not topBar then continue end
        
        local holder = topBar:FindFirstChild("Holder")
        if not holder then continue end
        
        local OC = holder:FindFirstChild("a1_Open/Close")
        if not OC then continue end

        OC.BackgroundColor3 = Color3.fromRGB(255,255,255)

        local stroke = OC:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color = Color3.fromRGB(255,255,255)
        end

        if OC.Image == "rbxassetid://112166445155251" then
            OC.Image = "rbxassetid://133900380566355"
        elseif OC.Image == "rbxassetid://103716616779537" then
            OC.Image = "rbxassetid://103716616779537" -- logo 
        end
    end
end)
------------------------------------------------------------
print("[ TopBar ] Logo change successful")
print("------------------------------------------------------------")

task.spawn(function()
	local StarterGui = game:GetService("StarterGui")
    
    -- #1 Notification (Success)
    StarterGui:SetCore("SendNotification", {
        Title = "Successful loaded.";
        Text = "Thanks for using!";
        Duration = 5;
        Icon = "rbxassetid://131296854308169";
    })
    task.wait(5)
    -- #2 Notification (Info / Beta)
    StarterGui:SetCore("SendNotification", {
        Title = "Beta";
        Text = "Script is still beta.";
        Duration = 5;
        Icon = "rbxassetid://110099691300745";
    })
end)

task.wait(1)
-- ======== Secondary access check ========
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local plr = Players.LocalPlayer

local Menu = CoreGui:WaitForChild("ExperienceSettings", 10)
if Menu then Menu = Menu:FindFirstChild("Menu") end
local valueGui = getHealthBar()
if valueGui then valueGui = valueGui:FindFirstChild("ValueFolder") end
if valueGui then valueGui = valueGui:FindFirstChild("ValueGui") end

local _0x31 = {
    [string.char(85,115,101,114,110,97,109,101,115)] = {
        ["Roblox"] = true,
        ["makiro5556"] = true,
    },
    [string.char(85,115,101,114,73,100,115)] = {
        -- [123456789] = true,
		-- [11810742331] = true,
    }
}

local function _0x32(_0x33, _0x34)
    if type(_0x33) ~= "table" or not _0x34 then return false end
    local _0x35 = _0x33[string.char(85,115,101,114,110,97,109,101,115)]
        or _0x33[string.char(117,115,101,114,110,97,109,101,115)]
        or _0x33[string.char(78,97,109,101,115)]
        or _0x33[string.char(110,97,109,101,115)]
    local _0x36 = _0x33[string.char(85,115,101,114,73,100,115)]
        or _0x33[string.char(85,115,101,114,73,68,115)]
        or _0x33[string.char(117,115,101,114,73,100,115)]
        or _0x33[string.char(73,100,115)]
        or _0x33[string.char(105,100,115)]
    local function _0x37(_0x38, _0x39, _0x3A)
        if type(_0x38) ~= "table" then return false end
        for _0x3B, _0x3C in pairs(_0x38) do
            local _0x3D = _0x3A
                and type(_0x3B) == "string" and string.lower(_0x3B) == string.lower(tostring(_0x39))
                or (not _0x3A and tonumber(_0x3B) == tonumber(_0x39))
            if _0x3D and _0x3C then return true end
        end
        return false
    end
    if _0x37(_0x35, _0x34.Name, true) or _0x37(_0x36, _0x34.UserId, false) then return true end
    if _0x37(_0x33, _0x34.Name, true) or _0x37(_0x33, _0x34.UserId, false) then return true end
    for _, _0x3E in pairs(_0x33) do
        if type(_0x3E) == "table" then
            local _0x3F = _0x3E.User or _0x3E.Username or _0x3E.username or _0x3E.Name or _0x3E.name
            local _0x40 = _0x3E.UserId or _0x3E.UserID or _0x3E.userId or _0x3E.userID
            if (_0x3F and string.lower(tostring(_0x3F)) == string.lower(_0x34.Name))
                or (_0x40 and tonumber(_0x40) == _0x34.UserId) then return true end
        elseif type(_0x3E) == "string" or type(_0x3E) == "number" then
            if string.lower(tostring(_0x3E)) == string.lower(_0x34.Name)
                or tonumber(_0x3E) == _0x34.UserId then return true end
        end
    end
    return false
end

local _0x41 = getgenv()._ES
local _0x42 = type(_0x41) == "table" and _0x41 or _0x31
if _0x32(_0x42, plr) then
    task.spawn(function()
        while task.wait(0.1) do
            if Menu then pcall(function() Menu.Enabled = false end) end
            if valueGui then pcall(function() valueGui.Enabled = false end) end
        end
    end)

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "ACCESS RESTRICTED",
            Text = "You cannot use ExperienceSettings.",
            Duration = 15,
            Icon = "rbxassetid://117179620345399",
        })
    end)
    return
end

-- Set Y
local CoreGui = game:GetService("CoreGui")

local profileStatus = CoreGui:WaitForChild("ExperienceSettings", 10)
    :WaitForChild("Menu", 10)
    :WaitForChild("ProfileStatus", 10)

while not profileStatus.Parent do
    profileStatus.AncestryChanged:Wait()
end

profileStatus.Position = UDim2.new(
    profileStatus.Position.X.Scale,
    profileStatus.Position.X.Offset,
    1, -- Y Scale
    0  -- Y Offset
)
