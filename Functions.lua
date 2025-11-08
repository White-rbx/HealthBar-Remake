-- ===== [ Service's ] ===== 
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ===== [ Position's ] ===== 
local Background = game:GetService("CoreGui")
                   :WaitForChild("TopBarApp")
                   :WaitForChild("TopBarApp")
                   :WaitForChild("UnibarLeftFrame")
                   :WaitForChild("HealthBar")
                   :WaitForChild("ExperienceSettings")
                   :WaitForChild("Menu")
                   :WaitForChild("Background")

local Menu = game:GetService("CoreGui")
                   :WaitForChild("TopBarApp")
                   :WaitForChild("TopBarApp")
                   :WaitForChild("UnibarLeftFrame")
                   :WaitForChild("HealthBar")
                   :WaitForChild("ExperienceSettings")
                   :WaitForChild("Menu")

local hr = Menu:WaitForChild("TopBar")
               :WaitForChild("Holder")

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

local function createUIListLayout(parent, scale, offset, HZ, VT, SO, FILL)
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

-- About Button
-- Settings button (on hr)
local Abt = Instance.new("ImageButton")
Abt.Name = "z7_About"
Abt.Size = UDim2.new(0, 34, 0.8, 0)
Abt.Image = "rbxassetid://97370032987773"
Abt.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Abt.BackgroundTransparency = 1
Abt.Active = true
Abt.Visible = true
Abt.Parent = hr
Corner(1, 0, Abt)

local sta = Instance.new("ImageButton")
sta.Name = "a2_Status"
sta.Size = UDim2.new(0, 34, 0.8, 0)
sta.Image = "rbxassetid://116259694864857"
sta.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sta.BackgroundTransparency = 1
sta.Active = true
sta.Visible = false
sta.Parent = hr
Corner(1, 0, sta)


-- ===== Instance =====
local Inner = Instance.new("Frame")
Inner.Name = "Inner_Background"
Inner.Visible = false
Inner.Active = false
Inner.BackgroundColor3 = Color3.fromRGB(0,0,0)
Inner.BackgroundTransparency = 0.5
Inner.Position = UDim2.new(-1,0,0,0)
Inner.Size = UDim2.new(1,0,1,0)
Inner.Parent = Background
Corner(0.02, 0, Inner)

local Toggle = Instance.new("Frame")
Toggle.Name = "Toggles"
Toggle.Active = false
Toggle.BackgroundColor3 = Color3.fromRGB(0,0,0)
Toggle.BackgroundTransparency = 0.5
Toggle.Position = UDim2.new(0.02,0,0.02,0)
Toggle.Size = UDim2.new(0.96,0,0.96,0)
Toggle.Parent = Inner
Corner(0.02, 0, Toggle)

local BFrame = Instance.new("Frame")
BFrame.Name = "B_Frame"
BFrame.BackgroundTransparency = 1
BFrame.Position = UDim2.new(0.02,0,0.02,0)
BFrame.Size = UDim2.new(0.96,0,0.96,0)
BFrame.Parent = Toggle
createUIListLayout(BFrame, 0.005, 0, HCenter, VTop, SName, FillV)

-- =======================
-- =====>> Loading <<=====
local bk = Instance.new("Frame")
bk.Name = "Load_Background"
bk.Size = UDim2.new(0.4,0,0.4,0)
bk.Position = UDim2.new(0.3,0,0.3,0)
bk.BackgroundColor3 = Color3.fromRGB(0,0,0)
bk.BackgroundTransparency = 0.5
bk.Visible = true
bk.Parent = Menu
Corner(0, 10, bk)
Stroke(bk, ASMBorder, 255, 255, 255, LSMRound, 1, 0)

local line = Instance.new("Frame")
line.Name = "Line"
line.Position = UDim2.new(0.02,0,0.23,0)
line.Size = UDim2.new(0.96,0,0,1)
line.BackgroundColor3 = Color3.fromRGB(255,255,255)
line.Parent = bk
Corner(1,0,line)

local lg = Instance.new("TextLabel")
lg.Name = "Loading"
lg.BackgroundTransparency = 1
lg.Position = UDim2.new(0.02,0,0.02,0)
lg.Size = UDim2.new(0.96,0,0.2,0)
lg.Text = "Loading"
lg.TextSize = 20
lg.TextColor3 = Color3.fromRGB(255,255,255)
lg.Parent = bk

local wt = Instance.new("TextLabel")
wt.Name = "Wait"
wt.BackgroundTransparency = 1
wt.Position = UDim2.new(0.02,0,0.25,0)
wt.Size = UDim2.new(0.96,0,0.35,0)
wt.Text = "Starting ExperienceSettings. Please wait..."
wt.TextScaled = true
wt.TextColor3 = Color3.fromRGB(255,255,255)
wt.Parent = bk

local wl = Instance.new("TextLabel")
wl.Name = "Credit"
wl.BackgroundTransparency = 1
wl.Position = UDim2.new(0.02,0,0.65,0)
wl.Size = UDim2.new(0.96,0,0.13,0)
wl.Text = "Creator by @5teve on ScriptBlox"
wl.TextScaled = true
wl.TextColor3 = Color3.fromRGB(255,255,255)
wl.Parent = bk

local skp = Instance.new("TextButton")
skp.Name = "Skip"
skp.BackgroundTransparency = 0.8
skp.BackgroundColor3 = Color3.fromRGB(255,255,255)
skp.Position = UDim2.new(0.02,0,0.8,0)
skp.Size = UDim2.new(0.96,0,0.15,0)
skp.Text = "Skip"
skp.TextScaled = true
skp.TextColor3 = Color3.fromRGB(255,255,255)
skp.Parent = bk
Corner(0,8,skp)
Stroke(skp, ASMBorder, 255, 255, 255, LSMRound, 1, 0)

-- =====>> Button About <<=====
local Ab = Instance.new("Frame")
Ab.Name = "About_Background"
Ab.Active = false
Ab.Position = UDim2.new(0.25,0,1,0)
Ab.Size = UDim2.new(0.5,0,0.7,0)
Ab.BackgroundColor3 = Color3.fromRGB(11,11,21)
Ab.BackgroundTransparency = 0.3
Ab.Parent = Menu
Corner(0,12,Ab)
Stroke(Ab, ASMBorder, 255, 255, 255, LSMRound, 1, 0)

local In = Instance.new("Frame")
In.Name = "Inside"
In.Active = false
In.Size = UDim2.new(0.96,0,0.96,0)
In.Position = UDim2.new(0.02,0,0.02,0)
In.BackgroundTransparency = 1
In.Parent = Ab

local in1 = Instance.new("Frame")
in1.Name = "Inside.2"
in1.Active = false
in1.Size = UDim2.new(1,0,0,100)
in1.BackgroundTransparency = 1
in1.Parent = In
createUIListLayout(in1, 0, 5, HLeft, VTop, SName, FillH)

local imag = Instance.new("ImageLabel")
imag.Name = "a1_Icon"
imag.Active = false
imag.Size = UDim2.new(0,100,0,100)
imag.BackgroundTransparency = 0.3
imag.Image = "rbxassetid://124343752460868"
imag.Parent = in1
Corner(0, 8, imag)

local iN2 = Instance.new("Frame")
iN2.Name = "a2_txts"
iN2.Active = false
iN2.Size = UDim2.new(0.5,0,0,40)
iN2.BackgroundTransparency  = 1
iN2.Parent = in1

local txt = Instance.new("TextLabel")
txt.Name = "Name"
txt.Active = false
txt.TextXAlignment = Enum.TextXAlignment.Left
txt.Size = UDim2.new(1,0,0,40)
txt.BackgroundTransparency = 1
txt.Text = "@5teve"
txt.TextColor3 = Color3.fromRGB(255,255,255)
txt.TextScaled =  true
txt.Parent = iN2

local txt2 = Instance.new("TextLabel")
txt2.Name = "Name"
txt2.Active = false
txt2.TextXAlignment = Enum.TextXAlignment.Left
txt2.Size = UDim2.new(1,0,0,35)
txt2.Position = UDim2.new(0,0,0,36)
txt2.BackgroundTransparency = 1
txt2.Text = "“Creator of the ExperiencSettings.”"
txt2.TextColor3 = Color3.fromRGB(255,255,255)
txt2.TextScaled =  true
txt2.Parent = iN2

local txt3 = Instance.new("TextLabel")
txt3.Name = "Name"
txt3.Active = false
txt3.TextXAlignment = Enum.TextXAlignment.Left
txt3.Size = UDim2.new(1,0,0,15)
txt3.Position = UDim2.new(0,0,0,70)
txt3.BackgroundTransparency = 1
txt3.Text = "[ User on ScriptBlox ]"
txt3.TextColor3 = Color3.fromRGB(255,255,255)
txt3.TextScaled =  true
txt3.Parent = iN2

local bigt = Instance.new("TextLabel")
bigt.Name = "About"
bigt.Active = false
big.Size = UDim2.new(1,0,0.6,0)
bigt.Position = UDim2.new(0,0,0.26,0)
bigt.BackgroundTransparency = 1
bigt.Text = [[
The ExperienceSettings is debug tools you can use on your own, there are a lot of tools!
For HealthBar was a remake of better and smoother and ValueLabels for show values.
If your ExperienceSettings was Disabled there are three reasons,
 • HumanoidRootPart was removed too long.
 • The Experience doesn't support the ExperienceSettings.
 • Script failed to load.
If you enjoy it, you can support me on ScriptBlox!
Thank you for using ExperienceSettings!

Creator: @5teve (Gui, Little Script)
Helper: ChatGPT (Script) <-- He got a lot of complaints lol.
Fun fact: Old is ugly than now lol I swear 😂 Oh, you haven't seen it :(

========================
➕ = Add something
📢 = Announcements
🔨 = In-develop
🔷 = Plan ahead for updates
✅ = Done
⚠️ = Have issues
🟠 = Updating soon
❌ = Bug
⚫ = Cannot fix
➖ = Disconnected or discontinued
-------
📌 Updated:Nothing
-------
🔁 In progress:
 🔨 Creating FreeCam for all devices
 🔨 Creating Status Profile (Debug)
 🔨 Updating AI Open Source (In develop)
 🔷 Moveable HealthBar and ValueLabels
-------
]]
bigt.TextColor3 = Color3.fromRGB(255,255,255)
bigt.TextScaled = true
bigt.TextXAlignment = Enum.TextXAlignment.Left
bigt.TextYAlignment = Enum.TextYAlignment.Top
bigt.Parent = In
Stroke(bigt, ASMBorder, 255,255,255, LSMRound, 1, 0.5)

local tip = Instance.new("TextLabel")
tip.Name = "Help"
tip.Active = false
tip.Size = UDim2.new(0.8,0,0,30)
tip.Position = UDim2.new(0,0,0.88,0)
tip.BackgroundTransparency = 1
tip.TextColor3 = Color3.fromRGB(255,255,255)
tip.TextScaled = true
tip.Text = "Oh, if the ExperienceSettings was disabled. You can hide the text there -->>"
tip.Parent = In

local hid = Instance.new("TextButton")
hid.Name = "Hide"
hid.Active = true
hid.Position = UDim2.new(0.8,0,0.88,0)
hid.Size = UDim2.new(0.2,0,0,30)
hid.BackgroundTransparency = 1
hid.Text = "Hide"
hid.TextScaled = true
hid.TextColor3 = Color3.fromRGB(255,255,255)
hid.Parent = In
Corner(1,0,hid)
Stroke(hid, ASMBorder, 255, 255, 255, LSMRound, 1, 0)

-- หาปุ่ม About ด้วย WaitForChild (ใน CoreGui)
local aboutButton = game:GetService("CoreGui")
	:WaitForChild("TopBarApp")
	:WaitForChild("TopBarApp")
	:WaitForChild("UnibarLeftFrame")
	:WaitForChild("HealthBar")
	:WaitForChild("ExperienceSettings")
	:WaitForChild("Menu")
	:WaitForChild("TopBar")
	:WaitForChild("Holder")
	:WaitForChild("z7_About")

-- ตัวแปรสถานะเปิด/ปิด
local aboutOpen = false

-- Tween การเคลื่อนตำแหน่งของ Ab
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

aboutButton.MouseButton1Click:Connect(function()
	local Ab = Ab
	if not Ab then return end

	aboutOpen = not aboutOpen

	local targetPos = aboutOpen
		and UDim2.new(0.25, 0, 0.2, 0)  -- เปิด
		or  UDim2.new(0.25, 0, 1, 0)    -- ปิด

	game:GetService("TweenService"):Create(Ab, tweenInfo, { Position = targetPos }):Play()
end)

-- =====>> Script <<=====
skp.MouseButton1Click:Connect(function()
	if bk then
		bk.Visible = false
	end
end)

task.spawn(function()
	local cg = game:GetService("CoreGui")
	local top = cg:WaitForChild("TopBarApp"):WaitForChild("TopBarApp")
	local unibar = top:WaitForChild("UnibarLeftFrame")
	local hb = unibar:WaitForChild("HealthBar")
	local exp = hb:WaitForChild("ExperienceSettings")
	local menu = exp:WaitForChild("Menu")
	local topbar = menu:WaitForChild("TopBar")
	local holder = topbar:WaitForChild("Holder")
	local sta = holder:WaitForChild("a2_Status")

	local function checkHolderSize()
		local x = holder.Size.X.Offset
		if x > 160 then
			sta.Visible = true
		else
			sta.Visible = false
		end
	end

	-- ตรวจทันทีตอนเริ่ม
	checkHolderSize()

	-- อัปเดตเมื่อ Size เปลี่ยน
	holder:GetPropertyChangedSignal("Size"):Connect(checkHolderSize)
end)

task.spawn(function()
	local cg = game:GetService("CoreGui")
	local top = cg:WaitForChild("TopBarApp"):WaitForChild("TopBarApp")
	local unibar = top:WaitForChild("UnibarLeftFrame")
	local hb = unibar:WaitForChild("HealthBar")
	local exp = hb:WaitForChild("ExperienceSettings")
	local menu = exp:WaitForChild("Menu")
	local topbar = menu:WaitForChild("TopBar")
    local holder = topbar:WaitForChild("Holder")
	local loadFrame = holder:WaitForChild("LoadFrame")     
	local bg = menu:WaitForChild("About_Background")
	local inside = bg:WaitForChild("Inside")
	local hideBtn = inside:WaitForChild("Hide")             

	local function setHideEnabled(enabled)
		if not hideBtn then return end
		pcall(function()
			hideBtn.Active = enabled
			if hideBtn:IsA("GuiButton") then
				hideBtn.AutoButtonColor = enabled
			end
			hideBtn.TextTransparency = enabled and 0 or 0.6
		end)
	end

	local function updateState()
		local ok, vis = pcall(function() return loadFrame.Visible end)
		if ok and vis then
			setHideEnabled(true)
		else
			setHideEnabled(false)
		end
	end

	if loadFrame then
		updateState()
		local sOK = pcall(function()
			loadFrame:GetPropertyChangedSignal("Visible"):Connect(updateState)
		end)
		if not sOK then
			task.spawn(function()
				local last = nil
				while true do
					local ok2, cur = pcall(function() return loadFrame.Visible end)
					if ok2 and cur ~= last then
						updateState()
						last = cur
					end
					task.wait(0.25)
				end
			end)
		end
	end

	-- ✅ เฉพาะ holder และ topbar เท่านั้น
	if hideBtn and hideBtn:IsA("GuiButton") then
		hideBtn.MouseButton1Click:Connect(function()
			local ok, cur = pcall(function() return loadFrame.Visible end)
			if not ok or not cur then return end

			pcall(function()
				local info = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(holder, info, { Size = UDim2.new(0, 44, 1, 0) }):Play()
				TweenService:Create(topbar, info, { Position = UDim2.new(0.47, 0, 0.02, 0) }):Play()
				task.wait(0.3)
				loadFrame.Visible = false
			end)

			setHideEnabled(false)
		end)
	end
end)

-- Full ExperienceSettings TopBar controls (LocalScript)
local TweenService = game:GetService("TweenService")
local cg = game:GetService("CoreGui")

-- wait core UI
local root = cg:WaitForChild("TopBarApp"):WaitForChild("TopBarApp")
local holder = root:WaitForChild("UnibarLeftFrame")
	:WaitForChild("HealthBar"):WaitForChild("ExperienceSettings")
	:WaitForChild("Menu"):WaitForChild("TopBar"):WaitForChild("Holder")
local menu = holder.Parent.Parent
local topbar = menu:WaitForChild("TopBar")
local holderRef = holder

-- BUTTON NAMES
local BUTTON_NAMES = {
	"z8_ChatGPT",
	"z7_About",
	"a3_Settings",
	"a2_Status",
}

-- ICONS (OPEN / CLOSE) — ใช้ id ที่ให้มา
local ICONS = {
	z8_ChatGPT = {
		OPEN  = "rbxassetid://73936905825225",
		CLOSE = "rbxassetid://100183093743893",
	},
	z7_About = {
		OPEN  = "rbxassetid://132997296544985",
		CLOSE = "rbxassetid://97370032987773",
	},
	a3_Settings = {
		OPEN  = "rbxassetid://137006295894798",
		CLOSE = "rbxassetid://130405026545116",
	},
	a2_Status = {
		OPEN  = "rbxassetid://116259694864857",
		CLOSE = "rbxassetid://107706370299068",
	},
}

-- Optional mapping button -> panel (adjust names to your GUI)
local PANEL_MAP = {
	z7_About = "About_Background",
	z8_ChatGPT = "ChatGPT_Panel",
	a3_Settings = "Settings_Background",
}

-- convenience getter
local function getBtn(name)
	local ok, v = pcall(function() return holderRef:FindFirstChild(name) end)
	if ok and v and (v:IsA("ImageButton") or v:IsA("ImageLabel") or v:IsA("GuiButton")) then
		return v
	end
	return nil
end

local function setIcon(btn, img)
	if not btn then return end
	pcall(function() btn.Image = img end)
end

local function setButtonOpen(name, open)
	local data = ICONS[name]
	if not data then return end
	local btn = getBtn(name)
	if not btn then return end
	pcall(function() btn.Image = open and data.OPEN or data.CLOSE end)
end

-- init all icons to CLOSE (default)
for _, n in ipairs(BUTTON_NAMES) do
	setButtonOpen(n, false)
end

-- ---------- a2_Status logic ----------
local loadFrame = holderRef:FindFirstChild("LoadFrame") -- may exist
local statusBtn = getBtn("a2_Status")

local function updateStatusVisibility()
	if not statusBtn then return end

	-- 1) priority: LoadFrame.Visible == true -> status.Visible = false
	local okLoad, loadVisible = pcall(function() return loadFrame and loadFrame.Visible end)
	if okLoad and lonupisible then
		pcall(function() statusBtn.Visible = false end)
		setButtonOpen("a2_Status", false)
		return
	end

	-- 2)createToggleleder.Size.X (prefer Offset logic as specified)
	local okSize, sizeX = pcall(function() return holderRef.Size.X end)
	if not okSize or not sizeX then
		-- fallback default visible true
		pcall(function() statusBtn.Visible = true end)
		setButtonOpen("a2_Status", true)
		return
	end

	-- safely try to read Offset and Scale
	local offset = nil
	local scale = nil
	pcall(function()
		-- sizeX may be a UDim; access in a pcall to avoid errors
		offset = sizeX.Offset
		scale = sizeX.Scale
	end)

	-- if Scale is present and > 0 treat as expanded -> hide
	if type(scale) == "number" and scale > 0 then
		pcall(function() statusBtn.Visible = false end)
		setButtonOpen("a2_Status", false)
		return
	end

	-- apply rules for Offset (numeric)
	-- If Offset == 265 => Visible = true
	-- If Offset > 265  => Visible = false
	-- If Offset == 90  => Visible = false
	-- If Offset == 44  => Visible = false
	-- Else default true
	if type(offset) == "number" then
		if offset == 265 then
			pcall(function() statusBtn.Visible = true end)
			setButtonOpen("a2_Status", true)
		elseif offset > 265 then
			pcall(function() statusBtn.Visible = false end)
			setButtonOpen("a2_Status", false)
		elseif offset == 90 or offset == 44 then
			pcall(function() statusBtn.Visible = false end)
			setButtonOpen("a2_Status", false)
		else
			pcall(function() statusBtn.Visible = true end)
			setButtonOpen("a2_Status", true)
		end
	else
		-- fallback default
		pcall(function() statusBtn.Visible = true end)
		setButtonOpen("a2_Status", true)
	end
