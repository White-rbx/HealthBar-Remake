local v_ver = [[Editor 0.98 Test]]
--[[ UI_functions version: 2.3 ( Reduced Locals for more less risk to due Out Of Local ) ]]

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
    local stroke = parent:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
    stroke.ApplyStrokeMode = StrokeUI[ASM] or StrokeUI.ASMBorder
    stroke.Color = Color3.fromRGB(R or 255, G or 255, B or 255)
    stroke.LineJoinMode = StrokeUI[LJM] or StrokeUI.LJMRound
    stroke.Thickness = Tn or 1
    stroke.Transparency = Transy or 0
    stroke.Parent = parent
    return stroke
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
 Axis = Enum.DominantAxis,
 Type = Enum.AspectType,

-- optional ultra-short aliases
 Width = Axis.Width,
 Height = Axis.Height,

 Fit = Type.FitWithinMaxSize,
 Scale = Type.ScaleWithParentSize
}


--// ASPECT FUNCTION
function Aspect(parent, ratio, aspectType, dominantAxis)
	if not parent then return end
	
	-- prevent duplicates
	local existing = parent:FindFirstChildOfClass("UIAspectRatioConstraint")
	if existing then
		-- update instead
		existing.AspectRatio = AspectUI[ratio] or existing.AspectRatio
		existing.AspectType = AspectUI[aspectType] or existing.AspectType
		existing.DominantAxis = AspectUI[dominantAxis] or existing.DominantAxis
		return existing
	end
	
	-- create new
	local constraint = Instance.new("UIAspectRatioConstraint")
	constraint.Parent = parent
	
	constraint.AspectRatio = AspectUI[ratio] or 1
	constraint.AspectType = AspectUI[aspectType] or AspectUI.Fit
	constraint.DominantAxis = AspectUI[dominantAxis] or AspectUI.Width
	
	return constraint
end

-- =====END FUNCTION UIASPECTRATIONCONSTRAINT=====

--[[
====== CLIENT SERVICES ( OLD ) ======

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

-- Storage
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Third Party
local HttpService = game:GetService("HttpService")

-- Audio / Feedback
local SoundService = game:GetService("SoundService")

-- Commerce / Monetization
local MarketplaceService = game:GetService("MarketplaceService")

-- Runtime / Frame Updates
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local TextChatService = game:GetService("TextChatService")

-- Animation / Transitions
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

-- Input (Desktop / Mobile)
local UserInputService = game:GetService("UserInputService")
local TouchInputService = game:GetService("TouchInputService")
]]

--====== CLIENT SERVICES ( TABLE ); Use like this 'Service.Example' ======--

local s = {
-- UI / Player Interface
 CoreGui = game:GetService("CoreGui"),
 StarterGui = game:GetService("StarterGui"),
 GuiService = game:GetService("GuiService"),
 Players = game:GetService("Players"),

-- 3D/2D Destroy
 Debris = game:GetService("Debris"),

-- 3D Wprkspace
 Workspace = game:GetService("Workspace"),
 TeleportService = game:GetService("TeleportService"),
 Lighting = game:GetService("Lighting"),
 Camera = Workspace.CurrentCamera,

-- Storage
 ReplicatedStorage = game:GetService("ReplicatedStorage"),

-- Third Party
 HttpService = game:GetService("HttpService"),

-- Audio / Feedback
 SoundService = game:GetService("SoundService"),

-- Commerce / Monetization
 MarketplaceService = game:GetService("MarketplaceService"),

-- Runtime / Frame Updates
 RunService = game:GetService("RunService"),
 TextService = game:GetService("TextService"),
 TextChatService = game:GetService("TextChatService"),

-- Animation / Transitions
 TweenService = game:GetService("TweenService"),
 ContentProvider = game:GetService("ContentProvider"),

-- Input (Desktop / Mobile)
 UserInputService = game:GetService("UserInputService"),
 TouchInputService = game:GetService("TouchInputService"),

}

-- All local in one tabel; Use like this 'loc.Example'
local loc = {
  -- v Local V
  
}

---------------------------------------------------------------------------------------

