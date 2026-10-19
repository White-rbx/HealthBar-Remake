local v_ver = [[Script ahh 2.93 Beta]]

------------------------------------------------------------------------------------------

-- =====>> Saved Functions <<=====
-- ====FUNCTION CORNER===== Example: Corner(Scale, Offset, Parent)
local function Corner(Scale, Offset, Parent)
  local Corner = Instance.new("UICorner")
  Corner.CornerRadius = UDim.new(Scale or 0, Offset or 0)
  Corner.Parent = Parent
  return Corner
end
-- =====END FUNCTION CORNER====

-- =====FUNCTION UILISTLAYOUT===== Example: ListLayout(parent, scale, offset, HZ, VT, SO, FILL)
local ListUI = {
 HCenter = Enum.HorizontalAlignment.Center,
 VCenter = Enum.VerticalAlignment.Center,
 HLeft = Enum.HorizontalAlignment.Left,
 VTop = Enum.VerticalAlignment.Top,
 HRight = Enum.HorizontalAlignment.Right,
 VBottom = Enum.VerticalAlignment.Bottom,
 FillH = Enum.FillDirection.Horizontal,
 FillV = Enum.FillDirection.Vertical,
 SCustom = Enum.SortOrder.Custom,
 SLayout = Enum.SortOrder.LayoutOrder,
 SName = Enum.SortOrder.Name
}

local function ListLayout(parent, scale, offset, HZ, VT, SO, FILL)
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(scale or 0, offset or 0)
    list.FillDirection = ListUI[FILL] or ListUI.FillH
    list.HorizontalAlignment = ListUI[HZ] or ListUI.HCenter
    list.VerticalAlignment = ListUI[VT] or ListUI.VCenter
    list.SortOrder = ListUI[SO] or ListUI.SName
    list.Parent = parent
    return list
end
-- =====END FUNCTION UILISTLAYOUT=====

-- ====FUNCTION UISTROKE===== Example: Stroke(parent, ASM, R, G, B, LJM, Tn, Transy)
local StrokeUI = {
 ASMBorder = Enum.ApplyStrokeMode.Border,
 ASMContextual = Enum.ApplyStrokeMode.Contextual,

 LJMBevel = Enum.LineJoinMode.Bevel,
 LJMMiter = Enum.LineJoinMode.Miter,
 LJMRound = Enum.LineJoinMode.Round
}

local function Stroke(parent, ASM, R, G, B, LJM, Tn, Transy)
    if not parent then return nil end

    local stroke = parent:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
    local strokeMode = typeof(ASM) == "EnumItem" and ASM
        or (type(ASM) == "string" and StrokeUI[ASM])
        or StrokeUI.ASMBorder
    local lineJoin = typeof(LJM) == "EnumItem" and LJM
        or (type(LJM) == "string" and StrokeUI[LJM])
        or StrokeUI.LJMRound

    stroke.ApplyStrokeMode = strokeMode
    stroke.Color = Color3.fromRGB(R or 255, G or 255, B or 255)
    stroke.LineJoinMode = lineJoin
    stroke.Thickness = Tn or 1
    stroke.Transparency = Transy or 0
    stroke.Parent = parent
    return stroke
end

-- Change a UIStroke color when an action cannot be completed.
local function warnStroke(target, warningColor)
    if not target then return end
    local stroke = target:FindFirstChildOfClass("UIStroke")
    if stroke then
        stroke.Color = warningColor or Color3.fromRGB(255, 0, 0)
    end
end
-- =====END FUNCTION UISTROKE=====

