-- Creating Folder
local folder1 = Instance.new("Folder")
folder1.Name = "ExperienceSettings"

-- Creating ScreenGui
local screengui2 = Instance.new("ScreenGui")
screengui2.DisplayOrder = 2147483645
screengui2.ResetOnSpawn = false
screengui2.Name = "Menu"
screengui2.Parent = folder1

-- Creating Frame
local frame3 = Instance.new("Frame")
frame3.BackgroundTransparency = 1
frame3.Position = UDim2.new(0.46000000834465027, 0, 0.019999999552965164, 0)
frame3.Size = UDim2.new(1, 0, 0, 43)
frame3.Name = "TopBar"
frame3.Parent = screengui2

-- Creating UIListLayout
local uilistlayout4 = Instance.new("UIListLayout")
uilistlayout4.Parent = frame3

-- Creating Frame
local frame5 = Instance.new("Frame")
frame5.BackgroundColor3 = Color3.new(0.07058823853731155, 0.07058823853731155, 0.08235294371843338)
frame5.BackgroundTransparency = 0.07999999821186066
frame5.Size = UDim2.new(0, 90, 1, 0)
frame5.ZIndex = 2147483646
frame5.Name = "Holder"
frame5.Parent = frame3

-- Creating UICorner
local uicorner6 = Instance.new("UICorner")
uicorner6.Parent = frame5

-- Creating UIListLayout
local uilistlayout7 = Instance.new("UIListLayout")
uilistlayout7.Parent = frame5

-- Creating ImageButton
local imagebutton8 = Instance.new("ImageButton")
imagebutton8.Image = "rbxassetid://130405026545116"
imagebutton8.AutoButtonColor = false
imagebutton8.BackgroundColor3 = Color3.new(1, 1, 1)
imagebutton8.BackgroundTransparency = 1
imagebutton8.Rotation = 180
imagebutton8.Size = UDim2.new(0, 34, 0.800000011920929, 0)
imagebutton8.Visible = false
imagebutton8.ZIndex = 2147483646
imagebutton8.Name = "a3_Settings"
imagebutton8.Parent = frame5

-- Creating UICorner
local uicorner9 = Instance.new("UICorner")
uicorner9.Parent = imagebutton8

-- Creating UIStroke
local uistroke10 = Instance.new("UIStroke")
uistroke10.Color = Color3.new(1, 1, 1)
uistroke10.Thickness = 0
uistroke10.ZIndex = 2147483646
uistroke10.Parent = imagebutton8

-- Creating ImageButton
local imagebutton11 = Instance.new("ImageButton")
imagebutton11.Image = "rbxassetid://90812069520281"
imagebutton11.AutoButtonColor = false
imagebutton11.BackgroundColor3 = Color3.new(1, 1, 1)
imagebutton11.BackgroundTransparency = 1
imagebutton11.Size = UDim2.new(0, 34, 0.800000011920929, 0)
imagebutton11.Visible = false
imagebutton11.ZIndex = 2147483646
imagebutton11.Name = "z9_HamburgerMenu"
imagebutton11.Parent = frame5

-- Creating UICorner
local uicorner12 = Instance.new("UICorner")
uicorner12.Parent = imagebutton11

-- Creating UIStroke
local uistroke13 = Instance.new("UIStroke")
uistroke13.Color = Color3.new(1, 1, 1)
uistroke13.Thickness = 0
uistroke13.ZIndex = 2147483646
uistroke13.Parent = imagebutton11

-- Creating ImageButton
local imagebutton14 = Instance.new("ImageButton")
imagebutton14.Image = "rbxassetid://133900380566355"
imagebutton14.AutoButtonColor = false
imagebutton14.BackgroundColor3 = Color3.new(1, 1, 1)
imagebutton14.BackgroundTransparency = 1
imagebutton14.Size = UDim2.new(0, 34, 0.800000011920929, 0)
imagebutton14.ZIndex = 2147483646
imagebutton14.Name = "a1_Open/Close"
imagebutton14.Parent = frame5

-- Creating UICorner
local uicorner15 = Instance.new("UICorner")
uicorner15.Parent = imagebutton14

-- Creating UIStroke
local uistroke16 = Instance.new("UIStroke")
uistroke16.Color = Color3.new(1, 1, 1)
uistroke16.Thickness = 0
uistroke16.ZIndex = 2147483646
uistroke16.Parent = imagebutton14

-- Creating ImageButton
local imagebutton17 = Instance.new("ImageButton")
imagebutton17.Image = "rbxassetid://108080487163852"
imagebutton17.AutoButtonColor = false
imagebutton17.BackgroundColor3 = Color3.new(1, 1, 1)
imagebutton17.BackgroundTransparency = 1
imagebutton17.Size = UDim2.new(0, 34, 0.800000011920929, 0)
imagebutton17.Visible = false
imagebutton17.ZIndex = 2147483646
imagebutton17.Name = "z8_ChatGPT"
imagebutton17.Parent = frame5

-- Creating UICorner
local uicorner18 = Instance.new("UICorner")
uicorner18.Parent = imagebutton17

-- Creating UIStroke
local uistroke19 = Instance.new("UIStroke")
uistroke19.Color = Color3.new(1, 1, 1)
uistroke19.Thickness = 0
uistroke19.ZIndex = 2147483646
uistroke19.Parent = imagebutton17

-- Creating TextLabel
local textlabel20 = Instance.new("TextLabel")
textlabel20.Text = "-"
textlabel20.TextColor3 = Color3.new(0, 0, 0)
textlabel20.TextScaled = true
textlabel20.TextWrapped = true
textlabel20.BackgroundColor3 = Color3.new(1, 1, 1)
textlabel20.Position = UDim2.new(0.5, 0, 0.6000000238418579, 0)
textlabel20.Size = UDim2.new(0, 20, 0, 20)
textlabel20.Visible = false
textlabel20.ZIndex = 2147483647
textlabel20.Name = "NewMessage"
textlabel20.Parent = imagebutton17

-- Creating UICorner
local uicorner21 = Instance.new("UICorner")
uicorner21.Parent = textlabel20

-- Creating ImageButton
local imagebutton22 = Instance.new("ImageButton")
imagebutton22.Image = "rbxassetid://115316941207686"
imagebutton22.AutoButtonColor = false
imagebutton22.BackgroundColor3 = Color3.new(1, 1, 1)
imagebutton22.BackgroundTransparency = 1
imagebutton22.Size = UDim2.new(0, 34, 0.800000011920929, 0)
imagebutton22.Visible = false
imagebutton22.ZIndex = 2147483646
imagebutton22.Name = "a4_Search"
imagebutton22.Parent = frame5

-- Creating UICorner
local uicorner23 = Instance.new("UICorner")
uicorner23.Parent = imagebutton22

-- Creating UIStroke
local uistroke24 = Instance.new("UIStroke")
uistroke24.Color = Color3.new(1, 1, 1)
uistroke24.Thickness = 0
uistroke24.ZIndex = 2147483646
uistroke24.Parent = imagebutton22

-- Creating Frame
local frame25 = Instance.new("Frame")
frame25.BackgroundTransparency = 1
frame25.Size = UDim2.new(0.5, 0, 1, 0)
frame25.Visible = false
frame25.ZIndex = 2147483646
frame25.Name = "LoadFrame"
frame25.Parent = frame5

-- Creating TextLabel
local textlabel26 = Instance.new("TextLabel")
textlabel26.Text = "The ExperienceSettings has been deactivated for some reason."
textlabel26.TextColor3 = Color3.new(1, 1, 1)
textlabel26.TextScaled = true
textlabel26.TextWrapped = true
textlabel26.BackgroundTransparency = 1
textlabel26.Size = UDim2.new(1, 0, 1, 0)
textlabel26.Visible = false
textlabel26.ZIndex = 2147483646
textlabel26.Name = "Warning & Load"
textlabel26.Parent = frame25

-- Creating ImageButton
local imagebutton27 = Instance.new("ImageButton")
imagebutton27.Image = "rbxassetid://97370032987773"
imagebutton27.AutoButtonColor = false
imagebutton27.BackgroundColor3 = Color3.new(1, 1, 1)
imagebutton27.BackgroundTransparency = 1
imagebutton27.Size = UDim2.new(0, 34, 0.800000011920929, 0)
imagebutton27.ZIndex = 2147483646
imagebutton27.Name = "z7_About"
imagebutton27.Parent = frame5

-- Creating UICorner
local uicorner28 = Instance.new("UICorner")
uicorner28.Parent = imagebutton27

-- Creating UIStroke
local uistroke29 = Instance.new("UIStroke")
uistroke29.Color = Color3.new(1, 1, 1)
uistroke29.Thickness = 0
uistroke29.ZIndex = 2147483646
uistroke29.Parent = imagebutton27

-- Creating ImageButton
local imagebutton30 = Instance.new("ImageButton")
imagebutton30.Image = "rbxassetid://107706370299068"
imagebutton30.AutoButtonColor = false
imagebutton30.BackgroundColor3 = Color3.new(1, 1, 1)
imagebutton30.BackgroundTransparency = 1
imagebutton30.Size = UDim2.new(0, 34, 0.800000011920929, 0)
imagebutton30.Visible = false
imagebutton30.ZIndex = 2147483646
imagebutton30.Name = "a2_Status"
imagebutton30.Parent = frame5

-- Creating UICorner
local uicorner31 = Instance.new("UICorner")
uicorner31.Parent = imagebutton30

-- Creating UIStroke
local uistroke32 = Instance.new("UIStroke")
uistroke32.Color = Color3.new(1, 1, 1)
uistroke32.Thickness = 0
uistroke32.ZIndex = 2147483646
uistroke32.Parent = imagebutton30

-- Creating ScrollingFrame
local scrollingframe33 = Instance.new("ScrollingFrame")
scrollingframe33.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingframe33.ScrollBarThickness = 4
scrollingframe33.BackgroundColor3 = Color3.new(0.07058823853731155, 0.07058823853731155, 0.08235294371843338)
scrollingframe33.BackgroundTransparency = 0.07999999821186066
scrollingframe33.Visible = false
scrollingframe33.Name = "TopButtons"
scrollingframe33.Parent = frame3

-- Creating UICorner
local uicorner34 = Instance.new("UICorner")
uicorner34.Parent = scrollingframe33

-- Creating UIGridLayout
local uigridlayout35 = Instance.new("UIGridLayout")
uigridlayout35.CellSize = UDim2.new(0, 70, 0, 70)
uigridlayout35.Parent = scrollingframe33

-- Creating ImageButton
local imagebutton36 = Instance.new("ImageButton")
imagebutton36.Image = "rbxassetid://139665085719816"
imagebutton36.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
imagebutton36.BackgroundTransparency = 0.20000000298023224
imagebutton36.Size = UDim2.new(0, 70, 0, 70)
imagebutton36.Visible = false
imagebutton36.Name = "a1_INF YIELD"
imagebutton36.Parent = scrollingframe33

-- Creating UICorner
local uicorner37 = Instance.new("UICorner")
uicorner37.Parent = imagebutton36

-- Creating ImageButton
local imagebutton38 = Instance.new("ImageButton")
imagebutton38.Image = "rbxassetid://112062985804784"
imagebutton38.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
imagebutton38.BackgroundTransparency = 0.20000000298023224
imagebutton38.Size = UDim2.new(0, 70, 0, 70)
imagebutton38.Visible = false
imagebutton38.Name = "a2_Dex"
imagebutton38.Parent = scrollingframe33

-- Creating UICorner
local uicorner39 = Instance.new("UICorner")
uicorner39.Parent = imagebutton38

-- Creating ImageButton
local imagebutton40 = Instance.new("ImageButton")
imagebutton40.Image = "rbxassetid://76210662677344"
imagebutton40.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
imagebutton40.BackgroundTransparency = 0.20000000298023224
imagebutton40.Size = UDim2.new(0, 70, 0, 70)
imagebutton40.Visible = false
imagebutton40.Name = "a3_Keyboard"
imagebutton40.Parent = scrollingframe33

-- Creating UICorner
local uicorner41 = Instance.new("UICorner")
uicorner41.Parent = imagebutton40

-- Creating ImageButton
local imagebutton42 = Instance.new("ImageButton")
imagebutton42.Image = "rbxassetid://111409127543607"
imagebutton42.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
imagebutton42.BackgroundTransparency = 0.20000000298023224
imagebutton42.Size = UDim2.new(0, 70, 0, 70)
imagebutton42.Visible = false
imagebutton42.Name = "a4_Rochips"
imagebutton42.Parent = scrollingframe33

-- Creating UICorner
local uicorner43 = Instance.new("UICorner")
uicorner43.Parent = imagebutton42

-- Creating ImageButton
local imagebutton44 = Instance.new("ImageButton")
imagebutton44.Image = "rbxassetid://73739594473443"
imagebutton44.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
imagebutton44.BackgroundTransparency = 0.20000000298023224
imagebutton44.Size = UDim2.new(0, 70, 0, 70)
imagebutton44.Visible = false
imagebutton44.Name = "a5_Ketamine"
imagebutton44.Parent = scrollingframe33

-- Creating UICorner
local uicorner45 = Instance.new("UICorner")
uicorner45.Parent = imagebutton44

-- Creating ImageButton
local imagebutton46 = Instance.new("ImageButton")
imagebutton46.Image = "rbxassetid://70633192931522"
imagebutton46.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
imagebutton46.BackgroundTransparency = 0.20000000298023224
imagebutton46.Size = UDim2.new(0, 70, 0, 70)
imagebutton46.Visible = false
imagebutton46.Name = "a6_AFEM"
imagebutton46.Parent = scrollingframe33

-- Creating UICorner
local uicorner47 = Instance.new("UICorner")
uicorner47.Parent = imagebutton46

-- Creating ImageButton
local imagebutton48 = Instance.new("ImageButton")
imagebutton48.Image = "rbxassetid://78687742773593"
imagebutton48.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
imagebutton48.BackgroundTransparency = 0.20000000298023224
imagebutton48.Size = UDim2.new(0, 70, 0, 70)
imagebutton48.Visible = false
imagebutton48.Name = "a7_Chat"
imagebutton48.Parent = scrollingframe33

-- Creating UICorner
local uicorner49 = Instance.new("UICorner")
uicorner49.Parent = imagebutton48

-- Creating ImageButton
local imagebutton50 = Instance.new("ImageButton")
imagebutton50.Image = "rbxassetid://7128117167"
imagebutton50.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
imagebutton50.BackgroundTransparency = 0.20000000298023224
imagebutton50.Size = UDim2.new(0, 70, 0, 70)
imagebutton50.Visible = false
imagebutton50.Name = "a8_ExeTest"
imagebutton50.Parent = scrollingframe33

-- Creating UICorner
local uicorner51 = Instance.new("UICorner")
uicorner51.Parent = imagebutton50

-- Creating ImageButton
local imagebutton52 = Instance.new("ImageButton")
imagebutton52.Image = "rbxassetid://91782079102380"
imagebutton52.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
imagebutton52.BackgroundTransparency = 0.20000000298023224
imagebutton52.Size = UDim2.new(0, 70, 0, 70)
imagebutton52.Visible = false
imagebutton52.Name = "a9_REM"
imagebutton52.Parent = scrollingframe33

-- Creating UICorner
local uicorner53 = Instance.new("UICorner")
uicorner53.Parent = imagebutton52

-- Creating ImageButton
local imagebutton54 = Instance.new("ImageButton")
imagebutton54.Image = "rbxassetid://14944375078"
imagebutton54.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
imagebutton54.BackgroundTransparency = 0.20000000298023224
imagebutton54.Size = UDim2.new(0, 70, 0, 70)
imagebutton54.Visible = false
imagebutton54.Name = "b1_GameProber"
imagebutton54.Parent = scrollingframe33

-- Creating UICorner
local uicorner55 = Instance.new("UICorner")
uicorner55.Parent = imagebutton54

-- Creating ImageButton
local imagebutton56 = Instance.new("ImageButton")
imagebutton56.Image = "rbxassetid://93917898537008"
imagebutton56.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
imagebutton56.BackgroundTransparency = 0.20000000298023224
imagebutton56.Size = UDim2.new(0, 70, 0, 70)
imagebutton56.Visible = false
imagebutton56.Name = "b2_AudioPlayer"
imagebutton56.Parent = scrollingframe33

-- Creating UICorner
local uicorner57 = Instance.new("UICorner")
uicorner57.Parent = imagebutton56

-- Creating ImageButton
local imagebutton58 = Instance.new("ImageButton")
imagebutton58.Image = "rbxassetid://116278455133074"
imagebutton58.BackgroundColor3 = Color3.new(0.250980406999588, 1, 0.29019609093666077)
imagebutton58.BackgroundTransparency = 0.20000000298023224
imagebutton58.Size = UDim2.new(0, 70, 0, 70)
imagebutton58.Visible = false
imagebutton58.Name = "b3_ExperienceSettings_Executor"
imagebutton58.Parent = scrollingframe33

-- Creating UICorner
local uicorner59 = Instance.new("UICorner")
uicorner59.Parent = imagebutton58

-- Creating TextButton
local textbutton60 = Instance.new("TextButton")
textbutton60.Text = "Emote Select"
textbutton60.TextColor3 = Color3.new(1, 1, 1)
textbutton60.TextScaled = true
textbutton60.TextWrapped = true
textbutton60.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton60.BackgroundTransparency = 0.20000000298023224
textbutton60.Size = UDim2.new(0, 70, 0, 70)
textbutton60.Visible = false
textbutton60.Name = "b3_EmoteSelect"
textbutton60.Parent = scrollingframe33

-- Creating UICorner
local uicorner61 = Instance.new("UICorner")
uicorner61.Parent = textbutton60

-- Creating TextButton
local textbutton62 = Instance.new("TextButton")
textbutton62.Text = "Universal Chat"
textbutton62.TextColor3 = Color3.new(1, 1, 1)
textbutton62.TextScaled = true
textbutton62.TextWrapped = true
textbutton62.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton62.BackgroundTransparency = 0.20000000298023224
textbutton62.Size = UDim2.new(0, 70, 0, 70)
textbutton62.Visible = false
textbutton62.Name = "b4_UniversalChat"
textbutton62.Parent = scrollingframe33

-- Creating UICorner
local uicorner63 = Instance.new("UICorner")
uicorner63.Parent = textbutton62

-- Creating Frame
local frame64 = Instance.new("Frame")
frame64.BackgroundColor3 = Color3.new(0.07058823853731155, 0.07058823853731155, 0.08235294371843338)
frame64.BackgroundTransparency = 0.5
frame64.Position = UDim2.new(1, 0, 0.10000000149011612, 0)
frame64.Size = UDim2.new(0.3499999940395355, 0, 0.8999999761581421, 0)
frame64.Name = "Background"
frame64.Parent = screengui2

-- Creating UICorner
local uicorner65 = Instance.new("UICorner")
uicorner65.Parent = frame64

-- Creating ImageLabel
local imagelabel66 = Instance.new("ImageLabel")
imagelabel66.Image = "rbxassetid://77745379860640"
imagelabel66.BackgroundTransparency = 0.5
imagelabel66.Position = UDim2.new(0.019999999552965164, 0, 0.019999999552965164, 0)
imagelabel66.Size = UDim2.new(0.30000001192092896, 0, 0.23499999940395355, 0)
imagelabel66.Name = "ExperienceImage"
imagelabel66.Parent = frame64

-- Creating UICorner
local uicorner67 = Instance.new("UICorner")
uicorner67.Parent = imagelabel66

-- Creating TextLabel
local textlabel68 = Instance.new("TextLabel")
textlabel68.Text = "The Normal Elevator"
textlabel68.TextColor3 = Color3.new(1, 1, 1)
textlabel68.TextScaled = true
textlabel68.TextStrokeTransparency = 0
textlabel68.TextWrapped = true
textlabel68.BackgroundTransparency = 1
textlabel68.Position = UDim2.new(0.3400000035762787, 0, 0.019999999552965164, 0)
textlabel68.Size = UDim2.new(0.6499999761581421, 0, 0.23499999940395355, 0)
textlabel68.Name = "ExperienceName"
textlabel68.Parent = frame64

-- Creating Frame
local frame69 = Instance.new("Frame")
frame69.Active = true
frame69.BackgroundColor3 = Color3.new(0, 0, 0)
frame69.BackgroundTransparency = 0.5
frame69.Position = UDim2.new(0.019999999552965164, 0, 0.2800000011920929, 0)
frame69.Size = UDim2.new(0.9599999785423279, 0, 0.699999988079071, 0)
frame69.Name = "Settings"
frame69.Parent = frame64

-- Creating UICorner
local uicorner70 = Instance.new("UICorner")
uicorner70.Parent = frame69

-- Creating Folder
local folder71 = Instance.new("Folder")
folder71.Name = "Pmax"
folder71.Parent = frame69

-- Creating TextLabel
local textlabel72 = Instance.new("TextLabel")
textlabel72.Text = "Player :"
textlabel72.TextColor3 = Color3.new(0, 0, 0)
textlabel72.TextScaled = true
textlabel72.TextWrapped = true
textlabel72.BackgroundColor3 = Color3.new(1, 1, 1)
textlabel72.BackgroundTransparency = 0.20000000298023224
textlabel72.Position = UDim2.new(0.019999999552965164, 0, 0.019999999552965164, 0)
textlabel72.Size = UDim2.new(0.36000001430511475, 0, 0.05000000074505806, 0)
textlabel72.Name = "Players"
textlabel72.Parent = folder71

-- Creating UICorner
local uicorner73 = Instance.new("UICorner")
uicorner73.Parent = textlabel72

-- Creating TextLabel
local textlabel74 = Instance.new("TextLabel")
textlabel74.Text = "6/8"
textlabel74.TextColor3 = Color3.new(0, 0, 0)
textlabel74.TextScaled = true
textlabel74.TextWrapped = true
textlabel74.BackgroundColor3 = Color3.new(1, 1, 1)
textlabel74.BackgroundTransparency = 0.20000000298023224
textlabel74.Position = UDim2.new(0.4000000059604645, 0, 0.019999999552965164, 0)
textlabel74.Size = UDim2.new(0.5799999833106995, 0, 0.05000000074505806, 0)
textlabel74.Name = "PlayerCount"
textlabel74.Parent = folder71

-- Creating UICorner
local uicorner75 = Instance.new("UICorner")
uicorner75.Parent = textlabel74

-- Creating TextButton
local textbutton76 = Instance.new("TextButton")
textbutton76.Text = "Open Roblox Settings"
textbutton76.TextScaled = true
textbutton76.TextWrapped = true
textbutton76.BackgroundTransparency = 0.20000000298023224
textbutton76.Position = UDim2.new(0.019999999552965164, 0, 0.07999999821186066, 0)
textbutton76.Size = UDim2.new(0.9599999785423279, 0, 0.05000000074505806, 0)
textbutton76.Name = "SeeAll"
textbutton76.Parent = folder71

-- Creating UICorner
local uicorner77 = Instance.new("UICorner")
uicorner77.Parent = textbutton76

-- Creating Folder
local folder78 = Instance.new("Folder")
folder78.Name = "Buttons"
folder78.Parent = frame69

-- Creating TextButton
local textbutton79 = Instance.new("TextButton")
textbutton79.Text = "Leave The Experience"
textbutton79.TextColor3 = Color3.new(1, 1, 1)
textbutton79.TextScaled = true
textbutton79.TextWrapped = true
textbutton79.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton79.BackgroundTransparency = 0.20000000298023224
textbutton79.Position = UDim2.new(0.019999999552965164, 0, 0.9399999976158142, 0)
textbutton79.Size = UDim2.new(0.9599999785423279, 0, 0.05000000074505806, 0)
textbutton79.Name = "Leave"
textbutton79.Parent = folder78

-- Creating UICorner
local uicorner80 = Instance.new("UICorner")
uicorner80.Parent = textbutton79

-- Creating TextButton
local textbutton81 = Instance.new("TextButton")
textbutton81.Text = "Reset character"
textbutton81.TextColor3 = Color3.new(1, 1, 1)
textbutton81.TextScaled = true
textbutton81.TextWrapped = true
textbutton81.BackgroundColor3 = Color3.new(1, 0.3294117748737335, 0.3294117748737335)
textbutton81.BackgroundTransparency = 0.20000000298023224
textbutton81.Position = UDim2.new(0.019999999552965164, 0, 0.8799999952316284, 0)
textbutton81.Size = UDim2.new(0.9599999785423279, 0, 0.05000000074505806, 0)
textbutton81.Name = "Reset character"
textbutton81.Parent = folder78

-- Creating UICorner
local uicorner82 = Instance.new("UICorner")
uicorner82.Parent = textbutton81

-- Creating TextButton
local textbutton83 = Instance.new("TextButton")
textbutton83.Text = "Resume"
textbutton83.TextColor3 = Color3.new(1, 1, 1)
textbutton83.TextScaled = true
textbutton83.TextWrapped = true
textbutton83.BackgroundColor3 = Color3.new(0.6666666865348816, 0.6666666865348816, 0.6666666865348816)
textbutton83.BackgroundTransparency = 0.20000000298023224
textbutton83.Position = UDim2.new(0.019999999552965164, 0, 0.8199999928474426, 0)
textbutton83.Size = UDim2.new(0.9599999785423279, 0, 0.05000000074505806, 0)
textbutton83.Name = "Resume"
textbutton83.Parent = folder78

-- Creating UICorner
local uicorner84 = Instance.new("UICorner")
uicorner84.Parent = textbutton83

-- Creating Frame
local frame85 = Instance.new("Frame")
frame85.Position = UDim2.new(0.019999999552965164, 0, 0.15000000596046448, 0)
frame85.Size = UDim2.new(0.9599999785423279, 0, 0.009999999776482582, 0)
frame85.Name = "Line"
frame85.Parent = frame69

-- Creating Frame
local frame86 = Instance.new("Frame")
frame86.Position = UDim2.new(0.019999999552965164, 0, 0.7900000214576721, 0)
frame86.Size = UDim2.new(0.9599999785423279, 0, 0.009999999776482582, 0)
frame86.Name = "Line2"
frame86.Parent = frame69

-- Creating Frame
local frame87 = Instance.new("Frame")
frame87.BackgroundTransparency = 1
frame87.Position = UDim2.new(0.019999999552965164, 0, 0.18000000715255737, 0)
frame87.Size = UDim2.new(0.9599999785423279, 0, 0.6000000238418579, 0)
frame87.Name = "B_Frame"
frame87.Parent = frame69

-- Creating UIListLayout
local uilistlayout88 = Instance.new("UIListLayout")
uilistlayout88.Parent = frame87

-- Creating Frame
local frame89 = Instance.new("Frame")
frame89.BackgroundColor3 = Color3.new(0, 0, 0)
frame89.Size = UDim2.new(1, 0, 0.10000000149011612, 0)
frame89.Name = "Frame1"
frame89.Parent = frame87

-- Creating UICorner
local uicorner90 = Instance.new("UICorner")
uicorner90.Parent = frame89

-- Creating Frame
local frame91 = Instance.new("Frame")
frame91.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame91.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame91.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame91.Name = "Bar"
frame91.Parent = frame89

-- Creating UICorner
local uicorner92 = Instance.new("UICorner")
uicorner92.Parent = frame91

-- Creating TextButton
local textbutton93 = Instance.new("TextButton")
textbutton93.Text = "ON"
textbutton93.BackgroundColor3 = Color3.new(0, 0.7843137383460999, 0)
textbutton93.Size = UDim2.new(0.5, 0, 1, 0)
textbutton93.Name = "ToggleButton"
textbutton93.Parent = frame91

-- Creating UICorner
local uicorner94 = Instance.new("UICorner")
uicorner94.Parent = textbutton93

-- Creating TextLabel
local textlabel95 = Instance.new("TextLabel")
textlabel95.RichText = true
textlabel95.Text = "Enable ValueLabels"
textlabel95.TextColor3 = Color3.new(1, 1, 1)
textlabel95.TextScaled = true
textlabel95.TextWrapped = true
textlabel95.BackgroundTransparency = 1
textlabel95.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel95.Name = "Label"
textlabel95.Parent = frame89

-- Creating Frame
local frame96 = Instance.new("Frame")
frame96.BackgroundColor3 = Color3.new(0, 0, 0)
frame96.Size = UDim2.new(1, 0, 0.10000000149011612, 0)
frame96.Name = "Frame2"
frame96.Parent = frame87

-- Creating UICorner
local uicorner97 = Instance.new("UICorner")
uicorner97.Parent = frame96

-- Creating Frame
local frame98 = Instance.new("Frame")
frame98.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame98.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame98.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame98.Name = "Bar"
frame98.Parent = frame96

-- Creating UICorner
local uicorner99 = Instance.new("UICorner")
uicorner99.Parent = frame98

-- Creating TextButton
local textbutton100 = Instance.new("TextButton")
textbutton100.Text = "OFF"
textbutton100.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton100.Position = UDim2.new(0.5, 0, 0, 0)
textbutton100.Size = UDim2.new(0.5, 0, 1, 0)
textbutton100.Name = "ToggleButton"
textbutton100.Parent = frame98

-- Creating UICorner
local uicorner101 = Instance.new("UICorner")
uicorner101.Parent = textbutton100

-- Creating TextLabel
local textlabel102 = Instance.new("TextLabel")
textlabel102.RichText = true
textlabel102.Text = "Shaders - Recommend graphics 5+"
textlabel102.TextColor3 = Color3.new(1, 1, 1)
textlabel102.TextScaled = true
textlabel102.TextWrapped = true
textlabel102.BackgroundTransparency = 1
textlabel102.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel102.Name = "Label"
textlabel102.Parent = frame96

-- Creating Frame
local frame103 = Instance.new("Frame")
frame103.BackgroundColor3 = Color3.new(0, 0, 0)
frame103.Size = UDim2.new(1, 0, 0.10000000149011612, 0)
frame103.Name = "Frame3"
frame103.Parent = frame87

-- Creating UICorner
local uicorner104 = Instance.new("UICorner")
uicorner104.Parent = frame103

-- Creating Frame
local frame105 = Instance.new("Frame")
frame105.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame105.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame105.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame105.Name = "Bar"
frame105.Parent = frame103

-- Creating UICorner
local uicorner106 = Instance.new("UICorner")
uicorner106.Parent = frame105

-- Creating TextButton
local textbutton107 = Instance.new("TextButton")
textbutton107.Text = "OFF"
textbutton107.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton107.Position = UDim2.new(0.5, 0, 0, 0)
textbutton107.Size = UDim2.new(0.5, 0, 1, 0)
textbutton107.Name = "ToggleButton"
textbutton107.Parent = frame105

-- Creating UICorner
local uicorner108 = Instance.new("UICorner")
uicorner108.Parent = textbutton107

-- Creating TextLabel
local textlabel109 = Instance.new("TextLabel")
textlabel109.RichText = true
textlabel109.Text = "White Light"
textlabel109.TextColor3 = Color3.new(1, 1, 1)
textlabel109.TextScaled = true
textlabel109.TextWrapped = true
textlabel109.BackgroundTransparency = 1
textlabel109.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel109.Name = "Label"
textlabel109.Parent = frame103

-- Creating Frame
local frame110 = Instance.new("Frame")
frame110.BackgroundColor3 = Color3.new(0, 0, 0)
frame110.Size = UDim2.new(1, 0, 0.10000000149011612, 0)
frame110.Name = "Frame4"
frame110.Parent = frame87

-- Creating UICorner
local uicorner111 = Instance.new("UICorner")
uicorner111.Parent = frame110

-- Creating Frame
local frame112 = Instance.new("Frame")
frame112.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame112.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame112.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame112.Name = "Bar"
frame112.Parent = frame110

-- Creating UICorner
local uicorner113 = Instance.new("UICorner")
uicorner113.Parent = frame112

-- Creating TextButton
local textbutton114 = Instance.new("TextButton")
textbutton114.Text = "OFF"
textbutton114.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton114.Position = UDim2.new(0.5, 0, 0, 0)
textbutton114.Size = UDim2.new(0.5, 0, 1, 0)
textbutton114.Name = "ToggleButton"
textbutton114.Parent = frame112

-- Creating UICorner
local uicorner115 = Instance.new("UICorner")
uicorner115.Parent = textbutton114

-- Creating TextLabel
local textlabel116 = Instance.new("TextLabel")
textlabel116.RichText = true
textlabel116.Text = "RGB Light"
textlabel116.TextColor3 = Color3.new(1, 1, 1)
textlabel116.TextScaled = true
textlabel116.TextWrapped = true
textlabel116.BackgroundTransparency = 1
textlabel116.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel116.Name = "Label"
textlabel116.Parent = frame110

-- Creating Frame
local frame117 = Instance.new("Frame")
frame117.BackgroundColor3 = Color3.new(0, 0, 0)
frame117.Size = UDim2.new(1, 0, 0.10000000149011612, 0)
frame117.Name = "Frame5"
frame117.Parent = frame87

-- Creating UICorner
local uicorner118 = Instance.new("UICorner")
uicorner118.Parent = frame117

-- Creating Frame
local frame119 = Instance.new("Frame")
frame119.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame119.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame119.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame119.Name = "Bar"
frame119.Parent = frame117

-- Creating UICorner
local uicorner120 = Instance.new("UICorner")
uicorner120.Parent = frame119

-- Creating TextButton
local textbutton121 = Instance.new("TextButton")
textbutton121.Text = "OFF"
textbutton121.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton121.Position = UDim2.new(0.5, 0, 0, 0)
textbutton121.Size = UDim2.new(0.5, 0, 1, 0)
textbutton121.Name = "ToggleButton"
textbutton121.Parent = frame119

-- Creating UICorner
local uicorner122 = Instance.new("UICorner")
uicorner122.Parent = textbutton121

-- Creating TextLabel
local textlabel123 = Instance.new("TextLabel")
textlabel123.RichText = true
textlabel123.Text = "ESP"
textlabel123.TextColor3 = Color3.new(1, 1, 1)
textlabel123.TextScaled = true
textlabel123.TextWrapped = true
textlabel123.BackgroundTransparency = 1
textlabel123.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel123.Name = "Label"
textlabel123.Parent = frame117

-- Creating Frame
local frame124 = Instance.new("Frame")
frame124.BackgroundColor3 = Color3.new(0, 0, 0)
frame124.Size = UDim2.new(1, 0, 0.10000000149011612, 0)
frame124.Name = "Frame6"
frame124.Parent = frame87

-- Creating UICorner
local uicorner125 = Instance.new("UICorner")
uicorner125.Parent = frame124

-- Creating Frame
local frame126 = Instance.new("Frame")
frame126.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame126.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame126.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame126.Name = "Bar"
frame126.Parent = frame124

-- Creating UICorner
local uicorner127 = Instance.new("UICorner")
uicorner127.Parent = frame126

-- Creating TextButton
local textbutton128 = Instance.new("TextButton")
textbutton128.Text = "OFF"
textbutton128.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton128.Position = UDim2.new(0.5, 0, 0, 0)
textbutton128.Size = UDim2.new(0.5, 0, 1, 0)
textbutton128.Name = "ToggleButton"
textbutton128.Parent = frame126

-- Creating UICorner
local uicorner129 = Instance.new("UICorner")
uicorner129.Parent = textbutton128

-- Creating TextLabel
local textlabel130 = Instance.new("TextLabel")
textlabel130.RichText = true
textlabel130.Text = "Damage Overlay <stroke color='rgb(255,255,255)' thickness='1'><font color='#ff5555'><b>⚠ EPILEPSY WARNING</b></font></stroke>"
textlabel130.TextColor3 = Color3.new(1, 1, 1)
textlabel130.TextScaled = true
textlabel130.TextWrapped = true
textlabel130.BackgroundTransparency = 1
textlabel130.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel130.Name = "Label"
textlabel130.Parent = frame124

-- Creating Frame
local frame131 = Instance.new("Frame")
frame131.BackgroundColor3 = Color3.new(0, 0, 0)
frame131.Size = UDim2.new(1, 0, 0.10000000149011612, 0)
frame131.Name = "Frame7"
frame131.Parent = frame87

-- Creating UICorner
local uicorner132 = Instance.new("UICorner")
uicorner132.Parent = frame131

-- Creating Frame
local frame133 = Instance.new("Frame")
frame133.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame133.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame133.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame133.Name = "Bar"
frame133.Parent = frame131

-- Creating UICorner
local uicorner134 = Instance.new("UICorner")
uicorner134.Parent = frame133

