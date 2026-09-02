-- searcher... yes. 10.0

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
local TextService = game:GetService("TextService")

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

local function tweenSize(obj, size, pos, backcol, time)
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(
            time,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {Size = size,
        Position = pos,
        BackgroundColor3 = backcol,
        }
    )

    tween:Play()
    return tween
end

-- =========================================
-- ScriptBlox Fetch
-- =========================================
local HttpService =
    game:GetService("HttpService")

local SCRIPTBLOX_API =
    "https://scriptblox.com/api/script/fetch"

local SCRIPTBLOX_INDIVIDUAL_API =
    "https://scriptblox.com/api/script/"

local ROOT = "ExperienceSettings"
local IMAGE_FOLDER = ROOT .. "/DownloadedImage"

-- ExperienceSettings
if not isfolder(ROOT) then
    makefolder(ROOT)
end

-- DownloadedImage
if not isfolder(IMAGE_FOLDER) then
    makefolder(IMAGE_FOLDER)
end

-- Locate  
local menu = CoreGui:WaitForChild("ExperienceSettings", 10):FindFirstChild("Menu")  
if not menu then return end  

--[[if menu.Search then
   menu.Search:Destroy()
end]]

-- =========================  
-- Main Frame  
-- =========================  
local sea = Instance.new("Frame")  
sea.Name = "Search"  
sea.Size = UDim2.new(0.8, 0, 0.8, 0)  
sea.Position = UDim2.new(0, 0, 1, 0)  
sea.BackgroundColor3 = Color3.fromRGB(18, 18, 21)  
sea.BackgroundTransparency = 0.3  
sea.BorderSizePixel = 8
sea.BorderMode = Enum.BorderMode.Inset
sea.Active = false 
sea.Parent = menu  
Corner(0, 8, sea)
Stroke(sea, ASMBorder, 255,255,255, LJMRound, 1, 0)
ListLayout(sea, 0, 5, HLeft, VCenter, SLayout, FillH)
  
local dear = Instance.new("TextLabel")
dear.Name = "Sorry!"
dear.BackgroundTransparency = 1
dear.RichText = true
dear.Active = false
dear.Visible = false
dear.TextWrapped = true
dear.Size = UDim2.new(1,0,1,0)
dear.TextSize = 23
dear.TextColor3 = Color3.new(1,1,1)
dear.Text = '<font size="50" color="rgb(255,0,0)">Sorry!</font> \n We are making the UI better than before and mobile friendly! \n <font size="10">From White the creator</font>'
dear.Parent = sea
  
local searchBtn =  
    menu.TopBar.Holder:WaitForChild("a4_Search")

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
        tweenSea(UDim2.new(0.1,0,1,0)) -- CLOSE  
    elseif searchBtn.Image == IMG_OPEN then  
        tweenSea(UDim2.new(0.1,0,0.15,0)) -- OPEN  
    end  
  end  
  
searchBtn:GetPropertyChangedSignal("Image"):Connect(updateState)  
updateState()  

local List = Instance.new("Frame")
List.Name = "List"
List.Size = UDim2.new(1,0,1,0)
List.BackgroundTransparency = 1
List.Active = false
List.Parent = sea

-----

local Page = List:Clone()
Page.Name = "Page"
Page.Size = UDim2.new(0,0,1,0)
Page.BorderMode = Enum.BorderMode.Inset
Page.BorderSizePixel = 5
Page.Visible = false
Page.Parent = sea

local InPage = Instance.new("ScrollingFrame")
InPage.Name = "InPage"
InPage.Size = UDim2.new(1,0,1,0)
InPage.BackgroundTransparency = 1
InPage.ScrollBarThickness = 0
InPage.ScrollingDirection = Enum.ScrollingDirection.Y
InPage.CanvasSize = UDim2.new(0,0,0,628)
InPage.Parent = Page

local vp = Instance.new("CanvasGroup")
vp.Name = "ViewPage"
vp.Size = UDim2.new(1,0,1,0)
vp.BackgroundColor3 = Color3.new(1,1,1)
vp.BorderMode = Enum.BorderMode.Inset
vp.BorderSizePixel = 5
vp.Active = false
vp.Parent = InPage
Corner(0,8,vp)
Gradient(vp, -90,0,0, Color3.fromRGB(170,0,255), Color3.fromRGB(255,85,255))

local imgview = Instance.new("ImageLabel")
imgview.Name = "ImageView"
imgview.BackgroundColor3 = Color3.new(1,1,1)
imgview.BackgroundTransparency = 0.5
imgview.Active = false
imgview.Size = UDim2.new(1,0,0,120)
imgview.Image = "rbxassetid://136962703149104"
imgview.ScaleType = Enum.ScaleType.Fit
imgview.Parent = vp
Corner(0,8,imgview)

local names = Instance.new("TextLabel")
names.Name = "NameOfScriptTitle"
names.Size = UDim2.new(1,0,0,20)
names.Position = UDim2.new(0,0,0,125)
names.TextXAlignment = Enum.TextXAlignment.Left
names.BackgroundTransparency = 1
names.TextScaled = true
names.RichText = true
names.Text = "<b>Script Title</b>"
names.Parent = vp

local types = names:Clone()
types.Name = "TypeScript"
types.RichText = false
types.Text = "📌 Universal Script"
types.Size = UDim2.new(1,0,0,13)
types.Position = UDim2.new(0,0,0,145)
types.Parent = vp

local cre = types:Clone()
cre.Name = "Creator"
cre.Position += UDim2.new(0,0,0,13)
cre.Text = "By @Username"
cre.Parent = vp

local credate = types:Clone()
credate.Name = "CreationDate"
credate.Position += UDim2.new(0,0,0,26)
credate.Text = "Creation Date: DD/MM/YYYY"
credate.Parent = vp

