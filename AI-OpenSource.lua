-- gpt 3.678

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
txt(user.Nill, "Version: Test 3.678 | © Copyright LighterCyan", 180, 180, 180)
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
-- AI-OpenSource: client integration (tail script)
-- Requires: existing UI elements (no new Instances created)
-- Expects: txt(user, text, R,G,B) and 'user' table already present

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")

-- request function detection: try common executor http functions
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- JSON helpers (wrap safe)
local function jsonEncode(t) return HttpService:JSONEncode(t) end
local function jsonDecode(s) 
    local ok, v = pcall(HttpService.JSONDecode, HttpService, s)
    return ok and v or nil
end

-- Config
local SKIP_VALIDATION = false            -- set true to skip remote key validation
local VALIDATION_TIMEOUT = 12           -- seconds to wait for validation attempt (non-blocking)
local BASE_REQUEST_DELAY = 0.6          -- seconds between queued requests (avoid hammering)
local BACKOFF_MULT = 2                  -- exponential backoff multiplier for 429
local MAX_RETRY = 5

-- helper: safe pcall txt
local function safeTxt(u, t, r,g,b)
    if type(txt)=="function" then
        pcall(txt, u, t, r or 255, g or 255, b or 255)
    end
end

-- find UI root (tolerant)
local root
do
    local ok, m = pcall(function()
        return CoreGui:WaitForChild("ExperienceSettings",6).Menu:WaitForChild("AIOpenSource",6)
    end)
    root = (ok and m) or nil
    if not root then
        -- fallback path user gave earlier
        local ok2, f = pcall(function()
            return CoreGui:WaitForChild("ExperienceSettings",6).Menu:WaitForChild("AI-OpenSource",6)
        end)
        root = (ok2 and f) or root
    end
end
if not root then
    safeTxt(user.Error, "UI root not found: CoreGui.ExperienceSettings.Menu.AIOpenSource", 255,0,0)
    return
end

-- bind UI elements (names must match your UI)
local function find(name)
    return root:FindFirstChild(name, true) or root:FindFirstChild(name) -- tolerant
end

-- Common UI handles (adjust names if different)
local frame = root:FindFirstChild("Frame") or root
local ch = frame:FindFirstChild("chat") or frame:FindFirstChild("ch") or frame:FindFirstChild("Ch")
local se = frame:FindFirstChild("Send") or frame:FindFirstChild("se")
local si = frame:FindFirstChild("ChatLogs") or frame:FindFirstChild("si")
local con = frame:FindFirstChild("Confirm_api") or frame:FindFirstChild("con")
local con2 = frame:FindFirstChild("Unsaved_API") or frame:FindFirstChild("con2")
local st = frame:FindFirstChild("Status") or frame:FindFirstChild("st")

if not (ch and se and si) then
    safeTxt(user.Error, "Chat UI missing (ch/se/si)", 255,0,0)
    return
end

-- state
local DEBUG_MODE = false
local currentApiKey = nil
local currentProvider = nil -- "openai" or "gemini"
local currentModel = "gpt-4o-mini"
local requestQueue = {}
local processing = false
local nextDelay = BASE_REQUEST_DELAY
local lastRateReset = 0

-- helper: update status label safely
local function updateStatus(text)
    if st and st:IsA("TextLabel") then
        pcall(function() st.Text = "Status: "..tostring(text) end)
    end
end

