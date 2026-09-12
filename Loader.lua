-- Loader script 3.4

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

local SoundState = false
local PainSoundId = "rbxassetid://126351915401997"

local painui


local function UpdatePainSound(state)

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



painui = Txt(
    "Pain Sound (DamageOverlay)",
    255,255,255,

    false,nil,

    true,nil,

    nil,

    function(state)
        UpdatePainSound(state)
    end,

    SoundState,

    ins
)



local function WatchPainSound(char)

    local hrp = char:WaitForChild("HumanoidRootPart")


    -- If PainNoise already exists
    task.spawn(function()
        local sound = hrp:WaitForChild("PainNoise", 5)

        if sound then
            UpdatePainSound(SoundState)
        end
    end)


    -- If PainNoise appears later
    hrp.ChildAdded:Connect(function(child)

        if child.Name == "PainNoise" and child:IsA("Sound") then

            task.wait()

            UpdatePainSound(SoundState)

        end

    end)

end



-- First spawn
if player.Character then
    WatchPainSound(player.Character)
end


-- Respawn
player.CharacterAdded:Connect(function(char)

    WatchPainSound(char)

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
--// TEXT-DETECTION LOCALIZATION ENGINE v1
--// No Path-based translation.
--// =====================================================

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local ExperienceSettings

local CurrentLanguage = "EN"
local latestClick = "EN"
local TranslationBusy = false
local TranslationCooldown = 2
local LastApiRequest = 0

local TranslationCacheFile =
    "ExperienceSettings/translation_cache.json"

-- Translation providers
-- LibreTranslate is optional. When it is not configured, the engine
-- falls back to Google Translate's public web translation endpoint.
local LIBRETRANSLATE_URL = nil
local LIBRETRANSLATE_API_KEY = nil
local GOOGLE_TRANSLATE_URL = "https://translate.googleapis.com/translate_a/single"
local REMOTE_CACHE_URL = nil

local LibreTranslateTarget = {
    ES = "es",
    TH = "th",
    ["PT-BR"] = "pt",
    ["PT-PT"] = "pt",
    RU = "ru",
    KO = "ko"
}

local HTTP_REQUEST =
    request
    or http_request
    or (syn and syn.request)

local LanguageButtons = {}
local RefreshLanguageButtons

local TranslationSource =
    setmetatable({}, {__mode = "k"})

local TranslationApplied =
    setmetatable({}, {__mode = "k"})

local TranslationConnections =
    setmetatable({}, {__mode = "k"})

local TranslationCache = {
    ["EN"] = {},
    ["ES"] = {},
    ["TH"] = {},
    ["PT-BR"] = {},
    ["PT-PT"] = {},
    ["RU"] = {},
    ["KO"] = {},
}

local TranslationDB = {
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
        ["Close fuc#king annoying load bar"] = "Cerrar barra de carga molesta",
        ["Creator by @5teve3019D on ScriptBlox/HaxHell"] = "Creador por @5teve3019D en ScriptBlox/HaxHell",
        ["Loading"] = "Cargando",
        ["Starting ExperienceSettings. Please wait..."] = "Iniciando ExperienceSettings. Por favor espera...",
        ["It might have bug and it still in beta."] = "Podría tener errores y todavía está en beta.",
        ["Open Developer console"] = "Abrir consola de desarrollador",
        ["Drop Tool"] = "Soltar herramienta",
        ["Drop all tools"] = "Soltar todas las herramientas",
        ["[ Select first ] Searcher"] = "[ Selecciona primero ] Buscador",
    },
    ["TH"] = {
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
        ["Close fuc#king annoying load bar"] = "ปิดแถบโหลดน่ารำคาญ",
        ["Creator by @5teve3019D on ScriptBlox/HaxHell"] = "ผู้สร้างโดย @5teve3019D บน ScriptBlox/HaxHell",
        ["Loading"] = "กำลังโหลด",
        ["Starting ExperienceSettings. Please wait..."] = "กำลังเริ่ม ExperienceSettings กรุณารอสักครู่...",
        ["It might have bug and it still in beta."] = "อาจมีบั๊ก และยังอยู่ในช่วงเบต้า",
        ["Open Developer console"] = "เปิดคอนโซลนักพัฒนา",
        ["Drop Tool"] = "ทิ้งเครื่องมือ",
        ["Drop all tools"] = "ทิ้งเครื่องมือทั้งหมด",
        ["[ Select first ] Searcher"] = "[ เลือกก่อน ] ตัวค้นหา",
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
        ["Close fuc#king annoying load bar"] = "Fechar a barra de carregamento irritante",
        ["Creator by @5teve3019D on ScriptBlox/HaxHell"] = "Criado por @5teve3019D no ScriptBlox/HaxHell",
        ["Loading"] = "Carregando",
        ["Starting ExperienceSettings. Please wait..."] = "Iniciando o ExperienceSettings. Aguarde...",
        ["It might have bug and it still in beta."] = "Pode ter bugs e ainda está em beta.",
        ["Open Developer console"] = "Abrir console de desenvolvedor",
        ["Drop Tool"] = "Dropar ferramenta",
        ["Drop all tools"] = "Dropar todas as ferramentas",
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
        ["Close fuc#king annoying load bar"] = "Fechar a barra de carregamento irritante",
        ["Creator by @5teve3019D on ScriptBlox/HaxHell"] = "Criado por @5teve3019D no ScriptBlox/HaxHell",
        ["Loading"] = "A carregar",
        ["Starting ExperienceSettings. Please wait..."] = "A iniciar o ExperienceSettings. Aguarda...",
        ["It might have bug and it still in beta."] = "Pode ter bugs e ainda está em beta.",
        ["Open Developer console"] = "Abrir consola de desenvolvedor",
        ["Drop Tool"] = "Largar ferramenta",
        ["Drop all tools"] = "Largar todas as ferramentas",
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
        ["Close fuc#king annoying load bar"] = "Закрыть бесящую полосу загрузки",
        ["Creator by @5teve3019D on ScriptBlox/HaxHell"] = "Создатель: @5teve3019D на ScriptBlox/HaxHell",
        ["Loading"] = "Загрузка",
        ["Starting ExperienceSettings. Please wait..."] = "Запуск ExperienceSettings. Пожалуйста, подожди...",
        ["It might have bug and it still in beta."] = "Возможны баги, и это всё ещё beta.",
        ["Open Developer console"] = "Открыть консоль разработчика",
        ["Drop Tool"] = "Выбросить предмет",
        ["Drop all tools"] = "Выбросить все предметы",
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
        ["Close fuc#king annoying load bar"] = "짜증나는 로딩 바 닫기",
        ["Creator by @5teve3019D on ScriptBlox/HaxHell"] = "ScriptBlox/HaxHell의 @5teve3019D 제작",
        ["Loading"] = "로딩 중",
        ["Starting ExperienceSettings. Please wait..."] = "ExperienceSettings를 시작하는 중입니다. 잠시만 기다려 주세요...",
        ["It might have bug and it still in beta."] = "버그가 있을 수 있으며 아직 베타 상태입니다.",
        ["Open Developer console"] = "개발자 콘솔 열기",
        ["Drop Tool"] = "도구 버리기",
        ["Drop all tools"] = "모든 도구 버리기",
        ["[ Select first ] Searcher"] = "[ 먼저 선택 ] 검색",
    },
}

