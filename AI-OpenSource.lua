-- gpt 3.656

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

--====== CLIENT SERVICES ======--

-- UI / Player Interface
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

-- Audio / Feedback
local SoundService = game:GetService("SoundService")

-- Commerce / Monetization
local MarketplaceService = game:GetService("MarketplaceService")

-- Runtime / Frame Updates
local RunService = game:GetService("RunService")

-- Animation / Transitions
local TweenService = game:GetService("TweenService")

-- Input (Desktop / Mobile)
local UserInputService = game:GetService("UserInputService")
local TouchInputService = game:GetService("TouchInputService")

--================================--
local Menu = CoreGui:WaitForChild("ExperienceSettings").Menu
local gpt = Menu.ChatGPT

gpt.Line:Destroy()
gpt.Disconnected:Destroy()
gpt.error:Destroy()
gpt.warn:Destroy()

gpt.Position = UDim2.new(0.25,0,1,0)
gpt.Size = UDim2.new(0.5,0,0.7,0)
gpt.Name = "AIOpenSource"
gpt.BackgroundTransparency = 0.3

-- frame
local ins = Instance.new("Frame")
ins.Position = UDim2.new(0.02,0,0.02,0)
ins.Size = UDim2.new(0.96,0,0.96,0)
ins.BackgroundTransparency = 1
ins.Active = false
ins.Parent = gpt

-- text
local t = Instance.new("Frame")
t.Name = "Text"
t.Position = UDim2.new(0,0,1,-40)
t.Size = UDim2.new(1,0,0,40)
t.BackgroundTransparency = 0.8
t.BackgroundColor3 = Color3.fromRGB(255,255,255)
t.Active = false
t.Parent = ins
Corner(1, 0, t)
Stroke(t, ASMBorder, 255, 255, 255, LJMRound, 1, 0)

-- TextLabel
local tl = Instance.new("TextLabel")
tl.Name = "Topic"
tl.Size = UDim2.new(0.2,0,0.1,0)
tl.BackgroundTransparency = 1
tl.Active = false
tl.Text = "AI-OpenSource"
tl.TextColor3 = Color3.fromRGB(255,255,255)
tl.TextScaled = true
tl.Parent = ins

-- TextLabel2
local tl2 = Instance.new("TextLabel")
tl2.Name = "ver"
tl2.Position = UDim2.new(0,0,0.07,0)
tl2.Size = UDim2.new(0.2,0,0.03,0)
tl2.BackgroundTransparency = 1
tl2.Active = false
tl2.Text = "Version: TEST"
tl2.TextXAlignment = Enum.TextXAlignment.Left
tl2.TextColor3 = Color3.fromRGB(255,255,255)
tl2.TextScaled = true
tl2.Parent = ins


-- line
local lin = Instance.new("Frame")
lin.Name = "Line"
lin.Position = UDim2.new(0.22,0,0,0)
lin.Size = UDim2.new(0,0,0.1,0)
lin.BackgroundColor3 = Color3.fromRGB(255,255,255)
lin.BorderColor3 = Color3.fromRGB(255,255,255)
lin.Active = false
lin.Parent = ins

-- textbox
local tb = Instance.new("TextBox")
tb.Name = "api"
tb.Position = UDim2.new(0.23,0,0,0)
tb.Size = UDim2.new(0.3,0,0.1,0)
tb.BackgroundTransparency = 1
tb.TextColor3 = Color3.fromRGB(255,255,255)
tb.PlaceholderText = "[ Your API here (ChatGPT or Gemini) ]"
tb.Text = ""
tb.RichText = true
tb.TextScaled = true
tb.TextSize = 16
tb.TextXAlignment = Enum.TextXAlignment.Left
tb.Parent = ins

-- Textbutton
local con = Instance.new("TextButton")
con.Name = "Confirm_api"
con.Position = UDim2.new(0.55,0,0,0)
con.Size = UDim2.new(0.1,0,0.1,0)
con.BackgroundTransparency = 1
con.TextColor3 = Color3.fromRGB(0,255,0)
con.TextScaled = true
con.Text = "Confirm API"
con.Parent = ins
Corner(0, 8, con)
Stroke(con, ASMBorder, 0, 255, 0, LJMRound, 1, 0)

