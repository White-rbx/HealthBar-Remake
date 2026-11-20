-- Public QA checks drive UI only. Verified case operations remain on the Roblox server bridge.
local publicLookup = (...) == "public_qa"
local player = game:GetService("Players").LocalPlayer
if not player then return nil end

local bridge, transport, outsideQA
if publicLookup then
    local env = getgenv()
    local candidates = table.pack(request, http_request, type(syn) == "table" and syn.request,
        type(http) == "table" and http.request, env.request)
    local requestFn
    for i = 1, candidates.n do
        if type(candidates[i]) == "function" then
            requestFn = candidates[i]
            break
        end
    end
    if not requestFn then return nil end
    local service = game:GetService("HttpService")
    transport = function()
        local reply = requestFn({
            Url = "https://arcscriptcenter-ban-policy-qa.kogpasan14.workers.dev/api/v1/client/bans/v2/status",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json", ["Accept"] = "application/json" },
            Body = service:JSONEncode({ userId = tostring(player.UserId) }),
            Timeout = 8,
        })
        if type(reply) ~= "table" then return nil end
        local raw = reply.Body or reply.body
        if type(raw) ~= "string" or #raw > 1024 then return nil end
        local data = service:JSONDecode(raw)
        local code = tonumber(reply.StatusCode or reply.Status)
        if code == 200 then return data end
        if code == 403 and type(data) == "table" and data.code == "target_not_allowed" then
            return { outsideQA = true }
        end
        return nil
    end
else
    bridge = game:GetService("ReplicatedStorage"):WaitForChild("ArcScriptCenterBanBridgeSTAGING", 5)
    if not bridge or not bridge:IsA("RemoteFunction") then return nil end
    transport = function(operation, ...)
        return bridge:InvokeServer(operation, ...)
    end
end

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
        local ok, data = pcall(transport, operation, table.unpack(arguments, 1, arguments.n))
        finish(ok and type(data) == "table" and data or nil)
    end)
    if not finished then signal.Event:Wait() end
    signal:Destroy()
    return result
end

local client = { publicLookup = publicLookup, isolatedQA = not bridge or bridge:GetAttribute("IsolatedQA") ~= false }

function client.isOutsideQA()
    return outsideQA == true
end

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
    outsideQA = publicLookup and data and data.outsideQA == true
    if not data or data.ok ~= true or data.identityVerified ~= (not publicLookup)
        or data.subject ~= tostring(player.UserId)
        or type(data.checkedAt) ~= "number" or data.checkedAt < lastChecked or data.checkedAt % 1 ~= 0
        or type(data.nextCheckAt) ~= "number" or data.nextCheckAt % 1 ~= 0 or data.nextCheckAt <= data.checkedAt
        or data.nextCheckAt > data.checkedAt + 30 then return nil end
    if not (data.state == "clear" or data.state == "ban_ingame" or data.state == "restricted_mode") then return nil end
    if publicLookup or data.state == "clear" then
        if data.ban ~= nil then return nil end
    else
        local item = data.ban
        if type(item) ~= "table" or item.selection ~= data.state
            or type(item.reason) ~= "string" or type(item.description) ~= "string"
            or (item.startAt ~= nil and (type(item.startAt) ~= "number"
                or item.startAt % 1 ~= 0 or item.startAt <= 0 or item.startAt > data.checkedAt))
            or not (item.duration == "permanent" and item.expiresAt == nil
                or item.duration == "temporary" and type(item.expiresAt) == "number"
                    and item.expiresAt % 1 == 0 and item.expiresAt >= data.nextCheckAt)
        then return nil end
    end
    -- Worker time is rounded down to whole seconds. Count from request start
    -- so a slow or delayed response never extends the policy lifetime.
    data.validUntil = startedAt + data.nextCheckAt - data.checkedAt - 1
    if data.validUntil <= os.clock() then return nil end
    lastChecked, lastPolicy = data.checkedAt, data
    return data
end
if not publicLookup then
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
end
return client
