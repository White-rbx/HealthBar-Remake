-- Install only in ServerScriptService of the owner-authorized Roblox test experience.
-- Provision BAN_GAME_SERVER_SECRET in Roblox's Secrets Store, scoped to the QA Worker.
-- Do not publish any server credential or accept a UserId/URL from RemoteFunction inputs.
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local stagingGitHub = script:GetAttribute("UseStagingGitHub") == true
local tokenQA = not stagingGitHub and script:GetAttribute("BannedTokenQA") == true
local api = stagingGitHub
    and "https://arcscriptcenter-api-staging.kogpasan14.workers.dev/api/v1/roblox/bans/v2/"
    or (tokenQA and "https://arcscriptcenter-banned-token-qa.kogpasan14.workers.dev/api/v1/roblox/bans/v2/"
        or "https://arcscriptcenter-ban-v2-qa.kogpasan14.workers.dev/api/v1/roblox/bans/v2/")
local unavailable = { ok = false, code = "server_unavailable" }

local remote = Instance.new("RemoteFunction")
remote.Name = "ArcScriptCenterBanBridgeSTAGING"
remote:SetAttribute("IsolatedQA", not stagingGitHub)
remote:SetAttribute("BannedTokenQA", tokenQA)
local requests = {}
Players.PlayerRemoving:Connect(function(player) requests[player] = nil end)

local function send(player, operation, noticeId, description)
    local data = { userId = tostring(player.UserId), universeId = tostring(game.GameId) }
    if operation == "appeal" then
        data.noticeId, data.description = noticeId, description
    elseif tokenQA and (operation == "policy" or operation == "violation") then
        data.username = player.Name
    end
    local ok, reply = pcall(function()
        return HttpService:RequestAsync({
            Url = api .. operation,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = HttpService:GetSecret("BAN_GAME_SERVER_SECRET"):AddPrefix("Bearer "),
            },
            Body = HttpService:JSONEncode(data),
        })
    end)
    if not ok or type(reply) ~= "table" or type(reply.Body) ~= "string" or #reply.Body > 300000 then return unavailable end
    local parsed, result = pcall(HttpService.JSONDecode, HttpService, reply.Body)
    if not parsed or type(result) ~= "table" then return unavailable end
    if not reply.Success then
        return { ok = false, code = result.code or "server_unavailable" }
    end
    if result.ok ~= true then return unavailable end
    return result
end

remote.OnServerInvoke = function(player, operation, noticeId, description)
    if player.Parent ~= Players or not (operation == "policy" or operation == "violation" or operation == "appeal") then
        return { ok = false, code = "invalid_request" }
    end
    if operation == "appeal" and (type(noticeId) ~= "string" or #noticeId > 70
        or type(description) ~= "string" or #description > 20000) then
        return { ok = false, code = "invalid_request" }
    end
    local now = os.clock()
    local calls = requests[player]
    if not calls then calls = {}; requests[player] = calls end
    local pending = calls[operation]
    if pending and (pending.busy or now - pending.startedAt < 2) then
        return { ok = false, code = "rate" }
    end
    pending = { busy = true, startedAt = now }
    calls[operation] = pending
    local ok, result = pcall(send, player, operation, noticeId, description)
    pending.busy = false
    if not ok or player.Parent ~= Players then return unavailable end
    return result
end
remote.Parent = ReplicatedStorage
