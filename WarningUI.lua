local v_ver = [[WarningUI 0.1.9 Header Mode & Selected RichText]]
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

local LEVEL_RGB = {
  info = Color3.fromRGB(0,0,50),
  warning = Color3.fromRGB(50,50,0),
  critical = Color3.fromRGB(50,0,0),
}
local RICH_FONTS = {Gotham = true, SourceSans = true, Arial = true, Code = true, Cartoon = true}
local function validHex(v, fallback)
  if type(v) == "string" and v:match("^#%x%x%x%x%x%x$") then return v end
  return fallback
end
local function escapeRobloxText(v)
  return tostring(v or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end
local function formatWarningText(plain, settings)
  if type(settings) ~= "table" or settings.enabled ~= true then return tostring(plain or ""), false end
  local styles = type(settings.styles) == "table" and settings.styles or {}
  local function formatPart(text, style)
    local message = escapeRobloxText(text)
    if type(style) ~= "table" then return message end
    local function wrapper(openTag, closeTag)
      message = openTag .. message .. closeTag
    end
    for _, tag in ipairs({"b", "i", "u", "s"}) do
      local key = ({b="bold", i="italic", u="underline", s="strike"})[tag]
      if style[key] == true then wrapper("<"..tag..">", "</"..tag..">") end
    end
    if style.color ~= nil or style.font ~= nil then
      local color = validHex(style.color, "#FFFFFF")
      local face = RICH_FONTS[style.font] and style.font or "Gotham"
      wrapper('<font color="' .. color .. '" face="' .. face .. '">', '</font>')
    end
    local thickness = tonumber(style.strokeThickness) or 0
    if thickness > 0 then
      thickness = math.clamp(thickness, 0, 4)
      wrapper('<stroke color="' .. validHex(style.strokeColor,"#000000") .. '" thickness="' .. string.format("%.1f", thickness) .. '">', '</stroke>')
    end
    return message
  end
  if type(styles.segments) == "table" then
    if #styles.segments == 0 or #styles.segments > 200 then return tostring(plain or ""), false end
    local combined, chunks = {}, {}
    for _, seg in ipairs(styles.segments) do
      if type(seg) ~= "table" or type(seg.text) ~= "string" or type(seg.styles) ~= "table" then
        return tostring(plain or ""), false
      end
      table.insert(combined, seg.text)
      table.insert(chunks, formatPart(seg.text, seg.styles))
    end
    -- Never render a remotely provided styled body that differs from its plain body.
    if table.concat(combined) ~= tostring(plain or "") then return tostring(plain or ""), false end
    return table.concat(chunks), true
  end
  -- Backward compatibility with previously published whole-message styles.
  return formatPart(plain, styles), true
end

local function pop(ntitle, ndes, nbtn1, twoButtons, nbtn2, onClose, onPrimary, onSecondary, severity, formatting)
  local frmbtn = twoButtons == true

  local frm = Instance.new("Frame")
  frm.Name = "PopUp"
  frm.Size = UDim2.new(0.8, 0, 0.42, 0)
  local limit = Instance.new("UISizeConstraint")
  limit.MinSize = Vector2.new(240, 210)
  limit.MaxSize = Vector2.new(570, 450)
  limit.Parent = frm
  frm.BackgroundColor3 = LEVEL_RGB[tostring(severity or "warning"):lower()] or LEVEL_RGB.warning
  frm.BorderMode = Enum.BorderMode.Inset
  frm.BorderSizePixel = 5
  frm.Parent = hr
  Corner(0,8,frm)
  local frmStroke = Stroke(frm, "ASMBorder",255,255,255,"LJMRound",5,0)
  local themeColor = ({info=Color3.fromRGB(100,145,255), warning=Color3.fromRGB(255,226,90), critical=Color3.fromRGB(255,100,100)})[tostring(severity or "warning"):lower()] or Color3.new(1,1,1)
  local frmGra = Gradient(frmStroke, 0,0,0, {themeColor, Color3.new(1,1,1)})

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
  local formattedDescription, enableRichText = formatWarningText(ndes or "This is a warning.", formatting)
  des.Text = formattedDescription
  des.TextWrapped  = true
  --des.TextScaled = true
  des.TextSize = 13
  des.TextYAlignment = Enum.TextYAlignment.Top
  des.RichText = enableRichText
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

local api = { version = "0.2.6-header-mode-selected-richtext", source = "ExperienceSettings WarningUI" }

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
  -- Cloud actions are fixed, locally defined behaviors. No API source is compiled.
  if source == "server" then
    if scriptId == "ACS_WarningClose" then
      return function() return true end
    elseif scriptId == "ACS_WarningLeave" then
      return function()
        local player = game:GetService("Players").LocalPlayer
        if not player then return false end
        local ok, reason = pcall(function()
          player:Kick("You chose to leave the experience from ArcScriptCenter WarningUI.")
        end)
        if not ok then
          warn("[WarningUI] Leave failed: " .. tostring(reason))
          return false
        end
        return true
      end
    elseif scriptId == "ACS_WarningRejoin" then
      return function()
        -- Only after the local user explicitly presses the clearly labeled button.
        local player = game:GetService("Players").LocalPlayer
        if not player then return false end
        if game.PlaceId <= 0 then
          warn("[WarningUI] Rejoin requires a published Roblox place.")
          return false
        end
        -- Universal/client-only behavior, matching the existing Loader Rejoin action.
        -- No RemoteEvent or game-owned ServerScriptService script is required.
        -- Teleport() is a legacy Roblox API; some experiences may reject the request.
        local ok, err = pcall(function()
          s.TeleportService:Teleport(game.PlaceId, player)
        end)
        if not ok then
          warn("[WarningUI] Rejoin failed: " .. tostring(err))
          return false
        end
        return true
      end
    end
  end
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
      end, entry.onPrimary, entry.onSecondary, entry.severity, entry.formatting)
