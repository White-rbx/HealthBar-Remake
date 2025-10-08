-- TweenHealth
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/loadstring/TweenHealth.lua"))()

-- ========= HEALTHBAR AND SOUNDS ===========
-- ใช้ใน LocalScript (client-side)
-- ปรับปรุงการตรวจสอบ nil เพื่อหลีกเลี่ยง "attempt to index nil with 'FindFirstChild'"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- ถ้า LocalPlayer ยังไม่พร้อม ให้รอ
if not player then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    player = Players.LocalPlayer
end

-- เป้าหมายใหม่ของตำแหน่ง HealthBar (ปรับได้)
local newHealthBarPosition = UDim2.new(0.874, 0, 0, 0)
local newHealthBarSize = UDim2.new(0.109, 0, 1, 0)
local newInnerBarSize = UDim2.new(1.85, 0, 0, 10)

-- helper: หาวัตถุ TopBarApp.HealthBar แบบปลอดภัย (returns instance or nil)
local function getHealthBarRoot()
    local topBar = CoreGui:FindFirstChild("TopBarApp")
    if not topBar then return nil end
    local innerTop = topBar:FindFirstChild("TopBarApp") or topBar
    if not innerTop then return nil end
    local unibar = innerTop:FindFirstChild("UnibarLeftFrame")
    if not unibar then return nil end
    local healthBar = unibar:FindFirstChild("HealthBar")
    return healthBar
end

-- ปรับตำแหน่ง HealthBar (loop ปกติแต่ปลอดภัย)
task.spawn(function()
    while true do
        pcall(function()
            local bar = getHealthBarRoot()
            if bar then
                -- ตรวจสอบก่อนตั้งค่าทุกครั้ง
                if bar and bar.Parent then
                    bar.Visible = true
                    -- try/catch แต่ pcall รอบนอกแล้ว
                    bar.Position = newHealthBarPosition
                    bar.Size = newHealthBarSize
                end

                local innerBar = bar:FindFirstChild("HealthBar")
                if innerBar then
                    innerBar.Visible = true
                    innerBar.Size = newInnerBarSize
                end
            end
        end)
        task.wait(0.1)
    end
end)

-- GUI แสดงค่า HP / Speed / FPS (สร้างในโฟลเดอร์ใต้ HealthBar)
local function setupValueGui()
    local healthBar = getHealthBarRoot()
    if not healthBar then return end

    local folder = healthBar:FindFirstChild("ValueFolder")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "ValueFolder"
        folder.Parent = healthBar
    end

    local gui = folder:FindFirstChild("ValueGui")
    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = "ValueGui"
        gui.Parent = folder
    end

    -- frame container (point)
    local fm = gui:FindFirstChild("point")
    if not fm then
        fm = Instance.new("Frame")
        fm.Name = "point"
        fm.Size = UDim2.new(0.955, 0, 0, 15)
        fm.Position = UDim2.new(0, 0, 0, -50)
        fm.BackgroundTransparency = 1
        fm.Parent = gui
    end

    -- UIListLayout inside fm (horizontal)
    local layo = fm:FindFirstChildOfClass("UIListLayout")
    if not layo then
        layo = Instance.new("UIListLayout")
        layo.FillDirection = Enum.FillDirection.Horizontal
        layo.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layo.Padding = UDim.new(0, 10)
        layo.Parent = fm
    end

    local function createLabel(name, size, strokeColor)
        -- label parent should be fm (container)
        local existing = fm:FindFirstChild(name)
        if existing and existing:IsA("TextLabel") then
            return existing
        end

        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.BackgroundTransparency = 0.3
        lbl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        lbl.Size = size or UDim2.new(0.1, 0, 1, 0)
        lbl.Position = UDim2.new(0, 0, 0, 0)
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.TextStrokeTransparency = 0
        lbl.TextStrokeColor3 = strokeColor or Color3.fromRGB(255,255,255)
        lbl.TextScaled = true
        lbl.Text = "[ ... ]"
        lbl.Parent = fm

        local stroke = Instance.new("UIStroke")
        stroke.Color = strokeColor or Color3.fromRGB(255,255,255)
        stroke.Thickness = 1.5
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = lbl

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = lbl

        return lbl
    end

    createLabel("HealthLabel", UDim2.new(0.1, 0, 1, 0), Color3.fromRGB(0,255,0))
    createLabel("SpeedLabel",  UDim2.new(0.1, 0, 1, 0), Color3.fromRGB(0,0,255))
    createLabel("FPSLabel",    UDim2.new(0.1, 0, 1, 0), Color3.fromRGB(255,0,0))
end

-- Gradient/Stroke Setup (guarded)
local fillGradient = nil
local strokeObj, strokeGradient = nil, nil

local function setupGradients()
    local healthBar = getHealthBarRoot()
    if not healthBar then return end

    local innerHealthBar = healthBar:FindFirstChild("HealthBar")
    local fill = innerHealthBar and innerHealthBar:FindFirstChild("Fill")
    if fill then
        fillGradient = fill:FindFirstChildOfClass("UIGradient")
        if not fillGradient then
            fillGradient = Instance.new("UIGradient")
            fillGradient.Name = "UIGradient"
            fillGradient.Rotation = 0
            fillGradient.Parent = fill
        end
    end

    if innerHealthBar then
        strokeObj = innerHealthBar:FindFirstChildOfClass("UIStroke")
        if not strokeObj then
            strokeObj = Instance.new("UIStroke")
            strokeObj.Name = "UIStroke"
            strokeObj.Parent = innerHealthBar
        end
        strokeObj.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        strokeObj.Color = Color3.fromRGB(255,255,255)
        strokeObj.Thickness = 0

        strokeGradient = strokeObj:FindFirstChildOfClass("UIGradient")
        if not strokeGradient then
            strokeGradient = Instance.new("UIGradient")
            strokeGradient.Name = "UIGradient"
            strokeGradient.Parent = strokeObj
        end
    end
end

-- utility strings -> number formatting
local function getHealthText(current)
    return string.format("%.3f", current or 0)
end

local function calculateSpeed(velocity)
    if not velocity then return "0.000" end
    return string.format("%.3f", velocity.Magnitude)
end

local fps = 60
local lastUpdate = tick()
local frameCount = 0
local function calculateFPS()
    frameCount = frameCount + 1
    local now = tick()
    local dt = now - lastUpdate
    if dt >= 0.5 then
        fps = math.floor(frameCount / dt + 0.5)
        frameCount = 0
        lastUpdate = now
    end
    return fps
end

-- อัปเดตทุกเฟรม (RenderStepped)
RunService.RenderStepped:Connect(function()
    local char = player and player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
    if not (hum and hrp) then return end

    -- สร้าง GUI/gradients หากยังไม่มี
    setupValueGui()
    setupGradients()

    local healthBar = getHealthBarRoot()
    if not healthBar then return end

    local folder = healthBar:FindFirstChild("ValueFolder")
    local gui = folder and folder:FindFirstChild("ValueGui")
    if not gui then return end

    local fm = gui:FindFirstChild("point")
    if not fm then return end

    local healthLabel = fm:FindFirstChild("HealthLabel")
    local speedLabel = fm:FindFirstChild("SpeedLabel")
    local fpsLabel   = fm:FindFirstChild("FPSLabel")

    local percent = 0
    if hum and hum.MaxHealth and hum.MaxHealth > 0 then
        percent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
    end

    -- use Color3.fromHSV directly
    local mainColor = Color3.fromHSV(percent * 0.33, 1, 1)
    local altColor = Color3.fromHSV(((percent * 0.33) - 0.08) % 1, 0.9, 1)

    if healthLabel and hum then
        pcall(function()
            healthLabel.Text = getHealthText(hum.Health) .. " HP"
            healthLabel.TextStrokeColor3 = mainColor
        end)
    end

    if speedLabel and hrp then
        pcall(function()
            speedLabel.Text = calculateSpeed(hrp.Velocity) .. " WS/s"
        end)
    end

    if fpsLabel then
        pcall(function() fpsLabel.Text = "FPS " .. tostring(calculateFPS()) end)
    end

    -- Update Fill Gradient safely
    if fillGradient then
        pcall(function()
            fillGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, altColor),
                ColorSequenceKeypoint.new(1, mainColor)
            })
        end)
    end

    if strokeObj and strokeGradient then
        pcall(function()
            strokeObj.Thickness = (1 - percent) * 4
            strokeGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, altColor),
                ColorSequenceKeypoint.new(1, mainColor)
            })
        end)
    end
end)

-- Image and sound pools (guarded usage)
local imageIds = {
    96532568222291, 87031182561721, 98399849016295,
    85810598205383, 78345061727777
}

local soundIds = {
    6445594239, 7772283448, 18900008907,
    17517499979, 6701126635, 127758670731005,
    100656590080703, 91213210724720, 9106880189,
    18437707128, 15022681798, 73807980472301,
    133843340754810, 4492455380, 134547185130980,
    6729922069, 6349641063, 80156405968805, 8449305114,
    17748195478, 154146535, 17620645740,
    5853668794, 8551016315, 7056720271,
    2661731024, 108277187006018, 17229758629,
    4910368846, 8626458303, 6345884580,
    74360230474567, 78781475442496, 17629583511,
    115036117519824, 9083355768, 108820459035129, 4067643809, 105101770611803,
    104496776279828, 6435400690, 17390851754,
    4643776975, 8481038804, 6435404036,
    8987546731, 101627462619966, 6435412998,
    132582860782653, 17593207303, 129111537687116,
    18908859228, 114739399228816, 577475178,
    100835951102315, 17673195487, 88282256294957,
}

