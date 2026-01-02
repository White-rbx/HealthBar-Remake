-- gpt 3.681

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
txt(user.Nill, "Version: Test 3.681 | © Copyright LighterCyan", 180, 180, 180)
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
-- AI-OpenSource: UI glue + command handling + executor-HTTP AI caller
-- Put this after your UI instantiation. Requires:
--   txt(user, text, r,g,b)  -- provided by you
--   user table as in conversation
-- UI expected under: game:GetService("CoreGui").ExperienceSettings.Menu.AIOpenSource.Frame (tolerant search)

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")

-- find request function (executor friendly)
local requestFn =
    (syn and syn.request) or
    (http and http.request) or
    (fluxus and fluxus.request) or
    request or
    (function() return nil end)

-- tolerant UI root lookup
local function findRoot()
    local ok, root = pcall(function()
        return game:GetService("CoreGui"):WaitForChild("ExperienceSettings", 6).Menu:FindFirstChild("AIOpenSource") and
               game:GetService("CoreGui").ExperienceSettings.Menu.AIOpenSource.Frame
    end)
    if ok and root and root:IsA("Frame") then return root end
    -- fallback: try searching CoreGui for Frame named "AIOpenSource" or "AI-OpenSource" etc
    for _, obj in ipairs(game:GetService("CoreGui"):GetDescendants()) do
        if obj:IsA("Frame") and (obj.Name:lower():find("aio") or obj.Name:lower():find("open") or obj.Name:lower():find("chat")) then
            return obj
        end
    end
    return nil
end

local frame = findRoot()
if not frame then
    warn("[AI] UI root not found (AIOpenSource.Frame). Script will not run.")
    safeTxt = function() end
    return
end

-- tolerant child finders
local function findChildVariants(parent, names)
    for _, n in ipairs(names) do
        local v = parent:FindFirstChild(n)
        if v then return v end
    end
    return nil
end

local textFrame = frame:FindFirstChild("Text") or frame
local ch = findChildVariants(textFrame, {"chat","ch","Ch","Chat"})
local se = findChildVariants(textFrame, {"Send","se","send","SendBtn"})
local si = findChildVariants(frame, {"ChatLogs","ChatFrame","ChatFrameLogs"})
-- try deeper search if not found
if not si then
    for _, d in ipairs(frame:GetDescendants()) do
        if d:IsA("ScrollingFrame") and (d.Name:lower():find("chat") or d.Name:lower():find("log")) then
            si = d
            break
        end
    end
end

local con = findChildVariants(textFrame, {"Confirm_api","ConfirmAPI","Confirm","con"})
local con2 = findChildVariants(textFrame, {"Unsaved_API","UnsavedAPI","Unsaved","con2"})
local st = findChildVariants(textFrame, {"Status","status","St","State"})
local apiBox = findChildVariants(textFrame, {"api","API","APIKeyBox","APIKey"})

-- if some not found, try frame descendants
local function tryFindAny(nameList, predicate)
    for _, d in ipairs(frame:GetDescendants()) do
        if d:IsA("TextLabel") or d:IsA("TextBox") or d:IsA("TextButton") or d:IsA("ScrollingFrame") or d:IsA("Frame") then
            local nm = d.Name:lower()
            for _, wish in ipairs(nameList) do
                if nm == wish:lower() then
                    if not predicate or predicate(d) then
                        return d
                    end
                end
            end
        end
    end
    return nil
end

if not ch then ch = tryFindAny({"chat","ch","textbox","textbox1"}, function(d) return d:IsA("TextBox") end) end
if not se then se = tryFindAny({"send","submit","sendbtn","se"}, function(d) return d:IsA("TextButton") or d:IsA("TextLabel") or d:IsA("ImageButton") end) end
if not si then si = tryFindAny({"chatlogs","chatframe","logs"}, function(d) return d:IsA("ScrollingFrame") end) end
if not con then con = tryFindAny({"confirm_api","confirm_api","confirm_api_btn","confirm_api"}, nil) end
if not con2 then con2 = tryFindAny({"unsaved_api","unsaved_api","unsave_api"}, nil) end
if not st then st = tryFindAny({"status","Status","state"}, function(d) return d:IsA("TextLabel") end) end

-- enable interactions (fix buttons not clickable)
for _, btn in ipairs({con, con2, se}) do
    if btn and btn:IsA("TextButton") or (btn and btn:IsA("ImageButton")) then
        pcall(function()
            btn.Active = true
            btn.AutoButtonColor = true
            btn.ZIndex = 10
        end)
    end
end

-- safe txt wrapper (user-provided txt must exist)
local function safeTxt(u, t, r,g,b)
    if type(txt)=="function" then
        pcall(txt, u, t, r or 255, g or 255, b or 255)
    end
