-- Loader script 4.3

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
--// TEXT-DETECTION LOCALIZATION ENGINE v2
--// No Path-based translation.
--// =====================================================

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalizationService = game:GetService("LocalizationService")

local ExperienceSettings

local CurrentLanguage = "EN"
local SelectedLanguage = "EN"
local latestClick = "EN"
local TranslationBusy = false
local TranslationCooldown = 2
local LastApiRequest = 0

local TranslationCacheFile =
    "ExperienceSettings/translation_cache.json"

-- Roblox LocalizationService is the primary translation provider.
-- Local TranslationDB/cache remains as a fallback.
local REMOTE_CACHE_URL = nil


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

local LocaleMap = {
    ["EN"] = "en-us",
    ["ES"] = "es",
    ["TH"] = "th",
    ["PT-BR"] = "pt-br",
    ["PT-PT"] = "pt-pt",
    ["RU"] = "ru",
    ["KO"] = "ko",
}

local LocalizationTranslators = {}
local LocalizationReady = {}
local LocalizationLookupCache = {}
local SimilarSourceCache = {}
local SimilarCandidateIndex = {}
local SimilarCandidateList = {}

local LocalizationSourceCandidates = {
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
    "Relax / Gif Animation Predictor",
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
    "<font size='12'><b>Zero Point Instant Steal & more</b></font> Steal An Egg By @API Not supported Click 'View' for more details.",
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
    "The ExperienceSettings has been deactivated for some reason.",
    "Copy",
    "Execute",
    "<b>Don't show this again</b>",
    "<b>Remind Me Later</b>",
    "<b><font size=\"12\">Happy 1st Anniversary of The ExperienceSettings!</font></b> We want to let you know for those who using our script; we want to say <b>thank you for using our script!</b>    To close this <b>GUI</b> you can simply click <b><font size=\"9\">\"Remind me later.\"</font></b> or <b><font size=\"9\">\"Dont show this again.\"</font></b> button to continue use The ExperienceSettings.",
    "re-chat",
    "Ask anything..."
}

local function NormalizeSimilarityText(text)
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

local function SimilarityTextWithoutRichText(text)
    return NormalizeSimilarityText(tostring(text or ""):gsub("<[^>]->", ""))
end

