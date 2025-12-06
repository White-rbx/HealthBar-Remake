-- Version 1.47

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
local TweenService = game:GetService("TweenService")

local function BindAutoResize(obj, padding, charWidth)
	padding = padding or 20
	charWidth = charWidth or 7 -- ความกว้างเฉลี่ยตัวอักษร

	local lastLength = 0
	local tween = nil

	local function update()
		local text = obj.Text or ""
		local len = #text

		-- ไม่เปลี่ยน → ไม่ต้องทำอะไร
		if len == lastLength then return end
		lastLength = len

		-- คำนวณความกว้างใหม่
		local targetWidth = (len * charWidth) + padding

		-- กันเล็กเกิน
		if targetWidth < 150 then
			targetWidth = 150
		end

		-- ยกเลิก tween ก่อนหน้า
		if tween then
			tween:Cancel()
		end

		tween = TweenService:Create(
			obj,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = UDim2.new(
					0,
					targetWidth,
					0,
					obj.AbsoluteSize.Y > 0 and obj.AbsoluteSize.Y or 30
				)
			}
		)

		tween:Play()
	end

	-- Run หลังสร้าง
	update()

	-- TextBox = real-time update
	obj:GetPropertyChangedSignal("Text"):Connect(update)
end

local HolderScreen = game:GetService("CoreGui").ExperienceSettings.Menu.HolderScreen

local notiF = Instance.new("CanvasGroup")
notiF.Name = "NotificationFrame"
notiF.Size = UDim2.new(1,0,0.3,0)
notiF.Transparency = 1
notiF.Active = false
notiF.Parent = HolderScreen
createUIListLayout(notiF, 0, 3, HRight, VTop, SLayout, FillV)

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
	local r, g, b = rbxT:match("(%d+),(%d+),(%d+)")
	r, g, b = tonumber(r), tonumber(g), tonumber(b)

	local text = Instance.new("TextLabel")
	text.Name = "textnoti"
	text.Size = UDim2.new(0, 0, 0, 30)
	text.BackgroundColor3 = Color3.fromRGB(r, g, b)
	text.BackgroundTransparency = 0.08
	text.Text = tostring(icon) .. tostring(textValue)
	text.TextColor3 = Color3.fromRGB(255,255,255)
	text.Parent = notiF
	
	Corner(1,0,text)

	BindAutoResize(text, 30)

	-- 10 วิ แล้วหาย
	task.delay(10, function()
		text.Text = ""

		TweenService:Create(text,
			TweenInfo.new(0.25),
			{Size = UDim2.new(0,0,0,30)}
		):Play()

		task.wait(0.25)
		text:Destroy()
	end)

	return text
end

local function addsendnoti(textValue)
	local r, g, b = rbxT:match("(%d+),(%d+),(%d+)")
	r, g, b = tonumber(r), tonumber(g), tonumber(b)

	local input = Instance.new("TextBox")
	input.Name = "sendnoti"
	input.Size = UDim2.new(0, 150, 0, 30)
	input.BackgroundColor3 = Color3.fromRGB(r, g, b)
	input.BackgroundTransparency = 0.08
	input.Text = textValue or ""
	input.PlaceholderText = "Type anything..."
	input.TextColor3 = Color3.fromRGB(255,255,255)
	input.ClearTextOnFocus = false
	input.TextXAlignment = Enum.TextXAlignment.Left
	input.RichText = false
	input.AutomaticSize = Enum.AutomaticSize.X
	input.Parent = notiF

	Corner(1,0,input)

	local btn = Instance.new("TextButton")
	btn.Name = "send"
	btn.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
	btn.Text = "Send"
	btn.Size = UDim2.new(0,50,0,27)
	btn.Position = UDim2.new(1,-52,0,2)
	btn.Parent = input
	Corner(1,0,btn)

	BindAutoResize(input, 5)

	btn.MouseButton1Click:Connect(function()
		input.Text = ""

		TweenService:Create(input,
			TweenInfo.new(0.25),
			{Size = UDim2.new(0,0,0,30)}
		):Play()

		task.wait(0.25)
		input:Destroy()
	end)

	return input, btn
end

