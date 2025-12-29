-- Demo Test 2.5

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local function get(path)
    return CoreGui:WaitForChild("ExperienceSettings", 10)
        and CoreGui.ExperienceSettings:WaitForChild(path, 10)
end

local targets = {
    get("Menu"):WaitForChild("TopBar", 10):WaitForChild("Holder", 10),
    get("Menu"):WaitForChild("HolderScreen", 10):WaitForChild("Shift_Lock", 10)
}

local HIGHLIGHT_IN = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local HIGHLIGHT_OUT = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local BOUNCE = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function apply(btn: ImageButton)
    if btn.Name == "a3_Dragger" then return end

    btn.BackgroundTransparency = 1
    local defaultSize = btn.Size
    local bounceSize = UDim2.new(
        defaultSize.X.Scale,
        defaultSize.X.Offset + 30,
        defaultSize.Y.Scale,
        defaultSize.Y.Offset + 30
    )

    local function reset()
        TweenService:Create(btn, HIGHLIGHT_OUT, {
            BackgroundTransparency = 1,
            Size = defaultSize
        }):Play()
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(btn, HIGHLIGHT_IN, {
                BackgroundTransparency = 0.2
            }):Play()

            TweenService:Create(btn, BOUNCE, {
                Size = bounceSize
            }):Play()
        end
    end)

    -- ปล่อยเมาส์ / นิ้ว
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            reset()
        end
    end)

    -- 🔥 แก้บัค “ลากออกแล้วค้าง”
    btn.MouseLeave:Connect(reset)
end

for _, holder in ipairs(targets) do
    for _, ui in ipairs(holder:GetDescendants()) do
        if ui:IsA("ImageButton") then
            apply(ui)
        end
    end
end
