-- gpt 3.62

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
txt(user.Nill, "Version: Test 3.62 | © Copyright LighterCyan", 180, 180, 180)
txt(user.Warn, "Stop! For your safety, please do not share your API and avoid being stared at by people around you. Due to safety and privacy concerns, you confirm that you will use your API to continue using our AI-OpenSource or not? With respect.", 255,255,0)
txt(user.Nill, "[====== Chat ======]", 180, 180, 180)

-- AI-API Bridge (OpenAI / Gemini) for your existing AIOpenSource UI
-- Requires existing UI under:
-- CoreGui.ExperienceSettings.Menu.AIOpenSource.Frame
-- and existing helper `txt(user, text, R,G,B)` function.

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local debugMode = false -- set true to print some internal traces

-- find UI root (tolerant)
local ok, MenuRoot = pcall(function()
    return CoreGui:WaitForChild("ExperienceSettings", 6).Menu
end)
if not ok or not MenuRoot then
    warn("[AI] ExperienceSettings.Menu not found")
    return
end

local aioRoot = MenuRoot:FindFirstChild("AIOpenSource") or MenuRoot:FindFirstChild("AI-OpenSource") or MenuRoot:FindFirstChild("ChatGPT")
if not aioRoot then
    warn("[AI] AIOpenSource frame not found under ExperienceSettings.Menu")
    return
end

local Frame = aioRoot:FindFirstChild("Frame") or aioRoot

-- look up common UI elements (names you used earlier)
local apiBox = Frame:FindFirstChild("api") or Frame:FindFirstChild("APIKeyBox") -- TextBox
local confirmBtn = Frame:FindFirstChild("Confirm_api") or Frame:FindFirstChild("SaveBtn")
local unsaveBtn = Frame:FindFirstChild("Unsaved_API")
local statusLabel = Frame:FindFirstChild("Status") or Frame:FindFirstChild("st") -- TextLabel
local chatBox = Frame:FindFirstChild("chat") or Frame:FindFirstChild("ch") -- TextBox
local sendBtn = Frame:FindFirstChild("Send") or Frame:FindFirstChild("se") -- TextButton
local chatLogs = Frame:FindFirstChild("ChatLogs") or Frame:FindFirstChild("si") -- ScrollingFrame

if not chatBox or not sendBtn or not chatLogs or not apiBox or not confirmBtn or not statusLabel then
    warn("[AI] One or more UI elements not found. Check names: api, Confirm_api, Unsaved_API, Status, chat, Send, ChatLogs")
    -- we continue but will abort actions where elements missing
end

-- user label map (assume txt(user, text, R,G,B) exists globally)
local userLabels = {
    plr = "You: ",
    chat = "AI: ",
    Error = "Error: ",
    Suc = "Success: ",
    Warn = "Warning: ",
    Info = "Information: ",
    Nill = "",
    Sys = "System: "
}

-- helper to set status text safely
local function setStatus(txtStr)
    if statusLabel and statusLabel:IsA("TextLabel") then
        statusLabel.Text = "Status: " .. tostring(txtStr)
    end
end

-- find an HTTP request function (executor friendly)
local function findRequestFunc()
    -- common executor apis
    if syn and syn.request then return syn.request end
    if http and http.request then return http.request end
    if request then return request end
    if fluxus and fluxus.request then return fluxus.request end
    -- fallback: Roblox HttpService (RequestAsync) - may require permissions and not available in normal client environment
    if HttpService and HttpService.HttpEnabled ~= false and HttpService.RequestInternal then
        return function(opts)
            -- map to RequestInternal style? try RequestAsync if available
            if HttpService.RequestInternal then
                return HttpService:RequestInternal(opts)
            elseif HttpService.RequestAsync then
                return HttpService:RequestAsync(opts)
            else
                error("No executor request function available")
            end
        end
    end
    return nil
end

local httpRequest = findRequestFunc()
if debugMode then print("[AI] httpRequest:", httpRequest) end

-- JSON helpers
local function jsonEncode(t) return HttpService:JSONEncode(t) end
local function jsonDecode(s) 
    local ok, res = pcall(function() return HttpService:JSONDecode(s) end)
    if ok then return res end
    return nil
end

-- Rate limit queue & backoff
local queue = {}
local processing = false
local baseDelay = 1.2 -- seconds between requests
local maxRetries = 4

