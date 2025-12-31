-- gpt 3.5

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
txt(user.Nill, "Version: Test 3.5 | © Copyright LighterCyan", 180, 180, 180)
txt(user.Warn, "Stop! For your safety, please do not share your API and avoid being stared at by people around you. Due to safety and privacy concerns, you confirm that you will use your API to continue using our AI-OpenSource or not? With respect.", 255,255,0)
txt(user.Nill, "[====== Chat ======]", 180, 180, 180)

-- AI-OpenSource: Chat connector (tail)
-- Expects existing UI:
--  Frame: game:GetService("CoreGui").ExperienceSettings.Menu.AIOpenSource.Frame
--  api textbox name = "api" (tb)
--  Status label name = "Status" (st)
--  chat textbox name = "chat" (ch)
--  send button name = "Send" (se)
--  chat logs scrolling frame = "ChatLogs" (si)
-- Expects existing txt(user, text, R,G,B) function and user table available.

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- helper to find UI robustly (tweak path if your hierarchy differs)
local function findUI()
    local ok, menu = pcall(function()
        return CoreGui:WaitForChild("ExperienceSettings", 5).Menu
    end)
    if not ok or not menu then return nil end

    local frame = menu:FindFirstChild("AIOpenSource") and menu.AIOpenSource:FindFirstChild("Frame")
    if not frame then
        -- fallback to ChatGPT frame if used earlier
        local chatgpt = menu:FindFirstChild("ChatGPT")
        frame = chatgpt and chatgpt or nil
    end
    return frame
end

local frame = findUI()
if not frame then
    warn("[AI-OpenSource] UI frame not found at CoreGui.ExperienceSettings.Menu.AIOpenSource.Frame (or fallback).")
    return
end

-- ui refs (try-safe)
local tb = frame:FindFirstChild("api", true) or frame:FindFirstChild("API") or frame:FindFirstChild("APIKeyBox") -- try a few
local st = frame:FindFirstChild("Status", true) or frame:FindFirstChild("StatusLabel")
local ch = frame:FindFirstChild("chat", true) or frame:FindFirstChild("chatBox") or frame:FindFirstChild("TextBox", true)
local se = frame:FindFirstChild("Send", true) or frame:FindFirstChild("SendBtn", true)
local si = frame:FindFirstChild("ChatLogs", true) or frame:FindFirstChild("ChatFrame", true)

-- validate we found the essentials
if not tb or not ch or not se or not si or not st then
    warn("[AI-OpenSource] Required UI not found (tb/ch/se/si/st). Aborting.")
    return
end

-- external helpers (executor env)
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local hasWriteFile = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
local saveFileName = "ai_open_key.txt"

-- saved key helpers
local function saveKeyToDisk(key)
    if hasWriteFile then
        pcall(function() writefile(saveFileName, key) end)
    end
end
local function loadKeyFromDisk()
    if hasWriteFile and isfile(saveFileName) then
        local ok, data = pcall(readfile, saveFileName)
        if ok and data then return data end
    end
    return nil
end
local function clearSavedKey()
    if hasWriteFile and isfile(saveFileName) then
        pcall(function() delfile(saveFileName) end)
    end
end

-- UI status helper
local function setStatus(s)
    pcall(function() st.Text = "Status: " .. tostring(s) end)
end

-- detect key type
local function detectKeyType(key)
    if not key or key == "" then return nil end
    -- ChatGPT/OpenAI keys usually start with "sk-" (or other sk_ variants)
    if tostring(key):match("^sk") then return "openai" end
    -- Gemini / Google API keys often start with "AIza"
    if tostring(key):match("^AIza") then return "google" end
    -- sometimes user pasted "sk-proj-" or long strings; also accept "sk-proj" prefix
    if tostring(key):match("^sk%-proj") then return "openai" end
    return nil
end

-- small JSON decode helper (safe)
local function safeDecode(body)
    local ok, decoded = pcall(function() return HttpService:JSONDecode(body) end)
    if ok then return decoded end
    return nil
end