local function Tween(obj, size, pos, backcol, tra, time)
    local tween = s.TweenService:Create(
        obj,
        TweenInfo.new(
            time,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {Size = size,
        Position = pos,
        BackgroundColor3 = backcol,
        BackgroundTransparency = tra,
        }
    )

    tween:Play()
    return tween
end

local state = false
local menu = game:GetService("CoreGui"):WaitForChild("ExperienceSettings").Menu

local notif = Instance.new("Frame")
notif.Name = "Notification"
notif.ClipsDescendants = true
notif.Size = UDim2.new(1,0,0.4,0)
notif.Position = UDim2.new(0,0,0.11,0)
notif.BorderMode = Enum.BorderMode.Inset
notif.BorderSizePixel = 10
notif.BackgroundTransparency = 1
notif.Active = false
notif.Parent = menu
ListLayout(notif, 0,5,"HCenter","VTop","SLayout","FillV")


local function ding(txt, time, R, G, B)
    local duration = tonumber(time)

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.ClipsDescendants = true
    main.AutomaticSize = Enum.AutomaticSize.XY
    main.BackgroundTransparency = 1
    main.Active = false
    main.Parent = notif
    Corner(0,5,main)

    local scale = Instance.new("UIScale")
    scale.Scale = 0
    scale.Parent = main

    local body = Instance.new("Frame")
    body.Name = "Body"
    body.ClipsDescendants = true
    body.AutomaticSize = Enum.AutomaticSize.XY
    body.BackgroundColor3 = Color3.new(0,0,0)
    body.BackgroundTransparency = 0.5
    body.BorderMode = Enum.BorderMode.Inset
    body.BorderSizePixel = 10
    body.Active = false
    body.Parent = main
    Corner(0,5,body)

    local s_body = Stroke(body, "ASMBorder", R or 255, G or 255, B or 255, "LJMRound", 2, 0)
    s_body.BorderStrokePosition = Enum.BorderStrokePosition.Inner

    local text = Instance.new("TextLabel")
    text.Name = "Text"
    text.BackgroundTransparency = 1
    text.AutomaticSize = Enum.AutomaticSize.XY
    text.TextSize = 12
    text.TextWrapped = true
    text.RichText = true
    text.TextColor3 = Color3.fromRGB(R or 255, G or 255, B or 255)
    text.Text = txt == nil and "<b>Failed</b>: Uhm.. I forgot" or tostring(txt)
    text.Parent = body

    local timer = Instance.new("Frame")
    timer.Name = "Timer"
    timer.Size = UDim2.new(1,0,0,5)
    timer.Position = UDim2.new(0,0,1,-5)
    timer.BackgroundColor3 = Color3.fromRGB(R or 255, G or 255, B or 255)
    timer.BorderSizePixel = 0
    timer.Active = false
    timer.Parent = main

    -- Open: UIScale 0 -> 1
    s.TweenService:Create(
        scale,
        TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
        {Scale = 1}
    ):Play()

    -- Countdown (nil or 0 = permanent)
    if duration and duration > 0 then
        local timerTween = s.TweenService:Create(
            timer,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {Size = UDim2.new(0,0,0,5)}
        )

        timerTween:Play()

        task.delay(duration, function()
            if not main.Parent then
                return
            end

            -- Close: UIScale 1 -> 0
            local closeTween = s.TweenService:Create(
                scale,
                TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.In),
                {Scale = 0}
            )

            closeTween:Play()
            closeTween.Completed:Wait()

            main:Destroy()
        end)
    end
end


local editor = menu.TopBar.Holder.a5_Editor

local eback = Instance.new("Frame")
eback.Name = "Editor"
eback.Position = UDim2.new(0.1,0,1.1,0)
eback.Size = UDim2.new(0.8,0,0.8,0)
eback.BorderMode = Enum.BorderMode.Inset
eback.BorderSizePixel = 5
eback.BackgroundColor3 = Color3.fromRGB(17,18,25)
eback.BackgroundTransparency = 1
eback.Active = false
eback.Parent = menu
Corner(0,8,eback)
ListLayout(eback, 0, 10, "HCenter", "VCenter", "SLayout", "FillV")

editor.MouseButton1Click:Connect(function()
  if state == true then
      editor.Image = "rbxassetid://73984153023004"
      state = false
      Tween(eback, nil, UDim2.new(0.1,0,1.1,0), nil,nil, 0.4)
  else
      editor.Image = "rbxassetid://108682872011804"
      state = true
      Tween(eback, nil, UDim2.new(0.1,0,0.18,0), nil,nil, 0.4)
  end
end)

