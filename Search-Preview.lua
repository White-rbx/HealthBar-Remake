-- searcher... yes. 11.5

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
local ContentProvider = game:GetService("ContentProvider")

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

local ROOT = "ExperienceSettings"

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

-- =========================================
-- Bookmark JSON Storage
-- =========================================
local BOOKMARK_FILE = ROOT .. "/SearchBookmark.json"
local bookmarks = {}

local function bookmarkKey(source, scriptId, title)
    return tostring(source or "") .. "|" .. tostring(scriptId or "") .. "|" .. tostring(title or "")
end

local function saveBookmarks()
    if type(writefile) ~= "function" then
        return false
    end

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(bookmarks)
    end)

    if not ok then
        warn("❌ Bookmark JSON encode failed:", encoded)
        return false
    end

    local wrote, err = pcall(function()
        writefile(BOOKMARK_FILE, encoded)
    end)

    if not wrote then
        warn("❌ Bookmark JSON write failed:", err)
        return false
    end

    return true
end

local function loadBookmarkFile()
    bookmarks = {}

    if type(isfile) ~= "function" or type(readfile) ~= "function" then
        return
    end

    if not isfile(BOOKMARK_FILE) then
        return
    end

    local ok, content = pcall(function()
        return readfile(BOOKMARK_FILE)
    end)

    if not ok or type(content) ~= "string" or content == "" then
        warn("❌ Bookmark JSON read failed")
        return
    end

    local decodedOk, decoded = pcall(function()
        return HttpService:JSONDecode(content)
    end)

    if not decodedOk or type(decoded) ~= "table" then
        warn("❌ Bookmark JSON decode failed")
        return
    end

    for _, item in ipairs(decoded) do
        if type(item) == "table" then
            local title = tostring(item.title or "")
            local source = tostring(item.source or "")
            local id = item.id

            if title ~= "" and source ~= "" then
                table.insert(bookmarks, {
                    title = title,
                    source = source,
                    id = id
                })
            end
        end
    end
end

local function addBookmarkData(title, source, scriptId)
    local key = bookmarkKey(source, scriptId, title)

    for _, item in ipairs(bookmarks) do
        if bookmarkKey(item.source, item.id, item.title) == key then
            return false
        end
    end

    table.insert(bookmarks, {
        title = tostring(title or ""),
        source = tostring(source or ""),
        id = scriptId
    })

    saveBookmarks()
    return true
end

local function removeBookmarkData(title, source, scriptId)
    local key = bookmarkKey(source, scriptId, title)

    for i = #bookmarks, 1, -1 do
        local item = bookmarks[i]
        if bookmarkKey(item.source, item.id, item.title) == key then
            table.remove(bookmarks, i)
            break
        end
    end

    saveBookmarks()
end

local SCRIPTBLOX_API =
    "https://scriptblox.com/api/script/fetch"

local SCRIPTBLOX_INDIVIDUAL_API =
    "https://scriptblox.com/api/script/"

local WEAREDEVS_API =
    "https://wearedevs.net/api/scripts/search"

local HAXHELL_API =
    "https://haxhell.com/api/v1/scripts"

local RSCRIPTS_API =
    "https://api.rscripts.net"

-- RScripts v1 requires an API key. Leave empty only if you
-- intentionally want the script to report the missing-key state.
-- You can also define RSCRIPTS_API_KEY before loading this file.
local RSCRIPTS_API_KEY = "rsc_live_ZyltSCHGpsfvgHudK24bqOYwIK-fyKDM"

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

local Page = Instance.new("CanvasGroup")
Page.Name = "Page"
Page.Size = UDim2.new(0,0,1,0)
Page.BorderMode = Enum.BorderMode.Inset
Page.BorderSizePixel = 5
Page.BackgroundTransparency = 1
Page.Visible = false
Page.Active = false
Page.Parent = sea

local InPage = Instance.new("ScrollingFrame")
InPage.Name = "InPage"
InPage.Size = UDim2.new(1,0,1,0)
InPage.BackgroundTransparency = 1
InPage.ScrollBarThickness = 0
InPage.ScrollingDirection = Enum.ScrollingDirection.Y
InPage.CanvasSize = UDim2.new(0,0,0,628)
InPage.Parent = Page

local Book = Instance.new("Frame")
Book.Name = "Bookmark"
Book.Size = UDim2.new(1,0,1,0)
Book.BackgroundTransparency = 1
Book.Visible = false
Book.Parent = Page

local vb = Instance.new("CanvasGroup")
vb.Name = "ViewBookmark"
vb.Size = UDim2.new(1,0,1,0)
vb.Position = UDim2.new(1,0,0,0)
vb.BackgroundColor3 = Color3.new(1,1,1)
vb.BorderMode = Enum.BorderMode.Inset
vb.BorderSizePixel = 5
vb.Active = false
vb.Parent = Book
Corner(0,8,vb)
Gradient(vb, -90,0,0, Color3.fromRGB(255,170,0), Color3.fromRGB(255,0,0))

local vp = Instance.new("CanvasGroup")
vp.Name = "ViewPage"
vp.Size = UDim2.new(1,0,1,0)
vp.BackgroundColor3 = Color3.new(1,1,1)
vp.BorderMode = Enum.BorderMode.Inset
vp.BorderSizePixel = 5
vp.Active = false
vp.Parent = InPage
Corner(0,8,vp)
Gradient(vp, 90,0,0, Color3.fromRGB(170,0,255), Color3.fromRGB(255,85,255))

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

-- =========================================
-- Filter Body
-- =========================================

local filter_body = Instance.new("Frame")
filter_body.Name = "FilterBody"
filter_body.Size = UDim2.new(0,0,0,0)
filter_body.Position = UDim2.new(0,-305,1,5)
filter_body.BackgroundColor3 = Color3.fromRGB(0,85,0)
filter_body.BorderMode = Enum.BorderMode.Inset
filter_body.BorderSizePixel = 5
filter_body.ZIndex = 2
filter_body.AutomaticSize = Enum.AutomaticSize.Y
filter_body.Visible = false
filter_body.Parent = filter
Corner(0,8,filter_body)
ListLayout(filter_body, 0,2, HCenter, VTop, SLayout, FillV)

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

local switches = {}
local resetSwitches = {}

local function type_(lay, type, key)

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

    body.LayoutOrder = tonumber(lay)

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

resetSwitches[key] = function()

    stateIndex = 1
    filterType[key] = "Default"

    tweenSize(
        switch,
        nil,
        nil,
        FILTER_COLORS.Default,
        0.1
    )

end

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

    -- Return the actual UI object so the API capability
    -- system can toggle Visible correctly.
    return body
end

-- =========================================
-- Create Filters
-- =========================================

local scrtype = type_(0, "Script Type (Default/Free/Paid)", "ScriptType")
local uni = type_(1, "Universal", "IsUniversal")
local ver = type_(2, "Verified", "Verified")
local pat = type_(3, "Patched", "Patched")
local ky = type_(5, "Key", "Key")

local APIType = {
    "ScriptBlox",
    "WeAreDevs",
    "HaxHell",
    "RScripts"
}

local currentAPI = "ScriptBlox"

local APISortCapabilities = {

    ScriptBlox = {
        Views = true,
        Likes = true,
        Dislikes = true,
        ["Creation Date"] = true,
        ["Update Date"] = true,
        ["Match Accuracy"] = true
    },

    WeAreDevs = {
        Views = false,
        Likes = false,
        Dislikes = false,
        ["Creation Date"] = false,
        ["Update Date"] = false,
        ["Match Accuracy"] = false
    },

    HaxHell = {
        Views = true,
        Likes = false,
        Dislikes = false,
        ["Creation Date"] = true,
        ["Update Date"] = true,
        ["Match Accuracy"] = false
    },

    RScripts = {
        Views = true,
        Likes = true,
        Dislikes = false,
        ["Creation Date"] = true,
        ["Update Date"] = false,
        ["Match Accuracy"] = false
    }
}
  
