-- Script ahh 1.27

-- =====>> Saved Functions <<=====

-- ====FUNCTION CORNER=====
local function Corner(Scale, Offset, Parent)
  local Corner = Instance.new("UICorner")
  Corner.CornerRadius = UDim.new(Scale or 0, Offset or 0)
  Corner.Parent = Parent
  return Corner
end
-- =====END FUNCTION CORNER====

-- =====FUNCTION UILISTLAYOUT=====
local HCenter = Enum.HorizontalAlignment.Center
local VCenter = Enum.VerticalAlignment.Center
local HLeft = Enum.HorizontalAlignment.Left
local VTop = Enum.VerticalAlignment.Top
local HRight = Enum.HorizontalAlignment.Right
local VBottom = Enum.VerticalAlignment.Bottom
local FillH = Enum.FillDirection.Horizontal
local FillV = Enum.FillDirection.Vertical
local SCustom = Enum.SortOrder.Custom
local SLayout = Enum.SortOrder.LayoutOrder
local SName = Enum.SortOrder.Name

local function ListLayout(parent, scale, offset, HZ, VT, SO, FILL)
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(scale or 0, offset or 0)
    list.FillDirection = FILL or FillH
    list.HorizontalAlignment = HZ or HCenter
    list.VerticalAlignment = VT or VCenter
    list.SortOrder = SO or SName
    list.Parent = parent
    return list
end
-- =====END FUNCTION UILISTLAYOUT=====

-- ====FUNCTION UISTROKE=====
local ASMBorder = Enum.ApplyStrokeMode.Border
local ASMContextual = Enum.ApplyStrokeMode.Contextual

local LJMBevel = Enum.LineJoinMode.Bevel
local LJMMiter = Enum.LineJoinMode.Miter
local LJMRound = Enum.LineJoinMode.Round

local function Stroke(parent, ASM, R, G, B, LJM, Tn, Transy)
    local stroke = parent:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
    stroke.ApplyStrokeMode = ASM or ASMBorder
    stroke.Color = Color3.fromRGB(R or 255, G or 255, B or 255)
    stroke.LineJoinMode = LJM or LJMRound
    stroke.Thickness = Tn or 1
    stroke.Transparency = Transy or 0
    stroke.Parent = parent
    return stroke
end
-- =====END FUNCTION UISTROKE=====

