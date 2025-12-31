-- gpt 2.1

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
tb.PlaceholderText = "[ Your API_gpt here (ChatGPT or Gemini) ]"
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
ch.PlaceholderText = "Say something..."
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
]]

-- functions
local user = {
    plr  = "You: ",
    chat = "AI: ",
    Error = "Error: ",
    Suc   = "Success: ",
    Warn  = "Warning: ",
    Info  = "Information: ",
    Nill = ""
}

-- ChatLogs Line
local function txt(user, text, R, G, B)
    local cha = Instance.new("TextLabel")
    cha.Name = "Text"
    cha.Size = UDim2.new(1, 0, 0, 30) -- default height (ปรับภายหลังได้)
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
]]

txt(user.Nill, "Nothing is working! Please wait for the next update!", 180,180,180)
txt(user,Nill, "Version: Test 2 | © Copyright LighterCyan

-- =========================
-- API CONNECT / CHAT HANDLER
-- =========================

-- เตรียม httpRequest fallback (executor-friendly)
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if not httpRequest then
    txt(user.Error, "No executor HTTP available.", 255,0,0)
    st.Text = "Status: No HTTP"
    return
end

-- constants
local OPENAI_URL = "https://api.openai.com/v1/responses"
local GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

-- helper: trim
local function trim(s)
    if not s then return "" end
    return s:match("^%s*(.-)%s*$")
end

-- detect provider from key
local function detectProvider(key)
    if not key then return nil end
    key = trim(key)
    if key:match("^sk%-") then
        return "openai"
    elseif key:match("^AIza") then
        return "gemini"
    else
        return nil
    end
end

-- update Status UI helper
local function setStatus(state)
    if not st then return end
    -- map states to label text
    local label = {
        select_chatgpt = "Status: Select ChatGPT",
        select_gemini  = "Status: Select Gemini",
        connecting     = "Status: Connecting",
        connected      = "Status: Connected",
        invalid        = "Status: Invalid key",
        unsave         = "Status: Unsave key",
        nokey          = "Status: No key",
    }
    st.Text = label[state] or ("Status: "..tostring(state))
end

-- validate OpenAI key by hitting /v1/models (GET) — lightweight
local function validateOpenAIKey(key, timeout)
    timeout = timeout or 10
    local ok, res = pcall(function()
        return httpRequest({
            Url = "https://api.openai.com/v1/models",
            Method = "GET",
            Headers = {
                ["Authorization"] = "Bearer "..key
            },
            Timeout = timeout
        })
    end)
    if not ok then
        return false, tostring(res)
    end
    -- status code 200 -> valid
    if res.StatusCode and tonumber(res.StatusCode) == 200 then
        return true
    else
        return false, (res.StatusMessage or tostring(res.StatusCode) or "unknown")
    end
end

-- validate Gemini key by doing a minimal POST (same shape used later)
local function validateGeminiKey(key, timeout)
    timeout = timeout or 10
    local body = {contents = {{parts = {{text = "hi"}}}}}
    local ok, res = pcall(function()
        return httpRequest({
            Url = GEMINI_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["x-goog-api-key"] = key
            },
            Body = game:GetService("HttpService"):JSONEncode(body),
            Timeout = timeout
        })
    end)
    if not ok then
        return false, tostring(res)
    end
    -- many google errors still return 200 with error body; treat success if Body decodes and has candidates or content
    local succ, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(res.Body) end)
    if succ and decoded and (decoded.candidates or decoded.output) then
        return true
    else
        -- if status code 200 but no usable body -> invalid
        if res.StatusCode and tonumber(res.StatusCode) >= 200 and tonumber(res.StatusCode) < 300 then
            -- ambiguous — treat as valid but warn
            return true, "ambiguous"
        end
        return false, (res.StatusMessage or tostring(res.StatusCode) or res.Body or "unknown")
    end
end

-- choose provider validator
local function validateKeyForProvider(key, provider)
    if provider == "openai" then
        return validateOpenAIKey(key)
    elseif provider == "gemini" then
        return validateGeminiKey(key)
    else
        return false, "unknown provider"
    end
end

-- store selected provider and key (in memory)
local CURRENT = {
    provider = nil,
    key = nil,
    connected = false
}

