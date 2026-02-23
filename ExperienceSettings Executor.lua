local Version = [[0.0.42 Alpha
GitHub failed to load raw ahh]]
-- This executor

------------------------------------------------------------------------------------------

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
local Camera = Workspace.CurrentCamera
if Camera == Workspace.CurrentCamera then
  -- Do nothing
else
  Camera = nil
end


-- Third Party
local HttpService = game:GetService("HttpService")

-- Audio / Feedback
local SoundService = game:GetService("SoundService")

-- Commerce / Monetization
local MarketplaceService = game:GetService("MarketplaceService")

-- Runtime / Frame Updates
local RunService = game:GetService("RunService")

-- Animation / Transitions
local TweenService = game:GetService("TweenService")

-- Input (Desktop / Mobile)
local UserInputService = game:GetService("UserInputService")
local TouchInputService = game:GetService("TouchInputService")

---------------------------------------------------------------------------------------

local Folder = Instance.new("Folder")
Folder.Name = "ExperienceSettings-Executor"
Folder.Parent = CoreGui

local Windows = Instance.new("ScreenGui")
Windows.Name = "Main"
Windows.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
Windows.Parent = Folder

local Bg = Instance.new("Frame")
Bg.Name = "Background"
Bg.Size = UDim2.new(1,0,1,0)
Bg.BackgroundColor3 = Color3.fromRGB(18,18,21)
Bg.BackgroundTransparency = 0.3
Bg.Active = false
Bg.Parent = Windows

Bg.Transparency = 1

local Bg2 = Instance.new("Frame")
Bg2.Name = "Background2"
Bg2.Size = UDim2.new(1,0,1,0)
Bg2.BackgroundColor3 = Color3.fromRGB(18,18,21)
Bg2.BackgroundTransparency = 1
Bg2.Active = false
Bg2.Parent = Windows


local oc = Instance.new("ImageButton")
oc.Name = "connect"
oc.Size = UDim2.new(0.04,0,0.08,0)
oc.Position = UDim2.new(0.482, 0, 0.19, 0)
oc.BackgroundColor3 = Color3.fromRGB(18,18,21)
oc.Transparency = 0.08
oc.Draggable = true
oc.Image = "rbxassetid://116278455133074" -- Open
oc.Parent = Bg2
Corner(1,0, oc)
Stroke(oc, ASMBorder, 255,255,255, LJMRound, 3, 0)

local aspectConstraint = Instance.new("UIAspectRatioConstraint")
  aspectConstraint.AspectRatio = 1 -- 1:1 Square ratio
  aspectConstraint.AspectType = Enum.AspectType.FitWithinMaxSize
  aspectConstraint.DominantAxis = Enum.DominantAxis.Height -- Adjusts width to match height
  aspectConstraint.Parent = oc

local st = CoreGui["ExperienceSettings-Executor"].Main.Background2.connect.UIStroke
Gradient(st, 0, 0, 0,
    Color3.fromRGB(255,255,255),
    Color3.fromRGB(0,0,0)
)

local gr = st.UIGradient

task.spawn(function()
    while true do
        task.wait(0.001)
        gr.Rotation += 3
        if gr.Rotation == 360 then
           gr.Rotation = 0
        end

    end
end)

-- Close: oc.Image = "rbxassetid://120294896493053"

local oc = oc
local container = Bg2

local function clampPosition()
    local parentSize = container.AbsoluteSize
    local objSize = oc.AbsoluteSize
    local pos = oc.Position

    -- คำนวณตำแหน่งจริงบนจอ
    local absX = pos.X.Scale * parentSize.X + pos.X.Offset
    local absY = pos.Y.Scale * parentSize.Y + pos.Y.Offset

    -- clamp
    absX = math.clamp(absX, 0, parentSize.X - objSize.X)
    absY = math.clamp(absY, 0, parentSize.Y - objSize.Y)

    -- แปลงกลับเป็น Offset แต่ "เก็บ Scale เดิม"
    local newOffsetX = absX - (pos.X.Scale * parentSize.X)
    local newOffsetY = absY - (pos.Y.Scale * parentSize.Y)

    oc.Position = UDim2.new(
        pos.X.Scale, newOffsetX,
        pos.Y.Scale, newOffsetY
    )
end

oc:GetPropertyChangedSignal("Position"):Connect(clampPosition)
clampPosition()

------------------------------

local Bghr = Instance.new("CanvasGroup")
Bghr.Name = "Windows"
Bghr.Size = UDim2.new(1,0,0.75,0)
Bghr.BackgroundTransparency = 1
Bghr.Active = false
Bghr.Position = UDim2.new(0,0,-1,0)
Bghr.Parent = Bg

local Frame = {
    Home = Instance.new("CanvasGroup"),
    Edit = Instance.new("CanvasGroup"),
    Console = Instance.new("CanvasGroup"),
    Folder = Instance.new("CanvasGroup"),
    Bookmark = Instance.new("CanvasGroup"),
    Search = Instance.new("CanvasGroup"),
    Music = Instance.new("CanvasGroup"),
    Settings = Instance.new("CanvasGroup")
}

