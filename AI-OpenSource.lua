-- gpt 3.66

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
txt(user.Nill, "Version: Test 3.66 | © Copyright LighterCyan", 180, 180, 180)
txt(user.Warn, "Stop! For your safety, please do not share your API and avoid being stared at by people around you. Due to safety and privacy concerns, you confirm that you will use your API to continue using our AI-OpenSource or not? With respect.", 255,255,0)
txt(user.Info, "Use /help for more information or commands.", 0,170,255)
txt(user.Nill, "[====== Chat ======]", 180, 180, 180)

-- Profile: Tail script to wire AI UI + commands + rate-limit safe http
-- Requires existing UI elements:
--  - api TextBox (name "api")
--  - Confirm_api TextButton (name "Confirm_api") -> con
--  - Unsaved_API TextButton (name "Unsaved_API") -> con2
--  - Status TextLabel (name "Status") -> st
--  - chat TextBox (name "chat") -> ch
--  - Send TextButton (name "Send") -> se
--  - ChatLogs ScrollingFrame (name "ChatLogs") -> si
--  - txt(user, text, r,g,b) function already defined elsewhere (used for logging to si)

local HttpReq = (syn and syn.request) or (http and http.request) or request or http_request
local jsonEncode = game:GetService("HttpService").JSONEncode
local jsonDecode = game:GetService("HttpService").JSONDecode
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- locate UI root tolerant (try some known paths)
local function findUI()
    local ok, root = pcall(function()
        local es = CoreGui:FindFirstChild("ExperienceSettings") or CoreGui:WaitForChild("ExperienceSettings", 6)
        if not es then return nil end
        local menu = es:FindFirstChild("Menu") or es:FindFirstChildWhichIsA("Frame")
        if not menu then return nil end
        local ao = menu:FindFirstChild("AIOpenSource") or menu:FindFirstChild("ChatGPT") or menu:FindFirstChild("gpt") or menu:FindFirstChild("GPT")
        if ao and ao:FindFirstChild("Frame") then
            return ao.Frame
        elseif ao then
            return ao
        else
            -- fallback: try ChatGPT directly
            local cg = menu:FindFirstChild("ChatGPT")
            if cg and cg:FindFirstChild("Frame") then return cg.Frame end
            return menu
        end
    end)
    if ok then return root end
    return nil
end

local root = findUI()
if not root then
    warn("[AI] UI root not found (ExperienceSettings.Menu.AIOpenSource.Frame)")
    return
end

-- try to locate elements
local tb = root:FindFirstChild("api") or root:FindFirstChild("API") or root:FindFirstChildWhichIsA("TextBox")
local con = root:FindFirstChild("Confirm_api") or root:FindFirstChild("ConfirmAPI") or root:FindFirstChildWhichIsA("TextButton")
local con2 = root:FindFirstChild("Unsaved_API") or root:FindFirstChild("UnsavedAPI") or root:FindFirstChildWhichIsA("TextButton")
local st  = root:FindFirstChild("Status") or root:FindFirstChildWhichIsA("TextLabel")
local ch  = root:FindFirstChild("chat") or root:FindFirstChild("Chat") or root:FindFirstChildWhichIsA("TextBox")
local se  = root:FindFirstChild("Send") or root:FindFirstChildWhichIsA("TextButton")
local si  = root:FindFirstChild("ChatLogs") or root:FindFirstChildWhichIsA("ScrollingFrame")

if not (tb and con and con2 and st and ch and se and si) then
    warn("[AI] Some UI elements not found, check names. tb, con, con2, st, ch, se, si must exist.")
    -- but continue to avoid immediate crash
end

-- user label mapping for txt()
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

-- debug toggle
local DEBUG_MODE = false

local function logDebug(msg)
    if DEBUG_MODE and type(txt) == "function" then
        pcall(txt, user.Info, tostring(msg), 0,170,255)
    end
end

