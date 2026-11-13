-- UniversalPresence.lua | ArcScriptCenter Phase 2 v0.5.41.3
-- Backward-compatible replacement for UniversalPresence.lua v0.5.14
-- Production ONLY | OFF by default | explicit per-feature opt-in
-- Loading this ModuleScript/loadstring DOES NOT start any network requests.
-- Compatible: .new(httpRequest, onStatus, profile), :start(true), :stop(), :isEnabled()
-- New methods: :count(), :getStatus(), :setAdminNicknameConsent(),
--              :setAnalyticsConsent(), :setLeaderboardConsent(), :setAvatarConsent()
-- All client-reported identities are unverified; this is NOT an authorization system.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local BASE = "https://arcscriptcenter-api.kogpasan14.workers.dev"
local HEARTBEAT = "/api/v1/presence/heartbeat"
local LEAVE = "/api/v1/presence/leave"
local COUNT = "/api/v1/presence/count"
local INTERVAL = 30
local SINGLETON_KEY = "__ASC_UniversalPresence_Active"

local function globalEnvironment()
    if type(getgenv) ~= "function" then return nil end
    local env = getgenv()
    return type(env) == "table" and env or nil
end

local Client = {}
Client.__index = Client

local function getRequest()
    if type(request) == "function" then return request end
    if type(http_request) == "function" then return http_request end
    if type(syn) == "table" and type(syn.request) == "function" then return syn.request end
    if type(http) == "table" and type(http.request) == "function" then return http.request end
    if type(getgenv) == "function" then
        local env = getgenv()
        if type(env) == "table" and type(env.request) == "function" then
            return env.request
        end
    end
    return nil
end

-- A v0.5.14 caller may pass { consent=true, userId=..., username=..., displayName=... }
-- as the 3rd constructor argument. Preserve that explicit profile opt-in, but
-- take identity fields from the local Player instead of trusting stale inputs.
function Client.new(requestFunction, onStatus, profile)
    local fn = type(requestFunction) == "function" and requestFunction or getRequest()
    assert(type(fn) == "function", "HTTP request() with POST support is required")
    local player = Players.LocalPlayer
    assert(player ~= nil, "LocalPlayer unavailable")
    local legacyProfileConsent = type(profile) == "table" and profile.consent == true
    local sessionId = HttpService:GenerateGUID(false):gsub("%-", ""):lower()
    local legacyProfile = legacyProfileConsent and {
        consent = true,
        userId = tostring(player.UserId),
        username = player.Name,
        displayName = player.DisplayName,
    } or nil
    return setmetatable({
        request = fn,
        player = player,
        onStatus = type(onStatus) == "function" and onStatus or function() end,
        sessionId = sessionId,
        id = sessionId,       -- v0.5.14 compatibility
        profile = legacyProfile, -- legacy read-only snapshot; use setter to change consent
        active = false,
        adminSharing = legacyProfileConsent,
        adminDetails = false, -- new full-profile disclosure, never inherited
        analytics = false,
        leaderboard = false,
        avatar = false,
        generation = 0,
        running = false,
        pendingHeartbeat = false,
        pendingLeave = false,
        pendingLeaderboardRevoke = false,
        revokeAttempts = 0,
        revokeFailed = false,
        mightHavePublicRank = false,
        lastError = nil,
        lastHTTP = nil,
        lastOk = nil,
        lastAction = "idle",
        lastOnline = nil,
        lastSuccess = nil,
    }, Client)
end

function Client:getStatus()
    -- No raw session ID, user ID or user names are exposed in status.
    return {
        active = self.active,
        adminNicknameConsent = self.adminSharing,
        adminProfileConsent = self.adminDetails,
        analyticsConsent = self.analytics,
        leaderboardConsent = self.leaderboard,
        avatarConsent = self.avatar,
        requestInProgress = self.running,
        lastAction = self.lastAction,
        lastHTTP = self.lastHTTP,
        lastOk = self.lastOk,
        lastError = self.lastError,
        lastOnline = self.lastOnline,
        lastSuccess = self.lastSuccess,
        leaderboardRevokeFailed = self.revokeFailed,
    }
end

