-- gpt 3.67

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
txt(user.Nill, "Version: Test 3.67 | © Copyright LighterCyan", 180, 180, 180)
txt(user.Warn, "Stop! For your safety, please do not share your API and avoid being stared at by people around you. Due to safety and privacy concerns, you confirm that you will use your API to continue using our AI-OpenSource or not? With respect.", 255,255,0)
txt(user.Info, "Use /help for more information or commands.", 0,170,255)
txt(user.Nill, [[
What is AI-OpenSource?
  AI-OpenSource is a tool for questioning to AIs (ChatGPT/Gemini) by putting API Key.
  
What AI model you using?
  We use gpt-4o-mini and gemini-2.5-flash
  
This is safe to put api key?
  Yes, this is safe to put your api key, but make sure do NOT share your api.
  
Available commands
  /Help
  /Addapi [ChatGPT/Gemini] [ApiKey] [yes/no]  
       Add API key  
  
  /Unsaveapi OR /UnApi  
       Unsave API key  
  
  /Calculate OR /Cal [MATH]  
       Use + - * / ^ x  
       Example: 50 * 100  
  
  /ClearText  
       Clear all texts  
  
  /OpenWebsiteInExperience OR /OWINE [URL]  
       Open website in experience  
  
  /Script [CODE] -- add [ ] more please.  
       write script  
       Example: /script [print("Hello, World!")]  
  
  /Loadstring [URL]  
       loadstring any url of scripts  
       Example: /loadstring https://raw.githubusercontent.com/RyXeleron/infiniteyield-reborn/refs/heads/scriptblox/source  
  
  /Debug [on/off]  
       show debug  
]], 180, 180, 180)
txt(user.Nill, "[====== Chat ======]", 180, 180, 180)

-- ===============================
-- Tail script: UI hooks, API connect, askAI, commands
-- Requires: ch, se, si, st, con, con2, txt, user, endpointsFor
-- Uses executor request implementations (syn.request, http.request, request, fluxus.request)
-- ===============================

local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")

-- executor http detection
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if not httpRequest then
    -- If no executor http, we still allow /addapi stub and local-only commands.
    txt(user.Warn, "No executor HTTP available: API requests disabled", 255,200,0)
end

-- state
local SAVED_API = nil         -- string api key (not persisted here)
local SAVED_PROVIDER = nil    -- "chatgpt" or "gemini" or nil
local CURRENT_MODEL = "gpt-4o-mini" -- default for OpenAI
local DEBUG_MODE = false
local RATE_LOCK = false       -- set when 429 received
local RATE_UNTIL = 0          -- os.time() + seconds to wait
local LAST_TEST_AT = 0
local TEST_COOLDOWN = 5       -- seconds between key-validation attempts
local BACKOFF_BASE = 2
local backoff_attempts = 0

-- helper: safe json encode/decode wrappers
local function jsonEncode(t)
    return HttpService:JSONEncode(t)
end
local function jsonDecode(s)
    local ok, r = pcall(HttpService.JSONDecode, HttpService, s)
    if not ok then return nil end
    return r
end

-- UI status update helper
local function setStatus(text)
    if st and typeof(st) == "Instance" and st:IsA("TextLabel") then
        st.Text = "Status: "..tostring(text)
    end
end

-- detect provider by key prefix (simple heuristics)
local function detectProviderByKey(key)
    if not key then return nil end
    if tostring(key):match("^sk%-") then return "chatgpt" end
    if tostring(key):match("^AIza") or tostring(key):match("^AIza") then return "gemini" end
    -- fallback: user may pass other tokens — choose OpenAI by default
    return "chatgpt"
end

-- small helper to throttle local validation attempts
local function canAttemptValidation()
    return os.time() - LAST_TEST_AT >= TEST_COOLDOWN
end

-- show debug messages
local function dbg(...)
    if DEBUG_MODE and type(txt) == "function" then
        local msg = table.concat({ ... }, " ")
        txt(user.Info, "[DBG] "..msg, 0,170,255)
    end
end

-- Rate limit display
local function setRateLimited(seconds)
    RATE_LOCK = true
    RATE_UNTIL = os.time() + (seconds or 30)
    setStatus("Rate-limited. Retry in "..tostring(seconds or 30).."s")
    txt(user.Warn, "Rate-limited. Retry in "..tostring(seconds or 30).."s", 255,255,0)
    -- schedule unlock
    task.delay(seconds or 30, function()
        RATE_LOCK = false
        setStatus("Idle")
    end)
end

