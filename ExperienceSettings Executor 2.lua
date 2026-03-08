-- Name 0.13

------------------------------------------------------------------------------------------

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

-- 3D/2D Destroy
local Debris = game:GetService("Debris")

-- 3D Wprkspace
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local Camera = Workspace.CurrentCamera

-- Third Party
local HttpService = game:GetService("HttpService")

-- Audio / Feedback
local SoundService = game:GetService("SoundService")

-- Commerce / Monetization
local MarketplaceService = game:GetService("MarketplaceService")

-- Runtime / Frame Updates
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

-- Animation / Transitions
local TweenService = game:GetService("TweenService")

-- Input (Desktop / Mobile)
local UserInputService = game:GetService("UserInputService")
local TouchInputService = game:GetService("TouchInputService")

---------------------------------------------------------------------------------------
local color = {
    red = Color3.fromRGB(255,0,0), -- suitable for error
    orange = Color3.fromRGB(255,85,0), -- suitable for somthing
    yellow = Color3.fromRGB(255,255,0), -- sutiable for warning
    green = Color3.fromRGB(0,255,0), -- suitable for working
    cyan = Color3.fromRGB(0,255,255), --suitablr for something
    blue = Color3.fromRGB(0,0,255), -- sutiable for information
    pink = Color3.fromRGB(255,0,255), -- suitable for something
    purple = Color3.fromRGB(170,0,255), -- suitable for something
    nor = Color3.fromRGB(255,255,255) -- sutiable for custom
}

-- ฟังก์ชันแจ้งเตือน
local function noti(times, text, colorValue)
    local finalColor = colorValue or color.nor

    -- กล่องแจ้งเตือน
    local txt = Instance.new("TextLabel")
    txt.Name = "Notify"
    txt.BackgroundColor3 = Color3.fromRGB(18,18,21)
    txt.BackgroundTransparency = 0.5
    txt.TextWrap = true
    txt.RichText = true
    txt.TextScaled = false
    txt.TextSize = 18
    txt.Font = Enum.Font.GothamBold
    txt.Text = tostring(text)
    txt.TextColor3 = finalColor
    txt.ClipsDescendants = true
    txt.Parent = CoreGui["ExperienceSettings-Executor"].Main.Background.TopNoity

    Corner(0.15,0,txt)

    -- แปลง Color3 → RGB
    local r = finalColor.R * 255
    local g = finalColor.G * 255
    local b = finalColor.B * 255

    Stroke(txt, ASMBorder, r, g, b, LJMRound, 1, 0)

    -- คำนวณขนาดข้อความ
    local textSize = TextService:GetTextSize(
        txt.Text,
        txt.TextSize,
        txt.Font,
        Vector2.new(1000, 100)
    )

    local padding = 30
    local finalSize = UDim2.new(0, textSize.X + padding, 0, textSize.Y + 20)

    -- เริ่มต้นเป็นศูนย์ก่อน
    txt.Size = UDim2.new(0,0,0,0)

    -- Tween ขยายเข้า
    TweenService:Create(
        txt,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = finalSize}
    ):Play()

    -- time bar
    local bar = Instance.new("Frame")
    bar.Name = "time"
    bar.Position = UDim2.new(0,0,0.9,0)
    bar.Size = UDim2.new(1,0,0.05,0)
    bar.BackgroundColor3 = finalColor
    bar.BorderSizePixel = 0
    bar.Parent = txt

    -- Tween time bar
    local barTween = TweenService:Create(
        bar,
        TweenInfo.new(times, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0,0,0.05,0)}
    )
    barTween:Play()

    -- เมื่อ time หมด
    barTween.Completed:Connect(function()

        local hideTween = TweenService:Create(
            txt,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {
                Size = UDim2.new(0,0,0,0),
                BackgroundTransparency = 1,
                TextTransparency = 1
            }
        )
        hideTween:Play()

        hideTween.Completed:Connect(function()
            txt:Destroy()
        end)
    end)
end

--------------------------------------------------
-- PATH
--------------------------------------------------

local ASSET_PATH = "ExperienceSettings-Executor/Assets"
local TOTAL_ASSETS = 57

--------------------------------------------------
-- ICON TABLE (ใส่ icon เองตรงนี้)
--------------------------------------------------