-- Creating TextButton
local textbutton135 = Instance.new("TextButton")
textbutton135.Text = "OFF"
textbutton135.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton135.Position = UDim2.new(0.5, 0, 0, 0)
textbutton135.Size = UDim2.new(0.5, 0, 1, 0)
textbutton135.Name = "ToggleButton"
textbutton135.Parent = frame133

-- Creating UICorner
local uicorner136 = Instance.new("UICorner")
uicorner136.Parent = textbutton135

-- Creating TextLabel
local textlabel137 = Instance.new("TextLabel")
textlabel137.RichText = true
textlabel137.Text = "MoreToggles"
textlabel137.TextColor3 = Color3.new(1, 1, 1)
textlabel137.TextScaled = true
textlabel137.TextWrapped = true
textlabel137.BackgroundTransparency = 1
textlabel137.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel137.Name = "Label"
textlabel137.Parent = frame131

-- Creating Frame
local frame138 = Instance.new("Frame")
frame138.BackgroundColor3 = Color3.new(0.07058823853731155, 0.07058823853731155, 0.08235294371843338)
frame138.BackgroundTransparency = 0.5
frame138.Position = UDim2.new(-0.800000011920929, 0, 0, 0)
frame138.Size = UDim2.new(0.800000011920929, 0, 1, 0)
frame138.Visible = false
frame138.Name = "Inner_Background"
frame138.Parent = frame64

-- Creating UICorner
local uicorner139 = Instance.new("UICorner")
uicorner139.Parent = frame138

-- Creating Frame
local frame140 = Instance.new("Frame")
frame140.BackgroundColor3 = Color3.new(0, 0, 0)
frame140.BackgroundTransparency = 0.5
frame140.Position = UDim2.new(0.019999999552965164, 0, 0.019999999552965164, 0)
frame140.Size = UDim2.new(0.9599999785423279, 0, 0.9599999785423279, 0)
frame140.Name = "Toggles"
frame140.Parent = frame138

-- Creating UICorner
local uicorner141 = Instance.new("UICorner")
uicorner141.Parent = frame140

-- Creating Frame
local frame142 = Instance.new("Frame")
frame142.BackgroundTransparency = 1
frame142.Position = UDim2.new(0.019999999552965164, 0, 0.019999999552965164, 0)
frame142.Size = UDim2.new(0.9599999785423279, 0, 0.9599999785423279, 0)
frame142.Name = "B_Frame"
frame142.Parent = frame140

-- Creating UIListLayout
local uilistlayout143 = Instance.new("UIListLayout")
uilistlayout143.Parent = frame142

-- Creating Frame
local frame144 = Instance.new("Frame")
frame144.BackgroundColor3 = Color3.new(0, 0, 0)
frame144.Size = UDim2.new(1, 0, 0.05000000074505806, 0)
frame144.Name = "Frame1"
frame144.Parent = frame142

-- Creating UICorner
local uicorner145 = Instance.new("UICorner")
uicorner145.Parent = frame144

-- Creating Frame
local frame146 = Instance.new("Frame")
frame146.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame146.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame146.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame146.Name = "Bar"
frame146.Parent = frame144

-- Creating UICorner
local uicorner147 = Instance.new("UICorner")
uicorner147.Parent = frame146

-- Creating TextButton
local textbutton148 = Instance.new("TextButton")
textbutton148.Text = "OFF"
textbutton148.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton148.Position = UDim2.new(0.5, 0, 0, 0)
textbutton148.Size = UDim2.new(0.5, 0, 1, 0)
textbutton148.Name = "ToggleButton"
textbutton148.Parent = frame146

-- Creating UICorner
local uicorner149 = Instance.new("UICorner")
uicorner149.Parent = textbutton148

-- Creating TextLabel
local textlabel150 = Instance.new("TextLabel")
textlabel150.RichText = true
textlabel150.Text = "LighterCyan.ai (Discontinued)"
textlabel150.TextColor3 = Color3.new(1, 1, 1)
textlabel150.TextScaled = true
textlabel150.TextWrapped = true
textlabel150.BackgroundTransparency = 1
textlabel150.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel150.Name = "Label"
textlabel150.Parent = frame144

-- Creating Frame
local frame151 = Instance.new("Frame")
frame151.BackgroundColor3 = Color3.new(0, 0, 0)
frame151.Size = UDim2.new(1, 0, 0.05000000074505806, 0)
frame151.Name = "Frame2"
frame151.Parent = frame142

-- Creating UICorner
local uicorner152 = Instance.new("UICorner")
uicorner152.Parent = frame151

-- Creating Frame
local frame153 = Instance.new("Frame")
frame153.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame153.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame153.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame153.Name = "Bar"
frame153.Parent = frame151

-- Creating UICorner
local uicorner154 = Instance.new("UICorner")
uicorner154.Parent = frame153

-- Creating TextButton
local textbutton155 = Instance.new("TextButton")
textbutton155.Text = "ON"
textbutton155.BackgroundColor3 = Color3.new(0, 0.7843137383460999, 0)
textbutton155.Size = UDim2.new(0.5, 0, 1, 0)
textbutton155.Name = "ToggleButton"
textbutton155.Parent = frame153

-- Creating UICorner
local uicorner156 = Instance.new("UICorner")
uicorner156.Parent = textbutton155

-- Creating TextLabel
local textlabel157 = Instance.new("TextLabel")
textlabel157.RichText = true
textlabel157.Text = "Enable HealthBar"
textlabel157.TextColor3 = Color3.new(1, 1, 1)
textlabel157.TextScaled = true
textlabel157.TextWrapped = true
textlabel157.BackgroundTransparency = 1
textlabel157.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel157.Name = "Label"
textlabel157.Parent = frame151

-- Creating Frame
local frame158 = Instance.new("Frame")
frame158.BackgroundColor3 = Color3.new(0, 0, 0)
frame158.Size = UDim2.new(1, 0, 0.05000000074505806, 0)
frame158.Name = "Frame3"
frame158.Parent = frame142

-- Creating UICorner
local uicorner159 = Instance.new("UICorner")
uicorner159.Parent = frame158

-- Creating Frame
local frame160 = Instance.new("Frame")
frame160.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame160.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame160.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame160.Name = "Bar"
frame160.Parent = frame158

-- Creating UICorner
local uicorner161 = Instance.new("UICorner")
uicorner161.Parent = frame160

-- Creating TextButton
local textbutton162 = Instance.new("TextButton")
textbutton162.Text = "OFF"
textbutton162.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton162.Position = UDim2.new(0.5, 0, 0, 0)
textbutton162.Size = UDim2.new(0.5, 0, 1, 0)
textbutton162.Name = "ToggleButton"
textbutton162.Parent = frame160

-- Creating UICorner
local uicorner163 = Instance.new("UICorner")
uicorner163.Parent = textbutton162

-- Creating TextLabel
local textlabel164 = Instance.new("TextLabel")
textlabel164.RichText = true
textlabel164.Text = "Disable Death Sound"
textlabel164.TextColor3 = Color3.new(1, 1, 1)
textlabel164.TextScaled = true
textlabel164.TextWrapped = true
textlabel164.BackgroundTransparency = 1
textlabel164.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel164.Name = "Label"
textlabel164.Parent = frame158

-- Creating Frame
local frame165 = Instance.new("Frame")
frame165.BackgroundColor3 = Color3.new(0, 0, 0)
frame165.Size = UDim2.new(1, 0, 0.05000000074505806, 0)
frame165.Name = "Frame4"
frame165.Parent = frame142

-- Creating UICorner
local uicorner166 = Instance.new("UICorner")
uicorner166.Parent = frame165

-- Creating Frame
local frame167 = Instance.new("Frame")
frame167.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame167.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame167.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame167.Name = "Bar"
frame167.Parent = frame165

-- Creating UICorner
local uicorner168 = Instance.new("UICorner")
uicorner168.Parent = frame167

-- Creating TextButton
local textbutton169 = Instance.new("TextButton")
textbutton169.Text = "OFF"
textbutton169.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton169.Position = UDim2.new(0.5, 0, 0, 0)
textbutton169.Size = UDim2.new(0.5, 0, 1, 0)
textbutton169.Name = "ToggleButton"
textbutton169.Parent = frame167

-- Creating UICorner
local uicorner170 = Instance.new("UICorner")
uicorner170.Parent = textbutton169

-- Creating TextLabel
local textlabel171 = Instance.new("TextLabel")
textlabel171.RichText = true
textlabel171.Text = "FreeCam (Mobile)"
textlabel171.TextColor3 = Color3.new(1, 1, 1)
textlabel171.TextScaled = true
textlabel171.TextWrapped = true
textlabel171.BackgroundTransparency = 1
textlabel171.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel171.Name = "Label"
textlabel171.Parent = frame165

-- Creating Frame
local frame172 = Instance.new("Frame")
frame172.BackgroundColor3 = Color3.new(0, 0, 0)
frame172.Size = UDim2.new(1, 0, 0.05000000074505806, 0)
frame172.Name = "Frame5"
frame172.Parent = frame142

-- Creating UICorner
local uicorner173 = Instance.new("UICorner")
uicorner173.Parent = frame172

-- Creating Frame
local frame174 = Instance.new("Frame")
frame174.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame174.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame174.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame174.Name = "Bar"
frame174.Parent = frame172

-- Creating UICorner
local uicorner175 = Instance.new("UICorner")
uicorner175.Parent = frame174

-- Creating TextButton
local textbutton176 = Instance.new("TextButton")
textbutton176.Text = "OFF"
textbutton176.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton176.Position = UDim2.new(0.5, 0, 0, 0)
textbutton176.Size = UDim2.new(0.5, 0, 1, 0)
textbutton176.Name = "ToggleButton"
textbutton176.Parent = frame174

-- Creating UICorner
local uicorner177 = Instance.new("UICorner")
uicorner177.Parent = textbutton176

-- Creating TextLabel
local textlabel178 = Instance.new("TextLabel")
textlabel178.RichText = true
textlabel178.Text = "Almost Endless Fallen (-50K)"
textlabel178.TextColor3 = Color3.new(1, 1, 1)
textlabel178.TextScaled = true
textlabel178.TextWrapped = true
textlabel178.BackgroundTransparency = 1
textlabel178.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel178.Name = "Label"
textlabel178.Parent = frame172

-- Creating Frame
local frame179 = Instance.new("Frame")
frame179.BackgroundColor3 = Color3.new(0, 0, 0)
frame179.Size = UDim2.new(1, 0, 0.05000000074505806, 0)
frame179.Name = "Frame6"
frame179.Parent = frame142

-- Creating UICorner
local uicorner180 = Instance.new("UICorner")
uicorner180.Parent = frame179

-- Creating Frame
local frame181 = Instance.new("Frame")
frame181.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame181.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame181.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame181.Name = "Bar"
frame181.Parent = frame179

-- Creating UICorner
local uicorner182 = Instance.new("UICorner")
uicorner182.Parent = frame181

-- Creating TextButton
local textbutton183 = Instance.new("TextButton")
textbutton183.Text = "OFF"
textbutton183.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton183.Position = UDim2.new(0.5, 0, 0, 0)
textbutton183.Size = UDim2.new(0.5, 0, 1, 0)
textbutton183.Name = "ToggleButton"
textbutton183.Parent = frame181

-- Creating UICorner
local uicorner184 = Instance.new("UICorner")
uicorner184.Parent = textbutton183

-- Creating TextLabel
local textlabel185 = Instance.new("TextLabel")
textlabel185.RichText = true
textlabel185.Text = "Flashlight (FirstPerson & GFX 6+)"
textlabel185.TextColor3 = Color3.new(1, 1, 1)
textlabel185.TextScaled = true
textlabel185.TextWrapped = true
textlabel185.BackgroundTransparency = 1
textlabel185.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel185.Name = "Label"
textlabel185.Parent = frame179

-- Creating Frame
local frame186 = Instance.new("Frame")
frame186.BackgroundColor3 = Color3.new(0, 0, 0)
frame186.Size = UDim2.new(1, 0, 0.05000000074505806, 0)
frame186.Name = "Frame7"
frame186.Parent = frame142

-- Creating UICorner
local uicorner187 = Instance.new("UICorner")
uicorner187.Parent = frame186

-- Creating Frame
local frame188 = Instance.new("Frame")
frame188.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame188.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame188.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame188.Name = "Bar"
frame188.Parent = frame186

-- Creating UICorner
local uicorner189 = Instance.new("UICorner")
uicorner189.Parent = frame188

-- Creating TextButton
local textbutton190 = Instance.new("TextButton")
textbutton190.Text = "OFF"
textbutton190.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton190.Position = UDim2.new(0.5, 0, 0, 0)
textbutton190.Size = UDim2.new(0.5, 0, 1, 0)
textbutton190.Name = "ToggleButton"
textbutton190.Parent = frame188

-- Creating UICorner
local uicorner191 = Instance.new("UICorner")
uicorner191.Parent = textbutton190

-- Creating TextLabel
local textlabel192 = Instance.new("TextLabel")
textlabel192.RichText = true
textlabel192.Text = "ESP Highlight Players & Non-Players"
textlabel192.TextColor3 = Color3.new(1, 1, 1)
textlabel192.TextScaled = true
textlabel192.TextWrapped = true
textlabel192.BackgroundTransparency = 1
textlabel192.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel192.Name = "Label"
textlabel192.Parent = frame186

-- Creating Frame
local frame193 = Instance.new("Frame")
frame193.BackgroundColor3 = Color3.new(0, 0, 0)
frame193.Size = UDim2.new(1, 0, 0.05000000074505806, 0)
frame193.Name = "Frame8"
frame193.Parent = frame142

-- Creating UICorner
local uicorner194 = Instance.new("UICorner")
uicorner194.Parent = frame193

-- Creating Frame
local frame195 = Instance.new("Frame")
frame195.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame195.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame195.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame195.Name = "Bar"
frame195.Parent = frame193

-- Creating UICorner
local uicorner196 = Instance.new("UICorner")
uicorner196.Parent = frame195

-- Creating TextButton
local textbutton197 = Instance.new("TextButton")
textbutton197.Text = "OFF"
textbutton197.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton197.Position = UDim2.new(0.5, 0, 0, 0)
textbutton197.Size = UDim2.new(0.5, 0, 1, 0)
textbutton197.Name = "ToggleButton"
textbutton197.Parent = frame195

-- Creating UICorner
local uicorner198 = Instance.new("UICorner")
uicorner198.Parent = textbutton197

-- Creating TextLabel
local textlabel199 = Instance.new("TextLabel")
textlabel199.RichText = true
textlabel199.Text = "Shift Lock (Mobile)"
textlabel199.TextColor3 = Color3.new(1, 1, 1)
textlabel199.TextScaled = true
textlabel199.TextWrapped = true
textlabel199.BackgroundTransparency = 1
textlabel199.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel199.Name = "Label"
textlabel199.Parent = frame193

-- Creating Frame
local frame200 = Instance.new("Frame")
frame200.BackgroundColor3 = Color3.new(0, 0, 0)
frame200.Size = UDim2.new(1, 0, 0.05000000074505806, 0)
frame200.Name = "Frame9"
frame200.Parent = frame142

-- Creating UICorner
local uicorner201 = Instance.new("UICorner")
uicorner201.Parent = frame200

-- Creating Frame
local frame202 = Instance.new("Frame")
frame202.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame202.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame202.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame202.Name = "Bar"
frame202.Parent = frame200

-- Creating UICorner
local uicorner203 = Instance.new("UICorner")
uicorner203.Parent = frame202

-- Creating TextButton
local textbutton204 = Instance.new("TextButton")
textbutton204.Text = "OFF"
textbutton204.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton204.Position = UDim2.new(0.5, 0, 0, 0)
textbutton204.Size = UDim2.new(0.5, 0, 1, 0)
textbutton204.Name = "ToggleButton"
textbutton204.Parent = frame202

-- Creating UICorner
local uicorner205 = Instance.new("UICorner")
uicorner205.Parent = textbutton204

-- Creating TextLabel
local textlabel206 = Instance.new("TextLabel")
textlabel206.RichText = true
textlabel206.Text = "Hitbox Shower"
textlabel206.TextColor3 = Color3.new(1, 1, 1)
textlabel206.TextScaled = true
textlabel206.TextWrapped = true
textlabel206.BackgroundTransparency = 1
textlabel206.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel206.Name = "Label"
textlabel206.Parent = frame200

-- Creating Frame
local frame207 = Instance.new("Frame")
frame207.BackgroundColor3 = Color3.new(0, 0, 0)
frame207.Size = UDim2.new(1, 0, 0.05000000074505806, 0)
frame207.Name = "Frame10"
frame207.Parent = frame142

-- Creating UICorner
local uicorner208 = Instance.new("UICorner")
uicorner208.Parent = frame207

-- Creating Frame
local frame209 = Instance.new("Frame")
frame209.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame209.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame209.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame209.Name = "Bar"
frame209.Parent = frame207

-- Creating UICorner
local uicorner210 = Instance.new("UICorner")
uicorner210.Parent = frame209

-- Creating TextButton
local textbutton211 = Instance.new("TextButton")
textbutton211.Text = "OFF"
textbutton211.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton211.Position = UDim2.new(0.5, 0, 0, 0)
textbutton211.Size = UDim2.new(0.5, 0, 1, 0)
textbutton211.Name = "ToggleButton"
textbutton211.Parent = frame209

-- Creating UICorner
local uicorner212 = Instance.new("UICorner")
uicorner212.Parent = textbutton211

-- Creating TextLabel
local textlabel213 = Instance.new("TextLabel")
textlabel213.RichText = true
textlabel213.Text = "Last Death"
textlabel213.TextColor3 = Color3.new(1, 1, 1)
textlabel213.TextScaled = true
textlabel213.TextWrapped = true
textlabel213.BackgroundTransparency = 1
textlabel213.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel213.Name = "Label"
textlabel213.Parent = frame207

-- Creating Frame
local frame214 = Instance.new("Frame")
frame214.BackgroundColor3 = Color3.new(0, 0, 0)
frame214.Size = UDim2.new(1, 0, 0.05000000074505806, 0)
frame214.Name = "Frame11"
frame214.Parent = frame142

-- Creating UICorner
local uicorner215 = Instance.new("UICorner")
uicorner215.Parent = frame214

-- Creating Frame
local frame216 = Instance.new("Frame")
frame216.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame216.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame216.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame216.Name = "Bar"
frame216.Parent = frame214

-- Creating UICorner
local uicorner217 = Instance.new("UICorner")
uicorner217.Parent = frame216

-- Creating TextButton
local textbutton218 = Instance.new("TextButton")
textbutton218.Text = "OFF"
textbutton218.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton218.Position = UDim2.new(0.5, 0, 0, 0)
textbutton218.Size = UDim2.new(0.5, 0, 1, 0)
textbutton218.Name = "ToggleButton"
textbutton218.Parent = frame216

-- Creating UICorner
local uicorner219 = Instance.new("UICorner")
uicorner219.Parent = textbutton218

-- Creating TextLabel
local textlabel220 = Instance.new("TextLabel")
textlabel220.RichText = true
textlabel220.Text = "ServerPositionPredictor (By @zephyrr)"
textlabel220.TextColor3 = Color3.new(1, 1, 1)
textlabel220.TextScaled = true
textlabel220.TextWrapped = true
textlabel220.BackgroundTransparency = 1
textlabel220.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel220.Name = "Label"
textlabel220.Parent = frame214

-- Creating Frame
local frame221 = Instance.new("Frame")
frame221.BackgroundColor3 = Color3.new(0, 0, 0)
frame221.Size = UDim2.new(1, 0, 0.05000000074505806, 0)
frame221.Name = "Frame1"
frame221.Parent = frame142

-- Creating UICorner
local uicorner222 = Instance.new("UICorner")
uicorner222.Parent = frame221

-- Creating Frame
local frame223 = Instance.new("Frame")
frame223.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame223.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame223.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame223.Name = "Bar"
frame223.Parent = frame221

-- Creating UICorner
local uicorner224 = Instance.new("UICorner")
uicorner224.Parent = frame223

-- Creating TextButton
local textbutton225 = Instance.new("TextButton")
textbutton225.Text = "OFF"
textbutton225.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton225.Position = UDim2.new(0.5, 0, 0, 0)
textbutton225.Size = UDim2.new(0.5, 0, 1, 0)
textbutton225.Name = "ToggleButton"
textbutton225.Parent = frame223

-- Creating UICorner
local uicorner226 = Instance.new("UICorner")
uicorner226.Parent = textbutton225

-- Creating TextLabel
local textlabel227 = Instance.new("TextLabel")
textlabel227.RichText = true
textlabel227.Text = "Show Physics"
textlabel227.TextColor3 = Color3.new(1, 1, 1)
textlabel227.TextScaled = true
textlabel227.TextWrapped = true
textlabel227.BackgroundTransparency = 1
textlabel227.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel227.Name = "Label"
textlabel227.Parent = frame221

-- Creating Frame
local frame228 = Instance.new("Frame")
frame228.BackgroundColor3 = Color3.new(0, 0, 0)
frame228.Size = UDim2.new(1, 0, 0.05000000074505806, 0)
frame228.Name = "Frame2"
frame228.Parent = frame142

-- Creating UICorner
local uicorner229 = Instance.new("UICorner")
uicorner229.Parent = frame228

-- Creating Frame
local frame230 = Instance.new("Frame")
frame230.BackgroundColor3 = Color3.new(0.25882354378700256, 0.25882354378700256, 0.25882354378700256)
frame230.Position = UDim2.new(0.6000000238418579, 0, 0, 0)
frame230.Size = UDim2.new(0.4000000059604645, 0, 1, 0)
frame230.Name = "Bar"
frame230.Parent = frame228

-- Creating UICorner
local uicorner231 = Instance.new("UICorner")
uicorner231.Parent = frame230

-- Creating TextButton
local textbutton232 = Instance.new("TextButton")
textbutton232.Text = "OFF"
textbutton232.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton232.Position = UDim2.new(0.5, 0, 0, 0)
textbutton232.Size = UDim2.new(0.5, 0, 1, 0)
textbutton232.Name = "ToggleButton"
textbutton232.Parent = frame230

-- Creating UICorner
local uicorner233 = Instance.new("UICorner")
uicorner233.Parent = textbutton232

-- Creating TextLabel
local textlabel234 = Instance.new("TextLabel")
textlabel234.RichText = true
textlabel234.Text = "Global Physics"
textlabel234.TextColor3 = Color3.new(1, 1, 1)
textlabel234.TextScaled = true
textlabel234.TextWrapped = true
textlabel234.BackgroundTransparency = 1
textlabel234.Size = UDim2.new(0.6000000238418579, 0, 1, 0)
textlabel234.Name = "Label"
textlabel234.Parent = frame228

-- Creating Frame
local frame235 = Instance.new("Frame")
frame235.BackgroundColor3 = Color3.new(0.07058823853731155, 0.07058823853731155, 0.08235294371843338)
frame235.BackgroundTransparency = 0.5
frame235.Position = UDim2.new(-1.600000023841858, 0, 0, 0)
frame235.Size = UDim2.new(0.800000011920929, 0, 1, 0)
frame235.Visible = false
frame235.Name = "Inner2_Background"
frame235.Parent = frame64

-- Creating UICorner
local uicorner236 = Instance.new("UICorner")
uicorner236.Parent = frame235

-- Creating Frame
local frame237 = Instance.new("Frame")
frame237.BackgroundColor3 = Color3.new(0, 0, 0)
frame237.BackgroundTransparency = 0.5
frame237.Position = UDim2.new(0.019999999552965164, 0, 0.019999999552965164, 0)
frame237.Size = UDim2.new(0.9599999785423279, 0, 0.9599999785423279, 0)
frame237.Name = "Toggles"
frame237.Parent = frame235

-- Creating UICorner
local uicorner238 = Instance.new("UICorner")
uicorner238.Parent = frame237

-- Creating Frame
local frame239 = Instance.new("Frame")
frame239.BackgroundTransparency = 1
frame239.Position = UDim2.new(0.019999999552965164, 0, 0.019999999552965164, 0)
frame239.Size = UDim2.new(0.9599999785423279, 0, 0.9599999785423279, 0)
frame239.Name = "B_Frame"
frame239.Parent = frame237

-- Creating UIListLayout
local uilistlayout240 = Instance.new("UIListLayout")
uilistlayout240.Parent = frame239

-- Creating Frame
local frame241 = Instance.new("Frame")
frame241.BackgroundColor3 = Color3.new(0.07058823853731155, 0.07058823853731155, 0.08235294371843338)
frame241.BackgroundTransparency = 0.5
frame241.Position = UDim2.new(0.30000001192092896, 0, 0.699999988079071, 0)
frame241.Size = UDim2.new(0.4000000059604645, 0, 0.20000000298023224, 0)
frame241.Visible = false
frame241.Name = "Load_Background"
frame241.Parent = screengui2

-- Creating UICorner
local uicorner242 = Instance.new("UICorner")
uicorner242.Parent = frame241

-- Creating UIStroke
local uistroke243 = Instance.new("UIStroke")
uistroke243.Color = Color3.new(1, 1, 1)
uistroke243.Parent = frame241

-- Creating Frame
local frame244 = Instance.new("Frame")
frame244.BackgroundColor3 = Color3.new(1, 1, 1)
frame244.Position = UDim2.new(0.019999999552965164, 0, 0.23000000417232513, 0)
frame244.Size = UDim2.new(0.9599999785423279, 0, 0, 1)
frame244.Name = "Line"
frame244.Parent = frame241

-- Creating UICorner
local uicorner245 = Instance.new("UICorner")
uicorner245.Parent = frame244

-- Creating TextLabel
local textlabel246 = Instance.new("TextLabel")
textlabel246.Text = "Loading"
textlabel246.TextColor3 = Color3.new(1, 1, 1)
textlabel246.TextSize = 20
textlabel246.BackgroundTransparency = 1
textlabel246.Position = UDim2.new(0.019999999552965164, 0, 0.019999999552965164, 0)
textlabel246.Size = UDim2.new(0.9599999785423279, 0, 0.20000000298023224, 0)
textlabel246.Name = "Loading"
textlabel246.Parent = frame241

-- Creating TextLabel
local textlabel247 = Instance.new("TextLabel")
textlabel247.Text = "Starting ExperienceSettings. Please wait..."
textlabel247.TextColor3 = Color3.new(1, 1, 1)
textlabel247.TextScaled = true
textlabel247.TextWrapped = true
textlabel247.BackgroundTransparency = 1
textlabel247.Position = UDim2.new(0.019999999552965164, 0, 0.25, 0)
textlabel247.Size = UDim2.new(0.9599999785423279, 0, 0.3499999940395355, 0)
textlabel247.Name = "Wait"
textlabel247.Parent = frame241

-- Creating TextLabel
local textlabel248 = Instance.new("TextLabel")
textlabel248.Text = "Creator by @5teve3019D on ScriptBlox/HaxHell"
textlabel248.TextColor3 = Color3.new(1, 1, 1)
textlabel248.TextScaled = true
textlabel248.TextWrapped = true
textlabel248.BackgroundTransparency = 1
textlabel248.Position = UDim2.new(0.019999999552965164, 0, 0.6499999761581421, 0)
textlabel248.Size = UDim2.new(0.9599999785423279, 0, 0.12999999523162842, 0)
textlabel248.Name = "Credit"
textlabel248.Parent = frame241

-- Creating TextButton
local textbutton249 = Instance.new("TextButton")
textbutton249.Text = "Close fuc#king annoying load bar"
textbutton249.TextColor3 = Color3.new(1, 1, 1)
textbutton249.TextScaled = true
textbutton249.TextWrapped = true
textbutton249.BackgroundColor3 = Color3.new(1, 1, 1)
textbutton249.BackgroundTransparency = 0.800000011920929
textbutton249.Position = UDim2.new(0.019999999552965164, 0, 0.8500000238418579, 0)
textbutton249.Size = UDim2.new(0.9599999785423279, 0, 0.10000000149011612, 0)
textbutton249.Name = "Skip"
textbutton249.Parent = frame241

-- Creating UICorner
local uicorner250 = Instance.new("UICorner")
uicorner250.Parent = textbutton249

-- Creating UIStroke
local uistroke251 = Instance.new("UIStroke")
uistroke251.Color = Color3.new(1, 1, 1)
uistroke251.Parent = textbutton249

-- Creating Frame
local frame252 = Instance.new("Frame")
frame252.BackgroundColor3 = Color3.new(1, 1, 1)
frame252.BackgroundTransparency = 0.800000011920929
frame252.Size = UDim2.new(1, 0, 1, 0)
frame252.Name = "Loader"
frame252.Parent = textbutton249

-- Creating UICorner
local uicorner253 = Instance.new("UICorner")
uicorner253.Parent = frame252

-- Creating Frame
local frame254 = Instance.new("Frame")
frame254.BackgroundColor3 = Color3.new(0.07058823853731155, 0.07058823853731155, 0.08235294371843338)
frame254.BackgroundTransparency = 0.30000001192092896
frame254.Position = UDim2.new(0.25, 0, 1, 0)
frame254.Size = UDim2.new(0.5, 0, 0.699999988079071, 0)
frame254.Name = "About_Background"
frame254.Parent = screengui2

-- Creating UICorner
local uicorner255 = Instance.new("UICorner")
uicorner255.Parent = frame254

-- Creating UIStroke
local uistroke256 = Instance.new("UIStroke")
uistroke256.Color = Color3.new(1, 1, 1)
uistroke256.Parent = frame254

-- Creating Frame
local frame257 = Instance.new("Frame")
frame257.BackgroundTransparency = 1
frame257.Position = UDim2.new(0.019999999552965164, 0, 0.019999999552965164, 0)
frame257.Size = UDim2.new(0.9599999785423279, 0, 0.9599999785423279, 0)
frame257.Name = "Inside"
frame257.Parent = frame254

-- Creating TextBox
local textbox258 = Instance.new("TextBox")
textbox258.ClearTextOnFocus = false
textbox258.Text = "https://discord.gg/nFz3ypxUMA"
textbox258.TextColor3 = Color3.new(1, 1, 1)
textbox258.TextScaled = true
textbox258.TextWrapped = true
textbox258.BackgroundTransparency = 1
textbox258.Position = UDim2.new(0.6499999761581421, 0, 0, 0)
textbox258.Size = UDim2.new(0.3400000035762787, 0, 0, 20)
textbox258.Name = "Discord link"
textbox258.Parent = frame257

-- Creating UICorner
local uicorner259 = Instance.new("UICorner")
uicorner259.Parent = textbox258

-- Creating UIStroke
local uistroke260 = Instance.new("UIStroke")
uistroke260.Color = Color3.new(1, 1, 1)
uistroke260.Parent = textbox258

-- Creating Frame
local frame261 = Instance.new("Frame")
frame261.BackgroundTransparency = 1
frame261.Size = UDim2.new(1, 0, 0, 100)
frame261.Name = "Inside.2"
frame261.Parent = frame257

-- Creating UIListLayout
local uilistlayout262 = Instance.new("UIListLayout")
uilistlayout262.Parent = frame261

-- Creating ImageLabel
local imagelabel263 = Instance.new("ImageLabel")
imagelabel263.Image = "rbxassetid://117799080288721"
imagelabel263.BackgroundTransparency = 0.30000001192092896
imagelabel263.Size = UDim2.new(0, 100, 0, 100)
imagelabel263.Name = "a1_Icon"
imagelabel263.Parent = frame261

-- Creating UICorner
local uicorner264 = Instance.new("UICorner")
uicorner264.Parent = imagelabel263

-- Creating Frame
local frame265 = Instance.new("Frame")
frame265.BackgroundTransparency = 1
frame265.Size = UDim2.new(0.5, 0, 0, 40)
frame265.Name = "a2_txts"
frame265.Parent = frame261

-- Creating TextLabel
local textlabel266 = Instance.new("TextLabel")
textlabel266.Text = "@5teve3019D"
textlabel266.TextColor3 = Color3.new(1, 1, 1)
textlabel266.TextScaled = true
textlabel266.TextWrapped = true
textlabel266.BackgroundTransparency = 1
textlabel266.Size = UDim2.new(1, 0, 0, 40)
textlabel266.Name = "Name"
textlabel266.Parent = frame265

-- Creating TextLabel
local textlabel267 = Instance.new("TextLabel")
textlabel267.Text = "“Creator of the ExperiencSettings.”"
textlabel267.TextColor3 = Color3.new(1, 1, 1)
textlabel267.TextScaled = true
textlabel267.TextWrapped = true
textlabel267.BackgroundTransparency = 1
textlabel267.Position = UDim2.new(0, 0, 0, 36)
textlabel267.Size = UDim2.new(1, 0, 0, 35)
textlabel267.Name = "Name"
textlabel267.Parent = frame265

-- Creating TextLabel
local textlabel268 = Instance.new("TextLabel")
textlabel268.Text = "[ User on ScriptBlox/HaxHell ]"
textlabel268.TextColor3 = Color3.new(1, 1, 1)
textlabel268.TextScaled = true
textlabel268.TextWrapped = true
textlabel268.BackgroundTransparency = 1
textlabel268.Position = UDim2.new(0, 0, 0, 70)
textlabel268.Size = UDim2.new(1, 0, 0, 15)
textlabel268.Name = "Name"
textlabel268.Parent = frame265

-- Creating ScrollingFrame
local scrollingframe269 = Instance.new("ScrollingFrame")
scrollingframe269.BackgroundTransparency = 1
scrollingframe269.Position = UDim2.new(0, 0, 0.25999999046325684, 0)
scrollingframe269.Size = UDim2.new(1, 0, 0.6000000238418579, 0)
scrollingframe269.Name = "Scroll"
scrollingframe269.Parent = frame257

-- Creating UIStroke
local uistroke270 = Instance.new("UIStroke")
uistroke270.Color = Color3.new(1, 1, 1)
uistroke270.Transparency = 0.5
uistroke270.Parent = scrollingframe269

-- Creating TextLabel
local textlabel271 = Instance.new("TextLabel")
textlabel271.Text = "The ExperienceSettings is debug tools you can use on your own, there are a lot of tools!\nFor HealthBar was a remake of better and smoother and ValueLabels for show values.\nIf your ExperienceSettings was Disabled there are three reasons,\n • HumanoidRootPart was removed too long.\n • The Experience doesn't support the ExperienceSettings.\n • Script failed to load.\nIf you enjoy it, you can support me on discord!\nThank you for using ExperienceSettings! ♥️\n\n54% Gui is made by hand\n10% Script is made by hand\n36% Script is made by ai\n\nCreator: @5teve3019D (Gui, Little Script)\nHelper: ChatGPT (Script) <-- He got a lot of complaints lol.\nLittle Helper: Copilot of GitHub (Script)\nFun fact: Old is ugly than now lol I swear 😂 Oh, you haven't seen it :(\n\n========================\n➕ = Add something\n📢 = Announcements\n🔨 = In-develop\n🔷 = Plan ahead for updates\n✅ = Done\n⚠️ = Have issues\n🟠 = Updating soon\n❌ = Bug\n⚫ = Cannot fix\n➖ = Disconnected or discontinued\n-------\n📌 Updated: Update in this information is no longer appear now, please join our discord community to following update!\n-------\n🔁 In progress: No longer appear features\n-------\n❌ Failed: No longer appear unavailable features\n-------\n\n✨ SCRIPT CREDITS ✨\n[ Script Name ] by [ Creator ] [ Verification Status ]\n\nWe want to say that your script is awesome, and it is used in our project for debugging and educational purposes.\nThank you for your contribution :3 ❤️\n- Debugger\n\n-- Credits List --\n'Ketamine' by @Cherry (✓ Verified)\n'OG AFEM – Legacy' by @Imperial (✓ Verified)\n'Chat' by Unknown user\n'UNC' by Unknown user\n'REM' by @evildotcom (X Not verified)\n'GameProber' by @Imperial (✓ Verified)\n'AudioPlayer' by Unknown user\n'EmoteSelect' by Unknown user\n'Universal Movement Predictor' by @zephyrr (X Not verified)\n'Server Position Predictor' by @zephyrr (X Not verified)\n'Open Source Universal Chat' by @neutral (X Not verified)\n\n-- Notice to Script Creators --\nIf you are a script creator listed above and do not want your script to be included,\nplease contact us via our Discord forum, and we will remove it immediately."
textlabel271.TextColor3 = Color3.new(1, 1, 1)
textlabel271.BackgroundTransparency = 1
textlabel271.Size = UDim2.new(1, 0, 1, 0)
textlabel271.Name = "About"
textlabel271.Parent = scrollingframe269