local like = Instance.new("TextLabel")
like.Name = "Likes"
like.Position = UDim2.new(0,0,0,188)
like.Size = UDim2.new(0.5,0,0,20)
like.BackgroundColor3 = Color3.fromRGB(0,170,255)
like.TextColor3 = Color3.new(1,1,1)
like.RichText = true
like.TextScaled = true
like.Text = "<b>Like: -</b>"
like.BorderMode = Enum.BorderMode.Inset
like.BorderSizePixel = 2
like.Parent = vp
Corner(0,3,like)

local dislike = Instance.new("TextLabel")
dislike.Name = "Dislikes"
dislike.Position = UDim2.new(1,0,0,188)
dislike.Size = UDim2.new(-0.5,0,0,20)
dislike.BackgroundColor3 = Color3.fromRGB(255,0,0)
dislike.TextColor3 = Color3.new(1,1,1)
dislike.RichText = true
dislike.TextScaled = true
dislike.Text = "<b>Dislike: -</b>"
dislike.BorderMode = Enum.BorderMode.Inset
dislike.BorderSizePixel = 2
dislike.Parent = vp
Corner(0,3,dislike)

local visit = Instance.new("TextLabel")
visit.Name = "Visits"
visit.Position = UDim2.new(0,0,0,210)
visit.Size = UDim2.new(1,0,0,20)
visit.BackgroundColor3 = Color3.fromRGB(255,85,0)
visit.TextColor3 = Color3.new(1,1,1)
visit.RichText = true
visit.TextScaled = true
visit.Text = "<b>Visit: -</b>"
visit.BorderMode = Enum.BorderMode.Inset
visit.BorderSizePixel = 2
visit.Parent = vp
Corner(0,3,visit)

local fea = names:Clone()
fea.Name = "Features"
fea.Position = UDim2.new(0,0,0,233)
fea.Text = "<b>Description</b>"
fea.Parent = vp

local feascroll = Instance.new("ScrollingFrame")
feascroll.Name = "FeaturesScroll"
feascroll.Position = UDim2.new(0,0,0,258)
feascroll.Size = UDim2.new(1,0,0,100)
feascroll.BackgroundColor3 = Color3.new(0,0,0)
feascroll.ScrollBarThickness = 10
feascroll.BackgroundTransparency = 0.8
feascroll.ScrollingDirection = Enum.ScrollingDirection.Y
feascroll.BorderMode = Enum.BorderMode.Inset
feascroll.BorderSizePixel = 5
feascroll.CanvasSize = UDim2.new(0,0,30,0)
feascroll.Parent = vp
Corner(0,3,feascroll)

local feabox = Instance.new("TextBox")
feabox.Name = "FeaturesBox"
feabox.Position = UDim2.new(0,0,0,0)
feabox.Size = UDim2.new(1,-11,1,0)
feabox.BackgroundTransparency = 1
feabox.TextColor3 = Color3.new(1,1,1)
feabox.ClearTextOnFocus = false
feabox.PlaceholderText = "No description yet."
feabox.PlaceholderColor3 = Color3.new(1,1,1)
feabox.Text = ""
feabox.TextSize = 8
feabox.TextWrapped = true
feabox.TextXAlignment = Enum.TextXAlignment.Left
feabox.TextYAlignment = Enum.TextYAlignment.Top
feabox.TextEditable = false
feabox.Parent = feascroll

local tags = names:Clone()
tags.Name = "Tags"
tags.Position = UDim2.new(0,0,0,363)
tags.Text = "<b>Tag</b>"
tags.Parent = vp

local tagscroll = Instance.new("ScrollingFrame")
tagscroll.Name = "TagScroll"
tagscroll.Position = UDim2.new(0,0,0,386)
tagscroll.Size = UDim2.new(1,0,0,30)
tagscroll.BackgroundColor3 = Color3.new(0,0,0)
tagscroll.ScrollBarThickness = 2
tagscroll.BackgroundTransparency = 0.8
tagscroll.ScrollingDirection = Enum.ScrollingDirection.X
tagscroll.BorderMode = Enum.BorderMode.Inset
tagscroll.BorderSizePixel = 5
tagscroll.CanvasSize = UDim2.new(0,0,0,0)
tagscroll.Parent = vp
Corner(0,3,tagscroll)
ListLayout(tagscroll, 0, 3, HLeft, VTop, SLayout, FillH)

local tagLayout = tagscroll:FindFirstChildOfClass("UIListLayout")

local function updateTagCanvas()
    if not tagLayout or not tagLayout.Parent then
        return
    end

    local content = tagLayout.AbsoluteContentSize

    tagscroll.CanvasSize = UDim2.new(
        0,
        math.ceil(content.X),
        0,
        math.ceil(content.Y)
    )
end

local function tagss(string)
    local text = tostring(string)

    local tag = Instance.new("TextLabel")
    tag.Name = "TagString"

    tag.Text = text
    tag.TextSize = 12
    tag.Font = Enum.Font.SourceSans

    tag.TextXAlignment = Enum.TextXAlignment.Center
    tag.TextYAlignment = Enum.TextYAlignment.Center

    local bounds = TextService:GetTextSize(
        text,
        tag.TextSize,
        tag.Font,
        Vector2.new(math.huge, math.huge)
    )

    local padding = 10

    tag.Size = UDim2.new(
        0,
        math.ceil(bounds.X) + padding,
        1,
        -2
    )

    tag.BackgroundColor3 = Color3.fromRGB(170,255,255)
    tag.BorderMode = Enum.BorderMode.Inset
    tag.BorderSizePixel = 5
    tag.Active = false
    tag.Parent = tagscroll

    Corner(0,3,tag)

    task.defer(updateTagCanvas)
end

tagLayout:GetPropertyChangedSignal("AbsoluteContentSize")
    :Connect(updateTagCanvas)

task.defer(updateTagCanvas)

local rs = names:Clone()
rs.Name = "RawScript"
rs.Position = UDim2.new(0,0,1,-198)
rs.Text = "<b>Raw Script</b>"
rs.Parent = vp

