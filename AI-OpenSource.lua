-- gpt 3.658

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
txt(user.Nill, "Version: Test 3.658 | © Copyright LighterCyan", 180, 180, 180)
txt(user.Warn, "Stop! For your safety, please do not share your API and avoid being stared at by people around you. Due to safety and privacy concerns, you confirm that you will use your API to continue using our AI-OpenSource or not? With respect.", 255,255,0)
txt(user.Info, "Use /help for more information or commands.", 0,170,255)
txt(user.Nill, [[
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
  /Script [CODE] -- add [] more please.
    write script
    Example: /script [print("Hello, World!")]
  /Loadstring [URL]
    loadstring any url of scripts
    Example: /loadstring https://raw.githubusercontent.com/RyXeleron/infiniteyield-reborn/refs/heads/scriptblox/source
]], 180, 180, 180)
txt(user.Nill, "[====== Chat ======]", 180, 180, 180)

-- AI Chat tail script (attach to existing UI variables)
-- ต้องมีตัวแปร/ฟังก์ชันต่อไปนี้ที่ถูกสร้างไว้ล่วงหน้า:
-- ch   = TextBox (chat input)
-- se   = TextButton (send)
-- si   = ScrollingFrame (ChatLogs)
-- st   = TextLabel (Status)
-- user = table of labels (user.plr, user.chat, user.Error, ...)
-- txt(userLabel, text, r,g,b)  -- function that appends a TextLabel to si

-- =====================================
-- Services + helpers
-- =====================================
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

-- http request wrapper (support many executors)
local function http_request_wrap(req)
    local ok, res
    if syn and syn.request then
        ok, res = pcall(function() return syn.request(req) end)
        if ok then return res end
    end
    if http and http.request then
        ok, res = pcall(function() return http.request(req) end)
        if ok then return res end
    end
    if request then
        ok, res = pcall(function() return request(req) end)
        if ok then return res end
    end
    if fluxus and fluxus.request then
        ok, res = pcall(function() return fluxus.request(req) end)
        if ok then return res end
    end
    -- fallback: try http_request (old)
    if http_request then
        ok, res = pcall(function() return http_request(req) end)
        if ok then return res end
    end
    return nil, "no-http"
end

-- JSON helpers
local function jsonEncode(t) return HttpService:JSONEncode(t) end
local function jsonDecode(s)
    local ok, v = pcall(function() return HttpService:JSONDecode(s) end)
    if ok then return v end
    return nil, "decode_err"
end

-- status helper (st is a TextLabel)
local function setStatus(s)
    if st and typeof(st) == "Instance" and st:IsA("TextLabel") then
        pcall(function() st.Text = "Status: " .. tostring(s) end)
    end
end

-- =====================================
-- Provider / Key state
-- =====================================
local currentProvider = nil -- "chatgpt" or "gemini" or nil
local currentKey = nil
local currentModel = "gpt-4o-mini" -- default model for OpenAI responses; user can change later
local skipValidation = false -- when true we won't run expensive validation requests

-- helper to detect provider by key prefix
local function detectProviderByKey(k)
    if not k or k == "" then return nil end
    if tostring(k):lower():match("^sk%-proj") or tostring(k):lower():match("^sk%-") then
        return "chatgpt"
    elseif tostring(k):match("^AIza") then
        return "gemini"
    else
        return nil
    end
end

-- =====================================
-- Request queue (single-worker) to avoid spamming & handle 429/backoff
-- =====================================
local requestQueue = {}
local queueRunning = false
local defaultRetryDelay = 2

