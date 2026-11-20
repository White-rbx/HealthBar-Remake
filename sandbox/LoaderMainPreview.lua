-- ArcScriptCenter LoaderMainPreview | STAGING REAL LOADER ENTRY
-- Directly derived from White-rbx/HealthBar-Remake branch loadstring/Loader.lua
-- Upstream blob 9d6af20cf93610adf9be2e49bf61edabe8903f38; reviewed BanMode integration from sandbox/Loader-Main-BanMode-STAGING.lua
-- This runs the REAL Loader/SetUp/Arcsen flow, not a fabricated PlayerGui preview.
-- QA only: Universal entrypoint uses public display policy and can optionally use a trusted bridge.
-- All staging module paths remain sandbox-scoped.
-- ============================================================================
-- Well 4.12 | v0.5.36: Strict SetUp -> Loader -> Main serialization

--[[
 HELLO SCRIPTBLOX AND HAXHELL USERSSSS WHAT THE ACTUALLY HELL YOU GUYS
 DOING IN THIS RAW SCRIPT? AND YES IT'S MIGHT LOOK TOO AI SLOP BUT -
 GUIS ARE NOT MADE BY AI, ANYWAY I'M STILL LEARNING SCRIPT!

 THANK YOU FOR READINGGGGG *COUGH* *COUGH* *COUGH* *Died adorably*


  anyway you can see there's banned users. I'm not telling you how to- nah :3
]]

-- =========================================
-- SERIAL STARTUP (prevent duplicate SetUp/Loader windows)
-- =========================================
local policyMode = (...) == "roblox_server" and "roblox_server"
    or ((...) == "universal_case_qa" and "universal_case_qa" or "public_qa")
local bootEnv = getgenv()
if bootEnv.__ES_BOOTSTRAP_BUSY then
    warn("[ES][Bootstrap] Initialization already in progress; duplicate execution ignored.")
    return
end
bootEnv.__ES_BOOTSTRAP_BUSY = true
-- ASC BAN V2 BOOTSTRAP BEGIN
bootEnv.__ASC_BAN_POLICY_ERROR = nil
bootEnv.__ASC_BAN_V2_STATE = nil
bootEnv.__ASC_BAN_V2_CLIENT = nil
bootEnv.__ASC_REQUEST_BAN_REFRESH = nil
bootEnv.__ASC_BAN_V2_PREVIEW = true
local okClient, client = pcall(function()
    local url = "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/feedback-appeal-release-track/sandbox/BanPolicyClientPreview.lua"
    return assert(loadstring(game:HttpGet(url)))(policyMode)
end)
if okClient then bootEnv.__ASC_BAN_V2_CLIENT = client end
-- ASC BAN V2 BOOTSTRAP END

-- =========================================
-- RESET
-- =========================================

-- Time of this client execution is used for Only Live warnings.
getgenv().ArcScriptWarningClientStartedAt = os.time()
getgenv().ES = nil
getgenv().__ES_READY = nil
getgenv().__ES_BANNED = nil
getgenv().__ES_SETUP_FINISHED = nil
getgenv().__ES_BAN_SELECTION = nil
getgenv().__ES_BAN_DURATION = nil
getgenv().__ES_BAN_SELECTION_ASSIGNED = nil
getgenv().__ES_RESTRICTED_MODE = nil
getgenv()[string.char(95, 120, 55, 95, 113)] = nil