local codescroll = Instance.new("ScrollingFrame")
codescroll.Name = "CodeScroll"
codescroll.Position = UDim2.new(0,0,1,-175)
codescroll.Size = UDim2.new(1,0,0,100)
codescroll.BackgroundColor3 = Color3.new(0,0,0)
codescroll.ScrollBarThickness = 10
codescroll.ScrollingDirection = Enum.ScrollingDirection.Y
codescroll.BorderMode = Enum.BorderMode.Inset
codescroll.BorderSizePixel = 5
codescroll.CanvasSize = UDim2.new(0,0,30,0)
codescroll.Parent = vp
Corner(0,3,codescroll)

local codebox = Instance.new("TextBox")
codebox.Name = "CodeBox"
codebox.Position = UDim2.new(0,0,0,0)
codebox.Size = UDim2.new(1,-11,1,0)
codebox.BackgroundTransparency = 1
codebox.TextColor3 = Color3.new(0,1,0)
codebox.Font = Enum.Font.Code
codebox.ClearTextOnFocus = false
codebox.PlaceholderText = "Hmm... Looks like there's no source code in here. Please make sure you select the script or the owner didn't put a source code yet."
codebox.PlaceholderColor3 = Color3.new(1,1,1)
codebox.Text = ""
codebox.TextSize = 11
codebox.TextWrapped = true
codebox.TextXAlignment = Enum.TextXAlignment.Left
codebox.TextYAlignment = Enum.TextYAlignment.Top
codebox.TextEditable = false
codebox.Parent = codescroll

local exe = Instance.new("TextButton")
exe.Name = "Execute"
exe.Size = UDim2.new(1,0,0,20)
exe.Position = UDim2.new(0,0,1,-70)
exe.BackgroundColor3 = Color3.fromRGB(255,0,128)
exe.TextColor3 = Color3.new(1,1,1)
exe.TextScaled = true
exe.RichText = true
exe.BorderMode = Enum.BorderMode.Inset
exe.BorderSizePixel = 2
exe.Text = "<b>Execute</b>"
exe.Parent = vp
Corner(0,3,exe)

local cy = Instance.new("TextButton")
cy.Name = "Copy"
cy.Size = UDim2.new(1,0,0,20)
cy.Position = UDim2.new(0,0,1,-46)
cy.BackgroundColor3 = Color3.fromRGB(145,0,255)
cy.TextColor3 = Color3.new(1,1,1)
cy.TextScaled = true
cy.RichText = true
cy.BorderMode = Enum.BorderMode.Inset
cy.BorderSizePixel = 2
cy.Text = "<b>Copy To Clipboard</b>"
cy.Parent = vp
Corner(0,3,cy)

local backs = Instance.new("TextButton")
backs.Name = "ClosePage"
backs.Size = UDim2.new(1,0,0,20)
backs.Position = UDim2.new(0,0,1,-20)
backs.BackgroundColor3 = Color3.new(1,0,0)
backs.TextColor3 = Color3.new(1,1,1)
backs.TextXAlignment = Enum.TextXAlignment.Right
backs.BorderMode = Enum.BorderMode.Inset
backs.BorderSizePixel = 4
backs.RichText = true
backs.TextScaled = true
backs.Text = "<b>Back »</b>"
backs.Parent = vp
Corner(0,8,backs)

------

local tb = Instance.new("TextBox")
tb.Name = "SearchInput"
tb.Size = UDim2.new(1,0,0,45)
tb.BackgroundColor3 = Color3.fromRGB(0,170,255)
tb.BackgroundTransparency = 0.3
tb.BorderMode = Enum.BorderMode.Inset
tb.BorderSizePixel = 6
tb.TextSize = 16
tb.TextWrapped = true
tb.Text = ""
tb.PlaceholderText = "Search here!"
tb.PlaceholderColor3 = Color3.new(0,0,0)
tb.TextColor3 = Color3.new(1,1,1)
tb.TextXAlignment = Enum.TextXAlignment.Left
tb.Parent = List
Corner(0,8,tb)

local filter = Instance.new("ImageButton")
filter.Name = "Filter"
filter.Position = UDim2.new(1,-35,0,0)
filter.Size = UDim2.new(0,35,0,35)
filter.BackgroundColor3 = Color3.new(1,1,1)
filter.BackgroundTransparency = 0.3
filter.Image = "rbxassetid://134089160838664"
filter.Parent = tb

Corner(0,3,filter)
Stroke(filter, ASMBorder, 255, 255, 255, LJMRound, 1 ,0)
Gradient(filter, -45 ,0,0, Color3.fromRGB(85,255,0), Color3.fromRGB(255,255,0))

local tb_str = Stroke(tb,ASMBorder, 255,255,255, LJMRound, 2, 0)
Gradient(tb_str, 90, 0,0, Color3.fromRGB(255,255,255), Color3.fromRGB(0,255,255))

local refresh = Instance.new("ImageButton")
refresh.Name = "Refresh"
refresh.Position = UDim2.new(1,-75,0,0)
refresh.Size = UDim2.new(0,35,0,35)
refresh.BackgroundColor3 = Color3.new(1,1,1)
refresh.BackgroundTransparency = 0.3
refresh.Image = "rbxassetid://133018773942204"
refresh.Parent = tb

Corner(0,3,refresh)
Stroke(refresh, ASMBorder, 255, 255, 255, LJMRound, 1 ,0)
Gradient(refresh, -45 ,0,0, Color3.fromRGB(255,85,0), Color3.fromRGB(255,255,0))

local filter_body = Instance.new("Frame")
filter_body.Name = "FilterBody"
filter_body.Size = UDim2.new(0,0,0,150)
filter_body.Position = UDim2.new(0,-305,1,5)
filter_body.BackgroundColor3 = Color3.fromRGB(0,85,0)
filter_body.BorderMode = Enum.BorderMode.Inset
filter_body.BorderSizePixel = 5
filter_body.ZIndex = 2
filter_body.Visible = false
filter_body.Parent = filter
Corner(0,8,filter_body)
ListLayout(filter_body, 0,2, HCenter, VTop, SLayout, FillV)

-- =========================================
-- Filter System
-- =========================================