-- Creating TextLabel
local textlabel272 = Instance.new("TextLabel")
textlabel272.Text = "Oh, if the ExperienceSettings was disabled. You can hide the text by click the button."
textlabel272.TextColor3 = Color3.new(1, 1, 1)
textlabel272.TextScaled = true
textlabel272.TextWrapped = true
textlabel272.BackgroundTransparency = 1
textlabel272.Position = UDim2.new(0, 0, 0.8799999952316284, 0)
textlabel272.Size = UDim2.new(0.800000011920929, 0, 0, 30)
textlabel272.Name = "Help"
textlabel272.Parent = frame257

-- Creating TextButton
local textbutton273 = Instance.new("TextButton")
textbutton273.Text = "Hide"
textbutton273.TextColor3 = Color3.new(1, 1, 1)
textbutton273.TextScaled = true
textbutton273.TextTransparency = 0.6000000238418579
textbutton273.TextWrapped = true
textbutton273.AutoButtonColor = false
textbutton273.Active = false
textbutton273.BackgroundTransparency = 1
textbutton273.Position = UDim2.new(0.800000011920929, 0, 0.8799999952316284, 0)
textbutton273.Size = UDim2.new(0.20000000298023224, 0, 0, 30)
textbutton273.Name = "Hide"
textbutton273.Parent = frame257

-- Creating UICorner
local uicorner274 = Instance.new("UICorner")
uicorner274.Parent = textbutton273

-- Creating UIStroke
local uistroke275 = Instance.new("UIStroke")
uistroke275.Color = Color3.new(1, 1, 1)
uistroke275.Parent = textbutton273

-- Creating Frame
local frame276 = Instance.new("Frame")
frame276.BackgroundColor3 = Color3.new(0.07058823853731155, 0.07058823853731155, 0.08235294371843338)
frame276.BackgroundTransparency = 1
frame276.Size = UDim2.new(1, 0, 1, 0)
frame276.Name = "MiddleScreen"
frame276.Parent = screengui2

-- Creating UIListLayout
local uilistlayout277 = Instance.new("UIListLayout")
uilistlayout277.Parent = frame276

-- Creating ImageLabel
local imagelabel278 = Instance.new("ImageLabel")
imagelabel278.Image = "rbxassetid://111897588899496"
imagelabel278.AnchorPoint = Vector2.new(0.5, 0.5)
imagelabel278.BackgroundTransparency = 1
imagelabel278.Position = UDim2.new(0.5, 0, 0.5, 0)
imagelabel278.Size = UDim2.new(0, 50, 0, 50)
imagelabel278.Visible = false
imagelabel278.Name = "TargetShift"
imagelabel278.Parent = frame276

-- Creating Frame
local frame279 = Instance.new("Frame")
frame279.BackgroundTransparency = 1
frame279.Position = UDim2.new(0, 0, 0.10000000149011612, 0)
frame279.Size = UDim2.new(1, 0, 0.8999999761581421, 0)
frame279.Name = "HolderScreen"
frame279.Parent = screengui2

-- Creating Frame
local frame280 = Instance.new("Frame")
frame280.BackgroundColor3 = Color3.new(0.07058823853731155, 0.07058823853731155, 0.08235294371843338)
frame280.BackgroundTransparency = 0.07999999821186066
frame280.Position = UDim2.new(0, 0, 0, 250)
frame280.Size = UDim2.new(0, 90, 0, 43)
frame280.Visible = false
frame280.Name = "Shift_Lock"
frame280.Parent = frame279

-- Creating UICorner
local uicorner281 = Instance.new("UICorner")
uicorner281.Parent = frame280

-- Creating UIListLayout
local uilistlayout282 = Instance.new("UIListLayout")
uilistlayout282.Parent = frame280

-- Creating ImageButton
local imagebutton283 = Instance.new("ImageButton")
imagebutton283.Image = "rbxassetid://137719322669506"
imagebutton283.AutoButtonColor = false
imagebutton283.BackgroundColor3 = Color3.new(1, 1, 1)
imagebutton283.BackgroundTransparency = 1
imagebutton283.Size = UDim2.new(0, 34, 0.800000011920929, 0)
imagebutton283.Name = "a1_Shift"
imagebutton283.Parent = frame280

-- Creating UICorner
local uicorner284 = Instance.new("UICorner")
uicorner284.Parent = imagebutton283

-- Creating UIStroke
local uistroke285 = Instance.new("UIStroke")
uistroke285.Color = Color3.new(1, 1, 1)
uistroke285.Thickness = 0
uistroke285.Parent = imagebutton283

-- Creating ImageButton
local imagebutton286 = Instance.new("ImageButton")
imagebutton286.Image = "rbxassetid://99025662889813"
imagebutton286.AutoButtonColor = false
imagebutton286.BackgroundTransparency = 1
imagebutton286.Size = UDim2.new(0, 35, 0, 35)
imagebutton286.Name = "a3_Dragger"
imagebutton286.Parent = frame280

-- Creating UICorner
local uicorner287 = Instance.new("UICorner")
uicorner287.Parent = imagebutton286

-- Creating ImageButton
local imagebutton288 = Instance.new("ImageButton")
imagebutton288.Image = "rbxassetid://74510217089631"
imagebutton288.AutoButtonColor = false
imagebutton288.BackgroundColor3 = Color3.new(1, 1, 1)
imagebutton288.BackgroundTransparency = 1
imagebutton288.Size = UDim2.new(0, 34, 0.800000011920929, 0)
imagebutton288.Visible = false
imagebutton288.Name = "a2_Aim"
imagebutton288.Parent = frame280

-- Creating UICorner
local uicorner289 = Instance.new("UICorner")
uicorner289.Parent = imagebutton288

-- Creating UIStroke
local uistroke290 = Instance.new("UIStroke")
uistroke290.Color = Color3.new(1, 1, 1)
uistroke290.Thickness = 0
uistroke290.Parent = imagebutton288

-- Creating Frame
local frame291 = Instance.new("Frame")
frame291.BackgroundColor3 = Color3.new(0.07058823853731155, 0.07058823853731155, 0.08235294371843338)
frame291.BackgroundTransparency = 0.30000001192092896
frame291.Position = UDim2.new(0.25, 0, 1, 0)
frame291.Size = UDim2.new(0.5, 0, 0.699999988079071, 0)
frame291.Name = "ProfileStatus"
frame291.Parent = screengui2

-- Creating UICorner
local uicorner292 = Instance.new("UICorner")
uicorner292.Parent = frame291

-- Creating UIStroke
local uistroke293 = Instance.new("UIStroke")
uistroke293.Color = Color3.new(1, 1, 1)
uistroke293.Parent = frame291

-- Creating UIListLayout
local uilistlayout294 = Instance.new("UIListLayout")
uilistlayout294.Parent = frame291

-- Creating Frame
local frame295 = Instance.new("Frame")
frame295.BackgroundTransparency = 1
frame295.Size = UDim2.new(0.9800000190734863, 0, 0.9599999785423279, 0)
frame295.Name = "InsideProfileStatus"
frame295.Parent = frame291

-- Creating Frame
local frame296 = Instance.new("Frame")
frame296.BackgroundTransparency = 1
frame296.Size = UDim2.new(0.5, 0, 1, 0)
frame296.Name = "ProfileCharacter"
frame296.Parent = frame295

-- Creating Frame
local frame297 = Instance.new("Frame")
frame297.BackgroundTransparency = 1
frame297.Size = UDim2.new(1, 0, 0.20000000298023224, 0)
frame297.Name = "Holder"
frame297.Parent = frame296

-- Creating ImageLabel
local imagelabel298 = Instance.new("ImageLabel")
imagelabel298.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=2535650316&width=150&height=150&format=Png"
imagelabel298.BackgroundTransparency = 0.800000011920929
imagelabel298.Size = UDim2.new(0, 80, 0, 80)
imagelabel298.Name = "Profile"
imagelabel298.Parent = frame297

-- Creating UICorner
local uicorner299 = Instance.new("UICorner")
uicorner299.Parent = imagelabel298

-- Creating TextLabel
local textlabel300 = Instance.new("TextLabel")
textlabel300.Text = "White (@5teve3019D)"
textlabel300.TextColor3 = Color3.new(1, 1, 1)
textlabel300.TextScaled = true
textlabel300.TextWrapped = true
textlabel300.BackgroundTransparency = 1
textlabel300.Position = UDim2.new(0, 82, 0, 0)
textlabel300.Size = UDim2.new(0.800000011920929, 0, 0.30000001192092896, 0)
textlabel300.Name = "Username"
textlabel300.Parent = frame297

-- Creating ScrollingFrame
local scrollingframe301 = Instance.new("ScrollingFrame")
scrollingframe301.CanvasSize = UDim2.new(0, 0, 5000, 0)
scrollingframe301.ScrollBarThickness = 0
scrollingframe301.BackgroundTransparency = 1
scrollingframe301.Position = UDim2.new(0, 0, 0.20999999344348907, 0)
scrollingframe301.Size = UDim2.new(1, 0, 0.7900000214576721, 0)
scrollingframe301.Name = "Scroll"
scrollingframe301.Parent = frame296

-- Creating UIListLayout
local uilistlayout302 = Instance.new("UIListLayout")
uilistlayout302.Parent = scrollingframe301

-- Creating Frame
local frame303 = Instance.new("Frame")
frame303.BackgroundTransparency = 1
frame303.Size = UDim2.new(1, 0, 0, 0)
frame303.Name = "There's nothing woof!"
frame303.Parent = scrollingframe301

-- Creating TextLabel
local textlabel304 = Instance.new("TextLabel")
textlabel304.Text = "It might have bug and it still in beta."
textlabel304.TextColor3 = Color3.new(1, 0.5137255191802979, 0.5137255191802979)
textlabel304.TextScaled = true
textlabel304.TextWrapped = true
textlabel304.BackgroundTransparency = 1
textlabel304.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textlabel304.Name = "Beta"
textlabel304.Parent = scrollingframe301

-- Creating UICorner
local uicorner305 = Instance.new("UICorner")
uicorner305.Parent = textlabel304

-- Creating UIStroke
local uistroke306 = Instance.new("UIStroke")
uistroke306.Color = Color3.new(1, 0, 0)
uistroke306.Parent = textlabel304

-- Creating TextButton
local textbutton307 = Instance.new("TextButton")
textbutton307.Text = "PlayerID: 2535650316"
textbutton307.TextColor3 = Color3.new(1, 1, 1)
textbutton307.TextScaled = true
textbutton307.TextWrapped = true
textbutton307.BackgroundTransparency = 1
textbutton307.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textbutton307.Name = "PlayerID"
textbutton307.Parent = scrollingframe301

-- Creating UICorner
local uicorner308 = Instance.new("UICorner")
uicorner308.Parent = textbutton307

-- Creating UIStroke
local uistroke309 = Instance.new("UIStroke")
uistroke309.Color = Color3.new(0.7058823704719543, 0.7058823704719543, 1)
uistroke309.Parent = textbutton307

-- Creating TextButton
local textbutton310 = Instance.new("TextButton")
textbutton310.Text = "PlayerAge: 1894 day"
textbutton310.TextColor3 = Color3.new(1, 1, 1)
textbutton310.TextScaled = true
textbutton310.TextWrapped = true
textbutton310.BackgroundTransparency = 1
textbutton310.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textbutton310.Name = "PlayerAge"
textbutton310.Parent = scrollingframe301

-- Creating UICorner
local uicorner311 = Instance.new("UICorner")
uicorner311.Parent = textbutton310

-- Creating UIStroke
local uistroke312 = Instance.new("UIStroke")
uistroke312.Color = Color3.new(0.7843137383460999, 0.7843137383460999, 1)
uistroke312.Parent = textbutton310

-- Creating TextButton
local textbutton313 = Instance.new("TextButton")
textbutton313.Text = "PlayerBirth: 27/04/2021"
textbutton313.TextColor3 = Color3.new(1, 1, 1)
textbutton313.TextScaled = true
textbutton313.TextWrapped = true
textbutton313.BackgroundTransparency = 1
textbutton313.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textbutton313.Name = "PlayerBirth"
textbutton313.Parent = scrollingframe301

-- Creating UICorner
local uicorner314 = Instance.new("UICorner")
uicorner314.Parent = textbutton313

-- Creating UIStroke
local uistroke315 = Instance.new("UIStroke")
uistroke315.Color = Color3.new(0.7843137383460999, 1, 0.7843137383460999)
uistroke315.Parent = textbutton313

-- Creating TextLabel
local textlabel316 = Instance.new("TextLabel")
textlabel316.Text = "CameraMode: Enum.CameraMode.Classic"
textlabel316.TextColor3 = Color3.new(1, 1, 1)
textlabel316.TextScaled = true
textlabel316.TextWrapped = true
textlabel316.BackgroundTransparency = 1
textlabel316.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textlabel316.Name = "CameraMode"
textlabel316.Parent = scrollingframe301

-- Creating UICorner
local uicorner317 = Instance.new("UICorner")
uicorner317.Parent = textlabel316

-- Creating UIStroke
local uistroke318 = Instance.new("UIStroke")
uistroke318.Color = Color3.new(1, 1, 1)
uistroke318.Parent = textlabel316

-- Creating TextButton
local textbutton319 = Instance.new("TextButton")
textbutton319.Text = "PlaceID: 230362888"
textbutton319.TextColor3 = Color3.new(1, 1, 1)
textbutton319.TextScaled = true
textbutton319.TextWrapped = true
textbutton319.BackgroundTransparency = 1
textbutton319.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textbutton319.Name = "PlaceID"
textbutton319.Parent = scrollingframe301

-- Creating UICorner
local uicorner320 = Instance.new("UICorner")
uicorner320.Parent = textbutton319

-- Creating UIStroke
local uistroke321 = Instance.new("UIStroke")
uistroke321.Color = Color3.new(0.7058823704719543, 0.7058823704719543, 1)
uistroke321.Parent = textbutton319

-- Creating TextButton
local textbutton322 = Instance.new("TextButton")
textbutton322.Text = "Creator: NowDoTheHarlemShake"
textbutton322.TextColor3 = Color3.new(1, 1, 1)
textbutton322.TextScaled = true
textbutton322.TextWrapped = true
textbutton322.BackgroundTransparency = 1
textbutton322.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textbutton322.Name = "CreatorName"
textbutton322.Parent = scrollingframe301

-- Creating UICorner
local uicorner323 = Instance.new("UICorner")
uicorner323.Parent = textbutton322

-- Creating UIStroke
local uistroke324 = Instance.new("UIStroke")
uistroke324.Color = Color3.new(1, 0.8627451062202454, 0.5882353186607361)
uistroke324.Parent = textbutton322

-- Creating TextButton
local textbutton325 = Instance.new("TextButton")
textbutton325.Text = "CreatorID: 38506985"
textbutton325.TextColor3 = Color3.new(1, 1, 1)
textbutton325.TextScaled = true
textbutton325.TextWrapped = true
textbutton325.BackgroundTransparency = 1
textbutton325.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textbutton325.Name = "CreatorID"
textbutton325.Parent = scrollingframe301

-- Creating UICorner
local uicorner326 = Instance.new("UICorner")
uicorner326.Parent = textbutton325

-- Creating UIStroke
local uistroke327 = Instance.new("UIStroke")
uistroke327.Color = Color3.new(1, 0.7843137383460999, 0.7843137383460999)
uistroke327.Parent = textbutton325

-- Creating TextLabel
local textlabel328 = Instance.new("TextLabel")
textlabel328.Text = "AFK: 00:00 | LastAFK: 00:01"
textlabel328.TextColor3 = Color3.new(1, 1, 1)
textlabel328.TextScaled = true
textlabel328.TextWrapped = true
textlabel328.BackgroundTransparency = 1
textlabel328.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textlabel328.Name = "AFK"
textlabel328.Parent = scrollingframe301

-- Creating UICorner
local uicorner329 = Instance.new("UICorner")
uicorner329.Parent = textlabel328

-- Creating UIStroke
local uistroke330 = Instance.new("UIStroke")
uistroke330.Color = Color3.new(1, 1, 1)
uistroke330.Parent = textlabel328

-- Creating TextLabel
local textlabel331 = Instance.new("TextLabel")
textlabel331.Text = "PlayingTime: 000:00:00:41"
textlabel331.TextColor3 = Color3.new(0.7843137383460999, 0.8627451062202454, 1)
textlabel331.TextScaled = true
textlabel331.TextWrapped = true
textlabel331.BackgroundTransparency = 1
textlabel331.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textlabel331.Name = "PlayingTime"
textlabel331.Parent = scrollingframe301

-- Creating UICorner
local uicorner332 = Instance.new("UICorner")
uicorner332.Parent = textlabel331

-- Creating UIStroke
local uistroke333 = Instance.new("UIStroke")
uistroke333.Color = Color3.new(0.7843137383460999, 0.8627451062202454, 1)
uistroke333.Parent = textlabel331

-- Creating TextLabel
local textlabel334 = Instance.new("TextLabel")
textlabel334.Text = "WalkSpeed: 16"
textlabel334.TextColor3 = Color3.new(0.6274510025978088, 0.7843137383460999, 1)
textlabel334.TextScaled = true
textlabel334.TextWrapped = true
textlabel334.BackgroundTransparency = 1
textlabel334.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textlabel334.Name = "WalkSpeed"
textlabel334.Parent = scrollingframe301

-- Creating UICorner
local uicorner335 = Instance.new("UICorner")
uicorner335.Parent = textlabel334

-- Creating UIStroke
local uistroke336 = Instance.new("UIStroke")
uistroke336.Color = Color3.new(0.6274510025978088, 0.7843137383460999, 1)
uistroke336.Parent = textlabel334

-- Creating TextLabel
local textlabel337 = Instance.new("TextLabel")
textlabel337.Text = "JumpPower: 50"
textlabel337.TextColor3 = Color3.new(1, 0.5882353186607361, 0.5882353186607361)
textlabel337.TextScaled = true
textlabel337.TextWrapped = true
textlabel337.BackgroundTransparency = 1
textlabel337.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textlabel337.Name = "JumpPower"
textlabel337.Parent = scrollingframe301

-- Creating UICorner
local uicorner338 = Instance.new("UICorner")
uicorner338.Parent = textlabel337

-- Creating UIStroke
local uistroke339 = Instance.new("UIStroke")
uistroke339.Color = Color3.new(1, 0.5882353186607361, 0.5882353186607361)
uistroke339.Parent = textlabel337

-- Creating TextLabel
local textlabel340 = Instance.new("TextLabel")
textlabel340.Text = "BestDamage: 0 | LastDamage: 0"
textlabel340.TextColor3 = Color3.new(1, 0.3137255012989044, 0.3137255012989044)
textlabel340.TextScaled = true
textlabel340.TextWrapped = true
textlabel340.BackgroundTransparency = 1
textlabel340.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textlabel340.Name = "Damage"
textlabel340.Parent = scrollingframe301

-- Creating UICorner
local uicorner341 = Instance.new("UICorner")
uicorner341.Parent = textlabel340

-- Creating UIStroke
local uistroke342 = Instance.new("UIStroke")
uistroke342.Color = Color3.new(1, 0.3137255012989044, 0.3137255012989044)
uistroke342.Parent = textlabel340

-- Creating TextLabel
local textlabel343 = Instance.new("TextLabel")
textlabel343.Text = "BestHeal: 0 | LastHeal: 0"
textlabel343.TextColor3 = Color3.new(0.3137255012989044, 1, 0.47058823704719543)
textlabel343.TextScaled = true
textlabel343.TextWrapped = true
textlabel343.BackgroundTransparency = 1
textlabel343.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textlabel343.Name = "Heal"
textlabel343.Parent = scrollingframe301

-- Creating UICorner
local uicorner344 = Instance.new("UICorner")
uicorner344.Parent = textlabel343

-- Creating UIStroke
local uistroke345 = Instance.new("UIStroke")
uistroke345.Color = Color3.new(0.3137255012989044, 1, 0.47058823704719543)
uistroke345.Parent = textlabel343

-- Creating TextLabel
local textlabel346 = Instance.new("TextLabel")
textlabel346.Text = "Deaths: 0"
textlabel346.TextColor3 = Color3.new(1, 0.3137255012989044, 0.3137255012989044)
textlabel346.TextScaled = true
textlabel346.TextWrapped = true
textlabel346.BackgroundTransparency = 1
textlabel346.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textlabel346.Name = "Deaths"
textlabel346.Parent = scrollingframe301

-- Creating UICorner
local uicorner347 = Instance.new("UICorner")
uicorner347.Parent = textlabel346

-- Creating UIStroke
local uistroke348 = Instance.new("UIStroke")
uistroke348.Color = Color3.new(1, 0.3137255012989044, 0.3137255012989044)
uistroke348.Parent = textlabel346

-- Creating TextLabel
local textlabel349 = Instance.new("TextLabel")
textlabel349.Text = "Tools: 0"
textlabel349.TextColor3 = Color3.new(1, 1, 1)
textlabel349.TextScaled = true
textlabel349.TextWrapped = true
textlabel349.BackgroundTransparency = 1
textlabel349.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textlabel349.Name = "Inventory"
textlabel349.Parent = scrollingframe301

-- Creating UICorner
local uicorner350 = Instance.new("UICorner")
uicorner350.Parent = textlabel349

-- Creating UIStroke
local uistroke351 = Instance.new("UIStroke")
uistroke351.Color = Color3.new(1, 1, 1)
uistroke351.Parent = textlabel349

-- Creating TextLabel
local textlabel352 = Instance.new("TextLabel")
textlabel352.Text = "HoldingTool: none"
textlabel352.TextColor3 = Color3.new(1, 1, 1)
textlabel352.TextScaled = true
textlabel352.TextWrapped = true
textlabel352.BackgroundTransparency = 1
textlabel352.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textlabel352.Name = "HoldingTool"
textlabel352.Parent = scrollingframe301

-- Creating UICorner
local uicorner353 = Instance.new("UICorner")
uicorner353.Parent = textlabel352

-- Creating UIStroke
local uistroke354 = Instance.new("UIStroke")
uistroke354.Color = Color3.new(1, 1, 1)
uistroke354.Parent = textlabel352

-- Creating TextLabel
local textlabel355 = Instance.new("TextLabel")
textlabel355.Text = "MaxHealth: 100"
textlabel355.TextColor3 = Color3.new(1, 0.3137255012989044, 0.3137255012989044)
textlabel355.TextScaled = true
textlabel355.TextWrapped = true
textlabel355.BackgroundTransparency = 1
textlabel355.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textlabel355.Name = "MaxHealth"
textlabel355.Parent = scrollingframe301

-- Creating UICorner
local uicorner356 = Instance.new("UICorner")
uicorner356.Parent = textlabel355

-- Creating UIStroke
local uistroke357 = Instance.new("UIStroke")
uistroke357.Color = Color3.new(1, 0.3137255012989044, 0.3137255012989044)
uistroke357.Parent = textlabel355

-- Creating TextLabel
local textlabel358 = Instance.new("TextLabel")
textlabel358.Text = "StandingOn: Fabric"
textlabel358.TextColor3 = Color3.new(0.3137255012989044, 1, 0.47058823704719543)
textlabel358.TextScaled = true
textlabel358.TextWrapped = true
textlabel358.BackgroundTransparency = 1
textlabel358.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textlabel358.Name = "StandingOn"
textlabel358.Parent = scrollingframe301

-- Creating UICorner
local uicorner359 = Instance.new("UICorner")
uicorner359.Parent = textlabel358

-- Creating UIStroke
local uistroke360 = Instance.new("UIStroke")
uistroke360.Color = Color3.new(0.3137255012989044, 1, 0.47058823704719543)
uistroke360.Parent = textlabel358

-- Creating TextButton
local textbutton361 = Instance.new("TextButton")
textbutton361.Text = "Position: X: -0.56 | Y: 3.75 | Z: -113.86"
textbutton361.TextColor3 = Color3.new(0.47058823704719543, 1, 1)
textbutton361.TextScaled = true
textbutton361.TextWrapped = true
textbutton361.BackgroundTransparency = 1
textbutton361.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textbutton361.Name = "PositionOfCharacter"
textbutton361.Parent = scrollingframe301

-- Creating UICorner
local uicorner362 = Instance.new("UICorner")
uicorner362.Parent = textbutton361

-- Creating UIStroke
local uistroke363 = Instance.new("UIStroke")
uistroke363.Color = Color3.new(0.47058823704719543, 1, 1)
uistroke363.Parent = textbutton361

-- Creating TextLabel
local textlabel364 = Instance.new("TextLabel")
textlabel364.Text = "CharacterType: R15"
textlabel364.TextColor3 = Color3.new(1, 1, 1)
textlabel364.TextScaled = true
textlabel364.TextWrapped = true
textlabel364.BackgroundTransparency = 1
textlabel364.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textlabel364.Name = "CharacterType"
textlabel364.Parent = scrollingframe301

-- Creating UICorner
local uicorner365 = Instance.new("UICorner")
uicorner365.Parent = textlabel364

-- Creating UIStroke
local uistroke366 = Instance.new("UIStroke")
uistroke366.Color = Color3.new(1, 1, 1)
uistroke366.Parent = textlabel364

-- Creating TextButton
local textbutton367 = Instance.new("TextButton")
textbutton367.Text = "TimeOfDay: 00:00:00"
textbutton367.TextColor3 = Color3.new(1, 0.9019607901573181, 0.47058823704719543)
textbutton367.TextScaled = true
textbutton367.TextWrapped = true
textbutton367.BackgroundTransparency = 1
textbutton367.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textbutton367.Name = "TimeOfDay"
textbutton367.Parent = scrollingframe301

-- Creating UICorner
local uicorner368 = Instance.new("UICorner")
uicorner368.Parent = textbutton367

-- Creating UIStroke
local uistroke369 = Instance.new("UIStroke")
uistroke369.Color = Color3.new(1, 0.9019607901573181, 0.47058823704719543)
uistroke369.Parent = textbutton367

-- Creating TextButton
local textbutton370 = Instance.new("TextButton")
textbutton370.Text = "Open Developer console"
textbutton370.TextColor3 = Color3.new(0.7058823704719543, 0.8627451062202454, 1)
textbutton370.TextScaled = true
textbutton370.TextWrapped = true
textbutton370.Active = false
textbutton370.BackgroundTransparency = 1
textbutton370.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textbutton370.Name = "DeveloperConsole"
textbutton370.Parent = scrollingframe301

-- Creating UICorner
local uicorner371 = Instance.new("UICorner")
uicorner371.Parent = textbutton370

-- Creating UIStroke
local uistroke372 = Instance.new("UIStroke")
uistroke372.Color = Color3.new(0.7058823704719543, 0.8627451062202454, 1)
uistroke372.Parent = textbutton370

-- Creating TextButton
local textbutton373 = Instance.new("TextButton")
textbutton373.Text = "Drop Tool"
textbutton373.TextColor3 = Color3.new(1, 1, 0)
textbutton373.TextScaled = true
textbutton373.TextWrapped = true
textbutton373.BackgroundTransparency = 1
textbutton373.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textbutton373.Name = "DropTool"
textbutton373.Parent = scrollingframe301

-- Creating UICorner
local uicorner374 = Instance.new("UICorner")
uicorner374.Parent = textbutton373

-- Creating UIStroke
local uistroke375 = Instance.new("UIStroke")
uistroke375.Color = Color3.new(1, 0.8627451062202454, 0.47058823704719543)
uistroke375.Parent = textbutton373

-- Creating TextButton
local textbutton376 = Instance.new("TextButton")
textbutton376.Text = "Drop all tools"
textbutton376.TextColor3 = Color3.new(1, 0.47058823704719543, 0.5882353186607361)
textbutton376.TextScaled = true
textbutton376.TextWrapped = true
textbutton376.BackgroundTransparency = 1
textbutton376.Size = UDim2.new(0.9900000095367432, 0, 0, 30)
textbutton376.Name = "DropTools"
textbutton376.Parent = scrollingframe301

-- Creating UICorner
local uicorner377 = Instance.new("UICorner")
uicorner377.Parent = textbutton376

-- Creating UIStroke
local uistroke378 = Instance.new("UIStroke")
uistroke378.Color = Color3.new(1, 0.3137255012989044, 0.3137255012989044)
uistroke378.Parent = textbutton376

-- Creating Frame
local frame379 = Instance.new("Frame")
frame379.BackgroundTransparency = 1
frame379.Position = UDim2.new(0.5, 0, 0, 0)
frame379.Size = UDim2.new(0.5, 0, 1, 0)
frame379.Name = "Debugs"
frame379.Parent = frame295

-- Creating Frame
local frame380 = Instance.new("Frame")
frame380.BackgroundColor3 = Color3.new(0.07058823853731155, 0.07058823853731155, 0.08235294371843338)
frame380.BackgroundTransparency = 0.30000001192092896
frame380.Position = UDim2.new(0.25, 0, 1, 0)
frame380.Size = UDim2.new(0.5, 0, 0.699999988079071, 0)
frame380.Name = "AIOpenSource"
frame380.Parent = screengui2

-- Creating UICorner
local uicorner381 = Instance.new("UICorner")
uicorner381.Parent = frame380

-- Creating UIStroke
local uistroke382 = Instance.new("UIStroke")
uistroke382.Color = Color3.new(1, 1, 1)
uistroke382.Parent = frame380

-- Creating Frame
local frame383 = Instance.new("Frame")
frame383.BackgroundTransparency = 1
frame383.Position = UDim2.new(0.019999999552965164, 0, 0.019999999552965164, 0)
frame383.Size = UDim2.new(0.9599999785423279, 0, 0.9599999785423279, 0)
frame383.Parent = frame380

-- Creating Frame
local frame384 = Instance.new("Frame")
frame384.BackgroundColor3 = Color3.new(1, 1, 1)
frame384.BackgroundTransparency = 0.800000011920929
frame384.Position = UDim2.new(0.029999999329447746, 0, 1, -40)
frame384.Size = UDim2.new(0.800000011920929, 0, 0, 40)
frame384.Name = "Text"
frame384.Parent = frame383

-- Creating UICorner
local uicorner385 = Instance.new("UICorner")
uicorner385.Parent = frame384

-- Creating UIStroke
local uistroke386 = Instance.new("UIStroke")
uistroke386.Color = Color3.new(1, 1, 1)
uistroke386.Parent = frame384

-- Creating TextBox
local textbox387 = Instance.new("TextBox")
textbox387.ClearTextOnFocus = false
textbox387.MultiLine = true
textbox387.PlaceholderText = "Type /Help to show all commands or Say something..."
textbox387.RichText = true
textbox387.Text = ""
textbox387.TextColor3 = Color3.new(1, 1, 1)
textbox387.TextScaled = true
textbox387.TextSize = 28
textbox387.TextWrapped = true
textbox387.BackgroundTransparency = 1
textbox387.Position = UDim2.new(0.019999999552965164, 0, 0.019999999552965164, 0)
textbox387.Size = UDim2.new(0.9649999737739563, 0, 0.9599999785423279, 0)
textbox387.Name = "chat"
textbox387.Parent = frame384

-- Creating TextButton
local textbutton388 = Instance.new("TextButton")
textbutton388.Text = "✓"
textbutton388.TextColor3 = Color3.new(1, 1, 1)
textbutton388.TextScaled = true
textbutton388.TextWrapped = true
textbutton388.BackgroundColor3 = Color3.new(0, 0.6666666865348816, 1)
textbutton388.BackgroundTransparency = 0.5
textbutton388.Position = UDim2.new(1, 6, 0.07999999821186066, 0)
textbutton388.Size = UDim2.new(0, 35, 0, 35)
textbutton388.Name = "Send"
textbutton388.Parent = frame384

-- Creating UIStroke
local uistroke389 = Instance.new("UIStroke")
uistroke389.Color = Color3.new(1, 1, 1)
uistroke389.Parent = textbutton388

-- Creating UICorner
local uicorner390 = Instance.new("UICorner")
uicorner390.Parent = textbutton388

-- Creating TextButton
local textbutton391 = Instance.new("TextButton")
textbutton391.Text = "X"
textbutton391.TextColor3 = Color3.new(1, 1, 1)
textbutton391.TextScaled = true
textbutton391.TextWrapped = true
textbutton391.BackgroundColor3 = Color3.new(1, 0, 0)
textbutton391.BackgroundTransparency = 0.5
textbutton391.Position = UDim2.new(1, 48, 0.07999999821186066, 0)
textbutton391.Size = UDim2.new(0, 35, 0, 35)
textbutton391.Name = "Clear"
textbutton391.Parent = frame384

-- Creating UIStroke
local uistroke392 = Instance.new("UIStroke")
uistroke392.Color = Color3.new(1, 1, 1)
uistroke392.Parent = textbutton391

-- Creating UICorner
local uicorner393 = Instance.new("UICorner")
uicorner393.Parent = textbutton391

-- Creating TextLabel
local textlabel394 = Instance.new("TextLabel")
textlabel394.RichText = true
textlabel394.Text = "<b><stroke color='rgb(85,255,255)' thickness='2'>AI-Thinking</stroke></b>"
textlabel394.TextColor3 = Color3.new(1, 1, 1)
textlabel394.TextScaled = true
textlabel394.TextWrapped = true
textlabel394.BackgroundTransparency = 1
textlabel394.Size = UDim2.new(0.20000000298023224, 0, 0.10000000149011612, 0)
textlabel394.Name = "Topic"
textlabel394.Parent = frame383

-- Creating TextLabel
local textlabel395 = Instance.new("TextLabel")
textlabel395.RichText = true
textlabel395.Text = "Version:<b> UIs 6.623 </b>"
textlabel395.TextColor3 = Color3.new(1, 1, 1)
textlabel395.TextScaled = true
textlabel395.TextWrapped = true
textlabel395.BackgroundTransparency = 1
textlabel395.Position = UDim2.new(0, 0, 0.07000000029802322, 0)
textlabel395.Size = UDim2.new(0.20000000298023224, 0, 0.029999999329447746, 0)
textlabel395.Name = "ver"
textlabel395.Parent = frame383

-- Creating TextLabel
local textlabel396 = Instance.new("TextLabel")
textlabel396.RichText = true
textlabel396.Text = "<b><stroke color='rgb(255,100,100)' thickness='1' transparency='0'>UNAVAILABLE FEATURES (Old)</stroke></b>"
textlabel396.TextColor3 = Color3.new(1, 0, 0)
textlabel396.TextSize = 24
textlabel396.BackgroundColor3 = Color3.new(0, 0, 0)
textlabel396.BackgroundTransparency = 0.4000000059604645
textlabel396.Position = UDim2.new(0.23000000417232513, 0, 0, 0)
textlabel396.Size = UDim2.new(0.7699999809265137, 0, 0.10000000149011612, 0)
textlabel396.ZIndex = 2
textlabel396.Name = "Unavailable"
textlabel396.Parent = frame383

-- Creating Frame
local frame397 = Instance.new("Frame")
frame397.BackgroundColor3 = Color3.new(1, 1, 1)
frame397.BorderColor3 = Color3.new(1, 1, 1)
frame397.Position = UDim2.new(0.2199999988079071, 0, 0, 0)
frame397.Size = UDim2.new(0, 0, 0.10000000149011612, 0)
frame397.Name = "Line"
frame397.Parent = frame383

-- Creating TextBox
local textbox398 = Instance.new("TextBox")
textbox398.PlaceholderText = "[ Your API here (ChatGPT or Gemini) ]"
textbox398.RichText = true
textbox398.Text = ""
textbox398.TextColor3 = Color3.new(1, 1, 1)
textbox398.TextScaled = true
textbox398.TextSize = 16
textbox398.TextWrapped = true
textbox398.Active = false
textbox398.BackgroundTransparency = 1
textbox398.Position = UDim2.new(0.23000000417232513, 0, 0, 0)
textbox398.Size = UDim2.new(0.30000001192092896, 0, 0.10000000149011612, 0)
textbox398.Name = "api"
textbox398.Parent = frame383

