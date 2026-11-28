-- Client entry for an owner-authorized, Studio-compatible STAGING Loader.
-- The experience server holds all Gateway credentials and uses HttpService.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local openLogin = require(script.Parent:WaitForChild("ESLogin"))
local website = "https://arcscriptcenter-eslogin-edge-qa.kogpasan14.workers.dev"

local function valid(profile)
    return type(profile) == "table" and type(profile.id) == "string"
        and type(profile.nickname) == "string"
        and (profile.status == "normal" or profile.status == "restricted_mode")
end

return function(loader)
    assert(type(loader.start) == "function" and type(loader.update) == "function"
        and type(loader.stop) == "function", "Loader start, update and stop callbacks are required")

    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local bridge = ReplicatedStorage:WaitForChild("ASCAccountStudioQA", 10)
    if not bridge then return false, "transport_unavailable" end

    local function invoke(op)
        local ok, result, reason = pcall(bridge.InvokeServer, bridge, op)
        if not ok then return nil, "unavailable" end
        return result, reason
    end

    local ok, signedIn = pcall(openLogin, {
        website = website,
        canRemember = function() return false end,
        begin = function() return invoke("begin") end,
        poll = function() return invoke("poll") end,
    }, playerGui)
    if not ok or not signedIn then
        invoke("cancel")
        return false, ok and "cancelled" or "unavailable"
    end

    local profile, reason = invoke("heartbeat")
    if not valid(profile) then
        invoke("logout")
        return false, reason or "session_expired"
    end

    local active = true
    local function stop(why)
        if not active then return end
        active = false
        pcall(loader.stop, why)
        invoke("logout")
    end
    local function signOut()
        stop("signed_out")
    end

    -- The Loader applies the initial policy before creating any gated UI.
    if not pcall(loader.start, profile, signOut) then
        stop("loader_unavailable")
        return false, "loader_unavailable"
    end

    while active do
        task.wait(25)
        if not active then break end
        local current, heartbeatError = invoke("heartbeat")
        if not active then break end
        if not valid(current) or current.id ~= profile.id then
            stop(heartbeatError or "session_expired")
        elseif current.status ~= profile.status or current.nickname ~= profile.nickname then
            profile = current
            if not pcall(loader.update, profile) then stop("loader_unavailable") end
        end
    end
    return true
end