end

-- initial and connections for a2_Status
updateStatusVisibility()
if loadFrame then
	pcall(function() loadFrame:GetPropertyChangedSignal("Visible"):Connect(updateStatusVisibility) end)
end
holderRef:GetPropertyChangedSignal("Size"):Connect(function() task.defer(updateStatusVisibility) end)
holderRef:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() task.defer(updateStatusVisibility) end)

-- ---------- a3_Settings logic ----------
-- Background variable: use existing Background if present, otherwise try to find
local Background = Background or menu:FindFirstChild("Background") or menu:FindFirstChild("About_Background")
local settingsBtn = getBtn("a3_Settings")

local function updateSettingsIcon()
	if not settingsBtn then return end
	local img = ICONS.a3_Settings.CLOSE
	if Background then
		local ok, pos = pcall(function() return Background.Position end)
		if ok and pos and pos.X then
			-- prefer Scale
			if pos.X.Scale ~= nil then
				if pos.X.Scale == 1 then
					img = ICONS.a3_Settings.CLOSE
				elseif pos.X.Scale <= 0.7 then
					img = ICONS.a3_Settings.OPEN
				else
					img = ICONS.a3_Settings.CLOSE
				end
			else
				-- fallback to Offset: treat 0 (or <1) as open, >=1 as closed
				local off = pos.X.Offset or 1
				if off == 0 or off < 1 then
					img = ICONS.a3_Settings.OPEN
				else
					img = ICONS.a3_Settings.CLOSE
				end
			end
		end
	end
	setIcon(settingsBtn, img)
