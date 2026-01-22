-- So uhm just a script lol. 4.69

-- Loadstring
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/ColorfulLabel.lua"))()

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
Inner.Position = UDim2.new(-0.8,0,0,0)
Inner.Size = UDim2.new(0.8,0,1,0)
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

--

local Inner2 = Instance.new("Frame")
Inner2.Name = "Inner2_Background"
Inner2.Visible = false
Inner2.Active = false
Inner2.BackgroundColor3 = Color3.fromRGB(0,0,0)
Inner2.BackgroundTransparency = 0.5
Inner2.Position = UDim2.new(-1.6,0,0,0)
Inner2.Size = UDim2.new(0.8,0,1,0)
Inner2.Parent = Background
Corner(0.02, 0, Inner2)

local Toggle2 = Instance.new("Frame")
Toggle2.Name = "Toggles"
Toggle2.Active = false
Toggle2.BackgroundColor3 = Color3.fromRGB(0,0,0)
Toggle2.BackgroundTransparency = 0.5
Toggle2.Position = UDim2.new(0.02,0,0.02,0)
Toggle2.Size = UDim2.new(0.96,0,0.96,0)
Toggle2.Parent = Inner2
Corner(0.02, 0, Toggle2)

local BFrame2 = Instance.new("Frame")
BFrame2.Name = "B_Frame"
BFrame2.BackgroundTransparency = 1
BFrame2.Position = UDim2.new(0.02,0,0.02,0)
BFrame2.Size = UDim2.new(0.96,0,0.96,0)
BFrame2.Parent = Toggle2
createUIListLayout(BFrame2, 0.005, 0, HCenter, VTop, SName, FillV)

-- =======================
-- =====>> Loading <<=====
local bk = Instance.new("Frame")
bk.Name = "Load_Background"
bk.Size = UDim2.new(0.4,0,0.2,0)
bk.Position = UDim2.new(0.3,0,0.70,0)
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
wl.Text = "Creator by @5teve3019D on ScriptBlox"
wl.TextScaled = true
wl.TextColor3 = Color3.fromRGB(255,255,255)
wl.Parent = bk

local skp = Instance.new("TextButton")
skp.Name = "Skip"
skp.BackgroundTransparency = 0.8
skp.BackgroundColor3 = Color3.fromRGB(255,255,255)
skp.Position = UDim2.new(0.02,0,0.85,0)
skp.Size = UDim2.new(0.96,0,0.1,0)
skp.Text = "Skip"
skp.TextScaled = true
skp.TextColor3 = Color3.fromRGB(255,255,255)
skp.Parent = bk
Corner(0,8,skp)
Stroke(skp, ASMBorder, 255, 255, 255, LSMRound, 1, 0)

local lder = Instance.new("Frame")
lder.Name = "Loader"
lder.BackgroundTransparency = 0.8
lder.BackgroundColor3 = Color3.fromRGB(255,255,255)
lder.Size = UDim2.new(0,0,1,0)
lder.Parent = skp
Corner(0, 8, lder)

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

local linkDc = Instance.new("TextBox")
linkDc.Name = "Discord link"
linkDc.TextScaled = true
linkDc.Text = "https://discord.gg/nFz3ypxUMA"
linkDc.TextColor3 = Color3.fromRGB(255,255,255)
linkDc.BackgroundTransparency = 1
linkDc.ClearTextOnFocus = false
linkDc.Size = UDim2.new(0.34,0,0,20)
linkDc.Position = UDim2.new(0.65,0,0,0)
linkDc.Parent = In
Corner(1, 0, linkDc)
Stroke(linkDc, ASMBorder, 255, 255, 255, LSMRound, 1, 0)

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
imag.Image = "rbxassetid://106411805549573"
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
txt.Text = "@5teve3019D"
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

local scrF = Instance.new("ScrollingFrame")
scrF.Name = "Scroll"
scrF.Position = UDim2.new(0,0,0.26,0)
scrF.Size = UDim2.new(1,0,0.6,0)
scrF.BackgroundTransparency = 1
scrF.Parent = In
Stroke(scrF, ASMBorder, 255,255,255, LSMRound, 1, 0.5)


local bigt = Instance.new("TextLabel")
bigt.Name = "About"
bigt.Active = false
bigt.Size = UDim2.new(1,0,1,0)
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

Creator: @5teve3019D (Gui, Little Script)
Helper: ChatGPT (Script) <-- He got a lot of complaints lol.
Little Helper: Copilot of GitHub (Script)
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
📌 Updated: Re-gui textlabel description.
-------
🔁 In progress:
 🔨 Creating Status Profile (Debug)
 🔨 Updating AI Open Source (In develop)
 🔷 Moveable ValueLabels
-------
❌ Failed:
 ➖ Moveable HealthBar
-------

✨ SCRIPT CREDITS ✨
[ Script Name ] by [ Creator ] [ Verification Status ]

We want to say that your script is awesome, and it is used in our project for debugging and educational purposes.
Thank you for your contribution :3 ❤️
- Debugger

-- Credits List --
'Ketamine' by @Cherry (✓ Verified)
'OG AFEM – Legacy' by @Imperial (✓ Verified)
'Chat' by Unknown user
'UNC' by Unknown user
'REM' by @evildotcom (X Not verified)
'GameProber' by @Imperial (✓ Verified)
'AudioPlayer' by Unknown user
'EmoteSelect' by Unknown user
'Universal Movement Predictor' by @zephyrr (X Not verified)
'Server Position Predictor' by @zephyrr (X Not verified)
'Open Source Universal Chat' by @neutral (X Not verified)

-- Notice to Script Creators --
If you are a script creator listed above and do not want your script to be included,
please contact us via our Discord forum, and we will remove it immediately.
]]
bigt.TextColor3 = Color3.fromRGB(255,255,255)
bigt.TextScaled = false
bigt.TextXAlignment = Enum.TextXAlignment.Left
bigt.TextYAlignment = Enum.TextYAlignment.Top
bigt.Parent = scrF

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

-- ================
local mfr = Instance.new("Frame")
mfr.Name = "MiddleScreen"
mfr.Position = UDim2.new(0, 0, 0, 0)
mfr.Size = UDim2.new(1, 0, 1, 0)
mfr.BackgroundTransparency = 1
mfr.Active = false
mfr.Parent = Menu
createUIListLayout(mfr, 0, 0, HCenter, VCenter, SName, FillH)
-- =================
local ts = Instance.new("ImageLabel")
ts.Name = "TargetShift"
ts.Size = UDim2.new(0, 50, 0, 50)
ts.BackgroundTransparency = 1
ts.Active = false
ts.Visible = false
ts.Image = "rbxassetid://118624373632520"
ts.AnchorPoint = Vector2.new(0.5, 0.5)
ts.Position = UDim2.new(0.5, -5, 0.5, -5)
ts.Parent = mfr
-- =================
local hrfr = Instance.new("Frame")
hrfr.Name = "HolderScreen"
hrfr.Position = UDim2.new(0, 0, 0.1, 0)
hrfr.Size = UDim2.new(1, 0, 0.9, 0)
hrfr.BackgroundTransparency = 1
hrfr.Active = false
hrfr.Parent = Menu