local icons = {
["info"] = getcustomasset("ExperienceSettings-Executor/Assets/info.png"),
["print"] = getcustomasset("ExperienceSettings-Executor/Assets/print.png"),
["error"] = getcustomasset("ExperienceSettings-Executor/Assets/error.png"),
["warn"] = getcustomasset("ExperienceSettings-Executor/Assets/warn.png"),
["cam"] = getcustomasset("ExperienceSettings-Executor/Assets/cam.png"),
["white_square"] = getcustomasset("ExperienceSettings-Executor/Assets/white-square.png"),
["black-shade"] = getcustomasset("ExperienceSettings-Executor/Assets/black-shade.png"),
["gray-shade"] = getcustomasset("ExperienceSettings-Executor/Assets/gray-shade.png"),
["white-shade"] = getcustomasset("ExperienceSettings-Executor/Assets/white-shade.png"),
["pink-shade"] = getcustomasset("ExperienceSettings-Executor/Assets/pink-shade.png"),
["blue-shade"] = getcustomasset("ExperienceSettings-Executor/Assets/blue-shade.png"),
["cyan-shade"] = getcustomasset("ExperienceSettings-Executor/Assets/cyan-shade.png"),
["yellow-shade"] = getcustomasset("ExperienceSettings-Executor/Assets/yellow-shade.png"),
["orange-shade"] = getcustomasset("ExperienceSettings-Executor/Assets/orange-shade.png"),
["red-shade"] = getcustomasset("ExperienceSettings-Executor/Assets/red-shade.png"),
["select"] = getcustomasset("ExperienceSettings-Executor/Assets/select.png"),
["cross"] = getcustomasset("ExperienceSettings-Executor/Assets/cross.png"),
["debug"] = getcustomasset("ExperienceSettings-Executor/Assets/debug.png"),
["autoexe"] = getcustomasset("ExperienceSettings-Executor/Assets/autoexe.png"),
["wearedevs-net"] = getcustomasset("ExperienceSettings-Executor/Assets/wearedevs-net.png"),
["scriptblox-com"] = getcustomasset("ExperienceSettings-Executor/Assets/scriptblox-com.png"),
["down"] = getcustomasset("ExperienceSettings-Executor/Assets/down.png"),
["up"] = getcustomasset("ExperienceSettings-Executor/Assets/up.png"),
["left"] = getcustomasset("ExperienceSettings-Executor/Assets/left.png"),
["right"] = getcustomasset("ExperienceSettings-Executor/Assets/right.png"),
["left-arrow"] = getcustomasset("ExperienceSettings-Executor/Assets/left-arrow.png"),
["right-arrow"] = getcustomasset("ExperienceSettings-Executor/Assets/right-arrow.png"),
["white-ball-fill"] = getcustomasset("ExperienceSettings-Executor/Assets/white-ball-fill.png"),
["white-ball"] = getcustomasset("ExperienceSettings-Executor/Assets/white-ball.png"),
["check-in"] = getcustomasset("ExperienceSettings-Executor/Assets/check-in.png"),
["check-out"] = getcustomasset("ExperienceSettings-Executor/Assets/check-out.png"),
["plus"] = getcustomasset("ExperienceSettings-Executor/Assets/plus.png"),
["plus-cyan"] = getcustomasset("ExperienceSettings-Executor/Assets/plus-cyan.png"),
["erase"] = getcustomasset("ExperienceSettings-Executor/Assets/erase.png"),
["copy"] = getcustomasset("ExperienceSettings-Executor/Assets/copy.png"),
["paste"] = getcustomasset("ExperienceSettings-Executor/Assets/paste.png"),
["paste-and-execute"] = getcustomasset("ExperienceSettings-Executor/Assets/paste-and-execute.png"),
["execute"] = getcustomasset("ExperienceSettings-Executor/Assets/execute.png"),
["settings"] = getcustomasset("ExperienceSettings-Executor/Assets/settings.png"),
["cross-white"] = getcustomasset("ExperienceSettings-Executor/Assets/cross-white.png"),
["console"] = getcustomasset("ExperienceSettings-Executor/Assets/console.png"),
["bookmark"] = getcustomasset("ExperienceSettings-Executor/Assets/bookmark.png"),
["folder"] = getcustomasset("ExperienceSettings-Executor/Assets/folder.png"),
["editor"] = getcustomasset("ExperienceSettings-Executor/Assets/editor.png"),
["home"] = getcustomasset("ExperienceSettings-Executor/Assets/home.png"),
["unknown-icon"] = getcustomasset("ExperienceSettings-Executor/Assets/unknown-icon.png"),
["lua-file"] = getcustomasset("ExperienceSettings-Executor/Assets/lua-file.png"),
["exe"] = getcustomasset("ExperienceSettings-Executor/Assets/exe.png"),
["ipa"] = getcustomasset("ExperienceSettings-Executor/Assets/ipa.png"),
["apk"] = getcustomasset("ExperienceSettings-Executor/Assets/apk.png"),
["zip"] = getcustomasset("ExperienceSettings-Executor/Assets/zip.png"),
["unknown-file"] = getcustomasset("ExperienceSettings-Executor/Assets/unknown-file.png"),
["png"] = getcustomasset("ExperienceSettings-Executor/Assets/png.png"),
["7z"] = getcustomasset("ExperienceSettings-Executor/Assets/7z.png"),
["file"] = getcustomasset("ExperienceSettings-Executor/Assets/file.png"),
["folder-"] = getcustomasset("ExperienceSettings-Executor/Assets/folder-.png"),
["search"] = getcustomasset("ExperienceSettings-Executor/Assets/search.png"),
}