-- Legacy callback: onStatus(ok, error). A third status value is optional.
-- Only notify on a completed heartbeat, matching v0.5.14 behavior.
function Client:_notify(completedHeartbeat)
    if completedHeartbeat then
        pcall(self.onStatus, self.lastOk, self.lastError, self:getStatus())
    end
end

-- Internal transport (HTTP 200 alone is NOT sufficient; JSON ok must be true).
function Client:_request(path, body)
    if path ~= HEARTBEAT and path ~= LEAVE and path ~= COUNT then
        return false, 0, "Unsupported public endpoint", nil
    end
    local options = {
        Url = BASE .. path,
        Method = body and "POST" or "GET",
        Headers = body and {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json",
        } or { ["Accept"] = "application/json" },
        Timeout = 10,
    }
    if body then options.Body = HttpService:JSONEncode(body) end
    local ok, response = pcall(self.request, options)
    if not ok or type(response) ~= "table" then
        return false, 0, "Network request failed", nil
    end
    local httpStatus = tonumber(response.StatusCode or response.Status) or 0
    local raw = response.Body
    if type(raw) ~= "string" or #raw > 32768 then
        return false, httpStatus, "Invalid response body", nil
    end
    local decoded, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not decoded or type(data) ~= "table" then
        return false, httpStatus, "Invalid response JSON", nil
    end
    if httpStatus ~= 200 or data.ok ~= true then
        return false, httpStatus, tostring(data.error or "Unexpected API result"), data
    end
    return true, httpStatus, nil, data
end

-- v0.5.14 compatibility helper, if a caller used :_send(path) directly.
-- This does not allow a heartbeat unless Active User has been opted into.
function Client:_send(path)
    if path == HEARTBEAT then
        if not self.active then return false, "Active User is not enabled" end
        local ok, _, err = self:_request(HEARTBEAT, self:_heartbeatBody())
        return ok, err
    elseif path == LEAVE then
        local ok, _, err = self:_request(LEAVE, self:_leaveBody(false))
        return ok, err
    end
    return false, "Unsupported endpoint"
end

function Client:_heartbeatBody()
    local body = {sessionId = self.sessionId}
    -- Profile fields are transmitted ONLY when a distinct opt-in requires them.
    -- Admin consent and leaderboard consent are independent.
    if self.adminSharing or self.adminDetails or self.leaderboard then
        body.profileConsent = true
        body.userId = tostring(self.player.UserId)
        body.username = self.player.Name
        body.displayName = self.player.DisplayName
        body.adminProfileConsent = self.adminSharing or self.adminDetails
        if self.adminDetails then body.adminDetailsConsent = true end
    end
    if self.analytics then
        body.analyticsConsent = true
        body.analyticsUserId = tostring(self.player.UserId)
        body.leaderboardConsent = self.leaderboard
        body.avatarConsent = self.leaderboard and self.avatar
    end
    return body
end

function Client:_leaveBody(revokeLeaderboard)
    local body = {sessionId = self.sessionId}
    if revokeLeaderboard then
        -- The Worker accepts revocation on /leave without an extra analytics
        -- heartbeat. This removes the live analytics session and public rank.
        body.analyticsConsent = true
        body.analyticsUserId = tostring(self.player.UserId)
        body.leaderboardConsent = false
    end
    return body
end