local function getNextSupportedSort()

    local states = {
        "Default",
        "Views",
        "Likes",
        "Dislikes",
        "Creation Date",
        "Update Date",
        "Match Accuracy"
    }

    local capabilities =
        APISortCapabilities[currentAPI]

    for _ = 1, #states do

        sortByIndex += 1

        if sortByIndex > #states then
            sortByIndex = 1
        end

        local state =
            states[sortByIndex]

        if state == "Default"
            or capabilities[state] == true then

            return state

        end

    end

    return "Default"

end

-- =========================================
-- Sort UI
-- =========================================

local sortContainer = Instance.new("Frame")

sortContainer.Name = "SortContainer"

sortContainer.Size =
    UDim2.new(1,0,0,30)

sortContainer.BackgroundTransparency = 1

sortContainer.ZIndex = 2

sortContainer.Parent = filter_body

sortContainer.LayoutOrder = 5


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

    sortType = getNextSupportedSort()

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

-- Used whenever a script has no usable thumbnail.
local FALLBACK_IMAGE = "rbxassetid://97342316412122"

local owninput = Instance.new("TextBox")
owninput.Name = "CreatorInput"
owninput.Size = UDim2.new(1,0,0,30)
owninput.BackgroundColor3 = Color3.fromRGB(255,85,0)
owninput.PlaceholderText = "Input: Creator..."
owninput.PlaceholderColor3 = Color3.new(1,1,1)
owninput.TextColor3 = Color3.new(0,0,0)
owninput.TextScaled = true
owninput.Text = ""
owninput.LayoutOrder = 6
owninput.BorderMode = Enum.BorderMode.Inset
owninput.BorderSizePixel = 3
owninput.ZIndex = 2
owninput.Parent = filter_body
Corner(0,5,owninput)

local gameinput = Instance.new("TextBox")
gameinput.Name = "GameInput"
gameinput.Size = UDim2.new(1,0,0,30)
gameinput.BackgroundColor3 = Color3.fromRGB(255,85,0)
gameinput.PlaceholderText = "Input: Game ID"
gameinput.PlaceholderColor3 = Color3.new(1,1,1)
gameinput.TextColor3 = Color3.new(0,0,0)
gameinput.TextScaled = true
gameinput.Text = ""
gameinput.LayoutOrder = 7
gameinput.BorderMode = Enum.BorderMode.Inset
gameinput.BorderSizePixel = 3
gameinput.ZIndex = 2
gameinput.Parent = filter_body
Corner(0,5,gameinput)

local apitype = Instance.new("TextButton")
apitype.Name = "TypeOfAnAPI"
apitype.Size = UDim2.new(1,0,0,30)
apitype.BackgroundColor3 = Color3.fromRGB(85, 255, 127)
apitype.TextColor3 = Color3.new(0,0,0)
apitype.RichText = true
apitype.LayoutOrder = -1
apitype.Text = "<b>Search API: ScriptBlox</b>"
apitype.TextScaled = true
apitype.BorderMode = Enum.BorderMode.Inset
apitype.BorderSizePixel = 3
apitype.ZIndex = 2
apitype.Parent = filter_body
Corner(0,5,apitype)

local line1 = Instance.new("Frame")
line1.Name = "Line"
line1.Size = UDim2.new(0.8,0,0,3)
line1.BackgroundColor3 = Color3.new(1,1,1)
line1.ZIndex = 2
line1.LayoutOrder = 8
line1.Visible = true
line1.Parent = filter_body

local back = Instance.new("TextButton")
back.Name = "Back"
back.Size = UDim2.new(1,0,0,30)
back.BackgroundColor3 = Color3.new(1,0,0)
back.TextSize = 14
back.RichText = true
back.TextWrapped = true
back.LayoutOrder = 3
back.ZIndex = 2
back.TextColor3 = Color3.new(1,1,1)
back.Text = "Switch back to the <b>Current version</b>"
back.LayoutOrder = 9
back.Parent = filter_body
Corner(0,8,back)
local bk_str = Stroke(back, ASMBorder, 100,0,0, LJMRound, 3, 0)
bk_str.BorderStrokePosition = Enum.BorderStrokePosition.Inner

back.MouseButton1Click:Connect(function()
    sea:Destroy()
    wait(0.5) 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/Search.lua"))()
end)

back.Visible = true

local pre = Instance.new("TextButton")
pre.Name = "Preview"
pre.Size = UDim2.new(1,0,0,30)
pre.BackgroundColor3 = Color3.new(0,1,1)
pre.TextSize = 16
pre.RichText = true
pre.TextWrapped = true
pre.LayoutOrder = 3
pre.ZIndex = 2
pre.TextColor3 = Color3.new(0,0,0)
pre.Text = "Switch to the <b>Preview version</b>"
pre.LayoutOrder = 10
pre.Parent = filter_body
Corner(0,8,pre)
local pre_str = Stroke(pre, ASMBorder, 0,170,255, LJMRound, 3, 0)
pre_str.BorderStrokePosition = Enum.BorderStrokePosition.Inner

pre.MouseButton1Click:Connect(function()
    sea:Destroy()
    wait(0.5) 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/Search-Preview.lua"))()
end)

pre.Visible = false -- FALSE FOR FULLY VERSION

local openb = Instance.new("ImageButton")
openb.Name = "Open"
openb.Position = UDim2.new(1,-115,0,0)
openb.Size = UDim2.new(0,35,0,35)
openb.BackgroundColor3 = Color3.new(1,1,1)
openb.BackgroundTransparency = 0.3
openb.Image = "rbxassetid://71272710123832"
openb.Parent = tb

Corner(0,3,openb)
Stroke(openb, ASMBorder, 255, 255, 255, LJMRound, 1 ,0)
Gradient(openb, -45 ,0,0, Color3.fromRGB(170,0,255), Color3.fromRGB(255,170,255))

openb.MouseButton1Click:Connect(function()
    if isswitch == false then
      isswitch = true
      openb.Image = "rbxassetid://133955276215666"
      tweenSize(InPage, nil, UDim2.new(1,0,0,0), nil, 0.3)
      tweenSize(Book, nil, UDim2.new(0,0,0,0), nil, 0.3)
      Book.Visible = true
      task.wait(0.3)
      InPage.Visible = false
    else
      isswitch = false
      openb.Image = "rbxassetid://71272710123832"
      tweenSize(InPage, nil, UDim2.new(0,0,0,0), nil, 0.3)
      tweenSize(Book, nil, UDim2.new(1,0,0,0), nil, 0.3)
      InPage.Visible = true
      task.wait(0.3)
      Book.Visible = false
    end
end)

local backs1 = Instance.new("TextButton")
backs1.Name = "CloseBookmark"
backs1.Size = UDim2.new(1,0,0,20)
backs1.Position = UDim2.new(0,0,1,-20)
backs1.BackgroundColor3 = Color3.new(1,0,0)
backs1.TextColor3 = Color3.new(1,1,1)
backs1.TextXAlignment = Enum.TextXAlignment.Right
backs1.BorderMode = Enum.BorderMode.Inset
backs1.BorderSizePixel = 4
backs1.RichText = true
backs1.TextScaled = true
backs1.Text = "<b>Back »</b>"
backs1.Parent = vb
Corner(0,8,backs1)