-- UI button actions: Confirm / Unsaved
con.MouseButton1Click:Connect(function()
    local k = trim(api.Text) -- api is the textbox variable in your UI
    if k == "" or not k then
        txt(user.Warn, "Please enter API key.", 255,255,0)
        setStatus("nokey")
        return
    end

    local provider = detectProvider(k)
    if provider == "openai" then
        setStatus("connecting")
        txt(user.Info, "Checking OpenAI key...", 0,170,255)
        local ok, msg = validateKeyForProvider(k, "openai")
        if ok then
            CURRENT.provider = "openai"
            CURRENT.key = k
            CURRENT.connected = true
            setStatus("connected")
            txt(user.Suc, "Connected to OpenAI (ChatGPT).", 0,255,0)
        else
            CURRENT.provider = nil
            CURRENT.key = nil
            CURRENT.connected = false
            setStatus("invalid")
            txt(user.Error, "OpenAI key invalid: "..tostring(msg), 255,0,0)
        end

    elseif provider == "gemini" then
        setStatus("connecting")
        txt(user.Info, "Checking Gemini key...", 0,170,255)
        local ok, msg = validateKeyForProvider(k, "gemini")
        if ok then
            CURRENT.provider = "gemini"
            CURRENT.key = k
            CURRENT.connected = true
            setStatus("connected")
            txt(user.Suc, "Connected to Gemini.", 0,255,0)
        else
            CURRENT.provider = nil
            CURRENT.key = nil
            CURRENT.connected = false
            setStatus("invalid")
            txt(user.Error, "Gemini key invalid: "..tostring(msg), 255,0,0)
        end

    else
        setStatus("nokey")
        txt(user.Warn, "Key not recognised (not sk- nor AIza).", 255,255,0)
    end
end)

con2.MouseButton1Click:Connect(function()
    -- unsave / disconnect
    CURRENT.provider = nil
    CURRENT.key = nil
    CURRENT.connected = false
    api.Text = ""
    setStatus("unsave")
    txt(user.Warn, "API key removed (unsaved).", 255,255,0)
end)

-- send -> choose provider send impl
local function callOpenAI(prompt)
    local body = {
        model = "gpt-4o-mini",
        input = prompt
    }
    local ok, res = pcall(function()
        return httpRequest({
            Url = OPENAI_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer "..CURRENT.key
            },
            Body = game:GetService("HttpService"):JSONEncode(body),
            Timeout = 20
        })
    end)
    if not ok then
        return false, tostring(res)
    end
    if not res or not res.Body then
        return false, "Empty response"
    end
    local succ, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(res.Body) end)
    if not succ or not decoded then
        return false, "Failed decode"
    end
    -- New Responses API: decoded.output[1].content[0].text OR decoded.output[1].content[1] etc.
    local text = nil
    if decoded.output and decoded.output[1] and decoded.output[1].content then
        -- try to collect textual parts
        for _, c in ipairs(decoded.output[1].content) do
            if c.text then
                text = (text or "") .. c.text
            end
        end
    elseif decoded.output_text then
        text = decoded.output_text
    elseif decoded.choice and decoded.choice[1] and decoded.choice[1].message and decoded.choice[1].message.content then
        -- fallback older structure
        text = decoded.choice[1].message.content[1].text or decoded.choice[1].message.content
    end

    if text then
        return true, text
    else
        return false, ("No text in response - raw: "..tostring(res.Body))
    end
end

local function callGemini(prompt)
    local rawBody = {contents = {{parts = {{text = prompt}}}}}
    local ok, res = pcall(function()
        return httpRequest({
            Url = GEMINI_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["x-goog-api-key"] = CURRENT.key
            },
            Body = game:GetService("HttpService"):JSONEncode(rawBody),
            Timeout = 20
        })
    end)
    if not ok then
        return false, tostring(res)
    end
    if not res or not res.Body then
        return false, "Empty response"
    end
    local succ, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(res.Body) end)
    if not succ then
        return false, "Failed decode"
    end
    if decoded.candidates and decoded.candidates[1] and decoded.candidates[1].content and decoded.candidates[1].content.parts then
        return true, decoded.candidates[1].content.parts[1].text
    end
    return false, ("No candidate - raw: "..tostring(res.Body))
end

-- main send function
local function sendPrompt()
    local prompt = trim(ch.Text)
    if prompt == "" then
        txt(user.Warn, "Please type a prompt first.", 255,255,0)
        return
    end

    -- display user message
    txt(user.plr, prompt, 255,255,255)
    ch.Text = ""

    if not CURRENT.connected or not CURRENT.key or not CURRENT.provider then
        txt(user.Error, "Not connected to any API. Please Confirm API key first.", 255,0,0)
        setStatus("nokey")
        return
    end

    setStatus("connecting")
    txt(user.Info, "Sending to AI...", 0,170,255)

    -- spawn so UI doesn't freeze
    task.spawn(function()
        local ok, respOrErr
        if CURRENT.provider == "openai" then
            ok, respOrErr = callOpenAI(prompt)
        elseif CURRENT.provider == "gemini" then
            ok, respOrErr = callGemini(prompt)
        else
            ok, respOrErr = false, "Unknown provider"
        end

        if ok then
            setStatus("connected")
            txt(user.chat, respOrErr, 85,255,255)
        else
            setStatus("invalid")
            txt(user.Error, "AI Error: "..tostring(respOrErr), 255,0,0)
        end
    end)
end

-- bind send actions
se.MouseButton1Click:Connect(sendPrompt)
ch.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        sendPrompt()
    end
end)
