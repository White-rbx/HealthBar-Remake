-- string starting//
-- 7 script (IMPORTANT)
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/LigherCyan.ai/refs/heads/main/Loader.lua"))()

-- string:LighterCyan:ai()
-- Parent Finder
local Ex = game:GetService("CoreGui").TopBarApp.TopBarApp.UnibarLeftFrame.HealthBar.ExperienceSettings
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
Error, Warn and Information Detectors
~~~~~~~~~~~~~~~~~~
Error: 0
Warn: 0
Information: 0
~~~~~~~~~~~~~~~~~~
Script state: Good
~~~~~~~~~~~~~~~~~~
]]

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
-- =====END FUNCTION UIPADDING==end

-- Instance
local Gui = Instance.new("ScreenGui")
Gui.Name = "LighterCyan.ai"
Gui.ResetOnSpawn = false
Gui.Parent = Ex -- Ex คือ PlayerGui ในสคริปต์นี้
createUIListLayout(Gui, 0, 5, HCenter, VBottom, SName, FillV)

local useless = Instance.new("Frame")
useless.Name = "Holder"
useless.Size = UDim2.new(0.5, 0, 0.9, 0) -- //Fixed
useless.BackgroundTransparency = 1 -- แก้จาก .Transparency
useless.Active = false
useless.Parent = Gui
createUIListLayout(useless, 0, 5, HCenter, VCenter, SName, FillV)

local insetFrame = Instance.new("Frame")
insetFrame.Name = "InsetFrame"
insetFrame.Size = UDim2.new(0.96, 0, 1, 0)
insetFrame.BackgroundTransparency = 1
insetFrame.Parent = useless
createUIListLayout(insetFrame, 0, 5, HCenter, VBottom, SName, FillV)

-- [ INSETFRAME ]

local tabel = Instance.new("Frame")
tabel.Name = "a4_Tabel"
tabel.Size = UDim2.new(1, 0, 0, 70)
tabel.BackgroundTransparency = 1
tabel.Parent = insetFrame

local input = Instance.new("Frame")
input.Name = "a3_Input&Send"
input.Size = UDim2.new(1, 0, 0, 50)
input.BackgroundColor3 = Color3.fromRGB(255,255,255)
input.BackgroundTransparency = 0.6
input.Parent = insetFrame
Corner(0, 8, input)
Stroke(input, ASMBorder, 255, 255, 255, LJMRound, 1, 0)

local chat = Instance.new("Frame")
chat.Name = "a2_Chat"
chat.Size = UDim2.new(1, 0, 0, 300)
chat.BackgroundColor3 = Color3.fromRGB(255,255,255)
chat.BackgroundTransparency = 0.5
chat.Parent = insetFrame
Corner(0, 8, chat)
Stroke(chat,  ASMBorder, 255, 255, 255, LJMRound, 1, 0)
createUIListLayout(chat, 0, 5, HCenter, VCenter, SName, FillV)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "Chat"
Scroll.Size = UDim2.new(0.96, 0, 0.96, 0)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 0
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Visible = true
Scroll.Parent = chat
createUIListLayout(Scroll, 0, 5, HCenter, VTop, SLayout, FillV)

local Scroll2 = Instance.new("ScrollingFrame")
Scroll2.Name = "Settings"
Scroll2.Size = UDim2.new(0.96, 0, 0.96, 0)
Scroll2.BackgroundTransparency = 1
Scroll2.ScrollBarThickness = 0
Scroll2.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll2.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll2.Visible = false
Scroll2.Parent = chat
createUIListLayout(Scroll2, 0, 5, HCenter, VTop, SLayout, FillV)

local Scroll3 = Instance.new("ScrollingFrame")
Scroll3.Name = "More"
Scroll3.Size = UDim2.new(0.96, 0, 0.96, 0)
Scroll3.BackgroundTransparency = 1
Scroll3.ScrollBarThickness = 0
Scroll3.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll3.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll3.Visible = false
Scroll3.Parent = chat
createUIListLayout(Scroll3, 0, 5, HCenter, VTop, SLayout, FillV)