end

-- status updater
local function updateStatus(s)
    if st and st:IsA("TextLabel") then
        local ok, _ = pcall(function() st.Text = "Status: "..tostring(s) end)
        if not ok then safeTxt(user.Info, "Status: "..tostring(s), 180,180,180) end
    else
        safeTxt(user.Info, "Status: "..tostring(s), 180,180,180)
    end
end

-- persistence helpers
local keyFileName = "AI_OpenSource_key.txt"
local function saveApiKeyToFile(key)
    if writefile then
        pcall(function()
            writefile(keyFileName, HttpService:UrlEncode(key))
        end)
    end
end
local function loadApiKeyFromFile()
    if readfile and isfile and isfile(keyFileName) then
        local ok, raw = pcall(function() return readfile(keyFileName) end)
        if ok and raw then
            return HttpService:UrlDecode(raw)
        end
    end
    return nil
end

-- state
local currentProvider = nil      -- "openai" or "gemini"
local currentApiKey = nil
local currentModel = "gpt-4o-mini"
local DEBUG_MODE = false

-- rate limiting controls
local rateLimitedUntil = 0
local lastRequestAt = 0
local minRequestInterval = 1.0 -- seconds between requests (throttle)
local function isRateLimited()
    return tick() < (rateLimitedUntil or 0)
end

-- helper: simple request wrapper (executor)
local function doRequest(opts)
    if not requestFn or requestFn== (function() return nil end) then
        return false, "no_http_executor"
    end
    if isRateLimited() then
        return false, ("rate_limited_until_"..tostring(math.ceil(rateLimitedUntil - tick())))
    end
    local now = tick()
    if now - lastRequestAt < minRequestInterval then
        task.wait(minRequestInterval - (now - lastRequestAt))
    end
    lastRequestAt = tick()

    local ok, res = pcall(function()
        return requestFn(opts)
    end)
    if not ok then return false, res end
    return true, res
end

-- endpoint builders (simplified, tolerant)
local function endpointsFor(provider)
    if provider == "gemini" then
        return {
            url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
            makeHeaders = function(key)
                return { ["Content-Type"]="application/json", ["x-goog-api-key"]=key }
            end,
            makeBody = function(prompt)
                -- attempt minimal shapes; Gemini API variants exist => use a simple shape that often works for examples
                return HttpService:JSONEncode({
                    prompt = {
                        parts = {
                            { text = prompt }
                        }
                    }
                })
            end,
            parseResult = function(bodyText)
                local ok, d = pcall(HttpService.JSONDecode, HttpService, bodyText)
                if not ok or not d then return nil end
                if d.candidates and d.candidates[1] and d.candidates[1].content and d.candidates[1].content.parts and d.candidates[1].content.parts[1] then
                    return tostring(d.candidates[1].content.parts[1].text)
                end
                if d.outputText then return tostring(d.outputText) end
                return nil
            end
        }
    else
        -- default: OpenAI Responses
        return {
            url = "https://api.openai.com/v1/responses",
            makeHeaders = function(key)
                return { ["Content-Type"]="application/json", ["Authorization"]="Bearer "..key }
            end,
            makeBody = function(prompt, model)
                return HttpService:JSONEncode({ model = model or currentModel, input = prompt })
            end,
            parseResult = function(bodyText)
                local ok, d = pcall(HttpService.JSONDecode, HttpService, bodyText)
                if not ok or not d then return nil end
                -- Try several shapes
                if d.output and type(d.output)=="table" and d.output[1] and d.output[1].content then
                    for _, item in ipairs(d.output[1].content) do
                        if item.type=="output_text" and item.text then return tostring(item.text) end
                    end
                end
                if d.choices and d.choices[1] and d.choices[1].message and d.choices[1].message.content then
                    return tostring(d.choices[1].message.content)
                end
                if d.results and d.results[1] and d.results[1].output_text then return tostring(d.results[1].output_text) end
                return nil
            end
        }
    end
end

-- Try to (optionally) load saved api key at start
do
    local old = loadApiKeyFromFile()
    if old then
        currentApiKey = old
        -- heuristics: check prefix to choose provider
        if tostring(old):match("^sk%-") or tostring(old):match("^bearer") then
            currentProvider = "openai"
            updateStatus("Key loaded (OpenAI detected)")
        elseif tostring(old):match("^AIza") or tostring(old):match("^AIsa") then
            currentProvider = "gemini"
            updateStatus("Key loaded (Gemini detected)")
        else
            updateStatus("Key loaded")
        end
    end
end

-- save/unsave handlers
local function saveApiKey(key, provider)
    currentApiKey = key
    if provider then currentProvider = provider end
    pcall(saveApiKeyToFile, key)
    updateStatus("Key set (not validated)")