-- Creating TextButton
local textbutton399 = Instance.new("TextButton")
textbutton399.Text = "Confirm API"
textbutton399.TextColor3 = Color3.new(0, 1, 0)
textbutton399.TextScaled = true
textbutton399.TextWrapped = true
textbutton399.Active = false
textbutton399.BackgroundTransparency = 1
textbutton399.Position = UDim2.new(0.550000011920929, 0, 0, 0)
textbutton399.Size = UDim2.new(0.10000000149011612, 0, 0.10000000149011612, 0)
textbutton399.Name = "Confirm_api"
textbutton399.Parent = frame383

-- Creating UICorner
local uicorner400 = Instance.new("UICorner")
uicorner400.Parent = textbutton399

-- Creating UIStroke
local uistroke401 = Instance.new("UIStroke")
uistroke401.Color = Color3.new(0, 1, 0)
uistroke401.Parent = textbutton399

-- Creating TextButton
local textbutton402 = Instance.new("TextButton")
textbutton402.Text = "Unsaved API"
textbutton402.TextColor3 = Color3.new(1, 0, 0)
textbutton402.TextScaled = true
textbutton402.TextWrapped = true
textbutton402.Active = false
textbutton402.BackgroundTransparency = 1
textbutton402.Position = UDim2.new(0.6600000262260437, 0, 0, 0)
textbutton402.Size = UDim2.new(0.10000000149011612, 0, 0.10000000149011612, 0)
textbutton402.Name = "Unsaved_API"
textbutton402.Parent = frame383

-- Creating UICorner
local uicorner403 = Instance.new("UICorner")
uicorner403.Parent = textbutton402

-- Creating UIStroke
local uistroke404 = Instance.new("UIStroke")
uistroke404.Color = Color3.new(1, 0, 0)
uistroke404.Parent = textbutton402

-- Creating TextLabel
local textlabel405 = Instance.new("TextLabel")
textlabel405.Text = "Status: No key"
textlabel405.TextColor3 = Color3.new(1, 1, 1)
textlabel405.TextScaled = true
textlabel405.TextWrapped = true
textlabel405.BackgroundTransparency = 1
textlabel405.Position = UDim2.new(0.7699999809265137, 0, 0, 0)
textlabel405.Size = UDim2.new(0.23000000417232513, 0, 0.10000000149011612, 0)
textlabel405.Name = "Status"
textlabel405.Parent = frame383

-- Creating UICorner
local uicorner406 = Instance.new("UICorner")
uicorner406.Parent = textlabel405

-- Creating UIStroke
local uistroke407 = Instance.new("UIStroke")
uistroke407.Color = Color3.new(1, 1, 1)
uistroke407.Parent = textlabel405

-- Creating ScrollingFrame
local scrollingframe408 = Instance.new("ScrollingFrame")
scrollingframe408.CanvasPosition = Vector2.new(0, 4782.6005859375)
scrollingframe408.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingframe408.BackgroundColor3 = Color3.new(0, 0, 0)
scrollingframe408.BackgroundTransparency = 0.5
scrollingframe408.Position = UDim2.new(0, 0, 0.12999999523162842, 0)
scrollingframe408.Size = UDim2.new(1, 0, 0.75, 0)
scrollingframe408.Name = "ChatLogs"
scrollingframe408.Parent = frame383

-- Creating UIListLayout
local uilistlayout409 = Instance.new("UIListLayout")
uilistlayout409.Parent = scrollingframe408

-- Creating UICorner
local uicorner410 = Instance.new("UICorner")
uicorner410.Parent = scrollingframe408

-- Creating UIStroke
local uistroke411 = Instance.new("UIStroke")
uistroke411.Color = Color3.new(1, 1, 1)
uistroke411.Parent = scrollingframe408

-- Creating TextLabel
local textlabel412 = Instance.new("TextLabel")
textlabel412.RichText = true
textlabel412.Text = "<font size=\"28\"><b>Working fine!</b></font>"
textlabel412.TextColor3 = Color3.new(0.7058823704719543, 0.7058823704719543, 0.7058823704719543)
textlabel412.TextSize = 16
textlabel412.TextWrapped = true
textlabel412.BackgroundColor3 = Color3.new(0.7058823704719543, 0.7058823704719543, 0.7058823704719543)
textlabel412.BackgroundTransparency = 0.8500000238418579
textlabel412.BorderSizePixel = 5
textlabel412.Size = UDim2.new(0.9700000286102295, 0, 0, 0)
textlabel412.Name = "Text"
textlabel412.Parent = scrollingframe408

-- Creating ImageButton
local imagebutton413 = Instance.new("ImageButton")
imagebutton413.Image = "rbxassetid://85495702622937"
imagebutton413.BackgroundColor3 = Color3.new(0.7058823704719543, 0.7058823704719543, 0.7058823704719543)
imagebutton413.BackgroundTransparency = 0.30000001192092896
imagebutton413.Position = UDim2.new(1, -25, 1, -25)
imagebutton413.Size = UDim2.new(0, 25, 0, 25)
imagebutton413.ZIndex = 2
imagebutton413.Name = "CopyButton"
imagebutton413.Parent = textlabel412

-- Creating UICorner
local uicorner414 = Instance.new("UICorner")
uicorner414.Parent = imagebutton413

-- Creating UICorner
local uicorner415 = Instance.new("UICorner")
uicorner415.Parent = textlabel412

-- Creating TextLabel
local textlabel416 = Instance.new("TextLabel")
textlabel416.RichText = true
textlabel416.Text = "<b>Version</b>: UIs 6.623 | © Copyright <i>LighterCyan</i>"
textlabel416.TextColor3 = Color3.new(0.7058823704719543, 0.7058823704719543, 0.7058823704719543)
textlabel416.TextSize = 16
textlabel416.TextWrapped = true
textlabel416.BackgroundColor3 = Color3.new(0.7058823704719543, 0.7058823704719543, 0.7058823704719543)
textlabel416.BackgroundTransparency = 0.8500000238418579
textlabel416.BorderSizePixel = 5
textlabel416.Size = UDim2.new(0.9700000286102295, 0, 0, 0)
textlabel416.Name = "Text"
textlabel416.Parent = scrollingframe408

-- Creating ImageButton
local imagebutton417 = Instance.new("ImageButton")
imagebutton417.Image = "rbxassetid://85495702622937"
imagebutton417.BackgroundColor3 = Color3.new(0.7058823704719543, 0.7058823704719543, 0.7058823704719543)
imagebutton417.BackgroundTransparency = 0.30000001192092896
imagebutton417.Position = UDim2.new(1, -25, 1, -25)
imagebutton417.Size = UDim2.new(0, 25, 0, 25)
imagebutton417.ZIndex = 2
imagebutton417.Name = "CopyButton"
imagebutton417.Parent = textlabel416

-- Creating UICorner
local uicorner418 = Instance.new("UICorner")
uicorner418.Parent = imagebutton417

-- Creating UICorner
local uicorner419 = Instance.new("UICorner")
uicorner419.Parent = textlabel416

-- Creating TextLabel
local textlabel420 = Instance.new("TextLabel")
textlabel420.RichText = true
textlabel420.Text = "[ ℹ️ ]: <font size=\"28\"><b>-- Update logs --</b></font>\n(:8/1/2026 | 5:55 pm: !) Fixed bug\n(:8/1/2026 | 6:00 pm: R) Raw reset GitHub bug.\n(:8/1/2026 | 6:22 pm: !) Fixed bug again\n(:8/1/2026 | -:-- pm: R) GitHub bug\n(:8/1/2026 | 6:49 pm: C) Closed\n(:30/1/2026 | 8:12 pm: U) Update\n(:30/1/2026 | 8:59 pm: D) Disabled top button for bug.\n(:28/3/2026 | 8:32 pm: F&amp;R) Fixed /Globalchat not working and rename from AI-OpenSource to AI-Thinking.\n(:13/4/2026 | 8:42 pm: A) Add &quot;New message&quot; TextLabel. Important for using /globalchat but still in development.\n(:14/4/2026 | 1:26 am: N) New message system is finally here!\n(:14/4/2026 | 1:33 am: F) FIXED NEW MESSAGE SYSTEM REVERSE WHAT THE FUCK.\n(:14/4/2026 | 1:52 am - 2:27 am: B) Buff from 99+ to 9999+ in new message system.\n(:15/4/2026 | 3:29 pm: A) Add Colorful to message and changed BackgroundTransparency to 0.85\n(:4/5/2026 | 5:10 am: F) Fixed AI ChatGPT Response.\n(:23/5/2026 | 1:45 am: R) Re-gui to make easier to use, and added Clear button!\n(:23/5/2026 | 2:06 am: F) Fixed button position.\n(:23/5/2026 | 6:59 pm: U) Upgrade gemini with 3.1 flash lite. Added /geminiswitchmodel and /gptswitchmodel\n(:23/5/2026 | 8:56 pm: A) Added memory for AI to remember what you chatting! also added 5 commands.\n(:24/5/2026 | 12:47 pm: F) Fixed AI doesn&apos;t remember.\n(:25/5/2026 | 4:58 pm: C) Changed AI emoji from [ 🤖 ] to [ ✨ ]. ( FOR AI DO NOT USE THIS PREFIX BECAUSE YOU ALREADY HAVE IT JUST SAY WITHOUT [ ✨ ], FOR ONE MORE TIME PLEASE DO NOT USE IT. )\n(:25/5/2026 | 5:53 pm: N) New command! called &quot;/AllowCam&quot; to make AI see Roblox world! if command is enabled.\n(:25/5/2026 | 7:16 pm: F) Fixed RichText cannot escape. (Actually tell AI LOL)\n(:25/5/2026 | 9:21 pm: R) Rename one command called &quot;/Globalchat&quot; to &quot;/Herechat&quot; to match Roblox chat.\n(:26/5/2026 | 5:36 pm: A) Added ViewportFrame to user while using /AllowCam to make sure what is AI seeing.\n(:26/5/2026 | 5:53 pm: F) Fixed ViewportFrame not showing and lag issues.\n(:27/5/2026 | 7:32 pm: F&amp;A) Fixed Center-Point Visibility Problem on /AllowCam and added &quot;/AllowProperties&quot; and &quot;/AllowSeeChildren&quot;. Add SUPERLONG mode for /geminiswitch and /gptswitch to make more text limit.\n(:28/5/2026 | 8:00 pm: F) Fixed lag as possible. and add safety from crashing by automatic allowcam turn off itself.\n(:29/5/2026 | 8:10 pm: F) Fixed lag issues for mobile device.\n(:29/5/2026 | 9:55 pm: S) Switch from instant build to streaming to improve performance on low-quality devices.\n(:31/5/2026 | 4:42 pm: S) Say hello to Gemini-3.5-flash and gpt-5.5! + add CREATIVE to /geminiswitch and /gptswitch.\n(:1/6/2026 | 1:17 am: A) AllowCam is unavailable for now that mean AI may not respond after use Allowcam. please do allowcam be disabled and wait the update.\n(:1/6/2026 | 4:10 pm: A) Add new string match google API key it called &quot;AQ.&quot;\n(:1/6/2026 | 5:32 pm: F) Fixed Allowcam.\n(:4/6/2026 | 6:51 pm: P) Prevent RichText conflicts.\n(:4/6/2026 | 7:37 pm: A) Added new one command called &quot;/TextStyle&quot; (Enable by default)\n(:5/6/2026 | 11:08 pm: F) Fixed Scroll and TextStyle. Also ADDED COPY BUTTON YEPPPIE!!!\n(:7/6/2026 | 2:20 pm: A) Added Team to HereChat with color team too.\n(:7/6/2026 | 3:05 pm: A) Added new command called &quot;/gstcb&quot;\n(:8/6/2026 | 4:05 pm: A) Added [](&lt;&gt;) and fixed team name RichText cannot escape.\n  • (:From 8/5/2026: F) Fixed bug Team name.\n      • (2) GET THIS FUCKING TEAM BUG AWAY FROM HERECHAT PLEASE OH MY GOD. (Fixed)\n      • (3: 5:44 pm:) AHHHHHHHHHHH\n      • (4: 6:24 pm:) Fuck these bug, herechat team tag.\n      • (5: 7:41 pm:) Fixed.\n(:9/6/2026 | 8:59 pm: W) Welcome claude and deepseek! you are here with us! added /claudeswitch, /claudemodel /deepseekswitch, /deepseekmodel. Have fun!\n      • (1: 9:13 pm: F) Fixed bug.\n      • (2: 9:52 pm: F) Fixed bug API not matching.\n(:--/--/--- | --&apos;-- --: F) Failed to load logs.\n(:12/6/2026 | 3:57 pm: U) Update prompt and added new formatting + fix team tag herechat bug.\n      • (1: 5:38 pm: A) Added Mutil line for new formatting and now support another formatting.\n      • (2: 7:28 pm: F) Fixed prompt text color rules.\n(:13/6/2026 | 7:18 pm: U) Upgrade prompt.\n(:14/6/2026 | 2:43 am: O) Out of local 🥀 Shit.\n(:14/6/2026 | 3:25 am: F) FUCK OFF OUT OF LOCAL I REDUCED YOU!\n(:14/6/2026 | 1:21 pm: A) Added 5 new formatting✨\n(:15/6/2026 | 5:55 pm: A) Added new 3 commands and added new stroke formatting.\n(:20/6/2026 | 8:26 pm: F) Fixed prompt."
textlabel420.TextColor3 = Color3.new(0, 0.6666666865348816, 1)
textlabel420.TextSize = 16
textlabel420.TextWrapped = true
textlabel420.BackgroundColor3 = Color3.new(0, 0.6666666865348816, 1)
textlabel420.BackgroundTransparency = 0.8500000238418579
textlabel420.BorderSizePixel = 5
textlabel420.Size = UDim2.new(0.9700000286102295, 0, 0, 0)
textlabel420.Name = "Text"
textlabel420.Parent = scrollingframe408

-- Creating ImageButton
local imagebutton421 = Instance.new("ImageButton")
imagebutton421.Image = "rbxassetid://85495702622937"
imagebutton421.BackgroundColor3 = Color3.new(0, 0.6666666865348816, 1)
imagebutton421.BackgroundTransparency = 0.30000001192092896
imagebutton421.Position = UDim2.new(1, -25, 1, -25)
imagebutton421.Size = UDim2.new(0, 25, 0, 25)
imagebutton421.ZIndex = 2
imagebutton421.Name = "CopyButton"
imagebutton421.Parent = textlabel420

-- Creating UICorner
local uicorner422 = Instance.new("UICorner")
uicorner422.Parent = imagebutton421

-- Creating UICorner
local uicorner423 = Instance.new("UICorner")
uicorner423.Parent = textlabel420

-- Creating TextLabel
local textlabel424 = Instance.new("TextLabel")
textlabel424.RichText = true
textlabel424.Text = "[ ℹ️ ]: Use <b>/help</b> for more <i>information</i> or commands. Add api is <b>/addapi</b>"
textlabel424.TextColor3 = Color3.new(0, 0.6666666865348816, 1)
textlabel424.TextSize = 16
textlabel424.TextWrapped = true
textlabel424.BackgroundColor3 = Color3.new(0, 0.6666666865348816, 1)
textlabel424.BackgroundTransparency = 0.8500000238418579
textlabel424.BorderSizePixel = 5
textlabel424.Size = UDim2.new(0.9700000286102295, 0, 0, 0)
textlabel424.Name = "Text"
textlabel424.Parent = scrollingframe408

-- Creating ImageButton
local imagebutton425 = Instance.new("ImageButton")
imagebutton425.Image = "rbxassetid://85495702622937"
imagebutton425.BackgroundColor3 = Color3.new(0, 0.6666666865348816, 1)
imagebutton425.BackgroundTransparency = 0.30000001192092896
imagebutton425.Position = UDim2.new(1, -25, 1, -25)
imagebutton425.Size = UDim2.new(0, 25, 0, 25)
imagebutton425.ZIndex = 2
imagebutton425.Name = "CopyButton"
imagebutton425.Parent = textlabel424

-- Creating UICorner
local uicorner426 = Instance.new("UICorner")
uicorner426.Parent = imagebutton425

-- Creating UICorner
local uicorner427 = Instance.new("UICorner")
uicorner427.Parent = textlabel424

-- Creating TextLabel
local textlabel428 = Instance.new("TextLabel")
textlabel428.RichText = true
textlabel428.Text = "# What is AI-Thinking?\n  AI-Thinking is a <b>tool for questioning to AIs</b> (ChatGPT/Gemini) by putting <b>your API Key</b>.\n  \n<font size=\"28\"><b>What AI model you using?</b></font>\n  We use <b>gpt-4o-mini</b> and <b>gemini-3.1-flash</b>\n  \n<font size=\"28\"><b>This is safe to put api key?</b></font>\n  <b>Yes</b>, this is <b>safe to put your api key</b>, but make sure do <b>NOT</b> share your api.\n  \n<font size=\"28\"><b>Available commands</b></font>\n  use <b>/Help</b> for more <i>commands</i>."
textlabel428.TextColor3 = Color3.new(0.7058823704719543, 0.7058823704719543, 0.7058823704719543)
textlabel428.TextSize = 16
textlabel428.TextWrapped = true
textlabel428.BackgroundColor3 = Color3.new(0.7058823704719543, 0.7058823704719543, 0.7058823704719543)
textlabel428.BackgroundTransparency = 0.8500000238418579
textlabel428.BorderSizePixel = 5
textlabel428.Size = UDim2.new(0.9700000286102295, 0, 0, 0)
textlabel428.Name = "Text"
textlabel428.Parent = scrollingframe408

-- Creating ImageButton
local imagebutton429 = Instance.new("ImageButton")
imagebutton429.Image = "rbxassetid://85495702622937"
imagebutton429.BackgroundColor3 = Color3.new(0.7058823704719543, 0.7058823704719543, 0.7058823704719543)
imagebutton429.BackgroundTransparency = 0.30000001192092896
imagebutton429.Position = UDim2.new(1, -25, 1, -25)
imagebutton429.Size = UDim2.new(0, 25, 0, 25)
imagebutton429.ZIndex = 2
imagebutton429.Name = "CopyButton"
imagebutton429.Parent = textlabel428

-- Creating UICorner
local uicorner430 = Instance.new("UICorner")
uicorner430.Parent = imagebutton429

-- Creating UICorner
local uicorner431 = Instance.new("UICorner")
uicorner431.Parent = textlabel428

-- Creating TextLabel
local textlabel432 = Instance.new("TextLabel")
textlabel432.RichText = true
textlabel432.Text = "<font size=\"28\"><b>OFFICIAL ANNOUNCEMENT </b></font>\nAI is <b>not</b> bug with broken text because of text limit, use <b>/geminiswitch</b> or <b>/gptswitch</b> to change text limit."
textlabel432.TextColor3 = Color3.new(1, 0, 0)
textlabel432.TextSize = 16
textlabel432.TextWrapped = true
textlabel432.BackgroundColor3 = Color3.new(1, 0, 0)
textlabel432.BackgroundTransparency = 0.8500000238418579
textlabel432.BorderSizePixel = 5
textlabel432.Size = UDim2.new(0.9700000286102295, 0, 0, 0)
textlabel432.Name = "Text"
textlabel432.Parent = scrollingframe408

-- Creating ImageButton
local imagebutton433 = Instance.new("ImageButton")
imagebutton433.Image = "rbxassetid://85495702622937"
imagebutton433.BackgroundColor3 = Color3.new(1, 0, 0)
imagebutton433.BackgroundTransparency = 0.30000001192092896
imagebutton433.Position = UDim2.new(1, -25, 1, -25)
imagebutton433.Size = UDim2.new(0, 25, 0, 25)
imagebutton433.ZIndex = 2
imagebutton433.Name = "CopyButton"
imagebutton433.Parent = textlabel432

-- Creating UICorner
local uicorner434 = Instance.new("UICorner")
uicorner434.Parent = imagebutton433

-- Creating UICorner
local uicorner435 = Instance.new("UICorner")
uicorner435.Parent = textlabel432

-- Creating TextLabel
local textlabel436 = Instance.new("TextLabel")
textlabel436.RichText = true
textlabel436.Text = "[ ⚠️ ]: &quot;<b>Stop!</b> For your <b>safety</b>, please do <b>NOT</b> share your API and avoid being stared at by <b>people around you</b>. Due to safety and privacy concerns, you confirm that you will use your API to continue using our <b>AI-Thinking</b> or not? \n<b>With respect</b>."
textlabel436.TextColor3 = Color3.new(1, 1, 0)
textlabel436.TextSize = 16
textlabel436.TextWrapped = true
textlabel436.BackgroundColor3 = Color3.new(1, 1, 0)
textlabel436.BackgroundTransparency = 0.8500000238418579
textlabel436.BorderSizePixel = 5
textlabel436.Size = UDim2.new(0.9700000286102295, 0, 0, 0)
textlabel436.Name = "Text"
textlabel436.Parent = scrollingframe408

-- Creating ImageButton
local imagebutton437 = Instance.new("ImageButton")
imagebutton437.Image = "rbxassetid://85495702622937"
imagebutton437.BackgroundColor3 = Color3.new(1, 1, 0)
imagebutton437.BackgroundTransparency = 0.30000001192092896
imagebutton437.Position = UDim2.new(1, -25, 1, -25)
imagebutton437.Size = UDim2.new(0, 25, 0, 25)
imagebutton437.ZIndex = 2
imagebutton437.Name = "CopyButton"
imagebutton437.Parent = textlabel436

-- Creating UICorner
local uicorner438 = Instance.new("UICorner")
uicorner438.Parent = imagebutton437

-- Creating UICorner
local uicorner439 = Instance.new("UICorner")
uicorner439.Parent = textlabel436

-- Creating TextLabel
local textlabel440 = Instance.new("TextLabel")
textlabel440.RichText = true
textlabel440.Text = "[ ⚠️ ]: <font size=\"28\">1 command is [mark=rbg(0,255,0)]enabled[/mark]</font>\n<b>/1AutoRememberInGame</b> ON - Make AI to remember anything while chatting <font size=\"12\">(SAVE MEMORY (ONLY IN-GAME)</font>"
textlabel440.TextColor3 = Color3.new(1, 1, 0)
textlabel440.TextSize = 16
textlabel440.TextWrapped = true
textlabel440.BackgroundColor3 = Color3.new(1, 1, 0)
textlabel440.BackgroundTransparency = 0.8500000238418579
textlabel440.BorderSizePixel = 5
textlabel440.Size = UDim2.new(0.9700000286102295, 0, 0, 0)
textlabel440.Name = "Text"
textlabel440.Parent = scrollingframe408

-- Creating ImageButton
local imagebutton441 = Instance.new("ImageButton")
imagebutton441.Image = "rbxassetid://85495702622937"
imagebutton441.BackgroundColor3 = Color3.new(1, 1, 0)
imagebutton441.BackgroundTransparency = 0.30000001192092896
imagebutton441.Position = UDim2.new(1, -25, 1, -25)
imagebutton441.Size = UDim2.new(0, 25, 0, 25)
imagebutton441.ZIndex = 2
imagebutton441.Name = "CopyButton"
imagebutton441.Parent = textlabel440

-- Creating UICorner
local uicorner442 = Instance.new("UICorner")
uicorner442.Parent = imagebutton441

-- Creating UICorner
local uicorner443 = Instance.new("UICorner")
uicorner443.Parent = textlabel440

-- Creating TextLabel
local textlabel444 = Instance.new("TextLabel")
textlabel444.RichText = true
textlabel444.Text = "<font size=\"28\"><b>If you don&apos;t know how to put API key</b></font>\n<font size=\"18\"><b>1. Go to the website </b></font>\n\n• <font color=\"rgb(0,255,255)\">Google AI (Gemini)</font> - <font color=\"rgb(0,255,0)\"><b>Recommend</b></font> / <i>Free</i>\n  API:\n  <font color=\"rgb(80,170,255)\"><u>https://aistudio.google.com/app/api-keys</u></font>\n  Docs:\n  <font color=\"rgb(80,170,255)\"><u>https://ai.google.dev/gemini-api/docs/available-regions</u></font>\n\n• <font color=\"rgb(255,255,255)\">OpenAI (ChatGPT)</font> / <i>Paid</i>\n  API:\n  <font color=\"rgb(80,170,255)\"><u>https://platform.openai.com/api-keys</u></font>\n  Docs:\n  <font color=\"rgb(80,170,255)\"><u>https://openai.com/policies/row-terms-of-use/</u></font>\n\n• <font color=\"rgb(255,85,0)\">Anthropic (Claude)</font> <i>Paid</i>\n  API:\n  <font color=\"rgb(80,170,255)\"><u>https://console.anthropic.com/settings/keys</u></font>\n  Docs:\n<font color=\"rgb(80,170,255)\"><u>https://www.anthropic.com/legal/archive/79dbc8c6-7f64-43d6-8101-207cede59a4d</u></font>\n\n• <font color=\"rgb(0,150,150)\">DeepSeek</font> / <i>Paid</i>\n  API:\n  <font color=\"rgb(80,170,255)\"><u>https://platform.deepseek.com/api_keys</u></font>\n  Docs:\n  <font color=\"rgb(80,170,255)\"><u>https://cdn.deepseek.com/policies/en-US/deepseek-terms-of-use.html</u></font>\n\n<font size=\"18\"><b>2. Create API key and copy your API key.</b></font>\n• <b>Gemini</b>\n  Usually starts with:\n  <font face=\"Code\"><font color=\"rgb(255,220,150)\">AIza...</font></font> or <font face=\"Code\"><font color=\"rgb(255,220,150)\">AQ.</font></font>\n• <b>ChatGPT</b>\n  Usually starts with:\n  <font face=\"Code\"><font color=\"rgb(255,220,150)\">sk-</font></font>\n• <b>Claude</b>\n  Usually starts with:\n  <font face=\"Code\"><font color=\"rgb(255,220,150)\">sk-ant-</font></font>\n• <b>DeepSeek</b>\n  Usually starts with:\n  <font face=\"Code\"><font color=\"rgb(255,220,150)\">sk-</font></font>\n\n<font size=\"18\"><i></i>3. Launch Roblox.\n4. Execute ExperienceSettings.\n5. Open AI-Thinking.\n6. Run: Command<i></i></font>\n/addapi [GEMINI/CHATGPT/CLAUDE/DEEPSEEK] [APIKEY] [YES/NO]\n\nExamples:\n<font face=\"Code\"><font color=\"rgb(255,200,120)\">/addapi GEMINI AIzaxxxxxxxx YES\n/addapi CHATGPT sk-xxxxxxxx YES\n/addapi CLAUDE sk-ant-xxxxxxxx YES\n/addapi DEEPSEEK sk-xxxxxxxx YES</font></font>\n<font size=\"18\"><b>7. Enjoy </b></font>\n\n<font size=\"18\"><font size=\"28\"><b>Notes</b></font></font>\n• Never share your API key.\n• Gemini availability depends on region.\n• ChatGPT, Claude and DeepSeek may require credits.\n\n• If AI returns &quot;Insufficient Balance&quot;,\n  please check your provider billing status.\n	\n★ Scroll up to see all steps."
textlabel444.TextColor3 = Color3.new(1, 0.5882353186607361, 0)
textlabel444.TextSize = 16
textlabel444.TextWrapped = true
textlabel444.BackgroundColor3 = Color3.new(1, 0.5882353186607361, 0)
textlabel444.BackgroundTransparency = 0.8500000238418579
textlabel444.BorderSizePixel = 5
textlabel444.Size = UDim2.new(0.9700000286102295, 0, 0, 0)
textlabel444.Name = "Text"
textlabel444.Parent = scrollingframe408

-- Creating ImageButton
local imagebutton445 = Instance.new("ImageButton")
imagebutton445.Image = "rbxassetid://85495702622937"
imagebutton445.BackgroundColor3 = Color3.new(1, 0.5882353186607361, 0)
imagebutton445.BackgroundTransparency = 0.30000001192092896
imagebutton445.Position = UDim2.new(1, -25, 1, -25)
imagebutton445.Size = UDim2.new(0, 25, 0, 25)
imagebutton445.ZIndex = 2
imagebutton445.Name = "CopyButton"
imagebutton445.Parent = textlabel444

-- Creating UICorner
local uicorner446 = Instance.new("UICorner")
uicorner446.Parent = imagebutton445

-- Creating UICorner
local uicorner447 = Instance.new("UICorner")
uicorner447.Parent = textlabel444

-- Creating TextLabel
local textlabel448 = Instance.new("TextLabel")
textlabel448.RichText = true
textlabel448.Text = "<font size=\"20\"><b>[====== Chat ======]</b></font>"
textlabel448.TextColor3 = Color3.new(0.7058823704719543, 0.7058823704719543, 0.7058823704719543)
textlabel448.TextSize = 16
textlabel448.TextWrapped = true
textlabel448.BackgroundColor3 = Color3.new(0.7058823704719543, 0.7058823704719543, 0.7058823704719543)
textlabel448.BackgroundTransparency = 0.8500000238418579
textlabel448.BorderSizePixel = 5
textlabel448.Size = UDim2.new(0.9700000286102295, 0, 0, 0)
textlabel448.Name = "Text"
textlabel448.Parent = scrollingframe408

-- Creating ImageButton
local imagebutton449 = Instance.new("ImageButton")
imagebutton449.Image = "rbxassetid://85495702622937"
imagebutton449.BackgroundColor3 = Color3.new(0.7058823704719543, 0.7058823704719543, 0.7058823704719543)
imagebutton449.BackgroundTransparency = 0.30000001192092896
imagebutton449.Position = UDim2.new(1, -25, 1, -25)
imagebutton449.Size = UDim2.new(0, 25, 0, 25)
imagebutton449.ZIndex = 2
imagebutton449.Name = "CopyButton"
imagebutton449.Parent = textlabel448

-- Creating UICorner
local uicorner450 = Instance.new("UICorner")
uicorner450.Parent = imagebutton449

-- Creating UICorner
local uicorner451 = Instance.new("UICorner")
uicorner451.Parent = textlabel448

-- Creating TextLabel
local textlabel452 = Instance.new("TextLabel")
textlabel452.RichText = true
textlabel452.Text = "[STATUS] No key"
textlabel452.TextColor3 = Color3.new(0.7058823704719543, 0.7058823704719543, 0.7058823704719543)
textlabel452.TextSize = 16
textlabel452.TextWrapped = true
textlabel452.BackgroundColor3 = Color3.new(0.7058823704719543, 0.7058823704719543, 0.7058823704719543)
textlabel452.BackgroundTransparency = 0.8500000238418579
textlabel452.BorderSizePixel = 5
textlabel452.Size = UDim2.new(0.9700000286102295, 0, 0, 0)
textlabel452.Name = "Text"
textlabel452.Parent = scrollingframe408

-- Creating ImageButton
local imagebutton453 = Instance.new("ImageButton")
imagebutton453.Image = "rbxassetid://85495702622937"
imagebutton453.BackgroundColor3 = Color3.new(0.7058823704719543, 0.7058823704719543, 0.7058823704719543)
imagebutton453.BackgroundTransparency = 0.30000001192092896
imagebutton453.Position = UDim2.new(1, -25, 1, -25)
imagebutton453.Size = UDim2.new(0, 25, 0, 25)
imagebutton453.ZIndex = 2
imagebutton453.Name = "CopyButton"
imagebutton453.Parent = textlabel452

-- Creating UICorner
local uicorner454 = Instance.new("UICorner")
uicorner454.Parent = imagebutton453

-- Creating UICorner
local uicorner455 = Instance.new("UICorner")
uicorner455.Parent = textlabel452

-- Creating TextLabel
local textlabel456 = Instance.new("TextLabel")
textlabel456.RichText = true
textlabel456.Text = "[ ✅ ]: <b>Hello, World!</b>"
textlabel456.TextColor3 = Color3.new(0, 1, 0)
textlabel456.TextSize = 16
textlabel456.TextWrapped = true
textlabel456.BackgroundColor3 = Color3.new(0, 1, 0)
textlabel456.BackgroundTransparency = 0.8500000238418579
textlabel456.BorderSizePixel = 5
textlabel456.Size = UDim2.new(0.9700000286102295, 0, 0, 0)
textlabel456.Name = "Text"
textlabel456.Parent = scrollingframe408

-- Creating ImageButton
local imagebutton457 = Instance.new("ImageButton")
imagebutton457.Image = "rbxassetid://85495702622937"
imagebutton457.BackgroundColor3 = Color3.new(0, 1, 0)
imagebutton457.BackgroundTransparency = 0.30000001192092896
imagebutton457.Position = UDim2.new(1, -25, 1, -25)
imagebutton457.Size = UDim2.new(0, 25, 0, 25)
imagebutton457.ZIndex = 2
imagebutton457.Name = "CopyButton"
imagebutton457.Parent = textlabel456

-- Creating UICorner
local uicorner458 = Instance.new("UICorner")
uicorner458.Parent = imagebutton457

-- Creating UICorner
local uicorner459 = Instance.new("UICorner")
uicorner459.Parent = textlabel456

-- Creating UIScale
local uiscale460 = Instance.new("UIScale")
uiscale460.Name = "MenuUIScale"
uiscale460.Parent = screengui2

-- Creating Frame
local frame461 = Instance.new("Frame")
frame461.BackgroundColor3 = Color3.new(0.07058823853731155, 0.07058823853731155, 0.08235294371843338)
frame461.BackgroundTransparency = 0.30000001192092896
frame461.Position = UDim2.new(0, 0, 1, 0)
frame461.Size = UDim2.new(1, 0, 0.8999999761581421, 0)
frame461.Name = "Search"
frame461.Parent = screengui2

-- Creating Frame
local frame462 = Instance.new("Frame")
frame462.BackgroundTransparency = 1
frame462.Size = UDim2.new(1, 0, 0.15000000596046448, 0)
frame462.Name = "TopFrame"
frame462.Parent = frame461

-- Creating UIListLayout
local uilistlayout463 = Instance.new("UIListLayout")
uilistlayout463.Parent = frame462

-- Creating TextLabel
local textlabel464 = Instance.new("TextLabel")
textlabel464.Text = "Script: 20/220"
textlabel464.TextColor3 = Color3.new(1, 1, 1)
textlabel464.TextSize = 10
textlabel464.BackgroundTransparency = 1
textlabel464.Size = UDim2.new(0.10000000149011612, 0, 0.30000001192092896, 0)
textlabel464.Name = "ScriptCounter"
textlabel464.Parent = frame462

-- Creating Frame
local frame465 = Instance.new("Frame")
frame465.BackgroundTransparency = 0.5
frame465.Size = UDim2.new(0.5, 0, 0.30000001192092896, 0)
frame465.Name = "SearchBar"
frame465.Parent = frame462

-- Creating UICorner
local uicorner466 = Instance.new("UICorner")
uicorner466.Parent = frame465

-- Creating UIStroke
local uistroke467 = Instance.new("UIStroke")
uistroke467.Color = Color3.new(1, 1, 1)
uistroke467.Parent = frame465

-- Creating UIListLayout
local uilistlayout468 = Instance.new("UIListLayout")
uilistlayout468.Parent = frame465

-- Creating UIGradient
local uigradient469 = Instance.new("UIGradient")
uigradient469.Parent = frame465

-- Creating TextBox
local textbox470 = Instance.new("TextBox")
textbox470.ClearTextOnFocus = false
textbox470.PlaceholderText = "[ Select first ] Searcher"
textbox470.Text = ""
textbox470.TextColor3 = Color3.new(1, 1, 1)
textbox470.TextScaled = true
textbox470.TextWrapped = true
textbox470.BackgroundTransparency = 1
textbox470.Size = UDim2.new(0.949999988079071, 0, 0.5, 0)
textbox470.Name = "Searcher"
textbox470.Parent = frame465

-- Creating TextButton
local textbutton471 = Instance.new("TextButton")
textbutton471.Text = "ScriptBlox"
textbutton471.TextColor3 = Color3.new(1, 1, 1)
textbutton471.TextScaled = true
textbutton471.TextWrapped = true
textbutton471.Size = UDim2.new(0.10000000149011612, 0, 0.30000001192092896, 0)
textbutton471.Name = "ScriptBlox"
textbutton471.Parent = frame462

-- Creating UICorner
local uicorner472 = Instance.new("UICorner")
uicorner472.Parent = textbutton471

-- Creating UIStroke
local uistroke473 = Instance.new("UIStroke")
uistroke473.Color = Color3.new(1, 0.4117647111415863, 0.7058823704719543)
uistroke473.Parent = textbutton471

-- Creating UIListLayout
local uilistlayout474 = Instance.new("UIListLayout")
uilistlayout474.Parent = textbutton471