-- exponential backoff HTTP helper (returns response table or nil+err)
local function httpWithRetries(reqTable, maxRetries)
    maxRetries = maxRetries or 5
    local backoff = 1
    for attempt = 1, maxRetries do
        local ok, res = pcall(function() return httpRequest(reqTable) end)
        if not ok then
            -- network/other error
            return nil, ("request error: " .. tostring(res))
        end
        if res and (res.StatusCode == 200 or res.StatusCode == 201) then
            return res, nil
        end
        if res and res.StatusCode == 429 then
            -- rate limit, show waiting and retry after backoff
            setStatus("Rate limited, retry in " .. tostring(backoff) .. "s")
            task.wait(backoff)
            backoff = math.min(backoff * 2, 30)
            -- continue
        else
            -- non-429 failure -> return response
            local msg = "HTTP " .. tostring(res and res.StatusCode or "nil")
            if res and res.Body then msg = msg .. " " .. tostring(res.Body) end
            return res, msg
        end
    end
    return nil, "max retries reached (429)"
end

-- Validate key by issuing a tiny test request (1 token). returns type, ok, err
local function validateKey(key)
    local kind = detectKeyType(key)
    if not kind then return nil, false, "unknown key type" end

    setStatus("Connecting")
    if kind == "openai" then
        -- small chat request (model chosen conservatively)
        local url = "https://api.openai.com/v1/chat/completions"
        local model = "gpt-4o-mini" -- change if you want another
        local body = HttpService:JSONEncode({
            model = model,
            messages = {{role = "user", content = "Hello"}},
            max_tokens = 1,
            temperature = 0
        })
        local headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. key
        }
        local res, err = httpWithRetries({Url = url, Method = "POST", Headers = headers, Body = body}, 3)
        if not res then
            return kind, false, err or "no response"
        end
        if res.StatusCode == 200 then
            return kind, true, nil
        else
            local d = safeDecode(res.Body)
            local em = d and (d.error and (d.error.message or d.error)) or tostring(res.Body)
            return kind, false, em
        end

    elseif kind == "google" then
        -- call a small generation to test (Gemini endpoint). Use X-GOOG-API-KEY header (or x-goog-api-key)
        local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
        local rawBody = {contents = {{parts = {{text = "Hello"}}}}}
        local body = HttpService:JSONEncode(rawBody)
        local headers = {
            ["Content-Type"] = "application/json",
            ["x-goog-api-key"] = key
        }
        local res, err = httpWithRetries({Url = url, Method = "POST", Headers = headers, Body = body}, 3)
        if not res then
            return kind, false, err or "no response"
        end
        if res.StatusCode == 200 then
            return kind, true, nil
        else
            local d = safeDecode(res.Body)
            local em = d and (d.error and (d.error.message or d.error)) or tostring(res.Body)
            return kind, false, em
        end
    end

    return nil, false, "unsupported"
end

-- request functions for each provider
local function requestOpenAI(key, prompt)
    local url = "https://api.openai.com/v1/chat/completions"
    local body = HttpService:JSONEncode({
        model = "gpt-4o-mini",
        messages = {{role = "user", content = prompt}},
        temperature = 0.2,
        max_tokens = 1200
    })
    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. key
    }
    local res, err = httpWithRetries({Url = url, Method = "POST", Headers = headers, Body = body}, 5)
    if not res then return nil, err end
    local decoded = safeDecode(res.Body)
    if not decoded then return nil, res.Body end
    -- try common shapes
    if decoded.choices and decoded.choices[1] then
        local c = decoded.choices[1]
        if c.message and c.message.content then return c.message.content end
        if c.text then return c.text end
        if c.delta and c.delta.content then return c.delta.content end
    end
    if decoded.error then return nil, decoded.error.message or tostring(decoded.error) end
    return nil, "no usable content"
end

local function requestGoogleGemini(key, prompt)
    local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
    local rawBody = {contents = {{parts = {{text = prompt}}}}}
    local body = HttpService:JSONEncode(rawBody)
    local headers = {
        ["Content-Type"] = "application/json",
        ["x-goog-api-key"] = key
    }
    local res, err = httpWithRetries({Url = url, Method = "POST", Headers = headers, Body = body}, 5)
    if not res then return nil, err end
    local decoded = safeDecode(res.Body)
    if not decoded then return nil, res.Body end
    if decoded.candidates and decoded.candidates[1] and decoded.candidates[1].content and decoded.candidates[1].content.parts and decoded.candidates[1].content.parts[1] then
        return decoded.candidates[1].content.parts[1].text
    end
    if decoded.error then return nil, decoded.error.message or tostring(decoded.error) end
    return nil, "no usable content"
