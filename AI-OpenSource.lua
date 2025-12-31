-- gpt 3.3

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
tb.PlaceholderText = "[ Your API_gpt here (ChatGPT or Gemini) ]"
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
]]

-- functions
local user = {
    plr  = "You: ",
    chat = "AI: ",
    Error = "Error: ",
    Suc   = "Success: ",
    Warn  = "Warning: ",
    Info  = "Information: ",
    Nill = ""
}

-- ChatLogs Line
local function txt(user, text, R, G, B)
    local cha = Instance.new("TextLabel")
    cha.Name = "Text"
    cha.Size = UDim2.new(1, 0, 0, 30) -- default height (ปรับภายหลังได้)
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
]]

txt(user.Nill, "Nothing is working! Please wait for the next update!", 180,180,180)
txt(user.Nill, "Version: Test 3.3 | © Copyright LighterCyan", 180, 180, 180)
txt(user.Warn, "Stop! For your safety, please do not share your API and avoid being stared at by people around you. Due to safety and privacy concerns, you confirm that you will use your API to continue using our AI-OpenSource or not? With respect.", 255,255,0)

-- AI-OpenSource API connector (tail)
-- Requires existing UI:
--   Frame: api (TextBox), Confirm_api (TextButton), Unsaved_API (TextButton), Status (TextLabel),
--   chat (TextBox), Send (TextButton), ChatLogs (ScrollingFrame)
-- Also requires a function txt(user, text, R,G,B) that appends a TextLabel to ChatLogs.

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- try to find UI root (adjust path if you use different)
local ok, root = pcall(function()
    return CoreGui:WaitForChild("ExperienceSettings", 5)
              :WaitForChild("Menu", 5)
              :WaitForChild("AIOpenSource", 5)
              :WaitForChild("Frame", 5)
end)

if not ok or not root then
    warn("[AI-OpenSource] UI root not found; aborting connector.")
    return
end

local apiBox      = root:FindFirstChild("api")
local confirmBtn  = root:FindFirstChild("Confirm_api")
local unsaveBtn   = root:FindFirstChild("Unsaved_API")
local statusLabel = root:FindFirstChild("Status")
local chatBox     = root:FindFirstChild("chat")
local sendBtn     = root:FindFirstChild("Send")
local chatLogs    = root:FindFirstChild("ChatLogs")

-- sanity checks
if not apiBox or not confirmBtn or not unsaveBtn or not statusLabel or not chatBox or not sendBtn or not chatLogs then
    warn("[AI-OpenSource] Some UI elements are missing. Required: api, Confirm_api, Unsaved_API, Status, chat, Send, ChatLogs.")
    -- still continue but some features may fail
end

-- rely on txt(...) existing (user provided). If not, fallback simple function that inserts a TextLabel.
if not txt then
    function txt(user, text, R, G, B)
        local cha = Instance.new("TextLabel")
        cha.Size = UDim2.new(1,0,0,30)
        cha.Text = tostring(user) .. tostring(text)
        cha.BackgroundTransparency = 1
        cha.TextColor3 = Color3.fromRGB(R or 255, G or 255, B or 255)
        cha.TextWrapped = true
        cha.AutomaticSize = Enum.AutomaticSize.Y
        cha.Parent = chatLogs
        return cha
    end
end

-- http request function (executor friendly)
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local hasHttp = type(httpRequest) == "function"

-- base64 helpers if crypt available
local base64Encode = (crypt and (crypt.base64encode or crypt.base64.encode)) or (function(s) return s end)
local base64Decode = (crypt and (crypt.base64decode or crypt.base64.decode)) or (function(s) return s end)

-- file storage
local KEY_FILE = "AI_OPEN_KEY.txt"
local function writeKeyToFile(key)
    if writefile then
        local ok, out = pcall(function()
            if base64Encode and base64Encode ~= (function(s) return s end) then
                writefile(KEY_FILE, base64Encode(key))
            else
                writefile(KEY_FILE, key)
            end
        end)
        return ok
    end
    return false
