-- Universal QA uses executor HTTP for public status and scoped private case sessions.
local mode = ...
local publicLookup = mode == "public_qa" or mode == "universal_case_qa"
local player = game:GetService("Players").LocalPlayer
if not player then return nil end

local bridge, transport, post, outsideQA
local caseOrigin = "https://arcscriptcenter-banned-token-universal-qa.kogpasan14.workers.dev"
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
    post = function(url, body, credential, maxBytes)
        local headers = { ["Content-Type"] = "application/json", ["Accept"] = "application/json" }
        if credential then headers.Authorization = "Bearer " .. credential end
        local reply = requestFn({
            Url = url, Method = "POST", Headers = headers, Body = service:JSONEncode(body), Timeout = 8,
        })
        if type(reply) ~= "table" then return nil end
        local raw = reply.Body or reply.body
        if type(raw) ~= "string" or #raw > maxBytes then return nil end
        local data = service:JSONDecode(raw)
        if type(data) ~= "table" then return nil end
        return { status = tonumber(reply.StatusCode or reply.Status), data = data }
    end
    local publicOrigin = mode == "universal_case_qa" and caseOrigin
        or "https://arcscriptcenter-ban-policy-qa.kogpasan14.workers.dev"
    transport = function()
        local reply = post(publicOrigin .. "/api/v1/client/bans/v2/status", { userId = tostring(player.UserId) }, nil, 1024)
        if not reply then return nil end
        if reply.status == 200 then return reply.data end
        if reply.status == 403 and reply.data.code == "target_not_allowed" then return { outsideQA = true } end
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
local function invoke(call, operation, ...)
    local arguments, signal = table.pack(...), Instance.new("BindableEvent")
    local finished, result = false, nil
    local function finish(value)
        if finished then return end
        finished, result = true, value
        signal:Fire()
    end
    task.delay(8, finish, nil)
    task.spawn(function()
        local ok, data = pcall(call, operation, table.unpack(arguments, 1, arguments.n))
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
    local data = invoke(transport, "policy")
    policyInFlight = false
    lastPolicy = nil
    outsideQA = publicLookup and data and data.outsideQA == true
    if not data or data.ok ~= true or data.identityVerified ~= (not publicLookup)
        or data.subject ~= tostring(player.UserId)
        or type(data.checkedAt) ~= "number" or data.checkedAt < lastChecked or data.checkedAt % 1 ~= 0
        or type(data.nextCheckAt) ~= "number" or data.nextCheckAt % 1 ~= 0 or data.nextCheckAt <= data.checkedAt
        or data.nextCheckAt > data.checkedAt + 30 then return nil end
    if not (data.state == "clear" or data.state == "ban_ingame" or data.state == "restricted_mode") then return nil end
    if data.state == "clear" then
        if data.ban ~= nil or data.notice ~= nil then return nil end
    elseif publicLookup then
        local notice = data.notice
        if data.ban ~= nil or type(notice) ~= "table" or type(notice.reason) ~= "string"
            or #notice.reason == 0 or #notice.reason > 120 or notice.reference ~= nil
            or (notice.revision ~= nil and (type(notice.revision) ~= "string"
                or #notice.revision ~= 24 or not notice.revision:match("^[0-9a-f]+$")))
            or not (notice.duration == "permanent" and notice.expiresAt == nil
                or notice.duration == "temporary" and type(notice.expiresAt) == "number"
                    and notice.expiresAt % 1 == 0 and notice.expiresAt > data.checkedAt)
            then return nil end
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
local session
local account = tostring(player.UserId)
local sessionFile = "ExperienceSettings/ArcScriptCenterCaseSession_" .. account .. ".json"
local function credential(value, prefix)
    return type(value) == "string" and #value == 70 and value:sub(1, 6) == prefix
        and value:sub(7):match("^[0-9a-f]+$") ~= nil
end

if publicLookup and type(readfile) == "function" then
    local ok, record = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(sessionFile))
    end)
    if ok and type(record) == "table" and record.subject == account and credential(record.session, "ASCVS_")
        and type(record.expiresAt) == "number" and record.expiresAt > os.time() then
        session = record.session
    end
end

local function clearSession()
    session = nil
    if type(delfile) == "function" then pcall(delfile, sessionFile) end
end
local function callCase(operation, body, token)
    return invoke(function(route)
        return post(caseOrigin .. "/api/v1/client/violation/" .. route, body, token, 300000)
    end, operation)
end

function client.hasPrivateCaseChannel()
    return not publicLookup or session ~= nil
end

function client.enrollCase(code, remember)
    if not publicLookup or session or not credential(code, "ASCVE_") then return false, "invalid_code" end
    local reply = callCase("enroll", {}, code)
    if not reply then return false, "unavailable" end
    local data = reply.data
    if reply.status ~= 201 or data.ok ~= true or not credential(data.session, "ASCVS_")
        or type(data.expiresAt) ~= "number" then return false, data.code end
    if data.subject ~= account then
        callCase("revoke", {}, data.session)
        return false, "different_account"
    end
    session = data.session
    if remember then
        local saved = type(writefile) == "function" and type(delfile) == "function" and pcall(function()
            if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder("ExperienceSettings") then
                makefolder("ExperienceSettings")
            end
            writefile(sessionFile, game:GetService("HttpService"):JSONEncode({
                subject = account, session = session, expiresAt = data.expiresAt,
            }))
        end)
        if not saved then return true, "not_saved" end
    end
    return true
end

local function privateCall(operation, body)
    local token = session
    if not token then return nil end
    local reply = callCase(operation, body, token)
    if session ~= token or not reply then return nil end
    if reply.status == 401 then clearSession() end
    return reply
end

function client.disconnectCase()
    if not session then return true end
    local reply = privateCall("revoke", {})
    if not reply or (reply.status ~= 200 and reply.status ~= 401) then return false end
    clearSession()
    return true
end

local function maskedReference(value)
    return type(value) == "string" and value:match("^••••[0-9A-F][0-9A-F]$") or nil
end

function client.restrictionReference(status)
    if not publicLookup or not status or not status.notice or not status.notice.revision then return nil end
    local reply = privateCall("reference", {})
    local data = reply and reply.status == 200 and reply.data
    if data and data.ok == true and data.subject == account and data.state == status.state
        and data.revision == status.notice.revision then
        return maskedReference(data.reference)
    end
end

function client.history()
    local data
    if publicLookup then
        local reply = privateCall("history", {})
        data = reply and reply.status == 200 and reply.data
    else
        data = invoke(transport, "violation")
    end
    if data and data.ok == true and data.identityVerified == true and type(data.notices) == "table" then
        for _, notice in ipairs(data.notices) do
            if type(notice) == "table" then notice.reference = maskedReference(notice.reference) end
        end
        return data.notices
    end
end

function client.appeal(noticeId, description)
    if not publicLookup then return invoke(transport, "appeal", noticeId, description) end
    local reply = privateCall("appeal", {noticeId = noticeId, description = description})
    return reply and reply.data
end
return client
