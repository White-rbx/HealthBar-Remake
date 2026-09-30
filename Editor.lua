local v_ver = [[Editor 0.3 Test]]
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

local topic = Instance.new("TextLabel")
topic.Name = "Topic"
topic.Size = UDim2.new(0,200,0,35)
topic.Position = UDim2.new(0,0,0,-50)
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
    end)

  return Frame
end

addpage("Test", "Information", 76063966669126, UDim2.new(0,0,0,0))
addpage("Editor", "Editor", 79382593376107, UDim2.new(-1,0,0,0))
addpage("Device", "Device Exeplorer", 77415773465628, UDim2.new(-1,0,0,0))
addpage("Dex", "Dex Exeplorer", 73941302443097, UDim2.new(-2,0,0,0))
addpage("PlayersList", "Learderboard", 133148371698132, UDim2.new(-4,0,0,0))
addpage("ServerList", "ServerList", 124257243656869, UDim2.new(-5,0,0,0))
addpage("About", "About", 128234289075456, UDim2.new(-6,0,0,0))

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
