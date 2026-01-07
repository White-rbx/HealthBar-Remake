-- gpt 3.95

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
txt(user.Nill, "Version: Test 3.95 | © Copyright LighterCyan", 180, 180, 180)
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
-- AI-OpenSource: Unified client-side script (full)
-- Assumptions:
--  - There's a function txt(userLabel, text, r,g,b) already defined.
--  - There's a table `user` already defined (user.plr, user.chat, user.Error, etc).
--  - Some UI was already created: we'll search for it (Frame, Text, ChatLogs, Send, api, Status)
--  - Executor http functions may exist (syn.request, http, request, http_request, fluxus.request, etc.)

-- ============================
-- SAFE HELPERS (do not override txt/user)
-- ============================
local function fallbackPrint(...) print(...) end

local safeTxt = function(u, t, r, g, b)
    if type(txt) == "function" then
        pcall(txt, u, t, r or 255, g or 255, b or 255)
    else
        -- fallback print if txt missing
        pcall(fallbackPrint, tostring(u) .. tostring(t))
    end
end

-- ensure user table exists
user = user or {
    plr  = "You: ",
    chat = "AI: ",
    Error = "Error: ",
    Suc   = "Success: ",
    Warn  = "Warning: ",
    Info  = "Information: ",
    Nill = "",
    Sys = "System: "
}

-- debug flag
local DEBUG_MODE = false
local USLD_ENABLED = false -- unknown script language debug

local function dbg(...)
    if DEBUG_MODE then
        local s = {}
        for i=1,select('#', ...) do table.insert(s, tostring(select(i, ...))) end
        safeTxt(user.Info, table.concat(s, " "), 0,170,255)
    end
end

-- ============================
-- FIND UI (robust)
-- ============================
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function findUI()
    -- try common paths
    local rootCandidates = {}

    -- ExperienceSettings menu if exists
    pcall(function()
        local ex = CoreGui:FindFirstChild("ExperienceSettings") or CoreGui:FindFirstChild("CoreGui")
        if ex and ex:FindFirstChild("Menu") then
            table.insert(rootCandidates, ex.Menu)
        end
    end)

    -- find "AIOpenSource" or "ChatGPT" GUI inside CoreGui
    for _, v in ipairs(CoreGui:GetDescendants()) do
        if v:IsA("Frame") and (v.Name:lower():match("aio") or v.Name:lower():match("chatgpt") or v.Name:lower():match("ai%-opensource") or v.Name:lower():match("aio")) then
            table.insert(rootCandidates, v)
        end
    end

    -- fallback: any ScreenGui with ChatFrame-like child
    for _, sg in ipairs(CoreGui:GetChildren()) do
        if sg:IsA("ScreenGui") then
            for _, c in ipairs(sg:GetDescendants()) do
                if c.Name:lower():match("chatlogs") or c.Name:lower():match("chatframe") or c.Name:lower():match("chat") then
                    table.insert(rootCandidates, sg)
                    break
                end
            end
        end
    end

    -- choose first valid candidate and try to locate subelements
    local chosen = nil
    for _, root in ipairs(rootCandidates) do
        -- try to find Text frame, ChatLogs, Send, api tb, status label
        local frame = root
        local textFrame = frame:FindFirstChild("Text") or frame:FindFirstChild("text") or nil
        local chatTB = nil
        if textFrame then
            chatTB = textFrame:FindFirstChild("chat") or textFrame:FindFirstChild("Chat") or textFrame:FindFirstChildWhichIsA and textFrame:FindFirstChildWhichIsA("TextBox")
        else
            -- maybe in root directly
            chatTB = frame:FindFirstChild("chat") or frame:FindFirstChildWhichIsA and frame:FindFirstChildWhichIsA("TextBox")
        end
        local sendBtn = nil
        if textFrame then
            sendBtn = textFrame:FindFirstChild("Send") or textFrame:FindFirstChild("se") or textFrame:FindFirstChildWhichIsA and textFrame:FindFirstChildWhichIsA("TextButton")
        else
            sendBtn = frame:FindFirstChild("Send") or frame:FindFirstChild("se")
        end
        local chatLogs = frame:FindFirstChild("ChatLogs") or frame:FindFirstChild("ChatFrame") or frame:FindFirstChildWhichIsA and frame:FindFirstChildWhichIsA("ScrollingFrame")
        local apiTB = frame:FindFirstChild("api") or frame:FindFirstChild("API") or (textFrame and (textFrame:FindFirstChild("api") or textFrame:FindFirstChild("API")))
        local statusLabel = frame:FindFirstChild("Status") or frame:FindFirstChild("status") or frame:FindFirstChildWhichIsA and frame:FindFirstChildWhichIsA("TextLabel")
        -- Accept candidate if we found at least chatTB and sendBtn and chatLogs (best)
        if chatTB and sendBtn and chatLogs then
            chosen = {
                root = frame,
                textFrame = textFrame,
                ch = chatTB,
                se = sendBtn,
                si = chatLogs,
                tb = apiTB,
                st = statusLabel
            }
            break
        end
    end

    return chosen
