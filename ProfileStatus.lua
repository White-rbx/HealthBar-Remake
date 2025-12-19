-- Script ahh 1.305

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

--====================================================
-- SERVICES
--====================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

local lp = Players.LocalPlayer
--====================================================
-- CHARACTER BIND (ULTRA SAFE / MOBILE)
--====================================================
local Character = nil
local Humanoid = nil
local HRP = nil

local function ClearCharacter()
	Character = nil
	Humanoid = nil
	HRP = nil
end

local function BindCharacter(char)
	ClearCharacter()
	if not char then return end

	Character = char

	-- รอแบบปลอดภัย (ไม่ค้าง thread)
	task.spawn(function()
		HRP = char:WaitForChild("HumanoidRootPart", 15)
	end)

	task.spawn(function()
		Humanoid = char:WaitForChild("Humanoid", 15)
	end)
end

-- initial
if lp.Character then
	BindCharacter(lp.Character)
end

-- respawn
lp.CharacterAdded:Connect(BindCharacter)
lp.CharacterRemoving:Connect(ClearCharacter)

-- watchdog (กันกรณี Humanoid/HRP หายกลางทาง)
task.spawn(function()
	while true do
		if Character then
			if not Humanoid or not Humanoid.Parent then
				Humanoid = Character:FindFirstChildOfClass("Humanoid")
			end
			if not HRP or not HRP.Parent then
				HRP = Character:FindFirstChild("HumanoidRootPart")
			end
		end
		task.wait(0.2)
	end
end)

--====================================================
-- PLAYER BASIC INFO
--====================================================
-- PlayerID
Button(scr,"PlayerID","PlayerID: ...",true,255,255,255,180,180,255,
	function(btn)
		btn.Text = "PlayerID: "..lp.UserId
	end,
	function()
		if setclipboard then setclipboard(tostring(lp.UserId)) end
	end
)

-- PlayerAge
Button(scr,"PlayerAge","PlayerAge: ...",true,255,255,255,200,200,255,
	function(btn)
		btn.Text = "PlayerAge: "..lp.AccountAge.." day"
	end,
	function()
		if setclipboard then setclipboard(tostring(lp.AccountAge)) end
	end
)

-- PlayerBirth
Button(scr,"PlayerBirth","PlayerBirth: ...",true,255,255,255,200,255,200,
	function(btn)
		local birth = os.time() - (lp.AccountAge * 86400)
		local d = os.date("*t", birth)
		btn.Text = string.format("PlayerBirth: %02d/%02d/%04d", d.day,d.month,d.year)
	end,
	function()
		local birth = os.time() - (lp.AccountAge * 86400)
		local d = os.date("*t", birth)
		if setclipboard then
			setclipboard(string.format("%02d/%02d/%04d", d.day,d.month,d.year))
		end
	end
)

--====================================================
-- CAMERA MODE
--====================================================
local camText = Text(scr,"CameraMode","CameraMode: ...",false,255,255,255,255,255,255)
local function updateCam()
	camText.Text = "CameraMode: "..tostring(lp.CameraMode)
end
updateCam()
lp:GetPropertyChangedSignal("CameraMode"):Connect(updateCam)

--====================================================
-- PLACE / CREATOR
--====================================================
Button(scr,"PlaceID","PlaceID: ...",true,255,255,255,180,180,255,
	function(btn) btn.Text = "PlaceID: "..game.PlaceId end,
	function() if setclipboard then setclipboard(tostring(game.PlaceId)) end end
)

local placeInfo
pcall(function()
	placeInfo = MarketplaceService:GetProductInfo(game.PlaceId)
end)

Button(scr,"CreatorName","Creator: ...",true,255,255,255,255,220,150,
	function(btn)
		if placeInfo then
			btn.Text = "Creator: "..placeInfo.Creator.Name
		end
	end,
	function()
		if placeInfo and setclipboard then
			setclipboard(placeInfo.Creator.Name)
		end
	end
)

Button(scr,"CreatorID","CreatorID: ...",true,255,255,255,255,200,200,
	function(btn)
		if placeInfo then
			btn.Text = "CreatorID: "..placeInfo.Creator.CreatorTargetId
		end
	end,
	function()
		if placeInfo and setclipboard then
			setclipboard(tostring(placeInfo.Creator.CreatorTargetId))
		end
	end
)

------------------------------------------------
-- AFK CORE (WITH LAST AFK)
------------------------------------------------
local UserInputService = game:GetService("UserInputService")

local AFK = {}
AFK.LastActivity = tick()
AFK.LastAFKDuration = 0
AFK.IsAFK = false

local function markActivity()
	local now = tick()

	if AFK.IsAFK then
		AFK.LastAFKDuration = math.floor(now - AFK.LastActivity)
	end

	AFK.LastActivity = now
	AFK.IsAFK = false
