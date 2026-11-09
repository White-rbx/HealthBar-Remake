-- So this another script lol 2.95


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
local TextService = game:GetService("TextService")

-- Input (Desktop / Mobile)
local UserInputService = game:GetService("UserInputService")
local TouchInputService = game:GetService("TouchInputService")
------------------------------------------------------------
local BFrame = CoreGui:WaitForChild("ExperienceSettings")
    .Menu.Background
    :WaitForChild("Inner_Background")
    .Toggles:WaitForChild("B_Frame")

repeat
    task.wait()
until BFrame.Parent

local function SafeFont(font)
	local ok = pcall(function()
		local _ = font.Name
	end)

	if ok and font ~= Enum.Font.Unknown then
		return font
	end

	return Enum.Font.SourceSans
end

local ToggleConfig = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/ToggleConfig.lua"
))()

-- Toggle builder
local toggleCount = 0

local function createToggle(parent, id, text, description, callback, defaultState)
    toggleCount += 1

    local f = Instance.new("Frame")
    f.Name = "Frame" .. toggleCount
    f.Size = UDim2.new(1,0,0.05,0)
    f.BackgroundColor3 = Color3.new(0,0,0)
    f.Parent = parent
    Corner(0.3,0,f)

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
    txt.TextColor3 = Color3.new(1,1,1)
    txt.RichText = true
    txt.Text = text or ""
    txt.Parent = f

    local des = Instance.new("TextLabel")
    des.Name = "Description"
    des.Position = UDim2.new(0,-224,0,0)
    des.BackgroundColor3 = Color3.fromRGB(25,25,25)
    des.TextWrapped = true
    des.TextYAlignment = Enum.TextYAlignment.Top
    des.TextColor3 = Color3.new(1,1,1)
    des.RichText = true
    des.TextSize = 12
    des.Visible = false
    des.ZIndex = 3
    des.Text = description or ""
    des.Parent = txt

    Corner(0,8,des)
    Stroke(des, ASMBorder,255,255,255,LJMRound,1,0)

    local function StripRichText(text)
	text = tostring(text or "")

	-- ลบเฉพาะ Tag ที่ขึ้นต้นด้วยตัวอักษรหรือ /
	text = text:gsub("</?[%a][^>]->", "")

	return text
end
	
    local function StripRichText(text)
	text = tostring(text or "")

	-- ลบเฉพาะ Tag ที่ขึ้นต้นด้วยตัวอักษรหรือ /
	text = text:gsub("</?[%a][^>]->", "")

	return text
end
	
    local bounds

    local ok = pcall(function()
        bounds = TextService:GetTextSize(
            StripRichText(des.Text or ""),
            tonumber(des.TextSize) or 12,
            SafeFont(des.Font),
            Vector2.new(220, math.huge)
        )
    end)

    if not ok or not bounds then
        bounds = Vector2.new(220,24)
    end

    des.Size = UDim2.new(0,220,0,bounds.Y+10)

	txt.MouseEnter:Connect(function()
    des.Visible = true
end)

txt.MouseLeave:Connect(function()
    des.Visible = false
end)

    txt.MouseEnter:Connect(function()
        des.Visible = true
    end)

    txt.MouseLeave:Connect(function()
        des.Visible = false
    end)

    ---------------------------------------------------
    -- Toggle Logic
    ---------------------------------------------------

    local toggle = ToggleConfig:Get(
        id,
        defaultState or false
    )

    local tweenInfo = TweenInfo.new(
        0.3,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )

    local function updateToggle(state, instant)

        toggle = state

        ToggleConfig:Set(id,state)
        ToggleConfig:Save()

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
                but[k] = v
            end

        else

            TweenService:Create(
                but,
                tweenInfo,
                props
            ):Play()

        end

        if callback then
            pcall(callback,toggle)
        end

    end

    -- โหลดค่าจากไฟล์
    updateToggle(toggle,true)

    but.MouseButton1Click:Connect(function()
        updateToggle(not toggle)
    end)

    return f, updateToggle
end
--// =====================================================


--// =====================================================
--// PHYSICS VISUAL DEBUGGER (FINAL + MODEL REMOVE FIX)
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

    MaxDistance = 2048,
    TimeStep = 0.05,
    MaxTime = 3,

    SegmentThickness = 0.15,
}

--// =====================================================
--// CACHE
--// =====================================================

local PhysicsCache = {}

--// =====================================================
--// UTILS
--// =====================================================