-- ====FUNCTION UIGRADIENT=====
local function Gradient(parent, rotation, offsetX, offsetY, ...)
    local grad = parent:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
    grad.Rotation = rotation or 0
    grad.Offset = Vector2.new(offsetX or 0, offsetY or 0)

    local colors = {...}
    local keypoints = {}

    if #colors == 0 then
        keypoints = { ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.new(1,1,1)) }
    elseif #colors == 1 then
        keypoints = { ColorSequenceKeypoint.new(0, colors[1]), ColorSequenceKeypoint.new(1, colors[1]) }
    else
        for i, c in ipairs(colors) do
            local t = (i-1) / (#colors-1)
            table.insert(keypoints, ColorSequenceKeypoint.new(t, c))
        end
    end

    grad.Color = ColorSequence.new(keypoints)
    grad.Parent = parent
    return grad
end
-- =====END FUNCTION UIGRADIENT=====

-- ====FUNCTION UIPADDING (ตามลำดับ Roblox)=====
local function Padding(parent, bottom, left, right, top)
    local pad = parent:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding")
    local function toUDim(value)
        if typeof(value) == "UDim" then
            return value
        elseif type(value) == "number" then
            return UDim.new(0, value)
        elseif type(value) == "table" and #value >= 2 then
            return UDim.new(value[1] or 0, value[2] or 0)
        else
            return UDim.new(0, 0)
        end
    end

    pad.PaddingBottom = toUDim(bottom)
    pad.PaddingLeft   = toUDim(left)
    pad.PaddingRight  = toUDim(right)
    pad.PaddingTop    = toUDim(top)

    pad.Parent = parent
    return pad
end
-- =====END FUNCTION UIPADDING======

-- <<===== Position of Services =====>>
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- <<===== Position =====>>
local Menu = game.CoreGui:WaitForChild("TopBarApp")
                 :WaitForChild("TopBarApp")
                 :WaitForChild("UnibarLeftFrame")
                 :WaitForChild("HealthBar")
                 :WaitForChild("ExperienceSettings")
                 :WaitForChild("Menu")

-- =====>> Instance <<=====
local pro = Instance.new("Frame")
pro.Name = "ProfileStatus"
pro.Position = UDim2.new(0.25,0,1,0)
pro.Size = UDim2.new(0.5,0,0.7,0)
pro.BackgroundColor3 = Color3.fromRGB(0,0,0)
pro.BackgroundTransparency = 0.3
pro.Parent = Menu
Corner(0,8,pro)
Stroke(pro, ASMBorder, 255,255,255, LSMRound, 1, 0)
ListLayout(pro, 0, 0, HCenter, VCenter, SName, FillV)

-- [ pro.prin ]
local prin = Instance.new("Frame")
prin.Name = "InsideProfileStatus"
prin.Size = UDim2.new(0.98,0,0.96,0)
prin.BackgroundTransparency = 1
prin.Parent = pro

-- [ pro.prin(Inside) ]
local pchar = Instance.new("Frame")
pchar.Name = "ProfileCharacter"
pchar.Size = UDim2.new(0.5,0,1,0)
pchar.BackgroundTransparency = 1
pchar.Parent = prin

local dg = Instance.new("Frame")
dg.Name = "Debugs"
dg.Position = UDim2.new(0.5,0,0,0)
dg.Size = UDim2.new(0.5,0,1,0)
dg.BackgroundTransparency = 1
dg.Parent = prin

-- [ pro.pchar.pfhr ]
local pfhr = Instance.new("Frame")
pfhr.Name = "Holder"
pfhr.Size = UDim2.new(1,0,0.2,0)
pfhr.BackgroundTransparency = 1
pfhr.Parent = pchar

-- [ pro.pchar.pfhr.pf ]
local pf = Instance.new("ImageLabel")
pf.Name = "Profile"
pf.Size = UDim2.new(0,80,0,80)
pf.BackgroundTransparency = 0.8
pf.Image = "rbxassetid://"
pf.Parent = pfhr
Corner(0,8,pf)

-- [ pro.char.pfhr.user ]
local user = Instance.new("TextLabel")
user.Name = "Username"
user.Size = UDim2.new(0.8,0,0.3,0)
user.Position = UDim2.new(0,82,0,0)
user.BackgroundTransparency = 1
user.TextScaled = true
user.Text = "Getting API..."
user.TextXAlignment = Enum.TextXAlignment.Left
user.TextColor3 = Color3.fromRGB(255,255,255)
user.Parent = pfhr

-- [ pro.pchar.scr ]
local scr = Instance.new("ScrollingFrame")
scr.Name = "Scroll"
scr.Size = UDim2.new(1,0,0.79,0)
scr.Position = UDim2.new(0,0,0.21,0)
scr.CanvasSize = UDim2.new(0,0,5000,0)
scr.ScrollingDirection = Enum.ScrollingDirection.Y
scr.ScrollBarThickness = 0
scr.BackgroundTransparency = 1
scr.Parent = pchar
ListLayout(scr, 0, 5, HCenter, VTop, SLayout, FillV)

-- [ function Text ]
local TextExtraFunction = {}

local function Text(parent, Name, TextContent, Active, R, G, B, R1, G1, B1, Workin, Function)
    local txt = Instance.new("TextLabel")
    txt.Name = tostring(Name)
    txt.Text = tostring(TextContent)
    txt.Active = (Active ~= false)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(R or 255, G or 255, B or 255)
    txt.TextScaled = true
    txt.Size = UDim2.new(0.99, 0, 0, 30)
    txt.Parent = parent

    Corner(0, 8, txt)
    Stroke(txt, ASMBorder, R1 or 255, G1 or 255, B1 or 255, LJMRound, 1, 0)

    -- Workin loop (สคริปต์หลัก)
    if typeof(Workin) == "function" then
        task.spawn(function()
            while txt.Parent do
                Workin(txt)
                task.wait(0.05)
            end
        end)
    end

    -- Function เสริม (เก็บแยก)
    if typeof(Function) == "function" then
        TextExtraFunction[txt] = Function
    end

    return txt
end
			
-- [ pro.pchar.scr.woof ]
local wf = Instance.new("Frame")
wf.Name = "There's nothing woof!"
wf.Size = UDim2.new(1,0,0,0)
wf.BackgroundTransparency = 1
wf.Parent = scr

-- [ function Button ]
local function Button(parent, Name, TextContent, Active, R, G, B, R1, G1, B1, Workin, Callback, Function)
    local btn = Instance.new("TextButton")
    btn.Name = tostring(Name)
    btn.Text = tostring(TextContent)
    btn.Active = (Active ~= false)
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.fromRGB(R or 255, G or 255, B or 255)
    btn.TextScaled = true
    btn.Size = UDim2.new(0.99, 0, 0, 30)
    btn.Parent = parent

    Corner(0, 8, btn)
    Stroke(btn, ASMBorder, R1 or 255, G1 or 255, B1 or 255, LJMRound, 1, 0)

    -- Callback (ไม่มี debug)
    if typeof(Callback) == "function" then
        btn.MouseButton1Click:Connect(function()
            Callback(btn)
        end)
    end

    -- Workin loop (ไม่มี debug)
    if typeof(Workin) == "function" then
        task.spawn(function()
            while btn.Parent do
                Workin(btn)
                task.wait(0.05)
            end
        end)
    end

    -- Manual function
    if typeof(Function) == "function" then
        btn.Function = function(...)
            return Function(btn, ...)
        end
    end

    return btn
end

-- Load Avatar
task.spawn(function()
    local lp = Players.LocalPlayer
    local uid = lp.UserId
    pf.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. uid .. "&width=150&height=150&format=Png"
end)
-- Load Username

task.spawn(function()
    local lp = Players.LocalPlayer
    local display = lp.DisplayName or lp.Name
    local real = lp.Name or ""
    user.Text = tostring(display) .. " (@" .. tostring(real) .. ")"
end)


Text(scr, "Beta", "It might have bug and it still in beta.", false, 255, 131, 131, 255, 0, 0)
--===================--
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local Character = nil
local Humanoid = nil

local function BindCharacter(char)
	Character = char
	Humanoid = nil

	-- รอ Root ให้ชัวร์ (มือถือสำคัญมาก)
	char:WaitForChild("HumanoidRootPart", 10)
	Humanoid = char:WaitForChild("Humanoid", 10)
end

if lp.Character then
	BindCharacter(lp.Character)
end

lp.CharacterAdded:Connect(BindCharacter)
                        
------------------------------------------------
-- PlayerID
------------------------------------------------

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

Button(
	scr,
	"PlayerID",
	"PlayerID: Getting API...",
	true,
	255,255,255,        -- Text color
	180,180,255,        -- Stroke color
	function(btn)       -- Workin
		if lp and lp.UserId then
			btn.Text = "PlayerID: " .. tostring(lp.UserId)
		end
	end,
	function(btn)       -- Callback (คลิก)
		local id = tostring(lp.UserId)

		-- Copy (รองรับหลาย executor)
		if setclipboard then
			setclipboard(id)
		elseif toclipboard then
			toclipboard(id)
		elseif syn and syn.set_clipboard then
			syn.set_clipboard(id)
		end

		-- Feedback
		local stroke = btn:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Color = Color3.fromRGB(0,255,150)
			task.delay(0.4, function()
				if stroke then
					stroke.Color = Color3.fromRGB(180,180,255)
				end
			end)
		end
	end
)

Button(
	scr,
	"PlayerAge",
	"PlayerAge: Getting API...",
	true,                 -- Active
	255,255,255,          -- Text color
	200,200,255,          -- Stroke color
	function(btn)         -- Workin
		if lp then
			btn.Text = "PlayerAge: " .. tostring(lp.AccountAge) .. " day"
		end
	end,
	function(btn)         -- Callback (Copy)
		local age = tostring(lp.AccountAge)

		if setclipboard then
			setclipboard(age)
		elseif toclipboard then
			toclipboard(age)
		elseif syn and syn.set_clipboard then
			syn.set_clipboard(age)
		end
	end
)

Button(
	scr,
	"PlayerBirth",
	"PlayerBirth: Calculating...",
	true,
	255,255,255,
	200,255,200,
	function(btn) -- Workin
		if not lp then return end

		local ageDays = lp.AccountAge
		local now = os.time()
		local birth = now - (ageDays * 86400)

		local d = os.date("*t", birth)
		local text = string.format(
			"PlayerBirth: %02d/%02d/%04d",
			d.day, d.month, d.year
		)

		btn.Text = text
	end,
	function(btn) -- Copy
		local ageDays = lp.AccountAge
		local birth = os.time() - (ageDays * 86400)
		local d = os.date("*t", birth)

		local copyText = string.format(
			"%02d/%02d/%04d",
			d.day, d.month, d.year
		)

		if setclipboard then
			setclipboard(copyText)
		elseif toclipboard then
			toclipboard(copyText)
		elseif syn and syn.set_clipboard then
			syn.set_clipboard(copyText)
		end
	end
)
------------------------------------------------
-- CameraMode
------------------------------------------------
local camText = Text(
	scr,
	"CameraMode",
	"CameraMode: ...",
	false,
	255,255,255,
	255,255,255
)

local function updateCam()
	camText.Text = "CameraMode: " .. tostring(lp.CameraMode)
end

updateCam()
lp:GetPropertyChangedSignal("CameraMode"):Connect(updateCam)						
------------------------------------------------
-- PlaceID
------------------------------------------------
Button(
	scr,
	"PlaceID",
	"PlaceID: Getting...",
	true,
	255,255,255,
	180,180,255,
	function(btn)
		btn.Text = "PlaceID: " .. tostring(game.PlaceId)
	end,
	function(btn)
		local id = tostring(game.PlaceId)
		if setclipboard then setclipboard(id)
		elseif toclipboard then toclipboard(id)
		elseif syn and syn.set_clipboard then syn.set_clipboard(id) end
	end
)

------------------------------------------------
-- CreatorName
------------------------------------------------
Button(
	scr,
	"CreatorName",
	"Creator: Getting...",
	true,
	255,255,255,
	255,220,150,
	function(btn)
		local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
		local name = info.Creator.Name
		btn.Text = "Creator: " .. name .. " (@" .. name .. ")"
	end,
	function(btn)
		local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
		if setclipboard then setclipboard(info.Creator.Name) end
	end
)

------------------------------------------------
-- CreatorID
------------------------------------------------
Button(
	scr,
	"CreatorID",
	"CreatorID: Getting...",
	true,
	255,255,255,
	255,200,200,
	function(btn)
		local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
		btn.Text = "CreatorID: " .. tostring(info.Creator.CreatorTargetId)
	end,
	function(btn)
		local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
		if setclipboard then
			setclipboard(tostring(info.Creator.CreatorTargetId))
		end
	end
)

-- ===== ProfileStatus runtime helpers (paste after your Text/Button + scr setup) =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer

local debugMode = true -- false to quiet prints

-- state
local CurrentCharacter = nil
local CurrentHumanoid = nil
local CurrentHRP = nil

-- trackers
local lastHealth = nil
local totalDamage = 0
local lastDamage = 0
local totalHeal = 0
local lastHeal = 0
local deathsCount = 0

-- AFK
local lastActivity = tick()
local function markActivity() lastActivity = tick() end
UserInputService.InputBegan:Connect(function(...) markActivity() end)
UserInputService.InputChanged:Connect(function(...) markActivity() end)
UserInputService.InputEnded:Connect(function(...) markActivity() end)

-- utility safe call
local function safe(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok and debugMode then warn("[ProfileStatus] error:", err) end
    return ok, err
end

-- UI Text elements (expects your Text() function + scr exist)
-- create or reuse: AFK (MM:SS), Walkspeed, Jumppower, Damage, Heal, Deaths
local afkLabel = Text(scr, "AFKTime", "AFK: 00:00", false, 255,255,255, 255,255,255, nil)
local wsLabel  = Text(scr, "WalkSpeed", "WalkSpeed: -", false, 160,200,255, 180,180,255, nil)
local jpLabel  = Text(scr, "JumpPower", "JumpPower: -", false, 255,150,150, 255,150,150, nil)
local dmgLabel = Text(scr, "Damage", "BestDamage: 0 | LastDamage: 0", false, 255,80,80, 255,80,80, nil)
local healLabel= Text(scr, "Heal", "BestHeal: 0 | LastHeal: 0", false, 80,255,120, 80,255,120, nil)
local deathLabel = Text(scr, "Deaths", "Deaths: 0", false, 255,80,80, 255,80,80, nil)

-- update UI helpers
local function updateWalkJump()
    if CurrentHumanoid then
        local ws = CurrentHumanoid.WalkSpeed or 0
        local jp = nil
        if CurrentHumanoid.UseJumpPower then
            jp = CurrentHumanoid.JumpPower
        else
            jp = CurrentHumanoid.JumpHeight
        end
        safe(function() wsLabel.Text = "WalkSpeed: "..tostring(ws) end)
        safe(function() jpLabel.Text = "JumpPower: "..tostring(jp) end)
    else
        safe(function() wsLabel.Text = "WalkSpeed: -" end)
        safe(function() jpLabel.Text = "JumpPower: -" end)
    end
end

-- health change handlers
local function onHealthChanged(hp)
    if lastHealth == nil then lastHealth = hp; return end

    if hp < lastHealth then
        local dmg = math.floor(lastHealth - hp)
        lastDamage = dmg
        totalDamage = totalDamage + dmg
        dmgLabel.Text = "BestDamage: "..tostring(totalDamage).." | LastDamage: "..tostring(lastDamage)
        if debugMode then print("[ProfileStatus] damage", dmg, "total", totalDamage) end
    elseif hp > lastHealth then
        local heal = math.floor(hp - lastHealth)
        lastHeal = heal
        totalHeal = totalHeal + heal
        healLabel.Text = "BestHeal: "..tostring(totalHeal).." | LastHeal: "..tostring(lastHeal)
        if debugMode then print("[ProfileStatus] heal", heal, "total", totalHeal) end
    end

    lastHealth = hp
end

local function onDied()
    deathsCount = deathsCount + 1
    deathLabel.Text = "Deaths: "..tostring(deathsCount)
    if debugMode then print("[ProfileStatus] died. deaths=", deathsCount) end
end

-- bind character (attach events, init values)
local function BindCharacter(char)
    if not char then return end
    CurrentCharacter = char

    -- try find HRP and Humanoid
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    -- if not present, wait a short time (but don't block forever)
    if not hum then
        hum = char:WaitForChild("Humanoid", 6)
    end
    if not hrp then
        hrp = char:WaitForChild("HumanoidRootPart", 6) or char:FindFirstChildWhichIsA("BasePart")
    end

    CurrentHumanoid = hum
    CurrentHRP = hrp

    -- reset trackers for the new spawn
    lastHealth = nil
    lastDamage = 0
    lastHeal = 0
    totalDamage = 0
    totalHeal = 0

    -- init values
    if CurrentHumanoid then
        lastHealth = CurrentHumanoid.Health
        updateWalkJump()
        safe(function()
            CurrentHumanoid.HealthChanged:Connect(onHealthChanged)
        end)
        safe(function()
            CurrentHumanoid.Died:Connect(onDied)
        end)
        -- property watchers
        safe(function()
            CurrentHumanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(updateWalkJump)
        end)
        safe(function()
            CurrentHumanoid:GetPropertyChangedSignal("JumpPower"):Connect(updateWalkJump)
            CurrentHumanoid:GetPropertyChangedSignal("JumpHeight"):Connect(updateWalkJump)
            CurrentHumanoid:GetPropertyChangedSignal("UseJumpPower"):Connect(updateWalkJump)
        end)
    end

    if debugMode then
        print("[ProfileStatus] Bound character:", char.Name, "Humanoid:", tostring(CurrentHumanoid), "HRP:", tostring(CurrentHRP))
    end
end

-- watch for character add / respawn
if lp then
    if lp.Character then
        BindCharacter(lp.Character)
    end
    lp.CharacterAdded:Connect(function(c) BindCharacter(c) end)
else
    warn("[ProfileStatus] LocalPlayer not found")
end

-- also try to re-bind if humanoidrootpart appears later
task.spawn(function()
    while true do
        if CurrentCharacter and (not CurrentHRP or not CurrentHumanoid) then
            local hrp = CurrentCharacter:FindFirstChild("HumanoidRootPart") or CurrentCharacter:FindFirstChildWhichIsA("BasePart")
            local hum = CurrentCharacter:FindFirstChildOfClass("Humanoid")
            if hum and hrp then
                BindCharacter(CurrentCharacter)
            end
        end
        task.wait(0.5)
    end
end)

-- AFK UI update loop (MM:SS)
task.spawn(function()
    while true do
        local secs = math.floor(tick() - lastActivity)
        local mm = math.floor(secs/60)
        local ss = secs % 60
        afkLabel.Text = string.format("AFK: %02d:%02d", mm, ss)
        task.wait(1)
    end
end)

-- optional debug/heartbeat summary (toggle debugMode)
if debugMode then
    task.spawn(function()
        while true do
            local humState = CurrentHumanoid and ("H:"..tostring(CurrentHumanoid.Health)) or "H:-"
            print("[ProfileStatus][debug] HRP:", tostring(CurrentHRP) .. " Humanoid:", humState, "lastActivity:", math.floor(tick()-lastActivity))
            task.wait(3)
        end
    end)
end

-- end of ProfileStatus runtime helpers

------------------------------------------------
-- PLAYING TIME CORE (SAFE)
------------------------------------------------
_G.__PLAYING_TIME_START__ = _G.__PLAYING_TIME_START__ or tick()
local startTick = _G.__PLAYING_TIME_START__

local function formatTime(sec)
	local days = math.floor(sec / 86400)
	sec %= 86400
	local hours = math.floor(sec / 3600)
	sec %= 3600
	local minutes = math.floor(sec / 60)
	local seconds = math.floor(sec % 60)

	return string.format("%03d:%02d:%02d:%02d", days, hours, minutes, seconds)
end

Text(
	scr,
	"PlayingTime",
	"PlayingTime: 000:00:00:00",
	false,
	200,220,255,
	200,220,255,
	nil,nil,nil,
	function(txt)
		local elapsed = math.floor(tick() - startTick)
		txt.Text = "PlayingTime: " .. formatTime(elapsed)
	end,
	nil
)

------------------------------------------------
-- Inventory (Backpack Tools)
------------------------------------------------
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local backpack = lp:WaitForChild("Backpack")

local invText = Text(
	scr,
	"Inventory",
	"Tools: 0",
	false,
	255,255,255,
	255,255,255
)

local function updateBackpack()
	local count = 0
	for _, v in ipairs(backpack:GetChildren()) do
		if v:IsA("Tool") then
			count += 1
		end
	end
	invText.Text = "Tools: " .. count
end

-- initial
updateBackpack()

-- realtime
backpack.ChildAdded:Connect(updateBackpack)
backpack.ChildRemoved:Connect(updateBackpack)

------------------------------------------------
-- Holding Tool
------------------------------------------------
local holdingText = Text(
	scr,
	"HoldingTool",
	"HoldingTool: none",
	false,
	255,255,255,
	255,255,255
)

local function updateHolding(character)
	if not character then
		holdingText.Text = "HoldingTool: none"
		return
	end

	local tool = character:FindFirstChildOfClass("Tool")
	if tool then
		holdingText.Text = "HoldingTool: " .. tool.Name
	else
		holdingText.Text = "HoldingTool: none"
	end
end

-- realtime scan (safe)
task.spawn(function()
	while true do
		if Character then
			updateHolding(Character)
		end
		task.wait(0.1)
	end
end)

------------------------------------------------
-- MaxHealth
------------------------------------------------
local maxHpText = Text(
	scr,
	"MaxHealth",
	"MaxHealth: --",
	false,
	255,80,80,
	255,80,80
)

local lastMax

local function bindMaxHealth(hum)
	lastMax = hum.MaxHealth
	maxHpText.Text = "MaxHealth: " .. math.floor(hum.MaxHealth)

	hum:GetPropertyChangedSignal("MaxHealth"):Connect(function()
		if hum.MaxHealth ~= lastMax then
			lastMax = hum.MaxHealth
			maxHpText.Text = "MaxHealth: " .. math.floor(hum.MaxHealth)
		end
	end)
end

-- bind when humanoid ready
task.spawn(function()
	while true do
		if Humanoid then
			bindMaxHealth(Humanoid)
			break
		end
		task.wait()
	end
end)

------------------------------------------------
-- StandingOn (FloorMaterial)
------------------------------------------------
local standingText = Text(
	scr,
	"StandingOn",
	"StandingOn: Air",
	false,
	80,255,120,     -- Green
	80,255,120
)

task.spawn(function()
	while true do
		if Humanoid then
			local mat = Humanoid.FloorMaterial

			if mat == Enum.Material.Air then
				standingText.Text = "StandingOn: Air"
			else
				-- ตัด Enum.Material.
				local name = tostring(mat):gsub("Enum.Material.", "")
				standingText.Text = "StandingOn: " .. name
			end
		end

		task.wait(0.1)
	end
end)
