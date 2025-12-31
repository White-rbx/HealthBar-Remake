-- gpt 3.2

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
txt(user.Nill, "Version: Test 3.2 | © Copyright LighterCyan", 180, 180, 180)
txt(user.Warn, "Stop! For your safety, please do not share your API and avoid being stared at by people around you. Due to safety and privacy concerns, you confirm that you will use your API to continue using our AI-OpenSource or not? With respect.", 255,255,0)

-- AI-OpenSource -> API check + chat (LocalScript / executor)
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- helpers for executor http
local function get_http_request()
    if syn and syn.request then return syn.request end
    if http and http.request then return http.request end
    if request then return request end
    if fluxus and fluxus.request then return fluxus.request end
    return nil
end
local httpRequest = get_http_request()

local function safeRequest(opts)
    if not httpRequest then
        return false, "No http request function available (executor required)"
    end
    local ok, res = pcall(httpRequest, opts)
    if not ok then return false, tostring(res) end
    return true, res
end

-- UI lookup (wait for frame)
local ok, exp = pcall(function()
    return CoreGui:WaitForChild("ExperienceSettings", 10)
end)
if not ok or not exp then
    warn("[AI] ExperienceSettings not found")
    return
end

local menu = exp:WaitForChild("Menu", 5)
if not menu then warn("[AI] Menu missing") return end

local aio = menu:FindFirstChild("AIOpenSource") or menu:FindFirstChild("ChatGPT") or menu:FindFirstChild("AI-OpenSource")
if not aio then
    warn("[AI] AIOpenSource frame not found under Menu")
    return
end
local frame = aio:FindFirstChild("Frame") or aio

-- wait for controls
local function waitChild(parent, name, t)
    t = t or 6
    local obj = parent:FindFirstChild(name) or parent:WaitForChild(name, t)
    return obj
end

local apiBox     = waitChild(frame, "api", 6)
local confirmBtn = waitChild(frame, "Confirm_api", 6)
local unsaveBtn  = waitChild(frame, "Unsaved_API", 6)
local statusLbl  = waitChild(frame, "Status", 6)
local chatBox    = waitChild(frame, "chat", 6)
local sendBtn    = waitChild(frame, "Send", 6)
local chatLogs   = waitChild(frame, "ChatLogs", 6)

if not (apiBox and confirmBtn and unsaveBtn and statusLbl and chatBox and sendBtn and chatLogs) then
    warn("[AI] Missing one or more UI components. Check names: api, Confirm_api, Unsaved_API, Status, chat, Send, ChatLogs")
    -- continue but safe-fail where needed
end

-- status setter
local function setStatus(s)
    if statusLbl and statusLbl:IsA("TextLabel") then
        statusLbl.Text = "Status: " .. tostring(s)
    end
end

-- simple chat UI append
local function txt(user, text, R, G, B)
    local cha = Instance.new("TextLabel")
    cha.Name = "Text"
    cha.Size = UDim2.new(1, 0, 0, 30)
    cha.TextColor3 = Color3.fromRGB(R or 255, G or 255, B or 255)
    cha.BackgroundTransparency = 1
    cha.Text = tostring(user) .. tostring(text)
    cha.TextSize = 16
    cha.RichText = true
    cha.TextWrapped = true
    cha.TextXAlignment = Enum.TextXAlignment.Left
    cha.TextYAlignment = Enum.TextYAlignment.Top
    cha.AutomaticSize = Enum.AutomaticSize.Y
    cha.Parent = chatLogs
    return cha
end

-- config/state
local cfg = {
    apiKey = nil,
    provider = nil, -- "openai" or "gemini"
    modelOpenAI = "gpt-4o-mini", -- default model for OpenAI check/send (adjust if needed)
    modelGemini = "gemini-2.5-flash", -- for Gemini endpoint build
    geminiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
    openaiUrl = "https://api.openai.com/v1/chat/completions",
    maxRetries = 4
}

-- detect key type
local function detectKeyType(key)
    if not key or key == "" then return nil end
    if string.match(key, "^%s*sk") then return "openai" end
    if string.match(key, "^%s*sk%-proj") then return "openai" end
    if string.match(key, "^%s*AIza") then return "gemini" end
    -- fallback: if contains "sk-" treat openai, else: unknown -> prefer openai attempt first
    if string.find(key, "sk%-") then return "openai" end
    return nil
end

