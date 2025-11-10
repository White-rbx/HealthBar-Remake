-- === Replace/insert these functions into your existing TweenHealth.lua ===

-- Smart tween state (reuse existing vars)
currentFillTween = nil
ignoreSizeChange = false
SaveValue = SaveValue or nil
pendingTarget = nil
tweening = false
local spawnPhase = false -- flag during spawn tween

local function ensureNumberSave()
	if SaveValue and SaveValue.Parent then return end
	SaveValue = Instance.new("NumberValue")
	SaveValue.Name = "SaveValue"
	SaveValue.Value = 1
	SaveValue.Parent = script
end

local function readFillScale()
	if Fill and Fill:IsA("GuiObject") then
		local ok, s = pcall(function() return Fill.Size.X.Scale end)
		if ok and type(s) == "number" then
			return s
		end
	end
	if SaveValue then return SaveValue.Value end
	return 1
end

local function safeCancel(tw)
	if not tw then return end
	pcall(function() if type(tw.Cancel) == "function" then tw:Cancel() end end)
end

-- smartTweenTo(targetPercent, optionalDuration)
local function smartTweenTo(targetPercent, forcedDuration)
	if not targetPercent then return end
	targetPercent = math.clamp(targetPercent, 0, 1)
	ensureNumberSave()

	-- if Fill not ready, just save and return (will apply later)
	if not Fill or not Fill:IsA("GuiObject") then
		SaveValue.Value = targetPercent
		pendingTarget = nil
		return
	end

	-- if tweening already (normal tween) -> update pendingTarget and return
	if tweening then
		pendingTarget = targetPercent
		return
	end

	-- compute current
	local cur = readFillScale()
	SaveValue.Value = cur

	-- no-op if close enough
	if math.abs(cur - targetPercent) < 0.001 then
		SaveValue.Value = targetPercent
		return
	end

	-- start tween
	tweening = true
	-- cancel previous tween
	if currentFillTween then
		safeCancel(currentFillTween)
		currentFillTween = nil
	end

	-- prevent watcher reacting to our immediate sets
	ignoreSizeChange = true

	-- determine duration:
	local dur
	if forcedDuration and type(forcedDuration) == "number" then
		dur = forcedDuration
	else
		-- if spawn phase or large diff, prefer FILL_TWEEN_TIME; else scale by diff for small changes
		local diff = math.abs(cur - targetPercent)
		dur = (spawnPhase and SPAWN_FILL_TIME) or (FILL_TWEEN_TIME or math.clamp(diff * 0.6, 0.06, 0.8))
	end

	local ok, tw = pcall(function()
		return TweenService:Create(Fill, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(targetPercent, 0, 1, 0)
		})
	end)
	if not ok or not tw then
		-- fallback: set directly
		pcall(function() Fill.Size = UDim2.new(targetPercent, 0, 1, 0) end)
		SaveValue.Value = targetPercent
		ignoreSizeChange = false
		tweening = false
		if pendingTarget and math.abs(pendingTarget - targetPercent) > 0.001 then
			local next = pendingTarget; pendingTarget = nil
			smartTweenTo(next)
		end
		return
	end

	currentFillTween = tw
	tw:Play()

	-- completion handler
	spawn(function()
		-- wait for tween to finish (robust)
		tw.Completed:Wait()
		SaveValue.Value = targetPercent
		currentFillTween = nil
		ignoreSizeChange = false
		tweening = false
		-- if pending target different, start next tween
		if pendingTarget and math.abs(pendingTarget - targetPercent) > 0.001 then
			local next = pendingTarget; pendingTarget = nil
			-- normal tweens after spawn use normal duration
			spawnPhase = false
			smartTweenTo(next)
		end
	end)
end

-- watcher attach: detect external Size changes and tween instead of letting them instant-change
local sizeWatcherConn = nil
local function attachFillWatcher()
	if not Fill or not Fill:IsA("GuiObject") then return end
	if sizeWatcherConn then return end

	ensureNumberSave()
	-- initialize SaveValue to current scale
	SaveValue.Value = readFillScale()

	sizeWatcherConn = Fill:GetPropertyChangedSignal("Size"):Connect(function()
		-- if we're the one changing, ignore
		if ignoreSizeChange then return end
		-- read new scale
		local ok, newScale = pcall(function() return Fill.Size.X.Scale end)
		if not ok or type(newScale) ~= "number" then return end

		local prev = SaveValue and SaveValue.Value or newScale
		-- if almost equal, update and nothing else
		if math.abs(prev - newScale) < 0.001 then
			SaveValue.Value = newScale
			return
		end

		-- revert instantly to prev so we can tween from prev -> newScale
		ignoreSizeChange = true
		pcall(function() Fill.Size = UDim2.new(prev, 0, 1, 0) end)
		-- small wait to let UI settle (very short)
		task.defer(function()
			ignoreSizeChange = false
			-- now tween smoothly to newScale
			-- use normal FILL_TWEEN_TIME for health changes (not spawn)
			spawnPhase = false
			smartTweenTo(newScale, FILL_TWEEN_TIME)
		end)
	end)
end

local function detachFillWatcher()
	if sizeWatcherConn then
		pcall(function() sizeWatcherConn:Disconnect() end)
		sizeWatcherConn = nil
	end
end

-- spawnFillTweenOnce: use SPAWN_FILL_TIME, then restore normal mode
local function spawnFillTweenOnce()
	-- wait a bit for UI to exist
	task.wait(0.9)
	local inner, fill = findInnerAndFill()
	if not fill or not fill:IsA("GuiObject") then return end

	-- set to 0 instantly (suppress watcher)
	ignoreSizeChange = true
	pcall(function() fill.Size = UDim2.new(0, 0, 1, 0) end)
	ignoreSizeChange = false

	-- mark spawnPhase to use SPAWN_FILL_TIME duration
	spawnPhase = true
	-- smartTweenTo will use forced duration if spawnPhase true
	smartTweenTo(1, SPAWN_FILL_TIME)
end

-- update humanoid health handler to ALWAYS call smartTweenTo(percent)
-- (replace the section in setupHumanoid where you previously called tweenFill)
-- inside your existing setupHumanoid function replace the fill-update line with:
--    smartTweenTo(percent)
-- (make sure applyAllFixes() has run and attachFillWatcher() is active)

-- Example snippet for the health changed part (place inside setupHumanoid)
-- humanoid:GetPropertyChangedSignal("Health"):Connect(function()
--     if not Fill then applyAllFixes() end
--     local percent = 1
--     if humanoid.MaxHealth and humanoid.MaxHealth > 0 then
--         percent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
--     end
--     if lastHealth and humanoid.Health < lastHealth then
--         onDamageTriggered(percent)
--     else
--         if percent < 0.5 then
--             local mapped = math.clamp(percent / 0.5, 0, 1)
--             tweenOverlayTo(mapped, LOWHEALTH_TWEEN_TIME)
--         else
--             tweenOverlayTo(1, LOWHEALTH_TWEEN_TIME)
--         end
--     end
--     -- NEW: always call smartTweenTo
--     smartTweenTo(percent)
--     lastHealth = humanoid.Health
-- end)

-- === End of replacements ===