local function enqueueRequest(req)
    table.insert(queue, req)
    if not processing then
        processing = true
        task.spawn(function()
            while #queue > 0 do
                local item = table.remove(queue, 1)
                local success = false
                local attempt = 0
                local delayTime = baseDelay
                while attempt <= maxRetries and not success do
                    attempt = attempt + 1
                    if debugMode then print("[AI] request attempt", attempt, item.url) end
                    -- perform request
                    local ok, resp = pcall(function()
                        if httpRequest then
                            -- executor-style expects a table: Url, Method, Headers, Body
                            return httpRequest({
                                Url = item.url,
                                Method = item.method or "POST",
                                Headers = item.headers or {},
                                Body = item.body
                            })
                        else
                            -- try HttpService:RequestAsync
                            return HttpService:RequestAsync({
                                Url = item.url,
                                Method = item.method or "POST",
                                Headers = item.headers or {},
                                Body = item.body
                            })
                        end
                    end)

                    if not ok then
                        -- fatal error calling executor
                        if item.onError then
                            item.onError("request_failed", tostring(resp))
                        end
                        success = true -- stop retrying because executor call failed (no network)
                        break
                    end

                    -- now analyze response
                    local statusCode = tonumber(resp.StatusCode) or tonumber(resp.status) or tonumber(resp.Status) or 0
                    local bodyText = resp.Body or resp.body or (type(resp) == "table" and resp.Body) or tostring(resp)
                    if statusCode == 200 or statusCode == 201 then
                        if item.onSuccess then
                            item.onSuccess(bodyText, resp)
                        end
                        success = true
                    elseif statusCode == 429 then
                        -- backoff and retry
                        if item.onError then item.onError("rate_limited", bodyText) end
                        task.wait(delayTime)
                        delayTime = delayTime * 1.8
                    else
                        -- other http error - forward to onError
                        if item.onError then item.onError("http_error", {code = statusCode, body = bodyText}) end
                        success = true -- do not retry by default for other codes
                    end
                end
                -- small pause between queued items
                task.wait(baseDelay)
            end
            processing = false
        end)
    end
end

-- Endpoint builders
local function endpointsFor(provider)
    provider = provider or "openai"
    if provider == "google" then
        return {
            url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
            buildHeaders = function(key)
                return {
                    ["Content-Type"] = "application/json",
                    ["x-goog-api-key"] = key
                }
            end,
            buildBody = function(prompt)
                -- minimal generateContent body for Gemini v1beta (adapt as needed).
                return jsonEncode({
                    prompt = {
                        text = prompt
                    }
                })
            end
        }
    else
        -- OpenAI Responses API (simple)
        return {
            url = "https://api.openai.com/v1/responses",
            buildHeaders = function(key)
                return {
                    ["Content-Type"] = "application/json",
                    ["Authorization"] = "Bearer " .. key
                }
            end,
            buildBody = function(prompt, model)
                model = model or "gpt-4o-mini"
                return jsonEncode({
                    model = model,
                    input = prompt
                })
            end
        }
    end
end

-- High-level send wrappers
local function sendOpenAI(apiKey, prompt, onSuccess, onError, model)
    local endp = endpointsFor("openai")
    local body = endp.buildBody(prompt, model)
    enqueueRequest({
        url = endp.url,
        method = "POST",
        headers = endp.buildHeaders(apiKey),
        body = body,
        onSuccess = function(bodyText)
            -- Responses API returns JSON with choices or output[0].content etc. Try decode defensively.
            local decoded = jsonDecode(bodyText)
            local out = nil
            if decoded then
                -- Try multiple shapes
                if decoded.output and decoded.output[1] and decoded.output[1].content then
                    -- sometimes { output: [ { content: [ { type: "output_text", text: "..." } ] } ] }
                    local cont = decoded.output[1].content
                    for _,c in ipairs(cont) do
                        if c.type == "output_text" and c.text then
                            out = (out or "") .. c.text
                        end
                    end
                end
                if not out and decoded.choices and decoded.choices[1] and decoded.choices[1].delta then
                    out = decoded.choices[1].delta.content or decoded.choices[1].text
                end
                if not out and decoded.choices and decoded.choices[1] and decoded.choices[1].message then
                    out = decoded.choices[1].message.content or decoded.choices[1].message
                end
                if not out and decoded.result and decoded.result.output_text then
                    out = decoded.result.output_text
                end
            end
            if not out then out = "(no text - decode failed)" end
            if onSuccess then pcall(onSuccess, out, decoded) end
        end,
        onError = function(kind, info)
            if onError then pcall(onError, kind, info) end
        end
    })
end

local function sendGemini(apiKey, prompt, onSuccess, onError)
    local endp = endpointsFor("google")
    local body = endp.buildBody(prompt)
    enqueueRequest({
        url = endp.url,
        method = "POST",
        headers = endp.buildHeaders(apiKey),
        body = body,
        onSuccess = function(bodyText)
            local decoded = jsonDecode(bodyText)
            local out = nil
            if decoded then
                if decoded.candidates and decoded.candidates[1] and decoded.candidates[1].content and decoded.candidates[1].content.parts then
                    out = decoded.candidates[1].content.parts[1].text
                elseif decoded.output and decoded.output[1] and decoded.output[1].content and decoded.output[1].content[1] then
                    out = decoded.output[1].content[1].text
                end
            end
            if not out then out = "(no text - decode failed)" end
            if onSuccess then pcall(onSuccess, out, decoded) end
        end,
        onError = function(kind, info)
            if onError then pcall(onError, kind, info) end
        end
    })
end

-- key store
local currentKey = nil
local currentProvider = nil -- "openai" or "google"

