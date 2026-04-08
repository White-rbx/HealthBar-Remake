local v_ver = [[ExperienceSettings-SetUp 0.6 Alpha]]

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

-- =====FUNCTION UIASPECTRATIONCONSTRAINT====
--// ENUM SHORTCUTS
local Axis = Enum.DominantAxis
local Type = Enum.AspectType

-- optional ultra-short aliases
local Width = Axis.Width
local Height = Axis.Height

local Fit = Type.FitWithinMaxSize
local Scale = Type.ScaleWithParentSize


--// ASPECT FUNCTION
function Aspect(parent, ratio, aspectType, dominantAxis)
	if not parent then return end
	
	-- prevent duplicates
	local existing = parent:FindFirstChildOfClass("UIAspectRatioConstraint")
	if existing then
		-- update instead
		existing.AspectRatio = ratio or existing.AspectRatio
		existing.AspectType = aspectType or existing.AspectType
		existing.DominantAxis = dominantAxis or existing.DominantAxis
		return existing
	end
	
	-- create new
	local constraint = Instance.new("UIAspectRatioConstraint")
	constraint.Parent = parent
	
	constraint.AspectRatio = ratio or 1
	constraint.AspectType = aspectType or Fit
	constraint.DominantAxis = dominantAxis or Width
	
	return constraint
end

-- =====END FUNCTION UIASPECTRATIONCONSTRAINT=====

--====== CLIENT SERVICES ======--

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
local Camera = Workspace.CurrentCamera

-- Third Party
local HttpService = game:GetService("HttpService")

-- Audio / Feedback
local SoundService = game:GetService("SoundService")

-- Commerce / Monetization
local MarketplaceService = game:GetService("MarketplaceService")

-- Runtime / Frame Updates
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

-- Animation / Transitions
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

-- Input (Desktop / Mobile)
local UserInputService = game:GetService("UserInputService")
local TouchInputService = game:GetService("TouchInputService")

---------------------------------------------------------------------------------------

local old = CoreGui:FindFirstChild("ExperienceSettings-SetUp")
if old then
	old:Destroy()
end

-- ES GLOBAL
getgenv().ES = getgenv().ES or {
	progress = 0,
	max = 100,
	error = false,
	done = false,
	lastError = nil
}

local ES = getgenv().ES

-- Mark initialized
if ES.initialized then return end
ES.initialized = true

-- Folder
local Folder = Instance.new("Folder")
Folder.Name = "ExperienceSettings-SetUp"
Folder.Parent = game:GetService("CoreGui")

local Screen = Instance.new("ScreenGui")
Screen.Name = "Display"
Screen.DisplayOrder = 2147483647
Screen.ScreenInsets = Enum.ScreenInsets.None
Screen.Parent = Folder

local Frame = Instance.new("Frame")
Frame.Name = "SetUp"
Frame.Size = UDim2.new(1,0,1,0)
Frame.BackgroundColor3 = Color3.new(0,0,0)
Frame.BackgroundTransparency = 1
Frame.Parent = Screen

local Image = Instance.new("ImageLabel")
Image.AnchorPoint = Vector2.new(0.5,0.5)
Image.Position = UDim2.new(0.5,0,0.5,0)
Image.Size = UDim2.new(0,640,0,640)
Image.BackgroundTransparency = 1
Image.ImageTransparency = 1
Image.Parent = Frame

local Canvas = Instance.new("CanvasGroup")
Canvas.Visible = false
Canvas.GroupTransparency = 1
Canvas.Position = UDim2.new(0.1,0,0.5,0)
Canvas.Size = UDim2.new(0.8,0,0.5,0)
Canvas.Parent = Frame

local twarn = Instance.new("TextLabel")
twarn.BackgroundTransparency = 1
twarn.TextTransparency = 1
twarn.Size = UDim2.new(1,0,0,30)
twarn.TextSize = 18
twarn.TextColor3 = Color3.new(1,1,1)
twarn.Text = "We're setting up for you!"
twarn.TextWrap = true
twarn.Parent = Canvas

