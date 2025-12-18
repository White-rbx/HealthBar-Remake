-- Script ahh 1.267

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

-- <<===== Position of Services =====>>
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- <<===== Position =====>>
local Menu = game.CoreGui:WaitForChild("TopBarApp")
                 :WaitForChild("TopBarApp")
                 :WaitForChild("UnibarLeftFrame")
                 :WaitForChild("HealthBar")
                 :WaitForChild("ExperienceSettings")
                 :WaitForChild("Menu")

-- =====>> Instance <<=====
local pro = Instance.new("Frame")
pro.Name = "ProfileStatus"
pro.Position = UDim2.new(0.25,0,1,0)
pro.Size = UDim2.new(0.5,0,0.7,0)
pro.BackgroundColor3 = Color3.fromRGB(0,0,0)
pro.BackgroundTransparency = 0.3
pro.Parent = Menu
Corner(0,8,pro)
Stroke(pro, ASMBorder, 255,255,255, LSMRound, 1, 0)
ListLayout(pro, 0, 0, HCenter, VCenter, SName, FillV)

-- [ pro.prin ]
local prin = Instance.new("Frame")
prin.Name = "InsideProfileStatus"
prin.Size = UDim2.new(0.98,0,0.96,0)
prin.BackgroundTransparency = 1
prin.Parent = pro

-- [ pro.prin(Inside) ]
local pchar = Instance.new("Frame")
pchar.Name = "ProfileCharacter"
pchar.Size = UDim2.new(0.5,0,1,0)
pchar.BackgroundTransparency = 1
pchar.Parent = prin

local dg = Instance.new("Frame")
dg.Name = "Debugs"
dg.Position = UDim2.new(0.5,0,0,0)
dg.Size = UDim2.new(0.5,0,1,0)
dg.BackgroundTransparency = 1
dg.Parent = prin

-- [ pro.pchar.pfhr ]
local pfhr = Instance.new("Frame")
pfhr.Name = "Holder"
pfhr.Size = UDim2.new(1,0,0.2,0)
pfhr.BackgroundTransparency = 1
pfhr.Parent = pchar

-- [ pro.pchar.pfhr.pf ]
local pf = Instance.new("ImageLabel")
pf.Name = "Profile"
pf.Size = UDim2.new(0,80,0,80)
pf.BackgroundTransparency = 0.8
pf.Image = "rbxassetid://"
pf.Parent = pfhr
Corner(0,8,pf)

-- [ pro.char.pfhr.user ]
local user = Instance.new("TextLabel")
user.Name = "Username"
user.Size = UDim2.new(0.8,0,0.3,0)
user.Position = UDim2.new(0,82,0,0)
user.BackgroundTransparency = 1
user.TextScaled = true
user.Text = "Getting API..."
user.TextXAlignment = Enum.TextXAlignment.Left
user.TextColor3 = Color3.fromRGB(255,255,255)
user.Parent = pfhr

-- [ pro.pchar.scr ]
local scr = Instance.new("ScrollingFrame")
scr.Name = "Scroll"
scr.Size = UDim2.new(1,0,0.79,0)
scr.Position = UDim2.new(0,0,0.21,0)
scr.CanvasSize = UDim2.new(0,0,5000,0)
scr.ScrollingDirection = Enum.ScrollingDirection.Y
scr.ScrollBarThickness = 0
scr.BackgroundTransparency = 1
scr.Parent = pchar
ListLayout(scr, 0, 5, HCenter, VTop, SLayout, FillV)

-- [ function Text ]
local TextExtraFunction = {}