end

local ui = findUI()
local frame = ui and ui.root or nil
local ch = ui and ui.ch or nil
local se = ui and ui.se or nil
local si = ui and ui.si or nil
local tb = ui and ui.tb or nil
local st = ui and ui.st or nil

dbg("UI find:", frame, ch, se, si, tb, st)

-- ============================
-- HTTP wrapper (executor-friendly)
-- ============================
local httpRequestFunc = nil
local httpName = nil

-- detect available request function
if syn and syn.request then
    httpRequestFunc = function(req) return syn.request(req) end; httpName="syn.request"
elseif request then
    httpRequestFunc = request; httpName="request"
elseif http and http.request then
    httpRequestFunc = http.request; httpName="http.request"
elseif http_request then
    httpRequestFunc = http_request; httpName="http_request"
elseif fluxus and fluxus.request then
    httpRequestFunc = fluxus.request; httpName="fluxus.request"
end

local HttpService = game:GetService("HttpService")
local jsonEncode = function(t) return HttpService:JSONEncode(t) end
local jsonDecode = function(s) 
    local ok, v = pcall(function() return HttpService:JSONDecode(tostring(s)) end)
    if ok then return v else return nil end
end

local function doRequest(req)
    -- req: table {Url, Method, Headers, Body, Timeout}
    if not httpRequestFunc then
        error("No executor HTTP available")
    end
    local ok, res = pcall(function()
        return httpRequestFunc(req)
    end)
    if not ok then return nil, res end
    -- normalize response
    -- syn.request returns {StatusCode, Body, Headers}
    -- http.request may return different shape; we try common fields
    local status = res.StatusCode or res.status or res.statusCode
    local body = res.Body or res.body or res.response or res
    return {StatusCode = status, Body = body, Raw = res}, nil
end

-- ============================
-- Key storage (writefile/readfile if available)
-- ============================
local keyFileName = "AI_OpenSource_Key.json"

local function saveApiToFile(tbl)
    if type(tbl) ~= "table" then return false, "bad args" end
    if writefile then
        local encoded = jsonEncode(tbl)
        pcall(function() writefile(keyFileName, encoded) end)
        return true
    else
        -- no writefile: store in memory (volatile)
        _G.AIOPS_KEYCACHE = tbl
        return true
    end
end

local function loadApiFromFile()
    if isfile and isfile(keyFileName) and readfile then
        local content = readfile(keyFileName)
        local ok, v = pcall(function() return jsonDecode(content) end)
        if ok and type(v) == "table" then return v end
    end
    return _G.AIOPS_KEYCACHE
end

-- ============================
-- Endpoints builder
-- ============================
local currentProvider = nil -- "openai" | "gemini" | "custom"
local currentApiKey = nil
local currentCustomUrl = nil
local currentCustomAuth = nil
local currentModel = "gpt-4o-mini" -- default for OpenAI (can be changed by user in code)
local SKIP_VALIDATION = false -- if true skip key validation step