local function AddSimilarityCandidate(candidate)
    candidate = tostring(candidate or "")
    if candidate == "" or SimilarCandidateIndex[candidate] then
        return
    end

    local normalized = NormalizeSimilarityText(candidate)
    local plain = SimilarityTextWithoutRichText(candidate)

    local item = {
        Source = candidate,
        Normalized = normalized,
        Plain = plain,
        Length = #normalized,
    }

    SimilarCandidateIndex[candidate] = item
    SimilarCandidateList[#SimilarCandidateList + 1] = item

    if normalized ~= "" then
        SimilarCandidateIndex["N:" .. normalized] = item
    end

    if plain ~= "" and plain ~= normalized then
        SimilarCandidateIndex["P:" .. plain] = item
    end
end

local function BuildSimilarityCandidateIndex()
    table.clear(SimilarCandidateIndex)
    table.clear(SimilarCandidateList)

    for _, candidate in ipairs(LocalizationSourceCandidates or {}) do
        AddSimilarityCandidate(candidate)
    end

    for _, entries in pairs(TranslationDB) do
        for candidate in pairs(entries) do
            AddSimilarityCandidate(candidate)
        end
    end
end

BuildSimilarityCandidateIndex()

local function FindSimilarLocalizationSource(sourceText)
    local source = tostring(sourceText or "")
    if source == "" then
        return nil
    end

    local cached = SimilarSourceCache[source]
    if cached ~= nil then
        return cached.Resolved
    end

    local normalized = NormalizeSimilarityText(source)
    local plainNormalized = SimilarityTextWithoutRichText(source)

    -- O(1) normalized lookups first.
    local exactNormalized = SimilarCandidateIndex["N:" .. normalized]
    if exactNormalized then
        SimilarSourceCache[source] = {
            Resolved = exactNormalized.Source,
            Score = 1,
        }
        return exactNormalized.Source
    end

    local exactPlain = SimilarCandidateIndex["P:" .. plainNormalized]
    if exactPlain then
        SimilarSourceCache[source] = {
            Resolved = exactPlain.Source,
            Score = 1,
        }
        return exactPlain.Source
    end

    -- Fuzzy matching is intentionally only done once per unique source.
    local bestCandidate = nil
    local bestScore = 0
    local sourceLength = #normalized

    local function testCandidate(item)
        if item.Source == source then
            return
        end

        local maxLength = math.max(sourceLength, item.Length)
        local minLength = math.min(sourceLength, item.Length)
        local lengthRatio = minLength / math.max(1, maxLength)

        if lengthRatio < 0.72 then
            return
        end

        local scoreA = TokenSimilarity(normalized, item.Normalized)
        local scoreB = TokenSimilarity(plainNormalized, item.Plain)
        local scoreC = CommonPrefixRatio(normalized, item.Normalized)

        local score = math.max(scoreA, scoreB) * 0.75 + scoreC * 0.25

        if score > bestScore then
            bestScore = score
            bestCandidate = item.Source
        end
    end

    -- Cheap filtering before fuzzy work. This prevents comparing huge blocks
    -- against every candidate when their lengths are obviously unrelated.
    for _, item in ipairs(SimilarCandidateList) do
        testCandidate(item)
    end

    if bestCandidate and bestScore >= 0.92 then
        SimilarSourceCache[source] = {
            Resolved = bestCandidate,
            Score = bestScore,
        }
        return bestCandidate
    end

    -- Cache misses too, so the same untranslated string does not trigger
    -- another full similarity pass every 5 seconds.
    SimilarSourceCache[source] = {
        Resolved = false,
        Score = bestScore,
    }

    return nil
end

-- Import the static TranslationDB.
for language, entries in pairs(TranslationDB) do
    for sourceText, translatedText in pairs(entries) do
        TranslationCache[language][sourceText] = translatedText

        local plainKey = PlainCacheKey(sourceText)
        if plainKey ~= PlainCacheKey("") then
            TranslationCache[language][plainKey] = translatedText
        end
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

-- Normalize static DB entries so runtime dynamic values can match the same template.
for language, entries in pairs(TranslationDB) do
    for sourceText, translatedText in pairs(entries) do
        local template, protected = SelectTextToTranslateOnly(sourceText)
        if template ~= sourceText and not TranslationCache[language][template] then
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
            TranslationCache[language][template] = translatedTemplate
            TranslationCache[language][PlainCacheKey(template)] = translatedTemplate
        end
    end
end


local function GetLocalizationTranslator(language)
    if language == "EN" then
        return nil
    end

    local existing = LocalizationTranslators[language]
    if existing then
        return existing
    end

    local localeId = LocaleMap[language]
    if not localeId then
        return nil
    end

    local ok, translator = pcall(function()
        return LocalizationService:GetTranslatorForLocaleAsync(localeId)
    end)

    if ok and translator then
        LocalizationTranslators[language] = translator
        LocalizationReady[language] = true
        return translator
    end

    LocalizationReady[language] = false
    return nil
end

local function TranslateFromLocalization(obj, sourceText, language)
    if language == "EN" or not obj or sourceText == "" then
        return nil
    end

    LocalizationLookupCache[language] = LocalizationLookupCache[language] or {}
    local lookup = LocalizationLookupCache[language]

    local cached = lookup[sourceText]
    if cached ~= nil then
        return cached or nil
    end

    local translator = GetLocalizationTranslator(language)
    if not translator then
        lookup[sourceText] = false
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

        lookup[sourceText] = translated
        return translated
    end

    -- 1. Exact source.
    local translated = trySource(sourceText)
    if translated then
        return translated
    end

    -- 2. Equivalent whitespace source.
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
            return translated
        end
    end

    -- 3. Find the closest known canonical source.
    local similarSource =
        FindSimilarLocalizationSource(sourceText)

    if similarSource and similarSource ~= sourceText then
        translated = trySource(similarSource)
        if translated then
            return translated
        end
    end

    lookup[sourceText] = false
    return nil
end

local function GetCachedTranslation(sourceText, language)
    if language == "EN" then
        return sourceText
    end

    local cache = TranslationCache[language]
    if not cache then
        return nil
    end

    local exact = cache[sourceText]
    if exact then
        return exact
    end

    local plain = cache[PlainCacheKey(sourceText)]
    if plain then
        return plain
    end

    local template, protected =
        SelectTextToTranslateOnly(sourceText)

    local cachedTemplate = cache[template]
    if cachedTemplate then
        return RestoreSelectedText(cachedTemplate, protected)
    end

    local cachedPlainTemplate = cache[PlainCacheKey(template)]
    if cachedPlainTemplate then
        return RestoreSelectedText(cachedPlainTemplate, protected)
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
                patternParts[#patternParts + 1] = EscapeLuaPattern(tail)
            end
            break
        end

        local permanent = template:sub(cursor, startPos - 1)

        if permanent ~= "" then
            patternParts[#patternParts + 1] = EscapeLuaPattern(permanent)
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

local function GetStateTranslation(obj, state, property, language)
    if not state
        or not state.SourceTemplate
        or state.SourceTemplate == "" then
        return nil
    end

    local sourceRendered = RestoreSelectedText(
        state.SourceTemplate,
        state.DynamicValues or {}
    )

    if language == "EN" then
        return sourceRendered
    end

    local cache = TranslationCache[language]

    -- 1. Exact cached translation.
    local translated = cache and cache[sourceRendered]
    if translated then
        return translated
    end

    -- 2. Roblox LocalizationService / Localization Table.
    translated = TranslateFromLocalization(
        obj,
        sourceRendered,
        language
    )

    if translated then
        TranslationCache[language][sourceRendered] = translated
        TranslationCache[language][PlainCacheKey(sourceRendered)] = translated
        return translated
    end

    -- 3. Existing local TranslationDB/cache template fallback.
    translated = GetCachedTranslation(sourceRendered, language)
    if translated then
        return translated
    end

    local translatedTemplate = cache
        and (cache[state.SourceTemplate]
            or cache[PlainCacheKey(state.SourceTemplate)])

    if translatedTemplate then
        return RestoreSelectedText(
            translatedTemplate,
            state.DynamicValues or {}
        )
    end

    return nil
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
                        obj,
                        TranslationState[obj][property],
                        property,
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

                -- Local-only mode: do not request a translation provider here.
                -- If a translation is added to TranslationCache later, the next
                -- ApplyCachedLanguage() pass will render it.
                ApplyStateToObject(
                    obj,
                    property,
                    language
                )
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

    -- Full descendant scan: every child under this parent is visited.
    for _, child in ipairs(obj:GetDescendants()) do
        if not IsTranslationSkipped(child) then
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                BindProperty(child, "Text")
            elseif child:IsA("TextBox") then
                BindProperty(child, "PlaceholderText")
                BindTextBoxEditable(child)
                if not child.TextEditable then
                    BindProperty(child, "Text")
                end
            end
        end
    end
end

local function ApplyCachedLanguage(language)
    CurrentLanguage = language
    local processed = 0

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
                        obj,
                        state,
                        property,
                        language
                    )

                if rendered then
                    TranslationApplied[obj] =
                        TranslationApplied[obj] or {}

                    TranslationApplied[obj][property] =
                        rendered

                    if obj[property] ~= rendered then
                        obj[property] = rendered
                    end

                    processed += 1
                    if processed % 12 == 0 then
                        task.wait()
                    end

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
    SelectedLanguage = language
    RefreshLanguageButtons()
    TranslationBusy = true

    SetLanguageButtonsLocked(true)

    task.spawn(function()
        -- Load the Roblox LocalizationService translator for the selected locale.
        -- No external translation provider is used.
        if language ~= "EN" then
            GetLocalizationTranslator(language)
        end

        -- Re-scan in case the game created new GUI elements.
        ScanInstance(ExperienceSettings)

        if language == "EN" then
            ApplyCachedLanguage("EN")

            TranslationBusy = false
            SetLanguageButtonsLocked(false)
            SelectedLanguage = CurrentLanguage
            RefreshLanguageButtons()
            return
        end

        -- One non-blocking translation pass. Results are cached per source/locale.
        ApplyCachedLanguage(language)
        SaveTranslationCache()

        TranslationBusy = false
        SetLanguageButtonsLocked(false)
        SelectedLanguage = CurrentLanguage
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

            if CurrentLanguage ~= "EN" and not TranslationBusy then
                ApplyStateToObject(obj, "Text", CurrentLanguage)
                ApplyStateToObject(obj, "PlaceholderText", CurrentLanguage)
            end
        end)
    end)
end)

-- Full translation pass every 5 seconds for the currently selected language.
task.spawn(function()
    while task.wait(5) do
        if ExperienceSettings and ExperienceSettings.Parent then
            ScanInstance(ExperienceSettings)

            if CurrentLanguage ~= "EN" then
                GetLocalizationTranslator(CurrentLanguage)
            end

            if CurrentLanguage ~= "EN" and not TranslationBusy then
                ApplyCachedLanguage(CurrentLanguage)
            end

            RefreshLanguageButtons()
        end
    end
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
    for language, button in pairs(LanguageButtons) do
        if button and button.Parent then
            local selected = (SelectedLanguage == language)
            button.TextColor3 = selected
                and Color3.fromRGB(0,255,0)
                or Color3.fromRGB(255,255,255)
            button.BackgroundTransparency = selected and 0.15 or 1
        end
    end
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
