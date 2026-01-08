-- gpt 4.1

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
txt(user.Nill, "Version: Test 4.1 | © Copyright LighterCyan", 180, 180, 180)
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
-- AI-OpenSource: Integration + Command System + HTTP queue + GlobalChat/SpyChat
-- Put this after your UI-creation code (it will try to find the existing UI)
-- Assumes you already have `txt(user, text, r,g,b)` and `user` table defined
-- and `safeTxt(u,t,r,g,b)` helper optionally present.

-- ===== SERVICES & HELPERS =====
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local jsonEncode = function(t) return HttpService:JSONEncode(t) end
local jsonDecode = function(s) local ok, v = pcall(HttpService.JSONDecode, HttpService, s) if ok then return v end return nil end

-- http request function (executor friendly)
local httpRequestFunc = (syn and syn.request) or (httprequest or http_request or request) or (http and http.request)

-- safe print into your chat logs
local function safeTxt(u,t,r,g,b)
    if type(txt) == "function" then
        pcall(txt, u, t, r or 255, g or 255, b or 255)
    end
end

-- small util
local function trim(s) return (tostring(s):gsub("^%s+", ""):gsub("%s+$","")) end
local function splitWords(s)
    local t = {}
    for w in tostring(s):gmatch("%S+") do table.insert(t,w) end
    return t
end

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

