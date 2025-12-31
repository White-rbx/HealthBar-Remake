-- gpt 2.5

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
txt(user.Nill, "Version: Test 2.5 | © Copyright LighterCyan", 180, 180, 180)

-- ====== AI connector (append to your script) ======
-- assumes these UI variables already exist:
-- tb (TextBox for API key), con (Confirm_api TextButton), con2 (Unsaved_API TextButton),
-- st (Status TextLabel), ch (chat TextBox), se (Send TextButton), si (ChatLogs ScrollingFrame),
-- user table and txt(user, text, R,G,B) function exist.

local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local httpService = game:GetService("HttpService")

-- storage config
local KEY_FILE = "AI_OpenSource_key.txt"

local state = {
    apiKey = nil,
    apiType = nil, -- "ChatGPT" or "Gemini" or nil
    status = "No key", -- status text
    model_chatgpt = "gpt-4o-mini", -- change if you want
    gemini_url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
    openai_models_url = "https://api.openai.com/v1/models",
}

-- helper: set status label and write small chat line
local function setStatus(s)
    state.status = s
    if st and st.Text then
        st.Text = "Status: " .. s
    end
    -- also show in chat logs for user visibility
    if s and #s > 0 then
        txt(user.Info, "Status: " .. s, 0, 170, 255)
    end
end

-- detect key type
local function detectKeyType(key)
    if not key or key == "" then return nil end
    key = tostring(key)
    if key:match("^sk") or key:match("^sk%-proj") then
        return "ChatGPT"
    elseif key:match("^AIza") then
        return "Gemini"
    else
        return nil
    end
end

-- save/load key (use writefile/readfile if available)
local function saveKeyToFile(key)
    if not key then return end
    if writefile then
        local enc = key
        if (crypt and crypt.base64encode) or _G.base64 then
            local b64 = (crypt and (crypt.base64encode or crypt.base64.encode)) or _G.base64 and _G.base64.encode
            if b64 then enc = b64(key) end
        end
        pcall(function() writefile(KEY_FILE, enc) end)
    end
end
local function loadKeyFromFile()
    if isfile and readfile and isfile(KEY_FILE) then
        local ok, raw = pcall(readfile, KEY_FILE)
        if ok and raw then
            -- try base64 decode if possible
            local dec = raw
            local b64dec = (crypt and (crypt.base64decode or crypt.base64.decode)) or (_G.base64 and _G.base64.decode)
            if b64dec then
                pcall(function() dec = b64dec(raw) end)
            end
            return dec
        end
    end
    return nil
end

-- minimal validators
local function validateChatGPTKey(key)
    if not httpRequest then return false, "No httpRequest available" end
    local ok, resp = pcall(function()
        return httpRequest({
            Url = state.openai_models_url,
            Method = "GET",
            Headers = {
                ["Authorization"] = "Bearer " .. key,
                ["Content-Type"] = "application/json"
            },
            Timeout = 8
        })
    end)
    if not ok then return false, tostring(resp) end
    if resp and (resp.StatusCode == 200 or resp.StatusCode == 429 or resp.StatusCode == 401) then
        -- 200 = valid (list returned), 429 = rate/billing (key valid but limited), 401 = invalid
        if resp.StatusCode == 200 or resp.StatusCode == 429 then
            return true, "OK"
        else
            return false, "HTTP " .. tostring(resp.StatusCode)
        end
    end
    return false, "HTTP request failed"
end

local function validateGeminiKey(key)
    if not httpRequest then return false, "No httpRequest available" end
    local testBody = { contents = {{ parts = {{ text = "hi" }} }} }
    local ok, resp = pcall(function()
        return httpRequest({
            Url = state.gemini_url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["x-goog-api-key"] = key
            },
            Body = httpService:JSONEncode(testBody),
            Timeout = 8
        })
    end)
    if not ok then return false, tostring(resp) end
    if resp and (resp.StatusCode == 200 or resp.StatusCode == 429) then
        return true, "OK"
    end
    return false, "HTTP " .. tostring(resp.StatusCode or "nil")
end

-- UI button handlers
con.MouseButton1Click:Connect(function()
    local key = tostring(tb.Text or ""):gsub("^%s*(.-)%s*$", "%1")
    if key == "" then
        setStatus("No key")
        txt(user.Warn, "Please enter an API key first", 255,255,0)
        return
    end
    setStatus("Connecting")
    local detected = detectKeyType(key)
    if not detected then
        setStatus("Invalid key")
        txt(user.Error, "Key format not recognized (not sk... or AIza...)", 255,0,0)
        return
    end

    -- validate remote
    spawn(function()
        if detected == "ChatGPT" then
            local ok, msg = validateChatGPTKey(key)
            if ok then
                state.apiKey = key
                state.apiType = "ChatGPT"
                saveKeyToFile(key)
                setStatus("Connected (ChatGPT)")
                txt(user.Suc, "ChatGPT key validated.", 0,255,0)
            else
                setStatus("Invalid key")
                txt(user.Error, "ChatGPT key validation failed: "..tostring(msg), 255,0,0)
            end
        else -- Gemini
            local ok, msg = validateGeminiKey(key)
            if ok then
                state.apiKey = key
                state.apiType = "Gemini"
                saveKeyToFile(key)
                setStatus("Connected (Gemini)")
                txt(user.Suc, "Gemini key validated.", 0,255,0)
            else
                setStatus("Invalid key")
                txt(user.Error, "Gemini key validation failed: "..tostring(msg), 255,0,0)
            end
        end
    end)
end)