local function enqueueRequest(reqObj)
    -- reqObj = { url, method, headers, body, onSuccess(respBody, respObj), onError(errStr, respObj) }
    table.insert(requestQueue, reqObj)
    if not queueRunning then
        queueRunning = true
        task.spawn(function()
            local backoffBase = 1
            while #requestQueue > 0 do
                local r = table.remove(requestQueue, 1)
                if not r or not r.url then
                    -- skip
                else
                    local attempt = 0
                    local maxAttempts = r.maxAttempts or 5
                    local okResp
                    while attempt < maxAttempts do
                        attempt = attempt + 1
                        local req = {
                            Url = r.url,
                            Method = r.method or "POST",
                            Headers = r.headers or {},
                            Body = r.body or ""
                        }
                        local res, err = http_request_wrap(req)
                        if not res then
                            -- no http available
                            if r.onError then
                                pcall(r.onError, "no-http", err)
                            end
                            break
                        end

                        -- Normalize response fields for many executors
                        local status = res.StatusCode or res.status or res.code
                        local bodyText = res.Body or res.body or res.response or ""
                        local headers = {}
                        -- try to capture headers keys if available
                        if res.Headers then
                            headers = res.Headers
                        elseif res.headers then
                            headers = res.headers
                        end

                        if status == 200 or status == 201 or status == 202 then
                            -- success
                            if r.onSuccess then
                                pcall(r.onSuccess, bodyText, res)
                            end
                            okResp = true
                            break
                        elseif status == 429 then
                            -- rate limited: try to respect Retry-After header
                            local retryAfter = tonumber(headers["Retry-After"] or headers["retry-after"] or headers["Retry_after"]) or nil
                            local waitT = retryAfter or (defaultRetryDelay * backoffBase)
                            backoffBase = backoffBase * 2
                            setStatus("Rate-limited. Retry in " .. tostring(math.ceil(waitT)) .. "s")
                            task.wait(waitT)
                            -- continue attempt
                        else
                            -- other HTTP errors -> pass to onError and break
                            if r.onError then
                                pcall(r.onError, tostring(status) .. " - " .. tostring(bodyText), res)
                            end
                            okResp = false
                            break
                        end
                    end -- attempts
                    -- small sleep between queued requests
                    task.wait(0.3)
                end
            end
            queueRunning = false
        end)
    end
end

-- =====================================
-- Endpoints builders
-- =====================================
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
                -- Minimal request body for Gemini-like endpoint
                return jsonEncode({
                    prompt = {
                        text = prompt
                    }
                })
            end,
            parseResult = function(bodyText)
                local d = jsonDecode(bodyText)
                if not d then return nil end
                -- try to find text in common shapes
                if d.candidates and d.candidates[1] and d.candidates[1].content and d.candidates[1].content.parts and d.candidates[1].content.parts[1] then
                    return d.candidates[1].content.parts[1].text
                elseif d.outputText then
                    return d.outputText
                end
                return nil
            end
        }
    else
        -- default OpenAI Responses API (Responses)
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
                return jsonEncode({
                    model = m,
                    input = prompt
                })
            end,
            parseResult = function(bodyText)
                local d = jsonDecode(bodyText)
                if not d then return nil end
                -- try to extract 'output' / 'content' shapes
                if d.output and type(d.output) == "table" and d.output[1] and d.output[1].content then
                    for _, item in ipairs(d.output[1].content) do
                        if item.type == "output_text" and item.text then
                            return item.text
                        end
                    end
                end
                if d.results and d.results[1] and d.results[1].output and d.results[1].output[1] and d.results[1].output[1].content then
                    -- older shape
                    local parts = d.results[1].output[1].content
                    for _,p in ipairs(parts) do
                        if p.type == "output_text" and p.text then
                            return p.text
                        end
                    end
                end
                -- fallback: try common candidate
                if d.choices and d.choices[1] and d.choices[1].message and d.choices[1].message.content then
                    return d.choices[1].message.content
                end
                return nil
            end
        }
    end
end

-- =====================================
-- AI Sending logic
-- =====================================
local function sendToAI(prompt, onResult, onError)
    if not currentProvider or not currentKey then
        if onError then pcall(onError, "no-key") end
        return
    end
    local ep = endpointsFor(currentProvider)
    local url = ep.url
    local headers = ep.makeHeaders(currentKey)
    local body = ep.makeBody(prompt, currentModel)

    enqueueRequest({
        url = url,
        method = "POST",
        headers = headers,
        body = body,
        onSuccess = function(bodyText, resp)
            setStatus("Connected")
            local txtOut = nil
            pcall(function()
                txtOut = ep.parseResult(bodyText)
            end)
            if not txtOut or txtOut == "" then
                -- fallback to raw body
                txtOut = bodyText or "(no response text)"
            end
            if onResult then pcall(onResult, txtOut) end
        end,
        onError = function(err, resp)
            if tostring(err):match("429") or tostring(err):lower():match("rate") then
                setStatus("Rate-limited. Retry soon")
            else
                setStatus("Invalid key or HTTP error")
            end
            if onError then pcall(onError, err) end
        end
    })
end

-- quick test ping (used by /addapi when confirm = yes). This is lightweight: single small request.
local function quickValidateKey(provider, key, callback)
    -- if skipValidation true -> don't actually call; just callback(true)
    if skipValidation then
        callback(true, "skipped")
        return
    end
    local ep = endpointsFor(provider)
    local url = ep.url
    local headers = ep.makeHeaders(key)
    local body = ep.makeBody("ping")
    enqueueRequest({
        url = url,
        method = "POST",
        headers = headers,
        body = body,
        onSuccess = function(bodyText, resp)
            callback(true, bodyText)
        end,
        onError = function(err, resp)
            callback(false, tostring(err))
        end
    })
