-- Loader script 7.38

--[[ UI_functions version: 2.3 ( Reduced Locals for more less risk to due Out Of Local ) ]]

-- Shared function/state table.
local loc = {}

------------------------------------------------------------------------------------------

-- =====>> UI Instance Helpers (standalone functions) <<=====
-- ====FUNCTION CORNER===== Example: Corner(Scale, Offset, Parent)
local function Corner(Scale, Offset, Parent)
  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(Scale or 0, Offset or 0)
  corner.Parent = Parent
  return corner
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
local function Aspect(parent, ratio, aspectType, dominantAxis)
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
 Camera = game:GetService("Workspace").CurrentCamera,

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
 LocalizationService = game:GetService("LocalizationService"),

-- Animation / Transitions
 TweenService = game:GetService("TweenService"),
 ContentProvider = game:GetService("ContentProvider"),

-- Input (Desktop / Mobile)
 UserInputService = game:GetService("UserInputService"),
 TouchInputService = game:GetService("TouchInputService"),

}

-- Shared loc table was initialized near the top of this file.

local tweenStyle = {
    Linear = Enum.EasingStyle.Linear,
    Sine = Enum.EasingStyle.Sine,
    Back = Enum.EasingStyle.Back,
    Quad = Enum.EasingStyle.Quad,
    Quart = Enum.EasingStyle.Quart,
    Quint = Enum.EasingStyle.Quint,
    Bounce = Enum.EasingStyle.Bounce,
    Elastic = Enum.EasingStyle.Elastic,
    Exponential = Enum.EasingStyle.Exponential,
    Circular = Enum.EasingStyle.Circular,
    Cubic = Enum.EasingStyle.Cubic
}

local function Tween(obj, propertie, time, style)
    local properties = propertie or {}

    local selectedStyle = tweenStyle[style] or style or Enum.EasingStyle.Quad

    local tweenInfo = TweenInfo.new(
        time or 0.5,
        selectedStyle,
        Enum.EasingDirection.Out
    )

    local tween = s.TweenService:Create(obj, tweenInfo, properties)
    tween:Play()
    return tween
end

---------------------------------------------------------------------------------------



-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "LoaderSettings"
gui.DisplayOrder = 2147483646
-- gui.ScreenInsets = Enum.ScreenInsets.None
gui.Parent = s.CoreGui

local hr = Instance.new("Frame")
hr.Name = "Holder"
hr.Size = UDim2.new(0.3,0,1,0)
hr.BackgroundColor3 = Color3.fromRGB(18,18,21)
hr.Position = UDim2.new(-0.3,0,0,0)
hr.BackgroundTransparency = 0.08
hr.Active = false
hr.BorderSizePixel = 0
hr.Parent = gui
Corner(0,8,hr)

local oc = Instance.new("ImageButton")
oc.Name = "Open/Close"
oc.Size = UDim2.new(0,40,0,40)
oc.Position = UDim2.new(1,5,0,0)
oc.BackgroundColor3 = Color3.fromRGB(18,18,21)
oc.BackgroundTransparency = 0.08
oc.ScaleType = Enum.ScaleType.Fit
oc.Image = "rbxassetid://132003718727838"
oc.Parent = hr
Corner(1,0,oc)

local h_si = Instance.new("Frame")
h_si.Name = "Inside"
h_si.Size = UDim2.new(1,0,1,0)
h_si.Position = UDim2.new(0,0,0,0)
h_si.BackgroundTransparency = 1
h_si.Active = false
h_si.BorderMode = Enum.BorderMode.Inset
h_si.BorderSizePixel = 10
h_si.Parent = hr

local topic = Instance.new("TextLabel")
topic.Name = "Topic"
topic.Size = UDim2.new(1,0,0,50)
topic.BackgroundColor3 = Color3.fromRGB(0,85,255)
topic.RichText = true
topic.TextScaled = true
topic.BorderMode = Enum.BorderMode.Inset
topic.BorderSizePixel = 13
topic.Text = "<b>Settings - Loader Rejoiner</b>"
topic.TextColor3 = Color3.new(1,1,1)
topic.Parent = h_si
Corner(0,8,topic)

local scr = Instance.new("ScrollingFrame")
scr.Name = "Settings"
scr.Size = UDim2.new(1,0,1,-55)
scr.Position = UDim2.new(0,0,0,55)
scr.BackgroundTransparency = 1
scr.BorderMode = Enum.BorderMode.Inset
scr.BorderSizePixel = 5
scr.AutomaticCanvasSize = Enum.AutomaticSize.Y
scr.ScrollingDirection = Enum.ScrollingDirection.Y
scr.ScrollBarThickness = 0
scr.CanvasSize = UDim2.new(0,0,0,0)
scr.Parent = h_si
Corner(0,8,scr)
ListLayout(scr, 0, 5, "HCenter","VTop","SLayout","FillV")

local ocstate = false
oc.MouseButton1Click:Connect(function()
  if ocstate == false then
    ocstate = true
    oc.Image = "rbxassetid://111119256032094"
    Tween(hr, {Position = UDim2.new(0,0,0,0)}, 0.4)
    Tween(oc, {Position = UDim2.new(1,5,0.5,-50),Size = UDim2.new(0.1,-10,0,100)}, 0.4)
  else
    ocstate = false
    oc.Image = "rbxassetid://132003718727838"
    Tween(hr, {Position = UDim2.new(-0.3,0,0,0)}, 0.4)
    Tween(oc, {Position = UDim2.new(1,5,0,0),Size = UDim2.new(0,40,0,40)}, 0.4)
  end
end)

--// =====================================================
--// SERVICES
--// =====================================================

-- HttpService uses the shared s.HttpService service reference.

--// =====================================================
--// SAVE PATH
--// =====================================================

local ROOT_FOLDER = "ExperienceSettings"
local SAVE_FILE   = ROOT_FOLDER .. "/config.json"

--// =====================================================
--// FILE UTILS (EXECUTOR ONLY)
--// =====================================================

loc.ensureFolder = function()
    if not isfolder(ROOT_FOLDER) then
        makefolder(ROOT_FOLDER)
    end
end

--// =====================================================
--// DEFAULT DATA
--// =====================================================

local DEFAULT_DATA = {
    Version = 1,

    Loader = {
        AlwaysLoad = false
    },

    UI = {
        BackgroundRGB = { 18, 18, 21 },
        BackgroundRGBCustom = false,
        Theme = "Default",
        ThemeImage = "",
        ThemeGradient1 = { 255, 255, 255 },
        ThemeGradient2 = { 255, 255, 255 },
        ThemeGradientRotation = 90,
        MenuBackgroundTransparency = 0.08, -- Compatibility mirror of the active Theme value.
        MenuBackgroundTransparencyDefault = 0.08,
        MenuBackgroundTransparencyImage = 0.1,
        ThemeTileSize = 64,
        HideMenu = false,
        SettingsTransparency = 0.3,
        UIScale = 1,
        DraggableUI = false,
        CrosshairID = "rbxassetid://118624373632520",
        ToolCrosshairID = "rbxassetid://73868291781876",
		ScreenInsets = "DeviceSafeInsets",
		DisplayOrder = math.huge
    }
}

--// =====================================================
--// DEEP MERGE (เติมค่า default ที่หายไป)
--// =====================================================

loc.deepMerge = function(data, defaults)
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            data[k] = type(data[k]) == "table" and data[k] or {}
            loc.deepMerge(data[k], v)
        elseif data[k] == nil then
            data[k] = v
        end
    end
end

--// =====================================================
--// SAVE DATA  <<<<<< สำคัญ (ตัวนี้ที่เคย NIL)
--// =====================================================

loc.saveData = function(data)
    loc.ensureFolder()

    local ok, encoded = pcall(function()
        return s.HttpService:JSONEncode(data)
    end)

    if ok then
        writefile(SAVE_FILE, encoded)
        return true
    end

    return false
end

--// =====================================================
--// LOAD DATA
--// =====================================================

loc.loadData = function()
    loc.ensureFolder()

    local data = {}

    if isfile(SAVE_FILE) then
        local ok, decoded = pcall(function()
            return s.HttpService:JSONDecode(readfile(SAVE_FILE))
        end)

        if ok and type(decoded) == "table" then
            data = decoded
        end
    end

    -- Preserve the old single transparency value when migrating to per-theme values.
    loc.LegacyThemeForTransparency = type(data.UI) == "table" and tostring(data.UI.Theme or "Default") or "Default"
    if loc.LegacyThemeForTransparency ~= "Default" and loc.LegacyThemeForTransparency ~= "Anniversary"
        and loc.LegacyThemeForTransparency ~= "Halloween" and loc.LegacyThemeForTransparency ~= "Custom" then
        loc.LegacyThemeForTransparency = "Default"
    end
    loc.LegacyTransparencyValue = type(data.UI) == "table"
        and tonumber(data.UI.MenuBackgroundTransparency) or nil
    loc.HadDefaultTransparency = type(data.UI) == "table" and data.UI.MenuBackgroundTransparencyDefault ~= nil
    loc.HadImageTransparency = type(data.UI) == "table" and data.UI.MenuBackgroundTransparencyImage ~= nil

    -- เติม default ที่ขาด
    loc.deepMerge(data, DEFAULT_DATA)

    if not loc.HadDefaultTransparency then
        data.UI.MenuBackgroundTransparencyDefault = loc.LegacyThemeForTransparency == "Default"
            and math.clamp(loc.LegacyTransparencyValue or 0.08, 0, 1)
            or 0.08
    end
    if not loc.HadImageTransparency then
        data.UI.MenuBackgroundTransparencyImage = loc.LegacyThemeForTransparency ~= "Default"
            and math.clamp(loc.LegacyTransparencyValue or 0.1, 0.1, 1)
            or 0.1
    end
    if data.UI.Theme == "Default" then
        data.UI.MenuBackgroundTransparency = data.UI.MenuBackgroundTransparencyDefault
    else
        data.UI.MenuBackgroundTransparency = data.UI.MenuBackgroundTransparencyImage
    end

    -- save กลับทันที (กัน key หาย)
    loc.saveData(data)

    return data
end

--// =====================================================

--// =====================================================
--// UI HELPER
--// =====================================================

loc.updateToggle = function(btn, status)
    btn.Text = status and "ON" or "OFF"
    btn.TextColor3 = status
        and Color3.fromRGB(0,255,0)
        or Color3.fromRGB(255,0,0)
end

--// =====================================================
--// TXT FUNCTION (FIXED)
--// =====================================================

-- Legacy Txt builder removed; all UI rows use loc.o().


-- New
loc.o = function(a, b, c, d, e, f, g, h, i, j, k, l)
    -- New API:
    -- o(parent, fill, option_, isrt, isb, nbtnText, isselect, isi, tih,
    --   scriptFN, callback, selectedText)
    -- When isselect and isb are both true, the row gets:
    -- [Select dropdown] [nbtn/action button].
    -- Legacy API remains supported below.
    local modern = typeof(a) == "Instance"
    local parent, fill, option_, isrt, isb, tb, isselect, isi, tih, scriptFN, callback
    local status, livePreview, labelColor, selectedText

    if modern then
        parent, fill, option_, isrt, isb, tb, isselect, isi, tih, scriptFN, callback, selectedText =
            a, b, c, d, e, f, g, h, i, j, k, l
        labelColor = Color3.new(1, 1, 1)
    else
        option_ = a
        labelColor = Color3.fromRGB(b or 255, c or 255, d or 255)
        isi, tih, isb, tb = e == true, f, g == true, h
        livePreview, callback, status, parent = i, j, k, l
        fill = nil
        isrt = false
        isselect = false
    end

    local rowParent = typeof(parent) == "Instance" and parent or scr or h_si
    local autoSize = Enum.AutomaticSize.None
    if type(fill) == "string" then
        autoSize = Enum.AutomaticSize[fill] or Enum.AutomaticSize.None
    end

    local hasSelect = isselect == true
    local hasButton = isb == true -- nbtn/action button; not the dropdown trigger
    local hasInput = isi == true
    local reserve = (hasSelect and hasButton) and 205
        or ((hasSelect or hasButton or hasInput) and 105 or 0)

    local frame = Instance.new("Frame")
    frame.Name = "Body"
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.AutomaticSize = autoSize
    frame.BorderMode = Enum.BorderMode.Inset
    frame.BorderSizePixel = 1
    frame.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
    frame.BackgroundTransparency = 0.45
    frame.Active = false
    frame.ClipsDescendants = false
    frame.Parent = rowParent
    Corner(0, 5, frame)

    local label = Instance.new("TextLabel")
    label.Name = "Name"
    label.Size = UDim2.new(1, -reserve, 1, 0)
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.RichText = isrt == true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = labelColor
    label.Text = tostring(option_ or "Unknown")
    label.Parent = frame

    local button
    if hasButton then
        button = Instance.new("TextButton")
        button.Name = "Button" -- nbtn
        button.Size = UDim2.new(0, hasSelect and 82 or 100, 0, 24)
        button.Position = UDim2.new(1, hasSelect and -82 or -102, 0, 3)
        button.BackgroundColor3 = Color3.fromRGB(55, 62, 76)
        button.BackgroundTransparency = 0.12
        button.TextScaled = true
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Text = tostring(tb or "OK")
        button.Visible = true
        button.ClipsDescendants = false
        button.Parent = frame
        Corner(0, 4, button)
    end

    local selectButton
    if hasSelect then
        selectButton = Instance.new("TextButton")
        selectButton.Name = "SelectButton"
        selectButton.Size = UDim2.new(0, hasButton and 110 or 100, 0, 24)
        selectButton.Position = UDim2.new(1, hasButton and -198 or -102, 0, 3)
        selectButton.BackgroundColor3 = Color3.fromRGB(55, 62, 76)
        selectButton.BackgroundTransparency = 0.12
        selectButton.TextScaled = true
        selectButton.TextColor3 = Color3.new(1, 1, 1)
        selectButton.Text = tostring(selectedText or (hasButton and "Select" or tb) or "Select")
        selectButton.Visible = true
        selectButton.ClipsDescendants = false
        selectButton.Parent = frame
        Corner(0, 4, selectButton)
    end

    local input
    if hasInput then
        input = Instance.new("TextBox")
        input.Name = "Input"
        input.Size = UDim2.new(0, 100, 0, 24)
        input.Position = UDim2.new(1, -102, 0, 3)
        input.BackgroundColor3 = Color3.fromRGB(42, 45, 53)
        input.BackgroundTransparency = 0.1
        input.TextSize = 16
        input.TextColor3 = Color3.new(1, 1, 1)
        input.PlaceholderColor3 = Color3.fromRGB(175, 180, 190)
        input.TextScaled = true
        input.Text = ""
        input.ClearTextOnFocus = false
        input.PlaceholderText = tostring(tih or "Input")
        input.Visible = true
        input.Parent = frame
        Corner(0, 4, input)
    end

    -- Compact legacy proportions; modern controls use fixed-width fields.
    if not modern then
        if hasButton and hasInput then
            label.Size = UDim2.new(1/3, 0, 1, 0)
            input.Size = UDim2.new(1/3, -2, 0, 24)
            input.Position = UDim2.new(0.343, 0, 0, 3)
            button.Size = UDim2.new(1/3, -2, 0, 24)
            button.Position = UDim2.new(0.696, 0, 0, 3)
        elseif hasInput then
            label.Size = UDim2.new(0.4, 0, 1, 0)
            input.Size = UDim2.new(0.49, 0, 0, 24)
            input.Position = UDim2.new(0.41, 0, 0, 3)
        elseif hasButton then
            label.Size = UDim2.new(0.58, 0, 1, 0)
            button.Size = UDim2.new(0.4, 0, 0, 24)
            button.Position = UDim2.new(0.59, 0, 0, 3)
        end
    elseif hasButton and hasInput and not hasSelect then
        input.Position = UDim2.new(1, -207, 0, 3)
    end

    local selectFrame
    local ui = {
        Parent = rowParent,
        Frame = frame,
        Label = label,
        Button = button, -- compatibility alias for the nbtn
        NButton = button,
        SelectButton = selectButton,
        Input = input,
        Box = input,
        Select = nil,
        SelectOptions = {},
        SelectedValue = selectedText or (hasSelect and not hasButton and tb or nil),
    }

    if hasSelect then
        selectFrame = Instance.new("ScrollingFrame")
        selectFrame.Name = "Select"
        selectFrame.Size = UDim2.new(0, 200, 0, 220)
        selectFrame.Position = UDim2.new(0, hasButton and -90 or -100, 0, 27)
        selectFrame.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
        selectFrame.BackgroundTransparency = 0
        selectFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        selectFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        selectFrame.ScrollingDirection = Enum.ScrollingDirection.Y
        selectFrame.ScrollBarThickness = 3
        selectFrame.BorderMode = Enum.BorderMode.Inset
        selectFrame.BorderSizePixel = 1
        selectFrame.Visible = false
        selectFrame.ClipsDescendants = true
        selectFrame.Parent = selectButton
        selectFrame.ZIndex = 5
        Corner(0, 4, selectFrame)
        ListLayout(selectFrame, 0, 3, "HLeft", "VTop", "SLayout", "FillV")
        ui.Select = selectFrame
    end

    local function setOptionDisabled(optionButton, disabled)
        if not optionButton then return end
        disabled = disabled == true
        optionButton:SetAttribute("Disabled", disabled)
        optionButton.Active = not disabled
        optionButton.Selectable = not disabled
        optionButton.AutoButtonColor = not disabled
        optionButton.TextColor3 = disabled
            and Color3.fromRGB(115, 120, 130)
            or Color3.new(1, 1, 1)
        optionButton.BackgroundTransparency = disabled and 0.65 or 0.35
    end

    local function addSelect(child, disabled)
        if not selectFrame then return nil end
        local value = tostring(child or "UnknownChild")
        local optionButton = Instance.new("TextButton")
        optionButton.Name = value
        optionButton.Size = UDim2.new(1, 0, 0, 24)
        optionButton.BackgroundTransparency = 0.35
        optionButton.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
        optionButton.TextScaled = true
        optionButton.TextColor3 = Color3.new(1, 1, 1)
        optionButton.Text = value
        optionButton.Parent = selectFrame
        optionButton.ZIndex = 6
        Corner(0, 3, optionButton)
        setOptionDisabled(optionButton, disabled)
        ui.SelectOptions[value] = optionButton

        optionButton.MouseButton1Click:Connect(function()
            if optionButton:GetAttribute("Disabled") then return end
            ui.SelectedValue = value
            selectButton.Text = value
            selectFrame.Visible = false
            if type(callback) == "function" then
                callback(value, "select", ui)
            end
        end)
        return optionButton
    end

    ui.AddSelect = addSelect
    ui.SetOptionDisabled = setOptionDisabled

    if selectButton then
        selectButton.MouseButton1Click:Connect(function()
            if selectButton.Active then
                selectFrame.Visible = not selectFrame.Visible
            end
        end)
    end

    if button then
        if status ~= nil then
            loc.updateToggle(button, status)
        end
        button.MouseButton1Click:Connect(function()
            if not button.Active then return end
            if not modern and status ~= nil then
                status = not status
                loc.updateToggle(button, status)
                if type(livePreview) == "function" then livePreview(status) end
                if type(callback) == "function" then callback(status) end
            elseif type(callback) == "function" then
                if modern then
                    callback(hasSelect and ui.SelectedValue or button.Text, "button", ui)
                else
                    callback(input, button, ui)
                end
            end
        end)
    end

    if input then
        if not modern and type(livePreview) == "function" then
            input:GetPropertyChangedSignal("Text"):Connect(function()
                livePreview(input)
            end)
        elseif modern then
            input.FocusLost:Connect(function(enterPressed)
                if type(callback) == "function" then
                    callback(input.Text, "input", ui, enterPressed)
                end
            end)
        end
    end

    if modern and type(scriptFN) == "function" then
        scriptFN(ui)
    end

    return ui
end

-- New API: loc.o(parent, fill, option_, isrt, isb, nbtnText, isselect, isi, tih, scriptFN, callback, selectedText)
-- Legacy UI callsites are also routed through loc.o until they are migrated.

--// =====================================================
--// USAGE
--// =====================================================

-- =====================================================
-- LOAD DATA
-- =====================================================
local Data = loc.loadData()

-- CoreGui uses the shared s.CoreGui service reference.

local MENU_INSTANCE = nil
local HIDE_MENU_STATUS = Data.UI.HideMenu -- อ่านจาก json ครั้งเดียว

loc.applyHideMenu = function()
    if MENU_INSTANCE then
        MENU_INSTANCE.Enabled = not HIDE_MENU_STATUS
    end
end

-- 🔎 หา Menu (ใช้ชื่อ + parent เท่านั้น)
loc.isTargetMenu = function(inst)
    return inst:IsA("ScreenGui")
        and inst.Name == "Menu"
        and inst.Parent
        and inst.Parent.Name == "ExperienceSettings"
end

-- 1️⃣ เช็คของที่มีอยู่แล้ว
for _, inst in ipairs(s.CoreGui:GetDescendants()) do
    if loc.isTargetMenu(inst) then
        MENU_INSTANCE = inst
        loc.applyHideMenu() -- ✅ apply ตาม json ทันที
        break
    end
end

-- 2️⃣ รอของที่โผล่มาทีหลัง
s.CoreGui.DescendantAdded:Connect(function(inst)
    if MENU_INSTANCE then return end

    if loc.isTargetMenu(inst) then
        MENU_INSTANCE = inst
        loc.applyHideMenu() -- ✅ apply ตาม json ทันที
    end
end)

local CONTINUE_LOCK = true

-- Always Load → skip lock
if Data.Loader.AlwaysLoad == true then
    CONTINUE_LOCK = false
end
------------------------------------------------------------

-- Continue (ONE TIME)
local continueUI = loc.o(
    "Continue loadstring main ExperienceSettings",
    255,255,255,
    false, nil,
    true, "Get Load",
    nil,
    function(box, btn)

        -- safety check
        local player = s.Players.LocalPlayer
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        local healthEnabled = s.StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Health)

        if not hrp or not healthEnabled then
            -- temporary warning
            local oldText = btn.Text
            local oldColor = btn.TextColor3

            btn.Text = "Cannot Load"
            btn.TextColor3 = Color3.fromRGB(255,255,0)

            task.delay(1, function()
                if btn and btn.Parent and CONTINUE_LOCK then
                    btn.Text = oldText
                    btn.TextColor3 = oldColor
                end
            end)

            return
        end

        -- passed check → load
        CONTINUE_LOCK = false
        btn.Text = "Loaded"
    end
)

local btn = continueUI.Button

-- sync text if already unlocked (Always Load case)
if not CONTINUE_LOCK then
    btn.Text = "Loaded"
end

-- color loop watcher
task.spawn(function()
    local toggle = false

    while btn and btn.Parent do
        if not CONTINUE_LOCK then
            toggle = not toggle

            local color = toggle
                and Color3.fromRGB(0,255,0)
                or Color3.fromRGB(255,255,255)

            local tween = s.TweenService:Create(
                btn,
                TweenInfo.new(0.3, Enum.EasingStyle.Linear),
                { TextColor3 = color }
            )
            tween:Play()

            task.wait(0.35)
        else
            task.wait(0.2)
        end
    end
end)

-- Always Load (SAVE) ------------------------------
local alwaysUI = loc.o(  
    "Always Load main ExperienceSettings",  
    255,255,255,  
    false, nil,  
    true, nil,  
    function(newStatus)  
        Data.Loader.AlwaysLoad = newStatus  
        loc.saveData(Data)  
    end,  
    nil,  
    Data.Loader.AlwaysLoad,
    scr
) 

local continueBtn = continueUI.Button
local alwaysBtn = alwaysUI.Button

-- function ตรวจสถานะโหลดได้หรือไม่
loc.canLoad = function()
    local player = s.Players.LocalPlayer
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    local healthOn = false
    pcall(function()
        healthOn = s.StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Health)
    end)

    return hrp and healthOn
end

-- bypass warning watcher
task.spawn(function()
    while continueBtn and continueBtn.Parent do
        local alwaysOn = alwaysBtn.Text == "ON"
        local ok = loc.canLoad()

        if alwaysOn and not ok then
            -- show warning
            continueBtn.Text = "Bypass detected: Toggle is ON"
            continueBtn.TextColor3 = Color3.fromRGB(255,255,0)

            CONTINUE_LOCK = true
        else
            -- revert to normal state
            if not CONTINUE_LOCK then
                continueBtn.Text = "Loaded"
                continueBtn.TextColor3 = Color3.fromRGB(255,255,255)
            else
                continueBtn.Text = "Okay"
                continueBtn.TextColor3 = Color3.fromRGB(255,255,255)
            end
        end

        task.wait(0.3)
    end
end)

--// =====================================================
--// EXPERIENCESETTINGS THEME / BACKGROUND SYSTEM
--// =====================================================

-- All listed parents receive BackgroundColor3, Gradient and BackgroundTransparency.
-- ImageTransparency is never modified; ImageBackground is limited to supported paths.
loc.BG_COLOR_PATHS = {
    "ExperienceSettings.Menu.About_Background",
    "ExperienceSettings.Menu.Arcsen",
    "ExperienceSettings.Menu.Background",
    "ExperienceSettings.Menu.Background.Inner_Background",
    "ExperienceSettings.Menu.Background.Inner2_Background",
    "ExperienceSettings.Menu.Editor.Page",
    "ExperienceSettings.Menu.Editor.BottmBar",
    "ExperienceSettings.Menu.Load_Background",
    "ExperienceSettings.Menu.Search",
    "ExperienceSettings.Menu.Search.List",
    "ExperienceSettings.Menu.Search.Page",
    "ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus",
    "ExperienceSettings.Menu.ProfileStatus",
    "ExperienceSettings.Menu.TopBar.Holder",
    "ExperienceSettings.Menu.TopBar.TopButtons",
    "ExperienceSettings.Menu.Editor.Page.Icon",
    "ExperienceSettings.Menu.Editor.Page.Topic"
}

-- These parents support a tiled ImageBackground. The omitted paths are intentionally no-image targets.
loc.IMAGE_BG_PATHS = {
    "ExperienceSettings.Menu.About_Background",
    "ExperienceSettings.Menu.Arcsen",
    "ExperienceSettings.Menu.Background",
    "ExperienceSettings.Menu.Background.Inner_Background",
    "ExperienceSettings.Menu.Background.Inner2_Background",
    "ExperienceSettings.Menu.Editor.Page",
    "ExperienceSettings.Menu.Load_Background",
    "ExperienceSettings.Menu.Search.List",
    "ExperienceSettings.Menu.Search.Page",
    "ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus"
}

loc.CACHED_BGS = {}
loc.PROFILE_STATUS_INNER = nil
loc.PROFILE_STATUS_INNER_PATH = "ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus"
loc.SEARCH_LIST = nil
loc.SEARCH_PAGE = nil
loc.SEARCH_LIST_PATH = "ExperienceSettings.Menu.Search.List"
loc.SEARCH_PAGE_PATH = "ExperienceSettings.Menu.Search.Page"
loc.CURRENT_BG_COLOR = Color3.fromRGB(18, 18, 21)
loc.CURRENT_BG_TRANSPARENCY = tonumber(Data.UI.MenuBackgroundTransparencyDefault) or 0.08
loc.CURRENT_TILE_SIZE = 64
if type(Data.UI.BackgroundRGB) ~= "table" or #Data.UI.BackgroundRGB < 3 then
    Data.UI.BackgroundRGB = {18, 18, 21}
end
-- 150,150,150 was the previous automatic default. Migrate that legacy fallback
-- to the actual ExperienceSettings default unless an explicit custom flag exists.
if Data.UI.BackgroundRGBCustom ~= true
    and tonumber(Data.UI.BackgroundRGB[1]) == 150
    and tonumber(Data.UI.BackgroundRGB[2]) == 150
    and tonumber(Data.UI.BackgroundRGB[3]) == 150 then
    Data.UI.BackgroundRGB = {18, 18, 21}
end
Data.UI.BackgroundRGBCustom = Data.UI.BackgroundRGBCustom == true
if type(Data.UI.ThemeGradient1) ~= "table" or #Data.UI.ThemeGradient1 < 3 then Data.UI.ThemeGradient1 = {255, 255, 255} end
if type(Data.UI.ThemeGradient2) ~= "table" or #Data.UI.ThemeGradient2 < 3 then Data.UI.ThemeGradient2 = {255, 255, 255} end
Data.UI.ThemeGradientRotation = math.clamp(tonumber(Data.UI.ThemeGradientRotation) or 90, 0, 360)

-- Migrate the previous two-color Custom Gradient to the new multi-stop format.
if type(Data.UI.ThemeGradientColors) ~= "table" or #Data.UI.ThemeGradientColors < 2 then
    Data.UI.ThemeGradientColors = {
        { RGB = {tonumber(Data.UI.ThemeGradient1[1]) or 255, tonumber(Data.UI.ThemeGradient1[2]) or 255, tonumber(Data.UI.ThemeGradient1[3]) or 255}, Transparency = 0 },
        { RGB = {tonumber(Data.UI.ThemeGradient2[1]) or 255, tonumber(Data.UI.ThemeGradient2[2]) or 255, tonumber(Data.UI.ThemeGradient2[3]) or 255}, Transparency = 0 }
    }
end
while #Data.UI.ThemeGradientColors > 20 do table.remove(Data.UI.ThemeGradientColors) end
while #Data.UI.ThemeGradientColors < 2 do
    table.insert(Data.UI.ThemeGradientColors, { RGB = {255, 255, 255}, Transparency = 0 })
end
for i, stop in ipairs(Data.UI.ThemeGradientColors) do
    if type(stop) ~= "table" then stop = {}; Data.UI.ThemeGradientColors[i] = stop end
    local rgb = type(stop.RGB) == "table" and stop.RGB or {255, 255, 255}
    stop.RGB = {
        math.clamp(math.floor(tonumber(rgb[1]) or 255), 0, 255),
        math.clamp(math.floor(tonumber(rgb[2]) or 255), 0, 255),
        math.clamp(math.floor(tonumber(rgb[3]) or 255), 0, 255)
    }
    if stop.Transparency == nil or tostring(stop.Transparency) == "" or string.lower(tostring(stop.Transparency)) == "nil" then
        stop.Transparency = nil
    else
        stop.Transparency = math.clamp(tonumber(stop.Transparency) or 0, 0, 1)
    end
end

loc.findByPath = function(root, path)
    local current = root
    for part in string.gmatch(path, "[^%.]+") do
        current = current and current:FindFirstChild(part)
        if not current then return nil end
    end
    return current
end

loc.refreshThemeTargets = function()
    loc.CACHED_BGS = {}
    loc.PROFILE_STATUS_INNER = loc.findByPath(s.CoreGui, loc.PROFILE_STATUS_INNER_PATH)
    loc.SEARCH_LIST = loc.findByPath(s.CoreGui, loc.SEARCH_LIST_PATH)
    loc.SEARCH_PAGE = loc.findByPath(s.CoreGui, loc.SEARCH_PAGE_PATH)
    for _, path in ipairs(loc.BG_COLOR_PATHS) do
        local inst = loc.findByPath(s.CoreGui, path)
        if inst and inst:IsA("GuiObject") then
            table.insert(loc.CACHED_BGS, inst)
        end
    end
    return #loc.CACHED_BGS
end

loc.parseRGB = function(text)
    if type(text) ~= "string" then return nil end
    local r, g, b = text:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
    r, g, b = tonumber(r), tonumber(g), tonumber(b)
    if r and g and b then
        r, g, b = math.clamp(math.floor(r), 0, 255), math.clamp(math.floor(g), 0, 255), math.clamp(math.floor(b), 0, 255)
        return Color3.fromRGB(r, g, b), { r, g, b }
    end
end

loc.rgbArrayToColor = function(value, fallback)
    if type(value) ~= "table" or #value < 3 then value = fallback end
    return Color3.fromRGB(
        math.clamp(math.floor(tonumber(value[1]) or 150), 0, 255),
        math.clamp(math.floor(tonumber(value[2]) or 150), 0, 255),
        math.clamp(math.floor(tonumber(value[3]) or 150), 0, 255)
    )
end

loc.normalizeImageId = function(raw)
    raw = tostring(raw or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if raw == "" then return "" end
    if raw:match("^rbxassetid://%d+$") then return raw end
    if raw:match("^%d+$") then return "rbxassetid://" .. raw end
    return nil
end

loc.applyBackgroundColor = function(color)
    if typeof(color) ~= "Color3" then return end
    loc.CURRENT_BG_COLOR = color
    if #loc.CACHED_BGS == 0 then loc.refreshThemeTargets() end
    for _, inst in ipairs(loc.CACHED_BGS) do
        if inst and inst.Parent then inst.BackgroundColor3 = color end
    end
end

loc.clampBackgroundTransparency = function(value)
    value = tonumber(value)
    if value == nil or value ~= value or value == math.huge or value == -math.huge then return nil end

    -- Default allows 0–1. Image themes keep at least 0.1 so ImageBackground remains visible.
    local minimum = Data.UI.Theme == "Default" and 0 or 0.1
    return math.clamp(value, minimum, 1)
end

loc.getActiveBackgroundTransparency = function()
    if Data.UI.Theme == "Default" then
        loc.ActiveTransparencyValue = tonumber(Data.UI.MenuBackgroundTransparencyDefault)
        if loc.ActiveTransparencyValue == nil then loc.ActiveTransparencyValue = 0.08 end
    else
        loc.ActiveTransparencyValue = tonumber(Data.UI.MenuBackgroundTransparencyImage)
        if loc.ActiveTransparencyValue == nil then loc.ActiveTransparencyValue = 0.1 end
    end
    return loc.clampBackgroundTransparency(loc.ActiveTransparencyValue)
end

loc.storeActiveBackgroundTransparency = function(value)
    if Data.UI.Theme == "Default" then
        Data.UI.MenuBackgroundTransparencyDefault = value
    else
        Data.UI.MenuBackgroundTransparencyImage = value
    end
    -- Keep the legacy field synchronized for older configs/tools.
    Data.UI.MenuBackgroundTransparency = value
end

loc.clampThemeTileSize = function(value)
    value = tonumber(value)
    if value == nil or value ~= value or value == math.huge or value == -math.huge then return nil end
    return math.max(12, math.floor(value))
end
Data.UI.ThemeTileSize = loc.clampThemeTileSize(Data.UI.ThemeTileSize) or 64

-- These ExperienceSettings containers must always remain fully transparent.
loc.isForcedTransparentBackground = function(inst)
    return inst == loc.PROFILE_STATUS_INNER
        or inst == loc.SEARCH_LIST
        or inst == loc.SEARCH_PAGE
end

loc.applyBackgroundTransparency = function(value)
    value = loc.clampBackgroundTransparency(value)
    if value == nil then return false end
    loc.storeActiveBackgroundTransparency(value)
    loc.CURRENT_BG_TRANSPARENCY = value
    if #loc.CACHED_BGS == 0 then loc.refreshThemeTargets() end
    for _, inst in ipairs(loc.CACHED_BGS) do
        if inst and inst.Parent then
            -- ProfileStatus.InsideProfileStatus, Search.List and Search.Page are fixed at 1.
            inst.BackgroundTransparency = loc.isForcedTransparentBackground(inst)
                and 1
                or loc.CURRENT_BG_TRANSPARENCY
        end
    end
    return true
end

loc.applyTheme = function()
    loc.refreshThemeTargets()
    Data.UI.Theme = (Data.UI.Theme == "Default" or Data.UI.Theme == "Anniversary" or Data.UI.Theme == "Halloween" or Data.UI.Theme == "Custom") and Data.UI.Theme or "Default"

    loc.ThemeGradientColors = {}
    loc.ThemeGradientTransparency = {}
    loc.ThemeGradientRotation = Data.UI.Theme == "Custom"
        and math.clamp(tonumber(Data.UI.ThemeGradientRotation) or 90, 0, 360)
        or 90

    if Data.UI.Theme == "Custom" then
        for _, stop in ipairs(Data.UI.ThemeGradientColors or {}) do
            local rgb = type(stop) == "table" and stop.RGB or nil
            table.insert(loc.ThemeGradientColors, loc.rgbArrayToColor(rgb, {255, 255, 255}))
            table.insert(loc.ThemeGradientTransparency,
                math.clamp(tonumber(type(stop) == "table" and stop.Transparency) or 0, 0, 1))
        end
    else
        local first, second
        if Data.UI.Theme == "Anniversary" then
            first, second = Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 255)
        elseif Data.UI.Theme == "Halloween" then
            first, second = Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 150, 0)
        else
            first, second = Color3.new(1, 1, 1), Color3.new(1, 1, 1)
        end
        loc.ThemeGradientColors = {first, second}
        loc.ThemeGradientTransparency = {0, 0}
    end

    -- Color3 is user-configurable only for Default. All other themes use neutral gray.
    loc.CURRENT_BG_COLOR = Data.UI.Theme == "Default"
        and loc.rgbArrayToColor(Data.UI.BackgroundRGB, {18, 18, 21})
        or Color3.fromRGB(150, 150, 150)
    loc.CURRENT_BG_TRANSPARENCY = loc.getActiveBackgroundTransparency()
        or (Data.UI.Theme == "Default" and 0.08 or 0.1)
    loc.storeActiveBackgroundTransparency(loc.CURRENT_BG_TRANSPARENCY)
    Data.UI.ThemeTileSize = loc.clampThemeTileSize(Data.UI.ThemeTileSize) or 64
    loc.CURRENT_TILE_SIZE = 64
    if Data.UI.Theme == "Custom" then
        loc.CURRENT_TILE_SIZE = Data.UI.ThemeTileSize
    end

    for _, inst in ipairs(loc.CACHED_BGS) do
        if inst and inst.Parent then
            inst.BackgroundColor3 = loc.CURRENT_BG_COLOR
            -- Keep the protected ExperienceSettings containers at BackgroundTransparency = 1.
            inst.BackgroundTransparency = loc.isForcedTransparentBackground(inst)
                and 1
                or loc.CURRENT_BG_TRANSPARENCY
            Gradient(inst, loc.ThemeGradientRotation, 0, 0, loc.ThemeGradientColors, loc.ThemeGradientTransparency)
        end
    end

    if Data.UI.Theme == "Anniversary" then
        loc.ThemeImageID = "rbxassetid://115277364630066"
    elseif Data.UI.Theme == "Halloween" then
        loc.ThemeImageID = "rbxassetid://135302639900234"
    elseif Data.UI.Theme == "Custom" then
        loc.ThemeImageID = loc.normalizeImageId(Data.UI.ThemeImage) or ""
    else
        -- Default theme removes any existing ImageBackground asset.
        loc.ThemeImageID = ""
    end
    for _, path in ipairs(loc.IMAGE_BG_PATHS) do
        loc.ThemeImageParent = loc.findByPath(s.CoreGui, path)
        if loc.ThemeImageParent and loc.ThemeImageParent:IsA("GuiObject") then
            loc.ThemeImage = loc.ThemeImageParent:FindFirstChild("ImageBackground")
            if loc.ThemeImageID ~= "" then
                if not loc.ThemeImage or not loc.ThemeImage:IsA("ImageLabel") then
                    if loc.ThemeImage then loc.ThemeImage:Destroy() end
                    loc.ThemeImage = Instance.new("ImageLabel")
                end
                loc.ThemeImage.Name = "ImageBackground"
                loc.ThemeImage.Size = UDim2.new(1, 0, 1, 0)
                loc.ThemeImage.Position = UDim2.new(0, 0, 0, 0)
                loc.ThemeImage.BackgroundTransparency = 1
                loc.ThemeImage.Image = loc.ThemeImageID
                loc.ThemeImage.ScaleType = Enum.ScaleType.Tile
                loc.ThemeImage.TileSize = UDim2.new(0, loc.CURRENT_TILE_SIZE or 64, 0, loc.CURRENT_TILE_SIZE or 64)
                loc.ThemeImage.ZIndex = math.max(0, (tonumber(loc.ThemeImageParent.ZIndex) or 1) - 1)
                loc.ThemeImage.Active = false
                loc.ThemeImage.Parent = loc.ThemeImageParent
            elseif loc.ThemeImage then
                loc.ThemeImage:Destroy()
            end
        end
    end