local function Configure(frame)
    frame.Visible = true
    frame.Size = UDim2.new(0.8, 0, 0.8, 0)
    frame.Position = UDim2.new(0.1, 0, -1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
    frame.BackgroundTransparency = 0.35
    frame.Parent = Bghr
    Corner(0.05,0,frame)
    Stroke(frame, ASMBorder, 255, 255, 255, LJMRound, 1.5, 0)
    
    local Inside = Instance.new("Frame")
    Inside.Name = "Inside"
    Inside.Size = UDim2.new(0.95,0,0.9,0)
    Inside.Position = UDim2.new(0.025,0,1,0) -- On is (0.025,0,0.05,0)
    Inside.BackgroundTransparency = 1
    Inside.Active = false
    Inside.Parent = frame
    
    local soon = Instance.new("TextLabel")
    soon.Name = "soon"
    soon.Visible = false
    soon.Size = UDim2.new(1,0,1,0)
    soon.BackgroundTransparency = 1
    soon.TextColor3 = Color3.fromRGB(255,255,255)
    soon.RichText = true
    soon.Text = [[ <b><font size="15">Coming soon...</font></b> ]]
    soon.Parent = Inside
    Corner(0.1,0,soon)
end

Configure(Frame.Home)
Configure(Frame.Edit)
Configure(Frame.Console)
Configure(Frame.Folder)
Configure(Frame.Bookmark)
Configure(Frame.Search)
Configure(Frame.Music)
Configure(Frame.Settings)

--[ Name ]
Frame.Home.Name = "Home"
Frame.Edit.Name = "Edit"
Frame.Console.Name = "Console"
Frame.Folder.Name = "Folder"
Frame.Bookmark.Name = "Bookmark"
Frame.Search.Name = "Search"
Frame.Music.Name = "Music"
Frame.Settings.Name = "Settings"

--[ Visible ]
Frame.Console.Inside.soon.Visible = true
Frame.Folder.Inside.soon.Visible = true
Frame.Bookmark.Inside.soon.Visible = true
Frame.Search.Inside.soon.Visible = true
Frame.Music.Inside.soon.Visible = true
Frame.Settings.Inside.soon.Visible = true
------------------------------------------------------------
local topn = Instance.new("Frame")
topn.Name = "TopNoity"
topn.Position = UDim2.new(0,0,0.1,0)
topn.Size = UDim2.new(1,0,0,43)
topn.BackgroundTransparency = 1
topn.Active = false
topn.Parent = Bg
ListLayout(topn, 0,5, HCenter, VTop, SLayout, FillV)

------------------------------------------------------------
-- local function
------------------------------------------------------------
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local color = {
    red = Color3.fromRGB(255,0,0), -- suitable for error
    orange = Color3.fromRGB(255,85,0), -- suitable for somthing
    yellow = Color3.fromRGB(255,255,0), -- sutiable for warning
    green = Color3.fromRGB(0,255,0), -- suitable for working
    cyan = Color3.fromRGB(0,255,255), --suitablr for something
    blue = Color3.fromRGB(0,0,255), -- sutiable for information
    pink = Color3.fromRGB(255,0,255), -- suitable for something
    purple = Color3.fromRGB(170,0,255), -- suitable for something
    nor = Color3.fromRGB(255,255,255) -- sutiable for custom
}

-- ฟังก์ชันแจ้งเตือน
local function noti(times, text, colorValue)
    local finalColor = colorValue or color.nor

    -- กล่องแจ้งเตือน
    local txt = Instance.new("TextLabel")
    txt.Name = "Notify"
    txt.BackgroundColor3 = Color3.fromRGB(18,18,21)
    txt.BackgroundTransparency = 0.5
    txt.TextWrap = true
    txt.RichText = true
    txt.TextScaled = false
    txt.TextSize = 18
    txt.Font = Enum.Font.GothamBold
    txt.Text = tostring(text)
    txt.TextColor3 = finalColor
    txt.ClipsDescendants = true
    txt.Parent = topn

    Corner(0.15,0,txt)

    -- แปลง Color3 → RGB
    local r = finalColor.R * 255
    local g = finalColor.G * 255
    local b = finalColor.B * 255

    Stroke(txt, ASMBorder, r, g, b, LJMRound, 1, 0)

    -- คำนวณขนาดข้อความ
    local textSize = TextService:GetTextSize(
        txt.Text,
        txt.TextSize,
        txt.Font,
        Vector2.new(1000, 100)
    )

    local padding = 30
    local finalSize = UDim2.new(0, textSize.X + padding, 0, textSize.Y + 20)

    -- เริ่มต้นเป็นศูนย์ก่อน
    txt.Size = UDim2.new(0,0,0,0)

    -- Tween ขยายเข้า
    TweenService:Create(
        txt,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = finalSize}
    ):Play()

    -- time bar
    local bar = Instance.new("Frame")
    bar.Name = "time"
    bar.Position = UDim2.new(0,0,0.9,0)
    bar.Size = UDim2.new(1,0,0.05,0)
    bar.BackgroundColor3 = finalColor
    bar.BorderSizePixel = 0
    bar.Parent = txt

    -- Tween time bar
    local barTween = TweenService:Create(
        bar,
        TweenInfo.new(times, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0,0,0.05,0)}
    )
    barTween:Play()

    -- เมื่อ time หมด
    barTween.Completed:Connect(function()

        local hideTween = TweenService:Create(
            txt,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {
                Size = UDim2.new(0,0,0,0),
                BackgroundTransparency = 1,
                TextTransparency = 1
            }
        )
        hideTween:Play()

        hideTween.Completed:Connect(function()
            txt:Destroy()
        end)
    end)
end

------------------------------------------------------------
-- home
------------------------------------------------------------

--[[ USER ]]
local user = Instance.new("Frame")
user.Name = "User"
user.Size = UDim2.new(0.5,0,0.2,0)
user.BackgroundColor3 = Color3.fromRGB(255,255,255)
user.Active = false
user.Parent = Frame.Home.Inside
Corner(0.1,0,user)
Stroke(user, ASMBorder, 255,255,255, LJMRound, 1, 0)
Gradient(user, 90,0,0,
  Color3.fromRGB(85,0,127),
  Color3.fromRGB(0,0,127)
)

local imauser = Instance.new("ImageLabel")
imauser.Name = "ImageLocalUser"
imauser.Size = UDim2.new(1,0,0.8,0)
imauser.Position = UDim2.new(0.025,0,0.1,0)
imauser.BackgroundColor3 = Color3.fromRGB(255,255,255)
imauser.BackgroundTransparency = 0.5
imauser.Image = "rbxassetid://"
imauser.Parent = user
Corner(0.1,0,imauser)
Stroke(imauser, ASMBorder, 255,255,255, LJMRound, 1, 0)
-- UIAspectRatioConstraint
local imauia = Instance.new("UIAspectRatioConstraint")
imauia.Parent = imauser
 
--[[ Label ]]
local lauser = Instance.new("TextLabel")
lauser.Name = "TheWelcome"
lauser.Position = UDim2.new(0.215,0,0.25,0)
lauser.Size = UDim2.new(0.75,0,0.5,0)
lauser.BackgroundTransparency = 1
lauser.Text = "Hello!, @Username."
lauser.TextColor3 = Color3.fromRGB(255,255,255)
lauser.TextScaled = true
lauser.TextXAlignment = Enum.TextXAlignment.Left
lauser.TextYAlignment = Enum.TextYAlignment.Center
lauser.Parent = user

--[[ Script ]]
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- โหลดรูปผู้เล่น
local userId = player.UserId
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420

local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
imauser.Image = content


-- ตรวจเวลา
local hour = tonumber(os.date("%H")) -- ได้ค่า 0 - 23

local timeGreeting = nil

if hour >= 5 and hour < 12 then
    timeGreeting = "Good morning"
elseif hour >= 12 and hour < 15 then
    timeGreeting = "Good afternoon"
