-- So this another script lol 0.6


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

local BFrame = CoreGui:WaitForChild("ExperienceSettings", 10).Menu.Background:WaitForChild("Inner_Background", 5).Toggles.B_Frame

-- Toggle builder
local toggleCount = 0
local function createToggle(parent, text, callback, defaultState)
    toggleCount += 1

    local f = Instance.new("Frame")
    f.Name = "Frame" .. toggleCount
    f.Size = UDim2.new(1,0,0.05,0)
    f.BackgroundTransparency = 0
    f.Parent = parent
    Corner(0.3, 0, f)

    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(0.4,0,1,0)
    bar.Position = UDim2.new(0.6,0,0,0)
    bar.BackgroundColor3 = Color3.fromRGB(66,66,66)
    bar.Parent = f
    Corner(0.3,0,bar)

    local but = Instance.new("TextButton")
    but.Name = "ToggleButton"
    but.Size = UDim2.new(0.5,0,1,0)
    but.Parent = bar
    Corner(0.3,0,but)

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
--// =====================================================


--// =====================================================
--// PHYSICS VISUAL DEBUGGER (FINAL + SAFE)
--// =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--// =====================================================
--// SETTINGS
--// =====================================================

local Physics = {
    Enabled = false,
    Global = false,

    MaxDistance = 1024,
    TimeStep = 0.05,
    MaxTime = 3,

    SegmentThickness = 0.15,
    MinMoveSpeed = 1, -- studs/s (นิ่ง = ไม่วาด)
}

--// =====================================================
--// CACHE
--// =====================================================

local PhysicsCache = {}

--// =====================================================
--// UTILS
--// =====================================================

local function getSpeedColor(speed)
    if not speed or speed <= 0 then
        return Color3.fromRGB(0,180,255)       -- Cyan
    elseif speed < 17 then
        return Color3.fromRGB(120,255,200)     -- Mint
    elseif speed < 32 then
        return Color3.fromRGB(0,255,0)         -- Lime
    elseif speed < 64 then
        return Color3.fromRGB(255,255,0)       -- Yellow
    elseif speed < 128 then
        return Color3.fromRGB(213,115,61)      -- Orange
    elseif speed < 512 then
        return Color3.fromRGB(255,0,0)         -- Red
    else
        return Color3.fromRGB(170,0,255)       -- 🔥 Purple (แทน Pink)
    end
end

local function isRootAlive(root)
    return root
        and root.Parent
        and root:IsDescendantOf(Workspace)
end

local function getRootFromInstance(inst)
    if inst:IsA("BasePart") then
        if inst.Anchored then return nil end
        return inst
    end
    if inst:IsA("Model") then
        return inst:FindFirstChild("HumanoidRootPart")
            or inst.PrimaryPart
            or inst:FindFirstChildWhichIsA("BasePart")
    end
end

local function newSegment()
    local p = Instance.new("Part")
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.Neon
    p.Size = Vector3.new(Physics.SegmentThickness, Physics.SegmentThickness, 1)
    p.Parent = Workspace
    return p
end

local function clearState(state)
    for _, s in ipairs(state.Segments) do
        if s then s:Destroy() end
    end
    if state.CFrameSeg then state.CFrameSeg:Destroy() end
    if state.BlueBall then state.BlueBall:Destroy() end
    if state.RedBall then state.RedBall:Destroy() end
end

local function getState(root)
    if PhysicsCache[root] then
        return PhysicsCache[root]
    end

    local state = {
        Segments = {},
        LastPos = root.Position,
        LastTime = os.clock(),
    }

    -- auto clean when destroyed
    root.AncestryChanged:Connect(function(_, parent)
        if not parent then
            clearState(state)
            PhysicsCache[root] = nil
        end
    end)

    PhysicsCache[root] = state
    return state
end

--// =====================================================
--// PHYSICS DRAW
--// =====================================================

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist

local function drawPhysics(root)
    local state = getState(root)
    if not isRootAlive(root) then return end

    local now = os.clock()
    local dt = now - state.LastTime
    if dt <= 0 then return end

    local velocity = (root.Position - state.LastPos) / dt
    local speed = velocity.Magnitude
    state.LastPos = root.Position
    state.LastTime = now

    if speed < Physics.MinMoveSpeed then return end

    -- clear old segments
    for _, s in ipairs(state.Segments) do
        s:Destroy()
    end
    table.clear(state.Segments)

    rayParams.FilterDescendantsInstances = {root.Parent}

    local startPos = root.Position
    local v0 = velocity
    local gravity = Vector3.new(0, -Workspace.Gravity, 0)

    local lastPos = startPos

    for t = 0, Physics.MaxTime, Physics.TimeStep do
        local pos = startPos + v0 * t + 0.5 * gravity * t * t
        if (pos - startPos).Magnitude > Physics.MaxDistance then break end

        local dir = pos - lastPos
        if dir.Magnitude > 0.05 then
            local hit = Workspace:Raycast(lastPos, dir, rayParams)
            if hit then break end

            local seg = newSegment()
            seg.Size = Vector3.new(
                Physics.SegmentThickness,
                Physics.SegmentThickness,
                dir.Magnitude
            )
            seg.CFrame = CFrame.new(lastPos + dir/2, pos)
            seg.Color = getSpeedColor(speed * (1 - t / Physics.MaxTime))
            table.insert(state.Segments, seg)
        end

        lastPos = pos
    end

    --// Position of CFrame (ไม่โค้ง)
    if state.CFrameSeg then state.CFrameSeg:Destroy() end
    local cfSeg = newSegment()
    cfSeg.Color = Color3.fromRGB(255,255,255)
    cfSeg.Size = Vector3.new(
        Physics.SegmentThickness,
        Physics.SegmentThickness,
        math.min(speed * 0.5, Physics.MaxDistance)
    )
    cfSeg.CFrame = CFrame.new(
        startPos,
        startPos + root.CFrame.LookVector
    ) * CFrame.new(0,0,-cfSeg.Size.Z/2)
    state.CFrameSeg = cfSeg
end

--// =====================================================
--// UPDATE LOOP
--// =====================================================

RunService.RenderStepped:Connect(function()
    -- global clean
    for root, state in pairs(PhysicsCache) do
        if not isRootAlive(root) then
            clearState(state)
            PhysicsCache[root] = nil
        end
    end

    if not Physics.Enabled then return end

    local origin = LocalPlayer.Character
        and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if Physics.Global then
        for _, inst in ipairs(Workspace:GetDescendants()) do
            local root = getRootFromInstance(inst)
            if root and root ~= origin then
                drawPhysics(root)
            end
        end
    elseif origin then
        drawPhysics(origin)
    end
end)

--// =====================================================
--// TOGGLES (example)
--// =====================================================

createToggle(BFrame, "Show Physics", function(on)
    Physics.Enabled = on
    Physics.Global = false
end, false)

createToggle(BFrame, "Global Physics", function(on)
    Physics.Enabled = on
    Physics.Global = on
end, false)

--// ================= END =================