-- Creating UIGradient
local uigradient475 = Instance.new("UIGradient")
uigradient475.Rotation = 90
uigradient475.Parent = textbutton471

-- Creating TextButton
local textbutton476 = Instance.new("TextButton")
textbutton476.Text = "WeAreDev (SOON)"
textbutton476.TextColor3 = Color3.new(1, 1, 1)
textbutton476.TextScaled = true
textbutton476.TextWrapped = true
textbutton476.BackgroundTransparency = 0.5
textbutton476.Size = UDim2.new(0.10000000149011612, 0, 0.30000001192092896, 0)
textbutton476.Name = "WeAreDev"
textbutton476.Parent = frame462

-- Creating UICorner
local uicorner477 = Instance.new("UICorner")
uicorner477.Parent = textbutton476

-- Creating UIStroke
local uistroke478 = Instance.new("UIStroke")
uistroke478.Color = Color3.new(0.48235294222831726, 0.6470588445663452, 0.658823549747467)
uistroke478.Parent = textbutton476

-- Creating UIListLayout
local uilistlayout479 = Instance.new("UIListLayout")
uilistlayout479.Parent = textbutton476

-- Creating UIGradient
local uigradient480 = Instance.new("UIGradient")
uigradient480.Rotation = 90
uigradient480.Parent = textbutton476

-- Creating ScrollingFrame
local scrollingframe481 = Instance.new("ScrollingFrame")
scrollingframe481.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingframe481.ScrollBarThickness = 5
scrollingframe481.Active = true
scrollingframe481.BackgroundTransparency = 1
scrollingframe481.Position = UDim2.new(0.05000000074505806, 0, 0.15000000596046448, 0)
scrollingframe481.Size = UDim2.new(0.8999999761581421, 0, 0.8500000238418579, 0)
scrollingframe481.Name = "scroll"
scrollingframe481.Parent = frame461

-- Creating UIGridLayout
local uigridlayout482 = Instance.new("UIGridLayout")
uigridlayout482.CellSize = UDim2.new(0, 180, 0, 250)
uigridlayout482.Parent = scrollingframe481

-- Creating Frame
local frame483 = Instance.new("Frame")
frame483.BackgroundColor3 = Color3.new(0.07058823853731155, 0.07058823853731155, 0.08235294371843338)
frame483.BackgroundTransparency = 0.25
frame483.Size = UDim2.new(0, 220, 0, 250)
frame483.Name = "Handle"
frame483.Parent = scrollingframe481

-- Creating UICorner
local uicorner484 = Instance.new("UICorner")
uicorner484.Parent = frame483

-- Creating UIGradient
local uigradient485 = Instance.new("UIGradient")
uigradient485.Rotation = 90
uigradient485.Parent = frame483

-- Creating UIScale
local uiscale486 = Instance.new("UIScale")
uiscale486.Parent = frame483

-- Creating Frame
local frame487 = Instance.new("Frame")
frame487.BackgroundTransparency = 1
frame487.Position = UDim2.new(0, 4, 0, 4)
frame487.Size = UDim2.new(1, -8, 1, -8)
frame487.Parent = frame483

-- Creating TextLabel
local textlabel488 = Instance.new("TextLabel")
textlabel488.Text = "Evolution Hub AUTOLINEUPS FORMLESSMACRO AUTODEFENSE"
textlabel488.TextColor3 = Color3.new(1, 1, 1)
textlabel488.TextScaled = true
textlabel488.TextWrapped = true
textlabel488.BackgroundTransparency = 1
textlabel488.Size = UDim2.new(1, 0, 0, 40)
textlabel488.Name = "Title"
textlabel488.Parent = frame487

-- Creating ImageLabel
local imagelabel489 = Instance.new("ImageLabel")
imagelabel489.Image = "https://scriptblox.com/images/script/94647229517154-1781025166676.jpg"
imagelabel489.BackgroundTransparency = 0.30000001192092896
imagelabel489.Position = UDim2.new(0, 0, 0, 42)
imagelabel489.Size = UDim2.new(1, 0, 0, 100)
imagelabel489.Name = "ImageAsset"
imagelabel489.Parent = frame487

-- Creating UICorner
local uicorner490 = Instance.new("UICorner")
uicorner490.Parent = imagelabel489

-- Creating UIListLayout
local uilistlayout491 = Instance.new("UIListLayout")
uilistlayout491.Parent = imagelabel489

-- Creating TextLabel
local textlabel492 = Instance.new("TextLabel")
textlabel492.Text = "Key"
textlabel492.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel492.TextScaled = true
textlabel492.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel492.TextStrokeTransparency = 0
textlabel492.TextWrapped = true
textlabel492.BackgroundTransparency = 1
textlabel492.Size = UDim2.new(0.5, 0, 0, 18)
textlabel492.Visible = false
textlabel492.Name = "KEY"
textlabel492.Parent = imagelabel489

-- Creating TextLabel
local textlabel493 = Instance.new("TextLabel")
textlabel493.Text = "Patched"
textlabel493.TextColor3 = Color3.new(1, 0, 0)
textlabel493.TextScaled = true
textlabel493.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel493.TextStrokeTransparency = 0
textlabel493.TextWrapped = true
textlabel493.BackgroundTransparency = 1
textlabel493.Size = UDim2.new(0.5, 0, 0, 18)
textlabel493.Visible = false
textlabel493.Name = "Patched"
textlabel493.Parent = imagelabel489

-- Creating TextLabel
local textlabel494 = Instance.new("TextLabel")
textlabel494.Text = "Verified"
textlabel494.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel494.TextScaled = true
textlabel494.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel494.TextStrokeTransparency = 0
textlabel494.TextWrapped = true
textlabel494.BackgroundTransparency = 1
textlabel494.Size = UDim2.new(0.5, 0, 0, 18)
textlabel494.Visible = false
textlabel494.Name = "Verified"
textlabel494.Parent = imagelabel489

-- Creating TextLabel
local textlabel495 = Instance.new("TextLabel")
textlabel495.Text = "Visits: 31642"
textlabel495.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel495.TextScaled = true
textlabel495.TextWrapped = true
textlabel495.BackgroundTransparency = 1
textlabel495.Position = UDim2.new(0, 0, 0, 142)
textlabel495.Size = UDim2.new(1, 0, 0, 18)
textlabel495.Name = "Visit"
textlabel495.Parent = frame487

-- Creating TextLabel
local textlabel496 = Instance.new("TextLabel")
textlabel496.Text = "Likes: 0"
textlabel496.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel496.TextScaled = true
textlabel496.TextWrapped = true
textlabel496.BackgroundTransparency = 1
textlabel496.Position = UDim2.new(0, 0, 0, 158)
textlabel496.Size = UDim2.new(1, 0, 0, 18)
textlabel496.Name = "Like"
textlabel496.Parent = frame487

-- Creating TextLabel
local textlabel497 = Instance.new("TextLabel")
textlabel497.Text = "[⚔️ RANKED QOL] Azure Latch"
textlabel497.TextColor3 = Color3.new(1, 1, 1)
textlabel497.TextScaled = true
textlabel497.TextWrapped = true
textlabel497.BackgroundTransparency = 1
textlabel497.Position = UDim2.new(0, 0, 0, 176)
textlabel497.Size = UDim2.new(1, 0, 0, 18)
textlabel497.Name = "IsUniversal"
textlabel497.Parent = frame487

-- Creating TextButton
local textbutton498 = Instance.new("TextButton")
textbutton498.Text = "EXECUTE"
textbutton498.TextColor3 = Color3.new(1, 1, 1)
textbutton498.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton498.Position = UDim2.new(0, 0, 1, -20)
textbutton498.Size = UDim2.new(1, 0, 0, 20)
textbutton498.Parent = frame487

-- Creating UICorner
local uicorner499 = Instance.new("UICorner")
uicorner499.Parent = textbutton498

-- Creating TextButton
local textbutton500 = Instance.new("TextButton")
textbutton500.Text = "COPY TO CLIPBOARD"
textbutton500.TextColor3 = Color3.new(1, 1, 1)
textbutton500.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton500.Position = UDim2.new(0, 0, 1, -44)
textbutton500.Size = UDim2.new(1, 0, 0, 20)
textbutton500.Name = "copy"
textbutton500.Parent = frame487

-- Creating UICorner
local uicorner501 = Instance.new("UICorner")
uicorner501.Parent = textbutton500

-- Creating Frame
local frame502 = Instance.new("Frame")
frame502.BackgroundColor3 = Color3.new(1, 0.42352941632270813, 0)
frame502.BackgroundTransparency = 0.25
frame502.Size = UDim2.new(0, 220, 0, 250)
frame502.Name = "Handle"
frame502.Parent = scrollingframe481

-- Creating UICorner
local uicorner503 = Instance.new("UICorner")
uicorner503.Parent = frame502

-- Creating UIGradient
local uigradient504 = Instance.new("UIGradient")
uigradient504.Rotation = 90
uigradient504.Parent = frame502

-- Creating UIScale
local uiscale505 = Instance.new("UIScale")
uiscale505.Parent = frame502

-- Creating Frame
local frame506 = Instance.new("Frame")
frame506.BackgroundTransparency = 1
frame506.Position = UDim2.new(0, 4, 0, 4)
frame506.Size = UDim2.new(1, -8, 1, -8)
frame506.Parent = frame502

-- Creating TextLabel
local textlabel507 = Instance.new("TextLabel")
textlabel507.Text = "VERY OP UNIVERSAL MPS REACH"
textlabel507.TextColor3 = Color3.new(1, 1, 1)
textlabel507.TextScaled = true
textlabel507.TextWrapped = true
textlabel507.BackgroundTransparency = 1
textlabel507.Size = UDim2.new(1, 0, 0, 40)
textlabel507.Name = "Title"
textlabel507.Parent = frame506

-- Creating ImageLabel
local imagelabel508 = Instance.new("ImageLabel")
imagelabel508.Image = "https://scriptblox.com/images/script/0-1767747925903.webp"
imagelabel508.BackgroundTransparency = 0.30000001192092896
imagelabel508.Position = UDim2.new(0, 0, 0, 42)
imagelabel508.Size = UDim2.new(1, 0, 0, 100)
imagelabel508.Name = "ImageAsset"
imagelabel508.Parent = frame506

-- Creating UICorner
local uicorner509 = Instance.new("UICorner")
uicorner509.Parent = imagelabel508

-- Creating UIListLayout
local uilistlayout510 = Instance.new("UIListLayout")
uilistlayout510.Parent = imagelabel508

-- Creating TextLabel
local textlabel511 = Instance.new("TextLabel")
textlabel511.Text = "Key"
textlabel511.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel511.TextScaled = true
textlabel511.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel511.TextStrokeTransparency = 0
textlabel511.TextWrapped = true
textlabel511.BackgroundTransparency = 1
textlabel511.Size = UDim2.new(0.5, 0, 0, 18)
textlabel511.Name = "KEY"
textlabel511.Parent = imagelabel508

-- Creating TextLabel
local textlabel512 = Instance.new("TextLabel")
textlabel512.Text = "Patched"
textlabel512.TextColor3 = Color3.new(1, 0, 0)
textlabel512.TextScaled = true
textlabel512.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel512.TextStrokeTransparency = 0
textlabel512.TextWrapped = true
textlabel512.BackgroundTransparency = 1
textlabel512.Size = UDim2.new(0.5, 0, 0, 18)
textlabel512.Visible = false
textlabel512.Name = "Patched"
textlabel512.Parent = imagelabel508

-- Creating TextLabel
local textlabel513 = Instance.new("TextLabel")
textlabel513.Text = "Verified"
textlabel513.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel513.TextScaled = true
textlabel513.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel513.TextStrokeTransparency = 0
textlabel513.TextWrapped = true
textlabel513.BackgroundTransparency = 1
textlabel513.Size = UDim2.new(0.5, 0, 0, 18)
textlabel513.Visible = false
textlabel513.Name = "Verified"
textlabel513.Parent = imagelabel508

-- Creating TextLabel
local textlabel514 = Instance.new("TextLabel")
textlabel514.Text = "Visits: 4861"
textlabel514.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel514.TextScaled = true
textlabel514.TextWrapped = true
textlabel514.BackgroundTransparency = 1
textlabel514.Position = UDim2.new(0, 0, 0, 142)
textlabel514.Size = UDim2.new(1, 0, 0, 18)
textlabel514.Name = "Visit"
textlabel514.Parent = frame506

-- Creating TextLabel
local textlabel515 = Instance.new("TextLabel")
textlabel515.Text = "Likes: 0"
textlabel515.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel515.TextScaled = true
textlabel515.TextWrapped = true
textlabel515.BackgroundTransparency = 1
textlabel515.Position = UDim2.new(0, 0, 0, 158)
textlabel515.Size = UDim2.new(1, 0, 0, 18)
textlabel515.Name = "Like"
textlabel515.Parent = frame506

-- Creating TextLabel
local textlabel516 = Instance.new("TextLabel")
textlabel516.Text = "Universal Script 📌"
textlabel516.TextColor3 = Color3.new(1, 1, 1)
textlabel516.TextScaled = true
textlabel516.TextWrapped = true
textlabel516.BackgroundTransparency = 1
textlabel516.Position = UDim2.new(0, 0, 0, 176)
textlabel516.Size = UDim2.new(1, 0, 0, 18)
textlabel516.Name = "IsUniversal"
textlabel516.Parent = frame506

-- Creating TextButton
local textbutton517 = Instance.new("TextButton")
textbutton517.Text = "EXECUTE"
textbutton517.TextColor3 = Color3.new(1, 1, 1)
textbutton517.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton517.Position = UDim2.new(0, 0, 1, -20)
textbutton517.Size = UDim2.new(1, 0, 0, 20)
textbutton517.Parent = frame506

-- Creating UICorner
local uicorner518 = Instance.new("UICorner")
uicorner518.Parent = textbutton517

-- Creating TextButton
local textbutton519 = Instance.new("TextButton")
textbutton519.Text = "COPY TO CLIPBOARD"
textbutton519.TextColor3 = Color3.new(1, 1, 1)
textbutton519.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton519.Position = UDim2.new(0, 0, 1, -44)
textbutton519.Size = UDim2.new(1, 0, 0, 20)
textbutton519.Name = "copy"
textbutton519.Parent = frame506

-- Creating UICorner
local uicorner520 = Instance.new("UICorner")
uicorner520.Parent = textbutton519

-- Creating Frame
local frame521 = Instance.new("Frame")
frame521.BackgroundColor3 = Color3.new(0.07058823853731155, 0.07058823853731155, 0.08235294371843338)
frame521.BackgroundTransparency = 0.25
frame521.Size = UDim2.new(0, 220, 0, 250)
frame521.Name = "Handle"
frame521.Parent = scrollingframe481

-- Creating UICorner
local uicorner522 = Instance.new("UICorner")
uicorner522.Parent = frame521

-- Creating UIGradient
local uigradient523 = Instance.new("UIGradient")
uigradient523.Rotation = 90
uigradient523.Parent = frame521

-- Creating UIScale
local uiscale524 = Instance.new("UIScale")
uiscale524.Parent = frame521

-- Creating Frame
local frame525 = Instance.new("Frame")
frame525.BackgroundTransparency = 1
frame525.Position = UDim2.new(0, 4, 0, 4)
frame525.Size = UDim2.new(1, -8, 1, -8)
frame525.Parent = frame521

-- Creating TextLabel
local textlabel526 = Instance.new("TextLabel")
textlabel526.Text = "ONICheats universal aimbot"
textlabel526.TextColor3 = Color3.new(1, 1, 1)
textlabel526.TextScaled = true
textlabel526.TextWrapped = true
textlabel526.BackgroundTransparency = 1
textlabel526.Size = UDim2.new(1, 0, 0, 40)
textlabel526.Name = "Title"
textlabel526.Parent = frame525

-- Creating ImageLabel
local imagelabel527 = Instance.new("ImageLabel")
imagelabel527.Image = "https://scriptblox.com/images/script/0-1781697573135.png"
imagelabel527.BackgroundTransparency = 0.30000001192092896
imagelabel527.Position = UDim2.new(0, 0, 0, 42)
imagelabel527.Size = UDim2.new(1, 0, 0, 100)
imagelabel527.Name = "ImageAsset"
imagelabel527.Parent = frame525

-- Creating UICorner
local uicorner528 = Instance.new("UICorner")
uicorner528.Parent = imagelabel527

-- Creating UIListLayout
local uilistlayout529 = Instance.new("UIListLayout")
uilistlayout529.Parent = imagelabel527

-- Creating TextLabel
local textlabel530 = Instance.new("TextLabel")
textlabel530.Text = "Key"
textlabel530.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel530.TextScaled = true
textlabel530.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel530.TextStrokeTransparency = 0
textlabel530.TextWrapped = true
textlabel530.BackgroundTransparency = 1
textlabel530.Size = UDim2.new(0.5, 0, 0, 18)
textlabel530.Visible = false
textlabel530.Name = "KEY"
textlabel530.Parent = imagelabel527

-- Creating TextLabel
local textlabel531 = Instance.new("TextLabel")
textlabel531.Text = "Patched"
textlabel531.TextColor3 = Color3.new(1, 0, 0)
textlabel531.TextScaled = true
textlabel531.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel531.TextStrokeTransparency = 0
textlabel531.TextWrapped = true
textlabel531.BackgroundTransparency = 1
textlabel531.Size = UDim2.new(0.5, 0, 0, 18)
textlabel531.Visible = false
textlabel531.Name = "Patched"
textlabel531.Parent = imagelabel527

-- Creating TextLabel
local textlabel532 = Instance.new("TextLabel")
textlabel532.Text = "Verified"
textlabel532.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel532.TextScaled = true
textlabel532.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel532.TextStrokeTransparency = 0
textlabel532.TextWrapped = true
textlabel532.BackgroundTransparency = 1
textlabel532.Size = UDim2.new(0.5, 0, 0, 18)
textlabel532.Visible = false
textlabel532.Name = "Verified"
textlabel532.Parent = imagelabel527

-- Creating TextLabel
local textlabel533 = Instance.new("TextLabel")
textlabel533.Text = "Visits: 6156"
textlabel533.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel533.TextScaled = true
textlabel533.TextWrapped = true
textlabel533.BackgroundTransparency = 1
textlabel533.Position = UDim2.new(0, 0, 0, 142)
textlabel533.Size = UDim2.new(1, 0, 0, 18)
textlabel533.Name = "Visit"
textlabel533.Parent = frame525

-- Creating TextLabel
local textlabel534 = Instance.new("TextLabel")
textlabel534.Text = "Likes: 0"
textlabel534.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel534.TextScaled = true
textlabel534.TextWrapped = true
textlabel534.BackgroundTransparency = 1
textlabel534.Position = UDim2.new(0, 0, 0, 158)
textlabel534.Size = UDim2.new(1, 0, 0, 18)
textlabel534.Name = "Like"
textlabel534.Parent = frame525

-- Creating TextLabel
local textlabel535 = Instance.new("TextLabel")
textlabel535.Text = "Universal Script 📌"
textlabel535.TextColor3 = Color3.new(1, 1, 1)
textlabel535.TextScaled = true
textlabel535.TextWrapped = true
textlabel535.BackgroundTransparency = 1
textlabel535.Position = UDim2.new(0, 0, 0, 176)
textlabel535.Size = UDim2.new(1, 0, 0, 18)
textlabel535.Name = "IsUniversal"
textlabel535.Parent = frame525

-- Creating TextButton
local textbutton536 = Instance.new("TextButton")
textbutton536.Text = "EXECUTE"
textbutton536.TextColor3 = Color3.new(1, 1, 1)
textbutton536.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton536.Position = UDim2.new(0, 0, 1, -20)
textbutton536.Size = UDim2.new(1, 0, 0, 20)
textbutton536.Parent = frame525

-- Creating UICorner
local uicorner537 = Instance.new("UICorner")
uicorner537.Parent = textbutton536

-- Creating TextButton
local textbutton538 = Instance.new("TextButton")
textbutton538.Text = "COPY TO CLIPBOARD"
textbutton538.TextColor3 = Color3.new(1, 1, 1)
textbutton538.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton538.Position = UDim2.new(0, 0, 1, -44)
textbutton538.Size = UDim2.new(1, 0, 0, 20)
textbutton538.Name = "copy"
textbutton538.Parent = frame525

-- Creating UICorner
local uicorner539 = Instance.new("UICorner")
uicorner539.Parent = textbutton538

-- Creating Frame
local frame540 = Instance.new("Frame")
frame540.BackgroundColor3 = Color3.new(0, 1, 1)
frame540.BackgroundTransparency = 0.25
frame540.Size = UDim2.new(0, 220, 0, 250)
frame540.Name = "Handle"
frame540.Parent = scrollingframe481

-- Creating UICorner
local uicorner541 = Instance.new("UICorner")
uicorner541.Parent = frame540

-- Creating UIGradient
local uigradient542 = Instance.new("UIGradient")
uigradient542.Rotation = 90
uigradient542.Parent = frame540

-- Creating UIScale
local uiscale543 = Instance.new("UIScale")
uiscale543.Parent = frame540

-- Creating Frame
local frame544 = Instance.new("Frame")
frame544.BackgroundTransparency = 1
frame544.Position = UDim2.new(0, 4, 0, 4)
frame544.Size = UDim2.new(1, -8, 1, -8)
frame544.Parent = frame540

-- Creating TextLabel
local textlabel545 = Instance.new("TextLabel")
textlabel545.Text = "Flow ScriptHub 20 Games"
textlabel545.TextColor3 = Color3.new(1, 1, 1)
textlabel545.TextScaled = true
textlabel545.TextWrapped = true
textlabel545.BackgroundTransparency = 1
textlabel545.Size = UDim2.new(1, 0, 0, 40)
textlabel545.Name = "Title"
textlabel545.Parent = frame544

-- Creating ImageLabel
local imagelabel546 = Instance.new("ImageLabel")
imagelabel546.Image = "https://scriptblox.com/images/script/0-1782834157294.png"
imagelabel546.BackgroundTransparency = 0.30000001192092896
imagelabel546.Position = UDim2.new(0, 0, 0, 42)
imagelabel546.Size = UDim2.new(1, 0, 0, 100)
imagelabel546.Name = "ImageAsset"
imagelabel546.Parent = frame544

-- Creating UICorner
local uicorner547 = Instance.new("UICorner")
uicorner547.Parent = imagelabel546

-- Creating UIListLayout
local uilistlayout548 = Instance.new("UIListLayout")
uilistlayout548.Parent = imagelabel546

-- Creating TextLabel
local textlabel549 = Instance.new("TextLabel")
textlabel549.Text = "Key"
textlabel549.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel549.TextScaled = true
textlabel549.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel549.TextStrokeTransparency = 0
textlabel549.TextWrapped = true
textlabel549.BackgroundTransparency = 1
textlabel549.Size = UDim2.new(0.5, 0, 0, 18)
textlabel549.Name = "KEY"
textlabel549.Parent = imagelabel546

-- Creating TextLabel
local textlabel550 = Instance.new("TextLabel")
textlabel550.Text = "Patched"
textlabel550.TextColor3 = Color3.new(1, 0, 0)
textlabel550.TextScaled = true
textlabel550.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel550.TextStrokeTransparency = 0
textlabel550.TextWrapped = true
textlabel550.BackgroundTransparency = 1
textlabel550.Size = UDim2.new(0.5, 0, 0, 18)
textlabel550.Visible = false
textlabel550.Name = "Patched"
textlabel550.Parent = imagelabel546

-- Creating TextLabel
local textlabel551 = Instance.new("TextLabel")
textlabel551.Text = "Verified"
textlabel551.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel551.TextScaled = true
textlabel551.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel551.TextStrokeTransparency = 0
textlabel551.TextWrapped = true
textlabel551.BackgroundTransparency = 1
textlabel551.Size = UDim2.new(0.5, 0, 0, 18)
textlabel551.Name = "Verified"
textlabel551.Parent = imagelabel546

-- Creating TextLabel
local textlabel552 = Instance.new("TextLabel")
textlabel552.Text = "Visits: 6444"
textlabel552.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel552.TextScaled = true
textlabel552.TextWrapped = true
textlabel552.BackgroundTransparency = 1
textlabel552.Position = UDim2.new(0, 0, 0, 142)
textlabel552.Size = UDim2.new(1, 0, 0, 18)
textlabel552.Name = "Visit"
textlabel552.Parent = frame544

-- Creating TextLabel
local textlabel553 = Instance.new("TextLabel")
textlabel553.Text = "Likes: 0"
textlabel553.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel553.TextScaled = true
textlabel553.TextWrapped = true
textlabel553.BackgroundTransparency = 1
textlabel553.Position = UDim2.new(0, 0, 0, 158)
textlabel553.Size = UDim2.new(1, 0, 0, 18)
textlabel553.Name = "Like"
textlabel553.Parent = frame544

-- Creating TextLabel
local textlabel554 = Instance.new("TextLabel")
textlabel554.Text = "Universal Script 📌"
textlabel554.TextColor3 = Color3.new(1, 1, 1)
textlabel554.TextScaled = true
textlabel554.TextWrapped = true
textlabel554.BackgroundTransparency = 1
textlabel554.Position = UDim2.new(0, 0, 0, 176)
textlabel554.Size = UDim2.new(1, 0, 0, 18)
textlabel554.Name = "IsUniversal"
textlabel554.Parent = frame544

-- Creating TextButton
local textbutton555 = Instance.new("TextButton")
textbutton555.Text = "EXECUTE"
textbutton555.TextColor3 = Color3.new(1, 1, 1)
textbutton555.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton555.Position = UDim2.new(0, 0, 1, -20)
textbutton555.Size = UDim2.new(1, 0, 0, 20)
textbutton555.Parent = frame544

-- Creating UICorner
local uicorner556 = Instance.new("UICorner")
uicorner556.Parent = textbutton555

-- Creating TextButton
local textbutton557 = Instance.new("TextButton")
textbutton557.Text = "COPY TO CLIPBOARD"
textbutton557.TextColor3 = Color3.new(1, 1, 1)
textbutton557.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton557.Position = UDim2.new(0, 0, 1, -44)
textbutton557.Size = UDim2.new(1, 0, 0, 20)
textbutton557.Name = "copy"
textbutton557.Parent = frame544

-- Creating UICorner
local uicorner558 = Instance.new("UICorner")
uicorner558.Parent = textbutton557

-- Creating Frame
local frame559 = Instance.new("Frame")
frame559.BackgroundColor3 = Color3.new(0.07058823853731155, 0.07058823853731155, 0.08235294371843338)
frame559.BackgroundTransparency = 0.25
frame559.Size = UDim2.new(0, 220, 0, 250)
frame559.Name = "Handle"
frame559.Parent = scrollingframe481

-- Creating UICorner
local uicorner560 = Instance.new("UICorner")
uicorner560.Parent = frame559

-- Creating UIGradient
local uigradient561 = Instance.new("UIGradient")
uigradient561.Rotation = 90
uigradient561.Parent = frame559

-- Creating UIScale
local uiscale562 = Instance.new("UIScale")
uiscale562.Parent = frame559

-- Creating Frame
local frame563 = Instance.new("Frame")
frame563.BackgroundTransparency = 1
frame563.Position = UDim2.new(0, 4, 0, 4)
frame563.Size = UDim2.new(1, -8, 1, -8)
frame563.Parent = frame559

-- Creating TextLabel
local textlabel564 = Instance.new("TextLabel")
textlabel564.Text = "Kyo Hub - AUTO GEAR 5 AND MUCH MORE !"
textlabel564.TextColor3 = Color3.new(1, 1, 1)
textlabel564.TextScaled = true
textlabel564.TextWrapped = true
textlabel564.BackgroundTransparency = 1
textlabel564.Size = UDim2.new(1, 0, 0, 40)
textlabel564.Name = "Title"
textlabel564.Parent = frame563

-- Creating ImageLabel
local imagelabel565 = Instance.new("ImageLabel")
imagelabel565.Image = "https://scriptblox.com/images/script/5130598377-1782926071392.png"
imagelabel565.BackgroundTransparency = 0.30000001192092896
imagelabel565.Position = UDim2.new(0, 0, 0, 42)
imagelabel565.Size = UDim2.new(1, 0, 0, 100)
imagelabel565.Name = "ImageAsset"
imagelabel565.Parent = frame563

-- Creating UICorner
local uicorner566 = Instance.new("UICorner")
uicorner566.Parent = imagelabel565

-- Creating UIListLayout
local uilistlayout567 = Instance.new("UIListLayout")
uilistlayout567.Parent = imagelabel565

-- Creating TextLabel
local textlabel568 = Instance.new("TextLabel")
textlabel568.Text = "Key"
textlabel568.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel568.TextScaled = true
textlabel568.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel568.TextStrokeTransparency = 0
textlabel568.TextWrapped = true
textlabel568.BackgroundTransparency = 1
textlabel568.Size = UDim2.new(0.5, 0, 0, 18)
textlabel568.Visible = false
textlabel568.Name = "KEY"
textlabel568.Parent = imagelabel565

-- Creating TextLabel
local textlabel569 = Instance.new("TextLabel")
textlabel569.Text = "Patched"
textlabel569.TextColor3 = Color3.new(1, 0, 0)
textlabel569.TextScaled = true
textlabel569.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel569.TextStrokeTransparency = 0
textlabel569.TextWrapped = true
textlabel569.BackgroundTransparency = 1
textlabel569.Size = UDim2.new(0.5, 0, 0, 18)
textlabel569.Visible = false
textlabel569.Name = "Patched"
textlabel569.Parent = imagelabel565

-- Creating TextLabel
local textlabel570 = Instance.new("TextLabel")
textlabel570.Text = "Verified"
textlabel570.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel570.TextScaled = true
textlabel570.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel570.TextStrokeTransparency = 0
textlabel570.TextWrapped = true
textlabel570.BackgroundTransparency = 1
textlabel570.Size = UDim2.new(0.5, 0, 0, 18)
textlabel570.Visible = false
textlabel570.Name = "Verified"
textlabel570.Parent = imagelabel565

-- Creating TextLabel
local textlabel571 = Instance.new("TextLabel")
textlabel571.Text = "Visits: 4246"
textlabel571.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel571.TextScaled = true
textlabel571.TextWrapped = true
textlabel571.BackgroundTransparency = 1
textlabel571.Position = UDim2.new(0, 0, 0, 142)
textlabel571.Size = UDim2.new(1, 0, 0, 18)
textlabel571.Name = "Visit"
textlabel571.Parent = frame563

-- Creating TextLabel
local textlabel572 = Instance.new("TextLabel")
textlabel572.Text = "Likes: 0"
textlabel572.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel572.TextScaled = true
textlabel572.TextWrapped = true
textlabel572.BackgroundTransparency = 1
textlabel572.Position = UDim2.new(0, 0, 0, 158)
textlabel572.Size = UDim2.new(1, 0, 0, 18)
textlabel572.Name = "Like"
textlabel572.Parent = frame563

-- Creating TextLabel
local textlabel573 = Instance.new("TextLabel")
textlabel573.Text = "[🧊HIE & ROKUSHIKI👊] A Universal Time"
textlabel573.TextColor3 = Color3.new(1, 1, 1)
textlabel573.TextScaled = true
textlabel573.TextWrapped = true
textlabel573.BackgroundTransparency = 1
textlabel573.Position = UDim2.new(0, 0, 0, 176)
textlabel573.Size = UDim2.new(1, 0, 0, 18)
textlabel573.Name = "IsUniversal"
textlabel573.Parent = frame563

-- Creating TextButton
local textbutton574 = Instance.new("TextButton")
textbutton574.Text = "EXECUTE"
textbutton574.TextColor3 = Color3.new(1, 1, 1)
textbutton574.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton574.Position = UDim2.new(0, 0, 1, -20)
textbutton574.Size = UDim2.new(1, 0, 0, 20)
textbutton574.Parent = frame563

-- Creating UICorner
local uicorner575 = Instance.new("UICorner")
uicorner575.Parent = textbutton574

-- Creating TextButton
local textbutton576 = Instance.new("TextButton")
textbutton576.Text = "COPY TO CLIPBOARD"
textbutton576.TextColor3 = Color3.new(1, 1, 1)
textbutton576.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton576.Position = UDim2.new(0, 0, 1, -44)
textbutton576.Size = UDim2.new(1, 0, 0, 20)
textbutton576.Name = "copy"
textbutton576.Parent = frame563

-- Creating UICorner
local uicorner577 = Instance.new("UICorner")
uicorner577.Parent = textbutton576

-- Creating Frame
local frame578 = Instance.new("Frame")
frame578.BackgroundColor3 = Color3.new(1, 0.42352941632270813, 0)
frame578.BackgroundTransparency = 0.25
frame578.Size = UDim2.new(0, 220, 0, 250)
frame578.Name = "Handle"
frame578.Parent = scrollingframe481

-- Creating UICorner
local uicorner579 = Instance.new("UICorner")
uicorner579.Parent = frame578

-- Creating UIGradient
local uigradient580 = Instance.new("UIGradient")
uigradient580.Rotation = 90
uigradient580.Parent = frame578

-- Creating UIScale
local uiscale581 = Instance.new("UIScale")
uiscale581.Parent = frame578

-- Creating Frame
local frame582 = Instance.new("Frame")
frame582.BackgroundTransparency = 1
frame582.Position = UDim2.new(0, 4, 0, 4)
frame582.Size = UDim2.new(1, -8, 1, -8)
frame582.Parent = frame578

-- Creating TextLabel
local textlabel583 = Instance.new("TextLabel")
textlabel583.Text = "BEST | Auto Fish, Auto Farm, Abuse Quests, Flags And MORE!!"
textlabel583.TextColor3 = Color3.new(1, 1, 1)
textlabel583.TextScaled = true
textlabel583.TextWrapped = true
textlabel583.BackgroundTransparency = 1
textlabel583.Size = UDim2.new(1, 0, 0, 40)
textlabel583.Name = "Title"
textlabel583.Parent = frame582

-- Creating ImageLabel
local imagelabel584 = Instance.new("ImageLabel")
imagelabel584.Image = "rbxassetid://118914662369732"
imagelabel584.BackgroundTransparency = 0.30000001192092896
imagelabel584.Position = UDim2.new(0, 0, 0, 42)
imagelabel584.Size = UDim2.new(1, 0, 0, 100)
imagelabel584.Name = "ImageAsset"
imagelabel584.Parent = frame582

-- Creating UICorner
local uicorner585 = Instance.new("UICorner")
uicorner585.Parent = imagelabel584

-- Creating UIListLayout
local uilistlayout586 = Instance.new("UIListLayout")
uilistlayout586.Parent = imagelabel584

-- Creating TextLabel
local textlabel587 = Instance.new("TextLabel")
textlabel587.Text = "Key"
textlabel587.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel587.TextScaled = true
textlabel587.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel587.TextStrokeTransparency = 0
textlabel587.TextWrapped = true
textlabel587.BackgroundTransparency = 1
textlabel587.Size = UDim2.new(0.5, 0, 0, 18)
textlabel587.Name = "KEY"
textlabel587.Parent = imagelabel584

-- Creating TextLabel
local textlabel588 = Instance.new("TextLabel")
textlabel588.Text = "Patched"
textlabel588.TextColor3 = Color3.new(1, 0, 0)
textlabel588.TextScaled = true
textlabel588.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel588.TextStrokeTransparency = 0
textlabel588.TextWrapped = true
textlabel588.BackgroundTransparency = 1
textlabel588.Size = UDim2.new(0.5, 0, 0, 18)
textlabel588.Visible = false
textlabel588.Name = "Patched"
textlabel588.Parent = imagelabel584

-- Creating TextLabel
local textlabel589 = Instance.new("TextLabel")
textlabel589.Text = "Verified"
textlabel589.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel589.TextScaled = true
textlabel589.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel589.TextStrokeTransparency = 0
textlabel589.TextWrapped = true
textlabel589.BackgroundTransparency = 1
textlabel589.Size = UDim2.new(0.5, 0, 0, 18)
textlabel589.Visible = false
textlabel589.Name = "Verified"
textlabel589.Parent = imagelabel584

-- Creating TextLabel
local textlabel590 = Instance.new("TextLabel")
textlabel590.Text = "Visits: 6475"
textlabel590.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel590.TextScaled = true
textlabel590.TextWrapped = true
textlabel590.BackgroundTransparency = 1
textlabel590.Position = UDim2.new(0, 0, 0, 142)
textlabel590.Size = UDim2.new(1, 0, 0, 18)
textlabel590.Name = "Visit"
textlabel590.Parent = frame582

