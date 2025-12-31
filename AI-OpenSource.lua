-- gpt 3.58

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
txt(user.Nill, "Version: Test 3.58 | © Copyright LighterCyan", 180, 180, 180)
txt(user.Warn, "Stop! For your safety, please do not share your API and avoid being stared at by people around you. Due to safety and privacy concerns, you confirm that you will use your API to continue using our AI-OpenSource or not? With respect.", 255,255,0)
txt(user.Nill, "[====== Chat ======]", 180, 180, 180)

-- === AI-OpenSource: Chat bridge (paste AFTER your UI + txt() + user table) ===
-- Expects existing Instances in UI:
--  - TextBox for API key: name "api" (or "APIKeyBox")
--  - TextButton Confirm_api (or "Confirm_api" / "SaveBtn")
--  - TextButton Unsaved_API (or "Unsaved_API")
--  - TextBox chat input: name "chat" or "ch"
--  - TextButton send: name "Send" or "se"
--  - ScrollingFrame chat logs: name "ChatLogs" or "si"
--  - Status TextLabel: name "Status" or "st"
-- Also expects your txt(user, text, R,G,B) function and user table already present.

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local rootMenu = nil
local ok
ok, rootMenu = pcall(function() return CoreGui:WaitForChild("ExperienceSettings", 5).Menu end)
if not ok or not rootMenu then
    -- fallback: try common alternatives
    rootMenu = CoreGui:FindFirstChild("ExperienceSettings") and CoreGui.ExperienceSettings:FindFirstChild("Menu")
end

-- try multiple frames/names (user said Frame path may vary)
local function findChildByAny(parent, names)
    for _, n in ipairs(names) do
        local c = parent:FindFirstChild(n)
        if c then return c end
    end
    return nil
end

local container = rootMenu or CoreGui -- fallback to CoreGui to search globally
local apiBox = findChildByAny(container, {"api", "APIKeyBox", "APIKey", "KeyBox"})
local confirmBtn = findChildByAny(container, {"Confirm_api", "SaveBtn", "ConfirmAPI", "Confirm_api"})
local unsavedBtn = findChildByAny(container, {"Unsaved_API", "UnsavedAPI", "Unsaved"})
local statusLbl = findChildByAny(container, {"Status", "st", "StatusLabel"})
local chatInput = findChildByAny(container, {"chat", "ch", "PromptBox", "UserBox"}) -- some UIs use PromptBox
local sendBtn = findChildByAny(container, {"Send", "se", "SendBtn"})
local chatLogs = findChildByAny(container, {"ChatLogs", "ChatFrame", "ChatFrame", "si", "ChatFrame"})

-- If some direct children weren't found inside Menu, search whole experience
if not apiBox then apiBox = CoreGui:FindFirstChild("api") or CoreGui:FindFirstChild("APIKeyBox") end
if not confirmBtn then confirmBtn = CoreGui:FindFirstChild("Confirm_api") or CoreGui:FindFirstChild("SaveBtn") end
if not unsavedBtn then unsavedBtn = CoreGui:FindFirstChild("Unsaved_API") end
if not statusLbl then statusLbl = CoreGui:FindFirstChild("Status") end
if not chatInput then chatInput = CoreGui:FindFirstChild("chat") or CoreGui:FindFirstChild("PromptBox") end
if not sendBtn then sendBtn = CoreGui:FindFirstChild("Send") or CoreGui:FindFirstChild("SendBtn") end
if not chatLogs then chatLogs = CoreGui:FindFirstChild("ChatLogs") end

-- Verify required helpers exist
if type(txt) ~= "function" then
    warn("[AI-OpenSource] txt() function not found. Aborting chat bridge.")
    return
end
if type(user) ~= "table" then
    warn("[AI-OpenSource] user table not found. Aborting chat bridge.")
    return
end

-- request function detection (executor)
local requestFunc = nil
requestFunc = (syn and syn.request) or (request or http and http.request) or (http_request) or (fluxus and fluxus.request)

local function hasRequest()
    return type(requestFunc) == "function"
end

