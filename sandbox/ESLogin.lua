local v_ver = [[ExperienceSettingsLogin 0.0 Draft]]
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
function Aspect(parent, ratio, aspectType, dominantAxis)
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

local client, parent, initialStatus = ...
if type(client) ~= "table" then return false end

local tweenService = game:GetService("TweenService")
local loc = {}

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

    local tween = tweenService:Create(obj, tweenInfo, properties)
    tween:Play()
    return tween
end

---------------------------------------------------------------------------------------

-- StarterGui.ESLoginGui
local ESLoginGui = Instance.new("ScreenGui")
ESLoginGui.Name = "ESLoginGui"
local guiParent = parent or game:GetService("CoreGui")
local existing = guiParent:FindFirstChild("ESLoginGui")
if existing then existing:Destroy() end
ESLoginGui.ResetOnSpawn = false
ESLoginGui.DisplayOrder = 2147483647
ESLoginGui.Parent = guiParent

-- StarterGui.ESLoginGui.Main
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.ClipsDescendants = true
Main.Position = UDim2.new(0.3, 0, 0.2, 0)
Main.Size = UDim2.new(0.4, 0, 0.5, 0)
Main.BackgroundColor3 = Color3.fromRGB(0, 11, 52)
Main.BorderSizePixel = 5
Main.BorderMode = Enum.BorderMode.Inset
Main.Parent = ESLoginGui
local minimum = Instance.new("UISizeConstraint")
minimum.MinSize = Vector2.new(200,214)
minimum.Parent = Main
Corner(0,8,Main)
loc.MStr = Stroke(Main, ASMBorder, 255,255,255, LJMRound, 5, 0)
Gradient(loc.MStr, 0,0,0,{Color3.fromRGB(0,78,255), Color3.new(1,1,1)})

-- StarterGui.ESLoginGui.Main.Inside
local Inside = Instance.new("Frame")
Inside.Name = "Inside"
Inside.Position = UDim2.new(0, 0, 0, 32)
Inside.Size = UDim2.new(1, 0, 1, -32)
Inside.BackgroundTransparency = 1
Inside.Parent = Main

-- StarterGui.ESLoginGui.Main.Inside.Username
local Username = Instance.new("TextLabel")
Username.Name = "Username"
Username.Size = UDim2.new(1, 0, 0, 22)
Username.BackgroundTransparency = 1
Username.Text = "Pairing code"
Username.TextColor3 = Color3.fromRGB(255, 255, 255)
Username.TextXAlignment = Enum.TextXAlignment.Left
Username.Parent = Inside

-- StarterGui.ESLoginGui.Main.Inside.UserInput
local UserInput = Instance.new("TextBox")
UserInput.Name = "UserInput"
UserInput.Position = UDim2.new(0, 0, 0, 22)
UserInput.Size = UDim2.new(1, 0, 0, 28)
UserInput.BackgroundTransparency = 0.5
UserInput.BackgroundColor3 = Color3.fromRGB(0, 20, 255)
UserInput.PlaceholderText = "Tap Login to get a code"
UserInput.TextEditable = false
UserInput.ClearTextOnFocus = false
UserInput.TextColor3 = Color3.fromRGB(255, 255, 255)
UserInput.Parent = Inside
Corner(0,8,UserInput)

-- StarterGui.ESLoginGui.Main.Inside.Password
local Password = Instance.new("TextLabel")
Password.Name = "Password"
Password.Position = UDim2.new(0, 0, 0, 50)
Password.Size = UDim2.new(1, 0, 0, 22)
Password.BackgroundTransparency = 1
Password.Text = "Sign-in status"
Password.TextColor3 = Color3.fromRGB(255, 255, 255)
Password.TextXAlignment = Enum.TextXAlignment.Left
Password.Parent = Inside

-- StarterGui.ESLoginGui.Main.Inside.PassInput
local PassInput = Instance.new("TextBox")
PassInput.Name = "PassInput"
PassInput.Position = UDim2.new(0, 0, 0, 72)
PassInput.Size = UDim2.new(1, 0, 0, 28)
PassInput.BackgroundTransparency = 0.5
PassInput.BackgroundColor3 = Color3.fromRGB(0, 20, 255)
PassInput.PlaceholderText = ""
PassInput.TextEditable = false
PassInput.ClearTextOnFocus = false
PassInput.TextColor3 = Color3.fromRGB(255, 255, 255)
PassInput.Parent = Inside
Corner(0,8,PassInput)

-- StarterGui.ESLoginGui.Main.Inside.Buttons
local Buttons = Instance.new("Frame")
Buttons.Name = "Buttons"
Buttons.Position = UDim2.new(0, 0, 1, -80)
Buttons.Size = UDim2.new(1, 0, 0, 80)
Buttons.BackgroundTransparency = 1
Buttons.Parent = Inside
ListLayout(Buttons, 0, 5, "HCenter","VCenter","SLayout","FillV")

