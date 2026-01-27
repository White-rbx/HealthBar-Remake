-- Loader script 0.44

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

--// =====================================================
--// SAVE DATA
--// =====================================================

local DEFAULT_DATA = {
    Version = 1,
    Loader = {
        AlwaysLoad = false
    },
    UI = {
        BackgroundRGB = { 18, 18, 21 }
    }
}

local function deepMerge(defaults, data)
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            data[k] = type(data[k]) == "table" and data[k] or {}
            deepMerge(v, data[k])
        elseif data[k] == nil then
            data[k] = v
        end
    end
end

local function loadData()
    ensureFolder()

    local data = {}

    if isfile(SAVE_FILE) then
        local ok, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(SAVE_FILE))
        end)
        if ok and type(decoded) == "table" then
            data = decoded
        end
    end

    deepMerge(DEFAULT_DATA, data)
    saveData(data)
    return data
end

--// =====================================================
--// UI HELPER
--// =====================================================

local function updateToggle(btn, status)
    btn.Text = status and "ON" or "OFF"
    btn.TextColor3 = status
        and Color3.fromRGB(0,255,0)
        or Color3.fromRGB(255,0,0)
end

--// =====================================================
--// TXT FUNCTION (FIXED)
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

    -- Label
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
        a.Size = UDim2.new(0.58,0,1,0)
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
        box.Parent = b

        box.Size = UDim2.new(0.49,0,1,0)
        box.Position = UDim2.new(0.41,0,0,0)

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

    -- Button / Toggle
    local btn
    if hasButton then
        btn = Instance.new("TextButton")
        btn.BackgroundTransparency = 0.5
        btn.TextScaled = true
        btn.Size = UDim2.new(0.44,0,1,0)
        btn.Position = UDim2.new(0.59,0,0,0)
        btn.Parent = b
        Corner(0,8,btn)
        Stroke(btn, ASMBorder, 255, 255, 255, JSMRound, 1, 0)

        if hasBox then
            btn.Size = UDim2.new(0.25,0,1,0)
            btn.Position = UDim2.new(0.51,0,0,0)
        end

        -- INIT
        if status ~= nil then
            updateToggle(btn, status)
        else
            btn.Text = tostring(btxt or "OK")
            btn.TextColor3 = Color3.fromRGB(255,255,255)
        end

        -- SINGLE CONNECT (สำคัญ)
        btn.MouseButton1Click:Connect(function()
            if status ~= nil then
                status = not status
                updateToggle(btn, status)

                if work then work(status) end
                if callback then callback(status) end
            else
                if work then work() end
                if callback then callback() end
            end
        end)
    end

    return {
        Frame = b,
        Label = a,
        Box = box,
        Button = btn
    }
end

--// =====================================================
--// USAGE
--// =====================================================

local Data = loadData()
local CONTINUE_LOCK = true

-- Always Load → skip lock
if Data.Loader.AlwaysLoad == true then
    CONTINUE_LOCK = false
end

-- Continue (ONE TIME)
Txt(
    "Continue loadstring (ANTI-BROKE)",
    255,255,255,
    false, nil,
    true, "Okay",
    function()
        CONTINUE_LOCK = false
    end
)

-- Always Load (SAVE)
Txt(
    "Always Load",
    255,255,255,
    false, nil,
    true, nil,
    function(newStatus)
        Data.Loader.AlwaysLoad = newStatus
        saveData(Data)
    end,
    nil,
    Data.Loader.AlwaysLoad
)

--// =====================================================
--// BACKGROUND APPLY SYSTEM
--// =====================================================

local CoreGui = game:GetService("CoreGui")

local BG_PATHS = {
    "ExperienceSettings.Menu.AIOpenSource",
    "ExperienceSettings.Menu.About_Background",
    "ExperienceSettings.Menu.Background",
    "ExperienceSettings.Menu.HolderScreen",
    "ExperienceSettings.Menu.Load_Background",
    "ExperienceSettings.Menu.MiddleScreen",
    "ExperienceSettings.Menu.ProfileStatus",
    "ExperienceSettings.Menu.Search",
    "ExperienceSettings.Menu.TopBar.Holder",
    "ExperienceSettings.Menu.TopBar.TopButtons",
    "ExperienceSettings.Menu.Background.Inner_Background",
    "ExperienceSettings.Menu.Background.Inner2_Background"
}

local CURRENT_BG_COLOR = nil

task.spawn(function()
    while true do
        if CURRENT_BG_COLOR then
            for _, path in ipairs(BG_PATHS) do
                local inst = CoreGui:FindFirstChild(path, true)
                if inst and inst:IsA("GuiObject") then
                    inst.BackgroundColor3 = CURRENT_BG_COLOR
                end
            end
        end
        task.wait(0.5)
    end
end)

local function applyBackgroundColor(color)
    CURRENT_BG_COLOR = color
end

--// =====================================================
--// RGB PARSER
--// =====================================================

local function parseRGB(text)
    if not text then return nil end

    local r, g, b = text:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
    r, g, b = tonumber(r), tonumber(g), tonumber(b)

    if r and g and b then
        r = math.clamp(r, 0, 255)
        g = math.clamp(g, 0, 255)
        b = math.clamp(b, 0, 255)

        return Color3.fromRGB(r, g, b), { r, g, b }
    end
end

--// =====================================================
--// APPLY SAVED COLOR ON LOAD
--// =====================================================

applyBackgroundColor(Color3.fromRGB(
    Data.UI.BackgroundRGB[1],
    Data.UI.BackgroundRGB[2],
    Data.UI.BackgroundRGB[3]
))

--// =====================================================
--// CUSTOM BACKGROUND UI
--// =====================================================

local Data = loadData()

local function setBGFromData()
    local rgb = Data.UI.BackgroundRGB
    CURRENT_BG_COLOR = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

setBGFromData()

Txt(
    "Custom Background (R,G,B)",
    255,255,255,
    true, "30,30,30",
    true, "Confirm",

    -- work = live preview
    function(text)
        local color = select(1, parseRGB(text))
        if color then
            CURRENT_BG_COLOR = color
        end
    end,

    -- callback = CONFIRM ONLY
    function(box, btn)
        local color, raw = parseRGB(box.Text)
        if not color then return end

        -- FORCE SAVE
        Data.UI.BackgroundRGB = raw
        saveData(Data)

        CURRENT_BG_COLOR = color

        -- visual confirm
        btn.TextColor3 = Color3.fromRGB(0,255,0)
        task.delay(0.35, function()
            btn.TextColor3 = Color3.fromRGB(255,255,255)
        end)
    end
)














-- WAIT
while CONTINUE_LOCK do
    task.wait()
end
