-- gpt 3.94 (modified to support HttpService fallback & custom (self-hosted) endpoints)

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
txt(user.Nill, "Version: Test 3.94 (modified) | © Copyright LighterCyan", 180, 180, 180)
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
-- AI-OpenSource: Command + UI glue (PATCH)
-- Paste this after your UI definitions (txt(), user table, etc.)
-- ===========================

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Globals that may already exist (we won't overwrite if set)
_G.AIOpenSource = _G.AIOpenSource or {}
local state = _G.AIOpenSource
state.DEBUG_MODE = state.DEBUG_MODE or false
state.rateLimitUntil = state.rateLimitUntil or 0
state.currentApiKey = state.currentApiKey or nil
state.currentProvider = state.currentProvider or nil -- "openai" / "gemini" / "custom"
state.currentCustomUrl = state.currentCustomUrl or nil
state.currentCustomAuth = state.currentCustomAuth or nil

-- --- Helper: safeTxt wrapper (if txt exists) ---
local function safeTxtWrap(u, t, r,g,b)
    if type(safeTxt) == "function" then
        pcall(safeTxt, u, t, r,g,b)
    elseif type(txt) == "function" then
        pcall(txt, u, t, r,g,b)
    else
        -- fallback print
        print(("[%s] %s"):format(tostring(u), tostring(t)))
    end
end

-- helper mask key
local function maskKey(k)
    if not k or k == "" then return "<none>" end
    local s = tostring(k)
    if #s <= 12 then return s end
    return s:sub(1,6) .. string.rep("*", math.max(0, #s-10)) .. s:sub(-4)
end

-- ------------ UI Lookup (robust) ------------
local ch, se, si, st, con, con2, tb, frame

local function findChild(root, names)
    if not root then return nil end
    for _,n in ipairs(names) do
        local ok, v = pcall(function() return root:FindFirstChild(n) end)
        if ok and v then return v end
    end
    return nil
end

-- candidate roots (common paths you mentioned)
local function findFrameRoot()
    -- Try ExperienceSettings Menu AIOpenSource.Frame
    local ok, es = pcall(function() return CoreGui:FindFirstChild("ExperienceSettings") end)
    if ok and es then
        local menu = es:FindFirstChild("Menu")
        if menu then
            local aio = menu:FindFirstChild("AIOpenSource") or menu:FindFirstChild("ChatGPT") or menu:FindFirstChild("AI-OpenSource")
            if aio then
                local fr = aio:FindFirstChild("Frame") or aio:FindFirstChild("frame") or aio
                if fr then return fr end
            end
            -- fallback to Menu.ChatGPT.Frame
            local chatgpt = menu:FindFirstChild("ChatGPT")
            if chatgpt then
                local f = chatgpt:FindFirstChild("Frame") or chatgpt
                if f then return f end
            end
        end
    end

    -- fallback: search for a ScreenGui containing "AIOpenSource" or Chat logs
    for _, gui in ipairs(CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") or gui:IsA("PlayerGui") then
            local f = gui:FindFirstChild("AIOpenSource") or gui:FindFirstChild("ChatGPT") or gui:FindFirstChild("AI-OpenSource")
            if f then
                local fr = f:FindFirstChild("Frame") or f
                if fr then return fr end
            end
        end
    end

    return nil
end

frame = findFrameRoot()

-- if we couldn't find the frame, attempt to locate chat TextBox anywhere
if frame then
    ch = findChild(frame, {"Text", "TextBox", "chat", "ch", "Chat", "ChatBox"}) and (function()
        local txtframe = findChild(frame, {"Text"})
        if txtframe then
            return findChild(txtframe, {"chat","ch","Chat","ChatText","chatBox"}) or txtframe:FindFirstChildWhichIsA("TextBox")
        end
        -- direct inside frame
        return findChild(frame, {"chat","ch"})
    end)()
    se = findChild(frame, {"Send","se","SendBtn","SendButton"})
    si = findChild(frame, {"ChatLogs","ChatFrame","ChatFrameLogs","ChatLogsFrame"}) or (frame:FindFirstChildWhichIsA("ScrollingFrame") or nil)
    st = findChild(frame, {"Status","st","StatusLabel"})
    tb = findChild(frame, {"api","API","APIKeyBox","apiText"})
    con = findChild(frame, {"Confirm_api","ConfirmAPI","Confirm_api","Confirm_api_Button","Confirm_api"})
    con2 = findChild(frame, {"Unsaved_API","UnsavedAPI","Unsaved_API"})
end

-- extra fallback: find any TextBox named "chat" globally under CoreGui
if not ch then
    for _,gui in ipairs(CoreGui:GetChildren()) do
        local found = gui:FindFirstChildWhichIsA("TextBox", true)
        if found and (found.Name:lower():match("chat") or found.Parent and found.Parent.Name:lower():match("chat")) then
            ch = found
            break
        end
    end
end

-- If si still nil, try common name anywhere
if not si then
    for _,gui in ipairs(CoreGui:GetChildren()) do
        local sf = gui:FindFirstChildWhichIsA("ScrollingFrame", true)
        if sf and sf.Name:lower():match("chat") or (sf.Name:lower():match("log")) then
            si = sf
            break
        end
    end
end

-- safe debug print of found UI
if state.DEBUG_MODE then
    safeTxtWrap(user.Info, ("UI found: ch=%s, se=%s, si=%s, st=%s, con=%s, con2=%s, tb=%s"):format(
        tostring(ch and ch:GetFullName() or "nil"),
        tostring(se and se:GetFullName() or "nil"),
        tostring(si and si:GetFullName() or "nil"),
        tostring(st and st:GetFullName() or "nil"),
        tostring(con and con:GetFullName() or "nil"),
        tostring(con2 and con2:GetFullName() or "nil"),
        tostring(tb and tb:GetFullName() or "nil")
    ), 0,170,255)
end

-- ---- HTTP / executor request wrapper ----
local httpRequestFunc = nil
local function discoverRequest()
    if httpRequestFunc then return httpRequestFunc end
    if type(syn) == "table" and type(syn.request) == "function" then
        httpRequestFunc = function(req) return syn.request(req) end
    elseif type(request) == "function" then
        httpRequestFunc = function(req) return request(req) end
    elseif type(http_request) == "function" then
        httpRequestFunc = function(req) return http_request(req) end
    elseif type(fluxus) == "table" and type(fluxus.request) == "function" then
        httpRequestFunc = function(req) return fluxus.request(req) end
    elseif type(game.HttpGet) == "function" then
        httpRequestFunc = function(req)
            -- limited: only GET supported here
            if req.Method == "GET" or not req.Method then
                local body = game:HttpGet(req.Url, true)
                return { StatusCode = 200, Body = body }
            else
                error("executor does not support POST via game:HttpGet")
            end
        end
    else
        httpRequestFunc = nil
    end
    return httpRequestFunc
end

local function doRequest(req)
    -- req: table { Url, Method, Body, Headers (table), Timeout }
    local func = discoverRequest()
    if not func then error("No HTTP request function available") end
    local ok, res = pcall(function() return func({
        Url = req.Url,
        Method = req.Method or "GET",
        Body = req.Body,
        Headers = req.Headers or {},
        -- Syn/fluxus support "AllowGzip" etc, but keep simple
    }) end)
    if not ok then return nil, res end
    -- normalize response
    local resp = res
    -- if minimal (string) convert
    if type(resp) == "string" then
        return { StatusCode = 200, Body = resp }
    end
    -- Some executors return .status or .StatusCode
    resp.StatusCode = resp.StatusCode or resp.status or resp.Status or resp.Status_Code
    resp.Body = resp.Body or resp.body or resp.ResponseText or resp.data
    return resp
end

-- ---- Utilities ----
local function trim(s) return (s or ""):gsub("^%s+", ""):gsub("%s+$", "") end
local function splitWords(s)
    local t = {}
    for w in tostring(s):gmatch("%S+") do table.insert(t, w) end
    return t
end

local function clearChatLogs()
    if not si then return end
    for _,v in ipairs(si:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
end

local function calculate(expr)
    if not expr or expr == "" then return nil, "empty" end
    -- allow ^ as power? Lua ^ exists
    local ok, fn = pcall(function() return loadstring("return "..expr) end)
    if not ok or not fn then return nil, "invalid expression" end
    local suc, res = pcall(fn)
    if not suc then return nil, res end
    return res
end

local function setDebugMode(flag)
    state.DEBUG_MODE = flag and true or false
    safeTxtWrap(user.Suc, "Debug mode: "..tostring(state.DEBUG_MODE), 0,255,0)
end

-- ---- Status UI updater (st) ----
local function updateStatusText(s)
    if st and st:IsA("TextLabel") then
        pcall(function() st.Text = tostring(s) end)
    else
        safeTxtWrap(user.Info, tostring(s), 0,170,255)
    end
end

-- ---- Save / Load key locally (simple) ----
local KEYFILE = "AIOpenSource_API.json"
local function saveApiKeyToFile(tbl)
    -- tbl: { provider=..., key=..., url=..., auth=... }
    if type(writefile) == "function" and type(jsonEncode) == "function" then
        pcall(function()
            writefile(KEYFILE, jsonEncode(tbl))
        end)
    else
        -- fallback: store in global state
        state._savedKey = tbl
    end
end
local function loadApiKeyFromFile()
    if type(readfile) == "function" and type(jsonDecode) == "function" and isfile(KEYFILE) then
        local ok, data = pcall(function() return jsonDecode(readfile(KEYFILE)) end)
        if ok and type(data) == "table" then return data end
    end
    return state._savedKey or nil
end

-- ---- Key validation (async, slower to avoid quick "Invalid" early) ----
local function validateKeyAsync()
    local key = state.currentApiKey
    if not key or key == "" then
        updateStatusText("No key")
        return false
    end

    -- don't spam: if rate-limited or last validated recently, skip
    if tick() < (state._lastValidateAt or 0) + 10 then
        updateStatusText("Validation queued")
        return false
    end

    state._lastValidateAt = tick()
    updateStatusText("Connecting...")

    -- spawn validate with delay to avoid instant "invalid"
    task.spawn(function()
        -- small delay (10-15s) to match your request to be slower
        task.wait(12)

        local provider = state.currentProvider
        local ok, resp
        local req = {}
        local function setBad(msg) updateStatusText(msg); safeTxtWrap(user.Error, msg, 255,0,0) end

        if provider == "openai" then
            req.Url = "https://api.openai.com/v1/models"
            req.Method = "GET"
            req.Headers = { ["Authorization"] = "Bearer "..tostring(key) }
            ok, resp = pcall(doRequest, req)
            if not ok or not resp then setBad("No response from OpenAI"); return end
            if resp.StatusCode == 200 then
                updateStatusText("Connected (OpenAI)")
                safeTxtWrap(user.Suc, "OpenAI key valid", 0,255,0)
                state.currentProvider = "openai"
                return
            elseif resp.StatusCode == 401 then
                setBad("Invalid OpenAI key (401)")
                return
            elseif resp.StatusCode == 429 then
                state.rateLimitUntil = tick() + 30
                updateStatusText("Rate-limited. Retry later")
                safeTxtWrap(user.Warn, "OpenAI rate-limited (429)", 255,200,0)
                return
            else
                setBad("OpenAI check returned "..tostring(resp.StatusCode))
                return
            end

        elseif provider == "gemini" then
            req.Url = "https://generativelanguage.googleapis.com/v1beta/models"
            req.Method = "GET"
            req.Headers = { ["x-goog-api-key"] = tostring(key) }
            ok, resp = pcall(doRequest, req)
            if not ok or not resp then setBad("No response from Gemini"); return end
            if resp.StatusCode == 200 then
                updateStatusText("Connected (Gemini)")
                safeTxtWrap(user.Suc, "Gemini key valid", 0,255,0)
                state.currentProvider = "gemini"
                return
            elseif resp.StatusCode == 403 or resp.StatusCode == 401 then
                setBad("Invalid Gemini key (401/403)")
                return
            elseif resp.StatusCode == 429 then
                state.rateLimitUntil = tick() + 30
                updateStatusText("Rate-limited. Retry later")
                safeTxtWrap(user.Warn, "Gemini rate-limited (429)", 255,200,0)
                return
            else
                setBad("Gemini check returned "..tostring(resp.StatusCode))
                return
            end

        elseif provider == "custom" and state.currentCustomUrl then
            -- check HEAD
            req.Url = state.currentCustomUrl
            req.Method = "HEAD"
            if state.currentCustomAuth then req.Headers = { Authorization = state.currentCustomAuth } end
            ok, resp = pcall(doRequest, req)
            if not ok or not resp then setBad("No response from custom endpoint"); return end
            if resp.StatusCode and resp.StatusCode < 400 then
                updateStatusText("Connected (custom)")
                safeTxtWrap(user.Suc, "Custom endpoint reachable", 0,255,0)
                return
            else
                setBad("Custom endpoint returned "..tostring(resp.StatusCode))
                return
            end
        else
            updateStatusText("Unknown provider")
            safeTxtWrap(user.Warn, "Unknown provider for validation", 255,200,0)
            return
        end
    end)

    return true
end

-- ---- Hook up Confirm / Unsaved buttons (con, con2) ----
local function onConfirmClicked()
    -- read from tb if exists
    local newKey = nil
    if tb and tb:IsA("TextBox") then newKey = trim(tb.Text) end
    if not newKey or newKey == "" then
        safeTxtWrap(user.Error, "No key in textbox", 255,0,0)
        return
    end

    -- auto detect provider by prefix
    if tostring(newKey):match("^sk") or tostring(newKey):match("^sk%-proj") then
        state.currentProvider = "openai"
        state.currentApiKey = newKey
    elseif tostring(newKey):match("^AIza") then
        state.currentProvider = "gemini"
        state.currentApiKey = newKey
    else
        -- ask user: treat as custom
        state.currentProvider = "custom"
        state.currentCustomUrl = tostring(newKey) -- if they pasted URL
        state.currentApiKey = state.currentCustomAuth -- keep old auth
    end

    updateStatusText("Key set (validating...)")
    safeTxtWrap(user.Info, "Key set, validating in background (takes ~12s)...", 0,170,255)
    validateKeyAsync()
end

local function onUnsavedClicked()
    state.currentApiKey = nil
    state.currentProvider = nil
    state.currentCustomUrl = nil
    state.currentCustomAuth = nil
    updateStatusText("Unsave key")
    safeTxtWrap(user.Suc, "API unsaved", 0,255,0)
end

if con and con:IsA("GuiButton") then
    pcall(function() con.MouseButton1Click:Connect(onConfirmClicked) end)
end
if con2 and con2:IsA("GuiButton") then
    pcall(function() con2.MouseButton1Click:Connect(onUnsavedClicked) end)
end

-- expose functions globally (for other parts of your code)
_G.AIOpenSource.confirmKey = onConfirmClicked
_G.AIOpenSource.unsaveKey = onUnsavedClicked
_G.AIOpenSource.validateKeyAsync = validateKeyAsync

-- ---- Command handler (main). Integrate with your existing handleCommand by calling this first. ----
local HELP_TEXT = [=[
/Help - show commands
/Cal or /Calculate [expr] - safe math uh... maybe but we don't allow × ÷ and =.
/ClearText - clear chat logs
/AddAPI [ChatGPT/Gemini/custom] [API or URL] [APIKEY(if custom)] [yes/no] - add API quickly
    Examples:
      /addapi chatgpt sk-... yes
      /addapi gemini AI... yes
      /addapi custom https://host:8080 myapikey yes
/UnsaveAPI or /UnApi - remove key
/OpenWebsiteInExperience or /OWINE [URL] - open site
/Loadstring [URL] - loadstring(url)()
/Script [[CODE]] - run code
/Debug [on/off] - show debug logs
/CheckHTTP - check executor http availability
/CheckURLStatus [URL] - check website status (HEAD)
/CheckSYN - check syn request availability
/EnableUSLD - enable unknown-language debug printing to logs
/CheckAPI - validate saved API (slow)
/ResetRateLimit or /ReRateLimit - reset local rate-limit state
/DumpStatus - dump internal status
/GlobalChat - attempt to bind server relay for chat (server snippet required)
/SpyChat - attempt to bind whisper relay
/InstanceTool [NAME] [PARTSIZE] [MESHID] [TEXTUREID] [MESHOFFSET] [COLOR3] [TOOLIMAGE] [[CODE]]
]=]

local function handleCommandPatch(msg)
    local lower = tostring(msg or ""):lower()
    if lower:match("^/help") then
        safeTxtWrap(user.Nill, "What is AI-OpenSource?", 180,180,180)
        for line in HELP_TEXT:gmatch("[^\n]+") do safeTxtWrap(user.Nill, line, 180,180,180) end
        return true
    end

    if lower:match("^/cleartext") then
        clearChatLogs()
        safeTxtWrap(user.Suc, "Chat cleared", 0,255,0)
        return true
    end

    if lower:match("^/cal") or lower:match("^/calculate") then
        local expr = msg:match("^/%S+%s+(.+)$") or ""
        if expr == "" then safeTxtWrap(user.Error, "Usage: /cal [expression]",255,0,0) return true end
        local res, err = calculate(expr)
        if not res then safeTxtWrap(user.Error, "Math error: "..tostring(err),255,0,0) else safeTxtWrap(user.Suc, "Result = "..tostring(res),0,255,0) end
        return true
    end

    if lower:match("^/addapi") then
        local args = splitWords(msg)
        if #args < 3 then
            safeTxtWrap(user.Error, "Usage: /addapi [ChatGPT/Gemini/custom] [API or URL] [APIKEY(if custom)] [yes/no]",255,0,0)
            return true
        end
        local name = args[2]:lower()
        if name == "custom" then
            local url = args[3]
            local apikey = args[4]
            local confirm = args[5]
            if not url then safeTxtWrap(user.Error, "Usage: /addapi custom <URL> [APIKEY] [yes/no]",255,0,0) return true end
            state.currentProvider = "custom"
            state.currentCustomUrl = url
            state.currentCustomAuth = apikey and apikey ~= "" and apikey or nil
            state.currentApiKey = state.currentCustomAuth
            if confirm and confirm:lower()=="yes" then
                saveApiKeyToFile({ provider = "custom", key = state.currentCustomAuth, url = state.currentCustomUrl, auth = state.currentCustomAuth })
                updateStatusText("Custom set (saved)")
                safeTxtWrap(user.Suc, "Custom endpoint saved",0,255,0)
            else
                updateStatusText("Custom set (unsaved)")
                safeTxtWrap(user.Info, "Custom endpoint set. Use 'yes' to save: /addapi custom <URL> <APIKEY> yes",0,170,255)
            end
            return true
        else
            local provider = (name:match("chat") and "openai") or (name:match("gemini") and "gemini") or nil
            local key = args[3]
            local confirm = args[4]
            if not provider or not key then safeTxtWrap(user.Error, "Usage: /addapi [ChatGPT/Gemini] [API] [yes/no]",255,0,0) return true end
            state.currentApiKey = key
            state.currentProvider = provider
            if confirm and confirm:lower()=="yes" then
                saveApiKeyToFile({ provider = state.currentProvider, key = key, url = state.currentCustomUrl, auth = state.currentCustomAuth })
                updateStatusText("Key set (saved)")
                safeTxtWrap(user.Suc, "API set and saved (local)",0,255,0)
            else
                updateStatusText("Key set (unconfirmed)")
                safeTxtWrap(user.Info, "Key set. Click Confirm API or /addapi ... yes to validate",0,170,255)
            end
            return true
        end
    end

    if lower:match("^/unsaveapi") or lower:match("^/unapi") then
        onUnsavedClicked()
        return true
    end

    if lower:match("^/openwebsiteinexperience") or lower:match("^/owine") then
        local url = msg:match("^/%S+%s+(.+)$") or ""
        url = url:gsub("^%s+",""):gsub("%s+$","")
        if url == "" then safeTxtWrap(user.Error, "Usage: /OpenWebsiteInExperience [URL]",255,0,0) return true end
        local ok, e = pcall(function()
            -- attempt GuiService.OpenBrowserWindow, fallback to StarterGui:SetCore
            local ok2, err2
            if pcall(function() return game:GetService("GuiService").OpenBrowserWindow end) then
                pcall(function() game:GetService("GuiService"):OpenBrowserWindow(url) end)
                ok2 = true
            else
                if pcall(function() return game:GetService("StarterGui").SetCore end) then
                    pcall(function() game:GetService("StarterGui"):SetCore("OpenBrowserWindow", url) end)
                    ok2 = true
                else
                    ok2 = false
                    err2 = "Service blocked"
                end
            end
            if not ok2 then error(err2) end
        end)
        if ok then safeTxtWrap(user.Suc, "Opened website: "..url,0,255,0) else safeTxtWrap(user.Error, "OpenWebsite failed: "..tostring(e),255,0,0) end
        return true
    end

    if lower:match("^/loadstring") then
        local url = msg:match("^/%S+%s+(.+)$") or ""
        url = url:gsub("^%s+",""):gsub("%s+$","")
        if url == "" then safeTxtWrap(user.Error, "Usage: /loadstring [URL]",255,0,0) return true end
        safeTxtWrap(user.Sys, "Fetching loadstring...",255,90,0)
        local ok, res = pcall(function() return loadstring(game:HttpGet(url))() end)
        if ok then safeTxtWrap(user.Suc, "loadstring executed",0,255,0) else safeTxtWrap(user.Error, "loadstring error: "..tostring(res),255,0,0) end
        return true
    end

    if lower:match("^/script") then
        local code = msg:match("^/%S+%s+(.+)$") or ""
        if code == "" then safeTxtWrap(user.Error, "Usage: /script [[CODE]]",255,0,0) return true end
        code = code:gsub("^%[%[",""):gsub("%]%]$","")
        safeTxtWrap(user.Sys, "Executing script...",255,90,0)
        local fn, err = loadstring(code)
        if not fn then safeTxtWrap(user.Error, "Compile error: "..tostring(err),255,0,0) else
            local ok, r = pcall(fn)
            if ok then safeTxtWrap(user.Suc, "Script executed",0,255,0) else safeTxtWrap(user.Error, "Runtime error: "..tostring(r),255,0,0) end
        end
        return true
    end

    if lower:match("^/debug%s+(on|off)") then
        local flag = msg:match("^/debug%s+(on|off)")
        setDebugMode(flag == "on")
        return true
    end

    if lower:match("^/checkhttp") then
        local ok = discoverRequest() ~= nil
        safeTxtWrap(user.Info, "Executor HTTP available: "..tostring(ok), 0,170,255)
        return true
    end

    if lower:match("^/checkurlstatus") then
        local url = msg:match("^/%S+%s+(.+)$") or ""
        url = url:gsub("^%s+",""):gsub("%s+$","")
        if url == "" then safeTxtWrap(user.Error, "Usage: /CheckURLStatus [URL]",255,0,0) return true end
        local ok, res = pcall(doRequest, { Url = url, Method = "HEAD" })
        if not ok or not res then safeTxtWrap(user.Error, "Request error: "..tostring(res),255,0,0) else safeTxtWrap(user.Info, "URL status: "..tostring(res.StatusCode), 0,170,255) end
        return true
    end

    if lower:match("^/checksyn") then
        safeTxtWrap(user.Info, "syn.request available: "..tostring( (type(syn)=="table" and type(syn.request)=="function") and true or false ), 0,170,255)
        return true
    end

    if lower:match("^/enableusld") then
        safeTxtWrap(user.Info, "USLD enabled (unknown-language debug will print to logs)", 0,170,255)
        state.USLD = true
        return true
    end

    if lower:match("^/checkapi") then
        validateKeyAsync()
        return true
    end

    if lower:match("^/resetratelimit") or lower:match("^/reratelimit") then
        state.rateLimitUntil = 0
        safeTxtWrap(user.Suc, "Rate limit reset", 0,255,0)
        return true
    end

    if lower:match("^/dumpstatus") then
        safeTxtWrap(user.Info, ("Provider: %s"):format(tostring(state.currentProvider or "<none>")), 0,170,255)
        safeTxtWrap(user.Info, ("API: %s"):format(maskKey(state.currentApiKey)), 0,170,255)
        safeTxtWrap(user.Info, ("Rate until: %s (now=%s)"):format(tostring(state.rateLimitUntil), tostring(tick())), 0,170,255)
        safeTxtWrap(user.Info, ("HTTP func: %s"):format(tostring(discoverRequest()~=nil)), 0,170,255)
        return true
    end

    if lower:match("^/globalchat") then
        safeTxtWrap(user.Sys, "Binding GlobalChat (server relay required). See server snippet in code comments.", 255,90,0)
        -- try bind server relay if exists
        local evt = ReplicatedStorage:FindFirstChild("AI_GlobalChatRelay")
        if evt and evt:IsA("RemoteEvent") then
            evt.OnClientEvent:Connect(function(senderName, message, extra) safeTxtWrap(user.Nill, ("[@%s]: %s"):format(senderName, message), 180,180,180) end)
            safeTxtWrap(user.Suc, "GlobalChat relay bound", 0,255,0)
        else
            safeTxtWrap(user.Warn, "No server relay found; server script required", 255,200,0)
        end
        return true
    end

    if lower:match("^/spychat") then
        safeTxtWrap(user.Warn, "SpyChat needs server relay that forwards whispers. See server snippet.", 255,200,0)
        return true
    end

    if lower:match("^/instancetool") then
        -- simple wrapper: pass remainder to InstanceTool parser (we exposed previously in other patch)
        local args = msg:sub((msg:find("%s") or 1) + 1)
        if _G.AIOpenSource_InstanceTool and type(_G.AIOpenSource_InstanceTool) == "function" then
            pcall(_G.AIOpenSource_InstanceTool, args)
        else
            safeTxtWrap(user.Error, "InstanceTool function not available", 255,0,0)
        end
        return true
    end

    return false
end

-- expose to global so your main handleMessage can call this first
_G.AIOpenSource_HandleCommand = handleCommandPatch

-- ---- Send UI glue ----
local function sendMessageFromUI()
    if not ch then safeTxtWrap(user.Warn, "Chat textbox not found", 255,200,0); return end
    local msg = tostring(ch.Text or "")
    msg = trim(msg)
    if msg == "" then return end

    -- if command
    if msg:sub(1,1) == "/" then
        local ok = pcall(function()
            if handleCommandPatch(msg) then
                -- handled
            else
                safeTxtWrap(user.Warn, "Unknown command. Type /help", 255,255,0)
            end
        end)
        if not ok then safeTxtWrap(user.Error, "Command error", 255,0,0) end
        if ch and ch:IsA("TextBox") then pcall(function() ch.Text = "" end) end
        return
    end

    -- normal chat: print user message and ask AI (if askAI exists)
    safeTxtWrap(user.plr, msg, 255,255,255)
    if type(askAI) == "function" then
        -- askAI should be defined in your main AI code; we call it with callback
        askAI(msg, function(answer)
            safeTxtWrap(user.chat, answer or "(no response)", 85,255,255)
        end, function(err)
            safeTxtWrap(user.Error, "AI request failed: "..tostring(err), 255,0,0)
        end)
    else
        safeTxtWrap(user.chat, "(AI not connected)", 85,255,255)
    end

    if ch and ch:IsA("TextBox") then pcall(function() ch.Text = "" end) end
end

-- hook send button and Enter key
if se and se:IsA("GuiButton") then
    pcall(function() se.MouseButton1Click:Connect(sendMessageFromUI) end)
end
if ch and ch:IsA("TextBox") then
    pcall(function() ch.FocusLost:Connect(function(enter) if enter then sendMessageFromUI() end end) end)
end

-- final feedback
safeTxtWrap(user.Info, "AI-OpenSource patch loaded (commands + UI glue). Use /help for commands.", 0,170,255)

-- END OF PATCH
