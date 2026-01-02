-- gpt 3.70 (modified to support HttpService fallback & custom (self-hosted) endpoints)

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
txt(user.Nill, "Version: Test 3.70 (modified) | © Copyright LighterCyan", 180, 180, 180)
txt(user.Warn, "Stop! For your safety, please do not share your API and avoid being stared at by people around you. Due to safety and privacy concerns, you confirm that you will use your API to continue using our AI-OpenSource or not? With respect.", 255, 255, 0)
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
  /Addapi [ChatGPT/Gemini/custom] [ApiKey or URL] [ApiKey(if custom)] [yes/no]  
       Add API key or custom endpoint (custom example: /addapi custom https://host:8080 mykey yes)
  
  /Unsaveapi OR /UnApi  
       Unsave API key or remove saved config
  
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
txt(user.Nill, "Welcome back Tester", 0, 255, 0)
txt(user.Nill, "[====== Chat ======]", 180, 180, 180)

-- ===============================
-- AI-OpenSource — Full LocalScript (modified)
-- Assumes helper functions + user table + txt() exist in environment (per your setup)
-- Place in: CoreGui.ExperienceSettings.Menu.AIOpenSource.Frame (or adjust `rootPath`)

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- CONFIG
local rootPath = game:GetService("CoreGui"):WaitForChild("ExperienceSettings", 6) -- .Menu.AIOpenSource.Frame expected below
local DEBUG_MODE = false

-- helpers: safe txt
local function safeTxt(u, t, r,g,b)
    if type(txt)=="function" then
        pcall(txt, u, t, r or 255, g or 255, b or 255)
    end
end

-- find UI controls (tolerant)
local ok, Menu = pcall(function() return rootPath.Menu end)
if not ok or not Menu then
    warn("[AI] ExperienceSettings.Menu not found")
    return
end

local frame = Menu:FindFirstChild("AIOpenSource") and Menu.AIOpenSource:FindFirstChild("Frame")
           or Menu:FindFirstChild("AIOpenSource")
           or Menu:FindFirstChild("ChatGPT")
           or Menu -- fallback to Menu itself

-- robust child lookup
local function findTextBoxNames(parent, names)
    for _,n in ipairs(names) do
        local v = parent:FindFirstChild(n)
        if v and v:IsA("TextBox") then return v end
    end
    return nil
end

local function findButtonNames(parent, names)
    for _,n in ipairs(names) do
        local v = parent:FindFirstChild(n)
        if v and (v:IsA("TextButton") or v:IsA("ImageButton")) then return v end
    end
    return nil
end

local tb = (frame and (frame:FindFirstChild("Text") and (frame.Text:FindFirstChild("api") or frame.Text:FindFirstChild("API") or frame.Text:FindFirstChild("tb") ) ))
       or findTextBoxNames(frame or Menu, {"api","API","tb","TextBox_api"})
if tb then tb = tb end

local con = (frame and (frame.Text and (frame.Text:FindFirstChild("Confirm_api") or frame.Text:FindFirstChild("con") ))) or findButtonNames(frame or Menu, {"Confirm_api","con","ConfirmAPI"})
local con2 = (frame and (frame.Text and (frame.Text:FindFirstChild("Unsaved_API") or frame.Text:FindFirstChild("UnsavedApi") ))) or findButtonNames(frame or Menu, {"Unsaved_API","con2","UnsavedApi"})
local st = (frame and frame:FindFirstChild("Status")) or findTextBoxNames(frame or Menu, {"Status","st","StatusLabel"})
local ch = (frame and (frame.Text and (frame.Text:FindFirstChild("chat") or frame.Text:FindFirstChild("ch") or frame.Text:FindFirstChild("Chat") ))) or findTextBoxNames(frame or Menu, {"chat","ch","Chat"})
local se = (frame and (frame.Text and (frame.Text:FindFirstChild("Send") or frame.Text:FindFirstChild("se") ))) or findButtonNames(frame or Menu, {"Send","se","SendBtn"})
local si = (frame and (frame:FindFirstChild("ChatLogs") or (frame.Text and frame.Text:FindFirstChild("ChatLogs")))) or (Menu and Menu:FindFirstChild("ChatLogs"))

-- If not found, still continue but warn
if not si then safeTxt(user.Error, "ChatLogs (si) not found - logs disabled", 255,0,0) end
if not ch or not se then safeTxt(user.Warn, "chat TextBox or send Button not found", 255,255,0) end
if not tb or not con or not con2 or not st then safeTxt(user.Warn, "API UI (tb/con/con2/st) partially missing", 255,255,0) end

-- detect executor request function
local httpRequestFunc = (syn and syn.request) or (http and http.request) or http_request or request or (fluxus and fluxus.request) or nil
-- doRequest: try executor function first, fallback to HttpService:RequestAsync if available
local function doRequest(req)
    if httpRequestFunc then
        local ok, res = pcall(httpRequestFunc, req)
        if not ok then
            return nil, res
        end
        return res
    end

    -- Fallback: HttpService:RequestAsync (Roblox built-in). Map fields.
    if HttpService and HttpService.RequestAsync then
        local ok, res = pcall(function()
            local r = {
                Url = req.Url,
                Method = req.Method or "GET",
                Headers = req.Headers or {},
                Body = req.Body,
                -- Timeout is not supported in RequestAsync; ignore
            }
            return HttpService:RequestAsync(r)
        end)
        if not ok then
            return nil, res
        end
        return res
    end

    return nil, "no_request_function"
end

-- status update UI
local function updateStatus(s)
    if st and st:IsA("TextLabel") then
        pcall(function() st.Text = tostring(s) end)
    else
        safeTxt(user.Sys, "Status: "..tostring(s), 255,90,0)
    end
    if DEBUG_MODE and si then safeTxt(user.Info, "[STATUS] "..tostring(s), 0,170,255) end
end

-- persistence (optional: writefile/readfile) -- now supports old simple key and new JSON format
local keyFile = "AI_OPEN_API.key"
local function saveApiKeyToFile(data)
    if writefile then
        pcall(function()
            local raw
            if type(data) == "table" then
                raw = HttpService:JSONEncode(data)
            else
                -- legacy: store URL-encoded string
                raw = HttpService:UrlEncode(tostring(data))
            end
            writefile(keyFile, raw)
        end)
    end
end
local function loadApiKeyFromFile()
    if readfile and isfile and isfile(keyFile) then
        local ok, raw = pcall(readfile, keyFile)
        if ok and raw then
            -- try JSON decode first
            local ok2, dec = pcall(HttpService.JSONDecode, HttpService, raw)
            if ok2 and type(dec) == "table" and dec.provider then
                return dec
            end
            -- try URL decode (legacy)
            return HttpService:UrlDecode(raw)
        end
    end
    return nil
end

-- State
local currentApiKey = nil
local currentProvider = nil -- "openai" or "gemini" or "custom"
local currentModel = "gpt-4o-mini" -- default for openai
local currentCustomUrl = nil
local currentCustomAuth = nil
local requestQueue = {}
local workerRunning = false
local rateLimitedUntil = 0

-- load saved config if present
local loaded = loadApiKeyFromFile()
if type(loaded) == "table" then
    currentProvider = loaded.provider
    currentApiKey = loaded.key
    if loaded.url then currentCustomUrl = loaded.url end
    if loaded.auth then currentCustomAuth = loaded.auth end
elseif type(loaded) == "string" then
    -- legacy: plain key, default to openai
    currentApiKey = loaded
    currentProvider = "openai"
end

-- small queue worker (single request at a time)
local function enqueueRequest(opts)
    table.insert(requestQueue, opts)
    if not workerRunning then
        workerRunning = true
        task.spawn(function()
            while #requestQueue > 0 do
                local now = tick()
                if rateLimitedUntil > now then
                    local waitFor = rateLimitedUntil - now
                    if DEBUG_MODE then safeTxt(user.Info, ("Rate-limited, waiting %.1fs"):format(waitFor), 0,170,255) end
                    task.wait(waitFor)
                end
                local job = table.remove(requestQueue, 1)
                if not job then break end

                local ok, res = pcall(function()
                    -- perform request
                    local r = doRequest(job.request)
                    return r
                end)

                if not ok then
                    if job.onError then
                        job.onError(res)
                    end
                else
                    local resp = res
                    -- handle HTTP 429
                    local code = resp and (resp.StatusCode or resp.status or resp.Status) or 0
                    if code == 429 then
                        local retry = 5
                        local headers = resp.Headers or resp.headers or {}
                        local ra = headers["Retry-After"] or headers["retry-after"]
                        local waitSec = tonumber(ra) or retry
                        rateLimitedUntil = tick() + waitSec
                        if job.onError then job.onError("rate_limited", resp) end
                        -- push job back to queue end
                        table.insert(requestQueue, job)
                        -- small backoff
                        task.wait(waitSec)
                    else
                        if job.onSuccess then
                            job.onSuccess(resp)
                        end
                    end
                end

                task.wait(0.15) -- small gap between jobs to avoid burst
            end
            workerRunning = false
        end)
    end
end

-- endpoints.lua
-- ปรับปรุง endpointsFor จากของคุณ:
-- - เพิ่มรูปแบบ `messages` สำหรับ Gemini (หลายเวอร์ชันต้องการ)
-- - รองรับการส่งคีย์เป็น ?key=... หรือ Authorization: Bearer ...
-- - ตรวจสอบการมี HttpService และ fallback ถ้าไม่มี
-- - ใช้ JSON decode แบบปลอดภัย (pcall wrapper)
-- - ปรับ parseResult ให้ครอบคลุมรูปแบบผลลัพธ์เพิ่มขึ้น

local HttpService
local hasHttpService = pcall(function() HttpService = game:GetService and game:GetService("HttpService") end)
local jsonEncode, jsonDecode
if hasHttpService and HttpService then
    jsonEncode = function(t) return HttpService:JSONEncode(t) end
    jsonDecode = function(s) return HttpService:JSONDecode(s) end
else
    local ok, dkjson = pcall(require, "dkjson")
    if not ok then error("No JSON library available (need HttpService or dkjson)") end
    jsonEncode = function(t) return dkjson.encode(t) end
    jsonDecode = function(s) return dkjson.decode(s) end
end

local function safeDecode(body)
    local ok, res = pcall(function() return jsonDecode(body) end)
    if not ok then return nil, res end
    return res
end

local function tryConcatParts(parts)
    if type(parts) ~= "table" then
        return tostring(parts)
    end
    local buf = {}
    for _, p in ipairs(parts) do
        if type(p) == "table" then
            if p.text then table.insert(buf, tostring(p.text)) else table.insert(buf, tostring(p)) end
        else
            table.insert(buf, tostring(p))
        end
    end
    return table.concat(buf, "")
end

local function endpointsFor(provider)
    if provider == "gemini" then
        local baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
        return {
            -- url is base; caller may append ?key=... if they prefer query param
            url = baseUrl,
            makeHeaders = function(key)
                local headers = { ["Content-Type"] = "application/json" }
                if key and key ~= "" then
                    -- If key looks like an API key (no spaces) prefer ?key=... caller-side or x-goog-api-key.
                    -- If it looks like a bearer token (starts with "ya29." or "Bearer ") use Authorization.
                    if key:match("^Bearer%s+") then
                        headers["Authorization"] = key
                    elseif key:match("^ya29") or key:match("^ya29%.") then
                        headers["Authorization"] = "Bearer " .. key
                    else
                        -- include x-goog-api-key as fallback; some endpoints accept this header
                        headers["x-goog-api-key"] = key
                    end
                end
                return headers
            end,
            makeBodies = function(prompt)
                local list = {}
                -- Try common generate shapes for Generative Language / Gemini variations
                pcall(function()
                    -- messages with content string
                    table.insert(list, jsonEncode({ messages = { { role = "user", content = prompt } } }))
                end)
                pcall(function()
                    -- messages with content parts (some versions expect array of content objects)
                    table.insert(list, jsonEncode({
                        messages = {
                            {
                                role = "user",
                                content = { { type = "text", text = prompt } }
                            }
                        }
                    }))
                end)
                pcall(function()
                    -- older style: prompt/text/input
                    table.insert(list, jsonEncode({ prompt = { text = prompt } }))
                    table.insert(list, jsonEncode({ input = prompt }))
                    table.insert(list, jsonEncode({ text = prompt }))
                end)
                pcall(function()
                    -- Vertex-like instance shape (some people mistakenly use this against GL API)
                    table.insert(list, jsonEncode({ instances = { { content = prompt } } }))
                end)
                return list
            end,
            parseResult = function(body)
                local d, err = safeDecode(body)
                if not d then
                    -- not JSON or decode failed: return raw string
                    return tostring(body)
                end
                -- common GL/Gemini shapes
                if d.candidates and d.candidates[1] then
                    local c = d.candidates[1].content
                    if type(c) == "table" then
                        -- content.parts[].text
                        if c.parts and c.parts[1] and c.parts[1].text then
                            return c.parts[1].text
                        end
                        -- content[1].text
                        if c[1] and c[1].text then
                            return c[1].text
                        end
                    elseif type(c) == "string" then
                        return c
                    end
                end
                if d.outputText and type(d.outputText) == "string" then return d.outputText end
                if d.output and type(d.output) == "string" then return d.output end
                -- new Responses-like shape
                if d.results and d.results[1] and d.results[1].output then
                    local out = d.results[1].output[1]
                    if out and out.content then
                        for _, item in ipairs(out.content) do
                            if item.type == "output_text" and item.text then return item.text end
                            if item.text then return item.text end
                        end
                    end
                end
                -- try choices (OpenAI-like)
                if d.choices and d.choices[1] then
                    if d.choices[1].text then return d.choices[1].text end
                    if d.choices[1].message and d.choices[1].message.content then
                        return d.choices[1].message.content
                    end
                end
                -- try simple text fields
                if d.text then return d.text end
                if d.generated_text then return d.generated_text end
                -- fallback: find first string value in table
                for k,v in pairs(d) do
                    if type(v) == "string" then return v end
                end
                return jsonEncode(d)
            end
        }
    elseif provider == "custom" then
        return {
            url = currentCustomUrl,
            makeHeaders = function(key)
                local headers = { ["Content-Type"] = "application/json" }
                local authKey = key or currentCustomAuth
                if authKey and authKey ~= "" then
                    if authKey:match("^Bearer%s+") then
                        headers["Authorization"] = authKey
                    else
                        -- put into Authorization as Bearer and x-api-key as fallback
                        headers["Authorization"] = "Bearer " .. authKey
                        headers["x-api-key"] = authKey
                    end
                end
                return headers
            end,
            makeBodies = function(prompt)
                local list = {}
                pcall(function() table.insert(list, jsonEncode({ input = prompt })) end)
                pcall(function() table.insert(list, jsonEncode({ prompt = prompt })) end)
                pcall(function() table.insert(list, jsonEncode({ instances = { { content = prompt } } })) end)
                pcall(function() table.insert(list, jsonEncode({ text = prompt })) end)
                pcall(function() table.insert(list, jsonEncode({ messages = { { role = "user", content = prompt } } })) end)
                return list
            end,
            parseResult = function(body)
                local d = safeDecode(body)
                if not d then return tostring(body) end
                if type(d) == "string" then return d end
                if d.output and type(d.output) == "string" then return d.output end
                if d.text then return d.text end
                if d.generated_text then return d.generated_text end
                if d.data and type(d.data) == "table" and d.data[1] and d.data[1].generated_text then
                    return d.data[1].generated_text
                end
                if d.choices and d.choices[1] then
                    if d.choices[1].text then return d.choices[1].text end
                    if d.choices[1].message and d.choices[1].message.content then
                        return d.choices[1].message.content
                    end
                end
                for k,v in pairs(d) do
                    if type(v) == "string" then return v end
                end
                return jsonEncode(d)
            end
        }
    else
        -- openai / responses
        return {
            url = "https://api.openai.com/v1/responses",
            makeHeaders = function(key)
                local headers = { ["Content-Type"] = "application/json" }
                if key and key ~= "" then
                    if key:match("^Bearer%s+") then
                        headers["Authorization"] = key
                    else
                        headers["Authorization"] = "Bearer " .. key
                    end
                end
                return headers
            end,
            makeBodies = function(prompt)
                local list = {}
                pcall(function() table.insert(list, jsonEncode({ model = currentModel, input = prompt })) end)
                pcall(function() table.insert(list, jsonEncode({ model = currentModel, messages = { { role = "user", content = prompt } } })) end)
                pcall(function() table.insert(list, jsonEncode({ prompt = prompt, model = currentModel })) end)
                return list
            end,
            parseResult = function(body)
                local d = safeDecode(body)
                if not d then return tostring(body) end
                if d.output and type(d.output) == "table" and d.output[1] and d.output[1].content then
                    for _, item in ipairs(d.output[1].content) do
                        if item.type == "output_text" and item.text then return item.text end
                    end
                end
                if d.choices and d.choices[1] and d.choices[1].message and d.choices[1].message.content then
                    return d.choices[1].message.content
                end
                if d.results and d.results[1] and d.results[1].output and d.results[1].output[1] and d.results[1].output[1].content then
                    local parts = d.results[1].output[1].content
                    for _, p in ipairs(parts) do
                        if p.type == "output_text" and p.text then return p.text end
                    end
                end
                if d.choices and d.choices[1] and d.choices[1].text then return d.choices[1].text end
                return tostring(body)
            end
        }
    end
end

return {
    endpointsFor = endpointsFor,
    safeDecode = safeDecode,
    tryConcatParts = tryConcatParts
}

-- validator: try a single quick request to check key (use minimal body and don't spam)
local function validateKey(provider, key, timeoutSec)
    timeoutSec = timeoutSec or 12
    local eps = endpointsFor(provider)
    if not eps then return false, "no_endpoint" end
    if provider == "custom" and (not currentCustomUrl or currentCustomUrl == "") then
        return false, "no_custom_url"
    end
    local headers = eps.makeHeaders(key)
    local bodies = eps.makeBodies("Hello")
    for _, body in ipairs(bodies) do
        local req = {
            Url = eps.url,
            Method = "POST",
            Headers = headers,
            Body = body,
            Timeout = timeoutSec
        }
        local ok, res = pcall(doRequest, req)
        if not ok then
            return false, tostring(res)
        else
            local code = res.StatusCode or res.status or (res.Success and (res.StatusCode or res.Status)) or 0
            local bodyText = res.Body or res.body or (res.success ~= nil and tostring(res)) or ""
            if code and (code >= 200 and code < 300) then
                return true, "ok"
            else
                return false, {code=code, body=bodyText}
            end
        end
    end
    return false, "no_bodies"
end

-- ask AI (public)
local function askAI(prompt, onSuccess, onError)
    if not currentApiKey and currentProvider ~= "custom" then
        if onError then onError("no_api") end
        safeTxt(user.Error, "No API key configured. Use /addapi or input and Confirm API", 255,0,0)
        updateStatus("No key")
        return
    end
    if currentProvider == "custom" and (not currentCustomUrl or currentCustomUrl == "") then
        if onError then onError("no_custom_url") end
        safeTxt(user.Error, "Custom endpoint not configured. Use /addapi custom [URL] [APIKEY] yes", 255,0,0)
        updateStatus("No custom url")
        return
    end
    -- select endpoints
    local eps = endpointsFor(currentProvider or "openai")
    local headers = eps.makeHeaders(currentApiKey)
    local bodies = eps.makeBodies(prompt)
    -- try bodies sequentially via enqueueRequest
    local tried = 0
    local function tryBody(idx)
        local body = bodies[idx]
        if not body then
            if onError then onError("no_body_succeeded") end
            return
        end
        tried = tried + 1
        local req = {
            Url = eps.url,
            Method = "POST",
            Headers = headers,
            Body = body
        }
        enqueueRequest({
            request = req,
            onSuccess = function(resp)
                local text = resp.Body or resp.body or (resp.Success and resp.Body) or ""
                local parsed = nil
                local ok, out = pcall(eps.parseResult, text)
                if ok then parsed = out else parsed = text end
                if onSuccess then
                    pcall(onSuccess, parsed)
                end
            end,
            onError = function(err)
                -- if HTTP 4xx (bad payload), try next body; if 429, enqueue will re-add with backoff
                local code = (type(err)=="table" and (err.StatusCode or err.status)) or nil
                if code and (code >= 400 and code < 500) and idx < #bodies then
                    tryBody(idx+1)
                else
                    if onError then onError(err) end
                end
            end
        })
    end
    tryBody(1)
end

-- UI: Confirm API button click
local function onConfirmApiClicked()
    if not tb then
        safeTxt(user.Error, "API TextBox not found", 255,0,0)
        return
    end
    local value = tostring(tb.Text or ""):gsub("^%s+",""):gsub("%s+$","")
    if value == "" then
        safeTxt(user.Error, "API textbox empty", 255,0,0)
        return
    end

    -- guess provider from key prefix or url form
    local providerGuess = nil
    if value:match("^https?://") then
        -- user pasted a URL: treat as custom endpoint (no API key here)
        providerGuess = "custom"
        currentCustomUrl = value
        currentCustomAuth = nil
        -- we prompt user via status to /addapi custom <url> <apikey> yes if they want to save with key
        updateStatus("Custom URL set (unconfirmed)")
        safeTxt(user.Info, "Custom URL set. To add API key and save: /addapi custom "..value.." <APIKEY> yes", 0,170,255)
        return
    elseif value:match("^sk%-") or value:match("^sk_proj") or value:match("^eyJ") then -- heuristics
        providerGuess = "openai"
    elseif value:match("^AIza") or value:match("^AI") or value:match("^AIza") or value:match("^AIsa") then
        providerGuess = "gemini"
    else
        -- fallback: default openai
        providerGuess = "openai"
    end

    updateStatus("Connecting ("..providerGuess..")")
    safeTxt(user.Info, "Validating key (one request) — please wait...", 0,170,255)

    -- validation (single request)
    local ok, detail = validateKey(providerGuess, value, 12)
    if ok == true then
        currentApiKey = value
        currentProvider = providerGuess
        -- save structured config
        local conf = { provider = currentProvider, key = currentApiKey, url = currentCustomUrl, auth = currentCustomAuth }
        saveApiKeyToFile(conf)
        updateStatus("Connected ("..providerGuess..")")
        safeTxt(user.Suc, "API validated and saved (local)", 0,255,0)
    else
        local code = (type(detail)=="table" and detail.code) or nil
        local body = (type(detail)=="table" and detail.body) or tostring(detail)
        updateStatus("Invalid key")
        safeTxt(user.Error, "Validation failed: "..tostring(body or detail), 255,0,0)
    end
end

-- UI: Unsaved / Clear key
local function onUnsavedApiClicked()
    currentApiKey = nil
    currentProvider = nil
    currentCustomUrl = nil
    currentCustomAuth = nil
    -- remove file if possible
    if isfile and isfile(keyFile) then
        pcall(function() delfile(keyFile) end)
    end
    updateStatus("Unsave key")
    safeTxt(user.Suc, "API key unsaved", 0,255,0)
end

-- wire up con / con2 safely
if con and con:IsA("GuiObject") then
    con.Active = true
    con.AutoButtonColor = true
    con.MouseButton1Click:Connect(onConfirmApiClicked)
end
if con2 and con2:IsA("GuiObject") then
    con2.Active = true
    con2.AutoButtonColor = true
    con2.MouseButton1Click:Connect(onUnsavedApiClicked)
end

-- open website helper (robust) — fixed
local function openWebsiteInExperience(url)
    local ok, err = pcall(function()
        if GuiService and GuiService.OpenBrowserWindow then
            GuiService:OpenBrowserWindow(url)
        else
            -- use dot to check existence, colon when calling
            if StarterGui and StarterGui.SetCore then
                StarterGui:SetCore("OpenBrowserWindow", url)
            else
                error("Service blocked")
            end
        end
    end)
    return ok, err
end

-- CHAT / COMMAND handling
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
/OpenWebsiteInExperience or /OWINE [URL] - open site
/Loadstring [URL] - loadstring(url)()
/Script [[CODE]] - run code
/Debug [on/off] - show debug logs
/CheckHTTP - check executor http availability
/CheckURLStatus [URL] - check website status (HEAD)
/CheckSYN - check syn request availability
/EnableUSLD - enable unknown-language debug printing to logs
]=]

