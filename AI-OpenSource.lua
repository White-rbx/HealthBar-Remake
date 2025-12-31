-- gpt 3.61

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
txt(user.Nill, "Version: Test 3.61 | © Copyright LighterCyan", 180, 180, 180)
txt(user.Warn, "Stop! For your safety, please do not share your API and avoid being stared at by people around you. Due to safety and privacy concerns, you confirm that you will use your API to continue using our AI-OpenSource or not? With respect.", 255,255,0)
txt(user.Nill, "[====== Chat ======]", 180, 180, 180)

-- <<== AI HTTP + Queue + UI binding (paste at end of your existing UI script) ==>>

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Config
local REQUEST_MIN_DELAY = 1.0         -- minimum seconds between requests (helps avoid 429)
local MAX_RETRIES = 4                 -- exponential backoff retries
local BACKOFF_BASE = 1.2              -- multiplier
local skipValidation = false          -- set true to skip a preliminary key validation (fewer requests)

-- Find UI root (tolerant)
local ok, Menu = pcall(function()
    return CoreGui:WaitForChild("ExperienceSettings", 6).Menu
end)

if not ok or not Menu then
    warn("[AI] ExperienceSettings.Menu not found")
    return
end

local root = Menu:FindFirstChild("AIOpenSource") or Menu:FindFirstChild("AI-OpenSource")
             or Menu:FindFirstChild("ChatGPT") or Menu:FindFirstChild("gpt") or Menu

-- helper to find descendant by name (case-sensitive)
local function findDesc(name)
    for _, v in ipairs(root:GetDescendants()) do
        if v.Name == name then return v end
    end
    return nil
end

-- expected existing elements (you said these already exist)
local apiBox     = findDesc("api")           -- TextBox for API key
local confirmBtn = findDesc("Confirm_api")  -- confirm button
local unsaveBtn  = findDesc("Unsaved_API")  -- unsave button
local statusLbl  = findDesc("Status")       -- TextLabel for status
local chatBox    = findDesc("chat")         -- chat TextBox (input)
local sendBtn    = findDesc("Send")         -- send button
local chatLogs   = findDesc("ChatLogs")     -- ScrollingFrame where txt() puts messages

-- verify elements
if not chatBox or not sendBtn or not chatLogs or not apiBox or not statusLbl then
    warn("[AI] Required UI elements missing. Found:",
         "apiBox", tostring(apiBox),
         "confirmBtn", tostring(confirmBtn),
         "unsaveBtn", tostring(unsaveBtn),
         "chatBox", tostring(chatBox),
         "sendBtn", tostring(sendBtn),
         "chatLogs", tostring(chatLogs),
         "statusLbl", tostring(statusLbl))
    -- we continue but will fail gracefully
end

-- you already have txt(user, text, r,g,b) and user table
-- check presence:
if not txt or not type(txt) == "function" then
    warn("[AI] txt(user, text, r,g,b) not found in environment. Please ensure it exists.")
end

-- find available http function (executor)
local httpRequest = nil
if syn and syn.request then
    httpRequest = syn.request
elseif request then
    httpRequest = request
elseif http and http.request then
    httpRequest = http.request
elseif fluxus and fluxus.request then
    httpRequest = fluxus.request
elseif _G and _G.request then
    httpRequest = _G.request
end

if not httpRequest then
    warn("[AI] No executor http found (syn.request / request / http.request). HTTP will not work.")
end

-- convenience JSON helpers
local function jsonEncode(t) return HttpService:JSONEncode(t) end
local function jsonDecode(s)
    local ok, res = pcall(function() return HttpService:JSONDecode(s) end)
    if ok then return res end
    return nil, res
end

-- stored key & provider
local STATE = {
    apiKey = nil,
    provider = nil,    -- "openai" or "google" (gemini)
    model = nil,       -- optional model selection
    connected = false
}

local function setStatus(text)
    if statusLbl and statusLbl.SetAttribute then
        -- prefer using text property
    end
    if statusLbl and statusLbl:IsA("TextLabel") then
        statusLbl.Text = "Status: " .. tostring(text)
    end
end

-- detect provider by key prefix (heuristic)
local function detectProvider(key)
    if not key or key == "" then return nil end
    -- common OpenAI prefix: sk- or sk_proj...
    if string.match(key, "^sk%-") or string.match(key, "^sk_pro") then
        return "openai"
    end
    -- Google API keys (simple heuristic): "AIza"
    if string.match(key, "^AIza") then
        return "google"
    end
    -- fallback: if user wrote "gemini" or "google" in box
    local low = tostring(key):lower()
    if low:find("gemini") or low:find("google") then return "google" end
    return "openai" -- default to openai