local switches = {}

local filterType = {
    ScriptType = "Default",
    IsUniversal = "Default",
    Verified = "Default",
    Patched = "Default",
    Key = "Default"
}

-- =========================================
-- Sort System
-- =========================================

local sortType = "Default"
local sortOrder = "Default"

local sortByStates = {
    "Default",
    "Views",
    "Likes",
    "Dislikes",
    "Creation Date",
    "Update Date",
    "Match Accuracy"
}

local sortOrderStates = {
    "Default",
    "Ascending",
    "Descending"
}

local sortByIndex = 1
local sortOrderIndex = 1

-- =========================================
-- Filter Colors
-- =========================================

local FILTER_COLORS = {
    Default = Color3.fromRGB(128,128,128),
    With = Color3.fromRGB(0,255,0),
    Without = Color3.fromRGB(255,0,0),

    Free = Color3.fromRGB(0,255,0),
    Paid = Color3.fromRGB(170,85,0)
}

-- =========================================
-- Create Filter
-- =========================================

local function type_(type, key)

    -- =====================================
    -- Body
    -- =====================================

    local body = Instance.new("TextLabel")

    body.Name = "Body"
    body.Size = UDim2.new(1,0,0,30)

    body.BackgroundColor3 =
        Color3.fromRGB(0,163,0)

    body.TextXAlignment =
        Enum.TextXAlignment.Left

    body.TextColor3 =
        Color3.new(1,1,1)

    body.Text =
        "<b>" .. tostring(type) .. "</b>"

    body.RichText = true

    body.TextScaled = true

    body.BorderMode =
        Enum.BorderMode.Inset

    body.BorderSizePixel = 5

    body.ZIndex = 2

    body.Parent = filter_body

    Corner(0,5,body)

    -- =====================================
    -- Switch
    -- =====================================

    local switch = Instance.new("TextButton")

    switch.Name = "Switch"

    -- 20 × 20 Offset
    switch.Size =
        UDim2.new(0,20,0,20)

    switch.Position =
        UDim2.new(1,-20,0,0)

    switch.BackgroundColor3 =
        FILTER_COLORS.Default

    switch.ZIndex = 2

    -- No Text
    switch.Text = ""

    switch.Parent = body

    Corner(0,3,switch)

    switches[key] = switch

    -- =====================================
    -- States
    -- =====================================

    local states

    if key == "ScriptType" then

        states = {
            "Default",
            "Free",
            "Paid"
        }

    else

        states = {
            "Default",
            "With",
            "Without"
        }

    end

    local stateIndex = 1

    -- =====================================
    -- Switch Click
    -- =====================================

    switch.MouseButton1Click:Connect(function()

        stateIndex += 1

        if stateIndex > #states then
            stateIndex = 1
        end

        local state =
            states[stateIndex]

        filterType[key] =
            state

        -- Change color only
        tweenSize(
            switch,
            nil,
            nil,
            FILTER_COLORS[state],
            0.1
        )

    end)

end

-- =========================================
-- Create Filters
-- =========================================

type_("Script Type (Default/Free/Paid)", "ScriptType")
type_("Universal", "IsUniversal")
type_("Verified", "Verified")
type_("Patched", "Patched")
type_("Key", "Key")


-- =========================================
-- Sort UI
-- =========================================

local sortContainer = Instance.new("Frame")

sortContainer.Name = "SortContainer"

sortContainer.Size =
    UDim2.new(1,0,0,35)

sortContainer.BackgroundTransparency = 1

sortContainer.ZIndex = 2

sortContainer.Parent = filter_body


-- =========================================
-- Sort By Button
-- =========================================

local sortBy = Instance.new("TextButton")

sortBy.Name = "SortBy"

sortBy.Size =
    UDim2.new(0.5,-3,0,30)

sortBy.Position =
    UDim2.new(0,0,0,0)

sortBy.BackgroundColor3 =
    Color3.fromRGB(255,255,0)

sortBy.TextColor3 =
    Color3.new(0,0,0)

sortBy.RichText = true

sortBy.TextScaled = true

sortBy.Text =
    "<b>Sort by: Default</b>"

sortBy.BorderMode =
    Enum.BorderMode.Inset

sortBy.BorderSizePixel = 3

sortBy.ZIndex = 2

sortBy.Parent = sortContainer

Corner(0,5,sortBy)

-- =========================================
-- Sort Order Button
-- =========================================

local sortOrderButton = Instance.new("TextButton")

sortOrderButton.Name = "SortOrder"

sortOrderButton.Size =
    UDim2.new(0.5,-3,0,30)

sortOrderButton.Position =
    UDim2.new(0.5,3,0,0)

sortOrderButton.BackgroundColor3 =
    Color3.fromRGB(0,255,255)

sortOrderButton.TextColor3 =
    Color3.new(0,0,0)

sortOrderButton.RichText = true
sortOrderButton.TextScaled = true

sortOrderButton.Text =
    "<b>Sort order: Default</b>"

sortOrderButton.BorderMode =
    Enum.BorderMode.Inset

sortOrderButton.BorderSizePixel = 3

sortOrderButton.ZIndex = 2

sortOrderButton.Parent = sortContainer

Corner(0,5,sortOrderButton)

-- =========================================
-- Sort By Click
-- =========================================

sortBy.MouseButton1Click:Connect(function()

    sortByIndex += 1

    if sortByIndex > #sortByStates then
        sortByIndex = 1
    end

    sortType =
        sortByStates[sortByIndex]

    sortBy.Text =
        "<b>Sort by: "
        .. sortType
        .. "</b>"

end)


-- =========================================
-- Sort Order Click
-- =========================================

sortOrderButton.MouseButton1Click:Connect(function()

    sortOrderIndex += 1

    if sortOrderIndex > #sortOrderStates then
        sortOrderIndex = 1
    end

    sortOrder =
        sortOrderStates[sortOrderIndex]

    sortOrderButton.Text =
        "<b>Sort order: "
        .. sortOrder
        .. "</b>"

end)