-- StarterGui.ESLoginGui.Main.Inside.Buttons.Login
local Login = Instance.new("TextButton")
Login.Name = "Login"
Login.Size = UDim2.new(0, 182, 0, 24)
local loginWidth = Instance.new("UISizeConstraint")
loginWidth.MaxSize = Vector2.new(182,24)
loginWidth.Parent = Login
Login.BackgroundColor3 = Color3.fromRGB(0, 234, 255)
Login.Text = "Login"
Login.Parent = Buttons
Corner(0,8,Login)

-- StarterGui.ESLoginGui.Main.Inside.Buttons.Linl
local Linl = Instance.new("TextButton")
Linl.Name = "Linl"
Linl.Size = UDim2.new(1, 0, 0, 18)
Linl.BackgroundTransparency = 1
Linl.BackgroundColor3 = Color3.fromRGB(0, 234, 255)
Linl.RichText = true
Linl.Text = "<i>No account? Register on ArcScriptCenter!</i>"
Linl.TextColor3 = Color3.fromRGB(0, 151, 255)
Linl.TextScaled = true
Linl.TextWrapped = true
Linl.Parent = Buttons

-- StarterGui.ESLoginGui.Main.Holder
local Holder = Instance.new("Frame")
Holder.Name = "Holder"
Holder.Size = UDim2.new(1, 0, 0, 32)
Holder.BackgroundTransparency = 1
Holder.Parent = Main

-- StarterGui.ESLoginGui.Main.Holder.Topic
local Topic = Instance.new("TextLabel")
Topic.Name = "Topic"
Topic.LayoutOrder = 1
Topic.Size = UDim2.new(1, -75, 0, 32)
Topic.BackgroundTransparency = 1
Topic.Text = "Welcome"
Topic.TextColor3 = Color3.fromRGB(255, 255, 255)
Topic.TextScaled = true
Topic.TextXAlignment = Enum.TextXAlignment.Left
Topic.Parent = Holder

ListLayout(Holder, 0,5, "HCenter","VCenter","SLayout","FillH")
-- StarterGui.ESLoginGui.Main.Holder.Logo
local Logo = Instance.new("ImageLabel")
Logo.Name = "Logo"
Logo.Size = UDim2.new(0, 32, 0, 32)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://120500539322715"
Logo.Parent = Holder
local remembered = false
local remember = Linl:Clone()
remember.Name = "Remember"
remember.Text = "Remember on this device [OFF]"
remember.LayoutOrder = 2
remember.Parent = Buttons
remember.Activated:Connect(function()
    remembered = not remembered
    remember.Text = remembered and "Remember on this device [ON]" or "Remember on this device [OFF]"
end)
local function navigate()
    local copied = type(setclipboard) == "function" and pcall(setclipboard, client.website)
    if copied then
        PassInput.Text = "Website copied. Open it in your browser."
    else
        PassInput.Text = client.website
    end
end
Linl.Activated:Connect(navigate)
local ready, busy = false, false
local messages = {
    session_expired = "Session expired. Sign in again.",
    no_session = "Sign in on the ArcScriptCenter website to link this account.",
    account_qa_provisioning = "Account QA backend is being prepared. Registration and pairing are not available yet.",
    unavailable = "Account service unavailable. Try Login again.",
    rate_limited = "Too many requests. Wait and try again.",
    verification_required = "Complete verification on the account website.",
}
PassInput.Text = messages[initialStatus] or "Sign in on the account website."
Login.Activated:Connect(function()
    if busy then return end
    busy,Login.Interactable = true,false
    PassInput.Text = "Preparing sign in..."
    task.spawn(function()
        local ok, pair, why = pcall(client.begin)
        if ok and pair and type(pair.code) == "string" and type(pair.expiresAt) == "number" then
            UserInput.Text = pair.code
            navigate()
            Password.Text = "Sign in, verify, then link this code"
            while ESLoginGui.Parent and os.time() < pair.expiresAt do
                task.wait(3)
                if not ESLoginGui.Parent then break end
                local checked, response, failure = pcall(client.poll,pair,remembered)
                if checked and response and response.state == "ready" then
                    ready = true
                    PassInput.Text = "Signed in"
                    return
                end
                if not checked or failure then
                    PassInput.Text = messages[failure] or messages.unavailable
                    if failure == "session_expired" then break end
                end
            end
            PassInput.Text = "Pairing expired. Tap Login for a new code."
            UserInput.Text = ""
            Password.Text = "Sign-in status"
        else
            PassInput.Text = messages[why] or messages.unavailable
        end
        busy,Login.Interactable = false,true
    end)
end)
while ESLoginGui.Parent and not ready do task.wait(0.2) end
if ESLoginGui.Parent then
    if ready then task.wait(0.35) end
    ESLoginGui:Destroy()
end
return ready
