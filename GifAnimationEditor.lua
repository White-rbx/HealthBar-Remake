local v_ver = [[Relax 3.2 Type]]
--[[
	You know... all gui was made by me! but script made by chatgpt
]]

------------------------------------------------------------------------------------------
-- Services
------------------------------------------------------------------------------------------

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

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

local function NormalizeId(text)
	text = tostring(text or "")
	local id = text:gsub("%D", "")
	if id ~= "" then
		return id
	end
	return text:gsub("%s+", "")
end

local function Trim(text)
	text = tostring(text or "")
	return text:match("^%s*(.-)%s*$") or ""
end

------------------------------------------------------------------------------------------
-- Files
------------------------------------------------------------------------------------------

local Folder = "ExperienceSettings"
local File = Folder .. "/save.json"

local SetUpData = {
	Idle = {
		"87288722220760",
		"110198608646142",
		"109515403119009",
		"94534807296665",
		"109515403119009",
		"110198608646142",
		"87288722220760",
		"74090248828410",
		"140157555930711",
		"74090248828410"
	},
	WhenClick = {
		"108536153230595",
		"140719134461082",
		"87784765293553",
		"112472844275294",
		"112472844275294",
		"77710265074111",
		"122515039486650",
		"105333712802943",
		"0",
		"0",
		"0",
		"0",
		"101674068212544",
		"82332000482707",
		"137967156256451",
		"91386333466574",
		"91386333466574",
		"91386333466574",
		"109086671336135",
		"109086671336135",
		"109086671336135",
		"109086671336135",
		"109086671336135",
		"109086671336135"
	},
	IdleFPS = 15,
	WhenClickFPS = 5
}

