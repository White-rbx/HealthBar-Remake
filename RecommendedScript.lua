local v_ver = [[Recommanded Script 1.0 Remakes]]
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

local tb = s.CoreGui:WaitForChild("ExperienceSettings"):WaitForChild("Menu"):WaitForChild("TopBar"):WaitForChild("TopButtons")
---------------------------------------------------------------------------------------

local function add(title, des, raw, r, g, b)

local Raw = raw or ""
  
local Body = Instance.new("Frame")
Body.Active = false
Body.BackgroundColor3 = Color3.fromRGB(r or 95, g or 94, b or 96)
Body.BorderSizePixel = 5
Body.BorderMode = Enum.BorderMode.Inset
Body.Size = UDim2.new(1, 0, 0, 75)
Body.Name = "Script"
Body.Parent = tb
Corner(0,5,Body)

local Des = Instance.new("TextLabel")
Des.Active = false
Des.Text = des or "This is the script's description, if you see like this I didn't put description yet lol."
Des.TextColor3 = Color3.new(1, 1, 1)
Des.TextWrapped = true
Des.Active = true
Des.BackgroundColor3 = Color3.new(0, 0, 0)
Des.BackgroundTransparency = 0.800000011920929
Des.BorderSizePixel = 2
Des.BorderMode = Enum.BorderMode.Inset
Des.TextXAlignment = Enum.TextXAlignment.Left
Des.TextYAlignment = Enum.TextYAlignment.Top
Des.Position = UDim2.new(0, 0, 0, 20)
Des.Size = UDim2.new(0.699999988079071, 0, 0, 45)
Des.Name = "Description"
Des.Parent = Body
Corner(0,3,Des)

local Title = Instance.new("TextLabel")
Title.Active = false
Title.Text = title or "Script Title"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.TextWrapped = true
Title.Active = true
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextYAlignment = Enum.TextYAlignment.Top
Title.Size = UDim2.new(0.699999988079071, 0, 0, 20)
Title.Name = "Title"
Title.Parent = Body

-- Creating TextButton
local Exe = Instance.new("TextButton")
Exe.Text = "Execute"
Exe.TextColor3 = Color3.new(0, 0, 0)
Exe.BorderSizePixel = 5
Exe.BorderMode = Enum.BorderMode.Inset
Exe.TextScaled = true
Exe.BackgroundColor3 = Color3.new(0, 1, 0)
Exe.Position = UDim2.new(0.7, 5, 0, 0)
Exe.Size = UDim2.new(0.30000001192092896, -5, 0, 30)
Exe.Name = "Execute"
Exe.Parent = Body
Corner(0,5, Exe)

local Copy = Instance.new("TextButton")
Copy.Text = "Copy"
Copy.TextColor3 = Color3.new(0, 0, 0)
Copy.BorderSizePixel = 5
Copy.BorderMode = Enum.BorderMode.Inset
Copy.TextScaled = true
Copy.BackgroundColor3 = Color3.new(0.7477386593818665, 0.7477386593818665, 0.7477386593818665)
Copy.Position = UDim2.new(0.7, 5, 1, -30)
Copy.Size = UDim2.new(0.30000001192092896, -5, 0, 30)
Copy.Name = "Copy"
Copy.Parent = Body
Corner(0,5,Copy)

Exe.MouseButton1Click:Connect(function()
  if Raw and Raw ~= "" then
    if loadstring then
        loadstring(Raw)()
        Exe.Text = "Executed"
    else
        Exe.Text = "Failed to executed"
    end
  else
      Exe.Text = "Raw is empty"
  end
  wait(1)

  Exe.Text = "Execute"
end)

Copy.MouseButton1Click:Connect(function()
  if Raw and Raw ~= "" then
    if setclipboard then
        setclipboard(Raw)
        Copy.Text = "Copied"
    else
        Copy.Text = "Clipboard unsupported"
    end
  else
      Copy.Text = "Raw is empty"
  end
  wait(1)

  Copy.Text = "Copy"
end)
end

add("Infinite yield (@edge.egg | discord)", "The most powerful admin commands.", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
add("Delta Keyboard (@sakura)", "A keyboard for mobile. Crack by Ata", "https://raw.githubusercontent.com/Xxtan31/Ata/main/deltakeyboardcrack.txt")
add("Dex++ (@mcdaggitt)", "Not my script but Ill actively update it with new features. Includes optimization + rspy plugin!", "https://raw.githubusercontent.com/jodta/my-scripts/refs/heads/main/Dex%2B%2B/Decompiler%20Fix.lua")
add("RoChip (@Allskill)", "Universal script allows you to tp to players, also lets you fling them and many more.", "https://rawscripts.net/raw/Universal-Script-rochips-universal-18294")
add("ConsoleCopyButton (@Lordi_scripts)", "lets you copy everything right in the native console interface (/console OR F9)", "https://rawscripts.net/raw/Universal-Script-ConsoleCopyButton-60768")