-- ASC POLICY WARNING BEGIN
local function ensureWarningUI()
    local existing = bootEnv.WarningUI
    if type(existing) == "table" and type(existing.dismissClient) == "function" then return existing end
    local sourceUI = [=====[
local v_ver = [[WarningUI 0.1.0 Preview]]
--[[ UI_functions version: 2.3 ( Reduced Locals for more less risk to due Out Of Local ) ]]

------------------------------------------------------------------------------------------

-- =====>> Saved Functions <<=====
-- ====FUNCTION CORNER===== Example: Corner(Scale, Offset, Parent)
local function Corner(Scale, Offset, Parent)
  local Corner = Instance.new("UICorner")
  Corner.CornerRadius = UDim.new(Scale or 0, Offset or 0)
  Corner.Parent = Parent
  return Corner
end
-- =====END FUNCTION CORNER====

-- =====FUNCTION UILISTLAYOUT===== Example: ListLayout(parent, scale, offset, HZ, VT, SO, FILL)
local ListUI = {
 HCenter = Enum.HorizontalAlignment.Center,
 VCenter = Enum.VerticalAlignment.Center,
 HLeft = Enum.HorizontalAlignment.Left,
 VTop = Enum.VerticalAlignment.Top,
 HRight = Enum.HorizontalAlignment.Right,
 VBottom = Enum.VerticalAlignment.Bottom,
 FillH = Enum.FillDirection.Horizontal,
 FillV = Enum.FillDirection.Vertical,
 SCustom = Enum.SortOrder.Custom,
 SLayout = Enum.SortOrder.LayoutOrder,
 SName = Enum.SortOrder.Name
}

local function ListLayout(parent, scale, offset, HZ, VT, SO, FILL)
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(scale or 0, offset or 0)
    list.FillDirection = ListUI[FILL] or ListUI.FillH
    list.HorizontalAlignment = ListUI[HZ] or ListUI.HCenter
    list.VerticalAlignment = ListUI[VT] or ListUI.VCenter
    list.SortOrder = ListUI[SO] or ListUI.SName
    list.Parent = parent
    return list
end
-- =====END FUNCTION UILISTLAYOUT=====

-- ====FUNCTION UISTROKE===== Example: Stroke(parent, ASM, R, G, B, LJM, Tn, Transy)
local StrokeUI = {
 ASMBorder = Enum.ApplyStrokeMode.Border,
 ASMContextual = Enum.ApplyStrokeMode.Contextual,

 LJMBevel = Enum.LineJoinMode.Bevel,
 LJMMiter = Enum.LineJoinMode.Miter,
 LJMRound = Enum.LineJoinMode.Round
}

local function Stroke(parent, ASM, R, G, B, LJM, Tn, Transy)
    local stroke = parent:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
    stroke.ApplyStrokeMode = StrokeUI[ASM] or StrokeUI.ASMBorder
    stroke.Color = Color3.fromRGB(R or 255, G or 255, B or 255)
    stroke.LineJoinMode = StrokeUI[LJM] or StrokeUI.LJMRound
    stroke.Thickness = Tn or 1
    stroke.Transparency = Transy or 0
    stroke.Parent = parent
    return stroke
end
-- =====END FUNCTION UISTROKE=====

-- ====FUNCTION UIGRADIENT===== Example: Gradient(parent, rotation, offsetX, offsetY, {...}, {...})
local function Gradient(parent, rotation, offsetX, offsetY, colors, transparencies)
    local grad = parent:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")

    grad.Rotation = rotation or 0
    grad.Offset = Vector2.new(offsetX or 0, offsetY or 0)

    -- Color
    local colorKeypoints = {}

    if not colors or #colors == 0 then
        colorKeypoints = {
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
        }
    elseif #colors == 1 then
        colorKeypoints = {
            ColorSequenceKeypoint.new(0, colors[1]),
            ColorSequenceKeypoint.new(1, colors[1])
        }
    else
        for i, c in ipairs(colors) do
            local t = (i-1) / (#colors-1)
            table.insert(colorKeypoints, ColorSequenceKeypoint.new(t, c))
        end
    end

    grad.Color = ColorSequence.new(colorKeypoints)


    -- Transparency
    local transparencyKeypoints = {}

    if not transparencies or #transparencies == 0 then
        transparencyKeypoints = {
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 0)
        }
    elseif #transparencies == 1 then
        transparencyKeypoints = {
            NumberSequenceKeypoint.new(0, transparencies[1]),
            NumberSequenceKeypoint.new(1, transparencies[1])
        }
    else
        for i, tValue in ipairs(transparencies) do
            local t = (i-1) / (#transparencies-1)
            table.insert(
                transparencyKeypoints,
                NumberSequenceKeypoint.new(t, tValue)
            )
        end
    end

    grad.Transparency = NumberSequence.new(transparencyKeypoints)

    grad.Parent = parent
    return grad
end
-- =====END FUNCTION UIGRADIENT=====

-- ====FUNCTION UIPADDING ===== Example: Padding(parent, {X, Y}, {X, Y}, {X, Y}, {X, Y})
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

-- =====FUNCTION UIASPECTRATIONCONSTRAINT==== Example: Aspect(parent, ratio, aspectType, dominantAxis)

--// ENUM SHORTCUTS
local Axis = Enum.DominantAxis
local Type = Enum.AspectType

local AspectUI = {
 Axis = Enum.DominantAxis,
 Type = Enum.AspectType,

-- optional ultra-short aliases
 Width = Axis.Width,
 Height = Axis.Height,

 Fit = Type.FitWithinMaxSize,
 Scale = Type.ScaleWithParentSize
}


--// ASPECT FUNCTION
local function Aspect(parent, ratio, aspectType, dominantAxis)
	if not parent then return end

	-- prevent duplicates
	local existing = parent:FindFirstChildOfClass("UIAspectRatioConstraint")
	if existing then
		-- update instead
		existing.AspectRatio = AspectUI[ratio] or existing.AspectRatio
		existing.AspectType = AspectUI[aspectType] or existing.AspectType
		existing.DominantAxis = AspectUI[dominantAxis] or existing.DominantAxis
		return existing
	end

	-- create new
	local constraint = Instance.new("UIAspectRatioConstraint")
	constraint.Parent = parent

	constraint.AspectRatio = AspectUI[ratio] or 1
	constraint.AspectType = AspectUI[aspectType] or AspectUI.Fit
	constraint.DominantAxis = AspectUI[dominantAxis] or AspectUI.Width

	return constraint
end

-- =====END FUNCTION UIASPECTRATIONCONSTRAINT=====

--[[
====== CLIENT SERVICES ( OLD ) ======

-- UI / Player Interface
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

-- 3D/2D Destroy
local Debris = game:GetService("Debris")

-- 3D Wprkspace
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera

-- Storage
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Third Party
local HttpService = game:GetService("HttpService")

-- Audio / Feedback
local SoundService = game:GetService("SoundService")

-- Commerce / Monetization
local MarketplaceService = game:GetService("MarketplaceService")

-- Runtime / Frame Updates
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local TextChatService = game:GetService("TextChatService")

-- Animation / Transitions
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

-- Input (Desktop / Mobile)
local UserInputService = game:GetService("UserInputService")
local TouchInputService = game:GetService("TouchInputService")
]]

--====== CLIENT SERVICES ( TABLE ); Use like this 'Service.Example' ======--

local s = {
-- UI / Player Interface
 CoreGui = game:GetService("CoreGui"),
 StarterGui = game:GetService("StarterGui"),
 GuiService = game:GetService("GuiService"),
 Players = game:GetService("Players"),

-- 3D/2D Destroy
 Debris = game:GetService("Debris"),

-- 3D Wprkspace
 Workspace = game:GetService("Workspace"),
 TeleportService = game:GetService("TeleportService"),
 Lighting = game:GetService("Lighting"),
 Camera = game:GetService("Workspace").CurrentCamera,

-- Storage
 ReplicatedStorage = game:GetService("ReplicatedStorage"),

-- Third Party
 HttpService = game:GetService("HttpService"),

-- Audio / Feedback
 SoundService = game:GetService("SoundService"),

-- Commerce / Monetization
 MarketplaceService = game:GetService("MarketplaceService"),

-- Runtime / Frame Updates
 RunService = game:GetService("RunService"),
 TextService = game:GetService("TextService"),
 TextChatService = game:GetService("TextChatService"),

-- Animation / Transitions
 TweenService = game:GetService("TweenService"),
 ContentProvider = game:GetService("ContentProvider"),

-- Input (Desktop / Mobile)
 UserInputService = game:GetService("UserInputService"),
 TouchInputService = game:GetService("TouchInputService"),

}

-- All local in one tabel; Use like this 'loc.Example'
local loc = {
  -- v Local V

}

local tweenStyle = {
    Linear = Enum.EasingStyle.Linear,
    Sine = Enum.EasingStyle.Sine,
    Back = Enum.EasingStyle.Back,
    Quad = Enum.EasingStyle.Quad,
    Quart = Enum.EasingStyle.Quart,
    Quint = Enum.EasingStyle.Quint,
    Bounce = Enum.EasingStyle.Bounce,
    Elastic = Enum.EasingStyle.Elastic,
    Exponential = Enum.EasingStyle.Exponential,
    Circular = Enum.EasingStyle.Circular,
    Cubic = Enum.EasingStyle.Cubic
}

local function Tween(obj, propertie, time, style)
    local properties = propertie or {}

    local selectedStyle = tweenStyle[style] or style or Enum.EasingStyle.Quad

    local tweenInfo = TweenInfo.new(
        time or 0.5,
        selectedStyle,
        Enum.EasingDirection.Out
    )

    local tween = s.TweenService:Create(obj, tweenInfo, properties)
    tween:Play()
    return tween
end

---------------------------------------------------------------------------------------

-- Remove a previously initialized popup and its animation loops when re-running.
local old = s.CoreGui:FindFirstChild("WarningUI-ByArcScript")
if old then old:Destroy() end

local fder = Instance.new("Folder")
fder.Name = "WarningUI-ByArcScript"
fder.Parent = s.CoreGui

local gui = Instance.new("ScreenGui")
gui.Name = "main"
gui.ScreenInsets = Enum.ScreenInsets.None
gui.DisplayOrder = 2147483647
gui.Parent = fder

local hr = Instance.new("Frame")
hr.Name = "Holder"
hr.Size = UDim2.new(1,0,1,0)
hr.BackgroundTransparency = 1
hr.BackgroundColor3 = Color3.new(0,0,0)
hr.Parent = gui
local layout = ListLayout(hr, 0,0,"HCenter","VCenter","SLayout","FillV")

-- Preserve only the warning IDs we already displayed across re-execution in this session.
-- Never persist message bodies, usernames, IPs or secrets.
local warningEnv = type(getgenv) == "function" and getgenv() or nil
local warningCache = warningEnv and warningEnv.ArcScriptWarningSeenIds
if type(warningCache) ~= "table" then
    warningCache = {seen = {}, order = {}}
    if warningEnv then warningEnv.ArcScriptWarningSeenIds = warningCache end
end
warningCache.seen = type(warningCache.seen) == "table" and warningCache.seen or {}
warningCache.order = type(warningCache.order) == "table" and warningCache.order or {}
local state = { queue = {}, active = nil, seen = warningCache.seen, seenOrder = warningCache.order, run = 0, dead = false, scripts = {} }

local function pop(ntitle, ndes, nbtn1, twoButtons, nbtn2, onClose, onPrimary, onSecondary, compact)
  local frmbtn = twoButtons == true

  local frm = Instance.new("Frame")
  frm.Name = "PopUp"
  layout.VerticalAlignment = compact and Enum.VerticalAlignment.Bottom or Enum.VerticalAlignment.Center
  frm.Size = compact and UDim2.new(0.8, 0, 0.36, 0) or UDim2.new(0.8, 0, 0.42, 0)
  local limit = Instance.new("UISizeConstraint")
  limit.MinSize = compact and Vector2.new(240, 206) or Vector2.new(240, 210)
  limit.MaxSize = compact and Vector2.new(420, 236) or Vector2.new(570, 450)
  limit.Parent = frm
  frm.BackgroundColor3 = Color3.fromRGB(0,0,25)
  frm.BorderMode = Enum.BorderMode.Inset
  frm.BorderSizePixel = 5
  frm.Parent = hr
  Corner(0,8,frm)
  local frmStroke = Stroke(frm, "ASMBorder",255,255,255,"LJMRound",5,0)
  local frmGra = Gradient(frmStroke, 0,0,0,
      {Color3.new(1,1,0),Color3.new(0,1,1)})

  local frmsca = Instance.new("UIScale")
  frmsca.Scale = 0.01
  frmsca.Parent = frm

  local credit = Instance.new("TextLabel")
  credit.Name = "Label"
  credit.Position = UDim2.new(0.55, 0, 0, 2)
  credit.Size = UDim2.new(0.43, 0, 0, 16)
  credit.TextScaled = false
  credit.TextSize = 10
  credit.TextXAlignment = Enum.TextXAlignment.Right
  credit.BackgroundTransparency = 1
  credit.TextColor3 = Color3.new(1,1,1)
  credit.Text = 'Gui by <b><font color="rgb(0,255,255)">Arc</font><font color="rgb(255,255,0)">Script</font>&apos; Dev</b>'
  credit.RichText = true
  credit.Parent = frm

  local title = Instance.new("TextLabel")
  title.Name = "Title"
  title.Size = UDim2.new(1,0,0,42)
  title.Position = UDim2.new(0,0,0,14)
  title.BackgroundTransparency = 1
  title.TextColor3 = Color3.new(1,1,1)
  title.BorderMode = Enum.BorderMode.Inset
  title.BorderSizePixel = 8
  title.Text = tostring(ntitle or "Unknown Warning")
  title.TextScaled = true
  title.RichText = false -- server-supplied text must never be parsed as markup
  title.Parent = frm

  local line = Instance.new("Frame")
  line.Name = "Line"
  line.Size = UDim2.new(1,0,0,1)
  line.BackgroundColor3 = Color3.new(1,1,1)
  line.Position = UDim2.new(0,0,0,56)
  line.Parent = frm

  local des = Instance.new("TextLabel")
  des.Name = "Description"
  des.Size = UDim2.new(1,-16,1,-122)
  des.Position = UDim2.new(0,8,0,62)
  des.BackgroundTransparency = 1
  des.TextColor3 = Color3.new(1,1,1)
  des.BorderMode = Enum.BorderMode.Inset
  des.BorderSizePixel = 8
  des.Text = tostring(ndes or "This a blank message for the example.\nThis is from the server by moderator or client saying:\n\nHello, World.")
  des.TextWrapped  = true
  --des.TextScaled = true
  des.TextSize = 13
  des.TextYAlignment = Enum.TextYAlignment.Top
  des.RichText = false
  des.Parent = frm

  local tap = Instance.new("Frame")
  tap.Name = "Tab"
  tap.Size = UDim2.new(1,0,0,55)
  tap.Position = UDim2.new(0,0,1,-55)
  tap.BackgroundTransparency = 1
  tap.BorderMode = Enum.BorderMode.Inset
  tap.BorderSizePixel = 5
  tap.Parent = frm

  local btn = Instance.new("TextButton")
  btn.Name = "Button1"
  btn.Size = UDim2.new(1,-1,0,45)
  btn.BackgroundColor3 = Color3.fromRGB(0,85,255)
  btn.BorderMode = Enum.BorderMode.Inset
  btn.BorderSizePixel = 8
  btn.TextColor3 = Color3.new(1,1,1)
  btn.TextScaled = true
  btn.Text = tostring(nbtn1 or "Button1")
  btn.Parent = tap
  Corner(0,8,btn)

  local btn2 = Instance.new("TextButton")
  btn2.Name = "Button2"
  btn2.Size = UDim2.new(0.5,-1,0,45)
  btn2.Position = UDim2.new(1/2,1,0,0)
  btn2.BackgroundColor3 = Color3.fromRGB(0,85,255)
  btn2.BorderMode = Enum.BorderMode.Inset
  btn2.BorderSizePixel = 8
  btn2.TextColor3 = Color3.new(1,1,1)
  btn2.TextScaled = true
  btn2.Text = tostring(nbtn2 or "Button2")
  btn2.Visible = frmbtn
  btn2.Parent = tap
  Corner(0,8,btn2)

  if frmbtn == true then
    btn.Size = UDim2.new(0.5,-1,0,45)
    btn.BackgroundColor3 = Color3.new(1,1,1)
    btn.TextColor3 = Color3.new(0,0,0)
    btn2.Visible = true
  end

  local closing = false
  local function dismiss()
    if closing then return end
    closing = true
    Tween(frmsca, {Scale = 0.01}, 0.2, "Quad")
    Tween(hr, {BackgroundTransparency = 1}, 0.2, "Quad")
    task.delay(0.21, function()
      if frm and frm.Parent then frm:Destroy() end
      if type(onClose) == "function" then onClose() end
    end)
  end

  btn.MouseButton1Click:Connect(function()
    if type(onPrimary) == "function" then
      local ok, value = pcall(onPrimary)
      if not ok then warn("[WarningUI] Primary callback:", value) end
      if ok and value == false then return end
    end
    dismiss()
  end)
  btn2.MouseButton1Click:Connect(function()
    if type(onSecondary) == "function" then
      local ok, value = pcall(onSecondary)
      if not ok then warn("[WarningUI] Secondary callback:", value) end
      if ok and value == false then return end
    end
    dismiss()
  end)

  task.spawn(function()
    while frm and frm.Parent and not closing do
      frmGra.Rotation = (frmGra.Rotation + 4) % 360
      task.wait(0.05)
    end
  end)

  Tween(hr, {BackgroundTransparency = compact and 1 or 0.2}, 0.2)
  Tween(frmsca, {Scale = 1}, 0.2, "Bounce")
  return { close = dismiss, frame = frm }
end

local api = { version = "0.2.0", source = "ExperienceSettings WarningUI" }

-- Register trusted local Luau callbacks before showing Cloud warnings.
-- 'RequireScript' never compiles text returned by a Cloudflare API.
function api.registerScript(id, fn)
  if type(id) ~= "string" or not id:match("^[%a][%w_-]*$") or #id > 64 then
    return false, "Invalid script ID"
  end
  if type(fn) ~= "function" then return false, "Expected Luau function" end
  state.scripts[id] = fn
  return true
end

function api.unregisterScript(id)
  state.scripts[id] = nil
end

local function makeButtonCallback(entry, source, slot)
  local isPrimary = slot == 1
  local action = entry[isPrimary and "primaryAction" or "secondaryAction"] or "ExitUI"
  local scriptId = entry[isPrimary and "primaryScriptId" or "secondaryScriptId"]
  local localFunction = entry[isPrimary and "primaryScript" or "secondaryScript"]
  local legacy = entry[isPrimary and "onPrimary" or "onSecondary"]
  if action == "ExitUI" then
    -- Legacy client callback remains supported for old integrations.
    if source == "client" and type(legacy) == "function" then return legacy end
    return nil
  end
  if action ~= "RequireScript" then return nil end
  if source == "client" and type(localFunction) == "function" then
    return function() return localFunction(entry) end
  end
  if type(scriptId) ~= "string" then return nil end
  return function()
    local handler = state.scripts[scriptId]
    if type(handler) ~= "function" then
      warn("[WarningUI] Unregistered button script: " .. tostring(scriptId))
      return nil -- allow popup to close; don't trap the player
    end
    return handler(entry)
  end
end

local function showNext()
  if state.dead or state.active or #state.queue == 0 then return end
  local entry = table.remove(state.queue, 1)
  state.active = pop(entry.title, entry.description, entry.primaryLabel,
      entry.secondaryLabel ~= nil, entry.secondaryLabel,
      function()
        state.active = nil
        if not state.dead then task.defer(showNext) end
      end, entry.onPrimary, entry.onSecondary, entry.compact)
  state.active.clientKey = entry.clientKey
end

local function queueWarning(entry, source)
  if state.dead or type(entry) ~= "table" then return false, "Invalid warning" end
  if #state.queue >= 20 then return false, "Warning queue is full" end
  local prefix = source == "server" and "SERVER" or "CLIENT"
  local title = "[" .. prefix .. "] " .. tostring(entry.title or "Warning")
  local description = tostring(entry.description or entry.message or "")
  if description == "" then return false, "Message is empty" end
  -- For local client callbacks the function is supplied directly in Luau.
  -- For server notices only a registered script ID can run on button click.
  local action1 = entry.primaryAction or "ExitUI"
  local action2 = entry.secondaryAction or "ExitUI"
  if (action1 ~= "ExitUI" and action1 ~= "RequireScript") or
     (action2 ~= "ExitUI" and action2 ~= "RequireScript") then
    return false, "Invalid button action"
  end
  if source == "server" then
    if action1 == "RequireScript" and type(entry.primaryScriptId) ~= "string" then
      return false, "Button1 script ID required"
    end
    if entry.secondaryLabel and action2 == "RequireScript" and type(entry.secondaryScriptId) ~= "string" then
      return false, "Button2 script ID required"
    end
  elseif action1 == "RequireScript" and type(entry.primaryScript) ~= "function" and
    (type(entry.primaryScriptId) ~= "string" or not state.scripts[entry.primaryScriptId]) then
    return false, "Button1 Luau function required"
  elseif entry.secondaryLabel and action2 == "RequireScript" and
    type(entry.secondaryScript) ~= "function" and
    (type(entry.secondaryScriptId) ~= "string" or not state.scripts[entry.secondaryScriptId]) then
    return false, "Button2 Luau function required"
  end
  local key = source == "client" and entry.clientKey or nil
  local item = {
    clientKey = key,
    compact = source == "client" and entry.compact == true,
    title = title:sub(1, 120),
    description = description:sub(1, 1500),
    primaryLabel = tostring(entry.primaryLabel or "OK"):sub(1, 32),
    secondaryLabel = entry.secondaryLabel and tostring(entry.secondaryLabel):sub(1, 32) or nil,
    onPrimary = makeButtonCallback(entry, source, 1),
    onSecondary = entry.secondaryLabel and makeButtonCallback(entry, source, 2) or nil
  }
  table.insert(state.queue, key and 1 or #state.queue + 1, item)
  showNext()
  return true
end

-- Client warnings are local; they work without any network request.
function api.showClient(data)
  return queueWarning(data, "client")
end

function api.dismissClient(key)
  if type(key) ~= "string" then return end
  for i = #state.queue, 1, -1 do
    if state.queue[i].clientKey == key then table.remove(state.queue, i) end
  end
  if state.active and state.active.clientKey == key then state.active.close() end
end

-- Server warnings are already-verified announcement objects from the Cloud API.
-- ExpiresAt is Unix seconds; the upstream Worker must validate admin authorization.
function api.showServer(data)
  if type(data) ~= "table" then return false, "Invalid server warning" end
  local id = tostring(data.id or "")
  if id == "" or #id > 100 then return false, "Server warning ID required" end
  -- Only Live: clients that start after publication must never see this item.
  local mode = tostring(data.deliveryMode or 'only_live')
  local created = tonumber(data.createdAt)
  if mode ~= 'only_live' and mode ~= 'live_and_after' then return false, 'Invalid delivery mode' end
  if not created then return false, 'Creation timestamp required' end
  local sessionStarted = warningEnv and tonumber(warningEnv.ArcScriptWarningClientStartedAt) or os.time()
  if mode == 'only_live' and created < sessionStarted then
    return false, 'Only Live: announcement was published before client start'
  end
  local expires = tonumber(data.expiresAt)
  if expires and expires <= os.time() then return false, "Warning expired" end
  if state.seen[id] then return false, "Already shown this session" end
  local ok, err = queueWarning(data, "server")
  if ok then
    state.seen[id] = true
    table.insert(state.seenOrder, id)
    if #state.seenOrder > 300 then
      local oldest = table.remove(state.seenOrder, 1)
      state.seen[oldest] = nil
    end
  end
  return ok, err
end

function api.dismiss()
  if state.active then state.active.close() end
end

-- The fetcher is supplied by a trusted caller and returns decoded JSON:
-- { warnings = { { id=..., title=..., message=..., expiresAt=... }, ... } }
-- No API URL, secret, or network function is hardcoded in WarningUI itself.
function api.startServerPolling(fetcher, interval)
  if type(fetcher) ~= "function" then return false, "Fetcher function required" end
  interval = math.clamp(tonumber(interval) or 30, 15, 300)
  state.run += 1
  local currentRun = state.run
  task.spawn(function()
    while not state.dead and currentRun == state.run do
      local ok, data = pcall(fetcher)
      if ok and type(data) == "table" and type(data.warnings) == "table" then
        for _, item in ipairs(data.warnings) do
          if state.dead or currentRun ~= state.run then break end
          api.showServer(item)
        end
      end
      task.wait(interval)
    end
  end)
  return true
end

function api.stopServerPolling()
  state.run += 1
end

function api.destroy()
  if state.dead then return end
  state.dead = true
  state.run += 1
  table.clear(state.queue)
  if fder and fder.Parent then fder:Destroy() end
  state.active = nil
  if type(getgenv) == "function" then
    local env = getgenv()
    if env.WarningUI == api then env.WarningUI = nil end
  end
end

if type(getgenv) == "function" then
  local env = getgenv()
  if type(env.WarningUI) == "table" and type(env.WarningUI.destroy) == "function" then
    pcall(env.WarningUI.destroy)
  end
  env.WarningUI = api
end

return api

]=====]
    return assert(loadstring(sourceUI))()
end

local warningKey = "ArcScriptCenterBanPolicy"
local requestedWarning, deliveredWarning = nil, nil
-- Restricted warnings wait for SetUp; a full ban keeps SetUp open.
local setupWarningReady = false
local pendingPolicyWarning = nil
local function syncPolicyWarning(status)
    if not setupWarningReady and (not status or status.state ~= "ban_ingame") then
        pendingPolicyWarning = status
        return
    end
    -- Unknown never means clear. The policy UI handles connectivity separately.
    if not status then return end
    local item = status.notice or status.ban
    local blocked = status.state ~= "clear" and item ~= nil
    local reference = status.identityVerified == true and item and type(item.reference) == "string"
        and item.reference:match("^••••[0-9A-F][0-9A-F]$") or nil
    local signature = blocked and table.concat({
        status.state, item.duration, tostring(item.expiresAt or ""), item.reason, tostring(item.revision or ""), reference or "",
    }, "\31") or "clear"
    if requestedWarning == signature then return end
    if deliveredWarning == signature then
        requestedWarning = nil
        return
    end
    requestedWarning = signature
    task.defer(function()
        if requestedWarning ~= signature then return end
        local client = bootEnv.__ASC_BAN_V2_CLIENT
        if blocked and not reference and client and client.publicLookup and client.hasPrivateCaseChannel() then
            local ok, verifiedReference = pcall(client.restrictionReference, status)
            if ok then reference = verifiedReference end
        end
        if requestedWarning ~= signature then return end
        requestedWarning = nil
        local ok, queued = pcall(function()
            if blocked then
                local api = ensureWarningUI()
                api.dismissClient(warningKey)
                local duration = item.duration == "permanent" and "Permanent"
                    or ("Temporary\nEnds: " .. os.date("!%Y-%m-%d %H:%M", item.expiresAt + 7 * 3600) .. " ICT")
                local restricted = status.state == "restricted_mode"
                return api.showClient({
                    clientKey = warningKey,
                    compact = restricted,
                    title = restricted and "Restricted Mode" or "Ban in-game",
                    description = "Reason: " .. item.reason .. "\nDuration: " .. duration
                        .. (reference and "\nReference: " .. reference or "")
                        .. (restricted and "\nSettings and Feedback & Appeal are available."
                            or "\nExperienceSettings is unavailable for this account."),
                    primaryLabel = "Close",
                })
            end
            local api = bootEnv.WarningUI
            if api and api.dismissClient then api.dismissClient(warningKey) end
            return true
        end)
        if ok and queued == true then
            deliveredWarning = signature
        else
            warn("[ES] Could not display the restriction warning.")
        end
    end)
end
bootEnv.__ASC_SYNC_POLICY_WARNING = syncPolicyWarning
-- ASC POLICY WARNING END

-- =========================================
-- SAFE LOAD SETUP
-- =========================================

local ok,err =
	pcall(function()

		loadstring(
			game:HttpGet(
				"https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/feedback-appeal-release-track/sandbox/ExperienceSettings-SetUp-Preview.lua"
			)
		)()

	end)

if not ok then

	warn(
		"[ ES ERROR ] Failed to load setup:",
		err
	)

    bootEnv.__ES_BOOTSTRAP_BUSY = nil
    return

end

-- =========================================
-- WAIT READY
-- =========================================

local timeout = 15
local start = tick()

repeat
	task.wait()
until
	getgenv().__ES_READY
    or getgenv().__ES_BANNED == true
    or bootEnv.__ASC_BAN_POLICY_ERROR == true
	or getgenv()[string.char(95, 120, 55, 95, 113)]
	or tick() - start >= timeout

-- =========================================
-- TIMEOUT
-- =========================================

if tick() - start >= timeout then

	warn(
		"[ ES ERROR ] Setup timeout."
	)

    bootEnv.__ES_BOOTSTRAP_BUSY = nil
	return

end

-- =========================================
-- BAN CHECK
-- =========================================

if bootEnv.__ASC_BAN_POLICY_ERROR == true then
    warn("[ES] Ban policy unavailable. Loader blocked pending a verified response.")
    bootEnv.__ES_BOOTSTRAP_BUSY = nil
    return
end

if getgenv().__ES_BANNED == true or getgenv()[string.char(95, 120, 55, 95, 113)] then

	warn(
		"You're banned from ExperienceSettings."
	)

    bootEnv.__ES_BOOTSTRAP_BUSY = nil
	return

end

-- Restricted Mode is routed to MAIN LOADER, not the SetUp-only screen.
-- This is UI routing, NOT an authentication or authorization decision.
if bootEnv.__ES_RESTRICTED_MODE == true then
    if bootEnv.__ES_BAN_SELECTION ~= "restricted_mode" or bootEnv.__ES_BANNED == true then
        warn("[ES] Inconsistent Restricted Mode state; Loader blocked.")
        bootEnv.__ES_BOOTSTRAP_BUSY = nil
        return
    end
end

-- =========================================
-- ES OBJECT
-- =========================================

local ES = getgenv().ES

if not ES then

	warn(
		"[ ES ERROR ] ES missing."
	)

    bootEnv.__ES_BOOTSTRAP_BUSY = nil
	return

end


-- =========================================================
-- PHASE 2: SetUp must finish scanning AND close its splash
-- Do not confuse __ES_READY (ban check passed) with ES.done.
-- =========================================================
-- ===== ERROR SYSTEM =====
local function catch(err)
	ES.error = true
	ES.lastError = tostring(err)
	warn("[ ES ERROR ]:", err)
end

local function safe(f)
	local ok, err = pcall(f)
	if not ok then
		catch(err)
	end
end

-- ===== SCAN SYSTEM =====
local visited = {}
local queue = {}
local scannedCount = 0

local function extractURLs(src)

	local urls = {}

	-- ""
	for url in string.gmatch(
		src,
		'HttpGet%s*%(%s*"([^"]+)"'
	) do

		if url:match("^https?://") then
			table.insert(urls,url)
		end

	end

	-- ''
	for url in string.gmatch(
		src,
		"HttpGet%s*%(%s*'([^']+)'"
	) do

		if url:match("^https?://") then
			table.insert(urls,url)
		end

	end

	-- [[ ]]
	for url in string.gmatch(
		src,
		'HttpGet%s*%(%s*%[%[(.-)%]%]'
	) do

		if url:match("^https?://") then
			table.insert(urls,url)
		end

	end

	return urls

end

local function scan(url)
	if visited[url] then return end
	visited[url] = true

	local ok, src = pcall(function()
		return game:HttpGet(url)
	end)

	if not ok then
		return catch("HttpGet failed: "..tostring(src))
	end

	if not src or src == "" then
		return catch("Empty script: "..url)
	end

	-- ✅ compile check
	local f, err = loadstring(src)
	if not f then
		return catch("Compile error: "..err.." | "..url)
	end

	-- 🔍 หา loadstring ต่อ
	for _, u in ipairs(extractURLs(src)) do
		table.insert(queue, u)
	end

	-- 📊 progress จริง
	scannedCount += 1
ES.progress =
	math.clamp(
		scannedCount * 15,
		0,
		ES.max
	)
end

-- ===== MAIN =====
local function main()

	-- 🔥 ใช้ Loader ตัวใหม่
	table.insert(queue, "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/feedback-appeal-release-track/sandbox/LoaderMainPreview.lua")

	while #queue > 0 do
		if ES.error then break end

		local url = table.remove(queue, 1)

		safe(function()
			scan(url)
		end)
	end

end

-- RUN
safe(main)

-- DONE: mark the progress only after the full compile/URL scan finishes.
if ES.error then
    warn("[ES][SetUp] Script validation failed; Loader will not be started.")
    getgenv().__ES_BOOTSTRAP_BUSY = nil
    return
end
ES.progress = ES.max
task.wait(0.2) -- allow the progress bar to reach 100% visually
ES.done = true


-- Wait until the SetUp script has completed its fade-out and destroyed its ScreenGui.
-- A 10-second timeout prevents a broken SetUp from opening the Loader prematurely.
do
    local coreGui = game:GetService("CoreGui")
    local deadline = os.clock() + 10
    repeat
        if bootEnv.__ES_BANNED or ES.error or bootEnv.ES ~= ES then
            warn("[ES][SetUp] Aborted: denied, invalidated or failed during finish.")
            bootEnv.__ES_BOOTSTRAP_BUSY = nil
            return
        end
        local stillShowing = coreGui:FindFirstChild("ExperienceSettings-SetUp") ~= nil
        local finishedSignal = bootEnv.__ES_SETUP_FINISHED == true
        -- Compatible with previous SetUp versions that do not send this explicit signal.
        if ES.done == true and not stillShowing and
            (finishedSignal or bootEnv.__ES_SETUP_FINISHED == nil) then
            break
        end
        if os.clock() >= deadline then
            warn("[ES][SetUp] Timed out waiting for the intro screen to close. Loader blocked.")
            bootEnv.__ES_BOOTSTRAP_BUSY = nil
            return
        end
        task.wait(0.05)
    until false
end

-- SetUp has finished fading and its ScreenGui is gone.
-- Deliver only the latest queued policy warning, before Loader Rejoiner.
setupWarningReady = true
if pendingPolicyWarning then
    local latest = pendingPolicyWarning
    pendingPolicyWarning = nil
    syncPolicyWarning(latest)
end

-- =========================================================
-- PHASE 3: Only now is the Loader Rejoiner allowed to appear.
-- =========================================================
-- Strict synchronous Get Load / Always Load gate (v0.5.35).
-- A parallel task.spawn previously allowed Main UI to run before the Loader returned.
do
    local env = getgenv()
    env.__ES_LOAD_GRANTED = false
    local player = game:GetService("Players").LocalPlayer
    if not player then
        warn("[ES][Gate] No LocalPlayer")
        bootEnv.__ES_BOOTSTRAP_BUSY = nil
        return
    end
    local character = player.Character or player.CharacterAdded:Wait()
    character:WaitForChild("HumanoidRootPart", 20)
    pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health, true) end)
    local ok, allowed = pcall(function()
        local url = "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/feedback-appeal-release-track/sandbox/Loader-UI-BanMode-STAGING.lua"
        local src = game:HttpGet(url)
        local chunk, why = loadstring(src)
        if not chunk then error("LoaderSettings compile: " .. tostring(why)) end
        return chunk()
    end)
    if not ok or allowed ~= true or env.__ES_BANNED == true
        or env.__ES_READY ~= true or env.ES ~= ES or ES.error then
        warn("[ES][Gate] Main initialization blocked: " .. tostring(allowed))
        bootEnv.__ES_BOOTSTRAP_BUSY = nil
        return
    end
    env.__ES_LOAD_GRANTED = true
    print("[ES][Gate] Authorized by Get Load or Always Load")