-- Textbutton2
local con2 = Instance.new("TextButton")
con2.Name = "Unsaved_API"
con2.Position = UDim2.new(0.66,0,0,0)
con2.Size = UDim2.new(0.1,0,0.1,0)
con2.BackgroundTransparency = 1
con2.TextColor3 = Color3.fromRGB(255,0,0)
con2.TextScaled = true
con2.Text = "Unsaved API"
con2.Parent = ins
Corner(0, 8, con2)
Stroke(con2, ASMBorder, 255, 0, 0, LJMRound, 1, 0)

-- status
local st = Instance.new("TextLabel")
st.Name = "Status"
st.Position = UDim2.new(0.77,0,0,0)
st.Size = UDim2.new(0.23,0,0.1,0)
st.BackgroundTransparency = 1
st.Text = "Status: No key"
st.TextColor3 = Color3.fromRGB(255,255,255)
st.TextScaled = true
st.Active = false
st.Parent = ins
Corner(0, 8, st)
Stroke(st, ASMBorder, 255, 255, 255, LJMRound, 1, 0)

-- chat
local ch = Instance.new("TextBox")
ch.Name = "chat"
ch.Position = UDim2.new(0.02,0,0.02,0)
ch.Size = UDim2.new(0.8,0,0.96,0)
ch.BackgroundTransparency = 1
ch.TextColor3 = Color3.fromRGB(255,255,255)
ch.RichText = true
ch.Text = ""
ch.PlaceholderText = "Type /Help or Say something..."
ch.TextSize = 16
ch.TextWrap = true
ch.TextWrapped = true
ch.TextXAlignment = Enum.TextXAlignment.Left
ch.ClearTextOnFocus = false
ch.MultiLine = true
ch.Parent = t

-- send
local se = Instance.new("TextButton")
se.Name = "Send"
se.Position = UDim2.new(0.932,0,0.08,0)
se.Size = UDim2.new(0,35,0,35)
se.Text = "→"
se.TextScaled = true
se.TextColor3 = Color3.fromRGB(255,255,255)
se.BackgroundTransparency = 1
se.Parent = t

-- ScrollingFrame 
local si = Instance.new("ScrollingFrame")
si.Name = "ChatLogs"
si.Position = UDim2.new(0,0,0.13,0)
si.Size = UDim2.new(1,0,0.75,0)
si.BackgroundTransparency = 1
si.ScrollingDirection = Enum.ScrollingDirection.Y
si.AutomaticCanvasSize = Enum.AutomaticSize.Y
si.CanvasSize = UDim2.new(0,0,0,0)
si.Parent = ins
ListLayout(si, 0, 3, HLeft, VTop, SLayout, FillV)

--[[
Note
 Player color is White
 ChatGPT color is lime

Example
 txt(user.plr, "", 255,255,255) -- White
 txt(user.chat, "", 85,255,255) -- Cyan
 txt(user.Error, "", 255,0,0) -- Red
 txt(user.Suc, "", 0,255,0) -- Lime
 txt(user.Warn, "", 255,255,0) -- Yellow
 txt(user.Info, "", 0,170,255) -- Light blue
 txt(user.Nill, "", 180,180,180) -- Gray
 txt(user.Sys, "", 255, 90, 0) -- Orange
]]

-- functions
local user = {
    plr  = "You: ",
    chat = "AI: ",
    Error = "Error: ",
    Suc   = "Success: ",
    Warn  = "Warning: ",
    Info  = "Information: ",
    Nill = "",
    Sys = "System: "
}

-- ChatLogs Line
local function txt(user, text, R, G, B)
    local cha = Instance.new("TextLabel")
    cha.Name = "Text"
    cha.Size = UDim2.new(0.97, 0, 0, 30) -- default height (ปรับภายหลังได้)
    cha.TextColor3 = Color3.fromRGB(R or 255, G or 255, B or 255)
    cha.BackgroundTransparency = 1
    cha.Text = tostring(user) .. tostring(text)
    cha.TextSize = 16
    cha.RichText = true
    cha.TextWrapped = true
    cha.TextXAlignment = Enum.TextXAlignment.Left
    cha.TextYAlignment = Enum.TextYAlignment.Top
    cha.AutomaticSize = Enum.AutomaticSize.Y
    cha.Parent = si

    return cha
