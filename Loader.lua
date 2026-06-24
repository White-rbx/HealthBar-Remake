-- Loader script 2.24

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
gui.DisplayOrder = 2147483646
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

-- Holder 2
local hr2 = Instance.new("Frame")
hr2.Name = "Holder"
hr2.Size = UDim2.new(1,0,1,0)
hr2.Position = UDim2.new(-1,0,0,0)
hr2.BackgroundTransparency = 0.3
hr2.BorderSizePixel = 0
hr2.BackgroundColor3 = Color3.fromRGB(18,18,21)
hr2.Active = false
hr2.Parent = hr -- original frame 

-- Inside 2
local ins2 = Instance.new("Frame")
ins2.Name = "Inside"
ins2.Size = UDim2.new(0.92,0,0.96,0)
ins2.Position = UDim2.new(0.04,0,0.02,0)
ins2.BackgroundTransparency = 1
ins2.Active = false
ins2.Parent = hr2
ListLayout(ins2, 0, 5, HCenter, VTop, SLayout, FillV)

-- Holder
local top2 = Instance.new("TextLabel")
top2.Name = "Topic"
top2.Size = UDim2.new(1,0,0.05,0)
top2.BackgroundTransparency = 1
top2.TextScaled = true
top2.Text = "Settings - 2"
top2.TextColor3 = Color3.fromRGB(255,255,255)
top2.Parent = ins2
Corner(0, 8, top2)
Stroke(top2, ASMBorder, 255,255,255, LJMRound, 1, 0)


-- Toggle for holder
-- ตัวแปรที่มีอยู่แล้ว
-- hr : Frame
-- oc : TextButton

local POSITIONS = {
    -0.3, -- OFF
    0,    -- OPEN 1
    0.3   -- OPEN 2
}

local state = 1 -- เริ่มที่ OFF