end

-- Apply saved theme once, persist any theme-specific transparency correction,
-- then keep newly-created menu parents in sync.
loc.applyTheme()
loc.saveData(Data)

--// =====================================================
--// THEME SETTINGS UI
--// =====================================================

loc.BackgroundColorUI = loc.o(
    "Set BackgroundColor3 (R,G,B)",
    255, 255, 255,
    true, table.concat(Data.UI.BackgroundRGB, ","),
    true, "Save",
    function(box)
        if Data.UI.Theme ~= "Default" then return end
        local color, raw = loc.parseRGB(box.Text)
        if color then
            Data.UI.BackgroundRGB = raw
            loc.applyTheme()
        end
    end,
    function(box, btn)
        if Data.UI.Theme ~= "Default" then return end
        local color, raw = loc.parseRGB(box.Text)
        if not color then return end
        Data.UI.BackgroundRGB = raw
        Data.UI.BackgroundRGBCustom = true
        loc.saveData(Data)
        loc.applyTheme()
        btn.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.delay(0.35, function()
            if btn and btn.Parent then btn.TextColor3 = Color3.new(1, 1, 1) end
        end)
    end
)

if loc.BackgroundColorUI and loc.BackgroundColorUI.Input then
    loc.BackgroundColorUI.Input.Text = table.concat(Data.UI.BackgroundRGB, ",")
end

loc.ThemeSelectUI = loc.o(
    scr, nil, "Theme", false, false, nil, true, false, nil,
    function(ui)
        ui.AddSelect("Default")
        ui.AddSelect("Anniversary")
        ui.AddSelect("Halloween")
        ui.AddSelect("Custom")
        ui.SelectedValue = Data.UI.Theme
        ui.SelectButton.Text = Data.UI.Theme
    end,
    function(value, action, ui)
        if action ~= "select" then return end
        if value ~= "Default" and value ~= "Anniversary" and value ~= "Halloween" and value ~= "Custom" then return end
        Data.UI.Theme = value
        loc.updateThemeCustomRows()
        loc.applyTheme()
        if loc.BackgroundTransparencyUI and loc.BackgroundTransparencyUI.Input then
            loc.BackgroundTransparencyUI.Input.PlaceholderText = tostring(loc.getActiveBackgroundTransparency())
        end
        loc.saveData(Data)
        if ui and ui.SelectButton then ui.SelectButton.Text = value end
    end,
    Data.UI.Theme
)

loc.updateThemeCustomRows = function()
    loc.ThemeRowsVisible = Data.UI.Theme == "Custom"
    if loc.ThemeImageUI and loc.ThemeImageUI.Frame then loc.ThemeImageUI.Frame.Visible = loc.ThemeRowsVisible end
    if loc.ThemeTileSizeUI and loc.ThemeTileSizeUI.Frame then loc.ThemeTileSizeUI.Frame.Visible = loc.ThemeRowsVisible end
    if loc.ThemeGradientEditorFrame then loc.ThemeGradientEditorFrame.Visible = loc.ThemeRowsVisible end

    -- BackgroundColor3 can only be edited while the Default theme is selected.
    loc.BackgroundColorEditable = Data.UI.Theme == "Default"
    if loc.BackgroundColorUI then
        if loc.BackgroundColorUI.Input then
            loc.BackgroundColorUI.Input.TextEditable = loc.BackgroundColorEditable
            loc.BackgroundColorUI.Input.Active = loc.BackgroundColorEditable
            loc.BackgroundColorUI.Input.Selectable = loc.BackgroundColorEditable
            loc.BackgroundColorUI.Input.BackgroundTransparency = loc.BackgroundColorEditable and 0.1 or 0.55
        end
        if loc.BackgroundColorUI.Button then
            loc.BackgroundColorUI.Button.Active = loc.BackgroundColorEditable
            loc.BackgroundColorUI.Button.Selectable = loc.BackgroundColorEditable
            loc.BackgroundColorUI.Button.AutoButtonColor = loc.BackgroundColorEditable
            loc.BackgroundColorUI.Button.Text = loc.BackgroundColorEditable and "Save" or "Locked"
            loc.BackgroundColorUI.Button.BackgroundTransparency = loc.BackgroundColorEditable and 0.12 or 0.6
        end
    end
end

loc.ThemeTileSizeUI = loc.o(
    "Set TileSize (px, minimum 12)",
    255, 255, 255,
    true, tostring(Data.UI.ThemeTileSize or 64),
    true, "Save",
    function(box)
        local value = loc.clampThemeTileSize(box.Text)
        if value ~= nil then
            Data.UI.ThemeTileSize = value
            box.Text = ""
            box.PlaceholderText = tostring(value)
            loc.applyTheme()
        end
    end,
    function(box, btn)
        local value = loc.clampThemeTileSize(box.Text)
        if value == nil then return end
        Data.UI.ThemeTileSize = value
        box.Text = ""
        box.PlaceholderText = tostring(value)
        loc.saveData(Data)
        loc.applyTheme()
        btn.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.delay(0.35, function() if btn and btn.Parent then btn.TextColor3 = Color3.new(1, 1, 1) end end)
    end
)
if loc.ThemeTileSizeUI and loc.ThemeTileSizeUI.Input then
    loc.ThemeTileSizeUI.Input.Text = ""
    loc.ThemeTileSizeUI.Input.PlaceholderText = tostring(Data.UI.ThemeTileSize or 64)
end

loc.ThemeImageUI = loc.o(
    "Set Image (Asset ID)",
    255, 255, 255,
    true, tostring(Data.UI.ThemeImage or ""),
    true, "Save",
    function(box)
        loc.ThemeImageValue = loc.normalizeImageId(box.Text)
        if loc.ThemeImageValue ~= nil then
            Data.UI.ThemeImage = loc.ThemeImageValue
            loc.applyTheme()
        end
    end,
    function(box, btn)
        loc.ThemeImageValue = loc.normalizeImageId(box.Text)
        if loc.ThemeImageValue == nil then return end
        Data.UI.ThemeImage = loc.ThemeImageValue
        loc.saveData(Data)
        loc.applyTheme()
        btn.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.delay(0.35, function() if btn and btn.Parent then btn.TextColor3 = Color3.new(1, 1, 1) end end)
    end
)
if loc.ThemeImageUI and loc.ThemeImageUI.Input then
    loc.ThemeImageUI.Input.Text = tostring(Data.UI.ThemeImage or "")
end

-- Dynamic Multi-Stop Gradient Editor (2–20 stops).
loc.ThemeGradientEditorFrame = Instance.new("Frame")
loc.ThemeGradientEditorFrame.Name = "CustomGradientEditor"
loc.ThemeGradientEditorFrame.Size = UDim2.new(1, 0, 0, 0)
loc.ThemeGradientEditorFrame.AutomaticSize = Enum.AutomaticSize.Y
loc.ThemeGradientEditorFrame.BackgroundTransparency = 1
loc.ThemeGradientEditorFrame.Visible = false
loc.ThemeGradientEditorFrame.Parent = scr
ListLayout(loc.ThemeGradientEditorFrame, 0, 4, "HCenter", "VTop", "SLayout", "FillV")

loc.ThemeGradientRowUIs = {}
loc.copyThemeGradientStops = function(stops)
    local copy = {}
    for _, stop in ipairs(stops or {}) do
        local rgb = type(stop) == "table" and stop.RGB or nil
        table.insert(copy, {
            RGB = {
                math.clamp(math.floor(tonumber(rgb and rgb[1]) or 255), 0, 255),
                math.clamp(math.floor(tonumber(rgb and rgb[2]) or 255), 0, 255),
                math.clamp(math.floor(tonumber(rgb and rgb[3]) or 255), 0, 255)
            },
            Transparency = type(stop) == "table" and stop.Transparency or nil
        })
    end
    return copy
end
loc.ThemeGradientDraftStops = loc.copyThemeGradientStops(Data.UI.ThemeGradientColors)
loc.collectThemeGradientDraft = function(skipIndex)
    local result = {}
    for i, rowUI in ipairs(loc.ThemeGradientRowUIs) do
        if i ~= skipIndex then
            local raw = rowUI.Input and rowUI.Input.Text or ""
            local rgbText, transparencyText = tostring(raw):match("^%s*(.-)%s*;%s*(.-)%s*$")
            if not rgbText then rgbText = tostring(raw) end
            local color, rgb = loc.parseRGB(rgbText)
            if not color then return nil, "Color" .. i .. " must use R,G,B;Transparency." end
            local transparency = nil
            if transparencyText ~= nil and transparencyText ~= ""
                and string.lower(transparencyText) ~= "nil" then
                transparency = tonumber(transparencyText)
                if not transparency or transparency < 0 or transparency > 1 then
                    return nil, "Color" .. i .. " transparency must be 0–1 or nil."
                end
            end
            table.insert(result, { RGB = rgb, Transparency = transparency })
        end
    end
    return result
end

loc.rebuildThemeGradientRows = function()
    for _, rowUI in ipairs(loc.ThemeGradientRowUIs) do
        if rowUI.Frame then rowUI.Frame:Destroy() end
    end
    loc.ThemeGradientRowUIs = {}
    for i, stop in ipairs(loc.ThemeGradientDraftStops) do
        local rgb = type(stop.RGB) == "table" and stop.RGB or {255, 255, 255}
        local transparencyText = stop.Transparency == nil and "" or tostring(stop.Transparency)
        local ui = loc.o(
            "Color" .. i,
            255, 255, 255,
            true, "R,G,B;Transparency (or nil)",
            true, "Delete",
            nil,
            function(box, btn, rowData)
                local rowIndex = rowData and rowData.Frame and rowData.Frame:GetAttribute("GradientIndex") or i
                local draft, err = loc.collectThemeGradientDraft(rowIndex)
                if not draft then
                    return
                end
                if #draft < 2 then
                    return
                end
                loc.ThemeGradientDraftStops = draft
                loc.rebuildThemeGradientRows()
            end,
            nil,
            loc.ThemeGradientEditorFrame
        )
        if ui and ui.Input then
            ui.Frame.LayoutOrder = i
            ui.Frame:SetAttribute("GradientIndex", i)
            ui.Input.Text = table.concat(rgb, ",") .. ";" .. transparencyText
            ui.Input.PlaceholderText = "R,G,B;Transparency (or nil)"
            ui.Input.TextSize = 13
            ui.Input.TextScaled = false
            ui.Label.Size = UDim2.new(0.2, -2, 1, 0)
            ui.Input.Size = UDim2.new(0.58, -4, 0, 24)
            ui.Input.Position = UDim2.new(0.21, 2, 0, 3)
            ui.Button.Size = UDim2.new(0.19, -2, 0, 24)
            ui.Button.Position = UDim2.new(0.80, 0, 0, 3)
        end
        table.insert(loc.ThemeGradientRowUIs, ui)
    end
end

loc.ThemeGradientRotationUI = loc.o(
    "Gradient Rotation (0–360)",
    255, 255, 255,
    true, tostring(Data.UI.ThemeGradientRotation or 90),
    false, nil,
    nil, nil, nil,
    loc.ThemeGradientEditorFrame
)
if loc.ThemeGradientRotationUI and loc.ThemeGradientRotationUI.Input then
    loc.ThemeGradientRotationUI.Input.Text = tostring(Data.UI.ThemeGradientRotation or 90)
    loc.ThemeGradientRotationUI.Input.TextSize = 14
    loc.ThemeGradientRotationUI.Input.TextScaled = false
    loc.ThemeGradientRotationUI.Frame.LayoutOrder = 0
end

loc.ThemeGradientAddUI = loc.o(
    "Add Color",
    255, 255, 255,
    false, nil,
    true, "Add",
    nil,
    function(box, btn)
        if #loc.ThemeGradientDraftStops >= 20 then
            return
        end
        local draft, err = loc.collectThemeGradientDraft()
        if not draft then
            return
        end
        table.insert(draft, { RGB = {255, 255, 255}, Transparency = 0 })
        loc.ThemeGradientDraftStops = draft
        loc.rebuildThemeGradientRows()
    end,
    nil,
    loc.ThemeGradientEditorFrame
)
if loc.ThemeGradientAddUI and loc.ThemeGradientAddUI.Frame then
    loc.ThemeGradientAddUI.Frame.LayoutOrder = 21
end

loc.ThemeGradientSaveUI = loc.o(
    "Gradient Settings",
    255, 255, 255,
    false, nil,
    true, "Submit and Save",
    nil,
    function(box, btn)
        local draft, err = loc.collectThemeGradientDraft()
        if not draft then
            return
        end
        if #draft < 2 or #draft > 20 then
            return
        end
        local rotation = tonumber(loc.ThemeGradientRotationUI and loc.ThemeGradientRotationUI.Input
            and loc.ThemeGradientRotationUI.Input.Text or "")
        if not rotation or rotation < 0 or rotation > 360 then
            return
        end
        Data.UI.ThemeGradientColors = draft
        Data.UI.ThemeGradientRotation = rotation
        loc.ThemeGradientDraftStops = loc.copyThemeGradientStops(draft)
        loc.saveData(Data)
        loc.rebuildThemeGradientRows()
        loc.applyTheme()
        btn.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.delay(0.5, function() if btn and btn.Parent then btn.TextColor3 = Color3.new(1, 1, 1) end end)
    end,
    nil,
    loc.ThemeGradientEditorFrame
)
if loc.ThemeGradientSaveUI and loc.ThemeGradientSaveUI.Frame then
    loc.ThemeGradientSaveUI.Frame.LayoutOrder = 22
end

loc.rebuildThemeGradientRows()
loc.updateThemeCustomRows()
loc.saveData(Data)

loc.BackgroundTransparencyUI = loc.o(
    "Set BackgroundTransparency",
    255, 255, 255,
    true, tostring(loc.getActiveBackgroundTransparency() or 0.08),
    true, "Save",
    function(box)
        local value = loc.clampBackgroundTransparency(box.Text)
        if value ~= nil then
            loc.applyBackgroundTransparency(value)
        end
    end,
    function(box, btn)
        local value = loc.clampBackgroundTransparency(box.Text)
        if value == nil then return end
        loc.storeActiveBackgroundTransparency(value)
        box.Text = ""
        box.PlaceholderText = tostring(value)
        loc.saveData(Data)
        loc.applyBackgroundTransparency(value)
        btn.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.delay(0.35, function() if btn and btn.Parent then btn.TextColor3 = Color3.new(1, 1, 1) end end)
    end
)
if loc.BackgroundTransparencyUI and loc.BackgroundTransparencyUI.Input then
    loc.BackgroundTransparencyUI.Input.Text = ""
    loc.BackgroundTransparencyUI.Input.PlaceholderText = tostring(loc.getActiveBackgroundTransparency() or 0.08)
end

-- Keep the current theme applied as delayed ExperienceSettings descendants appear.
task.spawn(function()
    while true do
        loc.applyTheme()
        task.wait(1)
    end
end)

-- background watcher (ไม่บล็อก)
task.spawn(function()
	while true do
		if not MENU_INSTANCE then
			local menu =
				loc.findByPath(
					s.CoreGui,
					"ExperienceSettings.Menu"
				)
			if menu
			and menu:IsA("ScreenGui") then
				MENU_INSTANCE = menu
				loc.applyHideMenu()
			end
			end
		task.wait(0.25)
	end
end)

loc.o(
    "Hide ExperienceSettings",
    255,255,255,
    false, nil,
    true, nil,

    function(newStatus)
        HIDE_MENU_STATUS = newStatus
        Data.UI.HideMenu = newStatus
        loc.saveData(Data)
        loc.applyHideMenu()
    end,

    nil,
    Data.UI.HideMenu,
    scr
)

--// =====================================================
--// FOUND HUMANOIDROOTPART STATUS
--// =====================================================

-- Players uses the shared s.Players service reference.
local LocalPlayer = s.Players.LocalPlayer

-- สร้าง Text อย่างเดียว (ไม่มี box / ไม่มีปุ่ม)
local ui = loc.o(
    "FoundHumanoidRootPart: NO",
    255,255,255,
    false, nil,
    false, nil
)

local label = ui.Label

-- ฟังก์ชันเช็ค HRP
loc.updateHRPStatus = function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if hrp then
        label.Text = "FoundHumanoidRootPart: YES"
        label.TextColor3 = Color3.fromRGB(0,255,0)
    else
        label.Text = "FoundHumanoidRootPart: NO"
        label.TextColor3 = Color3.fromRGB(255,0,0)
    end
end

-- เช็คตอนแรก
loc.updateHRPStatus()

-- เช็คเมื่อ character โหลดใหม่
LocalPlayer.CharacterAdded:Connect(function(char)
    loc.updateHRPStatus()

    -- เผื่อ HRP โผล่ช้า
    char.ChildAdded:Connect(function(child)
        if child.Name == "HumanoidRootPart" then
            loc.updateHRPStatus()
        end
    end)
end)

-- fallback: loop กันพลาด
task.spawn(function()
    while true do
        loc.updateHRPStatus()
        task.wait(0.5)
    end
end)

--// =====================================================
--// SETTINGS TRANSPARENCY SYSTEM
--// =====================================================

-- CoreGui uses the shared s.CoreGui service reference.

-- Settings Only transparency controls the Loader Rejoiner holder (hr) only.
-- It is intentionally separate from MenuBackgroundTransparency, which targets ExperienceSettings.
local SETTINGS_INSTANCES = { hr }
local CURRENT_TRANSPARENCY = tonumber(Data.UI.SettingsTransparency) or 0.3

-- apply transparency to Loader Rejoiner only.
loc.applyTransparency = function(value)
    value = tonumber(value)
    if not value then return false end
    CURRENT_TRANSPARENCY = math.clamp(value, 0, 1)

    for _, inst in ipairs(SETTINGS_INSTANCES) do
        if inst and inst.Parent and inst:IsA("GuiObject") then
            inst.BackgroundTransparency = CURRENT_TRANSPARENCY
        end
    end
    return true
end

-- Apply saved Settings Only value immediately to hr.
loc.applyTransparency(CURRENT_TRANSPARENCY)

loc.o(
    "Set BackgroundTransparency (Settings Only)",
    255,255,255,
    true, tostring(Data.UI.SettingsTransparency or 0.3),
    true, "Save",

    -- LIVE PREVIEW
    function(box)
        local v = tonumber(box.Text)
        if v then
            loc.applyTransparency(v)
        end
    end,

    -- SAVE
    function(box, btn)
        local v = tonumber(box.Text)
        if not v then return end

        v = math.clamp(v, 0, 1)
        Data.UI.SettingsTransparency = v
        loc.saveData(Data)
        loc.applyTransparency(v)

        btn.TextColor3 = Color3.fromRGB(0,255,0)
        task.delay(0.35, function()
            btn.TextColor3 = Color3.fromRGB(255,255,255)
        end)
    end
)

-- =====================================================
-- LOAD DATA
-- =====================================================
Data = loc.loadData()
Data.UI = Data.UI or {}
Data.UI.UIScale = tonumber(Data.UI.UIScale) or 1

-- =====================================================
-- SERVICES
-- =====================================================
-- CoreGui uses the shared s.CoreGui service reference.

-- =====================================================
-- STATE
-- =====================================================
local MENU_INSTANCE = nil
local UISCALE_INSTANCE = nil
local CURRENT_SCALE = Data.UI.UIScale

-- =====================================================
-- FIND MENU (CoreGui.ExperienceSettings.Menu)
-- =====================================================
loc.tryFindMenu = function()
    local root = s.CoreGui:FindFirstChild("ExperienceSettings")
    if not root then return nil end
    return root:FindFirstChild("Menu")
end

-- =====================================================
-- APPLY UI SCALE
-- =====================================================
loc.applyUIScale = function(scale)
    if not MENU_INSTANCE then return end

    CURRENT_SCALE = math.clamp(scale or CURRENT_SCALE, 0.5, 2)

    -- reset ถ้า UIScale ติด menu เก่า
    if UISCALE_INSTANCE and UISCALE_INSTANCE.Parent ~= MENU_INSTANCE then
        UISCALE_INSTANCE = nil
    end

    if not UISCALE_INSTANCE then
        UISCALE_INSTANCE = MENU_INSTANCE:FindFirstChild("MenuUIScale")

        if not UISCALE_INSTANCE then
            UISCALE_INSTANCE = Instance.new("UIScale")
            UISCALE_INSTANCE.Name = "MenuUIScale"
            UISCALE_INSTANCE.Parent = MENU_INSTANCE
        end
    end

    UISCALE_INSTANCE.Scale = CURRENT_SCALE
end

-- =====================================================
-- WATCHER (รอ menu ได้ตลอด / ไม่บล็อก)
-- =====================================================
task.spawn(function()
    while true do
        local menu = loc.tryFindMenu()
        if menu and menu ~= MENU_INSTANCE then
            MENU_INSTANCE = menu
            UISCALE_INSTANCE = nil
            loc.applyUIScale(CURRENT_SCALE) -- apply จาก data ทันที
        end
        task.wait(0.25)
    end
end)

-- =====================================================
-- UI (Txt)
-- =====================================================
loc.o(
    "Set UIScaled",
    255,255,255,
    true, tostring(Data.UI.UIScale),
    true, "Save",

    -- LIVE PREVIEW
    function(box)
        local v = tonumber(box.Text)
        if v then
            loc.applyUIScale(v)
        end
    end,

    -- SAVE
    function(box, btn)
        local v = tonumber(box.Text)
        if not v then return end

        v = math.clamp(v, 0.5, 2)
        Data.UI.UIScale = v
        loc.saveData(Data)
        loc.applyUIScale(v)

        -- feedback
        btn.TextColor3 = Color3.fromRGB(0,255,0)
        task.delay(0.35, function()
            btn.TextColor3 = Color3.fromRGB(255,255,255)
        end)
    end
)

-- StarterGui uses the shared s.StarterGui service reference.

loc.isHealthEnabled = function()
    local ok, res = pcall(function()
        return s.StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Health)
    end)
    return ok and res or false
end

loc.setHealth = function(state)
    s.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, state)
end

-- TXT: Status
local healthTxt = loc.o(
    "IsHealthOn: ...",
    0,255,0,
    false,nil,
    false,nil
)

-- TXT: Toggle
local HealthToggle = loc.o(
    "HealthBarToggle",
    255,255,255,
    false,nil,
    true,"",
    function(status)
        loc.setHealth(status)
    end,
    function(status)
        loc.setHealth(status)
    end,
    loc.isHealthEnabled(),
    scr
)

-- 🔁 Unified watcher
task.spawn(function()
    local last
    while true do
        local on = loc.isHealthEnabled()
        if on ~= last then
            -- update text
            healthTxt.Label.Text = "IsHealthOn: " .. (on and "YES" or "NO")
            healthTxt.Label.TextColor3 = on
                and Color3.fromRGB(0,255,0)
                or Color3.fromRGB(255,0,0)

            -- update button
            loc.updateToggle(HealthToggle.Button, on)

            last = on
        end
        task.wait(0.5)
    end
end)

-- TeleportService uses the shared s.TeleportService service reference.
-- HttpService uses the shared s.HttpService service reference.
-- Players uses the shared s.Players service reference.

local player = s.Players.LocalPlayer
local placeId = game.PlaceId

-- Server selector: filters public servers by ServerSize (maxPlayers), not current PlayerCount.
local SERVER_OPTIONS = {
    { Label = "Rejoin (Default)", Key = "Rejoin" },
    { Label = "Hop", Key = "Hop" },
    { Label = "Few Players (<2)", Key = "Few", MinSize = 1 },
    { Label = "Less Players (<5)", Key = "Less", MinSize = 2 },
    { Label = "Many Players (<10)", Key = "Many", MinSize = 5 },
    { Label = "A Lot Of Players (10+)", Key = "A lot", MinSize = 10 },
    { Label = "Custom", Key = "Custom", MinSize = 2 },
}

local SERVER_OPTION_BY_LABEL = {}
for _, option in ipairs(SERVER_OPTIONS) do
    SERVER_OPTION_BY_LABEL[option.Label] = option
end

local SERVER_PLAYER_COUNT = #s.Players:GetPlayers()
local SERVER_SIZE = tonumber(s.Players.MaxPlayers)
if not SERVER_SIZE or SERVER_SIZE <= 0 then
    SERVER_SIZE = SERVER_PLAYER_COUNT
end
local SERVER_SELECT_UI

-- Resolve the custom target against this server's capacity.
-- The target must always be at least one slot below the current ServerSize.
loc.CustomServerTarget = nil
loc.UpdateCustomServerTarget = function(raw, commit)
    if raw == nil or tostring(raw):match("^%s*$") then
        loc.CustomServerTarget = nil
        if loc.CustomServerUI and loc.CustomServerUI.Label then
            loc.CustomServerUI.Label.Text = "Custom ServerSize"
        end
        return nil
    end

    local entered = tonumber(raw)
    if not entered or entered ~= entered or entered == math.huge or entered < 1 then
        loc.CustomServerTarget = nil
        if loc.CustomServerUI and loc.CustomServerUI.Label then
            loc.CustomServerUI.Label.Text = "Custom ServerSize (Invalid)"
        end
        return nil
    end

    entered = math.floor(entered)
    local maxAllowed = SERVER_SIZE - 1
    if maxAllowed < 1 then
        loc.CustomServerTarget = nil
        if loc.CustomServerUI and loc.CustomServerUI.Label then
            loc.CustomServerUI.Label.Text = "Custom ServerSize (Unavailable)"
        end
        return nil
    end

    local adjusted = math.min(entered, maxAllowed)
    loc.CustomServerTarget = adjusted

    if loc.CustomServerUI then
        if loc.CustomServerUI.Label then
            loc.CustomServerUI.Label.Text = string.format(
                "Custom ServerSize (%d/%d)",
                adjusted,
                SERVER_SIZE
            )
        end
        if commit and loc.CustomServerUI.Input then
            loc.CustomServerUI.Input.Text = tostring(adjusted)
        end
    end

    return adjusted
end

loc.UpdateServerSelector = function()
    SERVER_PLAYER_COUNT = #s.Players:GetPlayers()
    SERVER_SIZE = tonumber(s.Players.MaxPlayers)
    if not SERVER_SIZE or SERVER_SIZE <= 0 then
        SERVER_SIZE = SERVER_PLAYER_COUNT
    end

    if SERVER_SELECT_UI and SERVER_SELECT_UI.Label then
        SERVER_SELECT_UI.Label.Text = string.format(
            "Server (%d/%d)",
            SERVER_PLAYER_COUNT,
            SERVER_SIZE
        )
    end

    -- Disable size ranges that cannot exist below the current ServerSize.
    if SERVER_SELECT_UI and SERVER_SELECT_UI.SelectOptions then
        for _, option in ipairs(SERVER_OPTIONS) do
            if option.MinSize then
                SERVER_SELECT_UI.SetOptionDisabled(
                    SERVER_SELECT_UI.SelectOptions[option.Label],
                    SERVER_SIZE < option.MinSize
                )
            end
        end
    end

    -- Refresh the displayed custom result when the current server size changes.
    if loc.CustomServerUI and loc.CustomServerUI.Input
        and loc.CustomServerUI.Input.Text ~= "" then
        loc.UpdateCustomServerTarget(loc.CustomServerUI.Input.Text, false)
    end
end