-- Import the old translations into the new text-key cache.
for language, entries in pairs(TranslationDB) do
    for sourceText, translatedText in pairs(entries) do
        TranslationCache[language][sourceText] = translatedText
    end
end

local function IsTranslationSkipped(obj)
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

local function SaveTranslationCache()
    if not writefile then
        return false
    end

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode({
            Version = 1,
            Languages = TranslationCache
        })
    end)

    if not ok then
        return false
    end

    local saveOk = pcall(function()
        if not isfolder("ExperienceSettings") then
            makefolder("ExperienceSettings")
        end

        writefile(TranslationCacheFile, encoded)
    end)

    return saveOk
end

local function LoadTranslationCache()
    if not readfile
        or not isfile
        or not isfile(TranslationCacheFile) then
        return
    end

    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(TranslationCacheFile))
    end)

    if not ok
        or type(decoded) ~= "table"
        or type(decoded.Languages) ~= "table" then
        return
    end

    for language, entries in pairs(decoded.Languages) do
        if TranslationCache[language]
            and type(entries) == "table" then

            for sourceText, translatedText in pairs(entries) do
                if type(sourceText) == "string"
                    and type(translatedText) == "string" then

                    TranslationCache[language][sourceText] =
                        translatedText
                end
            end
        end
    end
