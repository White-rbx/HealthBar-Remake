-- Script ahh 1.145

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

-- <<===== Position of Services =====>>
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- <<===== Position =====>>
local Menu = game.CoreGui:WaitForChild("TopBarApp")
                 :WaitForChild("TopBarApp")
                 :WaitForChild("UnibarLeftFrame")
                 :WaitForChild("HealthBar")
                 :WaitForChild("ExperienceSettings")
                 :WaitForChild("Menu")

-- =====>> Instance <<=====
local pro = Instance.new("Frame")
pro.Name = "ProfileStatus"
pro.Position = UDim2.new(0.25,0,1,0)
pro.Size = UDim2.new(0.5,0,0.7,0)
pro.BackgroundColor3 = Color3.fromRGB(0,0,0)
pro.BackgroundTransparency = 0.3
pro.Parent = Menu
Corner(0,8,pro)
Stroke(pro, ASMBorder, 255,255,255, LSMRound, 1, 0)
ListLayout(pro, 0, 0, HCenter, VCenter, SName, FillV)

-- [ pro.prin ]
local prin = Instance.new("Frame")
prin.Name = "InsideProfileStatus"
prin.Size = UDim2.new(0.98,0,0.96,0)
prin.BackgroundTransparency = 1
prin.Parent = pro

-- [ pro.prin(Inside) ]
local pchar = Instance.new("Frame")
pchar.Name = "ProfileCharacter"
pchar.Size = UDim2.new(0.5,0,1,0)
pchar.BackgroundTransparency = 1
pchar.Parent = prin

local dg = Instance.new("Frame")
dg.Name = "Debugs"
dg.Position = UDim2.new(0.5,0,0,0)
dg.Size = UDim2.new(0.5,0,1,0)
dg.BackgroundTransparency = 1
dg.Parent = prin

-- [ pro.pchar.pfhr ]
local pfhr = Instance.new("Frame")
pfhr.Name = "Holder"
pfhr.Size = UDim2.new(1,0,0.2,0)
pfhr.BackgroundTransparency = 1
pfhr.Parent = pchar

-- [ pro.pchar.pfhr.pf ]
local pf = Instance.new("ImageLabel")
pf.Name = "Profile"
pf.Size = UDim2.new(0,80,0,80)
pf.BackgroundTransparency = 0.8
pf.Image = "rbxassetid://"
pf.Parent = pfhr
Corner(0,8,pf)

-- [ pro.char.pfhr.user ]
local user = Instance.new("TextLabel")
user.Name = "Username"
user.Size = UDim2.new(0.8,0,0.3,0)
user.Position = UDim2.new(0,82,0,0)
user.BackgroundTransparency = 1
user.TextScaled = true
user.Text = "Getting API..."
user.TextXAlignment = Enum.TextXAlignment.Left
user.TextColor3 = Color3.fromRGB(255,255,255)
user.Parent = pfhr

-- [ pro.pchar.scr ]
local scr = Instance.new("ScrollingFrame")
scr.Name = "Scroll"
scr.Size = UDim2.new(1,0,0.79,0)
scr.Position = UDim2.new(0,0,0.21,0)
scr.CanvasSize = UDim2.new(0,0,5000,0)
scr.ScrollingDirection = Enum.ScrollingDirection.X
scr.ScrollBarThickness = 0
scr.BackgroundTransparency = 1
scr.Parent = pchar
ListLayout(scr, 0, 5, HCenter, VTop, SLayout, FillV)

-- [ function Text ]
local TextExtraFunction = {}

local function Text(parent, Name, TextContent, Active, R, G, B, R1, G1, B1, Workin, Function)
    local txt = Instance.new("TextLabel")
    txt.Name = tostring(Name)
    txt.Text = tostring(TextContent)
    txt.Active = (Active ~= false)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(R or 255, G or 255, B or 255)
    txt.TextScaled = true
    txt.Size = UDim2.new(0.99, 0, 0, 30)
    txt.Parent = parent

    Corner(0, 8, txt)
    Stroke(txt, ASMBorder, R1 or 255, G1 or 255, B1 or 255, LJMRound, 1, 0)

    -- Workin loop (สคริปต์หลัก)
    if typeof(Workin) == "function" then
        task.spawn(function()
            while txt.Parent do
                Workin(txt)
                task.wait(0.05)
            end
        end)
    end

    -- Function เสริม (เก็บแยก)
    if typeof(Function) == "function" then
        TextExtraFunction[txt] = Function
    end

    return txt
end
			