-- ======================
-- HTTP queue + rate-limit/backoff
-- ======================
local queue = {}
local inFlight = false
local last429Backoff = 0
local function enqueueRequest(req)
    -- req = { url, method, headers, body, onSuccess, onError }
    table.insert(queue, req)
    -- start worker
    if not inFlight then
        task.spawn(function()
            while #queue > 0 do
                -- respect global backoff
                if last429Backoff > tick() then
                    local waitFor = math.ceil(last429Backoff - tick())
                    if st then st.Text = ("Status: Rate - limited. Retry in %ds"):format(waitFor) end
                    logDebug("Backoff active, waiting "..tostring(waitFor).."s")
                    task.wait(waitFor)
                end

                local r = table.remove(queue, 1)
                inFlight = true
                local ok, resp = pcall(function()
                    if not HttpReq then error("HTTP unavailable") end
                    return HttpReq({
                        Url = r.url,
                        Method = r.method or "GET",
                        Headers = r.headers or {},
                        Body = r.body
                    })
                end)

                if not ok then
                    if r.onError then pcall(r.onError, resp) end
                else
                    -- handle 429
                    local status = tonumber(resp.StatusCode) or tonumber(resp.status) or 0
                    if status == 429 then
                        local retry = 10
                        local headerRetry = resp.Headers and (resp.Headers["Retry-After"] or resp.Headers["retry-after"])
                        if headerRetry then
                            local n = tonumber(headerRetry)
                            if n and n>0 then retry = n end
                        end
                        last429Backoff = tick() + retry
                        if st then st.Text = ("Status: Rate - limited. Retry in %ds"):format(retry) end
                        logDebug("429 received; backoff "..tostring(retry).."s")
                        -- push back current request to try again later? No — drop and signal onError with code
                        if r.onError then pcall(r.onError, {code=429, resp=resp}) end
                    else
                        if r.onSuccess then pcall(r.onSuccess, resp.Body, resp) end
                    end
                end

                inFlight = false
                task.wait(0.15) -- small pacing between requests
            end
        end)
    end
end

-- ======================
-- endpoints builder (ChatGPT / Gemini)
-- ======================
local currentProvider = nil -- "openai" or "gemini"
local currentKey = nil
local currentModel = "gpt-4o-mini" -- default

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
                -- minimal; Google API often expects a 'prompt' object or 'input'
                -- This is a conservative format used on many examples: {prompt:{text: "..."}}
                return jsonEncode({
                    prompt = {
                        text = prompt
                    }
                })
            end,
            parseResult = function(bodyText)
                local ok, d = pcall(jsonDecode, bodyText)
                if not ok or not d then return nil end
                if d.candidates and d.candidates[1] and d.candidates[1].content and d.candidates[1].content.parts then
                    return d.candidates[1].content.parts[1].text
                elseif d.outputText then
                    return d.outputText
                end
                return nil
            end
        }
    else
        -- default: OpenAI Responses API shape
        return {
            url = "https://api.openai.com/v1/responses",
            makeHeaders = function(key)
                return {
                    ["Content-Type"] = "application/json",
                    ["Authorization"] = "Bearer " .. key
                }
            end,
            makeBody = function(prompt, model)
                local m = model or currentModel
                -- Responses API expects "input" as list or string depending on SDK; here's minimal
                return jsonEncode({
                    model = m,
                    input = prompt
                })
            end,
            parseResult = function(bodyText)
                local ok, d = pcall(jsonDecode, bodyText)
                if not ok or not d then return nil end
                -- attempt to extract responses
                if d.outputText then return d.outputText end
                if d.output and type(d.output)=="table" and d.output[1] and d.output[1].content then
                    for _,item in ipairs(d.output[1].content) do
                        if item.type == "output_text" and item.text then return item.text end
                    end
                end
                if d.choices and d.choices[1] and d.choices[1].message and d.choices[1].message.content then
                    return d.choices[1].message.content
                end
                if d.results and d.results[1] and d.results[1].output_text then return d.results[1].output_text end
                return nil
            end
        }
    end
