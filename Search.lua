-- searcher... yes. 2.4

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

--[[
Before we starting create guis or any script
we must get api searcher into our description first!

-- ==== API ==== --
WeAreDevs: https://wearedevs.net/api/scripts/search
More Source: https://wearedevs.net/forum/t/37448

ScriptBlox: https://scriptblox.com/api/script/fetch
More Source: https://docs.scriptblox.com/scripts/fetch
-- ============= --

]]

-- Locate  
local menu = CoreGui:WaitForChild("ExperienceSettings", 10):FindFirstChild("Menu")  
if not menu then return end  
  
-- =========================  
-- Main Frame  
-- =========================  
local sea = Instance.new("Frame")  
sea.Name = "Search"  
sea.Size = UDim2.new(1, 0, 0.9, 0)  
sea.Position = UDim2.new(0, 0, 1, 0)  
sea.BackgroundColor3 = Color3.fromRGB(18, 18, 21)  
sea.BackgroundTransparency = 0.3  
sea.Active = false  
sea.Parent = menu  
  
-- =========================  
-- Top Frame  
-- =========================  
local tf = Instance.new("Frame")  
tf.Name = "TopFrame"  
tf.Size = UDim2.new(1, 0, 0.15, 0)  
tf.BackgroundTransparency = 1  
tf.Active = false  
tf.Parent = sea  
ListLayout(tf, 0, 5, HCenter, VCenter, SLayout, FillH)  
  
-- =========================  
-- Search Bar  
-- =========================  
local bar = Instance.new("Frame")  
bar.Name = "SearchBar"  
bar.Size = UDim2.new(0.5, 0, 0.3, 0)  
bar.BackgroundTransparency = 0.5  
bar.Parent = tf  
  
Corner(10, 0, bar)  
Stroke(bar, ASMBorder, 255, 255, 255, LineJoinMode, 1, 0)  
ListLayout(bar, 0, 5, HCenter, VCenter, SLayout, FillV)  
Gradient(bar,0, 0, 0,Color3.fromRGB(255,255,255), Color3.fromRGB(0,0,0))  
  
-- =========================  
-- TextBox  
-- =========================  
local tb = Instance.new("TextBox")  
tb.Name = "Searcher"  
tb.Size = UDim2.new(0.95, 0, 0.5, 0)  
tb.BackgroundTransparency = 1  
tb.Text = ""  
tb.PlaceholderText = "[ Select first ] Searcher"  
tb.TextColor3 = Color3.fromRGB(255, 255, 255)  
tb.TextScaled = true  
tb.TextXAlignment = Enum.TextXAlignment.Left  
tb.ClearTextOnFocus = false  
tb.Parent = bar  
  
-- Button ScriptBlox  
local sb = Instance.new("TextButton")  
sb.Name = "ScriptBlox"  
sb.Size = UDim2.new(0.1,0,0.3,0)  
sb.TextColor3 = Color3.fromRGB(255,255,255)  
sb.Text = "ScriptBlox"  
sb.TextScaled = true  
sb.Parent = tf  
Corner(10, 0, sb)  
Stroke(sb, ASMBorder, 255, 105, 180, LineJoinMode, 1, 0)  
ListLayout(sb, 0, 5, HCenter, VCenter, SLayout, FillV)  
Gradient(sb,90, 0, 0,Color3.fromRGB(255,105,180),Color3.fromRGB(255,182,193))  
  
-- Button WeAreDev  
local wrd = Instance.new("TextButton")  
wrd.Name = "WeAreDev"  
wrd.Size = UDim2.new(0.1,0,0.3,0)  
wrd.TextColor3 = Color3.fromRGB(255,255,255)  
wrd.Text = "WeAreDev (SOON)"  
wrd.BackgroundTransparency = 0.5
wrd.TextScaled = true  
wrd.Parent = tf  
Corner(10, 0, wrd)  
Stroke(wrd, ASMBorder, 123, 165, 168, LineJoinMode, 1, 0)  
ListLayout(wrd, 0, 5, HCenter, VCenter, SLayout, FillV)  
Gradient(wrd,90, 0, 0,Color3.fromRGB(123,165,168),Color3.fromRGB(0,255,255))  
  
