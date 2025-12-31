-- gpt 3

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
txt(user.Nill, "Version: Test 3 | © Copyright LighterCyan", 180, 180, 180)
txt(user.Warn, "Stop! For your safety, please do not share your API and avoid being stared at by people around you. Due to safety and privacy concerns, you confirm that you will use your API to continue using our AI-OpenSource or not? With respect.", 255,255,0)

-- AI-OpenSource: client-side controller (no UI creation)
-- ต้องแน่ใจว่า gpt (root GUI) อยู่แล้วใน CoreGui ตามที่คุณเตรียมไว้

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- find gpt root (Menu.ChatGPT)
local CoreGui = game:GetService("CoreGui")
local function findChatGui()
    for _, g in ipairs(CoreGui:GetDescendants()) do
        if g.Name == "ChatGPT" and g:IsA("Frame") then
            return g
        end
    end
    -- fallback: wait for it
    local ok, found = pcall(function() return CoreGui:WaitForChild("ExperienceSettings", 5) end)
    if ok and found then
        for _, d in ipairs(found:GetDescendants()) do
            if d.Name == "ChatGPT" and d:IsA("Frame") then return d end
        end
    end
end
local gpt = findChatGui()
if not gpt then
    warn("AI-OpenSource: couldn't find ChatGPT GUI root in CoreGui")
    return
end

-- helper to find descendant by name
local function findDesc(name)
    for _, v in ipairs(gpt:GetDescendants()) do
        if v.Name == name then return v end
    end
    return nil
end

-- UI elements you said exist:
local apiBox       = findDesc("api")            -- TextBox for API key
local confirmBtn   = findDesc("Confirm_api")   -- Confirm button
local unsavedBtn   = findDesc("Unsaved_API")   -- Unsaved button (cancel)
local statusLabel  = findDesc("Status")        -- TextLabel for status
local chatInput    = findDesc("chat")          -- TextBox to type prompt
local sendBtn      = findDesc("Send")          -- Send button
local logsFrame    = findDesc("ChatLogs")      -- ScrollingFrame (Auto canvas size)
local listLayout   -- determine listlayout inside logsFrame
if logsFrame then
    for _,c in ipairs(logsFrame:GetChildren()) do
        if c:IsA("UIListLayout") then listLayout = c break end
    end
end

-- Safety checks
if not apiBox or not confirmBtn or not unsavedBtn or not statusLabel or not chatInput or not sendBtn or not logsFrame then
    warn("AI-OpenSource: missing one or more UI elements. Script requires: api, Confirm_api, Unsaved_API, Status, chat, Send, ChatLogs")
    -- continue but some features may not work
end

-- detect available request function (supports many executors)
local requestFunc = nil
if syn and syn.request then requestFunc = syn.request
elseif http and http.request then requestFunc = http.request
elseif http_request then requestFunc = http_request
elseif request then requestFunc = request
elseif fluxus and fluxus.request then requestFunc = fluxus.request end

if not requestFunc then
    warn("AI-OpenSource: No HTTP request function found in this environment (executor required).")
end

-- config
local cfg = {
    openai_models_url = "https://api.openai.com/v1/models",
    openai_chat_url   = "https://api.openai.com/v1/chat/completions",
    openai_default_model = "gpt-4o-mini",  -- change as desired
    google_gen_url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
    maxRetries = 5,
    baseRetryDelay = 0.6, -- seconds (exponential backoff)
}

-- state
local STATE = {
    selectedService = nil, -- "ChatGPT" or "Gemini" or nil
    apiKey = nil,
    connected = false,
    connectedTo = nil, -- service string
}

-- small UI helper
local function setStatus(s)
    if not statusLabel then return end
    statusLabel.Text = "Status: "..tostring(s or "No key")
end

local function postLog(text, color)
    -- uses existing txt() pattern: but we create a TextLabel inside logsFrame
    -- color: Color3
    if not logsFrame then return end
    local lbl = Instance.new("TextLabel")
    lbl.Name = "Text"
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1,0,0,28)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.TextWrapped = true
    lbl.RichText = true
    lbl.Text = tostring(text)
    lbl.TextColor3 = color or Color3.fromRGB(255,255,255)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 16
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.Parent = logsFrame
    -- ensure scrolling to bottom after layout
    task.defer(function()
        if listLayout and logsFrame then
            logsFrame.CanvasSize = UDim2.new(0,0,0,logsFrame.CanvasSize.Y.Offset) -- no-op to update in some exec
        end
        -- small wait to let layout adjust, then auto-scroll (if available)
        task.wait(0.05)
        if logsFrame and logsFrame:IsA("ScrollingFrame") then
            logsFrame.CanvasPosition = Vector2.new(0, 999999)
        end
    end)
    return lbl
end

-- exponential backoff HTTP wrapper for 429
local function httpRequestWithRetry(reqTable)
    if not requestFunc then return false, "NoHTTP" end
    local attempt = 0
    while attempt < cfg.maxRetries do
        attempt = attempt + 1
        local ok, res = pcall(function() return requestFunc(reqTable) end)
        if not ok then
            -- network-level failure
            return false, tostring(res)
        end
        -- some executors return status in different fields
        local status = res.StatusCode or res.status or res.code
        if status == 429 then
            -- rate-limited -> wait and retry
            local delay = cfg.baseRetryDelay * (2 ^ (attempt-1))
            task.wait(delay)
            continue
        end
        -- success or other error
        return true, res
    end
    return false, "429_retries_exhausted"
