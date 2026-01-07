-- gpt 3.98

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

txt(user.Nill, "Nothing is working! Please wait for the next update!", 180,180,180)
txt(user.Nill, "Version: Test 3.98 | © Copyright LighterCyan", 180, 180, 180)
txt(user.Warn, "Stop! For your safety, please do not share your API and avoid being stared at by people around you. Due to safety and privacy concerns, you confirm that you will use your API to continue using our AI-OpenSource or not? With respect.", 255, 255, 0)
txt(user.Info, "Use /help for more information or commands.", 0,170,255) txt(user.Nill, [=[
What is AI-OpenSource?
  AI-OpenSource is a tool for questioning to AIs (ChatGPT/Gemini) by putting API Key.
  
What AI model you using?
  We use gpt-4o-mini and gemini-2.5-flash
  
This is safe to put api key?
  Yes, this is safe to put your api key, but make sure do NOT share your api.
  
Available commands
  use /Help
]=], 180, 180, 180)
txt(user.Nill, "Welcome back Tester", 0, 255, 0)
txt(user.Nill, "[====== Chat ======]", 180, 180, 180)

-- ===========================
-- AI-OpenSource: Unified client script (finds existing UI, hooks commands, HTTP queue, OpenAI/Gemini)
-- Assumes: txt(user, text, R,G,B) exists and local 'user' table exists (see your setup).
-- Place as LocalScript. Uses executor HTTP (syn.request etc) if available.

-- ===== SERVICES & UTIL =====
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- safe printing to chat area
local function safeTxt(u, t, r,g,b)
    if type(txt) == "function" then
        pcall(txt, u, t, r or 255, g or 255, b or 255)
    end
end

-- debug mode flag & USLD (unknown-language debug)
local DEBUG_MODE = false
local USLD = false

-- ===== FIND UI (connect to existing GUI) =====
local function findChatUI(timeout)
    timeout = tonumber(timeout) or 5
    local startTime = tick()

    while tick() - startTime < timeout do
        local CoreGui = game:GetService("CoreGui")

        -- hard path (NO SCAN)
        local exp = CoreGui:FindFirstChild("ExperienceSettings")
        if exp then
            local menu = exp:FindFirstChild("Menu")
            if menu then
                local root = menu:FindFirstChild("AIOpenSource")
                if root then
                    -- main frame
                    local frame = root:FindFirstChild("Frame")

                    if frame then
                        -- Chat logs
                        local si = frame:FindFirstChild("ChatLogs")

                        -- Text container
                        local textFrame = frame:FindFirstChild("Text")

                        local ch, se, tb
                        if textFrame then
                            ch = textFrame:FindFirstChild("chat")
                            se = textFrame:FindFirstChild("Send")
                            tb = textFrame:FindFirstChild("api")
                        end

                        -- Status label (NOT si)
                        local st =
                            root:FindFirstChild("Status")
                            or root:FindFirstChild("Status", true)

                        -- API buttons
                        local con =
                            textFrame and textFrame:FindFirstChild("Confirm_api")
                            or root:FindFirstChild("Confirm_api", true)

                        local con2 =
                            textFrame and textFrame:FindFirstChild("Unsaved_API")
                            or root:FindFirstChild("Unsaved_API", true)

                        -- HARD REQUIREMENTS
                        if ch and se and si then
                            return {
                                root = root,
                                frame = frame,
                                textFrame = textFrame,

                                -- main
                                ch = ch,     -- TextBox (chat)
                                se = se,     -- Send button
                                tb = tb,     -- API TextBox

                                -- logs / status
                                si = si,     -- ChatLogs ONLY
                                st = st,     -- Status label

                                -- api buttons
                                con = con,   -- Confirm_api
                                con2 = con2  -- Unsaved_API
                            }
                        end
                    end
                end
            end
        end

        task.wait(0.1)
    end

    return nil
end

-- helper updateStatus (shows in st if present, else si)
local function updateStatus(text)
    if st and st:IsA("TextLabel") then
        pcall(function() st.Text = "Status: "..tostring(text) end)
    else
        safeTxt(user.Info, "Status: "..tostring(text), 0,170,255)
    end
end

-- ===== HTTP / EXECUTOR DETECTION & QUEUE =====
local httpRequestFunc = nil