-- scroll  
local sc = Instance.new("ScrollingFrame")  
sc.Name = "scroll"  
sc.Position = UDim2.new(0.05,0,0.15,0)  
sc.Size = UDim2.new(0.9,0,0.85,0)  
sc.BackgroundTransparency = 1  
sc.Active = true
sc.CanvasSize = UDim2.new(0,0,0,0)  
sc.AutomaticCanvasSize = Enum.AutomaticSize.Y  
sc.ScrollBarThickness = 5  
sc.ScrollingDirection = Enum.ScrollingDirection.Y  
sc.Parent = sea  

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0, 180, 0, 250) 
grid.CellPadding = UDim2.new(0, 5, 0, 5) 
grid.FillDirection = Enum.FillDirection.Horizontal
grid.SortOrder = Enum.SortOrder.Name
grid.Parent = sc

local function asset(title, visits, likes, callback)
    local handle = Instance.new("Frame")
    handle.Name = "Handle"
    handle.Size = UDim2.new(0, 220, 0, 250)
    handle.BackgroundTransparency = 0.25
    handle.BackgroundColor3 = Color3.fromRGB(18,18,21)
    handle.Parent = sc
    Corner(0, 8, handle)

    local ins = Instance.new("Frame")
    ins.Size = UDim2.new(1, -8, 1, -8)
    ins.Position = UDim2.new(0, 4, 0, 4)
    ins.BackgroundTransparency = 1
    ins.Parent = handle

    -- Title
    local titleLb = Instance.new("TextLabel")
    titleLb.Size = UDim2.new(1, 0, 0, 40)
    titleLb.Name = "Title"
    titleLb.TextWrapped = true
    titleLb.BackgroundTransparency = 1
    titleLb.TextColor3 = Color3.fromRGB(255,255,255)
    titleLb.TextXAlignment = Enum.TextXAlignment.Left
    titleLb.TextYAlignment = Enum.TextYAlignment.Center
    titleLb.TextScaled = true
    titleLb.Text = tostring(title)
    titleLb.Parent = ins

    local ima = Instance.new("ImageLabel")      
    ima.Name = "ImageAsset"      
    ima.Size = UDim2.new(1,0,0,100)
    ima.Position = UDim2.new(0,0,0,42)
    ima.BackgroundTransparency = 0.3      
    ima.Image = "rbxassetid://140452968852400" 
    ima.Parent = ins      
    Corner(0,8,ima)      

    -- Visits
    local vis = Instance.new("TextLabel")
    vis.Position = UDim2.new(0,0,0,142)
    vis.Name = "Visit"
    vis.Size = UDim2.new(1,0,0,18)
    vis.BackgroundTransparency = 1
    vis.TextColor3 = Color3.fromRGB(200,200,200)
    vis.TextXAlignment = Enum.TextXAlignment.Left
    vis.TextScaled = true
    vis.Text = "Visits: " .. tostring(visits or 0)
    vis.Parent = ins

    -- Likes
    local lik = Instance.new("TextLabel")
    lik.Position = UDim2.new(0,0,0,158)
    lik.Name = "Like"
    lik.Size = UDim2.new(1,0,0,18)
    lik.BackgroundTransparency = 1
    lik.TextColor3 = Color3.fromRGB(200,200,200)
    lik.TextXAlignment = Enum.TextXAlignment.Left
    lik.TextScaled = true
    lik.Text = "Likes: " .. tostring(likes or 0)
    lik.Parent = ins

    -- Execute
    local exe = Instance.new("TextButton")
    exe.Size = UDim2.new(1, 0, 0, 20)
    exe.Position = UDim2.new(0, 0, 1, -20)
    exe.BackgroundColor3 = Color3.fromRGB(30,30,30)
    exe.TextColor3 = Color3.fromRGB(255,255,255)
    exe.TextScaled = false
    exe.Text = "EXECUTE"
    exe.Parent = ins
    Corner(0, 8, exe)

    local cop = Instance.new("TextButton")  
    cop.Name = "copy"  
    cop.Size = UDim2.new(1,0,0,20)  
    cop.Position = UDim2.new(0,0,1,-44)  
    cop.TextColor3 = Color3.fromRGB(255,255,255)  
    cop.TextScaled = false 
    cop.BackgroundColor3 = Color3.fromRGB(50,50,50)  
    cop.Text = "COPY TO CLIPBOARD"  
    cop.Parent = ins  
    Corner(0,8,cop) 

    if callback then
        exe.MouseButton1Click:Connect(function()
            callback("execute")
        end)

        cop.MouseButton1Click:Connect(function()
            callback("copy")
        end)
    end