elseif hour >= 15 and hour < 20 then
    timeGreeting = "Good evening"
elseif hour >= 20 and hour < 23 then
    timeGreeting = "Good night"
else
    timeGreeting = "Good midnight"
end


-- ข้อความสุ่ม
local greetings = {
    "Hello",
    "Welcome back",
    "Yo",
    "Greeting",
    "What's up",
    "Hey",
    "Ay",
    timeGreeting
}

-- เลือกแบบสุ่ม
local randomText = greetings[math.random(1, #greetings)]

-- ใส่ชื่อผู้เล่น
lauser.Text = randomText .. ", " .. player.Name .. "."

--[[ Note ]]
local frtxt = Instance.new("Frame")
frtxt.Name = "Note"
frtxt.Position = UDim2.new(0,0,0.25,0)
frtxt.Size = UDim2.new(0.5,0,0.75,0)
frtxt.BackgroundColor3 = Color3.fromRGB(255,255,255)
frtxt.Active = false
frtxt.Parent = Frame.Home.Inside
Corner(0.05,0,frtxt)
Stroke(frtxt, ASMBorder, 255,255,255, LJMRound, 1, 0)
Gradient(frtxt, 45,0,0,
  Color3.fromRGB(0,0,170),
  Color3.fromRGB(0,100,255)
)

local ttxt = Instance.new("TextLabel")
ttxt.Name = "Text"
ttxt.Position = UDim2.new(0.05,0,0,0)
ttxt.Size = UDim2.new(0.9,0,1,0)
ttxt.BackgroundTransparency = 1
ttxt.Active = false
ttxt.Text = [[
<b><font size="15">Note</font></b> 
ExperienceSettings Executor is for debugging script and it use only for executor app, so thank you for using our executor!

<b><font size="15">Credit</font></b>
@5teve3019D (ScriptBlox)

<b><font size="15">Executor Verison</font></b>
]] .. Version

ttxt.TextColor3 = Color3.fromRGB(255,255,255)
ttxt.TextSize = 10
ttxt.RichText = true
ttxt.TextWrap = true
ttxt.TextXAlignment = Enum.TextXAlignment.Left
ttxt.TextYAlignment = Enum.TextYAlignment.Top
ttxt.Parent = frtxt

--[[ soon ]]
local son = Instance.new("TextLabel")
son.Name = "Soon"
son.Position = UDim2.new(0.52,0,0.25,0)
son.Size = UDim2.new(0.48,0,0.75,0)
son.BackgroundTransparency = 1
son.Active = false
son.Text = [[
<b><font size="15">Soon</font></b> 
Coming soon...
]]

son.TextColor3 = Color3.fromRGB(255,255,255)
son.TextSize = 10
son.RichText = true
son.TextWrap = true
son.TextXAlignment = Enum.TextXAlignment.Center
son.TextYAlignment = Enum.TextYAlignment.Center
son.Parent = Frame.Home.Inside
Corner(0.05,0, son)
Stroke(son, ASMBorder, 255,255,255, LJMRound, 1, 0)

--[[ Soucre ]]
local dis = Instance.new("TextButton")
dis.Name = "Discord"
dis.Position = UDim2.new(0.52,0,0,0)
dis.Size = UDim2.new(0.48,0,0.2,0)
dis.BackgroundColor3 = Color3.fromRGB(27, 42, 53)
dis.TextSize = 20
dis.Text = "Join our Discord community! [ Copy ]"
dis.TextColor3 = Color3.fromRGB(255,255,255)
dis.TextWrap = true
dis.Parent = Frame.Home.Inside
Corner(0.05,0, dis)
Stroke(dis, ASMBorder, 255,255,255, LJMRound, 1, 0)
Gradient(dis, 90,0,0,
  Color3.fromRGB(170,0,255),
  Color3.fromRGB(0,170,255)
)

dis.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/UZXhApNH")
    noti(3, "<b>Copied!</b> Discord link copied to clipboard", color.green)
end)

------------------------------------------------------------
-- edit
------------------------------------------------------------
local edits = Instance.new("ScrollingFrame")
edits.Name = "EditScroll"
edits.Size = UDim2.new(0.5,0,1,0)
edits.BackgroundTransparency = 0
edits.BackgroundColor3 = Color3.fromRGB(0,0,0)
edits.ScrollBarThickness = 1
edits.CanvasSize = UDim2.new(10,0,100,0)
edits.Parent = Frame.Edit.Inside

local editb = Instance.new("TextBox")
editb.Name = "Edit"
editb.Size = UDim2.new(1,0,1,0)
editb.Position = UDim2.new(0,50,0,0)
editb.ClearTextOnFocus = false
editb.BackgroundTransparency = 1
editb.TextTransparency = 1
editb.TextSize = 15
editb.TextWrap = true
editb.RichText = true
editb.Text = ""
editb.PlaceholderText = 'print("Hello, World!")'
editb.TextColor3 = Color3.fromRGB(255,255,255)
editb.TextXAlignment = Enum.TextXAlignment.Left
editb.TextYAlignment = Enum.TextYAlignment.Top
editb.Parent = edits

--[ Script (Syntax) ]
--// SERVICES
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

--// PATH
local executor = CoreGui:WaitForChild("ExperienceSettings-Executor")
local scroll = executor.Main.Background.Windows.Edit.Inside.EditScroll
local editBox = scroll.Edit -- USE ONE ONLY

--// CONFIG
local FONT = Enum.Font.Code
local TEXT_SIZE = 15
local LINE_HEIGHT = 18
local MAX_CANVAS_HEIGHT = 180000
local VISIBLE_BUFFER = 80

scroll.AutomaticCanvasSize = Enum.AutomaticSize.None

--// TEXTBOX SETUP
editBox.MultiLine = true
editBox.ClearTextOnFocus = false
editBox.TextWrapped = false
editBox.Font = FONT
editBox.TextSize = TEXT_SIZE
editBox.TextColor3 = Color3.fromRGB(255,255,255)
editBox.TextXAlignment = Enum.TextXAlignment.Left
editBox.TextYAlignment = Enum.TextYAlignment.Top
editBox.BackgroundTransparency = 1
editBox.ZIndex = 3

--// HIGHLIGHT LAYER
local highlight = Instance.new("TextLabel")
highlight.Name = "SyntaxColor"
highlight.BackgroundTransparency = 1
highlight.TextColor3 = Color3.new(1,1,1)
highlight.RichText = true
highlight.Font = FONT
highlight.TextSize = TEXT_SIZE
highlight.TextWrapped = false
highlight.TextXAlignment = Enum.TextXAlignment.Left
highlight.TextYAlignment = Enum.TextYAlignment.Top
highlight.ZIndex = 2
highlight.Parent = scroll

--// LINE NUMBERS
local lineNumbers = Instance.new("TextLabel")
lineNumbers.BackgroundColor3 = Color3.fromRGB(25,25,25)
lineNumbers.BorderSizePixel = 0
lineNumbers.Font = FONT
lineNumbers.TextSize = TEXT_SIZE
lineNumbers.TextColor3 = Color3.fromRGB(140,140,140)
lineNumbers.TextXAlignment = Enum.TextXAlignment.Right
lineNumbers.TextYAlignment = Enum.TextYAlignment.Top
lineNumbers.ZIndex = 1
lineNumbers.Parent = scroll

--//COLORS
local COLORS = {
	Keyword   = "#c586c0",
	Comment   = "#6a9955",
	String    = "#ce9178",
	Datatype  = "#ff0000",
	Global    = "#4ec9b0",
}


local keywords = {  
	["local"]=true, ["function"]=true, ["return"]=true,  
	["if"]=true, ["then"]=true, ["elseif"]=true, ["else"]=true,  
	["for"]=true, ["while"]=true, ["do"]=true, ["end"]=true,  
	["break"]=true, ["continue"]=true, ["in"]=true,  
	["repeat"]=true, ["until"]=true,  
	["not"]=true, ["and"]=true, ["or"]=true  
}

local datatype = {

	["Axes"] = true,
	["BrickColor"] = true,
	["CatalogSearchParams"] = true,
	["CFrame"] = true,
	["Color3"] = true,
	["ColorSequence"] = true,
	["ColorSequenceKeypoint"] = true,
	["Content"] = true,
	["DateTime"] = true,
	["DockWidgetPluginGuiInfo"] = true,
	["Enum"] = true,
	["EnumItem"] = true,
	["Enums"] = true,
	["Faces"] = true,
	["FloatCurveKey"] = true,
	["Font"] = true,
	["Instance"] = true,
	["NumberRange"] = true,
	["NumberSequence"] = true,
	["NumberSequenceKeypoint"] = true,
	["OverlapParams"] = true,
	["Path2DControlPoint"] = true,
	["PathWaypoint"] = true,
	["PhysicalProperties"] = true,
	["Random"] = true,
	["Ray"] = true,
	["RaycastParams"] = true,
	["RaycastResult"] = true,
	["RBXScriptConnection"] = true,
	["RBXScriptSignal"] = true,
	["Rect"] = true,
	["Region3"] = true,
	["Region3int16"] = true,
	["RotationCurveKey"] = true,
	["Secret"] = true,
	["SharedTable"] = true,
	["TweenInfo"] = true,
	["UDim"] = true,
	["UDim2"] = true,
	["ValueCurveKey"] = true,
	["Vector2"] = true,
	["Vector2int16"] = true,
	["Vector3"] = true,
	["Vector3int16"] = true,
}

local globals = {

	["assert"]=true,
	["collectgarbage"]=true,
	["DebuggerManager"]=true,
	["delay"]=true,
	["elapsedTime"]=true,
	["Enum"]=true,
	["error"]=true,
	["game"]=true,
	["gcinfo"]=true,
	["getfenv"]=true,
	["getmetatable"]=true,
	["ipairs"]=true,
	["loadstring"]=true,
	["newproxy"]=true,
	["next"]=true,
	["pairs"]=true,
	["pcall"]=true,
	["plugin"]=true,
	["PluginManager"]=true,
	["print"]=true,
	["printidentity"]=true,
	["rawequal"]=true,
	["rawget"]=true,
	["rawlen"]=true,
	["rawset"]=true,
	["require"]=true,
	["script"]=true,
	["select"]=true,
	["setfenv"]=true,
	["setmetatable"]=true,
	["settings"]=true,
	["shared"]=true,
	["spawn"]=true,
	["stats"]=true,
	["tick"]=true,
	["time"]=true,
	["tonumber"]=true,
	["tostring"]=true,
	["type"]=true,
	["typeof"]=true,
	["unpack"]=true,
	["UserSettings"]=true,
	["version"]=true,
	["wait"]=true,
	["warn"]=true,
	["workspace"]=true,
	["xpcall"]=true,
	["ypcall"]=true,
	["_G"]=true,
	["_VERSION"]=true,
}

-- Escape FIRST
local function escape(text)
	return text
		:gsub("&","&amp;")
		:gsub("<","&lt;")
		:gsub(">","&gt;")
end

local function highlightLine(raw)

	local safe = escape(raw)

	-- protect escaped entities temporarily
	local entities = {}
	safe = safe:gsub("&[%a]+;", function(ent)
		table.insert(entities, ent)
		return "\0"..#entities.."\0"
	end)

	-- highlight comments
	safe = safe:gsub("%-%-.*", function(c)
		return '<font color="'..COLORS.Comment..'">'..c..'</font>'
	end)

	-- highlight strings
	safe = safe:gsub('"(.-)"', function(str)
		return '<font color="'..COLORS.String..'">"'..str..'"</font>'
	end)

	safe = safe:gsub("'(.-)'", function(str)
		return '<font color="'..COLORS.String..'">\''..str..'\'</font>'
	end)

	-- highlight keywords + datatype
safe = safe:gsub("(%f[%w_](%a[%w_]*)%f[^%w_])", function(full, word)

	if keywords[word] then
		return '<font color="'..COLORS.Keyword..'">'..word..'</font>'

	elseif datatype[word] then
		return '<font color="'..COLORS.Datatype..'">'..word..'</font>'

	elseif globals[word] then
		return '<font color="'..COLORS.Global..'">'..word..'</font>'
	end

	return word
end)

	-- restore entities
	safe = safe:gsub("\0(%d+)\0", function(i)
		return entities[tonumber(i)]
	end)

	return safe
end

local function isValidRichText(text)
	local open = 0
	
	for tag in text:gmatch("<(/?font[^>]*)>") do
		if tag:sub(1,1) == "/" then
			open -= 1
		else
			open += 1
		end
		
		if open < 0 then
			return false
		end
	end
	
	return open == 0
end


--// SPLIT
local function getLines(text)
	local t = {}
	for line in text:gmatch("([^\n]*)\n?") do
		table.insert(t,line)
	end
	return t
end

--// RENDER
local function render()

	local lines = getLines(editBox.Text)
	local total = #lines

	scroll.CanvasSize = UDim2.new(0, 10000, 0, total * LINE_HEIGHT)

	local first = math.floor(scroll.CanvasPosition.Y / LINE_HEIGHT) + 1
	local last = math.min(first + VISIBLE_BUFFER, total)

	local txt = {}
	local nums = {}

	for i = first,last do
	
  	local raw = lines[i] or ""
  	local result = highlightLine(raw)

    	if not isValidRichText(result) then
  		result = escape(raw)
  	end
	
   	table.insert(txt, result)
  	table.insert(nums, i)
  end

	highlight.Text = table.concat(txt,"\n")
	lineNumbers.Text = table.concat(nums,"\n")

	local y = (first-1)*LINE_HEIGHT

	highlight.Position = UDim2.new(0,50,0,y)
	lineNumbers.Position = UDim2.new(0,0,0,y)

	highlight.Size = UDim2.new(1,-50,0,(last-first+1)*LINE_HEIGHT)
	lineNumbers.Size = UDim2.new(0,46,0,(last-first+1)*LINE_HEIGHT)
end

editBox:GetPropertyChangedSignal("Text"):Connect(render)
scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(render)

render()


--[ End of syntax script ]

--[ Script new ]
local stab = Instance.new("ScrollingFrame")
stab.Name = "ScriptTabs"
stab.Position = UDim2.new(0.51,0,0,0)
stab.Size = UDim2.new(0.49,0,0.1,0)
stab.BackgroundColor3 = Color3.new(1,1,1)
stab.BackgroundTransparency = 0.5
stab.CanvasSize = UDim2.new(100,0,0,0)
stab.ScrollBarThickness = 2
stab.ScrollingDirection = Enum.ScrollingDirection.X
stab.Parent = Frame.Edit.Inside
Corner(0.15,0,stab)
Stroke(stab, ASMBorder, 255,255,255, LJMRound, 2, 0)
Gradient(stab, 90,0,0,
  Color3.fromRGB(85,0,127),
  Color3.fromRGB(0,255,255)
)

local stabi = Instance.new("Frame")
stabi.Name = "Inside"
stabi.Position = UDim2.new(0,0,0.1,0)
stabi.Size = UDim2.new(1,0,0.8,0)
stabi.BackgroundTransparency = 1
stabi.Active = false
stabi.Parent = stab
ListLayout(stabi, 0,5, HLeft, VCenter, SName, FillH)

local function uia(parent, num)
  local Ui = Instance.new("UIAspectRatioConstraint")
  Ui.AspectRatio = num
  Ui.Parent = parent
end
  
local addbtn = Instance.new("ImageButton")
addbtn.Name = "Z999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999_Add"
addbtn.Size = UDim2.new(1,0,1,0)
addbtn.BackgroundColor3 = Color3.new(0,0,0)
addbtn.Image = "rbxassetid://115181877700997"
addbtn.Parent = stabi
uia(addbtn, 1)
Corner(0.2,0,addbtn)
Stroke(addbtn, ASMBorder, 255,255,255, LJMRound, 1, 0)

--// ===============================
--// PATH
--// ===============================

local Edits = game:GetService("CoreGui")["ExperienceSettings-Executor"]
	.Main.Background.Windows.Edit.Inside.EditScroll
	
local Editb = Edits.Edit

--// ===============================
--// FOLDER SETUP
--// ===============================

--// ===============================
--// PATH + FOLDER SETUP
--// ===============================

local HttpService = game:GetService("HttpService")

local base = "ExperienceSettings-Executor"
local tabsPath = base .. "/Tabs"
local jsonPath = base .. "/workin.json"

-- สร้าง base folder
if not isfolder(base) then
	makefolder(base)
end

-- สร้าง sub folders
local folders = { "Workspace", "AutoExe", "Tabs" }

for _, folder in ipairs(folders) do
	local path = base .. "/" .. folder
	if not isfolder(path) then
		makefolder(path)
	end
end


--// ===============================
--// WORKIN DATA
--// ===============================

local highlightEnabled = true
local currentFile = nil

local workinData = {
	version = 1,
	lastOpened = nil,
	syntax = true
}


--// ===============================
--// LOAD WORKIN
--// ===============================

local function loadWorkin()

	-- ถ้าไม่มีไฟล์ สร้างใหม่
	if not isfile(jsonPath) then
		writefile(jsonPath, HttpService:JSONEncode(workinData))
	end

	local raw = readfile(jsonPath)

	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(raw)
	end)

	if ok and type(decoded) == "table" then
		
		workinData.version = decoded.version or 1
		workinData.lastOpened = decoded.lastOpened
		workinData.syntax = decoded.syntax ~= false
		
		highlightEnabled = workinData.syntax
		
	else
		-- ถ้าไฟล์พัง รีเซ็ต
		writefile(jsonPath, HttpService:JSONEncode(workinData))
	end
