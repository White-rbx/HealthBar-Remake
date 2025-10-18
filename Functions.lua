-- ===== [ Service's ] ===== 
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ===== Positions =====   
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
bigt.Size = UDim2.new(1,0,0.6,0)
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

📌 Updated: More Button
 • Just add "Information" button to fixed annoy warn text.
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
		if x > 91 then
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
    local holder = topbar:WaitForChild("Holder")
	local loadFrame = holder:WaitForChild("LoadFrame")     
	local bg = menu:WaitForChild("About_Background")
	local inside = bg:WaitForChild("Inside")
	local inside2 = inside:WaitForChild("Inside2")
	local hideBtn = inside2:WaitForChild("Hide")             

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
createToggle(BFrame, "LighterCyan.ai (Dev Test)", function(state)
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
createToggle(BFrame, "HealthBar", function(state)
	local fill = hb:FindFirstChild("Fill")
	local outline = hb:FindFirstChild("Outline")
	local stroke = hb:FindFirstChild("UIStroke")

	if fill then fill.Visible = state end
	if outline then outline.Visible = state end
	if stroke then stroke.Transparency = state and 0 or 1 end
end, true) -- default = ON
-- <<===== END HEALTHBAR =====>>