SERVER_SELECT_UI = loc.o(
    scr,
    nil,
    "Server (0/0)",
    false,
    true,
    "Go",
    true,
    false,
    nil,
    nil,
    function(value, action, ui)
        if action == "select" then
            local selected = SERVER_OPTION_BY_LABEL[value]
            if loc.CustomServerUI and loc.CustomServerUI.Frame then
                loc.CustomServerUI.Frame.Visible = selected and selected.Key == "Custom" or false
            end
            if selected and selected.Key == "Custom" and loc.CustomServerUI
                and loc.CustomServerUI.Input then
                loc.UpdateCustomServerTarget(loc.CustomServerUI.Input.Text, false)
            end
            return
        end

        if action ~= "button" then return end

        local selected = SERVER_OPTION_BY_LABEL[value]
        if not selected then return end

        local customTarget
        if selected.Key == "Custom" then
            customTarget = loc.UpdateCustomServerTarget(
                loc.CustomServerUI and loc.CustomServerUI.Input
                    and loc.CustomServerUI.Input.Text or "",
                true
            )
            if not customTarget then
                ui.Button.Text = "Invalid Size"
                ui.Button.TextColor3 = Color3.fromRGB(255, 150, 0)
                task.delay(2, function()
                    if ui.Button and ui.Button.Parent then
                        ui.Button.Text = "Go"
                        ui.Button.TextColor3 = Color3.new(1, 1, 1)
                    end
                end)
                return
            end
        end

        ui.Button.TextColor3 = Color3.fromRGB(255, 220, 100)

        if selected.Key == "Rejoin" then
            ui.Button.Text = "Rejoining..."
            task.spawn(function()
                task.wait(0.5)
                s.TeleportService:Teleport(placeId, player)
            end)
            return
        end

        ui.Button.Text = selected.Key == "Hop" and "Hopping..." or "Searching..."
        task.spawn(function()
            local start = os.clock()
            local found = false
            local filter

            -- Preset filters use server.maxPlayers (ServerSize), not server.playing.
            if selected.Key == "Few" then
                filter = function(capacity)
                    return capacity < 2
                end
            elseif selected.Key == "Less" then
                filter = function(capacity)
                    return capacity >= 2 and capacity < 5
                end
            elseif selected.Key == "Many" then
                filter = function(capacity)
                    return capacity >= 5 and capacity < 10
                end
            elseif selected.Key == "A lot" then
                filter = function(capacity)
                    return capacity >= 10
                end
            elseif selected.Key == "Custom" then
                filter = function(capacity)
                    return capacity == customTarget
                end
            end
            -- Hop intentionally has no ServerSize filter.

            while os.clock() - start < 5 do
                local url = "https://games.roblox.com/v1/games/"
                    .. placeId
                    .. "/servers/Public?sortOrder=Asc&limit=100"

                local success, result = pcall(function()
                    return s.HttpService:JSONDecode(game:HttpGet(url))
                end)

                local candidates = {}
                if success and result and type(result.data) == "table" then
                    for _, server in ipairs(result.data) do
                        local playing = tonumber(server.playing)
                        local capacity = tonumber(server.maxPlayers)
                        if server.id ~= game.JobId
                            and playing ~= nil
                            and capacity ~= nil
                            and playing < capacity
                            and (not filter or filter(capacity)) then
                            table.insert(candidates, server.id)
                        end
                    end
                end

                if #candidates > 0 then
                    found = true
                    ui.Button.Text = selected.Key == "Hop" and "Hopping..." or "Joining..."
                    s.TeleportService:TeleportToPlaceInstance(
                        placeId,
                        candidates[math.random(1, #candidates)],
                        player
                    )
                    return
                end

                task.wait(1)
            end

            if not found and ui.Button and ui.Button.Parent then
                ui.Button.Text = "No server found"
                ui.Button.TextColor3 = Color3.fromRGB(255, 150, 0)
                task.delay(2, function()
                    if ui.Button and ui.Button.Parent then
                        ui.Button.Text = "Go"
                        ui.Button.TextColor3 = Color3.new(1, 1, 1)
                    end
                end)
            end
        end)
    end,
    "Rejoin (Default)"
)

for _, option in ipairs(SERVER_OPTIONS) do
    SERVER_SELECT_UI.AddSelect(option.Label)
end

-- A separate row keeps the nbox from overlapping the Select and Go controls.
loc.CustomServerUI = loc.o(
    scr,
    nil,
    "Custom ServerSize",
    false,
    false,
    nil,
    false,
    true,
    "Max players",
    nil,
    function(value, action)
        if action == "input" then
            loc.UpdateCustomServerTarget(value, true)
        end
    end
)
loc.CustomServerUI.Frame.Visible = false

loc.UpdateServerSelector()
s.Players.PlayerAdded:Connect(function()
    task.defer(loc.UpdateServerSelector)
end)
s.Players.PlayerRemoving:Connect(function()
    task.defer(loc.UpdateServerSelector)
end)

------------------------------------------------------------

-- ExperienceSettings Frames
local ESFrames = {
    "About_Background",
    "Background",
    "AIOpenSource",
    "Load_Background",
    "ProfileStatus",
    "Holder",
    "Search"
}

-- TopBarApp Frames
local TBFrames = {
    "point"
}

-- State
local DragState = false
local DragLoopStarted = false

loc.applyDraggableUI = function(state)

    DragState = state

    if DragLoopStarted then
        return
    end

    DragLoopStarted = true

    task.spawn(function()

        while true do

            -- ExperienceSettings
            local vES = s.CoreGui:FindFirstChild("ExperienceSettings")
            if vES then
                for _,name in ipairs(ESFrames) do
                    local ui = vES:FindFirstChild(name, true)
                    if ui and ui:IsA("Frame") then
                        ui.Active = DragState
                        ui.Draggable = DragState
                    end
                end
            end

            -- TopBarApp
            local vTopBar = s.CoreGui:FindFirstChild("TopBarApp")
            if vTopBar then
                for _,name in ipairs(TBFrames) do
                    local ui = vTopBar:FindFirstChild(name, true)
                    if ui and ui:IsA("Frame") then
                        ui.Active = DragState
                        ui.Draggable = DragState
                    end
                end
            end

            task.wait(0.5)

        end

    end)

end



loc.DragUItweenColor = function(obj,color)
    s.TweenService:Create(
        obj,
        TweenInfo.new(0.25),
        {TextColor3 = color}
    ):Play()
end

-- toggle UI
local DraUI = loc.o(
    "Draggable UI",
    255,255,255,
    false,nil,
    true,"OFF",

    function(state)

        Data.UI.DraggableUI = state
        loc.saveData(Data)

        loc.applyDraggableUI(state)

    end,

    nil,

    Data.UI.DraggableUI,
    scr
)

-- apply color when UI created
if DraUI.Button then
    if Data.UI.DraggableUI then
        DraUI.Button.Text = "ON"
        loc.DragUItweenColor(DraUI.Button, Color3.fromRGB(0,255,0))
    else
        DraUI.Button.Text = "OFF"
        loc.DragUItweenColor(DraUI.Button, Color3.fromRGB(255,0,0))
    end
end

-- apply ตอนโหลด
task.spawn(function()
    loc.applyDraggableUI(Data.UI.DraggableUI)
end)

--// =====================================================
--// CROSSHAIR SYSTEM (FIXED)
--// =====================================================

-- Players uses the shared s.Players service reference.
-- CoreGui uses the shared s.CoreGui service reference.

local player = s.Players.LocalPlayer

local DEFAULT_CROSSHAIR =
	"rbxassetid://118624373632520"

local DEFAULT_TOOL_CROSSHAIR =
	"rbxassetid://73868291781876"

local TARGET_SHIFT = nil

--====================================================--
-- GET IMAGE FROM DATA
--====================================================--

loc.getNormalCrosshair = function()

	local id = Data.UI.CrosshairID

	if not id
	or id == ""
	or id == "0" then

		return DEFAULT_CROSSHAIR
	end

	return id
end

loc.getToolCrosshair = function()

	local id = Data.UI.ToolCrosshairID

	if not id
	or id == ""
	or id == "0" then

		return DEFAULT_TOOL_CROSSHAIR
	end

	return id
end

--====================================================--
-- TOOL CHECK
--====================================================--

loc.isToolEnabled = function()

	local char = player.Character

	if not char then
		return false
	end

	for _, v in ipairs(char:GetChildren()) do
		if v:IsA("Tool") then
			return true
		end
	end

	return false
end

--====================================================--
-- APPLY CROSSHAIR
--====================================================--

loc.applyCrosshair = function()

	if not TARGET_SHIFT then
		return
	end

	local current =
		TARGET_SHIFT.Image

	--================================================--
	-- TOOL MODE
	--================================================--

	if loc.isToolEnabled() then

		local newTool =
			loc.getToolCrosshair()

		-- ถ้าปัจจุบันยังเป็น default
		-- หรือเป็นค่าว่าง
		-- ให้เปลี่ยนทันที

		if current == DEFAULT_TOOL_CROSSHAIR
		or current == ""
		or current == "0" then

			TARGET_SHIFT.Image =
				newTool

		-- ถ้า save ใหม่แล้ว
		-- แต่ current ยังไม่ตรง
		-- force update

		elseif current ~= newTool then

			TARGET_SHIFT.Image =
				newTool

		end

	--================================================--
	-- NORMAL MODE
	--================================================--

	else

		local newNormal =
			loc.getNormalCrosshair()

		if current == DEFAULT_CROSSHAIR
		or current == ""
		or current == "0" then

			TARGET_SHIFT.Image =
				newNormal

		elseif current ~= newNormal then

			TARGET_SHIFT.Image =
				newNormal

		end

	end
end

--====================================================--
-- FIND TARGETSHIFT
-- NON-BLOCKING
--====================================================--

task.spawn(function()

	while true do

		local target =
			s.CoreGui:FindFirstChild(
				"TargetShift",
				true
			)

		if target
		and target:IsA("ImageLabel") then

			TARGET_SHIFT = target

			-- APPLY ล่าสุดจาก DATA ทันที
			loc.applyCrosshair()

			break
		end

		task.wait(0.2)
	end

end)

--====================================================--
-- CHARACTER WATCHER
--====================================================--

task.spawn(function()

	local function bindCharacter(char)

		char.ChildAdded:Connect(function(v)

			if v:IsA("Tool") then
				task.wait()
				loc.applyCrosshair()
			end

		end)

		char.ChildRemoved:Connect(function(v)

			if v:IsA("Tool") then
				task.wait()
				loc.applyCrosshair()
			end

		end)

		task.wait()
		loc.applyCrosshair()

	end

	if player.Character then
		bindCharacter(player.Character)
	end

	player.CharacterAdded:Connect(bindCharacter)

end)

--====================================================--
-- ANTI DEFAULT OVERRIDE
-- Functions.lua กันดื้อ
--====================================================--

task.spawn(function()

	while true do

		if TARGET_SHIFT then

			local current =
				TARGET_SHIFT.Image

			-- TOOL MODE
			if loc.isToolEnabled() then

				local wanted =
					loc.getToolCrosshair()

				if current == DEFAULT_TOOL_CROSSHAIR
				and wanted ~= DEFAULT_TOOL_CROSSHAIR then

					TARGET_SHIFT.Image =
						wanted
				end

			-- NORMAL MODE
			else

				local wanted =
					loc.getNormalCrosshair()

				if current == DEFAULT_CROSSHAIR
				and wanted ~= DEFAULT_CROSSHAIR then

					TARGET_SHIFT.Image =
						wanted
				end

			end

		end

		task.wait(0.05)

	end

end)

--====================================================--
-- CUSTOM CROSSHAIR ID
--====================================================--

loc.o(
	"Custom Crosshair ID",

	255,255,255,

	true, "Type Image ID",

	true, "Save",

	nil,

	function(box, btn)

		local text =
			tostring(box.Text or "")

		-- RESET
		if text == ""
		or text == "0" then

			Data.UI.CrosshairID =
				DEFAULT_CROSSHAIR

		else

			text =
				text:gsub(
					"rbxassetid://",
					""
				)

			Data.UI.CrosshairID =
				"rbxassetid://" .. text

		end

		loc.saveData(Data)

		-- APPLY NOW
		loc.applyCrosshair()

		-- VISUAL
		btn.TextColor3 =
			Color3.fromRGB(0,255,0)

		task.delay(0.35,function()

			btn.TextColor3 =
				Color3.fromRGB(255,255,255)

		end)

	end,

	nil,

	scr
)

--====================================================--
-- CUSTOM TOOL CROSSHAIR ID
--====================================================--

loc.o(
	"Custom Tool Crosshair ID",

	255,255,255,

	true, "Type Image ID",

	true, "Save",

	nil,

	function(box, btn)

		local text =
			tostring(box.Text or "")

		-- RESET
		if text == ""
		or text == "0" then

			Data.UI.ToolCrosshairID =
				DEFAULT_TOOL_CROSSHAIR

		else

			text =
				text:gsub(
					"rbxassetid://",
					""
				)

			Data.UI.ToolCrosshairID =
				"rbxassetid://" .. text

		end

		loc.saveData(Data)

		-- APPLY NOW
		loc.applyCrosshair()

		-- VISUAL
		btn.TextColor3 =
			Color3.fromRGB(0,255,0)

		task.delay(0.35,function()

			btn.TextColor3 =
				Color3.fromRGB(255,255,255)

		end)

	end,

	nil,

	scr
)

local SoundState = false
local PainSoundId = "rbxassetid://126351915401997"

local painui


loc.UpdatePainSound = function(state)

    SoundState = state

    local char = player.Character

    if not char then
        if painui and painui.Button then
            painui.Button.Text = "No Character"
            painui.Button.TextColor3 = Color3.fromRGB(170,170,170)
        end
        return
    end


    local hrp = char:FindFirstChild("HumanoidRootPart")

    if not hrp then
        if painui and painui.Button then
            painui.Button.Text = "No HRP"
            painui.Button.TextColor3 = Color3.fromRGB(170,170,170)
        end
        return
    end


    local sounds = {}

    for _,v in ipairs(hrp:GetChildren()) do
        if v.Name == "PainNoise" and v:IsA("Sound") then
            table.insert(sounds, v)
        end
    end


    if #sounds == 0 then
        if painui and painui.Button then
            painui.Button.Text = "No Sound"
            painui.Button.TextColor3 = Color3.fromRGB(170,170,170)
        end
        return
    end


    -- Keep one PainNoise
    local sound = sounds[1]

    for i = 2, #sounds do
        sounds[i]:Destroy()
    end


    if SoundState then
        -- ON
        sound.SoundId = PainSoundId

        if painui and painui.Button then
            painui.Button.Text = "ON"
            painui.Button.TextColor3 = Color3.fromRGB(0,255,120)
        end

    else
        -- OFF
        sound.SoundId = ""

        if painui and painui.Button then
            painui.Button.Text = "OFF"
            painui.Button.TextColor3 = Color3.fromRGB(255,70,70)
        end
    end

end



painui = loc.o(
    "Pain Sound (DamageOverlay)",
    255,255,255,

    false,nil,

    true,nil,

    nil,

    function(state)
        loc.UpdatePainSound(state)
    end,

    SoundState,

    scr
)



loc.WatchPainSound = function(char)

    local hrp = char:WaitForChild("HumanoidRootPart")


    -- If PainNoise already exists
    task.spawn(function()
        local sound = hrp:WaitForChild("PainNoise", 5)

        if sound then
            loc.UpdatePainSound(SoundState)
        end
    end)


    -- If PainNoise appears later
    hrp.ChildAdded:Connect(function(child)

        if child.Name == "PainNoise" and child:IsA("Sound") then

            task.wait()

            loc.UpdatePainSound(SoundState)

        end

    end)

end



-- First spawn
if player.Character then
    loc.WatchPainSound(player.Character)
end


-- Respawn
player.CharacterAdded:Connect(function(char)

    loc.WatchPainSound(char)

end)

--======= PATH ========--
local ES
local List

task.spawn(function()

    ES = game:GetService("CoreGui")
        :WaitForChild("ExperienceSettings")
        :WaitForChild("Menu")

	task.wait(7)

    List = {
        ai = ES:WaitForChild("AIOpenSource").Frame,
        ab = ES:WaitForChild("About_Background").Inside,
        bg = ES:WaitForChild("Background"),
        hrs = ES:WaitForChild("HolderScreen"),
        lb = ES:WaitForChild("Load_Background"),
        ms = ES:WaitForChild("MiddleScreen"),
        pfs = ES:WaitForChild("ProfileStatus"),
        sh = ES:WaitForChild("Search"),
    }

end)

--======= ENGLISH ========--
--// =====================================================
--// TEXT-DETECTION LOCALIZATION ENGINE v2.1
--// Path-based translation: full Device export is the primary source.
--// =====================================================

-- HttpService uses the shared s.HttpService service reference.
-- CoreGui uses the shared s.CoreGui service reference.
-- LocalizationService uses the shared s.LocalizationService service reference.

local L = {}

local ExperienceSettings

L.CurrentLanguage = "EN"
L.SelectedLanguage = "EN"
L.latestClick = "EN"
L.Busy = false
L.Cooldown = 2
L.LastRequest = 0

L.CacheFile =
    "ExperienceSettings/translation_cache.json"

-- Static-only translation mode.
-- Local L.DB/cache/similarity is the only translation provider.
-- Roblox LocalizationService is intentionally not used for these UI texts.
L.RemoteURL = nil


L.Request =
    request
    or http_request
    or (syn and syn.request)

L.LanguageButtons = {}
L.LanguageButtonDefaultText = {}
L.LanguageButtonStatus = nil
L.RefreshLanguageButtons = nil
L.LanguageSelect = nil
L.LanguageHeader = nil
L.LanguageOptionLabels = {
    EN = "🇺🇸 English",
    ES = "🇪🇸 Español",
    TH = "🇹🇭 ไทย",
    ["PT-BR"] = "🇧🇷 Português (Brasil)",
    ["PT-PT"] = "🇵🇹 Português (Portugal)",
    RU = "🇷🇺 Русский",
    KO = "🇰🇷 한국어 (대한민국)",
}
L.LanguageValueToCode = {}
L.LanguageOrder = {"EN", "ES", "TH", "PT-BR", "PT-PT", "RU", "KO"}

-- Missing local translations are kept by language so they can be completed
-- without guessing which UI strings were skipped.
L.MissingTranslations = {}
L.MissingTranslationCountByLanguage = {}
L.LastMissingTranslationCount = 0

-- Language selector timing UI.
-- Working... shows elapsed whole seconds while translation is running.
-- Done! shows the final WorkingSeconds before waiting PauseSeconds, then Selected.
L.WorkingSeconds = 0
L.PauseSeconds = 1
L.LanguageButtonTimerGeneration = 0

L.Source =
    setmetatable({}, {__mode = "k"})

L.Applied =
    setmetatable({}, {__mode = "k"})

-- Tracks exactly which language/source produced the currently applied text.
-- This lets the translator skip objects that are already translated.
L.AppliedMeta =
    setmetatable({}, {__mode = "k"})

-- Translation queue state. Work is spread across frames so a full translation
-- pass does not block the game for a long continuous period.
L.TranslationGeneration = 0
L.TranslationRunning = false

L.Canonical =
    setmetatable({}, {__mode = "k"})

L.CanonicalTemplate =
    setmetatable({}, {__mode = "k"})

L.Connections =
    setmetatable({}, {__mode = "k"})

L.PathSources = {
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.Holder.z8_ChatGPT.NewMessage|Text"] = "0",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.Holder.LoadFrame[\"Warning & Load\"]|Text"] = "The ExperienceSettings has been deactivated for some reason.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[3].Description|Text"] = "The most powerful admin commands.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[3].Title|Text"] = "<b>Infinite yield (@edge.egg | discord)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[3].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[3].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[4].Description|Text"] = "A keyboard for mobile. Crack by Ata",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[4].Title|Text"] = "<b>Delta Keyboard (@sakura)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[4].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[4].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[5].Description|Text"] = "Not my script but Ill actively update it with new features. Includes optimization + rspy plugin!",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[5].Title|Text"] = "<b>Dex++ (@mcdaggitt)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[5].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[5].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[6].Description|Text"] = "Universal script allows you to tp to players, also lets you fling them and many more.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[6].Title|Text"] = "<b>RoChip (@83937293938381929383)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[6].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[6].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[7].Description|Text"] = "lets you copy everything right in the native console interface (/console OR F9)",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[7].Title|Text"] = "<b>ConsoleCopyButton (@Lordi_scripts)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[7].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[7].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[8].Description|Text"] = "Take your Roblox experience to the next level by listening to your favorite  music or watching YouTube videos while you play.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[8].Title|Text"] = "<b>YouTube Music Player V8 (@Turmux404)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[8].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[8].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[9].Description|Text"] = "yet another random hub menu.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[9].Title|Text"] = "<b>YARHM - MM2, FTF, Forsaken, CNA Sim, etc. (@Imperial)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[9].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[9].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[10].Description|Text"] = "Introducing AFEM Max, the powerful AFEM you know and love and now EVEN MORE supercharged!",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[10].Title|Text"] = "<b>AFEM MAX - 40K EMOTES SCRIPT BEST (@Imperial)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[10].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[10].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[11].Description|Text"] = "The best Remote Spy (and not only) in Roblox's history after being developed for.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[11].Title|Text"] = "<b>Ketamine (@Kawi)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[11].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[11].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[12].Description|Text"] = "The Updated UNC Test, Since the old UNC test checks for getfenv(0) and not getgenv()",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[12].Title|Text"] = "<b>UNC Test (@vxsty)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[12].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[12].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[13].Description|Text"] = "Credits to @yourfriendfromschool1 for the script idea.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[13].Title|Text"] = "<b>MoreUNC (@vxsty)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[13].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[13].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[14].Description|Text"] = "An improvised version of MoreUNC! Gets around 52 to 53% UNC on Roblox Studio (Roblox studio has 0%)",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[14].Title|Text"] = "<b>MoreUNC V2 (@vxsty)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[14].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[14].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[15].Description|Text"] = "MoreUNC v3, the newest version of moreunc, with less functions, but more complex functions.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[15].Title|Text"] = "<b>MoreUNC V3 (@vxsty)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[15].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[15].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[16].Description|Text"] = "HAVE BUGS FOR NOW; added random avatars; Apply with username-ids, and u can add to favorites.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[16].Title|Text"] = "<b>Universal avatar changer free (@byted)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[16].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[16].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[17].Description|Text"] = "New FE Script for Free  Animation Bundles in Roblox. As you may know, Roblox recently introduced custom UGC  animation bundles",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[17].Title|Text"] = "<b>FREE BUNDLES and EMOTES l FE (@Bac0nH1ckOff)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[17].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[17].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[18].Description|Text"] = "cyan dot = predicted pos; yellow line = trajectory; green line = velocity; red = landing spot",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[18].Title|Text"] = "<b>universal movement predictor (@koboldpaws)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[18].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[18].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[19].Description|Text"] = "works with any ugc with the name \"tail\" in it",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[19].Title|Text"] = "<b>physics based tail animator (@koboldpaws)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[19].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[19].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[20].Description|Text"] = "Removes gameplay puased",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[20].Title|Text"] = "<b>Anti GamePlay Paused (@sillzchibi)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[20].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[20].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[21].Description|Text"] = "Admin commands; More than 280+ admin commands; This is a reworked version no bugs found; Better than old nameless admin and inf yeild.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[21].Title|Text"] = "<b>Nameless admin REWORKED (@Screatkin)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[21].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[21].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[22].Description|Text"] = "Nameless Admin is a universal admin script, that has over 300+ commands.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[22].Title|Text"] = "<b>Nameless admin (@Stars)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[22].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[22].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[23].Description|Text"] = "K to open/close; a script i modded and replaced unworking stuff.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[23].Title|Text"] = "<b>Orca modded (@moma1133222)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[23].Execute|Text"] = "Execute",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.TopBar.TopButtons:GetChildren()[23].Copy|Text"] = "Copy",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.ExperienceName|Text"] = "[UP] Just a baseplate.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.Pmax.Players|Text"] = "Player :",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.Pmax.PlayerCount|Text"] = "7/22",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.Pmax.SeeAll|Text"] = "A button that doesn't do NOTHING",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.Buttons.Leave|Text"] = "Leave The Experience",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.Buttons[\"Reset character\"]|Text"] = "Reset character",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.Buttons.Resume|Text"] = "Resume",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame1.Bar.ToggleButton|Text"] = "ON",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame1.Label|Text"] = "Enable ValueLabels",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame1.Label.Description|Text"] = "<b><u>ValueLabel</u></b>\nShow ValueLabel at the Top HealthBar.\n• FPS - Frame Per second\n• HP - Health ( How to read: 100.000 HP = 100 HP )\n• WS/s - Walkspeed per studs ( How to read: 16.000 WS/s = 16 WS/s )",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame2.Bar.ToggleButton|Text"] = "OFF",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame2.Label|Text"] = "Shaders - Sunset",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame2.Label.Description|Text"] = "<b><u>Shaders</u></b>\nWhat a beautiful sunset!\nGraphic quality recommend 6+",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame3.Bar.ToggleButton|Text"] = "OFF",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame3.Label|Text"] = "White Light",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame3.Label.Description|Text"] = "<b><u>White Light</u></b>\nJust a PointLight around the you.\nUseful in the dark.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame4.Bar.ToggleButton|Text"] = "OFF",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame4.Label|Text"] = "RGB Light",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame4.Label.Description|Text"] = "<b><u>RGB Light</u></b>\nSame as White Light, but RGB.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame5.Bar.ToggleButton|Text"] = "OFF",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame5.Label|Text"] = "ESP",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame5.Label.Description|Text"] = "<b><u>ESP</u></b>\nSee all players around the map.\nAlso TextLabel will change color following team color.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame6.Bar.ToggleButton|Text"] = "ON",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame6.Label|Text"] = "Damage Overlay <stroke color='rgb(255,255,255)' thickness='1'><font color='#ff5555'><b>⚠ READ DESCRIPTION BY PRESSING HERE ⚠</b></font></stroke>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame6.Label.Description|Text"] = "<b><u>Damage Overlay</u></b>\nDisplays visual damage effects when your character takes damage.\n\n<stroke color=\"rgb(255,0,0)\" thickness=\"1\">\n<font color=\"#ff5555\">\n<b>⚠ Photosensitive Epilepsy Warning</b>\n\nThis effect may contain:\n• Flashing lights\n• Rapid brightness changes\n• Screen color pulses\n\nIf you experience dizziness, eye strain, or discomfort,\nplease turn this feature <b>OFF</b> immediately.\n</font></stroke>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame7.Bar.ToggleButton|Text"] = "ON",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame7.Label|Text"] = "MoreToggles",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Settings.B_Frame.Frame7.Label.Description|Text"] = "<b><u>MoreToggles</u></b>\nOpen second toggle menu.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame:GetChildren()[2].Bar.ToggleButton|Text"] = "OFF",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame:GetChildren()[2].Label|Text"] = "LighterCyan.ai (Discontinued)",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame:GetChildren()[2].Label.Description|Text"] = "<b><u>LighterCyan.ai</u></b>\nIt's discontinued bro.\n😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame:GetChildren()[3].Bar.ToggleButton|Text"] = "ON",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame:GetChildren()[3].Label|Text"] = "HealthBar",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame:GetChildren()[3].Label.Description|Text"] = "<b><u>HealthBar</u></b>\nShow HealthBar at the Top Right.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame:GetChildren()[4].Bar.ToggleButton|Text"] = "OFF",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame:GetChildren()[4].Label|Text"] = "Disable Death Sound",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame:GetChildren()[4].Label.Description|Text"] = "<b><u>Death Sound</u></b>\nPlay sound after character dead.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame4.Bar.ToggleButton|Text"] = "OFF",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame4.Label|Text"] = "FreeCam (Mobile)",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame4.Label.Description|Text"] = "<b><u>FreeCam</u></b>\n\tExplore around the world with FreeCam! (Mobile Only)",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame5.Bar.ToggleButton|Text"] = "OFF",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame5.Label|Text"] = "Almost Endless Fallen (-50K)",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame5.Label.Description|Text"] = "<b><u>Almost Endless Fallen</u></b>\nSet FallenPartDestroyHeight at -50000.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame6.Bar.ToggleButton|Text"] = "OFF",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame6.Label|Text"] = "Flashlight",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame6.Label.Description|Text"] = "<b><u>Flashlight</u></b>\nIt will make you in the first person with light, and also recommend set graphic quality at 6+",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame7.Bar.ToggleButton|Text"] = "OFF",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame7.Label|Text"] = "ESP Highlight Players & Non-Players",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame7.Label.Description|Text"] = "<b><u>ESP Highlight Players & Non-Players</u></b>\nIt will highlight HumanoidRootPart. Players is <font color=\"rgb(0,255,0)\">green</font> and Non-Players is <font color=\"rgb(255,10,10)\">red</font>.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame8.Bar.ToggleButton|Text"] = "OFF",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame8.Label|Text"] = "Shift Lock (Mobile)",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame8.Label.Description|Text"] = "<b><u>Shift Lock</u></b>\nShift Lock for Mobile players. Also you can CUSTOMIZE CROSSHAIR by open <b>Settings - 2</b> in <b>Settings - Loader Rejoiner</b>!",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame9.Bar.ToggleButton|Text"] = "OFF",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame9.Label|Text"] = "Hitbox Shower",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame9.Label.Description|Text"] = "<b><u>Hitbox Shower</u></b>\nSee all hitbox players \n(Using ViewportFrame)",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame10.Bar.ToggleButton|Text"] = "OFF",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame10.Label|Text"] = "Last Death",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame10.Label.Description|Text"] = "<b><u>Last Death</u></b>\nIt will show last position where you die at\nas a frozen ghost character...",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame11.Bar.ToggleButton|Text"] = "OFF",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame11.Label|Text"] = "ServerPositionPredictor (By @zephyrr)",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame.Frame11.Label.Description|Text"] = "<b><u>ServerPositionPredictor</u></b>\nShowing between Server and Client.\nServer is a second character of you. (Displaying as like ping)\nClient is you.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame:GetChildren()[13].Bar.ToggleButton|Text"] = "OFF",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame:GetChildren()[13].Label|Text"] = "Show Physics",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame:GetChildren()[13].Label.Description|Text"] = "<b><u>Show Physics</u></b>\nDisplays colorful trajectory lines (\"player speedometers\") and landing prediction points showing where your character is expected to land.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame:GetChildren()[14].Bar.ToggleButton|Text"] = "OFF",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame:GetChildren()[14].Label|Text"] = "Global Physics",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame:GetChildren()[14].Label.Description|Text"] = "<b><u>Global Physics</u></b>\nSame as Show Physics Toggle, but you're just seeing the physics of other players and objects too.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame:GetChildren()[15].Bar.ToggleButton|Text"] = "OFF",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame:GetChildren()[15].Label|Text"] = "Relax / Gif Animation Editor",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Background.Inner_Background.Toggles.B_Frame:GetChildren()[15].Label.Description|Text"] = "<b><u>Gif Animation Editor</u></b>\nShow or hide the Gif Animation Editor window.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Load_Background.Loading|Text"] = "Loading",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Load_Background.Wait|Text"] = "Starting ExperienceSettings. Please wait...",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Load_Background.Credit|Text"] = "Creator by @5teve3019D on ScriptBlox/HaxHell",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Load_Background.Skip|Text"] = "Close fuc#king annoying load bar",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.About_Background.Inside[\"Discord link\"]|PlaceholderText"] = "",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.About_Background.Inside[\"Inside.2\"].a2_txts:GetChildren()[1]|Text"] = "@5teve3019D",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.About_Background.Inside[\"Inside.2\"].a2_txts:GetChildren()[2]|Text"] = "“Creator of the ExperiencSettings.”",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.About_Background.Inside[\"Inside.2\"].a2_txts:GetChildren()[3]|Text"] = "[ User on ScriptBlox/HaxHell ]",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.About_Background.Inside.Scroll.About|Text"] = "The ExperienceSettings is debug tools you can use on your own, there are a lot of tools!\nFor HealthBar was a remake of better and smoother and ValueLabels for show values.\nIf your ExperienceSettings was Disabled there are three reasons,\n • HumanoidRootPart was removed too long.\n • The Experience doesn't support the ExperienceSettings.\n • Script failed to load.\nIf you enjoy it, you can support me on discord!\nThank you for using ExperienceSettings! ♥️\n\n54% Gui is made by hand\n10% Script is made by hand\n36% Script is made by ai\n\nCreator: @5teve3019D (Gui, Little Script)\nHelper: ChatGPT (Script) <-- He got a lot of complaints lol.\nLittle Helper: Copilot of GitHub (Script)\nFun fact: Old is ugly than now lol I swear 😂 Oh, you haven't seen it :(\n\n========================\n➕ = Add something\n📢 = Announcements\n🔨 = In-develop\n🔷 = Plan ahead for updates\n✅ = Done\n⚠️ = Have issues\n🟠 = Updating soon\n❌ = Bug\n⚫ = Cannot fix\n➖ = Disconnected or discontinued\n-------\n📌 Updated: Update in this information is no longer appear now, please join our discord community to following update!\n-------\n🔁 In progress: No longer appear features\n-------\n❌ Failed: No longer appear unavailable features\n-------\n\n✨ SCRIPT CREDITS ✨\n[ Script Name ] by [ Creator ] [ Verification Status ]\n\nWe want to say that your script is awesome, and it is used in our project for debugging and educational purposes.\nThank you for your contribution :3 ❤️\n- Debugger\n\n-- Credits List --\n'Ketamine' by @Cherry (✓ Verified)\n'OG AFEM – Legacy' by @Imperial (✓ Verified)\n'Chat' by Unknown user\n'UNC' by Unknown user\n'REM' by @evildotcom (X Not verified)\n'GameProber' by @Imperial (✓ Verified)\n'AudioPlayer' by Unknown user\n'EmoteSelect' by Unknown user\n'Universal Movement Predictor' by @zephyrr (X Not verified)\n'Server Position Predictor' by @zephyrr (X Not verified)\n'Open Source Universal Chat' by @neutral (X Not verified)\n\n-- Notice to Script Creators --\nIf you are a script creator listed above and do not want your script to be included,\nplease contact us via our Discord forum, and we will remove it immediately.\n",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.About_Background.Inside.Help|Text"] = "Oh, if the ExperienceSettings was disabled. You can hide the text by click the button.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.About_Background.Inside.Hide|Text"] = "Hide",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.HolderScreen.Relax.Settings|Text"] = "Settings",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.HolderScreen.Relax.Dragger|Text"] = "Drag",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.HolderScreen.Relax.Editor[\"TextLabel-editor\"]|Text"] = "<u><b>Editor</b></u>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.HolderScreen.Relax.Editor.Idle.AddIdle|Text"] = "+",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.HolderScreen.Relax.Editor[\"TextLabel-idle\"]|Text"] = "Idle",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.HolderScreen.Relax.Editor[\"TextLabel-idle\"].ClearIdle|Text"] = "Clear All Idle",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.HolderScreen.Relax.Editor[\"TextLabel-WhenClick\"]|Text"] = "When Click",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.HolderScreen.Relax.Editor[\"TextLabel-WhenClick\"].ClearWhenClick|Text"] = "Clear All When Click",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.HolderScreen.Relax.Editor.WhenClick.AddWhenClick|Text"] = "+",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.HolderScreen.Relax.Editor[\"TextLabel-FrameRate\"]|Text"] = "Frame Rate",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.HolderScreen.Relax.Editor.Idle_FPS|PlaceholderText"] = "Idle's FPS",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.HolderScreen.Relax.Editor.WhenClick_FPS|PlaceholderText"] = "When Click's FPS",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.HolderScreen.Relax.Editor[\"TextLabel-Idle-FrameRate\"]|Text"] = "Idle Frame Rate",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.HolderScreen.Relax.Editor[\"TextLabel-WhenClick-FrameRate\"]|Text"] = "When Click Frame Rate",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.HolderScreen.Relax.Editor.Save|Text"] = "Save",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.HolderScreen.Relax.Editor.GetcustomassetSwitch.Getdevicepathinput|PlaceholderText"] = "Example: 'Folder/'",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.HolderScreen.Relax.Editor.GetcustomassetSwitch.GetSwitch|Text"] = "Image",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.HolderScreen.Relax.Editor[\"Textlabel-Credit\"]|Text"] = "Relax / Gif Animation Editor by <font color='rgb(85,255,255)'>5teve3019D</font>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.HolderScreen.Relax.Editor.MoreMenu|Text"] = "• • •",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Holder.Username|Text"] = "<b>ExperienceSettings</b> (@ExperienceSettings)",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll:GetChildren()[5]|Text"] = "-- <b>Texts</b> --",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll:GetChildren()[6]|Text"] = "-- <b>Buttons</b> --",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.PlayerID|Text"] = "PlayerID: 10640542665",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.FriendCount|Text"] = "Friends in the server: 0",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.PlayerAge|Text"] = "PlayerAge: 189 day",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.PlayerBirth|Text"] = "PlayerBirth: 08/03/2026",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.CameraMode|Text"] = "CameraMode: Enum.CameraMode.Classic",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.PlaceID|Text"] = "PlaceID: 123974602339071",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.CreatorName|Text"] = "Creator: The Local Maze",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.CreatorID|Text"] = "CreatorID: 34901800",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.AFK|Text"] = "AFK: 00:00 | LastAFK: 00:03",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.PlayingTime|Text"] = "PlayingTime: 000:00:03:22",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.RealTimeClock|Text"] = "Real Time Clock: 14:32:12",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.WalkSpeed|Text"] = "WalkSpeed: 16",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.JumpPower|Text"] = "JumpPower: 50",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.Damage|Text"] = "BestDamage: 0 | LastDamage: 0",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.Heal|Text"] = "BestHeal: 0 | LastHeal: 0",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.Deaths|Text"] = "Deaths: 0",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.Inventory|Text"] = "Tools: 0",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.HoldingTool|Text"] = "HoldingTool: none",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.MaxHealth|Text"] = "MaxHealth: 100",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.StandingOn|Text"] = "StandingOn: Plastic",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.PositionOfCharacter|Text"] = "Position: X: -54.36 | Y: 3.00 | Z: -49.11",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.CharacterType|Text"] = "CharacterType: R15",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.TimeOfDay|Text"] = "TimeOfDay: 14:00:00",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.DeveloperConsole|Text"] = "Open Developer console",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.DropTool|Text"] = "Drop Tool",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.ProfileCharacter.Scroll.DropTools|Text"] = "Drop all tools",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.Debugs[\"Sorry!\"]|Text"] = "Debugs page is <b><u>not</u></b> done yet.\nTry to press the button at the top right.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.MusicPlayer[\"Sorry!\"]|Text"] = "Music Player page is <b><u>not</u></b> done yet.\nTry to press the button at the top right. Yeah bro, you're not in the loop stop pressing the button.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.MusicPlayer.Display.MusicName|Text"] = "Untitled Song",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.MusicPlayer.Display.PlayButton|Text"] = "<b>▶</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.ProfileStatus.InsideProfileStatus.SwitchButton|Text"] = "1",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.AIOpenSource.Frame.Text.chat|PlaceholderText"] = "Type /Help to show all commands or Say something...",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.AIOpenSource.Frame.Text.Send|Text"] = "✓",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.AIOpenSource.Frame.Text.Clear|Text"] = "X",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.AIOpenSource.Frame.Topic|Text"] = "<b><stroke color='rgb(85,255,255)' thickness='2'>AI-Thinking</stroke></b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.AIOpenSource.Frame.ver|Text"] = "Version:<b> UIs 6.929.2 </b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.AIOpenSource.Frame.Unavailable|Text"] = "<b><stroke color='rgb(255,100,100)' thickness='1' transparency='0'>UNAVAILABLE FEATURES (Old)</stroke></b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.AIOpenSource.Frame.api|PlaceholderText"] = "[ Your API here (ChatGPT or Gemini) ]",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.AIOpenSource.Frame.Confirm_api|Text"] = "Confirm API",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.AIOpenSource.Frame.Unsaved_API|Text"] = "Unsaved API",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.AIOpenSource.Frame.Status|Text"] = "Status: Unknown",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.SearchInput|PlaceholderText"] = "Search here!",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody:GetChildren()[3]|Text"] = "<b>Script Type (Default/Free/Paid)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody:GetChildren()[3].Switch|Text"] = "",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody:GetChildren()[4]|Text"] = "<b>Universal</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody:GetChildren()[4].Switch|Text"] = "",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody:GetChildren()[5]|Text"] = "<b>Verified</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody:GetChildren()[5].Switch|Text"] = "",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody:GetChildren()[6]|Text"] = "<b>Patched</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody:GetChildren()[6].Switch|Text"] = "",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody:GetChildren()[7]|Text"] = "<b>Key</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody:GetChildren()[7].Switch|Text"] = "",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody.SortContainer.SortBy|Text"] = "<b>Sort by: Default</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody.SortContainer.SortOrder|Text"] = "<b>Sort order: Default</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody.CreatorInput|PlaceholderText"] = "Input: Creator...",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody.GameInput|PlaceholderText"] = "Input: Game ID",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody.TypeOfAnAPI|Text"] = "<b>Search API: ScriptBlox</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody.Back|Text"] = "Switch back to the <b>Current version</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody.Preview|Text"] = "Switch to the <b>Preview version</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.Scrips[\"Sorry!\"]|Text"] = "<font size=\"50\" color=\"rgb(255,0,0)\">Sorry!</font> \n We are making the UI better than before and mobile friendly! \n <font size=\"10\">From White the creator</font>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.Scrips.Body.State.Verified|Text"] = "<b>Verified</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.Scrips.Body.State.Key|Text"] = "<b>Key</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.Scrips.Body.State.Patched|Text"] = "<b>Patched</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.Scrips.Body.State.Free|Text"] = "<b>Free</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.Scrips.Body.State.Paid|Text"] = "<b>Paid</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.Scrips.Body.Details|Text"] = "<font size='12'><b>Script Title</b></font>\nUniversal Script 📌\nBy @API Not supported\nClick 'View' for more details.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.Scrips.Body.ViewButton|Text"] = "<b><i>View</i></b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.List.Scrips.Body.BookmarkButton|Text"] = "<b><i>Bookmark</i></b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.NameOfScriptTitle|Text"] = "<b>Script Title</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.TypeScript|Text"] = "📌 Universal Script",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.Creator|Text"] = "By @Username",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.CreationDate|Text"] = "Creation Date: DD/MM/YYYY",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.Likes|Text"] = "<b>Like: -</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.Dislikes|Text"] = "<b>Dislike: -</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.Visits|Text"] = "<b>Visit: -</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.Features|Text"] = "<b>Description</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.FeaturesScroll.FeaturesBox|PlaceholderText"] = "No description yet.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.Tags|Text"] = "<b>Tag</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.RawScript|Text"] = "<b>Raw Script</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.CodeScroll.CodeBox|PlaceholderText"] = "Hmm... Looks like there's no source code in here. Please make sure you select the script or the owner didn't put a source code yet.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.Execute|Text"] = "<b>Execute</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.Copy|Text"] = "<b>Copy To Clipboard</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.ClosePage|Text"] = "<b>Back »</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.Bookmark.ViewBookmark.CloseBookmark|Text"] = "<b>Back »</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.Bookmark.ViewBookmark.BookmarkTopic|Text"] = "<b>Bookmark page</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.Bookmark.ViewBookmark.BookmarList.Body.Title|Text"] = "<b>Script Title (discontinued but working)</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.Bookmark.ViewBookmark.BookmarList.Body.Source|Text"] = "From: Source",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.Bookmark.ViewBookmark.BookmarList.Body.Execute|Text"] = "<b>Execute</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.Bookmark.ViewBookmark.BookmarList.Body.Copy|Text"] = "<b>Copy</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.Bookmark.ViewBookmark.BookmarList.Body.View|Text"] = "<b>View</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.Search.Page.Bookmark.ViewBookmark.BookmarList.Body.Remove|Text"] = "<b>Remove from the bookmark page</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.PopUp.Scroll.Thank|Text"] = "<b><font size=\"12\">Happy 1st Anniversary of The ExperienceSettings!</font></b>\nWe want to let you know for those who using our script; we want to say <b>thank you for using our script!</b> \n \nTo close this <b>GUI</b> you can simply click <b><font size=\"9\">\"Remind me later.\"</font></b> or <b><font size=\"9\">\"Dont show this again.\"</font></b> button to continue use The ExperienceSettings.",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.PopUp.FrameOfButtons.RemindMeLater|Text"] = "<b>Remind Me Later</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings.Menu.PopUp.FrameOfButtons.Close|Text"] = "<b>Don't show this again</b>",
    ["game:GetService(\"CoreGui\").ExperienceSettings[\"LighterCyan.ai\"].Holder.InsetFrame[\"a3_Input&Send\"].Ask|PlaceholderText"] = "Ask anything...",
    ["game:GetService(\"CoreGui\").ExperienceSettings[\"LighterCyan.ai\"].Holder.InsetFrame[\"a3_Input&Send\"].Send|Text"] = "✓",
    ["game:GetService(\"CoreGui\").ExperienceSettings[\"LighterCyan.ai\"].Holder.InsetFrame[\"a3_Input&Send\"].clear|Text"] = "×",
    ["game:GetService(\"CoreGui\").ExperienceSettings[\"LighterCyan.ai\"].Holder.InsetFrame[\"a3_Input&Send\"][\"re-chat\"]|Text"] = "re-chat",
    ["game:GetService(\"CoreGui\").ExperienceSettings[\"LighterCyan.ai\"].Holder.InsetFrame.a1_option[\"a1.logo\"].Text|Text"] = "LighterCyan",
    ["game:GetService(\"CoreGui\").ExperienceSettings[\"LighterCyan.ai\"].Holder.InsetFrame.a1_option[\"a2.Chat\"].TextButton|Text"] = "🗨️ Chat",
    ["game:GetService(\"CoreGui\").ExperienceSettings[\"LighterCyan.ai\"].Holder.InsetFrame.a1_option[\"a3.Settings\"].TextButton|Text"] = "⚙️ Settings",
    ["game:GetService(\"CoreGui\").ExperienceSettings[\"LighterCyan.ai\"].Holder.InsetFrame.a1_option[\"a4.Explorer\"].TextButton|Text"] = "🌏 Explorer",
    ["game:GetService(\"CoreGui\").ExperienceSettings[\"LighterCyan.ai\"].Holder.InsetFrame.a1_option[\"a5.About\"].TextButton|Text"] = "📜 About",
    ["game:GetService(\"CoreGui\").ExperienceSettings[\"LighterCyan.ai\"].Holder.InsetFrame.a1_option[\"a6.Executor\"].TextButton|Text"] = "✏️ Executor",
    ["game:GetService(\"CoreGui\").ExperienceSettings[\"LighterCyan.ai\"].Holder.InsetFrame.a1_option[\"a7.SaveScript\"].TextButton|Text"] = "📂 SaveScript",
    ["game:GetService(\"CoreGui\").ExperienceSettings[\"LighterCyan.ai\"].Holder.InsetFrame.a1_option[\"z9.More\"].TextButton|Text"] = "📦 More",
}