end


--// ===============================
--// SAVE WORKIN
--// ===============================

local function saveWorkin()

	workinData.syntax = highlightEnabled
	workinData.lastOpened = currentFile

	local ok, encoded = pcall(function()
		return HttpService:JSONEncode(workinData)
	end)

	if ok then
		writefile(jsonPath, encoded)
	end
end


--// ===============================
--// INIT
--// ===============================

loadWorkin()

--// ===============================
--// VARIABLES
--// ===============================

local i = 0
local currentFile = nil
local loadingFile = false
local saveDebounce = false

--// ===============================
--// SAVE SYSTEM
--// ===============================

local function saveCurrent()
	if not currentFile then return end
	if not isfile(currentFile) then return end
	
	writefile(currentFile, Editb.Text)
end

-- AUTO SAVE
Editb:GetPropertyChangedSignal("Text"):Connect(function()
	if loadingFile then return end
	if not currentFile then return end
	if saveDebounce then return end
	
	saveDebounce = true
	
	task.delay(0.3,function()
		if currentFile then
			saveCurrent()
		end
		saveDebounce = false
	end)
end)

--// ===============================
--// SCRIPT ADD
--// ===============================

local function scriptadd(existingFile)

	local filename
	local fullpath

	if existingFile then
		-- โหลดไฟล์เก่า
		fullpath = existingFile
		filename = existingFile:match("[^/\\]+$")
	else
		-- สร้างไฟล์ใหม่
		i += 1
		filename = "Script " .. i .. ".lua"
		fullpath = tabsPath .. "/" .. filename

		if not isfile(fullpath) then
			writefile(fullpath, "-- "..filename.."\n")
		end
	end

	local scr = Instance.new("TextButton")
	scr.Name = filename
	scr.Text = filename
	scr.Size = UDim2.new(1,0,0,30)
	scr.BackgroundColor3 = Color3.fromRGB(255,255,255)
	scr.TextColor3 = Color3.fromRGB(0,0,0)
	scr.TextXAlignment = Enum.TextXAlignment.Left
	scr.TextSize = 12
	scr.Parent = stabi
	Gradient(scr, 90,0,0,
	  Color3.fromRGB(0,255,255),
	  Color3.fromRGB(255,255,255)
	 )
	
	Corner(0.1,0,scr)
	Stroke(scr, ASMBorder,255,255,255,LJMRound,1,0)
	uia(scr,4)

	scr.MouseButton1Click:Connect(function()
		if currentFile then
			saveCurrent()
		end
		
		loadingFile = true
		currentFile = fullpath
		Editb.Text = readfile(fullpath)
		loadingFile = false
	end)

	local des = Instance.new("ImageButton")
	des.Name = "Destroy"
	des.Size = UDim2.new(1,0,1,0)
	des.Position = UDim2.new(0.7,0,0,0)
	des.BackgroundTransparency = 1
	des.Image = "rbxassetid://136855726459065"
	des.Parent = scr
	
	uia(des,1)

	des.MouseButton1Click:Connect(function()
		if currentFile == fullpath then
			Editb.Text = ""
			currentFile = nil
		end
		
		if isfile(fullpath) then
			delfile(fullpath)
		end
		
		scr:Destroy()
	end)