-- [ pro.pchar.scr.woof ]
local wf = Instance.new("Frame")
wf.Name = "There's nothing woof!"
wf.Size = UDim2.new(1,0,0,0)
wf.BackgroundTransparency = 1
wf.Parent = scr

-- [ function Button ]
local function Button(parent, Name, TextContent, Active, R, G, B, R1, G1, B1, Workin, Callback, Function)
    local btn = Instance.new("TextButton")
    btn.Name = tostring(Name)
    btn.Text = tostring(TextContent)
    btn.Active = (Active ~= false)
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.fromRGB(R or 255, G or 255, B or 255)
    btn.TextScaled = true
    btn.Size = UDim2.new(0.99, 0, 0, 30)
    btn.Parent = parent

    Corner(0, 8, btn)
    Stroke(btn, ASMBorder, R1 or 255, G1 or 255, B1 or 255, LJMRound, 1, 0)

    -- Callback (ไม่มี debug)
    if typeof(Callback) == "function" then
        btn.MouseButton1Click:Connect(function()
            Callback(btn)
        end)
    end

    -- Workin loop (ไม่มี debug)
    if typeof(Workin) == "function" then
        task.spawn(function()
            while btn.Parent do
                Workin(btn)
                task.wait(0.05)
            end
        end)
    end

    -- Manual function
    if typeof(Function) == "function" then
        btn.Function = function(...)
            return Function(btn, ...)
        end
    end

    return btn
end

-- Load Avatar
task.spawn(function()
    local lp = Players.LocalPlayer
    local uid = lp.UserId
    pf.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. uid .. "&width=150&height=150&format=Png"
end)
-- Load Username

Text(scr, "Soon", "More soon!")

task.spawn(function()
    local lp = Players.LocalPlayer
    local display = lp.DisplayName or lp.Name
    local real = lp.Name or ""
    user.Text = tostring(display) .. " (@" .. tostring(real) .. ")"
end)

local UserInputService = game:GetService("UserInputService")

------------------------------------------------
-- AFK TIMER CORE
------------------------------------------------

local lastInput = os.clock()

local function resetAFK()
	lastInput = os.clock()
end

-- กดปุ่ม = ไม่ AFK
UserInputService.InputBegan:Connect(resetAFK)

-- เปลี่ยน input แต่ "ไม่ใช่" การขยับเมาส์
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseMovement then
		resetAFK()
	end
end)
						
local afkText = Text(
	scr,
	"AFKTime",
	"AFK: 0 minute 0 second",
	false,
	255,255,255,        -- Text color
	255,255,255,        -- Stroke start color
	nil,nil,nil,        -- ✅ R1 G1 B1 (ข้าม)
	function(txt)       -- ✅ Workin (ตำแหน่งถูกต้อง)
		local afk = math.floor(os.clock() - lastInput)

		local min = math.floor(afk / 60)
		local sec = afk % 60

		txt.Text = string.format("AFK: %d minute %d second", min, sec)

		local stroke = txt:FindFirstChildOfClass("UIStroke")
		if not stroke then return end

		if min < 5 then
			stroke.Color = Color3.fromRGB(255,255,255)
		elseif min < 10 then
			stroke.Color = Color3.fromRGB(255,190,190)
		elseif min < 13 then
			stroke.Color = Color3.fromRGB(255,150,150)
		elseif min < 15 then
			stroke.Color = Color3.fromRGB(255,110,110)
		elseif min < 17 then
			stroke.Color = Color3.fromRGB(255,60,60)
		elseif min < 19 or (min == 19 and sec <= 30) then
			stroke.Color = Color3.fromRGB(200,0,0)
		else
			stroke.Color = Color3.fromRGB(140,0,0)
		end
	end,
	nil                 -- Function (ไม่ใช้)
)
						
------------------------------------------------
-- PlayerID
------------------------------------------------

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

Button(
	scr,
	"PlayerID",
	"PlayerID: Getting API...",
	true,
	255,255,255,        -- Text color
	180,180,255,        -- Stroke color
	function(btn)       -- Workin
		if lp and lp.UserId then
			btn.Text = "PlayerID: " .. tostring(lp.UserId)
		end
	end,
	function(btn)       -- Callback (คลิก)
		local id = tostring(lp.UserId)

		-- Copy (รองรับหลาย executor)
		if setclipboard then
			setclipboard(id)
		elseif toclipboard then
			toclipboard(id)
		elseif syn and syn.set_clipboard then
			syn.set_clipboard(id)
		end

		-- Feedback
		local stroke = btn:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Color = Color3.fromRGB(0,255,150)
			task.delay(0.4, function()
				if stroke then
					stroke.Color = Color3.fromRGB(180,180,255)
				end
			end)
		end
	end
)