end

-- main connector state
local API = {
    key = nil,
    kind = nil, -- "openai" or "google"
    busy = false
}

-- load saved key to UI if present
local saved = loadKeyFromDisk()
if saved then
    tb.Text = saved
    API.key = saved
    API.kind = detectKeyType(saved)
    if API.kind then setStatus("Loaded key ("..tostring(API.kind)..")") end
end

-- UI button handlers (Confirm / Unsaved)
-- confirm: validate key then save; unsaved: clear current
local function onConfirmKey()
    local key = tostring(tb.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if key == "" then
        setStatus("No key")
        return
    end
    setStatus("Connecting")
    local kind, ok, err = validateKey(key)
    if ok then
        API.key = key
        API.kind = kind
        saveKeyToDisk(key)
        setStatus("Connected")
        txt(user.Suc, "API connected ("..tostring(kind)..")", 0,255,0)
    else
        API.key = nil
        API.kind = nil
        setStatus("Invalid key")
        txt(user.Error, "Invalid key: " .. tostring(err), 255,0,0)
    end
end

local function onUnsavedKey()
    tb.Text = ""
    API.key = nil
    API.kind = nil
    clearSavedKey()
    setStatus("No key")
    txt(user.Warn, "API unset", 255,255,0)
end

-- wire confirm / unsaved buttons if they exist inside frame
local confirmBtn =
    frame:FindFirstChild("Confirm_api", true)
    or frame:FindFirstChild("ConfirmAPI", true)
local unsavedBtn =
    frame:FindFirstChild("Unsaved_API", true)
    or frame:FindFirstChild("UnsavedAPI", true)

if confirmBtn then confirmBtn.MouseButton1Click:Connect(onConfirmKey) end
if unsavedBtn then unsavedBtn.MouseButton1Click:Connect(onUnsavedKey) end

-- sending logic (single in-flight at a time)
local function sendMessage(prompt)
    if not API.key or not API.kind then
        txt(user.Error, "No API key selected/valid. Click Confirm API.", 255,0,0)
        setStatus("No key")
        return
    end
    if API.busy then
        txt(user.Warn, "Please wait for current request to finish.", 255,255,0)
        return
    end

    API.busy = true
    setStatus("Sending...")
    local displayUser = tostring(Players.LocalPlayer.DisplayName or Players.LocalPlayer.Name)
    txt(user.plr, prompt, 255,255,255) -- your UI function usage

    -- create placeholder AI message
    local aiPlaceholder = txt(user.chat, "🤖 Thinking...", 85,255,255)

    local res, err
    if API.kind == "openai" then
        res, err = requestOpenAI(API.key, prompt)
    elseif API.kind == "google" then
        res, err = requestGoogleGemini(API.key, prompt)
    else
        err = "unsupported provider"
    end

    if res then
        -- show AI reply
        aiPlaceholder.Text = tostring(user.chat) .. tostring(res)
        setStatus("Connected")
    else
        aiPlaceholder.Text = tostring(user.chat) .. "Error: " .. tostring(err)
        setStatus("Invalid key")
    end

    API.busy = false
end

-- hook Send button
se.MouseButton1Click:Connect(function()
    local txtmsg = tostring(ch.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if txtmsg == "" then return end
    -- clear input immediately (like chat)
    ch.Text = ""
    -- send (spawn to not block UI)
    task.spawn(function() sendMessage(txtmsg) end)
end)

-- also allow Enter on the textbox (FocusLost with enter)
ch.FocusLost:Connect(function(enter)
    if enter then
        local txtmsg = tostring(ch.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if txtmsg ~= "" then
            ch.Text = ""
            task.spawn(function() sendMessage(txtmsg) end)
        end
    end
end)

-- helper to set status initial
if API.key then
    setStatus("Loaded key ("..tostring(API.kind)..")")
else
    setStatus("No key")
end

-- done
txt(user.Info, "Chat connector initialized.", 0,170,255)