end

-- โหลดไฟล์ทั้งหมดตอนเข้าเกม
local files = listfiles(tabsPath)

-- รีเซ็ต i ตามจำนวนไฟล์จริง
i = 0

for _, file in ipairs(files) do
	if file:sub(-4) == ".lua" then
		i += 1
		scriptadd(file)
	end
end

--// ===============================
--// LOAD EXISTING
--// ===============================

local function loadExistingTabs()
	local files = listfiles(tabsPath)
	
	for _, file in ipairs(files) do
		if file:sub(-4) == ".lua" then
			i += 1
			
			local filename = file:match("[^/\\]+$")
			
			local scr = Instance.new("TextButton")
			scr.Name = filename
			scr.Text = filename
			scr.Size = UDim2.new(1,0,0,30)
			scr.BackgroundColor3 = Color3.fromRGB(255,255,255)
			scr.TextColor3 = Color3.fromRGB(0,0,0)
			scr.TextSize = 12
			scr.Parent = stabi
			
			Corner(0.1,0,scr)
			Stroke(scr, ASMBorder,255,255,255,LJMRound,1,0)
			uia(scr,4)

			scr.MouseButton1Click:Connect(function()
				if currentFile then
					saveCurrent()
				end
				
				loadingFile = true
				currentFile = file
				Editb.Text = readfile(file)
				loadingFile = false
			end)
		end
	end