end

local function unsaveApiKey()
    currentApiKey = nil
    currentProvider = nil
    if writefile and isfile and isfile(keyFileName) then
        pcall(function() delfile(keyFileName) end)
    end
    updateStatus("No key")
    safeTxt(user.Suc, "API key unsaved", 0,255,0)
end

-- Validate key (slow, careful). Return true/false + message
local function validateKeyOnce(key, provider, timeoutSeconds)
    timeoutSeconds = timeoutSeconds or 12
    if not key or key=="" then return false, "no_key" end
    local endpoints = endpointsFor(provider or (key:match("^sk") and "openai" or "gemini"))
    local headers = endpoints.makeHeaders(key)
    local body = endpoints.makeBody("Hello")
    local ok, res = doRequest({ Url = endpoints.url, Method = "POST", Headers = headers, Body = body, Timeout = timeoutSeconds })
    if not ok then
        return false, tostring(res)
    end
    local status = res and (res.StatusCode or res.status or res.code) or nil
    if status == 401 or status == 403 or status == 400 then
        return false, ("HTTP "..tostring(status))
    end
    if status == 429 then
        local retryAfter = tonumber(res.Headers and (res.Headers["Retry-After"] or res.Headers["retry-after"]) or nil) or 30
        rateLimitedUntil = tick() + retryAfter
        return false, "rate_limited_"..tostring(retryAfter)
    end
    -- try parse minimal
    local parsed = endpoints.parseResult(res.Body or res.body or "")
    if parsed then return true, "ok" end
    -- otherwise accept if status in 200..299
    if tonumber(status) and tonumber(status) >= 200 and tonumber(status) < 300 then return true, "ok" end
    return false, ("unknown_response_"..tostring(status))
end

-- askAI: queue single request, parse and callback
local function askAI(prompt, onSuccess, onError, opts)
    opts = opts or {}
    if isRateLimited() then
        local waitSec = math.ceil(rateLimitedUntil - tick())
        if onError then onError("rate_limited: wait "..tostring(waitSec).."s") end
        updateStatus("Rate-limited. Retry in "..tostring(waitSec).."s")
        return
    end

    if not currentApiKey then
        if onError then onError("no_api_key") end
        updateStatus("No key")
        return
    end
    local provider = currentProvider or ((tostring(currentApiKey):match("^sk%-") and "openai") or "gemini")
    local ep = endpointsFor(provider)
    local headers = ep.makeHeaders(currentApiKey)
    local body = ep.makeBody(prompt, currentModel)

    -- perform request
    updateStatus("Connecting API ("..tostring(provider)..")")
    local ok, res = doRequest({ Url = ep.url, Method = "POST", Headers = headers, Body = body })
    if not ok then
        -- fail early
        if string.find(tostring(res):lower(),"rate") or tostring(res):match("429") then
            local retry = 30
            rateLimitedUntil = tick() + retry
            updateStatus("Rate-limited. Retry in "..tostring(retry).."s")
            if onError then onError("rate_limited") end
            return
        end
        if onError then onError(tostring(res)) end
        updateStatus("Request failed")
        return
    end

    local statusCode = tonumber(res.StatusCode or res.status or res.code) or nil
    if statusCode == 429 then
        local retry = tonumber(res.Headers and (res.Headers["Retry-After"] or res.Headers["retry-after"]) or nil) or 30
        rateLimitedUntil = tick() + retry
        updateStatus("Rate-limited. Retry in "..tostring(retry).."s")
        if onError then onError("rate_limited") end
        return
    end

    local bodyText = res.Body or res.body or ""
    local parsed = ep.parseResult(bodyText)
    if not parsed then
        -- fallback attempt: attempt to decode then find common fields
        local okd, dec = pcall(HttpService.JSONDecode, HttpService, bodyText)
        if okd and dec then
            -- try a couple of shapes
            if dec and dec.choices and dec.choices[1] and dec.choices[1].message and dec.choices[1].message.content then
                parsed = dec.choices[1].message.content
            elseif dec and dec.output and dec.output[1] and dec.output[1].content then
                for _, item in ipairs(dec.output[1].content) do
                    if item.type=="output_text" and item.text then parsed = item.text; break end
                end
            end
        end
    end

    if not parsed then
        if onError then onError("no_parse") end
        updateStatus("Connected (no text)")
        return
    end

    -- success
    updateStatus("Connected (success)")
    if onSuccess then onSuccess(tostring(parsed)) end
end

