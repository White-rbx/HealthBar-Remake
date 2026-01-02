-- gpt 3.676

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
txt(user.Nill, "Version: Test 3.676 | © Copyright LighterCyan", 180, 180, 180)
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
-- AI-OpenSource: hookup + command + basic API driver (tail portion)
-- Assumes UI Instances already exist in CoreGui at:
-- CoreGui.ExperienceSettings.Menu.AIOpenSource (or similar)
-- and children named: api (TextBox), Confirm_api (TextButton), Unsaved_API (TextButton),
-- Status (TextLabel), chat (TextBox) as ch, Send (TextButton) as se, ChatLogs (ScrollingFrame) as si
-- function txt(user, text, R,G,B) already defined by user (this script uses it)

local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

-- CONFIG
local SKIP_VALIDATION = true        -- default: skip network validation (set false to actually validate)
local VALIDATION_DELAY = 10        -- seconds to wait before doing validation request (to slow things down)
local VALIDATION_TIMEOUT = 8       -- how long to wait for a validate request (seconds)
local RETRY_BASE = 5               -- base seconds for exponential backoff on 429
local currentModel = "gpt-4o-mini" -- default model for OpenAI responses
local DEBUG_MODE = false

-- executor http function detection
local function getRequestFunc()
    if syn and syn.request then return syn.request end
    if http and http.request then return http.request end
    if http_request then return http_request end
    if request then return request end
    return nil
end
local requestFunc = getRequestFunc()

-- safe JSON helpers
local function jsonEncode(t) return pcall(function() return HttpService:JSONEncode(t) end) and HttpService:JSONEncode(t) end
local function jsonDecode(s) local ok, r = pcall(function() return HttpService:JSONDecode(s) end) if ok then return r end return nil end

-- find UI root tolerant
local function findUI()
    local ok, res = pcall(function()
        local ES = CoreGui:FindFirstChild("ExperienceSettings") or CoreGui:WaitForChild("ExperienceSettings", 6)
        if not ES then return nil end
        local Menu = ES:FindFirstChild("Menu") or ES:WaitForChild("Menu", 2)
        if not Menu then return nil end
        -- user said AIOpenSource.Frame path earlier
        local root = Menu:FindFirstChild("AIOpenSource") or Menu:FindFirstChild("ChatGPT") or Menu:FindFirstChild("AI-OpenSource") or Menu:FindFirstChild("AIOpenSource_Frame") or Menu
        -- if root is a frame wrapper:
        if root and root:IsA("GuiObject") then
            -- try to find Frame child if user put 'Frame' under it
            if root:FindFirstChild("Frame") then
                root = root.Frame
            end
        end
        return root, Menu
    end)
    if ok then return res end
    return nil
end

local rootUI = findUI()
if not rootUI then
    warn("[AI-OpenSource] UI root not found. Ensure CoreGui.ExperienceSettings.Menu.AIOpenSource exists.")
    -- still attempt to proceed, but many features will not work
end

-- utility: safe find descendant by name
local function find(name)
    if not rootUI then return nil end
    return rootUI:FindFirstChild(name, true) or rootUI:FindFirstChild(name)
end

-- get references
local apiBox = find("api")
local conBtn = find("Confirm_api")
local unsaveBtn = find("Unsaved_API")
local statusLabel = find("Status")
local ch = find("chat")   -- TextBox
local se = find("Send")   -- TextButton
local si = find("ChatLogs") -- ScrollingFrame (for txt already using it)

-- fallback log if txt exists
local function logDbg(...)
    if DEBUG_MODE and type(txt)=="function" then
        pcall(txt, user.Info, table.concat({...}," "), 0,170,255)
    end
end

-- state
local ACTIVE_KEY = nil
local ACTIVE_PROVIDER = nil -- "chatgpt" | "gemini" | nil
local VALIDATE_LOCK = false
local RATE_LOCK = false
local REFRESH_COOLDOWN = 0