-- ====FUNCTION UIGRADIENT===== Example: Gradient(parent, rotation, offsetX, offsetY, {...}, {...})
local function Gradient(parent, rotation, offsetX, offsetY, colors, transparencies)
    local grad = parent:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")

    grad.Rotation = rotation or 0
    grad.Offset = Vector2.new(offsetX or 0, offsetY or 0)

    -- Color
    local colorKeypoints = {}

    if not colors or #colors == 0 then
        colorKeypoints = {
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
        }
    elseif #colors == 1 then
        colorKeypoints = {
            ColorSequenceKeypoint.new(0, colors[1]),
            ColorSequenceKeypoint.new(1, colors[1])
        }
    else
        for i, c in ipairs(colors) do
            local t = (i-1) / (#colors-1)
            table.insert(colorKeypoints, ColorSequenceKeypoint.new(t, c))
        end
    end

    grad.Color = ColorSequence.new(colorKeypoints)


    -- Transparency
    local transparencyKeypoints = {}

    if not transparencies or #transparencies == 0 then
        transparencyKeypoints = {
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 0)
        }
    elseif #transparencies == 1 then
        transparencyKeypoints = {
            NumberSequenceKeypoint.new(0, transparencies[1]),
            NumberSequenceKeypoint.new(1, transparencies[1])
        }
    else
        for i, tValue in ipairs(transparencies) do
            local t = (i-1) / (#transparencies-1)
            table.insert(
                transparencyKeypoints,
                NumberSequenceKeypoint.new(t, tValue)
            )
        end
    end

    grad.Transparency = NumberSequence.new(transparencyKeypoints)

    grad.Parent = parent
    return grad
end
-- =====END FUNCTION UIGRADIENT=====

-- ====FUNCTION UIPADDING ===== Example: Padding(parent, {X, Y}, {X, Y}, {X, Y}, {X, Y})
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

-- =====FUNCTION UIASPECTRATIONCONSTRAINT==== Example: Aspect(parent, ratio, aspectType, dominantAxis)
--// ENUM SHORTCUTS
local Axis = Enum.DominantAxis
local Type = Enum.AspectType

local AspectUI = {
    Axis = Axis,
    Type = Type,

    Width = Axis.Width,
    Height = Axis.Height,

    Fit = Type.FitWithinMaxSize,
    Scale = Type.ScaleWithParentSize
}


--// ASPECT FUNCTION
function Aspect(parent, ratio, aspectType, dominantAxis)
    if not parent then return end

    -- Numeric ratios (for example 1 or 16/9) should be used directly.
    local ratioValue = type(ratio) == "number" and ratio > 0 and ratio or nil
    local typeValue = typeof(aspectType) == "EnumItem" and aspectType
        or (type(aspectType) == "string" and AspectUI[aspectType])
    local axisValue = typeof(dominantAxis) == "EnumItem" and dominantAxis
        or (type(dominantAxis) == "string" and AspectUI[dominantAxis])

    local existing = parent:FindFirstChildOfClass("UIAspectRatioConstraint")
    if existing then
        if ratioValue then existing.AspectRatio = ratioValue end
        if typeValue then existing.AspectType = typeValue end
        if axisValue then existing.DominantAxis = axisValue end
        return existing
    end

    local constraint = Instance.new("UIAspectRatioConstraint")
    constraint.AspectRatio = ratioValue or 1
    constraint.AspectType = typeValue or AspectUI.Fit
    constraint.DominantAxis = axisValue or AspectUI.Width
    constraint.Parent = parent
    return constraint
end

-- =====END FUNCTION UIASPECTRATIONCONSTRAINT=====

--====== CLIENT SERVICES ======--

-- UI / Player Interface
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

-- 3D/2D Destroy
local Debris = game:GetService("Debris")

-- 3D Wprkspace
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera

-- Third Party
local HttpService = game:GetService("HttpService")

-- Audio / Feedback
local SoundService = game:GetService("SoundService")

-- Commerce / Monetization
local MarketplaceService = game:GetService("MarketplaceService")

-- Runtime / Frame Updates
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

-- Animation / Transitions
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

-- Input (Desktop / Mobile)
local UserInputService = game:GetService("UserInputService")
local TouchInputService = game:GetService("TouchInputService")

---------------------------------------------------------------------------------------

-- <<===== Position =====>>
local Menu = game.CoreGui:WaitForChild("TopBarApp")
                 :WaitForChild("TopBarApp")
                 :WaitForChild("UnibarLeftFrame")
                 :WaitForChild("HealthBar")
                 :WaitForChild("ExperienceSettings")
                 :WaitForChild("Menu")


-- local Menu = game:GetService("CoreGui").ExperienceSettings.Menu

-- =====>> Instance <<=====
local pro = Instance.new("Frame")
pro.Name = "ProfileStatus"
pro.Position = UDim2.new(0.25,0,1,0)
pro.Size = UDim2.new(0.5,0,0.7,0)
pro.BackgroundColor3 = Color3.fromRGB(17, 18, 25)
pro.BackgroundTransparency = 0
pro.Parent = Menu
Corner(0,8,pro)
ListLayout(pro, 0, 0, "HCenter", "VCenter", "SName", "FillV")

-- [ pro.prin ]
local prin = Instance.new("Frame")
prin.Name = "InsideProfileStatus"
prin.Size = UDim2.new(0.98,0,0.96,0)
prin.BackgroundTransparency = 1
prin.Parent = pro

-- [ pro.prin(Inside) ]
local pchar = Instance.new("Frame")
pchar.Name = "ProfileCharacter"
pchar.Active = false
pchar.Size = UDim2.new(1,0,1,0)
pchar.BackgroundTransparency = 1
pchar.BorderMode = Enum.BorderMode.Inset
pchar.BorderSizePixel = 3
pchar.Parent = prin

-- [ pro.pchar.pfhr ]
local pfhr = Instance.new("Frame")
pfhr.Name = "Holder"
pfhr.Size = UDim2.new(1,0,0,80)
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
user.Size = UDim2.new(0.6,0,0.3,0)
user.Position = UDim2.new(0,85,0,0)
user.BackgroundTransparency = 1
user.TextScaled = true
user.RichText = true
user.Text = "Getting API..."
user.TextXAlignment = Enum.TextXAlignment.Left
user.TextColor3 = Color3.fromRGB(255,255,255)
user.Parent = pfhr

-- [ pro.pchar.scr ]
local scr = Instance.new("ScrollingFrame")
scr.Name = "Scroll"
scr.Size = UDim2.new(1,0,1,-80)
scr.Position = UDim2.new(0,0,0.21,0)
scr.CanvasSize = UDim2.new(0,0,0,0)
scr.BorderMode = Enum.BorderMode.Inset
scr.BorderSizePixel = 5
scr.ScrollingDirection = Enum.ScrollingDirection.Y
scr.AutomaticCanvasSize = Enum.AutomaticSize.Y
scr.ScrollBarThickness = 0
scr.BackgroundTransparency = 1
scr.Parent = pchar
ListLayout(scr, 0, 5, "HCenter", "VTop", "SLayout", "FillV")
Corner(0,3,scr)

-- [ function Text ]
local TextExtraFunction = {}

local function Text(parent, Name, TextContent, Active, R, G, B, R1, G1, B1, lay, Workin, Function)
    local Body = Instance.new("Frame")
    Body.Name = tostring(Name or "Unknown")
    Body.Size = UDim2.new(1,-2,0,20)
    Body.BackgroundTransparency = 1
    Body.Parent = parent

    local img = Instance.new("ImageLabel")
    img.Name = "Icon"
    img.Size = UDim2.new(0,20,0,20)
    img.BackgroundTransparency = 0.8
    img.BackgroundColor3 = Color3.fromRGB(R1 or 255, G1 or 255, B1 or 255)
    img.Image = "rbxassetid://86157935898545"
    img.Parent = Body
    
    local txt = Instance.new("TextLabel")
    txt.Name = tostring(Name)
    txt.Text = tostring(TextContent)
    txt.Active = (Active ~= false)
    txt.BackgroundTransparency = 0.8
	txt.BackgroundColor3 = Color3.fromRGB(R1 or 255, G1 or 255, B1 or 255)
    txt.TextColor3 = Color3.fromRGB(R or 255, G or 255, B or 255)
    txt.TextScaled = true
	txt.RichText = true
	txt.LayoutOrder = tonumber(lay or 0)
    txt.Size = UDim2.new(1, -25, 0, 20)
    txt.Position = UDim2.new(25,0,0,0)
    txt.Parent = Body

    Corner(0, 5, txt)
    Stroke(txt, "ASMBorder", R1 or 255, G1 or 255, B1 or 255, "LJMRound", 1, 0)
    Corner(0, 5, img)
    Stroke(img, "ASMBorder", R1 or 255, G1 or 255, B1 or 255, "LJMRound", 1, 0)

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
local function Button(parent, Name, TextContent, Active, R, G, B, R1, G1, B1, lay, Workin, Callback, Function)
    local Body = Instance.new("Frame")
    Body.Name = tostring(Name or "Unknown")
    Body.Size = UDim2.new(1,-2,0,20)
    Body.BackgroundTransparency = 1
    Body.Parent = parent

    local img = Instance.new("ImageLabel")
    img.Name = "Icon"
    img.Size = UDim2.new(0,20,0,20)
    img.BackgroundColor3 = Color3.fromRGB(R1 or 255, G1 or 255, B1 or 255)
    img.BackgroundTransparency = 0.8
    img.Image = "rbxassetid://85495702622937"
    img.Parent = Body
          
    local btn = Instance.new("TextButton")
    btn.Name = tostring(Name)
    btn.Text = tostring(TextContent)
    btn.Active = (Active ~= false)
    btn.BackgroundTransparency = 0.8
	btn.BackgroundColor3 = Color3.fromRGB(R1 or 255, G1 or 255, B1 or 255)
    btn.TextScaled = true
	btn.RichText = true
	btn.TextColor3 = Color3.new(1,1,1)
    btn.Size = UDim2.new(1, -25, 0, 20)
    btn.Position = UDim2.new(25,0,0,0)
	btn.LayoutOrder = tonumber(lay or 0)
    btn.Parent = Body

    Corner(0, 5, btn)
    Stroke(btn, "ASMBorder", R1 or 255, G1 or 255, B1 or 255, "LJMRound", 1, 0)
    Corner(0, 5, img)
    Stroke(img, "ASMBorder", R1 or 255, G1 or 255, B1 or 255, "LJMRound", 1, 0)

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

local function space(parent, layoutorder, text)
	local space = Instance.new("TextLabel")
	space.Name = "Space"
	space.Size = UDim2.new(0.99,0,0,11)
	space.BackgroundTransparency = 1
    space.LayoutOrder = layoutorder or 1
	space.TextColor3 = Color3.new(1,1,1)
	space.Text = tostring("<b>" .. text .."</b>")
	space.RichText = true
	space.TextWrapped = true
	space.TextSize = 10
	space.TextXAlignment = Enum.TextXAlignment.Center
	space.TextYAlignment = Enum.TextYAlignment.Center
    space.Parent = parent
end

space(scr, 0, "You")
space(scr, 2, "Experience")
space(scr, 4, "Others")
						
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
    user.Text = "<b>" ..tostring(display).. "</b>" .. " (@" .. tostring(real) .. ")"
end)