end

updateSettingsIcon()
if Background then
	pcall(function()
		Background:GetPropertyChangedSignal("Position"):Connect(function() task.defer(updateSettingsIcon) end)
	end)
end

-- ---------- click behavior: toggle icon + toggle mapped panels ----------
for _, name in ipairs(BUTTON_NAMES) do
	local btn = getBtn(name)
	if btn and btn:IsA("GuiButton") then
		btn.MouseButton1Click:Connect(function()
			-- determine current icon state
			local curImg = tostring(btn.Image or "")
			local openId = ICONS[name] and ICONS[name].OPEN or ""
			local isOpen = (curImg == openId)

			-- toggle icon
			setButtonOpen(name, not isOpen)

			-- toggle associated panel if mapped
			local panelName = PANEL_MAP[name]
			if panelName then
				local ok, panel = pcall(function() return menu:FindFirstChild(panelName) end)
				if ok and panel and panel:IsA("GuiObject") then
					pcall(function() panel.Visible = not panel.Visible end)
				end
			end
		end)
	end
end

-- ---------- Hide button (tween holder & topbar) ----------
do
	local hideBtn = nil
	pcall(function()
		local bg = menu:FindFirstChild("Background") or menu:FindFirstChild("About_Background")
		if bg then
			local inside = bg:FindFirstChild("Inside")
			if inside then hideBtn = inside:FindFirstChild("Hide") end
		end
	end)

	if hideBtn and hideBtn:IsA("GuiButton") then
		-- enable only when LoadFrame.Visible == true
		local function setHideEnabled(enabled)
			pcall(function()
				hideBtn.Active = enabled
				hideBtn.AutoButtonColor = enabled
				hideBtn.TextTransparency = enabled and 0 or 0.6
			end)
		end

		if loadFrame then
			local function updateHideEnable()
				local ok, vis = pcall(function() return loadFrame.Visible end)
				if ok and vis then setHideEnabled(true) else setHideEnabled(false) end
			end
			updateHideEnable()
			pcall(function() loadFrame:GetPropertyChangedSignal("Visible"):Connect(updateHideEnable) end)
		end

		hideBtn.MouseButton1Click:Connect(function()
			local ok, vis = pcall(function() return loadFrame and loadFrame.Visible end)
			if not ok or not vis then return end

			pcall(function()
				local info = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(holderRef, info, { Size = UDim2.new(0,44,1,0) }):Play()
				TweenService:Create(topbar, info, { Position = UDim2.new(0.47,0,0.02,0) }):Play()
				task.wait(0.32)
				loadFrame.Visible = false
				-- update dependent status
				updateStatusVisibility()
			end)
		end)
	end
