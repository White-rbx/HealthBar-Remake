-- Well 4.14

--[[
 HELLO SCRIPTBLOX AND HAXHELL USERSSSS WHAT THE ACTUALLY HELL YOU GUYS
 DOING IN THIS RAW SCRIPT? AND YES IT'S MIGHT LOOK TOO AI SLOP BUT -
 GUIS ARE NOT MADE BY AI, ANYWAY I'M STILL LEARNING SCRIPT!

 THANK YOU FOR READINGGGGG *COUGH* *COUGH* *COUGH* *Died adorably*


  anyway you can see there's banned users. I'm not telling you how to- nah :3
]]

-- =========================================
-- RESET
-- =========================================

-- Time of this client execution is used for Only Live warnings.
getgenv().ArcScriptWarningClientStartedAt = os.time()
getgenv().ES = nil
getgenv().__ES_READY = nil
getgenv()[string.char(95, 120, 55, 95, 113)] = nil

-- =========================================
-- SAFE LOAD SETUP
-- =========================================

local ok,err =
	pcall(function()

		loadstring(
			game:HttpGet(
				"https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/loadstring/ExperienceSettings-SetUp.lua"
			)
		)()

	end)

if not ok then

	warn(
		"[ ES ERROR ] Failed to load setup:",
		err
	)

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
	or getgenv()[string.char(95, 120, 55, 95, 113)]
	or tick() - start >= timeout

-- =========================================
-- TIMEOUT
-- =========================================

if tick() - start >= timeout then

	warn(
		"[ ES ERROR ] Setup timeout."
	)

	return

end

-- =========================================
-- BAN CHECK
-- =========================================

if getgenv()[string.char(95, 120, 55, 95, 113)] then

	warn(
		"You're banned from ExperienceSettings."
	)

	return

end

-- =========================================
-- ES OBJECT
-- =========================================

local ES = getgenv().ES

if not ES then

	warn(
		"[ ES ERROR ] ES missing."
	)

	return

end


