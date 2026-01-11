-- Value 1.0
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local HealthBar = game:GetService("CoreGui"):WaitForChild("TopBarApp")
    :WaitForChild("TopBarApp")
    :WaitForChild("UnibarLeftFrame")
    :WaitForChild("HealthBar")
    :WaitForChild("ValueFolder")

local valueGui = HealthBar:WaitForChild("ValueGui")
local point = valueGui:WaitForChild("point")
local fpsLabel = point:WaitForChild("FPSLabel") :: TextLabel
local uiStroke = fpsLabel:WaitForChild("UIStroke") :: UIStroke

-- Function to get color based on FPS
local function getFPSColor(fps: number)
    if fps <= 10 then
        return Color3.fromRGB(255, 0, 0) -- Red
    elseif fps <= 20 then
        return Color3.fromRGB(255, 69, 0) -- Red Orange
    elseif fps <= 30 then
        return Color3.fromRGB(255, 165, 0) -- Orange
    elseif fps <= 35 then
        return Color3.fromRGB(255, 179, 71) -- Yellow Orange
    elseif fps <= 40 then
        return Color3.fromRGB(255, 255, 0) -- Yellow
    elseif fps <= 50 then
        return Color3.fromRGB(191, 255, 0) -- Lime
    elseif fps <= 60 then
        return Color3.fromRGB(0, 255, 170) -- Mint
    elseif fps <= 120 then
        return Color3.fromRGB(0, 255, 255) -- Cyan
    elseif fps <= 500 then
        return Color3.fromRGB(0, 191, 255) -- Blue Cyan
    else
        return Color3.fromRGB(255, 105, 180) -- Pink
    end
end

-- Tween TextLabel stroke
local function tweenTextStroke(label: TextLabel, color: Color3)
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(label, tweenInfo, {TextStrokeColor3 = color})
    tween:Play()
end

-- Tween UIStroke (Color)
local function tweenStrokeColor(stroke: UIStroke, color: Color3)
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(stroke, tweenInfo, {Color = color})
    tween:Play()
end

-- Main loop
local lastTime = tick()
RunService.RenderStepped:Connect(function()
    local currentTime = tick()
    local fps = 1 / (currentTime - lastTime)
    lastTime = currentTime

    local color = getFPSColor(fps)
    tweenTextStroke(fpsLabel, color)
    tweenStrokeColor(uiStroke, color)
end)