--------------------------------------------------
-- COUNT PNG
--------------------------------------------------

local function countAssets()

	if not isfolder or not isfolder(ASSET_PATH) then
		return 0
	end

	local count = 0

	for _,file in pairs(listfiles(ASSET_PATH)) do
		if file:match("%.png$") then
			count += 1
		end
	end

	return count

end

--------------------------------------------------
-- LOAD ICONS
--------------------------------------------------

local function loadIcons()

	for name,_ in pairs(icons) do

		local path = ASSET_PATH.."/"..name..".png"

		if isfile and isfile(path) then
			icons[name] = getcustomasset(path)
		end

	end

end

--------------------------------------------------
-- CHECK ASSETS
--------------------------------------------------

local current = countAssets()
local missing = TOTAL_ASSETS - current

if missing > 0 then

	local assetWord = (missing == 1) and "Asset" or "Assets"
	local isWord = (missing == 1) and "is" or "are"

	if noti then
		noti(
			15,
			"[ "..missing.." "..assetWord.." of "..current.."/"..TOTAL_ASSETS.." ] "..assetWord.." "..isWord.." missing. Please type 'getLoad:Data(Download.Asset(\"png\"))' or 'getLoad:Data(Download.FailedAsset(\"png\"))' to redownload again.",
			color and color.red or nil
		)
	end

end

--------------------------------------------------
-- BUILD ICON TABLE
--------------------------------------------------

loadIcons()


local inside = game:GetService("CoreGui")["ExperienceSettings-Executor"].Main.Background.Inside.Holder
local windows = game:GetService("CoreGui")["ExperienceSettings-Executor"].Main.Background.Windows

--[[ Inside ]]--
inside.Home.Image = icons.home
inside.Edit.Image = icons.editor
inside.Console.Image = icons.console
inside.Folder.Image = icons["folder-"]
inside.Bookmark.Image = icons.bookmark
inside.Search.Image = icons.search
-- inside.Music = Image = icons.music
inside.Settings.Image = icons.settings

--[[ Windows ]]--
local vHome = windows.Home.Inside
local vEditor = windows.Edit.Inside
local vConsole = windows.Console.Inside
local vFolder = windows.Folder.Inside
local vBookmark = windows.Bookmark.Inside
local vSearch = windows.Search.Inside
local vMusic = windows.Music.Inside
local vSettings = windows.Settings.Inside

--[ Home ]--


--[ Editor ]--
local vEditTabs = vEditor.ScriptTabs.Inside
vEditTabs:FindFirstChild("Z99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999_AddScript").Image = icons["plus-cyan"]

local vEditExe = vEditor:FindFirstChild("Execute tabs").Inside
vEditExe.Execute.Image = icons.execute
vEditExe.Debugger.Image = icons.debug
vEditExe.PasteAndExecute.Image = icons["paste-and-execute"]
vEditExe.Paste.Image = icons.paste
vEditExe.Copy.Image = icons.copy
vEditExe.Clear.Image = icons.erase

--[ Console ]--


--[ Folder ]--
local vFolderBar = vFolder.FolderBar
local vFBInsideBar = vFolderBar.InsideBar
vFBInsideBar.Seacrh.Image = icons.search
vFBInsideBar.Select.Image = icons.select

--[ Bookmark ]--


--[ Search ]--


--[ Music ]--


--[ Settings ]--