end
-- SetUp, source scanning and the manual Get Load prompt can outlive a policy.
local function canStartMain()
    local client = bootEnv.__ASC_BAN_V2_CLIENT
    if not client then return not bootEnv.__ASC_BAN_V2_PREVIEW end
    local status = bootEnv.__ASC_BAN_V2_STATE
    if client.secondsRemaining(status) <= 0 then
        status = client.policy()
        bootEnv.__ASC_BAN_V2_STATE = status
    end
    local item = status and (status.notice or status.ban)
    if bootEnv.__ASC_SYNC_POLICY_WARNING then pcall(bootEnv.__ASC_SYNC_POLICY_WARNING, status) end
    bootEnv.__ASC_BAN_POLICY_ERROR = status == nil
    bootEnv.__ES_BANNED = status ~= nil and status.state == "ban_ingame"
    bootEnv.__ES_RESTRICTED_MODE = status ~= nil and status.state == "restricted_mode"
    bootEnv.__ES_BAN_SELECTION = status and status.state ~= "clear" and status.state or nil
    bootEnv.__ES_BAN_DURATION = item and item.duration
    bootEnv.__ES_BAN_SELECTION_ASSIGNED = item ~= nil and item.legacy ~= true
    if status and not bootEnv.__ES_BANNED then return true end
    bootEnv.__ES_LOAD_GRANTED = false
    warn("[ES] Access changed or could not be checked. Reopen the Ban Center preview or rejoin.")
    return false
