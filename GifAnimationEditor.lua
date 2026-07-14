local v_ver = [[Relax 0.0 Type]]

------------------------------------------------------------------------------------------
-- Services
------------------------------------------------------------------------------------------

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

------------------------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------------------------

local function Corner(scale, offset, parent)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(scale or 0, offset or 0)
	corner.Parent = parent
	return corner
end

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
	SName = Enum.SortOrder.Name,
}

local function ListLayout(parent, scale, offset, hz, vt, so, fill)
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(scale or 0, offset or 0)
	list.FillDirection = ListUI[fill] or ListUI.FillH
	list.HorizontalAlignment = ListUI[hz] or ListUI.HCenter
	list.VerticalAlignment = ListUI[vt] or ListUI.VCenter
	list.SortOrder = ListUI[so] or ListUI.SName
	list.Parent = parent
	return list
end

local StrokeUI = {
	ASMBorder = Enum.ApplyStrokeMode.Border,
	ASMContextual = Enum.ApplyStrokeMode.Contextual,

	LJMBevel = Enum.LineJoinMode.Bevel,
	LJMMiter = Enum.LineJoinMode.Miter,
	LJMRound = Enum.LineJoinMode.Round,
}

local function Stroke(parent, asm, r, g, b, ljm, tn, transy)
	local stroke = parent:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	stroke.ApplyStrokeMode = StrokeUI[asm] or StrokeUI.ASMBorder
	stroke.Color = Color3.fromRGB(r or 255, g or 255, b or 255)
	stroke.LineJoinMode = StrokeUI[ljm] or StrokeUI.LJMRound
	stroke.Thickness = tn or 1
	stroke.Transparency = transy or 0
	stroke.Parent = parent
	return stroke
end

local function Gradient(parent, rotation, offsetX, offsetY, ...)
	local grad = parent:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
	grad.Rotation = rotation or 0
	grad.Offset = Vector2.new(offsetX or 0, offsetY or 0)

	local colors = { ... }
	local keypoints = {}

	if #colors == 0 then
		keypoints = {
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
		}
	elseif #colors == 1 then
		keypoints = {
			ColorSequenceKeypoint.new(0, colors[1]),
			ColorSequenceKeypoint.new(1, colors[1]),
		}
	else
		for i, c in ipairs(colors) do
			local t = (i - 1) / (#colors - 1)
			table.insert(keypoints, ColorSequenceKeypoint.new(t, c))
		end
	end

	grad.Color = ColorSequence.new(keypoints)
	grad.Parent = parent
	return grad
end

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
	pad.PaddingLeft = toUDim(left)
	pad.PaddingRight = toUDim(right)
	pad.PaddingTop = toUDim(top)
	pad.Parent = parent
	return pad
end

local Axis = Enum.DominantAxis
local Type = Enum.AspectType

local Width = Axis.Width
local Height = Axis.Height

local Fit = Type.FitWithinMaxSize
local ScaleWithParent = Type.ScaleWithParentSize

local function Aspect(parent, ratio, aspectType, dominantAxis)
	if not parent then
		return
	end

	local existing = parent:FindFirstChildOfClass("UIAspectRatioConstraint")
	if existing then
		existing.AspectRatio = ratio or existing.AspectRatio
		existing.AspectType = aspectType or existing.AspectType
		existing.DominantAxis = dominantAxis or existing.DominantAxis
		return existing
	end

	local constraint = Instance.new("UIAspectRatioConstraint")
	constraint.Parent = parent
	constraint.AspectRatio = ratio or 1
	constraint.AspectType = aspectType or Fit
	constraint.DominantAxis = dominantAxis or Width
	return constraint
end

local function NormalizeId(text)
	text = tostring(text or "")
	local id = text:gsub("%D", "")
	if id ~= "" then
		return id
	end
	return text:gsub("%s+", "")
end

------------------------------------------------------------------------------------------
-- Files
------------------------------------------------------------------------------------------

local Folder = "ExperienceSettings"
local File = Folder .. "/save.json"

local DefaultData = {
	Relax = {
		Idle = {},
		WhenClick = {},
		IdleFPS = 10,
		WhenClickFPS = 10,
	}
}

if not isfolder(Folder) then
	makefolder(Folder)
end

if not isfile(File) then
	writefile(File, HttpService:JSONEncode(DefaultData))
end

local function LoadJson()
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(File))
	end)

	if ok and type(data) == "table" then
		data.Relax = data.Relax or {}
		data.Relax.Idle = data.Relax.Idle or {}
		data.Relax.WhenClick = data.Relax.WhenClick or {}
		data.Relax.IdleFPS = tonumber(data.Relax.IdleFPS) or 10
		data.Relax.WhenClickFPS = tonumber(data.Relax.WhenClickFPS) or 10
		return data
	end

	local fallback = {
		Relax = {
			Idle = {},
			WhenClick = {},
			IdleFPS = 10,
			WhenClickFPS = 10,
		}
	}

	writefile(File, HttpService:JSONEncode(fallback))
	return fallback