backs1.MouseButton1Click:Connect(function()
  tweenSize(Page, UDim2.new(0,0,1,0),nil,nil, 0.4)
  tweenSize(List, UDim2.new(1,0,1,0),nil,nil, 0.4).Completed:Wait()
  Page.Visible = false
end)

openb.ImageColor3 = Color3.new(0,0,0)
filter.ImageColor3 = Color3.new(0,0,0)
refresh.ImageColor3 = Color3.new(0,0,0)

local btopic = Instance.new("TextLabel")
btopic.Name = "BookmarkTopic"
btopic.Size = UDim2.new(1,0,0,25)
btopic.RichText = true
btopic.BackgroundTransparency = 1
btopic.Active = false
btopic.TextXAlignment = Enum.TextXAlignment.Left
btopic.TextColor3 = Color3.new(1,1,1)
btopic.Text = "<b>Bookmark page</b>"
btopic.TextScaled = true
btopic.BorderMode = Enum.BorderMode.Inset
btopic.BorderSizePixel = 3
btopic.Parent = vb

local bscroll = Instance.new("ScrollingFrame")
bscroll.Name = "BookmarList"
bscroll.Size = UDim2.new(1,0,0.88,0)
bscroll.Position = UDim2.new(0,0,1,-415)
bscroll.ScrollBarThickness = 5
bscroll.ScrollingDirection = Enum.ScrollingDirection.Y
bscroll.CanvasSize = UDim2.new(0,0,0,0)
bscroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
bscroll.BackgroundTransparency = 1
bscroll.BorderMode = Enum.BorderMode.Inset
bscroll.BorderSizePixel = 5
bscroll.BorderColor3 = Color3.new(1,0,0)
bscroll.Parent = vb
ListLayout(bscroll, 0, 3, HLeft, VTop, SLayout, FillV)

-- =========================================
-- Shared State / Forward Declarations
-- =========================================
-- Declared before the API switch callback so it
-- closes over the intended local variables.
local currentPage = 1
local loading = false
local loadMoreButton = nil

local apiCursor = nil

local fetchScripts
local fetchIndividual
local requestAPI
local clearCards
local refreshSearch
local buildSearchURL
local buildScriptBloxURL
local buildWeAreDevsURL
local buildHaxHellURL
local buildRScriptsURL

local isswitch = false
local fil_sw = false  
  
filter.MouseButton1Click:Connect(function()  
    if not fil_sw then  
      fil_sw = true  
      filter_body.Visible = true  
      tweenSize(filter_body, UDim2.new(0,350,0,0),nil,nil,0.3).Completed:Wait()
    else  
      fil_sw = false  
      tweenSize(filter_body, UDim2.new(0,0,0,0),nil,nil,0.3).Completed:Wait()
      filter_body.Visible = false  
    end  
end)

-- =========================================
-- Reset Filter State
-- =========================================

local function resetAPIFilters()

    -- =====================================
    -- Reset type_() states + switch UI
    -- =====================================

    for _, reset in pairs(resetSwitches) do
        reset()
    end

    -- =====================================
    -- Reset Sort
    -- =====================================

    sortType = "Default"
    sortOrder = "Default"

    sortByIndex = 1
    sortOrderIndex = 1

    sortBy.Text =
        "<b>Sort by: Default</b>"

    sortOrderButton.Text =
        "<b>Sort order: Default</b>"

    -- =====================================
    -- Reset TextBox
    -- =====================================

    owninput.Text = ""
    gameinput.Text = ""

end

-- =========================================
-- API Capability System
-- =========================================

local apiIndex = 1

-- =========================================
-- API Capabilities
-- =========================================

local APICapabilities = {

    -- =====================================
    -- ScriptBlox
    -- =====================================

    ScriptBlox = {

        Creator = true,
        Game = true,

        ScriptType = true,
        Universal = true,
        Verified = true,
        Patched = true,
        Key = true,

        Sort = true

    },

    -- =====================================
    -- WeAreDevs
    -- =====================================

    WeAreDevs = {

        Creator = false,
        Game = false,

        ScriptType = false,
        Universal = false,
        Verified = false,
        Patched = false,
        Key = false,

        Sort = false

    },

    -- =====================================
    -- HaxHell
    -- =====================================

    HaxHell = {

        Creator = true,
        Game = true,

        ScriptType = false,
        Universal = false,
        Verified = false,
        Patched = true,
        Key = true,

        Sort = true

    },

    -- =====================================
    -- RScripts
    -- =====================================

    RScripts = {
    Creator = false,
    Game = true,

    ScriptType = false,
    Universal = false,
    Verified = true,
    Patched = false,
    Key = true,

    Sort = true
    }

}

-- =========================================
-- API Normalize
-- =========================================

local function normalizeScript(api, item)

	if type(item) ~= "table" then
		return nil
	end

	--------------------------------------------------
	-- ScriptBlox
	--------------------------------------------------

	if api == "ScriptBlox" then

		return {
			id = item._id,
			name = item.title or item.name,
			creator = item.owner
				and item.owner.username,

			description = item.description or item.features,

			gameName = item.game
				and item.game.name,

			gameId = item.game
				and (
					item.game.gameId
					or item.game.placeId
				),

			views = item.views or 0,
			likes = item.likeCount or 0,
			dislikes = item.dislikeCount or 0,

			verified = item.isVerified == true,
			patched = item.isPatched == true,
			universal = item.isUniversal == true,
			paid = item.isPaid == true,
      scriptType =
            item.isPaid == true
            and "paid"
            or "free",
			key = item.keySystem == true,

			createdAt = item.createdAt,
			updatedAt = item.updatedAt,

			raw = item.script,

			tags = item.tags,

			image = item.image
		}

	--------------------------------------------------
	-- WeAreDevs
	--------------------------------------------------

	elseif api == "WeAreDevs" then

		local account =
			item.account

		return {
			id = item._id,
			name = item.name,
			creator = account
				and account.username,

			description = item.description,

			gameName = nil,
			gameId = nil,

			views = 0,
			likes = 0,
			dislikes = 0,

			verified = false,
			patched = false,
			universal = false,
			paid = false,
			key = false,

			createdAt = nil,
			updatedAt = nil,

			raw = item.raw,

			tags = item.tags,

			image = item.image
		}

	--------------------------------------------------
	-- HaxHell
	--------------------------------------------------

	elseif api == "HaxHell" then

		local author = item.author
		local game = item.game
		local stats = item.stats
		local flags = item.flags
		local media = item.media
		local links = item.links

		return {
			id = item.id,
			name = item.title,
			creator = author
				and author.username,

			description = item.description,

			gameName = game
				and game.name,

			gameId = game
				and (
					game.placeId
					or game.universeId
				),

			views = stats
				and stats.views or 0,

			likes = stats
				and stats.likes or 0,

			dislikes = 0,

			verified = false,
			patched = flags
				and flags.patched == true,

			universal = item.type
				== "universal",

			paid = flags
				and flags.isPaid == true,

      scriptType =
    flags == nil
    and nil
    or (
        flags.isPaid == true
        and "paid"
        or "free"
    ),

			key = flags
				and flags.keySystem == true,

			createdAt = item.createdAt,
			updatedAt = item.updatedAt,

			raw = links
				and links.raw,

			tags = item.tags,

			image = media
				and media.thumbnailUrl
		}

	--------------------------------------------------
	-- RScripts
	--------------------------------------------------

	elseif api == "RScripts" then

		local game = item.game
		local creator = item.creator

		return {
			id = item.id,
			name = item.title,
			creator = creator
				and creator.username,

			description = item.description,

			gameName = game
				and game.title,

			gameId = game
				and game.placeId,

			views = item.views or 0,
			likes = item.likes or 0,
			dislikes = item.dislikes or 0,

			verified = creator
				and creator.isVerified == true,

			patched = false,
			universal = false,
			paid = false,
			key = false,

			createdAt = nil,
			updatedAt = nil,

			raw = item.rawScript
				or item.script,

			tags = item.tags,

			image = game
				and game.thumbnailUrl
		}

	end

	return nil

