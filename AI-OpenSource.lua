-- gpt 3.683

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
txt(user.Nill, "Version: Test 3.683 | © Copyright LighterCyan", 180, 180, 180)
txt(user.Warn, "Stop! For your safety, please do not share your API and avoid being stared at by people around you. Due to safety and privacy concerns, you confirm that you will use your API to continue using our AI-OpenSource or not? With respect.", 255,255,0)
txt(user.Info, "Use /help for more information or commands.", 0,170,255)
txt(user.Nill, [=[
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
  
  /Script [[CODE]]
       write script  
       Example: /script [print("Hello, World!")]  
  
  /Loadstring [URL]  
       loadstring any url of scripts  
       Example: /loadstring https://raw.githubusercontent.com/RyXeleron/infiniteyield-reborn/refs/heads/scriptblox/source  
  
  /Debug [on/off]  
       show debug  
]=], 180, 180, 180)
txt(user.Nill, "[====== Chat ======]", 180, 180, 180)

-- ===============================
-- AI-OpenSource: Frontend runner (uses existing UI instances, no instance creation)
-- Requirements (must exist already):
-- txt(user, text, r,g,b)   -- message helper
-- user table with keys like user.plr, user.chat, user.Suc, etc.

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")

-- ---------- CONFIG ----------
local rootFramePath = {"ExperienceSettings", "Menu", "AIOpenSource", "Frame"} -- path inside CoreGui
local UI_WAIT_TIMEOUT = 6 -- seconds to WaitForChild when searching (mobile safe)

local currentProvider = nil     -- "openai" or "gemini"
local currentApiKey = nil
local currentModel = "gpt-4o-mini" -- default for openai
local DEBUG_MODE = false

-- request executor detection (executor/http wrappers)
local requestFunc = nil
if syn and syn.request then
    requestFunc = syn.request
elseif http and http.request then
    requestFunc = http.request
elseif request then
    requestFunc = request
elseif fluxus and fluxus.request then
    requestFunc = fluxus.request
elseif (http_request) then
    requestFunc = http_request
end

-- JSON helper
local function jsonEncode(t) return HttpService:JSONEncode(t) end
local function jsonDecode(s) pcall(function() end) return HttpService:JSONDecode(s) end

-- ---------- FIND UI ----------
local function findUI()
    local node = CoreGui
    for _, name in ipairs(rootFramePath) do
        if not node:FindFirstChild(name) then
            local ok, res = pcall(function() return node:WaitForChild(name, UI_WAIT_TIMEOUT) end)
            if not ok or not res then return nil, "UI path not found: " .. tostring(name) end
            node = res
        else
            node = node:FindFirstChild(name)
        end
    end
    return node
end

local frame, err = findUI()
if not frame then
    warn("[AI] UI root not found:", err)
    return
end

-- try common names inside frame.Text
local safeFind = function(parent, list)
    for _, n in ipairs(list) do
        local v = parent:FindFirstChild(n)
        if v then return v end
    end
    return nil
end

local textFrame = frame:FindFirstChild("Text") or frame
local ch = safeFind(textFrame, {"chat","Chat","ch","Ch"})
local se = safeFind(textFrame, {"Send","se","send","btnSend"})
local tb = safeFind(textFrame, {"api","API","Api","apiKey","APIKey"})
local con = safeFind(textFrame, {"Confirm_api","ConfirmAPI","Confirm_apiBtn","Confirm"})
local con2 = safeFind(textFrame, {"Unsaved_API","UnsavedAPI","Unsaved"})
local st = safeFind(textFrame, {"Status","status","STAT"})
local si = safeFind(frame, {"ChatLogs","ChatFrame","ChatFrameScrolling","ChatLogsScrolling"})

if not ch or not se or not tb or not st or not si then
    -- try alternative location: Frame.ChatLogs or frame:FindFirstChild("ChatLogs")
    si = si or frame:FindFirstChild("ChatLogs")
end

-- sanity log
if DEBUG_MODE then
    print("[AI] ui found:", ch and ch.Name, se and se.Name, tb and tb.Name, con and con.Name, con2 and con2.Name, st and st.Name, si and si.Name)
end

