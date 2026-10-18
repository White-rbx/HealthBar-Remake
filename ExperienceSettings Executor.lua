local Version = [[0.1.8 Alpha
- Insane reduce local]]
-- This executor

--[[
 HELLO SCRIPTBLOX AND HAXHELL USERSSSS WHAT THE ACTUALLY HELL YOU GUYS
 DOING IN THIS RAW SCRIPT? AND YES IT'S MIGHT LOOK TOO AI SLOP BUT -
 GUIS ARE NOT MADE BY AI, ANYWAY I'M STILL LEARNING SCRIPT!

 THANK YOU FOR READINGGGGG
 - from Loader.lua message

 anyway you can see there's banned users. I'm not telling you how to- nah :3
]]

getgenv().ES = nil

-- Load SetUp
loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/loadstring/ExperienceSettings-SetUp.lua"))()

repeat task.wait() until getgenv().__ES_READY or getgenv().__ES_BANNED

if getgenv().__ES_BANNED then
	warn("You're banned from ExperienceSettings Executor.")
	return
end


local ES = getgenv().ES

-- RESET
ES.progress = 0
ES.max = 100
ES.error = false
ES.done = false
ES.lastError = nil

local function catch(err)
	ES.error = true
	ES.lastError = tostring(err)
	warn("[ ES ERROR ]:", err)
end

local function safe(f)
	local ok, err = pcall(f)
	if not ok then
		catch(err)
	end
end

safe(function()
	local url = "https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/Executor/ExperienceSettings%20Executor.lua"

	local ok, src = pcall(function()
		return game:HttpGet(url)
	end)

	if not ok then
		return catch("HttpGet failed: "..tostring(src))
	end

	local f, err = loadstring(src)
	if not f then
		return catch("Compile error: "..err)
	end

	ES.progress = 100
end)

if not ES.error then
	ES.done = true
end

------------------------------------------------------------------------------------------

-- Shared UI helpers and service table (publish UI_functions.lua at this Raw URL).
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/Executor/UI_functions.lua"))()


-- Shared services are exposed by UI.s.


UI.loc.Folder = Instance.new("Folder")
UI.loc.Folder.Name = "ExperienceSettings-Executor"
UI.loc.Folder.Parent = UI.s.CoreGui

UI.loc.Windows = Instance.new("ScreenGui")
UI.loc.Windows.Name = "Main"
UI.loc.Windows.DisplayOrder = 2147483647
UI.loc.Windows.ScreenInsets = Enum.ScreenInsets.None
UI.loc.Windows.Parent = UI.loc.Folder

UI.loc.Bg = Instance.new("Frame")
UI.loc.Bg.Name = "Background"
UI.loc.Bg.Size = UDim2.new(1,0,1,0)
UI.loc.Bg.BackgroundColor3 = Color3.fromRGB(18,18,21)
UI.loc.Bg.BackgroundTransparency = 0.3
UI.loc.Bg.Active = false
UI.loc.Bg.Parent = UI.loc.Windows

UI.loc.Bg.Transparency = 1

UI.loc.Bg2 = Instance.new("Frame")
UI.loc.Bg2.Name = "Background2"
UI.loc.Bg2.Size = UDim2.new(1,0,1,0)
UI.loc.Bg2.BackgroundColor3 = Color3.fromRGB(18,18,21)
UI.loc.Bg2.BackgroundTransparency = 1
UI.loc.Bg2.Active = false
UI.loc.Bg2.Parent = UI.loc.Windows


UI.loc.oc = Instance.new("ImageButton")
UI.loc.oc.Name = "connect"
UI.loc.oc.Size = UDim2.new(0.04,0,0.08,0)
UI.loc.oc.Position = UDim2.new(0,15,0.015,0)
UI.loc.oc.BackgroundColor3 = Color3.fromRGB(18,18,21)
UI.loc.oc.Transparency = 0.08
UI.loc.oc.Draggable = true
UI.loc.oc.Image = "rbxassetid://116278455133074" -- Open
UI.loc.oc.Parent = UI.loc.Bg2
UI.Corner(1,0, UI.loc.oc)
UI.Stroke(UI.loc.oc, UI.StrokeUI.ASMBorder, 255,255,255, UI.StrokeUI.LJMRound, 2, 0)

-- Season
UI.loc.oc.Image = "rbxassetid://116278455133074"

UI.Aspect(UI.loc.oc, 1, "Fit", "Height")

UI.loc.st = UI.s.CoreGui["ExperienceSettings-Executor"].Main.Background2.connect.UIStroke
UI.Gradient(UI.loc.st, 0, 0, 0,
    Color3.fromRGB(255,255,255),
    Color3.fromRGB(0,255,255)
)

UI.loc.gr = UI.loc.st.UIGradient

task.spawn(function()
    while true do
        task.wait(0.001)
        UI.loc.gr.Rotation += 3
        if UI.loc.gr.Rotation == 360 then
           UI.loc.gr.Rotation = 0
        end

    end
end)

-- Close: oc.Image = "rbxassetid://120294896493053"

UI.loc.container = UI.loc.Bg2

UI.loc.clampPosition = function()
    local parentSize = UI.loc.container.AbsoluteSize
    local objSize = UI.loc.oc.AbsoluteSize
    local pos = UI.loc.oc.Position

    -- คำนวณตำแหน่งจริงบนจอ
    local absX = pos.X.Scale * parentSize.X + pos.X.Offset
    local absY = pos.Y.Scale * parentSize.Y + pos.Y.Offset

    -- clamp
    absX = math.clamp(absX, 0, parentSize.X - objSize.X)
    absY = math.clamp(absY, 0, parentSize.Y - objSize.Y)

    -- แปลงกลับเป็น Offset แต่ "เก็บ Scale เดิม"
    local newOffsetX = absX - (pos.X.Scale * parentSize.X)
    local newOffsetY = absY - (pos.Y.Scale * parentSize.Y)

    UI.loc.oc.Position = UDim2.new(
        pos.X.Scale, newOffsetX,
        pos.Y.Scale, newOffsetY
    )
end

UI.loc.oc:GetPropertyChangedSignal("Position"):Connect(UI.loc.clampPosition)
UI.loc.clampPosition()

------------------------------

UI.loc.Bghr = Instance.new("CanvasGroup")
UI.loc.Bghr.Name = "Windows"
UI.loc.Bghr.Size = UDim2.new(1,0,0.85,0)
UI.loc.Bghr.BackgroundTransparency = 1
UI.loc.Bghr.Active = false
UI.loc.Bghr.Position = UDim2.new(0,0,-1,0)
UI.loc.Bghr.Parent = UI.loc.Bg

UI.loc.Frame = {
    Home = Instance.new("CanvasGroup"),
    Edit = Instance.new("CanvasGroup"),
	AutoExe = Instance.new("CanvasGroup"),
    Console = Instance.new("CanvasGroup"),
	ExpInfo = Instance.new("CanvasGroup"),
    Folder = Instance.new("CanvasGroup"),
    Bookmark = Instance.new("CanvasGroup"),
    Search = Instance.new("CanvasGroup"),
    Music = Instance.new("CanvasGroup"),
    Settings = Instance.new("CanvasGroup")
}