end

-- done

-- =====>> Force Loop <<=====

--- Ensure Ab stays visible without blocking other code
task.spawn(function()
    while task.wait(0.005) do
        if Ab.Visible == false then
            Ab.Visible = true
        end
    end
end)

-- ===== END =====

-- Toggle builder
local toggleCount = 0
local function createToggle(parent, text, callback, defaultState)
    toggleCount += 1

    local f = Instance.new("Frame")
    f.Name = "Frame" .. toggleCount
    f.Size = UDim2.new(1,0,0.05,0)
    f.BackgroundTransparency = 0
    f.Parent = parent
    Corner(0.3, 0, f)

    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(0.4,0,1,0)
    bar.Position = UDim2.new(0.6,0,0,0)
    bar.BackgroundColor3 = Color3.fromRGB(66,66,66)
    bar.Parent = f
    Corner(0.3,0,bar)

    local but = Instance.new("TextButton")
    but.Name = "ToggleButton"
    but.Size = UDim2.new(0.5,0,1,0)
    but.Parent = bar
    Corner(0.3,0,but)

    local txt = Instance.new("TextLabel")
    txt.Name = "Label"
    txt.Size = UDim2.new(0.6,0,1,0)
    txt.BackgroundTransparency = 1
    txt.TextScaled = true
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.Text = text
    txt.Parent = f

    -- Toggle Logic
    local toggle = defaultState or false
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local function updateToggle(state, instant)
        toggle = state
        local props
        if toggle then
            props = {
                Position = UDim2.new(0,0,0,0),
                BackgroundColor3 = Color3.fromRGB(0,200,0)
            }
            but.Text = "ON"
        else
            props = {
                Position = UDim2.new(0.5,0,0,0),
                BackgroundColor3 = Color3.fromRGB(255,0,0)
            }
            but.Text = "OFF"
        end
        if instant then
            for k,v in pairs(props) do
                pcall(function() but[k] = v end)
            end
        else
            pcall(function() TweenService:Create(but, tweenInfo, props):Play() end)
        end
        if callback then
            pcall(callback, toggle)
        end
    end

    updateToggle(toggle, true)

    but.MouseButton1Click:Connect(function()
        updateToggle(not toggle)
    end)

    return f