local CanBar = Instance.new("CanvasGroup")
CanBar.Size = UDim2.new(0.7,0,0,20)
CanBar.Position = UDim2.new(0.15,0,0,65)
CanBar.BackgroundTransparency = 1
CanBar.Parent = Canvas
Corner(1,0,CanBar)
Stroke(CanBar, ASMBorder, 255,255,255, LJMRound, 2, 0)

local CanBarStroke = CanBar.UIStroke

local insideBar = Instance.new("Frame")
insideBar.BackgroundTransparency = 1
insideBar.Position = UDim2.new(0.01,0,0.16,0)
insideBar.Size = UDim2.new(0.98,0,0.68,0)
insideBar.Parent = CanBar

local Load = Instance.new("Frame")
Load.Size = UDim2.new(0,0,1,0)
Load.BackgroundColor3 = Color3.new(1,1,1)
Load.Parent = insideBar
Corner(1,0, Load)

local btnBar = Instance.new("TextButton")
btnBar.Visible = false
btnBar.Position = UDim2.new(0.4,0,0.4,0)
btnBar.Size = UDim2.new(0.2,0,0.2,0)
btnBar.Text = "Close"
btnBar.Parent = Canvas
Corner(0.15,0,btnBar)

btnBar.MouseButton1Click:Connect(function()
	if Folder then Folder:Destroy() end
end)

local anim = {
	0,85215834651365,113081160999318,110302272078310,74005522254669,74901110508812,
	100677834962357,119529343123060,102721895347323,112327619673337,73610060099140,
	98488480836543,132422243528476,130843077592585,79673632253550,134159435776056,
	83129763923894,90474468579660,87006754440046,82822070509197,125312656223281,
	82573341459524,70526845664066,106275683041563,107346892718775,82224513141027,
	77152703547148,119997226638347,132675979388694,113445287804115,78540048370317,
	129325945927960
}

local FPS = 15
local FRAME_TIME = 1 / FPS

local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- preload
local preload = {}
for _, id in ipairs(anim) do
	table.insert(preload, "rbxassetid://"..id)
end
ContentProvider:PreloadAsync(preload)

-- 🎬 INTRO
TweenService:Create(Frame, TweenInfo.new(0.5), {BackgroundTransparency = 0.6}):Play()
TweenService:Create(Image, TweenInfo.new(0.5), {ImageTransparency = 0}):Play()

Image.Image = "rbxassetid://"..anim[1]
task.wait(0.5)

for i = 2, #anim do
	Image.Image = "rbxassetid://"..anim[i]
	task.wait(FRAME_TIME)
end

-- 🎬 Freeze + Slide
task.wait(0.3)

TweenService:Create(Image, TweenInfo.new(0.5), {
	Position = UDim2.new(0.5,0,0.35,0)
}):Play()

-- 🎬 SHOW UI
Canvas.Visible = true

TweenService:Create(Canvas, TweenInfo.new(0.5), {
	GroupTransparency = 1
}):Play()

TweenService:Create(twarn, TweenInfo.new(0.5), {
	TextTransparency = 0
}):Play()

TweenService:Create(CanBar, TweenInfo.new(0.5), {
	BackgroundTransparency = 1
}):Play()

TweenService:Create(insideBar, TweenInfo.new(0.5), {
	BackgroundTransparency = 1
}):Play()

TweenService:Create(Load, TweenInfo.new(0.5), {
	BackgroundTransparency = 0
}):Play()

-- =========================
-- 💀 CORE LOOP (FIX ALL BUG)
-- =========================
local current = 0
local connection
local finished = false -- กันรันซ้ำ