local sh = Instance.new("Frame")
sh.Name = "Shift_Lock"
sh.Size = UDim2.new(0, 90, 0, 43) -- off = 90, on = 135
sh.Position = UDim2.new(0, 0, 0, 250)
sh.Visible = false
sh.Active = false
sh.BackgroundTransparency = 0.08
sh.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
sh.Parent = hrfr
Corner(1, 0, sh)
createUIListLayout(sh, 0, 10, HCenter, VCenter, SName, FillH)

local shl = Instance.new("ImageButton")
shl.Name = "a1_Shift"
shl.BackgroundTransparency = 1
shl.Image = "rbxassetid://137719322669506"
shl.Size = UDim2.new(0, 35, 0, 35)
shl.Parent = sh
Corner(1, 0, shl)

local dr = Instance.new("ImageButton")
dr.Name = "a3_Dragger"
dr.Image = "rbxassetid://99025662889813"
dr.AutoButtonColor = false
dr.BackgroundTransparency = 1
dr.Size = UDim2.new(0, 35, 0, 35)
dr.Parent = sh
Corner(1, 0, dr)

local aim = Instance.new("ImageButton")
aim.Name = "a2_Aim"
aim.Image = "rbxassetid://74510217089631"
aim.Size = UDim2.new(0, 35, 0, 35)
aim.BackgroundTransparency = 1
aim.Visible = false
aim.Parent = sh
Corner(1, 0, aim)

-- === Dragger ===
-- Dragger = dr
-- Frame ที่จะขยับ = sh

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local dragging = false
local dragStart
local startPos

local dragSpeed = 0.12 -- ลื่นแบบกำลังดี

local function updateInput(input)
    if not dragging then return end
    
    local delta = input.Position - dragStart

    local new = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )

    --====== ป้องกัน UI หลุดจอ ======--
    local screen = workspace.CurrentCamera.ViewportSize
    local w = sh.AbsoluteSize.X
    local h = sh.AbsoluteSize.Y

    local x = math.clamp(new.X.Offset, 0, screen.X - w)
    local y = math.clamp(new.Y.Offset, 0, screen.Y - h)

    TweenService:Create(sh, TweenInfo.new(dragSpeed), {
        Position = UDim2.new(0, x, 0, y)
    }):Play()
end


--====== Start Drag on DRAGGER ONLY ======--
dr.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = sh.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)


--====== Update while dragging ======--
UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement 
    or input.UserInputType == Enum.UserInputType.Touch then
        updateInput(input)
    end
end)

--========================================================--
-- SHIFT-LOCK (FULL SYSTEM) + AIM + Tween
--========================================================--

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- UI
-- shl = ปุ่ม ShiftLock
-- ts  = ไอคอนกลางบอกสถานะ
-- sh  = Frame ด้านล่าง
-- aim = ปุ่มเล็ง

-- ICON CONFIG
local SHL_OFF = "rbxassetid://137719322669506"
local SHL_ON  = "rbxassetid://138164639115707"

local TS_NO_TOOL = "rbxassetid://118624373632520"
local TS_TOOL    = "rbxassetid://73868291781876"

local AIM_OFF = "rbxassetid://74510217089631"
local AIM_ON  = "rbxassetid://127391106123970"

local shiftEnabled = false
local aimEnabled = false
local equippedTool = nil

local humanoid
local root

--========================================================--
-- Tween Helper
--========================================================--
local function tween(obj, t, data)
	return TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), data):Play()
end

--========================================================--
-- อัปเดต Character
--========================================================--
local function bindCharacter(char)
	humanoid = char:WaitForChild("Humanoid", 5)
	root = char:WaitForChild("HumanoidRootPart", 5)
end
bindCharacter(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(bindCharacter)

--========================================================--
-- อัปเดต ts (สถานะอย่างเดียว)
--========================================================--
local function updateTS()
	if not shiftEnabled then
		ts.Visible = false
		return
	end

	ts.Visible = true
	if equippedTool then
		ts.Image = TS_TOOL
	else
		ts.Image = TS_NO_TOOL
	end
end

--========================================================--
-- AIM SYSTEM
--========================================================--
local function updateAim(state)
	aimEnabled = state

	if not shiftEnabled then
		aimEnabled = false
	end

	if aimEnabled then
		aim.Visible = true
		aim.Image = AIM_ON
	else
		aim.Image = AIM_OFF
	end

	updateTS()
end

aim.MouseButton1Click:Connect(function()
	updateAim(not aimEnabled)
end)

--========================================================--
-- เปิด/ปิด Shift Lock
--========================================================--
local function updateShiftLock(state)
	shiftEnabled = state
	updateTS()

	if shiftEnabled then
		shl.Image = SHL_ON
		UIS.MouseBehavior = Enum.MouseBehavior.LockCenter

		camera.CameraType = Enum.CameraType.Custom
		player.CameraMode = Enum.CameraMode.Classic

		-- sh Frame ขยายเป็น 135
		tween(sh, 0.25, {Size = UDim2.new(0, 135, 0, sh.Size.Y.Offset)})

		aim.Visible = true

	else
		shl.Image = SHL_OFF
		UIS.MouseBehavior = Enum.MouseBehavior.Default

		player.CameraMode = Enum.CameraMode.Classic

		-- sh Frame หดเป็น 90
		tween(sh, 0.25, {Size = UDim2.new(0, 90, 0, sh.Size.Y.Offset)})

		aim.Visible = false
		aimEnabled = false
		updateAim(false)
	end

	updateTS()
end

--========================================================--
-- ปุ่ม shl
--========================================================--
shl.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		updateShiftLock(not shiftEnabled)
	end
end)

--========================================================--
-- Tool Detect
--========================================================--
local function bindTool(tool)
	if tool.ClassName ~= "Tool" then return end

	tool.Equipped:Connect(function()
		equippedTool = tool
		updateTS()
	end)

	tool.Unequipped:Connect(function()
		equippedTool = nil
		updateTS()
	end)
end