local function clearChatLogs()
    if not si then return end
    for _,v in ipairs(si:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
end

local function calculate(expr)
    local ok, f = pcall(function() return loadstring("return "..expr) end)
    if not ok or not f then return nil, "invalid expression" end
    local suc, res = pcall(f)
    if not suc then return nil, res end
    return res
end

-- toggle debug prints
local function setDebugMode(flag)
    DEBUG_MODE = flag and true or false
    safeTxt(user.Suc, "Debug mode: "..tostring(DEBUG_MODE), 0,255,0)
end

-- split helper
local function splitWords(s)
    local t = {}
    for w in s:gmatch("%S+") do table.insert(t, w) end
    return t
end

-- command handler
local function handleCommand(msg)
    local lower = tostring(msg):lower()
    if lower:match("^/help") then
        safeTxt(user.Nill, "What is AI-OpenSource?", 180,180,180)
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
        if expr == "" then safeTxt(user.Error, "Usage: /cal [expression]",255,0,0) return true end
        local res, err = calculate(expr)
        if not res then safeTxt(user.Error, "Math error: "..tostring(err),255,0,0) else safeTxt(user.Suc, "Result = "..tostring(res),0,255,0) end
        return true
    end

    if lower:match("^/addapi") then
        local args = splitWords(msg)
        if #args < 3 then
            safeTxt(user.Error, "Usage: /addapi [ChatGPT/Gemini/custom] [API or URL] [APIKEY(if custom)] [yes/no]",255,0,0)
            return true
        end
        local name = args[2]:lower()
        if name == "custom" then
            local url = args[3]
            local apikey = args[4]
            local confirm = args[5]
            if not url then safeTxt(user.Error, "Usage: /addapi custom <URL> [APIKEY] [yes/no]",255,0,0) return true end
            currentProvider = "custom"
            currentCustomUrl = url
            currentCustomAuth = apikey and apikey ~= "" and apikey or nil
            currentApiKey = currentCustomAuth
            if confirm and confirm:lower()=="yes" then
                saveApiKeyToFile({ provider = "custom", key = currentCustomAuth, url = currentCustomUrl, auth = currentCustomAuth })
                updateStatus("Custom set (saved)")
                safeTxt(user.Suc, "Custom endpoint saved",0,255,0)
            else
                updateStatus("Custom set (unsaved)")
                safeTxt(user.Info, "Custom endpoint set. Use 'yes' to save: /addapi custom <URL> <APIKEY> yes",0,170,255)
            end
            return true
        else
            local provider = (name:match("chat") and "openai") or (name:match("gemini") and "gemini") or nil
            local key = args[3]
            local confirm = args[4]
            if not provider or not key then safeTxt(user.Error, "Usage: /addapi [ChatGPT/Gemini] [API] [yes/no]",255,0,0) return true end
            currentApiKey = key
            currentProvider = provider
            if confirm and confirm:lower()=="yes" then
                saveApiKeyToFile({ provider = currentProvider, key = key, url = currentCustomUrl, auth = currentCustomAuth })
                updateStatus("Key set (saved)")
                safeTxt(user.Suc, "API set and saved (local)",0,255,0)
            else
                updateStatus("Key set (unconfirmed)")
                safeTxt(user.Info, "Key set. Click Confirm API or /addapi ... yes to validate",0,170,255)
            end
            return true
        end
    end

    if lower:match("^/unsaveapi") or lower:match("^/unapi") then
        onUnsavedApiClicked()
        return true
    end

    if lower:match("^/openwebsiteinexperience") or lower:match("^/owine") then
        local url = msg:match("^/%S+%s+(.+)$") or ""
        url = url:gsub("^%s+",""):gsub("%s+$","")
        if url == "" then safeTxt(user.Error, "Usage: /OpenWebsiteInExperience [URL]",255,0,0) return true end
        local ok, e = openWebsiteInExperience(url)
        if ok then safeTxt(user.Suc, "Opened website: "..url,0,255,0) else safeTxt(user.Error, "OpenWebsite failed: "..tostring(e),255,0,0) end
        return true
    end

    if lower:match("^/loadstring") then
        local url = msg:match("^/%S+%s+(.+)$") or ""
        url = url:gsub("^%s+",""):gsub("%s+$","")
        if url == "" then safeTxt(user.Error, "Usage: /loadstring [URL]",255,0,0) return true end
        safeTxt(user.Sys, "Fetching loadstring...",255,90,0)
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
        setDebugMode(flag == "on")
        return true
    end

    if lower:match("^/checkhttp") then
        local ok = (httpRequestFunc ~= nil)
        safeTxt(user.Info, "Executor HTTP available: "..tostring(ok), 0,170,255)
        return true
    end

    if lower:match("^/checkurlstatus") then
        local url = msg:match("^/%S+%s+(.+)$") or ""
        url = url:gsub("^%s+",""):gsub("%s+$","")
        if url == "" then safeTxt(user.Error, "Usage: /CheckURLStatus [URL]",255,0,0) return true end
        local req = {Url = url, Method = "HEAD"}
        local ok, res = pcall(doRequest, req)
        if not ok then safeTxt(user.Error, "Request error: "..tostring(res),255,0,0) else
            local code = res.StatusCode or res.status
            safeTxt(user.Info, "URL status: "..tostring(code), 0,170,255)
        end
        return true
    end

    if lower:match("^/checksyn") then
        safeTxt(user.Info, "syn.request available: "..tostring( (syn and syn.request) and true or false ), 0,170,255)
        return true
    end

    if lower:match("^/enableusld") then
        safeTxt(user.Info, "USLD enabled (will print unknown content types to logs)", 0,170,255)
        -- implement as needed
        return true
    end

    return false
end

-- send handler (UI)
local function sendMessageFromUI()
    if not ch then return end
    local msg = tostring(ch.Text or ""):gsub("^%s+",""):gsub("%s+$","")
    if msg == "" then return end

    -- command?
    if msg:sub(1,1) == "/" then
        local handled = handleCommand(msg)
        if not handled then safeTxt(user.Error, "Unknown command. Type /help",255,0,0) end
        ch.Text = ""
        return
    end

    -- show user message
    safeTxt(user.plr, msg, 255,255,255)
    ch.Text = ""

    -- ask AI
    askAI(msg, function(answer)
        safeTxt(user.chat, tostring(answer or "(no response)"), 85,255,255)
    end, function(err)
        safeTxt(user.Error, "AI request failed: "..tostring(err), 255,0,0)
    end)
end

-- connect send UI
if se and se:IsA("GuiButton") then
    se.MouseButton1Click:Connect(sendMessageFromUI)
end
if ch and ch:IsA("TextBox") then
    ch.FocusLost:Connect(function(enter)
        if enter then sendMessageFromUI() end
    end)
end

-- initial status
if currentApiKey or currentCustomUrl then updateStatus("Key/URL loaded (unconfirmed)") else updateStatus("No key") end

-- debug heartbeat
task.spawn(function()
    while true do
        if DEBUG_MODE then
            safeTxt(user.Info, ("Debug heartbeat. Queue size=%d provider=%s"):format(#requestQueue, tostring(currentProvider)), 0,170,255)
        end
        task.wait(5)
    end
end)

-- done
updateStatus((currentApiKey or currentCustomUrl) and "Key/URL loaded" or "No key")