-- choose endpoints per provider
local function endpointsFor(provider)
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
                -- Use the "input" shape which is accepted by some generateContent variants
                return jsonEncode({
                    input = { text = tostring(prompt) }
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
        -- default: OpenAI Responses API
        return {
            url = "https://api.openai.com/v1/responses",
            makeHeaders = function(key)
                return {
                    ["Content-Type"] = "application/json",
                    ["Authorization"] = "Bearer "..tostring(key)
                }
            end,
            makeBody = function(prompt, model)
                model = model or currentModel
                return jsonEncode({
                    model = model,
                    input = tostring(prompt)
                })
            end,
            parseResult = function(bodyText)
                local d = jsonDecode(bodyText)
                if not d then return nil end
                if d.output and type(d.output)=="table" and d.output[1] and d.output[1].content then
                    for _, item in ipairs(d.output[1].content) do
                        if item.type == "output_text" and item.text then
                            return item.text
                        end
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

-- low-level http wrapper using available executor function
local function doHttpRequest(params)
    -- params: url, method, headers, body
    if not httpRequest then
        return false, "no_http_executor"
    end
    local ok, resp = pcall(function()
        return httpRequest({
            Url = params.url,
            Method = params.method or "GET",
            Headers = params.headers,
            Body = params.body
        })
    end)
    if not ok then
        return false, resp -- message from pcall
    end
    return true, resp
end

-- queue logic with backoff handling for 429
local function processQueue()
    if processing then return end
    processing = true
    spawn(function()
        while #requestQueue > 0 do
            local job = table.remove(requestQueue, 1)
            local tries = 0
            local backoff = nextDelay
            local lastErr
            while tries < MAX_RETRY do
                tries = tries + 1
                if DEBUG_MODE then safeTxt(user.Info, ("[REQ] try %d -> %s"):format(tries, job.url), 0,170,255) end
                local ok, resp = doHttpRequest{
                    url = job.url,
                    method = job.method or "POST",
                    headers = job.headers,
                    body = job.body
                }
                if not ok then
                    lastErr = resp
                    -- fatal local executor error (no point retrying many times)
                    if tostring(resp):match("no_http_executor") then
                        job.onError("no_http_executor")
                        break
                    end
                    -- wait a bit and retry
                    task.wait(backoff)
                    backoff = backoff * BACKOFF_MULT
                else
                    -- http executor responded; parse status
                    local status = resp.Status or resp.status or resp.StatusCode or resp.statusCode
                    local bodyText = resp.Body or resp.body or resp.response
                    status = tonumber(status) or 0
                    if status == 429 then
                        -- rate limited; check Retry-After header
                        local retryAfter = tonumber((resp.Headers and (resp.Headers["Retry-After"] or resp.Headers["retry-after"])) or nil) or backoff
                        safeTxt(user.Warn, ("Rate-limited. Retry in %ss"):format(tostring(retryAfter)), 255,255,0)
                        task.wait(retryAfter)
                        backoff = backoff * BACKOFF_MULT
                        lastErr = "429"
                    elseif status >= 200 and status < 300 then
                        -- success
                        if job.onSuccess then
                            job.onSuccess(bodyText, resp)
                        end
                        lastErr = nil
                        break
                    else
                        -- other HTTP error
                        lastErr = ("HTTP %s"):format(tostring(status))
                        if job.onError then job.onError(lastErr, resp) end
                        break
                    end
                end
            end
            if lastErr and job.onError then
                job.onError(lastErr)
            end
            task.wait(BASE_REQUEST_DELAY)
        end
        processing = false
    end)
end

local function enqueueRequest(req)
    table.insert(requestQueue, req)
    processQueue()
end

-- test key: run a minimal request depending on provider
local function testKey(key, provider, onSuccess, onError)
    local ep = endpointsFor(provider)
    local url = ep.url
    local headers = ep.makeHeaders(key)
    local body = ep.makeBody("Hello")
    enqueueRequest{
        url = url,
        method = "POST",
        headers = headers,
        body = body,
        onSuccess = function(bodyText, resp)
            local parsed = ep.parseResult(bodyText)
            if parsed then
                onSuccess(parsed)
            else
                onError("no_response_shape", bodyText)
            end
        end,
        onError = function(err, resp) onError(err, resp) end
    }
end

-- add API key (Confirm button)
local function saveApiKey(key)
    currentApiKey = key
    -- detect provider
    if tostring(key):match("^sk%-%w+") then
        currentProvider = "openai"
        safeTxt(user.Info, "ChatGPT Key detected", 0,170,255)
    elseif tostring(key):match("^AIza") then
        currentProvider = "gemini"
        safeTxt(user.Info, "Gemini Key detected", 0,170,255)
    else
        currentProvider = nil
        safeTxt(user.Warn, "Unknown key format (will attempt)", 255,255,0)
    end

    updateStatus("Connecting")

    if SKIP_VALIDATION then
        updateStatus("Connected (skipped validation)")
        safeTxt(user.Suc, "API saved (validation skipped)", 0,255,0)
        return
    end

    local validated = false
    local done = false
    -- perform test but do not block UI; use callback
    testKey(currentApiKey, currentProvider or "openai", function(sample)
        validated = true
        done = true
        updateStatus("Connected")
        safeTxt(user.Suc, "Connected: sample reply: "..tostring(sample):sub(1,200), 0,255,0)
    end, function(err, resp)
        done = true
        if tostring(err) == "429" then
            updateStatus("Rate-limited")
            safeTxt(user.Warn, "Rate-limited while validating key", 255,255,0)
        else
            updateStatus("Invalid key")
            safeTxt(user.Error, "Key validation failed: "..tostring(err), 255,0,0)
        end
    end)

    -- NOTE: testKey enqueues request and returns immediately
    -- we avoid busy-waiting here; UI shows status updates via callbacks above
end

local function unsaveApiKey()
    currentApiKey = nil
    currentProvider = nil
    updateStatus("No key")
    safeTxt(user.Suc, "API key unsaved", 0,255,0)
end

-- wire confirm/unsave buttons if present
if con and con:IsA("GuiButton") then
    con.MouseButton1Click:Connect(function()
        local key = (frame:FindFirstChild("api") and tostring(frame.api.Text or "")) or ""
        if key == "" then
            safeTxt(user.Error, "No API key entered", 255,0,0)
            return
        end
        updateStatus("Validating")
        saveApiKey(key)
    end)
end

if con2 and con2:IsA("GuiButton") then
    con2.MouseButton1Click:Connect(function()
        unsaveApiKey()
    end)
end

-- UTIL: open website in experience (robust)
local function openWebsiteInExperience(url)
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
    return ok, e
end

-- COMMAND SYSTEM
local HELP_TEXT = [[
/Help - show commands
/Cal or /Calculate [expr] - safe math
/ClearText - clear chat logs
/AddAPI [ChatGPT/Gemini] [API] [yes/no] - add API quickly
/UnsaveAPI or /UnApi - remove key
/OpenWebsiteInExperience or /OWINE [URL] - open site
/Loadstring [URL] - loadstring(url)()
/Script [CODE] - run code, but please add [ ] more between "CODE".
/Debug [on/off] - show debug logs
]]

local function clearChatLogs()
    for _,v in ipairs(si:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
end

local function calculate(expr)
    local ok, fn = pcall(function() return loadstring("return "..expr) end)
    if not ok or not fn then return nil, "invalid" end
    local suc, res = pcall(fn)
    if not suc then return nil, res end
    return res
end

-- commands handler (single message string)
local function handleCommand(msg)
    local lower = msg:lower()
    if lower:match("^/help") then
        safeTxt(user.Nill, "What is AI-OpenSource?  ..", 180,180,180)
        for line in HELP_TEXT:gmatch("[^\n]+") do
            safeTxt(user.Nill, line, 180,180,180)
        end
        return true
    end

    if lower:match("^/cleartext") then
        clearChatLogs()
        safeTxt(user.Suc, "Chat cleared", 0,255,0)
        return true
    end

    if lower:match("^/cal") or lower:match("^/calculate") then
        local expr = msg:match("^/%S+%s+(.+)$") or ""
        if expr == "" then
            safeTxt(user.Error, "Usage: /cal [expression]", 255,0,0)
            return true
        end
        local res, err = calculate(expr)
        if not res then safeTxt(user.Error, "Math error: "..tostring(err), 255,0,0)
        else safeTxt(user.Suc, "Result = "..tostring(res), 0,255,0)
        return true
    end

    if lower:match("^/addapi") then
        local name, key, confirm = msg:match("^/addapi%s+(%S+)%s+(%S+)%s*(%S*)")
        if not name or not key then
            safeTxt(user.Error, "Usage: /addapi [ChatGPT/Gemini] [API] [yes/no]", 255,0,0)
            return true
        end
        name = name:lower()
        local provider = (name:match("chat") and "openai") or (name:match("gemini") and "gemini") or nil
        if not provider then
            safeTxt(user.Warn, "Unknown provider. Use ChatGPT or Gemini", 255,255,0)
            return true
        end
        -- assign and optionally validate
        currentApiKey = key
        currentProvider = provider
        if confirm and confirm:lower()=="yes" then
            saveApiKey(key)
        else
            updateStatus("Key set (unconfirmed)")
            safeTxt(user.Info, "Key set. Click Confirm API or /addapi ... yes to validate", 0,170,255)
        end
        return true
    end

    if lower:match("^/unsaveapi") or lower:match("^/unapi") then
        unsaveApiKey()
        return true
    end

    if lower:match("^/openwebsiteinexperience") or lower:match("^/owine") then
        local url = msg:match("^/%S+%s+(.+)$") or ""
        url = url:gsub("^%s+",""):gsub("%s+$","")
        if url == "" then
            safeTxt(user.Error, "Usage: /OpenWebsiteInExperience [URL]", 255,0,0)
            return true
        end
        local ok,e = openWebsiteInExperience(url)
        if ok then safeTxt(user.Suc, "Opened website: "..url, 0,255,0) else safeTxt(user.Error, "OpenWebsite failed: "..tostring(e), 255,0,0) end
        return true
    end

    if lower:match("^/loadstring") then
        local url = msg:match("^/%S+%s+(.+)$") or ""
        url = url:gsub("^%s+",""):gsub("%s+$","")
        if url == "" then safeTxt(user.Error, "Usage: /loadstring [URL]",255,0,0) return true end
        safeTxt(user.Sys, "Fetching loadstring...", 255,90,0)
        local ok, res = pcall(function() return loadstring(game:HttpGet(url))() end)
        if ok then safeTxt(user.Suc, "loadstring executed",0,255,0) else safeTxt(user.Error, "loadstring error: "..tostring(res),255,0,0) end
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
        local flag = msg:match("^/debug%s+(on|off)")
        DEBUG_MODE = (flag == "on")
        safeTxt(user.Suc, "Debug mode: "..tostring(DEBUG_MODE),0,255,0)
        return true
    end

    return false
end

-- askAI: enqueue a single ask to current API
local function askAI(prompt, onSuccess, onError)
    if not currentApiKey then
        if onError then onError("no_key") end
        safeTxt(user.Error, "Not connected to any API. Please Confirm API key first.", 255,0,0)
        return
    end
    local provider = currentProvider or ((tostring(currentApiKey):match("^sk%-%w+")) and "openai") or ((tostring(currentApiKey):match("^AIza")) and "gemini") or "openai"
    updateStatus("Connecting")
    local ep = endpointsFor(provider)
    local headers = ep.makeHeaders(currentApiKey)
    local body = ep.makeBody(prompt, currentModel)

    enqueueRequest{
        url = ep.url,
        method = "POST",
        headers = headers,
        body = body,
        onSuccess = function(bodyText, resp)
            updateStatus("Connected")
            local parsed = ep.parseResult(bodyText)
            if parsed then
                if onSuccess then onSuccess(parsed) end
            else
                if onError then onError("no_text") end
            end
        end,
        onError = function(err, resp)
            if tostring(err) == "429" then
                updateStatus("Rate-limited")
                if onError then onError("rate_limited") end
            else
                updateStatus("Invalid key")
                if onError then onError(err) end
            end
        end
    }
end

-- UI send logic
local function sendMessageFromUI()
    local msg = (ch and tostring(ch.Text or "")) or ""
    msg = msg:gsub("^%s+",""):gsub("%s+$","")
    if msg == "" then return end

    -- command?
    if msg:sub(1,1) == "/" then
        local handled = handleCommand(msg)
        if not handled then safeTxt(user.Warn, "Unknown command. Type /help", 255,255,0) end
        if ch then ch.Text = "" end
        return
    end

    -- normal message
    safeTxt(user.plr, msg, 255,255,255)

    askAI(msg, function(answer)
        safeTxt(user.chat, tostring(answer), 85,255,255)
    end, function(err)
        if err=="rate_limited" then safeTxt(user.Warn, "Rate-limited. Try again later.",255,255,0)
        else safeTxt(user.Error, "AI request failed: "..tostring(err),255,0,0) end
    end)

    if ch then ch.Text = "" end
end

-- Wire send UI
if se and se:IsA("GuiButton") then
    se.MouseButton1Click:Connect(sendMessageFromUI)
end
if ch and ch:IsA("TextBox") then
    ch.FocusLost:Connect(function(enter)
        if enter then sendMessageFromUI() end
    end)
end

-- initial info
updateStatus("No key")

-- done