local function detectProviderFromKey(key)
    if not key or key == "" then return nil end
    if key:match("^sk") then return "openai" end
    if key:match("^AIza") then return "google" end
    if key:match("^sk%-proj") then return "openai" end -- your sk-proj case
    -- fallback nil (ask user)
    return nil
end

-- Validate key (lightweight)
local function validateKey(key, provider, callback)
    -- Option: skip validation by passing provider="skip"
    if provider == "skip" then
        if callback then callback(true, "skipped") end
        return
    end

    local done = false
    setStatus("Connecting")
    -- We'll do a single small request to test authorization:
    if provider == "google" then
        -- do a minimal generate call with a tiny prompt
        sendGemini(key, "Hello", function(out)
            if not done then
                done = true
                callback(true, out)
            end
        end, function(kind, info)
            if not done then
                done = true
                callback(false, {kind = kind, info = info})
            end
        end)
    else
        -- openai: request models list (GET) might be blocked; use /v1/responses with small prompt as test
        sendOpenAI(key, "Hello", function(out)
            if not done then
                done = true
                callback(true, out)
            end
        end, function(kind, info)
            if not done then
                done = true
                callback(false, {kind = kind, info = info})
            end
        end)
    end
end

-- UI actions
if confirmBtn then
    confirmBtn.MouseButton1Click:Connect(function()
        if not apiBox then return end
        local key = tostring(apiBox.Text or "")
        if key == "" then
            setStatus("No key")
            if txt then pcall(txt, userLabels.Sys, "No API provided", 255, 90, 0) end
            return
        end

        local detected = detectProviderFromKey(key)
        currentKey = key
        currentProvider = detected or "openai"

        setStatus("Connecting")
        -- validate but allow skip by writing "skip" suffix? (not required)
        validateKey(currentKey, currentProvider, function(ok, info)
            if ok then
                setStatus("Connected (" .. tostring(currentProvider) .. ")")
                if txt then pcall(txt, userLabels.Suc, "Connected to " .. tostring(currentProvider), 0,255,0) end
            else
                setStatus("Invalid key")
                if txt then pcall(txt, userLabels.Error, "Invalid key or rate-limited", 255,0,0) end
            end
        end)
    end)
end

if unsaveBtn then
    unsaveBtn.MouseButton1Click:Connect(function()
        currentKey = nil
        currentProvider = nil
        setStatus("Unsave key")
        if txt then pcall(txt, userLabels.Sys, "API key cleared", 255, 90, 0) end
    end)
end

-- sending prompt function (wired to send button)
local lastSentAt = 0
local minInterval = 1.0 -- seconds between sending to avoid abuse/429

local function sendPromptFromUI()
    if not chatBox or not sendBtn then return end
    local prompt = tostring(chatBox.Text or "")
    if prompt == "" then return end

    local now = tick()
    if now - lastSentAt < minInterval then
        if txt then pcall(txt, userLabels.Warn, "Please wait a bit before sending again", 255,255,0) end
        return
    end
    lastSentAt = now

    -- show user message
    if txt then pcall(txt, userLabels.plr, prompt, 255,255,255) end

    -- clear input
    chatBox.Text = ""

    if not currentKey then
        if txt then pcall(txt, userLabels.Error, "No API key set", 255,0,0) end
        setStatus("No key")
        return
    end

    setStatus("Connecting")
    -- send according to provider
    if currentProvider == "google" then
        sendGemini(currentKey, prompt,
            function(out)
                if txt then pcall(txt, userLabels.chat, out, 85,255,255) end
                setStatus("Connected")
            end,
            function(kind, info)
                if txt then pcall(txt, userLabels.Error, "Request error: "..tostring(kind), 255,0,0) end
                setStatus("Invalid key")
            end
        )
    else
        sendOpenAI(currentKey, prompt, function(out)
            if txt then pcall(txt, userLabels.chat, out, 85,255,255) end
            setStatus("Connected")
        end, function(kind, info)
            if txt then pcall(txt, userLabels.Error, "Request error: "..tostring(kind), 255,0,0) end
            setStatus("Invalid key")
        end)
    end
end

-- wire send button
if sendBtn then
    sendBtn.MouseButton1Click:Connect(sendPromptFromUI)
end

-- wire enter key in chatBox (if applicable)
if chatBox and chatBox:IsA("TextBox") then
    chatBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            sendPromptFromUI()
        end
    end)
end

-- auto-scroll ChatLogs when new messages added
if chatLogs and chatLogs:IsA("ScrollingFrame") then
    -- rely on AutomaticCanvasSize = Enum.AutomaticSize.Y on chatLogs and UIListLayout in it
    -- connect descendant added to ensure scroll bottom
    chatLogs.DescendantAdded:Connect(function()
        -- small delay then set canvas offset
        task.defer(function()
            pcall(function()
                chatLogs.CanvasPosition = Vector2.new(0, chatLogs.CanvasSize.Y.Offset)
            end)
        end)
    end)
end

-- initial status
setStatus("No key")

if debugMode then
    print("[AI] Module initialized. httpRequest:", tostring(httpRequest))
end

-- END