end

local function queueWarning(entry, source)
  if state.dead or type(entry) ~= "table" then return false, "Invalid warning" end
  if #state.queue >= 20 then return false, "Warning queue is full" end
  local prefix = source == "server" and "SERVER" or "CLIENT"
  -- Header preference is only the [SERVER] / [CLIENT] label; never the warning title.
  -- Existing warnings and clients default to the same header as before.
  local headerMode = entry.headerMode == "none" and "none" or "default"
  local title = (headerMode == "none" and "" or ("[" .. prefix .. "] ")) .. tostring(entry.title or "Warning")
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
  -- A server-authored notice must never disguise a voluntary disconnect button.
  local label1 = tostring(entry.primaryLabel or "OK"):sub(1, 32)
  local label2 = entry.secondaryLabel and tostring(entry.secondaryLabel):sub(1, 32) or nil
  if source == "server" then
    if action1 == "RequireScript" and entry.primaryScriptId == "ACS_WarningLeave" then
      label1 = "Leave game"
    end
    if action1 == "RequireScript" and entry.primaryScriptId == "ACS_WarningRejoin" then
      label1 = "Rejoin game"
    end
    if label2 and action2 == "RequireScript" and entry.secondaryScriptId == "ACS_WarningLeave" then
      label2 = "Leave game"
    end
    if label2 and action2 == "RequireScript" and entry.secondaryScriptId == "ACS_WarningRejoin" then
      label2 = "Rejoin game"
    end
  end
  -- Limit local input by UTF-8 characters, never by raw bytes. Server notices
  -- are <=900 Unicode characters, so their styled segments stay in sync.
  local cutOk, cutAt = pcall(utf8.offset, description, 1501)
  if cutOk and cutAt then description = description:sub(1, cutAt - 1) end
  table.insert(state.queue, {
    title = title:sub(1, 120),
    description = description,
    severity = tostring(entry.severity or "warning"):lower(),
    formatting = entry.richText == true and {enabled = true, styles = entry.formatting} or nil,
    primaryLabel = label1,
    secondaryLabel = label2,
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