local function endpointsFor(provider)
    provider = provider or currentProvider
    if provider == "gemini" then
        return {
            url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
            makeHeaders = function(key)
                return {
                    ["Content-Type"] = "application/json",
                    ["x-goog-api-key"] = key
                }
            end,
            -- try body shape A (prompt.text) and shape B (input)
            makeBodies = function(prompt)
                local bodies = {}
                -- shape 1 (text prompt)
                table.insert(bodies, jsonEncode({prompt = {text = prompt}}))
                -- shape 2 (messages like assistant)
                table.insert(bodies, jsonEncode({input = {text = prompt}}))
                -- shape 3 (alternate): messages style
                table.insert(bodies, jsonEncode({messages = {{author="user", content = {{type="text", text = prompt}}}}}))
                return bodies
            end,
            parseResult = function(bodyText)
                local d = jsonDecode(bodyText)
                if not d then return nil end
                if d.candidates and d.candidates[1] and d.candidates[1].content and d.candidates[1].content.parts then
                    return d.candidates[1].content.parts[1].text
                end
                if d.outputText then return d.outputText end
                if d.choices and d.choices[1] and d.choices[1].text then return d.choices[1].text end
                return nil
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
            makeBodies = function(prompt)
                local bodies = {}
                -- send as Responses API minimal
                table.insert(bodies, jsonEncode({model = currentModel, input = prompt}))
                -- also try chat-like shape as fallback
                table.insert(bodies, jsonEncode({model = currentModel, messages = {{role="user", content = prompt}}}))
                return bodies
            end,
            parseResult = function(bodyText)
                local d = jsonDecode(bodyText)
                if not d then return nil end
                -- Responses API new shape: d.output[1].content...
                if d.output and type(d.output)=="table" and d.output[1] and d.output[1].content then
                    for _, item in ipairs(d.output[1].content) do
                        if item.type == "output_text" and item.text then return item.text end
                        if item.type == "message" and item.text then return item.text end
                    end
                end
                if d.results and d.results[1] and d.results[1].output and d.results[1].output[1] and d.results[1].output[1].content then
                    local parts = d.results[1].output[1].content
                    for _,p in ipairs(parts) do
                        if p.type == "output_text" and p.text then return p.text end
                    end
                end
                if d.choices and d.choices[1] and d.choices[1].message and d.choices[1].message.content then
                    return d.choices[1].message.content
                end
                if d.outputText then return d.outputText end
                return nil
            end
        }
    elseif provider == "custom" and currentCustomUrl then
        return {
            url = currentCustomUrl,
            makeHeaders = function(key) 
                local h = { ["Content-Type"] = "application/json" }
                if currentCustomAuth then h["Authorization"] = "Bearer "..tostring(currentCustomAuth) end
                return h
            end,
            makeBodies = function(prompt)
                -- custom endpoint user must accept generic body
                return { jsonEncode({ input = prompt }) }
            end,
            parseResult = function(bodyText)
                local d = jsonDecode(bodyText)
                if type(d) == "string" then return d end
                if type(d) == "table" then
                    if d.text then return d.text end
                    if d.output then return tostring(d.output) end
                    if d.result then return tostring(d.result) end
                end
                return tostring(bodyText)
            end
        }
    end
    return nil
end

-- ============================
-- Request queue + backoff + single in-flight
-- ============================
local REQUEST_QUEUE = {}
local IN_FLIGHT = false
local RATE_LIMIT_UNTIL = 0 -- epoch seconds until allowed
local LAST_RATE_RETRY = 0
local BACKOFF_BASE = 1.5

local function enqueueRequest(reqTbl)
    table.insert(REQUEST_QUEUE, reqTbl)
    -- try process
    coroutine.wrap(function()
        while IN_FLIGHT do task.wait(0.05) end
        if #REQUEST_QUEUE > 0 then
            local r = table.remove(REQUEST_QUEUE, 1)
            r()
        end
    end)()
end

-- askAI(prompt, onSuccess, onError)
local function askAI(prompt, onSuccess, onError)
    if not prompt or tostring(prompt):gsub("%s+","") == "" then
        if onError then onError("empty prompt") end
        return
    end
    -- rate-limited?
    local now = os.time()
    if now < RATE_LIMIT_UNTIL then
        local waitSec = math.max(1, RATE_LIMIT_UNTIL - now)
        if onError then onError("rate_limited:"..tostring(waitSec)) end
        safeTxt(user.Warn, "Rate-limited. Retry in "..tostring(waitSec).."s", 255,255,0)
        return
    end

    if not currentProvider then
        if onError then onError("no_provider") end
        safeTxt(user.Error, "Not connected to any API. Please Confirm API key first.", 255,0,0)
        return
    end

    local ep = endpointsFor(currentProvider)
    if not ep then
        if onError then onError("no_endpoint") end
        safeTxt(user.Error, "Provider not supported", 255,0,0)
        return
    end

    -- single-inflight protection + enqueue
    local function doAsk()
        IN_FLIGHT = true
        local headers = ep.makeHeaders(currentApiKey)
        local bodies = ep.makeBodies(prompt)
        local successText = nil
        local lastErr = nil

        for bi, body in ipairs(bodies) do
            if not currentApiKey and currentProvider ~= "custom" then
                lastErr = "no_key"
                break
            end
            local attempt = 0
            local backoff = 1
            while attempt < 4 do
                attempt = attempt + 1
                local ok, res = doRequest({Url = ep.url, Method = "POST", Headers = headers, Body = body})
                if not ok then
                    lastErr = tostring(res)
                    -- if this is network-level error, break
                    if tostring(res):lower():match("http") then
                        -- try again after short wait
                        task.wait(backoff)
                        backoff = backoff * BACKOFF_BASE
                        continue
                    else
                        break
                    end
                else
                    local code = tonumber(res.StatusCode or 0)
                    local bodyText = tostring(res.Body or "")
                    dbg("askAI resp", code, bodyText:sub(1,200))
                    if code == 200 or code == 201 then
                        -- success decode
                        local out = nil
                        pcall(function() out = ep.parseResult(bodyText) end)
                        if out then
                            successText = out
                            break
                        else
                            successText = tostring(bodyText)
                            break
                        end
                    elseif code == 401 or code == 403 then
                        lastErr = "invalid_key_or_forbidden: "..tostring(bodyText)
                        -- do not retry many times; break outer loops
                        attempt = 99
                        break
                    elseif code == 429 then
                        -- rate limit: parse Retry-After if provided
                        local waitS = 5
                        local tryParse = nil
                        pcall(function()
                            local j = jsonDecode(bodyText)
                            if j and j.retry_after then waitS = tonumber(j.retry_after) or waitS end
                        end)
                        RATE_LIMIT_UNTIL = os.time() + waitS
                        lastErr = "rate_limited"
                        safeTxt(user.Warn, "Rate-limited by API. Retry after "..tostring(waitS).."s", 255,255,0)
                        task.wait(waitS)
                        -- then retry
                    else
                        -- other error: return API message as err
                        lastErr = "HTTP "..tostring(code).." "..tostring(bodyText)
                        -- if 400 and message about payload, try next body shape
                        break
                    end
                end
            end
            if successText then break end
        end

        if successText then
            if type(onSuccess) == "function" then pcall(onSuccess, successText) end
        else
            if type(onError) == "function" then pcall(onError, lastErr) end
        end

        IN_FLIGHT = false
    end

    enqueueRequest(doAsk)