local function detectHttp()
    if syn and syn.request then return syn.request end
    if request then return request end
    if http and http.request then return http.request end
    if http_request then return http_request end
    if fluxus and fluxus.request then return fluxus.request end
    return nil
end

httpRequestFunc = detectHttp()
if httpRequestFunc then
    safeTxt(user.Info, "Executor HTTP detected", 0,170,255)
else
    safeTxt(user.Warn, "Executor HTTP not available. API requests disabled.", 255,200,0)
end

-- wrapper doRequest that returns (ok, responseTable or errorString)
local function doRequest(req)
    -- req: table {Url, Method, Headers, Body}
    if not httpRequestFunc then error("Executor HTTP not available") end
    local ok, res = pcall(function()
        -- syn.request returns table {Success, StatusCode, Body, Headers}
        local r = httpRequestFunc(req)
        -- normalize
        if r then
            -- some functions return .Status or .StatusCode; Body or body
            local code = r.StatusCode or r.status or r.Status
            local body = r.Body or r.body or r.BodyText
            local headers = r.Headers or r.headers or r.headers or {}
            return {
                Success = (r.Success == nil and (code and code >= 200 and code < 400) or r.Success) or (code and code >= 200 and code < 400),
                StatusCode = code or (r.statusCode),
                Body = body,
                Raw = r,
                Headers = headers
            }
        else
            return { Success = false, StatusCode = 0, Body = tostring(r), Raw = r, Headers = {}}
        end
    end)
    if not ok then return false, tostring(res) end
    return true, res
end

-- request queue to avoid bursts and handle rate-limit
local rq = {}
local processing = false
local rateUntil = 0 -- epoch time until we can't send

local function enqueueRequest(req, onComplete)
    table.insert(rq, {req = req, cb = onComplete})
    if not processing then
        task.spawn(function()
            processing = true
            while #rq > 0 do
                local item = table.remove(rq, 1)
                local now = tick()
                if now < rateUntil then
                    task.wait(rateUntil - now)
                end
                -- send
                local ok, res = pcall(doRequest, item.req)
                if not ok then
                    if item.cb then pcall(item.cb, false, res) end
                else
                    -- handle 429 or Retry-After
                    if res.StatusCode == 429 or (res.StatusCode and res.StatusCode >= 500) then
                        local retry = 5
                        -- parse Retry-After / custom header
                        local ra = nil
                        if res.Headers then
                            ra = res.Headers["Retry-After"] or res.Headers["retry-after"] or res.Headers["X-RateLimit-Reset"]
                        end
                        if ra then
                            local num = tonumber(ra)
                            if num then retry = num end
                        end
                        -- set rateUntil and re-enqueue with delay
                        rateUntil = tick() + retry
                        safeTxt(user.Warn, "Rate-limited. Retry in "..tostring(math.ceil(retry)).."s", 255,200,0)
                        -- reinsert at front
                        table.insert(rq, 1, item)
                        task.wait(retry)
                    else
                        if item.cb then pcall(item.cb, true, res) end
                    end
                end
                task.wait(0.05)
            end
            processing = false
        end)
    end
end

-- ===== API ENDPOINTS / BODY BUILDERS / PARSERS =====
local currentProvider = nil -- "openai" or "gemini" or "custom"
local currentApiKey = nil
local currentModel = "gpt-4o-mini"
local currentCustomUrl = nil
local currentCustomAuth = nil