local function Text(parent, Name, TextContent, Active, R, G, B, R1, G1, B1, Workin, Function)
    local txt = Instance.new("TextLabel")
    txt.Name = tostring(Name)
    txt.Text = tostring(TextContent)
    txt.Active = (Active ~= false)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(R or 255, G or 255, B or 255)
    txt.TextScaled = true
    txt.Size = UDim2.new(0.99, 0, 0, 30)
    txt.Parent = parent

    Corner(0, 8, txt)
    Stroke(txt, ASMBorder, R1 or 255, G1 or 255, B1 or 255, LJMRound, 1, 0)

    -- Workin loop (สคริปต์หลัก)
    if typeof(Workin) == "function" then
        task.spawn(function()
            while txt.Parent do
                Workin(txt)
                task.wait(0.05)
            end
        end)
    end

    -- Function เสริม (เก็บแยก)
    if typeof(Function) == "function" then
        TextExtraFunction[txt] = Function
    end

    return txt
end
			
-- [ pro.pchar.scr.woof ]
local wf = Instance.new("Frame")
wf.Name = "There's nothing woof!"
wf.Size = UDim2.new(1,0,0,0)
wf.BackgroundTransparency = 1
wf.Parent = scr

-- [ function Button ]
local function Button(parent, Name, TextContent, Active, R, G, B, R1, G1, B1, Workin, Callback, Function)
    local btn = Instance.new("TextButton")
    btn.Name = tostring(Name)
    btn.Text = tostring(TextContent)
    btn.Active = (Active ~= false)
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.fromRGB(R or 255, G or 255, B or 255)
    btn.TextScaled = true
    btn.Size = UDim2.new(0.99, 0, 0, 30)
    btn.Parent = parent

    Corner(0, 8, btn)
    Stroke(btn, ASMBorder, R1 or 255, G1 or 255, B1 or 255, LJMRound, 1, 0)

    -- Callback (ไม่มี debug)
    if typeof(Callback) == "function" then
        btn.MouseButton1Click:Connect(function()
            Callback(btn)
        end)
    end

    -- Workin loop (ไม่มี debug)
    if typeof(Workin) == "function" then
        task.spawn(function()
            while btn.Parent do
                Workin(btn)
                task.wait(0.05)
            end
        end)
    end

    -- Manual function
    if typeof(Function) == "function" then
        btn.Function = function(...)
            return Function(btn, ...)
        end
    end

    return btn
end

-- Load Avatar
task.spawn(function()
    local lp = Players.LocalPlayer
    local uid = lp.UserId
    pf.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. uid .. "&width=150&height=150&format=Png"
end)
-- Load Username

task.spawn(function()
    local lp = Players.LocalPlayer
    local display = lp.DisplayName or lp.Name
    local real = lp.Name or ""
    user.Text = tostring(display) .. " (@" .. tostring(real) .. ")"
end)


Text(scr, "Beta", "It might have bug and it still in beta.", false, 255, 131, 131, 255, 0, 0)
--===================--
local UserInputService = game:GetService("UserInputService")

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local humanoid
local character

local function bindCharacter(char)
	character = char
	humanoid = char:WaitForChild("Humanoid", 10)
end

if lp.Character then
	bindCharacter(lp.Character)
end
lp.CharacterAdded:Connect(bindCharacter)
						
------------------------------------------------
-- PlayerID
------------------------------------------------

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

Button(
	scr,
	"PlayerID",
	"PlayerID: Getting API...",
	true,
	255,255,255,        -- Text color
	180,180,255,        -- Stroke color
	function(btn)       -- Workin
		if lp and lp.UserId then
			btn.Text = "PlayerID: " .. tostring(lp.UserId)
		end
	end,
	function(btn)       -- Callback (คลิก)
		local id = tostring(lp.UserId)

		-- Copy (รองรับหลาย executor)
		if setclipboard then
			setclipboard(id)
		elseif toclipboard then
			toclipboard(id)
		elseif syn and syn.set_clipboard then
			syn.set_clipboard(id)
		end

		-- Feedback
		local stroke = btn:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Color = Color3.fromRGB(0,255,150)
			task.delay(0.4, function()
				if stroke then
					stroke.Color = Color3.fromRGB(180,180,255)
				end
			end)
		end
	end
)