end

-- =====================================
-- UI connected send flow
-- =====================================
local function doSendFromUI(rawMessage)
    local message = tostring(rawMessage or "")
    message = message:gsub("^%s+", ""):gsub("%s+$", "")
    if message == "" then return end

    -- commands start with '/'
    if message:sub(1,1) == "/" then
        -- handle inline simple commands here, or dispatch to command system
        -- We'll add minimal handling for /help & /cleartext here; longer commands below
        local cmd = message:match("^/([^%s]+)")
        if cmd and cmd:lower() == "help" then
            txt(user.Sys, "Available commands: /help /cal /cleartext /addapi /unsaveapi /loadstring /script /owine", 255,90,0)
            return
        elseif cmd and (cmd:lower() == "cleartext" or cmd:lower() == "clearchat") then
            for _,v in ipairs(si:GetChildren()) do
                if v:IsA("TextLabel") then v:Destroy() end
            end
            txt(user.Suc, "Chat cleared", 0,255,0)
            return
        end
        -- other commands are handled by the commands block provided later
    end

    -- show user message
    txt(user.plr, message, 255,255,255)

    -- If no AI connected, show placeholder
    if not currentProvider or not currentKey then
        txt(user.chat, "(AI not connected)", 85,255,255)
        setStatus("No key")
        return
    end

    -- show connecting status
    setStatus("Connecting API [" .. tostring(currentProvider) .. "]")
    -- call AI
    sendToAI(message, function(result)
        -- display AI result
        txt(user.chat, tostring(result), 85,255,255)
    end, function(err)
        txt(user.Error, "AI request failed: " .. tostring(err), 255,0,0)
    end)
end

-- Connect UI send
if se and se.MouseButton1Click then
    se.MouseButton1Click:Connect(function()
        local m = ch.Text or ""
        doSendFromUI(m)
        -- clear input after send
        pcall(function() ch.Text = "" end)
    end)
end
if ch and ch.FocusLost then
    ch.FocusLost:Connect(function(enter)
        if enter then
            local m = ch.Text or ""
            doSendFromUI(m)
            pcall(function() ch.Text = "" end)
        end
    end)
end

-- =====================================
-- Commands implementation (extended)
-- =====================================
local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$","")) end
local function splitWords(s)
    local t = {}
    for w in s:gmatch("%S+") do table.insert(t,w) end
    return t
end

local function safeCalculate(expr)
    -- very basic: allow digits, operators, parentheses, ^, %, ., spaces, math functions
    -- replace ^ with ^ handled by loadstring (Lua uses ^ for bitwise in some versions, so be cautious)
    local safe = expr:match("^[%d%p%sa-zA-Z%%%^%*%/%+%-%(%)]+$")
    if not safe then return nil, "contains invalid chars" end
    local ok, f = pcall(function() return loadstring("return " .. expr) end)
    if not ok or not f then return nil, "invalid expression" end
    local ok2, res = pcall(f)
    if not ok2 then return nil, tostring(res) end
    return res
end

-- top-level commands table
local Commands = {}

-- /addapi [name] [key] [confirm?]
Commands.addapi = function(args)
    args = trim(args or "")
    local parts = {}
    for w in args:gmatch("%S+") do table.insert(parts,w) end
    local aiName = parts[1] and parts[1]:lower() or nil
    local key = parts[2]
    local ack = parts[3] and parts[3]:lower() or "no"

    if not aiName or not key then
        txt(user.Error, "Usage: /addapi [gemini|chatgpt] [API_KEY] [yes/no]", 255,0,0)
        return
    end

    local prov = aiName
    if prov ~= "gemini" and prov ~= "chatgpt" then
        txt(user.Error, "Invalid provider. Use 'gemini' or 'chatgpt'", 255,0,0)
        return
    end

    txt(user.Sys, "API detected for " .. prov .. " (confirm="..ack..")", 255,90,0)
    setStatus("Select " .. prov)

    if ack == "yes" then
        -- optionally validate (quick)
        setStatus("Validating key...")
        quickValidateKey(prov, key, function(ok, info)
            if ok then
                currentProvider = prov
                currentKey = key
                setStatus("Connected")
                txt(user.Suc, prov .. " connected", 0,255,0)
            else
                -- still allow but mark invalid
                currentProvider = prov
                currentKey = key
                setStatus("Invalid key (but saved)")
                txt(user.Warn, "Key validation failed: " .. tostring(info), 255,200,0)
            end
        end)
    else
        -- store without validation
        currentProvider = prov
        currentKey = key
        setStatus("Selected " .. prov .. " (unsaved validation)")
        txt(user.Info, prov .. " selected (validation skipped)", 0,170,255)
    end