-- file save/load (optional)
local CAN_FILE = (type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function")
local KEYFILE = "AI_OPEN_KEY.txt"

local function saveKeyToFile(key)
    if CAN_FILE then
        pcall(function()
            writefile(KEYFILE, key)
        end)
    end
end
local function loadKeyFromFile()
    if CAN_FILE and isfile(KEYFILE) then
        local ok, v = pcall(function() return readfile(KEYFILE) end)
        if ok and v then return v end
    end
    return nil
end

-- config
local RATE_LIMIT_SEC = 3          -- min seconds between requests
local BACKOFF_BASE = 1.5         -- exponential backoff multiplier
local OPENAI_MODEL = "gpt-4o-mini" -- default model for OpenAI
local GEMINI_MODEL_ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

-- runtime state
local savedKey = nil
local provider = nil -- "openai" | "gemini" | nil
local lastRequestTime = 0
local retryQueue = {}

local function setStatus(s)
    if statusLbl and statusLbl:IsA("TextLabel") then
        statusLbl.Text = "Status: " .. tostring(s)
    end
end

local function detectProviderFromKey(k)
    if not k then return nil end
    k = tostring(k)
    if k:match("^%s*sk%-") then
        return "openai"
    elseif k:match("^%s*AIza") then
        return "gemini"
    else
        -- fallback: if contains "sk_proj" treat openai; user said "sk_proj*** = ChatGPT"
        if k:find("sk_proj") then return "openai" end
        return nil
    end
end

-- safe post helper using executor request
local function httpPost(opts)
    if not requestFunc then
        return false, "http_request_not_available"
    end
    local ok, res = pcall(function() return requestFunc(opts) end)
    return ok, res
end

-- build OpenAI request (chat completions)
local function callOpenAI(key, prompt)
    local url = "https://api.openai.com/v1/chat/completions"
    local payload = {
        model = OPENAI_MODEL,
        messages = {
            {role = "user", content = prompt}
        },
        max_tokens = 800,
        temperature = 0.7
    }
    local body = HttpService:JSONEncode(payload)
    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. key
    }
    return httpPost({Url = url, Method = "POST", Headers = headers, Body = body})
end

-- build Gemini request (Google Generative Language) — use user-provided API key as x-goog-api-key
local function callGemini(key, prompt)
    local raw = {contents = {{parts = {{text = prompt}}}}}
    local body = HttpService:JSONEncode(raw)
    local headers = {
        ["Content-Type"] = "application/json",
        ["x-goog-api-key"] = key
    }
    return httpPost({Url = GEMINI_MODEL_ENDPOINT, Method = "POST", Headers = headers, Body = body})
end

-- minimal rate-limited caller (returns success, response or false+error)
local function enqueueRequest(fn)
    -- returns a promise-like table with waitForResult() to keep simple
    local token = {done=false, ok=false, res=nil}
    table.insert(retryQueue, {fn=fn, token=token, backoff=1})
    return token
end

-- background processor for queue
task.spawn(function()
    while true do
        local job = table.remove(retryQueue, 1)
        if job then
            local now = tick()
            local waitFor = math.max(0, RATE_LIMIT_SEC - (now - lastRequestTime))
            if waitFor > 0 then task.wait(waitFor) end

            local ok, res = pcall(job.fn)
            lastRequestTime = tick()

            -- handle HTTP 429: if res and res.StatusCode==429 then retry with backoff
            local statusCode = nil
            if ok and type(res)=="table" then statusCode = res.StatusCode end

            if statusCode == 429 then
                -- exponential backoff, push back if attempts left
                job.backoff = job.backoff * BACKOFF_BASE
                task.delay(job.backoff, function()
                    table.insert(retryQueue, job)
                end)
            else
                job.token.done = true
                job.token.ok = ok
                job.token.res = res
            end
        else
            task.wait(0.1)
        end
    end
end)

-- wrapper to call API depending on provider
local function sendToProvider(prompt)
    if not savedKey then
        return false, "no_key"
    end
    if not provider then
        return false, "no_provider"
    end

    local fn
    if provider == "openai" then
        fn = function() return callOpenAI(savedKey, prompt) end
    elseif provider == "gemini" then
        fn = function() return callGemini(savedKey, prompt) end
    else
        return false, "unknown_provider"
    end

    local token = enqueueRequest(fn)
    -- wait for the token to resolve (simple busy wait, but small)
    local start = tick()
    while not token.done do
        task.wait(0.05)
        -- safety timeout
        if tick() - start > 30 then break end
    end

    if token.ok and type(token.res) == "table" then
        return true, token.res
    else
        return false, token.res or "request_failed"
    end
end

-- parse responses and show to UI
local function parseAndShowResponse(ok, res)
    if not ok then
        txt(user.Error, "HTTP request error or no executor available.", 255,0,0)
        return
    end
    if type(res) ~= "table" then
        txt(user.Error, "Invalid response object.", 255,0,0)
        return
    end

    -- OpenAI typical response: res.Body JSON with choices[1].message.content
    if res.Body then
        local body = res.Body
        local parsed, success = pcall(function() return HttpService:JSONDecode(body) end)
        if success and parsed then
            -- OpenAI style
            if parsed.choices and parsed.choices[1] and parsed.choices[1].message and parsed.choices[1].message.content then
                local aiText = parsed.choices[1].message.content
                txt(user.chat, aiText, 85,255,255)
                return
            end
            -- Gemini style: candidates -> content.parts[1].text
            if parsed.candidates and parsed.candidates[1] and parsed.candidates[1].content and parsed.candidates[1].content.parts then
                local p = parsed.candidates[1].content.parts[1].text
                txt(user.chat, p or "[No answer]", 85,255,255)
                return
            end
            -- fallback: show raw body
            txt(user.chat, (type(parsed)=="table" and tostring(parsed) or body), 85,255,255)
            return
        else
            -- non-json body
            txt(user.chat, tostring(body), 85,255,255)
            return
        end
    end

    txt(user.Error, "No Body in response.", 255,0,0)