end

LoadTranslationCache()

-- Protect only the dynamic parts.
-- Example:
--   "Health: 100" -> "Health: __DYNAMIC_1__"
local function SelectTextToTranslateOnly(text)
    local source = tostring(text or "")
    local protected = {}
    local counter = 0

    local function protect(value)
        counter += 1
        protected[counter] = value
        return string.format("__DYNAMIC_%d__", counter)
    end

    source = source:gsub("<[^>]->", function(tag)
        return protect(tag)
    end)

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

local function RestoreSelectedText(text, protected)
    local result = tostring(text or "")

    for index = #protected, 1, -1 do
        local token = string.format("__DYNAMIC_%d__", index)

        result = result:gsub(token, function()
            return protected[index]
        end)
    end

    return result
end

local function WaitForApiSlot()
    local remaining =
        TranslationCooldown
        - (os.clock() - LastApiRequest)

    if remaining > 0 then
        task.wait(remaining)
    end
end

local function UrlEncode(value)
    local ok, result = pcall(function()
        return HttpService:UrlEncode(tostring(value or ""))
    end)

    if ok and result then
        return result
    end

    return tostring(value or "")
        :gsub("([^%w%-_%.~])", function(char)
            return string.format("%%%02X", string.byte(char))
        end)
end

local function RequestHttp(options)
    if HTTP_REQUEST then
        local ok, response = pcall(function()
            return HTTP_REQUEST(options)
        end)

        if ok and type(response) == "table" then
            return response
        end
    end

    if options.Method == "GET" and game and game.HttpGet and options.Url then
        local ok, body = pcall(function()
            return game:HttpGet(options.Url)
        end)

        if ok and type(body) == "string" then
            return {
                StatusCode = 200,
                Body = body,
            }
        end
    end

    return nil
end

local function ParseGoogleTranslation(body)
    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(body)
    end)

    if not ok or type(decoded) ~= "table" or type(decoded[1]) ~= "table" then
        return nil
    end

    local output = {}

    for _, part in ipairs(decoded[1]) do
        if type(part) == "table"
            and type(part[1]) == "string" then
            output[#output + 1] = part[1]
        end
    end

    local result = table.concat(output)
    if result == "" then
        return nil
    end

    return result
end

local function RequestGoogleTranslation(template, language)
    local target = LibreTranslateTarget[language] or language
    local encoded = UrlEncode(template)

    local url = GOOGLE_TRANSLATE_URL
        .. "?client=gtx&sl=en&tl="
        .. UrlEncode(target)
        .. "&dt=t&q="
        .. encoded

    local response = RequestHttp({
        Url = url,
        Method = "GET",
        Headers = {
            ["Accept"] = "application/json"
        }
    })

    if type(response) ~= "table" then
        return nil
    end

    local body = response.Body or response.body
    if type(body) ~= "string" then
        return nil
    end

    return ParseGoogleTranslation(body)
end

local function RequestTranslation(template, language)
    if not template or template == "" then
        return nil
    end

    WaitForApiSlot()
    LastApiRequest = os.clock()

    -- 1) LibreTranslate if explicitly configured.
    if HTTP_REQUEST and LIBRETRANSLATE_URL then
        local payload = {
            q = template,
            source = "en",
            target = LibreTranslateTarget[language] or language,
            format = "text"
        }

        if LIBRETRANSLATE_API_KEY then
            payload.api_key = LIBRETRANSLATE_API_KEY
        end

        local ok, response = pcall(function()
            return HTTP_REQUEST({
                Url = LIBRETRANSLATE_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(payload)
            })
        end)

        if ok and type(response) == "table" then
            local responseBody = response.Body or response.body

            if type(responseBody) == "string" then
                local decodeOk, decoded = pcall(function()
                    return HttpService:JSONDecode(responseBody)
                end)

                if decodeOk
                    and type(decoded) == "table"
                    and type(decoded.translatedText) == "string"
                    and decoded.translatedText ~= "" then
                    return decoded.translatedText
                end
            end
        end
    end

    -- 2) Public fallback so missing TranslationDB entries can still translate.
    return RequestGoogleTranslation(template, language)