end

local Data = LoadJson()

------------------------------------------------------------------------------------------
-- UI Root
------------------------------------------------------------------------------------------

local ESHR = CoreGui:WaitForChild("ExperienceSettings")
	:WaitForChild("Menu")
	:WaitForChild("HolderScreen")

local RelaxGui = Instance.new("Frame")
RelaxGui.Active = true
RelaxGui.BackgroundColor3 = Color3.new(0, 0, 0)
RelaxGui.BackgroundTransparency = 0.6
RelaxGui.Draggable = true
RelaxGui.Position = UDim2.new(0.1, 0, 0.2, 0)
RelaxGui.Size = UDim2.new(0, 50, 0, 30)
RelaxGui.Name = "Relax"
RelaxGui.Parent = ESHR

Corner(0, 8, RelaxGui)
Stroke(RelaxGui, "ASMBorder", 255, 255, 255, "LJMRound", 1, 0)

local Settings = Instance.new("TextButton")
Settings.Text = "Settings"
Settings.TextColor3 = Color3.new(0, 0, 0)
Settings.TextSize = 16
Settings.TextStrokeColor3 = Color3.new(1, 1, 1)
Settings.TextStrokeTransparency = 0
Settings.BackgroundColor3 = Color3.new(0.0705882, 0.0705882, 0.0823529)
Settings.BackgroundTransparency = 0.5
Settings.Position = UDim2.new(1, 4, 0, 0)
Settings.Size = UDim2.new(0, 100, 0, 30)
Settings.Name = "Settings"
Settings.Parent = RelaxGui

Corner(0, 8, Settings)
Stroke(Settings, "ASMBorder", 255, 255, 255, "LJMRound", 1, 0)

local Display = Instance.new("ImageButton")
Display.Active = false
Display.BackgroundColor3 = Color3.new(0, 0, 0)
Display.BackgroundTransparency = 0.8
Display.BorderColor3 = Color3.new(0, 0, 0)
Display.Position = UDim2.new(0, 0, 0, 34)
Display.Size = UDim2.new(0, 200, 0, 200)
Display.Name = "Image"
Display.Image = ""
Display.Parent = RelaxGui

Stroke(Display, "ASMBorder", 255, 255, 255, "LJMRound", 1, 0)
Corner(0, 8, Display)

local Dragger = Instance.new("TextLabel")
Dragger.Text = "Drag"
Dragger.TextColor3 = Color3.new(1, 1, 1)
Dragger.TextSize = 14
Dragger.TextStrokeColor3 = Color3.new(1, 1, 1)
Dragger.TextStrokeTransparency = 0
Dragger.BackgroundTransparency = 1
Dragger.Size = UDim2.new(1, 0, 1, 0)
Dragger.Name = "Dragger"
Dragger.Parent = RelaxGui

local Editor = Instance.new("CanvasGroup")
Editor.BackgroundColor3 = Color3.new(0, 0, 0)
Editor.BackgroundTransparency = 0.3
Editor.BorderSizePixel = 10
Editor.Position = UDim2.new(0, 209, 0, -11)
Editor.Size = UDim2.new(0, 0, 0, 300)
Editor.Name = "Editor"
Editor.BorderMode = Enum.BorderMode.Inset
Editor.Visible = false
Editor.Parent = RelaxGui

