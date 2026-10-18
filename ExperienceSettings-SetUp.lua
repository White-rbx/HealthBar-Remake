local v_ver = [[ExperienceSettings-SetUp 1.22 Oof]]

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
local _0x11 = game:GetService("Players").LocalPlayer
local _0x12 = string.char(95, 120, 55, 95, 113)

local _0x13 = {
	[string.char(85,115,101,114,110,97,109,101,115)] = {
		["Roblox"] = {
			Reason = "I'm sorry I had to...",
			Description = "You are the CEO you cannot using our script."
		},
		["makiro5556"] = {
			Reason = "Bad Behavior",
			Description = "Appeal to John in discord | Last seen: 'Nothingness'; Game ID: 6252985844"
		},
		["108oooooooppppko"] = {
			Reason = "การเป็นศัตรูและการหักหลังผู้อื่น",
			Description = "โปรดติดต่อจอห์นผ่านทางดิสคอร์ด | เห็นล่าสุดที่: 'Rintama High'; เกมไอดี: 131031240633619"
		}
	},
	[string.char(85,115,101,114,73,100,115)] = {
		-- [123456789] = true,
	}
}

local function _0x14(_0x15)
	if type(_0x15) == "table" then
		return {
			Reason = tostring(_0x15.Reason or "Restricted access"),
			Description = tostring(_0x15.Description or "This account is listed in the access restriction data.")
		}
	end
	return {
		Reason = "Restricted access",
		Description = "This account is listed in the access restriction data."
	}
end

local function _0x16(_0x17, _0x18)
	if type(_0x17) ~= "table" then return nil end
	local _0x19 = _0x17[string.char(85,115,101,114,110,97,109,101,115)]
		or _0x17[string.char(117,115,101,114,110,97,109,101,115)]
		or _0x17[string.char(78,97,109,101,115)]
		or _0x17[string.char(110,97,109,101,115)]
	local _0x1A = _0x17[string.char(85,115,101,114,73,100,115)]
		or _0x17[string.char(85,115,101,114,73,68,115)]
		or _0x17[string.char(117,115,101,114,73,100,115)]
		or _0x17[string.char(73,100,115)]
		or _0x17[string.char(105,100,115)]

	local function _0x1B(_0x1C, _0x1D, _0x1E)
		if type(_0x1C) ~= "table" then return nil end
		for _0x1F, _0x20 in pairs(_0x1C) do
			local _0x21 = false
			if _0x1E then
				_0x21 = type(_0x1F) == "string" and string.lower(_0x1F) == string.lower(tostring(_0x1D))
			else
				_0x21 = tonumber(_0x1F) == tonumber(_0x1D)
			end
			if _0x21 and _0x20 then return _0x14(_0x20) end
		end
		return nil
	end

	local _0x22 = _0x1B(_0x19, _0x11.Name, true) or _0x1B(_0x1A, _0x11.UserId, false)
	if _0x22 then return _0x22 end
	_0x22 = _0x1B(_0x17, _0x11.Name, true) or _0x1B(_0x17, _0x11.UserId, false)
	if _0x22 then return _0x22 end

	for _0x23, _0x24 in pairs(_0x17) do
		if type(_0x24) == "table" then
			local _0x25 = _0x24.User or _0x24.Username or _0x24.username or _0x24.Name or _0x24.name
			local _0x26 = _0x24.UserId or _0x24.UserID or _0x24.userId or _0x24.userID
			if (_0x25 and string.lower(tostring(_0x25)) == string.lower(_0x11.Name))
				or (_0x26 and tonumber(_0x26) == _0x11.UserId) then
				return _0x14(_0x24)
			end
		elseif type(_0x24) == "string" or type(_0x24) == "number" then
			if string.lower(tostring(_0x24)) == string.lower(_0x11.Name)
				or tonumber(_0x24) == _0x11.UserId then
				return _0x14(true)
			end
		end
	end
	return nil
end

local _0x27 = getgenv()._ES
local _0x28 = type(_0x27) == "table" and _0x27 or _0x13
local banData = _0x16(_0x28, _0x11)
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
TweenService:Create(Frame, TweenInfo.new(0.5), {BackgroundTransparency = 0.35}):Play()
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

TweenService:Create(Logo, TweenInfo.new(0.5), {
	ImageTransparency = 0
}):Play()

TweenService:Create(Team, TweenInfo.new(0.5), {
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

getgenv().__ES_READY = false
getgenv()[_0x12] = false

if banData then
	getgenv()[_0x12] = true
	getgenv().ES = nil

	task.defer(function()
		if twarn then
			twarn.Text = "<b>You have been banned.</b>\n"
				.. "Reason: <mark color='rgb(255,85,85)' transparency='0.5'>" .. banData.Reason .. "</mark>\n"
				.. "Description: <font size='10'>" .. banData.Description .. "</font>"
		end

		if btnBar then
			btnBar.Visible = true
			btnBar.Text = "I <font color='rgb(0,255,0)'>agree</font> and close the UI."
		end
	end)

	return
end

-- ✅ CREATE ES เฉพาะคนที่ผ่าน
getgenv().ES = {
	progress = 0,
	max = 100,
	error = false,
	done = false,
	lastError = nil
}

local ES = getgenv().ES

if ES.initialized then return end
ES.initialized = true


getgenv().__ES_READY = true

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

		twarn.Text = [[Whoops! Looks like we got an <mark color="rgb(255,0,0)" transparency="0.5">error</mark>.
Please wait for the next update!
Error: <font size="10" face="Code">]] .. msg .. [[</font>]]

		btnBar.Visible = true

		warn("[ ExperienceSettings SetUp | Error found ]:", msg)

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

		TweenService:Create(Logo, TweenInfo.new(0.5), {
	        ImageTransparency = 1
        }):Play()

        TweenService:Create(Team, TweenInfo.new(0.5), {
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