Button(
	scr,
	"PlayerAge",
	"PlayerAge: Getting API...",
	true,                 -- Active
	255,255,255,          -- Text color
	200,200,255,          -- Stroke color
	function(btn)         -- Workin
		if lp then
			btn.Text = "PlayerAge: " .. tostring(lp.AccountAge) .. " day"
		end
	end,
	function(btn)         -- Callback (Copy)
		local age = tostring(lp.AccountAge)

		if setclipboard then
			setclipboard(age)
		elseif toclipboard then
			toclipboard(age)
		elseif syn and syn.set_clipboard then
			syn.set_clipboard(age)
		end
	end
)

Button(
	scr,
	"PlayerBirth",
	"PlayerBirth: Calculating...",
	true,
	255,255,255,
	200,255,200,
	function(btn) -- Workin
		if not lp then return end

		local ageDays = lp.AccountAge
		local now = os.time()
		local birth = now - (ageDays * 86400)

		local d = os.date("*t", birth)
		local text = string.format(
			"PlayerBirth: %02d/%02d/%04d",
			d.day, d.month, d.year
		)

		btn.Text = text
	end,
	function(btn) -- Copy
		local ageDays = lp.AccountAge
		local birth = os.time() - (ageDays * 86400)
		local d = os.date("*t", birth)

		local copyText = string.format(
			"%02d/%02d/%04d",
			d.day, d.month, d.year
		)

		if setclipboard then
			setclipboard(copyText)
		elseif toclipboard then
			toclipboard(copyText)
		elseif syn and syn.set_clipboard then
			syn.set_clipboard(copyText)
		end
	end
)
------------------------------------------------
-- CameraMode
------------------------------------------------
local camText = Text(
	scr,
	"CameraMode",
	"CameraMode: ...",
	false,
	255,255,255,
	255,255,255
)

local function updateCam()
	camText.Text = "CameraMode: " .. tostring(lp.CameraMode)
end

updateCam()
lp:GetPropertyChangedSignal("CameraMode"):Connect(updateCam)						
------------------------------------------------
-- PlaceID
------------------------------------------------
Button(
	scr,
	"PlaceID",
	"PlaceID: Getting...",
	true,
	255,255,255,
	180,180,255,
	function(btn)
		btn.Text = "PlaceID: " .. tostring(game.PlaceId)
	end,
	function(btn)
		local id = tostring(game.PlaceId)
		if setclipboard then setclipboard(id)
		elseif toclipboard then toclipboard(id)
		elseif syn and syn.set_clipboard then syn.set_clipboard(id) end
	end
)

------------------------------------------------
-- CreatorName
------------------------------------------------
Button(
	scr,
	"CreatorName",
	"Creator: Getting...",
	true,
	255,255,255,
	255,220,150,
	function(btn)
		local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
		local name = info.Creator.Name
		btn.Text = "Creator: " .. name .. " (@" .. name .. ")"
	end,
	function(btn)
		local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
		if setclipboard then setclipboard(info.Creator.Name) end
	end
)

------------------------------------------------
-- CreatorID
------------------------------------------------
Button(
	scr,
	"CreatorID",
	"CreatorID: Getting...",
	true,
	255,255,255,
	255,200,200,
	function(btn)
		local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
		btn.Text = "CreatorID: " .. tostring(info.Creator.CreatorTargetId)
	end,
	function(btn)
		local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
		if setclipboard then
			setclipboard(tostring(info.Creator.CreatorTargetId))
		end
	end
)

-- ======= Live stats + AFK + Damage/Heal/Deaths (HRP-safe) =======
local DEBUG = false -- set true to print debug lines

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer

-- storage
local Current = {
    Character = nil,
    Humanoid = nil,
    HRP = nil,
    Conn = {}, -- store connections to clean on respawn
}

-- combat / health trackers (persist across spawns)
local Stats = {
    TotalDamage = 0,
    LastDamage = 0,
    TotalHeal = 0,
    LastHeal = 0,
    Deaths = 0,
    LastHealth = nil,
}

