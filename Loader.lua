-- Loader script 0.31

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

------------------------------------------------------------------------------------------

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "LoaderSettings"
gui.Parent = CoreGui

-- Frame
local hr = Instance.new("Frame")
hr.Name = "Holder"
hr.Size = UDim2.new(0.3,0,1,0)
hr.Position = UDim2.new(-0.3,0,0,0)
hr.BackgroundTransparency = 0.3
hr.BorderSizePixel = 0
hr.BackgroundColor3 = Color3.fromRGB(18,18,21)
hr.Active = false
hr.Parent = gui

-- Button
local oc = Instance.new("TextButton")
oc.Name = "OPEN/CLOSE"
oc.Size = UDim2.new(0.1,0,0.1,0)
oc.Position = UDim2.new(1,0,0,0)
oc.BackgroundTransparency = 0.3
oc.BorderSizePixel = 0
oc.BackgroundColor3 = Color3.fromRGB(18,18,21)
oc.TextColor3 = Color3.fromRGB(255,255,255)
oc.TextSize = 18
oc.Text = "‹›"
oc.Parent = hr

-- Frame
local ins = Instance.new("Frame")
ins.Name = "Inside"
ins.Size = UDim2.new(0.92,0,0.96,0)
ins.Position = UDim2.new(0.04,0,0.02,0)
ins.BackgroundTransparency = 1
ins.Active = false
ins.Parent = hr
ListLayout(ins, 0, 5, HCenter, VTop, SLayout, FillV)

-- Holder
local top = Instance.new("TextLabel")
top.Name = "Topic"
top.Size = UDim2.new(1,0,0.05,0)
top.BackgroundTransparency = 1
top.TextScaled = true
top.Text = "Settings - Loader"
top.TextColor3 = Color3.fromRGB(255,255,255)
top.Parent = ins
Corner(0, 8, top)
Stroke(top, ASMBorder, 255,255,255, LJMRound, 1, 0)

-- Toggle for holder
-- ตัวแปรที่มีอยู่แล้ว
-- hr : Frame
-- oc : TextButton

local OFF_X = -0.3
local ON_X = 0

local tweenInfo = TweenInfo.new(
    0.25, -- เวลา
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)

local function tweenHR(xScale)
    local goal = {
        Position = UDim2.new(
            xScale,
            0,
            hr.Position.Y.Scale,
            hr.Position.Y.Offset
        )
    }

    TweenService:Create(hr, tweenInfo, goal):Play()
end

oc.MouseButton1Click:Connect(function()
    local currentX = hr.Position.X.Scale

    if currentX <= OFF_X then
        -- OFF → ON
        tweenHR(ON_X)
    else
        -- ON → OFF
        tweenHR(OFF_X)
    end
end)

--// =====================================================
--// SERVICES
--// =====================================================

local HttpService = game:GetService("HttpService")

--// =====================================================
--// SAVE PATH
--// =====================================================

local ROOT_FOLDER = "ExperienceSettings"
local SAVE_FILE   = ROOT_FOLDER .. "/config.json"

--// =====================================================
--// FILE UTILS (EXECUTOR)
--// =====================================================

local function ensureFolder()
    if not isfolder(ROOT_FOLDER) then
        makefolder(ROOT_FOLDER)
    end
end

local function saveData(data)
    ensureFolder()
    writefile(SAVE_FILE, HttpService:JSONEncode(data))
end

local function loadData()
    ensureFolder()
    if isfile(SAVE_FILE) then
        local ok, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(SAVE_FILE))
        end)
        if ok and type(decoded) == "table" then
            return decoded
        end
    end
    return {}
end

--// =====================================================
--// TXT FUNCTION (YOUR SYSTEM)
--// =====================================================

local function Txt(
    txt, R, G, B,
    hasBox, ptxt,
    hasButton, btxt,
    work, callback, status
)
    -- Frame
    local b = Instance.new("Frame")
    b.Name = "Handle"
    b.Size = UDim2.new(1, 0, 0.05, 0)
    b.BackgroundTransparency = 1
    b.Parent = ins

    -- TextLabel
    local a = Instance.new("TextLabel")
    a.BackgroundTransparency = 1
    a.Text = tostring(txt)
    a.TextScaled = true
    a.TextColor3 = Color3.fromRGB(R, G, B)
    a.TextXAlignment = Enum.TextXAlignment.Left
    a.Size = UDim2.new(1,0,1,0)
    a.Parent = b

    if hasBox and hasButton then
        a.Size = UDim2.new(0.25,0,1,0)
    elseif hasBox then
        a.Size = UDim2.new(0.4,0,1,0)
    elseif hasButton then
        a.Size = UDim2.new(0.65,0,1,0)
    end

    -- TextBox
    local box
    if hasBox then
        box = Instance.new("TextBox")
        box.BackgroundTransparency = 1
        box.PlaceholderText = tostring(ptxt or "")
        box.Text = ""
        box.TextScaled = true
        box.TextColor3 = Color3.fromRGB(0,255,0)
        box.Size = UDim2.new(0.49,0,1,0)
        box.Position = UDim2.new(0.41,0,0,0)
        box.Parent = b

        if hasButton then
            box.Size = UDim2.new(0.25,0,1,0)
            box.Position = UDim2.new(0.26,0,0,0)
        end

        if work then
            box.FocusLost:Connect(function(enter)
                if enter then
                    work(box.Text)
                    if callback then
                        callback(box.Text)
                    end
                end
            end)
        end
    end

    -- TextButton / Toggle
    local btn
    if hasButton then
        btn = Instance.new("TextButton")
        btn.BackgroundTransparency = 0.15
        btn.TextScaled = true
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Size = UDim2.new(0.44,0,1,0)
        btn.Position = UDim2.new(0.66,0,0,0)
        btn.Parent = b

        if hasBox then
            btn.Size = UDim2.new(0.25,0,1,0)
            btn.Position = UDim2.new(0.51,0,0,0)
        end

        if status ~= nil then
            btn.Text = status and "ON" or "OFF"
            btn.MouseButton1Click:Connect(function()
                status = not status
                btn.Text = status and "ON" or "OFF"
                if work then work(status) end
                if callback then callback(status) end
            end)
        else
            btn.Text = tostring(btxt or "OK")
            btn.MouseButton1Click:Connect(function()
                if work then work() end
                if callback then callback() end
            end)
        end
    end

    return {
        Frame = b,
        Label = a,
        Box = box,
        Button = btn
    }
end

--// =====================================================
--// USAGE EXAMPLES
--// =====================================================

-- Toggle: Show Physics
local CONTINUE_LOCK = true

Txt(
    "Continue loadstring (ANTI-BROKE)",
    255, 255, 255,
    false, nil,
    true, "Okay",
    function()
        CONTINUE_LOCK = false
    end
)
















-- WAIT FOR USER CONFIRM
while CONTINUE_LOCK do
    task.wait()
end