end

-- =========================================
-- API UI Objects
-- =========================================

local APIFilters = {

    Creator = owninput,
    Game = gameinput,

    ScriptType = scrtype,
    Universal = uni,
    Verified = ver,
    Patched = pat,
    Key = ky,

    Sort = sortContainer

}

-- =========================================
-- Update API UI
-- =========================================

local function updateAPIFilters()

    local capabilities =
        APICapabilities[currentAPI]

    if not capabilities then
        return
    end

    for feature, object in pairs(APIFilters) do

        if object then
            -- Unsupported API features are completely hidden.
            object.Visible = capabilities[feature] == true
        end

    end

end

-- =========================================
-- API Switch
-- =========================================

apitype.MouseButton1Click:Connect(function()

    apiIndex += 1

    if apiIndex > #APIType then
        apiIndex = 1
    end

    currentAPI =
        APIType[apiIndex]

    apiCursor = nil

    -- Reset filters / inputs / sort
    resetAPIFilters()

    -- Clear old results
    clearCards()

    -- Reset pagination
    currentPage = 1

    -- Update visible filters
    updateAPIFilters()

    -- Update API button
    apitype.Text =
        "<b>Search API: "
        .. currentAPI
        .. "</b>"

    -- Fetch the first page for the new API
    refreshSearch()

end)

-- Initial State
updateAPIFilters()
  
local scr = Instance.new("ScrollingFrame")
scr.Name = "Scrips"
scr.Position = UDim2.new(0,0,0,50)
scr.Size = UDim2.new(1,0,1,-50)
scr.BackgroundColor3 = Color3.fromRGB(255,255,255)
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

-----

local function normalizeAssetImage(value)
	if value == nil then
		return nil
	end

	local image = tostring(value)
	if image == "" then
		return nil
	end

	-- Already a Roblox content id.
	if image:match("^rbxassetid://")
		or image:match("^rbxthumb://")
		or image:match("^rbxasset://") then
		return image
	end

	return image
end

local function getImageExtension(url)
	local clean = tostring(url):lower():match("^[^%?]+") or tostring(url):lower()
	local ext = clean:match("%.(png)$")
		or clean:match("%.(jpg)$")
		or clean:match("%.(jpeg)$")
		or clean:match("%.(webp)$")

	return ext or "png"
end

local function sanitizeFileName(value)
	local text = tostring(value or "image")
	text = text:gsub("[^%w%-_]", "_")
	text = text:gsub("_+", "_")
	return text:sub(1, 80)
end

local function getCachedRemoteImage(imageUrl, cacheKey)
	imageUrl = normalizeAssetImage(imageUrl)
	if not imageUrl
		or not imageUrl:match("^https?://") then
		return nil
	end

	if type(isfile) ~= "function"
		or type(getcustomasset) ~= "function" then
		return nil
	end

	local extension = getImageExtension(imageUrl)
	local fileName = IMAGE_FOLDER .. "/"
		.. sanitizeFileName(cacheKey or "image")
		.. "."
		.. extension

	if not isfile(fileName) then
		return nil
	end

	local ok, asset = pcall(function()
		return getcustomasset(fileName)
	end)

	if ok and asset and tostring(asset) ~= "" then
		return tostring(asset)
	end

	return nil
end

local function cacheRemoteImage(imageUrl, cacheKey)
	imageUrl = normalizeAssetImage(imageUrl)
	if not imageUrl
		or not imageUrl:match("^https?://") then
		return imageUrl
	end

	if type(writefile) ~= "function"
		or type(isfile) ~= "function"
		or type(getcustomasset) ~= "function" then
		return nil
	end

	local cached = getCachedRemoteImage(imageUrl, cacheKey)
	if cached then
		return cached
	end

	local extension = getImageExtension(imageUrl)
	local fileName = IMAGE_FOLDER .. "/"
		.. sanitizeFileName(cacheKey or "image")
		.. "."
		.. extension

	local ok, body = pcall(function()
		return game:HttpGet(imageUrl)
	end)

	if not ok or type(body) ~= "string" or body == "" then
		return nil
	end

	local wrote = pcall(function()
		writefile(fileName, body)
	end)

	if not wrote then
		return nil
	end

	return getCachedRemoteImage(imageUrl, cacheKey)
end

local function getGameThumbnail(gameId, cacheKey)
	gameId = tonumber(gameId)
	if not gameId then
		return nil
	end

	-- rbxthumb is the primary Roblox-native fallback.
	return "rbxthumb://type=GameThumbnail&id="
		.. tostring(math.floor(gameId))
		.. "&w=480&h=270"
end

local function getScriptImage(scriptData)
	if type(scriptData) ~= "table" then
		return FALLBACK_IMAGE
	end

	--------------------------------------------------
	-- 1. Roblox Game Thumbnail (PRIMARY)
	-- Roblox's GameThumbnail expects a PlaceId.
	-- This intentionally overrides API/custom images
	-- whenever a valid game id is available.
	--------------------------------------------------
	local thumbnail = getGameThumbnail(scriptData.gameId)
	if thumbnail then
		return thumbnail
	end

	--------------------------------------------------
	-- 2. API custom image (fallback only)
	--------------------------------------------------
	local apiImage = normalizeAssetImage(scriptData.image)
	if apiImage then
		if not apiImage:match("^https?://") then
			return apiImage
		end

		local cacheKey = tostring(scriptData.id or scriptData.gameId or "image")
		local cached = getCachedRemoteImage(
			apiImage,
			currentAPI .. "_" .. cacheKey
		)

		if cached then
			return cached
		end
	end

	--------------------------------------------------
	-- 3. Fallback
	--------------------------------------------------
	return FALLBACK_IMAGE
end

local function loadRemoteImageAsync(scriptData, imageObject)
	if type(scriptData) ~= "table"
		or not imageObject
		or not imageObject:IsA("ImageLabel") then
		return
	end

	-- Do not replace a valid game thumbnail with an API/custom image.
	if getGameThumbnail(scriptData.gameId) then
		return
	end

	local apiImage = normalizeAssetImage(scriptData.image)
	if not apiImage
		or not apiImage:match("^https?://") then
		return
	end

	local cacheKey = tostring(scriptData.id or scriptData.gameId or "image")
	local cached = cacheRemoteImage(
		apiImage,
		currentAPI .. "_" .. cacheKey
	)

	if cached
		and imageObject.Parent then
		imageObject.Image = cached
		preloadImage(imageObject)
	end
end

-- =========================================
-- Preview Image Helpers
-- =========================================
local function getFetchPreviewImage(data)
	return getScriptImage(data)
end

local function getSearchPreviewImage(data)
	return getScriptImage(data)
end

local function preloadImage(imageObject)
	if not imageObject or not imageObject:IsA("ImageLabel") then
		return
	end

	pcall(function()
		ContentProvider:PreloadAsync({imageObject})
	end)
end

-- =========================================
-- API Display Helper
-- =========================================

local function apiText(value)

    if value == nil then
        return "API Not supported"
    end

    return tostring(value)
end


local function boolText(value)

    if value == nil then
        return "API Not supported"
    end

    if value == true then
        return "Yes"
    end

    return "No"
end