end
if not canStartMain() then
    bootEnv.__ES_BOOTSTRAP_BUSY = nil
    return
end
-- From this point Main UI is allowed; further stages handle their own startup guards.
bootEnv.__ES_BOOTSTRAP_BUSY = nil

-- Global announcements keep their existing post-SetUp startup.
-- Policy notices can already have initialized the same WarningUI.
task.spawn(function()
    if getgenv().__ES_BANNED or not getgenv().__ES_READY then return end
    local ok, err = pcall(function()
        local sourceConnector = [=====[
-- ArcScriptCenter Phase 2 - Production Bootstrap + WarningUI Connector v0.5.41.1
-- Read-only public HTTPS GET only. NO secrets, Roblox UserId, or executable source.
-- Load AFTER the existing WarningUI is initialized. Never use the staging Worker.

local env = type(getgenv) == "function" and getgenv() or nil
assert(type(env) == "table", "ArcScriptCenter requires getgenv()")
local ui = env.WarningUI
assert(type(ui) == "table" and type(ui.startServerPolling) == "function",
    "WarningUI must be initialized before the connector")

-- Replace older connector's polling loop, but keep WarningUI and its UI/UX intact.
if type(env.ArcScriptWarningConnector) == "table"
    and type(env.ArcScriptWarningConnector.stop) == "function" then
    pcall(env.ArcScriptWarningConnector.stop)
end
if type(ui.stopServerPolling) == "function" then
    ui.stopServerPolling()
end

local HttpService = game:GetService("HttpService")
local BASE = "https://arcscriptcenter-api.kogpasan14.workers.dev"
local BOOTSTRAP_PATH = "/api/v1/client/bootstrap"
local WARNINGS_PATH = "/api/v1/warnings"
local requestFn = type(request) == "function" and request
    or type(http_request) == "function" and http_request
    or type(syn) == "table" and type(syn.request) == "function" and syn.request
    or type(http) == "table" and type(http.request) == "function" and http.request
    or type(env.request) == "function" and env.request

local status = {
    connectorVersion = "0.5.41.1-phase2",
    host = BASE,
    bootstrap = {ok=false, state="pending"},
    warnings = {ok=false, state="pending", count=0},
}
env.ArcScriptClientStatus = status
env.ArcScriptWarningStatus = {ok=false, stage="pending", count=0}

local function publicGetJSON(path, maxBytes)
    -- Never construct URLs from untrusted server responses.
    if path ~= BOOTSTRAP_PATH and path ~= WARNINGS_PATH then
        error("Unrecognized public endpoint")
    end
    local url = BASE .. path
    local raw
    if type(requestFn) == "function" then
        local ok, response = pcall(requestFn, {
            Url = url, Method = "GET", Headers = {Accept="application/json"}, Timeout=10
        })
        if not ok or type(response) ~= "table" then
            error("Public API HTTP request unavailable")
        end
        local httpStatus = tonumber(response.StatusCode or response.Status or 0)
        if httpStatus ~= 200 then
            error("Public API HTTP " .. tostring(httpStatus))
        end
        raw = response.Body
    else
        -- Compatibility fallback; still only uses the fixed Production HTTPS URL.
        local ok, body = pcall(function() return game:HttpGet(url) end)
        if not ok then error("HTTPS GET is unavailable") end
        raw = body
    end
    if type(raw) ~= "string" or #raw > maxBytes then
        error("Invalid or oversized public API response")
    end
    local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok or type(data) ~= "table" or data.ok ~= true then
        error("Invalid public API JSON")
    end
    return data
end

local nextBootstrapRetry = 0
local lastWarningLog = 0
local function readBootstrap()
    local now=os.time()
    if status.bootstrap.ok or now < nextBootstrapRetry then return end
    nextBootstrapRetry=now+120
    local ok, data=pcall(publicGetJSON, BOOTSTRAP_PATH, 16384)
    if ok and data.service == "ArcScriptCenter" and data.protocol == 1
        and data.client == "executor_sunc" and data.mode == "read_only_public"
        and type(data.version) == "string"
        and type(data.endpoints) == "table"
        and data.endpoints.publicWarnings == WARNINGS_PATH then
        status.bootstrap={ok=true,state="online",version=data.version,
            protocol=data.protocol,lastSuccess=now}
    else
        status.bootstrap={ok=false,state="degraded",
            error=ok and "Unexpected bootstrap protocol" or tostring(data)}
        -- A transient Bootstrap error does not block local UI or public warnings.
    end
end

local function warningsFetcher()
    readBootstrap()
    local ok, data=pcall(publicGetJSON, WARNINGS_PATH, 131072)
    if not ok or type(data.warnings) ~= "table" then
        local reason=ok and "Missing warnings array" or tostring(data)
        local previous=status.warnings.lastSuccess
        status.warnings={ok=false,state="degraded",error=reason,
            lastSuccess=previous,count=0}
        env.ArcScriptWarningStatus={ok=false,stage="fetch",error=reason,
            lastSuccess=previous,count=0}
        if os.time()-lastWarningLog >= 120 then
            warn("[ArcScriptCenter Phase2] Public warnings: " .. reason)
            lastWarningLog=os.time()
        end
        return nil
    end
    local now=os.time()
    status.warnings={ok=true,state="online",lastSuccess=now,
        count=#data.warnings}
    env.ArcScriptWarningStatus={ok=true,stage="online",lastSuccess=now,
        count=#data.warnings}
    return data
end

-- Bootstrap is only advisory. WarningUI retains its existing queue, deduplication,
-- Only Live and expiry checks; it never executes code from the API.
readBootstrap()
local started, reason=ui.startServerPolling(warningsFetcher, 15)
assert(started, tostring(reason or "Could not start public warnings polling"))

local controller={
    version="0.5.41.1-phase2",
    baseUrl=BASE,
    getStatus=function() return status end,
    stop=function()
        if type(ui.stopServerPolling) == "function" then
            ui.stopServerPolling()
        end
        status.warnings.state="stopped"
    end,
}
env.ArcScriptWarningConnector=controller
return controller
]=====]
        ensureWarningUI()
        local startConnector, connectorCompile = loadstring(sourceConnector)
        if not startConnector then error('Warning connector compile: '..tostring(connectorCompile)) end
        startConnector()
    end)
    if not ok then warn('[ArcScriptCenter WarningUI] '..tostring(err)) end
end)



local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local hrp = character:WaitForChild("HumanoidRootPart")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true)


-- Monitor & auto-run (executor)
local URL = "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/main/loadstring.lua"
local CoreGui = game:GetService("CoreGui")

-- ========== HELPER ==========
-- Return both layout candidates rather than only the first one.
-- If both HealthBars exist during a Roblox UI rollout, the temporary UI
-- might still have been parented to the other HealthBar.
local function getHealthBars()
    local outer = CoreGui:FindFirstChild("TopBarApp")
    local app = outer and outer:FindFirstChild("TopBarApp")
    if not app then return nil, nil end

    local topBarFrame = app:FindFirstChild("TopBarFrame")
    local topRightFrame = topBarFrame and topBarFrame:FindFirstChild("TopRightFrame")
    local unibarLeftFrame = app:FindFirstChild("UnibarLeftFrame")

    local newBar = topRightFrame and topRightFrame:FindFirstChild("HealthBar")
    local oldBar = unibarLeftFrame and unibarLeftFrame:FindFirstChild("HealthBar")
    return newBar, oldBar
end

local function getHealthBar()
    local newBar, oldBar = getHealthBars()
    return newBar or oldBar
end

local function findExperienceSettings()
    -- It may already have been reparented by another stage of the loader.
    local direct = CoreGui:FindFirstChild("ExperienceSettings")
    if direct then return direct end

    -- Search BOTH candidates, even if the other HealthBar has priority.
    local newBar, oldBar = getHealthBars()
    return (newBar and newBar:FindFirstChild("ExperienceSettings"))
        or (oldBar and oldBar:FindFirstChild("ExperienceSettings"))
end

local function removeLoadBackground()
    local bar = getHealthBar()
    local exp = CoreGui:FindFirstChild("ExperienceSettings")
        or (bar and bar:FindFirstChild("ExperienceSettings"))
    local menu = exp and exp:FindFirstChild("Menu")
    if menu then
		local bg = menu:FindFirstChild("Load_Background")
		if bg then
			pcall(function() bg:Destroy() end)
			warn("[Monitor] Removed Load_Background before re-executing.")
		end
	end
end

-- ========== MAIN ==========
local reloading = false
_G.HealthBarExecutedOnce = _G.HealthBarExecutedOnce or false

local function tryReload()
	if reloading then return end
	reloading = true

	if _G.HealthBarExecutedOnce then
		-- ครั้งที่ 2 ขึ้นไป: ลบ Load_Background ก่อน
		removeLoadBackground()
	else
		warn("[Monitor] First-time execute, skipping Load_Background removal.")
	end

	local ok, src = pcall(function()
		return game:HttpGet(URL)
	end)
	if not ok then
		warn("HttpGet failed:", src)
		reloading = false
		return
	end

	local f, err = loadstring(src)
	if not f then
		warn("Compile failed:", err)
		reloading = false
		return
	end

	local ok2, res = pcall(f)
	if not ok2 then
		warn("Runtime error after loading:", res)
		warn(debug.traceback())
	else
		print("[Monitor] loadstring executed successfully.")
	end

	_G.HealthBarExecutedOnce = true
	reloading = false
end

-- ========== MONITOR LOOP ==========
local monitorReady = false
task.spawn(function()
	while true do
		task.wait(1)
		local hb = monitorReady and getHealthBar()
		if hb then
			local exp = CoreGui:FindFirstChild("ExperienceSettings")
                or hb:FindFirstChild("ExperienceSettings")
            if not exp then
                tryReload()
            end
		else
			-- HealthBar หาย ไม่ reload ตามที่ระบุ
		end
	end
end)
-- ==============

-- A separate entrypoint normally launches main/ExperienceSettings.lua.
-- If that entrypoint was skipped, failed or returned before creating the UI,
-- start it here *once*. Note: upload the PATCHED ExperienceSettings.lua to
-- the main branch too; main/loadstring.lua uses that path.
local UI_SOURCE_URL = "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/main/ExperienceSettings.lua"
task.spawn(function()
    task.wait(3) -- Give the normal entrypoint a chance to create the UI.
    if findExperienceSettings() then
        print("[ES][Bootstrap] UI already exists; no duplicate startup.")
        return
    end
    local env = getgenv()
    if env.__ES_UI_BOOTSTRAP_RUNNING or env.__ES_UI_SCRIPT_RUNNING then
        print("[ES][Bootstrap] UI script already in progress; monitoring it.")
        return
    end

    env.__ES_UI_BOOTSTRAP_RUNNING = true
    local ok, err = pcall(function()
        print("[ES][Bootstrap] No UI after 3s; fetching ExperienceSettings.lua...")
        local source = game:HttpGet(UI_SOURCE_URL)
        print("[ES][Bootstrap] UI source downloaded; compiling...")
        local chunk, compileError = loadstring(source)
        if not chunk then
            error("ExperienceSettings.lua compile error: " .. tostring(compileError))
        end
        print("[ES][Bootstrap] Executing ExperienceSettings.lua...")
        chunk()
    end)
    env.__ES_UI_BOOTSTRAP_RUNNING = nil
    if not ok then
        warn("[ES][Bootstrap] UI script failed: " .. tostring(err))
    elseif findExperienceSettings() then
        print("[ES][Bootstrap] ExperienceSettings UI created.")
    else
        warn("[ES][Bootstrap] ExperienceSettings.lua returned without creating UI. Make sure main/ExperienceSettings.lua is the updated dual-path file.")
    end
end)

-- Locate ExperienceSettings under either HealthBar or CoreGui.
-- Unlike a path warning, this also reports whether the bootstrap began.
local expsting
local uiDeadline = os.clock() + 45
repeat
    expsting = findExperienceSettings()
    if expsting then break end
    task.wait(0.1)
until os.clock() >= uiDeadline

if not expsting then
    local newBar, oldBar = getHealthBars()
    if newBar or oldBar then
        warn("[ExperienceSettings] HealthBar found, but no UI after 45s. Check [ES][Bootstrap] logs and verify main/ExperienceSettings.lua is updated.")
    else
        warn("[ExperienceSettings] HealthBar not found at either TopBar path within 45s (new: TopBarFrame.TopRightFrame.HealthBar; old: UnibarLeftFrame.HealthBar).")
    end
    return
end

-- Keep waiting for the loading animation, but handle a UI that has
-- already moved to CoreGui and no longer has a loading background.
local ready = false
local readyDeadline = os.clock() + 45
repeat
    local menu = expsting:FindFirstChild("Menu")
    local background = menu and menu:FindFirstChild("Load_Background")
    local skip = background and background:FindFirstChild("Skip")
    local loader = skip and skip:FindFirstChild("Loader")

    if loader and loader.Size == UDim2.new(1, 0, 1, 0) then
        ready = true
        break
    end

    if expsting.Parent == CoreGui and menu and not background then
        ready = true -- Already completed by another stage.
        break
    end

    task.wait(0.05)
until os.clock() >= readyDeadline

if not ready then
    warn("[ExperienceSettings] UI folder found, but loading animation did not finish within 45s.")
    return
end

-- Parent is temporary in either TopBar layout; move it only after loading.
if expsting.Parent ~= CoreGui then
    expsting.Parent = CoreGui
end
monitorReady = true

-- Auto-destroy Load_Background
task.wait(3)

task.spawn(function()
    local CoreGui = game:GetService("CoreGui")

    while task.wait(0.05) do
        local bar = getHealthBar()
        local exp = CoreGui:FindFirstChild("ExperienceSettings")
            or (bar and bar:FindFirstChild("ExperienceSettings"))
        local path = exp and exp:FindFirstChild("Menu")

        -- ถ้าถึงตรงนี้ได้แล้วจึงเช็ค Load_Background
        if path then
            local lb = path:FindFirstChild("Load_Background", 10)
            if lb then
                lb:Destroy()
            end
        end
    end
end)

-- Auto-destroy Folder 
task.spawn(function()
    local CoreGui = game:GetService("CoreGui")

    while task.wait(0.05) do
        -- หา ExperienceSettings ให้แน่นอนก่อน
        local bar = getHealthBar()
        local path = CoreGui:FindFirstChild("ExperienceSettings")
            or (bar and bar:FindFirstChild("ExperienceSettings"))

        if not path then
            continue
        end

        -- เก็บจำนวน child แต่ละชื่อ
        local nameCount = {}

        for _, obj in ipairs(path:GetChildren()) do
            local n = obj.Name
            nameCount[n] = nameCount[n] or {}
            table.insert(nameCount[n], obj)
        end

        -- ถ้าชื่อไหนมีมากกว่า 1 → ลบตัวที่เกินออก
        for name, list in pairs(nameCount) do
            if #list > 1 then
                -- เริ่มลบตั้งแต่ตัวที่ 2 ขึ้นไป
                for i = 2, #list do
                    list[i]:Destroy()
                end
            end
        end
    end
end)

-- Function_Two.lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/Function_Two.lua"))()

-- BouncyAndHiglightImagsButton
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/loadstring/BouncyAndHighlightImageButton.lua"))()
print("[ BouncyAndHiglightImagsButton ] Successful loaded.")

local asrt =
	game:GetService("CoreGui")
	.ExperienceSettings
	.Menu
	.TopBar
	.Holder

local MAX_ZINDEX = 2147483646

local function SetZIndexRecursive(obj)
	pcall(function()
		obj.ZIndex = MAX_ZINDEX
	end)

	for _, child in ipairs(obj:GetDescendants()) do
		pcall(function()
			child.ZIndex = MAX_ZINDEX
		end)
	end
end

SetZIndexRecursive(asrt)

-- The main ExperienceSettings instance was moved to CoreGui above.
-- Only remove an obsolete second Menu still attached to a HealthBar.
local staleBar = getHealthBar()
local staleExp = staleBar and staleBar:FindFirstChild("ExperienceSettings")
local sata = staleExp and staleExp:FindFirstChild("Menu")
if sata then sata:Destroy() end


-- Base UI and HealthBar discovery can also outlive the check at Get Load.
local display, displayProperty, priorDisplay
if bootEnv.__ASC_BAN_V2_CLIENT then
    display = asrt:FindFirstAncestorOfClass("ScreenGui") or asrt.Parent.Parent
    displayProperty = display:IsA("ScreenGui") and "Enabled" or "Visible"
    priorDisplay = display[displayProperty]
    display[displayProperty] = false
    if not canStartMain() then return end
    display[displayProperty] = priorDisplay
end

-- Ban in-game never reaches here. Restricted Mode deliberately loads MAIN
-- while skipping the Editor/Search/RecommendedScript modules.
local isRestrictedMode = bootEnv.__ES_RESTRICTED_MODE == true
local toolBase = "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/"
local loadedTools = {}
local function loadTool(name)
    if loadedTools[name] then return end
    assert(loadstring(game:HttpGet(toolBase .. name)))()
    loadedTools[name] = true
end
if not isRestrictedMode then
    loadTool("RecommendedScript.lua")
end

-- Editor creates Menu.Notification, shared by Arcsen.
-- Keep the original initialization order in restricted mode as well.
-- The restricted UI gate below disables Editor's button, not its initialization.
loadTool("Editor.lua")
local notification = asrt and asrt:FindFirstAncestor("ExperienceSettings")
local notificationMenu = notification and notification:FindFirstChild("Menu")
assert(notificationMenu and notificationMenu:FindFirstChild("Notification"),
    "[ES] Editor did not initialize Menu.Notification before Arcsen")
print("[ES][QA] Editor initialized; shared Notification ready.")

-- Apply the Restricted UI lock BEFORE Arcsen can create chat controls.
-- Server-side account authorization is a separate required release gate.
if isRestrictedMode then
    local okGate, gateResult = pcall(function()
        local gateCode = game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/feedback-appeal-release-track/sandbox/RestrictedMode-Topbar-STAGING.lua")
        return assert(loadstring(gateCode))()
    end)
    if not okGate or gateResult ~= true then
        warn("[ES][Restricted] Missing UI gate; cannot enable unrestricted UI.")
        local gui = game:GetService("CoreGui"):FindFirstChild("ExperienceSettings")
        if gui and gui:IsA("ScreenGui") then gui.Enabled = false end
        local menu = gui and gui:FindFirstChild("Menu")
        if menu and menu:IsA("GuiObject") then menu.Visible = false end
        return
    end
end

-- Trace the exact handoff without changing restricted-mode permissions.
-- The Roblox TopBarApp old/new paths are separate from ExperienceSettings.Menu.TopBar.
-- Do not wait on either Roblox layout to lock ExperienceSettings controls.
local qaArcsenStarted = false
local qaArcsenFinished = false
task.spawn(function()
    task.wait(12)
    if qaArcsenStarted and not qaArcsenFinished then
        warn("[ES][QA][Arcsen] Still initializing after 12s; inspect pending WaitForChild dependencies (Notification / AIOpenSource).")
    end
end)

-- Arcsen stays available for Settings > ArcScriptCenter > Feedback & Appeal.
-- STAGING-only patched UI is read-only while Restricted Mode is active.
-- This PREVIEW always uses the STAGING Arcsen source, including for unbanned QA
-- accounts, to avoid accidentally invoking the normal live Arcsen in a test.
local arcsenUrl = "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/feedback-appeal-release-track/sandbox/Arcsen-Preview.lua"
print("[ES][QA] Starting Arcsen-Preview.lua")
qaArcsenStarted = true
local qaArcsenOk, qaArcsenErr = xpcall(function()
    local source = game:HttpGet(arcsenUrl)
    local compiled, compileError = loadstring(source)
    assert(compiled, tostring(compileError))
    return compiled("ban_qa")
end, function(err)
    return tostring(err) .. "\\n" .. debug.traceback()
end)
qaArcsenFinished = true
if not qaArcsenOk then
    warn("[ES][QA] Arcsen-Preview failed: " .. tostring(qaArcsenErr))
    error(qaArcsenErr, 0)
end
print("[ Arcsen ] Successful loaded.")

if not isRestrictedMode then
    loadTool("Search.lua")
    print("[ Search ] Successful loaded.")
end

-- ASC BAN V2 MAIN REFRESH BEGIN
if bootEnv.__ASC_BAN_V2_CLIENT then
    local client = bootEnv.__ASC_BAN_V2_CLIENT
    local hiddenForPolicy = false
    local function hideForPolicy()
        if not hiddenForPolicy then priorDisplay = display[displayProperty] end
        display[displayProperty], hiddenForPolicy = false, true
    end
    local function showBlocked(message)
        hideForPolicy()
        warn(message)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "ExperienceSettings", Text = message, Duration = 8,
            })
        end)
    end

    -- A stricter policy cannot unwind modules already initialized. Rejoin
    -- uses the original SetUp path to construct the UI for the new policy.
    local needsRejoin, restoring, refreshRequested = false, false, false
    bootEnv.__ASC_REQUEST_BAN_REFRESH = function() refreshRequested = true end
    local function active()
        return asrt.Parent and bootEnv.__ASC_BAN_V2_CLIENT == client
    end
    local function updateArcsen()
        local gate = bootEnv.ArcScriptPolicyGate
        if gate and gate.refresh then gate.refresh() end
    end
    local function suspendExpired()
        bootEnv.__ASC_BAN_V2_STATE = nil
        if not hiddenForPolicy then showBlocked("Ban status unavailable. Waiting for the server.") end
        updateArcsen()
    end
    task.spawn(function()
        local nextAttempt = 0
        while active() do
            local before = bootEnv.__ASC_BAN_V2_STATE
            local now = os.clock()
            local pollAt = math.max(nextAttempt, before and now + client.secondsRemaining(before) - 2 or now)
            repeat
                if before and client.secondsRemaining(before) <= 0 then
                    suspendExpired()
                    before = nil
                end
                if os.clock() >= pollAt or (refreshRequested and os.clock() >= nextAttempt) then break end
                task.wait(0.25)
            until not active()
            if not active() then break end

            refreshRequested = false
            local checking = true
            if before then
                task.delay(client.secondsRemaining(before), function()
                    if checking and active() then suspendExpired() end
                end)
            end
            local status = client.policy()
            checking = false
            if not active() then break end
            nextAttempt = os.clock() + (status and 2 or 5)
            bootEnv.__ASC_BAN_V2_STATE = status
            if bootEnv.__ASC_SYNC_POLICY_WARNING then pcall(bootEnv.__ASC_SYNC_POLICY_WARNING, status) end
            if not status then
                suspendExpired()
            elseif status.state == "ban_ingame" or (status.state == "restricted_mode" and (not isRestrictedMode or restoring)) then
                if not needsRejoin then showBlocked("Your access changed. Rejoin to load the correct restriction screen.") end
                needsRejoin = true
            elseif not needsRejoin then
                if status.state == "clear" and isRestrictedMode then
                    hideForPolicy()
                    restoring = true
                    local okRestore = pcall(function()
                        loadTool("RecommendedScript.lua")
                        loadTool("Editor.lua")
                        loadTool("Search.lua")
                    end)
                    if not okRestore then
                        needsRejoin = true
                        showBlocked("Status checked. Rejoin to restore all ExperienceSettings tools.")
                    elseif client.secondsRemaining(status) > 0 then
                        isRestrictedMode, restoring = false, false
                        bootEnv.__ES_RESTRICTED_MODE = false
                        bootEnv.__ES_BAN_SELECTION, bootEnv.__ES_BAN_DURATION = nil, nil
                        bootEnv.__ES_BAN_SELECTION_ASSIGNED = false
                        local controller = bootEnv.ESRestrictedTopbarController
                        if controller then controller.stop() end
                    end
                end
                if not needsRejoin and hiddenForPolicy and not restoring and client.secondsRemaining(status) > 0 then
                    display[displayProperty], hiddenForPolicy = priorDisplay, false
                end
            end
            updateArcsen()
        end
    end)