end

-- detect provider by key hint
local function detectProviderFromKey(key)
    if not key then return nil end
    if key:match("^AIza") then return "gemini" end
    if key:match("^sk%-") or key:match("^sk_") or key:match("^sk") then return "openai" end
    -- fallback: try to guess; prefer openai by default if starts with "sk"
    return nil
end

-- ======================
-- validation (single request)
-- ======================
local function validateKeyAndSet(key, onDone)
    if not key or key == "" then
        if st then st.Text = "Status: No key" end
        if type(txt)=="function" then pcall(txt, user.Error, "No key provided", 255,0,0) end
        if onDone then onDone(false) end
        return
    end

    local prov = detectProviderFromKey(key) or "openai"
    currentProvider = prov
    currentKey = key

    -- UI update
    if st then
        st.Text = ("Status: Connecting API [%s]"):format((prov=="gemini") and "Gemini" or "ChatGPT")
    end
    if type(txt)=="function" then pcall(txt, user.Sys, ("Connecting API [%s]"):format(prov), 255,90,0) end

    local ep = endpointsFor(prov)
    local testBody = ep.makeBody("Hello") -- minimal probe
    local headers = ep.makeHeaders(key)

    local tried = false
    local function onSuccess(bodyText, resp)
        -- try parse
        local out = nil
        pcall(function() out = ep.parseResult(bodyText) end)
        if out and out ~= "" then
            if st then st.Text = "Status: Connected" end
            if type(txt)=="function" then pcall(txt, user.Suc, "Connected: API validated", 0,255,0) end
            if onDone then onDone(true) end
        else
            -- server may return 200 but unknown shape -> still consider connected if 200 but warn
            if tonumber(resp.StatusCode) and tonumber(resp.StatusCode) >= 200 and tonumber(resp.StatusCode) < 300 then
                if st then st.Text = "Status: Connected (unparsed response)" end
                if type(txt)=="function" then pcall(txt, user.Warn, "Connected but couldn't parse response. You may still be able to use it.", 255,255,0) end
                if onDone then onDone(true) end
            else
                if st then st.Text = "Status: Invalid key" end
                if type(txt)=="function" then pcall(txt, user.Error, "Invalid key or API returned no text", 255,0,0) end
                if onDone then onDone(false) end
            end
        end
    end

    local function onError(err)
        -- err could be table with code
        if type(err) == "table" and err.code == 429 then
            -- already handled by enqueueRequest: it sets last429Backoff
            if st then st.Text = "Status: Rate - limited. Retry soon" end
            if type(txt)=="function" then pcall(txt, user.Warn, "Rate limited — try again later", 255,255,0) end
            if onDone then onDone(false) end
        else
            if st then st.Text = "Status: Invalid key" end
            if type(txt)=="function" then pcall(txt, user.Error, "Key validation failed: " .. tostring(err), 255,0,0) end
            if onDone then onDone(false) end
        end
    end

    -- Enqueue validation request (use POST)
    enqueueRequest({
        url = ep.url,
        method = "POST",
        headers = headers,
        body = testBody,
        onSuccess = onSuccess,
        onError = onError
    })
end

-- ======================
-- hook Confirm / Unsaved
-- ======================
if con then
    con.MouseButton1Click:Connect(function()
        local key = (tb and tb.Text) and tostring(tb.Text):gsub("^%s+",""):gsub("%s+$","") or ""
        if key == "" then
            if st then st.Text = "Status: No key" end
            if type(txt)=="function" then pcall(txt, user.Error, "No API key in textbox", 255,0,0) end
            return
        end

        -- detect provider and set status quickly
        local prov = detectProviderFromKey(key)
        if prov == "gemini" then
            if st then st.Text = "Status: Select Gemini" end
        elseif prov == "openai" then
            if st then st.Text = "Status: Select ChatGPT" end
        else
            if st then st.Text = "Status: Selecting provider..." end
        end

        -- validate key (async)
        validateKeyAndSet(key, function(ok)
            if ok then
                -- persisted currentKey / provider kept
                currentKey = key
                currentProvider = detectProviderFromKey(key) or currentProvider or "openai"
                if st then st.Text = "Status: Connected" end
            else
                -- keep key but mark invalid
                if st then st.Text = "Status: Invalid key" end
            end
        end)
    end)