-- =========================================
-- Individual / Detail Fetch
-- =========================================
fetchIndividual = function(scriptId, fallbackData)
	if not scriptId then
		return fallbackData
	end

	-- ScriptBlox provides a dedicated individual endpoint.
	if currentAPI ~= "ScriptBlox" then
		return fallbackData
	end

	local url = SCRIPTBLOX_INDIVIDUAL_API
		.. HttpService:UrlEncode(tostring(scriptId))

	local success, response = requestAPI(url)
	if not success then
		warn("❌ ScriptBlox detail request failed:", response)
		return fallbackData
	end

	local decodeSuccess, payload = pcall(function()
		return HttpService:JSONDecode(response)
	end)

	if not decodeSuccess or type(payload) ~= "table" then
		warn("❌ ScriptBlox detail JSON decode failed:", payload)
		return fallbackData
	end

	local item = payload.script
	if type(item) ~= "table" then
		item = payload
	end

	local normalized = normalizeScript(currentAPI, item)
	if not normalized then
		return fallbackData
	end

	return normalized
end

-- =========================================
-- Script Card
-- =========================================

local marked

-- =========================================
-- Bookmark API Switch
-- =========================================

local function switchBookmarkAPI(source)

    if type(source) ~= "string" or source == "" then
        return
    end

    currentAPI = source

    for i, apiName in ipairs(APIType) do
        if apiName == source then
            apiIndex = i
            break
        end
    end

    apiCursor = nil
    updateAPIFilters()

    apitype.Text =
        "<b>Search API: "
        .. currentAPI
        .. "</b>"
end

-- =========================================
-- View Page Loader
-- =========================================

local function loadViewData(data, preloadedDetail)

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

  -- Always return to the normal View page.
  -- This must also run when View is opened for the 2nd+ time.
  isswitch = false
  openb.Image = "rbxassetid://71272710123832"
  InPage.Visible = true
  Book.Visible = false

  tweenSize(InPage, nil, UDim2.new(0,0,0,0), nil, 0.3)
  tweenSize(Book, nil, UDim2.new(1,0,0,0), nil, 0.3)


    -- =================================
    -- Loading State
    -- =================================

    names.Text =
        "<b>Loading Data...</b>"

    types.Text =
        "Loading Data..."

    cre.Text =
        "Loading Data..."

    credate.Text =
        "Loading Data..."

    like.Text =
        "<b>Like: Loading Data...</b>"

    dislike.Text =
        "<b>Dislike: Loading Data...</b>"

    visit.Text =
        "<b>Visit: Loading Data...</b>"

    feabox.Text =
        "Loading Data..."

    codebox.Text =
        "Loading Data..."

    imgview.Image =
        FALLBACK_IMAGE


    -- =================================
    -- Clear Old Tags
    -- =================================

    for _, child in ipairs(
        tagscroll:GetChildren()
    ) do

        if child.Name ==
            "TagString" then

            child:Destroy()

        end
    end

    tagscroll.CanvasSize =
        UDim2.new(0,0,0,0)


    -- =================================
    -- Detail Data
    -- =================================

    local detail =
        preloadedDetail

    if type(detail) ~= "table" then
        detail = fetchIndividual(
            data.id,
            data
        )
    end

    if type(detail) ~= "table" then
        detail = data
    end


    -- =================================
    -- Title
    -- =================================

    local detailTitle =
        apiText(detail.name)

    if detailTitle == ""
        or detailTitle ==
            "API Not supported" then

        detailTitle =
            "Untitled Script"

    end


    -- =================================
    -- Creator
    -- =================================

    local detailOwner =
        apiText(detail.creator)

    if detailOwner == "" then
        detailOwner =
            "API Not supported"
    end


    -- =================================
    -- Game Name
    -- =================================

    local detailGameName =
        apiText(detail.gameName)

    if detailGameName == "" then
        detailGameName =
            "API Not supported"
    end


    -- =================================
    -- Image
    -- =================================

    imgview.Image =
        getFetchPreviewImage(detail)

    preloadImage(imgview)
    task.spawn(loadRemoteImageAsync, detail, imgview)


    -- =================================
    -- Title
    -- =================================

    names.Text =
        "<b>"
        .. detailTitle
        .. "</b>"


    -- =================================
    -- Game
    -- =================================

    types.Text =
        detailGameName


    -- =================================
    -- Creator
    -- =================================

    cre.Text =
        "By @"
        .. detailOwner


    -- =================================
    -- Likes
    -- =================================

    like.Text =
        "<b>Like: "
        .. apiText(detail.likes)
        .. "</b>"


    -- =================================
    -- Dislikes
    -- =================================

    dislike.Text =
        "<b>Dislike: "
        .. apiText(detail.dislikes)
        .. "</b>"


    -- =================================
    -- Views
    -- =================================

    visit.Text =
        "<b>Visit: "
        .. apiText(detail.views)
        .. "</b>"


    -- =================================
    -- Creation Date
    -- =================================

    credate.Text =
        "Creation Date: "
        .. apiText(detail.createdAt)


    -- =================================
    -- Features / Description
    -- =================================

    local features =
        apiText(detail.description)

    if features ==
        "API Not supported" then

        feabox.Text = ""
        feabox.PlaceholderText =
            "API Not supported"

    elseif features == "" then

        feabox.Text = ""
        feabox.PlaceholderText =
            "No description yet."

    else

        feabox.Text =
            features

    end


    -- =================================
    -- Tags
    -- =================================

    for _, child in ipairs(
        tagscroll:GetChildren()
    ) do

        if child:IsA("TextLabel")
            and child.Name ==
                "TagString" then

            child:Destroy()

        end

    end


    if type(detail.tags) ==
        "table" then

        for _, tagName in ipairs(
            detail.tags
        ) do

            tagss(tagName)

        end

    end


    -- =================================
    -- Source
    -- =================================

    codebox.Text =
        apiText(detail.raw)


end

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

    Verified.Text =
        "<b>Verified</b>"

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

    Key.Text =
        "<b>Key</b>"

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

    Patched.Text =
        "<b>Patched</b>"

    Patched.Visible =
        data.patched == true

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

    Free.Text =
        "<b>Free</b>"

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

    Paid.Text =
        "<b>Paid</b>"

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
    task.defer(preloadImage, Img)
    task.spawn(loadRemoteImageAsync, data, Img)

    Corner(0,3,Img)


    -- =====================================
    -- Game Name
    -- =====================================

    local gameName =
        apiText(data.gameName)

    if gameName == "" then
        gameName =
            "API Not supported"
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


    -- =====================================
    -- Title
    -- =====================================

    local title =
        apiText(data.name)

    if title == ""
        or title == "API Not supported" then

        title =
            "Untitled Script"

    end


    -- =====================================
    -- Creator
    -- =====================================

    local owner =
        apiText(data.creator)

    if owner == "" then
        owner =
            "API Not supported"
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
    -- Bookmark Button
    -- =====================================

    local bookm =
        Instance.new("TextButton")

    bookm.Name =
        "BookmarkButton"

    bookm.Position =
        UDim2.new(1,-100,0,40)

    bookm.Size =
        UDim2.new(0,100,0,35)

    bookm.BackgroundColor3 =
        Color3.new(1,1,1)

    bookm.TextColor3 =
        Color3.new(0,0,0)

    bookm.TextSize = 13
    bookm.RichText = true

    bookm.Text =
        "<b><i>Bookmark</i></b>"

    bookm.Parent = body

    Corner(0,3,bookm)


    Gradient(
        bookm,
        -45,
        0,
        0,
        Color3.fromRGB(255,0,0),
        Color3.fromRGB(255,255,0)
    )


    Stroke(
        bookm,
        ASMBorder,
        255,255,255,
        LJMRound,
        2,
        0
  )


    -- =====================================
    -- Bookmark Click
    -- =====================================

    bookm.MouseButton1Click:Connect(function()

        -- ---------------------------------
        -- Button animation
        -- ---------------------------------

        tweenSize(
            bookm,
            UDim2.new(0,80,0,15),
            nil,
            nil,
            0.1
        ).Completed:Wait()


        tweenSize(
            bookm,
            UDim2.new(0,100,0,35),
            nil,
            nil,
            0.1
        )


        -- =================================
        -- =================================
        -- Add Bookmark
        -- =================================

        if marked then
            local added = addBookmarkData(
                data.name,
                currentAPI,
                data.id
            )

            if added then
                marked(
                    data.name,
                    currentAPI,
                    data.id
                )
            end
        end

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

      if isswitch == false then
      isswitch = true
      openb.Image = "rbxassetid://133955276215666"
      tweenSize(InPage, nil, UDim2.new(1,0,0,0), nil, 0.3)
      tweenSize(Book, nil, UDim2.new(0,0,0,0), nil, 0.3)
      Book.Visible = true
      task.wait(0.3)
      InPage.Visible = false
      end
    end)

  
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

        -- =================================
        -- Load View Data
        -- =================================

        loadViewData(data)

    end)