-- WARNING CENTER: load only after ES SetUp has permitted the user.
-- The Worker sends only DATA; these two trusted modules are embedded here.
-- This avoids a missing GitHub path/branch and keeps startup independent of the dashboard.
task.spawn(function()
    if getgenv().__ES_BANNED or not getgenv().__ES_READY then return end
    local ok, err = pcall(function()
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
 Camera = Workspace.CurrentCamera,

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
gui.DisplayOrder = 2147483645
gui.Parent = fder

local hr = Instance.new("Frame")
hr.Name = "Holder"
hr.Size = UDim2.new(1,0,1,0)
hr.BackgroundTransparency = 1
hr.BackgroundColor3 = Color3.new(0,0,0)
hr.Parent = gui
ListLayout(hr, 0,0,"HCenter","VCenter","SLayout","FillV")

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

local function pop(ntitle, ndes, nbtn1, twoButtons, nbtn2, onClose, onPrimary, onSecondary)
  local frmbtn = twoButtons == true

  local frm = Instance.new("Frame")
  frm.Name = "PopUp"
  frm.Size = UDim2.new(0.8, 0, 0.42, 0)
  local limit = Instance.new("UISizeConstraint")
  limit.MinSize = Vector2.new(240, 210)
  limit.MaxSize = Vector2.new(570, 450)
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

  Tween(hr, {BackgroundTransparency = 0.2}, 0.2)
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
      end, entry.onPrimary, entry.onSecondary)
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
  table.insert(state.queue, {
    title = title:sub(1, 120),
    description = description:sub(1, 1500),
    primaryLabel = tostring(entry.primaryLabel or "OK"):sub(1, 32),
    secondaryLabel = entry.secondaryLabel and tostring(entry.secondaryLabel):sub(1, 32) or nil,
    onPrimary = makeButtonCallback(entry, source, 1),
    onSecondary = entry.secondaryLabel and makeButtonCallback(entry, source, 2) or nil
  })
  showNext()
  return true
end

-- Client warnings are local; they work without any network request.
function api.showClient(data)
  return queueWarning(data, "client")
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
        local sourceConnector = [=====[
-- ArcScriptCenter Cloud Warning Connector v0.5.21 — live 15s one-shot polling
-- Install with WarningUI.lua (Preview v0.1.0+) already loaded.
-- Server means ArcScriptCenter's Cloudflare Worker, NOT another game's Roblox server.
-- Only reads public, approved service notices. No secrets or user data are sent.

local shared = type(getgenv) == 'function' and getgenv() or nil
assert(type(shared) == 'table', 'WarningUI CloudConnector needs getgenv()')

local ui = shared.WarningUI
assert(type(ui) == 'table' and type(ui.startServerPolling) == 'function',
    'Load WarningUI.lua before WarningUI_CloudConnector.lua')

-- Stop older polling loops before starting a new one.
if type(ui.stopServerPolling) == 'function' then
    ui.stopServerPolling()
end

local HttpService = game:GetService('HttpService')
local url = 'https://arcscriptcenter-api.kogpasan14.workers.dev/api/v1/warnings'
local requestFn = type(request) == 'function' and request
    or type(http_request) == 'function' and http_request
    or type(syn) == 'table' and type(syn.request) == 'function' and syn.request
    or type(http) == 'table' and type(http.request) == 'function' and http.request
    or type(shared.request) == 'function' and shared.request

local lastErrorAt = 0
shared.ArcScriptWarningStatus = {ok=false,stage='fetching',lastSuccess=nil,count=0}
local function readWarnings()
    local raw
    if type(requestFn) == 'function' then
        local ok, response = pcall(requestFn, {
            Url = url,
            Method = 'GET',
            Headers = {Accept = 'application/json'},
            Timeout = 10
        })
        if not ok or type(response) ~= 'table' then
            error('Cloud Warning request failed')
        end
        local status = tonumber(response.StatusCode or response.Status or 0)
        if status ~= 200 then
            error('Cloud Warning HTTP ' .. tostring(status))
        end
        raw = response.Body
    else
        local ok, response = pcall(function()
            return game:HttpGet(url)
        end)
        if not ok then error('HTTP GET is unavailable in this environment') end
        raw = response
    end

    if type(raw) ~= 'string' then error('Invalid Warning API response') end
    local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok or type(data) ~= 'table' or data.ok ~= true or type(data.warnings) ~= 'table' then
        error('Invalid Warning API JSON')
    end
    return data
end

local function fetcher()
    local ok, data = pcall(readWarnings)
    if ok then
        shared.ArcScriptWarningStatus = {ok=true,stage='online',lastSuccess=os.time(),count=#data.warnings}
        return data
    end
    shared.ArcScriptWarningStatus = {ok=false,stage='fetch',error=tostring(data),lastSuccess=shared.ArcScriptWarningStatus.lastSuccess}
    if os.time() - lastErrorAt >= 120 then
        warn('[WarningUI] ' .. tostring(data))
        lastErrorAt = os.time()
    end
    return nil
end

local started, reason = ui.startServerPolling(fetcher, 15)
assert(started, tostring(reason or 'Unable to start WarningUI polling'))

shared.ArcScriptWarningConnector = {
    version = '0.5.21',
    stop = function()
        ui.stopServerPolling()
    end
}
return shared.ArcScriptWarningConnector

]=====]
        local factory, compileError = loadstring(sourceUI)
        if not factory then error('WarningUI compile: '..tostring(compileError)) end
        factory()
        local startConnector, connectorCompile = loadstring(sourceConnector)
        if not startConnector then error('Warning connector compile: '..tostring(connectorCompile)) end
        startConnector()
    end)
    if not ok then warn('[ArcScriptCenter WarningUI] '..tostring(err)) end
end)

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
	table.insert(queue, "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/loadstring/Loader.lua")

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

-- DONE
task.delay(0.5,function()
	if not ES.error then
		ES.progress = ES.max
		ES.done = true
	end
end)

-- LoaderSettings is a separate configuration UI (not ExperienceSettings).
-- Its startup must not suspend the main UI bootstrap if it yields on an avatar/UI.
task.spawn(function()
    print("[ES][Bootstrap] Starting LoaderSettings in parallel...")
    local ok, err = pcall(function()
        local url = "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/Loader.lua"
        local source = game:HttpGet(url)
        local chunk, compileError = loadstring(source)
        if not chunk then error("LoaderSettings compile: " .. tostring(compileError)) end
        chunk()
    end)
    if not ok then
        warn("[ES][Bootstrap] LoaderSettings failed independently: " .. tostring(err))
    else
        print("[ES][Bootstrap] LoaderSettings loaded.")
    end
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


-- Hamburger Menu Remake
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/RecommendedScript.lua"))()

-- Editor
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/Editor.lua"))()

-- Arcsen
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/loadstring/Arcsen.lua"))()
print("[ Arcsen ] Successful loaded.")

-- Seacrh
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/Search.lua"))()
print("[ Seacrh ] Successful loaded.")

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
if _0x32(_0x42, plr) then
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
