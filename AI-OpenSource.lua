local ver = " gpt Test 4.242 ( Closed )"
local update = [=[
-- Update logs --
(:8/1/2026 | 5:55 pm: !) Fixed bug
(:8/1/2026 | 6:00 pm: R) Raw reset GitHub bug.
(:8/1/2026 | 6:22 pm: !) Fixed bug again
(:8/1/2026 | -:-- pm: R) GitHub bug
(:8/1/2026 | 6:49 pm: C) Closed
(:30/1/2026 | 8:12 pm: U) Update
(:30/1/2026 | 8:59 pm: D) Disabled top button for bug.
]=]

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

tb.Visible = false
con.Visible = false
con2.Visible = false
st.Visible = false

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
    cha.Size = UDim2.new(0.97, 0, 0, 0) -- default height (ปรับภายหลังได้)
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

txt(user.Nill, "Nothing is working! Please wait for the next update!", 180,180,180)
txt(user.Nill, "Version:" .. ver .. "| © Copyright LighterCyan", 180, 180, 180)
txt(user.Info, update, 0, 170, 255)
txt(user.Warn, "Stop! For your safety, please do not share your API and avoid being stared at by people around you. Due to safety and privacy concerns, you confirm that you will use your API to continue using our AI-OpenSource or not? With respect.", 255, 255, 0)
txt(user.Info, "Use /help for more information or commands. Add api is /addapi", 0,170,255) 
-- txt(user.Nill, 
--[[ What is AI-OpenSource?
  AI-OpenSource is a tool for questioning to AIs (ChatGPT/Gemini) by putting API Key.
  
What AI model you using?
  We use gpt-4o-mini and gemini-2.5-flash
  
This is safe to put api key?
  Yes, this is safe to put your api key, but make sure do NOT share your api.
  
Available commands
  use /Help
", 180, 180, 180)

txt(user.Nill, "Welcome back Tester", 0, 255, 0)
]]
txt(user.Nill, [=[
[==> OFFICIAL ANNOUNCEMENT <==]
AI-OpenSource close for now. We'll be right back soon! maybe 

AI MIGHT BE BUG BECAUSE OF TEXTLABEL
]=], 255,0,0)
txt(user.Nill, "[====== Chat ======]", 180, 180, 180)

-- ===========================
-- AI-OpenSource: Full runtime (UI hook, commands, executor HTTP, Gemini/OpenAI)
-- Place this where your client script runs (LocalScript / executor-run context)
-- It expects your UI already exists (CoreGui.ExperienceSettings.Menu.AIOpenSource.Frame)
-- Uses executor http (syn.request / http_request / request / fluxus.request) when available.

-- ========== CONFIG ==========
local saveFileName = "ai_open_source_key.txt" -- optional save
local DEBUG_MODE = false
local REQUEST_INTERVAL = 0.8 -- min delay between outbound requests (seconds) to reduce 429
local VALIDATION_DELAY = 6 -- seconds after pressing Confirm to validate key
local QUEUE_MAX_RETRIES = 4

-- profile presets
local GPT_PRESETS = {
    FREE  = {mt = 64,  t = 0.5},
    PRO   = {mt = 256, t = 0.7},
    PLUS  = {mt = 512, t = 0.75},
}
local GEMINI_PRESETS = {
    FREE  = {mt = 64,  t = 0.4},
    PRO   = {mt = 256, t = 0.7},
    PLUS  = {mt = 512, t = 0.75},
}

-- ========== SERVICES & UTIL ==========
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- executor http detection (function returning response-like table)
local httpRequestFunc = nil
if syn and syn.request then httpRequestFunc = syn.request
elseif http and http.request then httpRequestFunc = http.request
elseif request then httpRequestFunc = request
elseif fluxus and fluxus.request then httpRequestFunc = fluxus.request
elseif http_request then httpRequestFunc = http_request
else httpRequestFunc = nil end

-- simple wrappers
local function jsonEncode(t) return HttpService:JSONEncode(t) end
local function jsonDecode(s) local ok, r = pcall(HttpService.JSONDecode, HttpService, s); if ok then return r end; return nil end

local function safeCall(fn, ...)
    local ok, a, b = pcall(fn, ...)
    return ok, a, b
end

local function debugLog(...)
    if not DEBUG_MODE then return end
    local args = { ... }
    pcall(function()
        print("[AI-OpenSource][DEBUG]", unpack(args))
    end)
end

-- ========== UI ELEMENT REFERENCES (will be set by hook) ==========
local UI = {
    root = nil,
    textFrame = nil,
    ch = nil,   -- TextBox for chat input
    se = nil,   -- Send button
    tb = nil,   -- API textbox
    si = nil,   -- ScrollingFrame for logs
    st = nil,   -- Status TextLabel
    con = nil,  -- Confirm_api TextButton
    con2 = nil, -- Unsaved_API TextButton
}
-- convenience locals bound to UI fields for readability (will update after hook)
local ch, se, tb, si, st, con, con2

-- ========== user labels & safe text function (already exist in user code, but we keep fallback) ==========
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

-- assume txt(user, text, r,g,b) already exists in global; if not provide fallback
if type(txt) ~= "function" then
    function txt(u, text, r,g,b)
        local color = {r or 255, g or 255, b or 255}
        local prefix = (type(u) == "string") and u or (u and tostring(u) or "")
        local line = tostring(prefix) .. tostring(text)
        print("[AI-OpenSource][FALLBACK-TXT]", line)
    end
end

local function safeTxt(u, t, r,g,b)
    if type(txt) == "function" then
        pcall(txt, u, t, r or 255, g or 255, b or 255)
    end
end

-- ========== STATE ==========
local currentProvider = nil -- "openai" | "gemini" | "custom"
local currentApiKey = nil
local currentCustomUrl = nil
local currentCustomAuth = nil
local currentModel = "gpt-4o-mini" -- default for OpenAI branch
local currentPresetGPT = "FREE"
local currentPresetGemini = "FREE"

-- queue for requests to avoid spamming
local requestQueue = {}
local lastRequestTime = 0
local isProcessingQueue = false

-- ========== REQUEST QUEUE / HTTP WRAPPER ==========
local function doRequest(req)
    if not httpRequestFunc then
        return nil, "no-http-executor"
    end
    -- allow two shapes: {Url=..., Method=..., Headers=..., Body=...} or {url=...}
    local requestParams = {}
    if req.Url or req.Url == nil then
        requestParams.Url = req.Url or req.url
        requestParams.Method = req.Method or req.method or "GET"
        requestParams.Headers = req.Headers or req.headers or {}
        requestParams.Body = req.Body or req.body or nil
    else
        -- fallback if passed the direct low-level table
        requestParams = req
    end
    debugLog("doRequest:", requestParams.Url, requestParams.Method)
    local ok, resp = pcall(httpRequestFunc, requestParams)
    if not ok then
        return nil, resp
    end
    -- normalize response keys
    local res = resp
    -- some executors return .StatusCode, some .status
    res.StatusCode = res.StatusCode or res.status or res.Status or 0
    res.Body = res.Body or res.body or res.response or ""
    return res
end

local function enqueueRequest(req)
    table.insert(requestQueue, {req = req, retries = 0})
    if not isProcessingQueue then
        task.spawn(function()
            isProcessingQueue = true
            while #requestQueue > 0 do
                local item = table.remove(requestQueue, 1)
                local now = tick()
                local waitFor = math.max(0, REQUEST_INTERVAL - (now - lastRequestTime))
                if waitFor > 0 then task.wait(waitFor) end
                lastRequestTime = tick()
                local ok, res = pcall(function() return doRequest(item.req) end)
                if ok and res and (res.StatusCode >= 200 and res.StatusCode < 300) then
                    if item.req.onSuccess then
                        pcall(item.req.onSuccess, res.Body, res)
                    end
                else
                    local statusCode = (res and res.StatusCode) or "ERR"
                    local body = (res and res.Body) or tostring(res)
                    debugLog("request failed:", statusCode, body)
                    if item.retries < QUEUE_MAX_RETRIES and (statusCode == 429 or statusCode == 502 or statusCode == 500) then
                        item.retries = item.retries + 1
                        table.insert(requestQueue, item) -- requeue at end
                        task.wait(1 + item.retries * 1.5)
                    else
                        if item.req.onError then
                            pcall(item.req.onError, body, res)
                        end
                    end
                end
            end
            isProcessingQueue = false
        end)
    end
end

-- ========== ENDPOINTS BUILDERS ==========
local function endpointsFor(provider)
    provider = tostring(provider or "openai"):lower()
    if provider == "gemini" then
        return {
            url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent",
            makeHeaders = function(key)
                return { ["Content-Type"] = "application/json", ["x-goog-api-key"] = key }
            end,
            makeBody = function(prompt)
                -- Gemini accepted body shape (per earlier example)
                return jsonEncode({
                    contents = {
                        {
                            role = "user",
                            parts = { { text = prompt } }
                        }
                    },
                    generationConfig = {
                        maxOutputTokens = GEMINI_PRESETS[currentPresetGemini].mt,
                        temperature = GEMINI_PRESETS[currentPresetGemini].t,
                        topP = 0.9
                    }
                })
            end,
            parseResult = function(bodyText)
                local d = jsonDecode(bodyText)
                if not d then return nil end
                if d.candidates and d.candidates[1] and d.candidates[1].content and d.candidates[1].content.parts and d.candidates[1].content.parts[1] then
                    return d.candidates[1].content.parts[1].text
                elseif d.outputText then
                    return d.outputText
                end
                return nil
            end
        }
    elseif provider == "custom" then
        return {
            url = currentCustomUrl,
            makeHeaders = function(key)
                local h = { ["Content-Type"] = "application/json" }
                if currentCustomAuth then h["Authorization"] = "Bearer " .. tostring(currentCustomAuth) end
                return h
            end,
            makeBody = function(prompt)
                local body = { prompt = prompt }
                return jsonEncode(body)
            end,
            parseResult = function(bodyText)
                local d = jsonDecode(bodyText) or {}
                return tostring(d.result or d.output or d.text or d.response or "")
            end
        }
    else
        -- default OpenAI Responses API shape: use Responses endpoint
        return {
            url = "https://api.openai.com/v1/responses",
            makeHeaders = function(key)
                return { ["Content-Type"] = "application/json", ["Authorization"] = "Bearer " .. key }
            end,
            makeBody = function(prompt)
                local preset = GPT_PRESETS[currentPresetGPT] or GPT_PRESETS.FREE
                local body = {
                    model = currentModel,
                    input = prompt,
                    max_tokens = preset.mt,
                    temperature = preset.t,
                }
                return jsonEncode(body)
            end,
            parseResult = function(bodyText)
                local d = jsonDecode(bodyText)
                if not d then return nil end
                -- try responses shape
                if d.output and d.output[1] and d.output[1].content then
                    for _, item in ipairs(d.output[1].content) do
                        if item.type == "output_text" and item.text then return item.text end
                    end
                end
                if d.choices and d.choices[1] and d.choices[1].message and d.choices[1].message.content then
                    return d.choices[1].message.content
                end
                if d.results and d.results[1] and d.results[1].output then
                    -- older shape fallback
                    local parts = d.results[1].output[1].content or {}
                    for _,p in ipairs(parts) do
                        if p.type == "output_text" and p.text then return p.text end
                    end
                end
                return nil
            end
        }
    end
end

-- ========== askAI (single entry) ==========
local function detectProviderFromKey(key)
    if tostring(key):match("^sk%-") then return "openai" end
    if tostring(key):match("^AIza") then return "google" end
    if tostring(key):match("^AI") or tostring(key):match("^AIz") then return "gemini" end
    -- simple heuristics: default openai
    return "openai"
end

local function askAI(prompt, onSuccess, onError)
    if not currentProvider or not currentApiKey then
        if onError then pcall(onError, "no_key") end
        safeTxt(user.Error, "No API key configured. Use /addapi or paste & Confirm.", 255,0,0)
        return
    end
    local epi = endpointsFor(currentProvider)
    if not epi or not epi.url then
        if onError then pcall(onError, "no_endpoint") end
        safeTxt(user.Error, "No endpoint for provider: " .. tostring(currentProvider), 255,0,0)
        return
    end

    local headers = epi.makeHeaders(currentApiKey)
    local body = epi.makeBody(prompt)

    enqueueRequest({
        url = epi.url,
        method = "POST",
        headers = headers,
        body = body,
        onSuccess = function(bodyText, resp)
            local out = nil
            local ok, parsed = pcall(function() return epi.parseResult(bodyText) end)
            if ok then out = parsed end
            if not out then
                -- fallback: raw body
                out = tostring(bodyText)
            end
            if onSuccess then pcall(onSuccess, out) end
        end,
        onError = function(errBody, resp)
            if onError then pcall(onError, tostring(errBody) or "request_failed") end
        end
    })
end

-- ========== COMMANDS ==========
local HELP_TEXT = [=[
/Help - show commands
/Cal or /Calculate [expr] - safe math
/ClearText - clear chat logs
/AddAPI [ChatGPT/Gemini/custom] [API or URL] [APIKEY(if custom)] [yes/no]
/UnsaveAPI or /UnApi - remove key
/OpenWebsiteInExperience or /OWINE [URL] - open site
/Loadstring [URL] - loadstring(url)()
/Script [[CODE]] - run code
/Debug [on/off] - show debug logs
/CheckHTTP - check executor http
/CheckURLStatus [URL] - HEAD request to URL
/CheckSYN - check syn.request availability
/EnableUSLD - enable unknown-language debug printing
/GPTSwitch [FREE/PRO/PLUS]
/GEMINISwitch [FREE/PRO/PLUS]
/ResetRateLimit or /ReRateLimit - resets local queue/backoff
/DumpStatus - prints current state
/InstanceTool ("NAME") ([sizeX,sizeY,sizeZ]) [MESHID] [TEXTUREID] [MESHOFFSETX,MESHOFFSETY,MESHOFFSETZ] [R,G,B] [TOOLIMAGE] [[CODE]]
/GlobalChat [ON/OFF] - stream global chat (client-side view only)
/SpyChat [ON/OFF] - stream whisper messages (client-side view only)
]=]

local function clearChatLogs()
    if si and si.GetChildren then
        for _,v in ipairs(si:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
    end
end

local function calculate(expr)
    if not expr or expr == "" then return nil, "empty" end
    -- simple safety: allow digits and math symbols only
    if expr:match("[^%d%+%-%*/%%%^%(%)%.%s]") then
        -- there may be variables like x - skip for safety
        -- attempt to run with pcall to catch errors
    end
    local fn, err = loadstring("return " .. expr)
    if not fn then return nil, err end
    local ok, res = pcall(fn)
    if not ok then return nil, res end
    return res
end

-- instance tool helper (creates a Tool under Backpack)
local function createInstanceTool(argsStr)
    -- expected args: ("Name") (x,y,z) meshId textureId offsetX,offsetY,offsetZ R,G,B imageId [[code]]
    -- parsing will be basic; user must format correctly
    local ok, err = pcall(function()
        -- find name in quotes
        local name = argsStr:match('%("([^"]+)"%)') or argsStr:match("%('([^']+)'%)")
        if not name then error("Name must be in parentheses and quotes: (\"Sword\")") end
        -- size table
        local sizeStr = argsStr:match("%(%s*([%d%.%s,%-]+)%s*%)")
        -- we will fallback to Vector3.new(1,1,1) if not found
        local size = Vector3.new(1,1,1)
        if sizeStr then
            local a,b,c = sizeStr:match("([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)")
            if a and b and c then size = Vector3.new(tonumber(a), tonumber(b), tonumber(c)) end
        end
        local tool = Instance.new("Tool")
        tool.Name = name
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = size
        handle.Color = Color3.fromRGB(180,180,180)
        handle.Parent = tool
        tool.Parent = lp.Backpack
        safeTxt(user.Suc, "Tool created: "..tostring(name), 0,255,0)
    end)
    if not ok then safeTxt(user.Error, "InstanceTool error: "..tostring(err), 255,0,0) end
end

-- global chat spying placeholders (client-side only)
local GLOBAL_CHAT_ON = false
local SPY_CHAT_ON = false

local function handleCommand(msg)
    local lower = tostring(msg):lower()
    if lower:match("^/help") then
        safeTxt(user.Nill, "What is AI-OpenSource?", 180,180,180)
        for line in HELP_TEXT:gmatch("[^\n]+") do safeTxt(user.Nill, line, 180,180,180) end
        return true
    end
    if lower:match("^/cleartext") then clearChatLogs(); safeTxt(user.Suc, "Chat cleared", 0,255,0); return true end
    if lower:match("^/cal%s+") or lower:match("^/calculate%s+") then
        local expr = msg:match("^/%S+%s+(.+)$") or ""
        local res, err = calculate(expr)
        if not res then safeTxt(user.Error, "Math error: "..tostring(err),255,0,0) else safeTxt(user.Suc, "Result = "..tostring(res),0,255,0) end
        return true
    end
    if lower:match("^/addapi") then
        local parts = {}
        for w in msg:gmatch("%S+") do table.insert(parts, w) end
        if #parts < 3 then safeTxt(user.Error, "Usage: /addapi [ChatGPT/Gemini/custom] [API or URL] [APIKEY(if custom)] [yes/no]",255,0,0); return true end
        local name = parts[2]:lower()
        if name == "custom" then
            currentProvider = "custom"
            currentCustomUrl = parts[3]
            currentCustomAuth = parts[4] and parts[4] ~= "" and parts[4] or nil
            currentApiKey = currentCustomAuth
            safeTxt(user.Info, "Custom endpoint set (unsaved). Use /addapi custom <URL> <KEY> yes to save",0,170,255)
            return true
        else
            local provider = (name:match("chat") and "openai") or (name:match("gemini") and "gemini") or nil
            local key = parts[3]
            if not provider or not key then safeTxt(user.Error, "Usage: /addapi [ChatGPT/Gemini] [API] [yes/no]",255,0,0); return true end
            currentProvider = provider
            currentApiKey = key
            safeTxt(user.Info, "Key set (unconfirmed). Click Confirm or type /addapi ... yes to save",0,170,255)
            return true
        end
    end
    if lower:match("^/unsaveapi") or lower:match("^/unapi") then
        currentProvider = nil; currentApiKey = nil; currentCustomUrl = nil; currentCustomAuth = nil
        safeTxt(user.Info, "API unsaved", 0,170,255)
        if st and st:IsA("TextLabel") then pcall(function() st.Text = "No key" end) end
        return true
    end
    if lower:match("^/openwebsiteinexperience") or lower:match("^/owine") then
        local url = msg:match("^/%S+%s+(.+)$") or ""
        url = url:gsub("^%s+",""):gsub("%s+$","")
        if url == "" then safeTxt(user.Error, "Usage: /OpenWebsiteInExperience [URL]",255,0,0) return true end
        local ok, e = pcall(function()
            if GuiService and GuiService.OpenBrowserWindow then GuiService:OpenBrowserWindow(url)
            else if StarterGui and StarterGui.SetCore then StarterGui:SetCore("OpenBrowserWindow", url) else error("Service blocked") end end
        end)
        if ok then safeTxt(user.Suc, "Opened website: "..url,0,255,0) else safeTxt(user.Error, "OpenWebsite failed: "..tostring(e),255,0,0) end
        return true
    end
    if lower:match("^/loadstring") then
        local url = msg:match("^/%S+%s+(.+)$") or ""
        url = url:gsub("^%s+",""):gsub("%s+$","")
        if url == "" then safeTxt(user.Error, "Usage: /loadstring [URL]",255,0,0) return true end
        safeTxt(user.Sys, "Fetching loadstring...",255,90,0)
        local ok, res = pcall(function() return loadstring(game:HttpGet(url))() end)
        if ok then safeTxt(user.Suc, "loadstring executed",0,255,0) else safeTxt(user.Error, "loadstring error: "..tostring(res),255,0,0) end
        return true
    end
    if lower:match("^/script") then
        local code = msg:match("^/%S+%s+(.+)$") or ""
        if code == "" then safeTxt(user.Error, "Usage: /script [[CODE]]",255,0,0) return true end
        code = code:gsub("^%[%[",""):gsub("%]%]$","")
        safeTxt(user.Sys, "Executing script...",255,90,0)
        local fn, err = loadstring(code)
        if not fn then safeTxt(user.Error, "Compile error: "..tostring(err),255,0,0) else
            local ok, r = pcall(fn)
            if ok then safeTxt(user.Suc, "Script executed",0,255,0) else safeTxt(user.Error, "Runtime error: "..tostring(r),255,0,0) end
        end
        return true
    end
    if lower:match("^/debug%s+(on|off)") then
        local flag = msg:match("^/debug%s+(on|off)")
        DEBUG_MODE = (flag == "on")
        safeTxt(user.Suc, "Debug mode: "..tostring(DEBUG_MODE),0,255,0)
        return true
    end
    if lower:match("^/checkhttp") then
        safeTxt(user.Info, "Executor HTTP available: "..tostring(httpRequestFunc ~= nil), 0,170,255)
        return true
    end
    if lower:match("^/checkurlstatus") then
        local url = msg:match("^/%S+%s+(.+)$") or ""
        if url == "" then safeTxt(user.Error, "Usage: /CheckURLStatus [URL]",255,0,0) return true end
        local ok, res = pcall(function() return doRequest({Url = url, Method = "HEAD"}) end)
        if not ok then safeTxt(user.Error, "Request error: "..tostring(res),255,0,0) else safeTxt(user.Info, "URL status: "..tostring(res.StatusCode),0,170,255) end
        return true
    end
    if lower:match("^/checksyn") then
        safeTxt(user.Info, "syn.request available: "..tostring((syn and syn.request) and true or false),0,170,255)
        return true
    end
    if lower:match("^/enableusld") then
        safeTxt(user.Info, "USLD enabled (no-op here)",0,170,255)
        return true
    end
    if lower:match("^/gptswitch") then
        local choice = msg:match("^/gptswitch%s+(%S+)")
        if choice and GPT_PRESETS[choice:upper()] then
            currentPresetGPT = choice:upper()
            safeTxt(user.Suc, "GPT preset set: "..currentPresetGPT,0,255,0)
        else safeTxt(user.Error, "Usage: /GPTSwitch [FREE/PRO/PLUS]",255,0,0) end
        return true
    end
    if lower:match("^/geminiswitch") then
        local choice = msg:match("^/geminiswitch%s+(%S+)")
        if choice and GEMINI_PRESETS[choice:upper()] then
            currentPresetGemini = choice:upper()
            safeTxt(user.Suc, "Gemini preset set: "..currentPresetGemini,0,255,0)
        else safeTxt(user.Error, "Usage: /GEMINISwitch [FREE/PRO/PLUS]",255,0,0) end
        return true
    end
    if lower:match("^/resetratelimit") or lower:match("^/reratelimit") then
        requestQueue = {}
        isProcessingQueue = false
        safeTxt(user.Suc, "Rate limit queue reset",0,255,0)
        return true
    end
    if lower:match("^/dumpstatus") then
        safeTxt(user.Info, "Provider: "..tostring(currentProvider)..", Key present: "..tostring(currentApiKey ~= nil), 0,170,255)
        return true
    end
    if lower:match("^/instancetool") then
        local args = msg:sub(#"/instancetool "+1) -- quick, not perfect parse
        createInstanceTool(msg)
        return true
    end
    if lower:match("^/globalchat") then
        local t = msg:match("^/globalchat%s*(%S*)") or ""
        GLOBAL_CHAT_ON = (t:upper() == "ON")
        safeTxt(user.Suc, "GlobalChat: "..tostring(GLOBAL_CHAT_ON),0,255,0)
        return true
    end
    if lower:match("^/spychat") then
        local t = msg:match("^/spychat%s*(%S*)") or ""
        SPY_CHAT_ON = (t:upper() == "ON")
        safeTxt(user.Suc, "SpyChat: "..tostring(SPY_CHAT_ON),0,255,0)
        return true
    end

    return false
end

-- ========== UI HOOK & BIND (safe, replace old) ==========
local function hookUI(timeoutSeconds)
    timeoutSeconds = tonumber(timeoutSeconds) or 6
    local start = tick()
    local found = nil
    while tick() - start < timeoutSeconds do
        local menu = CoreGui:FindFirstChild("ExperienceSettings")
        if menu and menu:FindFirstChild("Menu") then
            local ao = menu.Menu:FindFirstChild("AIOpenSource") or menu.Menu:FindFirstChild("AI-OpenSource") or menu.Menu:FindFirstChild("AIOpen") or menu.Menu:FindFirstChild("ChatGPT")
            if ao then
                local frame = ao:FindFirstChild("Frame") or ao
                local textFrame = frame:FindFirstChild("Text") or frame:FindFirstChild("text") or frame
                local chatTB = (textFrame and (textFrame:FindFirstChild("chat") or textFrame:FindFirstChild("ch")))
                local sendBtn = (textFrame and (textFrame:FindFirstChild("Send") or textFrame:FindFirstChild("se")))
                local apiTB = (textFrame and (textFrame:FindFirstChild("api") or textFrame:FindFirstChild("API")))
                local chatLogs = ao:FindFirstChild("ChatLogs") or ao:FindFirstChildWhichIsA("ScrollingFrame") or frame:FindFirstChildWhichIsA("ScrollingFrame")
                local statusLabel = (textFrame and (textFrame:FindFirstChild("Status") or textFrame:FindFirstChild("status"))) or ao:FindFirstChild("Status")
                local confirmBtn = (textFrame and (textFrame:FindFirstChild("Confirm_api") or textFrame:FindFirstChild("Confirm_API")))
                local unsavedBtn = (textFrame and (textFrame:FindFirstChild("Unsaved_API") or textFrame:FindFirstChild("UnsavedApi")))

                if chatTB and sendBtn and chatLogs then
                    UI.root = ao
                    UI.textFrame = textFrame
                    UI.ch = chatTB
                    UI.se = sendBtn
                    UI.tb = apiTB
                    UI.si = chatLogs
                    UI.st = statusLabel
                    UI.con = confirmBtn
                    UI.con2 = unsavedBtn
                    found = true
                    break
                end
            end
        end
        -- fallback: search top-level ScreenGuis that look like Chat GPT
        for _,sg in ipairs(CoreGui:GetChildren()) do
            if sg:IsA("ScreenGui") then
                local maybe = sg:FindFirstChild("AIOpenSource") or sg:FindFirstChild("AIOpen") or sg:FindFirstChildWhichIsA("Frame")
                if maybe then
                    local frame = maybe:FindFirstChild("Frame") or maybe
                    local textFrame = frame:FindFirstChild("Text") or frame
                    local chatTB = textFrame:FindFirstChild("chat") or textFrame:FindFirstChild("ch")
                    local sendBtn = textFrame:FindFirstChild("Send") or textFrame:FindFirstChild("se")
                    local chatLogs = sg:FindFirstChild("ChatLogs") or frame:FindFirstChildWhichIsA("ScrollingFrame")
                    if chatTB and sendBtn and chatLogs then
                        UI.root = sg
                        UI.textFrame = textFrame
                        UI.ch = chatTB
                        UI.se = sendBtn
                        UI.tb = textFrame:FindFirstChild("api") or textFrame:FindFirstChild("API")
                        UI.si = chatLogs
                        UI.st = textFrame:FindFirstChild("Status")
                        UI.con = textFrame:FindFirstChild("Confirm_api")
                        UI.con2 = textFrame:FindFirstChild("Unsaved_API")
                        found = true
                        break
                    end
                end
            end
        end

        if found then break end
        task.wait(0.12)
    end

    if not found then
        safeTxt(user.Warn, "UI not found. Ensure path CoreGui.ExperienceSettings.Menu.AIOpenSource.Frame exists", 255,200,0)
        return false
    end

    -- bind locals
    ch = UI.ch; se = UI.se; tb = UI.tb; si = UI.si; st = UI.st; con = UI.con; con2 = UI.con2

    -- attach handlers
    local function setStatusText(s)
        if st and st:IsA("TextLabel") then pcall(function() st.Text = s end) else safeTxt(user.Nill, "[STATUS] "..s, 180,180,180) end
    end

    local function doConfirm()
        if not tb then safeTxt(user.Error, "API textbox not found",255,0,0); return end
        local key = tostring(tb.Text or ""):gsub("%s+","")
        if key == "" then safeTxt(user.Error, "API key empty",255,0,0); return end
        currentApiKey = key
        currentProvider = detectProviderFromKey(key)
        setStatusText("Connecting ("..tostring(currentProvider)..")")
        safeTxt(user.Info, "Key set (validating)...",0,170,255)
        task.spawn(function()
            task.wait(VALIDATION_DELAY)
            askAI("ping", function(answer)
                setStatusText("Connected")
                safeTxt(user.Suc, "API validated: connected",0,255,0)
            end, function(err)
                setStatusText("Invalid key")
                safeTxt(user.Error, "Validation failed: "..tostring(err),255,0,0)
            end)
        end)
    end

    local function doUnsaved()
        currentProvider = nil; currentApiKey = nil; currentCustomUrl = nil; currentCustomAuth = nil
        setStatusText("No key")
        safeTxt(user.Info, "API unsaved", 0,170,255)
    end

    local function sendFromUI()
        if not ch then return end
        local raw = tostring(ch.Text or ""):gsub("^%s+",""):gsub("%s+$","")
        if raw == "" then return end
        if raw == "/" then safeTxt(user.Warn, "Single '/' is not a command",255,200,0); ch.Text = ""; return end
        if raw:sub(1,1) == "/" then
            local ok, res = pcall(function() return handleCommand(raw) end)
            if not ok then safeTxt(user.Error, "Command error: "..tostring(res),255,0,0) end
            ch.Text = ""
            return
        end
        safeTxt(user.plr, raw, 255,255,255)
        ch.Text = ""
        askAI(raw, function(answer)
            safeTxt(user.chat, answer or "(no answer)", 85,255,255)
        end, function(err)
            safeTxt(user.Error, "AI request failed: "..tostring(err),255,0,0)
        end)
    end

    -- connect UI events
    if se and se:IsA("TextButton") then
        se.MouseButton1Click:Connect(sendFromUI)
    end
    if ch and ch:IsA("TextBox") then
        ch.FocusLost:Connect(function(enter) if enter then sendFromUI() end end)
    end
    if con and con:IsA("TextButton") then con.MouseButton1Click:Connect(doConfirm) end
    if con2 and con2:IsA("TextButton") then con2.MouseButton1Click:Connect(doUnsaved) end

    -- initial status
    if currentApiKey then setStatusText("Key present (unconfirmed)") else setStatusText("No key") end

    safeTxt(user.Suc, "UI hooked successfully", 0,255,0)
    return true
end

-- auto try hook once at load
task.spawn(function() hookUI(6) end)

-- ========== Optional periodic debug printing ==========
task.spawn(function()
    while true do
        if DEBUG_MODE then
            safeTxt(user.Info, ("QueueLen="..tostring(#requestQueue).." Provider="..tostring(currentProvider).." Key="..tostring(currentApiKey~=nil)), 0,170,255)
        end
        task.wait(8)
    end
end)

-- End of script