local function endpointsFor(provider)
    provider = provider or currentProvider or "openai"
    if provider == "gemini" then
        return {
            url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
            makeHeaders = function(key)
                return {
                    ["Content-Type"] = "application/json",
                    ["x-goog-api-key"] = key
                }
            end,
            -- try a few body shapes sequentially in send function
            -- parser:
            parseResult = function(bodyText)
                local ok, d = pcall(function() return HttpService:JSONDecode(bodyText) end)
                if not ok or not d then return nil, "decode_error" end
                -- common shapes
                if d.candidates and d.candidates[1] and d.candidates[1].content and d.candidates[1].content.parts then
                    return d.candidates[1].content.parts[1].text, d
                end
                if d.outputText then return d.outputText, d end
                -- try nested
                if d.results and d.results[1] and d.results[1].candidates and d.results[1].candidates[1] then
                    return d.results[1].candidates[1].content or d.results[1].candidates[1].message, d
                end
                return nil, d
            end
        }
    elseif provider == "openai" then
        return {
            url = "https://api.openai.com/v1/responses",
            makeHeaders = function(key)
                return {
                    ["Content-Type"] = "application/json",
                    ["Authorization"] = "Bearer " .. key
                }
            end,
            parseResult = function(bodyText)
                local ok, d = pcall(function() return HttpService:JSONDecode(bodyText) end)
                if not ok or not d then return nil, "decode_error" end
                if d.output and d.output[1] and d.output[1].content then
                    for _, item in ipairs(d.output[1].content) do
                        if item.type == "output_text" and item.text then return item.text, d end
                    end
                end
                if d.results and d.results[1] and d.results[1].output and d.results[1].output[1] and d.results[1].output[1].content then
                    local parts = d.results[1].output[1].content
                    for _,p in ipairs(parts) do
                        if p.type == "output_text" and p.text then return p.text, d end
                    end
                end
                -- fallback to choices
                if d.choices and d.choices[1] and d.choices[1].message then
                    local m = d.choices[1].message
                    if type(m) == "string" then return m, d end
                    if m.content then return m.content, d end
                end
                return nil, d
            end
        }
    else
        -- custom endpoint (user-provided)
        return {
            url = currentCustomUrl,
            makeHeaders = function(key)
                local h = { ["Content-Type"] = "application/json" }
                if currentCustomAuth then h["Authorization"] = "Bearer "..currentCustomAuth end
                return h
            end,
            parseResult = function(bodyText)
                local ok, d = pcall(function() return HttpService:JSONDecode(bodyText) end)
                if not ok then return bodyText, "raw" end
                -- try common fields
                if d.text then return d.text, d end
                if d.output then return d.output, d end
                return d, d
            end
        }
    end
end

-- helper to try multiple body shapes then parse
local function sendAIRequest(prompt, provider, apiKey, model, callback)
    provider = provider or currentProvider
    model = model or currentModel
    if not provider then return callback(false, "no_provider") end
    if provider == "custom" and not currentCustomUrl then return callback(false, "no_custom_url") end
    if provider ~= "custom" and (not apiKey or apiKey == "") then return callback(false, "no_key") end
    local ep = endpointsFor(provider)
    local headers = ep.makeHeaders(apiKey)
    local url = ep.url
    -- try multiple body shapes in order, stopping at first success
    local bodies = {}
    if provider == "gemini" then
        bodies = {
            HttpService:JSONEncode({input = { text = prompt }}),
            HttpService:JSONEncode({prompt = { text = prompt }}),
            HttpService:JSONEncode({instances = {{ content = prompt }}}),
            HttpService:JSONEncode({input = prompt})
        }
    elseif provider == "openai" then
        bodies = {
            HttpService:JSONEncode({model = model, input = prompt}),
            HttpService:JSONEncode({model = model, messages = {{role="user", content=prompt}}}),
            HttpService:JSONEncode({model = model, prompt = prompt})
        }
    else
        bodies = { HttpService:JSONEncode({input=prompt}) }
    end

    local tried = 0
    local function tryNext()
        tried = tried + 1
        if tried > #bodies then
            return callback(false, "no_valid_body")
        end
        local body = bodies[tried]
        local req = {
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = body
        }
        enqueueRequest(req, function(ok, res)
            if not ok then
                callback(false, res)
                return
            end
            if not res.Success then
                -- pass error body back for debugging (HTTP error)
                -- If 429/500 handled in queue already, but still return
                callback(false, res)
                return
            end
            -- parse
            local parsed, raw = ep.parseResult(res.Body or "")
            if parsed then
                callback(true, parsed, raw)
            else
                -- try next body shape
                tryNext()
            end
        end)
    end
    tryNext()
end

-- ===== API KEY persistence (simple local file via writefile/readfile if available) =====
local function saveApiKeyToFile(tbl)
    if type(writefile) ~= "function" then
        safeTxt(user.Warn, "writefile unavailable; not saved to disk", 255,180,0)
        return
    end
    local ok, e = pcall(function()
        writefile("AI_OpenSource_api.json", HttpService:JSONEncode(tbl))
    end)
    if not ok then safeTxt(user.Error, "Save failed: "..tostring(e), 255,0,0) end