end

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

-- =========================================
-- API URL Builder
-- =========================================

    buildSearchURL = function(page)

    if currentAPI == "ScriptBlox" then
        return buildScriptBloxURL(page)
    elseif currentAPI == "WeAreDevs" then
        return buildWeAreDevsURL(page)
    elseif currentAPI == "HaxHell" then
        return buildHaxHellURL(page)
    elseif currentAPI == "RScripts" then
        return buildRScriptsURL(page)
    end

    return nil

end

-- =========================================
-- ScriptBlox Search URL
-- =========================================

buildScriptBloxURL = function(page)

    local query = tb.Text or ""

    query =
        query:gsub("^%s+", "")
            :gsub("%s+$", "")

    local creator = owninput.Text or ""

    creator =
        creator:gsub("^%s+", "")
              :gsub("%s+$", "")

    local gameInputText = gameinput.Text or ""

    gameInputText =
        gameInputText:gsub("^%s+", "")
                      :gsub("%s+$", "")

    local params = {}

    -- =====================================
    -- Page
    -- =====================================

    table.insert(
        params,
        "page=" .. tostring(page)
    )

    -- =====================================
    -- Max
    -- =====================================

    table.insert(
        params,
        "max=20"
    )

    -- =====================================
    -- Search
    -- =====================================

    if query ~= "" then

        table.insert(
            params,
            "q="
            .. HttpService:UrlEncode(query)
        )

    end

    -- =====================================
    -- Creator
    -- =====================================

    if creator ~= "" then

        table.insert(
            params,
            "owner="
            .. HttpService:UrlEncode(creator)
        )

    end

    -- =====================================
    -- Game
    -- =====================================

    if gameInputText ~= "" then

        local gameId = tonumber(gameInputText)

        if gameId then

            gameId = math.floor(gameId)

            if gameId > 0 then
                table.insert(
                    params,
                    "placeId=" .. tostring(gameId)
                )
            end

        end

    end

    -- =====================================
    -- Script Type
    -- =====================================

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

    -- =====================================
    -- Universal
    -- =====================================

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

    -- =====================================
    -- Verified
    -- =====================================

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

    -- =====================================
    -- Patched
    -- =====================================

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

    -- =====================================
    -- Key
    -- =====================================

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

    -- =====================================
    -- Sort By
    -- =====================================

    if sortType == "Views" then

        table.insert(
            params,
            "sortBy=views"
        )

    elseif sortType == "Likes" then

        table.insert(
            params,
            "sortBy=likeCount"
        )

    elseif sortType == "Dislikes" then

        table.insert(
            params,
            "sortBy=dislikeCount"
        )

    elseif sortType == "Creation Date" then

        table.insert(
            params,
            "sortBy=createdAt"
        )

    elseif sortType == "Update Date" then

        table.insert(
            params,
            "sortBy=updatedAt"
        )

    elseif sortType == "Match Accuracy" then

        table.insert(
            params,
            "sortBy=accuracy"
        )

    end

    -- =====================================
    -- Sort Order
    -- =====================================

    if sortOrder == "Ascending" then

        table.insert(
            params,
            "order=asc"
        )

    elseif sortOrder == "Descending" then

        table.insert(
            params,
            "order=desc"
        )

    end

    -- =====================================
    -- Endpoint
    -- =====================================

    local endpoint

    if query ~= "" then

        endpoint =
            SCRIPTBLOX_API:gsub(
                "/fetch$",
                "/search"
            ) .. "?"

    else

        endpoint =
            SCRIPTBLOX_API .. "?"

    end

    return endpoint
        .. table.concat(params, "&")

end

-- =========================================
-- WeAreDevs Search URL
-- =========================================

buildWeAreDevsURL = function(page)

    local query = tb.Text or ""

    query =
        query:gsub("^%s+", "")
            :gsub("%s+$", "")

    local params = {}

    -- =====================================
    -- Search
    -- =====================================

    if query ~= "" then

        table.insert(
            params,
            "s="
            .. HttpService:UrlEncode(query)
        )

    end

    -- =====================================
    -- Pagination Cursor
    -- =====================================
    if apiCursor ~= nil
        and tostring(apiCursor) ~= "" then

        table.insert(
            params,
            "after="
            .. HttpService:UrlEncode(
                tostring(apiCursor)
            )
        )
    end

    -- =====================================
    -- Endpoint
    -- =====================================

    local endpoint =
        WEAREDEVS_API
        .. "?"

    return endpoint
        .. table.concat(params, "&")

end

-- =========================================
-- HaxHell Search URL
-- =========================================

buildHaxHellURL = function(page)

    local query = tb.Text or ""

    query =
        query:gsub("^%s+", "")
            :gsub("%s+$", "")

    local creator = owninput.Text or ""

    creator =
        creator:gsub("^%s+", "")
              :gsub("%s+$", "")

    local gameInputText = gameinput.Text or ""

    gameInputText =
        gameInputText:gsub("^%s+", "")
                      :gsub("%s+$", "")

    local params = {}

    -- =====================================
    -- Page
    -- =====================================

    table.insert(
        params,
        "page=" .. tostring(page)
    )

    -- =====================================
    -- Limit
    -- =====================================

    table.insert(
        params,
        "limit=20"
    )

    -- =====================================
    -- Search
    -- =====================================

    if query ~= "" then

        table.insert(
            params,
            "q="
            .. HttpService:UrlEncode(query)
        )

    end

    -- =====================================
    -- Creator
    -- =====================================

    if creator ~= "" then

        table.insert(
            params,
            "username="
            .. HttpService:UrlEncode(creator)
        )

    end

    -- =====================================
    -- Game
    -- =====================================

    if gameInputText ~= "" then

        table.insert(
            params,
            "gameName="
            .. HttpService:UrlEncode(gameInputText)
        )

    end

    -- =====================================
    -- Patched
    -- =====================================

    if filterType.Patched == "With" then

        table.insert(
            params,
            "patched=true"
        )

    elseif filterType.Patched == "Without" then

        table.insert(
            params,
            "patched=false"
        )

    end

    -- =====================================
    -- Key
    -- =====================================

    if filterType.Key == "With" then

        table.insert(
            params,
            "keySystem=true"
        )

    elseif filterType.Key == "Without" then

        table.insert(
            params,
            "keySystem=false"
        )

    end

    -- =====================================
    -- Sort
    -- =====================================

    if sortType == "Views" then

        table.insert(
            params,
            "sort=views"
        )

    elseif sortType == "Creation Date" then

        table.insert(
            params,
            "sort=latest"
        )

    elseif sortType == "Update Date" then

        table.insert(
            params,
            "sort=updated"
        )

    end

    -- =====================================
    -- Unsupported Sorts
    -- =====================================
    -- Likes
    -- Dislikes
    -- Match Accuracy
    --
    -- Intentionally not sent because
    -- HaxHell does not provide a directly
    -- compatible sort parameter for these.

    -- =====================================
    -- Sort Order
    -- =====================================
    -- HaxHell does not use our
    -- Ascending / Descending parameter.
    --
    -- Intentionally omitted.

    -- =====================================
    -- Endpoint
    -- =====================================

    local endpoint =
        HAXHELL_API .. "?"

    return endpoint
        .. table.concat(params, "&")