end

local function MergeRemoteCache(decoded)
    if type(decoded) ~= "table" then
        return
    end

    local languages = decoded.Languages or decoded

    if type(languages) ~= "table" then
        return
    end

    for language, entries in pairs(languages) do
        if TranslationCache[language]
            and type(entries) == "table" then

            for sourceText, translatedText in pairs(entries) do
                if type(sourceText) == "string"
                    and type(translatedText) == "string" then

                    TranslationCache[language][sourceText] =
                        translatedText
                end
            end
        end
    end
end

local function PullRemoteCache()
    if not HTTP_REQUEST or not REMOTE_CACHE_URL then
        return
    end

    pcall(function()
        local response = HTTP_REQUEST({
            Url = REMOTE_CACHE_URL,
            Method = "GET"
        })

        local body = response and
            (response.Body or response.body)

        if type(body) ~= "string" then
            return
        end

        local ok, decoded =
            pcall(function()
                return HttpService:JSONDecode(body)
            end)

        if ok then
            MergeRemoteCache(decoded)
        end
    end)
end

local function PushRemoteCache()
    if not HTTP_REQUEST or not REMOTE_CACHE_URL then
        return
    end

    pcall(function()
        HTTP_REQUEST({
            Url = REMOTE_CACHE_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({
                Version = 1,
                Languages = TranslationCache
            })
        })
    end)
end

local function GetCachedTranslation(sourceText, language)
    if language == "EN" then
        return sourceText
    end

    local exact =
        TranslationCache[language][sourceText]

    if exact then
        return exact
    end

    local template, protected =
        SelectTextToTranslateOnly(sourceText)

    local cachedTemplate =
        TranslationCache[language][template]

    if cachedTemplate then
        return RestoreSelectedText(
            cachedTemplate,
            protected
        )
    end

    return nil, template, protected
end

local TranslationState =
    setmetatable({}, {__mode = "k"})

local function EscapeLuaPattern(value)
    return tostring(value or ""):gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
end