end

local function readKeyFromFile()
    if readfile and isfile and isfile(KEY_FILE) then
        local data = readfile(KEY_FILE)
        if base64Decode and base64Decode ~= (function(s) return s end) then
            return base64Decode(data)
        else
            return data
        end
    end
    return nil
end

local currentKey = readKeyFromFile() or apiBox and tostring(apiBox.Text or "") or ""
if currentKey == "" then currentKey = nil end

-- state
local provider = nil -- "chatgpt" or "gemini"
local connected = false

local function setStatus(s)
    if statusLabel then
        statusLabel.Text = "Status: " .. tostring(s)
    end
end

local function detectProviderFromKey(key)
    if not key then return nil end
    key = tostring(key)
    -- heuristics: sk-... => OpenAI; sk-proj... => project key -> OpenAI; AIza... => Google API key (Gemini)
    if string.match(key, "^sk%-proj") or string.match(key, "^sk%-") then
        return "chatgpt"
    end
    if string.find(key, "AIza") then
        return "gemini"
    end
    -- fallback: if contains "x-goog-api-key" pattern? else nil
    return nil
end

-- HTTP helpers with retry/backoff for 429
local function requestWithRetry(reqArgs, maxRetries)
    maxRetries = maxRetries or 4
    local delayBase = 0.8
    local lastResp, lastErr
    for attempt = 1, (maxRetries+1) do
        if not hasHttp then
            return false, "HTTP not available in this environment"
        end
        local ok, resp = pcall(function() return httpRequest(reqArgs) end)
        if not ok then
            lastErr = resp
            -- fallthrough to retry?
        else
            -- resp is table with StatusCode or Code depending on executor
            local code = resp.StatusCode or resp.code or resp.Status or resp.Status or 0
            code = tonumber(code) or 0
            if code == 429 then
                lastResp = resp
                -- exponential backoff
                local backoff = delayBase * (2 ^ (attempt-1))
                task.wait(backoff)
                continue
            end
            return true, resp
        end
        -- small wait before next attempt in case of pcall failure
        task.wait(0.5)
    end
    return false, lastErr or lastResp
end

-- validate key by calling provider-specific small request
local function validateKey(key, prov)
    if not key then return false, "No key" end
    if not hasHttp then return false, "No HTTP available" end

    setStatus("Connecting")
    if prov == "chatgpt" then
        -- OpenAI validate by listing models (GET)
        local url = "https://api.openai.com/v1/models"
        local ok, resp = requestWithRetry({
            Url = url,
            Method = "GET",
            Headers = {
                ["Authorization"] = "Bearer " .. key,
                ["Content-Type"] = "application/json"
            },
            Timeout = 15
        }, 2)
        if not ok then
            return false, tostring(resp)
        end
        local code = resp.StatusCode or resp.code or 0
        if code >= 200 and code < 300 then
            return true, "Connected"
        elseif code == 401 or code == 403 then
            return false, "Invalid key"
        else
            return false, "HTTP "..tostring(code)
        end
    elseif prov == "gemini" then
        -- Gemini minimal POST check (small body)
        local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.0:generateText"
        -- (try a minimal body; some endpoints require different model names — this is best-effort)
        local body = HttpService:JSONEncode({prompt = "hello", maxOutputTokens=1})
        local ok, resp = requestWithRetry({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["x-goog-api-key"] = key
            },
            Body = body,
            Timeout = 15
        }, 2)
        if not ok then
            return false, tostring(resp)
        end
        local code = resp.StatusCode or resp.code or 0
        if code >= 200 and code < 300 then
            return true, "Connected"
        elseif code == 401 or code == 403 then
            return false, "Invalid key"
        else
            return false, "HTTP "..tostring(code)
        end
    else
        return false, "Unknown provider"
    end
end