local function getRoot(inst)
    if inst:IsA("BasePart") and not inst.Anchored then
        return inst
    end
    if inst:IsA("Model") then
        return inst:FindFirstChild("HumanoidRootPart")
            or inst.PrimaryPart
            or inst:FindFirstChildWhichIsA("BasePart")
    end
end

local function newPart(size)
    local p = Instance.new("Part")
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.Neon
    p.Size = size
    p.Transparency = 0
    p.Parent = Workspace
    return p
end

local function newBall(color, size)
    local p = newPart(Vector3.new(size,size,size))
    p.Shape = Enum.PartType.Ball
    p.Color = color
    p.Transparency = 1
    return p
end

--// =====================================================
--// SPEED COLOR (STUDS / SEC)
--// =====================================================

local function getSpeedColor(speed)
    if not speed or speed <= 0 then
        return Color3.fromRGB(0,180,255)       -- Cyan (Nil)
    elseif speed < 32 then
        return Color3.fromRGB(120,255,200)     -- Mint
    elseif speed < 64 then
        return Color3.fromRGB(0,255,0)         -- Lime
    elseif speed < 128 then
        return Color3.fromRGB(255,255,0)       -- Yellow
    elseif speed < 512 then
        return Color3.fromRGB(213, 115, 61)    -- Orange
    elseif speed < 1024 then
        return Color3.fromRGB(255,0,0)         -- Red
    else
        return Color3.fromRGB(170, 0, 255)     -- Purple
    end
end

--// =====================================================
--// STATE
--// =====================================================

local function clearState(state)
    for _, s in ipairs(state.Segments) do
        if s then s:Destroy() end
    end
    table.clear(state.Segments)

    if state.PosLine then
        state.PosLine:Destroy()
        state.PosLine = nil
    end

    if state.BlueBall then
        state.BlueBall.Transparency = 1
    end
    if state.RedBall then
        state.RedBall.Transparency = 1
    end
end

local function destroyState(state)
    -- [FIX] destroy everything fully
    for _, s in ipairs(state.Segments) do
        if s then s:Destroy() end
    end

    if state.PosLine then state.PosLine:Destroy() end
    if state.BlueBall then state.BlueBall:Destroy() end
    if state.RedBall then state.RedBall:Destroy() end
end