-- retry/backoff helper
local function doWithRetries(fn)
    local attempt = 0
    while attempt <= cfg.maxRetries do
        attempt = attempt + 1
        local ok, res = pcall(fn)
        if ok then
            return true, res
        else
            local err = res
            -- if error indicates rate limit, do exponential backoff
            if tostring(err):find("429") or tostring(err):lower():find("rate") then
                local waitFor = math.min(2 ^ attempt, 10)
                task.wait(waitFor)
                -- retry
            else
                return false, err
            end
        end
    end
    return false, "max retries exceeded"
end

-- check functions
local function checkOpenAIKey(key)
    return doWithRetries(function()
        local body = {
            model = cfg.modelOpenAI,
            messages = {
                {role="user", content = "ping"}
            },
            max_tokens = 1
        }
        local ok, res = safeRequest({
            Url = cfg.openaiUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. key
            },
            Body = HttpService:JSONEncode(body)
        })
        if not ok then error(res) end
        local status = res.StatusCode or res.status or res.code
        if status == 200 or status == 201 then
            return true
        elseif status == 401 then
            error("401")
        elseif status == 429 then
            error("429")
        else
            -- try to parse body for message
            local parsed
            pcall(function() parsed = HttpService:JSONDecode(res.Body or "{}") end)
            local msg = parsed and (parsed.error and parsed.error.message) or ("HTTP "..tostring(status))
            error(msg)
        end
    end)
end

local function checkGeminiKey(key)
    return doWithRetries(function()
        local body = {
            prompt = {
                text = "ping"
            },
            -- some runtime may require "instances" format; but we'll use their generateContent pattern minimally
        }
        local raw = HttpService:JSONEncode({inputs = { {content = {text = "ping"}} }})
        -- earlier examples used x-goog-api-key header and v1beta models/gemini-2.5-flash:generateContent
        local ok, res = safeRequest({
            Url = cfg.geminiUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["x-goog-api-key"] = key
            },
            Body = raw
        })
        if not ok then error(res) end
        local status = res.StatusCode or res.status
        if status == 200 then
            return true
        elseif status == 401 then
            error("401")
        elseif status == 429 then
            error("429")
        else
            local parsed
            pcall(function() parsed = HttpService:JSONDecode(res.Body or "{}") end)
            local msg = parsed and (parsed.error and parsed.error.message) or ("HTTP "..tostring(status))
            error(msg)
        end
    end)
end

-- UI button behaviors
confirmBtn.MouseButton1Click:Connect(function()
    local key = tostring(apiBox.Text or ""):match("%S.*%S") or tostring(apiBox.Text or "")
    if key == "" then
        setStatus("No key")
        return
    end

    setStatus("Connecting")
    -- choose by detection first
    local kind = detectKeyType(key)
    if kind == "openai" then setStatus("Select ChatGPT")
    elseif kind == "gemini" then setStatus("Select Gemini")
    else setStatus("Select (unknown), trying OpenAI then Gemini") end

    task.spawn(function()
        -- try OpenAI if detected or attempt fallback
        local ok, err
        if kind == "openai" or not kind then
            ok, err = pcall(checkOpenAIKey, key)
            if ok and err then
                cfg.apiKey = key; cfg.provider = "openai"
                setStatus("Connected (ChatGPT)")
                return
            end
            -- if failed and not detected, try Gemini next
        end

        -- try Gemini
        ok, err = pcall(checkGeminiKey, key)
        if ok and err then
            cfg.apiKey = key; cfg.provider = "gemini"
            setStatus("Connected (Gemini)")
            return
        end

        -- if we got here, both fail -> invalid
        setStatus("Invalid key")
        warn("[AI] Key test failed:", err)
    end)
end)

unsaveBtn.MouseButton1Click:Connect(function()
    cfg.apiKey = nil
    cfg.provider = nil
    apiBox.Text = ""
    setStatus("No key")
end)

-- simple send handlers for Chat (one request at a time)
local sending = false

local function sendToOpenAI(prompt)
    local body = {
        model = cfg.modelOpenAI,
        messages = {
            {role="user", content = prompt}
        },
        max_tokens = 600
    }
    local ok, res = safeRequest({
        Url = cfg.openaiUrl,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. cfg.apiKey
        },
        Body = HttpService:JSONEncode(body)
    })
    if not ok then return false, res end
    if (res.StatusCode or res.status) ~= 200 then
        local parsed
        pcall(function() parsed = HttpService:JSONDecode(res.Body or "{}") end)
        local msg = parsed and (parsed.error and parsed.error.message) or ("HTTP "..tostring(res.StatusCode or res.status))
        return false, msg
    end
    local parsed = HttpService:JSONDecode(res.Body)
    -- try to extract reply
    local reply = ""
    pcall(function()
        if parsed and parsed.choices and parsed.choices[1] and parsed.choices[1].message then
            reply = parsed.choices[1].message.content or ""
        elseif parsed and parsed.choices and parsed.choices[1] and parsed.choices[1].text then
            reply = parsed.choices[1].text or ""
        end
    end)
    return true, reply