-- helper safe txt wrapper
local function safeTxt(u,t,r,g,b)
    if type(txt) == "function" then
        pcall(txt, u, t, r or 255, g or 255, b or 255)
    end
end

-- ---------- STATUS UPDATES ----------
local function updateStatusText(s)
    if st and st:IsA("TextLabel") then
        pcall(function() st.Text = "Status: " .. tostring(s) end)
    end
end

local function setStatusSelect()
    if not currentProvider then
        updateStatusText("Select ChatGPT / Gemini")
    else
        if currentProvider == "openai" then
            updateStatusText("Selected: ChatGPT")
        else
            updateStatusText("Selected: Gemini")
        end
    end
end
setStatusSelect()

-- ---------- FILE SAVE/LOAD (if executors allow) ----------
local KEY_FILE = "AI_OPEN_KEY.txt"
local function saveApiKeyToFile(key)
    if writefile then
        pcall(function()
            writefile(KEY_FILE, (key or ""))
        end)
    end
end
local function loadApiKeyFromFile()
    if readfile and isfile and isfile(KEY_FILE) then
        local ok, data = pcall(function() return readfile(KEY_FILE) end)
        if ok then return data end
    end
    return nil
end

-- ---------- ENDPOINTS BUILDERS ----------
local function endpointsFor(provider)
    if provider == "gemini" then
        -- best-effort/generic body for the generativelanguage generateContent endpoint.
        -- APIs vary; we provide a few shapes and parse robustly.
        return {
            url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
            makeHeaders = function(key)
                return {
                    ["Content-Type"] = "application/json",
                    ["x-goog-api-key"] = key
                }
            end,
            makeBody = function(prompt)
                -- Try the simple "input" shape first (works for some wrappers)
                return jsonEncode({ input = { text = prompt } })
            end,
            parseResult = function(bodyText)
                local ok, d = pcall(function() return HttpService:JSONDecode(bodyText) end)
                if not ok or not d then return nil end
                -- check common shapes
                if d.candidates and d.candidates[1] and d.candidates[1].content and d.candidates[1].content.parts then
                    return d.candidates[1].content.parts[1].text
                end
                if d.outputText then return d.outputText end
                if d.result and d.result.output and d.result.output[1] then
                    local o = d.result.output[1]
                    if type(o) == "string" then return o end
                end
                return nil
            end
        }
    else
        -- OpenAI Responses endpoint (simple)
        return {
            url = "https://api.openai.com/v1/responses",
            makeHeaders = function(key)
                return {
                    ["Content-Type"] = "application/json",
                    ["Authorization"] = "Bearer " .. key
                }
            end,
            makeBody = function(prompt, model)
                local m = model or currentModel or "gpt-4o-mini"
                -- Use simple Responses API shape
                return jsonEncode({
                    model = m,
                    input = prompt
                })
            end,
            parseResult = function(bodyText)
                local ok, d = pcall(function() return HttpService:JSONDecode(bodyText) end)
                if not ok or not d then return nil end
                if d.output and type(d.output) == "table" and d.output[1] and d.output[1].content then
                    for _, item in ipairs(d.output[1].content) do
                        if item.type == "output_text" and item.text then return item.text end
                    end
                end
                if d.results and d.results[1] and d.results[1].output and d.results[1].output[1] and d.results[1].output[1].content then
                    local parts = d.results[1].output[1].content
                    for _, p in ipairs(parts) do
                        if p.type == "output_text" and p.text then return p.text end
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

-- ---------- REQUEST QUEUE + BACKOFF ----------
local queue = {}
local processing = false
local backoffBase = 2

local function enqueueRequest(req)
    table.insert(queue, req)
    if not processing then
        processing = true
        task.spawn(function()
            while #queue > 0 do
                local item = table.remove(queue, 1)
                local ok, resp = pcall(function()
                    if not requestFunc then error("No HTTP request executor available") end
                    return requestFunc({
                        Url = item.url,
                        Method = item.method or "POST",
                        Headers = item.headers or {},
                        Body = item.body or ""
                    })
                end)

                if not ok or not resp then
                    -- network / executor error
                    if item.onError then item.onError("request_failed", resp) end
                    -- small delay to avoid spinning
                    task.wait(0.5)
                else
                    -- support different executors with different field names
                    local status = resp.StatusCode or resp.status or resp.code or resp.Status or 0
                    local bodyText = resp.Body or resp.body or resp[1] or ""
                    if status == 429 then
                        -- rate-limited: retry with backoff
                        local retryAfter = 5
                        -- try to parse header Retry-After
                        local h = resp.Headers or resp.headers or {}
                        local ra = h["Retry-After"] or h["retry-after"]
                        if ra then
                            local n = tonumber(ra)
                            if n then retryAfter = n end
                        end
                        updateStatusText("Rate-limited. Retry in " .. tostring(retryAfter) .. "s")
                        safeTxt(user.Warn, "Rate-limited. Retry in " .. tostring(retryAfter) .. "s", 255,255,0)
                        task.wait(retryAfter)
                        -- push it back front
                        table.insert(queue, 1, item)
                    elseif status >= 200 and status < 300 then
                        if item.onSuccess then
                            pcall(item.onSuccess, bodyText, resp)
                        end
                        -- small pause so we don't hammer
                        task.wait(0.15)
                    else
                        if item.onError then pcall(item.onError, status, bodyText, resp) end
                        task.wait(0.2)
                    end
                end
            end
            processing = false
            setStatusSelect()
        end)
    end
end

-- ---------- AI ASK (uses endpointsFor + enqueue) ----------
local function askAI(prompt, onSuccess, onError)
    if not currentApiKey or not currentProvider then
        if onError then onError("no_key") end
        safeTxt(user.Error, "No API selected. Use /addapi or Confirm API", 255,0,0)
        updateStatusText("No key")
        return
    end

    updateStatusText("Connecting API [" .. tostring(currentProvider) .. "]")
    local endp = endpointsFor(currentProvider)
    local url = endp.url
    local headers = endp.makeHeaders(currentApiKey)
    local body = endp.makeBody(prompt, currentModel)

    enqueueRequest({
        url = url,
        method = "POST",
        headers = headers,
        body = body,
        onSuccess = function(bodyText, resp)
            local out = nil
            local ok, parsed = pcall(function() return HttpService:JSONDecode(bodyText) end)
            if ok and parsed then
                -- prefer endpoint parser
                out = endp.parseResult(bodyText)
            end
            out = out or "(no response)"
            updateStatusText("Connected")
            if onSuccess then pcall(onSuccess, out) end
        end,
        onError = function(status, bodyText, resp)
            if tostring(status) == "429" then
                if onError then onError("rate_limited") end
            else
                if onError then onError("http_error", tostring(status) .. " " .. tostring(bodyText)) end
            end
        end
    })
end

-- ---------- KEY VALIDATION (light-weight) ----------
local validating = false
local function validateKey(provider, key, timeoutSeconds)
    timeoutSeconds = timeoutSeconds or 12
    if validating then return false, "already_validating" end
    validating = true
    updateStatusText("Validating key...")
    local endp = endpointsFor(provider)
    local okFlag = false
    local timer = 0
    local done = false

    local function onSucc(bodyText)
        okFlag = true
        done = true
    end
    local function onErr(...)
        -- no-op; will be handled by timeout or response
        done = true
    end

    -- enqueue a single test request (don't spam)
    enqueueRequest({
        url = endp.url,
        method = "POST",
        headers = endp.makeHeaders(key),
        body = endp.makeBody("Hello"),
        onSuccess = function(bodyText) onSucc(bodyText) end,
        onError = function(...) onErr(...) end
    })

    -- wait for small timeout window
    local waited = 0
    while waited < timeoutSeconds and not done do
        task.wait(0.5)
        waited = waited + 0.5
    end
    validating = false
    if okFlag then
        return true
    else
        return false, "validate_failed_or_timeout"
    end
end

-- ---------- SAVE / UNSAVE API ----------
local function saveApiKey(key)
    currentApiKey = key
    saveApiKeyToFile(key)
    safeTxt(user.Suc, "API saved (local)", 0,255,0)
    setStatusSelect()
end

local function loadSavedApiKey()
    local f = loadApiKeyFromFile()
    if f and f ~= "" then
        currentApiKey = f
        safeTxt(user.Info, "Loaded saved API (file)", 0,170,255)
    end
end

local function unsaveApiKey()
    currentApiKey = nil
    currentProvider = nil
    if isfile and isfile(KEY_FILE) then
        pcall(function() delfile(KEY_FILE) end)
    end
    updateStatusText("Unsave key")
    safeTxt(user.Sys, "API unsaved", 255,90,0)
end

-- ---------- UI HOOKS ----------
-- Confirm button: take tb.Text, auto-detect provider by prefix and validate (with rate-limit)
if con and con:IsA("GuiObject") then
    con.Active = true
    con.MouseButton1Click:Connect(function()
        local keyText = (tb and tostring(tb.Text or "")) or ""
        if keyText == "" then
            safeTxt(user.Error, "No key in API box", 255,0,0)
            return
        end

        -- detect provider by value pattern
        local provider = nil
        if keyText:match("^sk%-proj") or keyText:match("^sk%-") or keyText:match("^gpt%-") or keyText:match("^sk_") then
            provider = "openai"
        elseif keyText:match("^AIza") or keyText:match("^AIzaSy") or keyText:match("^AIsa") or keyText:match("^AIza") then
            provider = "gemini"
        elseif keyText:match("^AIza") then
            provider = "gemini"
        else
            -- fallback: ask user to choose; set default OpenAI
            provider = "openai"
        end

        -- set provider and key
        currentProvider = provider
        currentApiKey = keyText
        updateStatusText("Key set, validating...")

        -- validate but non-blocking; run in task so UI remains responsive
        task.spawn(function()
            local ok, why = validateKey(provider, keyText, 15)
            if ok then
                updateStatusText("Connected")
                safeTxt(user.Suc, "Key validated and connected ("..tostring(provider)..")", 0,255,0)
            else
                updateStatusText("Invalid key or timeout")
                safeTxt(user.Error, "Key validation failed (or rate-limited). It's set but may not work.", 255,0,0)
            end
        end)
    end)
end

-- Unsaved button
if con2 and con2:IsA("GuiObject") then
    con2.Active = true
    con2.MouseButton1Click:Connect(function()
        unsaveApiKey()
    end)
end

-- connect Send + TextBox
local function doSendFromUI()
    local msg = (ch and tostring(ch.Text or "")) or ""
    msg = msg:gsub("^%s+",""):gsub("%s+$","")
    if msg == "" then return end

    -- commands handled first
    local lower = msg:lower()
    if lower:sub(1,1) == "/" then
        local handled = handleCommand(msg)
        if not handled then
            safeTxt(user.Warn, "Unknown command. Type /help", 255,255,0)
        end
        if ch then pcall(function() ch.Text = "" end) end
        return
    end

    -- show user message
    safeTxt(user.plr, msg, 255,255,255)
    if ch then pcall(function() ch.Text = "" end) end

    -- ask AI
    askAI(msg, function(answer)
        safeTxt(user.chat, answer, 85,255,255)
    end, function(err, detail)
        if err == "rate_limited" then
            safeTxt(user.Warn, "AI request rate-limited. Try again later.", 255,255,0)
            updateStatusText("Rate-limited")
        else
            safeTxt(user.Error, "AI request failed: "..tostring(detail or err), 255,0,0)
            updateStatusText("Request failed")
        end
    end)
end

if se and se:IsA("GuiObject") then
    se.Active = true
    se.MouseButton1Click:Connect(doSendFromUI)
end

if ch and ch:IsA("TextBox") then
    ch.FocusLost:Connect(function(enter)
        if enter then doSendFromUI() end
    end)
end

-- ---------- COMMANDS (handler used above) ----------
-- Assume safeTxt, user, si exist. We'll provide help and core commands.
local HELP_TEXT = [=[
/Help - show commands
/Cal or /Calculate [expr] - safe math
/ClearText - clear chat logs
/AddAPI [ChatGPT/Gemini] [API] [yes/no] - add API quickly
/UnsaveAPI or /UnApi - remove key
/OpenWebsiteInExperience or /OWINE [URL] - open site
/Loadstring [URL] - loadstring(url)()
/Script [[CODE]] - run code
/Debug [on/off] - show debug logs
]=]

local function clearChatLogs()
    if not si then return end
    for _,v in ipairs(si:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
end

local function calculate(expr)
    -- simple safe wrapper
    local ok, f = pcall(function() return loadstring("return " .. expr) end)
    if not ok or not f then return nil, "invalid expression" end
    local ok2, res = pcall(f)
    if not ok2 then return nil, res end
    return res
end

function handleCommand(msg)
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
        if expr == "" then safeTxt(user.Error, "Usage: /cal [expression]",255,0,0) return true end
        local res, err = calculate(expr)
        if not res then safeTxt(user.Error, "Math error: "..tostring(err),255,0,0) else safeTxt(user.Suc, "Result = "..tostring(res),0,255,0) end
        return true
    end

    if lower:match("^/addapi") then
        local name, key, confirm = msg:match("^/addapi%s+(%S+)%s+(%S+)%s*(%S*)")
        if not name or not key then safeTxt(user.Error, "Usage: /addapi [ChatGPT/Gemini] [API] [yes/no]",255,0,0) return true end
        name = name:lower()
        local provider = (name:match("chat") and "openai") or (name:match("gemini") and "gemini") or nil
        if not provider then safeTxt(user.Warn, "Unknown provider. Use ChatGPT or Gemini",255,255,0) return true end
        currentProvider = provider
        currentApiKey = key
        if confirm and confirm:lower()=="yes" then
            saveApiKey(key)
            safeTxt(user.Suc, "API saved locally (unvalidated)", 0,255,0)
        else
            safeTxt(user.Info, "Key set (temporary). Use Confirm API to validate", 0,170,255)
        end
        setStatusSelect()
        return true
    end

    if lower:match("^/unsaveapi") or lower:match("^/unapi") then
        unsaveApiKey()
        return true
    end

    if lower:match("^/openwebsiteinexperience") or lower:match("^/owine") then
        local url = msg:match("^/%S+%s+(.+)$") or ""
        url = url:gsub("^%s+",""):gsub("%s+$","")
        if url == "" then safeTxt(user.Error, "Usage: /OpenWebsiteInExperience [URL]",255,0,0) return true end
        local ok, e = pcall(function()
            if GuiService and GuiService.OpenBrowserWindow then
                GuiService:OpenBrowserWindow(url)
            elseif StarterGui and StarterGui.SetCore then
                StarterGui:SetCore("OpenBrowserWindow", url)
            else
                error("Service blocked")
            end
        end)
        if ok then safeTxt(user.Suc, "Opened website: "..url, 0,255,0) else safeTxt(user.Error, "OpenWebsite failed: "..tostring(e), 255,0,0) end
        return true
    end

    if lower:match("^/loadstring") then
        local url = msg:match("^/%S+%s+(.+)$") or ""
        url = url:gsub("^%s+",""):gsub("%s+$","")
        if url == "" then safeTxt(user.Error, "Usage: /loadstring [URL]",255,0,0) return true end
        safeTxt(user.Sys, "Fetching loadstring...",255,90,0)
        local ok,res = pcall(function() return loadstring(game:HttpGet(url))() end)
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
            local ok,r = pcall(fn)
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

-- ---------- INITIAL LOAD ----------
-- try load saved key silently
loadSavedApiKey()
if currentApiKey and not currentProvider then
    -- try to guess provider from saved key
    if currentApiKey:match("^sk") then currentProvider = "openai"
    elseif currentApiKey:match("^AIza") then currentProvider = "gemini"
    end
    setStatusSelect()
end

-- debug heartbeat display (if enabled)
task.spawn(function()
    while true do
        if DEBUG_MODE then
            safeTxt(user.Info, ("Debug: q=%d processing=%s req=%s"):format(#queue, tostring(processing), tostring(requestFunc~=nil)), 0,170,255)
        end
        task.wait(10)
    end
end)

-- final status
setStatusSelect()
safeTxt(user.Info, "AI-OpenSource frontend initialized", 0,170,255)
safeTxt(user.Nill, "I'm not sure it work or not, but I trust it 100% not working lol...", 0, 255, 152)