L.LocaleMap = {
    ["EN"] = "en-us",
    ["ES"] = "es",
    ["TH"] = "th",
    ["PT-BR"] = "pt-br",
    ["PT-PT"] = "pt-pt",
    ["RU"] = "ru",
    ["KO"] = "ko",
}

L.Translators = {}
L.Ready = {}

L.Cache = {
    ["EN"] = {},
    ["ES"] = {},
    ["TH"] = {},
    ["PT-BR"] = {},
    ["PT-PT"] = {},
    ["RU"] = {},
    ["KO"] = {},
}

L.DB = {
    ["ES"] = {
        ["Type /Help to show all commands or Say something..."] = "Escribe /Help para mostrar todos los comandos o di algo...",
        ["Confirm API"] = "Confirmar API",
        ["Unsaved API"] = "API no guardada",
        ["[ Your API here (ChatGPT or Gemini) ]"] = "[ Tu API aquí (ChatGPT o Gemini) ]",
        ["Status: No key"] = "Estado: Sin clave",
        ["<b><stroke color='rgb(85,255,255)' thickness='2'>AI-Thinking</stroke></b>"] = "<b><stroke color='rgb(85,255,255)' thickness='2'>Pensamiento IA</stroke></b>",
        ["<b><stroke color='rgb(255,100,100)' thickness='1' transparency='0'>UNAVAILABLE FEATURES (Old)</stroke></b>"] = "<b><stroke color='rgb(255,100,100)' thickness='1' transparency='0'>FUNCIONES NO DISPONIBLES (Antiguas)</stroke></b>",
        ["\nThe ExperienceSettings is debug tools you can use on your own, there are a lot of tools!\nFor HealthBar was a remake of better and smoother and ValueLabels for show values.\nIf your ExperienceSettings was Disabled there are three reasons,\n • HumanoidRootPart was removed too long.\n • The Experience doesn't support the ExperienceSettings.\n • Script failed to load.\nIf you enjoy it, you can support me on discord!\nThank you for using ExperienceSettings! ♥️\n\n54% Gui is made by hand\n10% Script is made by hand\n36% Script is made by ai\n\nCreator: @5teve3019D (Gui, Little Script)\nHelper: ChatGPT (Script) <-- He got a lot of complaints lol.\nLittle Helper: Copilot of GitHub (Script)\nFun fact: Old is ugly than now lol I swear 😂 Oh, you haven't seen it :(\n\n========================\n➕ = Add something\n📢 = Announcements\n🔨 = In-develop\n🔷 = Plan ahead for updates\n✅ = Done\n⚠️ = Have issues\n🟠 = Updating soon\n❌ = Bug\n⚫ = Cannot fix\n➖ = Disconnected or discontinued\n-------\n📌 Updated: Update in this information is no longer appear now, please join our discord community to following update!\n-------\n🔁 In progress: No longer appear features\n-------\n❌ Failed: No longer appear unavailable features\n-------\n\n✨ SCRIPT CREDITS ✨\n[ Script Name ] by [ Creator ] [ Verification Status ]\n\nWe want to say that your script is awesome, and it is used in our project for debugging and educational purposes.\nThank you for your contribution :3 ❤️\n- Debugger\n\n-- Credits List --\n'Ketamine' by @Cherry (✓ Verified)\n'OG AFEM – Legacy' by @Imperial (✓ Verified)\n'Chat' by Unknown user\n'UNC' by Unknown user\n'REM' by @evildotcom (X Not verified)\n'GameProber' by @Imperial (✓ Verified)\n'AudioPlayer' by Unknown user\n'EmoteSelect' by Unknown user\n'Universal Movement Predictor' by @zephyrr (X Not verified)\n'Server Position Predictor' by @zephyrr (X Not verified)\n'Open Source Universal Chat' by @neutral (X Not verified)\n\n-- Notice to Script Creators --\nIf you are a script creator listed above and do not want your script to be included,\nplease contact us via our Discord forum, and we will remove it immediately.\n"] = "\nExperienceSettings es una herramienta de depuración que puedes usar por tu cuenta; ¡tiene muchas herramientas!\nHealthBar fue un remake más fluido y mejor, y ValueLabels sirve para mostrar valores.\nSi tu ExperienceSettings está deshabilitado, hay tres razones:\n • El HumanoidRootPart fue eliminado hace demasiado tiempo.\n • El Experience no admite ExperienceSettings.\n • El script no pudo cargarse.\nSi te gusta, ¡puedes apoyarme en Discord!\n¡Gracias por usar ExperienceSettings! ♥️\n\n54% de la GUI está hecha a mano\n10% del script está hecho a mano\n36% del script está hecho con IA\n\nCreador: @5teve3019D (GUI, pequeño script)\nAyudante: ChatGPT (Script) <-- Sí, recibió muchas quejas jaja.\nPequeño ayudante: Copilot de GitHub (Script)\nDato curioso: lo antiguo es más feo que lo de ahora jajaja, te lo juro 😂 Ah, no has visto lo de antes :(\n\n========================\n➕ = Añadir algo\n📢 = Anuncios\n🔨 = En desarrollo\n🔷 = Plan para futuras actualizaciones\n✅ = Hecho\n⚠️ = Tiene problemas\n🟠 = Pronto se actualizará\n❌ = Error\n⚫ = No se puede arreglar\n➖ = Desconectado o descontinuado\n-------\n📌 Actualizado: esta información ya no aparece en las actualizaciones; ¡por favor únete a nuestra comunidad de Discord para seguirlas!\n-------\n🔁 En progreso: funciones que ya no aparecen\n-------\n❌ Fallado: funciones no disponibles que ya no aparecen\n-------\n\n✨ CRÉDITOS DEL SCRIPT ✨\n[ Nombre del script ] por [ Creador ] [ Estado de verificación ]\n\nQueremos decir que tu script es increíble y se usa en nuestro proyecto para depuración y fines educativos.\nGracias por tu contribución :3 ❤️\n- Debugger\n\n-- Lista de créditos --\n'Ketamine' por @Cherry (✓ Verificado)\n'OG AFEM – Legacy' por @Imperial (✓ Verificado)\n'Chat' por usuario desconocido\n'UNC' por usuario desconocido\n'REM' por @evildotcom (X No verificado)\n'GameProber' por @Imperial (✓ Verificado)\n'AudioPlayer' por usuario desconocido\n'EmoteSelect' por usuario desconocido\n'Universal Movement Predictor' por @zephyrr (X No verificado)\n'Server Position Predictor' por @zephyrr (X No verificado)\n'Open Source Universal Chat' por @neutral (X No verificado)\n\n-- Aviso para creadores de scripts --\nSi eres creador de uno de los scripts mencionados arriba y no quieres que tu script esté incluido,\npor favor contáctanos a través de nuestro foro de Discord y lo eliminaremos de inmediato.\n",
        ["Hide"] = "Ocultar",
        ["Oh, if the ExperienceSettings was disabled. You can hide the text by click the button."] = "Oh, si ExperienceSettings está deshabilitado, puedes ocultar el texto pulsando el botón.",
        ["Leave"] = "Salir",
        ["Reset character"] = "Reiniciar personaje",
        ["Resume"] = "Continuar",
        ["Open Roblox Settings"] = "Abrir configuración de Roblox",
        ["Player :"] = "Jugador :",
        ["Enable ValueLabels"] = "Activar ValueLabels",
        ["Shaders - Recommend graphics 5+"] = "Shaders - Se recomiendan gráficos 5+",
        ["White Light"] = "Luz blanca",
        ["RGB Light"] = "Luz RGB",
        ["ESP (Beta)"] = "ESP (Beta)",
        ["Damage Overlay <stroke color='rgb(255,255,255)' thickness='1'><font color='#ff5555'><b>⚠ READ DESCRIPTION BY PRESSING HERE ⚠</b></font></stroke>"] = "Superposición de daño <stroke color='rgb(255,255,255)' thickness='1'><font color='#ff5555'><b>⚠ PRESIONA AQUÍ PARA LEER LA DESCRIPCIÓN ⚠</b></font></stroke>",
        ["MoreToggles"] = "Más toggles",
        ["LighterCyan.ai (Discontinued)"] = "LighterCyan.ai (Descontinuado)",
        ["Show Physics"] = "Mostrar física",
        ["Last Death"] = "Última muerte",
        ["ServerPositionPredictor (By @zephyrr)"] = "ServerPositionPredictor (Por @zephyrr)",
        ["Enable HealthBar"] = "Activar HealthBar",
        ["Global Physics"] = "Física global",
        ["Disable Death Sound"] = "Desactivar sonido de muerte",
        ["FreeCam (Mobile)"] = "FreeCam (Móvil)",
        ["Almost Endless Fallen (-50K)"] = "Caída casi interminable (-50K)",
        ["Flashlight (FirstPerson & GFX 6+)"] = "Linterna (Primera persona y GFX 6+)",
        ["ESP Highlight Players & Non-Players"] = "ESP resalta jugadores y no jugadores",
        ["Shift Lock (Mobile)"] = "Shift Lock (Móvil)",
        ["Hitbox Shower"] = "Lluvia de hitboxes",
        ["Shaders - Sunset"] = "Shaders - Atardecer",
        ["ESP"] = "ESP",
        ["HealthBar"] = "HealthBar",
        ["Flashlight"] = "Linterna",
        ["Relax / Gif Animation Editor"] = "Editor de animaciones Relax / Gif",
        ["Close fuc#king annoying load bar"] = "Cerrar barra de carga molesta",
        ["Creator by @5teve3019D on ScriptBlox/HaxHell"] = "Creador por @5teve3019D en ScriptBlox/HaxHell",
        ["Loading"] = "Cargando",
        ["Starting ExperienceSettings. Please wait..."] = "Iniciando ExperienceSettings. Por favor espera...",
        ["It might have bug and it still in beta."] = "Podría tener errores y todavía está en beta.",
        ["Open Developer console"] = "Abrir consola de desarrollador",
        ["Drop Tool"] = "Soltar herramienta",
        ["Drop all tools"] = "Soltar todas las herramientas",
        ["<b>Description</b>"] = "<b>Descripción</b>",
        ["Description"] = "Descripción",
        ["<b>Remove from the bookmark page</b>"] = "<b>Eliminar de la página de marcadores</b>",
        ["Remove from the bookmark page"] = "Eliminar de la página de marcadores",
        ["Search here!"] = "¡Busca aquí!",
        ["Enter"] = "Entrar",
        ["[ Select first ] Searcher"] = "[ Selecciona primero ] Buscador",
    },
    ["TH"] = {
        ["The ExperienceSettings is debug tools you can use on your own, there are a lot of tools!\nFor HealthBar was a remake of better and smoother and ValueLabels for show values.\nIf your ExperienceSettings was Disabled there are three reasons,\n • HumanoidRootPart was removed too long.\n • The Experience doesn't support the ExperienceSettings.\n • Script failed to load.\nIf you enjoy it, you can support me on discord!\nThank you for using ExperienceSettings! ♥️\n\n54% Gui is made by hand\n10% Script is made by hand\n36% Script is made by ai\n\nCreator: @5teve3019D (Gui, Little Script)\nHelper: ChatGPT (Script) <-- He got a lot of complaints lol.\nLittle Helper: Copilot of GitHub (Script)\nFun fact: Old is ugly than now lol I swear 😂 Oh, you haven't seen it :(\n\n========================\n➕ = Add something\n📢 = Announcements\n🔨 = In-develop\n🔷 = Plan ahead for updates\n✅ = Done\n⚠️ = Have issues\n🟠 = Updating soon\n❌ = Bug\n⚫ = Cannot fix\n➖ = Disconnected or discontinued\n-------\n📌 Updated: Update in this information is no longer appear now, please join our discord community to following update!\n-------\n🔁 In progress: No longer appear features\n-------\n❌ Failed: No longer appear unavailable features\n-------\n\n✨ SCRIPT CREDITS ✨\n[ Script Name ] by [ Creator ] [ Verification Status ]\n\nWe want to say that your script is awesome, and it is used in our project for debugging and educational purposes.\nThank you for your contribution :3 ❤️\n- Debugger\n\n-- Credits List --\n'Ketamine' by @Cherry (✓ Verified)\n'OG AFEM – Legacy' by @Imperial (✓ Verified)\n'Chat' by Unknown user\n'UNC' by Unknown user\n'REM' by @evildotcom (X Not verified)\n'GameProber' by @Imperial (✓ Verified)\n'AudioPlayer' by Unknown user\n'EmoteSelect' by Unknown user\n'Universal Movement Predictor' by @zephyrr (X Not verified)\n'Server Position Predictor' by @zephyrr (X Not verified)\n'Open Source Universal Chat' by @neutral (X Not verified)\n\n-- Notice to Script Creators --\nIf you are a script creator listed above and do not want your script to be included,\nplease contact us via our Discord forum, and we will remove it immediately.\n"] = "ExperienceSettings เป็นเครื่องมือดีบักที่คุณสามารถใช้ได้เอง มีเครื่องมือเยอะมาก!\nสำหรับ HealthBar นั้นเป็นเวอร์ชันรีเมคที่ลื่นกว่าและดีกว่า และ ValueLabels ใช้สำหรับแสดงค่า\nถ้า ExperienceSettings ของคุณถูกปิดใช้งาน มีอยู่ 3 สาเหตุ:\n • HumanoidRootPart ถูกลบไปนานเกินไป\n • Experience นี้ไม่รองรับ ExperienceSettings\n • สคริปต์โหลดไม่สำเร็จ\nถ้าคุณชอบมัน คุณสามารถสนับสนุนฉันได้ทาง Discord!\nขอบคุณที่ใช้ ExperienceSettings! ♥️\n\n54% ของ GUI ทำด้วยมือ\n10% ของสคริปต์ทำด้วยมือ\n36% ของสคริปต์ทำโดย AI\n\nผู้สร้าง: @5teve3019D (GUI, สคริปต์ส่วนเล็ก)\nผู้ช่วย: ChatGPT (สคริปต์) <-- เขาโดนบ่นเยอะมากเลย ฮ่าๆ\nผู้ช่วยตัวเล็ก: Copilot ของ GitHub (สคริปต์)\nเกร็ดน่าสนใจ: ของเก่าขี้เหร่กว่าตอนนี้เยอะเลย ฉันสาบาน 😂 โอ้ คุณยังไม่เคยเห็นมันสินะ :(\n\n========================\n➕ = เพิ่มอะไรบางอย่าง\n📢 = ประกาศ\n🔨 = กำลังพัฒนา\n🔷 = แผนสำหรับอัปเดตในอนาคต\n✅ = เสร็จแล้ว\n⚠️ = มีปัญหา\n🟠 = จะอัปเดตเร็ว ๆ นี้\n❌ = บั๊ก\n⚫ = ไม่สามารถแก้ได้\n➖ = ตัดการเชื่อมต่อหรือยกเลิกการพัฒนา\n-------\n📌 อัปเดต: ข้อมูลในส่วนนี้จะไม่แสดงในอัปเดตอีกต่อไป กรุณาเข้าร่วมชุมชน Discord ของเราเพื่อรับข่าวสารต่อไป!\n-------\n🔁 อยู่ระหว่างดำเนินการ: ฟีเจอร์ที่ไม่แสดงอีกแล้ว\n-------\n❌ ล้มเหลว: ฟีเจอร์ที่ไม่พร้อมใช้งานซึ่งไม่แสดงอีกแล้ว\n-------\n\n✨ เครดิตสคริปต์ ✨\n[ ชื่อสคริปต์ ] โดย [ ผู้สร้าง ] [ สถานะการยืนยัน ]\n\nเราขอบอกว่าสคริปต์ของคุณยอดเยี่ยมมาก และถูกใช้ในโปรเจกต์ของเราเพื่อการดีบักและเพื่อการศึกษา\nขอบคุณสำหรับผลงานของคุณ :3 ❤️\n- Debugger\n\n-- รายชื่อเครดิต --\n'Ketamine' โดย @Cherry (✓ ยืนยันแล้ว)\n'OG AFEM – Legacy' โดย @Imperial (✓ ยืนยันแล้ว)\n'Chat' โดยผู้ใช้ไม่ทราบชื่อ\n'UNC' โดยผู้ใช้ไม่ทราบชื่อ\n'REM' โดย @evildotcom (X ยังไม่ยืนยัน)\n'GameProber' โดย @Imperial (✓ ยืนยันแล้ว)\n'AudioPlayer' โดยผู้ใช้ไม่ทราบชื่อ\n'EmoteSelect' โดยผู้ใช้ไม่ทราบชื่อ\n'Universal Movement Predictor' โดย @zephyrr (X ยังไม่ยืนยัน)\n'Server Position Predictor' โดย @zephyrr (X ยังไม่ยืนยัน)\n'Open Source Universal Chat' โดย @neutral (X ยังไม่ยืนยัน)\n\n-- แจ้งเตือนสำหรับผู้สร้างสคริปต์ --\nหากคุณเป็นผู้สร้างสคริปต์ที่ระบุไว้ข้างต้น และไม่ต้องการให้สคริปต์ของคุณถูกรวมไว้\nกรุณาติดต่อเราผ่านฟอรัม Discord ของเรา และเราจะลบออกให้ทันที\n",
        ["Type /Help to show all commands or Say something..."] = "พิมพ์ /Help เพื่อดูคำสั่งทั้งหมด หรือพิมพ์อะไรสักอย่าง...",
        ["Confirm API"] = "ยืนยัน API",
        ["Unsaved API"] = "API ยังไม่บันทึก",
        ["[ Your API here (ChatGPT or Gemini) ]"] = "[ ใส่ API ของคุณที่นี่ (ChatGPT หรือ Gemini) ]",
        ["Status: No key"] = "สถานะ: ไม่มีคีย์",
        ["<b><stroke color='rgb(85,255,255)' thickness='2'>AI-Thinking</stroke></b>"] = "<b><stroke color='rgb(85,255,255)' thickness='2'>AI-Thinking</stroke></b>",
        ["<b><stroke color='rgb(255,100,100)' thickness='1' transparency='0'>UNAVAILABLE FEATURES (Old)</stroke></b>"] = "<b><stroke color='rgb(255,100,100)' thickness='1' transparency='0'>ฟีเจอร์ที่ใช้งานไม่ได้ (ของเก่า)</stroke></b>",
        ["\nThe ExperienceSettings is debug tools you can use on your own, there are a lot of tools!\nFor HealthBar was a remake of better and smoother and ValueLabels for show values.\nIf your ExperienceSettings was Disabled there are three reasons,\n • HumanoidRootPart was removed too long.\n • The Experience doesn't support the ExperienceSettings.\n • Script failed to load.\nIf you enjoy it, you can support me on discord!\nThank you for using ExperienceSettings! ♥️\n\n54% Gui is made by hand\n10% Script is made by hand\n36% Script is made by ai\n\nCreator: @5teve3019D (Gui, Little Script)\nHelper: ChatGPT (Script) <-- He got a lot of complaints lol.\nLittle Helper: Copilot of GitHub (Script)\nFun fact: Old is ugly than now lol I swear 😂 Oh, you haven't seen it :(\n\n========================\n➕ = Add something\n📢 = Announcements\n🔨 = In-develop\n🔷 = Plan ahead for updates\n✅ = Done\n⚠️ = Have issues\n🟠 = Updating soon\n❌ = Bug\n⚫ = Cannot fix\n➖ = Disconnected or discontinued\n-------\n📌 Updated: Update in this information is no longer appear now, please join our discord community to following update!\n-------\n🔁 In progress: No longer appear features\n-------\n❌ Failed: No longer appear unavailable features\n-------\n\n✨ SCRIPT CREDITS ✨\n[ Script Name ] by [ Creator ] [ Verification Status ]\n\nWe want to say that your script is awesome, and it is used in our project for debugging and educational purposes.\nThank you for your contribution :3 ❤️\n- Debugger\n\n-- Credits List --\n'Ketamine' by @Cherry (✓ Verified)\n'OG AFEM – Legacy' by @Imperial (✓ Verified)\n'Chat' by Unknown user\n'UNC' by Unknown user\n'REM' by @evildotcom (X Not verified)\n'GameProber' by @Imperial (✓ Verified)\n'AudioPlayer' by Unknown user\n'EmoteSelect' by Unknown user\n'Universal Movement Predictor' by @zephyrr (X Not verified)\n'Server Position Predictor' by @zephyrr (X Not verified)\n'Open Source Universal Chat' by @neutral (X Not verified)\n\n-- Notice to Script Creators --\nIf you are a script creator listed above and do not want your script to be included,\nplease contact us via our Discord forum, and we will remove it immediately.\n"] = "\nExperienceSettings เป็นเครื่องมือดีบักที่คุณสามารถใช้ได้เอง มีเครื่องมือเยอะมาก!\nสำหรับ HealthBar นั้นเป็นเวอร์ชันรีเมคที่ลื่นกว่าและดีกว่า และ ValueLabels ใช้สำหรับแสดงค่า\nถ้า ExperienceSettings ของคุณถูกปิดใช้งาน มีอยู่ 3 สาเหตุ:\n • HumanoidRootPart ถูกลบไปนานเกินไป\n • Experience นี้ไม่รองรับ ExperienceSettings\n • สคริปต์โหลดไม่สำเร็จ\nถ้าคุณชอบมัน คุณสามารถสนับสนุนฉันได้ทาง Discord!\nขอบคุณที่ใช้ ExperienceSettings! ♥️\n\n54% ของ GUI ทำด้วยมือ\n10% ของสคริปต์ทำด้วยมือ\n36% ของสคริปต์ทำโดย AI\n\nผู้สร้าง: @5teve3019D (GUI, สคริปต์ส่วนเล็ก)\nผู้ช่วย: ChatGPT (สคริปต์) <-- เขาโดนบ่นเยอะมากเลย ฮ่าๆ\nผู้ช่วยตัวเล็ก: Copilot ของ GitHub (สคริปต์)\nเกร็ดน่าสนใจ: ของเก่าขี้เหร่กว่าตอนนี้เยอะเลย ฉันสาบาน 😂 โอ้ คุณยังไม่เคยเห็นมันสินะ :(\n\n========================\n➕ = เพิ่มอะไรบางอย่าง\n📢 = ประกาศ\n🔨 = กำลังพัฒนา\n🔷 = แผนสำหรับอัปเดตในอนาคต\n✅ = เสร็จแล้ว\n⚠️ = มีปัญหา\n🟠 = จะอัปเดตเร็ว ๆ นี้\n❌ = บั๊ก\n⚫ = ไม่สามารถแก้ได้\n➖ = ตัดการเชื่อมต่อหรือยกเลิกการพัฒนา\n-------\n📌 อัปเดต: ข้อมูลในส่วนนี้จะไม่แสดงในอัปเดตอีกต่อไป กรุณาเข้าร่วมชุมชน Discord ของเราเพื่อรับข่าวสารต่อไป!\n-------\n🔁 อยู่ระหว่างดำเนินการ: ฟีเจอร์ที่ไม่แสดงอีกแล้ว\n-------\n❌ ล้มเหลว: ฟีเจอร์ที่ไม่พร้อมใช้งานซึ่งไม่แสดงอีกแล้ว\n-------\n\n✨ เครดิตสคริปต์ ✨\n[ ชื่อสคริปต์ ] โดย [ ผู้สร้าง ] [ สถานะการยืนยัน ]\n\nเราขอบอกว่าสคริปต์ของคุณยอดเยี่ยมมาก และถูกใช้ในโปรเจกต์ของเราเพื่อการดีบักและเพื่อการศึกษา\nขอบคุณสำหรับผลงานของคุณ :3 ❤️\n- Debugger\n\n-- รายชื่อเครดิต --\n'Ketamine' โดย @Cherry (✓ ยืนยันแล้ว)\n'OG AFEM – Legacy' โดย @Imperial (✓ ยืนยันแล้ว)\n'Chat' โดยผู้ใช้ไม่ทราบชื่อ\n'UNC' โดยผู้ใช้ไม่ทราบชื่อ\n'REM' โดย @evildotcom (X ยังไม่ยืนยัน)\n'GameProber' โดย @Imperial (✓ ยืนยันแล้ว)\n'AudioPlayer' โดยผู้ใช้ไม่ทราบชื่อ\n'EmoteSelect' โดยผู้ใช้ไม่ทราบชื่อ\n'Universal Movement Predictor' โดย @zephyrr (X ยังไม่ยืนยัน)\n'Server Position Predictor' โดย @zephyrr (X ยังไม่ยืนยัน)\n'Open Source Universal Chat' โดย @neutral (X ยังไม่ยืนยัน)\n\n-- แจ้งเตือนสำหรับผู้สร้างสคริปต์ --\nหากคุณเป็นผู้สร้างสคริปต์ที่ระบุไว้ข้างต้น และไม่ต้องการให้สคริปต์ของคุณถูกรวมไว้\nกรุณาติดต่อเราผ่านฟอรัม Discord ของเรา และเราจะลบออกให้ทันที\n",
        ["Hide"] = "ซ่อน",
        ["Oh, if the ExperienceSettings was disabled. You can hide the text by click the button."] = "อ้อ ถ้า ExperienceSettings ถูกปิดใช้งาน คุณสามารถซ่อนข้อความได้โดยกดปุ่มนี้",
        ["Leave"] = "ออก",
        ["Reset character"] = "รีเซ็ตตัวละคร",
        ["Resume"] = "กลับเข้าเกม",
        ["Open Roblox Settings"] = "เปิดการตั้งค่า Roblox",
        ["Player :"] = "ผู้เล่น :",
        ["Enable ValueLabels"] = "เปิด ValueLabels",
        ["Shaders - Recommend graphics 5+"] = "Shaders - แนะนำกราฟิก 5+",
        ["White Light"] = "แสงสีขาว",
        ["RGB Light"] = "แสง RGB",
        ["ESP (Beta)"] = "ESP (เบต้า)",
        ["Damage Overlay <stroke color='rgb(255,255,255)' thickness='1'><font color='#ff5555'><b>⚠ READ DESCRIPTION BY PRESSING HERE ⚠</b></font></stroke>"] = "โอเวอร์เลย์ความเสียหาย <stroke color='rgb(255,255,255)' thickness='1'><font color='#ff5555'><b>⚠ แตะที่นี่เพื่ออ่านคำอธิบาย ⚠</b></font></stroke>",
        ["MoreToggles"] = "ตัวเลือกเพิ่มเติม",
        ["LighterCyan.ai (Discontinued)"] = "LighterCyan.ai (เลิกพัฒนาแล้ว)",
        ["Show Physics"] = "แสดงฟิสิกส์",
        ["Last Death"] = "การตายครั้งล่าสุด",
        ["ServerPositionPredictor (By @zephyrr)"] = "ServerPositionPredictor (โดย @zephyrr)",
        ["Enable HealthBar"] = "เปิด HealthBar",
        ["Global Physics"] = "ฟิสิกส์แบบรวม",
        ["Disable Death Sound"] = "ปิดเสียงตาย",
        ["FreeCam (Mobile)"] = "FreeCam (มือถือ)",
        ["Almost Endless Fallen (-50K)"] = "Almost Endless Fallen (-50K)",
        ["Flashlight (FirstPerson & GFX 6+)"] = "ไฟฉาย (บุคคลที่หนึ่ง & GFX 6+)",
        ["ESP Highlight Players & Non-Players"] = "ESP ไฮไลต์ผู้เล่นและสิ่งที่ไม่ใช่ผู้เล่น",
        ["Shift Lock (Mobile)"] = "Shift Lock (มือถือ)",
        ["Hitbox Shower"] = "Hitbox Shower",
        ["ESP"] = "ESP",
        ["HealthBar"] = "HealthBar",
        ["Flashlight"] = "ไฟฉาย",
        ["Close fuc#king annoying load bar"] = "ปิดแถบโหลดน่ารำคาญ",
        ["Creator by @5teve3019D on ScriptBlox/HaxHell"] = "ผู้สร้างโดย @5teve3019D บน ScriptBlox/HaxHell",
        ["Loading"] = "กำลังโหลด",
        ["Starting ExperienceSettings. Please wait..."] = "กำลังเริ่ม ExperienceSettings กรุณารอสักครู่...",
        ["It might have bug and it still in beta."] = "อาจมีบั๊ก และยังอยู่ในช่วงเบต้า",
        ["Open Developer console"] = "เปิดคอนโซลนักพัฒนา",
        ["Drop Tool"] = "ทิ้งเครื่องมือ",
        ["Drop all tools"] = "ทิ้งเครื่องมือทั้งหมด",
        ["<b>Description</b>"] = "<b>คำอธิบาย</b>",
        ["Description"] = "คำอธิบาย",
        ["<b>Remove from the bookmark page</b>"] = "<b>ลบออกจากหน้าบุ๊กมาร์ก</b>",
        ["Remove from the bookmark page"] = "ลบออกจากหน้าบุ๊กมาร์ก",
        ["Search here!"] = "ค้นหาที่นี่!",
        ["Enter"] = "เข้า",
        ["[ Select first ] Searcher"] = "[ เลือกก่อน ] ตัวค้นหา",
        ["The ExperienceSettings is debug tools you can use on your own, there are a lot of tools!\nFor HealthBar was a remake of better and smoother and ValueLabels for show values.\nIf your ExperienceSettings was Disabled there are three reasons,\n • HumanoidRootPart was removed too long.\n • The Experience doesn't support the ExperienceSettings.\n • Script failed to load.\nIf you enjoy it, you can support me on discord!\nThank you for using ExperienceSettings! ♥️\n\n54% Gui is made by hand\n10% Script is made by hand\n36% Script is made by ai\n\nCreator: @5teve3019D (Gui, Little Script)\nHelper: ChatGPT (Script) <-- He got a lot of complaints lol.\nLittle Helper: Copilot of GitHub (Script)\nFun fact: Old is ugly than now lol I swear 😂 Oh, you haven't seen it :(\n\n========================\n➕ = Add something\n📢 = Announcements\n🔨 = In-develop\n🔷 = Plan ahead for updates\n✅ = Done\n⚠️ = Have issues\n🟠 = Updating soon\n❌ = Bug\n⚫ = Cannot fix\n➖ = Disconnected or discontinued\n-------\n📌 Updated: Update in this information is no longer appear now, please join our discord community to following update!\n-------\n🔁 In progress: No longer appear features\n-------\n❌ Failed: No longer appear unavailable features\n-------\n\n✨ SCRIPT CREDITS ✨\n[ Script Name ] by [ Creator ] [ Verification Status ]\n\nWe want to say that your script is awesome, and it is used in our project for debugging and educational purposes.\nThank you for your contribution :3 ❤️\n- Debugger\n\n-- Credits List --\n'Ketamine' by @Cherry (✓ Verified)\n'OG AFEM – Legacy' by @Imperial (✓ Verified)\n'Chat' by Unknown user\n'UNC' by Unknown user\n'REM' by @evildotcom (X Not verified)\n'GameProber' by @Imperial (✓ Verified)\n'AudioPlayer' by Unknown user\n'EmoteSelect' by Unknown user\n'Universal Movement Predictor' by @zephyrr (X Not verified)\n'Server Position Predictor' by @zephyrr (X Not verified)\n'Open Source Universal Chat' by @neutral (X Not verified)\n\n-- Notice to Script Creators --\nIf you are a script creator listed above and do not want your script to be included,\nplease contact us via our Discord forum, and we will remove it immediately.\n"] = null,
        ["Status: Unknown"] = "สถานะ: ไม่ทราบ",
        ["Version:<b> VER </b>"] = "เวอร์ชัน:<b> VER </b>",
        ["[ User on ScriptBlox/HaxHell ]"] = "[ ผู้ใช้บน ScriptBlox/HaxHell ]",
        ["“Creator of the ExperiencSettings.”"] = "“ผู้สร้าง ExperienceSettings”",
        ["Leave The Experience"] = "ออกจากเกม",
        ["A button that doesn't do NOTHING"] = "ปุ่มที่ไม่ทำอะไรเลย",
        ["OFF"] = "ปิด",
        ["<b><u>ValueLabel</u></b> Show ValueLabel at the Top HealthBar. • FPS - Frame Per second • HP - Health ( How to read: 100.000 HP = 100 HP ) • WS/s - Walkspeed per studs ( How to read: 16.000 WS/s = 16 WS/s )"] = "<b><u>ValueLabel</u></b> แสดง ValueLabel ที่ด้านบนของ HealthBar • FPS - เฟรมต่อวินาที • HP - พลังชีวิต (วิธีอ่าน: 100.000 HP = 100 HP) • WS/s - ความเร็วการเดินต่อ studs (วิธีอ่าน: 16.000 WS/s = 16 WS/s)",
        ["Shaders - Sunset"] = "Shaders - พระอาทิตย์ตก",
        ["<b><u>Shaders</u></b>\nWhat a beautiful sunset!\nGraphic quality recommend 6+"] = "<b><u>Shaders</u></b>\nพระอาทิตย์ตกสวยจัง!\nแนะนำให้ตั้งคุณภาพกราฟิกที่ 6+",
        ["<b><u>White Light</u></b>\nJust a PointLight around the you. Useful in the dark."] = "<b><u>White Light</u></b>\nเป็น PointLight รอบตัวคุณ เหมาะสำหรับใช้ในที่มืด",
        ["<b><u>RGB Light</u></b>\nSame as White Light, but RGB."] = "<b><u>RGB Light</u></b>\nเหมือน White Light แต่เป็น RGB",
        ["<b><u>ESP</u></b>\nSee all players around the map. Also TextLabel will change color following team color."] = "<b><u>ESP</u></b>\nดูผู้เล่นทั้งหมดรอบแผนที่ และ TextLabel จะเปลี่ยนสีตามสีทีม",
        ["<b><u>Damage Overlay</u></b> Displays visual damage effects ... Photosensitive Epilepsy Warning ..."] = "<b><u>Damage Overlay</u></b> แสดงเอฟเฟกต์ความเสียหายบนหน้าจอ ... คำเตือนสำหรับผู้ที่ไวต่อแสง ...",
        ["<b><u>MoreToggles</u></b> Open second toggle menu."] = "<b><u>MoreToggles</u></b> เปิดเมนูตัวเลือกชุดที่สอง",
        ["<b><u>Show Physics</u></b>\nDisplays colorful trajectory lines (\"player speedometers\") and landing prediction points showing where your character is expected to land."] = "<b><u>Show Physics</u></b>\nแสดงเส้นวิถีสีสันต่าง ๆ (\"มาตรวัดความเร็วผู้เล่น\") และจุดคาดการณ์ตำแหน่งลงพื้นเพื่อแสดงว่าตัวละครของคุณคาดว่าจะลงที่ไหน",
        ["<b><u>HealthBar</u></b>\nShow HealthBar at the Top Right."] = "<b><u>HealthBar</u></b>\nแสดง HealthBar ที่มุมขวาบน",
        ["<b><u>Global Physics</u></b>\nSame as Show Physics Toggle, but you're just seeing the physics of other players and objects too."] = "<b><u>Global Physics</u></b>\nเหมือน Show Physics แต่จะแสดงฟิสิกส์ของผู้เล่นและวัตถุอื่น ๆ ด้วย",
        ["<b><u>Death Sound</u></b>\nPlay sound after character dead."] = "<b><u>Death Sound</u></b>\nเล่นเสียงหลังจากตัวละครตาย",
        ["Relax / Gif Animation Editor"] = "ตัวแก้ไขแอนิเมชัน Relax / Gif",
        ["<b><u>Gif Animation Editor</u></b> Show or hide the Gif Animation Editor window."] = "<b><u>Gif Animation Editor</u></b> แสดงหรือซ่อนหน้าต่าง Gif Animation Editor",
        ["<b><u>FreeCam</u></b>\n\tExplore around the world with FreeCam! (Mobile Only)"] = "<b><u>FreeCam</u></b>\n\tสำรวจโลกไปรอบ ๆ ด้วย FreeCam! (มือถือเท่านั้น)",
        ["<b><u>Almost Endless Fallen</u></b>\nSet FallenPartDestroyHeight at -50000."] = "<b><u>Almost Endless Fallen</u></b>\nตั้งค่า FallenPartDestroyHeight เป็น -50000",
        ["<b><u>Flashlight</u></b>\nIt will make you in the first person with light, and also recommend set graphic quality at 6+"] = "<b><u>Flashlight</u></b>\nทำให้คุณอยู่ในมุมมองบุคคลที่หนึ่งพร้อมแสง และแนะนำให้ตั้งคุณภาพกราฟิกที่ 6+",
        ["<b><u>ESP Highlight Players & Non-Players</u></b>\nIt will highlight HumanoidRootPart. Players is <font color=\"rgb(0,255,0)\">green</font> and Non-Players is <font color=\"rgb(255,10,10)\">red</font>."] = "<b><u>ESP Highlight Players & Non-Players</u></b>\nจะไฮไลต์ HumanoidRootPart โดยผู้เล่นเป็นสี <font color=\"rgb(0,255,0)\">เขียว</font> และสิ่งที่ไม่ใช่ผู้เล่นเป็นสี <font color=\"rgb(255,10,10)\">แดง</font>",
        ["<b><u>Shift Lock</u></b>\nShift Lock for Mobile players. Also you can CUSTOMIZE CROSSHAIR by open <b>Settings - 2</b> in <b>Settings - Loader Rejoiner</b>!"] = "<b><u>Shift Lock</u></b>\nShift Lock สำหรับผู้เล่นมือถือ และคุณสามารถปรับแต่ง CROSSHAIR ได้โดยเปิด <b>Settings - 2</b> ใน <b>Settings - Loader Rejoiner</b>!",
        ["<b><u>Hitbox Shower</u></b>\nSee all hitbox players \n(Using ViewportFrame)"] = "<b><u>Hitbox Shower</u></b>\nดู Hitbox ของผู้เล่นทั้งหมด\n(ใช้ ViewportFrame)",
        ["Drag"] = "ลาก",
        ["Image"] = "รูปภาพ",
        ["Example: 'Folder/'"] = "ตัวอย่าง: 'Folder/'",
        ["Idle's FPS"] = "FPS ขณะ Idle",
        ["Save"] = "บันทึก",
        ["When Click's FPS"] = "FPS เมื่อคลิก",
        ["Frame Rate"] = "อัตราเฟรม",
        ["Idle Frame Rate"] = "อัตราเฟรมขณะ Idle",
        ["When Click"] = "เมื่อคลิก",
        ["When Click Frame Rate"] = "อัตราเฟรมเมื่อคลิก",
        ["<u><b>Editor</b></u>"] = "<u><b>ตัวแก้ไข</b></u>",
        ["Idle"] = "Idle",
        ["Debugs page is <b><u>not</u></b> done yet.\nTry to press the button at the top right."] = "หน้าดีบัก <b><u>ยัง</u></b> ทำไม่เสร็จ\nลองกดปุ่มที่มุมขวาบน",
        ["Untitled Song"] = "เพลงไม่มีชื่อ",
    },
    ["PT-BR"] = {
        ["Type /Help to show all commands or Say something..."] = "Digite /Ajuda para ver todos os comandos ou diga algo...",
        ["Confirm API"] = "Confirmar API",
        ["Unsaved API"] = "API não salva",
        ["[ Your API here (ChatGPT or Gemini) ]"] = "[ Sua API aqui (ChatGPT ou Gemini) ]",
        ["Status: No key"] = "Status: Sem chave",
        ["<b><stroke color='rgb(85,255,255)' thickness='2'>AI-Thinking</stroke></b>"] = "<b><stroke color='rgb(85,255,255)' thickness='2'>IA-Pensando</stroke></b>",
        ["<b><stroke color='rgb(255,100,100)' thickness='1' transparency='0'>UNAVAILABLE FEATURES (Old)</stroke></b>"] = "<b><stroke color='rgb(255,100,100)' thickness='1' transparency='0'>RECURSOS INDISPONÍVEIS (Antigos)</stroke></b>",
        ["\nThe ExperienceSettings is debug tools you can use on your own, there are a lot of tools!\nFor HealthBar was a remake of better and smoother and ValueLabels for show values.\nIf your ExperienceSettings was Disabled there are three reasons,\n • HumanoidRootPart was removed too long.\n • The Experience doesn't support the ExperienceSettings.\n • Script failed to load.\nIf you enjoy it, you can support me on discord!\nThank you for using ExperienceSettings! ♥️\n\n54% Gui is made by hand\n10% Script is made by hand\n36% Script is made by ai\n\nCreator: @5teve3019D (Gui, Little Script)\nHelper: ChatGPT (Script) <-- He got a lot of complaints lol.\nLittle Helper: Copilot of GitHub (Script)\nFun fact: Old is ugly than now lol I swear 😂 Oh, you haven't seen it :(\n\n========================\n➕ = Add something\n📢 = Announcements\n🔨 = In-develop\n🔷 = Plan ahead for updates\n✅ = Done\n⚠️ = Have issues\n🟠 = Updating soon\n❌ = Bug\n⚫ = Cannot fix\n➖ = Disconnected or discontinued\n-------\n📌 Updated: Update in this information is no longer appear now, please join our discord community to following update!\n-------\n🔁 In progress: No longer appear features\n-------\n❌ Failed: No longer appear unavailable features\n-------\n\n✨ SCRIPT CREDITS ✨\n[ Script Name ] by [ Creator ] [ Verification Status ]\n\nWe want to say that your script is awesome, and it is used in our project for debugging and educational purposes.\nThank you for your contribution :3 ❤️\n- Debugger\n\n-- Credits List --\n'Ketamine' by @Cherry (✓ Verified)\n'OG AFEM – Legacy' by @Imperial (✓ Verified)\n'Chat' by Unknown user\n'UNC' by Unknown user\n'REM' by @evildotcom (X Not verified)\n'GameProber' by @Imperial (✓ Verified)\n'AudioPlayer' by Unknown user\n'EmoteSelect' by Unknown user\n'Universal Movement Predictor' by @zephyrr (X Not verified)\n'Server Position Predictor' by @zephyrr (X Not verified)\n'Open Source Universal Chat' by @neutral (X Not verified)\n\n-- Notice to Script Creators --\nIf you are a script creator listed above and do not want your script to be included,\nplease contact us via our Discord forum, and we will remove it immediately.\n"] = "\nO ExperienceSettings é um conjunto de ferramentas de debug que você pode usar por conta própria. Existem muitas ferramentas!\nO HealthBar foi um remake mais suave e melhor, e o ValueLabels serve para mostrar valores.\nSe o seu ExperienceSettings estiver desativado, existem três motivos:\n • O HumanoidRootPart foi removido por muito tempo.\n • A experiência não suporta o ExperienceSettings.\n • O script falhou ao carregar.\nSe você gostar, pode me apoiar no Discord!\nObrigado por usar o ExperienceSettings! ♥️\n\n54% da interface foi feita manualmente\n10% do script foi feito manualmente\n36% do script foi feito por IA\n\nCriador: @5teve3019D (GUI, pequeno script)\nAjudante: ChatGPT (script) <-- Ele recebeu muitas reclamações kkk.\nPequeno ajudante: Copilot da GitHub (script)\nCuriosidade: o antigo era mais feio que o atual, eu juro 😂 Ah, você ainda não viu :(\n\n========================\n➕ = Adicionar algo\n📢 = Anúncios\n🔨 = Em desenvolvimento\n🔷 = Planejado para futuras atualizações\n✅ = Concluído\n⚠️ = Com problemas\n🟠 = Atualizando em breve\n❌ = Bug\n⚫ = Não pode ser corrigido\n➖ = Desconectado ou descontinuado\n-------\n📌 Atualizado: a atualização desta informação não aparece mais; entre na nossa comunidade no Discord para acompanhar as novidades!\n-------\n🔁 Em progresso: recursos que não aparecem mais\n-------\n❌ Falhou: recursos indisponíveis que não aparecem mais\n-------\n\n✨ CRÉDITOS DO SCRIPT ✨\n[ Nome do Script ] por [ Criador ] [ Status de Verificação ]\n\nQueremos dizer que o seu script é incrível e está sendo usado no nosso projeto para fins de debug e educação.\nObrigado pela sua contribuição :3 ❤️\n- Debugger\n\n-- Lista de créditos --\n'Ketamine' por @Cherry (✓ Verificado)\n'OG AFEM – Legacy' por @Imperial (✓ Verificado)\n'Chat' por usuário desconhecido\n'UNC' por usuário desconhecido\n'REM' por @evildotcom (X Não verificado)\n'GameProber' por @Imperial (✓ Verificado)\n'AudioPlayer' por usuário desconhecido\n'EmoteSelect' por usuário desconhecido\n'Universal Movement Predictor' por @zephyrr (X Não verificado)\n'Server Position Predictor' por @zephyrr (X Não verificado)\n'Open Source Universal Chat' por @neutral (X Não verificado)\n\n-- Aviso aos criadores de script --\nSe você for um criador de script listado acima e não quiser que o seu script seja incluído,\nentre em contato pelo nosso fórum no Discord, e vamos removê-lo imediatamente.\n",
        ["Hide"] = "Ocultar",
        ["Oh, if the ExperienceSettings was disabled. You can hide the text by click the button."] = "Ah, se o ExperienceSettings estiver desativado, você pode ocultar este texto clicando no botão.",
        ["Leave"] = "Sair",
        ["Reset character"] = "Resetar personagem",
        ["Resume"] = "Continuar",
        ["Open Roblox Settings"] = "Abrir configurações do Roblox",
        ["Player :"] = "Jogador :",
        ["Enable ValueLabels"] = "Ativar ValueLabels",
        ["Shaders - Recommend graphics 5+"] = "Shaders - Recomendado: gráficos 5+",
        ["White Light"] = "Luz branca",
        ["RGB Light"] = "Luz RGB",
        ["ESP (Beta)"] = "ESP (Beta)",
        ["Damage Overlay <stroke color='rgb(255,255,255)' thickness='1'><font color='#ff5555'><b>⚠ READ DESCRIPTION BY PRESSING HERE ⚠</b></font></stroke>"] = "Sobreposição de dano <stroke color='rgb(255,255,255)' thickness='1'><font color='#ff5555'><b>⚠ TOQUE AQUI PARA LER A DESCRIÇÃO ⚠</b></font></stroke>",
        ["MoreToggles"] = "Mais Toggles",
        ["LighterCyan.ai (Discontinued)"] = "LighterCyan.ai (Descontinuado)",
        ["Show Physics"] = "Mostrar física",
        ["Last Death"] = "Última morte",
        ["ServerPositionPredictor (By @zephyrr)"] = "ServerPositionPredictor (Por @zephyrr)",
        ["Enable HealthBar"] = "Ativar HealthBar",
        ["Global Physics"] = "Física global",
        ["Disable Death Sound"] = "Desativar som de morte",
        ["FreeCam (Mobile)"] = "FreeCam (Mobile)",
        ["Almost Endless Fallen (-50K)"] = "Queda quase infinita (-50K)",
        ["Flashlight (FirstPerson & GFX 6+)"] = "Lanterna (Primeira pessoa & GFX 6+)",
        ["ESP Highlight Players & Non-Players"] = "ESP destaca jogadores e não jogadores",
        ["Shift Lock (Mobile)"] = "Shift Lock (Mobile)",
        ["Hitbox Shower"] = "Chuva de hitboxes",
        ["Shaders - Sunset"] = "Shaders - Pôr do sol",
        ["ESP"] = "ESP",
        ["HealthBar"] = "HealthBar",
        ["Flashlight"] = "Lanterna",
        ["Relax / Gif Animation Editor"] = "Editor de animação Relax / Gif",
        ["Close fuc#king annoying load bar"] = "Fechar a barra de carregamento irritante",
        ["Creator by @5teve3019D on ScriptBlox/HaxHell"] = "Criado por @5teve3019D no ScriptBlox/HaxHell",
        ["Loading"] = "Carregando",
        ["Starting ExperienceSettings. Please wait..."] = "Iniciando o ExperienceSettings. Aguarde...",
        ["It might have bug and it still in beta."] = "Pode ter bugs e ainda está em beta.",
        ["Open Developer console"] = "Abrir console de desenvolvedor",
        ["Drop Tool"] = "Dropar ferramenta",
        ["Drop all tools"] = "Dropar todas as ferramentas",
        ["<b>Description</b>"] = "<b>Descrição</b>",
        ["Description"] = "Descrição",
        ["<b>Remove from the bookmark page</b>"] = "<b>Remover da página de favoritos</b>",
        ["Remove from the bookmark page"] = "Remover da página de favoritos",
        ["Search here!"] = "Pesquise aqui!",
        ["Enter"] = "Entrar",
        ["[ Select first ] Searcher"] = "[ Selecione primeiro ] Pesquisar",
    },
    ["PT-PT"] = {
        ["Type /Help to show all commands or Say something..."] = "Escreve /Ajuda para ver todos os comandos ou diz algo...",
        ["Confirm API"] = "Confirmar API",
        ["Unsaved API"] = "API não guardada",
        ["[ Your API here (ChatGPT or Gemini) ]"] = "[ A tua API aqui (ChatGPT ou Gemini) ]",
        ["Status: No key"] = "Estado: Sem chave",
        ["<b><stroke color='rgb(85,255,255)' thickness='2'>AI-Thinking</stroke></b>"] = "<b><stroke color='rgb(85,255,255)' thickness='2'>IA-Pensando</stroke></b>",
        ["<b><stroke color='rgb(255,100,100)' thickness='1' transparency='0'>UNAVAILABLE FEATURES (Old)</stroke></b>"] = "<b><stroke color='rgb(255,100,100)' thickness='1' transparency='0'>FUNCIONALIDADES INDISPONÍVEIS (Antigas)</stroke></b>",
        ["\nThe ExperienceSettings is debug tools you can use on your own, there are a lot of tools!\nFor HealthBar was a remake of better and smoother and ValueLabels for show values.\nIf your ExperienceSettings was Disabled there are three reasons,\n • HumanoidRootPart was removed too long.\n • The Experience doesn't support the ExperienceSettings.\n • Script failed to load.\nIf you enjoy it, you can support me on discord!\nThank you for using ExperienceSettings! ♥️\n\n54% Gui is made by hand\n10% Script is made by hand\n36% Script is made by ai\n\nCreator: @5teve3019D (Gui, Little Script)\nHelper: ChatGPT (Script) <-- He got a lot of complaints lol.\nLittle Helper: Copilot of GitHub (Script)\nFun fact: Old is ugly than now lol I swear 😂 Oh, you haven't seen it :(\n\n========================\n➕ = Add something\n📢 = Announcements\n🔨 = In-develop\n🔷 = Plan ahead for updates\n✅ = Done\n⚠️ = Have issues\n🟠 = Updating soon\n❌ = Bug\n⚫ = Cannot fix\n➖ = Disconnected or discontinued\n-------\n📌 Updated: Update in this information is no longer appear now, please join our discord community to following update!\n-------\n🔁 In progress: No longer appear features\n-------\n❌ Failed: No longer appear unavailable features\n-------\n\n✨ SCRIPT CREDITS ✨\n[ Script Name ] by [ Creator ] [ Verification Status ]\n\nWe want to say that your script is awesome, and it is used in our project for debugging and educational purposes.\nThank you for your contribution :3 ❤️\n- Debugger\n\n-- Credits List --\n'Ketamine' by @Cherry (✓ Verified)\n'OG AFEM – Legacy' by @Imperial (✓ Verified)\n'Chat' by Unknown user\n'UNC' by Unknown user\n'REM' by @evildotcom (X Not verified)\n'GameProber' by @Imperial (✓ Verified)\n'AudioPlayer' by Unknown user\n'EmoteSelect' by Unknown user\n'Universal Movement Predictor' by @zephyrr (X Not verified)\n'Server Position Predictor' by @zephyrr (X Not verified)\n'Open Source Universal Chat' by @neutral (X Not verified)\n\n-- Notice to Script Creators --\nIf you are a script creator listed above and do not want your script to be included,\nplease contact us via our Discord forum, and we will remove it immediately.\n"] = "\nO ExperienceSettings é um conjunto de ferramentas de depuração que podes usar por tua conta. Existem muitas ferramentas!\nO HealthBar foi um remake mais suave e melhor, e o ValueLabels serve para mostrar valores.\nSe o teu ExperienceSettings estiver desativado, existem três motivos:\n • O HumanoidRootPart foi removido há demasiado tempo.\n • A experiência não suporta o ExperienceSettings.\n • O script falhou ao carregar.\nSe gostares, podes apoiar-me no Discord!\nObrigado por usares o ExperienceSettings! ♥️\n\n54% da interface foi feita manualmente\n10% do script foi feito manualmente\n36% do script foi feito por IA\n\nCriador: @5teve3019D (GUI, pequeno script)\nAjudante: ChatGPT (script) <-- Ele recebeu muitas reclamações lol.\nPequeno ajudante: Copilot da GitHub (script)\nCuriosidade: o antigo era mais feio do que o atual, eu juro 😂 Ah, ainda não viste :(\n\n========================\n➕ = Adicionar algo\n📢 = Anúncios\n🔨 = Em desenvolvimento\n🔷 = Planeado para futuras atualizações\n✅ = Concluído\n⚠️ = Com problemas\n🟠 = A atualizar em breve\n❌ = Bug\n⚫ = Não pode ser corrigido\n➖ = Desligado ou descontinuado\n-------\n📌 Atualizado: esta informação já não aparece; junta-te à nossa comunidade no Discord para acompanhares as novidades!\n-------\n🔁 Em progresso: funcionalidades que já não aparecem\n-------\n❌ Falhou: funcionalidades indisponíveis que já não aparecem\n-------\n\n✨ CRÉDITOS DO SCRIPT ✨\n[ Nome do Script ] por [ Criador ] [ Estado de Verificação ]\n\nQueremos dizer que o teu script é incrível e está a ser usado no nosso projeto para fins de depuração e educação.\nObrigado pela tua contribuição :3 ❤️\n- Debugger\n\n-- Lista de créditos --\n'Ketamine' por @Cherry (✓ Verificado)\n'OG AFEM – Legacy' por @Imperial (✓ Verificado)\n'Chat' por utilizador desconhecido\n'UNC' por utilizador desconhecido\n'REM' por @evildotcom (X Não verificado)\n'GameProber' por @Imperial (✓ Verificado)\n'AudioPlayer' por utilizador desconhecido\n'EmoteSelect' por utilizador desconhecido\n'Universal Movement Predictor' por @zephyrr (X Não verificado)\n'Server Position Predictor' por @zephyrr (X Não verificado)\n'Open Source Universal Chat' por @neutral (X Não verificado)\n\n-- Aviso aos criadores de script --\nSe fores um criador de script listado acima e não quiseres que o teu script seja incluído,\nentra em contacto através do nosso fórum no Discord, e vamos removê-lo imediatamente.\n",
        ["Hide"] = "Ocultar",
        ["Oh, if the ExperienceSettings was disabled. You can hide the text by click the button."] = "Ah, se o ExperienceSettings estiver desativado, podes ocultar este texto clicando no botão.",
        ["Leave"] = "Sair",
        ["Reset character"] = "Reiniciar personagem",
        ["Resume"] = "Continuar",
        ["Open Roblox Settings"] = "Abrir definições do Roblox",
        ["Player :"] = "Jogador :",
        ["Enable ValueLabels"] = "Ativar ValueLabels",
        ["Shaders - Recommend graphics 5+"] = "Shaders - Recomendado: gráficos 5+",
        ["White Light"] = "Luz branca",
        ["RGB Light"] = "Luz RGB",
        ["ESP (Beta)"] = "ESP (Beta)",
        ["Damage Overlay <stroke color='rgb(255,255,255)' thickness='1'><font color='#ff5555'><b>⚠ READ DESCRIPTION BY PRESSING HERE ⚠</b></font></stroke>"] = "Sobreposição de dano <stroke color='rgb(255,255,255)' thickness='1'><font color='#ff5555'><b>⚠ TOCA AQUI PARA LER A DESCRIÇÃO ⚠</b></font></stroke>",
        ["MoreToggles"] = "Mais Toggles",
        ["LighterCyan.ai (Discontinued)"] = "LighterCyan.ai (Descontinuado)",
        ["Show Physics"] = "Mostrar física",
        ["Last Death"] = "Última morte",
        ["ServerPositionPredictor (By @zephyrr)"] = "ServerPositionPredictor (Por @zephyrr)",
        ["Enable HealthBar"] = "Ativar HealthBar",
        ["Global Physics"] = "Física global",
        ["Disable Death Sound"] = "Desativar som de morte",
        ["FreeCam (Mobile)"] = "FreeCam (Telemóvel)",
        ["Almost Endless Fallen (-50K)"] = "Queda quase infinita (-50K)",
        ["Flashlight (FirstPerson & GFX 6+)"] = "Lanterna (1.ª pessoa & GFX 6+)",
        ["ESP Highlight Players & Non-Players"] = "ESP destaca jogadores e não jogadores",
        ["Shift Lock (Mobile)"] = "Shift Lock (Telemóvel)",
        ["Hitbox Shower"] = "Chuva de hitboxes",
        ["Shaders - Sunset"] = "Shaders - Pôr do sol",
        ["ESP"] = "ESP",
        ["HealthBar"] = "HealthBar",
        ["Flashlight"] = "Lanterna",
        ["Relax / Gif Animation Editor"] = "Editor de animação Relax / Gif",
        ["Close fuc#king annoying load bar"] = "Fechar a barra de carregamento irritante",
        ["Creator by @5teve3019D on ScriptBlox/HaxHell"] = "Criado por @5teve3019D no ScriptBlox/HaxHell",
        ["Loading"] = "A carregar",
        ["Starting ExperienceSettings. Please wait..."] = "A iniciar o ExperienceSettings. Aguarda...",
        ["It might have bug and it still in beta."] = "Pode ter bugs e ainda está em beta.",
        ["Open Developer console"] = "Abrir consola de desenvolvedor",
        ["Drop Tool"] = "Largar ferramenta",
        ["Drop all tools"] = "Largar todas as ferramentas",
        ["<b>Description</b>"] = "<b>Descrição</b>",
        ["Description"] = "Descrição",
        ["<b>Remove from the bookmark page</b>"] = "<b>Remover da página de favoritos</b>",
        ["Remove from the bookmark page"] = "Remover da página de favoritos",
        ["Search here!"] = "Pesquisa aqui!",
        ["Enter"] = "Entrar",
        ["[ Select first ] Searcher"] = "[ Seleciona primeiro ] Pesquisar",
    },
    ["RU"] = {
        ["Type /Help to show all commands or Say something..."] = "Введите /Help, чтобы показать все команды, или напишите что-нибудь...",
        ["Confirm API"] = "Подтвердить API",
        ["Unsaved API"] = "API не сохранён",
        ["[ Your API here (ChatGPT or Gemini) ]"] = "[ Ваш API здесь (ChatGPT или Gemini) ]",
        ["Status: No key"] = "Статус: нет ключа",
        ["<b><stroke color='rgb(85,255,255)' thickness='2'>AI-Thinking</stroke></b>"] = "<b><stroke color='rgb(85,255,255)' thickness='2'>ИИ-Мышление</stroke></b>",
        ["<b><stroke color='rgb(255,100,100)' thickness='1' transparency='0'>UNAVAILABLE FEATURES (Old)</stroke></b>"] = "<b><stroke color='rgb(255,100,100)' thickness='1' transparency='0'>НЕДОСТУПНЫЕ ФУНКЦИИ (Старые)</stroke></b>",
        ["\nThe ExperienceSettings is debug tools you can use on your own, there are a lot of tools!\nFor HealthBar was a remake of better and smoother and ValueLabels for show values.\nIf your ExperienceSettings was Disabled there are three reasons,\n • HumanoidRootPart was removed too long.\n • The Experience doesn't support the ExperienceSettings.\n • Script failed to load.\nIf you enjoy it, you can support me on discord!\nThank you for using ExperienceSettings! ♥️\n\n54% Gui is made by hand\n10% Script is made by hand\n36% Script is made by ai\n\nCreator: @5teve3019D (Gui, Little Script)\nHelper: ChatGPT (Script) <-- He got a lot of complaints lol.\nLittle Helper: Copilot of GitHub (Script)\nFun fact: Old is ugly than now lol I swear 😂 Oh, you haven't seen it :(\n\n========================\n➕ = Add something\n📢 = Announcements\n🔨 = In-develop\n🔷 = Plan ahead for updates\n✅ = Done\n⚠️ = Have issues\n🟠 = Updating soon\n❌ = Bug\n⚫ = Cannot fix\n➖ = Disconnected or discontinued\n-------\n📌 Updated: Update in this information is no longer appear now, please join our discord community to following update!\n-------\n🔁 In progress: No longer appear features\n-------\n❌ Failed: No longer appear unavailable features\n-------\n\n✨ SCRIPT CREDITS ✨\n[ Script Name ] by [ Creator ] [ Verification Status ]\n\nWe want to say that your script is awesome, and it is used in our project for debugging and educational purposes.\nThank you for your contribution :3 ❤️\n- Debugger\n\n-- Credits List --\n'Ketamine' by @Cherry (✓ Verified)\n'OG AFEM – Legacy' by @Imperial (✓ Verified)\n'Chat' by Unknown user\n'UNC' by Unknown user\n'REM' by @evildotcom (X Not verified)\n'GameProber' by @Imperial (✓ Verified)\n'AudioPlayer' by Unknown user\n'EmoteSelect' by Unknown user\n'Universal Movement Predictor' by @zephyrr (X Not verified)\n'Server Position Predictor' by @zephyrr (X Not verified)\n'Open Source Universal Chat' by @neutral (X Not verified)\n\n-- Notice to Script Creators --\nIf you are a script creator listed above and do not want your script to be included,\nplease contact us via our Discord forum, and we will remove it immediately.\n"] = "\nExperienceSettings — это набор отладочных инструментов, которыми ты можешь пользоваться сам. Тут много разных инструментов!\nHealthBar — это ремейк, который работает плавнее и лучше, а ValueLabels показывают значения.\nЕсли ExperienceSettings отключён, есть три причины:\n • HumanoidRootPart был удалён слишком давно.\n • Эта Experience не поддерживает ExperienceSettings.\n • Скрипт не смог загрузиться.\nЕсли тебе нравится этот проект, ты можешь поддержать меня в Discord!\nСпасибо за использование ExperienceSettings! ♥️\n\n54% интерфейса сделано вручную\n10% скрипта сделано вручную\n36% скрипта сделано ИИ\n\nСоздатель: @5teve3019D (GUI, небольшой скрипт)\nПомощник: ChatGPT (скрипт) <-- На него было много жалоб лол.\nМаленький помощник: Copilot от GitHub (скрипт)\nИнтересный факт: старый вариант был намного хуже, чем сейчас, клянусь 😂 О, ты его ещё не видел :(\n\n========================\n➕ = Добавить что-то\n📢 = Объявления\n🔨 = В разработке\n🔷 = Планируется в будущем обновлении\n✅ = Готово\n⚠️ = Есть проблемы\n🟠 = Скоро обновится\n❌ = Баг\n⚫ = Невозможно исправить\n➖ = Отключено или устарело\n-------\n📌 Обновлено: обновления этой информации больше не показываются, пожалуйста, присоединяйся к нашему Discord-сообществу, чтобы следить за новостями!\n-------\n🔁 В процессе: функции, которые больше не отображаются\n-------\n❌ Не удалось: недоступные функции, которые больше не отображаются\n-------\n\n✨ КРЕДИТЫ СКРИПТА ✨\n[ Название скрипта ] от [ Создатель ] [ Статус проверки ]\n\nМы хотим сказать, что твой скрипт потрясающий, и он используется в нашем проекте для отладки и обучения.\nСпасибо за твой вклад :3 ❤️\n- Debugger\n\n-- Список кредитов --\n'Ketamine' от @Cherry (✓ Проверено)\n'OG AFEM – Legacy' от @Imperial (✓ Проверено)\n'Chat' от неизвестного пользователя\n'UNC' от неизвестного пользователя\n'REM' от @evildotcom (X Не проверено)\n'GameProber' от @Imperial (✓ Проверено)\n'AudioPlayer' от неизвестного пользователя\n'EmoteSelect' от неизвестного пользователя\n'Universal Movement Predictor' от @zephyrr (X Не проверено)\n'Server Position Predictor' от @zephyrr (X Не проверено)\n'Open Source Universal Chat' от @neutral (X Не проверено)\n\n-- Примечание для авторов скриптов --\nЕсли ты автор скрипта, указанного выше, и не хочешь, чтобы он был включён,\nсвяжись с нами через наш Discord-форум, и мы удалим его сразу же.\n",
        ["Hide"] = "Скрыть",
        ["Oh, if the ExperienceSettings was disabled. You can hide the text by click the button."] = "Ах, если ExperienceSettings отключён, ты можешь скрыть этот текст, нажав кнопку.",
        ["Leave"] = "Выйти",
        ["Reset character"] = "Сбросить персонажа",
        ["Resume"] = "Продолжить",
        ["Open Roblox Settings"] = "Открыть настройки Roblox",
        ["Player :"] = "Игрок :",
        ["Enable ValueLabels"] = "Включить ValueLabels",
        ["Shaders - Recommend graphics 5+"] = "Шейдеры - рекомендуется графика 5+",
        ["White Light"] = "Белый свет",
        ["RGB Light"] = "RGB-свет",
        ["ESP (Beta)"] = "ESP (бета)",
        ["Damage Overlay <stroke color='rgb(255,255,255)' thickness='1'><font color='#ff5555'><b>⚠ READ DESCRIPTION BY PRESSING HERE ⚠</b></font></stroke>"] = "Наложение урона <stroke color='rgb(255,255,255)' thickness='1'><font color='#ff5555'><b>⚠ НАЖМИТЕ ЗДЕСЬ, ЧТОБЫ ПРОЧИТАТЬ ОПИСАНИЕ ⚠</b></font></stroke>",
        ["MoreToggles"] = "Ещё тумблеры",
        ["LighterCyan.ai (Discontinued)"] = "LighterCyan.ai (Устарело)",
        ["Show Physics"] = "Показать физику",
        ["Last Death"] = "Последняя смерть",
        ["ServerPositionPredictor (By @zephyrr)"] = "ServerPositionPredictor (От @zephyrr)",
        ["Enable HealthBar"] = "Включить HealthBar",
        ["Global Physics"] = "Глобальная физика",
        ["Disable Death Sound"] = "Отключить звук смерти",
        ["FreeCam (Mobile)"] = "FreeCam (Mobile)",
        ["Almost Endless Fallen (-50K)"] = "Почти бесконечное падение (-50K)",
        ["Flashlight (FirstPerson & GFX 6+)"] = "Фонарик (Первое лицо & GFX 6+)",
        ["ESP Highlight Players & Non-Players"] = "ESP выделяет игроков и неигроков",
        ["Shift Lock (Mobile)"] = "Shift Lock (Mobile)",
        ["Hitbox Shower"] = "Дождь хитбоксов",
        ["Shaders - Sunset"] = "Шейдеры — закат",
        ["ESP"] = "ESP",
        ["HealthBar"] = "HealthBar",
        ["Flashlight"] = "Фонарик",
        ["Relax / Gif Animation Editor"] = "Редактор GIF-анимации Relax",
        ["Close fuc#king annoying load bar"] = "Закрыть бесящую полосу загрузки",
        ["Creator by @5teve3019D on ScriptBlox/HaxHell"] = "Создатель: @5teve3019D на ScriptBlox/HaxHell",
        ["Loading"] = "Загрузка",
        ["Starting ExperienceSettings. Please wait..."] = "Запуск ExperienceSettings. Пожалуйста, подожди...",
        ["It might have bug and it still in beta."] = "Возможны баги, и это всё ещё beta.",
        ["Open Developer console"] = "Открыть консоль разработчика",
        ["Drop Tool"] = "Выбросить предмет",
        ["Drop all tools"] = "Выбросить все предметы",
        ["<b>Description</b>"] = "<b>Описание</b>",
        ["Description"] = "Описание",
        ["<b>Remove from the bookmark page</b>"] = "<b>Удалить со страницы закладок</b>",
        ["Remove from the bookmark page"] = "Удалить со страницы закладок",
        ["Search here!"] = "Поиск здесь!",
        ["Enter"] = "Войти",
        ["[ Select first ] Searcher"] = "[ Сначала выбери ] Поиск",
    },
    ["KO"] = {
        ["Type /Help to show all commands or Say something..."] = "모든 명령을 보려면 /Help 를 입력하거나 아무 말이나 해보세요...",
        ["Confirm API"] = "API 확인",
        ["Unsaved API"] = "저장되지 않은 API",
        ["[ Your API here (ChatGPT or Gemini) ]"] = "[ 여기에 API 입력 (ChatGPT 또는 Gemini) ]",
        ["Status: No key"] = "상태: 키 없음",
        ["<b><stroke color='rgb(85,255,255)' thickness='2'>AI-Thinking</stroke></b>"] = "<b><stroke color='rgb(85,255,255)' thickness='2'>AI-생각중</stroke></b>",
        ["<b><stroke color='rgb(255,100,100)' thickness='1' transparency='0'>UNAVAILABLE FEATURES (Old)</stroke></b>"] = "<b><stroke color='rgb(255,100,100)' thickness='1' transparency='0'>사용할 수 없는 기능 (오래된 기능)</stroke></b>",
        ["\nThe ExperienceSettings is debug tools you can use on your own, there are a lot of tools!\nFor HealthBar was a remake of better and smoother and ValueLabels for show values.\nIf your ExperienceSettings was Disabled there are three reasons,\n • HumanoidRootPart was removed too long.\n • The Experience doesn't support the ExperienceSettings.\n • Script failed to load.\nIf you enjoy it, you can support me on discord!\nThank you for using ExperienceSettings! ♥️\n\n54% Gui is made by hand\n10% Script is made by hand\n36% Script is made by ai\n\nCreator: @5teve3019D (Gui, Little Script)\nHelper: ChatGPT (Script) <-- He got a lot of complaints lol.\nLittle Helper: Copilot of GitHub (Script)\nFun fact: Old is ugly than now lol I swear 😂 Oh, you haven't seen it :(\n\n========================\n➕ = Add something\n📢 = Announcements\n🔨 = In-develop\n🔷 = Plan ahead for updates\n✅ = Done\n⚠️ = Have issues\n🟠 = Updating soon\n❌ = Bug\n⚫ = Cannot fix\n➖ = Disconnected or discontinued\n-------\n📌 Updated: Update in this information is no longer appear now, please join our discord community to following update!\n-------\n🔁 In progress: No longer appear features\n-------\n❌ Failed: No longer appear unavailable features\n-------\n\n✨ SCRIPT CREDITS ✨\n[ Script Name ] by [ Creator ] [ Verification Status ]\n\nWe want to say that your script is awesome, and it is used in our project for debugging and educational purposes.\nThank you for your contribution :3 ❤️\n- Debugger\n\n-- Credits List --\n'Ketamine' by @Cherry (✓ Verified)\n'OG AFEM – Legacy' by @Imperial (✓ Verified)\n'Chat' by Unknown user\n'UNC' by Unknown user\n'REM' by @evildotcom (X Not verified)\n'GameProber' by @Imperial (✓ Verified)\n'AudioPlayer' by Unknown user\n'EmoteSelect' by Unknown user\n'Universal Movement Predictor' by @zephyrr (X Not verified)\n'Server Position Predictor' by @zephyrr (X Not verified)\n'Open Source Universal Chat' by @neutral (X Not verified)\n\n-- Notice to Script Creators --\nIf you are a script creator listed above and do not want your script to be included,\nplease contact us via our Discord forum, and we will remove it immediately.\n"] = "\nExperienceSettings는 혼자서 사용할 수 있는 디버그 도구 모음입니다. 정말 많은 기능이 있어요!\nHealthBar는 더 부드럽고 개선된 리메이크이며, ValueLabels는 값을 표시하는 데 사용됩니다.\nExperienceSettings가 비활성화되는 이유는 세 가지입니다.\n • HumanoidRootPart가 너무 오래 전에 제거됨.\n • 해당 경험이 ExperienceSettings를 지원하지 않음.\n • 스크립트 로딩에 실패함.\n마음에 드셨다면 Discord에서 응원해 주세요!\nExperienceSettings를 사용해 주셔서 감사합니다! ♥️\n\n인터페이스 54%는 수작업으로 제작됨\n스크립트 10%는 수작업으로 제작됨\n스크립트 36%는 AI로 제작됨\n\n제작자: @5teve3019D (GUI, 작은 스크립트)\n도움: ChatGPT (스크립트) <-- 불만도 많이 받았어요 ㅋㅋ\n작은 도우미: GitHub Copilot (스크립트)\n재미있는 사실: 예전 버전은 지금보다 훨씬 못생겼어요, 진짜예요 😂 아직 안 보셨죠 :(\n\n========================\n➕ = 추가\n📢 = 공지\n🔨 = 개발 중\n🔷 = 향후 업데이트 예정\n✅ = 완료\n⚠️ = 문제 있음\n🟠 = 곧 업데이트\n❌ = 버그\n⚫ = 수정 불가\n➖ = 연결 끊김 또는 서비스 종료\n-------\n📌 업데이트됨: 이 정보의 업데이트는 더 이상 표시되지 않습니다. 최신 소식을 보려면 Discord 커뮤니티에 참여해 주세요!\n-------\n🔁 진행 중: 더 이상 표시되지 않는 기능\n-------\n❌ 실패: 사용할 수 없게 되어 더 이상 표시되지 않는 기능\n-------\n\n✨ 스크립트 크레딧 ✨\n[ 스크립트 이름 ] by [ 제작자 ] [ 검증 상태 ]\n\n당신의 스크립트는 정말 멋지고, 현재 우리 프로젝트에서 디버깅 및 교육용으로 사용되고 있습니다.\n기여해 주셔서 감사합니다 :3 ❤️\n- Debugger\n\n-- 크레딧 목록 --\n'Ketamine' by @Cherry (✓ 검증됨)\n'OG AFEM – Legacy' by @Imperial (✓ 검증됨)\n'Chat' by 알 수 없는 사용자\n'UNC' by 알 수 없는 사용자\n'REM' by @evildotcom (X 미검증)\n'GameProber' by @Imperial (✓ 검증됨)\n'AudioPlayer' by 알 수 없는 사용자\n'EmoteSelect' by 알 수 없는 사용자\n'Universal Movement Predictor' by @zephyrr (X 미검증)\n'Server Position Predictor' by @zephyrr (X 미검증)\n'Open Source Universal Chat' by @neutral (X 미검증)\n\n-- 스크립트 제작자 안내 --\n위 목록에 포함된 스크립트의 제작자 중 자신의 스크립트가 포함되기를 원하지 않는 분은,\nDiscord 포럼으로 연락해 주세요. 즉시 제거하겠습니다.\n",
        ["Hide"] = "숨기기",
        ["Oh, if the ExperienceSettings was disabled. You can hide the text by click the button."] = "아, ExperienceSettings가 비활성화되어 있어도 이 버튼을 눌러 이 텍스트를 숨길 수 있습니다.",
        ["Leave"] = "나가기",
        ["Reset character"] = "캐릭터 초기화",
        ["Resume"] = "계속하기",
        ["Open Roblox Settings"] = "Roblox 설정 열기",
        ["Player :"] = "플레이어 :",
        ["Enable ValueLabels"] = "ValueLabels 활성화",
        ["Shaders - Recommend graphics 5+"] = "셰이더 - 권장 그래픽 5+",
        ["White Light"] = "화이트 라이트",
        ["RGB Light"] = "RGB 라이트",
        ["ESP (Beta)"] = "ESP (베타)",
        ["Damage Overlay <stroke color='rgb(255,255,255)' thickness='1'><font color='#ff5555'><b>⚠ READ DESCRIPTION BY PRESSING HERE ⚠</b></font></stroke>"] = "데미지 오버레이 <stroke color='rgb(255,255,255)' thickness='1'><font color='#ff5555'><b>⚠ 여기를 눌러 설명을 읽어 주세요 ⚠</b></font></stroke>",
        ["MoreToggles"] = "더 많은 토글",
        ["LighterCyan.ai (Discontinued)"] = "LighterCyan.ai (지원 종료)",
        ["Show Physics"] = "물리 표시",
        ["Last Death"] = "마지막 죽음",
        ["ServerPositionPredictor (By @zephyrr)"] = "ServerPositionPredictor (@zephyrr 제작)",
        ["Enable HealthBar"] = "HealthBar 활성화",
        ["Global Physics"] = "전역 물리",
        ["Disable Death Sound"] = "죽음 소리 비활성화",
        ["FreeCam (Mobile)"] = "FreeCam (모바일)",
        ["Almost Endless Fallen (-50K)"] = "거의 끝없는 바닥 (-50K)",
        ["Flashlight (FirstPerson & GFX 6+)"] = "손전등 (1인칭 & GFX 6+)",
        ["ESP Highlight Players & Non-Players"] = "플레이어와 비플레이어 ESP 강조",
        ["Shift Lock (Mobile)"] = "Shift Lock (모바일)",
        ["Hitbox Shower"] = "히트박스 샤워",
        ["Shaders - Sunset"] = "셰이더 - 석양",
        ["ESP"] = "ESP",
        ["HealthBar"] = "HealthBar",
        ["Flashlight"] = "손전등",
        ["Relax / Gif Animation Editor"] = "Relax / Gif 애니메이션 편집기",
        ["Close fuc#king annoying load bar"] = "짜증나는 로딩 바 닫기",
        ["Creator by @5teve3019D on ScriptBlox/HaxHell"] = "ScriptBlox/HaxHell의 @5teve3019D 제작",
        ["Loading"] = "로딩 중",
        ["Starting ExperienceSettings. Please wait..."] = "ExperienceSettings를 시작하는 중입니다. 잠시만 기다려 주세요...",
        ["It might have bug and it still in beta."] = "버그가 있을 수 있으며 아직 베타 상태입니다.",
        ["Open Developer console"] = "개발자 콘솔 열기",
        ["Drop Tool"] = "도구 버리기",
        ["Drop all tools"] = "모든 도구 버리기",
        ["<b>Description</b>"] = "<b>설명</b>",
        ["Description"] = "설명",
        ["<b>Remove from the bookmark page</b>"] = "<b>북마크 페이지에서 제거</b>",
        ["Remove from the bookmark page"] = "북마크 페이지에서 제거",
        ["Search here!"] = "여기에서 검색하세요!",
        ["Enter"] = "입력",
        ["[ Select first ] Searcher"] = "[ 먼저 선택 ] 검색",
    },
}


