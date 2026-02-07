-- Loader script 0.7

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
top.Text = "Settings - Loader Rejoiner"
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
--// FILE UTILS (EXECUTOR ONLY)
--// =====================================================

local function ensureFolder()
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
        HideMenu = false,
        SettingsTransparency = 0.5,
        UIScale = 1
    }
}

--// =====================================================
--// DEEP MERGE (เติมค่า default ที่หายไป)
--// =====================================================

local function deepMerge(data, defaults)
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            data[k] = type(data[k]) == "table" and data[k] or {}
            deepMerge(data[k], v)
        elseif data[k] == nil then
            data[k] = v
        end
    end
end

--// =====================================================
--// SAVE DATA  <<<<<< สำคัญ (ตัวนี้ที่เคย NIL)
--// =====================================================

local function saveData(data)
    ensureFolder()

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(data)
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

    -- เติม default ที่ขาด
    deepMerge(data, DEFAULT_DATA)

    -- save กลับทันที (กัน key หาย)
    saveData(data)

    return data
end

--// =====================================================

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
        a.Size = UDim2.new(1/3,0,1,0)
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
            box.Size = UDim2.new(1/3,0,1,0)
            box.Position = UDim2.new(0.343,0,0,0)
        end

        -- ✅ LIVE PREVIEW
        if work then
            box:GetPropertyChangedSignal("Text"):Connect(function()
                work(box)
            end)
        end
    end

    -- Button
    local btn
    if hasButton then
        btn = Instance.new("TextButton")
        btn.BackgroundTransparency = 0.5
        btn.TextScaled = true
        btn.Size = UDim2.new(0.44,0,1,0)
        btn.Position = UDim2.new(0.59,0,0,0)
        btn.Parent = b
        Corner(0,8,btn)
        Stroke(btn, ASMBorder, 255,255,255, LJMRound, 1, 0)

        if hasBox then
            btn.Size = UDim2.new(1/3,0,1,0)
            btn.Position = UDim2.new(0.696,0,0,0)
        end

        -- INIT
        if status ~= nil then
            updateToggle(btn, status)
        else
            btn.Text = tostring(btxt or "OK")
            btn.TextColor3 = Color3.fromRGB(255,255,255)
        end

        btn.MouseButton1Click:Connect(function()
            if status ~= nil then
                status = not status
                updateToggle(btn, status)
                if work then work(status) end
                if callback then callback(status) end
            else
                if callback then
                    callback(box, btn)
                end
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

-- =====================================================
-- LOAD DATA
-- =====================================================
local Data = loadData()

local CoreGui = game:GetService("CoreGui")

local MENU_INSTANCE = nil
local HIDE_MENU_STATUS = Data.UI.HideMenu -- อ่านจาก json ครั้งเดียว

local function applyHideMenu()
    if MENU_INSTANCE then
        MENU_INSTANCE.Enabled = not HIDE_MENU_STATUS
    end
end

-- 🔎 หา Menu (ใช้ชื่อ + parent เท่านั้น)
local function isTargetMenu(inst)
    return inst:IsA("ScreenGui")
        and inst.Name == "Menu"
        and inst.Parent
        and inst.Parent.Name == "ExperienceSettings"
end

-- 1️⃣ เช็คของที่มีอยู่แล้ว
for _, inst in ipairs(CoreGui:GetDescendants()) do
    if isTargetMenu(inst) then
        MENU_INSTANCE = inst
        applyHideMenu() -- ✅ apply ตาม json ทันที
        break
    end
end

-- 2️⃣ รอของที่โผล่มาทีหลัง
CoreGui.DescendantAdded:Connect(function(inst)
    if MENU_INSTANCE then return end

    if isTargetMenu(inst) then
        MENU_INSTANCE = inst
        applyHideMenu() -- ✅ apply ตาม json ทันที
    end
end)

local CONTINUE_LOCK = true

-- Always Load → skip lock
if Data.Loader.AlwaysLoad == true then
    CONTINUE_LOCK = false
end

-- Continue (ONE TIME)
local continueUI = Txt(
    "Continue loadstring main ExperienceSettings",
    255,255,255,
    false, nil,
    true, "Okay",
    nil,
    function(box, btn)
        CONTINUE_LOCK = false
        btn.Text = "Loaded"

        -- tween loop
        task.spawn(function()
            while btn and btn.Parent do
                if CONTINUE_LOCK then break end

                -- white → lime
                safeTween(btn, {
                    TextColor3 = Color3.fromRGB(0,255,0)
                }, 0.3)

                task.wait(0.3)

                -- lime → white
                safeTween(btn, {
                    TextColor3 = Color3.fromRGB(255,255,255)
                }, 0.3)

                task.wait(0.3)
            end
        end)
    end
)

-- Always Load (SAVE)
local alwaysUI = Txt(
    "Always Load main ExperienceSettings",
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

local alwaysBtn = alwaysUI.Button
--// =====================================================
--// BACKGROUND APPLY SYSTEM (WAIT UNTIL READY)
--// =====================================================

local CoreGui = game:GetService("CoreGui")

-- Path ที่ต้องครบทุกอันก่อน
local BG_PATHS = {
    "ExperienceSettings.Menu.AIOpenSource",
    "ExperienceSettings.Menu.About_Background",
    "ExperienceSettings.Menu.Background",
    "ExperienceSettings.Menu.Load_Background",
    "ExperienceSettings.Menu.MiddleScreen",
    "ExperienceSettings.Menu.ProfileStatus",
    "ExperienceSettings.Menu.Search",
    "ExperienceSettings.Menu.TopBar.Holder",
    "ExperienceSettings.Menu.TopBar.TopButtons",
    "ExperienceSettings.Menu.Background.Inner_Background",
    "ExperienceSettings.Menu.Background.Inner2_Background",
    "ExperienceSettings.Menu.HolderScreen.Shift_Lock"
}

-- ================================
-- หา Instance จาก path
-- ================================
local function findByPath(root, path)
    local current = root
    for part in string.gmatch(path, "[^%.]+") do
        current = current:FindFirstChild(part)
        if not current then
            return nil
        end
    end
    return current
end

-- ================================
-- ตรวจว่าครบทุก BG_PATHS ไหม
-- ================================
local function getAllBGInstances()
    local result = {}

    for _, path in ipairs(BG_PATHS) do
        local inst = findByPath(CoreGui, path)
        if not inst or not inst:IsA("GuiObject") then
            return nil -- ❌ ยังไม่ครบ
        end
        table.insert(result, inst)
    end

    return result -- ✅ ครบแล้ว
end

-- ================================
-- STATE
-- ================================
local READY = false
local CACHED_BGS = {}
local CURRENT_BG_COLOR = nil

-- ================================
-- WAIT SYSTEM (3 STAGES)
-- ================================
task.spawn(function()
    while not READY do
        -- Stage 1
        if not CoreGui:FindFirstChild("ExperienceSettings", true) then
            task.wait(0.2)
            continue
        end

        -- Stage 2
        local list = getAllBGInstances()
        if not list then
            task.wait(0.2)
            continue
        end

        -- Stage 3
        CACHED_BGS = list
        READY = true

        -- apply ถ้ามีสีรออยู่
        if CURRENT_BG_COLOR then
            for _, inst in ipairs(CACHED_BGS) do
                inst.BackgroundColor3 = CURRENT_BG_COLOR
            end
        end
    end
end)

-- ================================
-- API สำหรับเปลี่ยนสี
-- ================================
local function applyBackgroundColor(color)
    if not color then return end

    CURRENT_BG_COLOR = color

    -- ถ้า READY แล้ว → apply ทันที
    if READY then
        for _, inst in ipairs(CACHED_BGS) do
            inst.BackgroundColor3 = color
        end
    end
    -- ถ้ายังไม่ READY → เก็บค่าไว้เฉย ๆ
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

local function setBGFromData()
    local rgb = Data.UI.BackgroundRGB
    CURRENT_BG_COLOR = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

setBGFromData()

Txt(
    "Custom Background (R,G,B)",
    255,255,255,
    true, "18,18,21",
    true, "Save",

    -- LIVE PREVIEW
    function(box)
        local color = select(1, parseRGB(box.Text))
        if color then
            applyBackgroundColor(color)
        end
    end,

    -- CONFIRM + SAVE
    function(box, btn)
        local color, raw = parseRGB(box.Text)
        if not color then return end

        Data.UI.BackgroundRGB = raw
        saveData(Data)
        applyBackgroundColor(color)

        -- visual confirm
        btn.TextColor3 = Color3.fromRGB(0,255,0)
        task.delay(0.35, function()
            btn.TextColor3 = Color3.fromRGB(255,255,255)
        end)
    end
)

-- background watcher (ไม่บล็อก)
task.spawn(function()
    while true do
        if not MENU_INSTANCE then
            local menu = tryFindMenu()
            if menu then
                MENU_INSTANCE = menu
                applyHideMenu()
            end
        end
        task.wait(0.25)
    end
end)

Txt(
    "Hide ExperienceSettings",
    255,255,255,
    false, nil,
    true, nil,

    function(newStatus)
        HIDE_MENU_STATUS = newStatus
        Data.UI.HideMenu = newStatus
        saveData(Data)
        applyHideMenu()
    end,

    nil,
    Data.UI.HideMenu
)

--// =====================================================
--// FOUND HUMANOIDROOTPART STATUS
--// =====================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- สร้าง Text อย่างเดียว (ไม่มี box / ไม่มีปุ่ม)
local ui = Txt(
    "FoundHumanoidRootPart: NO",
    255,255,255,
    false, nil,
    false, nil
)

local label = ui.Label

-- ฟังก์ชันเช็ค HRP
local function updateHRPStatus()
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
updateHRPStatus()

-- เช็คเมื่อ character โหลดใหม่
LocalPlayer.CharacterAdded:Connect(function(char)
    updateHRPStatus()

    -- เผื่อ HRP โผล่ช้า
    char.ChildAdded:Connect(function(child)
        if child.Name == "HumanoidRootPart" then
            updateHRPStatus()
        end
    end)
end)

-- fallback: loop กันพลาด
task.spawn(function()
    while true do
        updateHRPStatus()
        task.wait(0.5)
    end
end)

--// =====================================================
--// SETTINGS TRANSPARENCY SYSTEM
--// =====================================================

local CoreGui = game:GetService("CoreGui")

local SETTINGS_INSTANCES = {}
local CURRENT_TRANSPARENCY = Data.UI.SettingsTransparency or 0.5

-- path ที่ต้องใช้
local SETTINGS_PATHS = {
    "LoaderSettings.Holder",
    "LoaderSettings.Holder.OPEN/CLOSE"
}

-- find by path
local function findByPath(root, path)
    local cur = root
    for part in string.gmatch(path, "[^%.]+") do
        cur = cur:FindFirstChild(part)
        if not cur then return nil end
    end
    return cur
end

-- apply transparency
local function applyTransparency(value)
    CURRENT_TRANSPARENCY = math.clamp(value, 0, 1)

    for _, inst in ipairs(SETTINGS_INSTANCES) do
        if inst:IsA("GuiObject") then
            inst.BackgroundTransparency = CURRENT_TRANSPARENCY
        end
    end
end

-- watcher (ไม่บล็อก)
task.spawn(function()
    while #SETTINGS_INSTANCES < #SETTINGS_PATHS do
        SETTINGS_INSTANCES = {}

        for _, path in ipairs(SETTINGS_PATHS) do
            local inst = findByPath(CoreGui, path)
            if inst and inst:IsA("GuiObject") then
                table.insert(SETTINGS_INSTANCES, inst)
            end
        end

        task.wait(0.25)
    end

    -- เจอครบ → apply ตาม data
    applyTransparency(CURRENT_TRANSPARENCY)
end)

Txt(
    "Settings Transparency",
    255,255,255,
    true, "0.5",
    true, "Save",

    -- LIVE PREVIEW
    function(box)
        local v = tonumber(box.Text)
        if v then
            applyTransparency(v)
        end
    end,

    -- SAVE
    function(box, btn)
        local v = tonumber(box.Text)
        if not v then return end

        v = math.clamp(v, 0, 1)
        Data.UI.SettingsTransparency = v
        saveData(Data)
        applyTransparency(v)

        btn.TextColor3 = Color3.fromRGB(0,255,0)
        task.delay(0.35, function()
            btn.TextColor3 = Color3.fromRGB(255,255,255)
        end)
    end
)

-- =====================================================
-- LOAD DATA
-- =====================================================
local Data = loadData()
Data.UI = Data.UI or {}
Data.UI.UIScale = tonumber(Data.UI.UIScale) or 1

-- =====================================================
-- SERVICES
-- =====================================================
local CoreGui = game:GetService("CoreGui")

-- =====================================================
-- STATE
-- =====================================================
local MENU_INSTANCE = nil
local UISCALE_INSTANCE = nil
local CURRENT_SCALE = Data.UI.UIScale

-- =====================================================
-- FIND MENU (CoreGui.ExperienceSettings.Menu)
-- =====================================================
local function tryFindMenu()
    local root = CoreGui:FindFirstChild("ExperienceSettings")
    if not root then return nil end
    return root:FindFirstChild("Menu")
end

-- =====================================================
-- APPLY UI SCALE
-- =====================================================
local function applyUIScale(scale)
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
        local menu = tryFindMenu()
        if menu and menu ~= MENU_INSTANCE then
            MENU_INSTANCE = menu
            UISCALE_INSTANCE = nil
            applyUIScale(CURRENT_SCALE) -- apply จาก data ทันที
        end
        task.wait(0.25)
    end
end)

-- =====================================================
-- UI (Txt)
-- =====================================================
Txt(
    "Set UIScaled",
    255,255,255,
    true, tostring(Data.UI.UIScale),
    true, "Save",

    -- LIVE PREVIEW
    function(box)
        local v = tonumber(box.Text)
        if v then
            applyUIScale(v)
        end
    end,

    -- SAVE
    function(box, btn)
        local v = tonumber(box.Text)
        if not v then return end

        v = math.clamp(v, 0.5, 2)
        Data.UI.UIScale = v
        saveData(Data)
        applyUIScale(v)

        -- feedback
        btn.TextColor3 = Color3.fromRGB(0,255,0)
        task.delay(0.35, function()
            btn.TextColor3 = Color3.fromRGB(255,255,255)
        end)
    end
)

local StarterGui = game:GetService("StarterGui")

local function isHealthEnabled()
    local ok, res = pcall(function()
        return StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Health)
    end)
    return ok and res or false