-- set provider & status from key (but don't save)
local function setKeyAndDetect(key)
    currentKey = key and key ~= "" and tostring(key) or nil
    provider = detectProviderFromKey(currentKey)
    if not currentKey then
        setStatus("No key")
        connected = false
        return
    end
    if provider == "chatgpt" then
        setStatus("Select ChatGPT")
    elseif provider == "gemini" then
        setStatus("Select Gemini")
    else
        setStatus("Select Provider")
    end
end

-- initial detect
setKeyAndDetect(currentKey)
if apiBox and currentKey then apiBox.Text = currentKey end

-- UI -> Confirm button
if confirmBtn then
    confirmBtn.MouseButton1Click:Connect(function()
        local raw = (apiBox and tostring(apiBox.Text or "") or "")
        if raw == "" then
            setStatus("No key")
            return
        end
        local prov = detectProviderFromKey(raw)
        if not prov then
            -- try heuristics: if contains "sk-" choose chatgpt
            if string.match(raw, "^sk%-") then prov = "chatgpt" end
        end
        if not prov then
            setStatus("Select Provider")
            txt("Error: ", "Cannot detect provider from key. Paste a ChatGPT sk- key or Google API key (AIza...).", 255,100,100)
            return
        end

        -- check validity (non-blocking)
        setStatus("Connecting")
        task.spawn(function()
            local ok, msg = validateKey(raw, prov)
            if ok then
                -- save
                local saved = writeKeyToFile(raw)
                if saved then
                    setStatus("Connected")
                else
                    setStatus("Connected")
                end
                currentKey = raw
                provider = prov
                connected = true
                txt("Success: ", "API key validated and saved (if writefile available). Provider: "..prov, 0,255,0)
            else
                setStatus("Invalid key")
                connected = false
                txt("Error: ", "Key validation failed: "..tostring(msg), 255,120,120)
            end
        end)
    end)
end

-- UI -> Unsaved button (clear key)
if unsaveBtn then
    unsaveBtn.MouseButton1Click:Connect(function()
        -- remove file if possible and clear in-memory
        if isfile and isfile(KEY_FILE) and delfile then
            pcall(function() delfile(KEY_FILE) end)
        end
        currentKey = nil
        provider = nil
        connected = false
        if apiBox then apiBox.Text = "" end
        setStatus("Unsave key")
        txt("Info: ", "API key removed (unsaved).", 0,170,255)
        -- final status
        task.delay(1, function() setStatus("No key") end)
    end)
end

-- send -> actual chat request
local function sendToProvider(promptText)
    if not currentKey then
        txt("Error: ", "No API key. Please set one first.", 255,0,0)
        setStatus("No key")
        return
    end
    if not provider then
        txt("Error: ", "Provider not detected from key.", 255,0,0)
        setStatus("Select Provider")
        return
    end
    setStatus("Connecting")

    -- show thinking placeholder
    txt("You: ", promptText, 255,255,255)
    local thinking = txt("ChatGPT: ", "Thinking...", 180,255,200)

    task.spawn(function()
        if provider == "chatgpt" then
            -- OpenAI ChatCompletion
            local url = "https://api.openai.com/v1/chat/completions"
            local body = {
                model = "gpt-4o-mini", -- you mentioned gpt-4o-mini earlier
                messages = {
                    {role = "user", content = promptText}
                },
                max_tokens = 512
            }
            local ok, resp = requestWithRetry({
                Url = url,
                Method = "POST",
                Headers = {
                    ["Authorization"] = "Bearer " .. currentKey,
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(body),
                Timeout = 30
            }, 3)

            if not ok then
                thinking.Text = "Error: Request failed"
                setStatus("Invalid key")
                txt("Error: ", tostring(resp), 255,0,0)
                return
            end

            local code = resp.StatusCode or resp.code or 0
            if code == 429 then
                thinking.Text = "Error: Rate limited (429)"
                setStatus("Invalid key")
                txt("Error: ", "HTTP 429 rate limit", 255,0,0)
                return
            end

            if code >= 200 and code < 300 then
                local success, decoded = pcall(function() return HttpService:JSONDecode(resp.Body) end)
                if not success or not decoded then
                    thinking.Text = "Error: Bad response"
                    txt("Error: ", "Failed to decode response", 255,0,0)
                    setStatus("Invalid key")
                    return
                end
                -- extract text (safely)
                local content = nil
                if decoded.choices and decoded.choices[1] and decoded.choices[1].message and decoded.choices[1].message.content then
                    content = decoded.choices[1].message.content
                elseif decoded.choices and decoded.choices[1] and decoded.choices[1].text then
                    content = decoded.choices[1].text
                end
                content = tostring(content or "[No content]")
                thinking.Text = content
                setStatus("Connected")
                return
            else
                thinking.Text = "Error: HTTP "..tostring(code)
                txt("Error: ", "HTTP "..tostring(code).. " ".. (resp.StatusMessage or ""), 255,0,0)
                setStatus("Invalid key")
                return
            end

        elseif provider == "gemini" then
            -- Gemini (Google) generateContent minimal call
            local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.0:generateText"
            local bodyTable = {
                prompt = {
                    text = promptText
                },
                maxOutputTokens = 512
            }
            local ok, resp = requestWithRetry({
                Url = url,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["x-goog-api-key"] = currentKey
                },
                Body = HttpService:JSONEncode(bodyTable),
                Timeout = 30
            }, 3)

            if not ok then
                thinking.Text = "Error: Request failed"
                setStatus("Invalid key")
                txt("Error: ", tostring(resp), 255,0,0)
                return
            end
            local code = resp.StatusCode or resp.code or 0
            if code >= 200 and code < 300 then
                local success, decoded = pcall(function() return HttpService:JSONDecode(resp.Body) end)
                if success and decoded then
                    -- try to extract text
                    local content = decoded.output and decoded.output[1] and decoded.output[1].content and decoded.output[1].content[1] and decoded.output[1].content[1].text
                    if not content then
                        -- alternate shapes
                        if decoded.candidates and decoded.candidates[1] and decoded.candidates[1].content and decoded.candidates[1].content[1] then
                            content = decoded.candidates[1].content[1].text
                        end
                    end
                    thinking.Text = tostring(content or "[No content]")
                    setStatus("Connected")
                    return
                else
                    thinking.Text = "Error: Bad response"
                    setStatus("Invalid key")
                    txt("Error: ", "Failed to decode Gemini response", 255,0,0)
                    return
                end
            else
                thinking.Text = "Error: HTTP "..tostring(code)
                setStatus("Invalid key")
                txt("Error: ", "HTTP "..tostring(code).. " ".. (resp.StatusMessage or ""), 255,0,0)
                return
            end
        else
            thinking.Text = "Error: Unknown provider"
            setStatus("Select Provider")
            return
        end
    end)
end

-- send button wiring
if sendBtn and chatBox then
    sendBtn.MouseButton1Click:Connect(function()
        local text = tostring(chatBox.Text or ""):gsub("^%s*(.-)%s*$","%1")
        if text == "" then return end
        chatBox.Text = ""
        sendToProvider(text)
    end)
    -- also allow Enter key inside chatBox (if desktop)
    chatBox.FocusLost:Connect(function(enter)
        if enter then
            local text = tostring(chatBox.Text or ""):gsub("^%s*(.-)%s*$","%1")
            if text ~= "" then
                chatBox.Text = ""
                sendToProvider(text)
            end
        end
    end)
end

-- helper: try auto-validate loaded key on startup (non-blocking)
if currentKey then
    task.spawn(function()
        local prov = detectProviderFromKey(currentKey)
        if not prov then
            setStatus("Select Provider")
            return
        end
        setStatus("Connecting")
        local ok, msg = validateKey(currentKey, prov)
        if ok then
            provider = prov
            connected = true
            setStatus("Connected")
        else
            provider = prov
            connected = false
            setStatus("Invalid key")
            txt("Error: ", "Saved key validation failed: "..tostring(msg), 255,0,0)
        end
    end)
end

-- final friendly notice in UI
txt("Info: ", "API connector ready. Paste your API key and press Confirm.", 0,170,255)