end

-- determine key type heuristics
local function detectKeyType(key)
    if not key or key == "" then return nil end
    local k = tostring(key)
    -- ChatGPT/OpenAI keys typically start with "sk-" or "sk-proj-"
    if k:match("^sk") then
        return "ChatGPT"
    end
    -- Google API keys often start with "AIza"
    if k:match("^AIza") then
        return "Gemini"
    end
    -- some project-level "sk-proj-" may be used; also allow explicit user selection later
    return nil
end

-- validate key for ChatGPT (simple GET models) and Gemini (small POST)
local function validateKeyForService(key, service)
    if not requestFunc then return false, "NoHTTP" end
    if not key or key == "" then return false, "NoKey" end

    if service == "ChatGPT" then
        -- Test with listing models (lightweight). If 200 -> OK. If 401 -> invalid
        local ok, res = httpRequestWithRetry{
            Url = cfg.openai_models_url,
            Method = "GET",
            Headers = {
                ["Authorization"] = "Bearer "..key,
            },
        }
        if not ok then
            return false, tostring(res)
        end
        local code = res.StatusCode or res.status or res.code
        if code == 200 then return true, "Connected"
        elseif code == 401 then return false, "Invalid"
        else return false, "HTTP "..tostring(code) end
    elseif service == "Gemini" then
        -- POST a tiny payload to Gemini endpoint to validate API key (x-goog-api-key)
        local body = HttpService:JSONEncode({contents = {{parts = {{text = "ping"}}}}})
        local ok, res = httpRequestWithRetry{
            Url = cfg.google_gen_url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["x-goog-api-key"] = key,
            },
            Body = body,
        }
        if not ok then return false, tostring(res) end
        local code = res.StatusCode or res.status or res.code
        if code == 200 then return true, "Connected"
        elseif code == 403 or code == 401 then return false, "Invalid"
        else return false, "HTTP "..tostring(code) end
    else
        return false, "UnknownService"
    end
end

-- perform actual AI request (Chat completions or Gemini generateContent)
local function callAI(prompt)
    if not STATE.connected then
        return false, "Not connected"
    end
    local service = STATE.selectedService
    local key = STATE.apiKey
    if service == "ChatGPT" then
        local payload = {
            model = cfg.openai_default_model,
            messages = {
                { role = "user", content = tostring(prompt) }
            },
            max_tokens = 1024
        }
        local body = HttpService:JSONEncode(payload)
        local ok, res = httpRequestWithRetry{
            Url = cfg.openai_chat_url,
            Method = "POST",
            Headers = {
                ["Authorization"] = "Bearer "..key,
                ["Content-Type"] = "application/json"
            },
            Body = body
        }
        if not ok then return false, tostring(res) end
        local code = res.StatusCode or res.status or res.code
        if code == 200 or code == 201 then
            local parsed
            local decodeOk, dec = pcall(function() return HttpService:JSONDecode(res.Body) end)
            if not decodeOk then return false, "Invalid JSON" end
            parsed = dec
            -- try to extract text safely
            local text = nil
            if parsed and parsed.choices and parsed.choices[1] and parsed.choices[1].message and parsed.choices[1].message.content then
                text = parsed.choices[1].message.content
            elseif parsed and parsed.choices and parsed.choices[1] and parsed.choices[1].text then
                text = parsed.choices[1].text
            end
            return true, text or "<no text>"
        else
            return false, "HTTP "..tostring(code).." "..tostring(res.StatusMessage or "")
        end
    elseif service == "Gemini" then
        local payload = { contents = {{ parts = {{ text = tostring(prompt) }} }} }
        local body = HttpService:JSONEncode(payload)
        local ok, res = httpRequestWithRetry{
            Url = cfg.google_gen_url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["x-goog-api-key"] = key,
            },
            Body = body
        }
        if not ok then return false, tostring(res) end
        local code = res.StatusCode or res.status or res.code
        if code == 200 or code == 201 then
            local decodeOk, dec = pcall(function() return HttpService:JSONDecode(res.Body) end)
            if not decodeOk then return false, "Invalid JSON" end
            local text = nil
            -- response schema vary; attempt to find content
            if dec and dec.candidates and dec.candidates[1] and dec.candidates[1].content and dec.candidates[1].content.parts then
                text = dec.candidates[1].content.parts[1].text
            elseif dec and dec.output and dec.output[1] then
                text = dec.output[1].content or dec.output[1].text
            end
            return true, text or "<no text>"
        else
            return false, "HTTP "..tostring(code).." "..tostring(res.StatusMessage or "")
        end
    end
    return false, "Unsupported service"
end