end

local function loadApiKeyFromFile()
    if type(readfile) ~= "function" then return nil end
    local ok, content = pcall(function() return readfile("AI_OpenSource_api.json") end)
    if not ok then return nil end
    local ok2, tbl = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok2 then return nil end
    return tbl
end

-- try load saved
local saved = loadApiKeyFromFile()
if saved then
    currentProvider = saved.provider or currentProvider
    currentApiKey = saved.key or currentApiKey
    currentCustomUrl = saved.url or currentCustomUrl
    currentCustomAuth = saved.auth or currentCustomAuth
    if currentProvider then updateStatus("Key loaded (from file)") end
end

-- ===== KEY VALIDATION (background slow check) =====
local validating = false
local function validateKeyInBackground()
    if validating then return end
    validating = true
    task.spawn(function()
        -- take a bit of time to avoid triggering rate limit
        updateStatus("Connecting")
        safeTxt(user.Info, "Key set, validating in background (takes ~10-20s)...", 0,170,255)
        task.wait(2)
        local p = currentProvider or "openai"
        local k = currentApiKey
        if p == "custom" and not currentCustomUrl then
            updateStatus("No key")
            validating = false
            return
        end
        -- do a small test prompt
        local testPrompt = "Hello"
        local done = false
        local resultOk, resultData = false, nil
        sendAIRequest(testPrompt, p, k, nil, function(ok, data, raw)
            resultOk, resultData = ok, data
            done = true
        end)
        -- wait up to 20s
        local t0 = tick()
        while not done and (tick() - t0) < 20 do task.wait(0.25) end
        if resultOk then
            updateStatus("Connected ("..(p == "openai" and "ChatGPT" or p == "gemini" and "Gemini" or "custom")..")")
            safeTxt(user.Suc, (p == "openai" and "ChatGPT" or p == "gemini" and "Gemini" or "Custom").." key valid", 0,255,0)
        else
            updateStatus("Invalid key")
            safeTxt(user.Error, "Key validation failed: "..tostring(resultData), 255,0,0)
        end
        validating = false
    end)
end

-- ===== MESSAGE / COMMAND HANDLING =====
local HELP_TEXT = [=[
/Help - show commands
/Cal or /Calculate [expr] - safe math
/ClearText - clear chat logs
/AddAPI [ChatGPT/Gemini/custom] [API or URL] [APIKEY(if custom)] [yes/no] - add API quickly
/UnsaveAPI or /UnApi - remove key
/OpenWebsiteInExperience or /OWINE [URL] - open site
/Loadstring [URL] - loadstring(url)()
/Script [[CODE]] - run code
/Debug [on/off] - show debug logs
/CheckHTTP - check executor http availability
/CheckURLStatus [URL] - check website status (HEAD)
/CheckSYN - check syn.request availability
/EnableUSLD - enable unknown-language debug printing to logs
/InstanceTool ("NAME") ([PARTSIZE]) ([MESHID]) ([TEXTUREID]) ([MESHOFFSET]) ([COLOR3]) ([TOOLIMAGE]) [[CODE]]
]=]