end

-- ============================
-- Validate key (background)
-- ============================
local function validateKeyAsync(provider, key, callback)
    if SKIP_VALIDATION then
        if callback then pcall(callback, true, "skipped") end
        return
    end
    local ep = endpointsFor(provider)
    if not ep then if callback then pcall(callback, false, "no_endpoint") end return end
    local bodies = ep.makeBodies("hello")
    local headers = ep.makeHeaders(key)
    local ok, res = doRequest({Url = ep.url, Method = "POST", Headers = headers, Body = bodies[1]})
    if not ok then
        pcall(callback, false, res)
        return
    end
    local status = tonumber(res.StatusCode or 0)
    local bodyText = tostring(res.Body or "")
    if status == 200 or status == 201 then
        pcall(callback, true, "ok")
    else
        pcall(callback, false, tostring(status).. " "..bodyText)
    end
end

-- ============================
-- Status UI update helper
-- ============================
local function updateStatus(text)
    if st and st:IsA("TextLabel") then
        pcall(function() st.Text = "Status: "..tostring(text) end)
    else
        safeTxt(user.Info, "Status: "..tostring(text) , 180,180,180)
    end
end

-- ============================
-- Persistence helpers wrappers
-- ============================
local function saveApiKeyLocal(provider, key, customUrl, customAuth)
    local t = {provider = provider, key = key, url = customUrl, auth = customAuth, model = currentModel}
    saveApiToFile(t)
    return true
end

local function loadApiKeyLocal()
    local t = loadApiFromFile()
    if t and type(t) == "table" then
        currentProvider = t.provider
        currentApiKey = t.key
        currentCustomUrl = t.url
        currentCustomAuth = t.auth
        currentModel = t.model or currentModel
        return true, t
    end
    return false
end

-- try load on start
local okfile = pcall(loadApiKeyLocal)
if okfile then updateStatus("Loaded key (local)") end

-- ============================
-- Commands handling (full)
-- ============================
local HELP_TEXT = [=[
/Help - show commands
/Cal or /Calculate [expr] - safe math
/ClearText - clear chat logs
/AddAPI [ChatGPT/Gemini/custom] [API or URL] [APIKEY(if custom)] [yes/no] - add API quickly
    Examples:
      /addapi chatgpt sk-... yes
      /addapi gemini AI... yes
      /addapi custom https://host:8080 myapikey yes
/UnsaveAPI or /UnApi - remove key
/OpenWebsiteInExperience or /OWINE [URL] - open site in-game (if allowed)
/Loadstring [URL] - loadstring(url)()
/Script [[CODE]] - run code
/Debug [on/off] - show debug logs
/CheckHTTP - check executor http availability
/CheckURLStatus [URL] - check website status (HEAD)
/CheckSYN - check syn.request availability
/EnableUSLD - enable unknown-language debug printing to logs
/CheckAPI - quick ping the selected API (light)
/ResetRateLimit or /ReRateLimit - clear client-side rate hold
/DumpStatus - print internal status to si
/InstanceTool (...) or /InstanceTool [...] [ ... ] [[CODE]] - create tool locally
/GlobalChat - (requires server) stub locally
/SpyChat - (requires server) stub locally
]=]

