-- Isolated QA client. A ModuleScript receives a server-side Roblox HTTP transport.
local function newClient(requestFn)
    local service = game:GetService("HttpService")
    local gatewayOrigin = "https://arcscriptcenter-eslogin-pairing-qa.kogpasan14.workers.dev"
    local client = {
        website = "https://arcscriptcenter-eslogin-edge-qa.kogpasan14.workers.dev",
        publicLookup = false, isolatedQA = true, accountMode = true,
    }
    local session, current, currentPolicy, expectedAccountId
    local function credential(value)
        return type(value) == "string" and #value == 64 and value:match("^[0-9a-f]+$") ~= nil
    end
    local function erase()
        session, current, currentPolicy, expectedAccountId = nil, nil, nil, nil
        return true
    end
    -- Cloudflare Access is a different authentication layer from ESLogin Passkeys.
    -- Roblox HTTP does NOT inherit the browser's Access session; never copy its
    -- cookie or a service credential into Luau to make pairing appear to work.
    -- A redirect (or followed Access HTML) must be reported as Access-required,
    -- not parsed as an Account API JSON response or treated as a verified session.
    local function accessChallenge(reply, status, raw)
        if status and status >= 300 and status < 400 then return true end
        local headers = reply.Headers or reply.headers
        if type(headers) == "table" then
            for name, value in pairs(headers) do
                if type(name) == "string" and type(value) == "string"
                    and name:lower() == "location"
                    and value:lower():find(".cloudflareaccess.com", 1, true) then
                    return true
                end
            end
        end
        if type(raw) ~= "string" or not raw:match("^%s*<") then return false end
        local prefix = raw:sub(1, 16000):lower()
        return prefix:find("cloudflare access", 1, true) ~= nil
            or prefix:find(".cloudflareaccess.com", 1, true) ~= nil
    end

    local function send(route, body, authenticated)
        if not requestFn then return nil, "transport_unavailable" end
        if authenticated and not session then return nil, "session_expired" end
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
                local reply = requestFn({ Url = gatewayOrigin .. "/api/v1/accounts/" .. route,
                    Method = "POST", Headers = headers, Body = next(body) and service:JSONEncode(body) or "{}", Timeout = 8 })
                if type(reply) ~= "table" then return nil, "unavailable" end
                local status = tonumber(reply.StatusCode or reply.Status)
                local raw = reply.Body or reply.body
                if accessChallenge(reply, status, raw) then return nil, "access_required" end
                if type(raw) ~= "string" or #raw > 300000 then return nil, "unavailable" end
                -- Never treat HTML/Access login pages as the Account JSON API.
                if raw:match("^%s*<") then return nil, "unavailable" end
                local value = service:JSONDecode(raw)
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
        if authenticated and why == "session_expired" and route ~= "logout" then erase() end
        return response, why
    end

    local function applyProfile(reply)
        local account = reply and reply.account
        if type(account) ~= "table" or type(account.id) ~= "string" or type(account.nickname) ~= "string"
            or not (account.status == "normal" or account.status == "restricted_mode" or account.status == "banned") then
            return nil
        end
        if expectedAccountId and expectedAccountId ~= account.id then
            erase()
            return nil
        end
        current, expectedAccountId = account, account.id
        return current
    end

    function client.refresh()
        if not session then
            current, currentPolicy = nil, nil
            return nil, "no_session"
        end
        local data, reason = send("session", {}, true)
        local account = applyProfile(data)
        -- A transient request failure must not leave an old verified identity
        -- visible to owner-scoped UI. Preserve the token for a later retry.
        if not account then current, currentPolicy = nil, nil end
        return account, reason or (not account and "session_expired" or nil)
    end
    function client.profile()
        return current
    end
    function client.hasSession()
        return session ~= nil
    end
    function client.canRemember()
        return false
    end
    function client.begin()
        local pair, reason = send("pair/start", {})
        if not pair then return nil, reason end
        if type(pair.code) ~= "string" or #pair.code ~= 12 or not pair.code:match("^[0-9A-F]+$")
            or not credential(pair.secret) or type(pair.expiresAt) ~= "number"
            or pair.expiresAt <= os.time() then return nil, "unavailable" end
        return pair
    end
    function client.poll(pair, _remember, stillOpen)
        local function cancelled()
            return type(stillOpen) == "function" and not stillOpen()
        end
        if cancelled() then return nil, "cancelled" end
        if type(pair) ~= "table" or not credential(pair.secret) then return nil, "unavailable" end
        local data, reason = send("pair/poll", {secret=pair.secret})
        if cancelled() and (not data or data.state ~= "ready") then return nil, "cancelled" end
        if not data or data.state == "pending" then return data, reason end
        if data.state ~= "ready" or not credential(data.session) then return nil, "unavailable" end
        session, current, currentPolicy, expectedAccountId = data.session, nil, nil, nil
        local function cancelIssuedSession()
            -- A session created while closing the GUI must never be remembered locally.
            client.logout() -- attempt remote revocation and always invalidate locally
            return nil, "cancelled"
        end
        if cancelled() then return cancelIssuedSession() end
        local account, errorCode = client.refresh()
        if cancelled() then return cancelIssuedSession() end
        if not account or type(data.expiresAt) ~= "number" or data.expiresAt <= os.time() then
            client.logout()
            return nil, errorCode or "session_expired"
        end
        return {state="ready",saved=false}
    end

    function client.heartbeat()
        local reply = send("heartbeat", {}, true)
        local account = applyProfile(reply)
        if not account then current, currentPolicy = nil, nil end
        return account
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
        return false
    end
    function client.history()
        return nil
    end
    function client.caseHistory()
        return nil
    end
    function client.logout()
        -- Clear the in-memory session even if remote revocation fails.
        -- false means the server-side token may remain valid until expiry.
        local result, reason = send("logout",{},true)
        local cleared = erase()
        return result ~= nil or reason == "session_expired", cleared
    end
    return client
end

if typeof(script) == "Instance" and script:IsA("ModuleScript") then
    return newClient
end

-- Retire saved sessions from older previews without reading their contents.
if type(isfile) == "function" and type(delfile) == "function" then
    pcall(function()
        local path = "ArcScriptCenter/Account.json"
        if isfile(path) then delfile(path) end
    end)
end

-- Compatibility with the existing opt-in preview entry.
local env = getgenv()
local candidates = table.pack(request, http_request, type(syn) == "table" and syn.request,
    type(http) == "table" and http.request, env.request)
for i = 1, candidates.n do
    if type(candidates[i]) == "function" then return newClient(candidates[i]) end
end
return newClient(nil)