Corner(0, 8, Editor)
Stroke(Editor, "ASMBorder", 255, 255, 255, "LJMRound", 1, 0)

local EditorOpened = false
local OpenCloseTween = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

Settings.MouseButton1Click:Connect(function()
	if EditorOpened then
		EditorOpened = false

		local Close = TweenService:Create(Editor, OpenCloseTween, {
			Size = UDim2.new(0, 0, 0, 300)
		})

		Close:Play()
		Close.Completed:Wait()
		Editor.Visible = false
	else
		EditorOpened = true
		Editor.Visible = true

		local Open = TweenService:Create(Editor, OpenCloseTween, {
			Size = UDim2.new(0, 500, 0, 300)
		})

		Open:Play()
	end
end)

------------------------------------------------------------------------------------------
-- Editor UI
------------------------------------------------------------------------------------------

local TEditor = Instance.new("TextLabel")
TEditor.RichText = true
TEditor.Text = "<u><b>Editor</b></u>"
TEditor.TextColor3 = Color3.new(1, 1, 1)
TEditor.TextSize = 16
TEditor.Active = true
TEditor.BackgroundTransparency = 1
TEditor.Size = UDim2.new(0, 100, 0, 30)
TEditor.Name = "TextLabel-editor"
TEditor.TextXAlignment = Enum.TextXAlignment.Left
TEditor.Parent = Editor

local IdleScroll = Instance.new("ScrollingFrame")
IdleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
IdleScroll.ScrollBarThickness = 0
IdleScroll.Active = true
IdleScroll.BackgroundTransparency = 1
IdleScroll.Position = UDim2.new(0, 0, 0, 60)
IdleScroll.Size = UDim2.new(1, 0, 0, 50)
IdleScroll.Name = "Idle"
IdleScroll.Parent = Editor

ListLayout(IdleScroll, 0, 3, "HLeft", "VCenter", "SLayout", "FillH")

local TIdle = Instance.new("TextLabel")
TIdle.RichText = true
TIdle.Text = "Idle"
TIdle.TextColor3 = Color3.new(1, 1, 1)
TIdle.TextSize = 10
TIdle.Active = true
TIdle.BackgroundTransparency = 1
TIdle.Position = UDim2.new(0, 0, 0, 32)
TIdle.Size = UDim2.new(0, 100, 0, 30)
TIdle.Name = "TextLabel-idle"
TIdle.TextXAlignment = Enum.TextXAlignment.Left
TIdle.Parent = Editor

local TWhenClick = Instance.new("TextLabel")
TWhenClick.RichText = true
TWhenClick.Text = "When Click"
TWhenClick.TextColor3 = Color3.new(1, 1, 1)
TWhenClick.TextSize = 10
TWhenClick.Active = true
TWhenClick.BackgroundTransparency = 1
TWhenClick.Position = UDim2.new(0, 0, 0, 112)
TWhenClick.Size = UDim2.new(0, 100, 0, 30)
TWhenClick.Name = "TextLabel-WhenClick"
TWhenClick.TextXAlignment = Enum.TextXAlignment.Left
TWhenClick.Parent = Editor

local WhenClickScroll = Instance.new("ScrollingFrame")
WhenClickScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
WhenClickScroll.ScrollBarThickness = 0
WhenClickScroll.Active = true
WhenClickScroll.BackgroundTransparency = 1
WhenClickScroll.Position = UDim2.new(0, 0, 0, 144)
WhenClickScroll.Size = UDim2.new(1, 0, 0, 50)
WhenClickScroll.Name = "WhenClick"
WhenClickScroll.Parent = Editor

ListLayout(WhenClickScroll, 0, 3, "HLeft", "VCenter", "SLayout", "FillH")

local TFrameRate = Instance.new("TextLabel")
TFrameRate.RichText = true
TFrameRate.Text = "Frame Rate"
TFrameRate.TextColor3 = Color3.new(1, 1, 1)
TFrameRate.TextSize = 10
TFrameRate.Active = true
TFrameRate.BackgroundTransparency = 1
TFrameRate.Position = UDim2.new(0, 0, 0, 194)
TFrameRate.Size = UDim2.new(0, 100, 0, 30)
TFrameRate.Name = "TextLabel-FrameRate"
TFrameRate.TextXAlignment = Enum.TextXAlignment.Left
TFrameRate.Parent = Editor

