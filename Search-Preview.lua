-- searcher... yes. 4.2 (1)

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

local function tweenSize(obj, size, time)
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(
            time,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {Size = size}
    )

    tween:Play()
    return tween
end

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

if menu.Search then
   menu.Search:Destroy()
end

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

local vp = Instance.new("CanvasGroup")
vp.Name = "ViewPage"
vp.Size = UDim2.new(1,0,1,0)
vp.BackgroundColor3 = Color3.new(1,1,1)
vp.BorderMode = Enum.BorderMode.Inset
vp.BorderSizePixel = 5
vp.Active = false
vp.Parent = Page
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
cre.Text = "@Username"
cre.Parent = vp

local like = Instance.new("TextLabel")
like.Name = "Likes"
like.Position = UDim2.new(0,0,0,175)
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
dislike.Position = UDim2.new(1,0,0,175)
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
visit.Position = UDim2.new(0,0,0,200)
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

local codescroll = Instance.new("ScrollingFrame")
codescroll.Name = "CodeScroll"
codescroll.Position = UDim2.new(0,0,0,230)
codescroll.Size = UDim2.new(1,0,0,100)
codescroll.BackgroundColor3 = Color3.new(0,0,0)
codescroll.ScrollBarThickness = 10
codescroll.ScrollingDirection = Enum.ScrollingDirection.Y
codescroll.CanvasSize = UDim2.new(0,0,10000,0)
codescroll.Parent = vp

local codebox = Instance.new("TextBox")
codebox.Name = "CodeBox"
codebox.Position = UDim2.new(0,0,0,0)
codebox.Size = UDim2.new(1,-11,1,0)
codebox.BackgroundTransparency = 1
codebox.TextColor3 = Color3.new(0,1,0)
codebox.Font = Enum.Font.Code
codebox.ClearTextOnFocus = false
codebox.PlaceholderText = "Hmm... Looks like there no script in here. Please make sure you select the script or the owner didn't put a script yet."
codebox.PlaceholderColor3 = Color3.new(1,1,1)
codebox.Text = ""
codebox.TextSize = 11
codebox.TextWrapped = true
codebox.TextXAlignment = Enum.TextXAlignment.Left
codebox.TextYAlignment = Enum.TextYAlignment.Top
codebox.Parent = codescroll


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
tb.RichText = true
tb.Text = "<b><font color='rgb(255,0,0)' size='10'>YOU JUST ENTER PREVIEW VERSION! TO USE OLD VERSION PLEASE SCOLL DOWN THEN CLICK SWITCH.</font></b>"
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

back.Visible = true

-----

