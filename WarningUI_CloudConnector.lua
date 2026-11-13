-- ArcScriptCenter Phase 2 - Production Bootstrap + WarningUI Connector v0.5.41.1
-- Read-only public HTTPS GET only. NO secrets, Roblox UserId, or executable source.
-- Load AFTER the existing WarningUI is initialized. Never use the staging Worker.

local env = type(getgenv) == "function" and getgenv() or nil
assert(type(env) == "table", "ArcScriptCenter requires getgenv()")
local ui = env.WarningUI
assert(type(ui) == "table" and type(ui.startServerPolling) == "function",
    "WarningUI must be initialized before the connector")

-- Replace older connector's polling loop, but keep WarningUI and its UI/UX intact.
if type(env.ArcScriptWarningConnector) == "table"
    and type(env.ArcScriptWarningConnector.stop) == "function" then
    pcall(env.ArcScriptWarningConnector.stop)
end
if type(ui.stopServerPolling) == "function" then
    ui.stopServerPolling()
end

local HttpService = game:GetService("HttpService")
local BASE = "https://arcscriptcenter-api.kogpasan14.workers.dev"
local BOOTSTRAP_PATH = "/api/v1/client/bootstrap"
local WARNINGS_PATH = "/api/v1/warnings"
local requestFn = type(request) == "function" and request
    or type(http_request) == "function" and http_request
    or type(syn) == "table" and type(syn.request) == "function" and syn.request
    or type(http) == "table" and type(http.request) == "function" and http.request
    or type(env.request) == "function" and env.request

local status = {
    connectorVersion = "0.5.41.1-phase2",
    host = BASE,
    bootstrap = {ok=false, state="pending"},
    warnings = {ok=false, state="pending", count=0},
}
env.ArcScriptClientStatus = status
env.ArcScriptWarningStatus = {ok=false, stage="pending", count=0}

local function publicGetJSON(path, maxBytes)
    -- Never construct URLs from untrusted server responses.
    if path ~= BOOTSTRAP_PATH and path ~= WARNINGS_PATH then
        error("Unrecognized public endpoint")
    end
    local url = BASE .. path
    local raw
    if type(requestFn) == "function" then
        local ok, response = pcall(requestFn, {
            Url = url, Method = "GET", Headers = {Accept="application/json"}, Timeout=10
        })
        if not ok or type(response) ~= "table" then
            error("Public API HTTP request unavailable")
        end
        local httpStatus = tonumber(response.StatusCode or response.Status or 0)
        if httpStatus ~= 200 then
            error("Public API HTTP " .. tostring(httpStatus))
        end
        raw = response.Body
    else
        -- Compatibility fallback; still only uses the fixed Production HTTPS URL.
        local ok, body = pcall(function() return game:HttpGet(url) end)
        if not ok then error("HTTPS GET is unavailable") end
        raw = body
    end
    if type(raw) ~= "string" or #raw > maxBytes then
        error("Invalid or oversized public API response")
    end
    local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok or type(data) ~= "table" or data.ok ~= true then
        error("Invalid public API JSON")
    end
    return data
end

local nextBootstrapRetry = 0
local lastWarningLog = 0
local function readBootstrap()
    local now=os.time()
    if status.bootstrap.ok or now < nextBootstrapRetry then return end
    nextBootstrapRetry=now+120
    local ok, data=pcall(publicGetJSON, BOOTSTRAP_PATH, 16384)
    if ok and data.service == "ArcScriptCenter" and data.protocol == 1
        and data.client == "executor_sunc" and data.mode == "read_only_public"
        and type(data.version) == "string"
        and type(data.endpoints) == "table"
        and data.endpoints.publicWarnings == WARNINGS_PATH then
        status.bootstrap={ok=true,state="online",version=data.version,
            protocol=data.protocol,lastSuccess=now}
    else
        status.bootstrap={ok=false,state="degraded",
            error=ok and "Unexpected bootstrap protocol" or tostring(data)}
        -- A transient Bootstrap error does not block local UI or public warnings.
    end
end

local function warningsFetcher()
    readBootstrap()
    local ok, data=pcall(publicGetJSON, WARNINGS_PATH, 131072)
    if not ok or type(data.warnings) ~= "table" then
        local reason=ok and "Missing warnings array" or tostring(data)
        local previous=status.warnings.lastSuccess
        status.warnings={ok=false,state="degraded",error=reason,
            lastSuccess=previous,count=0}
        env.ArcScriptWarningStatus={ok=false,stage="fetch",error=reason,
            lastSuccess=previous,count=0}
        if os.time()-lastWarningLog >= 120 then
            warn("[ArcScriptCenter Phase2] Public warnings: " .. reason)
            lastWarningLog=os.time()
        end
        return nil
    end
    local now=os.time()
    status.warnings={ok=true,state="online",lastSuccess=now,
        count=#data.warnings}
    env.ArcScriptWarningStatus={ok=true,stage="online",lastSuccess=now,
        count=#data.warnings}
    return data
end

-- Bootstrap is only advisory. WarningUI retains its existing queue, deduplication,
-- Only Live and expiry checks; it never executes code from the API.
readBootstrap()
local started, reason=ui.startServerPolling(warningsFetcher, 15)
assert(started, tostring(reason or "Could not start public warnings polling"))

local controller={
    version="0.5.41.1-phase2",
    baseUrl=BASE,
    getStatus=function() return status end,
    stop=function()
        if type(ui.stopServerPolling) == "function" then
            ui.stopServerPolling()
        end
        status.warnings.state="stopped"
    end,
}
env.ArcScriptWarningConnector=controller
return controller