-- low-level request wrapper using executor http
local function executorRequest(opts)
    -- opts: { Url, Method, Headers, Body } returns (ok, response-table or err)
    if not httpRequest then return false, "no httpRequest available" end
    local success, res = pcall(function()
        return httpRequest({
            Url = opts.Url,
            Method = opts.Method or "GET",
            Headers = opts.Headers,
            Body = opts.Body,
            -- sometimes executors expect lowercase keys; but syn.request style used here
        })
    end)
    if not success then return false, res end
    return true, res
end

-- choose endpoints for SAVED_PROVIDER or explicit provider
local function pickEndpoint(provider)
    provider = provider or SAVED_PROVIDER or "chatgpt"
    local ep = endpointsFor(provider)
    return ep, provider
end

-- askAI with backoff/rate-limit handling
local function askAI(prompt, onSuccess, onError)
    if RATE_LOCK then
        local waitLeft = math.max(0, RATE_UNTIL - os.time())
        if onError then onError("Rate limited. Retry in "..waitLeft.."s") end
        return
    end
    if not SAVED_API then
        if onError then onError("Not connected to any API. Confirm API first.") end
        return
    end
    if not httpRequest then
        if onError then onError("Executor HTTP not available.") end
        return
    end

    local ep, provider = pickEndpoint()
    if not ep then
        if onError then onError("No endpoint for provider") end
        return
    end

    local headers = ep.makeHeaders(SAVED_API)
    local body = nil
    -- some endpoints accept simple payload; allow provider.makeBody signature (prompt, model)
    if ep.makeBody then
        body = ep.makeBody(prompt, CURRENT_MODEL)
    else
        -- fallback generic
        body = jsonEncode({ input = prompt })
    end

    dbg("askAI -> provider", provider, "url", ep.url)
    setStatus("Sending to API ("..tostring(provider)..")")

    -- send via executor but handle common http response shapes
    local ok, resp = executorRequest({ Url = ep.url, Method = "POST", Headers = headers, Body = body })
    if not ok then
        -- executor error
        backoff_attempts = backoff_attempts + 1
        local err = resp
        dbg("executorRequest failed:", err)
        if onError then onError(err) end
        return
    end

    -- syn.request returns table with StatusCode, Body, Headers etc.
    local status = resp.StatusCode or resp.status
    local bodyText = resp.Body or resp.body or ""
    dbg("HTTP status", status)

    if status == 429 then
        -- rate-limited: check Retry-After header
        local headersResp = resp.Headers or resp.headers or {}
        local retry = tonumber(headersResp["Retry-After"] or headersResp["retry-after"] or headersResp["Retry-After-Sec"]) or 30
        setRateLimited(retry)
        if onError then onError("Rate limited: "..tostring(retry).."s") end
        return
    end

    if status and (status < 200 or status >= 300) then
        -- try parse error to show meaningful message
        local parsed = jsonDecode(bodyText)
        local msg = "HTTP "..tostring(status)
        if parsed and parsed.error and parsed.error.message then
            msg = msg .. ": " .. tostring(parsed.error.message)
        end
        if onError then onError(msg) end
        return
    end

    -- success -> parse result via endpoint parser if present
    local out = nil
    if ep.parseResult then
        out = ep.parseResult(bodyText)
    else
        -- fallback: try common shapes
        local parsed = jsonDecode(bodyText)
        if parsed then
            if parsed.choices and parsed.choices[1] and parsed.choices[1].message and parsed.choices[1].message.content then
                out = parsed.choices[1].message.content
            elseif parsed.outputText then
                out = parsed.outputText
            else
                out = tostring(bodyText)
            end
        else
            out = tostring(bodyText)
        end
    end

    if onSuccess then
        onSuccess(out)
    end
end