-- try to find immediately
local UI = findChatUI(6)
if not UI then
    safeTxt(user.Error, "Could not find chat UI. Check path CoreGui.ExperienceSettings.Menu.AIOpenSource", 255,0,0)
    -- still continue (commands that don't require UI may work)
else
    safeTxt(user.Info, "Chat UI connected", 0,170,255)
end

-- local shortcuts (may be nil)
local ch = UI and UI.ch or nil
local se = UI and UI.se or nil
local tb = UI and UI.tb or nil
local si = UI and UI.si or nil
local st = UI and UI.st or nil

-- ===== STATUS & API MANAGEMENT =====
local currentProvider = nil -- "openai"|"gemini"|"custom"
local currentApiKey = nil
local currentCustomUrl = nil
local currentCustomAuth = nil
local currentModel = "gpt-4o-mini"

local RATE = { nextAvailable = 0 } -- epoch seconds when next allowed
local HTTP_ENABLED = (httpRequestFunc ~= nil)

local function updateStatusText(s)
    if st and st:IsA("TextLabel") then
        pcall(function() st.Text = "Status: "..tostring(s) end)
    else
        -- fallback: print to si or chat
        safeTxt(user.Nill, "Status: "..tostring(s), 180,180,180)
    end
end

-- simple local save/load using writefile/readfile if available
local saveFileName = "ai_open_source_key.json"
local function saveApiKeyToFile(obj)
    if writefile then
        local ok, j = pcall(function() return jsonEncode(obj) end)
        if ok then
            pcall(function() writefile(saveFileName, j) end)
            return true
        end
    end
    return false
end
local function loadApiKeyFromFile()
    if isfile and isfile(saveFileName) and readfile then
        local ok, c = pcall(function() return readfile(saveFileName) end)
        if ok and c then
            local data = jsonDecode(c)
            if type(data) == "table" then
                return data
            end
        end
    end
    return nil
end

local function setApiKey(provider, key, customUrl, customAuth, save)
    provider = provider or "openai"
    currentProvider = provider
    currentApiKey = key
    currentCustomUrl = customUrl
    currentCustomAuth = customAuth
    updateStatusText("Key set (unconfirmed)")
    if save then
        saveApiKeyToFile({ provider = provider, key = key, url = customUrl, auth = customAuth })
        updateStatusText("Key set (saved)")
    end
end

local function unsaveApiKey()
    currentProvider = nil
    currentApiKey = nil
    currentCustomUrl = nil
    currentCustomAuth = nil

    if isfile and isfile(saveFileName) and (writefile or delfile) then
        pcall(function()
            if delfile then
                delfile(saveFileName)
            end
        end)
    end

    updateStatusText("No key")
end

-- try load saved at start
do
    local data = loadApiKeyFromFile()
    if data and data.key then
        currentProvider = data.provider
        currentApiKey = data.key
        currentCustomUrl = data.url
        currentCustomAuth = data.auth
        updateStatusText("Key loaded (unconfirmed)")
    end
end

-- confirm buttons (if present)
local function onConfirmClicked()
    if not currentApiKey or currentApiKey == "" then
        safeTxt(user.Warn, "No API key to confirm", 255,255,0)
        return
    end
    -- do validation in background (non-blocking)
    updateStatusText("Connecting")
    safeTxt(user.Info, "Validating key (takes ~10-20s)...", 0,170,255)
    -- we will start a minimal test request (skip heavy calls)
    -- askAI will handle validation using skip validation param
    -- run in spawned thread:
    task.spawn(function()
        local ok, err = nil, nil
        -- use a lightweight request depending on provider
        if not HTTP_ENABLED then
            ok = false err = "Executor HTTP unavailable"
        else
            -- we will call a small request but do not charge big: use model-less ping or minimal usage
            -- Use askAI below with skipRateLimit true for validation
            local done = false
            local result, rerr = nil, nil
            -- call askAI
            local waiter = {}
            local function cbSuccess(res) result = res done = true end
            local function cbErr(e) result = nil rerr = e done = true end
            -- call generic test: send "hello" with very small logic
            pcall(function()
                askAI("Hello", cbSuccess, cbErr, {validateOnly=true, timeout=15})
            end)
            local start = tick()
            while not done and tick() - start < 20 do task.wait(0.2) end
            if done and result then ok = true else ok = false err = rerr or "validation failed" end
        end
        if ok then
            updateStatusText("Connected ("..tostring(currentProvider or "unknown")..")")
            safeTxt(user.Suc, (currentProvider == "openai" and "ChatGPT key valid") or (currentProvider == "gemini" and "Gemini key valid") or "Key valid", 0,255,0)
        else
            updateStatusText("Invalid key")
            safeTxt(user.Error, "Key validation failed: "..tostring(err), 255,0,0)
        end
    end)
end

local function onUnsavedApiClicked()
    -- unsave and mark unsaved
    unsaveApiKey()
    updateStatusText("Unsave key")
    safeTxt(user.Warn, "API key removed", 255,255,0)
end

-- wire confirm/unsaved UI buttons if exist
if UI and UI.root then
    local root = UI.root

    -- try common explicit names first
    local confirmBtn = root:FindFirstChild("Confirm_api") or root:FindFirstChild("Confirm_API")
    local unsavedBtn = root:FindFirstChild("Unsaved_API") or root:FindFirstChild("UnsavedApi")

    -- If not found at root, check textFrame (if present)
    if UI.textFrame then
        confirmBtn = confirmBtn or UI.textFrame:FindFirstChild("Confirm_api") or UI.textFrame:FindFirstChild("Confirm_API")
        unsavedBtn = unsavedBtn or UI.textFrame:FindFirstChild("Unsaved_API") or UI.textFrame:FindFirstChild("UnsavedApi")
    end

    -- fallback: try FindFirstChildWhichIsA safely (pcall in case API is blocked)
    if not confirmBtn then
        local ok, cb = pcall(function()
            return root:FindFirstChildWhichIsA("TextButton")
        end)
        if ok and cb then confirmBtn = cb end
    end

    if not confirmBtn and UI.textFrame then
        local ok, cb = pcall(function()
            return UI.textFrame:FindFirstChildWhichIsA("TextButton")
        end)
        if ok and cb then confirmBtn = cb end
    end

    -- connect handlers if the found objects are actually TextButtons
    if confirmBtn and confirmBtn:IsA("TextButton") then
        confirmBtn.MouseButton1Click:Connect(onConfirmClicked)
    end
    if unsavedBtn and unsavedBtn:IsA("TextButton") then
        unsavedBtn.MouseButton1Click:Connect(onUnsavedApiClicked)
    end
end

-- ===== HTTP request queue + rate-limit handling =====
local RequestQueue = {}
local QueueRunning = false

local function doRawRequest(req)
    -- req = { Url, Method, Headers, Body } -> returns (ok, responseTable or errorString)
    if not httpRequestFunc then return false, "no http executor" end
    local ok, res = pcall(function()
        return httpRequestFunc(req)
    end)
    if not ok then return false, res end
    return true, res
end

local function processQueue()
    if QueueRunning then return end
    QueueRunning = true
    task.spawn(function()
        while #RequestQueue > 0 do
            local item = table.remove(RequestQueue, 1)
            local now = os.time()
            if now < (RATE.nextAvailable or 0) and not item.skipRate then
                -- wait until allowed
                local waitSec = (RATE.nextAvailable - now)
                task.wait(waitSec)
            end

            -- perform request
            local ok, res = doRawRequest(item.req)
            if not ok then
                -- network/executor error -> callback error
                if item.onError then
                    pcall(item.onError, res)
                end
            else
                -- check HTTP status codes & handle 429
                local status = tonumber(res.StatusCode or res.status or res.Status) or 0
                if status == 429 then
                    -- Rate limited: compute retry from Retry-After header or backoff
                    local retryAfter = tonumber(res.Headers and (res.Headers["Retry-After"] or res.Headers["retry-after"]) ) or nil
                    local backoff = retryAfter or (item.retryCount and (2 ^ item.retryCount) or 2)
                    RATE.nextAvailable = os.time() + (backoff or 3)
                    -- re-enqueue with incremented retryCount up to limit
                    item.retryCount = (item.retryCount or 0) + 1
                    if item.retryCount <= 5 then
                        table.insert(RequestQueue, 1, item) -- requeue front
                        if item.onError then pcall(item.onError, "429 Rate limited; retrying in "..tostring(backoff or 3).."s") end
                    else
                        if item.onError then pcall(item.onError, "429 Rate limited; max retries reached") end
                    end
                else
                    -- success-ish
                    if item.onSuccess then
                        pcall(item.onSuccess, res)
                    end
                end
            end
            task.wait(0.05) -- small gap to avoid hammering
        end
        QueueRunning = false
    end)
end

local function enqueueRequest(req, onSuccess, onError, skipRate)
    table.insert(RequestQueue, { req = req, onSuccess = onSuccess, onError = onError, skipRate = skipRate })
    processQueue()
end

-- convenience doRequest wrapper returns (ok, response) synchronously-ish via pcall and callback
local function doRequestBlocking(rawReq)
    local done, ok, res = false, false, nil
    local function sOnSuccess(r) ok, res, done = true, r, true end
    local function sOnError(e) ok, res, done = false, e, true end
    enqueueRequest(rawReq, sOnSuccess, sOnError, true)
    local maxWait = 20
    local t0 = tick()
    while not done and (tick()-t0) < maxWait do task.wait(0.05) end
    return ok, res
end

-- ===== Endpoints builder =====
local function endpointsFor(provider)
    provider = provider or "openai"
    if provider == "gemini" then
        return {
            url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
            makeHeaders = function(key)
                return {
                    ["Content-Type"] = "application/json",
                    ["x-goog-api-key"] = key
                }
            end,
            makeBody = function(prompt)
                -- minimal attempt for Gemini; real API might require different shape
                return jsonEncode({
                    prompt = {
                        text = prompt
                    }
                })
            end,
            parseResult = function(bodyText)
                local d = jsonDecode(bodyText)
                if not d then return nil, "decode failed" end
                if d.candidates and d.candidates[1] and d.candidates[1].content and d.candidates[1].content.parts then
                    return d.candidates[1].content.parts[1].text
                elseif d.outputText then
                    return d.outputText
                end
                return nil, "no text"
            end
        }
    elseif provider == "custom" then
        -- custom endpoint expects currentCustomUrl present
        return {
            url = currentCustomUrl,
            makeHeaders = function(key)
                return {
                    ["Content-Type"] = "application/json",
                    ["Authorization"] = (currentCustomAuth and ("Bearer "..currentCustomAuth)) or nil
                }
            end,
            makeBody = function(prompt)
                return jsonEncode({ input = prompt })
            end,
            parseResult = function(bodyText)
                local d = jsonDecode(bodyText)
                if not d then return nil, "decode failed" end
                if d.result then return d.result end
                if d.output then return d.output end
                return nil, "no text"
            end
        }
    else
        -- openai responses endpoint
        return {
            url = "https://api.openai.com/v1/responses",
            makeHeaders = function(key)
                return {
                    ["Content-Type"] = "application/json",
                    ["Authorization"] = "Bearer " .. (key or "")
                }
            end,
            makeBody = function(prompt, model)
                local m = model or currentModel or "gpt-4o-mini"
                return jsonEncode({
                    model = m,
                    input = prompt
                })
            end,
            parseResult = function(bodyText)
                local d = jsonDecode(bodyText)
                if not d then return nil, "decode failed" end
                -- many shapes: try a few
                if d.output and d.output[1] and d.output[1].content then
                    for _, item in ipairs(d.output[1].content) do
                        if item.type == "output_text" and item.text then return item.text end
                    end
                end
                if d.choices and d.choices[1] and d.choices[1].message and d.choices[1].message.content then
                    return d.choices[1].message.content
                end
                if d.results and d.results[1] and d.results[1].output and d.results[1].output[1] and d.results[1].output[1].content then
                    for _,p in ipairs(d.results[1].output[1].content) do
                        if p.type == "output_text" and p.text then return p.text end
                    end
                end
                return nil, "no text"
            end
        }
    end
end

-- ===== askAI function (one-shot) =====
-- options = { validateOnly=true/false, timeout=seconds, skipRateLimit=true }
function askAI(prompt, onSuccess, onError, options)
    options = options or {}
    if not HTTP_ENABLED then
        if onError then pcall(onError, "HTTP executor not available") end
        return
    end
    if not currentProvider then
        if onError then pcall(onError, "Not connected to any API (no key)") end
        return
    end
    local ep = endpointsFor(currentProvider)
    if not ep then
        if onError then pcall(onError, "No endpoint") end
        return
    end
    local body = ep.makeBody(prompt, currentModel)
    local headers = ep.makeHeaders(currentApiKey or currentCustomAuth)
    if not headers then headers = { ["Content-Type"] = "application/json" } end
    local req = {
        Url = ep.url,
        Method = "POST",
        Headers = headers,
        Body = body
    }
    -- callbacks: wrap to parse later
    local function onSuccessRaw(resp)
        local bodyText = resp.Body or resp.body or resp.BodyText
        local ok, parsed = pcall(ep.parseResult, bodyText)
        if ok and parsed then
            if onSuccess then pcall(onSuccess, parsed) end
        else
            if onError then pcall(onError, parsed or "parse error") end
        end
    end
    local function onErrorRaw(err)
        if onError then pcall(onError, err) end
    end

    enqueueRequest(req, onSuccessRaw, onErrorRaw, options.skipRateLimit)
end

-- ===== COMMANDS & CHAT LINK =====
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
/CheckAPI
/EnableUSLD - enable unknown-language debug printing to logs
/GlobalChat [on/off] - show global chat in logs (client-side UI parsing)
/SpyChat [on/off] - attempt to show whispers if client UI exposes them (not guaranteed)
/ResetRateLimit or /ReRateLimit
/Dumpstatus
]=]

