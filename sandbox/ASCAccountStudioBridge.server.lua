-- Install only in an owner-controlled STAGING test place with HTTP requests enabled.
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local newClient = require(script.Parent:WaitForChild("ASCAccountClientPreview"))
local states = {}
local bridge = Instance.new("RemoteFunction")
bridge.Name = "ASCAccountStudioQA"
local allowed = {begin=true, poll=true, session=true, heartbeat=true, logout=true, cancel=true}
local waitBetween = {begin=3, poll=2, session=1, heartbeat=5, logout=1}

local function request(options)
    return HttpService:RequestAsync({
        Url=options.Url, Method=options.Method, Headers=options.Headers, Body=options.Body,
    })
end

local function clear(player, state)
    state.pair = nil
    player:SetAttribute("ASCAccountQAStatus", nil)
end

local function handle(player, state, op)
    local client = state.client
    if op == "begin" then
        if client.hasSession() then return nil, "already_signed_in" end
        if state.pair and state.pair.expiresAt > os.time() then
            return {code=state.pair.code, expiresAt=state.pair.expiresAt}
        end
        local pair, reason = client.begin()
        if state.cancelled then return nil, "cancelled" end
        state.pair = pair
        if pair then return {code=pair.code, expiresAt=pair.expiresAt} end
        return nil, reason
    elseif op == "poll" then
        if not state.pair then return nil, "session_expired" end
        local result, reason = client.poll(state.pair, false, function()
            return not state.cancelled and player.Parent == Players
        end)
        if result and result.state == "ready" then
            state.pair = nil
            player:SetAttribute("ASCAccountQAStatus", client.profile().status)
        elseif reason == "session_expired" then
            state.pair = nil
        end
        return result, reason
    elseif op == "logout" then
        clear(player, state)
        return client.logout()
    end
    local profile, reason
    if op == "session" then profile, reason = client.refresh()
    else profile = client.heartbeat() end
    player:SetAttribute("ASCAccountQAStatus", profile and profile.status or nil)
    return profile, reason
end

bridge.OnServerInvoke = function(player, op)
    if player.Parent ~= Players or type(op) ~= "string" or not allowed[op] then
        return nil, "invalid_input"
    end
    local state = states[player]
    if not state then
        if op ~= "begin" then return nil, "no_session" end
        state = {client=newClient(request), nextAt={}}
        states[player] = state
    end
    if op == "cancel" then
        state.cancelled = true
        clear(player, state)
        if not state.busy and state.client.hasSession() then
            state.busy = true
            state.client.logout()
            state.busy = false
        end
        return true
    end
    local now = os.clock()
    if state.busy or now < (state.nextAt[op] or 0) then return nil, "rate_limited" end
    state.nextAt[op] = now + waitBetween[op]
    state.busy = true
    if op == "begin" then state.cancelled = false end
    local ok, result, reason = pcall(handle, player, state, op)
    if state.cancelled then
        if state.client.hasSession() then state.client.logout() end
        clear(player, state)
        result, reason = nil, "cancelled"
    end
    state.busy = false
    if not ok then clear(player, state); return nil, "unavailable" end
    return result, reason
end

Players.PlayerRemoving:Connect(function(player)
    local state = states[player]
    states[player] = nil
    if not state then return end
    state.cancelled = true
    if not state.busy and state.client.hasSession() then task.spawn(state.client.logout) end
end)

bridge.Parent = ReplicatedStorage