end

-- =========================================
-- RScripts Search URL
-- =========================================

buildRScriptsURL = function(page)

    local query = tb.Text or ""

    query =
        query:gsub("^%s+", "")
            :gsub("%s+$", "")

    local gameInputText = gameinput.Text or ""

    gameInputText =
        gameInputText:gsub("^%s+", "")
                      :gsub("%s+$", "")

    local params = {}

    -- =====================================
    -- Page
    -- =====================================

    table.insert(
        params,
        "page=" .. tostring(page)
    )

    -- =====================================
    -- Limit
    -- =====================================

    table.insert(
        params,
        "limit=20"
    )

    -- =====================================
    -- Search
    -- =====================================

    if query ~= "" then

        table.insert(
            params,
            "q="
            .. HttpService:UrlEncode(query)
        )

    end

    -- =====================================
    -- Game
    -- =====================================

    if gameInputText ~= "" then

        local gameId =
            tonumber(gameInputText)

        if gameId then

            table.insert(
                params,
                "placeId="
                .. tostring(math.floor(gameId))
            )

        end

    end

    -- =====================================
    -- Script Type
    -- =====================================

    if filterType.ScriptType == "Free" then

        table.insert(
            params,
            "freeOnly=true"
        )

    end

    -- =====================================
    -- Verified
    -- =====================================

    if filterType.Verified == "With" then

        table.insert(
            params,
            "verifiedOnly=true"
        )

    end

    -- =====================================
    -- Key
    -- =====================================

    if filterType.Key == "Without" then

        table.insert(
            params,
            "noKeySystem=true"
        )

    end

    -- =====================================
    -- Sort By
    -- =====================================

    if sortType == "Views" then

        table.insert(
            params,
            "sort=most-views"
        )

    elseif sortType == "Likes" then

        table.insert(
            params,
            "sort=most-likes"
        )

    elseif sortType == "Creation Date" then

        table.insert(
            params,
            "sort=newest"
        )

    end

    -- =====================================
    -- Unsupported Filters
    -- =====================================
    --
    -- Creator
    -- Universal
    -- Patched
    --
    -- Intentionally omitted.

    -- =====================================
    -- Unsupported Sorts
    -- =====================================
    --
    -- Dislikes
    -- Update Date
    -- Match Accuracy
    --
    -- Intentionally omitted.

    -- =====================================
    -- Sort Order
    -- =====================================
    --
    -- Ascending / Descending is not supported
    -- by this API, so it is intentionally omitted.

    -- =====================================
    -- Endpoint
    -- =====================================

    return RSCRIPTS_API
        .. "/v1/scripts?"
        .. table.concat(params, "&")

end

-- =========================================
-- API Response Extractor
-- =========================================

local function getAPIResults(api, data)

	if api == "ScriptBlox" then

		if data
			and data.result
			and data.result.scripts then

			return data.result.scripts
		end

	elseif api == "WeAreDevs" then

		if data
			and data.scripts then

			return data.scripts
		end

	elseif api == "HaxHell" then

		if data
			and data.data then

			return data.data
		end

	elseif api == "RScripts" then

		if data
			and data.data then

			return data.data
		end

	end

	return {}
end

requestAPI = function(url, headers)

	-- API ที่ไม่ต้องใช้ headers
	if not headers or next(headers) == nil then

		local success, response = pcall(function()
			return game:HttpGet(url)
		end)

		if not success then
			return false, response
		end

		return true, response
	end

	-- API ที่ต้องใช้ headers
	-- เช่น RScripts
	if request then

		local success, result = pcall(function()

			return request({
				Url = url,
				Method = "GET",
				Headers = headers
			})

		end)

		if not success then
			return false, result
		end

		if not result then
			return false, "No response"
		end

		local statusCode = tonumber(result.StatusCode)
		if statusCode and (statusCode < 200 or statusCode >= 300) then
			return false,
				"HTTP " .. tostring(statusCode)
				.. ": " .. tostring(result.StatusMessage or result.Body or "Request failed")
		end

		return true, result.Body
	end

	return false,
		"HTTP request function with headers is unavailable"

end

local function getAPIHasMore(api, data)

    if type(data) ~= "table" then
        return false
    end

    if api == "ScriptBlox" then

        local result = data.result

        if type(result) ~= "table" then
            return false
        end

        -- ScriptBlox returns `nextPage` as a page number.
        -- `totalPages` is also available on fetch responses.
        local nextPage = tonumber(result.nextPage)
        local totalPages = tonumber(result.totalPages)

        if nextPage and nextPage > 0 then
            return not totalPages or nextPage <= totalPages
        end

        return false

    elseif api == "WeAreDevs" then

        -- WeAreDevs pagination is cursor based. A non-empty
        -- `after` cursor means another page can be requested.
        local after = data.after

        return after ~= nil and tostring(after) ~= ""

    elseif api == "HaxHell" then

        return data.pagination
            and data.pagination.hasMore == true

    elseif api == "RScripts" then

        return data.meta
            and data.meta.hasNextPage == true

    end

    return false

end

-- =========================================
-- Fetch Function
-- =========================================

fetchScripts = function(page)

	if loading then
		return
	end

	local url = buildSearchURL(page)

	if not url then

		warn(
			"❌ API not supported: "
			.. tostring(currentAPI)
		)

		return
	end

	loading = true

	--------------------------------------------------
	-- REQUEST
	--------------------------------------------------

	local headers = {}

	if currentAPI == "RScripts" then

		if not RSCRIPTS_API_KEY
			or RSCRIPTS_API_KEY == "" then

			loading = false
			warn("❌ RScripts requires an API key. Set RSCRIPTS_API_KEY before loading SearchPreview.lua.")
			return false

		end

		headers["Authorization"] =
			"Bearer " .. RSCRIPTS_API_KEY

	end

	local success, response =
		requestAPI(url, headers)

	if not success then

		loading = false

		warn(
			"❌ "
			.. tostring(currentAPI)
			.. " request failed:",
			response
		)

		return
	end

	--------------------------------------------------
	-- JSON
	--------------------------------------------------

	local decodeSuccess, data =
		pcall(function()

			return HttpService:JSONDecode(response)

		end)

	if not decodeSuccess then

		loading = false

		warn(
			"❌ "
			.. tostring(currentAPI)
			.. " JSON decode failed:",
			data
		)

		return
	end

	--------------------------------------------------
	-- UPDATE PAGINATION CURSOR
	--------------------------------------------------
	if currentAPI == "WeAreDevs" then
		apiCursor = data.after
	end

	--------------------------------------------------
	-- GET RESULTS
	--------------------------------------------------

	local scripts =
		getAPIResults(currentAPI, data)

	if type(scripts) ~= "table" then
		scripts = {}
	end

	--------------------------------------------------
	-- NORMALIZE + RENDER
	--------------------------------------------------

	for _, scriptData in ipairs(scripts) do

		local normalized =
			normalizeScript(
				currentAPI,
				scriptData
			)

		if normalized then
      normalized.image =
			getScriptImage(normalized)

			sipt(normalized)
		end

	end

	local hasMore =
		getAPIHasMore(currentAPI, data)

	loading = false

	if hasMore then
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

