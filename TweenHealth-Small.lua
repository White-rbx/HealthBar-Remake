-- วางไว้ในสคริปต์ที่มีตัวแปร Fill และ TweenService อยู่
-- จะสร้าง a NumberValue ชื่อ "SaveValue" ใต้สคริปต์ (หรือ reuse ถ้ามี)

local TweenService = game:GetService("TweenService")
local scriptParent = script -- ถ้าเป็น ModuleScript/LocalScript ปรับตามที่เก็บ
-- ensure SaveValue exists
local SaveValue = script:FindFirstChild("SaveValue")
if not SaveValue then
    SaveValue = Instance.new("NumberValue")
    SaveValue.Name = "SaveValue"
    SaveValue.Value = 1 -- default assume full (จะถูกตั้งใหม่เมื่อพบ Fill)
    SaveValue.Parent = script
end

-- เก็บ ref ของ current tween
local currentFillTween = nil

-- helper: read X.Scale ของ Fill (safely)
local function readFillScale(fill)
    if not fill or not fill:IsA("GuiObject") then
        return SaveValue.Value or 0
    end
    local ok, s = pcall(function() return (fill.Size and fill.Size.X and fill.Size.X.Scale) end)
    if ok and type(s) == "number" then
        return s
    end
    return SaveValue.Value or 0
end

-- safe cancel
local function safeCancel(tw)
    if not tw then return end
    pcall(function()
        if type(tw.Cancel) == "function" then tw:Cancel() end
    end)
end

-- new tweenFillTo function
local TweenService = game:GetService("TweenService")
local SaveValue = script:FindFirstChild("SaveValue") or Instance.new("NumberValue")
SaveValue.Name = "SaveValue"
SaveValue.Value = 1
SaveValue.Parent = script

local currentTween = nil
local currentTarget = 1
local tweening = false

-- อ่านค่าปัจจุบัน
local function getCurrentScale()
	if Fill and Fill:IsA("GuiObject") then
		return Fill.Size.X.Scale
	end
	return SaveValue.Value or 0
end

-- tween ไปยังค่าใหม่ โดยถ้า tween อยู่ให้เปลี่ยนเป้าหมายแทน
local function smartTweenFill(newPercent)
	newPercent = math.clamp(newPercent, 0, 1)

	-- ถ้ามี Fill ไม่พร้อม ให้แค่จำไว้ก่อน
	if not Fill or not Fill:IsA("GuiObject") then
		SaveValue.Value = newPercent
		currentTarget = newPercent
		return
	end

	-- ถ้า tween กำลังทำงานอยู่ -> อัปเดต target เฉยๆ
	if tweening then
		currentTarget = newPercent
		return
	end

	-- ถ้าไม่มี tween กำลังทำงาน -> เริ่มใหม่
	tweening = true
	task.spawn(function()
		while math.abs(getCurrentScale() - currentTarget) > 0.001 do
			local start = getCurrentScale()
			local target = currentTarget
			local diff = math.abs(start - target)
			local time = math.clamp(diff * 0.6, 0.06, 0.5)

			if currentTween then
				pcall(function() currentTween:Cancel() end)
				currentTween = nil
			end

			local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			currentTween = TweenService:Create(Fill, tweenInfo, { Size = UDim2.new(target, 0, 1, 0) })
			currentTween:Play()

			currentTween.Completed:Wait()
			SaveValue.Value = target
		end
		tweening = false
	end)
end

-- export ให้เรียกง่าย
tweenFill = smartTweenFnil