-- Creating TextLabel
local textlabel591 = Instance.new("TextLabel")
textlabel591.Text = "Likes: 0"
textlabel591.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel591.TextScaled = true
textlabel591.TextWrapped = true
textlabel591.BackgroundTransparency = 1
textlabel591.Position = UDim2.new(0, 0, 0, 158)
textlabel591.Size = UDim2.new(1, 0, 0, 18)
textlabel591.Name = "Like"
textlabel591.Parent = frame582

-- Creating TextLabel
local textlabel592 = Instance.new("TextLabel")
textlabel592.Text = "Pilgrammed: Early Sunset / Ex Machina"
textlabel592.TextColor3 = Color3.new(1, 1, 1)
textlabel592.TextScaled = true
textlabel592.TextWrapped = true
textlabel592.BackgroundTransparency = 1
textlabel592.Position = UDim2.new(0, 0, 0, 176)
textlabel592.Size = UDim2.new(1, 0, 0, 18)
textlabel592.Name = "IsUniversal"
textlabel592.Parent = frame582

-- Creating TextButton
local textbutton593 = Instance.new("TextButton")
textbutton593.Text = "EXECUTE"
textbutton593.TextColor3 = Color3.new(1, 1, 1)
textbutton593.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton593.Position = UDim2.new(0, 0, 1, -20)
textbutton593.Size = UDim2.new(1, 0, 0, 20)
textbutton593.Parent = frame582

-- Creating UICorner
local uicorner594 = Instance.new("UICorner")
uicorner594.Parent = textbutton593

-- Creating TextButton
local textbutton595 = Instance.new("TextButton")
textbutton595.Text = "COPY TO CLIPBOARD"
textbutton595.TextColor3 = Color3.new(1, 1, 1)
textbutton595.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton595.Position = UDim2.new(0, 0, 1, -44)
textbutton595.Size = UDim2.new(1, 0, 0, 20)
textbutton595.Name = "copy"
textbutton595.Parent = frame582

-- Creating UICorner
local uicorner596 = Instance.new("UICorner")
uicorner596.Parent = textbutton595

-- Creating Frame
local frame597 = Instance.new("Frame")
frame597.BackgroundColor3 = Color3.new(0, 1, 1)
frame597.BackgroundTransparency = 0.25
frame597.Size = UDim2.new(0, 220, 0, 250)
frame597.Name = "Handle"
frame597.Parent = scrollingframe481

-- Creating UICorner
local uicorner598 = Instance.new("UICorner")
uicorner598.Parent = frame597

-- Creating UIGradient
local uigradient599 = Instance.new("UIGradient")
uigradient599.Rotation = 90
uigradient599.Parent = frame597

-- Creating UIScale
local uiscale600 = Instance.new("UIScale")
uiscale600.Parent = frame597

-- Creating Frame
local frame601 = Instance.new("Frame")
frame601.BackgroundTransparency = 1
frame601.Position = UDim2.new(0, 4, 0, 4)
frame601.Size = UDim2.new(1, -8, 1, -8)
frame601.Parent = frame597

-- Creating TextLabel
local textlabel602 = Instance.new("TextLabel")
textlabel602.Text = "SOLIXHUB DELTA XENO GODMOE AUTO FARM AUTO HELP AUTO ALL"
textlabel602.TextColor3 = Color3.new(1, 1, 1)
textlabel602.TextScaled = true
textlabel602.TextWrapped = true
textlabel602.BackgroundTransparency = 1
textlabel602.Size = UDim2.new(1, 0, 0, 40)
textlabel602.Name = "Title"
textlabel602.Parent = frame601

-- Creating ImageLabel
local imagelabel603 = Instance.new("ImageLabel")
imagelabel603.Image = "https://scriptblox.com/images/script/78515283254292-1783084505601.png"
imagelabel603.BackgroundTransparency = 0.30000001192092896
imagelabel603.Position = UDim2.new(0, 0, 0, 42)
imagelabel603.Size = UDim2.new(1, 0, 0, 100)
imagelabel603.Name = "ImageAsset"
imagelabel603.Parent = frame601

-- Creating UICorner
local uicorner604 = Instance.new("UICorner")
uicorner604.Parent = imagelabel603

-- Creating UIListLayout
local uilistlayout605 = Instance.new("UIListLayout")
uilistlayout605.Parent = imagelabel603

-- Creating TextLabel
local textlabel606 = Instance.new("TextLabel")
textlabel606.Text = "Key"
textlabel606.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel606.TextScaled = true
textlabel606.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel606.TextStrokeTransparency = 0
textlabel606.TextWrapped = true
textlabel606.BackgroundTransparency = 1
textlabel606.Size = UDim2.new(0.5, 0, 0, 18)
textlabel606.Visible = false
textlabel606.Name = "KEY"
textlabel606.Parent = imagelabel603

-- Creating TextLabel
local textlabel607 = Instance.new("TextLabel")
textlabel607.Text = "Patched"
textlabel607.TextColor3 = Color3.new(1, 0, 0)
textlabel607.TextScaled = true
textlabel607.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel607.TextStrokeTransparency = 0
textlabel607.TextWrapped = true
textlabel607.BackgroundTransparency = 1
textlabel607.Size = UDim2.new(0.5, 0, 0, 18)
textlabel607.Visible = false
textlabel607.Name = "Patched"
textlabel607.Parent = imagelabel603

-- Creating TextLabel
local textlabel608 = Instance.new("TextLabel")
textlabel608.Text = "Verified"
textlabel608.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel608.TextScaled = true
textlabel608.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel608.TextStrokeTransparency = 0
textlabel608.TextWrapped = true
textlabel608.BackgroundTransparency = 1
textlabel608.Size = UDim2.new(0.5, 0, 0, 18)
textlabel608.Name = "Verified"
textlabel608.Parent = imagelabel603

-- Creating TextLabel
local textlabel609 = Instance.new("TextLabel")
textlabel609.Text = "Visits: 1168"
textlabel609.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel609.TextScaled = true
textlabel609.TextWrapped = true
textlabel609.BackgroundTransparency = 1
textlabel609.Position = UDim2.new(0, 0, 0, 142)
textlabel609.Size = UDim2.new(1, 0, 0, 18)
textlabel609.Name = "Visit"
textlabel609.Parent = frame601

-- Creating TextLabel
local textlabel610 = Instance.new("TextLabel")
textlabel610.Text = "Likes: 0"
textlabel610.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel610.TextScaled = true
textlabel610.TextWrapped = true
textlabel610.BackgroundTransparency = 1
textlabel610.Position = UDim2.new(0, 0, 0, 158)
textlabel610.Size = UDim2.new(1, 0, 0, 18)
textlabel610.Name = "Like"
textlabel610.Parent = frame601

-- Creating TextLabel
local textlabel611 = Instance.new("TextLabel")
textlabel611.Text = "Animal Hospital (Anomaly) 🧪"
textlabel611.TextColor3 = Color3.new(1, 1, 1)
textlabel611.TextScaled = true
textlabel611.TextWrapped = true
textlabel611.BackgroundTransparency = 1
textlabel611.Position = UDim2.new(0, 0, 0, 176)
textlabel611.Size = UDim2.new(1, 0, 0, 18)
textlabel611.Name = "IsUniversal"
textlabel611.Parent = frame601

-- Creating TextButton
local textbutton612 = Instance.new("TextButton")
textbutton612.Text = "EXECUTE"
textbutton612.TextColor3 = Color3.new(1, 1, 1)
textbutton612.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton612.Position = UDim2.new(0, 0, 1, -20)
textbutton612.Size = UDim2.new(1, 0, 0, 20)
textbutton612.Parent = frame601

-- Creating UICorner
local uicorner613 = Instance.new("UICorner")
uicorner613.Parent = textbutton612

-- Creating TextButton
local textbutton614 = Instance.new("TextButton")
textbutton614.Text = "COPY TO CLIPBOARD"
textbutton614.TextColor3 = Color3.new(1, 1, 1)
textbutton614.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton614.Position = UDim2.new(0, 0, 1, -44)
textbutton614.Size = UDim2.new(1, 0, 0, 20)
textbutton614.Name = "copy"
textbutton614.Parent = frame601

-- Creating UICorner
local uicorner615 = Instance.new("UICorner")
uicorner615.Parent = textbutton614

-- Creating Frame
local frame616 = Instance.new("Frame")
frame616.BackgroundColor3 = Color3.new(0, 1, 1)
frame616.BackgroundTransparency = 0.25
frame616.Size = UDim2.new(0, 220, 0, 250)
frame616.Name = "Handle"
frame616.Parent = scrollingframe481

-- Creating UICorner
local uicorner617 = Instance.new("UICorner")
uicorner617.Parent = frame616

-- Creating UIGradient
local uigradient618 = Instance.new("UIGradient")
uigradient618.Rotation = 90
uigradient618.Parent = frame616

-- Creating UIScale
local uiscale619 = Instance.new("UIScale")
uiscale619.Parent = frame616

-- Creating Frame
local frame620 = Instance.new("Frame")
frame620.BackgroundTransparency = 1
frame620.Position = UDim2.new(0, 4, 0, 4)
frame620.Size = UDim2.new(1, -8, 1, -8)
frame620.Parent = frame616

-- Creating TextLabel
local textlabel621 = Instance.new("TextLabel")
textlabel621.Text = "BEST SCRIPT FULL XENO DELTA 180+ STACKING FEATURES FREE OP"
textlabel621.TextColor3 = Color3.new(1, 1, 1)
textlabel621.TextScaled = true
textlabel621.TextWrapped = true
textlabel621.BackgroundTransparency = 1
textlabel621.Size = UDim2.new(1, 0, 0, 40)
textlabel621.Name = "Title"
textlabel621.Parent = frame620

-- Creating ImageLabel
local imagelabel622 = Instance.new("ImageLabel")
imagelabel622.Image = "https://scriptblox.com/images/script/2753915549-1775777816748.jpg"
imagelabel622.BackgroundTransparency = 0.30000001192092896
imagelabel622.Position = UDim2.new(0, 0, 0, 42)
imagelabel622.Size = UDim2.new(1, 0, 0, 100)
imagelabel622.Name = "ImageAsset"
imagelabel622.Parent = frame620

-- Creating UICorner
local uicorner623 = Instance.new("UICorner")
uicorner623.Parent = imagelabel622

-- Creating UIListLayout
local uilistlayout624 = Instance.new("UIListLayout")
uilistlayout624.Parent = imagelabel622

-- Creating TextLabel
local textlabel625 = Instance.new("TextLabel")
textlabel625.Text = "Key"
textlabel625.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel625.TextScaled = true
textlabel625.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel625.TextStrokeTransparency = 0
textlabel625.TextWrapped = true
textlabel625.BackgroundTransparency = 1
textlabel625.Size = UDim2.new(0.5, 0, 0, 18)
textlabel625.Name = "KEY"
textlabel625.Parent = imagelabel622

-- Creating TextLabel
local textlabel626 = Instance.new("TextLabel")
textlabel626.Text = "Patched"
textlabel626.TextColor3 = Color3.new(1, 0, 0)
textlabel626.TextScaled = true
textlabel626.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel626.TextStrokeTransparency = 0
textlabel626.TextWrapped = true
textlabel626.BackgroundTransparency = 1
textlabel626.Size = UDim2.new(0.5, 0, 0, 18)
textlabel626.Visible = false
textlabel626.Name = "Patched"
textlabel626.Parent = imagelabel622

-- Creating TextLabel
local textlabel627 = Instance.new("TextLabel")
textlabel627.Text = "Verified"
textlabel627.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel627.TextScaled = true
textlabel627.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel627.TextStrokeTransparency = 0
textlabel627.TextWrapped = true
textlabel627.BackgroundTransparency = 1
textlabel627.Size = UDim2.new(0.5, 0, 0, 18)
textlabel627.Name = "Verified"
textlabel627.Parent = imagelabel622

-- Creating TextLabel
local textlabel628 = Instance.new("TextLabel")
textlabel628.Text = "Visits: 2974669"
textlabel628.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel628.TextScaled = true
textlabel628.TextWrapped = true
textlabel628.BackgroundTransparency = 1
textlabel628.Position = UDim2.new(0, 0, 0, 142)
textlabel628.Size = UDim2.new(1, 0, 0, 18)
textlabel628.Name = "Visit"
textlabel628.Parent = frame620

-- Creating TextLabel
local textlabel629 = Instance.new("TextLabel")
textlabel629.Text = "Likes: 0"
textlabel629.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel629.TextScaled = true
textlabel629.TextWrapped = true
textlabel629.BackgroundTransparency = 1
textlabel629.Position = UDim2.new(0, 0, 0, 158)
textlabel629.Size = UDim2.new(1, 0, 0, 18)
textlabel629.Name = "Like"
textlabel629.Parent = frame620

-- Creating TextLabel
local textlabel630 = Instance.new("TextLabel")
textlabel630.Text = "Blox Fruits"
textlabel630.TextColor3 = Color3.new(1, 1, 1)
textlabel630.TextScaled = true
textlabel630.TextWrapped = true
textlabel630.BackgroundTransparency = 1
textlabel630.Position = UDim2.new(0, 0, 0, 176)
textlabel630.Size = UDim2.new(1, 0, 0, 18)
textlabel630.Name = "IsUniversal"
textlabel630.Parent = frame620

-- Creating TextButton
local textbutton631 = Instance.new("TextButton")
textbutton631.Text = "EXECUTE"
textbutton631.TextColor3 = Color3.new(1, 1, 1)
textbutton631.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton631.Position = UDim2.new(0, 0, 1, -20)
textbutton631.Size = UDim2.new(1, 0, 0, 20)
textbutton631.Parent = frame620

-- Creating UICorner
local uicorner632 = Instance.new("UICorner")
uicorner632.Parent = textbutton631

-- Creating TextButton
local textbutton633 = Instance.new("TextButton")
textbutton633.Text = "COPY TO CLIPBOARD"
textbutton633.TextColor3 = Color3.new(1, 1, 1)
textbutton633.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton633.Position = UDim2.new(0, 0, 1, -44)
textbutton633.Size = UDim2.new(1, 0, 0, 20)
textbutton633.Name = "copy"
textbutton633.Parent = frame620

-- Creating UICorner
local uicorner634 = Instance.new("UICorner")
uicorner634.Parent = textbutton633

-- Creating Frame
local frame635 = Instance.new("Frame")
frame635.BackgroundColor3 = Color3.new(0.07058823853731155, 0.07058823853731155, 0.08235294371843338)
frame635.BackgroundTransparency = 0.25
frame635.Size = UDim2.new(0, 220, 0, 250)
frame635.Name = "Handle"
frame635.Parent = scrollingframe481

-- Creating UICorner
local uicorner636 = Instance.new("UICorner")
uicorner636.Parent = frame635

-- Creating UIGradient
local uigradient637 = Instance.new("UIGradient")
uigradient637.Rotation = 90
uigradient637.Parent = frame635

-- Creating UIScale
local uiscale638 = Instance.new("UIScale")
uiscale638.Parent = frame635

-- Creating Frame
local frame639 = Instance.new("Frame")
frame639.BackgroundTransparency = 1
frame639.Position = UDim2.new(0, 4, 0, 4)
frame639.Size = UDim2.new(1, -8, 1, -8)
frame639.Parent = frame635

-- Creating TextLabel
local textlabel640 = Instance.new("TextLabel")
textlabel640.Text = "Vodka hub universal"
textlabel640.TextColor3 = Color3.new(1, 1, 1)
textlabel640.TextScaled = true
textlabel640.TextWrapped = true
textlabel640.BackgroundTransparency = 1
textlabel640.Size = UDim2.new(1, 0, 0, 40)
textlabel640.Name = "Title"
textlabel640.Parent = frame639

-- Creating ImageLabel
local imagelabel641 = Instance.new("ImageLabel")
imagelabel641.Image = "https://scriptblox.com/images/script/0-1779918629760.jpg"
imagelabel641.BackgroundTransparency = 0.30000001192092896
imagelabel641.Position = UDim2.new(0, 0, 0, 42)
imagelabel641.Size = UDim2.new(1, 0, 0, 100)
imagelabel641.Name = "ImageAsset"
imagelabel641.Parent = frame639

-- Creating UICorner
local uicorner642 = Instance.new("UICorner")
uicorner642.Parent = imagelabel641

-- Creating UIListLayout
local uilistlayout643 = Instance.new("UIListLayout")
uilistlayout643.Parent = imagelabel641

-- Creating TextLabel
local textlabel644 = Instance.new("TextLabel")
textlabel644.Text = "Key"
textlabel644.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel644.TextScaled = true
textlabel644.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel644.TextStrokeTransparency = 0
textlabel644.TextWrapped = true
textlabel644.BackgroundTransparency = 1
textlabel644.Size = UDim2.new(0.5, 0, 0, 18)
textlabel644.Visible = false
textlabel644.Name = "KEY"
textlabel644.Parent = imagelabel641

-- Creating TextLabel
local textlabel645 = Instance.new("TextLabel")
textlabel645.Text = "Patched"
textlabel645.TextColor3 = Color3.new(1, 0, 0)
textlabel645.TextScaled = true
textlabel645.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel645.TextStrokeTransparency = 0
textlabel645.TextWrapped = true
textlabel645.BackgroundTransparency = 1
textlabel645.Size = UDim2.new(0.5, 0, 0, 18)
textlabel645.Visible = false
textlabel645.Name = "Patched"
textlabel645.Parent = imagelabel641

-- Creating TextLabel
local textlabel646 = Instance.new("TextLabel")
textlabel646.Text = "Verified"
textlabel646.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel646.TextScaled = true
textlabel646.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel646.TextStrokeTransparency = 0
textlabel646.TextWrapped = true
textlabel646.BackgroundTransparency = 1
textlabel646.Size = UDim2.new(0.5, 0, 0, 18)
textlabel646.Visible = false
textlabel646.Name = "Verified"
textlabel646.Parent = imagelabel641

-- Creating TextLabel
local textlabel647 = Instance.new("TextLabel")
textlabel647.Text = "Visits: 3358"
textlabel647.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel647.TextScaled = true
textlabel647.TextWrapped = true
textlabel647.BackgroundTransparency = 1
textlabel647.Position = UDim2.new(0, 0, 0, 142)
textlabel647.Size = UDim2.new(1, 0, 0, 18)
textlabel647.Name = "Visit"
textlabel647.Parent = frame639

-- Creating TextLabel
local textlabel648 = Instance.new("TextLabel")
textlabel648.Text = "Likes: 0"
textlabel648.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel648.TextScaled = true
textlabel648.TextWrapped = true
textlabel648.BackgroundTransparency = 1
textlabel648.Position = UDim2.new(0, 0, 0, 158)
textlabel648.Size = UDim2.new(1, 0, 0, 18)
textlabel648.Name = "Like"
textlabel648.Parent = frame639

-- Creating TextLabel
local textlabel649 = Instance.new("TextLabel")
textlabel649.Text = "Universal Script 📌"
textlabel649.TextColor3 = Color3.new(1, 1, 1)
textlabel649.TextScaled = true
textlabel649.TextWrapped = true
textlabel649.BackgroundTransparency = 1
textlabel649.Position = UDim2.new(0, 0, 0, 176)
textlabel649.Size = UDim2.new(1, 0, 0, 18)
textlabel649.Name = "IsUniversal"
textlabel649.Parent = frame639

-- Creating TextButton
local textbutton650 = Instance.new("TextButton")
textbutton650.Text = "EXECUTE"
textbutton650.TextColor3 = Color3.new(1, 1, 1)
textbutton650.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton650.Position = UDim2.new(0, 0, 1, -20)
textbutton650.Size = UDim2.new(1, 0, 0, 20)
textbutton650.Parent = frame639

-- Creating UICorner
local uicorner651 = Instance.new("UICorner")
uicorner651.Parent = textbutton650

-- Creating TextButton
local textbutton652 = Instance.new("TextButton")
textbutton652.Text = "COPY TO CLIPBOARD"
textbutton652.TextColor3 = Color3.new(1, 1, 1)
textbutton652.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton652.Position = UDim2.new(0, 0, 1, -44)
textbutton652.Size = UDim2.new(1, 0, 0, 20)
textbutton652.Name = "copy"
textbutton652.Parent = frame639

-- Creating UICorner
local uicorner653 = Instance.new("UICorner")
uicorner653.Parent = textbutton652

-- Creating Frame
local frame654 = Instance.new("Frame")
frame654.BackgroundColor3 = Color3.new(0.07058823853731155, 0.07058823853731155, 0.08235294371843338)
frame654.BackgroundTransparency = 0.25
frame654.Size = UDim2.new(0, 220, 0, 250)
frame654.Name = "Handle"
frame654.Parent = scrollingframe481

-- Creating UICorner
local uicorner655 = Instance.new("UICorner")
uicorner655.Parent = frame654

-- Creating UIGradient
local uigradient656 = Instance.new("UIGradient")
uigradient656.Rotation = 90
uigradient656.Parent = frame654

-- Creating UIScale
local uiscale657 = Instance.new("UIScale")
uiscale657.Parent = frame654

-- Creating Frame
local frame658 = Instance.new("Frame")
frame658.BackgroundTransparency = 1
frame658.Position = UDim2.new(0, 4, 0, 4)
frame658.Size = UDim2.new(1, -8, 1, -8)
frame658.Parent = frame654

-- Creating TextLabel
local textlabel659 = Instance.new("TextLabel")
textlabel659.Text = "Kill Aura Items ESP and more"
textlabel659.TextColor3 = Color3.new(1, 1, 1)
textlabel659.TextScaled = true
textlabel659.TextWrapped = true
textlabel659.BackgroundTransparency = 1
textlabel659.Size = UDim2.new(1, 0, 0, 40)
textlabel659.Name = "Title"
textlabel659.Parent = frame658

-- Creating ImageLabel
local imagelabel660 = Instance.new("ImageLabel")
imagelabel660.Image = "rbxassetid://118914662369732"
imagelabel660.BackgroundTransparency = 0.30000001192092896
imagelabel660.Position = UDim2.new(0, 0, 0, 42)
imagelabel660.Size = UDim2.new(1, 0, 0, 100)
imagelabel660.Name = "ImageAsset"
imagelabel660.Parent = frame658

-- Creating UICorner
local uicorner661 = Instance.new("UICorner")
uicorner661.Parent = imagelabel660

-- Creating UIListLayout
local uilistlayout662 = Instance.new("UIListLayout")
uilistlayout662.Parent = imagelabel660

-- Creating TextLabel
local textlabel663 = Instance.new("TextLabel")
textlabel663.Text = "Key"
textlabel663.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel663.TextScaled = true
textlabel663.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel663.TextStrokeTransparency = 0
textlabel663.TextWrapped = true
textlabel663.BackgroundTransparency = 1
textlabel663.Size = UDim2.new(0.5, 0, 0, 18)
textlabel663.Visible = false
textlabel663.Name = "KEY"
textlabel663.Parent = imagelabel660

-- Creating TextLabel
local textlabel664 = Instance.new("TextLabel")
textlabel664.Text = "Patched"
textlabel664.TextColor3 = Color3.new(1, 0, 0)
textlabel664.TextScaled = true
textlabel664.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel664.TextStrokeTransparency = 0
textlabel664.TextWrapped = true
textlabel664.BackgroundTransparency = 1
textlabel664.Size = UDim2.new(0.5, 0, 0, 18)
textlabel664.Visible = false
textlabel664.Name = "Patched"
textlabel664.Parent = imagelabel660

-- Creating TextLabel
local textlabel665 = Instance.new("TextLabel")
textlabel665.Text = "Verified"
textlabel665.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel665.TextScaled = true
textlabel665.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel665.TextStrokeTransparency = 0
textlabel665.TextWrapped = true
textlabel665.BackgroundTransparency = 1
textlabel665.Size = UDim2.new(0.5, 0, 0, 18)
textlabel665.Visible = false
textlabel665.Name = "Verified"
textlabel665.Parent = imagelabel660

-- Creating TextLabel
local textlabel666 = Instance.new("TextLabel")
textlabel666.Text = "Visits: 785"
textlabel666.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel666.TextScaled = true
textlabel666.TextWrapped = true
textlabel666.BackgroundTransparency = 1
textlabel666.Position = UDim2.new(0, 0, 0, 142)
textlabel666.Size = UDim2.new(1, 0, 0, 18)
textlabel666.Name = "Visit"
textlabel666.Parent = frame658

-- Creating TextLabel
local textlabel667 = Instance.new("TextLabel")
textlabel667.Text = "Likes: 0"
textlabel667.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel667.TextScaled = true
textlabel667.TextWrapped = true
textlabel667.BackgroundTransparency = 1
textlabel667.Position = UDim2.new(0, 0, 0, 158)
textlabel667.Size = UDim2.new(1, 0, 0, 18)
textlabel667.Name = "Like"
textlabel667.Parent = frame658

-- Creating TextLabel
local textlabel668 = Instance.new("TextLabel")
textlabel668.Text = "🧟 Survive the Apocalypse"
textlabel668.TextColor3 = Color3.new(1, 1, 1)
textlabel668.TextScaled = true
textlabel668.TextWrapped = true
textlabel668.BackgroundTransparency = 1
textlabel668.Position = UDim2.new(0, 0, 0, 176)
textlabel668.Size = UDim2.new(1, 0, 0, 18)
textlabel668.Name = "IsUniversal"
textlabel668.Parent = frame658

-- Creating TextButton
local textbutton669 = Instance.new("TextButton")
textbutton669.Text = "EXECUTE"
textbutton669.TextColor3 = Color3.new(1, 1, 1)
textbutton669.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton669.Position = UDim2.new(0, 0, 1, -20)
textbutton669.Size = UDim2.new(1, 0, 0, 20)
textbutton669.Parent = frame658

-- Creating UICorner
local uicorner670 = Instance.new("UICorner")
uicorner670.Parent = textbutton669

-- Creating TextButton
local textbutton671 = Instance.new("TextButton")
textbutton671.Text = "COPY TO CLIPBOARD"
textbutton671.TextColor3 = Color3.new(1, 1, 1)
textbutton671.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton671.Position = UDim2.new(0, 0, 1, -44)
textbutton671.Size = UDim2.new(1, 0, 0, 20)
textbutton671.Name = "copy"
textbutton671.Parent = frame658

-- Creating UICorner
local uicorner672 = Instance.new("UICorner")
uicorner672.Parent = textbutton671

-- Creating Frame
local frame673 = Instance.new("Frame")
frame673.BackgroundColor3 = Color3.new(1, 0.42352941632270813, 0)
frame673.BackgroundTransparency = 0.25
frame673.Size = UDim2.new(0, 220, 0, 250)
frame673.Name = "Handle"
frame673.Parent = scrollingframe481

-- Creating UICorner
local uicorner674 = Instance.new("UICorner")
uicorner674.Parent = frame673

-- Creating UIGradient
local uigradient675 = Instance.new("UIGradient")
uigradient675.Rotation = 90
uigradient675.Parent = frame673

-- Creating UIScale
local uiscale676 = Instance.new("UIScale")
uiscale676.Parent = frame673

-- Creating Frame
local frame677 = Instance.new("Frame")
frame677.BackgroundTransparency = 1
frame677.Position = UDim2.new(0, 4, 0, 4)
frame677.Size = UDim2.new(1, -8, 1, -8)
frame677.Parent = frame673

-- Creating TextLabel
local textlabel678 = Instance.new("TextLabel")
textlabel678.Text = "rbcheats"
textlabel678.TextColor3 = Color3.new(1, 1, 1)
textlabel678.TextScaled = true
textlabel678.TextWrapped = true
textlabel678.BackgroundTransparency = 1
textlabel678.Size = UDim2.new(1, 0, 0, 40)
textlabel678.Name = "Title"
textlabel678.Parent = frame677

-- Creating ImageLabel
local imagelabel679 = Instance.new("ImageLabel")
imagelabel679.Image = "https://scriptblox.com/images/script/0-1783075049928.png"
imagelabel679.BackgroundTransparency = 0.30000001192092896
imagelabel679.Position = UDim2.new(0, 0, 0, 42)
imagelabel679.Size = UDim2.new(1, 0, 0, 100)
imagelabel679.Name = "ImageAsset"
imagelabel679.Parent = frame677

-- Creating UICorner
local uicorner680 = Instance.new("UICorner")
uicorner680.Parent = imagelabel679

-- Creating UIListLayout
local uilistlayout681 = Instance.new("UIListLayout")
uilistlayout681.Parent = imagelabel679

-- Creating TextLabel
local textlabel682 = Instance.new("TextLabel")
textlabel682.Text = "Key"
textlabel682.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel682.TextScaled = true
textlabel682.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel682.TextStrokeTransparency = 0
textlabel682.TextWrapped = true
textlabel682.BackgroundTransparency = 1
textlabel682.Size = UDim2.new(0.5, 0, 0, 18)
textlabel682.Name = "KEY"
textlabel682.Parent = imagelabel679

-- Creating TextLabel
local textlabel683 = Instance.new("TextLabel")
textlabel683.Text = "Patched"
textlabel683.TextColor3 = Color3.new(1, 0, 0)
textlabel683.TextScaled = true
textlabel683.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel683.TextStrokeTransparency = 0
textlabel683.TextWrapped = true
textlabel683.BackgroundTransparency = 1
textlabel683.Size = UDim2.new(0.5, 0, 0, 18)
textlabel683.Visible = false
textlabel683.Name = "Patched"
textlabel683.Parent = imagelabel679

-- Creating TextLabel
local textlabel684 = Instance.new("TextLabel")
textlabel684.Text = "Verified"
textlabel684.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel684.TextScaled = true
textlabel684.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel684.TextStrokeTransparency = 0
textlabel684.TextWrapped = true
textlabel684.BackgroundTransparency = 1
textlabel684.Size = UDim2.new(0.5, 0, 0, 18)
textlabel684.Visible = false
textlabel684.Name = "Verified"
textlabel684.Parent = imagelabel679

-- Creating TextLabel
local textlabel685 = Instance.new("TextLabel")
textlabel685.Text = "Visits: 672"
textlabel685.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel685.TextScaled = true
textlabel685.TextWrapped = true
textlabel685.BackgroundTransparency = 1
textlabel685.Position = UDim2.new(0, 0, 0, 142)
textlabel685.Size = UDim2.new(1, 0, 0, 18)
textlabel685.Name = "Visit"
textlabel685.Parent = frame677

-- Creating TextLabel
local textlabel686 = Instance.new("TextLabel")
textlabel686.Text = "Likes: 0"
textlabel686.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel686.TextScaled = true
textlabel686.TextWrapped = true
textlabel686.BackgroundTransparency = 1
textlabel686.Position = UDim2.new(0, 0, 0, 158)
textlabel686.Size = UDim2.new(1, 0, 0, 18)
textlabel686.Name = "Like"
textlabel686.Parent = frame677

-- Creating TextLabel
local textlabel687 = Instance.new("TextLabel")
textlabel687.Text = "Universal Script 📌"
textlabel687.TextColor3 = Color3.new(1, 1, 1)
textlabel687.TextScaled = true
textlabel687.TextWrapped = true
textlabel687.BackgroundTransparency = 1
textlabel687.Position = UDim2.new(0, 0, 0, 176)
textlabel687.Size = UDim2.new(1, 0, 0, 18)
textlabel687.Name = "IsUniversal"
textlabel687.Parent = frame677

-- Creating TextButton
local textbutton688 = Instance.new("TextButton")
textbutton688.Text = "EXECUTE"
textbutton688.TextColor3 = Color3.new(1, 1, 1)
textbutton688.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton688.Position = UDim2.new(0, 0, 1, -20)
textbutton688.Size = UDim2.new(1, 0, 0, 20)
textbutton688.Parent = frame677

-- Creating UICorner
local uicorner689 = Instance.new("UICorner")
uicorner689.Parent = textbutton688

-- Creating TextButton
local textbutton690 = Instance.new("TextButton")
textbutton690.Text = "COPY TO CLIPBOARD"
textbutton690.TextColor3 = Color3.new(1, 1, 1)
textbutton690.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton690.Position = UDim2.new(0, 0, 1, -44)
textbutton690.Size = UDim2.new(1, 0, 0, 20)
textbutton690.Name = "copy"
textbutton690.Parent = frame677

-- Creating UICorner
local uicorner691 = Instance.new("UICorner")
uicorner691.Parent = textbutton690

-- Creating Frame
local frame692 = Instance.new("Frame")
frame692.BackgroundColor3 = Color3.new(1, 0.42352941632270813, 0)
frame692.BackgroundTransparency = 0.25
frame692.Size = UDim2.new(0, 220, 0, 250)
frame692.Name = "Handle"
frame692.Parent = scrollingframe481

-- Creating UICorner
local uicorner693 = Instance.new("UICorner")
uicorner693.Parent = frame692

-- Creating UIGradient
local uigradient694 = Instance.new("UIGradient")
uigradient694.Rotation = 90
uigradient694.Parent = frame692

-- Creating UIScale
local uiscale695 = Instance.new("UIScale")
uiscale695.Parent = frame692

-- Creating Frame
local frame696 = Instance.new("Frame")
frame696.BackgroundTransparency = 1
frame696.Position = UDim2.new(0, 4, 0, 4)
frame696.Size = UDim2.new(1, -8, 1, -8)
frame696.Parent = frame692

-- Creating TextLabel
local textlabel697 = Instance.new("TextLabel")
textlabel697.Text = "Skin Changer Hitbox Expander And More Features"
textlabel697.TextColor3 = Color3.new(1, 1, 1)
textlabel697.TextScaled = true
textlabel697.TextWrapped = true
textlabel697.BackgroundTransparency = 1
textlabel697.Size = UDim2.new(1, 0, 0, 40)
textlabel697.Name = "Title"
textlabel697.Parent = frame696

-- Creating ImageLabel
local imagelabel698 = Instance.new("ImageLabel")
imagelabel698.Image = "rbxassetid://118914662369732"
imagelabel698.BackgroundTransparency = 0.30000001192092896
imagelabel698.Position = UDim2.new(0, 0, 0, 42)
imagelabel698.Size = UDim2.new(1, 0, 0, 100)
imagelabel698.Name = "ImageAsset"
imagelabel698.Parent = frame696

-- Creating UICorner
local uicorner699 = Instance.new("UICorner")
uicorner699.Parent = imagelabel698

-- Creating UIListLayout
local uilistlayout700 = Instance.new("UIListLayout")
uilistlayout700.Parent = imagelabel698

-- Creating TextLabel
local textlabel701 = Instance.new("TextLabel")
textlabel701.Text = "Key"
textlabel701.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel701.TextScaled = true
textlabel701.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel701.TextStrokeTransparency = 0
textlabel701.TextWrapped = true
textlabel701.BackgroundTransparency = 1
textlabel701.Size = UDim2.new(0.5, 0, 0, 18)
textlabel701.Name = "KEY"
textlabel701.Parent = imagelabel698

-- Creating TextLabel
local textlabel702 = Instance.new("TextLabel")
textlabel702.Text = "Patched"
textlabel702.TextColor3 = Color3.new(1, 0, 0)
textlabel702.TextScaled = true
textlabel702.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel702.TextStrokeTransparency = 0
textlabel702.TextWrapped = true
textlabel702.BackgroundTransparency = 1
textlabel702.Size = UDim2.new(0.5, 0, 0, 18)
textlabel702.Visible = false
textlabel702.Name = "Patched"
textlabel702.Parent = imagelabel698

-- Creating TextLabel
local textlabel703 = Instance.new("TextLabel")
textlabel703.Text = "Verified"
textlabel703.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel703.TextScaled = true
textlabel703.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel703.TextStrokeTransparency = 0
textlabel703.TextWrapped = true
textlabel703.BackgroundTransparency = 1
textlabel703.Size = UDim2.new(0.5, 0, 0, 18)
textlabel703.Visible = false
textlabel703.Name = "Verified"
textlabel703.Parent = imagelabel698

-- Creating TextLabel
local textlabel704 = Instance.new("TextLabel")
textlabel704.Text = "Visits: 4637"
textlabel704.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel704.TextScaled = true
textlabel704.TextWrapped = true
textlabel704.BackgroundTransparency = 1
textlabel704.Position = UDim2.new(0, 0, 0, 142)
textlabel704.Size = UDim2.new(1, 0, 0, 18)
textlabel704.Name = "Visit"
textlabel704.Parent = frame696

