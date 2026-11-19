-- ArcScriptCenter / LoaderMainPreview.lua
-- STAGING REVIEW: an isolated LOCAL visual QA fixture, not a real Loader.
-- No HttpGet, ban mutation, server calls, or changes to existing game UI.
-- Running this only adds one disposable ScreenGui to LocalPlayer.PlayerGui.

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
if not player then return end
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end
local NAME = "ArcScriptCenter_LoaderMainPreview_QA"
local previous = playerGui:FindFirstChild(NAME)
if previous then previous:Destroy() end

local colors = {
    bg = Color3.fromRGB(20,22,29),
    card = Color3.fromRGB(38,42,52),
    ink = Color3.fromRGB(245,245,248),
    blue = Color3.fromRGB(48,96,190),
    green = Color3.fromRGB(30,121,74),
    disabled = Color3.fromRGB(89,89,89)
}
local function make(class, properties, parent)
    local o = Instance.new(class)
    for k,v in pairs(properties) do o[k] = v end
    o.Parent = parent
    return o
end
local function round(o)
    make("UICorner", {CornerRadius=UDim.new(0,8)}, o)
    return o
end
local function text(parent, name, value, y, h, size)
    return make("TextLabel", {
        Name=name, Position=UDim2.new(0,10,0,y), Size=UDim2.new(1,-20,0,h),
        BackgroundTransparency=1, Text=value, TextWrapped=true,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextColor3=colors.ink, TextSize=size or 12, Font=Enum.Font.Gotham
    }, parent)
end
local function button(parent, name, value, x, y, w, h)
    return round(make("TextButton", {
        Name=name, Position=UDim2.new(x,0,0,y), Size=UDim2.new(w,0,0,h),
        BackgroundColor3=colors.card, BorderSizePixel=0, Text=value,
        TextWrapped=true, TextSize=12, TextColor3=colors.ink,
        Font=Enum.Font.GothamBold
    },parent))
end
local gui = make("ScreenGui", {
    Name=NAME, ResetOnSpawn=false, DisplayOrder=90
}, playerGui)
local root = round(make("Frame", {
    Name="Preview", AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromScale(0.95,0.88),
    BackgroundColor3=colors.bg, BorderSizePixel=0
}, gui))
make("UISizeConstraint", {MinSize=Vector2.new(280,350),
    MaxSize=Vector2.new(520,730)}, root)
text(root,"Title","Loader Main — STAGING Preview",9,25,16)
text(root,"Safety","LOCAL SYNTHETIC FIXTURE • NOT A REAL BAN",38,18,10)
local close=button(root,"ClosePreview","X",0.91,9,0.07,29)
local inGame=button(root,"BanIngame","Ban in-game",0.03,66,0.46,36)
local restricted=button(root,"RestrictedMode","Restricted Mode",0.51,66,0.46,36)
local temporary=button(root,"Temporary","Temporary",0.03,108,0.46,36)
local permanent=button(root,"Permanent","Permanent",0.51,108,0.46,36)
local headline=text(root,"Scenario","",153,54,12)
headline.BackgroundTransparency=0
headline.BackgroundColor3=colors.card
round(headline)