task.spawn(function()
  local holder = menu.TopBar.Holder
	local function checkHolderSize()
		local x = holder.Size.X.Offset
		if x > 311 then
			editor.Visible = true
		else
			editor.Visible = false
		end
	end

	checkHolderSize()

	holder:GetPropertyChangedSignal("Size"):Connect(checkHolderSize)
end)

local can = Instance.new("Frame")
can.Name = "Page"
can.Size = UDim2.new(1,0,0.8,0)
can.BackgroundColor3 = eback.BackgroundColor3
can.BackgroundTransparency = 0.1
can.BorderMode = eback.BorderMode
can.BorderSizePixel = 10
can.Active = false
can.Parent = eback
Corner(0,8,can)

local bottombar = Instance.new("Frame")
bottombar.Name = "BottmBar"
bottombar.ClipsDescendants = true
bottombar.AutomaticSize = Enum.AutomaticSize.X
bottombar.Size = UDim2.new(0,0,0,50)
bottombar.BackgroundColor3 = eback.BackgroundColor3
bottombar.BackgroundTransparency = 0.1
bottombar.BorderMode = eback.BorderMode
bottombar.BorderSizePixel = 5
bottombar.Active = false
bottombar.Parent = eback
Corner(1, 0,bottombar)
ListLayout(bottombar, 0, 5, "HCenter", "VCenter", "SLayout", "FillH")

local icon = Instance.new("ImageLabel")
icon.Name = "Icon"
icon.Size = UDim2.new(0,35,0,35)
icon.Position = UDim2.new(0,0,0,-50)
icon.BackgroundColor3 = eback.BackgroundColor3
icon.BackgroundTransparency = 0.1
icon.Image = "rbxassetid://76063966669126"
icon.Parent = can
Corner(0,8,icon)

local topic = Instance.new("TextLabel")
topic.Name = "Topic"
topic.Size = UDim2.new(0,200,0,35)
topic.Position = UDim2.new(0,40,0,-50)
topic.BackgroundColor3 = eback.BackgroundColor3
topic.BackgroundTransparency = 0.1
topic.Text = "<b>Unknow Page</b>"
topic.TextScaled = true
topic.TextColor3 = Color3.new(1,1,1)
topic.RichText = true
topic.BorderMode = eback.BorderMode
topic.BorderSizePixel = 5
topic.TextXAlignment = Enum.TextXAlignment.Left
topic.Parent = can
Corner(0,8,topic)

topic.Text = "<b>Information</b>"

local incan = Instance.new("Frame")
incan.Name = "InsideCanvas"
incan.ClipsDescendants = true
incan.Size = UDim2.new(1,0,1,0)
incan.BackgroundTransparency = 1
incan.BorderSizePixel = 0
incan.Active = false
incan.Parent = can

local incan2 = Instance.new("Frame")
incan2.Name = "SecondInsideCanvasNoClip"
incan2.Size = UDim2.new(1,0,1,0)
incan2.Position = UDim2.new(0,0,0,0)
incan2.BackgroundTransparency = 1
incan2.BorderSizePixel = 0
incan2.Active = false
incan2.Parent = incan
ListLayout(incan2, 0, 0, "HLeft", "VCenter", "SLayout", "FillH")

local pageButtons = {}

local function addpage(vtopic, vtopic2, image, udim2)
    local Frame = Instance.new("Frame")
    Frame.Name = tostring(vtopic)
    Frame.ClipsDescendants = false
    Frame.Active = false
    Frame.Size = UDim2.new(1,0,1,0)
    Frame.BackgroundTransparency = 1
    Frame.BorderSizePixel = 0
    Frame.Parent = incan2

    local Button = Instance.new("ImageButton")
    Button.Name = tostring(vtopic)
    Button.Size = UDim2.new(0,40,0,40)
    Button.BackgroundColor3 = Color3.new(1,1,1)
    Button.BackgroundTransparency = 1
    Button.Image = "rbxassetid://" .. tonumber(image)
    Button.Parent = bottombar
    Corner(1,0,Button)

    table.insert(pageButtons, Button)

    Button.MouseButton1Click:Connect(function()
        for _, otherButton in ipairs(pageButtons) do
            Tween(otherButton, nil,nil,nil, 1, 0.2)
        end

        Tween(Button, nil,nil,nil, 0.5, 0.2)

        Tween(incan2, nil, udim2, nil,nil, 0.4)
        topic.Text = "<b>" .. tostring(vtopic2) .. "</b>"
        icon.Image = "rbxassetid://".. tonumber(image)
    end)

  return Frame