local IdleInput = Instance.new("TextBox")
IdleInput.PlaceholderColor3 = Color3.new(1, 1, 1)
IdleInput.PlaceholderText = "Idle's FPS"
IdleInput.Text = tostring(Data.Relax.IdleFPS or 10)
IdleInput.TextColor3 = Color3.new(1, 1, 1)
IdleInput.BackgroundColor3 = Color3.new(1, 1, 1)
IdleInput.BackgroundTransparency = 0.8
IdleInput.Position = UDim2.new(0, 0, 0, 230)
IdleInput.Size = UDim2.new(0, 100, 0, 30)
IdleInput.Name = "Idle_FPS"
IdleInput.Parent = Editor
Corner(0, 8, IdleInput)

local WhenClickInput = Instance.new("TextBox")
WhenClickInput.PlaceholderColor3 = Color3.new(1, 1, 1)
WhenClickInput.PlaceholderText = "When Click's FPS"
WhenClickInput.Text = tostring(Data.Relax.WhenClickFPS or 10)
WhenClickInput.TextColor3 = Color3.new(1, 1, 1)
WhenClickInput.BackgroundColor3 = Color3.new(1, 1, 1)
WhenClickInput.BackgroundTransparency = 0.8
WhenClickInput.Position = UDim2.new(0, 104, 0, 230)
WhenClickInput.Size = UDim2.new(0, 100, 0, 30)
WhenClickInput.Name = "WhenClick_FPS"
WhenClickInput.Parent = Editor
Corner(0, 8, WhenClickInput)

local TIdleFrameRate = Instance.new("TextLabel")
TIdleFrameRate.RichText = true
TIdleFrameRate.Text = "Idle Frame Rate"
TIdleFrameRate.TextColor3 = Color3.new(1, 1, 1)
TIdleFrameRate.TextSize = 7
TIdleFrameRate.Active = true
TIdleFrameRate.BackgroundTransparency = 1
TIdleFrameRate.Position = UDim2.new(0, 0, 0, 258)
TIdleFrameRate.Size = UDim2.new(0, 100, 0, 20)
TIdleFrameRate.Name = "TextLabel-Idle-FrameRate"
TIdleFrameRate.Parent = Editor

local TWhenClickFrameRate = Instance.new("TextLabel")
TWhenClickFrameRate.RichText = true
TWhenClickFrameRate.Text = "When Click Frame Rate"
TWhenClickFrameRate.TextColor3 = Color3.new(1, 1, 1)
TWhenClickFrameRate.TextSize = 7
TWhenClickFrameRate.Active = true
TWhenClickFrameRate.BackgroundTransparency = 1
TWhenClickFrameRate.Position = UDim2.new(0, 104, 0, 258)
TWhenClickFrameRate.Size = UDim2.new(0, 100, 0, 20)
TWhenClickFrameRate.Name = "TextLabel-WhenClick-FrameRate"
TWhenClickFrameRate.Parent = Editor

local Save = Instance.new("TextButton")
Save.Text = "Save"
Save.TextColor3 = Color3.new(0, 0, 0)
Save.BackgroundColor3 = Color3.new(0, 1, 0)
Save.Position = UDim2.new(1, -50, 0, 0)
Save.Size = UDim2.new(0, 50, 0, 30)
Save.Name = "Save"
Save.Parent = Editor

Corner(0, 8, Save)
Stroke(Save, "ASMBorder", 255, 255, 255, "LJMRound", 1, 0)

local Addbtn = Instance.new("TextButton")
Addbtn.Text = "+"
Addbtn.TextSize = 20
Addbtn.BackgroundColor3 = Color3.new(1, 1, 1)
Addbtn.LayoutOrder = math.huge
Addbtn.Size = UDim2.new(0, 50, 0, 50)
Addbtn.Name = "AddIdle"
Addbtn.Parent = IdleScroll
Corner(0, 8, Addbtn)