local viewport=make("ScrollingFrame",{
    Name="QAViewport",Position=UDim2.new(0.03,0,0,215),
    Size=UDim2.new(0.94,0,1,-270),ScrollBarThickness=3,
    BorderSizePixel=0,BackgroundTransparency=1,
    CanvasSize=UDim2.fromOffset(0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y
},root)
make("UIListLayout", {
    Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder
},viewport)

local setup=round(make("Frame",{
    Name="SetUpFixture",LayoutOrder=1,Size=UDim2.new(1,-4,0,90),
    BackgroundColor3=colors.card, BorderSizePixel=0
},viewport))
text(setup,"SetUpTitle","ExperienceSettings SetUp (fixture)",7,21,14)
local setupState=text(setup,"SetUpState","",29,54,12)
local main=round(make("Frame",{
    Name="MainFixture",LayoutOrder=2,Size=UDim2.new(1,-4,0,332),
    BackgroundColor3=colors.card, BorderSizePixel=0
},viewport))
text(main,"MainTitle","Loader Main / Arcsen (fixture)",6,23,14)
local topbar=make("Frame",{
    Name="TopBar",Position=UDim2.new(0,8,0,34),
    Size=UDim2.new(1,-16,0,86),BackgroundTransparency=1
},main)
local holder=make("Frame",{
    Name="Holder",Size=UDim2.fromScale(1,1),BackgroundTransparency=1
},topbar)
local buttons={
    button(holder,"a1_Open/Close","Open/Close",0,0,0.32,34),
    button(holder,"z7_About","About",0.34,0,0.32,34),
    button(holder,"z8_ChatGPT","Arcsen",0.68,0,0.32,34),
    button(holder,"MockEditor","Editor (fixture)",0,42,0.32,34),
    button(holder,"MockSearch","Search (fixture)",0.34,42,0.32,34),
    button(holder,"MockTools","Tools (fixture)",0.68,42,0.32,34)
}
local keep={
    ["a1_Open/Close"]=true,["z7_About"]=true,
    ["z8_ChatGPT"]=true,["z8_Arcsen"]=true
}
local settings=text(main,"Settings","",130,66,12)
settings.BackgroundTransparency=0
settings.BackgroundColor3=colors.bg
round(settings)
local toggle=button(main,"ToggleSyntheticVerifiedViolation",
    "Synthetic verified violation: OFF",0.02,205,0.96,35)
local violation=text(main,"ViolationFixture",
    "Violation → Appeal (SYNTHETIC fixture only)\nNever creates a real account case.",
    250,68,12)
violation.BackgroundTransparency=0
violation.BackgroundColor3=colors.green
round(violation)

local audit=round(make("Frame",{
    Name="RealLocalReadOnlyAudit",LayoutOrder=3,
    Size=UDim2.new(1,-4,0,83),
    BackgroundColor3=colors.card, BorderSizePixel=0
},viewport))
local auditText=text(audit,"Report",
    "Local GUI audit not run. Nothing outside this fixture is changed.",
    5,72,12)
local inspect=button(root,"InspectLocalUI","Inspect actual local GUI (read-only)",
    0.03,0,0.94,35)
inspect.Position=UDim2.new(0.03,0,1,-45)
inspect.BackgroundColor3=colors.blue

local selection="restricted_mode"
local duration="temporary"
local syntheticVerified=false
local showSettings=false
local showAbout=false
local expanded=true

local function selected(b,on)
    b.BackgroundColor3=on and colors.blue or colors.card
end
local function render()
    selected(inGame,selection=="ban_ingame")
    selected(restricted,selection=="restricted_mode")
    selected(temporary,duration=="temporary")
    selected(permanent,duration=="permanent")
    local isRestricted=selection=="restricted_mode"
    headline.Text=(isRestricted and "Restricted Mode" or "Ban in-game")
        .." • "..(duration=="temporary" and "Temporary" or "Permanent")
        .."\nAll 4 combinations are independent. No data is saved."
    setupState.Text=isRestricted
        and "SetUp completes, then Loader Main starts.\nOnly approved UI functions remain."
        or "SetUp-only. Loader Main must not run.\nNo Arcsen, Editor or Search."
    main.Visible=isRestricted
    for _,b in ipairs(buttons) do
        local allowed=keep[b.Name]==true
        b.Interactable=allowed
        b.Active=allowed
        b.AutoButtonColor=allowed
        b.BackgroundColor3=allowed and colors.blue or colors.disabled
    end
    holder.Visible=expanded
    toggle.Visible=expanded
    settings.Visible=expanded
    violation.Visible=expanded and syntheticVerified
    toggle.Text="Synthetic verified violation: "
        ..(syntheticVerified and "ON" or "OFF")
    if showSettings then
        settings.Text="Arcsen → Settings → ArcScriptCenter\nFeedback & Appeal: Rules, Feedback; Violation only when verified."
    elseif showAbout then
        settings.Text="About (synthetic). This preview does not authorize bans."
    else
        settings.Text="Chat / Tabs / New Chat / Send / API: BLOCKED in fixture.\nTap Arcsen to show mocked Settings."
    end
end
inGame.MouseButton1Click:Connect(function()
    selection="ban_ingame" render()
end)
restricted.MouseButton1Click:Connect(function()
    selection="restricted_mode" render()
end)
temporary.MouseButton1Click:Connect(function()
    duration="temporary" render()
end)
permanent.MouseButton1Click:Connect(function()
    duration="permanent" render()
end)
buttons[1].MouseButton1Click:Connect(function()
    expanded=not expanded render()
end)
buttons[2].MouseButton1Click:Connect(function()
    showAbout=not showAbout showSettings=false render()
end)
buttons[3].MouseButton1Click:Connect(function()
    showSettings=not showSettings showAbout=false render()
end)
toggle.MouseButton1Click:Connect(function()
    syntheticVerified=not syntheticVerified render()
end)
inspect.MouseButton1Click:Connect(function()
    local ok,result=pcall(function()
        local rootLive=CoreGui:FindFirstChild("ExperienceSettings")
        local menu=rootLive and rootLive:FindFirstChild("Menu")
        local top=menu and menu:FindFirstChild("TopBar")
        local liveHolder=top and top:FindFirstChild("Holder")
        local allowedCount, inactiveCount=0,0
        if liveHolder then
            for _,b in ipairs(liveHolder:GetDescendants()) do
                if b:IsA("GuiButton") then
                    if keep[b.Name] then allowedCount+=1
                    elseif b.Interactable==false then inactiveCount+=1 end
                end
            end
        end
        local env=type(getgenv)=="function" and getgenv() or {}
        return "Real Holder: "..(liveHolder and "FOUND" or "NOT FOUND")
            .." | Visible: "..tostring(rootLive and rootLive.Enabled)
            .."\nClient Restricted flag: "..tostring(env.__ES_RESTRICTED_MODE==true)
            .."\nAllowed buttons found: "..allowedCount
            .." | Other inactive buttons: "..inactiveCount
            .."\nObservation only: NOT server enforcement evidence."
    end)
    auditText.Text=ok and result or ("Audit unavailable: "..tostring(result))
end)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
render()
print("[ArcScriptCenter] LoaderMainPreview local synthetic fixture ready.")