L.SimilarCache =
    setmetatable({}, {__mode = "k"})

L.Candidates = {
    "Type /Help to show all commands or Say something...",
    "Confirm API",
    "Unsaved API",
    "[ Your API here (ChatGPT or Gemini) ]",
    "Status: Unknown",
    "<b><stroke color='rgb(85,255,255)' thickness='2'>AI-Thinking</stroke></b>",
    "<b><stroke color='rgb(255,100,100)' thickness='1' transparency='0'>UNAVAILABLE FEATURES (Old)</stroke></b>",
    "Version:<b> VER </b>",
    "[ User on ScriptBlox/HaxHell ]",
    "“Creator of the ExperiencSettings.”",
    "The ExperienceSettings is debug tools you can use on your own, there are a lot of tools! For HealthBar was a remake of better and smoother and ValueLabels for show values. If your ExperienceSettings was Disabled there are three reasons,  • HumanoidRootPart was removed too long.  • The Experience doesn't support the ExperienceSettings.  • Script failed to load. If you enjoy it, you can support me on discord! Thank you for using ExperienceSettings! ♥️  54% Gui is made by hand 10% Script is made by hand 36% Script is made by ai  Creator: @5teve3019D (Gui, Little Script) Helper: ChatGPT (Script) <-- He got a lot of complaints lol. Little Helper: Copilot of GitHub (Script) Fun fact: Old is ugly than now lol I swear 😂 Oh, you haven't seen it :(  ======================== ➕ = Add something 📢 = Announcements 🔨 = In-develop 🔷 = Plan ahead for updates ✅ = Done ⚠️ = Have issues 🟠 = Updating soon ❌ = Bug ⚫ = Cannot fix ➖ = Disconnected or discontinued ------- 📌 Updated: Update in this information is no longer appear now, please join our discord community to following update! ------- 🔁 In progress: No longer appear features ------- ❌ Failed: No longer appear unavailable features -------  ✨ SCRIPT CREDITS ✨ [ Script Name ] by [ Creator ] [ Verification Status ]  We want to say that your script is awesome, and it is used in our project for debugging and educational purposes. Thank you for your contribution :3 ❤️ - Debugger  -- Credits List -- 'Ketamine' by @Cherry (✓ Verified) 'OG AFEM – Legacy' by @Imperial (✓ Verified) 'Chat' by Unknown user 'UNC' by Unknown user 'REM' by @evildotcom (X Not verified) 'GameProber' by @Imperial (✓ Verified) 'AudioPlayer' by Unknown user 'EmoteSelect' by Unknown user 'Universal Movement Predictor' by @zephyrr (X Not verified) 'Server Position Predictor' by @zephyrr (X Not verified) 'Open Source Universal Chat' by @neutral (X Not verified)  -- Notice to Script Creators -- If you are a script creator listed above and do not want your script to be included, please contact us via our Discord forum, and we will remove it immediately. ",
    "Hide",
    "Oh, if the ExperienceSettings was disabled. You can hide the text by click the button.",
    "Leave The Experience",
    "Reset character",
    "Resume",
    "A button that doesn't do NOTHING",
    "Player :",
    "ON",
    "OFF",
    "Enable ValueLabels",
    "<b><u>ValueLabel</u></b> Show ValueLabel at the Top HealthBar. • FPS - Frame Per second • HP - Health ( How to read: 100.000 HP = 100 HP ) • WS/s - Walkspeed per studs ( How to read: 16.000 WS/s = 16 WS/s )",
    "Shaders - Sunset",
    "<b><u>Shaders</u></b> What a beautiful sunset! Graphic quality recommend 6+",
    "White Light",
    "<b><u>White Light</u></b> Just a PointLight around the you. Useful in the dark.",
    "RGB Light",
    "<b><u>RGB Light</u></b> Same as White Light, but RGB.",
    "ESP",
    "<b><u>ESP</u></b> See all players around the map. Also TextLabel will change color following team color.",
    "Damage Overlay <stroke color='rgb(255,255,255)' thickness='1'><font color='#ff5555'><b>⚠ READ DESCRIPTION BY PRESSING HERE ⚠</b></font></stroke>",
    "<b><u>Damage Overlay</u></b> Displays visual damage effects when your character takes damage.  <stroke color=\"rgb(255,0,0)\" thickness=\"1\"> <font color=\"#ff5555\"> <b>⚠ Photosensitive Epilepsy Warning</b>  This effect may contain: • Flashing lights • Rapid brightness changes • Screen color pulses  If you experience dizziness, eye strain, or discomfort, please turn this feature <b>OFF</b> immediately. </font></stroke>",
    "MoreToggles",
    "<b><u>MoreToggles</u></b> Open second toggle menu.",
    "Show Physics",
    "<b><u>Show Physics</u></b> Displays colorful trajectory lines (\"player speedometers\") and landing prediction points showing where your character is expected to land.",
    "LighterCyan.ai (Discontinued)",
    "<b><u>LighterCyan.ai</u></b> It's discontinued bro. 😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭",
    "Last Death",
    "<b><u>Last Death</u></b> It will show last position where you die at as a frozen ghost character...",
    "ServerPositionPredictor (By @zephyrr)",
    "<b><u>ServerPositionPredictor</u></b> Showing between Server and Client. Server is a second character of you. (Displaying as like ping) Client is you.",
    "HealthBar",
    "<b><u>HealthBar</u></b> Show HealthBar at the Top Right.",
    "Global Physics",
    "<b><u>Global Physics</u></b> Same as Show Physics Toggle, but you're just seeing the physics of other players and objects too.",
    "Disable Death Sound",
    "<b><u>Death Sound</u></b> Play sound after character dead.",
    "Relax / Gif Animation Editor",
    "<b><u>Gif Animation Editor</u></b> Show or hide the Gif Animation Editor window.",
    "FreeCam (Mobile)",
    "<b><u>FreeCam</u></b> \tExplore around the world with FreeCam! (Mobile Only)",
    "Almost Endless Fallen (-50K)",
    "<b><u>Almost Endless Fallen</u></b> Set FallenPartDestroyHeight at -50000.",
    "Flashlight",
    "<b><u>Flashlight</u></b> It will make you in the first person with light, and also recommend set graphic quality at 6+",
    "ESP Highlight Players & Non-Players",
    "<b><u>ESP Highlight Players & Non-Players</u></b> It will highlight HumanoidRootPart. Players is <font color=\"rgb(0,255,0)\">green</font> and Non-Players is <font color=\"rgb(255,10,10)\">red</font>.",
    "Shift Lock (Mobile)",
    "<b><u>Shift Lock</u></b> Shift Lock for Mobile players. Also you can CUSTOMIZE CROSSHAIR by open <b>Settings - 2</b> in <b>Settings - Loader Rejoiner</b>!",
    "Hitbox Shower",
    "<b><u>Hitbox Shower</u></b> See all hitbox players  (Using ViewportFrame)",
    "Settings",
    "Drag",
    "Image",
    "Example: 'Folder/'",
    "Idle's FPS",
    "Save",
    "When Click's FPS",
    "Frame Rate",
    "Idle Frame Rate",
    "When Click",
    "When Click Frame Rate",
    "<u><b>Editor</b></u>",
    "Idle",
    "Relax / Gif Animation Editor by <font color='rgb(85,255,255)'>5teve3019D</font>",
    "Debugs page is <b><u>not</u></b> done yet. Try to press the button at the top right.",
    "Untitled Song",
    "CreatorID: ID ",
    "Creator: NAME",
    "Open Developer console",
    "Drop Tool",
    "Drop all tools",
    "PlaceID: ID",
    "PlayerAge: COUNT",
    "PlayerBirth: DATE",
    "Position: ASIX",
    "TimeOfDay: DATE",
    "AFK: TIME | LastAFK: TIME",
    "CameraMode: ENUM",
    "CharacterType: RIGTYPE",
    "BestDamage: COUNT | LastDamage: COUNT",
    "Deaths: COUNT",
    "Friends in the server: COUNT",
    "BestHeal: COUNT | LastHeal: COUNT",
    "HoldingTool: ITEM",
    "Tools: AMOUNT",
    "JumpPower: NUM",
    "MaxHealth: NUM",
    "PlayingTime: TIME",
    "Real Time Clock: TIME",
    "-- <b>Buttons</b> --",
    "-- <b>Texts</b> --",
    "StandingOn: MATERIAL",
    "WalkSpeed: NUM",
    "<b>Free</b>",
    "<b>Key</b>",
    "<b>Paid</b>",
    "<b>Patched</b>",
    "<b>Verified</b>",
    "<b><i>Bookmark</i></b>",
    "<b><i>View</i></b>",
    "<font size='12'><b>SCRIPTTITLE</b></font> GAMENAME By @API Not supported Click 'View' for more details.",
    "<b>Copy</b>",
    "<b>Execute</b>",
    "<b>Remove from the bookmark page</b>",
    "<b>View</b>",
    "From: API",
    "<b>Back »</b>",
    "<b>Bookmark page</b>",
    "Creation Date: DATE",
    "By @USER",
    "<b>Dislike: COUNT</b>",
    "<b>Description</b>",
    "<b>Like: COUNT</b>",
    "<b>Raw Script</b>",
    "<b>Tag</b>",
    "Universal Script 📌",
    "<b>Visit: COUNT</b>",
    "Search here!",
    "Enter",
    "The ExperienceSettings has been deactivated for some reason.",
    "Copy",
    "Execute",
    "<b>Don't show this again</b>",
    "<b>Remind Me Later</b>",
    "<b><font size=\"12\">Happy 1st Anniversary of The ExperienceSettings!</font></b> We want to let you know for those who using our script; we want to say <b>thank you for using our script!</b>    To close this <b>GUI</b> you can simply click <b><font size=\"9\">\"Remind me later.\"</font></b> or <b><font size=\"9\">\"Dont show this again.\"</font></b> button to continue use The ExperienceSettings.",
    "re-chat",
    "Ask anything..."
}