con2.MouseButton1Click:Connect(function()
    -- unsave / remove key
    state.apiKey = nil
    state.apiType = nil
    if writefile and isfile and isfile(KEY_FILE) then
        pcall(function() delfile(KEY_FILE) end)
    end
    tb.Text = ""
    setStatus("Unsave key")
    txt(user.Warn, "API key removed (unsaved).", 255,255,0)
end)

-- loader: try load saved key (non-blocking)
spawn(function()
    local k = loadKeyFromFile()
    if k then
        tb.Text = "•••••• (saved)"
        -- don't auto-confirm: user must press Confirm, but keep memory
        state.apiKey = k
        state.apiType = detectKeyType(k)
        if state.apiType then setStatus("Key loaded (need confirm)") end
    end
end)

-- send functions
local function callChatGPT(prompt)
    if not state.apiKey then return nil, "No API key" end
    if not httpRequest then return nil, "No http request" end
    local payload = {
        model = state.model_chatgpt,
        messages = {
            { role = "user", content = prompt }
        },
        max_tokens = 900
    }
    local ok, resp = pcall(function()
        return httpRequest({
            Url = "https://api.openai.com/v1/chat/completions",
            Method = "POST",
            Headers = {
                ["Authorization"] = "Bearer " .. state.apiKey,
                ["Content-Type"] = "application/json"
            },
            Body = httpService:JSONEncode(payload),
            Timeout = 20
        })
    end)
    if not ok then return nil, tostring(resp) end
    if resp.StatusCode and (resp.StatusCode >= 200 and resp.StatusCode < 300) then
        local s, body = pcall(function() return httpService:JSONDecode(resp.Body) end)
        if not s then return nil, "Failed decode response" end
        -- parse usual ChatGPT response shapes
        local text = nil
        if body.choices and body.choices[1] and body.choices[1].message and body.choices[1].message.content then
            text = body.choices[1].message.content
        elseif body.choices and body.choices[1] and body.choices[1].text then
            text = body.choices[1].text
        else
            text = httpService:JSONEncode(body)
        end
        return text, nil
    else
        return nil, "HTTP " .. tostring(resp.StatusCode or "nil")
    end
end

local function callGemini(prompt)
    if not state.apiKey then return nil, "No API key" end
    if not httpRequest then return nil, "No http request" end
    local rawBody = { contents = {{ parts = {{ text = prompt }} }} }
    local ok, resp = pcall(function()
        return httpRequest({
            Url = state.gemini_url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["x-goog-api-key"] = state.apiKey
            },
            Body = httpService:JSONEncode(rawBody),
            Timeout = 20
        })
    end)
    if not ok then return nil, tostring(resp) end
    if resp.StatusCode and (resp.StatusCode >= 200 and resp.StatusCode < 300) then
        local s, body = pcall(function() return httpService:JSONDecode(resp.Body) end)
        if not s then return nil, "Failed decode body" end
        if body.candidates and body.candidates[1] and body.candidates[1].content and body.candidates[1].content.parts then
            local p = body.candidates[1].content.parts[1].text
            return p, nil
        else
            return httpService:JSONEncode(body), nil
        end
    else
        return nil, "HTTP " .. tostring(resp.StatusCode or "nil")
    end
end

-- main Send handler
se.MouseButton1Click:Connect(function()
    local prompt = tostring(ch.Text or ""):gsub("^%s*(.-)%s*$", "%1")
    if prompt == "" then
        txt(user.Warn, "Please type a prompt first.", 255,255,0)
        return
    end
    -- user message
    txt(user.plr, prompt, 255,255,255)
    ch.Text = ""

    if not state.apiKey or not state.apiType then
        txt(user.Error, "Not connected to any API. Please Confirm API key first.", 255,0,0)
        return
    end

    -- show thinking
    local thinkingLabel = txt(user.Info, "Thinking...", 0,170,255)

    -- call in background
    spawn(function()
        local result, err
        if state.apiType == "ChatGPT" then
            result, err = callChatGPT(prompt)
        else
            result, err = callGemini(prompt)
        end

        if thinkingLabel and thinkingLabel.Parent then
            thinkingLabel:Destroy()
        end

        if result then
            txt(user.chat, result, 85,255,255)
        else
            txt(user.Error, "Error: " .. tostring(err or "unknown"), 255,0,0)
        end
    end)
end)

-- finishing note
setStatus(state.status or "No key")

-- end of appended connector
