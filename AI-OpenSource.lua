-- gpt 3.4

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
txt(user.Nill, "Version: Test 3.4 | © Copyright LighterCyan", 180, 180, 180)
txt(user.Warn, "Stop! For your safety, please do not share your API and avoid being stared at by people around you. Due to safety and privacy concerns, you confirm that you will use your API to continue using our AI-OpenSource or not? With respect.", 255,255,0)

-- AI-OpenSource connector (Client) -------------------------------------------------
-- วางเป็น LocalScript; ต้องมี UI อยู่แล้วที่
-- CoreGui.ExperienceSettings.Menu.AIOpenSource.Frame
-- Elements expected: api(TextBox) Confirm_api(TextButton) Unsaved_API(TextButton) Status(TextLabel)
--                    chat(TextBox) Send(TextButton) ChatLogs(ScrollingFrame)
-- and a function `txt(user, text, R,G,B)` already defined that appends a line to ChatLogs
-- ----------------------------------------------------------------------------------

local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- PATH TO EXISTING UI (change if your UI lives somewhere else)
local ROOT_FRAME_PATH = {
    "ExperienceSettings",
    "Menu",
    "AIOpenSource",
    "Frame"
}

-- try get frame
local ok, frame = pcall(function()
    local cur = CoreGui
    for _, name in ipairs(ROOT_FRAME_PATH) do
        cur = cur:WaitForChild(name, 5)
    end
    return cur
end)

if not ok or not frame then
    warn("[AI-OpenSource] UI frame not found at CoreGui." .. table.concat(ROOT_FRAME_PATH, "."))
    return
end

-- find UI elements
local tb_api      = frame:FindFirstChild("api", true)        -- TextBox for API key (may be nested)
local btn_confirm = frame:FindFirstChild("Confirm_api", true)
local btn_unsave  = frame:FindFirstChild("Unsaved_API", true)
local lbl_status  = frame:FindFirstChild("Status", true)

local tb_chat     = frame:FindFirstChild("chat", true)
local btn_send    = frame:FindFirstChild("Send", true)
local sf_chatlogs = frame:FindFirstChild("ChatLogs", true)

-- sanity
if not (tb_api and btn_confirm and btn_unsave and lbl_status and tb_chat and btn_send and sf_chatlogs) then
    warn("[AI-OpenSource] Missing one or more UI elements. Make sure names match: api, Confirm_api, Unsaved_API, Status, chat, Send, ChatLogs")
    return
end