local function clearChatLogs()
    if not si then return end
    for _,v in ipairs(si:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
end

local function calculate(expr)
    local ok, f = pcall(function() return loadstring("return "..expr) end)
    if not ok or not f then return nil, "invalid expression" end
    local suc, res = pcall(f)
    if not suc then return nil, res end
    return res
end

-- helper open website
local function openWebsiteInExperience(url)
    local ok, err = pcall(function()
        if GuiService and GuiService.OpenBrowserWindow then
            GuiService:OpenBrowserWindow(url)
        else
            if StarterGui and StarterGui.SetCore then
                StarterGui:SetCore("OpenBrowserWindow", url)
            else
                error("Service blocked")
            end
        end
    end)
    return ok, err
end

-- handleCommand returns true if handled
local function handleCommand(msg)
    if not msg then return false end
    local lower = tostring(msg):lower()
    if lower:match("^/help") then
        safeTxt(user.Nill, "What is AI-OpenSource?", 180,180,180)
        for line in HELP_TEXT:gmatch("[^\n]+") do safeTxt(user.Nill, line, 180,180,180) end
        return true
    end
    if lower:match("^/cleartext") then clearChatLogs(); safeTxt(user.Suc, "Chat cleared",0,255,0); return true end
    if lower:match("^/cal") or lower:match("^/calculate") then
        local expr = msg:match("^/%S+%s+(.+)$") or ""
        if expr == "" then safeTxt(user.Error, "Usage: /cal [expression]",255,0,0) return true end
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
            if parts[5] and parts[5]:lower() == "yes" then
                saveApiKeyToFile({provider="custom", url=currentCustomUrl, auth=currentCustomAuth, key=currentApiKey})
                updateStatus("Custom set (saved)")
                safeTxt(user.Suc, "Custom API saved",0,255,0)
            else
                updateStatus("Custom set (unsaved)")
                safeTxt(user.Info, "Custom endpoint set. Add 'yes' to save.",0,170,255)
            end
            validateKeyInBackground()
            return true
        else
            local provider = (name:match("chat") and "openai") or (name:match("gemini") and "gemini") or nil
            if not provider then safeTxt(user.Error, "Unknown provider",255,0,0); return true end
            currentProvider = provider
            currentApiKey = parts[3]
            if parts[4] and parts[4]:lower() == "yes" then
                saveApiKeyToFile({provider=currentProvider, key=currentApiKey})
                updateStatus("Key set (saved)")
                safeTxt(user.Suc, "API set and saved",0,255,0)
            else
                updateStatus("Key set (unconfirmed)")
                safeTxt(user.Info, "Key set. Use confirm to validate or /addapi ... yes to save.",0,170,255)
            end
            validateKeyInBackground()
            return true
        end
    end
    if lower:match("^/unsaveapi") or lower:match("^/unapi") then
        currentProvider = nil; currentApiKey = nil; currentCustomUrl = nil; currentCustomAuth = nil
        if type(writefile) == "function" then pcall(function() delfile("AI_OpenSource_api.json") end) end
        updateStatus("Unsave key")
        safeTxt(user.Warn, "API key removed",255,255,0)
        return true
    end
    if lower:match("^/openwebsiteinexperience") or lower:match("^/owine") then
        local url = msg:match("^/%S+%s+(.+)$") or ""
        url = url:gsub("^%s+",""):gsub("%s+$","")
        if url == "" then safeTxt(user.Error, "Usage: /OpenWebsiteInExperience [URL]",255,0,0); return true end
        local ok,e = openWebsiteInExperience(url)
        if ok then safeTxt(user.Suc, "Opened website: "..url,0,255,0) else safeTxt(user.Error, "OpenWebsite failed: "..tostring(e),255,0,0) end
        return true
    end
    if lower:match("^/loadstring") then
        local url = msg:match("^/%S+%s+(.+)$") or ""
        if url == "" then safeTxt(user.Error, "Usage: /loadstring [URL]",255,0,0); return true end
        safeTxt(user.Sys, "Fetching loadstring...",255,90,0)
        local ok, res = pcall(function() return loadstring(game:HttpGet(url))() end)
        if ok then safeTxt(user.Suc, "loadstring executed",0,255,0) else safeTxt(user.Error, "loadstring error: "..tostring(res),255,0,0) end
        return true
    end
    if lower:match("^/script") then
        local code = msg:match("^/%S+%s+(.+)$") or ""
        if code == "" then safeTxt(user.Error, "Usage: /script [[CODE]]",255,0,0); return true end
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
    if lower:match("^/checkhttp") then safeTxt(user.Info, "Executor HTTP available: "..tostring(httpRequestFunc ~= nil), 0,170,255); return true end
    if lower:match("^/checkurlstatus") then
        local url = msg:match("^/%S+%s+(.+)$") or ""
        url = url:gsub("^%s+",""):gsub("%s+$","")
        if url == "" then safeTxt(user.Error, "Usage: /CheckURLStatus [URL]",255,0,0) return true end
        local ok, res = pcall(doRequest, {Url=url, Method="HEAD"})
        if not ok then safeTxt(user.Error, "Request error: "..tostring(res),255,0,0) else safeTxt(user.Info, "URL status: "..tostring(res.StatusCode or "nil"),0,170,255) end
        return true
    end
    if lower:match("^/checksyn") then safeTxt(user.Info, "syn.request available: "..tostring((syn and syn.request) and true or false),0,170,255); return true end
    if lower:match("^/enableusld") then USLD = true; safeTxt(user.Info, "USLD enabled",0,170,255); return true end

    -- InstanceTool :
    if lower:match("^/instancetool") then
        -- format: /InstanceTool ("Name") (x,y,z) mesh texture (ox,oy,oz) (r,g,b) image [[CODE]]
        local argsStr = msg:match("^/%S+%s+(.+)$") or ""
        -- simple parsing: find "..." for name, [[...]] for code, then numbers
        local name = argsStr:match('%"([^%"]+)%"') or argsStr:match("%(([^%)]+)%)") or "Tool"
        local code = argsStr:match("%[%[(.-)%]%]") -- optional
        -- numbers sequence
        local nums = {}
        for n in argsStr:gmatch("([%-]?%d+%.?%d*)") do table.insert(nums, tonumber(n)) end
        -- assign defaults
        local partSize = Vector3.new(1,1,1)
        local meshId, texId, offX,offY,offZ = nil,nil,0,0,0
        local color3 = Color3.fromRGB(255,255,255)
        local toolImageId = nil
        if #nums >= 3 then partSize = Vector3.new(nums[1], nums[2], nums[3]) end
        if #nums >= 4 then meshId = tostring(nums[4]) end
        if #nums >= 5 then texId = tostring(nums[5]) end
        if #nums >= 8 then offX,offY,offZ = nums[6],nums[7],nums[8] end
        if #nums >= 11 then color3 = Color3.fromRGB(nums[9],nums[10],nums[11]) end
        if #nums >= 12 then toolImageId = tostring(nums[12]) end

        -- create tool in Backpack
        local ok, err = pcall(function()
            local tool = Instance.new("Tool")
            tool.Name = name
            local handle = Instance.new("Part")
            handle.Name = "Handle"
            handle.Size = partSize
            handle.Color = color3
            handle.Parent = tool
            if meshId then
                local mesh = Instance.new("SpecialMesh", handle)
                mesh.MeshId = "rbxassetid://"..meshId
                mesh.Offset = Vector3.new(offX or 0, offY or 0, offZ or 0)
                if texId then mesh.TextureId = "rbxassetid://"..texId end
            end
            if toolImageId then
                pcall(function() tool.TextureId = "rbxassetid://"..toolImageId end)
            end
            -- add local script if code present
            if code and code ~= "" then
                local ls = Instance.new("LocalScript")
                ls.Name = "InstanceToolScript"
                ls.Source = code
                ls.Parent = tool
            end
            -- parent to Backpack (client-local)
            local bp = LocalPlayer:WaitForChild("Backpack", 5)
            if bp then tool.Parent = bp else tool.Parent = workspace end
        end)
        if ok then safeTxt(user.Suc, "InstanceTool created: "..tostring(name),0,255,0) else safeTxt(user.Error, "InstanceTool error: "..tostring(err),255,0,0) end
        return true
    end

    if lower:match("^/globalchat") then
        safeTxt(user.Warn, "GlobalChat needs server access. This client stub cannot fetch server chat.", 255,200,0)
        return true
    end
    if lower:match("^/spychat") then
        safeTxt(user.Warn, "SpyChat needs server access (private messages). Client stub only.",255,200,0)
        return true
    end

    return false
end

-- ===== send to AI / message dispatch =====
local function askAI(prompt, onSuccess, onError)
    if not currentProvider then
        if onError then onError("Not connected to any API. Use Confirm API or /addapi") end
        return
    end
    if not httpRequestFunc then
        if onError then onError("HTTP unavailable (executor)") end
        return
    end
    sendAIRequest(prompt, currentProvider, currentApiKey, currentModel, function(ok, data, raw)
        if ok then
            if onSuccess then pcall(onSuccess, tostring(data)) end
        else
            if onError then pcall(onError, tostring(data)) end
        end
    end)
end

-- ===== UI hooking: connect buttons, textbox events =====
if se and se:IsA("GuiButton") then
    se.MouseButton1Click:Connect(function()
        local m = (ch and tostring(ch.Text or "")) or ""
        m = m:gsub("^%s+",""):gsub("%s+$","")
        if m == "" then return end
        -- command?
        if m:sub(1,1) == "/" then
            local handled = handleCommand(m)
            if not handled then safeTxt(user.Error, "Unknown command. Type /help",255,0,0) end
            if ch then ch.Text = "" end
            return
        end
        -- normal chat
        safeTxt(user.plr, m, 255,255,255)
        -- show pending AI
        safeTxt(user.chat, "(AI thinking...)", 85,255,255)
        -- send
        askAI(m, function(ans)
            safeTxt(user.chat, ans, 85,255,255)
        end, function(err)
            safeTxt(user.Error, "AI request failed: "..tostring(err), 255,0,0)
        end)
        if ch then ch.Text = "" end
    end)
end

if ch and ch:IsA("TextBox") then
    ch.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local m = tostring(ch.Text or "")
            m = m:gsub("^%s+",""):gsub("%s+$","")
            if m == "" then return end
            if m:sub(1,1) == "/" then
                local handled = handleCommand(m)
                if not handled then safeTxt(user.Error, "Unknown command. Type /help",255,0,0) end
                ch.Text = ""
                return
            end
            safeTxt(user.plr, m, 255,255,255)
            safeTxt(user.chat, "(AI thinking...)", 85,255,255)
            askAI(m, function(ans) safeTxt(user.chat, ans, 85,255,255) end, function(err) safeTxt(user.Error, "AI request failed: "..tostring(err),255,0,0) end)
            ch.Text = ""
        end
    end)