local function addqusnoti(icon, textValue)
	local r, g, b = rbxT:match("(%d+),(%d+),(%d+)")
	r, g, b = tonumber(r), tonumber(g), tonumber(b)

	local box = Instance.new("TextLabel")
	box.Name = "qusnoti"
	box.Size = UDim2.new(0,0,0,30)
	box.BackgroundColor3 = Color3.fromRGB(r,g,b)
	box.BackgroundTransparency = 0.08
	box.TextColor3 = Color3.new(1,1,1)
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.Text = tostring(icon) .. tostring(textValue)
	box.Parent = notiF
	Corner(1,0,box)

	local cancel = Instance.new("TextButton")
	cancel.Size = UDim2.new(0,50,0,27)
	cancel.Position = UDim2.new(1,-52,0,2)
	cancel.Text = "Cancel"
	cancel.BackgroundColor3 = Color3.fromRGB(255,0,0)
	cancel.TextColor3 = Color3.new(1,1,1)
	cancel.Parent = box
	Corner(1,0,cancel)

	local agree = Instance.new("TextButton")
	agree.Size = UDim2.new(0,50,0,27)
	agree.Position = UDim2.new(1,-103,0,2)
	agree.Text = "Agree"
	agree.BackgroundColor3 = Color3.fromRGB(0,255,0)
	agree.TextColor3 = Color3.new(1,1,1)
	agree.Parent = box
	Corner(1,0,agree)

	BindAutoResize(box, 120)

	local function close()
		box.Text = ""

		TweenService:Create(box,
			TweenInfo.new(0.25),
			{Size = UDim2.new(0,0,0,30)}
		):Play()

		task.wait(0.25)
		box:Destroy()
	end

	cancel.MouseButton1Click:Connect(close)
	agree.MouseButton1Click:Connect(close)

	return box, cancel, agree
end
--====== END FUNCTIONS ========--
-- ===== Notification detectors (BadWord removed) =====
-- Put this AFTER: --====== END FUNCTIONS ========--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local plr = Players.LocalPlayer

-- defensive voice service handling (API varies by client/updates)
local VoiceService = nil
pcall(function()
    VoiceService = game:GetService("VoiceChatService")
end)

-- default icons (if not defined earlier)
vc     = vc     or "🎙️: "
tpps   = tpps   or "🏙️: "
warn   = warn   or "⚠️: "
cross  = cross  or "❌: "
int    = int    or "🛜: "
sle    = sle    or "💤: "
gre    = gre    or "🟢: "
warn2  = warn2  or "❗: "

local Detectors = {}

local function safeAddText(icon, text)
    if type(addtextnoti) == "function" then
        pcall(addtextnoti, icon, text)
    else
        warn("addtextnoti not found")
    end
end

local function safeAddSend(initial)
    if type(addsendnoti) == "function" then
        local ok, input, btn = pcall(addsendnoti, initial)
        if ok then return input, btn end
    else
        warn("addsendnoti not found")
    end
    return nil
end

local function safeAddQ(icon, text)
    if type(addqusnoti) == "function" then
        pcall(addqusnoti, icon, text)
    else
        warn("addqusnoti not found")
    end
end

-- Voice Detector
Detectors.Voice = {}
function Detectors.Voice.Start(opts)
    opts = opts or {}
    local threshold = opts.threshold or 0.27
    local debounce = opts.debounce or 3

    if not VoiceService then
        warn("Voice service unavailable on this client; Voice.Detector disabled.")
        return
    end

    local last = 0
    Detectors.Voice._running = true
    task.spawn(function()
        while Detectors.Voice._running do
            task.wait(0.12)
            local ok, level = pcall(function()
                if VoiceService.GetVoiceIndicator then
                    return VoiceService:GetVoiceIndicator(plr)
                elseif VoiceService.GetVoiceLevel then
                    return VoiceService:GetVoiceLevel(plr.UserId)
                else
                    return nil
                end
            end)

            if ok and type(level) == "number" and level > threshold then
                if tick() - last > debounce then
                    last = tick()
                    safeAddText(vc, "Voice detected (" .. tostring(math.floor(level * 100)) .. "%)")
                end
            end
        end
    end)
end
function Detectors.Voice.Stop() Detectors.Voice._running = false end

-- Teleport helper
Detectors.Teleport = {}
function Detectors.Teleport.NotifyHeading(placeId)
    safeAddText(tpps, 'You\'re heading to "' .. tostring(placeId) .. '"')
end

-- ToS / Spam Detector (keeps invite/links + spam detection)
Detectors.ToS = {}
Detectors.ToS._inviteKeywords = {
    "discord","dc","disc","discorn","ip",".com",".xyz",".org",".onion",".io","web",
    ".gg",".shop",".net","http","https","giveaway","want admin","want free","free robux","free robu"
}
Detectors.ToS._recentMsgs = {}
Detectors.ToS._window = 5
Detectors.ToS._limitCount = 5