for _, tool in ipairs(player.Backpack:GetChildren()) do
	bindTool(tool)
end
player.Backpack.ChildAdded:Connect(bindTool)

--========================================================--
-- ระบบหมุนตัว + กล้องเอียงขวาแบบ Roblox SHIFT LOCK
--========================================================--
RunService.RenderStepped:Connect(function()

    if ts then
		ts.Position = UDim2.new(0.5, 0, 0.5, 0)
	end
		
	if not shiftEnabled then
		if humanoid then humanoid.AutoRotate = true end
		return
	end

	if not humanoid or not root or not camera then return end

	-- หมุนตัวละครเฉพาะ XZ
	local camLook = camera.CFrame.LookVector
	local flat = Vector3.new(camLook.X,0,camLook.Z)
	if flat.Magnitude > 0.001 then
		flat = flat.Unit
		humanoid.AutoRotate = false
		root.CFrame = CFrame.new(root.Position, root.Position + flat)
	end

	-- OFFSET SHIFT LOCK แบบ Roblox
	local offset = Vector3.new(2.3,0,0) -- ขยับขวา/ขึ้นเล็กน้อย
	local worldOffset = camera.CFrame:VectorToWorldSpace(offset)
	local newCamPos = camera.CFrame.Position + worldOffset

	-- สำคัญ: ใช้กล้องเดิมคง LookVector → มองขึ้น/ลงได้อิสระ
	camera.CFrame = CFrame.new(newCamPos, newCamPos + camLook)
end)

--========================================================--
-- เมื่อกดปุ่ม UI (shl)
--========================================================--
shl.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		updateShiftLock(not shiftEnabled)
	end
end)

--=========================--
-- เล็ง 
--=========================--

local UserInputService = game:GetService("UserInputService")

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	and not gameProcessedEvent
	and aimEnabled then

		PerformAimRaycast()
	end
end)

--===========================

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

task.wait(0.1)
lder.Size = UDim2.new(0.01,0,1,0)
task.wait(0.1)
lder.Size = UDim2.new(0.02,0,1,0)
task.wait(0.1)
lder.Size = UDim2.new(0.03,0,1,0)
task.wait(0.1)
lder.Size = UDim2.new(0.04,0,1,0)
task.wait(0.1)
lder.Size = UDim2.new(0.05,0,1,0)
task.wait(0.1)
lder.Size = UDim2.new(0.06,0,1,0)
task.wait(0.1)
lder.Size = UDim2.new(0.07,0,1,0)
task.wait(0.1)
lder.Size = UDim2.new(0.08,0,1,0)
task.wait(0.1)
lder.Size = UDim2.new(0.09,0,1,0)
task.wait(0.1)
lder.Size = UDim2.new(0.1,0,1,0)

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
		OPEN  = "rbxassetid://92243936349090",
		CLOSE = "rbxassetid://108080487163852",
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
		setButtonOpen("alsetatus", false)
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
	local offset =FreeCamocal scale = nil
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
		if offset == 311 then
			pcall(function() statusBtn.Visible = true end)
			setButtonOpen("a2_Status", true)
		elseif offset > 311 then
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

local defaultText = "https://discord.gg/nFz3ypxUMA"

task.spawn(function()
    while task.wait(0.005) do
        if linkDc.Text ~= defaultText then
            linkDc.Text = defaultText
        end
    end
end)
				
-- ===== END =====
-- Loadstring ProfileStatus
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/ProfileStatus.lua"))()

-- ==== PROFILESTATUS ======
-- Sta image-driven toggle for ProfileStatus tween
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local ON_ID  = "116259694864857"
local OFF_ID = "107706370299068"

local profilePath = CoreGui
    :WaitForChild("TopBarApp")
    :WaitForChild("TopBarApp")
    :WaitForChild("UnibarLeftFrame")
    :WaitForChild("HealthBar")
    :WaitForChild("ExperienceSettings")
    :WaitForChild("Menu")
local ProfileStatus = profilePath:WaitForChild("ProfileStatus")

local tweenInfo = TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local posOn  = UDim2.new(0.25, 0, 0.155, 0)
local posOff = UDim2.new(0.25, 0, 1, 0)

local function extractId(imageProp)
    if not imageProp then return nil end
    local s = tostring(imageProp)
    local id = s:match("(%d+)")
    return id
end

-- หา object ที่มี image เป็นหนึ่งในสองไอดี (ลงค้นหาใน ProfileStatus เฉพาะ)
local function findStaObject(root)
    for _, v in ipairs(root:GetDescendants()) do
        if v:IsA("ImageLabel") or v:IsA("ImageButton") then
            local id = extractId(v.Image)
            if id == ON_ID or id == OFF_ID then
                return v
            end
        end
    end
    return nil
end

local staObj = findStaObject(profilePath) or findStaObject(ProfileStatus)

-- ถ้าไม่เจอ ให้ลองค้นหาใน Menu เผื่อว่าวางไว้ที่อื่น
if not staObj then
    staObj = findStaObject(profilePath.Parent or profilePath)
end

-- init state by image (default OFF if unknown)
local isOn = false
if staObj then
    local cur = extractId(staObj.Image)
    if cur == ON_ID then
        isOn = true
    else
        isOn = false
    end
else
    -- ไม่พบวัตถุภาพที่มีไอดี — กำหนด default OFF
    isOn = false
end

local function applyPosition(on)
    local target = on and posOn or posOff
    TweenService:Create(ProfileStatus, tweenInfo, { Position = target }):Play()
end

local function setStaImage(on)
    if not staObj then return end
    staObj.Image = "rbxassetid://" .. (on and ON_ID or OFF_ID)
end

-- เรียกตั้ง initial
applyPosition(isOn)
setStaImage(isOn)

-- เชื่อม event เมื่อเป็น ImageButton / TextButton
if staObj and staObj:IsA("GuiButton") then
    staObj.MouseButton1Click:Connect(function()
        isOn = not isOn
        applyPosition(isOn)
        setStaImage(isOn)
    end)
else
    -- ถ้าพบ ImageLabel แต่อยากให้มันคลิกได้ ให้ฟัง InputBegan (ต้องเป็น GuiObject ที่รับ Input)
    if staObj and staObj:IsA("GuiObject") then
        staObj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isOn = not isOn
                applyPosition(isOn)
                setStaImage(isOn)
            end
        end)
    end
end
-- ==========

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

-- <<===== HEALTHBAR =====>>
-- 🔍 หา HealthBar หลัก
local hb = game:GetService("CoreGui")
	:WaitForChild("TopBarApp")
	:WaitForChild("TopBarApp")
	:WaitForChild("UnibarLeftFrame")
	:WaitForChild("HealthBar")
	:WaitForChild("HealthBar")