end

-- choose endpoints per provider
local function endpointsFor(provider)
    if provider == "google" then
        -- Gemini (v1beta generateContent)
        return {
            url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent",
            headers = function(key)
                return {
                    ["Content-Type"] = "application/json",
                    ["x-goog-api-key"] = key
                }
            end,
            makeBody = function(prompt)
                return jsonEncode({
                    contents = {
                        {
                            role = "user",
                            parts = {
                                { text = tostring(prompt) }
                            }
                        }
                    }
                })
            end
        }
    else
        -- OpenAI (Responses API)
        return {
            url = "https://api.openai.com/v1/responses",
            headers = function(key)
                return {
                    ["Content-Type"] = "application/json",
                    ["Authorization"] = "Bearer " .. key
                }
            end,
            makeBody = function(prompt, model)
                return jsonEncode({
                    model = model or "gpt-4o-mini",
                    input = tostring(prompt)
                })
            end
        }
    end
end

-- request queue (one-in-flight)
local queue = {}
local processing = false

local function enqueueRequest(opts)
    -- opts: {provider, url, headers, body, onSuccess(respBody), onError(err)}
    table.insert(queue, opts)
    if not processing then
        processing = true
        task.spawn(function()
            while #queue > 0 do
                local item = table.remove(queue, 1)
                local attempt = 0
                local delayNext = REQUEST_MIN_DELAY
                local lastErr = nil
                while attempt <= MAX_RETRIES do
                    attempt = attempt + 1
                    -- perform request
                    local success, response = pcall(function()
                        return httpRequest({
                            Url = item.url,
                            Method = item.method or "POST",
                            Headers = item.headers,
                            Body = item.body,
                            -- Some executors expect 'Body' or 'body'
                        })
                    end)
                    if not success then
                        lastErr = response
                        -- network-like error -> backoff
                        local back = math.pow(BACKOFF_BASE, attempt)
                        task.wait(back)
                        continue
                    end

                    -- got response
                    local res = response
                    local statusCode = tonumber(res.StatusCode) or tonumber(res.status) or 0
                    if statusCode == 200 or statusCode == 201 or statusCode == 204 then
                        -- success
                        if type(item.onSuccess) == "function" then
                            local body = res.Body or res.body or ""
                            item.onSuccess(body, res)
                        end
                        break
                    elseif statusCode == 429 then
                        -- rate-limited; check Retry-After
                        local retryAfter = nil
                        -- try common headers
                        local headers = res.Headers or res.headers or {}
                        retryAfter = tonumber(headers["Retry-After"] or headers["retry-after"]) or retryAfter
                        local back = retryAfter or (math.pow(BACKOFF_BASE, attempt))
                        task.wait(back)
                        lastErr = "HTTP 429"
                        -- continue to retry
                    elseif statusCode >= 500 then
                        -- server error - backoff
                        local back = math.pow(BACKOFF_BASE, attempt)
                        task.wait(back)
                        lastErr = "HTTP "..tostring(statusCode)
                    else
                        -- other client error (e.g., 401 invalid key)
                        if type(item.onError) == "function" then
                            local body = res.Body or res.body or ""
                            item.onError(statusCode, body, res)
                        end
                        lastErr = "HTTP "..tostring(statusCode)
                        break
                    end
                end -- retry loop

                -- small gap between queued requests to be nice
                task.wait(REQUEST_MIN_DELAY)
            end -- queue loop
            processing = false
        end)
    end
end

-- high-level send functions for OpenAI and Gemini
local function sendOpenAI(apiKey, prompt, onSuccess, onError, model)
    local ep = endpointsFor("openai")
    local body = ep.makeBody(prompt, model)
    local headers = ep.headers(apiKey)
    enqueueRequest({
        url = ep.url,
        method = "POST",
        headers = headers,
        body = body,
        onSuccess = function(bodyText, resp)
            local decoded, err = jsonDecode(bodyText)
            if not decoded then
                if onError then onError("decode", bodyText) end
                return
            end
            -- Responses API: decoded.output_text or decoded.choices
            local out = nil
            if decoded.output and decoded.output[1] and decoded.output[1].content then
                out = ""
                for _, part in ipairs(decoded.output) do
                    if part.content and part.content[1] and part.content[1].text then
                        out = out .. tostring(part.content[1].text)
                    end
                end
            end
            -- fallback
            if not out then
                if decoded.choices and decoded.choices[1] and decoded.choices[1].message and decoded.choices[1].message.content then
                    local c = decoded.choices[1].message.content
                    if type(c) == "string" then out = c end
                    if type(c) == "table" then out = c[1] end
                end
            end
            onSuccess(out or "(no text)", decoded)
        end,
        onError = onError
    })