-- Creating TextLabel
local textlabel705 = Instance.new("TextLabel")
textlabel705.Text = "Likes: 0"
textlabel705.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel705.TextScaled = true
textlabel705.TextWrapped = true
textlabel705.BackgroundTransparency = 1
textlabel705.Position = UDim2.new(0, 0, 0, 158)
textlabel705.Size = UDim2.new(1, 0, 0, 18)
textlabel705.Name = "Like"
textlabel705.Parent = frame696

-- Creating TextLabel
local textlabel706 = Instance.new("TextLabel")
textlabel706.Text = "[NEBULA] BloxStrike"
textlabel706.TextColor3 = Color3.new(1, 1, 1)
textlabel706.TextScaled = true
textlabel706.TextWrapped = true
textlabel706.BackgroundTransparency = 1
textlabel706.Position = UDim2.new(0, 0, 0, 176)
textlabel706.Size = UDim2.new(1, 0, 0, 18)
textlabel706.Name = "IsUniversal"
textlabel706.Parent = frame696

-- Creating TextButton
local textbutton707 = Instance.new("TextButton")
textbutton707.Text = "EXECUTE"
textbutton707.TextColor3 = Color3.new(1, 1, 1)
textbutton707.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton707.Position = UDim2.new(0, 0, 1, -20)
textbutton707.Size = UDim2.new(1, 0, 0, 20)
textbutton707.Parent = frame696

-- Creating UICorner
local uicorner708 = Instance.new("UICorner")
uicorner708.Parent = textbutton707

-- Creating TextButton
local textbutton709 = Instance.new("TextButton")
textbutton709.Text = "COPY TO CLIPBOARD"
textbutton709.TextColor3 = Color3.new(1, 1, 1)
textbutton709.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton709.Position = UDim2.new(0, 0, 1, -44)
textbutton709.Size = UDim2.new(1, 0, 0, 20)
textbutton709.Name = "copy"
textbutton709.Parent = frame696

-- Creating UICorner
local uicorner710 = Instance.new("UICorner")
uicorner710.Parent = textbutton709

-- Creating Frame
local frame711 = Instance.new("Frame")
frame711.BackgroundColor3 = Color3.new(1, 0.42352941632270813, 0)
frame711.BackgroundTransparency = 0.25
frame711.Size = UDim2.new(0, 220, 0, 250)
frame711.Name = "Handle"
frame711.Parent = scrollingframe481

-- Creating UICorner
local uicorner712 = Instance.new("UICorner")
uicorner712.Parent = frame711

-- Creating UIGradient
local uigradient713 = Instance.new("UIGradient")
uigradient713.Rotation = 90
uigradient713.Parent = frame711

-- Creating UIScale
local uiscale714 = Instance.new("UIScale")
uiscale714.Parent = frame711

-- Creating Frame
local frame715 = Instance.new("Frame")
frame715.BackgroundTransparency = 1
frame715.Position = UDim2.new(0, 4, 0, 4)
frame715.Size = UDim2.new(1, -8, 1, -8)
frame715.Parent = frame711

-- Creating TextLabel
local textlabel716 = Instance.new("TextLabel")
textlabel716.Text = "Aim Lock n more GUI"
textlabel716.TextColor3 = Color3.new(1, 1, 1)
textlabel716.TextScaled = true
textlabel716.TextWrapped = true
textlabel716.BackgroundTransparency = 1
textlabel716.Size = UDim2.new(1, 0, 0, 40)
textlabel716.Name = "Title"
textlabel716.Parent = frame715

-- Creating ImageLabel
local imagelabel717 = Instance.new("ImageLabel")
imagelabel717.Image = "rbxassetid://118914662369732"
imagelabel717.BackgroundTransparency = 0.30000001192092896
imagelabel717.Position = UDim2.new(0, 0, 0, 42)
imagelabel717.Size = UDim2.new(1, 0, 0, 100)
imagelabel717.Name = "ImageAsset"
imagelabel717.Parent = frame715

-- Creating UICorner
local uicorner718 = Instance.new("UICorner")
uicorner718.Parent = imagelabel717

-- Creating UIListLayout
local uilistlayout719 = Instance.new("UIListLayout")
uilistlayout719.Parent = imagelabel717

-- Creating TextLabel
local textlabel720 = Instance.new("TextLabel")
textlabel720.Text = "Key"
textlabel720.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel720.TextScaled = true
textlabel720.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel720.TextStrokeTransparency = 0
textlabel720.TextWrapped = true
textlabel720.BackgroundTransparency = 1
textlabel720.Size = UDim2.new(0.5, 0, 0, 18)
textlabel720.Name = "KEY"
textlabel720.Parent = imagelabel717

-- Creating TextLabel
local textlabel721 = Instance.new("TextLabel")
textlabel721.Text = "Patched"
textlabel721.TextColor3 = Color3.new(1, 0, 0)
textlabel721.TextScaled = true
textlabel721.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel721.TextStrokeTransparency = 0
textlabel721.TextWrapped = true
textlabel721.BackgroundTransparency = 1
textlabel721.Size = UDim2.new(0.5, 0, 0, 18)
textlabel721.Visible = false
textlabel721.Name = "Patched"
textlabel721.Parent = imagelabel717

-- Creating TextLabel
local textlabel722 = Instance.new("TextLabel")
textlabel722.Text = "Verified"
textlabel722.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel722.TextScaled = true
textlabel722.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel722.TextStrokeTransparency = 0
textlabel722.TextWrapped = true
textlabel722.BackgroundTransparency = 1
textlabel722.Size = UDim2.new(0.5, 0, 0, 18)
textlabel722.Visible = false
textlabel722.Name = "Verified"
textlabel722.Parent = imagelabel717

-- Creating TextLabel
local textlabel723 = Instance.new("TextLabel")
textlabel723.Text = "Visits: 2120"
textlabel723.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel723.TextScaled = true
textlabel723.TextWrapped = true
textlabel723.BackgroundTransparency = 1
textlabel723.Position = UDim2.new(0, 0, 0, 142)
textlabel723.Size = UDim2.new(1, 0, 0, 18)
textlabel723.Name = "Visit"
textlabel723.Parent = frame715

-- Creating TextLabel
local textlabel724 = Instance.new("TextLabel")
textlabel724.Text = "Likes: 0"
textlabel724.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel724.TextScaled = true
textlabel724.TextWrapped = true
textlabel724.BackgroundTransparency = 1
textlabel724.Position = UDim2.new(0, 0, 0, 158)
textlabel724.Size = UDim2.new(1, 0, 0, 18)
textlabel724.Name = "Like"
textlabel724.Parent = frame715

-- Creating TextLabel
local textlabel725 = Instance.new("TextLabel")
textlabel725.Text = "The Strongest Battlegrounds"
textlabel725.TextColor3 = Color3.new(1, 1, 1)
textlabel725.TextScaled = true
textlabel725.TextWrapped = true
textlabel725.BackgroundTransparency = 1
textlabel725.Position = UDim2.new(0, 0, 0, 176)
textlabel725.Size = UDim2.new(1, 0, 0, 18)
textlabel725.Name = "IsUniversal"
textlabel725.Parent = frame715

-- Creating TextButton
local textbutton726 = Instance.new("TextButton")
textbutton726.Text = "EXECUTE"
textbutton726.TextColor3 = Color3.new(1, 1, 1)
textbutton726.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton726.Position = UDim2.new(0, 0, 1, -20)
textbutton726.Size = UDim2.new(1, 0, 0, 20)
textbutton726.Parent = frame715

-- Creating UICorner
local uicorner727 = Instance.new("UICorner")
uicorner727.Parent = textbutton726

-- Creating TextButton
local textbutton728 = Instance.new("TextButton")
textbutton728.Text = "COPY TO CLIPBOARD"
textbutton728.TextColor3 = Color3.new(1, 1, 1)
textbutton728.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton728.Position = UDim2.new(0, 0, 1, -44)
textbutton728.Size = UDim2.new(1, 0, 0, 20)
textbutton728.Name = "copy"
textbutton728.Parent = frame715

-- Creating UICorner
local uicorner729 = Instance.new("UICorner")
uicorner729.Parent = textbutton728

-- Creating Frame
local frame730 = Instance.new("Frame")
frame730.BackgroundColor3 = Color3.new(1, 0.42352941632270813, 0)
frame730.BackgroundTransparency = 0.25
frame730.Size = UDim2.new(0, 220, 0, 250)
frame730.Name = "Handle"
frame730.Parent = scrollingframe481

-- Creating UICorner
local uicorner731 = Instance.new("UICorner")
uicorner731.Parent = frame730

-- Creating UIGradient
local uigradient732 = Instance.new("UIGradient")
uigradient732.Rotation = 90
uigradient732.Parent = frame730

-- Creating UIScale
local uiscale733 = Instance.new("UIScale")
uiscale733.Parent = frame730

-- Creating Frame
local frame734 = Instance.new("Frame")
frame734.BackgroundTransparency = 1
frame734.Position = UDim2.new(0, 4, 0, 4)
frame734.Size = UDim2.new(1, -8, 1, -8)
frame734.Parent = frame730

-- Creating TextLabel
local textlabel735 = Instance.new("TextLabel")
textlabel735.Text = "Kill Aura Safe Play GUI"
textlabel735.TextColor3 = Color3.new(1, 1, 1)
textlabel735.TextScaled = true
textlabel735.TextWrapped = true
textlabel735.BackgroundTransparency = 1
textlabel735.Size = UDim2.new(1, 0, 0, 40)
textlabel735.Name = "Title"
textlabel735.Parent = frame734

-- Creating ImageLabel
local imagelabel736 = Instance.new("ImageLabel")
imagelabel736.Image = "rbxassetid://118914662369732"
imagelabel736.BackgroundTransparency = 0.30000001192092896
imagelabel736.Position = UDim2.new(0, 0, 0, 42)
imagelabel736.Size = UDim2.new(1, 0, 0, 100)
imagelabel736.Name = "ImageAsset"
imagelabel736.Parent = frame734

-- Creating UICorner
local uicorner737 = Instance.new("UICorner")
uicorner737.Parent = imagelabel736

-- Creating UIListLayout
local uilistlayout738 = Instance.new("UIListLayout")
uilistlayout738.Parent = imagelabel736

-- Creating TextLabel
local textlabel739 = Instance.new("TextLabel")
textlabel739.Text = "Key"
textlabel739.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel739.TextScaled = true
textlabel739.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel739.TextStrokeTransparency = 0
textlabel739.TextWrapped = true
textlabel739.BackgroundTransparency = 1
textlabel739.Size = UDim2.new(0.5, 0, 0, 18)
textlabel739.Name = "KEY"
textlabel739.Parent = imagelabel736

-- Creating TextLabel
local textlabel740 = Instance.new("TextLabel")
textlabel740.Text = "Patched"
textlabel740.TextColor3 = Color3.new(1, 0, 0)
textlabel740.TextScaled = true
textlabel740.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel740.TextStrokeTransparency = 0
textlabel740.TextWrapped = true
textlabel740.BackgroundTransparency = 1
textlabel740.Size = UDim2.new(0.5, 0, 0, 18)
textlabel740.Visible = false
textlabel740.Name = "Patched"
textlabel740.Parent = imagelabel736

-- Creating TextLabel
local textlabel741 = Instance.new("TextLabel")
textlabel741.Text = "Verified"
textlabel741.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel741.TextScaled = true
textlabel741.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel741.TextStrokeTransparency = 0
textlabel741.TextWrapped = true
textlabel741.BackgroundTransparency = 1
textlabel741.Size = UDim2.new(0.5, 0, 0, 18)
textlabel741.Visible = false
textlabel741.Name = "Verified"
textlabel741.Parent = imagelabel736

-- Creating TextLabel
local textlabel742 = Instance.new("TextLabel")
textlabel742.Text = "Visits: 1418"
textlabel742.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel742.TextScaled = true
textlabel742.TextWrapped = true
textlabel742.BackgroundTransparency = 1
textlabel742.Position = UDim2.new(0, 0, 0, 142)
textlabel742.Size = UDim2.new(1, 0, 0, 18)
textlabel742.Name = "Visit"
textlabel742.Parent = frame734

-- Creating TextLabel
local textlabel743 = Instance.new("TextLabel")
textlabel743.Text = "Likes: 0"
textlabel743.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel743.TextScaled = true
textlabel743.TextWrapped = true
textlabel743.BackgroundTransparency = 1
textlabel743.Position = UDim2.new(0, 0, 0, 158)
textlabel743.Size = UDim2.new(1, 0, 0, 18)
textlabel743.Name = "Like"
textlabel743.Parent = frame734

-- Creating TextLabel
local textlabel744 = Instance.new("TextLabel")
textlabel744.Text = "Survive Zombie Arena"
textlabel744.TextColor3 = Color3.new(1, 1, 1)
textlabel744.TextScaled = true
textlabel744.TextWrapped = true
textlabel744.BackgroundTransparency = 1
textlabel744.Position = UDim2.new(0, 0, 0, 176)
textlabel744.Size = UDim2.new(1, 0, 0, 18)
textlabel744.Name = "IsUniversal"
textlabel744.Parent = frame734

-- Creating TextButton
local textbutton745 = Instance.new("TextButton")
textbutton745.Text = "EXECUTE"
textbutton745.TextColor3 = Color3.new(1, 1, 1)
textbutton745.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton745.Position = UDim2.new(0, 0, 1, -20)
textbutton745.Size = UDim2.new(1, 0, 0, 20)
textbutton745.Parent = frame734

-- Creating UICorner
local uicorner746 = Instance.new("UICorner")
uicorner746.Parent = textbutton745

-- Creating TextButton
local textbutton747 = Instance.new("TextButton")
textbutton747.Text = "COPY TO CLIPBOARD"
textbutton747.TextColor3 = Color3.new(1, 1, 1)
textbutton747.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton747.Position = UDim2.new(0, 0, 1, -44)
textbutton747.Size = UDim2.new(1, 0, 0, 20)
textbutton747.Name = "copy"
textbutton747.Parent = frame734

-- Creating UICorner
local uicorner748 = Instance.new("UICorner")
uicorner748.Parent = textbutton747

-- Creating Frame
local frame749 = Instance.new("Frame")
frame749.BackgroundColor3 = Color3.new(1, 0.42352941632270813, 0)
frame749.BackgroundTransparency = 0.25
frame749.Size = UDim2.new(0, 220, 0, 250)
frame749.Name = "Handle"
frame749.Parent = scrollingframe481

-- Creating UICorner
local uicorner750 = Instance.new("UICorner")
uicorner750.Parent = frame749

-- Creating UIGradient
local uigradient751 = Instance.new("UIGradient")
uigradient751.Rotation = 90
uigradient751.Parent = frame749

-- Creating UIScale
local uiscale752 = Instance.new("UIScale")
uiscale752.Parent = frame749

-- Creating Frame
local frame753 = Instance.new("Frame")
frame753.BackgroundTransparency = 1
frame753.Position = UDim2.new(0, 4, 0, 4)
frame753.Size = UDim2.new(1, -8, 1, -8)
frame753.Parent = frame749

-- Creating TextLabel
local textlabel754 = Instance.new("TextLabel")
textlabel754.Text = "Autofarm GUI"
textlabel754.TextColor3 = Color3.new(1, 1, 1)
textlabel754.TextScaled = true
textlabel754.TextWrapped = true
textlabel754.BackgroundTransparency = 1
textlabel754.Size = UDim2.new(1, 0, 0, 40)
textlabel754.Name = "Title"
textlabel754.Parent = frame753

-- Creating ImageLabel
local imagelabel755 = Instance.new("ImageLabel")
imagelabel755.Image = "rbxassetid://118914662369732"
imagelabel755.BackgroundTransparency = 0.30000001192092896
imagelabel755.Position = UDim2.new(0, 0, 0, 42)
imagelabel755.Size = UDim2.new(1, 0, 0, 100)
imagelabel755.Name = "ImageAsset"
imagelabel755.Parent = frame753

-- Creating UICorner
local uicorner756 = Instance.new("UICorner")
uicorner756.Parent = imagelabel755

-- Creating UIListLayout
local uilistlayout757 = Instance.new("UIListLayout")
uilistlayout757.Parent = imagelabel755

-- Creating TextLabel
local textlabel758 = Instance.new("TextLabel")
textlabel758.Text = "Key"
textlabel758.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel758.TextScaled = true
textlabel758.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel758.TextStrokeTransparency = 0
textlabel758.TextWrapped = true
textlabel758.BackgroundTransparency = 1
textlabel758.Size = UDim2.new(0.5, 0, 0, 18)
textlabel758.Name = "KEY"
textlabel758.Parent = imagelabel755

-- Creating TextLabel
local textlabel759 = Instance.new("TextLabel")
textlabel759.Text = "Patched"
textlabel759.TextColor3 = Color3.new(1, 0, 0)
textlabel759.TextScaled = true
textlabel759.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel759.TextStrokeTransparency = 0
textlabel759.TextWrapped = true
textlabel759.BackgroundTransparency = 1
textlabel759.Size = UDim2.new(0.5, 0, 0, 18)
textlabel759.Visible = false
textlabel759.Name = "Patched"
textlabel759.Parent = imagelabel755

-- Creating TextLabel
local textlabel760 = Instance.new("TextLabel")
textlabel760.Text = "Verified"
textlabel760.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel760.TextScaled = true
textlabel760.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel760.TextStrokeTransparency = 0
textlabel760.TextWrapped = true
textlabel760.BackgroundTransparency = 1
textlabel760.Size = UDim2.new(0.5, 0, 0, 18)
textlabel760.Visible = false
textlabel760.Name = "Verified"
textlabel760.Parent = imagelabel755

-- Creating TextLabel
local textlabel761 = Instance.new("TextLabel")
textlabel761.Text = "Visits: 4118"
textlabel761.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel761.TextScaled = true
textlabel761.TextWrapped = true
textlabel761.BackgroundTransparency = 1
textlabel761.Position = UDim2.new(0, 0, 0, 142)
textlabel761.Size = UDim2.new(1, 0, 0, 18)
textlabel761.Name = "Visit"
textlabel761.Parent = frame753

-- Creating TextLabel
local textlabel762 = Instance.new("TextLabel")
textlabel762.Text = "Likes: 0"
textlabel762.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel762.TextScaled = true
textlabel762.TextWrapped = true
textlabel762.BackgroundTransparency = 1
textlabel762.Position = UDim2.new(0, 0, 0, 158)
textlabel762.Size = UDim2.new(1, 0, 0, 18)
textlabel762.Name = "Like"
textlabel762.Parent = frame753

-- Creating TextLabel
local textlabel763 = Instance.new("TextLabel")
textlabel763.Text = "Kick a Lucky Block"
textlabel763.TextColor3 = Color3.new(1, 1, 1)
textlabel763.TextScaled = true
textlabel763.TextWrapped = true
textlabel763.BackgroundTransparency = 1
textlabel763.Position = UDim2.new(0, 0, 0, 176)
textlabel763.Size = UDim2.new(1, 0, 0, 18)
textlabel763.Name = "IsUniversal"
textlabel763.Parent = frame753

-- Creating TextButton
local textbutton764 = Instance.new("TextButton")
textbutton764.Text = "EXECUTE"
textbutton764.TextColor3 = Color3.new(1, 1, 1)
textbutton764.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton764.Position = UDim2.new(0, 0, 1, -20)
textbutton764.Size = UDim2.new(1, 0, 0, 20)
textbutton764.Parent = frame753

-- Creating UICorner
local uicorner765 = Instance.new("UICorner")
uicorner765.Parent = textbutton764

-- Creating TextButton
local textbutton766 = Instance.new("TextButton")
textbutton766.Text = "COPY TO CLIPBOARD"
textbutton766.TextColor3 = Color3.new(1, 1, 1)
textbutton766.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton766.Position = UDim2.new(0, 0, 1, -44)
textbutton766.Size = UDim2.new(1, 0, 0, 20)
textbutton766.Name = "copy"
textbutton766.Parent = frame753

-- Creating UICorner
local uicorner767 = Instance.new("UICorner")
uicorner767.Parent = textbutton766

-- Creating Frame
local frame768 = Instance.new("Frame")
frame768.BackgroundColor3 = Color3.new(1, 0.42352941632270813, 0)
frame768.BackgroundTransparency = 0.25
frame768.Size = UDim2.new(0, 220, 0, 250)
frame768.Name = "Handle"
frame768.Parent = scrollingframe481

-- Creating UICorner
local uicorner769 = Instance.new("UICorner")
uicorner769.Parent = frame768

-- Creating UIGradient
local uigradient770 = Instance.new("UIGradient")
uigradient770.Rotation = 90
uigradient770.Parent = frame768

-- Creating UIScale
local uiscale771 = Instance.new("UIScale")
uiscale771.Parent = frame768

-- Creating Frame
local frame772 = Instance.new("Frame")
frame772.BackgroundTransparency = 1
frame772.Position = UDim2.new(0, 4, 0, 4)
frame772.Size = UDim2.new(1, -8, 1, -8)
frame772.Parent = frame768

-- Creating TextLabel
local textlabel773 = Instance.new("TextLabel")
textlabel773.Text = "Full Autofarm Auto Buy Upgrade Fruit And More"
textlabel773.TextColor3 = Color3.new(1, 1, 1)
textlabel773.TextScaled = true
textlabel773.TextWrapped = true
textlabel773.BackgroundTransparency = 1
textlabel773.Size = UDim2.new(1, 0, 0, 40)
textlabel773.Name = "Title"
textlabel773.Parent = frame772

-- Creating ImageLabel
local imagelabel774 = Instance.new("ImageLabel")
imagelabel774.Image = "rbxassetid://118914662369732"
imagelabel774.BackgroundTransparency = 0.30000001192092896
imagelabel774.Position = UDim2.new(0, 0, 0, 42)
imagelabel774.Size = UDim2.new(1, 0, 0, 100)
imagelabel774.Name = "ImageAsset"
imagelabel774.Parent = frame772

-- Creating UICorner
local uicorner775 = Instance.new("UICorner")
uicorner775.Parent = imagelabel774

-- Creating UIListLayout
local uilistlayout776 = Instance.new("UIListLayout")
uilistlayout776.Parent = imagelabel774

-- Creating TextLabel
local textlabel777 = Instance.new("TextLabel")
textlabel777.Text = "Key"
textlabel777.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel777.TextScaled = true
textlabel777.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel777.TextStrokeTransparency = 0
textlabel777.TextWrapped = true
textlabel777.BackgroundTransparency = 1
textlabel777.Size = UDim2.new(0.5, 0, 0, 18)
textlabel777.Name = "KEY"
textlabel777.Parent = imagelabel774

-- Creating TextLabel
local textlabel778 = Instance.new("TextLabel")
textlabel778.Text = "Patched"
textlabel778.TextColor3 = Color3.new(1, 0, 0)
textlabel778.TextScaled = true
textlabel778.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel778.TextStrokeTransparency = 0
textlabel778.TextWrapped = true
textlabel778.BackgroundTransparency = 1
textlabel778.Size = UDim2.new(0.5, 0, 0, 18)
textlabel778.Visible = false
textlabel778.Name = "Patched"
textlabel778.Parent = imagelabel774

-- Creating TextLabel
local textlabel779 = Instance.new("TextLabel")
textlabel779.Text = "Verified"
textlabel779.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel779.TextScaled = true
textlabel779.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel779.TextStrokeTransparency = 0
textlabel779.TextWrapped = true
textlabel779.BackgroundTransparency = 1
textlabel779.Size = UDim2.new(0.5, 0, 0, 18)
textlabel779.Visible = false
textlabel779.Name = "Verified"
textlabel779.Parent = imagelabel774

-- Creating TextLabel
local textlabel780 = Instance.new("TextLabel")
textlabel780.Text = "Visits: 4983"
textlabel780.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel780.TextScaled = true
textlabel780.TextWrapped = true
textlabel780.BackgroundTransparency = 1
textlabel780.Position = UDim2.new(0, 0, 0, 142)
textlabel780.Size = UDim2.new(1, 0, 0, 18)
textlabel780.Name = "Visit"
textlabel780.Parent = frame772

-- Creating TextLabel
local textlabel781 = Instance.new("TextLabel")
textlabel781.Text = "Likes: 0"
textlabel781.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel781.TextScaled = true
textlabel781.TextWrapped = true
textlabel781.BackgroundTransparency = 1
textlabel781.Position = UDim2.new(0, 0, 0, 158)
textlabel781.Size = UDim2.new(1, 0, 0, 18)
textlabel781.Name = "Like"
textlabel781.Parent = frame772

-- Creating TextLabel
local textlabel782 = Instance.new("TextLabel")
textlabel782.Text = "[🌳] Sell Lemons 🍋"
textlabel782.TextColor3 = Color3.new(1, 1, 1)
textlabel782.TextScaled = true
textlabel782.TextWrapped = true
textlabel782.BackgroundTransparency = 1
textlabel782.Position = UDim2.new(0, 0, 0, 176)
textlabel782.Size = UDim2.new(1, 0, 0, 18)
textlabel782.Name = "IsUniversal"
textlabel782.Parent = frame772

-- Creating TextButton
local textbutton783 = Instance.new("TextButton")
textbutton783.Text = "EXECUTE"
textbutton783.TextColor3 = Color3.new(1, 1, 1)
textbutton783.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton783.Position = UDim2.new(0, 0, 1, -20)
textbutton783.Size = UDim2.new(1, 0, 0, 20)
textbutton783.Parent = frame772

-- Creating UICorner
local uicorner784 = Instance.new("UICorner")
uicorner784.Parent = textbutton783

-- Creating TextButton
local textbutton785 = Instance.new("TextButton")
textbutton785.Text = "COPY TO CLIPBOARD"
textbutton785.TextColor3 = Color3.new(1, 1, 1)
textbutton785.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton785.Position = UDim2.new(0, 0, 1, -44)
textbutton785.Size = UDim2.new(1, 0, 0, 20)
textbutton785.Name = "copy"
textbutton785.Parent = frame772

-- Creating UICorner
local uicorner786 = Instance.new("UICorner")
uicorner786.Parent = textbutton785

-- Creating Frame
local frame787 = Instance.new("Frame")
frame787.BackgroundColor3 = Color3.new(1, 0.42352941632270813, 0)
frame787.BackgroundTransparency = 0.25
frame787.Size = UDim2.new(0, 220, 0, 250)
frame787.Name = "Handle"
frame787.Parent = scrollingframe481

-- Creating UICorner
local uicorner788 = Instance.new("UICorner")
uicorner788.Parent = frame787

-- Creating UIGradient
local uigradient789 = Instance.new("UIGradient")
uigradient789.Rotation = 90
uigradient789.Parent = frame787

-- Creating UIScale
local uiscale790 = Instance.new("UIScale")
uiscale790.Parent = frame787

-- Creating Frame
local frame791 = Instance.new("Frame")
frame791.BackgroundTransparency = 1
frame791.Position = UDim2.new(0, 4, 0, 4)
frame791.Size = UDim2.new(1, -8, 1, -8)
frame791.Parent = frame787

-- Creating TextLabel
local textlabel792 = Instance.new("TextLabel")
textlabel792.Text = "CHub MVSD"
textlabel792.TextColor3 = Color3.new(1, 1, 1)
textlabel792.TextScaled = true
textlabel792.TextWrapped = true
textlabel792.BackgroundTransparency = 1
textlabel792.Size = UDim2.new(1, 0, 0, 40)
textlabel792.Name = "Title"
textlabel792.Parent = frame791

-- Creating ImageLabel
local imagelabel793 = Instance.new("ImageLabel")
imagelabel793.Image = "https://scriptblox.com/images/script/12355337193-1762189995467.png"
imagelabel793.BackgroundTransparency = 0.30000001192092896
imagelabel793.Position = UDim2.new(0, 0, 0, 42)
imagelabel793.Size = UDim2.new(1, 0, 0, 100)
imagelabel793.Name = "ImageAsset"
imagelabel793.Parent = frame791

-- Creating UICorner
local uicorner794 = Instance.new("UICorner")
uicorner794.Parent = imagelabel793

-- Creating UIListLayout
local uilistlayout795 = Instance.new("UIListLayout")
uilistlayout795.Parent = imagelabel793

-- Creating TextLabel
local textlabel796 = Instance.new("TextLabel")
textlabel796.Text = "Key"
textlabel796.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel796.TextScaled = true
textlabel796.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel796.TextStrokeTransparency = 0
textlabel796.TextWrapped = true
textlabel796.BackgroundTransparency = 1
textlabel796.Size = UDim2.new(0.5, 0, 0, 18)
textlabel796.Name = "KEY"
textlabel796.Parent = imagelabel793

-- Creating TextLabel
local textlabel797 = Instance.new("TextLabel")
textlabel797.Text = "Patched"
textlabel797.TextColor3 = Color3.new(1, 0, 0)
textlabel797.TextScaled = true
textlabel797.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel797.TextStrokeTransparency = 0
textlabel797.TextWrapped = true
textlabel797.BackgroundTransparency = 1
textlabel797.Size = UDim2.new(0.5, 0, 0, 18)
textlabel797.Visible = false
textlabel797.Name = "Patched"
textlabel797.Parent = imagelabel793

-- Creating TextLabel
local textlabel798 = Instance.new("TextLabel")
textlabel798.Text = "Verified"
textlabel798.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel798.TextScaled = true
textlabel798.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel798.TextStrokeTransparency = 0
textlabel798.TextWrapped = true
textlabel798.BackgroundTransparency = 1
textlabel798.Size = UDim2.new(0.5, 0, 0, 18)
textlabel798.Visible = false
textlabel798.Name = "Verified"
textlabel798.Parent = imagelabel793

-- Creating TextLabel
local textlabel799 = Instance.new("TextLabel")
textlabel799.Text = "Visits: 29298"
textlabel799.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel799.TextScaled = true
textlabel799.TextWrapped = true
textlabel799.BackgroundTransparency = 1
textlabel799.Position = UDim2.new(0, 0, 0, 142)
textlabel799.Size = UDim2.new(1, 0, 0, 18)
textlabel799.Name = "Visit"
textlabel799.Parent = frame791

-- Creating TextLabel
local textlabel800 = Instance.new("TextLabel")
textlabel800.Text = "Likes: 0"
textlabel800.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel800.TextScaled = true
textlabel800.TextWrapped = true
textlabel800.BackgroundTransparency = 1
textlabel800.Position = UDim2.new(0, 0, 0, 158)
textlabel800.Size = UDim2.new(1, 0, 0, 18)
textlabel800.Name = "Like"
textlabel800.Parent = frame791

-- Creating TextLabel
local textlabel801 = Instance.new("TextLabel")
textlabel801.Text = "Murderers VS Sheriffs DUELS"
textlabel801.TextColor3 = Color3.new(1, 1, 1)
textlabel801.TextScaled = true
textlabel801.TextWrapped = true
textlabel801.BackgroundTransparency = 1
textlabel801.Position = UDim2.new(0, 0, 0, 176)
textlabel801.Size = UDim2.new(1, 0, 0, 18)
textlabel801.Name = "IsUniversal"
textlabel801.Parent = frame791

-- Creating TextButton
local textbutton802 = Instance.new("TextButton")
textbutton802.Text = "EXECUTE"
textbutton802.TextColor3 = Color3.new(1, 1, 1)
textbutton802.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton802.Position = UDim2.new(0, 0, 1, -20)
textbutton802.Size = UDim2.new(1, 0, 0, 20)
textbutton802.Parent = frame791

-- Creating UICorner
local uicorner803 = Instance.new("UICorner")
uicorner803.Parent = textbutton802

-- Creating TextButton
local textbutton804 = Instance.new("TextButton")
textbutton804.Text = "COPY TO CLIPBOARD"
textbutton804.TextColor3 = Color3.new(1, 1, 1)
textbutton804.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton804.Position = UDim2.new(0, 0, 1, -44)
textbutton804.Size = UDim2.new(1, 0, 0, 20)
textbutton804.Name = "copy"
textbutton804.Parent = frame791

-- Creating UICorner
local uicorner805 = Instance.new("UICorner")
uicorner805.Parent = textbutton804

-- Creating Frame
local frame806 = Instance.new("Frame")
frame806.BackgroundColor3 = Color3.new(0.07058823853731155, 0.07058823853731155, 0.08235294371843338)
frame806.BackgroundTransparency = 0.25
frame806.Size = UDim2.new(0, 220, 0, 250)
frame806.Name = "Handle"
frame806.Parent = scrollingframe481

-- Creating UICorner
local uicorner807 = Instance.new("UICorner")
uicorner807.Parent = frame806

-- Creating UIGradient
local uigradient808 = Instance.new("UIGradient")
uigradient808.Rotation = 90
uigradient808.Parent = frame806

-- Creating UIScale
local uiscale809 = Instance.new("UIScale")
uiscale809.Parent = frame806

-- Creating Frame
local frame810 = Instance.new("Frame")
frame810.BackgroundTransparency = 1
frame810.Position = UDim2.new(0, 4, 0, 4)
frame810.Size = UDim2.new(1, -8, 1, -8)
frame810.Parent = frame806

-- Creating TextLabel
local textlabel811 = Instance.new("TextLabel")
textlabel811.Text = "Vuzo Zilux"
textlabel811.TextColor3 = Color3.new(1, 1, 1)
textlabel811.TextScaled = true
textlabel811.TextWrapped = true
textlabel811.BackgroundTransparency = 1
textlabel811.Size = UDim2.new(1, 0, 0, 40)
textlabel811.Name = "Title"
textlabel811.Parent = frame810

-- Creating ImageLabel
local imagelabel812 = Instance.new("ImageLabel")
imagelabel812.Image = "https://scriptblox.com/images/script/3623096087-1769447149143.png"
imagelabel812.BackgroundTransparency = 0.30000001192092896
imagelabel812.Position = UDim2.new(0, 0, 0, 42)
imagelabel812.Size = UDim2.new(1, 0, 0, 100)
imagelabel812.Name = "ImageAsset"
imagelabel812.Parent = frame810

-- Creating UICorner
local uicorner813 = Instance.new("UICorner")
uicorner813.Parent = imagelabel812

-- Creating UIListLayout
local uilistlayout814 = Instance.new("UIListLayout")
uilistlayout814.Parent = imagelabel812

-- Creating TextLabel
local textlabel815 = Instance.new("TextLabel")
textlabel815.Text = "Key"
textlabel815.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel815.TextScaled = true
textlabel815.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel815.TextStrokeTransparency = 0
textlabel815.TextWrapped = true
textlabel815.BackgroundTransparency = 1
textlabel815.Size = UDim2.new(0.5, 0, 0, 18)
textlabel815.Visible = false
textlabel815.Name = "KEY"
textlabel815.Parent = imagelabel812

-- Creating TextLabel
local textlabel816 = Instance.new("TextLabel")
textlabel816.Text = "Patched"
textlabel816.TextColor3 = Color3.new(1, 0, 0)
textlabel816.TextScaled = true
textlabel816.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel816.TextStrokeTransparency = 0
textlabel816.TextWrapped = true
textlabel816.BackgroundTransparency = 1
textlabel816.Size = UDim2.new(0.5, 0, 0, 18)
textlabel816.Visible = false
textlabel816.Name = "Patched"
textlabel816.Parent = imagelabel812

-- Creating TextLabel
local textlabel817 = Instance.new("TextLabel")
textlabel817.Text = "Verified"
textlabel817.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel817.TextScaled = true
textlabel817.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel817.TextStrokeTransparency = 0
textlabel817.TextWrapped = true
textlabel817.BackgroundTransparency = 1
textlabel817.Size = UDim2.new(0.5, 0, 0, 18)
textlabel817.Visible = false
textlabel817.Name = "Verified"
textlabel817.Parent = imagelabel812

-- Creating TextLabel
local textlabel818 = Instance.new("TextLabel")
textlabel818.Text = "Visits: 1333"
textlabel818.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel818.TextScaled = true
textlabel818.TextWrapped = true
textlabel818.BackgroundTransparency = 1
textlabel818.Position = UDim2.new(0, 0, 0, 142)
textlabel818.Size = UDim2.new(1, 0, 0, 18)
textlabel818.Name = "Visit"
textlabel818.Parent = frame810