-- UI: confirm / unsave buttons
if con and con:IsA("TextButton") then
    con.MouseButton1Click:Connect(function()
        if not currentApiKey then
            local apiVal = apiBox and apiBox.Text or ""
            if apiVal and apiVal ~= "" then
                currentApiKey = apiVal
            else
                safeTxt(user.Error, "No API in box to confirm", 255,0,0)
                return
            end
        end
        updateStatus("Validating key...")
        safeTxt(user.Info, "Validating key (this may take ~10s)...", 0,170,255)
        -- slow validation (non-blocking)
        task.spawn(function()
            local ok, msg = validateKeyOnce(currentApiKey, currentProvider or (currentApiKey:match("^sk%-") and "openai" or "gemini"), 14)
            if ok then
                saveApiKey(currentApiKey, currentProvider)
                updateStatus("Connected")
                safeTxt(user.Suc, "Key validated and saved", 0,255,0)
            else
                if tostring(msg):match("rate_limited") then
                    safeTxt(user.Warn, "Rate-limited during validation. Retry later.", 255,200,0)
                    updateStatus("Rate-limited. Retry soon.")
                else
                    safeTxt(user.Error, "Key invalid: "..tostring(msg), 255,0,0)
                    updateStatus("Invalid key")
                end
            end
        end)
    end)
end

if con2 and con2:IsA("TextButton") then
    con2.MouseButton1Click:Connect(function()
        unsaveApiKey()
    end)
end

-- command handling (your version, integrated)
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
    local ok, f = pcall(function() return loadstring("return "..expr) end)
    if not ok or not f then return nil, "invalid" end
    local suc, res = pcall(f)
    if not suc then return nil, res end
    return res
end

-- helper: open website
local function openWebsiteInExperience(url)
    local ok, err = pcall(function()
        if GuiService and GuiService.OpenBrowserWindow then
            GuiService:OpenBrowserWindow(url)
        else
            if StarterGui and StarterGui:SetCore then
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
        else safeTxt(user.Suc, "Result = "..tostring(res), 0,255,0) end
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
        currentApiKey = key
        currentProvider = provider
        if confirm and confirm:lower()=="yes" then
            -- validate now (async)
            updateStatus("Validating...")
            task.spawn(function()
                local ok, msg = validateKeyOnce(currentApiKey, currentProvider, 14)
                if ok then
                    saveApiKey(currentApiKey, currentProvider)
                    updateStatus("Connected")
                    safeTxt(user.Suc, "Key validated and saved", 0,255,0)
                else
                    safeTxt(user.Error, "Validation failed: "..tostring(msg), 255,0,0)
                    updateStatus("Invalid key")
                end
            end)
        else
            updateStatus("Key set (unconfirmed)")
            safeTxt(user.Info, "Key set. Use Confirm API button or /addapi ... yes to validate", 0,170,255)
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

-- send UI link
local function sendMessageFromUI()
    local msg = (ch and tostring(ch.Text or "") or "")
    msg = msg:gsub("^%s+",""):gsub("%s+$","")
    if msg == "" then return end

    if msg:sub(1,1) == "/" then
        local handled = false
        local ok,err = pcall(function() handled = handleCommand(msg) end)
        if not ok then
            safeTxt(user.Error, "Command handler error: "..tostring(err), 255,0,0)
        elseif not handled then
            safeTxt(user.Warn, "Unknown command. Type /help", 255,255,0)
        end
        if ch then ch.Text = "" end
        return
    end

    -- normal conversation
    safeTxt(user.plr, msg, 255,255,255)
    -- send to AI
    askAI(msg, function(answer)
        safeTxt(user.chat, tostring(answer), 85,255,255)
    end, function(err)
        safeTxt(user.Error, "AI request failed: "..tostring(err), 255,0,0)
    end)

    if ch then ch.Text = "" end
end

-- wire send button and enter key
if se and (se:IsA("TextButton") or se:IsA("ImageButton")) then
    se.MouseButton1Click:Connect(sendMessageFromUI)
end
if ch and ch:IsA("TextBox") then
    ch.FocusLost:Connect(function(enter)
        if enter then sendMessageFromUI() end
    end)
end

-- periodic status updater when rate-limited
task.spawn(function()
    while true do
        if isRateLimited() then
            local left = math.max(0, math.ceil(rateLimitedUntil - tick()))
            updateStatus("Rate-limited. Retry in "..tostring(left).."s")
        end
        task.wait(1)
    end
end)

-- debug heartbeat
task.spawn(function()
    while true do
        if DEBUG_MODE then
            safeTxt(user.Info, string.format("DEBUG: provider=%s key=%s rateLimited=%s", tostring(currentProvider), (currentApiKey and "set" or "nil"), tostring(isRateLimited())), 0,170,255)
        end
        task.wait(6)
    end
end)

-- done
safeTxt(user.Suc, "AI-OpenSource bridge loaded", 0,255,0)
safeTxt(user.Nill, "And I'm not sure it work or not lol...", 0, 255, 152)
updateStatus("Ready")