function Client:_schedule()
    if self.running then return end
    self.running = true
    task.spawn(function()
        while self.pendingLeave or self.pendingHeartbeat do
            local doLeave = self.pendingLeave
            local revoke = doLeave and self.pendingLeaderboardRevoke
            local payload
            local path
            if doLeave then
                self.pendingLeave = false
                if revoke then self.pendingLeaderboardRevoke = false end
                payload = self:_leaveBody(revoke)
                path = LEAVE
            else
                self.pendingHeartbeat = false
                if self.active then
                    payload = self:_heartbeatBody()
                    path = HEARTBEAT
                end
            end
            if path then
                self.lastAction = path == HEARTBEAT and "heartbeat" or "leave"
                local ok, code, err, data = self:_request(path, payload)
                self.lastOk = ok
                self.lastHTTP = code
                self.lastError = err
                if ok then self.lastSuccess = os.time() end
                if ok and path == HEARTBEAT and payload.analyticsConsent == true then
                    if payload.leaderboardConsent == true then
                        self.mightHavePublicRank = true
                    elseif payload.leaderboardConsent == false then
                        self.mightHavePublicRank = false
                    end
                end
                if revoke then
                    self.revokeFailed = not ok
                    if ok then
                        self.mightHavePublicRank = false
                        self.revokeAttempts = 0
                    elseif self.revokeAttempts < 3 then
                        self.revokeAttempts += 1
                        local expectedAttempt = self.revokeAttempts
                        task.delay(5 * expectedAttempt, function()
                            if self.revokeFailed and self.revokeAttempts == expectedAttempt then
                                self.pendingLeaderboardRevoke = true
                                self.pendingLeave = true
                                if self.active then self.pendingHeartbeat = true end
                                self:_schedule()
                            end
                        end)
                    end
                end
                if doLeave and self.active then
                    -- Leave after revoking a public rank; restore anonymous/opt-in
                    -- presence using the *latest* consent settings.
                    self.pendingHeartbeat = true
                end
                if data and path == HEARTBEAT and data.accepted == false then
                    -- A deduplicated heartbeat is not a transport error.
                    self.lastAction = "heartbeat_deduplicated"
                end
                self:_notify(path == HEARTBEAT)
            end
        end
        self.running = false
        -- May have received a new update while leaving the processing loop.
        if self.pendingLeave or self.pendingHeartbeat then self:_schedule() end
    end)
end

function Client:_queueHeartbeat()
    if self.active then
        self.pendingHeartbeat = true
        self:_schedule()
    end
end

function Client:count()
    local ok, code, err, data = self:_request(COUNT)
    self.lastHTTP = code
    self.lastOk = ok
    self.lastError = err
    self.lastAction = "count"
    if ok and type(data.online) == "number" then
        self.lastOnline = data.online
        self.lastSuccess = os.time()
    end
    self:_notify()
    return ok, ok and data.online or err
end

function Client:start(consent)
    if consent ~= true then
        return false, "Explicit Active User consent required; nothing was sent"
    end
    if self.active then return true, "Already active" end
    -- One active instance per client: no duplicate 30s heartbeat streams.
    local env = globalEnvironment()
    if env then
        local previous = env[SINGLETON_KEY]
        if previous and previous ~= self and type(previous.isEnabled) == "function"
            and previous:isEnabled() then
            return false, "Another UniversalPresence instance is active; stop it first"
        end
        -- The separate Phase2 prototype must not run alongside this module.
        local prototype = env.ArcScriptPresenceClient
        if prototype and prototype ~= self and type(prototype.isEnabled) == "function"
            and prototype:isEnabled() then
            return false, "Stop the separate Phase2 Presence client first"
        end
        env[SINGLETON_KEY] = self
    end
    self.active = true
    self.generation += 1
    local currentRun = self.generation
    self:_queueHeartbeat()
    task.spawn(function()
        -- The server recommends one heartbeat approximately every 30 seconds.
        while self.active and self.generation == currentRun do
            task.wait(INTERVAL)
            if self.active and self.generation == currentRun then
                self:_queueHeartbeat()
            end
        end
    end)
    return true
end

function Client:setAdminNicknameConsent(enabled)
    if type(enabled) ~= "boolean" then return false, "Expected boolean" end
    if enabled and not self.active then return false, "Enable Active User first" end
    if self.adminSharing == enabled then return true end
    local revoke = self.adminSharing and not enabled
    self.adminSharing = enabled
    self.profile = enabled and {
        consent = true,
        userId = tostring(self.player.UserId),
        username = self.player.Name,
        displayName = self.player.DisplayName,
    } or nil
    if revoke and self.active then
        -- Clear the admin-visible profile immediately via /leave, which is not
        -- subject to the optional presence-heartbeat rate limiter. The queue
        -- then restores the current anonymous / analytics-enabled session.
        self.pendingLeave = true
    end
    self:_queueHeartbeat()
    return true
end