local fil_sw = false  
  
filter.MouseButton1Click:Connect(function()  
    if not fil_sw then  
      fil_sw = true  
      filter_body.Visible = true  
      tweenSize(filter_body, UDim2.new(0,350,0,200),nil,nil,0.3).Completed:Wait()
    else  
      fil_sw = false  
      tweenSize(filter_body, UDim2.new(0,0,0,200),nil,nil,0.3).Completed:Wait()
      filter_body.Visible = false  
    end  
end)
  
local scr = Instance.new("ScrollingFrame")
scr.Name = "Scrips"
scr.Position = UDim2.new(0,0,0,50)
scr.Size = UDim2.new(1,0,1,-50)
scr.BackgroundColor3 = Color3.new(255,255,255)
scr.BackgroundTransparency = 0.7
scr.ScrollBarThickness = 2
-- scr.CanvasSize = UDim2.new(0,0,0,0)
scr.Parent = List
Corner(0,8,scr)
Gradient(scr, 0,0,0, Color3.fromRGB(0,0,172), Color3.fromRGB(0,255,255))
ListLayout(scr, 0, 4, HLeft, VTop, SLayout, FillV)


local function updateCanvas()
    local layout = scr:FindFirstChildOfClass("UIListLayout")

    if layout then
        scr.CanvasSize = UDim2.new(
            0,
            0,
            0,
            layout.AbsoluteContentSize.Y + 5
        )
    end
end

local scrLayout = scr:FindFirstChildOfClass("UIListLayout")

if scrLayout then
    scrLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
end

dear.Parent = scr
dear.Visible = false

local back = Instance.new("TextButton")
back.Name = "Back"
back.Size = UDim2.new(0.98,0,0,50)
back.Position = UDim2.new(0.5,-100,0.8,0)
back.BackgroundColor3 = Color3.new(1,0,0)
back.TextSize = 16
back.RichText = true
back.TextWrapped = true
back.LayoutOrder = 3
back.TextColor3 = Color3.new(1,1,1)
back.Text = "Switch back to the <b>Old UI</b>?"
back.Parent = scr
Corner(0,8,back)
local bk_str = Stroke(back, ASMBorder, 100,0,0, LJMRound, 3, 0)
bk_str.BorderStrokePosition = Enum.BorderStrokePosition.Inner

back.MouseButton1Click:Connect(function()
    sea:Destroy()
    wait(0.5) 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/397db6d363933259c69d4683830484f67e13b28b/Search.lua"))()
end)

back.Visible = false -- FALSE FOR FULLY VERSION

-----

-- =========================================
-- Preview Image
-- =========================================

local FALLBACK_IMAGE =
    "rbxassetid://136962703149104"

-- =========================================
-- Preview Image - Search
-- =========================================

local function getSearchPreviewImage(data)
    if data and data.isUniversal == true then
        return FALLBACK_IMAGE
    end

    local game = data and data.game

    if type(game) ~= "table" then
        return FALLBACK_IMAGE
    end

    local gameId = game.gameId or game.placeId

    if gameId then
        return "rbxthumb://type=GameThumbnail&id="
            .. tostring(gameId)
            .. "&w=480&h=270"
    end

    return FALLBACK_IMAGE
end

-- =========================================
-- Preview Image - Fetch
-- =========================================

local function getFetchPreviewImage(data)

    local game = data and data.game

    local gameId = tonumber(
        game and (game.placeId or game.gameId)
    )

    if gameId then
        return string.format(
            "https://assetgame.roblox.com/Game/Tools/ThumbnailAsset.ashx?aid=%d&fmt=png&wd=420&ht=420",
            gameId
        )
    end

    if type(data.image) == "string"
        and data.image ~= ""
        and data.image:sub(1, 1) == "/" then

        return "https://scriptblox.com" .. data.image
    end

    return FALLBACK_IMAGE
end

-- =========================================
-- ScriptBlox Individual
-- =========================================

local function fetchIndividual(scriptId)

    if not scriptId then
        return nil
    end

    local success, response = pcall(function()

        return game:HttpGet(
            SCRIPTBLOX_INDIVIDUAL_API
            .. tostring(scriptId)
        )

    end)

    if not success then
        return nil
    end


    local jsonSuccess, result = pcall(function()

        return HttpService:JSONDecode(
            response
        )

    end)

    if not jsonSuccess then
        return nil
    end


    if not result
        or not result.script then

        return nil
    end


    return result.script
end


-- =========================================
-- Script Card
-- =========================================

