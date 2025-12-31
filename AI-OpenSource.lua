-- gpt 3.571

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
txt(user.Nill, "Version: Test 3.571 | © Copyright LighterCyan", 180, 180, 180)
txt(user.Warn, "Stop! For your safety, please do not share your API and avoid being stared at by people around you. Due to safety and privacy concerns, you confirm that you will use your API to continue using our AI-OpenSource or not? With respect.", 255,255,0)
txt(user.Nill, "[====== Chat ======]", 180, 180, 180)

-- AI-OpenSource: Chat bridge (executor HTTP)
-- ต้องการ UI instances ที่มีอยู่:
-- Frame path: CoreGui.ExperienceSettings.Menu.AIOpenSource.Frame
-- children: "api" (TextBox), "Confirm_api" (TextButton), "Unsaved_API" (TextButton), "Status" (TextLabel),
--           "chat" (TextBox), "Send" (TextButton), "ChatLogs" (ScrollingFrame)
-- ต้องมีฟังก์ชัน txt(userKey, text, R,G,B) อยู่แล้ว (ใช้เพื่อเขียน log ใน ChatLogs)

local Http = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- Safe find UI frame (tolerant)
local function getFrame()
    local ok, menu = pcall(function()
        return CoreGui:WaitForChild("ExperienceSettings", 5).Menu
    end)
    if not ok or not menu then return nil end
    local f = menu:FindFirstChild("AIOpenSource") or menu:FindFirstChild("ChatGPT") or menu:FindFirstChild("AIOpen") 
    if f and f:FindFirstChild("Frame") then
        return f.Frame
    elseif f and f:IsA("Frame") then
        return f
    end
    return nil
end

local frame = getFrame()
if not frame then
    warn("[AI-OpenSource] UI frame not found at CoreGui.ExperienceSettings.Menu.AIOpenSource.Frame")
    return
end

local apiBox       = frame:FindFirstChild("api")
local confirmBtn   = frame:FindFirstChild("Confirm_api")
local unsaveBtn    = frame:FindFirstChild("Unsaved_API")
local statusLabel  = frame:FindFirstChild("Status")
local chatBox      = frame:FindFirstChild("chat")
local sendBtn      = frame:FindFirstChild("Send")
local chatLogs     = frame:FindFirstChild("ChatLogs")

if not (apiBox and confirmBtn and unsaveBtn and statusLabel and chatBox and sendBtn and chatLogs) then
    warn("[AI-OpenSource] Missing one or more UI elements (api, Confirm_api, Unsaved_API, Status, chat, Send, ChatLogs)")
    -- still continue but many features will be no-op
end

-- use existing txt() function for printing to ChatLogs
-- assume txt(userKey, text, R,G,B) exists globally
if type(txt) ~= "function" then
    error("txt(userKey, text, R,G,B) function not found — required for Chat logging")
end

-- detect executor HTTP function
local httpRequest =
    (syn and syn.request) or
    (http and http.request) or
    (fluxus and fluxus.request) or
    request or
    http_request or
    (function() return nil end)

if not httpRequest then
    txt("Error", "No executor HTTP function found (syn.request / http.request / request)", 255,0,0)
    warn("[AI-OpenSource] No http request function found in environment")
end

-- config
local cfg = {
    apiKey = nil,
    provider = nil, -- "openai" or "gemini"
    openai_url = "https://api.openai.com/v1/chat/completions",
    openai_model = "gpt-4o-mini", -- change if you want
    gemini_url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
    queue = {},
    processing = false,
    backoff = 1.5, -- exponential backoff base
    maxBackoff = 60,
    lastRequestTime = 0,
    minInterval = 1.0, -- minimum seconds between requests to avoid 429
}

-- helper: set status label safely
local function setStatus(s)
    if statusLabel and statusLabel:IsA("TextLabel") then
        statusLabel.Text = "Status: " .. tostring(s)
    end
end

-- determine provider by key pattern
local function detectProvider(key)
    if not key or key == "" then return nil end
    if tostring(key):match("^sk") or tostring(key):match("^sk%-proj") then
        return "openai"
    end
    if tostring(key):match("^AIza") then
        return "gemini"
    end
    -- fallback: if contains "sk-" treat as openai
    if tostring(key):find("sk%-") then return "openai" end
    -- unknown
    return nil
end

