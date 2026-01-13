-- searcher... yes. 2.78

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
-- Script counter
-- =========================
local sct = Instance.new("TextLabel")
sct.Name = "ScriptCounter"
sct.Size = UDim2.new(0.1,0,0.3,0)
sct.BackgroundTransparency = 1
sct.Active = false
sct.TextSize = 10
sct.Text = "Script: 0/220"
sct.TextColor3 = Color3.fromRGB(255,255,255)
sct.Parent = tf
  
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

-- ========= SERVICES =========
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- ========= CONFIG =========
local TARGET_TOTAL = 220
local ITEM_DELAY = 0.1
local PAGE_DELAY = 0.2

local SCRIPTBLOX_SEARCH =
    "https://scriptblox.com/api/script/search?q=%s&page=%d&max=20"

local SCRIPTBLOX_HOME =
    "https://scriptblox.com/api/script/fetch"

local FALLBACK_IMAGE = "rbxassetid://140452968852400"

-- =======================

local imageCache = {}

local function getScriptImage(script)
    if script._id and imageCache[script._id] then
        return imageCache[script._id]
    end

    local img

    -- 1) รูปที่ user ใส่เอง
    if script.image and script.image ~= "" then
        img = script.image

    -- 2) Roblox Game Thumbnail (ใช้ rbxthumb)
    elseif script.game and script.game._id then
        local placeId = tonumber(script.game._id)
        if placeId then
            img = ("rbxthumb://type=GameThumbnail&id=%d&w=420&h=420"):format(placeId)
        end
    end

    img = img or FALLBACK_IMAGE

    if script._id then
        imageCache[script._id] = img
    end

    return img
end

-- ========= UI ROOT (ต้องมีอยู่แล้ว) =========
-- sc = container (ScrollingFrame / Frame)
-- sea = main frame
-- sb = search button
-- tb = TextBox search
-- Corner(), Gradient() ต้องมี

-- ========= HELPERS =========
local function clearResults()
    for _, v in ipairs(sc:GetChildren()) do
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
        warn("[HTTP ERROR]", res)
        return nil
    end

    local success, data = pcall(function()
        return HttpService:JSONDecode(res)
    end)
    if not success then
        warn("[JSON ERROR]")
        return nil
    end

    return data
end

-- =========================
-- POPUP ANIMATION
-- =========================
local function playPopup(handle)
    local scale = Instance.new("UIScale")
    scale.Scale = 0
    scale.Parent = handle

    local t1 = TweenService:Create(
        scale,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Scale = 1.2 }
    )

    local t2 = TweenService:Create(
        scale,
        TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Scale = 1 }
    )

    t1:Play()
    t1.Completed:Wait()
    t2:Play()
    t2.Completed:Wait()
end