loc.StripRichText = function(text)
    return tostring(text or ""):gsub("<[^>]->", "")
end

loc.PlainCacheKey = function(text)
    return "__PLAIN_RICHTEXT__" .. loc.StripRichText(text)
end

loc.NormalizeSimilarityText = function(text)
    text = tostring(text or "")
    text = text:gsub("\r\n", "\n")
    text = text:gsub("\r", "\n")
    text = text:gsub("\\n", "\n")
    text = text:gsub("\\t", " ")
    text = text:gsub("\n", " ")
    text = text:gsub("\t", " ")
    text = text:gsub("%s+", " ")
    text = text:gsub("^%s+", "")
    text = text:gsub("%s+$", "")
    text = text:gsub("“", '"'):gsub("”", '"')
    text = text:gsub("‘", "'"):gsub("’", "'")
    return text:lower()
end

loc.SimilarityTextWithoutRichText = function(text)
    return loc.NormalizeSimilarityText(tostring(text or ""):gsub("<[^>]->", ""))
end

loc.CommonPrefixRatio = function(a, b)
    local length = math.min(#a, #b)
    if length == 0 then
        return 1
    end

    local same = 0
    for i = 1, length do
        if a:sub(i, i) ~= b:sub(i, i) then
            break
        end
        same += 1
    end

    return same / math.max(#a, #b)
end

loc.TokenSimilarity = function(a, b)
    local function makeTokens(value)
        local tokens = {}
        for token in value:gmatch("[%w@#%%_%-]+") do
            tokens[#tokens + 1] = token
        end
        return tokens
    end

    local ta = makeTokens(a)
    local tb = makeTokens(b)

    if #ta <= 1 or #tb <= 1 then
        return 0
    end

    local lookup = {}
    for _, token in ipairs(ta) do
        lookup[token] = true
    end

    local common = 0
    local used = {}

    for _, token in ipairs(tb) do
        if lookup[token] and not used[token] then
            used[token] = true
            common += 1
        end
    end

    return (2 * common) / (#ta + #tb)
end

local SelectTextToTranslateOnly

loc.FindSimilarLocalizationSource = function(sourceText, language)
    local source = tostring(sourceText or "")
    if source == "" then
        return nil
    end

    local cache = language and L.Cache[language]

    L.SimilarCache[source] =
        L.SimilarCache[source] or {}

    local languageCache =
        language and L.SimilarCache[source][language]

    if languageCache then
        return languageCache.Resolved
    end

    local normalized = loc.NormalizeSimilarityText(source)
    local plainNormalized =
        loc.SimilarityTextWithoutRichText(source)

    local function hasTranslation(candidate)
        if not cache then
            return false
        end

        if cache[candidate] then
            return true
        end

        local plainKey = loc.PlainCacheKey(candidate)
        if cache[plainKey] then
            return true
        end

        local template = SelectTextToTranslateOnly(candidate)
        if template and template ~= "" then
            if cache[template]
                or cache[loc.PlainCacheKey(template)] then
                return true
            end
        end

        return false
    end

    local function remember(candidate, score)
        L.SimilarCache[source][language or "__ANY__"] = {
            Resolved = candidate,
            Score = score,
        }
        return candidate
    end

    -- First pass: exact normalized match WITH a translation for this language.
    for _, candidate in ipairs(L.Candidates) do
        if loc.NormalizeSimilarityText(candidate) == normalized
            and (not language or hasTranslation(candidate)) then
            return remember(candidate, 1)
        end
    end

    -- Second pass: canonical sources from the translation DB.
    for _, entries in pairs(L.DB) do
        for candidate in pairs(entries) do
            if loc.NormalizeSimilarityText(candidate) == normalized
                and (not language or hasTranslation(candidate)) then
                return remember(candidate, 1)
            end
        end
    end

    -- Third pass: high-confidence fuzzy match, but ONLY among candidates
    -- that actually have a translation for the selected language.
    local bestCandidate = nil
    local bestScore = 0

    local seen = {}

    local function testCandidate(candidate)
        if seen[candidate] then
            return
        end
        seen[candidate] = true

        if candidate == source then
            return
        end

        if language and not hasTranslation(candidate) then
            return
        end

        local candidateNormalized =
            loc.NormalizeSimilarityText(candidate)

        local candidatePlain =
            loc.SimilarityTextWithoutRichText(candidate)

        local lengthRatio =
            math.min(#normalized, #candidateNormalized)
            / math.max(1, math.max(#normalized, #candidateNormalized))

        if lengthRatio < 0.72 then
            return
        end

        local scoreA =
            loc.TokenSimilarity(normalized, candidateNormalized)

        local scoreB =
            loc.TokenSimilarity(plainNormalized, candidatePlain)

        local scoreC =
            loc.CommonPrefixRatio(
                normalized,
                candidateNormalized
            )

        local score =
            math.max(scoreA, scoreB) * 0.75
            + scoreC * 0.25

        if score > bestScore then
            bestScore = score
            bestCandidate = candidate
        end
    end

    for _, candidate in ipairs(L.Candidates) do
        testCandidate(candidate)
    end

    for _, entries in pairs(L.DB) do
        for candidate in pairs(entries) do
            testCandidate(candidate)
        end
    end

    if bestCandidate and bestScore >= 0.92 then
        return remember(bestCandidate, bestScore)
    end

    L.SimilarCache[source][language or "__ANY__"] = false
    return nil
end


-- v23: extra Directly coverage for Search + ProfileStatus + popup/static UI.
local ExtraDirectTranslations = {
    ["ES"] = {
        ["Sorry!"] = "¡Lo siento!",
        ["Untitled Song"] = "Canción sin título",
        ["Status: Unknown"] = "Estado: Desconocido",
        ["Input: Creator..."] = "Entrada: Creador...",
        ["Input: Game ID"] = "Entrada: ID del juego",
        ["No description yet."] = "Aún no hay descripción.",
        ["Friends in the server: COUNT"] = "Amigos en el servidor: COUNT",
        ["PlayerAge: COUNT"] = "Edad del jugador: COUNT",
        ["PlayerBirth: DATE"] = "Nacimiento del jugador: DATE",
        ["Position: ASIX"] = "Posición: ASIX",
        ["TimeOfDay: DATE"] = "Hora del día: DATE",
        ["AFK: TIME | LastAFK: TIME"] = "AFK: TIME | Último AFK: TIME",
        ["BestDamage: COUNT | LastDamage: COUNT"] = "Mejor daño: COUNT | Último daño: COUNT",
        ["BestHeal: COUNT | LastHeal: COUNT"] = "Mejor curación: COUNT | Última curación: COUNT",
        ["Deaths: COUNT"] = "Muertes: COUNT",
        ["Tools: AMOUNT"] = "Herramientas: AMOUNT",
        ["HoldingTool: ITEM"] = "Herramienta equipada: ITEM",
        ["PlayingTime: TIME"] = "Tiempo de juego: TIME",
        ["Real Time Clock: TIME"] = "Reloj en tiempo real: TIME",
        ["StandingOn: MATERIAL"] = "Sobre: MATERIAL",
        ["WalkSpeed: NUM"] = "Velocidad: NUM",
        ["JumpPower: NUM"] = "Potencia de salto: NUM",
        ["MaxHealth: NUM"] = "Salud máxima: NUM",
        ["CameraMode: ENUM"] = "Modo de cámara: ENUM",
        ["CharacterType: RIGTYPE"] = "Tipo de personaje: RIGTYPE",
        ["Creator: NAME"] = "Creador: NAME",
        ["CreatorID: ID"] = "ID del creador: ID",
        ["PlaceID: ID"] = "ID del lugar: ID",
        ["PlayerID: ID"] = "ID del jugador: ID",
        ["<b>Script Type (Default/Free/Paid)</b>"] = "<b>Tipo de script (Predeterminado/Gratis/Pago)</b>",
        ["<b>Verified</b>"] = "<b>Verificado</b>",
        ["<b>Patched</b>"] = "<b>Parcheado</b>",
        ["<b>Key</b>"] = "<b>Clave</b>",
        ["<b>Sort by: Default</b>"] = "<b>Ordenar por: Predeterminado</b>",
        ["<b>Sort order: Default</b>"] = "<b>Orden de clasificación: Predeterminado</b>",
        ["<b>Search API: ScriptBlox</b>"] = "<b>Buscar API: ScriptBlox</b>",
        ["Switch back to the <b>Current version</b>"] = "Cambiar a la <b>versión actual</b>",
        ["Switch to the <b>Preview version</b>"] = "Cambiar a la <b>versión de vista previa</b>",
        ["<b>Script Title</b>"] = "<b>Título del script</b>",
        ["📌 Universal Script"] = "📌 Script universal",
        ["<b>Like: -</b>"] = "<b>Me gusta: -</b>",
        ["<b>Dislike: -</b>"] = "<b>No me gusta: -</b>",
        ["<b>Visit: -</b>"] = "<b>Visitas: -</b>",
        ["<b>Tag</b>"] = "<b>Etiqueta</b>",
        ["<b>Raw Script</b>"] = "<b>Script sin formato</b>",
        ["<b>Copy To Clipboard</b>"] = "<b>Copiar al portapapeles</b>",
        ["<b>Back »</b>"] = "<b>Volver »</b>",
        ["<b>Bookmark page</b>"] = "<b>Página de marcadores</b>",
        ["<b>Execute</b>"] = "<b>Ejecutar</b>",
        ["<b>Copy</b>"] = "<b>Copiar</b>",
        ["<b>View</b>"] = "<b>Ver</b>",
        ["<b>Remove from the bookmark page</b>"] = "<b>Eliminar de la página de marcadores</b>",
        ["The ExperienceSettings has been deactivated for some reason."] = "ExperienceSettings se ha desactivado por algún motivo.",
        ["Leave The Experience"] = "Salir de la experiencia",
        ["A button that doesn't do NOTHING"] = "Un botón que no hace NADA",
        ["<b>Don't show this again</b>"] = "<b>No mostrar esto de nuevo</b>",
        ["<b>Remind Me Later</b>"] = "<b>Recordármelo más tarde</b>",
        ["<font size=\"50\" color=\"rgb(255,0,0)\">Sorry!</font> \n We are making the UI better than before and mobile friendly! \n <font size=\"10\">From White the creator</font>"] = "<font size=\"50\" color=\"rgb(255,0,0)\">¡Lo siento!</font> \n Estamos mejorando la interfaz para que sea mejor que antes y compatible con móviles. \n <font size=\"10\">De White, el creador</font>",
    },
    ["TH"] = {
        ["Sorry!"] = "ขออภัย!",
        ["Untitled Song"] = "เพลงไม่มีชื่อ",
        ["Status: Unknown"] = "สถานะ: ไม่ทราบ",
        ["Input: Creator..."] = "ป้อนข้อมูล: ผู้สร้าง...",
        ["Input: Game ID"] = "ป้อนข้อมูล: Game ID",
        ["No description yet."] = "ยังไม่มีคำอธิบาย",
        ["Friends in the server: COUNT"] = "เพื่อนในเซิร์ฟเวอร์: COUNT",
        ["PlayerAge: COUNT"] = "อายุผู้เล่น: COUNT",
        ["PlayerBirth: DATE"] = "วันเกิดผู้เล่น: DATE",
        ["Position: ASIX"] = "ตำแหน่ง: ASIX",
        ["TimeOfDay: DATE"] = "เวลาของวัน: DATE",
        ["AFK: TIME | LastAFK: TIME"] = "AFK: TIME | AFK ล่าสุด: TIME",
        ["BestDamage: COUNT | LastDamage: COUNT"] = "ดาเมจสูงสุด: COUNT | ดาเมจล่าสุด: COUNT",
        ["BestHeal: COUNT | LastHeal: COUNT"] = "ฮีลสูงสุด: COUNT | ฮีลล่าสุด: COUNT",
        ["Deaths: COUNT"] = "ตาย: COUNT",
        ["Tools: AMOUNT"] = "เครื่องมือ: AMOUNT",
        ["HoldingTool: ITEM"] = "ถือเครื่องมือ: ITEM",
        ["PlayingTime: TIME"] = "เวลาเล่น: TIME",
        ["Real Time Clock: TIME"] = "นาฬิกาเวลาจริง: TIME",
        ["StandingOn: MATERIAL"] = "ยืนอยู่บน: MATERIAL",
        ["WalkSpeed: NUM"] = "ความเร็วเดิน: NUM",
        ["JumpPower: NUM"] = "พลังการกระโดด: NUM",
        ["MaxHealth: NUM"] = "พลังชีวิตสูงสุด: NUM",
        ["CameraMode: ENUM"] = "โหมดกล้อง: ENUM",
        ["CharacterType: RIGTYPE"] = "ประเภทตัวละคร: RIGTYPE",
        ["Creator: NAME"] = "ผู้สร้าง: NAME",
        ["CreatorID: ID"] = "ID ผู้สร้าง: ID",
        ["PlaceID: ID"] = "ID สถานที่: ID",
        ["PlayerID: ID"] = "ID ผู้เล่น: ID",
        ["<b>Script Type (Default/Free/Paid)</b>"] = "<b>ประเภทสคริปต์ (ค่าเริ่มต้น/ฟรี/เสียเงิน)</b>",
        ["<b>Verified</b>"] = "<b>ยืนยันแล้ว</b>",
        ["<b>Patched</b>"] = "<b>แก้ไขแล้ว</b>",
        ["<b>Key</b>"] = "<b>มีคีย์</b>",
        ["<b>Sort by: Default</b>"] = "<b>เรียงตาม: ค่าเริ่มต้น</b>",
        ["<b>Sort order: Default</b>"] = "<b>ลำดับการเรียง: ค่าเริ่มต้น</b>",
        ["<b>Search API: ScriptBlox</b>"] = "<b>ค้นหา API: ScriptBlox</b>",
        ["Switch back to the <b>Current version</b>"] = "สลับกลับไปยัง<b>เวอร์ชันปัจจุบัน</b>",
        ["Switch to the <b>Preview version</b>"] = "สลับไปยัง<b>เวอร์ชันตัวอย่าง</b>",
        ["<b>Script Title</b>"] = "<b>ชื่อสคริปต์</b>",
        ["📌 Universal Script"] = "📌 สคริปต์ Universal",
        ["<b>Like: -</b>"] = "<b>ถูกใจ: -</b>",
        ["<b>Dislike: -</b>"] = "<b>ไม่ถูกใจ: -</b>",
        ["<b>Visit: -</b>"] = "<b>เข้าชม: -</b>",
        ["<b>Tag</b>"] = "<b>แท็ก</b>",
        ["<b>Raw Script</b>"] = "<b>สคริปต์ดิบ</b>",
        ["<b>Copy To Clipboard</b>"] = "<b>คัดลอกไปยังคลิปบอร์ด</b>",
        ["<b>Back »</b>"] = "<b>ย้อนกลับ »</b>",
        ["<b>Bookmark page</b>"] = "<b>หน้าบุ๊กมาร์ก</b>",
        ["<b>Execute</b>"] = "<b>รัน</b>",
        ["<b>Copy</b>"] = "<b>คัดลอก</b>",
        ["<b>View</b>"] = "<b>ดู</b>",
        ["<b>Remove from the bookmark page</b>"] = "<b>นำออกจากหน้าบุ๊กมาร์ก</b>",
        ["The ExperienceSettings has been deactivated for some reason."] = "ExperienceSettings ถูกปิดใช้งานด้วยเหตุผลบางอย่าง",
        ["Leave The Experience"] = "ออกจาก Experience",
        ["A button that doesn't do NOTHING"] = "ปุ่มที่ไม่ได้ทำอะไรเลย",
        ["<b>Don't show this again</b>"] = "<b>ไม่ต้องแสดงอีก</b>",
        ["<b>Remind Me Later</b>"] = "<b>เตือนฉันภายหลัง</b>",
        ["<font size=\"50\" color=\"rgb(255,0,0)\">Sorry!</font> \n We are making the UI better than before and mobile friendly! \n <font size=\"10\">From White the creator</font>"] = "<font size=\"50\" color=\"rgb(255,0,0)\">ขออภัย!</font> \n เรากำลังปรับปรุง UI ให้ดีขึ้นกว่าเดิมและรองรับมือถือ! \n <font size=\"10\">จาก White ผู้สร้าง</font>",
    },
    ["PT-BR"] = {
        ["Sorry!"] = "Desculpe!",
        ["Untitled Song"] = "Música sem título",
        ["Status: Unknown"] = "Status: Desconhecido",
        ["Input: Creator..."] = "Entrada: Criador...",
        ["Input: Game ID"] = "Entrada: ID do jogo",
        ["No description yet."] = "Ainda não há descrição.",
        ["Friends in the server: COUNT"] = "Amigos no servidor: COUNT",
        ["PlayerAge: COUNT"] = "Idade do jogador: COUNT",
        ["PlayerBirth: DATE"] = "Nascimento do jogador: DATE",
        ["Position: ASIX"] = "Posição: ASIX",
        ["TimeOfDay: DATE"] = "Hora do dia: DATE",
        ["AFK: TIME | LastAFK: TIME"] = "AFK: TIME | Último AFK: TIME",
        ["BestDamage: COUNT | LastDamage: COUNT"] = "Melhor dano: COUNT | Último dano: COUNT",
        ["BestHeal: COUNT | LastHeal: COUNT"] = "Melhor cura: COUNT | Última cura: COUNT",
        ["Deaths: COUNT"] = "Mortes: COUNT",
        ["Tools: AMOUNT"] = "Ferramentas: AMOUNT",
        ["HoldingTool: ITEM"] = "Ferramenta equipada: ITEM",
        ["PlayingTime: TIME"] = "Tempo de jogo: TIME",
        ["Real Time Clock: TIME"] = "Relógio em tempo real: TIME",
        ["StandingOn: MATERIAL"] = "Em cima de: MATERIAL",
        ["WalkSpeed: NUM"] = "Velocidade: NUM",
        ["JumpPower: NUM"] = "Poder de pulo: NUM",
        ["MaxHealth: NUM"] = "Vida máxima: NUM",
        ["CameraMode: ENUM"] = "Modo de câmera: ENUM",
        ["CharacterType: RIGTYPE"] = "Tipo de personagem: RIGTYPE",
        ["Creator: NAME"] = "Criador: NAME",
        ["CreatorID: ID"] = "ID do criador: ID",
        ["PlaceID: ID"] = "ID do lugar: ID",
        ["PlayerID: ID"] = "ID do jogador: ID",
        ["<b>Script Type (Default/Free/Paid)</b>"] = "<b>Tipo de script (Padrão/Grátis/Pago)</b>",
        ["<b>Verified</b>"] = "<b>Verificado</b>",
        ["<b>Patched</b>"] = "<b>Corrigido</b>",
        ["<b>Key</b>"] = "<b>Key</b>",
        ["<b>Sort by: Default</b>"] = "<b>Ordenar por: Padrão</b>",
        ["<b>Sort order: Default</b>"] = "<b>Ordem: Padrão</b>",
        ["<b>Search API: ScriptBlox</b>"] = "<b>Pesquisar API: ScriptBlox</b>",
        ["Switch back to the <b>Current version</b>"] = "Voltar para a <b>versão atual</b>",
        ["Switch to the <b>Preview version</b>"] = "Mudar para a <b>versão de prévia</b>",
        ["<b>Script Title</b>"] = "<b>Título do script</b>",
        ["📌 Universal Script"] = "📌 Script Universal",
        ["<b>Like: -</b>"] = "<b>Like: -</b>",
        ["<b>Dislike: -</b>"] = "<b>Dislike: -</b>",
        ["<b>Visit: -</b>"] = "<b>Visitas: -</b>",
        ["<b>Tag</b>"] = "<b>Tag</b>",
        ["<b>Raw Script</b>"] = "<b>Script bruto</b>",
        ["<b>Copy To Clipboard</b>"] = "<b>Copiar para a área de transferência</b>",
        ["<b>Back »</b>"] = "<b>Voltar »</b>",
        ["<b>Bookmark page</b>"] = "<b>Página de favoritos</b>",
        ["<b>Execute</b>"] = "<b>Executar</b>",
        ["<b>Copy</b>"] = "<b>Copiar</b>",
        ["<b>View</b>"] = "<b>Ver</b>",
        ["<b>Remove from the bookmark page</b>"] = "<b>Remover da página de favoritos</b>",
        ["The ExperienceSettings has been deactivated for some reason."] = "O ExperienceSettings foi desativado por algum motivo.",
        ["Leave The Experience"] = "Sair da experiência",
        ["A button that doesn't do NOTHING"] = "Um botão que não faz NADA",
        ["<b>Don't show this again</b>"] = "<b>Não mostrar novamente</b>",
        ["<b>Remind Me Later</b>"] = "<b>Lembrar mais tarde</b>",
        ["<font size=\"50\" color=\"rgb(255,0,0)\">Sorry!</font> \n We are making the UI better than before and mobile friendly! \n <font size=\"10\">From White the creator</font>"] = "<font size=\"50\" color=\"rgb(255,0,0)\">Desculpe!</font> \n Estamos melhorando a interface para ficar melhor do que antes e compatível com celulares! \n <font size=\"10\">Do White, o criador</font>",
    },
    ["PT-PT"] = {
        ["Sorry!"] = "Desculpa!",
        ["Untitled Song"] = "Música sem título",
        ["Status: Unknown"] = "Estado: Desconhecido",
        ["Input: Creator..."] = "Entrada: Criador...",
        ["Input: Game ID"] = "Entrada: ID do jogo",
        ["No description yet."] = "Ainda não existe descrição.",
        ["Friends in the server: COUNT"] = "Amigos no servidor: COUNT",
        ["PlayerAge: COUNT"] = "Idade do jogador: COUNT",
        ["PlayerBirth: DATE"] = "Nascimento do jogador: DATE",
        ["Position: ASIX"] = "Posição: ASIX",
        ["TimeOfDay: DATE"] = "Hora do dia: DATE",
        ["AFK: TIME | LastAFK: TIME"] = "AFK: TIME | Último AFK: TIME",
        ["BestDamage: COUNT | LastDamage: COUNT"] = "Melhor dano: COUNT | Último dano: COUNT",
        ["BestHeal: COUNT | LastHeal: COUNT"] = "Melhor cura: COUNT | Última cura: COUNT",
        ["Deaths: COUNT"] = "Mortes: COUNT",
        ["Tools: AMOUNT"] = "Ferramentas: AMOUNT",
        ["HoldingTool: ITEM"] = "Ferramenta equipada: ITEM",
        ["PlayingTime: TIME"] = "Tempo de jogo: TIME",
        ["Real Time Clock: TIME"] = "Relógio em tempo real: TIME",
        ["StandingOn: MATERIAL"] = "Em cima de: MATERIAL",
        ["WalkSpeed: NUM"] = "Velocidade: NUM",
        ["JumpPower: NUM"] = "Potência de salto: NUM",
        ["MaxHealth: NUM"] = "Vida máxima: NUM",
        ["CameraMode: ENUM"] = "Modo de câmara: ENUM",
        ["CharacterType: RIGTYPE"] = "Tipo de personagem: RIGTYPE",
        ["Creator: NAME"] = "Criador: NAME",
        ["CreatorID: ID"] = "ID do criador: ID",
        ["PlaceID: ID"] = "ID do local: ID",
        ["PlayerID: ID"] = "ID do jogador: ID",
        ["<b>Script Type (Default/Free/Paid)</b>"] = "<b>Tipo de script (Predefinido/Grátis/Pago)</b>",
        ["<b>Verified</b>"] = "<b>Verificado</b>",
        ["<b>Patched</b>"] = "<b>Corrigido</b>",
        ["<b>Key</b>"] = "<b>Chave</b>",
        ["<b>Sort by: Default</b>"] = "<b>Ordenar por: Predefinido</b>",
        ["<b>Sort order: Default</b>"] = "<b>Ordem: Predefinida</b>",
        ["<b>Search API: ScriptBlox</b>"] = "<b>Pesquisar API: ScriptBlox</b>",
        ["Switch back to the <b>Current version</b>"] = "Voltar para a <b>versão atual</b>",
        ["Switch to the <b>Preview version</b>"] = "Mudar para a <b>versão de pré-visualização</b>",
        ["<b>Script Title</b>"] = "<b>Título do script</b>",
        ["📌 Universal Script"] = "📌 Script Universal",
        ["<b>Like: -</b>"] = "<b>Gostos: -</b>",
        ["<b>Dislike: -</b>"] = "<b>Não gostos: -</b>",
        ["<b>Visit: -</b>"] = "<b>Visitas: -</b>",
        ["<b>Tag</b>"] = "<b>Etiqueta</b>",
        ["<b>Raw Script</b>"] = "<b>Script bruto</b>",
        ["<b>Copy To Clipboard</b>"] = "<b>Copiar para a área de transferência</b>",
        ["<b>Back »</b>"] = "<b>Voltar »</b>",
        ["<b>Bookmark page</b>"] = "<b>Página de favoritos</b>",
        ["<b>Execute</b>"] = "<b>Executar</b>",
        ["<b>Copy</b>"] = "<b>Copiar</b>",
        ["<b>View</b>"] = "<b>Ver</b>",
        ["<b>Remove from the bookmark page</b>"] = "<b>Remover da página de favoritos</b>",
        ["The ExperienceSettings has been deactivated for some reason."] = "O ExperienceSettings foi desativado por algum motivo.",
        ["Leave The Experience"] = "Sair da experiência",
        ["A button that doesn't do NOTHING"] = "Um botão que não faz NADA",
        ["<b>Don't show this again</b>"] = "<b>Não mostrar novamente</b>",
        ["<b>Remind Me Later</b>"] = "<b>Lembrar-me mais tarde</b>",
        ["<font size=\"50\" color=\"rgb(255,0,0)\">Sorry!</font> \n We are making the UI better than before and mobile friendly! \n <font size=\"10\">From White the creator</font>"] = "<font size=\"50\" color=\"rgb(255,0,0)\">Desculpa!</font> \n Estamos a melhorar a interface para ficar melhor do que antes e compatível com telemóveis! \n <font size=\"10\">Do White, o criador</font>",
    },
    ["RU"] = {
        ["Sorry!"] = "Извините!",
        ["Untitled Song"] = "Песня без названия",
        ["Status: Unknown"] = "Статус: неизвестен",
        ["Input: Creator..."] = "Ввод: создатель...",
        ["Input: Game ID"] = "Ввод: ID игры",
        ["No description yet."] = "Описания пока нет.",
        ["Friends in the server: COUNT"] = "Друзья на сервере: COUNT",
        ["PlayerAge: COUNT"] = "Возраст игрока: COUNT",
        ["PlayerBirth: DATE"] = "Дата рождения игрока: DATE",
        ["Position: ASIX"] = "Позиция: ASIX",
        ["TimeOfDay: DATE"] = "Время суток: DATE",
        ["AFK: TIME | LastAFK: TIME"] = "AFK: TIME | Последний AFK: TIME",
        ["BestDamage: COUNT | LastDamage: COUNT"] = "Лучший урон: COUNT | Последний урон: COUNT",
        ["BestHeal: COUNT | LastHeal: COUNT"] = "Лучшее лечение: COUNT | Последнее лечение: COUNT",
        ["Deaths: COUNT"] = "Смерти: COUNT",
        ["Tools: AMOUNT"] = "Инструменты: AMOUNT",
        ["HoldingTool: ITEM"] = "В руках: ITEM",
        ["PlayingTime: TIME"] = "Время игры: TIME",
        ["Real Time Clock: TIME"] = "Часы реального времени: TIME",
        ["StandingOn: MATERIAL"] = "Стоит на: MATERIAL",
        ["WalkSpeed: NUM"] = "Скорость ходьбы: NUM",
        ["JumpPower: NUM"] = "Сила прыжка: NUM",
        ["MaxHealth: NUM"] = "Макс. здоровье: NUM",
        ["CameraMode: ENUM"] = "Режим камеры: ENUM",
        ["CharacterType: RIGTYPE"] = "Тип персонажа: RIGTYPE",
        ["Creator: NAME"] = "Создатель: NAME",
        ["CreatorID: ID"] = "ID создателя: ID",
        ["PlaceID: ID"] = "ID места: ID",
        ["PlayerID: ID"] = "ID игрока: ID",
        ["<b>Script Type (Default/Free/Paid)</b>"] = "<b>Тип скрипта (По умолчанию/Бесплатный/Платный)</b>",
        ["<b>Verified</b>"] = "<b>Проверено</b>",
        ["<b>Patched</b>"] = "<b>Исправлено</b>",
        ["<b>Key</b>"] = "<b>Ключ</b>",
        ["<b>Sort by: Default</b>"] = "<b>Сортировка: По умолчанию</b>",
        ["<b>Sort order: Default</b>"] = "<b>Порядок сортировки: По умолчанию</b>",
        ["<b>Search API: ScriptBlox</b>"] = "<b>Поиск API: ScriptBlox</b>",
        ["Switch back to the <b>Current version</b>"] = "Вернуться к <b>текущей версии</b>",
        ["Switch to the <b>Preview version</b>"] = "Перейти к <b>предварительной версии</b>",
        ["<b>Script Title</b>"] = "<b>Название скрипта</b>",
        ["📌 Universal Script"] = "📌 Универсальный скрипт",
        ["<b>Like: -</b>"] = "<b>Лайков: -</b>",
        ["<b>Dislike: -</b>"] = "<b>Дизлайков: -</b>",
        ["<b>Visit: -</b>"] = "<b>Посещений: -</b>",
        ["<b>Tag</b>"] = "<b>Тег</b>",
        ["<b>Raw Script</b>"] = "<b>Исходный скрипт</b>",
        ["<b>Copy To Clipboard</b>"] = "<b>Копировать в буфер обмена</b>",
        ["<b>Back »</b>"] = "<b>Назад »</b>",
        ["<b>Bookmark page</b>"] = "<b>Страница закладок</b>",
        ["<b>Execute</b>"] = "<b>Выполнить</b>",
        ["<b>Copy</b>"] = "<b>Копировать</b>",
        ["<b>View</b>"] = "<b>Просмотр</b>",
        ["<b>Remove from the bookmark page</b>"] = "<b>Удалить со страницы закладок</b>",
        ["The ExperienceSettings has been deactivated for some reason."] = "ExperienceSettings была отключена по какой-то причине.",
        ["Leave The Experience"] = "Выйти из Experience",
        ["A button that doesn't do NOTHING"] = "Кнопка, которая НИЧЕГО не делает",
        ["<b>Don't show this again</b>"] = "<b>Больше не показывать</b>",
        ["<b>Remind Me Later</b>"] = "<b>Напомнить позже</b>",
        ["<font size=\"50\" color=\"rgb(255,0,0)\">Sorry!</font> \n We are making the UI better than before and mobile friendly! \n <font size=\"10\">From White the creator</font>"] = "<font size=\"50\" color=\"rgb(255,0,0)\">Извините!</font> \n Мы улучшаем интерфейс, чтобы он стал лучше прежнего и удобнее на мобильных устройствах! \n <font size=\"10\">От White, создателя</font>",
    },
    ["KO"] = {
        ["Sorry!"] = "죄송합니다!",
        ["Untitled Song"] = "제목 없는 노래",
        ["Status: Unknown"] = "상태: 알 수 없음",
        ["Input: Creator..."] = "입력: 제작자...",
        ["Input: Game ID"] = "입력: 게임 ID",
        ["No description yet."] = "아직 설명이 없습니다.",
        ["Friends in the server: COUNT"] = "서버의 친구: COUNT",
        ["PlayerAge: COUNT"] = "플레이어 나이: COUNT",
        ["PlayerBirth: DATE"] = "플레이어 생일: DATE",
        ["Position: ASIX"] = "위치: ASIX",
        ["TimeOfDay: DATE"] = "시간: DATE",
        ["AFK: TIME | LastAFK: TIME"] = "AFK: TIME | 마지막 AFK: TIME",
        ["BestDamage: COUNT | LastDamage: COUNT"] = "최고 피해: COUNT | 마지막 피해: COUNT",
        ["BestHeal: COUNT | LastHeal: COUNT"] = "최고 회복: COUNT | 마지막 회복: COUNT",
        ["Deaths: COUNT"] = "사망: COUNT",
        ["Tools: AMOUNT"] = "도구: AMOUNT",
        ["HoldingTool: ITEM"] = "들고 있는 도구: ITEM",
        ["PlayingTime: TIME"] = "플레이 시간: TIME",
        ["Real Time Clock: TIME"] = "실시간 시계: TIME",
        ["StandingOn: MATERIAL"] = "밟고 있음: MATERIAL",
        ["WalkSpeed: NUM"] = "걷기 속도: NUM",
        ["JumpPower: NUM"] = "점프력: NUM",
        ["MaxHealth: NUM"] = "최대 체력: NUM",
        ["CameraMode: ENUM"] = "카메라 모드: ENUM",
        ["CharacterType: RIGTYPE"] = "캐릭터 유형: RIGTYPE",
        ["Creator: NAME"] = "제작자: NAME",
        ["CreatorID: ID"] = "제작자 ID: ID",
        ["PlaceID: ID"] = "장소 ID: ID",
        ["PlayerID: ID"] = "플레이어 ID: ID",
        ["<b>Script Type (Default/Free/Paid)</b>"] = "<b>스크립트 유형 (기본/무료/유료)</b>",
        ["<b>Verified</b>"] = "<b>검증됨</b>",
        ["<b>Patched</b>"] = "<b>패치됨</b>",
        ["<b>Key</b>"] = "<b>키</b>",
        ["<b>Sort by: Default</b>"] = "<b>정렬 기준: 기본값</b>",
        ["<b>Sort order: Default</b>"] = "<b>정렬 순서: 기본값</b>",
        ["<b>Search API: ScriptBlox</b>"] = "<b>API 검색: ScriptBlox</b>",
        ["Switch back to the <b>Current version</b>"] = "<b>현재 버전</b>으로 돌아가기",
        ["Switch to the <b>Preview version</b>"] = "<b>미리보기 버전</b>으로 전환",
        ["<b>Script Title</b>"] = "<b>스크립트 제목</b>",
        ["📌 Universal Script"] = "📌 유니버설 스크립트",
        ["<b>Like: -</b>"] = "<b>좋아요: -</b>",
        ["<b>Dislike: -</b>"] = "<b>싫어요: -</b>",
        ["<b>Visit: -</b>"] = "<b>방문: -</b>",
        ["<b>Tag</b>"] = "<b>태그</b>",
        ["<b>Raw Script</b>"] = "<b>원본 스크립트</b>",
        ["<b>Copy To Clipboard</b>"] = "<b>클립보드에 복사</b>",
        ["<b>Back »</b>"] = "<b>뒤로 »</b>",
        ["<b>Bookmark page</b>"] = "<b>북마크 페이지</b>",
        ["<b>Execute</b>"] = "<b>실행</b>",
        ["<b>Copy</b>"] = "<b>복사</b>",
        ["<b>View</b>"] = "<b>보기</b>",
        ["<b>Remove from the bookmark page</b>"] = "<b>북마크 페이지에서 제거</b>",
        ["The ExperienceSettings has been deactivated for some reason."] = "ExperienceSettings가 어떤 이유로 비활성화되었습니다.",
        ["Leave The Experience"] = "Experience 나가기",
        ["A button that doesn't do NOTHING"] = "아무것도 하지 않는 버튼",
        ["<b>Don't show this again</b>"] = "<b>다시 표시하지 않기</b>",
        ["<b>Remind Me Later</b>"] = "<b>나중에 알림</b>",
        ["<font size=\"50\" color=\"rgb(255,0,0)\">Sorry!</font> \n We are making the UI better than before and mobile friendly! \n <font size=\"10\">From White the creator</font>"] = "<font size=\"50\" color=\"rgb(255,0,0)\">죄송합니다!</font> \n 저희는 UI를 이전보다 더 좋고 모바일 친화적으로 개선하고 있습니다! \n <font size=\"10\">제작자 White</font>",
    },
}

for language, entries in pairs(ExtraDirectTranslations) do
    L.DB[language] = L.DB[language] or {}
    for sourceText, translatedText in pairs(entries) do
        L.DB[language][sourceText] = translatedText
    end
end

-- Import the static L.DB.
for language, entries in pairs(L.DB) do
    for sourceText, translatedText in pairs(entries) do
        L.Cache[language][sourceText] = translatedText

        local plainKey = loc.PlainCacheKey(sourceText)
        if plainKey ~= loc.PlainCacheKey("") then
            L.Cache[language][plainKey] = translatedText
        end
    end
end

loc.IsTranslationSkipped = function(obj)
    local current = obj

    while current do
        if current:GetAttribute("SkipAutoTranslate") == true then
            return true
        end

        if current == ExperienceSettings then
            break
        end

        current = current.Parent
    end

    return false
end

loc.SaveTranslationCache = function(language)
    if not writefile then
        return false
    end

    language = language or L.CurrentLanguage
    local selectedCache = L.Cache[language]
    if type(selectedCache) ~= "table" then
        return false
    end

    -- Persist only the selected language, not stale entries for every language.
    local ok, encoded = pcall(function()
        return s.HttpService:JSONEncode({
            Version = 2,
            Language = language,
            Languages = {
                [language] = selectedCache
            }
        })
    end)

    if not ok then
        return false
    end

    local saveOk = pcall(function()
        if not isfolder("ExperienceSettings") then
            makefolder("ExperienceSettings")
        end
        writefile(L.CacheFile, encoded)
    end)

    return saveOk
end

loc.LoadTranslationCache = function()
    if not readfile or not isfile or not isfile(L.CacheFile) then
        return
    end

    local rawCache
    local okRead = pcall(function()
        rawCache = readfile(L.CacheFile)
    end)
    if not okRead or type(rawCache) ~= "string" then
        return
    end

    local ok, decoded = pcall(function()
        return s.HttpService:JSONDecode(rawCache)
    end)
    if not ok or type(decoded) ~= "table"
        or type(decoded.Languages) ~= "table" then
        return
    end

    local language = decoded.Language
    if type(language) ~= "string" or type(L.Cache[language]) ~= "table" then
        -- Legacy files did not record the active language. Use the current
        -- default language rather than merging every old language together.
        language = L.CurrentLanguage
    end

    local entries = decoded.Languages[language]
    if type(entries) == "table" and type(L.Cache[language]) == "table" then
        for sourceText, translatedText in pairs(entries) do
            if type(sourceText) == "string" and type(translatedText) == "string" then
                L.Cache[language][sourceText] = translatedText
            end
        end
    end

    local languageCount = 0
    for _ in pairs(decoded.Languages) do
        languageCount += 1
    end

    -- Keep a one-time backup before migrating a legacy multi-language cache.
    if decoded.Version ~= 2 or languageCount ~= 1 or decoded.Language ~= language then
        pcall(function()
            local backupFile = "ExperienceSettings/translation_cache.backup.json"
            if not isfile(backupFile) then
                writefile(backupFile, rawCache)
            end
        end)
        loc.SaveTranslationCache(language)
    end
end

loc.LoadTranslationCache()

-- Protect only the dynamic parts.
-- Example:
--   "Health: 100" -> "Health: __DYNAMIC_1__"
SelectTextToTranslateOnly = function(text)
    local source = tostring(text or "")
    local protected = {}
    local counter = 0

    local function protect(value)
        counter += 1
        protected[counter] = value
        return string.format("__DYNAMIC_%d__", counter)
    end

    -- RichText tags are permanent syntax, not dynamic values.
    -- Keeping them literal prevents adjacent-tag matching failures.

    source = source:gsub("https?://%S+", function(value)
        return protect(value)
    end)

    source = source:gsub("rbxassetid://%d+", function(value)
        return protect(value)
    end)

    source = source:gsub("@[%w_]+", function(value)
        return protect(value)
    end)

    -- Common runtime placeholders used by ExperienceSettings.
    source = source:gsub("%f[%a](VER|COUNT|DATE|TIME|ASIX|ENUM|RIGTYPE|ITEM|MATERIAL|NUM|NAME|ID|AMOUNT)%f[%A]", function(value)
        return protect(value)
    end)

    source = source:gsub("[%+%-]?%d[%d,%.]*%%?", function(value)
        return protect(value)
    end)

    return source, protected
end

loc.RestoreSelectedText = function(text, protected)
    local result = tostring(text or "")

    for index = #protected, 1, -1 do
        local token = string.format("__DYNAMIC_%d__", index)

        result = result:gsub(token, function()
            return protected[index]
        end)
    end

    return result
end

-- Normalize static DB entries so runtime dynamic values can match the same template.
for language, entries in pairs(L.DB) do
    for sourceText, translatedText in pairs(entries) do
        local template, protected = SelectTextToTranslateOnly(sourceText)
        if template ~= sourceText and not L.Cache[language][template] then
            local translatedTemplate = translatedText
            for index = #protected, 1, -1 do
                local value = tostring(protected[index] or "")
                if value ~= "" then
                    local escaped = value:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
                    translatedTemplate = translatedTemplate:gsub(
                        escaped,
                        string.format("__DYNAMIC_%d__", index),
                        1
                    )
                end
            end
            L.Cache[language][template] = translatedTemplate
            L.Cache[language][loc.PlainCacheKey(template)] = translatedTemplate
        end
    end
end


loc.GetLocalizationTranslator = function(language)
    if language == "EN" then
        return nil
    end

    local existing = L.Translators[language]
    if existing then
        return existing
    end

    local localeId = L.LocaleMap[language]
    if not localeId then
        return nil
    end

    local ok, translator = pcall(function()
        return s.LocalizationService:GetTranslatorForLocaleAsync(localeId)
    end)

    if ok and translator then
        L.Translators[language] = translator
        L.Ready[language] = true
        return translator
    end

    L.Ready[language] = false
    return nil
end

-- Localizate: Roblox LocalizationService / Localization Table only.
loc.Localizate = function(obj, sourceText, language, preferredSource)
    if language == "EN" or not obj or sourceText == "" then
        return nil
    end

    local translator = loc.GetLocalizationTranslator(language)
    if not translator then
        return nil
    end

    local tried = {}
    local function trySource(candidate)
        candidate = tostring(candidate or "")
        if candidate == "" or tried[candidate] then
            return nil
        end

        tried[candidate] = true

        local ok, translated = pcall(function()
            return translator:Translate(obj, candidate)
        end)

        if not ok or type(translated) ~= "string" then
            return nil
        end

        -- Roblox returns the source text when no translated entry is available.
        if translated == candidate then
            return nil
        end

        return translated
    end

    -- 1. Path-based canonical source from the full Device export.
    -- This is the primary source now; runtime text is used as fallback.
    if preferredSource and preferredSource ~= "" then
        local translated = trySource(preferredSource)
        if translated then
            return translated, preferredSource
        end
    end

    -- 2. Exact runtime source.
    local translated = trySource(sourceText)
    if translated then
        return translated, sourceText
    end

    -- 3. Equivalent whitespace source.
    -- This fixes real newlines, literal "\\n", tabs, and repeated spaces.
    local normalizedCandidate =
        sourceText
            :gsub("\\r\\n", " ")
            :gsub("[\\r\\n\\t]", " ")
            :gsub("\\\\n", " ")
            :gsub("%s+", " ")
            :gsub("^%s+", "")
            :gsub("%s+$", "")

    if normalizedCandidate ~= sourceText then
        translated = trySource(normalizedCandidate)
        if translated then
            return translated, normalizedCandidate
        end
    end

    -- 3. Find the closest known canonical source.
    local similarSource =
        loc.FindSimilarLocalizationSource(sourceText, language)

    if similarSource and similarSource ~= sourceText then
        translated = trySource(similarSource)
        if translated then
            return translated, similarSource
        end
    end

    return nil
end

loc.GetCachedTranslation = function(sourceText, language)
    if language == "EN" then
        return sourceText
    end

    local cache = L.Cache[language]
    if not cache then
        return nil
    end

    local exact = cache[sourceText]
    if exact then
        return exact
    end

    local plain = cache[loc.PlainCacheKey(sourceText)]
    if plain then
        return plain
    end

    local template, protected =
        SelectTextToTranslateOnly(sourceText)

    local cachedTemplate = cache[template]
    if cachedTemplate then
        return loc.RestoreSelectedText(cachedTemplate, protected)
    end

    local cachedPlainTemplate = cache[loc.PlainCacheKey(template)]
    if cachedPlainTemplate then
        return loc.RestoreSelectedText(cachedPlainTemplate, protected)
    end

    return nil, template, protected
end

L.State =
    setmetatable({}, {__mode = "k"})

-- Guards property writes performed by click-state Localization so the
-- Text/PlaceholderText change signal cannot recursively re-translate itself.
L.LocalizationWrite =
    setmetatable({}, {__mode = "k"})

loc.EscapeLuaPattern = function(value)
    return tostring(value or ""):gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
end

-- Match the current text against a permanent/dynamic template.
-- Example:
--   "Health: __DYNAMIC_1__"
--   "Health: 100"
-- -> { [1] = "100" }
loc.MatchDynamicTemplate = function(template, text)
    template = tostring(template or "")
    text = tostring(text or "")

    local patternParts = {"^"}
    local dynamicOrder = {}
    local cursor = 1

    while true do
        local startPos, endPos, index =
            template:find("__DYNAMIC_(%d+)__", cursor)

        if not startPos then
            local tail = template:sub(cursor)
            if tail ~= "" then
                patternParts[#patternParts + 1] = loc.EscapeLuaPattern(tail)
            end
            break
        end

        local permanent = template:sub(cursor, startPos - 1)

        if permanent ~= "" then
            patternParts[#patternParts + 1] = loc.EscapeLuaPattern(permanent)
        end

        patternParts[#patternParts + 1] = "(.-)"
        dynamicOrder[#dynamicOrder + 1] = tonumber(index)
        cursor = endPos + 1
    end

    patternParts[#patternParts + 1] = "$"

    local captures = {
        string.match(
            text,
            table.concat(patternParts)
        )
    }

    if #dynamicOrder == 0 then
        return text == template and {}
            or nil
    end

    if #captures ~= #dynamicOrder then
        return nil
    end

    local values = {}

    for i, index in ipairs(dynamicOrder) do
        values[index] = captures[i]
    end

    return values
end

loc.FormatPathName = function(name)
    name = tostring(name or "")

    if name:match("^[A-Za-z_][A-Za-z0-9_]*$") then
        return "." .. name
    end

    return "[" .. string.format("%q", name) .. "]"
end

loc.GetObjectPath = function(obj)
    if not obj then
        return nil
    end

    local parts = {}
    local current = obj

    while current and current ~= s.CoreGui do
        local parent = current.Parent

        if not parent then
            break
        end

        local children = parent:GetChildren()
        local childIndex = nil
        local sameNameCount = 0

        for index, child in ipairs(children) do
            if child.Name == current.Name then
                sameNameCount = sameNameCount + 1
            end

            if child == current then
                childIndex = index
            end
        end

        if sameNameCount > 1 and childIndex then
            table.insert(
                parts,
                1,
                ":GetChildren()[" .. tostring(childIndex) .. "]"
            )
        else
            table.insert(
                parts,
                1,
                loc.FormatPathName(current.Name)
            )
        end

        current = parent
    end

    if current == s.CoreGui then
        return 'game:GetService("CoreGui")' .. table.concat(parts)
    end

    local ok, fullName = pcall(function()
        return obj:GetFullName()
    end)

    if ok and type(fullName) == "string" and fullName ~= "" then
        return fullName
    end

    return nil
end

L.LocalizationExcluded = {
    [
        'game:GetService("CoreGui").ExperienceSettings.Menu.Search.List.Scrips.Body.Details|Text'
    ] = true,
    [
        'game:GetService("CoreGui").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.NameOfScriptTitle|Text'
    ] = true,
    [
        'game:GetService("CoreGui").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.TypeScript|Text'
    ] = true,
    [
        'game:GetService("CoreGui").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.Likes|Text'
    ] = true,
    [
        'game:GetService("CoreGui").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.Dislikes|Text'
    ] = true,
    [
        'game:GetService("CoreGui").ExperienceSettings.Menu.Search.Page.InPage.ViewPage.Visits|Text'
    ] = true,
    [
        'game:GetService("CoreGui").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody.SortContainer.SortBy|Text'
    ] = true,
    [
        'game:GetService("CoreGui").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody.SortContainer.SortOrder|Text'
    ] = true,
    [
        'game:GetService("CoreGui").ExperienceSettings.Menu.Search.List.SearchInput.Filter.FilterBody.TypeOfAnAPI|Text'
    ] = true,
}

loc.IsLocalizationExcluded = function(obj, property)
    if not obj or not property then
        return false
    end

    local path = loc.GetObjectPath(obj)
    if not path then
        return false
    end

    return L.LocalizationExcluded[
        path .. "|" .. tostring(property)
    ] == true
end

loc.GetPathSource = function(obj, property)
    local path = loc.GetObjectPath(obj)
    if not path then
        return nil, nil
    end

    return path,
        L.PathSources[path .. "|" .. tostring(property)]
end

loc.RestoreDynamicValuesFromSource = function(
    translatedText,
    canonicalSource,
    currentTemplate,
    currentValues
)
    if type(translatedText) ~= "string"
        or type(canonicalSource) ~= "string" then
        return translatedText
    end

    local canonicalTemplate, canonicalValues =
        SelectTextToTranslateOnly(canonicalSource)

    if canonicalTemplate ~= currentTemplate then
        return translatedText
    end

    local result = translatedText

    for index = #canonicalValues, 1, -1 do
        local oldValue = tostring(canonicalValues[index] or "")
        local newValue = tostring(currentValues[index] or oldValue)

        if oldValue ~= ""
            and newValue ~= oldValue then
            local escaped =
                oldValue:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")

            result = result:gsub(
                escaped,
                function()
                    return newValue
                end,
                1
            )
        end
    end

    return result
end

loc.GetState = function(obj, property)
    L.State[obj] =
        L.State[obj] or {}

    L.State[obj][property] =
        L.State[obj][property] or {}

    return L.State[obj][property]
end

loc.BuildSourceState = function(obj, property, sourceText)
    local state = loc.GetState(obj, property)
    local path, pathSource = loc.GetPathSource(obj, property)

    L.Canonical[obj] = L.Canonical[obj] or {}
    L.CanonicalTemplate[obj] = L.CanonicalTemplate[obj] or {}

    -- Canonical source priority:
    --   1) source captured on the very first bind
    --   2) authoritative PathSource from Device/PathSources
    --   3) previously cached canonical map
    --   4) current GUI value only for genuinely new/unmapped objects
    --
    -- Never use a translated GUI value to replace the canonical source.
    local canonical =
        state.SourceText
        or L.Canonical[obj][property]
        or pathSource
        or sourceText

    local template, protected =
        SelectTextToTranslateOnly(canonical)

    local canonicalTemplate =
        state.SourceTemplate
        or L.CanonicalTemplate[obj][property]
        or template

    state.Path = state.Path or path
    state.PathSource = state.PathSource or pathSource
    state.SourceTemplate = canonicalTemplate
    state.DynamicValues = state.DynamicValues or protected
    state.SourceText = canonical

    -- Freeze the canonical source for all future language switches.
    L.Canonical[obj][property] = state.SourceText
    L.CanonicalTemplate[obj][property] = state.SourceTemplate

    return state
end


loc.Directly = function(sourceText, language, pathSource)
    if language == "EN" then
        return tostring(sourceText or "")
    end

    local sourceRendered = tostring(sourceText or "")
    if sourceRendered == "" then
        return nil
    end

    local cache = L.Cache[language]
    if not cache then
        return nil
    end

    -- 1. Path-based canonical source. This is the strongest local identity.
    if pathSource and pathSource ~= "" then
        local translated = cache[pathSource]
        if translated then
            return translated, pathSource
        end

        local template, protected =
            SelectTextToTranslateOnly(pathSource)

        local currentTemplate, currentProtected =
            SelectTextToTranslateOnly(sourceRendered)

        if template == currentTemplate then
            translated = cache[template]
                or cache[loc.PlainCacheKey(template)]

            if translated then
                return loc.RestoreSelectedText(
                    translated,
                    currentProtected
                ), pathSource
            end
        end
    end

    -- 2. Exact/local cache and static DB.
    local translated = loc.GetCachedTranslation(
        sourceRendered,
        language
    )

    if translated then
        return translated, sourceRendered
    end

    -- 3. Similarity fallback. IMPORTANT: the similarity search is
    -- language-aware, so it never locks onto a canonical source that has no
    -- translation for the currently selected language.
    local similarSource =
        loc.FindSimilarLocalizationSource(sourceRendered, language)

    if similarSource and similarSource ~= sourceRendered then
        translated = cache[similarSource]
            or cache[loc.PlainCacheKey(similarSource)]

        if not translated then
            local similarTemplate =
                SelectTextToTranslateOnly(similarSource)

            translated = cache[similarTemplate]
                or cache[loc.PlainCacheKey(similarTemplate)]
        end

        if translated then
            local currentTemplate, currentProtected =
                SelectTextToTranslateOnly(sourceRendered)

            local similarTemplate =
                SelectTextToTranslateOnly(similarSource)

            if currentTemplate == similarTemplate then
                return loc.RestoreSelectedText(
                    translated,
                    currentProtected
                ), similarSource
            end

            return translated, similarSource
        end
    end

    return nil
end

-- Dynamic classification policy.
--
-- 1) LIVE/ValueChanger dynamic:
--    Any text object under a ValueChanger branch can change at any time.
--    It MUST NOT use Directly() and MUST NOT use LocalizationService.
--
-- 2) CLICK/interaction dynamic:
--    Any text object under TextChangeOnlyWhenClick is state-based UI text.
--    It MAY change when clicked, so it uses LocalizationService ONLY.
--
-- 3) Static:
--    Everything else follows the normal Directly() path.

loc.HasAncestorNamed = function(obj, targetName)
    if not obj then
        return false
    end

    targetName = tostring(targetName or ""):lower()
    if targetName == "" then
        return false
    end

    local current = obj.Parent
    while current do
        if tostring(current.Name or ""):lower() == targetName then
            return true
        end

        if current == ExperienceSettings then
            break
        end

        current = current.Parent
    end

    return false
end

loc.FindControllerRelation = function(obj, controllerName)
    if not obj then
        return nil
    end

    controllerName = tostring(controllerName or ""):lower()
    if controllerName == "" then
        return nil
    end

    -- 1) Most reliable relation: the controller is an ancestor.
    local current = obj.Parent
    while current do
        if tostring(current.Name or ""):lower() == controllerName then
            return current
        end

        if current == ExperienceSettings then
            break
        end

        current = current.Parent
    end

    -- 2) Some UI layouts keep the controller as a sibling of the value.
    --    Only accept this when there is exactly ONE direct sibling/controller
    --    with that name, preventing an entire panel from becoming dynamic.
    local parent = obj.Parent
    if parent then
        local found = nil
        local count = 0

        for _, child in ipairs(parent:GetChildren()) do
            if tostring(child.Name or ""):lower() == controllerName then
                found = child
                count += 1
            end
        end

        if count == 1 then
            return found
        end
    end

    return nil
end

-- Absolute Translate List exclusions for known ValueChanger-driven fields.
-- These entries are intentionally removed from the translation queue entirely.
-- They must never reach Directly() or LocalizationService.
local ValueChangerTranslateListSkip = {
    PlayerID = true,
    FriendCount = true,
    PlayerAge = true,
    PlayerBirth = true,
    PlaceID = true,
    CreatorName = true,
    CreatorID = true,
    AFK = true,
    PlayingTime = true,
    RealTimeClock = true,
    WalkSpeed = true,
    JumpPower = true,
    Damage = true,
    Heal = true,
    Deaths = true,
    Inventory = true,
    HoldingTool = true,
    MaxHealth = true,
    StandingOn = true,
    PositionOfCharacter = true,
    CharacterType = true,
    TimeOfDay = true,
}

-- Other dynamic/special fields found in Device.json.
-- These are intentionally removed from the translation queue entirely.
-- They must never reach Directly() or LocalizationService.
local DynamicTranslateListSkip = {
    PlayerCount = true,
    PlayerButton = true,
    SwitchButton = true,
    Status = true,
    ver = true,
    CreationDate = true,
    Creator = true,
}

loc.IsValueChangerTranslateListSkip = function(obj)
    if not obj then
        return false
    end

    local path = obj:GetFullName()

    -- ProfileStatus runtime values.
    if string.find(path, "ExperienceSettings.ProfileStatus", 1, true)
        or string.find(path, "ExperienceSettings.Menu.ProfileStatus", 1, true) then
        if ValueChangerTranslateListSkip[obj.Name] == true then
            return true
        end
    end

    -- Background.Settings.Pmax.PlayerCount
    if string.find(path, "ExperienceSettings.Menu.Background.Settings.Pmax", 1, true)
        and obj.Name == "PlayerCount" then
        return true
    end

    -- AIOpenSource runtime/special fields.
    if string.find(path, "ExperienceSettings.Menu.AIOpenSource", 1, true)
        and DynamicTranslateListSkip[obj.Name] == true then
        return true
    end

    -- Search API-generated metadata.
    if string.find(path, "ExperienceSettings.Menu.Search.Page.InPage.ViewPage", 1, true)
        and DynamicTranslateListSkip[obj.Name] == true then
        return true
    end

    return false
end

loc.IsValueChangerDynamic = function(obj, property)
    if not obj or not property then
        return false
    end

    -- Editable/user-entered TextBox.Text is always live dynamic.
    if property == "Text"
        and obj:IsA("TextBox")
        and obj.TextEditable then
        return true
    end

    -- FIRST: remove known ValueChanger-driven runtime fields from the
    -- Translate List before any translation state/cache/listener is created.
    if loc.IsValueChangerTranslateListSkip(obj) then
        return true
    end

    -- SECOND: detect an actual runtime ValueChanger controller relation.
    return loc.FindControllerRelation(obj, "ValueChanger") ~= nil
end

loc.IsTextChangeOnlyWhenClick = function(obj, property)
    if not obj or not property then
        return false
    end

    if loc.HasAncestorNamed(obj, "TextChangeOnlyWhenClick") then
        return true
    end

    -- Keep the known click-state buttons as a safe fallback even if their
    -- parent container is not named TextChangeOnlyWhenClick.
    if property == "Text" then
        local name = tostring(obj.Name or ""):lower()
        if name == "execute"
            or name == "copy"
            or name == "copy to clipboard" then
            return true
        end
    end

    return false
end

loc.GetDynamicTranslationMode = function(obj, property)
    if loc.IsValueChangerDynamic(obj, property) then
        return "LIVE"
    end

    if loc.IsTextChangeOnlyWhenClick(obj, property) then
        return "CLICK"
    end

    return "STATIC"
end

loc.IsDynamicTranslationTarget = function(obj, state, property)
    return loc.IsValueChangerDynamic(obj, property)
end

loc.IsLocalizationDirectOnlyProperty = function(obj, property, state)
    if not obj or not property or not state then
        return false
    end

    -- New policy: all static text uses the Directly/cache engine.
    -- TextButton is Directly unless it is one of the three dynamic buttons.
    if obj:IsA("TextLabel") then
        return true
    end

    if obj:IsA("TextBox") then
        if property == "Text" then
            return not obj.TextEditable
        end

        if property == "PlaceholderText" then
            return true
        end
    end

    if obj:IsA("TextButton") then
        return not loc.IsDynamicTranslationTarget(obj, state, property)
            and not loc.IsTextChangeOnlyWhenClick(obj, property)
    end

    if loc.IsTextChangeOnlyWhenClick(obj, property) then
        return false
    end

    return false
end

loc.GetStateTranslation = function(obj, state, property, language)
    if not obj or not property or not state then
        return nil
    end

    if loc.IsLocalizationExcluded(obj, property) then
        return nil
    end

    -- Live/ValueChanger dynamic text is never translated.
    if loc.IsDynamicTranslationTarget(obj, state, property) then
        return nil
    end

    if not state
        or not state.SourceTemplate
        or state.SourceTemplate == "" then
        return nil
    end

    local okRestore, sourceRendered = pcall(
        loc.RestoreSelectedText,
        state.SourceTemplate,
        state.DynamicValues or {}
    )

    if not okRestore or type(sourceRendered) ~= "string" then
        warn(
            "[Translation][SOURCE RENDER ERROR]",
            state.Path or obj:GetFullName(),
            tostring(sourceRendered)
        )
        return nil
    end

    if language == "EN" then
        return sourceRendered
    end

    -- Click/state dynamic text MUST use Roblox LocalizationService only.
    -- Directly() is intentionally forbidden for this class.
    if loc.IsTextChangeOnlyWhenClick(obj, property) then
        local okLocalize, localized, localizedSource = pcall(
            loc.Localizate,
            obj,
            sourceRendered,
            language,
            nil
        )

        if not okLocalize then
            warn(
                "[Translation][CLICK LOCALIZATION ERROR]",
                state.Path or obj:GetFullName(),
                property,
                tostring(localized)
            )
            return nil
        end

        if type(localized) == "string"
            and localized ~= ""
            and localized ~= sourceRendered then
            return localized
        end

        return nil
    end

    -- Static UI is Directly-only now. This includes TextLabel,
    -- non-editable TextBox.Text, TextBox.PlaceholderText, and static TextButton.
    if loc.IsLocalizationDirectOnlyProperty(obj, property, state) then
        local okDirect, direct, directSource = pcall(
            loc.Directly,
            sourceRendered,
            language,
            state.PathSource
        )

        if not okDirect then
            warn(
                "[Translation][DIRECT ERROR]",
                state.Path or obj:GetFullName(),
                property,
                tostring(direct)
            )
            return nil
        end

        if type(direct) == "string" and direct ~= "" then
            if directSource
                and state.PathSource
                and directSource == state.PathSource then
                direct = loc.RestoreDynamicValuesFromSource(
                    direct,
                    state.PathSource,
                    state.SourceTemplate,
                    state.DynamicValues or {}
                )
            end

            return direct
        end

        return nil
    end

    return nil
end

loc.NeedsTranslation = function(obj, property, state, language)
    if not obj
        or not property
        or not state
        or loc.IsLocalizationExcluded(obj, property) then
        return false
    end

    if not obj.Parent
        or loc.IsTranslationSkipped(obj) then
        return false
    end

    if loc.IsDynamicTranslationTarget(obj, state, property) then
        return false
    end

    if property == "Text"
        and obj:IsA("TextBox")
        and obj.TextEditable then
        return false
    end

    local currentValue =
        tostring(obj[property] or "")

    local sourceRendered =
        loc.RestoreSelectedText(
            state.SourceTemplate or "",
            state.DynamicValues or {}
        )

    if language == "EN" then
        return currentValue ~= sourceRendered
    end

    local applied =
        L.Applied[obj]
        and L.Applied[obj][property]

    local meta =
        L.AppliedMeta[obj]
        and L.AppliedMeta[obj][property]

    -- Fast path: this exact source is already rendered for this language.
    if meta
        and meta.Language == language
        and meta.Source == state.SourceText
        and meta.Text == currentValue then
        return false
    end

    if applied == currentValue
        and meta
        and meta.Language == language then
        return false
    end

    -- A cached translation may already be present even when this object was
    -- created after the previous scan. Do not call LocalizationService again.
    local cached =
        loc.GetCachedTranslation(sourceRendered, language)

    if cached then
        return currentValue ~= cached
    end

    if state.PathSource and state.PathSource ~= "" then
        local pathCache =
            L.Cache[language]
            and L.Cache[language][state.PathSource]

        if pathCache then
            local restored =
                loc.RestoreDynamicValuesFromSource(
                    pathCache,
                    state.PathSource,
                    state.SourceTemplate,
                    state.DynamicValues or {}
                )

            return currentValue ~= restored
        end
    end

    return true
end

loc.ApplyStateToObject = function(obj, property, language)
    if loc.IsLocalizationExcluded(obj, property) then
        return false
    end

    if not obj
        or not obj.Parent
        or loc.IsTranslationSkipped(obj) then
        return false
    end

    local state =
        L.State[obj]
        and L.State[obj][property]

    if not state then
        return false
    end

    if loc.IsDynamicTranslationTarget(obj, state, property) then
        return false
    end

    local rendered =
        loc.GetStateTranslation(
            obj,
            state,
            property,
            language
        )

    if rendered == nil then
        return false
    end

    if property == "Text"
        and obj:IsA("TextBox")
        and obj.TextEditable then
        return false
    end

    local ok = pcall(function()
        L.Applied[obj] =
            L.Applied[obj] or {}

        L.Applied[obj][property] =
            rendered

        L.AppliedMeta[obj] =
            L.AppliedMeta[obj] or {}

        L.AppliedMeta[obj][property] = {
            Language = language,
            Source = state.SourceText,
            Text = rendered,
        }

        obj[property] = rendered
    end)

    return ok
end

loc.UpdateDynamicState = function(obj, property, currentValue)
    local state =
        L.State[obj]
        and L.State[obj][property]

    if not state then
        return false
    end

    -- 1. The GUI changed only its dynamic part while
    --    already translated. Match against the translated template.
    if L.CurrentLanguage ~= "EN" then
        local translatedTemplate =
            L.Cache[L.CurrentLanguage]
            and L.Cache[L.CurrentLanguage][state.SourceTemplate]

        if translatedTemplate then
            local translatedDynamic =
                loc.MatchDynamicTemplate(
                    translatedTemplate,
                    currentValue
                )

            if translatedDynamic then
                state.DynamicValues =
                    translatedDynamic

                return true
            end
        end
    end

    -- 2. The GUI may have restored/changed the English text.
    local sourceDynamic =
        loc.MatchDynamicTemplate(
            state.SourceTemplate,
            currentValue
        )

    if sourceDynamic then
        state.DynamicValues =
            sourceDynamic

        state.SourceText =
            loc.RestoreSelectedText(
                state.SourceTemplate,
                sourceDynamic
            )

        return true
    end

    return false
end

loc.BindProperty = function(obj, property)
    if not obj
        or not obj.Parent
        or loc.IsTranslationSkipped(obj) then
        return
    end

    L.Source[obj] =
        L.Source[obj] or {}

    L.Applied[obj] =
        L.Applied[obj] or {}

    L.Connections[obj] =
        L.Connections[obj] or {}

    if L.Connections[obj][property] then
        return
    end

    if property == "Text"
        and obj:IsA("TextBox")
        and obj.TextEditable then
        return
    end

    -- HARD RULE: ValueChanger-controlled text is NEVER translated.
    -- Do not create translation state, cache, Localization listeners, or
    -- Directly work for it. This prevents ValueChanger feedback loops.
    if loc.IsValueChangerDynamic(obj, property) then
        return
    end

    local currentValue =
        tostring(obj[property] or "")

    local state =
        loc.BuildSourceState(
            obj,
            property,
            currentValue
        )

    L.Source[obj][property] =
        state.SourceText

    L.Applied[obj][property] =
        currentValue

    -- Live/ValueChanger text is intentionally one-shot and unobserved.
    -- It can change at any time, so it must never trigger translation work.
    -- Click-state text is different: it changes because the user interacts
    -- with it, and it is explicitly allowed to use LocalizationService.
    if loc.IsTextChangeOnlyWhenClick(obj, property) then
        local signal = obj:GetPropertyChangedSignal(property)

        L.Connections[obj][property] = signal:Connect(function()
            if not obj.Parent
                or loc.IsTranslationSkipped(obj)
                or loc.IsLocalizationExcluded(obj, property)
                or loc.IsValueChangerDynamic(obj, property) then
                return
            end

            L.LocalizationWrite = L.LocalizationWrite
                or setmetatable({}, {__mode = "k"})
            L.LocalizationWrite[obj] =
                L.LocalizationWrite[obj] or {}

            if L.LocalizationWrite[obj][property] then
                return
            end

            local currentValue =
                tostring(obj[property] or "")

            if currentValue == "" then
                return
            end

            local state =
                L.State[obj]
                and L.State[obj][property]

            if not state then
                return
            end

            -- A user click can replace the current English state. When that
            -- happens, rebuild the canonical source from the new state.
            state.SourceText = currentValue
            state.SourceTemplate, state.DynamicValues =
                SelectTextToTranslateOnly(currentValue)

            if L.CurrentLanguage == "EN" then
                return
            end

            task.spawn(function()
                local okLocalize, localized = pcall(
                    loc.Localizate,
                    obj,
                    currentValue,
                    L.CurrentLanguage,
                    nil
                )

                if okLocalize
                    and type(localized) == "string"
                    and localized ~= ""
                    and localized ~= currentValue
                    and obj.Parent then

                    L.LocalizationWrite[obj][property] = true

                    local okApply = pcall(function()
                        obj[property] = localized
                    end)

                    if okApply then
                        L.Applied[obj] =
                            L.Applied[obj] or {}
                        L.Applied[obj][property] = localized

                        L.AppliedMeta[obj] =
                            L.AppliedMeta[obj] or {}
                        L.AppliedMeta[obj][property] = {
                            Language = L.CurrentLanguage,
                            Source = state.SourceText,
                            Text = localized,
                        }

                    end

                    -- Always release the recursion guard, even if the property
                    -- write itself fails.
                    L.LocalizationWrite[obj][property] = false
                end
            end)
        end)
    end

end

loc.BindTextBoxEditable = function(obj)
    if not obj:IsA("TextBox")
        or not obj.Parent then
        return
    end

    L.Connections[obj] =
        L.Connections[obj] or {}

    if L.Connections[obj]._TextEditable then
        return
    end

    L.Connections[obj]._TextEditable =
        obj:GetPropertyChangedSignal("TextEditable"):Connect(function()
            if obj.TextEditable then
                if L.Source[obj] then
                    L.Source[obj].Text = nil
                end

                if L.Applied[obj] then
                    L.Applied[obj].Text = nil
                end

                if L.AppliedMeta[obj] then
                    L.AppliedMeta[obj].Text = nil
                end

                if L.State[obj] then
                    L.State[obj].Text = nil
                end

                return
            end

            loc.BindProperty(obj, "Text")
        end)
end

loc.ScanInstance = function(obj)
    -- Process only this instance. DescendantAdded calls this once per new object.
    if not obj or not obj.Parent or loc.IsTranslationSkipped(obj) then
        return
    end

    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        loc.BindProperty(obj, "Text")
    elseif obj:IsA("TextBox") then
        loc.BindProperty(obj, "PlaceholderText")
        loc.BindTextBoxEditable(obj)
        if not obj.TextEditable then
            loc.BindProperty(obj, "Text")
        end
    end
end

loc.ScanTree = function(root)
    if not root then
        return
    end

    loc.ScanInstance(root)
    for index, child in ipairs(root:GetDescendants()) do
        loc.ScanInstance(child)
        if index % 40 == 0 then
            task.wait()
        end
    end
end

loc.EnsureCanonicalState = function()
    for obj, properties in pairs(L.State) do
        if obj and obj.Parent and properties then
            for property, state in pairs(properties) do
                if state then
                    L.Canonical[obj] = L.Canonical[obj] or {}
                    L.CanonicalTemplate[obj] = L.CanonicalTemplate[obj] or {}

                    local canonical =
                        L.Canonical[obj][property]
                        or state.SourceText
                        or state.PathSource

                    if canonical and canonical ~= "" then
                        state.SourceText = canonical
                        L.Canonical[obj][property] = canonical
                    end

                    local template =
                        L.CanonicalTemplate[obj][property]
                        or state.SourceTemplate

                    if (not template or template == "") and canonical then
                        local builtTemplate =
                            SelectTextToTranslateOnly(canonical)
                        template = builtTemplate
                    end

                    if template and template ~= "" then
                        state.SourceTemplate = template
                        L.CanonicalTemplate[obj][property] = template
                    end
                end
            end
        end
    end
end

loc.ApplyCachedLanguage = function(language, onComplete)
    L.CurrentLanguage = language
    L.MissingTranslations[language] = {}
    L.MissingTranslationCountByLanguage[language] = nil

    -- Every language change starts from a clean applied-state.
    L.AppliedMeta = setmetatable({}, {__mode = "k"})

    L.TranslationGeneration += 1
    local generation = L.TranslationGeneration
    L.TranslationRunning = true

    -- Repeated-pass translation:
    --   1. Scan current GUI.
    --   2. Translate everything currently missing.
    --   3. Scan again.
    --   4. Continue until there is nothing left to translate,
    --      or a full pass makes zero progress.
    --
    -- This is intentionally NOT a timer/translation loop. Each pass is
    -- started only after the previous pass has completely finished.
    local pass = 0
    local totalApplied = 0

    local function finish()
        if generation ~= L.TranslationGeneration then
            return
        end

        L.TranslationRunning = false

        if onComplete then
            onComplete()
        end
    end

    -- Single worker architecture:
    -- NEVER spawn processBatch from inside itself. A yielding worker is used
    -- instead, which prevents C-stack growth while still checking one item
    -- at a time and allowing the UI scheduler to breathe between items.
    local function worker()
        local pass = 0
        local totalApplied = 0
        local totalChecked = 0

        while generation == L.TranslationGeneration do
            pass += 1

            -- Re-scan before every pass. BuildSourceState is source-safe below,
            -- so already-translated text cannot replace the canonical source.
            if pass == 1 then
                loc.ScanTree(ExperienceSettings)
            end
            loc.EnsureCanonicalState()

            local queue = {}
            local skipped = 0

            for obj, properties in pairs(L.State) do
                if obj
                    and obj.Parent
                    and not loc.IsTranslationSkipped(obj) then

                    for property, state in pairs(properties) do
                        -- ValueChanger is an absolute exclusion. If a controller
                        -- appeared after the initial scan, remove this state so
                        -- no translation path can touch it.
                        if loc.IsValueChangerDynamic(obj, property) then
                            -- Absolute Translate List removal: do not queue it.
                            properties[property] = nil
                        elseif not loc.IsLocalizationExcluded(obj, property)
                            and not loc.IsDynamicTranslationTarget(obj, state, property)
                            and not (
                                property == "Text"
                                and obj:IsA("TextBox")
                                and obj.TextEditable
                            ) then

                            totalChecked += 1

                            local needs = false
                            local okNeeds, resultNeeds = pcall(
                                loc.NeedsTranslation,
                                obj,
                                property,
                                state,
                                language
                            )

                            if okNeeds then
                                needs = resultNeeds == true
                            else
                                skipped += 1
                                warn(
                                    "[Translation][CHECK ERROR]",
                                    obj:GetFullName(),
                                    property,
                                    tostring(resultNeeds)
                                )
                            end

                            if needs then
                                queue[#queue + 1] = {
                                    obj = obj,
                                    property = property,
                                    state = state,
                                }
                            end
                        end
                    end
                end
            end

            if #queue == 0 then
                break
            end

            local appliedThisPass = 0

            -- Process EXACTLY ONE text at a time.
            for index = 1, #queue do
                if generation ~= L.TranslationGeneration then
                    return
                end

                local item = queue[index]
                local obj = item.obj
                local property = item.property
                local state = item.state

                local shouldApply = false
                local okNeeds, resultNeeds = pcall(
                    loc.NeedsTranslation,
                    obj,
                    property,
                    state,
                    language
                )

                if okNeeds then
                    shouldApply = resultNeeds == true
                else
                    warn(
                        "[Translation][RECHECK ERROR]",
                        obj and obj:GetFullName() or "<nil>",
                        property,
                        tostring(resultNeeds)
                    )
                end

                if shouldApply
                    and obj
                    and obj.Parent
                    and not loc.IsTranslationSkipped(obj)
                    and not loc.IsLocalizationExcluded(obj, property)
                    and not loc.IsValueChangerDynamic(obj, property)
                    and not loc.IsDynamicTranslationTarget(obj, state, property) then

                    local before = tostring(obj[property] or "")


                    local okRender, rendered = pcall(
                        loc.GetStateTranslation,
                        obj,
                        state,
                        property,
                        language
                    )

                    if not okRender then
                        warn(
                            "[Translation][TRANSLATE ERROR]",
                            state.Path or obj:GetFullName(),
                            property,
                            tostring(rendered)
                        )
                    elseif type(rendered) == "string" and rendered ~= "" and rendered ~= before then
                        local appliedOK, appliedErr = pcall(function()
                            L.Applied[obj] = L.Applied[obj] or {}
                            L.Applied[obj][property] = rendered

                            L.AppliedMeta[obj] = L.AppliedMeta[obj] or {}
                            L.AppliedMeta[obj][property] = {
                                Language = language,
                                Source = state.SourceText,
                                Text = rendered,
                            }

                            obj[property] = rendered

                            L.Source[obj] = L.Source[obj] or {}
                            L.Source[obj][property] = state.SourceText
                        end)

                        if appliedOK then
                            appliedThisPass += 1
                            totalApplied += 1

                        else
                            warn(
                                "[Translation][APPLY ERROR]",
                                state.Path or obj:GetFullName(),
                                property,
                                tostring(appliedErr)
                            )
                        end
                    elseif rendered == nil or rendered == "" then
                        L.MissingTranslations[language] =
                            L.MissingTranslations[language] or {}

                        L.MissingTranslations[language][
                            state.SourceTemplate
                            or state.SourceText
                            or (tostring(state.Path or obj:GetFullName()) .. "|" .. property)
                        ] = {
                            Path = state.Path or obj:GetFullName(),
                            Property = property,
                        }
                    else
                    end
                end

                -- Yield AFTER every single item. This is the key C-stack fix.
                task.wait()
            end

            -- No progress means the remaining entries have no available local
            -- translation. Stop instead of spinning forever.
            if appliedThisPass == 0 then
                warn(
                    string.format(
                        "[Translation][STOP] pass=%d made no progress; remaining=%d",
                        pass,
                        #queue
                    )
                )
                break
            end

            -- Yield before the next scan, but DO NOT call worker/runPass again.
            task.wait()
        end

        -- Count unique source templates that do not have a local translation.
        L.MissingTranslationCountByLanguage[language] = 0
        for _ in pairs(L.MissingTranslations[language] or {}) do
            L.MissingTranslationCountByLanguage[language] += 1
        end
        L.LastMissingTranslationCount =
            L.MissingTranslationCountByLanguage[language]

        -- IMPORTANT: release the selector after the worker really finishes.
        finish()
    end

    task.spawn(worker)
end

loc.SetPermanentTranslationSource = function(
    obj,
    property,
    sourceText
)
    local state =
        loc.BuildSourceState(
            obj,
            property,
            sourceText
        )

    L.Source[obj] =
        L.Source[obj] or {}

    L.Source[obj][property] =
        state.SourceText
end

local SetLanguageButtonsLocked

loc.ChangeLanguage = function(language)
    if not ExperienceSettings then
        return
    end

    if L.Busy then
        return
    end

    -- Same language = zero work, zero API calls.
    if L.latestClick == language then
        return
    end

    L.latestClick = language
    L.PendingLanguage = language
    L.SelectedLanguage = language
    L.Busy = true
    L.LanguageButtonStatus = "Working"
    L.WorkingSeconds = 0
    L.LanguageButtonTimerGeneration += 1
    local timerGeneration = L.LanguageButtonTimerGeneration

    -- Immediately show Working... (0)
    L.RefreshLanguageButtons()
    SetLanguageButtonsLocked(true)

    -- Keep the selector timer independent from the translation worker.
    local started = os.clock()

    task.spawn(function()

        while L.Busy
            and timerGeneration == L.LanguageButtonTimerGeneration do
            L.WorkingSeconds = math.floor(os.clock() - started)
            L.RefreshLanguageButtons()
            task.wait(0.25)
        end
    end)

    task.spawn(function()
        loc.EnsureCanonicalState()

        local function complete()
            if timerGeneration ~= L.LanguageButtonTimerGeneration then
                return
            end

            -- Freeze the actual elapsed time for the final status.
            L.WorkingSeconds = math.max(0, math.floor(os.clock() - started))
            L.Busy = false
            L.SelectedLanguage = L.CurrentLanguage
            L.PendingLanguage = L.CurrentLanguage

            -- Show Done! (final WorkingSeconds), wait PauseSeconds, then Selected.
            L.LanguageButtonStatus = "Done"
            L.RefreshLanguageButtons()

            if L.PauseSeconds > 0 then
                task.wait(L.PauseSeconds)
            end

            if timerGeneration ~= L.LanguageButtonTimerGeneration then
                return
            end

            L.LanguageButtonStatus = "Selected"
            SetLanguageButtonsLocked(false)
            L.RefreshLanguageButtons()
        end

        if language == "EN" then
            loc.ApplyCachedLanguage("EN", function()
                loc.SaveTranslationCache("EN")
                complete()
            end)
            return
        end

        loc.ApplyCachedLanguage(language, function()
            loc.SaveTranslationCache(language)
            complete()
        end)
    end)
end

SetLanguageButtonsLocked = function(locked)
    if L.LanguageSelect then
        for _, control in ipairs({L.LanguageSelect.SelectButton, L.LanguageSelect.Button}) do
            if control then
                control.Active = not locked
                control.AutoButtonColor = not locked
            end
        end
        if locked and L.LanguageSelect.Select then
            L.LanguageSelect.Select.Visible = false
        end
    end

    for _, button in pairs(L.LanguageButtons) do
        if button and button.Parent then
            button.Active = not locked
            button.AutoButtonColor = not locked
        end
    end
end

-- Never translate the language selector itself.
if typeof(ins2) == "Instance" then
    ins2:SetAttribute("SkipAutoTranslate", true)
end

-- ExperienceSettings may be created/moved into CoreGui later.
-- Wait for it in a separate thread so the rest of Loader.lua keeps running.
task.spawn(function()
    ExperienceSettings = s.CoreGui:WaitForChild("ExperienceSettings")

    -- Initial scan; yield periodically to avoid freezing large UI trees.
    loc.ScanTree(ExperienceSettings)

    -- New GUI objects are picked up automatically.
    ExperienceSettings.DescendantAdded:Connect(function(obj)
        task.defer(function()
            if not obj
                or not obj.Parent
                or loc.IsTranslationSkipped(obj) then
                return
            end

            loc.ScanInstance(obj)

            if L.CurrentLanguage ~= "EN" and not L.Busy then
                loc.ApplyStateToObject(obj, "Text", L.CurrentLanguage)
                loc.ApplyStateToObject(obj, "PlaceholderText", L.CurrentLanguage)
            end
        end)
    end)
end)

-- One-shot translation only. Dynamic text is not re-translated on a timer.
-- New GUI objects are handled by DescendantAdded.

L.LanguageHeader = loc.o(
    "« Languages (Not 100%) »",
    255,255,255,
    false,nil,false,nil,nil,nil,nil,ins2
).Label

L.PendingLanguage = L.CurrentLanguage
L.LanguageSelect = loc.o(
    typeof(ins2) == "Instance" and ins2 or scr,
    nil,
    "Switch Language",
    false,
    true,
    "Switch",
    true,
    false,
    nil,
    nil,
    function(value, action, ui)
        if action == "select" then
            L.PendingLanguage = L.LanguageValueToCode[value]
            L.LanguageButtonStatus = nil
            if L.RefreshLanguageButtons then
                L.RefreshLanguageButtons()
            elseif ui and ui.Button then
                ui.Button.Text = "Switch"
            end
        elseif action == "button" then
            local language = L.PendingLanguage
            if language then
                loc.ChangeLanguage(language)
            end
        end
    end,
    L.LanguageOptionLabels[L.CurrentLanguage]
)

-- Build the language dropdown; the adjacent nbtn applies the selected language.
for _, language in ipairs(L.LanguageOrder) do
    L.LanguageValueToCode[L.LanguageOptionLabels[language]] = language
    L.LanguageButtonDefaultText[language] = L.LanguageOptionLabels[language]
    L.LanguageButtons[language] = L.LanguageSelect.AddSelect(
        L.LanguageOptionLabels[language]
    )
end

L.RefreshLanguageButtons = function()
    local selected = L.PendingLanguage or L.SelectedLanguage
    local status = L.LanguageButtonStatus
    local selector = L.LanguageSelect and L.LanguageSelect.SelectButton
    local actionButton = L.LanguageSelect and L.LanguageSelect.Button

    if selector then
        selector.Text = L.LanguageButtonDefaultText[selected]
            or L.LanguageOptionLabels[selected]
            or "Language"
    end

    if actionButton then
        if status == "Working" then
            actionButton.Text = string.format(
                "Working... (%ds)",
                tonumber(L.WorkingSeconds) or 0
            )
        elseif status == "Done" then
            actionButton.Text = string.format(
                "Done! (%ds)",
                tonumber(L.WorkingSeconds) or 0
            )
        elseif status == "Selected" then
            actionButton.Text = "Selected"
        else
            actionButton.Text = "Switch"
        end
    end

    for language, optionButton in pairs(L.LanguageButtons) do
        if optionButton and optionButton.Parent then
            local isSelected = selected == language
            optionButton.TextColor3 = isSelected
                and Color3.fromRGB(0,255,0)
                or Color3.fromRGB(255,255,255)
            optionButton.BackgroundTransparency = isSelected and 0.15 or 0.35
        end
    end

    if L.LanguageHeader then
        local missing = L.MissingTranslationCountByLanguage[L.SelectedLanguage]
        if missing ~= nil then
            L.LanguageHeader.Text = string.format(
                "« Languages · Missing: %d »",
                missing
            )
        else
            L.LanguageHeader.Text = "« Languages (Not 100%) »"
        end
    end
end

L.RefreshLanguageButtons()

loc.o("« Debug »", 255,255,255, false,nil,false,nil,nil,nil,nil,ins2)


-- Set ExperienceSetting's ScreenGui ScreenInsets

local screenInsetStates = {
    {
        Name = "DeviceSafeInsets",
        Enum = Enum.ScreenInsets.DeviceSafeInsets
    },
    {
        Name = "CoreUISafeInset",
        Enum = Enum.ScreenInsets.CoreUISafeInsets
    },
    {
        Name = "None",
        Enum = Enum.ScreenInsets.None
    }
}

local screenInsetCurrent = 1

for i, state in ipairs(screenInsetStates) do
    if state.Name == Data.UI.ScreenInsets then
        screenInsetCurrent = i
        break
    end
end

local screenInsetPending = screenInsetStates[screenInsetCurrent].Name
local screenInsetUI = loc.o(
    typeof(ins2) == "Instance" and ins2 or scr,
    nil,
    "Set ExperienceSetting's ScreenGui",
    false,
    true,
    "Apply",
    true,
    false,
    nil,
    nil,
    function(value, action, ui)
        if action == "select" then
            screenInsetPending = value
            return
        end

        if action == "button" then
            for index, state in ipairs(screenInsetStates) do
                if state.Name == screenInsetPending then
                    screenInsetCurrent = index
                    Data.UI.ScreenInsets = state.Name

                    if MENU_INSTANCE then
                        MENU_INSTANCE.ScreenInsets = state.Enum
                    end

                    loc.saveData(Data)
                    ui.Button.Text = "Saved"
                    ui.Button.TextColor3 = Color3.fromRGB(0, 255, 0)
                    task.delay(1, function()
                        if ui.Button and ui.Button.Parent then
                            ui.Button.Text = "Apply"
                            ui.Button.TextColor3 = Color3.new(1, 1, 1)
                        end
                    end)
                    break
                end
            end
        end
    end,
    screenInsetPending
)

for _, state in ipairs(screenInsetStates) do
    screenInsetUI.AddSelect(state.Name)
end

-- Apply saved state when Menu exists
task.spawn(function()
    while not MENU_INSTANCE do
        task.wait()
    end

    MENU_INSTANCE.ScreenInsets =
        screenInsetStates[screenInsetCurrent].Enum
end)

-- Screen.DisplayOrder

local DEFAULT_DISPLAY_ORDER = 2147483646

loc.parseDisplayOrder = function(value)
    if type(value) == "number" then
        return value
    end

    value = tostring(value):lower():gsub("%s+", "")

    if value == "default" then
        return DEFAULT_DISPLAY_ORDER
    elseif value == "math.huge" then
        return math.huge
    elseif value == "math.mininteger" then
        return math.mininteger
    elseif value == "math.maxinteger" then
        return math.maxinteger
    end

    return tonumber(value)
end

loc.displayOrderText = function(value)
    if value == DEFAULT_DISPLAY_ORDER then
        return "Default"
    elseif value == math.huge then
        return "math.huge"
    elseif value == math.mininteger then
        return "math.mininteger"
    elseif value == math.maxinteger then
        return "math.maxinteger"
    end

    return tostring(value)
end

loc.o(
    "Screen.DisplayOrder",
    255,255,255,

    true,
    loc.displayOrderText(Data.UI.DisplayOrder or DEFAULT_DISPLAY_ORDER),

    true,
    "Save",

    -- LIVE PREVIEW
    function(box)
        local value = loc.parseDisplayOrder(box.Text)

        if value ~= nil and MENU_INSTANCE then
            MENU_INSTANCE.DisplayOrder = value
        end
    end,

    -- SAVE
    function(box, btn)
        local value = loc.parseDisplayOrder(box.Text)

        if value == nil then
            box.Text = loc.displayOrderText(
                Data.UI.DisplayOrder or DEFAULT_DISPLAY_ORDER
            )
            return
        end

        Data.UI.DisplayOrder = value

        if MENU_INSTANCE then
            MENU_INSTANCE.DisplayOrder = value
        end

        loc.saveData(Data)

        btn.TextColor3 = Color3.fromRGB(0,255,0)

        task.delay(0.35, function()
            if btn and btn.Parent then
                btn.TextColor3 = Color3.fromRGB(255,255,255)
            end
        end)
    end,

    nil,
    ins2
)






















-- This only way the last toggle
-- StarterGui uses the shared s.StarterGui service reference.

loc.o(
    "Console shortcut",
    255,255,255,
    false,nil,
    true,"OPEN",
    nil,
    function()
        pcall(function()
            s.StarterGui:SetCore("DevConsoleVisible", true)
        end)
    end
)

local kill = loc.o(
    "Kill Gui - This Settings only",
    255,80,80,
    false, nil,
    true, "Destroy",
    nil,
    function(_, btn)
        if not btn.Active then return end
        if gui and gui.Parent then
            gui:Destroy()
        end
    end
)

local killBtn = kill.Button

task.spawn(function()
    while killBtn and killBtn.Parent do
        if not CONTINUE_LOCK then
            killBtn.Active = false
        end
        task.wait(0.2)
    end
end)

task.spawn(function()
    while killBtn and killBtn.Parent do
        local isAlwaysOn = alwaysBtn.Text == "ON"

        if not CONTINUE_LOCK then
            -- Continue ถูกกดแล้ว
            killBtn.Active = false
            killBtn.Text = "Cannot destroy"
            killBtn.TextColor3 = Color3.fromRGB(255,0,0)

        elseif isAlwaysOn then
            -- Always Load เปิด
            killBtn.Active = false
            killBtn.Text = "Cannot destroy"
            killBtn.TextColor3 = Color3.fromRGB(255,0,0)

        else
            -- ปกติ
            killBtn.Active = true
            killBtn.Text = "Destroy"
            killBtn.TextColor3 = Color3.fromRGB(255,255,255)
        end

        task.wait(0.2)
    end
end)

print[[------------------------------------------------------------
[ Settings - Loader Rejoiner ] Successful loaded.

>> for Information
  - Continue loadstring = Load ExperienceSettings
  - Always Load = Auto load ExperienceSettings
  - Set BackgroundColor3 (R,G,B) = ExperienceSettings BackgroundColor3 (Default theme only)
  - Custom Theme = Image + Multi-Stop Gradient (2–20 colors, rotation and transparency)
  - FoundHumanoidRootPart: State = If there HumanoidRootPart or not
  - Hide ExperienceSettings = Hide TopBar and another frames
  - Set BackgroundTransparency = ExperienceSettings Menu backgrounds
  - Set BackgroundTransparency (Settings Only) = Loader Rejoiner holder (hr)
  - Set UIScale = Set UIScale of ExperienceSettings
  - IsHealthOn: State = Always checking HealthBar is on or not
  - HealthBarToggle = ON/OFF HealthBar
  - Console shortcut = The short way to open developer console on mobile
  - Kill Gui = Destroy this Settings - Loader Rejoiner
------------------------------------------------------------
]]

-- WAIT
while CONTINUE_LOCK do
    task.wait()
end