-- Creating TextLabel
local textlabel819 = Instance.new("TextLabel")
textlabel819.Text = "Likes: 0"
textlabel819.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel819.TextScaled = true
textlabel819.TextWrapped = true
textlabel819.BackgroundTransparency = 1
textlabel819.Position = UDim2.new(0, 0, 0, 158)
textlabel819.Size = UDim2.new(1, 0, 0, 18)
textlabel819.Name = "Like"
textlabel819.Parent = frame810

-- Creating TextLabel
local textlabel820 = Instance.new("TextLabel")
textlabel820.Text = "💪Muscle Legends"
textlabel820.TextColor3 = Color3.new(1, 1, 1)
textlabel820.TextScaled = true
textlabel820.TextWrapped = true
textlabel820.BackgroundTransparency = 1
textlabel820.Position = UDim2.new(0, 0, 0, 176)
textlabel820.Size = UDim2.new(1, 0, 0, 18)
textlabel820.Name = "IsUniversal"
textlabel820.Parent = frame810

-- Creating TextButton
local textbutton821 = Instance.new("TextButton")
textbutton821.Text = "EXECUTE"
textbutton821.TextColor3 = Color3.new(1, 1, 1)
textbutton821.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton821.Position = UDim2.new(0, 0, 1, -20)
textbutton821.Size = UDim2.new(1, 0, 0, 20)
textbutton821.Parent = frame810

-- Creating UICorner
local uicorner822 = Instance.new("UICorner")
uicorner822.Parent = textbutton821

-- Creating TextButton
local textbutton823 = Instance.new("TextButton")
textbutton823.Text = "COPY TO CLIPBOARD"
textbutton823.TextColor3 = Color3.new(1, 1, 1)
textbutton823.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton823.Position = UDim2.new(0, 0, 1, -44)
textbutton823.Size = UDim2.new(1, 0, 0, 20)
textbutton823.Name = "copy"
textbutton823.Parent = frame810

-- Creating UICorner
local uicorner824 = Instance.new("UICorner")
uicorner824.Parent = textbutton823

-- Creating Frame
local frame825 = Instance.new("Frame")
frame825.BackgroundColor3 = Color3.new(1, 0.42352941632270813, 0)
frame825.BackgroundTransparency = 0.25
frame825.Size = UDim2.new(0, 220, 0, 250)
frame825.Name = "Handle"
frame825.Parent = scrollingframe481

-- Creating UICorner
local uicorner826 = Instance.new("UICorner")
uicorner826.Parent = frame825

-- Creating UIGradient
local uigradient827 = Instance.new("UIGradient")
uigradient827.Rotation = 90
uigradient827.Parent = frame825

-- Creating UIScale
local uiscale828 = Instance.new("UIScale")
uiscale828.Parent = frame825

-- Creating Frame
local frame829 = Instance.new("Frame")
frame829.BackgroundTransparency = 1
frame829.Position = UDim2.new(0, 4, 0, 4)
frame829.Size = UDim2.new(1, -8, 1, -8)
frame829.Parent = frame825

-- Creating TextLabel
local textlabel830 = Instance.new("TextLabel")
textlabel830.Text = "Auto Farm Fast Train Auto Sell Auto Collect"
textlabel830.TextColor3 = Color3.new(1, 1, 1)
textlabel830.TextScaled = true
textlabel830.TextWrapped = true
textlabel830.BackgroundTransparency = 1
textlabel830.Size = UDim2.new(1, 0, 0, 40)
textlabel830.Name = "Title"
textlabel830.Parent = frame829

-- Creating ImageLabel
local imagelabel831 = Instance.new("ImageLabel")
imagelabel831.Image = "rbxassetid://118914662369732"
imagelabel831.BackgroundTransparency = 0.30000001192092896
imagelabel831.Position = UDim2.new(0, 0, 0, 42)
imagelabel831.Size = UDim2.new(1, 0, 0, 100)
imagelabel831.Name = "ImageAsset"
imagelabel831.Parent = frame829

-- Creating UICorner
local uicorner832 = Instance.new("UICorner")
uicorner832.Parent = imagelabel831

-- Creating UIListLayout
local uilistlayout833 = Instance.new("UIListLayout")
uilistlayout833.Parent = imagelabel831

-- Creating TextLabel
local textlabel834 = Instance.new("TextLabel")
textlabel834.Text = "Key"
textlabel834.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel834.TextScaled = true
textlabel834.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel834.TextStrokeTransparency = 0
textlabel834.TextWrapped = true
textlabel834.BackgroundTransparency = 1
textlabel834.Size = UDim2.new(0.5, 0, 0, 18)
textlabel834.Name = "KEY"
textlabel834.Parent = imagelabel831

-- Creating TextLabel
local textlabel835 = Instance.new("TextLabel")
textlabel835.Text = "Patched"
textlabel835.TextColor3 = Color3.new(1, 0, 0)
textlabel835.TextScaled = true
textlabel835.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel835.TextStrokeTransparency = 0
textlabel835.TextWrapped = true
textlabel835.BackgroundTransparency = 1
textlabel835.Size = UDim2.new(0.5, 0, 0, 18)
textlabel835.Visible = false
textlabel835.Name = "Patched"
textlabel835.Parent = imagelabel831

-- Creating TextLabel
local textlabel836 = Instance.new("TextLabel")
textlabel836.Text = "Verified"
textlabel836.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel836.TextScaled = true
textlabel836.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel836.TextStrokeTransparency = 0
textlabel836.TextWrapped = true
textlabel836.BackgroundTransparency = 1
textlabel836.Size = UDim2.new(0.5, 0, 0, 18)
textlabel836.Visible = false
textlabel836.Name = "Verified"
textlabel836.Parent = imagelabel831

-- Creating TextLabel
local textlabel837 = Instance.new("TextLabel")
textlabel837.Text = "Visits: 378"
textlabel837.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel837.TextScaled = true
textlabel837.TextWrapped = true
textlabel837.BackgroundTransparency = 1
textlabel837.Position = UDim2.new(0, 0, 0, 142)
textlabel837.Size = UDim2.new(1, 0, 0, 18)
textlabel837.Name = "Visit"
textlabel837.Parent = frame829

-- Creating TextLabel
local textlabel838 = Instance.new("TextLabel")
textlabel838.Text = "Likes: 0"
textlabel838.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel838.TextScaled = true
textlabel838.TextWrapped = true
textlabel838.BackgroundTransparency = 1
textlabel838.Position = UDim2.new(0, 0, 0, 158)
textlabel838.Size = UDim2.new(1, 0, 0, 18)
textlabel838.Name = "Like"
textlabel838.Parent = frame829

-- Creating TextLabel
local textlabel839 = Instance.new("TextLabel")
textlabel839.Text = "[💪] Push a Lucky Block"
textlabel839.TextColor3 = Color3.new(1, 1, 1)
textlabel839.TextScaled = true
textlabel839.TextWrapped = true
textlabel839.BackgroundTransparency = 1
textlabel839.Position = UDim2.new(0, 0, 0, 176)
textlabel839.Size = UDim2.new(1, 0, 0, 18)
textlabel839.Name = "IsUniversal"
textlabel839.Parent = frame829

-- Creating TextButton
local textbutton840 = Instance.new("TextButton")
textbutton840.Text = "EXECUTE"
textbutton840.TextColor3 = Color3.new(1, 1, 1)
textbutton840.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton840.Position = UDim2.new(0, 0, 1, -20)
textbutton840.Size = UDim2.new(1, 0, 0, 20)
textbutton840.Parent = frame829

-- Creating UICorner
local uicorner841 = Instance.new("UICorner")
uicorner841.Parent = textbutton840

-- Creating TextButton
local textbutton842 = Instance.new("TextButton")
textbutton842.Text = "COPY TO CLIPBOARD"
textbutton842.TextColor3 = Color3.new(1, 1, 1)
textbutton842.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton842.Position = UDim2.new(0, 0, 1, -44)
textbutton842.Size = UDim2.new(1, 0, 0, 20)
textbutton842.Name = "copy"
textbutton842.Parent = frame829

-- Creating UICorner
local uicorner843 = Instance.new("UICorner")
uicorner843.Parent = textbutton842

-- Creating Frame
local frame844 = Instance.new("Frame")
frame844.BackgroundColor3 = Color3.new(1, 0.42352941632270813, 0)
frame844.BackgroundTransparency = 0.25
frame844.Size = UDim2.new(0, 220, 0, 250)
frame844.Name = "Handle"
frame844.Parent = scrollingframe481

-- Creating UICorner
local uicorner845 = Instance.new("UICorner")
uicorner845.Parent = frame844

-- Creating UIGradient
local uigradient846 = Instance.new("UIGradient")
uigradient846.Rotation = 90
uigradient846.Parent = frame844

-- Creating UIScale
local uiscale847 = Instance.new("UIScale")
uiscale847.Parent = frame844

-- Creating Frame
local frame848 = Instance.new("Frame")
frame848.BackgroundTransparency = 1
frame848.Position = UDim2.new(0, 4, 0, 4)
frame848.Size = UDim2.new(1, -8, 1, -8)
frame848.Parent = frame844

-- Creating TextLabel
local textlabel849 = Instance.new("TextLabel")
textlabel849.Text = "Sell Lemon OP Undetected Script auto farm"
textlabel849.TextColor3 = Color3.new(1, 1, 1)
textlabel849.TextScaled = true
textlabel849.TextWrapped = true
textlabel849.BackgroundTransparency = 1
textlabel849.Size = UDim2.new(1, 0, 0, 40)
textlabel849.Name = "Title"
textlabel849.Parent = frame848

-- Creating ImageLabel
local imagelabel850 = Instance.new("ImageLabel")
imagelabel850.Image = "https://scriptblox.com/images/script/79268393072444-1781453794182.png"
imagelabel850.BackgroundTransparency = 0.30000001192092896
imagelabel850.Position = UDim2.new(0, 0, 0, 42)
imagelabel850.Size = UDim2.new(1, 0, 0, 100)
imagelabel850.Name = "ImageAsset"
imagelabel850.Parent = frame848

-- Creating UICorner
local uicorner851 = Instance.new("UICorner")
uicorner851.Parent = imagelabel850

-- Creating UIListLayout
local uilistlayout852 = Instance.new("UIListLayout")
uilistlayout852.Parent = imagelabel850

-- Creating TextLabel
local textlabel853 = Instance.new("TextLabel")
textlabel853.Text = "Key"
textlabel853.TextColor3 = Color3.new(1, 0.3333333432674408, 0)
textlabel853.TextScaled = true
textlabel853.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel853.TextStrokeTransparency = 0
textlabel853.TextWrapped = true
textlabel853.BackgroundTransparency = 1
textlabel853.Size = UDim2.new(0.5, 0, 0, 18)
textlabel853.Name = "KEY"
textlabel853.Parent = imagelabel850

-- Creating TextLabel
local textlabel854 = Instance.new("TextLabel")
textlabel854.Text = "Patched"
textlabel854.TextColor3 = Color3.new(1, 0, 0)
textlabel854.TextScaled = true
textlabel854.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel854.TextStrokeTransparency = 0
textlabel854.TextWrapped = true
textlabel854.BackgroundTransparency = 1
textlabel854.Size = UDim2.new(0.5, 0, 0, 18)
textlabel854.Visible = false
textlabel854.Name = "Patched"
textlabel854.Parent = imagelabel850

-- Creating TextLabel
local textlabel855 = Instance.new("TextLabel")
textlabel855.Text = "Verified"
textlabel855.TextColor3 = Color3.new(0, 0.3333333432674408, 1)
textlabel855.TextScaled = true
textlabel855.TextStrokeColor3 = Color3.new(1, 1, 1)
textlabel855.TextStrokeTransparency = 0
textlabel855.TextWrapped = true
textlabel855.BackgroundTransparency = 1
textlabel855.Size = UDim2.new(0.5, 0, 0, 18)
textlabel855.Visible = false
textlabel855.Name = "Verified"
textlabel855.Parent = imagelabel850

-- Creating TextLabel
local textlabel856 = Instance.new("TextLabel")
textlabel856.Text = "Visits: 2289"
textlabel856.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel856.TextScaled = true
textlabel856.TextWrapped = true
textlabel856.BackgroundTransparency = 1
textlabel856.Position = UDim2.new(0, 0, 0, 142)
textlabel856.Size = UDim2.new(1, 0, 0, 18)
textlabel856.Name = "Visit"
textlabel856.Parent = frame848

-- Creating TextLabel
local textlabel857 = Instance.new("TextLabel")
textlabel857.Text = "Likes: 0"
textlabel857.TextColor3 = Color3.new(0.7843137383460999, 0.7843137383460999, 0.7843137383460999)
textlabel857.TextScaled = true
textlabel857.TextWrapped = true
textlabel857.BackgroundTransparency = 1
textlabel857.Position = UDim2.new(0, 0, 0, 158)
textlabel857.Size = UDim2.new(1, 0, 0, 18)
textlabel857.Name = "Like"
textlabel857.Parent = frame848

-- Creating TextLabel
local textlabel858 = Instance.new("TextLabel")
textlabel858.Text = "[🌳] Sell Lemons 🍋"
textlabel858.TextColor3 = Color3.new(1, 1, 1)
textlabel858.TextScaled = true
textlabel858.TextWrapped = true
textlabel858.BackgroundTransparency = 1
textlabel858.Position = UDim2.new(0, 0, 0, 176)
textlabel858.Size = UDim2.new(1, 0, 0, 18)
textlabel858.Name = "IsUniversal"
textlabel858.Parent = frame848

-- Creating TextButton
local textbutton859 = Instance.new("TextButton")
textbutton859.Text = "EXECUTE"
textbutton859.TextColor3 = Color3.new(1, 1, 1)
textbutton859.BackgroundColor3 = Color3.new(0.11764705926179886, 0.11764705926179886, 0.11764705926179886)
textbutton859.Position = UDim2.new(0, 0, 1, -20)
textbutton859.Size = UDim2.new(1, 0, 0, 20)
textbutton859.Parent = frame848

-- Creating UICorner
local uicorner860 = Instance.new("UICorner")
uicorner860.Parent = textbutton859

-- Creating TextButton
local textbutton861 = Instance.new("TextButton")
textbutton861.Text = "COPY TO CLIPBOARD"
textbutton861.TextColor3 = Color3.new(1, 1, 1)
textbutton861.BackgroundColor3 = Color3.new(0.19607843458652496, 0.19607843458652496, 0.19607843458652496)
textbutton861.Position = UDim2.new(0, 0, 1, -44)
textbutton861.Size = UDim2.new(1, 0, 0, 20)
textbutton861.Name = "copy"
textbutton861.Parent = frame848

-- Creating UICorner
local uicorner862 = Instance.new("UICorner")
uicorner862.Parent = textbutton861

-- Creating ScreenGui
local screengui863 = Instance.new("ScreenGui")
screengui863.Enabled = false
screengui863.ResetOnSpawn = false
screengui863.Name = "LighterCyan.ai"
screengui863.Parent = folder1

-- Creating UIListLayout
local uilistlayout864 = Instance.new("UIListLayout")
uilistlayout864.Parent = screengui863

-- Creating Frame
local frame865 = Instance.new("Frame")
frame865.BackgroundTransparency = 1
frame865.Size = UDim2.new(0.5, 0, 0.8999999761581421, 0)
frame865.Name = "Holder"
frame865.Parent = screengui863

-- Creating UIListLayout
local uilistlayout866 = Instance.new("UIListLayout")
uilistlayout866.Parent = frame865

-- Creating Frame
local frame867 = Instance.new("Frame")
frame867.BackgroundTransparency = 1
frame867.Size = UDim2.new(0.9599999785423279, 0, 1, 0)
frame867.Name = "InsetFrame"
frame867.Parent = frame865

-- Creating UIListLayout
local uilistlayout868 = Instance.new("UIListLayout")
uilistlayout868.Parent = frame867

-- Creating Frame
local frame869 = Instance.new("Frame")
frame869.BackgroundTransparency = 1
frame869.Size = UDim2.new(1, 0, 0, 70)
frame869.Name = "a4_Tabel"
frame869.Parent = frame867

-- Creating Frame
local frame870 = Instance.new("Frame")
frame870.BackgroundColor3 = Color3.new(1, 1, 1)
frame870.BackgroundTransparency = 0.6000000238418579
frame870.Size = UDim2.new(1, 0, 0, 50)
frame870.Name = "a3_Input&Send"
frame870.Parent = frame867

-- Creating UICorner
local uicorner871 = Instance.new("UICorner")
uicorner871.Parent = frame870

-- Creating UIStroke
local uistroke872 = Instance.new("UIStroke")
uistroke872.Color = Color3.new(1, 1, 1)
uistroke872.Parent = frame870

-- Creating TextBox
local textbox873 = Instance.new("TextBox")
textbox873.ClearTextOnFocus = false
textbox873.PlaceholderColor3 = Color3.new(0.37254902720451355, 0.37254902720451355, 0.37254902720451355)
textbox873.PlaceholderText = "Ask anything..."
textbox873.RichText = true
textbox873.Text = ""
textbox873.TextColor3 = Color3.new(0, 0, 0)
textbox873.TextScaled = true
textbox873.TextWrapped = true
textbox873.BackgroundTransparency = 1
textbox873.Position = UDim2.new(0.019999999552965164, 0, 0.05000000074505806, 0)
textbox873.Size = UDim2.new(0.7200000286102295, 0, 0.8999999761581421, 0)
textbox873.Name = "Ask"
textbox873.Parent = frame870

-- Creating TextButton
local textbutton874 = Instance.new("TextButton")
textbutton874.Text = "✓"
textbutton874.TextColor3 = Color3.new(0, 0, 0)
textbutton874.TextScaled = true
textbutton874.TextWrapped = true
textbutton874.BackgroundTransparency = 0.6000000238418579
textbutton874.Position = UDim2.new(0.75, 0, 0.05000000074505806, 0)
textbutton874.Size = UDim2.new(0.07599999755620956, 0, 0.8999999761581421, 0)
textbutton874.Name = "Send"
textbutton874.Parent = frame870

-- Creating UICorner
local uicorner875 = Instance.new("UICorner")
uicorner875.Parent = textbutton874

-- Creating UIStroke
local uistroke876 = Instance.new("UIStroke")
uistroke876.Color = Color3.new(1, 1, 1)
uistroke876.Parent = textbutton874

-- Creating TextButton
local textbutton877 = Instance.new("TextButton")
textbutton877.Text = "×"
textbutton877.TextColor3 = Color3.new(0, 0, 0)
textbutton877.TextScaled = true
textbutton877.TextWrapped = true
textbutton877.BackgroundTransparency = 0.6000000238418579
textbutton877.Position = UDim2.new(0.8349999785423279, 0, 0.05000000074505806, 0)
textbutton877.Size = UDim2.new(0.07599999755620956, 0, 0.8999999761581421, 0)
textbutton877.Name = "clear"
textbutton877.Parent = frame870

-- Creating UICorner
local uicorner878 = Instance.new("UICorner")
uicorner878.Parent = textbutton877

-- Creating UIStroke
local uistroke879 = Instance.new("UIStroke")
uistroke879.Color = Color3.new(1, 1, 1)
uistroke879.Parent = textbutton877

-- Creating TextButton
local textbutton880 = Instance.new("TextButton")
textbutton880.Text = "re-chat"
textbutton880.TextColor3 = Color3.new(0, 0, 0)
textbutton880.TextScaled = true
textbutton880.TextWrapped = true
textbutton880.BackgroundTransparency = 0.6000000238418579
textbutton880.Position = UDim2.new(0.9179999828338623, 0, 0.05000000074505806, 0)
textbutton880.Size = UDim2.new(0.07599999755620956, 0, 0.8999999761581421, 0)
textbutton880.Name = "re-chat"
textbutton880.Parent = frame870

-- Creating UICorner
local uicorner881 = Instance.new("UICorner")
uicorner881.Parent = textbutton880

-- Creating UIStroke
local uistroke882 = Instance.new("UIStroke")
uistroke882.Color = Color3.new(1, 1, 1)
uistroke882.Parent = textbutton880

-- Creating Frame
local frame883 = Instance.new("Frame")
frame883.BackgroundColor3 = Color3.new(1, 1, 1)
frame883.BackgroundTransparency = 0.5
frame883.Size = UDim2.new(1, 0, 0, 300)
frame883.Name = "a2_Chat"
frame883.Parent = frame867

-- Creating UICorner
local uicorner884 = Instance.new("UICorner")
uicorner884.Parent = frame883

-- Creating UIStroke
local uistroke885 = Instance.new("UIStroke")
uistroke885.Color = Color3.new(1, 1, 1)
uistroke885.Parent = frame883

-- Creating UIListLayout
local uilistlayout886 = Instance.new("UIListLayout")
uilistlayout886.Parent = frame883

-- Creating ScrollingFrame
local scrollingframe887 = Instance.new("ScrollingFrame")
scrollingframe887.CanvasSize = UDim2.new(1000, 0, 0, 0)
scrollingframe887.ScrollBarThickness = 0
scrollingframe887.BackgroundTransparency = 1
scrollingframe887.Size = UDim2.new(0.9599999785423279, 0, 0.9599999785423279, 0)
scrollingframe887.Name = "Chat"
scrollingframe887.Parent = frame883

-- Creating UIListLayout
local uilistlayout888 = Instance.new("UIListLayout")
uilistlayout888.Parent = scrollingframe887

-- Creating ScrollingFrame
local scrollingframe889 = Instance.new("ScrollingFrame")
scrollingframe889.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingframe889.ScrollBarThickness = 0
scrollingframe889.BackgroundTransparency = 1
scrollingframe889.Size = UDim2.new(0.9599999785423279, 0, 0.9599999785423279, 0)
scrollingframe889.Visible = false
scrollingframe889.Name = "Settings"
scrollingframe889.Parent = frame883

-- Creating UIListLayout
local uilistlayout890 = Instance.new("UIListLayout")
uilistlayout890.Parent = scrollingframe889

-- Creating ScrollingFrame
local scrollingframe891 = Instance.new("ScrollingFrame")
scrollingframe891.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingframe891.ScrollBarThickness = 0
scrollingframe891.BackgroundTransparency = 1
scrollingframe891.Size = UDim2.new(0.9599999785423279, 0, 0.9599999785423279, 0)
scrollingframe891.Visible = false
scrollingframe891.Name = "More"
scrollingframe891.Parent = frame883

-- Creating UIListLayout
local uilistlayout892 = Instance.new("UIListLayout")
uilistlayout892.Parent = scrollingframe891

-- Creating Frame
local frame893 = Instance.new("Frame")
frame893.BackgroundColor3 = Color3.new(1, 1, 1)
frame893.BackgroundTransparency = 1
frame893.Size = UDim2.new(1, 0, 0, 50)
frame893.Name = "a1_option"
frame893.Parent = frame867

-- Creating Frame
local frame894 = Instance.new("Frame")
frame894.BackgroundColor3 = Color3.new(1, 1, 1)
frame894.BackgroundTransparency = 0.6000000238418579
frame894.Size = UDim2.new(0.20000000298023224, 0, 0, 50)
frame894.Name = "a1.logo"
frame894.Parent = frame893

-- Creating UICorner
local uicorner895 = Instance.new("UICorner")
uicorner895.Parent = frame894

-- Creating UIStroke
local uistroke896 = Instance.new("UIStroke")
uistroke896.Color = Color3.new(1, 1, 1)
uistroke896.Parent = frame894

-- Creating TextLabel
local textlabel897 = Instance.new("TextLabel")
textlabel897.Text = "LighterCyan"
textlabel897.TextColor3 = Color3.new(1, 1, 1)
textlabel897.TextScaled = true
textlabel897.TextStrokeColor3 = Color3.new(0.3333333432674408, 1, 1)
textlabel897.TextStrokeTransparency = 0
textlabel897.TextWrapped = true
textlabel897.BackgroundTransparency = 1
textlabel897.Position = UDim2.new(0.05000000074505806, 0, 0.05000000074505806, 0)
textlabel897.Size = UDim2.new(0.8999999761581421, 0, 0.8999999761581421, 0)
textlabel897.Name = "Text"
textlabel897.Parent = frame894

-- Creating Frame
local frame898 = Instance.new("Frame")
frame898.BackgroundColor3 = Color3.new(1, 1, 1)
frame898.BackgroundTransparency = 0.6000000238418579
frame898.Size = UDim2.new(0.10000000149011612, 0, 0, 50)
frame898.Name = "a2.Chat"
frame898.Parent = frame893

-- Creating UICorner
local uicorner899 = Instance.new("UICorner")
uicorner899.Parent = frame898

-- Creating UIStroke
local uistroke900 = Instance.new("UIStroke")
uistroke900.Color = Color3.new(1, 1, 1)
uistroke900.Parent = frame898

-- Creating TextButton
local textbutton901 = Instance.new("TextButton")
textbutton901.Text = "🗨️ Chat"
textbutton901.TextScaled = true
textbutton901.TextWrapped = true
textbutton901.BackgroundTransparency = 1
textbutton901.Position = UDim2.new(0.05000000074505806, 0, 0.05000000074505806, 0)
textbutton901.Size = UDim2.new(0.8999999761581421, 0, 0.8999999761581421, 0)
textbutton901.Parent = frame898

-- Creating UIGradient
local uigradient902 = Instance.new("UIGradient")
uigradient902.Parent = textbutton901

-- Creating Frame
local frame903 = Instance.new("Frame")
frame903.BackgroundColor3 = Color3.new(1, 1, 1)
frame903.BackgroundTransparency = 0.6000000238418579
frame903.Size = UDim2.new(0.10000000149011612, 0, 0, 50)
frame903.Name = "a3.Settings"
frame903.Parent = frame893

-- Creating UICorner
local uicorner904 = Instance.new("UICorner")
uicorner904.Parent = frame903

-- Creating UIStroke
local uistroke905 = Instance.new("UIStroke")
uistroke905.Color = Color3.new(1, 1, 1)
uistroke905.Parent = frame903

-- Creating TextButton
local textbutton906 = Instance.new("TextButton")
textbutton906.Text = "⚙️ Settings"
textbutton906.TextScaled = true
textbutton906.TextWrapped = true
textbutton906.BackgroundTransparency = 1
textbutton906.Position = UDim2.new(0.05000000074505806, 0, 0.05000000074505806, 0)
textbutton906.Size = UDim2.new(0.8999999761581421, 0, 0.8999999761581421, 0)
textbutton906.Parent = frame903

-- Creating UIGradient
local uigradient907 = Instance.new("UIGradient")
uigradient907.Parent = textbutton906

-- Creating Frame
local frame908 = Instance.new("Frame")
frame908.BackgroundColor3 = Color3.new(1, 1, 1)
frame908.BackgroundTransparency = 0.6000000238418579
frame908.Size = UDim2.new(0.10000000149011612, 0, 0, 50)
frame908.Name = "a4.Explorer"
frame908.Parent = frame893

-- Creating UICorner
local uicorner909 = Instance.new("UICorner")
uicorner909.Parent = frame908

-- Creating UIStroke
local uistroke910 = Instance.new("UIStroke")
uistroke910.Color = Color3.new(1, 1, 1)
uistroke910.Parent = frame908

-- Creating TextButton
local textbutton911 = Instance.new("TextButton")
textbutton911.Text = "🌏 Explorer"
textbutton911.TextScaled = true
textbutton911.TextWrapped = true
textbutton911.BackgroundTransparency = 1
textbutton911.Position = UDim2.new(0.05000000074505806, 0, 0.05000000074505806, 0)
textbutton911.Size = UDim2.new(0.8999999761581421, 0, 0.8999999761581421, 0)
textbutton911.Parent = frame908

-- Creating UIGradient
local uigradient912 = Instance.new("UIGradient")
uigradient912.Parent = textbutton911

-- Creating Frame
local frame913 = Instance.new("Frame")
frame913.BackgroundColor3 = Color3.new(1, 1, 1)
frame913.BackgroundTransparency = 0.6000000238418579
frame913.Size = UDim2.new(0.10000000149011612, 0, 0, 50)
frame913.Name = "a5.About"
frame913.Parent = frame893

-- Creating UICorner
local uicorner914 = Instance.new("UICorner")
uicorner914.Parent = frame913

-- Creating UIStroke
local uistroke915 = Instance.new("UIStroke")
uistroke915.Color = Color3.new(1, 1, 1)
uistroke915.Parent = frame913

-- Creating TextButton
local textbutton916 = Instance.new("TextButton")
textbutton916.Text = "📜 About"
textbutton916.TextScaled = true
textbutton916.TextWrapped = true
textbutton916.BackgroundTransparency = 1
textbutton916.Position = UDim2.new(0.05000000074505806, 0, 0.05000000074505806, 0)
textbutton916.Size = UDim2.new(0.8999999761581421, 0, 0.8999999761581421, 0)
textbutton916.Parent = frame913

-- Creating UIGradient
local uigradient917 = Instance.new("UIGradient")
uigradient917.Parent = textbutton916

-- Creating Frame
local frame918 = Instance.new("Frame")
frame918.BackgroundColor3 = Color3.new(1, 1, 1)
frame918.BackgroundTransparency = 0.6000000238418579
frame918.Size = UDim2.new(0.10000000149011612, 0, 0, 50)
frame918.Name = "a6.Executor"
frame918.Parent = frame893

-- Creating UICorner
local uicorner919 = Instance.new("UICorner")
uicorner919.Parent = frame918

-- Creating UIStroke
local uistroke920 = Instance.new("UIStroke")
uistroke920.Color = Color3.new(1, 1, 1)
uistroke920.Parent = frame918

-- Creating TextButton
local textbutton921 = Instance.new("TextButton")
textbutton921.Text = "✏️ Executor"
textbutton921.TextScaled = true
textbutton921.TextWrapped = true
textbutton921.BackgroundTransparency = 1
textbutton921.Position = UDim2.new(0.05000000074505806, 0, 0.05000000074505806, 0)
textbutton921.Size = UDim2.new(0.8999999761581421, 0, 0.8999999761581421, 0)
textbutton921.Parent = frame918

-- Creating UIGradient
local uigradient922 = Instance.new("UIGradient")
uigradient922.Parent = textbutton921

-- Creating Frame
local frame923 = Instance.new("Frame")
frame923.BackgroundColor3 = Color3.new(1, 1, 1)
frame923.BackgroundTransparency = 0.6000000238418579
frame923.Size = UDim2.new(0.10000000149011612, 0, 0, 50)
frame923.Name = "a7.SaveScript"
frame923.Parent = frame893

-- Creating UICorner
local uicorner924 = Instance.new("UICorner")
uicorner924.Parent = frame923

-- Creating UIStroke
local uistroke925 = Instance.new("UIStroke")
uistroke925.Color = Color3.new(1, 1, 1)
uistroke925.Parent = frame923

-- Creating TextButton
local textbutton926 = Instance.new("TextButton")
textbutton926.Text = "📂 SaveScript"
textbutton926.TextScaled = true
textbutton926.TextWrapped = true
textbutton926.BackgroundTransparency = 1
textbutton926.Position = UDim2.new(0.05000000074505806, 0, 0.05000000074505806, 0)
textbutton926.Size = UDim2.new(0.8999999761581421, 0, 0.8999999761581421, 0)
textbutton926.Parent = frame923

-- Creating UIGradient
local uigradient927 = Instance.new("UIGradient")
uigradient927.Parent = textbutton926

-- Creating Frame
local frame928 = Instance.new("Frame")
frame928.BackgroundColor3 = Color3.new(1, 1, 1)
frame928.BackgroundTransparency = 0.6000000238418579
frame928.Size = UDim2.new(0.10000000149011612, 0, 0, 50)
frame928.Name = "z9.More"
frame928.Parent = frame893

-- Creating UICorner
local uicorner929 = Instance.new("UICorner")
uicorner929.Parent = frame928

-- Creating UIStroke
local uistroke930 = Instance.new("UIStroke")
uistroke930.Color = Color3.new(1, 1, 1)
uistroke930.Parent = frame928

-- Creating TextButton
local textbutton931 = Instance.new("TextButton")
textbutton931.Text = "📦 More"
textbutton931.TextScaled = true
textbutton931.TextWrapped = true
textbutton931.BackgroundTransparency = 1
textbutton931.Position = UDim2.new(0.05000000074505806, 0, 0.05000000074505806, 0)
textbutton931.Size = UDim2.new(0.8999999761581421, 0, 0.8999999761581421, 0)
textbutton931.Parent = frame928

-- Creating UIGradient
local uigradient932 = Instance.new("UIGradient")
uigradient932.Parent = textbutton931

-- Creating UIListLayout
local uilistlayout933 = Instance.new("UIListLayout")
uilistlayout933.Parent = frame893

-- Creating Script
local script934 = Instance.new("Script")
script934.Name = "README"
script934.Source = [=[--[[
		Thank you for using UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw.

		If you didn't save in Binary (rbxl) - it's recommended to save the game right away to take advantage of the binary format & to preserve values of certain properties if you used IgnoreDefaultProperties setting (as they might change in the future).
		You can do that by going to FILE -> Save to File As -> Make sure File Name ends with .rbxl -> Save

		ServerStorage, ServerScriptService and Server Scripts are IMPOSSIBLE to save because of FilteringEnabled.

		If your player cannot spawn into the game, please move the scripts in StarterPlayer somewhere else or delete them. Then run `game:GetService("Players").CharacterAutoLoads = true`.
		And use "Play Here" to start game instead of "Play" to spawn your Character where your Camera currently is.

		If the chat system does not work, please use the explorer and delete everything inside the TextChatService/Chat service(s). 
		Or run `game:GetService("Chat"):ClearAllChildren() game:GetService("TextChatService"):ClearAllChildren()`
				
		If Union and MeshPart collisions don't work, run the script below in the Studio Command Bar:
				
				
		local C = game:GetService("CoreGui")
		local D = Enum.CollisionFidelity.Default
				
		for _, v in game:GetDescendants() do
			if v:IsA("TriangleMeshPart") and not v:IsDescendantOf(C) then
				v.CollisionFidelity = D
			end
		end
		print("Done")
				
		If you can't move the Camera, run this script in the Studio Command Bar:
			
		workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed
		
		Or Destroy the Camera.

		This file was generated with the following settings:
		{"SaveBytecode":false,"Callback":false,"ShowStatus":true,"IgnoreDefaultPlayerScripts":true,"NilInstancesFixes":{"BaseWrap":null,"Animator":null,"Attachment":null,"PackageLink":null,"AdPortal":null},"IgnoreList":["CoreGui","CorePackages"],"__DEBUG_MODE":false,"KillAllScripts":true,"DecompileJobless":false,"IgnoreNotArchivable":true,"RemovePlayerCharacters":true,"Object":null,"DecompileIgnore":["TextChatService",null,null,null,null,null,null],"IgnoreSpecialProperties":false,"TreatUnionsAsParts":false,"IsModel":false,"NilInstances":false,"ExtraInstances":[],"noscripts":false,"ReadMe":true,"OptionsAliases":{"SavePlayers":"IsolatePlayers","IgnoreArchivable":"IgnoreNotArchivable","DecompileTimeout":"timeout","SaveNonCreatable":"SaveNotCreatable","InstancesBlacklist":"IgnoreList","IsolatePlayerGui":"IsolateLocalPlayer","FileName":"FilePath","IgnoreDefaultProps":"IgnoreDefaultProperties"},"scriptcache":true,"SharedStringOverwrite":false,"AlternativeWritefile":true,"mode":"invalidmode","SaveCacheInterval":56320,"IgnoreSharedStrings":true,"IsolatePlayers":false,"NotCreatableFixes":["","AdvancedDragger","AnimationTrack","Dragger","Player","PlayerGui","PlayerMouse","PlayerMouse","PlayerScripts","ScreenshotHud","StudioData","TextChatMessage","TextSource","TouchTransmitter","Translator"],"timeout":10,"IgnoreDefaultProperties":true,"Anonymous":false,"IsolateStarterPlayer":false,"IsolateLocalPlayerCharacter":false,"IgnorePropertiesOfNotScriptsOnScriptsMode":false,"AvoidFileOverwrite":true,"SaveNotCreatable":false,"IsolateLocalPlayer":false,"FilePath":false,"AntiIdle":true,"ShutdownWhenDone":false,"SafeMode":true,"IgnoreProperties":[]}

		Elapsed time: 0.4463156149722636 Date (UTC): 3 July 2026 20:13:32 PlaceId: 230362888 PlaceVersion: 570 Client Version: 2.726.1142 Executor: VegaX 4.0.8
]]]=]