end
-- ASC BAN V2 MAIN REFRESH END

-- Anniversary (The event has ended.)
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/Anniversary.lua"))()

------------------------------------------------------------
local CoreGui = game:GetService("CoreGui")

task.spawn(function()
    while task.wait(0.2) do
        local menu = CoreGui:FindFirstChild("ExperienceSettings")
        if not menu then continue end
        
        local Menu1 = menu:FindFirstChild("Menu")
        if not Menu1 then continue end
        
        local topBar = Menu1:FindFirstChild("TopBar")
        if not topBar then continue end
        
        local holder = topBar:FindFirstChild("Holder")
        if not holder then continue end
        
        local OC = holder:FindFirstChild("a1_Open/Close")
        if not OC then continue end

        OC.BackgroundColor3 = Color3.fromRGB(255,255,255)

        local stroke = OC:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color = Color3.fromRGB(255,255,255)
        end

        if OC.Image == "rbxassetid://112166445155251" then
            OC.Image = "rbxassetid://133900380566355"
        elseif OC.Image == "rbxassetid://103716616779537" then
            OC.Image = "rbxassetid://103716616779537" -- logo 
        end
    end
end)
------------------------------------------------------------
print("[ TopBar ] Logo change successful")
print("------------------------------------------------------------")

task.spawn(function()
	local StarterGui = game:GetService("StarterGui")
    
    -- #1 Notification (Success)
    StarterGui:SetCore("SendNotification", {
        Title = "Successful loaded.";
        Text = "Thanks for using!";
        Duration = 5;
        Icon = "rbxassetid://131296854308169";
    })
    task.wait(5)
    -- #2 Notification (Info / Beta)
    StarterGui:SetCore("SendNotification", {
        Title = "Beta";
        Text = "Script is still beta.";
        Duration = 5;
        Icon = "rbxassetid://110099691300745";
    })
end)