clearCards = function()

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

refreshSearch = function()

    if loading then
        return
    end

    clearCards()

    currentPage = 1
    apiCursor = nil

    fetchScripts(currentPage)
end

tb.FocusLost:Connect(function(enterPressed)

    if not enterPressed then
        return
    end

    refreshSearch()

end)

-- GameInput must also trigger a refresh.
gameinput.FocusLost:Connect(function(enterPressed)

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

marked = function(tit, sour, scriptId)

    local body = Instance.new("Frame")
    body.Name = "Body"
    body.BackgroundColor3 = Color3.new(1,1,1)
    body.Size = UDim2.new(1,-5,0,120)
    body.BorderMode = Enum.BorderMode.Inset
    body.BorderSizePixel = 5
    body.Parent = bscroll
    Corner(0,5,body)
    Gradient(
        body,
        -45,0,0,
        Color3.fromRGB(255,255,0),
        Color3.fromRGB(255,85,255)
    )

    body:SetAttribute("ScriptId", tostring(scriptId or ""))
    body:SetAttribute("ScriptSource", tostring(sour or ""))

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1,0,0,25)
    title.BackgroundTransparency = 1
    title.BorderMode = Enum.BorderMode.Inset
    title.BorderSizePixel = 3
    title.RichText = true
    title.TextScaled = true
    title.TextColor3 = Color3.new(0,0,0)

    local titleText = tostring(tit or "")
    if titleText == "" or titleText == "nil" then
        titleText = "Untitled"
    end

    title.Text = "<b>" .. titleText .. "</b>"
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Top
    title.Parent = body

    local sou = Instance.new("TextLabel")
    sou.Name = "Source"
    sou.Size = UDim2.new(1,0,0,20)
    sou.Position += UDim2.new(0,0,0,25)
    sou.BackgroundTransparency = 1
    sou.BorderMode = Enum.BorderMode.Inset
    sou.BorderSizePixel = 3
    sou.TextScaled = true
    sou.TextColor3 = Color3.new(0,0,0)

    local sourceText = tostring(sour or "")
    if sourceText == "" or sourceText == "nil" then
        sourceText = "Unknown"
    end

    sou.Text = "From: " .. sourceText
    sou.TextXAlignment = Enum.TextXAlignment.Left
    sou.TextYAlignment = Enum.TextYAlignment.Top
    sou.Parent = body

    local exe = Instance.new("TextButton")
    exe.Name = "Execute"
    exe.Size = UDim2.new(0.5,-5,0,20)
    exe.Position = UDim2.new(0,0,1,-20)
    exe.BackgroundColor3 = Color3.new(0,1,0)
    exe.TextSize = 10
    exe.RichText = true
    exe.TextColor3 = Color3.new(0,0,0)
    exe.Text = "<b>Execute</b>"
    exe.Parent = body
    Corner(0,5,exe)

    local cy = exe:Clone()
    cy.Name = "Copy"
    cy.Position = UDim2.new(0.5,0,1,-20)
    cy.BackgroundColor3 = Color3.fromRGB(153,153,153)
    cy.TextColor3 = Color3.new(1,1,1)
    cy.Text = "<b>Copy</b>"
    cy.Parent = body

    local view = Instance.new("TextButton")
    view.Name = "View"
    view.Size = UDim2.new(1,-5,0,20)
    view.Position = UDim2.new(0,0,1,-42)
    view.BackgroundColor3 = Color3.new(1,1,0)
    view.TextSize = 10
    view.RichText = true
    view.TextColor3 = Color3.new(0,0,0)
    view.Text = "<b>View</b>"
    view.Parent = body
    Corner(0,5,view)

    local rem = Instance.new("TextButton")
    rem.Name = "Remove"
    rem.Size = UDim2.new(1,-5,0,20)
    rem.Position = UDim2.new(0,0,1,-64)
    rem.BackgroundColor3 = Color3.new(1,0,0)
    rem.TextSize = 8
    rem.RichText = true
    rem.TextColor3 = Color3.new(1,1,1)
    rem.Text = "<b>Remove from the bookmark page</b>"
    rem.Parent = body
    Corner(0,5,rem)

    local function getBookmarkData(button)
        button.Text = "<b>Getting data...</b>"

        local oldAPI = currentAPI
        switchBookmarkAPI(sourceText)

        local fallback = {
            id = scriptId,
            name = titleText
        }

        local detail = fetchIndividual(
            scriptId,
            fallback
        )

        return detail
    end

    -- =================================
    -- View
    -- =================================

    view.MouseButton1Click:Connect(function()

        if not scriptId or tostring(scriptId) == "" then
            view.Text = "<b>Data unavailable</b>"
            task.wait(1)
            view.Text = "<b>View</b>"
            return
        end

        local detail = getBookmarkData(view)

        if type(detail) ~= "table" then
            view.Text = "<b>Failed to get data</b>"
            task.wait(1)
            view.Text = "<b>View</b>"
            return
        end

        loadViewData(
            {
                id = scriptId,
                name = titleText
            },
            detail
        )

        task.wait(1)
        view.Text = "<b>View</b>"
    end)

    -- =================================
    -- Execute
    -- =================================

    exe.MouseButton1Click:Connect(function()

        if not scriptId or tostring(scriptId) == "" then
            exe.Text = "<b>Data unavailable</b>"
            task.wait(1)
            exe.Text = "<b>Execute</b>"
            return
        end

        local detail = getBookmarkData(exe)
        local raw = nil

        if type(detail) == "table" then
            raw = detail.raw
        end

        if raw and tostring(raw) ~= "" then
            if loadstring then
                loadstring(tostring(raw))()
                exe.Text = "<b>Executed</b>"
            else
                exe.Text = "<b>Execution unsupported</b>"
            end
        else
            exe.Text = "<b>No Source Found</b>"
        end

        task.wait(1)
        exe.Text = "<b>Execute</b>"
    end)

    -- =================================
    -- Copy
    -- =================================

    cy.MouseButton1Click:Connect(function()

        if not scriptId or tostring(scriptId) == "" then
            cy.Text = "<b>Data unavailable</b>"
            task.wait(1)
            cy.Text = "<b>Copy</b>"
            return
        end

        local detail = getBookmarkData(cy)
        local raw = nil

        if type(detail) == "table" then
            raw = detail.raw
        end

        if raw and tostring(raw) ~= "" then
            if setclipboard then
                setclipboard(tostring(raw))
                cy.Text = "<b>Copied</b>"
            else
                cy.Text = "<b>Clipboard Unsupported</b>"
            end
        else
            cy.Text = "<b>No Code</b>"
        end

        task.wait(1)
        cy.Text = "<b>Copy</b>"
    end)

    -- =================================
    -- Remove
    -- =================================

    rem.MouseButton1Click:Connect(function()
        removeBookmarkData(
            titleText,
            sourceText,
            scriptId
        )

        body:Destroy()
    end)

end


-- =========================================
-- Load saved bookmarks
-- =========================================
loadBookmarkFile()

for _, item in ipairs(bookmarks) do
    marked(
        item.title,
        item.source,
        item.id
    )
end