-- Match the current text against a permanent/dynamic template.
-- Example:
--   "Health: __DYNAMIC_1__"
--   "Health: 100"
-- -> { [1] = "100" }
local function MatchDynamicTemplate(template, text)
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
                patternParts[#patternParts + 1] =
                    EscapeLuaPattern(tail)
            end

            break
        end

        local permanent = template:sub(cursor, startPos - 1)

        if permanent ~= "" then
            patternParts[#patternParts + 1] =
                EscapeLuaPattern(permanent)
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
        return nil
    end

    if #captures ~= #dynamicOrder then
        return nil
    end

    local values = {}

    for i = 1, #dynamicOrder do
        values[dynamicOrder[i]] = captures[i]
    end

    return values
end

local function GetState(obj, property)
    TranslationState[obj] =
        TranslationState[obj] or {}

    TranslationState[obj][property] =
        TranslationState[obj][property] or {}

    return TranslationState[obj][property]
end

local function BuildSourceState(obj, property, sourceText)
    local state =
        GetState(obj, property)

    local template, protected =
        SelectTextToTranslateOnly(sourceText)

    state.SourceTemplate = template
    state.DynamicValues = protected
    state.SourceText =
        RestoreSelectedText(
            template,
            protected
        )

    return state
end

local function GetStateTranslation(state, language)
    if not state
        or not state.SourceTemplate
        or state.SourceTemplate == "" then
        return nil
    end

    if language == "EN" then
        return RestoreSelectedText(
            state.SourceTemplate,
            state.DynamicValues or {}
        )
    end

    local translatedTemplate =
        TranslationCache[language]
        and TranslationCache[language][state.SourceTemplate]

    if not translatedTemplate then
        return nil
    end

    return RestoreSelectedText(
        translatedTemplate,
        state.DynamicValues or {}
    )
end

local function ApplyStateToObject(obj, property, language)
    if not obj
        or not obj.Parent
        or IsTranslationSkipped(obj) then
        return false
    end

    local state =
        TranslationState[obj]
        and TranslationState[obj][property]

    if not state then
        return false
    end

    local rendered =
        GetStateTranslation(
            state,
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

    TranslationApplied[obj] =
        TranslationApplied[obj] or {}

    TranslationApplied[obj][property] =
        rendered

    obj[property] = rendered
    return true
end

local function UpdateDynamicState(obj, property, currentValue)
    local state =
        TranslationState[obj]
        and TranslationState[obj][property]

    if not state then
        return false
    end

    -- 1. The GUI changed only its dynamic part while
    --    already translated. Match against the translated template.
    if CurrentLanguage ~= "EN" then
        local translatedTemplate =
            TranslationCache[CurrentLanguage]
            and TranslationCache[CurrentLanguage][state.SourceTemplate]

        if translatedTemplate then
            local translatedDynamic =
                MatchDynamicTemplate(
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
        MatchDynamicTemplate(
            state.SourceTemplate,
            currentValue
        )

    if sourceDynamic then
        state.DynamicValues =
            sourceDynamic

        state.SourceText =
            RestoreSelectedText(
                state.SourceTemplate,
                sourceDynamic
            )

        return true
    end

    return false
end

local function BindProperty(obj, property)
    if not obj
        or not obj.Parent
        or IsTranslationSkipped(obj) then
        return
    end

    TranslationSource[obj] =
        TranslationSource[obj] or {}

    TranslationApplied[obj] =
        TranslationApplied[obj] or {}

    TranslationConnections[obj] =
        TranslationConnections[obj] or {}

    if TranslationConnections[obj][property] then
        return
    end

    if property == "Text"
        and obj:IsA("TextBox")
        and obj.TextEditable then
        return
    end

    local currentValue =
        tostring(obj[property] or "")

    local state =
        BuildSourceState(
            obj,
            property,
            currentValue
        )

    TranslationSource[obj][property] =
        state.SourceText

    TranslationApplied[obj][property] =
        currentValue

    TranslationConnections[obj][property] =
        obj:GetPropertyChangedSignal(property):Connect(function()
            local changedValue =
                tostring(obj[property] or "")

            local applied =
                TranslationApplied[obj]
                and TranslationApplied[obj][property]

            -- Ignore our own translated write.
            if applied == changedValue then
                return
            end

            if property == "Text"
                and obj:IsA("TextBox")
                and obj.TextEditable then
                return
            end

            -- English is always the canonical source.
            if CurrentLanguage == "EN" then
                local newState =
                    BuildSourceState(
                        obj,
                        property,
                        changedValue
                    )

                TranslationSource[obj][property] =
                    newState.SourceText

                TranslationApplied[obj][property] =
                    changedValue

                return
            end

            -- Most changes are only dynamic values.
            -- Keep the already-translated permanent text.
            if UpdateDynamicState(
                obj,
                property,
                changedValue
            ) then
                local rendered =
                    GetStateTranslation(
                        TranslationState[obj][property],
                        CurrentLanguage
                    )

                if rendered then
                    TranslationApplied[obj][property] =
                        rendered

                    if rendered ~= changedValue then
                        obj[property] = rendered
                    end
                end

                return
            end

            -- A genuinely new permanent string appeared.
            -- Rebuild the source template instead of treating
            -- the previously translated text as English.
            local newState =
                BuildSourceState(
                    obj,
                    property,
                    changedValue
                )

            TranslationSource[obj][property] =
                newState.SourceText

            TranslationApplied[obj][property] =
                changedValue

            task.defer(function()
                if not obj.Parent
                    or TranslationBusy then
                    return
                end

                local language =
                    CurrentLanguage

                if language == "EN" then
                    return
                end

                local template =
                    newState.SourceTemplate

                if template == "" then
                    return
                end

                local cached =
                    TranslationCache[language]
                    and TranslationCache[language][template]

                if cached then
                    ApplyStateToObject(
                        obj,
                        property,
                        language
                    )
                    return
                end

                local apiTranslation =
                    RequestTranslation(
                        template,
                        language
                    )

                if not apiTranslation then
                    return
                end

                TranslationCache[language][template] =
                    apiTranslation

                ApplyStateToObject(
                    obj,
                    property,
                    language
                )

                SaveTranslationCache()
                PushRemoteCache()
            end)
        end)
end

local function BindTextBoxEditable(obj)
    if not obj:IsA("TextBox")
        or not obj.Parent then
        return
    end

    TranslationConnections[obj] =
        TranslationConnections[obj] or {}

    if TranslationConnections[obj]._TextEditable then
        return
    end

    TranslationConnections[obj]._TextEditable =
        obj:GetPropertyChangedSignal("TextEditable"):Connect(function()
            if obj.TextEditable then
                if TranslationSource[obj] then
                    TranslationSource[obj].Text = nil
                end

                if TranslationApplied[obj] then
                    TranslationApplied[obj].Text = nil
                end

                if TranslationState[obj] then
                    TranslationState[obj].Text = nil
                end

                return
            end

            BindProperty(obj, "Text")
        end)
end

local function ScanInstance(obj)
    if not obj
        or IsTranslationSkipped(obj) then
        return
    end

    if obj:IsA("TextLabel")
        or obj:IsA("TextButton") then

        BindProperty(obj, "Text")

    elseif obj:IsA("TextBox") then

        BindProperty(
            obj,
            "PlaceholderText"
        )

        BindTextBoxEditable(obj)

        if not obj.TextEditable then
            BindProperty(obj, "Text")
        end
    end

    -- Recursive traversal through ALL child instances.
    for _, child in ipairs(obj:GetChildren()) do
        ScanInstance(child)
    end
end

local function ApplyCachedLanguage(language)
    CurrentLanguage = language

    for obj, properties in pairs(TranslationState) do
        if obj
            and obj.Parent
            and not IsTranslationSkipped(obj) then

            for property, state in pairs(properties) do
                if property == "Text"
                    and obj:IsA("TextBox")
                    and obj.TextEditable then
                    continue
                end

                local rendered =
                    GetStateTranslation(
                        state,
                        language
                    )

                if rendered then
                    TranslationApplied[obj] =
                        TranslationApplied[obj] or {}

                    TranslationApplied[obj][property] =
                        rendered

                    obj[property] = rendered

                    TranslationSource[obj] =
                        TranslationSource[obj] or {}

                    TranslationSource[obj][property] =
                        state.SourceText
                end
            end
        end
    end
end

local function SetPermanentTranslationSource(
    obj,
    property,
    sourceText
)
    local state =
        BuildSourceState(
            obj,
            property,
            sourceText
        )

    TranslationSource[obj] =
        TranslationSource[obj] or {}

    TranslationSource[obj][property] =
        state.SourceText
end

local SetLanguageButtonsLocked

local function ChangeLanguage(language)
    if not ExperienceSettings then
        return
    end

    if TranslationBusy then
        return
    end

    -- Same language = zero work, zero API calls.
    if latestClick == language then
        return
    end

    latestClick = language
    TranslationBusy = true

    SetLanguageButtonsLocked(true)

    task.spawn(function()
        PullRemoteCache()

        -- Re-scan in case the game created new GUI elements.
        ScanInstance(ExperienceSettings)

        if language == "EN" then
            ApplyCachedLanguage("EN")

            TranslationBusy = false
            SetLanguageButtonsLocked(false)
            RefreshLanguageButtons()
            return
        end

        -- Instant local/remote cache pass first.
        ApplyCachedLanguage(language)

        -- Find unique uncached permanent templates.
        local pending = {}
        local pendingSeen = {}

        for obj, properties in pairs(TranslationState) do
            if obj
                and obj.Parent
                and not IsTranslationSkipped(obj) then

                for property, state in pairs(properties) do
                    if property == "Text"
                        and obj:IsA("TextBox")
                        and obj.TextEditable then
                        continue
                    end

                    local template =
                        state.SourceTemplate

                    if template
                        and template ~= ""
                        and not (
                            TranslationCache[language]
                            and TranslationCache[language][template]
                        )
                        and not pendingSeen[template] then

                        pendingSeen[template] =
                            true

                        pending[#pending + 1] =
                            template
                    end
                end
            end
        end

        -- API calls are serialized and rate-limited.
        for _, template in ipairs(pending) do
            local apiTranslation =
                RequestTranslation(
                    template,
                    language
                )

            if apiTranslation then
                TranslationCache[language][template] =
                    apiTranslation
            end
        end

        SaveTranslationCache()
        PushRemoteCache()

        -- Apply anything added by the API pass.
        ApplyCachedLanguage(language)

        TranslationBusy = false
        SetLanguageButtonsLocked(false)
        RefreshLanguageButtons()
    end)
end

SetLanguageButtonsLocked = function(locked)
    for _, button in pairs(LanguageButtons) do
        if button and button.Parent then
            button.Active = not locked
            button.AutoButtonColor = not locked
        end
    end
end

-- Never translate the language selector itself.
ins2:SetAttribute("SkipAutoTranslate", true)

-- ExperienceSettings may be created/moved into CoreGui later.
-- Wait for it in a separate thread so the rest of Loader.lua keeps running.
task.spawn(function()
    ExperienceSettings = CoreGui:WaitForChild("ExperienceSettings")

    -- Initial scan. No Paths are used.
    ScanInstance(ExperienceSettings)

    -- New GUI objects are picked up automatically.
    ExperienceSettings.DescendantAdded:Connect(function(obj)
        task.defer(function()
            if not obj
                or not obj.Parent
                or IsTranslationSkipped(obj) then
                return
            end

            ScanInstance(obj)

            if CurrentLanguage ~= "EN" then
                ApplyCachedLanguage(CurrentLanguage)
            end
        end)
    end)
end)

local EngBtn = Txt(
    "🇺🇸 English",
    255,255,255,
    false,nil,
    true,"Select",
    nil,
    function()
        ChangeLanguage("EN")
    end,
    nil,
    ins2
).Button

local SpaBtn = Txt(
    "🇪🇸 Español",
    255,255,255,
    false,nil,
    true,"Select",
    nil,
    function()
        ChangeLanguage("ES")
    end,
    nil,
    ins2
).Button

local ThaBtn = Txt(
    "🇹🇭 ไทย",
    255,255,255,
    false,nil,
    true,"เลือก",
    nil,
    function()
        ChangeLanguage("TH")
    end,
    nil,
    ins2
).Button

local BraBtn = Txt(
    "🇧🇷 Português (Brasil)",
    255,255,255,
    false,nil,
    true,"Selecionar",
    nil,
    function()
        ChangeLanguage("PT-BR")
    end,
    nil,
    ins2
).Button

local PorBtn = Txt(
    "🇵🇹 Português (Portugal)",
    255,255,255,
    false,nil,
    true,"Selecionar",
    nil,
    function()
        ChangeLanguage("PT-PT")
    end,
    nil,
    ins2
).Button

local RusBtn = Txt(
    "🇷🇺 Русский",
    255,255,255,
    false,nil,
    true,"Выбрать",
    nil,
    function()
        ChangeLanguage("RU")
    end,
    nil,
    ins2
).Button

local KorBtn = Txt(
    "🇰🇷 한국어 (대한민국)",
    255,255,255,
    false,nil,
    true,"선택",
    nil,
    function()
        ChangeLanguage("KO")
    end,
    nil,
    ins2
).Button

LanguageButtons = {
    EN = EngBtn,
    ES = SpaBtn,
    TH = ThaBtn,
    ["PT-BR"] = BraBtn,
    ["PT-PT"] = PorBtn,
    RU = RusBtn,
    KO = KorBtn
}

RefreshLanguageButtons = function()
    if not (
        EngBtn
        and SpaBtn
        and ThaBtn
        and BraBtn
        and PorBtn
        and RusBtn
        and KorBtn
    ) then
        return
    end

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

    BraBtn.TextColor3 =
        CurrentLanguage == "PT-BR"
        and Color3.fromRGB(0,255,0)
        or Color3.fromRGB(255,255,255)

    PorBtn.TextColor3 =
        CurrentLanguage == "PT-PT"
        and Color3.fromRGB(0,255,0)
        or Color3.fromRGB(255,255,255)

    RusBtn.TextColor3 =
        CurrentLanguage == "RU"
        and Color3.fromRGB(0,255,0)
        or Color3.fromRGB(255,255,255)

    KorBtn.TextColor3 =
        CurrentLanguage == "KO"
        and Color3.fromRGB(0,255,0)
        or Color3.fromRGB(255,255,255)
end

RefreshLanguageButtons()

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