-- executor http detection
local http_request = (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or request or http_request
if not http_request then
    warn("[AI-OpenSource] No executor HTTP function found (syn.request/http.request/request). The script requires an executor with HTTP support.")
    lbl_status.Text = "Status: No executor HTTP"
    return
end

-- optional file IO (save key)
local canWrite = type(writefile) == "function"
local canRead  = type(readfile) == "function"
local KEY_FILE = "AI_OPEN_KEY.txt"

-- config
local OPENAI_MODEL_DEFAULT = "gpt-4o-mini"   -- นายบอกใช้อันนี้
local OPENAI_URL = "https://api.openai.com/v1/chat/completions"
local GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

-- state
local currentKey = nil
local currentProvider = nil -- "chatgpt" | "gemini" | nil
local connected = false
local savedToFile = false

-- helpers ------------------------------------------------
local function setStatus(s)
    if lbl_status and lbl_status:IsA("TextLabel") then
        lbl_status.Text = "Status: " .. tostring(s)
    end
end

local function detectProviderFromKey(key)
    if not key then return nil end
    key = tostring(key)
    if key:match("^sk") then
        return "chatgpt"
    end
    if key:match("AIza") then
        return "gemini"
    end
    -- user also had examples like "sk-proj..." (still starts with sk) -> chatgpt
    -- fallback: if contains "sk-" treat as chatgpt
    if key:match("sk%-") then return "chatgpt" end
    return nil
end

-- persist/load
local function saveKeyToFile(key)
    if not canWrite then return false end
    local ok, err = pcall(function()
        writefile(KEY_FILE, key)
    end)
    if ok then savedToFile = true end
    return ok
end

local function loadKeyFromFile()
    if not canRead then return nil end
    local ok, content = pcall(function() return readfile(KEY_FILE) end)
    if ok and content and content ~= "" then
        savedToFile = true
        return content
    end
    return nil
end

-- parse response helpers
local function tryJSONDecode(body)
    local ok, httpService = pcall(function() return game:GetService("HttpService") end)
    if not ok then return nil end
    local ok2, tbl = pcall(function() return httpService:JSONDecode(body) end)
    if ok2 then return tbl end
    return nil
end

-- exponential backoff for 429
local function requestWithRetries(reqOptions, maxRetries)
    maxRetries = maxRetries or 5
    local attempt = 0
    while attempt <= maxRetries do
        local ok, res = pcall(function() return http_request(reqOptions) end)
        if not ok then
            -- network/executor error — return error
            return nil, ("HTTP request failed: " .. tostring(res))
        end

        -- if returned table-like with StatusCode/Status
        local status = res.StatusCode or res.status or res.code or (res and res[1] and res[1].StatusCode)
        local body = res.Body or res.body or tostring(res)
        -- try decode for more info
        if status == 429 then
            -- backoff
            attempt = attempt + 1
            local waitSec = math.min(2 ^ attempt + math.random() * 0.5, 8)
            task.wait(waitSec)
            continue
        end
        return res, nil
    end
    return nil, "HTTP 429 (rate-limited) after retries"
end

-- validate key (small test call)
local function validateKey(key, provider)
    setStatus("Connecting")
    if provider == "chatgpt" then
        -- quick call to OpenAI: send small completion, but use streamless
        local body = {
            model = OPENAI_MODEL_DEFAULT,
            messages = { { role = "user", content = "ping" } },
            max_tokens = 6,
        }
        local httpBody = game:GetService("HttpService"):JSONEncode(body)
        local req = {
            Url = OPENAI_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. key
            },
            Body = httpBody
        }
        local res, err = requestWithRetries(req, 3)
        if not res then
            return false, err or "No response"
        end
        local code = res.StatusCode or res.status or 0
        if code >= 200 and code < 300 then
            return true, "Connected"
        else
            -- try parse error message
            local dec = tryJSONDecode(res.Body or "")
            local msg = dec and (dec.error and dec.error.message) or tostring(res.Body)
            return false, "Invalid key: " .. tostring(msg)
        end
    elseif provider == "gemini" then
        -- call generateContent with tiny prompt
        local rawBody = {
            contents = { { parts = { { text = "ping" } } } }
        }
        local httpBody = game:GetService("HttpService"):JSONEncode(rawBody)
        local req = {
            Url = GEMINI_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["x-goog-api-key"] = key
            },
            Body = httpBody
        }
        local res, err = requestWithRetries(req, 3)
        if not res then
            return false, err or "No response"
        end
        local code = res.StatusCode or res.status or 0
        if code >= 200 and code < 300 then
            return true, "Connected"
        else
            local dec = tryJSONDecode(res.Body or "")
            local msg = dec and (dec.error and dec.error.message) or tostring(res.Body)
            return false, "Invalid key: " .. tostring(msg)
        end
    else
        return false, "Unknown provider"
    end
end

-- send prompt to provider
local function sendPromptToProvider(key, provider, prompt, onDone)
    if not key or not provider then
        if onDone then onDone(nil, "No key/provider") end
        return
    end

    if provider == "chatgpt" then
        local body = {
            model = OPENAI_MODEL_DEFAULT,
            messages = {
                { role = "user", content = prompt }
            },
            max_tokens = 1024
        }
        local httpBody = game:GetService("HttpService"):JSONEncode(body)
        local req = {
            Url = OPENAI_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. key
            },
            Body = httpBody
        }

        local res, err = requestWithRetries(req, 5)
        if not res then
            if onDone then onDone(nil, err) end
            return
        end

        local dec = tryJSONDecode(res.Body or "")
        local text = nil
        if dec then
            -- OpenAI ChatCompletions: choices[1].message.content
            if dec.choices and dec.choices[1] and dec.choices[1].message and dec.choices[1].message.content then
                text = dec.choices[1].message.content
            elseif dec.choices and dec.choices[1] and dec.choices[1].text then
                text = dec.choices[1].text
            end
        end
        if not text then
            text = tostring(res.Body or ""):sub(1, 2000)
        end
        if onDone then onDone(text, nil) end
        return
    elseif provider == "gemini" then
        local rawBody = {
            contents = { { parts = { { text = prompt } } } }
        }
        local httpBody = game:GetService("HttpService"):JSONEncode(rawBody)
        local req = {
            Url = GEMINI_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["x-goog-api-key"] = key
            },
            Body = httpBody
        }

        local res, err = requestWithRetries(req, 5)
        if not res then
            if onDone then onDone(nil, err) end
            return
        end

        local dec = tryJSONDecode(res.Body or "")
        local text = nil
        if dec and dec.candidates and dec.candidates[1] and dec.candidates[1].content and dec.candidates[1].content.parts and dec.candidates[1].content.parts[1] then
            text = dec.candidates[1].content.parts[1].text
        end
        if not text then
            text = tostring(res.Body or ""):sub(1, 2000)
        end
        if onDone then onDone(text, nil) end
        return
    else
        if onDone then onDone(nil, "Unknown provider") end
    end