local tweenInfo = TweenInfo.new(
    0.25,
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
    -- เปลี่ยนสถานะ
    state += 1
    if state > #POSITIONS then
        state = 1
    end

    tweenHR(POSITIONS[state])
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
        SettingsTransparency = 0.3,
        UIScale = 1,
        DraggableUI = false,
        CrosshairID = "rbxassetid://118624373632520",
        ToolCrosshairID = "rbxassetid://73868291781876"
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
    work, callback, status,
    parent
)
    -- Frame
    local b = Instance.new("Frame")
    b.Name = "Handle"
    b.Size = UDim2.new(1, 0, 0.05, 0)
    b.BackgroundTransparency = 1
    b.Parent = parent or ins

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
    task.spawn(function()
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
------------------------------------------------------------

-- Continue (ONE TIME)
local continueUI = Txt(
    "Continue loadstring main ExperienceSettings",
    255,255,255,
    false, nil,
    true, "Get Load",
    nil,
    function(box, btn)

        -- safety check
        local player = game.Players.LocalPlayer
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        local healthEnabled = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Health)

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

            local tween = TweenService:Create(
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

local continueBtn = continueUI.Button
local alwaysBtn = alwaysUI.Button

-- function ตรวจสถานะโหลดได้หรือไม่
local function canLoad()
    local player = game.Players.LocalPlayer
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    local healthOn = false
    pcall(function()
        healthOn = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Health)
    end)

    return hrp and healthOn
end

-- bypass warning watcher
task.spawn(function()
    while continueBtn and continueBtn.Parent do
        local alwaysOn = alwaysBtn.Text == "ON"
        local ok = canLoad()

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
			local menu =
				findByPath(
					CoreGui,
					"ExperienceSettings.Menu"
				)
			if menu
			and menu:IsA("ScreenGui") then
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
    "LoaderSettings.Holder.OPEN/CLOSE",
    "LoaderSettings.Holder.Holder"
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
    true, "0.3",
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

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local placeId = game.PlaceId

------------------------------------------------------------

local rejoinUI = Txt(
    "Rejoin",
    255,255,255,
    false, nil,
    true, "Confirm",
    nil,
    function(box, btn)
        btn.Text = "Rejoining..."
        btn.TextColor3 = Color3.fromRGB(150,255,150)

        task.spawn(function()
            task.wait(0.5)
            TeleportService:Teleport(placeId, player)
        end)
    end
)

------------------------------------------------------------

local switchUI = Txt(
    "Switch Server",
    255,255,255,
    false, nil,
    true, "Confirm",
    nil,
    function(box, btn)
        btn.Text = "Finding Server..."
        btn.TextColor3 = Color3.fromRGB(255,255,0)

        task.spawn(function()
            local start = tick()
            local found = false

            while tick() - start < 5 do
                local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
                local success, result = pcall(function()
                    return HttpService:JSONDecode(game:HttpGet(url))
                end)

                if success and result and result.data then
                    for _, server in ipairs(result.data) do
                        if server.playing < server.maxPlayers and server.id ~= game.JobId then
                            found = true
                            TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
                            return
                        end
                    end
                end

                task.wait(1)
            end

            if not found then
                btn.Text = "Server not found or full"
                btn.TextColor3 = Color3.fromRGB(255,150,0)
            end
        end)
    end
)

------------------------------------------------------------

local lowSwitchUI = Txt(
    "Switch to Low Players Server",
    255,255,255,
    false, nil,
    true, "Confirm",
    nil,
    function(box, btn)
        btn.Text = "Finding Low Players Server..."
        btn.TextColor3 = Color3.fromRGB(255,255,0)

        local start = tick()
        local found = false

        while tick() - start < 5 do
            local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
            local success, result = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)

            if success and result and result.data then
                for _, server in ipairs(result.data) do
                    if server.playing >= 3 and server.playing <= 5 and server.id ~= game.JobId then
                        found = true
                        TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
                        return
                    end
                end
            end

            task.wait(1)
        end

        if not found then
            btn.Text = "Server not found, please try again later."
            btn.TextColor3 = Color3.fromRGB(255,170,0)
        end
    end
)

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

local function applyDraggableUI(state)

    DragState = state

    if DragLoopStarted then
        return
    end

    DragLoopStarted = true

    task.spawn(function()

        while true do

            -- ExperienceSettings
            local vES = CoreGui:FindFirstChild("ExperienceSettings")
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
            local vTopBar = CoreGui:FindFirstChild("TopBarApp")
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



local function DragUItweenColor(obj,color)
    TweenService:Create(
        obj,
        TweenInfo.new(0.25),
        {TextColor3 = color}
    ):Play()
end

-- toggle UI
local DraUI = Txt(
    "Draggable UI",
    255,255,255,
    false,nil,
    true,"OFF",

    function(state)

        Data.UI.DraggableUI = state
        saveData(Data)

        applyDraggableUI(state)

    end,

    nil,

    Data.UI.DraggableUI
)

-- apply color when UI created
if DraUI.Button then
    if Data.UI.DraggableUI then
        DraUI.Button.Text = "ON"
        DragUItweenColor(DraUI.Button, Color3.fromRGB(0,255,0))
    else
        DraUI.Button.Text = "OFF"
        DragUItweenColor(DraUI.Button, Color3.fromRGB(255,0,0))
    end
end

-- apply ตอนโหลด
task.spawn(function()
    applyDraggableUI(Data.UI.DraggableUI)
end)

--// =====================================================
--// CROSSHAIR SYSTEM (FIXED)
--// =====================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

local DEFAULT_CROSSHAIR =
	"rbxassetid://118624373632520"

local DEFAULT_TOOL_CROSSHAIR =
	"rbxassetid://73868291781876"

local TARGET_SHIFT = nil

--====================================================--
-- GET IMAGE FROM DATA
--====================================================--

local function getNormalCrosshair()

	local id = Data.UI.CrosshairID

	if not id
	or id == ""
	or id == "0" then

		return DEFAULT_CROSSHAIR
	end

	return id
end

local function getToolCrosshair()

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

local function isToolEnabled()

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

local function applyCrosshair()

	if not TARGET_SHIFT then
		return
	end

	local current =
		TARGET_SHIFT.Image

	--================================================--
	-- TOOL MODE
	--================================================--

	if isToolEnabled() then

		local newTool =
			getToolCrosshair()

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
			getNormalCrosshair()

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
			CoreGui:FindFirstChild(
				"TargetShift",
				true
			)

		if target
		and target:IsA("ImageLabel") then

			TARGET_SHIFT = target

			-- APPLY ล่าสุดจาก DATA ทันที
			applyCrosshair()

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
				applyCrosshair()
			end

		end)

		char.ChildRemoved:Connect(function(v)

			if v:IsA("Tool") then
				task.wait()
				applyCrosshair()
			end

		end)

		task.wait()
		applyCrosshair()

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
			if isToolEnabled() then

				local wanted =
					getToolCrosshair()

				if current == DEFAULT_TOOL_CROSSHAIR
				and wanted ~= DEFAULT_TOOL_CROSSHAIR then

					TARGET_SHIFT.Image =
						wanted
				end

			-- NORMAL MODE
			else

				local wanted =
					getNormalCrosshair()

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

Txt(
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

		saveData(Data)

		-- APPLY NOW
		applyCrosshair()

		-- VISUAL
		btn.TextColor3 =
			Color3.fromRGB(0,255,0)

		task.delay(0.35,function()

			btn.TextColor3 =
				Color3.fromRGB(255,255,255)

		end)

	end,

	nil,

	ins2
)

--====================================================--
-- CUSTOM TOOL CROSSHAIR ID
--====================================================--

Txt(
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

		saveData(Data)

		-- APPLY NOW
		applyCrosshair()

		-- VISUAL
		btn.TextColor3 =
			Color3.fromRGB(0,255,0)

		task.delay(0.35,function()

			btn.TextColor3 =
				Color3.fromRGB(255,255,255)

		end)

	end,

	nil,

	ins2
)

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
local function Eng()

-- AIThinking
List.ai.Text.chat.PlaceholderText = "Type /Help to show all commands or Say something..."
List.ai.Confirm_api.Text = "Confirm API"
List.ai.Unsaved_API.Text = "Unsaved API"
List.ai.api.PlaceholderText = "[ Your API here (ChatGPT or Gemini) ]"
List.ai.Status.Text = "Status: No key"
List.ai.Topic.Text = "<b><stroke color='rgb(85,255,255)' thickness='2'>AI-Thinking</stroke></b>"
List.ai.Unavailable.Text = "<b><stroke color='rgb(255,100,100)' thickness='1' transparency='0'>UNAVAILABLE FEATURES (Old)</stroke></b>"
-- List.ai.ver.Text = "Version:"

-- About_Background
List.ab.Scroll.About.Text = [[
The ExperienceSettings is debug tools you can use on your own, there are a lot of tools!
For HealthBar was a remake of better and smoother and ValueLabels for show values.
If your ExperienceSettings was Disabled there are three reasons,
 • HumanoidRootPart was removed too long.
 • The Experience doesn't support the ExperienceSettings.
 • Script failed to load.
If you enjoy it, you can support me on discord!
Thank you for using ExperienceSettings! ♥️

54% Gui is made by hand
10% Script is made by hand
36% Script is made by ai

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
📌 Updated: Update in this information is no longer appear now, please join our discord community to following update!
-------
🔁 In progress: No longer appear features
-------
❌ Failed: No longer appear unavailable features
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

List.ab.Hide.Text = "Hide"
List.ab.Help.Text = "Oh, if the ExperienceSettings was disabled. You can hide the text by click the button."

-- Background
List.bg.Settings.Buttons.Leave.Text = "Leave"
List.bg.Settings.Buttons["Reset character"].Text = "Reset character"
List.bg.Settings.Buttons.Resume.Text = "Resume"
List.bg.Settings.Pmax.SeeAll.Text = "Open Roblox Settings"
List.bg.Settings.Pmax.Players.Text = "Player :"

List.bg.Settings.B_Frame.Frame1.Label.Text = "Enable ValueLabels"
List.bg.Settings.B_Frame.Frame2.Label.Text = "Shaders - Recommend graphics 5+"
List.bg.Settings.B_Frame.Frame3.Label.Text = "White Light"
List.bg.Settings.B_Frame.Frame4.Label.Text = "RGB Light"
List.bg.Settings.B_Frame.Frame5.Label.Text = "ESP (Beta)"
List.bg.Settings.B_Frame.Frame6.Label.Text = "Damage Overlay"
List.bg.Settings.B_Frame.Frame7.Label.Text = "MoreToggles"

List.bg.Inner_Background.Toggles.B_Frams.Frame1.Label.Text = "LighterCyan.ai (Discontinued)"
List.bg.Inner_Background.Toggles.B_Frams:GetChildren()[13].Label.Text = "Show Physics"
List.bg.Inner_Background.Toggles.B_Frams.Frame10.Label.Text = "Last Death"
List.bg.Inner_Background.Toggles.B_Frams.Frame11.Label.Text = "ServerPositionPredictor (By @zephyrr)"
List.bg.Inner_Background.Toggles.B_Frams.Frame2.Label.Text = "Enable HealthBar"
List.bg.Inner_Background.Toggles.B_Frams:GetChildren()[14].Label.Text = "Global Physics"
List.bg.Inner_Background.Toggles.B_Frams.Frame3.Label.Text = "Disable Death Sound"
List.bg.Inner_Background.Toggles.B_Frams.Frame4.Label.Text = "FreeCam (Mobile)"
List.bg.Inner_Background.Toggles.B_Frams.Frame5.Label.Text = "Almost Endless Fallen (-50K)"
List.bg.Inner_Background.Toggles.B_Frams.Frame6.Label.Text = "Flashlight (FirstPerson & GFX 6+)"
List.bg.Inner_Background.Toggles.B_Frams.Frame7.Label.Text = "ESP Highlight Players & Non-Players"
List.bg.Inner_Background.Toggles.B_Frams.Frame8.Label.Text = "Shift Lock (Mobile)"
List.bg.Inner_Background.Toggles.B_Frams.Frame9.Label.Text = "Hitbox Shower"

-- Load_Background
List.lb.Skip.Text = "Close fuc#king annoying load bar"
List.lb.Credit.Text = "Creator by @5teve3019D on ScriptBlox/HaxHell"
List.lb.Loading.Text = "Loading"
List.lb.Wait.Text = "Starting ExperienceSettings. Please wait..."

-- ProfileStatus
List.pfs.InsideProfileStatus.ProfileCharacter.Scroll.Beta.Text = "It might have bug and it still in beta."
List.pfs.InsideProfileStatus.ProfileCharacter.Scroll.DeveloperConsole.Text = "Open Developer console"
List.pfs.InsideProfileStatus.ProfileCharacter.Scroll.DropTool.Text = "Drop Tool"
List.pfs.InsideProfileStatus.ProfileCharacter.Scroll.DropTools.Text = "Drop all tools"

-- Search
List.sh.SearchBar.Searcher.PlaceholderText = "[ Select first ] Searcher"

end

--======= SPAIN ========--
local function Spa()

-- AIThinking
List.ai.Text.chat.PlaceholderText = "Escribe /Help para mostrar todos los comandos o di algo..."
List.ai.Confirm_api.Text = "Confirmar API"
List.ai.Unsaved_API.Text = "API no guardada"
List.ai.api.PlaceholderText = "[ Tu API aquí (ChatGPT o Gemini) ]"
List.ai.Status.Text = "Estado: Sin clave"
List.ai.Topic.Text = "<b><stroke color='rgb(85,255,255)' thickness='2'>Pensamiento IA</stroke></b>"
List.ai.Unavailable.Text = "<b><stroke color='rgb(255,100,100)' thickness='1' transparency='0'>FUNCIONES NO DISPONIBLES (Antiguas)</stroke></b>"
-- List.ai.ver.Text = "Versión:"

-- About_Background
List.ab.Scroll.About.Text = [[
ExperienceSettings es una herramienta de depuración que puedes usar por tu cuenta; ¡tiene muchas herramientas!
HealthBar fue un remake más fluido y mejor, y ValueLabels sirve para mostrar valores.
Si tu ExperienceSettings está deshabilitado, hay tres razones:
 • El HumanoidRootPart fue eliminado hace demasiado tiempo.
 • El Experience no admite ExperienceSettings.
 • El script no pudo cargarse.
Si te gusta, ¡puedes apoyarme en Discord!
¡Gracias por usar ExperienceSettings! ♥️

54% de la GUI está hecha a mano
10% del script está hecho a mano
36% del script está hecho con IA

Creador: @5teve3019D (GUI, pequeño script)
Ayudante: ChatGPT (Script) <-- Sí, recibió muchas quejas jaja.
Pequeño ayudante: Copilot de GitHub (Script)
Dato curioso: lo antiguo es más feo que lo de ahora jajaja, te lo juro 😂 Ah, no has visto lo de antes :(

========================
➕ = Añadir algo
📢 = Anuncios
🔨 = En desarrollo
🔷 = Plan para futuras actualizaciones
✅ = Hecho
⚠️ = Tiene problemas
🟠 = Pronto se actualizará
❌ = Error
⚫ = No se puede arreglar
➖ = Desconectado o descontinuado
-------
📌 Actualizado: esta información ya no aparece en las actualizaciones; ¡por favor únete a nuestra comunidad de Discord para seguirlas!
-------
🔁 En progreso: funciones que ya no aparecen
-------
❌ Fallado: funciones no disponibles que ya no aparecen
-------

✨ CRÉDITOS DEL SCRIPT ✨
[ Nombre del script ] por [ Creador ] [ Estado de verificación ]

Queremos decir que tu script es increíble y se usa en nuestro proyecto para depuración y fines educativos.
Gracias por tu contribución :3 ❤️
- Debugger

-- Lista de créditos --
'Ketamine' por @Cherry (✓ Verificado)
'OG AFEM – Legacy' por @Imperial (✓ Verificado)
'Chat' por usuario desconocido
'UNC' por usuario desconocido
'REM' por @evildotcom (X No verificado)
'GameProber' por @Imperial (✓ Verificado)
'AudioPlayer' por usuario desconocido
'EmoteSelect' por usuario desconocido
'Universal Movement Predictor' por @zephyrr (X No verificado)
'Server Position Predictor' por @zephyrr (X No verificado)
'Open Source Universal Chat' por @neutral (X No verificado)

-- Aviso para creadores de scripts --
Si eres creador de uno de los scripts mencionados arriba y no quieres que tu script esté incluido,
por favor contáctanos a través de nuestro foro de Discord y lo eliminaremos de inmediato.
]]

List.ab.Hide.Text = "Ocultar"
List.ab.Help.Text = "Oh, si ExperienceSettings está deshabilitado, puedes ocultar el texto pulsando el botón."

-- Background
List.bg.Settings.Buttons.Leave.Text = "Salir"
List.bg.Settings.Buttons["Reset character"].Text = "Reiniciar personaje"
List.bg.Settings.Buttons.Resume.Text = "Continuar"
List.bg.Settings.Pmax.SeeAll.Text = "Abrir configuración de Roblox"
List.bg.Settings.Pmax.Players.Text = "Jugador :"

List.bg.Settings.B_Frame.Frame1.Label.Text = "Activar ValueLabels"
List.bg.Settings.B_Frame.Frame2.Label.Text = "Shaders - Se recomiendan gráficos 5+"
List.bg.Settings.B_Frame.Frame3.Label.Text = "Luz blanca"
List.bg.Settings.B_Frame.Frame4.Label.Text = "Luz RGB"
List.bg.Settings.B_Frame.Frame5.Label.Text = "ESP (Beta)"
List.bg.Settings.B_Frame.Frame6.Label.Text = "Superposición de daño"
List.bg.Settings.B_Frame.Frame7.Label.Text = "Más toggles"

List.bg.Inner_Background.Toggles.B_Frams.Frame1.Label.Text = "LighterCyan.ai (Descontinuado)"
List.bg.Inner_Background.Toggles.B_Frams:GetChildren()[13].Label.Text = "Mostrar física"
List.bg.Inner_Background.Toggles.B_Frams.Frame10.Label.Text = "Última muerte"
List.bg.Inner_Background.Toggles.B_Frams.Frame11.Label.Text = "ServerPositionPredictor (Por @zephyrr)"
List.bg.Inner_Background.Toggles.B_Frams.Frame2.Label.Text = "Activar HealthBar"
List.bg.Inner_Background.Toggles.B_Frams:GetChildren()[14].Label.Text = "Física global"
List.bg.Inner_Background.Toggles.B_Frams.Frame3.Label.Text = "Desactivar sonido de muerte"
List.bg.Inner_Background.Toggles.B_Frams.Frame4.Label.Text = "FreeCam (Móvil)"
List.bg.Inner_Background.Toggles.B_Frams.Frame5.Label.Text = "Caída casi interminable (-50K)"
List.bg.Inner_Background.Toggles.B_Frams.Frame6.Label.Text = "Linterna (Primera persona y GFX 6+)"
List.bg.Inner_Background.Toggles.B_Frams.Frame7.Label.Text = "ESP resalta jugadores y no jugadores"
List.bg.Inner_Background.Toggles.B_Frams.Frame8.Label.Text = "Shift Lock (Móvil)"
List.bg.Inner_Background.Toggles.B_Frams.Frame9.Label.Text = "Lluvia de hitboxes"

-- Load_Background
List.lb.Skip.Text = "Cerrar barra de carga molesta"
List.lb.Credit.Text = "Creador por @5teve3019D en ScriptBlox/HaxHell"
List.lb.Loading.Text = "Cargando"
List.lb.Wait.Text = "Iniciando ExperienceSettings. Por favor espera..."

-- ProfileStatus
List.pfs.InsideProfileStatus.ProfileCharacter.Scroll.Beta.Text = "Podría tener errores y todavía está en beta."
List.pfs.InsideProfileStatus.ProfileCharacter.Scroll.DeveloperConsole.Text = "Abrir consola de desarrollador"
List.pfs.InsideProfileStatus.ProfileCharacter.Scroll.DropTool.Text = "Soltar herramienta"
List.pfs.InsideProfileStatus.ProfileCharacter.Scroll.DropTools.Text = "Soltar todas las herramientas"

-- Search
List.sh.SearchBar.Searcher.PlaceholderText = "[ Selecciona primero ] Buscador"

end

--======= THAI ========--
local function Tha()

-- AIThinking
List.ai.Text.chat.PlaceholderText = "พิมพ์ /Help เพื่อดูคำสั่งทั้งหมด หรือพิมพ์อะไรสักอย่าง..."
List.ai.Confirm_api.Text = "ยืนยัน API"
List.ai.Unsaved_API.Text = "API ยังไม่บันทึก"
List.ai.api.PlaceholderText = "[ ใส่ API ของคุณที่นี่ (ChatGPT หรือ Gemini) ]"
List.ai.Status.Text = "สถานะ: ไม่มีคีย์"
List.ai.Topic.Text = "<b><stroke color='rgb(85,255,255)' thickness='2'>AI-Thinking</stroke></b>"
List.ai.Unavailable.Text = "<b><stroke color='rgb(255,100,100)' thickness='1' transparency='0'>ฟีเจอร์ที่ใช้งานไม่ได้ (ของเก่า)</stroke></b>"
-- List.ai.ver.Text = "Version:"

-- About_Background
List.ab.Scroll.About.Text = [[
ExperienceSettings เป็นเครื่องมือดีบักที่คุณสามารถใช้ได้เอง มีเครื่องมือเยอะมาก!
สำหรับ HealthBar นั้นเป็นเวอร์ชันรีเมคที่ลื่นกว่าและดีกว่า และ ValueLabels ใช้สำหรับแสดงค่า
ถ้า ExperienceSettings ของคุณถูกปิดใช้งาน มีอยู่ 3 สาเหตุ:
 • HumanoidRootPart ถูกลบไปนานเกินไป
 • Experience นี้ไม่รองรับ ExperienceSettings
 • สคริปต์โหลดไม่สำเร็จ
ถ้าคุณชอบมัน คุณสามารถสนับสนุนฉันได้ทาง Discord!
ขอบคุณที่ใช้ ExperienceSettings! ♥️

54% ของ GUI ทำด้วยมือ
10% ของสคริปต์ทำด้วยมือ
36% ของสคริปต์ทำโดย AI

ผู้สร้าง: @5teve3019D (GUI, สคริปต์ส่วนเล็ก)
ผู้ช่วย: ChatGPT (สคริปต์) <-- เขาโดนบ่นเยอะมากเลย ฮ่าๆ
ผู้ช่วยตัวเล็ก: Copilot ของ GitHub (สคริปต์)
เกร็ดน่าสนใจ: ของเก่าขี้เหร่กว่าตอนนี้เยอะเลย ฉันสาบาน 😂 โอ้ คุณยังไม่เคยเห็นมันสินะ :(

========================
➕ = เพิ่มอะไรบางอย่าง
📢 = ประกาศ
🔨 = กำลังพัฒนา
🔷 = แผนสำหรับอัปเดตในอนาคต
✅ = เสร็จแล้ว
⚠️ = มีปัญหา
🟠 = จะอัปเดตเร็ว ๆ นี้
❌ = บั๊ก
⚫ = ไม่สามารถแก้ได้
➖ = ตัดการเชื่อมต่อหรือยกเลิกการพัฒนา
-------
📌 อัปเดต: ข้อมูลในส่วนนี้จะไม่แสดงในอัปเดตอีกต่อไป กรุณาเข้าร่วมชุมชน Discord ของเราเพื่อรับข่าวสารต่อไป!
-------
🔁 อยู่ระหว่างดำเนินการ: ฟีเจอร์ที่ไม่แสดงอีกแล้ว
-------
❌ ล้มเหลว: ฟีเจอร์ที่ไม่พร้อมใช้งานซึ่งไม่แสดงอีกแล้ว
-------

✨ เครดิตสคริปต์ ✨
[ ชื่อสคริปต์ ] โดย [ ผู้สร้าง ] [ สถานะการยืนยัน ]

เราขอบอกว่าสคริปต์ของคุณยอดเยี่ยมมาก และถูกใช้ในโปรเจกต์ของเราเพื่อการดีบักและเพื่อการศึกษา
ขอบคุณสำหรับผลงานของคุณ :3 ❤️
- Debugger

-- รายชื่อเครดิต --
'Ketamine' โดย @Cherry (✓ ยืนยันแล้ว)
'OG AFEM – Legacy' โดย @Imperial (✓ ยืนยันแล้ว)
'Chat' โดยผู้ใช้ไม่ทราบชื่อ
'UNC' โดยผู้ใช้ไม่ทราบชื่อ
'REM' โดย @evildotcom (X ยังไม่ยืนยัน)
'GameProber' โดย @Imperial (✓ ยืนยันแล้ว)
'AudioPlayer' โดยผู้ใช้ไม่ทราบชื่อ
'EmoteSelect' โดยผู้ใช้ไม่ทราบชื่อ
'Universal Movement Predictor' โดย @zephyrr (X ยังไม่ยืนยัน)
'Server Position Predictor' โดย @zephyrr (X ยังไม่ยืนยัน)
'Open Source Universal Chat' โดย @neutral (X ยังไม่ยืนยัน)

-- แจ้งเตือนสำหรับผู้สร้างสคริปต์ --
หากคุณเป็นผู้สร้างสคริปต์ที่ระบุไว้ข้างต้น และไม่ต้องการให้สคริปต์ของคุณถูกรวมไว้
กรุณาติดต่อเราผ่านฟอรัม Discord ของเรา และเราจะลบออกให้ทันที
]]

List.ab.Hide.Text = "ซ่อน"
List.ab.Help.Text = "อ้อ ถ้า ExperienceSettings ถูกปิดใช้งาน คุณสามารถซ่อนข้อความได้โดยกดปุ่มนี้"

-- Background
List.bg.Settings.Buttons.Leave.Text = "ออก"
List.bg.Settings.Buttons["Reset character"].Text = "รีเซ็ตตัวละคร"
List.bg.Settings.Buttons.Resume.Text = "กลับเข้าเกม"
List.bg.Settings.Pmax.SeeAll.Text = "เปิดการตั้งค่า Roblox"
List.bg.Settings.Pmax.Players.Text = "ผู้เล่น :"

List.bg.Settings.B_Frame.Frame1.Label.Text = "เปิด ValueLabels"
List.bg.Settings.B_Frame.Frame2.Label.Text = "Shaders - แนะนำกราฟิก 5+"
List.bg.Settings.B_Frame.Frame3.Label.Text = "แสงสีขาว"
List.bg.Settings.B_Frame.Frame4.Label.Text = "แสง RGB"
List.bg.Settings.B_Frame.Frame5.Label.Text = "ESP (เบต้า)"
List.bg.Settings.B_Frame.Frame6.Label.Text = "โอเวอร์เลย์ความเสียหาย"
List.bg.Settings.B_Frame.Frame7.Label.Text = "ตัวเลือกเพิ่มเติม"

List.bg.Inner_Background.Toggles.B_Frams.Frame1.Label.Text = "LighterCyan.ai (เลิกพัฒนาแล้ว)"
List.bg.Inner_Background.Toggles.B_Frams:GetChildren()[13].Label.Text = "แสดงฟิสิกส์"
List.bg.Inner_Background.Toggles.B_Frams.Frame10.Label.Text = "การตายครั้งล่าสุด"
List.bg.Inner_Background.Toggles.B_Frams.Frame11.Label.Text = "ServerPositionPredictor (โดย @zephyrr)"
List.bg.Inner_Background.Toggles.B_Frams.Frame2.Label.Text = "เปิด HealthBar"
List.bg.Inner_Background.Toggles.B_Frams:GetChildren()[14].Label.Text = "ฟิสิกส์แบบรวม"
List.bg.Inner_Background.Toggles.B_Frams.Frame3.Label.Text = "ปิดเสียงตาย"
List.bg.Inner_Background.Toggles.B_Frams.Frame4.Label.Text = "FreeCam (มือถือ)"
List.bg.Inner_Background.Toggles.B_Frams.Frame5.Label.Text = "Almost Endless Fallen (-50K)"
List.bg.Inner_Background.Toggles.B_Frams.Frame6.Label.Text = "ไฟฉาย (บุคคลที่หนึ่ง & GFX 6+)"
List.bg.Inner_Background.Toggles.B_Frams.Frame7.Label.Text = "ESP ไฮไลต์ผู้เล่นและสิ่งที่ไม่ใช่ผู้เล่น"
List.bg.Inner_Background.Toggles.B_Frams.Frame8.Label.Text = "Shift Lock (มือถือ)"
List.bg.Inner_Background.Toggles.B_Frams.Frame9.Label.Text = "Hitbox Shower"

-- Load_Background
List.lb.Skip.Text = "ปิดแถบโหลดน่ารำคาญ"
List.lb.Credit.Text = "ผู้สร้างโดย @5teve3019D บน ScriptBlox/HaxHell"
List.lb.Loading.Text = "กำลังโหลด"
List.lb.Wait.Text = "กำลังเริ่ม ExperienceSettings กรุณารอสักครู่..."

-- ProfileStatus
List.pfs.InsideProfileStatus.ProfileCharacter.Scroll.Beta.Text = "อาจมีบั๊ก และยังอยู่ในช่วงเบต้า"
List.pfs.InsideProfileStatus.ProfileCharacter.Scroll.DeveloperConsole.Text = "เปิดคอนโซลนักพัฒนา"
List.pfs.InsideProfileStatus.ProfileCharacter.Scroll.DropTool.Text = "ทิ้งเครื่องมือ"
List.pfs.InsideProfileStatus.ProfileCharacter.Scroll.DropTools.Text = "ทิ้งเครื่องมือทั้งหมด"

-- Search
List.sh.SearchBar.Searcher.PlaceholderText = "[ เลือกก่อน ] ตัวค้นหา"

end

local CurrentLanguage = "EN"

local function RefreshLanguageButtons()

    EngBtn.TextColor3 =
        CurrentLanguage == "EN"
        and Color3.fromRGB(0,255,0)
        or Color3.fromRGB(255,255,255)

    SpaBtn.TextColor3 =
        CurrentLanguage == "ES"
        and Color3.fromRGB(0,255,0)
        or Color3.fromRGB(255,255,255)

    ThaBtn.TextColor3 =
        CurrentLanguage == "TH"
        and Color3.fromRGB(0,255,0)
        or Color3.fromRGB(255,255,255)

end

local EngBtn = Txt(
    "English",
    255,255,255,
    false,nil,
    true,"Select",
    nil,
    function(_, btn)
        CurrentLanguage = "EN"
        Eng()
        RefreshLanguageButtons()
    end,
    nil,
    ins2
).Button

local SpaBtn = Txt(
    "Español",
    255,255,255,
    false,nil,
    true,"Seleccionar",
    nil,
    function(_, btn)
        CurrentLanguage = "ES"
        Spa()
        RefreshLanguageButtons()
    end,
    nil,
    ins2
).Button

local ThaBtn = Txt(
    "ไทย",
    255,255,255,
    false,nil,
    true,"เลือก",
    nil,
    function(_, btn)
        CurrentLanguage = "TH"
        Tha()
        RefreshLanguageButtons()
    end,
    nil,
    ins2
).Button



































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

print[[------------------------------------------------------------
[ Settings - Loader Rejoiner ] Successful loaded.

>> for Information
  - Continue loadstring = Load ExperienceSettings
  - Always Load = Auto load ExperienceSettings
  - Custom Background (R,G,B) = Custom ExperienceSettings Background
  - FoundHumanoidRootPart: State = If there HumanoidRootPart or not
  - Hide ExperienceSettings = Hide TopBar and another frames
  - Settings Transparency = Set Transparency this Settings - Loader Rejoiner 
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