end

if con2 then
    con2.MouseButton1Click:Connect(function()
        currentKey = nil
        currentProvider = nil
        if st then st.Text = "Status: Unsave key" end
        if type(txt)=="function" then pcall(txt, user.Sys, "API key unsaved", 255,90,0) end
    end)
end

-- ======================
-- ask AI (send prompt)
-- ======================
local function askAI(prompt, onResult, onError)
    if not currentKey or not currentProvider then
        if type(txt)=="function" then pcall(txt, user.Warn, "No API configured. Use Confirm_api", 255,255,0) end
        if onError then onError("no_key") end
        return
    end
    local ep = endpointsFor(currentProvider)
    local body = ep.makeBody(prompt, currentModel)
    local headers = ep.makeHeaders(currentKey)

    enqueueRequest({
        url = ep.url,
        method = "POST",
        headers = headers,
        body = body,
        onSuccess = function(bodyText, resp)
            local out = nil
            pcall(function() out = ep.parseResult(bodyText) end)
            if out then
                if onResult then onResult(out) end
            else
                -- fallback to raw
                if onResult then onResult(bodyText) end
            end
        end,
        onError = function(err)
            if onError then onError(err) end
        end
    })
end

-- ======================
-- Connect send UI (ch + se)
-- ======================
local function sendMessageFromUI()
    local msg = (ch and tostring(ch.Text or "")) or ""
    msg = msg:gsub("^%s+",""):gsub("%s+$","")
    if msg == "" then return end

    -- command handling (leading '/')
    if msg:sub(1,1) == "/" then
        local handled = false

        -- /help
        if msg:lower():match("^/help") then
            if type(txt)=="function" then
                pcall(txt, user.Sys, "Available commands:", 255,90,0)
                pcalltxt(user.Nill, [["
  /Help (BROKEN)
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
"]], 180, 180, 180)
            end
            handled = true
        end

        -- /cal
        if not handled and msg:lower():match("^/cal") or msg:lower():match("^/calculate") then
            local expr = msg:match("^/%S+%s+(.+)$") or ""
            local ok, res = pcall(function()
                local f, e = loadstring("return "..expr)
                if not f then error(e) end
                local ok2, r = pcall(f)
                if not ok2 then error(r) end
                return r
            end)
            if ok then
                pcall(txt, user.Suc, "Result = "..tostring(res), 0,255,0)
            else
                pcall(txt, user.Error, "Math error: "..tostring(res), 255,0,0)
            end
            handled = true
        end

        -- /cleartext
        if not handled and msg:lower():match("^/cleartext") then
            for _,v in ipairs(si:GetChildren()) do
                if v:IsA("TextLabel") then v:Destroy() end
            end
            pcall(txt, user.Suc, "Chat cleared", 0,255,0)
            handled = true
        end

        -- /openwebsiteinexperience or /owine
        if not handled and (msg:lower():match("^/openwebsiteinexperience") or msg:lower():match("^/owine")) then
            local url = msg:match("^/%S+%s+(.+)$") or ""
            url = url:gsub("^%s+",""):gsub("%s+$","")
            if url == "" then
                pcall(txt, user.Error, "Usage: /OpenWebsiteInExperience [URL]", 255,0,0)
            else
                local ok, e = pcall(function()
                    -- Try GuiService.OpenBrowserWindow (may not be present on some clients)
                    if GuiService and GuiService.OpenBrowserWindow then
                        GuiService:OpenBrowserWindow(url)
                    else
                        -- fallback to SetCore if available
                        local StarterGui = game:GetService("StarterGui")
                        if StarterGui and StarterGui:SetCore then
                            StarterGui:SetCore("OpenBrowserWindow", url)
                        else
                            error("No supported API to open website in-game")
                        end
                    end
                end)
                if ok then
                    pcall(txt, user.Suc, "Opened website: "..url, 0,255,0)
                else
                    pcall(txt, user.Error, "OpenWebsite failed: "..tostring(e), 255,0,0)
                end
            end
            handled = true
        end

        -- /loadstring
        if not handled and msg:lower():match("^/loadstring") then
            local url = msg:match("^/%S+%s+(.+)$") or ""
            url = url:gsub("^%s+",""):gsub("%s+$","")
            if url == "" then
                pcall(txt, user.Error, "Usage: /loadstring [URL]", 255,0,0)
            else
                pcall(txt, user.Sys, "Fetching loadstring...", 255,90,0)
                local ok, res = pcall(function() return loadstring(game:HttpGet(url))() end)
                if ok then pcall(txt, user.Suc, "loadstring executed", 0,255,0) else pcall(txt, user.Error, "loadstring error: "..tostring(res), 255,0,0) end
            end
            handled = true
        end

        -- /script
        if not handled and msg:lower():match("^/script") then
            local code = msg:match("^/%S+%s+(.+)$") or ""
            if code == "" then
                pcall(txt, user.Error, "Usage: /script [[CODE]]", 255,0,0)
            else
                -- remove wrapping [[ ]] if present
                code = code:gsub("^%[%[",""):gsub("%]%]$","")
                pcall(txt, user.Sys, "Executing script...", 255,90,0)
                local fn, err = loadstring(code)
                if not fn then pcall(txt, user.Error, "Compile error: "..tostring(err),255,0,0) else
                    local ok, r = pcall(fn)
                    if ok then pcall(txt, user.Suc, "Script executed",0,255,0) else pcall(txt, user.Error, "Runtime error: "..tostring(r),255,0,0) end
                end
            end
            handled = true
        end

        -- /debug on/off
        if not handled and msg:lower():match("^/debug%s+(on|off)$") then
            local flag = msg:match("^/debug%s+(on|off)$"):lower()
            DEBUG_MODE = (flag == "on")
            pcall(txt, user.Suc, "Debug mode: "..tostring(DEBUG_MODE), 0,255,0)
            handled = true
        end

        if not handled then pcall(txt, user.Warn, "Unknown command. Type /help", 255,255,0) end

        -- clear input
        if ch then ch.Text = "" end
        return
    end

    -- normal message to AI
    if type(txt) == "function" then pcall(txt, user.plr, msg, 255,255,255) end

    -- send to AI (queue)
    askAI(msg, function(answer)
        if type(txt) == "function" then
            pcall(txt, user.chat, answer, 85,255,255)
        end
    end, function(err)
        if type(txt) == "function" then
            pcall(txt, user.Error, "AI request failed: "..tostring(err), 255,0,0)
        end
    end)

    if ch then ch.Text = "" end
end

-- connect UI
if se then
    se.MouseButton1Click:Connect(sendMessageFromUI)
end
if ch then
    ch.FocusLost:Connect(function(enter)
        if enter then sendMessageFromUI() end
    end)
end

-- initial status
if st then st.Text = "Status: No key" end
logDebug("AI UI wired")

-- quick expose for debug in global (optional)
_G.AIOpenSource = _G.AIOpenSource or {}
_G.AIOpenSource.askAI = askAI
_G.AIOpenSource.validateKeyAndSet = validateKeyAndSet
_G.AIOpenSource.getStatus = function() return { provider = currentProvider, key = (currentKey and "[set]" or nil), lastBackoff = last429Backoff } end
