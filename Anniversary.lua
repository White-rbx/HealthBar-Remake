local v_ver = [[Anniversary 1.0 yay]]
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

local menu = s.CoreGui:WaitForChild("ExperienceSettings").Menu

local main = Instance.new("CanvasGroup")
main.Name = "PopUp"
main.Position = UDim2.new(0.35,0,1,0) -- Y Scale Open = 0.23
main.Size = UDim2.new(0.3,0,0.6,0)
main.BackgroundTransparency = 1
main.Parent = menu
Corner(0,8,main)
Stroke(main, ASMBorder, 255,255,255, LJMRound, 1, 0)

local img = Instance.new("ImageLabel")
img.Name = "Image"
img.Size = UDim2.new(1,0,0,125)
img.ScaleType = Enum.ScaleType.Fit
img.BackgroundColor3 = Color3.new(0,0,0)
img.BackgroundTransparency = 0.3
img.Image = "rbxassetid://135517402094731"
img.BorderSizePixel = 0
img.ZIndex = 0
img.Parent = main

local scr = Instance.new("ScrollingFrame")
scr.Name = "Scroll"
scr.Position = UDim2.new(0,0,0,125)
scr.Size = UDim2.new(1,0,1,-125)
scr.BackgroundColor3 = Color3.fromRGB(255,255,255)
scr.BackgroundTransparency = 0.3
scr.ScrollingDirection = Enum.ScrollingDirection.Y
scr.ScrollBarThickness = 5
scr.BorderSizePixel = 0
scr.ZIndex = 0
scr.Parent = main
Gradient(scr, -45,0,0,{Color3.fromRGB(0,255,0), Color3.fromRGB(255,255,0)})

local txt = Instance.new("TextLabel")
txt.Name = "Thank"
txt.Size = UDim2.new(1,-5,1,0)
txt.BackgroundTransparency = 1
txt.TextXAlignment = Enum.TextXAlignment.Left
txt.TextYAlignment = Enum.TextYAlignment.Top
txt.BorderMode = Enum.BorderMode.Inset 
txt.BorderSizePixel = 5
txt.TextColor3 = Color3.new(1,1,1)
txt.TextStrokeTransparency = 0
txt.RichText = true
txt.TextWrapped = true
txt.Text = '<b><font size="12">Happy 1st Anniversary of The ExperienceSettings!</font></b>\nWe want to let you know for those who using our script; we want to say <b>thank you for using our script!</b> \n \nTo close this <b>GUI</b> you can simply click <b><font size="9">"Remind me later."</font></b> or <b><font size="9">"Dont show this again."</font></b> button to continue use The ExperienceSettings.'

txt.Parent = scr

local fr = Instance.new("Frame")
fr.Name = "FrameOfButtons"
fr.Position = UDim2.new(0,0,1,-50)
fr.Size = UDim2.new(1,0,0,50)
fr.Active = false
fr.BackgroundColor3 = Color3.new(1,1,1)
fr.BackgroundTransparency = 1
fr.ZIndex = 0
fr.BorderMode = Enum.BorderMode.Inset
fr.BorderSizePixel = 5
fr.Parent = main

local rm = Instance.new("TextButton")
rm.Name = "RemindMeLater"
rm.Size = UDim2.new(0.5,-3,1,0)
rm.BackgroundColor3 = Color3.fromRGB(255,255,0)
rm.RichText = true
rm.BorderMode = Enum.BorderMode.Inset
rm.BorderSizePixel = 10
rm.TextScaled = true
rm.Text = "<b>Remind Me Later</b>"
rm.TextColor3 = Color3.new(0,0,0)
rm.Parent = fr
Corner(0,8,rm)

local cl = rm:Clone()
cl.Name = "Close"
cl.Position = UDim2.new(0.5,3,0,0)
cl.BackgroundColor3 = Color3.fromRGB(255,0,0)
cl.TextColor3 = Color3.new(1,1,1)
cl.Text = "<b>Don't show this again</b>"
cl.Parent = fr

-- ===== Anniversary System =====

local AnniversaryFolder = "ExperienceSettings"
local AnniversaryFile = AnniversaryFolder .. "/AnniversaryData.json"

-- ===== JSON Default Data =====

local DefaultData = {
    remindUntil = 0,
    dontShowAgain = false
}

local AnniversaryData = {}

-- ===== JSON Helpers =====

local function saveAnniversaryData()
    writefile(
        AnniversaryFile,
        s.HttpService:JSONEncode(AnniversaryData)
    )
end

local function loadAnniversaryData()
    if not isfile(AnniversaryFile) then
        AnniversaryData = {
            remindUntil = 0,
            dontShowAgain = false
        }

        saveAnniversaryData()
        return
    end

    local success, result = pcall(function()
        return s.HttpService:JSONDecode(
            readfile(AnniversaryFile)
        )
    end)

    if success and type(result) == "table" then
        AnniversaryData = result

        -- กัน JSON เก่าหรือข้อมูลหาย
        AnniversaryData.remindUntil =
            tonumber(AnniversaryData.remindUntil) or 0

        AnniversaryData.dontShowAgain =
            AnniversaryData.dontShowAgain == true
    else
        AnniversaryData = {
            remindUntil = 0,
            dontShowAgain = false
        }

        saveAnniversaryData()
    end
end

-- ===== Date Check =====

local CurrentDate = os.date("*t")

-- November 1 เป็นต้นไป = Anniversary หมดเขต
local AnniversaryExpired =
    CurrentDate.month >= 11

-- ===== Tween =====

local function OpenAnniversary()
    main.Visible = true

    main.Position =
        UDim2.new(0.35, 0, 1, 0)

    local tween = s.TweenService:Create(
        main,
        TweenInfo.new(
            0.45,
            Enum.EasingStyle.Back,
            Enum.EasingDirection.Out
        ),
        {
            Position =
                UDim2.new(0.35, 0, 0.23, 0)
        }
    )

    tween:Play()
end


local function CloseAnniversary()
    local tween = s.TweenService:Create(
        main,
        TweenInfo.new(
            0.35,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.In
        ),
        {
            Position =
                UDim2.new(0.35, 0, 1, 0)
        }
    )

    tween:Play()

    tween.Completed:Connect(function()
        main.Visible = false
    end)
end

-- ===== Load Data =====

loadAnniversaryData()

-- ===== Remind Me Later =====

rm.MouseButton1Click:Connect(function()

    AnniversaryData.remindUntil =
        os.time() + (5 * 24 * 60 * 60)

    saveAnniversaryData()

    CloseAnniversary()
end)

-- ===== Don't Show This Again =====

cl.MouseButton1Click:Connect(function()

    AnniversaryData.dontShowAgain = true

    saveAnniversaryData()

    CloseAnniversary()
end)

-- ===== Initial State =====

main.Visible = false

if not AnniversaryExpired
and not AnniversaryData.dontShowAgain
and os.time() >= AnniversaryData.remindUntil then

    OpenAnniversary()
end