-- helper: set status (updates UI text label and logs)
local function setStatus(s)
    if statusLabel and statusLabel:IsA("TextLabel") then
        pcall(function() statusLabel.Text = "Status: "..tostring(s) end)
    end
    if type(txt)=="function" then pcall(txt, user.Nill, "Status: "..tostring(s), 180,180,180) end
    logDbg("setStatus:", s)
end

-- detect provider by key signature
local function detectProvider(key)
    if not key then return nil end
    if key:match("^sk%-") then return "chatgpt" end
    if key:match("^AIza") or key:match("^AI") then return "gemini" end
    return nil
end

-- build payloads for providers (only used if SKIP_VALIDATION==false)
local function endpointsFor(provider, key)
    if provider == "gemini" then
        return {
            url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
            makeHeaders = function() return { ["Content-Type"]="application/json", ["x-goog-api-key"]=key } end,
            makeBody = function(prompt)
                -- the official minimal shape for generateContent uses "prompt" with structured content; different versions vary.
                -- here's a conservative supported shape often used:
                return jsonEncode({
                    prompt = {
                        text = prompt
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
    else
        -- default OpenAI Responses
        return {
            url = "https://api.openai.com/v1/responses",
            makeHeaders = function() return { ["Content-Type"]="application/json", ["Authorization"]="Bearer "..key } end,
            makeBody = function(prompt)
                local body = { model = currentModel, input = prompt }
                return jsonEncode(body)
            end,
            parseResult = function(bodyText)
                local d = jsonDecode(bodyText)
                if not d then return nil end
                if d.output and type(d.output)=="table" and d.output[1] and d.output[1].content then
                    for _, item in ipairs(d.output[1].content) do
                        if item.type == "output_text" and item.text then return item.text end
                    end
                end
                if d.results and d.results[1] and d.results[1].output and d.results[1].output[1] and d.results[1].output[1].content then
                    for _,p in ipairs(d.results[1].output[1].content) do
                        if p.type=="output_text" and p.text then return p.text end
                    end
                end
                if d.choices and d.choices[1] and d.choices[1].message and d.choices[1].message.content then
                    return d.choices[1].message.content
                end
                return nil
            end
        }
    end
end

-- perform request via executor (with simple error handling + rate-limit)
local function requestHttp(args)
    -- args: { url, method, headers, body }
    if not requestFunc then
        return false, "no http executor available"
    end
    local ok, resp = pcall(function() return requestFunc({
        Url = args.url,
        Method = args.method or "GET",
        Headers = args.headers or {},
        Body = args.body
    }) end)
    if not ok then return false, resp end
    return true, resp
end

-- one-shot validation request (with small prompt) - returns success true/false and message/result
local function validateKey(provider, key)
    if not key or key=="" then return false, "no key" end
    local ep = endpointsFor(provider, key)
    if not ep then return false, "unknown provider" end
    if not requestFunc then return false, "no executor" end

    -- throttle
    if VALIDATE_LOCK then return false, "validation locked" end
    VALIDATE_LOCK = true
    task.spawn(function() task.wait(VALIDATION_DELAY); VALIDATE_LOCK=false end)

    local body = ep.makeBody("Hello")
    local ok, resp = requestHttp({ url = ep.url, method = "POST", headers = ep.makeHeaders(), body = body })
    if not ok then return false, resp end

    -- handle rate limit
    local sc = resp.StatusCode or resp.status or resp.code
    if sc == 429 then
        local retry = 30
        local rh = resp.Headers or resp.headers or {}
        if rh["Retry-After"] then retry = tonumber(rh["Retry-After"]) or retry end
        return false, ("rate_limited:"..tostring(retry))
    end
    if sc and (sc < 200 or sc >= 300) then
        return false, ("http_error:"..tostring(sc).." "..tostring(resp.StatusMessage or resp.message or "" ))
    end

    -- parse response
    local out = ep.parseResult(resp.Body or resp.body or resp.Response)
    if out then return true, out end
    return false, ("no_text_in_response")
end

-- API driver: askAI(prompt, onSuccess, onError)
local function askAI(prompt, onSuccess, onError)
    if not ACTIVE_KEY or not ACTIVE_PROVIDER then
        if onError then onError("Not connected to any API. Confirm API first.") end
        return
    end
    if RATE_LOCK then
        if onError then onError("Rate-limited. Retry later.") end
        return
    end
    local ep = endpointsFor(ACTIVE_PROVIDER, ACTIVE_KEY)
    if not ep then if onError then onError("Endpoint not configured") end return end

    local body = ep.makeBody(prompt)
    local ok, resp = requestHttp({ url = ep.url, method = "POST", headers = ep.makeHeaders(), body = body })
    if not ok then
        if tostring(resp):match("429") then
            -- if resp is string or response table
            local retry = RETRY_BASE
            if type(resp)=="table" then
                local rh = resp.Headers or resp.headers or {}
                if rh["Retry-After"] then retry = tonumber(rh["Retry-After"]) or retry end
            end
            RATE_LOCK = true
            setStatus(("Rate-limited. Retry in %ds"):format(retry))
            task.delay(retry, function() RATE_LOCK = false; setStatus("Connected") end)
            if onError then onError("rate_limited") end
            return
        end
        if onError then onError(resp) end
        return
    end

    local sc = resp.StatusCode or resp.status or resp.code
    if sc == 429 then
        local retry = RETRY_BASE
        local rh = resp.Headers or resp.headers or {}
        if rh["Retry-After"] then retry = tonumber(rh["Retry-After"]) or retry end
        RATE_LOCK = true
        setStatus(("Rate-limited. Retry in %ds"):format(retry))
        task.delay(retry, function() RATE_LOCK = false; setStatus("Connected") end)
        if onError then onError("rate_limited") end
        return
    end

    if sc and (sc < 200 or sc >= 300) then
        if onError then onError(("http_error:%s"):format(tostring(sc))) end
        return
    end

    local out = ep.parseResult(resp.Body or resp.body or resp.Response or "")
    if out then
        if onSuccess then onSuccess(out) end
    else
        if onError then onError("no_text") end
    end
end

-- UI handlers: Confirm / Unsave
local function onConfirmClicked()
    if not apiBox then
        pcall(txt, user.Error, "API box not found", 255,0,0)
        return
    end
    local key = tostring(apiBox.Text or ""):gsub("^%s+",""):gsub("%s+$","")
    if key == "" then
        setStatus("No key")
        pcall(txt, user.Error, "Please input an API key", 255,0,0)
        return
    end

    local prov = detectProvider(key) or "unknown"
    pcall(txt, user.Info, ("Key detected: %s (provider=%s)"):format(key:sub(1,12).."...", prov), 0,170,255)
    setStatus(("Key detected (%s)"):format(prov))
    ACTIVE_KEY = key
    ACTIVE_PROVIDER = prov

    -- change status to connecting
    setStatus(("Connecting API [%s]"):format(prov))

    if SKIP_VALIDATION or not requestFunc then
        -- immediate connect (simulated)
        setStatus("Connected")
        pcall(txt, user.Suc, "Connected (validation skipped)", 0,255,0)
        return
    end

    -- do delayed validation (not instant)
    if VALIDATE_LOCK then
        pcall(txt, user.Warn, "Validation in progress / locked. Please wait.", 255,255,0)
        return
    end
    VALIDATE_LOCK = true
    setStatus("Validating... (please wait)")
    task.spawn(function()
        task.wait(VALIDATION_DELAY)
        local ok, res = validateKey(ACTIVE_PROVIDER, ACTIVE_KEY)
        VALIDATE_LOCK = false
        if ok then
            setStatus("Connected")
            pcall(txt, user.Suc, "Key validated and connected", 0,255,0)
        else
            if tostring(res):match("^rate_limited") then
                local sec = tonumber(res:match(":(%d+)")) or 30
                setStatus(("Rate-limited. Retry in %ds"):format(sec))
                pcall(txt, user.Warn, ("Rate-limited. Validation failed. Retry in %ds"):format(sec), 255,255,0)
                -- schedule automatic retry
                task.delay(sec, function()
                    if not ACTIVE_KEY then return end
                    pcall(txt, user.Info, "Retrying validation...", 0,170,255)
                    onConfirmClicked()
                end)
            else
                setStatus("Invalid key")
                pcall(txt, user.Error, ("Validation failed: %s"):format(tostring(res)), 255,0,0)
            end
        end
    end)
end

local function onUnsaveClicked()
    ACTIVE_KEY = nil
    ACTIVE_PROVIDER = nil
    setStatus("Unsave key")
    pcall(txt, user.Warn, "API key removed (unsaved)", 255,255,0)
    if apiBox then apiBox.Text = "" end
end

-- wire up buttons safe
if conBtn and conBtn:IsA("GuiButton") then
    conBtn.AutoButtonColor = true
    conBtn.MouseButton1Click:Connect(function() pcall(onConfirmClicked) end)
else
    warn("Confirm_api button not found or wrong type")
end
if unsaveBtn and unsaveBtn:IsA("GuiButton") then
    unsaveBtn.AutoButtonColor = true
    unsaveBtn.MouseButton1Click:Connect(function() pcall(onUnsaveClicked) end)
else
    warn("Unsaved_API button not found or wrong type")
end

-- COMMANDS and CHAT wiring (uses txt function provided by user)
-- reuse helper trim/split
local function trim(s) return (s or ""):gsub("^%s+",""):gsub("%s+$","") end

-- command handlers table (add /help, /debug, /openwebsiteinexperience)
local Commands = {}

Commands.help = function(arg)
    txt(user.Nill, [[
What is AI-OpenSource?
  AI-OpenSource is a tool for questioning to AIs (ChatGPT/Gemini) by putting API Key.

What AI model you using?
  We use gpt-4o-mini and gemini-2.5-flash

This is safe to put api key?
  Yes, but do NOT share your API publicly.

Available commands:
  /help
  /addapi [ChatGPT/Gemini] [ApiKey] [yes/no]
  /unsaveapi or /unapi
  /calculate or /cal [math]
  /cleartext
  /openwebsiteinexperience or /owine [URL]
  /script [[CODE]]
  /loadstring [URL]
  /debug [on/off]
]], 180,180,180)
end

Commands.cleartext = function() for _,v in ipairs(si:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end; txt(user.Suc, "Chat cleared", 0,255,0) end

Commands.cal = function(arg)
    local expr = trim(arg or "")
    if expr == "" then txt(user.Error, "Usage: /cal [expression]", 255,0,0); return end
    local ok, res = pcall(function()
        local f, e = loadstring("return "..expr)
        if not f then error(e) end
        return f()
    end)
    if ok then txt(user.Suc, "Result = "..tostring(res), 0,255,0) else txt(user.Error, "Math error: "..tostring(res), 255,0,0) end
end
Commands.calculate = Commands.cal

Commands.addapi = function(arg)
    local a,b,c = arg:match("^(%S+)%s+(%S+)%s*(%S*)$")
    if not a or not b then txt(user.Error, "Usage: /addapi [ChatGPT/Gemini] [ApiKey] [yes/no]",255,0,0); return end
    local provider = a:lower()
    local key = b
    local confirm = (c or ""):lower()
    -- immediate store
    ACTIVE_KEY = key
    ACTIVE_PROVIDER = detectProvider(key) or provider
    txt(user.Info, ("API added: provider=%s, key=%s"):format(tostring(ACTIVE_PROVIDER), key:sub(1,12).."..."), 0,170,255)
    if confirm == "yes" then
        txt(user.Info, "Auto-confirmed. Validating...", 0,170,255)
        onConfirmClicked()
    else
        txt(user.Sys, "Add finished. Press Confirm API to validate/connect.", 255,90,0)
    end
end

Commands.unsaveapi = function() onUnsaveClicked() end
Commands.unapi = Commands.unsaveapi

Commands.owine = function(arg)
    local url = trim(arg or "")
    if url == "" then txt(user.Error, "Usage: /OpenWebsiteInExperience [URL]", 255,0,0); return end
    local ok, e = pcall(function()
        if GuiService and GuiService.OpenBrowserWindow then
            GuiService:OpenBrowserWindow(url)
        else
            if StarterGui and StarterGui.SetCore then
                StarterGui:SetCore("OpenBrowserWindow", url)
            else
                error("No supported API to open website in-game")
            end
        end
    end)
    if ok then txt(user.Suc, "Opened website: "..url, 0,255,0) else txt(user.Error, "OpenWebsite failed: "..tostring(e), 255,0,0) end
end
Commands.openwebsiteinexperience = Commands.owine

Commands.loadstring = function(arg)
    local url = trim(arg or "")
    if url == "" then txt(user.Error, "Usage: /loadstring [URL]", 255,0,0); return end
    txt(user.Sys, "Fetching loadstring...", 255,90,0)
    local ok, res = pcall(function() return loadstring(game:HttpGet(url))() end)
    if ok then txt(user.Suc, "loadstring executed", 0,255,0) else txt(user.Error, "loadstring error: "..tostring(res),255,0,0) end
end
Commands.ls = Commands.loadstring

Commands.script = function(arg)
    local code = trim(arg or "")
    if code == "" then txt(user.Error,"Usage: /script [[CODE]]",255,0,0); return end
    code = code:gsub("^%[%[",""):gsub("%]%]$","")
    txt(user.Sys, "Executing script...",255,90,0)
    local fn, err = loadstring(code)
    if not fn then txt(user.Error, "Compile error: "..tostring(err),255,0,0); return end
    local ok, r = pcall(fn)
    if ok then txt(user.Suc, "Script executed",0,255,0) else txt(user.Error, "Runtime error: "..tostring(r),255,0,0) end
end
Commands.run = Commands.script

Commands.debug = function(arg)
    local flag = (arg or ""):lower()
    if flag == "on" then DEBUG_MODE = true; txt(user.Suc,"Debug ON",0,255,0) elseif flag == "off" then DEBUG_MODE = false; txt(user.Suc,"Debug OFF",0,255,0) else txt(user.Error,"Usage: /debug [on/off]",255,0,0) end
end

-- message handler used by UI send
local function handleMessage(msg)
    msg = trim(msg or "")
    if msg == "" then return end

    if msg:sub(1,1) == "/" then
        local cmd, args = msg:match("^/(%S+)%s*(.*)$")
        cmd = cmd and cmd:lower()
        if cmd and Commands[cmd] then
            Commands[cmd](args or "")
        else
            txt(user.Warn, "Unknown command: /"..tostring(cmd).." (type /help)", 255,255,0)
        end
        return
    end

    -- normal chat workflow
    txt(user.plr, msg, 255,255,255)

    -- if not connected warn
    if not ACTIVE_KEY or not ACTIVE_PROVIDER then
        txt(user.Error, "Not connected to any API. Press Confirm API or use /addapi", 255,0,0)
        return
    end

    -- ask AI but avoid requesting if rate limited
    askAI(msg, function(answer)
        pcall(txt, user.chat, tostring(answer), 85,255,255)
    end, function(err)
        pcall(txt, user.Error, "AI request failed: "..tostring(err), 255,0,0)
    end)
end

-- wire UI send controls
if se and se:IsA("GuiButton") then
    se.MouseButton1Click:Connect(function()
        local text = (ch and tostring(ch.Text or "")) or ""
        handleMessage(text)
        if ch then ch.Text = "" end
    end)
else
    warn("Send button not found or wrong type")
end

-- Enter key on chat box
if ch and ch:IsA("TextBox") then
    ch.FocusLost:Connect(function(enter)
        if enter then
            local text = tostring(ch.Text or "")
            handleMessage(text)
            ch.Text = ""
        end
    end)
else
    warn("Chat TextBox not found or wrong type")
end

-- init status
setStatus("No key")
-- initial help message
pcall(Commands.help)

-- debug print for wiring
if DEBUG_MODE then
    pcall(txt, user.Info, "UI wired. Ready.", 0,170,255)
end

-- End of script