-- 🟩 Toggle รวม HealthBar
createToggle(BFrame, "Enable HealthBar", function(state)
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
-- ✅ ExperienceSettingsCamera (FreeCam Final - White Edition)
-- รองรับ Mobile + Keyboard + Speed UI + Direction Fix
createToggle(BFrame, "FreeCam (Mobile)", function(state)
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local CoreGui = game:GetService("CoreGui")

	local player = Players.LocalPlayer
	local cam = workspace.CurrentCamera
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart") or char:WaitForChild("Torso") or char:WaitForChild("LowerTorso")
	local humanoid = char:WaitForChild("Humanoid")

	local connList = {}
	local part
	local holderGui
	local speed = 16
	local minSpeed, maxSpeed = 1, 50000

	-- helper: disconnect safely
	local function addConn(c)
		if c then table.insert(connList, c) end
	end

	local function disconnectAll()
		for _, c in ipairs(connList) do
			if c and c.Connected then
				pcall(function() c:Disconnect() end)
			end
		end
		connList = {}
	end

	-- helper: make button
	local function makeButton(parent, name, labelText, pos)
		local b = Instance.new("TextButton")
		b.Name = name
		b.Text = labelText
		b.Size = UDim2.new(0, 50, 0, 50)
		b.Position = pos
		b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		b.BackgroundTransparency = 0.5
		b.TextColor3 = Color3.fromRGB(0, 0, 0)
		b.TextScaled = true
		b.Font = Enum.Font.SourceSansBold
		b.BorderSizePixel = 0
		b.Active = true
		b.Selectable = false
		b.Parent = parent

		local uc = Instance.new("UICorner")
		uc.CornerRadius = UDim.new(0, 8)
		uc.Parent = b

		local st = Instance.new("UIStroke")
		st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		st.LineJoinMode = Enum.LineJoinMode.Round
		st.Color = Color3.fromRGB(255, 255, 255)
		st.Thickness = 1
		st.Transparency = 0
		st.Parent = b

		return b
	end

	-- Speed controller UI
	local function createSpeedController(parent)
		local frame = Instance.new("Frame")
		frame.Name = "SpeedController"
		frame.Size = UDim2.new(0, 285, 0, 60)
		frame.Position = UDim2.new(0.385, 0, 0.1, 0)
		frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame.BackgroundTransparency = 0.6
		frame.Parent = parent

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = frame

		local stroke = Instance.new("UIStroke")
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.LineJoinMode = Enum.LineJoinMode.Round
		stroke.Color = Color3.fromRGB(255, 255, 255)
		stroke.Thickness = 1
		stroke.Parent = frame

		local defaultBtn = Instance.new("TextButton")
		defaultBtn.Name = "Default"
		defaultBtn.Text = "Default"
		defaultBtn.Size = UDim2.new(0, 80, 1, 0)
		defaultBtn.Position = UDim2.new(0, 8, 0, 0)
		defaultBtn.BackgroundTransparency = 0.5
		defaultBtn.Parent = frame

		local speedBox = Instance.new("TextBox")
		speedBox.Name = "SpeedType"
		speedBox.PlaceholderText = "SpeedType"
		speedBox.Text = tostring(speed)
		speedBox.Size = UDim2.new(0, 110, 1, 0)
		speedBox.Position = UDim2.new(0, 100, 0, 0)
		speedBox.BackgroundTransparency = 0.5
		speedBox.TextScaled = true -- ✅ Added as requested
		speedBox.Parent = frame

		local enterBtn = Instance.new("TextButton")
		enterBtn.Name = "Enter"
		enterBtn.Text = "Enter"
		enterBtn.Size = UDim2.new(0, 60, 1, 0)
		enterBtn.Position = UDim2.new(0, 216, 0, 0)
		enterBtn.BackgroundTransparency = 0.5
		enterBtn.Parent = frame

		for _, v in ipairs({ defaultBtn, speedBox, enterBtn }) do
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0, 8)
			c.Parent = v
			local s = Instance.new("UIStroke")
			s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			s.LineJoinMode = Enum.LineJoinMode.Round
			s.Color = Color3.fromRGB(255, 255, 255)
			s.Thickness = 1
			s.Parent = v
			if not v:IsA("TextBox") then
				v.TextScaled = true
			end
			v.Font = Enum.Font.SourceSansBold
			v.TextColor3 = Color3.fromRGB(0, 0, 0)
		end

		enterBtn.MouseButton1Click:Connect(function()
			local n = tonumber(speedBox.Text)
			if n then
				speed = math.clamp(n, minSpeed, maxSpeed)
				speedBox.Text = tostring(speed)
			end
		end)

		defaultBtn.MouseButton1Click:Connect(function()
			speed = 16
			speedBox.Text = tostring(speed)
		end)
	end

	-- movement state
	local mobileKeys = { W=false, A=false, S=false, D=false, Q=false, E=false }

	local function ensureMovementLoop()
		if mobileKeys.__loop then return end
		mobileKeys.__loop = task.spawn(function()
			while part and part.Parent do
				local dt = RunService.RenderStepped:Wait()
				local dir = Vector3.zero
				if mobileKeys.W then dir += Vector3.new(0,0,1) end
				if mobileKeys.S then dir -= Vector3.new(0,0,1) end
				if mobileKeys.A then dir -= Vector3.new(1,0,0) end
				if mobileKeys.D then dir += Vector3.new(1,0,0) end
				if mobileKeys.Q then dir += Vector3.new(0,1,0) end
				if mobileKeys.E then dir -= Vector3.new(0,1,0) end

				if dir.Magnitude > 0 then
					dir = dir.Unit
					local look = cam.CFrame.LookVector
					local right = cam.CFrame.RightVector
					local forward = Vector3.new(look.X, 0, look.Z).Unit
					local rightVec = Vector3.new(right.X, 0, right.Z).Unit

					local move = forward * dir.Z + rightVec * dir.X + Vector3.new(0, dir.Y, 0)
					part.CFrame += move * speed * dt
				end
			end
			mobileKeys.__loop = nil
		end)
	end

	-- button binding
	local function bindButton(btn, key)
		btn.MouseButton1Down:Connect(function()
			mobileKeys[key] = true
			btn:TweenSize(UDim2.new(0, 55, 0, 55), "Out", "Sine", 0.1, true)
			ensureMovementLoop()
		end)
		btn.MouseButton1Up:Connect(function()
			mobileKeys[key] = false
			btn:TweenSize(UDim2.new(0, 50, 0, 50), "Out", "Sine", 0.1, true)
		end)
	end

	-- MAIN toggle
	if state then
		local existing = workspace:FindFirstChild("ExperienceSettingsCamera")
		if existing then existing:Destroy() end

		for _,v in ipairs(CoreGui:GetDescendants()) do
			if v.Name == "FrameHolder" then v:Destroy() end
		end

		holderGui = Instance.new("Frame")
		holderGui.Name = "FrameHolder"
		holderGui.Size = UDim2.new(1, 0, 1, 0)
		holderGui.BackgroundTransparency = 1
		holderGui.Parent = Menu

		part = Instance.new("Part")
		part.Name = "ExperienceSettingsCamera"
		part.Size = Vector3.new(5,5,5)
		part.Transparency = 1
		part.Locked = true
		part.Anchored = true
		part.CanCollide = false
		part.CFrame = hrp.CFrame
		part.Parent = workspace

		hrp.Anchored = true
		humanoid.AutoRotate = false
		player.CameraMode = Enum.CameraMode.LockFirstPerson
		cam.CameraSubject = part

		local w = makeButton(holderGui, "W", "↑", UDim2.new(0.05, 0, 0.65, 0))
		local a = makeButton(holderGui, "A", "←", UDim2.new(0, 0, 0.75, 0))
		local s = makeButton(holderGui, "S", "↓", UDim2.new(0.05, 0, 0.85, 0))
		local d = makeButton(holderGui, "D", "→", UDim2.new(0.1, 0, 0.75, 0))
		local q = makeButton(holderGui, "Q", "Up", UDim2.new(0.85, 0, 0.65, 0))
		local e = makeButton(holderGui, "E", "Down", UDim2.new(0.85, 0, 0.85, 0))

		for _,b in ipairs({w,a,s,d,q,e}) do bindButton(b,b.Name) end
		createSpeedController(holderGui)

	else
		disconnectAll()
		local old = Menu:FindFirstChild("FrameHolder")
		if old then old:Destroy() end
		if part and part.Parent then part:Destroy() end

		hrp.Anchored = false
		humanoid.AutoRotate = true
		player.CameraMode = Enum.CameraMode.Classic
		cam.CameraSubject = humanoid
	end
end, false)