local function sipt()
  local body = Instance.new("Frame")
  body.Name = "Body"
  body.Size = UDim2.new(0.98,0,0,130)
  body.BorderMode = Enum.BorderMode.Inset
  body.BackgroundColor3 = Color3.new(1,1,1)
  body.BorderSizePixel = 7
  body.Parent = scr
  Corner(0,8,body)
  local bd_str = Stroke(body, ASMBorder, 255,255,255, LJMRound, 3, 0)
  bd_str.BorderStrokePosition = Enum.BorderStrokePosition.Inner
  Gradient(body, 0, 0, 0, Color3.fromRGB(0,255,255), Color3.fromRGB(170,0,255))

  local state = Instance.new("Frame")
  state.Name = "State"
  state.Position = UDim2.new(0,0,0,90)
  state.Size = UDim2.new(1,0,0,25)
  state.BackgroundTransparency = 1
  state.Parent = body
  ListLayout(state, 0, 3, HLeft, VCenter, SLayout, FillH)

  local Verified = Instance.new("TextLabel")
  Verified.Name = "Verified"
  Verified.Size = UDim2.new(0,100,1,0)
  Verified.BackgroundTransparency = 0.3
  Verified.BackgroundColor3 = Color3.fromRGB(0,85,255)
  Verified.TextColor3 = Color3.fromRGB(0,255,255)
  Verified.TextSize = 13
  Verified.RichText = true
  Verified.Text = "<b>Verified</b>"
  Verified.Visible = false
  Verified.Active = false
  Verified.Parent = state
  Corner(0,8,Verified)
 
  local Key = Instance.new("TextLabel")
  Key.Name = "Key"
  Key.Size = UDim2.new(0,60,1,0)
  Key.BackgroundTransparency = 0.3
  Key.BackgroundColor3 = Color3.fromRGB(255,170,0)
  Key.TextColor3 = Color3.fromRGB(255,255,0)
  Key.TextSize = 13
  Key.RichText = true
  Key.Text = "<b>Key</b>"
  Key.Visible = false
  Key.Active = false
  Key.Parent = state
  Corner(0,8,Key)
  
  local Patched = Instance.new("TextLabel")
  Patched.Name = "Patched"
  Patched.Size = UDim2.new(0,100,1,0)
  Patched.BackgroundTransparency = 0.3
  Patched.BackgroundColor3 = Color3.fromRGB(170,0,0)
  Patched.TextColor3 = Color3.fromRGB(255,0,0)
  Patched.TextSize = 13
  Patched.RichText = true
  Patched.Text = "<b>Patched</b>"
  Patched.Visible = false
  Patched.Active = false
  Patched.Parent = state
  Corner(0,8,Patched)
  
  local Free = Instance.new("TextLabel")
  Free.Name = "Free"
  Free.Size = UDim2.new(0,70,1,0)
  Free.BackgroundTransparency = 0.3
  Free.BackgroundColor3 = Color3.fromRGB(0,170,0)
  Free.TextColor3 = Color3.fromRGB(0,255,0)
  Free.TextSize = 13
  Free.RichText = true
  Free.Text = "<b>Free</b>"
  Free.Visible = false
  Free.Active = false
  Free.Parent = state
  Corner(0,8,Free)
  
  local Paid = Instance.new("TextLabel")
  Paid.Name = "Paid"
  Paid.Size = UDim2.new(0,70,1,0)
  Paid.BackgroundTransparency = 0.3
  Paid.BackgroundColor3 = Color3.fromRGB(170,85,0)
  Paid.TextColor3 = Color3.fromRGB(255,85,0)
  Paid.TextSize = 13
  Paid.RichText = true
  Paid.Text = "<b>Paid</b>"
  Paid.Visible = false
  Paid.Active = false
  Paid.Parent = state
  Corner(0,8,Paid)
  
  local Img = Instance.new("ImageLabel")
  Img.Name = "Preview"
  Img.Size = UDim2.new(0,160,0,85)
  Img.BackgroundColor3 = Color3.new(1,1,1)
  Img.Image = "rbxassetid://136962703149104"
  Img.Parent = body
  Corner(0,3,Img)

  local de = Instance.new("TextLabel")
  de.Name = "Details"
  de.BackgroundTransparency = 1
  de.Position = UDim2.new(0,165,0,0)
  de.Size = UDim2.new(1,-270,0,30)
  de.TextXAlignment = Enum.TextXAlignment.Left
  de.TextYAlignment = Enum.TextYAlignment.Top
  de.RichText = true
  de.TextColor3 = Color3.new(0,0,0)
  de.Text = "<font size='12'><b>Script Title</b></font> \n📌 Universal Script \nBy @Username \nClick 'View' for more details."
  de.Parent = body

  local view = Instance.new("TextButton")
  view.Name = "ViewButton"
  view.Position = UDim2.new(1,-100,0,0)
  view.Size = UDim2.new(0,100,0,35)
  view.BackgroundColor3 = Color3.new(1,1,1)
  view.TextColor3 = Color3.new(0,0,0)
  view.TextSize = 16
  view.RichText = true
  view.Text = "<b><i>View</i></b>"
  view.Parent = body
  Corner(0,3,view)
  Gradient(view, -45,0,0, Color3.fromRGB(0,255,85), Color3.fromRGB(255,255,0))
  Stroke(view, ASMBorder, 255,255,255, LJMRound, 2 ,0)
  
  view.MouseButton1Click:Connect(function()
    tweenSize(view, UDim2.new(0,80,0,15), 0.1).Completed:Wait()
    tweenSize(view, UDim2.new(0,100,0,35), 0.1)
    Page.Visible = true
    tweenSize(Page, UDim2.new(0.35,-5,1,0), 0.4)
    tweenSize(List, UDim2.new(0.65,0,1,0), 0.4)
  end)
end

backs.MouseButton1Click:Connect(function()
  tweenSize(Page, UDim2.new(0,0,1,0), 0.4)
  tweenSize(List, UDim2.new(1,0,1,0), 0.4).Completed:Wait()
  Page.Visible = false
end)

-----

local function load()
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
local lm_str = Stroke(lm, ASMBorder, 60,60,60, LJMRound, 3, 0)
lm_str.BorderStrokePosition = Enum.BorderStrokePosition.Inner
end

sipt()
sipt()
sipt()
load()
