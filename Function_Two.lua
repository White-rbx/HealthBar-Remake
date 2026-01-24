-- So this another script lol 0.1


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
--// PHYSICS VISUAL DEBUGGER (FULL + FIXED)
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
    MinMovement = 0.05,
}

--// =====================================================
--// CACHE
--// =====================================================

local PhysicsCache = {}
local Billboard

--// =====================================================
--// CLEANUP (MISSING PART)
--// =====================================================

local function cleanupState(root)
    local state = PhysicsCache[root]
    if not state then return end

    for _, s in ipairs(state.Segments) do
        s:Destroy()
    end
    state.BlueBall:Destroy()
    state.RedBall:Destroy()

    PhysicsCache[root] = nil
end

local function cleanupAll()
    for root in pairs(PhysicsCache) do
        cleanupState(root)
    end
end

--// =====================================================
--// UTILS
--// =====================================================

local function getRootFromInstance(inst)
    if inst:IsA("BasePart") then
        if inst.Anchored then return nil end
        return inst
    end

    if inst:IsA("Model") then
        return inst.PrimaryPart
            or inst:FindFirstChild("HumanoidRootPart")
            or inst:FindFirstChildWhichIsA("BasePart")
    end

    if inst:IsA("Folder") then
        for _, v in ipairs(inst:GetChildren()) do
            local r = getRootFromInstance(v)
            if r then return r end
        end
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

local function newBall(color, size)
    local p = Instance.new("Part")
    p.Shape = Enum.PartType.Ball
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.Neon
    p.Color = color
    p.Size = Vector3.new(size, size, size)
    p.Transparency = 1
    p.Parent = Workspace
    return p
end

local function getState(root)
    if PhysicsCache[root] then
        return PhysicsCache[root]
    end

    local state = {
        Segments = {},
        BlueBall = newBall(Color3.fromRGB(0,180,255), 0.6),
        RedBall  = newBall(Color3.fromRGB(255,70,70), 1),
        LastPos = root.Position
    }

    PhysicsCache[root] = state
    return state
end

--// =====================================================
--// BILLBOARD
--// =====================================================

local function createBillboard(hrp)
    if Billboard then Billboard:Destroy() end

    Billboard = Instance.new("BillboardGui")
    Billboard.Adornee = hrp
    Billboard.Size = UDim2.fromScale(4, 2)
    Billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    Billboard.AlwaysOnTop = true
    Billboard.Enabled = false
    Billboard.Parent = hrp

    local text = Instance.new("TextLabel")
    text.Name = "Info"
    text.Size = UDim2.fromScale(1,1)
    text.BackgroundTransparency = 1
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0.25
    text.TextColor3 = Color3.fromRGB(180,255,255)
    text.Parent = Billboard
end

--// =====================================================
--// RAY PARAMS
--// =====================================================

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist

--// =====================================================
--// PHYSICS DRAW
--// =====================================================

local function drawPhysics(root)
    if not root or not root.Parent then
        cleanupState(root)
        return
    end

    local state = getState(root)

    if (root.Position - state.LastPos).Magnitude < Physics.MinMovement then
        return
    end
    state.LastPos = root.Position

    for _, s in ipairs(state.Segments) do
        s:Destroy()
    end
    table.clear(state.Segments)

    state.BlueBall.Transparency = 1
    state.RedBall.Transparency = 1

    local startPos = root.Position
    local v0 = root.AssemblyLinearVelocity
    local gravity = Vector3.new(0, -Workspace.Gravity, 0)

    rayParams.FilterDescendantsInstances = {root.Parent}

    local lastPos = startPos
    local landedPos

    for t = 0, Physics.MaxTime, Physics.TimeStep do
        local pos = startPos + v0 * t + 0.5 * gravity * t * t

        if (pos - startPos).Magnitude > Physics.MaxDistance then
            break
        end

        local dir = pos - lastPos
        if dir.Magnitude > 0.05 then
            local hit = Workspace:Raycast(lastPos, dir, rayParams)
            if hit then
                landedPos = hit.Position
                break
            end

            local seg = newSegment()
            seg.Size = Vector3.new(
                Physics.SegmentThickness,
                Physics.SegmentThickness,
                dir.Magnitude
            )
            seg.CFrame = CFrame.new(lastPos + dir/2, pos)
            seg.Color = Color3.fromRGB(0,180,255)

            table.insert(state.Segments, seg)
        end

        lastPos = pos
    end

    if landedPos then
        state.RedBall.Transparency = 0
        state.RedBall.Position = landedPos
    elseif v0.Magnitude > 1 then
        state.BlueBall.Transparency = 0
        state.BlueBall.Position = lastPos
    end

    return v0, landedPos
end

--// =====================================================
--// CHARACTER
--// =====================================================

local function onCharacter(char)
    createBillboard(char:WaitForChild("HumanoidRootPart"))
end

if LocalPlayer.Character then
    onCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(onCharacter)

--// =====================================================
--// UPDATE LOOP
--// =====================================================

RunService.RenderStepped:Connect(function()
    if not Physics.Enabled then
        cleanupAll()
        return
    end

    local char = LocalPlayer.Character
    local origin = char and char:FindFirstChild("HumanoidRootPart")
    if not origin then return end

    if Physics.Global then
        for _, inst in ipairs(Workspace:GetChildren()) do
            local root = getRootFromInstance(inst)
            if root and (root.Position - origin.Position).Magnitude <= Physics.MaxDistance then
                drawPhysics(root)
            end
        end
    else
        local v0, landed = drawPhysics(origin)
        if Billboard and Billboard.Enabled then
            Billboard.Info.Text = string.format(
                "Speed: %.1f\nLanding: %s",
                v0.Magnitude,
                landed and "Yes" or "No"
            )
        end
    end
end)

--// =====================================================
--// TOGGLES
--// =====================================================

createToggle(BFrame, "Show Physics", function(on)
    Physics.Enabled = on
    Physics.Global = false
    if Billboard then Billboard.Enabled = on end
    if not on then cleanupAll() end
end, false)

createToggle(BFrame, "Global Physics", function(on)
    Physics.Global = on
    Physics.Enabled = on
    if Billboard then Billboard.Enabled = false end
    if not on then cleanupAll() end
end, false)

--//============= END ===============