end

-- ส่งคำขอไปยัง Gemini (Google Generative Language)
local HttpService = game:GetService("HttpService")
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request

-- ใช้ enqueueRequest ถ้ามี (ผู้ใช้เก่าของคุณอาจมีคิว)
local hasEnqueue = type(enqueueRequest) == "function"

local function sendGemini(apiKey, prompt, onSuccess, onError)
    if not apiKey or apiKey == "" then
        if onError then onError("no_key") end
        return
    end

    local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
    local headers = {
        ["Content-Type"] = "application/json",
        ["x-goog-api-key"] = apiKey
    }

    -- ปรับ body ให้เป็นตาราง Lua ถูกต้อง (รูปแบบตัวอย่าง — ปรับตาม API จริงได้)
    local bodyTable = {
        prompt = {
            sections = {
                { type = "text", text = tostring(prompt) }
            }
        },
        temperature = 0.2
    }

    local body = HttpService:JSONEncode(bodyTable)

    local function handleResponse(res, attempt)
        attempt = attempt or 1
        if not res then
            if onError then onError("no_response") end
            return
        end

        -- 200 OK
        if res.StatusCode == 200 or res.StatusCode == 201 then
            local ok, decoded = pcall(function() return HttpService:JSONDecode(res.Body) end)
            if not ok then
                if onError then onError("decode_error", res.Body) end
                return
            end

            -- พยายามดึงข้อความจากรูปแบบที่ต่างกัน
            local out = nil
            -- รูปแบบ: { candidates = { { content = { parts = { { text = "..." } } } } } }
            if decoded.candidates and decoded.candidates[1] and decoded.candidates[1].content and decoded.candidates[1].content.parts then
                out = decoded.candidates[1].content.parts[1].text
            end
            -- รูปแบบอื่น ๆ (บาง API ใช้ generations)
            if (not out) and decoded.generations and decoded.generations[1] then
                out = decoded.generations[1].text or decoded.generations[1].content
            end

            if onSuccess then onSuccess(out or "(no text)", decoded) end
            return
        end

        -- Rate limit: retry แบบ exponential backoff (เบา ๆ)
        if res.StatusCode == 429 then
            if attempt < 4 then
                local waitTime = 0.8 * attempt
                task.wait(waitTime)
                -- รีส่ง (โดยเรียก request ใหม่จากภายนอก)
                return nil, "retry"  -- caller (doRequest) จะจัดการ retry
            else
                if onError then onError("rate_limited", res) end
                return
            end
        end

        -- ข้อผิดพลาด HTTP อื่น ๆ
        if onError then onError("http_error", res) end
    end

    -- ส่งจริง (รองรับ enqueueRequest หรือ ส่งทันทีผ่าน executor)
    local function doRequest(attempt)
        attempt = attempt or 1

        if hasEnqueue then
            -- ถ้ามี enqueueRequest (user code) ให้ใช้มัน (สมมติ signature: table)
            enqueueRequest({
                url = url,
                method = "POST",
                headers = headers,
                body = body,
                onSuccess = function(bodyText, resp)
                    -- สร้าง fake response object ให้เข้ารูป
                    local fakeRes = { StatusCode = 200, Body = bodyText }
                    handleResponse(fakeRes, attempt)
                end,
                onError = function(err)
                    if attempt < 4 then
                        task.wait(0.6 * attempt)
                        doRequest(attempt + 1)
                    else
                        if onError then onError("enqueue_error", err) end
                    end
                end
            })
        else
            -- ส่งด้วย executor httpRequest
            local ok, res = pcall(function()
                return httpRequest({
                    Url = url,
                    Method = "POST",
                    Headers = headers,
                    Body = body
                })
            end)

            if not ok then
                if attempt < 4 then
                    task.wait(0.6 * attempt)
                    return doRequest(attempt + 1)
                else
                    if onError then onError("request_failed", res) end
                    return
                end
            end

            -- handle 429 retry loop here
            if res.StatusCode == 429 and attempt < 4 then
                task.wait(0.8 * attempt)
                return doRequest(attempt + 1)
            end

            handleResponse(res, attempt)
        end
    end

    -- เริ่มส่ง (ไม่บล็อก)
    task.spawn(function() doRequest(1) end)