local DEBUG_MODE = false
local function setDebug(flag) DEBUG_MODE = flag and true or false safeTxt(user.Suc, "Debug: "..tostring(DEBUG_MODE), 0,255,0) end

-- clear chat logs (si)
local function clearChatLogs()
    if not si then return end
    for _,v in ipairs(si:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
end

-- evaluate math safely
local function calculate(expr)
    local ok, f = pcall(function() return loadstring("return "..expr) end)
    if not ok or not f then return nil, "invalid expression" end
    local suc, res = pcall(f)
    if not suc then return nil, res end
    return res
end

-- open website helper
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

-- command handler
local function handleCommand(msg)
    local lower = tostring(msg or ""):lower()
    if lower:match("^/help") then
        safeTxt(user.Nill, "What is AI-OpenSource?", 180,180,180)
        for line in HELP_TEXT:gmatch("[^\n]+") do safeTxt(user.Nill, line, 180,180,180) end
        return true
    end
    if lower:match("^/cleartext") then clearChatLogs(); safeTxt(user.Suc,"Chat cleared",0,255,0); return true end
    if lower:match("^/cal") or lower:match("^/calculate") then
        local expr = msg:match("^/%S+%s+(.+)$") or ""
        if expr=="" then safeTxt(user.Error,"Usage: /cal [expression]",255,0,0); return true end
        local res, err = calculate(expr)
        if not res then safeTxt(user.Error,"Math error: "..tostring(err),255,0,0) else safeTxt(user.Suc,"Result = "..tostring(res),0,255,0) end
        return true
    end
    if lower:match("^/addapi") then
        local args = splitWords(msg)
        if #args < 3 then safeTxt(user.Error,"Usage: /addapi [ChatGPT/Gemini/custom] [API or URL] [APIKEY(if custom)] [yes/no]",255,0,0); return true end
        local name = args[2]:lower()
        if name == "custom" then
            local url = args[3]; local apikey = args[4]; local confirm = args[5]
            if not url then safeTxt(user.Error,"Usage: /addapi custom <URL> [APIKEY] [yes/no]",255,0,0); return true end
            currentProvider = "custom"; currentCustomUrl = url; currentCustomAuth = apikey; currentApiKey = apikey
            if confirm and confirm:lower()=="yes" then saveApiKeyToFile({ provider = "custom", key = apikey, url = url, auth = apikey }); updateStatusText("Custom set (saved)"); safeTxt(user.Suc,"Custom saved",0,255,0)
            else updateStatusText("Custom set (unsaved)"); safeTxt(user.Info,"Custom set. Use ... yes to save",0,170,255) end
            return true
        else
            local provider = (name:match("chat") and "openai") or (name:match("gemini") and "gemini") or nil
            local key = args[3]; local confirm = args[4]
            if not provider or not key then safeTxt(user.Error,"Usage: /addapi [ChatGPT/Gemini] [API] [yes/no]",255,0,0); return true end
            currentApiKey = key; currentProvider = provider
            if confirm and confirm:lower()=="yes" then saveApiKeyToFile({ provider = provider, key = key }); updateStatusText("Key set (saved)"); safeTxt(user.Suc,"Key saved",0,255,0)
            else updateStatusText("Key set (unconfirmed)"); safeTxt(user.Info,"Key set. Use confirm to validate",0,170,255) end
            return true
        end
    end
    if lower:match("^/unsaveapi") or lower:match("^/unapi") then unsaveApiKey(); return true end
    if lower:match("^/openwebsiteinexperience") or lower:match("^/owine") then
        local url = msg:match("^/%S+%s+(.+)$") or ""
        url = trim(url)
        if url=="" then safeTxt(user.Error,"Usage: /OpenWebsiteInExperience [URL]",255,0,0) return true end
        local ok,e = openWebsiteInExperience(url)
        if ok then safeTxt(user.Suc,"Opened website: "..url,0,255,0) else safeTxt(user.Error,"OpenWebsite failed: "..tostring(e),255,0,0) end
        return true
    end
    if lower:match("^/loadstring") then
        local url = msg:match("^/%S+%s+(.+)$") or ""
        url = trim(url)
        if url=="" then safeTxt(user.Error,"Usage: /loadstring [URL]",255,0,0); return true end
        safeTxt(user.Sys,"Fetching loadstring...",255,90,0)
        local ok,res = pcall(function() return loadstring(game:HttpGet(url))() end)
        if ok then safeTxt(user.Suc,"loadstring executed",0,255,0) else safeTxt(user.Error,"loadstring error: "..tostring(res),255,0,0) end
        return true
    end
    if lower:match("^/script") then
        local code = msg:match("^/%S+%s+(.+)$") or ""
        code = code:gsub("^%[%[",""):gsub("%]%]$","")
        if code=="" then safeTxt(user.Error,"Usage: /script [[CODE]]",255,0,0); return true end
        safeTxt(user.Sys,"Executing script...",255,90,0)
        local fn,err = loadstring(code)
        if not fn then safeTxt(user.Error,"Compile error: "..tostring(err),255,0,0) else local ok,r = pcall(fn) if ok then safeTxt(user.Suc,"Script executed",0,255,0) else safeTxt(user.Error,"Runtime error: "..tostring(r),255,0,0) end end
        return true
    end
    if lower:match("^/debug%s+(on|off)") then local flag = msg:match("^/debug%s+(on|off)"); setDebug(flag=="on"); return true end
    if lower:match("^/checkhttp") then safeTxt(user.Info,"Executor HTTP available: "..tostring(HTTP_ENABLED),0,170,255); return true end
    if lower:match("^/checkurlstatus") then
        local url = msg:match("^/%S+%s+(.+)$") or ""; url = trim(url)
        if url=="" then safeTxt(user.Error,"Usage: /CheckURLStatus [URL]",255,0,0); return true end
        local ok,res = doRequestBlocking({ Url = url, Method = "HEAD" })
        if not ok then safeTxt(user.Error,"Request error: "..tostring(res),255,0,0) else safeTxt(user.Info,"URL status: "..tostring(res.StatusCode or res.status or "unknown"),0,170,255) end
        return true
    end
    if lower:match("^/checksyn") then safeTxt(user.Info,"syn.request available: "..tostring((syn and syn.request) and true or false),0,170,255); return true end
    if lower:match("^/enableusld") then safeTxt(user.Info,"USLD enabled (will log unknown types)",0,170,255); return true end

    -- GlobalChat toggle
    if lower:match("^/globalchat") then
        local arg = msg:match("^/globalchat%s+(.+)$") or ""
        arg = trim(arg):lower()
        if arg == "on" then startGlobalChat() elseif arg == "off" then stopGlobalChat() else safeTxt(user.Info,"Usage: /GlobalChat on|off",0,170,255) end
        return true
    end
    -- SpyChat toggle
    if lower:match("^/spychat") then
        local arg = msg:match("^/spychat%s+(.+)$") or ""
        arg = trim(arg):lower()
        if arg == "on" then startSpyChat() elseif arg == "off" then stopSpyChat() else safeTxt(user.Info,"Usage: /SpyChat on|off (client-only)",0,170,255) end
        return true
    end

    return false
end

-- ===== Extra commands: ResetRateLimit / CheckAPI / DumpStatus / InstanceTool =====

-- helper: mask key
local function maskKey(k)
    if not k or k == "" then return "<none>" end
    local s = tostring(k)
    if #s > 10 then
        return s:sub(1,4) .. "..." .. s:sub(-4)
    else
        return "****"
    end
end

-- Reset rate limit
local function resetRateLimit()
    RATE.nextAvailable = 0
    safeTxt(user.Suc, "Rate limit reset; requests allowed now.", 0,255,0)
    if st then pcall(function() st.Text = "Status: Rate reset" end) end
end

-- Check API: lightweight validation by asking "ping" (non-blocking)
local function checkApiKey()
    if not currentProvider or not currentApiKey then
        safeTxt(user.Error, "No API key set.", 255,0,0)
        return
    end
    safeTxt(user.Info, "Checking API key (light request)...", 0,170,255)
    -- askAI will enqueue. Provide small prompt and short timeout via callback logic
    local done = false
    askAI("Say 'pong' if you are reachable.", function(answer)
        done = true
        safeTxt(user.Suc, "API responded: "..tostring(answer), 0,255,0)
        updateStatusText("Connected ("..tostring(currentProvider)..")")
    end, function(err)
        done = true
        safeTxt(user.Error, "API check failed: "..tostring(err), 255,0,0)
        updateStatusText("Invalid key")
    end, { skipRateLimit = true })
    -- we don't block here; result will appear in chat via callbacks
end

-- Dump status
local function dumpStatus()
    local p = currentProvider or "<none>"
    local keymask = maskKey(currentApiKey)
    local model = currentModel or "<none>"
    local http = tostring((httpRequestFunc ~= nil))
    local qlen = #RequestQueue
    local nextAvail = RATE.nextAvailable or 0
    safeTxt(user.Nill, "===== DumpStatus =====", 180,180,180)
    safeTxt(user.Nill, "Provider: "..tostring(p), 180,180,180)
    safeTxt(user.Nill, "API: "..keymask, 180,180,180)
    safeTxt(user.Nill, "Model: "..tostring(model), 180,180,180)
    safeTxt(user.Nill, "HTTP executor: "..http, 180,180,180)
    safeTxt(user.Nill, "Queue length: "..tostring(qlen), 180,180,180)
    safeTxt(user.Nill, "Rate next available (epoch): "..tostring(nextAvail).." (now="..tostring(os.time())..")", 180,180,180)
    safeTxt(user.Nill, "Debug: "..tostring(DEBUG_MODE), 180,180,180)
    if st then pcall(function() st.Text = "Status: Dumped" end) end
end

-- parse helper: comma or space separated numbers -> table
local function parseNumberList(s)
    s = s or ""
    s = s:gsub("[%(%)]", "") -- remove parentheses
    local parts = {}
    for num in s:gmatch("[-%d%.]+") do
        table.insert(parts, tonumber(num))
    end
    return parts
end

-- parse color rgb "r,g,b" -> Color3
local function parseColor3(s)
    local nums = parseNumberList(s)
    if #nums >= 3 then
        local r,g,b = nums[1], nums[2], nums[3]
        return Color3.fromRGB(math.clamp(math.floor(r or 0),0,255), math.clamp(math.floor(g or 0),0,255), math.clamp(math.floor(b or 0),0,255))
    end
    return nil
end

-- parse vector3 "1,2,3" -> Vector3
local function parseVector3(s)
    local nums = parseNumberList(s)
    if #nums >= 3 then
        return Vector3.new(nums[1], nums[2], nums[3])
    end
    return nil
end

-- InstanceTool creator (client-side Tool in Backpack)
local function createInstanceTool(argsStr)
    -- expected format tolerant: (/InstanceTool NAME PARTSIZE MESHID TEXTUREID MESHOFFSET COLOR3 TOOLIMAGE [[CODE]])
    -- we'll split by spaces but allow quoted NAME and final [[CODE]]
    local code = nil
    local codeMatch = argsStr:match("%[%[.-%]%]")
    if codeMatch then
        code = codeMatch:sub(3,-3) -- remove [[ ]]
        argsStr = argsStr:gsub("%[%[.-%]%]","")
    end

    -- name in quotes?
    local name = argsStr:match('^%s*%"(.-)%"') or argsStr:match("^%s*'([^']+)'") or argsStr:match("^%s*(%S+)")
    if not name then safeTxt(user.Error, "InstanceTool: missing name",255,0,0); return end

    -- remove name from args
    local rest = argsStr:gsub('^%s*%"(.-)%"',''):gsub("^%s*'([^']+)'",""):gsub("^%s*%S+","",1)
    rest = rest or ""
    local parts = {}
    for token in rest:gmatch("%S+") do table.insert(parts, token) end

    -- map parts
    local partSizeStr = parts[1] or "1,1,1"
    local meshId = parts[2] or ""
    local textureId = parts[3] or ""
    local meshOffsetStr = parts[4] or "0,0,0"
    local colorStr = parts[5] or "255,255,255"
    local toolImage = parts[6] or ""

    local sizeVec = parseVector3(partSizeStr) or Vector3.new(1,1,1)
    local msOffset = parseVector3(meshOffsetStr) or Vector3.new(0,0,0)
    local col = parseColor3(colorStr) or Color3.fromRGB(255,255,255)

    -- create tool safely
    local ok, err = pcall(function()
        local tool = Instance.new("Tool")
        tool.Name = tostring(name)
        tool.RequiresHandle = true
        -- create handle
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = sizeVec
        handle.Color = col
        handle.Material = Enum.Material.Plastic
        handle.CanCollide = false
        handle.Parent = tool

        -- mesh
        if tonumber(meshId) and tonumber(meshId) > 0 then
            local mesh = Instance.new("SpecialMesh", handle)
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = "rbxassetid://"..tostring(meshId)
            if tonumber(textureId) and tonumber(textureId) > 0 then
                mesh.TextureId = "rbxassetid://"..tostring(textureId)
            end
            mesh.Offset = msOffset
        end

        -- tool image
        if tonumber(toolImage) and tonumber(toolImage) > 0 then
            pcall(function() tool.TextureId = "rbxassetid://"..tostring(toolImage) end)
        end

        -- add script if provided
        if code and code ~= "" then
            local ls = Instance.new("LocalScript")
            ls.Name = "ToolClientScript"
            ls.Source = code
            ls.Parent = tool
        end

        -- parent tool to backpack
        local backpack = LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:WaitForChild("Backpack", 2)
        if backpack then
            tool.Parent = backpack
            safeTxt(user.Suc, "InstanceTool created and placed in Backpack: "..tostring(tool.Name), 0,255,0)
        else
            -- fallback: put in StarterGui temporarily
            tool.Parent = game:GetService("StarterGui")
            safeTxt(user.Warn, "Backpack not found; tool placed in StarterGui", 255,255,0)
        end
    end)
    if not ok then
        safeTxt(user.Error, "InstanceTool failed: "..tostring(err), 255,0,0)
    end
end

-- Now extend handleCommand to include these new commands (if your handleCommand is a single function, add the branches below)
-- If you already have handleCommand, just add these `if` blocks inside it.

-- Add these checks inside your existing handleCommand function (preferably near other /check* commands):

-- /ResetRateLimit or /ReRateLimit
if lower:match("^/resetratelimit") or lower:match("^/reratelimit") then
    resetRateLimit()
    return true
end

-- /CheckAPI
if lower:match("^/checkapi") then
    checkApiKey()
    return true
end

-- /DumpStatus
if lower:match("^/dumpstatus") then
    dumpStatus()
    return true
end

-- /InstanceTool
if lower:match("^/instancetool") then
    local args = msg:match("^/%S+%s+(.+)$") or ""
    if args == "" then
        safeTxt(user.Error, "Usage: /InstanceTool \"NAME\" PARTSIZE MESHID TEXTUREID MESHOFFSET COLOR3 TOOLIMAGE [[CODE]]", 255,0,0)
        return true
    end
    -- call creator (non-blocking)
    task.spawn(function() createInstanceTool(args) end)
    return true
end

-- End of added command blocks

-- ===== CHAT SEND LINK (connect ch & se) =====
local function doSendMessageFromUI()
    if not ch then return end
    local message = trim(ch.Text or "")
    if message == "" then return end
    -- command?
    if message:sub(1,1) == "/" then
        local handled = handleCommand(message)
        if not handled then safeTxt(user.Error, "Unknown command. Type /help", 255,0,0) end
        ch.Text = ""
        return
    end
    -- normal: display user and ask AI
    safeTxt(user.plr, message, 255,255,255)
    ch.Text = "" -- clear input
    -- ask AI
    askAI(message, function(answer)
        safeTxt(user.chat, answer or "(no reply)", 85,255,255)
    end, function(err)
        safeTxt(user.Error, "AI request failed: "..tostring(err), 255,0,0)
    end)
end

if se and se:IsA("GuiButton") then
    se.MouseButton1Click:Connect(doSendMessageFromUI)
end
if ch and ch:IsA("TextBox") then
    ch.FocusLost:Connect(function(enter) if enter then doSendMessageFromUI() end end)
end

-- ===== GLOBALCHAT LISTENER (client-side) =====
-- The code below is exactly the earlier listener; ensure it's defined before we reference it in commands
local GLOBAL_CHAT = { connected = false, conn = nil, root = nil }

local function parseTextMessage(node)
    if not node then return nil end
    local body = (node:FindFirstChild("BodyText") and tostring(node.BodyText.Text or "")) or ""
    local prefix = (node:FindFirstChild("PrefixText") and tostring(node.PrefixText.Text or "")) or ""
    body = trim(body); prefix = trim(prefix)
    if body == "" then return nil end
    return { prefix = prefix, body = body }
end

local function showGlobalMessage(prefix, body)
    if not body then return end
    local display = "[" .. (prefix ~= "" and prefix or "Unknown") .. "] " .. body
    safeTxt(user.Nill, display, 180,180,180)
end

local function snapshotExisting(root)
    for _,child in ipairs(root:GetChildren()) do
        if child:FindFirstChild("BodyText") then
            local m = parseTextMessage(child)
            if m then showGlobalMessage(m.prefix, m.body) end
        else
            -- search deeper
            for _,d in ipairs(child:GetDescendants()) do
                if d.Name == "BodyText" and d.Parent then
                    local m = parseTextMessage(d.Parent)
                    if m then showGlobalMessage(m.prefix, m.body) end
                end
            end
        end
    end
end

local function onGlobalChildAdded(child)
    task.wait(0.03)
    local msg = nil
    if child:FindFirstChild("BodyText") then msg = parseTextMessage(child) end
    if not msg then
        for _,d in ipairs(child:GetDescendants()) do
            if d.Name == "BodyText" and d.Parent then msg = parseTextMessage(d.Parent); break end
        end
    end
    if msg then showGlobalMessage(msg.prefix, msg.body) end
end

function startGlobalChat()
    if GLOBAL_CHAT.connected then safeTxt(user.Info, "GlobalChat already running", 0,170,255); return true end
    -- try find root ExperienceChat path
    local ok, exp = pcall(function() return CoreGui:FindFirstChild("ExperienceChat") end)
    if not ok or not exp then safeTxt(user.Error, "ExperienceChat UI not found", 255,0,0); return false end
    local function tryFind()
        local cur = exp:FindFirstChild("appLayout")
        if not cur then return nil end
        cur = cur:FindFirstChild("chatWindow") if not cur then return nil end
        cur = cur:FindFirstChild("scrollingView") if not cur then return nil end
        cur = cur:FindFirstChild("bottomLockedScrollView") if not cur then return nil end
        cur = cur:FindFirstChild("RCTScrollView") if not cur then return nil end
        return cur:FindFirstChild("RCTScrollContentView")
    end
    local root = tryFind()
    if not root then safeTxt(user.Error,"Global chat content not found",255,0,0); return false end
    GLOBAL_CHAT.root = root
    snapshotExisting(root)
    GLOBAL_CHAT.conn = root.ChildAdded:Connect(onGlobalChildAdded)
    GLOBAL_CHAT.connected = true
    safeTxt(user.Suc, "GlobalChat started", 0,255,0)
    return true
end

function stopGlobalChat()
    if GLOBAL_CHAT.conn then GLOBAL_CHAT.conn:Disconnect() GLOBAL_CHAT.conn = nil end
    GLOBAL_CHAT.connected = false
    GLOBAL_CHAT.root = nil
    safeTxt(user.Sys, "GlobalChat stopped", 255,90,0)
end

-- ===== SPYCHAT (best-effort client-side) =====
local SPY_CHAT = { connected = false, conn = nil, root = nil }
local function tryFindPrivateChatRoot()
    -- sometimes private chat messages are stored under same ExperienceChat, search for elements named "Private" or "Whisper"
    local ok, exp = pcall(function() return CoreGui:FindFirstChild("ExperienceChat") end)
    if not ok or not exp then return nil end
    for _,d in ipairs(exp:GetDescendants()) do
        local nm = tostring(d.Name):lower()
        if nm:match("private") or nm:match("whisper") or nm:match("direct") then
            local parent = d.Parent
            if parent and parent:FindFirstChild("BodyText") then return parent end
        end
    end
    return nil
end

local function onSpyChildAdded(child)
    task.wait(0.03)
    local m = parseTextMessage(child) or parseTextMessage(child.Parent)
    if m then
        safeTxt(user.Nill, "[WHISPER] "..(m.prefix or "??").." "..(m.body or ""), 200, 120, 255)
    end
end

function startSpyChat()
    if SPY_CHAT.connected then safeTxt(user.Info,"SpyChat already running",0,170,255); return true end
    local root = tryFindPrivateChatRoot()
    if not root then safeTxt(user.Warn,"SpyChat: private/whisper UI not found (client-side). Server-side required.",255,255,0); return false end
    SPY_CHAT.root = root
    SPY_CHAT.conn = root.ChildAdded:Connect(onSpyChildAdded)
    SPY_CHAT.connected = true
    safeTxt(user.Suc, "SpyChat started", 0,255,0)
    return true
end

function stopSpyChat()
    if SPY_CHAT.conn then SPY_CHAT.conn:Disconnect(); SPY_CHAT.conn = nil end
    SPY_CHAT.connected = false
    SPY_CHAT.root = nil
    safeTxt(user.Sys, "SpyChat stopped", 255,90,0)
end

-- ===== Final: expose some functions to _G for debugging if needed =====
_G.AIOpenSource = _G.AIOpenSource or {}
_G.AIOpenSource.startGlobalChat = startGlobalChat
_G.AIOpenSource.stopGlobalChat = stopGlobalChat
_G.AIOpenSource.startSpyChat = startSpyChat
_G.AIOpenSource.stopSpyChat = stopSpyChat
_G.AIOpenSource.askAI = askAI
_G.AIOpenSource.setApiKey = setApiKey
_G.AIOpenSource.unsaveApiKey = unsaveApiKey
_G.AIOpenSource.updateStatusText = updateStatusText

safeTxt(user.Sys, "AI-OpenSource integration loaded", 255,90,0)
updateStatusText((currentProvider and ("Key loaded: "..tostring(currentProvider)) or "No key"))

-- End of file