end

addpage("Test", "Information", 76063966669126, UDim2.new(0,0,0,0))
addpage("Editor", "Editor", 79382593376107, UDim2.new(-1,0,0,0))
addpage("Device", "Device Exeplorer", 77415773465628, UDim2.new(-2,0,0,0))
addpage("Dex", "Dex Exeplorer", 73941302443097, UDim2.new(-3,0,0,0))
addpage("PlayersList", "Learderboard", 133148371698132, UDim2.new(-4,0,0,0))
addpage("ServerList", "ServerList", 124257243656869, UDim2.new(-5,0,0,0))
addpage("Settings", "Settings", 109951202940492, UDim2.new(-6,0,0,0))
addpage("About", "About", 128234289075456, UDim2.new(-7,0,0,0))

local ic2 = {
  Test = incan2.Test,
  Editor = incan2.Editor,
  Device = incan2.Device,
  Dex = incan2.Dex,
  PlayersList = incan2.PlayersList,
  ServerList = incan2.ServerList,
  About = incan2.About,
}

local cs = Instance.new("TextLabel")
cs.Name = "ComingSoon"
cs.Size = UDim2.new(1,0,1,0)
cs.BackgroundTransparency = 1
cs.TextColor3 = Color3.new(1,1,1)
cs.TextScaled = true
cs.Text = "Underdevelopment, will be available soon!"
cs.BorderMode = Enum.BorderMode.Inset
cs.BorderSizePixel = 100
cs.Visible = true
cs.Parent = ic2.Test

-- >> Editor << --

local e_cs = Instance.new("ScrollingFrame")
e_cs.Name = "Console"
e_cs.Size = UDim2.new(0.8,-5,0.2,0)
e_cs.Position = UDim2.new(0.2,5,0.8,0)
e_cs.BorderMode = Enum.BorderMode.Inset
e_cs.BorderSizePixel = 5
e_cs.BackgroundColor3 = Color3.fromRGB(0,0,0)
e_cs.CanvasSize = UDim2.new(0,0,0,0)
e_cs.ScrollBarThickness = 0
e_cs.ScrollingDirection = Enum.ScrollingDirection.Y
e_cs.AutomaticCanvasSize = Enum.AutomaticSize.Y
e_cs.Parent = ic2.Editor
Corner(0,8,e_cs)
ListLayout(e_cs,0,3,"HLeft","VTop","SLayout","FillV")

local LogService = game:GetService("LogService")
local conList = {}
local outputQueue = {}
local processing = false

local MAX_OUTPUTS = 250

local OUTPUT_COLORS = {
    [Enum.MessageType.MessageOutput] = Color3.fromRGB(255, 255, 255),
    [Enum.MessageType.MessageWarning] = Color3.fromRGB(255, 255, 0),
    [Enum.MessageType.MessageError] = Color3.fromRGB(255, 0, 0),
    [Enum.MessageType.MessageInfo] = Color3.fromRGB(0, 255, 255)
}

local function con(output, messageType)
    table.insert(outputQueue, {
        Text = tostring(output),
        Type = messageType
    })

    if processing then
        return
    end

    processing = true

    task.spawn(function()
        while #outputQueue > 0 do
            local item = table.remove(outputQueue, 1)
            local color = OUTPUT_COLORS[item.Type]
                or Color3.fromRGB(255, 255, 255)

            for _, old in ipairs(conList) do
                old.LayoutOrder += 1
            end

            local btn = Instance.new("TextButton")
            btn.Name = "Output"
            btn.AutomaticSize = Enum.AutomaticSize.Y
            btn.Size = UDim2.new(1, 0, 0, 0)
            btn.BackgroundTransparency = 0.6
            btn.BackgroundColor3 = color
            btn.TextColor3 = color
            btn.Text = item.Text
            btn.TextWrapped = true
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.TextYAlignment = Enum.TextYAlignment.Top
            btn.BorderMode = Enum.BorderMode.Inset
            btn.BorderSizePixel = 3
            btn.LayoutOrder = 0
            btn.Parent = e_cs

            Corner(0, 3, btn)

            table.insert(conList, 1, btn)

            if #conList > MAX_OUTPUTS then
                table.remove(conList):Destroy()
            end

            task.wait(0.03)
        end

        processing = false
    end)