local function sipt(data)

    -- =====================================
    -- Body
    -- =====================================

    local body = Instance.new("Frame")

    body.Name = "Body"
    body.Size = UDim2.new(0.98,0,0,130)
    body.BorderMode = Enum.BorderMode.Inset
    body.BackgroundColor3 = Color3.new(1,1,1)
    body.BorderSizePixel = 7
    body.Parent = scr

    Corner(0,8,body)


    local bd_str = Stroke(
        body,
        ASMBorder,
        255,255,255,
        LJMRound,
        3,
        0
    )

    bd_str.BorderStrokePosition =
        Enum.BorderStrokePosition.Inner


    Gradient(
        body,
        0,
        0,
        0,
        Color3.fromRGB(0,255,255),
        Color3.fromRGB(170,0,255)
    )


    -- =====================================
    -- State
    -- =====================================

    local state = Instance.new("Frame")

    state.Name = "State"
    state.Position = UDim2.new(0,0,0,90)
    state.Size = UDim2.new(1,0,0,25)
    state.BackgroundTransparency = 1
    state.Parent = body

    ListLayout(
        state,
        0,
        3,
        HLeft,
        VCenter,
        SLayout,
        FillH
    )


    -- =====================================
    -- Verified
    -- =====================================

    local Verified = Instance.new("TextLabel")

    Verified.Name = "Verified"
    Verified.Size = UDim2.new(0,100,1,0)
    Verified.BackgroundTransparency = 0.3
    Verified.BackgroundColor3 =
        Color3.fromRGB(0,85,255)

    Verified.TextColor3 =
        Color3.fromRGB(0,255,255)

    Verified.TextSize = 13
    Verified.RichText = true
    Verified.Text = "<b>Verified</b>"

    Verified.Visible =
        data.verified == true

    Verified.Active = false
    Verified.Parent = state

    Corner(0,8,Verified)


    -- =====================================
    -- Key
    -- =====================================

    local Key = Instance.new("TextLabel")

    Key.Name = "Key"
    Key.Size = UDim2.new(0,60,1,0)
    Key.BackgroundTransparency = 0.3
    Key.BackgroundColor3 =
        Color3.fromRGB(255,170,0)

    Key.TextColor3 =
        Color3.fromRGB(255,255,0)

    Key.TextSize = 13
    Key.RichText = true
    Key.Text = "<b>Key</b>"

    Key.Visible =
        data.key == true

    Key.Active = false
    Key.Parent = state

    Corner(0,8,Key)


    -- =====================================
    -- Patched
    -- =====================================

    local Patched = Instance.new("TextLabel")

    Patched.Name = "Patched"
    Patched.Size = UDim2.new(0,100,1,0)
    Patched.BackgroundTransparency = 0.3
    Patched.BackgroundColor3 =
        Color3.fromRGB(170,0,0)

    Patched.TextColor3 =
        Color3.fromRGB(255,0,0)

    Patched.TextSize = 13
    Patched.RichText = true
    Patched.Text = "<b>Patched</b>"

    Patched.Visible =
        data.isPatched == true

    Patched.Active = false
    Patched.Parent = state

    Corner(0,8,Patched)


    -- =====================================
    -- Free
    -- =====================================

    local Free = Instance.new("TextLabel")

    Free.Name = "Free"
    Free.Size = UDim2.new(0,70,1,0)
    Free.BackgroundTransparency = 0.3
    Free.BackgroundColor3 =
        Color3.fromRGB(0,170,0)

    Free.TextColor3 =
        Color3.fromRGB(0,255,0)

    Free.TextSize = 13
    Free.RichText = true
    Free.Text = "<b>Free</b>"

    Free.Visible =
        data.scriptType == "free"

    Free.Active = false
    Free.Parent = state

    Corner(0,8,Free)


    -- =====================================
    -- Paid
    -- =====================================

    local Paid = Instance.new("TextLabel")

    Paid.Name = "Paid"
    Paid.Size = UDim2.new(0,70,1,0)
    Paid.BackgroundTransparency = 0.3
    Paid.BackgroundColor3 =
        Color3.fromRGB(170,85,0)

    Paid.TextColor3 =
        Color3.fromRGB(255,85,0)

    Paid.TextSize = 13
    Paid.RichText = true
    Paid.Text = "<b>Paid</b>"

    Paid.Visible =
        data.scriptType == "paid"

    Paid.Active = false
    Paid.Parent = state

    Corner(0,8,Paid)


    -- =====================================
    -- Preview
    -- =====================================

    local Img = Instance.new("ImageLabel")

    Img.Name = "Preview"
    Img.Size = UDim2.new(0,153,0,85)

    Img.BackgroundColor3 =
        Color3.new(1,1,1)

    Img.ScaleType =
        Enum.ScaleType.Fit

    Img.Image =
        getFetchPreviewImage(data)

    Img.Parent = body

    Corner(0,3,Img)


    -- =====================================
    -- Game Name
    -- =====================================

    local gameName =
        "Universal Script"

    if data.game
        and type(data.game) == "table"
        and data.game.name
        and tostring(data.game.name) ~= "" then

        gameName =
            tostring(data.game.name)
    end


    -- =====================================
    -- Details
    -- =====================================

    local de = Instance.new("TextLabel")

    de.Name = "Details"
    de.BackgroundTransparency = 1
    de.Position = UDim2.new(0,155,0,0)
    de.Size = UDim2.new(1,-270,0,30)

    de.TextXAlignment =
        Enum.TextXAlignment.Left

    de.TextYAlignment =
        Enum.TextYAlignment.Top

    de.RichText = true
    de.TextWrapped = true

    de.TextColor3 =
        Color3.new(0,0,0)


    local title =
        tostring(
            data.title
            or "Untitled Script"
        )


    local owner = "Unknown"

    if data.owner
        and type(data.owner) == "table"
        and data.owner.username then

        owner =
            tostring(
                data.owner.username
            )

    elseif data.owner
        and tostring(data.owner) ~= "" then

        owner =
            tostring(data.owner)
    end


    de.Text =
        "<font size='12'><b>"
        .. title
        .. "</b></font>\n"
        .. gameName
        .. "\n"
        .. "By @"
        .. owner
        .. "\n"
        .. "Click 'View' for more details."

    de.Parent = body


    -- =====================================
    -- View Button
    -- =====================================

    local view =
        Instance.new("TextButton")

    view.Name =
        "ViewButton"

    view.Position =
        UDim2.new(1,-100,0,0)

    view.Size =
        UDim2.new(0,100,0,35)

    view.BackgroundColor3 =
        Color3.new(1,1,1)

    view.TextColor3 =
        Color3.new(0,0,0)

    view.TextSize = 16
    view.RichText = true

    view.Text =
        "<b><i>View</i></b>"

    view.Parent = body

    Corner(0,3,view)


    Gradient(
        view,
        -45,
        0,
        0,
        Color3.fromRGB(0,255,85),
        Color3.fromRGB(255,255,0)
    )


    Stroke(
        view,
        ASMBorder,
        255,255,255,
        LJMRound,
        2,
        0
    )


    view:SetAttribute(
        "ScriptTitle",
        title
    )


    -- =====================================
    -- View Click
    -- =====================================

    view.MouseButton1Click:Connect(function()

        -- ---------------------------------
        -- Button animation
        -- ---------------------------------

        tweenSize(
            view,
            UDim2.new(0,80,0,15),
            nil,
            nil,
            0.1
        ).Completed:Wait()


        tweenSize(
            view,
            UDim2.new(0,100,0,35),
            nil,
            nil,
            0.1
        )


-- =================================
-- Open Page
-- =================================

Page.Visible = true

tweenSize(
    Page,
    UDim2.new(0.35,-5,1,0),
    nil,
    nil,
    0.4
)

tweenSize(
    List,
    UDim2.new(0.65,0,1,0),
    nil,
    nil,
    0.4
)

-- =================================
-- Loading State
-- =================================

names.Text = "<b>Loading Data...</b>"
types.Text = "Loading Data..."
cre.Text = "Loading Data..."
credate.Text = "Loading Data..."

like.Text = "<b>Like: Loading Data...</b>"
dislike.Text = "<b>Dislike: Loading Data...</b>"
visit.Text = "<b>Visit: Loading Data...</b>"

feabox.Text = "Loading Data..."
codebox.Text = "Loading Data..."

imgview.Image = FALLBACK_IMAGE

-- =================================
-- Clear Old Tags
-- =================================

for _, child in ipairs(tagscroll:GetChildren()) do
    if child.Name == "TagString" then
        child:Destroy()
    end
end

tagscroll.CanvasSize =
    UDim2.new(0,0,0,0)

-- =================================
-- Fetch Individual
-- =================================

local detail = fetchIndividual(data._id)

if not detail then
    detail = data
end

        -- ---------------------------------
        -- Fallback
        -- ---------------------------------

        if not detail then
            detail = data
        end


        -- ---------------------------------
        -- Title
        -- ---------------------------------

        local detailTitle =
            tostring(
                detail.title
                or data.title
                or "Untitled Script"
            )


        -- ---------------------------------
        -- Owner
        -- ---------------------------------

        local detailOwner =
            "Unknown"


        if detail.owner
            and type(detail.owner) == "table"
            and detail.owner.username then

            detailOwner =
                tostring(
                    detail.owner.username
                )

        elseif detail.owner
            and tostring(detail.owner) ~= "" then

            detailOwner =
                tostring(detail.owner)
        end


        -- ---------------------------------
        -- Game Name
        -- ---------------------------------

        local detailGameName =
            "Universal Script"


        if detail.game
            and type(detail.game) == "table"
            and detail.game.name
            and tostring(detail.game.name) ~= "" then

            detailGameName =
                tostring(detail.game.name)
        end


        -- ---------------------------------
        -- Image
        -- ---------------------------------

        imgview.Image =
            getSearchPreviewImage(detail)


        -- ---------------------------------
        -- Title
        -- ---------------------------------

        names.Text =
            "<b>"
            .. detailTitle
            .. "</b>"


        -- ---------------------------------
        -- Game
        -- ---------------------------------

        types.Text =
            ""..
            detailGameName


        -- ---------------------------------
        -- Creator
        -- ---------------------------------

        cre.Text =
            "By @"
            .. detailOwner


        -- ---------------------------------
        -- Likes
        -- ---------------------------------

        like.Text =
            "<b>Like: "
            .. tostring(
                detail.likeCount
                or 0
            )
            .. "</b>"


        -- ---------------------------------
        -- Dislikes
        -- ---------------------------------

        dislike.Text =
            "<b>Dislike: "
            .. tostring(
                detail.dislikeCount
                or 0
            )
            .. "</b>"


        -- ---------------------------------
        -- Views
        -- ---------------------------------

        visit.Text =
            "<b>Visit: "
            .. tostring(
                detail.views
                or 0
            )
            .. "</b>"



        -- ---------------------------------
        -- Creation Date
        -- ---------------------------------

        local creationDate = "Unknown"

        if detail.createdAt then
            local timestamp = tostring(detail.createdAt)

            -- ตรงนี้ค่อยแปลง timestamp เป็น DD/MM/YYYY
            creationDate = timestamp
        end

        credate.Text =
            "Creation Date: "
            .. creationDate


        -- ---------------------------------
        -- Features / Description
        -- ---------------------------------

        local features =
            tostring(
                detail.features
                or ""
            )

        if features == "" then
            feabox.Text = ""
            feabox.PlaceholderText =
                "No description yet."
        else
            feabox.Text = features
        end


        -- ---------------------------------
        -- Tags
        -- ---------------------------------

        for _, child in ipairs(tagscroll:GetChildren()) do
            if child:IsA("TextLabel")
                and child.Name == "TagString" then

                child:Destroy()
            end
        end

        if type(detail.tags) == "table" then
            for _, tagName in ipairs(detail.tags) do
                tagss(tagName)
            end
        end
      
        -- ---------------------------------
        -- Source
        -- ---------------------------------

        codebox.Text =
            tostring(
                detail.script
                or ""
            )

    end)