end

-- UI logic ------------------------------------------------
-- load key from file if present
local function initLoadKey()
    local fkey = nil
    if canRead then
        fkey = loadKeyFromFile()
    end
    if fkey and fkey ~= "" then
        tb_api.Text = fkey
        currentKey = fkey
        currentProvider = detectProviderFromKey(fkey)
        if currentProvider == "chatgpt" then setStatus("Select ChatGPT") end
        if currentProvider == "gemini" then setStatus("Select Gemini") end
        connected = false
    else
        setStatus("No key")
    end
end

-- Confirm API button: validate & save (or just select)
btn_confirm.MouseButton1Click:Connect(function()
    local key = tostring(tb_api.Text or "")
    if key == "" then
        setStatus("No key")
        return
    end

    local provider = detectProviderFromKey(key)
    if not provider then
        -- allow manual selection maybe? For now mark invalid
        setStatus("Invalid key")
        return
    end

    setStatus("Connecting")
    task.spawn(function()
        local ok, err = validateKey(key, provider)
        if ok then
            currentKey = key
            currentProvider = provider
            connected = true
            setStatus(provider == "chatgpt" and "Connected" or "Connected")
            -- try save to file
            if canWrite then saveKeyToFile(key) end
            -- announce in chatlogs
            pcall(function() txt(user.Suc, "API connected (" .. provider .. ")", 180,180,255) end)
        else
            currentKey = nil
            currentProvider = nil
            connected = false
            setStatus("Invalid key")
            pcall(function() txt(user.Error, "API validation failed: "..tostring(err), 255,80,80) end)
        end
    end)
end)

-- Unsaved API
btn_unsave.MouseButton1Click:Connect(function()
    -- clear memory + file
    currentKey = nil
    currentProvider = nil
    connected = false
    setStatus("Unsave key")
    if canWrite then
        pcall(function() delfile(KEY_FILE) end)
    end
    pcall(function() txt(user.Suc, "API key unsaved", 180,180,255) end)
end)

-- send message (ui)
local function sendMessageFromUI()
    local prompt = tostring(tb_chat.Text or ""):match("^%s*(.-)%s*$")
    if not prompt or prompt == "" then return end

    -- add user message
    pcall(function() txt(user.plr, prompt, 255,255,255) end)
    tb_chat.Text = ""

    -- choose provider
    local key = currentKey
    local provider = currentProvider

    if not key or not provider then
        pcall(function() txt(user.Error, "No API key selected/connected", 255,180,60) end)
        setStatus("No key")
        return
    end

    setStatus("Connecting")
    -- async send
    task.spawn(function()
        sendPromptToProvider(key, provider, prompt, function(responseText, err)
            if err then
                pcall(function() txt(user.Error, tostring(err), 255,0,0) end)
                setStatus("Invalid key")
            else
                pcall(function() txt(user.chat, tostring(responseText), 85,255,255) end)
                setStatus("Connected")
            end
        end)
    end)
end

-- hook send button
btn_send.MouseButton1Click:Connect(function()
    sendMessageFromUI()
end)

-- allow Enter to send (on non-mobile the TextBox fires FocusLost)
if tb_chat:IsA("TextBox") then
    tb_chat.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            sendMessageFromUI()
        end
    end)
end

-- initial load
initLoadKey()

-- small helper to auto-scroll ChatLogs when content changes (if UIListLayout present)
-- try to get list layout
local listLayout = sf_chatlogs:FindFirstChildOfClass("UIListLayout")
if listLayout then
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf_chatlogs.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
        sf_chatlogs.CanvasPosition = Vector2.new(0, sf_chatlogs.CanvasSize.Y.Offset)
    end)
end

-- finished
setStatus(currentProvider and "Select " .. (currentProvider == "chatgpt" and "ChatGPT" or "Gemini") or "No key")
print("[AI-OpenSource] connector loaded.")