local Addbtn2 = Instance.new("TextButton")
Addbtn2.Text = "+"
Addbtn2.TextSize = 20
Addbtn2.BackgroundColor3 = Color3.new(1, 1, 1)
Addbtn2.LayoutOrder = math.huge
Addbtn2.Size = UDim2.new(0, 50, 0, 50)
Addbtn2.Name = "AddWhenClick"
Addbtn2.Parent = WhenClickScroll
Corner(0, 8, Addbtn2)

------------------------------------------------------------------------------------------
-- Canvas
------------------------------------------------------------------------------------------

local function RefreshCanvas(scroll)
	local layout = scroll:FindFirstChildOfClass("UIListLayout")
	if not layout then
		return
	end

	scroll.CanvasSize = UDim2.fromOffset(layout.AbsoluteContentSize.X + 6, 0)
end

local function BindCanvas(scroll)
	local layout = scroll:FindFirstChildOfClass("UIListLayout")
	if not layout then
		return
	end

	local function update()
		scroll.CanvasSize = UDim2.fromOffset(layout.AbsoluteContentSize.X + 6, 0)
	end

	update()
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
end

BindCanvas(IdleScroll)
BindCanvas(WhenClickScroll)

------------------------------------------------------------------------------------------
-- Data helpers
------------------------------------------------------------------------------------------

local function GetTextBoxesSorted(scroll)
	local boxes = {}

	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("TextBox") then
			table.insert(boxes, child)
		end
	end

	table.sort(boxes, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)

	return boxes
end

local function GetImages(scroll)
	local result = {}

	for _, textbox in ipairs(GetTextBoxesSorted(scroll)) do
		local id = NormalizeId(textbox.Text)
		if id ~= "" then
			table.insert(result, id)
		end
	end

	return result
end

local function RefreshDisplay()
	local boxes = GetTextBoxesSorted(IdleScroll)
	for _, textbox in ipairs(boxes) do
		local id = NormalizeId(textbox.Text)
		if id ~= "" then
			Display.Image = "rbxassetid://" .. id
			return
		end
	end

	Display.Image = ""
end

local function ClearScroll(scroll)
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("TextBox") then
			child:Destroy()
		end
	end
end