-- Validate API quickly (one small request). Avoid frequent validation.
local function validateAndSetApi(key)
    if not key or key == "" then
        txt(user.Error, "Key is empty", 255,0,0)
        return false
    end
    if not httpRequest then
        txt(user.Error, "No executor HTTP available for validation", 255,0,0)
        return false
    end
    if not canAttemptValidation() then
        txt(user.Warn, "Validation cooldown. Try again later.", 255,255,0)
        return false
    end

    LAST_TEST_AT = os.time()

    local prov = detectProviderByKey(key)
    local ep, provider = pickEndpoint(prov)
    if not ep then
        txt(user.Error, "No endpoint configured for provider: "..tostring(prov), 255,0,0)
        return false
    end

    -- Build minimal test body (do not ask heavy model)
    local body = nil
    if ep.makeBody then
        body = ep.makeBody("Hello")
    else
        body = jsonEncode({ input = "Hello" })
    end
    local headers = ep.makeHeaders(key)

    setStatus("Checking API key...")
    txt(user.Info, "Information: Checking API key...", 0,170,255)

    local ok, resp = executorRequest({ Url = ep.url, Method = "POST", Headers = headers, Body = body })
    if not ok then
        txt(user.Error, "Error: HTTP request failed: "..tostring(resp), 255,0,0)
        return false
    end
    local status = resp.StatusCode or resp.status
    local bodyText = resp.Body or resp.body or ""
    if status == 429 then
        local headersResp = resp.Headers or resp.headers or {}
        local retry = tonumber(headersResp["Retry-After"] or headersResp["retry-after"]) or 30
        setRateLimited(retry)
        return false
    end
    if status and (status < 200 or status >= 300) then
        -- parse for message
        local parsed = jsonDecode(bodyText)
        local errMsg = "HTTP "..tostring(status)
        if parsed and parsed.error and parsed.error.message then
            errMsg = errMsg..": "..tostring(parsed.error.message)
        end
        txt(user.Error, "Key validation failed: "..errMsg, 255,0,0)
        setStatus("Invalid key")
        return false
    end

    -- success
    SAVED_API = key
    SAVED_PROVIDER = provider
    backoff_attempts = 0
    setStatus("Connected")
    txt(user.Suc, "Connected: "..tostring(provider).." (quick test OK)", 0,255,0)
    return true
end

-- connect buttons
if con and con:IsA("TextButton") then
    con.MouseButton1Click:Connect(function()
        local key = (type(tb) == "Instance" and tb.Text) or (type(api)=="string" and api) or ((type(ch)=="Instance" and ch.Text) and ch.Text) or nil
        if not key or key == "" then
            txt(user.Error, "No API key in textbox", 255,0,0)
            return
        end
        -- detect provider
        local prov = detectProviderByKey(key)
        setStatus("Connecting")
        txt(user.Info, "Information: Connecting to API...", 0,170,255)
        -- validate (this will set SAVED_API on success)
        local ok = validateAndSetApi(key)
        if not ok then
            txt(user.Error, "Failed to connect/validate key", 255,0,0)
            return
        end
    end)
else
    dbg("Confirm_api button 'con' missing")
end

-- unsave API
if con2 and con2:IsA("TextButton") then
    con2.MouseButton1Click:Connect(function()
        SAVED_API = nil
        SAVED_PROVIDER = nil
        setStatus("Unsave key")
        txt(user.Warn, "API key removed (Unsaved)", 255,255,0)
    end)
else
    dbg("Unsaved_API button 'con2' missing")
end