local function clearChatLogs()
    if not si then return end
    for _,v in ipairs(si:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
end

local function calculate(expr)
    local ok, fn = pcall(function() return loadstring("return "..expr) end)
    if not ok or not fn then return nil, "invalid expression" end
    local suc, res = pcall(fn)
    if not suc then return nil, res end
    return res
end

-- open website helper (safe, handles Service blocked)
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

-- InstanceTool handler uses functions from patch earlier
-- We'll embed the createInstanceTool and parser here (same as patch).
local function tokenizeNumbersCSV(txt)
    local t = {}
    for n in tostring(txt or ""):gmatch("[-%d%.]+") do
        local num = tonumber(n)
        if num then table.insert(t, num) end
    end
    return t
end

local function splitWords(s)
    local t = {}
    for w in tostring(s or ""):gmatch("%S+") do table.insert(t, w) end
    return t
end

-- createInstanceTool (same as previous)
local function createInstanceTool(params)
    local plr = Players.LocalPlayer
    if not plr then return false, "No LocalPlayer" end
    local backpack = plr:FindFirstChild("Backpack") or plr:WaitForChild("Backpack",3)
    if not backpack then return false, "Backpack not found" end
    local tool = Instance.new("Tool")
    tool.Name = tostring(params.name or "Tool")
    tool.RequiresHandle = true
    tool.CanBeDropped = true
    if params.toolimage and tostring(params.toolimage)~="" then
        pcall(function() tool.TextureId = "rbxassetid://" .. tostring(params.toolimage) end)
    end
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    local sx,sy,sz = 1,1,1
    if params.partsize and #params.partsize>=3 then sx,sy,sz = params.partsize[1], params.partsize[2], params.partsize[3] end
    handle.Size = Vector3.new(sx,sy,sz)
    handle.Color = Color3.fromRGB(255,255,255)
    if params.color3 and #params.color3>=3 then
        handle.Color = Color3.fromRGB(math.clamp(math.floor(params.color3[1]),0,255),
                                      math.clamp(math.floor(params.color3[2]),0,255),
                                      math.clamp(math.floor(params.color3[3]),0,255))
    end
    handle.Parent = tool
    handle.CanCollide = false
    handle.Massless = true
    handle.Locked = true
    if params.meshid and tostring(params.meshid) ~= "" then
        local sm = Instance.new("SpecialMesh")
        sm.MeshType = Enum.MeshType.FileMesh
        pcall(function() sm.MeshId = "rbxassetid://"..tostring(params.meshid) end)
        if params.textureid and tostring(params.textureid)~="" then
            pcall(function() sm.TextureId = "rbxassetid://"..tostring(params.textureid) end)
        end
        if params.meshoffset and #params.meshoffset>=3 then
            sm.Offset = Vector3.new(params.meshoffset[1], params.meshoffset[2], params.meshoffset[3])
        end
        sm.Parent = handle
    end
    if params.code and params.code ~= "" then
        local okSet, err = pcall(function() 
            local ls = Instance.new("LocalScript")
            -- try set Source (may fail in some env)
            ls.Source = tostring(params.code)
            ls.Parent = tool
        end)
        if not okSet then
            local mod = Instance.new("ModuleScript")
            pcall(function() mod.Source = tostring(params.code) end)
            mod.Parent = tool
        end
    end
    tool.Parent = backpack
    return true, "Tool created in Backpack: "..tool.Name
end

local function handleInstanceToolCommand(raw)
    local s = tostring(raw or "")
    s = s:gsub("^/instancetool%s*", "", 1)
    -- extract code block
    local code = s:match("%[%[(.-)%]%]")
    if code then s = s:gsub("%[%[(.-)%]%]", "", 1) end
    -- find (...) and [...] in order
    local tokensOrder = {}
    for block in s:gmatch("%b()") do table.insert(tokensOrder, {type="par", text = block:sub(2,-2)}) end
    for block in s:gmatch("%b[]") do table.insert(tokensOrder, {type="br", text = block:sub(2,-2)}) end
    if #tokensOrder == 0 then
        -- fallback space-separated
        local parts = splitWords(s)
        tokensOrder = {}
        for i,p in ipairs(parts) do tokensOrder[i] = {type="word", text=p} end
    end
    local getText = function(t) return t and tostring(t.text or "") or "" end
    local p = {}
    p.name = getText(tokensOrder[1]) or "Tool"
    if tokensOrder[2] then
        local nums = tokenizeNumbersCSV(tokensOrder[2].text)
        if #nums>=3 then p.partsize = {nums[1],nums[2],nums[3]} end
    end
    if tokensOrder[3] then p.meshid = tostring(tokensOrder[3].text):gsub("[%[%]() ]","") end
    if tokensOrder[4] then p.textureid = tostring(tokensOrder[4].text):gsub("[%[%]() ]","") end
    if tokensOrder[5] then
        local nums = tokenizeNumbersCSV(tokensOrder[5].text)
        if #nums>=3 then p.meshoffset = {nums[1],nums[2],nums[3]} end
    end
    if tokensOrder[6] then
        local nums = tokenizeNumbersCSV(tokensOrder[6].text)
        if #nums>=3 then p.color3 = {nums[1],nums[2],nums[3]} end
    end
    if tokensOrder[7] then p.toolimage = tostring(tokensOrder[7].text):gsub("[%[%]() ]","") end
    p.code = code
    local ok,res = pcall(function() return createInstanceTool(p) end)
    if ok then safeTxt(user.Suc, tostring(res or "Tool created"), 0,255,0) else safeTxt(user.Error, "InstanceTool error: "..tostring(res),255,0,0) end
end

-- main command handler
local function handleCommand(msg)
    local lower = tostring(msg or ""):lower()
    if lower:match("^/help") then
        safeTxt(user.Nill, "What is AI-OpenSource?", 180,180,180)
        for line in HELP_TEXT:gmatch("[^\n]+") do safeTxt(user.Nill, line, 180,180,180) end
        return true
    end
    if lower:match("^/cleartext") then
        clearChatLogs()
        safeTxt(user.Suc, "Chat cleared", 0,255,0)
        return true
    end
    if lower:match("^/cal") or lower:match("^/calculate") then
        local expr = msg:match("^/%S+%s+(.+)$") or ""
        if expr == "" then safeTxt(user.Error, "Usage: /cal [expression]",255,0,0); return true end
        local res, err = calculate(expr)
        if not res then safeTxt(user.Error, "Math error: "..tostring(err),255,0,0) else safeTxt(user.Suc, "Result = "..tostring(res),0,255,0) end
        return true
    end
    if lower:match("^/addapi") then
        local parts = splitWords(msg)
        if #parts < 3 then safeTxt(user.Error, "Usage: /addapi [ChatGPT/Gemini/custom] [API or URL] [APIKEY(if custom)] [yes/no]",255,0,0) return true end
        local name = parts[2]:lower()
        if name == "custom" then
            local url = parts[3]
            local apikey = parts[4]
            local confirm = parts[5]
            currentProvider = "custom"
            currentCustomUrl = url
            currentCustomAuth = apikey and apikey ~= "" and apikey or nil
            currentApiKey = currentCustomAuth
            if confirm and confirm:lower()=="yes" then
                saveApiKeyLocal("custom", currentApiKey, currentCustomUrl, currentCustomAuth)
                updateStatus("Custom set (saved)")
                safeTxt(user.Suc, "Custom endpoint saved",0,255,0)
            else
                updateStatus("Custom set (unsaved)")
                safeTxt(user.Info, "Custom endpoint set. Use 'yes' to save: /addapi custom <URL> <APIKEY> yes",0,170,255)
            end
            return true
        else
            local provider = (name:match("chat") and "openai") or (name:match("gemini") and "gemini") or nil
            local key = parts[3]
            local confirm = parts[4]
            if not provider or not key then safeTxt(user.Error, "Usage: /addapi [ChatGPT/Gemini] [API] [yes/no]",255,0,0) return true end
            currentApiKey = key
            currentProvider = provider
            updateStatus("Key set (validating in background)")
            safeTxt(user.Info, "Key set. validating...", 0,170,255)
            validateKeyAsync(provider, key, function(ok, msg)
                if ok then
                    safeTxt(user.Suc, (provider == "openai" and "ChatGPT key valid" or "Gemini key valid"), 0,255,0)
                    updateStatus("Connected ("..(provider == "openai" and "ChatGPT" or "Gemini")..")")
                    if confirm and confirm:lower()=="yes" then saveApiKeyLocal(provider, key, currentCustomUrl, currentCustomAuth) end
                else
                    safeTxt(user.Error, "Key validation failed: "..tostring(msg), 255,0,0)
                    updateStatus("Invalid key")
                end
            end)
            return true
        end
    end
    if lower:match("^/unsaveapi") or lower:match("^/unapi") then
        -- remove persisted
        saveApiToFile({}) -- clear file
        currentApiKey = nil; currentProvider = nil; currentCustomAuth = nil; currentCustomUrl = nil
        updateStatus("No key")
        safeTxt(user.Suc, "API key removed", 0,255,0)
        return true
    end
    if lower:match("^/openwebsiteinexperience") or lower:match("^/owine") then
        local url = msg:match("^/%S+%s+(.+)$") or ""; url = url:gsub("^%s+",""):gsub("%s+$","")
        if url == "" then safeTxt(user.Error, "Usage: /OpenWebsiteInExperience [URL]",255,0,0) return true end
        local ok, e = openWebsiteInExperience(url)
        if ok then safeTxt(user.Suc, "Opened website: "..url,0,255,0) else safeTxt(user.Error, "OpenWebsite failed: "..tostring(e),255,0,0) end
        return true
    end
    if lower:match("^/loadstring") then
        local url = msg:match("^/%S+%s+(.+)$") or ""; url = url:gsub("^%s+",""):gsub("%s+$","")
        if url == "" then safeTxt(user.Error, "Usage: /loadstring [URL]",255,0,0) return true end
        safeTxt(user.Sys, "Fetching loadstring...",255,90,0)
        local ok, res = pcall(function() return loadstring(game:HttpGet(url))() end)
        if ok then safeTxt(user.Suc,"loadstring executed",0,255,0) else safeTxt(user.Error,"loadstring error: "..tostring(res),255,0,0) end
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
        local flag = msg:match("^/debug%s+(on|off)") or "off"
        DEBUG_MODE = (flag == "on")
        safeTxt(user.Suc, "Debug mode: "..tostring(DEBUG_MODE), 0,255,0)
        return true
    end
    if lower:match("^/instancetool") then
        handleInstanceToolCommand(msg)
        return true
    end
    if lower:match("^/checkhttp") then
        safeTxt(user.Info, "Executor HTTP available: "..tostring(httpRequestFunc ~= nil), 0,170,255)
        return true
    end
    if lower:match("^/checkurlstatus") then
        local url = msg:match("^/%S+%s+(.+)$") or ""; url = url:gsub("^%s+",""):gsub("%s+$","")
        if url == "" then safeTxt(user.Error, "Usage: /CheckURLStatus [URL]",255,0,0); return true end
        local ok,res = doRequest({Url=url, Method="HEAD"})
        if not ok then safeTxt(user.Error, "Request error: "..tostring(res),255,0,0) else safeTxt(user.Info, "URL status: "..tostring(res.StatusCode or "nil"), 0,170,255) end
        return true
    end
    if lower:match("^/checksyn") then
        safeTxt(user.Info, "syn.request available: "..tostring((syn and syn.request) and true or false), 0,170,255)
        return true
    end
    if lower:match("^/enableusld") then
        USLD_ENABLED = true
        safeTxt(user.Info, "USLD enabled (unknown-language debug prints to logs)", 0,170,255)
        return true
    end
    if lower:match("^/checkapi") then
        if not currentProvider or not currentApiKey then safeTxt(user.Error, "No API set",255,0,0); return true end
        safeTxt(user.Info, "Checking API (light)...", 0,170,255)
        validateKeyAsync(currentProvider, currentApiKey, function(ok,msg)
            if ok then safeTxt(user.Suc, "API OK: "..tostring(msg), 0,255,0) else safeTxt(user.Error, "API check failed: "..tostring(msg),255,0,0) end
        end)
        return true
    end
    if lower:match("^/resetratelimit") or lower:match("^/reratelimit") then
        RATE_LIMIT_UNTIL = 0
        safeTxt(user.Suc, "Rate limit reset", 0,255,0)
        return true
    end
    if lower:match("^/dumpstatus") then
        local stbl = {
            provider = currentProvider,
            api = (currentApiKey and "set" or "nil"),
            customUrl = currentCustomUrl,
            http = (httpRequestFunc and httpName or "none"),
            in_flight = IN_FLIGHT,
            rate_until = RATE_LIMIT_UNTIL,
            debug = DEBUG_MODE,
            usld = USLD_ENABLED
        }
        safeTxt(user.Nill, "Dumping status:", 180,180,180)
        for k,v in pairs(stbl) do safeTxt(user.Nill, tostring(k)..": "..tostring(v), 180,180,180) end
        return true
    end
    -- GlobalChat & SpyChat stubs
    if lower:match("^/globalchat") then
        safeTxt(user.Warn, "/GlobalChat requires server relay. Ask me to add ServerScript for this.",255,255,0)
        return true
    end
    if lower:match("^/spychat") then
        safeTxt(user.Warn, "/SpyChat requires server relay (private messages). Server component required.",255,255,0)
        return true
    end

    return false
end

-- ============================
-- Send hookup (ensure se,ch working)
-- ============================
local function sendMessageFromUI()
    local msg = (ch and tostring(ch.Text or "")) or ""
    msg = msg:gsub("^%s+",""):gsub("%s+$","")
    if msg == "" then return end
    -- commands
    if msg:sub(1,1) == "/" then
        local handled = handleCommand(msg)
        if not handled then safeTxt(user.Warn, "Unknown command. Type /Help", 255,255,0) end
        if ch then ch.Text = "" end
        return
    end
    -- normal chat -> show player's line then ask AI
    safeTxt(user.plr, msg, 255,255,255)
    safeTxt(user.chat, "(AI: thinking...)", 85,255,255)
    if ch then ch.Text = "" end

    askAI(msg, function(answer)
        safeTxt(user.chat, tostring(answer), 85,255,255)
    end, function(err)
        safeTxt(user.Error, "AI request failed: "..tostring(err), 255,0,0)
    end)
end

local function attachSendHook(sendBtn, textBox)
    if not sendBtn or not textBox then return false end
    if sendBtn:GetAttribute and sendBtn:GetAttribute("AIOOpenBound") then return true end
    local function fire()
        pcall(sendMessageFromUI)
    end
    pcall(function() sendBtn.MouseButton1Click:Connect(fire) end)
    pcall(function() sendBtn.Activated:Connect(fire) end)
    if sendBtn.TouchTap then pcall(function() sendBtn.TouchTap:Connect(fire) end) end
    -- focus lost
    pcall(function() textBox.FocusLost:Connect(function(enter) if enter then pcall(sendMessageFromUI) end end) end)
    if sendBtn.SetAttribute then sendBtn:SetAttribute("AIOOpenBound", true) end
    return true
end

-- try attach now; if ui missing, poll for it
if ch and se then attachSendHook(se, ch) end
if not (ch and se) then
    -- try periodic finder
    coroutine.wrap(function()
        for i=1,20 do
            if not (ch and se) then
                ui = findUI()
                if ui then
                    ch = ch or ui.ch
                    se = se or ui.se
                    si = si or ui.si
                    tb = tb or ui.tb
                    st = st or ui.st
                end
            end
            if ch and se then
                attachSendHook(se, ch); break
            end
            task.wait(0.25)
        end
    end)()
end

-- ============================
-- Connect Confirm / Unsaved API buttons if exist (tb, con, con2)
-- ============================
-- try find confirm buttons inside frame (names: Confirm_api, Unsaved_API, ConfirmAPI, UnsavedAPI)
local function findConfirmButtons()
    local confirm = nil; local unsave = nil
    if frame then
        confirm = frame:FindFirstChild("Confirm_api") or frame:FindFirstChild("ConfirmAPI") or frame:FindFirstChildWhichIsA and frame:FindFirstChildWhichIsA("TextButton")
        unsave = frame:FindFirstChild("Unsaved_API") or frame:FindFirstChild("UnsavedAPI")
        -- maybe inside Text
        if frame:FindFirstChild("Text") then
            confirm = confirm or frame.Text:FindFirstChild("Confirm_api") or frame.Text:FindFirstChild("ConfirmAPI")
            unsave = unsave or frame.Text:FindFirstChild("Unsaved_API") or frame.Text:FindFirstChild("UnsavedAPI")
        end
    end
    return confirm, unsave
end

local function onConfirmClicked()
    -- confirm current key: run validation and save
    if not currentProvider or not currentApiKey then safeTxt(user.Error, "No API to confirm",255,0,0); return end
    safeTxt(user.Sys, "Confirming API key...",255,90,0)
    validateKeyAsync(currentProvider, currentApiKey, function(ok,msg)
        if ok then
            saveApiKeyLocal(currentProvider, currentApiKey, currentCustomUrl, currentCustomAuth)
            updateStatus("Connected ("..(currentProvider == "openai" and "ChatGPT" or (currentProvider == "gemini" and "Gemini" or "Custom"))..")")
            safeTxt(user.Suc, "API confirmed and saved", 0,255,0)
        else
            safeTxt(user.Error, "Validation failed: "..tostring(msg),255,0,0)
            updateStatus("Invalid key")
        end
    end)
end

local function onUnsavedClicked()
    saveApiToFile({}) -- clear
    currentProvider = nil; currentApiKey = nil; currentCustomUrl = nil; currentCustomAuth = nil
    updateStatus("No key")
    safeTxt(user.Suc, "Unsave key done", 0,255,0)
end

-- attempt to hook buttons (poll)
coroutine.wrap(function()
    for i=1,30 do
        local c,u = findConfirmButtons()
        if c and not c:GetAttribute("AIOBound") then
            pcall(function() c.MouseButton1Click:Connect(onConfirmClicked) end)
            pcall(function() c.Activated:Connect(onConfirmClicked) end)
            if c.SetAttribute then c:SetAttribute("AIOBound", true) end
        end
        if u and not u:GetAttribute("AIOBound") then
            pcall(function() u.MouseButton1Click:Connect(onUnsavedClicked) end)
            pcall(function() u.Activated:Connect(onUnsavedClicked) end)
            if u.SetAttribute then u:SetAttribute("AIOBound", true) end
        end
        if (c and u) then break end
        task.wait(0.25)
    end
end)()

-- ============================
-- Final notes
-- ============================
safeTxt(user.Suc, "AI-OpenSource client patch loaded. Type /Help for commands.", 0,255,0)
updateStatus("No key")

-- End of script