-- <<===== ALMOST ENDLESS FALLEN (-50K STUDS) =====>>

local SavedFallen = workspace.FallenPartsDestroyHeight  
local FallenToggleState = false  -- default = OFF

createToggle(BFrame, "Almost Endless Fallen (-50K)", function(state)

    if state then
        -- ON Mode (ไม่บันทึกค่า)
        FallenToggleState = true
        workspace.FallenPartsDestroyHeight = -50000
    else
        -- OFF Mode
        -- Save เฉพาะตอน OFF → OFF
        if FallenToggleState == false then
            SavedFallen = workspace.FallenPartsDestroyHeight
        end

        -- Restore ค่าเดิม
        workspace.FallenPartsDestroyHeight = SavedFallen
        FallenToggleState = false
    end

end, false)

-- <<===== END ALMOST ENDLESS FALLEN =====>>

-- <<===== FLASHLIGHT (FirstPerson + Spotlight + PointLight) =====>>

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local flashlightPart = nil
local flashlightConn = nil

createToggle(BFrame, "Flashlight (FirstPerson & GFX 6+)", function(state)
    if state then
        --------------------------------------------------
        --                    ON
        --------------------------------------------------

        -- ล้างของเก่า
        if flashlightConn then
            flashlightConn:Disconnect()
            flashlightConn = nil
        end
        if flashlightPart and flashlightPart.Parent then
            flashlightPart:Destroy()
            flashlightPart = nil
        end

        -- สร้าง Part
        flashlightPart = Instance.new("Part")
        flashlightPart.Name = "FlashlightHeading(ExpSettings)"
        flashlightPart.Size = Vector3.new(1, 1, 1)
        flashlightPart.Transparency = 1
        flashlightPart.Anchored = true
        flashlightPart.CanCollide = false
        flashlightPart.CanTouch = false
        flashlightPart.Parent = workspace

        --------------------------------------------------
        --               SPOTLIGHT (หลัก)
        --------------------------------------------------
        local sp = Instance.new("SpotLight")
        sp.Angle = 60
        sp.Brightness = 1.5
        sp.Range = 60
        sp.Face = Enum.NormalId.Front
        sp.Color = Color3.fromRGB(255,255,255)
        sp.Shadows = true
        sp.Parent = flashlightPart

        --------------------------------------------------
        --               POINTLIGHT (เพิ่มเงานุ่ม)
        --------------------------------------------------
        local pl = Instance.new("PointLight")
        pl.Brightness = 1.5
        pl.Range = 6
        pl.Shadows = true
        pl.Color = Color3.fromRGB(255,255,255)
        pl.Parent = flashlightPart

        --------------------------------------------------
        --      ปรับค่าตามของเครื่องกราฟิกต่ำ (silent)
        --------------------------------------------------
        pcall(function()
            local ok, q = pcall(function()
                return settings().Rendering.QualityLevel
            end)

            if ok and typeof(q) == "number" and q < 6 then
                sp.Brightness = 1
                sp.Range = 40
                pl.Brightness = 1
                pl.Range = 6
            end
        end)

        --------------------------------------------------
        --          Lock เป็น FirstPerson
        --------------------------------------------------
        LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson

        --------------------------------------------------
        --      ติดตามตำแหน่งและมุมของกล้องทุกเฟรม
        --------------------------------------------------
        flashlightConn = RunService.RenderStepped:Connect(function()
            if flashlightPart and flashlightPart.Parent then
                flashlightPart.CFrame = Camera.CFrame
            end
        end)

    else
        --------------------------------------------------
        --                    OFF
        --------------------------------------------------

        if flashlightConn then
            flashlightConn:Disconnect()
            flashlightConn = nil
        end
        if flashlightPart and flashlightPart.Parent then
            flashlightPart:Destroy()
            flashlightPart = nil
        end

        -- กลับค่า Camera
        LocalPlayer.CameraMaxZoomDistance = 128
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
    end
end, false)

-- <<===== END FLASHLIGHT =====>>

--========================================================--
-- ESP Highlight Players & Non-Players (FULL TOGGLE)
--========================================================--

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ESP_Objects = {}
local espLoopRunning = false

-- ลบ highlight ทั้งหมด + ตั้ง transparency = 1
local function clearESP()
	for hrp, data in pairs(ESP_Objects) do
		if hrp and hrp.Parent then
			pcall(function()
				if data.highlight then
					data.highlight:Destroy()
				end
				hrp.Transparency = 1  -- OFF = 1
			end)
		end
	end
	ESP_Objects = {}
