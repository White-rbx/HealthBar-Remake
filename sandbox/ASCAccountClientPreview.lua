-- STAGING account adapter. The Executor transport handles HTTPS; HttpService handles JSON.
local env = getgenv()
local service = game:GetService("HttpService")
local candidates = table.pack(request, http_request, type(syn) == "table" and syn.request,
    type(http) == "table" and http.request, env.request)
local requestFn
for i = 1, candidates.n do
    if type(candidates[i]) == "function" then requestFn = candidates[i]; break end
end

local client = {
    website = "https://arcscriptcenter-account-qa.kogpasan14.workers.dev",
    publicLookup = false, isolatedQA = true, accountMode = true,
}
local folder, file = "ArcScriptCenter", "ArcScriptCenter/Account.json"
local session, current, currentPolicy
local function credential(value)
    return type(value) == "string" and #value == 64 and value:match("^[0-9a-f]+$") ~= nil
end
local function erase()
    session, current, currentPolicy = nil, nil, nil
    if type(delfile) == "function" then pcall(delfile, file) end
end

local function send(route, body, authenticated)
    if not requestFn or (authenticated and not session) then return nil, authenticated and "session_expired" or "unavailable" end
    local expected = session
    local completed, response, why = false, nil, nil
    local signal = Instance.new("BindableEvent")
    local function finish(value, failure)
        if completed then return end
        completed, response, why = true, value, failure
        signal:Fire()
    end
    task.delay(8, finish, nil, "unavailable")
    task.spawn(function()
        local success, data, code = pcall(function()
            local headers = { ["Content-Type"] = "application/json" }
            if authenticated then headers.Authorization = "Bearer " .. expected end
            local reply = requestFn({ Url = client.website .. "/api/v1/accounts/" .. route,
                Method = "POST", Headers = headers, Body = service:JSONEncode(body), Timeout = 8 })
            if type(reply) ~= "table" then return nil, "unavailable" end
            local raw = reply.Body or reply.body
            if type(raw) ~= "string" or #raw > 300000 then return nil, "unavailable" end
            local value = service:JSONDecode(raw)
            local status = tonumber(reply.StatusCode or reply.Status)
            if type(value) ~= "table" or not status then return nil, "unavailable" end
            if status >= 200 and status < 300 and value.ok == true then return value end
            return nil, type(value.code) == "string" and value.code or "unavailable"
        end)
        if not success then finish(nil, "unavailable")
        else finish(data, code) end
    end)
    if not completed then signal.Event:Wait() end
    signal:Destroy()
    if authenticated and session ~= expected then return nil, "session_expired" end
    if authenticated and why == "session_expired" then erase() end
    return response, why
end

if type(readfile) == "function" then
    local ok, saved = pcall(function() return service:JSONDecode(readfile(file)) end)
    if ok and type(saved) == "table" and credential(saved.session)
        and type(saved.expiresAt) == "number" and saved.expiresAt > os.time() then
        session = saved.session
    end
end

local function applyProfile(reply)
    local account = reply and reply.account
    if type(account) ~= "table" or type(account.id) ~= "string" or type(account.nickname) ~= "string"
        or not (account.status == "normal" or account.status == "restricted_mode" or account.status == "banned") then
        return nil
    end
    if current and current.id ~= account.id then return nil end
    current = account
    return current
end

function client.refresh()
    if not session then return nil, "no_session" end
    local data, reason = send("session", {}, true)
    return applyProfile(data), reason
end
function client.profile()
    return current
end
function client.hasSession()
    return session ~= nil
end
function client.begin()
    return send("pair/start", {})
end
function client.poll(pair, remember, stillOpen)
    local function cancelled()
        return type(stillOpen) == "function" and not stillOpen()
    end
    if cancelled() then return nil, "cancelled" end
    if type(pair) ~= "table" or not credential(pair.secret) then return nil, "unavailable" end
    local data, reason = send("pair/poll", {secret=pair.secret,remember=remember == true})
    if cancelled() and (not data or data.state ~= "ready") then return nil, "cancelled" end
    if not data or data.state == "pending" then return data, reason end
    if data.state ~= "ready" or not credential(data.session) then return nil, "unavailable" end
    session = data.session
    local function cancelIssuedSession()
        -- A session created while closing the GUI must never be remembered locally.
        pcall(client.logout) -- best-effort remote revocation
        erase() -- mandatory local invalidation even when the network is unavailable
        return nil, "cancelled"
    end
    if cancelled() then return cancelIssuedSession() end
    local account, errorCode = client.refresh()
    if cancelled() then return cancelIssuedSession() end
    if not account then erase(); return nil, errorCode end
    local saved = false
    if remember and type(writefile) == "function" and type(delfile) == "function" then
        saved = pcall(function()
            if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder(folder) then makefolder(folder) end
            writefile(file, service:JSONEncode({accountId=account.id,session=session,expiresAt=data.expiresAt}))
        end)
    end
    if cancelled() then return cancelIssuedSession() end
    return {state="ready",saved=saved}
end

function client.heartbeat()
    local reply = send("heartbeat", {}, true)
    return applyProfile(reply)
end
function client.policy()
    local started = os.clock()
    local account = client.refresh()
    currentPolicy = nil
    if not account then return nil end
    local state = ({normal="clear",restricted_mode="restricted_mode",banned="ban_ingame"})[account.status]
    local checked = os.time()
    currentPolicy = {state=state,identityVerified=true,checkedAt=checked,nextCheckAt=checked+30,validUntil=started+28}
    if state ~= "clear" then
        currentPolicy.ban = {selection=state,duration="permanent",
            reason="ArcScriptCenter account restriction.",description="See the ArcScriptCenter account website for case details."}
    end
    return currentPolicy
end
function client.secondsRemaining(status)
    return status and status == currentPolicy and math.max(0,status.validUntil-os.clock()) or 0
end
function client.hasPrivateCaseChannel()
    return session ~= nil and current ~= nil
end
function client.caseHistory()
    local result = send("history", {}, true)
    return result and result.cases
end
function client.history()
    local result = send("history", {}, true)
    return result and result.notices
end
function client.appeal(id, description)
    local result, why = send("appeal",{id=id,description=description},true)
    return result or {ok=false,code=why=="appeal_unavailable" and "appeal_ineligible" or why}
end
function client.feedback(description)
    return send("feedback",{description=description},true)
end
function client.logout()
    local result, reason = send("logout",{},true)
    if result or reason=="session_expired" then erase(); return true end
    return false
end
return client
