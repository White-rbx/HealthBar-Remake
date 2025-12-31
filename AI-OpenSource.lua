-- gpt 3.1

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
txt(user.Nill, "Version: Test 3.1 | © Copyright LighterCyan", 180, 180, 180)
txt(user.Warn, "Stop! For your safety, please do not share your API and avoid being stared at by people around you. Due to safety and privacy concerns, you confirm that you will use your API to continue using our AI-OpenSource or not? With respect.", 255,255,0)

--========================--
--  API / HTTP SECTION   --
--========================--

local HttpService = game:GetService("HttpService")

-- executor compatible request
local http_request =
    request or
    http_request or
    syn and syn.request or
    fluxus and fluxus.request

if not http_request then
    warn("Executor HTTP not supported")
end

--========================--
--  STATE / VARS         --
--========================--

local API_KEY = nil
local MODEL = nil -- "chatgpt" | "gemini"
local CONNECTED = false
local BUSY = false

--========================--
--  STATUS HELPER        --
--========================--

local function setStatus(text)
    st.Text = "Status: " .. text
end

setStatus("No key")

--========================--
--  KEY DETECT           --
--========================--

local function detectModel(key)
    if not key or key == "" then
        return nil
    end

    if key:sub(1,3) == "sk-" then
        return "chatgpt"
    elseif key:sub(1,6) == "AIzaSy" then
        return "gemini"
    end

    return nil
end

--========================--
--  API TEST (PING)      --
--========================--

local function testAPI(key, model)
    if not http_request then
        return false, "No HTTP"
    end

    local req
    if model == "chatgpt" then
        req = {
            Url = "https://api.openai.com/v1/models",
            Method = "GET",
            Headers = {
                ["Authorization"] = "Bearer " .. key
            }
        }
    elseif model == "gemini" then
        req = {
            Url = "https://generativelanguage.googleapis.com/v1/models?key=" .. key,
            Method = "GET"
        }
    end

    local res = http_request(req)
    if not res then
        return false, "No response"
    end

    if res.StatusCode == 200 then
        return true
    elseif res.StatusCode == 429 then
        return false, "429"
    else
        return false, "Invalid"
    end
end

--========================--
--  CONFIRM API BUTTON   --
--========================--

con.MouseButton1Click:Connect(function()
    if BUSY then return end
    BUSY = true

    local key = tb.Text
    if not key or key == "" then
        setStatus("No key")
        BUSY = false
        return
    end

    local model = detectModel(key)
    if not model then
        setStatus("Invalid key")
        BUSY = false
        return
    end

    if model == "chatgpt" then
        setStatus("Select ChatGPT")
    else
        setStatus("Select Gemini")
    end

    setStatus("Connecting")

    -- simple retry (fix 429)
    local success, reason
    for i = 1,3 do
        success, reason = testAPI(key, model)
        if success then break end
        if reason == "429" then
            task.wait(1.5 * i)
        else
            break
        end
    end

    if success then
        API_KEY = key
        MODEL = model
        CONNECTED = true
        setStatus("Connected")
        txt(user.Suc, "API connected", 0,255,0)
    else
        CONNECTED = false
        API_KEY = nil
        MODEL = nil
        setStatus("Invalid key")
        txt(user.Error, "Invalid API key", 255,0,0)
    end

    BUSY = false
end)

--========================--
--  UNSAVE API BUTTON    --
--========================--

con2.MouseButton1Click:Connect(function()
    API_KEY = nil
    MODEL = nil
    CONNECTED = false
    tb.Text = ""
    setStatus("Unsave key")
    txt(user.Warn, "API key removed", 255,255,0)
end)

--========================--
--  SEND CHAT            --
--========================--

local function sendChat(message)
    if not CONNECTED or not API_KEY then
        txt(user.Error, "Not connected", 255,0,0)
        return
    end

    if BUSY then return end
    BUSY = true

    txt(user.plr, message, 255,255,255)

    local req
    if MODEL == "chatgpt" then
        req = {
            Url = "https://api.openai.com/v1/chat/completions",
            Method = "POST",
            Headers = {
                ["Authorization"] = "Bearer " .. API_KEY,
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({
                model = "gpt-4o-mini",
                messages = {
                    {role="user", content=message}
                }
            })
        }
    elseif MODEL == "gemini" then
        req = {
            Url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=" .. API_KEY,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({
                contents = {{
                    parts = {{ text = message }}
                }}
            })
        }
    end

    local res = http_request(req)
    if not res then
        txt(user.Error, "No response", 255,0,0)
        BUSY = false
        return
    end

    if res.StatusCode == 200 then
        local data = HttpService:JSONDecode(res.Body)
        local reply = "..."

        if MODEL == "chatgpt" then
            reply = data.choices[1].message.content
        else
            reply = data.candidates[1].content.parts[1].text
        end

        txt(user.chat, reply, 85,255,255)
    elseif res.StatusCode == 429 then
        txt(user.Warn, "Rate limited (429)", 255,255,0)
    else
        txt(user.Error, "HTTP "..res.StatusCode, 255,0,0)
    end

    BUSY = false
end

se.MouseButton1Click:Connect(function()
    if ch.Text ~= "" then
        sendChat(ch.Text)
        ch.Text = ""
    end
end)