end

-- ตัวอย่างการเรียกใช้:
-- sendGemini(apiKey, "Hello world", function(text, raw) print("OK:", text) end, function(err, info) warn("ERR:", err, info) end)

-- validate key (lightweight): send a tiny prompt and interpret response
local function validateKey(apiKey, provider, onOk, onFail)
    if skipValidation then
        if onOk then onOk() end
        return
    end
    setStatus("Connecting")
    local prompt = "Ping"
    local cbOk = function(text)
        setStatus("Connected")
        if onOk then onOk() end
    end
    local cbFail = function(code, body)
        setStatus("Invalid key")
        if onFail then onFail(code, body) end
    end

    if provider == "google" then
        -- call gemini minimal
        sendGemini(apiKey, "hello", cbOk, cbFail)
    else
        sendOpenAI(apiKey, "hello", cbOk, cbFail, "gpt-4o-mini")
    end
end

-- connect UI buttons (confirm, unsave)
if confirmBtn then
    confirmBtn.MouseButton1Click:Connect(function()
        local key = (apiBox and apiBox.Text) and tostring(apiBox.Text)
        if not key or key == "" then
            setStatus("No key")
            if txt then txt(user.Error, "API key empty", 255,0,0) end
            return
        end
        local provider = detectProvider(key)
        STATE.apiKey = key
        STATE.provider = provider
        setStatus("Connecting")
        -- validate
        validateKey(key, provider, function()
            STATE.connected = true
            setStatus("Connected (" .. provider .. ")")
            if txt then txt(user.Suc, "API connected ("..provider..")", 0,255,0) end
        end, function(code, body)
            STATE.connected = false
            setStatus("Invalid key")
            if txt then txt(user.Error, "Invalid API key", 255,0,0) end
        end)
    end)
end

if unsaveBtn then
    unsaveBtn.MouseButton1Click:Connect(function()
        STATE.apiKey = nil
        STATE.provider = nil
        STATE.connected = false
        setStatus("Unsave key")
        if txt then txt(user.Info, "API key unsaved", 0,170,255) end
    end)
end

-- send message handler
local lastSendTick = 0
local function sendMessage(promptText)
    if not promptText or promptText:match("^%s*$") then return end
    if not STATE.apiKey then
        txt(user.Warn, "No API key. Press Confirm_api first.", 255,255,0)
        return
    end
    -- rate guard (local)
    if tick() - lastSendTick < 0.1 then
        -- tiny guard against accidental double clicks
        task.wait(0.1)
    end
    lastSendTick = tick()

    -- show user message
    if txt then txt(user.plr, promptText, 255,255,255) end

    -- callback for response
    local onOk = function(responseText, raw)
        if txt then txt(user.chat, responseText or "(no text)", 85,255,255) end
    end
    local onErr = function(code, body)
        if txt then txt(user.Error, "API error: "..tostring(code), 255,0,0) end
    end

    -- choose provider
    if STATE.provider == "google" then
        sendGemini(STATE.apiKey, promptText, onOk, onErr)
    else
        sendOpenAI(STATE.apiKey, promptText, onOk, onErr, STATE.model)
    end
end

-- connect send UI
if sendBtn and chatBox then
    sendBtn.MouseButton1Click:Connect(function()
        local text = tostring(chatBox.Text or "")
        sendMessage(text)
        chatBox.Text = ""
    end)
    -- support pressing Enter on TextBox (FocusLost with enter)
    chatBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local t = tostring(chatBox.Text or "")
            sendMessage(t)
            chatBox.Text = ""
        end
    end)
end

-- initial status
if not STATE.apiKey then setStatus("No key") end

-- ensure chatLogs auto-scroll when new child added
if chatLogs and chatLogs:IsA("ScrollingFrame") then
    local layout = nil
    for _, v in ipairs(chatLogs:GetChildren()) do
        if v:IsA("UIListLayout") or v:IsA("UIGridLayout") then
            layout = v; break
        end
    end
    if layout == nil then
        -- optionally create a ListLayout if none exists — but you said layout already present, so we won't create
    else
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            chatLogs.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 8)
            chatLogs.CanvasPosition = Vector2.new(0, math.max(0, layout.AbsoluteContentSize.Y - chatLogs.AbsoluteSize.Y))
        end)
    end
end

-- finalize
if txt then txt(user.Sys, "AI request system ready", 255,90,0) end
setStatus("No key")