-- AFK tracker
local AFK = {
    LastActivity = tick()
}
local function MarkActivity()
    AFK.LastActivity = tick()
    if DEBUG then print("[AFK] marked") end
end

-- input hooks for AFK
UserInputService.InputBegan:Connect(function(_, gpe) if not gpe then MarkActivity() end end)
UserInputService.InputChanged:Connect(function() MarkActivity() end)
UserInputService.InputEnded:Connect(function() MarkActivity() end)

-- movement marks AFK too (we'll detect via HRP monitoring below)

-- Utility: safely disconnect conns
local function ClearConns()
    for _, c in pairs(Current.Conn) do
        if c and c.Disconnect then
            pcall(function() c:Disconnect() end)
        elseif c and typeof(c) == "RBXScriptConnection" then
            pcall(function() c:Disconnect() end)
        end
    end
    Current.Conn = {}
end

-- Bind to humanoid when found
local function BindToHumanoid(hum)
    if not hum then return end
    ClearConns()
    Current.Humanoid = hum
    Stats.LastHealth = hum.Health

    -- HealthChanged -> detect damage/heal
    local hc = hum.HealthChanged:Connect(function(hp)
        if Stats.LastHealth == nil then
            Stats.LastHealth = hp
            return
        end

        if hp < Stats.LastHealth then
            local dmg = math.floor((Stats.LastHealth - hp) + 0.5)
            Stats.LastDamage = dmg
            Stats.TotalDamage = Stats.TotalDamage + dmg
            if DEBUG then print("[Dmg] got", dmg, "total", Stats.TotalDamage) end
        elseif hp > Stats.LastHealth then
            local heal = math.floor((hp - Stats.LastHealth) + 0.5)
            Stats.LastHeal = heal
            Stats.TotalHeal = Stats.TotalHeal + heal
            if DEBUG then print("[Heal] got", heal, "total", Stats.TotalHeal) end
        end

        Stats.LastHealth = hp
    end)
    table.insert(Current.Conn, hc)

    -- Died -> increment deaths and reset lasthealth to nil (humanoid will be replaced soon)
    local dc = hum.Died:Connect(function()
        Stats.Deaths = Stats.Deaths + 1
        if DEBUG then print("[Death] total", Stats.Deaths) end
        -- ensure lastHealth cleared so next humanoid bind will initialize
        Stats.LastHealth = nil
    end)
    table.insert(Current.Conn, dc)

    -- monitor HRP movement to mark AFK as activity
    -- (we'll attach movement monitor in the character binder)
end

-- Character binder (detect HRP + Humanoid, re-bind reliably)
local function BindCharacter(char)
    if not char then return end
    Current.Character = char

    -- try to wait a bit for parts
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso")
    local hum = char:FindFirstChildOfClass("Humanoid")

    -- if not found yet, wait a short while (handles slow spawns on mobile)
    if not hrp or not hum then
        -- try a few times quickly
        for i=1,10 do
            if not hrp then hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso") end
            if not hum then hum = char:FindFirstChildOfClass("Humanoid") end
            if hrp and hum then break end
            task.wait(0.08)
        end
    end

    -- if still missing, we'll keep trying in the main monitor loop
    if hum then
        BindToHumanoid(hum)
    end

    -- movement monitor: spawn a loop that checks HRP pos and marks activity
    if hrp then
        local lastPos = hrp.Position
        local mvConn
        mvConn = RunService.Heartbeat:Connect(function()
            if not char.Parent then
                if mvConn then
                    pcall(function() mvConn:Disconnect() end)
                end
                return
            end
            if hrp and hrp.Parent then
                local pos = hrp.Position
                if (pos - lastPos).Magnitude > 0.5 then
                    MarkActivity()
                end
                lastPos = pos
            end
        end)
        table.insert(Current.Conn, mvConn)
    end
end

-- monitor CharacterAdded + initial character
if lp then
    if lp.Character then
        BindCharacter(lp.Character)
    end
    lp.CharacterAdded:Connect(function(char)
        -- small delay to allow parts to exist
        task.wait(0.06)
        BindCharacter(char)
    end)
end

-- Main watcher: look for HRP/humanoid changes (covers cases where they spawn slowly)
task.spawn(function()
    while true do
        local char = lp and lp.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            -- if hum exists but not yet bound or changed, bind
            if hum and hum ~= Current.Humanoid then
                if DEBUG then print("[Binder] new humanoid found") end
                BindCharacter(char)
                -- ensure BindToHumanoid called inside BindCharacter when appropriate
                if Current.Humanoid ~= hum then
                    -- double-check and bind directly if missed
                    BindToHumanoid(hum)
                end
            end
        end
        task.wait(0.2)
    end
end)

-- ========== UI TEXTS ========== --
-- AFK: MM:SS
local afkText = Text(
    scr,
    "AFKTime",
    "AFK: 00:00",
    false,              -- Active = false
    255,255,255,        -- text color
    255,255,255,        -- stroke
    nil, nil, nil,      -- (R1,G1,B1 omitted)
    function(txt)
        local s = math.floor(tick() - AFK.LastActivity)
        local mm = math.floor(s / 60)
        local ss = s % 60
        txt.Text = string.format("AFK: %02d:%02d", mm, ss)
    end
)

-- WalkSpeed
local walkText = Text(
    scr,
    "WalkSpeed",
    "Walkspeed: --",
    false,
    120,150,255,        -- blue-ish
    120,150,255,
    nil, nil, nil,
    function(txt)
        local hum = Current.Humanoid
        if hum then
            txt.Text = "Walkspeed: " .. tostring(math.floor(hum.WalkSpeed * 100)/100)
        else
            txt.Text = "Walkspeed: --"
        end
    end
)

-- JumpPower / JumpHeight (choose correct property)
local jumpText = Text(
    scr,
    "JumpPower",
    "Jumppower: --",
    false,
    255,120,120,
    255,120,120,
    nil, nil, nil,
    function(txt)
        local hum = Current.Humanoid
        if hum then
            if hum.UseJumpPower then
                txt.Text = "Jumppower: " .. tostring(math.floor(hum.JumpPower * 100)/100)
            else
                txt.Text = "JumpHeight: " .. tostring(math.floor(hum.JumpHeight * 100)/100)
            end
        else
            txt.Text = "Jumppower: --"
        end
    end
)

-- Damage Text
local dmgText = Text(
    scr,
    "Damage",
    "BestDamage: 0 | LastDamage: 0",
    false,
    255,80,80,
    255,80,80,
    nil, nil, nil,
    function(txt)
        txt.Text = "BestDamage: "..tostring(Stats.TotalDamage).." | LastDamage: "..tostring(Stats.LastDamage)
    end
)

-- Heal Text
local healText = Text(
    scr,
    "Heal",
    "BestHeal: 0 | LastHeal: 0",
    false,
    80,255,120,
    80,255,120,
    nil, nil, nil,
    function(txt)
        txt.Text = "BestHeal: "..tostring(Stats.TotalHeal).." | LastHeal: "..tostring(Stats.LastHeal)
    end
)

-- Deaths
local deathsText = Text(
    scr,
    "Deaths",
    "Deaths: 0",
    false,
    255,80,80,
    255,80,80,
    nil, nil, nil,
    function(txt)
        txt.Text = "Deaths: "..tostring(Stats.Deaths)
    end
)

-- Optional debug ticker so you can see binding state (only when DEBUG=true)
if DEBUG then
    task.spawn(function()
        while true do
            local humOk = Current.Humanoid and true or false
            print("[DBG] Humanoid bound:", humOk, "LastHealth:", Stats.LastHealth, "Deaths:", Stats.Deaths)
            task.wait(1.0)
        end
    end)
end

-- final note: this script keeps totals (Damage/Heal/Deaths) across respawns.
-- If you want reset on respawn, clear Stats.* when Died occurs (remove persistence).