end

--// ===============================
--// CONNECT BUTTON
--// ===============================

addbtn.MouseButton1Click:Connect(scriptadd)

-- ถ้าต้องการโหลดไฟล์เก่าทั้งหมดตอนเปิด
-- loadExistingTabs()

--[ End of script tabs ]
local syntg = Instance.new("TextButton")
syntg.Name = "SyntaxHighlightToggle"
syntg.Position = UDim2.new(0.51,0,0.125,0)
syntg.Size = UDim2.new(1,0,0.1,0)
syntg.BackgroundColor3 = Color3.new(1,1,1)
syntg.TextScaled = true
syntg.TextColor3 = Color3.new(0,0,0)
syntg.Text = "Syntax Highlight"
syntg.Parent = Frame.Edit.Inside
Corner(0.1,0,syntg)
uia(syntg, 4)
local syngr = Gradient(syntg, 90,0,0, Color3.fromRGB(255,85,0), Color3.fromRGB(255,255,255)
)

--// ===============================
--// SYNTAX TOGGLE (SYNTG)
--// ===============================

local TweenService = game:GetService("TweenService")

-- อัปเดต UI ตามสถานะ
local function applySyntaxState()

	if highlightEnabled then
		-- ON
		highlight.TextTransparency = 0
		Editb.TextTransparency = 1
		syntg.BackgroundColor3 = Color3.fromRGB(0,255,0)
	else
		-- OFF
		highlight.TextTransparency = 1
		Editb.TextTransparency = 0
		syntg.BackgroundColor3 = Color3.fromRGB(255,0,0)
	end
	noti(2, "Syntax Highlight Update!", color.cyan)

	render()
end


-- หมุน gradient
local function rotateGradient()

	local tween = TweenService:Create(
		syngr,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Rotation = syngr.Rotation + 360}
	)

	tween:Play()

	tween.Completed:Connect(function()
		syngr.Rotation = 0
	end)
end


-- ปุ่มคลิก
syntg.MouseButton1Click:Connect(function()

	highlightEnabled = not highlightEnabled

	rotateGradient()
	applySyntaxState()
	saveWorkin()
end)


-- เรียกตอนเริ่มระบบให้ตรงกับค่าที่โหลดมา
applySyntaxState()

--[[ End of syntax toggle ]]

--[[ Execute buttons ]]
local etabs = Instance.new("CanvasGroup")
etabs.Name = "Execute tabs"
etabs.Position = UDim2.new(0.51,0,0.85,0)
etabs.Size = UDim2.new(0.49,0,0.15,0)
etabs.BackgroundTransparency = 0.3
etabs.Active = false
etabs.BackgroundColor3 = Color3.fromRGB(70,70,70)
etabs.Parent = Frame.Edit.Inside
Corner(0.1,0,etabs)
Stroke(etabs, ASMBorder, 255, 255, 255, LJMRound, 1, 0)

local eftabs = Instance.new("Frame")
eftabs.Name = "Inside"
eftabs.Position = UDim2.new(0.05,0,0.15,0)
eftabs.Size = UDim2.new(0.9,0,0.7,0)
eftabs.BackgroundTransparency = 1
eftabs.Active = false
eftabs.Parent = etabs
ListLayout(eftabs, 0, 5, HLeft, VCenter, SLayout, FillH)