-- helper: safely pick random element
local function safeRandomChoice(tbl)
    if type(tbl) ~= "table" or #tbl == 0 then return nil end
    return tbl[math.random(1, #tbl)]
end

-- find healthBarPath robustly (used for image UI)
local function findHealthBarPath()
    local top = CoreGui:FindFirstChild("TopBarApp")
    if not top then return nil end
    local inner = top:FindFirstChild("TopBarApp") or top
    return inner
end

local healthBarPath = findHealthBarPath()

local function createOrUpdateImage()
    -- try to refresh healthBarPath if nil
    if not healthBarPath then healthBarPath = findHealthBarPath() end
    if not healthBarPath then return end

    local healthBar = healthBarPath:FindFirstChild("UnibarLeftFrame", true)
    if not healthBar then return end

    local imageLabel = healthBar:FindFirstChild("ImageDeathRandomClient")
    if not imageLabel then
        imageLabel = Instance.new("ImageLabel")
        imageLabel.Name = "ImageDeathRandomClient"
        imageLabel.Size = UDim2.new(1.5, 0, 0.19000037, 0)
        imageLabel.BackgroundTransparency = 1
        imageLabel.ImageTransparency = 0
        imageLabel.Visible = true
        imageLabel.ZIndex = 10
        imageLabel.Parent = healthBar
    end

    local selectedId = safeRandomChoice(imageIds)
    if selectedId then
        pcall(function()
            imageLabel.Image = "rbxassetid://" .. tostring(selectedId)
            imageLabel.Position = UDim2.new(2.5, 0, 0.410000175, 0)
        end)
    end
end

local function playRandomSound(rootPart)
    if not rootPart then return end
    local selectedId = safeRandomChoice(soundIds)
    if not selectedId then return end

    local sound = Instance.new("Sound")
    sound.Name = "DeathSoundClient"
    sound.SoundId = "rbxassetid://" .. tostring(selectedId)
    sound.Volume = 1
    sound.Looped = false
    sound.RollOffMode = Enum.RollOffMode.Inverse
    sound.RollOffMaxDistance = 100
    sound.Parent = rootPart

    -- try to play safely
    local ok, err = pcall(function()
        -- try :Play() directly; if not yet loaded, connect Loaded
        local played = false
        if sound.IsLoaded then
            sound:Play()
            played = true
        else
            -- connect Loaded event (some executors/clients have it)
            if sound.Loaded then
                sound.Loaded:Connect(function()
                    pcall(function() sound:Play() end)
                end)
            else
                -- fallback: wait briefly then try Play
                task.delay(0.5, function()
                    pcall(function() sound:Play() end)
                end)
            end
        end
    end)
    if not ok then
        warn("[Healthbar] playRandomSound error: "..tostring(err))
    end
end

local function monitorHumanoid(humanoid, character)
    if not humanoid then return end
    humanoid.Died:Connect(function()
        pcall(function()
            createOrUpdateImage()
            local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
            if rootPart then
                playRandomSound(rootPart)
            end
        end)
    end)
end

-- connect existing character & future ones
player.CharacterAdded:Connect(function(char)
    local humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
    if humanoid then
        monitorHumanoid(humanoid, char)
    end
end)

if player.Character then
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        monitorHumanoid(humanoid, player.Character)
    end
end

-- Add-ons folder safe creation
do
    local hb = getHealthBarRoot()
    if hb then
        local addons = hb:FindFirstChild("Add-ons_Folder")
        if not addons then
            local ok, err = pcall(function()
                local newFolder = Instance.new("Folder")
                newFolder.Name = "Add-ons_Folder"
                newFolder.Parent = hb
            end)
            if not ok then warn("[Healthbar] Could not create Add-ons_Folder: "..tostring(err)) end
        end
    end
end

-- =========== AVAILABLE NOW ===============

-- =========== CONTINUE EXPSETTINGS SCRPIT ======





-- Client: ExperienceUI_Client.lua
-- LocalScript — สร้าง UI, ควบคุม Toggle, รับ thumbnail จาก Client API

--!strict
local MarketplaceService = game:GetService("MarketplaceService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- ======= Helpers =======
local function createUICorner(parent, scale, offset)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(scale, offset)
    corner.Parent = parent
    return corner
end

-- ======= UIListLayout helpers =========
local HCenter = Enum.HorizontalAlignment.Center
local VCenter = Enum.VerticalAlignment.Center
local HLeft = Enum.HorizontalAlignment.Left
local VTop = Enum.VerticalAlignment.Top
local FillH = Enum.FillDirection.Horizontal
local FillV = Enum.FillDirection.Vertical

local function createUIListLayout(parent, scale, offset, HZ, VT, FILL)
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(scale or 0, offset or 0)
    list.FillDirection = FILL or FillH
    list.HorizontalAlignment = HZ or HCenter
    list.VerticalAlignment = VT or VCenter
    list.Parent = parent
    return list
end

local function tweenObject(obj, props, time, style, direction)
    time = time or 0.28
    style = style or Enum.EasingStyle.Sine
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(time, style, direction)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- safe tween wrapper (ไม่ล่มถ้าหาก obj หาย)
local function safeTween(obj, props, time, style, dir)
    if not obj or not obj.Parent then return end
    pcall(function()
        tweenObject(obj, props, time, style, dir)
    end)
end

-- Safe Find path to the HealthBar where we parent our Menu
local function getHealthBar()
    local ok, topBar = pcall(function() return CoreGui:WaitForChild("TopBarApp", 5) end)
    if not ok or not topBar then return nil end
    local inner = topBar:FindFirstChild("TopBarApp")
    local left = inner and inner:FindFirstChild("UnibarLeftFrame")
    local healthBar = left and left:FindFirstChild("HealthBar")
    return healthBar
end

local healthBar = getHealthBar()
if not healthBar then
    warn("ExperienceUI: HealthBar not found. Aborting UI creation.")
    return
end

-- ======= Build UI =======
local expSettings = Instance.new("Folder")
expSettings.Name = "ExperienceSettings"
expSettings.Parent = healthBar

local menuGui = Instance.new("ScreenGui")
menuGui.Name = "Menu"
menuGui.ResetOnSpawn = false
menuGui.IgnoreGuiInset = true
menuGui.Parent = expSettings

-- Main TopBar holder (small)
local mtb = Instance.new("Frame")
mtb.Name = "TopBar"
mtb.Position = UDim2.new(0, 0, 0.02, 0)
mtb.Size = UDim2.new(1, 0, 0, 43)
mtb.BackgroundTransparency = 1
mtb.Parent = menuGui
createUIListLayout(mtb, 0.005, 0, HCenter, VTop, FillH)

-- Holder image area (left)
local hr = Instance.new("Frame")
hr.Name = "Holder"
hr.Size = UDim2.new(0, 370, 1, 0)
hr.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
hr.BackgroundTransparency = 0.2
hr.Parent = mtb
createUICorner(hr, 1, 0)
createUIListLayout(hr, 0, 10, HCenter, VCenter, FillH)

-- Top bar buttons container (tb) — starts collapsed
local tb = Instance.new("ScrollingFrame")
tb.Name = "TopButtons"
tb.Size = UDim2.new(0, 0, 0, 0) -- start collapsed
tb.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
tb.BackgroundTransparency = 0.2
tb.ScrollBarThickness = 4
tb.CanvasSize = UDim2.new(0, 0, 0, 0)
tb.ScrollingDirection = Enum.ScrollingDirection.XY
tb.Visible = false
tb.Parent = mtb
createUICorner(tb, 0.02, 0)

-- AFTER TB
local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0, 70, 0, 70)   -- ขนาดแต่ละ cell (70x70 px)
grid.CellPadding = UDim2.new(0, 5, 0, 5)  -- ระยะห่างระหว่าง cell
grid.FillDirection = Enum.FillDirection.Horizontal
grid.SortOrder = Enum.SortOrder.Name
grid.Parent = tb
-- update visibility function for tb and its children
local function updateButtonsVisibility()
    local scale = tb.Size.X.Scale or 0

grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    tb.CanvasSize = UDim2.new(0, grid.AbsoluteContentSize.X, 0, grid.AbsoluteContentSize.Y)
end)
-- END TB

    -- ซ่อนปุ่มลูกถ้า scale เล็กกว่า 0.364
    if scale <= 0.364 then
        for _, child in ipairs(tb:GetChildren()) do
            if child:IsA("ImageButton") or child:IsA("TextButton") then
                child.Visible = false
            end
        end
    else
        for _, child in ipairs(tb:GetChildren()) do
            if child:IsA("ImageButton") or child:IsA("TextButton") then
                child.Visible = true
            end
        end
    end

    -- ซ่อน tb ทั้งกล่องเมื่อ scale == 0
    if scale <= 0 then
        tb.Visible = false
    else
        tb.Visible = true
    end
end

tb:GetPropertyChangedSignal("Size"):Connect(updateButtonsVisibility)

-- Settings button (on hr)
local Set = Instance.new("ImageButton")
Set.Name = "a2_Settings"
Set.Size = UDim2.new(0, 36, 0.8, 0)
Set.Image = "rbxassetid://85613740372383"
Set.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Set.BackgroundTransparency = 0.8
Set.Active = true
Set.Visible = false
Set.Parent = hr
createUICorner(Set, 1, 0)

-- Hamburger menu (hbm)
local hbm = Instance.new("ImageButton")
hbm.Name = "a9999_HamburgerMenu"
hbm.Size = UDim2.new(0, 36, 0.8, 0)
hbm.Image = "rbxassetid://12214197591"
hbm.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
hbm.BackgroundTransparency = 0.8
hbm.Active = true
hbm.Visible = false
hbm.Parent = hr
createUICorner(hbm, 1, 0)

-- Open/Close
local OC = Instance.new("ImageButton")
OC.Name = "a1_Open/Close"
OC.Size = UDim2.new(0, 36, 0.8, 0)
OC.Image = "rbxassetid://8877547836"
OC.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
OC.BackgroundTransparency = 0.8
OC.Active = true
OC.Visible = false
OC.Parent = hr
createUICorner(OC, 1, 0)

-- GPT
local gpt = Instance.new("ImageButton")
gpt.Name = "a3_ChatGPT"
gpt.Size = UDim2.new(0, 36, 0.8, 0)
gpt.Image = "rbxassetid://15419312153"
gpt.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
gpt.BackgroundTransparency = 0.8
gpt.Active = true
gpt.Visible = false
gpt.Parent = hr
createUICorner(gpt, 1, 0) --

-- Wait1
local wa1 = Instance.new("Frame")
wa1.Name = "LoadFrame"
wa1.BackgroundTransparency = 1
wa1.Size = UDim2.new(0.8, 0, 1, 0)
wa1.Active = false
wa1.Visible = true
wa1.Parent = hr

-- Warning & Load
local wl = Instance.new("TextLabel")
wl.Name = "Warning & Load"
wl.BackgroundTransparency = 1
wl.Size = UDim2.new(1, 0, 1, 0)
wl.Text = "The ExperienceSettings has been deactivated for some reason."
wl.TextScaled = true
wl.Active = false
wl.TextColor3 = Color3.fromRGB(255, 255, 255)
wl.Visible = true
wl.Parent = wa1

-- ===== OC (Open/Close) wiring - REPLACEMENT =====
local OC_OPEN_IMAGE  = "rbxassetid://126759169574128" -- image when OPEN (show Set/hbm)
local OC_CLOSE_IMAGE = "rbxassetid://96748873664437"  -- image when CLOSED (hide Set/hbm)

-- target mtb X for "closed" (was 0.515 -> change to 0.48 as requested)
local MTB_X_CLOSED = 0.48
local MTB_X_OPEN   = 0 -- open => X = 0

-- hr sizes in px for open/close
local HR_WIDTH_OPEN  = 185
local HR_WIDTH_CLOSE = 44

-- safe setter for mtb position (uses tweenObject if available)
local function setMtbX(open, instant)
    local targetX = open and MTB_X_OPEN or MTB_X_CLOSED
    -- prefer existing mtb variable; fallback to searching inside menuGui
    local targetMtb = mtb or (menuGui and menuGui:FindFirstChild("TopBar", true))

    if OC and (OC:IsA("GuiObject")) then
        OC.Image = open and OC_OPEN_IMAGE or OC_CLOSE_IMAGE
    end

    if not targetMtb then
        return
    end

    local newPos = UDim2.new(targetX, 0, targetMtb.Position.Y.Scale, targetMtb.Position.Y.Offset)
    if instant then
        pcall(function() targetMtb.Position = newPos end)
    else
        pcall(function()
            if safeTween then
                safeTween(targetMtb, { Position = newPos }, 0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            else
                tweenObject(targetMtb, { Position = newPos }, 0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            end
        end)
    end
end

-- safe setter for hr width
local function setHrWidth(px, instant)
    if not hr then return end
    local newSize = UDim2.new(0, px, hr.Size.Y.Scale, hr.Size.Y.Offset)
    if instant then
        pcall(function() hr.Size = newSize end)
    else
        pcall(function()
            if safeTween then
                safeTween(hr, { Size = newSize }, 0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            else
                tweenObject(hr, { Size = newSize }, 0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            end
        end)
    end
end

-- determine initial state from current UI (if Set/hbm visible => consider OPEN)
local ocState = false
if (Set and Set:IsA("GuiObject")) and Set.Visible then
    ocState = true
end

-- ensure OC image set
if OC and OC:IsA("ImageButton") then
    OC.Image = ocState and OC_OPEN_IMAGE or OC_CLOSE_IMAGE
end

-- function to apply the state
local function applyOCState(open, instant)
    ocState = open
    -- set mtb position
    setMtbX(open, instant)
    -- set hr size
    setHrWidth(open and HR_WIDTH_OPEN or HR_WIDTH_CLOSE, instant)
    -- toggle Set/hbm visibility (pcall to be safe)
    pcall(function()
        if Set and Set:IsA("GuiObject") then Set.Visible = open end
        if hbm and hbm:IsA("GuiObject") then hbm.Visible = open end
        if gpt and gpt:IsA("GuiObject") then gpt.Visible = open end
    end)
    -- update OC image
    if OC and OC:IsA("GuiObject") then
        OC.Image = open and OC_OPEN_IMAGE or OC_CLOSE_IMAGE
    end
end

-- initialize (instant)
applyOCState(ocState, true)

-- OC click toggles
if OC and OC:IsA("GuiObject") then
    OC.MouseButton1Click:Connect(function()
        -- toggle and animate
        ocState = not ocState
        applyOCState(ocState, false)
    end)
end

-- KEEP FORCING 

mtb.Position = UDim2.new(0, 0, 0.02, 0)
hr.Size = UDim2.new(0, 350, 1, 0)

-- ===== HRP Watcher System (full) =====
local Players = game:GetService("Players")
local gui_aV2 = game:GetService("CoreGui").TopBarApp.TopBarApp.UnibarLeftFrame.HealthBar.ValueFolder.ValueGui

-- interval config
local CHECK_INTERVAL = 0.05 -- ระยะเวลาเช็ค (วินาที)
local TIMEOUT = 6.255         -- ถ้าไม่มี HRP เกินค่านี้ให้ปิด UI (วินาที)

-- เก็บตำแหน่งเริ่มต้น
local wa1_initial_pos, hr_initial_size, mtb_initial_pos
pcall(function()
    if wa1 then wa1_initial_pos = wa1.Position end
    if hr  then hr_initial_size = hr.Size end
    if mtb then mtb_initial_pos = mtb.Position end
end)

-- --- Ensure resolveUI exists (fallback) ---
if type(resolveUI) ~= "function" then
    function resolveUI()
        local root = menuGui or expSettings or healthBar or game:GetService("CoreGui")
        if not root then return nil end

        local function find(name)
            local ok, res = pcall(function() return root:FindFirstChild(name, true) end)
            if ok then return res end
            return nil
        end

        local rc_tb  = find("TopButtons") or find("TopBar") or find("TopBarApp")
        local rc_hr  = find("Holder") or find("HolderFrame") or find("a_holder")
        local rc_Set = find("a2_Settings") or find("Set") or find("SettingsButton")
        local rc_hbm = find("a9999_HamburgerMenu") or find("Hamburger") or find("hbm")
        local rc_OC  = find("a1_Open/Close") or find("OC") or find("OpenClose")
        local rc_wa1 = find("LoadFrame") or find("wa1") or find("WarningFrame")
        local rc_wl  = find("Warning & Load") or find("wl") or find("WaitLabel")
        local rc_bg  = find("Background") or find("bg")
        local rc_mtb = find("TopBar") or find("MainTopBar") or find("mtb")
        local rc_gpt = find("a3_ChatGPT") or find("gpt") or find("ChatGPTButton")

        return rc_tb, rc_hr, rc_Set, rc_hbm, rc_OC, rc_wa1, rc_wl, rc_bg, rc_mtb, rc_gpt
    end

    warn("[HRP-Watcher] Fallback resolveUI() injected (was missing).")
end

-- UI refs
local ui_tb, ui_hr, ui_Set, ui_hbm, ui_OC, ui_wa1, ui_wl, ui_bg, ui_mtb, ui_gpt = resolveUI()
local timerMissing = 0
local isOpen = false

-- check HRP in character
local function characterHasHRP(plr)
    if not plr or not plr.Character then return false end
    local char = plr.Character
    if char:FindFirstChild("HumanoidRootPart") then return true end
    if char.PrimaryPart and char.PrimaryPart:IsA("BasePart") then return true end
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("BasePart") and (string.find(c.Name, "Root") or string.find(c.Name, "Humanoid") or string.find(c.Name, "Head")) then
            return true
        end
    end
    return false
end

-- watcher loop
task.spawn(function()
    while true do
        task.wait(CHECK_INTERVAL)

        -- พยายาม resolve refs ถ้ายังไม่มี
        if not (ui_tb and ui_hr and ui_Set and ui_hbm and ui_OC and ui_gpt and ui_wa1 and ui_wl) then
            ui_tb, ui_hr, ui_Set, ui_hbm, ui_OC, ui_wa1, ui_wl, ui_bg, ui_mtb, ui_gpt = resolveUI()

            if not (ui_tb and ui_hr and ui_Set and ui_hbm and ui_OC and ui_gpt and ui_wa1 and ui_wl) then
                timerMissing = timerMissing + CHECK_INTERVAL
                if timerMissing >= TIMEOUT then
                    warn("[HRP-Watcher] UI missing for " .. math.floor(timerMissing) .. "s - waiting for UI")
                end
                continue
            else
                timerMissing = 0
            end
        end

        -- ตรวจ HRP ของผู้เล่น
        local pl = Players.LocalPlayer
        local hasHRP = characterHasHRP(pl)

        if hasHRP then
            timerMissing = 0
            if not isOpen then
                print("[HRP-Watcher] HRP detected -> opening UI")
                if ui_mtb and ui_mtb.Parent then
                    safeTween(ui_mtb, { Position = UDim2.new(0.48, 0, ui_mtb.Position.Y.Scale, ui_mtb.Position.Y.Offset) }, 0.28, Enum.EasingStyle.Quad)
                else
                    safeTween(ui_tb, { Position = UDim2.new(0,0,0,0) }, 0.28, Enum.EasingStyle.Quad)
                end

                safeTween(ui_hr, { Size = UDim2.new(0,44, ui_hr.Size.Y.Scale, ui_hr.Size.Y.Offset) }, 0.28)
                pcall(function()
                    if ui_Set  then ui_Set.Visible  = false end
                    if ui_hbm then ui_hbm.Visible = false end
                    if ui_OC  then ui_OC.Visible  = true end
                    if ui_gpt then ui_gpt.Visible = false end
                    if gui_aV2 then gui_aV2.Enabled = true end
                end)

                -- ซ่อน wa1 และ wl
                if ui_wa1 and ui_wa1.Parent then
                    ui_wa1.Visible = false
                    if wa1_initial_pos then
                        pcall(function() safeTween(ui_wa1, { Position = wa1_initial_pos }, 0.22) end)
                    end
                end
                if ui_wl and ui_wl.Parent then
                    ui_wl.Visible = false
                end

                isOpen = true
            end
        else
            timerMissing = timerMissing + CHECK_INTERVAL
            if timerMissing >= TIMEOUT then
                if isOpen then
                    print("[HRP-Watcher] HRP missing >"..TIMEOUT.."s -> closing UI")
                    if ui_mtb and ui_mtb.Parent then
                        safeTween(ui_mtb, { Position = UDim2.new(0,0, 0.02, 0) }, 0.28)
                    else
                        safeTween(ui_tb, { Position = UDim2.new(-5,0, ui_tb.Position.Y.Scale, ui_tb.Position.Y.Offset) }, 0.28)
                    end

                    safeTween(ui_hr, { Size = UDim2.new(0,400, ui_hr.Size.Y.Scale, ui_hr.Size.Y.Offset) }, 0.28)
                    pcall(function()
                        if ui_Set  then ui_Set.Visible  = false end
                        if ui_hbm then ui_hbm.Visible = false end
                        if ui_OC  then ui_OC.Visible  = false end
                        if ui_gpt then ui_gpt.Visible = false end
                        if gui_aV2 then gui_aV2.Enabled = false end
                    end)

                    -- แสดง wa1 และ wl
                    if ui_wa1 and ui_wa1.Parent then
                        ui_wa1.Visible = true
                    end
                    if ui_wl and ui_wl.Parent then
                        ui_wl.Visible = true
                    end

                    isOpen = false
                end
            end
        end
    end
end)

-- ========= END ==========

-- Background panel (start OFFscreen to right)
local background = Instance.new("Frame")
background.Name = "Background"
background.Size = UDim2.new(0.35, 0, 0.9, 0)
background.Position = UDim2.new(1, 0, 0.05, 0) -- offscreen
background.BackgroundColor3 = Color3.new(0, 0, 0)
background.BackgroundTransparency = 0.5
background.Active = true
background.Parent = menuGui
createUICorner(background, 0.02, 0)

-- Experience image (thumbnail)
local experienceImage = Instance.new("ImageLabel")
experienceImage.Name = "ExperienceImage"
experienceImage.Size = UDim2.new(0.3, 0, 0.235, 0)
experienceImage.Position = UDim2.new(0.02, 0, 0.02, 0)
experienceImage.BackgroundTransparency = 0.5
experienceImage.Image = "rbxassetid://15057690464" -- default fallback
experienceImage.Parent = background
createUICorner(experienceImage, 0.05, 0)

-- Experience name label
local experienceName = Instance.new("TextLabel")
experienceName.Name = "ExperienceName"
experienceName.Size = UDim2.new(0.65, 0, 0.235, 0)
experienceName.Position = UDim2.new(0.34, 0, 0.02, 0)
experienceName.BackgroundTransparency = 1
experienceName.Text = "Getting API experience..."
experienceName.TextScaled = true
experienceName.TextColor3 = Color3.new(1, 1, 1)
experienceName.TextStrokeTransparency = 0
experienceName.Parent = background

-- Settings frame inside background
local settings = Instance.new("Frame")
settings.Name = "Settings"
settings.Size = UDim2.new(0.96, 0, 0.7, 0)
settings.Position = UDim2.new(0.02, 0, 0.28, 0)
settings.BackgroundColor3 = Color3.new(0, 0, 0)
settings.BackgroundTransparency = 0.5
settings.Active = true
settings.Parent = background
createUICorner(settings, 0.02, 0)

-- Pmax (players info)
local pmax = Instance.new("Folder"); pmax.Name = "Pmax"; pmax.Parent = settings
local playersLabel = Instance.new("TextLabel")
playersLabel.Name = "Players"; playersLabel.Size = UDim2.new(0.36,0,0.05,0)
playersLabel.Position = UDim2.new(0.02,0,0.02,0)
playersLabel.BackgroundColor3 = Color3.new(1,1,1); playersLabel.BackgroundTransparency = 0.2
playersLabel.Text = "Player :"; playersLabel.TextColor3 = Color3.new(0,0,0)
playersLabel.TextScaled = true; playersLabel.Parent = pmax; createUICorner(playersLabel,0.3,0)

local playerCount = Instance.new("TextLabel")
playerCount.Name = "PlayerCount"; playerCount.Size = UDim2.new(0.58,0,0.05,0)
playerCount.Position = UDim2.new(0.4,0,0.02,0)
playerCount.BackgroundColor3 = Color3.new(1,1,1); playerCount.BackgroundTransparency = 0.2
playerCount.Text = "0/0"; playerCount.TextColor3 = Color3.new(0,0,0)
playerCount.TextScaled = true; playerCount.Parent = pmax; createUICorner(playerCount,0.3,0)

-- SeeAll button
local seeAll = Instance.new("TextButton")
seeAll.Name = "SeeAll"
seeAll.Size = UDim2.new(0.96,0,0.05,0)
seeAll.Position = UDim2.new(0.02,0,0.08,0)
seeAll.BackgroundTransparency = 0.2
seeAll.TextScaled = true
seeAll.Text = "Open Roblox Settings"
seeAll.Parent = pmax
createUICorner(seeAll,0.3,0)

-- Buttons folder (Leave / Reset / Resume)
local Bs = Instance.new("Folder"); Bs.Name = "Buttons"; Bs.Parent = settings

local LE = Instance.new("TextButton")
LE.Name="Leave"; LE.Size=UDim2.new(0.96,0,0.05,0); LE.Position=UDim2.new(0.02,0,0.94,0)
LE.BackgroundTransparency=0.2; LE.BackgroundColor3=Color3.fromRGB(255,0,0)
LE.TextScaled=true; LE.Text="Leave The Experience"; LE.TextColor3=Color3.fromRGB(255,255,255)
LE.Parent = Bs; createUICorner(LE,0.3,0)

local Re = Instance.new("TextButton")
Re.Name="Reset character"; Re.Size=UDim2.new(0.96,0,0.05,0); Re.Position=UDim2.new(0.02,0,0.88,0)
Re.BackgroundTransparency=0.2; Re.BackgroundColor3=Color3.fromRGB(255,84,84)
Re.TextScaled=true; Re.Text="Reset character"; Re.TextColor3=Color3.fromRGB(255,255,255)
Re.Parent = Bs; createUICorner(Re,0.3,0)

local Rm = Instance.new("TextButton")
Rm.Name="Resume"; Rm.Size=UDim2.new(0.96,0,0.05,0); Rm.Position=UDim2.new(0.02,0,0.82,0)
Rm.BackgroundTransparency=0.2; Rm.BackgroundColor3=Color3.fromRGB(170,170,170)
Rm.TextScaled=true; Rm.Text="Resume"; Rm.TextColor3=Color3.fromRGB(255,255,255)
Rm.Parent = Bs; createUICorner(Rm,0.3,0)

-- Lines and toggles container
local L1 = Instance.new("Frame"); L1.Name="Line"; L1.Position=UDim2.new(0.02,0,0.15,0); L1.Size=UDim2.new(0.96,0,0.01,0); L1.Parent = settings
local L2 = Instance.new("Frame"); L2.Name="Line2"; L2.Position=UDim2.new(0.02,0,0.79,0); L2.Size=UDim2.new(0.96,0,0.01,0); L2.Parent = settings

local BFrame = Instance.new("Frame")
BFrame.Name = "B_Frame"; BFrame.Position = UDim2.new(0.02,0,0.18,0); BFrame.Size = UDim2.new(0.96,0,0.6,0)
BFrame.BackgroundTransparency = 1; BFrame.Parent = settings

local UIList = Instance.new("UIListLayout"); UIList.Padding = UDim.new(0.01,0); UIList.Parent = BFrame

-- Toggle builder
local toggleCount = 0
local function createToggle(parent, text, callback, defaultState)
    toggleCount += 1

    local f = Instance.new("Frame")
    f.Name = "Frame" .. toggleCount
    f.Size = UDim2.new(1,0,0.1,0)
    f.BackgroundTransparency = 0
    f.Parent = parent
    createUICorner(f, 0.3, 0)

    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(0.4,0,1,0)
    bar.Position = UDim2.new(0.6,0,0,0)
    bar.BackgroundColor3 = Color3.fromRGB(66,66,66)
    bar.Parent = f
    createUICorner(bar,0.3,0)

    local but = Instance.new("TextButton")
    but.Name = "ToggleButton"
    but.Size = UDim2.new(0.5,0,1,0)
    but.Parent = bar
    createUICorner(but,0.3,0)

    local txt = Instance.new("TextLabel")
    txt.Name = "Label"
    txt.Size = UDim2.new(0.6,0,1,0)
    txt.BackgroundTransparency = 1
    txt.TextScaled = true
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.Text = text
    txt.Parent = f

    -- Toggle Logic
    local toggle = defaultState or false
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local function updateToggle(state, instant)
        toggle = state
        local props
        if toggle then
            props = {
                Position = UDim2.new(0,0,0,0),
                BackgroundColor3 = Color3.fromRGB(0,200,0)
            }
            but.Text = "ON"
        else
            props = {
                Position = UDim2.new(0.5,0,0,0),
                BackgroundColor3 = Color3.fromRGB(255,0,0)
            }
            but.Text = "OFF"
        end
        if instant then
            for k,v in pairs(props) do
                pcall(function() but[k] = v end)
            end
        else
            pcall(function() TweenService:Create(but, tweenInfo, props):Play() end)
        end
        if callback then
            pcall(callback, toggle)
        end
    end

    updateToggle(toggle, true)

    but.MouseButton1Click:Connect(function()
        updateToggle(not toggle)
    end)

    return f
end

-- ======== TOGGLE SWITCHS ===========

-- ValueLabels toggle (safe wait)
local valueGuiOK, ValueGui = pcall(function()
    return CoreGui:WaitForChild("TopBarApp"):WaitForChild("TopBarApp"):WaitForChild("UnibarLeftFrame"):WaitForChild("HealthBar"):WaitForChild("ValueFolder"):WaitForChild("ValueGui")
end)

createToggle(BFrame, "ValueLabels", function(state)
    if valueGuiOK and ValueGui then
        pcall(function() ValueGui.Enabled = state end)
    end
end, (valueGuiOK and ValueGui and ValueGui.Enabled) or true)

-- Save / restore Lighting backup
local lightingBackup = {}
local function saveLightingSettings()
    lightingBackup = {
        ClockTime = Lighting.ClockTime,
        GeographicLatitude = Lighting.GeographicLatitude,
        ColorShift_Bottom = Lighting.ColorShift_Bottom,
        ColorShift_Top = Lighting.ColorShift_Top,
        Ambient = Lighting.Ambient
    }
end
local function restoreLightingSettings()
    if lightingBackup.ClockTime ~= nil then
        pcall(function()
            Lighting.ClockTime = lightingBackup.ClockTime
            Lighting.GeographicLatitude = lightingBackup.GeographicLatitude
            Lighting.ColorShift_Bottom = lightingBackup.ColorShift_Bottom
            Lighting.ColorShift_Top = lightingBackup.ColorShift_Top
            Lighting.Ambient = lightingBackup.Ambient
        end)
    end
end

-- Shaders toggle
createToggle(BFrame, "Shaders - Recommend graphics 5+", function(state)
    if state then
        pcall(saveLightingSettings)
        -- Sky
        if not Lighting:FindFirstChild("Shader-sky") then
            local sky = Instance.new("Sky")
            sky.Name = "Shader-sky"
            sky.SkyboxBk = "rbxassetid://600830446"
            sky.SkyboxDn = "rbxassetid://600831635"
            sky.SkyboxFt = "rbxassetid://600832720"
            sky.SkyboxLf = "rbxassetid://600886090"
            sky.SkyboxRt = "rbxassetid://600833862"
            sky.SkyboxUp = "rbxassetid://600835177"
            sky.SunTextureId = "rbxassetid://6281397906"
            sky.MoonTextureId = "rbxassetid://102013024637283"
            sky.SunAngularSize = 11
            sky.MoonAngularSize = 11
            sky.Parent = Lighting
        end
        -- DepthOfField
        if not Lighting:FindFirstChild("Shader-Field") then
            local dof = Instance.new("DepthOfFieldEffect")
            dof.Name = "Shader-Field"; dof.InFocusRadius = 25; dof.NearIntensity = 0.15; dof.Parent = Lighting
        end
        -- ColorCorrection
        if not Lighting:FindFirstChild("Shader-Correction") then
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "Shader-Correction"; cc.Brightness = -0.1; cc.Contrast = 0.3; cc.Parent = Lighting
        end
        -- SunRays
        if not Lighting:FindFirstChild("Shader-SunRays") then
            local sr = Instance.new("SunRaysEffect")
            sr.Name = "Shader-SunRays"; sr.Intensity = 0.103; sr.Spread = 0.88; sr.Parent = Lighting
        end
        -- Atmosphere (safe create)
        if not Lighting:FindFirstChild("Shader-Atmosphere") then
            pcall(function()
                local a = Instance.new("Atmosphere")
                a.Name = "Shader-Atmosphere"
                a.Density = 0.419
                pcall(function() a.Color = Color3.fromRGB(75,47,29) end)
                a.Parent = Lighting
            end)
        end
        -- lighting props
        Lighting.ClockTime = 6.509
        Lighting.GeographicLatitude = 33.91
        Lighting.ColorShift_Bottom = Color3.fromRGB(0,0,0)
        Lighting.ColorShift_Top = Color3.fromRGB(255,166,0)
        Lighting.Ambient = Color3.fromRGB(75,47,20)
    else
        local targets = {"Shader-sky","Shader-Field","Shader-Correction","Shader-SunRays","Shader-Atmosphere"}
        for _, name in ipairs(targets) do
            local obj = Lighting:FindFirstChild(name)
            if obj then pcall(function() obj:Destroy() end) end
        end
        pcall(restoreLightingSettings)
    end
end, false)

-- ต้องมี service เหล่านี้
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

-- เก็บ coroutine / task ของ rainbow per-part เพื่อให้เราหยุดได้
local _rainbowTasks = {}

-- ลิสต์ part ที่จะพยายามหา (ลำดับความสำคัญ)
local ATTACH_CANDIDATES = {
    "HumanoidRootPart",
    "LowerTorso",
    "UpperTorso",
    "Torso",
    "Head"
}

-- หา part ที่จะ parent light ให้ (คืน BasePart หรือ nil)
local function findAttachPart(character)
    if not character then return nil end
    for _, name in ipairs(ATTACH_CANDIDATES) do
        local p = character:FindFirstChild(name)
        if p and p:IsA("BasePart") then
            return p
        end
    end
    return nil
end

-- สต็อกชื่อ light
local LIGHT_NAME = "Experience_Lighter"

-- หยุด rainbow loop สำหรับ part นั้น (ถ้ามี)
local function stopRainbowFor(part)
    if not part then return end
    local taskFlag = _rainbowTasks[part]
    if taskFlag and taskFlag._stop then
        taskFlag._stop = true
        _rainbowTasks[part] = nil
    end
end

-- สร้างหรือเปิด light
-- params:
--  state: boolean (true = on, false = off)
--  rainbow: boolean (true => ไล่สี)
--  opts (optional): table { Brightness = number, Range = number, Color = Color3 }
local function setLighterForCharacter(char, state, rainbow, opts)
    if not char then return false, "no char" end
    local attach = findAttachPart(char)
    if not attach then return false, "no attach part found" end

    -- ถ้ามี light อยู่แล้ว จัดการตาม state
    local existing = attach:FindFirstChild(LIGHT_NAME)
    if not state then
        -- ปิด/ลบ
        if existing then
            stopRainbowFor(attach)
            existing:Destroy()
        end
        return true, "turned off"
    end

    -- เปิด: สร้าง light ถ้ายังไม่มี
    if not existing then
        local light = Instance.new("PointLight")
        light.Name = LIGHT_NAME
        light.Brightness = (opts and opts.Brightness) or 2
        light.Range = (opts and opts.Range) or 25
        light.Color = (opts and opts.Color) or Color3.new(1,1,1)
        -- PointLight ไม่มี Angle property — เป็น omnidirectional อยู่แล้ว (เทียบกับ SpotLight)
        light.Parent = attach

        -- ถ้าผู้ใช้ทำลาย part เราควรหยุด task ด้วย (เช็ค AncestryChanged)
        attach.AncestryChanged:Connect(function(child, parent)
            if not parent then
                -- part ถูกลบ -> หยุด rainbow (ถ้ามี)
                stopRainbowFor(attach)
            end
        end)
    else
        -- update properties ถ้ามี
        existing.Brightness = (opts and opts.Brightness) or existing.Brightness
        existing.Range = (opts and opts.Range) or existing.Range
        existing.Color = (opts and opts.Color) or existing.Color
    end

    -- rainbow handling
    stopRainbowFor(attach) -- ทำความสะอาดก่อน
    if rainbow then
        -- สร้าง task flag เพื่อให้หยุดได้
        local flag = { _stop = false }
        _rainbowTasks[attach] = flag
        task.spawn(function()
            local t0 = tick()
            while not flag._stop and attach.Parent do
                local h = (tick() - t0) * 0.12 -- speed factor (ปรับได้)
                local color = Color3.fromHSV(h % 1, 1, 1)
                local light = attach:FindFirstChild(LIGHT_NAME)
                if light then
                    -- pcall ป้องกัน error ถ้า light ถูกทำลายในระหว่าง loop
                    pcall(function() light.Color = color end)
                else
                    break
                end
                task.wait(0.06)
            end
        end)
    else
        -- ตั้งสีปกติ (ขาว) เมื่อไม่ใช่ rainbow
        local light = attach:FindFirstChild(LIGHT_NAME)
        if light then
            pcall(function() light.Color = Color3.fromRGB(255,255,255) end)
        end
    end

    return true, "turned on"
end

-- ตัวช่วย: toggle สำหรับ local player (เรียกจาก toggle callback)
local function toggleForLocalPlayer(state, rainbow)
    local pl = Players.LocalPlayer
    if not pl then return end
    local char = pl.Character or pl.CharacterAdded:Wait()
    local ok, msg = pcall(function()
        return setLighterForCharacter(char, state, rainbow)
    end)
    if not ok then
        warn("[Lighter] failed:", msg)
    end
end

createToggle(BFrame, "White Light", function(state)
    toggleForLocalPlayer(state, false) -- ปกติ ขาว
end, false)

createToggle(BFrame, "RGB Light", function(state)
    toggleForLocalPlayer(state, true) -- RGB (เดิม rainbow)
end, false)



createToggle(BFrame, "ESP (Beta)", function(state)
    if state then
        if _G.EnableESP then pcall(_G.EnableESP) end
    else
        if _G.DisableESP then pcall(_G.DisableESP) end
    end
end, false)

-- ESP LocalScript (no FPS, with Team and plaID; Age & JoinDate unchanged)
-- วางใน StarterPlayerScripts (client-side)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local ESPEnabled = false
local ESPData = {} -- [player] = { highlight = Instance, billboard = Instance, label = Instance, conn = RBXScriptConnection }

-- Config
local HIGHLIGHT_NAME = "ESPHighlight"
local BILLBOARD_NAME  = "ESPInfo"
local UPDATE_INTERVAL = 0.12 -- ไม่อัปเดตเร็วจนเกินไป (text/props)

-- Helpers
local function safeDestroy(obj)
	if obj and obj.Destroy then
		pcall(function() obj:Destroy() end)
	end
end

local function getTeamColor(player)
	if player and player.TeamColor and player.TeamColor.Color then
		return player.TeamColor.Color
	end
	return Color3.fromRGB(170,170,170) -- neutral gray
end

local function getTeamName(player)
	if player and player.Team and player.Team.Name and player.Team.Name ~= "" then
		return player.Team.Name
	end
	return "Neutral"
end

local function fmtNum(n, f)
	f = f or "%.2f"
	if type(n) ~= "number" then return string.format(f, 0) end
	return string.format(f, n)
end

-- Build info string (ตามที่ขอ: ห้ามแก้ Age/JoinDate logic)
local function buildInfoString(player, character)
	local username = player and player.Name or "Unknown"
	local userId = tostring(player and player.UserId or 0)

	-- health
	local hum = character and character:FindFirstChildOfClass("Humanoid")
	local health = hum and hum.Health or 0

	-- studs (ระยะจาก local player's HRP ถ้ามี)
	local studs = 0
	local localRoot = LocalPlayer and LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head"))
	local targetPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head"))
	if localRoot and targetPart then
		studs = (targetPart.Position - localRoot.Position).Magnitude
	end

	-- team
	local teamName = getTeamName(player)

	-- Age & JoinDate (ใช้ logic เดิมของคุณ)
	local ageDays = player and player.AccountAge or 0 -- จำนวนวัน (ตาม Roblox property)
	local createdUnix = tick() - (ageDays * 86400) -- วิธีเดิมที่คุณใช้
	local joinDate = os.date("%Y-%m-%d", createdUnix)

	-- สร้าง string (ตามฟอร์แมตที่ขอรวม Team และ plaID)
	local info = string.format(
		"👤%s | 🕓Age: %d | 🗓️JoinDate: %s | ♥️Health: %s | 📏Studs: %s | 🏳️: %s | 🆔PlayerID: %s",
		username,
		ageDays,
		joinDate,
		string.format("%.2f", health),
		fmtNum(studs),
		teamName,
		userId
	)

	return info
end

-- Ensure Highlight
local function ensureHighlight(player, character)
	if not character then return nil end
	-- ค้นหา highlight ชื่อ HIGHLIGHT_NAME ภายใน character ก่อน
	local hi = character:FindFirstChild(HIGHLIGHT_NAME)
	if not hi then
		-- ถ้าไม่มี สร้างใหม่
		hi = Instance.new("Highlight")
		hi.Name = HIGHLIGHT_NAME
		hi.Parent = character
	end
	-- อัปเดต properties
	pcall(function()
		hi.Adornee = character
		local col = getTeamColor(player)
		hi.OutlineTransparency = 0
		hi.FillTransparency = 0.8
		hi.OutlineColor = col
		hi.FillColor = col
	end)
	return hi
end

-- Ensure BillboardGui + Label
local function ensureBillboard(player, character)
	if not character then return nil, nil end
	local adornee = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
	if not adornee then return nil, nil end

	local bg = character:FindFirstChild(BILLBOARD_NAME)
	if not bg or not bg:IsA("BillboardGui") then
		-- ถ้ามี object แต่ไม่ใช่ Billboard ให้ลบทิ้งก่อน
		if bg and bg.Parent then
			pcall(function() bg:Destroy() end)
		end
		bg = Instance.new("BillboardGui")
		bg.Name = BILLBOARD_NAME
		bg.Parent = character
		bg.Adornee = adornee
		bg.AlwaysOnTop = true
		bg.Size = UDim2.new(0,250,0,40)
		bg.StudsOffset = Vector3.new(0,3,0)
	end

	local tl = bg:FindFirstChild("ESP_Label")
	if not tl or not tl:IsA("TextLabel") then
		if tl and tl.Parent then pcall(function() tl:Destroy() end) end
		tl = Instance.new("TextLabel")
		tl.Name = "ESP_Label"
		tl.Parent = bg
		tl.Size = UDim2.new(1,0,1,0)
		tl.BackgroundTransparency = 1
		tl.TextScaled = true
		tl.TextStrokeTransparency = 0
		tl.Font = Enum.Font.SourceSans
		tl.TextXAlignment = Enum.TextXAlignment.Left
		tl.TextYAlignment = Enum.TextYAlignment.Center
	end

	-- set text color to team color
	pcall(function()
		tl.TextColor3 = getTeamColor(player)
	end)

	return bg, tl
end

-- add ESP to a single player
local function addESPToPlayer(player)
	if not player or player == LocalPlayer then return end
	if ESPData[player] then return end

	ESPData[player] = { highlight = nil, billboard = nil, label = nil, conn = nil }

	local function setupCharacter(character)
		if not character then return end
		-- wait for HRP or head at most a short time
		local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
		-- ensure highlight + billboard
		local hi = ensureHighlight(player, character)
		local bg, tl = ensureBillboard(player, character)
		ESPData[player].highlight = hi
		ESPData[player].billboard = bg
		ESPData[player].label = tl
		-- initial text
		if tl then
			pcall(function() tl.Text = buildInfoString(player, character) end)
		end
	end

	-- If character exists now
	if player.Character then
		setupCharacter(player.Character)
	end

	-- Connect CharacterAdded to re-setup
	local charConn = player.CharacterAdded:Connect(function(char)
		-- wait briefly for parts to load
		char:WaitForChild("HumanoidRootPart", 2)
		setupCharacter(char)
	end)

	-- store connection so we can disconnect later (also we will create updater connection below)
	ESPData[player].charConn = charConn

	-- Updater (Heartbeat) per-player: update text/colors & highlight color each interval
	local acc = 0
	local blinkAcc = 0
	local blinkState = false
	local updConn
	updConn = RunService.Heartbeat:Connect(function(dt)
		if not ESPEnabled then return end
		acc = acc + dt
		blinkAcc = blinkAcc + dt
		-- update at UPDATE_INTERVAL
		if acc >= UPDATE_INTERVAL then
			acc = 0
			local rec = ESPData[player]
			if not rec then
				-- safety
				if updConn then updConn:Disconnect() end
				return
			end
			local char = player.Character
			if not char then
				-- no character: ensure UI removed
				if rec.highlight and rec.highlight.Parent then safeDestroy(rec.highlight) end
				if rec.billboard and rec.billboard.Parent then safeDestroy(rec.billboard) end
				rec.highlight, rec.billboard, rec.label = nil, nil, nil
				return
			end

			-- ensure created if missing
			if not (rec.highlight and rec.highlight.Parent) then
				rec.highlight = ensureHighlight(player, char)
			end
			if not (rec.billboard and rec.billboard.Parent and rec.label) then
				local bg, tl = ensureBillboard(player, char)
				rec.billboard, rec.label = bg, tl
			end

			-- update text
			if rec.label then
				pcall(function()
					rec.label.Text = buildInfoString(player, char)
					rec.label.TextColor3 = getTeamColor(player)
				end)
			end

			-- update highlight color
			pcall(function()
				if rec.highlight then
					local col = getTeamColor(player)
					rec.highlight.FillColor = col
					rec.highlight.OutlineColor = col
				end
			end)
		end

		-- blink logic: (ไม่ใช่ส่วนหลัก แต่เก็บไว้ถ้าต้องการในอนาคต)
		-- ถ้าต้องการกระพริบเมื่อเลือดต่ำ ใช้ blinkAcc เปรียบกับ 0.05 แล้วสลับสี
	end)

	ESPData[player].conn = updConn
end

local function removeESPForPlayer(player)
	local rec = ESPData[player]
	if not rec then return end
	pcall(function()
		if rec.conn then rec.conn:Disconnect() end
		if rec.charConn then rec.charConn:Disconnect() end
		if rec.highlight and rec.highlight.Parent then safeDestroy(rec.highlight) end
		if rec.billboard and rec.billboard.Parent then safeDestroy(rec.billboard) end
	end)
	ESPData[player] = nil
end

-- Public controls
local function addAll()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			addESPToPlayer(p)
		end
	end
end

local function removeAll()
	for p, _ in pairs(ESPData) do
		removeESPForPlayer(p)
	end
end

-- Hook player join/leave to keep realtime
Players.PlayerAdded:Connect(function(p)
	if not ESPEnabled then return end
	if p ~= LocalPlayer then addESPToPlayer(p) end
end)
Players.PlayerRemoving:Connect(function(p)
	removeESPForPlayer(p)
end)

-- enable / disable functions
function enableESP()
	if ESPEnabled then return end
	ESPEnabled = true
	addAll()
end

function disableESP()
	if not ESPEnabled then return end
	ESPEnabled = false
	removeAll()
end

-- optionally expose to _G if you want toggling from elsewhere:
_G.EnableESP = enableESP
_G.DisableESP = disableESP

-- (example) start disabled by default — caller should call enableESP()
-- enableESP()

-- ===== END ESP implementation =====





-- ============== IMAGE BUTTONS ==============
-- helper: ImageButton creation (parented to tb by default)
local function createImageButton(name, r, g, b, bt, imageId, visible, parentFrame)
    parentFrame = parentFrame or tb
    local im = Instance.new("ImageButton")
    im.Name = tostring(name)
    im.Size = UDim2.new(0, 70, 0, 70)
    im.BackgroundTransparency = bt or 1
    im.BackgroundColor3 = Color3.fromRGB(r or 255, g or 255, b or 255)
    im.Visible = (visible ~= false)
    if imageId then
        local idstr = tostring(imageId)
        if idstr:match("^rbxassetid://") then
            im.Image = idstr
        else
            im.Image = "rbxassetid://" .. idstr
        end
    end
    im.Parent = parentFrame
    createUICorner(im, 1, 0)
    return im
end

-- CTB1
local ctb1 = createImageButton("a1_INF YIELD", 50, 50, 50, 0.2, "116464551513962", false)
if ctb1 then
    ctb1.MouseButton1Click:Connect(function()
        pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end)
    end)
end

-- CTB2
local ctb2 = createImageButton("a2_Dex", 50, 50, 50, 0.2, "102148729694907", false)
if ctb2 then
    ctb2.MouseButton1Click:Connect(function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/MITUMAxDev/Tools/refs/heads/main/Dex-Explorer.lua"))()
        end)
    end)
end

-- CTB3
local ctb3 = createImageButton("a3_Keyboard", 50, 50, 50, 0.2, "76210662677344", false)
if ctb3 then
    ctb3.MouseButton1Click:Connect(function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Xxtan31/Ata/main/deltakeyboardcrack.txt", true))()
        end)
    end)
end

-- CTB4
local ctb4 = createImageButton("a4_Rochips", 50, 50, 50, 0.2, "111409127543607", false)
if ctb4 then
    ctb4.MouseButton1Click:Connect(function()
        pcall(function()
            loadstring(game:HttpGet("https://glot.io/snippets/gzrux646yj/raw/main.ts"))()
        end)
    end)
end

-- CTB5
local ctb5 = createImageButton("a5_Ketamine", 50, 50, 50, 0.2, "73739594473443", false)
if ctb5 then
    ctb5.MouseButton1Click:Connect(function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/InfernusScripts/Ketamine/refs/heads/main/Ketamine.lua"))()
        end)
    end)
end

-- CTB6
local ctb6 = createImageButton("a6_AFEM", 50, 50, 50, 0.2, "70633192931522", false)
if ctb6 then
    ctb6.MouseButton1Click:Connect(function()
        pcall(function()
            loadstring(game:HttpGet("https://yarhm.mhi.im/scr?channel=afem", true))()
        end)
    end)
end

-- CTB7
local ctb7 = createImageButton("a7_Chat", 50, 50, 50, 0.2, "78687742773593", false)
if ctb7 then
    ctb7.MouseButton1Click:Connect(function()
        pcall(function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/ThacG/Xyros/refs/heads/main/test"))()
        end)
    end)
end

-- CTB8
local ctb8 = createImageButton("a8_ExeTest", 50, 50, 50, 0.2, "7128117167", false)
if ctb8 then
    ctb8.MouseButton1Click:Connect(function()
        pcall(function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/InfernusScripts/Executor-Tests/main/Identity/Test.lua"))()
        end)
    end)
end

-- CTB9
local ctb9 = createImageButton("a9_REM", 0, 165, 0, 0.2, "91782079102380", false)
if ctb9 then
    ctb9.MouseButton1Click:Connect(function()
        pcall(function()
    loadstring(game:HttpGet("https://e-vil.com/anbu/rem.lua"))()
        end)
    end)
end

-- CTB10
local ctb10 = createImageButton("b1_GameProber", 50, 50, 50, 0.2, "14944375078", false)
if ctb10 then
    ctb10.MouseButton1Click:Connect(function()
        pcall(function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Joystickplays/gameprober-lua/main/gp.lua"))()
        end)
    end)
end

-- ===== TEXT BUTTONS =======
-- helper: TextButton creation (parented to tb by default)
local function createTextButton(name, r, g, b, bt, text, scaled, visible, tr, tg, tb2, parentFrame)
    parentFrame = parentFrame or tb
    local txtb = Instance.new("TextButton")
    txtb.Name = tostring(name)
    -- fixed size: width 34 px (avoid stretching), full height fraction
    txtb.Size = UDim2.new(0, 70, 0, 70)
    txtb.BackgroundTransparency = bt or 1
    txtb.BackgroundColor3 = Color3.fromRGB(r or 255, g or 255, b or 255)
    txtb.Visible = (visible ~= false)
    txtb.Text = tostring(text or "")
    -- text color separate (defaults to white)
    txtb.TextColor3 = Color3.fromRGB(tr or 255, tg or 255, tb2 or 255)
    txtb.Font = Enum.Font.Legacy
    txtb.TextScaled = (scaled ~= false)
    txtb.Parent = parentFrame
    createUICorner(txtb, 1, 0)
    return txtb
end

-- ============== Background open/close functions ==============
local BG_X_ON = 0.65
local BG_X_OFF = 1
local function backgroundIsOpen()
    return math.abs(background.Position.X.Scale - BG_X_ON) < 0.01
end
local function setBackgroundState(open, instant)
    local target = open and BG_X_ON or BG_X_OFF
    local newPos = UDim2.new(target, 0, background.Position.Y.Scale, 0)
    if instant then
        background.Position = newPos
    else
        tweenObject(background, { Position = newPos }, 0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end
    pcall(function()
        if open then tweenObject(Set, { Rotation = 0 }, 0.22) else tweenObject(Set, { Rotation = 180 }, 0.22) end
    end)
end

Set.MouseButton1Click:Connect(function()
    setBackgroundState(not backgroundIsOpen(), false)
end)

-- ============== Thumbnail + ExperienceName load ==========
pcall(function()
    local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
    if ok and type(info) == "table" then
        if info.IconImageAssetId and info.IconImageAssetId ~= 0 then
            experienceImage.Image = "rbxassetid://" .. tostring(info.IconImageAssetId)
        else
            -- try GetGameThumbnailAsync fallback
            local sOk, content = pcall(function()
                return Players:GetGameThumbnailAsync(game.PlaceId, Enum.ThumbnailType.Icon, Enum.ThumbnailSize.Size512x512)
            end)
            if sOk and type(content) == "string" and #content > 4 then
                experienceImage.Image = content
            else
                experienceImage.Image = "rbxassetid://15057690464"
            end
        end
        if info.Name then experienceName.Text = tostring(info.Name) end
    else
        -- fallback: try thumbnail call directly
        local sOk, content = pcall(function()
            return Players:GetGameThumbnailAsync(game.PlaceId, Enum.ThumbnailType.Icon, Enum.ThumbnailSize.Size512x512)
        end)
        if sOk and type(content) == "string" and #content > 4 then
            experienceImage.Image = content
        else
            experienceImage.Image = "rbxassetid://15057690464"
        end
        pcall(function() experienceName.Text = tostring(game.Name or ("Place " .. tostring(game.PlaceId))) end)
    end
end)

-- ============== playerCount realtime ==========
local function updatePlayerCounter()
    local count = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers or 0
    playerCount.Text = tostring(count) .. "/" .. tostring(maxPlayers)
end
updatePlayerCounter()
Players.PlayerAdded:Connect(updatePlayerCounter)
Players.PlayerRemoving:Connect(updatePlayerCounter)
do
    local tick = 0
    RunService.Heartbeat:Connect(function(dt)
        tick += dt
        if tick >= 2 then tick = 0 updatePlayerCounter() end
    end)
end

-- ============== SeeAll: open Roblox settings and close background ==========
local function tryOpenRobloxMenu()
    -- try RobloxGui path first (set Visible)
    local ok, settingsShield = pcall(function()
        local rg = CoreGui:FindFirstChild("RobloxGui")
        if not rg then return nil end
        local sc = rg:FindFirstChild("SettingsClippingShield") or rg:FindFirstChild("SettingsShield")
        if not sc then return nil end
        local shield = sc:FindFirstChild("SettingsShield") or sc:FindFirstChild("Settings") or sc
        if shield then
            local menuContainer = shield:FindFirstChild("MenuContainer") or shield:FindFirstChild("SettingsMenu")
            if menuContainer then
                menuContainer.Visible = true
                return true
            end
        end
        return nil
    end)
    if ok and settingsShield then return true end

    -- fallback: try GuiService/OpenInGameMenu or StarterGui SetCore
    local ok1 = pcall(function() GuiService:OpenInGameMenu() end)
    if ok1 then return true end
    local ok2 = pcall(function() StarterGui:SetCore("ToggleGameMenu", true) end)
    if ok2 then return true end
    local ok3 = pcall(function() StarterGui:SetCore("OpenSettings") end)
    if ok3 then return true end

    -- last resort: try VirtualInputManager to send ESC if available
    local vim = game:FindService("VirtualInputManager")
    if vim then
        local ok4 = pcall(function()
            vim:SendKeyEvent(true, Enum.KeyCode.Escape, false, game)
            task.wait(0.02)
            vim:SendKeyEvent(false, Enum.KeyCode.Escape, false, game)
        end)
        if ok4 then return true end
    end

    return false
end

seeAll.MouseButton1Click:Connect(function()
    setBackgroundState(false, false) -- close panel via tween (OFF)
    tryOpenRobloxMenu()
end)

-- ============== LE / Re / Rm behaviors ==========
LE.MouseButton1Click:Connect(function()
    if localPlayer then pcall(function() localPlayer:Kick("You leave the experience.") end) end
end)

Re.MouseButton1Click:Connect(function()
    local plr = localPlayer
    if not plr then return end
    local char = plr.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function() humanoid.Health = 0 end)
        else
            pcall(function() char:BreakJoints() end)
        end
    end
end)

Rm.MouseButton1Click:Connect(function()
    setBackgroundState(false, false)
end)

-- Keep Set rotation consistent
RunService.Heartbeat:Connect(function()
    local open = backgroundIsOpen()
    if open then
        if math.abs(Set.Rotation - 0) > 1 then Set.Rotation = 0 end
    else
        if math.abs(Set.Rotation - 180) > 1 then Set.Rotation = 180 end
    end
end)

-- ============== Hamburger toggle (tb size + icons) ==============
local tbOpen = false
local function toggleTB()
    tbOpen = not tbOpen
    if tbOpen then
        tweenObject(tb, { Size = UDim2.new(0.365, 0, 10, 0) }, 0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        hbm.Image = "rbxassetid://10002398990"
    else
        tweenObject(tb, { Size = UDim2.new(0, 0, 0, 0) }, 0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        hbm.Image = "rbxassetid://12214197591"
    end
end
hbm.MouseButton1Click:Connect(toggleTB)


-- ChatGPT LocalScript (single-file) - unified /Ins + robust guards
-- Language: English commands, UI messages localized in English-like lines for clarity.
-- Defensive pcall wrappers to avoid "attempt to call a nil value"

-- Services
local HttpService       = game:GetService("HttpService")
local Players           = game:GetService("Players")
local TeleportService   = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Utilities
local function trim(s) return tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", "") end
local function safePcall(fn, ...) local ok, res = pcall(fn, ...) if not ok then return nil, tostring(res) end return res, nil end
local function redactKey(k) if type(k) ~= "string" or k == "" then return "<nil>" end if #k <= 12 then return "********" end return k:sub(1,6) .. "..." .. k:sub(-6) end
local function safeTween(obj, props, time, style, dir) if not obj or not obj.Parent then return end pcall(function() local tinfo = TweenInfo.new(time or 0.28, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out) local tw = TweenService:Create(obj, tinfo, props) tw:Play() end) end
local function safeEval(expr)
    if not expr or expr == "" then return nil, "empty" end
    if type(loadstring) ~= "function" then return nil, "loadstring not available" end
    local f, err = loadstring("return " .. expr)
    if not f then return nil, err end
    local ok, res = pcall(f)
    if not ok then return nil, tostring(res) end
    return res, nil
end

local function resolveLocate(locateStr)
    if not locateStr or locateStr == "" then return nil, "empty locate" end
    local s = trim(locateStr)
    -- try eval first (guarded)
    if type(loadstring) == "function" then
        local ok, val = pcall(function()
            local f, e = loadstring("return " .. s)
            if not f then error(e) end
            return f()
        end)
        if ok and val then return val, nil end
    end
    -- fallback: search in Workspace
    local found = Workspace:FindFirstChild(s, true)
    if found then return found, nil end
    for _,svc in ipairs(game:GetChildren()) do
        if type(svc) == "Instance" and svc.FindFirstChild then
            local ff = svc:FindFirstChild(s, true)
            if ff then return ff end
        end
    end
    return nil, "resolve_failed"
end

local function findObjectByName(name)
    if not name or name == "" then return nil end
    local f = Workspace:FindFirstChild(name, true)
    if f then return f end
    for _,svc in ipairs(game:GetChildren()) do
        if type(svc) == "Instance" and svc.FindFirstChild then
            local ff = svc:FindFirstChild(name, true)
            if ff then return ff end
        end
    end
    return nil
end

local function applyColorToObject(obj, color)
    if not obj or not color then return false end
    pcall(function()
        if obj:IsA("BasePart") then pcall(function() obj.Color = color end) end
        if pcall(function() return obj.BackgroundColor3 end) then pcall(function() obj.BackgroundColor3 = color end) end
        if pcall(function() return obj.TextColor3 end) then pcall(function() obj.TextColor3 = color end) end
        if pcall(function() return obj.ImageColor3 end) then pcall(function() obj.ImageColor3 = color end) end
    end)
    return true
end

-- Parent detection (prefer menuGui variable if present)
local targetMenu = nil
if type(menuGui) == "Instance" and menuGui.Parent then
    targetMenu = menuGui
else
    pcall(function()
        local path = CoreGui.TopBarApp and CoreGui.TopBarApp.TopBarApp and CoreGui.TopBarApp.TopBarApp.UnibarLeftFrame
        if path and path.HealthBar and path.HealthBar.ExperienceSettings and path.HealthBar.ExperienceSettings.Menu then
            targetMenu = path.HealthBar.ExperienceSettings.Menu
        end
    end)
end
if not (targetMenu and targetMenu.Parent) then
    targetMenu = CoreGui
end

-- STATE (no hardcoded secret keys)
local STATE = {
    OPENAI_KEY = nil,
    PROJECT_ID = nil,
    MODEL = "gpt-3.5-turbo",
    validated = false,
    requestInFlight = false,
    HttpAsync = true,
    seeChatEnabled = false,
    seeChatConns = {},
    _playerAddedConn = nil,
    _chatEventConn = nil,
    autobot = { enabled = false, mode = "Random", task = nil },
    debug = true,
    _keeps = {},
}

-- Ensure client remote event (safe)
pcall(function()
    if not ReplicatedStorage:FindFirstChild("ChatGPTClientEvent") then
        local ev = Instance.new("RemoteEvent")
        ev.Name = "ChatGPTClientEvent"
        ev.Parent = ReplicatedStorage
    end
end)

-- Create or reuse gptGui (do not override existing menu Gui)
local function createIfMissingGui()
    local gptGui = nil
    pcall(function() gptGui = targetMenu:FindFirstChild("gptGui", true) end)
    if not gptGui then
        local ok, isPlayerGui = pcall(function() return targetMenu:IsA("PlayerGui") end)
        if ok and isPlayerGui then
            gptGui = Instance.new("ScreenGui")
            gptGui.Name = "gptGui"
            gptGui.IgnoreGuiInset = true
            gptGui.Parent = targetMenu
        else
            local frame = Instance.new("Frame")
            frame.Name = "gptGui"
            frame.Size = UDim2.new(1,0,0.9,0)
            frame.Position = UDim2.new(-1,0,0.1,0)
            frame.BackgroundColor3 = Color3.fromRGB(18,18,20)
            frame.BackgroundTransparency = 0.12
            local uc = Instance.new("UICorner"); uc.CornerRadius = UDim.new(0,6); uc.Parent = frame
            frame.Parent = targetMenu
            gptGui = frame
        end
    end
    return gptGui
end

local gptGui = createIfMissingGui()

-- rootFrame (main panel)
local rootFrame = gptGui
if gptGui:IsA("ScreenGui") then
    local child = gptGui:FindFirstChild("FrameMain")
    if not child then
        child = Instance.new("Frame")
        child.Name = "FrameMain"
        child.Size = UDim2.new(1,0,0.9,0)
        child.Position = UDim2.new(-1,0,0.1,0)
        child.BackgroundColor3 = Color3.fromRGB(18,18,20)
        child.BackgroundTransparency = 0.12
        child.Parent = gptGui
    end
    rootFrame = child
end

-- Chat UI containers
local gptBack = rootFrame:FindFirstChild("Background") or Instance.new("Frame")
if not gptBack.Parent then
    gptBack.Name = "Background"
    gptBack.Size = UDim2.new(0.96,0,0.96,0)
    gptBack.Position = UDim2.new(0.02,0,0.02,0)
    gptBack.BackgroundTransparency = 1
    gptBack.Parent = rootFrame
end

local gptScroll = gptBack:FindFirstChild("a0_Scroll")
if not gptScroll then
    gptScroll = Instance.new("ScrollingFrame")
    gptScroll.Name = "a0_Scroll"
    gptScroll.Size = UDim2.new(1,0,0.62,0)
    gptScroll.Position = UDim2.new(0,0,0.12,0)
    gptScroll.BackgroundTransparency = 0.5
    gptScroll.BackgroundColor3 = Color3.fromRGB(12,12,12)
    gptScroll.ScrollBarThickness = 6
    gptScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local cc = Instance.new("UICorner"); cc.Parent = gptScroll
    gptScroll.Parent = gptBack
end

local gptChat = gptScroll:FindFirstChild("Chat")
if not gptChat then
    gptChat = Instance.new("Frame")
    gptChat.Name = "Chat"
    gptChat.Size = UDim2.new(0.96,0,0,0)
    gptChat.Position = UDim2.new(0.02,0,0,10)
    gptChat.BackgroundTransparency = 1
    gptChat.Parent = gptScroll
end

local uiLayout = gptChat:FindFirstChildOfClass("UIListLayout")
if not uiLayout then
    uiLayout = Instance.new("UIListLayout")
    uiLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiLayout.Padding = UDim.new(0,6)
    uiLayout.Parent = gptChat
end
uiLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    pcall(function()
        gptScroll.CanvasSize = UDim2.new(0,0,0,uiLayout.AbsoluteContentSize.Y)
        gptScroll.CanvasPosition = Vector2.new(0, math.max(0, uiLayout.AbsoluteContentSize.Y))
    end)
end)

-- Input
local inputFrame = rootFrame:FindFirstChild("a_chat_input") or Instance.new("Frame")
inputFrame.Name = "a_chat_input"
inputFrame.Size = UDim2.new(1,0,0,44)
inputFrame.Position = UDim2.new(0,0,0.82,0)
inputFrame.BackgroundTransparency = 1
inputFrame.Parent = rootFrame

local chatBox = inputFrame:FindFirstChild("ChatBox")
if not chatBox then
    chatBox = Instance.new("TextBox")
    chatBox.Name = "ChatBox"
    chatBox.Size = UDim2.new(0.75, -8, 1, 0)
    chatBox.Position = UDim2.new(0,6,0,0)
    chatBox.PlaceholderText = "Ask anything... (use / for commands)"
    chatBox.ClearTextOnFocus = false
    chatBox.Text = ""
    chatBox.Font = Enum.Font.SourceSans
    chatBox.TextSize = 16
    chatBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
    chatBox.TextColor3 = Color3.fromRGB(255,255,255)
    chatBox.Parent = inputFrame
end

local sendBtn = inputFrame:FindFirstChild("SendBtn")
if not sendBtn then
    sendBtn = Instance.new("TextButton")
    sendBtn.Name = "SendBtn"
    sendBtn.Size = UDim2.new(0.25, -8, 1, 0)
    sendBtn.Position = UDim2.new(0.75, 4, 0, 0)
    sendBtn.Text = "Send"
    sendBtn.TextScaled = true
    sendBtn.BackgroundColor3 = Color3.fromRGB(86,170,255)
    sendBtn.TextColor3 = Color3.fromRGB(255,255,255)
    sendBtn.Parent = inputFrame
end

-- Top row for API/project
local topRow = gptBack:FindFirstChild("TopRow") or Instance.new("Frame")
if not topRow.Parent then
    topRow.Name = "TopRow"; topRow.Size = UDim2.new(1,0,0,40); topRow.Position = UDim2.new(0,0,0,0); topRow.BackgroundTransparency = 1; topRow.Parent = gptBack
end
local function makeRow(parent, id, placeholder, btnText, side)
    local f = Instance.new("Frame"); f.Name = id .. "_frame"; f.Size = UDim2.new(0.5, -6, 1, 0); f.Position = UDim2.new((side==2) and 0.5 or 0, 6, 0, 0); f.BackgroundTransparency = 1; f.Parent = parent
    local box = Instance.new("TextBox"); box.Name = id .. "_box"; box.Size = UDim2.new(0.75, 0, 1, 0); box.Position = UDim2.new(0,0,0,0); box.PlaceholderText = placeholder; box.Text = ""; box.ClearTextOnFocus = false; box.Font = Enum.Font.SourceSans; box.TextSize = 14; box.BackgroundColor3 = Color3.fromRGB(40,40,40); box.TextColor3 = Color3.fromRGB(255,255,255); box.Parent = f
    local btn = Instance.new("TextButton"); btn.Name = id .. "_btn"; btn.Size = UDim2.new(0.25, 0, 1, 0); btn.Position = UDim2.new(0.75, 0, 0, 0); btn.Text = btnText; btn.TextScaled = true; btn.BackgroundColor3 = Color3.fromRGB(86,170,255); btn.TextColor3 = Color3.fromRGB(255,255,255); btn.Parent = f
    return f, box, btn
end
local f1, projBox, projBtn = makeRow(topRow, "a_proj_input", "Enter Project ID (proj_x...)", "Next", 1)
local f2, apiBox, apiBtn   = makeRow(topRow, "a_api_input",  "Enter API key (sk-...)", "Save", 2)

-- Append helpers
local chatCount = 0
local function appendChat(isUser, text, colorTbl)
    chatCount = chatCount + 1
    local fr = Instance.new("Frame")
    fr.Name = "ChatItem_"..chatCount
    fr.BackgroundTransparency = 1
    fr.Size = UDim2.new(1,0,0,0)
    fr.AutomaticSize = Enum.AutomaticSize.Y
    fr.Parent = gptChat

    local lbl = Instance.new("TextLabel")
    lbl.Name = "ChatLabel"
    lbl.Size = UDim2.new(1, -16, 0, 0)
    lbl.Position = UDim2.new(0, 8, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.TextWrapped = true
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 18
    lbl.RichText = false
    lbl.Text = tostring(text or "")
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    if colorTbl and type(colorTbl) == "table" then
        pcall(function() lbl.TextColor3 = Color3.fromRGB(colorTbl[1], colorTbl[2], colorTbl[3]) end)
    else
        if isUser then lbl.TextColor3 = Color3.fromRGB(86,170,255) else lbl.TextColor3 = Color3.fromRGB(255,255,255) end
    end
    lbl.Parent = fr

    task.defer(function()
        pcall(function()
            gptScroll.CanvasSize = UDim2.new(0,0,0,uiLayout.AbsoluteContentSize.Y)
            gptScroll.CanvasPosition = Vector2.new(0, uiLayout.AbsoluteContentSize.Y)
        end)
    end)
    return fr, lbl
end
local function appendSystem(msg) appendChat(false, "[System] "..tostring(msg), {200,200,255}) end
local function appendError(msg) appendChat(false, "[Error] "..tostring(msg), {255,80,80}) end
local function appendDebug(msg) if STATE.debug then appendChat(false, "[Debug] "..tostring(msg), {200,200,200}) end end

-- parse color string "r,g,b"
local function parseColorStr(s)
    if not s then return nil end
    local nums = {}
    for n in s:gmatch("%-?%d+%.?%d*") do table.insert(nums, tonumber(n)) end
    if #nums >= 3 then
        return Color3.fromRGB(math.clamp(math.floor(nums[1]+0.5),0,255),
                              math.clamp(math.floor(nums[2]+0.5),0,255),
                              math.clamp(math.floor(nums[3]+0.5),0,255))
    end
    return nil
end

-- ----- Unified /Ins processing function -----
local function processInsTable(data)
    if not data then appendError("Ins: no data provided."); return end
    local className = trim(data.Class or data.Type or "") or ""
    if className == "" then className = "Part" end
    local name = trim(data.Name or "") or (className .. "_inst")
    local parentLocate = trim(data.Parent or data.ParentLocate or "") or ""
    local parent = Workspace
    if parentLocate ~= "" then
        local p, err = resolveLocate(parentLocate)
        if not p then appendError("Ins: cannot resolve Parent: "..tostring(err)); return end
        parent = p
    end

    local ok, inst = pcall(function() return Instance.new(className) end)
    if not ok or not inst then appendError("Ins: failed to create class '"..tostring(className).."'."); return end
    pcall(function() inst.Name = name end)
    pcall(function() inst.Parent = parent end)

    -- Position
    if data.Position and data.Position ~= "" then
        local vec, err = safeEval(data.Position)
        if vec and typeof(vec) == "Vector3" then
            pcall(function() if inst:IsA("BasePart") then inst.CFrame = CFrame.new(vec) end end)
        else appendDebug("Ins: Position parse failed: "..tostring(err)) end
    end
    -- Size
    if data.Size and data.Size ~= "" then
        local vec, err = safeEval(data.Size)
        if vec and typeof(vec) == "Vector3" then pcall(function() if inst:IsA("BasePart") then inst.Size = vec end end) else appendDebug("Ins: Size parse failed: "..tostring(err)) end
    end
    -- Color
    if data.Color and data.Color ~= "" then
        local col = nil
        local okc, errc = pcall(function() col = safeEval(data.Color) end)
        if not col then col = parseColorStr(data.Color) end
        if col and typeof(col) == "Color3" then pcall(function() applyColorToObject(inst, col) end) end
    end

    -- Mesh (if provided)
    if (data.MeshId and data.MeshId ~= "") or (data.MeshShape and data.MeshShape ~= "") then
        if inst:IsA("BasePart") then
            local mesh = Instance.new("SpecialMesh")
            pcall(function()
                if data.MeshId and data.MeshId ~= "" then mesh.MeshId = tostring(data.MeshId); mesh.MeshType = Enum.MeshType.FileMesh
                else
                    local s = tostring(data.MeshShape or ""):gsub("%s+","")
                    local okm, enumVal = pcall(function() return Enum.MeshType[s] end)
                    if okm and enumVal then mesh.MeshType = enumVal else mesh.MeshType = Enum.MeshType.Brick end
                end
                if data.MeshScale and data.MeshScale ~= "" then
                    local ms, err = safeEval(data.MeshScale)
                    if ms and typeof(ms) == "Vector3" then mesh.Scale = ms end
                end
                if data.MeshTexture and data.MeshTexture ~= "" then mesh.TextureId = tostring(data.MeshTexture) end
            end)
            mesh.Parent = inst
        else appendDebug("Ins: Mesh requested but object not BasePart.") end
    end

    -- Decal
    if data.DecalId and data.DecalId ~= "" then
        local parentDecal = inst
        if not parentDecal:IsA("BasePart") then
            local partChild = parentDecal:FindFirstChildOfClass("BasePart") or parentDecal:FindFirstChild("Handle")
            if partChild then parentDecal = partChild end
        end
        if parentDecal and parentDecal:IsA("BasePart") then
            local d = Instance.new("Decal")
            d.Texture = tostring(data.DecalId)
            d.Transparency = tonumber(data.DecalTransparency) or 0
            d.Parent = parentDecal
        else appendDebug("Ins: Decal not inserted - target not a BasePart.") end
    end

    -- SurfaceGui / TextLabel
    if (data.SurfaceDirection and data.SurfaceDirection ~= "") or (data.SurfaceText and data.SurfaceText ~= "") then
        local targetPart = inst
        if not targetPart:IsA("BasePart") then
            local fp = inst:FindFirstChildOfClass("BasePart")
            if fp then targetPart = fp end
        end
        if targetPart and targetPart:IsA("BasePart") then
            local sg = Instance.new("SurfaceGui")
            local face = (data.SurfaceDirection and data.SurfaceDirection ~= "" and (Enum.NormalId[data.SurfaceDirection] or Enum.NormalId.Front)) or Enum.NormalId.Front
            pcall(function() sg.Face = face end)
            sg.Parent = targetPart
            if data.SurfaceText and data.SurfaceText ~= "" then
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1,0,1,0)
                lbl.Text = tostring(data.SurfaceText or "")
                lbl.TextScaled = (tostring(data.SurfaceTextScaled or ""):lower() == "true")
                local col = parseColorStr(tostring(data.SurfaceTextColor or "255,255,255"))
                if col then pcall(function() lbl.TextColor3 = col end) end
                lbl.TextSize = tonumber(data.SurfaceTextSize) or 14
                local okf, fenum = pcall(function() return Enum.Font[tostring(data.SurfaceTextFont or "SourceSans")] end)
                if okf and fenum then lbl.Font = fenum else lbl.Font = Enum.Font.SourceSans end
                lbl.TextWrapped = (tostring(data.SurfaceTextWrapped or "true"):lower() ~= "false")
                lbl.RichText = (tostring(data.SurfaceTextRich or "false"):lower() == "true")
                lbl.Parent = sg
            end
        else appendDebug("Ins: SurfaceGui fields provided but target is not BasePart.") end
    end

    -- Effects: ParticleEmitter or PointLight
    if data.EffectType and data.EffectType ~= "" then
        local typ = tostring(data.EffectType):lower()
        local targetParent = inst
        if typ:find("particle") then
            local pe = Instance.new("ParticleEmitter")
            if data.EffectColor and data.EffectColor ~= "" then
                local col = parseColorStr(data.EffectColor)
                if col then pcall(function() pe.Color = ColorSequence.new(col) end) end
            end
            if data.EffectSize and data.EffectSize ~= "" then
                local s,e = safeEval(data.EffectSize)
                if s and typeof(s) == "number" then pcall(function() pe.Size = NumberSequence.new(s) end) end
            end
            pe.Parent = targetParent
        elseif typ:find("light") then
            local li = Instance.new("PointLight")
            li.Brightness = tonumber(data.LightBrightness) or 1
            li.Range = tonumber(data.LightRange) or 8
            li.Parent = targetParent
        end
    end

    -- More options
    if data.MoreDestroy and tostring(data.MoreDestroy):lower():find("true") then
        task.spawn(function() task.wait(0.2); pcall(function() inst:Destroy() end) end)
    end
    if data.MoreReName and data.MoreReName ~= "" then pcall(function() inst.Name = tostring(data.MoreReName) end) end
    if data.MoreReColor and data.MoreReColor ~= "" then
        local c = parseColorStr(tostring(data.MoreReColor))
        if c then pcall(function() applyColorToObject(inst, c) end) end
    end
    if data.MoreRePos and data.MoreRePos ~= "" then
        local v,err = safeEval(data.MoreRePos)
        if v and typeof(v) == "Vector3" then pcall(function() if inst:IsA("BasePart") then inst.CFrame = CFrame.new(v) end end) end
    end

    appendSystem(("Ins: Created %s named '%s' under %s"):format(tostring(className), tostring(name), tostring(parent and (parent.Name or tostring(parent)) or "Workspace")))
end

-- Build interactive input UI appended in chat: appendInput creates a panel with many TextBoxes + Done
local function appendInput()
    -- container frame similar sizing to chat entries
    local frame = Instance.new("Frame")
    frame.Name = "InsInputPanel"
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1,0,0,0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.Parent = gptChat

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0.96,0,0,200)
    container.Position = UDim2.new(0.02,0,0,6)
    container.BackgroundColor3 = Color3.fromRGB(30,30,30)
    container.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Parent = container
    layout.Padding = UDim.new(0,4)

    local function makeField(labelTxt, placeholder)
        local fldFr = Instance.new("Frame")
        fldFr.Size = UDim2.new(1,0,0,30); fldFr.BackgroundTransparency = 1; fldFr.Parent = container
        local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.28,0,1,0); lbl.Position = UDim2.new(0,4,0,0); lbl.BackgroundTransparency = 1; lbl.Text = labelTxt; lbl.Font = Enum.Font.SourceSans; lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextColor3 = Color3.fromRGB(200,200,200); lbl.Parent = fldFr
        local tb = Instance.new("TextBox"); tb.Size = UDim2.new(0.7,-8,1,0); tb.Position = UDim2.new(0.3,4,0,0); tb.PlaceholderText = placeholder or ""; tb.Text = ""; tb.ClearTextOnFocus = false; tb.Font = Enum.Font.SourceSans; tb.TextSize = 14; tb.BackgroundColor3 = Color3.fromRGB(40,40,40); tb.TextColor3 = Color3.fromRGB(255,255,255); tb.Parent = fldFr
        return tb
    end

    -- Basic section (fields)
    local tbType = makeField("Type (Class)","Part, Model, Folder, etc. (default Part)")
    local tbVector = makeField("Vector (Position)","Vector3(0,5,0)")
    local tbName = makeField("Name","MyPart")
    local tbSpawn = makeField("Position/Spawn","use 'spawn' or Vector3(...)")
    local tbColor = makeField("Color (r,g,b or Color3.fromRGB)","255,255,255 or Color3.fromRGB(...)")
    local tbParent = makeField("Parent (locate)","game.Workspace.MyFolder or Workspace")
    -- Mesh
    local tbMeshShape = makeField("Mesh Shape","Brick,Sphere,FileMesh")
    local tbMeshSize = makeField("Mesh Size","Vector3(1,1,1)")
    local tbMeshOffset = makeField("Mesh Offset","Vector3(0,0,0)")
    local tbMeshId = makeField("Mesh ID","rbxassetid://12345 or 12345")
    local tbMeshTexture = makeField("Mesh Texture","rbxassetid://...")
    local tbMeshColor = makeField("Mesh Color","255,255,255")
    -- Effect
    local tbEffectSize = makeField("Effect Size","0.5 or Vector3 or Number")
    local tbEffectColor = makeField("Effect Color","255,200,200")
    local tbLightBrightness = makeField("Light Brightness","1")
    local tbLightAngle = makeField("Light Angle","0")
    local tbLightArea = makeField("Light Area","1")
    -- Surface / Decal / TextLabel
    local tbDecalID = makeField("Decal/Texture ID","rbxassetid://...")
    local tbDecalTrans = makeField("Decal Transparency","0")
    local tbSurfaceDir = makeField("Surface Direction","Front,Top,Bottom,Left,Right,Back or ALL")
    local tbSurfaceText = makeField("Surface Text","Hello")
    local tbSurfaceTextScaled = makeField("TextScaled true/false","true")
    local tbSurfaceTextColor = makeField("Text Color","255,255,255")
    local tbSurfaceTextSize = makeField("Text Size","18")
    local tbSurfaceTextFont = makeField("Text Font","SourceSans")
    local tbSurfaceTextWrap = makeField("TextWrapped true/false","true")
    local tbSurfaceTextRich = makeField("Text Rich true/false","false")
    -- SurfaceGui UDim2
    local tbUDim2Vec = makeField("UDim2 Vector","UDim2.new(0,0,0,0)")
    local tbUDim2Pos = makeField("UDim2 Position","UDim2.new(0,0,0,0)")
    local tbBgColor = makeField("BG Color","255,255,255")
    local tbBgTrans = makeField("BG Transparency","0")
    -- More options
    local tbTarget = makeField("More Target (locate)","game.Workspace.Part")
    local tbMoreDestroy = makeField("Destroy after (true/false)","false")
    local tbMoreRePos = makeField("RePosition Vector3","Vector3(0,0,0)")
    local tbMoreReColor = makeField("ReColor r,g,b","255,255,255")
    local tbMoreRename = makeField("Rename to","NewName")
    -- Done button
    local doneBtn = Instance.new("TextButton")
    doneBtn.Size = UDim2.new(1,0,0,28)
    doneBtn.Text = "Done (Create Instance)"
    doneBtn.Font = Enum.Font.SourceSans
    doneBtn.TextSize = 16
    doneBtn.BackgroundColor3 = Color3.fromRGB(86,170,255)
    doneBtn.TextColor3 = Color3.fromRGB(255,255,255)
    doneBtn.Parent = container

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(1,0,0,28)
    cancelBtn.Text = "Cancel"
    cancelBtn.Font = Enum.Font.SourceSans
    cancelBtn.TextSize = 16
    cancelBtn.BackgroundColor3 = Color3.fromRGB(120,120,120)
    cancelBtn.TextColor3 = Color3.fromRGB(255,255,255)
    cancelBtn.Parent = container

    doneBtn.MouseButton1Click:Connect(function()
        local data = {
            Class = trim(tbType.Text),
            Position = trim(tbVector.Text ~= "" and tbVector.Text or tbSpawn.Text),
            Name = trim(tbName.Text),
            Color = trim(tbColor.Text),
            Parent = trim(tbParent.Text),
            MeshShape = trim(tbMeshShape.Text),
            MeshScale = trim(tbMeshSize.Text),
            MeshOffset = trim(tbMeshOffset.Text),
            MeshId = trim(tbMeshId.Text),
            MeshTexture = trim(tbMeshTexture.Text),
            MeshColor = trim(tbMeshColor.Text),
            EffectSize = trim(tbEffectSize.Text),
            EffectColor = trim(tbEffectColor.Text),
            LightBrightness = trim(tbLightBrightness.Text),
            LightRange = trim(tbLightArea.Text),
            DecalId = trim(tbDecalID.Text),
            DecalTransparency = trim(tbDecalTrans.Text),
            SurfaceDirection = trim(tbSurfaceDir.Text),
            SurfaceText = trim(tbSurfaceText.Text),
            SurfaceTextScaled = trim(tbSurfaceTextScaled.Text),
            SurfaceTextColor = trim(tbSurfaceTextColor.Text),
            SurfaceTextSize = trim(tbSurfaceTextSize.Text),
            SurfaceTextFont = trim(tbSurfaceTextFont.Text),
            SurfaceTextWrapped = trim(tbSurfaceTextWrap.Text),
            SurfaceTextRich = trim(tbSurfaceTextRich.Text),
            UDim2Vector = trim(tbUDim2Vec.Text),
            UDim2Position = trim(tbUDim2Pos.Text),
            BackgroundColor = trim(tbBgColor.Text),
            BackgroundTransparency = trim(tbBgTrans.Text),
            MoreTarget = trim(tbTarget.Text),
            MoreDestroy = trim(tbMoreDestroy.Text),
            MoreRePos = trim(tbMoreRePos.Text),
            MoreReColor = trim(tbMoreReColor.Text),
            MoreReName = trim(tbMoreRename.Text),
        }
        processInsTable(data)
        pcall(function() frame:Destroy() end)
    end)
    cancelBtn.MouseButton1Click:Connect(function() pcall(function() frame:Destroy() end) end)

    task.defer(function()
        pcall(function()
            gptScroll.CanvasSize = UDim2.new(0,0,0,uiLayout.AbsoluteContentSize.Y)
            gptScroll.CanvasPosition = Vector2.new(0, uiLayout.AbsoluteContentSize.Y)
        end)
    end)
end

-- parse parentheses args quick /Ins("Class:Part","Name:MyPart",...)
local function parseInsArgs(rest)
    local inside = rest:match("%((.*)%)")
    if not inside then return {} end
    local parts = {}
    local cur = ""
    local depth = 0
    for i=1,#inside do
        local ch = inside:sub(i,i)
        if ch == "," and depth == 0 then table.insert(parts, trim(cur)); cur = "" else cur = cur..ch end
        if ch == "(" then depth = depth + 1 end
        if ch == ")" then depth = math.max(0, depth-1) end
    end
    if trim(cur) ~= "" then table.insert(parts, trim(cur)) end
    local data = {}
    for _,p in ipairs(parts) do
        p = p:gsub('^%s*"', ""):gsub('"%s*$', ""):gsub("^%s*'",""):gsub("'%s*$","")
        local k,v = p:match("^([^:]+):(.+)$")
        if k and v then data[ trim(k) ] = trim(v) else
            if not data[1] then data[1] = trim(p) elseif not data[2] then data[2] = trim(p) elseif not data[3] then data[3] = trim(p) elseif not data.Position then data.Position = trim(p) end
        end
    end
    if data[1] and not data.Class then data.Class = data[1] end
    if data[2] and not data.Name then data.Name = data[2] end
    if data[3] and not data.Parent then data.Parent = data[3] end
    return data
end

-- Command helpers: parentheses split, player find
local function try_parse_parentheses_content(txt)
    local inside = txt:match("%((.*)%)")
    if inside then inside = inside:gsub('^%s*"', ""):gsub('"%s*$', ""):gsub("^%s*'",""):gsub("'%s*$","") return trim(inside) end
    return nil
end
local function split_args_parentheses(s)
    local inside = s:match("%((.*)%)") if not inside then return {} end
    local parts = {} local cur = "" local depth = 0
    for i = 1, #inside do
        local ch = inside:sub(i,i)
        if ch == "," and depth == 0 then table.insert(parts, trim(cur)); cur = "" else cur = cur .. ch end
        if ch == "(" then depth = depth + 1 end
        if ch == ")" then depth = math.max(0, depth - 1) end
    end
    if trim(cur) ~= "" then table.insert(parts, trim(cur)) end
    for i,p in ipairs(parts) do parts[i] = p:gsub('^%s*"',''):gsub('"%s*$',''):gsub("^%s*'",""):gsub("'%s*$","") end
    return parts
end
local function checkPlayerByName(name)
    if not name or name == "" then return nil end
    name = trim(name)
    local p = Players:FindFirstChild(name)
    if p then return p end
    for _,pl in ipairs(Players:GetPlayers()) do if pl.Name:lower():find(name:lower()) then return pl end end
    return nil
end

-- Command handler (many commands kept)
function handleCommand(rawText)
    if not rawText or rawText == "" then return false end
    local t = tostring(rawText)
    if t:sub(1,1) ~= "/" then return false end
    local cmd, rest = t:match("^/(%S+)%s*(.*)$")
    cmd = (cmd or ""):upper()
    rest = rest or ""

    -- API / PROJECT
    if cmd == "API" then local inside = try_parse_parentheses_content(rest) or trim(rest) if inside=="" then appendSystem('Usage: /API ("sk-...")') return true end STATE.OPENAI_KEY = inside; STATE.validated = false; appendSystem(("API set (client-side): %s"):format(redactKey(STATE.OPENAI_KEY))); return true end
    if cmd == "UNSAVEAPI" then STATE.OPENAI_KEY = nil; appendSystem("API cleared."); return true end
    if cmd == "APIJ" then local inside = try_parse_parentheses_content(rest) or trim(rest) if inside=="" then appendSystem('Usage: /APIJ ("proj_...")') return true end STATE.PROJECT_ID = inside; appendSystem("Project ID set."); return true end
    if cmd == "UNSAVEAPIJ" or cmd == "NOAPIJ" then STATE.PROJECT_ID = nil; appendSystem("Project ID cleared."); return true end

    -- Http commands
    if cmd == "HTTPSERVICE" then local ok, enabled = pcall(function() return HttpService.HttpEnabled end); appendSystem(("HttpEnabled = %s (pcall ok=%s)"):format(tostring(enabled), tostring(ok))); return true end
    if cmd == "HTTPENABLED" then local v = trim(rest):lower() if v~="true" and v~="false" then appendSystem('Usage: /HttpEnabled true|false') return true end local desired=(v=="true") local succ,err = pcall(function() HttpService.HttpEnabled = desired end) local actual=nil; pcall(function() actual = HttpService.HttpEnabled end) if succ then appendSystem(("Set HttpEnabled -> current: %s"):format(tostring(actual))) else appendError(("Set HttpEnabled failed: %s | current: %s"):format(tostring(err), tostring(actual))) end return true end
    if cmd == "HTTPASYNC" then local v = trim(rest):lower() if v~="true" and v~="false" then appendSystem('Usage: /HttpAsync true|false') return true end STATE.HttpAsync=(v=="true"); appendSystem("HttpAsync set to "..tostring(STATE.HttpAsync)); return true end
    if cmd == "HTTPSTATE" then local urlRaw = try_parse_parentheses_content(rest) or trim(rest) if urlRaw=="" then appendSystem('Usage: /HttpState ("example.com")') return true end local url=(urlRaw:match("^https?://") and urlRaw) or ("https://"..urlRaw); appendSystem("Checking "..url.." ...") local ok,resp = pcall(function() return HttpService:RequestAsync({Url=url, Method="GET", Timeout=8}) end) if not ok then appendError("Http request failed: "..tostring(resp)); return true end if not resp then appendError("No response"); return true end appendSystem(("HTTP status: %s | Success: %s"):format(tostring(resp.StatusCode), tostring(resp.Success))); return true end

    -- Keep notes
    if cmd == "KEEP" then local content = try_parse_parentheses_content(rest) or trim(rest) if content=="" then appendSystem('Usage: /Keep ("text")') return true end table.insert(STATE._keeps, content); appendSystem(("Saved note #%d"):format(#STATE._keeps)); return true end
    if cmd == "SHOWKEEP" then if #STATE._keeps==0 then appendSystem("No saved notes.") else appendSystem("Saved notes:") for i,v in ipairs(STATE._keeps) do appendChat(false, ("#%d: %s"):format(i,tostring(v)), {200,200,255}) end end return true end
    if cmd == "CLEARALLKEEP" or cmd == "CAK" or cmd == "CLEARKEEP" then STATE._keeps = {}; appendSystem("All saved notes cleared."); return true end

    -- Clear GPT chat UI
    if cmd == "CLEARTEXTS" then for _,c in ipairs(gptChat:GetChildren()) do if c:IsA("Frame") then pcall(function() c:Destroy() end) end end appendSystem("Cleared GPT chat UI."); return true end

    -- Leave / Reset
    if cmd == "LEAVEGAME" or cmd == "EXIT" then appendSystem("Leaving game..."); pcall(function() LocalPlayer:Kick("") end); return true end
    if cmd == "RESET" or cmd == "RE" then local ch = LocalPlayer and LocalPlayer.Character if ch then local hum = ch:FindFirstChildOfClass("Humanoid") if hum then pcall(function() hum.Health = 0 end) appendSystem("Character reset.") else pcall(function() ch:BreakJoints() end) appendSystem("Character broken.") end return true end appendSystem("No character to reset.") return true end

    -- View / UnView
    if cmd == "VIEW" or cmd == "SPY" then
        local inside = try_parse_parentheses_content(rest) or trim(rest)
        if inside == "" then appendSystem('Usage: /View ("pla:Name" or "obj:locate")'); return true end
        local targetName = inside
        if targetName:sub(1,4):lower() == "pla:" then targetName = targetName:sub(5) end
        if targetName:sub(1,4):lower() == "obj:" then targetName = targetName:sub(5) end
        local pl = checkPlayerByName(targetName)
        if pl and pl.Character then
            local hrp = pl.Character:FindFirstChild("HumanoidRootPart") or pl.Character.PrimaryPart
            if not hrp then appendError("Player has no HRP."); return true end
            if rootFrame._viewConn and rootFrame._viewConn.Connected then pcall(function() rootFrame._viewConn:Disconnect() end) end
            local cam = workspace.CurrentCamera
            rootFrame._prevCamType = cam.CameraType; rootFrame._prevCamSubject = cam.CameraSubject
            rootFrame._viewConn = RunService.RenderStepped:Connect(function()
                if not hrp or not hrp.Parent then if rootFrame._viewConn then rootFrame._viewConn:Disconnect(); rootFrame._viewConn = nil end return end
                pcall(function() cam.CameraType = Enum.CameraType.Scriptable; cam.CFrame = hrp.CFrame * CFrame.new(0,2,6) end)
            end)
            appendSystem(("Viewing player %s (use /UnView)"):format(pl.Name))
            return true
        end
        local obj, err = resolveLocate(targetName)
        if obj then
            local hrp = (obj:IsA("Model") and (obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart)) or (obj:IsA("BasePart") and obj)
            if not hrp then appendError("Object not viewable."); return true end
            if rootFrame._viewConn and rootFrame._viewConn.Connected then pcall(function() rootFrame._viewConn:Disconnect() end) end
            local cam = workspace.CurrentCamera
            rootFrame._prevCamType = cam.CameraType; rootFrame._prevCamSubject = cam.CameraSubject
            rootFrame._viewConn = RunService.RenderStepped:Connect(function()
                if not hrp or not hrp.Parent then if rootFrame._viewConn then rootFrame._viewConn:Disconnect(); rootFrame._viewConn = nil end return end
                pcall(function() cam.CameraType = Enum.CameraType.Scriptable; cam.CFrame = hrp.CFrame * CFrame.new(0,2,6) end)
            end)
            appendSystem(("Viewing object %s (use /UnView)"):format(tostring(targetName)))
            return true
        end
        appendError("Player/object not found.")
        return true
    end
    if cmd == "UNVIEW" or cmd == "UNSPY" then
        if rootFrame._viewConn then pcall(function() rootFrame._viewConn:Disconnect() end); rootFrame._viewConn = nil end
        local cam = workspace.CurrentCamera
        pcall(function() cam.CameraType = rootFrame._prevCamType or Enum.CameraType.Custom; cam.CameraSubject = rootFrame._prevCamSubject or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")) end)
        appendSystem("Camera restored.")
        return true
    end

    -- SeeChat enable/disable (improved)
    local function bindPlayerChat(p)
        if not p or not p.Parent then return end
        pcall(function()
            if p.Chatted then
                local conn = p.Chatted:Connect(function(msg)
                    local col = {255,255,255}
                    pcall(function()
                        if p.Team and p.Team.TeamColor then
                            local tc = p.Team.TeamColor.Color
                            col = { math.floor(tc.R*255+0.5), math.floor(tc.G*255+0.5), math.floor(tc.B*255+0.5) }
                        end
                    end)
                    appendChat(false, ("[%s]: %s"):format(p.Name, tostring(msg)), col)
                end)
                if conn then STATE.seeChatConns[p] = conn end
            end
        end)
    end
    local function enableSeeChat()
        if STATE.seeChatEnabled then appendSystem("SeeChat already enabled."); return end
        STATE.seeChatEnabled = true
        STATE.seeChatConns = {}
        for _,p in ipairs(Players:GetPlayers()) do bindPlayerChat(p) end
        STATE._playerAddedConn = Players.PlayerAdded:Connect(bindPlayerChat)
        -- hook DefaultChatSystemChatEvents.OnMessageDoneFiltering if present (more reliable, provides speaker & color)
        pcall(function()
            local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if chatEvents and chatEvents:FindFirstChild("OnMessageDoneFiltering") then
                STATE._chatEventConn = chatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(msgData)
                    pcall(function()
                        if type(msgData) == "table" and msgData.FromSpeaker and msgData.Message then
                            local pl = Players:FindFirstChild(msgData.FromSpeaker)
                            local col = {200,200,200}
                            if pl and pl.Team and pl.Team.TeamColor then
                                local tc = pl.Team.TeamColor.Color
                                col = { math.floor(tc.R*255+0.5), math.floor(tc.G*255+0.5), math.floor(tc.B*255+0.5) }
                            end
                            appendChat(false, ("[%s]: %s"):format(msgData.FromSpeaker, msgData.Message), col)
                        elseif type(msgData) == "table" and msgData.FromSpeaker and msgData.Message and type(msgData.Message)=="string" then
                            appendChat(false, ("[%s]: %s"):format(tostring(msgData.FromSpeaker), tostring(msgData.Message)), {200,200,200})
                        end
                    end)
                end)
            end
        end)
        appendSystem("SeeChat enabled.")
    end
    local function disableSeeChat()
        if not STATE.seeChatEnabled then appendSystem("SeeChat not enabled."); return end
        STATE.seeChatEnabled = false
        if STATE._playerAddedConn then pcall(function() STATE._playerAddedConn:Disconnect() end); STATE._playerAddedConn = nil end
        if STATE._chatEventConn then pcall(function() STATE._chatEventConn:Disconnect() end); STATE._chatEventConn = nil end
        for p,conn in pairs(STATE.seeChatConns or {}) do pcall(function() conn:Disconnect() end) end
        STATE.seeChatConns = {}
        appendSystem("SeeChat disabled.")
    end
    if cmd == "SEECHAT" or cmd == "ENACHAT" or cmd == "ENABLECHAT" then enableSeeChat(); return true end
    if cmd == "UNSEECHAT" or cmd == "UNENACHAT" or cmd == "UNENABLECHAT" then disableSeeChat(); return true end

    -- /Ins unified (interactive OR quick args)
    if cmd == "INS" then
        local data = parseInsArgs(rest)
        if next(data) then
            processInsTable(data)
            return true
        else
            appendInput()
            appendSystem("Fill input panel and click Done to create instance.")
            return true
        end
    end

    -- Destroy / Resize / Position / Color
    if cmd == "DESTROY" then local args = split_args_parentheses(rest) if #args < 1 then appendSystem('Usage: /Destroy ("locate" or "Name")') return true end local targetStr = args[1] local obj, err = resolveLocate(targetStr) if not obj then obj = findObjectByName(targetStr) end if not obj then appendError("Object not found: "..tostring(err)) return true end pcall(function() obj:Destroy() end) appendSystem(("Destroyed %s"):format(tostring(targetStr))) return true end
    if cmd == "RESIZE" or cmd == "RES" then local args = split_args_parentheses(rest) if #args < 2 then appendSystem('Usage: /Resize ("locate","Vector3(x,y,z)")') return true end local locate,vecStr=args[1],args[2] local obj,err=resolveLocate(locate) if not obj then appendError("Locate failed: "..tostring(err)) return true end local vec,verr=safeEval(vecStr) if not vec or typeof(vec)~="Vector3" then appendError("Vector parse failed.") return true end pcall(function() if obj:IsA("BasePart") then obj.Size = vec end end) appendSystem(("Resized %s to %s"):format(tostring(locate), tostring(vec))) return true end
    if cmd == "POSITION" or cmd == "REPOS" or cmd == "REPOSITION" then local args = split_args_parentheses(rest) if #args < 2 then appendSystem('Usage: /Position ("locate","Vector3(x,y,z)")') return true end local locate,vecStr = args[1],args[2] local obj,err = resolveLocate(locate) if not obj then appendError("Locate failed: "..tostring(err)) return true end local vec,verr = safeEval(vecStr) if not vec or typeof(vec) ~= "Vector3" then appendError("Vector parse failed.") return true end pcall(function() if obj:IsA("BasePart") then obj.CFrame = CFrame.new(vec) end end) appendSystem(("Moved %s to %s"):format(tostring(locate), tostring(vec))) return true end
    if cmd == "COLOR" or cmd == "RECOLOR" then local args = split_args_parentheses(rest) if #args < 2 then appendSystem('Usage: /Color ("locate","Color3.fromRGB(255,0,0)")') return true end local locate,colorStr = args[1],args[2] local obj,err = resolveLocate(locate) if not obj then appendError("Locate failed: "..tostring(err)) return true end local col,cerr = safeEval(colorStr) if not col then col = parseColorStr(colorStr) end if not col or typeof(col) ~= "Color3" then appendError("Color parse failed."); return true end applyColorToObject(obj, col) appendSystem(("Color set for %s"):format(tostring(locate))) return true end

    -- Teleport (client-side)
    if cmd == "TP" or cmd == "TELEPORT" then local inside = try_parse_parentheses_content(rest) or trim(rest) if inside=="" then appendSystem('Usage: /TP ("Vector3(x,y,z)")') return true end local vec,err = safeEval(inside) if not vec or typeof(vec)~="Vector3" then appendError("Vector parse failed: "..tostring(err)) return true end local ch = LocalPlayer and LocalPlayer.Character if ch then local rootPart = ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart if rootPart then pcall(function() rootPart.CFrame = CFrame.new(vec) end) appendSystem("Teleported.") else appendError("No root part.") end else appendError("No character.") end return true end

    -- Rejoin
    if cmd == "REJOIN" or cmd == "RJ" then appendSystem("Rejoining...") pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end) return true end

    -- ServerHop (uses Roblox API)
    if cmd == "SERVERHOP" or cmd == "SH" then
        local inside = try_parse_parentheses_content(rest) or trim(rest)
        local limit = tonumber((inside or ""):match("plalimit:(%d+)")) or tonumber(inside) or 8
        appendSystem(("ServerHop: searching servers with players < %d ..."):format(limit))
        local url = ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100"):format(tostring(game.PlaceId))
        local ok, body = pcall(function() return HttpService:GetAsync(url, true) end)
        if not ok or type(body) ~= "string" then appendError("Server list fetch failed: "..tostring(body)); return true end
        local ok2, data = pcall(function() return HttpService:JSONDecode(body) end)
        if not ok2 or not data or not data.data then appendError("Invalid server data."); return true end
        for _,server in ipairs(data.data) do
            if server.id and (server.playing or 0) < limit and server.id ~= game.JobId then
                appendSystem(("Hopping to server %s (%d players)..."):format(tostring(server.id), server.playing or 0))
                pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer) end)
                return true
            end
        end
        appendError("No suitable server found.")
        return true
    end

    -- Autobot improved (modes: Walk/Jump/Spin/Dance/Random/Stop)
    local function autobotStart(mode)
        if STATE.autobot.enabled then appendSystem("Autobot already running."); return end
        STATE.autobot.enabled = true; STATE.autobot.mode = mode or "Random"; appendSystem("Autobot starting: "..STATE.autobot.mode)
        STATE.autobot.task = task.spawn(function()
            local emotes = {"dance","wave","cheer","laugh","point"}
            while STATE.autobot.enabled do
                local ch = LocalPlayer and LocalPlayer.Character
                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                local root = ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart)
                if hum and root then
                    local action = STATE.autobot.mode
                    if action == "Random" then
                        local pick = math.random(1,10)
                        if pick <= 4 then action = "Walk"
                        elseif pick <= 6 then action = "Jump"
                        elseif pick <= 8 then action = "Spin"
                        else action = "Dance" end
                    end
                    if action == "Walk" then
                        local dir = Vector3.new((math.random()-0.5)*12, 0, (math.random()-0.5)*12)
                        local target = root.Position + dir
                        pcall(function() hum:MoveTo(target) end)
                        task.wait(math.random(1,10))
                    elseif action == "Jump" then
                        -- some games block simulated keypress; using humanoid.Jump is more reliable
                        pcall(function()
                            if math.random() < 0.75 then hum.Jump = true end
                        end)
                        -- small chance to walk after jump
                        if math.random() < 0.4 then
                            local dir = Vector3.new((math.random()-0.5)*6, 0, (math.random()-0.5)*6)
                            pcall(function() hum:MoveTo(root.Position + dir) end)
                        end
                        task.wait(math.random(1,3))
                    elseif action == "Spin" then
                        local speedPercent = math.random(10,50)/100
                        local duration = math.random(1,4)
                        local t0 = tick()
                        while tick() - t0 < duration and STATE.autobot.enabled do
                            pcall(function() root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(30 * speedPercent), 0) end)
                            task.wait(0.05)
                        end
                    elseif action == "Dance" then
                        local em = emotes[math.random(1,#emotes)]
                        pcall(function() LocalPlayer:Chat("/e "..em) end)
                        task.wait(math.random(2,6))
                    else
                        task.wait(math.random(1,4))
                    end
                else
                    task.wait(1)
                end
                task.wait(math.random(1,3))
            end
            appendSystem("Autobot stopped.")
        end)
    end
    local function autobotStop() if not STATE.autobot.enabled then appendSystem("Autobot not running."); return end STATE.autobot.enabled=false; STATE.autobot.task=nil; appendSystem("Autobot stopping...") end
    if cmd == "AUTOBOT" then
        local inside = try_parse_parentheses_content(rest) or trim(rest)
        local mode = inside or "Random"
        mode = mode:gsub("^%s+",""):gsub("%s+$","")
        mode = (mode ~= "" and (mode:sub(1,1):upper() .. mode:sub(2))) or "Random"
        if mode:lower() == "stop" then autobotStop(); return true end
        if mode == "" then appendSystem('Usage: /Autobot [Walk|Jump|Spin|Dance|Random|Stop]'); return true end
        autobotStart(mode); return true
    end

    -- Music command
    if cmd == "MUSIC" then
        local arg = trim(rest)
        local function getOrCreateMusicSound()
            local ch = LocalPlayer and LocalPlayer.Character
            if not ch then return nil, "no_character" end
            local hrp = ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart
            if not hrp then return nil, "no_hrp" end
            local folder = hrp:FindFirstChild("gptMusicPlay")
            if not folder then folder = Instance.new("Folder"); folder.Name="gptMusicPlay"; folder.Parent=hrp end
            local sound = nil
            for _,v in ipairs(folder:GetChildren()) do if v:IsA("Sound") then sound=v; break end end
            if not sound then sound = Instance.new("Sound"); sound.Name="gptMusic"; sound.Volume=1; sound.Looped=false; sound.Parent=folder end
            return sound, nil
        end
        local sound, serr = getOrCreateMusicSound()
        if not sound then appendError("Music: "..tostring(serr)); return true end
        if arg:lower():match("^play:") then
            local id = arg:match("play:ID%((%d+)%)") or arg:match("play:ID%(([^%)]+)%)")
            if not id then appendError('Usage: /Music play:ID(123456)'); return true end
            local asset = "rbxassetid://"..tostring(id)
            pcall(function() sound.SoundId = asset; sound.Looped=false; sound:Play() end)
            appendSystem("Playing music ID: "..tostring(id)); return true
        end
        if arg:lower():match("^do:") then
            local op = arg:match("^do:([%w%(%)%d%s]+)")
            if not op then appendError("Music: unknown do action"); return true end
            op=op:lower()
            if op:find("play") then pcall(function() sound:Play() end); appendSystem("Music play"); return true end
            if op:find("pause") then pcall(function() sound:Pause() end); appendSystem("Music pause"); return true end
            if op:find("stop") then pcall(function() sound:Stop(); sound.SoundId = "" end); appendSystem("Music stopped and cleared"); return true end
            if op:find("restart") then pcall(function() sound:Stop(); sound:Play() end); appendSystem("Music restarted"); return true end
            if op:find("loop") and not op:match("loop%(%d+") then pcall(function() sound.Looped = true end); appendSystem("Music loop enabled"); return true end
            if op:find("unloop") then pcall(function() sound.Looped = false end); appendSystem("Music loop disabled"); return true end
            local loops = op:match("loop%((%d+)%s*times?%)")
            if loops then
                local n = tonumber(loops) or 1
                pcall(function()
                    sound.Looped = false
                    for i=1,n do
                        sound:Play()
                        local t0 = tick()
                        while true do
                            local isPlaying = false
                            pcall(function() isPlaying = sound.IsPlaying end)
                            if not isPlaying or tick()-t0>60 then break end
                            task.wait(0.2)
                        end
                    end
                end)
                appendSystem(("Looped music %d times"):format(n)); return true
            end
            appendError("Music do: unknown option: "..tostring(op)); return true
        end
        if arg:lower():match("^change:") then
            local sub = arg:sub(8)
            local vol = sub:match("Vol%(([%d%.]+)%)")
            local pb = sub:match("Playback%(([%d%.]+)%)")
            if vol then pcall(function() sound.Volume = tonumber(vol) end); appendSystem("Music volume changed -> "..tostring(vol)) end
            if pb then pcall(function() sound.PlaybackSpeed = tonumber(pb) end); appendSystem("Music playback speed changed -> "..tostring(pb)) end
            return true
        end
        appendError("Music command unknown. Use /Music play:ID(123) or /Music do:Play etc."); return true
    end

    -- Console: instruct to press F9 (do not create GUI)
    if cmd == "CONSOLE" then appendSystem("Developer Console: Press F9 in Roblox client (or View -> Developer Console in Studio)."); return true end

    -- TextsCounts
    if cmd == "TEXTSCOUNTS" or cmd == "TEXTSCOUNT" then
        local count = 0
        for _,c in ipairs(gptChat:GetChildren()) do if c:IsA("Frame") and c.Name:match("^ChatItem_%d+") then count = count + 1 end end
        appendSystem(("Total messages in GPT chat: %d"):format(count))
        return true
    end

    -- Help (enumerated)
    if cmd == "HELP" then
        appendSystem("Commands (detailed):")
        local helpLines = {
            '/API ("sk-...") — set OpenAI API key (client-side).',
            '/UnSaveAPI — clear API key from client.',
            '/APIJ ("proj_...") — set Project ID (optional).',
            '/UnSaveAPIJ — clear Project ID.',
            '/HttpService — show HttpService status.',
            '/HttpEnabled true|false — attempt to set HttpEnabled (may fail).',
            '/HttpAsync true|false — set internal async mode.',
            '/HttpState ("url") — GET check website.',
            '/Keep ("text") — save a local note.',
            '/ShowKeep — list saved notes.',
            '/ClearAllKeep — clear saved notes.',
            '/ClearTexts — clear GPT chat UI.',
            '/Ins — open interactive instancer or use /Ins (quick args).',
            '/Destroy /Resize /Position /Color — object ops.',
            '/TP /Rejoin /ServerHop /HttpAsync',
            '/Autobot [Walk|Jump|Spin|Dance|Random|Stop] — autonomous actions.',
            '/TextsCounts — number of messages in GPT chat.',
            '/Music play:ID(123456) — play music; /Music do:Play|Pause|Stop|Restart|Loop|UnLoop|Loop(N times); /Music change:Vol(X) or change:Playback(X).',
            '/SeeChat — mirror Roblox chat into GPT UI.',
            '/UnSeeChat — stop mirroring Roblox chat.',
            '/Execute "pla:..." or "cmd:..." — run player actions or call commands.',
            '/Console — instructions to open Roblox Developer Console (F9).',
        }
        for i,line in ipairs(helpLines) do appendChat(false, tostring(i) .. ". " .. line, {200,200,255}) end
        appendSystem("If you want example usage for a command, ask /Help <CommandName>.")
        return true
    end

    appendError("Unknown command: /"..tostring(cmd).." (use /Help)")
    return true
end

-- API/project top-row bindings
pcall(function()
    if projBtn and projBtn:IsA("TextButton") then
        projBtn.MouseButton1Click:Connect(function()
            local v = trim(projBox.Text or "")
            if v == "" then appendError("Project ID empty."); return end
            if not v:match("^proj_") then appendError("Project ID should start with 'proj_'"); return end
            STATE.PROJECT_ID = v; appendSystem("Project ID saved.")
        end)
    end
    if apiBtn and apiBtn:IsA("TextButton") then
        apiBtn.MouseButton1Click:Connect(function()
            local raw = trim(apiBox.Text or "")
            if raw == "" then appendError("API key empty."); return end
            STATE.OPENAI_KEY = raw; appendSystem(("API key set: %s (client-side)"):format(redactKey(raw)))
            task.spawn(function()
                -- optional validation could be added here (but avoid accidental requests)
                appendDebug("API assigned (no remote validation performed).")
            end)
        end)
    end
end)

-- Send chat binding
local function sendChat()
    local text = tostring(chatBox.Text or "")
    if text:match("^%s*$") then return end
    if text:sub(1,1) == "/" then
        if handleCommand(text) then chatBox.Text = "" ; return end
    end
    appendChat(true, text)
    chatBox.Text = ""
    if STATE.OPENAI_KEY and STATE.OPENAI_KEY ~= "" then
        appendChat(false, "[System] ⌛ Thinking...")
        task.spawn(function()
            -- minimal AI call wrapper (kept inside to avoid accidental use)
            local function callOpenAI(prompt, key, proj)
                if not key or key == "" then return nil, "no_key" end
                local payload = { model = STATE.MODEL, messages = { { role = "user", content = prompt } }, max_tokens=400, temperature=0.6 }
                local headers = { ["Content-Type"]="application/json", ["Authorization"]="Bearer "..tostring(key) }
                if proj and proj~="" then headers["OpenAI-Project"] = tostring(proj) end
                local ok, respOrErr = pcall(function()
                    return HttpService:RequestAsync({ Url = "https://api.openai.com/v1/chat/completions", Method = "POST", Headers = headers, Body = HttpService:JSONEncode(payload), Timeout = 25 })
                end)
                if not ok then return nil, tostring(respOrErr) end
                local resp = respOrErr
                if not resp or not resp.Success then
                    local parsed; pcall(function() parsed = HttpService:JSONDecode(resp.Body or "{}") end)
                    local errMsg = parsed and parsed.error and parsed.error.message or ("status:"..tostring(resp.StatusCode))
                    return nil, errMsg
                end
                local decoded; pcall(function() decoded = HttpService:JSONDecode(resp.Body or "{}") end)
                if decoded and decoded.choices and decoded.choices[1] and decoded.choices[1].message and decoded.choices[1].message.content then
                    return tostring(decoded.choices[1].message.content), nil
                end
                return nil, "no_content"
            end
            local reply, err = callOpenAI(text, STATE.OPENAI_KEY, STATE.PROJECT_ID)
            if reply then appendChat(false, reply) else appendError("OpenAI Error: "..tostring(err)) end
        end)
    else
        appendSystem("No API key set. Use /API to set your key.")
    end
end

pcall(function() if sendBtn and sendBtn:IsA("TextButton") then sendBtn.MouseButton1Click:Connect(sendChat) end end)
pcall(function() if chatBox and chatBox:IsA("TextBox") then chatBox.FocusLost:Connect(function(enter) if enter then sendChat() end end) end end)

-- Panel toggle binding (use existing toggle if available)
local toggleBtn = nil
pcall(function()
    if type(menuGui) == "Instance" and menuGui.Parent then
        toggleBtn = menuGui:FindFirstChild("a3_ChatGPT", true) or menuGui:FindFirstChild("gpt", true)
    end
    if not toggleBtn then
        toggleBtn = targetMenu:FindFirstChild("a3_ChatGPT", true) or targetMenu:FindFirstChild("gpt", true)
    end
end)
local panelOpen = false
local function togglePanel()
    panelOpen = not panelOpen
    if panelOpen then safeTween(rootFrame, { Position = UDim2.new(0,0,0.1,0) }, 0.28) else safeTween(rootFrame, { Position = UDim2.new(-1,0,0.1,0) }, 0.28) end
end
if toggleBtn and (toggleBtn:IsA("ImageButton") or toggleBtn:IsA("TextButton")) then pcall(function() toggleBtn.MouseButton1Click:Connect(togglePanel) end) else _G.ExperienceSettings_ToggleGPT = togglePanel end

-- Startup message
appendSystem("ChatGPT UI ready. Use /Help for commands. Use /Ins to open the instancer or /Ins (<args>) for quick create.")
_G.ExperienceSettings_GPT_STATE = STATE
_G.ExperienceSettings_GPT_append = appendChat
_G.ExperienceSettings_ToggleGPT = togglePanel

-- End of script