end

local currentPage = 1
local loading = false
local loadMoreButton = nil
local fetchScripts


-- =========================================
-- Load More Button
-- =========================================

local function load()

    if loadMoreButton then
        loadMoreButton:Destroy()
        loadMoreButton = nil
    end

    local lm = Instance.new("TextButton")
    lm.Name = "LoadMore"
    lm.Size = UDim2.new(0.98,0,0,50)
    lm.Position = UDim2.new(0.5,-100,0.8,0)
    lm.BackgroundColor3 = Color3.new(0.5,0.5,0.5)
    lm.TextSize = 16
    lm.RichText = true
    lm.TextWrapped = true
    lm.LayoutOrder = 2
    lm.TextColor3 = Color3.new(1,1,1)
    lm.Text = "Load More"
    lm.Parent = scr

    Corner(0,8,lm)

    local lm_str = Stroke(
        lm,
        ASMBorder,
        60,60,60,
        LJMRound,
        3,
        0
    )

    lm_str.BorderStrokePosition =
        Enum.BorderStrokePosition.Inner

    loadMoreButton = lm

    lm.MouseButton1Click:Connect(function()

        if loading then
            return
        end

        lm.Text = "Loading..."

        local nextPage = currentPage + 1

        local success = fetchScripts(nextPage)

        if success then
            currentPage = nextPage
        else
            lm.Text = "Load More"
        end
    end)