end

--[[
 txt(user.plr, "Hello, World!", 255,255,255) -- White
 txt(user.chat, "Hello, World!", 85,255,255) -- Cyan
 txt(user.Error, "Hello, World!", 255,0,0) -- Red
 txt(user.Suc, "Hello, World!", 0,255,0) -- Lime
 txt(user.Warn, "Hello, World!", 255,255,0) -- Yellow
 txt(user.Info, "Hello, World!", 0,170,255) -- Light blue
 txt(user.Nill, "Hello, World!", 180,180,180) -- Gray
 txt(user.Sys, "Hello, World!*, 255, 90, 0) -- Orange 
]]

txt(user.Nill, "Nothing is working! Please wait for the next update!", 180,180,180)
txt(user.Nill, "Version: Test 3.656 | © Copyright LighterCyan", 180, 180, 180)
txt(user.Warn, "Stop! For your safety, please do not share your API and avoid being stared at by people around you. Due to safety and privacy concerns, you confirm that you will use your API to continue using our AI-OpenSource or not? With respect.", 255,255,0)
txt(user.Info, "Use /help for more information or commands (SOON)", 0,170,255)
txt(user.Nill, "[====== Chat ======]", 180, 180, 180)

----------------------------------------------------------------
-- EXECUTOR HTTP WRAPPER
----------------------------------------------------------------
local http = (syn and syn.request)
          or (http_request)
          or (request)

if not http then
    txt(user.Error, "Executor HTTP not found", 255,0,0)
    return
end

local jsonEncode = function(t) return game:GetService("HttpService"):JSONEncode(t) end
local jsonDecode = function(s) return game:GetService("HttpService"):JSONDecode(s) end

----------------------------------------------------------------
-- STATE
----------------------------------------------------------------
local API_KEY = nil
local PROVIDER = nil -- "chatgpt" | "gemini"
local BUSY = false
local LAST_REQUEST = 0
local RATE_LIMIT_UNTIL = 0

----------------------------------------------------------------
-- STATUS HELPER
----------------------------------------------------------------
local function setStatus(text)
    st.Text = "Status: " .. text
end

----------------------------------------------------------------
-- KEY DETECTION
----------------------------------------------------------------
local function detectProvider(key)
    if type(key) ~= "string" or key == "" then
        return nil
    end
    if key:sub(1,7) == "sk-proj" or key:sub(1,3) == "sk-" then
        return "chatgpt"
    end
    if key:sub(1,6) == "AIzaSy" then
        return "gemini"
    end
    return nil
end

----------------------------------------------------------------
-- SEND REQUEST (SINGLE STEP, NO PRE-VALIDATION)
----------------------------------------------------------------
local function sendRequest(prompt)
    if BUSY then return end
    if not API_KEY or not PROVIDER then
        txt(user.Warn, "No API connected", 255,255,0)
        return
    end

    local now = os.time()
    if now < RATE_LIMIT_UNTIL then
        setStatus("Rate-limited. Retry in "..(RATE_LIMIT_UNTIL-now).."s")
        return
    end

    BUSY = true
    setStatus("Connecting API "..string.upper(PROVIDER))

    local req
    if PROVIDER == "chatgpt" then
        req = {
            Url = "https://api.openai.com/v1/responses",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer "..API_KEY
            },
            Body = jsonEncode({
                model = "gpt-4o-mini",
                input = prompt
            })
        }
    else -- gemini
        req = {
            Url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["x-goog-api-key"] = API_KEY
            },
            Body = jsonEncode({
                contents = {
                    {
                        parts = {
                            { text = prompt }
                        }
                    }
                }
            })
        }
    end

    local res = http(req)
    BUSY = false

    if not res then
        setStatus("Invalid response")
        return
    end

    if res.StatusCode == 429 then
        RATE_LIMIT_UNTIL = os.time() + 20
        setStatus("Rate-limited. Retry in 20s")
        return
    end

    if res.StatusCode >= 400 then
        txt(user.Error, "HTTP "..res.StatusCode, 255,0,0)
        setStatus("Invalid key")
        return
    end

    local ok, data = pcall(jsonDecode, res.Body)
    if not ok then
        txt(user.Error, "Decode failed", 255,0,0)
        return
    end

    local reply = "(no text)"
    if PROVIDER == "chatgpt" then
        if data.output and data.output[1] and data.output[1].content then
            reply = data.output[1].content[1].text or reply
        end
    else
        if data.candidates and data.candidates[1]
        and data.candidates[1].content
        and data.candidates[1].content.parts then
            reply = data.candidates[1].content.parts[1].text or reply
        end
    end

    txt(user.chat, reply, 85,255,255)
    setStatus("Connected (Successful connected)")