task.wait(1)
-- ======== Secondary access check ========
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local plr = Players.LocalPlayer

local Menu = CoreGui:WaitForChild("ExperienceSettings", 10)
if Menu then Menu = Menu:FindFirstChild("Menu") end
local valueGui = getHealthBar()
if valueGui then valueGui = valueGui:FindFirstChild("ValueFolder") end
if valueGui then valueGui = valueGui:FindFirstChild("ValueGui") end

local _0x31 = {
    [string.char(85,115,101,114,110,97,109,101,115)] = {
        ["Roblox"] = true,
        ["makiro5556"] = true,
    },
    [string.char(85,115,101,114,73,100,115)] = {
        -- [123456789] = true,
		-- [11810742331] = true,
    }
}

local function _0x32(_0x33, _0x34)
    if type(_0x33) ~= "table" or not _0x34 then return false end
    local _0x35 = _0x33[string.char(85,115,101,114,110,97,109,101,115)]
        or _0x33[string.char(117,115,101,114,110,97,109,101,115)]
        or _0x33[string.char(78,97,109,101,115)]
        or _0x33[string.char(110,97,109,101,115)]
    local _0x36 = _0x33[string.char(85,115,101,114,73,100,115)]
        or _0x33[string.char(85,115,101,114,73,68,115)]
        or _0x33[string.char(117,115,101,114,73,100,115)]
        or _0x33[string.char(73,100,115)]
        or _0x33[string.char(105,100,115)]
    local function _0x37(_0x38, _0x39, _0x3A)
        if type(_0x38) ~= "table" then return false end
        for _0x3B, _0x3C in pairs(_0x38) do
            local _0x3D = _0x3A
                and type(_0x3B) == "string" and string.lower(_0x3B) == string.lower(tostring(_0x39))
                or (not _0x3A and tonumber(_0x3B) == tonumber(_0x39))
            if _0x3D and _0x3C then return true end
        end
        return false
    end
    if _0x37(_0x35, _0x34.Name, true) or _0x37(_0x36, _0x34.UserId, false) then return true end
    if _0x37(_0x33, _0x34.Name, true) or _0x37(_0x33, _0x34.UserId, false) then return true end
    for _, _0x3E in pairs(_0x33) do
        if type(_0x3E) == "table" then
            local _0x3F = _0x3E.User or _0x3E.Username or _0x3E.username or _0x3E.Name or _0x3E.name
            local _0x40 = _0x3E.UserId or _0x3E.UserID or _0x3E.userId or _0x3E.userID
            if (_0x3F and string.lower(tostring(_0x3F)) == string.lower(_0x34.Name))
                or (_0x40 and tonumber(_0x40) == _0x34.UserId) then return true end
        elseif type(_0x3E) == "string" or type(_0x3E) == "number" then
            if string.lower(tostring(_0x3E)) == string.lower(_0x34.Name)
                or tonumber(_0x3E) == _0x34.UserId then return true end
        end
    end
    return false
end

local _0x41 = getgenv()._ES
local _0x42 = type(_0x41) == "table" and _0x41 or _0x31
if _0x32(_0x42, plr)
    and not (bootEnv.__ES_RESTRICTED_MODE == true
        and bootEnv.__ES_BAN_SELECTION == "restricted_mode") then
    task.spawn(function()
        while task.wait(0.1) do
            if Menu then pcall(function() Menu.Enabled = false end) end
            if valueGui then pcall(function() valueGui.Enabled = false end) end
        end
    end)

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "ACCESS RESTRICTED",
            Text = "You cannot use ExperienceSettings.",
            Duration = 15,
            Icon = "rbxassetid://117179620345399",
        })
    end)
    return
end

-- Set Y
local CoreGui = game:GetService("CoreGui")

local profileStatus = CoreGui:WaitForChild("ExperienceSettings", 10)
    :WaitForChild("Menu", 10)
    :WaitForChild("ProfileStatus", 10)

while not profileStatus.Parent do
    profileStatus.AncestryChanged:Wait()
end

profileStatus.Position = UDim2.new(
    profileStatus.Position.X.Scale,
    profileStatus.Position.X.Offset,
    1, -- Y Scale
    0  -- Y Offset
)