-- enqueue prompt
local function enqueuePrompt(prompt, meta)
    table.insert(cfg.queue, {prompt = prompt, meta = meta})
    -- attempt process
    task.spawn(function()
        if not cfg.processing then
            cfg.processing = true
            while #cfg.queue > 0 do
                local item = table.remove(cfg.queue, 1)
                -- respect min interval
                local waitFor = cfg.minInterval - (tick() - cfg.lastRequestTime)
                if waitFor > 0 then task.wait(waitFor) end
                local ok = pcall(function() 
                    -- send and handle backoff internally
                    local success = false
                    local backoff = cfg.backoff
                    while not success do
                        local status, err = pcall(function()
                            -- choose provider
                            if cfg.provider == "openai" then
                                -- OpenAI Chat Completion
                                local body = {
                                    model = cfg.openai_model,
                                    messages = {
                                        {role="system", content = "You are a helpful assistant."},
                                        {role="user", content = item.prompt}
                                    },
                                    max_tokens = 1024,
                                    temperature = 0.7
                                }
                                local res = httpRequest({
                                    Url = cfg.openai_url,
                                    Method = "POST",
                                    Headers = {
                                        ["Content-Type"] = "application/json",
                                        ["Authorization"] = "Bearer " .. tostring(cfg.apiKey)
                                    },
                                    Body = Http:JSONEncode(body),
                                    Timeout = 20
                                })
                                cfg.lastRequestTime = tick()
                                if not res then error("No response from HTTP request") end
                                if res.StatusCode == 429 then
                                    error("RATE_LIMIT_429")
                                end
                                if res.StatusCode < 200 or res.StatusCode >= 300 then
                                    error("HTTP "..tostring(res.StatusCode).." "..tostring(res.Body))
                                end
                                local okdecode, decoded = pcall(function() return Http:JSONDecode(res.Body) end)
                                if not okdecode then error("Invalid JSON from OpenAI: "..tostring(res.Body)) end
                                -- try to extract text
                                local text = nil
                                if decoded.choices and decoded.choices[1] and decoded.choices[1].message and decoded.choices[1].message.content then
                                    text = decoded.choices[1].message.content
                                elseif decoded.choices and decoded.choices[1] and decoded.choices[1].text then
                                    text = decoded.choices[1].text
                                else
                                    text = Http:JSONEncode(decoded)
                                end
                                -- display
                                txt(user.chat, text, 85,255,255) -- cyan
                                success = true
                            elseif cfg.provider == "gemini" then
                                local body = {
                                    contents = {
                                        { parts = { { text = item.prompt } } }
                                    }
                                }
                                local res = httpRequest({
                                    Url = cfg.gemini_url,
                                    Method = "POST",
                                    Headers = {
                                        ["Content-Type"] = "application/json",
                                        ["x-goog-api-key"] = tostring(cfg.apiKey)
                                    },
                                    Body = Http:JSONEncode(body),
                                    Timeout = 20
                                })
                                cfg.lastRequestTime = tick()
                                if not res then error("No response from HTTP request") end
                                if res.StatusCode == 429 then
                                    error("RATE_LIMIT_429")
                                end
                                if res.StatusCode < 200 or res.StatusCode >= 300 then
                                    error("HTTP "..tostring(res.StatusCode).." "..tostring(res.Body))
                                end
                                local okdecode, decoded = pcall(function() return Http:JSONDecode(res.Body) end)
                                if not okdecode then error("Invalid JSON from Gemini: "..tostring(res.Body)) end
                                -- try read candidates
                                local text = nil
                                if decoded.candidates and decoded.candidates[1] and decoded.candidates[1].content and decoded.candidates[1].content.parts and decoded.candidates[1].content.parts[1] then
                                    text = decoded.candidates[1].content.parts[1].text
                                else
                                    text = Http:JSONEncode(decoded)
                                end
                                txt(user.chat, text, 85,255,255)
                                success = true
                            else
                                error("No provider selected")
                            end
                        end)
                        if not status then
                            local errMsg = tostring(err or "unknown")
                            if errMsg:find("RATE_LIMIT_429") or errMsg:find("429") then
                                -- backoff then retry
                                txt(user.Warn, "Rate limited. backing off "..tostring(math.floor(backoff)).."s", 255,255,0)
                                task.wait(backoff)
                                backoff = math.min(backoff * 2, cfg.maxBackoff)
                            else
                                txt(user.Error, "Request failed: "..errMsg, 255,0,0)
                                success = true -- stop retrying for other errors
                            end
                        end
                    end
                end)
                if not ok then
                    txt(user.Error, "Processing queue error: "..tostring(err), 255,0,0)
                end
            end
            cfg.processing = false
        end
    end)