end

----------------------------------------------------------------
-- CONFIRM API
----------------------------------------------------------------
con.MouseButton1Click:Connect(function()
    local key = tb.Text
    if key == "" then
        setStatus("No key")
        return
    end

    local provider = detectProvider(key)
    if not provider then
        setStatus("Invalid key")
        return
    end

    API_KEY = key
    PROVIDER = provider

    if provider == "chatgpt" then
        setStatus("ChatGPT Key detected")
    else
        setStatus("Gemini Key detected")
    end

    task.delay(0.2, function()
        setStatus("Connecting API "..string.upper(provider))
    end)
end)

----------------------------------------------------------------
-- UNSAVE API
----------------------------------------------------------------
con2.MouseButton1Click:Connect(function()
    API_KEY = nil
    PROVIDER = nil
    setStatus("Unsave key")
end)

----------------------------------------------------------------
-- SEND BUTTON / CHAT LINK
----------------------------------------------------------------
local function sendChat()
    local text = ch.Text
    if text == "" then return end

    txt(user.plr, text, 255,255,255)
    ch.Text = "" -- ✅ FIX: clear textbox
    sendRequest(text)
end

se.MouseButton1Click:Connect(sendChat)

ch.FocusLost:Connect(function(enter)
    if enter then
        sendChat()
    end
end)

----------------------------------------------------------------
-- INIT
----------------------------------------------------------------
setStatus("No key")




-- ===============================
-- COMMAND SYSTEM
-- ===============================

local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function split(str)
    local t = {}
    for w in str:gmatch("%S+") do
        table.insert(t, w)
    end
    return t
end

-- ===== HELP TEXT =====
local HELP_TEXT = [[
/Help
"Show all commands"

/Calculate or /Cal [MATH]
"
Example:
/cal 29 / 2
/cal 4^2
/cal (18 + 2) * 3
"
/ClearText
"Delete all messages in ChatLogs"

/AddAPI [AI_NAME] [API] [CONFIRM]
"
Example:
/addapi gemini AIza**** yes
/addapi chatgpt sk_proj**** no
"

/UnsaveAPI
"Disable API"

/OpenWebsiteInExperience [URL]
"Open website in Roblox"

/loadstring [URL]
"execute loadstring"

/Script [CODE] -- please add "[]" more
"write script"
]]

-- ===== CLEAR CHAT =====
local function clearChat()
    for _, v in ipairs(si:GetChildren()) do
        if v:IsA("TextLabel") then
            v:Destroy()
        end
    end
end

-- ===== CALCULATOR (SAFE) =====
local function calculate(expr)
    expr = expr:gsub("%^", "^")
    local f = loadstring("return " .. expr)
    if not f then
        return nil, "invalid math expression"
    end
    local ok, res = pcall(f)
    if not ok then
        return nil, res
    end
    return res
end