local function exe(name, imageID, workin)

	local eb = Instance.new("ImageButton")
	eb.Name = tostring(name)
	eb.Size = UDim2.new(1,0,1,0) -- ห้ามแก้
	eb.BackgroundColor3 = Color3.new(0,0,0)
	eb.Image = "rbxassetid://" .. tostring(imageID)
	eb.Parent = eftabs
	
	Corner(0.1,0,eb)
	Stroke(eb, ASMBorder, 255,255,255, LJMRound, 1, 0)
	uia(eb, 1)

	eb.MouseButton1Click:Connect(function()

		-- ==============================
		-- 1️⃣ Execute
		-- ==============================
		if workin == "Execute" then
			
			local src = Editb.Text
			
			if src and src ~= "" then
				
				local f = loadstring(src)
				
				local f, compileErr = loadstring(src)

if not f then
	
	-- Compile error
	local line = compileErr:match(":(%d+):") or "?"
	noti(10, "Script Error [ At Line: "..line.." ]: "..compileErr, color.red)
	
else
	
	local success, runtimeErr = pcall(f)
	
	if success then
		noti(2, "Execute script!", color.green)
	else
		-- Runtime error
		local line = runtimeErr:match(":(%d+):") or "?"
		noti(10, "Script Error [ At Line: "..line.." ]: "..runtimeErr, color.red)
	end
	
end
			end


-- ==============================
-- 2️⃣ PasteAndExecute
-- ==============================
elseif workin == "PasteAndExecute" then
	
	if getclipboard then
		
		local clip = getclipboard()
		
		if clip and clip ~= "" then
			
			Editb.Text = clip
			
			local f, compileErr = loadstring(clip)
			
			-- 🔴 Compile Error
			if not f then
				
				local line = tostring(compileErr):match(":(%d+):") or "?"
				noti(10, "Script Error [ At Line: "..line.." ]: "..compileErr, color.red)
				
			else
				
				local success, runtimeErr = pcall(f)
				
				-- 🟢 Success
				if success then
					noti(2, "Paste script and Execute!", color.green)
					
				-- 🔴 Runtime Error
				else
					local line = tostring(runtimeErr):match(":(%d+):") or "?"
					noti(10, "Script Error [ At Line: "..line.." ]: "..runtimeErr, color.red)
				end
				
			end
			
		end
		
	else
		noti(2, "Clipboard not supported in this executor", color.red)
	end
				

		-- ==============================
		-- 3️⃣ Paste
		-- ==============================
		elseif workin == "Paste" then
			
			if getclipboard then
				
				local clip = getclipboard()
				
				if clip and clip ~= "" then
					Editb.Text = clip
					noti(2, "Paste script!", color.yellow)
				end
				
			else
				noti(2, "Clipboard not supported in this executor", color.red)
			end


		-- ==============================
		-- 4️⃣ Copy
		-- ==============================
		elseif workin == "Copy" then
			
			if setclipboard then
				
				if Editb.Text ~= "" then
					setclipboard(Editb.Text)
					noti(2, "Copy script!", color.yellow)
				end
				
			else
				noti(2, "Clipboard not supported in this executor!", color.red)
			end


		-- ==============================
		-- 5️⃣ Clear
		-- ==============================
		elseif workin == "Clear" then
			
			Editb.Text = ""
			noti(2, "Clear script! Make sure you save it.", color.red)
		end

	end)

end

exe("Execute", 104470314612186, "Execute")
exe("PasteAndExecute", 124911554606290, "PasteAndExecute")
exe("Paste", 81493320721369, "Paste")
exe("Copy", 70463360371392, "Copy")
exe("Clear", 105129411837741, "Clear")

--[[ Keywords seeker ]]
--// UI REFERENCES (ใช้ของนายแทนได้)
local Editb = Frame.Edit.Inside.Edit

local kword = Instance.new("ScrollingFrame")
kword.Name = "KeywordsSeeker"
kword.Position = UDim2.new(0.71,0,0.126,0)
kword.Size = UDim2.new(0.29,0,0.7,0)
kword.BackgroundTransparency = 0.5
kword.BackgroundColor3 = Color3.new(0,0,0)
kword.ScrollBarThickness = 2
kword.CanvasSize = UDim2.new(0,0,0,0)
kword.ScrollDirection = Enum.ScrollDirection.Y
kword.Parent = Frame.Edit.Inside

Corner(0,0,kword)
ListLayout(kword, 0,2, HLeft, VTop, SLayout, FillV)

local function createSuggestion(word, colorHex, T)

	local keyword = Instance.new("TextLabel")
	keyword.Size = UDim2.new(1,0,0,22)
	keyword.BackgroundColor3 = Color3.fromRGB(40,40,40)
	keyword.BackgroundTransparency = T
	keyword.TextXAlignment = Enum.TextXAlignment.Left
	keyword.TextSize = 13
	keyword.RichText = true
	keyword.Text = '<font color="'..colorHex..'">'..word..'</font>'
	keyword.Parent = kword

end