-- safe_attach_auto_resize_no_auto: ปรับขนาดด้วย TextService; ไม่มี MAX_H limit
local function safe_attach_auto_resize_no_auto(frame, label)
    if not (frame and frame:IsA("Frame") and label and label:IsA("TextLabel")) then return end

    -- prefer existing attach_auto_resize if present
    if type(attach_auto_resize) == "function" and attach_auto_resize ~= safe_attach_auto_resize_no_auto then
        pcall(function() attach_auto_resize(frame, label) end)
        return
    end

    local okMin, MIN_H = pcall(function() return MIN_HEIGHT end)
    if not okMin or type(MIN_H) ~= "number" then MIN_H = 60 end
    local TextService = game:GetService("TextService")

    local function get_label_width()
        local sc = (type(find_scroll_frame)=="function" and pcall(find_scroll_frame) and find_scroll_frame()) or nil
        local scW = (sc and sc.AbsoluteSize and sc.AbsoluteSize.X) or 400
        return math.max(32, math.floor(scW * 0.88))
    end

    local function clean_text(s)
        if not s then return "" end
        s = tostring(s):gsub("\r","")
        s = s:gsub("^%s+",""):gsub("%s+$","")
        return s
    end

    local lastApplied = 0

    local function apply_size_now()
        pcall(function()
            local txt = clean_text(label.Text or "")
            if txt == "" then
                if lastApplied ~= MIN_H then
                    frame.Size = UDim2.new(0.96, 0, 0, MIN_H)
                    lastApplied = MIN_H
                    local sc = (type(find_scroll_frame)=="function" and find_scroll_frame()) or nil
                    pcall(function() if type(update_canvas)=="function" then update_canvas(sc) end end)
                end
                return
            end

            -- short texts -> minimal height
            if #txt <= 6 then
                if lastApplied ~= MIN_H then
                    frame.Size = UDim2.new(0.96, 0, 0, MIN_H)
                    lastApplied = MIN_H
                    local sc = (type(find_scroll_frame)=="function" and find_scroll_frame()) or nil
                    pcall(function() if type(update_canvas)=="function" then update_canvas(sc) end end)
                end
                return
            end

            local avail = get_label_width()
            local ok, dims = pcall(function()
                return TextService:GetTextSize(txt, label.TextSize or 16, label.Font or Enum.Font.SourceSans, Vector2.new(avail, math.huge))
            end)
            local textHeight = (ok and dims and dims.Y) and dims.Y or (label.TextSize * 1.2)
            local newH = math.ceil(textHeight) + 18
            -- NO MAX limit here (user requested), only enforce min
            if math.abs(newH - lastApplied) > 1 then
                frame.Size = UDim2.new(0.96, 0, 0, newH)
                lastApplied = newH
                local sc = (type(find_scroll_frame)=="function" and find_scroll_frame()) or nil
                pcall(function() if type(update_canvas)=="function" then update_canvas(sc) end end)
            end
        end)
    end

    task.spawn(function() task.wait(0.02); apply_size_now() end)

    local conText = label:GetPropertyChangedSignal("Text"):Connect(function()
        task.defer(function() task.wait(0.01); apply_size_now() end)
    end)

    local sc = (type(find_scroll_frame)=="function" and pcall(find_scroll_frame) and find_scroll_frame()) or nil
    local conScroll = nil
    if sc then
        conScroll = sc:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            task.defer(function() task.wait(0.02); apply_size_now() end)
        end)
    end

    local ancCon
    ancCon = frame.AncestryChanged:Connect(function()
        if not frame:IsDescendantOf(game) then
            pcall(function()
                if conText and conText.Disconnect then conText:Disconnect() end
                if conScroll and conScroll.Disconnect then conScroll:Disconnect() end
                if ancCon and ancCon.Disconnect then ancCon:Disconnect() end
            end)
        end
    end)

    return function()
        pcall(function()
            if conText and conText.Disconnect then conText:Disconnect() end
            if conScroll and conScroll.Disconnect then conScroll:Disconnect() end
            if ancCon and ancCon.Disconnect then ancCon:Disconnect() end
        end)
    end
end

-- alias ให้เรียกใช้งานโดยชื่อเดิม
if type(attach_auto_resize) ~= "function" then
    attach_auto_resize = safe_attach_auto_resize_no_auto
end

--// ===== TYPEWRITER EFFECT WITH SOUND + LOCK SYSTEM ===== \\--

local isAITyping = false  -- ป้องกันการพิมพ์ซ้ำระหว่าง AI คิด

-- เล่นเสียงง่าย ๆ
local function playSound(soundId, parent)
	if not soundId then return end
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://" .. tostring(soundId)
	s.Volume = 0.2
	s.PlayOnRemove = true
	s.Parent = parent or game:GetService("CoreGui")
	s:Destroy()
end

-- พิมพ์ทีละตัวอักษร
local function typewrite(label, fullText, delayPerChar, soundId, callback)
	if not (label and label:IsA("TextLabel")) then
		if callback then callback() end
		return
	end
	fullText = tostring(fullText or "")
	delayPerChar = tonumber(delayPerChar) or 0.02
	label.Text = ""

	task.spawn(function()
		for i = 1, #fullText do
			pcall(function()
				label.Text = string.sub(fullText, 1, i)
				playSound(soundId, label)
			end)
			task.wait(delayPerChar)
		end
		if callback then callback() end
	end)
end

-- ล็อคช่องพิมพ์ระหว่าง AI ทำงาน
local function lockTextbox(box, locked)
	if not (box and box:IsA("TextBox")) then return end
	pcall(function()
		box.Active = not locked
		box.Selectable = not locked
		box.TextEditable = not locked
		if locked then
			box.PlaceholderText = "[Thinking...]"
		else
			box.PlaceholderText = "Ask anything..."
		end
	end)
end


--// ====== ฟังก์ชันแชท ====== \\--