end

-- validate key (light check) by sending tiny prompt (use minimal tokens)
local function validateKey(key, prov)
    if not key then return false, "no_key" end
    local small = "Hello (validation). Reply 'ok'."
    local ok, res = sendToProvider(small) -- note: this will use savedKey/provider; we'll temporarily assign
    return ok, res
end

-- UI bindings
local function setSavedKey(k)
    savedKey = k
    provider = detectProviderFromKey(k)
    if provider == "openai" then
        setStatus("Select ChatGPT")
    elseif provider == "gemini" then
        setStatus("Select Gemini")
    else
        setStatus("No key")
    end
end

-- load saved key from file if available
local fileKey = loadKeyFromFile()
if fileKey then
    setSavedKey(fileKey)
    if apiBox and apiBox:IsA("TextBox") then apiBox.Text = fileKey end
end

-- Confirm button: save + try lightweight validation (but avoid spamming)
if confirmBtn and confirmBtn:IsA("TextButton") then
    confirmBtn.MouseButton1Click:Connect(function()
        local key = (apiBox and apiBox.Text and tostring(apiBox.Text)) or savedKey
        if not key or key == "" then
            setStatus("No key")
            txt(user.Warn, "No API key provided.", 255,255,0)
            return
        end

        setStatus("Connecting")
        -- set and save immediately
        setSavedKey(key)
        -- save to file if possible
        saveKeyToFile(key)

        -- quick validation attempt (but skip if no requestFunc)
        if not hasRequest() then
            setStatus("Connected (no HTTP available)")
            txt(user.Info, "Executor HTTP not available; saved key locally.", 0,170,255)
            return
        end

        -- perform one test request (rate-limited)
        local ok2, res = sendToProvider("Hello. Test validation.")
        if ok2 then
            setStatus("Connected")
            txt(user.Suc, "API validated and connected.", 0,255,0)
        else
            setStatus("Invalid key")
            txt(user.Error, "Validation failed (server returned error). Saved key but invalid.", 255,0,0)
        end
    end)
end

-- Unsaved API: clear saved key
if unsavedBtn and unsavedBtn:IsA("TextButton") then
    unsavedBtn.MouseButton1Click:Connect(function()
        savedKey = nil
        provider = nil
        if CAN_FILE and isfile(KEYFILE) then pcall(function() delfile(KEYFILE) end) end
        if apiBox and apiBox:IsA("TextBox") then apiBox.Text = "" end
        setStatus("Unsave key")
        txt(user.Sys, "API key cleared.", 255,90,0)
    end)
end

-- send message from UI input
local function sendFromInput()
    if not chatInput then return end
    local text = tostring(chatInput.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then return end

    -- show user message
    txt(user.plr, text, 255,255,255)

    -- clear input
    chatInput.Text = ""

    -- basic local command: if message starts with "/skipvalidate" set special
    -- otherwise send to provider
    if not savedKey then
        txt(user.Warn, "No API key configured. Use Confirm API to set one.", 255,255,0)
        return
    end

    setStatus("Connecting")
    -- call provider
    local ok2, res = sendToProvider(text)
    if not ok2 then
        -- res might be error table or string
        if type(res) == "table" and res.StatusCode == 401 then
            setStatus("Invalid key")
            txt(user.Error, "Invalid API key (401).", 255,0,0)
        elseif type(res)=="table" and res.StatusCode == 429 then
            setStatus("Connected")
            txt(user.Warn, "Rate limited (429). Try again later.", 255,255,0)
        else
            txt(user.Error, "Request failed: "..tostring(res), 255,0,0)
            setStatus("Connected")
        end
        return
    end

    -- parse and show
    parseAndShowResponse(true, res)
    setStatus("Connected")
end

-- wire Enter key / FocusLost on TextBox (works on mobile too)
if chatInput and chatInput:IsA("TextBox") then
    chatInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            sendFromInput()
        end
    end)
end
if sendBtn and sendBtn:IsA("TextButton") then
    sendBtn.MouseButton1Click:Connect(sendFromInput)
end

-- convenience functions to show initial instructions
txt(user.Info, "AI chat ready. Enter prompt and press Send (or Enter).", 0,170,255)
if not hasRequest() then
    txt(user.Warn, "Executor HTTP not available. Requests will fail unless you enable executor HTTP.", 255,255,0)
    if statusLbl then setStatus("No key") end
else
    if savedKey then
        setStatus(provider and (provider=="openai" and "Select ChatGPT" or "Select Gemini") or "No key")
    else
        setStatus("No key")
    end
end

-- done
txt(user.Nill, "Bridge loaded.", 180,180,180)