end

-- /unsaveapi
Commands.unsaveapi = function(args)
    currentProvider = nil
    currentKey = nil
    setStatus("Unsave key")
    txt(user.Sys, "API disabled", 255, 90, 0)
end

-- /cal or /calculate
Commands.cal = function(args)
    local expr = trim(args or "")
    if expr == "" then
        txt(user.Error, "Usage: /cal [expression]", 255,0,0)
        return
    end
    local res, err = safeCalculate(expr)
    if not res then
        txt(user.Error, "Calc error: " .. tostring(err), 255,0,0)
    else
        txt(user.Suc, "Result = " .. tostring(res), 0,255,0)
    end
end
Commands.calculate = Commands.cal

-- /loadstring [URL]
Commands.loadstring = function(args)
    local url = trim(args or "")
    if url == "" then
        txt(user.Error, "Usage: /loadstring [URL]", 255,0,0)
        return
    end
    txt(user.Sys, "Loading script from URL...", 255,90,0)
    local ok, result = pcall(function()
        local bodyReq = { Url = url, Method = "GET" }
        local resp, err = http_request_wrap(bodyReq)
        if not resp then error("http fail: "..tostring(err)) end
        local code = resp.Body or resp.body or ""
        local fn = loadstring(code)
        if not fn then error("compile fail") end
        return fn()
    end)
    if ok then
        txt(user.Suc, "loadstring executed successfully", 0,255,0)
    else
        txt(user.Error, "loadstring failed: " .. tostring(result), 255,0,0)
    end
end

-- /script [[CODE]]
Commands.script = function(args)
    local code = trim(args or "")
    code = code:gsub("^%[%[", ""):gsub("%]%]$", "")
    if code == "" then
        txt(user.Error, "Usage: /script [[CODE]]", 255,0,0)
        return
    end
    txt(user.Sys, "Executing script...", 255,90,0)
    local fn, err = loadstring(code)
    if not fn then
        txt(user.Error, "Compile error: " .. tostring(err), 255,0,0)
        return
    end
    local ok, runtimeErr = pcall(fn)
    if ok then
        txt(user.Suc, "Script executed successfully", 0,255,0)
    else
        txt(user.Error, "Runtime error: " .. tostring(runtimeErr), 255,0,0)
    end
end

-- /owine or /openwebsiteinexperience [url]
Commands.owine = function(args)
    local url = trim(args or "")
    if url == "" then
        txt(user.Error, "Usage: /owine [URL]", 255,0,0)
        return
    end
    txt(user.Sys, "Opening website...", 255,90,0)
    local ok, e = pcall(function()
        -- Try StarterGui:SetCore to open in experience (may be restricted)
        if StarterGui and StarterGui.SetCore then
            pcall(function() StarterGui:SetCore("OpenBrowserWindow", url) end)
        else
            error("Open not supported")
        end
    end)
    if ok then
        txt(user.Suc, "Website opened (if allowed by client)", 0,255,0)
    else
        txt(user.Error, "Cannot open website: " .. tostring(e), 255,0,0)
    end
end

-- mapping short forms
Commands.calculator = Commands.cal
Commands.load = Commands.loadstring

-- dispatcher for messages typed starting with '/'
local function handleSlashCommand(text)
    local cmd, args = text:match("^/([^%s]+)%s*(.*)$")
    if not cmd then return false end
    cmd = cmd:lower()
    if Commands[cmd] then
        pcall(function() Commands[cmd](args) end)
        return true
    else
        txt(user.Warn, "Unknown command: /" .. tostring(cmd), 255,255,0)
        return false
    end
end

-- =====================================
-- Hook message entry to command system
-- (if user types "/...", it'll run the handlers above)
-- =====================================
-- The chat send earlier already calls doSendFromUI(), but we must route slash-commands to handleSlashCommand
-- So override doSendFromUI small: (we'll detect slash at top)
-- The doSendFromUI already shows user text — but prefer to run commands before sending to AI
local origDoSend = doSendFromUI
doSendFromUI = function(rawMessage)
    local message = tostring(rawMessage or "")
    message = message:gsub("^%s+", ""):gsub("%s+$", "")
    if message == "" then return end
    if message:sub(1,1) == "/" then
        local handled = false
        pcall(function() handled = handleSlashCommand(message) end)
        if not handled then
            txt(user.Error, "Unknown or failed command. Type /help", 255,0,0)
        end
        return
    end
    -- otherwise fallback to normal flow
    origDoSend(rawMessage)
end

-- =====================================
-- End
-- =====================================
txt(user.Sys, "Command system loaded.", 255, 90, 0)
setStatus("No key")