-- ========= --
local function asset(title, visits, likes, isUniversal, gameName, key, isPatched, verified, imageUrl, callback)
  local handle = Instance.new("Frame")
    handle.Name = "Handle"
    handle.Size = UDim2.new(0, 220, 0, 250)
    handle.BackgroundTransparency = 0.25
    handle.BackgroundColor3 = Color3.fromRGB(18,18,21)
    handle.Parent = sc
    Corner(0, 8, handle)
    Gradient(handle, 90,0,0, Color3.fromRGB(255,255,255), Color3.fromRGB(18,18,21))

    if key == true then
       handle.BackgroundColor3 = Color3.fromRGB(255, 108, 0)
    end  

    if isPatched == true then
       handle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end

    if verified == true then
       handle.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    end
  
  
    task.spawn(function()
        playPopup(handle)
    end)

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
    ima.Parent = ins      
    Corner(0,8,ima)
    ListLayout(ima, 0, 0, HLeft, VBottom, SLayout, FillV)

    ima.Image = (imageUrl and imageUrl ~= "") and imageUrl or FALLBACK_IMAGE

    -- KEY
    local keys = Instance.new("TextLabel")
    keys.Name = "KEY"
    keys.Size = UDim2.new(0.5,0,0,18)
    keys.BackgroundTransparency = 1
    keys.TextScaled = true
    keys.TextStrokeColor3 = Color3.fromRGB(255,255,255)
    keys.TextStrokeTransparency = 0
    keys.TextColor3 = Color3.fromRGB(255,85,0)
    keys.Text = "Key"
    keys.TextXAlignment = Enum.TextXAlignment.Left
    keys.Parent = ima

    if key == true then
       keys.Visible = true
    else
       keys.Visible = false
    end
  

    -- ISPATCH
    local pat = Instance.new("TextLabel")
    pat.Name = "Patched"
    pat.Size = UDim2.new(0.5,0,0,18)
    pat.BackgroundTransparency = 1
    pat.TextScaled = true
    pat.TextStrokeColor3 = Color3.fromRGB(255,255,255)
    pat.TextStrokeTransparency = 0
    pat.TextColor3 = Color3.fromRGB(255,0,0)
    pat.Text = "Patched"
    pat.TextXAlignment = Enum.TextXAlignment.Left
    pat.Parent = ima

    if isPatched == true then
       pat.Visible = true
    else
       pat.Visible = false
    end

   -- Verified
   local veri = Instance.new("TextLabel")
    veri.Name = "Verified"
    veri.Size = UDim2.new(0.5,0,0,18)
    veri.BackgroundTransparency = 1
    veri.TextScaled = true
    veri.TextStrokeColor3 = Color3.fromRGB(255,255,255)
    veri.TextStrokeTransparency = 0
    veri.TextColor3 = Color3.fromRGB(0,85,255)
    veri.Text = "Verified"
    veri.TextXAlignment = Enum.TextXAlignment.Left
    veri.Parent = ima

    if verified == true then
       veri.Visible = true
    else
       veri.Visible = false
    end       

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

    local uni = Instance.new("TextLabel")
    uni.Position = UDim2.new(0, 0, 0, 176)
    uni.Name = "IsUniversal"
    uni.Size = UDim2.new(1, 0, 0, 18)
    uni.BackgroundTransparency = 1
    uni.TextColor3 = Color3.fromRGB(255, 255, 255)
    uni.TextXAlignment = Enum.TextXAlignment.Left
    uni.TextScaled = true
    uni.Text = isUniversal and "Universal Script📌" or (gameName or "Unknown Game")
    uni.Parent = ins

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


-- ========= FETCH + RENDER =========
local function fetchAndRender(query)
    clearResults()
    loadedIds = {}

    local page = 1
    local loaded = 0
    local isSearch = (query and query ~= "")

    while loaded < TARGET_TOTAL do
        local url
        if isSearch then
            url = string.format(
                SCRIPTBLOX_SEARCH,
                HttpService:UrlEncode(query),
                page
            )
        else
            url = SCRIPTBLOX_HOME
        end

        local data = httpGetJson(url)
        if not data or not data.result then break end

        local scripts = data.result.scripts or {}
        if #scripts == 0 then break end

        for _, script in ipairs(scripts) do
            if loaded >= TARGET_TOTAL then break end

            -- ✅ กันซ้ำด้วย _id
            if script._id and loadedIds[script._id] then
                continue
            end
            loadedIds[script._id] = true

            local img = getScriptImage(script)
      
            asset(
                script.title or "Untitled",
                script.views or 0,
                script.likeCount or 0,
                script.isUniversal,
                script.game and script.game.name,
                script.key,
                script.isPatched,
                script.verified,
                img,
                function(action)
                    local source = script.script or ""
                    if action == "execute" then
                        local fn = loadstring(source)
                        if fn then fn() end
                    elseif action == "copy" then
                        if setclipboard then
                            setclipboard(source)
                        end
                    end
                end
            )

            loaded += 1
            task.wait(ITEM_DELAY)
        end

        -- 🔥 HOME ห้าม loop ต่อ
        if not isSearch then
            break
        end

        if not data.result.nextPage then break end
        page += 1
        task.wait(PAGE_DELAY)
    end
end

-- ========= WIRING =========
sb.MouseButton1Click:Connect(function()
    fetchAndRender(tb.Text)
end)

tb.FocusLost:Connect(function(enter)
    if enter then
        fetchAndRender(tb.Text)
    end
end)

-- ========= AUTO LOAD =========
fetchAndRender()


local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local scroll = CoreGui.ExperienceSettings.Menu.Search.scroll -- ตัว ScrollFrame
local MAX_COUNT = 220

-- ฟังก์ชันอัปเดต ScriptCounter
local function updateScriptCounter()
    if scroll and scroll.Parent then
        -- นับจำนวน Frame ที่ชื่อ Handle
        local handleCount = 0
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("Frame") and child.Name == "Handle" then
                handleCount = handleCount + 1
            end
        end

        sct.Text = "Script: " .. handleCount .. "/" .. MAX_COUNT
    else
        sct.Text = "Script: 0/" .. MAX_COUNT
    end
end

-- ตรวจสอบตลอดเวลา
RunService.RenderStepped:Connect(updateScriptCounter)