-- ===== COMMAND HANDLER =====
local function handleCommand(raw)
    local text = trim(raw)
    local args = split(text)
    local cmd = args[1]:lower()

    -- /help
    if cmd == "/help" then
        txt(user.Sys, "Available Commands:", 255, 90, 0)
        for line in HELP_TEXT:gmatch("[^\n]+") do
            txt(user.Nill, line, 180,180,180)
        end
        return true
    end

    -- /cleartext
    if cmd == "/cleartext" then
        clearChat()
        txt(user.Suc, "Chat cleared", 0,255,0)
        return true
    end

    -- /cal
    if cmd == "/cal" or cmd == "/calculate" then
        local expr = text:sub(#args[1] + 2)
        local res, err = calculate(expr)
        if not res then
            txt(user.Error, "Math error: ".. tostring(err), 255,0,0)
        else
            txt(user.Suc, "Result = ".. tostring(res), 0,255,0)
        end
        return true
    end

    -- /addapi
    if cmd == "/addapi" then
        txt(user.Sys, "API detected (stub mode)", 255, 90, 0)
        txt(user.Warn, "Validation skipped (executor logic required)", 255,255,0)
        return true
    end

    -- /unsaveapi
    if cmd == "/unsaveapi" or cmd == "/unapi" then
        txt(user.Sys, "API unsaved", 255, 90, 0)
        return true
    end

    return false
end

-- ===============================
-- SEND BUTTON + CHAT LINK
-- ===============================

local function onSend()
    local message = trim(ch.Text)
    if message == "" then return end

    ch.Text = "" -- clear textbox

    -- command?
    if message:sub(1,1) == "/" then
        local handled = handleCommand(message)
        if not handled then
            txt(user.Error, "Unknown command. Type /help", 255,0,0)
        end
        return
    end

    -- normal chat (AI stub)
    txt(user.plr, message, 255,255,255)
    txt(user.chat, "(AI not connected)", 85,255,255)
end

-- Button click
se.MouseButton1Click:Connect(onSend)

-- Enter key
ch.FocusLost:Connect(function(enter)
    if enter then
        onSend()
    end
end)


-- ===============================
-- COMMAND SYSTEM (TAIL SCRIPT)
-- ===============================

-- helper: trim
local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- helper: clear chat TextBox
local function clearInput()
    ch.Text = ""
end

-- helper: clear TextLabels in ChatLogs
local function clearChatLogs()
    for _, v in ipairs(si:GetChildren()) do
        if v:IsA("TextLabel") then
            v:Destroy()
        end
    end
end

-- ===============================
-- COMMAND HANDLERS
-- ===============================

local Commands = {}

-- /loadstring [URL]
Commands.loadstring = function(args)
    local url = trim(args)

    if url == "" then
        txt(user.Error, "Usage: /loadstring [URL]", 255, 0, 0)
        return
    end

    txt(user.Sys, "Loading script from URL...", 255, 90, 0)

    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)

    if ok then
        txt(user.Suc, "loadstring executed successfully", 0, 255, 0)
    else
        txt(user.Error, "loadstring failed: " .. tostring(result), 255, 0, 0)
    end
end

-- alias
Commands.ls = Commands.loadstring

-- /script [[CODE]]
Commands.script = function(args)
    local code = trim(args)

    if code == "" then
        txt(user.Error, "Usage: /script [[CODE]]", 255, 0, 0)
        return
    end

    -- remove wrapping [[ ]]
    code = code:gsub("^%[%[", ""):gsub("%]%]$", "")

    txt(user.Sys, "Executing script...", 255, 90, 0)

    local fn, err = loadstring(code)
    if not fn then
        txt(user.Error, "Compile error: " .. tostring(err), 255, 0, 0)
        return
    end

    local ok, runtimeErr = pcall(fn)
    if ok then
        txt(user.Suc, "Script executed successfully", 0, 255, 0)
    else
        txt(user.Error, "Runtime error: " .. tostring(runtimeErr), 255, 0, 0)
    end
end

-- alias
Commands.run = Commands.script

-- ===============================
-- MESSAGE DISPATCH
-- ===============================

local function handleMessage(message)
    message = trim(message)
    if message == "" then return end

    -- show user message
    txt(user.plr, message, 255, 255, 255)

    -- command?
    if message:sub(1,1) == "/" then
        local cmd, args = message:match("^/(%S+)%s*(.*)$")
        cmd = cmd and cmd:lower()

        if Commands[cmd] then
            Commands[cmd](args or "")
        else
            txt(user.Warn, "Unknown command: /" .. tostring(cmd), 255, 255, 0)
        end
    end
end

-- ===============================
-- CONNECT UI
-- ===============================

-- Send button
se.MouseButton1Click:Connect(function()
    handleMessage(ch.Text)
    clearInput()
end)

-- Enter key
ch.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        handleMessage(ch.Text)
        clearInput()
    end
end)