end

-- ======== --
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local menu = CoreGui:WaitForChild("ExperienceSettings")
    :WaitForChild("Menu")

local searchBtn =
    menu.TopBar.Holder:WaitForChild("a4_Search")

-- your frame
-- local sea = ...

-- asset ids
local IMG_CLOSE = "rbxassetid://115316941207686"
local IMG_OPEN  = "rbxassetid://108649442107108"

local tweenInfo = TweenInfo.new(
    0.35, -- time
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)

local function tweenSea(pos)
    TweenService:Create(
        sea,
        tweenInfo,
        { Position = pos }
    ):Play()
end

local function updateState()
    if searchBtn.Image == IMG_CLOSE then
        tweenSea(UDim2.new(0,0,1,0)) -- CLOSE
    elseif searchBtn.Image == IMG_OPEN then
        tweenSea(UDim2.new(0,0,0.1,0)) -- OPEN
    end
  end

searchBtn:GetPropertyChangedSignal("Image"):Connect(updateState)
updateState()

-- ======= --
local HttpService = game:GetService("HttpService")

-- =========================
-- CONFIG
-- =========================
local SCRIPTBLOX_SEARCH =
    "https://scriptblox.com/api/script/search?q=%s&page=1&max=120"

local SCRIPTBLOX_HOME =
    "https://scriptblox.com/api/script/fetch"

-- =========================
-- HELPERS
-- =========================
local function clearResults()
    for _,v in ipairs(sc:GetChildren()) do
        if v:IsA("Frame") then
            v:Destroy()
        end
    end
end

local function httpGetJson(url)
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok then
        warn("[ScriptBlox] HTTP error:", res)
        return nil
    end

    local success, data = pcall(function()
        return HttpService:JSONDecode(res)
    end)
    if not success then
        warn("[ScriptBlox] JSON decode failed")
        return nil
    end

    return data
end

-- =========================
-- MAIN RENDER
-- =========================
local function renderScripts(scripts)
    clearResults()

    for _,script in ipairs(scripts) do
        local title  = script.title or "Untitled"
        local views  = script.views or 0
        local likes  = script.likeCount or 0
        local source = script.script or ""

        asset(title, views, likes, function(action)
            if action == "execute" then
                if source ~= "" then
                    local fn, err = loadstring(source)
                    if fn then
                        fn()
                    else
                        warn("[ScriptBlox] Compile error:", err)
                    end
                end

            elseif action == "copy" then
                local clip = setclipboard or toclipboard
                if clip and source ~= "" then
                    clip(source)
                end
            end
        end)
    end
end

-- =========================
-- FETCH HOME (no search)
-- =========================
local function fetchHome()
    clearResults()
    local data = httpGetJson(SCRIPTBLOX_HOME)
    if not data or not data.result then return end

    renderScripts(data.result.scripts or {})
end

-- =========================
-- SEARCH
-- =========================
local function searchScriptBlox(query)
    if not query or query == "" then
        fetchHome()
        return
    end

    clearResults()

    local url = SCRIPTBLOX_SEARCH:format(HttpService:UrlEncode(query))
    local data = httpGetJson(url)
    if not data or not data.result then return end

    renderScripts(data.result.scripts or {})
end

-- =========================
-- BUTTON WIRING
-- =========================
sb.MouseButton1Click:Connect(function()
    searchScriptBlox(tb.Text)
end)

-- Optional: Enter key
tb.FocusLost:Connect(function(enter)
    if enter then
        searchScriptBlox(tb.Text)
    end
end)

-- =========================
-- AUTO LOAD HOME
-- =========================
fetchHome()