local function updateSuggestions()

	clearSuggestions()

	local current = getCurrentWord(Editb.Text)
	if current == "" then
		kword.CanvasSize = UDim2.new(0,0,0,0)
		return
	end

	local lowerCurrent = current:lower()
	local keywordCount = 0

	for keywordName, keywordType in pairs(ALL_WORDS) do

		local lowerKeyword = keywordName:lower()

		if lowerKeyword:sub(1,#lowerCurrent) == lowerCurrent then
			
			local keywordColor = COLORS[keywordType] or "#ffffff"

			local keywordTransparency
			if lowerKeyword == lowerCurrent then
				keywordTransparency = 0 -- ตรงเป๊ะ
			else
				keywordTransparency = 0.5 -- เกือบตรง
			end

			createSuggestion(keywordName, keywordColor, keywordTransparency)
			keywordCount += 1
		end
	end

	-- ถ้าไม่เจออะไรเลย → แสดงคำที่พิมพ์ (ขาว + จางสุด)
	if keywordCount == 0 then
		createSuggestion(current, "#ffffff", 1)
		keywordCount = 1
	end

	kword.CanvasSize = UDim2.new(0,0,0, keywordCount * 24)

end

------------------------------------------------------------
local Inside = Instance.new("CanvasGroup")
Inside.Name = "Inside"
Inside.Position = UDim2.new(0.15,0,1.2,0)
Inside.Size = UDim2.new(0.7,0,0.15,0)
Inside.BackgroundColor3 = Color3.fromRGB(18,18,21)
Inside.Transparency = 0.1
Inside.Parent = Bg
Corner(0.2,0,Inside)
Stroke(Inside, ASMBorder, 255,255,255, LJMRound, 2, 0)

local str1 = Inside.UIStroke
local gra1 = Gradient(str1, 45, 0, 0,
    Color3.fromRGB(255,255,255),
    Color3.fromRGB(0,0,0)
)

task.spawn(function()
    while true do        task.wait(0.001)
        gra1.Rotation += 3
        if gra1.Rotation == 360 then
           gra1.Rotation = 0
        end

    end
end)

local Bar = Instance.new("Frame")
Bar.Name = "Holder"
Bar.Position = UDim2.new(0.02,0,0.25,0)
Bar.Size = UDim2.new(0.96,0,0.5,0)
Bar.BackgroundTransparency = 1
Bar.Parent = Inside
ListLayout(Bar, 0, 10, HLeft, VCenter, SLayout, FillH)

local TweenService = game:GetService("TweenService")
local TweenService = game:GetService("TweenService")

local oc = oc
local inside = Inside
local Bg = Bg
local Bghr = Bghr

local bounceInfo = TweenInfo.new(
    0.4,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)

local shrinkInfo = TweenInfo.new(
    0.2,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)

local bgInfo = TweenInfo.new(
    0.5,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)

oc.MouseButton1Click:Connect(function()

    -- Tween ย่อ oc
    local shrinkTween = TweenService:Create(oc, shrinkInfo, {
        Size = UDim2.new(0,0,0,0)
    })
    shrinkTween:Play()

    -- ซ่อนหลังย่อเสร็จ
    shrinkTween.Completed:Connect(function()
        oc.Visible = false
    end)

    -- เด้ง Inside
    TweenService:Create(inside, bounceInfo, {
        Position = UDim2.new(0.15,0,0.8,0)
    }):Play()

    -- ทำให้พื้นหลังมืดลง
    TweenService:Create(Bg, bgInfo, {
        BackgroundTransparency = 0.3
    }):Play()

    -- เลื่อน Bghr ขึ้นมา
    TweenService:Create(Bghr, bgInfo, {
        Position = UDim2.new(0,0,0.1,0)
    }):Play()

end)

------------------------------------------------------------

local TweenService = game:GetService("TweenService")

local ActiveColor = Color3.fromRGB(140, 0, 255)
local InactiveColor = Color3.fromRGB(0, 0, 0)

local Buttons = {}

local btnTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local frameTween = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local insideTween = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function activateTab(name)
    for btnName, btn in pairs(Buttons) do
        
        local frame = Frame[btnName]
        if not frame then
            --[[ Frame not found ]]
            continue
        end

        local inside = frame:FindFirstChild("Inside")

        if btnName == name then
            -- ปุ่มที่ถูกกด
            TweenService:Create(btn, btnTween, {
                BackgroundColor3 = ActiveColor
            }):Play()

            TweenService:Create(
                btn.UIAspectRatioConstraint,
                btnTween,
                {AspectRatio = 2}
            ):Play()

            TweenService:Create(frame, frameTween, {
                Position = UDim2.new(0.1,0,0.1,0)
            }):Play()

            if inside then
                TweenService:Create(inside, insideTween, {
                    Position = UDim2.new(0.025,0,0.05,0)
                }):Play()
            end
        else
            -- ปุ่มอื่น
            TweenService:Create(btn, btnTween, {
                BackgroundColor3 = InactiveColor
            }):Play()

            TweenService:Create(
                btn.UIAspectRatioConstraint,
                btnTween,
                {AspectRatio = 1}
            ):Play()

            TweenService:Create(frame, frameTween, {
                Position = UDim2.new(0.1,0,-1,0)
            }):Play()

            if inside then
                TweenService:Create(inside, insideTween, {
                    Position = UDim2.new(0.025,0,2,0)
                }):Play()
            end
        end
    end
end


local function Btn(name, imageID, workin, callback, state)
  local imabtn = Instance.new("ImageButton")
  imabtn.Name = tostring(name)
  imabtn.Size = UDim2.new(0,0,1,0)
  imabtn.ScaleType = Enum.ScaleType.Fit

  local aspectConstraint = Instance.new("UIAspectRatioConstraint")
  aspectConstraint.AspectRatio = 1
  aspectConstraint.AspectType = Enum.AspectType.ScaleWithParentSize
  aspectConstraint.DominantAxis = Enum.DominantAxis.Height
  aspectConstraint.Parent = imabtn

  imabtn.BackgroundColor3 = InactiveColor
  imabtn.Image = "rbxassetid://" .. tostring(imageID)
  imabtn.Parent = Bar

  Corner(0.15, 0, imabtn)
  Stroke(imabtn, ASMBorder, 255,255,255, LJMRound, 1,0)
  Gradient(imabtn, 45,0,0,
    Color3.fromRGB(85,255,255),
    Color3.fromRGB(255,255,255)
  )

  -- เก็บปุ่ม
  Buttons[name] = imabtn

  if workin then
    task.spawn(function()
      workin(imabtn)
    end)
  end

  local toggled = false

  imabtn.MouseButton1Click:Connect(function()
    if state == "toggle" then
      toggled = not toggled
      if callback then
        callback(toggled, imabtn)
      end
    else
      -- เปิดแท็บตามชื่อปุ่ม
      activateTab(name)

      if callback then
        callback(imabtn)
      end
    end
  end)

  return imabtn
end
------------------------------------------------------------

local Close = Btn(
    "Close",
    76063966669126,
    nil,
    function()

        oc.Visible = true

        -- Tween oc กลับขนาดปกติ
        TweenService:Create(oc,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0.04,0,0.08,0)}
        ):Play()

        -- Tween Inside ลงล่าง
        TweenService:Create(Inside,
            TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(0.15,0,1.2,0)}
        ):Play()

        -- ทำให้พื้นหลังโปร่งใสกลับปกติ
        TweenService:Create(Bg,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 1}
        ):Play()

        -- เลื่อน Bghr ลง
        TweenService:Create(Bghr,
            TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(0,0,-1,0)}
        ):Play()
    end
)

Close.BackgroundColor3 = Color3.fromRGB(170,0,0)


home = Btn("Home", 70503788933260)
edit = Btn("Edit", 89040201197978)
console = Btn("Console", 76584386272665)
folder = Btn("Folder", 86157935898545)
bookmark = Btn("Bookmark", 71272710123832)
search = Btn("Search", 126157187256564)
music = Btn("Music", 120343700432506)
settings = Btn("Settings", 139502039855639)















noti(3, "<b>Welcome!</b> Successful loaded!", color.green)

noti(5, "<b>Verison: </b>" .. Version, color.nor)