end

local function setHealth(state)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, state)
end

-- TXT: Status
local healthTxt = Txt(
    "IsHealthOn: ...",
    0,255,0,
    false,nil,
    false,nil
)

-- TXT: Toggle
local HealthToggle = Txt(
    "HealthBarToggle",
    255,255,255,
    false,nil,
    true,"",
    function(status)
        setHealth(status)
    end,
    function(status)
        setHealth(status)
    end,
    isHealthEnabled()
)

-- 🔁 Unified watcher
task.spawn(function()
    local last
    while true do
        local on = isHealthEnabled()
        if on ~= last then
            -- update text
            healthTxt.Label.Text = "IsHealthOn: " .. (on and "YES" or "NO")
            healthTxt.Label.TextColor3 = on
                and Color3.fromRGB(0,255,0)
                or Color3.fromRGB(255,0,0)

            -- update button
            updateToggle(HealthToggle.Button, on)

            last = on
        end
        task.wait(0.5)
    end
end)





























-- This only way the last toggle
local StarterGui = game:GetService("StarterGui")

Txt(
    "Console shortcut",
    255,255,255,
    false,nil,
    true,"OPEN",
    nil,
    function()
        pcall(function()
            StarterGui:SetCore("DevConsoleVisible", true)
        end)
    end
)

local kill = Txt(
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

-- WAIT
while CONTINUE_LOCK do
    task.wait()
end
