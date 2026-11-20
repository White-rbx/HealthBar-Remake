-- Client presentation only. All protected operations go through the Roblox server.
local bridge = game:GetService("ReplicatedStorage"):WaitForChild("ArcScriptCenterBanBridgeSTAGING", 5)
local player = game:GetService("Players").LocalPlayer
if not bridge or not bridge:IsA("RemoteFunction") or not player then return nil end
local lastChecked = 0
local lastPolicy
local policyInFlight = false
local function invoke(operation, ...)
    local arguments, signal = table.pack(...), Instance.new("BindableEvent")
    local finished, result = false, nil
    local function finish(value)
        if finished then return end
        finished, result = true, value
        signal:Fire()
    end
    task.delay(8, finish, nil)
    task.spawn(function()
        local ok, data = pcall(bridge.InvokeServer, bridge, operation, table.unpack(arguments, 1, arguments.n))
        finish(ok and type(data) == "table" and data or nil)
    end)
    if not finished then signal.Event:Wait() end
    signal:Destroy()
    return result
end

local client = { isolatedQA = bridge:GetAttribute("IsolatedQA") ~= false }

function client.secondsRemaining(status)
    return status and status == lastPolicy and math.max(0, status.validUntil - os.clock()) or 0
end

function client.policy()
    if policyInFlight then return nil end
    policyInFlight = true
    local startedAt = os.clock()
    local data = invoke("policy")
    policyInFlight = false
    lastPolicy = nil
    if not data or data.ok ~= true or data.identityVerified ~= true
        or data.subject ~= tostring(player.UserId)
        or type(data.checkedAt) ~= "number" or data.checkedAt < lastChecked or data.checkedAt % 1 ~= 0
        or type(data.nextCheckAt) ~= "number" or data.nextCheckAt % 1 ~= 0 or data.nextCheckAt <= data.checkedAt
        or data.nextCheckAt > data.checkedAt + 30 then return nil end
    if data.state ~= "clear" then
        local item = data.ban
        if not (data.state == "ban_ingame" or data.state == "restricted_mode")
            or type(item) ~= "table" or item.selection ~= data.state
            or type(item.reason) ~= "string" or type(item.description) ~= "string"
            or (item.startAt ~= nil and (type(item.startAt) ~= "number"
                or item.startAt % 1 ~= 0 or item.startAt <= 0 or item.startAt > data.checkedAt))
            or not (item.duration == "permanent" and item.expiresAt == nil
                or item.duration == "temporary" and type(item.expiresAt) == "number"
                    and item.expiresAt % 1 == 0 and item.expiresAt >= data.nextCheckAt)
        then return nil end
    elseif data.ban ~= nil then return nil end
    -- Worker time is rounded down to whole seconds. Count from request start
    -- so a slow or delayed response never extends the policy lifetime.
    data.validUntil = startedAt + data.nextCheckAt - data.checkedAt - 1
    if data.validUntil <= os.clock() then return nil end
    lastChecked, lastPolicy = data.checkedAt, data
    return data
end
function client.history()
    local data = invoke("violation")
    if data and data.ok == true and data.identityVerified == true and type(data.notices) == "table" then
        return data.notices
    end
    return nil
end
function client.appeal(noticeId, description)
    return invoke("appeal", noticeId, description)
end
return client