-- Text(scr, "Beta", "It might have a bug, and still in <b>beta</b>", false, 255, 131, 131, 255, 0, 0)
--===================--
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
Button(scr,"PlayerID","PlayerID: ...",true,255,255,255,180,180,255,1,
	function(btn)
		btn.Text = "PlayerID: "..lp.UserId
	end,
	function()
		if setclipboard then setclipboard(tostring(lp.UserId)) end
	end
)

Text(
    scr,
    "FriendCount",
    "Friends in the server: 0",
    false,
    255, 255, 255,
    0, 255, 0,3,
    function(txtLabel)
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local count = 0

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local success, isFriend = pcall(function()
                    return LocalPlayer:IsFriendsWith(player.UserId)
                end)

                if success and isFriend then
                    count += 1
                end
            end
        end

        txtLabel.Text = "Friends in the server: " .. tostring(count)
    end,
    nil
)

-- PlayerAge
Button(scr,"PlayerAge","PlayerAge: ...",true,255,255,255,200,200,255,1,
	function(btn)
		btn.Text = "PlayerAge: "..lp.AccountAge.." day"
	end,
	function()
		if setclipboard then setclipboard(tostring(lp.AccountAge)) end
	end
)

-- PlayerBirth
Button(scr,"PlayerBirth","PlayerBirth: ...",true,255,255,255,200,255,200,1,
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
local camText = Text(scr,"CameraMode","CameraMode: ...",false,255,255,255,255,255,255,3)
local function updateCam()
	camText.Text = "CameraMode: "..tostring(lp.CameraMode)
end
updateCam()
lp:GetPropertyChangedSignal("CameraMode"):Connect(updateCam)

--====================================================
-- PLACE / CREATOR
--====================================================
Button(scr,"PlaceID","PlaceID: ...",true,255,255,255,180,180,255,3,
	function(btn) btn.Text = "PlaceID: "..game.PlaceId end,
	function() if setclipboard then setclipboard(tostring(game.PlaceId)) end end
)

local placeInfo
pcall(function()
	placeInfo = MarketplaceService:GetProductInfo(game.PlaceId)
end)

Button(scr,"CreatorName","Creator: ...",true,255,255,255,255,220,150,3,
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

Button(scr,"CreatorID","CreatorID: ...",true,255,255,255,255,200,200,3,
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
	255,255,255,1
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
	200,220,255,1
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

-- สร้าง TextLabel แสดงเวลาปัจจุบันตามโลกจริง
Text(
    scr,                           
    "RealTimeClock",               
	"00:00:00",                     
	false,                           
    255, 255, 255,                   
    0, 255, 255,1,          
    function(txtLabel)             
        -- ดึงเวลาปัจจุบันตามโลกจริง
        local timeData = os.date("*t")
        local formattedTime = string.format("%02d:%02d:%02d", timeData.hour, timeData.min, timeData.sec)
        
        -- อัปเดตข้อความบน TextLabel
        txtLabel.Text = "Real Time Clock: " .. formattedTime
    end,
    nil                         
						)
						
--====================================================
-- WALKSPEED / JUMPPOWER (REALTIME)
--====================================================
local wsText = Text(scr,"WalkSpeed","WalkSpeed: -",false,160,200,255,160,200,255,1)
local jpText = Text(scr,"JumpPower","JumpPower: -",false,255,150,150,255,150,150,1)

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

local dmgText  = Text(scr,"Damage","BestDamage: 0 | LastDamage: 0",false,255,80,80,255,80,80,1)
local healText = Text(scr,"Heal","BestHeal: 0 | LastHeal: 0",false,80,255,120,80,255,120,1)

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
local deathText = Text(scr,"Deaths","Deaths: 0",false,255,80,80,255,80,80,1)

local function bindDeaths()
	if not Humanoid then return end
	Humanoid.Died:Connect(function()
		deaths += 1
		deathText.Text = "Deaths: "..deaths
	end)
end

lp.CharacterAdded:Connect(function()
	task.wait()
	bindDeaths()
end)
if Humanoid then bindDeaths() end

--====================================================
-- INVENTORY (RESPAWN SAFE)
--====================================================
local invText = Text(scr,"Inventory","Tools: 0",false,255,255,255,255,255,255,1)

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
local holdText = Text(scr,"HoldingTool","HoldingTool: none",false,255,255,255,255,255,255,1)

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
local maxText = Text(scr,"MaxHealth","MaxHealth: -",false,255,80,80,255,80,80,1)

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
local standText = Text(scr,"StandingOn","StandingOn: Air",false,80,255,120,80,255,120,1)

task.spawn(function()
	while true do
		if Humanoid then
			local mat = Humanoid.FloorMaterial
			standText.Text = "StandingOn: "..(mat==Enum.Material.Air and "Air" or tostring(mat):gsub("Enum.Material.",""))
		end
		task.wait(0.1)
	end
end)
------------------------------------------------
-- Position Of Character (COPYABLE)
------------------------------------------------
local posButton = Button(
	scr,
	"PositionOfCharacter",
	"Position: X: - | Y: - | Z: -",
	true,                 -- Active (กดได้)
	120,255,255,          -- Text color (Cyan)
	120,255,255,3,        -- Stroke color
	nil,                  -- Workin (ใช้ loop ด้านล่างแทน)
	function(btn)         -- Callback (Copy)
		if HRP and HRP.Parent then
			local p = HRP.Position
			local text = string.format(
				"%.2f %.2f %.2f",
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
		task.wait(0.001)
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
	255,255,255,1
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
local timeText = Button(
	scr,
	"TimeOfDay",
	"TimeOfDay: 00:00:00",
	true,
	255,230,120,       -- Yellow
	255,230,120,3
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

------------------------------------------------
-- Developer Console Button (FIXED)
------------------------------------------------
Button(
	scr,
	"DeveloperConsole",
	"Open Developer console",
	false,
	180,220,255,          -- Light blue sky
	180,220,255,5,
	nil,                  -- ❌ Workin = ไม่ใช้
	function(btn)         -- ✅ Callback = ตอนกดจริง
		pcall(function()
			StarterGui:SetCore("DevConsoleVisible", true)
		end)
	end
)

------------------------------------------------
-- Drop tool and Drop all tools
------------------------------------------------
local function getCharacter()
	return lp.Character
end

local function getHumanoid()
	local c = getCharacter()
	return c and c:FindFirstChildOfClass("Humanoid")
end

local function getEquippedTool()
	local c = getCharacter()
	if not c then
		return nil
	end
	return c:FindFirstChildOfClass("Tool")
end

Button(
	scr,
	"DropTool",
	"Drop Tool",
	true,
	255,255,0,
	255,220,120,5,
	nil,
	function(btn)
		local tool = getEquippedTool()

		-- ตรวจสอบว่ามีไอเทม และไอเทมนั้นอนุญาตให้ทิ้งได้ไหม (CanBeDropped)
		if not tool or tool.CanBeDropped == false then
			warnStroke(btn, Color3.fromRGB(255,0,0))
			return
		end

		-- การทิ้งแบบ Backspace บนคอม: ย้าย Parent ไปไว้ใน workspace ทันทีขณะถือ
		tool.Parent = workspace
	end
)

Button(
	scr,
	"DropTools",
	"Drop all tools",
	true,
	255,120,150,
	255,80,80,5,
	nil,
	function(btn)
		local char = getCharacter()
		local hum = getHumanoid()
		local backpack = lp:FindFirstChild("Backpack")

		if not char or not hum or not backpack then
			warnStroke(btn, Color3.fromRGB(255,0,0))
			return
		end

		local failed = false

		local function drop(tool)
			if not tool:IsA("Tool") then
				return
			end

			if tool.CanBeDropped == false then
				failed = true
				return
			end

			-- ย้ายไป workspace โดยตรง
			tool.Parent = workspace
		end

		-- ทิ้งชิ้นที่ถืออยู่ออกก่อน
		for _, tool in ipairs(char:GetChildren()) do
			drop(tool)
		end

		-- สำหรับชิ้นในเป้ ต้องถือขึ้นมาก่อน แล้วค่อยทิ้งเหมือนกด Backspace
		for _, tool in ipairs(backpack:GetChildren()) do
			if tool:IsA("Tool") and tool.CanBeDropped ~= false then
				hum:EquipTool(tool)
				task.wait() -- รอให้ตัวละครถือของเสร็จเล็กน้อย
				drop(tool)
			elseif tool:IsA("Tool") and tool.CanBeDropped == false then
				failed = true
			end
		end

		if failed then
			warnStroke(btn, Color3.fromRGB(150,0,0))
		end
	end
)