end

LogService.MessageOut:Connect(function(message, messageType)
    con(message, messageType)
end)

-- Just testing
con("Hello, World!", Enum.MessageType.MessageOutput)
con("Not done yet, keep waiting for the update lol.", Enum.MessageType.MessageWarning)

local e_sc = Instance.new("ScrollingFrame")
e_sc.Name = "Tabs"
e_sc.Size = UDim2.new(0.2,0,1,0)
e_sc.BorderMode = Enum.BorderMode.Inset
e_sc.BorderSizePixel = 5
e_sc.BackgroundColor3 = Color3.fromRGB(37,37,37)
e_sc.CanvasSize = UDim2.new(0,0,0,0)
e_sc.ScrollBarThickness = 0
e_sc.ScrollingDirection = Enum.ScrollingDirection.Y
e_sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
e_sc.Parent = ic2.Editor
Corner(0,8,e_sc)
ListLayout(e_sc,0,3,"HCenter","VTop","SLayout","FillV")

local selectTab = {}

local function addtab(file)
    local morev = false
    local defaultTitle = "Script.lua"

    local btn = Instance.new("TextButton")
    btn.Name = tostring(file or defaultTitle)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BorderMode = Enum.BorderMode.Inset
    btn.BorderSizePixel = 5
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutomaticSize = Enum.AutomaticSize.Y
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = Color3.fromRGB(79, 79, 79)
    btn.Text = ""
    btn.Parent = e_sc
    Corner(0, 5, btn)

  local options = Instance.new("ScrollingFrame")
  options.Name = "Options"
  options.Size = UDim2.new(1,0,0,0)
  options.Position = UDim2.new(0,0,0,30)
  options.BackgroundColor3 = Color3.fromRGB(131,131,131)
  options.Visible = false
  options.BorderMode = Enum.BorderMode.Inset
  options.BorderSizePixel = 5
  options.CanvasSize = UDim2.new(0,0,0,0)
  options.AutomaticCanvasSize = Enum.AutomaticSize.Y
  options.ScrollingDirection = Enum.ScrollingDirection.Y
  options.ScrollBarThickness = 0
  options.Parent = btn
  Corner(0,5,options)
  ListLayout(options,0,3,"HLeft","VTop","SLayout","FillV")

  local more = Instance.new("TextButton")
  more.Name = "more"
  more.Size = UDim2.new(0,25,0,25)
  more.Position = UDim2.new(1,-25,0,0)
  more.BackgroundColor3 = Color3.fromRGB(121,121,121)
  more.BorderMode = Enum.BorderMode.Inset
  more.BorderSizePixel = 3
  more.TextScaled = true
  more.TextColor3 = Color3.new(1,1,1)
  more.Text = "•••"
  more.Parent = btn
  Corner(0, 3, more)

  more.MouseButton1Click:Connect(function()
    if morev == false then
        morev = true
        options.Visible = true
        more.Text = "✓"
        more.TextColor3 = Color3.new(0,0,0)
        Tween(options, UDim2.new(1,0,0,150),nil,nil,nil, 0.2)
        Tween(more, nil,nil,Color3.new(0,1,0),nil, 0.2)
      else
        morev = false
        more.Text = "•••"
        more.TextColor3 = Color3.new(1,1,1)
        Tween(options, UDim2.new(1,0,0,0),nil,nil,nil, 0.2)
        Tween(more, nil,nil,Color3.fromRGB(121,121,121),nil, 0.2).Completed:Wait()
        options.Visible = false
      end
    end)
    
  local del = Instance.new("TextButton")
  del.Name = "Delete"
  del.Size = UDim2.new(1,0,0,25)
  del.BackgroundColor3 = Color3.fromRGB(63, 0, 0)
  del.BorderMode = Enum.BorderMode.Inset
  del.BorderSizePixel = 3
  del.TextScaled = true
  del.TextColor3 = Color3.new(1,0,0)
  del.Text = "Delete"
  del.Parent = options
  Corner(0, 3, del)

  local dup = Instance.new("TextButton")
  dup.Name = "Duplicate"
  dup.Size = UDim2.new(1,0,0,25)
  dup.BackgroundColor3 = Color3.fromRGB(170, 255, 255)
  dup.BorderMode = Enum.BorderMode.Inset
  dup.BorderSizePixel = 3
  dup.TextScaled = true
  dup.TextColor3 = Color3.fromRGB(0, 85, 255)
  dup.Text = "Duplicate"
  dup.Parent = options
  Corner(0, 3, dup)

  local exe = Instance.new("TextButton")
  exe.Name = "Execute"
  exe.Size = UDim2.new(1,0,0,25)
  exe.BackgroundColor3 = Color3.fromRGB(85, 255, 127)
  exe.BorderMode = Enum.BorderMode.Inset
  exe.BorderSizePixel = 3
  exe.TextScaled = true
  exe.TextColor3 = Color3.fromRGB(0,170,0)
  exe.Text = "Execute"
  exe.Parent = options
  Corner(0, 3, exe)

  local cop = Instance.new("TextButton")
  cop.Name = "Copy"
  cop.Size = UDim2.new(1,0,0,25)
  cop.BackgroundColor3 = Color3.fromRGB(255, 255, 127)
  cop.BorderMode = Enum.BorderMode.Inset
  cop.BorderSizePixel = 3
  cop.TextScaled = true
  cop.TextColor3 = Color3.fromRGB(255, 170, 0)
  cop.Text = "Copy"
  cop.Parent = options
  Corner(0, 3, cop)

  local loc = Instance.new("TextButton")
  loc.Name = "LockEditable"
  loc.Size = UDim2.new(1,0,0,25)
  loc.BackgroundColor3 = Color3.fromRGB(0,0,0)
  loc.BorderMode = Enum.BorderMode.Inset
  loc.BorderSizePixel = 3
  loc.TextScaled = true
  loc.TextColor3 = Color3.fromRGB(0,255,0) -- unlock = lime; lock = red
  loc.Text = "Lock Editable" -- unlock = "Lock Editable"; lock = "Unlock Editable"
  loc.Parent = options
  Corner(0, 3, loc)

  local bac = Instance.new("TextBox")
  bac.Name = "BackgroundColor3"
  bac.Size = UDim2.new(1,0,0,25)
  bac.BackgroundColor3 = Color3.fromRGB(0,0,0)
  bac.BackgroundTransparency = 0.8
  bac.BorderMode = Enum.BorderMode.Inset
  bac.BorderSizePixel = 3
  bac.TextScaled = true
  bac.TextColor3 = Color3.fromRGB(79,79,79)
  bac.Text = "79,79,79"
  bac.PlaceholderText = "BackgroundColor3: 79,79,79"
  bac.ClearTextOnFocus = true
  bac.Parent = options
  Corner(0, 3, bac)

  local tc3 = Instance.new("TextBox")
  tc3.Name = "TextColor3"
  tc3.Size = UDim2.new(1,0,0,25)
  tc3.BackgroundColor3 = Color3.fromRGB(0,0,0)
  tc3.BackgroundTransparency = 0.8
  tc3.BorderMode = Enum.BorderMode.Inset
  tc3.BorderSizePixel = 3
  tc3.TextScaled = true
  tc3.TextColor3 = Color3.fromRGB(255,255,255)
  tc3.Text = "255,255,255"
  tc3.PlaceholderText = "TextColor3: 255,255,255"
  tc3.ClearTextOnFocus = true
  tc3.Parent = options
  Corner(0, 3, tc3)

  local sid = Instance.new("TextLabel")
  sid.Name = "ScriptID"
  sid.Size = UDim2.new(1,0,0,25)
  sid.BackgroundColor3 = Color3.fromRGB(255,255,255)
  sid.BorderMode = Enum.BorderMode.Inset
  sid.BorderSizePixel = 3
  sid.TextScaled = true
  sid.TextColor3 = Color3.fromRGB(0,0, 0)
  sid.Text = "ScriptID: 0"
  sid.Parent = options
  Corner(0, 3, sid)
  
    local title = Instance.new("TextBox")
    title.Name = "Title"
    title.Size = UDim2.new(1, -28, 0, 25)
    title.BorderMode = Enum.BorderMode.Inset
    title.BorderSizePixel = 3
    title.BackgroundTransparency = 1
    title.Active = false
    title.TextEditable = false
    title.ClearTextOnFocus = false
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.TextSize = 24
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = tostring(file or defaultTitle)
    title.PlaceholderText = defaultTitle
    title.PlaceholderColor3 = Color3.new(1, 1, 1)
    title.Parent = btn

    table.insert(selectTab, btn)

    local lastClick = 0
    local originalTitle = title.Text
    local editing = false
    local destroyed = false

    local function finishEditing(cancel)
        if not editing then
            return
        end

        if cancel then
            title.Text = originalTitle
        elseif title.Text:match("^%s*$") then
            title.Text = defaultTitle
        end

        btn.Name = title.Text
        title.TextEditable = false
        title.Active = false
        editing = false
    end

    local function beginEditing()
        if destroyed or editing then
            return
        end

        originalTitle = title.Text
        editing = true
        title.TextEditable = true
        title.Active = true
        title:CaptureFocus()
    end

    btn.Activated:Connect(function()
        for _, otherbtn in ipairs(selectTab) do
            Tween(
                otherbtn,
                nil,
                nil,
                Color3.fromRGB(79, 79, 79),
                nil,
                0.2
            )

            if otherbtn ~= btn then
                local otherTitle = otherbtn:FindFirstChild("Title")

                if otherTitle and otherTitle.TextEditable then
                    if otherTitle.Text:match("^%s*$") then
                        otherTitle.Text = defaultTitle
                    end

                    otherTitle.TextEditable = false
                    otherTitle.Active = false
                end
            end
        end

        Tween(
            btn,
            nil,
            nil,
            Color3.fromRGB(150, 150, 150),
            nil,
            0.2
        )
    end)

    title.InputBegan:Connect(function(input)
        if destroyed or editing then
            return
        end

        local inputType = input.UserInputType

        if inputType ~= Enum.UserInputType.MouseButton1
            and inputType ~= Enum.UserInputType.Touch then
            return
        end

        local now = os.clock()

        if now - lastClick <= 1 then
            lastClick = 0
            beginEditing()
        else
            lastClick = now
        end
    end)

    title.FocusLost:Connect(function(enterPressed)
        if not editing then
            return
        end

        if enterPressed then
            finishEditing(false)
        else
            finishEditing(false)
        end
    end)

    s.UserInputService.InputBegan:Connect(function(input)
        if destroyed or not editing then
            return
        end

        if input.KeyCode == Enum.KeyCode.Escape then
            finishEditing(true)
        end
    end)

    del.Activated:Connect(function()
        if destroyed then
            return
        end

        destroyed = true

        if editing then
            editing = false
            title.TextEditable = false
            title.Active = false
        end

        for i, tab in ipairs(selectTab) do
            if tab == btn then
                table.remove(selectTab, i)
                break
            end
        end

        btn:Destroy()
    end)
end

local add = Instance.new("TextButton")
add.Name = "add"
add.Size = UDim2.new(0,35,0,35)
add.BorderMode = Enum.BorderMode.Inset
add.BorderSizePixel = 5
add.TextXAlignment = Enum.TextXAlignment.Center
add.AutomaticSize = Enum.AutomaticSize.None
add.TextColor3 = Color3.new(1,1,1)
add.BackgroundColor3 = Color3.fromRGB(79,79,79)
add.TextScaled = true
add.Text = "+"
add.LayoutOrder = 2147483647
add.Parent = e_sc
Corner(0,5,add)

add.MouseButton1Click:Connect(function()
  addtab()
end)

ding("Hello, World!", 5, 0,255,255)
task.wait(1)
ding("Load successful :)", 5, 0,255,0)
task.wait(1)
ding([[ExperienceSettings (Beta); Notification from <b>Editor</b> &lt;3
  ———————————————————————————
  Version ExperienceSettings: <b>0.821.1.4-Beta</b>
  Version Editor: <b>]].. v_ver .."</b>", 8, 255,255,0)