local function getState(root)
    if PhysicsCache[root] then
        return PhysicsCache[root]
    end

    local state = {
        Segments = {},
        PosLine = nil,
        BlueBall = newBall(Color3.fromRGB(0,180,255), 0.6),
        RedBall  = newBall(Color3.fromRGB(255,70,70), 1),
    }

    -- =================================================
    -- [FIX] AUTO CLEAN WHEN MODEL / PART REMOVED
    -- =================================================
    root.AncestryChanged:Connect(function(_, parent)
        if not parent then
            destroyState(state)
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
    -- [FIX] root vanished safety
    if not root or not root.Parent then
        return
    end

    local state = getState(root)
    clearState(state)

    local startPos = root.Position
    local velocity = root.AssemblyLinearVelocity
    local gravity = Vector3.new(0, -Workspace.Gravity, 0)

    rayParams.FilterDescendantsInstances = {root.Parent}

    local lastPos = startPos
    local landedPos

    for t = 0, Physics.MaxTime, Physics.TimeStep do
        local pos = startPos + velocity * t + 0.5 * gravity * t * t
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

            local seg = newPart(Vector3.new(
                Physics.SegmentThickness,
                Physics.SegmentThickness,
                dir.Magnitude
            ))

            seg.CFrame = CFrame.new(lastPos + dir/2, pos)

            local speed = dir.Magnitude / Physics.TimeStep
            seg.Color = getSpeedColor(speed)

            table.insert(state.Segments, seg)
        end

        lastPos = pos
    end

    if landedPos then
        state.RedBall.Transparency = 0
        state.RedBall.Position = landedPos
    elseif velocity.Magnitude > 1 then
        state.BlueBall.Transparency = 0
        state.BlueBall.Position = lastPos
    end

    -- POSITION OF CFRAME (LINEAR)
    if velocity.Magnitude > 1 then
        local dir = velocity.Unit
        local len = math.clamp(velocity.Magnitude * 0.15, 2, 50)

        local line = newPart(Vector3.new(0.12, 0.12, len))
        line.Color = Color3.fromRGB(180,180,255)

        line.CFrame = CFrame.new(
            startPos + dir * (len / 2),
            startPos + dir * len
        )

        state.PosLine = line
    end
end

--// =====================================================
--// UPDATE LOOP
--// =====================================================

RunService.RenderStepped:Connect(function()
    if not Physics.Enabled then
        for root, state in pairs(PhysicsCache) do
            clearState(state)
        end
        return
    end

    local char = LocalPlayer.Character
    local origin = char and char:FindFirstChild("HumanoidRootPart")
    if not origin then return end

    if Physics.Global then
        for _, inst in ipairs(Workspace:GetChildren()) do
            local root = getRoot(inst)
            if root
                and root.Parent -- [FIX]
                and root.AssemblyLinearVelocity.Magnitude > 1
                and (root.Position - origin.Position).Magnitude <= Physics.MaxDistance
            then
                drawPhysics(root)
            end
        end
    else
        drawPhysics(origin)
    end
end)

--// =====================================================
--// TOGGLES
--// =====================================================

createToggle(BFrame, "SP", "Show Physics",[[<b><u>Show Physics</u></b>
Displays colorful trajectory lines ("player speedometers") and landing prediction points showing where your character is expected to land.]],
	function(on)
    Physics.Enabled = on
    Physics.Global = false
end, false)

createToggle(BFrame, "GP", "Global Physics", [[<b><u>Global Physics</u></b>
Same as Show Physics Toggle, but you're just seeing the physics of other players and objects too.]], function(on)
    Physics.Enabled = on
    Physics.Global = on
end, false)

-- Relax Loadstring 
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/GifAnimationEditor.lua"))()
local RelaxGui
task.spawn(function()
	local Hrsn = CoreGui:WaitForChild("ExperienceSettings")
		:WaitForChild("Menu")
		:WaitForChild("HolderScreen")

	RelaxGui = Hrsn:WaitForChild("Relax")
end)

createToggle(
	BFrame,
	"R/GAE",
	"Relax / Gif Animation Editor",
	[[<b><u>Gif Animation Editor</u></b>
Show or hide the Gif Animation Editor window.]],
	function(State)

		if RelaxGui then
			RelaxGui.Visible = State
		end

	end,
	false
)

--// =====================================================
--// ArcScriptCenter v0.5.35: ONE presence + usage owner (Function_Two Toggles)
--// Arcsen Settings is read-only. Public profiles/time require explicit consent.
--// =====================================================
do
    local env = getgenv()
    local conf = ToggleConfig
    local mainKey = "ACS_ShareActiveStatus"
    local pauseKey = "ACS_presence_pause_until"
    local neverKey = "ACS_presence_never_share"
    local profileKey = "ACS_presence_profile_opt_in"
    local usageKey = "ACS_usage_time_opt_in"
    local rankKey = "ACS_leaderboard_opt_in"
    local avatarKey = "ACS_leaderboard_avatar_opt_in"
    local oldKey = "_ES_UniversalPresenceSession"
    local ownerKey = "_ES_AnalyticsPresenceSession"

    -- Retire the previous UniversalPresence heartbeat to avoid counting one client twice.
    if type(env[oldKey]) == "table" and type(env[oldKey].stop) == "function" then
        pcall(function() env[oldKey]:stop() end)
    end
    env[oldKey] = nil
    if type(env[ownerKey]) == "table" and type(env[ownerKey].Destroy) == "function" then
        pcall(function() env[ownerKey]:Destroy(false) end)
    end
    env[ownerKey] = nil

    local bundledModule = [=====[-- ArcScriptCenter v0.5.35 — OPTIONAL, EXPLICITLY OPTED-IN usage telemetry.
-- This is a standalone client adapter for ExperienceSettings.
-- It does NOT send chat, movement, location, inventories, or private messages.
-- Usage (from your EXISTING toggle handlers):
--   local Analytics = [load this module]()
--   Analytics:SetActiveUser(true)       -- existing 'Active User' setting
--   Analytics:SetShowToAdmin(true)      -- existing 'Show to Admin' setting
--   Analytics:SetAnalyticsConsent(true) -- independent optional consent
--   Analytics:SetLeaderboardConsent(true) -- independent optional public-name consent
-- Anonymous active status is controlled by Function_Two. Analytics/leaderboard/avatar opt-in separately.

local Players = game:GetService('Players')
local HttpService = game:GetService('HttpService')
local LocalPlayer = Players.LocalPlayer

local M = {}
M.__index = M

local API_DEFAULT = 'https://arcscriptcenter-api.kogpasan14.workers.dev'
local HEARTBEAT = 30

local function getRequest()
    local env = type(getgenv) == 'function' and getgenv() or nil
    if type(env) == 'table' then
        if type(env.request) == 'function' then return env.request end
        if type(env.http_request) == 'function' then return env.http_request end
        if type(env.syn) == 'table' and type(env.syn.request) == 'function' then return env.syn.request end
    end
    if type(request) == 'function' then return request end
    if type(http_request) == 'function' then return http_request end
    if type(syn) == 'table' and type(syn.request) == 'function' then return syn.request end
    return nil
end

function M.new(opts)
    opts = type(opts) == 'table' and opts or {}
    local self = setmetatable({}, M)
    self.api = tostring(opts.url or API_DEFAULT):gsub('/+$','')
    if not self.api:match('^https://[%w%-%.]+$') then
        return nil, 'ArcScriptCenter URL must be an HTTPS hostname'
    end
    self._request = opts.httpRequest or getRequest()
    if type(self._request) ~= 'function' then
        return nil, 'No compatible HTTP request function available'
    end
    self.sessionId = HttpService:GenerateGUID(false):gsub('[^%x]',''):lower()
    self.activeUser = false
    self.showToAdmin = false
    self.analyticsConsent = false
    self.leaderboardConsent = false
    self.avatarConsent = false
    self.running = false
    self.destroyed = false
    self.epoch = 0
    self.busy = false
    self.lastError = nil
    self.loopId = 0
    self._connections = {}
    table.insert(self._connections, Players.PlayerRemoving:Connect(function(player)
        if player == LocalPlayer then self:Destroy(false) end
    end))
    return self
end

function M:_send(path, data)
    local response = self._request({
        Url = self.api .. '/api/v1/presence/' .. path,
        Method = 'POST',
        Headers = {['Content-Type']='application/json',Accept='application/json'},
        Body = HttpService:JSONEncode(data)
    })
    local code = tonumber(response and (response.StatusCode or response.Status)) or 0
    if code < 200 or code >= 300 then
        return false, 'Presence HTTP ' .. tostring(code)
    end
    return true
end

function M:_payload()
    local body = { sessionId = self.sessionId }
    -- Public leaderboard profile and admin presence profile are separate consents.
    local wantsPublic = self.analyticsConsent and self.leaderboardConsent
    local wantsAdmin = self.showToAdmin
    if wantsPublic or wantsAdmin then
        body.profileConsent = true
        body.adminProfileConsent = wantsAdmin == true
        body.userId = tostring(LocalPlayer.UserId)
        body.username = tostring(LocalPlayer.Name)
        body.displayName = tostring(LocalPlayer.DisplayName)
    end
    if self.analyticsConsent then
        body.analyticsConsent = true
        body.analyticsUserId = tostring(LocalPlayer.UserId)
        body.leaderboardConsent = wantsPublic == true
        body.avatarConsent = wantsPublic and self.avatarConsent == true or false
    end
    return body
end

function M:_leave(revokeRanking)
    local body = {sessionId=self.sessionId}
    if revokeRanking and self.analyticsConsent then
        body.analyticsConsent = true
        body.analyticsUserId = tostring(LocalPlayer.UserId)
        body.leaderboardConsent = false
    end
    -- Best effort only: abrupt game exits/network loss are handled by server TTL.
    task.spawn(function()
        pcall(function() self:_send('leave',body) end)
    end)
end

function M:_eligible()
    return not self.destroyed and self.activeUser
end

function M:_heartbeat()
    if not self:_eligible() or self.busy then return end
    local epoch = self.epoch
    local payload = self:_payload()
    self.busy = true
    task.spawn(function()
        local ok,success,why = pcall(function() return self:_send('heartbeat',payload) end)
        self.busy = false
        if not ok or not success then self.lastError = tostring(why or success)
        else self.lastError=nil end
        -- A delayed HTTP request must never re-enable a toggled-off session.
        if epoch ~= self.epoch then
            if self:_eligible() then self:_heartbeat() else self:_leave(false) end
        end
    end)
end

function M:_reconcile(oldEnabled, revokeRanking)
    if self.destroyed then return end
    local enabled = self:_eligible()
    self.epoch += 1
    if not enabled then
        if oldEnabled then self:_leave(revokeRanking) end
        self.running = false
        self.loopId += 1
        return
    end
    self:_heartbeat()
    if self.running then return end
    self.running = true
    self.loopId += 1
    local token = self.loopId
    task.spawn(function()
        while self.running and not self.destroyed and self.loopId == token do
            task.wait(HEARTBEAT)
            if self.loopId ~= token or not self:_eligible() then break end
            self:_heartbeat()
        end
        if self.loopId == token then self.running=false end
    end)
end

-- Hook existing UI controls to these setters; DO NOT create a second toggle panel.
function M:SetActiveUser(value)
    local was = self:_eligible()
    self.activeUser = value == true
    self:_reconcile(was, false)
end
function M:SetShowToAdmin(value)
    local was = self:_eligible()
    self.showToAdmin = value == true
    self:_reconcile(was, false)
end
function M:SetAnalyticsConsent(value)
    local was = self:_eligible()
    -- Withdrawn analytics consent also withdraws public ranking, including while paused.
    if self.analyticsConsent and value ~= true then self:_leave(true) end
    self.analyticsConsent = value == true
    if not self.analyticsConsent then
        self.leaderboardConsent = false
        self.avatarConsent = false
    end
    self:_reconcile(was, false)
end
function M:SetLeaderboardConsent(value)
    local was = self:_eligible()
    if value == true and not self.analyticsConsent then
        return false, 'Enable usage tracking consent first'
    end
    local turningOff = self.leaderboardConsent and value ~= true
    self.leaderboardConsent = value == true
    if not self.leaderboardConsent then self.avatarConsent = false end
    if turningOff and not was then self:_leave(true) end
    self:_reconcile(was, false)
    return true
end
function M:SetAvatarConsent(value)
    if value == true and (not self.analyticsConsent or not self.leaderboardConsent) then
        return false, 'Enable leaderboard sharing first'
    end
    self.avatarConsent = value == true
    self:_reconcile(self:_eligible(), false)
    return true
end
function M:GetStatus()
    return {
        active = self:_eligible(),
        analytics = self.analyticsConsent,
        leaderboard = self.leaderboardConsent,
        avatar = self.avatarConsent,
        showToAdmin = self.showToAdmin,
        lastError = self.lastError,
    }
end
function M:Destroy(revokeRanking)
    if self.destroyed then return end
    local was = self:_eligible()
    if was then self:_leave(revokeRanking == true) end
    self.destroyed=true;self.running=false;self.epoch += 1;self.loopId += 1
    for _,connection in ipairs(self._connections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(self._connections)
end

return M
]=====]
    local adapter
    do
        local compiled, why = loadstring(bundledModule)
        if compiled then
            local ok, factory = pcall(compiled)
            if ok and type(factory) == "table" and type(factory.new) == "function" then
                local made, instance, err = pcall(factory.new)
                if made and type(instance) == "table" then
                    adapter = instance
                    env[ownerKey] = instance
                else warn("[ArcScriptCenter] Analytics init: " .. tostring(err or instance)) end
            else warn("[ArcScriptCenter] Analytics module: " .. tostring(factory)) end
        else warn("[ArcScriptCenter] Analytics syntax: " .. tostring(why)) end
    end
    local initial = true
    local row, setMain, setUsage, setRank, setAvatar
    local function isEnabled()
        return conf:Get(mainKey,true) == true
            and conf:Get(neverKey,false) ~= true
            and (tonumber(conf:Get(pauseKey,0)) or 0) <= os.time()
    end
    local function updateState()
        local active = isEnabled()
        local showAdmin = conf:Get(profileKey,false) == true
        local usage = conf:Get(usageKey,false) == true
        local ranking = usage and conf:Get(rankKey,false) == true
        local avatar = ranking and conf:Get(avatarKey,false) == true
        if adapter then
            -- Inactive sessions send no heartbeat, while retained leaderboard time stays in D1.
            adapter:SetShowToAdmin(showAdmin)
            adapter:SetAnalyticsConsent(usage)
            adapter:SetLeaderboardConsent(ranking)
            adapter:SetAvatarConsent(avatar)
            adapter:SetActiveUser(active)
        end
        env.ArcScriptCenterConsentStatus = {
            activeUser=active, showToAdmin=showAdmin,
            analyticsConsent=usage, leaderboardConsent=ranking, avatarConsent=avatar,
            source="Function_Two.lua", tracking=active and usage
        }
    end
    -- Preserve user's existing pause setting, but do not turn ON a permanent opt-out.
    if tonumber(conf:Get(pauseKey,0)) > 0 and tonumber(conf:Get(pauseKey,0)) <= os.time()
       and not conf:Get(neverKey,false) then
        conf:Set(mainKey,true); conf:Set(pauseKey,0); conf:Save()
    end

    row,setMain=createToggle(BFrame,mainKey,"Share Active Status",
        [[<b>Anonymous Active User</b> is shared while ON (default). OFF pauses for 24 hours.
Use Never Share to opt out permanently. Usage time and public leaderboard are separate OFF-by-default toggles.]],
        function(on)
            if initial then return end
            conf:Set(pauseKey,on and 0 or (os.time()+86400)); conf:Save()
            updateState()
        end,true)
    row.Name=mainKey

    local profileRow=createToggle(BFrame,profileKey,"Show Roblox Profile to Admin",
        [[<b>Private Admin profile</b> — OFF by default. Explicit permission to display
self-reported Roblox Username, DisplayName and UserID on the Admin Active User list.]],
        function(on) if not initial then updateState() end end,false)
    profileRow.Name=profileKey

    local usageRow
    usageRow,setUsage=createToggle(BFrame,usageKey,"Count Usage Time",
        [[<b>Accumulate usage time</b> — OFF by default. When enabled while Share Active Status is ON,
periodic heartbeats count approximately 30-second intervals on the Worker. Time is kept in D1 after logout.
Turning OFF stops counting; turning it back ON resumes the total.]],
        function(on)
            if initial then return end
            if not on and conf:Get(rankKey,false) and setRank then setRank(false) end
            updateState()
        end,false)
    usageRow.Name=usageKey

    local rankRow
    rankRow,setRank=createToggle(BFrame,rankKey,"Show in Leaderboard",
        [[<b>Public Leaderboard (opt-in)</b> — OFF by default. Shares self-reported nickname,
masked Username, masked UserID, and accumulated usage time. The ranking stays visible after logout.
Turning this OFF removes the public profile without erasing recorded usage time.]],
        function(on)
            if initial then return end
            if on and not conf:Get(usageKey,false) then
                -- Do not silently turn on a separate telemetry consent.
                if setRank then setRank(false) end
                warn("[ArcScriptCenter] Enable Count Usage Time before Show in Leaderboard.")
                return
            end
            if not on and conf:Get(avatarKey,false) and setAvatar then setAvatar(false) end
            updateState()
        end,false)
    rankRow.Name=rankKey

    local avatarRow
    avatarRow,setAvatar=createToggle(BFrame,avatarKey,"Show Your Avatar in Arcsen Leaderboard",
        [[<b>Show your Roblox avatar ImageLabel</b> — OFF by default. An avatar may identify you even
when Username and UserID are masked. If ON, Worker fetches your public Roblox avatar
and stores only its CDN image URL. Some Roblox clients may show a fallback avatar.]],
        function(on)
            if initial then return end
            if on and not conf:Get(rankKey,false) then
                -- Consent to display an image never implies consent to publish the entire profile.
                if setAvatar then setAvatar(false) end
                warn("[ArcScriptCenter] Enable Show in Leaderboard first.")
                return
            end
            updateState()
        end,false)
    avatarRow.Name=avatarKey

    local neverRow=createToggle(BFrame,neverKey,"Never Share Active Status",
        [[<b>Permanent opt-out.</b> Stops active status and usage counting immediately.
Existing public ranking data is retained until you turn OFF Show in Leaderboard.]],
        function(on) if not initial then updateState() end end,false)
    neverRow.Name=neverKey
    initial=false
    -- Initial setup: do not fire a separate heartbeat from each toggle constructor.
    if not conf:Get(usageKey,false) and conf:Get(rankKey,false) then setRank(false) end
    if not conf:Get(rankKey,false) and conf:Get(avatarKey,false) then setAvatar(false) end
    updateState()

    task.spawn(function()
        while row.Parent do
            task.wait(60)
            if not row.Parent then break end
            if not conf:Get(neverKey,false) and not conf:Get(mainKey,true) and
               tonumber(conf:Get(pauseKey,0))>0 and tonumber(conf:Get(pauseKey,0))<=os.time() then
                setMain(true)
            end
        end
    end)
    row.AncestryChanged:Connect(function(_,parent)
        if not parent then
            if adapter then adapter:Destroy(false) end
            if env[ownerKey] == adapter then env[ownerKey]=nil end
            env.ArcScriptCenterConsentStatus=nil
        end
    end)
end

--// ================= END =================
