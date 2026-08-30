-- searcher... yes. 3

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

local menu = CoreGui:WaitForChild("ExperienceSettings")  
    :WaitForChild("Menu")  
  
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

local Page = List:Clone()
Page.Name = "Page"
Page.Size = UDim2.new(0,-5,1,0)
Page.BorderMode = Enum.BorderMode.Inset
Page.BorderSizePixel = 5
Page.Parent = sea

local tb = Instance.new("TextBox")
tb.Name = "SearchInput"
tb.Size = UDim2.new(1,0,0,45)
tb.BackgroundColor3 = Color3.fromRGB(0,170,255)
tb.BackgroundTransparency = 0.3
tb.BorderMode = Enum.BorderMode.Inset
tb.BorderSizePixel = 6
tb.TextSize = 16
tb.Text = ""
tb.PlaceholderText = "Search here!"
tb.PlaceholderColor3 = Color3.new(0,0,0)
tb.TextColor3 = Color3.new(1,1,1)
tb.TextXAlignment = Enum.TextXAlignment.Left
tb.Parent = List
Corner(0,8,tb)

local tb_str = Stroke(tb,ASMBorder, 255,255,255, LJMRound, 2, 0)
Gradient(tb_str, 90, 0,0, Color3.fromRGB(255,255,255), Color3.fromRGB(0,255,255))

local scr = Instance.new("ScrollingFrame")
scr.Name = "Scrips"
scr.Position = UDim2.new(0,0,0,50)
scr.Size = UDim2.new(1,0,0.878,0)
scr.BackgroundColor3 = Color3.new(255,255,255)
scr.BackgroundTransparency = 0.7
scr.ScrollBarThickness = 2
scr.CanvasSize = UDim2.new(0,0,0,0)
scr.Parent = List
Corner(0,8,scr)
Gradient(scr, 0,0,0, Color3.fromRGB(0,0,172), Color3.fromRGB(0,255,255))

dear.Parent = scr
dear.Visible = true

local back = Instance.new("TextButton")
back.Name = "Back"
back.Size = UDim2.new(0,200,0,50)
back.Position = UDim2.new(0.5,10,0.8,0)
back.BackgroundColor3 = Color3.new(1,0,0)
back.TextSize = 16
back.RichText = true
back.TextWrapped = true
back.TextColor3 = Color3.new(1,1,1)
back.Text = "Switch to <b>Old UI</b>?"
back.Parent = scr
Corner(0,8,back)
Stroke(back, ASMBorder, 100,0,0, LJMRound, 3, 0)

back.MouseButton1Click:Connect(function()
    sea:Destroy()
    wait(0.5) 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/397db6d363933259c69d4683830484f67e13b28b/Search.lua"))()
end)

local pre = Instance.new("TextButton")
pre.Name = "Preview"
pre.Size = UDim2.new(0,200,0,50)
pre.Position = UDim2.new(0.5,-210,0.8,0)
pre.BackgroundColor3 = Color3.new(0,1,0)
pre.TextSize = 16
pre.RichText = true
pre.TextWrapped = true
pre.TextColor3 = Color3.new(0,0,0)
pre.Text = "Switch to <b>Preview version</b>?"
pre.Parent = scr
Corner(0,8,pre)
Stroke(pre, ASMBorder, 0,170,0, LJMRound, 3, 0)

pre.MouseButton1Click:Connect(function()
    wait(0.5)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/ExperienceSettings-(loadstring)/Search-Preview.lua"))()
end)