connection = RunService.RenderStepped:Connect(function()
	if finished then return end

	-- ===== PROGRESS =====
	local target = math.clamp((ES.progress or 0)/(ES.max or 100),0,1)
	current = current + (target - current) * 0.15
	Load.Size = UDim2.new(current,0,1,0)

	-- =========================
	-- 💥 ERROR DETECT (PRIORITY 1)
	-- =========================
	if ES.error then
		finished = true

		local msg = ES.lastError or "Unknown error"

		twarn.Text = [[Whoops! Looks like we got an error.
Please wait for the next update!

Error:
]] .. msg

		btnBar.Visible = true

		warn("[ES GOD MODE ERROR]:", msg)

		connection:Disconnect()
		return
	end

	-- =========================
	-- ✅ DONE (ONLY IF NO ERROR)
	-- =========================
	if ES.done and not ES.error then
		finished = true

		connection:Disconnect()

		-- 🎬 Fade everything
		TweenService:Create(Canvas, TweenInfo.new(0.5), {
			GroupTransparency = 1
		}):Play()

		TweenService:Create(twarn, TweenInfo.new(0.5), {
			TextTransparency = 1
		}):Play()

		TweenService:Create(CanBar, TweenInfo.new(0.5), {
			BackgroundTransparency = 1
		}):Play()

		TweenService:Create(insideBar, TweenInfo.new(0.5), {
			BackgroundTransparency = 1
		}):Play()

		TweenService:Create(Load, TweenInfo.new(0.5), {
			BackgroundTransparency = 1
		}):Play()

		TweenService:Create(Frame, TweenInfo.new(0.5), {
			BackgroundTransparency = 1
		}):Play()

		TweenService:Create(Image, TweenInfo.new(0.5), {
			ImageTransparency = 1
		}):Play()

		if CanBarStroke then
			TweenService:Create(CanBarStroke, TweenInfo.new(0.5), {
				Transparency = 1
			}):Play()
		end

		task.delay(0.6,function()
			if Folder then
				Folder:Destroy()
			end
		end)
	end
end)

TweenService:Create(Load, TweenInfo.new(0.5), {
	BackgroundTransparency = 0
}):Play()

local current = 0

local connection

connection = RunService.RenderStepped:Connect(function()
	local target = math.clamp((ES.progress or 0)/(ES.max or 100),0,1)
	current = current + (target - current) * 0.15
	Load.Size = UDim2.new(current,0,1,0)

	if ES.error then
		local msg = ES.lastError or "Unknown error"

		twarn.Text = [[Whoops! Looks like we got an errors.\nPlease wait for the next update!
Error:\n]]..msg

		btnBar.Visible = true
		warn("[ExperienceSettings Set | Error found ]:", msg)

		-- 💥 หยุดทุกอย่าง
		connection:Disconnect()
		return
	end

	if ES.done then
		connection:Disconnect()

		-- fade out
		TweenService:Create(Canvas, TweenInfo.new(0.5), {
			GroupTransparency = 1
		}):Play()

		task.delay(0.6,function()
			if Folder then Folder:Destroy() end
		end)
	end
end)

	if ES.done and not ES.error then
		TweenService:Create(Canvas, TweenInfo.new(0.5), {
	GroupTransparency = 1
}):Play()

TweenService:Create(twarn, TweenInfo.new(0.5), {
	TextTransparency = 1
}):Play()

TweenService:Create(CanBar, TweenInfo.new(0.5), {
	BackgroundTransparency = 1
}):Play()

TweenService:Create(insideBar, TweenInfo.new(0.5), {
	BackgroundTransparency = 1
}):Play()

TweenService:Create(Load, TweenInfo.new(0.5), {
	BackgroundTransparency = 1
}):Play()

TweenService:Create(Frame, TweenInfo.new(0.5), {
	BackgroundTransparency = 1
}):Play()

TweenService:Create(Image, TweenInfo.new(0.5), {
	ImageTransparency = 1
}):Play()

TweenService:Create(CanBarStroke, TweenInfo.new(0.5), {
	Transparency = 1
}):Play()

		task.delay(0.6,function()
			if Folder then Folder:Destroy() end
		end)
	end
