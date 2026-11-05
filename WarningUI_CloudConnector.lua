-- ArcScriptCenter Cloud Warning Connector v0.5.13
-- Install with WarningUI.lua (Preview v0.1.0+) already loaded.
-- Server means ArcScriptCenter's Cloudflare Worker, NOT another game's Roblox server.
-- Only reads public, approved service notices. No secrets or user data are sent.

local shared = type(getgenv) == 'function' and getgenv() or nil
assert(type(shared) == 'table', 'WarningUI CloudConnector needs getgenv()')

local ui = shared.WarningUI
assert(type(ui) == 'table' and type(ui.startServerPolling) == 'function',
    'Load WarningUI.lua before WarningUI_CloudConnector.lua')

-- Stop older polling loops before starting a new one.
if type(ui.stopServerPolling) == 'function' then
    ui.stopServerPolling()
end

local HttpService = game:GetService('HttpService')
local url = 'https://arcscriptcenter-api.kogpasan14.workers.dev/api/v1/warnings'
local requestFn = type(request) == 'function' and request
    or type(http_request) == 'function' and http_request
    or type(syn) == 'table' and type(syn.request) == 'function' and syn.request
    or type(http) == 'table' and type(http.request) == 'function' and http.request
    or type(shared.request) == 'function' and shared.request

local lastErrorAt = 0
local function readWarnings()
    local raw
    if type(requestFn) == 'function' then
        local ok, response = pcall(requestFn, {
            Url = url,
            Method = 'GET',
            Headers = {Accept = 'application/json'},
            Timeout = 10
        })
        if not ok or type(response) ~= 'table' then
            error('Cloud Warning request failed')
        end
        local status = tonumber(response.StatusCode or response.Status or 0)
        if status ~= 200 then
            error('Cloud Warning HTTP ' .. tostring(status))
        end
        raw = response.Body
    else
        local ok, response = pcall(function()
            return game:HttpGet(url)
        end)
        if not ok then error('HTTP GET is unavailable in this environment') end
        raw = response
    end

    if type(raw) ~= 'string' then error('Invalid Warning API response') end
    local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok or type(data) ~= 'table' or data.ok ~= true or type(data.warnings) ~= 'table' then
        error('Invalid Warning API JSON')
    end
    return data
end

local function fetcher()
    local ok, data = pcall(readWarnings)
    if ok then return data end
    if os.time() - lastErrorAt >= 120 then
        warn('[WarningUI] ' .. tostring(data))
        lastErrorAt = os.time()
    end
    return nil
end

local started, reason = ui.startServerPolling(fetcher, 30)
assert(started, tostring(reason or 'Unable to start WarningUI polling'))

shared.ArcScriptWarningConnector = {
    version = '0.5.13',
    stop = function()
        ui.stopServerPolling()
    end
}
return shared.ArcScriptWarningConnector
