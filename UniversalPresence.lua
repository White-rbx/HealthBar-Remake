-- UniversalPresence.lua v0.5.14 — presence + optional consented profile.
-- This is a client-side prototype. It never starts unless :start(true) is called.
-- No usernames, Roblox UserIds, place IDs, chat messages or API secrets are sent.
-- Caller must supply an HTTP request function supported by its host environment.
local HttpService = game:GetService("HttpService")
local BASE = "https://arcscriptcenter-api.kogpasan14.workers.dev"
local Heartbeat = {}
Heartbeat.__index = Heartbeat

function Heartbeat.new(httpRequest, onStatus, profile)
    assert(type(httpRequest) == "function", "Provide an approved HTTP request function")
    return setmetatable({
        request = httpRequest,
        onStatus = type(onStatus) == "function" and onStatus or function() end,
        id = HttpService:GenerateGUID(false):gsub("%-", ""):lower(),
        active = false,
        generation = 0,
        profile = (type(profile) == "table" and profile.consent == true) and profile or nil,
    }, Heartbeat)
end

function Heartbeat:_send(path)
    local data = {sessionId = self.id}
    if path == "/api/v1/presence/heartbeat" and self.profile then
        data.profileConsent = true
        data.userId = tostring(self.profile.userId)
        data.username = self.profile.username
        data.displayName = self.profile.displayName
    end
    local ok, response = pcall(self.request, {
        Url = BASE .. path,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json", ["Accept"] = "application/json" },
        Body = HttpService:JSONEncode(data),
    })
    if not ok then return false, tostring(response) end
    if type(response) ~= "table" then return false, "Invalid HTTP response" end
    local status = tonumber(response.StatusCode or response.Status or 0) or 0
    if status < 200 or status >= 300 then return false, "HTTP " .. tostring(status) end
    return true
end

function Heartbeat:start(consent)
    if consent ~= true then return false, "User consent required. No data was sent." end
    if self.active then return true, "Already enabled" end
    self.active = true
    self.generation += 1
    local cycle = self.generation
    task.spawn(function()
        while self.active and self.generation == cycle do
            local ok, err = self:_send("/api/v1/presence/heartbeat")
            pcall(self.onStatus, ok, err)
            task.wait(60)
        end
    end)
    return true
end

function Heartbeat:stop()
    if not self.active then return end
    self.active = false
    self.generation += 1
    -- Best effort leave notification. If interrupted, sessions naturally expire after 150s.
    task.spawn(function()
        self:_send("/api/v1/presence/leave")
    end)
end

function Heartbeat:isEnabled()
    return self.active
end
return Heartbeat
