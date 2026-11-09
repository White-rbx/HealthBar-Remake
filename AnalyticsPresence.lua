-- ArcScriptCenter v0.5.35 — OPTIONAL, EXPLICITLY OPTED-IN usage telemetry.
-- This is a standalone client adapter for ExperienceSettings.
-- It does NOT send chat, movement, location, inventories, or private messages.
-- Usage (from your EXISTING toggle handlers):
--   local Analytics = [load this module]()
--   Analytics:SetActiveUser(true)       -- existing 'Active User' setting
--   Analytics:SetShowToAdmin(true)      -- existing 'Show to Admin' setting
--   Analytics:SetAnalyticsConsent(true) -- independent optional consent
--   Analytics:SetLeaderboardConsent(true) -- independent optional public-name consent
-- Anonymous active status is controlled by Function_Two. Analytics/leaderboard/avatar opt-in separately.

local Players = game:GetService('Players')
local HttpService = game:GetService('HttpService')
local LocalPlayer = Players.LocalPlayer

local M = {}
M.__index = M

local API_DEFAULT = 'https://arcscriptcenter-api.kogpasan14.workers.dev'
local HEARTBEAT = 30

local function getRequest()
    local env = type(getgenv) == 'function' and getgenv() or nil
    if type(env) == 'table' then
        if type(env.request) == 'function' then return env.request end
        if type(env.http_request) == 'function' then return env.http_request end
        if type(env.syn) == 'table' and type(env.syn.request) == 'function' then return env.syn.request end
    end
    if type(request) == 'function' then return request end
    if type(http_request) == 'function' then return http_request end
    if type(syn) == 'table' and type(syn.request) == 'function' then return syn.request end
    return nil
end

function M.new(opts)
    opts = type(opts) == 'table' and opts or {}
    local self = setmetatable({}, M)
    self.api = tostring(opts.url or API_DEFAULT):gsub('/+$','')
    if not self.api:match('^https://[%w%-%.]+$') then
        return nil, 'ArcScriptCenter URL must be an HTTPS hostname'
    end
    self._request = opts.httpRequest or getRequest()
    if type(self._request) ~= 'function' then
        return nil, 'No compatible HTTP request function available'
    end
    self.sessionId = HttpService:GenerateGUID(false):gsub('[^%x]',''):lower()
    self.activeUser = false
    self.showToAdmin = false
    self.analyticsConsent = false
    self.leaderboardConsent = false
    self.avatarConsent = false
    self.running = false
    self.destroyed = false
    self.epoch = 0
    self.busy = false
    self.lastError = nil
    self.loopId = 0
    self._connections = {}
    table.insert(self._connections, Players.PlayerRemoving:Connect(function(player)
        if player == LocalPlayer then self:Destroy(false) end
    end))
    return self
end

function M:_send(path, data)
    local response = self._request({
        Url = self.api .. '/api/v1/presence/' .. path,
        Method = 'POST',
        Headers = {['Content-Type']='application/json',Accept='application/json'},
        Body = HttpService:JSONEncode(data)
    })
    local code = tonumber(response and (response.StatusCode or response.Status)) or 0
    if code < 200 or code >= 300 then
        return false, 'Presence HTTP ' .. tostring(code)
    end
    return true
end

function M:_payload()
    local body = { sessionId = self.sessionId }
    -- Public leaderboard profile and admin presence profile are separate consents.
    local wantsPublic = self.analyticsConsent and self.leaderboardConsent
    local wantsAdmin = self.showToAdmin
    if wantsPublic or wantsAdmin then
        body.profileConsent = true
        body.adminProfileConsent = wantsAdmin == true
        body.userId = tostring(LocalPlayer.UserId)
        body.username = tostring(LocalPlayer.Name)
        body.displayName = tostring(LocalPlayer.DisplayName)
    end
    if self.analyticsConsent then
        body.analyticsConsent = true
        body.analyticsUserId = tostring(LocalPlayer.UserId)
        body.leaderboardConsent = wantsPublic == true
        body.avatarConsent = wantsPublic and self.avatarConsent == true or false
    end
    return body