local function AddImage(parent, initialId)
	local scroll = parent or IdleScroll

	local Input = Instance.new("TextBox")
	Input.PlaceholderColor3 = Color3.new(1, 1, 1)
	Input.PlaceholderText = "Image ID"
	Input.Text = ""
	Input.TextColor3 = Color3.new(1, 1, 1)
	Input.BackgroundColor3 = Color3.new(1, 1, 1)
	Input.BackgroundTransparency = 0.5
	Input.ClearTextOnFocus = true
	Input.Size = UDim2.new(0, 50, 0, 50)
	Input.ZIndex = 2
	Input.Name = "Image_" .. tostring(#GetTextBoxesSorted(scroll) + 1)
	Input.LayoutOrder = #GetTextBoxesSorted(scroll) + 1
  Input.TextWrapped = true
	Input.Parent = scroll
	Corner(0, 8, Input)

	local Preview = Instance.new("ImageLabel")
	Preview.Active = true
	Preview.BackgroundColor3 = Color3.new(0, 0, 0)
	Preview.BackgroundTransparency = 0
	Preview.Size = UDim2.new(1, 0, 1, 0)
	Preview.ZIndex = 1
	Preview.Parent = Input
	Corner(0, 8, Preview)

	local DelParent = Instance.new("TextButton")
	DelParent.Text = "-"
	DelParent.TextColor3 = Color3.new(1, 1, 1)
	DelParent.TextSize = 15
	DelParent.TextStrokeColor3 = Color3.new(1, 1, 1)
	DelParent.TextWrapped = true
	DelParent.BackgroundColor3 = Color3.fromRGB(225, 0, 0)
	DelParent.Position = UDim2.new(0, 3, 1, -19)
	DelParent.Size = UDim2.new(0, 15, 0, 15)
	DelParent.ZIndex = 3
	DelParent.Parent = Input
	Corner(0, 5, DelParent)

	local function ApplyId(idText)
		local id = NormalizeId(idText)
		if id ~= "" then
			Input.Text = id
			Preview.Image = "rbxassetid://" .. id
			if scroll == IdleScroll then
				RefreshDisplay()
			end
		end
	end

	Input.FocusLost:Connect(function(enterPressed)
		if not enterPressed then
			return
		end
		ApplyId(Input.Text)
		task.defer(function()
			RefreshCanvas(scroll)
		end)
	end)

	DelParent.MouseButton1Click:Connect(function()
		Input:Destroy()

		task.defer(function()
			RefreshCanvas(scroll)
			if scroll == IdleScroll then
				RefreshDisplay()
			end
		end)
	end)

	if initialId then
		ApplyId(initialId)
	end

	task.defer(function()
		RefreshCanvas(scroll)
		if scroll == IdleScroll then
			RefreshDisplay()
		end
	end)

	return {
		String = Input,
		Preview = Preview,
		Delete = DelParent,
	}
end

------------------------------------------------------------------------------------------
-- Bind buttons
------------------------------------------------------------------------------------------

Addbtn.MouseButton1Click:Connect(function()
	AddImage(IdleScroll)
end)

Addbtn2.MouseButton1Click:Connect(function()
	AddImage(WhenClickScroll)
end)

------------------------------------------------------------------------------------------
-- Run Animation
------------------------------------------------------------------------------------------

local CurrentAnimation = "Idle"
local CurrentFrame = 1

local function GetFPSDelay(fps)
	fps = tonumber(fps) or 10
	if fps <= 0 then
		fps = 10
	end
	return 1 / fps
end

task.spawn(function()

	while true do

		local Images
		local Delay

		if CurrentAnimation == "Idle" then
			Images = GetImages(IdleScroll)
			Delay = GetFPSDelay(IdleInput.Text)
		else
			Images = GetImages(WhenClickScroll)
			Delay = GetFPSDelay(WhenClickInput.Text)
		end

		-- ไม่มีรูป
		if #Images == 0 then
			task.wait(0.05)
			continue
		end

		-- ถ้าเฟรมเกินจำนวนรูป
		if CurrentFrame > #Images then

			if CurrentAnimation == "WhenClick" then

				-- กลับไป Idle
				CurrentAnimation = "Idle"
				CurrentFrame = 1

				local IdleImages = GetImages(IdleScroll)

				if #IdleImages > 0 then
					Display.Image = "rbxassetid://" .. IdleImages[1]
				else
					Display.Image = ""
				end

				task.wait(GetFPSDelay(IdleInput.Text))
				continue

			end

			-- Idle Loop
			CurrentFrame = 1

		end

		-- แสดงเฟรม
		Display.Image = "rbxassetid://" .. Images[CurrentFrame]

		CurrentFrame += 1

		task.wait(Delay)

	end

end)

Display.MouseButton1Click:Connect(function()

	local ClickImages = GetImages(WhenClickScroll)

	if #ClickImages == 0 then
		return
	end

	CurrentAnimation = "WhenClick"
	CurrentFrame = 1

end)

------------------------------------------------------------------------------------------
-- Load saved data into UI
------------------------------------------------------------------------------------------

ClearScroll(IdleScroll)
ClearScroll(WhenClickScroll)

for _, id in ipairs(Data.Relax.Idle or {}) do
	AddImage(IdleScroll, tostring(id))
end

for _, id in ipairs(Data.Relax.WhenClick or {}) do
	AddImage(WhenClickScroll, tostring(id))
end

if #GetTextBoxesSorted(IdleScroll) == 0 then
	AddImage(IdleScroll)
end

if #GetTextBoxesSorted(WhenClickScroll) == 0 then
	AddImage(WhenClickScroll)
end

RefreshCanvas(IdleScroll)
RefreshCanvas(WhenClickScroll)
RefreshDisplay()

------------------------------------------------------------------------------------------
-- Save
------------------------------------------------------------------------------------------

Save.MouseButton1Click:Connect(function()
	local Out = {
		Relax = {
			Idle = GetImages(IdleScroll),
			WhenClick = GetImages(WhenClickScroll),
			IdleFPS = tonumber(IdleInput.Text) or 10,
			WhenClickFPS = tonumber(WhenClickInput.Text) or 10,
		}
	}

	writefile(File, HttpService:JSONEncode(Out))
	Data = Out
end)