-- ai() – มีเสียงและพิมพ์ทีละตัว
local function ai(Text, Offset)
	isAITyping = true
	lockTextbox(box, true)

	Offset = tonumber(Offset) or 0
	local ai = Instance.new("Frame")
	ai.Name = "ai"
	ai.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ai.BackgroundTransparency = 0.8
	ai.Size = UDim2.new(0.96, 0, 0, Offset)
	ai.Parent = Scroll
	createUIListLayout(ai, 0, 10, HCenter, VCenter, SName, FillH)
	Stroke(ai, ASMBorder, 255, 255, 255, LJMRound, 1, 0)
	Corner(0, 8, ai)

	local image = Instance.new("ImageLabel")
	image.Name = "a1"
	image.Image = "rbxassetid://83032822916288"
	image.Size = UDim2.new(0, 50, 0, 50)
	image.BackgroundTransparency = 0.8
	image.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	image.Parent = ai
	Corner(0, 8, image)
	Stroke(image, ASMBorder, 255, 255, 255, LJMRound, 1, 0)

	local text = Instance.new("TextLabel")
	text.Name = "a2"
	text.Size = UDim2.new(0.88, -8, 1, 0)
	text.BackgroundTransparency = 1
    text.AutomaticSize = Enum.AutomaticSize.Y
	text.TextSize = 15
	text.TextWrapped = true
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.TextYAlignment = Enum.TextYAlignment.Top
	text.Parent = ai

	typewrite(text, Text or "Thinking...", 0.02, 18439142106, function()
		isAITyping = false
		lockTextbox(box, false)
	end)

	attach_auto_resize(ai, text)
	return ai
end


-- plr() – มีเสียงและ auto resize
local function plr(Text, Offset)
	Offset = tonumber(Offset) or 0
	local plrFrame = Instance.new("Frame")
	plrFrame.Name = "plr"
	plrFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
	plrFrame.BackgroundTransparency = 0.8
	plrFrame.Size = UDim2.new(0.96, 0, 0, Offset)
	plrFrame.Parent = Scroll
	createUIListLayout(plrFrame, 0, 10, HCenter, VCenter, SName, FillH)
	Stroke(plrFrame, ASMBorder, 255, 255, 255, LJMRound, 1, 0)
	Corner(0, 8, plrFrame)

	local image = Instance.new("ImageLabel")
	image.Name = "a2"
	image.Image = "rbxassetid://135474395711579"
	image.Size = UDim2.new(0, 50, 0, 50)
	image.BackgroundTransparency = 0.8
	image.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	image.Parent = plrFrame
	Corner(0, 8, image)
	Stroke(image, ASMBorder, 255, 255, 255, LJMRound, 1, 0)

	local text = Instance.new("TextLabel")
	text.Name = "a1"
	text.Size = UDim2.new(0.88, -8, 1, 0)
	text.BackgroundTransparency = 1
    text.AutomaticSize = Enum.AutomaticSize.Y
	text.TextSize = 15
	text.TextWrapped = true
	text.TextXAlignment = Enum.TextXAlignment.Right
	text.TextYAlignment = Enum.TextYAlignment.Top
	text.Parent = plrFrame

	typewrite(text, Text or "", 0.02, 1289263994)
	attach_auto_resize(plrFrame, text)
	return plrFrame
end


