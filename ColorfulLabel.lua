-- Value 2.0
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local fpsLabel, fpsStroke
local pingLabel, pingStroke

local function refreshObjects()
	local success, point = pcall(function()
		return CoreGui
			.TopBarApp
			.TopBarApp
			.UnibarLeftFrame
			.HealthBar
			.ValueFolder
			.ValueGui
			.point
	end)

	if not success or not point then
		return
	end

	fpsLabel = point:FindFirstChild("FPSLabel")
	if fpsLabel then
		fpsStroke = fpsLabel:FindFirstChildOfClass("UIStroke")
	end

	pingLabel = point:FindFirstChild("PingLabel")
	if pingLabel then
		pingStroke = pingLabel:FindFirstChildOfClass("UIStroke")
	end
end

refreshObjects()

CoreGui.DescendantAdded:Connect(function(obj)
	if obj:IsA("TextLabel") then
		if obj.Name == "FPSLabel" then
			fpsLabel = obj
			fpsStroke = obj:WaitForChild("UIStroke")
		elseif obj.Name == "PingLabel" then
			pingLabel = obj
			pingStroke = obj:WaitForChild("UIStroke")
		end
	end
end)

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

local function getPingColor(ping: number)
	if ping <= 20 then
		return Color3.fromRGB(0,255,255) -- Cyan (Excellent)
	elseif ping <= 40 then
		return Color3.fromRGB(0,255,170) -- Mint
	elseif ping <= 60 then
		return Color3.fromRGB(191,255,0) -- Lime
	elseif ping <= 80 then
		return Color3.fromRGB(255,255,0) -- Yellow
	elseif ping <= 120 then
		return Color3.fromRGB(255,179,71) -- Yellow Orange
	elseif ping <= 180 then
		return Color3.fromRGB(255,165,0) -- Orange
	elseif ping <= 300 then
		return Color3.fromRGB(255,69,0) -- Red Orange
	elseif ping <= 500 then
		return Color3.fromRGB(255,0,0) -- Red
	elseif ping <= 1000 then
		return Color3.fromRGB(139,0,0) -- Dark Red
	else
		return Color3.fromRGB(255,105,180) -- Pink (Of course connection is dying 💀)
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

	if not fpsLabel or not fpsStroke then
		refreshObjects()
		return
	end

	if not pingLabel or not pingStroke then
		refreshObjects()
		return
	end

	local currentTime = tick()

	local fps = 1 / (currentTime - lastTime)
	lastTime = currentTime

	-- FPS
	local fpsColor = getFPSColor(fps)

	tweenTextStroke(
		fpsLabel,
		fpsColor
	)

	tweenStrokeColor(
		fpsStroke,
		fpsColor
	)

	-- Ping
	local ping = game:GetService("Players").LocalPlayer:GetNetworkPing() * 1000
	local pingColor = getPingColor(ping)

	tweenTextStroke(
		pingLabel,
		pingColor
	)

	tweenStrokeColor(
		pingStroke,
		pingColor
	)

end)