end

-- =====>> TOGGLE SWITCH <<=====
-- <<===== LIGHTERCYAN.AI =====>>
-- << main loadstring >>
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/main/LighterCyan.ai.lua"))()
-- หา LighterCyan.ai ด้วย WaitForChild
local gui = game:GetService("CoreGui")
	:WaitForChild("TopBarApp")
	:WaitForChild("TopBarApp")
	:WaitForChild("UnibarLeftFrame")
	:WaitForChild("HealthBar")
	:WaitForChild("ExperienceSettings")
	:WaitForChild("LighterCyan.ai")

-- ใช้ toggle เดิมของนาย
createToggle(BFrame, "LighterCyan.ai (Discontinued)", function(state)
	gui.Enabled = state  -- เปิด/ปิดตามสวิตช์
end, false) -- default: ปิด
-- <<===== END LIGHTERCYAN =====>>

task.wait(0.1)
bk.Visible = false

-- <<===== HEALTHBAR =====>>
-- 🔍 หา HealthBar หลัก
local hb = game:GetService("CoreGui")
	:WaitForChild("TopBarApp")
	:WaitForChild("TopBarApp")
	:WaitForChild("UnibarLeftFrame")
	:WaitForChild("HealthBar")
	:WaitForChild("HealthBar")

-- 🟩 Toggle รวม HealthBar
createToggle(BFrame, "Disable HealthBar", function(state)
	local fill = hb:FindFirstChild("Fill")
	local outline = hb:FindFirstChild("Outline")
	local stroke = hb:FindFirstChild("UIStroke")

	if fill then fill.Visible = state end
	if outline then outline.Visible = state end
	if stroke then stroke.Transparency = state and 0 or 1 end
end, true) -- default = ON
-- <<===== END HEALTHBAR =====>>