end

-- ใส่ highlight ลง HRP โดยตรง
local function applyHighlight(hrp, isRealPlayer)
	if not hrp or not hrp.Parent then return end
	if ESP_Objects[hrp] then return end

	hrp.Transparency = 0.5  -- ON = 0.5

	local h = Instance.new("Highlight")
	h.Parent = hrp
	h.FillTransparency = 1
	h.OutlineTransparency = 0
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

	if isRealPlayer then
		h.OutlineColor = Color3.fromRGB(0, 255, 0) -- ผู้เล่นจริง → เขียว
	else
		h.OutlineColor = Color3.fromRGB(255, 0, 0) -- NPC → แดง
	end

	ESP_Objects[hrp] = { highlight = h }
end

-- สแกน NPC
local function scanNPC()
	for _, hum in ipairs(workspace:GetDescendants()) do
		if hum:IsA("Humanoid") then
			local model = hum.Parent
			if model and not Players:GetPlayerFromCharacter(model) then
				local hrp = model:FindFirstChild("HumanoidRootPart")
				if hrp then
					applyHighlight(hrp, false)
				end
			end
		end
	end
end

-- สแกน Player จริง
local function scanPlayers()
	for _, plr in ipairs(Players:GetPlayers()) do
		local char = plr.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				applyHighlight(hrp, true)
			end
		end
	end
end

-- เริ่มการทำงาน ESP
local function startESPLoop()
	if espLoopRunning then return end
	espLoopRunning = true

	task.spawn(function()
		while espLoopRunning do
			scanPlayers()
			scanNPC()
			task.wait(0.2)
		end
	end)
end

-- หยุด ESP
local function stopESP()
	espLoopRunning = false
	clearESP()
end

--========================================================--
-- 🔘 TOGGLE BUTTON (พร้อมใช้งาน)
--========================================================--

createToggle(BFrame, "ESP Highlight Players & Non-Players", function(state)
	if state then
		startESPLoop()   -- เปิด
	else
		stopESP()        -- ปิด
	end
end, false) -- default OFF

-- ========== END ESP ==========

-- ======== SHIFT LOCK =======
createToggle(BFrame, "Shift Lock (Mobile)", function(state)
    sh.Visible = state
end, false)
-- ====== END SHIFT LOCK =====

task.wait(0.1)
lder.Size = UDim2.new(0.11,0,1,0)
task.wait(0.1)
lder.Size = UDim2.new(0.12,0,1,0)
task.wait(0.1)
lder.Size = UDim2.new(0.13,0,1,0)
task.wait(0.1)
lder.Size = UDim2.new(0.14,0,1,0)
task.wait(0.1)
lder.Size = UDim2.new(0.15,0,1,0)
task.wait(0.1)
lder.Size = UDim2.new(0.16,0,1,0)
task.wait(0.1)
lder.Size = UDim2.new(0.17,0,1,0)
task.wait(0.1)
lder.Size = UDim2.new(0.18,0,1,0)
task.wait(0.1)
lder.Size = UDim2.new(0.19,0,1,0)
task.wait(0.1)
lder.Size = UDim2.new(0.2,0,1,0)


--===========
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ฟังก์ชันลบ DeathSoundClient ส่วนเกิน
local function cleanDeathSounds()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local deathSounds = {}
        for _, obj in ipairs(hrp:GetChildren()) do
            if obj.Name == "DeathSoundClient" then
                table.insert(deathSounds, obj)
            end
        end

        -- ถ้ามากกว่า 1 ตัว ให้ลบตัวที่เกิน
        if #deathSounds > 1 then
            for i = 2, #deathSounds do
                pcall(function()
                    deathSounds[i]:Destroy()
                end)
            end
        end
    end
end

-- loop ตรวจจับและลบส่วนเกินทุก 0.05 วินาที
task.spawn(function()
    while true do
        cleanDeathSounds()
        task.wait(0.05)
    end
end)

--========================================
-- REAL-TIME HITBOX SHOWER (ViewportFrame)
-- Debug Only
--========================================

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--========================================
-- SETTINGS
--========================================

local HitboxView = {
    Enabled = false,
    Transparency = 0.5
}

--========================================
-- GUI
--========================================

local gui = Instance.new("ScreenGui")
gui.Name = "HitboxShower"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local viewport = Instance.new("ViewportFrame")
viewport.Size = UDim2.fromScale(1, 1)
viewport.BackgroundTransparency = 1
viewport.Parent = gui

local cam = Instance.new("Camera")
cam.Parent = viewport
viewport.CurrentCamera = cam

--========================================
-- STORAGE
--========================================

-- [player] = {
--    model = Model,
--    parts = { [partName] = clonePart }
-- }
local clones = {}

--========================================
-- UTILS
--========================================

local function getTeamColor(plr)
    if plr.Team and plr.Team.TeamColor then
        return plr.Team.TeamColor.Color
    end
    return Color3.fromRGB(255,255,255)
end

local function destroyClone(plr)
    local data = clones[plr]
    if data then
        data.model:Destroy()
        clones[plr] = nil
    end
end

--========================================
-- CREATE CLONE
--========================================

local function createClone(plr)
    if plr == LocalPlayer then return end
    if clones[plr] then return end

    local char = plr.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local model = Instance.new("Model")
    model.Name = plr.Name .. "_Hitbox"

    local partMap = {}
    local color = getTeamColor(plr)

    for _, inst in ipairs(char:GetDescendants()) do
        if inst:IsA("BasePart") then
            local p = Instance.new(inst.ClassName)
            p.Name = inst.Name
            p.Size = inst.Size
            p.CFrame = inst.CFrame
            p.Anchored = true
            p.CanCollide = false
            p.Material = Enum.Material.Plastic
            p.Color = color
            p.Transparency = HitboxView.Transparency
            p.Parent = model

            partMap[inst.Name] = p
        end
    end

    model.Parent = viewport

    clones[plr] = {
        model = model,
        parts = partMap
    }
end

--========================================
-- REAL-TIME UPDATE LOOP
--========================================

RunService.RenderStepped:Connect(function()
    if not HitboxView.Enabled then
        for plr in pairs(clones) do
            destroyClone(plr)
        end
        return
    end

    -- camera sync
    cam.CFrame = Workspace.CurrentCamera.CFrame

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end

        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if not char or not hum or hum.Health <= 0 then
            destroyClone(plr)
            continue
        end

        if not clones[plr] then
            createClone(plr)
        end

        local data = clones[plr]
        if not data then continue end

        -- REAL-TIME PART SYNC
        for _, inst in ipairs(char:GetDescendants()) do
            if inst:IsA("BasePart") then
                local clonePart = data.parts[inst.Name]
                if clonePart then
                    clonePart.CFrame = inst.CFrame
                    clonePart.Size = inst.Size
                end
            end
        end
    end
end)