end

-- send-button handler
local function onSend()
    if not cfg.apiKey then
        txt(user.Warn, "No API key set. Use Confirm_api to set.", 255,255,0)
        return
    end
    local prompt = tostring(chatBox and chatBox.Text or "")
    if prompt == "" then
        txt(user.Warn, "Empty message.", 255,255,0)
        return
    end
    -- display user message
    txt(user.plr, prompt, 255,255,255)
    -- clear input
    if chatBox then chatBox.Text = "" end
    enqueuePrompt(prompt, {})
end

-- Confirm/Unsave API handlers
local function setApiKeyFromBox()
    if not apiBox then return end
    local key = tostring(apiBox.Text or "")
    if key == "" then
        txt(user.Warn, "Empty API key.", 255,255,0)
        setStatus("No key")
        return
    end
    -- detect
    local prov = detectProvider(key)
    if not prov then
        -- if unknown but contains "AIza" -> gemini, else if contains "sk" -> openai
        if key:find("AIza") then prov = "gemini" end
    end
    cfg.apiKey = key
    cfg.provider = prov or "openai" -- default to openai if unknown
    setStatus((cfg.provider == "openai") and "Select ChatGPT" or (cfg.provider == "gemini") and "Select Gemini" or "Select ChatGPT")
    txt(user.Suc, "API key set for provider: "..tostring(cfg.provider), 0,255,0)

    -- optional quick check: minimal request (skip heavy validation if you prefer). We'll attempt a tiny test but avoid heavy calls.
    setStatus("Connecting")
    -- do a light test depending on provider (non-blocking)
    task.spawn(function()
        local ok, resp = pcall(function()
            if cfg.provider == "openai" then
                local body = { model = cfg.openai_model, messages = {{role="user", content = "Hello"}} , max_tokens = 1 }
                local r = httpRequest({
                    Url = cfg.openai_url,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json", ["Authorization"] = "Bearer "..cfg.apiKey },
                    Body = Http:JSONEncode(body),
                    Timeout = 10
                })
                return r
            else
                local body = { contents = {{ parts = {{ text = "Hello" }} }} }
                local r = httpRequest({
                    Url = cfg.gemini_url,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json", ["x-goog-api-key"] = cfg.apiKey },
                    Body = Http:JSONEncode(body),
                    Timeout = 10
                })
                return r
            end
        end)
        if not ok or not resp then
            setStatus("Invalid key")
            txt(user.Error, "Key test failed (no response).", 255,0,0)
            return
        end
        if type(resp.StatusCode) == "number" and (resp.StatusCode == 200 or resp.StatusCode == 201) then
            setStatus("Connected")
            txt(user.Suc, "API connected.", 0,255,0)
        elseif type(resp.StatusCode) == "number" and resp.StatusCode == 401 then
            setStatus("Invalid key")
            txt(user.Error, "Invalid key (401).", 255,0,0)
        elseif type(resp.StatusCode) == "number" and resp.StatusCode == 429 then
            setStatus("Connected (Rate-limited)")
            txt(user.Warn, "Connected but rate-limited (429).", 255,255,0)
        else
            setStatus("Connected")
            txt(user.Info, "Test response: "..tostring(resp.StatusCode).. " " ..tostring(resp.StatusMessage or ""), 0,170,255)
        end
    end)
end

local function clearApiKey()
    cfg.apiKey = nil
    cfg.provider = nil
    setStatus("Unsave key")
    txt(user.Sys, "API key cleared (unsaved).", 255,90,0)
end

-- connect UI events
if sendBtn and sendBtn.MouseButton1Click then
    sendBtn.MouseButton1Click:Connect(onSend)
end
if chatBox then
    -- allow Enter on TextBox to send (some executors allow detecting Enter; fallback to clicking)
    chatBox.FocusLost:Connect(function(enter)
        if enter then onSend() end
    end)
end
if confirmBtn and confirmBtn.MouseButton1Click then
    confirmBtn.MouseButton1Click:Connect(function()
        setApiKeyFromBox()
    end)
end
if unsaveBtn and unsaveBtn.MouseButton1Click then
    unsaveBtn.MouseButton1Click:Connect(function()
        clearApiKey()
    end)
end

setStatus("No key")
txt(user.Nill, "AI bridge loaded. Use Confirm_api to set a key, then type and Send.", 180,180,180)

-- end of script