-- UI handlers
local function onConfirmApiClicked()
    if not apiBox then return end
    local key = tostring(apiBox.Text or ""):gsub("^%s*(.-)%s*$","%1") -- trim
    if key == "" then
        setStatus("No key")
        postLog("Warning: API key is empty", Color3.fromRGB(255,255,0))
        STATE.apiKey = nil
        STATE.connected = false
        STATE.selectedService = nil
        return
    end
    -- detect service by prefix heuristics
    local guess = detectKeyType(key)
    if not guess then
        -- unknown prefix -> prompt user to select via UI? For now auto-try ChatGPT then Gemini
        postLog("Information: key not auto-detected, trying ChatGPT then Gemini...", Color3.fromRGB(0,170,255))
        -- try ChatGPT first
        setStatus("Connecting")
        postLog("Information: Checking ChatGPT key...", Color3.fromRGB(0,170,255))
        local ok, msg = validateKeyForService(key, "ChatGPT")
        if ok then
            STATE.apiKey = key
            STATE.selectedService = "ChatGPT"
            STATE.connected = true
            setStatus("Connected (ChatGPT)")
            postLog("Connected to ChatGPT", Color3.fromRGB(0,255,0))
            return
        end
        postLog("ChatGPT check failed: "..tostring(msg), Color3.fromRGB(255,100,100))
        -- try Gemini
        postLog("Information: Checking Gemini key...", Color3.fromRGB(0,170,255))
        local ok2, msg2 = validateKeyForService(key, "Gemini")
        if ok2 then
            STATE.apiKey = key
            STATE.selectedService = "Gemini"
            STATE.connected = true
            setStatus("Connected (Gemini)")
            postLog("Connected to Gemini", Color3.fromRGB(0,255,0))
            return
        end
        postLog("Gemini check failed: "..tostring(msg2), Color3.fromRGB(255,100,100))
        setStatus("Invalid key")
        STATE.apiKey = nil
        STATE.connected = false
        STATE.selectedService = nil
        return
    else
        -- guessed service
        setStatus("Connecting")
        postLog("Information: auto-detected service: "..guess.." -- validating...", Color3.fromRGB(0,170,255))
        local ok, msg = validateKeyForService(key, guess)
        if ok then
            STATE.apiKey = key
            STATE.selectedService = guess
            STATE.connected = true
            setStatus("Connected ("..guess..")")
            postLog("Connected to "..guess, Color3.fromRGB(0,255,0))
            return
        else
            setStatus("Invalid key")
            postLog("Validation failed: "..tostring(msg), Color3.fromRGB(255,100,100))
            STATE.apiKey = nil
            STATE.connected = false
            STATE.selectedService = nil
            return
        end
    end
end

local function onUnsavedApiClicked()
    STATE.apiKey = nil
    STATE.selectedService = nil
    STATE.connected = false
    setStatus("Unsave key")
    postLog("Warning: API key removed", Color3.fromRGB(255,255,0))
end

local function onSendClicked()
    if not chatInput then return end
    local prompt = tostring(chatInput.Text or ""):gsub("^%s*(.-)%s*$","%1")
    if prompt == "" then
        postLog("Warning: Please type a prompt first.", Color3.fromRGB(255,255,0))
        return
    end
    -- display user message
    postLog("You: "..prompt, Color3.fromRGB(255,255,255))
    -- check connection state
    if not STATE.connected or not STATE.selectedService then
        postLog("Error: Not connected to any API. Please Confirm API key first.", Color3.fromRGB(255,0,0))
        return
    end
    -- display AI placeholder
    local aiPlaceholder = postLog("AI: ... thinking ...", Color3.fromRGB(170,170,170))
    -- call AI (in background)
    task.spawn(function()
        local ok, res = callAI(prompt)
        -- remove placeholder text and show actual (we'll append a new message for simplicity)
        if not ok then
            postLog("Error: "..tostring(res), Color3.fromRGB(255,0,0))
        else
            postLog("AI: "..tostring(res), Color3.fromRGB(85,255,255))
        end
    end)
    -- optionally clear input
    chatInput.Text = ""
end

-- bind UI events (safely)
if confirmBtn and confirmBtn:IsA("TextButton") then
    confirmBtn.MouseButton1Click:Connect(onConfirmApiClicked)
end
if unsavedBtn and unsavedBtn:IsA("TextButton") then
    unsavedBtn.MouseButton1Click:Connect(onUnsavedApiClicked)
end
if sendBtn and sendBtn:IsA("GuiButton") then
    sendBtn.MouseButton1Click:Connect(onSendClicked)
end

-- connect keyboard Enter on chatInput if available
if chatInput and chatInput:IsA("TextBox") then
    chatInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            onSendClicked()
        end
    end)
end

-- initial
setStatus("No key")
postLog("Information: AI-OpenSource client ready.", Color3.fromRGB(0,170,255))
postLog("Information: Press Confirm API after pasting a key (ChatGPT: sk-*, Gemini: AIza*).", Color3.fromRGB(180,180,180))

-- expose small API for other scripts if needed
local PUBLIC = {}
function PUBLIC.getState() return STATE end
function PUBLIC.setApiKey(k) apiBox.Text = tostring(k) end
-- return PUBLIC if used as module (optional)
return PUBLIC