end

function M:_leave(revokeRanking)
    local body = {sessionId=self.sessionId}
    if revokeRanking and self.analyticsConsent then
        body.analyticsConsent = true
        body.analyticsUserId = tostring(LocalPlayer.UserId)
        body.leaderboardConsent = false
    end
    -- Best effort only: abrupt game exits/network loss are handled by server TTL.
    task.spawn(function()
        pcall(function() self:_send('leave',body) end)
    end)
end

function M:_eligible()
    return not self.destroyed and self.activeUser
end

function M:_heartbeat()
    if not self:_eligible() or self.busy then return end
    local epoch = self.epoch
    local payload = self:_payload()
    self.busy = true
    task.spawn(function()
        local ok,success,why = pcall(function() return self:_send('heartbeat',payload) end)
        self.busy = false
        if not ok or not success then self.lastError = tostring(why or success)
        else self.lastError=nil end
        -- A delayed HTTP request must never re-enable a toggled-off session.
        if epoch ~= self.epoch then
            if self:_eligible() then self:_heartbeat() else self:_leave(false) end
        end
    end)
end

function M:_reconcile(oldEnabled, revokeRanking)
    if self.destroyed then return end
    local enabled = self:_eligible()
    self.epoch += 1
    if not enabled then
        if oldEnabled then self:_leave(revokeRanking) end
        self.running = false
        self.loopId += 1
        return
    end
    self:_heartbeat()
    if self.running then return end
    self.running = true
    self.loopId += 1
    local token = self.loopId
    task.spawn(function()
        while self.running and not self.destroyed and self.loopId == token do
            task.wait(HEARTBEAT)
            if self.loopId ~= token or not self:_eligible() then break end
            self:_heartbeat()
        end
        if self.loopId == token then self.running=false end
    end)
end

-- Hook existing UI controls to these setters; DO NOT create a second toggle panel.
function M:SetActiveUser(value)
    local was = self:_eligible()
    self.activeUser = value == true
    self:_reconcile(was, false)
end
function M:SetShowToAdmin(value)
    local was = self:_eligible()
    self.showToAdmin = value == true
    self:_reconcile(was, false)
end
function M:SetAnalyticsConsent(value)
    local was = self:_eligible()
    -- Withdrawn analytics consent also withdraws public ranking, including while paused.
    if self.analyticsConsent and value ~= true then self:_leave(true) end
    self.analyticsConsent = value == true
    if not self.analyticsConsent then
        self.leaderboardConsent = false
        self.avatarConsent = false
    end
    self:_reconcile(was, false)
end
function M:SetLeaderboardConsent(value)
    local was = self:_eligible()
    if value == true and not self.analyticsConsent then
        return false, 'Enable usage tracking consent first'
    end
    local turningOff = self.leaderboardConsent and value ~= true
    self.leaderboardConsent = value == true
    if not self.leaderboardConsent then self.avatarConsent = false end
    if turningOff and not was then self:_leave(true) end
    self:_reconcile(was, false)
    return true
end
function M:SetAvatarConsent(value)
    if value == true and (not self.analyticsConsent or not self.leaderboardConsent) then
        return false, 'Enable leaderboard sharing first'
    end
    self.avatarConsent = value == true
    self:_reconcile(self:_eligible(), false)
    return true
end
function M:GetStatus()
    return {
        active = self:_eligible(),
        analytics = self.analyticsConsent,
        leaderboard = self.leaderboardConsent,
        avatar = self.avatarConsent,
        showToAdmin = self.showToAdmin,
        lastError = self.lastError,
    }
end
function M:Destroy(revokeRanking)
    if self.destroyed then return end
    local was = self:_eligible()
    if was then self:_leave(revokeRanking == true) end
    self.destroyed=true;self.running=false;self.epoch += 1;self.loopId += 1
    for _,connection in ipairs(self._connections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(self._connections)
end

return M