-- <<===== MUTED DEATH SOUNDS =====>
-- ตัวแปรควบคุม loop
local deathSoundLoopRunning = false

createToggle(BFrame, "Disable Death Sound", function(state)
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer

	if state then
		-- เปิด: เริ่มตรวจจับ
		deathSoundLoopRunning = true
		task.spawn(function()
			while deathSoundLoopRunning do
				local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					for _, obj in ipairs(hrp:GetChildren()) do
						if obj.Name == "DeathSoundClient" then
							obj:Destroy()
						end
					end
				end
				task.wait(0.05)
			end
		end)
	else
		-- ปิด: หยุดลบเสียงทันที
		deathSoundLoopRunning = false
	end
end, false) -- default OFF
-- <<===== END MUTED DEATH SOUNDS =====>

-- ==============================
-- ExperienceSettingsCamera (Final Full)
-- - Holdable mobile buttons + keyboard
-- - SpeedType TextBox (name = "SpeedType")
-- - Cleanup when OFF (FrameHolder, part, connections)
-- - Expects createToggle and BFrame to exist already
-- ==============================

createToggle(BFrame, "ExperienceSettingsCamera (FreeCam Test)", function(state)
	-- Services
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local CoreGui = game:GetService("CoreGui")

	-- Player / Camera / Character
	local player = Players.LocalPlayer
	local cam = workspace.CurrentCamera
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	local humanoid = char:WaitForChild("Humanoid")

	-- Try to reuse existing Menu variable if present, otherwise fallback to searching CoreGui
	local OK_Menu = (type(Menu) == "table" or type(Menu) == "userdata") and Menu
	local Menu = OK_Menu or (pcall(function()
		return CoreGui:WaitForChild("TopBarApp"):WaitForChild("TopBarApp")
			:WaitForChild("UnibarLeftFrame"):WaitForChild("HealthBar")
			:WaitForChild("ExperienceSettings"):WaitForChild("Menu")
	end) and (CoreGui.TopBarApp.TopBarApp.UnibarLeftFrame.HealthBar.ExperienceSettings.Menu) or nil)

	-- state
	local conns = {}           -- list of connections to disconnect
	local part = nil           -- camera anchor part
	local holderGui = nil      -- FrameHolder parent for buttons / speed UI
	local moveConn = nil       -- Heartbeat mover connection
	local syncConn = nil       -- RenderStepped camera sync
	local pressed = { W=false, A=false, S=false, D=false, Q=false, E=false }
	local mobile = { W=false, A=false, S=false, D=false, Q=false, E=false }

	-- speed config
	local speed = 15
	local minSpeed, maxSpeed = 1, 250

	-- helper to store and disconnect connections
	local function addConn(c)
		if c then table.insert(conns, c) end
	end

	-- Styled button creator (50x50)
	local function makeButton(parent, name, labelText, pos)
		local b = Instance.new("TextButton")
		b.Name = name
		b.Text = labelText
		b.Size = UDim2.new(0,50,0,50)
		b.Position = pos
		b.BackgroundColor3 = Color3.fromRGB(255,255,255)
		b.BackgroundTransparency = 0.5
		b.TextColor3 = Color3.fromRGB(0,0,0)
		b.TextScaled = true
		b.Font = Enum.Font.SourceSansBold
		b.BorderSizePixel = 0
		b.Active = true
		b.Parent = parent

		local uc = Instance.new("UICorner"); uc.CornerRadius = UDim.new(0,8); uc.Parent = b
		local st = Instance.new("UIStroke"); st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.LineJoinMode = Enum.LineJoinMode.Round; st.Color = Color3.fromRGB(255,255,255); st.Thickness = 1; st.Parent = b

		return b
	end

	-- Speed UI creator (SpeedType textbox)
	local function createSpeedUI(parent)
		-- remove old if present
		local old = parent:FindFirstChild("SpeedController")
		if old then old:Destroy() end

		local frame = Instance.new("Frame")
		frame.Name = "SpeedController"
		frame.Size = UDim2.new(0,270,0,60)
		frame.Position = UDim2.new(0.12,0,0.56,0)
		frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
		frame.BackgroundTransparency = 0.6
		frame.Parent = parent

		local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0,8); corner.Parent = frame
		local stroke = Instance.new("UIStroke"); stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; stroke.LineJoinMode = Enum.LineJoinMode.Round; stroke.Color = Color3.fromRGB(255,255,255); stroke.Thickness = 1; stroke.Parent = frame

		local defaultBtn = Instance.new("TextButton")
		defaultBtn.Name = "Default"
		defaultBtn.Text = "Default"
		defaultBtn.Size = UDim2.new(0,80,1,0)
		defaultBtn.Position = UDim2.new(0,8,0,0)
		defaultBtn.BackgroundTransparency = 0.5
		defaultBtn.Parent = frame

		local speedBox = Instance.new("TextBox")
		speedBox.Name = "SpeedType" -- important, per your request
		speedBox.PlaceholderText = "SpeedType"
		speedBox.Text = tostring(speed)
		speedBox.Size = UDim2.new(0,110,1,0)
		speedBox.Position = UDim2.new(0,100,0,0)
		speedBox.BackgroundTransparency = 0.5
		speedBox.Parent = frame

		local enterBtn = Instance.new("TextButton")
		enterBtn.Name = "Enter"
		enterBtn.Text = "Enter"
		enterBtn.Size = UDim2.new(0,60,1,0)
		enterBtn.Position = UDim2.new(0,216,0,0)
		enterBtn.BackgroundTransparency = 0.5
		enterBtn.Parent = frame

		for _,child in ipairs({defaultBtn, speedBox, enterBtn}) do
			local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,8); c.Parent = child
			local s = Instance.new("UIStroke"); s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.LineJoinMode = Enum.LineJoinMode.Round; s.Color = Color3.fromRGB(255,255,255); s.Thickness = 1; s.Parent = child
			if not child:IsA("TextBox") then child.TextScaled = true end
			child.Font = Enum.Font.SourceSansBold
			child.TextColor3 = Color3.fromRGB(0,0,0)
		end

		local function setSpeedFromString(str)
			local n = tonumber(str)
			if n and n >= minSpeed and n <= maxSpeed then
				speed = math.clamp(n, minSpeed, maxSpeed)
				speedBox.Text = tostring(speed)
			else
				speedBox.Text = tostring(speed)
			end
		end

		enterBtn.MouseButton1Click:Connect(function() setSpeedFromString(speedBox.Text) end)
		defaultBtn.MouseButton1Click:Connect(function() speed = 15; speedBox.Text = tostring(speed) end)
		speedBox.FocusLost:Connect(function(enterPressed) if enterPressed then setSpeedFromString(speedBox.Text) end end)

		return frame, speedBox, defaultBtn, enterBtn
	end

	-- Movement map (unit directions)
	local moveMap = {
		W = Vector3.new(0,0,1),
		S = Vector3.new(0,0,-1),
		A = Vector3.new(-1,0,0),
		D = Vector3.new(1,0,0),
		Q = Vector3.new(0,1,0),
		E = Vector3.new(0,-1,0)
	}

	-- Bind hold semantics for GUI button (mouse/touch/Input)
	local function bindHoldButton(btn, key)
		if not btn or not btn:IsA("GuiObject") then return end
		if btn:GetAttribute("ESCBound") then return end
		btn:SetAttribute("ESCBound", true)

		-- InputBegan/InputEnded (broad coverage)
		addConn(btn.InputBegan:Connect(function(input)
			if input.UserInputState == Enum.UserInputState.Begin then
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					mobile[key] = true
				end
			end
		end))

		addConn(btn.InputEnded:Connect(function(input)
			if input.UserInputState == Enum.UserInputState.End then
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					mobile[key] = false
				end
			end
		end))

		-- fallbacks for devices/clients
		addConn(btn.MouseButton1Down:Connect(function() mobile[key] = true end))
		addConn(btn.MouseButton1Up:Connect(function() mobile[key] = false end))
		addConn(btn.TouchStarted:Connect(function() mobile[key] = true end))
		addConn(btn.TouchEnded:Connect(function() mobile[key] = false end))

		-- ensure click doesn't break (harmless)
		if btn.MouseButton1Click then
			addConn(btn.MouseButton1Click:Connect(function() end))
		end
	end

	-- Keyboard handlers
	addConn(UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			local kc = input.KeyCode
			for k,_ in pairs(moveMap) do
				if kc == Enum.KeyCode[k] then
					pressed[k] = true
				end
			end
		end
	end))

	addConn(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			local kc = input.KeyCode
			for k,_ in pairs(moveMap) do
				if kc == Enum.KeyCode[k] then
					pressed[k] = false
				end
			end
		end
	end))

	-- Movement loop (Heartbeat) — frame-rate independent
	local function startMoveLoop()
		if moveConn and moveConn.Connected then return end
		moveConn = RunService.Heartbeat:Connect(function(dt)
			if not part or not part.Parent then
				-- auto-stop loop if part missing
				if moveConn and moveConn.Connected then moveConn:Disconnect() end
				moveConn = nil
				return
			end

			-- accumulate direction
			local dir = Vector3.new(0,0,0)
			for k,v in pairs(moveMap) do
				if pressed[k] or mobile[k] then
					dir += v
				end
			end

			if dir.Magnitude > 0 then
				-- camera-aligned forward/right (ignore pitch)
				local camCF = cam.CFrame
				local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
				local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)
				if forward.Magnitude < 1e-4 then forward = Vector3.new(0,0,-1) else forward = forward.Unit end
				if right.Magnitude < 1e-4 then right = Vector3.new(1,0,0) else right = right.Unit end

				local moveWorld = right * dir.X + Vector3.new(0, dir.Y, 0) + forward * dir.Z
				if moveWorld.Magnitude > 0 then
					local delta = moveWorld.Unit * (speed * dt)
					local newPos = part.Position + delta
					local lookVec = cam.CFrame.LookVector
					part.CFrame = CFrame.new(newPos)
					cam.CFrame = CFrame.new(newPos, newPos + lookVec)
				end
			end
		end)
		addConn(moveConn)
	end

	-- keep camera synced to part each frame (safe)
	local function startSync()
		if syncConn and syncConn.Connected then return end
		syncConn = RunService.RenderStepped:Connect(function()
			if part and part.Parent then
				local lookVec = cam.CFrame.LookVector
				cam.CFrame = CFrame.new(part.Position, part.Position + lookVec)
			end
		end)
		addConn(syncConn)
	end

	-- MAIN toggle logic
	if state then
		-- ON: create part + GUI + bindings
		if workspace:FindFirstChild("ExperienceSettingsCamera") then
			workspace.ExperienceSettingsCamera:Destroy()
		end

		part = Instance.new("Part")
		part.Name = "ExperienceSettingsCamera"
		part.Size = Vector3.new(1,1,1)
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.CFrame = hrp.CFrame
		part.Parent = workspace

		local pl = Instance.new("PointLight"); pl.Brightness = 1.2; pl.Range = 16; pl.Parent = part

		-- immobilize character
		hrp.Anchored = true
		humanoid.AutoRotate = false

		-- camera lock-like behaviour
		player.CameraMode = Enum.CameraMode.LockFirstPerson
		cam.CameraSubject = part

		-- ensure holderGui exists under Menu
		holderGui = (Menu and Menu:FindFirstChild("FrameHolder")) or nil
		if not holderGui then
			-- create minimal FrameHolder under Menu if Menu exists
			if Menu then
				holderGui = Instance.new("Frame")
				holderGui.Name = "FrameHolder"
				holderGui.Size = UDim2.new(1,0,1,0)
				holderGui.BackgroundTransparency = 1
				holderGui.Parent = Menu
			else
				-- fallback: create under PlayerGui if Menu not found
				holderGui = Instance.new("ScreenGui")
				holderGui.Name = "FrameHolderFallback"
				holderGui.ResetOnSpawn = false
				holderGui.Parent = player:FindFirstChild("PlayerGui") or player
			end
		end

		-- create or reuse buttons (positions chosen to match prior)
		local w = holderGui:FindFirstChild("W") or makeButton(holderGui, "W", "W", UDim2.new(0.05,0,0.65,0))
		local a = holderGui:FindFirstChild("A") or makeButton(holderGui, "A", "A", UDim2.new(0,0,0.75,0))
		local s = holderGui:FindFirstChild("S") or makeButton(holderGui, "S", "S", UDim2.new(0.05,0,0.85,0))
		local d = holderGui:FindFirstChild("D") or makeButton(holderGui, "D", "D", UDim2.new(0.1,0,0.75,0))
		local q = holderGui:FindFirstChild("Q") or makeButton(holderGui, "Q", "Q", UDim2.new(0.85,0,0.65,0))
		local e = holderGui:FindFirstChild("E") or makeButton(holderGui, "E", "E", UDim2.new(0.85,0,0.85,0))

		-- bind hold semantics, ensure startMoveLoop on press
		for _, pair in ipairs({ {w,"W"}, {a,"A"}, {s,"S"}, {d,"D"}, {q,"Q"}, {e,"E"} }) do
			local btn, key = pair[1], pair[2]
			bindHoldButton(btn, key)
			-- immediate start on pointer down
			addConn(btn.MouseButton1Down:Connect(function() startMoveLoop() end))
			addConn(btn.TouchStarted:Connect(function() startMoveLoop() end))
		end

		-- create Speed UI
		createSpeedUI(holderGui)

		-- start sync & move loop if keys pressed
		startSync()
		startMoveLoop()
	else
		-- OFF: cleanup / restore
		-- disconnect all stored connections
		for _, c in ipairs(conns) do
			if c and c.Connected then
				pcall(function() c:Disconnect() end)
			end
		end
		conns = {}

		-- destroy FrameHolder under Menu (if exists)
		if Menu then
			local fh = Menu:FindFirstChild("FrameHolder")
			if fh then fh:Destroy() end
		else
			-- fallback: destroy fallback holder if used
			local fb = player:FindFirstChild("FrameHolderFallback")
			if fb and fb.Parent then fb:Destroy() end
		end

		-- destroy ExperienceSettingsCamera part
		if part and part.Parent then part:Destroy() end
		part = nil

		-- reset inputs
		for k,_ in pairs(pressed) do pressed[k] = false end
		for k,_ in pairs(mobile) do mobile[k] = false end

		-- restore char & camera
		humanoid.AutoRotate = true
		hrp.Anchored = false
		player.CameraMode = Enum.CameraMode.Classic
		cam.CameraSubject = humanoid
	end
end, false)