end

local function buildSearchURL(page)

    local query = tb.Text or ""
    query = query:gsub("^%s+", ""):gsub("%s+$", "")

    local params = {}

    table.insert(
        params,
        "page=" .. tostring(page)
    )

    table.insert(
        params,
        "max=20"
    )

    -- Search
    if query ~= "" then
        table.insert(
            params,
            "q=" .. HttpService:UrlEncode(query)
        )
    end

    -- ScriptType
    if filterType.ScriptType == "Free" then

        table.insert(
            params,
            "mode=free"
        )

    elseif filterType.ScriptType == "Paid" then

        table.insert(
            params,
            "mode=paid"
        )
    end

    -- Universal
    if filterType.IsUniversal == "With" then

        table.insert(
            params,
            "universal=1"
        )

    elseif filterType.IsUniversal == "Without" then

        table.insert(
            params,
            "universal=0"
        )
    end

    -- Verified
    if filterType.Verified == "With" then

        table.insert(
            params,
            "verified=1"
        )

    elseif filterType.Verified == "Without" then

        table.insert(
            params,
            "verified=0"
        )
    end

    -- Patched
    if filterType.Patched == "With" then

        table.insert(
            params,
            "patched=1"
        )

    elseif filterType.Patched == "Without" then

        table.insert(
            params,
            "patched=0"
        )
    end

    -- Key
    if filterType.Key == "With" then

        table.insert(
            params,
            "key=1"
        )

    elseif filterType.Key == "Without" then

        table.insert(
            params,
            "key=0"
        )
    end

if sortType == "Views" then
    table.insert(params, "sortBy=views")

elseif sortType == "Likes" then
    table.insert(params, "sortBy=likeCount")

elseif sortType == "Dislikes" then
    table.insert(params, "sortBy=dislikeCount")

elseif sortType == "Creation Date" then
    table.insert(params, "sortBy=createdAt")

elseif sortType == "Update Date" then
    table.insert(params, "sortBy=updatedAt")

elseif sortType == "Match Accuracy" then
    table.insert(params, "sortBy=accuracy")
end

if sortOrder == "Ascending" then
    table.insert(params, "order=asc")

elseif sortOrder == "Descending" then
    table.insert(params, "order=desc")
end

    local endpoint

    if query ~= "" then
        endpoint =
            "https://scriptblox.com/api/script/search?"
    else
        endpoint =
            "https://scriptblox.com/api/script/fetch?"
    end

    return endpoint .. table.concat(params, "&")
end

-- =========================================
-- Fetch Function
-- =========================================

function fetchScripts(page)

    if loading then
        return false
    end

    loading = true

    if loadMoreButton then
        loadMoreButton:Destroy()
        loadMoreButton = nil
    end

    local url = buildSearchURL(page)

    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if not success then
        loading = false
        warn("Fetch Error:", response)
        return false
    end

    local jsonSuccess, data =
        pcall(function()
            return HttpService:JSONDecode(response)
        end)

    if not jsonSuccess then
        loading = false
        warn("JSON Error:", data)
        return false
    end

    if data.message then
        loading = false
        warn("API Error:", data.message)
        return false
    end

    if not data.result
        or not data.result.scripts then

        loading = false
        warn("No scripts returned")
        return false
    end

    local scripts =
        data.result.scripts

    for _, scriptData in ipairs(scripts) do
        sipt(scriptData)
    end

    loading = false

    if data.result.nextPage
        and #scripts > 0 then

        load()

    elseif #scripts >= 20 then

        load()
    end

    return true
end


-- =========================================
-- Initial Fetch
-- =========================================

currentPage = 1
fetchScripts(currentPage)

backs.MouseButton1Click:Connect(function()
  tweenSize(Page, UDim2.new(0,0,1,0),nil,nil, 0.4)
  tweenSize(List, UDim2.new(1,0,1,0),nil,nil, 0.4).Completed:Wait()
  Page.Visible = false
end)

local function clearCards()

    if loadMoreButton then
        loadMoreButton:Destroy()
        loadMoreButton = nil
    end

    for _, child in ipairs(scr:GetChildren()) do

        if child:IsA("Frame")
            and child.Name == "Body" then

            child:Destroy()

        end
    end
end

local function refreshSearch()

    if loading then
        return
    end

    clearCards()

    currentPage = 1

    fetchScripts(currentPage)
end

tb.FocusLost:Connect(function(enterPressed)

    if not enterPressed then
        return
    end

    refreshSearch()

end)

refresh.MouseButton1Click:Connect(function()
    refreshSearch()
end)
-----

exe.MouseButton1Click:Connect(function()
  exe.Text = "<b>Executed</b>"
  tweenSize(exe, UDim2.new(1,0,0,10),nil,nil, 0.1).Completed:Wait()
  tweenSize(exe, UDim2.new(1,0,0,20),nil,nil, 0.1)

  local source = codebox.Text or ""

  if source and source ~= "" then

        if loadstring then
            loadstring((source))()
            exe.Text = "<b>Executed</b>"
        else
            exe.Text = "<b>Failed to execute</b>"
        end

    else
        exe.Text = "<b>No Source Found</b>"
    end
    
  wait(1)

  exe.Text = "<b>Execute</b>"
end)

cy.MouseButton1Click:Connect(function()

    local source = codebox.Text or ""

    if source == "" then
        cy.Text = "<b>No Code</b>"
    else
        if setclipboard then
            setclipboard(source)
            cy.Text = "<b>Copied</b>"
        else
            cy.Text = "<b>Clipboard Unsupported</b>"
        end
    end

    tweenSize(
        cy,
        UDim2.new(1,0,0,10),
        nil,nil,
        0.1
    ).Completed:Wait()

    tweenSize(
        cy,
        UDim2.new(1,0,0,20),
        nil,nil,
        0.1
    )

    task.wait(1)

    cy.Text = "<b>Copy To Clipboard</b>"
end)