--========================================
-- TOGGLE (ใช้ของเดิม)
--========================================

createToggle(BFrame, "Hitbox Shower", function(on)
    HitboxView.Enabled = on
    if not on then
        for plr in pairs(clones) do
            destroyClone(plr)
        end
    end
end, false)

--========================================
-- END
--========================================

--// =========================================
--// PHYSICS VISUAL DEBUGGER (FIXED)
--// Center-based Assembly Only
--// =========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// =========================================
--// SETTINGS
--// =========================================

local Physics = {
    Enabled = false,
    Global = false,

    MaxDistance = 200,
    TimeStep = 0.04,
    MaxTime = 2.5,

    SegmentThickness = 0.15,
}

--// =========================================
--// CACHE PER ROOT
--// =========================================

local PhysicsCache = {}

--// =========================================
--// UTILS
--// =========================================

local function newSegment()
    local p = Instance.new("Part")
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.Neon
    p.Size = Vector3.new(Physics.SegmentThickness, Physics.SegmentThickness, 1)
    p.Transparency = 1
    p.Parent = Workspace
    return p
end

local function newBall(color, size)
    local p = Instance.new("Part")
    p.Shape = Enum.PartType.Ball
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.Neon
    p.Color = color
    p.Size = Vector3.new(size, size, size)
    p.Transparency = 1
    p.Parent = Workspace
    return p
end

local function getState(root)
    if PhysicsCache[root] then
        return PhysicsCache[root]
    end

    local state = {
        Segments = {},
        BlueBall = newBall(Color3.fromRGB(0,180,255), 0.6),
        RedBall  = newBall(Color3.fromRGB(255,60,60), 1),
        Airborne = false,
    }

    PhysicsCache[root] = state
    return state
end

--// =========================================
--// ROOT RESOLVER (IMPORTANT FIX)
--// =========================================

local function getPhysicsRoot(inst)
    if inst:IsA("Model") then
        return inst.PrimaryPart
            or inst:FindFirstChild("HumanoidRootPart")
            or inst:FindFirstChildWhichIsA("BasePart")
    elseif inst:IsA("BasePart") then
        -- Ignore child parts inside models
        if inst.Parent and inst.Parent:IsA("Model") then
            return nil
        end
        return inst
    end
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist

--// =========================================
--// CORE SIMULATION
--// =========================================

local function drawPhysics(root)
    if root.Anchored then return end

    local state = getState(root)

    -- Reset visuals
    for _, s in ipairs(state.Segments) do
        s.Transparency = 1
    end
    table.clear(state.Segments)

    state.BlueBall.Transparency = 1
    state.RedBall.Transparency = 1

    local startPos = root.Position
    local velocity = root.AssemblyLinearVelocity
    local gravity = Vector3.new(0, -Workspace.Gravity, 0)

    rayParams.FilterDescendantsInstances = {root.Parent}

    local lastPos = startPos
    local landed = nil

    for t = 0, Physics.MaxTime, Physics.TimeStep do
        local pos = startPos + velocity * t + 0.5 * gravity * t * t

        if (pos - startPos).Magnitude > Physics.MaxDistance then
            break
        end

        local dir = pos - lastPos
        if dir.Magnitude > 0.05 then
            local hit = Workspace:Raycast(lastPos, dir, rayParams)
            if hit then
                landed = hit.Position
                break
            end

            local seg = newSegment()
            seg.Size = Vector3.new(
                Physics.SegmentThickness,
                Physics.SegmentThickness,
                dir.Magnitude
            )
            seg.CFrame = CFrame.new(lastPos + dir / 2, pos)
            seg.Color =
                math.abs(dir.Unit.Y) < 0.2 and Color3.fromRGB(0,255,0)
                or (dir.Unit.Y > 0 and Color3.fromRGB(255,255,0)
                or Color3.fromRGB(0,180,255))

            seg.Transparency = 0
            table.insert(state.Segments, seg)
        end

        lastPos = pos
    end

    -- STATE LOGIC
    if velocity.Y < -1 and not landed then
        state.Airborne = true
        state.BlueBall.Transparency = 0
        state.BlueBall.Position = lastPos
    end

    if landed then
        state.Airborne = false
        state.BlueBall.Transparency = 1
        state.RedBall.Transparency = 0
        state.RedBall.Position = landed
    end
end

--// =========================================
--// UPDATE LOOP
--// =========================================

RunService.RenderStepped:Connect(function()
    if not Physics.Enabled then
        for _, state in pairs(PhysicsCache) do
            for _, s in ipairs(state.Segments) do
                s.Transparency = 1
            end
            state.BlueBall.Transparency = 1
            state.RedBall.Transparency = 1
        end
        return
    end

    local origin = LocalPlayer.Character
        and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not origin then return end

    if Physics.Global then
        for _, inst in ipairs(Workspace:GetChildren()) do
            local root = getPhysicsRoot(inst)

            if root
                and root:IsA("BasePart")
                and root.AssemblyLinearVelocity.Magnitude > 1
                and (root.Position - origin.Position).Magnitude <= Physics.MaxDistance
            then
                drawPhysics(root)
            end
        end
    else
        drawPhysics(origin)
    end
end)

--// =========================================
--// TOGGLES
--// =========================================

createToggle(BFrame, "Show Physics", function(on)
    Physics.Enabled = on
end, false)

createToggle(BFrame, "Global Physics", function(on)
    Physics.Global = on
end, false)

--// =========================================
--// END
--// =========================================


--// ================================
--// LAST DEATH VISUAL
--// ================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--// ================================
--// STATE
--// ================================

local LastDeath = {
    Enabled = false,
    CurrentModel = nil
}

--// ================================
--// FOLDER
--// ================================

local DeathFolder = Workspace:FindFirstChild("LastDeathsFolderExpSettings")
if not DeathFolder then
    DeathFolder = Instance.new("Folder")
    DeathFolder.Name = "LastDeathsFolderExpSettings"
    DeathFolder.Parent = Workspace
end

--// ================================
--// CLEANUP
--// ================================

local function clearLastDeath()
    if LastDeath.CurrentModel then
        LastDeath.CurrentModel:Destroy()
        LastDeath.CurrentModel = nil
    end
end

--// ================================
--// CREATE GHOST
--// ================================

