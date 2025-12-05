-- Version 1.2

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

local function createUIListLayout(parent, scale, offset, HZ, VT, SO, FILL)
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


local HolderScreen = game:GetService("CoreGui").ExperienceSettings.Menu.HolderScreen

local notiF = Instance.new("CanvasGroup")
notiF.Name = "NotificationFrame"
notiF.Size = UDim2.new(1,0,0.3,0)
notiF.Transparency = 1
notiF.Active = false
notiF.Parent = HolderScreen
createUIListLayout(notiF, 0, 3, HCenter, VTop, SLayout, FillV)

-- Roblox Theme Color Default
local rbxT = "18,18,21"
-- Icon
local vc = "🎙️: "
local tpps = "🏙️: "
local warn = "⚠️: "
local warn2 = "❗: "
local red = "🔴: "
local orn = "🟠: "
local yell = "🟡: "
local gre = "🟢: "
local cmark = "✅: "
local cross = "❌: "
local sle = "💤: "
local int = "🛜: "
local qusmark = "❔: "
local square = "#️⃣: "
local thing = "💭: "
local fire = "🔥: "
local ann = "📢: "
local nan = ""

local function addtextnoti(icon, textValue)
	-- แปลงสี Roblox Theme
	local r, g, b = string.match(rbxT, "(%d+),(%d+),(%d+)")
	r, g, b = tonumber(r), tonumber(g), tonumber(b)

	local text = Instance.new("TextLabel")
	text.Name = "textnoti"
	text.Size = UDim2.new(0, 0, 0, 30)
	text.BackgroundColor3 = Color3.fromRGB(r, g, b)
	text.BackgroundTransparency = 0.08
	text.Text = tostring(icon)..tostring(textValue)
	text.TextColor3 = Color3.fromRGB(255,255,255)
	text.Active = false
	text.Parent = notiF
	
	Corner(1,0,text)
	TweenAutoSize(text, 30)
	return text
end

local function addsendnoti(textValue)
	-- แปลงสี Roblox Theme
	local r, g, b = string.match(rbxT, "(%d+),(%d+),(%d+)")
	r, g, b = tonumber(r), tonumber(g), tonumber(b)

	local input = Instance.new("TextBox")
	input.Name = "sendnoti"
	input.Size = UDim2.new(0, 100, 0, 30)
	input.BackgroundColor3 = Color3.fromRGB(r, g, b)
	input.BackgroundTransparency = 0.08
	input.Text = tostring(textValue or "")
	input.ClearTextOnFocus = false
	input.PlaceholderText = "Type anything..."
	input.TextColor3 = Color3.fromRGB(255,255,255)
	input.Active = true
       input.TextXAlignment = Enum.TextXAlignment.Left
	input.Parent = notiF

	Corner(1,0,input)

	local btn = Instance.new("TextButton")
	btn.Name = "send"
	btn.Size = UDim2.new(0,50,0,27)
	btn.Position = UDim2.new(1,-52,0,2)
	btn.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
	btn.Text = "Send"
	btn.Parent = input

	Corner(1,0,btn)
	TweenAutoSize(input, 60)
	return input, btn
end

local function addqusnoti(icon, textValue)
	-- แปลงสี Roblox Theme
	local r, g, b = string.match(rbxT, "(%d+),(%d+),(%d+)")
	r, g, b = tonumber(r), tonumber(g), tonumber(b)

	local text1 = Instance.new("TextLabel")
	text1.Name = "textnoti"
	text1.Size = UDim2.new(0.15,0, 0, 30)
	text1.BackgroundColor3 = Color3.fromRGB(r, g, b)
	text1.BackgroundTransparency = 0.08
	text1.Text = tostring(icon)..tostring(textValue)
	text1.TextColor3 = Color3.fromRGB(255,255,255)
       text1.TextXAlignment = Enum.TextXAlignment.Left
	text1.Active = false
	text1.Parent = notiF
	
	Corner(1,0,text1)

       local btn1 = Instance.new("TextButton")
	btn1.Name = "Cancel"
	btn1.Size = UDim2.new(0,50,0,27)
	btn1.Position = UDim2.new(1,-52,0,2)
	btn1.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
       btn1.TextColor3 = Color3.fromRGB(255,255,255)
	btn1.Text = "Cancel"
	btn1.Parent = text1
       Corner(1,0,btn1)

       local btn2 = Instance.new("TextButton")
	btn2.Name = "Agree"
	btn2.Size = UDim2.new(0,50,0,27)
	btn2.Position = UDim2.new(1,-103,0,2)
	btn2.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	btn2.Text = "Agree"
	btn2.Parent = text1
       Corner(1,0,btn2)
	TweenAutoSize(text1, 120)

	return text1, btn1, btn2
end

--====== END FUNCTIONS ========--
local TweenService = game:GetService("TweenService")

local function TweenAutoSize(obj, padding)
    padding = padding or 20  -- เพิ่มพื้นที่เผื่อปุ่ม/ระยะห่าง

    task.wait()  -- รอ 1 frame ให้ TextBounds คำนวณ

    local parentSize = obj.Parent.AbsoluteSize.X
    local textWidth = obj.TextBounds.X + padding

    local scaleX = math.clamp(textWidth / parentSize, 0, 1)

    TweenService:Create(
        obj,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.new(scaleX, 0, 0, obj.AbsoluteSize.Y) }
    ):Play()
end