local DefaultData = {
    Relax = {
        Idle = SetUpData.Idle,
        WhenClick = SetUpData.WhenClick,
        IdleFPS = SetUpData.IdleFPS,
        WhenClickFPS = SetUpData.WhenClickFPS,

        GetCustomAsset = false,
        GetCustomAssetPath = "",
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
    data.Relax.GetCustomAsset = data.Relax.GetCustomAsset == true
    data.Relax.GetCustomAssetPath = tostring(data.Relax.GetCustomAssetPath or "")
		return data
	end

	local fallback = {
    Relax = {
        Idle = {},
        WhenClick = {},
        IdleFPS = 10,
        WhenClickFPS = 10,

        GetCustomAsset = false,
        GetCustomAssetPath = "",
    }
}

	writefile(File, HttpService:JSONEncode(fallback))
	return fallback
end

local Data = LoadJson()

local HasGetCustomAsset = typeof(getcustomasset) == "function"
local UseCustomAsset = false

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
			Size = UDim2.fromOffset(0, Editor.Size.Y.Offset)
		})

		Close:Play()
		Close.Completed:Wait()
		Editor.Visible = false
	else
		EditorOpened = true
		Editor.Visible = true

		local Open = TweenService:Create(Editor, OpenCloseTween, {
			Size = UDim2.fromOffset(500, Editor.Size.Y.Offset)
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

local ClearIdle = Instance.new("TextButton")
ClearIdle.Name = "ClearIdle"
ClearIdle.Size = UDim2.new(0,60,0,20)
ClearIdle.Position = UDim2.new(1,0,0,5)
ClearIdle.Text = "Clear All Idle"
ClearIdle.BackgroundColor3 = Color3.new(1,0,0)
ClearIdle.TextColor3 = Color3.new(0,0,0)
ClearIdle.TextStrokeTransparency = 0
ClearIdle.TextStrokeColor3 = Color3.new(1,1,1)
ClearIdle.TextSize = 5
ClearIdle.TextWrapped = true
ClearIdle.Parent = TIdle

Corner(0,3,ClearIdle)
Stroke(ClearIdle, ASMBorder, 100,0,0, LJMRound, 1, 0)

local ClearWhenClick = Instance.new("TextButton")
ClearWhenClick.Name = "ClearWhenClick"
ClearWhenClick.Size = UDim2.new(0,60,0,20)
ClearWhenClick.Position = UDim2.new(1,0,0,5)
ClearWhenClick.Text = "Clear All When Click"
ClearWhenClick.BackgroundColor3 = Color3.new(1,0,0)
ClearWhenClick.TextColor3 = Color3.new(0,0,0)
ClearWhenClick.TextStrokeTransparency = 0
ClearWhenClick.TextStrokeColor3 = Color3.new(1,1,1)
ClearWhenClick.TextSize = 5
ClearWhenClick.TextWrapped = true
ClearWhenClick.Parent = TWhenClick

Corner(0,3,ClearWhenClick)
Stroke(ClearWhenClick, ASMBorder, 100,0,0, LJMRound, 1, 0)

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

local function ClearScroll(scroll)
	for _, v in ipairs(scroll:GetChildren()) do
		if
			not v:IsA("UIListLayout")
			and not v:IsA("UIPadding")
			and not v:IsA("TextButton")
		then
			v:Destroy()
		end
	end
end

ClearIdle.MouseButton1Click:Connect(function()  
  ClearScroll(IdleScroll)  
end)  
  
ClearWhenClick.MouseButton1Click:Connect(function()  
  ClearScroll(WhenClickScroll)  
end) 

local GetFrame = Instance.new("Frame")
GetFrame.Name = "GetcustomassetSwitch"
GetFrame.Size = UDim2.new(0, 100, 0, 30)
GetFrame.Position = UDim2.new(1, -154, 0, 0)
GetFrame.Active = false
GetFrame.BackgroundColor3 = Color3.fromRGB(87, 87, 87)
GetFrame.Parent = Editor
Corner(0, 8, GetFrame)

local GetFrame_Stroke = Stroke(GetFrame, "ASMBorder", 255, 0, 0, "LJMRound", 1, 0)
GetFrame_Stroke.Color = Color3.fromRGB(255, 0, 0)

local GetPath = Instance.new("TextBox")
GetPath.Name = "Getdevicepathinput"
GetPath.Size = UDim2.new(0, 0, 1, 0)
GetPath.Position = UDim2.new(0, 113, 0, 0)
GetPath.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
GetPath.TextColor3 = Color3.new(1, 1, 1)
GetPath.Text = Data.Relax.GetCustomAssetPath or ""
GetPath.PlaceholderText = "Example: 'Folder/'"
GetPath.ClearTextOnFocus = false
GetPath.TextScaled = true
GetPath.PlaceholderColor3 = Color3.new(0.7, 0.7, 0.7)
GetPath.Visible = false
GetPath.Parent = GetFrame
Corner(0, 8, GetPath)
Stroke(GetPath, "ASMBorder", 255, 255, 255, "LJMRound", 1, 0)

UseCustomAsset = Data.Relax.GetCustomAsset == true

local GetSwitch = Instance.new("TextButton")
GetSwitch.Name = "GetSwitch"
GetSwitch.Size = UDim2.new(0, 50, 1, 0)
GetSwitch.Position = UDim2.new(0, 0, 0, 0)
GetSwitch.Text = "Image"
GetSwitch.TextColor3 = Color3.new(0, 0, 0)
GetSwitch.TextStrokeTransparency = 0
GetSwitch.TextStrokeColor3 = Color3.new(1, 1, 1)
GetSwitch.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
GetSwitch.TextWrapped = true
GetSwitch.Parent = GetFrame
Corner(0, 8, GetSwitch)

local TCredit = Instance.new("TextLabel")
TCredit.Name = "Textlabel-Credit"
TCredit.Position = UDim2.new(1,-100,1,-10)
TCredit.Size = UDim2.new(0,100,0,10)
TCredit.BackgroundTransparency = 1
TCredit.TextColor3 = Color3.new(1,1,1)
TCredit.RichText = true
TCredit.Text = "Relax / Gif Animation Editor by <font color='rgb(85,255,255)'>5teve3019D</font>"
TCredit.TextXAlignment = Enum.TextXAlignment.Right
TCredit.Parent = Editor


local MoreMenu = Instance.new("TextButton")
MoreMenu.Name = "MoreMenu"
MoreMenu.Position = UDim2.new(1,-30,0,230)
MoreMenu.Size = UDim2.new(0,30,0,30)
MoreMenu.TextColor3 = Color3.new(1,1,1)
MoreMenu.BackgroundColor3 = Color3.new(0.3,0.3,0.3)
MoreMenu.Text = "• • •"
MoreMenu.Parent = Editor

Corner(0,8,MoreMenu)
Stroke(MoreMenu, ASMBorder, 255,255,255, LJMRound, 1, 0)

local EditorMore = false

MoreMenu.MouseButton1Click:Connect(function()
	if EditorMore then
		EditorMore = false

		local Close = TweenService:Create(Editor, OpenCloseTween, {
			Size = UDim2.fromOffset(Editor.Size.X.Offset, 300),
      Position = UDim2.fromOffset(Editor.Position.X.Offset, -11)
		})

    MoreMenu.Text = "• • •"

		Close:Play()
		Close.Completed:Wait()
	else
		EditorMore = true
		
		local Open = TweenService:Create(Editor, OpenCloseTween, {
			Size = UDim2.fromOffset(Editor.Size.X.Offset, 500),
      Position = UDim2.fromOffset(Editor.Position.X.Offset, -100)
		})

    MoreMenu.Text = "X"

		Open:Play()
	end
end)

------------------------------------------------------------------------------------------
-- Canvas / Data Helpers
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

local function RefreshLayout(scroll)
	local index = 1

	for _, object in ipairs(scroll:GetChildren()) do
		if object:IsA("TextBox") then
			object.LayoutOrder = index
			object.Name = "Image_" .. index
			index += 1
		end
	end
end

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

local function ResolveFrameSource(text)
	text = Trim(text)

	if text == "" or text == "0" then
		return ""
	end

	if text:match("^rbxassetid://") then
		return text
	end

	if text:match("^%d+$") then
		return "rbxassetid://" .. text
	end

	if HasGetCustomAsset then
	local path = Trim(GetPath and GetPath.Text or "")

	if path ~= "" then
		local ok, asset = pcall(function()
			return getcustomasset(path .. text)
		end)

		if ok and asset then
    return asset
end
	end
end

	return ""
end

local function GetFrameValues(scroll)
	local result = {}

	for _, textbox in ipairs(GetTextBoxesSorted(scroll)) do
		local text = Trim(textbox.Text)
		if text == "" then
			text = "0"
		end
		table.insert(result, text)
	end

	return result
end

local function RefreshAllPreviews(scroll)
	for _, textbox in ipairs(GetTextBoxesSorted(scroll)) do
		local preview = textbox:FindFirstChildOfClass("ImageLabel")
		if preview then
			preview.Image = ResolveFrameSource(textbox.Text)
		end
	end
end

local function RefreshDisplay()
	local boxes = GetTextBoxesSorted(IdleScroll)
	for _, textbox in ipairs(boxes) do
		local src = ResolveFrameSource(textbox.Text)
		if src ~= "" then
			Display.Image = src
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

local function AddImage(parent, initialText)
	local scroll = parent or IdleScroll

	local Input = Instance.new("TextBox")
	Input.PlaceholderColor3 = Color3.new(1, 1, 1)
	Input.PlaceholderText = "Image ID"
	Input.Text = tostring(initialText or "")
	Input.TextColor3 = Color3.new(1, 1, 1)
	Input.BackgroundColor3 = Color3.new(1, 1, 1)
	Input.BackgroundTransparency = 0.5
	Input.ClearTextOnFocus = false
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
		Input.Text = tostring(idText or "")
		local src = ResolveFrameSource(Input.Text)
		Preview.Image = src
		if scroll == IdleScroll then
			RefreshDisplay()
		end
	end

	Input.FocusLost:Connect(function(enterPressed)
		if not enterPressed then
			return
		end

		ApplyId(Input.Text)
		task.defer(function()
			RefreshLayout(scroll)
			RefreshCanvas(scroll)
			RefreshAllPreviews(scroll)
		end)
	end)

	DelParent.MouseButton1Click:Connect(function()
		Input:Destroy()

		task.defer(function()
			RefreshLayout(scroll)
			RefreshCanvas(scroll)
			if scroll == IdleScroll then
				RefreshDisplay()
			end
		end)
	end)

	if initialText ~= nil then
		ApplyId(initialText)
	end

	task.defer(function()
		RefreshLayout(scroll)
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

local function SetCustomAssetState(state, instant)
	if not HasGetCustomAsset then
		UseCustomAsset = false
		return
	end

	UseCustomAsset = state and true or false

	local openFramePos = UDim2.new(0, 104, 0, 0)
	local closeFramePos = UDim2.new(1, -154, 0, 0)

	local openPathSize = UDim2.new(0, 200, 1, 0)
	local closePathSize = UDim2.new(0, 0, 1, 0)

	local openSwitchPos = UDim2.new(0, 50, 0, 0)
	local closeSwitchPos = UDim2.new(0, 0, 0, 0)

	if instant then
		GetFrame.Position = UseCustomAsset and openFramePos or closeFramePos
		GetPath.Size = UseCustomAsset and openPathSize or closePathSize
		GetSwitch.Position = UseCustomAsset and openSwitchPos or closeSwitchPos
		GetPath.Visible = UseCustomAsset
	else
		if UseCustomAsset then
			GetPath.Visible = true

			TweenService:Create(GetFrame, TweenInfo.new(.2), {
				Position = openFramePos
			}):Play()

			TweenService:Create(GetPath, TweenInfo.new(.2), {
				Size = openPathSize
			}):Play()

			TweenService:Create(GetSwitch, TweenInfo.new(.2), {
				Position = openSwitchPos
			}):Play()
		else
			TweenService:Create(GetFrame, TweenInfo.new(.2), {
				Position = closeFramePos
			}):Play()

			TweenService:Create(GetPath, TweenInfo.new(.2), {
				Size = closePathSize
			}):Play()

			TweenService:Create(GetSwitch, TweenInfo.new(.2), {
				Position = closeSwitchPos
			}):Play()

			task.delay(.2, function()
				GetPath.Visible = false
			end)
		end
	end

	if UseCustomAsset then
		GetFrame_Stroke.Color = Color3.fromRGB(0, 255, 0)
		GetSwitch.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		GetSwitch.Text = "Getcustomasset"
	else
		GetFrame_Stroke.Color = Color3.fromRGB(255, 0, 0)
		GetSwitch.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		GetSwitch.Text = "Image"
	end

	RefreshAllPreviews(IdleScroll)
	RefreshAllPreviews(WhenClickScroll)
	RefreshDisplay()
end

------------------------------------------------------------------------------------------
-- getcustomasset UI state
------------------------------------------------------------------------------------------

if not HasGetCustomAsset then
	GetSwitch.Active = false
	GetSwitch.AutoButtonColor = false

	local OldText = GetSwitch.Text
	GetSwitch.Text = "Executor not support getcustomasset()"

	task.delay(3, function()
		if GetSwitch then
			GetSwitch.Text = OldText
		end
	end)
else
	SetCustomAssetState(false, true)
end

GetSwitch.MouseButton1Click:Connect(function()
	if not HasGetCustomAsset then
		return
	end

	SetCustomAssetState(not UseCustomAsset, false)
end)

GetPath.FocusLost:Connect(function()
	RefreshAllPreviews(IdleScroll)
	RefreshAllPreviews(WhenClickScroll)
	RefreshDisplay()
end)

------------------------------------------------------------------------------------------
-- Bind buttons
------------------------------------------------------------------------------------------

Addbtn.MouseButton1Click:Connect(function()
	AddImage(IdleScroll)
	RefreshLayout(IdleScroll)
	RefreshCanvas(IdleScroll)
end)

Addbtn2.MouseButton1Click:Connect(function()
	AddImage(WhenClickScroll)
	RefreshLayout(WhenClickScroll)
	RefreshCanvas(WhenClickScroll)
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
			Images = GetFrameValues(IdleScroll)
			Delay = GetFPSDelay(IdleInput.Text)
		else
			Images = GetFrameValues(WhenClickScroll)
			Delay = GetFPSDelay(WhenClickInput.Text)
		end

		if #Images == 0 then
			task.wait(0.05)
			continue
		end

		if CurrentFrame > #Images then
			if CurrentAnimation == "WhenClick" then
				CurrentAnimation = "Idle"
				CurrentFrame = 1

				local IdleImages = GetFrameValues(IdleScroll)
				if #IdleImages > 0 then
					Display.Image = ResolveFrameSource(IdleImages[1])
				else
					Display.Image = ""
				end

				task.wait(GetFPSDelay(IdleInput.Text))
				continue
			end

			CurrentFrame = 1
		end

		Display.Image = ResolveFrameSource(Images[CurrentFrame])
		CurrentFrame += 1

		task.wait(Delay)
	end
end)

Display.MouseButton1Click:Connect(function()
	local ClickImages = GetFrameValues(WhenClickScroll)
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

RefreshLayout(IdleScroll)
RefreshLayout(WhenClickScroll)
RefreshCanvas(IdleScroll)
RefreshCanvas(WhenClickScroll)
RefreshAllPreviews(IdleScroll)
RefreshAllPreviews(WhenClickScroll)
RefreshDisplay()

------------------------------------------------------------------------------------------
-- Save
------------------------------------------------------------------------------------------

Save.MouseButton1Click:Connect(function()
	RefreshLayout(IdleScroll)
	RefreshLayout(WhenClickScroll)

	local Out = {
		Relax = {
			Idle = GetFrameValues(IdleScroll),
      WhenClick = GetFrameValues(WhenClickScroll),
      GetCustomAsset = UseCustomAsset,
      GetCustomAssetPath = Trim(GetPath.Text),
			IdleFPS = tonumber(IdleInput.Text) or 10,
			WhenClickFPS = tonumber(WhenClickInput.Text) or 10,
		}
	}

	writefile(File, HttpService:JSONEncode(Out))
	Data = Out
end)