UI.loc.Configure = function(frame)
    frame.Visible = true
    frame.Size = UDim2.new(0.8, 0, 0.8, 0)
    frame.Position = UDim2.new(0.1, 0, -1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
    frame.BackgroundTransparency = 0.35
    frame.Parent = UI.loc.Bghr
    UI.Corner(0.05,0,frame)
    UI.Stroke(frame, UI.StrokeUI.ASMBorder, 255, 255, 255, UI.StrokeUI.LJMRound, 1.5, 0)
    
    local Inside = Instance.new("Frame")
    Inside.Name = "Inside"
    Inside.Size = UDim2.new(0.95,0,0.8,0)
    Inside.Position = UDim2.new(0.025,0,2,0) -- On is (0.025,0,0.15,0)
    Inside.BackgroundTransparency = 1
    Inside.Active = false
    Inside.Parent = frame

	local Tittle = Instance.new("TextLabel")
	Tittle.Name = "Tittle"
	Tittle.Size = UDim2.new(0.95,0,0.09,0)
	Tittle.Position = UDim2.new(0.025,0,0.05,0)
	Tittle.BackgroundTransparency = 1
	Tittle.TextScaled = true
	Tittle.Text = "Unknown Page"
	Tittle.TextColor3 = Color3.new(1,1,1)
	Tittle.TextStrokeColor3 = Color3.new(1,1,1)
	Tittle.TextStrokeTransparency = 0
	Tittle.TextXAlignment = Enum.TextXAlignment.Left
	Tittle.Parent = frame
    
    local soon = Instance.new("TextLabel")
    soon.Name = "soon"
    soon.Visible = false
    soon.Size = UDim2.new(1,0,1,0)
    soon.BackgroundTransparency = 1
    soon.TextColor3 = Color3.fromRGB(255,255,255)
    soon.RichText = true
    soon.Text = [[ <b><font size="15">Not now, Sorry! We are busy on main ExperienceSettings.</font></b> ]]
    soon.Parent = Inside
    UI.Corner(0.1,0,soon)
end

UI.loc.Configure(UI.loc.Frame.Home)
UI.loc.Configure(UI.loc.Frame.Edit)
UI.loc.Configure(UI.loc.Frame.AutoExe)
UI.loc.Configure(UI.loc.Frame.Console)
UI.loc.Configure(UI.loc.Frame.ExpInfo)
UI.loc.Configure(UI.loc.Frame.Folder)
UI.loc.Configure(UI.loc.Frame.Bookmark)
UI.loc.Configure(UI.loc.Frame.Search)
UI.loc.Configure(UI.loc.Frame.Music)
UI.loc.Configure(UI.loc.Frame.Settings)

--[ Name ]
UI.loc.Frame.Home.Name = "Home"
UI.loc.Frame.Edit.Name = "Edit"
UI.loc.Frame.AutoExe.Name = "AutoExe"
UI.loc.Frame.Console.Name = "Console"
UI.loc.Frame.ExpInfo.Name = "ExpInfo"
UI.loc.Frame.Folder.Name = "Folder"
UI.loc.Frame.Bookmark.Name = "Bookmark"
UI.loc.Frame.Search.Name = "Search"
UI.loc.Frame.Music.Name = "Music"
UI.loc.Frame.Settings.Name = "Settings"

--[ Tittle ]
UI.loc.Frame.Home.Tittle.Text = "Home"
UI.loc.Frame.Edit.Tittle.Text = "Editor"
UI.loc.Frame.AutoExe.Tittle.Text = "Auto Execute"
UI.loc.Frame.Console.Tittle.Text = "Console"
UI.loc.Frame.ExpInfo.Tittle.Text = "Experience Information"
UI.loc.Frame.Folder.Tittle.Text = "Device Folder"
UI.loc.Frame.Bookmark.Tittle.Text = "Bookmark Script"
UI.loc.Frame.Search.Tittle.Text = "Search Script"
UI.loc.Frame.Music.Tittle.Text = "Music and Audio"
UI.loc.Frame.Settings.Tittle.Text = "Settings"

--[ Visible ]
UI.loc.Frame.AutoExe.Inside.soon.Visible = true
UI.loc.Frame.Console.Inside.soon.Visible = true
UI.loc.Frame.ExpInfo.Inside.soon.Visible = true
UI.loc.Frame.Folder.Inside.soon.Visible = true
UI.loc.Frame.Bookmark.Inside.soon.Visible = true
UI.loc.Frame.Search.Inside.soon.Visible = true
UI.loc.Frame.Music.Inside.soon.Visible = true
UI.loc.Frame.Settings.Inside.soon.Visible = true

UI.loc.Frame.AutoExe.Inside.soon.Text = [[<b><font size="15">Delayed.</font></b>
But "AutoExe" is exist, so try to check on ExperienceSettings-Executor Folder on your device!]]

UI.loc.Frame.Console.Inside.soon.Text = [[<b><font size="15">Something was wrong...</font></b>
Tried to load console while executing. Please open dex explorer and find "ExperienceSettings-Executor" folder in CoreGui and destroy all folder that have same name or rejoin the game and execute again.]]

UI.loc.Frame.Search.Inside.soon.Text = [[<b><font size="15">Something was wrong...</font></b>
Tried to load seacrh while executing. Please open dex explorer and find "ExperienceSettings-Executor" folder in CoreGui and destroy all folder that have same name or rejoin the game and execute again.]]
------------------------------------------------------------
UI.loc.topn = Instance.new("Frame")
UI.loc.topn.Name = "TopNoity"
UI.loc.topn.Position = UDim2.new(0,0,0.033,0)
UI.loc.topn.Size = UDim2.new(1,0,0,43)
UI.loc.topn.BackgroundTransparency = 1
UI.loc.topn.Active = false
UI.loc.topn.Parent = UI.loc.Bg
UI.ListLayout(UI.loc.topn, 0,5, UI.ListUI.HCenter, UI.ListUI.VTop, UI.ListUI.SLayout, UI.ListUI.FillV)

------------------------------------------------------------
-- local function
------------------------------------------------------------
UI.loc.color = {
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
UI.loc.noti = function(times, text, colorValue)
    local finalColor = colorValue or UI.loc.color.nor

    -- กล่องแจ้งเตือน
    local txt = Instance.new("TextLabel")
    txt.Name = "Notify"
    txt.BackgroundColor3 = Color3.fromRGB(18,18,21)
    txt.BackgroundTransparency = 0.25
    txt.TextWrap = true
    txt.RichText = true
    txt.TextScaled = false
    txt.TextSize = 18
    txt.Font = Enum.Font.GothamBold
    txt.Text = tostring(text)
    txt.TextColor3 = finalColor
    txt.ClipsDescendants = true
    txt.Parent = UI.loc.topn

    UI.Corner(0,7,txt)

    -- แปลง Color3 → RGB
    local r = finalColor.R * 255
    local g = finalColor.G * 255
    local b = finalColor.B * 255

    UI.Stroke(txt, UI.StrokeUI.ASMBorder, r, g, b, UI.StrokeUI.LJMRound, 1, 0)

    -- คำนวณขนาดข้อความ
    local textSize = UI.s.TextService:GetTextSize(
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
    UI.s.TweenService:Create(
        txt,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = finalSize}
    ):Play()

    -- time bar
    local bar = Instance.new("Frame")
    bar.Name = "time"
    bar.Position = UDim2.new(0,0,0.9,0)
    bar.Size = UDim2.new(1,0,0,2)
    bar.BackgroundColor3 = finalColor
    bar.BorderSizePixel = 0
    bar.Parent = txt

    -- Tween time bar
    local barTween = UI.s.TweenService:Create(
        bar,
        TweenInfo.new(times, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0,0,0,2)}
    )
    barTween:Play()

    -- เมื่อ time หมด
    barTween.Completed:Connect(function()

        local hideTween = UI.s.TweenService:Create(
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

--// ===============================
--// PATH + FOLDER SETUP
--// ===============================

UI.loc.base = "ExperienceSettings-Executor"
UI.loc.tabsPath = UI.loc.base .. "/Tabs"
UI.loc.jsonPath = UI.loc.base .. "/workin.json"
-- สร้าง base folder
if not isfolder(UI.loc.base) then
	makefolder(UI.loc.base)
end

-- สร้าง sub folders
UI.loc.folders = { "Workspace", "AutoExe", "Tabs", "Save", "Assets", "Logs", ".Config" }

for _, folder in ipairs(UI.loc.folders) do
	local path = UI.loc.base .. "/" .. folder
	if not isfolder(path) then
		makefolder(path)
	end
end

-- Execute button
UI.loc.executeBtn = UI.loc.eftabs and UI.loc.eftabs:FindFirstChild("Execute")

if UI.loc.executeBtn then
	
	UI.loc.executeBtn.MouseButton1Click:Connect(function()

		if Editb and Editb.Text then
			
			if string.find(Editb.Text,"getLoad%(Asset%)") then
				getLoad("Asset")
			end
			
		end

	end)
	
end


------------------------------------------------------------
-- home
------------------------------------------------------------

--[[ USER ]]
UI.loc.user = Instance.new("Frame")
UI.loc.user.Name = "User"
UI.loc.user.Size = UDim2.new(0.5,0,0.2,0)
UI.loc.user.BackgroundColor3 = Color3.fromRGB(255,255,255)
UI.loc.user.Active = false
UI.loc.user.Parent = UI.loc.Frame.Home.Inside
UI.Corner(0.1,0,UI.loc.user)
UI.Stroke(UI.loc.user, UI.StrokeUI.ASMBorder, 255,255,255, UI.StrokeUI.LJMRound, 1, 0)
UI.Gradient(UI.loc.user, 90,0,0,
  Color3.fromRGB(85,0,127),
  Color3.fromRGB(0,0,127)
)

UI.loc.imauser = Instance.new("ImageLabel")
UI.loc.imauser.Name = "ImageLocalUser"
UI.loc.imauser.Size = UDim2.new(1,0,0.8,0)
UI.loc.imauser.Position = UDim2.new(0.025,0,0.1,0)
UI.loc.imauser.BackgroundColor3 = Color3.fromRGB(255,255,255)
UI.loc.imauser.BackgroundTransparency = 0.5
UI.loc.imauser.Image = "rbxassetid://"
UI.loc.imauser.Parent = UI.loc.user
UI.Corner(0.1,0,UI.loc.imauser)
UI.Stroke(UI.loc.imauser, UI.StrokeUI.ASMBorder, 255,255,255, UI.StrokeUI.LJMRound, 1, 0)
-- UIAspectRatioConstraint
UI.Aspect(UI.loc.imauser, 1)
 
--[[ Label ]]
UI.loc.lauser = Instance.new("TextLabel")
UI.loc.lauser.Name = "TheWelcome"
UI.loc.lauser.Position = UDim2.new(0.215,0,0.25,0)
UI.loc.lauser.Size = UDim2.new(0.75,0,0.5,0)
UI.loc.lauser.BackgroundTransparency = 1
UI.loc.lauser.Text = "Hello! <b><font color='rgb(0,255,0)'>@Username.</font></b>"
UI.loc.lauser.TextColor3 = Color3.fromRGB(255,255,255)
UI.loc.lauser.TextScaled = true
UI.loc.lauser.RichText = true
UI.loc.lauser.TextXAlignment = Enum.TextXAlignment.Left
UI.loc.lauser.TextYAlignment = Enum.TextYAlignment.Center
UI.loc.lauser.Parent = UI.loc.user

--[[ Script ]]
-- Load the thumbnail directly to avoid temporary locals.
UI.loc.imauser.Image = UI.s.Players:GetUserThumbnailAsync(
    UI.s.Players.LocalPlayer.UserId,
    Enum.ThumbnailType.HeadShot,
    Enum.ThumbnailSize.Size420x420
)


-- ตรวจเวลา
UI.loc.hour = tonumber(os.date("%H")) -- ได้ค่า 0 - 23

UI.loc.timeGreeting = nil

if UI.loc.hour >= 5 and UI.loc.hour < 12 then
    UI.loc.timeGreeting = "Good morning"
elseif UI.loc.hour >= 12 and UI.loc.hour < 15 then
    UI.loc.timeGreeting = "Good afternoon"
elseif UI.loc.hour >= 15 and UI.loc.hour < 20 then
    UI.loc.timeGreeting = "Good evening"
elseif UI.loc.hour >= 20 and UI.loc.hour < 23 then
    UI.loc.timeGreeting = "Good night"
else
    UI.loc.timeGreeting = "Good midnight"
end


-- ข้อความสุ่ม
UI.loc.greetings = {
    "Hello",
    "Welcome back",
    "Yo",
    "Greeting",
    "What's up",
    "Hey",
    "Ay",
	"Anything to do something?",
	"Thanks for using!",
	"How are you?",
	"GogoGaga",
	"Random Greetings btw",
    "Also try <stroke color='rgb(85,255,255)' thickness='1' transparency='0'>ExperienceSettings</stroke>",
	"Hmmm...",
	"<b>Bing chil ling</b>",
	"<font face='Jura'>TOYOTA</font>",
	"<u><font color='rgb(0,100,255)'>English</font></u> or <u><font color='rgb(255,100,0)'>Spanish</font></u>",
	"🏳️‍🌈?",
	"<stroke color='rgb(255,100,255)' thickness='2' transparency='0'>Good boy for using executor,</stroke>",
	"<font color='rgb(0,255,255)'>IT'S FREE!!!!</font>",
	"Seeking for Jimmy?",
	"🤌",
	"Do you think how many greeting random texts?",
	"Touch some <stroke color='rgb(0,200,0)' thickness='2' transparency='0'>grass</stroke> outside if you have,",
	"Don't you mind if I say this. Remember exploiters are for...😏 want to know huh?",
	"You're <font color='rgb(255,0,0)'>COOKED</font> if someone successful banned you🥀",
	"Hi,",
    UI.loc.timeGreeting
}

-- เลือกแบบสุ่ม
UI.loc.randomText = UI.loc.greetings[math.random(1, #UI.loc.greetings)]

-- ใส่ชื่อผู้เล่น
UI.loc.lauser.Text = UI.loc.randomText .. " <b><font color='rgb(0,255,0)'>" .. UI.s.Players.LocalPlayer.Name .. "</font></b>."

--[[ Note ]]
UI.loc.frtxt = Instance.new("Frame")
UI.loc.frtxt.Name = "Note"
UI.loc.frtxt.Position = UDim2.new(0,0,0.25,0)
UI.loc.frtxt.Size = UDim2.new(0.5,0,0.75,0)
UI.loc.frtxt.BackgroundColor3 = Color3.fromRGB(255,255,255)
UI.loc.frtxt.Active = false
UI.loc.frtxt.Parent = UI.loc.Frame.Home.Inside
UI.Corner(0.05,0,UI.loc.frtxt)
UI.Stroke(UI.loc.frtxt, UI.StrokeUI.ASMBorder, 255,255,255, UI.StrokeUI.LJMRound, 1, 0)
UI.Gradient(UI.loc.frtxt, 45,0,0,
  Color3.fromRGB(0,0,170),
  Color3.fromRGB(0,100,255)
)

UI.loc.sctxt = Instance.new("ScrollingFrame")
UI.loc.sctxt.Name = "Scroll"
UI.loc.sctxt.Position = UDim2.new(0.05,0,0,0)
UI.loc.sctxt.Size = UDim2.new(0.9,0,1,0)
UI.loc.sctxt.BackgroundTransparency = 1
UI.loc.sctxt.ScrollBarThickness = 0
UI.loc.sctxt.CanvasSize = UDim2.new(0,0,10,0)
UI.loc.sctxt.Parent = UI.loc.frtxt


UI.loc.ttxt = Instance.new("TextLabel")
UI.loc.ttxt.Name = "Text"
UI.loc.ttxt.Size = UDim2.new(1,0,1,0)
UI.loc.ttxt.BackgroundTransparency = 1
UI.loc.ttxt.Active = false
UI.loc.ttxt.Text = [[
<b><font size="15">Note</font></b> 
ExperienceSettings Executor is for debugging script and it use only for executor app, so thank you for using our executor!

<b><font size="15">What is executor for?</font></b>
For Integrated Development Environment (IDE) programing.

<b><font size="15">Credit</font></b>
@5teve3019D (ScriptBlox)

<b><font size="15">Custom syntax by @5teve3019D</font></b>
--[ getLoad ]--
 1. getLoad(VARIABLE)
     • Get VARIABLE from local
     
 2. getLoad(function()end)
     • Get function
     • getLoad(function()
        print("hi")
       end)

 3. getLoad.fromURL("") -- loadstring()
     • Working like loadstring but take long
     
 4. getLoad.fromPath("Name/")
     • Get path in your device ( Executor )
     
 5. getLoad:Settings(Enums.Settings.DelExe)
     • Delete ES Executor
     
 6. getLoad:Settings(Enums.Settings.ReloadExe)
     • Reload ES Executor
     
 7. getLoad:Data(Download.Asset("png"))
     • Download all pngs ( Important for getcustomasset )
     
 8. getLoad:Data(Download.FailedAsset("png"))
     • Same as Download but its only load failed assets
     
 9. getLoad:Data(Check.Asset("png"))
     • Check all assets png
     
10. getLoad:Data(Del.Asset("png"))
     • Delete all assets png

<b><font size="15">Support and Not Support getcustomasset()</font></b>

--[ Mobile Executor ]--
 1. Krnl (freakin dead | Confirmed by internet)
 2. Codex
 3. Cryptic
 4. VegaX
 5. Delta
 6. Ronix

--[ Pc Executor ( Confirmed by website ) ]--
 1. Volt
 2. Wave
 3. Volcano
 4. Bunni
 5. FluxesZ

--====[NOT SUPPORT ]====--

--[ Mobile Executor ]--
 1. JJsploit ( FREAKIN' DEAD LOL )
 
--[ Pc Executor ( Confirmed by website ) ]--
 1. Xeno
 2. JJsploit ( Currently checking )
 
--====[ IN COMING ]====--
 1. Cubix ( Let see when this executor available )

<b><font size="15">Contact us</font></b>
Join our Discord server for more information!
Feel free to suggest any ideas you'd like to share!

<b><font size="15">Executor Verison</font></b>
]] .. Version

UI.loc.ttxt.TextColor3 = Color3.fromRGB(255,255,255)
UI.loc.ttxt.TextSize = 10
UI.loc.ttxt.RichText = true
UI.loc.ttxt.TextWrap = true
UI.loc.ttxt.TextXAlignment = Enum.TextXAlignment.Left
UI.loc.ttxt.TextYAlignment = Enum.TextYAlignment.Top
UI.loc.ttxt.Parent = UI.loc.sctxt

--[[ soon ]]
UI.loc.son = Instance.new("TextLabel")
UI.loc.son.Name = "ScriptList"
UI.loc.son.Position = UDim2.new(0.52,0,0.25,0)
UI.loc.son.Size = UDim2.new(0.48,0,0.75,0)
UI.loc.son.BackgroundTransparency = 1
UI.loc.son.Active = false
UI.loc.son.Text = [[
<b><font size="15">Script hub</font></b> 
⟩⟩ Also try universal script ⟨⟨
]]

UI.loc.son.TextColor3 = Color3.fromRGB(255,255,255)
UI.loc.son.TextSize = 10
UI.loc.son.RichText = true
UI.loc.son.TextWrap = true
UI.loc.son.TextXAlignment = Enum.TextXAlignment.Center
UI.loc.son.TextYAlignment = Enum.TextYAlignment.Top
UI.loc.son.Parent = UI.loc.Frame.Home.Inside
UI.Corner(0.05,0, UI.loc.son)
UI.Stroke(UI.loc.son, UI.StrokeUI.ASMBorder, 255,255,255, UI.StrokeUI.LJMRound, 1, 0)

UI.loc.sons = Instance.new("ScrollingFrame")
UI.loc.sons.Name = "List"
UI.loc.sons.Position = UDim2.new(0,0,0.2,0)
UI.loc.sons.Size = UDim2.new(1,0,0.8,0)
UI.loc.sons.BackgroundTransparency = 1
UI.loc.sons.ScrollBarThickness = 0
UI.loc.sons.CanvasSize = UDim2.new(0,0,0,0)
UI.loc.sons.Parent = UI.loc.son

UI.loc.sonf = Instance.new("Frame")
UI.loc.sonf.Name = "Holder"
UI.loc.sonf.Position = UDim2.new(0.05,0,0.03,0)
UI.loc.sonf.Size = UDim2.new(0.9,0,0.95,0)
UI.loc.sonf.BackgroundTransparency = 1
UI.loc.sonf.Active = false
UI.loc.sonf.Parent = UI.loc.sons

UI.loc.uigr = Instance.new("UIGridLayout")
UI.loc.uigr.CellSize = UDim2.new(1,0,0,50)
UI.loc.uigr.CellPadding = UDim2.new(0,0,0,5)
UI.loc.uigr.Parent = UI.loc.sonf

local function scr(Pname, Sname, scriptSource, callback)

	-- =========================
	-- 📦 Card Container
	-- =========================
	local add = Instance.new("Frame")
	add.Name = tostring(Pname)
	add.Size = UDim2.new(1,0,0,50)
	add.BackgroundColor3 = Color3.new(1,1,1)
	add.BackgroundTransparency = 0
	add.Parent = UI.loc.sonf
	UI.Stroke(add, UI.StrokeUI.ASMBorder, 255,255,255, UI.StrokeUI.LJMRound, 1, 0)
	
	UI.Corner(0.1,0,add)
	UI.Gradient(add, -90,0,0,
  Color3.fromRGB(0,0,170),
  Color3.fromRGB(0,100,255)
  )

	local ins = Instance.new("Frame")
	ins.Name = "Inside"
	ins.Position = UDim2.new(0.05,0,0.1,0)
	ins.Size = UDim2.new(0.9,0,0.8,0)
	ins.BackgroundTransparency = 1
	ins.Parent = add

	-- =========================
	-- 📝 Script Name
	-- =========================
	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(0.5,0,1,0)
	txt.BackgroundTransparency = 1
	txt.TextScaled = true
	txt.RichText = true
	txt.Text = tostring(Sname)
	txt.TextXAlignment = Enum.TextXAlignment.Left
	txt.TextYAlignment = Enum.TextYAlignment.Center
	txt.TextStrokeTransparency = 0
	txt.TextColor3 = Color3.new(1,1,1)
	txt.TextStrokeColor3 = Color3.new(0,0,0)
	txt.Parent = ins

	-- =========================
	-- 📋 Copy Button
	-- =========================
	local copy = Instance.new("ImageButton")
	copy.Position = UDim2.new(0.72,0,0,5)
	copy.Size = UDim2.new(0,30,0,30)
	copy.BackgroundColor3 = Color3.new(0,0,0)
	copy.Image = "rbxassetid://70463360371392"
	copy.Parent = ins
	
	UI.Corner(0.2,0,copy)
	UI.Stroke(copy, UI.StrokeUI.ASMBorder, 255,255,255, UI.StrokeUI.LJMRound, 1, 0)

	copy.MouseButton1Click:Connect(function()
		if setclipboard then
			setclipboard(scriptSource)
			UI.loc.noti(2, "Copied: "..Sname, UI.loc.color.yellow)
		else
			UI.loc.noti(3, "Clipboard not supported.", UI.loc.color.red)
		end
	end)

	-- =========================
	-- ▶ Execute Button
	-- =========================
	local exe = Instance.new("ImageButton")
	exe.Position = UDim2.new(0.85,0,0,5)
	exe.Size = UDim2.new(0,30,0,30)
	exe.BackgroundColor3 = Color3.new(0,0,0)
	exe.Image = "rbxassetid://104470314612186"
	exe.Parent = ins
	
	UI.Corner(0.2,0,exe)
	UI.Stroke(exe, UI.StrokeUI.ASMBorder, 255,255,255, UI.StrokeUI.LJMRound, 1, 0)

	exe.MouseButton1Click:Connect(function()

		if not scriptSource or scriptSource == "" then
			UI.loc.noti(3, "No script source.", UI.loc.color.red)
			return
		end

		UI.loc.noti(2, "Executing: "..Sname, UI.loc.color.yellow)

		-- Compile
		local f, compileErr = loadstring(scriptSource)

		if not f then
			local line = tostring(compileErr):match(":(%d+):") or "?"
			UI.loc.noti(10,
				"[COMPILE ERROR]\nLine: "..line..
				"\n"..compileErr,
				UI.loc.color.red
			)
			return
		end

		-- Runtime
		local success, runtimeErr = pcall(f)

		if success then
			UI.loc.noti(2, "Executed: "..Sname, UI.loc.color.green)

			if callback then
				pcall(callback)
			end
		else
			local line = tostring(runtimeErr):match(":(%d+):") or "?"
			UI.loc.noti(10,
				"[RUNTIME ERROR]\nLine: "..line..
				"\n"..runtimeErr,
				UI.loc.color.red
			)
		end

	end)

end

scr("InfiniteYield", "Infinite Yield | by @edge_egg (Discord)",
  [[
  loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
  ]]
)

scr("DexExplorerPlusPlus", "DEX Explorer Plus+ | by @NullSpecter (ORIGINAL: Chillz)",
  [[
  loadstring(game:HttpGet("https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua"))()
  ]]
)

scr("ExperienceSettings", "ExperienceSettings | by @5teve3019D",
  [[
  loadstring(game:HttpGet("https://bit.ly/49157tB", true))()
  ]]
)

scr("YARHM", "YARHM | by @Imperial",
  [[local src = ""
local CoreGui = game:GetService("StarterGui")

pcall(function() 
    src = game:HttpGet("https://yarhm.mhi.im/scr", false)
end)
if src == "" then
  CoreGui:SetCore("SendNotification", {
  	Title = "YARHM Outage";
  	Text = "YARHM Online is currently unavailable! Sorry for the inconvenience. Using YARHM Offline.";
	  Duration = 5;
  })
  src = game:HttpGet("https://raw.githubusercontent.com/Joystickplays/psychic-octo-invention/main/source/yarhm/1.20/yarhm.lua", false)
end


loadstring(src)()

]])

scr("SmoothFreecam", "Smooth Freecam  | by @Styear", 
  [[loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Smooth-Freecam-123026"))()
]])

scr("seacrhscript", "Seacrh script | by @Pancho",
  [[loadstring(game:HttpGet("https://raw.githubusercontent.com/panchooo677/K66j/refs/heads/main/README.md"))()
  ]])

scr("VSCode", "VSCode Open Source | by @Cherry | [PC ONLY]",
[[loadstring(game:HttpGet("https://raw.githubusercontent.com/InfernusScripts/VSCode/refs/heads/main/VSCode.lua"))()
]])

scr("sUNC", "Unc Test | by @Alexchad", 
  [[loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Unc-Test-67860"))()
]])

scr("YTMP", "YouTube Music Player | by Termux_404",
	[[loadstring(game:HttpGet(('https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua'),true))()
]])

-- Update scroll automatically
UI.loc.updateCanvas = function()
	local contentY = UI.loc.uigr.AbsoluteContentSize.Y
	local extraPadding = 20 -- กัน stroke / rounding
	UI.loc.sons.CanvasSize = UDim2.new(0,0,0, contentY + extraPadding)
end

UI.loc.updateCanvas()

--[[ Soucre ]]
UI.loc.dis = Instance.new("TextButton")
UI.loc.dis.Name = "Discord"
UI.loc.dis.Position = UDim2.new(0.52,0,0,0)
UI.loc.dis.Size = UDim2.new(0.48,0,0.2,0)
UI.loc.dis.BackgroundColor3 = Color3.fromRGB(27, 42, 53)
UI.loc.dis.TextSize = 20
UI.loc.dis.Text = "Join our Discord community! [ Copy ]"
UI.loc.dis.TextColor3 = Color3.fromRGB(255,255,255)
UI.loc.dis.TextWrap = true
UI.loc.dis.Parent = UI.loc.Frame.Home.Inside
UI.Corner(0.05,0, UI.loc.dis)
UI.Stroke(UI.loc.dis, UI.StrokeUI.ASMBorder, 255,255,255, UI.StrokeUI.LJMRound, 1, 0)
UI.Gradient(UI.loc.dis, 90,0,0,
  Color3.fromRGB(170,0,255),
  Color3.fromRGB(0,170,255)
)

UI.loc.dis.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/UZXhApNH")
    UI.loc.noti(3, "<b>Copied!</b> Discord link copied to clipboard", UI.loc.color.green)
end)

------------------------------------------------------------
-- edit
------------------------------------------------------------
UI.loc.edits = Instance.new("ScrollingFrame")
UI.loc.edits.Name = "EditScroll"
UI.loc.edits.Size = UDim2.new(0.5,0,1,0)
UI.loc.edits.BackgroundTransparency = 0
UI.loc.edits.BackgroundColor3 = Color3.fromRGB(0,0,0)
UI.loc.edits.ScrollBarThickness = 1
UI.loc.edits.CanvasSize = UDim2.new(10,0,100,0)
UI.loc.edits.Parent = UI.loc.Frame.Edit.Inside

UI.loc.editb = Instance.new("TextBox")
UI.loc.editb.Name = "Edit"
UI.loc.editb.Size = UDim2.new(1,0,1,0)
UI.loc.editb.Position = UDim2.new(0,50,0,0)
UI.loc.editb.ClearTextOnFocus = false
UI.loc.editb.BackgroundTransparency = 1
UI.loc.editb.TextTransparency = 1
UI.loc.editb.TextSize = 15
UI.loc.editb.TextWrap = true
UI.loc.editb.RichText = true
UI.loc.editb.Text = 'print("Hello, World!")'
UI.loc.editb.TextColor3 = Color3.fromRGB(255,255,255)
UI.loc.editb.TextXAlignment = Enum.TextXAlignment.Left
UI.loc.editb.TextYAlignment = Enum.TextYAlignment.Top
UI.loc.editb.Parent = UI.loc.edits

--[ Script (Syntax) ]

--// PATH
UI.loc.executor = UI.s.CoreGui:WaitForChild("ExperienceSettings-Executor")
UI.loc.scroll = UI.loc.executor.Main.Background.Windows.Edit.Inside.EditScroll
UI.loc.editBox = UI.loc.scroll.Edit -- USE ONE ONLY

--// CONFIG
UI.loc.FONT = Enum.Font.Code
UI.loc.TEXT_SIZE = 15
UI.loc.LINE_HEIGHT = 18
UI.loc.MAX_CANVAS_HEIGHT = 180000
UI.loc.VISIBLE_BUFFER = 80

UI.loc.scroll.AutomaticCanvasSize = Enum.AutomaticSize.None

--// TEXTBOX SETUP
UI.loc.editBox.MultiLine = true
UI.loc.editBox.ClearTextOnFocus = false
UI.loc.editBox.TextWrapped = false
UI.loc.editBox.Font = UI.loc.FONT
UI.loc.editBox.TextSize = UI.loc.TEXT_SIZE
UI.loc.editBox.TextColor3 = Color3.fromRGB(255,255,255)
UI.loc.editBox.TextXAlignment = Enum.TextXAlignment.Left
UI.loc.editBox.TextYAlignment = Enum.TextYAlignment.Top
UI.loc.editBox.BackgroundTransparency = 1
UI.loc.editBox.ZIndex = 3

--// HIGHLIGHT LAYER
UI.loc.highlight = Instance.new("TextLabel")
UI.loc.highlight.Name = "SyntaxColor"
UI.loc.highlight.BackgroundTransparency = 1
UI.loc.highlight.TextColor3 = Color3.new(1,1,1)
UI.loc.highlight.RichText = true
UI.loc.highlight.Font = UI.loc.FONT
UI.loc.highlight.TextSize = UI.loc.TEXT_SIZE
UI.loc.highlight.TextWrapped = false
UI.loc.highlight.TextXAlignment = Enum.TextXAlignment.Left
UI.loc.highlight.TextYAlignment = Enum.TextYAlignment.Top
UI.loc.highlight.ZIndex = 2
UI.loc.highlight.Parent = UI.loc.scroll

--// LINE NUMBERS
UI.loc.lineNumbers = Instance.new("TextLabel")
UI.loc.lineNumbers.BackgroundColor3 = Color3.fromRGB(25,25,25)
UI.loc.lineNumbers.BorderSizePixel = 0
UI.loc.lineNumbers.Font = UI.loc.FONT
UI.loc.lineNumbers.TextSize = UI.loc.TEXT_SIZE
UI.loc.lineNumbers.TextColor3 = Color3.fromRGB(140,140,140)
UI.loc.lineNumbers.TextXAlignment = Enum.TextXAlignment.Right
UI.loc.lineNumbers.TextYAlignment = Enum.TextYAlignment.Top
UI.loc.lineNumbers.ZIndex = 1
UI.loc.lineNumbers.Parent = UI.loc.scroll

--//COLORS
UI.loc.COLORS = {
	Keyword   = "#c586c0",
	Comment   = "#6a9955",
	String    = "#ce9178",
	Datatype  = "#ff0000",
	Global    = "#4ec9b0",
	Class     = "#00FFFF",
	Enum      = "#ff8c00",
	Exe       = "#FFFF00",
}


UI.loc.keywords = {  
["break"]=true,
["do"]=true,
["else"]=true,
["elseif"]=true,
["end"]=true,
["false"]=true,
["for"]=true,
["function"]=true,
["if"]=true,
["in"]=true,
["local"]=true,
["nil"]=true,
["not"]=true,
["or"]=true,
["repeat"]=true,
["return"]=true,
["then"]=true,
["true"]=true,
["until"]=true,
["while"]=true,
["type"]=true,
["goto"]=true,
}

UI.loc.datatype = {

	["Axes"] = true,
	["BrickColor"] = true,
	["CatalogSearchParams"] = true,
	["CFrame"] = true,
	["Color3"] = true,
	["ColorSequence"] = true,
	["ColorSequenceKeypoint"] = true,
	["Content"] = true,
	["DateTime"] = true,
	["DockWidgetPluginGuiInfo"] = true,
	["Enum"] = true,
	["EnumItem"] = true,
	["Enums"] = true,
	["Faces"] = true,
	["FloatCurveKey"] = true,
	["Font"] = true,
	["Instance"] = true,
	["NumberRange"] = true,
	["NumberSequence"] = true,
	["NumberSequenceKeypoint"] = true,
	["OverlapParams"] = true,
	["Path2DControlPoint"] = true,
	["PathWaypoint"] = true,
	["PhysicalProperties"] = true,
	["Random"] = true,
	["Ray"] = true,
	["RaycastParams"] = true,
	["RaycastResult"] = true,
	["RBXScriptConnection"] = true,
	["RBXScriptSignal"] = true,
	["Rect"] = true,
	["Region3"] = true,
	["Region3int16"] = true,
	["RotationCurveKey"] = true,
	["Secret"] = true,
	["SecurityCapabilities"] = true,
	["SharedTable"] = true,
	["TweenInfo"] = true,
	["UDim"] = true,
	["UDim2"] = true,
	["ValueCurveKey"] = true,
	["Vector2"] = true,
	["Vector2int16"] = true,
	["Vector3"] = true,
	["Vector3int16"] = true,
}

UI.loc.globals = {

	["assert"]=true,
	["collectgarbage"]=true,
	["DebuggerManager"]=true,
	["delay"]=true,
	["elapsedTime"]=true,
	["Enum"]=true,
	["error"]=true,
	["game"]=true,
	["gcinfo"]=true,
	["getfenv"]=true,
	["getmetatable"]=true,
	["ipairs"]=true,
	["loadstring"]=true,
	["newproxy"]=true,
	["next"]=true,
	["pairs"]=true,
	["pcall"]=true,
	["plugin"]=true,
	["PluginManager"]=true,
	["print"]=true,
	["printidentity"]=true,
	["rawequal"]=true,
	["rawget"]=true,
	["rawlen"]=true,
	["rawset"]=true,
	["require"]=true,
	["script"]=true,
	["select"]=true,
	["setfenv"]=true,
	["setmetatable"]=true,
	["settings"]=true,
	["shared"]=true,
	["spawn"]=true,
	["stats"]=true,
	["tick"]=true,
	["time"]=true,
	["tonumber"]=true,
	["tostring"]=true,
	["type"]=true,
	["typeof"]=true,
	["unpack"]=true,
	["UserSettings"]=true,
	["version"]=true,
	["wait"]=true,
	["warn"]=true,
	["workspace"]=true,
	["xpcall"]=true,
	["ypcall"]=true,
	["_G"]=true,
	["_VERSION"]=true,
}

UI.loc.classList = {
"Accessory",
"AccessoryDescription",
"Accoutrement",
"Actor",
"AdGui",
"AdPortal",
"AdService",
"AdvancedDragger",
"AirController",
"AlignOrientation",
"AlignPosition",
"AnalyticsService",
"AngularVelocity",
"Animation",
"AnimationClip",
"AnimationClipProvider",
"AnimationConstraint",
"AnimationController",
"AnimationFromVideoCreatorService",
"AnimationRigData",
"AnimationTrack",
"Animator",
"Annotation",
"ArcHandles",
"AssetDeliveryProxy",
"AssetPatchSettings",
"AssetService",
"Atmosphere",
"AtmosphereSensor",
"Attachment",
"AudioAnalyzer",
"AudioChannelMixer",
"AudioChannelSplitter",
"AudioChorus",
"AudioCompressor",
"AudioDeviceInput",
"AudioDeviceOutput",
"AudioDistortion",
"AudioEcho",
"AudioEmitter",
"AudioEqualizer",
"AudioFader",
"AudioFilter",
"AudioFlanger",
"AudioGate",
"AudioLimiter",
"AudioListener",
"AudioPages",
"AudioPitchShifter",
"AudioPlayer",
"AudioRecorder",
"AudioReverb",
"AudioSearchParams",
"AudioSpeechToText",
"AudioTextToSpeech",
"AudioTremolo",
"AvatarCreationService",
"AvatarEditorService",
"Backpack",
"BackpackItem",
"BadgeService",
"BallSocketConstraint",
"BanHistoryPages",
"BasePart",
"BasePlayerGui",
"BaseRemoteEvent",
"BaseScript",
"BaseWrap",
"Beam",
"BevelMesh",
"BillboardGui",
"BinaryStringValue",
"BindableEvent",
"BindableFunction",
"BlockMesh",
"BloomEffect",
"BlurEffect",
"BodyAngularVelocity",
"BodyColors",
"BodyForce",
"BodyGyro",
"BodyMover",
"BodyPartDescription",
"BodyPosition",
"BodyThrust",
"BodyVelocity",
"Bone",
"BoolValue",
"BoxHandleAdornment",
"BrickColorValue",
"BrowserService",
"BubbleChatConfiguration",
"BubbleChatMessageProperties",
"BuoyancySensor",
"CFrameValue",
"CacheableContentProvider",
"Camera",
"CanvasGroup",
"Capture",
"CaptureService",
"CapturesPages",
"CatalogPages",
"ChangeHistoryService",
"ChannelTabsConfiguration",
"CharacterAppearance",
"CharacterMesh",
"Chat",
"ChatInputBarConfiguration",
"ChatWindowConfiguration",
"ChatWindowMessageProperties",
"ChorusSoundEffect",
"ClickDetector",
"ClientReplicator",
"ClimbController",
"Clothing",
"Clouds",
"ClusterPacketCache",
"CollectionService",
"Color3Value",
"ColorCorrectionEffect",
"ColorGradingEffect",
"CommerceService",
"CompositeValueCurve",
"CompressorSoundEffect",
"ConeHandleAdornment",
"ConfigService",
"ConfigSnapshot",
"Configuration",
"ConfigureServerService",
"Constraint",
"ContentProvider",
"ContextActionService",
"Controller",
"ControllerBase",
"ControllerManager",
"ControllerPartSensor",
"ControllerSensor",
"ControllerService",
"CookiesService",
"CoreGui",
"CoreScriptDebuggingManagerHelper",
"CornerWedgePart",
"CreatorStoreService",
"CurveAnimation",
"CustomEvent",
"CustomEventReceiver",
"CustomLog",
"CylinderHandleAdornment",
"CylinderMesh",
"CylindricalConstraint",
"DataModel",
"DataModelMesh",
"DataModelSession",
"DataStore",
"DataStoreGetOptions",
"DataStoreIncrementOptions",
"DataStoreInfo",
"DataStoreKey",
"DataStoreKeyInfo",
"DataStoreKeyPages",
"DataStoreListingPages",
"DataStoreObjectVersionInfo",
"DataStoreOptions",
"DataStorePages",
"DataStoreService",
"DataStoreSetOptions",
"DataStoreVersionPages",
"Debris",
"DebugSettings",
"Decal",
"DepthOfFieldEffect",
"Dialog",
"DialogChoice",
"DistortionSoundEffect",
"DockWidgetPluginGui",
"DoubleConstrainedValue",
"DraftsService",
"DragDetector",
"Dragger",
"DraggerService",
"DynamicRotate",
"EchoSoundEffect",
"EditableImage",
"EditableMesh",
"EmotesPages",
"EncodingService",
"EqualizerSoundEffect",
"EulerRotationCurve",
"ExperienceInviteOptions",
"ExperienceNotificationService",
"Explosion",
"FaceControls",
"FaceInstance",
"Feature",
"FeatureRestrictionManager",
"File",
"FileMesh",
"Fire",
"Flag",
"FlagStand",
"FlagStandService",
"FlangeSoundEffect",
"FloatCurve",
"FloorWire",
"FluidForceSensor",
"Folder",
"ForceField",
"FormFactorPart",
"Frame",
"FriendPages",
"FriendService",
"FunctionalTest",
"GamePassService",
"GameSettings",
"GamepadService",
"GenerationService",
"GenericChallengeService",
"GenericSettings",
"Geometry",
"GeometryService",
"GetTextBoundsParams",
"GlobalDataStore",
"GlobalSettings",
"Glue",
"GroundController",
"GroupService",
"GuiBase",
"GuiBase2d",
"GuiBase3d",
"GuiButton",
"GuiLabel",
"GuiMain",
"GuiObject",
"GuiService",
"GuidRegistryService",
"HSRDataContentProvider",
"HandRigDescription",
"HandleAdornment",
"Handles",
"HandlesBase",
"HapticEffect",
"HapticService",
"Hat",
"HeapProfilerService",
"HeightmapImporterService",
"HiddenSurfaceRemovalAsset",
"Highlight",
"HingeConstraint",
"Hint",
"Hole",
"Hopper",
"HopperBin",
"HttpRbxApiService",
"HttpService",
"Humanoid",
"HumanoidController",
"HumanoidDescription",
"HumanoidRigDescription",
"IKControl",
"ILegacyStudioBridge",
"ImageButton",
"ImageHandleAdornment",
"ImageLabel",
"IncrementalPatchBuilder",
"InputAction",
"InputBinding",
"InputContext",
"InputObject",
"InsertService",
"Instance",
"InstanceAdornment",
"InstanceFileSyncService",
"IntConstrainedValue",
"IntValue",
"IntersectOperation",
"InventoryPages",
"JointInstance",
"JointsService",
"KeyboardService",
"Keyframe",
"KeyframeMarker",
"KeyframeSequence",
"KeyframeSequenceProvider",
"LayerCollector",
"Light",
"Lighting",
"LineForce",
"LineHandleAdornment",
"LinearVelocity",
"LocalScript",
"LocalizationService",
"LocalizationTable",
"LogService",
"LoginService",
"LuaSettings",
"LuaSourceContainer",
"LuaWebService",
"MLService",
"MLSession",
"ManualGlue",
"ManualSurfaceJointInstance",
"ManualWeld",
"MarkerCurve",
"MarketplaceService",
"MatchmakingService",
"MaterialService",
"MaterialVariant",
"MemStorageConnection",
"MemStorageService",
"MemoryStoreHashMap",
"MemoryStoreHashMapPages",
"MemoryStoreQueue",
"MemoryStoreService",
"MemoryStoreSortedMap",
"MeshContentProvider",
"MeshPart",
"Message",
"MessagingService",
"MicroProfilerService",
"Model",
"ModerationService",
"ModuleScript",
"Motor",
"Motor6D",
"MotorFeature",
"Mouse",
"MouseService",
"MultipleDocumentInterfaceInstance",
"NegateOperation",
"NetworkClient",
"NetworkMarker",
"NetworkPeer",
"NetworkReplicator",
"NetworkServer",
"NetworkSettings",
"NoCollisionConstraint",
"NotificationService",
"NumberPose",
"NumberValue",
"Object",
"ObjectValue",
"OpenCloudApiV1",
"OpenCloudService",
"OrderedDataStore",
"OutfitPages",
"PVAdornment",
"PVInstance",
"PackageLink",
"PackageService",
"Pages",
"Pants",
"Part",
"PartAdornment",
"PartOperation",
"PartOperationAsset",
"ParticleEmitter",
"PatchBundlerFileWatch",
"PatchMapping",
"Path",
"Path2D",
"PathfindingLink",
"PathfindingModifier",
"PathfindingService",
"PermissionsService",
"PhysicsService",
"PhysicsSettings",
"PitchShiftSoundEffect",
"PlacesService",
"Plane",
"PlaneConstraint",
"Platform",
"Player",
"PlayerGui",
"PlayerMouse",
"PlayerScripts",
"PlayerViewService",
"Players",
"Plugin",
"PluginAction",
"PluginCapabilities",
"PluginDebugService",
"PluginDragEvent",
"PluginGui",
"PluginGuiService",
"PluginManagementService",
"PluginManager",
"PluginManagerInterface",
"PluginMenu",
"PluginMouse",
"PluginToolbar",
"PluginToolbarButton",
"PointLight",
"PointsService",
"PolicyService",
"Pose",
"PoseBase",
"PostEffect",
"PrismaticConstraint",
"ProcessInstancePhysicsService",
"ProximityPrompt",
"ProximityPromptService",
"PublishService",
"PyramidHandleAdornment",
"QWidgetPluginGui",
"RayValue",
"RecommendationPages",
"RecommendationService",
"ReflectionMetadata",
"ReflectionMetadataCallbacks",
"ReflectionMetadataClass",
"ReflectionMetadataClasses",
"ReflectionMetadataEnum",
"ReflectionMetadataEnumItem",
"ReflectionMetadataEnums",
"ReflectionMetadataEvents",
"ReflectionMetadataFunctions",
"ReflectionMetadataItem",
"ReflectionMetadataMember",
"ReflectionMetadataProperties",
"ReflectionMetadataYieldFunctions",
"ReflectionService",
"RemoteDebuggerServer",
"RemoteEvent",
"RemoteFunction",
"RenderSettings",
"RenderingTest",
"ReplicatedFirst",
"ReplicatedStorage",
"ReverbSoundEffect",
"RigidConstraint",
"RocketPropulsion",
"RodConstraint",
"RopeConstraint",
"Rotate",
"RotateP",
"RotateV",
"RotationCurve",
"RunService",
"RunningAverageItemDouble",
"RunningAverageItemInt",
"RunningAverageTimeIntervalItem",
"ScreenGui",
"ScreenshotCapture",
"ScreenshotHud",
"Script",
"ScriptBuilder",
"ScriptContext",
"ScriptDocument",
"ScriptEditorService",
"ScriptProfilerService",
"ScriptService",
"ScrollingFrame",
"Seat",
"Selection",
"SelectionBox",
"SelectionHighlightManager",
"SelectionLasso",
"SelectionPartLasso",
"SelectionPointLasso",
"SelectionSphere",
"SensorBase",
"SerializationService",
"ServerReplicator",
"ServerScriptService",
"ServerStorage",
"ServiceProvider",
"ServiceVisibilityService",
"SessionCheckService",
"SharedTableRegistry",
"Shirt",
"ShirtGraphic",
"SkateboardController",
"SkateboardPlatform",
"Skin",
"Sky",
"SlidingBallConstraint",
"SlimContentProvider",
"Smoke",
"SmoothVoxelsUpgraderService",
"Snap",
"SocialService",
"SolidModelContentProvider",
"Sound",
"SoundEffect",
"SoundGroup",
"SoundService",
"Sparkles",
"SpawnLocation",
"SpawnerService",
"SpecialMesh",
"SphereHandleAdornment",
"SpotLight",
"SpringConstraint",
"StandalonePluginScripts",
"StandardPages",
"StarterCharacterScripts",
"StarterGear",
"StarterGui",
"StarterPack",
"StarterPlayer",
"StarterPlayerScripts",
"StartupMessageService",
"Stats",
"StatsItem",
"Status",
"StopWatchReporter",
"StringValue",
"Studio",
"StudioService",
"StudioTestService",
"StudioTheme",
"StyleBase",
"StyleDerive",
"StyleLink",
"StyleRule",
"StyleSheet",
"SunRaysEffect",
"SurfaceAppearance",
"SurfaceGui",
"SurfaceGuiBase",
"SurfaceLight",
"SurfaceSelection",
"SwimController",
"SyncScriptBuilder",
"TaskScheduler",
"Team",
"TeamCreateData",
"TeamCreateService",
"Teams",
"TeleportAsyncResult",
"TeleportOptions",
"TeleportService",
"Terrain",
"TerrainDetail",
"TerrainIterateOperation",
"TerrainModifyOperation",
"TerrainReadOperation",
"TerrainRegion",
"TerrainWriteOperation",
"TestService",
"TextBox",
"TextBoxService",
"TextButton",
"TextChannel",
"TextChatCommand",
"TextChatConfigurations",
"TextChatMessage",
"TextChatMessageProperties",
"TextChatService",
"TextFilterResult",
"TextFilterTranslatedResult",
"TextGenerator",
"TextLabel",
"TextService",
"TextSource",
"Texture",
"TimerService",
"Tool",
"Torque",
"TorsionSpringConstraint",
"TotalCountTimeIntervalItem",
"TouchInputService",
"TouchTransmitter",
"Trail",
"Translator",
"TremoloSoundEffect",
"TriangleMeshPart",
"TrussPart",
"Tween",
"TweenBase",
"TweenService",
"UGCValidationService",
"UIAspectRatioConstraint",
"UIBase",
"UIComponent",
"UIConstraint",
"UICorner",
"UIDragDetector",
"UIFlexItem",
"UIGradient",
"UIGridLayout",
"UIGridStyleLayout",
"UILayout",
"UIListLayout",
"UIPadding",
"UIPageLayout",
"UIScale",
"UISizeConstraint",
"UIStroke",
"UITableLayout",
"UITextSizeConstraint",
"UnionOperation",
"UniversalConstraint",
"UnreliableRemoteEvent",
"UserGameSettings",
"UserInputService",
"UserService",
"UserSettings",
"VRService",
"VRStatusService",
"ValueBase",
"ValueCurve",
"Vector3Curve",
"Vector3Value",
"VectorForce",
"VehicleController",
"VehicleSeat",
"VelocityMotor",
"VideoCapture",
"VideoCaptureService",
"VideoDisplay",
"VideoFrame",
"VideoPlayer",
"VideoSampler",
"VideoService",
"ViewportFrame",
"VirtualInputManager",
"VirtualUser",
"VisibilityCheckDispatcher",
"Visit",
"VisualizationMode",
"VisualizationModeCategory",
"VisualizationModeService",
"VoiceChatService",
"WebStreamClient",
"WedgePart",
"Weld",
"WeldConstraint",
"Wire",
"WireframeHandleAdornment",
"Workspace",
"WorkspaceAnnotation",
"WorldModel",
"WorldRoot",
"WrapDeformer",
"WrapLayer",
"WrapTarget",
"WrapTextureTransfer",
}

UI.loc.classes = {}

for _, name in ipairs(UI.loc.classList) do
    UI.loc.classes[name] = true
end

UI.loc.enumList = {
"AccessModifierType",
"AccessoryType",
"ActionOnAutoResumeSync",
"ActionOnStopSync",
"ActionType",
"ActuatorRelativeTo",
"ActuatorType",
"AdAvailabilityResult",
"AdEventType",
"AdFormat",
"AdShape",
"AdTeleportMethod",
"AdUIEventType",
"AdUIType",
"AdUnitStatus",
"AdornCullingMode",
"AlignType",
"AlphaMode",
"AnalyticsCustomFieldKeys",
"AnalyticsEconomyAction",
"AnalyticsEconomyFlowType",
"AnalyticsEconomyTransactionType",
"AnalyticsLogLevel",
"AnalyticsProgressionStatus",
"AnalyticsProgressionType",
"AnimationClipFromVideoStatus",
"AnimationPriority",
"AnimatorRetargetingMode",
"AnnotationEditingMode",
"AnnotationRequestStatus",
"AnnotationRequestType",
"AppLifecycleManagerState",
"AppShellActionType",
"AppShellFeature",
"AppUpdateStatus",
"ApplyStrokeMode",
"AspectType",
"AssetCreatorType",
"AssetFetchStatus",
"AssetType",
"AssetTypeVerification",
"AudioApiRollout",
"AudioCaptureMode",
"AudioChannelLayout",
"AudioFilterType",
"AudioSimulationFidelity",
"AudioSubType",
"AudioWindowSize",
"AuthorityMode",
"AutoIndentRule",
"AutomaticSize",
"AvatarAssetType",
"AvatarChatServiceFeature",
"AvatarContextMenuOption",
"AvatarItemType",
"AvatarPromptResult",
"AvatarSettingsAccessoryLimitMethod",
"AvatarSettingsAccessoryMode",
"AvatarSettingsAnimationClipsMode",
"AvatarSettingsAnimationPacksMode",
"AvatarSettingsAppearanceMode",
"AvatarSettingsBuildMode",
"AvatarSettingsClothingMode",
"AvatarSettingsCollisionMode",
"AvatarSettingsCustomAccessoryMode",
"AvatarSettingsCustomBodyType",
"AvatarSettingsCustomClothingMode",
"AvatarSettingsHitAndTouchDetectionMode",
"AvatarSettingsJumpMode",
"AvatarSettingsLegacyCollisionMode",
"AvatarSettingsScaleMode",
"AvatarThumbnailCustomizationType",
"AvatarUnificationMode",
"Axis",
"BenefitType",
"BinType",
"BodyPart",
"BodyPartR15",
"BorderMode",
"BorderStrokePosition",
"BreakReason",
"BreakpointRemoveReason",
"BulkMoveMode",
"BundleType",
"Button",
"ButtonStyle",
"CageType",
"CameraMode",
"CameraPanMode",
"CameraSpeedAdjustBinding",
"CameraType",
"CaptureGalleryPermission",
"CaptureType",
"CatalogCategoryFilter",
"CatalogSortAggregation",
"CatalogSortType",
"CellBlock",
"CellMaterial",
"CellOrientation",
"CenterDialogType",
"CharacterControlMode",
"ChatCallbackType",
"ChatColor",
"ChatMode",
"ChatPrivacyMode",
"ChatRestrictionStatus",
"ChatStyle",
"ChatVersion",
"ClientAnimatorThrottlingMode",
"CloseReason",
"CollaboratorStatus",
"CollisionFidelity",
"CommandPermission",
"CompileTarget",
"CompletionAcceptanceBehavior",
"CompletionItemKind",
"CompletionItemTag",
"CompletionTriggerKind",
"CompositeValueCurveType",
"CompressionAlgorithm",
"ComputerCameraMovementMode",
"ComputerMovementMode",
"ConfigSnapshotErrorState",
"ConnectionError",
"ConnectionState",
"ContentSourceType",
"ContextActionPriority",
"ContextActionResult",
"ControlMode",
"CoreGuiType",
"CreateAssetResult",
"CreateOutfitFailure",
"CreatorType",
"CreatorTypeFilter",
"CurrencyType",
"CustomCameraMode",
"DataStoreRequestType",
"DebuggerEndReason",
"DebuggerExceptionBreakMode",
"DebuggerFrameType",
"DebuggerPauseReason",
"DebuggerStatus",
"DevCameraOcclusionMode",
"DevComputerCameraMovementMode",
"DevComputerMovementMode",
"DevTouchCameraMovementMode",
"DevTouchMovementMode",
"DeveloperMemoryTag",
"DeviceFeatureType",
"DeviceForm",
"DeviceLevel",
"DeviceType",
"DialogBehaviorType",
"DialogPurpose",
"DialogTone",
"DisplaySize",
"DominantAxis",
"DraftStatusCode",
"DragDetectorDragStyle",
"DragDetectorPermissionPolicy",
"DragDetectorResponseStyle",
"DraggerCoordinateSpace",
"DraggerMovementMode",
"DraggingScrollBar",
"EasingDirection",
"EasingStyle",
"ElasticBehavior",
"EnviromentalPhysicsThrottle",
"ExperienceAuthScope",
"ExperienceEventStatus",
"ExplosionType",
"FACSDataLod",
"FacialAgeEstimationResultType",
"FacialAnimationStreamingState",
"FacsActionUnit",
"FieldOfViewMode",
"FillDirection",
"FilterErrorType",
"FilterResult",
"FinishRecordingOperation",
"FluidFidelity",
"FluidForces",
"Font",
"FontSize",
"FontStyle",
"FontWeight",
"ForceLimitMode",
"FormFactor",
"FrameStyle",
"FramerateManagerMode",
"FriendRequestEvent",
"FriendStatus",
"FunctionalTestResult",
"GameAvatarType",
"GamepadType",
"GearGenreSetting",
"GearType",
"Genre",
"GraphicsMode",
"GraphicsOptimizationMode",
"GroupMembershipStatus",
"GuiState",
"GuiType",
"HandlesStyle",
"HapticEffectType",
"HashAlgorithm",
"HighlightDepthMode",
"HorizontalAlignment",
"HoverAnimateSpeed",
"HttpCachePolicy",
"HttpCompression",
"HttpContentType",
"HttpError",
"HttpRequestType",
"HumanoidCollisionType",
"HumanoidDisplayDistanceType",
"HumanoidHealthDisplayType",
"HumanoidRigType",
"HumanoidStateType",
"IKCollisionsMode",
"IKControlConstraintSupport",
"IKControlType",
"IXPLoadingStatus",
"ImageAlphaType",
"ImageCombineType",
"InOut",
"InfoType",
"InitialDockState",
"InputActionType",
"InputType",
"InstanceFileSyncStatus",
"IntermediateMeshGenerationResult",
"InterpolationThrottlingMode",
"InviteState",
"ItemLineAlignment",
"Language",
"LeftRight",
"LexemeType",
"LightingStyle",
"Limb",
"LineJoinMode",
"ListDisplayMode",
"ListenerLocation",
"ListenerType",
"LiveEditingAtomicUpdateResponse",
"LiveEditingBroadcastMessageType",
"LoadCharacterLayeredClothing",
"LoadDynamicHeads",
"LocationType",
"LuauTypeCheckMode",
"MarketplaceBulkPurchasePromptStatus",
"MarketplaceItemPurchaseStatus",
"MarketplaceProductType",
"MarkupKind",
"MatchmakingType",
"Material",
"MaterialPattern",
"MembershipType",
"MeshPartDetailLevel",
"MeshPartHeadsAndAccessories",
"MeshScaleUnit",
"MeshType",
"MessageType",
"ModelLevelOfDetail",
"ModelStreamingBehavior",
"ModelStreamingMode",
"ModerationStatus",
"ModifierKey",
"MouseBehavior",
"MoveState",
"MoverConstraintRootBehaviorMode",
"MuteState",
"NameOcclusion",
"NegateOperationHiddenHistory",
"NetworkOwnership",
"NetworkStatus",
"NoiseType",
"NormalId",
"NotificationButtonType",
"OperationType",
"OrientationAlignmentMode",
"OutfitSource",
"OutfitType",
"OutputLayoutMode",
"OverrideMouseIconBehavior",
"PackagePermission",
"PartType",
"ParticleEmitterShape",
"ParticleEmitterShapeInOut",
"ParticleEmitterShapeStyle",
"ParticleFlipbookLayout",
"ParticleFlipbookMode",
"ParticleFlipbookTextureCompatible",
"ParticleOrientation",
"PathStatus",
"PathWaypointAction",
"PathfindingUseImprovedSearch",
"PermissionLevelShown",
"PhysicsSimulationRate",
"PhysicsSteppingMethod",
"Platform",
"PlaybackState",
"PlayerActions",
"PlayerCharacterDestroyBehavior",
"PlayerChatType",
"PlayerDataErrorState",
"PlayerDataLoadFailureBehavior",
"PlayerExitReason",
"PoseEasingDirection",
"PoseEasingStyle",
"PositionAlignmentMode",
"PredictionMode",
"PredictionStatus",
"PreferredInput",
"PreferredTextSize",
"PrimalPhysicsSolver",
"PrimitiveType",
"PrivilegeType",
"ProductLocationRestriction",
"ProductPurchaseChannel",
"ProductPurchaseDecision",
"PromptCreateAssetResult",
"PromptCreateAvatarResult",
"PromptPublishAssetResult",
"PropertyStatus",
"ProximityPromptExclusivity",
"ProximityPromptInputType",
"ProximityPromptStyle",
"QualityLevel",
"R15CollisionType",
"RaycastFilterType",
"ReadCapturesFromGalleryResult",
"RecommendationActionType",
"RecommendationDepartureIntent",
"RecommendationImpressionType",
"RecommendationItemContentType",
"RecommendationItemVisibility",
"RejectCharacterDeletions",
"RenderFidelity",
"RenderPriority",
"RenderingCacheOptimizationMode",
"RenderingTestComparisonMethod",
"ReplicateInstanceDestroySetting",
"ResamplerMode",
"ReservedHighlightId",
"RestPose",
"ReturnKeyType",
"ReverbType",
"RibbonTool",
"RigScale",
"RigType",
"RollOffMode",
"RolloutState",
"RotationOrder",
"RotationType",
"RsvpStatus",
"RtlTextSupport",
"RunContext",
"RunState",
"RuntimeUndoBehavior",
"SafeAreaCompatibility",
"SalesTypeFilter",
"SandboxedInstanceMode",
"SaveAvatarThumbnailCustomizationFailure",
"SaveFilter",
"SavedQualitySetting",
"ScaleType",
"ScopeCheckResult",
"ScreenInsets",
"ScreenOrientation",
"ScrollBarInset",
"ScrollingDirection",
"SecurityCapability",
"SelectionBehavior",
"SelectionRenderMode",
"SelfViewPosition",
"SensorMode",
"SensorUpdateType",
"ServerLiveEditingMode",
"ServiceVisibility",
"Severity",
"ShowAdResult",
"SignalBehavior",
"SizeConstraint",
"SolverConvergenceMetricType",
"SolverConvergenceVisualizationMode",
"SortDirection",
"SortOrder",
"SpecialKey",
"StartCorner",
"StateObjectFieldType",
"Status",
"StepFrequency",
"StreamOutBehavior",
"StreamingIntegrityMode",
"StreamingPauseMode",
"StrokeSizingMode",
"StudioCloseMode",
"StudioDataModelType",
"StudioPlaceUpdateFailureReason",
"StudioScriptEditorColorCategories",
"StudioScriptEditorColorPresets",
"StudioStyleGuideColor",
"StudioStyleGuideModifier",
"Style",
"SubscriptionExpirationReason",
"SubscriptionPaymentStatus",
"SubscriptionPeriod",
"SubscriptionState",
"SurfaceConstraint",
"SurfaceGuiShape",
"SurfaceGuiSizingMode",
"SurfaceType",
"SwipeDirection",
"SystemThemeValue",
"TableMajorAxis",
"TeamCreateErrorState",
"Technology",
"TeleportMethod",
"TeleportResult",
"TeleportState",
"TeleportType",
"TerrainAcquisitionMethod",
"TerrainFace",
"TextChatMessageStatus",
"TextDirection",
"TextFilterContext",
"TextInputType",
"TextTruncate",
"TextXAlignment",
"TextYAlignment",
"TextureMode",
"TextureQueryType",
"ThreadPoolConfig",
"ThrottlingPriority",
"ThumbnailSize",
"ThumbnailType",
"TickCountSampleMethod",
"TonemapperPreset",
"TopBottom",
"TouchCameraMovementMode",
"TouchMovementMode",
"TrackerError",
"TrackerExtrapolationFlagMode",
"TrackerFaceTrackingStatus",
"TrackerLodFlagMode",
"TrackerLodValueMode",
"TrackerMode",
"TrackerPromptEvent",
"TrackerType",
"TriStateBoolean",
"TweenStatus",
"UICaptureMode",
"UIDragDetectorBoundingBehavior",
"UIDragDetectorDragRelativity",
"UIDragDetectorDragSpace",
"UIDragDetectorDragStyle",
"UIDragDetectorResponseStyle",
"UIDragSpeedAxisMapping",
"UIFlexAlignment",
"UIFlexMode",
"UITheme",
"UiMessageType",
"UploadCaptureResult",
"UsageContext",
"UserCFrame",
"UserInputState",
"UserInputType",
"VRComfortSetting",
"VRControllerModelMode",
"VRDeviceType",
"VRLaserPointerMode",
"VRSafetyBubbleMode",
"VRScaling",
"VRSessionState",
"VRTouchpad",
"VRTouchpadMode",
"VelocityConstraintMode",
"VerticalAlignment",
"VerticalScrollBarPosition",
"VibrationMotor",
"VideoCaptureResult",
"VideoCaptureStartedResult",
"VideoDeviceCaptureQuality",
"VideoError",
"VideoSampleSize",
"ViewMode",
"VirtualCursorMode",
"VirtualInputMode",
"VoiceChatDistanceAttenuationType",
"VoiceChatState",
"VoiceControlPath",
"VolumetricAudio",
"WaterDirection",
"WaterForce",
"WebSocketState",
"WebStreamClientState",
"WebStreamClientType",
"WeldConstraintPreserve",
"WhisperChatPrivacyMode",
"WrapLayerAutoSkin",
"WrapLayerDebugMode",
"WrapTargetDebugMode",
"ZIndexBehavior",
"Data",
"Settings",
"fromURL",
"fromPath",
"ServerSide",
"ServerRun",
"ServerExecute",
}

UI.loc.enums = {}

for _, name in ipairs(UI.loc.enumList) do
	UI.loc.enums[name] = true
end

UI.loc.exeList = {
["cache.invalidate"]=true,
["cache.iscached"]=true,
["cache.replace"]=true,
["cloneref"]=true,
["compareinstances"]=true,
["base64_encode"]=true,
["base64_decode"]=true,
["debug.getconstant"]=true,
["debug.getconstants"]=true,
["debug.getinfo"]=true,
["debug.getproto"]=true,
["debug.getprotos"]=true,
["debug.getupvalue"]=true,
["debug.getupvalues"]=true,
["debug.setconstant"]=true,
["getgc"]=true,
["getloadedmodules"]=true,
["getrunningscripts"]=true,
["getscripts"]=true,
["getsenv"]=true,
["hookmetamethod"]=true,
["iscclosure"]=true,
["isexecutorclosure"]=true,
["islclosure"]=true,
["newcclosure"]=true,
["setreadonly"]=true,
["lz4compress"]=true,
["lz4decompress"]=true,
["getscriptclosure"]=true,
["request"]=true,
["getcallbackvalue"]=true,
["listfiles"]=true,
["writefile"]=true,
["isfolder"]=true,
["makefolder"]=true,
["appendfile"]=true,
["isfile"]=true,
["delfolder"]=true,
["delfile"]=true,
["loadfile"]=true,
["gethui"]=true,
["getrawmetatable"]=true,
["isreadonly"]=true,
["getnamecallmethod"]=true,
["setscriptable"]=true,
["isscriptable"]=true,
["getinstances"]=true,
["getnilinstances"]=true,
["fireproximityprompt"]=true,
["setrawmetatable"]=true,
["getthreadidentity"]=true,
["setthreadidentity"]=true,
["getrenderproperty"]=true,
["setrenderproperty"]=true,
["Drawing.new"]=true,
["Drawing.Fonts"]=true,
["cleardrawcache"]=true,
["loadstring"]=true,
["debug.setupvalue"]=true,
["readfile"]=true,
["getscriptbytecode"]=true,
["getcallingscript"]=true,
["isrenderobj"]=true,
["firesignal"]=true,
["getscripthash"]=true,
["identifyexecutor"]=true,
["getfunctionhash"]=true,
["gethiddenproperty"]=true,
["debug.getstack"]=true,
["firetouchinterest"]=true,
["filtergc"]=true,
["getrenv"]=true,
["crypt.decrypt"]=true,
["crypt.generatebytes"]=true,
["crypt.generatekey"]=true,
["getconnections"]=true,
["checkcaller"]=true,
["crypt.encrypt"]=true,
["fireclickdetector"]=true,
["debug.setstack"]=true,
["decompile"]=true,
["hookfunction"]=true,
["restorefunction"]=true,
["clonefunction"]=true,
["getgenv"]=true,
["getcustomasset"]=true,
["sethiddenproperty"]=true,
["WebSocket.connect"]=true,
["replicatesignal"]=true,
["crypt.hash"]=true,
["getLoad"]=true,
}
------------------------------------------------------------
UI.loc.cooldown = false
UI.loc.detected = false

UI.loc.editb:GetPropertyChangedSignal("Text"):Connect(function()
	local found = UI.loc.editb.Text:match("%f[%w]getLoad%f[%W]") or UI.loc.editb.Text:match("%f[%w]Data%f[%W]") or UI.loc.editb.Text:match("%f[%w]Settings%f[%W]") or UI.loc.editb.Text:match("%f[%w]fromURL%f[%W]") or UI.loc.editb.Text:match("%f[%w]fromPath%f[%W]") or UI.loc.editb.Text:match("%f[%w]ServerSide%f[%W]") or UI.loc.editb.Text:match("%f[%w]ServerRun%f[%W]") or UI.loc.editb.Text:match("%f[%w]ServerExecute%f[%W]")

	if found and not UI.loc.detected and not UI.loc.cooldown then
		UI.loc.detected = true
		UI.loc.cooldown = true
		
		UI.loc.noti(10, "these syntax that you typed is not made by official sUNC, so it only can use for the ExperienceSettings.", UI.loc.color.yellow)

		task.delay(20,function()
			UI.loc.cooldown = false
		end)

	elseif not found then
		UI.loc.detected = false
	end
end)
------------------------------------------------------------
-- Escape FIRST
UI.loc.escape = function(text)
	return text
		:gsub("&","&amp;")
  	:gsub("<","&lt;")
		:gsub(">","&gt;")
end

UI.loc.highlightLine = function(raw)

	local safe = UI.loc.escape(raw)

	-- protect escaped entities temporarily
	local entities = {}
	safe = safe:gsub("&[%a]+;", function(ent)
		table.insert(entities, ent)
		return "\0"..#entities.."\0"
	end)

	-- highlight comments
	safe = safe:gsub("%-%-.*", function(c)
		return '<font color="'..UI.loc.COLORS.Comment..'">'..c..'</font>'
	end)

	-- highlight strings
	safe = safe:gsub('"(.-)"', function(str)
		return '<font color="'..UI.loc.COLORS.String..'">"'..str..'"</font>'
	end)

	safe = safe:gsub("'(.-)'", function(str)
		return '<font color="'..UI.loc.COLORS.String..'">\''..str..'\'</font>'
	end)

-- highlight identifiers
safe = safe:gsub("(%f[%w_](%a[%w_]*)%f[^%w_])", function(full, word)

    if UI.loc.keywords[word] then
        return '<font color="'..UI.loc.COLORS.Keyword..'">'..word..'</font>'

    elseif UI.loc.datatype[word] then
        return '<font color="'..UI.loc.COLORS.Datatype..'">'..word..'</font>'

    elseif UI.loc.globals[word] then
        return '<font color="'..UI.loc.COLORS.Global..'">'..word..'</font>'

    elseif UI.loc.classes[word] then
        return '<font color="'..UI.loc.COLORS.Class..'">'..word..'</font>'
    elseif UI.loc.enums[word] then
      	return '<font color="'..UI.loc.COLORS.Enum..'">'..word..'</font>'
    elseif UI.loc.exeList[word] then
        return '<font color="'..UI.loc.COLORS.Exe..'">'..word..'</font>'
    end

    return word
end)

	-- restore entities
	safe = safe:gsub("\0(%d+)\0", function(i)
		return entities[tonumber(i)]
	end)

	return safe
end

UI.loc.isValidRichText = function(text)
	local open = 0
	
	for tag in text:gmatch("<(/?font[^>]*)>") do
		if tag:sub(1,1) == "/" then
			open -= 1
		else
			open += 1
		end
		
		if open < 0 then
			return false
		end
	end
	
	return open == 0
end


--// SPLIT
UI.loc.getLines = function(text)
	local t = {}
	for line in text:gmatch("([^\n]*)\n?") do
		table.insert(t,line)
	end
	return t
end

--// RENDER
UI.loc.render = function()

	local lines = UI.loc.getLines(UI.loc.editBox.Text)
	local total = #lines

	UI.loc.scroll.CanvasSize = UDim2.new(1000, 0, 0, total * UI.loc.LINE_HEIGHT)

	local first = math.floor(UI.loc.scroll.CanvasPosition.Y / UI.loc.LINE_HEIGHT) + 1
	local last = math.min(first + UI.loc.VISIBLE_BUFFER, total)

	local txt = {}
	local nums = {}

	for i = first,last do
	
  	local raw = lines[i] or ""
  	local result = UI.loc.highlightLine(raw)

    	if not UI.loc.isValidRichText(result) then
  		result = UI.loc.escape(raw)
  	end
	
   	table.insert(txt, result)
  	table.insert(nums, i)
  end

	UI.loc.highlight.Text = table.concat(txt,"\n")
	UI.loc.lineNumbers.Text = table.concat(nums,"\n")

	local y = (first-1)*UI.loc.LINE_HEIGHT

	UI.loc.highlight.Position = UDim2.new(0,50,0,y)
	UI.loc.lineNumbers.Position = UDim2.new(0,0,0,y)

	UI.loc.highlight.Size = UDim2.new(1,-50,0,(last-first+1)*UI.loc.LINE_HEIGHT)
	UI.loc.lineNumbers.Size = UDim2.new(0,46,0,(last-first+1)*UI.loc.LINE_HEIGHT)
end


UI.loc.editBox:GetPropertyChangedSignal("Text"):Connect(UI.loc.render)
UI.loc.scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(UI.loc.render)

UI.loc.render()

--[ End of syntax script ]

--[ Script new ]
UI.loc.stab = Instance.new("ScrollingFrame")
UI.loc.stab.Name = "ScriptTabs"
UI.loc.stab.Position = UDim2.new(0.51,0,0,0)
UI.loc.stab.Size = UDim2.new(0.49,0,0.1,0)
UI.loc.stab.BackgroundColor3 = Color3.new(1,1,1)
UI.loc.stab.BackgroundTransparency = 0.5
UI.loc.stab.CanvasSize = UDim2.new(100,0,0,0)
UI.loc.stab.ScrollBarThickness = 2
UI.loc.stab.ScrollingDirection = Enum.ScrollingDirection.X
UI.loc.stab.Parent = UI.loc.Frame.Edit.Inside
UI.Corner(0.15,0,UI.loc.stab)
UI.Stroke(UI.loc.stab, UI.StrokeUI.ASMBorder, 255,255,255, UI.StrokeUI.LJMRound, 2, 0)
UI.Gradient(UI.loc.stab, 90,0,0,
  Color3.fromRGB(0,0,255),
  Color3.fromRGB(0,255,255)
)

UI.loc.stabi = Instance.new("Frame")
UI.loc.stabi.Name = "Inside"
UI.loc.stabi.Position = UDim2.new(0,0,0.1,0)
UI.loc.stabi.Size = UDim2.new(1,0,0.8,0)
UI.loc.stabi.BackgroundTransparency = 1
UI.loc.stabi.Active = false
UI.loc.stabi.Parent = UI.loc.stab
UI.ListLayout(UI.loc.stabi, 0,5, UI.ListUI.HLeft, UI.ListUI.VCenter, UI.ListUI.SLayout, UI.ListUI.FillH)

UI.loc.uia = function(parent, num)
  local Ui = Instance.new("UIAspectRatioConstraint")
  Ui.AspectRatio = num
  Ui.Parent = parent
end
  
UI.loc.addbtn = Instance.new("ImageButton")
UI.loc.addbtn.Name = "Z99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999_AddScript"
UI.loc.addbtn.Size = UDim2.new(1,0,1,0)
UI.loc.addbtn.BackgroundColor3 = Color3.new(0,0,0)
UI.loc.addbtn.Image = "rbxassetid://115181877700997"
UI.loc.addbtn.LayoutOrder = 99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
UI.loc.addbtn.Parent = UI.loc.stabi
UI.loc.uia(UI.loc.addbtn, 1)
UI.Corner(0.2,0,UI.loc.addbtn)
UI.Stroke(UI.loc.addbtn, UI.StrokeUI.ASMBorder, 255,255,255, UI.StrokeUI.LJMRound, 1, 0)

--// ===============================
--// PATH
--// ===============================

UI.loc.Edits = game:GetService("CoreGui")["ExperienceSettings-Executor"]
	.Main.Background.Windows.Edit.Inside.EditScroll
	
local Editb = UI.loc.Edits.Edit

------------------------------------------------------------
--------------------------------------------------
-- CONFIG
--------------------------------------------------

ASSET_PATH = "ExperienceSettings-Executor/Assets"

UI.loc.assets = {
	["7z"] = "https://i.postimg.cc/7LWyhTXQ/7z.png",
	["apk"] = "https://i.postimg.cc/1tV1q5Yj/apk.png",
	["auto-execute"] = "https://i.postimg.cc/wvRYmTbb/auto-execute.png",
	["black-shade"] = "https://i.postimg.cc/wvRYmTbP/black-shade.png",
	["blue-shade"] = "https://i.postimg.cc/QtKZTxnz/blue-shade.png",
	["bookmark"] = "https://i.postimg.cc/yd3CZYbq/bookmark.png",
	["cam"] = "https://i.postimg.cc/qR6H3M5V/cam.png",
	["check-in"] = "https://i.postimg.cc/gJLbZkTW/check-in.png",
	["check-out"] = "https://i.postimg.cc/k4RPbXpJ/check-out.png",
	["console"] = "https://i.postimg.cc/C5yTHT3w/console.png",
	["copy"] = "https://i.postimg.cc/HnGD4Dqp/copy.png",
	["cross"] = "https://i.postimg.cc/ZnktFtGb/cross.png",
	["cross-white"] = "https://i.postimg.cc/rs6XCXBF/cross-white.png",
	["cyan-shade"] = "https://i.postimg.cc/fy4njnGk/cyan-shade.png",
	["debug"] = "https://i.postimg.cc/x8rDyDwc/debug.png",
	["down"] = "https://i.postimg.cc/4yCkbkDY/down.png",
	["editor"] = "https://i.postimg.cc/rs6XCXBd/editor.png",
	["erase"] = "https://i.postimg.cc/PJGszsgD/erase.png",
	["error"] = "https://i.postimg.cc/x8rDyDwv/erorr.png",
	["exe"] = "https://i.postimg.cc/9035t56t/exe.png",
	["execute"] = "https://i.postimg.cc/rs6XCXBN/execute.png",
	["file"] = "https://i.postimg.cc/Znrkwsmy/file.png",
	["folder-"] = "https://i.postimg.cc/cCQqFkWt/folder.png",
	["gray-shade"] = "https://i.postimg.cc/90G3Lg2Z/gray-shade.png",
	["home"] = "https://i.postimg.cc/HnQG6vm4/home.png",
	["info"] = "https://i.postimg.cc/C5jycr0G/info.png",
	["ipa"] = "https://i.postimg.cc/VvjyKZwW/ipa.png",
	["left"] = "https://i.postimg.cc/QCpLfYD0/left.png",
	["left-arrow"] = "https://i.postimg.cc/j2zVM3Th/left-arrow.png",
	["lua-file"] = "https://i.postimg.cc/Znrkwsmf/lua-file.png",
	["orange-shade"] = "https://i.postimg.cc/BbxWm737/orange-shade.png",
	["paste"] = "https://i.postimg.cc/ZnrkwsZk/paste.png",
	["paste-and-execute"] = "https://i.postimg.cc/7hgvKt4c/paste-and-execute.png",
	["pink-shade"] = "https://i.postimg.cc/FzjtTCm5/pink-shade.png",
	["plus"] = "https://i.postimg.cc/mZMGZk9r/plus.png",
	["plus-cyan"] = "https://i.postimg.cc/c1YN1C3x/plus-cyan.png",
	["png"] = "https://i.postimg.cc/fWXhWydm/png.png",
	["print"] = "https://i.postimg.cc/FFcQFzSS/print.png",
	["red-shade"] = "https://i.postimg.cc/T2mX21bm/red-shade.png",
	["right"] = "https://i.postimg.cc/pV8tVrjf/right.png",
	["right-arrow"] = "https://i.postimg.cc/VsMcsvtC/right-arrow.png",
	["scriptblox"] = "https://i.postimg.cc/dQdKQ3Cm/scriptblox-com.png",
	["search"] = "https://i.postimg.cc/c1YN1C3m/seacrh.png",
	["select"] = "https://i.postimg.cc/BZDGZbFC/select.png",
	["settings"] = "https://i.postimg.cc/dtYchFRm/settings.png",
	["unknown-file"] = "https://i.postimg.cc/VsMcsvt7/unknown-file.png",
	["unknown-icon"] = "https://i.postimg.cc/65Xx8KV0/unknown-icon.png",
	["up"] = "https://i.postimg.cc/X7b6rWKg/up.png",
	["warn"] = "https://i.postimg.cc/m2sWP43d/warn.png",
	["wearedevs"] = "https://i.postimg.cc/NfcvKt8P/wearedevs-net.png",
	["white-ball"] = "https://i.postimg.cc/yYHCDKhG/white-ball.png",
	["white-ball-fill"] = "https://i.postimg.cc/BQ0fj35V/white-ball-fill.png",
	["white-shade"] = "https://i.postimg.cc/SNhbn4LB/white-shade.png",
	["white-square"] = "https://i.postimg.cc/J4LCs8cM/white-square.png",
	["yellow-shade"] = "https://i.postimg.cc/zXFZWQp9/yellow-shade.png",
	["zip"] = "https://i.postimg.cc/ncGb7WTN/zip.png",
	["folder"] = "https://i.postimg.cc/D0qVxphs/folder.png",
	["music-note"] = "https://i.postimg.cc/rFLBM6hF/music-note.png",
	["game-info"] = "https://i.postimg.cc/T1Bzsq22/game-info.png",
	["autoexewhite"] = "https://i.postimg.cc/MH8fDV9V/autoexewhite.png",
	["filters"] = "https://i.postimg.cc/hGFnFVpN/Filters.png",
	["rscript"] = "https://i.postimg.cc/9fGhcznx/Rscript.png",
}

-------------------------------------------------

--------------------------------------------------
-- VARIABLES
--------------------------------------------------

UI.loc.loadingAssets = false
UI.loc.assetsLoaded = false
UI.loc.failedAssets = {}

--------------------------------------------------
-- ENUMS
--------------------------------------------------

Enums = {}

Enums.Settings = {
	DelExe = "DelExe",
	ReloadExe = "ReloadExe"
}

--------------------------------------------------
-- DOWNLOAD TYPES
--------------------------------------------------

Download = {}

function Download.Asset(type)
	return {mode="DownloadAsset",type=type}
end

function Download.FailedAsset(type)
	return {mode="DownloadFailed",type=type}
end

--------------------------------------------------
-- CHECK TYPES
--------------------------------------------------

Check = {}

function Check.Asset(type)
	return {mode="CheckAsset",type=type}
end

--------------------------------------------------
-- DELETE TYPES
--------------------------------------------------

Del = {}

function Del.Asset(type)
	return {mode="DeleteAsset",type=type}
end

--------------------------------------------------
-- MAIN TABLE
--------------------------------------------------

getLoad = {}

--------------------------------------------------
-- COUNT ASSETS
--------------------------------------------------

UI.loc.countAssets = function()

	if not isfolder or not isfolder(ASSET_PATH) then
		return 0
	end

	local files = listfiles(ASSET_PATH)
	local count = 0

	for _,file in pairs(files) do
		if string.find(file,"%.png") then
			count += 1
		end
	end

	return count

end

--------------------------------------------------
-- DOWNLOAD FILE
--------------------------------------------------

UI.loc.downloadAsset = function(name,url)

	local path = ASSET_PATH.."/"..name..".png"

	if isfile and isfile(path) then
		return true
	end

	local ok,data = pcall(function()
		return game:HttpGet(url)
	end)

	if ok and data then

		writefile(path,data)

		UI.loc.noti(2,"[ "..name.." ] loaded",UI.loc.color.green)

		return true

	else

		table.insert(UI.loc.failedAssets,name)

		UI.loc.noti(2,"[ "..name.." ] failed",UI.loc.color.red)

		return false
	end

end

--------------------------------------------------
-- LOAD ASSETS
--------------------------------------------------

UI.loc.loadAssets = function(mode)

	if UI.loc.loadingAssets then
		return
	end

	if not isfolder(ASSET_PATH) then
		makefolder(ASSET_PATH)
	end

	UI.loc.loadingAssets = true

	local success = 0

	for name,url in pairs(UI.loc.assets) do

		local path = ASSET_PATH.."/"..name..".png"

		if mode == "failed" then

			if not (isfile and isfile(path)) then
				if UI.loc.downloadAsset(name,url) then
					success += 1
				end
			end

		else

			if UI.loc.downloadAsset(name,url) then
				success += 1
			end

		end

	end

	UI.loc.loadingAssets = false

end

--------------------------------------------------
-- CHECK ASSET COUNT
--------------------------------------------------

UI.loc.checkAssets = function()

	UI.loc.noti(4,"Checking all assets...",UI.loc.color.yellow)

	local current = UI.loc.countAssets()

	if current == 62 then
		UI.loc.noti(4,"All assets loaded (62/62)",UI.loc.color.green)
	else
		UI.loc.noti(4,"Assets missing "..current.."/62",UI.loc.color.orange)
	end

end

--------------------------------------------------
-- DELETE ASSETS
--------------------------------------------------

UI.loc.deleteAssets = function()

	UI.loc.noti(4, "Deleting all PNG assets...", UI.loc.color.orange)

	if not isfolder(ASSET_PATH) then
		return
	end

	for _,file in pairs(listfiles(ASSET_PATH)) do
		if string.find(file,"%.png") then
			delfile(file)
		end
	end

	UI.loc.noti(4,"All PNG assets deleted",UI.loc.color.red)

end

--------------------------------------------------
-- EXECUTOR CONTROL
--------------------------------------------------

UI.loc.deleteExecutor = function()

	local cg = game:GetService("CoreGui")

	local gui = cg:FindFirstChild("ExperienceSettings-Executor")

	if gui then
		gui:Destroy()
	end

end

UI.loc.reloadExecutor = function()

	UI.loc.deleteExecutor()

	loadstring(
		game:HttpGet("https://bit.ly/4tJ4Jbn")
	)()

end

--------------------------------------------------
-- SETTINGS API
--------------------------------------------------

function getLoad:Settings(setting)

	if setting == Enums.Settings.DelExe then
		UI.loc.deleteExecutor()
		return
	end

	if setting == Enums.Settings.ReloadExe then
		UI.loc.reloadExecutor()
		return
	end

end

------------------------------------------------
-- ES Executor Client
------------------------------------------------


UI.loc.Remote = UI.s.ReplicatedStorage:FindFirstChild("RotucexeEnabled")

games = games or {}
games.FireEvent = {}

getLoad = getLoad or {}

------------------------------------------------
-- STATES
------------------------------------------------

getLoad.ServerSideEnabled = false
getLoad.ServerSideRequested = false
getLoad.ServerSideVerified = false

------------------------------------------------
-- CONNECT SERVER
------------------------------------------------

function getLoad:ServerSide(mode)

	if mode ~= games.FireEvent then
		return
	end

	getLoad.ServerSideRequested = true

	UI.loc.noti(3,"Fired! Please wait server response.",UI.loc.color.yellow)

	if not UI.loc.Remote then
		UI.loc.noti(3,"Server remote not found.",UI.loc.color.red)
		return
	end

	UI.loc.Remote:FireServer("Verify")

end

------------------------------------------------
-- RECEIVE RESPONSE
------------------------------------------------

if UI.loc.Remote then

	UI.loc.Remote.OnClientEvent:Connect(function(msg)

		getLoad.ServerSideVerified = true

		if msg == "Enabled" then

			getLoad.ServerSideEnabled = true
			UI.loc.noti(3,"Server side enabled!",UI.loc.color.green)

		elseif msg == "Denied" then

			getLoad.ServerSideEnabled = false
			UI.loc.noti(3,"Developer permission denied.",UI.loc.color.red)

		end

	end)

end

------------------------------------------------
-- EXECUTE SCRIPT
------------------------------------------------

function getLoad.ServerExecute()

	if getLoad._executing then
		return
	end

	getLoad._executing = true

	task.spawn(function()

		if not UI.loc.editb then
			UI.loc.noti(3,"Editor not ready!",UI.loc.color.red)
			getLoad._executing = false
			return
		end

		local code = UI.loc.editb.Text

		if code == "" then
			UI.loc.noti(3,"Empty script!",UI.loc.color.red)
			getLoad._executing = false
			return
		end

		----------------------------------------
		-- SERVER EXECUTE
		----------------------------------------

		if getLoad.ServerSideEnabled and UI.loc.Remote then

			UI.loc.Remote:FireServer("RunScript",code)

		else

			UI.loc.noti(3,"Server disabled. Running client.",UI.loc.color.yellow)

			local ok,err = pcall(function()
				loadstring(code)()
			end)

			if not ok then
				warn(err)
			end

		end

		getLoad._executing = false

	end)

end

------------------------------------------------
-- ServerRun
------------------------------------------------

function getLoad:ServerRun(code)

	if typeof(code) ~= "string" then
		UI.loc.noti(3,"ServerRun requires string!",UI.loc.color.red)
		return
	end

	if not UI.loc.Remote then
		UI.loc.noti(3,"Server remote not found. Running client.",UI.loc.color.yellow)

		local ok,err = pcall(function()
			loadstring(code)()
		end)

		if not ok then
			warn(err)
		end

		return
	end

	UI.loc.noti(3,"Sending server script...",UI.loc.color.yellow)

	UI.loc.Remote:FireServer("ServerRun",code)

end

--------------------------------------------------
-- DATA API
--------------------------------------------------

function getLoad:Data(data)

	if type(data) ~= "table" then
		return
	end

	if data.mode == "DownloadAsset" then
		UI.loc.noti(15,'this take a while to load please wait until you see "Execute Script!". Also you can type "getLoad:Data(Check.Asset("png"))" in Editor and execute to see how many asset have been loaded.',UI.loc.color.yellow)
		UI.loc.loadAssets("all")
	end

	if data.mode == "DownloadFailed" then
		UI.loc.noti(15,'this take a while to load please wait until you see "Execute Script!". Also you can type "getLoad:Data(Check.Asset("png"))" in Editor and execute to see how many asset have been loaded.',UI.loc.color.yellow)
		UI.loc.loadAssets("failed")
	end

	if data.mode == "CheckAsset" then
		UI.loc.checkAssets()
	end

	if data.mode == "DeleteAsset" then
		UI.loc.deleteAssets()
	end

end

--------------------------------------------------
-- MAIN CALL
--------------------------------------------------

UI.loc.mainCall = function(arg)

	if type(arg) == "function" then
		return arg()
	end

	if type(arg) == "string" then

		local f,err = loadstring(arg)

		if f then
			return f()
		end

	end

end

--------------------------------------------------
-- METATABLE
--------------------------------------------------

setmetatable(getLoad,{
	__call = function(_,arg)
		return UI.loc.mainCall(arg)
	end
})

--------------------------------------------------
-- LOAD FROM URL
--------------------------------------------------

function getLoad.fromURL(url)

	if not url then
		return
	end

	local ok,data = pcall(function()
		return game:HttpGet(url)
	end)

	if ok then
		loadstring(data)()
	end

end

--------------------------------------------------
-- LOAD FROM PATH
--------------------------------------------------

function getLoad.fromPath(path)

	if not path then
		return
	end

	if not isfolder(path) then
		return
	end

	for _,file in pairs(listfiles(path)) do

		if string.find(file,"%.lua") then

			local code = readfile(file)

			loadstring(code)()

		end

	end

end

------------------------------------------------------------

--// ===============================
--// WORKIN DATA
--// ===============================

UI.loc.highlightEnabled = true
local currentFile = nil

UI.loc.workinData = {
	version = 1,
	lastOpened = nil,
	syntax = true
}


--// ===============================
--// LOAD WORKIN
--// ===============================

UI.loc.loadWorkin = function()

	-- ถ้าไม่มีไฟล์ สร้างใหม่
	if not isfile(UI.loc.jsonPath) then
		writefile(UI.loc.jsonPath, UI.s.HttpService:JSONEncode(UI.loc.workinData))
	end

	local raw = readfile(UI.loc.jsonPath)

	local ok, decoded = pcall(function()
		return UI.s.HttpService:JSONDecode(raw)
	end)

	if ok and type(decoded) == "table" then
		
		UI.loc.workinData.version = decoded.version or 1
		UI.loc.workinData.lastOpened = decoded.lastOpened
		UI.loc.workinData.syntax = decoded.syntax ~= false
		
		UI.loc.highlightEnabled = UI.loc.workinData.syntax
		
	else
		-- ถ้าไฟล์พัง รีเซ็ต
		writefile(UI.loc.jsonPath, UI.s.HttpService:JSONEncode(UI.loc.workinData))
	end
end


--// ===============================
--// SAVE WORKIN
--// ===============================

UI.loc.saveWorkin = function()

	UI.loc.workinData.syntax = UI.loc.highlightEnabled
	UI.loc.workinData.lastOpened = currentFile

	local ok, encoded = pcall(function()
		return UI.s.HttpService:JSONEncode(UI.loc.workinData)
	end)

	if ok then
		writefile(UI.loc.jsonPath, encoded)
	end
end


--// ===============================
--// INIT
--// ===============================

UI.loc.loadWorkin()

--// ===============================
--// VARIABLES
--// ===============================

local i = 0
local currentFile = nil
UI.loc.loadingFile = false
UI.loc.saveDebounce = false

--// ===============================
--// SAVE SYSTEM
--// ===============================

UI.loc.saveCurrent = function()
	if not currentFile then return end
	if not isfile(currentFile) then return end
	
	writefile(currentFile, Editb.Text)
end

-- AUTO SAVE
Editb:GetPropertyChangedSignal("Text"):Connect(function()
	if UI.loc.loadingFile then return end
	if not currentFile then return end
	if UI.loc.saveDebounce then return end
	
	UI.loc.saveDebounce = true
	
	task.delay(0.3,function()
		if currentFile then
			UI.loc.saveCurrent()
		end
		UI.loc.saveDebounce = false
	end)
end)

--// ===============================
--// SCRIPT ADD
--// ===============================

UI.loc.scriptadd = function(existingFile)

	local filename
	local fullpath

	if existingFile then
		-- โหลดไฟล์เก่า
		fullpath = existingFile
		filename = existingFile:match("[^/\\]+$")
	else
		-- สร้างไฟล์ใหม่
		i += 1
		filename = "Untitled " .. i .. ".lua"
		fullpath = UI.loc.tabsPath .. "/" .. filename

		if not isfile(fullpath) then
			writefile(fullpath, "-- "..filename.."\n")
		end
	end

	local back = Instance.new("Frame")
	back.Name = "Script"
	back.Active = true
	back.Size = UDim2.new(1,0,0,30)
	back.BackgroundColor3 = Color3.new(1,1,1)
	back.Parent = UI.loc.stabi
	UI.Gradient(back, 90,0,0,
	  Color3.fromRGB(0,150,150),
	  Color3.fromRGB(150,0,150)
	 )
	
	UI.Corner(0.1,0,back)
	UI.Stroke(back, UI.StrokeUI.ASMBorder,255,255,255,UI.StrokeUI.LJMRound,1,0)
	UI.loc.uia(back,4)

	local scr = Instance.new("TextButton")
	scr.Name = filename
	scr.Text = filename
	scr.BackgroundTransparency = 1
	scr.Size = UDim2.new(0.74,0,0,28)
	scr.BackgroundColor3 = Color3.fromRGB(255,255,255)
	scr.TextColor3 = Color3.new(1,1,1)
	scr.TextXAlignment = Enum.TextXAlignment.Center
	scr.TextScaled = true
	scr.Parent = back

	scr.MouseButton1Click:Connect(function()
		if currentFile then
			UI.loc.saveCurrent()
		end
		
		UI.loc.loadingFile = true
		currentFile = fullpath
		Editb.Text = readfile(fullpath)
		UI.loc.loadingFile = false
	end)

	local des = Instance.new("ImageButton")
	des.Name = "Destroy"
	des.Size = UDim2.new(1,0,1,0)
	des.Position = UDim2.new(0.75,0,0,0)
	des.BackgroundTransparency = 0.5
	des.BackgroundColor3 = Color3.new(0,0,0)
	des.Image = "rbxassetid://136855726459065"
	des.Parent = back
	UI.Stroke(des, UI.StrokeUI.ASMBorder, 255,255,255, UI.StrokeUI.LJMRound, 1, 0)
	UI.Corner(0.2,0,des)
	
	UI.loc.uia(des,1)

	des.MouseButton1Click:Connect(function()
		if currentFile == fullpath then
			Editb.Text = ""
			currentFile = nil
		end
		
		if isfile(fullpath) then
			delfile(fullpath)
		end
		
		back:Destroy()
	end)
end

-- โหลดไฟล์ทั้งหมดตอนเข้าเกม
local files = listfiles(UI.loc.tabsPath)

-- รีเซ็ต i ตามจำนวนไฟล์จริง
i = 0

for _, file in ipairs(files) do
	if file:sub(-4) == ".lua" then
		i += 1
		UI.loc.scriptadd(file)
	end
end

--// ===============================
--// LOAD EXISTING
--// ===============================

UI.loc.loadExistingTabs = function()
	local files = listfiles(UI.loc.tabsPath)
	
	for _, file in ipairs(files) do
		if file:sub(-4) == ".lua" then
			i += 1
			
			local filename = file:match("[^/\\]+$")
			
	        local scr = Instance.new("TextButton")
        	scr.Name = filename
         	scr.Text = filename
         	scr.BackgroundTransparency = 1
         	scr.Size = UDim2.new(0.74,0,0,28)
         	scr.BackgroundColor3 = Color3.fromRGB(255,255,255)
         	scr.TextColor3 = Color3.new(1,1,1)
         	scr.TextXAlignment = Enum.TextXAlignment.Center
         	scr.TextScaled = true
        	scr.Parent = back
			
			scr.MouseButton1Click:Connect(function()
				if currentFile then
					UI.loc.saveCurrent()
				end
				
				UI.loc.loadingFile = true
				currentFile = file
				Editb.Text = readfile(file)
				UI.loc.loadingFile = false
			end)
		end
	end
end

--// ===============================
--// CONNECT BUTTON
--// ===============================

UI.loc.addbtn.MouseButton1Click:Connect(UI.loc.scriptadd)

-- ถ้าต้องการโหลดไฟล์เก่าทั้งหมดตอนเปิด
-- loadExistingTabs()

--[ End of script tabs ]
UI.loc.syntg = Instance.new("TextButton")
UI.loc.syntg.Name = "SyntaxHighlightToggle"
UI.loc.syntg.Position = UDim2.new(0.51,0,0.125,0)
UI.loc.syntg.Size = UDim2.new(1,0,0.1,0)
UI.loc.syntg.BackgroundColor3 = Color3.new(1,1,1)
UI.loc.syntg.TextScaled = true
UI.loc.syntg.TextColor3 = Color3.new(0,0,0)
UI.loc.syntg.Text = "Syntax Highlight"
UI.loc.syntg.Parent = UI.loc.Frame.Edit.Inside
UI.Corner(0.1,0,UI.loc.syntg)
UI.loc.uia(UI.loc.syntg, 4)
UI.loc.syngr = UI.Gradient(UI.loc.syntg, 90,0,0, Color3.fromRGB(255,85,0), Color3.fromRGB(255,255,255)
)

--// ===============================
--// SYNTAX TOGGLE (SYNTG)
--// ===============================

-- อัปเดต UI ตามสถานะ
UI.loc.applySyntaxState = function()

	if UI.loc.highlightEnabled then
		-- ON
		UI.loc.highlight.TextTransparency = 0
		Editb.TextTransparency = 1
		UI.loc.syntg.BackgroundColor3 = Color3.fromRGB(0,255,0)
	else
		-- OFF
		UI.loc.highlight.TextTransparency = 1
		Editb.TextTransparency = 0
		UI.loc.syntg.BackgroundColor3 = Color3.fromRGB(255,0,0)
	end
	UI.loc.noti(2, "Syntax Highlight Update!", UI.loc.color.cyan)

	UI.loc.render()
end


-- หมุน gradient
UI.loc.rotateGradient = function()

	local tween = UI.s.TweenService:Create(
		UI.loc.syngr,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Rotation = UI.loc.syngr.Rotation + 360}
	)

	tween:Play()

	tween.Completed:Connect(function()
		UI.loc.syngr.Rotation = 0
	end)
end


-- ปุ่มคลิก
UI.loc.syntg.MouseButton1Click:Connect(function()

	UI.loc.highlightEnabled = not UI.loc.highlightEnabled

	UI.loc.rotateGradient()
	UI.loc.applySyntaxState()
	UI.loc.saveWorkin()
end)


-- เรียกตอนเริ่มระบบให้ตรงกับค่าที่โหลดมา
UI.loc.applySyntaxState()

--[[ End of syntax toggle ]]

--[[ Execute buttons ]]
UI.loc.etabs = Instance.new("CanvasGroup")
UI.loc.etabs.Name = "Execute tabs"
UI.loc.etabs.Position = UDim2.new(0.51,0,0.85,0)
UI.loc.etabs.Size = UDim2.new(0.49,0,0.15,0)
UI.loc.etabs.BackgroundTransparency = 0.3
UI.loc.etabs.Active = false
UI.loc.etabs.BackgroundColor3 = Color3.fromRGB(70,70,70)
UI.loc.etabs.Parent = UI.loc.Frame.Edit.Inside
UI.Corner(0.1,0,UI.loc.etabs)
UI.Stroke(UI.loc.etabs, UI.StrokeUI.ASMBorder, 255, 255, 255, UI.StrokeUI.LJMRound, 1, 0)

UI.loc.eftabs = Instance.new("Frame")
UI.loc.eftabs.Name = "Inside"
UI.loc.eftabs.Position = UDim2.new(0.05,0,0.15,0)
UI.loc.eftabs.Size = UDim2.new(0.9,0,0.7,0)
UI.loc.eftabs.BackgroundTransparency = 1
UI.loc.eftabs.Active = false
UI.loc.eftabs.Parent = UI.loc.etabs
UI.ListLayout(UI.loc.eftabs, 0, 5, UI.ListUI.HLeft, UI.ListUI.VCenter, UI.ListUI.SLayout, UI.ListUI.FillH)

local function exe(name, imageID, workin)

	local eb = Instance.new("ImageButton")
	eb.Name = tostring(name)
	eb.Size = UDim2.new(1,0,1,0) -- ห้ามแก้
	eb.BackgroundColor3 = Color3.new(0,0,0)
	eb.Image = "rbxassetid://" .. tostring(imageID)
	eb.Parent = UI.loc.eftabs
	
	UI.Corner(0.1,0,eb)
	UI.Stroke(eb, UI.StrokeUI.ASMBorder, 255,255,255, UI.StrokeUI.LJMRound, 1, 0)
	UI.loc.uia(eb, 1)

eb.MouseButton1Click:Connect(function()

	-- ==============================  
	-- 1️⃣ Execute  
	-- ==============================  
	if workin == "Execute" then  
		  
		local src = Editb.Text  
		if not src or src == "" then return end  
		
	  UI.loc.noti(3, "Executing... please wait.", UI.loc.color.yellow)
		  
		local f, compileErr = loadstring(src)  
  
		if not f then  
			local line = tostring(compileErr):match(":(%d+):") or "?"  
			UI.loc.noti(10, "Script Error [Line: "..line.."]:\n"..compileErr, UI.loc.color.red)  
		else  
			local success, runtimeErr = pcall(f)  
			if success then  
				UI.loc.noti(5, "Execute script!", UI.loc.color.green)  
			else  
				local line = tostring(runtimeErr):match(":(%d+):") or "?"  
				UI.loc.noti(10, "Runtime Error [Line: "..line.."]:\n"..runtimeErr, UI.loc.color.red)  
			end  
		end

-- ==============================
-- 2️⃣ Debugger
-- ==============================
elseif workin == "Debugger" then
	
	local src = Editb.Text
	if not src or src == "" then
		UI.loc.noti(3, "No script to debug.", UI.loc.color.red)
		return
	end

	-- ========= 1. Compile Check =========
	local f, compileErr = loadstring(src)
	if not f then
		local line = tostring(compileErr):match(":(%d+):") or "?"
		UI.loc.noti(10, "Compile Error [Line: "..line.."]:\n"..compileErr, UI.loc.color.red)
		return
	end


	-- ========= 2. Structure Check =========
	local function count(word)
		local c = 0
		for _ in src:gmatch("%f[%w]"..word.."%f[%W]") do
			c += 1
		end
		return c
	end

	local problems = {}

	local ifCount = count("if")
	local endCount = count("end")
	local functionCount = count("function")
	local repeatCount = count("repeat")
	local untilCount = count("until")

	if endCount < (ifCount + functionCount + repeatCount) then
		table.insert(problems, "Possible missing 'end'")
	end

	if repeatCount ~= untilCount then
		table.insert(problems, "repeat/until mismatch")
	end


	-- ========= 3. Scan E/W/P =========
	local hasError = src:match("%f[%w]error%f[%W]")
	local hasWarn  = src:match("%f[%w]warn%f[%W]")
	local hasPrint = src:match("%f[%w]print%f[%W]")


	-- ========= 4. Line Count =========
	local lines = 1
	for _ in src:gmatch("\n") do
		lines += 1
	end


	-- ========= 5. Result =========
	if #problems > 0 then
		
		local msg = "[DEBUG FOUND ISSUE]\n"
		msg ..= "Lines: "..lines.."\n\n"
		
		for _,p in ipairs(problems) do
			msg ..= "- "..p.."\n"
		end
		
		-- Show E/W/P only when script has issue
		if hasError then msg ..= "\nContains: error()" end
		if hasWarn then  msg ..= "\nContains: warn()" end
		if hasPrint then msg ..= "\nContains: print()" end
		
		UI.loc.noti(10, msg, UI.loc.color.red)
		
	else
		
		UI.loc.noti(5,
			"[DEBUG SUCCESS]\nLines: "..lines..
			"\nNo structure problems found.",
			UI.loc.color.green
		)
		UI.loc.noti(8, "Its better to execute script because it yields better results.", UI.loc.color.yellow
		)
	end
	
	-- ==============================
	-- 2️⃣ PasteAndExecute
	-- ==============================
	elseif workin == "PasteAndExecute" then
		
		if not getclipboard then
			UI.loc.noti(2, "Clipboard not supported", UI.loc.color.red)
			return
		end
		
		local clip = getclipboard()
		if not clip or clip == "" then return end
		
		Editb.Text = clip
		
		local f, compileErr = loadstring(clip)
		
		if not f then
			local line = tostring(compileErr):match(":(%d+):") or "?"
			UI.loc.noti(10, "Script Error [Line: "..line.."]:\n"..compileErr, UI.loc.color.red)
		else
			local success, runtimeErr = pcall(f)
			if success then
				UI.loc.noti(2, "Paste script and Execute!", UI.loc.color.green)
			else
				local line = tostring(runtimeErr):match(":(%d+):") or "?"
				UI.loc.noti(10, "Runtime Error [Line: "..line.."]:\n"..runtimeErr, UI.loc.color.red)
			end
		end


	-- ==============================
	-- 3️⃣ Paste
	-- ==============================
	elseif workin == "Paste" then
		
		if getclipboard then
			local clip = getclipboard()
			if clip and clip ~= "" then
				Editb.Text = clip
				UI.loc.noti(2, "Paste script!", UI.loc.color.yellow)
			end
		else
			UI.loc.noti(2, "Clipboard not supported", UI.loc.color.red)
		end


	-- ==============================
	-- 4️⃣ Copy
	-- ==============================
	elseif workin == "Copy" then
		
		if setclipboard then
			if Editb.Text ~= "" then
				setclipboard(Editb.Text)
				UI.loc.noti(2, "Copy script!", UI.loc.color.yellow)
			end
		else
			UI.loc.noti(2, "Clipboard not supported", UI.loc.color.red)
		end


	-- ==============================
	-- 5️⃣ Clear
	-- ==============================
	elseif workin == "Clear" then
		
		Editb.Text = ""
		UI.loc.noti(2, "Clear script! Make sure you save it.", UI.loc.color.red)
	end

end)
end

exe("Execute", 104470314612186, "Execute")
exe("Debugger", 95102226021004, "Debugger")
exe("PasteAndExecute", 124911554606290, "PasteAndExecute")
exe("Paste", 81493320721369, "Paste")
exe("Copy", 70463360371392, "Copy")
exe("Clear", 105129411837741, "Clear")

--[[ Keywords seeker ]]
--// UI REFERENCES (ใช้ของนายแทนได้)
local Editb = UI.loc.Frame.Edit.Inside.EditScroll.Edit

UI.loc.kword = Instance.new("ScrollingFrame")
UI.loc.kword.Name = "KeywordsSeeker"
UI.loc.kword.Position = UDim2.new(0.71,0,0.126,0)
UI.loc.kword.Size = UDim2.new(0.29,0,0.7,0)
UI.loc.kword.BackgroundTransparency = 0.5
UI.loc.kword.BackgroundColor3 = Color3.new(0,0,0)
UI.loc.kword.ScrollBarThickness = 0
UI.loc.kword.CanvasSize = UDim2.new(0,0,0,0)
UI.loc.kword.ScrollingDirection = Enum.ScrollingDirection.Y
UI.loc.kword.Parent = UI.loc.Frame.Edit.Inside

UI.Corner(0,0,UI.loc.kword)
UI.ListLayout(UI.loc.kword, 0,2, UI.ListUI.HLeft, UI.ListUI.VTop, UI.ListUI.SLayout, UI.ListUI.FillV)

--====================================================
-- REQUIREMENTS:
-- Editb      = TextBox ที่พิมพ์
-- kword      = Frame / ScrollingFrame แสดงคำ
-- keywords   = table
-- datatype   = table
-- globals    = table
-- COLORS     = table { Keyword=..., Datatype=..., Global=... }
--====================================================


--// CLEAR
UI.loc.clearSuggestions = function()
	for _, child in pairs(UI.loc.kword:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
end


--// BUILD WORD LIST
UI.loc.buildWordList = function()

	local words = {}

	if UI.loc.keywords then
		for k in pairs(UI.loc.keywords) do
			words[k] = "Keyword"
		end
	end

	if UI.loc.datatype then
		for k in pairs(UI.loc.datatype) do
			words[k] = "Datatype"
		end
	end

	if UI.loc.globals then
		for k in pairs(UI.loc.globals) do
			words[k] = "Global"
		end
	end

	if UI.loc.classes then
		for k in pairs(UI.loc.classes) do
			words[k] = "Class"
		end
	end

	if UI.loc.enums then
		for k in pairs(UI.loc.enums) do
			words[k] = "Enum"
		end
	end
	
	if UI.loc.exeList then
	  for k in pairs(UI.loc.exeList) do
	    words[k] = "Exe"
	  end
  end

	return words
end


--// GET CURRENT WORD BASED ON CURSOR
UI.loc.getCurrentWord = function(text, cursorPos)

	if not cursorPos or cursorPos < 1 then
		cursorPos = #text + 1
	end

	local beforeCursor = text:sub(1, cursorPos - 1)
	local current = beforeCursor:match("([%a_][%w_]*)$")

	return current or ""
end


--// REPLACE WORD AT CURSOR
UI.loc.replaceCurrentWord = function(newWord)

	local text = Editb.Text
	local cursorPos = Editb.CursorPosition

	if not cursorPos or cursorPos < 1 then
		return
	end

	local beforeCursor = text:sub(1, cursorPos - 1)
	local afterCursor = text:sub(cursorPos)

	local wordStart = beforeCursor:find("([%a_][%w_]*)$")

	if wordStart then
		local prefix = beforeCursor:sub(1, wordStart - 1)
		local newText = prefix .. newWord .. afterCursor

		Editb.Text = newText
		Editb.CursorPosition = #prefix + #newWord + 1
	end
end


--// CREATE SUGGESTION
UI.loc.createSuggestion = function(keywordName, colorHex, transparency, layout)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,0,22)
	label.BackgroundColor3 = Color3.fromRGB(40,40,40)
	label.BackgroundTransparency = transparency
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.LayoutOrder = layout
	label.TextScaled = true
	label.RichText = true
	label.Text = '<font color="'..colorHex..'">'..keywordName..'</font>'
	label.Parent = UI.loc.kword

	-- Click to replace
	label.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			UI.loc.replaceCurrentWord(keywordName)
		end
	end)
end


--// UPDATE
UI.loc.updateSuggestions = function()

	if not Editb or not UI.loc.kword then
		return
	end

	UI.loc.clearSuggestions()

	local ALL_WORDS = UI.loc.buildWordList()

	local current = UI.loc.getCurrentWord(Editb.Text or "", Editb.CursorPosition)
	if current == "" then
		UI.loc.kword.CanvasSize = UDim2.new(0,0,0,0)
		return
	end

	local lowerCurrent = current:lower()
	local matchCount = 0

	for keywordName, category in pairs(ALL_WORDS) do

		local lowerKeyword = keywordName:lower()

		if lowerKeyword:sub(1, #lowerCurrent) == lowerCurrent then

			local color = UI.loc.COLORS[category] or "#ffffff"

			local transparency = (lowerKeyword == lowerCurrent) and 0 or 0.5

			local layout = (lowerKeyword == lowerCurrent) and 0 or 1

			UI.loc.createSuggestion(keywordName, color, transparency, layout)
			matchCount += 1
		end
	end

	if matchCount == 0 then
		UI.loc.createSuggestion(current, "#ffffff", 1, 2)
		matchCount = 1
	end

	UI.loc.kword.CanvasSize = UDim2.new(0,0,0, matchCount * 24)

end


--// CONNECT EVENTS
if Editb and Editb:IsA("TextBox") then

	Editb:GetPropertyChangedSignal("Text"):Connect(UI.loc.updateSuggestions)
	Editb:GetPropertyChangedSignal("CursorPosition"):Connect(UI.loc.updateSuggestions)

end

------------------------------------------------------------
local PATH = "ExperienceSettings-Executor/AutoExe"

UI.loc.ALLOWED = {
	txt = true,
	lua = true,
	luau = true,
	es = true,
	text = true,
	set = true,
	ver = true,
	json = true,
	html = true,
	py = true,
	js = true,
	sql = true,
	cpp = true,
	cs = true,
	ts = true,
	go = true,
	rs = true,
	php = true,
	swift = true,
	kt = true,
	rb = true,
	r = true,
}

UI.loc.BLOCKED = {
 -- wut
}

UI.loc.getExtension = function(name)
	local ext = name:match("%.([^%.]+)$")
	return ext and string.lower(ext)
end

if not (isfolder and isfolder(PATH)) then
	return
end

local files = listfiles and listfiles(PATH)
if not files then
	return
end

for _, filePath in ipairs(files) do
	
	if isfile and isfile(filePath) then
		
		task.spawn(function() -- 🔥 isolate thread
			
			local fileName = filePath:match("[^/]+$")
			local ext = UI.loc.getExtension(fileName)
			
			if not ext then return end
			if UI.loc.BLOCKED[ext] then return end
			if not UI.loc.ALLOWED[ext] then return end
			
			local source = readfile(filePath)
			if not source or #source <= 3 then return end
			
			local f, compileErr = loadstring(source)
			
			if not f then
				UI.loc.noti(8,
					"[Compile ERROR]\n"..fileName..
					"\n"..tostring(compileErr),
					UI.loc.color.red
				)
				return
			end
			
			local success, runtimeErr = pcall(f)
			
			if not success then
				UI.loc.noti(8,
					"[AutoExe ERROR]\n"..fileName..
					"\n"..tostring(runtimeErr),
					UI.loc.color.red
				)
			end
			
		end)
		
	end
	
end

------------------------------------------------------------
UI.loc.fbar = Instance.new("Frame")
UI.loc.fbar.Name = "FolderBar"
UI.loc.fbar.Size = UDim2.new(1,0,0.15,0)
UI.loc.fbar.BackgroundColor3 = Color3.fromRGB(70,70,70)
UI.loc.fbar.BackgroundTransparency = 0.3
UI.loc.fbar.Active = false
UI.loc.fbar.Parent = UI.loc.Frame.Folder.Inside
UI.Corner(0.2,0, UI.loc.fbar)
UI.Stroke(UI.loc.fbar, UI.StrokeUI.ASMBorder, 165,165,165, UI.StrokeUI.LJMRound, 2, 0)

UI.loc.isbar = Instance.new("Frame")
UI.loc.isbar.Name = "InsideBar"
UI.loc.isbar.Size = UDim2.new(0.95,0,0.75,0)
UI.loc.isbar.Position = UDim2.new(0.015,0,0.15,0)
UI.loc.isbar.BackgroundTransparency = 1
UI.loc.isbar.Parent = UI.loc.fbar
UI.ListLayout(UI.loc.isbar, 0,20, UI.ListUI.HLeft, UI.ListUI.VCenter, UI.ListUI.SLayout, UI.ListUI.FillH)

UI.loc.sebar = Instance.new("TextBox")
UI.loc.sebar.Name = "SearchFileInput"
UI.loc.sebar.Size = UDim2.new(0.5,0,1,0)
UI.loc.sebar.BackgroundTransparency = 1
UI.loc.sebar.TextSize = 16
UI.loc.sebar.PlaceholderText = "Search any file..."
UI.loc.sebar.TextXAlignment = Enum.TextXAlignment.Left
UI.loc.sebar.Text = ""
UI.loc.sebar.TextColor3 = Color3.new(1,1,1)
UI.loc.sebar.ClearTextOnFocus = false
UI.loc.sebar.Parent = UI.loc.isbar


UI.loc.folderIn = Instance.new("Frame")
UI.loc.folderIn.Name = "InsideFolder"
UI.loc.folderIn.Active = false
UI.loc.folderIn.Position = UDim2.new(0,0,0.17,0)
UI.loc.folderIn.Size = UDim2.new(1,0,0.83,0)
UI.loc.folderIn.BackgroundTransparency = 1
UI.loc.folderIn.Parent = UI.loc.Frame.Folder.Inside

UI.loc.filelist = Instance.new("ScrollingFrame")
UI.loc.filelist.Name = "ScrollFileList"
UI.loc.filelist.Size = UDim2.new(0.35,0,1,0)
UI.loc.filelist.BackgroundTransparency = 1
UI.loc.filelist.CanvasSize = UDim2.new(100,0,0,0)
UI.loc.filelist.ScrollBarThickness = 5
UI.loc.filelist.Parent = UI.loc.folderIn
UI.Stroke(UI.loc.filelist, UI.StrokeUI.ASMBorder, 255, 255, 255, UI.StrokeUI.LJMRound, 1, 0)
UI.ListLayout(UI.loc.filelist, 0,1, UI.ListUI.HRight, UI.ListUI.VTop, UI.ListUI.SLayout, UI.ListUI.FillV)

local layout = UI.loc.filelist:FindFirstChildOfClass("UIListLayout")

if not layout then
	layout = Instance.new("UIListLayout")
	layout.Parent = UI.loc.filelist
end

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	UI.loc.filelist.CanvasSize = UDim2.new(100,0,0, layout.AbsoluteContentSize.Y + 10)
end)

UI.loc.FDScroll = Instance.new("ScrollingFrame")
UI.loc.FDScroll.Name = "TextViewerScroll"
UI.loc.FDScroll.Size = UDim2.new(0.64,0,0.8,0)
UI.loc.FDScroll.Position = UDim2.new(0.36,0,0,0)
UI.loc.FDScroll.BackgroundTransparency = 0
UI.loc.FDScroll.BackgroundColor3 = Color3.new(0,0,0)
UI.loc.FDScroll.CanvasSize = UDim2.new(0,0,0,0)
UI.loc.FDScroll.ScrollBarThickness = 1
UI.loc.FDScroll.Active = true
UI.loc.FDScroll.Parent = UI.loc.folderIn

UI.loc.LineNumViwer = Instance.new("TextLabel")
UI.loc.LineNumViwer.Name = "LineNumberViwer"
UI.loc.LineNumViwer.Size = UDim2.new(0,30,1,0)
UI.loc.LineNumViwer.BackgroundColor3 = Color3.fromRGB(48,48,48)
UI.loc.LineNumViwer.Active = false
UI.loc.LineNumViwer.TextColor3 = Color3.fromRGB(129,129,129)
UI.loc.LineNumViwer.TextStrokeTransparency = 0
UI.loc.LineNumViwer.TextStrokeColor3 = Color3.fromRGB(80,80,80)
UI.loc.LineNumViwer.BorderSizePixel = 0
UI.loc.LineNumViwer.TextSize = 15
UI.loc.LineNumViwer.Font = Enum.Font.Code
UI.loc.LineNumViwer.TextWrap = true
UI.loc.LineNumViwer.TextXAlignment = Enum.TextXAlignment.Right
UI.loc.LineNumViwer.TextYAlignment = Enum.TextYAlignment.Top
UI.loc.LineNumViwer.Text = ""
UI.loc.LineNumViwer.Parent = UI.loc.FDScroll

UI.loc.FDtxtview = Instance.new("TextLabel")
UI.loc.FDtxtview.Name = "TextViewer"
UI.loc.FDtxtview.BackgroundTransparency = 1
UI.loc.FDtxtview.Size = UDim2.new(100,0,1,0)
UI.loc.FDtxtview.Position = UDim2.new(0,30,0,0)
UI.loc.FDtxtview.BackgroundColor3 = Color3.new(0,0,0)
UI.loc.FDtxtview.TextColor3 = Color3.new(1,1,1)
UI.loc.FDtxtview.TextXAlignment = Enum.TextXAlignment.Left
UI.loc.FDtxtview.TextYAlignment = Enum.TextYAlignment.Top
UI.loc.FDtxtview.BorderSizePixel = 0
UI.loc.FDtxtview.TextSize = 15
UI.loc.FDtxtview.TextWrap = true
UI.loc.FDtxtview.RichText = true
UI.loc.FDtxtview.Font = Enum.Font.Code
UI.loc.FDtxtview.Text = "-- Cilck any file to view!"
UI.loc.FDtxtview.Parent = UI.loc.FDScroll

UI.loc.FDTabs = Instance.new("Frame")
UI.loc.FDTabs.Name = "FolderTabs"
UI.loc.FDTabs.Position = UDim2.new(0.36,0,0.82,0)
UI.loc.FDTabs.Size = UDim2.new(0.64,0,0.18,0)
UI.loc.FDTabs.Active = false
UI.loc.FDTabs.BackgroundTransparency = 1
UI.loc.FDTabs.Parent = UI.loc.folderIn
UI.ListLayout(UI.loc.FDTabs, 0, 5, UI.ListUI.HLeft, UI.ListUI.VTop, UI.ListUI.SLayout, UI.ListUI.FillH)
UI.Padding(UI.loc.FDTabs, nil, nil, {0.029, 0}, nil)

UI.loc.FDbtn = function(name, text, workin, callback)
  local btn = Instance.new("TextButton")
  btn.Name = tostring(name)
  btn.Size = UDim2.new(1/3, 0, 1, 0)
  btn.BackgroundTransparency = 0.3
  btn.Text = tostring(text)
  btn.TextColor3 = Color3.new(1,1,1)
  btn.TextSize = 10
  btn.Parent = UI.loc.FDTabs
  UI.Stroke(btn, UI.StrokeUI.ASMBorder, 255,255,255, UI.StrokeUI.LJMRound, 1, 0)
  UI.Corner(0.1,0,btn)
  
  -- workin
  
  -- callback
  
  -- return
  
end

UI.loc.FDbtn("PTE", "Paste to Editor")
UI.loc.FDbtn("Copy", "Copy")
UI.loc.FDbtn("Exe", "Execute")

------------------------------------------------
-- STATE
------------------------------------------------

UI.loc.currentSelected = nil
UI.loc.openedFolders = {}

-- 🔍 search
UI.loc.currentSearch = ""

local PATH = ""
UI.loc.ESPATH = "ExperienceSettings-Executor/Assets/"

------------------------------------------------
-- SAFE ASSET
------------------------------------------------

UI.loc.safeAsset = function(path)
	local ok, result = pcall(function()
		return getcustomasset(path)
	end)
	return (ok and result) or ""
end

------------------------------------------------
-- ICONS
------------------------------------------------

UI.loc.iconPH = {
	["apk"] = UI.loc.safeAsset(UI.loc.ESPATH.."apk.png"),
	["ipa"] = UI.loc.safeAsset(UI.loc.ESPATH.."ipa.png"),
	["exe"] = UI.loc.safeAsset(UI.loc.ESPATH.."exe.png"),
	["file"] = UI.loc.safeAsset(UI.loc.ESPATH.."file.png"),
	["png"] = UI.loc.safeAsset(UI.loc.ESPATH.."png.png"),
	["lua-file"] = UI.loc.safeAsset(UI.loc.ESPATH.."lua-file.png"),
	["zip"] = UI.loc.safeAsset(UI.loc.ESPATH.."zip.png"),
	["unknown-file"] = UI.loc.safeAsset(UI.loc.ESPATH.."unknown-file.png"),
	["unknown-icon"] = UI.loc.safeAsset(UI.loc.ESPATH.."unknown-icon.png"),
	["7z"] = UI.loc.safeAsset(UI.loc.ESPATH.."7z.png"),
	["folder-"] = UI.loc.safeAsset(UI.loc.ESPATH.."folder-.png"),
}

------------------------------------------------
-- MATCH SEARCH
------------------------------------------------

UI.loc.matchSearch = function(name)
	if UI.loc.currentSearch == "" then return true end
	return string.find(string.lower(name), UI.loc.currentSearch, 1, true)
end

------------------------------------------------
-- CHECK CHILD MATCH (recursive)
------------------------------------------------

UI.loc.hasMatch = function(path)

	local ok, items = pcall(function()
		return listfiles(path)
	end)

	if not ok or not items then return false end

	for _, p in ipairs(items) do
		local name = p:match("[^/]+$")

		if UI.loc.matchSearch(name) then
			return true
		end

		if isfolder and isfolder(p) then
			if UI.loc.hasMatch(p) then
				return true
			end
		end
	end

	return false
end

------------------------------------------------
-- RESET FOLDER STATE
------------------------------------------------

UI.loc.resetFolders = function()
	for k in pairs(UI.loc.openedFolders) do
		UI.loc.openedFolders[k] = nil
	end
end

------------------------------------------------
-- EXTENSION
------------------------------------------------

UI.loc.getExtension = function(name)
	local ext = name:match("%.([^%.]+)$")
	return ext and string.lower(ext)
end

------------------------------------------------
-- RESOLVE UI
------------------------------------------------

UI.loc.resolveUI = function(fileName, isFolder)
	local ext = UI.loc.getExtension(fileName)

	-- 📁 folder (priority สูงสุด)
	if isFolder then
		return UI.loc.iconPH["folder-"] or UI.loc.iconPH["unknown-file"], true
	end

	-- ❓ ไม่มีนามสกุล
	if not ext then
		return UI.loc.iconPH["unknown-file"], false
	end

	ext = string.lower(ext)

	------------------------------------------------
	-- 🚫 BLOCKED (มาก่อนเลย)
	------------------------------------------------
	if UI.loc.BLOCKED[ext] then
		return UI.loc.iconPH[ext] or UI.loc.iconPH["unknown-icon"], false
	end

	------------------------------------------------
	-- ✅ ALLOWED (เปิดได้)
	------------------------------------------------
	if UI.loc.ALLOWED[ext] then
		if ext == "lua" or ext == "luau" or ext == "es" then
			return UI.loc.iconPH["lua-file"] or UI.loc.iconPH["file"], true
		else
			return UI.loc.iconPH["file"], true
		end
	end

	------------------------------------------------
	-- 📦 SPECIAL TYPES (เปิดไม่ได้ แต่มี icon)
	------------------------------------------------
	if ext == "apk" or ext == "exe" or ext == "ipa" then
		return UI.loc.iconPH[ext] or UI.loc.iconPH["unknown-icon"], false
	end

	if ext == "png" then
		return UI.loc.iconPH["png"] or UI.loc.iconPH["file"], false
	end

	if ext == "zip" or ext == "7z" then
		-- 🔥 สำคัญ: ให้เปิดได้ (pseudo folder)
		return UI.loc.iconPH[ext] or UI.loc.iconPH["file"], true
	end

	------------------------------------------------
	-- ❓ unknown แต่มี icon
	------------------------------------------------
	if UI.loc.iconPH[ext] then
		return UI.loc.iconPH[ext], false
	end

	------------------------------------------------
	-- ❓ unknown จริง
	------------------------------------------------
	return UI.loc.iconPH["unknown-icon"], false
end

------------------------------------------------
-- UI OBJECT
------------------------------------------------

UI.loc.fdlists = function(T, active, icon, ObjectName, offset, filePath)

	local isFolderItem = isfolder and isfolder(filePath)
	local ext = UI.loc.getExtension(ObjectName)
	local isPseudoFolder = (ext == "zip" or ext == "7z")

	local btn = Instance.new("TextButton")
	btn.Name = "Object"
	btn.Size = UDim2.new(1, offset, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
	btn.BackgroundTransparency = T or 1
	btn.Active = true
	btn.TextSize = 0
	btn.Parent = UI.loc.filelist

	--[[ indent
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, offset)
	pad.Parent = btn
	]]

	UI.Stroke(btn, UI.StrokeUI.ASMBorder, 255,255,255, UI.StrokeUI.LJMRound, 1, 0)

	-- icon
	local ima = Instance.new("ImageLabel")
	ima.BackgroundTransparency = 1
	ima.Size = UDim2.new(0,30,1,0)
	ima.Image = icon or ""
	ima.Parent = btn

	-- name
	local na = Instance.new("TextLabel")
	na.BackgroundTransparency = 1
	na.Size = UDim2.new(1,-35,1,0)
	na.Position = UDim2.new(0,35,0,0)
	na.TextSize = 10
	na.TextXAlignment = Enum.TextXAlignment.Left
	na.TextYAlignment = Enum.TextYAlignment.Center
	na.TextColor3 = Color3.new(1,1,1)
	na.Parent = btn

	------------------------------------------------
	-- [+] [-]
	------------------------------------------------

	if isFolderItem or isPseudoFolder then
		if UI.loc.openedFolders[filePath] then
			na.Text = "▼ "..ObjectName
		else
			na.Text = "▶ "..ObjectName
		end
	else
		na.Text = ObjectName
	end

	------------------------------------------------
	-- CLICK
	------------------------------------------------

	btn.MouseButton1Click:Connect(function()

		-- select
		if UI.loc.currentSelected and UI.loc.currentSelected ~= btn then
			UI.loc.currentSelected.BackgroundTransparency = 1
			UI.loc.currentSelected.BackgroundColor3 = Color3.fromRGB(255,255,255)
		end

		UI.loc.currentSelected = btn
		btn.BackgroundTransparency = 0.5
		btn.BackgroundColor3 = Color3.fromRGB(0,95,255)

		------------------------------------------------
		-- folder / zip / 7z
		------------------------------------------------

		if isFolderItem or isPseudoFolder then
			UI.loc.openedFolders[filePath] = not UI.loc.openedFolders[filePath]
			refreshFileList()
			return
		end

		------------------------------------------------
		-- preview text
		------------------------------------------------

		if filePath and isfile and isfile(filePath) then

			local ext = UI.loc.getExtension(ObjectName)
			if ext and UI.loc.ALLOWED[ext] then

				local content = readfile(filePath)
				if not content then return end

				UI.loc.FDtxtview.Text = content

				-- line number
				local count = 1
				for _ in content:gmatch("\n") do
					count += 1
				end

				local lines = ""
				for i = 1, count do
					lines ..= i.."\n"
				end

				UI.loc.LineNumViwer.Text = lines

				task.defer(function()
					local y = UI.loc.FDtxtview.TextBounds.Y
					UI.loc.FDScroll.CanvasSize = UDim2.new(100,0,0, y + 20)
				end)

			end
		end

	end)

	return btn
end

------------------------------------------------
-- REFRESH
------------------------------------------------

function refreshFileList()

	-- clear
	for _, v in ipairs(UI.loc.filelist:GetChildren()) do
		if v.Name == "Object" then
			v:Destroy()
		end
	end

	local function scan(path, depth)

		local ok, items = pcall(function()
			return listfiles(path)
		end)

		if not ok or not items then return end

		for _, p in ipairs(items) do

			local name = p:match("[^/]+$")
			local isFolder = isfolder and isfolder(p)

			local match = UI.loc.matchSearch(name)
			local childMatch = isFolder and UI.loc.hasMatch(p)

			------------------------------------------------
			-- SEARCH MODE
			------------------------------------------------
			if UI.loc.currentSearch ~= "" then

				if not match and not childMatch then
					continue
				end

				if isFolder and childMatch then
					UI.loc.openedFolders[p] = true
				end

			end

			local icon, canOpen = UI.loc.resolveUI(name, isFolder)
			UI.loc.fdlists(1, canOpen, icon, name, depth - 0, p)

			if isFolder and UI.loc.openedFolders[p] then
				scan(p, depth - 30)
			end

		end
	end

	scan(PATH, 0)

	-- canvas fix
	task.defer(function()
		local layout = UI.loc.filelist:FindFirstChildOfClass("UIListLayout")
		if layout then
			UI.loc.filelist.CanvasSize = UDim2.new(100,0,0, layout.AbsoluteContentSize.Y + 10)
		end
	end)

end

------------------------------------------------
-- BTN BAR (รองรับ callback)
------------------------------------------------

UI.loc.btnbar = function(name, imageID, ifLine, workin, callback)

	local bbar = Instance.new("ImageButton")
	bbar.Name = tostring(name)
	bbar.Size = UDim2.new(1,0,1,0)
	bbar.BackgroundTransparency = 1
	bbar.Image = "rbxassetid://"..tostring(imageID)
	bbar.Parent = UI.loc.isbar

	UI.Corner(0.1,0,bbar)
	UI.loc.uia(bbar, 1)

	if ifLine then
		local line = Instance.new("Frame")
		line.Size = UDim2.new(0,3,1,0)
		line.BackgroundColor3 = Color3.fromRGB(170,170,170)
		line.Parent = UI.loc.isbar
	end

	if callback then
		bbar.MouseButton1Click:Connect(callback)
	end

	return bbar
end

------------------------------------------------
-- TEXTBOX SEARCH
------------------------------------------------

UI.loc.sebar:GetPropertyChangedSignal("Text"):Connect(function()

	UI.loc.currentSearch = string.lower(UI.loc.sebar.Text or "")

	if UI.loc.currentSearch == "" then
		UI.loc.resetFolders()
	end

	refreshFileList()

end)

------------------------------------------------
-- BUTTON SEARCH (fix error)
------------------------------------------------

local searchBtn = UI.loc.btnbar("Search", 133955276215666, true, nil, function()
	UI.loc.currentSearch = string.lower(UI.loc.sebar.Text or "")
	refreshFileList()
end)

------------------------------------------------------------

if not (isfolder and isfolder(PATH)) then return end
refreshFileList()

UI.loc.Frame.Folder.Inside.soon.Visible = false
UI.loc.Frame.Folder.Inside.soon.ZIndex = 2
------------------------------------------------------------
local Inside = Instance.new("CanvasGroup")
Inside.Name = "Inside"
Inside.Position = UDim2.new(0.15,0,1.2,0)
Inside.Size = UDim2.new(0.7,0,0.15,0)
Inside.BackgroundColor3 = Color3.fromRGB(18,18,21)
Inside.Transparency = 0.1
Inside.Parent = UI.loc.Bg
UI.Corner(0.2,0,Inside)
UI.Stroke(Inside, UI.StrokeUI.ASMBorder, 255,255,255, UI.StrokeUI.LJMRound, 2, 0)

UI.loc.str1 = Inside.UIStroke
UI.loc.gra1 = UI.Gradient(UI.loc.str1, 45, 0, 0,
    Color3.fromRGB(255,255,255),
    Color3.fromRGB(0,255,255)
)

task.spawn(function()
    while true do        
      task.wait(0.001)
        UI.loc.gra1.Rotation += 3
        if UI.loc.gra1.Rotation == 360 then
           UI.loc.gra1.Rotation = 0
        end

    end
end)

UI.loc.Bar = Instance.new("Frame")
UI.loc.Bar.Name = "Holder"
UI.loc.Bar.Position = UDim2.new(0.02,0,0.25,0)
UI.loc.Bar.Size = UDim2.new(0.96,0,0.5,0)
UI.loc.Bar.BackgroundTransparency = 1
UI.loc.Bar.Parent = Inside
UI.ListLayout(UI.loc.Bar, 0, 10, UI.ListUI.HLeft, UI.ListUI.VCenter, UI.ListUI.SLayout, UI.ListUI.FillH)

local inside = Inside
UI.loc.bounceInfo = TweenInfo.new(
    0.4,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)

UI.loc.shrinkInfo = TweenInfo.new(
    0.2,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)

UI.loc.bgInfo = TweenInfo.new(
    0.5,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)

UI.loc.oc.MouseButton1Click:Connect(function()

    -- Tween ย่อ oc
    local shrinkTween = UI.s.TweenService:Create(UI.loc.oc, UI.loc.shrinkInfo, {
        Size = UDim2.new(0,0,0,0)
    })
    shrinkTween:Play()

    -- ซ่อนหลังย่อเสร็จ
    shrinkTween.Completed:Connect(function()
        UI.loc.oc.Visible = false
    end)

    -- เด้ง Inside
    UI.s.TweenService:Create(inside, UI.loc.bounceInfo, {
        Position = UDim2.new(0.15,0,0.8,0)
    }):Play()

    -- ทำให้พื้นหลังมืดลง
    UI.s.TweenService:Create(UI.loc.Bg, UI.loc.bgInfo, {
        BackgroundTransparency = 0.3
    }):Play()

    -- เลื่อน Bghr ขึ้นมา
    UI.s.TweenService:Create(UI.loc.Bghr, UI.loc.bgInfo, {
        Position = UDim2.new(0,0,0.02,0)
    }):Play()

end)

------------------------------------------------------------
UI.loc.ActiveColor = Color3.fromRGB(140, 0, 255)
UI.loc.InactiveColor = Color3.fromRGB(0, 0, 0)

UI.loc.Buttons = {}

UI.loc.btnTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
UI.loc.frameTween = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
UI.loc.insideTween = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

UI.loc.activateTab = function(name)
    for btnName, btn in pairs(UI.loc.Buttons) do
        
        local frame = UI.loc.Frame[btnName]
        if not frame then
            --[[ Frame not found ]]
            continue
        end

        local inside = frame:FindFirstChild("Inside")

        if btnName == name then
            -- ปุ่มที่ถูกกด
            UI.s.TweenService:Create(btn, UI.loc.btnTween, {
                BackgroundColor3 = UI.loc.ActiveColor
            }):Play()

            UI.s.TweenService:Create(
                btn.UIAspectRatioConstraint,
                UI.loc.btnTween,
                {AspectRatio = 2}
            ):Play()

            UI.s.TweenService:Create(frame, UI.loc.frameTween, {
                Position = UDim2.new(0.1,0,0.1,0)
            }):Play()

            if inside then
                UI.s.TweenService:Create(inside, UI.loc.insideTween, {
                    Position = UDim2.new(0.025,0,0.15,0)
                }):Play()
            end
        else
            -- ปุ่มอื่น
            UI.s.TweenService:Create(btn, UI.loc.btnTween, {
                BackgroundColor3 = UI.loc.InactiveColor
            }):Play()

            UI.s.TweenService:Create(
                btn.UIAspectRatioConstraint,
                UI.loc.btnTween,
                {AspectRatio = 1}
            ):Play()

            UI.s.TweenService:Create(frame, UI.loc.frameTween, {
                Position = UDim2.new(0.1,0,-1,0)
            }):Play()

            if inside then
                UI.s.TweenService:Create(inside, UI.loc.insideTween, {
                    Position = UDim2.new(0.025,0,2,0)
                }):Play()
            end
        end
    end
end


UI.loc.Btn = function(name, imageID, workin, callback, state)
  local imabtn = Instance.new("ImageButton")
  imabtn.Name = tostring(name)
  imabtn.Size = UDim2.new(0,0,1,0)
  imabtn.ScaleType = Enum.ScaleType.Fit

  local aspectConstraint = Instance.new("UIAspectRatioConstraint")
  aspectConstraint.AspectRatio = 1
  aspectConstraint.AspectType = Enum.AspectType.ScaleWithParentSize
  aspectConstraint.DominantAxis = Enum.DominantAxis.Height
  aspectConstraint.Parent = imabtn

  imabtn.BackgroundColor3 = UI.loc.InactiveColor
  imabtn.Image = "rbxassetid://" .. tostring(imageID)
  imabtn.Parent = UI.loc.Bar

  UI.Corner(0.15, 0, imabtn)
  UI.Stroke(imabtn, UI.StrokeUI.ASMBorder, 255,255,255, UI.StrokeUI.LJMRound, 1,0)
  UI.Gradient(imabtn, 45,0,0,
    Color3.fromRGB(85,255,255),
    Color3.fromRGB(255,255,255)
  )

  -- เก็บปุ่ม
  UI.loc.Buttons[name] = imabtn

  if workin then
    task.spawn(function()
      workin(imabtn)
    end)
  end

  local toggled = false

  imabtn.MouseButton1Click:Connect(function()
    if state == "toggle" then
      toggled = not toggled
      if callback then
        callback(toggled, imabtn)
      end
    else
      -- เปิดแท็บตามชื่อปุ่ม
      UI.loc.activateTab(name)

      if callback then
        callback(imabtn)
      end
    end
  end)

  return imabtn
end
------------------------------------------------------------

UI.loc.Close = UI.loc.Btn(
    "Close",
    76063966669126,
    nil,
    function()

        UI.loc.oc.Visible = true

        -- Tween oc กลับขนาดปกติ
        UI.s.TweenService:Create(UI.loc.oc,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0.04,0,0.08,0)}
        ):Play()

        -- Tween Inside ลงล่าง
        UI.s.TweenService:Create(Inside,
            TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(0.15,0,1.2,0)}
        ):Play()

        -- ทำให้พื้นหลังโปร่งใสกลับปกติ
        UI.s.TweenService:Create(UI.loc.Bg,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 1}
        ):Play()

        -- เลื่อน Bghr ลง
        UI.s.TweenService:Create(UI.loc.Bghr,
            TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(0,0,-1,0)}
        ):Play()
    end
)

UI.loc.Close.BackgroundColor3 = Color3.fromRGB(170,0,0)


home = UI.loc.Btn("Home", 70503788933260)
edit = UI.loc.Btn("Edit", 89040201197978)
autoexe = UI.loc.Btn("AutoExe", 138873910046129)
console = UI.loc.Btn("Console", 76584386272665)
expinfo = UI.loc.Btn("ExpInfo", 98945717252202)
folder = UI.loc.Btn("Folder", 86157935898545)
bookmark = UI.loc.Btn("Bookmark", 71272710123832)
search = UI.loc.Btn("Search", 133955276215666)
music = UI.loc.Btn("Music", 120343700432506)
settings = UI.loc.Btn("Settings", 139502039855639)

-- loadstring
local ok,err = pcall(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/White-rbx/HealthBar-Remake/refs/heads/Executor/ExperienceSettings%20Executor%202.lua"))()
end)

if ok then
	UI.loc.noti(3,"<b>Welcome!</b> Successful loaded!",UI.loc.color.green)
else
	UI.loc.noti(5,"Script error: "..tostring(err),UI.loc.color.red)
end



UI.loc.noti(5, "<b>Verison: </b>" .. Version, UI.loc.color.nor)