-- Full profile for PRIVATE admins: separate, explicit consent.
-- Legacy setAdminNicknameConsent remains nickname-only (level 1).
function Client:setAdminProfileConsent(enabled)
    if type(enabled) ~= "boolean" then return false, "Expected boolean" end
    if enabled and not self.active then return false, "Enable Active User first" end
    if self.adminDetails == enabled then return true end
    local revoking = self.adminDetails and not enabled
    self.adminDetails = enabled
    if revoking and self.active then
        self.pendingLeave = true -- remove detailed profile immediately
    end
    self:_queueHeartbeat()
    return true
end

function Client:setAnalyticsConsent(enabled)
    if type(enabled) ~= "boolean" then return false, "Expected boolean" end
    if enabled and not self.active then return false, "Enable Active User first" end
    if self.analytics == enabled then return true end
    -- A previously queued leaderboard ON request might still be in flight.
    local mustRevokeRank = not enabled and (self.leaderboard or self.mightHavePublicRank)
    self.analytics = enabled
    if not enabled then
        self.leaderboard = false
        self.avatar = false
        if mustRevokeRank then
            -- Revoke public rank with /leave first (does not add new analytics
            -- credit), then immediately restore the active presence session.
            self.pendingLeaderboardRevoke = true
            self.pendingLeave = true
        end
    end
    self:_queueHeartbeat()
    return true
end

function Client:setLeaderboardConsent(enabled)
    if type(enabled) ~= "boolean" then return false, "Expected boolean" end
    if enabled and not self.analytics then
        return false, "Enable Analytics consent before public Leaderboard"
    end
    if self.leaderboard == enabled and not (not enabled and self.mightHavePublicRank) then
        return true
    end
    local revoke = not enabled and (self.leaderboard or self.mightHavePublicRank)
    self.leaderboard = enabled
    if enabled then self.mightHavePublicRank = true end
    if not enabled then
        self.avatar = false
        if revoke and self.active then
            -- Remove the public ranking right away, independent of heartbeat
            -- throttling; restore active presence with the latest consent state.
            self.pendingLeaderboardRevoke = true
            self.pendingLeave = true
        end
    end
    self:_queueHeartbeat()
    return true
end

function Client:setAvatarConsent(enabled)
    if type(enabled) ~= "boolean" then return false, "Expected boolean" end
    if enabled and not self.leaderboard then
        return false, "Enable public Leaderboard consent before Avatar sharing"
    end
    if self.avatar == enabled then return true end
    local revokeAvatar = self.avatar and not enabled and self.leaderboard
    self.avatar = enabled
    if revokeAvatar and self.active then
        -- /leave revokes the avatar cache without waiting for heartbeat limits.
        -- The following heartbeat restores the opted-in leaderboard, no avatar.
        self.pendingLeaderboardRevoke = true
        self.pendingLeave = true
    end
    self:_queueHeartbeat()
    return true
end

function Client:stop()
    if not self.active and not self.pendingHeartbeat and not self.running then
        return false, "Already stopped"
    end
    local env = globalEnvironment()
    if env and env[SINGLETON_KEY] == self then env[SINGLETON_KEY] = nil end
    local revoke = self.leaderboard or self.mightHavePublicRank or self.pendingLeaderboardRevoke
    self.active = false
    self.adminSharing = false
    self.adminDetails = false
    self.profile = nil
    self.analytics = false
    self.leaderboard = false
    self.avatar = false
    self.generation += 1
    self.pendingHeartbeat = false
    self.pendingLeave = true
    if revoke then self.pendingLeaderboardRevoke = true end
    -- Best effort: a lost Leave is recovered by the Worker presence TTL.
    self:_schedule()
    return true
end

function Client:retryLeaderboardRevoke()
    if not self.revokeFailed then return false, "No failed revocation" end
    self.revokeAttempts = 0
    self.pendingLeaderboardRevoke = true
    self.pendingLeave = true
    self:_schedule()
    return true
end

-- Convenience method for the Arcsen Settings Active User toggle.
function Client:setActive(enabled)
    if type(enabled) ~= "boolean" then return false, "Expected boolean" end
    if enabled then return self:start(true) end
    if self.active then return self:stop() end
    return true, "Already disabled"
end

function Client:isEnabled()
    return self.active
end

return Client