local function createLastDeathModel(character)
    clearLastDeath()

    local ghost = Instance.new("Model")
    ghost.Name = "LastDeath_" .. LocalPlayer.Name
    ghost.Parent = DeathFolder

    for _, inst in ipairs(character:GetDescendants()) do
        if inst:IsA("BasePart") then
            local p = inst:Clone()
            p.Anchored = true
            p.CanCollide = false
            p.Transparency = 0.7
            p.Material = Enum.Material.SmoothPlastic
            p.Parent = ghost
        end
    end

    LastDeath.CurrentModel = ghost
end

--// ================================
--// HUMANOID HOOK
--// ================================

local function hookCharacter(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end

    hum.Died:Connect(function()
        if LastDeath.Enabled then
            task.wait(0.1) -- ensure final pose
            createLastDeathModel(char)
        end
    end)
end

--// ================================
--// CHARACTER ADDED
--// ================================

if LocalPlayer.Character then
    hookCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    hookCharacter(char)
end)

--// ================================
--// TOGGLE
--// ================================

createToggle(BFrame, "Last Death", function(on)
    LastDeath.Enabled = on

    if not on then
        clearLastDeath()
    end
end, false)

--// ================================
--// END
--// ================================

--// =========================================
--// Server Position Predictor (By @zephyrr)
--// Toggle Version
--// =========================================

getgenv().ghost_rgb = true
getgenv().ghost_strength = 1
getgenv().ghost_max_limb = 6

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
LocalPlayer.Archivable = true

--// ========================
--// INTERNAL STATE
--// ========================

local Predictor = {
    Enabled = false,
    Heartbeat = nil,
    Ghosts = {},
    Frames = {}
}

--// ========================
--// CONSTANTS
--// ========================

local PART_NAMES = {
    "HumanoidRootPart","Head",
    "Left Arm","Right Arm","Left Leg","Right Leg",
    "LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm",
    "LeftHand","RightHand",
    "LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg",
    "LeftFoot","RightFoot"
}

--// ========================
--// HELPERS
--// ========================

local function rgb(t)
    return Color3.fromHSV((t % 5) / 5, 1, 1)
end

local function clearGhosts()
    for _, g in pairs(Predictor.Ghosts) do
        if g.ghost then g.ghost:Destroy() end
    end
    table.clear(Predictor.Ghosts)
    table.clear(Predictor.Frames)
end

local function makeGhost(real)
    local part = Instance.new("Part")
    part.Name = real.Name .. "_ghost"
    part.Size = real.Size
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.CFrame = real.CFrame
    part.Parent = workspace

    local box = Instance.new("SelectionBox")
    box.Adornee = part
    box.LineThickness = 0.04
    box.Parent = part

    return {
        real = real,
        ghost = part,
        box = box
    }
end

local function isReplicating(p)
    return p and not p.Anchored
end

local function isOwner(p)
    return p and p.ReceiveAge == 0
end

--// ========================
--// CORE SETUP
--// ========================

local function startPredictor()
    if Predictor.Heartbeat then return end

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    clearGhosts()

    for _, name in ipairs(PART_NAMES) do
        local p = char:FindFirstChild(name)
        if p and p:IsA("BasePart") then
            Predictor.Ghosts[name] = makeGhost(p)
        end
    end

    local serverCF = hrp.CFrame
    local velocity = Vector3.zero
    local lastTime = os.clock()
    local accumulator = 0

    Predictor.Heartbeat = RunService.Heartbeat:Connect(function()
        if not Predictor.Enabled or not hrp.Parent then
            clearGhosts()
            Predictor.Heartbeat:Disconnect()
            Predictor.Heartbeat = nil
            return
        end

        local now = os.clock()
        local delta = now - lastTime
        lastTime = now

        local ping = LocalPlayer.GetNetworkPing and LocalPlayer:GetNetworkPing() or 0.08

        if isReplicating(hrp) then
            velocity = isOwner(hrp) and hrp.AssemblyLinearVelocity or -hrp.AssemblyLinearVelocity
            if accumulator >= ping then
                serverCF = hrp.CFrame
                accumulator = 0
            else
                accumulator += delta
            end
        end

        local rel = {}
        for n, g in pairs(Predictor.Ghosts) do
            if g.real and g.real.Parent then
                rel[n] = serverCF:ToObjectSpace(g.real.CFrame)
            end
        end

        table.insert(Predictor.Frames, {
            t = now,
            cf = serverCF,
            pos = serverCF.Position,
            vel = velocity,
            rel = rel
        })

        if #Predictor.Frames > 240 then
            for _ = 1, 60 do table.remove(Predictor.Frames, 1) end
        end

        local targetT = now - ping
        local frame
        for i = #Predictor.Frames, 1, -1 do
            if Predictor.Frames[i].t <= targetT then
                frame = Predictor.Frames[i]
                break
            end
        end
        frame = frame or Predictor.Frames[1]
        if not frame then return end

        local td = math.min(targetT - frame.t, 0.06)
        local predPos = frame.pos + frame.vel * td * getgenv().ghost_strength
        local predCF = CFrame.new(predPos) * (frame.cf - frame.cf.Position)

        for n, g in pairs(Predictor.Ghosts) do
            local r = frame.rel[n]
            local target = r and predCF * r or g.real.CFrame

            local dist = (target.Position - predCF.Position).Magnitude
            if dist > getgenv().ghost_max_limb then
                local dir = (target.Position - predCF.Position).Unit
                local pos = predCF.Position + dir * getgenv().ghost_max_limb
                local rx, ry, rz = target:ToEulerAnglesXYZ()
                target = CFrame.new(pos) * CFrame.Angles(rx, ry, rz)
            end

            g.ghost.CFrame = g.ghost.CFrame:Lerp(target, math.min(delta * 18, 1))
            g.box.Color3 = getgenv().ghost_rgb and rgb(now) or Color3.new(1,1,1)
        end
    end)
end

--// ========================
--// TOGGLE
--// ========================

createToggle(BFrame, "ServerPositionPredictor (By @zephyrr)", function(on)
    Predictor.Enabled = on

    if on then
        startPredictor()
    else
        if Predictor.Heartbeat then
            Predictor.Heartbeat:Disconnect()
            Predictor.Heartbeat = nil
        end
        clearGhosts()
    end
end, false)

--// ========================
--// CHARACTER RESPAWN
--// ========================

LocalPlayer.CharacterAdded:Connect(function()
    if not Predictor.Enabled then return end
    LocalPlayer.Character:WaitForChild("HumanoidRootPart", 3)
    task.wait(0.15)
    startPredictor()
end)

--// =========================================
--// END
--// =========================================