function Detectors.ToS.OnLocalChat(msg)
    if not msg or msg == "" then return false end
    local lower = string.lower(msg)

    for _, kw in ipairs(Detectors.ToS._inviteKeywords) do
        if string.find(lower, kw, 1, true) then
            safeAddText(warn, "You have break the Terms of Service | Reason: Invitation/Link: " .. tostring(kw))
            return true
        end
    end

    local now = tick()
    table.insert(Detectors.ToS._recentMsgs, {t=now, m=msg})
    for i = #Detectors.ToS._recentMsgs, 1, -1 do
        if now - Detectors.ToS._recentMsgs[i].t > Detectors.ToS._window then
            table.remove(Detectors.ToS._recentMsgs, i)
        end
    end

    if #Detectors.ToS._recentMsgs >= Detectors.ToS._limitCount then
        safeAddText(warn, "You have break the Terms of Service | Reason: Spamming Chat")
        Detectors.ToS._recentMsgs = {}
        return true
    end

    return false
end

-- Internet status
Detectors.Internet = {}
Detectors.Internet._lastStatus = nil
function Detectors.Internet.SetStatus(status)
    if status == Detectors.Internet._lastStatus then return end
    Detectors.Internet._lastStatus = status
    if status == "disconnected" then
        safeAddText(int, "Internet Disconnected. Please re-connect or check and try again.")
    elseif status == "connected" then
        safeAddText(int, "Internet Connected")
    elseif status == "low" then
        safeAddText(int, "Low internet detected, please check your connection")
    else
        safeAddText(int, tostring(status))
    end
end

-- AFK detector
Detectors.AFK = {}
function Detectors.AFK.Start()
    if Detectors.AFK._running then return end
    Detectors.AFK._running = true

    local lastActivity = tick()
    local notified = { t2=false, t10=false, t15=false, t18=false }
    local thresholds = { t2=2*60, t10=10*60, t15=15*60, t18=18*60 }

    local function markActivity()
        lastActivity = tick()
        if notified.t2 or notified.t10 or notified.t15 or notified.t18 then
            local msgs = {
                "Are you farming?",
                "Are you eating dinner?",
                "Are you sleeping?",
                "Are you playing another game?",
                "Are you bored?",
                "Are you still alive?",
                "Are you tired?"
            }
            safeAddText(gre, "You are now no longer AFK. " .. msgs[math.random(1,#msgs)])
        end
        notified.t2=false; notified.t10=false; notified.t15=false; notified.t18=false
    end

    UserInputService.InputBegan:Connect(markActivity)
    UserInputService.InputChanged:Connect(markActivity)
    UserInputService.InputEnded:Connect(markActivity)

    task.spawn(function()
        while Detectors.AFK._running and plr and plr.Parent do
            local char = plr.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local lastPos = root.Position
                    while char and char.Parent and Detectors.AFK._running do
                        task.wait(1)
                        local nowPos = root.Position
                        if (nowPos - lastPos).Magnitude > 0.5 then
                            markActivity()
                        end
                        lastPos = nowPos
                    end
                end
            end
            task.wait(1)
        end
    end)

    task.spawn(function()
        while Detectors.AFK._running do
            local diff = tick() - lastActivity
            if diff >= thresholds.t2 and not notified.t2 then
                safeAddText(sle, "You are now AFK (2m ago)")
                notified.t2 = true
            end
            if diff >= thresholds.t10 and not notified.t10 then
                safeAddText(sle, "You being AFK 10 minutes now, come back before too late.")
                notified.t10 = true
            end
            if diff >= thresholds.t15 and not notified.t15 then
                safeAddText(sle, "You being AFK 15 minutes now, please come back before too late.")
                notified.t15 = true
            end
            if diff >= thresholds.t18 and not notified.t18 then
                safeAddText(sle, "You being AFK 18 minutes now, please come back before too late.")
                notified.t18 = true
            end
            task.wait(5)
        end
    end)
end
function Detectors.AFK.Stop() Detectors.AFK._running = false end

-- Hook for local chat: now only runs ToS/spam checks
function Detectors.OnLocalChat(msg)
    if not msg then return false end
    local tos = Detectors.ToS.OnLocalChat(msg) or false
    return tos
end

-- Init
function Detectors.Init(opts)
    opts = opts or {}
    if opts.voice ~= false then pcall(function() Detectors.Voice.Start({ threshold = opts.voiceThreshold or 0.27, debounce = opts.voiceDebounce or 3 }) end) end
    if opts.afk ~= false then pcall(function() Detectors.AFK.Start() end) end
    return Detectors
end

-- Example usage (remove/comment in production):
-- Detectors.Init({ voice = true, afk = true })
-- Detectors.Teleport.NotifyHeading("PLACE_ID_1234567890")
-- safeAddText(warn, "Test ToS warning")