end

local function sendToGemini(prompt)
    -- body structure depends on API surface; attempt a minimal generateContent-like call
    local body = {
        input = {
            text = prompt
        },
        -- if API expects different shape, actual prod code should adjust
    }
    local ok, res = safeRequest({
        Url = cfg.geminiUrl,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["x-goog-api-key"] = cfg.apiKey
        },
        Body = HttpService:JSONEncode({instances = { {content = {text = prompt}} }})
    })
    if not ok then return false, res end
    if (res.StatusCode or res.status) ~= 200 then
        local parsed
        pcall(function() parsed = HttpService:JSONDecode(res.Body or "{}") end)
        local msg = parsed and (parsed.error and parsed.error.message) or ("HTTP "..tostring(res.StatusCode or res.status))
        return false, msg
    end
    local parsed = HttpService:JSONDecode(res.Body)
    -- try to extract textual reply
    local reply = ""
    pcall(function()
        if parsed and parsed.candidates and parsed.candidates[1] and parsed.candidates[1].content and parsed.candidates[1].content[1] then
            reply = parsed.candidates[1].content[1].text or ""
        elseif parsed and parsed.generated_text then
            reply = parsed.generated_text or ""
        end
    end)
    return true, reply
end

local function requestChat(prompt)
    if not cfg.apiKey or not cfg.provider then
        setStatus("No key")
        txt("Error: ", "No API configured", 255,0,0)
        return
    end
    if sending then
        txt("Info: ", "Already sending, wait...", 0,170,255)
        return
    end
    sending = true
    local userText = tostring(prompt)
    txt("You: ", userText, 255,255,255)
    chatBox.Text = ""
    txt("ChatGPT: ", "Thinking...", 85,255,255)

    local sendFn = cfg.provider == "openai" and sendToOpenAI or sendToGemini

    -- retries for 429 implemented here (exponential)
    local attempt = 0
    local maxAttempts = cfg.maxRetries + 1
    local finalOk, finalRes, errMsg
    while attempt < maxAttempts do
        attempt = attempt + 1
        local ok, res = pcall(sendFn, userText)
        if ok then
            if res == false then
                finalOk = false
                finalRes = "Empty response"
                errMsg = "empty"
                break
            else
                finalOk = true
                finalRes = res
                break
            end
        else
            -- sendFn returned error via pcall -> res is message
            local e = res or "unknown"
            if tostring(e):find("429") or tostring(e):lower():find("rate") then
                local waitTime = math.min(2 ^ attempt, 10)
                setStatus("Rate limit, retrying in "..waitTime.."s")
                task.wait(waitTime)
                -- continue
            else
                finalOk = false
                finalRes = tostring(e)
                errMsg = tostring(e)
                break
            end
        end
    end

    -- remove the last "Thinking..." line and append result
    -- (quick-and-dirty: find last child with Name "Text" and content "Thinking..." and replace)
    for i = #chatLogs:GetChildren(), 1, -1 do
        local c = chatLogs:GetChildren()[i]
        if c and c:IsA("TextLabel") and tostring(c.Text or ""):match("Thinking...") then
            c:Destroy()
            break
        end
    end

    if finalOk then
        txt("ChatGPT: ", tostring(finalRes), 85,255,255)
        setStatus("Connected")
    else
        txt("Error: ", tostring(finalRes or errMsg), 255,0,0)
        setStatus("Invalid key / API Error")
    end

    sending = false
end

-- connect send events
sendBtn.MouseButton1Click:Connect(function()
    local text = tostring(chatBox.Text or "")
    if text == "" then return end
    requestChat(text)
end)

chatBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local t = tostring(chatBox.Text or "")
        if t ~= "" then requestChat(t) end
    end
end)

-- initial status
if apiBox and apiBox.Text and apiBox.Text ~= "" then
    setStatus("Key present, press Confirm")
else
    setStatus("No key")
end

-- quick helper: auto-detect when user pasted key and pressed confirm?
apiBox.FocusLost:Connect(function(enter)
    if enter and apiBox.Text and apiBox.Text ~= "" then
        setStatus("Key entered - press Confirm")
    end
end)

print("[AI] Script loaded. Provider:", cfg.provider or "none")