end

UserInputService.InputBegan:Connect(markActivity)
UserInputService.InputChanged:Connect(markActivity)
UserInputService.InputEnded:Connect(markActivity)

------------------------------------------------
-- AFK UI
------------------------------------------------
local afkText = Text(
	scr,
	"AFK",
	"AFK: 00:00 | LastAFK: 00:00",
	false,
	255,255,255,
	255,255,255
)

local function fmt(sec)
	return string.format("%02d:%02d", math.floor(sec/60), sec%60)
end

task.spawn(function()
	while afkText.Parent do
		local now = tick()
		local diff = math.floor(now - AFK.LastActivity)

		if diff >= 1 then
			AFK.IsAFK = true
		end

		afkText.Text =
			"AFK: "..fmt(diff)..
			" | LastAFK: "..fmt(AFK.LastAFKDuration)

		task.wait(1)
	end
end)
------------------------------------------------
-- PLAYING TIME (HARD LOOP / NEVER STOP)
------------------------------------------------
_G.__PLAYING_TIME_START__ = _G.__PLAYING_TIME_START__ or tick()
local startTick = _G.__PLAYING_TIME_START__

local playingText = Text(
	scr,
	"PlayingTime",
	"PlayingTime: 000:00:00:00",
	false,
	200,220,255,
	200,220,255
)

local function formatTime(sec)
	local d = math.floor(sec / 86400)
	sec %= 86400
	local h = math.floor(sec / 3600)
	sec %= 3600
	local m = math.floor(sec / 60)
	local s = sec % 60
	return string.format("%03d:%02d:%02d:%02d", d,h,m,s)
end

task.spawn(function()
	while playingText.Parent do
		local elapsed = math.floor(tick() - startTick)
		playingText.Text = "PlayingTime: " .. formatTime(elapsed)
		task.wait(1)
	end
end)

--====================================================
-- WALKSPEED / JUMPPOWER (REALTIME)
--====================================================
local wsText = Text(scr,"WalkSpeed","WalkSpeed: -",false,160,200,255,160,200,255)
local jpText = Text(scr,"JumpPower","JumpPower: -",false,255,150,150,255,150,150)

task.spawn(function()
	while true do
		if Humanoid then
			wsText.Text = "WalkSpeed: "..Humanoid.WalkSpeed
			jpText.Text = "JumpPower: "..(Humanoid.UseJumpPower and Humanoid.JumpPower or Humanoid.JumpHeight)
		end
		task.wait(0.1)
	end
end)

--====================================================
-- DAMAGE / HEAL (RESPAWN SAFE)
--====================================================
local lastHp
local totalDmg, lastDmg = 0,0
local totalHeal, lastHeal = 0,0

local dmgText  = Text(scr,"Damage","BestDamage: 0 | LastDamage: 0",false,255,80,80,255,80,80)
local healText = Text(scr,"Heal","BestHeal: 0 | LastHeal: 0",false,80,255,120,80,255,120)

local function bindHealth()
	if not Humanoid then return end
	lastHp = Humanoid.Health

	Humanoid.HealthChanged:Connect(function(hp)
		if hp < lastHp then
			lastDmg = math.floor(lastHp-hp)
			totalDmg += lastDmg
			dmgText.Text = "BestDamage: "..totalDmg.." | LastDamage: "..lastDmg
		elseif hp > lastHp then
			lastHeal = math.floor(hp-lastHp)
			totalHeal += lastHeal
			healText.Text = "BestHeal: "..totalHeal.." | LastHeal: "..lastHeal
		end
		lastHp = hp
	end)
end

lp.CharacterAdded:Connect(function()
	task.wait(1)
	bindHealth()
end)
if Humanoid then bindHealth() end

--====================================================
-- DEATHS
--====================================================
local deaths = 0
local deathText = Text(scr,"Deaths","Deaths: 0",false,255,80,80,255,80,80)

local function bindDeaths()
	if not Humanoid then return end
	Humanoid.Died:Connect(function()
		deaths += 1
		deathText.Text = "Deaths: "..deaths
	end)
end

lp.CharacterAdded:Connect(function()
	task.wait(1)
	bindDeaths()
end)
if Humanoid then bindDeaths() end

--====================================================
-- INVENTORY (RESPAWN SAFE)
--====================================================
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local invText = Text(scr,"Inventory","Tools: 0",false,255,255,255,255,255,255)

local backpackConnAdd
local backpackConnRemove