-- ===============================
-- Command & Send wiring (uses txt and user)
-- ===============================
-- central message handler (command + AI send)
local function handleMessageRaw(msg)
    msg = tostring(msg or ""):gsub("^%s+",""):gsub("%s+$","")
    if msg == "" then return end

    -- slash command
    if msg:sub(1,1) == "/" then
        local lower = msg:lower()
        if lower:match("^/help") then
            txt(user.Sys, "Available commands:", 255,90,0)
            for line in HELP_TEXT:gmatch("[^\n]+") do
                txt(user.Nill, line, 180,180,180)
            end
            return
        end

        if lower:match("^/debug%s+(on|off)") then
            local f = lower:match("^/debug%s+(on|off)")
            DEBUG_MODE = (f == "on")
            txt(user.Suc, "Debug mode: "..tostring(DEBUG_MODE), 0,255,0)
            return
        end

        if lower:match("^/openwebsiteinexperience") or lower:match("^/owine") then
            local url = msg:match("^/%S+%s+(.+)$") or ""
            url = url:gsub("^%s+",""):gsub("%s+$","")
            if url == "" then
                txt(user.Error, "Usage: /OpenWebsiteInExperience [URL]", 255,0,0)
                return
            end
            local ok, e = pcall(function()
                if GuiService and GuiService.OpenBrowserWindow then
                    GuiService:OpenBrowserWindow(url)
                else
                    if StarterGui and StarterGui:SetCore then
                        StarterGui:SetCore("OpenBrowserWindow", url)
                    else
                        error("No supported API to open website in-game")
                    end
                end
            end)
            if ok then txt(user.Suc, "Opened website: "..url, 0,255,0) else txt(user.Error, "OpenWebsite failed: "..tostring(e), 255,0,0) end
            return
        end

        if lower:match("^/loadstring%s+") then
            local url = msg:match("^/%S+%s+(.+)$") or ""
            if url == "" then txt(user.Error, "Usage: /loadstring [URL]",255,0,0); return end
            txt(user.Sys, "Fetching loadstring...", 255,90,0)
            local ok, res = pcall(function() return loadstring(game:HttpGet(url))() end)
            if ok then txt(user.Suc, "loadstring executed",0,255,0) else txt(user.Error, "loadstring error: "..tostring(res),255,0,0) end
            return
        end

        if lower:match("^/script%s+") then
            local code = msg:match("^/%S+%s+(.+)$") or ""
            code = code:gsub("^%[%[",""):gsub("%]%]$","")
            if code == "" then txt(user.Error, "Usage: /script [[CODE]]",255,0,0); return end
            txt(user.Sys, "Executing script...",255,90,0)
            local fn, err = loadstring(code)
            if not fn then txt(user.Error, "Compile error: "..tostring(err),255,0,0); return end
            local ok, r = pcall(fn)
            if ok then txt(user.Suc, "Script executed",0,255,0) else txt(user.Error, "Runtime error: "..tostring(r),255,0,0) end
            return
        end

        if lower:match("^/cleartext") then
            for _,v in ipairs(si:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
            txt(user.Suc, "Chat cleared",0,255,0)
            return
        end

        if lower:match("^/cal") or lower:match("^/calculate") then
            local expr = msg:match("^/%S+%s+(.+)$") or ""
            if expr == "" then txt(user.Error, "Usage: /cal [expr]",255,0,0); return end
            local ok, res = pcall(function() return loadstring("return "..expr)() end)
            if ok then txt(user.Suc, "Result = "..tostring(res),0,255,0) else txt(user.Error, "Math error: "..tostring(res),255,0,0) end
            return
        end

        if lower:match("^/addapi%s+") then
            local name, key, confirm = msg:match("^/%S+%s+(%S+)%s+(%S+)%s*(%S*)")
            if not name or not key then txt(user.Error, "Usage: /addapi [gemini/chatgpt] [key] [yes/no]",255,0,0); return end
            name = name:lower()
            if confirm == "yes" or confirm == "y" then
                -- immediate validate attempt
                local ok = validateAndSetApi(key)
                if ok then txt(user.Suc, "API saved and connected",0,255,0) else txt(user.Error, "API failed to validate",255,0,0) end
            else
                -- just save without validation (skipping validation)
                SAVED_API = key
                SAVED_PROVIDER = detectProviderByKey(key)
                setStatus("Select "..(SAVED_PROVIDER or "provider"))
                txt(user.Sys, "API stored (validation skipped). Use Confirm API to validate.",255,90,0)
            end
            return
        end

        if lower:match("^/unsaveapi") or lower:match("^/unapi") then
            SAVED_API = nil
            SAVED_PROVIDER = nil
            setStatus("No key")
            txt(user.Warn, "API unsaved",255,255,0)
            return
        end

        -- unknown command
        txt(user.Warn, "Unknown command. Type /help",255,255,0)
        return
    end

    -- Not a slash command: normal user message -> send to AI
    txt(user.plr, msg, 255,255,255)

    -- If no API saved -> reply stub
    if not SAVED_API then
        txt(user.chat, "(AI not connected)", 85,255,255)
        return
    end

    -- Send to AI (async)
    askAI(msg, function(answer)
        if answer and answer ~= "" then
            txt(user.chat, answer, 85,255,255)
        else
            txt(user.chat, "(no response)", 85,255,255)
        end
    end, function(err)
        txt(user.Error, "AI request failed: "..tostring(err), 255,0,0)
    end)
end

-- wire send button and Enter (FocusLost)
if se and se:IsA("TextButton") then
    se.MouseButton1Click:Connect(function()
        local msg = tostring(ch.Text or "")
        handleMessageRaw(msg)
        if ch then ch.Text = "" end
    end)
end

if ch and ch:IsA("TextBox") then
    ch.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local msg = tostring(ch.Text or "")
            handleMessageRaw(msg)
            ch.Text = ""
        end
    end)
end

-- expose debug toggle command for external use
_G.AIOPEN_DEBUG = function(flag)
    DEBUG_MODE = flag and true or false
    txt(user.Sys, "Debug mode: "..tostring(DEBUG_MODE), 255,90,0)
end

-- initial status
setStatus("No key")
txt(user.Nill, "System ready. Use /help for commands.", 180,180,180)

-- end of tail script