-- SAFE mesg() replacement
-- usage: mesg(text, offset, R,G,B, R1,G1,B1)
local function mesg(Text, Offset, R, G, B, R1, G1, B1)
    -- safe guards and normalise
    Text = tostring(Text or "")
    Offset = tonumber(Offset) or 60

    -- find Scroll parent safely (prefer existing Scroll global if available)
    local scroll = nil
    pcall(function()
        if Scroll and (type(Scroll)=="userdata" or type(Scroll)=="table") then
            scroll = Scroll
        elseif type(find_scroll_frame) == "function" then
            local ok, s = pcall(find_scroll_frame)
            if ok and s then scroll = s end
        end
    end)

    -- create frame
    local mesge = Instance.new("Frame")
    mesge.Name = "message"
    mesge.BackgroundColor3 = Color3.fromRGB(R or 240, G or 240, B or 240)
    mesge.BackgroundTransparency = 0.8
    mesge.Size = UDim2.new(0.96, 0, 0, Offset)
    -- attach to Scroll if available, else fallback to CoreGui (very rare)
    pcall(function()
        if scroll and scroll.Parent then
            mesge.Parent = scroll
        else
            local fallbackParent = game:GetService("CoreGui")
            if fallbackParent then mesge.Parent = fallbackParent end
        end
    end)

    -- try to run helper functions safely (Stroke/Corner/createUIListLayout)
    pcall(function() if type(createUIListLayout)=="function" then createUIListLayout(mesge, 0, 10, HCenter, VCenter, SName, FillH) end end)
    pcall(function() if type(Stroke)=="function" then Stroke(mesge, ASMBorder, 255,255,255, LJMRound, 1, 0) end end)
    pcall(function() if type(Corner)=="function" then Corner(0, 8, mesge) end end)

    -- create text label
    local text = Instance.new("TextLabel")
    text.Name = "a1"
    text.Size = UDim2.new(0.88, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(R1 or 0, G1 or 0, B1 or 0)
    text.TextSize = 15
    text.TextWrapped = true
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.TextYAlignment = Enum.TextYAlignment.Center
    text.Parent = mesge

    -- prepare TextService for measurement
    local TextService = game:GetService("TextService")

    -- helper to measure height (pixel) for given text and label settings
    local function measure_height_for(label, txt)
        txt = tostring(txt or ""):gsub("\r",""):gsub("^%s+",""):gsub("%s+$","")
        if txt == "" then return Offset end
        local scW = 400
        pcall(function()
            if scroll and scroll.AbsoluteSize and scroll.AbsoluteSize.X then scW = scroll.AbsoluteSize.X end
        end)
        local avail = math.max(32, math.floor(scW * 0.88))
        local ok, dims = pcall(function()
            return TextService:GetTextSize(txt, label.TextSize or 15, label.Font or Enum.Font.SourceSans, Vector2.new(avail, math.huge))
        end)
        local h = (ok and dims and dims.Y) and dims.Y or (label.TextSize * 1.2)
        return math.max(Offset, math.ceil(h) + 18)
    end

    -- set tentative size BEFORE typing (so frame won't jump)
    local computed = measure_height_for(text, Text)
    pcall(function() mesge.Size = UDim2.new(0.96, 0, 0, computed) end)
    pcall(function() if type(update_canvas) == "function" then update_canvas(scroll) end end)

    -- if typewrite exists, use it (it may also call attach_auto_resize on text changes)
    if type(typewrite) == "function" then
        -- typewrite will update text gradually; we already set size above
        pcall(function() typewrite(text, Text, 0.02, 263105619) end)
    else
        -- fallback: set text immediately
        pcall(function() text.Text = Text end)
    end

    -- finally, call attach_auto_resize safely if available (it will manage dynamic changes)
    pcall(function() if type(attach_auto_resize) == "function" then attach_auto_resize(mesge, text) end end)

    return mesge
end
-- =====END FUNCTION AI AND PLAYER + END INSETFRAME=====

-- [ INPUT ]
local box = Instance.new("TextBox")
box.Name = "Ask"
box.Size = UDim2.new(0.72, 0, 0.9, 0)
box.Position = UDim2.new(0.02, 0, 0.05, 0)
box.BackgroundTransparency = 1
box.PlaceholderColor3 = Color3.fromRGB(95,95,95)
box.PlaceholderText = "Ask anything..."
box.Text = ""
box.TextScaled = true
box.TextColor3 = Color3.fromRGB(0,0,0)
box.RichText = true
box.ClearTextOnFocus = false
box.Parent = input

local send = Instance.new("TextButton")
send.Name = "Send"
send.Size = UDim2.new(0.076, 0, 0.9, 0)
send.Position = UDim2.new(0.75, 0, 0.05, 0)
send.BackgroundTransparency = 0.6
send.TextScaled = true
send.Text = "✓"
send.TextColor3 = Color3.fromRGB(0,0,0)
send.Parent = input
Corner(0, 8, send)
Stroke(send, ASMBorder, 255, 255, 255, LSMRound, 1, 0)

local clear = Instance.new("TextButton")
clear.Name = "clear"
clear.Size = UDim2.new(0.076, 0, 0.9, 0)
clear.Position = UDim2.new(0.835, 0, 0.05, 0)
clear.BackgroundTransparency = 0.6
clear.TextScaled = true
clear.Text = "×"
clear.TextColor3 = Color3.fromRGB(0,0,0)
clear.Parent = input
Corner(0, 8, clear)
Stroke(clear, ASMBorder, 255, 255, 255, LSMRound, 1, 0)

local rec = Instance.new("TextButton")
rec.Name = "re-chat"
rec.Size = UDim2.new(0.076, 0, 0.9, 0)
rec.Position = UDim2.new(0.918, 0, 0.05, 0)
rec.BackgroundTransparency = 0.6
rec.TextScaled = true
rec.Text = "re-chat"
rec.TextColor3 = Color3.fromRGB(0,0,0)
rec.Parent = input
Corner(0, 8, rec)
Stroke(rec, ASMBorder, 255, 255, 255, LSMRound, 1, 0)

mesg("Verison: Alpha Dev Test", 30, 76, 76, 76, 255, 255, 255)
mesg("copyright © ExperienceSettings-ChatGPT 2025", 30, 76, 76, 76, 255, 255, 255)
ai("I'm ready to chat with you!", 60)
mesg(" --[ New Chat ]--", 30, 0, 0, 0, 255, 255, 255)
mesg("Please Re-Chat before chatting.", 30, 0, 0, 0, 75, 75, 75)

local option = Instance.new("Frame")
option.Name = "a1_option"
option.Size = UDim2.new(1, 0, 0, 50)
option.BackgroundColor3 = Color3.fromRGB(255,255,255)
option.BackgroundTransparency = 1
option.Parent = insetFrame

local logo = Instance.new("Frame")
logo.Name = "a1.logo"
logo.Size = UDim2.new(0.2, 0, 0, 50)
logo.BackgroundColor3 = Color3.fromRGB(255,255,255)
logo.BackgroundTransparency = 0.6
logo.Parent = option
Corner(0, 8, logo)
Stroke(logo, ASMBorder, 255, 255, 255, LSMRound, 1, 0)

local lotext = Instance.new("TextLabel")
lotext.Name = "Text"
lotext.Size = UDim2.new(0.9, 0, 0.9, 0)
lotext.Position = UDim2.new(0.05, 0, 0.05, 0)
lotext.BackgroundTransparency = 1
lotext.Text = "LighterCyan"
lotext.TextColor3 = Color3.fromRGB(255, 255, 255)
lotext.TextStrokeTransparency = 0
lotext.TextStrokeColor3 = Color3.fromRGB(85, 255, 255)
lotext.TextScaled = true
lotext.Parent = logo

-- =====FUNCTION TEXTBUTTON=====
local function btm(Name, Text, Pos)
    local btm1 = Instance.new("Frame")
    btm1.Name = tostring(Name or "")
    btm1.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btm1.BackgroundTransparency = 0.6
    btm1.Size = UDim2.new(0.1, 0, 0, 50)
    btm1.Position = UDim2.new(Pos or 0, 0, 0, 0)
    btm1.Parent = option
    Corner(0, 8, btm1)
    Stroke(btm1, ASMBorder, 255, 255, 255, LJMRound, 1, 0)

    local btm2 = Instance.new("TextButton")
    btm2.Size = UDim2.new(0.9, 0, 0.9, 0)
    btm2.Position = UDim2.new(0.05, 0, 0.05, 0)
    btm2.TextScaled = true
    btm2.BackgroundTransparency = 1
    btm2.Text = tostring(Text or "")
    btm2.Parent = btm1

    -- ใส่ Gradient ดำล้วน
    Gradient(btm2, 0, 0, 0, Color3.fromRGB(0,0,0), Color3.fromRGB(0,0,0))

    return btm1
end

btm("a2.Chat", "🗨️ Chat", 0)
btm("a3.Settings", "⚙️ Settings", 0)
btm("a4.Explorer", "🌏 Explorer", 0)
btm("a5.About", "📜 About", 0)
btm("a6.Executor", "✏️ Executor", 0)
btm("a7.SaveScript", "📂 SaveScript", 0)
btm("z9.More", "📦 More", 0)
createUIListLayout(option, 0, 5, HLeft, VCenter, SName, FillH) -- btw Scaled 0 because UIListLayout haha, now go back to work.

-- LighterCyan Controller — Final with attach_auto_resize
-- Run after Loader/bootstrap. Paste into executor or LocalScript (client).

local DEBUG = false
local GUI_WAIT_TIMEOUT = 12
local THINKING_BASE = "Thinking"
local MIN_HEIGHT = 60 -- min pixel height for frames

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local player = Players.LocalPlayer
if not player then warn("[LC] No LocalPlayer"); return end

local function dbg(...)
    if not DEBUG then return end
    local t = {"[LC]"} for i=1,select("#", ...) do t[#t+1] = tostring(select(i, ...)) end
    pcall(function() print(table.unpack(t)) end)
end

-- ---------- GUI helpers ----------
local function get_lightercyan_inset()
    local ok, base = pcall(function()
        if not CoreGui.TopBarApp then return nil end
        local t = CoreGui.TopBarApp.TopBarApp
        if not t then return nil end
        t = t.UnibarLeftFrame; if not t then return nil end
        t = t.HealthBar; if not t then return nil end
        t = t.ExperienceSettings; if not t then return nil end
        t = t["LighterCyan.ai"]; if not t then return nil end
        t = t.Holder; if not t then return nil end
        return t.InsetFrame
    end)
    if ok then return base end
    return nil
end

local function wait_for_gui(timeout)
    timeout = timeout or GUI_WAIT_TIMEOUT
    local t0 = tick()
    repeat
        local inset = get_lightercyan_inset()
        if inset then return inset end
        task.wait(0.06)
    until tick()-t0 > timeout
    return nil
end

local function find_scroll_frame()
    local inset = get_lightercyan_inset()
    if not inset then return nil end
    local chat = inset:FindFirstChild("a2_Chat")
    if not chat then
        for _,v in ipairs(inset:GetDescendants()) do
            if v.Name == "Chat" and v:IsA("ScrollingFrame") then chat = v; break end
        end
    end
    local scroll = chat and chat:FindFirstChild("Chat") or chat
    if scroll and scroll:IsA("ScrollingFrame") then return scroll end
    if chat and chat:IsA("ScrollingFrame") then return chat end
    return nil
end

local function update_canvas(scroll)
    if not scroll or not scroll:IsA("ScrollingFrame") then return end
    local layout = scroll:FindFirstChildOfClass("UIListLayout")
    if not layout then
        task.defer(function()
            local totalY = 0
            for _,c in ipairs(scroll:GetChildren()) do
                if c:IsA("Frame") then totalY = totalY + (c.AbsoluteSize.Y or MIN_HEIGHT) + 8 end
            end
            pcall(function() scroll.CanvasSize = UDim2.new(0,0,0, math.max(totalY, scroll.AbsoluteSize.Y or 0)) end)
        end)
        return
    end
    task.defer(function()
        local ok, size = pcall(function() return layout.AbsoluteContentSize end)
        if ok and size then
            pcall(function()
                scroll.CanvasSize = UDim2.new(0,0,0, math.max(size.Y + 8, scroll.AbsoluteSize.Y or 0))
                scroll.CanvasPosition = Vector2.new(0, math.max(0, size.Y - (scroll.AbsoluteSize.Y or 0)))
            end)
        end
    end)
end

-- ========== helpers: compute_text (fallback) ==========
local function compute_text_height(text, width, textSize, font)
    if not text then return MIN_HEIGHT end
    local size = Vector2.new(math.max(10, width or 200), math.huge)
    local ok, ts = pcall(function() return TextService:GetTextSize(tostring(text), textSize or 16, font or Enum.Font.SourceSans, size) end)
    if ok and ts then return math.max(MIN_HEIGHT, math.ceil(ts.Y) + 18) end
    return MIN_HEIGHT
end

-- ========== call wrappers ==========
local function call_ai(text, offset)
    local f = (type(ai)=="function" and ai) or (type(_G.ai)=="function" and _G.ai)
    if type(f)=="function" then pcall(f, text, offset or MIN_HEIGHT); update_canvas(find_scroll_frame()); return true end
    return false
end
local function call_plr(text, offset)
    local f = (type(plr)=="function" and plr) or (type(_G.plr)=="function" and _G.plr)
    if type(f)=="function" then pcall(f, text, offset or MIN_HEIGHT); update_canvas(find_scroll_frame()); return true end
    return false
end
local function call_mesg(text, offset, R,G,B,R1,G1,B1)
    local f = (type(mesg)=="function" and mesg) or (type(_G.mesg)=="function" and _G.mesg)
    if type(f)=="function" then pcall(f, text, offset or MIN_HEIGHT, R,G,B,R1,G1,B1); update_canvas(find_scroll_frame()); return true end
    return false
end

-- ========== fallback creators (use attach_auto_resize) ==========
local function fallback_create_frame(kind, text, offset, R,G,B,R1,G1,B1)
    local sc = find_scroll_frame() if not sc then return nil end
    local f = Instance.new("Frame"); f.Name = kind; f.BackgroundTransparency = 0.8; f.Parent = sc
    local icon = Instance.new("ImageLabel"); icon.Size = UDim2.new(0,50,0,50); icon.Position = UDim2.new(0,6,0,6); icon.BackgroundTransparency = 1; icon.Parent = f
    local lbl = Instance.new("TextLabel"); lbl.BackgroundTransparency = 1; lbl.TextWrapped = true; lbl.TextSize = 16; lbl.Font = Enum.Font.SourceSans; lbl.Parent = f
    if kind == "ai" then lbl.Name = "a2"; lbl.TextXAlignment = Enum.TextXAlignment.Left; icon.Name="a1"; icon.Image="rbxassetid://83032822916288"
    elseif kind == "plr" then lbl.Name = "a1"; lbl.TextXAlignment = Enum.TextXAlignment.Right; icon.Name="p1"; icon.Image="rbxassetid://135474395711579"
    else lbl.Name = "a1"; lbl.TextXAlignment = Enum.TextXAlignment.Center; icon.Name="m1" end
    lbl.Text = tostring(text or "")
    lbl.Size = UDim2.new(0.88, -8, 1, -12); lbl.Position = UDim2.new(0,56,0,6)
    if R and G and B then pcall(function() f.BackgroundColor3 = Color3.fromRGB(tonumber(R) or 255, tonumber(G) or 255, tonumber(B) or 255) end) end
    if R1 and G1 and B1 then pcall(function() lbl.TextColor3 = Color3.fromRGB(tonumber(R1) or 0, tonumber(G1) or 0, tonumber(B1) or 0) end) end
    -- attach autosize
    attach_auto_resize(f, lbl)
    return f
end

-- ========== find helpers ==========
local function find_last_frame_named(name)
    local sc = find_scroll_frame() if not sc then return nil end
    for i=#sc:GetChildren(),1,-1 do
        local c = sc:GetChildren()[i]
        if c and c:IsA("Frame") and c.Name == name then return c end
    end
    return nil
end

local function update_text_in_frame(frame, text)
    pcall(function()
        if not frame then return end
        local lbl
        for _,d in ipairs(frame:GetDescendants()) do if d:IsA("TextLabel") then lbl = d; break end end
        if not lbl then return end
        lbl.Text = tostring(text or "")
        -- ensure resize hooked (if not already)
        attach_auto_resize(frame, lbl)
    end)
end

-- ========== thinking handling ==========
local function get_or_create_thinking_frame(initialText)
    local existing = find_last_frame_named("ai")
    if existing then
        local foundLabel
        for _,d in ipairs(existing:GetDescendants()) do if d:IsA("TextLabel") then foundLabel=d; break end end
        if foundLabel and tostring(foundLabel.Text):match("^"..THINKING_BASE) then return existing end
    end
    if call_ai then
        pcall(call_ai, initialText or (THINKING_BASE.." (0s)"), MIN_HEIGHT)
        task.wait(0.06)
        local ex2 = find_last_frame_named("ai")
        if ex2 then return ex2 end
    end
    return fallback_create_frame("ai", initialText or (THINKING_BASE.." (0s)"), MIN_HEIGHT)
end

local function create_final_ai_frame(answer)
    if call_ai then
        pcall(call_ai, answer, MIN_HEIGHT)
        task.wait(0.04)
        local f = find_last_frame_named("ai")
        if f and f.Parent then return f end
    end
    return fallback_create_frame("ai", answer, MIN_HEIGHT)
end

-- ========== URL detect & fetch ==========
local ALLOWED_DOMAINS = {"youtube.com","youtu.be","en.help.roblox.com","create.roblox.com","x.com","chatgpt.com","chat.openai.com"}
local function detect_and_normalize_url(s)
    if not s then return nil end
    local text = tostring(s)
    for url in text:gmatch("https?://[%w%p]+") do return url end
    for _,dom in ipairs(ALLOWED_DOMAINS) do
        local pat = dom:gsub("%.", "%%.")
        local found = text:match("([%w%p]*"..pat.."[%w%p%/%%-]*)")
        if found then
            if not found:match("^https?://") then return "https://"..found end
            return found
        end
    end
    return nil
end

local function fetch_url(url)
    local ok, body = pcall(function() return HttpService:GetAsync(url, true) end)
    if ok and body and tostring(body) ~= "" then return true, body end
    ok, body = pcall(function() return game:HttpGet(url) end)
    if ok and body and tostring(body) ~= "" then return true, body end
    return false, body
end

local function show_error(msg)
    if call_mesg then pcall(call_mesg, msg, MIN_HEIGHT, 255,200,200, 255,50,50) else fallback_create_frame("message", msg, MIN_HEIGHT, 255,200,200, 255,50,50) end
end

-- ========== simple knowledge pipeline ==========
local function tokenize(s)
    if not s then return {} end
    s = tostring(s):lower()
    local t = {}
    for w in s:gmatch("[%w%p]+") do
        w = w:gsub("[%p]+",""):gsub("^%s+",""):gsub("%s+$","")
        if #w>0 then t[#t+1]=w end
    end
    return t
end
local function counts(list) local m={} for _,v in ipairs(list) do m[v]=(m[v] or 0)+1 end return m end
local function overlap(a,b)
    local ta, tb = tokenize(a), tokenize(b)
    if #ta==0 or #tb==0 then return 0 end
    local sa, sb = counts(ta), counts(tb)
    local match=0 for k,v in pairs(sa) do if sb[k] then match = match + math.min(v,sb[k]) end end
    local avg = (#ta + #tb)/2
    return match / math.max(1, avg)
end

local function compute_answer(input, context, fetched_text)
    local ok, pred = pcall(function()
        local fn = wait_for_bindable and wait_for_bindable("ai.Learning_Supervised_Predict")
        if fn and fn:IsA("BindableFunction") then return fn:Invoke(input) end
        return nil
    end)
    if ok and pred and tostring(pred)~="" then return tostring(pred) end

    if fetched_text and tostring(fetched_text) ~= "" then
        local txt = tostring(fetched_text)
        return "From fetched source: "..txt:sub(1,800)
    end

    local ok2, topics = pcall(function()
        local fn = wait_for_bindable and wait_for_bindable("ai.Unsupervised_GetTopics")
        if fn and fn:IsA("BindableFunction") then return fn:Invoke(5) end
        return nil
    end)
    if ok2 and topics and #topics>0 then return "Main topic: "..tostring(topics[1].w or topics[1]) end

    local ok3, examples = pcall(function()
        local fn = wait_for_bindable and wait_for_bindable("ai.DataStorage_Get")
        if fn and fn:IsA("BindableFunction") then return fn:Invoke() end
        return nil
    end)
    if ok3 and type(examples)=="table" and #examples>0 then
        local bestScore, bestText = 0, nil
        for _,ex in ipairs(examples) do
            local txt = tostring((type(ex)=="table" and (ex.text or ex)) or ex)
            local sc = overlap(input, txt)
            if sc > bestScore then bestScore = sc; bestText = txt end
        end
        if bestScore > 0.05 and bestText then
            return "Found related example (score "..string.format("%.2f", bestScore).."): "..bestText:sub(1,800)
        end
    end

    return nil
end

-- ========== jobs + debounce ==========
local currentJob = nil
local jobCounter = 0
local sendLock = false

local function cancel_current()
    if currentJob and currentJob.cancel then pcall(currentJob.cancel) end
    currentJob = nil
end

local function staged_status_loop(token, stages, base)
    local running = true; local idx = 1
    local frame = get_or_create_thinking_frame(base.." (0s)")
    local function settxt(t) pcall(function() update_text_in_frame(frame, t) end) end
    task.spawn(function()
        local start = tick()
        while running and not token.canceled do
            local s = math.floor(tick() - start)
            settxt(base.." ("..tostring(s).."s)")
            task.wait(1)
        end
    end)
    task.spawn(function()
        while running and not token.canceled do
            if stages[idx] then settxt(stages[idx]); idx = idx + 1 end
            for i=1,6 do if token.canceled then break end; task.wait(0.2) end
        end
    end)
    return { cancel = function() running=false; token.canceled=true end, frame = frame }
end

-- get_or_create_thinking_frame and update_text_in_frame are defined above and used here

function ThinkAsync(input, context)
    if not input then return end
    jobCounter = jobCounter + 1
    cancel_current()
    local token = { id = jobCounter, canceled = false }
    currentJob = { token = token, cancel = function() token.canceled = true end }

    local s = tostring(input)
    local url = detect_and_normalize_url(s)
    if url then
        local jobInfo = staged_status_loop(token, {"Searching URL...", "Getting Data...", "Readying..."}, THINKING_BASE)
        local ok, body = fetch_url(url)
        if not ok then
            if jobInfo and jobInfo.cancel then pcall(jobInfo.cancel) end
            show_error("ERROR fetching URL: "..tostring(body))
            currentJob=nil; return
        end
        pcall(function() local fn = wait_for_bindable and wait_for_bindable("ai.DataStorage_Add"); if fn and fn:IsA("BindableFunction") then fn:Invoke({text = tostring(body), source = url, time = os.time()}) end end)
        local answer = compute_answer(s, context, tostring(body)) or "No focused answer from fetched content."
        local final = create_final_ai_frame(answer)
        if jobInfo and jobInfo.frame then
            pcall(function()
                local lbl; for _,d in ipairs(jobInfo.frame:GetDescendants()) do if d:IsA("TextLabel") then lbl=d; break end end
                if lbl and tostring(lbl.Text):match("^"..THINKING_BASE) then pcall(function() jobInfo.frame:Destroy() end) end
            end)
            if jobInfo and jobInfo.cancel then pcall(jobInfo.cancel) end
        end
        currentJob=nil; return
    end

    local jobInfo = staged_status_loop(token, {"Analyzing...", "Searching memory...", "Preparing answer..."}, THINKING_BASE)
    task.spawn(function()
        local start = tick(); local maxWait = 30
        local result = compute_answer(s, context, nil)
        while not result and (tick()-start) < maxWait and not token.canceled do
            task.wait(0.12)
            result = compute_answer(s, context, nil)
        end
        if token.canceled then if jobInfo and jobInfo.cancel then pcall(jobInfo.cancel) end; currentJob=nil; return end
        if not result then
            update_text_in_frame(jobInfo.frame, "ERROR -1: TIMEOUT (overthinking)")
            if jobInfo and jobInfo.cancel then pcall(jobInfo.cancel) end
            currentJob=nil; return
        end
        local final = create_final_ai_frame(result)
        if jobInfo and jobInfo.frame then pcall(function() jobInfo.frame:Destroy() end) end
        if jobInfo and jobInfo.cancel then pcall(jobInfo.cancel) end
        currentJob=nil
    end)
end

-- ========== GUI hooks ==========
local function safe_connect(btn, fn)
    if not btn then return end
    pcall(function()
        if typeof(btn.MouseButton1Click) == "RBXScriptSignal" then btn.MouseButton1Click:Connect(fn)
        elseif btn:IsA("TextButton") then btn.Activated:Connect(fn) end
    end)
end

local function read_latest_label_text(scroll)
    if not scroll then return "" end
    for i=#scroll:GetChildren(),1,-1 do
        local c = scroll:GetChildren()[i]
        for _,d in ipairs(c:GetDescendants()) do
            if d:IsA("TextLabel") then return tostring(d.Text) end
        end
    end
    return ""
end

local function hook_gui_handlers()
    local inset = wait_for_gui(GUI_WAIT_TIMEOUT)
    if not inset then warn("[LC] GUI not found"); return false end
    local inputFrame = inset:FindFirstChild("a3_Input&Send")
    if not inputFrame then
        for _,v in ipairs(inset:GetDescendants()) do if v.Name=="a3_Input&Send" and v:IsA("Frame") then inputFrame=v; break end end
    end
    if not inputFrame then warn("[LC] input frame missing"); return false end

    local AskBox = inputFrame:FindFirstChild("Ask")
    local SendBtn = inputFrame:FindFirstChild("Send")
    local ClearBtn = inputFrame:FindFirstChild("clear") or inputFrame:FindFirstChild("Clear")
    local RecBtn = inputFrame:FindFirstChild("re-chat") or inputFrame:FindFirstChild("rec")

    safe_connect(SendBtn, function()
        if sendLock then return end
        sendLock = true
        task.spawn(function()
            local txt = ""
            pcall(function() if AskBox and AskBox:IsA("TextBox") then txt = AskBox.Text end end)
            if not (txt and tostring(txt):match("%S")) then sendLock=false; return end
            local plrok = false
            pcall(function() plrok = call_plr(txt, MIN_HEIGHT) end)
            if not plrok then fallback_create_frame("plr", txt, MIN_HEIGHT) end
            pcall(function() if type(ThinkAsync)=="function" then ThinkAsync(txt, read_latest_label_text(find_scroll_frame())) end end)
            pcall(function() if AskBox and AskBox:IsA("TextBox") then AskBox.Text = "" end end)
            task.wait(0.5)
            sendLock = false
        end)
    end)

    safe_connect(ClearBtn, function()
        pcall(function() if AskBox and AskBox:IsA("TextBox") then AskBox.Text = "" end end)
    end)

    safe_connect(RecBtn, function()
        local sc = find_scroll_frame()
        if not sc then return end
        pcall(function()
            for _,c in ipairs(sc:GetChildren()) do
                if c:IsA("Frame") then
                    local nm = tostring(c.Name or "")
                    if nm == "ai" or nm == "plr" or nm == "message" then
                        pcall(function() c:Destroy() end)
                    end
                end
            end
        end)
        update_canvas(sc)
    end)

    if AskBox and AskBox:IsA("TextBox") then
        pcall(function()
            AskBox.FocusLost:Connect(function(enter)
                if not enter then return end
                if sendLock then return end
                sendLock = true
                local t = ""
                pcall(function() t = AskBox.Text or "" end)
                if not (t and tostring(t):match("%S")) then sendLock=false; return end
                local plrok = false
                pcall(function() plrok = call_plr(t, MIN_HEIGHT) end)
                if not plrok then fallback_create_frame("plr", t, MIN_HEIGHT) end
                if type(ThinkAsync)=="function" then pcall(ThinkAsync, t, read_latest_label_text(find_scroll_frame())) end
                pcall(function() AskBox.Text = "" end)
                task.delay(0.5, function() sendLock = false end)
            end)
        end)
    end

    dbg("GUI hooks installed")
    return true
end

-- warm DataStorage bindable
pcall(function() if wait_for_bindable then wait_for_bindable("ai.DataStorage_Get") end end)

-- re-hook loop
task.spawn(function()
    while task.wait(2) do
        local inset = get_lightercyan_inset()
        if inset then hook_gui_handlers(); task.wait(4) end
    end
end)

print("[LC.Controller final + autosize] Ready")