local function bindBackpack()
	-- disconnect ของเก่า
	if backpackConnAdd then backpackConnAdd:Disconnect() end
	if backpackConnRemove then backpackConnRemove:Disconnect() end

	local backpack = lp:WaitForChild("Backpack")

	local function updateInv()
		local c = 0
		for _, v in ipairs(backpack:GetChildren()) do
			if v:IsA("Tool") then
				c += 1
			end
		end
		invText.Text = "Tools: "..c
	end

	backpackConnAdd = backpack.ChildAdded:Connect(updateInv)
	backpackConnRemove = backpack.ChildRemoved:Connect(updateInv)

	updateInv()
end

-- initial
bindBackpack()

-- IMPORTANT: rebinding when respawn
lp.CharacterAdded:Connect(function()
	task.wait(0.1) -- กัน race condition บนมือถือ
	bindBackpack()
end)
						
--====================================================
-- HOLDING TOOL
--====================================================
local holdText = Text(scr,"HoldingTool","HoldingTool: none",false,255,255,255,255,255,255)

task.spawn(function()
	while true do
		if Character then
			local tool = Character:FindFirstChildOfClass("Tool")
			holdText.Text = tool and ("HoldingTool: "..tool.Name) or "HoldingTool: none"
		end
		task.wait(0.1)
	end
end)

--====================================================
-- MAX HEALTH
--====================================================
local maxText = Text(scr,"MaxHealth","MaxHealth: -",false,255,80,80,255,80,80)

task.spawn(function()
	while true do
		if Humanoid then
			maxText.Text = "MaxHealth: "..math.floor(Humanoid.MaxHealth)
		end
		task.wait(0.2)
	end
end)

--====================================================
-- STANDING ON (FloorMaterial)
--====================================================
local standText = Text(scr,"StandingOn","StandingOn: Air",false,80,255,120,80,255,120)

task.spawn(function()
	while true do
		if Humanoid then
			local mat = Humanoid.FloorMaterial
			standText.Text = "StandingOn: "..(mat==Enum.Material.Air and "Air" or tostring(mat):gsub("Enum.Material.",""))
		end
		task.wait(0.1)
	end
end)------------------------------------------------
-- Position Of Character (COPYABLE)
------------------------------------------------
local posButton = Button(
	scr,
	"PositionOfCharacter",
	"Position: X: - | Y: - | Z: -",
	true,                 -- Active (กดได้)
	120,255,255,          -- Text color (Cyan)
	120,255,255,          -- Stroke color
	nil,                  -- Workin (ใช้ loop ด้านล่างแทน)
	function(btn)         -- Callback (Copy)
		if HRP and HRP.Parent then
			local p = HRP.Position
			local text = string.format(
				"X: %.2f | Y: %.2f | Z: %.2f",
				p.X, p.Y, p.Z
			)

			-- copy รองรับหลาย executor
			if setclipboard then
				setclipboard(text)
			elseif toclipboard then
				toclipboard(text)
			elseif syn and syn.set_clipboard then
				syn.set_clipboard(text)
			end
		end
	end
)

-- real-time update
task.spawn(function()
	while posButton.Parent do
		if HRP and HRP.Parent then
			local p = HRP.Position
			posButton.Text = string.format(
				"Position: X: %.2f | Y: %.2f | Z: %.2f",
				p.X, p.Y, p.Z
			)
		else
			posButton.Text = "Position: X: - | Y: - | Z: -"
		end
		task.wait(0.1)
	end
end)
------------------------------------------------
-- CharacterType (FIXED)
------------------------------------------------
local charTypeText = Text(
	scr,
	"CharacterType",
	"CharacterType: -",
	false,
	255,255,255,
	255,255,255
)

task.spawn(function()
	while charTypeText.Parent do
		if Humanoid then
			if Humanoid.RigType == Enum.HumanoidRigType.R6 then
				charTypeText.Text = "CharacterType: R6"
			elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then
				charTypeText.Text = "CharacterType: R15"
			else
				charTypeText.Text = "CharacterType: Unknown"
			end
		else
			charTypeText.Text = "CharacterType: -"
		end
		task.wait(0.3)
	end
end)

------------------------------------------------
-- Time Of Day
------------------------------------------------
local Lighting = game:GetService("Lighting")

local timeText = Button(
	scr,
	"TimeOfDay",
	"TimeOfDay: 00:00:00",
	true,
	255,230,120,       -- Yellow
	255,230,120
)

task.spawn(function()
	while timeText.Parent do
		timeText.Text = "TimeOfDay: " .. tostring(Lighting.TimeOfDay)
		task.wait(0.001)
	end
end)

-- Copy
timeText.MouseButton1Click:Connect(function()
	local t = tostring(Lighting.TimeOfDay)

	if setclipboard then
		setclipboard(t)
	elseif toclipboard then
		toclipboard(t)
	elseif syn and syn.set_clipboard then
		syn.set_clipboard(t)
	end
end)