end

-- Confirm API / Unsaved API bindings (if tb + buttons exist)
-- We'll try to find Confirm_api and Unsaved_API under the same text frame or root
local function bindConfirmButtons()
    local root = ui and ui.root
    if not root then return end
    local confirmBtn = root:FindFirstChild("Confirm_api") or root:FindFirstChild("Confirm_API") or (ui.textFrame and ui.textFrame:FindFirstChild("Confirm_api"))
    local unsaveBtn = root:FindFirstChild("Unsaved_API") or root:FindFirstChild("Unsaved_API") or (ui.textFrame and ui.textFrame:FindFirstChild("Unsaved_API"))
    if confirmBtn and confirmBtn:IsA("GuiButton") then
        confirmBtn.MouseButton1Click:Connect(function()
            if tb and tb:IsA("TextBox") then
                local key = tostring(tb.Text or "")
                if key == "" then safeTxt(user.Warn, "API textbox empty",255,255,0); return end
                currentApiKey = key
                -- provider detection heuristics
                if key:match("^sk%-") or key:match("^sk_") or key:match("^eyJ") then
                    currentProvider = "openai"
                elseif key:match("^AI") or key:match("^AIza") or key:match("^sk_proj") or #key > 40 then
                    currentProvider = "gemini" -- heuristic
                else
                    currentProvider = currentProvider or "openai"
                end
                updateStatus("Connecting")
                validateKeyInBackground()
            else
                safeTxt(user.Error, "API textbox not found",255,0,0)
            end
        end)
    end
    if unsaveBtn and unsaveBtn:IsA("GuiButton") then
        unsaveBtn.MouseButton1Click:Connect(function()
            currentProvider = nil; currentApiKey = nil; currentCustomUrl = nil; currentCustomAuth = nil
            if type(writefile) == "function" then pcall(function() delfile("AI_OpenSource_api.json") end) end
            updateStatus("Unsave key")
            safeTxt(user.Warn, "API key removed",255,255,0)
        end)
    end
end

bindConfirmButtons()

-- ===== initial info display =====
if si then
    safeTxt(user.Info, "Information: API: "..tostring(currentProvider or "<none>"), 0,170,255)
    safeTxt(user.Info, "Information: HTTP func: "..tostring(httpRequestFunc ~= nil), 0,170,255)
    if currentProvider and currentApiKey then validateKeyInBackground() end
end

-- ===== final notes / debug print =====
if DEBUG_MODE then safeTxt(user.Info, "Debug mode ON", 0,170,255) end
if USLD then safeTxt(user.Info, "USLD ON", 0,170,255) end

-- script ready
safeTxt(user.Suc, "AI-OpenSource script active", 0,255,0)
updateStatus("Ready")

-- End of script
