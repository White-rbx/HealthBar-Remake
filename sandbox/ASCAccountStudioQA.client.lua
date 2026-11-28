-- Run in the authorized Studio place. The server owns pairing and bearer secrets.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local bridge = ReplicatedStorage:WaitForChild("ASCAccountStudioQA", 10)
if not bridge then return end
local showLogin = require(ReplicatedStorage:WaitForChild("ESLogin"))
local gate = script:WaitForChild("VerifiedLoaderSession")

local function invoke(op)
    local ok, result, reason = pcall(bridge.InvokeServer, bridge, op)
    if not ok then return nil, "unavailable" end
    return result, reason
end
local login = {
    website="https://arcscriptcenter-eslogin-edge-qa.kogpasan14.workers.dev",
    canRemember=function() return false end,
    begin=function() return invoke("begin") end,
    poll=function() return invoke("poll") end,
}

if not showLogin(login, playerGui) then
    invoke("cancel")
    return
end

local profile, reason = invoke("session")
if not profile or profile.status == "banned" then
    invoke("logout")
    warn("ESLogin QA gate stopped", profile and profile.status or reason)
    return
end

-- The authorized place's Studio-compatible Loader subscribes to this event.
-- UI restrictions for restricted_mode must be applied before displaying features.
gate:Fire(profile.status)

local signedOut = false
script:WaitForChild("SignOut").Event:Connect(function()
    signedOut = true
    gate:Fire(false)
    invoke("logout")
end)
local previousStatus = profile.status
while not signedOut do
    task.wait(25)
    if signedOut then break end
    local current = invoke("session")
    if signedOut then break end
    local status = current and current.status
    if status ~= previousStatus then
        gate:Fire(status ~= "banned" and status or false)
        previousStatus = status
    end
    if not current or status == "banned" then break end
    invoke("heartbeat")
end
